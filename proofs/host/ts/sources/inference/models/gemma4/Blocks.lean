import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Gemma4.Blocks
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/gemma4/blocks.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// The Gemma 4 decoder blocks (port target: mlx-lm's gemma4_text.py and the
// switch_layers.py SwitchGLU it uses): the attention block with the read it was
// built with, the dense and mixture-of-experts feed-forward pieces, the
// per-layer-input pieces (e2b/e4b), the KV-sharing pieces (a donor layer's read
// and the donor each sharer attends) and the decoder layer composing them. The
// generic graph (`Gemma4Model`, model.ts) and the written graphs
// (gemma4-e4b.ts, gemma4-12b.ts, gemma4-26b.ts) compose these blocks.
// Each block is built once from the weights and the config and reads its cache
// through the read its caller's phase names: no block inspects its input to
// choose a phase, builds a mask or chooses an attention kernel. The training
// forward, which fetches plain keys and values from training caches under masks
// it builds, stays with the generic graph that declares training (model.ts).

import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { ModelConfig } from "../../artifacts/config";
import type { Weights } from "../../artifacts/weights";
import type { AttentionCache, AttentionRead, BidirectionalAttentionCache, Cache } from "../../contracts/mlx/cache";
import { geglu, GegluMLP } from "../../layers/geglu";
import { disposing } from "../../layers/helpers";
import { RMSNorm } from "../../layers/normalization";
import { QuantizedEmbedding } from "../../layers/quantized-embedding";
import { QuantizedLinear, QuantizedLinearPlain } from "../../layers/quantized-linear";
import { QuantizedSwitchLinear } from "../../layers/quantized-switch-linear";
import { isCompiledTrace } from "../../runtime/compiled-trace";
import { isExpertTracing, recordRouting } from "../../runtime/expert-trace";
import { captureRopeOffsets } from "../../state/attention-read";
import type { ReadPhase } from "../graph";

/** The phase a Gemma 4 forward runs, named by its caller: one new position per
 * row (`decode`), a causal window of positions (`window`: prefill chunks and
 * tails, speculative verify windows), or the first window of a prompt whose
 * image tokens attend each other in both directions (`bidirectional`: a
 * borrowed bool [L] flagging them, for every row). Each names a read of the
 * cache: `AttentionCache.appendDecode`, `appendWindow`,
 * `BidirectionalAttentionCache.appendBidirectional`. Gemma 4 composes no
 * committed append. */
export type Gemma4Phase = Exclude<ReadPhase, "committed"> | { readonly bidirectional: MlxArray };

/** How an attention block reads its cache, fixed when the block is built.
 * `read` appends `k` and `v` (borrowed) for `phase` and returns the read the
 * block, and the layers sharing its keys and values, attend. */
export interface Gemma4ReadStrategy {
  read(cache: Cache, phase: Gemma4Phase, k: MlxArray, v: MlxArray): AttentionRead;
}

const appendFor: Readonly<Record<Exclude<ReadPhase, "committed">, (cache: Cache, k: MlxArray, v: MlxArray) => AttentionRead>> = {
  decode: (cache, k, v) => (cache as AttentionCache).appendDecode(k, v),
  window: (cache, k, v) => (cache as AttentionCache).appendWindow(k, v),
};

/** The cache's own read for the phase: the default strategy. */
export const gemma4CacheRead: Gemma4ReadStrategy = Object.freeze({
  read: (cache: Cache, phase: Gemma4Phase, k: MlxArray, v: MlxArray): AttentionRead => typeof phase === "string"
    ? appendFor[phase](cache, k, v)
    : (cache as BidirectionalAttentionCache).appendBidirectional(k, v, phase.bidirectional),
});

/** A donor layer's read for one forward and the positions its queries take: the
 * donor cache's offset before the append and, where the cache carries per-row
 * positions (a batched layout, a compiled-decode trace), an owned copy of them,
 * held because advancing the cache may release its own array. The layers
 * sharing the donor's keys and values attend the same read with their own
 * queries (`AttentionRead.attend` is repeatable); the forward that made it
 * disposes it once, after its last sharer. */
export interface DonorRead {
  readonly read: AttentionRead;
  readonly offset: number;
  readonly offsetArr?: MlxArray;
  dispose(): void;
}

/** The donor each layer's attention reads (reference Gemma4TextModel's
 * `previous_kvs`): itself for the first `numDonors` layers, which own caches;
 * for each later layer, the last donor of its own attention type, whose read
 * that layer attends in the same forward. */
export function kvDonors(layerTypes: readonly string[], numDonors: number): number[] {
  const donors = layerTypes.map((_, i) => i);
  const lastByType: Record<string, number> = {};
  for (let i = 0; i < numDonors; i++) lastByType[layerTypes[i]!] = i;
  for (let j = numDonors; j < layerTypes.length; j++) {
    const donor = lastByType[layerTypes[j]!];
    if (donor === undefined) throw new Error(`no donor layer of type ${layerTypes[j]}`);
    donors[j] = donor;
  }
  return donors;
}

