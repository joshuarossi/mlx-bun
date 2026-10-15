import { expect, test } from "bun:test";
import { compareScreens, median, type ScreenReport } from "./forward-screen";

function report(ms: number): ScreenReport {
  return {
    schema: 1, pid: 1, graph: "graph", source: { head: "a", clean: true, sha256: "b", files: 1 },
    match: { tool: "tool", model: "/model", config: "config", metadata: {}, weights: [{ name: "weight", bytes: 100, modifiedMs: 1 }],
      native: { mlx: "runtime" }, architecture: "m1", host: "mac", bun: "1.4.2", mlx: "0.32.2", environment: {},
      gpuWiredLimitMB: 0, context: 64, warmup: 1, steps: 2, rows: [1], kv: "bf16" },
    preflight: { ok: true, problems: [], at: "now", swapUsedMB: 0, freePercent: 90, cpuSpeedLimit: 100,
      gpuWiredLimitMB: 0, loadAvg1m: 1, bigProcesses: [] },
    cells: [{ rows: 1, prefillMs: 100, warmup: [], samples: [
      { buildMs: 1, completedMs: ms, logits: "first" }, { buildMs: 1, completedMs: ms * 1.1, logits: "last" },
    ], state: "cache", memory: { activeBytes: 100, cacheBytes: 10, peakBytes: 120 } }],
  };
}

test("screen comparison pairs session medians and ignores graph build time as a speed claim", () => {
  const baseline = [report(50), report(51)], candidate = [report(45), report(45.9)];
  candidate[0]!.cells[0]!.samples.forEach(s => { s.buildMs = 100; });
  const [result] = compareScreens(baseline, candidate);
  expect(result!.pairs).toBe(2);
  expect(result!.ratio).toBeCloseTo(0.9, 12);
  expect(result!.verdict).toBe("improvement");
  expect(result!.gated).toBe(false);
});

test("screen rejects changes to workload, native runtime, artifact identity, and numerical outputs", () => {
  for (const change of [
    (r: ScreenReport) => { r.match.context++; },
    (r: ScreenReport) => { r.match.native.mlx = "changed"; },
    (r: ScreenReport) => { r.match.weights[0]!.modifiedMs++; },
    (r: ScreenReport) => { r.match.environment.MLX_MAX_OPS_PER_BUFFER = "10"; },
    (r: ScreenReport) => { r.cells[0]!.state = "changed"; },
    (r: ScreenReport) => { r.cells[0]!.samples[1]!.logits = "changed"; },
    (r: ScreenReport) => { r.cells[0]!.samples.pop(); },
    (r: ScreenReport) => { r.cells = []; },
  ]) {
    const candidate = report(45); change(candidate);
    expect(() => compareScreens([report(50)], [candidate])).toThrow();
  }
  expect(() => compareScreens([], [])).toThrow();
  expect(() => compareScreens([report(50)], [])).toThrow();
});

test("a lone screening session stays inconclusive; invalid timings cannot look faster", () => {
  expect(compareScreens([report(50)], [report(45)])[0]!.verdict).toBe("one pair, not gated");
  expect(median([3, 1, 4, 2])).toBe(2.5);
  for (const values of [[], [0], [-1], [NaN], [Infinity]]) expect(() => median(values)).toThrow();
});
