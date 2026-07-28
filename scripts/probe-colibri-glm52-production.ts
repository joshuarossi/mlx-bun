#!/usr/bin/env bun

/**
 * Manual G2 production-artifact correctness probe.
 *
 * This intentionally does not construct Glm52Model or run generation. It
 * evaluates one captured production row through layer 0's dense Q4 SwiGLU and
 * two captured rows through real F32 routers. Each cell opens only its owning
 * shard, forces evaluation, synchronizes, disposes, and clears the MLX cache.
 */

import { existsSync, mkdirSync, readFileSync } from "node:fs";
import { basename, join, resolve } from "node:path";
import { cpus } from "node:os";
import { MlxArray, gpuStream } from "../src/mlx/array";
import {
  activeMemory,
  cacheMemory,
  clearCache,
  peakMemory,
  resetPeakMemory,
  synchronize,
} from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { loadGlm52Config } from "../src/model/glm52-config";
import { routeGlm52MoeF32 } from "../src/model/glm52-moe";
import { ColibriGlm52Weights } from "../src/model/glm52-weights";

const PINNED_COLIBRI_COMMIT = "44e489b196c9b7876b3d37a0570ebf1c6f90f54c";
const PINNED_COLIBRI_GLM_SHA256 =
  "3be1b4dd663667c8fa2cfbbacdada3e545ff5f924737a0f5d058708d7bc5ad9d";

interface Cli {
  model: string;
  capture: string;
  colibri: string;
  output: string;
}

interface ErrorMetrics {
  maxAbs: number;
  meanAbs: number;
  rmse: number;
  cosine: number;
}

function parseCli(argv: string[]): Cli {
  const values = new Map<string, string>();
  for (let index = 0; index < argv.length; index += 2) {
    const key = argv[index];
    const value = argv[index + 1];
    if (!key?.startsWith("--") || value === undefined)
      throw new Error(
        "usage: probe-colibri-glm52-production.ts " +
        "--model DIR --capture DIR --colibri DIR --output FILE",
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
    colibri: required("colibri"),
    output: required("output"),
  };
}

function f32File(path: string, count: number): Float32Array {
  const bytes = readFileSync(path);
  if (bytes.byteLength !== count * 4)
    throw new Error(`${path}: expected ${count * 4} bytes, got ${bytes.byteLength}`);
  return new Float32Array(
    bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength),
  );
}

function i32File(path: string, count: number): Int32Array {
  const bytes = readFileSync(path);
  if (bytes.byteLength !== count * 4)
    throw new Error(`${path}: expected ${count * 4} bytes, got ${bytes.byteLength}`);
  return new Int32Array(
    bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength),
  );
}

