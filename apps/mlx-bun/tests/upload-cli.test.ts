// The upload verb (main's mlx_lm.upload counterpart), model-free and CPU-only.
//
// Injected-dependency tests cover usage, validation, token resolution, the
// upload contract, the completion box, failure, and cancellation. Spawned-CLI
// tests run src/cli/main.ts against a LOCAL mock Hub started here, with an
// isolated $HOME and an invented HF_TOKEN; a preload rewrites huggingface.co
// to the mock (the uploader has no endpoint environment knob) and refuses any
// other network request. Nothing here publishes.

import { afterAll, afterEach, beforeEach, expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import type { UploadOptions } from "@mlx-bun/hub/upload";
import { help, parseCommand, usage } from "../src/cli/args";
import { runUpload, type UploadDependencies } from "../src/cli/upload";

const parse = (...args: string[]) => parseCommand("upload", args);
const plain = (text: string) => text.replace(/\x1b\[[0-9;]*m/g, "");
const USAGE = "usage: mlx-bun upload --path <model-dir> --upload-repo <org/repo> [--private]";
const TOKEN_HELP = [
  "no Hugging Face token found — uploading needs a WRITE token from one of:",
  "  hf auth login                  (~/.cache/huggingface/token)",
  "  export HF_TOKEN=hf_…",
  "  web UI Settings → Hugging Face (~/.mlx-bun/hf.json)",
].join("\n");

const roots: string[] = [];
afterEach(() => { for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true }); });
function temporary(prefix: string): string { const dir = mkdtempSync(join(tmpdir(), prefix)); roots.push(dir); return dir; }

// ---------------------------------------------------------------- injected verb

function harness(input: { token?: string | null; directories?: string[]; url?: string } = {}) {
  const calls: { dir: string; repo: string; options: UploadOptions }[] = [], steps: string[] = [], boxes: string[][] = [];
  const logs: (string | undefined)[] = [], checked: string[] = [];
  let tokenReads = 0;
  const dependencies: UploadDependencies = {
    credentials: { get: () => { tokenReads++; return input.token === undefined ? "hf_injected" : input.token; } },
    upload: async (dir, repo, options) => {
      calls.push({ dir, repo, options });
      return { ok: true, url: input.url ?? `https://huggingface.co/${repo}`, commitOid: "abc" };
    },
    isDirectory: path => { checked.push(path); return (input.directories ?? ["/models/fused"]).includes(path); },
    step: text => {
      steps.push(`start:${plain(text)}`);
      return { update: t => { steps.push(`update:${plain(t)}`); }, done: t => { steps.push(`done:${plain(t ?? text)}`); },
        fail: t => { steps.push(`fail:${plain(t ?? text)}`); } };
    },
    box: lines => { boxes.push(lines.map(plain)); },
    log: line => { logs.push(line); },
  };
  return { dependencies, calls, steps, boxes, logs, checked, tokenReads: () => tokenReads };
}

test("upload is a documented verb with main's flags and strict parsing", () => {
  expect(help()).toContain("upload");
  for (const marker of ["--path", "--upload-repo", "--private", "mlx_lm.upload", "Usage: mlx-bun upload"]) expect(help("upload")).toContain(marker);
  expect(usage("upload")).toBe(USAGE);
  expect(parse("--path", "/tmp", "--upload-repo", "org/x", "--private")).toEqual({ values: { path: "/tmp", "upload-repo": "org/x", private: true }, positionals: [] });
  expect(() => parse("--path", "/tmp", "--upload-repo")).toThrow(USAGE);
  expect(() => parse("--upload-repo", "--private")).toThrow(USAGE);
  expect(() => parse("--unknown")).toThrow();
  expect(() => parse("--upload-repo", "org/x", "extra")).toThrow("Too many arguments for upload");
  expect(() => parseCommand("get", [])).toThrow("usage: mlx-bun get <org/repo | substring>");
});

test("usage and directory errors happen before any credential read or upload", async () => {
  for (const args of [["--path", "/models/fused"], ["--path", "/models/fused", "--upload-repo=-x"], ["--upload-repo="]]) {
    const run = harness();
    await expect(runUpload(parse(...args), run.dependencies)).rejects.toThrow(USAGE);
    expect(run.checked).toEqual([]); expect(run.tokenReads()).toBe(0); expect(run.calls).toEqual([]); expect(run.steps).toEqual([]);
  }
  const missing = harness();
  await expect(runUpload(parse("--upload-repo", "org/x", "--path", "/nope"), missing.dependencies))
    .rejects.toThrow("not a directory: /nope (pass the model directory via --path)");
  expect(missing.checked).toEqual(["/nope"]); expect(missing.tokenReads()).toBe(0); expect(missing.calls).toEqual([]);
  const defaulted = harness();
  await expect(runUpload(parse("--upload-repo", "org/x"), defaulted.dependencies)).rejects.toThrow("not a directory: mlx_model");
  expect(defaulted.checked).toEqual(["mlx_model"]);
});

