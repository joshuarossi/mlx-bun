// DiffusionGemma vision tower — DEDICATED, parity-exact port of optiq's
// gemma4 `VisionModel` (optiq/vlm/_mlxvlm/models/gemma4/vision.py) at the
// DiffusionGemma geometry (hidden 1152, head_dim 72, 16 heads, 27 layers,
// position_embedding_size 10240, standardize ON). This is its OWN module, not a
// reuse of the e4b SigLIP path — the two are separate models with separate
// towers (e4b ships a bf16 optiq_vision.safetensors sidecar; DiffusionGemma's
// vision is inline-quantized in the main shards). Ported op-for-op so it is
// bit-exact to the optiq reference.
//
// Forward (reference VisionModel.__call__):
//   pixels [1,3,H,W] → patchify (reshape/transpose, 2*(x-0.5)) → input_proj
//     + 2D position embedding (gather table[0,x]+table[1,y]) → PAD to
//     max_patches=2520 (zeros) → 27× transformer blocks (manual-f32 q/k/v RMS,
//     2D multidimensional RoPE, bidirectional -1e4 mask, scale=1.0, GeGLU) →
//     position-grouped 3×3 avg-pool to 280 (×√hidden) → trim to the real soft
//     tokens → standardize (h - std_bias)*std_scale → MultimodalEmbedder
//     (RMSNormNoScale → projection 1152→2816).
// Output = `getImageFeatures`: [1, softTokens, textHidden], scattered AS-IS into
// the prompt embeddings (NO /embed_scale — the diffusion merge adds it once via
// embed_tokens*embed_scale).
//
// The vision linears are 4-bit quantized inline; we run them as QuantizedLinear
// (== the reference's nn.quantize'd modules), not dequant+matmul.

import type { ModelConfig } from "../config";
import type { Weights } from "../weights";
import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { disposing, QuantizedLinear, RMSNorm } from "../model/gemma4-base";
import { parseSiglipConfig, type SiglipVisionConfig } from "./siglip";
import { decodeImage, resizeBicubic } from "./preprocess";

const VP = "model.encoder.vision_tower.";

/** Expand each `<|image|>` placeholder id into `boi + image*softCount + eoi`,
 *  matching optiq's `_build_image_inputs`. Returns the spliced ids (the
 *  diffusion engine's encoder prefills the merged vision features at the
 *  contiguous image run). */
export function spliceImageTokens(
  ids: number[],
  softCounts: number[],
  tokenIds: { image: number; boi: number; eoi: number },
): number[] {
  const out: number[] = [];
  let k = 0;
  for (const id of ids) {
    if (id === tokenIds.image) {
      out.push(tokenIds.boi);
      const n = softCounts[k] ?? softCounts[softCounts.length - 1] ?? 0;
      for (let i = 0; i < n; i++) out.push(tokenIds.image);
      out.push(tokenIds.eoi);
      k++;
    } else {
      out.push(id);
    }
  }
  return out;
}

/** A vision linear that is EITHER 4-bit quantized (q/k/v/o, gate/up, input_proj,
 *  embedding_projection) OR plain bf16 (down_proj is full-precision). Matches the
 *  reference, where nn.quantize skips the unquantized `down_proj`. */
class VisionLinear {
  private constructor(
    readonly q: QuantizedLinear | null,
    readonly w: MlxArray | null,
  ) {}
  static load(weights: Weights, config: ModelConfig, path: string): VisionLinear {
    if (weights.has(`${path}.scales`))
      return new VisionLinear(QuantizedLinear.load(weights, path, config), null);
    return new VisionLinear(null, weights.tensor(`${path}.weight`));
  }
  /** The dtype of the underlying weight tensor — uint32 for a quantized linear
   *  (the packed weight), the float dtype for a plain one. The reference
   *  patch-embedder casts its input to THIS dtype (a uint32 truncation for the
   *  quantized diffusion input_proj — see #patchify). */
  get weightDtype(): Dtype {
    return (this.q ? this.q.w : this.w!).dtype;
  }
  forward(x: MlxArray): MlxArray {
    if (this.q) return this.q.forward(x);
    const xc = x.astype(this.w!.dtype);
    const wT = ops.transposeAxes(this.w!, [1, 0]);
    const out = ops.matmul(xc, wT);
    xc.dispose();
    wT.dispose();
    return out;
  }
}

