// KV-cache persistence (slow tier): save → load (streamed copy-restore) →
// continuation must be token-identical; loading + first token must meet
// the Phase 5 cold-start criterion (< 1s for a cached-prefix prompt).

import { describe, expect, test } from "bun:test";
import { goldenAt } from "./goldens";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { SNAPSHOT, snapshotAvailable } from "./paths";

const haveWeights = await snapshotAvailable();
const haveGoldens = await goldenAt("parity.json").exists();

describe.skipIf(!haveWeights || !haveGoldens)("kv-cache persistence", async () => {
  if (!haveWeights || !haveGoldens) return;
  const golden = (await goldenAt("parity.json").json()) as {
    prompt_ids: number[];
    greedy_ids: number[];
  };

  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { Gemma4Model } = await import("../src/model/gemma4");
  const { generate } = await import("../src/generate");
  const { saveKvCache, loadKvCache, readKvHeader } = await import("../src/kv-store");
  const ops = await import("../src/mlx/ops");

  const config = await loadModelConfig(SNAPSHOT);
  const weights = await Weights.open(SNAPSHOT);
  const model = new Gemma4Model(weights, config);
  const dir = mkdtempSync(join(tmpdir(), "mlx-bun-kv-"));

  test("save → load → continuation is token-identical; TTFT < 1s", async () => {
    // prefill the prompt and persist the caches
    const caches = model.makeCache();
    const ids = ops.fromInt32(golden.prompt_ids, [1, golden.prompt_ids.length]);
    const h = model.forwardHidden(ids, caches);
    ops.evalAll(caches.flatMap((c) => c.state()));
    h.dispose();
    ids.dispose();
    const file = join(dir, "prefix.mlxkv");
    saveKvCache(file, golden.prompt_ids, caches);
    for (const c of caches) c.dispose();

    const header = readKvHeader(file);
    expect(header.tokens).toEqual(golden.prompt_ids);
    expect(header.caches).toHaveLength(48);

    // reload zero-copy and continue with one extra token (the harness
    // prompt + first greedy token) — must match the golden sequence
    const t0 = performance.now();
    const loaded = loadKvCache(file, model);
    const prompt = [...golden.prompt_ids, golden.greedy_ids[0]!];
    const gen = generate(model, prompt, {
      maxTokens: 12, temperature: 0, cache: loaded.caches,
    });
    const out: number[] = [];
    let ttftMs = 0;
    for await (const t of gen) {
      if (out.length === 0) ttftMs = performance.now() - t0;
      out.push(t.token);
    }
    expect(gen.stats!.cachedTokens).toBe(golden.prompt_ids.length);
    expect(out).toEqual(golden.greedy_ids.slice(1, 13));

    console.log(`    cold cache-load → first token: ${ttftMs.toFixed(0)} ms`);
    // in-suite bound is loose (GPU pressure from prior tests inflates it);
    // the real criterion harness is scripts/cold-start.ts in a fresh process
    expect(ttftMs).toBeLessThan(3000);

    for (const c of loaded.caches) c.dispose();
    rmSync(dir, { recursive: true, force: true });
  }, 240_000);

  // v2: the serving DEFAULT is kv_config quantization — those caches must
  // round-trip too (qkv on full layers + rotating-qkv on sliding layers).
  // Fork-compare: save mid-generation, continue in memory AND from the
  // reloaded file — greedy ids must match token-for-token.
  test("quantized (kv_config) save → load → continuation is token-identical", async () => {
    const { maybeQuantizeKv } = await import("../src/generate");
    const { MlxArray } = await import("../src/mlx/array");
    const { clearCache } = await import("../src/mlx/ffi");
    expect(config.kvQuant?.length).toBeGreaterThan(0); // 12B ships kv_config.json

    const argmaxLast = (lg: InstanceType<typeof MlxArray>): number => {
      const [, L, V] = lg.shape as [number, number, number];
      const s = lg.slice([0, L - 1, 0], [1, L, V]);
      const f = s.toFloat32();
      s.dispose();
      let bi = 0;
      for (let i = 1; i < f.length; i++) if (f[i]! > f[bi]!) bi = i;
      return bi;
    };
    const stepGreedy = (caches: import("../src/model/gemma4-base").Cache[], tok: number): number => {
      const tid = MlxArray.fromInt32(Int32Array.from([tok]), [1, 1]);
      const h = model.forwardHidden(tid, caches);
      tid.dispose();
      const lg = model.logitsFromHidden(h);
      h.dispose();
      const next = argmaxLast(lg);
      lg.dispose();
      return next;
    };

    const caches = model.makeCache();
    const ids = ops.fromInt32(golden.prompt_ids, [1, golden.prompt_ids.length]);
    const h = model.forwardHidden(ids, caches);
    ids.dispose();
    const lg = model.logitsFromHidden(h);
    h.dispose();
    let tok = argmaxLast(lg);
    lg.dispose();
    maybeQuantizeKv(caches, { kvConfig: config.kvQuant! });
    // advance a few quantized steps so the saved state is mid-generation
    for (let i = 0; i < 4; i++) tok = stepGreedy(caches, tok);
    ops.evalAll(caches.flatMap((c) => c.state()));

    const dirQ = mkdtempSync(join(tmpdir(), "mlx-bun-kvq-"));
    const file = join(dirQ, "prefix.mlxkv");
    saveKvCache(file, golden.prompt_ids, caches, { modelId: "gemma-12b-test" });
    const kinds = new Set(readKvHeader(file).caches.map((c) => c.kind));
    expect(kinds.has("qkv")).toBe(true);
    expect(kinds.has("rotating-qkv")).toBe(true);

    // fork A: continue in memory
    const memIds: number[] = [];
    let a = tok;
    for (let i = 0; i < 8; i++) { a = stepGreedy(caches, a); memIds.push(a); }
    for (const c of caches) c.dispose();
    clearCache();

    // fork B: continue from the reloaded file (verify=true exercises hashes)
    const loaded = loadKvCache(file, model, { verify: true });
    const diskIds: number[] = [];
    let b = tok;
    for (let i = 0; i < 8; i++) { b = stepGreedy(loaded.caches, b); diskIds.push(b); }
    expect(diskIds).toEqual(memIds);
    for (const c of loaded.caches) c.dispose();
    rmSync(dirQ, { recursive: true, force: true });
  }, 300_000);
});

