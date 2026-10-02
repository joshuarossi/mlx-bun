import { existsSync, mkdirSync, mkdtempSync, renameSync, rmSync } from "node:fs";
import { basename, dirname, join, resolve } from "node:path";
import type { CliTerminal, JobService, ModelCatalog } from "@mlx-bun/app-core";
import { CONVERT_DTYPES, convertedModelName, quantizedModelName } from "./output-name";

const gb = (bytes: number) => `${(bytes / 2 ** 30).toFixed(2)} GB`;
const REPO_ID = /^[\w.-]+\/[\w.-]+$/;
const message = (error: unknown) => (error instanceof Error ? error.message : String(error));

/** What a `convert` run was given: the verb's parsed options and positionals. */
export interface ConvertArgs {
  readonly values: Readonly<Record<string, unknown>>;
  readonly positionals: readonly string[];
}

export interface ConvertDependencies {
  /** The web quantize job's producer, run as an owned child process with the
   * same snake_case config. The sensitivity sweep is synchronous, so only a
   * separate process keeps the parent responsive; cancellation terminates and
   * joins the child and discards its staging. */
  quantize(config: Record<string, unknown>, outDir: string, progress: (message: string) => void, signal?: AbortSignal): Promise<{ outputPath: string }>;
  catalog: Pick<ModelCatalog, "find" | "download" | "canPublish" | "publish">;
  /** The default output's parent: the module's `models` storage entry. */
  modelsDir(): string;
  terminal: CliTerminal;
  log(line?: string): void;
}

/** Run the quantize job in an owned child over a private root created beside
 * the destination (same filesystem): the child's result, its atomic staging and
 * any temporary probe (its `TMPDIR`) all live under that root. The parent tails
 * the job's events for progress, publishes only a complete result with one
 * rename, and on every other exit stops the job and waits for its process to be
 * gone, then removes only the root it owns. Nothing is inferred from filename
 * prefixes. */
export async function quantizeInChild(jobs: Pick<JobService, "submit" | "get" | "events" | "cancel">, config: Record<string, unknown>, outDir: string,
  progress: (message: string) => void, signal?: AbortSignal): Promise<{ outputPath: string }> {
  const destination = resolve(outDir);
  mkdirSync(dirname(destination), { recursive: true });
  const root = mkdtempSync(join(dirname(destination), `.${basename(destination)}.convert-`));
  const result = join(root, "result"), scratch = join(root, "tmp");
  mkdirSync(scratch);
  let jobId: string | undefined, settled: Promise<void> | undefined;
  // Stops the job if it still runs and waits until its process is gone, so nothing writes into the root once it is removed.
  const settle = () => settled ??= jobId ? jobs.cancel(jobId) : Promise.resolve();
  try {
    signal?.throwIfAborted();
    const job = await jobs.submit({ kind: "quantize", config: { ...config, out_dir: result }, outputPath: result, scratchDir: scratch });
    jobId = job.id;
    if (signal?.aborted) { await settle(); throw signal.reason; }
    const cancel = () => { void jobs.cancel(job.id).catch(() => {}); };
    signal?.addEventListener("abort", cancel, { once: true });
    try {
      for await (const event of jobs.events(job.id, signal)) {
        if (event.type === "stage" && event.message) progress(event.message);
      }
    } finally { signal?.removeEventListener("abort", cancel); }
    if (signal?.aborted) { await settle(); throw signal.reason; }
    const row = await jobs.get(job.id);
    if (!row || row.status !== "done") throw new Error(row?.error ?? `quantize job ${row?.status ?? "missing"}`);
    if (!existsSync(result)) throw new Error("quantize job reported success without a result");
    if (existsSync(destination)) throw new Error(`Cannot save to the path ${outDir} as it already exists — delete it or pass a fresh --mlx-path.`);
    await settle();
    renameSync(result, destination);
    return { outputPath: destination };
  } finally {
    // Join the job's process (SIGTERM, then SIGKILL after a grace period) before the root it writes into goes away.
    try { await settle(); } finally { rmSync(root, { recursive: true, force: true }); }
  }
}

const TRELLIS_OPTIONS = ["trellis-bits", "trellis-k-map", "trellis-k-budget", "trellis-ldlq", "trellis-reuse",
  "trellis-down-axis", "trellis-interleave", "trellis-layers"] as const;

interface TrellisSettings {
  bits: number; downAxis: "out" | "in"; kMap?: string; kBudget: string; ldlq?: string; reuse: string[];
  interleave: boolean; layers?: number;
}

