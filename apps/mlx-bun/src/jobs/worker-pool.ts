// The exact-id LRU model pool behind --model-pool (main's ModelPool): up to
// `cap` resident isolation workers, one supervisor (worker-supervisor.ts) on
// its own socket per exact `/v1/models` id. A request naming an exact id
// spawns that model's worker on first use while the resident ones keep
// serving (spawn-overlap); cold starts run one at a time; over the cap the
// least-recently-used worker is deregistered at once, then drained and
// stopped through its own close (the worker demotes its prompt cache there),
// and naming it again respawns it. Anything else — empty, an alias, a fuzzy
// or unknown id — rides the default worker, mlx-lm's ignored-field semantics.
// Managed jobs lease every resident worker; a worker that becomes ready while
// a job holds leases takes one before it is routable.
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
  /** Snapshot paths GC must keep: every resident or loading model. */
  servedPaths(): string[];
  /** A finished download or job: refresh every serving worker's library and forget resolution misses. */
  invalidateLibrary(): void;
  /** A managed job's lease over every resident worker, held until disposed and
   * extended to a worker that becomes ready meanwhile; a draining eviction finishes first. */
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
  const evicting = new Set<Promise<void>>();
  const resolutions = new Map<string, ModelRecord | null>();
  const holders = new Set<Holder>();
  let spawned = 0, closed = false;

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
      const done: Promise<void> = victim.engine.close()
        .catch(error => notice(`${victimId} did not stop cleanly: ${describe(error)}`))
        .finally(() => evicting.delete(done));
      evicting.add(done);
      work.push(done);
    }
    await Promise.all(work);
  };

  const start = (id: string, model: ModelRecord, initial = false): Promise<Entry> => {
    const settled = Promise.withResolvers<Entry>();
    loading.set(id, settled.promise);
    void settled.promise.catch(() => {});
    serialize(async () => {
      let entry: Entry | undefined;
      try {
        if (closed) throw new EngineUnavailableError("closed", null);
        const socketPath = options.socketFor(spawned++);
        if (!initial) notice(`loading ${id} on a new worker (socket ${socketPath})`);
        entry = { id, model, engine: options.supervise(model, socketPath), socketPath };
        loadingEntries.set(id, entry);
        await entry.engine.ready;
        if (closed) throw new EngineUnavailableError("closed", null);
        // A job in progress owns the GPU: the new worker leases before it routes.
        await Promise.allSettled([...holders].map(holder => holder.cover(entry!)));
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
    signal.throwIfAborted();
    // A worker being evicted may still be finishing a generation: it stops first.
    while (evicting.size) await Promise.allSettled([...evicting]);
    signal.throwIfAborted();
    const holder: Holder = { disposed: false, leases: new Map(), cover(entry) {
      if (holder.disposed || holder.leases.has(entry)) return Promise.resolve();
      const lease = entry.engine.acquireExecutionLease(signal);
      holder.leases.set(entry, lease);
      return lease.then(value => { if (holder.disposed) value.dispose(); }, error => { holder.leases.delete(entry); throw error; });
    } };
    holders.add(holder);
    const dispose = () => {
      if (holder.disposed) return;
      holder.disposed = true;
      holders.delete(holder);
      for (const lease of holder.leases.values()) lease.then(value => value.dispose(), () => {});
    };
    try { await Promise.all([...resident.values()].map(entry => holder.cover(entry))); }
    catch (error) { dispose(); throw error; }
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
    const entries = [...resident.values(), ...loadingEntries.values()];
    resident.clear();
    lru = [];
    await Promise.allSettled([...entries.map(entry => entry.engine.close()), ...evicting, ...loading.values()]);
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
    servedPaths: () => [...new Set([...resident.values(), ...loadingEntries.values()].map(entry => entry.model.path))],
    invalidateLibrary, acquireExecutionLease, report, close,
  };
}
