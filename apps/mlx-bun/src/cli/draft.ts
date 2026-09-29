import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import type { ChatTemplate, LoadedTokenizer } from "@mlx-bun/inference/input";
import type { RuntimeModel } from "@mlx-bun/inference/models";
import type { quantizeDrafterDir } from "@mlx-bun/quantize/drafter";
import type * as Training from "@mlx-bun/training/dspark";
import { checkPositionals, type CommandArgs } from "./args";
import { resolveModelAuto } from "./model-selection";
import { boxLines, style } from "./terminal";
import { mlxBunHome, modelShortName, storagePath } from "../storage/paths";

// `mlx-bun draft`: produce the drafters `serve --draft-model` mounts. Thin
// verbs over the public training and quantize libraries: argument policy,
// default output locations and progress presentation live here; regeneration,
// the DSpark objective, calibration and quantization do not.
//
//   regen      the target answers a topic list; tapped hiddens become shards
//   train      shards -> a DSpark drafter checkpoint (models/<target>-dspark)
//   calibrate  fit per-position confidence thresholds into dspark.json
//   quantize   affine-quantize a released DeepSpec drafter (confidence head stays bf16)

export const DRAFT_ACTIONS = ["regen", "train", "calibrate", "quantize"] as const;
export type DraftAction = typeof DRAFT_ACTIONS[number];

/** The e4b tap layers (the last is the post-final-norm sentinel); other targets pass `--tap-layers`. */
const DEFAULT_TAP_LAYERS = [20, 31, 41, 42];

function opt(args: CommandArgs, name: string): string | undefined {
  const value = args.values[name];
  return typeof value === "string" && value ? value : undefined;
}

export interface DraftArgs {
  action: DraftAction;
  /** The target model (regen, train, calibrate) or the drafter directory (quantize). */
  subject: string;
  numbers: ReadonlyMap<string, number>;
  strings: ReadonlyMap<string, string>;
  tapLayers: number[] | undefined;
  seqHead: "markov" | "rnn" | undefined;
  flags: { resume: boolean; force: boolean };
}

const NUMBER_FLAGS: Record<DraftAction, readonly string[]> = {
  regen: ["max-resp", "seqs-per-shard", "min-resp"],
  train: ["iters", "batch", "gamma", "max-ctx", "lr", "warmup", "eval-every", "eval-anchors", "seed", "d-draft", "n-heads", "markov-rank", "layers"],
  calibrate: ["n", "max-tokens", "precision", "min-samples"],
  quantize: ["bits", "group-size"],
};
const STRING_FLAGS: Record<DraftAction, readonly string[]> = {
  regen: ["topics", "out"], train: ["data", "out"], calibrate: ["drafter", "data", "out"], quantize: ["out"],
};
const REQUIRED: Record<DraftAction, readonly string[]> = { regen: ["topics"], train: ["data"], calibrate: ["drafter", "data"], quantize: [] };

/** Validate flags before anything is resolved or loaded, in the order the action reads them. */
export function parseDraftArgs(args: CommandArgs): DraftArgs {
  checkPositionals("draft", args);
  const action = args.positionals[0] as DraftAction;
  if (!DRAFT_ACTIONS.includes(action)) throw new Error(`usage: mlx-bun draft <${DRAFT_ACTIONS.join("|")}> <${action === "quantize" ? "drafter-dir" : "model"}> [options]   (see: mlx-bun help draft)`);
  const subject = args.positionals[1] ?? opt(args, "model");
  if (!subject) throw new Error(`usage: mlx-bun draft ${action} <${action === "quantize" ? "drafter-dir" : "model"}> [options]   (see: mlx-bun help draft)`);
  const strings = new Map<string, string>(), numbers = new Map<string, number>();
  for (const name of REQUIRED[action]) if (!opt(args, name)) throw new Error(`draft ${action}: --${name} is required`);
  for (const name of STRING_FLAGS[action]) { const value = opt(args, name); if (value !== undefined) strings.set(name, value); }
  for (const name of NUMBER_FLAGS[action]) {
    const raw = opt(args, name);
    if (raw === undefined) continue;
    const value = Number(raw);
    if (!Number.isFinite(value)) throw new Error(`--${name} expects a number (got "${raw}")`);
    numbers.set(name, value);
  }
  const positive = (name: string, integer = true) => {
    const value = numbers.get(name);
    if (value !== undefined && !(value > 0 && (!integer || Number.isInteger(value)))) throw new Error(`--${name} expects a positive ${integer ? "integer" : "number"} (got "${value}")`);
  };
  for (const name of ["max-resp", "seqs-per-shard", "min-resp", "iters", "batch", "gamma", "max-ctx", "eval-every", "eval-anchors", "d-draft", "n-heads", "markov-rank", "layers", "n", "max-tokens", "min-samples", "group-size"]) positive(name);
  positive("lr", false);
  if (action === "quantize") {
    const bits = numbers.get("bits");
    if (bits !== undefined && bits !== 4 && bits !== 8) throw new Error(`--bits expects 4 or 8 (got "${bits}")`);
    const groupSize = numbers.get("group-size");
    if (groupSize !== undefined && groupSize !== 32 && groupSize !== 64) throw new Error(`--group-size expects 32 or 64 (got "${groupSize}")`);
  }
  const precision = numbers.get("precision");
  if (precision !== undefined && !(precision > 0 && precision <= 1)) throw new Error(`--precision expects a value in (0, 1] (got "${precision}")`);
  let tapLayers: number[] | undefined;
  const rawTaps = opt(args, "tap-layers");
  if (rawTaps !== undefined) {
    if (action !== "regen" && action !== "train") throw new Error(`--tap-layers applies to regen and train`);
    tapLayers = rawTaps.split(",").map(part => Number(part.trim()));
    if (tapLayers.some(n => !Number.isInteger(n) || n < 0)) throw new Error(`--tap-layers must be non-negative integers (got "${rawTaps}")`);
  }
  const rawHead = opt(args, "seq-head");
  if (rawHead !== undefined && rawHead !== "markov" && rawHead !== "rnn") throw new Error(`--seq-head expects markov|rnn (got "${rawHead}")`);
  return { action, subject, numbers, strings, tapLayers, seqHead: rawHead as "markov" | "rnn" | undefined,
    flags: { resume: args.values.resume === true, force: args.values.force === true } };
}

