import { existsSync } from "node:fs";
import { basename, join, resolve } from "node:path";
import { scanSnapshot, type ModelRecord, type Registry } from "@mlx-bun/hub/registry";
import { downloadModel } from "@mlx-bun/hub/download";
import { fit, thisMachine, type MachineSpec } from "@mlx-bun/inference/execution/fit";
import { loadModelConfig } from "@mlx-bun/inference/artifacts/config";
import { isSupportedModelRecord } from "@mlx-bun/inference/models/support";
import { chooseAutoModel, COEXIST_FRACTION, DEFAULT_REPO_ID, STARTER_REPO_ID } from "./model-choice";
import { openRegistry } from "../storage/paths";

type ModelRegistry = Pick<Registry, "list" | "resolve" | "scan" | "close">;
export interface ModelSelectionDependencies {
  registry(): ModelRegistry;
  scanSnapshot: typeof scanSnapshot;
  download: typeof downloadModel;
  machine(): MachineSpec;
  assess(model: ModelRecord, machine: MachineSpec): Promise<{ full: boolean; coexist: boolean }>;
  log(message: string): void;
}
const defaults: ModelSelectionDependencies = {
  registry: () => openRegistry(), scanSnapshot, download: downloadModel, machine: thisMachine,
  async assess(model, machine) {
    const config = await loadModelConfig(model.path);
    return {
      full: fit(config, model.sizeBytes, 8192, machine, undefined, model.expertsBytes).fits,
      coexist: fit(config, model.sizeBytes, 8192, machine, undefined, model.expertsBytes, machine.ramBytes * COEXIST_FRACTION).fits,
    };
  },
  log: message => console.log(message),
};

/** Resolve a path/query, or select a cached supported model. An empty supported
 * cache gets the starter first, as in main; the larger recommended model is
 * returned for the caller to fetch in the background under its own owner.
 * `signal` cancels the starter download (its partial stays resumable). */
export async function resolveModelAuto(query: string | null, supplied: Partial<ModelSelectionDependencies> = {},
  signal?: AbortSignal): Promise<{ m: ModelRecord; picked: boolean; recommended?: string }> {
  const deps = { ...defaults, ...supplied };
  if (query && existsSync(join(query, "config.json"))) {
    const directory = resolve(query);
    const hf = /models--([^/]+)--([^/]+)\/snapshots\//.exec(directory);
    const repoId = hf ? `${hf[1]}/${hf[2]}` : basename(directory);
    const model = await deps.scanSnapshot(directory, repoId);
    if (!model) throw new Error(`${directory} has config.json but no weights (*.safetensors)`);
    return { m: model, picked: false };
  }
  const registry = deps.registry();
  try {
    if (registry.list().length === 0) await registry.scan();
    if (query) return { m: registry.resolve(query), picked: false };
    const supported = () => registry.list().filter(model => isSupportedModelRecord(model.modelType));
    let candidates = supported();
    let recommended: string | undefined;
    if (candidates.length === 0) {
      signal?.throwIfAborted();
      deps.log(`Downloading starter model ${STARTER_REPO_ID}`);
      const reported = new Map<string, number>();
      await deps.download(STARTER_REPO_ID, {
        signal,
        onProgress(file, received, total) {
          // Keep redirected startup logs bounded while still showing large transfers.
          const bucket = total ? Math.floor(received / total * 10) : Math.floor(received / 100_000_000);
          if (reported.get(file) === bucket) return;
          reported.set(file, bucket);
          const progress = total ? `${Math.floor(received / total * 100)}%` : `${received} bytes`;
          deps.log(`Starter model: ${file} (${progress})`);
        },
      });
      await registry.scan();
      deps.log(`Starter ready; downloading ${DEFAULT_REPO_ID} in the background for the next start.`);
      recommended = DEFAULT_REPO_ID;
      candidates = supported();
    }
    signal?.throwIfAborted();
    const machine = deps.machine();
    const assessments = new Map<string, { full: boolean; coexist: boolean }>();
    for (const model of candidates) assessments.set(model.repoId, await deps.assess(model, machine));
    const chosen = chooseAutoModel(candidates, DEFAULT_REPO_ID,
      model => assessments.get(model.repoId)?.full ?? false,
      model => assessments.get(model.repoId)?.coexist ?? false);
    if (!chosen) throw new Error("No downloaded supported model fits this machine — pick one explicitly (mlx-bun ls).");
    return { m: chosen, picked: true, ...(recommended ? { recommended } : {}) };
  } finally { registry.close(); }
}
