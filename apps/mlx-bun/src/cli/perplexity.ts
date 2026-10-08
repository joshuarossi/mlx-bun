import { existsSync } from "node:fs";
import { join, resolve } from "node:path";
import type { CommandArgs } from "./args";
import { openRegistry } from "../storage/paths";
import pkg from "../../package.json" with { type: "json" };

// Main's `mlx-bun perplexity` (02d723a:src/cli.ts): mlx_lm.perplexity's method over
// a LOCAL dataset file (never a Hugging Face download), scored in process.

export const PERPLEXITY_USAGE = "usage: mlx-bun perplexity <model-query-or-path> --data-path <file.txt|file.jsonl> [--sequence-length 512] [--num-samples 256] [--batch-size 8] [--seed 123]";

export interface PerplexityOptions { model: string; dataPath: string; sequenceLength: number; numSamples: number; batchSize: number; seed: number; }

/** Main's flags, defaults and validation; -1 (all rows) is accepted for --num-samples only. */
export function perplexityOptions(parsed: CommandArgs): PerplexityOptions {
  const { values, positionals } = parsed;
  const model = positionals[0] ?? values.model ?? values.query, dataPath = values["data-path"];
  if (typeof model !== "string" || typeof dataPath !== "string") throw new Error(PERPLEXITY_USAGE);
  const int = (name: string, fallback: number, lo: number) => {
    const raw = values[name] === undefined ? String(fallback) : String(values[name]), v = Number(raw);
    if (!Number.isInteger(v) || (v < lo && !(name === "num-samples" && v === -1)))
      throw new Error(`--${name} expects an integer >= ${lo} (got "${raw}")`);
    return v;
  };
  return { model, dataPath, sequenceLength: int("sequence-length", 512, 2), numSamples: int("num-samples", 256, 1),
    batchSize: int("batch-size", 8, 1), seed: int("seed", 123, 0) };
}

const gb = (bytes: number) => `${(bytes / 2 ** 30).toFixed(2)} GB`;

export async function runPerplexity(parsed: CommandArgs): Promise<void> {
  const o = perplexityOptions(parsed);
  if (!existsSync(o.dataPath)) throw new Error(`data file not found: ${o.dataPath} (a local .txt or .jsonl — HF datasets are not downloaded)`);
  let modelDir = o.model;
  if (!existsSync(join(o.model, "config.json"))) {
    const reg = openRegistry();
    try {
      if (reg.list().length === 0) await reg.scan();
      modelDir = reg.resolve(o.model).path;
    } finally { reg.close(); }
  }
  modelDir = resolve(modelDir);

  const { banner, step, box, style } = await import("./terminal");
  banner(pkg.version);
  const sLoad = step(`loading ${modelDir}`);
  // The library dlopens MLX on import: load it only once the inputs are known good.
  const { loadModelConfig, Weights, createModel, loadTokenizer } = await import("@mlx-bun/inference");
  const { parseSamples, packRows, evalPpl } = await import("@mlx-bun/inference/scoring");
  const { resolveModelProfile } = await import("@mlx-bun/inference/models/profile");
  const { peakMemory, resetPeakMemory } = await import("@mlx-bun/mlx/ffi");
  const config = await loadModelConfig(modelDir);
  // Colibri-container checkpoints (GLM-5.2) need the streamed runtime; scoring runs the
  // synchronous forward over createModel, as main's verb did, so refuse them before loading.
  if (resolveModelProfile(config).profile.execution.loader === "colibri") {
    sLoad.fail("Colibri-container checkpoint");
    throw new Error(`${modelDir} is a Colibri-container checkpoint (GLM-5.2); perplexity scores createModel graphs only`);
  }
  const model = createModel(await Weights.open(modelDir), config);
  const tok = await loadTokenizer(modelDir);
  sLoad.done(`model loaded ${style.dim(`· ${modelDir}`)}`);

  const sData = step(`tokenizing ${o.dataPath}`);
  const samples = parseSamples(await Bun.file(o.dataPath).text(), o.dataPath);
  const rows = packRows(samples.map(t => tok.encode(t)), { sequenceLength: o.sequenceLength, numSamples: o.numSamples, seed: o.seed });
  if (rows.length === 0) {
    sData.fail(`dataset too small: fewer than ${o.sequenceLength} tokens (need at least one full row)`);
    throw new Error(`dataset too small: fewer than ${o.sequenceLength} tokens (need at least one full row)`);
  }
  sData.done(`${rows.length} row(s) × ${o.sequenceLength} tokens ${style.dim(`· ${samples.length} sample(s), seed ${o.seed}`)}`);

  const sEval = step(`evaluating (batch ${o.batchSize})`);
  resetPeakMemory();
  const t0 = performance.now();
  const r = evalPpl(model, rows, o.batchSize, (done, total) => sEval.update(`batch ${done}/${total}`));
  const seconds = (performance.now() - t0) / 1000;
  sEval.done(`evaluated ${r.tokens.toLocaleString()} tokens ${style.dim(`in ${seconds.toFixed(1)} s`)}`);
  console.log();
  box([
    `${style.green("●")} ${style.bold("perplexity")} ${style.dim(`· ${modelDir.split("/snapshots/")[0]?.split("/").at(-1) ?? modelDir}`)}`,
    "",
    `ppl        ${style.green(style.bold(r.ppl.toFixed(3)))} ${style.dim(`± ${r.standardError.toFixed(3)}`)}`,
    `mean CE    ${style.bold(r.meanLoss.toFixed(4))} ${style.dim("nats/token")}`,
    `tokens     ${style.bold(r.tokens.toLocaleString())} ${style.dim(`· ${r.rows} row(s) × ${o.sequenceLength}`)}`,
    `speed      ${style.dim(`${(r.tokens / seconds).toFixed(0)} tok/s · peak ${gb(peakMemory())}`)}`,
  ]);
}
