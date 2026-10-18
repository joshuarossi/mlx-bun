import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Gemma4.Model
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/gemma4/model.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxCacheLayer, MlxMixedRange, MlxSequenceRange } from "../../contracts/mlx/graph";
// Gemma 4 text model — line-for-line port of mlx-lm's gemma4_text.py
// (oracle venv site-packages), covering the paths our target models
// exercise: 12B (dense), e4b (per-layer-input embeddings + KV-shared
// layers), 26B-A4B (MoE block: router + gather_qmm experts).
//
// Parity notes:
// - SDPA scale is 1.0 (Gemma4 normalizes q/k instead).
// - Full-attention layers: global_head_dim 512, 1 global KV head,
//   attention_k_eq_v (V = same projection as K, with un-scaled RMS norm);
//   ProportionalRoPE rotates only partial_rotary_factor·dims dims.
// - Python-float scalars promote weakly to the array dtype.
// - Replicate mlx python helper implementations exactly (x**3 is
//   mx.power, not x·x·x — they round differently in bf16).
//
// Reads: every attention block reads its layer's cache through the read the
// caller's phase names (contracts/mlx/cache.ts AttentionCache), so the cache
// builds the mask (sliding layers compose RotatingKVCache, whose reads own the
// window) and attends with the kernel it was composed with. The graph never
// inspects the query count, builds a mask or chooses a kernel, the training
// forward (gradient checkpointing, prefix-shared and segmented training)
// included: it reads its stateless training caches the same way. The blocks
// (attention, feed-forward, per-layer inputs, KV sharing, decoder layer) live in
// blocks.ts, which the written graph files compose too.

import { disposeResources } from "../../runtime/resources";
import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { ModelConfig } from "../../artifacts/config";
import type { Weights } from "../../artifacts/weights";
import { Checkpoint } from "@mlx-bun/mlx/checkpoint";
import { LoraState } from "../../layers/lora";
import type { GraphDeclaration } from "../../contracts/portable/graph";
import type { MlxCapturingForward, MlxRowTable, MlxCompiledDecodeStep, MlxDeclaredGraph, MlxHeadForward, MlxLayerCapture, MlxMixedForward, MlxPhaseForward, MlxKnownOperations, MlxPromptRange, MlxTokenPhases, MlxVerifyForward } from "../../contracts/mlx/graph";
import { CompiledDecode } from "./compiled-decode";
import type { TargetView } from "../../contracts/mlx/draft-target";
import type { TrainableGraph } from "../../contracts/mlx/trainable";
import { gemma4Trainable, type GradCheckpointCtx, type LayerLoras } from "./trainable";
import type { MediaEncoders, MediaSidecarProbes, MlxPromptInput, Vision } from "../../contracts/mlx/media";
import { declareGraph } from "../capabilities";
import { DEFAULT_PHASE_ROWS,  rowTable   } from "../graph";
import { bindGemma4MediaInput, gemma4DraftTarget, gemma4MediaEncoders } from "./media";
import type { AttentionRead, Cache, SharedKv, TrainingAttentionCache } from "../../contracts/mlx/cache";
import { CompiledGegluMLP, PlainGegluMLP, CompiledGeglu } from "../../layers/geglu";
import { ServingDenseLayer, ServingMoeLayer } from "./serving-blocks";
import { FixedExperts, SortedSwitchGLU, UnsortedSwitchGLU } from "./blocks";
import type { MlxEmbeddingsRange } from "../../contracts/mlx/media";
import type { MlxSeparateMixed, MlxPhaseGroup } from "../../contracts/mlx/graph";
import { mapPackedTokens } from "../../input/token-groups";
import { disposing } from "../../layers/helpers";
import { RMSNorm } from "../../layers/normalization";
import { QuantizedEmbedding } from "../../layers/quantized-embedding";
import type { QuantizedLinear } from "../../layers/quantized-linear";
import { logitSoftcap } from "../../kernels/logits";
import { compiledLogitSoftcap } from "../../kernels/softcap";
import { AttentionMasks } from "../../state/attention-read";
import { composedFullAttentionCache, composedSlidingAttentionCache } from "../../state/bf16-first-kv";
import { deferredTurboQuantKernels } from "../../state/turboquant-attention";
import {
  DecoderLayer, kvDonors, PerLayerInputs, type Attention, type DonorRead, type Gemma4Phase,
} from "./blocks";

/** A donor layer's keys and values in the training forward: the keys (RoPE
 * applied) and values it appended to its training cache, which its sharers read
 * through that cache and which cross checkpoint and segment boundaries as
 * tensors. */
type DecoderOperation = Pick<DecoderLayer,"forward"|"forwardAttn"|"forwardMlp">;

type PlainSharedKv = Extract<SharedKv, { kind: "plain" }>;

/** The training forward's attention (`Gemma4Model.forwardTrainingHidden`,
 *  gradient checkpointing and the segmented backward) over `attn`'s
 *  projections, roped block-wise under a prefix-shared layout. `cache` is the
 *  training cache of this layer, or of its donor for a KV-sharing layer; it
 *  stores nothing (`TrainingCache`, `PrefixSharedCache`), so its window read
 *  of the keys and values handed to it owns the mask (causal, windowed, padded
 *  or block-sparse) and the kernel the run composed, and a sharer reads its
 *  donor's keys and values (`sharedIn`) by appending them to the donor's cache
 *  again. Returns the attention output and the donor's keys and values (a
 *  sharer returns `sharedIn`); the caller owns those of a donor and disposes
 *  them after the pass. */
