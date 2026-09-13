import type { ObjectCache } from "../../contracts/object-cache";
import { cloneAttachments, disposeAttachments, type CheckpointAttachment } from "./checkpoint-state";
import type { MlxArray } from "../../mlx/array";

/** Encoder-owned tensor schema over the cache's exact-object interface. */
export class EncoderCache {
  constructor(private readonly objects: ObjectCache<CheckpointAttachment[]>) {}

  async take(key: string): Promise<MlxArray | null> {
    const lease = await this.objects.take(`encoder-v1:${key}`);
    if (!lease) return null;
    try {
      const tensor = lease.value[0]!.tensors[0]!;
      return tensor.slice(tensor.shape.map(() => 0), [...tensor.shape]);
    } finally { lease.dispose(); }
  }

  /** Borrow the result; storage retains its own immutable native view. */
  put(key: string, features: MlxArray): void {
    const owned = cloneAttachments([{ schema: "encoder-features-v1", metadata: {}, tensors: [features] }]);
    try { this.objects.put(`encoder-v1:${key}`, owned); }
    catch (error) { disposeAttachments(owned); throw error; }
  }
}
