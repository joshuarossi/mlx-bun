// Qwen3-VL-family image preprocessing (Qwen3.8 vision, PLAN 14v) — port of
// mlx-vlm's Qwen3VLImageProcessor image path (processing_qwen3_vl.py):
//
//   decode → smart_resize to multiples of factor=patch*merge=32 (PIL-style
//   antialiased bicubic via the shared resizeBicubic) → rescale 1/255 →
//   normalize mean/std 0.5 → duplicate the frame temporal_patch_size(=2)
//   times → patchify into [grid_t*grid_h*grid_w, C*tps*ps*ps] rows.
//
// Row order is MERGE-BLOCK-MAJOR: rows enumerate (t, hBlock, wBlock, mh, mw)
// so each 2×2 spatial-merge block is contiguous; row elements enumerate
// (c, tFrame, py, px) — exactly the reference's transpose
// (0,1,4,7,5,8,3,2,6,9) before its final reshape. The tower's PatchEmbed and
// PatchMerger both assume this order.
//
// Images sized to multiples of 32 skip the resize and are bit-identical to
// the python pipeline through preprocessing (the gemma/SigLIP precedent);
// resized images carry the documented sub-ulp bicubic residual.

import { decodeImage, type RGBImage } from "./preprocess";

export const QWEN3VL_PATCH_SIZE = 16;
export const QWEN3VL_TEMPORAL_PATCH_SIZE = 2;
export const QWEN3VL_MERGE_SIZE = 2;
/** Qwen3VLImageProcessor defaults (no preprocessor_config.json in the
 *  artifact — mlx-vlm falls back to these class defaults too). */
export const QWEN3VL_MIN_PIXELS = 56 * 56;
export const QWEN3VL_MAX_PIXELS = 14 * 14 * 4 * 1280;

export interface Qwen3VLPreprocessed {
  /** [gridT*gridH*gridW, C*tps*ps*ps] f32 patch rows (merge-block-major). */
  pixelValues: Float32Array;
  rows: number;
  cols: number;
  /** [t, h, w] in PATCH units (h = resizedH/16 etc.). */
  gridThw: [number, number, number];
  /** Language-side image token count = t * (h/merge) * (w/merge). */
  imageTokens: number;
  /** Videos only: per-temporal-group timestamps in seconds (frame-pair
   *  averaged, transformers `_calculate_timestamps`) — the `<X.X seconds>`
   *  headers the prompt builder renders before each frame group. */
  groupTimestamps?: number[];
}

/** Python `f"{x:.1f}"` — correct rounding of the double with HALF-TO-EVEN
 *  at the decimal digit. JS toFixed rounds exact .x5 ties AWAY from zero
 *  (0.25 → "0.3"), the reference renders "0.2"; a different timestamp
 *  string is a different token sequence. */
export function pyFixed1(x: number): string {
  const scaled = x * 10;
  const floor = Math.floor(scaled);
  const diff = scaled - floor;
  let n: number;
  if (diff > 0.5) n = floor + 1;
  else if (diff < 0.5) n = floor;
  else n = floor % 2 === 0 ? floor : floor + 1;
  return (n / 10).toFixed(1);
}

/** Python's builtin round — HALF-TO-EVEN, unlike JS Math.round (half-up).
 *  smart_resize divides integer dims by factor 32, which lands on exact .5
 *  for heights like 80 (2.5): the reference rounds DOWN to the even 2 where
 *  Math.round gives 3 — a different grid and silently different tokens. */
export function roundHalfEven(x: number): number {
  const floor = Math.floor(x);
  const diff = x - floor;
  if (diff > 0.5) return floor + 1;
  if (diff < 0.5) return floor;
  return floor % 2 === 0 ? floor : floor + 1;
}

/** HF qwen2_vl smart_resize (image variant): round to multiples of `factor`,
 *  then scale into [minPixels, maxPixels] preserving aspect. */
export function smartResize(
  height: number,
  width: number,
  factor = QWEN3VL_PATCH_SIZE * QWEN3VL_MERGE_SIZE,
  minPixels = QWEN3VL_MIN_PIXELS,
  maxPixels = QWEN3VL_MAX_PIXELS,
): [number, number] {
  if (Math.max(height, width) / Math.min(height, width) > 200)
    throw new Error(
      `absolute aspect ratio must be smaller than 200, got ` +
      `${Math.max(height, width) / Math.min(height, width)}`,
    );
  let hBar = roundHalfEven(height / factor) * factor;
  let wBar = roundHalfEven(width / factor) * factor;
  if (hBar * wBar > maxPixels) {
    const beta = Math.sqrt((height * width) / maxPixels);
    hBar = Math.max(factor, Math.floor(height / beta / factor) * factor);
    wBar = Math.max(factor, Math.floor(width / beta / factor) * factor);
  } else if (hBar * wBar < minPixels) {
    const beta = Math.sqrt(minPixels / (height * width));
    hBar = Math.ceil((height * beta) / factor) * factor;
    wBar = Math.ceil((width * beta) / factor) * factor;
  }
  return [hBar, wBar];
}

