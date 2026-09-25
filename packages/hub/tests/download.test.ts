// downloadModel against a LOCAL fake Hub: the metadata listing, Range-resumed
// blob streaming, checksum verification, and caller-owned cancellation. Nothing
// here reaches huggingface.co, and no credential file is read (token: null).

import { afterEach, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, readlinkSync, rmSync, statSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { downloadModel, downloadsSnapshot, gitBlobSha1 } from "@mlx-bun/hub/download";

const sha256 = (bytes: Uint8Array) => new Bun.CryptoHasher("sha256").update(bytes).digest("hex");
const COMMIT = "c0ffee".padEnd(40, "0");
const CHUNK = 4;

interface FakeFile { name: string; bytes: Uint8Array; lfs: boolean }

/** Streams blobs in fixed chunks; `pause` holds an LFS blob's second chunk until
 * released, which also pins a chunk boundary the transport would otherwise merge. */
function fakeHub(files: FakeFile[]) {
  const seen: { path: string; range: string | null }[] = [];
  let pause: PromiseWithResolvers<void> | null = null;
  let holdMetadata: PromiseWithResolvers<void> | null = null;
  let ignoreRange = false;
  const server = Bun.serve({ hostname: "127.0.0.1", port: 0, async fetch(request) {
    const url = new URL(request.url);
    seen.push({ path: url.pathname, range: request.headers.get("range") });
    if (/^\/api\/models\/org\/tiny\/revision\/[^/]+$/.test(url.pathname)) {
      if (holdMetadata) await holdMetadata.promise;
      return Response.json({ sha: COMMIT, siblings: files.map(file => file.lfs
        ? { rfilename: file.name, size: file.bytes.length, blobId: "f".repeat(40), lfs: { sha256: sha256(file.bytes), size: file.bytes.length } }
        : { rfilename: file.name, size: file.bytes.length, blobId: gitBlobSha1(file.bytes) }) });
    }
    const resolve = /^\/[^/]+\/[^/]+\/resolve\/[^/]+\/(.+)$/.exec(url.pathname);
    const file = resolve && files.find(candidate => candidate.name === resolve[1]);
    if (!file) return new Response("missing", { status: 404 });
    const range = request.headers.get("range");
    const start = range && !ignoreRange ? Number(/bytes=(\d+)-/.exec(range)![1]) : 0;
    const body = file.bytes.subarray(start);
    let offset = 0;
    return new Response(new ReadableStream<Uint8Array>({ async pull(controller) {
      if (offset >= body.length) { controller.close(); return; }
      if (offset > 0 && pause && file.lfs) await pause.promise;
      controller.enqueue(body.subarray(offset, Math.min(offset + CHUNK, body.length)));
      offset += CHUNK;
    } }), { status: start > 0 ? 206 : 200, headers: { "content-length": String(body.length) } });
  } });
  return { seen, server,
    endpoint: `http://127.0.0.1:${server.port}`,
    pause() { pause = Promise.withResolvers<void>(); return () => { pause?.resolve(); pause = null; }; },
    holdMetadata() { holdMetadata = Promise.withResolvers<void>(); return () => { holdMetadata?.resolve(); holdMetadata = null; }; },
    ignoreRange(on: boolean) { ignoreRange = on; },
    resolves: (name: string) => seen.filter(entry => entry.path.endsWith(`/resolve/${COMMIT}/${name}`)),
    stop: () => { pause?.resolve(); holdMetadata?.resolve(); return server.stop(true); },
  };
}

const roots: string[] = [];
const hubs: ReturnType<typeof fakeHub>[] = [];
afterEach(async () => {
  for (const hub of hubs.splice(0)) await hub.stop();
  for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true });
});
function setup(files: FakeFile[] = defaultFiles()) {
  const hub = fakeHub(files); hubs.push(hub);
  const cacheDir = mkdtempSync(join(tmpdir(), "mlx-hub-download-")); roots.push(cacheDir);
  const repoDir = join(cacheDir, "models--org--tiny");
  return { hub, cacheDir, repoDir, files,
    download: (options: Parameters<typeof downloadModel>[1] = {}) =>
      downloadModel("org/tiny", { cacheDir, endpoint: hub.endpoint, token: null, ...options }) };
}
function defaultFiles(): FakeFile[] {
  const weights = new Uint8Array(20); for (let i = 0; i < weights.length; i++) weights[i] = i * 7 + 1;
  return [{ name: "config.json", bytes: new TextEncoder().encode('{"model_type":"tiny"}'), lfs: false },
    { name: "model.safetensors", bytes: weights, lfs: true }];
}
const blobName = (file: FakeFile) => file.lfs ? sha256(file.bytes) : gitBlobSha1(file.bytes);
function expectComplete({ repoDir, files }: { repoDir: string; files: FakeFile[] }, snapshot: string) {
  expect(snapshot).toBe(join(repoDir, "snapshots", COMMIT));
  for (const file of files) {
    expect(readFileSync(join(repoDir, "blobs", blobName(file)))).toEqual(Buffer.from(file.bytes));
    expect(readlinkSync(join(snapshot, file.name))).toBe(join("../../blobs", blobName(file)));
    expect(readFileSync(join(snapshot, file.name))).toEqual(Buffer.from(file.bytes));
    expect(existsSync(join(repoDir, "blobs", `${blobName(file)}.incomplete`))).toBe(false);
    expect(existsSync(join(repoDir, "blobs", `${blobName(file)}.lock`))).toBe(false);
  }
  expect(readFileSync(join(repoDir, "refs", "main"), "utf8")).toBe(COMMIT);
  expect(downloadsSnapshot().at(-1)).toMatchObject({ repoId: "org/tiny", state: "done", filesDone: files.length, filesTotal: files.length });
}

