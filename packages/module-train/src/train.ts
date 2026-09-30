import { existsSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";
import type { CliInvocation, CliTerminal, JobEmit, ModelCatalog } from "@mlx-bun/app-core";
import type { TrainingDefaults } from "@mlx-bun/inference/models/profile";
import { createFinetuneRunner } from "./job";
import { inspectDataset } from "./inspect";
import { runWatch } from "./watch";
import { modelShortName, selectModel, type SelectedModel } from "./model";

// Thin verbs over the module's fine-tuning producer and the public training
// library: argument policy, main's plan/summary presentation, and process
// cancellation live here; training numerics do not.

/** What a verb run was given: the host's parsed options and positionals (`CliInvocation`'s). */
export type VerbArgs = Pick<CliInvocation, "values" | "positionals">;
/** Allocator counters read through the native binding while training runs. */
export interface PeakMemory { peak(): number; reset(): void }
export type TrainMethod = "sft" | "dpo" | "orpo";

const gb = (bytes: number) => `${(bytes / 2 ** 30).toFixed(2)} GB`;
/** Main's `opt()`: an absent or empty value falls back to the default. */
export function opt(args: VerbArgs, name: string): string | undefined {
  const value = args.values[name];
  return typeof value === "string" && value ? value : undefined;
}
export const flag = (args: VerbArgs, name: string): boolean => args.values[name] === true;

export interface TrainArgs {
  query: string | null; dataDir: string; method: TrainMethod; sftScope: "full" | "response" | null;
  /** Validated numeric flags that were supplied; defaults are method/model dependent. */
  numbers: ReadonlyMap<string, number>;
  adapter?: string; resume: string; noSegment: boolean; flashOn: boolean; prefixOn: boolean; dryRun: boolean; gradCheckpoint: boolean;
}

/** Main's checks in main's order, all before any model resolution: usage,
 * train.jsonl, method, sft-scope, then each numeric flag main would read
 * (seg unless --no-segment; lambda only for ORPO). */
export function parseTrainArgs(args: VerbArgs, exists: (path: string) => boolean = existsSync): TrainArgs {
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
  /** The snake_case submit record the finetune runner parses (`config.ts`). */
  cfg: Record<string, unknown>;
}

/** Method-dependent defaults over the validated flags; model-dependent ones
 * (`defaults`) are declared by the model's profile. The adapter defaults to
 * `<adapters>/<method>-<model>` (the `adapters` storage entry, resolved only when no `--adapter` names one). */
export function trainPlan(parsed: TrainArgs, model: SelectedModel, defaults: TrainingDefaults, adaptersDir: () => string): TrainPlan {
  const num = (name: string, fallback: number) => parsed.numbers.get(name) ?? fallback;
  const { method } = parsed, isOrpo = method === "orpo";
  const adapter = parsed.adapter ?? join(adaptersDir(), `${method}-${modelShortName(model.repoId)}`);
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
  ds: { n_train: number; n_valid: number; format: string }, style: CliTerminal["style"]): string[] {
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

/** A fine-tune run: what the job child runs, driven in this process by `train`. */
export type TrainRunner = (emit: JobEmit, config: Record<string, unknown>, signal?: AbortSignal) => Promise<unknown>;

export interface TrainDependencies {
  /** Model selection; the signal cancels a starter download it may start. */
  resolve(query: string | null, signal?: AbortSignal): Promise<{ m: SelectedModel; picked: boolean }>;
  inspect: typeof inspectDataset;
  runner(): TrainRunner;
  /** Peak-memory reader; null when the native binding is unavailable. */
  memory(): Promise<PeakMemory | null>;
  exists(path: string): boolean;
  /** The fine-tuning defaults the model at `modelDir` declares through its resolved profile. */
  trainingDefaults(modelDir: string): Promise<TrainingDefaults>;
  log(line: string): void;
  terminal: CliTerminal;
  /** The `adapters` storage entry: where an adapter goes when `--adapter` names none. */
  adaptersDir(): string;
  now(): number;
}
/** Resolve the model's profile from its config alone (no weights, no native
 * load) and return the fine-tuning defaults its graph declares. */
export async function modelTrainingDefaults(modelDir: string): Promise<TrainingDefaults> {
  const { loadModelConfig } = await import("@mlx-bun/inference/artifacts/config");
  const { resolveModelProfile, trainingDefaultsFor } = await import("@mlx-bun/inference/models/profile");
  return trainingDefaultsFor(resolveModelProfile(await loadModelConfig(modelDir)));
}
/** The dependencies a `train` run has in a host: the catalog picks the model, the host draws the terminal. */
export function trainDependencies(services: { catalog: Pick<ModelCatalog, "find" | "pickDefault">; adaptersDir(): string },
  invocation: Pick<CliInvocation, "terminal" | "stdout">): TrainDependencies {
  return {
    resolve: (query, signal) => selectModel(services.catalog, query, signal),
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
    log: (line = "") => { invocation.stdout(line + "\n"); },
    terminal: invocation.terminal,
    adaptersDir: services.adaptersDir,
    now: Date.now,
  };
}

/** `train`: validate, resolve the model, preflight the dataset, print the plan,
 * then drive the finetune runner in-process. Cancellation reaches the runner
 * through `signal`; a cancelled run exits with the signal's reason and no adapter. */
export async function runTrain(args: VerbArgs, deps: TrainDependencies, signal?: AbortSignal): Promise<void> {
  const { terminal } = deps, { style } = terminal;
  const parsed = parseTrainArgs(args, deps.exists);
  signal?.throwIfAborted();
  const { m, picked } = await deps.resolve(parsed.query, signal);
  const plan = trainPlan(parsed, m, await deps.trainingDefaults(m.path), deps.adaptersDir);

  // Pre-flight: dataset counts + detected format (bail before loading the model).
  const ds = await deps.inspect(parsed.dataDir);
  if (!ds.ok) throw new Error(`dataset: ${ds.error}`);

  deps.log("");
  terminal.box(planLines(plan, m, picked, ds, style));
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
  const emit: JobEmit = e => {
    if (e.type === "stage" && e.message) deps.log(`  ${style.dim("·")} ${e.message}`);
    else if (e.type === "metric" && e.kind === "train") {
      const now = deps.now(); stepMs.push(now - lastStepT); lastStepT = now;
      const loss = e.loss as number;
      losses.push(loss);
      const n = losses.length;
      if (n <= 3 || n % 10 === 0)
        deps.log(`  step ${n}/${plan.iters}: loss ${style.bold(loss.toFixed(4))} ${style.dim(`(${(stepMs[stepMs.length - 1]! / 1000).toFixed(1)}s/step${peak()})`)}`);
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
  terminal.box([
    `${style.green("●")} ${style.bold("training complete")} ${style.dim(`· ${losses.length} steps`)}`,
    "",
    `loss       ${style.bold(`${losses[0]?.toFixed(4) ?? "—"} → ${losses[losses.length - 1]?.toFixed(4) ?? "—"}`)}${finite ? "" : "  (NON-FINITE!)"}`,
    `speed      ${style.dim(`${(med / 1000).toFixed(1)}s/step median${peak()}`)}`,
    "",
    `adapter    ${style.bold(plan.adapter)}`,
    `serve it   ${style.accent(`mlx-bun serve ${m.repoId} --adapter ${plan.adapter}`)}`,
  ]);
}

export interface WatchDependencies { watch: typeof runWatch; adaptersDir(): string }

/** The adapter directory under `adapters` whose metrics.jsonl changed last. */
function latestRun(adapters: string): string | undefined {
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
export async function runTrainWatch(args: VerbArgs, deps: WatchDependencies, signal?: AbortSignal): Promise<void> {
  const explicit = args.positionals[0] ?? opt(args, "adapter");
  const dir = explicit ?? latestRun(deps.adaptersDir());
  if (!dir) throw new Error(`no training run found in ${deps.adaptersDir()} — usage: mlx-bun train-watch <adapter-dir>`);
  await deps.watch(dir, { signal });
}
