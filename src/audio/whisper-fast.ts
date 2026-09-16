// Whisper FAST execution path — the optimized graphs behind the same
// decoding loop as the faithful port (whisper.ts / whisper-decode.ts).
// Gated token-exact against the faithful path on the fixture clips
// (tests/parity/whisper-fast.test.ts); never bit-exact by design.
//
// What it changes (PLAN "Whisper P3", the reference-engine techniques):
//   S1 fused SDPA (mx.fast.scaled_dot_product_attention) for encoder
//      self-attention, decoder self-attention (causal prefill, cached
//      steps) and cross-attention — whisper.cpp's flash_attn.
//   S3 cross-attention K/V for ALL decoder layers projected by ONE matmul
//      pair per window (concatenated weights), stored head-split
//      [B, H, 1500, hd] once — whisper.cpp's kv_cross / vLLM's
//      encoder-prefill-only cross KV.
//   S2 the single-token decoder step — embed → 4 layers → ln → logits →
//      logit filters — is ONE mx.compile'd, shapeless closure replayed
//      natively (src/mlx/compile.ts; the LLM compiled-decode pattern).
//      Per-step state crosses as small int32 arrays (position, last two
//      tokens, last timestamp, at-sample-begin) so the graph never
//      changes; the growing self-KV enters as inputs (concat in-graph).
//   GELU: the four separate ops instead of the compiled fused kernel the
//      faithful path needs for bit-exactness (measured equal; fewer traces).
//   S4 logit filters (suppress sets, blank, timestamp rules incl. the
//      openai monotonic rule and the timestamp-probability rule) are
//      device-side broadcast ops inside that closure — no 200 KB host
//      mask upload per step.
// Beam rows attend to the single encoder output through broadcasting;
// cache reorders are `take` on axis 0 between steps (openai/whisper.cpp
// seq_cp equivalent).

import { MlxArray } from "../mlx/array";
import { CompiledFunction } from "../mlx/compile";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import type { WhisperModel } from "../model/whisper";

export interface FastFilterConfig {
  nVocab: number;
  eot: number;
  timestampBegin: number;
  noTimestamps: number;
  /** Ids masked at every step (non-speech + task/special tokens). */
  suppressIds: number[];
  /** Ids masked at the first sampled position (blank + eot), or null. */
  blankIds: number[] | null;
  useTimestampRules: boolean;
  maxInitialTimestampIndex: number | null;
}

/** Cache layout of the fast path: head-split self K/V [B, H, T, hd] per
 *  layer; cross K/V [Bc, H, 1500, hd] per layer (Bc = 1 for one window). */
export class FastKvCache {
  k: MlxArray[] = [];
  v: MlxArray[] = [];
  crossK: MlxArray[] = [];
  crossV: MlxArray[] = [];
  get offset(): number {
    return this.k[0]?.shape[2] ?? 0;
  }
  rearrange(indices: number[]): void {
    if (indices.every((x, i) => x === i)) return;
    const idx = ops.fromInt32(indices, [indices.length]);
    for (let l = 0; l < this.k.length; l++) {
      const nk = ops.takeAxis(this.k[l]!, idx, 0);
      const nv = ops.takeAxis(this.v[l]!, idx, 0);
      this.k[l]!.dispose();
      this.v[l]!.dispose();
      this.k[l] = nk;
      this.v[l] = nv;
    }
    idx.dispose();
  }
  dispose(): void {
    for (const a of [...this.k, ...this.v, ...this.crossK, ...this.crossV]) a.dispose();
    this.k = []; this.v = []; this.crossK = []; this.crossV = [];
  }
}

const dispose = (old: MlxArray, next: MlxArray): MlxArray => {
  old.dispose();
  return next;
};

export class WhisperFastPath {
  readonly model: WhisperModel;
  readonly #H: number;
  readonly #hd: number;
  readonly #L: number;
  /** Encoder per-layer fused [D, 3D] q/k/v weightᵀ and [3D] bias (k has none). */
  readonly #encQkv = new Map<number, { wT: MlxArray; b: MlxArray }>();
  #crossWkT: MlxArray | null = null;
  #crossWvT: MlxArray | null = null;
  #crossBv: MlxArray | null = null;
  #encPos: MlxArray | null = null;
  readonly #steps = new Map<string, CompiledFunction>();
  #negInf: MlxArray | null = null;

  constructor(model: WhisperModel) {
    this.model = model;
    this.#H = model.dims.nTextHead;
    this.#hd = model.dims.nTextState / model.dims.nTextHead;
    this.#L = model.dims.nTextLayer;
  }

  // --- helpers ------------------------------------------------------------------

