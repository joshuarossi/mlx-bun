// mlx-bun memory — synthesis stage 2: CHUNK.  ⚠️ M1 STUB.
//
// Segment each new conversation into topic chunks (a local-model call — this is
// the segmentation track distilled from gold; eval by boundary/label accuracy).
// Re-chunk only conversations whose updated_at > chunked_at. Mirrors lucien's
// chunk-recent.ts. The prompt is the future "chunk" LoRA seam (prompts.ts).
//
// See docs/design/memory-system.md → "The nightly pipeline".

import type { SynthesisEvent } from "./pipeline";

export interface ChunkResult {
  conversations: number;
  chunks: number;
}

/** Conversations → topic chunks (local model). STUB. */
export async function chunkConversations(
  _model: unknown,
  _onEvent?: (e: SynthesisEvent) => void,
): Promise<ChunkResult> {
  // TODO(M1): for each conv with updated_at > chunked_at, run the chunk prompt
  // on the local model, write chunks, set chunked_at.
  throw new Error("memory.chunk is not implemented yet (M1)");
}
