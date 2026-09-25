import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { Registry } from "@mlx-bun/hub/registry";
import type { fuseAdapter } from "@mlx-bun/training";
import { createFinetuneRunner } from "../finetune/job";
import { inspectDataset } from "../finetune/inspect";
import { runWatch } from "../finetune/watch";
import type { JobEvent, JobRunner } from "../jobs/protocol";
import type { CommandArgs } from "./args";
import { resolveModelAuto } from "./model-selection";
import { boxLines, step, style } from "./terminal";

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
const home = () => process.env.HOME ?? homedir();

export interface TrainArgs {
  query: string | null; dataDir: string; method: TrainMethod; sftScope: "full" | "response" | null;
  /** Validated numeric flags that were supplied; defaults are method/model dependent. */
  numbers: ReadonlyMap<string, number>;
  adapter?: string; resume: string; noSegment: boolean; flashOn: boolean; prefixOn: boolean; dryRun: boolean;
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
    "grad-accum", "seed", "grad-clip", "val-size", ...(method === "orpo" ? ["lambda"] : [])]) {
    const raw = opt(args, name);
    if (raw === undefined) continue;
    const value = Number(raw);
    if (!Number.isFinite(value)) throw new Error(`--${name} expects a number (got "${raw}")`);
    numbers.set(name, value);
  }
  return { query, dataDir, method, sftScope, numbers, adapter: opt(args, "adapter"), resume: opt(args, "resume") ?? "",
    noSegment, flashOn: !flag(args, "no-flash"), prefixOn: !flag(args, "no-prefix"), dryRun: flag(args, "dry-run") };
}

export interface TrainPlan {
  method: TrainMethod; isOrpo: boolean; isGemma: boolean; adapter: string; iters: number; seq: number; seg: number;
  saveEvery: number; flashOn: boolean; prefixOn: boolean; resume: string;
  /** The snake_case submit record the finetune runner parses (finetune/config.ts). */
  cfg: Record<string, unknown>;
}

/** Main's method- and model-dependent defaults over the validated flags. */
export function trainPlan(parsed: TrainArgs, model: SelectedModel, isGemma: boolean, homeDir: string = home()): TrainPlan {
  const num = (name: string, fallback: number) => parsed.numbers.get(name) ?? fallback;
  const { method } = parsed, isOrpo = method === "orpo";
  const adapter = parsed.adapter ?? `${homeDir}/.cache/mlx-bun/mlx-bun-finetunes/${method}-${isGemma ? "e4b" : "cpm5"}`;
  const iters = num("iters", 100);
  const seq = num("seq", isGemma ? 8192 : 4096);
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
    num_layers: -1,
    iters,
    learning_rate: num("lr", isOrpo ? 1e-5 : method === "dpo" ? 5e-5 : 2e-4),
    max_seq_length: seq,
    batch_size: num("batch", 1),
    grad_accumulation_steps: num("grad-accum", 1),
    seed: num("seed", 0),
    steps_per_report: 1,
    steps_per_eval: saveEvery > 0 ? saveEvery : 1_000_000,
    save_checkpoints: saveEvery > 0,
    segment_size: seg,
    grad_clip_norm: num("grad-clip", 1.0),
    val_max_examples: num("val-size", 256),
    warm_start_adapter: parsed.resume,
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
  return { method, isOrpo, isGemma, adapter, iters, seq, seg, saveEvery, flashOn: parsed.flashOn, prefixOn: parsed.prefixOn,
    resume: parsed.resume, cfg };
}

