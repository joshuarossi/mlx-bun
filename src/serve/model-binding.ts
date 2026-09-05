import type { ModelConfig } from "../config";
import type { MlxArray } from "../mlx/array";
import type { MlxGatewayBinding } from "../backends/mlx/gateway-binding";
import type { MlxSerialServices } from "../backends/mlx/serial-executor";
import type { SsdCacheStore, SsdIndexEntry } from "../ssd-cache";
import type { ChatRequestParams } from "./chat-request";
import type { SerialRun, Vision } from "./generation-gateway";
import type { RequestOwnership } from "./request-plan";
import type { RequestPrep } from "./request-prep";

export interface ServedModelInfo {
  readonly config: ModelConfig;
  readonly weightsBytes: number;
}

export interface BuiltPrompt {
  promptIds: number[];
  vision: Vision | undefined;
  startInThinking: boolean;
  probeStableLen: boolean;
  diffusionPixels: MlxArray | null;
}

export interface ModelPromptBuilder {
  (body: ChatRequestParams, tools: ChatRequestParams["tools"] | null,
    ownership: RequestOwnership, prep: RequestPrep): Promise<BuiltPrompt>;
}

/** Model-owned native services. A replacement supplies this one binding;
 * routes and sessions consume it without requiring a concrete model class. */
export interface ModelServingBinding {
  readonly gateway: MlxGatewayBinding;
  createSerial(services: MlxSerialServices): SerialRun;
  readonly buildPrompt: ModelPromptBuilder;
  restore(store: SsdCacheStore, entry: SsdIndexEntry): ReturnType<SsdCacheStore["restore"]>;
  signal(promptIds: number[], bins: number, minimum: number): Promise<{ bins: number[]; vocab: number }>;
  diagnostics(): Record<string, unknown>;
  readonly discovery: { readonly adapters: boolean; readonly training: boolean;
    readonly dsa: unknown; readonly embeddings: boolean };
  embed?(inputs: string[], instruction?: string): ReturnType<typeof import("../embed").embedMany>;
}
