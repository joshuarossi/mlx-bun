import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Minicpm5.Model
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/minicpm5/model.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxCacheLayer, MlxMixedRange, MlxSequenceRange } from "../../contracts/mlx/graph";
// Concrete model graph for MiniCPM5-1B-OptiQ-4bit.
// Port target: mlx_lm.models.llama from the oracle venv. Each block is built
// once and reads its cache through the cache contract for the phase its caller
// names (`ReadPhase`); the cache was composed with its read, so no block builds
// a mask or chooses an attention kernel. The training forward
// (`forwardTraining`) reads its training caches the same way and adds only the
// prefix-shared block RoPE.

import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { LoraState } from "../../layers/lora";
import type { GraphDeclaration } from "../../contracts/portable/graph";
import type { MlxRowTable, MlxCapturingForward, MlxDeclaredGraph, MlxHeadForward, MlxPhaseForward, MlxPromptRange, MlxTokenPhases, MlxVerifyForward } from "../../contracts/mlx/graph";
import type { TrainableGraph } from "../../contracts/mlx/trainable";
import { miniCpmTrainable } from "./trainable";
import { declareGraph } from "../capabilities";
import { DEFAULT_PHASE_ROWS,  rowTable, type ReadPhase   } from "../graph";
import type { ModelConfig } from "../../artifacts/config";
import type { Weights } from "../../artifacts/weights";
import type { Cache, TrainingAttentionCache } from "../../contracts/mlx/cache";
import { disposing } from "../../layers/helpers";
import { RMSNorm } from "../../layers/normalization";
import { QuantizedEmbedding } from "../../layers/quantized-embedding";
import { QuantizedLinear, QuantizedLinearPlain } from "../../layers/quantized-linear";
import { composedFullAttentionCache } from "../../state/bf16-first-kv";
import { AttentionMasks } from "../../state/attention-read";
import { deferredTurboQuantKernels } from "../../state/turboquant-attention";
import { compiledSwiglu } from "../../layers/swiglu";
import { cacheRead, type AttentionReadStrategy } from "../qwen/blocks";

export class LlamaAttention {
  readonly qProj: QuantizedLinear;
  readonly kProj: QuantizedLinear;
  readonly vProj: QuantizedLinear;
  readonly oProj: QuantizedLinear;
  readonly nHeads: number;
  readonly nKvHeads: number;
  readonly headDim: number;
  readonly scale: number;
  readonly ropeBase: number;

  readonly #q: QuantizedLinearPlain;
  readonly #k: QuantizedLinearPlain;
  readonly #v: QuantizedLinearPlain;
  readonly #out: QuantizedLinearPlain;

  /** `reads` is how the block reads its cache: the cache's own read, fixed when
   * the block is built. */
  constructor(weights: Weights, config: ModelConfig, prefix: string, readonly reads: AttentionReadStrategy = cacheRead) {
    const t = config.text;
    this.nHeads = t.numAttentionHeads;
    this.nKvHeads = t.numKeyValueHeads;
    this.headDim = t.headDim;
    this.scale = Math.pow(this.headDim, -0.5);
    this.ropeBase = t.ropeParameters.full_attention?.ropeTheta ?? 10000;
    this.qProj = QuantizedLinear.load(weights, `${prefix}.q_proj`, config);
    this.kProj = QuantizedLinear.load(weights, `${prefix}.k_proj`, config);
    this.vProj = QuantizedLinear.load(weights, `${prefix}.v_proj`, config);
    this.oProj = QuantizedLinear.load(weights, `${prefix}.o_proj`, config);
    this.#q = new QuantizedLinearPlain(this.qProj);
    this.#k = new QuantizedLinearPlain(this.kProj);
    this.#v = new QuantizedLinearPlain(this.vProj);
    this.#out = new QuantizedLinearPlain(this.oProj);
  }

