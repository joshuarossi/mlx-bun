// Train a preference/SFT run and log the FULL trajectory for plotting.
//
// Per-step train {loss, accuracy, margin} + per-eval val {loss, accuracy, margin}
// -> runs/<stem>.json and runs/<stem>.csv, written INCREMENTALLY (on every val eval)
// so a long run is plottable live and survives interruption.
//
// Uses the trainer's OWN metric path (loraState-aware forward) — the canonical
// "did the preference get learned" signal (the serving AdapterManager.mount path
// does NOT reflect into branchLogpMean).
//
//   bun scripts/experiments/pref-control.ts <sft|dpo|orpo> <dataDir> <stem> [iters] [lr]
//
// Env overrides: SEQ (maxSeqLen, def 256) · EVAL_EVERY (stepsPerEval, def 10) ·
//   RANK (def 8) · SCHED (constant|cosine, def constant) · LAMBDA (orpo, def 0.1) ·
//   ADAPTER_DIR (def /tmp/<stem>-adapter)
import { readdirSync, writeFileSync, mkdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { loadTokenizer } from "../../src/tokenizer";
import { ChatTemplate } from "../../src/chat-template";
import { trainLora, DEFAULT_TRAIN_CONFIG } from "../../src/train/trainer";

const [method, dataDir, stem, itersStr, lrStr] = process.argv.slice(2);
if (!method || !dataDir || !stem) {
  console.error("usage: pref-control.ts <sft|dpo|orpo> <dataDir> <stem> [iters] [lr]");
  process.exit(1);
}
const iters = Number(itersStr ?? "120");
const lr = Number(lrStr ?? "1e-3");
const seq = Number(process.env.SEQ ?? "256");
const evalEvery = Number(process.env.EVAL_EVERY ?? "10");
const rank = Number(process.env.RANK ?? "8");
const sched = (process.env.SCHED ?? "constant") as "constant" | "cosine";
const lambda = Number(process.env.LAMBDA ?? "0.1");
const adapterDir = process.env.ADAPTER_DIR ?? `/tmp/${stem}-adapter`;

const hub = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots`;
const BASE = `${hub}/${readdirSync(hub)[0]}`;

const config = await loadModelConfig(BASE);
const weights = await Weights.open(BASE);
const model = createModel(weights, config);
const tok = await loadTokenizer(BASE);
const tmpl = await ChatTemplate.load(BASE);

type Row = { step: number; loss: number; accuracy?: number; margin?: number };
const train: Row[] = [];
const val: Row[] = [];

const writeOut = () => {
  mkdirSync("runs", { recursive: true });
  writeFileSync(`runs/${stem}.json`, JSON.stringify({ method, dataDir, iters, lr, seq, lambda, sched, train, val }, null, 2));
  const csv = ["phase,step,loss,accuracy,margin",
    ...train.map((r) => `train,${r.step},${r.loss},${r.accuracy ?? ""},${r.margin ?? ""}`),
    ...val.map((r) => `val,${r.step},${r.loss},${r.accuracy ?? ""},${r.margin ?? ""}`)].join("\n");
  writeFileSync(`runs/${stem}.csv`, csv);
};

const emit = (e: Record<string, unknown>) => {
  if (e.type === "metric" && e.kind === "train") {
    const r = { step: e.step as number, loss: e.loss as number, accuracy: e.accuracy as number, margin: e.margin as number };
    train.push(r);
    console.log(`  step ${r.step}/${iters}: loss=${r.loss.toFixed(4)} acc=${(r.accuracy ?? 0).toFixed(2)} margin=${(r.margin ?? 0).toFixed(3)}`);
  }
  if (e.type === "metric" && e.kind === "val") {
    const r = { step: e.step as number, loss: e.loss as number, accuracy: e.accuracy as number, margin: e.margin as number };
    val.push(r);
    writeOut(); // incremental: long runs are plottable live + crash-safe
    console.log(`  [VAL ${r.step}] loss=${r.loss.toFixed(4)} acc=${(r.accuracy ?? 0).toFixed(3)} margin=${(r.margin ?? 0).toFixed(4)}  -> runs/${stem}.{json,csv}`);
  }
  if (e.type === "stage" && typeof e.message === "string") console.log(`  · ${e.message}`);
};

console.log(`### ${method} | data=${dataDir} | iters=${iters} lr=${lr} seq=${seq} rank=${rank} sched=${sched} lambda=${lambda}`);
console.log(`### adapter -> ${adapterDir} | logs -> runs/${stem}.{json,csv}`);
await trainLora(model, tok, tmpl, dataDir, {
  ...DEFAULT_TRAIN_CONFIG,
  method: method as "sft" | "dpo" | "orpo",
  rank, scale: 2.0, rankScaling: "constant", numLayers: -1,
  iters, learningRate: lr,
  orpoLambda: lambda, orpoLrSchedule: sched, dpoLrSchedule: sched,
  maxSeqLen: seq, stepsPerReport: 10, stepsPerEval: evalEvery, segmentSize: 0,
  saveCheckpoints: true, // keep a mountable checkpoint at every val eval + track best-margin
  adapterPath: adapterDir, baseModel: BASE,
} as Parameters<typeof trainLora>[4], emit as Parameters<typeof trainLora>[5]);

writeOut();
const firstVal = val[0], lastVal = val[val.length - 1];
console.log(`\n=== ${method} RESULT (val = held-out preference) ===`);
if (firstVal && lastVal) {
  console.log(`val acc   : ${firstVal.accuracy?.toFixed(3)} (step ${firstVal.step}) -> ${lastVal.accuracy?.toFixed(3)} (step ${lastVal.step})`);
  console.log(`val margin: ${firstVal.margin?.toFixed(4)} -> ${lastVal.margin?.toFixed(4)}`);
}
console.log(`logged ${train.length} train + ${val.length} val rows -> runs/${stem}.{json,csv}`);
