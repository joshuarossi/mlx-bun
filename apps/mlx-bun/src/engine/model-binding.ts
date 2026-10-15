import type { MlxGatewayBinding } from "@mlx-bun/inference/execution";
import type { embedMany } from "@mlx-bun/inference/embeddings";

/** Numerical services supplied by one loaded model. HTTP requests and prompt
 * policy are not part of this boundary; replacement models supply it directly.
 * Saved state restores through the cache service, into the caches the loaded
 * graph composes. */
export interface ModelBinding {
  readonly stateCompatibility: string;
  readonly gateway: MlxGatewayBinding;
  signal(promptIds: number[], bins: number, minimum: number): Promise<{ bins: number[]; vocab: number }>;
  diagnostics(): Record<string, unknown>;
  readonly discovery: { readonly adapters: boolean; readonly training: boolean;
    readonly dsa: unknown; readonly embeddings: boolean; readonly decisions?: boolean };
  embed?(inputs: string[], instruction?: string): ReturnType<typeof embedMany>;
  /** Teacher-forced answer scoring, no generated tokens. Borrows prepared
   * media. When execute is supplied, every candidate's native work and cleanup
   * must settle inside that boundary; otherwise the caller owns graph access. */
  decide?(input: { prompt: number[]; candidates: number[][];
    vision?: import("@mlx-bun/inference/contracts/mlx").Vision; signal?: AbortSignal;
    /** Schedule one candidate at a time beside live generation rows. */
    execute?: <T>(work: () => Promise<T>) => Promise<T>;
  }): Promise<number[]>;
}
