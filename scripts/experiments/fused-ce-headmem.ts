// HEAD-ISOLATED memory benchmark for the vocab-blocked online-softmax fused head.
// The integrated training peak is dominated by the layer-stack backward, which
// masks the head term — so here we differentiate ONLY the head (a synthetic
// post-finalNorm hidden → fusedLogpMeanFromHidden → dh), with no layer stack, and
// measure peak vs the vocab block size. If [chunk,V] never materializes, the head
// peak scales with vocabBlock (not V).
//
//   bun scripts/experiments/fused-ce-headmem.ts                 # MiniCPM5
//   E4B=1 bun scripts/experiments/fused-ce-headmem.ts           # gemma e4b (262k vocab)

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { ValueAndGrad } from "../../src/mlx/autograd";
import { evalAll, randomNormal, meanAll } from "../../src/mlx/ops";
import { peakMemory, resetPeakMemory, clearCache } from "../../src/mlx/ffi";
import { fusedLogpMeanFromHidden } from "../../src/train/loss";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";

const HOME = process.env.HOME!;
const E4B = process.env.E4B === "1";
const repo = E4B
  ? "models--mlx-community--gemma-4-e4b-it-OptiQ-4bit"
  : "models--mlx-community--MiniCPM5-1B-OptiQ-4bit";
const base = `${HOME}/.cache/huggingface/hub/${repo}/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;
const M = Number(process.env.M ?? 2048); // response length
const CHUNK = Number(process.env.CHUNK ?? 4096); // >= M ⇒ one token-chunk, so vocabBlock is the only head lever
const gb = (b: number) => `${(b / 1e9).toFixed(3)} GB`;

const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
const hidden = config.text.hiddenSize;
const V = config.text.vocabSize;
console.log(`### fused-ce-headmem  model=${E4B ? "e4b" : "MiniCPM5"} M=${M} hidden=${hidden} V=${V} chunk=${CHUNK}`);

// Synthetic post-finalNorm hidden [1, T, hidden] with T = M (all-response: tiny
// prompt then response). ids/mask: position 0 is prompt, 1..M are response.
const T = M;
const h0 = randomNormal([1, T, hidden], Dtype.bfloat16, 0, 1, null);
const ids = Array.from({ length: M + 1 }, (_, i) => ((i * 13 + 5) % (V - 1)) + 1);
const mask = Array.from({ length: M + 1 }, (_, i) => (i >= 1 ? 1 : 0));

function headPeak(vocabBlock: number): { peak: number; loss: number } {
  clearCache();
  resetPeakMemory();
  const sink: Array<{ dispose(): void }> = [];
  const vag = new ValueAndGrad((p) => {
    // mean logp reduced to a 0-d scalar (meanAll; reshape-to-[] breaks the FFI).
    const m = fusedLogpMeanFromHidden(model, p[0]!, ids, mask, CHUNK, sink, vocabBlock);
    const sc = meanAll(m, false);
    m.dispose();
    return sc;
  }, [0]);
  const out = vag.apply([h0]);
  evalAll([out.value, ...out.grads]);
  const peak = peakMemory();
  const loss = out.value.toFloat32()[0]!;
  out.value.dispose(); out.grads.forEach((g) => g.dispose()); vag.dispose();
  for (const d of sink) d.dispose();
  return { peak, loss };
}

console.log(`${"vocabBlock".padEnd(14)} ${"head peak".padStart(12)} ${"loss".padStart(12)}`);
for (const vb of [0, 32768, 8192, 2048, 512]) {
  if (vb !== 0 && vb >= V) continue;
  const { peak, loss } = headPeak(vb);
  const label = vb === 0 ? `whole [chunk,V]` : `${vb}`;
  console.log(`${label.padEnd(14)} ${gb(peak).padStart(12)} ${loss.toFixed(4).padStart(12)}`);
}
weights.dispose();
