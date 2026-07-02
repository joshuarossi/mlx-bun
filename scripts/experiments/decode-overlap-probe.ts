// decode-overlap-probe.ts — the graph-build-overlap spike (decode-roofline-
// lookagain.md §6.1b). Question: the per-token host JS graph build (1.0 ms CPM5,
// 3.4–3.7 ms e4b/12B/26B) measures SERIAL with the GPU — can it hide under the
// GPU instead?
//
// Localizes where the GPU actually sits idle relative to the host timeline by
// injecting a known host busy-wait (spin) at different points in the pipelined
// loop, then measuring which injections surface in wall time:
//
//   arm baseline    the production loop shape (build → asyncEval → read)
//   arm spin-pre    +W ms spin BETWEEN build and asyncEvalAll
//                   (wall +W ⇒ GPU idle in that window; wall flat ⇒ GPU busy)
//   arm spin-post   +W ms spin AFTER asyncEvalAll, before the token read
//                   (wall flat ⇒ the dispatched buffer really runs async)
//   arm spin-build  +W ms spin DURING the build phase (before graph calls)
//   arm chain-K     build/dispatch K steps ahead of the read (deeper pipeline;
//                   K=1 is baseline). Token-identity-checked vs baseline.
//
//   bun scripts/experiments/decode-overlap-probe.ts --model <snapshot-dir>
//       [--steps N] [--spin MS] [--prompt-tokens N]
//
// Directional (session, loaded-machine caveat) — decomposition, not a press
// release. Greedy; bf16 KV; uncompiled path (the spike targets the general
// mechanism, not CompiledDecode).

