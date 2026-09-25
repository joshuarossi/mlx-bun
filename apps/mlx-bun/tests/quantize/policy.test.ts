import { afterEach, beforeEach, expect, test } from "bun:test";
import { mkdtempSync, rmSync, mkdirSync, writeFileSync, readFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { createQuantizeRunner } from "../../src/quantize/job";
import { inspectModel } from "../../src/quantize/inspect";
import { createQuantizeRoutes } from "../../src/server/quantize-routes";
import type { JobEvent } from "../../src/jobs/protocol";

let root = "", oldHub: string | undefined;
beforeEach(() => { root = mkdtempSync(join(tmpdir(), "mlx-quantize-policy-")); oldHub = process.env.HF_HUB_CACHE; process.env.HF_HUB_CACHE = root; });
afterEach(() => { if (oldHub === undefined) delete process.env.HF_HUB_CACHE; else process.env.HF_HUB_CACHE = oldHub; rmSync(root, { recursive: true, force: true }); });
function model(path: string) {
  mkdirSync(path, { recursive: true });
  writeFileSync(join(path, "config.json"), JSON.stringify({ model_type: "qwen3", architectures: ["Qwen3ForCausalLM"], hidden_size: 16,
    intermediate_size: 32, num_hidden_layers: 1, num_attention_heads: 2, num_key_value_heads: 2, vocab_size: 32, head_dim: 8, rms_norm_eps: 1e-6 }));
}

test("producer forwards mixed precision and rotation options and maps library progress", async () => {
  const events: JobEvent[] = [], calls: unknown[][] = [];
  const transform = { name: "test" };
  const run = createQuantizeRunner({
    quantize: (async (...args: any[]) => { calls.push(args); args[3]({ stage: "writing", progress: 0.8, message: "write" });
      return { outDir: args[1], nQuantized: 7, achievedBpw: 3.8 }; }) as any,
    rotation: ((options: unknown) => { expect(options).toEqual({ seed: 21 }); return transform; }) as any,
  });
  const output = await run(event => events.push(event), { src_dir: "/synthetic/source", out_dir: "/synthetic/result", bits: 8,
    group_size: 32, target_bpw: 3.8, candidate_bits: [2, 4, 8], reference: "artifact", calibration_mix: "default", n_calibration: 4,
    rotate_weights: true, rotation_seed: 21 });
  expect(calls[0]?.slice(0, 3)).toEqual(["/synthetic/source", "/synthetic/result", { bits: 8, groupSize: 32, mode: "affine",
    targetBpw: 3.8, candidateBits: [2, 4, 8], reference: "artifact", calibrationMix: "default", nCalibration: 4, weightTransform: transform }]);
  expect(events).toContainEqual({ type: "stage", stage: "writing", progress: 0.8, message: "write" });
  expect(events.at(-1)).toMatchObject({ type: "stage", stage: "done", progress: 1, output_dir: "/synthetic/result" });
  expect(output).toEqual({ outputPath: "/synthetic/result" });
});

test("invalid producer options reject before loading native libraries", async () => {
  const run = createQuantizeRunner();
  for (const config of [{}, { out_dir: "x", bits: 3 }, { out_dir: "x", group_size: 3 },
    { out_dir: "x", src_dir: "y", rotate_weights: true, rotation_seed: 0.5 }]) {
    await expect(run(() => {}, config)).rejects.toThrow();
  }
});

test("CPU inspection reads local configuration without loading tensor bytes", async () => {
  const path = join(root, "model"); model(path);
  expect(await inspectModel(path)).toMatchObject({ ok: true, arch: "qwen3", support: true, size_gb: 0 });
  mkdirSync(join(root, "missing"));
  expect(await inspectModel(join(root, "missing"))).toMatchObject({ ok: false, support: false });
});

test("submit keeps main's output naming and forwards quantization policy to the host", async () => {
  let captured: unknown[] = [];
  const routes = createQuantizeRoutes({ submit(...args) { captured = args; return { jobId: "job_test" }; } });
  const response = await routes.handle(new Request("http://x/api/quantize/submit", { method: "POST", body: JSON.stringify({
    model_id: "example/model", bits: 8, group_size: 32, target_bpw: 3.8, candidate_bits: [2, 4, 8], rotate_weights: true, rotation_seed: 21,
  }) }));
  const body = await response!.json();
  expect(body.ok).toBe(true); expect(body.job_id).toBe("job_test");
  expect(body.output_dir).toStartWith(join(root, "models--example--model-OptiQ-mixed-3.8bpw-rot21", "snapshots"));
  expect(captured[0]).toBe("quantize"); expect(captured[1]).toMatchObject({ model_id: "example/model", out_dir: body.output_dir,
    target_bpw: 3.8, candidate_bits: [2, 4, 8], rotate_weights: true, rotation_seed: 21 });
  expect(readFileSync(join(root, "models--example--model-OptiQ-mixed-3.8bpw-rot21", "refs/main"), "utf8")).toMatch(/^[0-9a-f]{40}$/);
  expect(captured[2]).toBe(body.output_dir);
});

test("resolve-folder locates a cached snapshot and unrelated producer routes remain deferred", async () => {
  const repo = join(root, "models--example--model"), snapshot = join(repo, "snapshots", "aabb"); model(snapshot);
  mkdirSync(join(repo, "refs")); writeFileSync(join(repo, "refs/main"), "aabb");
  const routes = createQuantizeRoutes({ submit() { throw new Error("not submitted"); } });
  const response = await routes.handle(new Request("http://x/api/model/resolve-folder", { method: "POST", body: JSON.stringify({ folder_name: "models--example--model" }) }));
  expect(await response!.json()).toEqual({ ok: true, path: snapshot, repo_id: "example/model" });
  for (const path of ["/api/dataset/submit", "/api/finetune/submit"]) {
    expect(await routes.handle(new Request(`http://x${path}`, { method: "POST" }))).toBeNull();
  }
  expect((await routes.handle(new Request("http://x/api/quantize/submit", { method: "POST", body: "{}" })))?.status).toBe(400);
});
