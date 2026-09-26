// The exact-id LRU model pool behind --model-pool (main's ModelPool): up to
// `cap` resident isolation workers, one supervisor (worker-supervisor.ts) on
// its own socket per exact `/v1/models` id. A request naming an exact id
// spawns that model's worker on first use while the resident ones keep
// serving (spawn-overlap); cold starts run one at a time; over the cap the
// least-recently-used worker is deregistered at once, then drained and
// stopped through its own close (the worker demotes its prompt cache there),
// and naming it again respawns it. Anything else — empty, an alias, a fuzzy
// or unknown id — rides the default worker, mlx-lm's ignored-field semantics.
// Managed jobs wait for an active load/eviction, then lease every resident
// worker. Cold starts wait until those leases have been released.
import type { DisposableResource } from "@mlx-bun/inference/contracts/portable";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import { EngineUnavailableError, type WorkerSupervisor, type WorkerSupervisorState } from "./worker-supervisor";

export interface WorkerPoolOptions {
  /** Resident worker cap; the CLI validates it as an integer >= 1. */
  cap: number;
  /** The model the parent resolved at startup; its id is the default key. */
  defaultModel: ModelRecord;
  /** Exact-id resolution through the registry, never a download; null for anything inexact. */
  resolve(id: string): ModelRecord | null;
  /** Ids that mean the default worker (Pi's `local`). */
  aliases?: readonly string[];
  /** One supervisor per worker, on the socket the pool assigns. */
  supervise(model: ModelRecord, socketPath: string): WorkerSupervisor;
  /** The socket path for the n-th worker this pool spawns (0 is the default worker's first). */
  socketFor(index: number): string;
  /** Pool notices (switches, evictions, failed loads); default `console.error`. */
  notice?(line: string): void;
}

export interface ResidentWorker { readonly id: string; readonly model: ModelRecord; readonly engine: WorkerSupervisor }

export interface PoolReport {
  cap: number;
  default: string;
  /** Least recently used first. */
  resident: { id: string; pid: number | null; state: WorkerSupervisorState; restarts: number; socket: string }[];
  loading: string[];
}

export interface WorkerPool {
  readonly cap: number;
  readonly defaultId: string;
  /** The default worker while resident or loading; undefined once evicted. Never spawns. */
  readonly default: WorkerSupervisor | undefined;
  /** The first default worker's readiness; a failed first load rejects and is never retried. */
  readonly ready: Promise<WorkerSupervisor>;
  /** A resident or loading worker by exact id, for inspection; never spawns. */
  worker(id: string): WorkerSupervisor | undefined;
  /** Resident workers, least recently used first. */
  residents(): ResidentWorker[];
  /** Where inspection and discovery go without loading a model: the default
   * worker while resident or loading, else the most recently used resident. */
  inspect(): WorkerSupervisor | undefined;
  /** Route a request's `model` field: an exact id's worker, spawned on first
   * use; anything else the default worker, respawned when it was evicted. The
   * signal abandons the wait, not the load. */
  workerFor(modelField: string | null | undefined, signal?: AbortSignal): Promise<WorkerSupervisor>;
  /** Snapshot paths GC must keep: every resident, queued/loading, or draining model. */
  servedPaths(): string[];
  /** A finished download or job: refresh every serving worker's library and forget resolution misses. */
  invalidateLibrary(): void;
  /** Wait for active loads and draining evictions, then lease every resident
   * worker. New cold starts wait until all acquired leases are disposed. */
  acquireExecutionLease(signal: AbortSignal): Promise<DisposableResource>;
  report(): PoolReport;
  /** Stop every worker (resident, loading, evicting) and join. Idempotent. */
  close(): Promise<void>;
}

interface Entry { id: string; model: ModelRecord; engine: WorkerSupervisor; socketPath: string }
interface Holder { disposed: boolean; leases: Map<Entry, Promise<DisposableResource>>; cover(entry: Entry): Promise<void> }

const describe = (error: unknown) => error instanceof Error ? error.message : String(error);

