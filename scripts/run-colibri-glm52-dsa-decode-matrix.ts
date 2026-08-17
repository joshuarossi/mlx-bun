#!/usr/bin/env bun

/** Orchestrate fresh-process Stage-2 cells and enforce token determinism. */

import { existsSync, mkdirSync, readFileSync } from "node:fs";
import { loadavg } from "node:os";
import { join, resolve } from "node:path";
import {
  GLM52_G5_DEFAULT_MACHINE_BYTES,
  GLM52_G5_DEFAULT_PROCESS_LIMIT_BYTES,
  planGlm52MemoryForArtifact,
} from "../src/model/glm52-memory";
import { parseSwapUsage, parseVmStat } from "./lib/g3-live-guard";

type Toggle = "on" | "off";

interface CellReport {
  readonly result: string;
  readonly cell: {
    readonly contextTokens: number;
    readonly dsa: Toggle;
    readonly mtp: Toggle;
    readonly repeat: number;
    readonly maxTokens: number;
  };
  readonly turns: ReadonlyArray<{
    readonly name: "cold" | "warm";
    readonly tokenIds: readonly number[];
    readonly timing: {
      readonly decodeTps: number;
      readonly prefillMs: number;
      readonly wallMs: number;
    };
  }>;
}

interface IneligibleCell {
  readonly contextTokens: number;
  readonly dsa: Toggle;
  readonly mtp: Toggle;
  readonly repeat: number;
  readonly reason: "g5-process-limit";
  readonly plannedProcessBytes: number;
  readonly processLimitBytes: number;
  readonly overageBytes: number;
}

