// One-off (2026-08-22 prefill-vs-mlx-lm analysis): verify that changing
// prefillChunkSize leaves LOGITS untouched — full-vocab comparison of the
// step-0 distribution between the 2048 oracle convention and candidate
// chunk sizes. Complements the greedy-trajectory check in
// prefill-chunk-ab.ts (Josh asked for logits explicitly).
//
//   bun scripts/experiments/prefill-logits-ab.ts [--model <query>] [--ctx N]

import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { ChatTemplate } from "../../src/chat-template";
import { loadTokenizer } from "../../src/tokenizer";
import { evalCacheState } from "../../src/generate";
import * as ops from "../../src/mlx/ops";
import { Dtype } from "../../src/mlx/ffi";

const MODEL_QUERY_IDX = process.argv.indexOf("--model");
const MODEL_QUERY = MODEL_QUERY_IDX > -1 ? process.argv[MODEL_QUERY_IDX + 1]! : "12B-it-OptiQ";
const CTX_IDX = process.argv.indexOf("--ctx");
const CTX = CTX_IDX > -1 ? Number(process.argv[CTX_IDX + 1]) : 3000;

const { Registry } = await import("../../src/registry");
const reg = new Registry();
if (reg.list().length === 0) await reg.scan();
const m = reg.resolve(MODEL_QUERY);
reg.close();

const cfg = await loadModelConfig(m.path);
const weights = await Weights.open(m.path);
const model = createModel(weights, cfg);
const tok = await loadTokenizer(m.path);
const tpl = await ChatTemplate.load(m.path);

let msg = "Summarize the history of computing.";
const filler =
  "Background context: the history of computation spans mechanical " +
  "calculators, relays, vacuum tubes, transistors, integrated circuits, " +
  "and accelerators. ";
while (tok.encode(msg).length < CTX - 24) msg = filler + msg;
const rendered = tpl.render([{ role: "user", content: msg }]);
const idsAll = tok.encode(rendered);
const promptIds =
  idsAll[0] === idsAll[1] && idsAll[0] === tok.bosTokenId ? idsAll.slice(1) : idsAll;

async function forwardHidden(ids: number[], cache: ReturnType<typeof model.makeCache>) {
  const idArr = ops.fromInt32(ids, [1, ids.length]);
  const asyncModel = model as typeof model & {
    forwardHiddenAsync?: (a: unknown, c: unknown) => Promise<ReturnType<typeof model.forwardHidden>>;
  };
  const h = typeof asyncModel.forwardHiddenAsync === "function"
    ? await asyncModel.forwardHiddenAsync(idArr, cache)
    : model.forwardHidden(idArr, cache);
  idArr.dispose();
  return h;
}

async function step0Logits(chunk: number): Promise<Float32Array> {
  const cache = model.makeCache();
  try {
    // drain to len-1 exactly like generate()'s tail-split convention,
    // then take the L=1 step-0 forward and read its full-vocab logits
    let pos = 0;
    while (promptIds.length - pos > 1) {
      const n = Math.min(chunk, promptIds.length - pos - 1);
      const h = await forwardHidden(promptIds.slice(pos, pos + n), cache);
      h.dispose();
      evalCacheState(cache);
      pos += n;
    }
    const last = ops.fromInt32(promptIds.slice(pos), [1, promptIds.length - pos]);
    const logits = model.forward(last, cache);
    last.dispose();
    const f32 = logits.astype(Dtype.float32);
    f32.eval();
    const out = f32.toFloat32();
    f32.dispose();
    logits.dispose();
    return out;
  } finally {
    for (const c of cache) c.dispose();
  }
}

// determinism controls first: same chunk twice MUST be exactly 0
const base = await step0Logits(2048);
const baseRepeat = await step0Logits(2048);
let dRep = 0;
for (let i = 0; i < base.length; i++)
  dRep = Math.max(dRep, Math.abs(base[i]! - baseRepeat[i]!));
console.log(`determinism 2048-vs-2048: max|Δ|=${dRep.toExponential(3)}`);

for (const chunk of [1024, 512]) {
  const cand = await step0Logits(chunk);
  const candRepeat = await step0Logits(chunk);
  let dSelf = 0;
  for (let i = 0; i < cand.length; i++)
    dSelf = Math.max(dSelf, Math.abs(cand[i]! - candRepeat[i]!));
  let maxAbs = 0;
  let bi = 0, ci = 0;
  for (let i = 0; i < base.length; i++) {
    const d = Math.abs(base[i]! - cand[i]!);
    if (d > maxAbs) maxAbs = d;
    if (base[i]! > base[bi]!) bi = i;
    if (cand[i]! > cand[ci]!) ci = i;
  }
  console.log(
    `chunk=${chunk}: self max|Δ|=${dSelf.toExponential(3)} · vs-2048 max|Δlogit|=${maxAbs.toExponential(3)} argmax ${bi === ci ? `SAME (${bi})` : `DIFF ${bi} vs ${ci}`}`,
  );
}
