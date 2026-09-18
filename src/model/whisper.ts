// Whisper (encoder-decoder speech recognition) — an op-for-op port of
// mlx-whisper's whisper.py (mlx-community/whisper-* checkpoints: fp16
// weights in a single weights.safetensors + config.json ModelDimensions).
// L1 gate: encoder output and per-step decoder logits bit-exact vs the
// pinned mlx-whisper oracle (tests/parity/whisper.test.ts).
//
// Graph (dtype = weight dtype, fp16 for the shipped artifacts):
//   encoder: mel [B,3000,n_mels] → conv1(k3,p1)+gelu → conv2(k3,s2,p1)+gelu
//            → + sinusoids(1500, D) → N × block(self-attn, mlp) → ln_post
//   decoder: tokens [B,T] → token_embedding + positional_embedding[offset:]
//            → N × block(causal self-attn w/ cache, cross-attn on the
//            encoder output w/ cross-KV cache, mlp) → ln → @ embeddingᵀ
//   gelu: mlx.nn.gelu is `@partial(mx.compile, shapeless=True)` in the
//         oracle — the FUSED kernel rounds differently from the four
//         separate ops (2% of conv1 outputs differ by an ulp), so the same
//         graph is compiled here too (bit-exact, verified 2026-09-15).
//   attention: q,k scaled by (D/H)^-0.25 each, qk in the weight dtype,
//              additive causal mask (-inf f16), precise softmax, no fused
//              kernels — the FAITHFUL path. The optimized path lives in
//              src/audio/whisper-fast.ts and is gated token-exact against
//              this one.
//
// mlx inline-temporary hazard (CLAUDE.md): every op result is held in a
// local and disposed; no nested `ops.foo(x.slice(...))` chains.

import type { ModelConfig } from "../config";
import { MlxArray } from "../mlx/array";
import { CompiledFunction } from "../mlx/compile";
import { WhisperFastPath } from "../audio/whisper-fast";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import type { Weights } from "../weights";

export interface WhisperDims {
  nMels: number;
  nAudioCtx: number;
  nAudioState: number;
  nAudioHead: number;
  nAudioLayer: number;
  nVocab: number;
  nTextCtx: number;
  nTextState: number;
  nTextHead: number;
  nTextLayer: number;
}

export function parseWhisperDims(raw: Record<string, unknown>): WhisperDims {
  const n = (k: string): number => {
    const v = raw[k];
    if (typeof v !== "number") throw new Error(`whisper config.json: missing numeric ${k}`);
    return v;
  };
  return {
    nMels: n("n_mels"), nAudioCtx: n("n_audio_ctx"), nAudioState: n("n_audio_state"),
    nAudioHead: n("n_audio_head"), nAudioLayer: n("n_audio_layer"), nVocab: n("n_vocab"),
    nTextCtx: n("n_text_ctx"), nTextState: n("n_text_state"), nTextHead: n("n_text_head"),
    nTextLayer: n("n_text_layer"),
  };
}

const dispose = (old: MlxArray, next: MlxArray): MlxArray => {
  old.dispose();
  return next;
};

/** Per-layer decoder state: self-attention K/V [B, T, D] (un-split, un-scaled,
 *  exactly what the oracle concatenates) and the cross-attention K/V computed
 *  once from the encoder output. */
export interface WhisperLayerCache {
  k: MlxArray | null;
  v: MlxArray | null;
  crossK: MlxArray | null;
  crossV: MlxArray | null;
}