/** The `--trellis-*` options of `--q-mode trellis`, checked against the files they name. Paths become absolute for the job child. */
function parseTrellisOptions(args: ConvertArgs): TrellisSettings {
  const opt = (name: string): string | undefined => { const value = args.values[name]; return typeof value === "string" ? value : undefined; };
  const bitsRaw = opt("trellis-bits") ?? "3", bits = Number(bitsRaw);
  if (!Number.isInteger(bits) || bits < 1 || bits > 8) throw new Error(`--trellis-bits must be an integer in [1, 8] (got "${bitsRaw}")`);
  const downAxis = opt("trellis-down-axis") ?? "out";
  if (downAxis !== "out" && downAxis !== "in") throw new Error(`--trellis-down-axis must be out or in (got "${downAxis}")`);
  const layersRaw = opt("trellis-layers"), layers = layersRaw !== undefined ? Number(layersRaw) : undefined;
  if (layers !== undefined && (!Number.isInteger(layers) || layers < 1)) throw new Error(`--trellis-layers expects a positive integer (got "${layersRaw}")`);
  const kMap = opt("trellis-k-map"), ldlq = opt("trellis-ldlq");
  if (kMap !== undefined && !existsSync(kMap)) throw new Error(`--trellis-k-map: ${kMap} does not exist`);
  if (ldlq !== undefined && !existsSync(ldlq)) throw new Error(`--trellis-ldlq: ${ldlq} does not exist`);
  if (opt("trellis-k-budget") !== undefined && kMap === undefined) throw new Error("--trellis-k-budget needs --trellis-k-map");
  const reuse = (opt("trellis-reuse")?.split(",").map((dir) => dir.trim()).filter(Boolean) ?? []);
  for (const dir of reuse) if (!existsSync(join(dir, "config.json"))) throw new Error(`--trellis-reuse: ${dir} is not a model directory`);
  return { bits, downAxis, ...(kMap ? { kMap: resolve(kMap) } : {}), kBudget: opt("trellis-k-budget") ?? "3.00",
    ...(ldlq ? { ldlq: resolve(ldlq) } : {}), reuse: reuse.map((dir) => resolve(dir)),
    interleave: args.values["trellis-interleave"] === true, ...(layers !== undefined ? { layers } : {}) };
}

/** mlx_lm.convert counterpart: main's flags, messages, and check order; the
 * output defaults to the app's models directory instead of `./mlx_model`.
 * Uniform affine 4/8-bit or the OptiQ mixed path via --target-bpw, or without
 * -q a dtype cast and/or dequantization (--dtype, -d), through the
 * same producer as the web quantize job in an owned child. Cancellation
 * terminates and joins that child; the atomic writer never publishes a partial
 * output and the parent removes the child's staging. */
