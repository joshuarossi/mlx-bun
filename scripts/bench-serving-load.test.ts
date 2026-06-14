// Unit tests for the parallel-load harness PURE logic only — percentile
// math, aggregation, knee detection, max-sustainable-rpm — over synthetic
// latency arrays. NO network, NO server, NO model. This is the only test
// the harness ships; everything else in bench-serving-load.ts touches the
// network and is exercised by Josh against his own running servers.
//
//   bun test scripts/bench-serving-load.test.ts

import { describe, expect, test } from "bun:test";
import {
  percentile, aggregate, detectKnee, maxSustainableRpm,
  type RequestResult, type SweepPoint,
} from "./bench-serving-load";

/** Build a synthetic OK result. sentAt/doneAt default so a list of these
 *  spans a 1 s window unless overridden. */
function ok(over: Partial<RequestResult> = {}): RequestResult {
  return {
    ok: true, ttftMs: 100, e2eMs: 1000, completionTokens: 50, decodeTps: 50,
    sentAt: 0, doneAt: 1000, ...over,
  };
}

describe("percentile", () => {
  test("empty array → 0", () => {
    expect(percentile([], 50)).toBe(0);
  });
  test("single sample → that sample for any p", () => {
    expect(percentile([42], 50)).toBe(42);
    expect(percentile([42], 95)).toBe(42);
    expect(percentile([42], 99)).toBe(42);
  });
  test("p50 of 1..9 is the middle value", () => {
    expect(percentile([1, 2, 3, 4, 5, 6, 7, 8, 9], 50)).toBe(5);
  });
  test("p0 / p100 are min / max", () => {
    const xs = [9, 1, 5, 3, 7];
    expect(percentile(xs, 0)).toBe(1);
    expect(percentile(xs, 100)).toBe(9);
  });
  test("interpolates between ranks", () => {
    // 4 samples: p50 rank = 0.5*3 = 1.5 → halfway between idx 1 (2) and 2 (3)
    expect(percentile([1, 2, 3, 4], 50)).toBeCloseTo(2.5, 6);
    // p95 rank = 0.95*3 = 2.85 → 3 + 0.85*(4-3) = 3.85
    expect(percentile([1, 2, 3, 4], 95)).toBeCloseTo(3.85, 6);
  });
  test("does not mutate input", () => {
    const xs = [3, 1, 2];
    percentile(xs, 50);
    expect(xs).toEqual([3, 1, 2]);
  });
});

describe("aggregate", () => {
  test("separates ok and errored requests; error rate", () => {
    const results: RequestResult[] = [
      ok(), ok(),
      { ok: false, ttftMs: 0, e2eMs: 500, completionTokens: 0, decodeTps: 0, sentAt: 0, doneAt: 500, error: "x" },
    ];
    const m = aggregate(results, 1000);
    expect(m.requestsOk).toBe(2);
    expect(m.requestsErr).toBe(1);
    expect(m.errorRate).toBeCloseTo(1 / 3, 6);
  });

  test("latency percentiles use OK requests only", () => {
    const results: RequestResult[] = [
      ok({ ttftMs: 100, e2eMs: 1000 }),
      ok({ ttftMs: 300, e2eMs: 3000 }),
      // an errored request with a misleading latency must not pollute p50/p95
      { ok: false, ttftMs: 9999, e2eMs: 9999, completionTokens: 0, decodeTps: 0, sentAt: 0, doneAt: 9999, error: "x" },
    ];
    const m = aggregate(results, 3000);
    expect(m.ttftP50Ms).toBe(200); // interp midpoint of [100,300]
    expect(m.e2eP50Ms).toBe(2000);
  });

  test("aggregate tok/s is summed generated tokens over the window", () => {
    // 4 requests × 50 tokens = 200 tokens over a 2 s window = 100 tok/s
    const results = [ok(), ok(), ok(), ok()];
    const m = aggregate(results, 2000);
    expect(m.aggTps).toBeCloseTo(100, 6);
  });

  test("per-request tok/s is the median per-stream decode rate", () => {
    const results = [ok({ decodeTps: 40 }), ok({ decodeTps: 60 }), ok({ decodeTps: 50 })];
    const m = aggregate(results, 1000);
    expect(m.perReqTps).toBe(50);
  });

  test("achieved rpm = ok requests per minute over the window", () => {
    // 10 ok requests over a 30 s window → 20 rpm
    const results = Array.from({ length: 10 }, () => ok());
    const m = aggregate(results, 30000);
    expect(m.achievedRpm).toBeCloseTo(20, 6);
  });

  test("falls back to measured span when no window supplied", () => {
    const results = [ok({ sentAt: 1000, doneAt: 2000 }), ok({ sentAt: 1500, doneAt: 3000 })];
    const m = aggregate(results); // span = 3000 - 1000 = 2000 ms
    expect(m.durationS).toBeCloseTo(2, 6);
  });

  test("empty input is safe (no divide-by-zero)", () => {
    const m = aggregate([], 0);
    expect(m.requestsOk).toBe(0);
    expect(m.aggTps).toBe(0);
    expect(m.errorRate).toBe(0);
    expect(Number.isFinite(m.durationS)).toBe(true);
  });
});

