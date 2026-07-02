// L3 gate: the Apple-CCE gradient FILTER (filter_eps skip) measured on REAL
// training data — not synthetic. Pulls actual DPO examples, runs the real model
// forward, takes the post-finalNorm response hidden states and the REAL
// next-token targets (the chosen response), then compares the flash-CCE backward
// dh with the filter OFF (exact) vs an eps sweep. The claim under test: on real,
// sharply-peaked next-token distributions, skipping the ≈0-softmax tail costs
// almost nothing (vs the random-data worst case).
//
// Also measures (the full backlog-#1 gate set, kernel-perf-review-2026-07.md):
//   - the blockMax vocab-block early-exit (lossless skip) on the same real data
//   - teacher-forced grad fidelity: flash dh vs the FULL-LOGITS autograd dh
//     (cosine + relnorm) — the L3 standing gate from PLAN.md
//   - eps=0 byte-identity: the "0" path must byte-match the exact baseline
//
//   bun scripts/experiments/flash-cce-filter-realdata.ts            # MiniCPM5
//   E4B=1 bun scripts/experiments/flash-cce-filter-realdata.ts      # gemma e4b (softcap, 262k vocab)
//   N=32 DATA=path/to/dpo.jsonl MAXLEN=8192 MCAP=4096 FID_M=512 ...  # knobs