/** Manual fp32 RMS norm matching the reference VisionRMSNorm / NoScale:
 *  x_f32 * rsqrt(mean(x²)+eps) [* weight_f32], cast back. (NOT the fused kernel
 *  — the reference q/k/v norms are decomposed f32.) */
function manualRms(x: MlxArray, weight: MlxArray | null, eps: number): MlxArray {
  const xf = x.astype(Dtype.float32);
  const sq = ops.mul(xf, xf);
  const varr = ops.meanAxis(sq, -1, true);
  sq.dispose();
  const epsArr = ops.scalarLike(eps, varr);
  const denom = ops.add(varr, epsArr);
  varr.dispose();
  epsArr.dispose();
  const rs = ops.rsqrt(denom);
  denom.dispose();
  let normed = ops.mul(xf, rs);
  xf.dispose();
  rs.dispose();
  if (weight) {
    const wf = weight.astype(Dtype.float32);
    normed = disposing(normed, ops.mul(normed, wf));
    wf.dispose();
  }
  const out = normed.astype(x.dtype);
  normed.dispose();
  return out;
}

/** Pad the last dim of x up to `target` with zeros (for the fused-SDPA head_dim
 *  padding, reference ensure_fused_sdpa). */
function padLastDim(x: MlxArray, target: number): MlxArray {
  const sh = x.shape;
  const D = sh[sh.length - 1]!;
  if (D >= target) return x;
  const padShape = [...sh];
  padShape[padShape.length - 1] = target - D;
  const zeros = ops.zeros(padShape, x.dtype);
  const out = ops.concatAxis([x, zeros], -1);
  zeros.dispose();
  return out;
}

/** rotate_half: [-x2, x1]. */
function rotateHalf(x: MlxArray): MlxArray {
  const sh = x.shape;
  const H = sh[sh.length - 1]!;
  const half = H / 2;
  const x1 = x.slice(sh.map((_, i) => (i === sh.length - 1 ? 0 : 0)), sh.map((s, i) => (i === sh.length - 1 ? half : s)));
  const x2 = x.slice(sh.map((s, i) => (i === sh.length - 1 ? half : 0)), [...sh]);
  const negX2 = ops.mulScalar(x2, -1);
  x2.dispose();
  const out = ops.concatAxis([negX2, x1], -1);
  negX2.dispose();
  x1.dispose();
  return out;
}

/** apply_multidimensional_rope: split head_dim into `ndim` parts, rope each
 *  independently with its own spatial position. x: [B, L, N, headDim],
 *  positions: [B, L, 2] (int32). */
function apply2dRope(x: MlxArray, positions: MlxArray, theta: number): MlxArray {
  const sh = x.shape;
  const headDim = sh[sh.length - 1]!;
  const ndim = 2;
  const channelsPerDim = 2 * Math.floor(headDim / (2 * ndim));
  const halfPerDim = Math.floor(channelsPerDim / 2);
  const [B, L] = sh as [number, number, number, number];

  const parts: MlxArray[] = [];
  for (let d = 0; d < ndim; d++) {
    // x_part = x[..., d*cpd : (d+1)*cpd]
    const start = sh.map((_, i) => (i === sh.length - 1 ? d * channelsPerDim : 0));
    const stop = sh.map((s, i) => (i === sh.length - 1 ? (d + 1) * channelsPerDim : s));
    const xPart = x.slice(start, stop);

    const ar = ops.arange(0, halfPerDim, 1, Dtype.float32);
    const freq = ops.mulScalar(ar, 2 / channelsPerDim);
    ar.dispose();
    const base = ops.scalarLike(theta, freq);
    const timescale = ops.pow(base, freq); // [half]
    base.dispose();
    freq.dispose();

    // positions[..., d:d+1] → [B, L, 1] → f32
    const posD = positions.slice([0, 0, d], [B, L, d + 1]);
    const posF = posD.astype(Dtype.float32);
    posD.dispose();
    // sinusoid = posF / timescale → [B, L, half]
    const sinus = ops.div(posF, timescale);
    posF.dispose();
    timescale.dispose();
    const cosd = ops.cos(sinus);
    const sind = ops.sin(sinus);
    sinus.dispose();
    let cosD = ops.concatAxis([cosd, cosd], -1).astype(x.dtype); // [B,L,cpd]
    let sinD = ops.concatAxis([sind, sind], -1).astype(x.dtype);
    cosd.dispose();
    sind.dispose();
    cosD = disposing(cosD, ops.expandDims(cosD, 2)); // [B,L,1,cpd]
    sinD = disposing(sinD, ops.expandDims(sinD, 2));

    const xc = ops.mul(xPart, cosD);
    const rh = rotateHalf(xPart);
    xPart.dispose();
    const rs = ops.mul(rh, sinD);
    rh.dispose();
    cosD.dispose();
    sinD.dispose();
    const yPart = ops.add(xc, rs);
    xc.dispose();
    rs.dispose();
    parts.push(yPart);
  }
  const out = ops.concatAxis(parts, -1);
  for (const p of parts) p.dispose();
  return out;
}

