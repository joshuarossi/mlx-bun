import type { AppModule, CliInvocation, CliVerbHandler, ModuleRuntime, RouteHandler } from "@mlx-bun/app-core";
import { createAdapterHandlers, type AdapterOptions } from "./adapters";
import { createFolderHandler } from "./folder";
import { createGcHandlers, type GcOptions } from "./gc";
import { createHubHandlers, type HubOptions } from "./hub";
import { createLibraryHandlers } from "./library";
import { manifest } from "./manifest";
import type { UploadDependencies } from "./verbs/upload";

export { manifest } from "./manifest";
export { createAdapterHandlers } from "./adapters";
export type { AdapterOptions } from "./adapters";
export { createFolderHandler } from "./folder";
export { createGcHandlers } from "./gc";
export type { GcOptions } from "./gc";
export { createHubHandlers } from "./hub";
export type { HubOptions } from "./hub";
export { createLibraryHandlers } from "./library";
export type * from "./protocol";
export { runGet } from "./verbs/get";
export { runGc } from "./verbs/gc";
export { runLs } from "./verbs/ls";
export { runScan } from "./verbs/scan";
export { runUpload, UPLOAD_USAGE } from "./verbs/upload";
export type { UploadDependencies } from "./verbs/upload";

type Services = "catalog" | "modelHost" | "storage" | "events";

/** Test seams: Hub search's transport and token, the cache directory cleanup reads, the export writer and the upload verb's file check. */
export interface ModelsModuleOptions {
  hub?: HubOptions;
  gc?: GcOptions;
  adapters?: AdapterOptions;
  upload?: Partial<UploadDependencies>;
  now?: () => number;
}

/** The models module. The host implements `catalog` (the local index, downloads, the Hub's publisher), `modelHost` (which model is served and the switch; a lease's `adapters` operation), `storage` (the `adapters` and `exports` entries) and `events` (`catalog.changed` drops the library's cached rows). */
export function createModelsModule(options: ModelsModuleOptions = {}): AppModule<Services> {
  return {
    ...manifest,
    activate({ services }): ModuleRuntime {
      const { catalog, modelHost, storage, events } = services;
      const library = createLibraryHandlers({ catalog, modelHost, events }, options.now);
      const handlers = { ...createHubHandlers({ catalog, modelHost }, options.hub), ...library.handlers, "resolve-folder": createFolderHandler(catalog),
        ...createGcHandlers({ catalog, modelHost }, options.gc), ...createAdapterHandlers({ catalog, modelHost, storage }, options.adapters) } as Record<(typeof manifest.routes)[number]["id"], RouteHandler>;
      // The verbs load on use, so a host that serves the routes never loads their terminal and fit code.
      const verb = (load: () => Promise<(invocation: CliInvocation) => Promise<number>>): CliVerbHandler => async invocation => (await load())(invocation);
      const verbs: Record<(typeof manifest.verbs)[number]["name"], CliVerbHandler> = {
        get: verb(async () => { const { runGet } = await import("./verbs/get"); return invocation => runGet(invocation, catalog); }),
        ls: verb(async () => { const { runLs } = await import("./verbs/ls"); return invocation => runLs(invocation, catalog); }),
        scan: verb(async () => { const { runScan } = await import("./verbs/scan"); return invocation => runScan(invocation, catalog); }),
        fit: verb(async () => { const { runFit } = await import("./verbs/fit"); return invocation => runFit(invocation, catalog); }),
        gc: verb(async () => { const { runGc } = await import("./verbs/gc"); return invocation => runGc(invocation, catalog); }),
        upload: verb(async () => { const { runUpload } = await import("./verbs/upload"); return invocation => runUpload(invocation, catalog, options.upload); }),
      };
      return { routes: handlers, verbs, dispose: library.stop };
    },
  };
}

export default createModelsModule();
