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
import { runtimeFlag } from "../../runtime/config";
import { mapTokenGroups } from "../../input/token-groups";
import { type TokenGroup } from "../../contracts/mlx/token-work";
import type { MlxArray } from "@mlx-bun/mlx/array";
import { deviceArchitecture } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { qwenAppendChunkSize } from "../../layers/qwen-append";
import { TRELLIS_MATVEC_MAX_M } from "../../layers/trellis-linear";
import { argmaxLastPosition } from "../../kernels/logits";
import { disposing } from "../../layers/helpers";
import { KVCache } from "../../state/kv";
import { AttentionMasks } from "../../state/attention-read";
import { LoraState } from "../../layers/lora";
import { QuantizedEmbedding } from "../../layers/quantized-embedding";
import { QuantizedLinear } from "../../layers/quantized-linear";
import { RMSNorm } from "../../layers/normalization";
import { type Cache } from "../../contracts/mlx/cache";
import { qwen35WeightsView } from "./checkpoint";
import type { GraphCapabilities } from "../../contracts/portable/graph";
import type { MlxDeclaredGraph } from "../../contracts/mlx/graph";
import type { TargetView } from "../../contracts/mlx/draft-target";
import type { MediaEncoders, MlxPromptInput, Vision } from "../../contracts/mlx/media";
import { declareGraph } from "../capabilities";
import { bindQwenMediaInput, qwenDraftTarget, qwenMediaEncoders } from "./media-input";
import { SSMCache } from "../../state/ssm";
import { buildMropePositions, mropeInvFreq } from "../../layers/qwen-mrope";
import { type MropeRequestState } from "../../contracts/mlx/positions";
import { Qwen3Layer, type ReadPhase } from "./blocks";

const PREFIX = "language_model";

// A2's phase types (`contracts/mlx/graph.ts` and `atEveryWidth` in
// `models/graph.ts` on refactor/composition-a2), copied so this graph names the
// same phases before A2 merges. The merge replaces them with A2's imports.
type MlxLayerCapture = (layer: number, hidden: MlxArray) => void;
type MlxPhaseForward = (ids: MlxArray, state: Cache[]) => MlxArray | Promise<MlxArray>;
type MlxVerifyForward = (ids: MlxArray, state: Cache[], capture: MlxLayerCapture | null) =>
  MlxArray | Promise<MlxArray>;
interface MlxWidthTable<Operation> {
  readonly one: Operation;
  readonly twoToFour: Operation;
  readonly fiveToEight: Operation;
  readonly wider: Operation;
}
function atEveryWidth<Operation>(operation: Operation): MlxWidthTable<Operation> {
  return Object.freeze({ one: operation, twoToFour: operation, fiveToEight: operation, wider: operation });
}

/** The phase of a forward reaching one of the deprecated entry points
 * (`forwardHidden`, `forwardHiddenMixed`, `forwardHiddenAtPositions`,
 * `forwardEmbeddingsAtPositions`, `forwardEmbeddings`, `createAppend`'s
 * `forwardHidden`, the MTP companion's `forward`), derived from the shape of
 * the input it was handed, [rows, tokens, ...]. A committed-append forward
 * (`committedAppend`) of one row is a committed span; otherwise one position
 * per row is a decode and more is a window. A padded forward of one position
 * per row would read as a decode, which ignores prefill padding; no caller pads
 * a one-position forward.
 * @deprecated E2 deletes this adapter when the scheduler calls the named phases
 * (`prefillChunk`, `prefillTail`, `decode`, `verify` and the committed append).
 * Nothing else in the graph or its blocks derives the phase from a shape. */
export function deprecatedPhase(input: MlxArray, committedAppend = false): ReadPhase {
  const [rows, tokens] = input.shape as [number, number];
  if (committedAppend && rows === 1) return "committed";
  return tokens === 1 ? "decode" : "window";
}

