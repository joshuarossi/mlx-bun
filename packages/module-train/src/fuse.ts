import { existsSync } from "node:fs";
import { join } from "node:path";
import type { CliInvocation, CliTerminal, ModelCatalog } from "@mlx-bun/app-core";
import type { fuseAdapter } from "@mlx-bun/training";
import { modelShortName } from "./model";
import { flag, opt, type VerbArgs } from "./train";

const REFUSED_FUSE_FLAGS = ["export-gguf", "gguf-path"];
const message = (error: unknown) => (error instanceof Error ? error.message : String(error));

export interface FuseDependencies {
  /** Resolves a query the way the catalog does (a model directory as given, else a downloaded model); the write token and the push behind `--upload-repo` are the catalog's too. */
  catalog: Pick<ModelCatalog, "find" | "canPublish" | "publish">;
  /** The `models` storage entry: where the default output goes. */
  modelsDir(): string;
  fuse: typeof fuseAdapter;
  exists(path: string): boolean;
  log(line: string): void;
  terminal: CliTerminal;
}
/** The dependencies a `fuse` run has in a host. */
export function fuseDependencies(services: { catalog: FuseDependencies["catalog"]; modelsDir(): string },
  invocation: Pick<CliInvocation, "terminal" | "stdout">): FuseDependencies {
  return { catalog: services.catalog, modelsDir: services.modelsDir, exists: existsSync, terminal: invocation.terminal,
    fuse: async (...call) => (await import("@mlx-bun/training")).fuseAdapter(...call),
    log: (line = "") => { invocation.stdout(line + "\n"); } };
}

/** The write-token check `--upload-repo` runs before any work. */
function requireWriteToken(catalog: Pick<ModelCatalog, "canPublish">): void {
  if (!catalog.canPublish())
    throw new Error("--upload-repo needs a Hugging Face WRITE token and none was found —\n" +
      "run `hf auth login`, export HF_TOKEN, or save one in the web UI (Settings → Hugging Face).");
}

/** The push after a successful `fuse`: an owned step, then, on failure, a
 * hint naming the retry command; the model on disk is complete either way. */
async function publishModel(deps: FuseDependencies, request: { repoId: string; dir: string }, signal?: AbortSignal): Promise<void> {
  signal?.throwIfAborted();
  const { repoId, dir } = request, { style } = deps.terminal;
  const uploading = deps.terminal.step(`uploading ${dir} → ${repoId}`);
  let uploaded: { url: string };
  try { uploaded = await deps.catalog.publish(dir, { repoId, ...(signal ? { signal } : {}) }); }
  catch (error) {
    // The model is complete either way; only the push is undone or unfinished.
    const hint = `the fused model is intact at ${dir} — retry with: mlx-bun upload --path ${dir} --upload-repo ${repoId}`;
    if (signal?.aborted) { uploading.fail("upload cancelled"); deps.log(hint); throw signal.reason; }
    uploading.fail(`upload failed: ${message(error)}`);
    throw new Error(hint);
  }
  uploading.done(`uploaded ${style.bold(uploaded.url)}`);
}

/** `fuse`: mlx_lm.fuse counterpart over the public training library
 * (`--dequantize` writes dense weights; `--upload-repo` pushes the result like
 * convert's). GGUF export is refused. The merge
 * itself has no cancellation seam: a signal is honored before it starts; one
 * arriving during the merge lets it finish so the output is never half-written. */
export async function runFuse(args: VerbArgs, deps: FuseDependencies, signal?: AbortSignal): Promise<void> {
  const { style } = deps.terminal;
  const unsupported = REFUSED_FUSE_FLAGS.filter(name => args.values[name] !== undefined).map(name => `--${name}`);
  if (unsupported.length > 0) throw new Error(`${unsupported.join(", ")}: not supported (GGUF export is not implemented; fuse writes safetensors; see: mlx-bun help fuse)`);
  // The write token is resolved before any fuse work, as convert does.
  const uploadRepo = opt(args, "upload-repo");
  if (uploadRepo !== undefined) requireWriteToken(deps.catalog);
  const modelArg = args.positionals[0] ?? opt(args, "model");
  if (!modelArg) throw new Error("usage: mlx-bun fuse <model-query-or-path> --adapter <dir> [--save-path <dir>]");
  const adapterDir = opt(args, "adapter") ?? opt(args, "adapter-path") ?? "adapters";
  if (!deps.exists(adapterDir)) throw new Error(`adapter dir not found: ${adapterDir}`);
  let modelDir = modelArg, modelId = modelArg;
  if (!deps.exists(`${modelArg}/config.json`)) {
    const entry = await deps.catalog.find(modelArg);
    modelDir = entry.directory; modelId = entry.id;
  }
  // An explicit --save-path keeps mlx_lm.fuse's semantics; the default is a
  // fresh directory in the app's models, never overwritten.
  let savePath = opt(args, "save-path");
  if (savePath === undefined) {
    savePath = join(deps.modelsDir(), `${modelShortName(modelId)}-fused`);
    if (deps.exists(savePath)) throw new Error(`${savePath} already exists — delete it or pass --save-path <dir>`);
  }
  signal?.throwIfAborted();
  const s = deps.terminal.step(`fusing ${adapterDir} into ${modelDir}`);
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
    deps.terminal.box([
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
    ]);
    if (interrupted) deps.log(`  ${style.dim("cancellation arrived during the merge; it cannot be interrupted, so the output was completed.")}`);
    fusedDir = stats.outDir;
  } catch (error) {
    s.fail(`fuse failed: ${error instanceof Error ? error.message : String(error)}`);
    throw error;
  } finally { signal?.removeEventListener("abort", onAbort); }
  // The push starts only for an uninterrupted run; a cancel that arrived mid-merge only completes the output.
  if (uploadRepo !== undefined && fusedDir !== undefined && !interrupted) await publishModel(deps, { repoId: uploadRepo, dir: fusedDir }, signal);
}
