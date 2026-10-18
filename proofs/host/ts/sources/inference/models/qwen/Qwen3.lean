import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Qwen.Qwen3
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/qwen/qwen3.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxCacheLayer, MlxMixedRange, MlxSequenceRange } from "../../contracts/mlx/graph";
// Concrete model graph for plain Qwen3 (Qwen3ForCausalLM).
// Port target: mlx_lm.models.qwen3. A standard dense decoder — GQA softmax
// attention with per-head q/k RMSNorm (applied over head_dim BEFORE RoPE),
// full-head RoPE (theta 1e6), SwiGLU MLP, RMSNorm, tied embeddings.
//
// Primary use here is as a TEXT-EMBEDDING backbone (mlx-community Qwen3-Embedding-*):
// `embedPooled` returns the last-token hidden, L2-normalized — the pooling
// Qwen3-Embedding was trained with (an <|endoftext|> token is appended by the
// caller; its hidden is the sentence vector). The full causal-LM surface
// (forward/generate via the tied head) is wired too so it conforms to RuntimeModel.
//
// Each attention block reads its cache through the cache contract for the
// phase its caller names (`ReadPhase`); the cache was composed with its read.

import type { ModelConfig } from "../../artifacts/config";
import type { Weights } from "../../artifacts/weights";
import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { disposing } from "../../layers/helpers";
import { composedFullAttentionCache } from "../../state/bf16-first-kv";
import { AttentionMasks } from "../../state/attention-read";
import { denseTurboQuantKernels } from "../../state/turboquant-attention";
import { LoraState } from "../../layers/lora";
import type { GraphDeclaration } from "../../contracts/portable/graph";
import type { MlxRowTable, MlxCapturingForward, MlxDeclaredGraph, MlxHeadForward, MlxPhaseForward, MlxPromptRange, MlxTokenPhases, MlxVerifyForward } from "../../contracts/mlx/graph";
import { declareGraph } from "../capabilities";
import { DEFAULT_PHASE_ROWS,  rowTable, type ReadPhase   } from "../graph";
import { QuantizedEmbedding } from "../../layers/quantized-embedding";
import { QuantizedLinear, QuantizedLinearPlain } from "../../layers/quantized-linear";
import { RMSNorm } from "../../layers/normalization";
import { type Cache } from "../../contracts/mlx/cache";
import { compiledSwiglu } from "../../layers/swiglu";
import { cacheRead, type AttentionReadStrategy } from "./blocks";

/** Qwen3 attention (per-head q/k RMSNorm over head_dim before full-head RoPE,
 *  GQA). qwen3 and qwen3_moe share it; they differ only in the `rope_theta`
 *  default used when the config omits one. */
export class Qwen3Attention {
  readonly qProj: QuantizedLinear;
  readonly kProj: QuantizedLinear;
  readonly vProj: QuantizedLinear;
  readonly oProj: QuantizedLinear;
  readonly qNorm: RMSNorm;
  readonly kNorm: RMSNorm;
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
  constructor(weights: Weights, config: ModelConfig, prefix: string, defaultRopeBase = 1000000,
    readonly reads: AttentionReadStrategy = cacheRead) {
    const t = config.text;
    this.nHeads = t.numAttentionHeads;
    this.nKvHeads = t.numKeyValueHeads;
    this.headDim = t.headDim;
    this.scale = Math.pow(this.headDim, -0.5);
    this.ropeBase = t.ropeParameters.full_attention?.ropeTheta ?? defaultRopeBase;
    this.qProj = QuantizedLinear.load(weights, `${prefix}.q_proj`, config);
    this.kProj = QuantizedLinear.load(weights, `${prefix}.k_proj`, config);
    this.vProj = QuantizedLinear.load(weights, `${prefix}.v_proj`, config);
    this.oProj = QuantizedLinear.load(weights, `${prefix}.o_proj`, config);
    this.qNorm = new RMSNorm(weights.tensor(`${prefix}.q_norm.weight`), t.rmsNormEps);
    this.kNorm = new RMSNorm(weights.tensor(`${prefix}.k_norm.weight`), t.rmsNormEps);
    this.#q = new QuantizedLinearPlain(this.qProj);
    this.#k = new QuantizedLinearPlain(this.kProj);
    this.#v = new QuantizedLinearPlain(this.vProj);
    this.#out = new QuantizedLinearPlain(this.oProj);
  }