test("a missing write token prints main's three sources and never uploads", async () => {
  const run = harness({ token: null });
  await expect(runUpload(parse("--upload-repo", "org/x", "--path", "/models/fused"), run.dependencies)).rejects.toThrow(TOKEN_HELP);
  expect(run.tokenReads()).toBe(1); expect(run.calls).toEqual([]); expect(run.steps).toEqual([]);
});

test("a successful upload forwards main's contract, reports progress, and prints the completion box", async () => {
  const run = harness();
  await runUpload(parse("--upload-repo", "org/x", "--path", "/models/fused"), run.dependencies);
  expect(run.calls.length).toBe(1);
  const { dir, repo, options } = run.calls[0]!;
  expect([dir, repo]).toEqual(["/models/fused", "org/x"]);
  expect(options).toMatchObject({ repoType: "model", private: false, token: "hf_injected", commitMessage: "Upload with mlx-bun" });
  expect(options.signal).toBeUndefined();
  options.onProgress!("model.safetensors", 2 ** 30, 2 ** 31);
  expect(run.steps).toEqual(["start:uploading /models/fused → org/x", "done:uploaded org/x", "update:org/x · model.safetensors · 1.00 GB / 2.00 GB"]);
  expect(run.logs).toEqual([undefined]);
  expect(run.boxes).toEqual([["● upload complete", "", "source    /models/fused", "repo      https://huggingface.co/org/x", "",
    "get it back anywhere:  mlx-bun get org/x"]]);
});

test("--private creates a private repo and marks the completion box", async () => {
  const run = harness({ url: "https://huggingface.co/org/secret" });
  await runUpload(parse("--upload-repo", "org/secret", "--path", "/models/fused", "--private"), run.dependencies);
  expect(run.calls[0]!.options.private).toBe(true);
  expect(run.boxes[0]).toContain("repo      https://huggingface.co/org/secret · private");
});

test("an upload failure fails the step with main's message and rejects for exit 1", async () => {
  const run = harness();
  const failure = new Error("commit failed (HTTP 403: forbidden)");
  run.dependencies.upload = async () => { throw failure; };
  await expect(runUpload(parse("--upload-repo", "org/x", "--path", "/models/fused"), run.dependencies)).rejects.toBe(failure);
  expect(run.steps).toEqual(["start:uploading /models/fused → org/x", "fail:upload failed: commit failed (HTTP 403: forbidden)"]);
  expect(run.boxes).toEqual([]);
});

test("cancellation is forwarded to the uploader and rejects with the signal reason", async () => {
  const reason = new Error("upload cancelled");
  const early = new AbortController(); early.abort(reason);
  const before = harness();
  await expect(runUpload(parse("--upload-repo", "org/x", "--path", "/models/fused"), before.dependencies, early.signal)).rejects.toBe(reason);
  expect(before.calls).toEqual([]); expect(before.steps).toEqual([]);
  const during = harness(), controller = new AbortController();
  during.dependencies.upload = (_dir, _repo, options) => new Promise((_, reject) => {
    options.signal!.addEventListener("abort", () => reject(options.signal!.reason), { once: true });
  });
  const pending = runUpload(parse("--upload-repo", "org/x", "--path", "/models/fused"), during.dependencies, controller.signal);
  await new Promise(resolve => setImmediate(resolve));
  expect(during.steps).toEqual(["start:uploading /models/fused → org/x"]);
  controller.abort(reason);
  await expect(pending).rejects.toBe(reason);
  expect(during.steps).toEqual(["start:uploading /models/fused → org/x", "fail:upload failed: upload cancelled"]);
  expect(during.boxes).toEqual([]);
});

// ---------------------------------------------------------------- spawned CLI

