import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Qwen.Qwen3Moe
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/qwen/qwen3-moe.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxCacheLayer, MlxMixedRange, MlxSequenceRange } from "../../contracts/mlx/graph";
// Concrete model graph for Qwen3-MoE (model_type `qwen3_moe`,
// Qwen3MoeForCausalLM). A STRAIGHT op-for-op transcription of the oracle
// (`mlx_lm/models/qwen3_moe.py` +
// switch_layers.py SwitchGLU + activations.py swiglu). Each op below carries
// the exact oracle line it copies — no abstraction, no reorder, no
// "optimization". The ONLY intentional deviation from a naive transcription is
// that the expert swiglu is mx.compile-COMPILED (like the oracle's
// activations.py `@partial(mx.compile) def swiglu`), matching both the greedy
// token stream AND the dispatched Metal kernel set.
//
// Attention is identical to plain qwen3 (per-head q/k RMSNorm over head_dim
// before RoPE, full-head RoPE, GQA, SDPA). The MoE block is
// Qwen3MoeSparseMoeBlock: gate Linear -> precise softmax over ALL experts ->
// argpartition top-k -> take_along_axis -> renormalize (norm_topk_prob) ->
// SwitchGLU(swiglu) experts -> weighted sum. Per decoder_sparse_step /
// mlp_only_layers a layer may instead be a dense MLP (MLP class); both are
// handled faithfully. Weights are untied (separate lm_head). Config: 48 layers,
// hidden 2048, 128 experts, top-8, moe_intermediate 768, rope_theta 1e7.

import type { ModelConfig } from "../../artifacts/config";
import type { Weights } from "../../artifacts/weights";
import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { disposing } from "../../layers/helpers";
import { compiledSwiglu } from "../../layers/swiglu";
import { LoraState } from "../../layers/lora";
import type { GraphDeclaration } from "../../contracts/portable/graph";
import type { MlxRowTable, MlxCapturingForward, MlxDeclaredGraph, MlxHeadForward, MlxPhaseForward, MlxPromptRange, MlxTokenPhases, MlxVerifyForward } from "../../contracts/mlx/graph";
import { declareGraph } from "../capabilities";
import { DEFAULT_PHASE_ROWS, rowTableFrom, rowTable, type ReadPhase   } from "../graph";
import { QuantizedEmbedding } from "../../layers/quantized-embedding";
import { QuantizedLinear, QuantizedLinearPlain } from "../../layers/quantized-linear";
import { QuantizedSwitchLinear } from "../../layers/quantized-switch-linear";
import { RMSNorm } from "../../layers/normalization";
import { type Cache } from "../../contracts/mlx/cache";
import { Qwen3Attention } from "./qwen3";

// ── qwen3_moe.py Attention (== plain qwen3, rope_theta default 1e7) ───────────
const MOE_ROPE_THETA = 10000000;                                        // args.rope_theta

// ── qwen3_moe.py MLP (dense-layer FFN) ───────────────────────────────────────
// def __call__(self, x): return self.down_proj(swiglu(self.gate_proj(x), self.up_proj(x)))
class MLP {
  readonly kind = "dense";
  readonly gateProj: QuantizedLinear;
  readonly upProj: QuantizedLinear;
  readonly downProj: QuantizedLinear;

  readonly #gate: QuantizedLinearPlain;
  readonly #up: QuantizedLinearPlain;
  readonly #down: QuantizedLinearPlain;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.gateProj = QuantizedLinear.load(weights, `${prefix}.gate_proj`, config); // nn.Linear(dim, hidden_dim, bias=False)
    this.upProj = QuantizedLinear.load(weights, `${prefix}.up_proj`, config);
    this.downProj = QuantizedLinear.load(weights, `${prefix}.down_proj`, config);
    this.#gate = new QuantizedLinearPlain(this.gateProj);
    this.#up = new QuantizedLinearPlain(this.upProj);
    this.#down = new QuantizedLinearPlain(this.downProj);
  }

  forward(x: MlxArray): MlxArray {
    const g = this.#gate.forward(x);                                // self.gate_proj(x)
    const u = this.#up.forward(x);                                  // self.up_proj(x)
    const s = compiledSwiglu(g, u);                                    // swiglu(gate, x)  (mx.compile)
    g.dispose(); u.dispose();
    const y = this.#down.forward(s); s.dispose();                  // self.down_proj(...)
    return y;
  }
}

