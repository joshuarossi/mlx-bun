// decode-roofline-step.ts — per-model decode-step decomposition against the
// measured-bandwidth roofline (2026-07-01 "look again" pass; generalizes
// decode-split.ts to any RuntimeModel via the factory).
//
// Mirrors generateInner's pipelined greedy loop (asyncEvalAll + itemUint32,
// clearCache cadence) and splits each step into:
//   t_graph    JS graph build (bun:ffi op calls)
//   t_dispatch asyncEvalAll call (blocks until the PRIOR buffer drains)
//   t_read     itemUint32 of the ready token
// Directional (session, loaded-machine caveat) — decomposition, not a
// press release.
//
//   bun scripts/experiments/decode-roofline-step.ts --model <snapshot-dir>
//       [--prompt-tokens N] [--steps N]

import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { CompiledDecode } from "../../src/model/compiled-decode";
import type { Gemma4Model } from "../../src/model/gemma4";
import { loadTokenizer } from "../../src/tokenizer";
import { ChatTemplate } from "../../src/chat-template";
import type { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { clearCache } from "../../src/mlx/ffi";
import { generate } from "../../src/generate";

const arg = (name: string, dflt: string): string => {
  const i = process.argv.indexOf(name);
  return i > -1 ? process.argv[i + 1]! : dflt;
};
const MODEL_DIR = arg("--model", "");
if (!MODEL_DIR) throw new Error("--model <snapshot-dir> required");
const PROMPT_TOKENS = Number(arg("--prompt-tokens", "128"));
const STEPS = Number(arg("--steps", "128"));
// --compiled: gemma4 dense only (mirrors generateInner's gate)
const COMPILED = process.argv.includes("--compiled");
process.env.MLX_BUN_COMPILED_DECODE = COMPILED ? "1" : "0";

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

// warmup on the same path (materialize weights, compile decode-shape kernels)
{
  const wCache = model.makeCache();
  const wGen = generate(model, promptIds.slice(0, 8), {
    maxTokens: 4, temperature: 0, cache: wCache,
  });
  for await (const _ of wGen) { /* discard */ }
  for (const c of wCache) c.dispose();
}

const med = (a: number[]): number =>
  a.slice().sort((x, y) => x - y)[Math.floor(a.length / 2)]!;
const sum = (a: number[]): number => a.reduce((s, v) => s + v, 0);

function runOnce(pass: number): void {
  const cache = model.makeCache();
  const CHUNK = 2048;
  let pos = 0;
  const tPrefill = performance.now();
  while (promptIds.length - pos > CHUNK) {
    const chunk = promptIds.slice(pos, pos + CHUNK);
    const cids = ops.fromInt32(chunk, [1, chunk.length]);
    const h = model.forwardHidden(cids, cache);
    cids.dispose();
    h.dispose();
    ops.evalAll(cache.flatMap((c) => c.state()));
    clearCache();
    pos += CHUNK;
  }
  const lastChunk = promptIds.slice(pos);
  const ids0 = ops.fromInt32(lastChunk, [1, lastChunk.length]);
  const h0 = model.forwardHidden(ids0, cache);
  ids0.dispose();
  const [, L0, H] = h0.shape as [number, number, number];
  const hLast = h0.slice([0, L0 - 1, 0], [1, L0, H]);
  h0.dispose();
  const logits0 = model.logitsFromHidden(hLast);
  hLast.dispose();
  const flat0 = ops.reshape(logits0, [1, logits0.shape[2]!]);
  logits0.dispose();
  let pending = ops.argmaxAxis(flat0, 1);
  flat0.dispose();
  pending.eval();
  clearCache();
  const prefillMs = performance.now() - tPrefill;

  const graphMs: number[] = [];
  const dispatchMs: number[] = [];
  const readMs: number[] = [];
  const tDecode = performance.now();
  for (let step = 0; step < STEPS; step++) {
    const cur = pending;
    const t0 = performance.now();
    let logits: MlxArray;
    let evalWith: MlxArray[] = [];
    if (COMPILED) {
      const r = CompiledDecode.for(model as Gemma4Model).step(cur, cache);
      logits = r.logits;
      evalWith = r.evalWith;
    } else {
      const tids = ops.reshape(cur, [1, 1]);
      const h = model.forwardHidden(tids, cache);
      tids.dispose();
      logits = model.logitsFromHidden(h);
      h.dispose();
    }
    const flat = ops.reshape(logits, [1, logits.shape[2]!]);
    logits.dispose();
    const next = ops.argmaxAxis(flat, 1);
    flat.dispose();
    const tG = performance.now();
    ops.asyncEvalAll([next, ...evalWith]);
    const t1 = performance.now();
    ops.itemUint32(cur); // sync-read step n's token while n+1 computes
    const t2 = performance.now();
    cur.dispose();
    pending = next;
    graphMs.push(tG - t0);
    dispatchMs.push(t1 - tG);
    readMs.push(t2 - t1);
    if (step > 0 && (step - 1) % 256 === 0) clearCache();
  }
  const decodeMs = performance.now() - tDecode;
  ops.itemUint32(pending);
  pending.dispose();
  for (const c of cache) c.dispose();
  clearCache();

  const msTok = decodeMs / STEPS;
  console.log(
    `pass${pass} ctx=${promptIds.length} steps=${STEPS}  prefill=${prefillMs.toFixed(0)}ms  ` +
    `decode=${msTok.toFixed(2)}ms/tok (${(1000 / msTok).toFixed(1)} tok/s)`,
  );
  console.log(
    `  per-step median: graph=${med(graphMs).toFixed(2)}ms  dispatch=${med(dispatchMs).toFixed(2)}ms  ` +
    `read=${med(readMs).toFixed(3)}ms   totals: graph=${(sum(graphMs) / STEPS).toFixed(2)}  ` +
    `dispatch=${(sum(dispatchMs) / STEPS).toFixed(2)}  read=${(sum(readMs) / STEPS).toFixed(3)}`,
  );
}

runOnce(1);
runOnce(2);
