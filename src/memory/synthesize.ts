// mlx-bun memory — synthesis stage 4: SYNTHESIZE.  ⚠️ M1 STUB.
//
// For each bucket touched this run, integrate its new chunks into the bucket's
// article (local-model call) — create-or-update, conservatively. The hard,
// proven gate is inherited from lucien: preserve prose, ≥70% word-count floor,
// every original conv: citation survives, integrate rather than overwrite. A
// weak local pass is gated to NO-OP rather than allowed to corrupt the vault.
// Mirrors lucien's synthesize-dispatch.ts / synthesize-update.ts.
//
// See docs/design/memory-system.md → "Synthesis runs on the local model".

import type { SynthesisEvent } from "./pipeline";

export interface SynthesizeResult {
  articlesCreated: number;
  articlesUpdated: number;
  skippedByGate: number;
}

/** Bucket → article create/update + safety gate (local model). STUB. */
export async function synthesizeBuckets(
  _model: unknown,
  _onEvent?: (e: SynthesisEvent) => void,
): Promise<SynthesizeResult> {
  // TODO(M1): per touched bucket, feed unsynthesized chunks + current article
  // through the synthesize prompt; apply the conservative gate; write the
  // article; record (bucket, chunk_id) in synthesized_bucket_chunks.
  throw new Error("memory.synthesize is not implemented yet (M1)");
}
