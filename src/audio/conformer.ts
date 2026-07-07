// Gemma-4 Conformer audio tower — op-for-op port of optiq's
// vlm/_mlxvlm/models/gemma4/audio.py (AudioEncoder) plus the audio
// MultimodalEmbedder (gemma4.py: RMSNormNoScale → Linear), fed from the bf16
// `optiq_vision.safetensors` sidecar (752 audio_tower.* / embed_audio.*
// tensors, including the ClippableLinear input/output min/max stats).
//
// Pipeline (batch 1):
//   mel [1,T,128,1] f32 → SSCP: 2× (pad(1,1,1,1) → Conv2d 3×3 stride 2 →
//   LayerNorm(channels, no bias) → ReLU), channels (128, 32) → flatten F·C →
//   Linear to hidden 1024 → 12× ConformerBlock (FFW½ → chunked local
//   attention → light depthwise Conv1d → FFW½ → clamp → RMSNorm) →
//   output_proj to 1536 (bias) → mask-zero → embed_audio (RMSNormNoScale →
//   Linear to textHidden 2560) → /embed_scale.
//
// Dtype contract (differs from siglip.ts — deliberate): the oracle feeds f32
// mel straight into bf16-weight modules and lets mlx PROMOTE, so every
// activation stays float32 end-to-end while weights stay bf16. We therefore
// must NOT cast activations to the weight dtype in #linear (siglip does).
// The ONE bf16 roundtrip the oracle performs — the relative-position timing
// signal is cast to bf16 for relative_k_proj and back to f32 — is mirrored.
//
// Chunked local attention (audio.py AudioAttention, config: chunk 12, left
// context 13 chunks → max_past 12, right 0, so context_size 24):
//   q/k/v via ClippableLinear (clamp to shipped stats), f32;
//   q *= softplus(per_dim_scale)·(head_dim^-0.5/ln2), k *= ln(1+e)/ln2;
//   q → [U, 12] blocks (T zero-padded up), k/v → [U, 24] block contexts
//   (pad 12 left / 11 right then strided gather);
//   logits = q·kᵀ + relative-shifted q·relative_k_proj(timing_signal)ᵀ;
//   softcap: tanh(logits/50)·50; invalid (pad or acausal) → -1e9;
//   softmax f32; context = probs·v; slice back to T; `post` projection.
// The causal+validity mask is exact boolean bookkeeping, so it's computed
// host-side (bit-identical to the oracle's tril build, far fewer ops):
// query chunk-position i may see context j iff i ≤ j ≤ i + 12, AND the
// context slot maps to a real (unpadded, valid) frame.
//
// Golden reference point (goldens/e4b-audio.json, gen-e4b-audio-golden.py):
// the dumped [n,2560] embeddings are the embed_audio OUTPUT in f32, NOT yet
// divided by embed_scale — the /embed_scale happens at the T2 splice. Like
// the vision towers, features() returns PRE-DIVIDED by embedScale (the
// language model's forwardEmbeddings re-multiplies), so the T1 test
// re-multiplies by embedScale before comparing against the golden.
//
// mlx inline-temporary hazard (CLAUDE.md): every op result is held in a
// local and disposed; no nested `ops.foo(x.slice(...))` chains.