/** A loaded target: the model plus what tokenizing a prompt needs. Owned by the caller. */
export interface DraftTarget {
  model: RuntimeModel; tokenizer: LoadedTokenizer; template: ChatTemplate; dispose(): void;
}

export interface DraftDependencies {
  resolve(query: string, signal?: AbortSignal): Promise<{ m: { path: string; repoId: string } }>;
  loadTarget(modelDir: string): Promise<DraftTarget>;
  training(): Promise<typeof Training>;
  quantizeDrafter(): Promise<typeof quantizeDrafterDir>;
  exists(path: string): boolean;
  readText(path: string): string;
  log(line: string): void;
  /** Storage root for default outputs (MLX_BUN_HOME). */
  root(): string;
}

async function loadTarget(modelDir: string): Promise<DraftTarget> {
  const [artifacts, models, input] = await Promise.all([
    import("@mlx-bun/inference/artifacts"), import("@mlx-bun/inference/models"), import("@mlx-bun/inference/input"),
  ]);
  const config = await artifacts.loadModelConfig(modelDir);
  const weights = await artifacts.Weights.open(modelDir);
  try {
    const model = models.createModel(weights, config);
    return { model, tokenizer: await input.loadTokenizer(modelDir), template: await input.ChatTemplate.load(modelDir),
      dispose() { if ("dispose" in model && typeof model.dispose === "function") (model as { dispose(): void }).dispose(); weights.dispose(); } };
  } catch (error) { weights.dispose(); throw error; }
}

const draftDefaults: DraftDependencies = {
  resolve: (query, signal) => resolveModelAuto(query, {}, signal),
  loadTarget,
  training: () => import("@mlx-bun/training/dspark"),
  quantizeDrafter: async () => (await import("@mlx-bun/quantize/drafter")).quantizeDrafterDir,
  exists: existsSync, readText: path => readFileSync(path, "utf8"),
  log: line => console.log(line), root: () => mlxBunHome(),
};

/** Default output locations, all under the app's storage root. */
export function draftOutput(action: DraftAction, parsed: DraftArgs, name: string, root: string): string {
  const explicit = parsed.strings.get("out");
  if (explicit) return explicit;
  if (action === "regen") return join(storagePath("datasets", root), `dspark-${name}`);
  if (action === "train") return join(storagePath("models", root), `${name}-dspark`);
  if (action === "quantize") return join(storagePath("models", root), `${name}-affine-q${parsed.numbers.get("bits") ?? 4}-g${parsed.numbers.get("group-size") ?? 64}`);
  return parsed.strings.get("drafter")!; // calibrate: rewrites the checkpoint's dspark.json in place
}

const secs = (ms: number) => `${(ms / 1000).toFixed(1)}s`;

/** `draft`: validate, resolve the target, then run one stage in-process. Cancellation
 * (`signal`) is honoured between topics, steps and prompts; a stage never leaves a
 * half-written checkpoint (a checkpoint is written whole, at an evaluation boundary). */
