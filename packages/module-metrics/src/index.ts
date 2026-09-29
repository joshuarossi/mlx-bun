import type { AppEvent, AppModule, CoreEventType, ModuleRuntime } from "@mlx-bun/app-core";
import { createBenchRunner, type BenchOptions } from "./bench";
import { manifest } from "./manifest";
import { createMetricsRoutes, type StreamTimers } from "./routes";
import { createMetricsStore, type MetricsStoreOptions } from "./store";

export { manifest } from "./manifest";
export { benchDirectories, compactRun, createBenchRunner, listHistory, listProfiles, readHistory, resolvePlan } from "./bench";
export type { BenchOptions } from "./bench";
export { createMetricsRoutes } from "./routes";
export type { MetricsRoutesOptions, StreamTimers } from "./routes";
export { createMetricsStore } from "./store";
export type { MetricsStore, MetricsStoreOptions } from "./store";
export type * from "./protocol";

/** Test seams: the reducer's windows, the benchmark runner's process creation, and the stream's timers. */
export interface MetricsModuleOptions {
  store?: MetricsStoreOptions;
  bench?: Partial<Omit<BenchOptions, "storage">>;
  stream?: { minIntervalMs?: number; keepAliveMs?: number; timers?: StreamTimers };
}

/** The events this module reduces; the rest of the bus is not its concern. */
const SUBSCRIBED: readonly CoreEventType[] = ["model.load", "model.unload", "model.memory", "request.finished", "scheduler.sample", "cache.sample"];

/** The panel element as a browser module: its one source file with the types erased. Undefined where the source is not shipped. */
async function panelSource(): Promise<string | undefined> {
  const file = Bun.file(new URL("./panel/index.ts", import.meta.url));
  if (!await file.exists()) return undefined;
  return new Bun.Transpiler({ loader: "ts", target: "browser" }).transformSync(await file.text());
}

/** The metrics and performance module. The host implements `events` (the model host and the engine adapter publish), `storage` and `jobs`. */
export function createMetricsModule(options: MetricsModuleOptions = {}): AppModule<"events" | "storage" | "jobs"> {
  return {
    ...manifest,
    activate({ services, signal }): ModuleRuntime {
      const store = createMetricsStore(options.store);
      const listeners = new Set<() => void>();
      const unsubscribe = services.events.subscribe(SUBSCRIBED, (event: AppEvent) => {
        const before = store.version;
        store.apply(event);
        if (store.version !== before) for (const listener of listeners) listener();
      });
      let source: Promise<string | undefined> | undefined;
      const routes = createMetricsRoutes({
        store, storage: services.storage, jobs: services.jobs, signal,
        onChange: listener => { listeners.add(listener); return () => { listeners.delete(listener); }; },
        panel: () => source ??= panelSource(),
        ...(options.stream?.minIntervalMs !== undefined ? { minIntervalMs: options.stream.minIntervalMs } : {}),
        ...(options.stream?.keepAliveMs !== undefined ? { keepAliveMs: options.stream.keepAliveMs } : {}),
        ...(options.stream?.timers ? { timers: options.stream.timers } : {}),
      });
      const runner = createBenchRunner({ storage: services.storage, ...options.bench });
      return {
        routes,
        jobs: { "bench-serve": (emit, config, signal) => runner(emit, config, signal) },
        status: () => ({ requests: store.snapshot().requests.finished, streams: listeners.size }),
        dispose() { unsubscribe(); listeners.clear(); },
      };
    },
  };
}

export default createMetricsModule();
