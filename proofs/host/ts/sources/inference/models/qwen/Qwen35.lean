import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Qwen.Qwen35
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/qwen/qwen3_5.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxCacheLayer, MlxMixedRange, MlxSequenceRange } from "../../contracts/mlx/graph";
// Concrete model graph for Qwen3.5 hybrid models (e.g. Qwen3.6-27B-OptiQ-4bit).
// Port target: mlx_lm.models.qwen3_5 (+ qwen3_next Attention/MLP/RMSNormGated,
// gated_delta recurrence). The architecture is a 64-layer stack where every
// `fullAttentionInterval`-th layer is standard softmax attention and the rest
// are gated-DeltaNet linear-attention layers. Weights carry a
// `language_model.` prefix. The blocks live in `blocks.ts`; this graph composes
// them and hands every block the phase its caller names.
//
// Parity bars: bf16 KV → bit-exact vs mlx-lm; mixed-precision KV → bit-exact vs
// mlx-optiq (the 16 full-attention layers quantized per kv_config.json, via the
// shared maybeQuantizeKv path).

import type { ModelConfig } from "../../artifacts/config";
import type { Weights } from "../../artifacts/weights";

import { mapPackedTokens } from "../../input/token-groups";
import type { MlxArray } from "@mlx-bun/mlx/array";

import * as ops from "@mlx-bun/mlx/ops";
import { qwenAppendChunkSize } from "../../layers/qwen-append";
import { disposing } from "../../layers/helpers";
import { LoraState } from "../../layers/lora";
import { QuantizedEmbedding } from "../../layers/quantized-embedding";
import { QuantizedLinear, QuantizedLinearPlain, QuantizedLinearRows } from "../../layers/quantized-linear";
import { RMSNorm } from "../../layers/normalization";
import { type Cache } from "../../contracts/mlx/cache";
import { qwen35WeightsView } from "./checkpoint";
import type { GraphDeclaration } from "../../contracts/portable/graph";
import type { MlxCapturingForward, MlxDeclaredGraph, MlxHeadForward, MlxKnownSpans, MlxLayerCapture, MlxPromptRange, MlxTokenPhases, MlxVerifyForward, MlxRowTable } from "../../contracts/mlx/graph";
import type { TargetView } from "../../contracts/mlx/draft-target";
import type { MediaEncoders, MlxPromptInput, Vision } from "../../contracts/mlx/media";
import { declareGraph } from "../capabilities";
import { DEFAULT_PHASE_ROWS, rowTableFrom, type ReadPhase   } from "../graph";
import { bindQwenMediaInput, qwenDraftTarget, qwenMediaEncoders } from "./media-input";
import { mropeInvFreq } from "../../layers/qwen-mrope";
import type { MropeForwardState } from "../../contracts/mlx/positions";
import { Qwen3Layer, QwenAttentionLayer, QwenDeltaLayer, QwenGatedDeltaNet, Qwen3TextAttention, Qwen3MediaAttention, type QwenMlp } from "./blocks";
import { Dtype, deviceArchitecture } from "@mlx-bun/mlx/ffi";
import { fusedGateUpEligible, type TrellisLinear } from "../../layers/trellis-linear";
import { TrellisFusedMLP, TrellisUnfusedMLP, TrellisReducePrompt, TrellisScatterPrompt, TrellisWidePrompt, TrellisTiledPrompt, TrellisSplitKPrompt, TrellisExpandReducePrompt, TrellisExpandScatterPrompt, type RowProjection } from "../../layers/trellis-prompt";
import { qualifiedRepresentations, wideTrellisPrefillEligible, tiledTrellisPrefillEligible, splitKTrellisPrefillEligible } from "../../kernels/trellis/index";

const PREFIX = "language_model";