// --- PIL-exact uint8 bicubic (Pillow Resample.c, 8bpc path) ---------------
// The reference pipeline roundtrips resize through PIL's 8-bit resampler:
// int32 fixed-point coefficients at PRECISION_BITS=22, a QUANTIZED uint8
// intermediate between the horizontal and vertical passes, and PIL's exact
// window bounds ((int)(center ± support + 0.5)). The float resizeBicubic in
// preprocess.ts (gemma's float-reference port) differs by ±1 uint8 count —
// this emulation is bit-exact instead (gated vs the oracle pixel grid).

const PIL_PRECISION_BITS = 32 - 8 - 2; // 22

function pilBicubicFilter(x: number): number {
  const a = -0.5;
  x = Math.abs(x);
  if (x < 1) return ((a + 2) * x - (a + 3)) * x * x + 1;
  if (x < 2) return (((x - 5) * x + 8) * x - 4) * a;
  return 0;
}

interface PilCoeffs {
  bounds: Int32Array; // [outSize × 2]: (xmin, count)
  kk: Int32Array; // [outSize × ksize] fixed-point (1<<22-scaled) weights
  ksize: number;
}

function pilPrecomputeCoeffs(inSize: number, outSize: number): PilCoeffs {
  const SUPPORT = 2.0;
  const scale = inSize / outSize;
  const filterscale = Math.max(scale, 1.0);
  const support = SUPPORT * filterscale;
  const ksize = Math.ceil(support) * 2 + 1;
  const bounds = new Int32Array(outSize * 2);
  const kk = new Int32Array(outSize * ksize);
  const ss = 1.0 / filterscale;
  for (let xx = 0; xx < outSize; xx++) {
    const center = (xx + 0.5) * scale;
    let xmin = Math.trunc(center - support + 0.5);
    if (xmin < 0) xmin = 0;
    let xmax = Math.trunc(center + support + 0.5);
    if (xmax > inSize) xmax = inSize;
    const count = xmax - xmin;
    const w = new Float64Array(count);
    let sum = 0;
    for (let x = 0; x < count; x++) {
      w[x] = pilBicubicFilter((x + xmin - center + 0.5) * ss);
      sum += w[x]!;
    }
    for (let x = 0; x < count; x++) {
      const v = sum !== 0 ? w[x]! / sum : w[x]!;
      // normalize_coeffs_8bpc: round-half-away via ±0.5 then C truncation.
      const scaled = v * (1 << PIL_PRECISION_BITS);
      kk[xx * ksize + x] = Math.trunc(scaled < 0 ? scaled - 0.5 : scaled + 0.5);
    }
    bounds[xx * 2] = xmin;
    bounds[xx * 2 + 1] = count;
  }
  return { bounds, kk, ksize };
}

function pilClip8(v: number): number {
  const shifted = Math.floor(v / (1 << PIL_PRECISION_BITS));
  return shifted < 0 ? 0 : shifted > 255 ? 255 : shifted;
}

/** PIL Image.resize(..., BICUBIC) on uint8 RGB — bit-exact 8bpc emulation. */
export function pilResizeBicubic(img: RGBImage, outW: number, outH: number): RGBImage {
  const { width: inW, height: inH } = img;
  let data = img.data;
  let curW = inW;
  const ROUND = 1 << (PIL_PRECISION_BITS - 1);
  if (outW !== inW) {
    const { bounds, kk, ksize } = pilPrecomputeCoeffs(inW, outW);
    const tmp = new Uint8Array(inH * outW * 3);
    for (let y = 0; y < inH; y++) {
      for (let x = 0; x < outW; x++) {
        const xmin = bounds[x * 2]!;
        const count = bounds[x * 2 + 1]!;
        let r = ROUND, g = ROUND, b = ROUND;
        for (let k = 0; k < count; k++) {
          const w = kk[x * ksize + k]!;
          const src = (y * inW + xmin + k) * 3;
          r += data[src]! * w;
          g += data[src + 1]! * w;
          b += data[src + 2]! * w;
        }
        const dst = (y * outW + x) * 3;
        tmp[dst] = pilClip8(r);
        tmp[dst + 1] = pilClip8(g);
        tmp[dst + 2] = pilClip8(b);
      }
    }
    data = tmp;
    curW = outW;
  }
  if (outH !== inH) {
    const { bounds, kk, ksize } = pilPrecomputeCoeffs(inH, outH);
    const out = new Uint8Array(outH * curW * 3);
    for (let y = 0; y < outH; y++) {
      const ymin = bounds[y * 2]!;
      const count = bounds[y * 2 + 1]!;
      for (let x = 0; x < curW; x++) {
        let r = ROUND, g = ROUND, b = ROUND;
        for (let k = 0; k < count; k++) {
          const w = kk[y * ksize + k]!;
          const src = ((ymin + k) * curW + x) * 3;
          r += data[src]! * w;
          g += data[src + 1]! * w;
          b += data[src + 2]! * w;
        }
        const dst = (y * curW + x) * 3;
        out[dst] = pilClip8(r);
        out[dst + 1] = pilClip8(g);
        out[dst + 2] = pilClip8(b);
      }
    }
    data = out;
  }
  return { width: outW, height: outH, data };
}

