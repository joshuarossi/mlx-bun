// Perplexity of a model over a local text/JSONL dataset: main's `mlx-bun perplexity`
// verb (02d723a:src/cli.ts) as a runner over the published library. It reads
// in-process logits, which no HTTP surface exposes, so eval-serve cannot carry it;
// the methodology (mlx_lm.perplexity's) lives in @mlx-bun/inference/scoring.
//
//   bun scripts/perplexity.ts /abs/snapshot --data-path /abs/data.txt|.jsonl
//     [--sequence-length 512] [--num-samples 256] [--batch-size 8] [--seed 123] [--json]
//
// Same options, defaults and summary as main's verb; --json prints one
// full-precision record with provenance instead. See --help.
import { existsSync } from "node:fs";
import { join, resolve } from "node:path";
import { parseArgs } from "node:util";
import { machine } from "./bench-serve";
import { fileSha, sourceSnapshot } from "./bench/plan";

const TOOL_ROOT = resolve(import.meta.dir, "..");
const USAGE = `Perplexity of a model over a local text/JSONL dataset (main's \`mlx-bun perplexity\`).

  bun scripts/perplexity.ts <model-dir> --data-path <file.txt|file.jsonl> [--sequence-length 512]
      [--num-samples 256] [--batch-size 8] [--seed 123] [--json]

mlx_lm.perplexity methodology, exactly: samples are visited in a seeded random order, tokenized,
concatenated, and cut into NON-OVERLAPPING rows of --sequence-length tokens; per batch the model
scores rows[:, :-1] against rows[:, 1:] in f32 (every position counts); reported as
ppl = exp(mean CE) ± the delta-method standard error. The data source is a LOCAL file, never a
Hugging Face dataset download; the shuffle is seeded but not NumPy's, so rows are reproducible per
seed without matching the Python tool's sampling.

  <model-dir>            Model directory holding config.json (a snapshot path; --model is accepted)
  --data-path <file>     .jsonl ({"text": …} rows) or plain .txt  (required)
  --sequence-length <n>  Tokens per row  [default: 512]
  --num-samples <n>      Rows to score (-1 = all available)  [default: 256]
  --batch-size <n>       Rows per forward  [default: 8]
  --seed <n>             Sample-shuffle seed  [default: 123]
  --json                 Print one JSON record (full-precision results, inputs, provenance)

The MLX library resolves as @mlx-bun/mlx does (MLX_BUN_LIBMLXC, else the staged package).
Progress goes to stderr; the summary or the record to stdout.`;

export interface PerplexityOptions {
  model: string; dataPath: string; sequenceLength: number; numSamples: number; batchSize: number; seed: number; json: boolean;
}

/** Main's flags and validation; -1 (all rows) is accepted for --num-samples only. */
export function parseOptions(argv: string[]): PerplexityOptions {
  // Main took `--num-samples -1`; node's parseArgs reads a dash-led value only as `--num-samples=-1`.
  const args: string[] = [];
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i]!, next = argv[i + 1];
    if (/^--(sequence-length|num-samples|batch-size|seed)$/.test(arg) && next !== undefined && /^-\d/.test(next)) args.push(`${arg}=${next}`), i++;
    else args.push(arg);
  }
  const { values, positionals } = parseArgs({ args, strict: true, allowPositionals: true, options: {
    model: { type: "string" }, "data-path": { type: "string" }, "sequence-length": { type: "string", default: "512" },
    "num-samples": { type: "string", default: "256" }, "batch-size": { type: "string", default: "8" },
    seed: { type: "string", default: "123" }, json: { type: "boolean", default: false },
  } });
  const model = positionals[0] ?? values.model, dataPath = values["data-path"];
  if (!model || !dataPath) throw new Error("usage: bun scripts/perplexity.ts <model-dir> --data-path <file.txt|file.jsonl> [--sequence-length 512] [--num-samples 256] [--batch-size 8] [--seed 123] [--json]");
  const int = (name: "sequence-length" | "num-samples" | "batch-size" | "seed", lo: number) => {
    const v = Number(values[name]);
    if (!Number.isInteger(v) || (v < lo && !(name === "num-samples" && v === -1)))
      throw new Error(`--${name} expects an integer >= ${lo} (got "${values[name]}")`);
    return v;
  };
  return { model, dataPath, sequenceLength: int("sequence-length", 2), numSamples: int("num-samples", 1),
    batchSize: int("batch-size", 1), seed: int("seed", 0), json: values.json! };
}

