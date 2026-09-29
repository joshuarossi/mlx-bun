import type { AppModule } from "@mlx-bun/app-core";
import { manifest as transcription } from "@mlx-bun/module-transcription/manifest";

// The one file that names module packages. This host installs one: no chat,
// models, training or memory module is in its import closure. The manifests are
// plain data, so the command list and `--help` read them without loading a
// module; its code loads only when the host activates it.
export const manifests: readonly Omit<AppModule, "activate">[] = [transcription];

/** The installed modules, in activation order. */
export async function installedModules(): Promise<readonly AppModule[]> {
  return [(await import("@mlx-bun/module-transcription")).default];
}