  /** `x` [B, L, hidden] (borrowed) to an owned [B, L, hidden], appending to
   *  `cache` and attending through the read `phase` names. */
  forward(x: MlxArray, cache: Cache, phase: ReadPhase): MlxArray {
    const [B, L] = x.shape as [number, number, number];
    let [q, k, v] = this.#heads(x, B, L);
    // RoPE: a number offset takes the static fast::rope; an array offset
    // (per-row positions for left-padded batched decode) takes the dynamic
    // variant — same kernel, offset read from the array. Captured once: rope
    // runs before the append, so K and Q share the pre-write offset.
    const offsetArr = cache.ropeOffsetArr;
    const ropeStep = (x: MlxArray): MlxArray => offsetArr
      ? ops.ropeDynamic(x, this.headDim, this.ropeBase, offsetArr, null)
      : ops.rope(x, this.headDim, this.ropeBase, cache.offset, null);
    q = disposing(q, ropeStep(q));
    k = disposing(k, ropeStep(k));
    const read = this.reads.read(cache, phase, k, v);
    k.dispose();
    v.dispose();
    let attn: MlxArray;
    try { attn = read.attend(q, this.scale); } finally { read.dispose(); }
    q.dispose();
    return this.#output(attn, B, L);
  }

  /** The training forward over a training cache (`TrainingCache`,
   *  `PrefixSharedCache`), roped at the positions the cache owns (block-wise
   *  for a prefix-shared concat), read through its window read, which owns the mask (causal, padded or
   *  block-sparse) and the kernel the run composed (the SDPA, or the validated
   *  flash kernel). */
  forwardTraining(x: MlxArray, cache: TrainingAttentionCache): MlxArray {
    const [B, L] = x.shape as [number, number, number];
    let [q, k, v] = this.#heads(x, B, L);
    const ropeStep = (x: MlxArray): MlxArray =>
      cache.ropePositions(x, (block, offset) => ops.rope(block, this.headDim, this.ropeBase, offset, null));
    q = disposing(q, ropeStep(q));
    k = disposing(k, ropeStep(k));
    const read = cache.appendWindow(k, v);
    k.dispose();
    v.dispose();
    let attn: MlxArray;
    try { attn = read.attend(q, this.scale); } finally { read.dispose(); }
    q.dispose();
    return this.#output(attn, B, L);
  }

  /** q, k and v heads [B, H, L, D] of `x` (borrowed), before RoPE. */
  #heads(x: MlxArray, B: number, L: number): [MlxArray, MlxArray, MlxArray] {
    let q = this.#q.forward(x);
    let k = this.#k.forward(x);
    let v = this.#v.forward(x);

    q = disposing(q, ops.reshape(q, [B, L, this.nHeads, this.headDim]));
    k = disposing(k, ops.reshape(k, [B, L, this.nKvHeads, this.headDim]));
    v = disposing(v, ops.reshape(v, [B, L, this.nKvHeads, this.headDim]));

    q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));
    k = disposing(k, ops.transposeAxes(k, [0, 2, 1, 3]));
    v = disposing(v, ops.transposeAxes(v, [0, 2, 1, 3]));
    return [q, k, v];
  }

  /** The output projection of `attn` [B, H, L, D] (consumed). */
  #output(attn: MlxArray, B: number, L: number): MlxArray {
    const attnT = ops.transposeAxes(attn, [0, 2, 1, 3]);
    attn.dispose();
    const merged = ops.reshape(attnT, [B, L, -1]);
    attnT.dispose();
    const out = this.#out.forward(merged);
    merged.dispose();
    return out;
  }
}

/** The MLP with mlx_lm activations.py's compiled swiglu, at every sequence
 *  length: separate kernels differ numerically on MLX 0.32.2 at larger prefill
 *  shapes. */
export class LlamaMLP {
  readonly kind = "compiled";
  readonly gate: QuantizedLinear;
  readonly up: QuantizedLinear;
  readonly down: QuantizedLinear;

