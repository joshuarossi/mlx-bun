// The companion hosts (one per non-chat operation: Whisper for `transcribe`, the
// image host for `image`) behind one `ModelHost`. Each call goes to the host of
// the operation the model declares: the operation a caller needs, else the one
// the catalog entry declares; a default the composite answered or a configured
// checkpoint is remembered, so a synchronous call (pin, stats) reaches its host
// too. Nothing here names a model: the composition supplies the hosts by
// operation, and each keeps its own residency, lock and lifecycle.
import type { AcquireOptions, ModelCatalog, ModelHost, ModelId, ModelLease, ModelOperation, ModelStats, ResidencyPolicy, ResidentModel } from "@mlx-bun/app-core";
import { ModelHostFailure } from "./failure";

/** A companion host: the contract plus the release its composer owns. */
export interface CompanionHost extends ModelHost {
  close(): Promise<void>;
}

/** The companion hosts as one `ModelHost`; `close` releases every host. */
export interface CompanionModelHost extends ModelHost {
  close(): Promise<void>;
}

export interface CompanionModelHostOptions {
  /** The host serving each companion operation. */
  hosts: Readonly<Partial<Record<ModelOperation, CompanionHost>>>;
  /** Says which operations a model declares when the caller names none of a host's. */
  catalog: Pick<ModelCatalog, "find">;
  /** Ids the composition already knows the operation of (configured checkpoints that need not be in the catalog). */
  known?: Readonly<Record<ModelId, ModelOperation>>;
}

export function createCompanionModelHost(options: CompanionModelHostOptions): CompanionModelHost {
  const entries = Object.entries(options.hosts) as [ModelOperation, CompanionHost][];
  const hosts = entries.map(([, host]) => host);
  /** The operation each id resolved to, so later calls for it reach the same host. */
  const learned = new Map<ModelId, ModelOperation>(Object.entries(options.known ?? {}).filter(([, operation]) => options.hosts[operation]));
  const learnedHost = (id: ModelId) => { const operation = learned.get(id); return operation ? options.hosts[operation] : undefined; };
  const holding = (id: ModelId) => learnedHost(id) ?? hosts.find(host => host.resident().some(model => model.id === id));

  /** The host for `id`: one serving an operation the caller needs, else the one it resolved to before, else the catalog's word. */
  async function hostFor(id: ModelId, need: readonly ModelOperation[] = []): Promise<CompanionHost> {
    for (const operation of need) {
      const host = options.hosts[operation];
      if (host) { learned.set(id, operation); return host; }
    }
    const known = learnedHost(id);
    if (known) return known;
    const entry = await options.catalog.find(id);
    for (const operation of entry.operations) {
      const host = options.hosts[operation];
      if (host) { learned.set(id, operation); learned.set(entry.id, operation); return host; }
    }
    throw new ModelHostFailure("does-not-fit", `${entry.id} declares no companion operation (${entry.operations.join(", ") || "none"})`);
  }

  return {
    get policy(): ResidencyPolicy {
      const policies = hosts.map(host => host.policy);
      return { budgetBytes: Number.POSITIVE_INFINITY, pinned: [...new Set(policies.flatMap(policy => policy.pinned))],
        // Each model's own `stats(id).idleUnloadSec` is exact; across hosts the shortest is the one any companion may rely on.
        idleUnloadSec: policies.reduce((least, policy) => Math.min(least, policy.idleUnloadSec), Number.POSITIVE_INFINITY) };
    },
    async acquire(id: ModelId, acquire: AcquireOptions = {}): Promise<ModelLease> {
      return (await hostFor(id, acquire.need)).acquire(id, acquire);
    },
    async defaultFor(operation) {
      const id = await options.hosts[operation]?.defaultFor(operation);
      if (id !== undefined) learned.set(id, operation);
      return id;
    },
    async plan(id) { return (await hostFor(id)).plan(id); },
    async serve() { throw new ModelHostFailure("not-switchable", "companion models serve their own operations; there is no model to switch"); },
    async unload(id, unload) {
      // A model no host holds is not resident, which resolves.
      await holding(id)?.unload(id, unload);
    },
    // An id no host has resolved yet is pinned (or unpinned) wherever it may load; a host keeps the mark until it does.
    pin(id) { const host = learnedHost(id); for (const each of host ? [host] : hosts) each.pin(id); },
    unpin(id) { const host = learnedHost(id); for (const each of host ? [host] : hosts) each.unpin(id); },
    resident: (): readonly ResidentModel[] => hosts.flatMap(host => host.resident()),
    stats(id): ModelStats {
      const host = holding(id) ?? hosts.find(each => each.stats(id).loads > 0) ?? hosts[0];
      return host ? host.stats(id) : { resident: false, loads: 0, unloads: 0, lastLoadMs: 0, idleUnloadSec: null };
    },
    async close() {
      const errors: unknown[] = [];
      for (const host of hosts) { try { await host.close(); } catch (error) { errors.push(error); } }
      if (errors.length === 1) throw errors[0];
      if (errors.length) throw new AggregateError(errors, "companion hosts failed to close");
    },
  };
}
