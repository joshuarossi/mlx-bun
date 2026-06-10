// Rotating KV-quant parity — Phase 9.
//
// Tier a (bit-exact) on both levels, post-Phase-10 (rope-freqs fix +
// fused reference goldens):
//  (1) MECHANICS: our RotatingQuantizedKVCache vs optiq's, driven
//      through the same scripted sequence (prefill → decode growth →
//      ring wrap → prefill-concat over the wrapped ring → post-wrap
//      decode); active triples + offset/_idx compared bitwise at
//      checkpoints. Fast tier — no model weights.
//  (2) END-TO-END (12B, slow tier): single-forward logits over a
//      past-window 1536-token prompt with uniform kv8/kv4 on ALL
//      layers, bit-exact vs python (patch_rotating_to_quantized +
//      fused install); greedy continuation prefix vs the
//      fused-prefill/stock-decode reference.
//
// Goldens: scripts/regen-rotating-kvq-goldens.ts.

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { SNAPSHOT, snapshotAvailable } from "./paths";

const manifestFile = Bun.file("goldens/rotating-kvq.json");
const blobFile = Bun.file("goldens/rotating-kvq.bin");
const haveGoldens = (await manifestFile.exists()) && (await blobFile.exists());

interface T { offset: number; shape: number[]; dtype: string }

