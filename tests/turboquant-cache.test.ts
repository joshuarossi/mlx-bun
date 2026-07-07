// TurboQuantKVCache invariants (model-free — synthetic MlxArrays, no
// weights/goldens needed). Covers the append/fetch roundtrip against
// direct encode+decode, growth-boundary crossing, front-trim + append,
// kv-store persistence roundtrip, and a dispose leak sanity check
// (activeMemory pattern from tests/ffi-jit.test.ts).

import { describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { Dtype, activeMemory } from "../src/mlx/ffi";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import * as tq from "../src/mlx/turboquant-ops";
import { TurboQuantKVCache, disposeTurboQuant } from "../src/model/gemma4-base";
import { saveKvCache, loadKvCache, readKvHeader, cloneKvCaches } from "../src/kv-store";

const B = 1, H = 2, D = 64; // smallest supported head_dim

function randKV(L: number, seed: number): [MlxArray, MlxArray] {
  const k0 = ops.randomKey(BigInt(seed * 2));
  const k1 = ops.randomKey(BigInt(seed * 2 + 1));
  const kArr = ops.randomNormal([B, H, L, D], Dtype.float32, 0, 1, k0);
  const vArr = ops.randomNormal([B, H, L, D], Dtype.float32, 0, 1, k1);
  k0.dispose();
  k1.dispose();
  const kBf = kArr.astype(Dtype.bfloat16);
  const vBf = vArr.astype(Dtype.bfloat16);
  kArr.dispose();
  vArr.dispose();
  return [kBf, vBf];
}

function toFloatArr(a: MlxArray): number[] {
  return [...a.astype(Dtype.float32).toFloat32()];
}

/** Direct encode+decode of the same data via the codec ops, bypassing the
 *  cache class entirely — the reference this test compares the cache
 *  against (both must run the SAME encode/decode ops on the SAME input). */
function directRoundtrip(k: MlxArray, v: MlxArray, kBits: number, vBits: number): [MlxArray, MlxArray] {
  const signed = kBits === 8;
  const kEnc = tq.encodeKeys(k, kBits, signed);
  const vEnc = tq.encodeValues(v, vBits);
  const kOut = tq.decodeKeys(kEnc.indices, kEnc.scales, kEnc.zeros);
  const vOut = tq.decodeValues(vEnc.indices, vEnc.scales, vBits);
  for (const a of [kEnc.indices, kEnc.scales, kEnc.zeros, vEnc.indices, vEnc.scales]) a.dispose();
  return [kOut, vOut];
}

describe("TurboQuantKVCache — append/fetch roundtrip", () => {
  test("single-chunk update matches direct encode+decode of the same data", () => {
    const [k, v] = randKV(8, 1);
    const cache = new TurboQuantKVCache(8, 3);
    const [fetchedK, fetchedV] = cache.updateAndFetch(k, v);

    const [refK, refV] = directRoundtrip(k, v, 8, 3);
    expect(toFloatArr(fetchedK)).toEqual(toFloatArr(refK));
    expect(toFloatArr(fetchedV)).toEqual(toFloatArr(refV));

    expect(cache.offset).toBe(8);
    expect(fetchedK.shape).toEqual([B, H, 8, D]);
    expect(fetchedV.shape).toEqual([B, H, 8, D]);

    k.dispose(); v.dispose(); fetchedK.dispose(); fetchedV.dispose();
    refK.dispose(); refV.dispose();
    cache.dispose();
  });

  test("k4/v2 (sub-8-bit both sides) roundtrip matches direct encode+decode", () => {
    const [k, v] = randKV(5, 2);
    const cache = new TurboQuantKVCache(4, 2);
    const [fetchedK, fetchedV] = cache.updateAndFetch(k, v);

    const [refK, refV] = directRoundtrip(k, v, 4, 2);
    expect(toFloatArr(fetchedK)).toEqual(toFloatArr(refK));
    expect(toFloatArr(fetchedV)).toEqual(toFloatArr(refV));

    k.dispose(); v.dispose(); fetchedK.dispose(); fetchedV.dispose();
    refK.dispose(); refV.dispose();
    cache.dispose();
  });

  test("multi-chunk appends: each chunk decodes to the SAME per-token result as encoding it alone", () => {
    // TurboQuant quantizes per-token, per-32-group — there is no cross-token
    // dependency in the codec, so appending token-by-token must reproduce
    // exactly the same dequantized values as a single encodeKeys/encodeValues
    // call over the concatenation (unlike the mlx affine scheme's per-cache
    // scale grouping, this is bitwise per-row-independent).
    const cache = new TurboQuantKVCache(8, 3);
    const chunks: [MlxArray, MlxArray][] = [randKV(3, 10), randKV(4, 11), randKV(2, 12)];
    let lastK: MlxArray | null = null;
    let lastV: MlxArray | null = null;
    for (const [k, v] of chunks) {
      lastK?.dispose();
      lastV?.dispose();
      [lastK, lastV] = cache.updateAndFetch(k, v);
    }
    expect(cache.offset).toBe(9);

    const allK = ops.concatAxis(chunks.map(([k]) => k), 2);
    const allV = ops.concatAxis(chunks.map(([, v]) => v), 2);
    const [refK, refV] = directRoundtrip(allK, allV, 8, 3);
    expect(toFloatArr(lastK!)).toEqual(toFloatArr(refK));
    expect(toFloatArr(lastV!)).toEqual(toFloatArr(refV));

    for (const [k, v] of chunks) { k.dispose(); v.dispose(); }
    allK.dispose(); allV.dispose();
    lastK!.dispose(); lastV!.dispose();
    refK.dispose(); refV.dispose();
    cache.dispose();
  });

  test("crosses the 256-token growth boundary without corrupting earlier rows", () => {
    const cache = new TurboQuantKVCache(8, 3);
    const [k1, v1] = randKV(250, 20);
    const [f1k, f1v] = cache.updateAndFetch(k1, v1);
    f1k.dispose(); f1v.dispose();

    const [k2, v2] = randKV(10, 21); // 250 + 10 = 260 > 256: forces growth mid-cache
    const [f2k, f2v] = cache.updateAndFetch(k2, v2);
    expect(cache.offset).toBe(260);
    expect(f2k.shape[2]).toBe(260);

    // the first 250 rows of the active window must still match their
    // original direct-encode/decode reference (growth must not corrupt
    // the already-written region)
    const [refK1, refV1] = directRoundtrip(k1, v1, 8, 3);
    const f2kFirst250 = f2k.slice([0, 0, 0, 0], [B, H, 250, D]);
    const f2vFirst250 = f2v.slice([0, 0, 0, 0], [B, H, 250, D]);
    expect(toFloatArr(f2kFirst250)).toEqual(toFloatArr(refK1));
    expect(toFloatArr(f2vFirst250)).toEqual(toFloatArr(refV1));

    k1.dispose(); v1.dispose(); k2.dispose(); v2.dispose();
    f2k.dispose(); f2v.dispose(); f2kFirst250.dispose(); f2vFirst250.dispose();
    refK1.dispose(); refV1.dispose();
    cache.dispose();
  });

  test("trim-last-n (rewind) then append: offset shrinks and new writes land correctly", () => {
    const cache = new TurboQuantKVCache(8, 3);
    const [k1, v1] = randKV(6, 30);
    const [f1k, f1v] = cache.updateAndFetch(k1, v1);
    f1k.dispose(); f1v.dispose();
    expect(cache.offset).toBe(6);

    cache.trim(2); // KVCache-style trim: drop the LAST n tokens (offset shrinks)
    expect(cache.offset).toBe(4);
    expect(cache.isTrimmable()).toBe(true);

    const [k2, v2] = randKV(3, 31);
    const [f2k, f2v] = cache.updateAndFetch(k2, v2);
    expect(cache.offset).toBe(7);
    expect(f2k.shape[2]).toBe(7);

    // rows [4:7) must match direct-encoding k2/v2 alone (the trimmed tail
    // was correctly overwritten, not left stale or corrupting the new write)
    const [refK2, refV2] = directRoundtrip(k2, v2, 8, 3);
    const newK = f2k.slice([0, 0, 4, 0], [B, H, 7, D]);
    const newV = f2v.slice([0, 0, 4, 0], [B, H, 7, D]);
    expect(toFloatArr(newK)).toEqual(toFloatArr(refK2));
    expect(toFloatArr(newV)).toEqual(toFloatArr(refV2));

    k1.dispose(); v1.dispose(); k2.dispose(); v2.dispose();
    f2k.dispose(); f2v.dispose(); newK.dispose(); newV.dispose();
    refK2.dispose(); refV2.dispose();
    cache.dispose();
  });

  test("ctor rejects an unsupported head_dim only lazily, on first update", () => {
    const cache = new TurboQuantKVCache(8, 3);
    expect(cache.headDim).toBeNull();
    const [k, v] = randKV(2, 40);
    // shrink to an unsupported head_dim (48: not divisible into {64,128,256,512})
    const kBad = k.slice([0, 0, 0, 0], [B, H, 2, 48]);
    const vBad = v.slice([0, 0, 0, 0], [B, H, 2, 48]);
    expect(() => cache.updateAndFetch(kBad, vBad)).toThrow(/head_dim/);
    k.dispose(); v.dispose(); kBad.dispose(); vBad.dispose();
    cache.dispose();
  });
});

describe("TurboQuantKVCache — kv-store persistence roundtrip", () => {
  test("state()/restoreState() through snapshotCache/loadKvCache is bit-identical", () => {
    const cache = new TurboQuantKVCache(8, 3);
    const [k, v] = randKV(7, 50);
    const [fk, fv] = cache.updateAndFetch(k, v);
    fk.dispose(); fv.dispose();
    k.dispose(); v.dispose();

    const beforeState = cache.state().map(toFloatArr);
    const stub = { makeCache: () => [new TurboQuantKVCache(8, 3)] };
    const dir = mkdtempSync(join(tmpdir(), "mlx-bun-tqkv-"));
    const file = join(dir, "x.mlxkv");
    saveKvCache(file, [1, 2, 3], [cache]);
    cache.dispose();

    const header = readKvHeader(file);
    expect(header.caches).toHaveLength(1);
    expect(header.caches[0]!.kind).toBe("turboquant");
    expect(header.caches[0]!.kBits).toBe(8);
    expect(header.caches[0]!.vBits).toBe(3);
    expect(header.caches[0]!.headDim).toBe(D);
    expect(header.caches[0]!.tensors).toHaveLength(5);

    const loaded = loadKvCache(file, stub, { verify: true });
    expect(loaded.caches).toHaveLength(1);
    const restored = loaded.caches[0] as InstanceType<typeof TurboQuantKVCache>;
    expect(restored).toBeInstanceOf(TurboQuantKVCache);
    expect(restored.offset).toBe(7);
    expect(restored.kBits).toBe(8);
    expect(restored.vBits).toBe(3);

    const afterState = restored.state().map(toFloatArr);
    expect(afterState).toEqual(beforeState);

    for (const c of loaded.caches) c.dispose();
    rmSync(dir, { recursive: true, force: true });
  });

  // The shape v1 serve actually produces on a mixed model (gemma-style):
  // TurboQuant on full-attention layers, plain RotatingKVCache left bf16 on
  // sliding-window layers, interleaved in one Cache[] (2026-07-06
  // integration review: this composition had no coverage).
  test("heterogeneous [turboquant, rotating, turboquant] list round-trips save/load/clone", async () => {
    const { RotatingKVCache } = await import("../src/model/gemma4-base");
    const mkTq = (seed: number) => {
      const c = new TurboQuantKVCache(8, 3);
      const [k, v] = randKV(6, seed);
      const [fk, fv] = c.updateAndFetch(k, v);
      for (const a of [k, v, fk, fv]) a.dispose();
      return c;
    };
    const mkRot = () => {
      const c = new RotatingKVCache(16);
      c.restoreState(
        ops.zeros([1, H, 6, D], Dtype.bfloat16),
        ops.zeros([1, H, 6, D], Dtype.bfloat16),
        6, 0,
      );
      return c;
    };
    const caches = [mkTq(70), mkRot(), mkTq(71)];
    const beforeStates = caches.map((c) => c.state().map(toFloatArr));
    // TurboQuant state() returns fresh views the caller must dispose;
    // rotating returns live arrays (see generate.ts evalCacheState).
    // toFloatArr copies, so the snapshot above is safe either way.

    // clone: per-kind dispatch must be independent of list position
    const clones = cloneKvCaches(caches);
    expect(clones[0]).toBeInstanceOf(TurboQuantKVCache);
    expect(clones[2]).toBeInstanceOf(TurboQuantKVCache);
    expect(clones.map((c) => c.state().map(toFloatArr))).toEqual(beforeStates);
    for (const c of clones) c.dispose();

    // save/load: header records both kinds, restore is bit-identical per slot
    const dir = mkdtempSync(join(tmpdir(), "mlx-bun-tqmix-"));
    const file = join(dir, "mix.mlxkv");
    saveKvCache(file, [1, 2, 3], caches);
    for (const c of caches) c.dispose();

    const header = readKvHeader(file);
    expect(header.caches.map((c) => c.kind)).toEqual(["turboquant", "rotating", "turboquant"]);

    const stub = { makeCache: () => [new TurboQuantKVCache(8, 3), new RotatingKVCache(16), new TurboQuantKVCache(8, 3)] };
    const loaded = loadKvCache(file, stub, { verify: true });
    expect(loaded.caches.map((c) => c.state().map(toFloatArr))).toEqual(beforeStates);
    expect(loaded.caches[1]!.offset).toBe(6);

    for (const c of loaded.caches) c.dispose();
    rmSync(dir, { recursive: true, force: true });
  });
});

describe("TurboQuantKVCache.fromKVCache", () => {
  test("converts an existing bf16 KVCache's live window in one shot, preserving offset", async () => {
    const { KVCache } = await import("../src/model/gemma4-base");
    const src = new KVCache();
    const [k, v] = randKV(5, 60);
    const [fk, fv] = src.updateAndFetch(k, v);
    fk.dispose(); fv.dispose();
    expect(src.offset).toBe(5);

    // compute the reference BEFORE fromKVCache disposes the source
    const [refK, refV] = directRoundtrip(k, v, 8, 3);
    k.dispose(); v.dispose();

    const q = TurboQuantKVCache.fromKVCache(src, 8, 3);
    expect(q.offset).toBe(5);
    expect(q.headDim).toBe(D);

    const state = q.state();
    // state() order is [kIdx, kScales, kZeros, vPacked, vScales]; decode
    // via the same codec path the cache itself uses internally.
    const kIdxU = tq.unpackBits(state[0]!, 8, D); // bits===8: no-op, returns state[0]
    const kOut = tq.decodeKeys(kIdxU, state[1]!, state[2]!);
    const vIdxU = tq.unpackBits(state[3]!, 3, D);
    const vOut = tq.decodeValues(vIdxU, state[4]!, 3);
    expect(toFloatArr(kOut)).toEqual(toFloatArr(refK));
    expect(toFloatArr(vOut)).toEqual(toFloatArr(refV));

    if (vIdxU !== state[3]) vIdxU.dispose();
    kOut.dispose(); vOut.dispose();
    for (const a of state) a.dispose();
    refK.dispose(); refV.dispose();
    q.dispose();
  });
});

describe("TurboQuantKVCache — dispose leak sanity", () => {
  test("repeated create/update/dispose cycles do not grow active memory unboundedly", () => {
    // warm up once (JIT / first-alloc effects) before measuring
    for (let i = 0; i < 3; i++) {
      const cache = new TurboQuantKVCache(8, 3);
      const [k, v] = randKV(4, 100 + i);
      const [fk, fv] = cache.updateAndFetch(k, v);
      k.dispose(); v.dispose(); fk.dispose(); fv.dispose();
      cache.dispose();
    }
    const before = activeMemory();

    for (let i = 0; i < 20; i++) {
      const cache = new TurboQuantKVCache(8, 3);
      const [k, v] = randKV(4, 200 + i);
      const [fk, fv] = cache.updateAndFetch(k, v);
      k.dispose(); v.dispose(); fk.dispose(); fv.dispose();
      cache.dispose();
    }

    const after = activeMemory();
    // a real leak would grow roughly linearly with iteration count (each
    // cache holds 5 arrays over [1,2,256,*] allocations); allow generous
    // slack for allocator fragmentation/pooling, not linear growth.
    expect(after - before).toBeLessThan(4_000_000);
  });

  test("dispose() releases the cache's storage (state() is empty after)", () => {
    const cache = new TurboQuantKVCache(8, 3);
    const [k, v] = randKV(2, 300);
    const [fk, fv] = cache.updateAndFetch(k, v);
    fk.dispose(); fv.dispose(); k.dispose(); v.dispose();
    const live = cache.state(); // fresh views — this cache kind's caller disposes
    expect(live).toHaveLength(5);
    for (const a of live) a.dispose();
    cache.dispose();
    expect(cache.state()).toEqual([]);
    // disposeTurboQuant itself tolerates an arbitrary 5-array tuple
    const t = { kIdx: MlxArray.fromFloat32(new Float32Array(4), [4]),
      kScales: MlxArray.fromFloat32(new Float32Array(1), [1]),
      kZeros: MlxArray.fromFloat32(new Float32Array(1), [1]),
      vPacked: MlxArray.fromFloat32(new Float32Array(4), [4]),
      vScales: MlxArray.fromFloat32(new Float32Array(1), [1]) };
    expect(() => disposeTurboQuant(t)).not.toThrow();
  });

  test("state() itself allocates fresh arrays every call (documents the contract evalCacheState must respect)", () => {
    // Unlike KVCache/QuantizedKVCache (state() returns the cache's own
    // live-owned arrays — same object identity every call), TurboQuantKVCache
    // trims-to-offset on every state() call, so two calls return DISTINCT
    // MlxArray wrappers even with no writes in between.
    const cache = new TurboQuantKVCache(8, 3);
    const [k, v] = randKV(4, 400);
    const [fk, fv] = cache.updateAndFetch(k, v);
    fk.dispose(); fv.dispose(); k.dispose(); v.dispose();

    const s1 = cache.state();
    const s2 = cache.state();
    for (let i = 0; i < s1.length; i++) {
      expect(s1[i]).not.toBe(s2[i]);
      expect(toFloatArr(s1[i]!)).toEqual(toFloatArr(s2[i]!));
    }
    for (const a of [...s1, ...s2]) a.dispose();
    cache.dispose();
  });

  test("evalCacheState (generate.ts's per-chunk materialize step) disposes TurboQuantKVCache's fresh state() arrays but leaves KVCache's live-owned state() arrays usable", async () => {
    const { evalCacheState } = await import("../src/generate");
    const { KVCache } = await import("../src/model/gemma4-base");

    // TurboQuantKVCache side: capture the exact array wrappers state()
    // returns for THIS call by spying on the method, then assert
    // evalCacheState disposed them (a used-after-dispose access throws —
    // array.ts's #disposed guard on the `handle` getter). This is the
    // direct, deterministic counterpart to the activeMemory() heuristic:
    // a real leak means these wrappers stay usable after the call.
    const tqCache = new TurboQuantKVCache(8, 3);
    const [tk, tv] = randKV(4, 700);
    const [tfk, tfv] = tqCache.updateAndFetch(tk, tv);
    tk.dispose(); tv.dispose(); tfk.dispose(); tfv.dispose();

    let capturedTqState: MlxArray[] = [];
    const origState = tqCache.state.bind(tqCache);
    tqCache.state = () => {
      capturedTqState = origState();
      return capturedTqState;
    };

    // KVCache side: its state() returns the SAME live arrays every call —
    // evalCacheState must NOT dispose these (the cache still owns them).
    const kvCache = new KVCache();
    const [kk, kv] = randKV(4, 701);
    const [kfk, kfv] = kvCache.updateAndFetch(kk, kv);
    kk.dispose(); kv.dispose(); kfk.dispose(); kfv.dispose();

    evalCacheState([tqCache, kvCache]);

    expect(capturedTqState.length).toBe(5);
    for (const a of capturedTqState) {
      expect(() => a.handle).toThrow(/used after dispose/);
    }
    // kvCache's own arrays must still be live and readable.
    expect(() => kvCache.state()[0]!.handle).not.toThrow();
    expect(toFloatArr(kvCache.state()[0]!).length).toBeGreaterThan(0);

    tqCache.dispose();
    kvCache.dispose();
  });
});
