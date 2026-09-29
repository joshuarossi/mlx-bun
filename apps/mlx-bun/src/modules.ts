import type { AppModule } from "@mlx-bun/app-core";
import { manifest as datasets } from "@mlx-bun/module-datasets/manifest";
import { manifest as metrics } from "@mlx-bun/module-metrics/manifest";
import { manifest as transcription } from "@mlx-bun/module-transcription/manifest";

// The one file that names module packages: import each `@mlx-bun/module-<id>`
// here and list it, and add it to package.json's dependencies. Order is
// activation order. The manifests are plain data, so the command list, `--help`
// and argument parsing read them without loading a module; a module's code
// loads only when a host activates it.
export const manifests: readonly Omit<AppModule, "activate">[] = [transcription, datasets, metrics];

/** Where a module activates: `state` is the app's persistent services (job runners, storage,
 * the served model's wire: modules that require `jobs`), `model` the model host's (Whisper
 * leases, the catalog) and the CLI verbs. */
export type ModuleScope = "state" | "model";

/** The installed modules of a scope, in activation order. */
export async function installedModules(scope: ModuleScope = "model"): Promise<readonly AppModule[]> {
  const all: readonly AppModule[] = [(await import("@mlx-bun/module-transcription")).default, (await import("@mlx-bun/module-datasets")).default,
    (await import("@mlx-bun/module-metrics")).default];
  return all.filter(module => module.requires.includes("jobs") === (scope === "state"));
}