interface Captured { requests: { method: string; path: string; auth: string | null }[]; createBody: unknown; commitBody: string | null }
let cap: Captured = { requests: [], createBody: null, commitBody: null };
let createStatus = 200;
let putGate: { arrived: () => void; release: Promise<void> } | null = null;
const hub = Bun.serve({
  hostname: "127.0.0.1", port: 0,
  async fetch(request) {
    const url = new URL(request.url), path = url.pathname;
    cap.requests.push({ method: request.method, path, auth: request.headers.get("authorization") });
    if (path === "/api/repos/create") {
      if (createStatus !== 200) return new Response("mock failure", { status: createStatus });
      cap.createBody = await request.json();
      return Response.json({ url: `${url.origin}/created` });
    }
    if (/^\/api\/models\/.+\/preupload\/main$/.test(path)) {
      const { files } = await request.json() as { files: { path: string }[] };
      return Response.json({ files: files.map(file => ({ path: file.path, uploadMode: file.path.endsWith(".safetensors") ? "lfs" : "regular" })) });
    }
    if (path.endsWith(".git/info/lfs/objects/batch")) {
      const { objects } = await request.json() as { objects: { oid: string; size: number }[] };
      return Response.json({ objects: objects.map(object => ({ ...object, actions: {
        upload: { href: `${url.origin}/s3-put/${object.oid}` }, verify: { href: `${url.origin}/lfs-verify` } } })) });
    }
    if (path.startsWith("/s3-put/")) {
      await request.arrayBuffer();
      if (putGate) { putGate.arrived(); await putGate.release; }
      return new Response(null, { status: 200 });
    }
    if (path === "/lfs-verify") { await request.arrayBuffer(); return new Response(null, { status: 200 }); }
    if (/^\/api\/models\/.+\/commit\/main$/.test(path)) { cap.commitBody = await request.text(); return Response.json({ commitOid: "feedface" }); }
    return new Response(`unexpected: ${path}`, { status: 404 });
  },
});
const base = `http://127.0.0.1:${hub.port}`;
afterAll(() => hub.stop(true));
beforeEach(() => { cap = { requests: [], createBody: null, commitBody: null }; createStatus = 200; putGate = null; });

const entry = process.env.MLX_BUN_TEST_CLI ?? resolve(import.meta.dir, "../src/cli/main.ts");
/** Isolated $HOME (no saved app token, no HF cache token); HF_TOKEN only when a test invents one.
 * The preload routes huggingface.co to the mock Hub when `network` is set and refuses everything else. */
