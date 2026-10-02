import { expect, test } from "bun:test";
import type { CatalogEntry, DownloadRow } from "@mlx-bun/app-core";
import { createLibraryHandlers } from "../src";
import { entry, fakeCatalog, fakeHost, request, resident, syncEvents } from "./support";

const details = { parameters: null, quantBits: 4, quantGroupSize: 64, license: null, vision: true, audio: false, tools: false, kvQuant: false, expertsBytes: 0, sidecarBytes: 0, supportTier: "targeted" as const };
const model = (id: string, extra: Partial<CatalogEntry> = {}) => entry(id, { modelType: "gemma4", details, ...extra });

function library(entries: CatalogEntry[], options: { host?: Parameters<typeof fakeHost>[0]; downloads?: DownloadRow[] } = {}) {
  const lists: unknown[] = [], events = syncEvents();
  const catalog = fakeCatalog(entries, { async list(filter) { lists.push(filter); return entries; }, downloads: () => options.downloads ?? [] });
  const { handlers, stop } = createLibraryHandlers({ catalog, modelHost: fakeHost(options.host), events });
  return { handlers, lists, events, stop, get: (path = "/library") => handlers.library(request(path)) };
}

test("every local model is listed with its fit inputs, capabilities, and what the host serves and holds resident", async () => {
  const run = library([model("org/a"), model("org/b", { modelType: "qwen3", details: { ...details, vision: false, supportTier: null } })],
    { host: { served: "org/b", residents: [resident("org/a"), resident("org/b"), resident("org/loading", { state: "loading" })] } });
  const body = await (await run.get()).json();
  expect(body.models).toEqual([
    { repo_id: "org/a", model_type: "gemma4", size_bytes: 1000, quant_bits: 4, vision: true, audio: false, supported: true, support_tier: "targeted", assessment: null, serving: false, resident: true },
    { repo_id: "org/b", model_type: "qwen3", size_bytes: 1000, quant_bits: 4, vision: false, audio: false, supported: false, support_tier: null, assessment: null, serving: true, resident: true },
  ]);
  // The index is re-read from disk (companions included), as a listing that must show what exists now.
  expect(run.lists).toEqual([{ companions: true, refresh: true }]);
});

test("the rows are kept until the catalog changes or a refresh is asked for; what is running is read every time", async () => {
  const run = library([model("org/a")]);
  await run.get(); await run.get();
  expect(run.lists).toHaveLength(1);
  await run.get("/library?refresh=1");
  expect(run.lists).toHaveLength(2);
  run.events.publish({ type: "catalog.changed", at: 1 });
  await run.get();
  expect(run.lists).toHaveLength(3);
  await run.get();
  expect(run.lists).toHaveLength(3);
  run.stop();
  run.events.publish({ type: "catalog.changed", at: 2 });
  await run.get();
  expect(run.lists).toHaveLength(3);
});

test("rows expire after thirty seconds", async () => {
  let now = 0;
  const catalog = fakeCatalog([model("org/a")]);
  let lists = 0;
  const { handlers } = createLibraryHandlers({ catalog: { ...catalog, async list() { lists++; return [model("org/a")]; } }, modelHost: fakeHost(), events: syncEvents() }, () => now);
  await handlers.library(request("/library")); now = 29_999; await handlers.library(request("/library"));
  expect(lists).toBe(1);
  now = 30_001; await handlers.library(request("/library"));
  expect(lists).toBe(2);
});

test("a failing listing is the caller's error and leaves nothing cached", async () => {
  let fail = true, lists = 0;
  const events = syncEvents();
  const { handlers } = createLibraryHandlers({ catalog: { ...fakeCatalog(), async list() { lists++; if (fail) throw new Error("scan failed"); return []; } }, modelHost: fakeHost(), events });
  await expect(handlers.library(request("/library"))).rejects.toThrow("scan failed");
  fail = false;
  expect(await (await handlers.library(request("/library"))).json()).toEqual({ models: [] });
  expect(lists).toBe(2);
});

test("downloads serves the catalog's progress rows", async () => {
  const rows: DownloadRow[] = [{ repoId: "org/tiny", state: "active", currentFile: null, receivedBytes: 0, totalBytes: 0 }];
  const run = library([], { downloads: rows });
  expect(await (await run.handlers.downloads(request("/downloads"))).json()).toEqual({ downloads: rows });
});
