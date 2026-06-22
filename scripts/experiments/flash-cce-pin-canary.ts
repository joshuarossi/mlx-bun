// Regression guard for the flash-CCE host-buffer pin leak (fixed 2026-06-21,
// docs/investigations/orpo-flash-cce-pin-leak.md). Runs the flash-CCE head
// forward+backward in a tight loop and asserts the module-level `pinned` buffer
// count stays BOUNDED. Pre-fix (u32 using the zero-copy fromView) this grew
// linearly +N/iter and never released, eventually crashing training natively;
// post-fix (fromBytesCopy) it must stay flat. Fast — head-only, no training.
//
//   bun scripts/experiments/flash-cce-pin-canary.ts          # MiniCPM5
//   E4B=1 bun scripts/experiments/flash-cce-pin-canary.ts    # gemma e4b

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { Gemma4Model } from "../../src/model/gemma4";
import * as ops from "../../src/mlx/ops";
import { evalAll, randomNormal } from "../../src/mlx/ops";
import { clearCache } from "../../src/mlx/ffi";
import { MlxArray, pinnedBufferCount } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { flashCceForward, flashCceBackward, type FlashCceHead } from "../../src/train/flash-cce";

const HOME = process.env.HOME!;
const E4B = process.env.E4B === "1";
const repo = E4B
  ? "models--mlx-community--gemma-4-e4b-it-OptiQ-4bit"
  : "models--mlx-community--MiniCPM5-1B-OptiQ-4bit";
const base = `${HOME}/.cache/huggingface/hub/${repo}/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;
const M = Number(process.env.M ?? 256);
const ITERS = Number(process.env.ITERS ?? 60);

const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
const H = config.text.hiddenSize;
const V = config.text.vocabSize;

let head: FlashCceHead;
if (model instanceof Gemma4Model) {
  const e = model.embed;
  head = { w: e.w, scales: e.scales, biases: e.biases!, bits: e.spec.bits, groupSize: e.spec.groupSize, softcap: config.text.finalLogitSoftcapping };
} else if (model instanceof MiniCPM5Model) {
  const lh = model.lmHead;
  head = { w: lh.w, scales: lh.scales, biases: lh.biases!, bits: lh.spec.bits, groupSize: lh.spec.groupSize, softcap: null };
} else throw new Error("unsupported model");

const hResp = ops.mulScalar(randomNormal([M, H], Dtype.bfloat16, 0, 1, null), 0.5);
const targets = Array.from({ length: M }, (_, i) => (i * 2659 + 7) % V);
const cot = Array.from({ length: M }, () => 1.0);
evalAll([hResp]);

const round = () => {
  const f = flashCceForward(hResp, head, targets);
  evalAll([f.logp, f.lse]);
  const dh = flashCceBackward(hResp, head, targets, f.lse, cot, "0", f.blockMax, "0");
  evalAll([dh]);
  f.logp.dispose(); f.lse.dispose(); f.blockMax.dispose(); dh.dispose();
  clearCache();
};

// Warm up (compile kernels + let any one-time pins settle) before the baseline.
round(); round();
const base0 = pinnedBufferCount();
let maxSeen = base0;
for (let i = 1; i <= ITERS; i++) {
  round();
  const p = pinnedBufferCount();
  if (p > maxSeen) maxSeen = p;
  if (i % 10 === 0) console.log(`iter ${i}: pinned ${p}  (base ${base0}, max ${maxSeen})`);
}

const growth = pinnedBufferCount() - base0;
// The leak was dozens of pins per iter; post-fix it must be ~0. Allow tiny jitter.
const ok = growth <= 2;
console.log(`### model=${E4B ? "e4b" : "MiniCPM5"} M=${M} iters=${ITERS}`);
console.log(`### ${ok ? "PASS" : "FAIL"}: pinned grew ${growth} over ${ITERS} iters (base ${base0} → ${pinnedBufferCount()}, max ${maxSeen})`);
hResp.dispose(); weights.dispose();
process.exitCode = ok ? 0 : 1;