describe("detectKnee", () => {
  const pt = (load: number, aggTps: number, e2eP95Ms: number): SweepPoint => ({
    load,
    metrics: {
      requestsOk: 10, requestsErr: 0, durationS: 10,
      ttftP50Ms: 100, ttftP95Ms: 200,
      e2eP50Ms: e2eP95Ms / 2, e2eP95Ms, e2eP99Ms: e2eP95Ms * 1.1,
      aggTps, perReqTps: aggTps / load, achievedRpm: aggTps,
      errorRate: 0,
    },
  });

  test("too few points → null", () => {
    expect(detectKnee([pt(1, 10, 100), pt(2, 20, 200)])).toBeNull();
  });

  test("batch=1 serialized: throughput flat from the start while latency climbs → knee at the first level", () => {
    // aggregate tok/s ~constant (serialized ceiling), e2e p95 climbs with queue depth
    const pts = [pt(1, 50, 1000), pt(2, 51, 2000), pt(4, 50, 4000), pt(8, 52, 8000)];
    expect(detectKnee(pts)).toBe(1);
  });

  test("batching server: scales then knees at the slot count", () => {
    // throughput climbs 1→2→4 (slots), flattens 4→8 while latency climbs
    const pts = [pt(1, 50, 1000), pt(2, 95, 1100), pt(4, 180, 1300), pt(8, 185, 3000)];
    expect(detectKnee(pts)).toBe(4);
  });

  test("still scaling through the top of the sweep → null", () => {
    const pts = [pt(1, 50, 1000), pt(2, 100, 1100), pt(4, 200, 1300), pt(8, 400, 1500)];
    expect(detectKnee(pts)).toBeNull();
  });

  test("unsorted input is handled (sorted internally)", () => {
    const pts = [pt(8, 52, 8000), pt(1, 50, 1000), pt(4, 50, 4000), pt(2, 51, 2000)];
    expect(detectKnee(pts)).toBe(1);
  });
});

describe("maxSustainableRpm", () => {
  const pt = (achievedRpm: number, ttftP95Ms: number, errorRate = 0): SweepPoint => ({
    load: achievedRpm,
    metrics: {
      requestsOk: 10, requestsErr: 0, durationS: 10,
      ttftP50Ms: ttftP95Ms / 2, ttftP95Ms,
      e2eP50Ms: 500, e2eP95Ms: 1000, e2eP99Ms: 1100,
      aggTps: achievedRpm, perReqTps: 50, achievedRpm,
      errorRate,
    },
  });

  test("returns the highest achieved rpm within the TTFT budget", () => {
    const pts = [pt(10, 200), pt(30, 800), pt(60, 1800), pt(90, 5000)];
    // budget 2000 ms: 10/30/60 pass, 90 fails → 60
    expect(maxSustainableRpm(pts, 2000)).toBe(60);
  });

  test("null when even the lightest point exceeds the budget", () => {
    const pts = [pt(10, 3000), pt(30, 5000)];
    expect(maxSustainableRpm(pts, 2000)).toBeNull();
  });

  test("error-rate ceiling excludes a point even if its TTFT is fine", () => {
    const pts = [pt(10, 200), pt(60, 500, 0.2)]; // 60 rpm but 20% errors
    expect(maxSustainableRpm(pts, 2000, 0.01)).toBe(10);
  });
});
