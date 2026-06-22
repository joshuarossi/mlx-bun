// Pin the temp-0 nondeterminism EXACTLY. Two tests, no server, raw model:
//   A: run the SAME prefill forward N times (fresh cache each) → are the logits
//      bit-identical? (is the forward itself deterministic?)
//   B: run a full GREEDY decode (argmax, the temp-0 path) N times → where does
//      the token sequence first diverge? (reproduces the long-output drift)
//
//   bun scripts/experiments/forward-determinism.ts
import { readdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import * as ops from "../../src/mlx/ops";
import { evalAll } from "../../src/mlx/ops";
import { clearCache } from "../../src/mlx/ffi";
import { MlxArray } from "../../src/mlx/array";
import { loadTokenizer } from "../../src/tokenizer";

const HOME = process.env.HOME!;
const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots`;
const MODEL = `${base}/${readdirSync(base)[0]}`;
const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
const tok = await loadTokenizer(MODEL);
const H = config.text.hiddenSize, V = config.text.vocabSize;
const eos = new Set<number>([config.text.eosTokenId].filter((x): x is number => x != null));

const text = "Name three primary colors and explain why each one matters in painting, with concrete detail.";
const promptIds: number[] = (tok as { encode(s: string): number[] }).encode(text);
const T = promptIds.length;
console.log(`### prompt ${T} tok · H=${H} V=${V} · eos=${[...eos].join(",")}`);

// next-token argmax from a hidden state's LAST position (exactly the server path:
// slice last hidden → head → argmax).
function nextToken(h: MlxArray, len: number): { tok: number; logitsVec: MlxArray } {
  const start = MlxArray.fromInt32(new Int32Array([len - 1]), [1]);
  const hLast = ops.sliceDynamic(h, start, [1], [1, 1, H]); // [1,1,H]
  const logits = model.logitsFromHidden(hLast);             // [1,1,V]
  const lv = ops.reshape(logits, [V]);
  const am = ops.argmaxAxis(lv, -1);
  evalAll([lv, am]);
  const t = ops.itemUint32(am);
  start.dispose(); hLast.dispose(); logits.dispose(); am.dispose();
  return { tok: t, logitsVec: lv }; // caller disposes logitsVec
}

// === TEST A: single prefill forward, repeated, fresh cache ===
console.log(`\n### TEST A — prefill forward × 5 (fresh cache each). Is it bit-identical?`);
let refVec: Float32Array | null = null;
for (let r = 0; r < 5; r++) {
  const cache = model.makeCache();
  const ids = ops.fromInt32(promptIds, [1, T]);
  const h = model.forwardHidden(ids, cache);
  const { tok: nt, logitsVec } = nextToken(h, T);
  const vec = logitsVec.toFloat32();
  ids.dispose(); h.dispose(); logitsVec.dispose(); for (const c of cache) c.dispose(); clearCache();
  if (r === 0) { refVec = vec; console.log(`  run 0: next=${nt} (ref)`); }
  else {
    let mx = 0, n = 0; for (let k = 0; k < V; k++) { const d = Math.abs(refVec![k]! - vec[k]!); if (d > mx) mx = d; if (d !== 0) n++; }
    console.log(`  run ${r}: next=${nt}  maxAbsΔ=${mx.toExponential(2)}  differingLogits=${n}/${V}  ${mx === 0 ? "BIT-IDENTICAL" : "DIFFERS"}`);
  }
}

// === TEST B: full greedy decode, repeated, find first divergence ===
const MAXNEW = Number(process.env.MAXNEW ?? 220);
function greedy(): number[] {
  const cache = model.makeCache();
  const ids = ops.fromInt32(promptIds, [1, T]);
  let h = model.forwardHidden(ids, cache); ids.dispose();
  let { tok: t, logitsVec } = nextToken(h, T); h.dispose(); logitsVec.dispose();
  const out = [t];
  for (let i = 0; i < MAXNEW - 1 && !eos.has(t); i++) {
    const step = ops.fromInt32([t], [1, 1]);
    const hh = model.forwardHidden(step, cache); step.dispose();
    const r = nextToken(hh, 1); hh.dispose(); r.logitsVec.dispose();
    t = r.tok; out.push(t);
  }
  for (const c of cache) c.dispose(); clearCache();
  return out;
}
console.log(`\n### TEST B — greedy decode × 4 (maxNew=${MAXNEW}). Where do they first diverge?`);
const seqs: number[][] = [];
for (let r = 0; r < 4; r++) { seqs.push(greedy()); console.log(`  run ${r}: ${seqs[r]!.length} tokens`); }
const ref = seqs[0]!;
for (let r = 1; r < 4; r++) {
  const s = seqs[r]!; let i = 0; const L = Math.min(ref.length, s.length);
  while (i < L && ref[i] === s[i]) i++;
  if (i === ref.length && i === s.length) console.log(`  run ${r} vs run 0: IDENTICAL (${i} tokens)`);
  else console.log(`  run ${r} vs run 0: diverge at token ${i}/${L}  (ref=${ref[i]} '${(tok as any).decode?.([ref[i]!]) ?? ""}' vs got=${s[i]} '${(tok as any).decode?.([s[i] ?? -1]) ?? ""}')`);
}
weights.dispose();
console.log(`\n### done`);
