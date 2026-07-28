#!/usr/bin/env bun

/**
 * Manual G3 production-artifact correctness probe.
 *
 * This is deliberately one layer and one decode row. It:
 *   1. reproduces Colibri's captured layer-3 true top-8 route;
 *   2. executes those eight routed experts through the native slab runtime;
 *   3. adds the directly loaded shared expert and compares the complete MoE
 *      output with the G0 Colibri capture;
 *   4. repeats the row to prove a residency hit;
 *   5. installs one non-route expert to force an LRU eviction, then reruns the
 *      true route and checks the complete output again.
 *
 * It does not construct the full model, run generation, or report performance.
 */

import {
  existsSync,
  mkdirSync,
  readFileSync,
} from "node:fs";
import { basename, dirname, join, resolve } from "node:path";
import { MlxArray, gpuStream } from "../src/mlx/array";
import {
  activeMemory,
  cacheMemory,
  clearCache,
  Dtype,
  peakMemory,
  resetPeakMemory,
  synchronize,
} from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { loadGlm52Config } from "../src/model/glm52-config";
import {
  planGlm52MoeBatchF32,
  type Glm52MoeBatchPlan,
} from "../src/model/glm52-moe";
import { Glm52ExpertRuntime } from "../src/model/glm52-residency";
import { ColibriGlm52Weights } from "../src/model/glm52-weights";

const LAYER = 3;
const INPUT_FILE = "0114.decode32.layer3.ffn.norm.f32";
const IDS_FILE = "0116.decode32.layer3.moe.top_ids.i32";
const WEIGHTS_FILE = "0117.decode32.layer3.moe.top_weights.f32";
const OUTPUT_FILE = "0119.decode32.layer3.ffn.output.f32";
const EXPECTED_SHA256 = {
  input: "0747fa2826f3bd39364ab88f2b6cae7c5b85d4f3199227bcbf2880c566961024",
  ids: "568cb9bbc99871a86c0394286242458f8405479fdc356a2b8ae9b931cbff13b4",
  weights: "cc5d80df62f8f40b4f7e1956fa1406f75ac3603547857f0f77ba5872ca4e2342",
  output: "1f9c8dc69f0fcac72002b007b03d6c15d048d9c7337cb7134d256bbc9294b0f5",
} as const;

interface Cli {
  readonly model: string;
  readonly capture: string;
  readonly output: string;
  readonly libraryPath?: string;
}

interface ErrorMetrics {
  readonly maxAbs: number;
  readonly meanAbs: number;
  readonly rmse: number;
  readonly cosine: number;
}

function parseCli(argv: string[]): Cli {
  const values = new Map<string, string>();
  for (let index = 0; index < argv.length; index += 2) {
    const key = argv[index];
    const value = argv[index + 1];
    if (!key?.startsWith("--") || value === undefined)
      throw new Error(
        "usage: probe-colibri-glm52-g3-experts.ts " +
        "--model DIR --capture DIR --output FILE [--library DYLIB]",
      );
    values.set(key.slice(2), value);
  }
  const required = (key: string): string => {
    const value = values.get(key);
    if (!value) throw new Error(`missing --${key}`);
    return resolve(value);
  };
  return {
    model: required("model"),
    capture: required("capture"),
    output: required("output"),
    libraryPath: values.has("library")
      ? resolve(values.get("library")!)
      : undefined,
  };
}

function bytes(path: string): Uint8Array {
  const value = readFileSync(path);
  return new Uint8Array(value.buffer, value.byteOffset, value.byteLength);
}

function sha256(value: ArrayBufferView): string {
  return new Bun.CryptoHasher("sha256")
    .update(new Uint8Array(value.buffer, value.byteOffset, value.byteLength))
    .digest("hex");
}

function checkedBytes(
  path: string,
  expectedBytes: number,
  expectedSha256: string,
): Uint8Array {
  const value = bytes(path);
  if (value.byteLength !== expectedBytes)
    throw new Error(
      `${path}: expected ${expectedBytes} bytes, got ${value.byteLength}`,
    );
  const actualSha256 = sha256(value);
  if (actualSha256 !== expectedSha256)
    throw new Error(
      `${path}: SHA-256 ${actualSha256} != G0 ${expectedSha256}`,
    );
  return value;
}

function asF32(value: Uint8Array): Float32Array {
  const copy = value.buffer.slice(
    value.byteOffset,
    value.byteOffset + value.byteLength,
  );
  return new Float32Array(copy);
}

function asI32(value: Uint8Array): Int32Array {
  const copy = value.buffer.slice(
    value.byteOffset,
    value.byteOffset + value.byteLength,
  );
  return new Int32Array(copy);
}