/** The attention block of one layer: the query projection and norm, and for a
 * layer that owns a cache the key and value projections and norms, RoPE on the
 * layer type's frequencies, and the read it was built with (`reads`, the cache's
 * own by default); a KV-sharing layer attends its donor's read instead. */
export class Attention {
  readonly isSliding: boolean;
  readonly windowSize: number;
  readonly useKEqV: boolean;
  readonly hasKv: boolean;
  readonly headDim: number;
  readonly nHeads: number;
  readonly nKvHeads: number;
  readonly ropeBase: number | null;
  readonly ropeFreqs: MlxArray | null;
  readonly qProj: QuantizedLinear;
  readonly kProj: QuantizedLinear | null;
  readonly vProj: QuantizedLinear | null;
  readonly oProj: QuantizedLinear;
  readonly #qPlain: QuantizedLinearPlain;
  readonly #kPlain: QuantizedLinearPlain | null;
  readonly #vPlain: QuantizedLinearPlain | null;
  readonly #oPlain: QuantizedLinearPlain;
  readonly qNorm: RMSNorm;
  readonly kNorm: RMSNorm | null;
  readonly vNorm: RMSNorm | null;

  constructor(
    weights: Weights, config: ModelConfig, prefix: string, layerType: string,
    hasKv = true,
    /** How a donor layer reads its cache (the cache's own read). */
    readonly reads: Gemma4ReadStrategy = gemma4CacheRead,
    kEqV?: boolean,
  ) {
    const t = config.text;
    this.hasKv = hasKv;
    this.isSliding = layerType === "sliding_attention";
    this.windowSize = t.slidingWindow;
    this.headDim = this.isSliding ? t.headDim : t.globalHeadDim;
    this.nHeads = t.numAttentionHeads;
    this.useKEqV = kEqV ?? (t.attentionKEqV && !this.isSliding);
    this.nKvHeads = this.useKEqV ? t.numGlobalKeyValueHeads : t.numKeyValueHeads;

    const rp = t.ropeParameters[this.isSliding ? "sliding_attention" : "full_attention"]!;
    if (rp.ropeType === "default") {
      this.ropeBase = rp.ropeTheta;
      this.ropeFreqs = null;
    } else if (rp.ropeType === "proportional") {
      // Port of rope_utils.ProportionalRoPE.__init__. The rotated freqs
      // MUST be computed on-device in f32 (arange/dims, then base**x)
      // exactly like the reference — computing them host-side in f64 and
      // rounding to f32 lands 17/64 of them 1 ulp off (f64 pow ≠ f32
      // powf), a latent knife-edge that tiled values exposed
      // as a 1-ulp q-rope divergence at layer 11 (porting rule:
      // replicate the helper's IMPLEMENTATION, not its formula).
      const rotated = Math.floor(this.headDim * rp.partialRotaryFactor);
      const n = this.headDim / 2;
      const exponentsRaw = ops.arange(0, rotated, 2, Dtype.float32);
      const dims = ops.scalarLike(this.headDim, exponentsRaw);
      const exponents = ops.div(exponentsRaw, dims);
      const base = ops.scalarLike(rp.ropeTheta, exponents);
      let rotFreqs = ops.pow(base, exponents);
      if (rp.factor !== 1.0) {
        const f = ops.scalarLike(rp.factor, rotFreqs);
        rotFreqs = disposing(rotFreqs, ops.mul(f, rotFreqs));
        f.dispose();
      }
      this.ropeBase = null;
      const tailLen = n - rotated / 2;
      if (tailLen > 0) {
        const tail = MlxArray.fromFloat32(
          new Float32Array(tailLen).fill(Infinity), [tailLen],
        );
        this.ropeFreqs = ops.concatAxis([rotFreqs, tail], 0);
        tail.dispose();
      } else {
        this.ropeFreqs = rotFreqs;
      }
      for (const a of [exponentsRaw, dims, exponents, base])
        a.dispose();
      if (this.ropeFreqs !== rotFreqs) rotFreqs.dispose();
    } else {
      throw new Error(`unsupported rope_type ${rp.ropeType}`);
    }

    this.qProj = QuantizedLinear.load(weights, `${prefix}.q_proj`, config);
    this.kProj = hasKv ? QuantizedLinear.load(weights, `${prefix}.k_proj`, config) : null;
    this.vProj = hasKv && !this.useKEqV
      ? QuantizedLinear.load(weights, `${prefix}.v_proj`, config) : null;
    this.oProj = QuantizedLinear.load(weights, `${prefix}.o_proj`, config);
    this.#qPlain = new QuantizedLinearPlain(this.qProj);
    this.#kPlain = this.kProj ? new QuantizedLinearPlain(this.kProj) : null;
    this.#vPlain = this.vProj ? new QuantizedLinearPlain(this.vProj) : null;
    this.#oPlain = new QuantizedLinearPlain(this.oProj);
    this.qNorm = new RMSNorm(weights.tensor(`${prefix}.q_norm.weight`), t.rmsNormEps);
    this.kNorm = hasKv
      ? new RMSNorm(weights.tensor(`${prefix}.k_norm.weight`), t.rmsNormEps) : null;
    this.vNorm = hasKv ? new RMSNorm(null, t.rmsNormEps) : null;
  }

