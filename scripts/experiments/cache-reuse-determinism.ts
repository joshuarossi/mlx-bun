// The raw forward is bit-deterministic (forward-determinism.ts). So the server's
// temp-0 drift must be the CACHE-REUSE path: a warm request reuses cached KV
// (= prefill[prompt-1] + decode the boundary token) instead of cold prefill[prompt].
// Two measurements:
//   C1 (atomic): is cold prefill[T] last-logits == split prefill[T-1]+decode[1]?
//   C2 (full):   cold greedy gen  vs  warm greedy gen (gen → trim back → gen).
//
//   bun scripts/experiments/cache-reuse-determinism.ts
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
const promptIds: number[] = (tok as { encode(s: string): number[] }).encode(
  "Name three primary colors and explain why each one matters in painting, with concrete detail.");
const T = promptIds.length;
console.log(`### prompt ${T} tok · H=${H} V=${V}`);

function lastLogits(h: MlxArray, len: number): { vec: Float32Array; tok: number } {
  const start = MlxArray.fromInt32(new Int32Array([len - 1]), [1]);
  const hLast = ops.sliceDynamic(h, start, [1], [1, 1, H]);
  const logits = model.logitsFromHidden(hLast);
  const lv = ops.reshape(logits, [V]);
  const am = ops.argmaxAxis(lv, -1);
  evalAll([lv, am]);
  const vec = lv.toFloat32(); const t = ops.itemUint32(am);
  start.dispose(); hLast.dispose(); logits.dispose(); lv.dispose(); am.dispose();
  return { vec, tok: t };
}
function step(t: number, cache: ReturnType<typeof model.makeCache>): { vec: Float32Array; tok: number } {
  const s = ops.fromInt32([t], [1, 1]);
  const h = model.forwardHidden(s, cache); s.dispose();
  const r = lastLogits(h, 1); h.dispose();
  return r;
}

// ── C1: cold prefill[T]  vs  split prefill[T-1] + decode[1] ──
console.log(`\n### C1 — cold prefill[T] last-logits  vs  split prefill[T-1]+decode[T]`);
const cold = (() => { const c = model.makeCache(); const ids = ops.fromInt32(promptIds, [1, T]);
  const h = model.forwardHidden(ids, c); const r = lastLogits(h, T); ids.dispose(); h.dispose(); for (const x of c) x.dispose(); clearCache(); return r; })();
const split = (() => { const c = model.makeCache(); const ids = ops.fromInt32(promptIds.slice(0, T - 1), [1, T - 1]);
  const h = model.forwardHidden(ids, c); ids.dispose(); h.dispose();        // prefill T-1, discard
  const r = step(promptIds[T - 1]!, c); for (const x of c) x.dispose(); clearCache(); return r; })();
let mx = 0, n = 0; for (let k = 0; k < V; k++) { const d = Math.abs(cold.vec[k]! - split.vec[k]!); if (d > mx) mx = d; if (d !== 0) n++; }
console.log(`  cold next=${cold.tok}  split next=${split.tok}  maxAbsΔ=${mx.toExponential(2)}  differing=${n}/${V}  ${mx === 0 ? "BIT-IDENTICAL" : "DIFFERS ← prefill≠decode"}`);

// ── C2: cold gen  vs  warm gen (gen, trim cache back to prompt, gen again) ──
const MAXNEW = Number(process.env.MAXNEW ?? 220);
function genFrom(cache: ReturnType<typeof model.makeCache>, firstTok: number): number[] {
  let t = firstTok; const out = [t];
  for (let i = 0; i < MAXNEW - 1 && !eos.has(t); i++) { t = step(t, cache).tok; out.push(t); }
  return out;
}
console.log(`\n### C2 — cold (prefill[T]) greedy  vs  warm (prefill[T-1]+decode boundary) greedy. maxNew=${MAXNEW}`);
// cold: prefill all T in one shot, then generate
const cCold = model.makeCache(); const idsC = ops.fromInt32(promptIds, [1, T]);
const hC = model.forwardHidden(idsC, cCold); const rC = lastLogits(hC, T); idsC.dispose(); hC.dispose();
const seqCold = genFrom(cCold, rC.tok);
for (const x of cCold) x.dispose(); clearCache();
// warm: prefill T-1, decode the boundary token (the cache-reuse path), then generate
const cWarm = model.makeCache(); const idsW = ops.fromInt32(promptIds.slice(0, T - 1), [1, T - 1]);
const hW = model.forwardHidden(idsW, cWarm); idsW.dispose(); hW.dispose();
const boundary = step(promptIds[T - 1]!, cWarm);
const seqWarm = genFrom(cWarm, boundary.tok);
for (const x of cWarm) x.dispose(); clearCache();
{ let i = 0; const L = Math.min(seqCold.length, seqWarm.length); while (i < L && seqCold[i] === seqWarm[i]) i++;
  if (i === seqCold.length && i === seqWarm.length) console.log(`  cold vs warm: IDENTICAL (${i} tokens)`);
  else console.log(`  cold vs warm: diverge at token ${i}/${L}  cold=${seqCold[i]} warm=${seqWarm[i]}  ← cache reuse changes the output`); }

weights.dispose();
console.log(`\n### done`);
