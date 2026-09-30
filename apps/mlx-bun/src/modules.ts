import type { AppModule } from "@mlx-bun/app-core";
import { manifest as benchmarks } from "@mlx-bun/module-benchmarks/manifest";
import { manifest as datasets } from "@mlx-bun/module-datasets/manifest";
import { manifest as metrics } from "@mlx-bun/module-metrics/manifest";
import { manifest as quantize } from "@mlx-bun/module-quantize/manifest";
import { manifest as train } from "@mlx-bun/module-train/manifest";
import { manifest as transcription } from "@mlx-bun/module-transcription/manifest";

// The one file that names module packages: import each `@mlx-bun/module-<id>`
// here and list it, and add it to package.json's dependencies. Order is
// activation order. The manifests are plain data, so the command list, `--help`
// and argument parsing read them without loading a module; a module's code
// loads only when a host activates it.
export const manifests: readonly Omit<AppModule, "activate">[] = [transcription, datasets, metrics, quantize, benchmarks, train];

/** Where a module activates: `state` is the app's persistent services (job runners, storage,
 * the served model's wire: modules that require `jobs`), `model` the model host's (Whisper
 * leases, the catalog). A CLI verb's host names its verb's module instead: a selection by manifest. */
export type ModuleScope = "state" | "model";

/** Each module's code, loaded on demand by id. */
const loaders: Record<string, () => Promise<{ default: AppModule }>> = {
  transcription: () => import("@mlx-bun/module-transcription"),
  datasets: () => import("@mlx-bun/module-datasets"),
  metrics: () => import("@mlx-bun/module-metrics"),
  quantize: () => import("@mlx-bun/module-quantize"),
  benchmarks: () => import("@mlx-bun/module-benchmarks"),
  train: () => import("@mlx-bun/module-train"),
};

/** The installed modules of a scope (or of a manifest selection), in activation order; a module's code loads only when selected. */
export async function installedModules(scope: ModuleScope | ((manifest: Omit<AppModule, "activate">) => boolean) = "model"): Promise<readonly AppModule[]> {
  const select = typeof scope === "function" ? scope : (manifest: Omit<AppModule, "activate">) => manifest.requires.includes("jobs") === (scope === "state");
  return Promise.all(manifests.filter(select).map(async manifest => (await loaders[manifest.id]!()).default));
}