  /** A number offset takes the static fast::rope; an array offset (set by
   *  compiled-decode trace adapters) takes the dynamic variant — same
   *  kernel, offset read from the array (bit-exactness asserted in
   *  `02d723a:tests/unit/compile.test.ts`). */
  rope(x: MlxArray, offset: number | MlxArray): MlxArray {
    return typeof offset === "number"
      ? ops.rope(x, this.headDim, this.ropeBase, offset, this.ropeFreqs)
      : ops.ropeDynamic(x, this.headDim, this.ropeBase, offset, this.ropeFreqs);
  }

  /** `x` [B, L, hidden] (borrowed) to an owned [B, L, hidden]. A donor layer
   *  appends its keys and values to `cache` through the read `phase` names and
   *  returns that read (`donor`, owned by the caller, who keeps it for the
   *  layers that share it); a KV-sharing layer attends `donor`, the read its
   *  donor layer made in this forward, and returns null. */
  forward(
    x: MlxArray, cache: Cache | null, phase: Gemma4Phase, donor: DonorRead | null,
  ): { out: MlxArray; donor: DonorRead | null } {
    const q = this.queries(x);
    const own = this.hasKv ? this.#append(x, cache!, phase) : null;
    return this.attendQueries(q, own ?? donor!, own, x.shape[0]!, x.shape[1]!);
  }

  forwardSeparate(x: MlxArray, cache: Cache, phase: Gemma4Phase): { out: MlxArray; donor: DonorRead } {
    const q = this.queries(x);
    const [B, L] = x.shape;
    let k = this.#kPlain!.forward(x);
    k = disposing(k, ops.reshape(k, [B!, L!, this.nKvHeads, this.headDim]));
    let v = this.#vPlain!.forward(x);
    v = disposing(v, ops.reshape(v, [B!, L!, this.nKvHeads, this.headDim]));
    const source = this.appendValues(k, v, cache, phase);
    return this.attendQueries(q, source, source, B!, L!) as { out: MlxArray; donor: DonorRead };
  }

  forwardKEqV(x: MlxArray, cache: Cache, phase: Gemma4Phase): { out: MlxArray; donor: DonorRead } {
    const q = this.queries(x);
    const [B, L] = x.shape;
    let k = this.#kPlain!.forward(x);
    k = disposing(k, ops.reshape(k, [B!, L!, this.nKvHeads, this.headDim]));
    const source = this.appendValues(k, k, cache, phase);
    return this.attendQueries(q, source, source, B!, L!) as { out: MlxArray; donor: DonorRead };
  }

  forwardShared(x: MlxArray, donor: DonorRead): { out: MlxArray; donor: null } {
    return this.attendQueries(this.queries(x), donor, null, x.shape[0]!, x.shape[1]!) as { out: MlxArray; donor: null };
  }

  private queries(x: MlxArray): MlxArray {
    const [B, L] = x.shape;
    let q = this.#qPlain.forward(x);
    q = disposing(q, ops.reshape(q, [B!, L!, this.nHeads, this.headDim]));
    return disposing(q, this.qNorm.forward(q));
  }

