// mlx-lm BatchRotatingKVCache is the same-B ring/mask oracle. Affine
// composition compares valid stored columns with the same native quantizer;
// no upstream implementation combines batched rotating and affine KV.
import { test, expect } from "bun:test";
import { spawnSync } from "node:child_process";
import { ORACLE_VENV } from "../support/paths";

const enabled = Bun.env.MLX_BUN_TEST_ROTATING_BLOCK === "1";
const oracle = String.raw`
import json
import mlx.core as mx
from mlx_lm.models.cache import BatchRotatingKVCache, RotatingKVCache

def record(a):
    return {"shape": list(a.shape), "values": a.astype(mx.float32).reshape(-1).tolist()}

runs = []
for pads in [[0], [0, 3], [2, 0, 4]]:
    cache = BatchRotatingKVCache(8, pads)
    steps = []
    for index, count in enumerate([5, 1, 3, 1, 1, 4, 2, 1, 9, 1, 2]):
        batch = len(cache.offset)
        if index == 4:
            cache.filter(list(reversed(range(batch))))
        if index == 7:
            cache.filter([0])
            batch = 1
        if index == 9:
            joiner = RotatingKVCache(8)
            joiner.update_and_fetch(mx.full((1, 1, 2, 64), 0.25, dtype=mx.bfloat16), mx.full((1, 1, 2, 64), -0.5, dtype=mx.bfloat16))
            cache = BatchRotatingKVCache.merge([cache.extract(0), joiner])
            batch = 2
        k = (((mx.arange(batch * count * 64) + index * 7) % 101) - 50).reshape(batch, 1, count, 64).astype(mx.bfloat16) / 32
        v = (((mx.arange(batch * count * 64) + index * 11) % 73) - 36).reshape(batch, 1, count, 64).astype(mx.bfloat16) / 16
        mask = cache.make_mask(count)
        keys, values = cache.update_and_fetch(k, v)
        extracts = []
        for row in range(batch):
            single = cache.extract(row)
            extracts.append({"keys": record(single.keys), "values": record(single.values), "offset": single.offset, "idx": single._idx})
        steps.append({"k": record(k), "v": record(v), "mask": record(mask), "keys": record(keys), "values": record(values), "offsets": cache.offset.tolist(), "pads": cache.left_padding.tolist(), "offset": cache._offset, "idx": cache._idx, "extracts": extracts})
    runs.append({"pads": pads, "steps": steps})
print(json.dumps(runs))
`;
type Tensor = { shape: number[]; values: number[] };
type Step = { k: Tensor; v: Tensor; mask: Tensor; keys: Tensor; values: Tensor; offsets: number[]; pads: number[]; offset: number; idx: number; extracts: { keys: Tensor; values: Tensor; offset: number; idx: number }[] };

