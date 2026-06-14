// GATED teacher-forced parity for batched DECODE (phase S1b — the matrix).
//
//   MLX_BUN_TEST_BATCH_DECODE=1 bun test tests/batched-decode-parity.test.ts
//
// Proves a left-padded B=2 batched decode produces, for EACH row, per-step
// distributions matching that row's INDEPENDENT B=1 decode — teacher-forced
// (each row is fed its own solo trajectory), so divergence is a real numerics
// bug, not free-running chaos. Gate = KL(solo || batched) per next-token dist.
// Batching changes the attention kernel's reduction order, so batched decode is
// NOT bit-exact vs single-stream (mlx-lm's batched serving wouldn't be either);
// the principled criterion is low KL, not bit-exactness. (CPM's small headDim
// happens to be batch-invariant — bit-exact there is a bonus, not the rule.)
//
// One reusable harness, one test per (model × layer) matrix cell. GATED behind
// the env + local weights, skipped by default (isolation rule: never in the
// fast suite — model loads OOM alongside it). See docs/design/parallel-slots.md
// for the full matrix.

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { SNAPSHOT, snapshotAvailable } from "./paths";
import type { Cache } from "../src/model/gemma4-base";

const optIn = process.env.MLX_BUN_TEST_BATCH_DECODE === "1";
const CPM_BASE =
  `${process.env.HOME}/.cache/huggingface/hub/` +
  `models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/` +
  `664aabaed233c653f82716d8dc822234d0091f78`;
const haveCpm = existsSync(`${CPM_BASE}/config.json`);
const haveGemma12b = await snapshotAvailable();
const E4B_BASE =
  `${process.env.HOME}/.cache/huggingface/hub/` +
  `models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/` +
  `fcdb12d740cd813634064567fc7cb51159b34253`;
const haveE4b = existsSync(`${E4B_BASE}/config.json`);

/** Run the batched-decode parity harness for one model. prompts[0] MUST be the
 *  longest (→ leftPad 0, the bit-exact row); others are left-padded. Returns
 *  the leftPad-0 row's max logit diff (expected 0) and the max over padded
 *  rows (expected within bf16 noise). */