// The generic graph binds device and artifact choices once at construction.
// Its forwards call the resulting operations without inspecting the device.
type FixedLayer = QwenDeltaLayer | QwenAttentionLayer;
interface FixedRange { readonly from: number; readonly to: number; readonly layers: readonly FixedLayer[]; readonly media: readonly FixedLayer[] }
function packedProjection(base: TrellisLinear): RowProjection {
  return base.geometry.axis === 1 ? new TrellisReducePrompt(base) : new TrellisScatterPrompt(base);
}
function expandedProjection(base: TrellisLinear): RowProjection {
  return base.geometry.axis === 1 ? new TrellisExpandReducePrompt(base) : new TrellisExpandScatterPrompt(base);
}
function affineMlp(base: Extract<QwenMlp, {kind: "affine"}>): RowProjection {
  return new TrellisUnfusedMLP(new QuantizedLinearPlain(base.gate), new QuantizedLinearPlain(base.up), new QuantizedLinearPlain(base.down));
}
/** Main's committed-span qualification, evaluated from loaded projections at construction. */
export function qwen35KnownSpansEligible(config: ModelConfig, layers: readonly Qwen3Layer[], device: string): boolean {
  const t = config.text;
  if (t.hiddenSize !== 5120 || t.intermediateSize !== 17408 || layers.length !== 64 ||
      t.headDim !== 256 || t.numAttentionHeads !== 24 || t.numKeyValueHeads !== 4 || device !== "applegpu_g16s")
    return false;
  const qualified = (linear: QuantizedLinear) => linear.spec.mode === "affine" &&
    [2, 3, 4, 6, 8].includes(linear.spec.bits) && [32, 64, 128].includes(linear.spec.groupSize);
  return layers.every(layer => {
    const a = layer.linearAttn, s = layer.selfAttn;
    const attention = a ? [a.inProjQkv, a.inProjZ, a.inProjB, a.inProjA, a.outProj]
      : [s!.qProj, s!.kProj, s!.vProj, s!.oProj];
    const mlp = layer.mlp.kind === "affine" ? [layer.mlp.gate, layer.mlp.up, layer.mlp.down] : [];
    return attention.every(qualified) && mlp.every(qualified);
  });
}

export class Qwen35Model implements MlxDeclaredGraph, MlxTokenPhases {
  readonly config: ModelConfig;
  readonly weightsBytes: number;
  /** Base path for LoRA target keys (weights carry the language_model prefix). */
  readonly prefixBase = "language_model.model";
  readonly loraState = new LoraState();
  /** Prepared image and video embeddings with request-owned mRoPE positions,
   * layer taps for drafts. Its few full-attention layers materialize their
   * scores at long context, so prefill chunks shrink to bound that workspace. */
  get graphCapabilities(): GraphDeclaration {
    return declareGraph({
      media: { input: "embeddings+positions", video: true }, hiddenLayerTaps: true,
      prefill: { boundedWorkspace: true },
    });
  }
  bindMediaInput(input: Vision): MlxPromptInput { return bindQwenMediaInput(this, input.embeddings, input.mrope!); }
  mediaEncoders(modelDir: string): Promise<MediaEncoders> { return qwenMediaEncoders(this, modelDir); }
  draftTarget(_caches: Cache[]): TargetView { return qwenDraftTarget(this); }
  readonly embed: QuantizedEmbedding;
  readonly layers: Qwen3Layer[];
  readonly finalNorm: RMSNorm;
  /** null when tied: the output head reuses embed_tokens (embed.asLinear). */
  readonly lmHead: QuantizedLinear | null;
  readonly tied: boolean;
  readonly faIdx: number;
  readonly #ranges: readonly FixedRange[];
  readonly #adapterOperations: TrellisFusedMLP[] = [];
  readonly #head: (hidden: MlxArray) => MlxArray;