  private attendQueries(q: MlxArray, source: DonorRead, own: DonorRead | null, B: number, L: number): { out: MlxArray; donor: DonorRead | null } {
    let attn: MlxArray;
    try {
      q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));
      q = disposing(q, this.rope(q, source.offsetArr ?? source.offset));
      attn = source.read.attend(q, 1.0);
    } catch (error) {
      own?.dispose();
      throw error;
    } finally { q.dispose(); }
    const attnT = ops.transposeAxes(attn, [0, 2, 1, 3]);
    attn.dispose();
    const merged = ops.reshape(attnT, [B, L, -1]);
    attnT.dispose();
    const out = this.#oPlain.forward(merged);
    merged.dispose();
    return { out, donor: own };
  }

  /** The donor half of `forward`: this layer's keys and values, normalized and
   *  positioned at the cache's offset, appended through the read `phase`
   *  names. The caller owns the returned read. */
  #append(x: MlxArray, cache: Cache, phase: Gemma4Phase): DonorRead {
    const [B, L] = x.shape as [number, number, number];
    let k = this.kProj!.forward(x);
    k = disposing(k, ops.reshape(k, [B, L, this.nKvHeads, this.headDim]));
    let v: MlxArray;
    if (this.vProj) {
      v = this.vProj.forward(x);
      v = disposing(v, ops.reshape(v, [B, L, this.nKvHeads, this.headDim]));
    } else {
      v = k; // attention_k_eq_v: shared projection; norms differ below
    }

    return this.appendValues(k, v, cache, phase);
  }

  private appendValues(k: MlxArray, v: MlxArray, cache: Cache, phase: Gemma4Phase): DonorRead {
    const offset = cache.offset;
    // Own the pre-write positions through every query that attends this read.
    // Advancing a row cache may replace and release its borrowed offset array
    // before the queries' RoPE is built.
    const offsetArr = captureRopeOffsets(cache);

    const kNormed = this.kNorm!.forward(k);
    const kT = ops.transposeAxes(kNormed, [0, 2, 1, 3]);
    kNormed.dispose();
    const kRoped = this.rope(kT, offsetArr ?? offset);
    kT.dispose();

    const vNormed = this.vNorm!.forward(v);
    const vT = ops.transposeAxes(vNormed, [0, 2, 1, 3]);
    vNormed.dispose();
    if (v !== k) v.dispose();
    k.dispose();

    let read: AttentionRead;
    try {
      read = this.reads.read(cache, phase, kRoped, vT);
    } catch (error) {
      offsetArr?.dispose();
      throw error;
    } finally {
      kRoped.dispose();
      vT.dispose();
    }
    return { read, offset, offsetArr, dispose() { read.dispose(); offsetArr?.dispose(); } };
  }
}

// --- MoE block (26B-A4B) — port of reference Router/Experts/SwitchGLU ----
// (gemma4_text.py + switch_layers.py in the oracle venv). The checkpoint
// ships pre-stacked switch_glu tensors [experts, out, in/packed]; only the
// quantized path exists here (all our targets are OptiQ quants).

/** Port of reference Router: norm -> scale -> project -> top-k -> renormalize. */
export class Router {
  readonly proj: QuantizedLinear;
  /** scale · hidden_size^-0.5, precomputed (identical ops to the per-call
   *  product in the reference: bf16 array × weak scalar). */
  readonly normWeight: MlxArray;
  readonly perExpertScale: MlxArray;
  readonly eps: number;
  readonly numExperts: number;
  readonly topK: number;
  /** Decoder layer index (parsed from the weight prefix) — for E0 tracing. */
  readonly layerIdx: number;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    const t = config.text;
    this.layerIdx = Number(prefix.match(/layers\.(\d+)/)?.[1] ?? -1);
    this.proj = QuantizedLinear.load(weights, `${prefix}.proj`, config);
    // weights.tensor() returns the Weights-owned cached array — do NOT
    // dispose it (a second model over the same Weights would get a dead
    // handle; Weights.dispose() frees it at end of life)
    const scale = weights.tensor(`${prefix}.scale`);
    this.normWeight = ops.mulScalar(scale, Math.pow(t.hiddenSize, -0.5));
    this.perExpertScale = weights.tensor(`${prefix}.per_expert_scale`);
    this.eps = t.rmsNormEps;
    this.numExperts = t.numExperts;
    this.topK = t.topKExperts;
  }

  /** x [B, L, H] → { indices [B, L, k] (uint32), weights [B, L, k] }. */
  forward(x: MlxArray): { indices: MlxArray; weights: MlxArray } {
    const normed = ops.rmsNorm(x, this.normWeight, this.eps);
    const scores = this.proj.forward(normed);
    normed.dispose();

    const part = ops.argpartitionAxis(scores, this.numExperts - this.topK, -1);
    const [B, L] = scores.shape as [number, number, number];
    let indices: MlxArray;
    if (isCompiledTrace()) {
      const start = ops.fromInt32([this.numExperts - this.topK], [1]);
      indices = ops.sliceDynamic(part, start, [2], [B, L, this.topK]);
      start.dispose();
    } else {
      indices = part.slice([0, 0, this.numExperts - this.topK], [B, L, this.numExperts]);
    }
    part.dispose();

    let w = ops.takeAlongAxis(scores, indices, -1);
    scores.dispose();
    w = disposing(w, ops.softmaxAxis(w, -1, false));
    const gathered = ops.takeAxis(this.perExpertScale, indices, 0);
    w = disposing(w, ops.mul(w, gathered));
    gathered.dispose();
    if (isExpertTracing()) recordRouting(this.layerIdx, indices);
    return { indices, weights: w };
  }
}

/** Port of switch_layers.SwitchGLU (geglu activation), quantized path, with the
 * activation form its owner chose at construction (`compiled`). */