function metrics(actual: Float32Array, expected: Float32Array): ErrorMetrics {
  if (actual.length !== expected.length)
    throw new Error(`metric length ${actual.length} != ${expected.length}`);
  let maxAbs = 0;
  let sumAbs = 0;
  let sumSquares = 0;
  let dot = 0;
  let normActual = 0;
  let normExpected = 0;
  for (let index = 0; index < actual.length; index++) {
    const a = actual[index]!;
    const e = expected[index]!;
    if (!Number.isFinite(a) || !Number.isFinite(e))
      throw new Error(`non-finite comparison at ${index}: ${a} vs ${e}`);
    const delta = a - e;
    const absolute = Math.abs(delta);
    maxAbs = Math.max(maxAbs, absolute);
    sumAbs += absolute;
    sumSquares += delta * delta;
    dot += a * e;
    normActual += a * a;
    normExpected += e * e;
  }
  return {
    maxAbs,
    meanAbs: sumAbs / actual.length,
    rmse: Math.sqrt(sumSquares / actual.length),
    cosine: dot / Math.sqrt(normActual * normExpected),
  };
}

function allocatorSnapshot() {
  return {
    active: activeMemory(),
    cache: cacheMemory(),
    peak: peakMemory(),
    rss: process.memoryUsage().rss,
  };
}

function swapSnapshot(): string {
  const result = Bun.spawnSync(["/usr/sbin/sysctl", "-n", "vm.swapusage"], {
    stdout: "pipe",
    stderr: "pipe",
  });
  if (result.exitCode !== 0)
    throw new Error(
      `sysctl vm.swapusage failed: ` +
      new TextDecoder().decode(result.stderr).trim(),
    );
  return new TextDecoder().decode(result.stdout).trim();
}

function directSwiGlu(
  source: ColibriGlm52Weights,
  input: MlxArray,
  prefix: string,
  intermediate: number,
  hidden: number,
): MlxArray {
  const gate = source.linear(
    input,
    `${prefix}.gate_proj.weight`,
    intermediate,
    hidden,
  );
  const up = source.linear(
    input,
    `${prefix}.up_proj.weight`,
    intermediate,
    hidden,
  );
  const activated = ops.silu(gate);
  const product = ops.mul(activated, up);
  gate.dispose();
  up.dispose();
  activated.dispose();
  const output = source.linear(
    product,
    `${prefix}.down_proj.weight`,
    hidden,
    intermediate,
  );
  product.dispose();
  return output;
}

function serializableSnapshot(
  snapshot: ReturnType<Glm52ExpertRuntime["manager"]["snapshot"]>,
) {
  return {
    ...snapshot,
    clock: snapshot.clock.toString(),
    generation: snapshot.generation.toString(),
  };
}

function delta(
  before: ReturnType<Glm52ExpertRuntime["manager"]["snapshot"]>,
  after: ReturnType<Glm52ExpertRuntime["manager"]["snapshot"]>,
) {
  return {
    hits: after.hits - before.hits,
    misses: after.misses - before.misses,
    evictions: after.evictions - before.evictions,
    pressureEvictions:
      after.pressureEvictions - before.pressureEvictions,
    footprintBytes: after.physicalFootprint - before.physicalFootprint,
  };
}

async function runCompleteMoe(
  runtime: Glm52ExpertRuntime,
  input: MlxArray,
  plan: Glm52MoeBatchPlan,
  shared: MlxArray,
): Promise<Float32Array> {
  const output = await runtime.executor.execute({
    layer: LAYER,
    input,
    plan,
    shared,
  });
  try {
    const host = output.toFloat32();
    synchronize(gpuStream);
    return host;
  } finally {
    output.dispose();
  }
}

/**
 * Consume one word from a replacement expert through Metal before releasing
 * its generation-bound lease. This changes residency state without pretending
 * the artificial expert is a valid model route.
 */
async function forceReplacement(
  runtime: Glm52ExpertRuntime,
  expertId: number,
): Promise<void> {
  const lease = await runtime.manager.acquireBlock(LAYER, [expertId]);
  const entry = lease.entries[0]!;
  const packed = MlxArray.fromPointer(
    runtime.store.pointer(entry.slot, entry.generation),
    [1],
    Dtype.uint32,
  );
  const consumed = packed.astype(Dtype.float32);
  try {
    ops.evalAll([consumed]);
    synchronize(gpuStream);
    lease.releaseFenced();
  } catch (error) {
    synchronize(gpuStream);
    lease.releaseFenced();
    throw error;
  } finally {
    consumed.dispose();
    packed.dispose();
  }
}

const cli = parseCli(Bun.argv.slice(2));
for (const [label, path] of Object.entries({
  model: cli.model,
  capture: cli.capture,
  library: cli.libraryPath,
})) {
  if (path && !existsSync(path))
    throw new Error(`${label} path does not exist: ${path}`);
}
mkdirSync(dirname(cli.output), { recursive: true });