/** Patchify one normalized frame (f32 CHW logical, provided as HWC bytes →
 *  normalized on the fly) into merge-block-major rows. */
export function patchifyImage(img: RGBImage): Qwen3VLPreprocessed {
  const ps = QWEN3VL_PATCH_SIZE;
  const tps = QWEN3VL_TEMPORAL_PATCH_SIZE;
  const ms = QWEN3VL_MERGE_SIZE;
  const C = 3;
  const { width: W, height: H, data } = img;
  if (H % (ps * ms) !== 0 || W % (ps * ms) !== 0)
    throw new Error(`patchify expects dims % ${ps * ms} == 0, got ${W}x${H}`);
  const gridH = H / ps;
  const gridW = W / ps;
  const rows = gridH * gridW;
  const cols = C * tps * ps * ps;
  const out = new Float32Array(rows * cols);
  // Normalize with the reference's exact f32 op sequence — x*(1/255), then
  // (x-0.5)/0.5 — NOT the algebraic x/127.5-1, which rounds differently in
  // f32 (a flat 1.19e-7 max delta on the unresized gate before this).
  const RESCALE = Math.fround(1 / 255);
  const norm = new Float32Array(256);
  for (let i = 0; i < 256; i++)
    norm[i] = Math.fround((Math.fround(i * RESCALE) - 0.5) / 0.5);
  const hBlocks = gridH / ms;
  const wBlocks = gridW / ms;
  let r = 0;
  for (let h1 = 0; h1 < hBlocks; h1++) {
    for (let w1 = 0; w1 < wBlocks; w1++) {
      for (let mh = 0; mh < ms; mh++) {
        for (let mw = 0; mw < ms; mw++) {
          const hPatch = h1 * ms + mh;
          const wPatch = w1 * ms + mw;
          const base = r * cols;
          for (let c = 0; c < C; c++) {
            for (let tp = 0; tp < tps; tp++) {
              // Images: the single frame is duplicated across tps.
              for (let py = 0; py < ps; py++) {
                const y = hPatch * ps + py;
                const rowOff = (y * W + wPatch * ps) * 3 + c;
                const dst = base + ((c * tps + tp) * ps + py) * ps;
                for (let px = 0; px < ps; px++) {
                  out[dst + px] = norm[data[rowOff + px * 3]!]!;
                }
              }
            }
          }
          r++;
        }
      }
    }
  }
  return {
    pixelValues: out,
    rows,
    cols,
    gridThw: [1, gridH, gridW],
    imageTokens: (gridH / ms) * (gridW / ms),
  };
}

/** Full image pipeline: decode → smart_resize (skipped when already sized) →
 *  patchify. */
export async function preprocessQwen3VLImage(
  bytes: Uint8Array,
): Promise<Qwen3VLPreprocessed> {
  const img = await decodeImage(bytes);
  const [h, w] = smartResize(img.height, img.width);
  const sized = h === img.height && w === img.width
    ? img
    : pilResizeBicubic(img, w, h);
  return patchifyImage(sized);
}

// --- video (PLAN 14w) ------------------------------------------------------

/** Qwen3VLVideoProcessor class defaults (frame-count-aware budget). */
export const QWEN3VL_VIDEO_MIN_PIXELS = 128 * 32 * 32;
export const QWEN3VL_VIDEO_MAX_PIXELS = 32 * 32 * 768;

/** HF smart_resize, VIDEO variant: the token budget counts the (padded)
 *  temporal extent — t_bar·h_bar·w_bar against min/max pixels. */
