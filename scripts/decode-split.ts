// Decode-gap instrumentation: per-step wall-time split of the pipelined
// decode loop. For each step, t_build = JS graph construction + the
// async_eval dispatch (host-side cost); t_read = time blocked in
// itemUint32 waiting for the GPU (device-side cost). The pipelined loop
// hides whichever is smaller — comparing the split at @600 vs @8k, and
// against the python oracle (scripts/oracle-decode-split.py), localizes
// the decode gap to host or device.
//
//   bun scripts/decode-split.ts [--prompt-tokens N] [--steps N]
//
// Mirrors generateInner's loop exactly (greedy; no processors; bf16 KV).
// Diagnostic ratios only — not an eval-DB benchmark.

import { SNAPSHOT } from "../tests/paths";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { Gemma4Model } from "../src/model/gemma4";
import { CompiledDecode } from "../src/model/compiled-decode";
import { loadTokenizer } from "../src/tokenizer";
import { ChatTemplate } from "../src/chat-template";
import type { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import { clearCache } from "../src/mlx/ffi";
import { generate } from "../src/generate";

const CLEAR = process.argv.includes("--clear-cache");
// --compiled: replay the decode graph via mx.compile (Phase A lever),
// mirroring generateInner's compiled branch. A/B against the default
// JS-graph-build loop below.
const COMPILED = process.argv.includes("--compiled");
// keep the warmup generate() on the same path as the measured loop
process.env.MLX_BUN_COMPILED_DECODE = COMPILED ? "1" : "0";
// --no-fuse: replay without kernel fusion (isolates fusion-codegen cost
// from the graph-replay win in the compiled A/B)
if (process.argv.includes("--no-fuse")) {
  const { setCompileMode } = await import("../src/mlx/compile");
  setCompileMode("no_fuse");
}

const ptIdx = process.argv.indexOf("--prompt-tokens");
const PROMPT_TOKENS = ptIdx > -1 ? Number(process.argv[ptIdx + 1]) : 600;
const stIdx = process.argv.indexOf("--steps");
const STEPS = stIdx > -1 ? Number(process.argv[stIdx + 1]) : 128;
const mIdx = process.argv.indexOf("--model");
const MODEL_DIR = mIdx > -1 ? process.argv[mIdx + 1]! : SNAPSHOT;

const config = await loadModelConfig(MODEL_DIR);
const weights = await Weights.open(MODEL_DIR);
const model = new Gemma4Model(weights, config);
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

// warmup (materialize weights, compile decode-shape kernels)
{
  const wCache = model.makeCache();
  const wGen = generate(model, promptIds.slice(0, 8), {
    maxTokens: 4, temperature: 0, cache: wCache,
  });
  for await (const _ of wGen) { /* discard */ }
  for (const c of wCache) c.dispose();
}

const PASSES = process.argv.includes("--twice") ? 2 : 1;
// --ab: interleaved uncompiled/compiled passes in one process — paired
// ratios survive machine drift (cross-process absolutes don't).
const AB = process.argv.includes("--ab");

function runOnce(pass: number, compiledPass = COMPILED) {
  // ---- prefill (chunked, like generateInner; greedy first token) ----
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
    if (CLEAR) clearCache(); // mirror mlx-lm generate_step's prefill loop
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
  if (CLEAR) clearCache(); // and once more before the decode clock starts
  const prefillMs = performance.now() - tPrefill;

  // ---- pipelined decode with per-step split timers ----
  const graphMs: number[] = [];
  const dispatchMs: number[] = [];
  const readMs: number[] = [];
  const disposeMs: number[] = [];
  const interMs: number[] = []; // between end of step n and start of n+1
  let prevEnd = 0;
  const tDecode = performance.now();
  for (let step = 0; step < STEPS; step++) {
    const cur = pending;
    const t0 = performance.now();
    // build step n+1's graph from the unread pending token
    let logits: MlxArray;
    let evalWith: MlxArray[] = [];
    if (compiledPass) {
      const r = CompiledDecode.for(model).step(cur, cache);
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
    const t3 = performance.now();
    pending = next;
    graphMs.push(tG - t0);
    dispatchMs.push(t1 - tG);
    readMs.push(t2 - t1);
    disposeMs.push(t3 - t2);
    if (step > 0) interMs.push(t0 - prevEnd);
    prevEnd = t3;
  }
  const decodeMs = performance.now() - tDecode;
  ops.itemUint32(pending);
  pending.dispose();
  for (const c of cache) c.dispose();

  const q = (xs: number[], p: number) => {
    const s = [...xs].sort((a, b) => a - b);
    return s[Math.min(s.length - 1, Math.floor(p * s.length))]!;
  };
  const sum = (xs: number[]) => xs.reduce((a, b) => a + b, 0);
  const fmt = (xs: number[]) =>
    `median ${q(xs, 0.5).toFixed(2)} ms  p10 ${q(xs, 0.1).toFixed(2)}  p90 ${q(xs, 0.9).toFixed(2)}  total ${sum(xs).toFixed(0)} ms`;

  console.log(`--- pass ${pass}${AB ? (compiledPass ? " [compiled]" : " [uncompiled]") : ""} ---`);
  console.log(`ctx=${promptIds.length} steps=${STEPS} prefill=${prefillMs.toFixed(0)} ms`);
  console.log(`decode ${(STEPS / decodeMs * 1000).toFixed(1)} tok/s (${(decodeMs / STEPS).toFixed(2)} ms/step)`);
  console.log(`t_graph    (JS graph build, FFI): ${fmt(graphMs)}`);
  console.log(`t_dispatch (asyncEvalAll call):   ${fmt(dispatchMs)}`);
  console.log(`t_read     (blocked in item):     ${fmt(readMs)}`);
  console.log(`t_dispose  (cur.dispose):         ${fmt(disposeMs)}`);
  console.log(`t_inter    (between iterations):  ${fmt(interMs)}`);
  console.log(
    `split: graph ${(100 * sum(graphMs) / decodeMs).toFixed(1)}% / dispatch ${(100 * sum(dispatchMs) / decodeMs).toFixed(1)}% / read ${(100 * sum(readMs) / decodeMs).toFixed(1)}% of decode wall`,
  );
  const slow = dispatchMs
    .map((v, i) => [i, v] as const)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 10);
  console.log(
    `slowest dispatch steps: ${slow.map(([i, v]) => `#${i}=${v.toFixed(0)}ms`).join(" ")}`,
  );
}

if (AB) {
  // u/c/u/c: first pass of each mode warms its path; compare pass 3 vs 4
  for (let p = 1; p <= 4; p++) runOnce(p, p % 2 === 0);
} else {
  for (let p = 1; p <= PASSES; p++) runOnce(p);
}
