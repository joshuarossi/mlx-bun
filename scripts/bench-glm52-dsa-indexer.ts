#!/usr/bin/env bun

/** Model-free G6R Stage-1 benchmark at the exact GLM-5.2 DSA geometry. */

import { mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { MlxArray } from "../src/mlx/array";
import {
  activeMemory,
  cacheMemory,
  peakMemory,
  resetPeakMemory,
} from "../src/mlx/ffi";
import {
  glm52DsaScoresMlx,
  selectGlm52DsaDevice,
} from "../src/model/glm52-dsa";
import { selectDsaThresholdTiesF32 } from "../src/model/glm52-reference";

const HEADS = 32;
const HEAD_DIM = 128;
const TOP_K = 2048;

function argumentsMap(argv: string[]): Map<string, string> {
  const out = new Map<string, string>();
  for (let index = 0; index < argv.length; index += 2) {
    const key = argv[index];
    const value = argv[index + 1];
    if (!key?.startsWith("--") || value === undefined) {
      throw new Error(
        "usage: bench-glm52-dsa-indexer.ts " +
        "[--contexts 2048,8192,32768] [--repeats 7] [--output FILE]",
      );
    }
    out.set(key.slice(2), value);
  }
  return out;
}

function positiveInteger(value: string, label: string): number {
  const parsed = Number(value);
  if (!Number.isSafeInteger(parsed) || parsed < 1)
    throw new Error(`${label} must be a positive integer`);
  return parsed;
}

function median(values: readonly number[]): number {
  const sorted = [...values].sort((a, b) => a - b);
  return sorted[Math.floor(sorted.length / 2)]!;
}

function sameNumbers(a: readonly number[], b: readonly number[]): boolean {
  return a.length === b.length && a.every((value, index) => value === b[index]);
}

function deterministicValues(length: number, seed: number): Float32Array {
  return Float32Array.from({ length }, (_, index) => Math.fround(
    Math.sin((index + 1) * (seed + 0.013)) * 0.43 +
    Math.cos((index + 7) * (seed + 0.031)) * 0.17,
  ));
}

function timed(repeats: number, operation: () => void): {
  samples_ms: number[];
  median_ms: number;
  minimum_ms: number;
  maximum_ms: number;
} {
  const samples: number[] = [];
  for (let repeat = 0; repeat < repeats; repeat++) {
    const started = Bun.nanoseconds();
    operation();
    samples.push((Bun.nanoseconds() - started) / 1e6);
  }
  return {
    samples_ms: samples,
    median_ms: median(samples),
    minimum_ms: Math.min(...samples),
    maximum_ms: Math.max(...samples),
  };
}

const cli = argumentsMap(Bun.argv.slice(2));
const contexts = (cli.get("contexts") ?? "2048,8192,32768")
  .split(",")
  .map((value) => positiveInteger(value, "context"));
const repeats = positiveInteger(cli.get("repeats") ?? "7", "repeats");
const rows: unknown[] = [];

for (const contextLength of contexts) {
  const processRssBeforeInputs = process.memoryUsage().rss;
  const query = MlxArray.fromFloat32(
    deterministicValues(HEADS * HEAD_DIM, 0.17),
    [HEADS, HEAD_DIM],
  );
  const keys = MlxArray.fromFloat32(
    deterministicValues(contextLength * HEAD_DIM, 0.23),
    [contextLength, HEAD_DIM],
  );
  const weights = MlxArray.fromFloat32(
    deterministicValues(HEADS, 0.41),
    [HEADS],
  );

  try {
    const mlxActiveInputBytes = activeMemory();
    // Warm kernel compilation and allocator state outside measured samples.
    for (let warmup = 0; warmup < 2; warmup++) {
      const scores = glm52DsaScoresMlx(query, keys, weights);
      if (contextLength > TOP_K) {
        const selection = selectGlm52DsaDevice(scores, TOP_K);
        selection.positions.eval();
        selection.dispose();
      } else {
        scores.eval();
      }
      scores.dispose();
    }
    resetPeakMemory();

    const scoreTiming = timed(repeats, () => {
      const scores = glm52DsaScoresMlx(query, keys, weights);
      scores.eval();
      scores.dispose();
    });

    let selectionTiming = null;
    let endToEndTiming = null;
    let correctness = {
      mode: "dense" as "dense" | "sparse",
      positions_exact: true,
      threshold_exact_f32: true,
    };
    if (contextLength > TOP_K) {
      const evaluatedScores = glm52DsaScoresMlx(query, keys, weights);
      const hostScores = evaluatedScores.toFloat32();
      const expected = selectDsaThresholdTiesF32(hostScores, TOP_K);
      const actual = selectGlm52DsaDevice(evaluatedScores, TOP_K);
      correctness = {
        mode: "sparse",
        positions_exact: sameNumbers(
          actual.positions.toIntTokens(),
          expected.selected,
        ),
        threshold_exact_f32:
          actual.threshold.toFloat32()[0] === expected.threshold,
      };
      actual.dispose();

      selectionTiming = timed(repeats, () => {
        const selection = selectGlm52DsaDevice(evaluatedScores, TOP_K);
        selection.positions.eval();
        selection.dispose();
      });
      evaluatedScores.dispose();

      endToEndTiming = timed(repeats, () => {
        const scores = glm52DsaScoresMlx(query, keys, weights);
        const selection = selectGlm52DsaDevice(scores, TOP_K);
        selection.positions.eval();
        selection.dispose();
        scores.dispose();
      });
    }

    if (!correctness.positions_exact || !correctness.threshold_exact_f32)
      throw new Error(`device selection mismatch at context ${contextLength}`);

    const row = {
      context_length: contextLength,
      correctness,
      timing: {
        score: scoreTiming,
        device_top_k: selectionTiming,
        score_plus_top_k: endToEndTiming,
      },
      allocation_geometry_bytes: {
        removed_broadcast_product: HEADS * contextLength * HEAD_DIM * 4,
        tiled_dot_output: HEADS * contextLength * 4,
        score_vector: contextLength * 4,
        compact_index_buffer: contextLength > TOP_K ? TOP_K * 4 : 0,
      },
      memory: {
        process_rss_before_inputs_bytes: processRssBeforeInputs,
        process_rss_after_measurement_bytes: process.memoryUsage().rss,
        mlx_active_input_bytes: mlxActiveInputBytes,
        mlx_active_after_measurement_bytes: activeMemory(),
        mlx_peak_during_measurement_bytes: peakMemory(),
        mlx_cache_after_measurement_bytes: cacheMemory(),
      },
      host_copy_bytes: {
        one_time_input_upload:
          (HEADS * HEAD_DIM + contextLength * HEAD_DIM + HEADS) * 4,
        timed_cpu_to_gpu: 0,
        timed_gpu_to_cpu: 0,
        correctness_only_gpu_to_cpu:
          contextLength > TOP_K
            ? contextLength * 4 + TOP_K * 4 + 4
            : 0,
      },
    };
    rows.push(row);
    const suffix = endToEndTiming
      ? `, score+top-k ${endToEndTiming.median_ms.toFixed(3)} ms`
      : ", dense boundary (production skips score/top-k)";
    console.log(
      `${contextLength}: score ${scoreTiming.median_ms.toFixed(3)} ms${suffix}`,
    );
  } finally {
    query.dispose();
    keys.dispose();
    weights.dispose();
  }
}

const report = {
  schema_version: 1,
  gate: "GLM-5.2 DSA production-shaped model-free indexer",
  result: "pass",
  geometry: {
    heads: HEADS,
    head_dim: HEAD_DIM,
    top_k: TOP_K,
    score_formula: "weighted ReLU([H,D] @ [D,L])",
    selection_contract:
      "score descending / lower position tie; above-threshold scan then threshold-tie scan",
  },
  measurement: {
    repeats,
    warmups: 2,
    timing: "warm synchronized wall time; model-free component only",
  },
  rows,
};

const output = cli.get("output");
if (output) {
  const path = resolve(output);
  mkdirSync(dirname(path), { recursive: true });
  await Bun.write(path, JSON.stringify(report, null, 2) + "\n");
}
