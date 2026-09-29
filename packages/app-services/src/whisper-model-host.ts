// The model host for a Whisper companion. Residency: a checkpoint loads on the
// first lease and is released right after the last one by default
// (`idleUnloadSec` > 0 keeps it for that long; a pinned model stays). Weights
// are mmap'd safetensors, so a reload after unload reads from the OS page
// cache; the GPU memory is what an idle host gives back. There is no memory
// budget here: only Whisper loads through this host, and residency by memory
// fit arrives with the general model host.
//
// Every decode call (a one-shot transcription, or each feed and finish of a
// streaming run) goes through the host's `exclusive` wrapper, so a host that
// also generates keeps decoding from overlapping it on the GPU.
import type {
  AcquireOptions, CatalogEntry, EventBus, ModelUnloadReason, ModelCatalog, ModelHost, ModelId, ModelLease, ModelOperation, ModelStats,
  ResidencyPlan, ResidencyPolicy, ResidentModel, TranscribeOptions, TranscriptionOperation,
} from "@mlx-bun/app-core";
import type { WhisperTranscribeOptions } from "@mlx-bun/inference/transcription";
import { ModelHostFailure } from "./failure";
import { nativeWhisperBackend, type LoadedWhisper, type WhisperBackend } from "./whisper-backend";

export type Exclusive = <T>(fn: () => Promise<T>, signal?: AbortSignal) => Promise<T>;

export interface WhisperModelHostOptions {
  /** Resolves ids and paths to checkpoint directories, and lists what is local. */
  catalog: Pick<ModelCatalog, "list" | "find">;
  /** The `--whisper-model` checkpoint: served under this id from this directory, and the default for `transcribe`. */
  configured?: { readonly id: ModelId; readonly directory: string };
  /** Seconds a model stays loaded after its last lease. Default 0: released right after every take. */
  idleUnloadSec?: number;
  /** Start with the configured model pinned (`--whisper-resident`). */
  resident?: boolean;
  /** Wraps every decode call (the full server passes the generation gateway's exclusive lock). */
  exclusive?: Exclusive;
  /** Real weights by default. */
  backend?: WhisperBackend;
  log?: (line: string) => void;
  /** Idle-unload scheduling; tests supply a fake clock. */
  timers?: { setTimeout(fn: () => void, ms: number): unknown; clearTimeout(handle: unknown): void };
  /** Monotonic milliseconds for the reported load times. */
  now?: () => number;
  /** Receives `model.load`, `model.unload` and `model.memory` events; publishing never waits for a subscriber. */
  events?: Pick<EventBus, "publish">;
}

const realTimers: NonNullable<WhisperModelHostOptions["timers"]> = {
  setTimeout(fn, ms) { const handle = setTimeout(fn, ms); handle.unref?.(); return handle; },
  clearTimeout(handle) { clearTimeout(handle as ReturnType<typeof setTimeout>); },
};

/** The library's decode options for the portable ones a consumer supplies. */
function whisperOptions(options: TranscribeOptions | undefined): WhisperTranscribeOptions {
  const o = options ?? {};
  return {
    task: o.task ?? "transcribe",
    language: o.language == null || o.language === "auto" ? null : o.language,
    initialPrompt: o.prompt ?? null,
    beamSize: o.beamSize ?? null,
    ...(o.temperature != null ? { temperature: o.temperature } : {}),
    conditionOnPreviousText: o.conditionOnPreviousText ?? true,
    ...(o.noSpeechThreshold !== undefined ? { noSpeechThreshold: o.noSpeechThreshold } : {}),
    withoutTimestamps: o.withoutTimestamps ?? false,
    wordTimestamps: o.wordTimestamps ?? false,
    fast: !o.faithful,
    audioCtx: o.audioCtx ?? null,
  };
}

function transcription(loaded: LoadedWhisper, exclusive: Exclusive): TranscriptionOperation {
  return {
    promptTokenBudget: loaded.promptTokenBudget,
    encode: text => loaded.encode(text),
    transcribe: (samples, options) => exclusive(() => loaded.transcribe(samples,
      { ...whisperOptions(options), onSegment: options?.onSegment, onProgress: options?.onProgress, signal: options?.signal }), options?.signal),
    start(options) {
      const run = loaded.start({ ...whisperOptions(options), signal: options?.signal });
      return {
        get segments() { return run.segments; },
        feedSilent: samples => run.feedSilent(samples),
        feed: (samples, signal) => exclusive(() => { signal?.throwIfAborted(); return run.feed(samples); }, signal),
        finish: signal => exclusive(() => { signal?.throwIfAborted(); return run.finish(); }, signal),
      };
    },
  };
}

