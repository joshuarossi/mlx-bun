// GATED: the continuous-batching scheduler (src/serve/batch-scheduler.ts).
//
//   MLX_BUN_TEST_BATCH_DECODE=1 bun test tests/batch-scheduler.test.ts
//
// The batched FORWARD and the dynamic-B cache ops are already oracle-verified
// (tests/batched-decode-parity.test.ts, tests/batched-rotating.test.ts). This
// gates the ORCHESTRATION on top — admission (solo prefill + merge into a
// running batch, per-layer by attention type), the step loop, per-row sampling
// + token accounting, and eviction (filter).
//
// METHODOLOGY — teacher-forced, NOT free-running greedy. Batched decode is not
// bit-exact vs solo (left-padding shifts each row's attention reduction order),
// so comparing free-running greedy *trajectories* measures chaos: one bf16
// argmax flip cascades (see memory: teacher-forced-gating-for-non-bitexact-paths).
// Instead we FORCE each row to follow its solo-greedy trajectory and compare the
// scheduler's per-row *logits* to the solo teacher-forced logits via KL. Forcing
// makes eviction/join timing deterministic; KL tolerates benign batch noise but
// still catches a real bug (wrong leftPad after evict/join, mis-routed tokens)
// as a logit shift. Plus a routing assertion: each row's emitted tokens, counts,
// and finish reason are exactly what the schedule dictates.
//
// Two models: CPM (all full-attention) and Gemma 12B (interleaved sliding +
// full — the mixed-layer path through the scheduler). Short prompts → the Gemma
// sliding window doesn't wrap here; the ring-wrap math is gated bit-exact vs
// mlx-lm model-free in tests/batched-rotating.test.ts.

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { SNAPSHOT, snapshotAvailable } from "./paths";

const optIn = process.env.MLX_BUN_TEST_BATCH_DECODE === "1";
const CPM_BASE =
  `${process.env.HOME}/.cache/huggingface/hub/` +
  `models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/` +
  `664aabaed233c653f82716d8dc822234d0091f78`;
const haveCpm = existsSync(`${CPM_BASE}/config.json`);
const haveGemma = await snapshotAvailable();

const delay = (ms: number) => new Promise<void>((r) => setTimeout(r, ms));

// KL(softmax(p) || softmax(q)) in nats — the "same distribution?" metric.
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
const KL_TOL = 1e-2; // benign batch noise ~5e-3; a real shift is ~2e-1

const PROMPTS = [
  [1, 100, 200, 300, 400, 500, 600], // len 7
  [1, 150, 250, 350, 450], // len 5
  [1, 130, 230, 330, 430, 530], // len 6
];
const STEPS = 11;
const MAXTOK = [5, 8, 11]; // staggered → rows evict at different steps

/** Teacher-forced scheduler parity for one model: each of three rows is forced
 *  along its solo-greedy trajectory; the scheduler's per-row logits must match
 *  solo (KL, bound `klTol` — per-model, see the Gemma case); emitted
 *  tokens/counts/finish are exactly the schedule. Run twice — all-at-once
 *  (staggered eviction 3→2→1→0) and a mid-stream join. */
const argmaxF = (a: Float32Array): number => {
  let bi = 0;
  for (let i = 1; i < a.length; i++) if (a[i]! > a[bi]!) bi = i;
  return bi;
};

/** Model + the solo-greedy reference harness (shared by the parity gate and
 *  the Phase-3.2 gates below). Caller owns disposal via `weights`. */