class DiffVisionAttention {
  readonly qProj: VisionLinear;
  readonly kProj: VisionLinear;
  readonly vProj: VisionLinear;
  readonly oProj: VisionLinear;
  readonly qNorm: MlxArray;
  readonly kNorm: MlxArray;
  readonly nHeads: number;
  readonly nKvHeads: number;
  readonly headDim: number;
  readonly theta: number;
  readonly eps: number;
  constructor(w: Weights, config: ModelConfig, cfg: SiglipVisionConfig, prefix: string) {
    this.qProj = VisionLinear.load(w, config, `${prefix}.q_proj.linear`);
    this.kProj = VisionLinear.load(w, config, `${prefix}.k_proj.linear`);
    this.vProj = VisionLinear.load(w, config, `${prefix}.v_proj.linear`);
    this.oProj = VisionLinear.load(w, config, `${prefix}.o_proj.linear`);
    this.qNorm = w.tensor(`${prefix}.q_norm.weight`);
    this.kNorm = w.tensor(`${prefix}.k_norm.weight`);
    this.nHeads = cfg.numHeads;
    this.nKvHeads = cfg.numKvHeads;
    this.headDim = cfg.headDim;
    this.theta = cfg.ropeTheta;
    this.eps = cfg.rmsNormEps;
  }
  forward(x: MlxArray, positions: MlxArray, mask: MlxArray): MlxArray {
    const [B, L] = x.shape as [number, number, number];
    const qf = this.qProj.forward(x);
    let q = ops.reshape(qf, [B, L, this.nHeads, this.headDim]);
    qf.dispose();
    const kf = this.kProj.forward(x);
    let k = ops.reshape(kf, [B, L, this.nKvHeads, this.headDim]);
    kf.dispose();
    const vf = this.vProj.forward(x);
    let v = ops.reshape(vf, [B, L, this.nKvHeads, this.headDim]);
    vf.dispose();

    q = disposing(q, manualRms(q, this.qNorm, this.eps));
    k = disposing(k, manualRms(k, this.kNorm, this.eps));
    v = disposing(v, manualRms(v, null, this.eps));

    q = disposing(q, apply2dRope(q, positions, this.theta));
    k = disposing(k, apply2dRope(k, positions, this.theta));

    q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));
    k = disposing(k, ops.transposeAxes(k, [0, 2, 1, 3]));
    v = disposing(v, ops.transposeAxes(v, [0, 2, 1, 3]));

    // Reference ensure_fused_sdpa: head_dim 72 isn't a fused-SDPA size, so it
    // PADS q/k/v to 80 (zeros, no effect on scores — the extra dims are 0),
    // runs the fused kernel, and slices back to 72. Replicate exactly: mlx's
    // SDPA path/numerics differ for an unpadded 72 vs the padded-80 fused path.
    const D = this.headDim;
    const target = D <= 64 ? 64 : D <= 80 ? 80 : D <= 128 ? 128 : D;
    if (target !== D) {
      q = disposing(q, padLastDim(q, target));
      k = disposing(k, padLastDim(k, target));
      v = disposing(v, padLastDim(v, target));
    }
    let attn = ops.sdpa(q, k, v, 1.0, "array", mask);
    q.dispose();
    k.dispose();
    v.dispose();
    if (target !== D) {
      const sh = attn.shape;
      attn = disposing(attn, attn.slice(sh.map(() => 0), sh.map((s, i) => (i === sh.length - 1 ? D : s))));
    }
    let o = ops.transposeAxes(attn, [0, 2, 1, 3]);
    attn.dispose();
    o = disposing(o, ops.reshape(o, [B, L, this.nHeads * this.headDim]));
    const out = this.oProj.forward(o);
    o.dispose();
    return out;
  }
}