  constructor(weights: Weights, config: ModelConfig, maxPhaseRows = DEFAULT_PHASE_ROWS, device = deviceArchitecture()) {
    const representations = qualifiedRepresentations(device);
    // Checkpoint-generation normalization BEFORE the first tensor() call: the
    // 5.8-family export names the trunk `model.language_model.*` with a
    // top-level `lm_head`, ships `mtp.*` in-repo, and stores RMSNorm gains as
    // γ−1 with HF-layout conv1d. The view maps all of that onto the names and
    // values this graph reads (mlx-lm's post-sanitize space). No-op — nothing
    // installed at all — for artifacts already in that space.
    const view = qwen35WeightsView(weights);
    if (view) weights.setView(view);
    this.config = config;
    this.tied = config.text.tieWordEmbeddings;
    this.weightsBytes = [...weights.shards.files.values()]
      .reduce((a, f) => a + f.mmap.size, 0);
    this.embed = QuantizedEmbedding.load(weights, `${PREFIX}.model.embed_tokens`, config);
    this.layers = Array.from(
      { length: config.text.numHiddenLayers },
      (_, i) => new Qwen3Layer(weights, config, i, representations),
    );
    this.finalNorm = new RMSNorm(weights.tensor(`${PREFIX}.model.norm.weight`), config.text.rmsNormEps);
    // Tied models (e.g. Qwen3.5-4B) ship no lm_head; the reference uses
    // embed_tokens.as_linear (mlx-lm qwen3_5 TextModel.__call__).
    this.lmHead = this.tied ? null : QuantizedLinear.load(weights, `${PREFIX}.lm_head`, config);
    this.faIdx = config.text.fullAttentionInterval - 1;
    const head = this.lmHead ? new QuantizedLinearPlain(this.lmHead) : null;
    this.#head = head ? hidden => head.forward(hidden) : hidden => this.embed.asLinear(hidden);
    const narrow = (base: QwenMlp): RowProjection => {
      if (base.kind === "affine") return affineMlp(base);
      const down = packedProjection(base.down);
      if (fusedGateUpEligible(base.gate, base.up)) {
        const operation = new TrellisFusedMLP(base.gate, base.up, down, this.loraState);
        this.#adapterOperations.push(operation); return operation;
      }
      return new TrellisUnfusedMLP(packedProjection(base.gate), packedProjection(base.up), down);
    };
    const windowGate = (base: TrellisLinear): RowProjection =>
      wideTrellisPrefillEligible(base.geometry, 5, Dtype.bfloat16, representations.widePrefill) ? new TrellisWidePrompt(base)
        : tiledTrellisPrefillEligible(base.geometry, 5, Dtype.bfloat16, representations.widePrefill) ? new TrellisTiledPrompt(base) : expandedProjection(base);
    const tiledGate = (base: TrellisLinear): RowProjection =>
      tiledTrellisPrefillEligible(base.geometry, 16, Dtype.bfloat16, representations.widePrefill) ? new TrellisTiledPrompt(base) : expandedProjection(base);
    const splitDown = (base: TrellisLinear): RowProjection =>
      splitKTrellisPrefillEligible(base.geometry, 5, Dtype.bfloat16) ? new TrellisSplitKPrompt(base) : expandedProjection(base);
    const five = (base: QwenMlp) => base.kind === "affine" ? affineMlp(base)
      : new TrellisUnfusedMLP(windowGate(base.gate), windowGate(base.up), splitDown(base.down));
    const nine = (base: QwenMlp) => base.kind === "affine" ? affineMlp(base)
      : new TrellisUnfusedMLP(windowGate(base.gate), windowGate(base.up), expandedProjection(base.down));
    const sixteen = (base: QwenMlp) => base.kind === "affine" ? affineMlp(base)
      : new TrellisUnfusedMLP(tiledGate(base.gate), tiledGate(base.up), expandedProjection(base.down));
    const expanded = (base: QwenMlp) => base.kind === "affine" ? affineMlp(base)
      : new TrellisUnfusedMLP(expandedProjection(base.gate), expandedProjection(base.up), expandedProjection(base.down));
    const bind = (from: number, to: number, mlp: (base: QwenMlp) => RowProjection): FixedRange => {
      const operations = this.layers.map(layer => mlp(layer.mlp));
      return { from, to, layers: this.layers.map((layer, index) => this.#layerView(weights, config, layer, index, operations[index]!, false)),
        media: this.layers.map((layer, index) => this.#layerView(weights, config, layer, index, operations[index]!, true)) };
    };
    const unfusedNarrow=bind(1,4,base=>base.kind==="affine" ? affineMlp(base)
      : new TrellisUnfusedMLP(packedProjection(base.gate),packedProjection(base.up),packedProjection(base.down)));
    this.#ranges = [bind(1, 4, narrow), bind(5, 8, five), bind(9, 15, nine), bind(16, 32, sixteen), bind(33, Infinity, expanded)];
    this.knownSpans = qwen35KnownSpansEligible(config, this.layers, device)
      ? Object.freeze({ maxChunkSize: (state: readonly Cache[]) => qwenAppendChunkSize(state[0]!.offset) }) : undefined;
    const forward = (range: FixedRange, phase: ReadPhase, bounded: boolean): MlxCapturingForward => (ids, state, capture) =>
      this.#captured(this.forwardLayers(this.embed.encode(ids), state, phase, undefined, capture, range.layers, bounded), capture);
    const exact = <Op>(build: (range: FixedRange) => Op): MlxRowTable<Op> => {
      const ranges = this.#ranges.map(range => ({ ...range, operation: build(range) }));
      const defaultOperation = ranges.at(-1)!.operation;
      // Admission caps do not remove the component's distinct 1–32 row forms.
      return Object.freeze({ ...rowTableFrom(rows => ranges.find(range => rows >= range.from && rows <= range.to)!.operation, Math.max(32, maxPhaseRows)),
        default: defaultOperation });
    };
    this.decode = exact(range => forward(range, "decode", false));
    this.verify = exact(range => forward(range, "window", false));
    this.appendKnown = this.knownSpans ? this.#committedKnownOperations(weights, config)
      : this.#ranges.map(range => ({ from: range.from, to: range.to, operation: (ids, state) =>
        this.forwardLayers(this.embed.encode(ids), state, "window", undefined, null, range.layers, false) }));
    this.prompt = this.#ranges.map(range => ({ from: range.from, to: range.to, operation: forward(range, "window", range.from > 4) }));
    this.multiSequencePrompt = this.prompt;
    // Main's whole chunks use independent projections even at 1–4 actual
    // rows and materialize each layer and its recurrent state.
    this.promptChunk = [unfusedNarrow, ...this.#ranges.slice(1)].map(range => ({
      from: range.from, to: range.to, operation: forward(range, "window", true) }));
    this.multiSequencePromptChunk = this.promptChunk;
    this.logits = Object.freeze({ default: (hidden: MlxArray) => this.logitsFromHidden(hidden) });
    this.sequence = this.#ranges.map(range => ({ from: range.from, to: range.to,
      operation: (ids, cache) => this.forwardLayers(this.embed.encode(ids), cache, "window", undefined, null, range.layers, range.from > 4) }));
    this.mediaPrefill = this.#ranges.map(range => ({ from: range.from, to: range.to,
      operation: (embeds, cache, positions) => this.forwardLayers(ops.contiguous(embeds), cache, "window", positions, null, range.media, range.from > 4) }));
    this.mediaPrompt = this.#ranges.map(range => ({ from: range.from, to: range.to,
      operation: (ids, cache, positions) => this.forwardLayers(this.embed.encode(ids), cache, "window", positions, null, range.media, range.from > 4) }));
    this.mediaDecode = exact(range => (ids, cache, positions) => this.forwardLayers(this.embed.encode(ids), cache, "decode", positions, null, range.media, false));
    this.embeddingPrompt = this.#ranges.map(range => ({ from: range.from, to: range.to,
      operation: (embeds, cache) => this.forwardLayers(ops.contiguous(embeds), cache, "window", undefined, null, range.layers, range.from > 4) }));
    this.mixed = this.#ranges.map(range => ({ from: range.from, to: range.to,
      operation: groups => this.#mixedForward(groups, range.layers) }));
    const packedWithVerification: import("../../contracts/mlx/graph").MlxMixedRange[] = this.#ranges.map(range => ({ from: range.from, to: range.to,
      totalTo: range.from === 1 ? 4 : undefined,
      operation: (groups: readonly import("../../contracts/mlx/graph").MlxPhaseGroup[]) => this.#mixedForward(groups, range.layers) }));
    packedWithVerification.push({ from: 1, to: 4, totalFrom: 5,
      operation: groups => this.#mixedForward(groups, unfusedNarrow.layers) });
    const separated = (phase: ReadPhase) => this.#ranges.map(range => ({ from: range.from, to: range.to,
      operation: (group: import("../../contracts/mlx/graph").MlxPhaseGroup) => this.#captured(this.forwardLayers(this.embed.encode(group.ids), group.state, phase,
        undefined, group.capture, range.layers, group.phase === "window" && range.from > 4), group.capture) }));
    this.mixedSeparate = { packed: packedWithVerification, decode: separated("decode"), window: separated("window"), verify: separated("window") };

    this.cacheLayers = this.layers.map(layer => layer.isLinear ? {kind:"recurrent" as const} : {kind:"full" as const,turboQuant:"dense" as const});
  }

  #layerView(weights: Weights, config: ModelConfig, base: Qwen3Layer, index: number, mlp: RowProjection, media: boolean): FixedLayer {
    const prefix = `${PREFIX}.model.layers.${index}`;
    if (base.linearAttn) {
      const b = base.linearAttn;
      return new QwenDeltaLayer(weights, config, prefix, new QwenGatedDeltaNet(weights, config, `${prefix}.linear_attn`, {
        inProjQkv: new QuantizedLinearPlain(b.inProjQkv), inProjZ: new QuantizedLinearPlain(b.inProjZ),
        inProjB: new QuantizedLinearPlain(b.inProjB), inProjA: new QuantizedLinearPlain(b.inProjA), outProj: new QuantizedLinearPlain(b.outProj) }), mlp);
    }
    const b = base.selfAttn!;
    const projections = { qProj: new QuantizedLinearPlain(b.qProj), kProj: new QuantizedLinearPlain(b.kProj),
      vProj: new QuantizedLinearPlain(b.vProj), oProj: new QuantizedLinearPlain(b.oProj) };
    const mixer = media ? new Qwen3MediaAttention(weights, config, `${prefix}.self_attn`, projections)
      : new Qwen3TextAttention(weights, config, `${prefix}.self_attn`, projections);
    return new QwenAttentionLayer(weights, config, prefix, mixer, mlp);
  }

  /** The committed graph binds independent affine rows before any forward.
   * Trellis projections retain the same fixed prompt ranges as this graph. */
  #committedKnownOperations(weights: Weights, config: ModelConfig): import("../../contracts/mlx/graph").MlxKnownOperations {
    const affine = (base: Extract<QwenMlp, {kind:"affine"}>): RowProjection => new TrellisUnfusedMLP(
      new QuantizedLinearRows(base.gate), new QuantizedLinearRows(base.up), new QuantizedLinearRows(base.down));
    return this.#ranges.map(range => {
      const layers = this.layers.map((base, index): FixedLayer => {
        const prefix = `${PREFIX}.model.layers.${index}`;
        const mlp = base.mlp.kind === "affine" ? affine(base.mlp) : range.layers[index]!.mlp;
        if (base.linearAttn) {
          const b = base.linearAttn;
          return new QwenDeltaLayer(weights, config, prefix, new QwenGatedDeltaNet(weights, config, `${prefix}.linear_attn`, {
            inProjQkv: new QuantizedLinearRows(b.inProjQkv), inProjZ: new QuantizedLinearRows(b.inProjZ),
            inProjB: new QuantizedLinearRows(b.inProjB), inProjA: new QuantizedLinearRows(b.inProjA), outProj: new QuantizedLinearRows(b.outProj),
          }), mlp);
        }
        const b = base.selfAttn!;
        return new QwenAttentionLayer(weights, config, prefix, new Qwen3TextAttention(weights, config, `${prefix}.self_attn`, {
          qProj: new QuantizedLinearRows(b.qProj), kProj: new QuantizedLinearRows(b.kProj),
          vProj: new QuantizedLinearRows(b.vProj), oProj: new QuantizedLinearRows(b.oProj),
        }), mlp);
      });
      return { from: range.from, to: range.to, operation: (ids, state) =>
        this.forwardLayers(this.embed.encode(ids), state, "committed", undefined, null, layers, false) };
    });
  }

  loraTargets(): Map<string, QuantizedLinear | TrellisLinear> {
    const out = new Map<string, QuantizedLinear | TrellisLinear>();
    for (let i = 0; i < this.layers.length; i++) {
      const l = this.layers[i]!;
      const p = `${PREFIX}.model.layers.${i}`;
      if (l.selfAttn) {
        out.set(`${p}.self_attn.q_proj`, l.selfAttn.qProj);
        out.set(`${p}.self_attn.k_proj`, l.selfAttn.kProj);
        out.set(`${p}.self_attn.v_proj`, l.selfAttn.vProj);
        out.set(`${p}.self_attn.o_proj`, l.selfAttn.oProj);
      } else if (l.linearAttn) {
        out.set(`${p}.linear_attn.in_proj_qkv`, l.linearAttn.inProjQkv);
        out.set(`${p}.linear_attn.in_proj_z`, l.linearAttn.inProjZ);
        out.set(`${p}.linear_attn.in_proj_b`, l.linearAttn.inProjB);
        out.set(`${p}.linear_attn.in_proj_a`, l.linearAttn.inProjA);
        out.set(`${p}.linear_attn.out_proj`, l.linearAttn.outProj);
      }
      out.set(`${p}.mlp.gate_proj`, l.mlp.gate);
      out.set(`${p}.mlp.up_proj`, l.mlp.up);
      out.set(`${p}.mlp.down_proj`, l.mlp.down);
    }
    return out;
  }

  /** Releases the mRoPE frequencies a vision forward built; the weights are its owner's. */
  dispose(): void {
    for (const operation of this.#adapterOperations) operation.dispose();
    this.#mropeInvFreq?.dispose();
    this.#mropeInvFreq = null;
  }

  /** One cache per layer, the full-attention caches sharing one mask memo:
   * the cache the composition's KV scheme names for each attention layer
   * (`composedFullAttentionCache`). Their TurboQuant read is dense
   * (`denseTurboQuantKernels`): the read decodes keys and values, then runs the
   * fused SDPA. */
  readonly cacheLayers: readonly MlxCacheLayer[];
  readonly sequence: readonly MlxSequenceRange[];
  readonly mediaPrefill: readonly import("../../contracts/mlx/media").MlxPositionedEmbeddingsRange[];
  readonly mediaPrompt: readonly import("../../contracts/mlx/media").MlxPositionedRange[];
  readonly mediaDecode: import("../../contracts/mlx/graph").MlxRowTable<import("../../contracts/mlx/media").MlxPositionedForward>;


  /** One whole chunk of a prompt; rows are sequences times the chunk size, and
   * each layer's output and recurrent state is evaluated before the next. The
   * GPU is this graph's one unit. */
  readonly prompt: readonly MlxPromptRange[];
  readonly multiSequencePrompt: readonly MlxPromptRange[];
  readonly promptChunk: readonly MlxPromptRange[];
  readonly multiSequencePromptChunk: readonly MlxPromptRange[];

  /** One new token per sequence: `ids` [sequences, 1], so rows are sequences. */
  readonly decode: MlxRowTable<MlxCapturingForward>;

  /** A speculative window: each sequence's last accepted token and its drafted
   * tokens, right-padded by the caller to the round's depth, `ids`
   * [sequences, depth + 1], so rows are sequences times (depth + 1). The graph
   * appends all depth + 1 positions; dropping the rejected suffix is the
   * caller's speculative transaction, begun before this call. */
  readonly verify: MlxRowTable<MlxVerifyForward>;

  /** Main's qualified committed spans, bound once when the generic graph loads. */
  readonly knownSpans: MlxKnownSpans | undefined;
  /** Known tokens: the committed read under `knownSpans`, the window read otherwise. */
  readonly appendKnown: import("../../contracts/mlx/graph").MlxKnownOperations;

  /** The same output head at every declared numeric row. */
  readonly logits: MlxRowTable<MlxHeadForward>;

  /** Hands `capture` the post-final-norm output after its layers, and returns it. */
  #captured(hidden: MlxArray, capture: MlxLayerCapture | null): MlxArray {
    capture?.(this.layers.length, hidden);
    return hidden;
  }

  /** Each group's attention reads its own caches and phase. Declared packed
   * operations share the nonverify MLP rows; verification keeps its own geometry.
   * Prompt groups above four rows evaluate each layer and recurrent state. */
  readonly mixed: readonly MlxMixedRange[];
  readonly mixedSeparate: import("../../contracts/mlx/graph").MlxSeparateMixed;
  #mixedForward(groups: readonly import("../../contracts/mlx/graph").MlxPhaseGroup[], layers: readonly FixedLayer[]): MlxArray[] {
    const hidden: MlxArray[] = [];
    const results: MlxArray[] = [];
    const bounded = groups.some(group => group.phase === "window" && group.rows > 4);
    try {
      for (const group of groups) hidden.push(this.embed.encode(group.ids));
      for (const [i, layer] of layers.entries()) {
        const mids: MlxArray[] = [];
        try {
          for (const [row, group] of groups.entries())
            mids.push(layer.forwardAttn(hidden[row]!, group.state[i]!, group.phase === "decode" ? "decode" : "window"));
          const outputs = mapPackedTokens(mids, h => layer.forwardMlp(h));
          for (const row of groups.keys()) { hidden[row]!.dispose(); hidden[row] = outputs[row]!; }
          // Materialize every layer's recurrent tail as well as the residual.
          // It is not a dependency of h and otherwise pins prefill buffers.
          if (bounded) {
            const caches = groups.map(group => group.state[i]!);
            const state = caches.map(cache => cache.state());
            try { ops.evalAll([...hidden, ...state.flat()]); }
            finally { for (const [row, cache] of caches.entries())
              if (cache.stateNeedsDispose) for (const value of state[row]!) value.dispose(); }
          }
          for (const [row, group] of groups.entries()) group.capture?.(i, hidden[row]!);
        } finally { for (const mid of mids) mid.dispose(); }
      }
      for (const [row, group] of groups.entries()) {
        const out = this.finalNorm.forward(hidden[row]!); results.push(out);
        group.capture?.(this.layers.length, out);
      }
      return results;
    } catch (error) { for (const result of results) result.dispose(); throw error; }
    finally { for (const h of hidden) h.dispose(); }
  }

  /** The interleaved-mRoPE inverse frequencies, built by the first forward a
   *  media request hands its positions; a text forward keeps the fast rope. */
  #mropeInvFreq: MlxArray | null = null;

  readonly embeddingPrompt: readonly import("../../contracts/mlx/media").MlxEmbeddingsRange[];

  /** The decoder over `h0` (consumed), every block reading its cache for
   *  `phase`, on the fixed layer view the calling operation names.
   *  `bounded` evaluates each layer's output and
   *  recurrent state before the next. `capture` receives each layer's residual
   *  output after the layer runs; the caller hands it the final hidden. */
  protected forwardLayers(h0: MlxArray, cache: Cache[], phase: ReadPhase,
    positions: MlxArray | undefined, capture: MlxLayerCapture | null, layers: readonly FixedLayer[], bounded: boolean): MlxArray {
    const L = h0.shape[1]!;
    // Vision requests: one interleaved-mRoPE cos/sin table per forward,
    // shared by all 12 full-attention layers (positions are layer-invariant).
    let mropeFwd: MropeForwardState | null = null;
    if (positions) {
      const t = this.config.text;
      const ropeDims = Math.trunc(t.headDim * t.partialRotaryFactor);
      const base = t.ropeParameters.full_attention?.ropeTheta ?? 10000;
      this.#mropeInvFreq ??= mropeInvFreq(ropeDims, base);
      mropeFwd = { posIds: positions, invFreq: this.#mropeInvFreq, rotaryDims: ropeDims };
    }
    let h: MlxArray | null = h0;
    const prof = (globalThis as Record<string, unknown>).__deltaProf as
      Record<string, number>
      | undefined;
    try {
      for (let i = 0; i < this.layers.length; i++) {
        const tl = prof ? performance.now() : 0;
        const next: MlxArray = layers[i]!.forward(h!, cache[i]!, phase, mropeFwd);
        h!.dispose();
        h = next;
        if (bounded) {
          // Affine prefills also need bounded evaluation: a retained prefix
          // history can leave too little room for the entire deferred graph.
          // Materialize the cache outputs too. In particular, the tiny
          // copied conv tail is not a dependency of `h`; leaving it lazy
          // pins the whole prefill conv buffer until the chunk ends.
          const state = cache[i]!.state();
          try { ops.evalAll([h, ...state]); }
          finally { if (cache[i]!.stateNeedsDispose) for (const a of state) a.dispose(); }
        }
        if (prof) {
          ops.evalAll([h]);
          const key = this.layers[i]!.isLinear ? "layerLin" : "layerFull";
          prof[key] = (prof[key] ?? 0) + performance.now() - tl;
        }
        capture?.(i, h);
      }
      const out = disposing(h, this.finalNorm.forward(h));
      h = null; // consumed — the finally must not double-free
      return out;
    } finally {
      if (mropeFwd && !positions) mropeFwd.posIds.dispose();
      // A mid-loop layer throw must not strand the in-flight [1,L,H]
      // residual (2026-08-18 review).
      h?.dispose();
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

end Host.Ts.Sources.Inference.Models.Qwen.Qwen35
