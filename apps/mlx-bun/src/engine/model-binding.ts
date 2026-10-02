import type { MlxGatewayBinding } from "@mlx-bun/inference/execution";
import type { SsdCacheStore, SsdIndexEntry } from "@mlx-bun/inference/state";
import type { embedMany } from "@mlx-bun/inference/embeddings";

/** Numerical services supplied by one loaded model. HTTP requests and prompt
 * policy are not part of this boundary; replacement models supply it directly. */
export interface ModelBinding {
  readonly stateCompatibility: string;
  readonly gateway: MlxGatewayBinding;
  restore(store: SsdCacheStore, entry: SsdIndexEntry): ReturnType<SsdCacheStore["restore"]>;
  restoreAsync?(store: SsdCacheStore, entry: SsdIndexEntry): ReturnType<SsdCacheStore["restoreAsync"]>;
  signal(promptIds: number[], bins: number, minimum: number): Promise<{ bins: number[]; vocab: number }>;
  diagnostics(): Record<string, unknown>;
  readonly discovery: { readonly adapters: boolean; readonly training: boolean;
    readonly dsa: unknown; readonly embeddings: boolean };
  embed?(inputs: string[], instruction?: string): ReturnType<typeof embedMany>;
}