// SSM (Qwen3.5 hybrid): conv/recurrent state + full-attention KV round-trip.
const QWEN_BASE =
  `${process.env.HOME}/.cache/huggingface/hub/` +
  `models--mlx-community--Qwen3.5-4B-OptiQ-4bit/snapshots/` +
  `6676059ab512d8b2be6c126d20bc651a4278fc4b`;
const { existsSync } = await import("node:fs");

describe.skipIf(!existsSync(`${QWEN_BASE}/config.json`))("kv-cache persistence — SSM (Qwen3.5)", () => {
  test("ssm save → load → continuation is token-identical", async () => {
    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { createModel } = await import("../src/model/factory");
    const { saveKvCache, loadKvCache, readKvHeader } = await import("../src/kv-store");
    const { MlxArray } = await import("../src/mlx/array");
    const ops = await import("../src/mlx/ops");

    const config = await loadModelConfig(QWEN_BASE);
    const weights = await Weights.open(QWEN_BASE);
    const model = createModel(weights, config);
    try {
      const argmaxLast = (lg: InstanceType<typeof MlxArray>): number => {
        const [, L, V] = lg.shape as [number, number, number];
        const s = lg.slice([0, L - 1, 0], [1, L, V]);
        const f = s.toFloat32();
        s.dispose();
        let bi = 0;
        for (let i = 1; i < f.length; i++) if (f[i]! > f[bi]!) bi = i;
        return bi;
      };
      const stepGreedy = (caches: import("../src/model/gemma4-base").Cache[], tok: number): number => {
        const tid = MlxArray.fromInt32(Int32Array.from([tok]), [1, 1]);
        const h = model.forwardHidden(tid, caches);
        tid.dispose();
        const lg = model.logitsFromHidden(h);
        h.dispose();
        const next = argmaxLast(lg);
        lg.dispose();
        return next;
      };

      const prompt = [1, 100, 200, 300, 400, 500, 600];
      const caches = model.makeCache();
      const ids = ops.fromInt32(prompt, [1, prompt.length]);
      const h = model.forwardHidden(ids, caches);
      ids.dispose();
      const lg = model.logitsFromHidden(h);
      h.dispose();
      let tok = argmaxLast(lg);
      lg.dispose();
      for (let i = 0; i < 2; i++) tok = stepGreedy(caches, tok);
      ops.evalAll(caches.flatMap((c) => c.state()));

      const dir = mkdtempSync(join(tmpdir(), "mlx-bun-kvssm-"));
      const file = join(dir, "prefix.mlxkv");
      saveKvCache(file, prompt, caches);
      const kinds = new Set(readKvHeader(file).caches.map((c) => c.kind));
      expect(kinds.has("ssm")).toBe(true);
      expect(kinds.has("kv")).toBe(true);

      const memIds: number[] = [];
      let a = tok;
      for (let i = 0; i < 6; i++) { a = stepGreedy(caches, a); memIds.push(a); }
      for (const c of caches) c.dispose();

      const loaded = loadKvCache(file, model, { verify: true });
      const diskIds: number[] = [];
      let b = tok;
      for (let i = 0; i < 6; i++) { b = stepGreedy(loaded.caches, b); diskIds.push(b); }
      expect(diskIds).toEqual(memIds);
      for (const c of loaded.caches) c.dispose();
      rmSync(dir, { recursive: true, force: true });
    } finally {
      weights.dispose();
    }
  }, 300_000);
});