async function runBatchedDecodeParity(
  base: string, prompts: number[][], steps: number,
): Promise<{ exactRowMax: number; paddedRowMax: number; argmaxMismatch: number; maxKl: number }> {
  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { createModel } = await import("../src/model/factory");
  const { MlxArray } = await import("../src/mlx/array");
  const ops = await import("../src/mlx/ops");
  const { clearCache } = await import("../src/mlx/ffi");
  const { KVCache, RotatingKVCache } = await import("../src/model/gemma4-base");
  const { BatchedDecodeMaskCache } = await import("../src/model/batched-mask");

  const config = await loadModelConfig(base);
  const weights = await Weights.open(base);
  const model = createModel(weights, config);

  const argmaxF = (a: Float32Array): number => {
    let bi = 0;
    for (let i = 1; i < a.length; i++) if (a[i]! > a[bi]!) bi = i;
    return bi;
  };
  const maxAbsDiff = (a: Float32Array, b: Float32Array): number => {
    let m = 0;
    for (let i = 0; i < a.length; i++) m = Math.max(m, Math.abs(a[i]! - b[i]!));
    return m;
  };
  /** KL(softmax(p) || softmax(q)) in nats — the principled "are these the same
   *  distribution?" metric (the L3 gate). Stable: subtract max before exp. */
  const klDiv = (p: Float32Array, q: Float32Array): number => {
    const mp = Math.max(...p), mq = Math.max(...q);
    let zp = 0, zq = 0;
    for (let i = 0; i < p.length; i++) { zp += Math.exp(p[i]! - mp); zq += Math.exp(q[i]! - mq); }
    const lzp = Math.log(zp), lzq = Math.log(zq);
    let kl = 0;
    for (let i = 0; i < p.length; i++) {
      const pp = Math.exp(p[i]! - mp - lzp);
      if (pp > 0) kl += pp * ((p[i]! - mp - lzp) - (q[i]! - mq - lzq));
    }
    return kl;
  };
  const rowLastLogits = (logits: InstanceType<typeof MlxArray>, b: number): Float32Array => {
    const [, L, V] = logits.shape as [number, number, number];
    const s = logits.slice([b, L - 1, 0], [b + 1, L, V]);
    const f = s.toFloat32();
    s.dispose();
    return f;
  };
  const prefill = (prompt: number[]): { cache: Cache[]; firstTok: number } => {
    const cache = model.makeCache();
    const ids = MlxArray.fromInt32(Int32Array.from(prompt), [1, prompt.length]);
    const h = model.forwardHidden(ids, cache);
    ids.dispose();
    const lg = model.logitsFromHidden(h);
    h.dispose();
    const last = rowLastLogits(lg, 0);
    lg.dispose();
    return { cache, firstTok: argmaxF(last) };
  };
  const soloDecode = (cache: Cache[], firstTok: number, n: number) => {
    const logits: Float32Array[] = [];
    const tokens: number[] = [];
    let tok = firstTok;
    for (let s = 0; s < n; s++) {
      tokens.push(tok);
      const tid = MlxArray.fromInt32(Int32Array.from([tok]), [1, 1]);
      const h = model.forwardHidden(tid, cache);
      tid.dispose();
      const lg = model.logitsFromHidden(h);
      h.dispose();
      const ll = rowLastLogits(lg, 0);
      lg.dispose();
      logits.push(ll);
      tok = argmaxF(ll);
      clearCache();
    }
    return { logits, tokens };
  };

  /** Assemble a left-padded batched cache from per-row prefills, PER LAYER and
   *  per cache type: KVCache → restoreState(k,v,Lmax); RotatingKVCache (pre-wrap
   *  only — offset < window) → restoreState(k,v,Lmax,Lmax) and the wrapper
   *  carries the window so buildBatchedDecodeMask applies it. Copies KV so the
   *  source caches stay usable for the solo reference. */
  const assemble = (caches: Cache[][], lens: number[]): Cache[] => {
    const B = caches.length;
    const Lmax = Math.max(...lens);
    const leftPad = lens.map((l) => Lmax - l);
    const numLayers = caches[0]!.length;
    const out: Cache[] = [];
    for (let i = 0; i < numLayers; i++) {
      const proto = caches[0]![i]!;
      const window = (proto as { maxSize?: number }).maxSize ?? null;
      if (window !== null && Lmax >= window)
        throw new Error(`sliding layer ${i}: prompt ${Lmax} >= window ${window} — ring-wrap batched decode is NYI (S1b sliding follow-up)`);
      const ks: InstanceType<typeof MlxArray>[] = [];
      const vs: InstanceType<typeof MlxArray>[] = [];
      for (let b = 0; b < B; b++) {
        const [k0, v0] = (caches[b]![i] as InstanceType<typeof KVCache>).temporalView();
        let k = k0, v = v0;
        const pad = leftPad[b]!;
        if (pad > 0) {
          const [, H, , D] = k.shape as [number, number, number, number];
          const vD = v.shape[3]!;
          const zK = ops.zeros([1, H, pad, D], k.dtype);
          const zV = ops.zeros([1, H, pad, vD], v.dtype);
          const k2 = ops.concatAxis([zK, k], 2);
          const v2 = ops.concatAxis([zV, v], 2);
          for (const a of [k, v, zK, zV]) a.dispose();
          k = k2; v = v2;
        }
        ks.push(k); vs.push(v);
      }
      const kB = ops.concatAxis(ks, 0);
      const vB = ops.concatAxis(vs, 0);
      for (const a of [...ks, ...vs]) a.dispose();
      let nc: Cache;
      if (window !== null) {
        const r = new RotatingKVCache(window);
        r.restoreState(kB, vB, Lmax, Lmax); // pre-wrap: idx == offset, no rotation
        nc = r;
      } else {
        const c = new KVCache();
        c.restoreState(kB, vB, Lmax);
        nc = c;
      }
      out.push(new BatchedDecodeMaskCache(nc, B, leftPad, window));
    }
    ops.evalAll(out.flatMap((c) => c.state()));
    return out;
  };

  try {
    const lens = prompts.map((p) => p.length);
    const ps = prompts.map(prefill);
    const batched = assemble(ps.map((p) => p.cache), lens);
    const solos = ps.map((p) => soloDecode(p.cache, p.firstTok, steps));

    const Lmax = Math.max(...lens);
    const leftPad = lens.map((l) => Lmax - l);
    let exactRowMax = 0, paddedRowMax = 0, argmaxMismatch = 0, maxKl = 0;
    for (let s = 0; s < steps; s++) {
      const stepToks = solos.map((so) => so.tokens[s]!);
      const ids = MlxArray.fromInt32(Int32Array.from(stepToks), [prompts.length, 1]);
      const h = model.forwardHidden(ids, batched);
      ids.dispose();
      const lg = model.logitsFromHidden(h);
      h.dispose();
      for (let b = 0; b < prompts.length; b++) {
        const row = rowLastLogits(lg, b);
        const d = maxAbsDiff(row, solos[b]!.logits[s]!);
        if (leftPad[b] === 0) exactRowMax = Math.max(exactRowMax, d);
        else paddedRowMax = Math.max(paddedRowMax, d);
        maxKl = Math.max(maxKl, klDiv(solos[b]!.logits[s]!, row));
        if (argmaxF(row) !== argmaxF(solos[b]!.logits[s]!)) argmaxMismatch++;
      }
      lg.dispose();
      clearCache();
    }
    for (const c of batched) c.dispose();
    for (const p of ps) for (const c of p.cache) c.dispose();
    return { exactRowMax, paddedRowMax, argmaxMismatch, maxKl };
  } finally {
    weights.dispose();
  }
}

