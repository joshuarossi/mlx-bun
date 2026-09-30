// Hub cache cleanup: what superseded snapshots and dead blobs would give back, and deleting them. The plan is always
// recomputed from disk at execution time, never taken from the client, and never touches a snapshot a resident model reads.
import { realpathSync } from "node:fs";
import { resolve, sep } from "node:path";
import type { ModelCatalog, ModelHost, RouteHandler } from "@mlx-bun/app-core";
import { executeGc, planGc } from "@mlx-bun/hub/registry";
import { failure, jsonError, objectBody } from "./http";

export interface GcOptions {
  /** The Hub cache to clean; default the library's own resolution. */
  hubDirectory?: string;
}

const canonicalPath = (path: string) => { try { return realpathSync(path); } catch { return resolve(path); } };

export function createGcHandlers(services: { catalog: Pick<ModelCatalog, "rescan" | "resolve">; modelHost: Pick<ModelHost, "resident"> },
  options: GcOptions = {}): Record<"gc-plan" | "gc-execute", RouteHandler> {
  const plans = () => planGc(options.hubDirectory).filter(plan => plan.pruneSnapshots.length || plan.skippedSnapshots.length || plan.deadBlobs.length);
  /** Every directory a resident model reads: the ones it names and the snapshot its id resolves to. */
  const inUse = async (): Promise<string[]> => {
    const paths: string[] = [];
    for (const model of services.modelHost.resident()) {
      paths.push(...(model.uses ?? []));
      if (!model.uses?.length) { const entry = await services.catalog.resolve(model.id); if (entry) paths.push(entry.directory); }
    }
    return paths.map(canonicalPath);
  };
  return {
    async "gc-plan"(request) {
      try {
        const listed = plans();
        return Response.json({ ok: true,
          superseded: listed.map(plan => ({ repo_id: plan.repoId, prune_snapshots: plan.pruneSnapshots.length,
            skipped_snapshots: plan.skippedSnapshots.length, dead_blobs: plan.deadBlobs.length, reclaim_bytes: plan.reclaimBytes })),
          reclaim_bytes: listed.reduce((total, plan) => total + plan.reclaimBytes, 0) });
      } catch (error) { return failure(error, "GET /api/gc/plan", request.signal); }
    },

    async "gc-execute"(request) {
      try {
        const body = await objectBody(request);
        if (!body || body.yes !== true) return jsonError('pass {"yes": true} to confirm deletion');
        // Recompute from disk at execution time; never accept a client-supplied deletion plan.
        const listed = plans();
        const served = await inUse();
        if (served.length && listed.some(plan => plan.pruneSnapshots.some(snapshot => {
          const candidate = canonicalPath(snapshot);
          return served.some(path => path === candidate || path.startsWith(candidate + sep));
        }))) return jsonError("GC would delete the active model snapshot. Serve another revision before cleaning this cache.", 409);
        // Even a partial deletion re-indexes, so the catalog never lists a snapshot that is gone.
        let result: ReturnType<typeof executeGc> | undefined, failed: { error: unknown } | undefined;
        try { result = executeGc(listed); } catch (error) { failed = { error }; }
        try { await services.catalog.rescan(); } catch (error) { failed ??= { error }; }
        if (failed) throw failed.error;
        return Response.json({ ok: true, snapshots: result!.snapshots, blobs: result!.blobs, reclaimed_bytes: result!.reclaimedBytes });
      } catch (error) { return failure(error, "POST /api/gc/execute", request.signal); }
    },
  };
}
