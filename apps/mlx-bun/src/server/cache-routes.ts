import type { createCacheServices } from "../engine/cache-services";
import { errorResponse } from "./http";

type CacheServices = Awaited<ReturnType<typeof createCacheServices>>;

export interface CacheRouteServices {
  promptCache: Pick<CacheServices["promptCache"], "closeSession">;
  flush: CacheServices["flush"];
  checkpoints: Pick<NonNullable<CacheServices["checkpoints"]>, "entries" | "longestDurablePrefixTokens"> | null;
}

/** Administrative HTTP policy over the app's cache services, preserving main's
 * `/admin/cache/*` wire contract. Both routes borrow the services: no execution
 * lease is taken, a session close never waits for a flush in progress, and a
 * close neither deletes checkpoints nor rejects an unknown session. */
export function createCacheRoutes(caches: CacheRouteServices) {
  return { async handle(request: Request): Promise<Response | null> {
    const route = `${request.method} ${new URL(request.url).pathname}`;
    if (route !== "POST /admin/cache/session/close" && route !== "POST /admin/cache/flush") return null;
    try {
      if (route === "POST /admin/cache/session/close") {
        let body: unknown;
        try {
          const text = await request.text();
          body = text.trim() ? JSON.parse(text) : {};
        } catch (error) {
          if (request.signal.aborted) return errorResponse(error, route, undefined, request.signal);
          return Response.json({ error: { message: "invalid JSON body" } }, { status: 400 });
        }
        const id = body && typeof body === "object" && !Array.isArray(body) && "session_id" in body ? body.session_id : undefined;
        if (typeof id === "string") caches.promptCache.closeSession(id);
        return Response.json({ closed: typeof id === "string" });
      }
      const result = await caches.flush();
      return Response.json({ ...result, entries: caches.checkpoints?.entries ?? 0,
        longest_durable_prefix_tokens: caches.checkpoints?.longestDurablePrefixTokens ?? 0 },
        { status: result.durable ? 200 : 503 });
    } catch (error) { return errorResponse(error, route, undefined, request.signal); }
  } };
}
