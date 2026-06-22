// EXACTLY where do warm and cold diverge? Run, on the real MiniCPM5, both:
//   COLD  = prefill[T]                       → boundary is position T-1
//   WARM  = prefill[T-1] (fills cache) + decode the boundary token → position 0
// and capture the boundary token's hidden state AFTER EVERY LAYER. Also track a
// shared-PREFIX position (T-2) for prefill[T] vs prefill[T-1], to tell whether the
// split is in the boundary's own decode or in the cached prefix it reads.
//
//   bun scripts/experiments/warm-cold-layer-trace.ts
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
const model = createModel(weights, config) as any;
const tok = await loadTokenizer(MODEL);
const H = config.text.hiddenSize;
const nL = model.layers.length;
const ids: number[] = (tok as { encode(s: string): number[] }).encode(
  "Name three primary colors and explain why each one matters in painting.");
const T = ids.length;
console.log(`### T=${T} tok · ${nL} layers · H=${H}`);

function row(h: MlxArray, pos: number): Float32Array {
  const start = MlxArray.fromInt32(new Int32Array([pos]), [1]);
  const s = ops.sliceDynamic(h, start, [1], [1, 1, H]);
  const r = ops.reshape(s, [H]); evalAll([r]); const f = r.toFloat32();
  start.dispose(); s.dispose(); r.dispose(); return f;
}
const maxAbs = (a: Float32Array, b: Float32Array) => { let mx = 0; for (let i = 0; i < a.length; i++) { const d = Math.abs(a[i]! - b[i]!); if (d > mx) mx = d; } return mx; };

// COLD: prefill[T] layer by layer → capture boundary (T-1) and prefix (T-2)
const cCold = model.makeCache();
const idsT = ops.fromInt32(ids, [1, T]);
let h = model.embed.encode(idsT);
const coldB: Float32Array[] = [], coldP: Float32Array[] = [];
const embB = row(h, T - 1), embP = row(h, T - 2);
for (let i = 0; i < nL; i++) { const n = model.runLayerRange(h, i, i + 1, cCold); coldB.push(row(n, T - 1)); coldP.push(row(n, T - 2)); h.dispose(); h = n; }
h.dispose(); idsT.dispose(); for (const c of cCold) c.dispose(); clearCache();

// WARM prefill[T-1] layer by layer → capture prefix (T-2), fills cWarm
const cWarm = model.makeCache();
const idsTm1 = ops.fromInt32(ids.slice(0, T - 1), [1, T - 1]);
let hp = model.embed.encode(idsTm1);
const warmP: Float32Array[] = [];
const embWP = row(hp, T - 2);
for (let i = 0; i < nL; i++) { const n = model.runLayerRange(hp, i, i + 1, cWarm); warmP.push(row(n, T - 2)); hp.dispose(); hp = n; }
hp.dispose(); idsTm1.dispose();

// WARM decode the boundary token, layer by layer, over the filled cache → position 0
const idsB = ops.fromInt32([ids[T - 1]!], [1, 1]);
let hd = model.embed.encode(idsB);
const warmB: Float32Array[] = [];
const embWB = row(hd, 0);
for (let i = 0; i < nL; i++) { const n = model.runLayerRange(hd, i, i + 1, cWarm); warmB.push(row(n, 0)); hd.dispose(); hd = n; }
hd.dispose(); idsB.dispose(); for (const c of cWarm) c.dispose(); clearCache();

console.log(`### sanity: embedding Δ — boundary ${maxAbs(embB, embWB).toExponential(2)} (==0: same token), prefix ${maxAbs(embP, embWP).toExponential(2)}`);
console.log(`\nlayer |  prefix Δ (prefill[T] vs prefill[T-1], pos T-2)  |  boundary Δ (cold vs warm, the decoded token)`);
for (let i = 0; i < nL; i++) {
  console.log(`  ${String(i).padStart(2)}  |  ${maxAbs(coldP[i]!, warmP[i]!).toExponential(3).padStart(12)}  |  ${maxAbs(coldB[i]!, warmB[i]!).toExponential(3)}`);
}
weights.dispose();
console.log("\n### done");
