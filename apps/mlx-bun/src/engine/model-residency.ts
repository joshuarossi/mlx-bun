// Residency by memory fit: the `ModelHost` contract (@mlx-bun/app-core) for
// models that generate. A model that fits the budget loads beside the others;
// otherwise the least recently used unpinned, unleased model is drained, has
// its state flushed durably, and is released before the newcomer loads, so
// resident bytes never exceed the budget during a swap. A request for a model
// that cannot fit while every other model is busy waits; it never evicts one
// mid-request. Nothing here loads weights or names a model family: a source
// resolves ids and loads units, and a unit says what it holds and how to close.
import type {
  AcquireOptions, CoreEvent, ModelHost, ModelHostError, ModelId, ModelLease, ModelOperation, ModelOperations, ModelRole, ModelStats,
  ResidencyFailure, ResidencyPlan, ResidencyPolicy, ResidentModel,
} from "@mlx-bun/app-core";
import type { DisposableResource } from "@mlx-bun/inference/contracts/portable";

export class ResidencyError extends Error implements ModelHostError {
  constructor(readonly code: ResidencyFailure, message: string, options?: { cause?: unknown }) {
    super(message, options);
    this.name = "ResidencyError";
  }
}

/** What closing a unit reported. */
export interface UnitClosed {
  /** Saved state reached durable storage before the weights were released. */
  readonly flushed: boolean;
  readonly drainMs?: number;
  readonly flushMs?: number;
}

/** One loaded model the host serves. The host owns its release. */
export interface ResidentUnit {
  readonly id: ModelId;
  readonly operations: readonly ModelOperation[];
  /** Saved state from an earlier run was found when it loaded, so a request can resume from it. */
  readonly resumed?: boolean;
  /** Bytes it holds now: weights plus the state it carries. */
  bytes(): number;
  memory(): { readonly weightsBytes: number; readonly kvBytes: number; readonly prefixCacheBytes: number };
  /** What a lease exposes; only what the model declared. */
  operationsFor(): Partial<ModelOperations>;
  /** Stop its execution until the resource is disposed (a job or a companion needs the GPU alone). */
  pause(signal?: AbortSignal): Promise<DisposableResource>;
  /** Stop admission, wait for work in flight, flush saved state durably, then release the weights. Once. */
  close(options: { readonly flush: boolean }): Promise<UnitClosed>;
}

/** A model the host may load, with what residency needs to know before it does. */
export interface ResidencyEntry {
  readonly id: ModelId;
  /** Bytes it needs resident (weights and working state), estimated before loading. */
  readonly bytes: number;
  readonly role?: ModelRole;
  readonly operations: readonly ModelOperation[];
}

export interface ResidencySource<U extends ResidentUnit> {
  /** Exact id only; never scans or downloads. */
  resolve(id: ModelId): Promise<ResidencyEntry | undefined>;
  load(entry: ResidencyEntry): Promise<U>;
}

export interface ResidencyOptions<U extends ResidentUnit> {
  source: ResidencySource<U>;
  /** Bytes all resident models may use together. */
  budgetBytes: number;
  /** Bytes the process actually holds (MLX active memory); residency never assumes less. */
  measured?: () => number;
  /** Bytes held by residents this host does not manage, such as a Whisper companion. */
  external?: () => number;
  pinned?: Iterable<ModelId>;
  /** The model a caller who names none is served with, per operation. */
  defaultFor?: (operation: ModelOperation) => Promise<ModelId | undefined>;
  events?: { publish(event: CoreEvent): void };
  log?: (line: string) => void;
  now?: () => number;
}

/** A lease that also hands the composition the unit itself, for routes bound to it. */
export interface ResidencyLease<U extends ResidentUnit> extends ModelLease { readonly unit: U }

