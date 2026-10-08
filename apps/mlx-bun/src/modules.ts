import type { MemoryModuleOptions } from "@mlx-bun/module-memory";
import type { AppModule } from "@mlx-bun/app-core";
import { manifest as benchmarks } from "@mlx-bun/module-benchmarks/manifest";
import { manifest as chat } from "@mlx-bun/module-chat/manifest";
import { manifest as datasets } from "@mlx-bun/module-datasets/manifest";
import { manifest as memory } from "@mlx-bun/module-memory/manifest";
import { manifest as metrics } from "@mlx-bun/module-metrics/manifest";
import { manifest as models } from "@mlx-bun/module-models/manifest";
import { manifest as quantize } from "@mlx-bun/module-quantize/manifest";
import { manifest as train } from "@mlx-bun/module-train/manifest";
import { manifest as transcription } from "@mlx-bun/module-transcription/manifest";

// The one file that names module packages: import each `@mlx-bun/module-<id>`
// here and list it, and add it to package.json's dependencies. Order is
// activation order. The manifests are plain data, so the command list, `--help`
// and argument parsing read them without loading a module; a module's code
// loads only when a host activates it.
export const manifests: readonly Omit<AppModule, "activate">[] = [transcription, datasets, metrics, quantize, benchmarks, train, models, chat, memory];

/** Where a module activates: `state` is the app's persistent services (job runners, sockets, storage, the served
 * model's wire: modules that require `jobs` or declare sockets), `model` the model host's (Whisper leases, the
 * catalog). A CLI verb's host names its verb's module instead: a selection by manifest. */
export type ModuleScope = "state" | "model";

/** What the app decides for a module beyond its services: the chat's read-only policy and working directory. */
export interface ModuleSettings {
  memory?: MemoryModuleOptions;
  chat?: { readOnly?: boolean; cwd?: string };
}

/** Each module's code, loaded on demand by id. */
const loaders: Record<string, (settings: ModuleSettings) => Promise<AppModule>> = {
  transcription: async () => (await import("@mlx-bun/module-transcription")).default,
  datasets: async () => (await import("@mlx-bun/module-datasets")).default,
  metrics: async () => (await import("@mlx-bun/module-metrics")).default,
  quantize: async () => (await import("@mlx-bun/module-quantize")).default,
  benchmarks: async () => (await import("@mlx-bun/module-benchmarks")).default,
  train: async () => (await import("@mlx-bun/module-train")).default,
  models: async () => (await import("@mlx-bun/module-models")).default,
  memory: async settings => (await import("@mlx-bun/module-memory")).createMemoryModule(settings.memory),
  chat: async settings => (await import("@mlx-bun/module-chat")).createChatModule(settings.chat),
};

/** The installed modules of a scope (or of a manifest selection), in activation order; a module's code loads only when selected. */
export async function installedModules(scope: ModuleScope | ((manifest: Omit<AppModule, "activate">) => boolean) = "model", settings: ModuleSettings = {}): Promise<readonly AppModule[]> {
  const select = typeof scope === "function" ? scope
    : (manifest: Omit<AppModule, "activate">) => (manifest.placement ?? (manifest.requires.includes("jobs") || (manifest.sockets?.length ?? 0) > 0 ? "app" : "model")) === (scope === "state" ? "app" : "model");
  return Promise.all(manifests.filter(select).map(manifest => loaders[manifest.id]!(settings)));
}

// Narrow public contracts and adapters used by this host's composition; module dependencies stay centralized here.
export { runMemory as runModuleMemory } from "@mlx-bun/module-memory/cli";
export type { MemoryDependencies, CommandArgs as MemoryCommandArgs } from "@mlx-bun/module-memory/cli";
export { MEMORY_TASK_MODEL, adapterDirFor, locateTaskModel, memoryBatchSize, memoryPromptIds } from "@mlx-bun/module-memory/model";
export type { MemoryCompletionClient, MemoryCompletionRequest } from "@mlx-bun/module-memory/model";
export type { SynthesisClient } from "@mlx-bun/module-memory/synthesis";
export { vaultRoot } from "@mlx-bun/module-memory/vault";
export { memory as memoryManifest };
