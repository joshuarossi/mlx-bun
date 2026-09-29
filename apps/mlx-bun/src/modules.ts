import type { AppModule } from "@mlx-bun/app-core";
import { manifest as transcription } from "@mlx-bun/module-transcription/manifest";

// The one file that names module packages: import each `@mlx-bun/module-<id>`
// here and list it, and add it to package.json's dependencies. Order is
// activation order. The manifests are plain data, so the command list, `--help`
// and argument parsing read them without loading a module; a module's code
// loads only when a host activates it.
export const manifests: readonly Omit<AppModule, "activate">[] = [transcription];

/** The installed modules, in activation order. */
export async function installedModules(): Promise<readonly AppModule[]> {
  return [(await import("@mlx-bun/module-transcription")).default];
}