export interface ResidencyHost<U extends ResidentUnit> extends ModelHost {
  acquire(id: ModelId, options?: AcquireOptions): Promise<ResidencyLease<U>>;
  /** Register a unit loaded elsewhere (the startup model, a caller's own context) as resident. `pin` keeps it from ever being evicted. */
  adopt(entry: ResidencyEntry, unit: U, options?: { readonly pin?: boolean; readonly loadMs?: number }): void;
  /** The resident unit, without leasing it: for read-only views (stats, discovery) that never load a model. */
  peek(id: ModelId): U | undefined;
  /** Free `bytes` by draining least recently used models, waiting while every candidate is busy; resolves once they fit. */
  makeRoom(bytes: number, signal?: AbortSignal): Promise<void>;
  /** Stop every resident execution until disposed, and hold back new loads meanwhile (a managed job, a companion's decode). */
  pauseAll(signal?: AbortSignal): Promise<DisposableResource>;
  /** Stop admission, wait for loads in flight, close every unit. The results are each closed unit's. Idempotent. */
  close(): Promise<readonly UnitClosed[]>;
}

/** What an eviction reports: the unit's own account, or the error its close failed with. */
type Evicted = UnitClosed & { readonly error?: unknown };

interface Slot<U extends ResidentUnit> {
  readonly id: ModelId;
  readonly entry: ResidencyEntry;
  unit: U | undefined;
  loading: Promise<U> | undefined;
  closing: Promise<Evicted> | undefined;
  leases: number;
  lastUsedAt: number;
  loads: number;
  unloads: number;
  lastLoadMs: number;
}

