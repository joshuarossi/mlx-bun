// The local models a host may load, by exact id, read from a source that lists
// them (the registry). A miss refreshes the listing at most every few seconds,
// so a model fetched from another shell becomes routable without a restart, and
// naming a model that does not exist never rescans on every request.
import type { ModelRecord } from "@mlx-bun/hub/registry";

export interface RecordIndex {
  /** Exact id only; the startup model is answered even when the listing does not know it (a path given to `--model`). */
  find(id: string): Promise<ModelRecord | undefined>;
  /** Forget the listing: a download or job finished. */
  invalidate(): void;
}

export function createRecordIndex(list: () => readonly ModelRecord[] | Promise<readonly ModelRecord[]>, startup?: ModelRecord, refreshMs = 5_000): RecordIndex {
  let index: { at: number; byId: Map<string, ModelRecord> } | undefined;
  return {
    async find(id) {
      if (startup && id === startup.repoId) return startup;
      for (const fresh of [false, true]) {
        if (!index || fresh && Date.now() - index.at > refreshMs) index = { at: Date.now(), byId: new Map((await list()).map(record => [record.repoId, record])) };
        const record = index.byId.get(id);
        if (record) return record;
      }
      return undefined;
    },
    invalidate() { index = undefined; },
  };
}
