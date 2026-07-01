// DSpark data regen — re-forward domain-matched documents through FROZEN e4b
// and dump per-position final hidden states (the tap) + token ids, sharded.
// This is the training target (paper §3.3 / §5.1): the draft learns to match
// e4b on e4b's own outputs. Pure reuse of the existing forward path.
//
// GPU JOB — Josh runs this, not an agent session. Reads a JSONL file of
// documents ({"text": "..."} per line; e.g. the ~3000 Opus-refined memory-job
// articles) and writes shards under --out.
//
//   bun scripts/dspark-regen.ts --docs path/to/docs.jsonl --out ~/.cache/mlx-bun/dspark-data \
//       --max-seq 1024 --seqs-per-shard 256
//
// Notes:
//  - Strips a duplicated leading BOS (the eval-reuse lesson) before forwarding.
//  - Truncates each doc to --max-seq tokens; documents shorter than γ+1 are
//    skipped (no valid anchor). Streams shard-by-shard; nothing is held beyond
//    the current shard's records.

import { Gemma4Model } from "../src/model/gemma4";
import { writeDSparkShard, type DSparkRecord } from "../src/spec/dspark/data";
import { mkdirSync } from "node:fs";
import * as ops from "../src/mlx/ops";

const { Registry } = await import("../src/registry");
const { loadModelConfig } = await import("../src/config");
const { Weights } = await import("../src/weights");
const { createModel } = await import("../src/model/factory");
const { loadTokenizer } = await import("../src/tokenizer");

function arg(name: string, def?: string): string {
  const i = process.argv.indexOf(`--${name}`);
  if (i >= 0 && i + 1 < process.argv.length) return process.argv[i + 1]!;
  if (def !== undefined) return def;
  throw new Error(`missing --${name}`);
}

const MODEL = arg("model", "gemma-4-e4b-it-OptiQ-4bit");
const DOCS = arg("docs");
const OUT = arg("out");
const MAX_SEQ = parseInt(arg("max-seq", "1024"), 10);
const SEQS_PER_SHARD = parseInt(arg("seqs-per-shard", "256"), 10);
const MIN_LEN = parseInt(arg("min-len", "16"), 10); // need at least a few anchors

const dir = new Registry().resolve(MODEL).path;
const config = await loadModelConfig(dir);
const weights = await Weights.open(dir);
const model = createModel(weights, config) as Gemma4Model;
const tok = await loadTokenizer(dir);
const H = config.text.hiddenSize;
mkdirSync(OUT, { recursive: true });

const file = Bun.file(DOCS);
const text = await file.text();
const lines = text.split("\n").filter((l) => l.trim().length > 0);
console.log(`[dspark-regen] ${lines.length} docs → ${OUT} (model ${MODEL}, H=${H}, maxSeq=${MAX_SEQ})`);

let shardIdx = 0;
let records: DSparkRecord[] = [];
let totalSeq = 0;
let totalTok = 0;

function flush(): void {
  if (records.length === 0) return;
  const meta = writeDSparkShard(OUT, shardIdx, records, H);
  console.log(`  shard ${shardIdx}: ${meta.nSeq} seqs, ${meta.nTokens} tokens`);
  shardIdx++;
  records = [];
}

for (let li = 0; li < lines.length; li++) {
  let doc: string;
  try {
    doc = (JSON.parse(lines[li]!) as { text?: string }).text ?? "";
  } catch {
    doc = lines[li]!; // tolerate raw-text lines
  }
  if (!doc) continue;

  let ids = tok.encode(doc, true); // with special tokens (BOS)
  // strip duplicated leading BOS if the tokenizer double-prefixed
  if (ids.length >= 2 && ids[0] === ids[1] && ids[0] === tok.bosTokenId) ids = ids.slice(1);
  if (ids.length > MAX_SEQ) ids = ids.slice(0, MAX_SEQ);
  if (ids.length < MIN_LEN) continue;

  // forward once; tap the final post-norm hidden [1, L, H]
  const cache = model.makeCache();
  try {
    const idArr = ops.fromInt32(ids, [1, ids.length]);
    const hidden = model.forwardHidden(idArr, cache); // [1,L,H]
    idArr.dispose();
    const hbf = hidden.astype(model.embed.scales.dtype); // ensure bf16
    hidden.dispose();
    const flat = ops.reshape(hbf, [ids.length, H]);
    hbf.dispose();
    const cont = ops.contiguous(flat);
    flat.dispose();
    const bytes = cont.rawBytes(); // bf16 row-major [L*H]
    cont.dispose();
    records.push({ ids, hiddenBf16: bytes });
    totalSeq++;
    totalTok += ids.length;
  } finally {
    for (const c of cache) c.dispose();
  }

  if (records.length >= SEQS_PER_SHARD) flush();
  if ((li + 1) % 50 === 0) console.log(`  …${li + 1}/${lines.length} docs (${totalSeq} kept, ${totalTok} tok)`);
}
flush();

console.log(`[dspark-regen] done: ${totalSeq} sequences, ${totalTok} tokens, ${shardIdx} shards in ${OUT}`);
