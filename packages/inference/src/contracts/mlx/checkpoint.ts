import type { MlxArray } from "@mlx-bun/mlx/array";

/** Generation-method state accompanying the target cache. The method owns
 * its schema and alignment; storage owns these immutable tensor snapshots.
 * Attachments require an exact prefix boundary and are never trimmed. */
export interface CheckpointAttachment {
  schema: string;
  metadata: Record<string, string | number | boolean>;
  tensors: MlxArray[];
}
