// DiffusionGemma D1 single-forward parity (OPT-IN slow tier — loads the 14 GB
// checkpoint). The oracle is mlx-optiq itself (stock mlx-lm/mlx-vlm cannot load
// this model). The gate is the STATIC graph, not the denoising engine: we feed
// the byte-identical prompt + canvas the Python golden used and compare the
// softcapped logits [1, 256, vocab] from
//   encoder(prompt) -> cache ; decoder(canvas, cache) -> hidden -> tied head.
//
//   MLX_BUN_TEST_DIFFUSION=1 bun test tests/diffusion-parity.test.ts
//
// Regen the golden first on this machine (loads the 14 GB checkpoint):
//   /Users/joshrossi/Code/mlx-lm/.venv/bin/python scripts/gen-diffusion-golden.py
//
// Where the quantized GEMV is 1-ULP off (the known megakernel/L2 finding) we
// gate by argmax-agreement + KL, not the bit-exact golden.

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { loadModelConfig } from "../src/config";
import { DiffusionGemmaModel } from "../src/model/diffusion-gemma";
import { Weights } from "../src/weights";
import { SNAPSHOT_DIFFUSION, snapshotDiffusionAvailable } from "./paths";

const GOLD_DIR = "goldens/diffusion";
const optIn = process.env.MLX_BUN_TEST_DIFFUSION === "1";
const haveWeights = await snapshotDiffusionAvailable();
const haveGoldens = existsSync(`${GOLD_DIR}/forward.json`);
const skip = !optIn || !haveWeights || !haveGoldens;

interface Meta {
  canvas_length: number;
  vocab_size: number;
  logits_shape: [number, number, number];
  argmax_canvas: number[];
}

describe.skipIf(skip)("DiffusionGemma D1 single-forward parity (vs mlx-optiq)", () => {
  test("encoder+decoder canvas logits match the optiq golden", async () => {
    const meta = (await Bun.file(`${GOLD_DIR}/forward.json`).json()) as Meta;
    const promptIds = [
      ...new Int32Array(await Bun.file(`${GOLD_DIR}/forward-prompt.bin`).arrayBuffer()),
    ];
    const canvasIds = [
      ...new Int32Array(await Bun.file(`${GOLD_DIR}/forward-canvas.bin`).arrayBuffer()),
    ];
    const [, L, V] = meta.logits_shape;

    const config = await loadModelConfig(SNAPSHOT_DIFFUSION);
    const model = new DiffusionGemmaModel(await Weights.open(SNAPSHOT_DIFFUSION), config);

    const logits = model.forwardCanvasLogits(promptIds, canvasIds);
    expect(logits.shape).toEqual([1, L, V]);
    const ours = logits.toFloat32();
    logits.dispose();

    const ref = new Float32Array(await Bun.file(`${GOLD_DIR}/forward-logits.bin`).arrayBuffer());
    expect(ref.length).toBe(L * V);

    // Per-canvas-position metrics: argmax agreement (the primary gate), max abs
    // diff, relative RMSE, and mean KL(ref || ours) over the 256 positions.
    let agree = 0;
    let maxDiff = 0;
    let sqErr = 0;
    let sqRef = 0;
    let klSum = 0;
    for (let p = 0; p < L; p++) {
      const base = p * V;
      let ourArg = 0;
      let ourMax = -Infinity;
      let refArg = 0;
      let refMax = -Infinity;
      // max for stable softmax
      for (let v = 0; v < V; v++) {
        const o = ours[base + v]!;
        const r = ref[base + v]!;
        if (o > ourMax) {
          ourMax = o;
          ourArg = v;
        }
        if (r > refMax) {
          refMax = r;
          refArg = v;
        }
        const d = Math.abs(o - r);
        if (d > maxDiff) maxDiff = d;
        sqErr += d * d;
        sqRef += r * r;
      }
      if (ourArg === refArg) agree++;
      // KL(ref || ours) at this position
      let oSum = 0;
      let rSum = 0;
      for (let v = 0; v < V; v++) {
        oSum += Math.exp(ours[base + v]! - ourMax);
        rSum += Math.exp(ref[base + v]! - refMax);
      }
      const oLog = Math.log(oSum) + ourMax;
      const rLog = Math.log(rSum) + refMax;
      let kl = 0;
      for (let v = 0; v < V; v++) {
        const rp = Math.exp(ref[base + v]! - rLog);
        if (rp > 1e-12) {
          const logOurs = ours[base + v]! - oLog;
          kl += rp * (ref[base + v]! - rLog - logOurs);
        }
      }
      klSum += kl;
    }
    const relRmse = Math.sqrt(sqErr / sqRef);
    const meanKl = klSum / L;

    // eslint-disable-next-line no-console
    console.log(
      `[diffusion D1] argmax ${agree}/${L} · maxDiff ${maxDiff.toExponential(3)} · ` +
        `relRMSE ${relRmse.toExponential(3)} · meanKL ${meanKl.toExponential(3)}`,
    );

    // Also confirm our argmax matches the golden's dumped argmax_canvas.
    let goldAgree = 0;
    for (let p = 0; p < L; p++) {
      const base = p * V;
      let ourArg = 0;
      let ourMax = -Infinity;
      for (let v = 0; v < V; v++) {
        const o = ours[base + v]!;
        if (o > ourMax) {
          ourMax = o;
          ourArg = v;
        }
      }
      if (ourArg === meta.argmax_canvas[p]) goldAgree++;
    }
    expect(goldAgree).toBe(agree); // sanity: dumped argmax == recomputed ref argmax

    // The whole graph is BIT-EXACT vs optiq on the reference machine (encoder
    // prefill + bidirectional decoder canvas pass + parallel dense/MoE +
    // self-conditioning + tied head + fp32 softcap). Assert it. (The dossier
    // anticipated a 1-ULP quantized-GEMV residual needing KL+argmax gating; the
    // graph turned out exact, so we hold the strong bar like the other models.)
    expect(maxDiff).toBe(0);
    expect(agree).toBe(L);
    expect(meanKl).toBe(0);
    expect(relRmse).toBe(0);
  }, 600_000);
});
