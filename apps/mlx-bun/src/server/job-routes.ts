import type { JobStore } from "../jobs/db";
import { streamJobResponse } from "../jobs/sse";

export function createJobRoutes(host: { ensureStore(): JobStore; signal: AbortSignal }) {
  return { async handle(request: Request): Promise<Response | null> {
    const url = new URL(request.url);
    if (request.method !== "GET") return null;
    if (url.pathname === "/api/jobs") {
      const limit = Number(url.searchParams.get("limit") ?? "50");
      const kind = url.searchParams.get("kind") ?? undefined;
      return Response.json({ ok: true, jobs: host.ensureStore().recent(limit, kind) });
    }
    const match = url.pathname.match(/^\/api\/jobs\/([^/]+?)(\/stream)?$/);
    if (!match) return null;
    const store = host.ensureStore(), jobId = match[1]!;
    if (match[2]) return streamJobResponse(store, jobId, AbortSignal.any([host.signal, request.signal]));
    const job = store.get(jobId);
    return job ? Response.json({ ok: true, job }) : Response.json({ ok: false, error: "job not found" }, { status: 404 });
  } };
}