/** The REAL mlx-bun batched path: left-pad prompts → one batched cache
 *  (BatchedDecodeMaskCache handles BOTH the prefill mask at offset 0 and the
 *  per-step decode mask + per-row RoPE) → batch-prefill → greedy batch-decode.
 *  Mirrors mlx-lm's BatchKVCache flow, so its per-row greedy trajectory is the
 *  thing compared bit-for-bit against the mlx-lm B=N oracle (tests/fixtures). */
async function realBatchedGreedy(
  base: string, prompts: number[][], steps: number,
): Promise<number[][]> {
  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { createModel } = await import("../src/model/factory");
  const { MlxArray } = await import("../src/mlx/array");
  const { clearCache } = await import("../src/mlx/ffi");
  const { BatchedDecodeMaskCache } = await import("../src/model/batched-mask");

  const config = await loadModelConfig(base);
  const weights = await Weights.open(base);
  const model = createModel(weights, config);

  const B = prompts.length;
  const Lmax = Math.max(...prompts.map((p) => p.length));
  const leftPad = prompts.map((p) => Lmax - p.length);
  const padded = prompts.map((p) => [...Array(Lmax - p.length).fill(0), ...p]); // left-pad 0

  const argmaxF = (a: Float32Array): number => {
    let bi = 0;
    for (let i = 1; i < a.length; i++) if (a[i]! > a[bi]!) bi = i;
    return bi;
  };
  const perRowLastTok = (lg: InstanceType<typeof MlxArray>): number[] => {
    const [, L, V] = lg.shape as [number, number, number];
    const out: number[] = [];
    for (let b = 0; b < B; b++) {
      const s = lg.slice([b, L - 1, 0], [b + 1, L, V]);
      const f = s.toFloat32();
      s.dispose();
      out.push(argmaxF(f));
    }
    return out;
  };

  try {
    const real = model.makeCache(); // per-layer KVCache / RotatingKVCache, offset 0
    const cacheWindow = (c: Cache) => (c as { maxSize?: number }).maxSize ?? null;
    const batched: Cache[] = real.map((c) => new BatchedDecodeMaskCache(c, B, leftPad, cacheWindow(c)));

    // Batch-prefill the left-padded batch (offset 0 → the wrapper emits the
    // left-pad prefill mask + ropeOffsetArr = -leftPad, matching BatchKVCache).
    const ids = MlxArray.fromInt32(Int32Array.from(padded.flat()), [B, Lmax]);
    let h = model.forwardHidden(ids, batched);
    ids.dispose();
    let lg = model.logitsFromHidden(h);
    h.dispose();
    let toks = perRowLastTok(lg);
    lg.dispose();
    clearCache();

    const traj: number[][] = Array.from({ length: B }, () => []);
    for (let s = 0; s < steps; s++) {
      toks.forEach((t, b) => traj[b]!.push(t));
      const tid = MlxArray.fromInt32(Int32Array.from(toks), [B, 1]);
      h = model.forwardHidden(tid, batched);
      tid.dispose();
      lg = model.logitsFromHidden(h);
      h.dispose();
      toks = perRowLastTok(lg);
      lg.dispose();
      clearCache();
    }
    for (const c of batched) c.dispose();
    return traj;
  } finally {
    weights.dispose();
  }
}

