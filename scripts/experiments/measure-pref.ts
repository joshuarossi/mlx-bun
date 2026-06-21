// Measure ORPO/DPO preference accuracy (fraction where chosen logp > rejected logp)
// + mean log-odds margin on a valid set, base vs a mounted adapter. The positive
// control for "does the preference actually get learned" (not just "loss drops").
//
//   bun scripts/experiments/measure-pref.ts <dataDir> [adapterDir]
//
// <dataDir>/valid.jsonl holds {prompt, chosen, rejected} rows.
import { readdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { loadTokenizer } from "../../src/tokenizer";
import { ChatTemplate } from "../../src/chat-template";
import { AdapterManager } from "../../src/lora";
import { loadDpoDataset } from "../../src/train/dataset";
import { orpoMetrics } from "../../src/train/loss";

const [dataDir, adapterDir] = process.argv.slice(2);
if (!dataDir) { console.error("usage: measure-pref.ts <dataDir> [adapterDir]"); process.exit(1); }

const hub = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots`;
const BASE = `${hub}/${readdirSync(hub)[0]}`;

const config = await loadModelConfig(BASE);
const weights = await Weights.open(BASE);
const model = createModel(weights, config);
const tok = await loadTokenizer(BASE);
const tmpl = await ChatTemplate.load(BASE);

const valid = await loadDpoDataset(`${dataDir}/valid.jsonl`, tok, tmpl, 256);

function measure(): { acc: number; margin: number } {
  let acc = 0, margin = 0;
  for (const ex of valid) {
    const b = {
      chosenIds: [ex.chosenIds], rejectedIds: [ex.rejectedIds],
      chosenMask: [ex.chosenMask], rejectedMask: [ex.rejectedMask],
    };
    const m = orpoMetrics(model, b as Parameters<typeof orpoMetrics>[1], 0.1);
    acc += m.accuracy; margin += m.margin;
  }
  return { acc: acc / valid.length, margin: margin / valid.length };
}

const base = measure();
console.log(`BASE    : pref-acc=${base.acc.toFixed(3)}  margin=${base.margin.toFixed(4)}  (n=${valid.length})`);

if (adapterDir) {
  const mgr = new AdapterManager(model);
  await mgr.mount("eval", adapterDir);
  const t = measure();
  console.log(`TRAINED : pref-acc=${t.acc.toFixed(3)}  margin=${t.margin.toFixed(4)}  (adapter=${adapterDir})`);
  console.log(`DELTA   : acc ${base.acc.toFixed(3)} -> ${t.acc.toFixed(3)}   margin ${base.margin.toFixed(4)} -> ${t.margin.toFixed(4)}`);
}