import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { loadTokenizer } from "../../src/tokenizer";
import { ChatTemplate } from "../../src/chat-template";
import type { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { clearCache } from "../../src/mlx/ffi";
import type { Cache } from "../../src/model/gemma4-base";

const arg = (name: string, dflt: string): string => {
  const i = process.argv.indexOf(name);
  return i > -1 ? process.argv[i + 1]! : dflt;
};
const MODEL_DIR = arg("--model", "");
if (!MODEL_DIR) throw new Error("--model <snapshot-dir> required");
const PROMPT_TOKENS = Number(arg("--prompt-tokens", "128"));
const STEPS = Number(arg("--steps", "96"));
const SPIN = Number(arg("--spin", "2")); // ms of injected host work

const config = await loadModelConfig(MODEL_DIR);
const weights = await Weights.open(MODEL_DIR);
const model = createModel(weights, config);
const tok = await loadTokenizer(MODEL_DIR);
const template = await ChatTemplate.load(MODEL_DIR);

let userMsg =
  "Write a detailed essay about the history of computing, starting with mechanical calculators.";
const filler =
  "Background context: the history of computation spans mechanical " +
  "calculators, electromechanical relays, vacuum tubes, transistors, " +
  "integrated circuits, and modern accelerators. ";
while (tok.encode(userMsg).length < PROMPT_TOKENS - 24) userMsg = filler + userMsg;
const rendered = template.render([{ role: "user", content: userMsg }]);
const ids = tok.encode(rendered);
const promptIds = ids[0] === ids[1] && ids[0] === tok.bosTokenId ? ids.slice(1) : ids;

const spin = (ms: number): void => {
  const t0 = performance.now();
  while (performance.now() - t0 < ms) { /* burn host */ }
};

function prefill(cache: Cache[]): MlxArray {
  const ids0 = ops.fromInt32(promptIds, [1, promptIds.length]);
  const h0 = model.forwardHidden(ids0, cache);
  ids0.dispose();
  const [, L0, H] = h0.shape as [number, number, number];
  const hLast = h0.slice([0, L0 - 1, 0], [1, L0, H]);
  h0.dispose();
  const logits0 = model.logitsFromHidden(hLast);
  hLast.dispose();
  const flat0 = ops.reshape(logits0, [1, logits0.shape[2]!]);
  logits0.dispose();
  const p = ops.argmaxAxis(flat0, 1);
  flat0.dispose();
  p.eval();
  clearCache();
  return p;
}

/** One decode step's graph: token array [1] -> next-token array [1]. */
function buildStep(cur: MlxArray, cache: Cache[]): MlxArray {
  const tids = ops.reshape(cur, [1, 1]);
  const h = model.forwardHidden(tids, cache);
  tids.dispose();
  const logits = model.logitsFromHidden(h);
  h.dispose();
  const flat = ops.reshape(logits, [1, logits.shape[2]!]);
  logits.dispose();
  const next = ops.argmaxAxis(flat, 1);
  flat.dispose();
  return next;
}

type Arm = "baseline" | "serial" | "spin-build" | "spin-pre" | "spin-post" | `chain-${number}`;

function run(armName: Arm): { msTok: number; graph: number; dispatch: number; read: number; tokens: number[] } {
  const cache = model.makeCache();
  let pending = prefill(cache);
  const tokens: number[] = [];
  const graphMs: number[] = [];
  const dispatchMs: number[] = [];
  const readMs: number[] = [];
  const chainK = armName.startsWith("chain-") ? Number(armName.slice(6)) : 1;

  const tDecode = performance.now();
  if (chainK > 1) {
    // Deeper pipeline: keep K step-graphs dispatched ahead of the token read.
    // Graphs chain lazily (step k+1's input is step k's UNREAD argmax node).
    const inflight: MlxArray[] = [pending];
    for (let step = 0; step < STEPS; step++) {
      const t0 = performance.now();
      const next = buildStep(inflight[inflight.length - 1]!, cache);
      const tG = performance.now();
      ops.asyncEvalAll([next]);
      const t1 = performance.now();
      inflight.push(next);
      let t2 = t1;
      if (inflight.length > chainK) {
        const oldest = inflight.shift()!;
        tokens.push(ops.itemUint32(oldest));
        t2 = performance.now();
        oldest.dispose();
      }
      graphMs.push(tG - t0);
      dispatchMs.push(t1 - tG);
      readMs.push(t2 - t1);
      if (step > 0 && (step - 1) % 256 === 0) clearCache();
    }
    for (const a of inflight) { tokens.push(ops.itemUint32(a)); a.dispose(); }
  } else if (armName === "serial") {
    // No pipelining: read each token before building the next step — the wall
    // here SHOULD be ≈ pipelined wall + graph if the pipelined loop hides the
    // build (the anchor for the overlap claim).
    for (let step = 0; step < STEPS; step++) {
      const cur = pending;
      const t0 = performance.now();
      const next = buildStep(cur, cache);
      const tG = performance.now();
      ops.evalAll([next]);
      const t1 = performance.now();
      tokens.push(ops.itemUint32(cur));
      const t2 = performance.now();
      cur.dispose();
      pending = next;
      graphMs.push(tG - t0);
      dispatchMs.push(t1 - tG);
      readMs.push(t2 - t1);
      if (step > 0 && (step - 1) % 256 === 0) clearCache();
    }
    tokens.push(ops.itemUint32(pending));
    pending.dispose();
  } else {
    for (let step = 0; step < STEPS; step++) {
      const cur = pending;
      const t0 = performance.now();
      if (armName === "spin-build") spin(SPIN);
      const next = buildStep(cur, cache);
      const tG = performance.now();
      if (armName === "spin-pre") spin(SPIN);
      const tPre = performance.now();
      ops.asyncEvalAll([next]);
      const t1 = performance.now();
      if (armName === "spin-post") spin(SPIN);
      const tPost = performance.now();
      tokens.push(ops.itemUint32(cur));
      const t2 = performance.now();
      cur.dispose();
      pending = next;
      graphMs.push(tG - t0);
      dispatchMs.push(t1 - tPre);
      readMs.push(t2 - tPost);
      if (step > 0 && (step - 1) % 256 === 0) clearCache();
    }
    tokens.push(ops.itemUint32(pending));
    pending.dispose();
  }
  const decodeMs = performance.now() - tDecode;
  for (const c of cache) c.dispose();
  clearCache();

  const med = (a: number[]): number => a.slice().sort((x, y) => x - y)[Math.floor(a.length / 2)]!;
  return { msTok: decodeMs / STEPS, graph: med(graphMs), dispatch: med(dispatchMs), read: med(readMs), tokens };
}

// warmup pass (materialize weights + shape-compile kernels)
run("baseline");

const arms: Arm[] = ["baseline", "serial", "spin-build", "spin-pre", "spin-post", "chain-2", "chain-3", "baseline"];
const ref: number[] = [];
console.log(`### decode-overlap-probe  model=${config.modelType} ctx=${promptIds.length} steps=${STEPS} spin=${SPIN}ms`);
console.log(`arm        | ms/tok | graph | dispatch | read  | Δ vs baseline | tokens`);
let base = 0;
for (const a of arms) {
  const r = run(a);
  if (a === "baseline" && ref.length === 0) { ref.push(...r.tokens); base = r.msTok; }
  const same = r.tokens.length === ref.length && r.tokens.every((t, i) => t === ref[i]);
  console.log(
    `${a.padEnd(10)} | ${r.msTok.toFixed(2).padStart(6)} | ${r.graph.toFixed(2).padStart(5)} | ${r.dispatch.toFixed(2).padStart(8)} | ${r.read.toFixed(3).padStart(5)} | ${(r.msTok - base >= 0 ? "+" : "") + (r.msTok - base).toFixed(2).padStart(5)} ms | ${same ? "IDENTICAL" : "DIVERGED"}`,
  );
}
weights.dispose();
