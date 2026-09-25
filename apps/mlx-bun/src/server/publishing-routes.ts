import type { createHfCredentials } from "../publishing/credentials";
import type { createPublisher, PublishRequest } from "../publishing/upload";

/** HTTP parsing and wire errors stay above credential and publishing policy. */
export function createPublishingRoutes(options: {
  credentials: ReturnType<typeof createHfCredentials>;
  publish: ReturnType<typeof createPublisher>;
}) {
  const error = (message: string, status = 400) => Response.json({ ok: false, error: message }, { status });
  return { async handle(request: Request): Promise<Response | null> {
    const path = new URL(request.url).pathname;
    const settings = path === "/api/settings/hf-token";
    const push = path.match(/^\/api\/(quantize|finetune|dataset)\/push$/);
    if (!(settings && ["GET", "POST"].includes(request.method)) && !(push && request.method === "POST")) return null;
    try {
      request.signal.throwIfAborted();
      if (settings && request.method === "GET") return Response.json({ ok: true, hasToken: options.credentials.get() !== null });
      const raw: unknown = await request.json().catch(() => null);
      request.signal.throwIfAborted();
      if (!raw || typeof raw !== "object" || Array.isArray(raw)) return error("expected a JSON object");
      const body = raw as Record<string, unknown>;
      if (settings) {
        if (typeof body.token !== "string" || !body.token.trim()) return error("token required");
        options.credentials.save(body.token);
        return Response.json({ ok: true });
      }
      if (typeof body.repo_id !== "string" || !body.repo_id.trim()) return error("repo_id required");
      for (const key of ["job_id", "source_path"] as const) {
        if (body[key] != null && (typeof body[key] !== "string" || !body[key].trim())) return error(`${key} must be a nonempty string`);
      }
      if (body.private != null && typeof body.private !== "boolean") return error("private must be a boolean");
      const result = await options.publish({ kind: push![1] as PublishRequest["kind"], repoId: body.repo_id,
        private: body.private as boolean | undefined, sourcePath: body.source_path as string | undefined,
        jobId: body.job_id as string | undefined });
      return Response.json({ ok: true, url: result.url });
    } catch (failure) {
      if (request.signal.aborted) return error("Request cancelled", 499);
      return error(failure instanceof Error ? failure.message : String(failure));
    }
  } };
}