export function smartResizeVideo(
  numFrames: number, height: number, width: number,
  temporalFactor = QWEN3VL_TEMPORAL_PATCH_SIZE,
  factor = QWEN3VL_PATCH_SIZE * QWEN3VL_MERGE_SIZE,
  minPixels = QWEN3VL_VIDEO_MIN_PIXELS,
  maxPixels = QWEN3VL_VIDEO_MAX_PIXELS,
): [number, number] {
  if (height < factor || width < factor)
    throw new Error(`height:${height} or width:${width} must be larger than factor:${factor}`);
  if (Math.max(height, width) / Math.min(height, width) > 200)
    throw new Error(
      `absolute aspect ratio must be smaller than 200, got ` +
      `${Math.max(height, width) / Math.min(height, width)}`,
    );
  let hBar = roundHalfEven(height / factor) * factor;
  let wBar = roundHalfEven(width / factor) * factor;
  const tBar = Math.ceil(numFrames / temporalFactor) * temporalFactor;
  if (tBar * hBar * wBar > maxPixels) {
    const beta = Math.sqrt((numFrames * height * width) / maxPixels);
    hBar = Math.max(factor, Math.floor(height / beta / factor) * factor);
    wBar = Math.max(factor, Math.floor(width / beta / factor) * factor);
  } else if (tBar * hBar * wBar < minPixels) {
    const beta = Math.sqrt(minPixels / (numFrames * height * width));
    hBar = Math.ceil((height * beta) / factor) * factor;
    wBar = Math.ceil((width * beta) / factor) * factor;
  }
  return [hBar, wBar];
}

/** Video pipeline on ALREADY-DECODED frames (uniform size): T-aware
 *  smart_resize per frame → normalize → pad to even T by repeating the last
 *  frame → patchify with REAL temporal pairs (element order (c, tp, py, px)
 *  reads frame t·2+tp). File decoding is the AVFoundation sidecar's job. */
export function preprocessQwen3VLVideoFrames(
  frames: RGBImage[],
  opts: { sampleFps?: number } = {},
): Qwen3VLPreprocessed {
  if (frames.length === 0) throw new Error("video needs at least one frame");
  // Frame timestamps: the sidecar samples at exact times k/fps, so frame k
  // sits at k/fps seconds; padding repeats the last frame's time (the
  // reference extends frames_indices with the last index). Group timestamp
  // = pair average (transformers _calculate_timestamps).
  const fps = opts.sampleFps ?? 2;
  const { height: H0, width: W0 } = frames[0]!;
  for (const f of frames)
    if (f.height !== H0 || f.width !== W0)
      throw new Error("video frames must share one size");
  const [h, w] = smartResizeVideo(frames.length, H0, W0);
  const sized = frames.map((f) =>
    h === f.height && w === f.width ? f : pilResizeBicubic(f, w, h));
  // Pad to a multiple of the temporal patch size (repeat the last frame).
  const tps = QWEN3VL_TEMPORAL_PATCH_SIZE;
  const frameTimes = frames.map((_, k) => k / fps);
  while (sized.length % tps !== 0) {
    sized.push(sized[sized.length - 1]!);
    frameTimes.push(frameTimes[frameTimes.length - 1]!);
  }
  const groupTimestamps: number[] = [];
  for (let i = 0; i < frameTimes.length; i += tps)
    groupTimestamps.push((frameTimes[i]! + frameTimes[i + tps - 1]!) / 2);

  const ps = QWEN3VL_PATCH_SIZE;
  const ms = QWEN3VL_MERGE_SIZE;
  const C = 3;
  const gridT = sized.length / tps;
  const gridH = h / ps;
  const gridW = w / ps;
  const rows = gridT * gridH * gridW;
  const cols = C * tps * ps * ps;
  const out = new Float32Array(rows * cols);
  const RESCALE = Math.fround(1 / 255);
  const norm = new Float32Array(256);
  for (let i = 0; i < 256; i++)
    norm[i] = Math.fround((Math.fround(i * RESCALE) - 0.5) / 0.5);
  const hBlocks = gridH / ms;
  const wBlocks = gridW / ms;
  let r = 0;
  for (let t = 0; t < gridT; t++) {
    for (let h1 = 0; h1 < hBlocks; h1++) {
      for (let w1 = 0; w1 < wBlocks; w1++) {
        for (let mh = 0; mh < ms; mh++) {
          for (let mw = 0; mw < ms; mw++) {
            const hPatch = h1 * ms + mh;
            const wPatch = w1 * ms + mw;
            const base = r * cols;
            for (let c = 0; c < C; c++) {
              for (let tp = 0; tp < tps; tp++) {
                const frame = sized[t * tps + tp]!.data;
                for (let py = 0; py < ps; py++) {
                  const y = hPatch * ps + py;
                  const rowOff = (y * w + wPatch * ps) * 3 + c;
                  const dst = base + ((c * tps + tp) * ps + py) * ps;
                  for (let px = 0; px < ps; px++)
                    out[dst + px] = norm[frame[rowOff + px * 3]!]!;
                }
              }
            }
            r++;
          }
        }
      }
    }
  }
  return {
    pixelValues: out,
    rows,
    cols,
    gridThw: [gridT, gridH, gridW],
    imageTokens: gridT * (gridH / ms) * (gridW / ms),
    groupTimestamps,
  };
}
