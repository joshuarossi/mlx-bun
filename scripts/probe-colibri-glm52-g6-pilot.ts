#!/usr/bin/env bun

/**
 * G6 measurement-only PILOT A/B. Both arms use plain LRU with native MTP on;
 * the candidate applies the next-layer router and records quality/timing but
 * never submits prefetch I/O or changes residency.
 */

import { existsSync, mkdirSync, readFileSync } from "node:fs";
import { join, resolve } from "node:path";

type Arm = "control" | "pilot-measure";

interface Cli {
  readonly model: string;
  readonly library: string;
  readonly outputDir: string;
  readonly memoryMode: "strict" | "observe";
  readonly repeats: number;
  readonly resume: boolean;
}

function parse(argv: string[]): Cli {
  const values = new Map<string, string>();
  for (let index = 0; index < argv.length; index += 2) {
    const key = argv[index];
    const value = argv[index + 1];
    if (!key?.startsWith("--") || value === undefined)
      throw new Error("G6 PILOT arguments must be --key value pairs");
    values.set(key.slice(2), value);
  }
  const required = (key: string): string => {
    const value = values.get(key);
    if (!value) throw new Error(`missing --${key}`);
    return resolve(value);
  };
  const memoryMode = values.get("memory-mode") ?? "observe";
  if (memoryMode !== "strict" && memoryMode !== "observe")
    throw new Error("--memory-mode must be strict or observe");
  const repeats = Number(values.get("repeats") ?? "1");
  if (!Number.isSafeInteger(repeats) || repeats < 1 || repeats > 10)
    throw new Error("--repeats must be an integer in 1..10");
  return {
    model: required("model"),
    library: required("library"),
    outputDir: required("output-dir"),
    memoryMode,
    repeats,
    resume: values.get("resume") === "1",
  };
}

function readJson(path: string): any {
  return JSON.parse(readFileSync(path, "utf8"));
}

function median(values: readonly number[]): number {
  if (!values.length) return 0;
  const sorted = values.slice().sort((left, right) => left - right);
  const middle = Math.floor(sorted.length / 2);
  return sorted.length % 2
    ? sorted[middle]!
    : (sorted[middle - 1]! + sorted[middle]!) / 2;
}

function ratio(numerator: number, denominator: number): number | null {
  return denominator === 0 ? null : numerator / denominator;
}

function assertExact(reports: readonly any[]): void {
  const expected = reports[0]?.turns?.[0]?.tokenIds;
  if (!Array.isArray(expected)) throw new Error("G6 PILOT report has no tokens");
  for (const report of reports) {
    for (const turn of report.turns ?? []) {
      if (JSON.stringify(turn.tokenIds) !== JSON.stringify(expected))
        throw new Error("measurement-only PILOT changed the emitted tokens");
    }
  }
}

const cli = parse(Bun.argv.slice(2));
mkdirSync(cli.outputDir, { recursive: true });
const laneScript = join(import.meta.dir, "probe-colibri-glm52-g5-memory.ts");

async function runLane(label: string, pilotMeasure: boolean): Promise<any> {
  let attempt = 1;
  let suffix = "";
  let output: string;
  let trace: string;
  while (true) {
    suffix = attempt === 1 ? "" : `-attempt-${attempt}`;
    output = join(cli.outputDir, `${label}${suffix}.json`);
    trace = join(cli.outputDir, `${label}${suffix}.jsonl`);
    if (!existsSync(output) && !existsSync(trace)) break;
    if (!cli.resume)
      throw new Error(`refusing to overwrite existing G6 PILOT arm ${label}`);
    if (existsSync(output)) {
      const prior = readJson(output);
      if (prior.result === "pass") {
        console.log(`G6 PILOT ${label}${suffix}: reusing completed lane`);
        return prior;
      }
    }
    attempt++;
  }
  console.log(`G6 PILOT ${label}${suffix}: starting MTP-on lane`);
  const child = Bun.spawn([
    process.execPath,
    laneScript,
    "--mode", "on",
    "--model", cli.model,
    "--library", cli.library,
    "--output", output,
    "--trace", trace,
    "--memory-mode", cli.memoryMode,
    "--pilot-measure", pilotMeasure ? "1" : "0",
  ], {
    stdout: "inherit",
    stderr: "inherit",
  });
  const exitCode = await child.exited;
  if (exitCode !== 0) throw new Error(`G6 PILOT ${label} exited ${exitCode}`);
  const report = readJson(output);
  if (report.result !== "pass")
    throw new Error(`G6 PILOT ${label} did not complete: ${report.result}`);
  return report;
}

function turnSummary(turn: any): Record<string, unknown> {
  return {
    endToEndTps: Number(turn.timing.endToEndTps),
    decodeTps: Number(turn.timing.decodeTps),
    wallMs: Number(turn.timing.wallMs),
    physicalFootprintBytes: Number(turn.finalPhysicalFootprintBytes),
    pilot: turn.expertTelemetry?.pilot ?? null,
  };
}