describe.skipIf(!haveGoldens)("rotating KV-quant", async () => {
  if (!haveGoldens) return;
  const manifest = (await manifestFile.json()) as {
    mechanics: {
      config: { max_size: number; heads: number; dim: number; group_size: number; bits: number };
      steps: { S: number; k: T; v: T }[];
      checkpoints: Record<string, {
        offset: number; idx: number;
        k_packed: T; k_scales: T; k_biases: T;
        v_packed: T; v_scales: T; v_biases: T;
      }>;
    };
    e2e: Record<string, unknown> & { prompt_ids: number[] };
  };
  const buf = await blobFile.arrayBuffer();
  const f32 = (t: T): Float32Array => {
    const n = t.shape.reduce((a, b) => a * b, 1);
    return new Float32Array(buf, t.offset * 4, n);
  };
  const u32 = (t: T): Uint32Array => {
    const n = t.shape.reduce((a, b) => a * b, 1);
    return new Uint32Array(buf, t.offset * 4, n);
  };
  const bf16 = (t: T): MlxArray => {
    const f = MlxArray.fromFloat32(new Float32Array(f32(t)), t.shape);
    const b = f.astype(Dtype.bfloat16);
    f.dispose();
    return b;
  };

  const { RotatingQuantizedKVCache, Gemma4Model, KVCache, RotatingKVCache, lastPositionLogits } =
    await import("../src/model/gemma4");

  test("mechanics: ring bit-exact vs oracle at every checkpoint", () => {
    const cfg = manifest.mechanics.config;
    const cache = new RotatingQuantizedKVCache(cfg.max_size, cfg.group_size, cfg.bits);
    for (let i = 0; i < manifest.mechanics.steps.length; i++) {
      const step = manifest.mechanics.steps[i]!;
      const k = bf16(step.k);
      const v = bf16(step.v);
      const [qk, qv] = cache.updateAndFetchQuantized(k, v);
      k.dispose();
      v.dispose();
      const cp = manifest.mechanics.checkpoints[String(i)];
      if (cp) {
        expect(cache.offset).toBe(cp.offset);
        expect(cache.ringIdx).toBe(cp.idx);
        const cmpU32 = (a: MlxArray, want: T) => {
          const c = ops.contiguous(a);
          c.eval();
          expect(new Uint32Array(c.rawBytes().buffer.slice(0))).toEqual(new Uint32Array(u32(want)));
          c.dispose();
        };
        const cmpF32 = (a: MlxArray, want: T) => {
          const got = a.toFloat32();
          const ref = f32(want);
          let m = 0;
          for (let j = 0; j < ref.length; j++) m = Math.max(m, Math.abs(got[j]! - ref[j]!));
          expect(m).toBe(0);
        };
        cmpU32(qk.packed, cp.k_packed);
        cmpF32(qk.scales, cp.k_scales);
        cmpF32(qk.biases, cp.k_biases);
        cmpU32(qv.packed, cp.v_packed);
        cmpF32(qv.scales, cp.v_scales);
        cmpF32(qv.biases, cp.v_biases);
      }
      for (const t of [qk, qv]) {
        t.packed.dispose();
        t.scales.dispose();
        t.biases.dispose();
      }
    }
    cache.dispose();
  });

  test("toQuantized replay from a WRAPPED bf16 ring preserves state", () => {
    // quantizedKvStart-style mid-generation conversion: drive a bf16
    // rotating cache past wrap, replay into quantized, verify ring
    // bookkeeping carries over and the quantized contents round-trip to
    // the bf16 ring within quantization error.
    const MAX = 64, H = 2, D = 64;
    const rand = (n: number, seed: number) => {
      const out = new Float32Array(n);
      let s = seed >>> 0;
      for (let i = 0; i < n; i++) {
        s = (s * 1664525 + 1013904223) >>> 0;
        out[i] = (s / 2 ** 32) * 2 - 1;
      }
      return out;
    };
    const mk = (S: number, seed: number) => {
      const f = MlxArray.fromFloat32(rand(H * S * D, seed), [1, H, S, D]);
      const b = f.astype(Dtype.bfloat16);
      f.dispose();
      return b;
    };
    const bf = new RotatingKVCache(MAX);
    for (let i = 0; i < 70; i++) { // wraps at 64
      const k = mk(1, 100 + i), v = mk(1, 900 + i);
      const [fk, fv] = bf.updateAndFetch(k, v);
      for (const a of [k, v, fk, fv]) a.dispose();
    }
    const ringBytesBefore = bf.keys!.rawBytes().slice();
    const offsetBefore = bf.offset, idxBefore = bf.ringIdx;

    const q = bf.toQuantized(64, 8); // consumes bf
    expect(q.offset).toBe(offsetBefore);
    expect(q.ringIdx).toBe(idxBefore);
    expect(q.keys!.packed.shape[2]).toBe(MAX);

    // dequantized ring ≈ original (kv8 error well under 1 bf16 ulp@1);
    // reference floats reconstructed from the saved bf16 ring bytes
    const deq = MlxArray.dequantize(q.keys!.packed, q.keys!.scales, q.keys!.biases, 64, 8);
    const got = deq.toFloat32();
    const u16 = new Uint16Array(ringBytesBefore.buffer, ringBytesBefore.byteOffset, got.length);
    let m = 0;
    for (let i = 0; i < got.length; i++) {
      const f = new Float32Array(new Uint32Array([u16[i]! << 16]).buffer)[0]!;
      m = Math.max(m, Math.abs(got[i]! - f));
    }
    expect(m).toBeLessThan(0.02); // kv8 quantization noise bound
    deq.dispose();

    // the converted cache keeps working: a post-replay decode step
    const k = mk(1, 7777), v = mk(1, 8888);
    const [qk, qv] = q.updateAndFetchQuantized(k, v);
    expect(qk.packed.shape[2]).toBe(MAX);
    expect(q.offset).toBe(offsetBefore + 1);
    for (const a of [k, v]) a.dispose();
    for (const t of [qk, qv]) {
      t.packed.dispose();
      t.scales.dispose();
      t.biases.dispose();
    }
    q.dispose();
  });

  // OPT-IN (run the file alone): another full 12B instance on top of the
  // default suite's residents OOM-kills the process (exit 137 — the
  // Phase 6 multi-model working-set ceiling; same policy as the 26B
  // suite):  MLX_BUN_TEST_ROTKVQ=1 bun test tests/rotating-kvq.test.ts
  const haveWeights = (await snapshotAvailable()) && process.env.MLX_BUN_TEST_ROTKVQ === "1";
  describe.skipIf(!haveWeights)("end-to-end (12B, past-window prompt)", async () => {
    if (!haveWeights) return;
    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { generate } = await import("../src/generate");

    const config = await loadModelConfig(SNAPSHOT);
    const weights = await Weights.open(SNAPSHOT);
    const model = new Gemma4Model(weights, config);
    const ids = manifest.e2e.prompt_ids;

    const quantizeAll = (bits: number) => {
      const caches = model.makeCache();
      for (let i = 0; i < caches.length; i++) {
        const c = caches[i]!;
        if (c instanceof KVCache || c instanceof RotatingKVCache)
          caches[i] = c.toQuantized(64, bits);
      }
      return caches;
    };

    for (const [key, bits] of [["kv8", 8], ["kv4", 4]] as const) {
      test(`${key}: single-forward logits bit-exact (all layers quantized)`, () => {
        const caches = quantizeAll(bits);
        const logits = model.forward(ids, caches);
        const ours = lastPositionLogits(logits);
        logits.dispose();
        for (const c of caches) c.dispose();
        const ref = f32(manifest.e2e[`${key}_logits`] as T);
        let m = 0;
        for (let i = 0; i < ref.length; i++) m = Math.max(m, Math.abs(ours[i]! - ref[i]!));
        expect(m).toBe(0);
      }, 300_000);

      test(`${key}: greedy continuation long-prefix agreement`, async () => {
        const caches = model.makeCache();
        const gen = generate(model, ids, {
          maxTokens: 16, temperature: 0, cache: caches,
          kvBits: bits, kvGroupSize: 64, quantizedKvStart: 0,
        });
        const out: number[] = [];
        for await (const t of gen) out.push(t.token);
        expect(caches.filter((c) => c instanceof RotatingQuantizedKVCache).length).toBe(40);
        for (const c of caches) c.dispose();
        const ref = manifest.e2e[`${key}_greedy`] as number[];
        let prefix = 0;
        while (prefix < Math.min(ref.length, out.length) && out[prefix] === ref[prefix]) prefix++;
        // trajectories are loop-shape-sensitive at bf16 knife edges
        // (standing finding) — require a meaningful prefix, not equality
        expect(prefix).toBeGreaterThanOrEqual(8);
      }, 300_000);
    }
  });
});