export function createWorkerPool(options: WorkerPoolOptions): WorkerPool {
  const cap = Math.max(1, Math.floor(options.cap));
  const defaultId = options.defaultModel.repoId;
  const aliases = new Set(options.aliases ?? []);
  const notice = options.notice ?? (line => console.error(`[isolate] ${line}`));
  const resident = new Map<string, Entry>();
  let lru: string[] = []; // least recently used first
  const loading = new Map<string, Promise<Entry>>();
  const loadingEntries = new Map<string, Entry>();
  const loadingModels = new Map<string, { model: ModelRecord; promise: Promise<Entry> }>();
  const evicting = new Set<Promise<void>>();
  const draining = new Set<Entry>();
  const resolutions = new Map<string, ModelRecord | null>();
  const holders = new Set<Holder>();
  let spawned = 0, closed = false;
  const shutdown = new AbortController();
  let jobsReleased = Promise.withResolvers<void>();
  let activeStart: Promise<void> | undefined;

  // Cold starts run one at a time. The slot is held through the eviction a
  // start causes, so the next load begins after the evicted worker has stopped.
  let busy = false;
  const queue: (() => void)[] = [];
  const serialize = (work: () => Promise<void>) => {
    const run = () => { busy = true; void work().finally(() => { busy = false; queue.shift()?.(); }); };
    if (busy) queue.push(run); else run();
  };
  const bump = (id: string) => { lru = lru.filter(key => key !== id); lru.push(id); };
  const keyFor = (field: string | null | undefined) => !field || aliases.has(field) ? defaultId : field;
  const settle = <T>(promise: Promise<T>, signal?: AbortSignal) => new Promise<T>((resolve, reject) => {
    if (signal?.aborted) return reject(signal.reason);
    const abort = () => reject(signal!.reason);
    signal?.addEventListener("abort", abort, { once: true });
    promise.then(resolve, reject).finally(() => signal?.removeEventListener("abort", abort));
  });

  const evictOverCap = async () => {
    const work: Promise<void>[] = [];
    while (resident.size > cap) {
      const victimId = lru.find(id => resident.has(id));
      if (victimId === undefined) break;
      const victim = resident.get(victimId)!;
      resident.delete(victimId);
      lru = lru.filter(id => id !== victimId);
      notice(`evicting ${victimId} (pool cap ${cap}): draining, then stopping`);
      // The supervisor's close is the drain-then-stop path; the worker's own
      // close demotes its prompt cache before the process exits.
      draining.add(victim);
      const done: Promise<void> = victim.engine.close()
        .catch(error => notice(`${victimId} did not stop cleanly: ${describe(error)}`))
        .finally(() => { evicting.delete(done); draining.delete(victim); });
      evicting.add(done);
      work.push(done);
    }
    await Promise.all(work);
  };

  const start = (id: string, model: ModelRecord, initial = false): Promise<Entry> => {
    const settled = Promise.withResolvers<Entry>();
    loading.set(id, settled.promise);
    loadingModels.set(id, { model, promise: settled.promise });
    void settled.promise.catch(() => {});
    serialize(async () => {
      let entry: Entry | undefined;
      let finished: ReturnType<typeof Promise.withResolvers<void>> | undefined;
      try {
        // Register a load only after jobs release. A job arriving during a load
        // waits for this load (including eviction), never for queued cold starts.
        while (holders.size) await settle(jobsReleased.promise, shutdown.signal);
        if (closed) throw new EngineUnavailableError("closed", null);
        finished = Promise.withResolvers<void>();
        activeStart = finished.promise;
        const socketPath = options.socketFor(spawned++);
        if (!initial) notice(`loading ${id} on a new worker (socket ${socketPath})`);
        entry = { id, model, engine: options.supervise(model, socketPath), socketPath };
        loadingEntries.set(id, entry);
        await entry.engine.ready;
        if (closed) throw new EngineUnavailableError("closed", null);
        resident.set(id, entry);
        bump(id);
        loading.delete(id);
        loadingEntries.delete(id);
        if (!initial) notice(`engine worker pid ${entry.engine.pid} ready for ${id} (socket ${socketPath})`);
        const eviction = evictOverCap();
        settled.resolve(entry);
        await eviction;
      } catch (error) {
        loading.delete(id);
        loadingEntries.delete(id);
        if (!initial) notice(`${id} did not load: ${describe(error)}`);
        settled.reject(error);
        if (entry) await entry.engine.close().catch(() => {});
      } finally {
        loadingEntries.delete(id);
        if (loadingModels.get(id)?.promise === settled.promise) loadingModels.delete(id);
        if (finished) { activeStart = undefined; finished.resolve(); }
      }
    });
    return settled.promise;
  };

  const resolveExact = (id: string): ModelRecord | null => {
    if (id === defaultId) return options.defaultModel;
    const cached = resolutions.get(id);
    if (cached !== undefined) return cached;
    let record: ModelRecord | null;
    try { record = options.resolve(id); } catch { record = null; }
    if (record && record.repoId !== id) record = null;
    resolutions.set(id, record);
    return record;
  };

  const workerFor = async (field: string | null | undefined, signal?: AbortSignal): Promise<WorkerSupervisor> => {
    if (closed) throw new EngineUnavailableError("closed", null);
    const key = keyFor(field);
    const current = resident.get(key);
    if (current) { bump(key); return current.engine; }
    const pending = loading.get(key);
    if (pending) {
      const entry = await settle(pending, signal);
      if (resident.has(key)) bump(key);
      return entry.engine;
    }
    const model = resolveExact(key);
    if (!model) return workerFor(undefined, signal);
    const entry = await settle(start(key, model), signal);
    if (resident.has(key)) bump(key);
    return entry.engine;
  };

  const acquireExecutionLease = async (signal: AbortSignal): Promise<DisposableResource> => {
    signal = AbortSignal.any([signal, shutdown.signal]);
    signal.throwIfAborted();
    const holder: Holder = { disposed: false, leases: new Map(), cover(entry) {
      if (holder.disposed || holder.leases.has(entry)) return Promise.resolve();
      const lease = entry.engine.acquireExecutionLease(signal);
      holder.leases.set(entry, lease);
      return lease.then(() => {}, error => { holder.leases.delete(entry); throw error; });
    } };
    // Admission is synchronous: no new load can slip between draining the
    // existing work and acquiring worker leases.
    if (!holders.size) jobsReleased = Promise.withResolvers<void>();
    holders.add(holder);
    const dispose = () => {
      if (holder.disposed) return;
      holder.disposed = true;
      holders.delete(holder);
      for (const lease of holder.leases.values()) lease.then(value => value.dispose(), () => {});
      if (!holders.size) jobsReleased.resolve();
    };
    try {
      if (activeStart) await settle(activeStart, signal);
      if (evicting.size) await settle(Promise.allSettled([...evicting]), signal);
      signal.throwIfAborted();
      // Stable order prevents concurrent jobs from holding different workers
      // while each waits for the other (the worker lease is exclusive).
      for (const entry of [...resident.values()].sort((a, b) => a.id.localeCompare(b.id))) {
        await settle(holder.cover(entry), signal);
      }
      signal.throwIfAborted();
    } catch (error) { dispose(); throw error; }
    return { dispose };
  };

  const invalidateLibrary = () => {
    resolutions.clear();
    for (const { engine } of resident.values()) {
      if (engine.state !== "ready") continue;
      void engine.fetch("http://engine/library?refresh=1").then(response => response.arrayBuffer()).catch(() => {});
    }
  };

  const report = (): PoolReport => ({
    cap, default: defaultId,
    resident: lru.filter(id => resident.has(id)).map(id => {
      const { engine, socketPath } = resident.get(id)!;
      return { id, pid: engine.pid, state: engine.state, restarts: engine.restarts, socket: socketPath };
    }),
    loading: [...loading.keys()],
  });

  const ready = start(defaultId, options.defaultModel, true).then(entry => entry.engine);
  void ready.catch(() => {});

  let closing: Promise<void> | undefined;
  const close = () => closing ??= (async () => {
    closed = true;
    shutdown.abort(new EngineUnavailableError("closed", null));
    const entries = [...resident.values(), ...loadingEntries.values()];
    resident.clear();
    lru = [];
    await Promise.allSettled([...entries.map(entry => entry.engine.close()), ...evicting, ...loading.values(), ...(activeStart ? [activeStart] : [])]);
    // A start still queued behind the slot rejects itself on its turn.
    while (loading.size) await Promise.allSettled([...loading.values()]);
  })();

  return {
    cap, defaultId, ready,
    get default() { return (resident.get(defaultId) ?? loadingEntries.get(defaultId))?.engine; },
    worker: id => (resident.get(id) ?? loadingEntries.get(id))?.engine,
    residents: () => lru.filter(id => resident.has(id)).map(id => { const { model, engine } = resident.get(id)!; return { id, model, engine }; }),
    inspect() {
      const recent = lru.findLast(id => resident.has(id));
      return resident.get(defaultId)?.engine ?? loadingEntries.get(defaultId)?.engine ?? (recent === undefined ? undefined : resident.get(recent)!.engine);
    },
    workerFor,
    servedPaths: () => [...new Set([...resident.values(), ...draining].map(entry => entry.model.path).concat([...loadingModels.values()].map(({ model }) => model.path)))],
    invalidateLibrary, acquireExecutionLease, report, close,
  };
}
