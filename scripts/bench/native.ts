#!/usr/bin/env bun
// Qwen native inference worker. Use the same frozen prompt-ID file for both
// stacks, run processes sequentially in AB/BA blocks, and retain every sample.
// Canonical serving numbers still come from bench-serve on a quiet machine.
import { createHash } from "node:crypto";
import { existsSync, mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { hostname, totalmem } from "node:os";
import { checkMachine } from "../../src/preflight";
import { ORACLE_VENV } from "../../tests/support/paths";
import { inventoryModel } from "./model-inventory";

export interface NativeBenchOptions {
  modelPath: string; promptIdsPath: string; jsonPath: string;
  stack: "mlx-bun" | "mlx-lm";
  tokens: number; samples: number; warmup: number; prefillChunk: number;
  diagnostic: boolean; dryRun: boolean; clearBeforeRequest: boolean;
}

export function parseNativeBenchArgs(argv: string[]): NativeBenchOptions {
  const values = new Map<string, string>();
  const switches = new Set(["diagnostic", "dry-run", "clear-before-request"]);
  const names = new Set(["model-path", "prompt-ids", "json", "stack", "tokens", "samples", "warmup", "prefill-chunk"]);
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i]!;
    if (!arg.startsWith("--")) throw new Error(`unexpected argument: ${arg}`);
    const key = arg.slice(2);
    if (values.has(key)) throw new Error(`duplicate --${key}`);
    if (switches.has(key)) values.set(key, "1");
    else if (names.has(key) && argv[i + 1] && !argv[i + 1]!.startsWith("--"))
      values.set(key, argv[++i]!);
    else throw new Error(`unknown option or missing value: ${arg}`);
  }
  const required = (key: string) => {
    const v = values.get(key); if (!v) throw new Error(`--${key} is required`); return v;
  };
  const integer = (key: string, fallback: number, min: number, max: number) => {
    const n = Number(values.get(key) ?? fallback);
    if (!Number.isInteger(n) || n < min || n > max) throw new Error(`--${key} must be ${min}..${max}`);
    return n;
  };
  const stack = values.get("stack") ?? "mlx-bun";
  if (stack !== "mlx-bun" && stack !== "mlx-lm") throw new Error("--stack must be mlx-bun or mlx-lm");
  return { modelPath: required("model-path"), promptIdsPath: required("prompt-ids"), jsonPath: required("json"), stack,
    tokens: integer("tokens", 64, 1, 4096), samples: integer("samples", 5, 1, 12),
    warmup: integer("warmup", 1, 0, 4), prefillChunk: integer("prefill-chunk", 2048, 1, 8192),
    diagnostic: values.has("diagnostic"), dryRun: values.has("dry-run"),
    clearBeforeRequest: values.has("clear-before-request") };
}

export function validatePromptIds(value: unknown, vocabSize: number): number[] {
  if (!Array.isArray(value) || value.length === 0 ||
      value.some((v) => !Number.isInteger(v) || v < 0 || v >= vocabSize))
    throw new Error("prompt file must contain a nonempty JSON array of in-vocabulary token IDs");
  return value as number[];
}

export interface NativeBenchSample {
  wallMs: number; firstTokenMs: number | null; tokens: number[];
  finishReason: "stop" | "length"; peakBytes: number;
  memoryBefore?: { activeBytes: number; cacheBytes: number };
  memoryAfter?: { activeBytes: number; cacheBytes: number };
}

