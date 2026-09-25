import { existsSync } from "node:fs";
import { basename, join, resolve } from "node:path";
import { Registry, scanSnapshot, type ModelRecord } from "@mlx-bun/hub/registry";
import { downloadModel } from "@mlx-bun/hub/download";
import { fit, thisMachine, type MachineSpec } from "@mlx-bun/hub/fit";
import { loadModelConfig } from "@mlx-bun/inference/artifacts/config";
import { isSupportedModelRecord } from "@mlx-bun/inference/models/support";

// Application choices, not hub policy: discovery and fit remain reusable libraries.
export const DEFAULT_REPO_ID = "mlx-community/gemma-4-e4b-it-OptiQ-4bit";
export const STARTER_REPO_ID = "mlx-community/MiniCPM5-1B-OptiQ-4bit";
export const COEXIST_FRACTION = 0.6;

/** Prefer e4b when it fits; otherwise retain room for other apps where possible.
 * Explicit model selection does not use these advisory fit predicates. */
export function chooseAutoModel<T extends { repoId: string; sizeBytes: number }>(
  candidates: readonly T[], preferredRepo: string,
  fitsFull: (candidate: T) => boolean, fitsCoexist: (candidate: T) => boolean,
): T | undefined {
  const preferred = candidates.find(candidate => candidate.repoId === preferredRepo);
  if (preferred && fitsFull(preferred)) return preferred;
  const largest = [...candidates].sort((a, b) => b.sizeBytes - a.sizeBytes);
  return largest.find(fitsCoexist) ?? largest.find(fitsFull);
}

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
  registry: () => new Registry(), scanSnapshot, download: downloadModel, machine: thisMachine,
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
    const supported = () => registry.list().filter(model => isSupportedModelRecord(model.modelType, model.repoId));
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

/** The default Whisper companion: the first downloaded `whisper` checkpoint
 * (scanning an empty index), or null when none is on disk. Resolved lazily on
 * the first audio request, as in main, so a chat-only serve never scans for it. */
export async function defaultWhisperModel(registry: () => Pick<Registry, "list" | "listCanonical" | "scan" | "close"> = () => new Registry()): Promise<ModelRecord | null> {
  const open = registry();
  try {
    if (open.list().length === 0) await open.scan();
    return open.listCanonical().find(model => model.modelType === "whisper") ?? null;
  } catch {
    return null;
  } finally { open.close(); }
}
