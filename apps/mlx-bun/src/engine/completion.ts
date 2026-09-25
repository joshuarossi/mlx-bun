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

/** App-owned completion boundary. HTTP parsing and output formatting stay above it. */
export interface CompletionEngine {
  place(shape: RequestShape, options?: GenerateOptions): GenerationPlacement;
  run(promptIds: number[], options: GenerateOptions & { stopSequences?: string[] },
    onToken: OnToken, vision: Vision | undefined, shape: RequestShape,
    placement: GenerationPlacement, signal?: AbortSignal,
    trace?: PromptResponseTrace): Promise<GenerateStats>;
}