export class Qwen35Model implements MlxDeclaredGraph {
  readonly config: ModelConfig;
  readonly weightsBytes: number;
  /** Base path for LoRA target keys (weights carry the language_model prefix). */
  readonly prefixBase = "language_model.model";
  readonly loraState = new LoraState();
  /** Layers whose attention reads plain keys and values: none; it attends the storage its caches hold. */
  readonly requiredDenseKvLayers: readonly number[] = Object.freeze([]);
  /** Prepared image and video embeddings with request-owned mRoPE positions,
   * layer taps for drafts. Its caches convert delayed affine rows and every
   * method is qualified over them. Speculation over affine KV is this graph's
   * option `MLX_BUN_QWEN_SPEC_KV4`, read where the graph is bound; immediate
   * 4-bit KV is qualified even without a grouped method. Its few
   * full-attention layers materialize their scores at long context, so prefill
   * chunks shrink to bound that workspace. */
  get graphCapabilities(): GraphCapabilities {
    return declareGraph({
      media: { input: "embeddings+positions", video: true }, hiddenLayerTaps: "hiddenTap" in this,
      kv: { delayedAffine: "all" }, prefill: { boundedWorkspace: true },
      speculation: { affineKv: runtimeFlag("MLX_BUN_QWEN_SPEC_KV4", true), immediateAffine4: true },
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
  /** `MLX_BUN_MIXED_PACKED_MLP`: the groups of a mixed forward share one MLP
   *  call (on unless set to 0). Read once, when the graph is built. */
  readonly #packMixedMlp: boolean;

  constructor(weights: Weights, config: ModelConfig) {
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
      (_, i) => new Qwen3Layer(weights, config, i),
    );
    this.finalNorm = new RMSNorm(weights.tensor(`${PREFIX}.model.norm.weight`), config.text.rmsNormEps);
    // Tied models (e.g. Qwen3.5-4B) ship no lm_head; the reference uses
    // embed_tokens.as_linear (mlx-lm qwen3_5 TextModel.__call__).
    this.lmHead = this.tied ? null : QuantizedLinear.load(weights, `${PREFIX}.lm_head`, config);
    this.faIdx = config.text.fullAttentionInterval - 1;
    this.#packMixedMlp = runtimeFlag("MLX_BUN_MIXED_PACKED_MLP", true);
  }

  loraTargets(): Map<string, QuantizedLinear> {
    const out = new Map<string, QuantizedLinear>();
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
      // Trellis-coded MLP tensors are not LoRA targets (no adapter seam yet).
      if (l.mlp.kind === "affine") {
        out.set(`${p}.mlp.gate_proj`, l.mlp.gate);
        out.set(`${p}.mlp.up_proj`, l.mlp.up);
        out.set(`${p}.mlp.down_proj`, l.mlp.down);
      }
    }
    return out;
  }

  /** One cache per layer, the full-attention caches sharing one mask memo. */
  makeCache(): Cache[] {
    const masks = new AttentionMasks();
    return this.layers.map((l) => (l.isLinear ? new SSMCache() : new KVCache(masks)));
  }

  /** The 27B append path keeps the native M1 affine arithmetic while Trellis
   * shares up to four rows. Other shapes retain single-token execution. */
  createAppend(policy: { hasAdapters: boolean; pagedKv: boolean }) {
    const t = this.config.text;
    if (policy.hasAdapters || policy.pagedKv || this.loraState.active.length || this.mrope ||
        t.hiddenSize !== 5120 || t.intermediateSize !== 17408 || this.layers.length !== 64 ||
        t.headDim !== 256 || t.numAttentionHeads !== 24 || t.numKeyValueHeads !== 4)
      return null;
    if (deviceArchitecture() !== "applegpu_g16s") return null;
    const qualified = (linear: QuantizedLinear) => {
      const { mode, bits, groupSize } = linear.spec;
      return mode === "affine" && [2, 3, 4, 6, 8].includes(bits) && [32, 64, 128].includes(groupSize);
    };
    for (const layer of this.layers) {
      const a = layer.linearAttn, s = layer.selfAttn;
      const attention = a ? [a.inProjQkv, a.inProjZ, a.inProjB, a.inProjA, a.outProj]
        : [s!.qProj, s!.kProj, s!.vProj, s!.oProj];
      const mlp = layer.mlp.kind === "affine" ? [layer.mlp.gate, layer.mlp.up, layer.mlp.down] : [];
      if (!attention.every(qualified) || !mlp.every(qualified))
        return null;
    }
    return {
      affineKvBits: [4, 8],
      turboQuantFormats: [{ kBits: 8, vBits: 3 }],
      maxChunkSize: (state: readonly Cache[], rows = 1) => rows === 1 ? qwenAppendChunkSize(state[0]!.offset) : 1,
      forwardHidden: (ids: MlxArray, cache: Cache[]): MlxArray => {
        // Wider cohorts retain their ordinary one-position numerical graph.
        // The specialized multi-position append remains qualified at B=1.
        const [rows, tokens] = ids.shape as [number, number];
        if (ids.shape.length !== 2 || !(rows === 1 ? tokens <= 4 : rows > 1 && tokens === 1))
          throw new Error("Qwen committed-token append supports one position per shared row or up to four positions at B=1");
        return this.forwardLayers(this.embed.encode(ids), cache, deprecatedPhase(ids, true));
      },
    };
  }

  forwardHidden(ids: MlxArray, cache: Cache[]): MlxArray {
    const h = this.embed.encode(ids);
    return this.forwardLayers(h, cache, deprecatedPhase(ids));
  }

  /** One whole chunk of a prompt: tokens per sequence equal the composition's
   * prefill chunk size; rows are sequences times that size. Token ids only: a
   * prompt with prepared media enters through the `MlxPromptInput` that
   * `bindMediaInput` returns (for `embeddings+positions`, the graph's
   * `forwardEmbeddingsAtPositions`). */
  prefillChunk(ids: MlxArray, state: Cache[]): MlxArray {
    return this.forwardLayers(this.embed.encode(ids), state, "window");
  }

  /** The positions left at the end of a prompt after its whole chunks, fewer
   * than the chunk size per sequence; rows are sequences times those tokens.
   * The same semantics as `prefillChunk`, named apart because a composition
   * may run it on different hardware. */
  prefillTail(ids: MlxArray, state: Cache[]): MlxArray {
    return this.forwardLayers(this.embed.encode(ids), state, "window");
  }

  /** One new token per sequence: `ids` [sequences, 1], so rows are sequences. */
  readonly decode: MlxWidthTable<MlxPhaseForward> = atEveryWidth<MlxPhaseForward>((ids, state) =>
    this.forwardLayers(this.embed.encode(ids), state, "decode"));

  /** A speculative window: each sequence's last accepted token and its drafted
   * tokens, right-padded by the caller to the round's depth, `ids`
   * [sequences, depth + 1], so rows are sequences times (depth + 1). The graph
   * appends all depth + 1 positions; dropping the rejected suffix is the
   * caller's speculative transaction, begun before this call. */
  readonly verify: MlxWidthTable<MlxVerifyForward> = atEveryWidth<MlxVerifyForward>((ids, state, capture) => {
    const hidden = this.forwardLayers(this.embed.encode(ids), state, "window", undefined, capture);
    capture?.(this.layers.length, hidden);
    return hidden;
  });

  /** Borrowed request positions, including different positions for each row. */
  forwardHiddenAtPositions(ids: MlxArray, cache: Cache[], positions: MlxArray): MlxArray {
    return this.forwardLayers(this.embed.encode(ids), cache, deprecatedPhase(ids), positions);
  }

  forwardEmbeddingsAtPositions(embeds: MlxArray, cache: Cache[], positions: MlxArray): MlxArray {
    return this.forwardLayers(ops.contiguous(embeds), cache, deprecatedPhase(embeds), positions);
  }

  /** Attention and DeltaNet retain disjoint row state. Only tokenwise MLP
   * work is eligible for packing; verification can preserve its geometry. */
  forwardHiddenMixed(work: readonly TokenGroup[]): MlxArray[] {
    if (work.length === 1 && !work[0]!.captureLayer) return [this.forwardHidden(work[0]!.ids, work[0]!.cache)];
    const groups: Array<{ h: MlxArray; phase: ReadPhase }> = [];
    const results: MlxArray[] = [];
    const bounded = work.some(group => group.ids.shape[1]! > TRELLIS_MATVEC_MAX_M);
    try {
      for (const { ids } of work) groups.push({ h: this.embed.encode(ids), phase: deprecatedPhase(ids) });
      for (const [i, layer] of this.layers.entries()) {
        const mids: MlxArray[] = [];
        try {
          for (const [row, group] of groups.entries())
            mids.push(layer.forwardAttn(group.h, work[row]!.cache[i]!, group.phase));
          // Packed rows of several groups share one MLP; no group here is a
          // committed span, so every row takes the shared projection arithmetic.
          const outputs = mapTokenGroups(work, mids, hidden => layer.forwardMlp(hidden, "window"), this.#packMixedMlp);
          for (const [row, group] of groups.entries()) { group.h.dispose(); group.h = outputs[row]!; }
          // Materialize every layer's recurrent tail as well as the residual.
          // It is not a dependency of h and otherwise pins prefill buffers.
          if (bounded) {
            const caches = work.map(group => group.cache[i]!);
            const state = caches.map(cache => cache.state());
            try { ops.evalAll([...groups.map(group => group.h), ...state.flat()]); }
            finally { for (const [row, cache] of caches.entries())
              if (cache.stateNeedsDispose) for (const value of state[row]!) value.dispose(); }
          }
          for (const [row, group] of groups.entries()) work[row]!.captureLayer?.(i, group.h);
        } finally { for (const mid of mids) mid.dispose(); }
      }
      for (const [row, group] of groups.entries()) {
        const hidden = this.finalNorm.forward(group.h); results.push(hidden);
        work[row]!.captureLayer?.(this.layers.length, hidden);
      }
      return results;
    } catch (error) { for (const result of results) result.dispose(); throw error; }
    finally { for (const group of groups) group.h.dispose(); }
  }

  /** Active vision mRoPE request state (serial lane; set by the generation
   *  gateway around a vision request's run, null for text-only — which keeps
   *  the bit-exact fast-rope path). The explicit serial executor scopes this value.
   *  Shared media forwards pass request-owned positions directly. */
  mrope: MropeRequestState | null = null;
  #mropeInvFreq: MlxArray | null = null;

  /** Vision prefill: spliced input embeddings [1, L, H] (image features
   *  overwriting image-token rows — the caller builds them). Caller keeps
   *  ownership of `embeds`. bidir/ids/multimodal are the Gemma-shaped extras
   *  and are unused: Qwen3.5 vision attends fully causally. */
  forwardEmbeddings(
    embeds: MlxArray, cache: Cache[], _bidir: MlxArray | null,
    _ids: MlxArray | null = null, _multimodal: MlxArray | null = null,
  ): MlxArray {
    const h = ops.contiguous(embeds); // fresh handle — the layer loop consumes it
    return this.forwardLayers(h, cache, deprecatedPhase(embeds));
  }

  /** Layer-output tap (same contract as Gemma4Model.hiddenTap): the serve
   *  loop's forwardMaybeTap sets it around prefill/verify forwards so
   *  KV-borrowing draft sources (native Qwen MTP) can read PRE-final-norm
   *  hiddens — layer 63's output stream, what mlx-vlm captures with
   *  skip_final_norm=True. No-op (and graph-identical) when null. */
  hiddenTap: { layers: Set<number>; pos?: number; captured: Map<number, MlxArray> } | null = null;

  /** Store layer `i`'s residual stream ([1,L,H]) if the tap requests it.
   *  Copies so the loop's h.dispose() can't free the capture. */
  protected captureLayer(i: number, h: MlxArray): void {
    const tap = this.hiddenTap;
    if (!tap || !tap.layers.has(i)) return;
    const H = h.shape[2]!;
    const src = tap.pos !== undefined ? h.slice([0, tap.pos, 0], [1, tap.pos + 1, H]) : h;
    const copy = ops.contiguous(src);
    if (src !== h) src.dispose();
    tap.captured.set(i, copy);
  }

  /** The decoder over `h0` (consumed), every block reading its cache for
   *  `phase`. `capture` receives each layer's residual output after the layer
   *  runs; the caller hands it the final hidden. */
  protected forwardLayers(h0: MlxArray, cache: Cache[], phase: ReadPhase,
    positions?: MlxArray, capture: MlxLayerCapture | null = null): MlxArray {
    const L = h0.shape[1]!;
    // Vision requests: one interleaved-mRoPE cos/sin table per forward,
    // shared by all 12 full-attention layers (positions are layer-invariant).
    let mropeFwd: ReturnType<typeof buildMropePositions> | null = null;
    if (positions || this.mrope) {
      const t = this.config.text;
      const ropeDims = Math.trunc(t.headDim * t.partialRotaryFactor);
      const base = t.ropeParameters.full_attention?.ropeTheta ?? 10000;
      this.#mropeInvFreq ??= mropeInvFreq(ropeDims, base);
      mropeFwd = positions ? { posIds: positions, invFreq: this.#mropeInvFreq, rotaryDims: ropeDims }
        : buildMropePositions(this.mrope!, cache[this.faIdx]!.offset, L, this.#mropeInvFreq, ropeDims);
    }
    let h: MlxArray | null = h0;
    const prof = (globalThis as Record<string, unknown>).__deltaProf as
      Record<string, number>
      | undefined;
    try {
      for (let i = 0; i < this.layers.length; i++) {
        const tl = prof ? performance.now() : 0;
        const next = this.layers[i]!.forward(h, cache[i]!, phase, mropeFwd);
        h.dispose();
        h = next;
        if (L > TRELLIS_MATVEC_MAX_M) {
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
        this.captureLayer(i, h); // native-MTP pre-final-norm tap (no-op unless set)
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
    return this.tied ? this.embed.asLinear(h) : this.lmHead!.forward(h);
  }

  forward(tokens: number[] | MlxArray, cache: Cache[]): MlxArray {
    const ids = Array.isArray(tokens)
      ? ops.fromInt32(tokens, [1, tokens.length])
      : tokens;
    const h = this.forwardHidden(ids, cache);
    if (Array.isArray(tokens)) ids.dispose();
    const logits = this.logitsFromHidden(h);
    h.dispose();
    return logits;
  }

  generate(promptTokens: number[], maxTokens: number, eosIds: number[] = []): number[] {
    const cache = this.makeCache();
    const out: number[] = [];
    try {
      let tokens = promptTokens;
      for (let step = 0; step < maxTokens; step++) {
        const logits = this.forward(tokens, cache);
        const next = argmaxLastPosition(logits);
        logits.dispose();
        if (eosIds.includes(next)) break;
        out.push(next);
        tokens = [next];
      }
    } finally {
      for (const c of cache) c.dispose();
    }
    return out;
  }
}
