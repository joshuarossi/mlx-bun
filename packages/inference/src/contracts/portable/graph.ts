/** Describes an implementation's ABI, not a claim of oracle parity or speed. */
export interface GraphDescriptor {
  readonly id: string;
  readonly backend: string;
  readonly graphAbi: string;
  readonly stateAbi: string;
  readonly artifact: string;
}

export type LogitSelection =
  | { readonly type: "all" }
  | { readonly type: "last" }
  | { readonly type: "range"; readonly start: number; readonly end: number };

/** Backend-bound graph. Tensor/State/Inputs stay concrete within the binding.
 * Inputs and hidden are borrowed until the returned lazy work completes;
 * returned hidden/logits are owned by the caller. The graph appends to state.
 * Hidden is [batch, positions, hidden-width]; logits are [batch, selected
 * positions, vocabulary]. Selection precedes the vocabulary projection.
 * Dtypes and evaluation/fence semantics belong to the declared backend ABI.
 * Per-run masks, positions, media, taps, and adapters belong in Inputs or in
 * a bound graph context; they are not mutable session fields. */
export interface AutoregressiveGraph<Tensor, State, Inputs> {
  readonly descriptor: GraphDescriptor;
  forwardHidden(inputs: Inputs, state: State): Tensor | Promise<Tensor>;
  projectLogits(hidden: Tensor, selection: LogitSelection): Tensor;
}

/** Which methods a graph's delayed affine KV is qualified for. Delayed affine rows
 * start plain and convert once a row passes its `quantizedKvStart`.
 * - `none`: rows never convert; an affine start past 0 is refused.
 * - `ordinary`: rows convert per layer where every cache layer is plain or
 *   rotating-plain; qualified for ordinary continuous decoding, generation
 *   checkpoints and committed grammar spans, not for speculation or fill.
 * - `all`: the graph's own caches convert and every method is qualified. */
export type DelayedAffineKv = "none" | "ordinary" | "all";

/** How prepared media reaches the graph.
 * - `embeddings`: spliced prompt embeddings (image/audio soft tokens, optional
 *   bidirectional and multimodal masks) enter the ordinary forward.
 * - `embeddings+positions`: spliced embeddings with request-owned multi-axis
 *   rotary positions and a decode delta.
 * - `pixels`: raw image pixels are the denoising method's own prefill input. */
export type GraphMediaInput = "embeddings" | "embeddings+positions" | "pixels";

/** Facts a graph declares once, when it is constructed. Composition binds the
 * operations these facts require and refuses what is genuinely missing;
 * scheduling reads only these declarations plus request and dynamic state
 * (batch membership, cache contents, cancellation), never a model's class or
 * name. A declaration that promises an operation is checked where it is bound. */
export interface GraphCapabilities {
  /** The method the graph's forward serves. Token-level methods (speculation,
   * grammar proposals, fill) bind only to `autoregressive`. */
  readonly method: "autoregressive" | "denoising";
  readonly adapters: {
    /** Named mount points exist: rows select adapters inside one shared group. */
    readonly batched: boolean;
    /** The application offers adapter mounting and training for this graph. */
    readonly mountable: boolean;
  };
  /** Prepared media the graph accepts, or null. Requests carrying prepared
   * embeddings need a `bindMediaInput` operation; `video` says video frames
   * are accepted input. */
  readonly media: { readonly input: GraphMediaInput; readonly video: boolean } | null;
  /** Attention accepts paged KV storage. */
  readonly pagedAttention: boolean;
  /** The graph owns a compiled decode step. Cache geometry can still decline it. */
  readonly compiledDecode: boolean;
  /** Attention selects a sparse subset of positions (surfaced to clients). */
  readonly sparseAttention: boolean;
  /** The graph exposes a pooled text-embedding path. */
  readonly embeddings: boolean;
  /** Hidden-layer outputs can be tapped for drafts that read them. */
  readonly hiddenLayerTaps: boolean;
  /** A draft head the graph's own checkpoint carries and has loaded, or null.
   * `kind` names the native draft provider that binds to this graph; the
   * provider registry resolves it, so no consumer names the graph or its
   * provider. `numDraftTokens` is the head's round width. */
  readonly nativeDraft: { readonly kind: string; readonly numDraftTokens: number } | null;
  /** How prefill is sized for this graph. */
  readonly prefill: {
    /** Long prompts prefill in smaller chunks so the attention score matrices
     * a fallback (unfused) attention materializes stay within a fixed
     * workspace. It changes work size, never admission. */
    readonly boundedWorkspace: boolean;
  };
  readonly kv: {
    /** Attention reads plain keys and values only (softcapped attention);
     * encoded storage must decode on read. The layers are the graph's
     * `requiredDenseKvLayers`. */
    readonly denseReads: boolean;
    readonly delayedAffine: DelayedAffineKv;
  };
  /** What the graph's target verification qualifies beyond ordinary plain-KV
   * rounds. Each is a property of the graph's verifier, independent of the
   * draft that supplies proposals. */
  readonly speculation: {
    /** Verification under mounted adapters. */
    readonly adapters: boolean;
    /** Verification of requests that return logprobs. */
    readonly logprobs: boolean;
    /** Verification over affine KV. */
    readonly affineKv: boolean;
    /** Verification over TurboQuant KV. */
    readonly turboKv: boolean;
    /** Immediate (start 0) 4-bit affine KV is qualified even where no grouped
     * method is bound, so such a draft is refused rather than ignored. */
    readonly immediateAffine4: boolean;
    /** Verification of externally supplied tokens (echo of a known continuation). */
    readonly externalTokens: boolean;
    /** Verified grammar-constraint proposals. */
    readonly grammarProposals: boolean;
  };
}

/** A fused InferenceMethod can bypass this graph interface entirely. It need
 * only satisfy the method's output, cancellation, and ownership contracts. */
export interface GraphFactory<Artifact, Binding, Graph> {
  open(artifact: Artifact, binding: Binding): Promise<{ graph: Graph; close(): Promise<void> }>;
}