export class SwitchGLU {
  readonly gate: QuantizedSwitchLinear;
  readonly up: QuantizedSwitchLinear;
  readonly down: QuantizedSwitchLinear;

  constructor(weights: Weights, config: ModelConfig, prefix: string, readonly compiled: boolean) {
    this.gate = QuantizedSwitchLinear.load(weights, `${prefix}.gate_proj`, config);
    this.up = QuantizedSwitchLinear.load(weights, `${prefix}.up_proj`, config);
    this.down = QuantizedSwitchLinear.load(weights, `${prefix}.down_proj`, config);
  }

  /** x [B, L, H], indices [B, L, k] → [B, L, k, H]. */
  forward(x: MlxArray, indices: MlxArray): MlxArray {
    // x → [B, L, 1, 1, H] (reference expand_dims(x, (-2, -3)))
    let h = ops.expandDims(x, -2);
    h = disposing(h, ops.expandDims(h, -3));

    // Sort tokens by expert when there are many rows (reference threshold).
    const doSort = indices.size >= 64;
    let idx = indices;
    let invOrder: MlxArray | null = null;
    let order: MlxArray | null = null;
    if (doSort) {
      // _gather_sort: flatten indices, argsort, gather rows by order // k
      const k = indices.shape[indices.ndim - 1]!;
      const idxFlat = ops.reshape(indices, [indices.size]);
      order = ops.argsortAxis(idxFlat, 0);
      invOrder = ops.argsortAxis(order, 0);
      const kScalar = ops.scalarLike(k, order);
      const rowIdx = ops.floorDivide(order, kScalar);
      kScalar.dispose();
      const [, , , , H] = h.shape as number[];
      const flat = ops.reshape(h, [-1, 1, H!]);
      h.dispose();
      h = ops.takeAxis(flat, rowIdx, 0);
      flat.dispose();
      rowIdx.dispose();
      idx = ops.takeAxis(idxFlat, order, 0);
      idxFlat.dispose();
    }

    const xUp = this.up.forward(h, idx, doSort);
    const xGate = this.gate.forward(h, idx, doSort);
    h.dispose();
    // GeGLU activation: gelu_approx(gate) · up. The oracle SwitchGLU uses the SAME
    // @mx.compile'd geglu as the dense MLP (activation=GeGLU(), switch_layers.py).
    const mid = geglu(xGate, xUp, this.compiled);
    let y = this.down.forward(mid, idx, doSort);
    mid.dispose();
    if (idx !== indices) idx.dispose();

    if (doSort) {
      // _scatter_unsort: restore row order, unflatten to indices.shape
      y = disposing(y, ops.takeAxis(y, invOrder!, 0));
      invOrder!.dispose();
      order!.dispose();
      const [B, L, k] = indices.shape as number[];
      const H = y.shape[y.ndim - 1]!;
      y = disposing(y, ops.reshape(y, [B!, L!, k!, 1, H]));
    }

    // squeeze(-2)
    const shape = y.shape;
    shape.splice(shape.length - 2, 1);
    return disposing(y, ops.reshape(y, shape));
  }
}

/** Port of reference Experts: switch_glu then top-k weighted sum. */
export class Experts {
  readonly switchGlu: SwitchGLU;

  constructor(weights: Weights, config: ModelConfig, prefix: string, compiledGeglu: boolean) {
    this.switchGlu = new SwitchGLU(weights, config, `${prefix}.switch_glu`, compiledGeglu);
  }

  forward(x: MlxArray, indices: MlxArray, weights: MlxArray): MlxArray {
    const w = ops.expandDims(weights, -1);
    const y = this.switchGlu.forward(x, indices);
    const wy = ops.mul(w, y);
    w.dispose();
    y.dispose();
    return disposing(wy, ops.sumAxis(wy, -2, false));
  }
}

/** One decoder layer: the attention sub-block (`forwardAttn`) and the row-wise
 * pieces after it (`denseFeedforward` or `moeFeedforward`, `perLayerGated`,
 * `scaled`), which the generic graph composes through `forwardMlp` and a
 * written graph composes as its layer table names them. */
export class DecoderLayer {
  readonly attn: Attention;
  readonly mlp: GegluMLP;
  readonly inputNorm: RMSNorm;
  readonly postAttnNorm: RMSNorm;
  readonly preFfNorm: RMSNorm;
  readonly postFfNorm: RMSNorm;
  readonly layerScalar: MlxArray | null;
  readonly layerType: string;
  // 26B-A4B MoE block (dense MLP + routed experts in parallel branches)
  readonly router: Router | null;
  readonly experts: Experts | null;
  readonly postFfNorm1: RMSNorm | null;
  readonly postFfNorm2: RMSNorm | null;
  readonly preFfNorm2: RMSNorm | null;
  // e2b/e4b per-layer input gating
  readonly perLayerGate: QuantizedLinear | null;
  readonly perLayerProjection: QuantizedLinear | null;
  readonly postPerLayerNorm: RMSNorm | null;

