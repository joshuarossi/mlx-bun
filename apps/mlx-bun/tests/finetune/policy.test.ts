import { afterEach, expect, spyOn, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { TrainConfig } from "@mlx-bun/training";
import type { JobEvent } from "../../src/jobs/protocol";
import { parseFinetuneConfig } from "../../src/finetune/config";
import { createFinetuneRunner, type FinetuneRuntime } from "../../src/finetune/job";
import { inspectDataset } from "../../src/finetune/inspect";
import { createFinetuneRoutes } from "../../src/server/finetune-routes";
import { pendingRoute } from "../../src/server/start";

// Deliberately distinctive supplied library defaults: app policy must not
// silently replace them with a second copy of DEFAULT_TRAIN_CONFIG.
const defaults = { rank: 73, scale: 9, learningRate: 0.02, segmentSize: 0,
  orpoChunkSize: 0, orpoFusedCe: false, orpoFlashCe: false, orpoPrefixShared: false,
  sftScope: "full", betas: [0.7, 0.8], warmStartAdapter: "" } as TrainConfig;
const paths = { model_dir: "/synthetic/model", data_dir: "/synthetic/data", adapter_path: "/synthetic/adapter" };

test("resolved SFT, DPO, and ORPO configs preserve main's API defaults", () => {
  // Captured from main src/train/trainer.ts + src/train/job.ts. This is a test
  // input/expectation, never an alternative production source of defaults.
  const mainLibraryDefaults: TrainConfig = {
    method: "sft", rank: 8, scale: 1, rankScaling: "by_bits",
    targetModules: ["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"],
    numLayers: -1, iters: 100, learningRate: 2e-4, maxSeqLen: 512, batchSize: 1,
    gradAccumSteps: 1, seed: 0, stepsPerReport: 10, stepsPerEval: 50, betas: [0.9, 0.999],
    weightDecay: 0.01, loraDropout: 0, rsLora: false, loraPlusRatio: 1, mlpSplit: false,
    gradCheckpoint: false, segmentSize: 0, saveCheckpoints: false, gradClipNorm: 1,
    valMaxExamples: 256, dpoBeta: 0.1, dpoWarmupIters: 0, dpoLrSchedule: "cosine",
    orpoLambda: 0.1, orpoWarmupIters: 0, orpoLrSchedule: "cosine", orpoChunkSize: 0,
    orpoFusedCe: false, orpoFlashCe: false, orpoPrefixShared: false, sftScope: "full",
    warmStartAdapter: "", adapterPath: "adapters", baseModel: "",
  };
  const expectedSft = { ...mainLibraryDefaults, adapterPath: paths.adapter_path, baseModel: paths.model_dir };
  expect(parseFinetuneConfig(paths, mainLibraryDefaults).cfg).toEqual(expectedSft);
  expect(parseFinetuneConfig({ ...paths, method: "dpo" }, mainLibraryDefaults).cfg)
    .toEqual({ ...expectedSft, method: "dpo", learningRate: 5e-5 });
  expect(parseFinetuneConfig({ ...paths, method: "orpo" }, mainLibraryDefaults).cfg)
    .toEqual({ ...expectedSft, method: "orpo", learningRate: 1e-5, segmentSize: 2,
      orpoChunkSize: 512, orpoFlashCe: true, orpoPrefixShared: true });
});

test("SFT inherits supplied library policy while DPO and ORPO preserve app learning rates and recipe", () => {
  const sft = parseFinetuneConfig(paths, defaults).cfg;
  expect(sft).toMatchObject({ ...defaults, method: "sft", baseModel: paths.model_dir, adapterPath: paths.adapter_path });
  expect(parseFinetuneConfig({ ...paths, method: "dpo" }, defaults).cfg.learningRate).toBe(5e-5);
  const orpo = parseFinetuneConfig({ ...paths, method: "orpo" }, defaults).cfg;
  expect(orpo).toMatchObject({ rank: 73, learningRate: 1e-5, segmentSize: 2, orpoChunkSize: 512,
    orpoFlashCe: true, orpoFusedCe: false, orpoPrefixShared: true, sftScope: "full" });
  expect(defaults.orpoFlashCe).toBe(false);
});

test("explicit web/API options win, including zero and false overrides of the ORPO recipe", () => {
  expect(parseFinetuneConfig({ ...paths, method: "orpo", rank: 16, scale: 1, rank_scaling: "constant",
    target_modules: ["q_proj"], num_layers: 2, iters: 3, learning_rate: 0.001, max_seq_length: 128,
    batch_size: 2, grad_accumulation_steps: 4, seed: 11, steps_per_report: 1, steps_per_eval: 2,
    weight_decay: 0, lora_dropout: 0.1, rs_lora: true, lora_plus_ratio: 2, grad_checkpoint: true,
    mlp_split: true, segment_size: 0, save_checkpoints: true, grad_clip_norm: 0, val_max_examples: 0,
    dpo_beta: 0.2, dpo_warmup_iters: 2, dpo_lr_schedule: "constant", orpo_lambda: 0.3,
    orpo_warmup_iters: 4, orpo_lr_schedule: "constant", orpo_chunk_size: 0, orpo_fused_ce: false,
    orpo_flash_ce: false, orpo_prefix_shared: false, sft_scope: "response", warm_start_adapter: "/previous",
  }, defaults).cfg).toEqual({ method: "orpo", rank: 16, scale: 1, rankScaling: "constant",
    targetModules: ["q_proj"], numLayers: 2, iters: 3, learningRate: 0.001, maxSeqLen: 128,
    batchSize: 2, gradAccumSteps: 4, seed: 11, stepsPerReport: 1, stepsPerEval: 2, betas: [0.7, 0.8],
    weightDecay: 0, loraDropout: 0.1, rsLora: true, loraPlusRatio: 2, gradCheckpoint: true,
    mlpSplit: true, segmentSize: 0, saveCheckpoints: true, gradClipNorm: 0, valMaxExamples: 0,
    dpoBeta: 0.2, dpoWarmupIters: 2, dpoLrSchedule: "constant", orpoLambda: 0.3,
    orpoWarmupIters: 4, orpoLrSchedule: "constant", orpoChunkSize: 0, orpoFusedCe: false,
    orpoFlashCe: false, orpoPrefixShared: false, sftScope: "response", warmStartAdapter: "/previous",
    baseModel: paths.model_dir, adapterPath: paths.adapter_path });
  expect(() => parseFinetuneConfig({ ...paths, sft_scope: "typo" }, defaults)).toThrow("sft_scope");
});

function runtime() {
  const calls: string[] = [], configs: TrainConfig[] = [];
  const r: FinetuneRuntime = {
    defaults,
    loadConfig: async () => ({ quantization: undefined }) as unknown as Awaited<ReturnType<FinetuneRuntime["loadConfig"]>>,
    openWeights: async () => ({ dispose() { calls.push("weights"); } }) as Awaited<ReturnType<FinetuneRuntime["openWeights"]>>,
    createModel: () => ({ dispose() { calls.push("model"); } }) as ReturnType<FinetuneRuntime["createModel"]>,
    loadTokenizer: async () => ({}) as Awaited<ReturnType<FinetuneRuntime["loadTokenizer"]>>,
    loadTemplate: async () => ({}) as Awaited<ReturnType<FinetuneRuntime["loadTemplate"]>>,
    train: async (_model, _tokenizer, _template, dir, config, emit) => {
      expect(dir).toBe(paths.data_dir); configs.push(config); calls.push("train");
      emit!({ type: "metric", kind: "train", step: 1, loss: 0.5 });
      return { adapterPath: config.adapterPath } as Awaited<ReturnType<FinetuneRuntime["train"]>>;
    },
    recommendedLimit: () => 100, setWiredLimit(limit) { calls.push(`limit:${limit}`); return 20; },
    synchronize() { calls.push("sync"); },
  };
  return { r, calls, configs };
}

test("child forwards training progress, falls back for bf16 ORPO heads, and restores/releases resources", async () => {
  const { r, calls, configs } = runtime(), events: JobEvent[] = [];
  expect(await createFinetuneRunner(async () => r)(event => events.push(event), { ...paths, method: "orpo" }))
    .toEqual({ outputPath: paths.adapter_path });
  expect(configs[0]).toMatchObject({ orpoFlashCe: false, orpoFusedCe: false, orpoPrefixShared: true, segmentSize: 2 });
  expect(events).toContainEqual({ type: "metric", kind: "train", step: 1, loss: 0.5 });
  expect(events.some(event => event.type === "stage" && event.message?.includes("unquantized base"))).toBe(true);
  expect(calls).toEqual(["limit:100", "train", "sync", "limit:20", "model", "weights"]);
});

test("quantized ORPO retains the submitted optimized head policy", async () => {
  const { r, configs } = runtime();
  r.loadConfig = async () => ({ quantization: { bits: 4, groupSize: 64 } }) as unknown as Awaited<ReturnType<FinetuneRuntime["loadConfig"]>>;
  await createFinetuneRunner(async () => r)(() => {}, { ...paths, method: "orpo" });
  expect(configs[0]).toMatchObject({ orpoFlashCe: true, orpoPrefixShared: true });
});

test("load failure releases already-owned resources without changing the wired limit", async () => {
  const { r, calls } = runtime();
  r.loadTokenizer = async () => { throw new Error("tokenizer failed"); };
  await expect(createFinetuneRunner(async () => r)(() => {}, paths)).rejects.toThrow("tokenizer failed");
  expect(calls).toEqual(["model", "weights"]);
});

test("training and cleanup errors are both retained while every resource is released once", async () => {
  const { r, calls } = runtime();
  const trainError = new Error("train failed"), syncError = new Error("sync failed");
  r.train = async () => { throw trainError; };
  r.synchronize = () => { calls.push("sync"); throw syncError; };
  let caught: unknown;
  try { await createFinetuneRunner(async () => r)(() => {}, paths); } catch (error) { caught = error; }
  expect(caught).toBeInstanceOf(AggregateError);
  expect((caught as AggregateError).errors).toEqual([trainError, syncError]);
  expect(calls).toEqual(["limit:100", "sync", "limit:20", "model", "weights"]);
});

test("incomplete child configs fail before importing a native runtime", async () => {
  for (const config of [{}, { model_dir: "x" }, { model_dir: "x", data_dir: "y" }])
    await expect(createFinetuneRunner()(() => {}, config)).rejects.toThrow("finetune job: missing");
});

const dirs: string[] = [];
afterEach(() => { for (const dir of dirs.splice(0)) rmSync(dir, { recursive: true, force: true }); });
const post = (path: string, body: unknown) => new Request(`http://x/api/finetune/${path}`, { method: "POST", body: JSON.stringify(body) });

test("dataset inspection counts nonblank rows and probes training format without loading MLX", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-finetune-")); dirs.push(dir);
  writeFileSync(join(dir, "train.jsonl"), '\n{"text":"first"}\n{"text":"second"}\n');
  writeFileSync(join(dir, "valid.jsonl"), '{"text":"validation"}\n');
  const routes = createFinetuneRoutes({ submit() { throw new Error("unexpected submit"); } });
  expect(await (await routes.handle(post("inspect-dataset", { path: dir })))!.json())
    .toEqual({ ok: true, n_train: 2, n_valid: 1, format: "text" });
  writeFileSync(join(dir, "train.jsonl"), "broken");
  expect(await inspectDataset(dir)).toMatchObject({ ok: false, n_train: 0, n_valid: 0, format: "unknown" });
  expect(await inspectDataset(join(dir, "absent"))).toMatchObject({ ok: false });
});

