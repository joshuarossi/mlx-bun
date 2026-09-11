import type { Cache } from "../../model/gemma4-base";
import type { MlxArray } from "../../mlx/array";
import * as ops from "../../mlx/ops";
import { legacyCacheCodecs, type CacheCodecProvider, type CacheHeaderEntry,
  type SnapshotContext } from "../../kv-store";
import { disposeResources } from "../../engine/resources";
import type { CheckpointAttachment } from "./checkpoint-state";
type TensorSlot = SnapshotContext["slots"][number];

/** Reuse the backend cache codecs for method-owned companion state. Tensor
 * slots address attachment indices here; the persistence tier supplies the
 * outer file offsets and checksums. No host serialization of tensors occurs. */
export function captureCacheAttachment(schema: string, caches: readonly Cache[],
  metadata: CheckpointAttachment["metadata"], codecs: CacheCodecProvider = legacyCacheCodecs): CheckpointAttachment {
  const tensors: MlxArray[] = [], headers: Array<CacheHeaderEntry | null> = [];
  try {
    for (const cache of caches) {
      if (!cache.offset) { headers.push(null); continue; }
      const slots: TensorSlot[] = [];
      const liveSlice = (array: MlxArray, length: number, axis = 2) => {
        const end = [...array.shape]; end[axis] = length;
        return array.slice(array.shape.map(() => 0), end);
      };
      const push = (array: MlxArray, owned: boolean) => {
        const value = owned ? array : ops.copyOf(array);
        const off = tensors.length; tensors.push(value);
        slots.push({ off, bytes: value.nbytes, shape: [...value.shape], dtype: value.dtype, hash: "" });
      };
      const context: SnapshotContext = { slots, push, liveSlice,
        liveMlaSlice: (array, length) => liveSlice(array, length, 1),
        pushTriple(triple, length) {
          for (const array of [triple.packed, triple.scales, triple.biases])
            push(length === null ? array : liveSlice(array, length), length !== null);
        },
      };
      const entry = codecs.forCache(cache).snapshot(cache, context);
      if (cache.minimumReusableOffset !== undefined) entry.minimumReusableOffset = cache.minimumReusableOffset;
      headers.push(entry);
    }
    return { schema, metadata: { ...metadata, cacheCodecs: codecs.id, cacheHeaders: JSON.stringify(headers) }, tensors };
  } catch (error) { disposeResources(tensors); throw error; }
}

/** Returned caches own immutable aliases. The caller keeps an external SSD
 * lease until its normal state materialization boundary has completed. */
export function restoreCacheAttachment(attachment: CheckpointAttachment, makeCache: () => Cache[],
  codecs: CacheCodecProvider = legacyCacheCodecs): Cache[] {
  if (attachment.metadata.cacheCodecs !== codecs.id) throw new Error("companion cache codec mismatch");
  const headers = JSON.parse(attachment.metadata.cacheHeaders as string) as Array<CacheHeaderEntry | null>;
  const caches = makeCache(), pending: MlxArray[] = [];
  const arr = (slot: TensorSlot) => {
    const value = ops.copyOf(attachment.tensors[slot.off]!); pending.push(value); return value;
  };
  try {
    for (const [index, entry] of headers.entries()) {
      if (!entry) continue;
      const cache = codecs.forHeader(entry).load(entry, { path: attachment.schema, arr, grownArr: arr,
        triple: (slots, at) => ({ packed: arr(slots[at]!), scales: arr(slots[at + 1]!), biases: arr(slots[at + 2]!) }),
      });
      pending.length = 0;
      cache.minimumReusableOffset = entry.minimumReusableOffset ?? 0;
      const previous = caches[index]; caches[index] = cache;
      previous?.dispose();
    }
    return caches;
  } catch (error) { disposeResources([...pending, ...caches]); throw error; }
}