const config = await loadGlm52Config(cli.model);
if (
  config.hiddenSize !== 6144 ||
  config.numRoutedExperts !== 256 ||
  config.numExpertsPerToken !== 8 ||
  config.firstKDenseReplace !== 3
) {
  throw new Error(
    "G3 production probe requires the pinned GLM-5.2 6144/256/top-8 geometry",
  );
}

const inputHost = asF32(checkedBytes(
  join(cli.capture, INPUT_FILE),
  config.hiddenSize * 4,
  EXPECTED_SHA256.input,
));
const expectedIds = asI32(checkedBytes(
  join(cli.capture, IDS_FILE),
  config.numExpertsPerToken * 4,
  EXPECTED_SHA256.ids,
));
const expectedWeights = asF32(checkedBytes(
  join(cli.capture, WEIGHTS_FILE),
  config.numExpertsPerToken * 4,
  EXPECTED_SHA256.weights,
));
const expectedOutput = asF32(checkedBytes(
  join(cli.capture, OUTPUT_FILE),
  config.hiddenSize * 4,
  EXPECTED_SHA256.output,
));

const prefix = `model.layers.${LAYER}.mlp`;
const routerName = `${prefix}.gate.weight`;
const correctionName = `${prefix}.gate.e_score_correction_bias`;
const sharedPrefix = `${prefix}.shared_experts`;
const selectedNames = [
  routerName,
  correctionName,
  `${sharedPrefix}.gate_proj.weight`,
  `${sharedPrefix}.gate_proj.weight.qs`,
  `${sharedPrefix}.up_proj.weight`,
  `${sharedPrefix}.up_proj.weight.qs`,
  `${sharedPrefix}.down_proj.weight`,
  `${sharedPrefix}.down_proj.weight.qs`,
];

synchronize(gpuStream);
clearCache();
resetPeakMemory();
const allocatorBefore = allocatorSnapshot();
const swapBefore = swapSnapshot();
const direct = ColibriGlm52Weights.openSelected(cli.model, selectedNames);
const input = MlxArray.fromFloat32(inputHost, [1, 1, config.hiddenSize]);
let logits: MlxArray | null = null;
let shared: MlxArray | null = null;
let runtime: Glm52ExpertRuntime | null = null;

