import { executeGc, planGc, Registry } from "@mlx-bun/hub/registry";
import { listAlwaysAllowedTools, revokeToolAlwaysAllowed } from "../chat/tool-approvals";

export interface ManagementRouteOptions {
  invalidateLibrary(): void;
  /** Share this path with PiBackendOptions.paths.toolApprovalsFile. */
  toolApprovalsFile?: string;
  /** Composition overrides for isolated storage; omitted paths use hub defaults. */
  hubDirectory?: string;
  createRegistry?: () => Pick<Registry, "scan" | "close">;
}

/** HTTP policy over chat approval storage and the public hub GC operations.
 * Each GC rescan owns and closes its registry; the discovery cache is borrowed. */
export function createManagementRoutes(options: ManagementRouteOptions) {
  const gcPlans = () => planGc(options.hubDirectory).filter(plan =>
    plan.pruneSnapshots.length || plan.skippedSnapshots.length || plan.deadBlobs.length);
  return { async handle(request: Request): Promise<Response | null> {
    const pathname = new URL(request.url).pathname;
    switch (`${request.method} ${pathname}`) {
      case "GET /api/settings/tool-approvals":
        return Response.json({ ok: true, alwaysAllow: listAlwaysAllowedTools(options.toolApprovalsFile) });
      case "DELETE /api/settings/tool-approvals": {
        const body: unknown = await request.json().catch(() => undefined);
        const tool = body && typeof body === "object" && !Array.isArray(body) && "tool" in body ? body.tool : undefined;
        if (typeof tool !== "string" || !tool)
          return Response.json({ ok: false, error: "tool required" }, { status: 400 });
        const file = revokeToolAlwaysAllowed(tool, options.toolApprovalsFile);
        return Response.json({ ok: true, alwaysAllow: Object.keys(file.allows).sort() });
      }
      case "GET /api/gc/plan": {
        const plans = gcPlans();
        const superseded = plans.map(plan => ({
          repo_id: plan.repoId, prune_snapshots: plan.pruneSnapshots.length,
          skipped_snapshots: plan.skippedSnapshots.length, dead_blobs: plan.deadBlobs.length,
          reclaim_bytes: plan.reclaimBytes,
        }));
        return Response.json({ ok: true, superseded,
          reclaim_bytes: plans.reduce((total, plan) => total + plan.reclaimBytes, 0) });
      }
      case "POST /api/gc/execute": {
        const body: unknown = await request.json().catch(() => undefined);
        if (!body || typeof body !== "object" || Array.isArray(body) || !("yes" in body) || body.yes !== true)
          return Response.json({ ok: false, error: 'pass {"yes": true} to confirm deletion' }, { status: 400 });
        // Recompute from disk at execution time; never accept a client-supplied
        // deletion plan. Even a partial failure must invalidate discovery.
        const plans = gcPlans();
        try {
          const result = executeGc(plans);
          const registry = options.createRegistry?.() ?? new Registry();
          try { await registry.scan(options.hubDirectory); }
          finally { registry.close(); }
          return Response.json({ ok: true, snapshots: result.snapshots,
            blobs: result.blobs, reclaimed_bytes: result.reclaimedBytes });
        } finally { options.invalidateLibrary(); }
      }
      default: return null;
    }
  } };
}
