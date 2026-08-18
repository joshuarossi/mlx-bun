// Direct Qwen3.8 native-MTP drafter-logit parity vs the mlx-vlm reference
// (PLAN 14g). Consumes the dump from oracle-qwen38-mtp-logits.py and makes
// two comparisons:
//
//   A) TARGET TAP (info): our pre-final-norm hidden grid vs the oracle's —
//      cross-stack AND cross-mlx-version, so ulp drift is possible; reported,
//      not gated.
//   B) DRAFTER PARITY (the gate): our drafter runs on the ORACLE's hidden
//      grid — byte-identical inputs — so tokens must match EXACTLY and the
//      per-step top-K logprobs should agree to bf16 noise. This isolates the
//      ported head math + embed/lm-head binding from target drift.
//
//   bun scripts/experiments/qwen38-mtp-logit-parity.ts /tmp/qwen38-mtp-oracle.json

import { SNAPSHOT_QWEN38, SNAPSHOT_QWEN38_MTP } from "../../tests/paths";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { Qwen35Model } from "../../src/model/qwen3_5";
import { setMemoryLimit, Dtype } from "../../src/mlx/ffi";
import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { makeSampler } from "../../src/sampler";
import { QwenMtpProvider } from "../../src/spec/qwen-mtp-source";

const oraclePath = process.argv[2] ?? "/tmp/qwen38-mtp-oracle.json";
const oracle = await Bun.file(oraclePath).json() as {
  mlx_version: string;
  prompt_ids: number[];
  gamma: number;
  token0: number;
  draft_tokens: number[];
  steps: { top_ids: number[]; top_logprobs: number[] }[];
  hidden_f32: number[];
  hidden_shape: number[];
};
const ids = oracle.prompt_ids;
const L = ids.length;
const TOPK = oracle.steps[0]!.top_ids.length;

setMemoryLimit(23_000_000_000);
const config = await loadModelConfig(SNAPSHOT_QWEN38);
const model = new Qwen35Model(await Weights.open(SNAPSHOT_QWEN38), config);
const provider = await QwenMtpProvider.load(SNAPSHOT_QWEN38_MTP);
const H = config.text.hiddenSize;
if (oracle.hidden_shape[1] !== L || oracle.hidden_shape[2] !== H)
  throw new Error(`oracle hidden shape ${oracle.hidden_shape} vs L=${L}, H=${H}`);

// ---- A) target tap: our pre-final-norm hidden vs the oracle's ------------
const caches = model.makeCache();
const tapIdx = config.text.numHiddenLayers - 1;
const cap = new Map<number, MlxArray>();
model.hiddenTap = { layers: new Set([tapIdx]), captured: cap };
const idsArr = ops.fromInt32(ids, [1, L]);
const finalHidden = model.forwardHidden(idsArr, caches);
idsArr.dispose();
model.hiddenTap = null;
const ourHidden = cap.get(tapIdx)!; // [1,L,H] bf16
const lastSlice = finalHidden.slice([0, L - 1, 0], [1, L, H]);
const lg = model.logitsFromHidden(lastSlice);
lastSlice.dispose();
finalHidden.dispose();
const V = lg.shape[lg.shape.length - 1]!;
const lgFlat = ops.reshape(lg, [1, V]);
lg.dispose();
const lgVals = lgFlat.toFloat32();
lgFlat.dispose();
let token0Ours = 0;
for (let i = 1; i < V; i++) if (lgVals[i]! > lgVals[token0Ours]!) token0Ours = i;

const ourHiddenF32 = (() => {
  const f = ourHidden.astype(Dtype.float32);
  const v = f.toFloat32();
  f.dispose();
  return v;
})();
let tapMaxAbs = 0;
let tapMismatched = 0;
for (let i = 0; i < ourHiddenF32.length; i++) {
  const d = Math.abs(ourHiddenF32[i]! - oracle.hidden_f32[i]!);
  if (d > 0) tapMismatched++;
  if (d > tapMaxAbs) tapMaxAbs = d;
}
console.log(
  `A) target tap vs oracle (mlx ${oracle.mlx_version} cross-version): ` +
  `max|Δ| ${tapMaxAbs.toExponential(3)}, ${tapMismatched}/${ourHiddenF32.length} elements differ; ` +
  `token0 ours ${token0Ours} vs oracle ${oracle.token0} ${token0Ours === oracle.token0 ? "MATCH" : "DIFFER"}`,
);

// ---- B) drafter parity on the ORACLE hidden grid (the gate) --------------
const oracleHidden = (() => {
  const f = MlxArray.fromFloat32(Float32Array.from(oracle.hidden_f32), [1, L, H]);
  const b = f.astype(Dtype.bfloat16);
  f.dispose();
  return b;
})();

const recorded: { top_ids: number[]; top_logprobs: number[] }[] = [];
const greedy = makeSampler({ temperature: 0 });
const recordingSampler = (logprobs: MlxArray, step: number): MlxArray => {
  const v = logprobs.toFloat32(); // already log-probs (the source's #sample)
  const idx = [...v.keys()].sort((a, b) => v[b]! - v[a]!).slice(0, TOPK);
  recorded.push({ top_ids: idx, top_logprobs: idx.map((i) => v[i]!) });
  return greedy(logprobs, step);
};

const source = provider.open({
  sampler: recordingSampler,
  target: { model, caches },
});
// prefill consumes ownership of the tapped context — hand it the ORACLE grid.
await (source as { prefill(ids: number[], ctx?: MlxArray): Promise<void> })
  .prefill(ids, oracleHidden);
const drafts = await source.draft([oracle.token0], oracle.gamma, 0);

const tokensExact = JSON.stringify(drafts) === JSON.stringify(oracle.draft_tokens);
console.log(`B) drafts ours ${drafts.join(",")} vs oracle ${oracle.draft_tokens.join(",")} → ${tokensExact ? "EXACT" : "DIVERGED"}`);
let worst = 0;
let topSetOk = true;
for (let s = 0; s < oracle.steps.length && s < recorded.length; s++) {
  const o = oracle.steps[s]!;
  const r = recorded[s]!;
  const idsMatch = JSON.stringify(o.top_ids) === JSON.stringify(r.top_ids);
  if (!idsMatch) topSetOk = false;
  let stepWorst = 0;
  for (let k = 0; k < TOPK; k++) {
    const oi = o.top_ids.indexOf(r.top_ids[k]!);
    if (oi >= 0)
      stepWorst = Math.max(stepWorst, Math.abs(o.top_logprobs[oi]! - r.top_logprobs[k]!));
  }
  worst = Math.max(worst, stepWorst);
  console.log(
    `   step ${s}: top-${TOPK} ids ${idsMatch ? "identical" : `DIFFER (ours ${r.top_ids.join(",")} vs ${o.top_ids.join(",")})`}, ` +
    `max|Δlogprob| ${stepWorst.toExponential(3)}`,
  );
}
console.log(
  `VERDICT: tokens ${tokensExact ? "EXACT" : "DIVERGED"}, top-${TOPK} ordering ${topSetOk ? "identical" : "differs"}, ` +
  `worst |Δlogprob| ${worst.toExponential(3)}`,
);
source.dispose();
ourHidden.dispose();
for (const c of caches) c.dispose();
