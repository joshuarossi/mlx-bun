// Loading the installed modules (`src/modules.ts`) over a host's core services
// (`@mlx-bun/app-services`); the serve composition supplies the generation
// gateway's execution lock so decoding never overlaps chat.
import type { LoadedModules } from "@mlx-bun/app-host";
import { activateModules, type HostServices } from "@mlx-bun/app-services";
import { installedModules } from "../modules";

export async function loadInstalledModules(host: Pick<HostServices, "bindings">): Promise<LoadedModules> {
  return activateModules(await installedModules(), host);
}
