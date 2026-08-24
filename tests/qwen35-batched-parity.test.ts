// GATED oracle parity for the Qwen3.5 (hybrid gated-DeltaNet) BATCHED path
// (docs/design/batching.md P5 — SSM layers join the batch lane).
//
//   MLX_BUN_TEST_BATCH_DECODE=1 bun test tests/qwen35-batched-parity.test.ts
//
// Unlike the dense oracle tests (realBatchedGreedy: left-padded BATCH
// prefill), this harness mirrors the PRODUCTION scheduler flow: each row
// solo-prefills UNPADDED at B=1, then merges into the batch (full layers via
// mergeKVRows, ssm layers via SSMCache.mergeRows) and greedy-decodes batched.
// That is deliberate — the SSM path has no ssm_mask (state must never see a
// pad token), so a left-padded batch prefill through our model would be
// running a composition we never ship. The oracle (mlx-lm B=2, left-padded
// prefill WITH its ssm_mask) must produce the same trajectories iff both
// pad-handling strategies are equivalent — which is exactly the claim the
// gate proves. Oracle fixture: scripts/oracle/gen-batched-golden.py (oracle venv);
// goldens are machine-specific (tests/goldens.ts).

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { goldenAt } from "./goldens";
import type { Cache } from "../src/model/gemma4-base";

const optIn = process.env.MLX_BUN_TEST_BATCH_DECODE === "1";
const QWEN_BASE =
  `${process.env.HOME}/.cache/huggingface/hub/` +
  `models--mlx-community--Qwen3.5-4B-OptiQ-4bit/snapshots/` +
  `6676059ab512d8b2be6c126d20bc651a4278fc4b`;
const haveQwen = existsSync(`${QWEN_BASE}/config.json`);

/** Solo-prefill each prompt, merge per layer kind (the scheduler's
 *  #mergeJoiner composition), free-run greedy batched decode. Returns per-row
 *  trajectories shaped like the oracle's: `steps` entries, entry 0 = the
 *  prefill argmax. */
async function batchedGreedyViaMerge(
  base: string, prompts: number[][], steps: number,
): Promise<number[][]> {
  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { createModel } = await import("../src/model/factory");
  const { MlxArray } = await import("../src/mlx/array");
  const { clearCache } = await import("../src/mlx/ffi");
  const { KVCache } = await import("../src/model/gemma4-base");
  const { BatchedDecodeMaskCache, mergeKVRows } = await import("../src/model/batched-mask");
  const { SSMCache } = await import("../src/model/qwen3-delta");

  const config = await loadModelConfig(base);
  const weights = await Weights.open(base);
  const model = createModel(weights, config);
  const B = prompts.length;

  const argmaxF = (a: Float32Array): number => {
    let bi = 0;
    for (let i = 1; i < a.length; i++) if (a[i]! > a[bi]!) bi = i;
    return bi;
  };
  const rowLastTok = (lg: InstanceType<typeof MlxArray>, b: number): number => {
    const [, L, V] = lg.shape as [number, number, number];
    const s = lg.slice([b, L - 1, 0], [b + 1, L, V]);
    const f = s.toFloat32();
    s.dispose();
    return argmaxF(f);
  };

  try {
    // Solo prefill (B=1, unpadded — the production joiner path).
    const solos = prompts.map((prompt) => {
      const cache = model.makeCache();
      const ids = MlxArray.fromInt32(Int32Array.from(prompt), [1, prompt.length]);
      const h = model.forwardHidden(ids, cache);
      ids.dispose();
      const lg = model.logitsFromHidden(h);
      h.dispose();
      const tok = rowLastTok(lg, 0);
      lg.dispose();
      clearCache();
      return { cache, tok };
    });

    // Merge per layer kind (the #mergeJoiner composition, batch built cold).
    const numLayers = solos[0]!.cache.length;
    const inners: Cache[] = [];
    let leftPad: number[] = prompts.map(() => 0);
    for (let i = 0; i < numLayers; i++) {
      if (solos[0]!.cache[i] instanceof SSMCache) {
        let merged: InstanceType<typeof SSMCache> | null = null;
        for (const s of solos) {
          const next = SSMCache.mergeRows(merged, s.cache[i] as InstanceType<typeof SSMCache>);
          merged?.dispose();
          merged = next;
        }
        inners.push(merged!);
      } else {
        const rows = solos.map((s) => {
          const [keys, values] = (s.cache[i] as InstanceType<typeof KVCache>).temporalView();
          return { keys, values };
        });
        const merged = mergeKVRows(rows);
        for (const r of rows) { r.keys.dispose(); r.values.dispose(); }
        const c = new KVCache();
        c.restoreState(merged.keys, merged.values, merged.width);
        inners.push(c);
        leftPad = merged.leftPad;
      }
    }
    for (const s of solos) for (const c of s.cache) c.dispose();

    // Free-run greedy batched decode (trajectory shape mirrors the oracle:
    // entry 0 = prefill argmax, then steps-1 decode-produced tokens).
    const traj: number[][] = solos.map((s) => [s.tok]);
    let toks = solos.map((s) => s.tok);
    for (let s = 1; s < steps; s++) {
      const fwd: Cache[] = inners.map((c) =>
        c instanceof SSMCache ? c : new BatchedDecodeMaskCache(c, B, leftPad, null),
      );
      const tid = MlxArray.fromInt32(Int32Array.from(toks), [B, 1]);
      const h = model.forwardHidden(tid, fwd);
      tid.dispose();
      const lg = model.logitsFromHidden(h);
      h.dispose();
      toks = Array.from({ length: B }, (_, b) => rowLastTok(lg, b));
      lg.dispose();
      toks.forEach((t, b) => traj[b]!.push(t));
      for (const c of fwd) (c as { releaseRopeArr?: () => void }).releaseRopeArr?.();
      clearCache();
    }
    for (const c of inners) c.dispose();
    return traj;
  } finally {
    weights.dispose();
  }
}