class DiffVisionMLP {
  readonly gate: VisionLinear;
  readonly up: VisionLinear;
  readonly down: VisionLinear;
  constructor(w: Weights, config: ModelConfig, prefix: string) {
    this.gate = VisionLinear.load(w, config, `${prefix}.gate_proj.linear`);
    this.up = VisionLinear.load(w, config, `${prefix}.up_proj.linear`);
    this.down = VisionLinear.load(w, config, `${prefix}.down_proj.linear`);
  }
  forward(x: MlxArray): MlxArray {
    const g = this.gate.forward(x);
    const act = ops.geluApprox(g);
    g.dispose();
    const u = this.up.forward(x);
    const m = ops.mul(act, u);
    act.dispose();
    u.dispose();
    const out = this.down.forward(m);
    m.dispose();
    return out;
  }
}

class DiffVisionBlock {
  readonly attn: DiffVisionAttention;
  readonly mlp: DiffVisionMLP;
  readonly inputNorm: RMSNorm;
  readonly postAttnNorm: RMSNorm;
  readonly preFfNorm: RMSNorm;
  readonly postFfNorm: RMSNorm;
  constructor(w: Weights, config: ModelConfig, cfg: SiglipVisionConfig, prefix: string) {
    this.attn = new DiffVisionAttention(w, config, cfg, `${prefix}.self_attn`);
    this.mlp = new DiffVisionMLP(w, config, `${prefix}.mlp`);
    const norm = (n: string) => new RMSNorm(w.tensor(`${prefix}.${n}.weight`), cfg.rmsNormEps);
    this.inputNorm = norm("input_layernorm");
    this.postAttnNorm = norm("post_attention_layernorm");
    this.preFfNorm = norm("pre_feedforward_layernorm");
    this.postFfNorm = norm("post_feedforward_layernorm");
  }
  forward(x: MlxArray, positions: MlxArray, mask: MlxArray): MlxArray {
    const normed = this.inputNorm.forward(x);
    let attnOut = this.attn.forward(normed, positions, mask);
    normed.dispose();
    attnOut = disposing(attnOut, this.postAttnNorm.forward(attnOut));
    const h = ops.add(x, attnOut);
    attnOut.dispose();
    const normedH = this.preFfNorm.forward(h);
    let ffw = this.mlp.forward(normedH);
    normedH.dispose();
    ffw = disposing(ffw, this.postFfNorm.forward(ffw));
    const out = ops.add(h, ffw);
    h.dispose();
    ffw.dispose();
    return out;
  }
}

export class DiffusionVisionTower {
  readonly cfg: SiglipVisionConfig;
  readonly inputProj: VisionLinear;
  readonly posTable: MlxArray; // [2, posSize, hidden]
  readonly layers: DiffVisionBlock[];
  readonly stdBias: MlxArray | null;
  readonly stdScale: MlxArray | null;
  readonly embedProj: VisionLinear; // MultimodalEmbedder projection
  readonly embedEps: number;
  readonly maxPatches: number;
  readonly patchSize: number;
  readonly defaultOutputLength: number;
  readonly rootHidden: number;

  constructor(weights: Weights, config: ModelConfig) {
    const raw = (config as unknown as { raw: Record<string, any> }).raw.vision_config;
    const cfg = parseSiglipConfig(raw);
    this.cfg = cfg;
    this.patchSize = cfg.patchSize;
    this.defaultOutputLength = cfg.defaultOutputLength;
    this.maxPatches = cfg.defaultOutputLength * cfg.poolingKernelSize * cfg.poolingKernelSize;
    this.rootHidden = Math.sqrt(cfg.hiddenSize);
    this.embedEps = (raw.rms_norm_eps as number) ?? 1e-6;

    this.inputProj = VisionLinear.load(weights, config, `${VP}patch_embedder.input_proj`);
    this.posTable = weights.tensor(`${VP}patch_embedder.position_embedding_table`);
    this.layers = Array.from(
      { length: cfg.numLayers },
      (_, i) => new DiffVisionBlock(weights, config, cfg, `${VP}encoder.layers.${i}`),
    );
    this.stdBias = cfg.standardize ? weights.tensor(`${VP}std_bias`) : null;
    this.stdScale = cfg.standardize ? weights.tensor(`${VP}std_scale`) : null;
    this.embedProj = VisionLinear.load(weights, config, "model.encoder.embed_vision.embedding_projection");
  }