async function openHarness(base: string) {
  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { createModel } = await import("../src/model/factory");
  const { MlxArray } = await import("../src/mlx/array");
  const { clearCache } = await import("../src/mlx/ffi");

  const config = await loadModelConfig(base);
  const weights = await Weights.open(base);
  const model = createModel(weights, config);

  const lastRowLogits = (lg: InstanceType<typeof MlxArray>): Float32Array => {
    const [, L, V] = lg.shape as [number, number, number];
    const s = lg.slice([0, L - 1, 0], [1, L, V]);
    const f = s.toFloat32();
    s.dispose();
    return f;
  };
  const soloGreedy = (prompt: number[], steps: number): { tokens: number[]; logits: Float32Array[] } => {
    const cache = model.makeCache();
    try {
      const ids = MlxArray.fromInt32(Int32Array.from(prompt), [1, prompt.length]);
      const h = model.forwardHidden(ids, cache);
      ids.dispose();
      const lg = model.logitsFromHidden(h);
      h.dispose();
      let L = lastRowLogits(lg);
      lg.dispose();
      const logits = [L];
      const tokens = [argmaxF(L)];
      clearCache();
      for (let s = 1; s < steps; s++) {
        const tid = MlxArray.fromInt32(Int32Array.from([tokens[s - 1]!]), [1, 1]);
        const h2 = model.forwardHidden(tid, cache);
        tid.dispose();
        const lg2 = model.logitsFromHidden(h2);
        h2.dispose();
        L = lastRowLogits(lg2);
        lg2.dispose();
        logits.push(L);
        tokens.push(argmaxF(L));
        clearCache();
      }
      return { tokens, logits };
    } finally {
      for (const c of cache) c.dispose();
    }
  };
  return { model, weights, MlxArray, soloGreedy };
}

async function schedulerParity(base: string, label: string, klTol = KL_TOL): Promise<void> {
  const { BatchScheduler } = await import("../src/serve/batch-scheduler");
  const { model, weights, MlxArray, soloGreedy } = await openHarness(base);
  const eos = model.config.eosTokenIds;

  try {
    const ref = PROMPTS.map((p) => soloGreedy(p, STEPS));
    for (let i = 0; i < PROMPTS.length; i++)
      for (let s = 0; s < MAXTOK[i]!; s++)
        if (eos.includes(ref[i]!.tokens[s]!))
          throw new Error(`[${label}] row ${i} EOSes at step ${s} within max_tokens — pick a longer prompt`);

    const submitForced = (sched: InstanceType<typeof BatchScheduler>, i: number, maxTokens: number) => {
      const captured: Float32Array[] = [];
      const got: number[] = [];
      const stats = sched.submit({
        promptIds: PROMPTS[i]!,
        maxTokens,
        eosTokenIds: eos,
        sample: (l, step) => {
          captured[step] = l.toFloat32();
          return MlxArray.fromInt32(Int32Array.from([ref[i]!.tokens[step]!]), [1]);
        },
        onToken: (t) => { got.push(t); },
      });
      return { captured, got, stats };
    };
    const checkRow = (i: number, maxTokens: number, captured: Float32Array[], got: number[], st: { generatedTokens: number; finishReason: string }) => {
      expect(got).toEqual(ref[i]!.tokens.slice(0, maxTokens));
      expect(st.generatedTokens).toBe(maxTokens);
      expect(st.finishReason).toBe("length");
      let maxKl = 0;
      for (let s = 0; s < maxTokens; s++) maxKl = Math.max(maxKl, klDiv(ref[i]!.logits[s]!, captured[s]!));
      console.log(`[sched ${label} row ${i}] maxKL=${maxKl.toExponential(2)} (steps=${maxTokens})`);
      expect(maxKl).toBeLessThan(klTol);
    };

    // Scenario 1: all three at once → staggered eviction.
    const sched1 = new BatchScheduler(model, { maxBatch: 4 });
    const s1 = PROMPTS.map((_, i) => submitForced(sched1, i, MAXTOK[i]!));
    const st1 = await Promise.all(s1.map((s) => s.stats));
    for (let i = 0; i < PROMPTS.length; i++) checkRow(i, MAXTOK[i]!, s1[i]!.captured, s1[i]!.got, st1[i]!);

    // Scenario 2: row 2 JOINS mid-stream (after 0,1 have stepped).
    const sched2 = new BatchScheduler(model, { maxBatch: 4 });
    const a = submitForced(sched2, 0, MAXTOK[0]!);
    const b = submitForced(sched2, 1, MAXTOK[1]!);
    await delay(40);
    const c = submitForced(sched2, 2, MAXTOK[2]!);
    const st2 = await Promise.all([a.stats, b.stats, c.stats]);
    checkRow(0, MAXTOK[0]!, a.captured, a.got, st2[0]!);
    checkRow(1, MAXTOK[1]!, b.captured, b.got, st2[1]!);
    checkRow(2, MAXTOK[2]!, c.captured, c.got, st2[2]!);
  } finally {
    weights.dispose();
  }
}

