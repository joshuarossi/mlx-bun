import { existsSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";
import type { Registry } from "@mlx-bun/hub/registry";
import type { TrainingDefaults } from "@mlx-bun/inference/models/profile";
import type { fuseAdapter } from "@mlx-bun/training";
import { createFinetuneRunner } from "../finetune/job";
import { inspectDataset } from "../finetune/inspect";
import { runWatch } from "../finetune/watch";
import type { JobEvent, JobRunner } from "../jobs/protocol";
import type { CommandArgs } from "./args";
import { publishModel, requireWriteToken, uploadDefaults, type UploadDependencies } from "./publish-model";
import { resolveModelAuto } from "./model-selection";
import { boxLines, step, style } from "./terminal";
import { mlxBunHome, modelShortName, openRegistry, storagePath } from "../storage/paths";

// Thin verbs over the app's fine-tuning producer and the public training
// library: argument policy, main's plan/summary presentation, and process
// cancellation live here; training numerics and adapter fusion do not.

interface SelectedModel { path: string; repoId: string }
type ModelRegistry = Pick<Registry, "resolve" | "list" | "scan" | "close">;
/** Allocator counters read through the native binding while training runs. */
export interface PeakMemory { peak(): number; reset(): void }
export type TrainMethod = "sft" | "dpo" | "orpo";

const gb = (bytes: number) => `${(bytes / 2 ** 30).toFixed(2)} GB`;
/** Main's `opt()`: an absent or empty value falls back to the default. */
function opt(args: CommandArgs, name: string): string | undefined {
  const value = args.values[name];
  return typeof value === "string" && value ? value : undefined;
}
const flag = (args: CommandArgs, name: string): boolean => args.values[name] === true;

export interface TrainArgs {
  query: string | null; dataDir: string; method: TrainMethod; sftScope: "full" | "response" | null;
  /** Validated numeric flags that were supplied; defaults are method/model dependent. */
  numbers: ReadonlyMap<string, number>;
  adapter?: string; resume: string; noSegment: boolean; flashOn: boolean; prefixOn: boolean; dryRun: boolean; gradCheckpoint: boolean;
}

/** Main's checks in main's order, all before any model resolution: usage,
 * train.jsonl, method, sft-scope, then each numeric flag main would read
 * (seg unless --no-segment; lambda only for ORPO). */
export function parseTrainArgs(args: CommandArgs, exists: (path: string) => boolean = existsSync): TrainArgs {
  const query = args.positionals[0] ?? opt(args, "query") ?? null;
  const dataDir = opt(args, "data");
  if (!dataDir) throw new Error("usage: mlx-bun train <model> --data <dir>   (see: mlx-bun help train)");
  if (!exists(`${dataDir}/train.jsonl`)) throw new Error(`no train.jsonl in ${dataDir}`);
  const method = opt(args, "method") ?? "orpo";
  if (method !== "sft" && method !== "dpo" && method !== "orpo") throw new Error(`--method must be sft | dpo | orpo (got "${method}")`);
  const sftScope = opt(args, "sft-scope") ?? null;
  if (sftScope !== null && sftScope !== "full" && sftScope !== "response") throw new Error(`--sft-scope must be full | response (got "${sftScope}")`);
  const noSegment = flag(args, "no-segment");
  const numbers = new Map<string, number>();
  for (const name of ["iters", "seq", ...(noSegment ? [] : ["seg"]), "save-every", "rank", "scale", "lr", "batch",
    "grad-accum", "seed", "grad-clip", "val-size", "num-layers", "steps-per-report", "steps-per-eval", "dropout", "weight-decay",
    ...(method === "orpo" ? ["lambda"] : [])]) {
    const raw = opt(args, name);
    if (raw === undefined) continue;
    const value = Number(raw);
    if (!Number.isFinite(value)) throw new Error(`--${name} expects a number (got "${raw}")`);
    numbers.set(name, value);
  }
  return { query, dataDir, method, sftScope, numbers, adapter: opt(args, "adapter"), resume: opt(args, "resume") ?? "",
    noSegment, flashOn: !flag(args, "no-flash"), prefixOn: !flag(args, "no-prefix"), dryRun: flag(args, "dry-run"),
    gradCheckpoint: flag(args, "grad-checkpoint") };
}

export interface TrainPlan {
  method: TrainMethod; isOrpo: boolean; adapter: string; iters: number; seq: number; seg: number;
  saveEvery: number; flashOn: boolean; prefixOn: boolean; resume: string;
  /** The snake_case submit record the finetune runner parses (finetune/config.ts). */
  cfg: Record<string, unknown>;
}

/** Method-dependent defaults over the validated flags; model-dependent ones
 * (`defaults`) are declared by the model's profile. The adapter defaults to
 * `<root>/adapters/<method>-<model>` (root: MLX_BUN_HOME). */
export function trainPlan(parsed: TrainArgs, model: SelectedModel, defaults: TrainingDefaults, root: string = mlxBunHome()): TrainPlan {
  const num = (name: string, fallback: number) => parsed.numbers.get(name) ?? fallback;
  const { method } = parsed, isOrpo = method === "orpo";
  const adapter = parsed.adapter ?? join(storagePath("adapters", root), `${method}-${modelShortName(model.repoId)}`);
  const iters = num("iters", 100);
  const seq = num("seq", defaults.maxSeqLength);
  const seg = parsed.noSegment ? 0 : num("seg", isOrpo ? 2 : 0);
  const saveEvery = num("save-every", 0);
  const cfg: Record<string, unknown> = {
    model_dir: model.path,
    data_dir: parsed.dataDir,
    adapter_path: adapter,
    method,
    rank: num("rank", isOrpo ? 16 : 8),
    scale: num("scale", isOrpo ? 2.0 : 1.0),
    rank_scaling: "by_bits",
    num_layers: num("num-layers", -1),
    iters,
    learning_rate: num("lr", isOrpo ? 1e-5 : method === "dpo" ? 5e-5 : 2e-4),
    max_seq_length: seq,
    batch_size: num("batch", 1),
    grad_accumulation_steps: num("grad-accum", 1),
    seed: num("seed", 0),
    steps_per_report: num("steps-per-report", 1),
    steps_per_eval: num("steps-per-eval", saveEvery > 0 ? saveEvery : 1_000_000),
    save_checkpoints: saveEvery > 0,
    segment_size: seg,
    grad_clip_norm: num("grad-clip", 1.0),
    val_max_examples: num("val-size", 256),
    warm_start_adapter: parsed.resume,
    ...(parsed.numbers.has("dropout") ? { lora_dropout: parsed.numbers.get("dropout") } : {}),
    ...(parsed.numbers.has("weight-decay") ? { weight_decay: parsed.numbers.get("weight-decay") } : {}),
    ...(parsed.gradCheckpoint ? { grad_checkpoint: true } : {}),
    ...(parsed.sftScope ? { sft_scope: parsed.sftScope } : {}),
    ...(isOrpo ? {
      orpo_lambda: num("lambda", 0.1),
      orpo_lr_schedule: "cosine",
      orpo_warmup_iters: Math.min(10, Math.floor(iters / 10)),
      orpo_chunk_size: 512,
      orpo_flash_ce: parsed.flashOn,
      orpo_fused_ce: !parsed.flashOn,
      orpo_prefix_shared: parsed.prefixOn,
    } : {}),
  };
  return { method, isOrpo, adapter, iters, seq, seg, saveEvery, flashOn: parsed.flashOn, prefixOn: parsed.prefixOn,
    resume: parsed.resume, cfg };
}

function planLines(plan: TrainPlan, model: SelectedModel, picked: boolean,
  ds: { n_train: number; n_valid: number; format: string }): string[] {
  const { cfg } = plan;
  const lines = [
    `${style.green("●")} ${style.bold(`train ${plan.method}`)} ${style.dim(`· ${model.repoId}${picked ? " (auto-picked)" : ""}`)}`,
    "",
    `data       ${style.bold(`${ds.n_train} train`)}${ds.n_valid ? ` · ${ds.n_valid} valid` : ""} ${style.dim(`· format ${ds.format}`)}`,
    `loop       ${style.dim(`iters ${plan.iters} · lr ${cfg.learning_rate} · rank ${cfg.rank} · scale ${cfg.scale} · seq ${plan.seq} · batch ${cfg.batch_size}`)}`,
  ];
  if (plan.isOrpo) {
    const accum = cfg.grad_accumulation_steps as number, batch = cfg.batch_size as number;
    lines.push(
      `head       ${style.dim(plan.flashOn ? "flash-CCE Metal ([M,vocab]-free)" : "MLX fused linear-CE")}`,
      `stack      ${style.dim(`prefix-share ${plan.prefixOn ? "on" : "off"} · segmented ${plan.seg > 0 ? `${plan.seg}/seg` : "off"} · λ ${cfg.orpo_lambda}`)}`,
      `stability  ${style.dim(`grad-clip ${cfg.grad_clip_norm || "off"} · val-size ${cfg.val_max_examples}${accum > 1 ? ` · grad-accum ${accum} (eff batch ${batch * accum})` : ""}`)}`,
    );
  } else lines.push(`stack      ${style.dim(`segmented ${plan.seg > 0 ? `${plan.seg}/seg` : "off"}`)}`);
  if (plan.resume) lines.push(`warm-start ${style.dim(`from ${plan.resume} (weights only)`)}`);
  if (plan.saveEvery > 0) lines.push(`checkpoint ${style.dim(`every ${plan.saveEvery} steps`)}`);
  lines.push("", `adapter    ${style.dim(plan.adapter)}`);
  return lines;
}

export interface TrainDependencies {
  /** Model selection; the signal cancels a starter download it may start. */
  resolve(query: string | null, signal?: AbortSignal): Promise<{ m: SelectedModel; picked: boolean }>;
  inspect: typeof inspectDataset;
  runner(): JobRunner;
  /** Peak-memory reader; null when the native binding is unavailable. */
  memory(): Promise<PeakMemory | null>;
  exists(path: string): boolean;
  /** The fine-tuning defaults the model at `modelDir` declares through its resolved profile. */
  trainingDefaults(modelDir: string): Promise<TrainingDefaults>;
  log(line: string): void;
  /** Storage root for default outputs (MLX_BUN_HOME). */
  root(): string;
  now(): number;
}
/** Resolve the model's profile from its config alone (no weights, no native
 * load) and return the fine-tuning defaults its graph declares. */
export async function modelTrainingDefaults(modelDir: string): Promise<TrainingDefaults> {
  const { loadModelConfig } = await import("@mlx-bun/inference/artifacts/config");
  const { resolveModelProfile, trainingDefaultsFor } = await import("@mlx-bun/inference/models/profile");
  return trainingDefaultsFor(resolveModelProfile(await loadModelConfig(modelDir)));
}
const trainDefaults: TrainDependencies = {
  resolve: (query, signal) => resolveModelAuto(query, {}, signal),
  inspect: inspectDataset,
  runner: () => createFinetuneRunner(),
  async memory() {
    // The binding dlopens at import; stay behind the training path and report
    // no peak when MLX cannot load rather than failing the run.
    try {
      const ffi = await import("@mlx-bun/mlx/ffi");
      return { peak: ffi.peakMemory, reset: ffi.resetPeakMemory };
    } catch { return null; }
  },
  exists: existsSync,
  trainingDefaults: modelTrainingDefaults,
  log: line => console.log(line), root: () => mlxBunHome(), now: Date.now,
};

/** `train`: validate, resolve the model, preflight the dataset, print the plan,
 * then drive the finetune runner in-process. Cancellation reaches the runner
 * through `signal`; a cancelled run exits with the signal's reason and no adapter. */
export async function runTrain(args: CommandArgs, supplied: Partial<TrainDependencies> = {}, signal?: AbortSignal): Promise<void> {
  const deps = { ...trainDefaults, ...supplied };
  const parsed = parseTrainArgs(args, deps.exists);
  signal?.throwIfAborted();
  const { m, picked } = await deps.resolve(parsed.query, signal);
  const plan = trainPlan(parsed, m, await deps.trainingDefaults(m.path), deps.root());

  // Pre-flight: dataset counts + detected format (bail before loading the model).
  const ds = await deps.inspect(parsed.dataDir);
  if (!ds.ok) throw new Error(`dataset: ${ds.error}`);

  deps.log("");
  for (const line of boxLines(planLines(plan, m, picked, ds))) deps.log(line);
  deps.log("");
  deps.log(`  ${style.dim("watch live (other tab):")} ${style.accent(`mlx-bun train-watch ${plan.adapter}`)}`);
  deps.log("");
  if (parsed.dryRun) { deps.log(`  ${style.dim("dry run — not training.")}`); return; }
  signal?.throwIfAborted();

  // Run the finetune job runner IN-PROCESS (foreground), streaming metrics to
  // the terminal — the same runner the server drives as a child job.
  const memory = await deps.memory();
  memory?.reset();
  const peak = () => (memory ? ` · peak ${gb(memory.peak())}` : "");
  const losses: number[] = [], stepMs: number[] = [];
  let lastStepT = deps.now();
  const emit = (e: JobEvent) => {
    if (e.type === "stage" && e.message) deps.log(`  ${style.dim("·")} ${e.message}`);
    else if (e.type === "metric" && e.kind === "train") {
      const now = deps.now(); stepMs.push(now - lastStepT); lastStepT = now;
      losses.push(e.loss);
      const n = losses.length;
      if (n <= 3 || n % 10 === 0)
        deps.log(`  step ${n}/${plan.iters}: loss ${style.bold(e.loss.toFixed(4))} ${style.dim(`(${(stepMs[stepMs.length - 1]! / 1000).toFixed(1)}s/step${peak()})`)}`);
    }
  };
  try {
    await deps.runner()(emit, plan.cfg, signal);
  } catch (error) {
    if (signal?.aborted) throw signal.reason instanceof Error ? signal.reason : new Error("training cancelled");
    throw new Error(`training failed: ${error instanceof Error ? error.message : String(error)}`);
  }
  const finite = losses.every(l => Number.isFinite(l));
  const sorted = stepMs.slice(1).sort((a, b) => a - b);
  const med = sorted[Math.floor(sorted.length / 2)] ?? stepMs[0] ?? 0;
  deps.log("");
  for (const line of boxLines([
    `${style.green("●")} ${style.bold("training complete")} ${style.dim(`· ${losses.length} steps`)}`,
    "",
    `loss       ${style.bold(`${losses[0]?.toFixed(4) ?? "—"} → ${losses[losses.length - 1]?.toFixed(4) ?? "—"}`)}${finite ? "" : "  (NON-FINITE!)"}`,
    `speed      ${style.dim(`${(med / 1000).toFixed(1)}s/step median${peak()}`)}`,
    "",
    `adapter    ${style.bold(plan.adapter)}`,
    `serve it   ${style.accent(`mlx-bun serve ${m.repoId} --adapter ${plan.adapter}`)}`,
  ])) deps.log(line);
}

export interface FuseDependencies {
  registry(): ModelRegistry;
  /** The Hub write token and push behind `--upload-repo`, as convert's. */
  credentials: UploadDependencies["credentials"];
  publish: UploadDependencies["publish"];
  /** Storage root for the default output (MLX_BUN_HOME). */
  root(): string;
  fuse: typeof fuseAdapter;
  exists(path: string): boolean;
  log(line: string): void;
  step: typeof step;
}
const fuseDefaults: FuseDependencies = {
  registry: () => openRegistry(), root: () => mlxBunHome(), ...uploadDefaults,
  fuse: async (...call) => (await import("@mlx-bun/training")).fuseAdapter(...call),
  exists: existsSync, log: line => console.log(line), step,
};
const REFUSED_FUSE_FLAGS = ["export-gguf", "gguf-path"];

/** `fuse`: mlx_lm.fuse counterpart over the public training library
 * (`--dequantize` writes dense weights; `--upload-repo` pushes the result like
 * convert's). GGUF export is refused. The merge
 * itself has no cancellation seam: a signal is honored before it starts; one
 * arriving during the merge lets it finish so the output is never half-written. */
export async function runFuse(args: CommandArgs, supplied: Partial<FuseDependencies> = {}, signal?: AbortSignal): Promise<void> {
  const deps = { ...fuseDefaults, ...supplied };
  const unsupported = REFUSED_FUSE_FLAGS.filter(name => args.values[name] !== undefined).map(name => `--${name}`);
  if (unsupported.length > 0) throw new Error(`${unsupported.join(", ")}: not supported (GGUF export is not implemented; fuse writes safetensors; see: mlx-bun help fuse)`);
  // The write token is resolved before any fuse work, as convert does.
  const uploadRepo = opt(args, "upload-repo");
  if (uploadRepo !== undefined) requireWriteToken(deps.credentials());
  const modelArg = args.positionals[0] ?? opt(args, "model");
  if (!modelArg) throw new Error("usage: mlx-bun fuse <model-query-or-path> --adapter <dir> [--save-path <dir>]");
  const adapterDir = opt(args, "adapter") ?? opt(args, "adapter-path") ?? "adapters";
  if (!deps.exists(adapterDir)) throw new Error(`adapter dir not found: ${adapterDir}`);
  let modelDir = modelArg, modelId = modelArg;
  if (!deps.exists(`${modelArg}/config.json`)) {
    const reg = deps.registry();
    try {
      if (reg.list().length === 0) await reg.scan();
      ({ path: modelDir, repoId: modelId } = reg.resolve(modelArg));
    } finally { reg.close(); }
  }
  // An explicit --save-path keeps mlx_lm.fuse's semantics; the default is a
  // fresh directory in the app's models, never overwritten.
  let savePath = opt(args, "save-path");
  if (savePath === undefined) {
    savePath = join(storagePath("models", deps.root()), `${modelShortName(modelId)}-fused`);
    if (deps.exists(savePath)) throw new Error(`${savePath} already exists — delete it or pass --save-path <dir>`);
  }
  signal?.throwIfAborted();
  const s = deps.step(`fusing ${adapterDir} into ${modelDir}`);
  let interrupted = false;
  const onAbort = () => {
    interrupted = true;
    s.update(`fusing ${adapterDir} into ${modelDir} ${style.dim(`· cancellation requested; the merge cannot be interrupted, finishing so ${savePath} is not left half-written`)}`);
  };
  signal?.addEventListener("abort", onAbort, { once: true });
  let fusedDir: string | undefined;
  try {
    const dequantize = flag(args, "dequantize");
    const stats = await deps.fuse(modelDir, adapterDir, savePath, e => s.update(e.message), { dequantize });
    s.done(`fused ${stats.fusedModules} module(s) ${style.dim(`· ${stats.totalTensors} tensors written`)}`);
    deps.log("");
    for (const line of boxLines([
      `${style.green("●")} ${style.bold("fuse complete")}`,
      "",
      `base      ${style.dim(modelDir)}`,
      `adapter   ${style.dim(adapterDir)}`,
      `model     ${style.bold(stats.outDir)}`,
      ...(dequantize ? [`weights   ${style.dim("dequantized to dense")}`] : []),
      ...(stats.skippedAdapterTensors > 0
        ? [`skipped   ${style.dim(`${stats.skippedAdapterTensors} adapter tensor(s) with no matching base weight`)}`] : []),
      "",
      `serve it   ${style.accent(`mlx-bun serve ${stats.outDir}`)}`,
    ])) deps.log(line);
    if (interrupted) deps.log(`  ${style.dim("cancellation arrived during the merge; it cannot be interrupted, so the output was completed.")}`);
    fusedDir = stats.outDir;
  } catch (error) {
    s.fail(`fuse failed: ${error instanceof Error ? error.message : String(error)}`);
    throw error;
  } finally { signal?.removeEventListener("abort", onAbort); }
  // The push starts only for an uninterrupted run; a cancel that arrived mid-merge only completes the output.
  if (uploadRepo !== undefined && fusedDir !== undefined && !interrupted)
    await publishModel(deps, { kind: "finetune", repoId: uploadRepo, dir: fusedDir, what: "fused" }, signal);
}

export interface WatchDependencies { watch: typeof runWatch; root(): string }
const watchDefaults: WatchDependencies = { watch: runWatch, root: () => mlxBunHome() };

/** The adapter directory under `<root>/adapters` whose metrics.jsonl changed last. */
function latestRun(root: string): string | undefined {
  const adapters = storagePath("adapters", root);
  let latest: { dir: string; at: number } | undefined;
  try {
    for (const name of readdirSync(adapters)) {
      const dir = join(adapters, name);
      try {
        const at = statSync(join(dir, "metrics.jsonl")).mtimeMs;
        if (!latest || at > latest.at) latest = { dir, at };
      } catch { /* not a training run */ }
    }
  } catch { /* no adapter store yet */ }
  return latest?.dir;
}

/** `train-watch`: live dashboard over `<adapter>/metrics.jsonl`; without a
 * directory, the most recently updated run in the app's adapter store. */
export async function runTrainWatch(args: CommandArgs, supplied: Partial<WatchDependencies> = {}, signal?: AbortSignal): Promise<void> {
  const deps = { ...watchDefaults, ...supplied };
  const dir = args.positionals[0] ?? opt(args, "adapter") ?? latestRun(deps.root());
  if (!dir) throw new Error(`no training run found in ${storagePath("adapters", deps.root())} — usage: mlx-bun train-watch <adapter-dir>`);
  await deps.watch(dir, { signal });
}
