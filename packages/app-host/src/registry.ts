import type { ExtensionPointId, Registration, Registry, Unsubscribe } from "@mlx-bun/app-core";

/** The host's registry service: one store, a scoped view per module. */
export interface RegistryHost {
  /** What a module receives. `register` accepts only the points the module declared in `contributes`. */
  scoped(moduleId: string, contributes: readonly ExtensionPointId[]): Registry;
  /** Drops every registration a module made; listeners are told once per affected point. */
  removeSource(moduleId: string): void;
  /** The host's own read view, for a shell that lists nav entries or settings. */
  readonly reader: Pick<Registry, "list" | "onChange">;
}

export function createRegistry(): RegistryHost {
  const entries: Registration[] = [];
  const listeners = new Map<ExtensionPointId, Set<() => void>>();
  const notify = (point: ExtensionPointId) => {
    for (const handler of [...listeners.get(point) ?? []]) {
      try { handler(); } catch { /* a listener never breaks the registrant */ }
    }
  };
  const list = <P extends ExtensionPointId>(point: P) =>
    entries.filter((entry): entry is Registration<P> => entry.point === point);
  const onChange = (point: ExtensionPointId, handler: () => void): Unsubscribe => {
    const set = listeners.get(point) ?? new Set();
    listeners.set(point, set);
    set.add(handler);
    return () => { set.delete(handler); };
  };
  return {
    reader: { list, onChange },
    scoped(moduleId, contributes) {
      return {
        list,
        onChange,
        register(point, contribution) {
          if (!contributes.includes(point))
            throw new Error(`module ${moduleId} did not declare "${point}" in contributes`);
          const entry: Registration = { point, source: moduleId, contribution };
          entries.push(entry);
          notify(point);
          return () => {
            const at = entries.indexOf(entry);
            if (at < 0) return;
            entries.splice(at, 1);
            notify(point);
          };
        },
      };
    },
    removeSource(moduleId) {
      const points = new Set<ExtensionPointId>();
      for (let at = entries.length - 1; at >= 0; at--) {
        if (entries[at]!.source !== moduleId) continue;
        points.add(entries[at]!.point);
        entries.splice(at, 1);
      }
      for (const point of points) notify(point);
    },
  };
}
