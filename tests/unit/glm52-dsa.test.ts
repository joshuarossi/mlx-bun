import { describe, expect, test } from "bun:test";
import { readFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { MlxArray } from "../../src/mlx/array";
import {
  Glm52DsaSelectionState,
  glm52DsaScoresMlx,
  projectGlm52DsaKeyF32,
  projectGlm52DsaQueryF32,
  scoreAndSelectGlm52DsaF32,
  selectGlm52DsaDevice,
  type Glm52DsaGeometry,
  type Glm52DsaProjectionWeights,
} from "../../src/model/glm52-dsa";
import {
  dsaScoresFromProjectedF32,
  selectDsaThresholdTiesF32,
} from "../../src/model/glm52-reference";

const ROOT = resolve(import.meta.dir, "..", "..");
const fixture = JSON.parse(
  readFileSync(join(ROOT, "fixtures/colibri-glm52/v1.json"), "utf8"),
);

function expectWithin(
  actual: ArrayLike<number>,
  expected: ArrayLike<number>,
  tolerance = 2e-6,
): void {
  expect(actual.length).toBe(expected.length);
  for (let index = 0; index < actual.length; index++)
    expect(Math.abs(actual[index]! - expected[index]!)).toBeLessThanOrEqual(tolerance);
}

const geometry: Glm52DsaGeometry = {
  numHeads: 2,
  headDim: 4,
  rotaryDimensions: 2,
  ropeTheta: 10_000,
  topK: 2,
};

const weights: Glm52DsaProjectionWeights = {
  query: [
    [1, 0], [0, 1], [0, 0], [0, 0],
    [0, 1], [1, 0], [0, 0], [0, 0],
  ],
  key: [
    [1, 0, 0, 0],
    [0, 1, 0, 0],
    [0, 0, 1, 0],
    [0, 0, 0, 1],
  ],
  headWeights: [
    [1, 0, 0, 0],
    [0, 1, 0, 0],
  ],
  keyNormWeight: [1, 1, 1, 1],
  keyNormBias: [0, 0, 0, 0],
};

describe("GLM-5.2 DSA primitives", () => {
  test("projects q/k, applies key LayerNorm, and partially rotates every index head", () => {
    const query = projectGlm52DsaQueryF32([2, 3], [5, 7, 0, 0], 0, weights, geometry);
    // position zero exposes Colibri's pair-interleaved -> split output layout.
    expect(query.heads.map((head) => Array.from(head))).toEqual([
      [2, 3, 0, 0],
      [3, 2, 0, 0],
    ]);
    expect(Array.from(query.headWeights)).toEqual([5, 7]);

    const key = projectGlm52DsaKeyF32([1, 2, 3, 4], 0, weights, geometry);
    const scale = 1 / Math.sqrt(1.25 + 1e-6);
    expectWithin(key, [-1.5 * scale, -0.5 * scale, 0.5 * scale, 1.5 * scale]);

    const rotated = projectGlm52DsaQueryF32([1, 0], [1, 1, 0, 0], 1, weights, geometry);
    expectWithin(rotated.heads[0]!, [Math.cos(1), Math.sin(1), 0, 0]);
  });

  test("matches projected weighted-ReLU scores on host and MLX", () => {
    const heads = [[1, 0], [0, 1]];
    const keys = [[1, 2], [-1, 3], [0, 0]];
    const headWeights = [2, 1];
    const expected = dsaScoresFromProjectedF32(heads, keys, headWeights);
    expectWithin(expected, [2, 1.5, 0]);

    const q = MlxArray.fromFloat32(new Float32Array(heads.flat()), [2, 2]);
    const k = MlxArray.fromFloat32(new Float32Array(keys.flat()), [3, 2]);
    const w = MlxArray.fromFloat32(new Float32Array(headWeights), [2]);
    const actual = glm52DsaScoresMlx(q, k, w);
    try {
      expectWithin(actual.toFloat32(), expected);
    } finally {
      actual.dispose();
      q.dispose();
      k.dispose();
      w.dispose();
    }
  });

  test("uses exact threshold/tie selection from the captured oracle", () => {
    for (const data of fixture.dsa_selection.cases) {
      const state = new Glm52DsaSelectionState(data.keep);
      const selected = state.selectFull(4, data.scores);
      if (data.scores.length <= data.keep) {
        expect(selected.mode).toBe("dense");
      } else {
        expect(selected.mode).toBe("sparse");
        if (selected.mode === "sparse") {
          expect(selected.threshold).toBe(data.expected.threshold);
          expect(selected.positions).toEqual(data.expected.selected);
        }
      }
    }
  });

  test("device top-k matches random host-oracle rows exactly", () => {
    let seed = 0x52d5a123;
    const random = (): number => {
      seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0;
      return Math.fround((seed / 0x1_0000_0000) * 20 - 10);
    };
    for (const [length, keep] of [[17, 5], [257, 64], [2049, 2048]] as const) {
      const values = Float32Array.from({ length }, random);
      const expected = selectDsaThresholdTiesF32(values, keep);
      const scores = MlxArray.fromFloat32(values, [length]);
      const actual = selectGlm52DsaDevice(scores, keep);
      try {
        expect(actual.positions.toIntTokens()).toEqual(expected.selected);
        expect(actual.threshold.toFloat32()[0]).toBe(expected.threshold);
      } finally {
        actual.dispose();
        scores.dispose();
      }
    }
  });

  test("device top-k preserves threshold ties and all-equal lower positions", () => {
    for (const data of [
      { scores: [0.5, 0.9, 0.9, 0.1], keep: 3 },
      { scores: [5, 5, 5, 5, 5], keep: 3 },
      { scores: [-2, -1, -1, -3, -1], keep: 2 },
    ]) {
      const values = Float32Array.from(data.scores);
      const expected = selectDsaThresholdTiesF32(values, data.keep);
      const scores = MlxArray.fromFloat32(values, [values.length]);
      const actual = selectGlm52DsaDevice(scores, data.keep);
      try {
        expect(actual.positions.toIntTokens()).toEqual(expected.selected);
        expect(actual.threshold.toFloat32()[0]).toBe(expected.threshold);
      } finally {
        actual.dispose();
        scores.dispose();
      }
    }
  });

  test("retains one compact FULL device buffer across SHARED layers", () => {
    const observed: unknown[] = [];
    const state = new Glm52DsaSelectionState(3, (selection) => observed.push(selection));
    const scores = MlxArray.fromFloat32(
      new Float32Array([0.5, 0.9, 0.9, 0.1]),
      [4],
    );
    try {
      const full = state.selectFullDevice(2, scores);
      expect(full.toIntTokens()).toEqual([1, 2, 0]);
      expect(state.selectSharedPositions(3, 4)).toBe(full);
      expect(state.selectSharedPositions(4, 4)).toBe(full);
      expect(observed).toEqual([{
        mode: "sparse",
        layer: 2,
        ownerLayer: 2,
        contextLength: 4,
        positions: [1, 2, 0],
        threshold: 0.5,
      }]);
      expect(() => state.selectSharedPositions(5, 5)).toThrow("context length");
    } finally {
      state.dispose();
      scores.dispose();
    }
  });

  test("retains one exact FULL selection per sparse verify row", () => {
    const state = new Glm52DsaSelectionState(2);
    const firstScores = MlxArray.fromFloat32(
      new Float32Array([4, 3, 2]),
      [3],
    );
    const secondScores = MlxArray.fromFloat32(
      new Float32Array([1, 5, 2, 4]),
      [4],
    );
    try {
      const first = state.selectFullDevice(2, firstScores);
      const second = state.selectFullDevice(2, secondScores);
      expect(state.selectSharedPositions(3, 3)).toBe(first);
      expect(state.selectSharedPositions(3, 4)).toBe(second);
      expect(() => state.selectSharedPositions(3, 5)).toThrow("no FULL selection");
    } finally {
      state.dispose();
      firstScores.dispose();
      secondScores.dispose();
    }
  });

  test("falls back to dense through topK and shares only the latest full selection", () => {
    const state = new Glm52DsaSelectionState(3);
    const dense = state.selectFull(0, [9, 8, 7]);
    expect(dense.mode).toBe("dense");
    expect(state.selectShared(1, 3)).toEqual({ ...dense, layer: 1 });

    const sparse = state.selectFull(2, [0.5, 0.9, 0.9, 0.1]);
    expect(sparse.mode).toBe("sparse");
    if (sparse.mode === "sparse") expect(sparse.positions).toEqual([1, 2, 0]);
    const shared = state.selectShared(3, 4);
    expect(shared.ownerLayer).toBe(2);
    expect(shared.layer).toBe(3);
    expect(shared).toEqual({ ...sparse, layer: 3 });

    expect(() => new Glm52DsaSelectionState(2).selectShared(1, 3))
      .toThrow("no preceding full-layer selection");
    expect(() => state.selectShared(4, 5)).toThrow("context length");
    state.reset();
    expect(state.latestFull).toBeNull();
  });

  test("can force a dense long-context selection for decode-only benchmarking", () => {
    const observed: unknown[] = [];
    const state = new Glm52DsaSelectionState(2, (selection) => observed.push(selection));
    const dense = state.selectFullDense(4, 8);
    expect(dense).toEqual({
      mode: "dense",
      layer: 4,
      ownerLayer: 4,
      contextLength: 8,
      positions: null,
      threshold: null,
    });
    expect(state.selectSharedPositions(5, 8)).toBeNull();
    expect(observed).toEqual([dense]);
    state.dispose();
  });

  test("uses the model's 2048-token dense/sparse boundary exactly", () => {
    const state = new Glm52DsaSelectionState(2048);
    expect(state.selectFull(20, new Float32Array(2048)).mode).toBe("dense");
    const scores = Float32Array.from({ length: 2049 }, (_, index) => index);
    const selected = state.selectFull(21, scores);
    expect(selected.mode).toBe("sparse");
    if (selected.mode === "sparse") {
      expect(selected.positions.length).toBe(2048);
      expect(selected.positions[0]).toBe(2);
      expect(selected.positions.at(-1)).toBe(1);
    }
  });

  test("observes FULL selections through a defensive snapshot", () => {
    const observed: unknown[] = [];
    const state = new Glm52DsaSelectionState(2, (selection) => {
      observed.push(selection);
      if (selection.mode === "sparse")
        (selection.positions as number[])[0] = 99;
    });

    const full = state.selectFull(4, [3, 2, 1]);
    expect(full).toEqual({
      mode: "sparse",
      layer: 4,
      ownerLayer: 4,
      contextLength: 3,
      positions: [0, 1],
      threshold: 2,
    });
    expect(observed).toHaveLength(1);
    expect(state.selectShared(5, 3)).toEqual({ ...full, layer: 5 });
    expect(observed).toHaveLength(1);
  });

  test("combines projected score and selection as one correctness operation", () => {
    const selection = scoreAndSelectGlm52DsaF32({
      heads: [new Float32Array([1, 0]), new Float32Array([0, 1])],
      headWeights: new Float32Array([2, 1]),
    }, [[1, 2], [-1, 3], [0, 0]], 2);
    expect(selection.mode).toBe("sparse");
    if (selection.mode === "sparse") expect(selection.positions).toEqual([0, 1]);
  });
});
