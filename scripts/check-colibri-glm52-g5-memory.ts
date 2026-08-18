#!/usr/bin/env bun

import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import directTrace from "../fixtures/colibri-glm52/g4-direct-mtp-trace.json";
import {
  evaluateG5Pair,
  type G5LaneReport,
} from "./lib/g5-memory-contract";

function argumentsMap(argv: string[]): Map<string, string> {
  const out = new Map<string, string>();
  for (let index = 0; index < argv.length; index += 2) {
    const key = argv[index];
    const value = argv[index + 1];
    if (!key?.startsWith("--") || value === undefined) {
      throw new Error(
        "usage: check-colibri-glm52-g5-memory.ts " +
        "--on REPORT.json --off REPORT.json [--output SUMMARY.json]",
      );
    }
    out.set(key.slice(2), value);
  }
  return out;
}

function readReport(path: string): G5LaneReport {
  return JSON.parse(readFileSync(resolve(path), "utf8")) as G5LaneReport;
}

const cli = argumentsMap(Bun.argv.slice(2));
const onPath = cli.get("on");
const offPath = cli.get("off");
if (!onPath || !offPath) throw new Error("--on and --off are required");
const summary = evaluateG5Pair(
  readReport(onPath),
  readReport(offPath),
  directTrace.token_ids,
);
const result = {
  schemaVersion: 1,
  gate: "G5 paired 32 GB memory contract",
  result: summary.measurementMode === "strict"
    ? "pass"
    : "observed",
  onReport: resolve(onPath),
  offReport: resolve(offPath),
  ...summary,
};
const text = `${JSON.stringify(result, null, 2)}\n`;
const output = cli.get("output");
if (output) await Bun.write(resolve(output), text);
console.log(text.trimEnd());
