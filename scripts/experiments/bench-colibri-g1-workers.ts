#!/usr/bin/env bun

/**
 * Reproducible G1 passive-worker power matrix.
 *
 * Runs a matched no-worker baseline and idle native worker pools while mactop
 * records CPU/GPU/package power. The first two samples of each arm are kept in
 * the raw report but excluded from the median summary.
 */

import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { loadavg } from "node:os";

interface MactopSample {
  readonly timestamp: string;
  readonly cpu_usage: number;
  readonly soc_metrics: {
    readonly cpu_power: number;
    readonly gpu_power: number;
    readonly system_power: number;
    readonly total_power: number;
    readonly gpu_active: number;
  };
}

function args(argv: readonly string[]): Map<string, string> {
  const values = new Map<string, string>();
  for (let index = 0; index < argv.length; index += 2) {
    const key = argv[index];
    const value = argv[index + 1];
    if (!key?.startsWith("--") || value === undefined)
      throw new Error(
        "usage: bench-colibri-g1-workers.ts --library DYLIB --file FILE " +
        "--output JSON --confirm-quiet yes [--workers 1,2,4] " +
        "[--samples 10] [--interval-ms 1000]",
      );
    values.set(key.slice(2), value);
  }
  return values;
}

function positiveInteger(value: string, label: string): number {
  const parsed = Number(value);
  if (!Number.isSafeInteger(parsed) || parsed < 1)
    throw new RangeError(`${label} must be a positive integer`);
  return parsed;
}

function command(command: readonly string[]): string {
  const result = Bun.spawnSync([...command], {
    stdout: "pipe",
    stderr: "pipe",
  });
  if (result.exitCode !== 0)
    throw new Error(
      `${command.join(" ")} failed: ` +
      new TextDecoder().decode(result.stderr),
    );
  return new TextDecoder().decode(result.stdout).trim();
}

function median(values: readonly number[]): number {
  const sorted = [...values].sort((left, right) => left - right);
  const middle = Math.floor(sorted.length / 2);
  return sorted.length % 2
    ? sorted[middle]!
    : (sorted[middle - 1]! + sorted[middle]!) / 2;
}

function summarize(samples: readonly MactopSample[]) {
  const measured = samples.slice(2);
  if (measured.length < 3)
    throw new Error("at least five mactop samples are required");
  const metric = (read: (sample: MactopSample) => number) =>
    median(measured.map(read));
  return {
    rawSamples: samples.length,
    measuredSamples: measured.length,
    cpuUsagePercent: metric((sample) => sample.cpu_usage),
    cpuPowerW: metric((sample) => sample.soc_metrics.cpu_power),
    gpuPowerW: metric((sample) => sample.soc_metrics.gpu_power),
    systemPowerW: metric((sample) => sample.soc_metrics.system_power),
    totalPowerW: metric((sample) => sample.soc_metrics.total_power),
    gpuActivePercent: metric((sample) => sample.soc_metrics.gpu_active),
  };
}

async function sampleMactop(
  count: number,
  intervalMs: number,
): Promise<MactopSample[]> {
  const child = Bun.spawn([
    "mactop",
    "--headless",
    "--format",
    "json",
    "--count",
    String(count),
    "--interval",
    String(intervalMs),
  ], {
    stdout: "pipe",
    stderr: "pipe",
  });
  const [stdout, stderr, exitCode] = await Promise.all([
    new Response(child.stdout).text(),
    new Response(child.stderr).text(),
    child.exited,
  ]);
  if (exitCode !== 0)
    throw new Error(`mactop failed (${exitCode}): ${stderr}`);
  const parsed = JSON.parse(stdout);
  if (!Array.isArray(parsed) || parsed.length !== count)
    throw new Error(`mactop returned ${parsed?.length ?? "invalid"} samples`);
  return parsed as MactopSample[];
}

const values = args(Bun.argv.slice(2));
if (values.get("confirm-quiet") !== "yes")
  throw new Error("refusing power matrix without --confirm-quiet yes");
const required = (name: string): string => {
  const value = values.get(name);
  if (!value) throw new Error(`--${name} is required`);
  return resolve(value);
};
const library = required("library");
const file = required("file");
const output = required("output");
const samples = positiveInteger(values.get("samples") ?? "10", "--samples");
const intervalMs = positiveInteger(
  values.get("interval-ms") ?? "1000",
  "--interval-ms",
);
const workers = (values.get("workers") ?? "1,2,4")
  .split(",")
  .map((value) => positiveInteger(value, "--workers"));
const existingMactop = Bun.spawnSync(["pgrep", "-x", "mactop"], {
  stdout: "pipe",
  stderr: "pipe",
});
if (existingMactop.exitCode === 0) {
  throw new Error("another mactop process is already running");
}
if (existingMactop.exitCode !== 1)
  throw new Error("could not determine whether mactop is already running");

const sha256 = (path: string) =>
  createHash("sha256").update(readFileSync(path)).digest("hex");
const report: Record<string, unknown> = {
  schemaVersion: 1,
  kind: "colibri_g1_passive_worker_power_matrix",
  date: new Date().toISOString(),
  commit: command(["git", "rev-parse", "HEAD"]),
  machine: {
    hardware: command(["sysctl", "-n", "hw.model"]),
    memoryBytes: command(["sysctl", "-n", "hw.memsize"]),
    os: command(["sw_vers", "-productVersion"]),
    bun: Bun.version,
    loadAverageAtStart: loadavg(),
    powerSource: command(["pmset", "-g", "batt"]),
    swapBefore: command(["sysctl", "-n", "vm.swapusage"]),
  },
  input: {
    library,
    librarySha256: sha256(library),
    file,
    samples,
    discardedWarmupSamples: 2,
    intervalMs,
  },
  arms: [],
};

const arms = report.arms as Array<Record<string, unknown>>;
const runArm = async (workerCount: number | null) => {
  let probe: {
    stdout: ReadableStream<Uint8Array>;
    stderr: ReadableStream<Uint8Array>;
    exited: Promise<number>;
  } | null = null;
  if (workerCount !== null) {
    const seconds = Math.ceil(samples * intervalMs / 1000) + 8;
    const spawned = Bun.spawn([
      process.execPath,
      resolve(import.meta.dir, "colibri-g1-idle-workers.ts"),
      "--library",
      library,
      "--file",
      file,
      "--workers",
      String(workerCount),
      "--seconds",
      String(seconds),
    ], {
      stdout: "pipe",
      stderr: "pipe",
    });
    probe = {
      stdout: spawned.stdout,
      stderr: spawned.stderr,
      exited: spawned.exited,
    };
    await Bun.sleep(1000);
  }
  const raw = await sampleMactop(samples, intervalMs);
  let probeOutput: string | null = null;
  if (probe) {
    const [stdout, stderr, exitCode] = await Promise.all([
      new Response(probe.stdout).text(),
      new Response(probe.stderr).text(),
      probe.exited,
    ]);
    if (exitCode !== 0)
      throw new Error(`worker probe failed (${exitCode}): ${stderr}`);
    probeOutput = stdout.trim();
  }
  const arm = {
    workers: workerCount,
    summary: summarize(raw),
    raw,
    probeOutput,
  };
  arms.push(arm);
  console.log(JSON.stringify({
    workers: workerCount ?? 0,
    ...arm.summary,
  }));
};

await runArm(null);
for (const workerCount of workers) await runArm(workerCount);
(report.machine as Record<string, unknown>).swapAfter =
  command(["sysctl", "-n", "vm.swapusage"]);
await Bun.write(output, `${JSON.stringify(report, null, 2)}\n`);
console.log(`wrote ${output}`);