  readonly #gate: QuantizedLinearPlain;
  readonly #up: QuantizedLinearPlain;
  readonly #down: QuantizedLinearPlain;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.gate = QuantizedLinear.load(weights, `${prefix}.gate_proj`, config);
    this.up = QuantizedLinear.load(weights, `${prefix}.up_proj`, config);
    this.down = QuantizedLinear.load(weights, `${prefix}.down_proj`, config);
    this.#gate = new QuantizedLinearPlain(this.gate);
    this.#up = new QuantizedLinearPlain(this.up);
    this.#down = new QuantizedLinearPlain(this.down);
  }

  /** MLP: returns mlp(x); the caller adds the residual when given. */
  forward(x: MlxArray, residual?: MlxArray): MlxArray {
    const gate = this.#gate.forward(x);
    const up = this.#up.forward(x);
    const hidden = compiledSwiglu(gate, up);
    gate.dispose();
    up.dispose();
    return downWithResidual(this.#down, hidden, residual);
  }
}

/** The MLP with the swiglu as separate silu and multiply kernels: the explicit
 *  layer form, available for callers writing their own graph. */
export class LlamaUnfusedMLP {
  readonly kind = "unfused";
  readonly gate: QuantizedLinear;
  readonly up: QuantizedLinear;
  readonly down: QuantizedLinear;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.gate = QuantizedLinear.load(weights, `${prefix}.gate_proj`, config);
    this.up = QuantizedLinear.load(weights, `${prefix}.up_proj`, config);
    this.down = QuantizedLinear.load(weights, `${prefix}.down_proj`, config);
  }

  /** MLP: returns mlp(x); the caller adds the residual when given. */
  forward(x: MlxArray, residual?: MlxArray): MlxArray {
    const gate = this.gate.forward(x);
    const up = this.up.forward(x);
    const sig = ops.sigmoid(gate);
    const silu = ops.mul(gate, sig);
    gate.dispose();
    sig.dispose();
    const hidden = ops.mul(silu, up);
    silu.dispose();
    up.dispose();
    return downWithResidual(this.down, hidden, residual);
  }
}

/** down(hidden) (hidden consumed), plus `residual` when given. */
function downWithResidual(down: { forward(x: MlxArray): MlxArray }, hidden: MlxArray, residual: MlxArray | undefined): MlxArray {
  const m = down.forward(hidden);
  hidden.dispose();
  if (residual == null) return m;
  return disposing(m, ops.add(residual, m));
}

export type MiniCpmMlp = LlamaMLP | LlamaUnfusedMLP;
type MlpBlock = new (weights: Weights, config: ModelConfig, prefix: string) => MiniCpmMlp;

export class LlamaLayer {
  readonly attn: LlamaAttention;
  readonly mlp: MiniCpmMlp;
  readonly inputNorm: RMSNorm;
  readonly postAttnNorm: RMSNorm;

  constructor(weights: Weights, config: ModelConfig, prefix: string, Mlp: MlpBlock = LlamaMLP) {
    this.attn = new LlamaAttention(weights, config, `${prefix}.self_attn`);
    this.mlp = new Mlp(weights, config, `${prefix}.mlp`);
    this.inputNorm = new RMSNorm(weights.tensor(`${prefix}.input_layernorm.weight`), config.text.rmsNormEps);
    this.postAttnNorm = new RMSNorm(weights.tensor(`${prefix}.post_attention_layernorm.weight`), config.text.rmsNormEps);
  }

  forward(x: MlxArray, cache: Cache, phase: ReadPhase): MlxArray {
    const xn = this.inputNorm.forward(x);
    const a = this.attn.forward(xn, cache, phase);
    xn.dispose();
    return this.#mlp(x, a);
  }

  /** The training forward (`LlamaAttention.forwardTraining`). */
  forwardTraining(x: MlxArray, cache: TrainingAttentionCache): MlxArray {
    const xn = this.inputNorm.forward(x);
    const a = this.attn.forwardTraining(xn, cache);
    xn.dispose();
    return this.#mlp(x, a);
  }