try {
  const router = direct.tensor(routerName);
  const routerTranspose = ops.transposeAxes(router, [1, 0]);
  logits = ops.matmul(input, routerTranspose);
  routerTranspose.dispose();
  const logitsHost = logits.toFloat32();
  const correction = direct.tensor(correctionName).toFloat32();
  synchronize(gpuStream);
  const plan = planGlm52MoeBatchF32(
    [logitsHost],
    correction,
    {
      topK: config.numExpertsPerToken,
      normalize: config.normTopkProb,
      routedScale: config.routedScalingFactor,
    },
    config.numExpertsPerToken,
  );
  const route = plan.routes[0]!;
  const actualIds = route.indices;
  if (
    actualIds.length !== expectedIds.length ||
    actualIds.some((id, index) => id !== expectedIds[index])
  ) {
    throw new Error(
      `layer-3 route ${actualIds.join(",")} != G0 ` +
      Array.from(expectedIds).join(","),
    );
  }
  const routeWeightComparison = metrics(
    route.executionWeights,
    expectedWeights,
  );
  if (routeWeightComparison.maxAbs > 1e-4)
    throw new Error(
      `layer-3 route-weight parity failed: ` +
      JSON.stringify(routeWeightComparison),
    );

  const sharedIntermediate =
    config.moeIntermediateSize * config.numSharedExperts;
  if (sharedIntermediate <= 0)
    throw new Error("G3 complete-MoE probe requires a shared expert");
  shared = directSwiGlu(
    direct,
    input,
    sharedPrefix,
    sharedIntermediate,
    config.hiddenSize,
  );

  // Eight global scratch slots and one pure-LRU slot per sparse layer are the
  // smallest layout that can execute this top-8 decode row and force churn.
  runtime = Glm52ExpertRuntime.open(cli.model, config, {
    budgetBytes: 4 * 1024 ** 3,
    fixedBytes: 0,
    workingSlots: config.numExpertsPerToken,
    maxSlotsPerLayer: 1,
    workers: 4,
    noCache: false,
    libraryPath: cli.libraryPath,
  });
  const initial = runtime.manager.snapshot();

  const coldOutput = await runCompleteMoe(runtime, input, plan, shared);
  const afterCold = runtime.manager.snapshot();
  const coldComparison = metrics(coldOutput, expectedOutput);

  const warmOutput = await runCompleteMoe(runtime, input, plan, shared);
  const afterWarm = runtime.manager.snapshot();
  const warmComparison = metrics(warmOutput, expectedOutput);

  const replacement = Array.from(
    { length: config.numRoutedExperts },
    (_, expertId) => expertId,
  ).find((expertId) => !actualIds.includes(expertId))!;
  await forceReplacement(runtime, replacement);
  const afterReplacement = runtime.manager.snapshot();

  const churnedOutput = await runCompleteMoe(runtime, input, plan, shared);
  const afterChurned = runtime.manager.snapshot();
  const churnedComparison = metrics(churnedOutput, expectedOutput);

  const bounds = {
    maxAbs: 2e-5,
    rmse: 2e-6,
    cosine: 0.999999,
  };
  for (const [label, comparison] of Object.entries({
    cold: coldComparison,
    warm: warmComparison,
    churned: churnedComparison,
  })) {
    if (
      comparison.maxAbs > bounds.maxAbs ||
      comparison.rmse > bounds.rmse ||
      comparison.cosine < bounds.cosine
    ) {
      throw new Error(
        `${label} complete-MoE parity failed: ${JSON.stringify(comparison)}`,
      );
    }
  }
  const coldDelta = delta(initial, afterCold);
  const warmDelta = delta(afterCold, afterWarm);
  const replacementDelta = delta(afterWarm, afterReplacement);
  const churnedDelta = delta(afterReplacement, afterChurned);
  if (coldDelta.misses !== 8 || coldDelta.hits !== 0)
    throw new Error(`cold residency trace mismatch: ${JSON.stringify(coldDelta)}`);
  if (warmDelta.hits < 1 || warmDelta.misses > 7)
    throw new Error(`warm residency trace mismatch: ${JSON.stringify(warmDelta)}`);
  if (replacementDelta.evictions < 1)
    throw new Error(
      `replacement did not force an LRU eviction: ` +
      JSON.stringify(replacementDelta),
    );
  if (churnedDelta.misses !== 8)
    throw new Error(
      `post-eviction route should be fully cold: ${JSON.stringify(churnedDelta)}`,
    );

  const report = {
    schemaVersion: 1,
    kind: "colibri_glm52_g3_bounded_production_expert_probe",
    scope: {
      fullModel: false,
      generation: false,
      performanceClaim: false,
      layer: LAYER,
      rows: 1,
      route: "captured decode-row true top-8",
      completeMoe: "routed weighted sum plus one unweighted shared expert",
    },
    inputs: {
      model: cli.model,
      capture: cli.capture,
      files: {
        input: { name: INPUT_FILE, sha256: EXPECTED_SHA256.input },
        ids: { name: IDS_FILE, sha256: EXPECTED_SHA256.ids },
        weights: { name: WEIGHTS_FILE, sha256: EXPECTED_SHA256.weights },
        output: { name: OUTPUT_FILE, sha256: EXPECTED_SHA256.output },
      },
    },
    route: {
      ids: actualIds,
      expectedIds: Array.from(expectedIds),
      exact: true,
      executionWeights: Array.from(route.executionWeights),
      weightComparison: routeWeightComparison,
      replacementExpert: replacement,
    },
    residencyPlan: runtime.plan,
    residency: {
      initial: serializableSnapshot(initial),
      cold: {
        delta: coldDelta,
        snapshot: serializableSnapshot(afterCold),
      },
      warm: {
        delta: warmDelta,
        snapshot: serializableSnapshot(afterWarm),
      },
      replacement: {
        delta: replacementDelta,
        snapshot: serializableSnapshot(afterReplacement),
      },
      churned: {
        delta: churnedDelta,
        snapshot: serializableSnapshot(afterChurned),
      },
    },
    output: {
      expectedSha256: EXPECTED_SHA256.output,
      bounds,
      cold: {
        sha256: sha256(coldOutput),
        comparison: coldComparison,
      },
      warm: {
        sha256: sha256(warmOutput),
        comparison: warmComparison,
      },
      churned: {
        sha256: sha256(churnedOutput),
        comparison: churnedComparison,
      },
    },
    allocator: {
      before: allocatorBefore,
      evaluated: allocatorSnapshot(),
    },
    swap: {
      before: swapBefore,
      evaluated: swapSnapshot(),
    },
  };
  await Bun.write(cli.output, `${JSON.stringify(report, null, 2)}\n`);
  console.log(
    JSON.stringify({
      output: cli.output,
      route: actualIds,
      cold: coldDelta,
      warm: warmDelta,
      replacement: replacementDelta,
      churned: churnedDelta,
      comparison: {
        cold: coldComparison,
        warm: warmComparison,
        churned: churnedComparison,
      },
      physicalFootprintBytes: afterChurned.physicalFootprint,
      swap: report.swap,
    }, null, 2),
  );
} finally {
  runtime?.close();
  shared?.dispose();
  logits?.dispose();
  input.dispose();
  direct.dispose();
  synchronize(gpuStream);
  clearCache();
}