test.skipIf(!enabled)("batched ring blocks match same-B oracle before/after wrap, overshoot, retirement, late admission and extraction", async () => {
  // Python completes before Bun touches MLX; the two GPU owners never overlap.
  const reference = spawnSync(`${ORACLE_VENV}/bin/python`, ["-c", oracle], { encoding: "utf8", maxBuffer: 32 * 1024 * 1024 });
  expect(reference.status, reference.stderr).toBe(0);
  const runs = JSON.parse(reference.stdout) as { pads: number[]; steps: Step[] }[];
  const { MlxArray } = await import("../../src/mlx/array");
  const { Dtype } = await import("../../src/mlx/ffi");
  const ops = await import("../../src/mlx/ops");
  const { BatchedRotatingCache } = await import("../../src/model/batched-rotating");
  const { BatchedRotatingQuantCache } = await import("../../src/model/batched-rotating-quant");
  type Array = import("../../src/mlx/array").MlxArray;
  const from = (t: Tensor) => {
    using a = MlxArray.fromFloat32(Float32Array.from(t.values), t.shape);
    return a.astype(Dtype.bfloat16);
  };
  const equal = (a: Array, t: Tensor) => {
    expect(a.shape).toEqual(t.shape);
    expect([...a.toFloat32()]).toEqual(t.values);
  };
  const disposeTriple = (t: import("../../src/mlx/ops").QuantizedTensor) => {
    t.packed.dispose(); t.scales.dispose(); t.biases.dispose();
  };
  for (const run of runs) {
    let plain = new BatchedRotatingCache(8, run.pads);
    const quants = [4, 8].map(bits => BatchedRotatingQuantCache.empty(8, 64, bits, run.pads));
    try {
      for (const [index, step] of run.steps.entries()) {
        if (index === 4 || index === 7) {
          const keep = index === 7 ? [0] : [...plain.offsetArr.keys()].reverse();
          plain.filter(keep); for (const quant of quants) quant.filter(keep);
        }
        if (index === 9) {
          const [oldK, oldV] = plain.temporalView();
          using joinK = from({ shape: [1, 1, 2, 64], values: [...new Float32Array(128).fill(0.25)] });
          using joinV = from({ shape: [1, 1, 2, 64], values: [...new Float32Array(128).fill(-0.5)] });
          const merged = BatchedRotatingCache.merge([{ keys: oldK, values: oldV }, { keys: joinK, values: joinV }], [plain.offsetArr[0]!, 2], 8);
          oldK.dispose(); oldV.dispose(); plain.dispose(); plain = merged;
          for (const [i, quant] of quants.entries()) {
            const [oldK, oldV] = quant.temporalView();
            const keys = ops.quantize(joinK, 64, quant.bits), values = ops.quantize(joinV, 64, quant.bits);
            const merged = BatchedRotatingQuantCache.merge([{ keys: oldK, values: oldV }, { keys, values }], [quant.offsetArr[0]!, 2], 8, 64, quant.bits);
            for (const t of [oldK, oldV, keys, values]) disposeTriple(t);
            quant.dispose(); quants[i] = merged;
          }
        }
        using k = from(step.k), v = from(step.v);
        const mask = plain.makeMask(k.shape[2]!, 8);
        try { equal(mask.arr!, step.mask); } finally { mask.arr!.dispose(); }
        const [pk, pv] = plain.updateAndFetch(k, v);
        try { equal(pk, step.keys); equal(pv, step.values); }
        finally { pk.dispose(); pv.dispose(); }
        expect(plain.offset).toBe(step.offset);
        expect(plain.offsetArr).toEqual(step.offsets);
        expect(plain.leftPad).toEqual(step.pads);
        for (const [row, expected] of step.extracts.entries()) {
          const extracted = plain.extractRow(row)!;
          try {
            equal(extracted.keys!, expected.keys); equal(extracted.values!, expected.values);
            expect(extracted.offset).toBe(expected.offset); expect(extracted.ringIdx).toBe(expected.idx);
          } finally { extracted.dispose(); }
        }
        for (const quant of quants) {
          const qm = quant.makeMask(k.shape[2]!, 8);
          try { equal(qm.arr!, step.mask); } finally { qm.arr!.dispose(); }
          const [qk, qv] = quant.updateAndFetchQuantized(k, v);
          disposeTriple(qk); disposeTriple(qv);
          expect(quant.offsetArr).toEqual(step.offsets);
          expect(quant.leftPad).toEqual(step.pads);
          expect(quant.offset).toBe(step.offset); expect(quant.ringIdx).toBe(step.idx);
          for (const [row, expected] of step.extracts.entries()) {
            const extracted = quant.extractRow(row)!;
            try {
              for (const [actual, target] of [[extracted.keys!, expected.keys], [extracted.values!, expected.values]] as const) {
                using source = from(target);
                const wanted = ops.quantize(source, 64, quant.bits);
                try {
                  expect(actual.packed.shape).toEqual(wanted.packed.shape);
                  expect(actual.packed.toIntTokens()).toEqual(wanted.packed.toIntTokens());
                  expect([...actual.scales.toFloat32()]).toEqual([...wanted.scales.toFloat32()]);
                  expect([...actual.biases.toFloat32()]).toEqual([...wanted.biases.toFloat32()]);
                } finally { disposeTriple(wanted); }
              }
              expect(extracted.offset).toBe(expected.offset); expect(extracted.ringIdx).toBe(expected.idx);
            } finally { extracted.dispose(); }
          }
          quant.releaseRopeArr();
        }
        plain.releaseRopeArr();
      }
    } finally { plain.dispose(); for (const quant of quants) quant.dispose(); }
  }
}, 120_000);
