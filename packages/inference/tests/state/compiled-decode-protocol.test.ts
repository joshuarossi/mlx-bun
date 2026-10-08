// A cache drives the compiled decode step through its own protocol: prepare the
// step, declare a slot, feed the closure inputs, place a stand-in in the traced
// graph, then apply the closure's outputs. Run eagerly (no compile), the stand-in
// must fetch exactly what the real cache's append fetches and leave the cache in
// exactly the state the real append leaves, in both fetch phases (growing concat,
// then the rotating ring at steady state). Every plane is compared byte for byte
// against a twin cache that took the ordinary append.
import { expect, test } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cache, CompiledDecodeCache } from "../../src/contracts/mlx/cache";
import { isCompiledDecodeCache } from "../../src/state/capabilities";
import { decodeStepInputs } from "../../src/state/decode-step-inputs";
import { BatchedKVCache } from "../../src/state/batched-kv";
import { KVCache } from "../../src/state/kv";
import { QuantizedKVCache } from "../../src/state/quantized-kv";
import { RotatingKVCache } from "../../src/state/rotating-kv";
import { RotatingQuantizedKVCache } from "../../src/state/rotating-quantized-kv";
import { TurboQuantKVCache } from "../../src/state/turboquant-kv";

const W = 8, H = 2, D = 64, GROUP = 32, BITS = 4;
type Kind = { name: string; make: () => CompiledDecodeCache & Cache; quantized: boolean; ring: boolean };
const KINDS: Kind[] = [
  { name: "KVCache", make: () => new KVCache(), quantized: false, ring: false },
  { name: "QuantizedKVCache", make: () => new QuantizedKVCache(GROUP, BITS), quantized: true, ring: false },
  { name: "RotatingKVCache", make: () => new RotatingKVCache(W), quantized: false, ring: true },
  { name: "RotatingQuantizedKVCache", make: () => new RotatingQuantizedKVCache(W, GROUP, BITS), quantized: true, ring: true },
];

/** [1, H, n, D] rows whose values depend on the position tag, head and lane. */
function rows(from: number, n: number, sign: 1 | -1): MlxArray {
  const data = new Float32Array(H * n * D);
  for (let h = 0; h < H; h++) for (let i = 0; i < n; i++) for (let d = 0; d < D; d++)
    data[(h * n + i) * D + d] = sign * ((from + i) * 0.37 + h * 0.25 + d / 128);
  const wide = MlxArray.fromFloat32(data, [1, H, n, D]);
  try { return wide.astype(Dtype.bfloat16); } finally { wide.dispose(); }
}

const bytes = (a: MlxArray): Uint8Array => {
  const c = ops.contiguous(a);
  try { return Uint8Array.from(c.rawBytes()); } finally { c.dispose(); }
};
const same = (a: MlxArray[], b: MlxArray[]) => {
  expect(a.length).toBe(b.length);
  a.forEach((x, i) => { expect(x.shape).toEqual(b[i]!.shape); expect(Buffer.compare(bytes(x), bytes(b[i]!))).toBe(0); });
};
const planes = (t: { packed: MlxArray; scales: MlxArray; biases: MlxArray }) => [t.packed, t.scales, t.biases];

/** The ordinary append; returns the attended tensors. */
function append(cache: Cache, quantized: boolean, k: MlxArray, v: MlxArray): MlxArray[] {
  if (quantized) {
    const [kq, vq] = (cache as QuantizedKVCache).updateAndFetchQuantized(k, v);
    return [...planes(kq), ...planes(vq)];
  }
  return cache.updateAndFetch(k, v).slice();
}

for (const kind of KINDS) {
  for (const prefill of [3, 12]) {
    test(`${kind.name} after a ${prefill}-token prefill: the stand-in fetches and commits what the ordinary append does`, () => {
      const real = kind.make(), driven = kind.make();
      const phases = new Set<string>();
      try {
        const kp = rows(0, prefill, 1), vp = rows(0, prefill, -1);
        for (const cache of [real, driven])
          for (const a of append(cache, kind.quantized, kp, vp)) a.dispose();
        kp.dispose(); vp.dispose();

        for (let step = 0; step < 14; step++) {
          const at = prefill + step;
          const k = rows(at, 1, 1), v = rows(at, 1, -1);
          const expected = append(real, kind.quantized, k, v);

          const phase = driven.decodePhase();
          const plan = driven.prepareDecodeStep();
          expect(plan.fetch).toBe(phase);
          phases.add(plan.fetch);
          const slot = driven.decodeSlot(plan);
          expect(slot.fetch).toBe(plan.fetch);
          const temps: MlxArray[] = [];
          const inputs = driven.decodeInputs(plan, decodeStepInputs(temps));
          expect(inputs.length).toBe(slot.inputs);
          const ropeOffset = ops.fromInt32([at], []);
          const trace = slot.trace([...inputs], ropeOffset);
          const fetched = append(trace, kind.quantized, k, v);
          expect(trace.outs.length).toBe(slot.outputs);
          same(fetched, expected);
          const roots = driven.commitDecodeStep(slot, trace.outs);
          for (const t of [...temps, ropeOffset, ...fetched]) t.dispose();

          expect(driven.offset).toBe(real.offset);
          same(driven.state(), real.state());
          expect(roots.length).toBe(slot.fetch === "concat" ? driven.state().length : 0);
          if (kind.ring) expect((driven as RotatingKVCache).ringIdx).toBe((real as RotatingKVCache).ringIdx);
          for (const a of [k, v, ...expected]) a.dispose();
        }
        // a ring past its window at the prefill only ever runs the ring fetch
        expect([...phases].sort()).toEqual(kind.ring && prefill >= W ? ["ring"] : kind.ring ? ["concat", "ring"] : ["concat"]);
      } finally { real.dispose(); driven.dispose(); }
    });
  }
}

test("only the caches that implement the protocol answer the compiled-decode probe", () => {
  const caches = KINDS.map(k => k.make());
  try {
    for (const cache of caches) expect(isCompiledDecodeCache(cache)).toBe(true);
    expect(isCompiledDecodeCache(new BatchedKVCache())).toBe(false);
    expect(isCompiledDecodeCache(new TurboQuantKVCache(4, 4, false))).toBe(false);
  } finally { for (const cache of caches) cache.dispose(); }
});