describe.skipIf(!optIn || !haveCpm)("batch scheduler — CPM L1 (full-attention)", () => {
  test("teacher-forced: scheduled per-row logits == solo (evict + join)", async () => {
    await schedulerParity(CPM_BASE, "CPM");
  }, 240_000);
});

// Gemma 12B (interleaved sliding + full): the mixed-layer scheduler path,
// gated with the SAME teacher-forced KL/argmax pattern as the CPM case above —
// forced tokens pin the schedule (admission merge, staggered eviction, join),
// so the exact-token routing assertions in checkRow are the "argmax" half, and
// KL on the per-row logits is the numerics half.
//
// Why not exact trajectories vs the mlx-lm B=2 golden (the previous gate)?
// The scheduler prefills each row SOLO and merges its KV into the running
// batch, while the golden ran one padded one-shot B=2 prefill — different
// bf16 reduction orders, so token-for-token equality between the two
// protocols is a machine-lucky coincidence (it held on the M4 Pro, not on
// the M1 Max), not a contract. The one-shot-protocol path IS gated exactly,
// per machine, in tests/batched-decode-parity.test.ts (realBatchedGreedy vs
// batched-golden-gemma12b.json via tests/goldens.ts).
//
// KL BOUND: batched-vs-solo Gemma carries inherent left-pad reduction-order
// noise at Gemma magnitudes (headDim 256, scale 1.0; see the parity harness
// notes), NOT a bug: measured benign divergence is 1.5e-7–4.1e-2 here
// (apple-m1-max, 2026-07-01) and up to ~2.6e-1 on padded rows historically —
// even while bit-matching mlx-lm B=N. So the CPM bound (1e-2) is unusable for
// Gemma; 5e-1 sits ~2x above the worst measured benign ceiling while still
// failing on real orchestration faults (wrong leftPad after merge/filter,
// mis-routed rows) — those attend to wrong content and shift KL to O(1)+.
// This gate covers orchestration, not sub-bf16 numerics (the parity oracle
// covers those).
//
// ALTERNATIVE (later, if a tighter gate is wanted): a protocol oracle — a gen
// script driving mlx-lm's BatchKVCache.merge/.extract/.filter through the
// scheduler's EXACT merged-solo-prefill + staggered-evict schedule (like
// scripts/oracle/gen-batched-dynamic-golden.py does for the cache ops), regenerated
// per machine via the goldens layer, would restore token-for-token equality.
const GEMMA_KL_TOL = 5e-1;
describe.skipIf(!optIn || !haveGemma)("batch scheduler — Gemma 12B (mixed sliding/full)", () => {
  test("teacher-forced: scheduled per-row logits == solo (evict + join, KL gate)", async () => {
    await schedulerParity(SNAPSHOT, "Gemma12B", GEMMA_KL_TOL);
  }, 300_000);
});

// ---- Phase 3.2 gates -------------------------------------------------------

