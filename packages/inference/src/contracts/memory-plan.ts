/** Common admission contract for every runtime. Representation-specific
 * planners may expose richer fields, but serving consumes only this shape. */
export interface MemoryPlan {
  readonly schemaVersion: 1;
  readonly strategy: "generic-kv" | "glm52-colibri";
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
}
