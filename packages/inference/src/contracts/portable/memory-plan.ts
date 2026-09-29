/** Common admission contract for every runtime. Representation-specific
 * planners may expose richer fields, but serving consumes only this shape. */
export interface MemoryPlan {
  readonly schemaVersion: 1;
  /** Names the accounting the plan comes from; informational, never branched on. */
  readonly strategy: string;
  readonly fits: boolean;
  readonly contextTokens: number;
  readonly maxSafeContext: number;
  readonly weightsBytes: number;
  readonly kvBytes: number;
  readonly transientBytes: number;
  readonly reserveBytes: number;
  readonly totalBytes: number;
  readonly usableBytes: number;
  readonly predictedDecodeTps: number | null;
  /** mlx allocator-cache limit, distinct from the process admission limit. */
  readonly allocatorLimitBytes?: number;
  /** Generated-token allowance reserved within `contextTokens`; absent when the plan reserves none. */
  readonly maxGenerationTokens?: number;
  /** Parts of `weightsBytes` held in bounded streaming tiers instead of resident
   * memory, by display label. Resident weights are `weightsBytes` minus their sum. */
  readonly streamedWeights?: Readonly<Record<string, number>>;
  /** RAM the plan leaves to the rest of the machine. */
  readonly machineHeadroomBytes?: number;
}
