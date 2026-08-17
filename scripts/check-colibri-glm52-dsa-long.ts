#!/usr/bin/env bun

/** Reduce the Stage-0 long-context DSA capture into an explicit parity gate. */

import { mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { MlxArray } from "../src/mlx/array";
import {
  Glm52DsaSelectionState,
  selectGlm52DsaDevice,
} from "../src/model/glm52-dsa";

type SelectionTrace = {
  layer: number;
  ownerLayer: number;
  contextLength: number;
  threshold: number;
  positions: number[];
};

function argumentsMap(argv: string[]): Map<string, string> {
  const out = new Map<string, string>();
  for (let index = 0; index < argv.length; index += 2) {
    const key = argv[index];
    const value = argv[index + 1];
    if (!key?.startsWith("--") || value === undefined) {
      throw new Error(
        "usage: check-colibri-glm52-dsa-long.ts " +
        "--mlx-report FILE --mlx-logits FILE --colibri-selections FILE " +
        "--colibri-scores FILE --colibri-logits FILE " +
        "--colibri-tokens FILE --output FILE",
      );
    }
    out.set(key.slice(2), value);
  }
  return out;
}

function required(values: Map<string, string>, key: string): string {
  const value = values.get(key);
  if (!value) throw new Error(`missing --${key}`);
  return resolve(value);
}

async function readF32(path: string): Promise<Float32Array> {
  const bytes = await Bun.file(path).bytes();
  if (bytes.byteLength % 4 !== 0)
    throw new Error(`${path}: byte length is not float32-aligned`);
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  return Float32Array.from(
    { length: bytes.byteLength / 4 },
    (_, index) => view.getFloat32(index * 4, true),
  );
}

async function readScoreRows(
  path: string,
): Promise<Array<{ layer: number; scores: Float32Array }>> {
  const bytes = await Bun.file(path).bytes();
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  const rows: Array<{ layer: number; scores: Float32Array }> = [];
  let offset = 0;
  while (offset < bytes.byteLength) {
    if (bytes.byteLength - offset < 8)
      throw new Error(`${path}: truncated score-row header`);
    const layer = view.getInt32(offset, true);
    const length = view.getInt32(offset + 4, true);
    offset += 8;
    if (length < 1 || bytes.byteLength - offset < length * 4)
      throw new Error(`${path}: invalid score-row length ${length}`);
    const scores = Float32Array.from(
      { length },
      (_, index) => view.getFloat32(offset + index * 4, true),
    );
    offset += length * 4;
    rows.push({ layer, scores });
  }
  return rows;
}

function prediction(values: Float32Array): {
  token: number;
  value: number;
  margin: number;
} {
  let token = 0;
  let first = values[0]!;
  let second = Number.NEGATIVE_INFINITY;
  for (let index = 1; index < values.length; index++) {
    const value = values[index]!;
    if (value > first) {
      second = first;
      first = value;
      token = index;
    } else if (value > second) {
      second = value;
    }
  }
  return { token, value: first, margin: first - second };
}

function sameNumbers(a: readonly number[], b: readonly number[]): boolean {
  return a.length === b.length && a.every((value, index) => value === b[index]);
}

const cli = argumentsMap(Bun.argv.slice(2));
const mlxReportPath = required(cli, "mlx-report");
const mlxLogitsPath = required(cli, "mlx-logits");
const selectionPath = required(cli, "colibri-selections");
const scorePath = required(cli, "colibri-scores");
const colibriLogitsPath = required(cli, "colibri-logits");
const tokenPath = required(cli, "colibri-tokens");
const output = required(cli, "output");

const mlxReport = JSON.parse(await Bun.file(mlxReportPath).text());
const traces = (await Bun.file(selectionPath).text())
  .trim()
  .split(/\r?\n/)
  .filter(Boolean)
  .map((line) => JSON.parse(line) as SelectionTrace);
const traceByLayer = new Map(traces.map((trace) => [trace.layer, trace]));
if (traceByLayer.size !== traces.length)
  throw new Error("Colibri selection trace contains duplicate layers");

const scoreRows = await readScoreRows(scorePath);
const topK = Number(mlxReport.scope?.prefix_tokens);
if (!Number.isSafeInteger(topK) || topK < 1)
  throw new Error("mlx-bun report has no valid prefix_tokens/topK");

const replayRows = scoreRows.map(({ layer, scores }) => {
  const trace = traceByLayer.get(layer);
  if (!trace) throw new Error(`score row has no selection trace for layer ${layer}`);
  const replay = new Glm52DsaSelectionState(topK).selectFull(layer, scores);
  if (replay.mode !== "sparse")
    throw new Error(`score row ${layer} unexpectedly replayed as dense`);
  const sorted = Array.from(scores).sort((a, b) => b - a);
  const boundaryGap = sorted[topK - 1]! - sorted[topK]!;
  const scoreArray = MlxArray.fromFloat32(scores, [scores.length]);
  const device = selectGlm52DsaDevice(scoreArray, topK);
  const devicePositions = device.positions.toIntTokens();
  const deviceThreshold = device.threshold.toFloat32()[0]!;
  device.dispose();
  scoreArray.dispose();
  return {
    layer,
    context_length: scores.length,
    boundary_gap: boundaryGap,
    tie_free: boundaryGap > 0,
    positions_exact: sameNumbers(replay.positions, trace.positions),
    threshold_exact_f32: replay.threshold === Math.fround(trace.threshold),
    device_positions_exact: sameNumbers(devicePositions, trace.positions),
    device_threshold_exact_f32:
      deviceThreshold === Math.fround(trace.threshold),
  };
});

const mlxSelections = new Map<number, SelectionTrace>(
  (mlxReport.dsa?.sparse_decode ?? []).map(
    (selection: SelectionTrace) => [selection.layer, selection],
  ),
);
const runtimeRows = traces.map((trace) => {
  const mlx = mlxSelections.get(trace.layer);
  if (!mlx) throw new Error(`mlx-bun report has no selection for layer ${trace.layer}`);
  const mlxSet = new Set(mlx.positions);
  const colibriSet = new Set(trace.positions);
  return {
    layer: trace.layer,
    ordered_exact: sameNumbers(mlx.positions, trace.positions),
    set_exact:
      mlxSet.size === colibriSet.size &&
      [...mlxSet].every((position) => colibriSet.has(position)),
    only_mlx: [...mlxSet].filter((position) => !colibriSet.has(position)),
    only_colibri: [...colibriSet].filter((position) => !mlxSet.has(position)),
    threshold_abs_diff: Math.abs(mlx.threshold - trace.threshold),
  };
});

const mlxLogits = await readF32(mlxLogitsPath);
const colibriLogits = await readF32(colibriLogitsPath);
if (mlxLogits.length !== colibriLogits.length)
  throw new Error("mlx-bun and Colibri logit vectors have different lengths");
let maxAbsolute = 0;
let maxAbsoluteToken = -1;
let absoluteSum = 0;
let squaredSum = 0;
let dot = 0;
let mlxSquared = 0;
let colibriSquared = 0;
for (let token = 0; token < mlxLogits.length; token++) {
  const mlx = mlxLogits[token]!;
  const colibri = colibriLogits[token]!;
  const absolute = Math.abs(mlx - colibri);
  if (absolute > maxAbsolute) {
    maxAbsolute = absolute;
    maxAbsoluteToken = token;
  }
  absoluteSum += absolute;
  squaredSum += absolute * absolute;
  dot += mlx * colibri;
  mlxSquared += mlx * mlx;
  colibriSquared += colibri * colibri;
}

const colibriTokens = (await Bun.file(tokenPath).text())
  .trim()
  .split(/\s+/)
  .filter(Boolean)
  .map(Number);
const mlxTokens = mlxReport.trajectory?.greedy_token_ids as number[];
const mlxPrediction = prediction(mlxLogits);
const colibriPrediction = prediction(colibriLogits);
const replayExact = replayRows.every(
  (row) => row.tie_free && row.positions_exact && row.threshold_exact_f32 &&
    row.device_positions_exact && row.device_threshold_exact_f32,
);
const tokensExact = sameNumbers(mlxTokens, colibriTokens);
const top1Exact = mlxPrediction.token === colibriPrediction.token;

const result = {
  schema_version: 1,
  gate: "GLM-5.2 DSA first-sparse official-score replay",
  result: replayExact && tokensExact && top1Exact ? "pass" : "fail",
  inputs: {
    mlx_report: mlxReportPath,
    mlx_logits_f32le: mlxLogitsPath,
    colibri_selections: selectionPath,
    colibri_scores_f32le: scorePath,
    colibri_logits_f32le: colibriLogitsPath,
    colibri_tokens: tokenPath,
  },
  dsa_score_replay: {
    records: replayRows.length,
    exact_records: replayRows.filter(
      (row) => row.positions_exact && row.threshold_exact_f32,
    ).length,
    device_exact_records: replayRows.filter(
      (row) => row.device_positions_exact && row.device_threshold_exact_f32,
    ).length,
    tie_free_records: replayRows.filter((row) => row.tie_free).length,
    minimum_boundary_gap: Math.min(...replayRows.map((row) => row.boundary_gap)),
    rows: replayRows,
  },
  full_runtime: {
    note:
      "Selection drift here includes the runtimes' different quantized-matmul accumulation before DSA; the official-score replay above isolates the selector.",
    ordered_exact_layers: runtimeRows.filter((row) => row.ordered_exact).length,
    set_exact_layers: runtimeRows.filter((row) => row.set_exact).length,
    rows: runtimeRows,
    greedy_tokens: { mlx_bun: mlxTokens, colibri: colibriTokens, exact: tokensExact },
    logits: {
      count: mlxLogits.length,
      top1_exact: top1Exact,
      mlx_bun: mlxPrediction,
      colibri: colibriPrediction,
      max_absolute: maxAbsolute,
      max_absolute_token: maxAbsoluteToken,
      mean_absolute: absoluteSum / mlxLogits.length,
      rmse: Math.sqrt(squaredSum / mlxLogits.length),
      cosine: dot / Math.sqrt(mlxSquared * colibriSquared),
    },
  },
};

mkdirSync(dirname(output), { recursive: true });
await Bun.write(output, JSON.stringify(result, null, 2) + "\n");
if (result.result !== "pass") process.exitCode = 1;