import { ptr, read } from "bun:ffi";
import { MlxArray, cpuStream } from "../mlx/array";
import { C, Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";

const cstr = (s: string) => Buffer.from(s + "\0", "utf8");
const dispose = (old: MlxArray, next: MlxArray): MlxArray => {
  old.dispose();
  return next;
};

export interface AudioTowerConfig {
  hiddenSize: number;
  numLayers: number;
  numHeads: number;
  convKernelSize: number;
  subsamplingConvChannels: [number, number];
  attentionChunkSize: number;
  attentionContextLeft: number;
  attentionContextRight: number;
  attentionLogitCap: number;
  attentionInvalidLogitsValue: number;
  residualWeight: number;
  rmsNormEps: number;
  gradientClipping: number;
  outputProjDims: number;
  useClippedLinears: boolean;
}

/** Parse a config.json `audio_config` block (gemma4_audio). Defaults mirror
 *  optiq's AudioConfig dataclass. */
export function parseAudioConfig(raw: Record<string, any>): AudioTowerConfig {
  return {
    hiddenSize: raw.hidden_size ?? 1024,
    numLayers: raw.num_hidden_layers ?? 12,
    numHeads: raw.num_attention_heads ?? 8,
    convKernelSize: raw.conv_kernel_size ?? 5,
    subsamplingConvChannels: (raw.subsampling_conv_channels ?? [128, 32]) as [number, number],
    attentionChunkSize: raw.attention_chunk_size ?? 12,
    attentionContextLeft: raw.attention_context_left ?? 13,
    attentionContextRight: raw.attention_context_right ?? 0,
    attentionLogitCap: raw.attention_logit_cap ?? 50.0,
    attentionInvalidLogitsValue: raw.attention_invalid_logits_value ?? -1e9,
    residualWeight: raw.residual_weight ?? 0.5,
    rmsNormEps: raw.rms_norm_eps ?? 1e-6,
    gradientClipping: raw.gradient_clipping ?? 1e10,
    outputProjDims: raw.output_proj_dims ?? 1536,
    useClippedLinears: raw.use_clipped_linears ?? true,
  };
}

/** Mel input feature width (USM: 128 mel bins). Fixed for all gemma-4 audio
 *  models — audio.py SubSampleConvProjection.INPUT_FEAT_SIZE. */
export const AUDIO_INPUT_FEAT_SIZE = 128;

/** Per-block precomputed attention context (masks, gather indices, timing
 *  signal) — layer-independent, built once per features() call. */
interface AttnContext {
  U: number;
  qPad: number;
  /** [U*contextSize] int32 gather indices into the padded key/value time axis. */
  kvIdx: MlxArray;
  /** [1,1,U,chunk,context] bool: causal ∧ context-slot-valid. */
  cond: MlxArray;
  /** [maxSpan, hidden] bf16 sinusoidal timing signal (pre-relative_k_proj). */
  sinBf: MlxArray;
  /** [1,T,1] f32 validity multiplier (1 valid / 0 invalid). */
  validF32: MlxArray;
}

export class AudioTower {
  #weights = new Map<string, MlxArray>();
  readonly cfg: AudioTowerConfig;
  readonly embedScale: number;

  private constructor(cfg: AudioTowerConfig, embedScale: number) {
    this.cfg = cfg;
    this.embedScale = embedScale;
  }

  /** Load the `audio_tower.*` + `embed_audio.*` tensors from the bf16
   *  sidecar. `embedScale` = the language model's embed_scale
   *  (= sqrt(textHidden)); features come out pre-divided by it. */
  static load(
    modelDir: string, cfg: AudioTowerConfig, embedScale: number,
  ): AudioTower {
    const self = new AudioTower(cfg, embedScale);
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
    if (status !== 0) throw new Error(`failed to load audio sidecar from ${modelDir}`);
    const arrMapHandle = read.u64(arrMapPtr, 0);

    const get = (name: string): MlxArray => {
      const slot = new BigUint64Array([C.mlx_array_new()]);
      const slotPtr = ptr(slot);
      if (C.mlx_map_string_to_array_get(slotPtr, arrMapHandle, ptr(cstr(name))) !== 0)
        throw new Error(`audio sidecar missing tensor ${name}`);
      return new MlxArray(read.u64(slotPtr, 0));
    };

    const clipSuffixes = ["input_min", "input_max", "output_min", "output_max"];
    const addClipLinear = (prefix: string) => {
      self.#weights.set(`${prefix}.linear.weight`, get(`${prefix}.linear.weight`));
      if (cfg.useClippedLinears)
        for (const s of clipSuffixes)
          self.#weights.set(`${prefix}.${s}`, get(`${prefix}.${s}`));
    };
    const add = (name: string) => self.#weights.set(name, get(name));

    for (let i = 0; i < cfg.numLayers; i++) {
      const p = `audio_tower.layers.${i}`;
      for (const ff of ["feed_forward1", "feed_forward2"]) {
        add(`${p}.${ff}.pre_layer_norm.weight`);
        add(`${p}.${ff}.post_layer_norm.weight`);
        addClipLinear(`${p}.${ff}.ffw_layer_1`);
        addClipLinear(`${p}.${ff}.ffw_layer_2`);
      }
      for (const proj of ["q_proj", "k_proj", "v_proj", "post"])
        addClipLinear(`${p}.self_attn.${proj}`);
      add(`${p}.self_attn.relative_k_proj.weight`);
      add(`${p}.self_attn.per_dim_scale`);
      add(`${p}.lconv1d.pre_layer_norm.weight`);
      add(`${p}.lconv1d.conv_norm.weight`);
      add(`${p}.lconv1d.depthwise_conv1d.weight`); // [hidden, K, 1] (MLX layout)
      addClipLinear(`${p}.lconv1d.linear_start`);
      addClipLinear(`${p}.lconv1d.linear_end`);
      add(`${p}.norm_pre_attn.weight`);
      add(`${p}.norm_post_attn.weight`);
      add(`${p}.norm_out.weight`);
    }
    // Sidecar conv weights are ALREADY MLX layout [C_out, kH, kW, C_in]
    // (layer0 [128,3,3,1], layer1 [32,3,3,128] — verified against the e4b
    // sidecar header); gemma4.py's sanitize() transpose targets the base-repo
    // PyTorch layout, which the sidecar extraction has already applied.
    add("audio_tower.subsample_conv_projection.layer0.conv.weight");
    add("audio_tower.subsample_conv_projection.layer0.norm.weight");
    add("audio_tower.subsample_conv_projection.layer1.conv.weight");
    add("audio_tower.subsample_conv_projection.layer1.norm.weight");
    add("audio_tower.subsample_conv_projection.input_proj_linear.weight");
    add("audio_tower.output_proj.weight");
    add("audio_tower.output_proj.bias");
    add("embed_audio.embedding_projection.weight");

    C.mlx_map_string_to_array_free(arrMapHandle);
    return self;
  }

  #w(name: string): MlxArray {
    return this.#weights.get(name)!;
  }

  /** nn.Linear: x @ W.T (no bias). NO input cast — activations are f32,
   *  weights bf16, and mlx promotes exactly like the oracle (see header). */
  #linear(x: MlxArray, weightName: string): MlxArray {
    const w = this.#w(weightName);
    const wT = ops.transposeAxes(w, [1, 0]);
    const out = ops.matmul(x, wT);
    wT.dispose();
    return out;
  }

  /** ClippableLinear: clip(x, input_min, input_max) → x @ W.T →
   *  clip(out, output_min, output_max). Clip bounds are bf16 scalars from the
   *  sidecar; clip on f32 x stays f32 (promote), matching the oracle. */
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

  /** mx.clip(x, -gradient_clipping, +gradient_clipping) (1e10 — active at
   *  inference in the oracle; a no-op numerically unless activations blow up,
   *  but ported faithfully). */
  #gclip(x: MlxArray): MlxArray {
    const lo = ops.scalarLike(-this.cfg.gradientClipping, x);
    const hi = ops.scalarLike(this.cfg.gradientClipping, x);
    const out = ops.clip(x, lo, hi);
    lo.dispose();
    hi.dispose();
    return out;
  }

  /** Zero-pad along one axis via concat (values identical to mx.pad). */
  #padAxis(x: MlxArray, axis: number, before: number, after: number): MlxArray {
    if (before === 0 && after === 0) throw new Error("padAxis: nothing to pad");
    const mk = (n: number): MlxArray => {
      const shape = [...x.shape];
      shape[axis] = n;
      return ops.zeros(shape, x.dtype);
    };
    const parts: MlxArray[] = [];
    const scratch: MlxArray[] = [];
    if (before > 0) {
      const z = mk(before);
      parts.push(z);
      scratch.push(z);
    }
    parts.push(x);
    if (after > 0) {
      const z = mk(after);
      parts.push(z);
      scratch.push(z);
    }
    const out = ops.concatAxis(parts, axis);
    for (const a of scratch) a.dispose();
    return out;
  }

  /** Host-int mask (0/1) → device bool array of the given shape. */
  #boolMask(data: Int32Array, shape: number[]): MlxArray {
    const i32 = MlxArray.fromInt32(data, shape);
    const b = i32.astype(Dtype.bool);
    i32.dispose();
    return b;
  }

  /** SSCPConvBlock: zero-invalid → pad(1,1,1,1) → Conv2d 3×3 stride (2,2),
   *  no conv padding (mirrors the oracle's explicit mx.pad) → LayerNorm over
   *  channels (no bias) → ReLU. Returns the conv output and the
   *  stride-2-downsampled validity. */
  #sscpBlock(
    xin: MlxArray, valid: Uint8Array, idx: 0 | 1,
  ): { x: MlxArray; valid: Uint8Array } {
    const p = `audio_tower.subsample_conv_projection.layer${idx}`;
    const T = xin.shape[1]!;

    // x = where(invalid[:, :, None, None], 0, x)
    const inv = new Int32Array(T);
    for (let i = 0; i < T; i++) inv[i] = valid[i] ? 0 : 1;
    const cond = this.#boolMask(inv, [1, T, 1, 1]);
    const zero = ops.scalarLike(0, xin);
    let x = ops.where(cond, zero, xin);
    cond.dispose();
    zero.dispose();

    x = dispose(x, this.#padAxis(x, 1, 1, 1)); // time
    x = dispose(x, this.#padAxis(x, 2, 1, 1)); // freq
    x = dispose(x, ops.conv2d(x, this.#w(`${p}.conv.weight`), [2, 2], [0, 0]));

    const tOut = x.shape[1]!;
    const outValid = new Uint8Array(tOut); // mask[:, ::2][:, :tOut]
    for (let i = 0; i < tOut; i++) outValid[i] = valid[2 * i] ?? 0;

    x = dispose(x, ops.layerNorm(x, this.#w(`${p}.norm.weight`), null, this.cfg.rmsNormEps));
    const z = ops.scalarLike(0, x);
    x = dispose(x, ops.maximum(x, z)); // nn.relu
    z.dispose();
    return { x, valid: outValid };
  }

  /** ConformerFeedForward (macaron half): clamp → RMSNorm → ClippableLinear
   *  4× → SiLU → ClippableLinear → clamp → RMSNorm; residual + 0.5·out. */
  #ffw(x: MlxArray, prefix: string): MlxArray {
    const eps = this.cfg.rmsNormEps;
    let h = this.#gclip(x);
    h = dispose(h, ops.rmsNorm(h, this.#w(`${prefix}.pre_layer_norm.weight`), eps));
    h = dispose(h, this.#clipLinear(h, `${prefix}.ffw_layer_1`));
    h = dispose(h, ops.silu(h));
    h = dispose(h, this.#clipLinear(h, `${prefix}.ffw_layer_2`));
    h = dispose(h, this.#gclip(h));
    h = dispose(h, ops.rmsNorm(h, this.#w(`${prefix}.post_layer_norm.weight`), eps));
    h = dispose(h, ops.mulScalar(h, this.cfg.residualWeight));
    const out = ops.add(x, h); // residual + x·w (x NOT consumed)
    h.dispose();
    return out;
  }

  /** ConformerLightConv1d: RMSNorm → Linear 2× → GLU → causal pad →
   *  depthwise Conv1d → clamp → RMSNorm → SiLU → Linear; + residual. */
  #lconv(x: MlxArray, prefix: string): MlxArray {
    const { hiddenSize, convKernelSize, rmsNormEps } = this.cfg;
    let h = ops.rmsNorm(x, this.#w(`${prefix}.pre_layer_norm.weight`), rmsNormEps);
    h = dispose(h, this.#clipLinear(h, `${prefix}.linear_start`)); // [1,T,2H]

    // GLU: x1 * sigmoid(x2)
    const [x1, x2] = ops.split(h, [hiddenSize], -1) as [MlxArray, MlxArray];
    const sg = ops.sigmoid(x2);
    const g = ops.mul(x1, sg);
    x1.dispose();
    x2.dispose();
    sg.dispose();
    h.dispose();

    let c = this.#padAxis(g, 1, convKernelSize - 1, 0); // causal left pad
    g.dispose();
    c = dispose(c, ops.conv1d(
      c, this.#w(`${prefix}.depthwise_conv1d.weight`), 1, 0, 1, hiddenSize,
    ));
    c = dispose(c, this.#gclip(c));
    c = dispose(c, ops.rmsNorm(c, this.#w(`${prefix}.conv_norm.weight`), rmsNormEps));
    c = dispose(c, ops.silu(c));
    c = dispose(c, this.#clipLinear(c, `${prefix}.linear_end`));
    const out = ops.add(c, x);
    c.dispose();
    return out;
  }

  /** Chunked local attention with relative position embedding and logit
   *  softcap (audio.py AudioAttention.__call__, f32 throughout except the
   *  bf16 relative_k_proj roundtrip). x: [1,T,hidden] f32. */
  #attention(x: MlxArray, prefix: string, actx: AttnContext): MlxArray {
    const { hiddenSize, numHeads, attentionChunkSize: chunk } = this.cfg;
    const { attentionContextLeft, attentionContextRight } = this.cfg;
    const maxPast = Math.max(0, attentionContextLeft - 1);
    const maxFuture = attentionContextRight;
    const context = chunk + maxPast + maxFuture;
    const maxSpan = maxPast + maxFuture + 1;
    const H = hiddenSize / numHeads;
    const N = numHeads;
    const T = x.shape[1]!;
    const { U, qPad } = actx;
    const qScale = Math.pow(H, -0.5) / Math.LN2;
    const kScale = Math.log(1 + Math.E) / Math.LN2;

    // q/k/v: ClippableLinear outputs are already f32 (promoted), matching the
    // oracle's explicit .astype(mx.float32).
    let q = this.#clipLinear(x, `${prefix}.q_proj`);
    q = dispose(q, ops.reshape(q, [1, T, N, H]));
    let k = this.#clipLinear(x, `${prefix}.k_proj`);
    k = dispose(k, ops.reshape(k, [1, T, N, H]));
    let v = this.#clipLinear(x, `${prefix}.v_proj`);
    v = dispose(v, ops.reshape(v, [1, T, N, H]));

    // q *= q_scale·softplus(per_dim_scale) (bf16, as the oracle computes it),
    // k *= k_scale (f32 scalar).
    const sp = ops.softplus(this.#w(`${prefix}.per_dim_scale`)); // bf16 [H]
    const spScaled = ops.mulScalar(sp, qScale); // bf16
    sp.dispose();
    q = dispose(q, ops.mul(q, spScaled)); // f32
    spScaled.dispose();
    k = dispose(k, ops.mulScalar(k, kScale));

    // _convert_to_block: q → [1,U,chunk,N,H] (zero-pad T up to U·chunk).
    if (qPad > 0) q = dispose(q, this.#padAxis(q, 1, 0, qPad));
    q = dispose(q, ops.reshape(q, [1, U, chunk, N, H]));

    // _extract_block_context: k/v → [1,U,context,N,H] via pad + gather.
    const extract = (t: MlxArray): MlxArray => {
      let e = this.#padAxis(t, 1, maxPast, maxFuture + chunk - 1);
      e = dispose(e, ops.takeAxis(e, actx.kvIdx, 1)); // [1,U*context,N,H]
      e = dispose(e, ops.reshape(e, [1, U, context, N, H]));
      return e;
    };
    const kc = extract(k);
    k.dispose();
    const vc = extract(v);
    v.dispose();

    // term_ac = q·kᵀ per (head, block): [1,N,U,W,H] @ [1,N,U,H,C] → [1,N,U,W,C]
    const qp = ops.transposeAxes(q, [0, 3, 1, 2, 4]);
    q.dispose();
    const kp = ops.transposeAxes(kc, [0, 3, 1, 4, 2]);
    kc.dispose();
    const termAc = ops.matmul(qp, kp);
    kp.dispose();

    // term_bd = q · relative_k_proj(timing_signal)ᵀ, relative-shifted.
    // sinBf [maxSpan, hidden] bf16 → proj (bf16 linear) → [maxSpan,N,H] f32.
    let posE = this.#linear(actx.sinBf, `${prefix}.relative_k_proj.weight`); // bf16
    posE = dispose(posE, ops.reshape(posE, [maxSpan, N, H]));
    posE = dispose(posE, posE.astype(Dtype.float32));
    posE = dispose(posE, ops.transposeAxes(posE, [1, 2, 0])); // [N,H,maxSpan]

    let qr = ops.reshape(qp, [1, N, U * chunk, H]);
    qp.dispose();
    let tbd = ops.matmul(qr, posE); // [1,N,U*chunk,maxSpan]
    qr.dispose();
    posE.dispose();
    tbd = dispose(tbd, ops.reshape(tbd, [1, N, U, chunk, maxSpan]));

    // _relative_shift: pad last to context+1, flatten, truncate, reshape.
    const padAmt = context + 1 - maxSpan;
    if (padAmt > 0) tbd = dispose(tbd, this.#padAxis(tbd, 4, 0, padAmt));
    tbd = dispose(tbd, ops.reshape(tbd, [1, N, U, chunk * (context + 1)]));
    tbd = dispose(tbd, tbd.slice([0, 0, 0, 0], [1, N, U, chunk * context]));
    tbd = dispose(tbd, ops.reshape(tbd, [1, N, U, chunk, context]));

    let logits = ops.add(termAc, tbd);
    termAc.dispose();
    tbd.dispose();

    // softcap: tanh(logits / cap) · cap
    const cap = ops.scalarLike(this.cfg.attentionLogitCap, logits);
    logits = dispose(logits, ops.div(logits, cap));
    cap.dispose();
    logits = dispose(logits, ops.tanh(logits));
    logits = dispose(logits, ops.mulScalar(logits, this.cfg.attentionLogitCap));

    // invalid → -1e9, softmax over context (f32).
    const fill = ops.scalarLike(this.cfg.attentionInvalidLogitsValue, logits);
    logits = dispose(logits, ops.where(actx.cond, logits, fill));
    fill.dispose();
    const probs = ops.softmaxAxis(logits, -1, false);
    logits.dispose();

    // einsum bnuwc,bucnh→buwnh as transposed matmul:
    // [1,U,N,W,C] @ [1,U,N,C,H] → [1,U,N,W,H] → [1,U,W,N,H]
    const pt = ops.transposeAxes(probs, [0, 2, 1, 3, 4]);
    probs.dispose();
    const vt = ops.transposeAxes(vc, [0, 1, 3, 2, 4]);
    vc.dispose();
    let ctx = ops.matmul(pt, vt);
    pt.dispose();
    vt.dispose();
    ctx = dispose(ctx, ops.transposeAxes(ctx, [0, 1, 3, 2, 4]));
    ctx = dispose(ctx, ops.reshape(ctx, [1, U * chunk, N, H]));
    ctx = dispose(ctx, ctx.slice([0, 0, 0, 0], [1, T, N, H]));
    ctx = dispose(ctx, ops.reshape(ctx, [1, T, N * H]));
    const out = this.#clipLinear(ctx, `${prefix}.post`);
    ctx.dispose();
    return out;
  }

  /** One ConformerBlock. Does not consume x. */
  #block(x: MlxArray, i: number, actx: AttnContext): MlxArray {
    const p = `audio_tower.layers.${i}`;
    const eps = this.cfg.rmsNormEps;

    let h = this.#ffw(x, `${p}.feed_forward1`);

    // attention with pre/post norm and residual
    const res = h;
    let a = this.#gclip(h);
    a = dispose(a, ops.rmsNorm(a, this.#w(`${p}.norm_pre_attn.weight`), eps));
    a = dispose(a, this.#attention(a, `${p}.self_attn`, actx));
    a = dispose(a, this.#gclip(a));
    a = dispose(a, ops.rmsNorm(a, this.#w(`${p}.norm_post_attn.weight`), eps));
    h = ops.add(res, a);
    a.dispose();
    res.dispose();

    // zero invalid positions before lconv1d (×1.0/0.0 validity, f32 exact)
    h = dispose(h, ops.mul(h, actx.validF32));

    h = dispose(h, this.#lconv(h, `${p}.lconv1d`));
    h = dispose(h, this.#ffw(h, `${p}.feed_forward2`));
    h = dispose(h, this.#gclip(h));
    h = dispose(h, ops.rmsNorm(h, this.#w(`${p}.norm_out.weight`), eps));
    return h;
  }

  /** Build the per-call attention context: block/gather geometry, the
   *  causal∧validity condition mask (exact boolean bookkeeping → host-side),
   *  the bf16 timing signal, and the validity multiplier. */
  #attnContext(T: number, valid: Uint8Array): AttnContext {
    const { hiddenSize, attentionChunkSize: chunk } = this.cfg;
    const maxPast = Math.max(0, this.cfg.attentionContextLeft - 1);
    const maxFuture = this.cfg.attentionContextRight;
    const context = chunk + maxPast + maxFuture;
    const maxSpan = maxPast + maxFuture + 1;
    const upperDiag = maxPast + maxFuture;
    const U = Math.ceil(T / chunk);
    const qPad = U * chunk - T;
    // oracle invariant: block counts from _convert_to_block and
    // _extract_block_context agree
    const uKv = Math.floor((T + maxPast + (maxFuture + chunk - 1) - context) / chunk) + 1;
    if (uKv !== U) throw new Error(`audio attention block mismatch: ${U} vs ${uKv}`);

    // key/value context gather indices into the (maxPast‖T‖chunk-1+maxFuture)
    // padded time axis: block u, slot c → u·chunk + c.
    const idxData = new Int32Array(U * context);
    for (let u = 0; u < U; u++)
      for (let c = 0; c < context; c++) idxData[u * context + c] = u * chunk + c;
    const kvIdx = MlxArray.fromInt32(idxData, [U * context]);

    // condition[u,i,c] = validity of context slot c of block u (real frame,
    // in range, valid) ∧ causal window (i ≤ c ≤ i + upperDiag) — exactly
    // extracted_valid & causal_valid_mask in the oracle.
    const condData = new Int32Array(U * chunk * context);
    for (let u = 0; u < U; u++)
      for (let i = 0; i < chunk; i++)
        for (let c = 0; c < context; c++) {
          const p = u * chunk + c - maxPast; // unpadded frame index
          const ev = p >= 0 && p < T && !!valid[p];
          const causal = i <= c && c <= i + upperDiag;
          condData[(u * chunk + i) * context + c] = ev && causal ? 1 : 0;
        }
    const cond = this.#boolMask(condData, [1, 1, U, chunk, context]);

    // sinusoidal timing signal for relative positions maxPast … -maxFuture,
    // built on-device op-for-op (arange → exp → sin/cos → concat) so the
    // transcendentals match the oracle bit-for-bit, then the one deliberate
    // bf16 cast (audio.py: sin_emb.astype(pos_proj.weight.dtype)).
    const numTs = Math.floor(hiddenSize / 2);
    const logInc = Math.log(10000.0) / Math.max(numTs - 1, 1);
    const ar = ops.arange(0, numTs, 1, Dtype.float32);
    const negs = ops.mulScalar(ar, -logInc);
    ar.dispose();
    let invT = ops.exp(negs);
    negs.dispose();
    invT = dispose(invT, ops.reshape(invT, [1, numTs]));
    const posData = new Float32Array(maxSpan);
    for (let s = 0; s < maxSpan; s++) posData[s] = maxPast - s;
    const pos = MlxArray.fromFloat32(posData, [maxSpan, 1]);
    const scaled = ops.mul(pos, invT); // [maxSpan, numTs] f32
    pos.dispose();
    invT.dispose();
    const sinP = ops.sin(scaled);
    const cosP = ops.cos(scaled);
    scaled.dispose();
    const sig = ops.concatAxis([sinP, cosP], 1); // [maxSpan, hidden] f32
    sinP.dispose();
    cosP.dispose();
    const sinBf = sig.astype(Dtype.bfloat16);
    sig.dispose();

    // validity multiplier [1,T,1] f32
    const vData = new Float32Array(T);
    for (let i = 0; i < T; i++) vData[i] = valid[i] ? 1 : 0;
    const validF32 = MlxArray.fromFloat32(vData, [1, T, 1]);

    return { U, qPad, kvIdx, cond, sinBf, validF32 };
  }

  /** Mel features [frames, 128] f32 (row-major, all frames valid) →
   *  language-space soft tokens [1, nSoft, textHidden] f32, PRE-DIVIDED by
   *  embedScale (forwardEmbeddings re-multiplies — vision-tower convention;
   *  the T1 golden is the UN-divided embed_audio output, so the parity test
   *  re-multiplies). nSoft = ceil(ceil(frames/2)/2)… i.e. two stride-2 convs. */
  features(mel: Float32Array, frames: number): MlxArray {
    if (mel.length !== frames * AUDIO_INPUT_FEAT_SIZE)
      throw new Error(`mel length ${mel.length} != frames ${frames} × ${AUDIO_INPUT_FEAT_SIZE}`);
    const eps = this.cfg.rmsNormEps;

    // ── SSCP: [1,T,128,1] → 2× conv blocks → [1,T2,F2·C2] → Linear(hidden)
    const x0 = MlxArray.fromFloat32(mel, [1, frames, AUDIO_INPUT_FEAT_SIZE, 1]);
    const valid0 = new Uint8Array(frames).fill(1);
    const s0 = this.#sscpBlock(x0, valid0, 0);
    x0.dispose();
    const s1 = this.#sscpBlock(s0.x, s0.valid, 1);
    s0.x.dispose();
    const [, T2, F2, C2] = s1.x.shape as [number, number, number, number];
    let h = ops.reshape(s1.x, [1, T2, F2 * C2]);
    s1.x.dispose();
    h = dispose(h, this.#linear(h, "audio_tower.subsample_conv_projection.input_proj_linear.weight"));

    // ── 12 Conformer blocks
    const actx = this.#attnContext(T2, s1.valid);
    for (let i = 0; i < this.cfg.numLayers; i++) {
      const next = this.#block(h, i, actx);
      h.dispose();
      h = next;
    }
    actx.kvIdx.dispose();
    actx.cond.dispose();
    actx.sinBf.dispose();
    actx.validF32.dispose();

    // ── output projection (bias) → mask-zero invalid frames
    const wT = ops.transposeAxes(this.#w("audio_tower.output_proj.weight"), [1, 0]);
    h = dispose(h, ops.addmm(this.#w("audio_tower.output_proj.bias"), h, wT));
    wT.dispose();
    const invData = new Int32Array(T2);
    for (let i = 0; i < T2; i++) invData[i] = s1.valid[i] ? 0 : 1;
    const invCond = this.#boolMask(invData, [1, T2, 1]);
    const zero = ops.scalarLike(0, h);
    h = dispose(h, ops.where(invCond, zero, h));
    invCond.dispose();
    zero.dispose();

    // ── embed_audio: RMSNormNoScale → Linear(textHidden), then /embed_scale
    h = dispose(h, ops.rmsNorm(h, null, eps));
    h = dispose(h, this.#linear(h, "embed_audio.embedding_projection.weight"));
    const scale = ops.scalarLike(this.embedScale, h);
    const out = ops.div(h, scale);
    h.dispose();
    scale.dispose();
    return out; // [1, T2, textHidden] f32
  }

  dispose(): void {
    for (const w of this.#weights.values()) w.dispose();
    this.#weights.clear();
  }
}
