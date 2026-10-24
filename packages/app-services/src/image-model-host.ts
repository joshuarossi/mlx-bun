// The model host for a text-to-image companion. Residency follows the Whisper
// host's (whisper-model-host.ts): a pipeline opens on the first lease and is
// released right after the last one by default (`idleUnloadSec` > 0 keeps it for
// that long; a pinned model stays). Opening reads configs only; each stage loads
// its weights during a run. The memory budget is the app's generation host's:
// this host reserves its pending and resident bytes through the composition
// before the first stage of an opened pipeline can load.
//
// The host settles stage residency once per opened pipeline by the stage rule
// its composer gives it (image-stages.ts; default the budget rule over a share
// of physical memory): either every run releases each stage once its output is
// evaluated (one stage resident at a time), or the stages stay open between
// runs until the pipeline is released. Runs reach a pipeline one at a time, and
// every run goes through the host's `exclusive` wrapper, so a host that also
// generates never overlaps it on the GPU.
import type {
  AcquireOptions, CatalogEntry, EventBus, ImageOperation, ModelCatalog, ModelHost, ModelId, ModelLease, ModelOperation, ModelStats, ModelUnloadReason,
  ResidencyPlan, ResidencyPolicy, ResidentModel, ReserveModel, ResidencyReservation,
} from "@mlx-bun/app-core";
import { ModelHostFailure } from "./failure";
import { nativeImageBackend, type ImageBackend, type LoadedImagePipeline } from "./image-backend";
import { defaultStageBudgetBytes, stageBudgetRule, type StageRule } from "./image-stages";
import type { Exclusive } from "./whisper-model-host";

export interface ImageModelHostOptions {
  /** Resolves ids and paths to snapshot directories, and lists what is local. */
  catalog: Pick<ModelCatalog, "list" | "find">;
  /** A checkpoint served under this id from this directory, and the default for `image`. */
  configured?: { readonly id: ModelId; readonly directory: string };
  /** Seconds a pipeline stays open after its last lease. Default 0: released right after every run. */
  idleUnloadSec?: number;
  /** Start with the configured model pinned. */
  resident?: boolean;
  /** Decides, from an opened pipeline's stage bytes, whether each run releases every stage after its output and what a run holds.
   * Default the budget rule over `DEFAULT_STAGE_BUDGET_FRACTION` of physical memory. */
  stages?: StageRule;
  /** Wraps every run (the full server passes the generation gateway's exclusive lock). */
  exclusive?: Exclusive;
  /** Owns the pending and resident charge, and can reclaim an idle pipeline. A host sharing a memory budget supplies this. */
  reserve?: ReserveModel;
  /** Real weights by default. */
  backend?: ImageBackend;
  log?: (line: string) => void;
  /** Idle-unload scheduling; tests supply a fake clock. */
  timers?: { setTimeout(fn: () => void, ms: number): unknown; clearTimeout(handle: unknown): void };
  /** Monotonic milliseconds for the reported load times. */
  now?: () => number;
  /** Receives `model.load`, `model.unload` and `model.memory` events; publishing never waits for a subscriber. */
  events?: Pick<EventBus, "publish">;
}

const realTimers: NonNullable<ImageModelHostOptions["timers"]> = {
  setTimeout(fn, ms) { const handle = setTimeout(fn, ms); handle.unref?.(); return handle; },
  clearTimeout(handle) { clearTimeout(handle as ReturnType<typeof setTimeout>); },
};

/** An opened pipeline with the residency this host chose for it. */
interface Opened {
  readonly pipeline: LoadedImagePipeline;
  /** Release each stage after its output: the stages together exceed the budget. */
  readonly releaseStages: boolean;
  /** What a run holds at once: the largest stage when stages are released, else all of them. */
  readonly bytes: number;
  /** Settles when the last run admitted to this pipeline has finished. */
  tail: Promise<void>;
}

/** Settles with `previous`, or rejects with the signal's reason once it aborts first. */
function waitTurn<T>(previous: Promise<T>, signal: AbortSignal | undefined): Promise<T> {
  if (!signal) return previous;
  if (signal.aborted) { void previous.catch(() => {}); return Promise.reject(signal.reason); }
  return new Promise((resolve, reject) => {
    const abort = () => reject(signal.reason);
    signal.addEventListener("abort", abort, { once: true });
    void previous.then(value => { signal.removeEventListener("abort", abort); resolve(value); },
      error => { signal.removeEventListener("abort", abort); reject(error); });
  });
}