  /** Decode + aspect-preserving resize (multiples of pooling·patch=48, within the
   *  max_patches budget) + rescale 1/255 + channel-first. Mirrors optiq's
   *  gemma4 `preprocess_images` (BICUBIC, do_rescale, do_normalize=False).
   *  Returns pixel_values [1,3,H,W] f32 and the per-image soft-token count. */
  async preprocess(bytes: Uint8Array): Promise<{ pixels: MlxArray; softTokens: number }> {
    let img = await decodeImage(bytes);
    const p = this.patchSize;
    const k = this.cfg.poolingKernelSize;
    const sideMult = p * k;
    const targetPx = this.maxPatches * p * p;
    const factor = Math.sqrt(targetPx / (img.height * img.width));
    let th = Math.floor((factor * img.height) / sideMult) * sideMult;
    let tw = Math.floor((factor * img.width) / sideMult) * sideMult;
    const maxSide = Math.floor(this.maxPatches / (k * k)) * sideMult;
    if (th === 0 && tw === 0) {
      th = sideMult;
      tw = sideMult;
    } else if (th === 0) {
      th = sideMult;
      tw = Math.min(Math.floor(img.width / img.height) * sideMult, maxSide);
    } else if (tw === 0) {
      tw = sideMult;
      th = Math.min(Math.floor(img.height / img.width) * sideMult, maxSide);
    }
    if (th !== img.height || tw !== img.width) img = resizeBicubic(img, tw, th);

    const { width: W, height: H, data } = img;
    // HWC uint8 -> CHW f32 / 255
    const chw = new Float32Array(3 * H * W);
    for (let y = 0; y < H; y++)
      for (let x = 0; x < W; x++)
        for (let c = 0; c < 3; c++)
          chw[c * H * W + y * W + x] = data[(y * W + x) * 3 + c]! / 255;
    const pixels = MlxArray.fromFloat32(chw, [1, 3, H, W]);
    const softTokens = Math.floor((Math.floor(H / p) * Math.floor(W / p)) / (k * k));
    return { pixels, softTokens };
  }

