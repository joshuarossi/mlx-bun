// The isolated serve composition, the default for `serve`: this process keeps the persistent
// CPU state (serve-state.ts), the web app, the chat module, the Responses history, the managed jobs and
// the modules that run beside them, and loads no model. Each resident model runs in its own
// worker process (worker-unit.ts; worker-entry.ts composes the model host over a Unix socket).
// This process holds their residency by memory fit with the same manager the in-process host
// uses (residency/model-residency.ts), counting each worker at the MLX memory it measures and reports
// (cli/worker-unit.ts; the estimate stands only before its first report): a model that fits the budget
// gets its own worker beside the others; otherwise the least recently used unpinned, unleased model is drained, its worker
// flushes its saved state durably and exits (the worker gets the CLI's shutdown budget, never a
// kill first), and naming it again spawns a worker that resumes from that state. Requests route
// by their `model` (server/model-routes.ts) and forward over the worker's socket; a crash
// respawns that worker with its model while the app stays up. Whisper and each image model are a companion worker of
// their own, which can be pinned; an image worker serves only the model it was started for. Each worker's events are
// relayed onto this process's bus.
// Nothing here imports the engine or a native module.
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { AppModule, ModelOperation } from "@mlx-bun/app-core";
import { defaultStageBudgetBytes, pipelineComponentBytes, stageResidency } from "@mlx-bun/app-services/portable";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import { EngineUnavailableError, type WorkerRestartBudget } from "../jobs/worker-supervisor";
import { createWorkerMemoryClient } from "../server/memory-completion-client";
import { createModelRoutes } from "../server/model-routes";
import { createProxyRoutes } from "../server/proxy-routes";
import { createResponsesClient } from "../server/responses-client";
import { startServer } from "../server/start";
import { listLocalRecords } from "../residency/local-records";
import { leasedAdapters } from "../residency/leased-adapters";
import { createResidencyHost, ResidencyError, type ResidencyEntry, type ResidencyHost, type ResidencySource } from "../residency/model-residency";
import { createRecordIndex } from "../residency/record-index";
import { defaultBudgetBytes, estimateRecordBytes } from "../residency/resident-estimate";
import type { RunningApp, ServeOptions } from "./serve-options";
import { createAppState, type RouteGroup } from "./serve-state";
import { spawnWorkerUnit, type WorkerUnit, type WorkerUnitContext } from "./worker-unit";

/** What the composition root supplies (`modules`: the installed modules that run in the persistent state)
 * and, internally for tests, stand-ins for the worker entry, the restart policy, and the model listing. */
export interface IsolatedServeHooks {
  modules?: Parameters<typeof createAppState>[2];
  /** Selects the dedicated task-model snapshot, without loading it in the parent. */
  taskSnapshot?(): Promise<string>;
  entry?: string;
  restarts?: Partial<WorkerRestartBudget>;
  env?: Record<string, string | undefined>;
  readyTimeoutMs?: number;
  graceMs?: number;
  notice?(line: string): void;
  log?(line: string): void;
  error?(line: string): void;
  /** Internal (tests): sees the app's event bus, where each worker's relayed events and the host's load/unload events arrive. */
  observe?(events: Pick<import("@mlx-bun/app-core").EventBus, "subscribe">): void;
  /** The local chat models the host may load, instead of the registry's. */
  records?(): readonly ModelRecord[];
  /** The checkpoints that may answer a companion operation (Whisper for `transcribe`, an image model for `image`), instead of the registry's. */
  companions?(operation: CompanionOperation): readonly ModelRecord[];
  /** The image hosts' stage budget, instead of the default share of physical memory. */
  stageBudgetBytes?: number;
}

/** The operations a companion worker answers beside the chat models, each from its own checkpoint. */
type CompanionOperation = "transcribe" | "image";
/** The request paths each companion operation answers (its module's routes); the router leases that companion for them. */
const COMPANION_PATHS: Readonly<Record<CompanionOperation, readonly string[]>> = {
  transcribe: ["/v1/audio/", "/admin/transcription/"],
  image: ["/v1/images/"],
};
/** How the host serves each companion operation's checkpoints, one worker per checkpoint. */
interface CompanionServing {
  /** The checkpoint a request is served with when it names none of this operation's by exact id. */
  default(): Promise<ModelRecord | undefined>;
  /** The checkpoint with exactly this id that a worker of this operation may serve. */
  find(id: string): Promise<ModelRecord | undefined>;
  /** What its worker is charged until it reports its own memory. */
  bytes(record: ModelRecord): Promise<number>;
  /** Its requests name their checkpoint in the JSON body's `model`; others (audio uploads) are never read for one. */
  named: boolean;
}

