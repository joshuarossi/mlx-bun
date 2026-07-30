import {
  mkdtempSync,
  readFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { describe, expect, it } from "bun:test";
import {
  G5_FLAT_MEMORY_TOLERANCE_BYTES,
  G5_MAX_COMPRESSOR_GROWTH_BYTES,
  G5_MAX_PHYSICAL_FOOTPRINT_BYTES,
  G5MemoryContractError,
  G5MemoryMonitor,
  evaluateG5Pair,
  type G5EnvironmentSample,
  type G5LaneReport,
} from "../scripts/lib/g5-memory-contract";
import {
  parseSwapUsage,
  parseVmStat,
} from "../scripts/lib/g3-live-guard";

function sample(
  physicalFootprintBytes: number,
  swapouts: number,
  compressorPages: number,
): G5EnvironmentSample {
  return {
    vm: parseVmStat(`
Mach Virtual Memory Statistics: (page size of 16384 bytes)
Pageins: 1.
Pageouts: 2.
Swapins: 3.
Swapouts: ${swapouts}.
Pages occupied by compressor: ${compressorPages}.
Compressions: 20.
Decompressions: 10.
`),
    swapUsage: parseSwapUsage(
      "total = 2048.00M used = 0.00M free = 2048.00M",
    ),
    processRssBytes: 1,
    physicalFootprintBytes,
    mlxActiveBytes: 2,
    mlxCacheBytes: 3,
    mlxPeakBytes: 4,
    mainResidency: null,
    mtpResidency: null,
  };
}

describe("G5 memory monitor", () => {
  it("flushes samples and trips on footprint, swapout, or compressor growth", () => {
    const directory = mkdtempSync(join(tmpdir(), "g5-memory-"));
    const samples = [
      sample(100, 5, 10),
      sample(100, 5, 10),
      sample(199, 5, 11),
      sample(201, 5, 11),
    ];
    let now = 0;
    const monitor = new G5MemoryMonitor({
      tracePath: join(directory, "trace.jsonl"),
      maxPhysicalFootprintBytes: 200,
      maxCompressorGrowthBytes: 2 * 16_384,
      sample: () => samples.shift()!,
      now: () => now++,
    });
    expect(monitor.record({ phase: "periodic" }).violations).toEqual([]);
    expect(() => monitor.record({ phase: "periodic" }, true))
      .toThrow(G5MemoryContractError);
    expect(monitor.tripped?.physicalFootprintBytes).toBe(201);
    expect(readFileSync(monitor.tracePath, "utf8").trim().split("\n"))
      .toHaveLength(3);
  });
});

function lane(mode: "on" | "off"): G5LaneReport {
  const tokenIds = Array.from({ length: 128 }, (_, index) => index);
  return {
    schemaVersion: 1,
    gate: "G5 32 GB memory contract",
    mode,
    result: "pass",
    contract: {
      processLimitBytes: G5_MAX_PHYSICAL_FOOTPRINT_BYTES,
      maxCompressorGrowthBytes: G5_MAX_COMPRESSOR_GROWTH_BYTES,
      flatMemoryToleranceBytes: G5_FLAT_MEMORY_TOLERANCE_BYTES,
    },
    turns: [
      {
        name: "cold",
        tokenIds,
        timing: {
          prefillMs: 10,
          decodeMs: mode === "on" ? 100 : 125,
          decodeTps: mode === "on" ? 1.28 : 1.024,
          wallMs: 110,
          endToEndTps: mode === "on" ? 1.2 : 1,
        },
        finalPhysicalFootprintBytes: 20_000,
      },
      {
        name: "warm",
        tokenIds,
        timing: {
          prefillMs: 8,
          decodeMs: mode === "on" ? 80 : 100,
          decodeTps: mode === "on" ? 1.6 : 1.28,
          wallMs: 88,
          endToEndTps: mode === "on" ? 1.5 : 1.2,
        },
        finalPhysicalFootprintBytes: 20_010,
      },
    ],
    memory: {
      maxPhysicalFootprintBytes: 20_100,
      maxCompressorDeltaBytes: 0,
      swapoutDeltaBytes: 0,
    },
  };
}

describe("G5 pair evaluator", () => {
  it("requires 128-token cold/warm and MTP on/off identity", () => {
    const summary = evaluateG5Pair(
      lane("on"),
      lane("off"),
      [0, 1, 2, 3],
    );
    expect(summary).toMatchObject({
      tokenCount: 128,
      warmMtpSpeedup: 1.25,
      maxPhysicalFootprintBytes: 20_100,
    });
  });

  it("rejects output drift even when memory passes", () => {
    const off = lane("off");
    const changed = {
      ...off,
      turns: off.turns.map((turn, turnIndex) => ({
        ...turn,
        tokenIds: turn.tokenIds.map((token, index) =>
          turnIndex === 0 && index === 100 ? token + 1 : token),
      })),
    } as G5LaneReport;
    expect(() => evaluateG5Pair(lane("on"), changed, [0, 1, 2, 3]))
      .toThrow(/cold\/warm token mismatch/);
  });
});
