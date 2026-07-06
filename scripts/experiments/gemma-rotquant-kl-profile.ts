// Milestone-2 diagnosis: per-step KL of each batched row vs its solo
// serial-quantized run on gemma 12B (rotating-quant twin). Where does
// divergence start — pre-join (adopted decode / compiled-B1), at the join
// (twin merge), or during twin decode?
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { maybeQuantizeKv } from "../../src/generate";
import { lastPositionLogits, argmaxLastPosition } from "../../src/model/gemma4";
import { BatchScheduler } from "../../src/serve/batch-scheduler";
import { SNAPSHOT } from "../../tests/paths";
import * as ops from "../../src/mlx/ops";
import { clearCache } from "../../src/mlx/ffi";
import type { MlxArray } from "../../src/mlx/array";

const config = await loadModelConfig(SNAPSHOT);
const weights = await Weights.open(SNAPSHOT);
const model = createModel(weights, config);
const STEPS = 16;
const JOIN_AT = Number(process.env.JOIN_AT ?? 6);

// CONFIG_FILTER=full|rot|all — bisect which layer kind's quant batching
// breaks: "full" = only full-attention layers configured (3.1 wrapper on
// gemma), "rot" = only sliding layers (the milestone-2 twin).
{
  const { RotatingKVCache } = await import("../../src/model/gemma4-base");
  const proto = model.makeCache();
  const kinds = proto.map((c) => (c instanceof RotatingKVCache ? "rot" : "full"));
  for (const c of proto) c.dispose();
  const f = process.env.CONFIG_FILTER ?? "all";
  if (f !== "all") {
    config.kvQuant = config.kvQuant!.filter((e) => kinds[e.layerIdx] === f);
    console.log(`CONFIG_FILTER=${f}: ${config.kvQuant.length} layers configured`);
  }
  // ROT_IDX=i: all full layers + ONLY rotating layer i.
  const ri = process.env.ROT_IDX;
  if (ri !== undefined) {
    config.kvQuant = config.kvQuant!.filter((e) =>
      kinds[e.layerIdx] === "full" || e.layerIdx === Number(ri));
    console.log(`ROT_IDX=${ri}: ${config.kvQuant.length} layers configured`);
  }
  // ROT_DROP=i: everything EXCEPT rotating layer i.
  const rd = process.env.ROT_DROP;
  if (rd !== undefined) {
    config.kvQuant = config.kvQuant!.filter((e) => e.layerIdx !== Number(rd));
    console.log(`ROT_DROP=${rd}: ${config.kvQuant.length} layers configured`);
  }
  // ROT_KEEP=N: all full layers + only the first N rotating layers.
  const rk = process.env.ROT_KEEP;
  if (rk !== undefined) {
    let kept = 0;
    config.kvQuant = config.kvQuant!.filter((e) =>
      kinds[e.layerIdx] === "full" ? true : ++kept <= Number(rk));
    console.log(`ROT_KEEP=${rk}: ${config.kvQuant.length} layers configured`);
  }
}

const promptA = [2, 100, 200, 300, 400, 500, 600, 700];
const promptB = [2, 150, 250, 350, 450];

const solo = (ids: number[]) => {
  const kvOpts = { kvConfig: config.kvQuant!, quantizedKvStart: 0 };
  const cache = model.makeCache();
  const toks: number[] = [];
  const logits: Float32Array[] = [];
  let l = model.forward(ids, cache);
  logits.push(lastPositionLogits(l));
  toks.push(argmaxLastPosition(l));
  l.dispose();
  maybeQuantizeKv(cache, kvOpts);
  for (let s = 1; s < STEPS; s++) {
    l = model.forward([toks[s - 1]!], cache);
    logits.push(lastPositionLogits(l));
    toks.push(argmaxLastPosition(l));
    l.dispose();
  }
  for (const c of cache) c.dispose();
  clearCache();
  return { toks, logits };
};
const refA = solo(promptA);
const refB = solo(promptB);

const klDiv = (x: Float32Array, y: Float32Array): number => {
  let mx = -Infinity, my = -Infinity;
  for (let i = 0; i < x.length; i++) { if (x[i]! > mx) mx = x[i]!; if (y[i]! > my) my = y[i]!; }
  let sx = 0, sy = 0;
  for (let i = 0; i < x.length; i++) { sx += Math.exp(x[i]! - mx); sy += Math.exp(y[i]! - my); }
  const lsx = Math.log(sx), lsy = Math.log(sy);
  let kl = 0;
  for (let i = 0; i < x.length; i++) {
    const lp = x[i]! - mx - lsx;
    const p = Math.exp(lp);
    if (p > 0) kl += p * (lp - (y[i]! - my - lsy));
  }
  return kl;
};

const sched = new BatchScheduler(model, { maxBatch: 2, kvConfig: config.kvQuant! });
const mk = (ids: number[], forced: number[], sink: Float32Array[]) => {
  let step = 0;
  return {
    promptIds: ids, maxTokens: STEPS, eosTokenIds: [], plainGreedy: false,
    sample: (lp: MlxArray) => {
      sink.push(lp.toFloat32());
      return ops.fromInt32([forced[step++]!], [1]);
    },
    onToken: () => true,
  };
};
const gotA: Float32Array[] = [];
const gotB: Float32Array[] = [];
const pa = sched.submit(mk(promptA, refA.toks, gotA));
while (gotA.length < JOIN_AT) await new Promise((r) => setTimeout(r, 2));
const pb = sched.submit(mk(promptB, refB.toks, gotB));
await Promise.all([pa, pb]);
clearCache();

console.log(`join pinned at A-step ${JOIN_AT}`);
for (const [got, ref, label] of [[gotA, refA.logits, "A"], [gotB, refB.logits, "B"]] as const) {
  const kls = got.map((g, s) => klDiv(ref[s]!, g));
  console.log(`row ${label}: KL by step: ${kls.map((k) => (k < 1e-6 ? "0" : k.toExponential(1))).join(" ")}`);
}
