import {
  mkdtempSync,
  readFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { describe, expect, test } from "bun:test";
import {
  G3LiveGuard,
  G3SwapoutGuardError,
  parseSwapUsage,
  parseVmStat,
  type G3LiveEnvironmentSample,
} from "../scripts/lib/g3-live-guard";

const vm = (swapins: number, swapouts: number) => parseVmStat(`
Mach Virtual Memory Statistics: (page size of 16384 bytes)
Pageins: 123.
Pageouts: 45.
Swapins: ${swapins}.
Swapouts: ${swapouts}.
Pages occupied by compressor: 77.
Compressions: 88.
Decompressions: 66.
`);

const sample = (
  swapins: number,
  swapouts: number,
): G3LiveEnvironmentSample => ({
  vm: vm(swapins, swapouts),
  swapUsage: parseSwapUsage(
    "total = 2048.00M  used = 999.75M  free = 1048.25M  (encrypted)",
  ),
  processRssBytes: 10,
  physicalFootprintBytes: 11,
  mlxActiveBytes: 12,
  mlxCacheBytes: 13,
  mlxPeakBytes: 14,
  residency: {
    working: 8,
    resident: 75,
    pinned: 0,
    disabled: 0,
    loading: 0,
    leased: 0,
    hits: 1,
    misses: 8,
    evictions: 1,
    pressureEvictions: 0,
  },
});

describe("G3 live swap guard", () => {
  test("parses cumulative vm_stat and swap usage", () => {
    expect(vm(299950, 1232946)).toEqual({
      pageSizeBytes: 16384,
      pageins: 123,
      pageouts: 45,
      swapins: 299950,
      swapouts: 1232946,
      compressorPages: 77,
      compressions: 88,
      decompressions: 66,
    });
    expect(parseSwapUsage(
      "total = 2048.00M  used = 999.75M  free = 1048.25M  (encrypted)",
    )).toMatchObject({
      totalBytes: 2147483648,
      usedBytes: 1048313856,
      freeBytes: 1099169792,
    });
  });

  test("flushes checkpoints and refuses the next guarded boundary", () => {
    const directory = mkdtempSync(join(tmpdir(), "g3-live-guard-"));
    const tracePath = join(directory, "trace.jsonl");
    const samples = [
      sample(10, 20),
      sample(10, 20),
      sample(11, 21),
      sample(11, 24),
    ];
    let now = 100;
    const guard = new G3LiveGuard({
      tracePath,
      maxSwapoutDeltaBytes: 4 * 16384,
      sample: () => samples.shift()!,
      now: () => now++,
    });
    const below = guard.record({
      phase: "wave_released",
      layer: 3,
      wave: 0,
    });
    expect(below.swapoutDeltaBytes).toBe(16384);
    expect(below.guardTripped).toBeFalse();
    expect(() => guard.record({
      phase: "wave_before",
      layer: 4,
      wave: 0,
    }, true)).toThrow(G3SwapoutGuardError);
    expect(guard.tripped?.swapoutDeltaPages).toBe(4);
    const lines = readFileSync(tracePath, "utf8").trim().split("\n");
    expect(lines).toHaveLength(3);
    expect(JSON.parse(lines[2]!).guardTripped).toBeTrue();
  });
});