test("a full download writes the huggingface cache layout with verified blobs and a revision ref", async () => {
  const fixture = setup();
  const progress: number[] = [];
  expectComplete(fixture, await fixture.download({ onProgress: (_file, received) => progress.push(received) }));
  expect(progress).toContain(fixture.files[1]!.bytes.length);
  expect(fixture.hub.resolves("model.safetensors").map(entry => entry.range)).toEqual([null]);
});

test("aborting mid-stream settles the received prefix, publishes nothing, and resumes with a Range request", async () => {
  const fixture = setup();
  const release = fixture.hub.pause();
  const controller = new AbortController();
  const stop = new Error("stop now");
  await expect(fixture.download({ signal: controller.signal, onProgress: (file, received) => {
    if (file === "model.safetensors" && received === CHUNK) controller.abort(stop);
  } })).rejects.toBe(stop);
  release();
  const blob = join(fixture.repoDir, "blobs", blobName(fixture.files[1]!));
  expect(statSync(`${blob}.incomplete`).size).toBe(CHUNK);
  expect(existsSync(blob)).toBe(false);
  expect(existsSync(`${blob}.lock`)).toBe(false);
  expect(existsSync(join(fixture.repoDir, "refs", "main"))).toBe(false);
  expect(downloadsSnapshot().at(-1)).toMatchObject({ repoId: "org/tiny", state: "error" });
  expectComplete(fixture, await fixture.download());
  expect(fixture.hub.resolves("model.safetensors").map(entry => entry.range)).toEqual([null, `bytes=${CHUNK}-`]);
});

test("aborting during the metadata request rejects before any cache directory exists", async () => {
  const fixture = setup();
  const release = fixture.hub.holdMetadata();
  const controller = new AbortController();
  const pending = fixture.download({ signal: controller.signal });
  await Bun.sleep(20);
  controller.abort(new Error("metadata abort"));
  await expect(pending).rejects.toThrow();
  release();
  expect(existsSync(fixture.repoDir)).toBe(false);
  expect(fixture.hub.seen.map(entry => entry.path)).toHaveLength(1);
});