interface Slot {
  readonly id: ModelId;
  readonly directory: string;
  /** The operations its catalog entry declares (always `image`). */
  readonly operations: readonly ModelOperation[];
  /** The catalog's size until the pipeline opens, then what a run holds at once. */
  bytes: number;
  opened: Opened | null;
  loading: Promise<Opened> | null;
  loadingAbort: AbortController | null;
  reservation: ResidencyReservation | undefined;
  leases: number;
  timer: unknown;
  loads: number;
  unloads: number;
  lastLoadMs: number;
  lastUsedAt: number;
}

/** Runs reach a pipeline one at a time, in order: its open stages are one run's state (a release mid-run would free a
 * stage another run reads). A queued run waits for its turn before it asks for the execution lock, so it holds nothing
 * while it waits, and an abort while queued rejects it without running. */
function imageOperation(opened: Opened, exclusive: Exclusive): ImageOperation {
  const { pipeline, releaseStages } = opened;
  return {
    defaults: pipeline.defaults,
    pixelsPerLatent: pipeline.pixelsPerLatent,
    async generate(request, options) {
      const signal = options?.signal, previous = opened.tail;
      let finished!: () => void;
      opened.tail = new Promise(resolve => { finished = resolve; });
      try {
        await waitTurn(previous, signal);
        return await exclusive(async () => {
          signal?.throwIfAborted();
          return await pipeline.generate(request, { releaseStages, ...(signal ? { signal } : {}), ...(options?.onProgress ? { onProgress: options.onProgress } : {}) });
        }, signal);
      } finally {
        // The next run starts once this one and every run before it are done, even when this one gave up waiting.
        void previous.then(finished);
      }
    },
  };
}

/** `ModelHost` for text-to-image pipelines, plus what the composing host needs beyond the contract: `preload` and `close`. */
export interface ImageModelHost extends ModelHost {
  /** Open a pipeline now without leasing it; it then follows the idle policy from its next lease. */
  preload(id?: ModelId): Promise<void>;
  /** Stop admission, cancel idle timers, wait for opens in flight and release every pipeline. Idempotent. */
  close(): Promise<void>;
}

