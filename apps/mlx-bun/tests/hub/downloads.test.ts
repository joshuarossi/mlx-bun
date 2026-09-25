import { afterEach, expect, test } from "bun:test";
import { existsSync, mkdtempSync, readFileSync, rmSync, statSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { downloadsSnapshot, gitBlobSha1 } from "@mlx-bun/hub/download";
import { createDownloadOwner, DuplicateDownloadError } from "../../src/hub/downloads";
import { createHubRoutes } from "../../src/server/hub-routes";
import { startServer } from "../../src/server/start";

const idleChat = () => ({ async start() {}, async handle() {}, dispose() {} });
/** Completion hooks run inside the transfer's settlement; wait for it to leave the map. */
async function drained(owner: { readonly active: readonly string[] }) { while (owner.active.length) await Bun.sleep(1); }

test("admission is synchronous before any request, refuses duplicates, and reopens after completion", async () => {
  const gate = Promise.withResolvers<string>();
  const completed = Promise.withResolvers<[string, string]>();
  let calls = 0;
  const owner = createDownloadOwner({ download: () => { calls++; return gate.promise; },
    active: repo => repo === "other/busy", onComplete: (repo, path) => { completed.resolve([repo, path]); } });
  owner.start("org/tiny");
  expect(owner.active).toEqual(["org/tiny"]);
  expect(() => owner.start("org/tiny")).toThrow(DuplicateDownloadError);
  expect(() => owner.start("other/busy")).toThrow("a download for other/busy is already in progress");
  expect(calls).toBe(1);
  gate.resolve("/snapshots/abc");
  expect(await completed.promise).toEqual(["org/tiny", "/snapshots/abc"]);
  await drained(owner);
  expect(owner.active).toEqual([]);
  owner.start("org/tiny");
  expect(calls).toBe(2);
  await owner.close();
});

test("a failed transfer reports once, never completes, and leaves the repo admissible again", async () => {
  const failed = Promise.withResolvers<[string, unknown]>();
  let completions = 0, attempts = 0;
  const owner = createDownloadOwner({
    download: async () => { if (attempts++ === 0) throw new Error("HF API 404"); return "/snap"; },
    onComplete: () => { completions++; }, onFailure: (repo, error) => failed.resolve([repo, error]) });
  owner.start("org/tiny");
  const [repo, error] = await failed.promise;
  expect(repo).toBe("org/tiny"); expect((error as Error).message).toBe("HF API 404");
  await drained(owner);
  expect(owner.active).toEqual([]);
  expect(completions).toBe(0);
  owner.start("org/tiny");
  await owner.close();
  expect(attempts).toBe(2);
});

test("close aborts every transfer, joins their settlement, publishes no completion, and refuses later starts", async () => {
  const events: string[] = [];
  let completions = 0, failures = 0;
  const owner = createDownloadOwner({
    download: (repo, options) => new Promise<string>(resolve => {
      options.signal!.addEventListener("abort", () => { events.push(`${repo} aborted`); setTimeout(() => { events.push(`${repo} settled`); resolve("/snap"); }, 10); });
    }),
    onComplete: () => { completions++; }, onFailure: () => { failures++; } });
  owner.start("org/one"); owner.start("org/two");
  const closing = owner.close();
  expect(closing).toBe(owner.close());
  await closing;
  expect(events.sort()).toEqual(["org/one aborted", "org/one settled", "org/two aborted", "org/two settled"]);
  expect(owner.active).toEqual([]);
  expect(completions).toBe(0); expect(failures).toBe(0);
  expect(() => owner.start("org/three")).toThrow("downloads are closed");
});

test("the listener joins a web-started transfer through beforeDrain before releasing the engine", async () => {
  const events: string[] = [];
  const owner = createDownloadOwner({ download: (repo, options) => new Promise<string>((_, reject) => {
    options.signal!.addEventListener("abort", () => { events.push("aborted"); setTimeout(() => { events.push("settled"); reject(options.signal!.reason); }, 10); });
  }) });
  const hub = createHubRoutes({ downloads: owner });
  const app = await startServer({ web: () => null, chat: idleChat, routes: hub,
    beforeDrain: () => owner.close(), async closeEngine() { events.push("engine-close"); } }, { port: 0 });
  try {
    const started = await fetch(new URL("/api/hub/download", app.server.url), { method: "POST",
      headers: { "content-type": "application/json" }, body: JSON.stringify({ repo: "org/tiny" }) });
    expect(await started.json()).toEqual({ ok: true, repo: "org/tiny", started: true });
    const duplicate = await fetch(new URL("/api/hub/download", app.server.url), { method: "POST",
      headers: { "content-type": "application/json" }, body: JSON.stringify({ repo: "org/tiny" }) });
    expect(duplicate.status).toBe(409);
    expect(owner.active).toEqual(["org/tiny"]);
  } finally { await app.close(); }
  expect(events).toEqual(["aborted", "settled", "engine-close"]);
});

// Real downloader against a local fake Hub through the owner: shutdown keeps a
// resumable partial, and the next start resumes and completes it.
const COMMIT = "abc123".padEnd(40, "0");
const roots: string[] = [];
afterEach(() => { for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true }); });