  /** `compiledGeglu` is the graph's construction-time choice of the GeGLU
   * activation form for the dense MLP and the experts (`layers/geglu.ts`). */
  constructor(weights: Weights, config: ModelConfig, prefixBase: string, idx: number, hasKv: boolean, compiledGeglu: boolean) {
    const prefix = `${prefixBase}.layers.${idx}`;
    const t = config.text;
    this.layerType = t.layerTypes[idx]!;
    this.attn = new Attention(weights, config, `${prefix}.self_attn`, this.layerType, hasKv);
    this.mlp = new GegluMLP(weights, config, `${prefix}.mlp`, compiledGeglu);
    const norm = (n: string) => new RMSNorm(weights.tensor(`${prefix}.${n}.weight`), t.rmsNormEps);
    this.inputNorm = norm("input_layernorm");
    this.postAttnNorm = norm("post_attention_layernorm");
    this.preFfNorm = norm("pre_feedforward_layernorm");
    this.postFfNorm = norm("post_feedforward_layernorm");
    this.layerScalar = weights.has(`${prefix}.layer_scalar`)
      ? weights.tensor(`${prefix}.layer_scalar`)
      : null;
    if (t.enableMoeBlock) {
      this.router = new Router(weights, config, `${prefix}.router`);
      this.experts = new Experts(weights, config, `${prefix}.experts`, compiledGeglu);
      this.postFfNorm1 = norm("post_feedforward_layernorm_1");
      this.postFfNorm2 = norm("post_feedforward_layernorm_2");
      this.preFfNorm2 = norm("pre_feedforward_layernorm_2");
    } else {
      this.router = this.experts = null;
      this.postFfNorm1 = this.postFfNorm2 = this.preFfNorm2 = null;
    }
    if (t.hiddenSizePerLayerInput > 0) {
      this.perLayerGate = QuantizedLinear.load(weights, `${prefix}.per_layer_input_gate`, config);
      this.perLayerProjection = QuantizedLinear.load(weights, `${prefix}.per_layer_projection`, config);
      this.postPerLayerNorm = norm("post_per_layer_input_norm");
    } else {
      this.perLayerGate = this.perLayerProjection = null;
      this.postPerLayerNorm = null;
    }
  }

  /** `x` [B, L, hidden] (borrowed) to an owned [B, L, hidden], the attention
   *  block reading `cache` for `phase` (a donor) or attending `donor` (a
   *  KV-sharing layer). Returns a donor layer's read, which the caller owns. */
  forward(
    x: MlxArray, cache: Cache | null, phase: Gemma4Phase,
    donor: DonorRead | null, perLayerInput: MlxArray | null,
  ): { h: MlxArray; donor: DonorRead | null } {
    // Composed from the two sub-blocks (the intra-layer min-cut is the post-attn
    // residual `hMid` [1,T,hidden]). `forwardMlp` borrows hMid.
    const { h: hMid, donor: made } = this.forwardAttn(x, cache, phase, donor);
    let h: MlxArray;
    try { h = this.forwardMlp(hMid, perLayerInput); }
    catch (error) { made?.dispose(); throw error; }
    finally { hMid.dispose(); }
    return { h, donor: made };
  }

  /** Attention sub-block: inputNorm → attn → postAttnNorm → residual add.
   *  Returns the post-attn residual stream `h` [B,T,hidden] (the intra-layer
   *  boundary) and a donor layer's read (null for a sharer). `x` is borrowed
   *  (never disposed). The e4b donor threading lives entirely here. */
  forwardAttn(
    x: MlxArray, cache: Cache | null, phase: Gemma4Phase, donor: DonorRead | null,
  ): { h: MlxArray; donor: DonorRead | null } {
    let h = this.inputNorm.forward(x);
    const { out, donor: made } = this.attn.forward(h, cache, phase, donor);
    h.dispose();
    h = out;
    h = disposing(h, this.postAttnNorm.forward(h));
    h = disposing(h, ops.add(x, h));
    return { h, donor: made };
  }

  /** MLP sub-block: FFN (dense or MoE) + postFfNorm + residual add, then the
   *  e4b per-layer-input gate and layer scalar. `hMid` (the attn sub-block's
   *  output) is BORROWED — the caller owns/disposes it (it is the checkpoint
   *  boundary leaf), so this never disposes it. The generic graph's composition
   *  of the pieces below; a written graph composes the ones its layer has. */
  forwardMlp(hMid: MlxArray, perLayerInput: MlxArray | null): MlxArray {
    let h = this.router && this.experts ? this.moeFeedforward(hMid) : this.denseFeedforward(hMid);
    if (this.perLayerGate && this.perLayerProjection && this.postPerLayerNorm && perLayerInput)
      h = this.perLayerGated(h, perLayerInput);
    if (this.layerScalar) h = this.scaled(h);
    return h;
  }

