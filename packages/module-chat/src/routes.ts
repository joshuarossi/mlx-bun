// The module's HTTP routes: the read-only session surface (search and export over the session
// directory) and the durable tool-approval settings. Paths are resolved per request, so a host
// creates storage entries on first use, not at startup.
import type { RouteHandler } from "@mlx-bun/app-core";
import { readSessionFile, sessionEntries } from "./session-files";
import { searchSessions } from "./session-search";
import { listAlwaysAllowedTools, revokeToolAlwaysAllowed } from "./tool-approvals";

const error = (message: string, status = 400) => Response.json({ ok: false, error: message }, { status });

export interface ChatRoutePaths {
  /** The session directory the Pi backend persists to. */
  sessionDir(): string;
  /** The always-allow file the approval gate reads. */
  approvalsFile(): string;
}

/** Handlers by route id (`manifest.routes`). */
export function createChatHandlers(paths: ChatRoutePaths): Record<"sessions-search" | "sessions-export" | "approvals" | "approvals-revoke", RouteHandler> {
  const guarded = (handler: RouteHandler): RouteHandler => async request => {
    try { return await handler(request); } catch (cause) {
      console.error(`[chat] ${request.method} ${new URL(request.url).pathname}: ${cause instanceof Error ? cause.message : String(cause)}`);
      return error(cause instanceof Error ? cause.message : String(cause), 500);
    }
  };
  return {
    "sessions-search": guarded(async request => {
      const query = (new URL(request.url).searchParams.get("q") ?? "").trim();
      if (!query) return error("q is required");
      return Response.json({ ok: true, results: await searchSessions(paths.sessionDir(), query) });
    }),
    "sessions-export": guarded(async request => {
      const path = (new URL(request.url).searchParams.get("path") ?? "").trim();
      if (!path) return error("path is required");
      const file = await readSessionFile(paths.sessionDir(), path);
      if (!file.ok) return file.reason === "forbidden"
        ? error("path must be under the session directory", 403) : error("session not found", 404);
      return Response.json({ ok: true, path, entries: sessionEntries(file.content) });
    }),
    approvals: guarded(() => Response.json({ ok: true, alwaysAllow: listAlwaysAllowedTools(paths.approvalsFile()) })),
    "approvals-revoke": guarded(async request => {
      const body: unknown = await request.json().catch(() => undefined);
      const tool = body && typeof body === "object" && !Array.isArray(body) && "tool" in body ? body.tool : undefined;
      if (typeof tool !== "string" || !tool) return error("tool required");
      const file = revokeToolAlwaysAllowed(tool, paths.approvalsFile());
      return Response.json({ ok: true, alwaysAllow: Object.keys(file.allows).sort() });
    }),
  };
}