// --- THE GATE: production-composition batched greedy (solo prefill + merge)
//     must match mlx-lm's B=2 batched decode (left-padded prefill + ssm_mask)
//     token-for-token. ---
describe.skipIf(!optIn || !haveQwen)("batched decode ORACLE parity — Qwen3.5 hybrid vs mlx-lm B=2", () => {
  test("solo-prefill+merge batched greedy == mlx-lm B=2", async () => {
    const golden = await goldenAt("batched-golden-qwen35.json").json();
    const got = await batchedGreedyViaMerge(QWEN_BASE, golden.prompts as number[][], golden.steps as number);
    console.log(`[oracle qwen3.5] mlx-bun: ${JSON.stringify(got)}`);
    console.log(`[oracle qwen3.5] mlx-lm:  ${JSON.stringify(golden.trajectories)}`);
    expect(got).toEqual(golden.trajectories);
  }, 300_000);
});

// --- SSMCache dynamic-B ops in isolation (fast, ungated math checks). ---
describe("SSMCache batch ops", () => {
  test("mergeRows + filter do B-axis surgery and preserve values", async () => {
    const { SSMCache } = await import("../src/model/qwen3-delta");
    const ops = await import("../src/mlx/ops");
    const { MlxArray } = await import("../src/mlx/array");
    const { Dtype } = await import("../src/mlx/ffi");

    const mk = (fill: number, offset: number) => {
      const c = new SSMCache();
      const f = MlxArray.fromFloat32(new Float32Array([fill]), []);
      const z = ops.zeros([1, 3, 4], Dtype.float32);
      c.conv = ops.add(z, f);
      z.dispose();
      const z2 = ops.zeros([1, 2, 2, 2], Dtype.float32);
      c.recurrent = ops.add(z2, f);
      z2.dispose();
      f.dispose();
      c.offset = offset;
      return c;
    };
    const a = mk(1, 7), b = mk(2, 5), c3 = mk(3, 9);
    const ab = SSMCache.mergeRows(null, a); // steals a's arrays
    expect(a.conv).toBeNull();
    const abB = SSMCache.mergeRows(ab, b);
    const abc = SSMCache.mergeRows(abB, c3);
    expect(abc.conv!.shape).toEqual([3, 3, 4]);
    expect(abc.recurrent!.shape).toEqual([3, 2, 2, 2]);
    expect(abc.offset).toBe(9);
    abc.filter([0, 2]); // drop the middle row
    expect(abc.conv!.shape).toEqual([2, 3, 4]);
    const conv = abc.conv!.toFloat32();
    expect(conv[0]).toBe(1); // row a
    expect(conv[conv.length - 1]).toBe(3); // row c
    const rec = abc.recurrent!.toFloat32();
    expect(rec[0]).toBe(1);
    expect(rec[rec.length - 1]).toBe(3);
    for (const x of [ab, abB, abc, b, c3, a]) x.dispose();
  });
});
