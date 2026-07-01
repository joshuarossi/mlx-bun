// Faithful DFlash regen (generation stage) — dump the target's MULTI-LAYER
// hiddens over the FULL sequence so the draft can attend to the whole prefix
// context (paper Eq 2). Uses model.hiddenTap to capture the m tapped layers.
//
//   bun scripts/dspark-regen-dflash.ts --topics <topics.txt> --out <dir> --max-resp 320

import { Gemma4Model } from "../src/model/gemma4";
import { MlxArray } from "../src/mlx/array";
import { ChatTemplate } from "../src/chat-template";
import { DEFAULT_DFLASH_CONFIG } from "../src/spec/dspark/module-dflash";
import { writeDflashShard, type DflashRecord } from "../src/spec/dspark/data-dflash";
import * as ops from "../src/mlx/ops";
import { mkdirSync, existsSync, readdirSync, readFileSync, appendFileSync } from "node:fs";
import { join } from "node:path";

const { Registry } = await import("../src/registry");
const { loadModelConfig } = await import("../src/config");
const { Weights } = await import("../src/weights");
const { createModel } = await import("../src/model/factory");
const { loadTokenizer } = await import("../src/tokenizer");

const arg = (n: string, d?: string) => {
  const i = process.argv.indexOf(`--${n}`);
  if (i >= 0 && i + 1 < process.argv.length) return process.argv[i + 1]!;
  if (d !== undefined) return d;
  throw new Error(`missing --${n}`);
};
const MODEL = arg("model", "gemma-4-e4b-it-OptiQ-4bit");
const TOPICS = arg("topics");
const OUT = arg("out");
const MAX_RESP = parseInt(arg("max-resp", "320"), 10);
const SEQS_PER_SHARD = parseInt(arg("seqs-per-shard", "32"), 10);
const GAMMA_MIN = parseInt(arg("gamma-min", "6"), 10);

const dir = new Registry().resolve(MODEL).path;
const config = await loadModelConfig(dir);
const model = createModel(await Weights.open(dir), config) as Gemma4Model;
const tok = await loadTokenizer(dir);
const template = await ChatTemplate.load(dir);
const H = config.text.hiddenSize;
const eos = config.eosTokenIds;
mkdirSync(OUT, { recursive: true });

// tap layers: default [20,31,41,42]; 42 = post-finalNorm sentinel (= layers.length).
const tapLayers = DEFAULT_DFLASH_CONFIG.tapLayers;
const m = tapLayers.length;
console.log(`[regen-dflash] tapLayers=${tapLayers} (m=${m}); layers.length=${model.layers.length}; H=${H}`);

const topics = readFileSync(TOPICS, "utf8").split("\n").map((t) => t.trim()).filter(Boolean);
const PROGRESS = join(OUT, "progress.txt");
const done = new Set(existsSync(PROGRESS) ? readFileSync(PROGRESS, "utf8").split("\n").filter(Boolean) : []);
let shardIdx = existsSync(OUT) ? readdirSync(OUT).filter((n) => n.startsWith("shard_")).length : 0;
if (done.size > 0) console.log(`[regen-dflash] resuming: ${done.size} done, next shard ${shardIdx}`);

let records: DflashRecord[] = [];
let pending: string[] = [];
let kept = done.size, totalTok = 0, skipShort = 0;
function flush() {
  if (!records.length) return;
  const meta = writeDflashShard(OUT, shardIdx, records, H, m, tapLayers);
  console.log(`  shard ${shardIdx}: ${meta.nSeq} seqs, ${meta.nTokens} tokens`);
  shardIdx++;
  appendFileSync(PROGRESS, pending.map((t) => t + "\n").join(""));
  records = []; pending = [];
}

for (let i = 0; i < topics.length; i++) {
  const topic = topics[i]!;
  if (done.has(topic)) continue;
  const text = template.render(
    [{ role: "user", content: `Write a detailed, thorough encyclopedia article about ${topic}. Be specific and informative.` }],
    { addGenerationPrompt: true },
  );
  let promptIds = tok.encode(text, true);
  if (promptIds.length >= 2 && promptIds[0] === promptIds[1] && promptIds[0] === tok.bosTokenId) promptIds = promptIds.slice(1);
  const respIds = model.generate(promptIds, MAX_RESP, eos);
  if (respIds.length < GAMMA_MIN) { skipShort++; continue; }
  const fullIds = [...promptIds, ...respIds];
  const respStart = promptIds.length - 1; // last prompt token seeds the first draft block

  // tap the m layers over the FULL sequence in one forward.
  model.hiddenTap = { layers: new Set(tapLayers), captured: new Map() };
  const cache = model.makeCache();
  try {
    const idArr = ops.fromInt32(fullIds, [1, fullIds.length]);
    const finalH = model.forwardHidden(idArr, cache); // captures fire during this
    idArr.dispose(); finalH.dispose();
    const captured = model.hiddenTap.captured;
    const L = fullIds.length;
    // assemble [L, m*H] by concatenating the m tapped layers on the feature axis.
    const perLayer: MlxArray[] = [];
    for (const li of tapLayers) {
      const cap = captured.get(li);
      if (!cap) throw new Error(`layer ${li} not captured`);
      perLayer.push(ops.reshape(cap, [L, H]));
    }
    const cat = ops.concatAxis(perLayer, 1); // [L, m*H]
    for (const p of perLayer) p.dispose();
    for (const [, cap] of captured) cap.dispose();
    const cont = ops.contiguous(cat); cat.dispose();
    records.push({ ids: fullIds, respStart, hiddenMlBf16: cont.rawBytes() });
    pending.push(topic); cont.dispose();
    kept++; totalTok += L;
  } finally {
    model.hiddenTap = null;
    for (const c of cache) c.dispose();
  }
  if (records.length >= SEQS_PER_SHARD) flush();
  if ((i + 1) % 20 === 0) console.log(`  …${i + 1}/${topics.length} (kept ${kept}, ${totalTok} tok)`);
}
flush();
console.log(`[regen-dflash] done: ${kept} articles, ${totalTok} tokens, ${shardIdx} shards in ${OUT} (skipped ${skipShort} short)`);
