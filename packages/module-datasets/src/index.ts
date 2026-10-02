import type { AppModule, ModuleRuntime } from "@mlx-bun/app-core";
import { manifest } from "./manifest";
import { DATASET_JOB, createDatasetHandlers } from "./routes";
import { createDatasetRunner } from "./runner";
import type { VerifyPython } from "./python-verifier";

export { manifest } from "./manifest";
export { createDatasetHandlers, DATASET_JOB } from "./routes";
export { createDatasetRunner } from "./runner";
export type { DatasetRunnerDependencies } from "./runner";
export { generate, getTemplate, TEMPLATES } from "./registry";
export type { GenerateResult, TemplateDef, TemplateField } from "./registry";
export { makeLlmClient } from "./llm";
export type { ChatMessage, ChatOpts, DatasetHttp, LlmClient } from "./llm";
export { createPythonVerifier, PYTHON_VERIFIER_IMAGE, PYTHON_VERIFIER_LIMITS, spawnDocker } from "./python-verifier";
export type { SpawnDocker, VerifyPython, PythonVerification } from "./python-verifier";

/** Test seams: Hugging Face's transport and the Python verifier. */
export interface DatasetsModuleOptions {
  fetch?: typeof fetch;
  verifyPython?: VerifyPython;
}

/** The datasets module. The host implements `jobs` (the `dataset` task kind), `storage` (`datasets/`) and `modelHost` (the served model's `generate`). */
export function createDatasetsModule(options: DatasetsModuleOptions = {}): AppModule<"jobs" | "storage" | "modelHost"> {
  return {
    ...manifest,
    activate({ services }): ModuleRuntime {
      const handlers = createDatasetHandlers(services);
      return {
        routes: handlers,
        jobs: { [DATASET_JOB]: createDatasetRunner({ models: services.modelHost, ...options }) },
      };
    },
  };
}

export default createDatasetsModule();