// Copy-restore byte identity, model-free, ALL FIVE cache kinds: the
// streamed copy-restore (2026-07-07, replacing the zero-copy mmap wrap)
// must hand back byte-identical tensors. Proven by save → load(verify) →
// re-save: identical per-tensor hashes (fixed-width Bun.hash of the raw
// bytes) mean the copies match the originals bit-for-bit. Also pins the
// KVCache STEP pre-sizing: restored full-attention caches carry ≥1 token
// of slack so the first post-restore step never concat-copies the entry.
describe("kv-store copy-restore byte identity", () => {
  test("save → load → re-save keeps every tensor hash; restored KVCache is STEP-sized", async () => {
    const { saveKvCache, loadKvCache, readKvHeader } = await import("../src/kv-store");
    const {
      KVCache, RotatingKVCache, QuantizedKVCache, RotatingQuantizedKVCache,
    } = await import("../src/model/gemma4-base");
    const { SSMCache } = await import("../src/model/qwen3-delta");
    const { MlxArray } = await import("../src/mlx/array");
    const { Dtype } = await import("../src/mlx/ffi");
    const ops = await import("../src/mlx/ops");

    // deterministic pseudo-random bf16 data (seeded LCG)
    let seed = 0x2545f491;
    const rnd = (): number => {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      return seed / 0x40000000 - 1;
    };
    const randBf16 = (shape: number[]): InstanceType<typeof MlxArray> => {
      const n = shape.reduce((a, b) => a * b, 1);
      const f = MlxArray.fromFloat32(Float32Array.from({ length: n }, rnd), shape);
      const b = f.astype(Dtype.bfloat16).eval();
      f.dispose();
      return b;
    };
    const qt = (shape: number[], g: number, bits: number): import("../src/mlx/ops").QuantizedTensor => {
      const w = randBf16(shape);
      const t = ops.quantize(w, g, bits);
      ops.evalAll([t.packed, t.scales, t.biases]);
      w.dispose();
      return t;
    };

    const kv = new KVCache();
    kv.restoreState(randBf16([1, 2, 8, 16]), randBf16([1, 2, 8, 16]), 8);
    const rot = new RotatingKVCache(8);
    rot.restoreState(randBf16([1, 2, 8, 16]), randBf16([1, 2, 8, 16]), 10, 2); // post-wrap ring
    const qkv = new QuantizedKVCache(64, 8);
    qkv.restoreState(qt([1, 2, 4, 64], 64, 8), qt([1, 2, 4, 64], 64, 8), 4);
    const rq = new RotatingQuantizedKVCache(8, 64, 4);
    rq.restoreState(qt([1, 2, 8, 64], 64, 4), qt([1, 2, 8, 64], 64, 4), 12, 4);
    const ssm = new SSMCache();
    ssm.conv = randBf16([1, 4, 3, 8]);
    ssm.recurrent = randBf16([1, 4, 8, 8]);
    ssm.offset = 5;
    const caches = [kv, rot, qkv, rq, ssm];
    const stub = { makeCache: () => [new KVCache(), new KVCache(), new KVCache(), new KVCache(), new KVCache()] };

    const dir = mkdtempSync(join(tmpdir(), "mlx-bun-kvrt-"));
    const f1 = join(dir, "a.mlxkv");
    const f2 = join(dir, "b.mlxkv");
    saveKvCache(f1, [1, 2, 3], caches, {});
    for (const c of caches) c.dispose();

    const loaded = loadKvCache(f1, stub, { verify: true });

    // STEP pre-sizing: the restored plain KVCache has slack capacity, and
    // the first 1-token update advances in place (no grow/realloc).
    const lkv = loaded.caches[0] as InstanceType<typeof KVCache>;
    expect(lkv.keys!.shape[2]).toBe(256);
    const one = randBf16([1, 2, 1, 16]);
    const [K, V] = lkv.updateAndFetch(one, one);
    ops.evalAll([K, V]);
    expect(lkv.offset).toBe(9);
    expect(lkv.keys!.shape[2]).toBe(256);
    K.dispose(); V.dispose(); one.dispose();
    lkv.trim(1); // back to the persisted state for the re-save

    saveKvCache(f2, [1, 2, 3], loaded.caches, {});
    for (const c of loaded.caches) c.dispose();

    const strip = (h: ReturnType<typeof readKvHeader>) =>
      h.caches.map((e) => ({
        kind: e.kind, offset: e.offset, idx: e.idx, maxSize: e.maxSize,
        groupSize: e.groupSize, bits: e.bits,
        tensors: e.tensors.map((t) => ({ bytes: t.bytes, shape: t.shape, dtype: t.dtype, hash: t.hash })),
      }));
    expect(strip(readKvHeader(f2))).toEqual(strip(readKvHeader(f1)));
    rmSync(dir, { recursive: true, force: true });
  });
});

