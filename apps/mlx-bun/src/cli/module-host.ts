// Loading the installed modules (`src/modules.ts`) over a host's core services
// (`@mlx-bun/app-services`); the serve composition supplies the generation
// gateway's execution lock so decoding never overlaps chat.
import type { LoadedModules } from "@mlx-bun/app-host";
import { activateModules, type HostServices } from "@mlx-bun/app-services";
import { installedModules, type ModuleScope } from "../modules";

/** Activate the installed modules of a scope (see `ModuleScope`) over the host's core services. */
export async function loadInstalledModules(host: Pick<HostServices, "bindings">, scope: ModuleScope = "model"): Promise<LoadedModules> {
  return activateModules(await installedModules(scope), host);
}
