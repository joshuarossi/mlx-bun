// The library: every local model with its fit on this machine and what is running. The rows (each needs a read of the
// model's config) are kept for 30 seconds and dropped whenever the catalog changes; a request can ask for a fresh read.
import type { EventBus, ModelCatalog, ModelHost, RouteHandler } from "@mlx-bun/app-core";
import type { LibraryRow } from "./protocol";
import { libraryRow } from "./rows";

const FRESH_MS = 30_000;

export interface LibraryHandlers {
  handlers: Record<"library" | "downloads", RouteHandler>;
  /** Stops following the catalog. */
  stop(): void;
}

export function createLibraryHandlers(services: { catalog: Pick<ModelCatalog, "list" | "downloads">; modelHost: Pick<ModelHost, "defaultFor" | "resident">; events: Pick<EventBus, "subscribe"> },
  now: () => number = Date.now): LibraryHandlers {
  const { catalog, modelHost } = services;
  let cached: { at: number; rows: Omit<LibraryRow, "serving" | "resident">[] } | undefined;
  const unsubscribe = services.events.subscribe(["catalog.changed"], () => { cached = undefined; });
  return {
    stop: unsubscribe,
    handlers: {
      async library(request) {
        if (new URL(request.url).searchParams.get("refresh") === "1" || !cached || now() - cached.at > FRESH_MS) {
          const rows = [];
          for (const entry of await catalog.list({ companions: true, refresh: true })) rows.push(await libraryRow(entry));
          cached = { at: now(), rows };
        }
        const serving = await modelHost.defaultFor("generate");
        const resident = new Set(modelHost.resident().filter(model => model.state === "ready").map(model => model.id));
        return Response.json({ models: cached.rows.map(row => ({ ...row, serving: row.repo_id === serving, resident: resident.has(row.repo_id) })) });
      },
      async downloads() { return Response.json({ downloads: catalog.downloads() }); },
    },
  };
}