test("shutdown mid-transfer keeps a resumable partial that a later start completes and reports", async () => {
  const weights = new Uint8Array(16); for (let i = 0; i < weights.length; i++) weights[i] = i + 3;
  const config = new TextEncoder().encode('{"model_type":"tiny"}');
  const digest = new Bun.CryptoHasher("sha256").update(weights).digest("hex");
  let pause: PromiseWithResolvers<void> | null = Promise.withResolvers<void>();
  const ranges: (string | null)[] = [];
  const server = Bun.serve({ hostname: "127.0.0.1", port: 0, async fetch(request) {
    const url = new URL(request.url);
    if (url.pathname.startsWith("/api/models/")) return Response.json({ sha: COMMIT, siblings: [
      { rfilename: "config.json", size: config.length, blobId: gitBlobSha1(config) },
      { rfilename: "model.safetensors", size: weights.length, blobId: "f".repeat(40), lfs: { sha256: digest, size: weights.length } }] });
    if (url.pathname.endsWith("/config.json")) return new Response(config);
    const range = request.headers.get("range"); ranges.push(range);
    const start = range ? Number(/bytes=(\d+)-/.exec(range)![1]) : 0;
    const body = weights.subarray(start);
    let offset = 0;
    return new Response(new ReadableStream<Uint8Array>({ async pull(controller) {
      if (offset >= body.length) { controller.close(); return; }
      if (offset > 0 && pause) await pause.promise;
      controller.enqueue(body.subarray(offset, offset + 4)); offset += 4;
    } }), { status: start > 0 ? 206 : 200 });
  } });
  const cacheDir = mkdtempSync(join(tmpdir(), "mlx-app-download-")); roots.push(cacheDir);
  const transfer = { cacheDir, endpoint: `http://127.0.0.1:${server.port}`, token: null };
  const blob = join(cacheDir, "models--org--tiny", "blobs", digest);
  try {
    const first = createDownloadOwner({ transfer, onComplete: () => { throw new Error("completion must not run after abort"); } });
    first.start("org/tiny");
    while (!existsSync(`${blob}.incomplete`) || statSync(`${blob}.incomplete`).size < 4) await Bun.sleep(5);
    await first.close();
    expect(statSync(`${blob}.incomplete`).size).toBe(4);
    expect(existsSync(blob)).toBe(false);
    expect(existsSync(join(cacheDir, "models--org--tiny", "refs", "main"))).toBe(false);
    expect(downloadsSnapshot().at(-1)).toMatchObject({ repoId: "org/tiny", state: "error" });
    pause.resolve(); pause = null;
    const completed = Promise.withResolvers<string>();
    const second = createDownloadOwner({ transfer, onComplete: (_repo, path) => { completed.resolve(path); } });
    second.start("org/tiny");
    const snapshot = await completed.promise;
    expect(readFileSync(join(snapshot, "model.safetensors"))).toEqual(Buffer.from(weights));
    expect(readFileSync(join(cacheDir, "models--org--tiny", "refs", "main"), "utf8")).toBe(COMMIT);
    expect(ranges).toEqual([null, "bytes=4-"]);
    expect(downloadsSnapshot().at(-1)).toMatchObject({ repoId: "org/tiny", state: "done" });
    await second.close();
  } finally { pause?.resolve(); await server.stop(true); }
});