function planLines(plan: TrainPlan, model: SelectedModel, picked: boolean,
  ds: { n_train: number; n_valid: number; format: string }): string[] {
  const { cfg } = plan;
  const lines = [
    `${style.green("●")} ${style.bold(`train ${plan.method}`)} ${style.dim(`· ${model.repoId}${picked ? " (auto-picked)" : ""}${plan.isGemma ? " · e4b defaults" : ""}`)}`,
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
  readText(path: string): Promise<string>;
  log(line: string): void;
  home(): string;
  now(): number;
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
  exists: existsSync, readText: path => Bun.file(path).text(),
  log: line => console.log(line), home, now: Date.now,
};

/** `train`: validate, resolve the model, preflight the dataset, print the plan,
 * then drive the finetune runner in-process. Cancellation reaches the runner
 * through `signal`; a cancelled run exits with the signal's reason and no adapter. */
export async function runTrain(args: CommandArgs, supplied: Partial<TrainDependencies> = {}, signal?: AbortSignal): Promise<void> {
  const deps = { ...trainDefaults, ...supplied };
  const parsed = parseTrainArgs(args, deps.exists);
  signal?.throwIfAborted();
  const { m, picked } = await deps.resolve(parsed.query, signal);
  const isGemma = (await deps.readText(`${m.path}/config.json`)).toLowerCase().includes("gemma");
  const plan = trainPlan(parsed, m, isGemma, deps.home());

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
  fuse: typeof fuseAdapter;
  exists(path: string): boolean;
  log(line: string): void;
  step: typeof step;
}
const fuseDefaults: FuseDependencies = {
  registry: () => new Registry(),
  fuse: async (...call) => (await import("@mlx-bun/training")).fuseAdapter(...call),
  exists: existsSync, log: line => console.log(line), step,
};
const REFUSED_FUSE_FLAGS = ["de-quantize", "dequantize", "export-gguf", "gguf-path", "upload-repo"];

/** `fuse`: mlx_lm.fuse counterpart over the public training library. The merge
 * itself has no cancellation seam: a signal is honored before it starts; one
 * arriving during the merge lets it finish so the output is never half-written. */
export async function runFuse(args: CommandArgs, supplied: Partial<FuseDependencies> = {}, signal?: AbortSignal): Promise<void> {
  const deps = { ...fuseDefaults, ...supplied };
  const unsupported = REFUSED_FUSE_FLAGS.filter(name => args.values[name] !== undefined).map(name => `--${name}`);
  if (unsupported.length > 0) throw new Error(`${unsupported.join(", ")}: not supported (see: mlx-bun help fuse)`);
  const modelArg = args.positionals[0] ?? opt(args, "model");
  if (!modelArg) throw new Error("usage: mlx-bun fuse <model-query-or-path> --adapter <dir> [--save-path <dir>]");
  const adapterDir = opt(args, "adapter") ?? opt(args, "adapter-path") ?? "adapters";
  const savePath = opt(args, "save-path") ?? "fused_model";
  if (!deps.exists(adapterDir)) throw new Error(`adapter dir not found: ${adapterDir}`);
  let modelDir = modelArg;
  if (!deps.exists(`${modelArg}/config.json`)) {
    const reg = deps.registry();
    try {
      if (reg.list().length === 0) await reg.scan();
      modelDir = reg.resolve(modelArg).path;
    } finally { reg.close(); }
  }
  signal?.throwIfAborted();
  const s = deps.step(`fusing ${adapterDir} into ${modelDir}`);
  let interrupted = false;
  const onAbort = () => {
    interrupted = true;
    s.update(`fusing ${adapterDir} into ${modelDir} ${style.dim(`· cancellation requested; the merge cannot be interrupted, finishing so ${savePath} is not left half-written`)}`);
  };
  signal?.addEventListener("abort", onAbort, { once: true });
  try {
    const stats = await deps.fuse(modelDir, adapterDir, savePath, e => s.update(e.message));
    s.done(`fused ${stats.fusedModules} module(s) ${style.dim(`· ${stats.totalTensors} tensors written`)}`);
    deps.log("");
    for (const line of boxLines([
      `${style.green("●")} ${style.bold("fuse complete")}`,
      "",
      `base      ${style.dim(modelDir)}`,
      `adapter   ${style.dim(adapterDir)}`,
      `model     ${style.bold(stats.outDir)}`,
      ...(stats.skippedAdapterTensors > 0
        ? [`skipped   ${style.dim(`${stats.skippedAdapterTensors} adapter tensor(s) with no matching base weight`)}`] : []),
      "",
      `serve it   ${style.accent(`mlx-bun serve ${stats.outDir}`)}`,
    ])) deps.log(line);
    if (interrupted) deps.log(`  ${style.dim("cancellation arrived during the merge; it cannot be interrupted, so the output was completed.")}`);
  } catch (error) {
    s.fail(`fuse failed: ${error instanceof Error ? error.message : String(error)}`);
    throw error;
  } finally { signal?.removeEventListener("abort", onAbort); }
}

export interface WatchDependencies { watch: typeof runWatch; home(): string }
const watchDefaults: WatchDependencies = { watch: runWatch, home };

/** `train-watch`: live dashboard over `<adapter>/metrics.jsonl`. */
export async function runTrainWatch(args: CommandArgs, supplied: Partial<WatchDependencies> = {}, signal?: AbortSignal): Promise<void> {
  const deps = { ...watchDefaults, ...supplied };
  const dir = args.positionals[0] ?? opt(args, "adapter") ?? `${deps.home()}/.cache/mlx-bun/mlx-bun-finetunes/orpo-cpm5`;
  await deps.watch(dir, { signal });
}