function attentionTraining(
  attn: Attention, x: MlxArray, cache: TrainingAttentionCache, sharedIn: PlainSharedKv | null,
): { out: MlxArray; shared: PlainSharedKv } {
  const [B, L] = x.shape as [number, number, number];

  let q = attn.qProj.forward(x);
  q = disposing(q, ops.reshape(q, [B, L, attn.nHeads, attn.headDim]));
  q = disposing(q, attn.qNorm.forward(q));

  let shared: PlainSharedKv;
  let read: AttentionRead;
  if (!attn.hasKv) {
    if (!sharedIn) throw new Error("KV-shared layer received no shared KV");
    shared = sharedIn;
    read = cache.appendWindow(shared.keys, shared.values);
  } else {
    let k = attn.kProj!.forward(x);
    k = disposing(k, ops.reshape(k, [B, L, attn.nKvHeads, attn.headDim]));
    let v: MlxArray;
    if (attn.vProj) {
      v = attn.vProj.forward(x);
      v = disposing(v, ops.reshape(v, [B, L, attn.nKvHeads, attn.headDim]));
    } else {
      v = k; // attention_k_eq_v: shared projection; norms differ below
    }

    const kNormed = attn.kNorm!.forward(k);
    const kT = ops.transposeAxes(kNormed, [0, 2, 1, 3]);
    kNormed.dispose();
    const kRoped = cache.ropePositions(kT, (block, offset) => attn.rope(block, offset));
    kT.dispose();

    const vNormed = attn.vNorm!.forward(v);
    const vT = ops.transposeAxes(vNormed, [0, 2, 1, 3]);
    vNormed.dispose();
    if (v !== k) v.dispose();
    k.dispose();

    try { read = cache.appendWindow(kRoped, vT); }
    catch (error) { kRoped.dispose(); vT.dispose(); throw error; }
    shared = { kind: "plain", keys: kRoped, values: vT, offset: cache.offset };
  }

  let out: MlxArray;
  try {
    q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));
    q = disposing(q, cache.ropePositions(q, (block, offset) => attn.rope(block, offset)));
    out = read.attend(q, 1.0);
  } finally { read.dispose(); }
  q.dispose();
  const attnT = ops.transposeAxes(out, [0, 2, 1, 3]);
  out.dispose();
  const merged = ops.reshape(attnT, [B, L, -1]);
  attnT.dispose();
  return { out: disposing(merged, attn.oProj.forward(merged)), shared };
}

/** The training forward's attention sub-block of `layer` (see
 *  `DecoderLayer.forwardAttn`): inputNorm → `attentionTraining` → postAttnNorm →
 *  residual add. */
function layerAttnTraining(
  layer: DecoderLayer, x: MlxArray, cache: TrainingAttentionCache, sharedIn: PlainSharedKv | null,
): { h: MlxArray; shared: PlainSharedKv } {
  let h = layer.inputNorm.forward(x);
  const { out, shared } = attentionTraining(layer.attn, h, cache, sharedIn);
  h.dispose();
  h = out;
  h = disposing(h, layer.postAttnNorm.forward(h));
  h = disposing(h, ops.add(x, h));
  return { h, shared };
}

/** The training forward's layer (see `attentionTraining`). The split into two
 *  sub-blocks lets the checkpoint path rematerialize attention and MLP
 *  separately (peak attn+MLP → max(attn,MLP)+hMid). */
function layerTraining(
  layer: DecoderLayer, x: MlxArray, cache: TrainingAttentionCache,
  sharedIn: PlainSharedKv | null, perLayerInput: MlxArray | null,
): { h: MlxArray; shared: PlainSharedKv } {
  const { h: hMid, shared } = layerAttnTraining(layer, x, cache, sharedIn);
  const h = layer.forwardMlp(hMid, perLayerInput);
  hMid.dispose();
  return { h, shared };
}