  /** The dense feed-forward with its residual: preFfNorm → GeGLU MLP →
   *  postFfNorm, added to `hMid` (borrowed). Returns an owned output. */
  denseFeedforward(hMid: MlxArray): MlxArray {
    let f = this.preFfNorm.forward(hMid);
    f = disposing(f, this.mlp.forward(f));
    f = disposing(f, this.postFfNorm.forward(f));
    const h = ops.add(hMid, f); // hMid borrowed — NOT disposed here
    f.dispose();
    return h;
  }

  /** The MoE feed-forward with its residual (26B-A4B): the dense MLP and the
   *  routed experts as parallel branches off `hMid` (borrowed; reference
   *  DecoderLayer, enable_moe path), summed, postFfNorm, added to `hMid`.
   *  Returns an owned output. */
  moeFeedforward(hMid: MlxArray): MlxArray {
    let h1 = this.preFfNorm.forward(hMid);
    h1 = disposing(h1, this.mlp.forward(h1));
    h1 = disposing(h1, this.postFfNorm1!.forward(h1));

    const { indices, weights: topKWeights } = this.router!.forward(hMid);
    let h2 = this.preFfNorm2!.forward(hMid);
    h2 = disposing(h2, this.experts!.forward(h2, indices, topKWeights));
    h2 = disposing(h2, this.postFfNorm2!.forward(h2));
    indices.dispose();
    topKWeights.dispose();

    let f = ops.add(h1, h2);
    h1.dispose();
    h2.dispose();
    f = disposing(f, this.postFfNorm.forward(f));
    const h = ops.add(hMid, f); // hMid borrowed — NOT disposed here
    f.dispose();
    return h;
  }

  /** The per-layer input gate (e2b/e4b; reference gemma4_text DecoderLayer):
   *  `h` (consumed) plus postPerLayerNorm(projection(gelu(gate(h)) ·
   *  `perLayerInput`)), the input borrowed. gelu(gate)·pli is the second GeGLU
   *  site — the bit-exact spelled-out gelu+mul. Returns an owned output. */
  perLayerGated(h: MlxArray, perLayerInput: MlxArray): MlxArray {
    let gate = this.perLayerGate!.forward(h);
    gate = disposing(gate, ops.geluApprox(gate));
    gate = disposing(gate, ops.mul(gate, perLayerInput));
    gate = disposing(gate, this.perLayerProjection!.forward(gate));
    gate = disposing(gate, this.postPerLayerNorm!.forward(gate));
    const out = ops.add(h, gate);
    h.dispose();
    gate.dispose();
    return out;
  }

  /** `h` (consumed) times the layer scalar. */
  scaled(h: MlxArray): MlxArray {
    return disposing(h, ops.mul(h, this.layerScalar!));
  }
}

/** The per-layer inputs of a per-layer-input model (e2b/e4b; reference
 *  `_get_per_layer_inputs` + `_project_per_layer_inputs`): every layer's input
 *  from the token ids and the scaled embeddings, and each layer's slice. */
export class PerLayerInputs {
  readonly embed: QuantizedEmbedding;
  readonly modelProjection: QuantizedLinear;
  readonly projectionNorm: RMSNorm;
  /** Each layer's input width. */
  readonly width: number;
  readonly #layers: number;
  readonly #hiddenSize: number;

  constructor(weights: Weights, config: ModelConfig, prefixBase: string) {
    const t = config.text;
    this.embed = QuantizedEmbedding.load(weights, `${prefixBase}.embed_tokens_per_layer`, config);
    this.modelProjection = QuantizedLinear.load(weights, `${prefixBase}.per_layer_model_projection`, config);
    this.projectionNorm = new RMSNorm(weights.tensor(`${prefixBase}.per_layer_projection_norm.weight`), t.rmsNormEps);
    this.width = t.hiddenSizePerLayerInput;
    this.#layers = t.numHiddenLayers;
    this.#hiddenSize = t.hiddenSize;
  }