// ── switch_layers.py SwitchGLU (swiglu activation, quantized experts) ─────────
// The three per-expert projections are the stacked switch_mlp.{gate,up,down}_proj
// tensors; the activation is the SAME @mx.compile swiglu as activations.py.
export class Qwen3SwitchWeights {
  readonly gateProj: QuantizedSwitchLinear;
  readonly upProj: QuantizedSwitchLinear;
  readonly downProj: QuantizedSwitchLinear;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.gateProj = QuantizedSwitchLinear.load(weights, `${prefix}.gate_proj`, config);
    this.upProj = QuantizedSwitchLinear.load(weights, `${prefix}.up_proj`, config);
    this.downProj = QuantizedSwitchLinear.load(weights, `${prefix}.down_proj`, config);
  }
}

interface ExpertForward { forward(x: MlxArray, indices: MlxArray): MlxArray }

/** Gather projections over the original token order. */
export class Qwen3UnsortedExperts implements ExpertForward {
  constructor(readonly weights: Qwen3SwitchWeights) {}
  forward(x: MlxArray, indices: MlxArray): MlxArray {
    using rows = ops.expandDims(x, -2);
    using expanded = ops.expandDims(rows, -3);
    using up = this.weights.upProj.forward(expanded, indices, false);
    using gate = this.weights.gateProj.forward(expanded, indices, false);
    using hidden = compiledSwiglu(gate, up);
    const output = this.weights.downProj.forward(hidden, indices, false);
    const shape = output.shape;
    shape.splice(shape.length - 2, 1);
    return disposing(output, ops.reshape(output, shape));
  }
}

/** Sorted gather followed by the reference inverse permutation. */
export class Qwen3SortedExperts implements ExpertForward {
  constructor(readonly weights: Qwen3SwitchWeights) {}
  forward(x: MlxArray, indices: MlxArray): MlxArray {
    const topK = indices.shape[indices.ndim - 1]!;
    using rows = ops.expandDims(x, -2);
    using expanded = ops.expandDims(rows, -3);
    using flatIndices = ops.reshape(indices, [indices.size]);
    using order = ops.argsortAxis(flatIndices, 0);
    using inverse = ops.argsortAxis(order, 0);
    using count = ops.scalarLike(topK, order);
    using rowIndices = ops.floorDivide(order, count);
    const width = expanded.shape[4]!;
    using flat = ops.reshape(expanded, [-1, 1, width]);
    using sortedRows = ops.takeAxis(flat, rowIndices, 0);
    using sortedIndices = ops.takeAxis(flatIndices, order, 0);
    using up = this.weights.upProj.forward(sortedRows, sortedIndices, true);
    using gate = this.weights.gateProj.forward(sortedRows, sortedIndices, true);
    using hidden = compiledSwiglu(gate, up);
    using sortedOutput = this.weights.downProj.forward(hidden, sortedIndices, true);
    using output = ops.takeAxis(sortedOutput, inverse, 0);
    const [batch, length, selected] = indices.shape;
    const outputWidth = output.shape[output.ndim - 1]!;
    using unflattened = ops.reshape(output, [batch!, length!, selected!, 1, outputWidth]);
    const shape = unflattened.shape;
    shape.splice(shape.length - 2, 1);
    return ops.reshape(unflattened, shape);
  }
}

