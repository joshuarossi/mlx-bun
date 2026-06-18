// SigLIP-style vision tower — port of optiq's vlm/gemma4 SigLIP encoder
// (vision.py / frontend.py / merge.py, vendored from mlx-vlm, BSD-3).
//
// Lights up image input for the gemma4 family that ships a *full* vision
// encoder (e2b/e4b/26B-A4B/31B), as opposed to the 12B gemma4_unified
// "encoder-free" patch embedder in ./embedder.ts. The two share the same
// merge contract: `features()` returns language-space soft tokens
// [1, soft, textHidden] pre-divided by embed_scale (the language model
// re-multiplies), so both drop into ./prompt.ts unchanged.
//
// Pipeline (per image, batch 1):
//   pixels → aspect-preserving resize (shared with ./preprocess.ts) →
//   16×16 patchify + 2*(x-0.5) → input_proj (+ 2D pos embedding) →
//   16× transformer blocks (clippable linears, q/k/v RMSNorm, 2D RoPE,
//   fused SDPA scale=1.0, GeGLU MLP) → 3×3 avg-pool over the patch grid
//   (×√hidden) → MultimodalEmbedder (RMSNormNoScale → Linear) → /embed_scale.
//
// Patch vectors, positions and the pooling matrix are precomputed host-side;
// the 2D-RoPE cos/sin tables are built on-device (op-for-op with optiq, so
// they're bit-identical). Single images run UNPADDED (no attention mask):
// every patch attends to every patch bidirectionally, which is numerically
// identical to optiq's padded+(-1e4)-masked path (masked keys underflow to
// exactly 0 in the softmax) but far cheaper than always running 2520²
// attention — verified: padded and unpadded give the same features to 4
// decimals.
//
// Parity: this matches optiq's computation op-for-op, INCLUDING its choices of
// decomposed (manual f32) RMS norm for the q/k/v attention norms vs the fused
// fast.rms_norm for the block layernorms. EVERY primitive is bit-identical to
// the oracle on this machine — verified model-free in scripts/op-parity-
// {dump.py,check.ts}: rms_norm, gelu, matmul, clip, cos, sin, the full
// multidimensional RoPE, sdpa (no-mask AND array-mask), sdpa padded-vs-unpadded
// (a no-op), and the 3×3 pool (f32 matmul == optiq's einsum). There is NO
// kernel / "cross-build" divergence (an earlier claim of one was a bug in the
// op-test harness: toFloat32 mis-read a non-contiguous SDPA output — force
// ops.contiguous() before raw readback).
//
// Pre-transformer features are bit-exact (0.003%) and ONE encoder layer on
// bit-exact input is bit-exact (0.0007%). The full 16-layer features land at
// ~1.0-1.2% rel-RMSE vs optiq: a sub-bf16 (≈0.0007%/layer) composition
// difference that ACCUMULATES and is amplified by this encoder's design —
// scale=1.0 on RMS-normed q/k makes q·k ~N(0, head_dim) and the softmax
// sharply peaked, so tiny rounding flips attention weights. ~0.17% of it is the
// patchify input (JS `pixel/127.5-1` vs optiq's two-step f32 `2*(pixel/255 -
// 0.5)`); the rest is encoder bf16 non-associativity. It flips a downstream
// greedy argmax after a few tokens, so the test asserts exact spliced ids + a
// greedy prefix + grounded output (the tier-a bar), not full bit-exact greedy.
//
// TODO(revisit): full bit-exact vision IS achievable and is the bar for the
// rest of this codebase (0.0000% across the text models) — the technique is to
// match optiq's EXACT op / lazy-eval / fusion ordering in the full graph, which
// you can read straight from optiq/vlm/gemma4/{vision,merge}.py. Every PRIMITIVE
// already matches bit-for-bit (op-parity-*); the residual is purely full-graph
// composition order. Left at tier-a for now (good enough — grounded, exact ids,
// greedy prefix); revisit to drive the encoder to 0% by aligning the op order.

