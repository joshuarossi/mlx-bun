import type { MlxArray } from "@mlx-bun/mlx/array";
import type { ObjectCache } from "@mlx-bun/inference/contracts/portable";
import type { CheckpointAttachment } from "@mlx-bun/inference/state";
import type { Vision } from "../engine/completion";
import type { ChatRequestParams } from "./chat-request";
import type { RequestOwnership } from "./request-plan";
import type { RequestPrep } from "./request-prep";
export interface BuiltPrompt {
  promptIds: number[]; vision: Vision | undefined; startInThinking: boolean;
  probeStableLen: boolean; diffusionPixels: MlxArray | null;
}
export type PromptNativeWork = <T>(work: () => Promise<T>) => Promise<T>;
export interface ModelPromptBuilder {
  (body: ChatRequestParams, tools: ChatRequestParams["tools"] | null,
    ownership: RequestOwnership, prep: RequestPrep, nativeWork?: PromptNativeWork,
    objects?: ObjectCache<CheckpointAttachment[]>): Promise<BuiltPrompt>;
}
