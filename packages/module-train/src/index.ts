import type { AppModule, CliVerbHandler, JobRunner, ModuleRuntime, RouteHandler } from "@mlx-bun/app-core";
import { runDraft, draftDependencies, type DraftDependencies } from "./draft";
import { fuseDependencies, runFuse, type FuseDependencies } from "./fuse";
import { createFinetuneRunner } from "./job";
import { manifest } from "./manifest";
import { createTrainHandlers } from "./routes";
import { runTrain, runTrainWatch, trainDependencies, type TrainDependencies, type WatchDependencies } from "./train";
import { runWatch } from "./watch";

export { manifest } from "./manifest";
export { parseFinetuneConfig } from "./config";
export { inspectDataset } from "./inspect";
export { createFinetuneRunner } from "./job";
export type { FinetuneRuntime } from "./job";
export { modelShortName, selectModel } from "./model";
export type { SelectedModel } from "./model";
export { createTrainHandlers } from "./routes";
export type { TrainRouteServices } from "./routes";
export { modelTrainingDefaults, parseTrainArgs, runTrain, runTrainWatch, trainDependencies, trainPlan } from "./train";
export type { PeakMemory, TrainArgs, TrainDependencies, TrainMethod, TrainPlan, TrainRunner, VerbArgs, WatchDependencies } from "./train";
export { fuseDependencies, runFuse } from "./fuse";
export type { FuseDependencies } from "./fuse";
export { DRAFT_ACTIONS, draftDependencies, draftOutput, parseDraftArgs, runDraft } from "./draft";
export type { DraftAction, DraftArgs, DraftDependencies, DraftTarget } from "./draft";
export { parseStream, processTerminal, renderFrame, runWatch, sPerStep } from "./watch";
export type { WatchTerminal } from "./watch";

/** Test seams: each verb's dependencies over what the host gives it. */
export interface TrainModuleOptions {
  train?(defaults: TrainDependencies): TrainDependencies;
  fuse?(defaults: FuseDependencies): FuseDependencies;
  draft?(defaults: DraftDependencies): DraftDependencies;
  watch?(defaults: WatchDependencies): WatchDependencies;
  /** The producer behind the `finetune` job. */
  runner?: JobRunner;
}

/** The host aborts a verb's signal with "<verb> cancelled"; `train` keeps the message its interrupted runs always ended with. */
function cancelledAs(signal: AbortSignal, message: string): AbortSignal {
  const relay = new AbortController(), stop = () => relay.abort(new Error(message));
  if (signal.aborted) stop(); else signal.addEventListener("abort", stop, { once: true });
  return relay.signal;
}

/** The train module. The host implements `jobs` (the `finetune` job runs as a child process under its GPU lease), `storage` (`adapters`, and the `models` and `datasets` entries the module shares) and `catalog`. */
export function createTrainModule(options: TrainModuleOptions = {}): AppModule<"jobs" | "storage" | "catalog"> {
  return {
    ...manifest,
    activate({ services }): ModuleRuntime {
      const handlers = createTrainHandlers(services) as Record<(typeof manifest.routes)[number]["id"], RouteHandler>;
      const adaptersDir = () => services.storage.path("adapters");
      const verbs: Record<(typeof manifest.verbs)[number]["name"], CliVerbHandler> = {
        train: async invocation => {
          const defaults = trainDependencies({ catalog: services.catalog, adaptersDir }, invocation);
          await runTrain(invocation, options.train?.(defaults) ?? defaults, cancelledAs(invocation.signal, "training cancelled"));
          return 0;
        },
        "train-watch": async invocation => {
          const defaults: WatchDependencies = { watch: runWatch, adaptersDir };
          await runTrainWatch(invocation, options.watch?.(defaults) ?? defaults, invocation.signal);
          return 0;
        },
        fuse: async invocation => {
          const defaults = fuseDependencies({ catalog: services.catalog, modelsDir: () => services.storage.path("models") }, invocation);
          await runFuse(invocation, options.fuse?.(defaults) ?? defaults, invocation.signal);
          return 0;
        },
        draft: async invocation => {
          const defaults = draftDependencies({ catalog: services.catalog, datasetsDir: () => services.storage.path("datasets"),
            modelsDir: () => services.storage.path("models") }, invocation);
          await runDraft(invocation, options.draft?.(defaults) ?? defaults, invocation.signal);
          return 0;
        },
      };
      const finetune: JobRunner = options.runner ?? createFinetuneRunner();
      return { routes: handlers, verbs, jobs: { finetune } };
    },
  };
}

export default createTrainModule();
