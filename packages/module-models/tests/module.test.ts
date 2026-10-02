// The module as a host loads it: a valid manifest over catalog, modelHost, storage and events; every route and verb
// mounted from the manifest at the paths it has always had; the library's cache following the catalog and stopping with the module.
import { afterEach, beforeEach, expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { checkManifests, loadModules } from "@mlx-bun/app-host";
import { createModuleRoutes, createStorage } from "@mlx-bun/app-services";
import models, { createModelsModule } from "../src";
import { manifest } from "../src/manifest";
import { entry, fakeCatalog, fakeHost, request, syncEvents } from "./support";

let home: string;
beforeEach(() => { home = mkdtempSync(join(tmpdir(), "models-module-")); });
afterEach(() => { rmSync(home, { recursive: true, force: true }); });

async function host(options: Parameters<typeof createModelsModule>[0] = {}, listed = [entry("org/a")]) {
  const events = syncEvents();
  let lists = 0;
  const catalog = fakeCatalog(listed, { async list() { lists++; return listed; } });
  const loaded = await loadModules([createModelsModule(options)], { services: { storage: createStorage(() => home), catalog: () => catalog, modelHost: () => fakeHost(), events: () => events } });
  return { loaded, events, lists: () => lists, send: async (path: string, init?: RequestInit) => (await createModuleRoutes(loaded.routes).handle(request(path, init)))! };
}

test("the manifest is valid for a host that implements catalog, modelHost, storage and events, and needs nothing else", () => {
  expect(models.requires).toEqual(["catalog", "modelHost", "storage", "events"]);
  const provided = ["catalog", "modelHost", "storage", "events"] as const;
  expect(checkManifests([models], { provided })).toEqual([]);
  expect(checkManifests([models], { provided: ["catalog", "modelHost", "storage"] })).toEqual(['module "models": requires "events", which this host does not implement']);
  // It runs beside the serving host's residency, not in a model's process.
  expect(models.placement).toBe("app");
  expect(models.panel).toEqual({ tag: "mlx-models-panel", entry: "@mlx-bun/module-models/panel", title: "Models", path: "/models", developer: false });
  expect(models.storage?.map(item => item.path)).toEqual(["adapters", "exports"]);
});

test("it mounts every route at the path the app has always answered on, and the verbs the CLI lists", async () => {
  const { loaded } = await host();
  try {
    expect(loaded.routes.map(route => `${route.spec.method} ${route.path}`)).toEqual([
      "GET /library", "GET /downloads", "GET /api/hub/local", "GET /api/hub/search", "POST /api/hub/serve", "POST /api/hub/download", "POST /api/model/resolve-folder",
      "GET /api/gc/plan", "POST /api/gc/execute", "GET /v1/adapters/available", "GET /v1/adapters", "POST /v1/adapters", "DELETE /v1/adapters/:id",
      "POST /api/finetune/merge", "POST /api/finetune/export"]);
    expect(manifest.routes.every(route => route.mount === "root")).toBe(true);
    expect([...loaded.verbs.keys()]).toEqual(["get", "ls", "scan", "fit", "gc", "upload"]);
    expect(loaded.jobs.size).toBe(0);
  } finally { await loaded.stop(); }
});

test("a request reaches its handler by method and path, and an adapter id is one path segment", async () => {
  const { loaded, send, lists } = await host();
  try {
    expect((await send("/library")).status).toBe(200);
    expect(lists()).toBe(1);
    expect((await send("/api/hub/search")).status).toBe(400);
    // The served model here declares no adapter operation, which the handler answers rather than the router.
    expect((await send("/v1/adapters/some-id", { method: "DELETE" })).status).toBe(400);
    expect((await send("/api/model/resolve-folder", { method: "POST", body: JSON.stringify({ folder_name: "nothing" }) })).status).toBe(200);
  } finally { await loaded.stop(); }
});

test("the library follows the catalog's changes while the module runs and stops following when it stops", async () => {
  const { loaded, send, events, lists } = await host();
  await send("/library"); await send("/library");
  expect(lists()).toBe(1);
  events.publish({ type: "catalog.changed", at: 1 });
  await send("/library");
  expect(lists()).toBe(2);
  await loaded.stop();
  events.publish({ type: "catalog.changed", at: 2 });
  await send("/library");
  expect(lists()).toBe(2);
});