const PROMPTS = [
  [1, 100, 200, 300, 400, 500, 600], // len 7 → leftPad 0 (bit-exact row)
  [1, 150, 250, 350, 450], // len 5 → leftPad 2
];
const STEPS = 8;
const TOL = 5e-1; // bf16 reduction-order noise from the left-pad column shift
// Universal gate: KL(solo || batched) per next-token distribution. Batching
// changes the attention kernel's reduction order, so batched decode is NOT
// bit-exact vs single-stream (bit-exact unpadded is a CPM-only artifact — its
// small headDim happens to be batch-invariant). KL is the principled measure:
// benign batch noise lands ~5e-3; a real distribution shift (the Gemma padded
// bug) is ~2e-1. 1e-2 cleanly separates them.
const KL_TOL = 1e-2;

// --- CPM (MiniCPM5-1B, Llama): all full-attention; L1 (bf16 KV) ---
describe.skipIf(!optIn || !haveCpm)("batched decode parity — CPM L1 (bf16)", () => {
  test("B=2 left-padded decode == two B=1 decodes (KL gate)", async () => {
    const r = await runBatchedDecodeParity(CPM_BASE, PROMPTS, STEPS);
    console.log(`[parity CPM L1] exactRow=${r.exactRowMax.toExponential(2)} paddedRow=${r.paddedRowMax.toExponential(2)} argmaxMismatch=${r.argmaxMismatch} maxKL=${r.maxKl.toExponential(2)}`);
    expect(r.maxKl).toBeLessThan(KL_TOL); // universal gate
    expect(r.exactRowMax).toBe(0); // CPM bonus: small-headDim batched attn is bit-invariant
  }, 180_000);
});

// --- THE REAL GATE: mlx-bun's real batched prefill+decode greedy trajectory
//     must match mlx-lm's batched B=N (BatchKVCache) exactly. Oracle fixture
//     from scripts/gen-batched-golden.py (run in the oracle venv). ---
describe.skipIf(!optIn || !haveCpm)("batched decode ORACLE parity — CPM L1 vs mlx-lm B=2", () => {
  test("real batched greedy trajectory == mlx-lm B=2", async () => {
    const golden = await Bun.file(`${import.meta.dir}/fixtures/batched-golden-cpm.json`).json();
    const got = await realBatchedGreedy(CPM_BASE, golden.prompts as number[][], golden.steps as number);
    console.log(`[oracle CPM] mlx-bun: ${JSON.stringify(got)}`);
    console.log(`[oracle CPM] mlx-lm:  ${JSON.stringify(golden.trajectories)}`);
    expect(got).toEqual(golden.trajectories);
  }, 180_000);
});

// --- Gemma 12B L1 (bf16 KV) vs mlx-lm B=2 oracle (sliding layers →
//     BatchRotatingKVCache; short-context/pre-wrap). THE real gate for the
//     Gemma cell that the KL harness couldn't judge. ---
describe.skipIf(!optIn || !haveGemma12b)("batched decode ORACLE parity — Gemma 12B L1 vs mlx-lm B=2", () => {
  test("real batched greedy trajectory == mlx-lm B=2", async () => {
    const golden = await Bun.file(`${import.meta.dir}/fixtures/batched-golden-gemma12b.json`).json();
    const got = await realBatchedGreedy(SNAPSHOT, golden.prompts as number[][], golden.steps as number);
    console.log(`[oracle Gemma12B] mlx-bun: ${JSON.stringify(got)}`);
    console.log(`[oracle Gemma12B] mlx-lm:  ${JSON.stringify(golden.trajectories)}`);
    expect(got).toEqual(golden.trajectories);
  }, 240_000);
});

