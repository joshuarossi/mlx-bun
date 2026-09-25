import { existsSync, mkdtempSync, readdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { basename, dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { Registry } from "@mlx-bun/hub/registry";
import type { DownloadOptions } from "@mlx-bun/hub/download";
import { createHfCredentials } from "../publishing/credentials";
import type { PublishRequest } from "../publishing/upload";
import { parseCommand, type CommandArgs } from "./args";
import { box, step, style, type Step } from "./terminal";

type ModelRegistry = Pick<Registry, "resolve" | "list" | "scan" | "close">;
type Progress = NonNullable<DownloadOptions["onProgress"]>;
const gb = (bytes: number) => `${(bytes / 2 ** 30).toFixed(2)} GB`;
const REPO_ID = /^[\w.-]+\/[\w.-]+$/;
const message = (error: unknown) => (error instanceof Error ? error.message : String(error));

export interface ConvertDependencies {
  /** The web quantize job's producer, run as an owned child process with the
   * same snake_case config. The sensitivity sweep is synchronous, so only a
   * separate process keeps the parent responsive; cancellation terminates and
   * joins the child and discards its staging. */
  quantize(config: Record<string, unknown>, outDir: string, progress: (message: string) => void, signal?: AbortSignal,
    owner?: { spawn?: typeof Bun.spawn; entry?: string }): Promise<{ outputPath: string }>;
  /** Child creation and entry for the default producer owner; tests inject a slow or failing child. */
  spawn?: typeof Bun.spawn;
  entry?: string;
  download(repoId: string, options: { onProgress: Progress; signal?: AbortSignal }): Promise<string>;
  registry(): ModelRegistry;
  credentials(): Pick<ReturnType<typeof createHfCredentials>, "get">;
  publish(request: PublishRequest): Promise<{ url: string }>;
  step: (text: string) => Step;
  box: (lines: string[]) => void;
  log(line?: string): void;
}
/** Staging directories the atomic writer may leave beside the destination. */
function stagingSiblings(outDir: string): string[] {
  const destination = resolve(outDir), parent = dirname(destination), prefix = `.${basename(destination)}.tmp-`;
  return existsSync(parent) ? readdirSync(parent).filter(name => name.startsWith(prefix)).map(name => join(parent, name)) : [];
}

/** Run the quantize job in an owned child over a temporary job store: the
 * parent tails the job log for progress; an abort terminates and joins the
 * child, then removes any staging the child created. */
export async function quantizeInChild(config: Record<string, unknown>, outDir: string, progress: (message: string) => void,
  signal?: AbortSignal, owner: { spawn?: typeof Bun.spawn; entry?: string } = {}): Promise<{ outputPath: string }> {
  const [{ createJobHost }, { JobStore }, { tailJob }] = await Promise.all([import("../jobs/host"), import("../jobs/db"), import("../jobs/sse")]);
  const root = mkdtempSync(join(tmpdir(), "mlx-convert-job-"));
  const before = new Set(stagingSiblings(outDir));
  const jobs = createJobHost({ entry: owner.entry ?? fileURLToPath(new URL("./job-entry.ts", import.meta.url)),
    acquire: async () => ({ dispose() {} }), spawn: owner.spawn,
    createStore: () => new JobStore(join(root, "jobs.db"), join(root, "logs")) });
  const cancel = () => { void jobs.close().catch(() => {}); };
  try {
    signal?.throwIfAborted();
    const { jobId } = jobs.submit("quantize", config, outDir);
    signal?.addEventListener("abort", cancel, { once: true });
    const store = jobs.ensureStore();
    for await (const event of tailJob(store, jobId, { signal })) {
      if (event.type === "stage" && event.message) progress(event.message);
    }
    if (signal?.aborted) {
      await jobs.close();
      for (const dir of stagingSiblings(outDir)) if (!before.has(dir)) rmSync(dir, { recursive: true, force: true });
      throw signal.reason;
    }
    const row = store.get(jobId);
    if (!row || row.status !== "done") throw new Error(row?.error ?? `quantize job ${row?.status ?? "missing"}`);
    return { outputPath: row.output_path ?? outDir };
  } finally {
    signal?.removeEventListener("abort", cancel);
    try { await jobs.close(); } finally { rmSync(root, { recursive: true, force: true }); }
  }
}

const defaults: ConvertDependencies = {
  quantize: quantizeInChild,
  async download(repoId, { onProgress, signal }) {
    const { downloadModel } = await import("@mlx-bun/hub/download");
    // The hub download honors the signal at every checkpoint and keeps the
    // blob's .incomplete prefix resumable; nothing is published after an abort.
    return downloadModel(repoId, { onProgress, signal });
  },
  registry: () => new Registry(),
  credentials: () => createHfCredentials(),
  async publish(request) {
    const { createPublisher } = await import("../publishing/upload");
    return createPublisher({ credentials: createHfCredentials(), getJob: () => null })(request);
  },
  step, box, log: (line = "") => { console.log(line); },
};

/** Strict parsing would report a generic missing value; main names the expectation. */
export function parseConvertArgs(args: string[]): CommandArgs {
  const at = args.indexOf("--upload-repo");
  if (at !== -1 && (!args[at + 1] || args[at + 1]!.startsWith("-"))) throw new Error("--upload-repo expects a repo id (org/name)");
  return parseCommand("convert", args);
}

/** mlx_lm.convert counterpart: main's flags, defaults, messages, and check order.
 * Uniform affine 4/8-bit or the OptiQ mixed path via --target-bpw, through the
 * same producer as the web quantize job in an owned child. Cancellation
 * terminates and joins that child; the atomic writer never publishes a partial
 * output and the parent removes the child's staging. */
export async function runConvert(args: CommandArgs, supplied: Partial<ConvertDependencies> = {}, signal?: AbortSignal): Promise<void> {
  const deps = { ...defaults, ...supplied };
  const opt = (name: string): string | undefined => { const value = args.values[name]; return typeof value === "string" ? value : undefined; };
  const flag = (name: string) => args.values[name] === true;

  // The write token is resolved before any conversion work (mlx_lm.convert parity).
  const uploadRepo = opt("upload-repo");
  if (uploadRepo !== undefined && !deps.credentials().get())
    throw new Error("--upload-repo needs a Hugging Face WRITE token and none was found —\n" +
      "run `hf auth login`, export HF_TOKEN, or save one in the web UI (Settings → Hugging Face).");
  const unsupported = [opt("dtype") !== undefined && "--dtype", flag("dequantize") && "--dequantize",
    opt("quant-predicate") !== undefined && "--quant-predicate"].filter((name): name is string => typeof name === "string");
  if (unsupported.length > 0) throw new Error(`${unsupported.join(", ")}: not supported (mixed precision: --target-bpw; see: mlx-bun help convert)`);
  const qMode = opt("q-mode") ?? "affine";
  if (qMode !== "affine") throw new Error(`--q-mode ${qMode}: only "affine" is supported`);
  const hfPath = opt("hf-path") ?? opt("model") ?? args.positionals[0];
  if (!hfPath) throw new Error("usage: mlx-bun convert --hf-path <repo-or-path> -q [--q-bits N] [--q-group-size N] [--mlx-path <dir>] [--target-bpw F]");
  const targetBpwRaw = opt("target-bpw");
  if (!flag("quantize") && targetBpwRaw === undefined) throw new Error("plain (non-quantizing) conversion is not supported yet — pass -q or --target-bpw");
  const targetBpw = targetBpwRaw !== undefined ? Number(targetBpwRaw) : undefined;
  if (targetBpw !== undefined && (!Number.isFinite(targetBpw) || targetBpw <= 0)) throw new Error(`--target-bpw expects a positive number (got "${targetBpwRaw}")`);
  const qBits = Number(opt("q-bits") ?? "4");
  if (qBits !== 4 && qBits !== 8) throw new Error(`--q-bits must be 4 or 8 (got "${opt("q-bits")}")`);
  const qGroup = Number(opt("q-group-size") ?? "64");
  if (qGroup !== 32 && qGroup !== 64) throw new Error(`--q-group-size must be 32 or 64 (got "${opt("q-group-size")}")`);
  const candidateBits = opt("candidate-bits")?.split(",").map((item) => Number(item.trim()));
  if (candidateBits && candidateBits.some((bits) => !Number.isInteger(bits) || bits < 2 || bits > 8))
    throw new Error(`--candidate-bits expects a comma list of integers in [2, 8] (got "${opt("candidate-bits")}")`);
  const rotateWeights = flag("rotate-weights");
  const rotationSeed = Number(opt("rotation-seed") ?? "42");
  if (!Number.isInteger(rotationSeed)) throw new Error(`--rotation-seed expects an integer (got "${opt("rotation-seed")}")`);
  const mlxPath = opt("mlx-path") ?? "mlx_model";
  if (existsSync(mlxPath)) throw new Error(`Cannot save to the path ${mlxPath} as it already exists — delete it or pass a fresh --mlx-path.`);
  signal?.throwIfAborted();

  // Source: a local model directory as given; else a downloaded model through the
  // registry; else an org/name repo id, downloaded first and then re-indexed.
  let srcDir = hfPath;
  if (!existsSync(join(hfPath, "config.json"))) {
    const registry = deps.registry();
    try {
      if (registry.list().length === 0) await registry.scan();
      try { srcDir = registry.resolve(hfPath).path; }
      catch (error) {
        if (!REPO_ID.test(hfPath)) throw error;
        signal?.throwIfAborted();
        const download = deps.step(`downloading ${hfPath}`);
        try {
          srcDir = await deps.download(hfPath, { signal, onProgress: (file, received, total) => {
            const pct = total ? Math.floor((received / total) * 100) : 0;
            download.update(`${style.bold(hfPath)} ${style.dim(`· ${file} · ${gb(received)} / ${gb(total)} (${pct}%)`)}`);
          } });
        } catch (error) { download.fail(signal?.aborted ? "download cancelled" : "download failed"); throw error; }
        download.done(`${style.bold(hfPath)} ${style.dim("downloaded · verified")}`);
        await registry.scan();
      }
    } finally { registry.close(); }
  }

  signal?.throwIfAborted();
  const quantizing = deps.step(targetBpw !== undefined
    ? `quantizing (mixed, target ${targetBpw} bpw — sensitivity sweep, ~minutes)` : `quantizing (${qBits}-bit, group ${qGroup})`);
  const config: Record<string, unknown> = { src_dir: srcDir, out_dir: mlxPath, bits: qBits, group_size: qGroup, mode: "affine",
    ...(targetBpw !== undefined ? { target_bpw: targetBpw } : {}),
    ...(candidateBits ? { candidate_bits: candidateBits } : {}),
    ...(opt("calibration-mix") ? { calibration_mix: opt("calibration-mix") } : {}),
    ...(opt("n-calibration") ? { n_calibration: Number(opt("n-calibration")) } : {}),
    ...(rotateWeights ? { rotate_weights: true, rotation_seed: rotationSeed } : {}) };
  let summary: string | undefined;
  const progress = (message: string) => { summary = message; quantizing.update(message); };
  let outDir = mlxPath;
  try {
    const result = await deps.quantize(config, mlxPath, progress, signal, { spawn: deps.spawn, entry: deps.entry });
    outDir = result.outputPath;
  } catch (error) { quantizing.fail(signal?.aborted ? "convert cancelled" : "convert failed"); throw error; }
  quantizing.done(summary ?? "quantized");
  deps.log();
  deps.box([
    `${style.green("●")} ${style.bold("convert complete")}`, "",
    `source    ${style.dim(srcDir)}`,
    `model     ${style.bold(outDir)}`,
    `quant     ${style.dim(targetBpw !== undefined ? `mixed (target ${targetBpw} bpw)` : `${qBits}-bit g${qGroup} affine`)}`,
    ...(rotateWeights ? [`transform ${style.dim(`TurboQuant rotation seed ${rotationSeed}`)}`] : []),
    "", `serve it   ${style.accent(`mlx-bun serve ${outDir}`)}`,
  ]);

  if (uploadRepo === undefined) return;
  signal?.throwIfAborted();
  const uploading = deps.step(`uploading ${outDir} → ${uploadRepo}`);
  let uploaded: { url: string };
  try { uploaded = await deps.publish({ kind: "quantize", repoId: uploadRepo, sourcePath: outDir, signal }); }
  catch (error) {
    // The converted model is complete either way; only the push is undone or unfinished.
    const hint = `the converted model is intact at ${outDir} — retry with: mlx-bun upload --path ${outDir} --upload-repo ${uploadRepo}`;
    if (signal?.aborted) { uploading.fail("upload cancelled"); deps.log(hint); throw signal.reason; }
    uploading.fail(`upload failed: ${message(error)}`);
    throw new Error(hint);
  }
  uploading.done(`uploaded ${style.bold(uploaded.url)}`);
}