export function createResidencyHost<U extends ResidentUnit>(options: ResidencyOptions<U>): ResidencyHost<U> {
  const { source } = options, budget = options.budgetBytes;
  if (!(budget > 0)) throw new Error("the residency budget must be positive");
  const log = options.log ?? (() => {}), now = options.now ?? (() => performance.now());
  const measured = options.measured ?? (() => 0), external = options.external ?? (() => 0);
  const slots = new Map<ModelId, Slot<U>>();
  const pinned = new Set<ModelId>(options.pinned ?? []);
  const waiters = new Set<() => void>();
  let closed = false, closing: Promise<readonly UnitClosed[]> | undefined, paused = 0;
  const closedError = () => new ResidencyError("closed", "the model host is closed");
  const publish = (event: CoreEvent) => { try { options.events?.publish(event); } catch { /* a subscriber never slows a load */ } };
  const notify = () => { for (const wake of [...waiters]) wake(); };
  /** Wake on the next change (a release, a load, an unload, an unpause) or reject when the signal aborts. */
  const changed = (signal?: AbortSignal) => new Promise<void>((resolve, reject) => {
    const done = () => { waiters.delete(wake); signal?.removeEventListener("abort", abort); };
    const wake = () => { done(); resolve(); };
    const abort = () => { done(); reject(signal!.reason); };
    waiters.add(wake);
    if (signal?.aborted) abort(); else signal?.addEventListener("abort", abort, { once: true });
  });

  const held = (slot: Slot<U>) => slot.unit ? slot.unit.bytes() : slot.loading ? slot.entry.bytes : 0;
  /** Bytes in use by everyone but `except`: the estimates, floored by what the process measurably holds. */
  const used = (except?: Slot<U>) => {
    let sum = external();
    for (const slot of slots.values()) if (slot !== except) sum += held(slot);
    return Math.max(sum, measured() - (except ? held(except) : 0));
  };
  const busy = (slot: Slot<U>) => slot.leases > 0 || !!slot.loading || !!slot.closing;
  const evictable = (slot: Slot<U>) => !!slot.unit && !busy(slot) && !pinned.has(slot.id);

  /** Least recently used first, the fewest that make `bytes` fit. `busy` is what waiting could still free. */
  function decide(bytes: number, except?: Slot<U>): { fits: boolean; victims: Slot<U>[]; wait: boolean } {
    const base = used(except);
    if (base + bytes <= budget) return { fits: true, victims: [], wait: false };
    const candidates = [...slots.values()].filter(slot => slot !== except && evictable(slot)).sort((a, b) => a.lastUsedAt - b.lastUsedAt);
    const victims: Slot<U>[] = [];
    let freed = 0;
    for (const slot of candidates) {
      victims.push(slot); freed += held(slot);
      if (base - freed + bytes <= budget) return { fits: true, victims, wait: false };
    }
    // Even every candidate would not be enough. If busy models hold the rest, wait for one to finish rather
    // than evict for nothing; if only pinned models and this one remain, a lone model is always served.
    const others = [...slots.values()].some(slot => slot !== except && !pinned.has(slot.id) && !!(slot.unit || slot.loading) && busy(slot));
    return { fits: false, victims: candidates, wait: others };
  }

  /** Drain, flush and release one resident model; it is `closing` for the duration so nothing else touches it. */
  function evict(slot: Slot<U>, reason: "evicted" | "requested", quiet = false): Promise<Evicted> {
    if (slot.closing) return slot.closing;
    const unit = slot.unit!;
    const started = now();
    const weightsBytes = quiet ? 0 : unit.memory().weightsBytes;
    if (!quiet) log(`[models] ${slot.id} draining (${reason}); flushing saved state before release`);
    slot.closing = (async () => {
      let result: Evicted = { flushed: false };
      try { result = await unit.close({ flush: true }); }
      catch (error) {
        // The unit released what it could; whoever asked for the close decides what a failure means.
        result = { flushed: false, error };
        if (reason === "evicted") log(`[models] ${slot.id} closed with an error: ${error instanceof Error ? error.message : String(error)}`);
      }
      slot.unit = undefined;
      slot.unloads++;
      publish({ type: "model.unload", at: Date.now(), model: slot.id, reason, drainMs: result.drainMs ?? now() - started, flushed: result.flushed,
        ...(result.flushMs !== undefined ? { flushMs: result.flushMs } : {}) });
      publish({ type: "model.memory", at: Date.now(), model: slot.id, weightsBytes: 0, kvBytes: 0, prefixCacheBytes: 0 });
      if (!quiet) log(`[models] ${slot.id} released (${(weightsBytes / 2 ** 30).toFixed(2)} GiB weights${result.flushed ? ", state saved" : ", state NOT durable"})`);
      return result;
    })().finally(() => { slot.closing = undefined; notify(); });
    return slot.closing;
  }

  async function slotFor(id: ModelId, need: readonly ModelOperation[]): Promise<Slot<U>> {
    const known = slots.get(id);
    const entry = known?.entry ?? await source.resolve(id);
    if (!entry) throw new ResidencyError("does-not-fit", `${id} is not a local model this host can serve`);
    for (const operation of need)
      if (!entry.operations.includes(operation)) throw new ResidencyError("does-not-fit", `${id} does not declare the ${operation} operation`);
    let slot = slots.get(entry.id);
    if (!slot) {
      slot = { id: entry.id, entry, unit: undefined, loading: undefined, closing: undefined, leases: 0, lastUsedAt: 0, loads: 0, unloads: 0, lastLoadMs: 0 };
      slots.set(entry.id, slot);
    }
    return slot;
  }

  function startLoad(slot: Slot<U>): Promise<U> {
    const started = now();
    publish({ type: "model.load", at: Date.now(), model: slot.id, phase: "started" });
    return slot.loading = (async () => {
      let unit: U;
      try { unit = await source.load(slot.entry); }
      catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        publish({ type: "model.load", at: Date.now(), model: slot.id, phase: "failed", error: message });
        throw new ResidencyError("load-failed", message, { cause: error });
      }
      slot.lastLoadMs = now() - started;
      slot.loads++;
      const memory = unit.memory();
      publish({ type: "model.load", at: Date.now(), model: slot.id, phase: "finished", ms: slot.lastLoadMs, weightsBytes: memory.weightsBytes,
        ...(unit.resumed ? { resumed: true } : {}) });
      publish({ type: "model.memory", at: Date.now(), model: slot.id, ...memory });
      log(`[models] ${slot.id} loaded in ${slot.lastLoadMs.toFixed(0)} ms (${(unit.bytes() / 2 ** 30).toFixed(2)} GiB resident)`);
      if (closed) {
        // The host closed while this loaded: nothing may serve it.
        try { await unit.close({ flush: true }); } catch { /* released as far as it could be */ }
        throw closedError();
      }
      slot.unit = unit;
      return unit;
    })().finally(() => { slot.loading = undefined; notify(); });
  }

  const lease = (slot: Slot<U>, unit: U, loadMs: number): ResidencyLease<U> => {
    let released = false;
    return {
      unit, loadMs, operations: unit.operationsFor(),
      get model() { return describe(slot); },
      release() {
        if (released) return;
        released = true;
        slot.leases--;
        slot.lastUsedAt = now();
        notify();
      },
    };
  };
  const describe = (slot: Slot<U>): ResidentModel => ({ id: slot.id, role: slot.entry.role ?? "primary",
    state: slot.closing ? "draining" : slot.loading && !slot.unit ? "loading" : "ready", operations: slot.unit?.operations ?? slot.entry.operations,
    bytes: held(slot), pinned: pinned.has(slot.id), leases: slot.leases, lastUsedAt: slot.lastUsedAt });

  const host: ResidencyHost<U> = {
    get policy(): ResidencyPolicy { return { budgetBytes: budget, pinned: [...pinned], idleUnloadSec: Number.POSITIVE_INFINITY }; },

    async acquire(id, acquireOptions = {}) {
      const { signal } = acquireOptions, need = acquireOptions.need ?? [];
      const waited = now();
      for (;;) {
        signal?.throwIfAborted();
        if (closed) throw closedError();
        const slot = await slotFor(id, need);
        signal?.throwIfAborted();
        if (closed) throw closedError();
        if (slot.closing) { await slot.closing.catch(() => {}); continue; }
        // Reserve before anything suspends: a leased model is never evicted.
        const reserve = () => { slot.leases++; slot.lastUsedAt = now(); };
        if (slot.unit) { reserve(); return lease(slot, slot.unit, 0); }
        if (slot.loading) {
          reserve();
          try { return lease(slot, await slot.loading, now() - waited); }
          catch (error) { slot.leases--; notify(); throw error; }
        }
        // Not resident. A managed job or a companion's decode holds the GPU: no loads or evictions meanwhile.
        if (paused > 0) { await changed(signal); continue; }
        const plan = decide(slot.entry.bytes, slot);
        if (!plan.fits && plan.wait) { await changed(signal); continue; }
        if (plan.victims.length) {
          // The largest set the plan named, released before the newcomer loads. A settled eviction re-decides.
          await Promise.all(plan.victims.map(victim => evict(victim, "evicted")));
          continue;
        }
        reserve();
        try { return lease(slot, await startLoad(slot), now() - waited); }
        catch (error) { slot.leases--; notify(); throw error; }
      }
    },

    adopt(entry, unit, adoptOptions = {}) {
      if (closed) throw closedError();
      if (slots.get(entry.id)?.unit) throw new Error(`${entry.id} is already resident`);
      const slot = slots.get(entry.id) ?? { id: entry.id, entry, unit: undefined, loading: undefined, closing: undefined, leases: 0,
        lastUsedAt: 0, loads: 0, unloads: 0, lastLoadMs: 0 };
      slot.unit = unit; slot.loads++; slot.lastUsedAt = now();
      slots.set(entry.id, slot);
      if (adoptOptions.pin) pinned.add(entry.id);
      // The loader already loaded it: announce it as resident, with the time that took when the caller knows it.
      const memory = unit.memory();
      publish({ type: "model.load", at: Date.now(), model: slot.id, phase: "finished", ...(adoptOptions.loadMs !== undefined ? { ms: adoptOptions.loadMs } : {}),
        weightsBytes: memory.weightsBytes, ...(unit.resumed ? { resumed: true } : {}) });
    },
    peek: id => slots.get(id)?.unit,
    defaultFor: operation => options.defaultFor?.(operation) ?? Promise.resolve(undefined),

    async plan(id) {
      const slot = await slotFor(id, []);
      if (slot.unit || slot.loading) return { fits: true, requiredBytes: 0, freeBytes: Math.max(0, budget - used()), evict: [] } satisfies ResidencyPlan;
      const plan = decide(slot.entry.bytes, slot);
      return { fits: plan.fits, requiredBytes: slot.entry.bytes, freeBytes: Math.max(0, budget - used(slot)), evict: plan.victims.map(victim => victim.id) };
    },

    async unload(id, unloadOptions = {}) {
      const slot = slots.get(id);
      if (!slot) return;
      if (slot.closing) { await slot.closing; return; }
      if (slot.loading) await slot.loading.catch(() => {});
      if (!slot.unit) return;
      if (slot.leases > 0 && !unloadOptions.force) throw new ResidencyError("in-use", `${id} is in use`);
      const result = await evict(slot, "requested");
      if (result.error !== undefined) throw result.error;
    },

    async makeRoom(bytes, signal) {
      for (;;) {
        signal?.throwIfAborted();
        if (closed) throw closedError();
        if (paused > 0) { await changed(signal); continue; }
        const plan = decide(bytes);
        if (plan.fits && !plan.victims.length) return;
        if (!plan.fits && plan.wait) { await changed(signal); continue; }
        if (!plan.victims.length) return;
        await Promise.all(plan.victims.map(victim => evict(victim, "evicted")));
      }
    },

    async pauseAll(signal) {
      paused++;
      const held: DisposableResource[] = [];
      try {
        // A model that is draining is on its way out: wait for it, then pause the ones that stay.
        await Promise.all([...slots.values()].map(slot => slot.closing?.catch(() => {})));
        // A stable order, so two pausers never wait on each other.
        for (const slot of [...slots.values()].filter(slot => slot.unit && !slot.closing).sort((a, b) => a.id < b.id ? -1 : 1))
          held.push(await slot.unit!.pause(signal));
      } catch (error) {
        for (const resource of held.reverse()) resource.dispose();
        paused--; notify();
        throw error;
      }
      let released = false;
      return { dispose() {
        if (released) return;
        released = true;
        for (const resource of held.reverse()) resource.dispose();
        paused--; notify();
      } };
    },

    pin(id) { pinned.add(id); },
    unpin(id) { pinned.delete(id); notify(); },
    resident: () => [...slots.values()].filter(slot => slot.unit).map(describe),

    stats(id): ModelStats {
      const slot = slots.get(id);
      return { resident: !!slot?.unit, loads: slot?.loads ?? 0, unloads: slot?.unloads ?? 0, lastLoadMs: slot?.lastLoadMs ?? 0,
        idleUnloadSec: pinned.has(id) ? null : Number.POSITIVE_INFINITY };
    },

    close() {
      if (closing) return closing;
      closed = true;
      notify();
      return closing = (async () => {
        const results: UnitClosed[] = [];
        const errors: unknown[] = [];
        // Loads in flight finish (and close themselves, seeing `closed`); evictions in flight finish.
        for (const slot of slots.values()) await Promise.allSettled([slot.loading, slot.closing]);
        for (const slot of [...slots.values()]) {
          if (!slot.unit) continue;
          const result = await evict(slot, "requested", true);
          if (result.error !== undefined) errors.push(result.error); else results.push(result);
        }
        if (errors.length) throw new AggregateError(errors, "model host close failed");
        return results;
      })();
    },
  };
  return host;
}
