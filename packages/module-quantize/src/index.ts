import type { AppModule, CliVerbHandler, JobRunner, ModuleRuntime, RouteHandler } from "@mlx-bun/app-core";
import { quantizeInChild, runConvert, type ConvertDependencies } from "./convert";
import { createQuantizeRunner } from "./job";
import { manifest } from "./manifest";
import { createQuantizeHandlers } from "./routes";

export { manifest } from "./manifest";
export { quantizeInChild, runConvert } from "./convert";
export type { ConvertArgs, ConvertDependencies } from "./convert";
export { inspectModel, resolveSrcDir } from "./inspect";
export { createQuantizeRunner } from "./job";
export { CONVERT_DTYPES, convertedModelName, modelShortName, quantizedModelName } from "./output-name";
export { createQuantizeHandlers } from "./routes";
export type { QuantizeRouteServices } from "./routes";

/** Test seams: the native producers behind the job, and the verb's process and terminal dependencies. */
export interface QuantizeModuleOptions {
  producers?: Parameters<typeof createQuantizeRunner>[1];
  convert?: Partial<ConvertDependencies>;
}

/** The quantize module. The host implements `jobs` (the `quantize` job runs as a child process under its GPU lease), `storage` (the `models` entry) and `catalog`. */
export function createQuantizeModule(options: QuantizeModuleOptions = {}): AppModule<"jobs" | "storage" | "catalog"> {
  return {
    ...manifest,
    activate({ services }): ModuleRuntime {
      const handlers = createQuantizeHandlers(services) as Record<(typeof manifest.routes)[number]["id"], RouteHandler>;
      const convert: CliVerbHandler = async invocation => {
        const dependencies: ConvertDependencies = {
          quantize: (config, outDir, progress, signal) => quantizeInChild(services.jobs, config, outDir, progress, signal),
          catalog: services.catalog,
          modelsDir: () => services.storage.path("models"),
          terminal: invocation.terminal,
          log: (line = "") => { invocation.stdout(line + "\n"); },
          ...(options.convert ?? {}),
        };
        await runConvert(invocation, dependencies, invocation.signal);
        return 0;
      };
      const quantize: JobRunner = createQuantizeRunner(services.catalog, options.producers);
      return { routes: handlers, verbs: { convert }, jobs: { quantize } };
    },
  };
}

export default createQuantizeModule();