  /** `x` [B, L, hidden] (borrowed) to an owned [B, L, hidden], appending to
   *  `cache` and attending through the read `phase` names. */
  forward(x: MlxArray, cache: Cache, phase: ReadPhase): MlxArray {
    const [B, L] = x.shape as [number, number, number];
    let q = this.#q.forward(x);
    let k = this.#k.forward(x);
    let v = this.#v.forward(x);

    // Reshape to heads, then q/k RMSNorm over head_dim BEFORE transpose+RoPE
    // (mlx-lm qwen3 reference order).
    q = disposing(q, ops.reshape(q, [B, L, this.nHeads, this.headDim]));
    k = disposing(k, ops.reshape(k, [B, L, this.nKvHeads, this.headDim]));
    v = disposing(v, ops.reshape(v, [B, L, this.nKvHeads, this.headDim]));
    q = disposing(q, this.qNorm.forward(q));
    k = disposing(k, this.kNorm.forward(k));

    q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));
    k = disposing(k, ops.transposeAxes(k, [0, 2, 1, 3]));
    v = disposing(v, ops.transposeAxes(v, [0, 2, 1, 3]));

    q = disposing(q, ops.rope(q, this.headDim, this.ropeBase, cache.offset, null));
    k = disposing(k, ops.rope(k, this.headDim, this.ropeBase, cache.offset, null));

    // The cache attends with the kernel it was composed with: mlx-lm's
    // scaled_dot_product_attention reads quantized caches through quantized SDPA.
    let attn: MlxArray;
    try {
      const read = this.reads.read(cache, phase, k, v);
      try { attn = read.attend(q, this.scale); } finally { read.dispose(); }
    } finally { k.dispose(); v.dispose(); q.dispose(); }

    const attnT = ops.transposeAxes(attn, [0, 2, 1, 3]);
    attn.dispose();
    const merged = ops.reshape(attnT, [B, L, -1]);
    attnT.dispose();
    const out = this.#out.forward(merged);
    merged.dispose();
    return out;
  }
}

export class Qwen3MLP {
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

  forward(x: MlxArray): MlxArray {
    const gate = this.#gate.forward(x);
    const up = this.#up.forward(x);
    // Oracle (mlx_lm/models/qwen3.py MLP): down_proj(swiglu(gate_proj(x), up_proj(x)))
    // where swiglu is the `@mx.compile` closure (silu(gate)*up). Compiled = the
    // same libmlx kernel mlx-lm dispatches (L1-faithful) AND fuses the three
    // standalone ops into one dispatch. Bit-identical to the old unfused path.
    const hidden = compiledSwiglu(gate, up);
    gate.dispose();
    up.dispose();
    const out = this.#down.forward(hidden);
    hidden.dispose();
    return out;
  }
}

export class Qwen3Layer {
  readonly attn: Qwen3Attention;
  readonly mlp: Qwen3MLP;
  readonly inputNorm: RMSNorm;
  readonly postAttnNorm: RMSNorm;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.attn = new Qwen3Attention(weights, config, `${prefix}.self_attn`);
    this.mlp = new Qwen3MLP(weights, config, `${prefix}.mlp`);
    this.inputNorm = new RMSNorm(weights.tensor(`${prefix}.input_layernorm.weight`), config.text.rmsNormEps);
    this.postAttnNorm = new RMSNorm(weights.tensor(`${prefix}.post_attention_layernorm.weight`), config.text.rmsNormEps);
  }

  forward(x: MlxArray, cache: Cache, phase: ReadPhase): MlxArray {
    const xn = this.inputNorm.forward(x);
    const a = this.attn.forward(xn, cache, phase);
    xn.dispose();
    const h = ops.add(x, a);
    a.dispose();
    const hn = this.postAttnNorm.forward(h);
    const m = this.mlp.forward(hn);
    hn.dispose();
    const out = ops.add(h, m);
    h.dispose();
    m.dispose();
    return out;
  }
}

