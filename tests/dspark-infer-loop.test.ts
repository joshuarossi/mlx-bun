// Regression gate for the forwardInfer host-sync tightening
// (docs/archive/investigations/dspark-handoff.md item 3): the greedy token
// recurrence now stays on-device (argmax → takeAxis, no itemUint32 per
// position) and confidence is deferred to one read when pruning is
// inactive. This test pins the PRE-TIGHTENING reference output — the
// rewrite is a pure optimization, so every value here must stay bit-exact.
// Model-free, CPU-only: same tiny stub-model pattern as
// scripts/dspark-dflash-smoke.ts.

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { DflashDrafter, DEFAULT_DFLASH_CONFIG, type TargetDims } from "../src/spec/dspark/module-dflash";

function rng(seed: number): () => number {
  let s = seed >>> 0 || 1;
  return () => { s ^= s << 13; s >>>= 0; s ^= s >> 17; s ^= s << 5; s >>>= 0; return s / 0x100000000; };
}

const A = 3, G = 5, V = 64, H = 32, m = 3, dDraft = 32;
const cfg = { ...DEFAULT_DFLASH_CONFIG, gamma: G, dDraft, nLayers: 2, nHeads: 4, markovRank: 16, tapLayers: [1, 2, 3] };
const dims: TargetDims = { hiddenSize: H, vocabSize: V, eps: 1e-6 };

/** Builds the stub model AND the drafter with the SAME rng(7) draw order as
 *  scripts/dspark-dflash-smoke.ts (fakeEmbed, fakeHead, fakeScales draws
 *  first from the shared stream; DflashDrafter.initFromDims seeds its own
 *  params internally at its default seed, independent of `r` — exactly as
 *  the smoke script relies on). */
function makeSmokeStub() {
  const r = rng(7);
  const fakeEmbed = MlxArray.fromFloat32(new Float32Array(V * H).map(() => (r() - 0.5) * 0.1), [V, H]).eval();
  const fakeHead = MlxArray.fromFloat32(new Float32Array(H * V).map(() => (r() - 0.5) * 0.1), [H, V]).eval();
  const fakeScales = MlxArray.fromFloat32(new Float32Array([1]), [1]).astype(Dtype.bfloat16).eval();
  const stub = {
    embed: { scales: fakeScales, encode: (ids: MlxArray) => ops.takeAxis(fakeEmbed, ids, 0) },
    logitsFromHidden: (h: MlxArray) => {
      const hf = h.dtype === Dtype.float32 ? h : h.astype(Dtype.float32);
      const o = ops.matmul(hf, fakeHead);
      if (hf !== h) hf.dispose();
      return o;
    },
  } as unknown as import("../src/model/gemma4").Gemma4Model;
  return { stub, dispose: () => { fakeEmbed.dispose(); fakeHead.dispose(); fakeScales.dispose(); } };
}

describe("forwardInfer host-sync tightening (bit-identity vs pre-tightening reference)", () => {
  test("greedy: tokens [53,24,53,53,53], conf all ~0.5", () => {
    const { stub, dispose: disposeStub } = makeSmokeStub();
    const d = DflashDrafter.initFromDims(dims, cfg, "smoke");

    // fresh hCtx from a SEPARATE rng(11) stream, per the orchestrator's spec
    const r11 = rng(11);
    const Lctx = 7, mH = m * H;
    const hCtx = MlxArray.fromFloat32(new Float32Array(1 * Lctx * mH).map(() => r11()), [1, Lctx, mH]);

    const blk = d.forwardInfer(stub, hCtx, 3, G);
    expect(blk.tokens).toEqual([53, 24, 53, 53, 53]);
    expect(blk.conf.length).toBe(G);
    for (const c of blk.conf) expect(c).toBeCloseTo(0.5, 6);
    expect(blk.draftLogits).toBeDefined();
    expect(blk.draftLogits!.shape).toEqual([1, G, V]);
    blk.draftLogits!.dispose();

    hCtx.dispose(); d.dispose(); disposeStub();
  });

  test("collectLogits:false returns undefined draftLogits + identical tokens", () => {
    const { stub, dispose: disposeStub } = makeSmokeStub();
    const d = DflashDrafter.initFromDims(dims, cfg, "smoke");

    const r11 = rng(11);
    const Lctx = 7, mH = m * H;
    const hCtx = MlxArray.fromFloat32(new Float32Array(1 * Lctx * mH).map(() => r11()), [1, Lctx, mH]);

    const withLogits = d.forwardInfer(stub, hCtx, 3, G);
    const noLogits = d.forwardInfer(stub, hCtx, 3, G, { collectLogits: false });

    expect(noLogits.draftLogits).toBeUndefined();
    expect(noLogits.tokens).toEqual(withLogits.tokens);
    expect(noLogits.conf).toEqual(withLogits.conf);

    withLogits.draftLogits!.dispose();
    hCtx.dispose(); d.dispose(); disposeStub();
  });

  test("pruning minConf 0.6 still returns exactly 1 token", () => {
    const { stub, dispose: disposeStub } = makeSmokeStub();
    const d = DflashDrafter.initFromDims(dims, cfg, "smoke");

    const r11 = rng(11);
    const Lctx = 7, mH = m * H;
    const hCtx = MlxArray.fromFloat32(new Float32Array(1 * Lctx * mH).map(() => r11()), [1, Lctx, mH]);

    const pruned = d.forwardInfer(stub, hCtx, 3, G, { minConf: 0.6 });
    expect(pruned.tokens.length).toBe(1);
    expect(pruned.conf.length).toBe(1);
    expect(pruned.tokens[0]).toBe(53); // prefix-identical to the unpruned block
    expect(pruned.draftLogits!.shape[1]).toBe(1);
    pruned.draftLogits!.dispose();

    hCtx.dispose(); d.dispose(); disposeStub();
  });

  test("sampling path (temperature>0, seeded) still returns 5 in-vocab tokens", () => {
    const { stub, dispose: disposeStub } = makeSmokeStub();
    const d = DflashDrafter.initFromDims(dims, cfg, "smoke");

    const r11 = rng(11);
    const Lctx = 7, mH = m * H;
    const hCtx = MlxArray.fromFloat32(new Float32Array(1 * Lctx * mH).map(() => r11()), [1, Lctx, mH]);

    const samp = d.forwardInfer(stub, hCtx, 3, G, { sample: { temperature: 0.8, seed: 123 } });
    expect(samp.tokens.length).toBe(G);
    expect(samp.tokens.every((t) => t >= 0 && t < V)).toBe(true);
    samp.draftLogits!.dispose();

    hCtx.dispose(); d.dispose(); disposeStub();
  });
});