// Prompt-cache reuse on the batch lane: request 1 finishes never-merged →
// put() (entry covers prompt+fed exactly); request 2 with the same prompt
// take()s the longest usable prefix (prompt.length-1, the take() cap) and
// suffix-prefills. Teacher-forced; step 0 is argmax-anchored (the restored
// row's token-0 logits come from a 1-token continuation forward — the same
// GEMV-vs-GEMM convention the serial cache-hit path carries), later steps
// KL-gated at the CPM bound.
describe.skipIf(!optIn || !haveCpm)("batch scheduler — prompt-cache reuse (Phase 3.2)", () => {
  test("put() on never-merged finish; second request restores the prefix", async () => {
    const { BatchScheduler } = await import("../src/serve/batch-scheduler");
    const { PromptCache } = await import("../src/prompt-cache");
    const { model, weights, MlxArray, soloGreedy } = await openHarness(CPM_BASE);
    const eos = model.config.eosTokenIds;
    try {
      const prompt = PROMPTS[0]!;
      const MAX = 5;
      const ref = soloGreedy(prompt, MAX);
      for (let s = 0; s < MAX; s++)
        if (eos.includes(ref.tokens[s]!)) throw new Error(`row EOSes at step ${s} — pick a longer prompt`);
      const pc = new PromptCache(512e6);
      const sched = new BatchScheduler(model, { maxBatch: 2, promptCache: pc });
      const run = () => {
        const captured: Float32Array[] = [];
        const got: number[] = [];
        const stats = sched.submit({
          promptIds: prompt, maxTokens: MAX, eosTokenIds: eos,
          sample: (l, step) => {
            captured[step] = l.toFloat32();
            return MlxArray.fromInt32(Int32Array.from([ref.tokens[step]!]), [1]);
          },
          onToken: (t) => { got.push(t); },
        });
        return { captured, got, stats };
      };
      const r1 = run();
      const st1 = await r1.stats;
      expect(st1.cachedTokens).toBe(0);
      expect(st1.finishReason).toBe("length");
      expect(pc.size).toBe(1); // never-merged finish put the entry back
      expect(pc.totalBytes).toBeGreaterThan(0);

      const r2 = run();
      const st2 = await r2.stats;
      expect(st2.cachedTokens).toBe(prompt.length - 1); // longest usable prefix
      expect(r2.got).toEqual(ref.tokens.slice(0, MAX));
      expect(argmaxF(r2.captured[0]!)).toBe(ref.tokens[0]!); // step-0 anchor
      let maxKl = 0;
      for (let s = 1; s < MAX; s++) maxKl = Math.max(maxKl, klDiv(ref.logits[s]!, r2.captured[s]!));
      console.log(`[sched cache-hit] maxKL=${maxKl.toExponential(2)} cached=${st2.cachedTokens}`);
      expect(maxKl).toBeLessThan(KL_TOL);
      expect(pc.size).toBe(1); // the hit was re-put (extended entry)
      pc.clear();
    } finally {
      weights.dispose();
    }
  }, 240_000);
});

// PREFIX SHARING (2026-07-05): take() serves zero-copy CLONES and leaves
// the donor intact. The scenario that used to break: agent A's conversation
// entry gets matched by agent B's shared-system-prompt request — the old
// consume-and-trim take DESTROYED A's entry to serve B. Now B clones the
// shared prefix, A's later turn still hits its FULL entry, and B's logits
// stay within the cache-hit bound vs its own solo run.
describe.skipIf(!optIn || !haveCpm)("batch scheduler — prefix sharing (real model)", () => {
  test("shared system prefix serves B without cannibalizing A's entry", async () => {
    const { BatchScheduler } = await import("../src/serve/batch-scheduler");
    const { PromptCache } = await import("../src/prompt-cache");
    const { model, weights, MlxArray, soloGreedy } = await openHarness(CPM_BASE);
    const eos = model.config.eosTokenIds;
    try {
      const SYS = [1, 100, 200, 300, 400, 500, 600]; // the shared "system prompt"
      const promptA = [...SYS, 800];
      const promptB = [...SYS, 900];
      const MAX = 5;
      const refA = soloGreedy(promptA, MAX);
      const refB = soloGreedy(promptB, MAX);
      const pc = new PromptCache(1e12); // real cloneKvCaches
      const sched = new BatchScheduler(model, { maxBatch: 2, promptCache: pc });

      const run = (prompt: number[], ref: { tokens: number[]; logits: Float32Array[] }, maxTokens = MAX) => {
        const captured: Float32Array[] = [];
        const got: number[] = [];
        const stats = sched.submit({
          promptIds: prompt, maxTokens, eosTokenIds: eos,
          sample: (l, step) => {
            captured[step] = l.toFloat32();
            return MlxArray.fromInt32(Int32Array.from([ref.tokens[step]!]), [1]);
          },
          onToken: (t) => { got.push(t); },
        });
        return { captured, got, stats };
      };

      // Agent A establishes the entry (SYS+qA+fed, 12 tokens).
      const stA = await run(promptA, refA).stats;
      expect(stA.cachedTokens).toBe(0);
      expect(pc.size).toBe(1);

      // Agent B shares only SYS — served from a CLONE of A's entry.
      const rB = run(promptB, refB);
      const stB = await rB.stats;
      expect(stB.cachedTokens).toBe(SYS.length); // the shared prefix
      expect(rB.got).toEqual(refB.tokens.slice(0, MAX));
      expect(argmaxF(rB.captured[0]!)).toBe(refB.tokens[0]!);
      let maxKl = 0;
      for (let s = 1; s < MAX; s++) maxKl = Math.max(maxKl, klDiv(refB.logits[s]!, rB.captured[s]!));
      console.log(`[sched share] B maxKL=${maxKl.toExponential(2)} cachedB=${stB.cachedTokens}`);
      expect(maxKl).toBeLessThan(KL_TOL);
      expect(pc.size).toBe(2); // A's entry SURVIVED B's borrow + B's entry

      // A's next turn: continuation of ITS OWN conversation — full entry hit
      // (the cannibalization regression: this used to be a 7-token hit at
      // best, because B's borrow trimmed A's entry down to SYS).
      const aEntryLen = promptA.length + (MAX - 1); // prompt + fed
      const promptA2 = [...promptA, ...refA.tokens.slice(0, MAX), 5, 5, 5];
      const refA2 = soloGreedy(promptA2, 3);
      const rA2 = run(promptA2, refA2, 3);
      const stA2 = await rA2.stats;
      expect(stA2.cachedTokens).toBe(aEntryLen); // FULL entry, not just SYS
      expect(pc.size).toBe(2); // A2's put superseded A's ancestor entry
      pc.clear();
    } finally {
      weights.dispose();
    }
  }, 300_000);
});

