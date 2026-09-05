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
