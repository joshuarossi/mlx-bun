// DSpark chunk-task data regen — re-forward the chunk-segmenter examples through
// FROZEN e4b WITH the production chunk adapter mounted, and dump per-position
// hidden states for the RESPONSE region only (the JSON output we actually draft).
//
// The chunk drafter is adapter-specific by design (paper §3.3): the dumped
// hiddens must reflect base+adapter so the draft learns the served distribution.
// We tap the response region only (last prompt token + the JSON chunks) — every
// dumped position is a valid anchor, so the shard format/sampler are unchanged.
//
// GPU JOB.  Data = Lucien chunk-v3 ORPO (read-only oracle; we read `prompt` +
// `chosen` = the gold response):
//
//   bun scripts/dspark-regen-chunk.ts \
//     --data ~/Code/lucien/benchmark/finetune/chunk-v3/dpo/orpo-curated-train.fixed.jsonl \
//     --adapter ~/.cache/mlx-bun/adapters/memory-chunk \
//     --out ~/.cache/mlx-bun/dspark-chunk-data --max-seq 8192

import { Gemma4Model } from "../src/model/gemma4";
import { AdapterManager } from "../src/lora";
import { ChatTemplate, type ChatMessage } from "../src/chat-template";
import { writeDSparkShard, type DSparkRecord } from "../src/spec/dspark/data";
import * as ops from "../src/mlx/ops";
import { mkdirSync } from "node:fs";

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
const DATA = arg("data");
const ADAPTER = arg("adapter");
const OUT = arg("out");
const MAX_SEQ = parseInt(arg("max-seq", "8192"), 10);
const SEQS_PER_SHARD = parseInt(arg("seqs-per-shard", "64"), 10);
const GAMMA_MIN = parseInt(arg("gamma-min", "6"), 10); // response must hold ≥ this many tokens
// The drafter must learn what e4b+adapter ACTUALLY emits, so by default we
// GENERATE the response with the target (paper §3.3: "responses are regenerated
// by each target model"). Pass --use-gold to instead teacher-force the dataset's
// gold `chosen` (cheaper, but off-distribution → lower τ).
const USE_GOLD = process.argv.includes("--use-gold");
const MAX_RESP = parseInt(arg("max-resp", "320"), 10);

const dir = new Registry().resolve(MODEL).path;
const config = await loadModelConfig(dir);
const weights = await Weights.open(dir);
const model = createModel(weights, config) as Gemma4Model;
const tok = await loadTokenizer(dir);
const template = await ChatTemplate.load(dir);
const H = config.text.hiddenSize;
mkdirSync(OUT, { recursive: true });

// mount + activate the production chunk adapter so hiddens reflect base+adapter
const adapters = new AdapterManager(model);
const info = await adapters.mount("chunk", ADAPTER);
model.loraState.active = ["chunk"];
console.log(`[regen-chunk] adapter ${ADAPTER} mounted: ${info.mountedLayers} layers, rank ${info.rank}, scale ${info.scale}`);
console.log(`[regen-chunk] model H=${H}; reading ${DATA}`);

interface Row { prompt: ChatMessage[]; chosen: string; rejected?: string }
const lines = (await Bun.file(DATA).text()).split("\n").filter((l) => l.trim().length > 0);

let shardIdx = 0;
let records: DSparkRecord[] = [];
let kept = 0, skippedLong = 0, skippedShort = 0, totalRespTok = 0;

function flush(): void {
  if (records.length === 0) return;
  const meta = writeDSparkShard(OUT, shardIdx, records, H);
  console.log(`  shard ${shardIdx}: ${meta.nSeq} seqs, ${meta.nTokens} response tokens`);
  shardIdx++; records = [];
}

for (let li = 0; li < lines.length; li++) {
  let row: Row;
  try { row = JSON.parse(lines[li]!) as Row; } catch { continue; }
  if (!row.prompt || !row.chosen) continue;

  // render the prompt EXACTLY as served (system + user, with the assistant
  // generation header), then append the gold response.
  const promptText = template.render(row.prompt, { addGenerationPrompt: true });
  let promptIds = tok.encode(promptText, true);
  if (promptIds.length >= 2 && promptIds[0] === promptIds[1] && promptIds[0] === tok.bosTokenId)
    promptIds = promptIds.slice(1); // strip dup BOS (serving-path lesson)
  if (promptIds.length + GAMMA_MIN > MAX_SEQ) { skippedLong++; continue; }

  // ON-DISTRIBUTION response: what e4b+adapter actually generates (greedy),
  // not the dataset's gold — so the draft learns the served distribution.
  const respIds = USE_GOLD
    ? tok.encode(row.chosen, false)
    : model.generate(promptIds, Math.min(MAX_RESP, MAX_SEQ - promptIds.length), config.eosTokenIds);

  if (respIds.length < GAMMA_MIN) { skippedShort++; continue; }
  if (promptIds.length + respIds.length > MAX_SEQ) { skippedLong++; continue; }

  const fullIds = [...promptIds, ...respIds];
  const respStart = promptIds.length - 1; // last prompt token seeds the first draft block

  const cache = model.makeCache();
  try {
    const idArr = ops.fromInt32(fullIds, [1, fullIds.length]);
    const hidden = model.forwardHidden(idArr, cache); // [1,L,H]
    idArr.dispose();
    // slice the response region: [respStart .. L)
    const L = fullIds.length;
    const rh = hidden.slice([0, respStart, 0], [1, L, H]); // [1, respLen+1, H]
    hidden.dispose();
    const flat = ops.reshape(rh, [L - respStart, H]);
    rh.dispose();
    const hbf = flat.astype(model.embed.scales.dtype);
    flat.dispose();
    const cont = ops.contiguous(hbf);
    hbf.dispose();
    records.push({ ids: fullIds.slice(respStart), hiddenBf16: cont.rawBytes() });
    cont.dispose();
    kept++;
    totalRespTok += L - respStart;
  } finally {
    for (const c of cache) c.dispose();
  }

  if (records.length >= SEQS_PER_SHARD) flush();
  if ((li + 1) % 50 === 0) console.log(`  …${li + 1}/${lines.length} (kept ${kept}, skip long ${skippedLong} / short ${skippedShort})`);
}
flush();

console.log(`[regen-chunk] done: ${kept} examples, ${totalRespTok} response tokens, ${shardIdx} shards in ${OUT} (skipped ${skippedLong} too long, ${skippedShort} too short)`);
