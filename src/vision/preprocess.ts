// Gemma-4 unified image preprocessing — port of optiq's
// vlm/gemma4_unified/image_processing.py (vendored from mlx-vlm, BSD-3).
//
// decode → aspect-ratio-preserving resize (PIL-style convolution
// resampling, bicubic kernel with antialias-scaled support) → rescale
// 1/255 → patchify into 48×48 patch vectors with 2D grid positions →
// pad to the 280 soft-token budget.
//
// Decode strategy (Bun ≥1.3.14): PNG goes straight through fast-png
// (exact, lossless — the parity-golden path). Everything else (JPEG,
// HEIC, AVIF, WebP, TIFF, GIF, BMP) is transcoded to lossless PNG by
// Bun.Image — native OS codecs (ImageIO on macOS), EXIF auto-orient,
// off-thread — then decoded by fast-png. Bun.Image has no raw-pixel
// terminal, so the PNG bridge is the supported path to pixels.
//
// Resize note: Bun.Image.resize is NOT used — its kernels (lanczos3,
// cubic≠PIL-bicubic) don't match PIL's antialiased bicubic, which the
// vision tower was trained behind. PIL's exact float pipeline isn't
// bit-reproducible here either, so vision logits can differ slightly
// from the python stack on images that need resizing. Images already
// sized to multiples of 48 (≤2520 patches) skip the resize entirely and
// are bit-identical through preprocessing.

import { decode as decodePng } from "fast-png";

export const PATCH_SIZE = 16;
export const POOLING_KERNEL_SIZE = 3;
export const MODEL_PATCH_SIZE = 48; // patch_size * pooling_kernel_size
export const NUM_SOFT_TOKENS = 280;

export interface RGBImage {
  width: number;
  height: number;
  /** Row-major RGB, 3 bytes/px. */
  data: Uint8Array;
}

export interface PreprocessedImage {
  /** [numSoftTokens, 6912] f32 patch vectors (padded). */
  patches: Float32Array;
  /** [numSoftTokens, 2] (x, y) grid positions; -1 padding. */
  positions: Int32Array;
  /** Real (unpadded) soft-token count. */
  softTokens: number;
}

function pngToRgb(bytes: Uint8Array): RGBImage {
  const png = decodePng(bytes);
  const ch = png.channels;
  const out = new Uint8Array(png.width * png.height * 3);
  const src = png.data as Uint8Array;
  const n = png.width * png.height;
  if (png.depth === 16) {
    const src16 = png.data as Uint16Array;
    for (let i = 0; i < n; i++)
      for (let c = 0; c < 3; c++)
        out[i * 3 + c] = src16[i * ch + Math.min(c, ch - 1)]! >> 8;
  } else {
    for (let i = 0; i < n; i++)
      for (let c = 0; c < 3; c++)
        out[i * 3 + c] = src[i * ch + Math.min(c, ch - 1)]!;
  }
  return { width: png.width, height: png.height, data: out };
}

export async function decodeImage(bytes: Uint8Array): Promise<RGBImage> {
  // PNG: direct, exact (the parity-golden path)
  if (bytes.length > 8 && bytes[0] === 0x89 && bytes[1] === 0x50)
    return pngToRgb(bytes);
  // everything else: native transcode to lossless PNG (HEIC/AVIF/WebP/
  // JPEG/TIFF/GIF/BMP — whatever the OS codecs decode), EXIF auto-orient
  try {
    const png = await new Bun.Image(bytes).png({ compressionLevel: 1 }).bytes();
    return pngToRgb(png);
  } catch (e) {
    const code = (e as { code?: string }).code;
    throw new Error(
      code === "ERR_IMAGE_UNKNOWN_FORMAT"
        ? "unsupported image format"
        : `image decode failed: ${(e as Error).message}`,
    );
  }
}

// --- PIL-style convolution resize (bicubic, a = -0.5) ---------------------

function bicubic(x: number): number {
  const a = -0.5;
  x = Math.abs(x);
  if (x < 1) return ((a + 2) * x - (a + 3)) * x * x + 1;
  if (x < 2) return (((x - 5) * x + 8) * x - 4) * a;
  return 0;
}

interface ResampleCoeffs {
  bounds: Int32Array; // [outSize × 2]: (start, count)
  weights: Float64Array; // [outSize × kmax]
  kmax: number;
}

/** Port of PIL's precompute_coeffs (antialias: support scales with ratio). */
function precomputeCoeffs(inSize: number, outSize: number): ResampleCoeffs {
  const SUPPORT = 2.0;
  const scale = inSize / outSize;
  const filterscale = Math.max(scale, 1.0);
  const support = SUPPORT * filterscale;
  const kmax = Math.ceil(support) * 2 + 1;
  const bounds = new Int32Array(outSize * 2);
  const weights = new Float64Array(outSize * kmax);

  for (let xx = 0; xx < outSize; xx++) {
    const center = (xx + 0.5) * scale;
    let xmin = Math.floor(center - support);
    if (xmin < 0) xmin = 0;
    let xmax = Math.ceil(center + support);
    if (xmax > inSize) xmax = inSize;
    const count = xmax - xmin;
    let sum = 0;
    for (let k = 0; k < count; k++) {
      const w = bicubic((xmin + k - center + 0.5) / filterscale);
      weights[xx * kmax + k] = w;
      sum += w;
    }
    if (sum !== 0)
      for (let k = 0; k < count; k++) weights[xx * kmax + k]! /= sum;
    bounds[xx * 2] = xmin;
    bounds[xx * 2 + 1] = count;
  }
  return { bounds, weights, kmax };
}