  /** Every layer's input, [B, L, nLayers, width] (owned), from `ids` [B, L]
   *  and the scaled embeddings `hScaled` [B, L, hidden] (both borrowed). */
  compute(ids: MlxArray, hScaled: MlxArray): MlxArray {
    const B = ids.shape[0]!;
    const L = ids.shape[1]!;
    let pli = this.embed.encode(ids); // [B, L, nLayers*width]
    pli = disposing(pli, ops.mulScalar(pli, Math.sqrt(this.width)));
    pli = disposing(pli, ops.reshape(pli, [B, L, this.#layers, this.width]));

    let proj = this.modelProjection.forward(hScaled);
    proj = disposing(proj, ops.mulScalar(proj, 1 / Math.sqrt(this.#hiddenSize)));
    proj = disposing(proj, ops.reshape(proj, [B, L, this.#layers, this.width]));
    proj = disposing(proj, this.projectionNorm.forward(proj));

    let combined = ops.add(proj, pli);
    proj.dispose();
    pli.dispose();
    combined = disposing(combined, ops.mulScalar(combined, Math.SQRT1_2));
    return combined;
  }

  /** Layer `i`'s input [B, L, width] (owned) from the [B, L, nLayers, width]
   *  tensor `compute` returned (borrowed). A compiled-decode trace slices at an
   *  array start, which replays at every step. */
  ordinaryLayer(perLayer: MlxArray, i: number, B: number, L: number): MlxArray {
    using slice = perLayer.slice([0, 0, i, 0], [B, L, i + 1, this.width]);
    return ops.reshape(slice, [B, L, this.width]);
  }

  traceLayer(perLayer: MlxArray, i: number, B: number, L: number): MlxArray {
    using start = ops.fromInt32([i], [1]);
    using slice = ops.sliceDynamic(perLayer, start, [2], [B, L, 1, this.width]);
    return ops.reshape(slice, [B, L, this.width]);
  }

  layer(perLayer: MlxArray, i: number, B: number, L: number): MlxArray {
    let pls: MlxArray;
    if (isCompiledTrace()) {
      const start = ops.fromInt32([i], [1]);
      pls = ops.sliceDynamic(perLayer, start, [2], [B, L, 1, this.width]);
      start.dispose();
    } else {
      pls = perLayer.slice([0, 0, i, 0], [B, L, i + 1, this.width]);
    }
    const r = ops.reshape(pls, [B, L, this.width]);
    pls.dispose();
    return r;
  }
}


/** Unsorted expert gather. The graph binds this below the reference threshold. */
export class UnsortedSwitchGLU {
  constructor(readonly base: SwitchGLU,
    readonly activation: { forward(gate: MlxArray, up: MlxArray): MlxArray }) {}
  forward(x: MlxArray, indices: MlxArray): MlxArray {
    using expanded = ops.expandDims(x, -2);
    using h = ops.expandDims(expanded, -3);
    const up = this.base.up.forward(h, indices, false);
    const gate = this.base.gate.forward(h, indices, false);
    using mid = this.activation.forward(gate, up);
    using y = this.base.down.forward(mid, indices, false);
    const shape = y.shape;
    shape.splice(shape.length - 2, 1);
    return ops.reshape(y, shape);
  }
}

/** Sorted expert gather and inverse permutation. No token-count selector. */
export class SortedSwitchGLU {
  constructor(readonly base: SwitchGLU,
    readonly activation: { forward(gate: MlxArray, up: MlxArray): MlxArray }) {}
  forward(x: MlxArray, indices: MlxArray): MlxArray {
    using expanded = ops.expandDims(x, -2);
    using h = ops.expandDims(expanded, -3);
    const k = indices.shape[indices.ndim - 1]!;
    using idxFlat = ops.reshape(indices, [indices.size]);
    using order = ops.argsortAxis(idxFlat, 0);
    using invOrder = ops.argsortAxis(order, 0);
    using kScalar = ops.scalarLike(k, order);
    using rowIdx = ops.floorDivide(order, kScalar);
    using flat = ops.reshape(h, [-1, 1, h.shape[4]!]);
    using sorted = ops.takeAxis(flat, rowIdx, 0);
    using idx = ops.takeAxis(idxFlat, order, 0);
    const up = this.base.up.forward(sorted, idx, true);
    const gate = this.base.gate.forward(sorted, idx, true);
    using mid = this.activation.forward(gate, up);
    using projected = this.base.down.forward(mid, idx, true);
    using unsorted = ops.takeAxis(projected, invOrder, 0);
    const [B, L, topK] = indices.shape as number[];
    using y = ops.reshape(unsorted, [B!, L!, topK!, 1, unsorted.shape.at(-1)!]);
    const shape = y.shape;
    shape.splice(shape.length - 2, 1);
    return ops.reshape(y, shape);
  }
}

/** The explicit expert operation, with top-k weighted sum in reference order. */
export class FixedExperts {
  constructor(readonly switchGlu: { forward(x: MlxArray, indices: MlxArray): MlxArray }) {}
  forward(x: MlxArray, indices: MlxArray, weights: MlxArray): MlxArray {
    using w = ops.expandDims(weights, -1);
    using y = this.switchGlu.forward(x, indices);
    using wy = ops.mul(w, y);
    return ops.sumAxis(wy, -2, false);
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Gemma4.Blocks
