// mlx-bun memory — synthesis stage 3: CLUSTER.  ⚠️ M1 STUB.
//
// Assign each new chunk to an existing bucket or propose a new one (local-model
// call). Buckets are emergent (Meta/Buckets.md), each mapping to a target
// article. Mirrors lucien's cluster-assign-recent.ts.
//
// See docs/design/memory-system.md → "The nightly pipeline".

import type { SynthesisEvent } from "./pipeline";

export interface ClusterResult {
  assigned: number;
  newBuckets: number;
}

/** Chunks → buckets (local model). STUB. */
export async function clusterChunks(
  _model: unknown,
  _onEvent?: (e: SynthesisEvent) => void,
): Promise<ClusterResult> {
  // TODO(M1): for each unbucketed chunk, classify into Meta/Buckets.md taxonomy
  // (or propose a new bucket → new article stem); persist chunk.bucket.
  throw new Error("memory.cluster is not implemented yet (M1)");
}
