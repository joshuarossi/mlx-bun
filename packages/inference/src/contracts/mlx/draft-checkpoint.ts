import type { CheckpointAttachment } from "./checkpoint";

export interface DraftRowCheckpoint {
  readonly processedTokens: number;
  readonly attachment: CheckpointAttachment;
}