async function main(options: NativeBenchOptions): Promise<void> {
  const modelPath = resolve(options.modelPath), jsonPath = resolve(options.jsonPath);
  if (!existsSync(`${modelPath}/config.json`)) throw new Error(`missing local model: ${modelPath}`);
  const inv = inventoryModel(modelPath);
  if (!String(inv.architecture.model_type).startsWith("qwen3_5"))
    throw new Error("this worker requires a dense Qwen3.5/3.8 artifact");
  if (options.stack === "mlx-lm" && inv.projectionGroups.some((g) => g.mode === "trellis"))
    throw new Error("stock mlx-lm cannot execute this packed trellis artifact; select an affine control");
  if (inv.fileBytes > totalmem()) throw new Error("artifact exceeds physical RAM; use a larger machine");
  const promptBytes = await Bun.file(resolve(options.promptIdsPath)).bytes();
  const ids = validatePromptIds(JSON.parse(new TextDecoder().decode(promptBytes)), Number(inv.architecture.vocab_size));
  const sha = (data: Uint8Array) => createHash("sha256").update(data).digest("hex");
  const command = (args: string[]) => Bun.spawnSync(args, { stdout: "pipe", stderr: "pipe" }).stdout.toString().trim();
  const codePaths = ["src/generate.ts", "src/model/qwen3_5.ts", "src/model/qwen3-delta.ts",
    "src/model/trellis-linear.ts", "src/model/trellis-shared-m.ts", "src/model/trellis-balanced-scatter.ts",
    "src/model/trellis-shared-scatter.ts", "src/model/trellis-tiled-prefill.ts", "src/model/trellis-splitk-prefill.ts",
    "src/model/qwen-conv.ts", "src/mlx/materialize.ts", "src/mlx/token-bitmask.ts",
    "src/mlx/array.ts", "src/mlx/ops.ts", "src/mlx/ffi.ts"];
  const sourceFiles = Object.fromEntries(await Promise.all(codePaths.map(async (p) => [p, sha(await Bun.file(p).bytes())])));
  const machineBefore = checkMachine();
  const report: Record<string, unknown> = { schemaVersion: 1, kind: "native-inference-diagnostic", canonical: false,
    httpMeasurement: false, stack: options.stack, artifact: modelPath, options,
    host: hostname(), chip: command(["sysctl", "-n", "machdep.cpu.brand_string"]), ramBytes: totalmem(),
    configSha256: inv.configSha256, indexSha256: inv.indexSha256, weightFiles: inv.files,
    identityNote: inv.identityNote, sourceCommit: command(["git", "rev-parse", "HEAD"]),
    sourceDiffSha256: sha(new TextEncoder().encode(command(["git", "diff", "HEAD", "--", "src"]))),
    sourceFiles, harnessSha256: sha(await Bun.file(import.meta.path).bytes()),
    variant: process.env.MLX_BUN_TRELLIS_VARIANT ?? "6", promptIds: ids, promptSha256: sha(promptBytes),
    kv: "bf16 attention plus f32 recurrent state", temperature: 0, machineBefore,
    note: "Fresh cache per request. Warmups are separate and retained. Wall time includes cache cleanup and completion of queued GPU work. Both stacks stop on configured and tokenizer EOS. Exact token IDs and whole-request wall time are the comparison; these are not HTTP rates or task-quality scores." };
  if (options.dryRun) { console.log(JSON.stringify({ ...report, measurement: false }, null, 2)); return; }
  if (!machineBefore.ok && !options.diagnostic)
    throw new Error(`machine not quiet; --diagnostic records a noncanonical run: ${machineBefore.problems.join("; ")}`);
  mkdirSync(dirname(jsonPath), { recursive: true });
  const save = async () => Bun.write(jsonPath, JSON.stringify(report, null, 2) + "\n");
  await save();
  try {
    if (options.stack === "mlx-lm") {
      const workerPath = new URL("../oracle/bench-native.py", import.meta.url).pathname;
      const workerOutput = `${jsonPath}.oracle.json`;
      const args = [`${ORACLE_VENV}/bin/python`, workerPath, "--model-path", modelPath,
        "--prompt-ids", resolve(options.promptIdsPath), "--json", workerOutput,
        "--tokens", String(options.tokens), "--samples", String(options.samples),
        "--warmup", String(options.warmup), "--prefill-chunk", String(options.prefillChunk)];
      if (options.clearBeforeRequest) args.push("--clear-before-request");
      report.workerCommand = args;
      report.workerSha256 = sha(await Bun.file(workerPath).bytes());
      const child = Bun.spawn(args, { stdout: "pipe", stderr: "pipe", env: { ...process.env, HF_HUB_OFFLINE: "1" } });
      const [stdout, stderr, code] = await Promise.all([new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited]);
      report.workerStdout = stdout; report.workerStderr = stderr;
      if (await Bun.file(workerOutput).exists()) Object.assign(report, await Bun.file(workerOutput).json());
      if (code !== 0) throw new Error(`pinned oracle exited ${code}: ${stderr.slice(-2000)}`);
    } else {
      const { loadModelConfig } = await import("../../src/config");
      const { loadTokenizer } = await import("../../src/tokenizer");
      const { Weights } = await import("../../src/weights");
      const { createModel } = await import("../../src/model/factory");
      const { generate, modelNeedsWiredLimit } = await import("../../src/generate");
      const { clearCache, activeMemory, cacheMemory, peakMemory, resetPeakMemory,
        maxRecommendedWorkingSetSize, synchronize, LIBMLXC_PATH } = await import("../../src/mlx/ffi");
      const { gpuStream } = await import("../../src/mlx/array");
      const config = await loadModelConfig(modelPath), tokenizer = await loadTokenizer(modelPath);
      if (tokenizer.eosTokenId != null && !config.eosTokenIds.includes(tokenizer.eosTokenId))
        config.eosTokenIds = [...config.eosTokenIds, tokenizer.eosTokenId];
      report.eosTokenIds = config.eosTokenIds;
      report.nativeLibrary = { path: LIBMLXC_PATH, sha256: sha(await Bun.file(LIBMLXC_PATH).bytes()), dependencies: command(["otool", "-L", LIBMLXC_PATH]) };
      const weights = await Weights.open(modelPath);
      try {
        const model = createModel(weights, config);
        report.memoryPolicy = { wiring: modelNeedsWiredLimit(model) ? "scoped-recommended" : "unchanged",
          wiredLimitBytes: maxRecommendedWorkingSetSize(), clearBeforeRequest: options.clearBeforeRequest,
          note: "Uses the engine's model-sized request wiring policy. Optional allocator cleanup is timed." };
        const warmups: NativeBenchSample[] = [], samples: NativeBenchSample[] = [];
        report.warmups = warmups; report.samples = samples;
        const run = async (): Promise<NativeBenchSample> => {
          const memoryBefore = { activeBytes: activeMemory(), cacheBytes: cacheMemory() };
          resetPeakMemory(); const start = performance.now();
          if (options.clearBeforeRequest) clearCache();
          const tokens: number[] = []; let firstTokenMs: number | null = null;
          const gen = generate(model, ids, { maxTokens: options.tokens, temperature: 0,
            prefillChunkSize: options.prefillChunk, eosTokenIds: config.eosTokenIds });
          for await (const t of gen) { firstTokenMs ??= performance.now() - start; tokens.push(t.token); }
          synchronize(gpuStream);
          const wallMs = performance.now() - start;
          return { wallMs, firstTokenMs, tokens,
            finishReason: tokens.length < options.tokens ? "stop" : "length", peakBytes: peakMemory(),
            memoryBefore, memoryAfter: { activeBytes: activeMemory(), cacheBytes: cacheMemory() } };
        };
        for (let i = 0; i < options.warmup; i++) { warmups.push(await run()); await save(); }
        for (let i = 0; i < options.samples; i++) { samples.push(await run()); await save(); }
      } finally { weights.dispose(); clearCache(); }
    }
    report.complete = true;
  } catch (error) {
    report.complete = false; report.error = String(error); throw error;
  } finally { report.machineAfter = checkMachine(); await save(); }
  console.log(JSON.stringify({ report: jsonPath, stack: options.stack, complete: report.complete }));
}

if (import.meta.main) {
  if (process.argv.includes("--help")) {
    console.log("bun scripts/bench/native.ts --model-path <dir> --prompt-ids <ids.json> --json <report.json> [--stack mlx-bun|mlx-lm] [--tokens 64] [--samples 5] [--warmup 1] [--prefill-chunk 2048] [--clear-before-request] [--diagnostic] [--dry-run]");
  } else await main(parseNativeBenchArgs(process.argv.slice(2)));
}