const gb = (bytes: number) => `${(bytes / 2 ** 30).toFixed(2)} GB`;

async function main(argv: string[]): Promise<number> {
  if (argv.includes("--help") || argv.includes("-h")) { console.log(USAGE); return 0; }
  const o = parseOptions(argv);
  if (!existsSync(o.dataPath)) throw new Error(`data file not found: ${o.dataPath} (a local .txt or .jsonl — HF datasets are not downloaded)`);
  if (!existsSync(join(o.model, "config.json")))
    throw new Error(`model directory not found: ${o.model} (pass a snapshot directory holding config.json; registry queries are the app's)`);

  // The library dlopens MLX on import: load it only once the inputs are known good.
  const { loadModelConfig, Weights, createModel, loadTokenizer } = await import("@mlx-bun/inference");
  const { parseSamples, packRows, evalPpl } = await import("@mlx-bun/inference/scoring");
  const { LIBMLXC_PATH, MLX_VERSION, peakMemory, resetPeakMemory } = await import("@mlx-bun/mlx/ffi");
  const log = (line: string) => console.error(line);

  const config = await loadModelConfig(o.model);
  const { resolveModelProfile } = await import("@mlx-bun/inference/models/profile");
  // Colibri-container checkpoints (GLM-5.2) need the streamed runtime; scoring runs the
  // synchronous forward over createModel, as main's verb did, so refuse them before loading.
  if (resolveModelProfile(config).profile.execution.loader === "colibri")
    throw new Error(`${o.model} is a Colibri-container checkpoint (GLM-5.2); perplexity scores createModel graphs only`);
  log(`loading ${o.model}`);
  const model = createModel(await Weights.open(o.model), config);
  const tok = await loadTokenizer(o.model);
  const samples = parseSamples(await Bun.file(o.dataPath).text(), o.dataPath);
  const rows = packRows(samples.map(t => tok.encode(t)), { sequenceLength: o.sequenceLength, numSamples: o.numSamples, seed: o.seed });
  if (rows.length === 0) throw new Error(`dataset too small: fewer than ${o.sequenceLength} tokens (need at least one full row)`);
  log(`${rows.length} row(s) × ${o.sequenceLength} tokens · ${samples.length} sample(s), seed ${o.seed}`);

  resetPeakMemory();
  const t0 = performance.now();
  const r = evalPpl(model, rows, o.batchSize, (done, total) => log(`batch ${done}/${total}`));
  const seconds = (performance.now() - t0) / 1000, peak = peakMemory();
  log(`evaluated ${r.tokens.toLocaleString()} tokens in ${seconds.toFixed(1)} s`);

  if (o.json) {
    const { head, clean } = sourceSnapshot(TOOL_ROOT);
    console.log(JSON.stringify({
      schema: 1, command: ["bun", "scripts/perplexity.ts", ...argv], tool: { root: TOOL_ROOT, head, clean }, machine: machine(),
      mlx: { version: MLX_VERSION, library: LIBMLXC_PATH }, model: resolve(o.model),
      data: { path: resolve(o.dataPath), sha256: fileSha(o.dataPath), samples: samples.length },
      options: { sequenceLength: o.sequenceLength, numSamples: o.numSamples, batchSize: o.batchSize, seed: o.seed },
      result: r, seconds, peakMemoryBytes: peak,
    }, null, 1));
    return 0;
  }
  console.log([
    `perplexity · ${o.model.split("/snapshots/")[0]?.split("/").at(-1) ?? o.model}`,
    `ppl        ${r.ppl.toFixed(3)} ± ${r.standardError.toFixed(3)}`,
    `mean CE    ${r.meanLoss.toFixed(4)} nats/token`,
    `tokens     ${r.tokens.toLocaleString()} · ${r.rows} row(s) × ${o.sequenceLength}`,
    `speed      ${(r.tokens / seconds).toFixed(0)} tok/s · peak ${gb(peak)}`,
  ].join("\n"));
  return 0;
}

if (import.meta.main) main(process.argv.slice(2)).then(code => process.exit(code), error => { console.error(error instanceof Error ? error.message : String(error)); process.exit(1); });