export async function runConvert(args: ConvertArgs, deps: ConvertDependencies, signal?: AbortSignal): Promise<void> {
  const { terminal } = deps, { style } = terminal;
  const opt = (name: string): string | undefined => { const value = args.values[name]; return typeof value === "string" ? value : undefined; };
  const flag = (name: string) => args.values[name] === true;

  // The write token is resolved before any conversion work (mlx_lm.convert parity).
  const uploadRepo = opt("upload-repo");
  if (uploadRepo !== undefined) requireWriteToken(deps.catalog);
  if (opt("quant-predicate") !== undefined)
    throw new Error("--quant-predicate: not supported (mlx_lm's mixed_* recipes need 2/3/6-bit; for mixed precision use --target-bpw; see: mlx-bun help convert)");
  const qMode = opt("q-mode") ?? "affine";
  if (qMode !== "affine" && qMode !== "trellis") throw new Error(`--q-mode ${qMode}: only "affine" and "trellis" are supported`);
  const trellis = qMode === "trellis";
  for (const name of TRELLIS_OPTIONS)
    if (!trellis && args.values[name] !== undefined) throw new Error(`--${name} needs --q-mode trellis`);
  if (trellis)
    for (const name of ["target-bpw", "q-bits", "q-group-size", "dtype", "candidate-bits", "calibration-mix", "n-calibration"])
      if (args.values[name] !== undefined) throw new Error(`--${name} does not apply to --q-mode trellis (the packed tensors and their affine tiers are fixed)`);
  const hfPath = opt("hf-path") ?? opt("model") ?? args.positionals[0];
  if (!hfPath) throw new Error("usage: mlx-bun convert --hf-path <repo-or-path> [-q] [--q-bits N] [--q-group-size N] [--mlx-path <dir>] [--target-bpw F] [--dtype float16|bfloat16|float32] [-d]");
  const targetBpwRaw = opt("target-bpw");
  const targetBpw = targetBpwRaw !== undefined ? Number(targetBpwRaw) : undefined;
  if (targetBpw !== undefined && (!Number.isFinite(targetBpw) || targetBpw <= 0)) throw new Error(`--target-bpw expects a positive number (got "${targetBpwRaw}")`);
  const dtype = opt("dtype");
  if (dtype !== undefined && !CONVERT_DTYPES.includes(dtype))
    throw new Error(`--dtype must be ${CONVERT_DTYPES.join(", ")} (got "${dtype}")`);
  const dequantize = flag("dequantize");
  const quantizing = flag("quantize") || targetBpw !== undefined || trellis;
  if (quantizing && dequantize) throw new Error("Choose either quantize or dequantize, not both.");
  const qBits = Number(opt("q-bits") ?? "4");
  if (qBits !== 4 && qBits !== 8) throw new Error(`--q-bits must be 4 or 8 (got "${opt("q-bits")}")`);
  const qGroup = Number(opt("q-group-size") ?? "64");
  if (qGroup !== 32 && qGroup !== 64) throw new Error(`--q-group-size must be 32 or 64 (got "${opt("q-group-size")}")`);
  const candidateBits = opt("candidate-bits")?.split(",").map((item) => Number(item.trim()));
  if (candidateBits && candidateBits.some((bits) => !Number.isInteger(bits) || bits < 2 || bits > 8))
    throw new Error(`--candidate-bits expects a comma list of integers in [2, 8] (got "${opt("candidate-bits")}")`);
  const trellisSettings = trellis ? parseTrellisOptions(args) : undefined;
  const rotateWeights = flag("rotate-weights") || trellis;
  if (rotateWeights && !quantizing) throw new Error("--rotate-weights folds a rotation before quantization — pass -q or --target-bpw");
  const rotationSeed = Number(opt("rotation-seed") ?? "42");
  if (!Number.isInteger(rotationSeed)) throw new Error(`--rotation-seed expects an integer (got "${opt("rotation-seed")}")`);
  const refuseExisting = (path: string) => {
    if (existsSync(path)) throw new Error(`Cannot save to the path ${path} as it already exists — delete it or pass a fresh --mlx-path.`);
  };
  const explicitPath = opt("mlx-path");
  if (explicitPath !== undefined) refuseExisting(explicitPath);
  signal?.throwIfAborted();

  // Source: a local model directory as given; else a downloaded model through the
  // catalog; else an org/name repo id, downloaded first and then indexed.
  let srcDir = hfPath;
  if (!existsSync(join(hfPath, "config.json"))) {
    try { srcDir = (await deps.catalog.find(hfPath)).directory; }
    catch (error) {
      if (!REPO_ID.test(hfPath)) throw error;
      signal?.throwIfAborted();
      const download = terminal.step(`downloading ${hfPath}`);
      try {
        srcDir = (await deps.catalog.download(hfPath, { ...(signal ? { signal } : {}), onProgress: (file, received, total) => {
          const pct = total ? Math.floor((received / total) * 100) : 0;
          download.update(`${style.bold(hfPath)} ${style.dim(`· ${file} · ${gb(received)} / ${gb(total)} (${pct}%)`)}`);
        } })).directory;
      } catch (error) { download.fail(signal?.aborted ? "download cancelled" : "download failed"); throw error; }
      download.done(`${style.bold(hfPath)} ${style.dim("downloaded · verified")}`);
    }
  }

  // Default: `<models>/<model>-<bits>bit` (or `-mixed-<bpw>bpw`, `-rot<seed>`),
  // named from the resolved source so a catalog query names the real model.
  const mlxPath = explicitPath ?? join(deps.modelsDir(), quantizing
    ? quantizedModelName(srcDir, { bits: qBits, targetBpw,
      rotationSeed: rotateWeights && (!trellis || opt("rotation-seed") !== undefined) ? rotationSeed : undefined,
      ...(trellisSettings ? { trellis: { bits: trellisSettings.bits, mixed: trellisSettings.kMap !== undefined } } : {}) })
    : convertedModelName(srcDir, { dtype, dequantize }));
  if (explicitPath === undefined) refuseExisting(mlxPath);
  signal?.throwIfAborted();
  const converting = dtype !== undefined || dequantize ? `${dequantize ? "dequantizing" : "casting"}${dtype ? ` to ${dtype}` : ""}` : "copying";
  const working = terminal.step(!quantizing ? `converting (${converting})` : trellisSettings
    ? `quantizing (packed trellis, ${trellisSettings.kMap ? "per-tensor allocation" : `${trellisSettings.bits}-bit`} MLP — Viterbi encode, slow)` : targetBpw !== undefined
    ? `quantizing (mixed, target ${targetBpw} bpw — sensitivity sweep, ~minutes)` : `quantizing (${qBits}-bit, group ${qGroup})`);
  const config: Record<string, unknown> = !quantizing
    ? { src_dir: srcDir, out_dir: mlxPath, quantize: false, ...(dtype ? { dtype } : {}), ...(dequantize ? { dequantize: true } : {}) }
    : trellisSettings
    ? { src_dir: srcDir, out_dir: mlxPath, mode: "trellis", rotation_seed: rotationSeed, trellis_bits: trellisSettings.bits,
      trellis_down_axis: trellisSettings.downAxis,
      ...(trellisSettings.kMap ? { trellis_k_map: trellisSettings.kMap, trellis_k_budget: trellisSettings.kBudget } : {}),
      ...(trellisSettings.ldlq ? { trellis_ldlq: trellisSettings.ldlq } : {}),
      ...(trellisSettings.reuse.length ? { trellis_reuse: trellisSettings.reuse } : {}),
      ...(trellisSettings.interleave ? { trellis_interleave: true } : {}),
      ...(trellisSettings.layers !== undefined ? { trellis_layers: trellisSettings.layers } : {}) }
    : { src_dir: srcDir, out_dir: mlxPath, bits: qBits, group_size: qGroup, mode: "affine",
    ...(dtype ? { dtype } : {}),
    ...(targetBpw !== undefined ? { target_bpw: targetBpw } : {}),
    ...(candidateBits ? { candidate_bits: candidateBits } : {}),
    ...(opt("calibration-mix") ? { calibration_mix: opt("calibration-mix") } : {}),
    ...(opt("n-calibration") ? { n_calibration: Number(opt("n-calibration")) } : {}),
    ...(rotateWeights ? { rotate_weights: true, rotation_seed: rotationSeed } : {}) };
  let summary: string | undefined;
  const progress = (message: string) => { summary = message; working.update(message); };
  let outDir = mlxPath;
  try {
    const result = await deps.quantize(config, mlxPath, progress, signal);
    outDir = result.outputPath;
  } catch (error) { working.fail(signal?.aborted ? "convert cancelled" : "convert failed"); throw error; }
  working.done(summary ?? (quantizing ? "quantized" : "converted"));
  deps.log();
  terminal.box([
    `${style.green("●")} ${style.bold("convert complete")}`, "",
    `source    ${style.dim(srcDir)}`,
    `model     ${style.bold(outDir)}`,
    `${quantizing ? "quant    " : "convert  "} ${style.dim(!quantizing ? converting : trellisSettings
      ? `packed trellis ${trellisSettings.kMap ? "(per-tensor k-map)" : `${trellisSettings.bits}-bit`} MLP${trellisSettings.ldlq ? ", BlockLDLQ" : ""}`
      : targetBpw !== undefined ? `mixed (target ${targetBpw} bpw)` : `${qBits}-bit g${qGroup} affine`)}`,
    ...(rotateWeights ? [`transform ${style.dim(`TurboQuant rotation seed ${rotationSeed}`)}`] : []),
    "", `serve it   ${style.accent(`mlx-bun serve ${outDir}`)}`,
  ]);

  if (uploadRepo === undefined) return;
  await publishModel(deps, { repoId: uploadRepo, dir: outDir }, signal);
}