const reports: Array<{ arm: Arm; repeat: number; report: any }> = [];
for (let repeat = 1; repeat <= cli.repeats; repeat++) {
  const order: readonly Arm[] = repeat % 2 === 1
    ? ["control", "pilot-measure"]
    : ["pilot-measure", "control"];
  for (const arm of order) {
    reports.push({
      arm,
      repeat,
      report: await runLane(`${arm}-${repeat}`, arm === "pilot-measure"),
    });
  }
}

assertExact(reports.map((item) => item.report));
for (const item of reports) {
  const pilots = item.report.turns.map(
    (turn: any) => turn.expertTelemetry?.pilot ?? null,
  );
  if (item.arm === "control" && pilots.some(Boolean))
    throw new Error(`${item.arm}-${item.repeat} unexpectedly measured PILOT`);
  if (item.arm === "pilot-measure" &&
      pilots.some((pilot: any) => !pilot || pilot.predictionCalls < 1)) {
    throw new Error(`${item.arm}-${item.repeat} produced no PILOT predictions`);
  }
}

const arms = Object.fromEntries(
  (["control", "pilot-measure"] as const).map((arm) => {
    const runs = reports.filter((item) => item.arm === arm).map((item) => ({
      repeat: item.repeat,
      openMs: Number(item.report.runtime.openMs),
      cold: turnSummary(item.report.turns[0]),
      warm: turnSummary(item.report.turns[1]),
    }));
    const warmPilots = runs
      .map((run) => (run.warm as any).pilot)
      .filter(Boolean);
    const rankCount = warmPilots[0]?.rankHitRate?.length ?? 0;
    return [arm, {
      runs,
      medianOpenMs: median(runs.map((run) => run.openMs)),
      medianWarmTps: median(runs.map(
        (run) => Number((run.warm as any).endToEndTps),
      )),
      medianWarmPhysicalFootprintBytes: median(runs.map(
        (run) => Number((run.warm as any).physicalFootprintBytes),
      )),
      pilot: warmPilots.length ? {
        medianPrecision: median(warmPilots.map(
          (pilot: any) => Number(pilot.precision),
        )),
        medianRecall: median(warmPilots.map(
          (pilot: any) => Number(pilot.recall),
        )),
        medianExactRowRate: median(warmPilots.map(
          (pilot: any) => Number(pilot.exactRowRate),
        )),
        medianPredictionP95Ms: median(warmPilots.map(
          (pilot: any) => Number(pilot.predictionLatency.p95Ms),
        )),
        medianLeadP95Ms: median(warmPilots.map(
          (pilot: any) => Number(pilot.leadTime.p95Ms),
        )),
        medianRankHitRate: Array.from({ length: rankCount }, (_, rank) =>
          median(warmPilots.map(
            (pilot: any) => Number(pilot.rankHitRate[rank]),
          ))),
        medianPrefixPrecision: Array.from(
          { length: rankCount },
          (_, rank) => median(warmPilots.map((pilot: any) => {
            const prefix = pilot.rankHitRate.slice(0, rank + 1);
            return prefix.reduce(
              (sum: number, value: number) => sum + value,
              0,
            ) / prefix.length;
          })),
        ),
        medianPrefixRecall: Array.from(
          { length: rankCount },
          (_, rank) => median(warmPilots.map((pilot: any) =>
            pilot.rankHitRate.slice(0, rank + 1).reduce(
              (sum: number, value: number) => sum + value,
              0,
            ) / pilot.rankHitRate.length)),
        ),
      } : null,
    }];
  }),
);
const control = arms.control as any;
const pilot = arms["pilot-measure"] as any;
const summary = {
  schemaVersion: 1,
  gate: "G6 measurement-only PILOT paired A/B",
  result: "measured",
  replicationComplete: cli.repeats >= 3,
  contract: {
    mtp: "on",
    exactTokens: true,
    valuePreserving: true,
    prefetchIo: false,
    repeats: cli.repeats,
    memoryMode: cli.memoryMode,
  },
  arms,
  comparison: {
    warmTpsRatio: ratio(pilot.medianWarmTps, control.medianWarmTps),
    startupMsDelta: pilot.medianOpenMs - control.medianOpenMs,
    warmPhysicalFootprintBytesDelta:
      pilot.medianWarmPhysicalFootprintBytes -
      control.medianWarmPhysicalFootprintBytes,
  },
};
const summaryPath = join(cli.outputDir, "summary.json");
await Bun.write(summaryPath, `${JSON.stringify(summary, null, 2)}\n`);
console.log(`G6 measurement-only PILOT measured: ${summaryPath}`);