/** Separable resize on float RGB planes (clamped back to [0,255] like PIL). */
export function resizeBicubic(img: RGBImage, outW: number, outH: number): RGBImage {
  const { width: inW, height: inH, data } = img;
  // horizontal pass → [inH, outW]
  const hCoef = precomputeCoeffs(inW, outW);
  const tmp = new Float64Array(inH * outW * 3);
  for (let y = 0; y < inH; y++) {
    for (let x = 0; x < outW; x++) {
      const xmin = hCoef.bounds[x * 2]!;
      const count = hCoef.bounds[x * 2 + 1]!;
      let r = 0, g = 0, b = 0;
      for (let k = 0; k < count; k++) {
        const w = hCoef.weights[x * hCoef.kmax + k]!;
        const src = (y * inW + xmin + k) * 3;
        r += data[src]! * w;
        g += data[src + 1]! * w;
        b += data[src + 2]! * w;
      }
      const dst = (y * outW + x) * 3;
      tmp[dst] = r;
      tmp[dst + 1] = g;
      tmp[dst + 2] = b;
    }
  }
  // vertical pass → [outH, outW]
  const vCoef = precomputeCoeffs(inH, outH);
  const out = new Uint8Array(outH * outW * 3);
  for (let y = 0; y < outH; y++) {
    const ymin = vCoef.bounds[y * 2]!;
    const count = vCoef.bounds[y * 2 + 1]!;
    for (let x = 0; x < outW; x++) {
      let r = 0, g = 0, b = 0;
      for (let k = 0; k < count; k++) {
        const w = vCoef.weights[y * vCoef.kmax + k]!;
        const src = ((ymin + k) * outW + x) * 3;
        r += tmp[src]! * w;
        g += tmp[src + 1]! * w;
        b += tmp[src + 2]! * w;
      }
      const dst = (y * outW + x) * 3;
      out[dst] = Math.min(255, Math.max(0, Math.round(r)));
      out[dst + 1] = Math.min(255, Math.max(0, Math.round(g)));
      out[dst + 2] = Math.min(255, Math.max(0, Math.round(b)));
    }
  }
  return { width: outW, height: outH, data: out };
}

/** Port of _aspect_ratio_preserving_resize. */
export function targetSize(
  width: number, height: number,
  patchSize = PATCH_SIZE, poolingKernel = POOLING_KERNEL_SIZE,
): { width: number; height: number } {
  const maxPatches = NUM_SOFT_TOKENS * poolingKernel ** 2;
  const targetPx = maxPatches * patchSize ** 2;
  const factor = Math.sqrt(targetPx / (height * width));
  const sideMult = poolingKernel * patchSize; // 48

  let tH = Math.floor((factor * height) / sideMult) * sideMult;
  let tW = Math.floor((factor * width) / sideMult) * sideMult;
  if (tH === 0 && tW === 0) throw new Error("image resizes to 0×0");

  const maxSide = Math.floor(maxPatches / poolingKernel ** 2) * sideMult;
  if (tH === 0) {
    tH = sideMult;
    tW = Math.min(Math.floor(width / height) * sideMult, maxSide);
  } else if (tW === 0) {
    tW = sideMult;
    tH = Math.min(Math.floor(height / width) * sideMult, maxSide);
  }
  return { width: tW, height: tH };
}

/** Full pipeline: bytes → padded patch vectors + grid positions. */
export async function preprocessImage(bytes: Uint8Array): Promise<PreprocessedImage> {
  let img = await decodeImage(bytes);
  const t = targetSize(img.width, img.height);
  if (t.width !== img.width || t.height !== img.height)
    img = resizeBicubic(img, t.width, t.height);

  const { width, height, data } = img;
  const p = MODEL_PATCH_SIZE;
  const pH = Math.floor(height / p);
  const pW = Math.floor(width / p);
  const n = pH * pW;
  if (n === 0) throw new Error("image smaller than one 48×48 patch");
  if (n > NUM_SOFT_TOKENS)
    throw new Error(`image yields ${n} patches > budget ${NUM_SOFT_TOKENS}`);

  const patchDim = p * p * 3;
  const patches = new Float32Array(NUM_SOFT_TOKENS * patchDim);
  const positions = new Int32Array(NUM_SOFT_TOKENS * 2).fill(-1);

  // patch vector layout matches the python reshape/transpose:
  // [pH, pW, p, p, C] flattened — i.e. for patch (py, px):
  // index = ((dy * p) + dx) * 3 + c over [C=channel-last]... python does
  // transpose(1,3,2,4,0) from [C, pH, p, pW, p] → [pH, pW, p, p, C]
  for (let py = 0; py < pH; py++) {
    for (let px = 0; px < pW; px++) {
      const base = (py * pW + px) * patchDim;
      for (let dy = 0; dy < p; dy++) {
        for (let dx = 0; dx < p; dx++) {
          const src = ((py * p + dy) * width + px * p + dx) * 3;
          const dst = base + (dy * p + dx) * 3;
          // python rescales then patchifies in CHW; layout [p, p, C]
          patches[dst] = data[src]! / 255;
          patches[dst + 1] = data[src + 1]! / 255;
          patches[dst + 2] = data[src + 2]! / 255;
        }
      }
      positions[(py * pW + px) * 2] = px; // x
      positions[(py * pW + px) * 2 + 1] = py; // y
    }
  }
  return { patches, positions, softTokens: n };
}
