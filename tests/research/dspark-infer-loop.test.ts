// Regression gate for the forwardInfer host-sync tightening
// (docs/archive/investigations/dspark-handoff.md item 3): the greedy token
// recurrence now stays on-device (argmax → takeAxis, no itemUint32 per
// position) and confidence is deferred to one read when pruning is
// inactive. This test pins the PRE-TIGHTENING reference output — the
// rewrite is a pure optimization, so every value here must stay bit-exact.
// Model-free, CPU-only: same tiny stub-model pattern as
// tests/helpers/dspark-dflash-smoke.ts.

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { DflashDrafter, DEFAULT_DFLASH_CONFIG, type TargetDims } from "../../src/spec/dspark/module-dflash";

function rng(seed: number): () => number {
  let s = seed >>> 0 || 1;
  return () => { s ^= s << 13; s >>>= 0; s ^= s >> 17; s ^= s << 5; s >>>= 0; return s / 0x100000000; };
}

const A = 3, G = 5, V = 64, H = 32, m = 3, dDraft = 32;
const cfg = { ...DEFAULT_DFLASH_CONFIG, gamma: G, dDraft, nLayers: 2, nHeads: 4, markovRank: 16, tapLayers: [1, 2, 3] };
const dims: TargetDims = { hiddenSize: H, vocabSize: V, eps: 1e-6 };

/** Builds the stub model AND the drafter with the SAME rng(7) draw order as
 *  tests/helpers/dspark-dflash-smoke.ts (fakeEmbed, fakeHead, fakeScales draws
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
  } as unknown as import("../../src/model/gemma4").Gemma4Model;
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


test("confidence truncates rows independently without consuming another row's sampling stream", () => {
  const { stub, dispose: disposeStub } = makeSmokeStub();
  try {
    for (const seqHead of ["markov", "rnn"] as const) {
      const drafter = DflashDrafter.initFromDims(dims, { ...cfg, seqHead }, "confidence-rows");
      using context = MlxArray.fromFloat32(Float32Array.from({ length: 4 * 7 * m * H },
        (_, i) => Math.sin(i * 0.17)), [4, 7, m * H]);
      using confidence = MlxArray.fromFloat32(Float32Array.from({ length: dDraft + cfg.markovRank },
        (_, i) => Math.sin(i * 0.3) * 0.1), [dDraft + cfg.markovRank, 1]);
      const params = drafter.flatParams().map((p, i) => drafter.names[i] === "conf.w" ? confidence : p);
      try {
        drafter.useParams(params, () => {
          const anchors = [3, 9, 17, 21], sample = { temperature: 0.8, seed: 123 };
          const full = drafter.forwardRows(stub, context, anchors, G, { sample, collectLogits: false });
          const values = full.conf.map(row => row[1]!);
          expect(Math.max(...values)).toBeGreaterThan(Math.min(...values));
          const threshold = (Math.min(...values) + Math.max(...values)) / 2;
          const pruned = drafter.forwardRows(stub, context, anchors, G, {
            sample, collectLogits: false, thresholds: [0, threshold, 0, 0, 0],
          });
          expect(new Set(pruned.tokens.map(row => row.length)).size).toBe(2);
          for (let row = 0; row < anchors.length; row++) {
            expect(pruned.tokens[row]).toEqual(full.tokens[row]!.slice(0, pruned.tokens[row]!.length));
            expect(pruned.conf[row]).toEqual(full.conf[row]!.slice(0, pruned.conf[row]!.length));
          }
        });
      } finally { drafter.dispose(); }
    }
  } finally { disposeStub(); }
});

test("DSpark row providers share projected context, retirement and immutable checkpoints", async () => {
  const { DflashProvider } = await import("../../src/spec/dflash-source");
  const { mkdtempSync, rmSync } = await import("node:fs");
  const { tmpdir } = await import("node:os");
  const { join } = await import("node:path");
  const { disposeAttachments } = await import("../../src/backends/mlx/checkpoint-state");
  for (const seqHead of ["markov", "rnn"] as const) {
    const { stub, dispose: disposeStub } = makeSmokeStub();
    const drafter = DflashDrafter.initFromDims(dims, { ...cfg, seqHead }, "smoke");
    const dir = mkdtempSync(join(tmpdir(), "dspark-rows-"));
    let provider: Awaited<ReturnType<typeof DflashProvider.load>> | undefined;
    const checkpoints: import("../../src/spec/source").DraftRowCheckpoint[] = [];
    try {
      drafter.save(dir); provider = await DflashProvider.load(dir);
      const target = { identity: {}, gemmaTaps: { layerCount: 4, projection: stub } };
      const raw = (B: number, N: number, seed: number) => MlxArray.fromFloat32(Float32Array.from({ length: B * N * m * H }, (_, i) => ((i + seed) % 97 - 48) / 64), [B, N, m * H]);
      using hidden = raw(1, 7, 11);
      const reference = drafter.forwardInfer(stub, hidden, 3, G, { collectLogits: false });
      const prefill = provider.grouped.openPrefill({ target, checkpoints: [null] });
      const sampling = { sample() { throw new Error("DSpark proposal is greedy"); } };
      let active: ReturnType<typeof provider.grouped.open> | undefined;
      try {
        using ids = ops.fromInt32([1, 2, 3, 4, 5, 6, 7], [1, 7]);
        await prefill.prefill(ids, hidden); checkpoints.push(prefill.capture(0));
        active = provider.grouped.open({ target, checkpoints: [checkpoints[0]!], sampling });
        expect((await active.draft([3], G, [0]))[0]).toEqual(reference.tokens);
        active.append([checkpoints[0]!]); expect(active.rowCount).toBe(2);
        const first = await active.draft([3, 9], G, [0, 0]);
        expect(first.map(row => row.length)).toEqual([G, G]);
        expect(await active.draft([3, 9], G, [0, 0])).toEqual(first);
        using verified = raw(2, G + 1, 29); await active.commit([1, 3], verified);
        const saved = [active.capture(0), active.capture(1)]; checkpoints.push(...saved);
        expect(saved.map(checkpoint => checkpoint.processedTokens)).toEqual([9, 11]);
        active.filterRows([1]);
        const restored = provider.grouped.open({ target, checkpoints: [saved[1]!], sampling });
        try { expect(await active.draft([13], G, [4])).toEqual(await restored.draft([13], G, [4])); }
        finally { restored.dispose(); }
        active.filterRows([]); expect(active.rowCount).toBe(0);
      } finally { active?.dispose(); prefill.dispose(); }
    } finally { disposeAttachments(checkpoints.map(checkpoint => checkpoint.attachment)); provider?.dispose(); drafter.dispose(); disposeStub(); rmSync(dir, { recursive: true, force: true }); }
  }
});
