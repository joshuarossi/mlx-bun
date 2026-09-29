import { basename, resolve } from "node:path";
import type { CatalogEntry, ModelCatalog } from "@mlx-bun/app-core";

/** A model's short name for derived output directories: the repo name of an
 * `org/name` id or a hub snapshot path, else the directory's basename. */
export function modelShortName(model: string): string {
  const snapshot = /models--[^/]+?--([^/]+)\/snapshots\//.exec(model);
  const name = snapshot ? snapshot[1]! : basename(model.replace(/\/+$/, ""));
  return name.replace(/[^\w.-]/g, "") || "model";
}

/** The model a verb runs on: its directory and the id it prints (the repo id of a hub snapshot path, else the directory's name). */
export interface SelectedModel { path: string; repoId: string }

const selected = (entry: CatalogEntry): SelectedModel => {
  // A directory given as a path is its own catalog id; name it as the hub cache or its folder does.
  if (entry.id !== entry.directory) return { path: entry.directory, repoId: entry.id };
  const directory = resolve(entry.directory);
  const hub = /models--([^/]+)--([^/]+)\/snapshots\//.exec(directory);
  return { path: directory, repoId: hub ? `${hub[1]}/${hub[2]}` : basename(directory) };
};

/** A query names a model directory or a downloaded model (never downloads); none picks the host's automatic choice. */
export async function selectModel(catalog: Pick<ModelCatalog, "find" | "pickDefault">, query: string | null,
  signal?: AbortSignal): Promise<{ m: SelectedModel; picked: boolean }> {
  if (query) return { m: selected(await catalog.find(query)), picked: false };
  return { m: selected(await catalog.pickDefault(signal ? { signal } : {})), picked: true };
}
