import { PromptCache, cacheBytes, type ColdTier } from "./prompt-cache";
import { cloneKvCaches, SpillQueue } from "./kv-store";
import { SsdDurabilityCoordinator } from "./ssd-durability";
import { disposeResources } from "./engine/resources";
import type { SsdCacheStore } from "./ssd-cache";

/** One cache with RAM and SSD storage. Inference sees the same put/take
 * interface. Recency and capacity choose RAM residents; a pending write is
 * never treated as a completed demotion. */
export class TieredPromptCache extends PromptCache {
  protected override promoteRestores = true;
  readonly spillQueue: SpillQueue;
  readonly durability: SsdDurabilityCoordinator;

  constructor(
    maxBytes: number,
    storage: Pick<SsdCacheStore, "storeAsync" | "hasDurablePrefix">,
    cold: ColdTier,
    clone = cloneKvCaches,
    readonly writeBehind = true,
  ) {
    super(maxBytes, null, cold, clone);
    this.spillQueue = new SpillQueue(Infinity, cacheBytes, async item => {
      return storage.hasDurablePrefix(item.tokens, item.ns) ||
        await storage.storeAsync(item.tokens, item.caches, item.ns, undefined, item.attachments);
    }, disposeResources, () => false);
    this.durability = new SsdDurabilityCoordinator(this, this.spillQueue, clone,
      (tokens, ns) => storage.hasDurablePrefix(tokens, ns), 0, 5_000, () => {
        // Writing alone does not remove a RAM entry. Apply capacity and
        // pressure policy after the completed writer releases its views.
        this.evictToBudget();
        this.reclaim();
      });
    this.canEvict = entry => {
      if (storage.hasDurablePrefix(entry.tokens, entry.ns)) return true;
      this.durability.schedule(entry.tokens, entry.ns, false);
      return false;
    };
  }

  override put(...args: Parameters<PromptCache["put"]>): void {
    super.put(...args);
    if (this.writeBehind) this.durability.schedule(args[0], args[2]);
  }
}
