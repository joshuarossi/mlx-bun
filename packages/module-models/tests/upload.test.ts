// The upload verb (main's mlx_lm.upload counterpart), model-free: usage, validation, token resolution, the publish contract,
// the completion box, failure and cancellation. The spawned verb against a mock Hub is `apps/mlx-bun/tests/upload-cli.test.ts`.
import { expect, test } from "bun:test";
import { parseVerb, verbHelp } from "@mlx-bun/app-services/verbs";
import type { PublishRequest } from "@mlx-bun/app-core";
import { manifest } from "../src/manifest";
import { runUpload, UPLOAD_USAGE } from "../src";
import { fakeCatalog, invoke } from "./support";

const spec = manifest.verbs.find(verb => verb.name === "upload")! as never;
const parse = (...args: string[]) => parseVerb("mlx-bun", spec, args);
const TOKEN_HELP = [
  "no Hugging Face token found — uploading needs a WRITE token from one of:",
  "  hf auth login                  (~/.cache/huggingface/token)",
  "  export HF_TOKEN=hf_…",
  "  web UI Settings → Hugging Face (~/.mlx-bun/hf.json)",
].join("\n");

function harness(input: { token?: boolean; directories?: string[]; url?: string } = {}) {
  const calls: { directory: string; request: PublishRequest }[] = [], checked: string[] = [];
  let tokenReads = 0;
  const catalog = fakeCatalog([], {
    canPublish: () => { tokenReads++; return input.token ?? true; },
    async publish(directory, request) { calls.push({ directory, request }); return { url: input.url ?? `https://huggingface.co/${request.repoId}` }; },
  });
  const dependencies = { isDirectory: (path: string) => { checked.push(path); return (input.directories ?? ["/models/fused"]).includes(path); } };
  const run = (args: string[], signal?: AbortSignal) => { const { invocation, console } = invoke("upload", args, signal); return { console, promise: runUpload(invocation, catalog, dependencies) }; };
  return { run, calls, checked, tokenReads: () => tokenReads, catalog, dependencies };
}

test("upload is a documented verb with main's flags and strict parsing", () => {
  const help = verbHelp("mlx-bun", spec);
  for (const marker of ["--path", "--upload-repo", "--private", "mlx_lm.upload", "Usage: mlx-bun upload"]) expect(help).toContain(marker);
  expect(UPLOAD_USAGE).toBe("usage: mlx-bun upload --path <model-dir> --upload-repo <org/repo> [--private]");
  expect(parse("--path", "/tmp", "--upload-repo", "org/x", "--private")).toEqual({ values: { path: "/tmp", "upload-repo": "org/x", private: true }, positionals: [] });
  expect(() => parse("--path", "/tmp", "--upload-repo")).toThrow(UPLOAD_USAGE);
  expect(() => parse("--upload-repo", "--private")).toThrow(UPLOAD_USAGE);
  expect(() => parse("--unknown")).toThrow();
  expect(() => parse("--upload-repo", "org/x", "extra")).toThrow("Too many arguments for upload");
  const get = manifest.verbs.find(verb => verb.name === "get")! as never;
  expect(() => parseVerb("mlx-bun", get, [])).toThrow("usage: mlx-bun get <org/repo | substring>");
});

test("usage and directory errors happen before any credential read or upload", async () => {
  for (const args of [["--path", "/models/fused"], ["--path", "/models/fused", "--upload-repo=-x"], ["--upload-repo="]]) {
    const run = harness(), verb = run.run(args);
    await expect(verb.promise).rejects.toThrow(UPLOAD_USAGE);
    expect(run.checked).toEqual([]); expect(run.tokenReads()).toBe(0); expect(run.calls).toEqual([]); expect(verb.console.steps).toEqual([]);
  }
  const missing = harness();
  await expect(missing.run(["--upload-repo", "org/x", "--path", "/nope"]).promise).rejects.toThrow("not a directory: /nope (pass the model directory via --path)");
  expect(missing.checked).toEqual(["/nope"]); expect(missing.tokenReads()).toBe(0); expect(missing.calls).toEqual([]);
  // No working-directory default: --path is required.
  const pathless = harness();
  await expect(pathless.run(["--upload-repo", "org/x"]).promise).rejects.toThrow(UPLOAD_USAGE);
  expect(pathless.checked).toEqual([]); expect(pathless.tokenReads()).toBe(0);
});