// Layer 0: the batch lane restores prefixes FROM DISK through the same
// PromptCache.take() (tiering lives inside the store — unified-engine plan).
// Request 1 puts its entry; demoteIdle() spills it to a real SsdCacheStore
// and frees the GPU arrays; request 2 with the same prompt restores via
// zero-copy mmap at ADMISSION and suffix-prefills — cachedTokens reported,
// logits within the CPM bound.
describe.skipIf(!optIn || !haveCpm)("batch scheduler — SSD tier through the batch lane (Layer 0)", () => {
  test("demoted entry restores from disk at admission", async () => {
    const { BatchScheduler } = await import("../src/serve/batch-scheduler");
    const { PromptCache } = await import("../src/prompt-cache");
    type ColdTier = import("../src/prompt-cache").ColdTier;
    const { SsdCacheStore } = await import("../src/ssd-cache");
    const { configFingerprint } = await import("../src/model/fingerprint");
    const { mkdtempSync, rmSync, readFileSync } = await import("node:fs");
    const { tmpdir } = await import("node:os");
    const { join } = await import("node:path");
    const { model, weights, MlxArray, soloGreedy } = await openHarness(CPM_BASE);
    const eos = model.config.eosTokenIds;
    const dir = mkdtempSync(join(tmpdir(), "mlxbun-ssd-batch-"));
    try {
      const store = new SsdCacheStore({
        dir, maxBytes: 8 * 2 ** 30,
        configFingerprint: `${configFingerprint(model.config)}-bf16`,
        tokenizerHash: Bun.hash(readFileSync(`${CPM_BASE}/tokenizer.json`)).toString(16),
        modelId: "cpm5-test",
      });
      const cold: ColdTier = {
        find: (prompt, ns) => {
          const h = store.find(prompt, ns);
          return h ? { prefixLen: h.prefixLen, handle: h.entry } : null;
        },
        restore: (handle) => {
          const loaded = store.restore(handle as never, model);
          return loaded
            ? { tokens: loaded.tokens, caches: loaded.caches, retain: () => {} }
            : null;
        },
        store: (tokens, caches, ns) => { store.store(tokens, caches, ns); },
      };
      const pc = new PromptCache(1e12, null, cold);
      const sched = new BatchScheduler(model, { maxBatch: 2, promptCache: pc });

      const prompt = PROMPTS[0]!;
      const MAX = 5;
      const ref = soloGreedy(prompt, MAX);
      const run = () => {
        const captured: Float32Array[] = [];
        const got: number[] = [];
        const stats = sched.submit({
          promptIds: prompt, maxTokens: MAX, eosTokenIds: eos,
          sample: (l, step) => {
            captured[step] = l.toFloat32();
            return MlxArray.fromInt32(Int32Array.from([ref.tokens[step]!]), [1]);
          },
          onToken: (t) => { got.push(t); },
        });
        return { captured, got, stats };
      };

      const st1 = await run().stats;
      expect(st1.cachedTokens).toBe(0);
      expect(pc.size).toBe(1);
      expect(pc.demoteIdle(0)).toBe(1); // spill to DISK, free the GPU arrays
      expect(pc.size).toBe(0);
      expect(store.entries).toBe(1);

      const r2 = run();
      const st2 = await r2.stats;
      expect(st2.cachedTokens).toBe(prompt.length - 1); // restored from disk
      expect(store.stats.restores).toBe(1);
      expect(r2.got).toEqual(ref.tokens.slice(0, MAX));
      expect(argmaxF(r2.captured[0]!)).toBe(ref.tokens[0]!);
      let maxKl = 0;
      for (let s = 1; s < MAX; s++) maxKl = Math.max(maxKl, klDiv(ref.logits[s]!, r2.captured[s]!));
      console.log(`[sched ssd-hit] maxKL=${maxKl.toExponential(2)} cached=${st2.cachedTokens}`);
      expect(maxKl).toBeLessThan(KL_TOL);
      pc.clear();
    } finally {
      rmSync(dir, { recursive: true, force: true });
      weights.dispose();
    }
  }, 240_000);
});

