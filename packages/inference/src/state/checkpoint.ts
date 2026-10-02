import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cache } from "../contracts/mlx/cache";
import { cleanupFailure,disposeResources,withResource } from "../runtime/resources";
import { leaseCacheStates } from "./leases";

export function attachmentBytes(attachments: readonly CheckpointAttachment[] = []): number {
  return attachments.reduce((sum, entry) =>
    sum + entry.tensors.reduce((bytes, tensor) => bytes + tensor.nbytes, 0), 0);
}

export function disposeAttachments(attachments: readonly CheckpointAttachment[] = []): void {
  disposeResources(attachments.flatMap((entry) => entry.tensors));
}

export function cloneAttachments(attachments: readonly CheckpointAttachment[] = []): CheckpointAttachment[] {
  const held: MlxArray[] = [];
  try {
    return attachments.map((entry) => ({
      schema: entry.schema, metadata: { ...entry.metadata },
      tensors: entry.tensors.map((tensor) => {
        const copy = tensor.slice(tensor.shape.map(() => 0), [...tensor.shape]);
        held.push(copy);
        return copy;
      }),
    }));
  } catch (error) { return cleanupFailure(error, () => disposeResources(held)); }
}

/** Shared cache port for MLX execution methods and their companion state. */
export type MlxPrefixCache = import("../contracts/portable/prefix-cache").PrefixCache<
  import("../contracts/mlx/cache").Cache[], CheckpointAttachment[]
>;

/** Resolve snapshot copies before storage retains them. A deferred compact
 * row still owns its full parent batch; persistence may wait until idle.
 * This only settles GPU state and performs no serialization or disk I/O. */
export function materializeCheckpoint(caches: Cache[], attachments: readonly CheckpointAttachment[] = []): void {
  withResource(leaseCacheStates(caches), state => {
    const tensors = [...state, ...attachments.flatMap(attachment => attachment.tensors)];
    if (tensors.length) ops.evalAll(tensors);
  });
}

import { CheckpointAttachment } from "../contracts/mlx/checkpoint";
export { type CheckpointAttachment } from "../contracts/mlx/checkpoint";