  #split(x: MlxArray, B: number, T: number, H: number, hd: number): MlxArray {
    let h = ops.reshape(x, [B, T, H, hd]);
    h = dispose(h, ops.transposeAxes(h, [0, 2, 1, 3]));
    return h;
  }

  #merge(x: MlxArray, B: number, T: number, D: number): MlxArray {
    let h = ops.transposeAxes(x, [0, 2, 1, 3]);
    h = dispose(h, ops.reshape(h, [B, T, D]));
    return h;
  }

  /** Attention with fused SDPA; k/v may carry batch 1 against B queries
   *  (broadcast materialized for the fused kernel only when needed). */
  #attend(qh: MlxArray, kh: MlxArray, vh: MlxArray, causal: boolean): MlxArray {
    const scale = this.#hd ** -0.5;
    const B = qh.shape[0]!;
    if (kh.shape[0] === B) return ops.sdpa(qh, kh, vh, scale, causal ? "causal" : "");
    // beams over one encoder output: plain matmul attention broadcasts
    // the batch for free; the fused kernel would need B copies.
    const kT = ops.transposeAxes(kh, [0, 1, 3, 2]);
    const s = ops.scalarLike(scale, qh);
    let qk = ops.matmul(qh, kT);
    kT.dispose();
    qk = dispose(qk, ops.mul(qk, s));
    s.dispose();
    const w = ops.softmaxAxis(qk, -1, true);
    qk.dispose();
    const o = ops.matmul(w, vh);
    w.dispose();
    return o;
  }

  // --- encoder ------------------------------------------------------------------

  /** One gemm for q/k/v instead of three (whisper.cpp fuses these too). */
  #encoderQkv(layer: number): { wT: MlxArray; b: MlxArray } {
    let e = this.#encQkv.get(layer);
    if (e) return e;
    const m = this.model;
    const p = `encoder.blocks.${layer}.attn`;
    const wT = ops.concatAxis([m.weightT(`${p}.query.weight`), m.weightT(`${p}.key.weight`), m.weightT(`${p}.value.weight`)], 1);
    const zeroB = ops.zeros([m.dims.nAudioState], m.dtype);
    const b = ops.concatAxis([m.weight(`${p}.query.bias`), zeroB, m.weight(`${p}.value.bias`)], 0);
    zeroB.dispose();
    ops.evalAll([wT, b]);
    e = { wT, b };
    this.#encQkv.set(layer, e);
    return e;
  }

  #sinusoids(): MlxArray {
    if (this.#encPos) return this.#encPos;
    const { nAudioCtx: length, nAudioState: channels } = this.model.dims;
    const half = channels / 2;
    const inc = Math.log(10000) / (half - 1);
    const ar = ops.arange(0, half, 1, Dtype.int32);
    const negInc = MlxArray.fromFloat32(new Float32Array([-inc]), []);
    let inv = ops.mul(ar, negInc);
    ar.dispose(); negInc.dispose();
    inv = dispose(inv, ops.exp(inv));
    inv = dispose(inv, ops.reshape(inv, [1, half]));
    let pos = ops.arange(0, length, 1, Dtype.int32);
    pos = dispose(pos, ops.reshape(pos, [length, 1]));
    const scaled = ops.mul(pos, inv);
    pos.dispose(); inv.dispose();
    const s = ops.sin(scaled);
    const c = ops.cos(scaled);
    scaled.dispose();
    let pe = ops.concatAxis([s, c], 1);
    s.dispose(); c.dispose();
    pe = dispose(pe, pe.astype(this.model.dtype));
    this.#encPos = pe;
    return pe;
  }

  /** AudioEncoder with fused SDPA: mel [B, 3000, n_mels] → [B, 1500, D].
   *  `audioCtx` (Lab, whisper.cpp `-ac`): encode only the first
   *  2·audioCtx mel frames → [B, audioCtx, D]; the positional table is
   *  truncated to match. Cheaper for short clips, NOT the trained context. */
  encode(mel: MlxArray, audioCtx: number | null = null): MlxArray {
    const m = this.model;
    const d = m.dims;
    const H = d.nAudioHead;
    const hd = d.nAudioState / H;
    let input = mel;
    let ownInput = false;
    if (audioCtx !== null && audioCtx < d.nAudioCtx) {
      input = mel.slice([0, 0, 0], [mel.shape[0]!, 2 * audioCtx, mel.shape[2]!]);
      ownInput = true;
    }
    let x = ops.conv1d(input, m.weight("encoder.conv1.weight"), 1, 1);
    if (ownInput) input.dispose();
    x = dispose(x, ops.add(x, m.weight("encoder.conv1.bias")));
    x = dispose(x, ops.geluPrecise(x));
    x = dispose(x, ops.conv1d(x, m.weight("encoder.conv2.weight"), 2, 1));
    x = dispose(x, ops.add(x, m.weight("encoder.conv2.bias")));
    x = dispose(x, ops.geluPrecise(x));
    const pe = this.#sinusoids();
    if (x.shape[1] !== d.nAudioCtx) {
      const peT = pe.slice([0, 0], [x.shape[1]!, d.nAudioState]);
      x = dispose(x, ops.add(x, peT));
      peT.dispose();
    } else x = dispose(x, ops.add(x, pe));
    const [B, T, D] = x.shape as [number, number, number];
    // Measured dead ends (M1 Max, 2026-09-15, interleaved A/B, median of 4):
    // padding MLP rows to 1536 for gemm tile alignment (isolated gemm +25 %,
    // whole encoder 0 %) and the unfused-vs-compiled GELU (0 %). The encoder
    // is bound by its fp16 gemms at ~7–8 TFLOPS; ~290 ms per window here
    // vs mlx-whisper's 298.
    for (let i = 0; i < d.nAudioLayer; i++) {
      const p = `encoder.blocks.${i}`;
      const ln = m.layerNorm(x, `${p}.attn_ln`);
      const { wT, b } = this.#encoderQkv(i);
      const qkv = ops.addmm(b, ln, wT);
      ln.dispose();
      const q = qkv.slice([0, 0, 0], [B, T, D]);
      const k = qkv.slice([0, 0, D], [B, T, 2 * D]);
      const v = qkv.slice([0, 0, 2 * D], [B, T, 3 * D]);
      qkv.dispose();
      const qh = this.#split(q, B, T, H, hd); q.dispose();
      const kh = this.#split(k, B, T, H, hd); k.dispose();
      const vh = this.#split(v, B, T, H, hd); v.dispose();
      let o = ops.sdpa(qh, kh, vh, hd ** -0.5, "");
      qh.dispose(); kh.dispose(); vh.dispose();
      o = dispose(o, this.#merge(o, B, T, D));
      o = dispose(o, m.linear(o, `${p}.attn.out`));
      x = dispose(x, ops.add(x, o));
      o.dispose();
      let h = m.layerNorm(x, `${p}.mlp_ln`);
      h = dispose(h, m.linear(h, `${p}.mlp1`));
      h = dispose(h, ops.geluPrecise(h));
      h = dispose(h, m.linear(h, `${p}.mlp2`));
      x = dispose(x, ops.add(x, h));
      h.dispose();
    }
    x = dispose(x, m.layerNorm(x, "encoder.ln_post"));
    return x;
  }

  // --- cross K/V (once per window) ---------------------------------------------

  #crossWeights(): { wkT: MlxArray; wvT: MlxArray; bv: MlxArray } {
    if (!this.#crossWkT) {
      const m = this.model;
      const ks: MlxArray[] = [];
      const vs: MlxArray[] = [];
      const bs: MlxArray[] = [];
      for (let l = 0; l < this.#L; l++) {
        ks.push(m.weightT(`decoder.blocks.${l}.cross_attn.key.weight`));
        vs.push(m.weightT(`decoder.blocks.${l}.cross_attn.value.weight`));
        bs.push(m.weight(`decoder.blocks.${l}.cross_attn.value.bias`));
      }
      this.#crossWkT = ops.concatAxis(ks, 1); // [D, L·D]
      this.#crossWvT = ops.concatAxis(vs, 1);
      this.#crossBv = ops.concatAxis(bs, 0); // [L·D]
      ops.evalAll([this.#crossWkT, this.#crossWvT, this.#crossBv]);
    }
    return { wkT: this.#crossWkT!, wvT: this.#crossWvT!, bv: this.#crossBv! };
  }

  /** Project the encoder output into every decoder layer's cross K/V with
   *  one matmul pair; fills `cache.crossK/V` head-split. */
  crossKv(features: MlxArray, cache: FastKvCache): void {
    const { wkT, wvT, bv } = this.#crossWeights();
    const [Bc, Tc] = features.shape as [number, number, number];
    const D = this.model.dims.nTextState;
    const kAll = ops.matmul(features, wkT);
    const vAll = ops.addmm(bv, features, wvT);
    for (let l = 0; l < this.#L; l++) {
      const k = kAll.slice([0, 0, l * D], [Bc, Tc, (l + 1) * D]);
      const v = vAll.slice([0, 0, l * D], [Bc, Tc, (l + 1) * D]);
      const kh = this.#split(k, Bc, Tc, this.#H, this.#hd);
      const vh = this.#split(v, Bc, Tc, this.#H, this.#hd);
      k.dispose(); v.dispose();
      // materialize once so every step reads contiguous tensors
      cache.crossK.push(dispose(kh, ops.contiguous(kh)));
      cache.crossV.push(dispose(vh, ops.contiguous(vh)));
    }
    kAll.dispose();
    vAll.dispose();
    ops.evalAll([...cache.crossK, ...cache.crossV]);
  }

  // --- decoder layers ---------------------------------------------------------------

  /** One decoder layer. `selfK/selfV` are the cache prefix (or null);
   *  returns the new full K/V for the caller to store. */
  #layer(
    x: MlxArray, l: number, selfK: MlxArray | null, selfV: MlxArray | null,
    crossK: MlxArray, crossV: MlxArray, causal: boolean,
  ): { x: MlxArray; k: MlxArray; v: MlxArray } {
    const m = this.model;
    const p = `decoder.blocks.${l}`;
    const [B, T, D] = x.shape as [number, number, number];
    const ln = m.layerNorm(x, `${p}.attn_ln`);
    const q = m.linear(ln, `${p}.attn.query`);
    const k = m.linear(ln, `${p}.attn.key`, false);
    const v = m.linear(ln, `${p}.attn.value`);
    ln.dispose();
    const qh = this.#split(q, B, T, this.#H, this.#hd); q.dispose();
    let kh = this.#split(k, B, T, this.#H, this.#hd); k.dispose();
    let vh = this.#split(v, B, T, this.#H, this.#hd); v.dispose();
    if (selfK && selfV) {
      kh = dispose(kh, ops.concatAxis([selfK, kh], 2));
      vh = dispose(vh, ops.concatAxis([selfV, vh], 2));
    }
    let o = this.#attend(qh, kh, vh, causal);
    qh.dispose();
    o = dispose(o, this.#merge(o, B, T, D));
    o = dispose(o, m.linear(o, `${p}.attn.out`));
    let h = ops.add(x, o);
    o.dispose();
    const cln = m.layerNorm(h, `${p}.cross_attn_ln`);
    const cq = m.linear(cln, `${p}.cross_attn.query`);
    cln.dispose();
    const cqh = this.#split(cq, B, T, this.#H, this.#hd); cq.dispose();
    let co = this.#attend(cqh, crossK, crossV, false);
    cqh.dispose();
    co = dispose(co, this.#merge(co, B, T, D));
    co = dispose(co, m.linear(co, `${p}.cross_attn.out`));
    h = dispose(h, ops.add(h, co));
    co.dispose();
    let f = m.layerNorm(h, `${p}.mlp_ln`);
    f = dispose(f, m.linear(f, `${p}.mlp1`));
    f = dispose(f, ops.geluPrecise(f));
    f = dispose(f, m.linear(f, `${p}.mlp2`));
    h = dispose(h, ops.add(h, f));
    f.dispose();
    return { x: h, k: kh, v: vh };
  }

  #embed(tokens: MlxArray, offsetIdx: MlxArray): MlxArray {
    const m = this.model;
    const T = tokens.shape[1]!;
    let x = ops.takeAxis(m.weight("decoder.token_embedding.weight"), tokens, 0);
    // positional rows [offset, offset+T) gathered by an index array so the
    // graph stays position-agnostic
    let pos: MlxArray;
    if (T === 1) pos = ops.takeAxis(m.weight("decoder.positional_embedding"), offsetIdx, 0); // [1, D]
    else {
      const ar = ops.arange(0, T, 1, Dtype.int32);
      const idx = ops.add(ar, offsetIdx);
      ar.dispose();
      pos = ops.takeAxis(m.weight("decoder.positional_embedding"), idx, 0); // [T, D]
      idx.dispose();
    }
    x = dispose(x, ops.add(x, pos));
    pos.dispose();
    return x;
  }

  #logits(x: MlxArray): MlxArray {
    const m = this.model;
    let h = m.layerNorm(x, "decoder.ln");
    h = dispose(h, ops.matmul(h, m.weightT("decoder.token_embedding.weight")));
    return h;
  }

  /** Eager multi-token prefill (initial tokens): fills the self-KV cache and
   *  returns logits [B, T, V] in the weight dtype. */
  prefill(tokens: MlxArray, cache: FastKvCache): MlxArray {
    const offsetIdx = ops.fromInt32([cache.offset], [1]);
    let x = this.#embed(tokens, offsetIdx);
    offsetIdx.dispose();
    for (let l = 0; l < this.#L; l++) {
      const r = this.#layer(x, l, cache.k[l] ?? null, cache.v[l] ?? null, cache.crossK[l]!, cache.crossV[l]!, true);
      x.dispose();
      x = r.x;
      cache.k[l]?.dispose();
      cache.v[l]?.dispose();
      cache.k[l] = r.k;
      cache.v[l] = r.v;
    }
    const logits = this.#logits(x);
    x.dispose();
    return logits;
  }

  // --- compiled single-token step -----------------------------------------------------

  #negInfArr(): MlxArray {
    return this.#negInf ??= MlxArray.fromFloat32(new Float32Array([-Infinity]), []);
  }

  /** Device-side logit filters (see header). `state` rows: lastTok,
   *  penultTok (-1 = none), lastTs (-1 = none) as int32 [B]; atBegin int32 [1]. */
  #filters(logits: MlxArray, cfg: FastFilterConfig, state: { lastTok: MlxArray; penultTok: MlxArray; lastTs: MlxArray; atBegin: MlxArray }): MlxArray {
    const V = cfg.nVocab;
    const B = logits.shape[0]!;
    const negInf = this.#negInfArr();
    const zero = ops.scalarLike(0, logits);
    const maskConst = new Float32Array(V);
    for (const id of cfg.suppressIds) maskConst[id] = -Infinity;
    if (cfg.useTimestampRules) maskConst[cfg.noTimestamps] = -Infinity;
    const constMask = MlxArray.fromFloat32(maskConst, [1, V]);
    let base = ops.add(logits, constMask);
    constMask.dispose();
    const atBegin = ops.greater(state.atBegin, ops.fromInt32([0], [1])); // [1] bool
    if (cfg.blankIds) {
      const blank = new Float32Array(V);
      for (const id of cfg.blankIds) blank[id] = -Infinity;
      const blankMask = MlxArray.fromFloat32(blank, [1, V]);
      const bm = ops.where(atBegin, blankMask, zero);
      blankMask.dispose();
      base = dispose(base, ops.add(base, bm));
      bm.dispose();
    }
    if (!cfg.useTimestampRules) {
      atBegin.dispose(); zero.dispose();
      return base;
    }
    const idx = ops.arange(0, V, 1, Dtype.int32);
    const idx2 = ops.reshape(idx, [1, V]);
    idx.dispose();
    const c = (n: number) => ops.fromInt32([n], [1]);
    const tsBegin = c(cfg.timestampBegin);
    const eot = c(cfg.eot);
    const minusOne = c(-1);
    const one = c(1);
    const col = (a: MlxArray) => ops.reshape(a, [B, 1]);
    const lastTok = col(state.lastTok);
    const penultTok = col(state.penultTok);
    const lastTs = col(state.lastTs);
    const lastWas = ops.greaterEqual(lastTok, tsBegin); // [B,1]
    const penultNone = ops.less(penultTok, c(0));
    const penultGe = ops.greaterEqual(penultTok, tsBegin);
    const penultWas = ops.logicalOr(penultNone, penultGe);
    const notPenult = ops.logicalNot(penultWas);
    const idxGeTs = ops.greaterEqual(idx2, tsBegin); // [1,V]
    const idxLtEot = ops.less(idx2, eot);
    const idxLtTs = ops.less(idx2, tsBegin);
    // m1: pairs rule
    const a1 = ops.logicalAnd(lastWas, penultWas);
    const a2 = ops.logicalAnd(lastWas, notPenult);
    const m1a = ops.logicalAnd(a1, idxGeTs);
    const m1b = ops.logicalAnd(a2, idxLtEot);
    let m = ops.logicalOr(m1a, m1b);
    // m2: monotonic timestamps
    const hasTs = ops.greaterEqual(lastTs, c(0));
    const lastTsPlus = ops.add(lastTs, one);
    const tsLast = ops.where(a2, lastTs, lastTsPlus);
    const idxLtLast = ops.less(idx2, tsLast);
    const m2a = ops.logicalAnd(hasTs, idxGeTs);
    const m2 = ops.logicalAnd(m2a, idxLtLast);
    m = dispose(m, ops.logicalOr(m, m2));
    // m3: at sample begin — timestamps only, capped by max_initial_timestamp
    let m3 = idxLtTs;
    let capMask: MlxArray | null = null;
    if (cfg.maxInitialTimestampIndex !== null) {
      const lastAllowed = c(cfg.timestampBegin + cfg.maxInitialTimestampIndex);
      capMask = ops.greater(idx2, lastAllowed);
      lastAllowed.dispose();
      m3 = ops.logicalOr(idxLtTs, capMask);
    }
    const m3b = ops.logicalAnd(atBegin, m3);
    m = dispose(m, ops.logicalOr(m, m3b));
    const ruleMask = ops.where(m, negInf, zero);
    // probability rule on the PRE-rule logits (the oracle's `logits`)
    // (no Slice inside a shapeless compile — MLX cannot infer its output
    // shape; mask the complementary halves to -inf instead)
    const lse = ops.logsumexpAxis(base, -1, true);
    const logprobs = ops.sub(base, lse);
    const tsPart = ops.where(idxGeTs, logprobs, negInf);
    const tsLp = ops.logsumexpAxis(tsPart, -1, true);
    const textPart = ops.where(idxLtTs, logprobs, negInf);
    const maxText = ops.maxAxis(textPart, -1, true);
    const cond = ops.greater(tsLp, maxText); // [B,1]
    const condMask = ops.logicalAnd(cond, idxLtTs);
    const probMask = ops.where(condMask, negInf, zero);
    let out = ops.add(base, ruleMask);
    out = dispose(out, ops.add(out, probMask));
    for (const a of [base, atBegin, zero, idx2, tsBegin, eot, minusOne, one, lastTok, penultTok, lastTs, lastWas, penultNone,
      penultGe, penultWas, notPenult, idxGeTs, idxLtEot, idxLtTs, a1, a2, m1a, m1b, m, hasTs, lastTsPlus, tsLast, idxLtLast,
      m2a, m2, m3b, ruleMask, lse, logprobs, tsPart, tsLp, textPart, maxText, cond, condMask, probMask]) a.dispose();
    if (capMask) { capMask.dispose(); m3.dispose(); }
    return out;
  }

  /** Greedy variant: the compiled graph also picks argmax(filtered) and its
   *  log-prob, so the next step can consume the token ARRAY without a host
   *  round trip (S5 pipelining: the host reads the previous step's token
   *  while the GPU runs the current one — the oracle's async_eval lag). */
  #greedyStep(B: number, Bc: number, cfg: FastFilterConfig): CompiledFunction {
    const key = `greedy:${B}:${Bc}:${cfg.suppressIds.join(",")}:${cfg.blankIds?.join(",") ?? "-"}:${cfg.useTimestampRules}:${cfg.maxInitialTimestampIndex}`;
    let fn = this.#steps.get(key);
    if (fn) return fn;
    const L = this.#L;
    fn = new CompiledFunction((inputs) => {
      // inputs: [tok [B] int32, offsetIdx [1], lastTok [B], penultTok [B], lastTs [B], K.., V.., CK.., CV..]
      const [tokFlat, offsetIdx, lastTok, penultTok, lastTs] = inputs as [MlxArray, MlxArray, MlxArray, MlxArray, MlxArray];
      const K = inputs.slice(5, 5 + L);
      const Vv = inputs.slice(5 + L, 5 + 2 * L);
      const CK = inputs.slice(5 + 2 * L, 5 + 3 * L);
      const CV = inputs.slice(5 + 3 * L, 5 + 4 * L);
      const tok = ops.reshape(tokFlat, [B, 1]);
      let x = this.#embed(tok, offsetIdx);
      tok.dispose();
      const newK: MlxArray[] = [];
      const newV: MlxArray[] = [];
      for (let l = 0; l < L; l++) {
        const r = this.#layer(x, l, K[l]!, Vv[l]!, CK[l]!, CV[l]!, false);
        x.dispose();
        x = r.x;
        newK.push(r.k);
        newV.push(r.v);
      }
      const logits16 = this.#logits(x);
      x.dispose();
      const V = cfg.nVocab;
      let last = ops.reshape(logits16, [B, V]);
      logits16.dispose();
      last = dispose(last, last.astype(Dtype.float32));
      const atBegin = ops.fromInt32([0], [1]); // steps ≥ 1 are never at sample_begin
      const filtered = this.#filters(last, cfg, { lastTok, penultTok, lastTs, atBegin });
      atBegin.dispose();
      let next = ops.argmaxAxis(filtered, -1);
      next = dispose(next, next.astype(Dtype.int32));
      const lse = ops.logsumexpAxis(filtered, -1, true);
      const logprobs = ops.sub(filtered, lse);
      lse.dispose();
      const idx = ops.reshape(next, [B, 1]);
      let lp = ops.takeAlongAxis(logprobs, idx, 1);
      idx.dispose();
      logprobs.dispose();
      lp = dispose(lp, ops.reshape(lp, [B]));
      // timestamp state for the NEXT step: last := next, penult := last,
      // lastTs := next if it is a timestamp else unchanged
      const tsBegin = ops.fromInt32([cfg.timestampBegin], [1]);
      const isTs = ops.greaterEqual(next, tsBegin);
      const newLastTs = ops.where(isTs, next, lastTs);
      tsBegin.dispose();
      isTs.dispose();
      filtered.dispose();
      return [last, next, lp, newLastTs, ...newK, ...newV];
    }, true);
    this.#steps.set(key, fn);
    return fn;
  }

  /** Pipelined greedy step: consumes/produces token + timestamp-state ARRAYS.
   *  Returns owned arrays; the caller reads `next` lazily (one-step lag). */
  greedyStep(
    st: { tok: MlxArray; lastTok: MlxArray; penultTok: MlxArray; lastTs: MlxArray },
    cache: FastKvCache, cfg: FastFilterConfig,
  ): { pre: MlxArray; next: MlxArray; lp: MlxArray; lastTs: MlxArray } {
    const B = st.tok.shape[0]!;
    const Bc = cache.crossK[0]!.shape[0]!;
    const fn = this.#greedyStep(B, Bc, cfg);
    const offsetIdx = ops.fromInt32([cache.offset], [1]);
    const outs = fn.apply([st.tok, offsetIdx, st.lastTok, st.penultTok, st.lastTs, ...cache.k, ...cache.v, ...cache.crossK, ...cache.crossV]);
    offsetIdx.dispose();
    const L = this.#L;
    for (let l = 0; l < L; l++) {
      cache.k[l]!.dispose();
      cache.v[l]!.dispose();
      cache.k[l] = outs[4 + l]!;
      cache.v[l] = outs[4 + L + l]!;
    }
    return { pre: outs[0]!, next: outs[1]!, lp: outs[2]!, lastTs: outs[3]! };
  }

  /** Beam variant: top-(k) indices/values of the filtered log-probs come
   *  out of the graph (one host readback per step, no partition ops outside). */
  #beamStep(B: number, Bc: number, k: number, cfg: FastFilterConfig): CompiledFunction {
    const key = `beam${k}:${B}:${Bc}:${cfg.suppressIds.join(",")}:${cfg.blankIds?.join(",") ?? "-"}:${cfg.useTimestampRules}:${cfg.maxInitialTimestampIndex}`;
    let fn = this.#steps.get(key);
    if (fn) return fn;
    const L = this.#L;
    fn = new CompiledFunction((inputs) => {
      const [tokFlat, offsetIdx, lastTok, penultTok, lastTs] = inputs as [MlxArray, MlxArray, MlxArray, MlxArray, MlxArray];
      const K = inputs.slice(5, 5 + L);
      const Vv = inputs.slice(5 + L, 5 + 2 * L);
      const CK = inputs.slice(5 + 2 * L, 5 + 3 * L);
      const CV = inputs.slice(5 + 3 * L, 5 + 4 * L);
      const tok = ops.reshape(tokFlat, [B, 1]);
      let x = this.#embed(tok, offsetIdx);
      tok.dispose();
      const newK: MlxArray[] = [];
      const newV: MlxArray[] = [];
      for (let l = 0; l < L; l++) {
        const r = this.#layer(x, l, K[l]!, Vv[l]!, CK[l]!, CV[l]!, false);
        x.dispose();
        x = r.x;
        newK.push(r.k);
        newV.push(r.v);
      }
      const logits16 = this.#logits(x);
      x.dispose();
      const V = cfg.nVocab;
      let last = ops.reshape(logits16, [B, V]);
      logits16.dispose();
      last = dispose(last, last.astype(Dtype.float32));
      const atBegin = ops.fromInt32([0], [1]);
      const filtered = this.#filters(last, cfg, { lastTok, penultTok, lastTs, atBegin });
      atBegin.dispose();
      const lse = ops.logsumexpAxis(filtered, -1, true);
      const logprobs = ops.sub(filtered, lse);
      lse.dispose();
      filtered.dispose();
      // top-k: sort descending is overkill; argpartition on the negation
      // then gather. (Slice with constant bounds is fine here: its output
      // shape does not depend on a varying dimension… but shapeless
      // compile still refuses Slice, so use take with a constant index.)
      const neg = ops.neg(logprobs);
      const part = ops.argpartitionAxis(neg, k - 1, -1);
      neg.dispose();
      const firstK = ops.arange(0, k, 1, Dtype.int32);
      let idx = ops.takeAxis(part, firstK, 1); // [B, k]
      part.dispose();
      firstK.dispose();
      idx = dispose(idx, idx.astype(Dtype.int32));
      const vals = ops.takeAlongAxis(logprobs, idx, 1);
      logprobs.dispose();
      return [last, idx, vals, ...newK, ...newV];
    }, true);
    this.#steps.set(key, fn);
    return fn;
  }

  /** One compiled beam step: returns the pre-filter logits and the top-k
   *  (indices, log-probs) per row; updates the cache in place. */
  beamStep(
    tokens: number[], cache: FastKvCache, cfg: FastFilterConfig, k: number,
    state: { lastTok: number[]; penultTok: number[]; lastTs: number[] },
  ): { pre: MlxArray; idx: MlxArray; vals: MlxArray } {
    const B = tokens.length;
    const Bc = cache.crossK[0]!.shape[0]!;
    const fn = this.#beamStep(B, Bc, k, cfg);
    const tok = ops.fromInt32(tokens, [B]);
    const offsetIdx = ops.fromInt32([cache.offset], [1]);
    const lastTok = ops.fromInt32(state.lastTok, [B]);
    const penultTok = ops.fromInt32(state.penultTok, [B]);
    const lastTs = ops.fromInt32(state.lastTs, [B]);
    const outs = fn.apply([tok, offsetIdx, lastTok, penultTok, lastTs, ...cache.k, ...cache.v, ...cache.crossK, ...cache.crossV]);
    for (const a of [tok, offsetIdx, lastTok, penultTok, lastTs]) a.dispose();
    const L = this.#L;
    for (let l = 0; l < L; l++) {
      cache.k[l]!.dispose();
      cache.v[l]!.dispose();
      cache.k[l] = outs[3 + l]!;
      cache.v[l] = outs[3 + L + l]!;
    }
    // Compiled outputs may be strided views; host readback walks memory
    // linearly, so materialize the small top-k arrays.
    const idx = ops.contiguous(outs[1]!);
    const vals = ops.contiguous(outs[2]!);
    outs[1]!.dispose();
    outs[2]!.dispose();
    return { pre: outs[0]!, idx, vals };
  }

  /** Compiled step for a fixed (B, Bc, filter config) signature. Inputs:
   *  [tok [B,1], offsetIdx [1], lastTok [B], penultTok [B], lastTs [B],
   *  atBegin [1], K_0..K_{L-1}, V_0.., CK_0.., CV_0..]. Outputs:
   *  [preLogits [B,V] f32, filtered [B,V] f32, newK_0.., newV_0..]. */
  #step(B: number, Bc: number, cfg: FastFilterConfig): CompiledFunction {
    const key = `${B}:${Bc}:${cfg.suppressIds.join(",")}:${cfg.blankIds?.join(",") ?? "-"}:${cfg.useTimestampRules}:${cfg.maxInitialTimestampIndex}`;
    let fn = this.#steps.get(key);
    if (fn) return fn;
    const L = this.#L;
    fn = new CompiledFunction((inputs) => {
      const [tok, offsetIdx, lastTok, penultTok, lastTs, atBegin] = inputs as [MlxArray, MlxArray, MlxArray, MlxArray, MlxArray, MlxArray];
      const K = inputs.slice(6, 6 + L);
      const Vv = inputs.slice(6 + L, 6 + 2 * L);
      const CK = inputs.slice(6 + 2 * L, 6 + 3 * L);
      const CV = inputs.slice(6 + 3 * L, 6 + 4 * L);
      let x = this.#embed(tok, offsetIdx);
      const newK: MlxArray[] = [];
      const newV: MlxArray[] = [];
      for (let l = 0; l < L; l++) {
        const r = this.#layer(x, l, K[l]!, Vv[l]!, CK[l]!, CV[l]!, false);
        x.dispose();
        x = r.x;
        newK.push(r.k);
        newV.push(r.v);
      }
      const logits16 = this.#logits(x);
      x.dispose();
      const V = cfg.nVocab;
      let last = ops.reshape(logits16, [B, V]);
      logits16.dispose();
      last = dispose(last, last.astype(Dtype.float32));
      const filtered = this.#filters(last, cfg, { lastTok, penultTok, lastTs, atBegin });
      return [last, filtered, ...newK, ...newV];
    }, true);
    this.#steps.set(key, fn);
    return fn;
  }

  /** Run one compiled decode step; updates `cache` in place. Returns the
   *  pre-filter and filtered last-position logits [B, V] f32 (owned). */
  step(
    tokens: number[], cache: FastKvCache, cfg: FastFilterConfig,
    state: { lastTok: number[]; penultTok: number[]; lastTs: number[]; atBegin: boolean },
  ): { pre: MlxArray; filtered: MlxArray } {
    const B = tokens.length;
    const Bc = cache.crossK[0]!.shape[0]!;
    const fn = this.#step(B, Bc, cfg);
    const tok = ops.fromInt32(tokens, [B, 1]);
    const offsetIdx = ops.fromInt32([cache.offset], [1]);
    const lastTok = ops.fromInt32(state.lastTok, [B]);
    const penultTok = ops.fromInt32(state.penultTok, [B]);
    const lastTs = ops.fromInt32(state.lastTs, [B]);
    const atBegin = ops.fromInt32([state.atBegin ? 1 : 0], [1]);
    const outs = fn.apply([tok, offsetIdx, lastTok, penultTok, lastTs, atBegin, ...cache.k, ...cache.v, ...cache.crossK, ...cache.crossV]);
    for (const a of [tok, offsetIdx, lastTok, penultTok, lastTs, atBegin]) a.dispose();
    const L = this.#L;
    for (let l = 0; l < L; l++) {
      cache.k[l]!.dispose();
      cache.v[l]!.dispose();
      cache.k[l] = outs[2 + l]!;
      cache.v[l] = outs[2 + L + l]!;
    }
    return { pre: outs[0]!, filtered: outs[1]! };
  }

  dispose(): void {
    for (const e of this.#encQkv.values()) { e.wT.dispose(); e.b.dispose(); }
    this.#encQkv.clear();
    this.#crossWkT?.dispose(); this.#crossWvT?.dispose(); this.#crossBv?.dispose();
    this.#encPos?.dispose();
    this.#negInf?.dispose();
    for (const f of this.#steps.values()) f.dispose();
    this.#steps.clear();
  }
}