// Compiled decode at B=1 (adopt-don't-copy keeps the lone row's caches
// serial-class, so CompiledDecode.supports passes and the scheduler replays
// the serial engine's compiled step). Free-running greedy through the batch
// lane must equal the REAL serial engine (generate()) token-for-token —
// GATE-B1 equivalence — and the CompiledDecode.stepsExecuted counter must
// advance, proving the compiled path actually engaged in the scheduler.
describe.skipIf(!optIn || !haveGemma)("batch scheduler — compiled decode at B=1 (Phase 3.2)", () => {
  test("lone adopted row replays the compiled step; greedy == serial generate()", async () => {
    const { BatchScheduler } = await import("../src/serve/batch-scheduler");
    const { CompiledDecode } = await import("../src/model/compiled-decode");
    const { generate } = await import("../src/generate");
    const { toLogprobs } = await import("../src/sampler");
    const ops = await import("../src/mlx/ops");
    const { model, weights } = await openHarness(SNAPSHOT);
    const eos = model.config.eosTokenIds;
    try {
      const prompt = PROMPTS[0]!;
      const MAX = 8;
      // Serial reference: the real engine (same GEMV prefill convention,
      // same compiled decode) — the thing B=1 must be indistinguishable from.
      const serialToks: number[] = [];
      const gen = generate(model, prompt, { maxTokens: MAX, cache: model.makeCache(), eosTokenIds: eos });
      for await (const t of gen) serialToks.push(t.token);

      const before = CompiledDecode.stepsExecuted;
      const sched = new BatchScheduler(model, { maxBatch: 2 });
      const got: number[] = [];
      const st = await sched.submit({
        promptIds: prompt, maxTokens: MAX, eosTokenIds: eos, plainGreedy: true,
        sample: (l) => {
          const lp = toLogprobs(l);
          const t = ops.argmaxAxis(lp, -1);
          lp.dispose();
          return t;
        },
        onToken: (t) => { got.push(t); },
      });
      const compiledSteps = CompiledDecode.stepsExecuted - before;
      console.log(`[sched compiled-b1] compiledSteps=${compiledSteps} serial=${JSON.stringify(serialToks)} batch=${JSON.stringify(got)}`);
      expect(got).toEqual(serialToks);
      expect(st.generatedTokens).toBe(serialToks.length);
      expect(compiledSteps).toBeGreaterThanOrEqual(MAX - 2);
      expect(CompiledDecode.unexpectedRetraces).toBe(0);
    } finally {
      weights.dispose();
    }
  }, 300_000);
});
