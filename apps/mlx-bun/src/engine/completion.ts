import type { GenerateOptions, GenerateStats } from "@mlx-bun/inference/generation";
import type { ExecutionRequirements, ResolvedExecution, OnToken } from "@mlx-bun/inference/contracts/portable";
import type { Vision } from "@mlx-bun/inference/contracts/mlx";
import type { PromptResponseTrace } from "@mlx-bun/inference/runtime/trace";

export type { OnToken } from "@mlx-bun/inference/contracts/portable";
export type { Vision } from "@mlx-bun/inference/contracts/mlx";
export interface RequestShape extends ExecutionRequirements {}
export interface GenerationPlacement {
  readonly shape: RequestShape;
  readonly mechanism: "continuous";
  readonly execution: ResolvedExecution;
}

const sharedExecutionExclusions = new Set([
  "continuous-unavailable", "media-batch-unsupported", "adapter-batch-unsupported",
  "kv-scheme-batch-unsupported", "turbo-kv-batch-unsupported", "grammar-batch-unsupported",
  "paged-kv-batch-unsupported", "method-batch-unsupported",
]);

/** A migrated request shape whose shared executor is not available yet.
 * Transport layers can distinguish this capability gap from an execution failure. */
export class UnsupportedExecutionError extends Error {
  readonly reasons: readonly string[];
  constructor(readonly modelType: string, readonly method: ResolvedExecution["method"], reasons: readonly string[]) {
    const exclusions = reasons.filter(reason => sharedExecutionExclusions.has(reason));
    super(`model ${modelType} method ${method} does not support shared execution${exclusions.length ? `: ${exclusions.join(", ")}` : ""}`);
    this.name = "UnsupportedExecutionError";
    this.reasons = Object.freeze(exclusions);
  }
}

/** App-owned completion boundary. HTTP parsing and output formatting stay above it. */
export interface CompletionEngine {
  place(shape: RequestShape, options?: GenerateOptions): GenerationPlacement;
  run(promptIds: number[], options: GenerateOptions & { stopSequences?: string[] },
    onToken: OnToken, vision: Vision | undefined, shape: RequestShape,
    placement: GenerationPlacement, signal?: AbortSignal,
    trace?: PromptResponseTrace): Promise<GenerateStats>;
}