function sha256Bytes(bytes: Float32Array | Int32Array | Uint8Array): string {
  const view = new Uint8Array(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  return new Bun.CryptoHasher("sha256").update(view).digest("hex");
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

function commandOutput(command: string[]): string {
  const result = Bun.spawnSync(command, { stdout: "pipe", stderr: "pipe" });
  if (result.exitCode !== 0) {
    throw new Error(
      `${command.join(" ")} failed (${result.exitCode}):\n` +
      new TextDecoder().decode(result.stderr),
    );
  }
  return new TextDecoder().decode(result.stdout).trim();
}

function validateColibriCheckout(colibri: string) {
  const commit = commandOutput(["git", "-C", colibri, "rev-parse", "HEAD"]);
  if (commit !== PINNED_COLIBRI_COMMIT)
    throw new Error(
      `Colibri commit ${commit} != pinned ${PINNED_COLIBRI_COMMIT}`,
    );
  const dirty = commandOutput(["git", "-C", colibri, "status", "--porcelain"]);
  if (dirty.length > 0)
    throw new Error("Colibri checkout is dirty; refusing a mislabeled oracle build");
  const source = readFileSync(join(colibri, "c", "glm.c"));
  const sourceSha256 = sha256Bytes(source);
  if (sourceSha256 !== PINNED_COLIBRI_GLM_SHA256)
    throw new Error(
      `Colibri c/glm.c SHA-256 ${sourceSha256} != pinned ` +
      PINNED_COLIBRI_GLM_SHA256,
    );
  return { commit, sourceSha256 };
}

function compileDenseOracle(colibri: string, output: string): void {
  const source = resolve("scripts/experiments/colibri-g2-dense-oracle.c");
  const glm = join(colibri, "c", "glm.c");
  if (!existsSync(glm)) throw new Error(`${glm}: missing pinned Colibri source`);
  mkdirSync(resolve(output, ".."), { recursive: true });

  const args = [
    "clang",
    "-O3",
    "-Wall",
    "-Wextra",
    "-Wno-unused-parameter",
    "-Wno-unused-function",
    `-DCOLIBRI_GLM_SOURCE="${glm}"`,
    source,
    "-o",
    output,
    "-lm",
  ];
  const brew = Bun.spawnSync(["brew", "--prefix", "libomp"], {
    stdout: "pipe",
    stderr: "ignore",
  });
  if (brew.exitCode === 0) {
    const prefix = new TextDecoder().decode(brew.stdout).trim();
    if (
      existsSync(join(prefix, "include", "omp.h")) &&
      existsSync(join(prefix, "lib"))
    ) {
      args.splice(2, 0, "-Xclang", "-fopenmp", `-I${join(prefix, "include")}`);
      args.push(`-L${join(prefix, "lib")}`, "-lomp");
    }
  }
  commandOutput(args);
}

function allocatorSnapshot() {
  return {
    active: activeMemory(),
    cache: cacheMemory(),
    peak: peakMemory(),
    rss: process.memoryUsage().rss,
  };
}

async function runDense(
  cli: Cli,
  hidden: number,
  intermediate: number,
  workDir: string,
) {
  const inputPath = join(cli.capture, "0102.decode32.layer0.ffn.norm.f32");
  const oraclePath = join(workDir, "layer0-dense-idot0.f32");
  const binary = join(workDir, "colibri-g2-dense-oracle");
  const input = f32File(inputPath, hidden);

  compileDenseOracle(cli.colibri, binary);
  const oracleRun = Bun.spawnSync(
    [binary, cli.model, inputPath, oraclePath],
    { stdout: "pipe", stderr: "pipe" },
  );
  if (oracleRun.exitCode !== 0) {
    throw new Error(
      `Colibri dense oracle failed (${oracleRun.exitCode}):\n` +
      new TextDecoder().decode(oracleRun.stderr),
    );
  }
  const expected = f32File(oraclePath, hidden);

  const prefix = "model.layers.0.mlp";
  const gate = `${prefix}.gate_proj.weight`;
  const up = `${prefix}.up_proj.weight`;
  const down = `${prefix}.down_proj.weight`;
  const tensorNames = [gate, `${gate}.qs`, up, `${up}.qs`, down, `${down}.qs`];

  synchronize(gpuStream);
  clearCache();
  resetPeakMemory();
  const before = allocatorSnapshot();
  const weights = ColibriGlm52Weights.openSelected(cli.model, tensorNames);
  const x = MlxArray.fromFloat32(input, [1, 1, hidden]);
  let output: MlxArray | null = null;
  try {
    const gateValue = weights.linear(x, gate, intermediate, hidden);
    const upValue = weights.linear(x, up, intermediate, hidden);
    const activated = ops.silu(gateValue);
    const product = ops.mul(activated, upValue);
    gateValue.dispose();
    upValue.dispose();
    activated.dispose();
    output = weights.linear(product, down, hidden, intermediate);
    product.dispose();
    const actual = output.toFloat32();
    synchronize(gpuStream);
    const comparison = metrics(actual, expected);
    if (
      comparison.maxAbs > 1e-3 ||
      comparison.rmse > 1e-4 ||
      comparison.cosine < 0.99999
    ) {
      throw new Error(
        `dense parity sanity bound failed: ${JSON.stringify(comparison)}`,
      );
    }
    return {
      input: {
        file: basename(inputPath),
        sha256: sha256Bytes(input),
      },
      oracle: {
        engine: "pinned Colibri C dense_mlp",
        idot: 0,
        outputSha256: sha256Bytes(expected),
        stderr: new TextDecoder().decode(oracleRun.stderr).trim(),
      },
      mlx: {
        outputSha256: sha256Bytes(actual),
        comparison,
      },
      tensors: tensorNames.map((name) => {
        const info = weights.container.info(name);
        return {
          name,
          shard: basename(info.file),
          absoluteBegin: info.absoluteBegin,
          byteLength: info.byteLength,
        };
      }),
      mappedShardCount: weights.mappedShardCount,
      mappedShardBytes: weights.mappedShardBytes,
      allocator: {
        before,
        evaluated: allocatorSnapshot(),
      },
    };
  } finally {
    output?.dispose();
    x.dispose();
    weights.dispose();
    synchronize(gpuStream);
    clearCache();
  }
}

async function runRouter(
  cli: Cli,
  hidden: number,
  experts: number,
  layer: 3 | 77,
  files: {
    input: string;
    sigmoid: string;
    ids: string;
    weights: string;
    keff: string;
  },
  routerConfig: {
    topK: number;
    normalize: boolean;
    routedScale: number;
  },
) {
  const prefix = `model.layers.${layer}.mlp.gate`;
  const gate = `${prefix}.weight`;
  const biasName = `${prefix}.e_score_correction_bias`;
  const inputPath = join(cli.capture, files.input);
  const input = f32File(inputPath, hidden);
  const expectedSigmoid = f32File(join(cli.capture, files.sigmoid), experts);
  const expectedIds = i32File(join(cli.capture, files.ids), routerConfig.topK);
  const expectedWeights = f32File(
    join(cli.capture, files.weights),
    routerConfig.topK,
  );
  const expectedKeff = i32File(join(cli.capture, files.keff), 1)[0]!;

  synchronize(gpuStream);
  clearCache();
  resetPeakMemory();
  const before = allocatorSnapshot();
  const weights = ColibriGlm52Weights.openSelected(
    cli.model,
    [gate, biasName],
  );
  const x = MlxArray.fromFloat32(input, [1, hidden]);
  let logits: MlxArray | null = null;
  try {
    const router = weights.tensor(gate);
    const transposed = ops.transposeAxes(router, [1, 0]);
    logits = ops.matmul(x, transposed);
    transposed.dispose();
    const logitsHost = logits.toFloat32();
    const bias = weights.tensor(biasName).toFloat32();
    synchronize(gpuStream);
    const route = routeGlm52MoeF32(logitsHost, bias, routerConfig);
    const idsExact = route.indices.length === expectedIds.length &&
      route.indices.every((id, index) => id === expectedIds[index]);
    if (!idsExact)
      throw new Error(
        `layer ${layer} route mismatch: ${route.indices.join(",")} != ` +
        Array.from(expectedIds).join(","),
      );
    if (route.indices.length !== expectedKeff)
      throw new Error(
        `layer ${layer} keff ${route.indices.length} != ${expectedKeff}`,
      );
    const sigmoidComparison = metrics(
      route.rawSigmoidScores,
      expectedSigmoid,
    );
    const weightComparison = metrics(
      route.executionWeights,
      expectedWeights,
    );
    if (sigmoidComparison.maxAbs > 1e-4 || weightComparison.maxAbs > 1e-4)
      throw new Error(
        `layer ${layer} router parity sanity bound failed: ` +
        JSON.stringify({ sigmoidComparison, weightComparison }),
      );
    const sortedSelection = Array.from(route.selectionScores)
      .sort((left, right) => right - left);
    return {
      layer,
      input: {
        file: files.input,
        sha256: sha256Bytes(input),
      },
      expectedIds: Array.from(expectedIds),
      actualIds: route.indices,
      exactIds: idsExact,
      expectedKeff,
      actualKeff: route.indices.length,
      exactKeff: route.indices.length === expectedKeff,
      top8BoundaryMargin: sortedSelection[routerConfig.topK - 1]! -
        sortedSelection[routerConfig.topK]!,
      sigmoidComparison,
      weightComparison,
      tensors: [gate, biasName].map((name) => {
        const info = weights.container.info(name);
        return {
          name,
          shard: basename(info.file),
          absoluteBegin: info.absoluteBegin,
          byteLength: info.byteLength,
        };
      }),
      mappedShardCount: weights.mappedShardCount,
      mappedShardBytes: weights.mappedShardBytes,
      allocator: {
        before,
        evaluated: allocatorSnapshot(),
      },
    };
  } finally {
    logits?.dispose();
    x.dispose();
    weights.dispose();
    synchronize(gpuStream);
    clearCache();
  }
}

const cli = parseCli(Bun.argv.slice(2));
for (const [label, path] of Object.entries({
  model: cli.model,
  capture: cli.capture,
  colibri: cli.colibri,
})) {
  if (!existsSync(path)) throw new Error(`${label} path does not exist: ${path}`);
}
mkdirSync(resolve(cli.output, ".."), { recursive: true });
const workDir = join(resolve(cli.output, ".."), "g2-production-probe-work");
mkdirSync(workDir, { recursive: true });

const config = await loadGlm52Config(cli.model);
const colibriProvenance = validateColibriCheckout(cli.colibri);
const dense = await runDense(
  cli,
  config.hiddenSize,
  config.intermediateSize,
  workDir,
);
const routerConfig = {
  topK: config.numExpertsPerToken,
  normalize: config.normTopkProb,
  routedScale: config.routedScalingFactor,
};
const router3 = await runRouter(
  cli,
  config.hiddenSize,
  config.numRoutedExperts,
  3,
  {
    input: "0114.decode32.layer3.ffn.norm.f32",
    sigmoid: "0115.decode32.layer3.moe.sigmoid_scores.f32",
    ids: "0116.decode32.layer3.moe.top_ids.i32",
    weights: "0117.decode32.layer3.moe.top_weights.f32",
    keff: "0118.decode32.layer3.moe.keff.i32",
  },
  routerConfig,
);
const router77 = await runRouter(
  cli,
  config.hiddenSize,
  config.numRoutedExperts,
  77,
  {
    input: "0130.decode32.layer77.ffn.norm.f32",
    sigmoid: "0131.decode32.layer77.moe.sigmoid_scores.f32",
    ids: "0132.decode32.layer77.moe.top_ids.i32",
    weights: "0133.decode32.layer77.moe.top_weights.f32",
    keff: "0134.decode32.layer77.moe.keff.i32",
  },
  routerConfig,
);

const report = {
  schemaVersion: 1,
  gate: "G2 production Q4 dense/router",
  result: "pass",
  contract: {
    dense: "same production Q4 bytes; Colibri IDOT=0 vs MLX dequant-to-f32 matmul",
    router: "same captured production f32 input/weights; exact top-8 and keff",
    sanityBounds: {
      denseMaxAbs: 1e-3,
      denseRmse: 1e-4,
      denseMinCosine: 0.99999,
      routerSigmoidMaxAbs: 1e-4,
      routerWeightMaxAbs: 1e-4,
    },
  },
  environment: {
    timestamp: new Date().toISOString(),
    platform: process.platform,
    arch: process.arch,
    cpu: cpus()[0]?.model ?? "unknown",
    bun: Bun.version,
    colibriCommit: colibriProvenance.commit,
    colibriGlmSha256: colibriProvenance.sourceSha256,
    modelSnapshot: basename(cli.model),
  },
  geometry: {
    hidden: config.hiddenSize,
    denseIntermediate: config.intermediateSize,
    experts: config.numRoutedExperts,
    topK: config.numExpertsPerToken,
  },
  dense,
  routers: [router3, router77],
  finalAllocator: allocatorSnapshot(),
};

await Bun.write(cli.output, `${JSON.stringify(report, null, 2)}\n`);
console.log(JSON.stringify(report, null, 2));
