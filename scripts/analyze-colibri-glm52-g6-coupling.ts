#!/usr/bin/env bun

/** Held-out evaluator for Colibri-style cross-layer route coactivation. */

import { mkdirSync, readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import {
  buildGlm52CouplingModel,
  evaluateGlm52Coupling,
  splitGlm52RouteTrace,
  type Glm52RouteTraceRecord,
} from "../src/model/glm52-coupling";

function argumentsMap(argv: string[]): Map<string, string> {
  const values = new Map<string, string>();
  for (let index = 0; index < argv.length; index += 2) {
    const key = argv[index];
    const value = argv[index + 1];
    if (!key?.startsWith("--") || value === undefined) {
      throw new Error(
        "usage: analyze-colibri-glm52-g6-coupling.ts " +
        "--input TRACE.jsonl --output REPORT.json [--segment cold] " +
        "[--train-fraction 0.7 --budgets 4,8,16,32 " +
        "--max-candidates 16]",
      );
    }
    values.set(key.slice(2), value);
  }
  return values;
}

function required(values: Map<string, string>, key: string): string {
  const value = values.get(key);
  if (!value) throw new Error(`missing --${key}`);
  return resolve(value);
}

function readTrace(path: string): Glm52RouteTraceRecord[] {
  return readFileSync(path, "utf8")
    .split(/\r?\n/)
    .filter(Boolean)
    .map((line, index) => {
      try {
        return JSON.parse(line) as Glm52RouteTraceRecord;
      } catch (error) {
        throw new Error(`${path}:${index + 1}: ${String(error)}`);
      }
    });
}

const cli = argumentsMap(Bun.argv.slice(2));
const input = required(cli, "input");
const output = required(cli, "output");
const trainFraction = Number(cli.get("train-fraction") ?? "0.7");
const maxCandidates = Number(cli.get("max-candidates") ?? "16");
const budgets = (cli.get("budgets") ?? "4,8,16,32")
  .split(",")
  .map(Number);
const records = readTrace(input);
const split = splitGlm52RouteTrace(records, {
  segment: cli.get("segment"),
  trainFraction,
});
const model = buildGlm52CouplingModel(split.train, maxCandidates);
const evaluations = evaluateGlm52Coupling(model, split.test, budgets);
const report = {
  schemaVersion: 1 as const,
  gate: "G6 route coupling held-out measurement" as const,
  policy: {
    valuePreserving: true,
    runtimeBackfill: false,
    deltas: [1, 2],
    trainFraction,
    maxCandidates,
    budgets,
  },
  trace: {
    input,
    segment: split.segment,
    records: records.length,
    trainPositions: split.trainPositions,
    testPositions: split.testPositions,
    trainRecords: split.train.length,
    testRecords: split.test.length,
  },
  model: {
    couplingEntries: model.entries.length,
    marginalLayers: model.marginals.length,
  },
  evaluations,
};
mkdirSync(dirname(output), { recursive: true });
await Bun.write(output, `${JSON.stringify(report, null, 2)}\n`);
console.log(
  `G6 coupling: ${split.trainPositions} train / ` +
  `${split.testPositions} held-out positions; ${model.entries.length} entries`,
);