export class Gemma4Model implements MlxDeclaredGraph, MlxTokenPhases {
  #disposed = false;
  readonly config: ModelConfig;
  /** Total weight-shard bytes (for the conditional wired-limit scope). */
  readonly weightsBytes: number;
  /** Weight-name prefix ("language_model.model" or "model"). */
  readonly prefixBase: string;
  /** Active LoRA adapters for the current generation (see LoraState). */
  readonly loraState = new LoraState();
  /** Prepared image/audio embeddings, layer taps for drafts, and a compiled
   * decode step, except through experts: shapeless replay
   * retraces their growing windows. */
  get graphCapabilities(): GraphDeclaration {
    return declareGraph({
      media: { input: "embeddings", video: false }, hiddenLayerTaps: true,
      compiledDecode: this.config?.modelType?.startsWith("gemma4") === true && !this.config.text.enableMoeBlock,
    });
  }
  #trainable: TrainableGraph | undefined;
  /** Segmented backward with KV-shared donor threading, prefix-shared ORPO,
   * gradient checkpointing, and the quantized tied head. Flash training
   * attention is refused: e4b crashes natively on it at long sequences. */
  get trainable(): TrainableGraph { return this.#trainable ??= gemma4Trainable(this); }
  bindMediaInput(input: Vision): MlxPromptInput { return bindGemma4MediaInput(this, input); }
  mediaEncoders(modelDir: string, probes: MediaSidecarProbes): Promise<MediaEncoders> {
    return gemma4MediaEncoders(this, modelDir, probes);
  }
  draftTarget(caches: Cache[]): TargetView { return gemma4DraftTarget(this, caches); }
  /** The compiled decode step declared above: the step records this graph's own
   * forward, so it shares the graph's weights and constants. */
  compiledDecodeStep(): MlxCompiledDecodeStep { return CompiledDecode.for(this); }
  releaseCompiledDecode(): void { CompiledDecode.release(this); }
  readonly embed: QuantizedEmbedding;
  readonly layers: DecoderLayer[];
  readonly finalNorm: RMSNorm;
  readonly embedScale: number;
  readonly windowSize: number;
  /** Donor count: layers [0, numDonors) own caches; the rest share. */
  readonly numDonors: number;
  /** layer idx → donor layer idx whose fetched KV it consumes (self for donors). */
  readonly previousKvs: number[];
  /** layer idx → cache index (donors only; -1 for sharers). */
  readonly cacheIndex: number[];
  /** Set by the trainer around its training forwards to checkpoint each layer
   *  (null = off). While set, the scoring and training forward
   *  (`sequenceHidden`) runs the training forward (`forwardTrainingHidden`'s),
   *  whose donors hand their sharers keys and values as checkpoint tensors. */
  gradCkpt: GradCheckpointCtx | null = null;
  // e2b/e4b per-layer input machinery (the block and its parts)
  readonly perLayerInputs: PerLayerInputs | null;
  readonly perLayerEmbed: QuantizedEmbedding | null;
  readonly perLayerModelProjection: QuantizedLinear | null;
  readonly perLayerProjectionNorm: RMSNorm | null;
  readonly perLayerWidth: number;
  readonly #servingLayers: readonly ServingDenseLayer[];
  readonly #sortedLayers: readonly ServingDenseLayer[];
  readonly traceLayers: readonly ServingDenseLayer[];
  readonly traceDecode: MlxCapturingForward;
  readonly #ordinarySlice: PerLayerInputs["ordinaryLayer"] | undefined;
  readonly #traceSlice: PerLayerInputs["traceLayer"] | undefined;
  readonly traceLogits = (hidden: MlxArray) => this.#head(hidden, logitSoftcap);
  readonly mediaPrefill: readonly MlxEmbeddingsRange[];
  readonly embeddingPrompt: readonly MlxEmbeddingsRange[];
  readonly mixed: readonly MlxMixedRange[];
  readonly mixedSeparate: MlxSeparateMixed;
  constructor(weights: Weights, config: ModelConfig, maxPhaseRows = DEFAULT_PHASE_ROWS) {
    const t = config.text;
    if (t.hiddenSize === 0 || !config.text.tieWordEmbeddings)
      throw new Error("only tied-embedding text configs are supported");

    this.config = config;
    this.weightsBytes = [...weights.shards.files.values()]
      .reduce((a, f) => a + f.mmap.size, 0);
    // gemma4_unified prefixes weights with language_model.; gemma4_text doesn't
    const prefixBase = weights.has("language_model.model.embed_tokens.weight")
      ? "language_model.model" : "model";
    this.prefixBase = prefixBase;
    this.embed = QuantizedEmbedding.load(weights, `${prefixBase}.embed_tokens`, config);

    this.numDonors = t.numHiddenLayers - t.numKvSharedLayers;
    this.layers = Array.from(
      { length: t.numHiddenLayers },
      (_, i) => new DecoderLayer(weights, config, prefixBase, i, i < this.numDonors, true),
    );
    // previous_kvs (reference Gemma4TextModel): sharer j uses the LAST
    // donor of its own layer type
    this.previousKvs = kvDonors(this.layers.map(layer => layer.layerType), this.numDonors);
    this.cacheIndex = this.layers.map((_, i) => (i < this.numDonors ? i : -1));

    this.finalNorm = new RMSNorm(
      weights.tensor(`${prefixBase}.norm.weight`),
      t.rmsNormEps,
    );
    this.embedScale = Math.sqrt(t.hiddenSize);
    this.windowSize = t.slidingWindow;

    this.perLayerInputs = t.hiddenSizePerLayerInput > 0 ? new PerLayerInputs(weights, config, prefixBase) : null;
    this.perLayerEmbed = this.perLayerInputs?.embed ?? null;
    this.perLayerModelProjection = this.perLayerInputs?.modelProjection ?? null;
    this.perLayerProjectionNorm = this.perLayerInputs?.projectionNorm ?? null;
    this.perLayerWidth = this.perLayerInputs?.width ?? 0;
    this.#servingLayers = this.layers.map(layer => layer.experts
      ? new ServingMoeLayer(layer, new CompiledGegluMLP(layer.mlp), new FixedExperts(new UnsortedSwitchGLU(layer.experts.switchGlu, new CompiledGeglu())))
      : new ServingDenseLayer(layer, new CompiledGegluMLP(layer.mlp)));
    this.#sortedLayers = this.layers.map(layer => layer.experts
      ? new ServingMoeLayer(layer, new CompiledGegluMLP(layer.mlp), new FixedExperts(new SortedSwitchGLU(layer.experts.switchGlu, new CompiledGeglu())))
      : new ServingDenseLayer(layer, new CompiledGegluMLP(layer.mlp)));
    this.#ordinarySlice = this.perLayerInputs?.ordinaryLayer.bind(this.perLayerInputs);
    this.#traceSlice = this.perLayerInputs?.traceLayer.bind(this.perLayerInputs);
    this.traceLayers = this.layers.map(layer => new ServingDenseLayer(layer, new PlainGegluMLP(layer.mlp)));
    this.traceDecode = (ids,cache,capture) => {
      const h = this.forwardDecoder(this.embedTokens(ids),cache,"decode",ids,capture,this.traceLayers,this.#traceSlice);
      capture?.(this.layers.length,h); return h;
    };

    // Artifact top-k determines the reference gather-sort boundary. Each
    // declared operation already owns its concrete expert and activation form.
    const boundary = t.enableMoeBlock ? Math.ceil(64 / t.topKExperts) : Infinity;
    const views = [{from:1,to:boundary-1,layers:this.#servingLayers}, {from:boundary,to:Infinity,layers:this.#sortedLayers}].filter(view=>Number.isFinite(view.from) && view.from<=view.to);
    this.prompt = views.map(view => ({from:view.from,to:view.to,operation:(ids,cache,capture)=>this.#window(ids,cache,capture,view.layers)}));
    this.promptChunk = this.prompt;
    this.multiSequencePrompt = this.prompt;
    this.multiSequencePromptChunk = this.multiSequencePrompt;
    const decode: Record<number,MlxCapturingForward> = {}, verify: Record<number,MlxCapturingForward> = {};
    for (let rows=1; rows<=maxPhaseRows; rows++) {
      const layers = rows < boundary ? this.#servingLayers : this.#sortedLayers;
      decode[rows] = (ids,cache,capture) => {
        const hidden = this.forwardDecoder(this.embedTokens(ids),cache,"decode",ids,capture,layers);
        capture?.(this.layers.length,hidden); return hidden;
      };
      verify[rows] = (ids,cache,capture) => this.#window(ids,cache,capture,layers);
    }
    this.decode = decode; this.verify = verify; this.appendKnown = views.map(view=>({from:view.from,to:view.to,operation:(ids,cache)=>this.#window(ids,cache,null,view.layers)}));
    this.logits = rowTable<MlxHeadForward>(hidden=>this.logitsFromHidden(hidden),maxPhaseRows);
    this.sequence = views.map(view=>({from:view.from,to:view.to,operation:(ids,cache)=>this.gradCkpt
      ? this.#forwardTraining(this.embedTokens(ids),cache,ids)
      : this.forwardDecoder(this.embedTokens(ids),cache,"window",ids,null,view.layers)}));
    this.mediaPrefill = views.map(view=>({from:view.from,to:view.to,operation:(embeddings,cache,imageMask,ids,multimodalMask)=>
      this.#prefillEmbeddings(embeddings,cache,imageMask,ids,multimodalMask,view.layers)}));
    this.embeddingPrompt = this.mediaPrefill;
    this.mixed = views.map(view=>({from:view.from,to:view.to,operation:groups=>this.#mixed(groups,view.layers)}));
    const separate = views.map(view=>({from:view.from,to:view.to,operation:(group:MlxPhaseGroup)=>{
      const hidden = this.forwardDecoder(this.embedTokens(group.ids),group.state,group.phase === "decode" ? "decode" : "window",group.ids,group.capture,view.layers);
      group.capture?.(this.layers.length,hidden); return hidden;
    }}));
    this.mixedSeparate = {decode:separate,window:separate,verify:separate};

    this.cacheLayers = this.layers.slice(0,this.numDonors).map(layer=>layer.layerType === "sliding_attention" ? {kind:"sliding" as const,window:this.windowSize}:{kind:"full" as const,turboQuant:"deferred" as const});
  }

  /** LoRA-mountable linears, keyed by weight-file module path: optiq
   *  mount.py's 7 target suffixes PLUS the e2b/e4b per-layer-input
   *  projections — mlx-lm's trainer targets those on e4b and optiq's
   *  mount silently drops their trained weights (we apply every adapter
   *  weight we can map).
   *  Expert pools stay non-targets (LoRASwitchLinear is future work). */
  loraTargets(): Map<string, QuantizedLinear> {
    const out = new Map<string, QuantizedLinear>();
    for (let i = 0; i < this.layers.length; i++) {
      const l = this.layers[i]!;
      const p = `${this.prefixBase}.layers.${i}`;
      const add = (suffix: string, lin: QuantizedLinear | null) => {
        if (lin) out.set(`${p}.${suffix}`, lin);
      };
      add("self_attn.q_proj", l.attn.qProj);
      add("self_attn.k_proj", l.attn.kProj);
      add("self_attn.v_proj", l.attn.vProj);
      add("self_attn.o_proj", l.attn.oProj);
      add("mlp.gate_proj", l.mlp.gate);
      add("mlp.up_proj", l.mlp.up);
      add("mlp.down_proj", l.mlp.down);
      add("per_layer_input_gate", l.perLayerGate);
      add("per_layer_projection", l.perLayerProjection);
    }
    return out;
  }

  /** Caches for donor layers only (sharers attend their donors' reads), all
   * sharing one mask memo, so each forward builds each mask once. Sliding
   * layers compose a ring of the sliding window, whose reads own the window
   * mask, and stay bf16 under TurboQuant. The full-attention caches' TurboQuant
   * read is deferred (`deferredTurboQuantKernels`): values stay rotated through
   * the fused SDPA and the read un-rotates the output. */
  readonly cacheLayers: readonly MlxCacheLayer[];
  readonly sequence: readonly MlxSequenceRange[];


  /** Release model-owned graph constants after all executions and compiled
   * runners have stopped. Weight tensors and hidden taps are borrowed. */
  dispose(): void {
    if (this.#disposed) return;
    this.#disposed = true;
    disposeResources(this.layers.flatMap(layer => layer.attn.ropeFreqs ? [layer.attn.ropeFreqs] : []));
  }

  /** Computed model constants must retain their constructor arithmetic when
   * a restored request enters compiled decode without a prefill first. */
  materializeGraphConstants(): void {
    const constants = this.layers.flatMap(layer => layer.attn.ropeFreqs ? [layer.attn.ropeFreqs] : []);
    if (constants.length) ops.evalAll(constants);
  }

  /** The scaled token embeddings [B, L, hidden] of `ids` (owned). */
  protected embedTokens(ids: MlxArray): MlxArray {
    const h = this.embed.encode(ids);
    return disposing(h, ops.mulScalar(h, this.embedScale));
  }

  /** One whole chunk of a prompt: tokens per sequence equal the composition's
   * prefill chunk size; rows are sequences times that size. Token ids only: a
   * prompt with prepared media enters through the `MlxPromptInput` that
   * `bindMediaInput` returns. The GPU is this graph's one unit. */
  readonly prompt: readonly MlxPromptRange[];
  readonly promptChunk: typeof this.prompt;
  readonly multiSequencePromptChunk: typeof this.multiSequencePrompt;
  readonly multiSequencePrompt: readonly MlxPromptRange[];

  /** A prompt's positions that are not a whole chunk: the window read at every width. */

  /** Known tokens: this graph declares no committed spans, so they read as a window. */
  readonly appendKnown: MlxKnownOperations;

  /** A causal window of token ids over every layer, `capture` seeing every layer and then the final hidden. */
  #window(ids: MlxArray, cache: Cache[], capture: MlxLayerCapture | null, layers = this.#servingLayers): MlxArray {
    const hidden = this.forwardDecoder(this.embedTokens(ids), cache, "window", ids, capture, layers);
    capture?.(this.layers.length, hidden);
    return hidden;
  }

  /** The one output head at every width. */
  readonly logits: MlxRowTable<MlxHeadForward>;

  /** One new token per sequence: `ids` [sequences, 1], so rows are sequences. */
  readonly decode: MlxRowTable<MlxCapturingForward>;

  /** A speculative window: each sequence's last accepted token and its drafted
   * tokens, right-padded by the caller to the round's depth, `ids`
   * [sequences, depth + 1], so rows are sequences times (depth + 1). The graph
   * appends all depth + 1 positions; dropping the rejected suffix is the
   * caller's speculative transaction, begun before this call. */
  readonly verify: MlxRowTable<MlxCapturingForward>;

  /** Per-layer inputs (reference _get_per_layer_inputs +
   *  _project_per_layer_inputs): [B, L, nLayers, perLayerWidth] (`PerLayerInputs.compute`). */
  protected computePerLayerInputs(ids: MlxArray, hScaled: MlxArray): MlxArray {
    return this.perLayerInputs!.compute(ids, hScaled);
  }

  /** The vision prefill phase: pre-merged (unscaled) input embeddings → hidden states. Used by the
   *  multimodal (vision/audio) path; `bidir` (bool [L]) marks image tokens,
   *  which attend bidirectionally among themselves (use_bidirectional_attention:
   *  "vision" — text stays causal; audio prompts pass NO bidir mask, and a
   *  mixed image+audio prompt drops the image overlay too,
   *  `02d723a:docs/design/generic-model-support.md` §6.6). `ids` ([1, L], the spliced token ids)
   *  is required for per-layer-input models (e2b/e4b): multimodal soft-token
   *  positions get token 0's per-layer embedding, and their tower content
   *  enters only through the projection term (the merged hidden). Matches
   *  optiq's frontend: `zeroed = where(text_mask, input_ids, 0)`.
   *
   *  `multimodal` (bool [L]) is the per-layer-input ZEROING mask — the UNION
   *  of multimodal soft tokens (image | audio, §3.3 Q2), decoupled from the
   *  attention overlay: an audio-only prompt has no bidir mask but its audio
   *  positions must still be zeroed. When null (the legacy vision call
   *  shape), the zeroing mask falls back to `bidir` — vision passes the same
   *  image mask for both roles, so that path is unchanged. */
  #prefillEmbeddings(
    embeds: MlxArray, cache: Cache[], bidir: MlxArray | null,
    ids: MlxArray | null = null, multimodal: MlxArray | null = null,
    layers: readonly DecoderOperation[] = this.#servingLayers,
  ): MlxArray {
    const h = ops.mulScalar(embeds, this.embedScale);
    const phase: Gemma4Phase = bidir ? { bidirectional: bidir } : "window";
    if (this.perLayerWidth === 0) return this.forwardDecoder(h, cache, phase, null, null, layers);

    if (!ids)
      throw new Error("per-layer-input multimodal models require token ids");
    const zeroing = multimodal ?? bidir;
    let plIds = ids;
    if (zeroing) {
      const cond = ops.reshape(zeroing, ids.shape);
      const zero = ops.zeros(ids.shape, ids.dtype);
      plIds = ops.where(cond, zero, ids);
      cond.dispose();
      zero.dispose();
    }
    const out = this.forwardDecoder(h, cache, phase, plIds, null, layers);
    if (plIds !== ids) plIds.dispose();
    return out;
  }

  /** The decoder over `h0` [B, L, hidden] (consumed), every donor layer's
   *  attention reading its cache for `phase` and every KV-sharing layer
   *  attending its donor's read. `ids` [B, L] feed the per-layer inputs
   *  (e2b/e4b). `capture` receives each layer's residual output after the layer
   *  runs (see `MlxLayerCapture`); the caller hands it the final hidden. */
  protected forwardDecoder(
    h0: MlxArray, cache: Cache[], phase: Gemma4Phase, ids: MlxArray | null,
    capture: MlxLayerCapture | null = null, layers: readonly DecoderOperation[] = this.#servingLayers, slice = this.#ordinarySlice,
  ): MlxArray {
    const B = h0.shape[0]!;
    const L = h0.shape[1]!;
    let h: MlxArray | null = h0;
    let perLayer: MlxArray | null = null;
    const donors: (DonorRead | null)[] = Array(this.numDonors).fill(null);
    try {
      // per-layer inputs (e2b/e4b)
      if (this.perLayerWidth > 0) perLayer = this.computePerLayerInputs(ids!, h);
      for (let i = 0; i < this.layers.length; i++) {
        const ci = this.cacheIndex[i]!;
        const pls = perLayer ? slice!(perLayer,i,B,L) : null;
        let next: { h: MlxArray; donor: DonorRead | null };
        try {
          next = layers[i]!.forward(h, ci === -1 ? null : cache[ci]!, phase,
            ci === -1 ? donors[this.previousKvs[i]!]! : null, pls);
        } finally { pls?.dispose(); }
        h.dispose();
        h = next.h;
        if (ci !== -1) donors[ci] = next.donor;
        capture?.(i, h);
      }
      const out = this.finalNorm.forward(h);
      h.dispose();
      h = null;
      return out;
    } finally {
      h?.dispose();
      perLayer?.dispose();
      // each donor's read exactly once, after its last sharer
      for (const donor of donors) donor?.dispose();
    }
  }

  /** Layer `i`'s per-layer input [B, L, width] (owned) from the model's
   *  [B, L, nLayers, width] tensor (`PerLayerInputs.layer`). */
  #perLayerInput(perLayer: MlxArray, i: number, B: number, L: number): MlxArray {
    return this.perLayerInputs!.layer(perLayer, i, B, L);
  }

  /** The training forward over stateless training caches (`TrainingCache`,
   *  `PrefixSharedCache`), one per donor layer: ids [1, T] to the final-norm
   *  hidden [1, T, hidden]. Every attention reads through its training cache's
   *  window read (a KV-sharing layer through its donor's, with the donor's keys
   *  and values), and a prefix-shared layout ropes block-wise; under `gradCkpt`
   *  each layer is checkpointed with its donor keys and values as checkpoint
   *  tensors. */
  forwardTrainingHidden(ids: MlxArray, cache: Cache[]): MlxArray {
    return this.#forwardTraining(this.embedTokens(ids), cache, ids);
  }

  /** The training cache layer `i` reads: its own, or its donor's for a
   *  KV-sharing layer (`cache` holds the donors' training caches). */
  #trainingCache(cache: Cache[], i: number): TrainingAttentionCache {
    const ci = this.cacheIndex[i]!;
    return cache[ci === -1 ? this.cacheIndex[this.previousKvs[i]!]! : ci] as TrainingAttentionCache;
  }

  /** The training forward's decoder over `h0` (consumed). */
  #forwardTraining(h0: MlxArray, cache: Cache[], ids: MlxArray | null): MlxArray {
    const B = h0.shape[0]!;
    const L = h0.shape[1]!;
    let h = h0;

    // per-layer inputs (e2b/e4b)
    let perLayer: MlxArray | null = null;
    if (this.perLayerWidth > 0) {
      if (!ids) throw new Error("per-layer-input models require token ids");
      perLayer = this.computePerLayerInputs(ids, h);
    }

    const intermediates: (PlainSharedKv | null)[] = Array(this.layers.length).fill(null);
    for (let i = 0; i < this.layers.length; i++) {
      const layer = this.layers[i]!;
      const ci = this.cacheIndex[i]!;
      const sharedIn = ci === -1 ? (intermediates[this.previousKvs[i]!] ?? null) : null;
      const pls = perLayer ? this.#perLayerInput(perLayer, i, B, L) : null;
      const layerCache = this.#trainingCache(cache, i);
      const { h: next, shared } = this.gradCkpt
        ? this.runCheckpointedLayer(i, layer, h, layerCache, sharedIn, pls)
        : layerTraining(layer, h, layerCache, sharedIn, pls);
      pls?.dispose();
      h.dispose();
      h = next;
      intermediates[i] = shared;
    }
    perLayer?.dispose();
    // dispose donor KV (each donor's shared entry exactly once)
    for (let i = 0; i < this.numDonors; i++) {
      const s = intermediates[i];
      if (!s) continue;
      Gemma4Model.disposeSharedKv(s);
    }

    h = disposing(h, this.finalNorm.forward(h));
    return h;
  }

  /** Mixed rows in one forward: each group's attention reads its own caches,
   * positions and SDPA shape in its own phase (a verify group reads a window);
   * feed-forward work packs only real tokens, when the composition packs mixed
   * MLP and no group is a verify window. Kernel selection for packed matmuls
   * can differ from a solo GEMV, so this is an explicit Lab port until its
   * matching packed oracle and serving comparison are accepted. */
  #mixed(groups: Parameters<MlxMixedForward>[0], layers: readonly ServingDenseLayer[]): MlxArray[] {
    const runs: Array<{ h: MlxArray; perLayer: MlxArray | null; donors: (DonorRead | null)[] }> = [];
    const results: MlxArray[] = [];

    try {
      for (const group of groups) {
        const run = { h: this.embedTokens(group.ids), perLayer: null as MlxArray | null,
          donors: Array<DonorRead | null>(this.numDonors).fill(null) };
        runs.push(run);
        if (this.perLayerWidth > 0) run.perLayer = this.computePerLayerInputs(group.ids, run.h);
      }
      for (let i = 0; i < this.layers.length; i++) {
        const layer = layers[i]!, ci = this.cacheIndex[i]!;
        const mids: MlxArray[] = [], inputs: MlxArray[] = [];
        try {
          for (const [row, group] of groups.entries()) {
            const run = runs[row]!;
            const { h, donor } = layer.forwardAttn(run.h, ci === -1 ? null : group.state[ci]!,
              group.phase === "decode" ? "decode" : "window", ci === -1 ? run.donors[this.previousKvs[i]!]! : null);
            mids.push(h);
            if (ci !== -1) run.donors[ci] = donor;
            if (run.perLayer) {
              const [B, L] = group.ids.shape;
              using part = run.perLayer.slice([0, 0, i, 0], [B!, L!, i + 1, this.perLayerWidth]);
              inputs.push(ops.reshape(part, [B!, L!, this.perLayerWidth]));
            }
          }
          // Per-layer inputs use the same token order as the hidden states.
          let packedInput: MlxArray | null = null;
          if (inputs.length) {
            const flat = inputs.map(input => ops.reshape(input, [1, -1, this.perLayerWidth]));
            try { packedInput = ops.concatAxis(flat, 1); }
            finally { for (const input of flat) input.dispose(); }
          }
          using pli = packedInput;
          const outputs: MlxArray[] = [];
          try {
            outputs.push(...mapPackedTokens(mids, packed => layer.forwardMlp(packed, pli)));
          } catch (error) { for (const output of outputs) output.dispose(); throw error; }
          for (const [row, run] of runs.entries()) {
            run.h.dispose(); run.h = outputs[row]!;
          }
          for (const [row, group] of groups.entries()) group.capture?.(i, runs[row]!.h);
        } finally {
          for (const mid of mids) mid.dispose();
          for (const input of inputs) input.dispose();
        }
      }
      for (const [row, group] of groups.entries()) {
        const hidden = this.finalNorm.forward(runs[row]!.h); results.push(hidden);
        group.capture?.(this.layers.length, hidden);
      }
      return results;
    } catch (error) { for (const result of results) result.dispose(); throw error; }
    finally {
      for (const run of runs) {
        run.h.dispose(); run.perLayer?.dispose();
        for (const donor of run.donors) donor?.dispose();
      }
    }
  }

  // --- Segmented-backward support (`02d723a:docs/design/orpo-training.md`
  // §5.3). These run the training forward's layers (`layerTraining`). The
  // segmented driver builds the training caches + per-layer inputs ONCE, then
  // drives runLayerRange per segment, threading the KV-shared donor K/V across
  // segment boundaries.

  /** Donor layer indices that KV-sharing sharers reuse (e4b: {22,23} — the last
   *  donor of each attention type; empty for dense models). Their K/V must
   *  survive across segment boundaries (saved as detached boundaries). */
  get reusedDonors(): Set<number> {
    return new Set(this.previousKvs.filter((d, i) => d !== i));
  }

  /** e2b/e4b training entry: the SCALED input embedding (the first segment
   *  boundary) plus the per-layer-input tensor [B,L,nLayers,width] (a detached
   *  boundary, sliced per layer inside runLayerRange). perLayer is null for dense
   *  models. Caller owns both. */
  embedForSegmented(ids: MlxArray): { hScaled: MlxArray; perLayer: MlxArray | null } {
    let h = this.embed.encode(ids);
    h = disposing(h, ops.mulScalar(h, this.embedScale));
    const perLayer = this.perLayerWidth > 0 ? this.computePerLayerInputs(ids, h) : null;
    return { hScaled: h, perLayer };
  }

  /** Dispose a training donor's K/V. */
  private static disposeSharedKv(s: PlainSharedKv): void {
    s.offsetArr?.dispose();
    s.keys.dispose();
    s.values.dispose();
  }

  /** Run decoder layers `[aIdx, bIdx)` on hidden `h`, returning the residual
   *  stream after the last layer in the range (NO finalNorm) plus the K/V of
   *  any reused-donor layers in the range (`donorKvOut`, for later segments).
   *  The input `h` is NEVER disposed (the caller / vjp owns the boundary leaf);
   *  intra-range hidden intermediates and per-layer slices ARE disposed.
   *  Non-reused donors' K/V are disposed; reused donors' K/V are returned
   *  (caller threads + disposes). NOT gradient-checkpointed — the segmentation
   *  IS the memory strategy.
   *
   *  @param cache     the pass's training caches, one per donor layer.
   *  @param perLayer  the [B,L,nLayers,width] tensor (caller-owned) or null.
   *  @param donorKvIn K/V of reused donors from EARLIER segments, keyed by donor
   *                   layer index (caller-owned; not disposed here). */
  runLayerRange(
    h: MlxArray, aIdx: number, bIdx: number, cache: Cache[],
    perLayer: MlxArray | null, donorKvIn: Map<number, SharedKv>,
  ): { h: MlxArray; donorKvOut: Map<number, SharedKv> } {
    const donorKvOut = new Map<number, SharedKv>();
    if (aIdx >= bIdx) return { h, donorKvOut };
    const B = h.shape[0]!;
    const L = h.shape[1]!;
    const reused = this.reusedDonors;
    let cur = h;
    for (let i = aIdx; i < bIdx; i++) {
      const layer = this.layers[i]!;
      const ci = this.cacheIndex[i]!;
      const isDonor = ci !== -1;
      let sharedIn: PlainSharedKv | null = null;
      if (!isDonor) {
        const donor = this.previousKvs[i]!;
        // The segment donors hand on the plain keys and values they appended.
        sharedIn = (donorKvOut.get(donor) ?? donorKvIn.get(donor) ?? null) as PlainSharedKv | null;
        if (!sharedIn) throw new Error(`runLayerRange: donor ${donor} K/V not available for sharer ${i}`);
      }
      let pls: MlxArray | null = null;
      if (perLayer) {
        const sl = perLayer.slice([0, 0, i, 0], [B, L, i + 1, this.perLayerWidth]);
        pls = ops.reshape(sl, [B, L, this.perLayerWidth]);
        sl.dispose();
      }
      const { h: next, shared } = layerTraining(layer, cur, this.#trainingCache(cache, i), sharedIn, pls);
      pls?.dispose();
      if (i > aIdx) cur.dispose(); // keep the input boundary leaf; drop interiors
      cur = next;
      if (isDonor) {
        if (reused.has(i)) donorKvOut.set(i, shared);
        else Gemma4Model.disposeSharedKv(shared);
      }
      // sharer: `shared` === sharedIn (owned by donorKvIn/Out) — do not dispose.
    }
    return { h: cur, donorKvOut };
  }

  /** Run one layer under gradient checkpointing: its interior activations are
   *  dropped and recomputed in the backward pass. The layer's LoRA params, h,
   *  pls, and a sharer's donor KV are threaded as explicit checkpoint inputs
   *  (the closure must be pure and self-contained — it re-runs during the
   *  backward, and captured autograd primals would be stale); the training
   *  cache it reads stores nothing, so the recompute reads exactly as the
   *  forward did. A donor layer also emits its K/V as checkpoint outputs so the
   *  (retained, small) tensors reach the sharer layers downstream. */
  private runCheckpointedLayer(
    i: number, layer: DecoderLayer, h: MlxArray,
    layerCache: TrainingAttentionCache, sharedIn: PlainSharedKv | null, pls: MlxArray | null,
  ): { h: MlxArray; shared: PlainSharedKv | null } {
    const ctx = this.gradCkpt!;
    const ll = ctx.byLayer.get(i) ?? { attn: [], mlp: [] };
    return ctx.splitMlp
      ? this.runSplitCheckpointedLayer(layer, h, layerCache, sharedIn, pls, ll, ctx)
      : this.runSingleCheckpointedLayer(layer, h, layerCache, sharedIn, pls, ll, ctx);
  }

  /** One Checkpoint over the whole layer (the original path). */
  private runSingleCheckpointedLayer(
    layer: DecoderLayer, h: MlxArray,
    layerCache: TrainingAttentionCache, sharedIn: PlainSharedKv | null, pls: MlxArray | null,
    ll: LayerLoras, ctx: GradCheckpointCtx,
  ): { h: MlxArray; shared: PlainSharedKv | null } {
    const lws = [...ll.attn, ...ll.mlp];
    const isSharer = !layer.attn.hasKv;
    const sIn = isSharer && sharedIn && sharedIn.kind === "plain" ? sharedIn : null;
    const hasPls = pls !== null;

    // Input order: [h, pls?, sharedInK?, sharedInV?, (lora_a, lora_b)*]
    const inputs: MlxArray[] = [h];
    if (hasPls) inputs.push(pls!);
    if (sIn) inputs.push(sIn.keys, sIn.values);
    for (const lw of lws) inputs.push(lw.a, lw.b);

    const ck = new Checkpoint((ins) => {
      let k = 0;
      const hIn = ins[k++]!;
      const plsIn = hasPls ? ins[k++]! : null;
      const sharedInRebuilt: PlainSharedKv | null = sIn
        ? { kind: "plain", keys: ins[k++]!, values: ins[k++]!, offset: 0 }
        : null;
      const saved = lws.map((lw) => [lw.a, lw.b] as [MlxArray, MlxArray]);
      for (const lw of lws) { lw.a = ins[k++]!; lw.b = ins[k++]!; }
      try {
        const out = layerTraining(layer, hIn, layerCache, sharedInRebuilt, plsIn);
        if (!isSharer && out.shared && out.shared.kind === "plain")
          return [out.h, out.shared.keys, out.shared.values];
        return [out.h];
      } finally {
        lws.forEach((lw, j) => { lw.a = saved[j]![0]; lw.b = saved[j]![1]; });
      }
    });
    ctx.keepAlive.push(ck);

    const outs = ck.apply(inputs);
    const shared: PlainSharedKv | null =
      !isSharer && outs.length === 3
        ? { kind: "plain", keys: outs[1]!, values: outs[2]!, offset: 0 }
        : null;
    return { h: outs[0]!, shared };
  }

  /** Intra-layer MLP split (lever 4): TWO checkpoints — the attention sub-block
   *  (forwardAttn: inputNorm → attn → residual add, threading the donor K/V) and
   *  the MLP sub-block (forwardMlp: FFN + per-layer gate) — with the post-attn
   *  residual `hMid` as the boundary. The backward recompute holds only one
   *  sub-block's activations at a time, dropping per-layer peak from `attn+MLP`
   *  to `max(attn,MLP)+hMid`. Attn LoRA / pls / donor-KV go to the attn ck; MLP
   *  LoRA to the MLP ck. */
  private runSplitCheckpointedLayer(
    layer: DecoderLayer, h: MlxArray,
    layerCache: TrainingAttentionCache, sharedIn: PlainSharedKv | null, pls: MlxArray | null,
    ll: LayerLoras, ctx: GradCheckpointCtx,
  ): { h: MlxArray; shared: PlainSharedKv | null } {
    const isSharer = !layer.attn.hasKv;
    const sIn = isSharer && sharedIn && sharedIn.kind === "plain" ? sharedIn : null;
    const hasPls = pls !== null;
    const attnLws = ll.attn;
    const mlpLws = ll.mlp;

    // --- attn sub-block checkpoint: [h, sharedInK?, sharedInV?, attnLora*]
    const attnInputs: MlxArray[] = [h];
    if (sIn) attnInputs.push(sIn.keys, sIn.values);
    for (const lw of attnLws) attnInputs.push(lw.a, lw.b);

    const attnCk = new Checkpoint((ins) => {
      let k = 0;
      const hIn = ins[k++]!;
      const sharedInRebuilt: PlainSharedKv | null = sIn
        ? { kind: "plain", keys: ins[k++]!, values: ins[k++]!, offset: 0 }
        : null;
      const saved = attnLws.map((lw) => [lw.a, lw.b] as [MlxArray, MlxArray]);
      for (const lw of attnLws) { lw.a = ins[k++]!; lw.b = ins[k++]!; }
      try {
        const out = layerAttnTraining(layer, hIn, layerCache, sharedInRebuilt);
        if (!isSharer && out.shared && out.shared.kind === "plain")
          return [out.h, out.shared.keys, out.shared.values];
        return [out.h];
      } finally {
        attnLws.forEach((lw, j) => { lw.a = saved[j]![0]; lw.b = saved[j]![1]; });
      }
    });
    ctx.keepAlive.push(attnCk);
    const attnOuts = attnCk.apply(attnInputs);
    const hMid = attnOuts[0]!;
    const shared: PlainSharedKv | null =
      !isSharer && attnOuts.length === 3
        ? { kind: "plain", keys: attnOuts[1]!, values: attnOuts[2]!, offset: 0 }
        : null;

    // --- MLP sub-block checkpoint: [hMid, pls?, mlpLora*] -> [hOut]
    const mlpInputs: MlxArray[] = [hMid];
    if (hasPls) mlpInputs.push(pls!);
    for (const lw of mlpLws) mlpInputs.push(lw.a, lw.b);

    const mlpCk = new Checkpoint((ins) => {
      let k = 0;
      const hMidIn = ins[k++]!;
      const plsIn = hasPls ? ins[k++]! : null;
      const saved = mlpLws.map((lw) => [lw.a, lw.b] as [MlxArray, MlxArray]);
      for (const lw of mlpLws) { lw.a = ins[k++]!; lw.b = ins[k++]!; }
      try {
        return [layer.forwardMlp(hMidIn, plsIn)];
      } finally {
        mlpLws.forEach((lw, j) => { lw.a = saved[j]![0]; lw.b = saved[j]![1]; });
      }
    });
    ctx.keepAlive.push(mlpCk);
    const mlpOuts = mlpCk.apply(mlpInputs);
    hMid.dispose(); // boundary leaf consumed by the MLP ck (mlx retains it in-graph)

    return { h: mlpOuts[0]!, shared };
  }

  /** hidden [1, L, hidden] → softcapped logits [1, L, vocab]. */
  logitsFromHidden(h: MlxArray): MlxArray { return this.#head(h, compiledLogitSoftcap); }

  #head(h: MlxArray, softcapOperation: typeof logitSoftcap): MlxArray {
    let logits = this.embed.asLinear(h);
    const softcap = this.config.text.finalLogitSoftcapping;
    if (softcap !== null) logits = disposing(logits, softcapOperation(logits, softcap));
    return logits;
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Gemma4.Model
