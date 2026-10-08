import { expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import type { CatalogEntry } from "@mlx-bun/app-core";
import type { TrainConfig } from "@mlx-bun/training";
import { inspectDataset, modelTrainingDefaults, parseFinetuneConfig, parseStream, parseTrainArgs, renderFrame, runFuse, runTrain, runTrainWatch, runWatch, sPerStep, trainPlan,
  type FuseDependencies, type TrainDependencies, type TrainRunner, type WatchTerminal } from "../src";
import { fakeTerminal, strip, verbArgs } from "./support";

const parse = verbArgs("train");
const adapters = () => "/store/adapters";
const preference = (i: number) => JSON.stringify({ prompt: `p${i}`, chosen: "c", rejected: "r" }) + "\n";

/** A synthetic snapshot (config.json only; no weights are read) and a JSONL dataset. */
/** Complete-enough configs for profile resolution: the real Gemma4 family type, MiniCPM5's llama-shaped
 * geometry (the family is recognized by it), plain Qwen3, and a Diffusion-Gemma stub. */
const configs = {
  gemma4: { model_type: "gemma4", hidden_size: 8, num_hidden_layers: 2, num_attention_heads: 2, num_key_value_heads: 1,
    intermediate_size: 16, vocab_size: 32, max_position_embeddings: 64 },
  minicpm5: { model_type: "llama", hidden_size: 1536, num_hidden_layers: 24, num_attention_heads: 16, num_key_value_heads: 2,
    head_dim: 128, intermediate_size: 4096, vocab_size: 130560, max_position_embeddings: 4096, tie_word_embeddings: false },
  qwen3: { model_type: "qwen3", hidden_size: 8, num_hidden_layers: 1, num_attention_heads: 2, num_key_value_heads: 2,
    intermediate_size: 16, vocab_size: 32, max_position_embeddings: 64, tie_word_embeddings: true },
  diffusionGemma: { model_type: "diffusion_gemma" },
};

function fixture({ rows = 3, valid = 1, config = configs.minicpm5 }: { rows?: number; valid?: number; config?: object } = {}) {
  const root = mkdtempSync(join(tmpdir(), "mlx-train-cli-"));
  const modelDir = join(root, "model"), dataDir = join(root, "data");
  mkdirSync(modelDir); mkdirSync(dataDir);
  writeFileSync(join(modelDir, "config.json"), JSON.stringify(config));
  writeFileSync(join(dataDir, "train.jsonl"), Array.from({ length: rows }, (_, i) => preference(i)).join(""));
  if (valid) writeFileSync(join(dataDir, "valid.jsonl"), Array.from({ length: valid }, (_, i) => preference(i)).join(""));
  return { root, modelDir, dataDir, dispose: () => rmSync(root, { recursive: true, force: true }) };
}

function harness(modelDir: string, run?: TrainRunner) {
  const logs: string[] = [], selections: (string | null)[] = [], runs: { cfg: Record<string, unknown>; signal?: AbortSignal }[] = [];
  const selectionSignals: (AbortSignal | undefined)[] = [];
  let resets = 0, clock = 1_000;
  const deps: TrainDependencies = {
    resolve: async (query, signal) => { selections.push(query); selectionSignals.push(signal); return { m: { path: modelDir, repoId: "example/model" }, picked: query === null }; },
    inspect: inspectDataset,
    runner: () => async (emit, cfg, signal) => { runs.push({ cfg, signal }); return run ? run(emit, cfg, signal) : { outputPath: String(cfg.adapter_path) }; },
    memory: async () => ({ peak: () => 3 * 2 ** 30, reset: () => { resets++; } }),
    exists: existsSync, trainingDefaults: modelTrainingDefaults,
    log: line => logs.push(line), terminal: fakeTerminal(logs), adaptersDir: () => "/store/adapters", now: () => (clock += 1500),
  };
  return { deps, logs, selections, selectionSignals, runs, resets: () => resets, text: () => strip(logs.join("\n")) };
}

// Captured from `02d723a:src/train/trainer.ts`: a test input, never a second
// production copy of the library defaults (the root export loads native MLX).
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

test("train validates usage, dataset, method, scope, and numbers before resolving a model", async () => {
  const f = fixture();
  try {
    const cases: [string[], string][] = [
      [[], "usage: mlx-bun train <model> --data <dir>   (see: mlx-bun help train)"],
      [["--data", "/nonexistent"], "no train.jsonl in /nonexistent"],
      [["--data", f.dataDir, "--method", "ppo"], '--method must be sft | dpo | orpo (got "ppo")'],
      [["--data", f.dataDir, "--sft-scope", "half"], '--sft-scope must be full | response (got "half")'],
      [["--data", f.dataDir, "--iters", "ten"], '--iters expects a number (got "ten")'],
      [["--data", f.dataDir, "--iters", "1", "--lr", "fast"], '--lr expects a number (got "fast")'],
      [["--data", f.dataDir, "--lambda", "x"], '--lambda expects a number (got "x")'],
      [["--data", f.dataDir, "--seg", "x"], '--seg expects a number (got "x")'],
      [["--data", f.dataDir, "--save-every", "NaN"], '--save-every expects a number (got "NaN")'],
    ];
    for (const [args, message] of cases) {
      const run = harness(f.modelDir);
      await expect(runTrain(parse(...args), run.deps)).rejects.toThrow(message);
      expect(run.selections).toEqual([]); expect(run.runs).toEqual([]); expect(run.logs).toEqual([]);
    }
    // Flags main never read for the method are not validated: lambda outside ORPO, seg under --no-segment.
    expect(parseTrainArgs(parse("--data", f.dataDir, "--method", "sft", "--lambda", "x")).numbers.has("lambda")).toBe(false);
    expect(parseTrainArgs(parse("--data", f.dataDir, "--no-segment", "--seg", "x")).numbers.has("seg")).toBe(false);
    // An empty value falls back to the default, as main's opt() did.
    expect(parseTrainArgs(parse("--data", f.dataDir, "--method", "")).method).toBe("orpo");
    expect(parseTrainArgs(parse("positional", "--data", f.dataDir, "--query", "ignored")).query).toBe("positional");
    for (const args of [["--data", f.dataDir, "--unknown"], ["a", "b", "--data", f.dataDir], ["--data"], ["--data", f.dataDir, "--serial"]])
      expect(() => parse(...args)).toThrow();
  } finally { f.dispose(); }
});

test("train builds main's exact submit record per method, with model-declared and explicit overrides", () => {
  const f = fixture();
  try {
    const m = { path: f.modelDir, repoId: "example/model" };
    const base = { model_dir: f.modelDir, data_dir: f.dataDir, rank_scaling: "by_bits", num_layers: -1, iters: 100,
      max_seq_length: 4096, batch_size: 1, grad_accumulation_steps: 1, seed: 0, steps_per_report: 1, steps_per_eval: 1_000_000,
      save_checkpoints: false, grad_clip_norm: 1, val_max_examples: 256, warm_start_adapter: "" };
    const orpo = trainPlan(parseTrainArgs(parse("--data", f.dataDir)), m, { maxSeqLength: 4096 }, adapters);
    expect(orpo.cfg).toEqual({ ...base, adapter_path: "/store/adapters/orpo-model", method: "orpo",
      rank: 16, scale: 2, learning_rate: 1e-5, segment_size: 2, orpo_lambda: 0.1, orpo_lr_schedule: "cosine", orpo_warmup_iters: 10,
      orpo_chunk_size: 512, orpo_flash_ce: true, orpo_fused_ce: false, orpo_prefix_shared: true });
    const dpo = trainPlan(parseTrainArgs(parse("--data", f.dataDir, "--method", "dpo")), m, { maxSeqLength: 4096 }, adapters);
    expect(dpo.cfg).toEqual({ ...base, adapter_path: "/store/adapters/dpo-model", method: "dpo",
      rank: 8, scale: 1, learning_rate: 5e-5, segment_size: 0 });
    expect(trainPlan(parseTrainArgs(parse("--data", f.dataDir, "--method", "sft")), m, { maxSeqLength: 8192 }, adapters).cfg)
      .toEqual({ ...base, adapter_path: "/store/adapters/sft-model", method: "sft",
        rank: 8, scale: 1, learning_rate: 2e-4, max_seq_length: 8192, segment_size: 0 });
    const overridden = trainPlan(parseTrainArgs(parse("--data", f.dataDir, "--adapter", "/out", "--iters", "45", "--lr", "3e-5",
      "--rank", "4", "--scale", "0.5", "--seq", "1024", "--batch", "2", "--grad-accum", "3", "--grad-clip", "0", "--seed", "7",
      "--val-size", "8", "--lambda", "0.3", "--sft-scope", "response", "--seg", "3", "--save-every", "5", "--resume", "/prev",
      "--no-flash", "--no-prefix")), m, { maxSeqLength: 8192 }, adapters);
    expect(overridden.cfg).toEqual({ model_dir: f.modelDir, data_dir: f.dataDir, adapter_path: "/out", method: "orpo", rank: 4,
      scale: 0.5, rank_scaling: "by_bits", num_layers: -1, iters: 45, learning_rate: 3e-5, max_seq_length: 1024, batch_size: 2,
      grad_accumulation_steps: 3, seed: 7, steps_per_report: 1, steps_per_eval: 5, save_checkpoints: true, segment_size: 3,
      grad_clip_norm: 0, val_max_examples: 8, warm_start_adapter: "/prev", sft_scope: "response", orpo_lambda: 0.3,
      orpo_lr_schedule: "cosine", orpo_warmup_iters: 4, orpo_chunk_size: 512, orpo_flash_ce: false, orpo_fused_ce: true,
      orpo_prefix_shared: false });
    expect(trainPlan(parseTrainArgs(parse("--data", f.dataDir, "--no-segment", "--seg", "9")), m, { maxSeqLength: 4096 }, adapters).cfg.segment_size).toBe(0);
    expect(trainPlan(parseTrainArgs(parse("--data", f.dataDir, "--iters", "5")), m, { maxSeqLength: 4096 }, adapters).cfg.orpo_warmup_iters).toBe(0);
    expect(trainPlan(parseTrainArgs(parse("--data", f.dataDir, "--method", "sft", "--sft-scope", "full")), m, { maxSeqLength: 4096 }, adapters).cfg.sft_scope).toBe("full");
    // Every key the verb emits is one the app's finetune config consumes, with its value.
    const consumed = parseFinetuneConfig(overridden.cfg, mainLibraryDefaults);
    expect(consumed.dataDir).toBe(f.dataDir);
    expect(consumed.cfg).toMatchObject({ method: "orpo", rank: 4, scale: 0.5, rankScaling: "by_bits", numLayers: -1, iters: 45,
      learningRate: 3e-5, maxSeqLen: 1024, batchSize: 2, gradAccumSteps: 3, seed: 7, stepsPerReport: 1, stepsPerEval: 5,
      saveCheckpoints: true, segmentSize: 3, gradClipNorm: 0, valMaxExamples: 8, warmStartAdapter: "/prev", sftScope: "response",
      orpoLambda: 0.3, orpoLrSchedule: "cosine", orpoWarmupIters: 4, orpoChunkSize: 512, orpoFlashCe: false, orpoFusedCe: true,
      orpoPrefixShared: false, adapterPath: "/out", baseModel: f.modelDir });
    expect(parseFinetuneConfig(dpo.cfg, mainLibraryDefaults).cfg).toMatchObject({ method: "dpo", learningRate: 5e-5, rank: 8,
      scale: 1, maxSeqLen: 4096, segmentSize: 0, stepsPerReport: 1, stepsPerEval: 1_000_000, saveCheckpoints: false, sftScope: "full" });
    expect(parseFinetuneConfig(orpo.cfg, mainLibraryDefaults).cfg).toMatchObject({ method: "orpo", rank: 16, scale: 2,
      learningRate: 1e-5, segmentSize: 2, orpoWarmupIters: 10, orpoChunkSize: 512, orpoFlashCe: true, orpoFusedCe: false, orpoPrefixShared: true });
  } finally { f.dispose(); }
});

test("the default sequence length comes from the model's resolved profile, not a name match", async () => {
  const seqOf = async (config: object, ...extra: string[]) => {
    const f = fixture({ config });
    try {
      const run = harness(f.modelDir);
      await runTrain(parse("--data", f.dataDir, "--dry-run", "--method", "sft", ...extra), run.deps);
      return { seq: run.text().match(/seq (\d+)/)?.[1], text: run.text() };
    } finally { f.dispose(); }
  };
  // Gemma-family graphs declare 8192; MiniCPM5 and Qwen3 declare nothing and get the generic 4096.
  expect((await seqOf(configs.gemma4)).seq).toBe("8192");
  expect((await seqOf(configs.diffusionGemma)).seq).toBe("8192");
  expect((await seqOf(configs.minicpm5)).seq).toBe("4096");
  expect((await seqOf(configs.qwen3)).seq).toBe("4096");
  // An explicit --seq always wins, and no family label is printed.
  const explicit = await seqOf(configs.gemma4, "--seq", "1024");
  expect(explicit.seq).toBe("1024"); expect(explicit.text).not.toContain("defaults");
  // The words in the config text are irrelevant: a qwen3 config that merely mentions gemma stays generic.
  expect((await seqOf({ ...configs.qwen3, _name_or_path: "not-gemma-at-all" })).seq).toBe("4096");
  expect(Object.keys(trainPlan(parseTrainArgs(parse("--data", "/d"), () => true), { path: "/m", repoId: "m" }, { maxSeqLength: 4096 }, adapters))).not.toContain("isGemma");
});

test("dataset preflight failure stops after resolution and before training", async () => {
  const f = fixture();
  try {
    writeFileSync(join(f.dataDir, "train.jsonl"), "not json\n");
    const run = harness(f.modelDir);
    await expect(runTrain(parse(f.modelDir, "--data", f.dataDir), run.deps)).rejects.toThrow("dataset: ");
    expect(run.selections).toEqual([f.modelDir]); expect(run.runs).toEqual([]); expect(run.logs).toEqual([]);
  } finally { f.dispose(); }
});

test("dry run prints main's plan box and runs no training", async () => {
  const f = fixture({ valid: 2 }), g = fixture({ config: configs.gemma4, valid: 0 });
  try {
    const run = harness(f.modelDir);
    await runTrain(parse("--data", f.dataDir, "--dry-run", "--save-every", "5", "--resume", "/prev", "--grad-accum", "2", "--query", "q"), run.deps);
    expect(run.selections).toEqual(["q"]);
    const text = run.text();
    for (const line of ["● train orpo · example/model", "data       3 train · 2 valid · format preference",
      "loop       iters 100 · lr 0.00001 · rank 16 · scale 2 · seq 4096 · batch 1", "head       flash-CCE Metal ([M,vocab]-free)",
      "stack      prefix-share on · segmented 2/seg · λ 0.1", "stability  grad-clip 1 · val-size 256 · grad-accum 2 (eff batch 2)",
      "warm-start from /prev (weights only)", "checkpoint every 5 steps",
      "adapter    /store/adapters/orpo-model",
      "watch live (other tab): mlx-bun train-watch /store/adapters/orpo-model", "dry run — not training."])
      expect(text).toContain(line);
    expect(run.runs).toEqual([]); expect(run.resets()).toBe(0);
    const auto = harness(g.modelDir);
    await runTrain(parse("--data", g.dataDir, "--dry-run", "--method", "sft", "--no-segment", "--no-flash", "--grad-clip", "0"), auto.deps);
    expect(auto.selections).toEqual([null]);
    for (const line of ["● train sft · example/model (auto-picked)", "data       3 train · format preference",
      "lr 0.0002 · rank 8 · scale 1 · seq 8192", "stack      segmented off", "adapter    /store/adapters/sft-model"])
      expect(auto.text()).toContain(line);
    expect(auto.text()).not.toContain("head "); expect(auto.text()).not.toContain("checkpoint ");
    const orpo = harness(f.modelDir);
    await runTrain(parse("--data", f.dataDir, "--dry-run", "--no-flash", "--no-prefix", "--no-segment", "--grad-clip", "0"), orpo.deps);
    expect(orpo.text()).toContain("head       MLX fused linear-CE");
    expect(orpo.text()).toContain("stack      prefix-share off · segmented off · λ 0.1");
    expect(orpo.text()).toContain("stability  grad-clip off · val-size 256"); expect(orpo.text()).not.toContain("grad-accum");
  } finally { f.dispose(); g.dispose(); }
});

test("training progress renders main's step lines and completion box, with peak memory only when available", async () => {
  const f = fixture();
  try {
    const training: TrainRunner = async emit => {
      emit({ type: "stage", stage: "load", progress: 0.01, message: "loading model" });
      emit({ type: "stage", stage: "setup", progress: 0.02 });
      for (let step = 1; step <= 12; step++) emit({ type: "metric", kind: "train", step, loss: 1 - step * 0.05 });
      emit({ type: "metric", kind: "val", step: 12, loss: 0.3 });
      return { outputPath: "/out" };
    };
    const run = harness(f.modelDir, training);
    await runTrain(parse(f.modelDir, "--data", f.dataDir, "--iters", "12", "--adapter", "/out"), run.deps);
    expect(run.runs[0]!.cfg).toMatchObject({ iters: 12, adapter_path: "/out", model_dir: f.modelDir });
    expect(run.text()).toContain("  · loading model");
    expect(run.logs.map(strip).filter(line => line.startsWith("  step "))).toEqual([
      "  step 1/12: loss 0.9500 (1.5s/step · peak 3.00 GB)", "  step 2/12: loss 0.9000 (1.5s/step · peak 3.00 GB)",
      "  step 3/12: loss 0.8500 (1.5s/step · peak 3.00 GB)", "  step 10/12: loss 0.5000 (1.5s/step · peak 3.00 GB)"]);
    for (const line of ["● training complete · 12 steps", "loss       0.9500 → 0.4000", "speed      1.5s/step median · peak 3.00 GB",
      "adapter    /out", "serve it   mlx-bun serve example/model --adapter /out"])
      expect(run.text()).toContain(line);
    expect(run.text()).not.toContain("NON-FINITE"); expect(run.resets()).toBe(1);

    const blocked = harness(f.modelDir, async emit => { emit({ type: "metric", kind: "train", step: 1, loss: NaN }); });
    await runTrain(parse(f.modelDir, "--data", f.dataDir, "--adapter", "/out"), { ...blocked.deps, memory: async () => null });
    expect(blocked.text()).toContain("step 1/100: loss NaN (1.5s/step)\n");
    expect(blocked.text()).toContain("loss       NaN → NaN  (NON-FINITE!)");
    expect(blocked.text()).toContain("speed      1.5s/step median"); expect(blocked.text()).not.toContain("peak");
  } finally { f.dispose(); }
});

test("training failure surfaces main's message and no completion box", async () => {
  const f = fixture();
  try {
    const run = harness(f.modelDir, async () => { throw new Error("boom"); });
    await expect(runTrain(parse(f.modelDir, "--data", f.dataDir), run.deps)).rejects.toThrow("training failed: boom");
    expect(run.text()).not.toContain("training complete");
  } finally { f.dispose(); }
});

test("cancellation mid-run reaches the runner, unwinds its cleanup, and exits with the cancel reason", async () => {
  const f = fixture();
  try {
    const controller = new AbortController(), cleanup: string[] = [];
    let observed: AbortSignal | undefined, steps = 0;
    const run = harness(f.modelDir, async (emit, _cfg, signal) => {
      observed = signal;
      try {
        for (let step = 1; step <= 100; step++) {
          signal?.throwIfAborted(); // the finetune runner observes the abort at each progress event
          emit({ type: "metric", kind: "train", step, loss: 0.5 }); steps++;
          if (step === 2) controller.abort(new Error("training cancelled"));
          await new Promise(resolve => setImmediate(resolve));
        }
      } finally { cleanup.push("disposed"); }
      return { outputPath: "/out" };
    });
    await expect(runTrain(parse(f.modelDir, "--data", f.dataDir, "--adapter", "/out"), run.deps, controller.signal)).rejects.toThrow("training cancelled");
    expect(observed).toBe(controller.signal); expect(steps).toBe(2); expect(cleanup).toEqual(["disposed"]);
    expect(run.text()).toContain("step 2/100"); expect(run.text()).not.toContain("training complete");
    // An abort before training starts never resolves a model or invokes the runner.
    const early = new AbortController(); early.abort(new Error("training cancelled"));
    const untouched = harness(f.modelDir);
    await expect(runTrain(parse(f.modelDir, "--data", f.dataDir), untouched.deps, early.signal)).rejects.toThrow("training cancelled");
    expect(untouched.selections).toEqual([]); expect(untouched.runs).toEqual([]);
  } finally { f.dispose(); }
});

test("train's layer count, report/eval cadence, dropout, weight decay and gradient checkpointing reach the submit record", () => {
  const f = fixture();
  try {
    const m = { path: f.modelDir, repoId: "example/model" };
    const cfg = trainPlan(parseTrainArgs(parse("--data", f.dataDir, "--method", "sft", "--num-layers", "8", "--steps-per-report", "10",
      "--steps-per-eval", "200", "--dropout", "0.05", "--weight-decay", "0", "--grad-checkpoint")), m, { maxSeqLength: 4096 }, adapters).cfg;
    expect(cfg).toMatchObject({ num_layers: 8, steps_per_report: 10, steps_per_eval: 200, lora_dropout: 0.05, weight_decay: 0, grad_checkpoint: true });
    // Not given: the submit record carries none of the optional keys and keeps the existing cadence.
    const plain = trainPlan(parseTrainArgs(parse("--data", f.dataDir, "--method", "sft")), m, { maxSeqLength: 4096 }, adapters).cfg;
    expect(plain).toMatchObject({ num_layers: -1, steps_per_report: 1, steps_per_eval: 1_000_000 });
    for (const key of ["lora_dropout", "weight_decay", "grad_checkpoint"]) expect(plain).not.toHaveProperty(key);
    // A checkpoint cadence still drives evaluation unless --steps-per-eval names its own.
    expect(trainPlan(parseTrainArgs(parse("--data", f.dataDir, "--save-every", "25")), m, { maxSeqLength: 4096 }, adapters).cfg.steps_per_eval).toBe(25);
    expect(() => parseTrainArgs(parse("--data", f.dataDir, "--num-layers", "many"))).toThrow('--num-layers expects a number (got "many")');
  } finally { f.dispose(); }
});

function fuseHarness(fuse?: FuseDependencies["fuse"], token: string | null = "hf_token") {
  const logs: string[] = [], steps: string[] = [], calls: unknown[][] = [], finds: string[] = [], published: unknown[] = [], options: unknown[] = [];
  const cached: CatalogEntry = { id: "org/cached", kind: "model", directory: "/cache/model", bytes: 0, operations: ["generate"] };
  const deps: FuseDependencies = {
    modelsDir: () => "/store/models",
    catalog: {
      find: async query => { finds.push(query); if (query !== "cached") throw new Error(`no model matching "${query}" — run \`mlx-bun scan\``); return cached; },
      canPublish: () => token !== null,
      publish: async (directory, request) => { published.push({ ...request, sourcePath: directory }); return { url: "https://huggingface.co/org/fused" }; },
    },
    fuse: fuse ?? (async (modelDir, adapterDir, outDir, onProgress, fuseOptions) => {
      calls.push([modelDir, adapterDir, outDir]); options.push(fuseOptions);
      onProgress?.({ stage: "fusing", message: "Module 1/2: layers.0", progress: 0.5 });
      return { outDir, fusedModules: 2, skippedAdapterTensors: 0, totalTensors: 5 };
    }),
    exists: existsSync, log: line => logs.push(line), terminal: fakeTerminal(logs, steps),
  };
  return { deps, logs, steps: () => steps.map(strip), calls, finds, published, options, text: () => strip(logs.join("\n")) };
}
const fuseArgs = verbArgs("fuse");

test("fuse refuses GGUF export and reports usage errors before touching anything", async () => {
  const f = fixture();
  try {
    const cases: [string[], string][] = [
      [[f.modelDir, "--adapter", f.dataDir, "--export-gguf"], "--export-gguf: not supported (GGUF export is not implemented; fuse writes safetensors; see: mlx-bun help fuse)"],
      [[f.modelDir, "--adapter", f.dataDir, "--gguf-path", "x.gguf"], "--gguf-path: not supported (GGUF export"],
      [["--export-gguf", "--gguf-path", "x.gguf"], "--export-gguf, --gguf-path: not supported (GGUF export"],
      [[], "usage: mlx-bun fuse <model-query-or-path> --adapter <dir> [--save-path <dir>]"],
      [[f.modelDir, "--adapter", "/nonexistent"], "adapter dir not found: /nonexistent"],
      [[f.modelDir], "adapter dir not found: adapters"],
      [["missing", "--adapter", f.dataDir], 'no model matching "missing"'],
    ];
    for (const [args, message] of cases) {
      const run = fuseHarness();
      await expect(runFuse(fuseArgs(...args), run.deps)).rejects.toThrow(message);
      expect(run.calls).toEqual([]); expect(run.steps()).toEqual([]); expect(run.logs).toEqual([]);
      if (message.startsWith("no model")) expect(run.finds).toEqual(["missing"]);
      else expect(run.finds).toEqual([]);
    }
    for (const args of [["m", "--unknown"], ["a", "b"], ["--adapter"]]) expect(() => fuseArgs(...args)).toThrow();
  } finally { f.dispose(); }
});

test("fuse merges by snapshot path or registry query with main's flag spellings and completion box", async () => {
  const f = fixture();
  try {
    const byPath = fuseHarness();
    await runFuse(fuseArgs(f.modelDir, "--adapter", f.dataDir), byPath.deps);
    expect(byPath.finds).toEqual([]); expect(byPath.calls).toEqual([[f.modelDir, f.dataDir, "/store/models/model-fused"]]);
    expect(byPath.steps()).toEqual([`start:fusing ${f.dataDir} into ${f.modelDir}`, "update:Module 1/2: layers.0", "done:fused 2 module(s) · 5 tensors written"]);
    for (const line of ["● fuse complete", `base      ${f.modelDir}`, `adapter   ${f.dataDir}`, "model     /store/models/model-fused", "serve it   mlx-bun serve /store/models/model-fused"])
      expect(byPath.text()).toContain(line);
    expect(byPath.text()).not.toContain("skipped");

    const byQuery = fuseHarness(async (modelDir, adapterDir, outDir) => ({ outDir: resolve(outDir), fusedModules: 1, skippedAdapterTensors: 3, totalTensors: 9 }));
    await runFuse(fuseArgs("--model", "cached", "--adapter-path", f.dataDir, "--save-path", "/out"), byQuery.deps);
    expect(byQuery.finds).toEqual(["cached"]);
    expect(byQuery.steps()).toEqual([`start:fusing ${f.dataDir} into /cache/model`, "done:fused 1 module(s) · 9 tensors written"]);
    for (const line of ["base      /cache/model", "model     /out", "skipped   3 adapter tensor(s) with no matching base weight", "serve it   mlx-bun serve /out"])
      expect(byQuery.text()).toContain(line);
    expect(fuseArgs("positional", "--model", "flag").positionals[0]).toBe("positional");
  } finally { f.dispose(); }
});

test("fuse --dequantize reaches the merge, and --upload-repo checks the token first and pushes only a finished, uninterrupted merge", async () => {
  const f = fixture();
  try {
    const dense = fuseHarness();
    await runFuse(fuseArgs(f.modelDir, "--adapter", f.dataDir, "--dequantize"), dense.deps);
    expect(dense.options).toEqual([{ dequantize: true }]);
    expect(dense.text()).toContain("weights   dequantized to dense");
    const plain = fuseHarness();
    await runFuse(fuseArgs(f.modelDir, "--adapter", f.dataDir), plain.deps);
    expect(plain.options).toEqual([{ dequantize: false }]); expect(plain.text()).not.toContain("dequantized");
    expect(plain.published).toEqual([]);

    // No write token: refused before the registry, the merge, or any output.
    const denied = fuseHarness(undefined, null);
    await expect(runFuse(fuseArgs(f.modelDir, "--adapter", f.dataDir, "--upload-repo", "org/fused"), denied.deps))
      .rejects.toThrow("--upload-repo needs a Hugging Face WRITE token and none was found");
    expect(denied.calls).toEqual([]); expect(denied.steps()).toEqual([]); expect(denied.published).toEqual([]);

    const pushed = fuseHarness();
    await runFuse(fuseArgs(f.modelDir, "--adapter", f.dataDir, "--save-path", "/out", "--upload-repo", "org/fused"), pushed.deps);
    expect(pushed.published).toEqual([{ repoId: "org/fused", sourcePath: "/out" }]);
    expect(pushed.steps().slice(-2)).toEqual(["start:uploading /out → org/fused", "done:uploaded https://huggingface.co/org/fused"]);

    // The fused model stays intact when the push fails, and the error names the retry command.
    const failed = fuseHarness();
    failed.deps.catalog = { ...failed.deps.catalog, publish: async () => { throw new Error("network down"); } };
    await expect(runFuse(fuseArgs(f.modelDir, "--adapter", f.dataDir, "--save-path", "/out", "--upload-repo", "org/fused"), failed.deps))
      .rejects.toThrow("the fused model is intact at /out — retry with: mlx-bun upload --path /out --upload-repo org/fused");
    expect(failed.steps()).toContain("fail:upload failed: network down");

    // A cancel that arrived during the merge completes the output but starts no push.
    const during = new AbortController();
    const interrupted = fuseHarness(async (_m, _a, outDir) => { during.abort(new Error("fuse cancelled")); return { outDir, fusedModules: 1, skippedAdapterTensors: 0, totalTensors: 1 }; });
    await runFuse(fuseArgs(f.modelDir, "--adapter", f.dataDir, "--save-path", "/out", "--upload-repo", "org/fused"), interrupted.deps, during.signal);
    expect(interrupted.published).toEqual([]); expect(interrupted.text()).toContain("● fuse complete");
  } finally { f.dispose(); }
});

test("fuse failure finishes the step line and exits non-zero; cancellation is honored only before the merge", async () => {
  const f = fixture();
  try {
    const failed = fuseHarness(async () => { throw new Error("adapter_config.json missing"); });
    await expect(runFuse(fuseArgs(f.modelDir, "--adapter", f.dataDir), failed.deps)).rejects.toThrow("adapter_config.json missing");
    expect(failed.steps().at(-1)).toBe("fail:fuse failed: adapter_config.json missing"); expect(failed.logs).toEqual([]);

    const early = new AbortController(); early.abort(new Error("fuse cancelled"));
    const skipped = fuseHarness();
    await expect(runFuse(fuseArgs(f.modelDir, "--adapter", f.dataDir), skipped.deps, early.signal)).rejects.toThrow("fuse cancelled");
    expect(skipped.calls).toEqual([]); expect(skipped.steps()).toEqual([]);

    // The library merge has no cancellation seam: a signal during it lets the
    // merge finish so the output directory is never half-written.
    const during = new AbortController();
    const finished = fuseHarness(async (_m, _a, outDir) => { during.abort(new Error("fuse cancelled")); return { outDir, fusedModules: 1, skippedAdapterTensors: 0, totalTensors: 1 }; });
    await runFuse(fuseArgs(f.modelDir, "--adapter", f.dataDir, "--save-path", "/out"), finished.deps, during.signal);
    expect(finished.steps().some(s => s.includes("cancellation requested; the merge cannot be interrupted, finishing so /out is not left half-written"))).toBe(true);
    expect(finished.text()).toContain("● fuse complete");
    expect(finished.text()).toContain("cancellation arrived during the merge; it cannot be interrupted, so the output was completed.");
  } finally { f.dispose(); }
});

const T0 = 1_700_000_000_000;
/** A synthetic metrics.jsonl in the trainer's format, with garbage and a partial trailing line. */
function stream(steps: number, iters: number): string {
  const lines = [JSON.stringify({ type: "meta", t: T0, method: "orpo", iters, learning_rate: 1e-5, max_seq_length: 4096, orpo_lambda: 0.1,
    model: "/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/0123456789abcdef0123", adapter_path: "/adapter" })];
  for (let step = 1; step <= steps; step++)
    lines.push(JSON.stringify({ type: "metric", kind: "train", step, t: T0 + step * 2000, loss: 1 / step, margin: step * 0.1 - 0.3,
      accuracy: step % 2, active_gb: 2.5, peak_gb: 3 + step * 0.01 }));
  if (steps >= 5) lines.push(JSON.stringify({ type: "metric", kind: "val", step: 5, t: T0 + 10_001, loss: 0.4, accuracy: 0.75, n_correct: 3, n_total: 4 }));
  lines.push("garbage line", JSON.stringify({ type: "metric", kind: "train", step: "x", loss: 1 }), '{"type":"metric","kind":"train","step":11');
  return lines.join("\n") + "\n";
}

test("parseStream folds meta, train, and val records, skips garbage, and derives step timing", () => {
  const st = parseStream(stream(10, 10));
  expect(st.meta).toEqual({ method: "orpo", model: "/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/0123456789abcdef0123",
    iters: 10, lambda: 0.1, lr: 1e-5, seq: 4096, startedAt: T0, adapterPath: "/adapter" });
  expect(st.loss).toHaveLength(10); expect(st.loss[0]).toEqual({ step: 1, t: T0 + 2000, y: 1 });
  expect(st.margin[9]!.y).toBeCloseTo(0.7); expect(st.trainAcc.map(p => p.y)).toEqual([1, 0, 1, 0, 1, 0, 1, 0, 1, 0]);
  expect(st.mem.every(p => p.y === 2.5)).toBe(true); expect(st.peak).toHaveLength(10); expect(st.peakGb).toBeCloseTo(3.1);
  expect(st.valAcc).toEqual([{ step: 5, t: T0 + 10_001, y: 0.75, nc: 3, nt: 4 }]);
  expect(st.valLoss).toEqual([{ step: 5, t: T0 + 10_001, y: 0.4 }]);
  expect(st).toMatchObject({ lastStep: 10, lastT: T0 + 20_000, done: true });
  expect(sPerStep(st)).toBe(2);
  expect(parseStream(stream(3, 10))).toMatchObject({ lastStep: 3, done: false });
  expect(parseStream("")).toMatchObject({ meta: { method: "?", model: "", iters: 0 }, loss: [], lastStep: 0, done: false });
  expect(sPerStep(parseStream(""))).toBe(0);
});

test("renderFrame is a pure, exactly sized frame with header, progress bar, legend, and panels", () => {
  const visible = (line: string) => [...strip(line)].length;
  const live = parseStream(stream(3, 10)), frame = renderFrame(live, 100, 30);
  expect(frame).toHaveLength(30); for (const line of frame) expect(visible(line)).toBe(100);
  const text = frame.map(strip);
  expect(text[0]).toContain("● orpo · MiniCPM5-1B"); expect(text[0]).toContain("step 3/10 · 30.0% · ETA 14s · 2.00s/step · 6s");
  expect(text[1]).toContain("█"); expect(text[1]).toContain("░"); expect(text[2]).toContain("loss = orpo/step · margin = confidence");
  const body = text.join("\n");
  // The loss headline is main's smoothed trend (rolling median, then mean), not the raw last loss.
  for (const panel of ["loss · orpo per step 0.833  ↓min 0.833 @ 3", "margin · confidence in the choice -0.133  leans rejected",
    "accuracy · correct choices on val awaiting first eval (50% = chance)", "memory peak 3.03GB · active 2.50GB"])
    expect(body).toContain(panel);
  expect(body).toContain("┄"); expect(/[⠀-⣿]/.test(body)).toBe(true);
  expect(renderFrame(live, 100, 30)).toEqual(frame);
  const done = renderFrame(parseStream(stream(10, 10)), 100, 30).map(strip);
  expect(done[0]).toContain("✓ orpo · MiniCPM5-1B"); expect(done[0]).toContain("step 10/10 · complete · 20s");
  expect(done.join("\n")).toContain("3/4 correct = 75.0%  · best 75.0% @ 5"); expect(done.join("\n")).toContain("●");
  const short = renderFrame(live, 60, 8);
  expect(short).toHaveLength(8); for (const line of short) expect(visible(line)).toBe(60);
  expect(short.map(strip).join("\n")).not.toContain("loss · orpo per step");
  expect(renderFrame(parseStream(""), 80, 24).map(strip)[0]).toContain("? · ");
});

const ALT_ON = "\x1b[?1049h\x1b[?25l", ALT_OFF = "\x1b[?25h\x1b[?1049l\x1b[0m";
test("runWatch draws on the alternate screen, stops on q or the external signal, and restores the terminal", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-watch-"));
  try {
    writeFileSync(join(dir, "metrics.jsonl"), stream(3, 10));
    const writes: string[] = []; let onKey: ((key: string) => void) | undefined, detached = 0, resizes = 0, sleeps = 0;
    const terminal: WatchTerminal = { write: text => { writes.push(text); }, size: () => ({ columns: 80, rows: 24 }),
      keys: listener => { onKey = listener; return () => { detached++; }; }, onResize: () => () => { resizes++; } };
    await runWatch(dir, { terminal, sleep: async (ms, signal) => { sleeps++; expect(ms).toBe(250); if (sleeps === 2) onKey!("q"); expect(signal.aborted).toBe(sleeps === 2); } });
    expect(writes[0]).toBe(ALT_ON + "\x1b[2J"); expect(writes.at(-1)).toBe(ALT_OFF);
    expect(writes.filter(w => w.startsWith("\x1b[H"))).toHaveLength(1); // an unchanged frame is not redrawn
    expect(sleeps).toBe(2); expect(detached).toBe(1); expect(resizes).toBe(1);

    const controller = new AbortController(), external: string[] = [];
    const piped: WatchTerminal = { write: text => { external.push(text); }, size: () => ({ columns: 80, rows: 24 }) };
    await runWatch(dir, { terminal: piped, signal: controller.signal, sleep: async (ms) => { expect(ms).toBe(250); controller.abort(new Error("watch cancelled")); } });
    expect(external).toHaveLength(3); expect(external.at(-1)).toBe(ALT_OFF);

    writeFileSync(join(dir, "metrics.jsonl"), stream(10, 10));
    const finished: string[] = [], done = new AbortController();
    await runWatch(dir, { terminal: { write: text => { finished.push(text); }, size: () => ({ columns: 80, rows: 24 }) }, signal: done.signal,
      sleep: async ms => { expect(ms).toBe(1000); done.abort(); } });
    expect(strip(finished[1]!)).toContain("complete");
    // A failure while attaching (resize registration) still detaches keys and leaves the alternate screen.
    const partial: string[] = []; let detachedKeys = 0;
    const failing: WatchTerminal = { write: text => { partial.push(text); }, size: () => ({ columns: 80, rows: 24 }),
      keys: () => () => { detachedKeys++; }, onResize: () => { throw new Error("resize unsupported"); } };
    await expect(runWatch(dir, { terminal: failing })).rejects.toThrow("resize unsupported");
    expect(detachedKeys).toBe(1); expect(partial.at(-1)).toBe(ALT_OFF);
    await expect(runWatch("/nonexistent", { terminal: piped })).rejects.toThrow(
      "no metrics.jsonl in /nonexistent — is this an mlx-bun training run dir?\n(the trainer writes /nonexistent/metrics.jsonl as it runs; point train-watch at the --adapter dir)");
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test("train-watch takes the positional, then --adapter, then the latest run in the adapter store", async () => {
  const watched: [string, AbortSignal | undefined][] = [];
  const deps = { watch: async (dir: string, options?: { signal?: AbortSignal }) => { watched.push([dir, options?.signal]); }, adaptersDir: () => "/nonexistent-store/adapters" };
  const signal = new AbortController().signal;
  await runTrainWatch(verbArgs("train-watch")("/run", "--adapter", "/flag"), deps, signal);
  await runTrainWatch(verbArgs("train-watch")("--adapter", "/flag"), deps);
  await expect(runTrainWatch(verbArgs("train-watch")(), deps)).rejects.toThrow("no training run found in /nonexistent-store/adapters");
  expect(watched).toEqual([["/run", signal], ["/flag", undefined]]);
});

test("the process terminal restores the raw and paused state it found when keys detach", async () => {
  const { processTerminal } = await import("../src");
  const calls: string[] = [];
  function fakeStdin(raw: boolean, paused: boolean) {
    const state = { raw, paused };
    return { isTTY: true, get isRaw() { return state.raw; }, isPaused: () => state.paused,
      setRawMode(on: boolean) { state.raw = on; calls.push(`raw:${on}`); },
      resume() { state.paused = false; calls.push("resume"); }, pause() { state.paused = true; calls.push("pause"); },
      on() { calls.push("on"); }, off() { calls.push("off"); } } as unknown as NodeJS.ReadStream;
  }
  const stdout = { write() { return true; }, on() {}, off() {}, columns: 80, rows: 24 } as unknown as NodeJS.WriteStream;
  const detach = processTerminal({ stdin: fakeStdin(false, true), stdout }).keys!(() => {});
  expect(calls).toEqual(["raw:true", "resume", "on"]);
  detach();
  expect(calls.slice(3)).toEqual(["off", "raw:false", "pause"]);
  // Already raw and flowing: detaching leaves it raw and flowing.
  calls.length = 0;
  processTerminal({ stdin: fakeStdin(true, false), stdout }).keys!(() => {})();
  expect(calls).toEqual(["raw:true", "resume", "on", "off", "raw:true"]);
});

test("train hands its cancellation signal to model selection so a starter download can be cancelled", async () => {
  const f = fixture();
  try {
    const controller = new AbortController(), run = harness(f.modelDir);
    await runTrain(parse("--data", f.dataDir, "--dry-run"), run.deps, controller.signal);
    expect(run.selectionSignals).toEqual([controller.signal]);
  } finally { f.dispose(); }
});