  /** Host-side patch positions (x,y) for the real patches + the padding mask,
   *  matching VisionModel._patch_positions_single (meshgrid xy, row-major). */
  #positions(H: number, W: number): { real: Int32Array; numReal: number } {
    const p = this.patchSize;
    const pH = Math.floor(H / p);
    const pW = Math.floor(W / p);
    const numReal = pH * pW;
    const real = new Int32Array(numReal * 2);
    for (let y = 0; y < pH; y++)
      for (let x = 0; x < pW; x++) {
        const L = y * pW + x;
        real[L * 2] = x;
        real[L * 2 + 1] = y;
      }
    return { real, numReal };
  }

  /** patchify: [1,3,H,W] -> [1, numReal, 3*p*p] (order p_row,p_col,C), 2*(x-0.5). */
  #patchify(pixels: MlxArray): MlxArray {
    const [B, C, H, W] = pixels.shape as [number, number, number, number];
    const p = this.patchSize;
    const pH = Math.floor(H / p);
    const pW = Math.floor(W / p);
    let t = ops.reshape(pixels, [B, C, pH, p, pW, p]);
    t = disposing(t, ops.transposeAxes(t, [0, 2, 4, 3, 5, 1])); // [B,pH,pW,p,p,C]
    t = disposing(t, ops.reshape(t, [B, pH * pW, C * p * p]));
    // 2*(x - 0.5)
    const half = ops.scalarLike(0.5, t);
    t = disposing(t, ops.sub(t, half));
    half.dispose();
    t = disposing(t, ops.mulScalar(t, 2));
    // Reference quirk: `patches.astype(self.input_proj.weight.dtype)`. The
    // DiffusionGemma input_proj is QUANTIZED, so weight.dtype is uint32 and this
    // TRUNCATES the patches to integers (mostly 0) before the matmul. The model
    // was trained with this, so replicate it exactly (e4b's bf16 input_proj made
    // it a no-op there). Back to a float the quantized matmul consumes.
    t = disposing(t, t.astype(this.inputProj.weightDtype));
    t = disposing(t, t.astype(Dtype.bfloat16));
    return t;
  }

  /** Full tower forward over channel-first pixel_values [1,3,H,W] -> standardized
   *  pooled hidden [1, numRealSoft, hidden] (BEFORE the MultimodalEmbedder). */
  visionTower(pixels: MlxArray, dbg?: (n: string, a: MlxArray) => void): MlxArray {
    const [, , H, W] = pixels.shape as [number, number, number, number];
    const { real, numReal } = this.#positions(H, W);
    const k = this.cfg.poolingKernelSize;
    const p = this.patchSize;
    const pW = Math.floor(W / p);
    const pH = Math.floor(H / p);

    // --- patch embed (real patches only) ---
    const patches = this.#patchify(pixels);
    let embeds = this.inputProj.forward(patches); // [1, numReal, hidden]
    patches.dispose();

    // + 2D position embedding: table[0, x] + table[1, y]
    const hidden = this.cfg.hiddenSize;
    const posSize = this.cfg.positionEmbeddingSize;
    const pxIdx = new Int32Array(numReal);
    const pyIdx = new Int32Array(numReal);
    for (let i = 0; i < numReal; i++) {
      pxIdx[i] = real[i * 2]!;
      pyIdx[i] = real[i * 2 + 1]!;
    }
    const plane0 = this.posTable.slice([0, 0, 0], [1, posSize, hidden]);
    const t0r = ops.reshape(plane0, [posSize, hidden]);
    plane0.dispose();
    const plane1 = this.posTable.slice([1, 0, 0], [2, posSize, hidden]);
    const t1r = ops.reshape(plane1, [posSize, hidden]);
    plane1.dispose();
    const pxArr = MlxArray.fromInt32(pxIdx, [numReal]);
    const pyArr = MlxArray.fromInt32(pyIdx, [numReal]);
    const e0 = ops.takeAxis(t0r, pxArr, 0);
    const e1 = ops.takeAxis(t1r, pyArr, 0);
    t0r.dispose();
    t1r.dispose();
    pxArr.dispose();
    pyArr.dispose();
    let pos = ops.add(e0, e1);
    e0.dispose();
    e1.dispose();
    pos = disposing(pos, ops.reshape(pos, [1, numReal, hidden]));
    pos = disposing(pos, pos.astype(embeds.dtype));
    embeds = disposing(embeds, ops.add(embeds, pos)); // [1, numReal, hidden]
    pos.dispose();
    dbg?.("patchembed", embeds);

    // --- pad to maxPatches (zeros) ---
    const numPad = this.maxPatches - numReal;
    if (numPad > 0) {
      const padE = ops.zeros([1, numPad, hidden], embeds.dtype);
      embeds = disposing(embeds, ops.concatAxis([embeds, padE], 1));
      padE.dispose();
    }

    // --- positions array [1, maxPatches, 2] (real then -1 pad) for RoPE ---
    const posInts = new Int32Array(this.maxPatches * 2).fill(-1);
    posInts.set(real, 0);
    const positions = MlxArray.fromInt32(posInts, [1, this.maxPatches, 2]);

    // --- bidirectional -1e4 mask [1,1,maxPatches,maxPatches] ---
    // valid_i AND valid_j → 0 else -1e4. valid = patch index < numReal.
    const validInts = new Float32Array(this.maxPatches);
    for (let i = 0; i < this.maxPatches; i++) validInts[i] = i < numReal ? 1 : 0;
    const validRow = MlxArray.fromFloat32(validInts, [1, 1, 1, this.maxPatches]); // keys
    const validCol = MlxArray.fromFloat32(validInts, [1, 1, this.maxPatches, 1]); // queries
    const both = ops.mul(validRow, validCol); // [1,1,mp,mp] 1 if both valid
    validRow.dispose();
    validCol.dispose();
    // mask_fill: where(both, 0, -1e4) = (both-1)*1e4
    const oneArr = ops.scalarLike(1, both);
    const bm1 = ops.sub(both, oneArr); // both-1: 0 or -1
    both.dispose();
    oneArr.dispose();
    let mask = ops.mulScalar(bm1, 1e4); // 0 or -1e4
    bm1.dispose();
    mask = disposing(mask, mask.astype(embeds.dtype));

    // --- transformer ---
    let h = embeds;
    for (let li = 0; li < this.layers.length; li++) {
      const next = this.layers[li]!.forward(h, positions, mask);
      h.dispose();
      h = next;
      if (li < 3) dbg?.(`vlayer${li}`, h);
    }
    positions.dispose();
    mask.dispose();
    dbg?.("transformer", h);

    // --- pooler: zero padding, position-grouped 3x3 avg-pool to 280, ×√hidden ---
    // zero padding rows
    if (numPad > 0) {
      const keep = new Float32Array(this.maxPatches);
      for (let i = 0; i < this.maxPatches; i++) keep[i] = i < numReal ? 1 : 0;
      const keepArr = MlxArray.fromFloat32(keep, [1, this.maxPatches, 1]).astype(h.dtype);
      h = disposing(h, ops.mul(h, keepArr));
      keepArr.dispose();
    }
    // pooling matrix [maxPatches, length] : kernel_idx = (x//k) + (pW_blocks)*(y//k)
    // pW_blocks = (max_x+1)//k where max_x = pW-1 → pW//k... reference: (max_x//k)
    // where max_x = max(clamped x)+1 = pW. So blocksPerRow = pW // k.
    const length = this.defaultOutputLength;
    const blocksPerRow = Math.floor(pW / k);
    const poolW = new Float32Array(this.maxPatches * length);
    const invK2 = 1 / (k * k);
    for (let i = 0; i < this.maxPatches; i++) {
      // clamped positions: pad (-1) → 0
      const x = i < numReal ? real[i * 2]! : 0;
      const y = i < numReal ? real[i * 2 + 1]! : 0;
      const idx = Math.floor(x / k) + blocksPerRow * Math.floor(y / k);
      if (idx < length) poolW[i * length + idx] = invK2;
    }
    const hf = h.astype(Dtype.float32);
    h.dispose();
    const poolWArr = MlxArray.fromFloat32(poolW, [this.maxPatches, length]);
    // output[l,d] = sum_L poolW[L,l] * hf[L,d] = poolW.T @ hf
    const hf2 = ops.reshape(hf, [this.maxPatches, hidden]);
    hf.dispose();
    const poolWT = ops.transposeAxes(poolWArr, [1, 0]); // [length, maxPatches]
    poolWArr.dispose();
    let pooled = ops.matmul(poolWT, hf2); // [length, hidden] f32
    poolWT.dispose();
    hf2.dispose();
    // ×√hidden, back to bf16, reshape [1, length, hidden]
    const dtype = this.posTable.dtype;
    pooled = disposing(pooled, pooled.astype(dtype));
    pooled = disposing(pooled, ops.mulScalar(pooled, this.rootHidden));
    pooled = disposing(pooled, ops.reshape(pooled, [1, length, hidden]));

    // --- trim to the real soft tokens (kernel_idx < numRealSoft) ---
    const softW = blocksPerRow;
    const softH = Math.floor(pH / k);
    const numSoft = softW * softH;
    const trimmed = pooled.slice([0, 0, 0], [1, numSoft, hidden]);
    pooled.dispose();
    let out = trimmed;
    dbg?.("pooled", out);

    // --- standardize: (h - std_bias) * std_scale ---
    if (this.stdBias && this.stdScale) {
      const sb = this.stdBias.astype(out.dtype);
      const ss = this.stdScale.astype(out.dtype);
      const sub = ops.sub(out, sb);
      out.dispose();
      sb.dispose();
      out = ops.mul(sub, ss);
      sub.dispose();
      ss.dispose();
    }
    dbg?.("toweroutput", out);
    return out;
  }

  /** get_image_features = embed_vision(vision_tower(pixels)):
   *  MultimodalEmbedder (RMSNormNoScale → projection 1152→2816). NO /embed_scale. */
  getImageFeatures(pixels: MlxArray, dbg?: (n: string, a: MlxArray) => void): MlxArray {
    const tower = this.visionTower(pixels, dbg);
    const normed = manualRms(tower, null, this.embedEps); // RMSNormNoScale
    tower.dispose();
    const out = this.embedProj.forward(normed);
    normed.dispose();
    return out;
  }
}