import { existsSync, readdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { Gemma4Model } from "../../src/model/gemma4";
import * as ops from "../../src/mlx/ops";
import { evalAll } from "../../src/mlx/ops";
import { clearCache } from "../../src/mlx/ffi";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { Vjp } from "../../src/mlx/autograd";
import { flashCceForward, flashCceBackward, type FlashCceHead } from "../../src/train/flash-cce";
import { encodeDpoRow } from "../../src/train/dataset";
import { loadTokenizer } from "../../src/tokenizer";
import { ChatTemplate } from "../../src/chat-template";

const HOME = process.env.HOME!;
const E4B = process.env.E4B === "1";
const repo = E4B
  ? "models--mlx-community--gemma-4-e4b-it-OptiQ-4bit"
  : "models--mlx-community--MiniCPM5-1B-OptiQ-4bit";
const base = `${HOME}/.cache/huggingface/hub/${repo}/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;
const N = Number(process.env.N ?? 24);        // real examples to pool
const MAXLEN = Number(process.env.MAXLEN ?? 4096);
const MCAP = Number(process.env.MCAP ?? 4096); // cap on pooled response tokens
const FID_M = Number(process.env.FID_M ?? 512); // tokens for the full-logits fidelity check
// Real DPO data: uf-binarized-chat where present, else the Lucien chunk-v3 ORPO
// set (THE production training data; read-only).
const DATA_CANDIDATES = [
  `${HOME}/.cache/mlx-bun/data/uf-binarized-chat/train.jsonl`,
  `${HOME}/Code/lucien/benchmark/finetune/chunk-v3/dpo/orpo-curated-train.fixed.jsonl`,
];
const DATA = process.env.DATA ?? DATA_CANDIDATES.find((p) => existsSync(p));
if (!DATA || !existsSync(DATA)) throw new Error(`no DPO jsonl found — set DATA= (tried ${DATA_CANDIDATES.join(", ")})`);

const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
const H = config.text.hiddenSize, V = config.text.vocabSize;
let head: FlashCceHead;
if (model instanceof Gemma4Model) {
  const e = model.embed;
  head = { w: e.w, scales: e.scales, biases: e.biases!, bits: e.spec.bits, groupSize: e.spec.groupSize, softcap: config.text.finalLogitSoftcapping };
} else if (model instanceof MiniCPM5Model) {
  const lh = model.lmHead;
  head = { w: lh.w, scales: lh.scales, biases: lh.biases!, bits: lh.spec.bits, groupSize: lh.spec.groupSize, softcap: null };
} else throw new Error("unsupported model");

const tok = await loadTokenizer(MODEL);
const tmpl = await ChatTemplate.load(MODEL);
const lines = (await Bun.file(DATA).text()).split("\n").filter(Boolean).slice(0, N);

// Pool the REAL response hiddens + REAL targets from N examples (chosen branch).
const hParts: MlxArray[] = [];
const targets: number[] = [];
let used = 0;
for (const l of lines) {
  if (targets.length >= MCAP) break;
  const ex = encodeDpoRow(JSON.parse(l), tok, tmpl, MAXLEN);
  const ids = ex.chosenIds, mask = ex.chosenMask;       // real tokens + response mask
  const L = ids.length, T = L - 1;
  let startT = -1, M = 0;
  for (let t = 0; t < T; t++) if (mask[t + 1]) { if (startT < 0) startT = t; M++; }
  if (M <= 0) continue;
  M = Math.min(M, MCAP - targets.length);
  const idsArr = ops.fromInt32(ids.slice(0, T), [1, T]);
  const h = model.forwardHidden(idsArr, model.makeCache());    // [1,T,H] post-finalNorm
  const start = MlxArray.fromInt32(new Int32Array([startT]), [1]);
  const hResp = ops.reshape(ops.sliceDynamic(h, start, [1], [1, M, H]), [M, H]); // [M,H]
  evalAll([hResp]);
  hParts.push(MlxArray.fromBytesCopy(hResp.rawBytes(), [M, H], hResp.dtype)); // detached leaf
  for (let i = 0; i < M; i++) targets.push(ids[startT + 1 + i]!);             // REAL next tokens
  for (const a of [idsArr, h, start, hResp]) a.dispose();
  clearCache();
  used++;
}
const hResp = hParts.length === 1 ? hParts[0]! : ops.concatAxis(hParts, 0); // [Mtot, H]
const Mtot = targets.length;
hParts.forEach((p) => { if (p !== hResp) p.dispose(); });
console.log(`### flash-cce-filter-realdata  model=${E4B ? "e4b" : "MiniCPM5"}  pooled ${Mtot} REAL response tokens from ${used} examples  H=${H} V=${V}  data=${DATA}`);

// Peakedness of the real distribution: mean prob the model assigns the TRUE next
// token (high = confident/peaked → the regime the filter is built for).
const fwd0 = flashCceForward(hResp, head, targets);
evalAll([fwd0.logp, fwd0.lse, fwd0.blockMax]);
const lp = fwd0.logp.toFloat32();
let sp = 0; for (let i = 0; i < Mtot; i++) sp += Math.exp(lp[i]!);
console.log(`### mean P(true next token) = ${(100 * sp / Mtot).toFixed(1)}%  (peakedness proxy — higher = more peaked)`);

const cot = new Array(Mtot).fill(1.0) as number[]; // UNIT cotangent — exactly how the trainer invokes the backward
const lse = fwd0.lse;
const bm = fwd0.blockMax;

function bwd(fEps: string, blkEps = "0"): MlxArray { return flashCceBackward(hResp, head, targets, lse, cot, fEps, bm, blkEps); }
function timed(fEps: string, blkEps = "0"): number {
  let b: MlxArray | undefined;
  for (let i = 0; i < 2; i++) { b?.dispose(); b = bwd(fEps, blkEps); evalAll([b]); } // warm
  const t0 = performance.now();
  for (let i = 0; i < 5; i++) { b?.dispose(); b = bwd(fEps, blkEps); evalAll([b]); }
  const ms = (performance.now() - t0) / 5; b?.dispose(); return ms;
}
function errVs(refF: Float32Array, a: MlxArray): { rel: number; mx: number } {
  const fF = a.toFloat32();
  let d2 = 0, r2 = 0, mx = 0;
  for (let i = 0; i < Mtot * H; i++) { const d = refF[i]! - fF[i]!; d2 += d * d; r2 += refF[i]! * refF[i]!; if (Math.abs(d) > mx) mx = Math.abs(d); }
  return { rel: Math.sqrt(d2) / (Math.sqrt(r2) || 1), mx };
}

const exact = bwd("0"); evalAll([exact]); const exactF = exact.toFloat32(); const msExact = timed("0");

// --- gate: eps=0 path identity + the run-to-run noise floor. eps="0" compiles
// the filter OUT (#if CCE_BWD_FILTER 0 — same kernel source as the pre-flip
// default; keyed per-eps in the kernel cache), so path identity is structural.
// Run-to-run BYTE identity is not available on this kernel: dh accumulates via
// atomic float adds across vocab-block programs → fp reassociation varies per
// run. Measure that exact-vs-exact rel% here — it is the noise floor any filter
// error must be judged against. ---
{
  const again = bwd("0"); evalAll([again]);
  const { rel } = errVs(exactF, again);
  const a = new Uint8Array(exact.rawBytes()), b = new Uint8Array(again.rawBytes());
  let same = a.length === b.length;
  if (same) for (let i = 0; i < a.length; i++) if (a[i] !== b[i]) { same = false; break; }
  console.log(`### eps=0 run-to-run: ${same ? "byte-identical" : `atomic-accumulation noise floor rel=${(rel * 100).toFixed(4)}%`}`);
  again.dispose();
}

console.log(`\n### filter sweep on REAL data (dh error vs EXACT; backward ms)`);
console.log(`eps      | dh rel %   | maxAbs    | ms    | speedup`);
console.log(`exact    | 0          | —         | ${msExact.toFixed(0)}   | 1.00x`);
for (const eps of ["1e-6", "1e-5", "1e-4", "1e-3"]) {
  const f = bwd(eps); evalAll([f]);
  const { rel, mx } = errVs(exactF, f);
  f.dispose();
  const ms = timed(eps);
  console.log(`${eps.padEnd(8)} | ${(rel * 100).toFixed(3).padEnd(10)} | ${mx.toExponential(2)} | ${ms.toFixed(0).padEnd(5)} | ${(msExact / ms).toFixed(2)}x`);
}

// --- blockMax vocab-block early-exit on the same real data (lossless when it
// fires; the open question is whether real text makes whole blocks go cold) ---
console.log(`\n### blockMax skip sweep on REAL data (blockEps; filter eps as noted)`);
console.log(`filter/block  | dh rel %   | ms    | speedup`);
for (const [fEps, blkEps] of [["0", "1e-6"], ["0", "1e-5"], ["0", "1e-4"], ["1e-5", "1e-5"]] as const) {
  const f = bwd(fEps, blkEps); evalAll([f]);
  const { rel } = errVs(exactF, f);
  f.dispose();
  const ms = timed(fEps, blkEps);
  console.log(`${fEps}/${blkEps}`.padEnd(13) + ` | ${(rel * 100).toFixed(3).padEnd(10)} | ${ms.toFixed(0).padEnd(5)} | ${(msExact / ms).toFixed(2)}x`);
}

// --- teacher-forced grad fidelity: flash dh vs FULL-LOGITS autograd dh on the
// first FID_M pooled tokens (cosine + relnorm). The full-logits head is the
// bf16 whole-vocab reference (materializes [Mf,V]) — softcap included via
// logitsFromHidden. This is fp-reassociation-vs-reference, NOT error; the L3
// bar is "flash ≈ full within the bf16 class, filter adds ≲ the bf16 floor". ---
{
  const Mf = Math.min(FID_M, Mtot);
  const zero = MlxArray.fromInt32(new Int32Array([0]), [1]);
  const hF = ops.sliceDynamic(hResp, zero, [0], [Mf, H]);
  evalAll([hF]); zero.dispose();
  const tgtF = targets.slice(0, Mf);
  const vjp = new Vjp((primals) => {
    const h3 = ops.reshape(primals[0]!, [1, Mf, H]);
    const lg = (model as MiniCPM5Model | Gemma4Model).logitsFromHidden(h3); // [1,Mf,V] (softcap applied)
    const l2 = ops.reshape(lg, [Mf, V]);
    const lseF = ops.logsumexpAxis(l2, -1, false); // [Mf]
    const tgtArr = MlxArray.fromInt32(new Int32Array(tgtF), [Mf, 1]);
    const gathered = ops.reshape(ops.takeAlongAxis(l2, tgtArr, -1), [Mf]);
    const logpF = ops.sub(gathered, lseF); // [Mf]
    const s = ops.sumAxis(logpF.dtype === Dtype.float32 ? logpF : logpF.astype(Dtype.float32), 0, false);
    return [ops.reshape(s, [1])];
  });
  const one = MlxArray.fromFloat32(new Float32Array([1]), [1]);
  const { outputs, vjps } = vjp.apply([hF], [one]);
  const dhFull = vjps[0]!.dtype === Dtype.float32 ? vjps[0]! : vjps[0]!.astype(Dtype.float32);
  evalAll([dhFull]);
  const fullF = dhFull.toFloat32();
  const fid = (flashDh: Float32Array): { cos: number; rel: number } => {
    let dot = 0, na = 0, nb = 0, d2 = 0, r2 = 0;
    for (let i = 0; i < Mf * H; i++) {
      const a = fullF[i]!, b = flashDh[i]!;
      dot += a * b; na += a * a; nb += b * b;
      const d = a - b; d2 += d * d; r2 += a * a;
    }
    return { cos: dot / (Math.sqrt(na * nb) || 1), rel: Math.sqrt(d2) / (Math.sqrt(r2) || 1) };
  };
  // flash dh on the SAME slice (own forward for lse/blockMax on the slice)
  const fwdF = flashCceForward(hF, head, tgtF);
  evalAll([fwdF.lse, fwdF.blockMax]);
  const cotF = new Array(Mf).fill(1.0) as number[];
  for (const eps of ["0", "1e-5"] as const) {
    const dh = flashCceBackward(hF, head, tgtF, fwdF.lse, cotF, eps, fwdF.blockMax, "0");
    evalAll([dh]);
    const { cos, rel } = fid(dh.toFloat32());
    console.log(`### teacher-forced fidelity (Mf=${Mf})  flash eps=${eps} vs full-logits autograd:  cosine=${cos.toFixed(6)}  relnorm=${(rel * 100).toFixed(3)}%`);
    dh.dispose();
  }
  for (const a of [fwdF.logp, fwdF.lse, fwdF.blockMax, hF, one, dhFull, ...outputs]) a.dispose();
  if (vjps[0] !== dhFull) vjps[0]!.dispose();
  vjp.dispose();
}

console.log(`\n### verdict: the filter is worth enabling iff some eps gives a large speedup at dh error that's lost in the bf16 floor (~0.3%) — judged HERE on real targets, not synthetic.`);
exact.dispose(); fwd0.logp.dispose(); lse.dispose(); bm.dispose(); hResp.dispose(); weights.dispose();