/** The write-token check `--upload-repo` runs before any work. */
function requireWriteToken(catalog: Pick<ModelCatalog, "canPublish">): void {
  if (!catalog.canPublish())
    throw new Error("--upload-repo needs a Hugging Face WRITE token and none was found —\n" +
      "run `hf auth login`, export HF_TOKEN, or save one in the web UI (Settings → Hugging Face).");
}

/** The push after a successful `convert`: an owned step, then, on failure, a
 * hint naming the retry command; the model on disk is complete either way. */
async function publishModel(deps: ConvertDependencies, request: { repoId: string; dir: string }, signal?: AbortSignal): Promise<void> {
  signal?.throwIfAborted();
  const { repoId, dir } = request, { style } = deps.terminal;
  const uploading = deps.terminal.step(`uploading ${dir} → ${repoId}`);
  let uploaded: { url: string };
  try { uploaded = await deps.catalog.publish(dir, { repoId, ...(signal ? { signal } : {}) }); }
  catch (error) {
    // The model is complete either way; only the push is undone or unfinished.
    const hint = `the converted model is intact at ${dir} — retry with: mlx-bun upload --path ${dir} --upload-repo ${repoId}`;
    if (signal?.aborted) { uploading.fail("upload cancelled"); deps.log(hint); throw signal.reason; }
    uploading.fail(`upload failed: ${message(error)}`);
    throw new Error(hint);
  }
  uploading.done(`uploaded ${style.bold(uploaded.url)}`);
}
