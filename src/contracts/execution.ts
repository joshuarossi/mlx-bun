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
  readonly checkpoints: boolean;
}

export interface ExecutionFeatures {
  readonly pagedKv: boolean;
  readonly fill: boolean;
}

/** Selected once; consumers execute/report these values without reselecting. */
export interface ResolvedExecution {
  readonly method: "autoregressive" | "speculative" | "denoising";
  readonly mechanism: "serial" | "continuous";
  readonly pagedKv: boolean;
  readonly promptCache: boolean;
  readonly checkpoint: boolean;
  readonly fill: boolean;
  readonly reasons: readonly string[];
}