// ── qwen3_moe.py Qwen3MoeSparseMoeBlock ──────────────────────────────────────
class Qwen3MoeSparseMoeBlock {
  readonly kind = "moe";
  readonly gate: QuantizedLinear;
  readonly switchMlp: Qwen3SwitchWeights;
  readonly numExperts: number;
  readonly topK: number;
  readonly normTopkProb: boolean;
  readonly #gate: QuantizedLinearPlain;
  readonly #normalize: (scores: MlxArray) => MlxArray;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    const t = config.text;
    this.numExperts = t.numExperts;                                   // self.num_experts
    this.topK = t.topKExperts;                                        // self.top_k
    this.normTopkProb = t.normTopkProb;                              // self.norm_topk_prob
    this.gate = QuantizedLinear.load(weights, `${prefix}.gate`, config); // nn.Linear(dim, num_experts, bias=False)
    this.switchMlp = new Qwen3SwitchWeights(weights, config, `${prefix}.switch_mlp`); // SwitchGLU(dim, moe_inter, num_experts)
    this.#gate = new QuantizedLinearPlain(this.gate);
    this.#normalize = this.normTopkProb ? scores => {
      using denominator = ops.sumAxis(scores, -1, true);
      return disposing(scores, ops.div(scores, denominator));
    } : scores => scores;
  }

  forward(x: MlxArray, experts: ExpertForward): MlxArray {
    let gates = this.#gate.forward(x);                                 // gates = self.gate(x)
    gates = disposing(gates, ops.softmaxAxis(gates, -1, true));      // gates = mx.softmax(gates, axis=-1, precise=True)

    const k = this.topK;
    const [B, L] = gates.shape as [number, number, number];
    // inds = mx.argpartition(gates, kth=-k, axis=-1)[..., -k:]
    const part = ops.argpartitionAxis(gates, this.numExperts - k, -1); // argpartition(..., kth=-k)
    const inds = part.slice([0, 0, this.numExperts - k], [B, L, this.numExperts]);
    part.dispose();

    let scores = ops.takeAlongAxis(gates, inds, -1);                 // scores = mx.take_along_axis(gates, inds, axis=-1)
    gates.dispose();
    scores = this.#normalize(scores);

    const y = experts.forward(x, inds);                       // y = self.switch_mlp(x, inds)
    inds.dispose();
    // y = (y * scores[..., None]).sum(axis=-2)
    const sExp = ops.expandDims(scores, -1);                        // scores[..., None]
    scores.dispose();
    const wy = ops.mul(y, sExp);                                    // y * scores[..., None]
    y.dispose(); sExp.dispose();
    return disposing(wy, ops.sumAxis(wy, -2, false));               // .sum(axis=-2)
  }
}

// ── qwen3_moe.py Qwen3MoeDecoderLayer ────────────────────────────────────────
class Qwen3MoeDecoderLayer {
  readonly selfAttn: Qwen3Attention;
  readonly mlp: Qwen3MoeSparseMoeBlock | MLP;
  readonly inputLayernorm: RMSNorm;
  readonly postAttentionLayernorm: RMSNorm;

  constructor(weights: Weights, config: ModelConfig, prefix: string, layerIdx: number) {
    const t = config.text;
    this.selfAttn = new Qwen3Attention(weights, config, `${prefix}.self_attn`, MOE_ROPE_THETA);
    this.inputLayernorm = new RMSNorm(weights.tensor(`${prefix}.input_layernorm.weight`), t.rmsNormEps);
    this.postAttentionLayernorm = new RMSNorm(weights.tensor(`${prefix}.post_attention_layernorm.weight`), t.rmsNormEps);
    // if (layer_idx not in mlp_only_layers) and (num_experts > 0 and
    //     (layer_idx + 1) % decoder_sparse_step == 0): Qwen3MoeSparseMoeBlock else MLP
    const isMoe =
      !t.mlpOnlyLayers.includes(layerIdx) &&
      t.numExperts > 0 &&
      (layerIdx + 1) % t.decoderSparseStep === 0;
    this.mlp = isMoe
      ? new Qwen3MoeSparseMoeBlock(weights, config, `${prefix}.mlp`)
      : new MLP(weights, config, `${prefix}.mlp`);
  }
}

