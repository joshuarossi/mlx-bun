import { afterEach, beforeEach, expect, test } from "bun:test";
import { mkdtempSync, rmSync, mkdirSync, writeFileSync, readdirSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { CatalogEntry, JobEvent, JobRecord, ModelCatalog } from "@mlx-bun/app-core";
import { createRegistryCatalog } from "@mlx-bun/app-services";
import { createQuantizeHandlers, createQuantizeRunner as createRunner, inspectModel } from "../src";

/** The producer with the job service's cancellation signal supplied, as the host runs it. */
const createQuantizeRunner = (...args: Parameters<typeof createRunner>) => {
  const run = createRunner(...args);
  return (emit: Parameters<typeof run>[0], config: Parameters<typeof run>[1]) => run(emit, config, new AbortController().signal);
};

let root = "", oldHub: string | undefined;
beforeEach(() => { root = mkdtempSync(join(tmpdir(), "mlx-quantize-policy-")); oldHub = process.env.HF_HUB_CACHE; process.env.HF_HUB_CACHE = root; });
afterEach(() => { if (oldHub === undefined) delete process.env.HF_HUB_CACHE; else process.env.HF_HUB_CACHE = oldHub; rmSync(root, { recursive: true, force: true }); });
function model(path: string) {
  mkdirSync(path, { recursive: true });
  writeFileSync(join(path, "config.json"), JSON.stringify({ model_type: "qwen3", architectures: ["Qwen3ForCausalLM"], hidden_size: 16,
    intermediate_size: 32, num_hidden_layers: 1, num_attention_heads: 2, num_key_value_heads: 2, vocab_size: 32, head_dim: 8, rms_norm_eps: 1e-6 }));
}

/** A catalog over a fixed list, as the host's registry-backed one answers `find`. */
const catalogOf = (entries: Partial<CatalogEntry>[] = []): Pick<ModelCatalog, "find" | "locate"> => ({
  find: async query => {
    const hit = entries.find(entry => entry.id === query);
    if (!hit) throw new Error(`no model matching "${query}" — run \`mlx-bun scan\``);
    return { kind: "model", bytes: 0, operations: [], directory: "", ...hit } as CatalogEntry;
  },
  locate: async () => undefined,
});

test("producer forwards mixed precision and rotation options and maps library progress", async () => {
  const events: JobEvent[] = [], calls: unknown[][] = [];
  const transform = { name: "test" };
  const run = createQuantizeRunner(catalogOf(), {
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

test("a trellis config reaches the packed-Trellis producer with every option and rejects bad ones before native work", async () => {
  const events: JobEvent[] = [], calls: unknown[][] = [];
  const run = createQuantizeRunner(catalogOf(), {
    trellis: (async (...args: any[]) => { calls.push(args); args[3]({ stage: "quantizing", progress: 0.5, message: "half" });
      return { outDir: args[1], nTrellis: 12, nAffine: 29, effectiveBpw: 3.52 }; }) as any,
    quantize: (async () => { throw new Error("must not run the affine quantizer"); }) as any,
  });
  const output = await run(event => events.push(event), { src_dir: "/src", out_dir: "/dst", mode: "trellis", rotation_seed: 7, trellis_bits: 2,
    trellis_down_axis: "in", trellis_k_map: "/kmap.json", trellis_k_budget: "2.5", trellis_ldlq: "/hessians", trellis_reuse: ["/a", "/b"],
    trellis_interleave: true, trellis_layers: 6 });
  expect(calls[0]!.slice(0, 3)).toEqual(["/src", "/dst", { bits: 2, seed: 7, downAxis: "in", kMap: { path: "/kmap.json", budget: "2.5" },
    ldlq: "/hessians", reuse: ["/a", "/b"], interleave: true, layers: 6 }]);
  expect(events).toContainEqual({ type: "stage", stage: "quantizing", progress: 0.5, message: "half" });
  expect(events.at(-1)).toMatchObject({ stage: "done", message: "Quantized 12 trellis + 29 affine modules (3.52 bpw)", output_dir: "/dst" });
  expect(output).toEqual({ outputPath: "/dst" });
  await run(() => {}, { src_dir: "/src", out_dir: "/dst2", mode: "trellis" });
  expect(calls[1]!.slice(0, 3)).toEqual(["/src", "/dst2", { bits: 3, seed: 42, downAxis: "out" }]);
  const strict = createQuantizeRunner(catalogOf());
  await expect(strict(() => {}, { src_dir: "/src", out_dir: "x", mode: "trellis", trellis_down_axis: "up" })).rejects.toThrow("trellis_down_axis must be out or in");
  await expect(strict(() => {}, { src_dir: "/src", out_dir: "x", mode: "trellis", rotation_seed: 0.5 })).rejects.toThrow("rotation_seed must be an integer");
});

test("invalid producer options reject before loading native libraries", async () => {
  const run = createQuantizeRunner(catalogOf());
  for (const config of [{}, { out_dir: "x", bits: 3 }, { out_dir: "x", group_size: 3 },
    { out_dir: "x", src_dir: "y", rotate_weights: true, rotation_seed: 0.5 }]) {
    await expect(run(() => {}, config)).rejects.toThrow();
  }
});

test("CPU inspection reads local configuration without loading tensor bytes", async () => {
  const path = join(root, "model"); model(path);
  expect(await inspectModel(catalogOf(), path)).toMatchObject({ ok: true, arch: "qwen3", support: true, size_gb: 0 });
  mkdirSync(join(root, "missing"));
  expect(await inspectModel(catalogOf(), join(root, "missing"))).toMatchObject({ ok: false, support: false });
});

/** The module's routes over a recording job service and a storage view that only names paths. */
function handlers(store: string, jobs: JobRecord[] = [], catalog: Pick<ModelCatalog, "find" | "locate"> = catalogOf()) {
  const submitted: Parameters<Parameters<typeof createQuantizeHandlers>[0]["jobs"]["submit"]>[0][] = [];
  const routes = createQuantizeHandlers({ catalog, storage: { path: key => join(store, key) },
    jobs: { submit: async submission => { submitted.push(submission); return { id: "job_test", kind: submission.kind, status: "queued", progress: 0, message: null,
      outputPath: null, error: null, startedAt: "", endedAt: null } as JobRecord; } } });
  const post = (route: keyof typeof routes, body: unknown) => routes[route](new Request(`http://x/api/quantize/${route}`, { method: "POST", body: typeof body === "string" ? body : JSON.stringify(body) }));
  return { post, submitted, jobs };
}

test("submit names a plain model directory under the storage root and forwards quantization policy to the host", async () => {
  const store = join(root, "store");
  const { post, submitted } = handlers(store);
  const body = await (await post("submit", {
    model_id: "example/model", bits: 8, group_size: 32, target_bpw: 3.8, candidate_bits: [2, 4, 8], rotate_weights: true, rotation_seed: 21,
  })).json();
  expect(body.ok).toBe(true); expect(body.job_id).toBe("job_test");
  expect(body.output_dir).toBe(join(store, "models", "model-mixed-3.8bpw-rot21"));
  expect(submitted[0]).toMatchObject({ kind: "quantize", outputPath: body.output_dir, config: { model_id: "example/model", out_dir: body.output_dir,
    bits: 8, group_size: 32, target_bpw: 3.8, candidate_bits: [2, 4, 8], rotate_weights: true, rotation_seed: 21 } });
  expect(readdirSync(root)).toEqual([]); // nothing is written into the hub cache
  const missing = await post("submit", "{}");
  expect(missing.status).toBe(400);
  expect(submitted).toHaveLength(1);
});

test("submit refuses a non-numeric bits, target_bpw or rotation_seed, which would name a directory outside the models store", async () => {
  const store = join(root, "store");
  const { post, submitted } = handlers(store);
  for (const body of [{ target_bpw: "1/../../../escape" }, { bits: "4/../../x" }, { rotate_weights: true, rotation_seed: "1/../../x" },
    { bits: "4" }, { target_bpw: { toString: null } }, { target_bpw: [5] }]) {
    const response = await post("submit", { model_id: "example/model", ...body });
    expect(response.status).toBe(400);
    expect((await response.json()).error).toMatch(/must be a finite number/);
  }
  // JSON has no Infinity or NaN; a huge exponent overflows to Infinity.
  expect((await post("submit", '{"model_id":"example/model","target_bpw":1e999}')).status).toBe(400);
  expect(submitted).toHaveLength(0);
  const plain = await (await post("submit", { model_id: "example/model", target_bpw: null })).json();
  expect(plain.output_dir).toBe(join(store, "models", "model-4bit"));
});

test("inspect answers from the catalog's entry: its model type and size, without reading tensors", async () => {
  const path = join(root, "model"); model(path);
  const { post } = handlers(join(root, "store"), [], catalogOf([{ id: "example/model", directory: path, bytes: 3 * (1 << 30), modelType: "qwen3-catalog" }]));
  expect(await (await post("inspect", { model_id: "example/model" })).json()).toEqual({ ok: true, model_id: "example/model", arch: "qwen3-catalog", support: true, size_gb: 3 });
  expect(await (await post("inspect", { model_id: "unknown/model" })).json()).toMatchObject({ ok: false, error: expect.stringContaining('no model matching "unknown/model"') });
});

test("resolve-folder locates a cached snapshot through the host's catalog, and says so when it cannot", async () => {
  const repo = join(root, "models--example--model"), snapshot = join(repo, "snapshots", "aabb"); model(snapshot);
  mkdirSync(join(repo, "refs")); writeFileSync(join(repo, "refs/main"), "aabb");
  const catalog = createRegistryCatalog({ registry: () => ({ list: () => [], listCanonical: () => [], resolve: () => { throw new Error("unused"); },
    scan: async () => ({}) as never, close() {} }), modelsRoot: () => join(root, "models") });
  const { post } = handlers(join(root, "store"), [], catalog);
  expect(await (await post("resolve-folder", { folder_name: "models--example--model" })).json()).toEqual({ ok: true, path: snapshot, repo_id: "example/model" });
  expect(await (await post("resolve-folder", { folder_name: "nothing-here" })).json())
    .toEqual({ ok: false, error: "Couldn't locate this folder on disk — paste the path instead." });
});
