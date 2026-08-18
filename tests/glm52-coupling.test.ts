import { describe, expect, test } from "bun:test";
import {
  buildGlm52CouplingModel,
  evaluateGlm52Coupling,
  Glm52RouteTraceCollector,
  splitGlm52RouteTrace,
  type Glm52RouteTraceRecord,
} from "../src/model/glm52-coupling";

function position(
  forward: number,
  source: number,
  next: number,
  nextTwo: number,
  segment = "cold",
): Glm52RouteTraceRecord[] {
  return [
    { segment, forward, row: 0, layer: 3, indices: [source] },
    { segment, forward, row: 0, layer: 4, indices: [next] },
    { segment, forward, row: 0, layer: 5, indices: [nextTwo] },
  ];
}

describe("GLM-5.2 route coupling measurement", () => {
  test("collector identifies forward boundaries without touching routes", () => {
    const collector = new Glm52RouteTraceCollector();
    collector.beginSegment("cold");
    collector.observe(3, [{ indices: [1, 2] }]);
    collector.observe(4, [{ indices: [3, 4] }]);
    collector.observe(3, [{ indices: [5, 6] }]);
    collector.beginSegment("warm");
    collector.observe(3, [{ indices: [7, 8] }]);
    expect(collector.snapshot()).toEqual([
      { segment: "cold", forward: 0, row: 0, layer: 3, indices: [1, 2] },
      { segment: "cold", forward: 0, row: 0, layer: 4, indices: [3, 4] },
      { segment: "cold", forward: 1, row: 0, layer: 3, indices: [5, 6] },
      { segment: "warm", forward: 0, row: 0, layer: 3, indices: [7, 8] },
    ]);
  });

  test("held-out coupling beats the equal-budget marginal without backfill", () => {
    const train = [
      ...position(0, 0, 5, 7),
      ...position(1, 1, 2, 3),
      ...position(2, 1, 2, 3),
      ...position(3, 1, 2, 3),
    ];
    const model = buildGlm52CouplingModel(train);
    const heldOut = position(4, 0, 5, 7);
    const scores = evaluateGlm52Coupling(model, heldOut, [1]);
    expect(scores).toEqual([
      {
        delta: 1,
        budget: 1,
        coupled: {
          rows: 2,
          predictedSelections: 2,
          actualSelections: 2,
          matchedSelections: 2,
          exactRows: 2,
          precision: 1,
          recall: 1,
          exactRowRate: 1,
        },
        marginal: {
          rows: 2,
          predictedSelections: 2,
          actualSelections: 2,
          matchedSelections: 0,
          exactRows: 0,
          precision: 0,
          recall: 0,
          exactRowRate: 0,
        },
        recallLift: 1,
      },
      {
        delta: 2,
        budget: 1,
        coupled: {
          rows: 1,
          predictedSelections: 1,
          actualSelections: 1,
          matchedSelections: 1,
          exactRows: 1,
          precision: 1,
          recall: 1,
          exactRowRate: 1,
        },
        marginal: {
          rows: 1,
          predictedSelections: 1,
          actualSelections: 1,
          matchedSelections: 0,
          exactRows: 0,
          precision: 0,
          recall: 0,
          exactRowRate: 0,
        },
        recallLift: 1,
      },
    ]);
  });

  test("temporal split excludes the repeated warm segment", () => {
    const records = [
      ...position(0, 0, 5, 7),
      ...position(1, 1, 2, 3),
      ...position(2, 0, 5, 7),
      ...position(3, 1, 2, 3),
      ...position(0, 0, 5, 7, "warm"),
    ];
    const split = splitGlm52RouteTrace(records, {
      segment: "cold",
      trainFraction: 0.5,
    });
    expect(split).toMatchObject({
      segment: "cold",
      trainPositions: 2,
      testPositions: 2,
    });
    expect(split.train.every((record) => record.segment === "cold")).toBe(true);
    expect(split.test.every((record) => record.segment === "cold")).toBe(true);
    expect(new Set(split.train.map((record) => record.forward))).toEqual(
      new Set([0, 1]),
    );
    expect(new Set(split.test.map((record) => record.forward))).toEqual(
      new Set([2, 3]),
    );
  });
});