export class Qwen3Model implements MlxDeclaredGraph, MlxTokenPhases {
  readonly config: ModelConfig;
  readonly weightsBytes: number;
  readonly prefixBase = "model";
  readonly loraState = new LoraState();
  /** An ordinary autoregressive graph that also exposes the pooled embedding path. */
  get graphCapabilities(): GraphDeclaration { return declareGraph(); }
  readonly embed: QuantizedEmbedding;
  readonly layers: Qwen3Layer[];
  readonly finalNorm: RMSNorm;
  /** Separate lm_head when NOT tied; otherwise the tied embedding's asLinear. */
  readonly lmHead: QuantizedLinear | null;
  readonly #head: (hidden: MlxArray) => MlxArray;

  constructor(weights: Weights, config: ModelConfig, maxPhaseRows = DEFAULT_PHASE_ROWS) {
    this.config = config;
    this.weightsBytes = [...weights.shards.files.values()]
      .reduce((a, f) => a + f.mmap.size, 0);
    this.embed = QuantizedEmbedding.load(weights, "model.embed_tokens", config);
    this.layers = Array.from(
      { length: config.text.numHiddenLayers },
      (_, i) => new Qwen3Layer(weights, config, `model.layers.${i}`),
    );
    this.finalNorm = new RMSNorm(weights.tensor("model.norm.weight"), config.text.rmsNormEps);
    this.lmHead = config.text.tieWordEmbeddings
      ? null
      : QuantizedLinear.load(weights, "lm_head", config);
    const head = this.lmHead && new QuantizedLinearPlain(this.lmHead);
    this.#head = head ? hidden => head.forward(hidden) : hidden => this.embed.asLinear(hidden);

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

    this.cacheLayers = this.layers.map(() => ({kind:"full" as const,turboQuant:"dense" as const}));
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

  /** One cache per layer, sharing one mask memo. Their TurboQuant read is dense
   * (`denseTurboQuantKernels`): the read decodes keys and values, then runs the
   * fused SDPA. */
  readonly cacheLayers: readonly MlxCacheLayer[];
  readonly sequence: readonly MlxSequenceRange[];


  /** The scoring forward (`MlxSequenceForward`): the window read at every width. */
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
    let cur = h0;
    for (let i = 0; i < this.layers.length; i++) {
      const next = this.layers[i]!.forward(cur, cache[i]!, phase);
      cur.dispose();
      cur = next;
    }
    return disposing(cur, this.finalNorm.forward(cur));
  }

  /** Last-token pooled, L2-normalized sentence embedding for one sequence.
   *  ids [1, L] → vector [1, hidden]. The caller appends the EOS/eod token
   *  (Qwen3-Embedding's pooling token) to `ids`. */
  embedPooled(this: Qwen3Model & { makeCache(): Cache[] }, ids: MlxArray): MlxArray {
    const cache = this.makeCache();
    try {
      const h = this.forwardLayers(this.embed.encode(ids), cache, "window"); // [1, L, hidden]
      const [B, L, H] = h.shape as [number, number, number];
      const last = h.slice([0, L - 1, 0], [B, L, H]); // [1, 1, hidden]
      h.dispose();
      const vec = disposing(last, ops.reshape(last, [B, H])); // [1, hidden]
      // L2 normalize: x / max(||x||_2, eps)
      const sq = ops.square(vec);
      const ss = disposing(sq, ops.sumAxis(sq, -1, true));
      const norm = disposing(ss, ops.sqrt(ss));
      const out = ops.div(vec, norm);
      vec.dispose();
      norm.dispose();
      return out;
    } finally {
      for (const c of cache) c.dispose();
    }
  }

  logitsFromHidden(h: MlxArray): MlxArray {
    return this.#head(h);
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Qwen.Qwen3
