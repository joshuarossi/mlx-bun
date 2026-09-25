import { readSessionFile, sessionEntries } from "../chat/session-files";
import { searchSessions } from "../chat/session-search";

/** Borrows the same explicit session directory passed to the Pi backend. */
export function createSessionRoutes(sessionDir: string) {
  const error = (message: string, status = 400) => Response.json({ ok: false, error: message }, { status });
  return { async handle(request: Request): Promise<Response | null> {
    const url = new URL(request.url);
    if (request.method !== "GET") return null;
    if (url.pathname === "/api/sessions/search") {
      const query = (url.searchParams.get("q") ?? "").trim();
      if (!query) return error("q is required");
      return Response.json({ ok: true, results: await searchSessions(sessionDir, query) });
    }
    if (url.pathname === "/api/sessions/export") {
      const path = (url.searchParams.get("path") ?? "").trim();
      if (!path) return error("path is required");
      const file = await readSessionFile(sessionDir, path);
      if (!file.ok) return file.reason === "forbidden"
        ? error("path must be under the session directory", 403) : error("session not found", 404);
      return Response.json({ ok: true, path, entries: sessionEntries(file.content) });
    }
    return null;
  } };
}