export async function runDraft(args: CommandArgs, supplied: Partial<DraftDependencies> = {}, signal?: AbortSignal): Promise<void> {
  const deps = { ...draftDefaults, ...supplied };
  const parsed = parseDraftArgs(args);
  const { action } = parsed;
  const num = (name: string, fallback: number) => parsed.numbers.get(name) ?? fallback;
  signal?.throwIfAborted();

  if (action === "quantize") {
    const dir = parsed.subject.replace(/\/+$/, "");
    if (!deps.exists(join(dir, "config.json"))) throw new Error(`${dir} has no config.json — pass a DeepSpec drafter directory`);
    const bits = num("bits", 4) as 4 | 8, groupSize = num("group-size", 64) as 32 | 64;
    const out = draftOutput(action, parsed, modelShortName(dir), deps.root());
    if (deps.exists(out)) throw new Error(`${out} already exists — delete it or pass --out <dir>`);
    deps.log(`  ${style.dim(`quantizing ${dir} · affine ${bits}-bit, group ${groupSize} · confidence_head stays bf16`)}`);
    const started = Date.now();
    const result = await (await deps.quantizeDrafter())(dir, out, { bits, groupSize,
      onProgress: (stage, message, progress) => { if (stage !== "quantizing" || Math.round(progress * 100) % 10 === 0) deps.log(`  ${style.dim("·")} [${stage}] ${message}`); } });
    for (const line of boxLines([
      `${style.green("●")} ${style.bold("drafter quantized")} ${style.dim(`· ${secs(Date.now() - started)}`)}`, "",
      `modules    ${style.dim(`${result.nQuantized} quantized · ${result.achievedBpw.toFixed(2)} bpw`)}`,
      `drafter    ${style.bold(out)}`, "",
      `gate it    ${style.accent(`bun scripts/drafter-ab.ts --target <model> --drafter-a ${dir} --drafter-b ${out}`)}`,
    ])) deps.log(line);
    return;
  }

  const { m } = await deps.resolve(parsed.subject, signal);
  const name = modelShortName(m.repoId);
  const library = await deps.training();
  const target = await deps.loadTarget(m.path);
  try {
    signal?.throwIfAborted();
    const text = target.model.config.text;
    const tapLayers = parsed.tapLayers ?? DEFAULT_TAP_LAYERS;
    if (action === "regen") {
      const topics = deps.readText(parsed.strings.get("topics")!).split("\n").map(t => t.trim()).filter(Boolean);
      if (!topics.length) throw new Error(`no topics in ${parsed.strings.get("topics")}`);
      const out = draftOutput(action, parsed, name, deps.root());
      const result = await library.regenDrafterData(target.model, target.tokenizer, target.template, topics, {
        outDir: out, tapLayers, maxResponseTokens: num("max-resp", 320), sequencesPerShard: num("seqs-per-shard", 32),
        minResponseTokens: num("min-resp", 6), signal,
        onProgress: event => {
          if (event.type === "start") deps.log(`  ${style.dim(`tap layers [${event.tapLayers}] of ${event.layers} · hidden ${event.hiddenSize}${event.resumed ? ` · resuming after ${event.resumed} topics` : ""}`)}`);
          else if (event.type === "shard") deps.log(`  shard ${event.index}: ${event.sequences} sequences, ${event.tokens} tokens`);
          else deps.log(`  ${style.dim(`${event.done}/${event.total} topics · kept ${event.kept} · ${event.tokens} tokens`)}`);
        },
      });
      for (const line of boxLines([
        `${style.green("●")} ${style.bold("regen complete")} ${style.dim(`· ${name}`)}`, "",
        `data       ${style.dim(`${result.kept} articles · ${result.tokens} tokens · ${result.shards} new shards · ${result.skippedShort} too short`)}`,
        `shards     ${style.bold(out)}`, "",
        `train it   ${style.accent(`mlx-bun draft train ${parsed.subject} --data ${out}${parsed.tapLayers ? ` --tap-layers ${tapLayers}` : ""}`)}`,
      ])) deps.log(line);
    } else if (action === "train") {
      const out = draftOutput(action, parsed, name, deps.root());
      const defaults = library.DEFAULT_DRAFTER_TRAIN_CONFIG, base = defaults.drafter;
      const gamma = num("gamma", base.gamma);
      const config = {
        ...defaults, dataDir: parsed.strings.get("data")!, outDir: out, targetId: `${m.repoId}@${text.hiddenSize}x${text.vocabSize}`,
        drafter: { ...base, gamma, dDraft: num("d-draft", base.dDraft), nHeads: num("n-heads", base.nHeads), nLayers: num("layers", base.nLayers),
          markovRank: num("markov-rank", base.markovRank), tapLayers, seqHead: parsed.seqHead ?? "markov" },
        iters: num("iters", defaults.iters), batch: num("batch", defaults.batch), maxCtx: num("max-ctx", defaults.maxCtx), lr: num("lr", defaults.lr),
        warmup: num("warmup", defaults.warmup), evalEvery: num("eval-every", defaults.evalEvery), evalAnchors: num("eval-anchors", defaults.evalAnchors),
        seed: num("seed", defaults.seed), resume: parsed.flags.resume,
      };
      const started = Date.now();
      let first = NaN, last = NaN;
      const result = await library.trainDrafter(target.model, config, event => {
        if (event.type === "start") deps.log(`  ${style.dim(`${event.shards} shards (${event.train} train / ${event.validation} val) · ${event.parameters} tensors · γ=${event.config.gamma} d=${event.config.dDraft} taps [${event.config.tapLayers}]${event.resumed ? " · RESUMED" : ""}`)}`);
        else if (event.type === "step") {
          if (Number.isNaN(first)) first = event.loss;
          last = event.loss;
          if (event.step === 1 || event.step % 50 === 0) deps.log(`  step ${event.step}/${event.iters}: loss ${style.bold(event.loss.toFixed(4))} ${style.dim(`lr ${event.lr.toExponential(2)}`)}`);
        } else deps.log(`  ${style.dim("held-out")} τ ${style.bold(event.tau.toFixed(3))} ${style.dim(`per-position [${event.perPosition.map(v => v.toFixed(2))}]`)}${event.saved ? style.green("  saved") : ""}`);
      }, signal);
      for (const line of boxLines([
        `${style.green("●")} ${style.bold("drafter trained")} ${style.dim(`· ${result.steps} steps · ${secs(Date.now() - started)}`)}`, "",
        `loss       ${style.bold(`${first.toFixed(4)} → ${last.toFixed(4)}`)}`,
        `best τ     ${style.bold(result.bestTau.toFixed(3))}`, "",
        `drafter    ${style.bold(out)}`,
        `calibrate  ${style.accent(`mlx-bun draft calibrate ${parsed.subject} --drafter ${out} --data <prompts.jsonl>`)}`,
        `serve it   ${style.accent(`mlx-bun serve ${m.repoId} --draft-model ${out}`)}`,
      ])) deps.log(line);
    } else {
      const drafterDir = parsed.strings.get("drafter")!;
      if (!deps.exists(join(drafterDir, "dspark.json"))) throw new Error(`${drafterDir} has no dspark.json — not a DSpark drafter`);
      const existing = library.readSts(drafterDir);
      if (existing && !parsed.flags.force)
        throw new Error(`${drafterDir} already has STS calibration (precision ${existing.target}, samples ${existing.samples ?? "?"}) — pass --force to recalibrate`);
      const prompts = deps.readText(parsed.strings.get("data")!).split("\n").filter(Boolean).map((line, i) => {
        const row = JSON.parse(line) as { prompt?: unknown };
        if (typeof row.prompt !== "string" && !Array.isArray(row.prompt)) throw new Error(`${parsed.strings.get("data")}:${i + 1}: each row needs a "prompt" (a string or chat messages)`);
        return row.prompt as string | { role: string; content: string }[];
      });
      const fit = await library.calibrateDrafter(target.model, target.tokenizer, target.template, drafterDir, {
        prompts: prompts as never, count: num("n", 32), maxTokens: num("max-tokens", 128), target: num("precision", 0.5), minSamples: num("min-samples", 50), signal,
        onPrompt: event => deps.log(`  [${event.index + 1}] ctx=${event.promptTokens} generated=${event.generated} acceptance=${event.acceptance.toFixed(3)}`),
      });
      fit.sts.thresholds.forEach((threshold, position) => deps.log(`  pos ${position}: threshold ${threshold.toFixed(4)}  n=${fit.positionSamples[position]}`));
      const out = draftOutput(action, parsed, name, deps.root());
      if (out !== drafterDir && !deps.exists(join(out, "dspark.json"))) throw new Error(`--out ${out} has no dspark.json — copy the checkpoint directory first`);
      const written = library.writeSts(out, fit.sts);
      for (const line of boxLines([
        `${style.green("●")} ${style.bold("calibration written")} ${style.dim(`· ${fit.sts.samples} samples · precision ${fit.sts.target}`)}`, "",
        `thresholds ${style.dim(`[${fit.sts.thresholds.map(t => t.toFixed(3))}]`)}`,
        `drafter    ${style.bold(written)}`,
      ])) deps.log(line);
    }
  } finally { target.dispose(); }
}
