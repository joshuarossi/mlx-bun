#!/usr/bin/env bun

/**
 * G6 paired learning-policy harness. A separate MTP-on seed process first
 * learns one fixed workload. Every measured control/candidate process starts
 * from an identical copy of that profile, preventing history drift from
 * masquerading as a placement win.
 */

import {
  copyFileSync,
  existsSync,
  mkdirSync,
  readFileSync,
} from "node:fs";
import { join, resolve } from "node:path";

type Arm = "control" | "auto-pin" | "live-lfru";

interface Cli {
  readonly model: string;
  readonly library: string;
  readonly outputDir: string;
  readonly memoryMode: "strict" | "observe";
  readonly repeats: number;
}

function parse(argv: string[]): Cli {
  const values = new Map<string, string>();
  for (let index = 0; index < argv.length; index += 2) {
    const key = argv[index];
    const value = argv[index + 1];
    if (!key?.startsWith("--") || value === undefined)
      throw new Error("G6 arguments must be --key value pairs");
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
  };
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

function readJson(path: string): any {
  return JSON.parse(readFileSync(path, "utf8"));
}

function ioBytes(tier: any, kind: "demand" | "policy"): number {
  return Number(tier?.[kind]?.readBytes ?? 0);
}

function summarizeTurn(turn: any): Record<string, unknown> {
  const main = turn.expertTelemetry?.main;
  const mtp = turn.expertTelemetry?.mtp;
  const hits = Number(main?.demand?.hits ?? 0) +
    Number(mtp?.demand?.hits ?? 0);
  const misses = Number(main?.demand?.misses ?? 0) +
    Number(mtp?.demand?.misses ?? 0);
  const demandReadBytes = ioBytes(main, "demand") + ioBytes(mtp, "demand");
  const policyReadBytes = ioBytes(main, "policy") + ioBytes(mtp, "policy");
  return {
    name: turn.name,
    wallMs: turn.timing.wallMs,
    endToEndTps: turn.timing.endToEndTps,
    decodeTps: turn.timing.decodeTps,
    hits,
    misses,
    hitRate: hits / Math.max(hits + misses, 1),
    demandReadBytes,
    policyReadBytes,
    totalReadBytes: demandReadBytes + policyReadBytes,
    diskGbPerToken:
      (demandReadBytes + policyReadBytes) / (128 * 1_000_000_000),
    mainDiskService: main?.demand?.diskService ?? null,
    mainForegroundWait: main?.demand?.foregroundWait ?? null,
    mainLayerForward: main?.layerForward ?? null,
    mtpDiskService: mtp?.demand?.diskService ?? null,
    mtpForegroundWait: mtp?.demand?.foregroundWait ?? null,
    mtpLayerForward: mtp?.layerForward ?? null,
    repin: turn.repin,
  };
}

function assertExact(reports: readonly any[]): void {
  const expected = reports[0]?.turns?.[0]?.tokenIds;
  if (!Array.isArray(expected)) throw new Error("G6 report has no token IDs");
  for (const report of reports) {
    for (const turn of report.turns ?? []) {
      if (JSON.stringify(turn.tokenIds) !== JSON.stringify(expected))
        throw new Error("G6 policy arm changed the emitted token trajectory");
    }
  }
}

const cli = parse(Bun.argv.slice(2));
mkdirSync(cli.outputDir, { recursive: true });
const laneScript = join(import.meta.dir, "probe-colibri-glm52-g5-memory.ts");

async function runLane(
  label: string,
  usagePath: string,
  autoPin: boolean,
  liveRepin: boolean,
): Promise<any> {
  const output = join(cli.outputDir, `${label}.json`);
  const trace = join(cli.outputDir, `${label}.jsonl`);
  if (existsSync(output) || existsSync(trace))
    throw new Error(`refusing to overwrite existing G6 arm ${label}`);
  console.log(`G6 ${label}: starting MTP-on lane`);
  const child = Bun.spawn([
    process.execPath,
    laneScript,
    "--mode", "on",
    "--model", cli.model,
    "--library", cli.library,
    "--output", output,
    "--trace", trace,
    "--memory-mode", cli.memoryMode,
    "--usage-path", usagePath,
    "--auto-pin", autoPin ? "1" : "0",
    "--live-repin", liveRepin ? "1" : "0",
  ], {
    stdout: "inherit",
    stderr: "inherit",
  });
  const exitCode = await child.exited;
  if (exitCode !== 0) throw new Error(`G6 ${label} exited ${exitCode}`);
  const report = readJson(output);
  if (report.result !== "pass")
    throw new Error(`G6 ${label} did not complete: ${report.result}`);
  return report;
}

const seedUsage = join(cli.outputDir, "seed.coli_usage");
const seedReport = await runLane("seed", seedUsage, false, false);
if (!existsSync(seedUsage)) throw new Error("G6 seed lane produced no usage profile");

const reports: Array<{ arm: Arm; repeat: number; report: any }> = [];
for (let repeat = 1; repeat <= cli.repeats; repeat++) {
  const order = ["control", "auto-pin", "live-lfru"] as const;
  const offset = (repeat - 1) % order.length;
  const balancedOrder = [...order.slice(offset), ...order.slice(0, offset)];
  for (const arm of balancedOrder) {
    const usagePath = join(cli.outputDir, `${arm}-${repeat}.coli_usage`);
    copyFileSync(seedUsage, usagePath);
    reports.push({
      arm,
      repeat,
      report: await runLane(
        `${arm}-${repeat}`,
        usagePath,
        arm !== "control",
        arm === "live-lfru",
      ),
    });
  }
}

assertExact([seedReport, ...reports.map((item) => item.report)]);
for (const item of reports) {
  if (item.arm !== "control" &&
      (item.report.runtime?.autoPin?.pins?.length ?? 0) === 0) {
    throw new Error(`${item.arm}-${item.repeat} selected no startup pins`);
  }
}

const arms = Object.fromEntries(
  (["control", "auto-pin", "live-lfru"] as const).map((arm) => {
    const armReports = reports.filter((item) => item.arm === arm);
    const summarized = armReports.map((item) => ({
      repeat: item.repeat,
      openMs: item.report.runtime.openMs,
      autoPin: item.report.runtime.autoPin,
      cold: summarizeTurn(item.report.turns[0]),
      warm: summarizeTurn(item.report.turns[1]),
    }));
    return [arm, {
      runs: summarized,
      medianOpenMs: median(summarized.map((item) => Number(item.openMs))),
      medianWarmTps: median(summarized.map(
        (item) => Number((item.warm as any).endToEndTps),
      )),
      medianWarmHitRate: median(summarized.map(
        (item) => Number((item.warm as any).hitRate),
      )),
      medianWarmDiskGbPerToken: median(summarized.map(
        (item) => Number((item.warm as any).diskGbPerToken),
      )),
    }];
  }),
);
const control = arms.control as any;
const auto = arms["auto-pin"] as any;
const live = arms["live-lfru"] as any;
const summary = {
  schemaVersion: 1,
  gate: "G6 learning residency paired A/B",
  result: "measured",
  defaultDecisionEligible: cli.repeats >= 3,
  contract: {
    mtp: "on",
    identicalSeedProfile: true,
    exactTokens: true,
    repeats: cli.repeats,
    memoryMode: cli.memoryMode,
  },
  seed: {
    report: "seed.json",
    selections: seedReport.runtime?.usage?.totalCount ?? null,
  },
  arms,
  comparisons: {
    autoPinVsControl: {
      warmTpsRatio: ratio(auto.medianWarmTps, control.medianWarmTps),
      warmHitRateDelta: auto.medianWarmHitRate - control.medianWarmHitRate,
      warmDiskGbPerTokenRatio:
        ratio(auto.medianWarmDiskGbPerToken, control.medianWarmDiskGbPerToken),
      startupMsDelta: auto.medianOpenMs - control.medianOpenMs,
    },
    liveLfruVsAutoPin: {
      warmTpsRatio: ratio(live.medianWarmTps, auto.medianWarmTps),
      warmHitRateDelta: live.medianWarmHitRate - auto.medianWarmHitRate,
      warmDiskGbPerTokenRatio:
        ratio(live.medianWarmDiskGbPerToken, auto.medianWarmDiskGbPerToken),
      startupMsDelta: live.medianOpenMs - auto.medianOpenMs,
    },
  },
};
await Bun.write(
  join(cli.outputDir, "summary.json"),
  `${JSON.stringify(summary, null, 2)}\n`,
);
console.log(`G6 learning A/B measured: ${join(cli.outputDir, "summary.json")}`);