class FixedMoeBlock {
  constructor(readonly weights: Qwen3MoeSparseMoeBlock, readonly experts: ExpertForward) {}
  forward(x: MlxArray): MlxArray { return this.weights.forward(x, this.experts); }
}
class Qwen3MoeLayerView {
  readonly #mlp: MLP | FixedMoeBlock;
  constructor(readonly base: Qwen3MoeDecoderLayer, Experts: new (weights: Qwen3SwitchWeights) => ExpertForward) {
    this.#mlp = base.mlp.kind === "dense" ? base.mlp : new FixedMoeBlock(base.mlp, new Experts(base.mlp.switchMlp));
  }
  forward(x: MlxArray, cache: Cache, phase: ReadPhase): MlxArray {
    const xn = this.base.inputLayernorm.forward(x);                       // self.input_layernorm(x)
    const r1 = this.base.selfAttn.forward(xn, cache, phase);             // r = self.self_attn(..., mask, cache)
    xn.dispose();
    const h = ops.add(x, r1); r1.dispose();                        // h = x + r
    const hn = this.base.postAttentionLayernorm.forward(h);             // self.post_attention_layernorm(h)
    const r2 = this.#mlp.forward(hn); hn.dispose();                 // r = self.mlp(...)
    const out = ops.add(h, r2); h.dispose(); r2.dispose();        // out = h + r
    return out;
  }
}

// ── qwen3_moe.py Qwen3MoeModel + Model ───────────────────────────────────────
export class Qwen3MoeModel implements MlxDeclaredGraph, MlxTokenPhases {
  readonly config: ModelConfig;
  readonly weightsBytes: number;
  readonly prefixBase = "model";
  readonly loraState = new LoraState();
  /** An ordinary autoregressive graph: every method over every cache lego. */
  get graphCapabilities(): GraphDeclaration { return declareGraph(); }
  readonly embed: QuantizedEmbedding;
  readonly layers: Qwen3MoeDecoderLayer[];
  readonly finalNorm: RMSNorm;
  /** Untied lm_head (tie_word_embeddings=false for this family). */
  readonly lmHead: QuantizedLinear | null;
  readonly #head: (hidden: MlxArray) => MlxArray;

