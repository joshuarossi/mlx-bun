import type { JobStore } from "../jobs";

export interface AdminRouteDeps {
  ensureJobs(): Promise<JobStore>;
  invalidateLibrary(): void;
}

export type AdminRoute =
  | { kind: "hf-token-get" }
  | { kind: "hf-token-set" }
  | { kind: "tool-approvals-get" }
  | { kind: "tool-approvals-delete" }
  | { kind: "push"; artifactKind: "quantize" | "finetune" | "dataset" }
  | { kind: "gc-plan" }
  | { kind: "gc-execute" }
  | { kind: "jobs-list" }
  | { kind: "job-get"; jobId: string; stream: boolean };

export function matchAdminRoute(method: string, pathname: string): AdminRoute | null {
  switch (`${method} ${pathname}`) {
    case "GET /api/settings/hf-token": return { kind: "hf-token-get" };
    case "POST /api/settings/hf-token": return { kind: "hf-token-set" };
    case "GET /api/settings/tool-approvals": return { kind: "tool-approvals-get" };
    case "DELETE /api/settings/tool-approvals": return { kind: "tool-approvals-delete" };
    case "GET /api/gc/plan": return { kind: "gc-plan" };
    case "POST /api/gc/execute": return { kind: "gc-execute" };
    case "GET /api/jobs": return { kind: "jobs-list" };
  }

  if (method === "POST") {
    const push = pathname.match(/^\/api\/(quantize|finetune|dataset)\/push$/);
    if (push) {
      return {
        kind: "push",
        artifactKind: push[1] as "quantize" | "finetune" | "dataset",
      };
    }
  }

  if (method === "GET") {
    const job = pathname.match(/^\/api\/jobs\/([^/]+?)(\/stream)?$/);
    if (job) {
      return {
        kind: "job-get",
        jobId: job[1]!,
        stream: !!job[2],
      };
    }
  }

  return null;
}

export async function handleAdminRoute(
  url: URL,
  request: Request,
  deps: AdminRouteDeps,
): Promise<Response | null> {
  const route = matchAdminRoute(request.method, url.pathname);
  if (!route) return null;

  switch (route.kind) {
    case "hf-token-get": {
      const { hasHfToken } = await import("../hf-push");
      return Response.json({ ok: true, hasToken: hasHfToken() });
    }
    case "hf-token-set": {
      const body = (await request.json().catch(() => ({}))) as { token?: string };
      if (!body.token)
        return Response.json({ ok: false, error: "token required" }, { status: 400 });
      const { saveHfToken } = await import("../hf-push");
      saveHfToken(body.token);
      return Response.json({ ok: true });
    }
    case "tool-approvals-get": {
      const { listAlwaysAllowedTools } = await import("../tool-approvals");
      return Response.json({ ok: true, alwaysAllow: listAlwaysAllowedTools() });
    }
    case "tool-approvals-delete": {
      const body = (await request.json().catch(() => ({}))) as { tool?: string };
      if (!body.tool)
        return Response.json({ ok: false, error: "tool required" }, { status: 400 });
      const { revokeToolAlwaysAllowed } = await import("../tool-approvals");
      const file = revokeToolAlwaysAllowed(body.tool);
      return Response.json({ ok: true, alwaysAllow: Object.keys(file.allows).sort() });
    }
    case "push": {
      const body = (await request.json().catch(() => ({}))) as {
        job_id?: string;
        repo_id?: string;
        private?: boolean;
        source_path?: string;
      };
      if (!body.repo_id)
        return Response.json({ ok: false, error: "repo_id required" }, { status: 400 });
      const { getHfToken, uploadFolder } = await import("../hf-push");
      const token = getHfToken();
      if (!token) {
        return Response.json(
          { ok: false, error: "no HF token saved — add one in Settings → Hugging Face" },
          { status: 400 },
        );
      }
      const store = await deps.ensureJobs();
      let dir = body.source_path;
      if (!dir && body.job_id) dir = store.get(body.job_id)?.output_path ?? undefined;
      if (!dir) {
        return Response.json(
          { ok: false, error: "no source dir (pass job_id or source_path)" },
          { status: 400 },
        );
      }
      try {
        const result = await uploadFolder(dir, body.repo_id, {
          repoType: route.artifactKind === "dataset" ? "dataset" : "model",
          private: !!body.private,
          token,
        });
        return Response.json({ ok: true, url: result.url });
      } catch (error) {
        return Response.json({ ok: false, error: (error as Error).message }, { status: 400 });
      }
    }
    case "gc-plan": {
      const { planGc } = await import("../registry");
      const plans = planGc().filter(
        (plan) => plan.pruneSnapshots.length || plan.skippedSnapshots.length || plan.deadBlobs.length,
      );
      const superseded = plans.map((plan) => ({
        repo_id: plan.repoId,
        prune_snapshots: plan.pruneSnapshots.length,
        skipped_snapshots: plan.skippedSnapshots.length,
        dead_blobs: plan.deadBlobs.length,
        reclaim_bytes: plan.reclaimBytes,
      }));
      const reclaim_bytes = plans.reduce((total, plan) => total + plan.reclaimBytes, 0);
      return Response.json({ ok: true, superseded, reclaim_bytes });
    }
    case "gc-execute": {
      const body = (await request.json().catch(() => ({}))) as { yes?: boolean };
      if (body.yes !== true) {
        return Response.json(
          { ok: false, error: "pass {\"yes\": true} to confirm deletion" },
          { status: 400 },
        );
      }
      const { planGc, executeGc, Registry } = await import("../registry");
      const plans = planGc().filter(
        (plan) => plan.pruneSnapshots.length || plan.skippedSnapshots.length || plan.deadBlobs.length,
      );
      const result = executeGc(plans);
      const registry = new Registry();
      try {
        await registry.scan();
      } finally {
        registry.close();
      }
      deps.invalidateLibrary();
      return Response.json({
        ok: true,
        snapshots: result.snapshots,
        blobs: result.blobs,
        reclaimed_bytes: result.reclaimedBytes,
      });
    }
    case "jobs-list": {
      const store = await deps.ensureJobs();
      const limit = Number(url.searchParams.get("limit") ?? "50");
      const kind = url.searchParams.get("kind") ?? undefined;
      return Response.json({ ok: true, jobs: store.recent(limit, kind) });
    }
    case "job-get": {
      const store = await deps.ensureJobs();
      if (route.stream) {
        const { streamJobResponse } = await import("../jobs");
        return streamJobResponse(store, route.jobId);
      }
      const job = store.get(route.jobId);
      if (!job)
        return Response.json({ ok: false, error: "job not found" }, { status: 404 });
      return Response.json({ ok: true, job });
    }
  }
}
