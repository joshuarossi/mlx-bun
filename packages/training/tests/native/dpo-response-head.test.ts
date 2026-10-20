import { expect, test } from "bun:test";

const native = process.env.MLX_BUN_TEST_NATIVE === "1";
type MlxArray = import("@mlx-bun/mlx/array").MlxArray;
const { MlxArray } = native ? await import("@mlx-bun/mlx/array") : {} as typeof import("@mlx-bun/mlx/array");
const { Dtype } = native ? await import("@mlx-bun/mlx/ffi") : {} as typeof import("@mlx-bun/mlx/ffi");
const { ValueAndGrad } = native ? await import("@mlx-bun/mlx/autograd") : {} as typeof import("@mlx-bun/mlx/autograd");
const ops = native ? await import("@mlx-bun/mlx/ops") : {} as typeof import("@mlx-bun/mlx/ops");
const { trainForward, sequenceLogProbabilities } = native ? await import("@mlx-bun/inference/scoring") : {} as typeof import("@mlx-bun/inference/scoring");
const { dpoLoss } = native ? await import("../../src/loss") : {} as typeof import("../../src/loss");
import type { RuntimeModel } from "@mlx-bun/inference/models";
import type { DpoBatch } from "../../src/dataset";

const ids = [0, 1, 2, 3, 4, 5, 6, 7, 1, 2, 3];
const cases = [
  { name: "one response token", masks: [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]] },
  { name: "two response tokens", masks: [[0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1]] },
  { name: "three response tokens", masks: [[0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1]] },
  { name: "batched sparse weighted masks and an empty row", masks: [
    [0, 0, 0, 0.5, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  ] },
  { name: "all response positions masked", masks: [Array(11).fill(0)] },
];

for (const dtype of native ? [Dtype.float32, Dtype.bfloat16] : []) for (const fixture of cases) {
  test.skipIf(!native)(`DPO response-only head: ${dtype} ${fixture.name}`, () => {
    const B = fixture.masks.length, T = ids.length - 1, H = 4, V = 8;
    using embeddingF = MlxArray.fromFloat32(Float32Array.from({ length: V * H }, (_, i) => Math.sin(i * 0.7) * 0.2), [V, H]);
    using embedding = embeddingF.astype(dtype);
    using headF = MlxArray.fromFloat32(Float32Array.from({ length: H * V }, (_, i) => Math.cos(i * 0.3)), [H, V]);
    using head = headF.astype(dtype);
    using paramF = MlxArray.fromFloat32(Float32Array.from({ length: H * H }, (_, i) => Math.sin(i + 1) * 0.1), [H, H]);
    using param = paramF.astype(dtype);
    const originalParam = param.toFloat32();
    using causalF = MlxArray.fromFloat32(Float32Array.from({ length: T * T }, (_, i) => i % T <= Math.floor(i / T) ? 1 : 0), [T, T]);
    using causal = causalF.astype(dtype);
    let projection = param;
    const headShapes: number[][] = [];
    const model = {
      makeCache: () => [],
      sequenceHidden(input: MlxArray) {
        using flat = ops.reshape(input, [B * T]);
        using gathered = ops.takeAxis(embedding, flat, 0);
        using tokens = ops.reshape(gathered, [B, T, H]);
        // Every response depends on earlier prompt positions. Compacting only
        // the head must not cut that dependency or change padding/mask meaning.
        using context = ops.matmul(causal, tokens);
        return ops.matmul(context, projection);
      },
      logitsFromHidden(hidden: MlxArray) {
        headShapes.push([...hidden.shape]);
        return ops.matmul(hidden, head);
      },
    } as unknown as RuntimeModel;
    const batch: DpoBatch = {
      chosenIds: fixture.masks.map(() => [...ids]),
      rejectedIds: fixture.masks.map(() => ids.map((v, i) => i > 4 ? (v + 1) % V : v)),
      chosenMask: fixture.masks.map(m => [...m]),
      rejectedMask: fixture.masks.map(m => [...m]),
      chosenLengths: fixture.masks.map(() => ids.length),
      rejectedLengths: fixture.masks.map(() => ids.length),
    };
    using refC = MlxArray.fromFloat32(new Float32Array(B).fill(-2), [B]);
    using refR = MlxArray.fromFloat32(new Float32Array(B).fill(-3), [B]);
    function fullScore(rows: number[][], masks: number[][]) {
      using input = MlxArray.fromInt32(Int32Array.from(rows.flatMap(r => r.slice(0, -1))), [B, T]);
      using logits = trainForward(model, input, batch.chosenLengths!.map(v => v - 1));
      return sequenceLogProbabilities(logits, rows, masks);
    }
    using oracle = new ValueAndGrad(p => {
      projection = p[0]!;
      using c = fullScore(batch.chosenIds, batch.chosenMask);
      using r = fullScore(batch.rejectedIds, batch.rejectedMask);
      using dc = ops.sub(c, refC), dr = ops.sub(r, refR);
      using diff = ops.sub(dc, dr), neg = ops.mulScalar(diff, -0.1);
      using zero = ops.scalarLike(0, neg), perRow = ops.logaddexp(zero, neg);
      return ops.meanAll(perRow, false);
    }, [0]);
    const expected = oracle.apply([param]);
    ops.evalAll([expected.value, ...expected.grads]);
    headShapes.length = 0;
    using candidate = new ValueAndGrad(p => {
      projection = p[0]!;
      return dpoLoss(model, batch, 0.1, refC, refR);
    }, [0]);
    const actual = candidate.apply([param]);
    try {
      ops.evalAll([actual.value, ...actual.grads]);
      expect(actual.value.toFloat32()[0]!).toBeCloseTo(expected.value.toFloat32()[0]!, 5);
      expect(actual.grads[0]!.shape).toEqual([H, H]);
      const a = actual.grads[0]!.toFloat32(), e = expected.grads[0]!.toFloat32();
      for (let i = 0; i < a.length; i++) {
        expect(Number.isFinite(a[i])).toBe(true);
        expect(Math.abs(a[i]! - e[i]!)).toBeLessThanOrEqual(dtype === Dtype.float32 ? 1e-6 : 1e-4);
      }
      const M = Math.max(...fixture.masks.map(m => m.slice(1).filter(Boolean).length));
      expect(headShapes).toEqual(M === 0 ? [] : [[B, M === 2 || M === 3 ? 4 : M, H], [B, M === 2 || M === 3 ? 4 : M, H]]);
      expect(param.toFloat32()).toEqual(originalParam);
      expect(batch.chosenMask).toEqual(fixture.masks);
    } finally {
      projection = param;
      for (const result of [expected, actual]) {
        result.value.dispose();
        for (const grad of result.grads) grad.dispose();
      }
    }
  });
}