function spawnCli(home: string, args: string[], input: { token?: string; network?: boolean } = {}) {
  const preload = join(home, "fetch.ts");
  writeFileSync(preload, input.network
    ? `const real = globalThis.fetch;
globalThis.fetch = (input, init) => {
  const url = typeof input === "string" ? input : input instanceof URL ? input.href : input.url;
  return real(url.replace(/^https:\\/\\/huggingface\\.co(?=\\/)/, ${JSON.stringify(base)}), init);
};`
    : 'globalThis.fetch = async input => { throw new Error("unexpected network request: " + String(input)); };');
  const env: Record<string, string> = { ...process.env as Record<string, string>, HOME: home, HF_HUB_OFFLINE: "1", NO_COLOR: "1",
    MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib" };
  delete env.HF_TOKEN;
  if (input.token !== undefined) env.HF_TOKEN = input.token;
  return Bun.spawn([process.execPath, "--no-env-file", "--preload", preload, entry, ...args], { env, stdout: "pipe", stderr: "pipe" });
}
async function finished(proc: ReturnType<typeof spawnCli>) {
  const [out, err, code] = await Promise.all([new Response(proc.stdout).text(), new Response(proc.stderr).text(), proc.exited]);
  return { out, err, code };
}
const cli = (home: string, args: string[], input: { token?: string; network?: boolean } = {}) => finished(spawnCli(home, args, input));
function modelDir(home: string) {
  const dir = join(home, "fused_model"); mkdirSync(dir);
  const weights = new Uint8Array(4096); for (let i = 0; i < weights.length; i++) weights[i] = (i * 7 + 3) & 0xff;
  writeFileSync(join(dir, "model.safetensors"), weights);
  writeFileSync(join(dir, "config.json"), JSON.stringify({ model_type: "qwen3" }));
  writeFileSync(join(dir, "README.md"), "# fused\n");
  return { dir, oid: createHash("sha256").update(weights).digest("hex") };
}

test("overview and help document the verb (ported from main's cli-upload test)", async () => {
  const home = temporary("mlx-upload-help-");
  const overview = await cli(home, ["--help"]);
  expect(overview.code).toBe(0); expect(overview.out).toContain("upload");
  for (const args of [["help", "upload"], ["upload", "--help"]]) {
    const helped = await cli(home, args);
    expect(helped.code).toBe(0);
    for (const marker of ["--upload-repo", "--path", "mlx_lm.upload"]) expect(helped.out).toContain(marker);
  }
});

test("usage, directory, and token errors exit 1 before any network request", async () => {
  const home = temporary("mlx-upload-usage-");
  for (const args of [["upload", "--path", "/tmp"], ["upload", "--path", "/tmp", "--upload-repo"]]) {
    const { code, err } = await cli(home, args);
    expect(code).toBe(1); expect(err).toContain("usage: mlx-bun upload");
  }
  const missing = await cli(home, ["upload", "--upload-repo", "org/x", "--path", "/tmp/definitely-not-a-model-dir"]);
  expect(missing.code).toBe(1); expect(missing.err).toContain("not a directory");
  const untokened = await cli(home, ["upload", "--upload-repo", "org/x", "--path", home]);
  expect(untokened.code).toBe(1);
  for (const marker of ["no Hugging Face token found", "hf auth login", "HF_TOKEN", "~/.mlx-bun/hf.json"]) expect(untokened.err).toContain(marker);
  expect(cap.requests).toEqual([]);
});

test("the real verb pushes create, preupload, LFS, and commit to the mock Hub with the invented bearer token", async () => {
  const home = temporary("mlx-upload-push-");
  const { dir, oid } = modelDir(home);
  const pushed = await cli(home, ["upload", "--path", dir, "--upload-repo", "org/x", "--private"], { token: "hf_invented_for_this_test", network: true });
  expect(pushed.err).toBe(""); expect(pushed.code).toBe(0);
  expect(cap.requests.map(request => `${request.method} ${request.path}`)).toEqual([
    "POST /api/repos/create", "POST /api/models/org/x/preupload/main", "POST /org/x.git/info/lfs/objects/batch",
    `PUT /s3-put/${oid}`, "POST /lfs-verify", "POST /api/models/org/x/commit/main",
  ]);
  for (const request of cap.requests.filter(request => !request.path.startsWith("/s3-put/")))
    expect(request.auth).toBe("Bearer hf_invented_for_this_test");
  expect(cap.createBody).toEqual({ type: "model", name: "x", organization: "org", private: true });
  const lines = cap.commitBody!.trim().split("\n").map(line => JSON.parse(line));
  expect(lines[0]).toEqual({ key: "header", value: { summary: "Upload with mlx-bun", description: "" } });
  expect(lines.filter(line => line.key === "lfsFile").map(line => line.value.path)).toEqual(["model.safetensors"]);
  expect(lines.filter(line => line.key === "file").map(line => line.value.path).sort()).toEqual(["README.md", "config.json"]);
  for (const marker of [`uploading ${dir} → org/x`, "uploaded org/x", "upload complete", `source    ${dir}`,
    "repo      https://huggingface.co/org/x · private", "get it back anywhere:  mlx-bun get org/x"]) expect(pushed.out).toContain(marker);

  // The saved app token outranks HF_TOKEN, and the default repo is public.
  mkdirSync(join(home, ".mlx-bun")); writeFileSync(join(home, ".mlx-bun", "hf.json"), JSON.stringify({ token: "hf_saved_by_app" }));
  cap = { requests: [], createBody: null, commitBody: null };
  const again = await cli(home, ["upload", "--path", dir, "--upload-repo", "org/x"], { token: "hf_env_ignored", network: true });
  expect(again.code).toBe(0);
  expect(cap.requests[0]).toEqual({ method: "POST", path: "/api/repos/create", auth: "Bearer hf_saved_by_app" });
  expect(cap.createBody).toEqual({ type: "model", name: "x", organization: "org", private: false });
  expect(again.out).toContain("repo      https://huggingface.co/org/x ");
  expect(again.out).not.toContain("· private");
});

test("SIGINT mid-transfer aborts the upload, exits 1, and never commits", async () => {
  const home = temporary("mlx-upload-sigint-");
  const { dir, oid } = modelDir(home);
  let arrived!: () => void, release!: () => void;
  const putArrived = new Promise<void>(resolve => { arrived = resolve; });
  putGate = { arrived, release: new Promise<void>(resolve => { release = resolve; }) };
  const proc = spawnCli(home, ["upload", "--path", dir, "--upload-repo", "org/x"], { token: "hf_invented_for_this_test", network: true });
  let result;
  try {
    await putArrived;
    proc.kill("SIGINT");
    result = await finished(proc);
  } finally { release(); }
  expect(result.code).toBe(1);
  expect(result.out).toContain("upload failed: upload cancelled");
  expect(result.err).toBe("upload cancelled\n");
  expect(cap.requests.map(request => request.path)).toEqual([
    "/api/repos/create", "/api/models/org/x/preupload/main", "/org/x.git/info/lfs/objects/batch", `/s3-put/${oid}`,
  ]);
  expect(cap.commitBody).toBeNull();
});

test("a Hub failure fails the step, prints the error, and exits 1", async () => {
  const home = temporary("mlx-upload-fail-");
  const { dir } = modelDir(home);
  createStatus = 401;
  const failed = await cli(home, ["upload", "--path", dir, "--upload-repo", "org/x"], { token: "hf_invented_for_this_test", network: true });
  expect(failed.code).toBe(1);
  expect(failed.out).toContain("upload failed: create repo failed (HTTP 401");
  expect(failed.err).toContain("HTTP 401");
  expect(cap.requests.map(request => request.path)).toEqual(["/api/repos/create"]);
  expect(cap.commitBody).toBeNull();
});