/** Isolated composition: the persistent state and the startup model's worker first, the listener
 * once that worker serves, so startup fails the way the in-process composition does when the model cannot load. */
export async function startIsolatedServer(model: ModelRecord, options: ServeOptions, hooks: IsolatedServeHooks = {}): Promise<RunningApp> {
  let residency!: ResidencyHost<WorkerUnit>;
  /** The model requests that name none are answered by, and Pi's `local`: the one the server started with, then the last switch. */
  let current = model.repoId;
  const workers = () => residency ? residency.resident().flatMap(({ id }) => { const unit = residency.peek(id); return unit ? [unit] : []; }) : [];
  const currentUnit = () => residency?.peek(current);
  // Snapshots a worker reads besides its own model: the memory task model, selected here and kept out of hub GC
  // from the call that carries it for as long as that worker lives (a respawned worker holds none until asked).
  const retained = new WeakMap<WorkerUnit, { restarts: number; paths: Set<string> }>();
  const retention = (unit: WorkerUnit) => {
    let held = retained.get(unit);
    if (!held || held.restarts !== unit.supervisor.restarts) retained.set(unit, held = { restarts: unit.supervisor.restarts, paths: new Set() });
    return held.paths;
  };
  // The parent loads no model: each synthesis stage call or batch runs on the current model's worker (its memory task
  // model, over its private route). A run holds that model's residency lease from its first call to its last (the same
  // `acquire` every consumer takes), so the worker it depends on is never drained under it; the worker takes its own
  // execution lease per call. Each call selects the task model snapshot once, here (the worker never scans the cache):
  // the call carries it, and a call that loads the task model loads exactly it.
  const state = await createAppState({ ...options, memoryCompletions: async signal => {
    let release: (() => void) | undefined;
    let selected: Promise<WorkerUnit> | undefined;
    const select = async () => {
      if (!residency) throw new EngineUnavailableError("starting", null);
      const lease = await residency.acquire(current, { signal, need: ["generate"] });
      release = () => lease.release();
      return lease.unit;
    };
    const client = createWorkerMemoryClient(async () => {
      if (!hooks.taskSnapshot) throw new Error("memory synthesis has no task model snapshot selector in this composition");
      const snapshot = await hooks.taskSnapshot();
      // Planning and empty pipelines never acquire or reload a worker. The first real call captures one worker,
      // whose residency stays held until the run (including every in-flight row) settles.
      const unit = await (selected ??= select());
      retention(unit).add(snapshot);
      return { worker: unit.supervisor, snapshot };
    }, signal);
    return Object.assign(client, { release: () => release?.() });
  } }, options.storagePaths ?? {}, hooks.modules ?? []);
  hooks.observe?.(state.events);
  // The sockets live in a private directory (0700) this process removes, one per worker.
  const socketDir = mkdtempSync(join(tmpdir(), "mlx-worker-"));
  const removeSocketDir = () => rmSync(socketDir, { recursive: true, force: true });
  const notice = hooks.notice ?? (line => console.log(`[isolate] ${line}`));
  // The startup worker until residency adopts it: a failure in between still stops it.
  let unadopted: WorkerUnit | undefined;
  const closeEngine = async () => {
    try { await unadopted?.close({ flush: false }); } finally { try { await residency?.close(); } finally { removeSocketDir(); } }
  };
  let detachLink = () => {};
  const detach = () => { const release = detachLink; detachLink = () => {}; release(); };
  let cleanup: (() => Promise<void>) | undefined = closeEngine;
  try {
    const { thisMachine } = await import("@mlx-bun/inference/execution/fit");
    const machine = thisMachine();
    // One stage budget for every image worker: its host's staging decision and this host's charge for it.
    const stageBudgetBytes = hooks.stageBudgetBytes ?? defaultStageBudgetBytes();
    const context: WorkerUnitContext = { options, startup: model, socketDir, stageBudgetBytes, publish: event => state.events.publish(event), notice,
      ...(hooks.entry ? { entry: hooks.entry } : {}), ...(hooks.restarts ? { restarts: hooks.restarts } : {}), ...(hooks.env ? { env: hooks.env } : {}),
      ...(hooks.readyTimeoutMs !== undefined ? { readyTimeoutMs: hooks.readyTimeoutMs } : {}), ...(hooks.graceMs !== undefined ? { graceMs: hooks.graceMs } : {}),
      ...(hooks.log ? { log: hooks.log } : {}), ...(hooks.error ? { error: hooks.error } : {}) };
    // Startup fails fast, as the in-process composition does: the first model's worker serves before the listener binds. Its
    // report is also how this process, which asks no Metal device itself, learns the device working set.
    const first = unadopted = await spawnWorkerUnit(context, model, "primary", model.sizeBytes);
    // What all resident workers may use together: `--model-budget`, else the share of the device working set the in-process
    // host uses (residency/resident-estimate.ts), as the first worker reported it.
    const budgetBytes = options.modelBudgetBytes ?? defaultBudgetBytes(first.measured()?.workingSetBytes);
    const chatModels = createRecordIndex(() => hooks.records?.() ?? listLocalRecords("generate"), model);
    const companionList = (operation: CompanionOperation) => hooks.companions?.(operation) ?? listLocalRecords(operation);
    // Whisper: the checkpoint `--whisper-model` resolved to, else the first downloaded one, looked up once.
    let whisper: Promise<ModelRecord | undefined> | undefined;
    const whisperRecord = () => whisper ??= (async () => {
      const explicit = options.whisper;
      if (explicit?.modelDir && explicit.modelId) {
        const listed = (await companionList("transcribe")).find(record => record.repoId === explicit.modelId);
        return listed ?? { repoId: explicit.modelId, path: explicit.modelDir, modelType: "whisper", sizeBytes: 0, expertsBytes: 0 } as unknown as ModelRecord;
      }
      return (await companionList("transcribe"))[0];
    })();
    // The image companions: every downloaded text-to-image model by its exact id, each in a worker of its own that serves it
    // alone; the first is the default, looked up once like Whisper. A worker is charged what one run holds under the stage rule
    // its host applies, from the snapshot's component files (this process reads no weights); a snapshot whose components
    // cannot be read is charged its whole size.
    const imageModels = createRecordIndex(() => companionList("image"));
    let image: Promise<ModelRecord | undefined> | undefined;
    const imageRecord = () => image ??= (async () => (await companionList("image"))[0])();
    const imageRunBytes = async (record: ModelRecord) => {
      const components = Object.values(await pipelineComponentBytes(record.path).catch(() => ({})));
      return components.length ? stageResidency(components, stageBudgetBytes).bytes : record.sizeBytes;
    };
    /** How each companion operation is served: Whisper's one checkpoint, and every image model by exact id. */
    const companions: Readonly<Record<CompanionOperation, CompanionServing>> = {
      transcribe: { default: whisperRecord, find: async id => { const record = await whisperRecord(); return record?.repoId === id ? record : undefined; },
        bytes: async record => record.sizeBytes, named: false },
      image: { default: imageRecord, find: id => imageModels.find(id), bytes: imageRunBytes, named: true },
    };
    const companionOperations = Object.keys(companions) as CompanionOperation[];
    const source: ResidencySource<WorkerUnit> = {
      async resolve(id) {
        const chat = await chatModels.find(id);
        // A config the fit model cannot read leaves the checkpoint's own size as the estimate.
        if (chat) return { id, bytes: await estimateRecordBytes(chat, { budgetBytes, cache: options.cache, machine }).catch(() => chat.sizeBytes), operations: ["generate"], role: "primary" };
        for (const operation of companionOperations) {
          const companion = await companions[operation].find(id);
          if (companion) return { id, bytes: await companions[operation].bytes(companion), operations: [operation], role: "companion" };
        }
        return undefined;
      },
      async load(entry) {
        const operation = entry.operations[0] as CompanionOperation | "generate";
        const record = operation === "generate" ? (await chatModels.find(entry.id))! : (await companions[operation].find(entry.id))!;
        return spawnWorkerUnit(context, record, entry.role ?? "primary", entry.bytes, operation);
      },
    };
    const companionFor = (operation: ModelOperation) => (companions as Partial<Record<ModelOperation, CompanionServing>>)[operation];
    residency = createResidencyHost<WorkerUnit>({ source, budgetBytes, events: state.events,
      defaultFor: async operation => operation === "generate" ? current : (await companionFor(operation)?.default())?.repoId,
      async serve(id, signal) {
        if (!await chatModels.find(id)) throw new ResidencyError("not-found", `${id} is not a local model; download it first`);
        (await residency.acquire(id, { ...(signal ? { signal } : {}), need: ["generate"] })).release();
        current = id;
      },
      // Hub cleanup keeps the snapshot of every resident worker's model, and the task model's on the worker that read it.
      uses: unit => [unit.record.path, ...retention(unit)],
      log: line => notice(line) });
    const entryOf = (unit: WorkerUnit): ResidencyEntry => ({ id: unit.id, bytes: unit.bytes(), role: unit.role, operations: unit.operations });
    residency.adopt(entryOf(first), first, { loadMs: first.readyMs });
    unadopted = undefined;
    // Whisper stays resident when asked to (`--whisper-resident`); otherwise it is the first to go when memory is short.
    const companion = options.whisper?.resident ? await whisperRecord() : undefined;
    if (companion) residency.pin(companion.repoId);

    const models = createModelRoutes({ host: residency, current: () => current,
      serves: async id => !!await chatModels.find(id),
      transcription: async () => (await whisperRecord())?.repoId,
      // Audio requests belong to the Whisper worker; an image request to the worker of the local image model its body names by exact
      // id (the rule chat routing follows), else the default's. Each loads on first use and drains a chat model when memory is short.
      companion: async (pathname, named) => {
        const operation = companionOperations.find(each => COMPANION_PATHS[each].some(prefix => pathname.startsWith(prefix)));
        if (!operation) return undefined;
        const serving = companions[operation], id = serving.named ? await named() : undefined;
        return ((id !== undefined ? await serving.find(id) : undefined) ?? await serving.default())?.repoId;
      } });
    const responses = createResponsesClient(state.responses);
    const proxy = createProxyRoutes({ workers: () => workers(), current: () => current, models, responses,
      modelId: model.repoId, startedAt: Date.now() });
    const invalidateLibrary = () => { chatModels.invalidate(); imageModels.invalidate(); };
    const persistent = state.routes;
    // The persistent groups answer first, in the direct host's order among themselves; the proxy takes every remaining path.
    const routes: RouteGroup = { handle: async request => await persistent.jobs.handle(request) ??
      await persistent.appModules.handle(request) ??
      await persistent.publishing.handle(request) ?? await proxy.handle(request) };
    let boundPort = options.port;
    // The chat module lives in the state and reaches the model through the served model host (over this listener's proxy;
    // its `local` model id is whatever is current), so web chat survives a worker restart and reports its failures as errors.
    // Jobs pause every resident worker; loopback clients reach the workers through the proxy; a hub switch is this host's to make.
    detachLink = state.attach({ get model() { return { id: current, bytes: currentUnit()?.bytes() ?? model.sizeBytes }; }, get port() { return boundPort; },
      acquireExecutionLease: signal => residency.pauseAll(signal),
      // Modules that generate through the model host (a dataset job) hold the model's residency lease until they release it.
      hold: (id, signal) => residency.acquire(id, { need: ["generate"], ...(signal ? { signal } : {}) }),
      invalidateLibrary,
      resident: () => residency.resident(),
      adapters: leasedAdapters(residency, () => current),
      serve: (id, signal) => residency.serve(id, { signal }) });
    // startServer owns engine cleanup on entry, including a bind failure.
    cleanup = undefined;
    const listener = await startServer({ routes, web: state.web, sockets: state.sockets,
      // The app stops its producers (jobs, downloads) while the workers are alive, then chat and HTTP drain, then every
      // worker is drained, flushes its saved state, and exits.
      beforeDrain: () => state.close(),
      closeEngine }, { port: options.port, hostname: options.hostname });
    if (listener.server.port !== undefined) boundPort = listener.server.port;
    let closing: Promise<void> | undefined;
    return { port: boundPort, downloads: state.downloads, close: () => closing ??= (async () => {
      const errors: unknown[] = [];
      try { await listener.close(); } catch (error) { errors.push(error); } finally { detach(); }
      // The listener's drain already closed the state; a repeated failure here is the same one.
      try { await state.close(); } catch (error) { errors.push(error); }
      if (errors.length) throw errors[0];
    })() };
  } catch (error) {
    const failures: unknown[] = [];
    try { await cleanup?.(); } catch (failure) { failures.push(failure); }
    finally { detach(); }
    try { await state.close(); } catch (failure) { failures.push(failure); }
    if (failures.length) throw new AggregateError([error, ...failures], "startup and cleanup failed");
    throw error;
  }
}
