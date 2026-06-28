// Qwen3-Embedding parity vs the mlx-lm reference (the L1 oracle). The same token
// ids (from the golden's meta.json) run through mlx-bun's Qwen3Model; we compare
// the post-final-norm hidden states [L, H] AND the last-token pooled, L2-normalized
// embedding [H] against mlx-lm's qwen3.
//
//   bun test tests/qwen3-embed-parity.test.ts
//
// Regen the golden first (needs the oracle venv):
//   ../mlx-lm/.venv/bin/python scripts/gen-qwen3-embed-golden.py
//
// The model is 4-bit DWQ + bf16 compute; like the SigLIP tower, every mlx
// primitive is bit-exact but 36-layer bf16 composition accumulates a sub-bf16
// residual. The gate is therefore cosine≈1 + tiny relRMSE on the pooled vector
// (the product), with a hidden-state relRMSE sanity bound.

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { loadModelConfig } from "../src/config";
import { createModel } from "../src/model/factory";
import { Qwen3Model } from "../src/model/qwen3";
import { Weights } from "../src/weights";
import * as ops from "../src/mlx/ops";
import { SNAPSHOT_QWEN3_EMBED, snapshotQwen3EmbedAvailable } from "./paths";

const GOLD_DIR = "goldens/qwen3-embed";
const haveWeights = await snapshotQwen3EmbedAvailable();
const haveGoldens = existsSync(`${GOLD_DIR}/meta.json`);
const skip = !haveWeights || !haveGoldens;

interface Meta {
  ids: number[];
  seqLen: number;
  hidden: number;
  text: string;
  eod: number;
}

function relRmse(ours: Float32Array, ref: Float32Array): number {
  let sqErr = 0;
  let sqRef = 0;
  for (let i = 0; i < ref.length; i++) {
    const d = ours[i]! - ref[i]!;
    sqErr += d * d;
    sqRef += ref[i]! * ref[i]!;
  }
  return Math.sqrt(sqErr / sqRef);
}

function maxAbs(ours: Float32Array, ref: Float32Array): number {
  let m = 0;
  for (let i = 0; i < ref.length; i++) {
    const d = Math.abs(ours[i]! - ref[i]!);
    if (d > m) m = d;
  }
  return m;
}

describe.skipIf(skip)("Qwen3-Embedding parity (vs mlx-lm qwen3)", () => {
  test("hidden states + pooled embedding match the mlx-lm golden", async () => {
    const meta = (await Bun.file(`${GOLD_DIR}/meta.json`).json()) as Meta;
    const refHidden = new Float32Array(await Bun.file(`${GOLD_DIR}/hidden.bin`).arrayBuffer());
    const refPooled = new Float32Array(await Bun.file(`${GOLD_DIR}/pooled.bin`).arrayBuffer());
    const { seqLen: L, hidden: H } = meta;
    expect(refHidden.length).toBe(L * H);
    expect(refPooled.length).toBe(H);

    const config = await loadModelConfig(SNAPSHOT_QWEN3_EMBED);
    const model = createModel(await Weights.open(SNAPSHOT_QWEN3_EMBED), config);
    expect(model).toBeInstanceOf(Qwen3Model);
    const qwen = model as Qwen3Model;

    // Post-final-norm hidden states for the exact golden ids.
    const ids = ops.fromInt32(meta.ids, [1, meta.ids.length]);
    const cache = qwen.makeCache();
    const hidden = qwen.forwardHidden(ids, cache);
    expect(hidden.shape).toEqual([1, L, H]);
    const ourHidden = hidden.toFloat32();
    hidden.dispose();
    for (const c of cache) c.dispose();

    // Pooled, L2-normalized embedding (the product the pipeline consumes).
    const pooled = qwen.embedPooled(ids);
    expect(pooled.shape).toEqual([1, H]);
    const ourPooled = pooled.toFloat32();
    pooled.dispose();
    ids.dispose();

    const hRel = relRmse(ourHidden, refHidden);
    const hMax = maxAbs(ourHidden, refHidden);
    const pRel = relRmse(ourPooled, refPooled);
    let dot = 0;
    for (let i = 0; i < H; i++) dot += ourPooled[i]! * refPooled[i]!;
    const cos = dot; // both L2-normalized

    // eslint-disable-next-line no-console
    console.log(
      `[qwen3-embed] hidden relRMSE ${hRel.toExponential(3)} maxAbs ${hMax.toExponential(3)} · ` +
        `pooled relRMSE ${pRel.toExponential(3)} cosine ${cos.toFixed(8)}`,
    );

    // The whole graph is BIT-EXACT vs mlx-lm on the reference machine (GQA + q/k
    // norm + full-head RoPE + swiglu + tied head); hold the strong L1 bar like the
    // other models. (cos is ~1.0006 — the pooled vector matches ref byte-for-byte;
    // the >1 is just the L2-norm's bf16 rounding, not a vector difference.)
    expect(hMax).toBe(0);
    expect(hRel).toBe(0);
    expect(pRel).toBe(0);
    expect(cos).toBeGreaterThan(0.9999);
  }, 300_000);
});
