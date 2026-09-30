// The real Download button of the models panel through the real listener, the models module's routes, the catalog over the
// app's download owner, the hub downloader, and `/downloads` against a local fake Hub.
// Covers the transitions a row-injection test cannot: a slow listing (no
// tracker row yet), progress, completion, and a listing failure.
import { testWindow } from "./dom-setup";
import { afterEach, expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { loadModules } from "@mlx-bun/app-host";
import { createEventHub, createModuleRoutes, createRegistryCatalog, createStorage } from "@mlx-bun/app-services";
import { downloadsSnapshot, gitBlobSha1 } from "@mlx-bun/hub/download";
import { Registry } from "@mlx-bun/hub/registry";
import { createModelsModule } from "@mlx-bun/module-models";
import { catalogTransfers, createDownloadOwner } from "../../src/hub/downloads";
import { startServer } from "../../src/server/start";

const COMMIT = "beef".padEnd(40, "0");
const cleanups: (() => Promise<void> | void)[] = [];
afterEach(async () => { for (const cleanup of cleanups.splice(0).reverse()) await cleanup(); });

function fakeHub() {
  const config = new TextEncoder().encode('{"model_type":"tiny"}');
  const weights = new Uint8Array(16); for (let i = 0; i < weights.length; i++) weights[i] = i + 1;
  const digest = new Bun.CryptoHasher("sha256").update(weights).digest("hex");
  let metadata: PromiseWithResolvers<void> | null = Promise.withResolvers<void>();
  let pause: PromiseWithResolvers<void> | null = Promise.withResolvers<void>();
  const server = Bun.serve({ hostname: "127.0.0.1", port: 0, async fetch(request) {
    const url = new URL(request.url);
    if (url.pathname === "/api/models") return Response.json([
      { id: "lifecycle/tiny", downloads: 3, likes: 1, tags: ["mlx"] }, { id: "lifecycle/missing", downloads: 0, likes: 0, tags: ["mlx"] }]);
    if (url.pathname.startsWith("/api/models/lifecycle/missing/")) return new Response("Repository not found", { status: 404 });
    if (url.pathname.startsWith("/api/models/lifecycle/tiny/")) {
      if (metadata) await metadata.promise;
      return Response.json({ sha: COMMIT, siblings: [
        { rfilename: "config.json", size: config.length, blobId: gitBlobSha1(config) },
        { rfilename: "model.safetensors", size: weights.length, blobId: "f".repeat(40), lfs: { sha256: digest, size: weights.length } }] });
    }
    if (url.pathname.endsWith("/config.json")) return new Response(config);
    let offset = 0;
    return new Response(new ReadableStream<Uint8Array>({ async pull(controller) {
      if (offset >= weights.length) { controller.close(); return; }
      if (offset > 0 && pause) await pause.promise;
      controller.enqueue(weights.subarray(offset, offset + 4)); offset += 4;
    } }));
  } });
  cleanups.push(() => { metadata?.resolve(); pause?.resolve(); return server.stop(true); });
  return { endpoint: `http://127.0.0.1:${server.port}`,
    releaseMetadata() { metadata?.resolve(); metadata = null; }, releasePause() { pause?.resolve(); pause = null; } };
}

async function until(predicate: () => boolean, what: string, ms = 5_000) {
  const deadline = Date.now() + ms;
  while (!predicate()) { if (Date.now() > deadline) throw new Error(`Timed out waiting for ${what}`); await Bun.sleep(5); }
}

test("Download button: slow listing shows preparing, then progress, then done; a listing failure shows its error", async () => {
  const hub = fakeHub();
  const cacheDir = mkdtempSync(join(tmpdir(), "mlx-hub-lifecycle-")); cleanups.push(() => rmSync(cacheDir, { recursive: true, force: true }));
  // The hub tracker is process-global and other suites leave rows in it; this
  // test reads only its own repo identities from it. Foreign-row inclusion is
  // covered by the owner's unit tests.
  const owner = createDownloadOwner({ transfer: { cacheDir, endpoint: hub.endpoint, token: null },
    tracker: () => downloadsSnapshot().filter(row => row.repoId.startsWith("lifecycle/")) });
  // The panel loads the downloaded models when it connects: an index of its own over this test's cache, never the user's.
  const previous = process.env.HF_HUB_CACHE;
  process.env.HF_HUB_CACHE = cacheDir;
  cleanups.push(() => { if (previous === undefined) delete process.env.HF_HUB_CACHE; else process.env.HF_HUB_CACHE = previous; });
  const catalog = createRegistryCatalog({ registry: () => new Registry(":memory:"), hub: { transfers: catalogTransfers(owner) } });
  const events = createEventHub();
  const modelHost = { defaultFor: async () => undefined, resident: () => [], serve: async () => { throw new Error("unused"); } };
  const loaded = await loadModules([createModelsModule({ hub: { endpoint: hub.endpoint, token: () => null } })], { services: { catalog: () => catalog,
    modelHost: () => modelHost as never, storage: createStorage(() => cacheDir), events: scope => events.scoped(scope) } });
  cleanups.push(() => loaded.stop());
  const routes = createModuleRoutes(loaded.routes);
  const app = await startServer({ web: () => null, chat: () => ({ async start() {}, async handle() {}, dispose() {} }),
    routes, beforeDrain: () => owner.close(), async closeEngine() {} }, { port: 0 });
  cleanups.push(() => app.close());
  const base = app.server.url;
  const browserFetch = globalThis.fetch;
  // The panel is a custom element: it reaches the routes at the origin its connection names, here the listener; the fake
  // Hub answers the download's own requests, so the panel's fetch is the real one.
  Object.assign(globalThis, { customElements: testWindow.customElements });
  await import("@mlx-bun/module-models/panel");
  document.body.innerHTML = "";
  const panel = document.createElement("mlx-models-panel") as HTMLElement & { connection?: { apiBase: string; eventsUrl: string }; search(query: string): Promise<void>; pollDownloads(): Promise<void> };
  panel.connection = { apiBase: new URL("/api/models", base).href, eventsUrl: "" };
  document.body.append(panel);
  cleanups.push(() => panel.remove());
  const shadow = panel.shadowRoot!;
  const actions = (repo: string) => shadow.querySelector(`.hub-row[data-search-repo="${repo}"] .hub-row-actions`)!.textContent;
  const button = (repo: string) => shadow.querySelector<HTMLButtonElement>(`.hub-download-btn[data-repo="${repo}"]`)!;
  const served = async () => (await (await browserFetch(new URL("/downloads", base))).json()).downloads as { repoId: string; state: string; totalBytes: number; error?: string }[];

  await panel.search("tiny");
  expect(button("lifecycle/tiny").textContent).toBe("Download");
  button("lifecycle/tiny").click();
  await until(() => actions("lifecycle/tiny") === "downloading…", "download admission");
  expect(owner.active).toEqual(["lifecycle/tiny"]);
  // The listing is still pending: the tracker has no row, the owner's does.
  expect(await served()).toEqual([expect.objectContaining({ repoId: "lifecycle/tiny", state: "active", totalBytes: 0 })]);
  await panel.pollDownloads();
  expect(actions("lifecycle/tiny")).toBe("preparing…");

  hub.releaseMetadata();
  await until(() => owner.snapshot().some(row => row.repoId === "lifecycle/tiny" && row.totalBytes > 0 && row.receivedBytes > 0), "tracker progress");
  await panel.pollDownloads();
  expect(actions("lifecycle/tiny")).toMatch(/^\d+%$/);
  hub.releasePause();
  await until(() => owner.active.length === 0, "transfer completion");
  await panel.pollDownloads();
  expect(actions("lifecycle/tiny")).toBe("done — reload to serve");
  expect(await served()).toEqual([expect.objectContaining({ repoId: "lifecycle/tiny", state: "done" })]);

  button("lifecycle/missing").click();
  await until(() => actions("lifecycle/missing") === "downloading…", "second admission");
  await until(() => owner.active.length === 0, "listing failure");
  await panel.pollDownloads();
  expect(actions("lifecycle/missing")).toContain("HF API 404");
  expect(await served()).toEqual([
    expect.objectContaining({ repoId: "lifecycle/tiny", state: "done" }),
    expect.objectContaining({ repoId: "lifecycle/missing", state: "error", error: expect.stringContaining("HF API 404") })]);
}, 20_000);