  /** The residual over the attention output `a` (consumed), then the MLP. */
  #mlp(x: MlxArray, a: MlxArray): MlxArray {
    const h = ops.add(x, a);
    a.dispose();
    const hn = this.postAttnNorm.forward(h);
    // Pass the residual h INTO the MLP so the fused kernel absorbs it (out = h + mlp).
    const out = this.mlp.forward(hn, h);
    hn.dispose();
    h.dispose();
    return out;
  }
}

export class MiniCPM5Model implements MlxDeclaredGraph, MlxTokenPhases {
  readonly config: ModelConfig;
  readonly weightsBytes: number;
  readonly prefixBase = "model";
  readonly loraState = new LoraState();
  /** An ordinary autoregressive graph: every method over every cache lego. */
  get graphCapabilities(): GraphDeclaration { return declareGraph(); }
  #trainable: TrainableGraph | undefined;
  /** The separate quantized head, segmented backward, prefix-shared ORPO and flash training attention. */
  get trainable(): TrainableGraph { return this.#trainable ??= miniCpmTrainable(this); }
  readonly embed: QuantizedEmbedding;
  readonly layers: LlamaLayer[];
  readonly finalNorm: RMSNorm;
  readonly lmHead: QuantizedLinear;
  readonly #head: QuantizedLinearPlain;

  constructor(weights: Weights, config: ModelConfig, maxPhaseRows = DEFAULT_PHASE_ROWS) {
    if (config.text.tieWordEmbeddings)
      throw new Error("llama tied embeddings are not supported yet");
    this.config = config;
    this.weightsBytes = [...weights.shards.files.values()]
      .reduce((a, f) => a + f.mmap.size, 0);
    this.embed = QuantizedEmbedding.load(weights, "model.embed_tokens", config);
    const Mlp = LlamaMLP;
    this.layers = Array.from(
      { length: config.text.numHiddenLayers },
      (_, i) => new LlamaLayer(weights, config, `model.layers.${i}`, Mlp),
    );
    this.finalNorm = new RMSNorm(weights.tensor("model.norm.weight"), config.text.rmsNormEps);
    this.lmHead = QuantizedLinear.load(weights, "lm_head", config);
    this.#head = new QuantizedLinearPlain(this.lmHead);

    const multiSequencePrompt: MlxCapturingForward = (ids, cache) =>
    this.forwardLayers(this.embed.encode(ids), cache, "window");
    this.prompt = [{ from: 1, to: Infinity, operation: multiSequencePrompt }];
    this.promptChunk = this.prompt;
    this.multiSequencePrompt = this.prompt;
    this.multiSequencePromptChunk = this.multiSequencePrompt;
    this.appendKnown = [{from:1,to:Infinity,operation:(ids, cache) =>
    this.forwardLayers(this.embed.encode(ids), cache, "window")}];
    this.logits = rowTable<MlxHeadForward>(hidden => this.logitsFromHidden(hidden), maxPhaseRows);
    this.decode = rowTable<MlxPhaseForward>((ids, cache) =>
    this.forwardLayers(this.embed.encode(ids), cache, "decode"), maxPhaseRows);
    this.verify = rowTable<MlxVerifyForward>((ids, cache) =>
    this.forwardLayers(this.embed.encode(ids), cache, "window"), maxPhaseRows);


    this.sequence = [{from:1,to:Infinity,operation:(ids,cache)=>this.sequenceHidden(ids,cache,1)}];

    this.cacheLayers = this.layers.map(() => ({kind:"full" as const,turboQuant:"deferred" as const}));
  }

  loraTargets(): Map<string, QuantizedLinear> {
    const out = new Map<string, QuantizedLinear>();
    for (let i = 0; i < this.layers.length; i++) {
      const l = this.layers[i]!;
      const p = `model.layers.${i}`;
      out.set(`${p}.self_attn.q_proj`, l.attn.qProj);
      out.set(`${p}.self_attn.k_proj`, l.attn.kProj);
      out.set(`${p}.self_attn.v_proj`, l.attn.vProj);
      out.set(`${p}.self_attn.o_proj`, l.attn.oProj);
      out.set(`${p}.mlp.gate_proj`, l.mlp.gate);
      out.set(`${p}.mlp.up_proj`, l.mlp.up);
      out.set(`${p}.mlp.down_proj`, l.mlp.down);
    }
    return out;
  }

  /** Builds no constants and opens no weights: nothing to release. */
  dispose(): void {}

  /** One cache per layer, sharing one mask memo. Their TurboQuant read is
   * deferred (`deferredTurboQuantKernels`): attention runs on the rotated
   * values and the read un-rotates its output. */
  readonly cacheLayers: readonly MlxCacheLayer[];
  readonly sequence: readonly MlxSequenceRange[];


  /** The scoring and training forward (`MlxSequenceForward`, `trainForward`
   *  over the training caches): the window read at every width. The training
   *  caches were composed with the run's training attention, so a run that
   *  selects flash attention reads with it here. */
  sequenceHidden(ids: MlxArray, cache: Cache[], _width: number): MlxArray {
    return this.forwardLayers(this.embed.encode(ids), cache, "window");
  }

  /** One whole chunk of a prompt; rows are sequences times the chunk size. The GPU is this graph's one unit. */
  readonly prompt: readonly MlxPromptRange[];
  readonly promptChunk: typeof this.prompt;
  readonly multiSequencePromptChunk: typeof this.multiSequencePrompt;
  readonly multiSequencePrompt: readonly MlxPromptRange[];

  /** A prompt's positions that are not a whole chunk: the window read at every width. */

  /** Known tokens: this graph declares no committed spans, so they read as a window. */
  readonly appendKnown: import("../../contracts/mlx/graph").MlxKnownOperations;

  /** The one output head at every width. */
  readonly logits: MlxRowTable<MlxHeadForward>;

  /** One new token per sequence: `ids` [sequences, 1]. */
  readonly decode: MlxRowTable<MlxCapturingForward>;

  /** A speculative window of depth + 1 positions per sequence. This graph
   * declares no hidden-layer taps, so `capture` is always null. */
  readonly verify: MlxRowTable<MlxCapturingForward>;

  /** The decoder over `h0` (consumed), every block reading its cache for `phase`. */
  protected forwardLayers(h0: MlxArray, cache: Cache[], phase: ReadPhase): MlxArray {
    let h = h0;
    for (let i = 0; i < this.layers.length; i++) {
      const next = this.layers[i]!.forward(h, cache[i]!, phase);
      h.dispose();
      h = next;
    }
    return disposing(h, this.finalNorm.forward(h));
  }

  /** Run decoder layers `[aIdx, bIdx)` on hidden `h`, returning the residual
   *  stream after the last layer in the range (NO finalNorm). The input `h` is
   *  NEVER disposed — the caller owns it (for segmented backward `h` is a leaf
   *  whose lifetime is managed by the autograd closure); intra-range
   *  intermediates ARE disposed. The segmented-backward and prefix-shared
   *  training paths' building block (`02d723a:docs/design/orpo-training.md`
   *  §5.3). MiniCPM5 is plain full-attention with no KV-sharing, so each layer
   *  reads its own stateless training cache `cache[i]`. */
  runLayerRange(h: MlxArray, aIdx: number, bIdx: number, cache: Cache[]): MlxArray {
    if (aIdx >= bIdx) return h;
    let cur = h;
    for (let i = aIdx; i < bIdx; i++) {
      const next = this.layers[i]!.forwardTraining(cur, cache[i] as TrainingAttentionCache);
      if (i > aIdx) cur.dispose(); // keep the input boundary leaf; drop interiors
      cur = next;
    }
    return cur;
  }

  logitsFromHidden(h: MlxArray): MlxArray {
    return this.#head.forward(h);
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Minicpm5.Model
