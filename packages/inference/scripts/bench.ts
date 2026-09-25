/** Library generation measurement. Run paired processes sequentially; keep raw samples. */
import { strict as assert } from "node:assert";
import { createHash } from "node:crypto";
import { createReadStream } from "node:fs";
import { readdir } from "node:fs/promises";
import { dirname, join, resolve } from "node:path";
import { cpus, hostname, loadavg, totalmem } from "node:os";

export interface NativeBenchOptions {
  modelPath: string; promptIdsPath: string; jsonPath: string;
  tokens: number; samples: number; warmup: number; prefillChunk: number;
  clearBeforeRequest: boolean; hashWeights: boolean;
}

export function parseNativeBenchArgs(argv: string[]): NativeBenchOptions {
  const values = new Map<string, string>();
  const switches = new Set(["clear-before-request", "hash-weights"]);
  const names = new Set(["model-path", "prompt-ids", "json", "tokens", "samples", "warmup", "prefill-chunk"]);
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
  return { modelPath: required("model-path"), promptIdsPath: required("prompt-ids"), jsonPath: required("json"),
    tokens: integer("tokens", 64, 1, 4096), samples: integer("samples", 5, 1, 12),
    warmup: integer("warmup", 1, 0, 4), prefillChunk: integer("prefill-chunk", 2048, 1, 8192),
    hashWeights: values.has("hash-weights"),
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
  /** Wall-clock boundaries align external GPU/VM samples with timed work. */
  startedAt?: string; firstTokenAt?: string | null; completedAt?: string;
  engineTiming?: { prefillMs: number; decodeMs: number; cachedTokens: number; generatedTokens: number };
  finishReason: "stop" | "length"; peakBytes: number;
  memoryBefore?: { activeBytes: number; cacheBytes: number };
  memoryAfter?: { activeBytes: number; cacheBytes: number };
}

const sha = (value: string | Uint8Array) => createHash("sha256").update(value).digest("hex");
async function fileHash(path: string) {
  const digest = createHash("sha256");
  for await (const chunk of createReadStream(path)) digest.update(chunk);
  return digest.digest("hex");
}
function command(args: string[], cwd?: string) {
  const result = Bun.spawnSync(args, { cwd, stdout: "pipe", stderr: "pipe" });
  assert.equal(result.exitCode, 0, `${args[0]}: ${result.stderr.toString()}`);
  return result.stdout.toString().trim();
}
const machineState = () => ({ at: new Date().toISOString(), loadAverage: loadavg(),
  vm: command(["vm_stat"]), swap: command(["sysctl", "-n", "vm.swapusage"]) });

export async function benchmark(options: NativeBenchOptions): Promise<void> {
  const modelPath = resolve(options.modelPath), jsonPath = resolve(options.jsonPath);
  const promptBytes = await Bun.file(resolve(options.promptIdsPath)).bytes();
  const configBytes = await Bun.file(join(modelPath, "config.json")).bytes();
  const root = resolve(import.meta.dir, "../../..");
  const index = Bun.file(join(modelPath, "model.safetensors.index.json"));
  const weightHashes: Record<string, string> = {};
  if (options.hashWeights) for (const name of (await readdir(modelPath)).filter(n => n.endsWith(".safetensors")).sort())
    weightHashes[name] = await fileHash(join(modelPath, name));
  const [{ loadModelConfig, loadTokenizer, Weights, createModel, generate },
    { modelNeedsWiredLimit }, ffi, { gpuStream }] = await Promise.all([
    import("@mlx-bun/inference"), import("@mlx-bun/inference/generation"),
    import("@mlx-bun/mlx/ffi"), import("@mlx-bun/mlx/array"),
  ]);
  const config = await loadModelConfig(modelPath);
  const ids = validatePromptIds(JSON.parse(new TextDecoder().decode(promptBytes)), config.text.vocabSize);
  const tokenizer = await loadTokenizer(modelPath);
  if (tokenizer.eosTokenId != null && !config.eosTokenIds.includes(tokenizer.eosTokenId))
    config.eosTokenIds = [...config.eosTokenIds, tokenizer.eosTokenId];
  const nativeHashes: Record<string, string> = {};
  for (const name of ["libmlxc.dylib", "libmlx.dylib", "libjaccl.dylib", "mlx.metallib"])
    nativeHashes[name] = await fileHash(name === "libmlxc.dylib" ? ffi.LIBMLXC_PATH : join(dirname(ffi.LIBMLXC_PATH), name));
  const report = {
    schemaVersion: 1, kind: "library-generation", canonical: false, httpMeasurement: false,
    stack: "mlx-bun", artifact: modelPath, options, createdAt: new Date().toISOString(),
    host: hostname(), chip: cpus()[0]?.model, ramBytes: totalmem(), bun: Bun.version,
    macOS: command(["sw_vers", "-productVersion"]), osBuild: command(["sw_vers", "-buildVersion"]),
    configSha256: sha(configBytes), indexSha256: await index.exists() ? sha(await index.bytes()) : null,
    weightHashes: options.hashWeights ? weightHashes : null,
    sourceCommit: command(["git", "rev-parse", "HEAD"], root),
    dirty: command(["git", "status", "--porcelain"], root).length > 0,
    sourceDiffSha256: sha(command(["git", "diff", "HEAD", "--binary"], root)),
    harnessSha256: await fileHash(import.meta.filename),
    runtime: ffi.MLX_VERSION, nativeHashes, nativeLibrary: ffi.LIBMLXC_PATH,
    runtimeEnvironment: Object.fromEntries(Object.entries(process.env).filter(([k]) => /^(MLX_BUN_|MLX_RD_|MLX_MAX_|MLX_BFS_|MLX_METAL_)/.test(k)).sort()),
    promptIds: ids, promptSha256: sha(promptBytes), temperature: 0, eosTokenIds: config.eosTokenIds,
    machineBefore: machineState(), machineAfter: null as ReturnType<typeof machineState> | null,
    memoryPolicy: null as null | { wiring: string; wiredLimitBytes: number; clearBeforeRequest: boolean },
    warmups: [] as NativeBenchSample[], samples: [] as NativeBenchSample[], complete: false,
    error: undefined as string | undefined,
    note: "Fresh request state, greedy generation, configured plus tokenizer EOS. Warmups are separate and retained. Request wall time includes generation cleanup and queued GPU completion; model/tokenizer load and artifact hashing are outside timing. Engine timing is reported separately and is not HTTP throughput. No quiet-machine claim is made automatically.",
  };
  const save = async () => { await Bun.write(jsonPath, JSON.stringify(report, null, 2) + "\n"); };
  await save();
  try {
    const weights = await Weights.open(modelPath);
    try {
      const model = createModel(weights, config);
      report.memoryPolicy = { wiring: modelNeedsWiredLimit(model) ? "scoped-recommended" : "unchanged",
        wiredLimitBytes: ffi.maxRecommendedWorkingSetSize(), clearBeforeRequest: options.clearBeforeRequest };
      // This measured region preserves main's scripts/bench/native.ts sequence.
      const run = async (): Promise<NativeBenchSample> => {
        const memoryBefore = { activeBytes: ffi.activeMemory(), cacheBytes: ffi.cacheMemory() };
        ffi.resetPeakMemory(); const startedAt = new Date().toISOString(); const start = performance.now();
        if (options.clearBeforeRequest) ffi.clearCache();
        const tokens: number[] = []; let firstTokenMs: number | null = null; let firstTokenAt: string | null = null;
        const gen = generate(model, ids, { maxTokens: options.tokens, temperature: 0,
          prefillChunkSize: options.prefillChunk, eosTokenIds: config.eosTokenIds });
        for await (const t of gen) {
          if (firstTokenMs === null) { firstTokenMs = performance.now() - start; firstTokenAt = new Date().toISOString(); }
          tokens.push(t.token);
        }
        ffi.synchronize(gpuStream);
        const wallMs = performance.now() - start;
        const stats = gen.stats;
        return { wallMs, firstTokenMs, tokens, startedAt, firstTokenAt, completedAt: new Date().toISOString(),
          engineTiming: stats ? { prefillMs: stats.prefillMs, decodeMs: stats.decodeMs,
            cachedTokens: stats.cachedTokens, generatedTokens: stats.generatedTokens } : undefined,
          finishReason: tokens.length < options.tokens ? "stop" : "length", peakBytes: ffi.peakMemory(),
          memoryBefore, memoryAfter: { activeBytes: ffi.activeMemory(), cacheBytes: ffi.cacheMemory() } };
      };
      for (let i = 0; i < options.warmup; i++) { report.warmups.push(await run()); await save(); }
      for (let i = 0; i < options.samples; i++) { report.samples.push(await run()); await save(); }
    } finally { weights.dispose(); ffi.synchronize(gpuStream); ffi.clearCache(); }
    report.complete = true;
  } catch (error) { report.error = String(error); throw error; }
  finally { report.machineAfter = machineState(); await save(); }
  console.log(JSON.stringify({ report: jsonPath, complete: report.complete, samples: report.samples.length }));
}

if (import.meta.main) {
  if (process.argv.includes("--help")) console.log(`Measure direct library generation with local weights (no downloads).
  bun packages/inference/scripts/bench.ts --model-path DIR --prompt-ids ids.json --json report.json
    [--tokens 64] [--samples 5] [--warmup 1] [--prefill-chunk 2048]
    [--clear-before-request] [--hash-weights]
Use the same frozen prompt IDs, artifact, EOS and runtime overrides for both trees.
Run processes sequentially in AB/BA order on a quiet machine with no training.
Keep every warmup and sample; inspect tokens before comparing timings. Reports are
external artifacts, never committed raw. Weight hashing streams files before timing.
No Python, server, native build or model download is started by this tool.
This is a library measurement, not an HTTP benchmark or automatic speed claim.`);
  else try { await benchmark(parseNativeBenchArgs(process.argv.slice(2))); }
  catch (error) { console.error(error instanceof Error ? error.message : error); process.exitCode = 1; }
}
