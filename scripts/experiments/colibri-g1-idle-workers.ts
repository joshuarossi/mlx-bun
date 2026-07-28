#!/usr/bin/env bun

/**
 * G1 passive-worker power probe.
 *
 * Opens the native positioned-read pool without submitting work, prints a
 * machine-readable ready record, waits for the requested sampling window, and
 * closes it. Pair the window with headless mactop samples. Any material CPU or
 * package-power delta over the no-worker baseline is a busy-spin failure.
 */

import { resolve } from "node:path";
import { ExpertIOSlabStore } from "../../src/expert-io";

function argumentsMap(argv: string[]): Map<string, string> {
  const out = new Map<string, string>();
  for (let index = 0; index < argv.length; index += 2) {
    const key = argv[index];
    const value = argv[index + 1];
    if (!key?.startsWith("--") || value === undefined) {
      throw new Error(
        "usage: colibri-g1-idle-workers.ts " +
        "--library DYLIB --file FILE --workers N --seconds N",
      );
    }
    out.set(key.slice(2), value);
  }
  return out;
}

function positiveInteger(value: string | undefined, label: string): number {
  const parsed = Number(value);
  if (!Number.isSafeInteger(parsed) || parsed < 1)
    throw new RangeError(`${label} must be a positive integer`);
  return parsed;
}

const cli = argumentsMap(Bun.argv.slice(2));
const libraryPath = resolve(cli.get("library") ?? "");
const file = resolve(cli.get("file") ?? "");
if (!cli.get("library") || !cli.get("file"))
  throw new Error("--library and --file are required");
const workers = positiveInteger(cli.get("workers"), "--workers");
const seconds = positiveInteger(cli.get("seconds"), "--seconds");

const store = new ExpertIOSlabStore([file], {
  slots: 1,
  slotBytes: 16 * 1024,
  workers,
  libraryPath,
});
try {
  console.log(JSON.stringify({
    phase: "ready",
    pid: process.pid,
    workers,
    seconds,
    physicalFootprintBytes: store.physicalFootprint(),
  }));
  await Bun.sleep(seconds * 1000);
  console.log(JSON.stringify({
    phase: "complete",
    pid: process.pid,
    workers,
    physicalFootprintBytes: store.physicalFootprint(),
  }));
} finally {
  store.close();
}