export class WhisperKvCache {
  readonly layers: WhisperLayerCache[];
  constructor(nLayers: number) {
    this.layers = Array.from({ length: nLayers }, () => ({ k: null, v: null, crossK: null, crossV: null }));
  }
  /** Tokens already in the self-attention cache. */
  get offset(): number {
    return this.layers[0]?.k?.shape[1] ?? 0;
  }
  /** Beam reorder: keep rows `indices` (mx.take along axis 0). Cross K/V
   *  rows are identical across beams and are left untouched when they were
   *  broadcast from one audio (shape[0] === 1). */
  rearrange(indices: number[]): void {
    if (indices.every((v, i) => v === i)) return;
    const idx = ops.fromInt32(indices, [indices.length]);
    for (const l of this.layers) {
      if (l.k) l.k = dispose(l.k, ops.takeAxis(l.k, idx, 0));
      if (l.v) l.v = dispose(l.v, ops.takeAxis(l.v, idx, 0));
      if (l.crossK && l.crossK.shape[0] !== 1) l.crossK = dispose(l.crossK, ops.takeAxis(l.crossK, idx, 0));
      if (l.crossV && l.crossV.shape[0] !== 1) l.crossV = dispose(l.crossV, ops.takeAxis(l.crossV, idx, 0));
    }
    idx.dispose();
  }
  arrays(): MlxArray[] {
    const out: MlxArray[] = [];
    for (const l of this.layers) for (const a of [l.k, l.v, l.crossK, l.crossV]) if (a) out.push(a);
    return out;
  }
  dispose(): void {
    for (const l of this.layers) {
      l.k?.dispose(); l.v?.dispose(); l.crossK?.dispose(); l.crossV?.dispose();
      l.k = l.v = l.crossK = l.crossV = null;
    }
  }
}

export class WhisperModel {
  readonly dims: WhisperDims;
  readonly dtype: Dtype;
  readonly #w: Weights;
  /** [1500, D] encoder positional sinusoids (weight dtype). */
  #encPos: MlxArray | null = null;
  /** [n_text_ctx, n_text_ctx] additive causal mask (weight dtype, -inf). */
  #causalMask: MlxArray | null = null;
  /** Transposed weight views, cached per name. */
  readonly #transposed = new Map<string, MlxArray>();
  /** Compiled nn.gelu (see header). */
  #gelu: CompiledFunction | null = null;
  #fast: WhisperFastPath | null = null;

  /** The optimized execution path (src/audio/whisper-fast.ts), built lazily. */
  get fast(): WhisperFastPath {
    return this.#fast ??= new WhisperFastPath(this);
  }

  constructor(weights: Weights, config: ModelConfig) {
    this.#w = weights;
    this.dims = parseWhisperDims(config.raw as Record<string, unknown>);
    this.dtype = weights.tensor("decoder.token_embedding.weight").dtype;
  }

  get isMultilingual(): boolean {
    return this.dims.nVocab >= 51865;
  }
  get numLanguages(): number {
    return this.dims.nVocab - 51765 - (this.isMultilingual ? 1 : 0);
  }

  /** Alignment heads [(layer, head), …] from the checkpoint (word timestamps);
   *  falls back to every head of the last half of the decoder layers. */
  get alignmentHeads(): [number, number][] {
    if (this.#w.has("alignment_heads")) {
      const a = this.#w.tensor("alignment_heads");
      const flat = a.astype(Dtype.int32).toIntTokens();
      const out: [number, number][] = [];
      for (let i = 0; i + 1 < flat.length; i += 2) out.push([flat[i]!, flat[i + 1]!]);
      return out;
    }
    const out: [number, number][] = [];
    for (let l = Math.floor(this.dims.nTextLayer / 2); l < this.dims.nTextLayer; l++)
      for (let h = 0; h < this.dims.nTextHead; h++) out.push([l, h]);
    return out;
  }

  // --- primitives -----------------------------------------------------------

