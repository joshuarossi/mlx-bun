import type { AppEvent, AppModule, EventBus, ModuleRuntime, StorageService } from "@mlx-bun/app-core";
import type { ServiceBindings } from "@mlx-bun/app-host";

/** A manifest with nothing declared; each test adds the parts it checks. */
export function module(id: string, parts: Partial<AppModule> = {}, runtime: ModuleRuntime = {}): AppModule {
  return { id, title: id, summary: id, requires: [], activate: () => runtime, ...parts };
}

export function fakeEvents(): EventBus & { readonly published: AppEvent[] } {
  const published: AppEvent[] = [];
  return { published, publish: event => { published.push(event); }, subscribe: () => () => {} };
}

/** Services scoped per module, recording which module asked for each. */
export function fakeServices(asked: string[] = []): ServiceBindings {
  return {
    events: scope => { asked.push(`events:${scope.moduleId}`); return fakeEvents(); },
    storage: scope => {
      asked.push(`storage:${scope.moduleId}`);
      const service: StorageService = { path: key => {
        const entry = scope.manifest.storage?.find(item => item.key === key);
        if (!entry) throw new Error(`no storage entry ${key}`);
        return `/home/${entry.path}`;
      } };
      return service;
    },
  };
}
