import type { CheckpointAttachment } from "./checkpoint";

export interface DraftRowCheckpoint {
  readonly processedTokens: number;
  readonly attachment: CheckpointAttachment;
}

/** Attachment schemas of the draft methods' persisted row state. The strings
 * are stored in checkpoints, so they never change with the code that reads them. */
export const DRAFT_CHECKPOINT_SCHEMA = Object.freeze({
  assistant: "gemma-assistant-v1",
  qwenMtp: "qwen-mtp-v1",
  glm52Mtp: "glm52-native-mtp-v1",
});