test("a missing write token prints main's three sources and never uploads", async () => {
  const run = harness({ token: false }), verb = run.run(["--upload-repo", "org/x", "--path", "/models/fused"]);
  await expect(verb.promise).rejects.toThrow(TOKEN_HELP);
  expect(run.tokenReads()).toBe(1); expect(run.calls).toEqual([]); expect(verb.console.steps).toEqual([]);
});

test("a successful upload forwards main's contract, reports progress, and prints the completion box", async () => {
  const run = harness(), verb = run.run(["--upload-repo", "org/x", "--path", "/models/fused"]);
  expect(await verb.promise).toBe(0);
  expect(run.calls.length).toBe(1);
  const { directory, request } = run.calls[0]!;
  expect(directory).toBe("/models/fused");
  expect(request).toMatchObject({ repoId: "org/x", private: false, commitMessage: "Upload with mlx-bun" });
  request.onProgress!("model.safetensors", 2 ** 30, 2 ** 31);
  expect(verb.console.steps).toEqual(["start:uploading /models/fused → org/x", "done:uploaded org/x", "update:org/x · model.safetensors · 1.00 GB / 2.00 GB"]);
  expect(verb.console.out).toEqual(["\n"]);
  expect(verb.console.boxes).toEqual([["● upload complete", "", "source    /models/fused", "repo      https://huggingface.co/org/x", "",
    "get it back anywhere:  mlx-bun get org/x"]]);
});

test("--private creates a private repo and marks the completion box", async () => {
  const run = harness({ url: "https://huggingface.co/org/secret" }), verb = run.run(["--upload-repo", "org/secret", "--path", "/models/fused", "--private"]);
  await verb.promise;
  expect(run.calls[0]!.request.private).toBe(true);
  expect(verb.console.boxes[0]).toContain("repo      https://huggingface.co/org/secret · private");
});

test("an upload failure fails the step with main's message and rejects for exit 1", async () => {
  const run = harness();
  const failure = new Error("commit failed (HTTP 403: forbidden)");
  const catalog = fakeCatalog([], { canPublish: () => true, publish: async () => { throw failure; } });
  const { invocation, console } = invoke("upload", ["--upload-repo", "org/x", "--path", "/models/fused"]);
  await expect(runUpload(invocation, catalog, run.dependencies)).rejects.toBe(failure);
  expect(console.steps).toEqual(["start:uploading /models/fused → org/x", "fail:upload failed: commit failed (HTTP 403: forbidden)"]);
  expect(console.boxes).toEqual([]);
});

test("cancellation is forwarded to the publisher and rejects with the signal reason", async () => {
  const reason = new Error("upload cancelled");
  const early = new AbortController(); early.abort(reason);
  const before = harness(), first = before.run(["--upload-repo", "org/x", "--path", "/models/fused"], early.signal);
  await expect(first.promise).rejects.toBe(reason);
  expect(before.calls).toEqual([]); expect(first.console.steps).toEqual([]);
  const controller = new AbortController();
  const catalog = fakeCatalog([], { canPublish: () => true, publish: (_directory, request) => new Promise((_, reject) => {
    request.signal!.addEventListener("abort", () => reject(request.signal!.reason), { once: true });
  }) });
  const { invocation, console } = invoke("upload", ["--upload-repo", "org/x", "--path", "/models/fused"], controller.signal);
  const pending = runUpload(invocation, catalog, { isDirectory: () => true });
  await new Promise(resolve => setImmediate(resolve));
  expect(console.steps).toEqual(["start:uploading /models/fused → org/x"]);
  controller.abort(reason);
  await expect(pending).rejects.toBe(reason);
  expect(console.steps).toEqual(["start:uploading /models/fused → org/x", "fail:upload failed: upload cancelled"]);
  expect(console.boxes).toEqual([]);
});