// --- Gemma e4b L1 (bf16 KV) vs mlx-lm B=2 oracle. Exercises per-layer-input
//     embeddings (the [1,L,…] hardcode → made B-generic) + KV-sharing. ---
describe.skipIf(!optIn || !haveE4b)("batched decode ORACLE parity — Gemma e4b L1 vs mlx-lm B=2", () => {
  test("real batched greedy trajectory == mlx-lm B=2", async () => {
    const golden = await Bun.file(`${import.meta.dir}/fixtures/batched-golden-e4b.json`).json();
    const got = await realBatchedGreedy(E4B_BASE, golden.prompts as number[][], golden.steps as number);
    console.log(`[oracle e4b] mlx-bun: ${JSON.stringify(got)}`);
    console.log(`[oracle e4b] mlx-lm:  ${JSON.stringify(golden.trajectories)}`);
    expect(got).toEqual(golden.trajectories);
  }, 240_000);
});

// --- Gemma 12B: dense, interleaved sliding/full attention; L1 (bf16 KV) ---
// Short prompts (≪ 1024 window) → pre-wrap, window inactive: validates the
// monolith Gemma path + base Attention + RotatingKVCache(pre-wrap) batched
// plumbing. Window-active / ring-wrap is the sliding-window follow-up.
// WIP (S1b Gemma cell). Two findings (KL-separated):
//  (1) unpadded row: KL ~5e-3, content-INDEPENDENT (same with identical
//      prompts) → benign mlx batched-attention reduction-order noise, NOT a bug.
//  (2) PADDED row: KL ~2.6e-1 → a REAL Gemma-specific error, even though its
//      mask + rope are mechanically identical to CPM's padded row (KL 7e-4).
//      Leading hypothesis: at Gemma's score magnitudes (headDim 256, scale 1.0)
//      the bool mask doesn't fully clamp the zero-padding columns to -inf, so
//      padding leaks (harmless at CPM's magnitudes). Needs layer-level
//      instrumentation. Diagnostic only (no hard assert) — see docs/design/parallel-slots.md.
describe.skipIf(!optIn || !haveGemma12b)("batched decode parity — Gemma 12B L1 (bf16, short-context) [WIP]", () => {
  // DIAGNOSTIC: B=1 through the wrapper (no cross-row, no left-pad) isolates
  // "is it the wrapper (array mask / ropeDynamic) on Gemma?" from "is it B=2
  // batching?". If exactRow != 0 here, the wrapper itself diverges for Gemma.
  test("diagnostic B=1 (wrapper only, no batching)", async () => {
    const r = await runBatchedDecodeParity(SNAPSHOT, [PROMPTS[0]!], STEPS);
    console.log(`[parity Gemma12B B=1] exactRow=${r.exactRowMax.toExponential(2)} (want 0) argmaxMismatch=${r.argmaxMismatch} maxKL=${r.maxKl.toExponential(2)}`);
  }, 240_000);

  // DIAGNOSTIC: two IDENTICAL prompts (B=2, no left-pad). Both rows == soloA.
  // If exactRow ≈ the B=2-with-different-content number → batch-kernel noise
  // (content-independent). If exactRow ≈ 0 → row1's CONTENT was leaking (a real
  // isolation bug). Distinguishes "mlx batched-attn numerics" from "leak".
  test("diagnostic B=2 identical prompts (no left-pad)", async () => {
    const r = await runBatchedDecodeParity(SNAPSHOT, [PROMPTS[0]!, PROMPTS[0]!], STEPS);
    console.log(`[parity Gemma12B B=2 identical] exactRow=${r.exactRowMax.toExponential(2)} (want 0) argmaxMismatch=${r.argmaxMismatch} maxKL=${r.maxKl.toExponential(2)}`);
  }, 240_000);

  test("diagnostic: B=2 left-padded decode vs two B=1 decodes", async () => {
    const r = await runBatchedDecodeParity(SNAPSHOT, PROMPTS, STEPS);
    console.log(`[parity Gemma12B L1 WIP] exactRow=${r.exactRowMax.toExponential(2)} (want 0) paddedRow=${r.paddedRowMax.toExponential(2)} argmaxMismatch=${r.argmaxMismatch} maxKL=${r.maxKl.toExponential(2)}`);
    // No assertion yet — cell is WIP (sliding-layer mask divergence under debug).
  }, 240_000);
});
