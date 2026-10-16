import { expect, test } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { GatedDeltaParameters } from "../../src/contracts/mlx/cache";
import { convDeltaDecode } from "../../src/kernels/delta/conv-step";
import { siluRmsHeads } from "../../src/kernels/delta/silu-rms-heads";
import { SSMCache } from "../../src/state/ssm";
import { BatchedSSMCache } from "../../src/state/batched-ssm";

function tensor(shape: number[], dtype: Dtype, seed: number, scale = 1): MlxArray {
  using wide = MlxArray.fromFloat32(Float32Array.from({ length: shape.reduce((a, b) => a * b, 1) },
    (_, i) => scale * (Math.sin(i * .73 + seed) + Math.cos(i * .11 - seed))), shape);
  return wide.astype(dtype);
}
function exact(a: MlxArray, b: MlxArray): void {
  expect(a.shape).toEqual(b.shape);
  expect(a.dtype).toBe(b.dtype);
  using ac = ops.contiguous(a); using bc = ops.contiguous(b);
  expect(Buffer.from(ac.rawBytes()).equals(Buffer.from(bc.rawBytes()))).toBe(true);
}
function sameState(a: SSMCache, b: SSMCache): void {
  expect(a.offset).toBe(b.offset);
  expect(a.offsets).toEqual(b.offsets);
  expect(a.state().length).toBe(b.state().length);
  a.state().forEach((array, i) => exact(array, b.state()[i]!));
}

for (const dtype of [Dtype.bfloat16, Dtype.float32]) test(`fused DeltaNet decode retains exact cache trajectories (${dtype})`, () => {
  const HK = 2, HV = 6, C = (2 * HK + HV) * 128;
  using convWeight = tensor([C, 4, 1], dtype, 1, .2);
  using aLog = tensor([HV], Dtype.float32, 2, .3);
  using dtBias = tensor([HV], dtype, 3);
  // Scale vectors use the same dtype as MLX's normalization weight.
  using qWide = MlxArray.fromFloat32(new Float32Array(128).fill(1 / 128), [128]);
  using kWide = MlxArray.fromFloat32(new Float32Array(128).fill(128 ** -.5), [128]);
  using q = qWide.astype(dtype);
  using k = kWide.astype(dtype);
  const plain: GatedDeltaParameters = { convWeight, aLog, dtBias, heads: convolved => {
    const [q0, k0, v0] = siluRmsHeads(convolved, q, k, HK, HV, 128);
    return { q: q0!, k: k0!, v: v0! };
  } };
  let decodes = 0;
  const fused: GatedDeltaParameters = { ...plain, decode: (qkv, a, b, history, state) => {
    ++decodes;
    return convDeltaDecode(qkv, a, b, history, state, convWeight, aLog, dtBias, q, k, HK, HV);
  } };
  const reference = new BatchedSSMCache(), candidate = new BatchedSSMCache();
  reference.offsets = [0, 0]; candidate.offsets = [0, 0];
  const advance = (B: number, S: number, seed: number, decode: boolean, aCache = reference as SSMCache, bCache = candidate as SSMCache) => {
    using input = tensor([B, S, C], dtype, seed);
    using a = tensor([B, S, HV], dtype, seed + 1);
    using b = tensor([B, S, HV], dtype, seed + 2);
    const read = (cache: SSMCache, layer: GatedDeltaParameters) => decode
      ? cache.recurDecode(ops.copyOf(input), ops.copyOf(a), ops.copyOf(b), layer)
      : cache.recurWindow(ops.copyOf(input), ops.copyOf(a), ops.copyOf(b), layer);
    using expected = read(aCache, plain);
    using actual = read(bCache, fused);
    exact(actual, expected); sameState(aCache, bCache);
  };
  try {
    advance(2, 1, 10, true); // cold zero state
    advance(2, 4, 20, false); // multi-token phase never calls the decode binding
    expect(decodes).toBe(1);
    for (let round = 0; round < 3; ++round) {
      reference.specRoundBegin(); candidate.specRoundBegin();
      advance(2, 1, 30 + round, true);
      reference.specRoundRollback([0, 1]); candidate.specRoundRollback([0, 1]);
      sameState(reference, candidate); // replays the fused kernel's retained K/V
      advance(2, 1, 40 + round, true);
    }
    reference.specRoundBegin(); candidate.specRoundBegin();
    advance(2, 4, 50, false);
    reference.specRoundRollback([3, 1]); candidate.specRoundRollback([3, 1]);
    advance(2, 1, 60, true); // pending window fold followed by fused decode
    const ra = reference.extractRow(1), ca = candidate.extractRow(1);
    try {
      advance(1, 1, 70, true, ra, ca);
      reference.mergeRows([ra]); candidate.mergeRows([ca]);
      advance(1, 1, 80, true);
      reference.filter([0]); candidate.filter([0]);
      sameState(reference, candidate);
    } finally { ra.dispose(); ca.dispose(); }
  } finally { reference.dispose(); candidate.dispose(); }
});