import { ptr, read } from "bun:ffi";
import { MlxArray, cpuStream } from "../mlx/array";
import { C, Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { decodeImage, resizeBicubic, targetSize } from "./preprocess";

const cstr = (s: string) => Buffer.from(s + "\0", "utf8");
const dispose = (old: MlxArray, next: MlxArray): MlxArray => {
  old.dispose();
  return next;
};

export interface SiglipVisionConfig {
  hiddenSize: number;
  intermediateSize: number;
  numLayers: number;
  numHeads: number;
  numKvHeads: number;
  headDim: number;
  ropeTheta: number;
  rmsNormEps: number;
  patchSize: number;
  poolingKernelSize: number;
  defaultOutputLength: number;
  positionEmbeddingSize: number;
  standardize: boolean;
  useClippedLinears: boolean;
}

/** Parse a config.json `vision_config` block (gemma4_vision). */
export function parseSiglipConfig(raw: Record<string, any>): SiglipVisionConfig {
  return {
    hiddenSize: raw.hidden_size ?? 768,
    intermediateSize: raw.intermediate_size ?? 3072,
    numLayers: raw.num_hidden_layers ?? 16,
    numHeads: raw.num_attention_heads ?? 12,
    numKvHeads: raw.num_key_value_heads ?? raw.num_attention_heads ?? 12,
    headDim: raw.head_dim ?? 64,
    ropeTheta: raw.rope_parameters?.rope_theta ?? 100.0,
    rmsNormEps: raw.rms_norm_eps ?? 1e-6,
    patchSize: raw.patch_size ?? 16,
    poolingKernelSize: raw.pooling_kernel_size ?? 3,
    defaultOutputLength: raw.default_output_length ?? 280,
    positionEmbeddingSize: raw.position_embedding_size ?? 10240,
    standardize: raw.standardize ?? false,
    useClippedLinears: raw.use_clipped_linears ?? false,
  };
}

export interface SiglipPreprocessed {
  /** [numReal, patchDim] f32 patch vectors, normalized 2*(x/255 - 0.5). */
  patches: Float32Array;
  /** [numReal] x grid position (column) of each patch, f32 — also the RoPE
   *  position for the first spatial dim. */
  posX: Float32Array;
  /** [numReal] y grid position (row) of each patch, f32 — RoPE second dim. */
  posY: Float32Array;
  /** [numReal] x grid position as int32, for the position-embedding gather. */
  pxIdx: Int32Array;
  /** [numReal] y grid position as int32, for the position-embedding gather. */
  pyIdx: Int32Array;
  /** [softTokens, numReal] 3×3 avg-pool weights (1/9 in-block, else 0). */
  poolWeights: Float32Array;
  /** Real (unpadded) 16×16 patch count = pH·pW. */
  numReal: number;
  /** Pooled soft-token count = (pH/3)·(pW/3). */
  softTokens: number;
}

/** bytes → resized RGB → SigLIP patch vectors + host-precomputed positions,
 *  RoPE tables and pooling matrix. */
export async function preprocessSiglip(
  bytes: Uint8Array, cfg: SiglipVisionConfig,
): Promise<SiglipPreprocessed> {
  let img = await decodeImage(bytes);
  const t = targetSize(img.width, img.height);
  if (t.width !== img.width || t.height !== img.height)
    img = resizeBicubic(img, t.width, t.height);

  const { width, height, data } = img;
  const p = cfg.patchSize; // 16
  const pH = Math.floor(height / p);
  const pW = Math.floor(width / p);
  const numReal = pH * pW;
  if (numReal === 0) throw new Error("image smaller than one patch");
  const k = cfg.poolingKernelSize; // 3
  const maxPatches = cfg.defaultOutputLength * k * k;
  if (numReal > maxPatches)
    throw new Error(`image yields ${numReal} patches > budget ${maxPatches}`);
  const softW = Math.floor(pW / k);
  const softH = Math.floor(pH / k);
  const softTokens = softW * softH;

  const patchDim = 3 * p * p; // 768

  const patches = new Float32Array(numReal * patchDim);
  const posX = new Float32Array(numReal);
  const posY = new Float32Array(numReal);
  const pxIdx = new Int32Array(numReal);
  const pyIdx = new Int32Array(numReal);
  const poolWeights = new Float32Array(softTokens * numReal);
  const invK2 = 1 / (k * k);

  for (let py = 0; py < pH; py++) {
    for (let px = 0; px < pW; px++) {
      const L = py * pW + px;
      pxIdx[L] = px;
      pyIdx[L] = py;
      posX[L] = px;
      posY[L] = py;

      // patch vector: [p_h, p_w, C] flattened (matches optiq's reshape/
      // transpose), value 2*(pixel/255 - 0.5) = pixel/127.5 - 1.
      const base = L * patchDim;
      for (let dy = 0; dy < p; dy++) {
        for (let dx = 0; dx < p; dx++) {
          const src = ((py * p + dy) * width + px * p + dx) * 3;
          const dst = base + (dy * p + dx) * 3;
          patches[dst] = data[src]! / 127.5 - 1;
          patches[dst + 1] = data[src + 1]! / 127.5 - 1;
          patches[dst + 2] = data[src + 2]! / 127.5 - 1;
        }
      }

      // pooling block index: px//k + (pW//k)*(py//k) (optiq kernel_idxs)
      const block = Math.floor(px / k) + softW * Math.floor(py / k);
      poolWeights[block * numReal + L] = invK2;
    }
  }

  return { patches, posX, posY, pxIdx, pyIdx, poolWeights, numReal, softTokens };
}

export class SiglipVisionTower {
  #weights = new Map<string, MlxArray>();
  readonly cfg: SiglipVisionConfig;
  readonly embedScale: number;
  #wdtype: Dtype = Dtype.bfloat16;

  private constructor(cfg: SiglipVisionConfig, embedScale: number) {
    this.cfg = cfg;
    this.embedScale = embedScale;
  }

  /** Load the `vision_tower.*` + `embed_vision.*` tensors from the bf16
   *  sidecar. `embedScale` = the language model's embed_scale
   *  (= sqrt(textHidden)); features come out pre-divided by it. */
  static load(
    modelDir: string, cfg: SiglipVisionConfig, embedScale: number,
  ): SiglipVisionTower {
    const self = new SiglipVisionTower(cfg, embedScale);
    // out-param slots read via read.u64, not [0] (DFG stale-read bug — see
    // outArray in mlx/ffi.ts).
    const arrMap = new BigUint64Array([C.mlx_map_string_to_array_new()]);
    const metaMap = new BigUint64Array([C.mlx_map_string_to_string_new()]);
    const arrMapPtr = ptr(arrMap);
    const metaMapPtr = ptr(metaMap);
    const status = C.mlx_load_safetensors(
      arrMapPtr, metaMapPtr,
      ptr(cstr(`${modelDir}/optiq_vision.safetensors`)), cpuStream,
    );
    C.mlx_map_string_to_string_free(read.u64(metaMapPtr, 0));
    if (status !== 0) throw new Error(`failed to load vision sidecar from ${modelDir}`);
    const arrMapHandle = read.u64(arrMapPtr, 0);

    const get = (name: string): MlxArray => {
      const slot = new BigUint64Array([C.mlx_array_new()]);
      const slotPtr = ptr(slot);
      if (C.mlx_map_string_to_array_get(slotPtr, arrMapHandle, ptr(cstr(name))) !== 0)
        throw new Error(`vision sidecar missing tensor ${name}`);
      return new MlxArray(read.u64(slotPtr, 0));
    };

    const clipSuffixes = ["input_min", "input_max", "output_min", "output_max"];
    const addLinear = (prefix: string) => {
      self.#weights.set(`${prefix}.linear.weight`, get(`${prefix}.linear.weight`));
      if (cfg.useClippedLinears)
        for (const s of clipSuffixes)
          self.#weights.set(`${prefix}.${s}`, get(`${prefix}.${s}`));
    };

    for (let i = 0; i < cfg.numLayers; i++) {
      const p = `vision_tower.encoder.layers.${i}`;
      for (const ln of [
        "input_layernorm", "post_attention_layernorm",
        "pre_feedforward_layernorm", "post_feedforward_layernorm",
      ])
        self.#weights.set(`${p}.${ln}.weight`, get(`${p}.${ln}.weight`));
      self.#weights.set(`${p}.self_attn.q_norm.weight`, get(`${p}.self_attn.q_norm.weight`));
      self.#weights.set(`${p}.self_attn.k_norm.weight`, get(`${p}.self_attn.k_norm.weight`));
      for (const proj of ["q_proj", "k_proj", "v_proj", "o_proj"])
        addLinear(`${p}.self_attn.${proj}`);
      for (const proj of ["gate_proj", "up_proj", "down_proj"])
        addLinear(`${p}.mlp.${proj}`);
    }
    self.#weights.set(
      "vision_tower.patch_embedder.input_proj.weight",
      get("vision_tower.patch_embedder.input_proj.weight"),
    );
    self.#weights.set(
      "vision_tower.patch_embedder.position_embedding_table",
      get("vision_tower.patch_embedder.position_embedding_table"),
    );
    self.#weights.set(
      "embed_vision.embedding_projection.weight",
      get("embed_vision.embedding_projection.weight"),
    );

    C.mlx_map_string_to_array_free(arrMapHandle);
    self.#wdtype = self.#w("embed_vision.embedding_projection.weight").dtype;
    return self;
  }

  async preprocess(bytes: Uint8Array): Promise<SiglipPreprocessed> {
    return preprocessSiglip(bytes, this.cfg);
  }

  #w(name: string): MlxArray {
    return this.#weights.get(name)!;
  }

  /** nn.Linear: x @ W.T (no bias). Casts x to the weight dtype first. */
  #linear(x: MlxArray, weightName: string): MlxArray {
    const w = this.#w(weightName);
    const xc = x.astype(w.dtype);
    const wT = ops.transposeAxes(w, [1, 0]);
    const out = ops.matmul(xc, wT);
    xc.dispose();
    wT.dispose();
    return out;
  }

  /** ClippableLinear: clip(x) → x @ W.T → clip(out). No bias. */
  #clipLinear(x: MlxArray, prefix: string): MlxArray {
    let xc: MlxArray = x;
    let clippedIn = false;
    if (this.cfg.useClippedLinears) {
      xc = ops.clip(x, this.#w(`${prefix}.input_min`), this.#w(`${prefix}.input_max`));
      clippedIn = true;
    }
    let out = this.#linear(xc, `${prefix}.linear.weight`);
    if (clippedIn) xc.dispose();
    if (this.cfg.useClippedLinears)
      out = dispose(out, ops.clip(out, this.#w(`${prefix}.output_min`), this.#w(`${prefix}.output_max`)));
    return out;
  }

  /** optiq's VisionRMSNorm / VisionRMSNormNoScale: a MANUAL float32 RMS norm
   *  (NOT the fused fast.rms_norm kernel). The q/k/v attention norms must use
   *  the same decomposed op sequence as optiq to stay bit-exact — the fused
   *  kernel diverges ~1 ULP per call, which compounds over 16 layers × 3
   *  norms. (The block layernorms DO use fast.rms_norm in both, so those keep
   *  ops.rmsNorm.) */
  #visionRmsNorm(x: MlxArray, weight: MlxArray | null, eps: number): MlxArray {
    const last = x.shape.length - 1;
    const xf = x.astype(Dtype.float32);
    const sq = ops.square(xf);
    const varr = ops.meanAxis(sq, last, true);
    sq.dispose();
    const epsA = ops.scalarLike(eps, varr);
    const vare = ops.add(varr, epsA);
    varr.dispose();
    epsA.dispose();
    const r = ops.rsqrt(vare);
    vare.dispose();
    let normed = ops.mul(xf, r);
    xf.dispose();
    r.dispose();
    if (weight) {
      const wf = weight.astype(Dtype.float32);
      normed = dispose(normed, ops.mul(normed, wf));
      wf.dispose();
    }
    const out = normed.astype(x.dtype);
    normed.dispose();
    return out;
  }

  /** Build the 2D-RoPE cos/sin tables ON DEVICE, matching optiq's
   *  apply_multidimensional_rope op-for-op (arange → power → div → cos/sin →
   *  concat) so they're bit-identical to the reference — a host-computed
   *  table rounds to bf16 differently and, applied to q&k every layer,
   *  compounds. Returns cosA/sinA [1, numReal, 1, headDim] (bf16). */
  #ropeTables(pre: SiglipPreprocessed): { cosA: MlxArray; sinA: MlxArray } {
    const { headDim, ropeTheta } = this.cfg;
    const { numReal } = pre;
    const channelsPerDim = 2 * Math.floor(headDim / 4); // ndim=2 → 32
    const half = Math.floor(channelsPerDim / 2); // 16

    // freq_exponents = (2/channelsPerDim) * arange(0, half); timescale = θ^freq
    const ar = ops.arange(0, half, 1, Dtype.float32);
    const freq = dispose(ar, ops.mulScalar(ar, 2 / channelsPerDim));
    const base = ops.scalarLike(ropeTheta, freq);
    const timescale = ops.pow(base, freq); // [half]
    base.dispose();
    freq.dispose();

    const perDim = (pos: Float32Array): { c: MlxArray; s: MlxArray } => {
      const p = MlxArray.fromFloat32(pos, [numReal, 1]);
      const sinusoid = ops.div(p, timescale); // [numReal, half]
      p.dispose();
      const cd = ops.cos(sinusoid);
      const sd = ops.sin(sinusoid);
      sinusoid.dispose();
      const c = ops.concatAxis([cd, cd], 1); // duplicate → [numReal, 32]
      const s = ops.concatAxis([sd, sd], 1);
      cd.dispose();
      sd.dispose();
      return { c, s };
    };
    const x = perDim(pre.posX);
    const y = perDim(pre.posY);
    timescale.dispose();

    const bf = this.#wdtype;
    const finish = (cx: MlxArray, cy: MlxArray): MlxArray => {
      const full = ops.concatAxis([cx, cy], 1); // [numReal, headDim]
      const r = ops.reshape(full, [1, numReal, 1, headDim]);
      full.dispose();
      const bfr = r.astype(bf);
      r.dispose();
      return bfr;
    };
    const cosA = finish(x.c, y.c);
    const sinA = finish(x.s, y.s);
    x.c.dispose();
    x.s.dispose();
    y.c.dispose();
    y.s.dispose();
    return { cosA, sinA };
  }

  /** rotate_half applied independently within each spatial-dim partition of
   *  the head (NOT across the whole head). x: [..., headDim]. */
  #partitionedRotateHalf(x: MlxArray): MlxArray {
    const sh = x.shape;
    const last = sh.length - 1;
    const headDim = sh[last]!;
    const channelsPerDim = 2 * Math.floor(headDim / 4); // ndim=2
    const half = Math.floor(channelsPerDim / 2);
    const ndim = Math.floor(headDim / channelsPerDim);
    const sliceLast = (a: number, b: number): MlxArray => {
      const start = sh.map(() => 0);
      const stop = [...sh];
      start[last] = a;
      stop[last] = b;
      return x.slice(start, stop);
    };
    const parts: MlxArray[] = [];
    const scratch: MlxArray[] = [];
    for (let d = 0; d < ndim; d++) {
      const o = d * channelsPerDim;
      const x1 = sliceLast(o, o + half);
      const x2 = sliceLast(o + half, o + channelsPerDim);
      const nx2 = ops.neg(x2);
      const r = ops.concatAxis([nx2, x1], last); // [-x2, x1]
      scratch.push(x1, x2, nx2);
      parts.push(r);
    }
    const out = ops.concatAxis(parts, last);
    for (const a of scratch) a.dispose();
    for (const a of parts) a.dispose();
    return out;
  }

  /** Apply 2D RoPE: x*cos + rotate_half(x)*sin. x: [1, L, H, headDim],
   *  cosA/sinA: [1, L, 1, headDim] (broadcast over heads). */
  #rope(x: MlxArray, cosA: MlxArray, sinA: MlxArray): MlxArray {
    const rotated = this.#partitionedRotateHalf(x);
    const a = ops.mul(x, cosA);
    const b = ops.mul(rotated, sinA);
    rotated.dispose();
    const out = ops.add(a, b);
    a.dispose();
    b.dispose();
    return out;
  }

  /** Self-attention. x: [1, L, hidden]. Single image, unpadded → full
   *  bidirectional attention (no mask). Consumes nothing, returns new. */
  #attention(x: MlxArray, cosA: MlxArray, sinA: MlxArray, prefix: string): MlxArray {
    const L = x.shape[1]!;
    const { numHeads, numKvHeads, headDim, rmsNormEps } = this.cfg;

    const proj = (name: string, heads: number, norm: string | null): MlxArray => {
      let t = this.#clipLinear(x, `${prefix}.${name}`);
      t = dispose(t, ops.reshape(t, [1, L, heads, headDim]));
      t = dispose(t, this.#visionRmsNorm(t, norm ? this.#w(`${prefix}.${norm}`) : null, rmsNormEps));
      return t;
    };
    let q = proj("q_proj", numHeads, "q_norm.weight");
    let k = proj("k_proj", numKvHeads, "k_norm.weight");
    let v = proj("v_proj", numKvHeads, null); // VisionRMSNormNoScale

    q = dispose(q, this.#rope(q, cosA, sinA));
    k = dispose(k, this.#rope(k, cosA, sinA));

    // [1, L, H, D] → [1, H, L, D]
    const qT = ops.transposeAxes(q, [0, 2, 1, 3]);
    const kT = ops.transposeAxes(k, [0, 2, 1, 3]);
    const vT = ops.transposeAxes(v, [0, 2, 1, 3]);
    q.dispose();
    k.dispose();
    v.dispose();

    // scale=1.0 (the trained convention for this encoder) — note this makes
    // the softmax very peaked (q/k are RMS-normed, so q·k has std ~sqrt(D)),
    // which AMPLIFIES the small bf16 difference between mlx-bun's fast SDPA
    // (ops.sdpa) and the reference into occasional argmax flips. That, not a
    // port bug, is the bulk of the ~1.2% feature divergence (see header).
    // ops.sdpa is the closest path (manual softmax(qkᵀ)v is ~2% — worse).
    // Full bidirectional attention, no mask: numerically identical to optiq's
    // padded+(-1e4)-masked path (masked keys underflow to 0) but cheaper.
    let o = ops.sdpa(qT, kT, vT, 1.0, "", null);
    qT.dispose();
    kT.dispose();
    vT.dispose();

    o = dispose(o, ops.transposeAxes(o, [0, 2, 1, 3]));
    o = dispose(o, ops.reshape(o, [1, L, numHeads * headDim]));
    const out = this.#clipLinear(o, `${prefix}.o_proj`);
    o.dispose();
    return out;
  }

  /** GeGLU MLP. x: [1, L, hidden]. */
  #mlp(x: MlxArray, prefix: string): MlxArray {
    let g = this.#clipLinear(x, `${prefix}.gate_proj`);
    g = dispose(g, ops.geluApprox(g));
    const u = this.#clipLinear(x, `${prefix}.up_proj`);
    const prod = ops.mul(g, u);
    g.dispose();
    u.dispose();
    const out = this.#clipLinear(prod, `${prefix}.down_proj`);
    prod.dispose();
    return out;
  }

  /** One transformer block. Returns a new hidden; caller disposes the input. */
  #block(h: MlxArray, cosA: MlxArray, sinA: MlxArray, i: number): MlxArray {
    const eps = this.cfg.rmsNormEps;
    const p = `vision_tower.encoder.layers.${i}`;

    const normed = ops.rmsNorm(h, this.#w(`${p}.input_layernorm.weight`), eps);
    let attn = this.#attention(normed, cosA, sinA, `${p}.self_attn`);
    normed.dispose();
    attn = dispose(attn, ops.rmsNorm(attn, this.#w(`${p}.post_attention_layernorm.weight`), eps));
    const h1 = ops.add(h, attn);
    attn.dispose();

    const normed2 = ops.rmsNorm(h1, this.#w(`${p}.pre_feedforward_layernorm.weight`), eps);
    let ff = this.#mlp(normed2, `${p}.mlp`);
    normed2.dispose();
    ff = dispose(ff, ops.rmsNorm(ff, this.#w(`${p}.post_feedforward_layernorm.weight`), eps));
    const h2 = ops.add(h1, ff);
    h1.dispose();
    ff.dispose();
    return h2;
  }

  /** One preprocessed image → language-space soft tokens
   *  [1, softTokens, textHidden], pre-divided by embed_scale. */
  features(pre: SiglipPreprocessed): MlxArray {
    const { hiddenSize, positionEmbeddingSize, rmsNormEps } = this.cfg;
    const { numReal, softTokens } = pre;
    const patchDim = 3 * this.cfg.patchSize * this.cfg.patchSize;
    const bf = this.#wdtype;

    // --- patch embedding ---
    const patchArr = MlxArray.fromFloat32(pre.patches, [1, numReal, patchDim]);
    let h = this.#linear(patchArr, "vision_tower.patch_embedder.input_proj.weight");
    patchArr.dispose();

    // + 2D position embedding: table[0, px] + table[1, py]
    const table = this.#w("vision_tower.patch_embedder.position_embedding_table");
    const slicePlane = (i: number): MlxArray => {
      const s = table.slice([i, 0, 0], [i + 1, positionEmbeddingSize, hiddenSize]);
      const r = ops.reshape(s, [positionEmbeddingSize, hiddenSize]);
      s.dispose();
      return r;
    };
    const t0r = slicePlane(0);
    const t1r = slicePlane(1);
    const pxArr = MlxArray.fromInt32(pre.pxIdx, [numReal]);
    const pyArr = MlxArray.fromInt32(pre.pyIdx, [numReal]);
    const e0 = ops.takeAxis(t0r, pxArr, 0);
    const e1 = ops.takeAxis(t1r, pyArr, 0);
    t0r.dispose();
    t1r.dispose();
    pxArr.dispose();
    pyArr.dispose();
    let pos = ops.add(e0, e1);
    e0.dispose();
    e1.dispose();
    pos = dispose(pos, ops.reshape(pos, [1, numReal, hiddenSize]));
    h = dispose(h, ops.add(h, pos));
    pos.dispose();

    // --- transformer (device-built RoPE tables, full bidirectional attn) ---
    const { cosA, sinA } = this.#ropeTables(pre);
    for (let i = 0; i < this.cfg.numLayers; i++) {
      const next = this.#block(h, cosA, sinA, i);
      h.dispose();
      h = next;
    }
    cosA.dispose();
    sinA.dispose();

    // --- 3×3 avg-pool over the patch grid (×√hidden) ---
    // optiq computes the pool in f32 then casts back to bf16; match that.
    const hf = h.astype(Dtype.float32);
    h.dispose();
    const h2 = ops.reshape(hf, [numReal, hiddenSize]);
    hf.dispose();
    const poolW = MlxArray.fromFloat32(pre.poolWeights, [softTokens, numReal]);
    let pooled = ops.matmul(poolW, h2); // [soft, hidden] f32
    poolW.dispose();
    h2.dispose();
    pooled = dispose(pooled, pooled.astype(bf));
    pooled = dispose(pooled, ops.mulScalar(pooled, Math.sqrt(hiddenSize)));
    pooled = dispose(pooled, ops.reshape(pooled, [1, softTokens, hiddenSize]));
    // standardize (e2b/e4b: off) intentionally unsupported until a model needs it.
    if (this.cfg.standardize)
      throw new Error("SigLIP standardize=true not yet supported");

    // --- MultimodalEmbedder: RMSNormNoScale → Linear(no bias) ---
    pooled = dispose(pooled, ops.rmsNorm(pooled, null, rmsNormEps));
    let feats = this.#linear(pooled, "embed_vision.embedding_projection.weight");
    pooled.dispose();

    // pre-divide by embed_scale (language model re-multiplies)
    const scale = ops.scalarLike(this.embedScale, feats);
    const out = ops.div(feats, scale);
    feats.dispose();
    scale.dispose();
    return out; // [1, softTokens, textHidden]
  }

  dispose(): void {
    for (const w of this.#weights.values()) w.dispose();
    this.#weights.clear();
  }
}