  constructor(weights: Weights, config: ModelConfig, maxPhaseRows = DEFAULT_PHASE_ROWS) {
    this.config = config;
    this.weightsBytes = [...weights.shards.files.values()]
      .reduce((a, f) => a + f.mmap.size, 0);
    this.embed = QuantizedEmbedding.load(weights, "model.embed_tokens", config); // nn.Embedding
    this.layers = Array.from(
      { length: config.text.numHiddenLayers },
      (_, i) => new Qwen3MoeDecoderLayer(weights, config, `model.layers.${i}`, i),
    );
    this.finalNorm = new RMSNorm(weights.tensor("model.norm.weight"), config.text.rmsNormEps); // self.norm
    this.lmHead = config.text.tieWordEmbeddings
      ? null
      : QuantizedLinear.load(weights, "lm_head", config);           // self.lm_head

    const head = this.lmHead && new QuantizedLinearPlain(this.lmHead);
    this.#head = head ? hidden => head.forward(hidden) : hidden => this.embed.asLinear(hidden);
    const unsorted = this.layers.map(layer => new Qwen3MoeLayerView(layer, Qwen3UnsortedExperts));
    const sorted = this.layers.map(layer => new Qwen3MoeLayerView(layer, Qwen3SortedExperts));
    const sortFrom = Math.ceil(64 / config.text.topKExperts);
    const decodeUnsorted = (ids: MlxArray, cache: Cache[]) => this.forwardLayers(this.embed.encode(ids), cache, "decode", unsorted);
    const decodeSorted = (ids: MlxArray, cache: Cache[]) => this.forwardLayers(this.embed.encode(ids), cache, "decode", sorted);
    const windowUnsorted = (ids: MlxArray, cache: Cache[]) => this.forwardLayers(this.embed.encode(ids), cache, "window", unsorted);
    const windowSorted = (ids: MlxArray, cache: Cache[]) => this.forwardLayers(this.embed.encode(ids), cache, "window", sorted);
    this.prompt = [{ from: 1, to: sortFrom - 1, operation: windowUnsorted }, { from: sortFrom, to: Infinity, operation: windowSorted }]
      .filter(range => range.from <= range.to);
    this.promptChunk = this.prompt;
    this.multiSequencePrompt = this.prompt;
    this.multiSequencePromptChunk = this.multiSequencePrompt;
    this.decode = rowTableFrom(rows => rows < sortFrom ? decodeUnsorted : decodeSorted, maxPhaseRows);
    const windows = rowTableFrom(rows => rows < sortFrom ? windowUnsorted : windowSorted, maxPhaseRows);
    this.verify = windows;
    this.logits = rowTable(hidden => this.#head(hidden), maxPhaseRows);
    const sequence: MlxSequenceRange[] = [
      { from: 1, to: sortFrom - 1, operation: (ids, cache) => windowUnsorted(ids, cache) },
      { from: sortFrom, to: Infinity, operation: (ids, cache) => windowSorted(ids, cache) },
    ];
    this.sequence = sequence.filter(range => range.from <= range.to);
    this.appendKnown = this.sequence;

    this.cacheLayers = this.layers.map(() => ({kind:"full" as const,turboQuant:"dense" as const}));
  }

  loraTargets(): Map<string, QuantizedLinear> {
    const out = new Map<string, QuantizedLinear>();
    for (let i = 0; i < this.layers.length; i++) {
      const l = this.layers[i]!;
      const p = `model.layers.${i}`;
      out.set(`${p}.self_attn.q_proj`, l.selfAttn.qProj);
      out.set(`${p}.self_attn.k_proj`, l.selfAttn.kProj);
      out.set(`${p}.self_attn.v_proj`, l.selfAttn.vProj);
      out.set(`${p}.self_attn.o_proj`, l.selfAttn.oProj);
      if (l.mlp.kind === "dense") {
        out.set(`${p}.mlp.gate_proj`, l.mlp.gateProj);
        out.set(`${p}.mlp.up_proj`, l.mlp.upProj);
        out.set(`${p}.mlp.down_proj`, l.mlp.downProj);
      }
      else out.set(`${p}.mlp.gate`, l.mlp.gate);
      // Stacked expert weights are separate from the two-dimensional router target.
    }
    return out;
  }

  /** Builds no constants and opens no weights: nothing to release. */
  dispose(): void {}

  /** One cache per layer, sharing one mask memo (create_attention_mask's one
   * mask per forward, built by the caches). Their TurboQuant read is dense
   * (`denseTurboQuantKernels`): the read decodes keys and values, then runs the
   * fused SDPA. */
  readonly cacheLayers: readonly MlxCacheLayer[];
  readonly sequence: readonly MlxSequenceRange[];


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
  protected forwardLayers(h0: MlxArray, cache: Cache[], phase: ReadPhase, layers: readonly Qwen3MoeLayerView[]): MlxArray {
    let cur = h0;
    for (let i = 0; i < layers.length; i++) {                  // for layer, c in zip(self.layers, cache)
      const next = layers[i]!.forward(cur, cache[i]!, phase);  // h = layer(h, mask, c)
      cur.dispose();
      cur = next;
    }
    return disposing(cur, this.finalNorm.forward(cur));            // return self.norm(h)
  }

  logitsFromHidden(h: MlxArray): MlxArray {
    return this.#head(h); // self.lm_head(out)
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Qwen.Qwen3Moe