test("submit forwards caller model and all policy to the host, independently of the resident model", async () => {
  const calls: unknown[][] = [];
  const routes = createFinetuneRoutes({ submit(...args) { calls.push(args); return { jobId: "job_test" }; } }, () => "/default/adapter");
  const body = { model_dir: paths.model_dir, data_dir: paths.data_dir, method: "orpo", rank: 16,
    orpo_flash_ce: false, sft_scope: "response", warm_start_adapter: "/previous" };
  expect(await (await routes.handle(post("submit", body)))!.json())
    .toEqual({ ok: true, job_id: "job_test", adapter_path: "/default/adapter" });
  expect(calls[0]).toEqual(["finetune", { ...body, adapter_path: "/default/adapter" }, "/default/adapter"]);
  await routes.handle(post("submit", { ...body, adapter_path: "/chosen" }));
  expect(calls[1]?.[2]).toBe("/chosen");
  expect(pendingRoute("/api/finetune/submit")).toBe(false);
  expect(pendingRoute("/api/finetune/inspect-dataset")).toBe(false);
  for (const path of ["merge", "export", "push"]) {
    expect(pendingRoute(`/api/finetune/${path}`)).toBe(true);
    expect(await routes.handle(post(path, {}))).toBeNull();
  }
});

test("malformed HTTP inputs never submit a child or inspect arbitrary non-string paths", async () => {
  const routes = createFinetuneRoutes({ submit() { throw new Error("unexpected submit"); } });
  for (const body of [null, [], {}, { ...paths, model_dir: 3 }, { ...paths, adapter_path: [] }])
    expect((await routes.handle(post("submit", body)))?.status).toBe(400);
  expect((await routes.handle(post("inspect-dataset", { path: [] })))?.status).toBe(400);
});

test("default adapter outputs are distinct for two submissions in the same millisecond", async () => {
  const calls: unknown[][] = [];
  const routes = createFinetuneRoutes({ submit(...args) { calls.push(args); return { jobId: `job_${calls.length}` }; } });
  const clock = spyOn(Date, "now").mockReturnValue(123);
  try {
    const body = { model_dir: paths.model_dir, data_dir: paths.data_dir };
    const first = await (await routes.handle(post("submit", body)))!.json();
    const second = await (await routes.handle(post("submit", body)))!.json();
    expect(first.adapter_path).toMatch(/\/adapter-123-[0-9a-f-]{36}$/);
    expect(second.adapter_path).toMatch(/\/adapter-123-[0-9a-f-]{36}$/);
    expect(first.adapter_path).not.toBe(second.adapter_path);
    expect(calls.map(call => call[2])).toEqual([first.adapter_path, second.adapter_path]);
    await routes.handle(post("submit", { ...body, adapter_path: "/chosen/output" }));
    expect(calls[2]?.[2]).toBe("/chosen/output");
  } finally { clock.mockRestore(); }
});