  #t(name: string): MlxArray {
    return this.#w.tensor(name);
  }

  /** Raw checkpoint tensor (borrowed; the fast path composes its own graphs). */
  weight(name: string): MlxArray {
    return this.#t(name);
  }

  /** Cached Wᵀ view (borrowed). */
  weightT(name: string): MlxArray {
    return this.#wT(name);
  }

  /** The compiled nn.gelu (shared with the faithful path). */
  gelu(x: MlxArray): MlxArray {
    return this.#geluCompiled(x);
  }

  layerNorm(x: MlxArray, prefix: string): MlxArray {
    return this.#layerNorm(x, prefix);
  }

  /** nn.Linear against a checkpoint weight (borrowed inputs, owned output). */
  linear(x: MlxArray, prefix: string, bias = true): MlxArray {
    return this.#linear(x, prefix, bias);
  }

  /** Wᵀ view, cached (transpose is a strided view, no copy). */
  #wT(name: string): MlxArray {
    let t = this.#transposed.get(name);
    if (!t) {
      t = ops.transposeAxes(this.#t(name), [1, 0]);
      this.#transposed.set(name, t);
    }
    return t;
  }

  /** nn.Linear: addmm(bias, x, Wᵀ) with bias, x @ Wᵀ without. */
  #linear(x: MlxArray, prefix: string, bias = true): MlxArray {
    const wT = this.#wT(`${prefix}.weight`);
    return bias ? ops.addmm(this.#t(`${prefix}.bias`), x, wT) : ops.matmul(x, wT);
  }

  /** nn.gelu — compiled, shapeless, same op graph as mlx.nn.activations.gelu:
   *  x * (1 + erf(x / sqrt(2))) / 2. */
  #geluCompiled(x: MlxArray): MlxArray {
    this.#gelu ??= new CompiledFunction(([a]) => {
      const s2 = ops.scalarLike(Math.SQRT2, a!);
      const xs = ops.div(a!, s2);
      const e = ops.erf(xs);
      const one = ops.scalarLike(1, a!);
      const e1 = ops.add(one, e);
      const xe = ops.mul(a!, e1);
      const two = ops.scalarLike(2, a!);
      return [ops.div(xe, two)];
    }, true);
    return this.#gelu.apply([x])[0]!;
  }

  #layerNorm(x: MlxArray, prefix: string): MlxArray {
    return ops.layerNorm(x, this.#t(`${prefix}.weight`), this.#t(`${prefix}.bias`), 1e-5);
  }

  /** MultiHeadAttention.__call__ + qkv_attention. Returns the projected
   *  output, the (un-split) k/v to cache, and optionally the raw qk. */
  #attention(
    x: MlxArray, prefix: string, nHead: number,
    opts: { xa?: MlxArray; mask?: MlxArray; kv?: [MlxArray, MlxArray] | null; crossKv?: [MlxArray, MlxArray] | null; wantQk?: boolean },
  ): { out: MlxArray; k: MlxArray; v: MlxArray; qk: MlxArray | null } {
    const q = this.#linear(x, `${prefix}.query`);
    let k: MlxArray;
    let v: MlxArray;
    if (!opts.xa) {
      k = this.#linear(x, `${prefix}.key`, false);
      v = this.#linear(x, `${prefix}.value`);
      if (opts.kv) {
        k = dispose(k, ops.concatAxis([opts.kv[0], k], 1));
        v = dispose(v, ops.concatAxis([opts.kv[1], v], 1));
      }
    } else if (!opts.crossKv) {
      k = this.#linear(opts.xa, `${prefix}.key`, false);
      v = this.#linear(opts.xa, `${prefix}.value`);
    } else {
      [k, v] = opts.crossKv;
    }
    const [B, T, D] = q.shape as [number, number, number];
    // k/v keep THEIR batch (the oracle reshapes with k.shape): beam rows
    // attend to one broadcast encoder output ([1, 1500, D]) via matmul
    // broadcasting instead of copying cross-K/V per beam.
    const Bk = k.shape[0]!;
    const Tk = k.shape[1]!;
    const hd = D / nHead;
    const scale = ops.scalarLike(hd ** -0.25, q);
    let qh = ops.reshape(q, [B, T, nHead, hd]);
    q.dispose();
    qh = dispose(qh, ops.transposeAxes(qh, [0, 2, 1, 3]));
    qh = dispose(qh, ops.mul(qh, scale));
    let kh = ops.reshape(k, [Bk, Tk, nHead, hd]);
    kh = dispose(kh, ops.transposeAxes(kh, [0, 2, 3, 1]));
    kh = dispose(kh, ops.mul(kh, scale));
    scale.dispose();
    let vh = ops.reshape(v, [Bk, Tk, nHead, hd]);
    vh = dispose(vh, ops.transposeAxes(vh, [0, 2, 1, 3]));
    let qk = ops.matmul(qh, kh);
    qh.dispose();
    kh.dispose();
    if (opts.mask) {
      const m = opts.mask.slice([0, 0], [T, T]);
      qk = dispose(qk, ops.add(qk, m));
      m.dispose();
    }
    const w = ops.softmaxAxis(qk, -1, true);
    let o = ops.matmul(w, vh);
    w.dispose();
    vh.dispose();
    o = dispose(o, ops.transposeAxes(o, [0, 2, 1, 3]));
    o = dispose(o, ops.reshape(o, [B, T, D]));
    const out = this.#linear(o, `${prefix}.out`);
    o.dispose();
    if (!opts.wantQk) {
      qk.dispose();
      return { out, k, v, qk: null };
    }
    return { out, k, v, qk };
  }

  #mlp(x: MlxArray, prefix: string): MlxArray {
    let h = this.#layerNorm(x, `${prefix}.mlp_ln`);
    h = dispose(h, this.#linear(h, `${prefix}.mlp1`));
    h = dispose(h, this.#geluCompiled(h));
    h = dispose(h, this.#linear(h, `${prefix}.mlp2`));
    return h;
  }

  // --- encoder ----------------------------------------------------------------

  #sinusoids(): MlxArray {
    if (this.#encPos) return this.#encPos;
    const { nAudioCtx: length, nAudioState: channels } = this.dims;
    const half = channels / 2;
    const inc = Math.log(10000) / (half - 1);
    const ar = ops.arange(0, half, 1, Dtype.int32);
    const negInc = MlxArray.fromFloat32(new Float32Array([-inc]), []);
    let inv = ops.mul(ar, negInc);
    ar.dispose();
    negInc.dispose();
    inv = dispose(inv, ops.exp(inv));
    inv = dispose(inv, ops.reshape(inv, [1, half]));
    let pos = ops.arange(0, length, 1, Dtype.int32);
    pos = dispose(pos, ops.reshape(pos, [length, 1]));
    const scaled = ops.mul(pos, inv);
    pos.dispose();
    inv.dispose();
    const s = ops.sin(scaled);
    const c = ops.cos(scaled);
    scaled.dispose();
    let pe = ops.concatAxis([s, c], 1);
    s.dispose();
    c.dispose();
    pe = dispose(pe, pe.astype(this.dtype));
    this.#encPos = pe;
    return pe;
  }

  /** AudioEncoder: mel [B, 3000, n_mels] (weight dtype) → [B, 1500, D]. */
  encode(mel: MlxArray, trace?: (name: string, a: MlxArray) => void): MlxArray {
    let x = ops.conv1d(mel, this.#t("encoder.conv1.weight"), 1, 1);
    x = dispose(x, ops.add(x, this.#t("encoder.conv1.bias")));
    x = dispose(x, this.#geluCompiled(x));
    trace?.("conv1", x);
    x = dispose(x, ops.conv1d(x, this.#t("encoder.conv2.weight"), 2, 1));
    x = dispose(x, ops.add(x, this.#t("encoder.conv2.bias")));
    x = dispose(x, this.#geluCompiled(x));
    if (x.shape[1] !== this.dims.nAudioCtx || x.shape[2] !== this.dims.nAudioState)
      throw new Error(`whisper encoder: incorrect audio shape ${JSON.stringify(x.shape)}`);
    x = dispose(x, ops.add(x, this.#sinusoids()));
    trace?.("conv2pos", x);
    for (let i = 0; i < this.dims.nAudioLayer; i++) {
      const p = `encoder.blocks.${i}`;
      const ln = this.#layerNorm(x, `${p}.attn_ln`);
      const a = this.#attention(ln, `${p}.attn`, this.dims.nAudioHead, {});
      ln.dispose();
      a.k.dispose();
      a.v.dispose();
      x = dispose(x, ops.add(x, a.out));
      a.out.dispose();
      const m = this.#mlp(x, p);
      x = dispose(x, ops.add(x, m));
      m.dispose();
      trace?.(`block${i}`, x);
    }
    x = dispose(x, this.#layerNorm(x, "encoder.ln_post"));
    return x;
  }

  // --- decoder ----------------------------------------------------------------

  #mask(): MlxArray {
    if (this.#causalMask) return this.#causalMask;
    const n = this.dims.nTextCtx;
    const m = new Float32Array(n * n);
    for (let i = 0; i < n; i++) for (let j = i + 1; j < n; j++) m[i * n + j] = -Infinity;
    const f32 = MlxArray.fromFloat32(m, [n, n]);
    const out = f32.astype(this.dtype);
    f32.dispose();
    this.#causalMask = out;
    return out;
  }

  /** TextDecoder.__call__: tokens [B, T] int32, audioFeatures [B|1, 1500, D].
   *  Returns logits [B, T, n_vocab] (weight dtype) and, when requested, the
   *  per-layer raw cross-attention qk for alignment. Mutates `cache`. */
  decode(
    tokens: MlxArray, audioFeatures: MlxArray, cache: WhisperKvCache,
    opts: { wantCrossQk?: boolean } = {},
  ): { logits: MlxArray; crossQk: (MlxArray | null)[] } {
    const offset = cache.offset;
    const T = tokens.shape[1]!;
    const embed = this.#t("decoder.token_embedding.weight");
    let x = ops.takeAxis(embed, tokens, 0);
    const pos = this.#t("decoder.positional_embedding").slice([offset, 0], [offset + T, this.dims.nTextState]);
    x = dispose(x, ops.add(x, pos));
    pos.dispose();
    const mask = this.#mask();
    const crossQk: (MlxArray | null)[] = [];
    for (let i = 0; i < this.dims.nTextLayer; i++) {
      const p = `decoder.blocks.${i}`;
      const layer = cache.layers[i]!;
      const ln = this.#layerNorm(x, `${p}.attn_ln`);
      const a = this.#attention(ln, `${p}.attn`, this.dims.nTextHead, {
        mask, kv: layer.k && layer.v ? [layer.k, layer.v] : null,
      });
      ln.dispose();
      layer.k?.dispose();
      layer.v?.dispose();
      layer.k = a.k;
      layer.v = a.v;
      x = dispose(x, ops.add(x, a.out));
      a.out.dispose();
      const cln = this.#layerNorm(x, `${p}.cross_attn_ln`);
      const c = this.#attention(cln, `${p}.cross_attn`, this.dims.nTextHead, {
        xa: audioFeatures,
        crossKv: layer.crossK && layer.crossV ? [layer.crossK, layer.crossV] : null,
        wantQk: opts.wantCrossQk,
      });
      cln.dispose();
      if (!layer.crossK) {
        layer.crossK = c.k;
        layer.crossV = c.v;
      }
      x = dispose(x, ops.add(x, c.out));
      c.out.dispose();
      crossQk.push(c.qk);
      const m = this.#mlp(x, p);
      x = dispose(x, ops.add(x, m));
      m.dispose();
    }
    x = dispose(x, this.#layerNorm(x, "decoder.ln"));
    const logits = ops.matmul(x, this.#wT("decoder.token_embedding.weight"));
    x.dispose();
    return { logits, crossQk };
  }

  dispose(): void {
    this.#encPos?.dispose();
    this.#causalMask?.dispose();
    for (const t of this.#transposed.values()) t.dispose();
    this.#transposed.clear();
    this.#fast?.dispose();
    this.#gelu?.dispose();
    this.#w.dispose();
  }
}