interface Slot {
  readonly id: ModelId;
  readonly directory: string;
  readonly bytes: number;
  loaded: LoadedWhisper | null;
  loading: Promise<LoadedWhisper> | null;
  leases: number;
  pinned: boolean;
  timer: unknown;
  loads: number;
  unloads: number;
  lastLoadMs: number;
  lastUsedAt: number;
}

/** `ModelHost` for Whisper checkpoints, plus what the composing host needs beyond the contract: `preload` and `close`. */
export interface WhisperModelHost extends ModelHost {
  /** Load a model now without leasing it (`--preload`); it then follows the idle policy from its next lease. */
  preload(id?: ModelId): Promise<void>;
  /** Stop admission, cancel idle timers, wait for loads in flight and release every checkpoint. Idempotent. */
  close(): Promise<void>;
}

export function createWhisperModelHost(options: WhisperModelHostOptions): WhisperModelHost {
  const catalog = options.catalog, backend = options.backend ?? nativeWhisperBackend, exclusive: Exclusive = options.exclusive ?? (fn => fn());
  const log = options.log ?? (line => console.log(line)), timers = options.timers ?? realTimers, now = options.now ?? (() => performance.now());
  const idleUnloadSec = Math.max(0, options.idleUnloadSec ?? 0);
  const slots = new Map<ModelId, Slot>();
  /** What the catalog listed when the default was resolved, so leasing it does not look it up again. */
  const listed = new Map<ModelId, CatalogEntry>();
  let closed = false, closing: Promise<void> | null = null, defaultTranscription: Promise<ModelId | undefined> | undefined;
  const pinnedIds = new Set<ModelId>(options.resident && options.configured ? [options.configured.id] : []);
  const closedError = () => new ModelHostFailure("closed", "transcription service is closed");

  const cancelTimer = (slot: Slot) => {
    if (slot.timer !== null) timers.clearTimeout(slot.timer);
    slot.timer = null;
  };
  /** Release the weights; a release at close is not an unload. */
  const dispose = (slot: Slot, reason: ModelUnloadReason | null = "idle") => {
    cancelTimer(slot);
    if (!slot.loaded) return false;
    const started = now();
    slot.loaded.dispose();
    slot.loaded = null;
    if (reason) {
      slot.unloads++;
      publish({ type: "model.unload", at: Date.now(), model: slot.id, reason, drainMs: now() - started, flushed: false });
    }
    return true;
  };
  const publish = (event: Parameters<EventBus["publish"]>[0]) => { try { options.events?.publish(event); } catch { /* the bus contract is never to throw; a stand-in must not break a decode */ } };
  const isPinned = (id: ModelId) => pinnedIds.has(id);
  const armIdle = (slot: Slot, keepAliveSec: number | undefined) => {
    cancelTimer(slot);
    if (isPinned(slot.id) || closed) return;
    const seconds = Math.max(0, keepAliveSec ?? idleUnloadSec);
    if (seconds <= 0) { if (slot.leases === 0 && dispose(slot)) log(`[transcription] ${slot.id} unloaded (idle)`); return; }
    slot.timer = timers.setTimeout(() => { slot.timer = null; if (slot.leases === 0 && dispose(slot)) log(`[transcription] ${slot.id} unloaded (idle)`); }, seconds * 1000);
  };

  async function slotFor(id: ModelId, need: readonly ModelOperation[]): Promise<Slot> {
    const existing = slots.get(id);
    if (existing) return existing;
    const entry = options.configured?.id === id
      ? { id, directory: options.configured.directory, bytes: 0, operations: ["transcribe"] as readonly ModelOperation[] }
      : listed.get(id) ?? await catalog.find(id);
    for (const operation of ["transcribe" as const, ...need])
      if (!entry.operations.includes(operation)) throw new ModelHostFailure("does-not-fit", `${entry.id} does not declare the ${operation} operation`);
    const known = slots.get(entry.id);
    if (known) return known;
    const slot: Slot = { id: entry.id, directory: entry.directory, bytes: entry.bytes, loaded: null, loading: null, leases: 0, pinned: false,
      timer: null, loads: 0, unloads: 0, lastLoadMs: 0, lastUsedAt: 0 };
    slots.set(entry.id, slot);
    if (id !== entry.id) slots.set(id, slot);
    return slot;
  }

  /** Load (or reuse); returns the milliseconds this call waited for weights. */
  async function ensureLoaded(slot: Slot): Promise<{ loadMs: number; loaded: LoadedWhisper }> {
    if (closed) throw closedError();
    if (slot.loaded) return { loadMs: 0, loaded: slot.loaded };
    const waitStart = now();
    if (!slot.loading) {
      slot.loading = (async () => {
        const t0 = now();
        let loaded: LoadedWhisper;
        publish({ type: "model.load", at: Date.now(), model: slot.id, phase: "started" });
        try { loaded = await backend.load(slot.directory); }
        catch (error) {
          const message = error instanceof Error ? error.message : String(error);
          publish({ type: "model.load", at: Date.now(), model: slot.id, phase: "failed", error: message });
          throw new ModelHostFailure("load-failed", message, { cause: error });
        }
        if (closed) { loaded.dispose(); throw closedError(); }
        slot.loaded = loaded;
        slot.loads++;
        slot.lastLoadMs = now() - t0;
        log(`[transcription] ${slot.id} loaded in ${slot.lastLoadMs.toFixed(0)} ms`);
        publish({ type: "model.load", at: Date.now(), model: slot.id, phase: "finished", ms: slot.lastLoadMs, weightsBytes: slot.bytes });
        publish({ type: "model.memory", at: Date.now(), model: slot.id, weightsBytes: slot.bytes, kvBytes: 0, prefixCacheBytes: 0 });
        return loaded;
      })().finally(() => { slot.loading = null; });
    }
    const loaded = await slot.loading;
    return { loadMs: now() - waitStart, loaded };
  }

  const resident = (slot: Slot): ResidentModel => ({ id: slot.id, role: "companion", state: slot.loading && !slot.loaded ? "loading" : "ready",
    operations: ["transcribe"], bytes: slot.bytes, pinned: isPinned(slot.id), leases: slot.leases, lastUsedAt: slot.lastUsedAt });

  const host: WhisperModelHost = {
    get policy(): ResidencyPolicy { return { budgetBytes: Number.POSITIVE_INFINITY, pinned: [...pinnedIds], idleUnloadSec }; },

    async acquire(id: ModelId, acquireOptions: AcquireOptions = {}): Promise<ModelLease> {
      if (closed) throw closedError();
      const slot = await slotFor(id, acquireOptions.need ?? []);
      acquireOptions.signal?.throwIfAborted();
      // Reserve before suspending again: an idle timer and unload refuse while a lease is held.
      cancelTimer(slot);
      slot.leases++;
      let loaded: LoadedWhisper, loadMs: number;
      try { ({ loaded, loadMs } = await ensureLoaded(slot)); }
      catch (error) { slot.leases--; armIdle(slot, acquireOptions.keepAliveSec); throw error; }
      slot.lastUsedAt = Date.now();
      let released = false;
      return {
        model: resident(slot), loadMs, operations: { transcribe: transcription(loaded, exclusive) },
        release() {
          if (released) return;
          released = true;
          slot.leases--;
          armIdle(slot, acquireOptions.keepAliveSec);
        },
      };
    },

    /** Resolved once, as in main: a checkpoint downloaded later needs a restart. */
    defaultFor(operation) {
      if (operation !== "transcribe") return Promise.resolve(undefined);
      return defaultTranscription ??= options.configured ? Promise.resolve(options.configured.id)
        : catalog.list({ kind: "model" }).then(entries => {
          for (const entry of entries) listed.set(entry.id, entry);
          return entries.find(entry => entry.operations.includes(operation))?.id;
        }, () => undefined);
    },

    async plan(id) {
      const slot = await slotFor(id, []);
      return { fits: true, requiredBytes: slot.bytes, freeBytes: Number.POSITIVE_INFINITY, evict: [] } satisfies ResidencyPlan;
    },

    async unload(id, unloadOptions = {}) {
      const slot = slots.get(id);
      if (!slot) return;
      cancelTimer(slot);
      if (!slot.loaded) return;
      if (slot.leases > 0 && !unloadOptions.force) throw new ModelHostFailure("in-use", `${slot.id} is in use`);
      if (dispose(slot, "requested")) log(`[transcription] ${slot.id} unloaded (idle)`);
    },

    pin(id) { pinnedIds.add(id); const slot = slots.get(id); if (slot) cancelTimer(slot); },
    unpin(id) { pinnedIds.delete(id); },
    resident: () => [...new Set(slots.values())].filter(slot => slot.loaded).map(resident),

    stats(id): ModelStats {
      const slot = slots.get(id);
      return { resident: !!slot?.loaded, loads: slot?.loads ?? 0, unloads: slot?.unloads ?? 0, lastLoadMs: slot?.lastLoadMs ?? 0,
        idleUnloadSec: isPinned(id) ? null : idleUnloadSec };
    },

    async preload(id) {
      const target = id ?? await host.defaultFor("transcribe");
      if (!target) throw new ModelHostFailure("does-not-fit", "no Whisper model is available");
      await ensureLoaded(await slotFor(target, []));
    },

    close() {
      if (closing) return closing;
      closed = true;
      const all = [...new Set(slots.values())];
      const release = () => { for (const slot of all) dispose(slot, null); };
      const loading = all.flatMap(slot => slot.loading ? [slot.loading.catch(() => undefined)] : []);
      if (!loading.length) { release(); return closing = Promise.resolve(); }
      return closing = Promise.all(loading).then(release);
    },
  };
  return host;
}