test("an already-aborted signal is honored before the first request or lock", async () => {
  const fixture = setup();
  await expect(fixture.download({ signal: AbortSignal.abort(new Error("never started")) })).rejects.toThrow("never started");
  expect(fixture.hub.seen).toEqual([]);
  expect(existsSync(fixture.repoDir)).toBe(false);
});

test("an abort after the last byte keeps the complete partial unpublished; the rerun rehashes it without a request", async () => {
  const fixture = setup();
  const controller = new AbortController();
  const total = fixture.files[1]!.bytes.length;
  await expect(fixture.download({ signal: controller.signal, onProgress: (file, received) => {
    if (file === "model.safetensors" && received === total) controller.abort(new Error("late abort"));
  } })).rejects.toThrow("late abort");
  const blob = join(fixture.repoDir, "blobs", blobName(fixture.files[1]!));
  expect(statSync(`${blob}.incomplete`).size).toBe(total);
  expect(existsSync(blob)).toBe(false);
  expect(existsSync(join(fixture.repoDir, "refs", "main"))).toBe(false);
  expect(downloadsSnapshot().at(-1)?.state).toBe("error");
  expectComplete(fixture, await fixture.download());
  expect(fixture.hub.resolves("model.safetensors")).toHaveLength(1);
});

test("a server that ignores Range restarts the blob from zero and still verifies it", async () => {
  const fixture = setup();
  const blob = join(fixture.repoDir, "blobs", blobName(fixture.files[1]!));
  mkdirSync(join(fixture.repoDir, "blobs"), { recursive: true });
  writeFileSync(`${blob}.incomplete`, fixture.files[1]!.bytes.subarray(0, CHUNK));
  fixture.hub.ignoreRange(true);
  expectComplete(fixture, await fixture.download());
  expect(fixture.hub.resolves("model.safetensors").map(entry => entry.range)).toEqual([`bytes=${CHUNK}-`, null]);
});

test("a paused stream is abortable while waiting for the next chunk, and the partial stays resumable", async () => {
  const fixture = setup();
  const release = fixture.hub.pause();
  const controller = new AbortController();
  let received = 0;
  const pending = fixture.download({ signal: controller.signal, onProgress: (file, bytes) => { if (file === "model.safetensors") received = bytes; } });
  while (received < CHUNK) await Bun.sleep(5);
  controller.abort(new Error("paused abort"));
  await expect(pending).rejects.toThrow();
  release();
  const blob = join(fixture.repoDir, "blobs", blobName(fixture.files[1]!));
  expect(statSync(`${blob}.incomplete`).size).toBe(CHUNK);
  expect(existsSync(join(fixture.repoDir, "refs", "main"))).toBe(false);
  expectComplete(fixture, await fixture.download());
});

test("onStatus hands the caller the live tracker row after listing and preflight, and never before a failure there", async () => {
  const fixture = setup();
  const seen: unknown[] = [];
  const snapshot = await fixture.download({ onStatus: status => {
    seen.push({ ...status });
    expect(status.state).toBe("active");
    expect(status.totalBytes).toBe(fixture.files.reduce((sum, file) => sum + file.bytes.length, 0));
    expect(downloadsSnapshot().at(-1)).toBe(status);
  } });
  expectComplete(fixture, snapshot);
  expect(seen).toHaveLength(1);
  const missing = setup();
  let statuses = 0;
  await expect(downloadModel("org/absent", { cacheDir: missing.cacheDir, endpoint: missing.hub.endpoint, token: null,
    onStatus: () => { statuses++; } })).rejects.toThrow("HF API 404");
  expect(statuses).toBe(0);
});

test("a throwing onStatus rejects the transfer and leaves the tracker row terminal, not active", async () => {
  const fixture = setup();
  await expect(fixture.download({ onStatus: () => { throw new Error("caller failed"); } })).rejects.toThrow("caller failed");
  expect(downloadsSnapshot().at(-1)).toMatchObject({ repoId: "org/tiny", state: "error", error: "caller failed" });
  expect(existsSync(join(fixture.repoDir, "refs", "main"))).toBe(false);
  expectComplete(fixture, await fixture.download());
});