// Integrity + atomicity: no model needed — hand-built caches.
describe("kv-store v2 integrity", () => {
  test("header hash catches corruption; metadata mismatches reject; writes are atomic", async () => {
    const { saveKvCache, loadKvCache, readKvHeader } = await import("../src/kv-store");
    const { KVCache } = await import("../src/model/gemma4-base");
    const { Dtype } = await import("../src/mlx/ffi");
    const ops = await import("../src/mlx/ops");
    const { openSync, writeSync, closeSync, readdirSync } = await import("node:fs");

    const mk = (): InstanceType<typeof KVCache> => {
      const c = new KVCache();
      const k = ops.zeros([1, 2, 4, 8], Dtype.bfloat16);
      const v = ops.zeros([1, 2, 4, 8], Dtype.bfloat16);
      c.restoreState(k, v, 4);
      return c;
    };
    const stub = { makeCache: () => [mk(), mk()] };
    const dir = mkdtempSync(join(tmpdir(), "mlx-bun-kvi-"));
    const file = join(dir, "x.mlxkv");
    const caches = [mk(), mk()];
    saveKvCache(file, [1, 2, 3, 4], caches, {
      modelId: "stub", configFingerprint: "fp-a", tokenizerHash: "tk-a", ns: "",
    });
    for (const c of caches) c.dispose();

    // atomic: no .tmp orphan after a successful save
    expect(readdirSync(dir).filter((f) => f.endsWith(".tmp"))).toEqual([]);

    // metadata guards
    const okLoad = loadKvCache(file, stub, { configFingerprint: "fp-a", tokenizerHash: "tk-a" });
    expect(okLoad.tokens).toEqual([1, 2, 3, 4]);
    for (const c of okLoad.caches) c.dispose();
    expect(() => loadKvCache(file, stub, { configFingerprint: "fp-B" })).toThrow(/configFingerprint/);
    expect(() => loadKvCache(file, { makeCache: () => [mk()] })).toThrow(/cached layers/);

    // header corruption: flip a byte inside the JSON region
    const fd = openSync(file, "r+");
    writeSync(fd, new Uint8Array([0x7a]), 0, 1, 30);
    closeSync(fd);
    expect(() => readKvHeader(file)).toThrow(/hash mismatch|not an mlx-bun/);

    rmSync(dir, { recursive: true, force: true });
  });
});