export function createImageModelHost(options: ImageModelHostOptions): ImageModelHost {
  const catalog = options.catalog, backend = options.backend ?? nativeImageBackend, exclusive: Exclusive = options.exclusive ?? (fn => fn());
  const log = options.log ?? (line => console.log(line)), timers = options.timers ?? realTimers, now = options.now ?? (() => performance.now());
  const idleUnloadSec = Math.max(0, options.idleUnloadSec ?? 0);
  const stages = options.stages ?? stageBudgetRule(defaultStageBudgetBytes());
  const slots = new Map<ModelId, Slot>();
  /** What the catalog listed when the default was resolved, so leasing it does not look it up again. */
  const listed = new Map<ModelId, CatalogEntry>();
  let closed = false, closing: Promise<void> | null = null, defaultImage: Promise<ModelId | undefined> | undefined;
  const pinnedIds = new Set<ModelId>(options.resident && options.configured ? [options.configured.id] : []);
  const closedError = () => new ModelHostFailure("closed", "image service is closed");

  const publish = (event: Parameters<EventBus["publish"]>[0]) => { try { options.events?.publish(event); } catch { /* the bus contract is never to throw; a stand-in must not break a run */ } };
  const cancelTimer = (slot: Slot) => {
    if (slot.timer !== null) timers.clearTimeout(slot.timer);
    slot.timer = null;
  };
  /** Release the pipeline; a release at close is not an unload. */
  const dispose = (slot: Slot, reason: ModelUnloadReason | null = "idle") => {
    cancelTimer(slot);
    if (!slot.opened) return false;
    const started = now();
    slot.opened.pipeline.dispose();
    slot.opened = null;
    slot.reservation?.release();
    slot.reservation = undefined;
    if (reason) {
      slot.unloads++;
      publish({ type: "model.unload", at: Date.now(), model: slot.id, reason, drainMs: now() - started, flushed: false });
    }
    return true;
  };
  const isPinned = (id: ModelId) => pinnedIds.has(id);
  const armIdle = (slot: Slot, keepAliveSec: number | undefined) => {
    cancelTimer(slot);
    if (isPinned(slot.id) || closed) return;
    const seconds = Math.max(0, keepAliveSec ?? idleUnloadSec);
    if (seconds <= 0) { if (slot.leases === 0 && dispose(slot)) log(`[image] ${slot.id} unloaded (idle)`); return; }
    slot.timer = timers.setTimeout(() => { slot.timer = null; if (slot.leases === 0 && dispose(slot)) log(`[image] ${slot.id} unloaded (idle)`); }, seconds * 1000);
  };

  /** The slot for `id`, refusing an operation its model does not declare on every acquisition, a known slot included. */
  async function slotFor(id: ModelId, need: readonly ModelOperation[]): Promise<Slot> {
    const slot = slots.get(id) ?? await newSlot(id);
    for (const operation of need)
      if (!slot.operations.includes(operation)) throw new ModelHostFailure("does-not-fit", `${slot.id} does not declare the ${operation} operation`);
    return slot;
  }

  async function newSlot(id: ModelId): Promise<Slot> {
    const entry = options.configured?.id === id
      ? { id, directory: options.configured.directory, bytes: 0, operations: ["image"] as readonly ModelOperation[] }
      : listed.get(id) ?? await catalog.find(id);
    if (!entry.operations.includes("image")) throw new ModelHostFailure("does-not-fit", `${entry.id} does not declare the image operation`);
    const known = slots.get(entry.id);
    if (known) return known;
    const slot: Slot = { id: entry.id, directory: entry.directory, operations: entry.operations, bytes: entry.bytes, opened: null, loading: null,
      loadingAbort: null, reservation: undefined, leases: 0, timer: null,
      loads: 0, unloads: 0, lastLoadMs: 0, lastUsedAt: 0 };
    slots.set(entry.id, slot);
    if (id !== entry.id) slots.set(id, slot);
    return slot;
  }

  /** Open (or reuse); returns the milliseconds this call waited for the pipeline. */
  async function ensureOpened(slot: Slot): Promise<{ loadMs: number; opened: Opened }> {
    if (closed) throw closedError();
    if (slot.opened) return { loadMs: 0, opened: slot.opened };
    const waitStart = now();
    if (!slot.loading) {
      const loadingAbort = slot.loadingAbort = new AbortController();
      slot.loading = (async () => {
        const t0 = now();
        let opened: Opened;
        publish({ type: "model.load", at: Date.now(), model: slot.id, phase: "started" });
        try {
          const pipeline = await backend.load(slot.directory);
          try {
            opened = { pipeline, ...stages(Object.values(pipeline.stageBytes)), tail: Promise.resolve() };
            slot.bytes = opened.bytes;
            loadingAbort.signal.throwIfAborted();
            // Publish the owned charge before any stage loads weights. The owner
            // exposes its leases and pin state to the shared residency policy.
            if (options.reserve) slot.reservation = await options.reserve({ model: () => resident(slot), unload: () => host.unload(slot.id) }, loadingAbort.signal);
            loadingAbort.signal.throwIfAborted();
          } catch (error) { pipeline.dispose(); slot.reservation?.release(); slot.reservation = undefined; throw error; }
        } catch (error) {
          const message = error instanceof Error ? error.message : String(error);
          publish({ type: "model.load", at: Date.now(), model: slot.id, phase: "failed", error: message });
          throw new ModelHostFailure("load-failed", message, { cause: error });
        }
        if (closed) { opened.pipeline.dispose(); slot.reservation?.release(); slot.reservation = undefined; throw closedError(); }
        slot.opened = opened;
        slot.bytes = opened.bytes;
        slot.loads++;
        slot.lastLoadMs = now() - t0;
        log(`[image] ${slot.id} opened in ${slot.lastLoadMs.toFixed(0)} ms (${opened.releaseStages ? "one stage resident at a time" : "stages kept open"})`);
        publish({ type: "model.load", at: Date.now(), model: slot.id, phase: "finished", ms: slot.lastLoadMs, weightsBytes: slot.bytes });
        publish({ type: "model.memory", at: Date.now(), model: slot.id, weightsBytes: slot.bytes, kvBytes: 0, prefixCacheBytes: 0 });
        return opened;
      })().finally(() => { slot.loading = null; slot.loadingAbort = null; slot.reservation?.changed(); });
    }
    const opened = await slot.loading;
    return { loadMs: now() - waitStart, opened };
  }

  const resident = (slot: Slot): ResidentModel => ({ id: slot.id, role: "companion", state: slot.loading && !slot.opened ? "loading" : "ready",
    operations: ["image"], bytes: slot.bytes, pinned: isPinned(slot.id), leases: slot.leases, lastUsedAt: slot.lastUsedAt, uses: [slot.directory] });

  const host: ImageModelHost = {
    get policy(): ResidencyPolicy { return { budgetBytes: Number.POSITIVE_INFINITY, pinned: [...pinnedIds], idleUnloadSec }; },

    async acquire(id: ModelId, acquireOptions: AcquireOptions = {}): Promise<ModelLease> {
      if (closed) throw closedError();
      const slot = await slotFor(id, acquireOptions.need ?? []);
      acquireOptions.signal?.throwIfAborted();
      // Reserve before suspending again: an idle timer and unload refuse while a lease is held.
      cancelTimer(slot);
      slot.leases++;
      let opened: Opened, loadMs: number;
      try {
        ({ opened, loadMs } = await waitTurn(ensureOpened(slot), acquireOptions.signal));
        acquireOptions.signal?.throwIfAborted();
      } catch (error) {
        slot.leases--;
        if (!slot.leases) slot.loadingAbort?.abort(error);
        slot.reservation?.changed();
        armIdle(slot, acquireOptions.keepAliveSec);
        throw error;
      }
      slot.lastUsedAt = now();
      let released = false;
      return {
        model: resident(slot), loadMs, operations: { image: imageOperation(opened, exclusive) },
        release() {
          if (released) return;
          released = true;
          slot.leases--;
          slot.lastUsedAt = now();
          slot.reservation?.changed();
          armIdle(slot, acquireOptions.keepAliveSec);
        },
      };
    },

    /** Resolved once, like the Whisper host's: a checkpoint downloaded later needs a restart. */
    defaultFor(operation) {
      if (operation !== "image") return Promise.resolve(undefined);
      return defaultImage ??= options.configured ? Promise.resolve(options.configured.id)
        : catalog.list({ kind: "model" }).then(entries => {
          for (const entry of entries) listed.set(entry.id, entry);
          return entries.find(entry => entry.operations.includes(operation))?.id;
        }, () => undefined);
    },

    async plan(id) {
      const slot = await slotFor(id, []);
      return { fits: true, requiredBytes: slot.bytes, freeBytes: Number.POSITIVE_INFINITY, evict: [] } satisfies ResidencyPlan;
    },

    async serve() { throw new ModelHostFailure("not-switchable", "the image host generates images only; it has no model to switch"); },

    async unload(id, unloadOptions = {}) {
      const slot = slots.get(id);
      if (!slot) return;
      cancelTimer(slot);
      if (!slot.opened) return;
      if (slot.leases > 0 && !unloadOptions.force) throw new ModelHostFailure("in-use", `${slot.id} is in use`);
      if (dispose(slot, "requested")) log(`[image] ${slot.id} unloaded`);
    },

    pin(id) { pinnedIds.add(id); const slot = slots.get(id); if (slot) { cancelTimer(slot); slot.reservation?.changed(); } },
    unpin(id) { pinnedIds.delete(id); slots.get(id)?.reservation?.changed(); },
    resident: () => [...new Set(slots.values())].filter(slot => slot.opened).map(resident),

    stats(id): ModelStats {
      const slot = slots.get(id);
      return { resident: !!slot?.opened, loads: slot?.loads ?? 0, unloads: slot?.unloads ?? 0, lastLoadMs: slot?.lastLoadMs ?? 0,
        idleUnloadSec: isPinned(id) ? null : idleUnloadSec };
    },

    async preload(id) {
      const target = id ?? await host.defaultFor("image");
      if (!target) throw new ModelHostFailure("does-not-fit", "no text-to-image model is available");
      await ensureOpened(await slotFor(target, []));
    },

    close() {
      if (closing) return closing;
      closed = true;
      const all = [...new Set(slots.values())];
      for (const slot of all) slot.loadingAbort?.abort(closedError());
      const release = () => { for (const slot of all) dispose(slot, null); };
      const loading = all.flatMap(slot => slot.loading ? [slot.loading.catch(() => undefined)] : []);
      if (!loading.length) { release(); return closing = Promise.resolve(); }
      return closing = Promise.all(loading).then(release);
    },
  };
  return host;
}
