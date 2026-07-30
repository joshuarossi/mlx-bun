#!/usr/bin/env bun

/**
 * Quiet-machine mlx-bun half of the Colibri G1/G3 kernel matrix.
 *
 * This is a component benchmark, not a model run:
 *   - production Q4 dense GEMM (M=1 and M=32);
 *   - routed expert SwiGLU decode (stock MLX vs direct-slot custom Metal);
 *   - stock routed expert prefill/ragged plans, with the M=1 Metal candidate
 *     explicitly reported as unsupported/falling back;
 *   - production-shape absorbed MLA decode through stock MLX.
 *
 * Every candidate passes a deterministic correctness check before timing.
 * Timed samples are warm, synchronized, and include allocator snapshots.
 */

import { existsSync, mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { loadavg } from "node:os";
import { MlxArray, gpuStream } from "../src/mlx/array";
import {
  activeMemory,
  cacheMemory,
  clearCache,
  peakMemory,
  resetPeakMemory,
  setMemoryLimit,
  synchronize,
} from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { loadGlm52Config } from "../src/model/glm52-config";
import { Glm52Mla } from "../src/model/glm52-mla";
import type {
  Glm52MoeBatchPlan,
  Glm52MoeExpertJob,
  Glm52MoeBatchWave,
} from "../src/model/glm52-moe";
import { Glm52ExpertRuntime } from "../src/model/glm52-residency";
import { ColibriGlm52Weights } from "../src/model/glm52-weights";
import type { Glm52Route } from "../src/model/glm52-reference";

const GiB = 1024 ** 3;
const LAYER = 3;
const DECODE_EXPERTS = 8;
const PREFILL_ROWS = 32;
const PREFILL_EXPERTS = 64;
const RAGGED_ROWS = 11;
const RAGGED_EXPERTS = 23;

interface Cli {
  readonly model: string;
  readonly library: string;
  readonly output: string;
  readonly warmups: number;
  readonly samples: number;
  readonly context: number;
  readonly workers: number;
  readonly allocatorLimitBytes: number;
}

interface Comparison {
  readonly elements: number;
  readonly maxAbs: number;
  readonly meanAbs: number;
  readonly rmse: number;
  readonly relativeRmse: number;
  readonly cosine: number;
  readonly expectedRms: number;
}

interface AllocatorSnapshot {
  readonly activeBytes: number;
  readonly cacheBytes: number;
  readonly peakBytes: number;
  readonly rssBytes: number;
  readonly physicalFootprintBytes: number | null;
}

interface TimedResult {
  readonly warmups: number;
  readonly samplesMs: readonly number[];
  readonly medianMs: number;
  readonly minMs: number;
  readonly maxMs: number;
  readonly rows: number;
  readonly rowsPerSecond: number;
  readonly allocatorBefore: AllocatorSnapshot;
  readonly allocatorAfter: AllocatorSnapshot;
}

type OutputFactory = () => MlxArray | Promise<MlxArray>;

function positiveInteger(value: string | undefined, name: string): number {
  const parsed = Number(value);
  if (!Number.isSafeInteger(parsed) || parsed <= 0)
    throw new Error(`${name} must be a positive integer`);
  return parsed;
}

function positiveNumber(value: string | undefined, name: string): number {
  const parsed = Number(value);
  if (!Number.isFinite(parsed) || parsed <= 0)
    throw new Error(`${name} must be positive`);
  return parsed;
}

function parseCli(argv: readonly string[]): Cli {
  const values = new Map<string, string>();
  for (let index = 0; index < argv.length; index += 2) {
    const key = argv[index];
    const value = argv[index + 1];
    if (!key?.startsWith("--") || value === undefined) {
      throw new Error(
        "usage: bench-colibri-glm52-kernels.ts " +
        "--model DIR --library DYLIB --output FILE --confirm-quiet yes " +
        "[--warmups 2] [--samples 7] [--context 129] [--workers 2] " +
        "[--allocator-limit-gib 4]",
      );
    }
    values.set(key.slice(2), value);
  }
  if (values.get("confirm-quiet") !== "yes") {
    throw new Error(
      "quiet benchmark refused: close unrelated applications and pass " +
      "--confirm-quiet yes",
    );
  }
  const required = (name: string): string => {
    const value = values.get(name);
    if (!value) throw new Error(`missing --${name}`);
    return resolve(value);
  };
  return {
    model: required("model"),
    library: required("library"),
    output: required("output"),
    warmups: positiveInteger(values.get("warmups") ?? "2", "warmups"),
    samples: positiveInteger(values.get("samples") ?? "7", "samples"),
    context: positiveInteger(values.get("context") ?? "129", "context"),
    workers: positiveInteger(values.get("workers") ?? "2", "workers"),
    allocatorLimitBytes:
      positiveNumber(
        values.get("allocator-limit-gib") ?? "4",
        "allocator-limit-gib",
      ) * GiB,
  };
}

function commandOutput(command: readonly string[]): string {
  const result = Bun.spawnSync([...command], {
    stdout: "pipe",
    stderr: "pipe",
  });
  if (result.exitCode !== 0) return "unavailable";
  return new TextDecoder().decode(result.stdout).trim();
}

function swapUsage(): string {
  return commandOutput(["/usr/sbin/sysctl", "-n", "vm.swapusage"]);
}

function allocatorSnapshot(
  runtime: Glm52ExpertRuntime | null = null,
): AllocatorSnapshot {
  return {
    activeBytes: activeMemory(),
    cacheBytes: cacheMemory(),
    peakBytes: peakMemory(),
    rssBytes: process.memoryUsage().rss,
    physicalFootprintBytes:
      runtime?.store.physicalFootprint() ?? null,
  };
}

function median(values: readonly number[]): number {
  if (values.length === 0) throw new Error("median requires samples");
  const sorted = [...values].sort((left, right) => left - right);
  const middle = Math.floor(sorted.length / 2);
  return sorted.length % 2 === 1
    ? sorted[middle]!
    : (sorted[middle - 1]! + sorted[middle]!) / 2;
}

function deterministicF32(length: number, seed: number): Float32Array {
  const values = new Float32Array(length);
  let state = seed >>> 0;
  for (let index = 0; index < length; index++) {
    state = (Math.imul(state, 1664525) + 1013904223) >>> 0;
    values[index] = ((state / 0xffffffff) * 2 - 1) * 0.125;
  }
  return values;
}

function inputArray(rows: number, hidden: number, seed: number): MlxArray {
  return MlxArray.fromFloat32(
    deterministicF32(rows * hidden, seed),
    [1, rows, hidden],
  );
}

function comparison(
  actual: Float32Array,
  expected: Float32Array,
): Comparison {
  if (actual.length !== expected.length)
    throw new Error(`comparison length ${actual.length} != ${expected.length}`);
  let maxAbs = 0;
  let sumAbs = 0;
  let sumSquareDelta = 0;
  let dot = 0;
  let actualSquares = 0;
  let expectedSquares = 0;
  for (let index = 0; index < actual.length; index++) {
    const left = actual[index]!;
    const right = expected[index]!;
    if (!Number.isFinite(left) || !Number.isFinite(right))
      throw new Error(`non-finite correctness value at ${index}`);
    const delta = left - right;
    maxAbs = Math.max(maxAbs, Math.abs(delta));
    sumAbs += Math.abs(delta);
    sumSquareDelta += delta * delta;
    dot += left * right;
    actualSquares += left * left;
    expectedSquares += right * right;
  }
  const expectedRms = Math.sqrt(expectedSquares / expected.length);
  const rmse = Math.sqrt(sumSquareDelta / expected.length);
  return {
    elements: actual.length,
    maxAbs,
    meanAbs: sumAbs / actual.length,
    rmse,
    relativeRmse: rmse / Math.max(expectedRms, 1e-12),
    cosine: dot / Math.sqrt(actualSquares * expectedSquares),
    expectedRms,
  };
}

function requireCorrect(
  label: string,
  result: Comparison,
  limits: {
    readonly relativeRmse: number;
    readonly cosine: number;
    readonly normalizedMaxAbs: number;
  },
): void {
  const normalizedMaxAbs =
    result.maxAbs / Math.max(result.expectedRms, 1e-12);
  if (
    result.relativeRmse > limits.relativeRmse ||
    result.cosine < limits.cosine ||
    normalizedMaxAbs > limits.normalizedMaxAbs
  ) {
    throw new Error(
      `${label} correctness failed: ${JSON.stringify({
        ...result,
        normalizedMaxAbs,
        limits,
      })}`,
    );
  }
}

async function hostOutput(factory: OutputFactory): Promise<Float32Array> {
  const output = await factory();
  try {
    const values = output.toFloat32();
    synchronize(gpuStream);
    return values;
  } finally {
    output.dispose();
  }
}

async function benchmark(
  label: string,
  rows: number,
  cli: Cli,
  factory: OutputFactory,
  runtime: Glm52ExpertRuntime | null = null,
): Promise<TimedResult> {
  synchronize(gpuStream);
  clearCache();
  for (let warmup = 0; warmup < cli.warmups; warmup++) {
    const output = await factory();
    ops.evalAll([output]);
    synchronize(gpuStream);
    output.dispose();
  }
  synchronize(gpuStream);
  resetPeakMemory();
  const allocatorBefore = allocatorSnapshot(runtime);
  const samplesMs: number[] = [];
  for (let sample = 0; sample < cli.samples; sample++) {
    const started = Bun.nanoseconds();
    const output = await factory();
    ops.evalAll([output]);
    synchronize(gpuStream);
    const elapsedMs = (Bun.nanoseconds() - started) / 1e6;
    output.dispose();
    samplesMs.push(elapsedMs);
  }
  synchronize(gpuStream);
  const allocatorAfter = allocatorSnapshot(runtime);
  const medianMs = median(samplesMs);
  console.log(
    `${label}: median ${medianMs.toFixed(3)} ms ` +
    `(${(rows * 1000 / medianMs).toFixed(2)} rows/s)`,
  );
  return {
    warmups: cli.warmups,
    samplesMs,
    medianMs,
    minMs: Math.min(...samplesMs),
    maxMs: Math.max(...samplesMs),
    rows,
    rowsPerSecond: rows * 1000 / medianMs,
    allocatorBefore,
    allocatorAfter,
  };
}

function routeForRow(
  row: number,
  uniqueExperts: number,
): Glm52Route {
  const indices: number[] = [];
  const executionWeights = new Float32Array(DECODE_EXPERTS);
  let sum = 0;
  for (let rank = 0; rank < DECODE_EXPERTS; rank++) {
    let expert = (row * 17 + rank * 7) % uniqueExperts;
    while (indices.includes(expert))
      expert = (expert + 1) % uniqueExperts;
    indices.push(expert);
    executionWeights[rank] = rank + 1;
    sum += rank + 1;
  }
  for (let rank = 0; rank < executionWeights.length; rank++)
    executionWeights[rank] = Math.fround(executionWeights[rank]! / sum);
  return {
    rawSigmoidScores: new Float32Array(0),
    selectionScores: new Float32Array(0),
    indices,
    executionWeights,
  };
}

function routedPlan(
  rows: number,
  uniqueExperts: number,
  waveSize: number,
): Glm52MoeBatchPlan {
  const routes = Array.from(
    { length: rows },
    (_, row) => routeForRow(row, uniqueExperts),
  );
  const builders = new Map<number, {
    rows: number[];
    ranks: number[];
    weights: number[];
  }>();
  const order: number[] = [];
  for (let row = 0; row < routes.length; row++) {
    const route = routes[row]!;
    for (let rank = 0; rank < route.indices.length; rank++) {
      const expertId = route.indices[rank]!;
      let builder = builders.get(expertId);
      if (!builder) {
        builder = { rows: [], ranks: [], weights: [] };
        builders.set(expertId, builder);
        order.push(expertId);
      }
      builder.rows.push(row);
      builder.ranks.push(rank);
      builder.weights.push(route.executionWeights[rank]!);
    }
  }
  const jobs: Glm52MoeExpertJob[] = order.map((expertId) => {
    const builder = builders.get(expertId)!;
    return {
      expertId,
      rows: Int32Array.from(builder.rows),
      ranks: Int32Array.from(builder.ranks),
      weights: Float32Array.from(builder.weights),
    };
  });
  const waves: Glm52MoeBatchWave[] = [];
  for (let begin = 0; begin < jobs.length; begin += waveSize)
    waves.push({ jobs: jobs.slice(begin, begin + waveSize) });
  return {
    routes,
    waves,
    uniqueExperts: jobs.length,
  };
}

async function executeExperts(
  runtime: Glm52ExpertRuntime,
  input: MlxArray,
  plan: Glm52MoeBatchPlan,
): Promise<MlxArray> {
  return runtime.executor.execute({
    layer: LAYER,
    input,
    plan,
    shared: null,
  });
}

function pinnedExperts(count: number) {
  return Array.from(
    { length: count },
    (_, expertId) => ({ layer: LAYER, expertId }),
  );
}

const cli = parseCli(Bun.argv.slice(2));
for (const [label, path] of Object.entries({
  model: cli.model,
  library: cli.library,
})) {
  if (!existsSync(path))
    throw new Error(`${label} path does not exist: ${path}`);
}
mkdirSync(dirname(cli.output), { recursive: true });

const config = await loadGlm52Config(cli.model);
if (
  config.hiddenSize !== 6144 ||
  config.moeIntermediateSize !== 2048 ||
  config.numAttentionHeads !== 64 ||
  config.qLoraRank !== 2048 ||
  config.kvLoraRank !== 512 ||
  config.qkNopeHeadDim !== 192 ||
  config.qkRopeHeadDim !== 64 ||
  config.vHeadDim !== 256
) {
  throw new Error(
    "quiet kernel matrix requires pinned GLM-5.2 production geometry",
  );
}

const swapBefore = swapUsage();
const powerSource = commandOutput(["/usr/bin/pmset", "-g", "batt"]);
if (!powerSource.includes("AC Power")) {
  throw new Error(
    "quiet benchmark refused: AC power is required; pmset reports:\n" +
    powerSource,
  );
}
const oldMemoryLimit = setMemoryLimit(cli.allocatorLimitBytes);
const machine = {
  date: new Date().toISOString(),
  hardware: commandOutput(["/usr/sbin/sysctl", "-n", "hw.model"]),
  memoryBytes: commandOutput(["/usr/sbin/sysctl", "-n", "hw.memsize"]),
  os: commandOutput(["/usr/bin/sw_vers", "-productVersion"]),
  bun: Bun.version,
  powerSource,
  loadAverageAtStart: loadavg(),
  allocatorLimitBytes: cli.allocatorLimitBytes,
};

const report: Record<string, unknown> = {
  schemaVersion: 1,
  kind: "colibri_glm52_mlx_bun_quiet_kernel_matrix",
  scope: {
    side: "mlx-bun",
    fullModel: false,
    generation: false,
    artifact: "direct pinned Colibri container",
    timing: "warm synchronized median",
  },
  machine,
  cli: {
    warmups: cli.warmups,
    samples: cli.samples,
    context: cli.context,
    workers: cli.workers,
  },
};

let decodeStockReference: Float32Array | null = null;
try {
  // ---- Q4 dense GEMM + stock MLA decode ---------------------------------
  const denseName = `model.layers.${LAYER}.self_attn.q_a_proj.weight`;
  const kvBName = `model.layers.${LAYER}.self_attn.kv_b_proj.weight`;
  const oName = `model.layers.${LAYER}.self_attn.o_proj.weight`;
  const selectedNames = [
    denseName,
    `${denseName}.qs`,
    kvBName,
    `${kvBName}.qs`,
    oName,
    `${oName}.qs`,
  ];
  const weights = ColibriGlm52Weights.openSelected(
    cli.model,
    selectedNames,
  );
  try {
    const denseInputs = [
      {
        name: "decode_m1",
        rows: 1,
        value: MlxArray.fromFloat32(
          deterministicF32(config.hiddenSize, 0x10203040),
          [1, config.hiddenSize],
        ),
      },
      {
        name: "prefill_m32",
        rows: 32,
        value: MlxArray.fromFloat32(
          deterministicF32(32 * config.hiddenSize, 0x50607080),
          [32, config.hiddenSize],
        ),
      },
    ];
    const denseCorrectness: Record<string, Comparison> = {};
    const denseTiming: Record<string, TimedResult> = {};
    try {
      // All dense candidates pass against the explicit f32-dequant oracle
      // before any dense timing begins.
      for (const item of denseInputs) {
        const actual = await hostOutput(() =>
          weights.linearQ4(
            item.value,
            denseName,
            config.qLoraRank,
            config.hiddenSize,
          ));
        const expected = await hostOutput(() =>
          weights.linear(
            item.value,
            denseName,
            config.qLoraRank,
            config.hiddenSize,
          ));
        const checked = comparison(actual, expected);
        requireCorrect(`dense Q4 ${item.name}`, checked, {
          relativeRmse: 0.01,
          cosine: 0.9999,
          normalizedMaxAbs: 0.08,
        });
        denseCorrectness[item.name] = checked;
      }
      for (const item of denseInputs) {
        denseTiming[item.name] = await benchmark(
          `Q4 dense GEMM ${item.name}`,
          item.rows,
          cli,
          () => weights.linearQ4(
            item.value,
            denseName,
            config.qLoraRank,
            config.hiddenSize,
          ),
        );
      }
    } finally {
      for (const item of denseInputs) item.value.dispose();
    }
    report.denseQ4 = {
      tensor: denseName,
      geometry: {
        outputRows: config.qLoraRank,
        inputColumns: config.hiddenSize,
        bits: 4,
      },
      oracle: "explicit dequant-to-f32 matmul",
      correctness: denseCorrectness,
      timing: denseTiming,
    };

    synchronize(gpuStream);
    clearCache();
    const mla = new Glm52Mla(config, weights, LAYER);
    const qNope = MlxArray.fromFloat32(
      deterministicF32(
        config.numAttentionHeads * config.qkNopeHeadDim,
        0x11223344,
      ),
      [1, 1, config.numAttentionHeads, config.qkNopeHeadDim],
    );
    const qRope = MlxArray.fromFloat32(
      deterministicF32(
        config.numAttentionHeads * config.qkRopeHeadDim,
        0x22334455,
      ),
      [1, 1, config.numAttentionHeads, config.qkRopeHeadDim],
    );
    const latent = MlxArray.fromFloat32(
      deterministicF32(cli.context * config.kvLoraRank, 0x33445566),
      [1, cli.context, config.kvLoraRank],
    );
    const rope = MlxArray.fromFloat32(
      deterministicF32(cli.context * config.qkRopeHeadDim, 0x44556677),
      [1, cli.context, config.qkRopeHeadDim],
    );
    try {
      const absorbed = await hostOutput(() =>
        mla.attendAbsorbed(
          { qNope, qRope },
          { latent, rope },
        ));
      const reconstructed = await hostOutput(() =>
        mla.attendReconstructed(
          { qNope, qRope },
          { latent, rope },
        ));
      const mlaCorrectness = comparison(absorbed, reconstructed);
      requireCorrect("stock MLX absorbed MLA decode", mlaCorrectness, {
        relativeRmse: 0.015,
        cosine: 0.9995,
        normalizedMaxAbs: 0.15,
      });
      const mlaTiming = await benchmark(
        "stock MLX absorbed MLA decode",
        1,
        cli,
        () => mla.attendAbsorbed(
          { qNope, qRope },
          { latent, rope },
        ),
      );
      report.mlaDecode = {
        candidate: "stock_mlx_absorbed",
        contextTokens: cli.context,
        geometry: {
          heads: config.numAttentionHeads,
          qkNope: config.qkNopeHeadDim,
          qkRope: config.qkRopeHeadDim,
          value: config.vHeadDim,
          latent: config.kvLoraRank,
        },
        oracle: "stock reconstructed MLA on identical tensors",
        correctness: mlaCorrectness,
        timing: mlaTiming,
        customMetal: {
          supported: false,
          reason: "no separate mlx-bun custom MLA candidate exists in G3",
        },
      };
    } finally {
      qNope.dispose();
      qRope.dispose();
      latent.dispose();
      rope.dispose();
    }
  } finally {
    weights.dispose();
    synchronize(gpuStream);
    clearCache();
  }

  // ---- Routed SwiGLU stock MLX ------------------------------------------
  const decodePlan = routedPlan(1, DECODE_EXPERTS, 64);
  const prefillPlan = routedPlan(
    PREFILL_ROWS,
    PREFILL_EXPERTS,
    64,
  );
  const prefillChunkedPlan = routedPlan(
    PREFILL_ROWS,
    PREFILL_EXPERTS,
    8,
  );
  const raggedPlan = routedPlan(RAGGED_ROWS, RAGGED_EXPERTS, 64);
  const raggedChunkedPlan = routedPlan(RAGGED_ROWS, RAGGED_EXPERTS, 8);
  const decodeInput = inputArray(1, config.hiddenSize, 0x66778899);
  const prefillInput = inputArray(
    PREFILL_ROWS,
    config.hiddenSize,
    0x778899aa,
  );
  const raggedInput = inputArray(
    RAGGED_ROWS,
    config.hiddenSize,
    0x8899aabb,
  );
  const stockRuntime = Glm52ExpertRuntime.open(cli.model, config, {
    budgetBytes: 25 * GiB,
    fixedBytes: 0,
    workingSlots: 64,
    maxSlotsPerLayer: 1,
    pinned: pinnedExperts(PREFILL_EXPERTS),
    workers: cli.workers,
    noCache: false,
    libraryPath: cli.library,
    decodeKernel: "stock",
  });
  let prefillCorrectness: Comparison;
  let raggedCorrectness: Comparison;
  try {
    // Correctness first. Alternate wave partitioning must not change math.
    decodeStockReference = await hostOutput(() =>
      executeExperts(stockRuntime, decodeInput, decodePlan));
    const decodeRepeat = await hostOutput(() =>
      executeExperts(stockRuntime, decodeInput, decodePlan));
    const decodeDeterminism = comparison(
      decodeRepeat,
      decodeStockReference,
    );
    requireCorrect("stock routed decode determinism", decodeDeterminism, {
      relativeRmse: 1e-6,
      cosine: 0.999999,
      normalizedMaxAbs: 1e-5,
    });

    const prefillOneWave = await hostOutput(() =>
      executeExperts(stockRuntime, prefillInput, prefillPlan));
    const prefillChunked = await hostOutput(() =>
      executeExperts(stockRuntime, prefillInput, prefillChunkedPlan));
    prefillCorrectness = comparison(prefillOneWave, prefillChunked);
    requireCorrect("stock routed prefill wave invariance", prefillCorrectness, {
      relativeRmse: 1e-6,
      cosine: 0.999999,
      normalizedMaxAbs: 1e-5,
    });

    const raggedOneWave = await hostOutput(() =>
      executeExperts(stockRuntime, raggedInput, raggedPlan));
    const raggedChunked = await hostOutput(() =>
      executeExperts(stockRuntime, raggedInput, raggedChunkedPlan));
    raggedCorrectness = comparison(raggedOneWave, raggedChunked);
    requireCorrect("stock routed ragged wave invariance", raggedCorrectness, {
      relativeRmse: 1e-6,
      cosine: 0.999999,
      normalizedMaxAbs: 1e-5,
    });

    const stockDecodeTiming = await benchmark(
      "routed SwiGLU decode M=1 stock MLX",
      1,
      cli,
      () => executeExperts(stockRuntime, decodeInput, decodePlan),
      stockRuntime,
    );
    const stockPrefillTiming = await benchmark(
      "routed SwiGLU prefill M=32 stock MLX",
      PREFILL_ROWS,
      cli,
      () => executeExperts(stockRuntime, prefillInput, prefillPlan),
      stockRuntime,
    );
    const stockRaggedTiming = await benchmark(
      "routed SwiGLU ragged M=11 stock MLX",
      RAGGED_ROWS,
      cli,
      () => executeExperts(stockRuntime, raggedInput, raggedPlan),
      stockRuntime,
    );
    report.routedSwiGlu = {
      geometry: {
        hidden: config.hiddenSize,
        intermediate: config.moeIntermediateSize,
        topK: DECODE_EXPERTS,
        bits: 4,
      },
      decodeM1: {
        stock: {
          correctness: decodeDeterminism,
          timing: stockDecodeTiming,
        },
      },
      prefillM32: {
        uniqueExperts: prefillPlan.uniqueExperts,
        stock: {
          correctness: prefillCorrectness,
          timing: stockPrefillTiming,
        },
        customMetal: {
          supported: false,
          effectivePath: "stock_mlx_fallback",
          reason:
            "the direct canonical-slot Metal candidate is M=1 per expert; " +
            "general multi-row prefill remains stock",
        },
      },
      raggedM11: {
        uniqueExperts: raggedPlan.uniqueExperts,
        stock: {
          correctness: raggedCorrectness,
          timing: stockRaggedTiming,
        },
        customMetal: {
          supported: false,
          effectivePath: "stock_mlx_fallback",
          reason:
            "ragged multi-row expert jobs are outside the direct M=1 Metal contract",
        },
      },
    };
  } finally {
    stockRuntime.close();
    synchronize(gpuStream);
    clearCache();
  }

  // ---- Routed SwiGLU custom Metal M=1 -----------------------------------
  const metalRuntime = Glm52ExpertRuntime.open(cli.model, config, {
    budgetBytes: 25 * GiB,
    fixedBytes: 0,
    workingSlots: DECODE_EXPERTS,
    maxSlotsPerLayer: 1,
    pinned: pinnedExperts(DECODE_EXPERTS),
    workers: cli.workers,
    noCache: false,
    libraryPath: cli.library,
    decodeKernel: "metal",
  });
  try {
    const metalHost = await hostOutput(() =>
      executeExperts(metalRuntime, decodeInput, decodePlan));
    const metalCorrectness = comparison(
      metalHost,
      decodeStockReference!,
    );
    requireCorrect("custom Metal routed decode vs stock", metalCorrectness, {
      relativeRmse: 0.015,
      cosine: 0.9995,
      normalizedMaxAbs: 0.15,
    });
    const metalTiming = await benchmark(
      "routed SwiGLU decode M=1 custom Metal",
      1,
      cli,
      () => executeExperts(metalRuntime, decodeInput, decodePlan),
      metalRuntime,
    );
    const routed = report.routedSwiGlu as {
      decodeM1: Record<string, unknown>;
    };
    routed.decodeM1.customMetal = {
      correctness: metalCorrectness,
      timing: metalTiming,
    };
    const stockMedian = (
      routed.decodeM1.stock as { timing: TimedResult }
    ).timing.medianMs;
    routed.decodeM1.fastestCorrectMlxPath =
      metalTiming.medianMs < stockMedian ? "custom_metal" : "stock_mlx";
  } finally {
    metalRuntime.close();
    decodeInput.dispose();
    prefillInput.dispose();
    raggedInput.dispose();
    synchronize(gpuStream);
    clearCache();
  }

  report.swap = {
    before: swapBefore,
    after: swapUsage(),
  };
  report.finalAllocator = allocatorSnapshot();
  await Bun.write(cli.output, `${JSON.stringify(report, null, 2)}\n`);
  console.log(`wrote ${cli.output}`);
} finally {
  synchronize(gpuStream);
  clearCache();
  setMemoryLimit(oldMemoryLimit);
}
