// The real Download button through the real listener, hub routes, download
// owner, hub downloader, and discovery `/downloads` against a local fake Hub.
// Covers the transitions a row-injection test cannot: a slow listing (no
// tracker row yet), progress, completion, and a listing failure.
import "./dom-setup";
import { afterEach, expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { downloadsSnapshot, gitBlobSha1 } from "@mlx-bun/hub/download";
import type { LoadedModelContext } from "../../src/engine/model-host";
import { createDownloadOwner } from "../../src/hub/downloads";
import { createDiscoveryRoutes } from "../../src/server/discovery-routes";
import { createHubRoutes } from "../../src/server/hub-routes";
import { startServer } from "../../src/server/start";
import { pollDownloads, runSearch, stopDownloadPolling } from "../../src/web/browser/hub";

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
  const context = { modelId: "test/model", model: { config: { modelType: "llama", text: { maxPositionEmbeddings: 8192 } } },
    template: { supportsThinking: false }, genDefaults: {}, draft: null } as unknown as LoadedModelContext;
  const discovery = createDiscoveryRoutes(context, { discovery: { adapters: false, training: false, dsa: true, embeddings: false } },
    Date.now(), undefined, undefined, owner.snapshot);
  const routes = createHubRoutes({ downloads: owner, endpoint: hub.endpoint, token: () => null });
  const app = await startServer({ web: () => null, chat: () => ({ async start() {}, async handle() {}, dispose() {} }),
    routes: { handle: async request => await routes.handle(request) ?? await discovery.handle(new URL(request.url), request) },
    beforeDrain: () => owner.close(), async closeEngine() {} }, { port: 0 });
  cleanups.push(() => app.close());
  const base = app.server.url;
  const browserFetch = globalThis.fetch;
  globalThis.fetch = ((input: string | URL | Request, init?: RequestInit) =>
    browserFetch(new URL(String(input), base).href, init)) as typeof fetch;
  cleanups.push(() => { globalThis.fetch = browserFetch; stopDownloadPolling(); });
  document.body.innerHTML = '<div id="hub-search-body"></div><div id="toasts"></div>';
  const actions = (repo: string) => document.querySelector(`.hub-row[data-search-repo="${repo}"] .hub-row-actions`)!.textContent;
  const button = (repo: string) => document.querySelector<HTMLButtonElement>(`.hub-download-btn[data-repo="${repo}"]`)!;
  const served = async () => (await (await browserFetch(new URL("/downloads", base))).json()).downloads as { repoId: string; state: string; totalBytes: number; error?: string }[];

  await runSearch("tiny");
  expect(button("lifecycle/tiny").textContent).toBe("Download");
  button("lifecycle/tiny").click();
  await until(() => actions("lifecycle/tiny") === "downloading…", "download admission");
  expect(owner.active).toEqual(["lifecycle/tiny"]);
  // The listing is still pending: the tracker has no row, the owner's does.
  expect(await served()).toEqual([expect.objectContaining({ repoId: "lifecycle/tiny", state: "active", totalBytes: 0 })]);
  await pollDownloads();
  expect(actions("lifecycle/tiny")).toBe("preparing…");

  hub.releaseMetadata();
  await until(() => owner.snapshot().some(row => row.repoId === "lifecycle/tiny" && row.totalBytes > 0 && row.receivedBytes > 0), "tracker progress");
  await pollDownloads();
  expect(actions("lifecycle/tiny")).toMatch(/^\d+%$/);
  hub.releasePause();
  await until(() => owner.active.length === 0, "transfer completion");
  await pollDownloads();
  expect(actions("lifecycle/tiny")).toBe("done — reload to serve");
  expect(await served()).toEqual([expect.objectContaining({ repoId: "lifecycle/tiny", state: "done" })]);

  button("lifecycle/missing").click();
  await until(() => actions("lifecycle/missing") === "downloading…", "second admission");
  await until(() => owner.active.length === 0, "listing failure");
  await pollDownloads();
  expect(actions("lifecycle/missing")).toContain("HF API 404");
  expect(await served()).toEqual([
    expect.objectContaining({ repoId: "lifecycle/tiny", state: "done" }),
    expect.objectContaining({ repoId: "lifecycle/missing", state: "error", error: expect.stringContaining("HF API 404") })]);
}, 20_000);
