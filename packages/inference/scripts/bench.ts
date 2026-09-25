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
  if (!Number.isSafeInteger(vocabSize) || vocabSize <= 0 || !Array.isArray(value) || value.length === 0 ||
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

export function pairReports(runs: { tree: "main" | "branch"; report: any }[]) {
  assert(runs.length >= 4 && runs.length % 4 === 0, "supply complete main/branch/branch/main blocks");
  const first = runs[0]!.report;
  const baseline = (r: any) => ({ artifact: r.artifact, configSha256: r.configSha256,
    indexSha256: r.indexSha256, promptSha256: r.promptSha256, promptIds: r.promptIds,
    eosTokenIds: r.eosTokenIds, runtimeEnvironment: r.runtimeEnvironment, weightHashes: r.weightHashes,
    host: r.host, chip: r.chip, ramBytes: r.ramBytes,
    tokens: r.options?.tokens, samples: r.options?.samples, warmup: r.options?.warmup,
    prefillChunk: r.options?.prefillChunk, clearBeforeRequest: r.options?.clearBeforeRequest });
  let expectedTokens: number[] | undefined;
  let previousEnd = -Infinity;
  const commits = new Map<string, string>();
  const samples: Record<"main" | "branch", NativeBenchSample[]> = { main: [], branch: [] };
  for (let i = 0; i < runs.length; i++) {
    const { tree, report: r } = runs[i]!;
    assert.equal(tree, ["main", "branch", "branch", "main"][i % 4], "expected AB/BA process order");
    assert.equal(r.complete, true, "incomplete run");
    assert(typeof r.sourceCommit === "string" && /^[a-f0-9]{40}$/.test(r.sourceCommit), "missing source revision");
    assert.equal(r.dirty, false, "explicit clean source provenance required");
    if (commits.has(tree)) assert.equal(r.sourceCommit, commits.get(tree), "source changed between blocks");
    commits.set(tree, r.sourceCommit);
    for (const key of ["artifact", "configSha256", "promptSha256", "host", "chip"])
      assert(typeof r[key] === "string" && r[key].length > 0, `missing ${key}`);
    assert(Array.isArray(r.promptIds) && r.promptIds.length > 0 && Array.isArray(r.eosTokenIds), "missing prompt/EOS IDs");
    assert(r.runtimeEnvironment && typeof r.runtimeEnvironment === "object" && !Array.isArray(r.runtimeEnvironment), "runtime environment must be recorded");
    assert(r.weightHashes && Object.keys(r.weightHashes).length > 0 && Object.values(r.weightHashes).every(h => typeof h === "string" && /^[a-f0-9]{64}$/.test(h)), "full weight hashes required");
    assert.deepEqual(baseline(r), baseline(first), "pair configuration differs");
    assert(Number.isSafeInteger(r.options.samples) && r.options.samples > 0 && Number.isSafeInteger(r.options.warmup) && r.options.warmup >= 0, "invalid sample counts");
    assert(Array.isArray(r.samples) && r.samples.length === r.options.samples, "missing samples");
    assert(Array.isArray(r.warmups) && r.warmups.length === r.options.warmup, "missing warmups");
    for (const sample of [...r.warmups, ...r.samples]) {
      const start = Date.parse(sample.startedAt), end = Date.parse(sample.completedAt);
      assert(Number.isFinite(start) && Number.isFinite(end) && start >= previousEnd && end >= start,
        "measurement timestamps must establish sequential AB/BA order");
      previousEnd = end;
      assert(Array.isArray(sample.tokens) && sample.tokens.every((n: unknown) => typeof n === "number" && Number.isSafeInteger(n) && n >= 0), "invalid generated IDs");
      expectedTokens ??= sample.tokens;
      assert.deepEqual(sample.tokens, expectedTokens, "generated tokens differ; timing comparison refused");
      assert(sample.tokens.length <= r.options.tokens, "too many generated tokens");
      assert.equal(sample.finishReason, sample.tokens.length < r.options.tokens ? "stop" : "length", "invalid finish reason");
      for (const value of [sample.wallMs, sample.peakBytes, sample.memoryBefore?.activeBytes, sample.memoryBefore?.cacheBytes,
        sample.memoryAfter?.activeBytes, sample.memoryAfter?.cacheBytes, sample.engineTiming?.prefillMs, sample.engineTiming?.decodeMs])
        assert(typeof value === "number" && Number.isFinite(value) && value >= 0, "missing or invalid measurement");
      assert(sample.firstTokenMs === null && sample.tokens.length === 0 ||
        typeof sample.firstTokenMs === "number" && Number.isFinite(sample.firstTokenMs) && sample.firstTokenMs >= 0 && sample.firstTokenMs <= sample.wallMs, "invalid first-token latency");
      assert.equal(sample.engineTiming.generatedTokens, sample.tokens.length, "engine/token count mismatch");
      assert.equal(sample.engineTiming.cachedTokens, 0, "expected fresh request state");
    }
    samples[tree].push(...r.samples);
  }
  const distribution = (values: number[]) => {
    assert(values.length > 0, "empty measurement distribution");
    const ordered = [...values].sort((a, b) => a - b), mid = Math.floor(ordered.length / 2);
    return { median: ordered.length % 2 ? ordered[mid]! : (ordered[mid - 1]! + ordered[mid]!) / 2,
      min: ordered[0]!, max: ordered.at(-1)! };
  };
  return { order: runs.map(r => r.tree), machineStates: runs.map(({ tree, report }) => ({ tree, before: report.machineBefore, after: report.machineAfter })), sourceCommits: Object.fromEntries(commits), tokens: expectedTokens,
    trees: Object.fromEntries((["main", "branch"] as const).map(tree => [tree, {
      samples: samples[tree].length,
      wallMs: distribution(samples[tree].map(s => s.wallMs)),
      firstTokenMs: samples[tree].some(s => s.firstTokenMs === null) ? null : distribution(samples[tree].map(s => s.firstTokenMs!)),
      prefillMs: distribution(samples[tree].map(s => s.engineTiming!.prefillMs)),
      decodeMs: distribution(samples[tree].map(s => s.engineTiming!.decodeMs)),
      peakBytes: distribution(samples[tree].map(s => s.peakBytes)),
      activeAfterBytes: distribution(samples[tree].map(s => s.memoryAfter!.activeBytes)),
      cacheAfterBytes: distribution(samples[tree].map(s => s.memoryAfter!.cacheBytes)),
    }])) };
}

if (import.meta.main) {
  if (process.argv.includes("--help")) console.log(`Measure direct library generation with local weights (no downloads).
  bun packages/inference/scripts/bench.ts --model-path DIR --prompt-ids ids.json --json report.json
    [--tokens 64] [--samples 5] [--warmup 1] [--prefill-chunk 2048]
    [--clear-before-request] [--hash-weights]
Use bun --no-env-file for both trees to avoid project-local dotenv overrides.
Use the same frozen prompt IDs, artifact, EOS and runtime overrides for both trees.
Run processes sequentially in AB/BA order on a quiet machine with no training.
Keep every warmup and sample; inspect tokens before comparing timings. Reports are
external artifacts, never committed raw. Weight hashing streams files before timing.
No Python, server, native build or model download is started by this tool.
This is a library measurement, not an HTTP benchmark or automatic speed claim.
CPU-only comparison: bench.ts pair --main A1.json --branch B1.json --branch B2.json --main A2.json
Requires complete AB/BA blocks, matching artifact/weight hashes, prompt/EOS/options,
recorded runtime environment and machine, and identical tokens in every warmup and
sample. Retains order and reports median/min/max; never infers a regression threshold.
Legacy main reports must have their missing runtimeEnvironment, weightHashes and
explicit dirty:false recorded externally from the actual launch/source/artifact; retain the raw
report alongside that annotated copy. Do not invent unrecorded settings.`);
  else try {
    const args = process.argv.slice(2);
    if (args[0] === "pair") {
      const runs: { tree: "main" | "branch"; report: unknown }[] = [];
      for (let i = 1; i < args.length; i += 2) {
        const label = args[i];
        assert((label === "--main" || label === "--branch") && args[i + 1], "pair expects labeled report files");
        runs.push({ tree: label === "--main" ? "main" : "branch", report: await Bun.file(args[i + 1]!).json() });
      }
      console.log(JSON.stringify(pairReports(runs), null, 2));
    } else await benchmark(parseNativeBenchArgs(args));
  }
  catch (error) { console.error(error instanceof Error ? error.message : error); process.exitCode = 1; }
}
