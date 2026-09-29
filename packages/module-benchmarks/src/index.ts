import type { AppModule, ModuleRuntime } from "@mlx-bun/app-core";
import { createEvalRunner, type EvalOptions } from "./evals";
import { manifest } from "./manifest";
import { createBenchmarkRoutes } from "./routes";

export { manifest } from "./manifest";
export { CHECKOUT, compactResult, compareRuns, createEvalRunner, evalDirectories, listHistory, listTasks, readHistory, resolveModel, taskSpec } from "./evals";
export type { EvalOptions } from "./evals";
export { createBenchmarkRoutes } from "./routes";
export type { BenchmarkRoutesOptions } from "./routes";
export type * from "./protocol";

/** Test seams: the runner's checkout, server command, MLX library and process creation. */
export type BenchmarksModuleOptions = Partial<Omit<EvalOptions, "storage" | "models" | "catalog">>;

/** The benchmarks module. The host implements `jobs` (the `eval-serve` task kind, exclusive of the GPU), `storage`, `modelHost` (which model is served) and `catalog` (its directory). */
export function createBenchmarksModule(options: BenchmarksModuleOptions = {}): AppModule<"jobs" | "storage" | "modelHost" | "catalog"> {
  return {
    ...manifest,
    activate({ services }): ModuleRuntime {
      const evals: EvalOptions = { storage: services.storage, models: services.modelHost, catalog: services.catalog, ...options };
      return {
        routes: createBenchmarkRoutes({ evals, jobs: services.jobs }),
        jobs: { "eval-serve": createEvalRunner(evals) },
      };
    },
  };
}

export default createBenchmarksModule();