function argumentsMap(argv: string[]): Map<string, string> {
  const out = new Map<string, string>();
  for (let index = 0; index < argv.length; index += 2) {
    const key = argv[index];
    const value = argv[index + 1];
    if (!key?.startsWith("--") || value === undefined) {
      throw new Error(
        "usage: run-colibri-glm52-dsa-decode-matrix.ts " +
        "--model DIR --library DYLIB --output-dir DIR " +
        "[--contexts 2048,8192,32768 --repeats 3 --max-tokens 16 " +
        "--require-quiet 1]",
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

function positiveInteger(value: string, label: string): number {
  const parsed = Number(value);
  if (!Number.isSafeInteger(parsed) || parsed < 1)
    throw new Error(`${label} must be a positive integer`);
  return parsed;
}

function command(command: readonly string[]): string {
  const result = Bun.spawnSync([...command], { stdout: "pipe", stderr: "pipe" });
  if (result.exitCode !== 0)
    throw new Error(new TextDecoder().decode(result.stderr));
  return new TextDecoder().decode(result.stdout);
}

function environment() {
  const top = command(["/usr/bin/top", "-l", "2", "-n", "0", "-s", "1"]);
  const cpuLines = [...top.matchAll(/CPU usage:.*$/gm)];
  const cpu = cpuLines.at(-1)?.[0] ?? "unavailable";
  const idleMatch = cpu.match(/([0-9.]+)% idle/);
  return {
    at: new Date().toISOString(),
    osLoadAverage: loadavg(),
    cpu,
    cpuIdlePercent: idleMatch ? Number(idleMatch[1]) : null,
    swapUsage: parseSwapUsage(
      command(["/usr/sbin/sysctl", "-n", "vm.swapusage"]),
    ),
    vm: parseVmStat(command(["/usr/bin/vm_stat"])),
  };
}

function exact(
  actual: readonly number[],
  expected: readonly number[],
  label: string,
): void {
  const mismatch = actual.findIndex((token, index) => token !== expected[index]);
  if (actual.length !== expected.length || mismatch >= 0) {
    const index = mismatch >= 0 ? mismatch : Math.min(actual.length, expected.length);
    throw new Error(
      `${label} mismatch at ${index}: ` +
      `${actual[index] ?? "<missing>"} != ${expected[index] ?? "<end>"}`,
    );
  }
}

function median(values: readonly number[]): number {
  const sorted = [...values].sort((a, b) => a - b);
  const middle = Math.floor(sorted.length / 2);
  return sorted.length % 2
    ? sorted[middle]!
    : (sorted[middle - 1]! + sorted[middle]!) / 2;
}

const cli = argumentsMap(Bun.argv.slice(2));
const modelDir = required(cli, "model");
const libraryPath = required(cli, "library");
const outputDir = required(cli, "output-dir");
const contexts = (cli.get("contexts") ?? "2048,8192,32768")
  .split(",")
  .map((value) => positiveInteger(value, "--contexts"));
const repeats = positiveInteger(cli.get("repeats") ?? "3", "--repeats");
const maxTokens = positiveInteger(cli.get("max-tokens") ?? "16", "--max-tokens");
const requireQuiet = (cli.get("require-quiet") ?? "1") === "1";
const draftTokens = 3;
mkdirSync(outputDir, { recursive: true });

const before = environment();
if (requireQuiet && (
  before.cpuIdlePercent === null ||
  before.cpuIdlePercent < 85 ||
  before.osLoadAverage[0]! > 3
)) {
  throw new Error(
    "Stage-2 performance matrix requires a quiet machine: " +
    `${before.cpu}; load ${before.osLoadAverage.map((v) => v.toFixed(2)).join("/")}`,
  );
}

const arms: ReadonlyArray<readonly [Toggle, Toggle]> = [
  ["off", "off"],
  ["on", "off"],
  ["off", "on"],
  ["on", "on"],
];
const reports: CellReport[] = [];
const ineligibleCells: IneligibleCell[] = [];
let primaryError: unknown = null;

const eligibility = new Map<string, {
  readonly plannedProcessBytes: number;
  readonly processLimitBytes: number;
  readonly eligible: boolean;
}>();
for (const context of contexts) {
  for (const mtp of ["off", "on"] as const) {
    // Ask the same planner for its full line-item total using the physical
    // machine size as a diagnostic ceiling. Eligibility still uses G5's
    // stricter 25 GiB process ceiling; this must not silently weaken it.
    const plan = await planGlm52MemoryForArtifact(modelDir, {
      contextTokens: context + maxTokens + draftTokens + 1,
      maxGenerationTokens: maxTokens,
      enableMtp: mtp === "on",
      mtpDraftTokens: draftTokens,
      processLimitBytes: GLM52_G5_DEFAULT_MACHINE_BYTES,
    });
    eligibility.set(`${context}:${mtp}`, {
      plannedProcessBytes: plan.plannedProcessBytes,
      processLimitBytes: GLM52_G5_DEFAULT_PROCESS_LIMIT_BYTES,
      eligible: plan.plannedProcessBytes <= GLM52_G5_DEFAULT_PROCESS_LIMIT_BYTES,
    });
  }
}

try {
  for (const context of contexts) {
    for (let repeat = 1; repeat <= repeats; repeat++) {
      // Rotate arm order across repeats so persistent OS file-cache warmth is
      // not assigned to the same arm every time.
      const rotated = arms.map((_, index) => arms[(index + repeat - 1) % arms.length]!);
      for (const [dsa, mtp] of rotated) {
        const name = `context-${context}-dsa-${dsa}-mtp-${mtp}-r${repeat}`;
        const output = join(outputDir, `${name}.json`);
        console.log(`\n=== ${name} ===`);
        const cellEligibility = eligibility.get(`${context}:${mtp}`)!;
        if (!cellEligibility.eligible) {
          const ineligible: IneligibleCell = {
            contextTokens: context,
            dsa,
            mtp,
            repeat,
            reason: "g5-process-limit",
            plannedProcessBytes: cellEligibility.plannedProcessBytes,
            processLimitBytes: cellEligibility.processLimitBytes,
            overageBytes:
              cellEligibility.plannedProcessBytes - cellEligibility.processLimitBytes,
          };
          ineligibleCells.push(ineligible);
          console.log(
            `${name}: ineligible (${ineligible.plannedProcessBytes} planned > ` +
            `${ineligible.processLimitBytes} process limit)`,
          );
          await Bun.write(join(outputDir, "progress.json"), JSON.stringify({
            schemaVersion: 1,
            completedPlannedCells: reports.length + ineligibleCells.length,
            measuredCells: reports.length,
            ineligibleCells: ineligibleCells.length,
            lastCell: ineligible,
            updatedAt: new Date().toISOString(),
          }, null, 2) + "\n");
          continue;
        }
        let report: CellReport;
        if (existsSync(output)) {
          report = JSON.parse(readFileSync(output, "utf8")) as CellReport;
          if (
            report.result !== "pass" ||
            report.cell.contextTokens !== context ||
            report.cell.dsa !== dsa ||
            report.cell.mtp !== mtp ||
            report.cell.repeat !== repeat ||
            report.cell.maxTokens !== maxTokens
          ) {
            throw new Error(`${name} has an incompatible resumable artifact`);
          }
          console.log(`${name}: resumed passed artifact`);
        } else {
          const child = Bun.spawn([
            process.execPath,
            resolve(import.meta.dir, "probe-colibri-glm52-dsa-decode.ts"),
            "--model", modelDir,
            "--library", libraryPath,
            "--output", output,
            "--context", String(context),
            "--dsa", dsa,
            "--mtp", mtp,
            "--repeat", String(repeat),
            "--max-tokens", String(maxTokens),
          ], { stdout: "inherit", stderr: "inherit" });
          const exitCode = await child.exited;
          if (exitCode !== 0) throw new Error(`${name} exited ${exitCode}`);
          report = JSON.parse(readFileSync(output, "utf8")) as CellReport;
        }
        if (report.result !== "pass") throw new Error(`${name} did not pass`);
        reports.push(report);
        await Bun.write(join(outputDir, "progress.json"), JSON.stringify({
          schemaVersion: 1,
          completedPlannedCells: reports.length + ineligibleCells.length,
          measuredCells: reports.length,
          ineligibleCells: ineligibleCells.length,
          lastCell: report.cell,
          updatedAt: new Date().toISOString(),
        }, null, 2) + "\n");
      }
    }
  }

  const measuredContexts = contexts.filter((context) =>
    reports.some((report) => report.cell.contextTokens === context)
  );
  for (const context of measuredContexts) {
    for (const dsa of ["off", "on"] as const) {
      for (let repeat = 1; repeat <= repeats; repeat++) {
        const off = reports.find((report) =>
          report.cell.contextTokens === context && report.cell.dsa === dsa &&
          report.cell.mtp === "off" && report.cell.repeat === repeat
        )!;
        const on = reports.find((report) =>
          report.cell.contextTokens === context && report.cell.dsa === dsa &&
          report.cell.mtp === "on" && report.cell.repeat === repeat
        )!;
        for (const turn of [0, 1] as const) {
          exact(
            on.turns[turn]!.tokenIds,
            off.turns[turn]!.tokenIds,
            `context ${context} DSA ${dsa} repeat ${repeat} MTP parity`,
          );
        }
      }
    }
    for (const [dsa, mtp] of arms) {
      const matching = reports.filter((report) =>
        report.cell.contextTokens === context && report.cell.dsa === dsa &&
        report.cell.mtp === mtp
      );
      const baseline = matching[0]!.turns[1]!.tokenIds;
      for (const report of matching.slice(1)) {
        exact(
          report.turns[1]!.tokenIds,
          baseline,
          `context ${context} DSA ${dsa} MTP ${mtp} repeat parity`,
        );
      }
    }
  }

  const after = environment();
  const cells = measuredContexts.flatMap((context) => arms.map(([dsa, mtp]) => {
    const matching = reports.filter((report) =>
      report.cell.contextTokens === context && report.cell.dsa === dsa &&
      report.cell.mtp === mtp
    );
    return {
      contextTokens: context,
      dsa,
      mtp,
      repeats: matching.length,
      warmDecodeTps: matching.map((report) => report.turns[1]!.timing.decodeTps),
      medianWarmDecodeTps: median(
        matching.map((report) => report.turns[1]!.timing.decodeTps),
      ),
      warmPrefillMs: matching.map((report) => report.turns[1]!.timing.prefillMs),
      tokenIds: matching[0]!.turns[1]!.tokenIds,
    };
  }));
  const pairedComparisons = measuredContexts.flatMap((context) =>
    (["off", "on"] as const).map((mtp) => {
      const pairs = Array.from({ length: repeats }, (_, index) => {
        const repeat = index + 1;
        const off = reports.find((report) =>
          report.cell.contextTokens === context && report.cell.dsa === "off" &&
          report.cell.mtp === mtp && report.cell.repeat === repeat
        )!;
        const on = reports.find((report) =>
          report.cell.contextTokens === context && report.cell.dsa === "on" &&
          report.cell.mtp === mtp && report.cell.repeat === repeat
        )!;
        return {
          repeat,
          decodeDeltaPercent:
            (on.turns[1]!.timing.decodeTps / off.turns[1]!.timing.decodeTps - 1) * 100,
          wallDeltaPercent:
            (on.turns[1]!.timing.wallMs / off.turns[1]!.timing.wallMs - 1) * 100,
        };
      });
      return {
        contextTokens: context,
        mtp,
        pairedMedianDecodeDeltaPercent: median(
          pairs.map((pair) => pair.decodeDeltaPercent),
        ),
        pairedMedianWallDeltaPercent: median(
          pairs.map((pair) => pair.wallDeltaPercent),
        ),
        pairs,
      };
    })
  );
  const summary = {
    schemaVersion: 1,
    gate: "G6R Stage 2 DSA decode matrix",
    result: "pass",
    configuration: { contexts, repeats, maxTokens, requireQuiet },
    scope: {
      claim: "decode throughput and DSA/MTP counterfactuals",
      longPrefillPerformanceClaim: false,
      sparseLongPrefillDeferredToStage3: true,
    },
    environment: { before, after },
    plannedCells: contexts.length * arms.length * repeats,
    measuredCells: reports.length,
    ineligibleCellCount: ineligibleCells.length,
    eligibility: [...eligibility.entries()].map(([key, value]) => {
      const [contextTokens, mtp] = key.split(":");
      return { contextTokens: Number(contextTokens), mtp, ...value };
    }),
    ineligibleCells,
    cells,
    pairedComparisons,
    decision: {
      productPerformanceWin: false,
      preserveCheckpointSchedule: true,
      longPrefillPerformanceClaim: false,
      stage3RequiredForG6rClosure: false,
      reason:
        "8K MTP-on DSA regressed paired median decode and total wall time; " +
        "32K exceeded the unchanged G5 process ceiling",
    },
  };
  await Bun.write(
    join(outputDir, "summary.json"),
    JSON.stringify(summary, null, 2) + "\n",
  );
  console.log(
    `\nPASS: ${reports.length} measured cells; ` +
    `${ineligibleCells.length} contract-ineligible cells`,
  );
} catch (error) {
  primaryError = error;
  const after = environment();
  await Bun.write(join(outputDir, "summary-error.json"), JSON.stringify({
    schemaVersion: 1,
    gate: "G6R Stage 2 DSA decode matrix",
    result: "error",
    error: error instanceof Error ? error.message : String(error),
    completedCells: reports.length,
    environment: { before, after },
  }, null, 2) + "\n");
  throw error;
} finally {
  if (primaryError) console.error("Stage-2 matrix stopped before completion");
}
