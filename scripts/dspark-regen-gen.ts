// DSpark generation-stage regen — train data for a drafter on long-form e4b
// GENERATION (the article-writing regime), to test whether spec decoding works
// far better when the output is generated (prose momentum) rather than copied
// from the input (chunk's worst case).
//
// For each topic: prompt e4b (base, no adapter — the synthesis/editor stages run
// on base) to write a long article, GENERATE the response (that IS what the model
// does), then forward [prompt+generation] once to dump response-region hiddens.
// Resumable: a progress ledger of done topics survives interruption.
//
//   bun scripts/dspark-regen-gen.ts --topics <topics.txt> --out <dir> --max-resp 320

import { Gemma4Model } from "../src/model/gemma4";
import { ChatTemplate } from "../src/chat-template";
import { writeDSparkShard, type DSparkRecord } from "../src/spec/dspark/data";
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

const topics = readFileSync(TOPICS, "utf8").split("\n").map((t) => t.trim()).filter(Boolean);
console.log(`[regen-gen] ${topics.length} topics → ${OUT}`);

// resumability (same ledger pattern as the DB regen): only flushed topics are
// recorded, so a kill mid-buffer just redoes that batch.
const PROGRESS = join(OUT, "progress.txt");
const done = new Set(existsSync(PROGRESS) ? readFileSync(PROGRESS, "utf8").split("\n").filter(Boolean) : []);
let shardIdx = existsSync(OUT) ? readdirSync(OUT).filter((n) => n.startsWith("shard_")).length : 0;
if (done.size > 0) console.log(`[regen-gen] resuming: ${done.size} done, next shard ${shardIdx}`);

let records: DSparkRecord[] = [];
let pending: string[] = [];
let kept = done.size, totalTok = 0, skipShort = 0;
function flush() {
  if (!records.length) return;
  const meta = writeDSparkShard(OUT, shardIdx, records, H);
  console.log(`  shard ${shardIdx}: ${meta.nSeq} seqs, ${meta.nTokens} response tokens`);
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

  // GENERATE — what e4b actually produces (greedy, on-distribution for temp 0).
  const respIds = model.generate(promptIds, MAX_RESP, eos);
  if (respIds.length < GAMMA_MIN) { skipShort++; continue; }

  const fullIds = [...promptIds, ...respIds];
  const respStart = promptIds.length - 1;
  const cache = model.makeCache();
  try {
    const idArr = ops.fromInt32(fullIds, [1, fullIds.length]);
    const hidden = model.forwardHidden(idArr, cache);
    idArr.dispose();
    const L = fullIds.length;
    const rh = hidden.slice([0, respStart, 0], [1, L, H]); hidden.dispose();
    const flat = ops.reshape(rh, [L - respStart, H]); rh.dispose();
    const hbf = flat.astype(model.embed.scales.dtype); flat.dispose();
    const cont = ops.contiguous(hbf); hbf.dispose();
    records.push({ ids: fullIds.slice(respStart), hiddenBf16: cont.rawBytes() });
    pending.push(topic); cont.dispose();
    kept++; totalTok += L - respStart;
  } finally {
    for (const c of cache) c.dispose();
  }
  if (records.length >= SEQS_PER_SHARD) flush();
  if ((i + 1) % 20 === 0) console.log(`  …${i + 1}/${topics.length} (kept ${kept}, ${totalTok} tok)`);
}
flush();
console.log(`[regen-gen] done: ${kept} articles, ${totalTok} response tokens, ${shardIdx} shards in ${OUT} (skipped ${skipShort} short)`);
