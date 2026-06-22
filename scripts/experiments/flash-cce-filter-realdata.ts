// L3 gate: the Apple-CCE gradient FILTER (filter_eps skip) measured on REAL
// training data — not synthetic. Pulls actual examples from uf-binarized-chat,
// runs the real MiniCPM5 forward, takes the post-finalNorm response hidden states
// and the REAL next-token targets (the chosen response), then compares the
// flash-CCE backward dh with the filter OFF (exact) vs an eps sweep. The claim
// under test: on real, sharply-peaked next-token distributions, skipping the
// ≈0-softmax tail costs almost nothing (vs the random-data worst case).
//
//   bun scripts/experiments/flash-cce-filter-realdata.ts
//   N=32 bun scripts/experiments/flash-cce-filter-realdata.ts   # more examples

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import * as ops from "../../src/mlx/ops";
import { evalAll } from "../../src/mlx/ops";
import { clearCache } from "../../src/mlx/ffi";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { flashCceForward, flashCceBackward, type FlashCceHead } from "../../src/train/flash-cce";
import { encodeDpoRow } from "../../src/train/dataset";
import { loadTokenizer } from "../../src/tokenizer";
import { ChatTemplate } from "../../src/chat-template";

const HOME = process.env.HOME!;
const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;
const N = Number(process.env.N ?? 24);   // real examples to pool
const DATA = `${HOME}/.cache/mlx-bun/data/uf-binarized-chat/train.jsonl`;

const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
if (!(model instanceof MiniCPM5Model)) throw new Error("expected MiniCPM5Model");
const H = config.text.hiddenSize, V = config.text.vocabSize;
const lh = model.lmHead;
const head: FlashCceHead = { w: lh.w, scales: lh.scales, biases: lh.biases!, bits: lh.spec.bits, groupSize: lh.spec.groupSize, softcap: null };

const tok = await loadTokenizer(MODEL);
const tmpl = await ChatTemplate.load(MODEL);
const lines = (await Bun.file(DATA).text()).split("\n").filter(Boolean).slice(0, N);

// Pool the REAL response hiddens + REAL targets from N examples (chosen branch).
const hParts: MlxArray[] = [];
const targets: number[] = [];
for (const l of lines) {
  const ex = encodeDpoRow(JSON.parse(l), tok, tmpl, 4096);
  const ids = ex.chosenIds, mask = ex.chosenMask;       // real tokens + response mask
  const L = ids.length, T = L - 1;
  let startT = -1, M = 0;
  for (let t = 0; t < T; t++) if (mask[t + 1]) { if (startT < 0) startT = t; M++; }
  if (M <= 0) continue;
  const idsArr = ops.fromInt32(ids.slice(0, T), [1, T]);
  const h = model.forwardHidden(idsArr, model.makeCache());    // [1,T,H] post-finalNorm
  const start = MlxArray.fromInt32(new Int32Array([startT]), [1]);
  const hResp = ops.reshape(ops.sliceDynamic(h, start, [1], [1, M, H]), [M, H]); // [M,H]
  evalAll([hResp]);
  hParts.push(MlxArray.fromBytesCopy(hResp.rawBytes(), [M, H], hResp.dtype)); // detached leaf
  for (let i = 0; i < M; i++) targets.push(ids[startT + 1 + i]!);             // REAL next tokens
  for (const a of [idsArr, h, start, hResp]) a.dispose();
  clearCache();
}
const hResp = hParts.length === 1 ? hParts[0]! : ops.concatAxis(hParts, 0); // [Mtot, H]
const Mtot = targets.length;
hParts.forEach((p) => { if (p !== hResp) p.dispose(); });
console.log(`### flash-cce-filter-realdata  pooled ${Mtot} REAL response tokens from ${lines.length} examples  H=${H} V=${V}`);

// Peakedness of the real distribution: mean prob the model assigns the TRUE next
// token (high = confident/peaked → the regime the filter is built for).
const fwd0 = flashCceForward(hResp, head, targets);
evalAll([fwd0.logp, fwd0.lse]);
const lp = fwd0.logp.toFloat32();
let sp = 0; for (let i = 0; i < Mtot; i++) sp += Math.exp(lp[i]!);
console.log(`### mean P(true next token) = ${(100 * sp / Mtot).toFixed(1)}%  (peakedness proxy — higher = more peaked)`);
fwd0.blockMax.dispose();

const cot = new Array(Mtot).fill(1.0) as number[]; // UNIT cotangent — exactly how the trainer invokes the backward
const lse = fwd0.lse;
const bm = flashCceForward(hResp, head, targets).blockMax; evalAll([bm]);

function bwd(fEps: string): MlxArray { return flashCceBackward(hResp, head, targets, lse, cot, fEps, bm, "0"); }
function timed(fEps: string): number {
  let b: MlxArray | undefined;
  for (let i = 0; i < 2; i++) { b?.dispose(); b = bwd(fEps); evalAll([b]); } // warm
  const t0 = performance.now();
  for (let i = 0; i < 5; i++) { b?.dispose(); b = bwd(fEps); evalAll([b]); }
  const ms = (performance.now() - t0) / 5; b?.dispose(); return ms;
}

const exact = bwd("0"); evalAll([exact]); const exactF = exact.toFloat32(); const msExact = timed("0");
console.log(`\n### filter sweep on REAL data (dh error vs EXACT; backward ms)`);
console.log(`eps      | dh rel %   | maxAbs    | ms    | speedup`);
console.log(`exact    | 0          | —         | ${msExact.toFixed(0)}   | 1.00x`);
for (const eps of ["1e-6", "1e-5", "1e-4", "1e-3"]) {
  const f = bwd(eps); evalAll([f]); const fF = f.toFloat32();
  let d2 = 0, r2 = 0, mx = 0;
  for (let i = 0; i < Mtot * H; i++) { const d = exactF[i]! - fF[i]!; d2 += d * d; r2 += exactF[i]! * exactF[i]!; if (Math.abs(d) > mx) mx = Math.abs(d); }
  const rel = Math.sqrt(d2) / (Math.sqrt(r2) || 1);
  f.dispose();
  const ms = timed(eps);
  console.log(`${eps.padEnd(8)} | ${(rel * 100).toFixed(3).padEnd(10)} | ${mx.toExponential(2)} | ${ms.toFixed(0).padEnd(5)} | ${(msExact / ms).toFixed(2)}x`);
}
console.log(`\n### verdict: the filter is worth enabling iff some eps gives a large speedup at dh error that's lost in the bf16 floor (~0.3%) — judged HERE on real targets, not synthetic.`);
exact.dispose(); fwd0.logp.dispose(); lse.dispose(); bm.dispose(); hResp.dispose(); weights.dispose();
