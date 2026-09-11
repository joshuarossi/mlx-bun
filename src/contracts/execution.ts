/** Request facts only. Native resources remain with the preparation owner. */
export interface ExecutionRequirements {
  readonly hasVision: boolean;
  readonly hasAdapters: boolean;
  readonly hasRepetitionPenalty: boolean;
  readonly userSeed: boolean;
  readonly kvQuant: boolean;
  readonly turboQuant: boolean;
  readonly hasLogitsExtras: boolean;
  readonly hasGrammar: boolean;
  readonly wantsLogprobs: boolean;
  readonly hasDraft: boolean;
}

export interface ExecutionCapabilities {
  readonly method: "autoregressive" | "denoising";
  readonly continuous: boolean;
  readonly quantizedBatch: boolean;
  readonly grammarBatch: boolean;
  readonly adapterBatch?: boolean;
  readonly pagedBatch?: boolean;
  readonly checkpoints: boolean;
  /** Bound ordinary driver can restore/capture this request configuration. */
  readonly sharedCheckpoints?: boolean;
  /** Model-qualified speculative execution can retain this request's KV codec. */
  readonly speculativeKvQuant?: boolean;
  readonly speculativeTurboQuant?: boolean;
  readonly turboQuantBatch?: boolean;
  readonly speculativeLogprobs?: boolean;
  /** The grouped provider supports the target's mounted adapter context. */
  readonly sharedSpeculativeAdapters?: boolean;
  /** Methods supplied by the model's shared execution binding. */
  readonly groupedMethods?: readonly string[];
  /** A graph-owned compiled step exists; cache geometry can still decline it. */
  readonly compiledDecode?: boolean;
}

export interface ExecutionFeatures {
  readonly pagedKv: boolean;
  readonly fill: boolean;
  readonly compiledDecode?: boolean;
  readonly grammarJump?: boolean;
}

/** Selected once; consumers execute/report these values without reselecting. */
export interface ResolvedExecution {
  /** Implementation-owned method ID. The built-in planner retains its known
   * methods; another model may register a different set without editing this contract. */
  readonly method: string;
  readonly mechanism: "serial" | "continuous";
  readonly pagedKv: boolean;
  readonly promptCache: boolean;
  readonly checkpoint: boolean;
  readonly fill: boolean;
  /** Permission to attempt the bound compiled step, never a promise that
   * every dynamic row/state shape supports replay. */
  readonly compiledDecode: boolean;
  readonly grammarJump: boolean;
  readonly reasons: readonly string[];
}
