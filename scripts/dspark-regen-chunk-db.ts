// DSpark chunk data regen — from the ALREADY-DONE chunk run in the DB.
//
// The chunk stage already segmented ~893 conversations; the adapter's output is
// persisted as `chunks` rows (conv, start/end positions, label). We rebuild the
// EXACT prompt (reusing src/memory/chunk.ts) and reconstruct the adapter's
// output JSON from those rows (positions → message uuids), then forward ONCE
// through e4b + the chunk adapter to dump response-region hiddens. No
// re-generation, no ORPO gold — this trains on what the adapter ACTUALLY did.
//
// Raw generations are not stored anywhere (verified), so reconstruction is the
// cheapest faithful source. `--audit N` first generates N convs LIVE and prints
// them next to the reconstruction so the serializer format can be confirmed.
//
//   bun scripts/dspark-regen-chunk-db.ts --adapter ~/.cache/mlx-bun/adapters/memory-chunk \
//     --out ~/.cache/mlx-bun/dspark-chunk-db --audit 2

import { Gemma4Model } from "../src/model/gemma4";
import { AdapterManager } from "../src/lora";
import { ChatTemplate } from "../src/chat-template";
import { CHUNK_SYSTEM, CHUNK_PROMPT, chunkInput, formatConversation } from "../src/memory/chunk";
import { loadMetaPolicy } from "../src/memory/prompts";
import { memoryPromptIds } from "../src/memory/model";
import { writeDSparkShard, type DSparkRecord } from "../src/spec/dspark/data";
import * as ops from "../src/mlx/ops";
import { Database } from "bun:sqlite";
import { mkdirSync, existsSync, readdirSync, readFileSync, writeFileSync, appendFileSync } from "node:fs";
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
const ADAPTER = arg("adapter");
const OUT = arg("out");
const DB = arg("db", `${process.env.HOME}/.cache/mlx-bun/memory.sqlite`);
const WIKI = arg("wiki", `${process.env.HOME}/.mlx-bun/wiki`); // vault for Meta policy
const MAX_SEQ = parseInt(arg("max-seq", "8192"), 10);
const SEQS_PER_SHARD = parseInt(arg("seqs-per-shard", "64"), 10);
const GAMMA_MIN = parseInt(arg("gamma-min", "6"), 10);
const LIMIT = parseInt(arg("limit", "100000"), 10);
const AUDIT = parseInt(arg("audit", "0"), 10);
process.env.MLX_BUN_WIKI = WIKI; // loadMetaPolicy reads <vault>/Meta/*

const dir = new Registry().resolve(MODEL).path;
const config = await loadModelConfig(dir);
const model = createModel(await Weights.open(dir), config) as Gemma4Model;
const tok = await loadTokenizer(dir);
const template = await ChatTemplate.load(dir);
const H = config.text.hiddenSize;
const eos = config.eosTokenIds;
mkdirSync(OUT, { recursive: true });

const adapters = new AdapterManager(model);
const info = await adapters.mount("chunk", ADAPTER);
model.loraState.active = ["chunk"];
console.log(`[regen-db] adapter mounted (${info.mountedLayers} layers); wiki=${WIKI}`);

// EXACT prompt head used by the run (CHUNK_PROMPT with Meta policy inlined).
const promptHead = CHUNK_PROMPT.replace("{{META_DOCS}}", loadMetaPolicy(["Chunking", "Topics_to_Ignore"]));

const db = new Database(DB, { readonly: true });
interface MsgRow { position: number; role: string; uuid: string; text: string }
const msgQuery = db.query("SELECT position, role, uuid, text FROM messages WHERE conv = ? ORDER BY position");
const chunkQuery = db.query(
  `SELECT ms.uuid AS s, me.uuid AS e, ch.label AS label
   FROM chunks ch
   JOIN messages ms ON ms.conv = ch.conv AND ms.position = ch.start
   JOIN messages me ON me.conv = ch.conv AND me.position = ch.end
   WHERE ch.conv = ? ORDER BY ch.start ASC`,
);
const convs = db.query(
  "SELECT conv, title FROM conversations WHERE conv IN (SELECT DISTINCT conv FROM chunks) ORDER BY conv",
).all() as { conv: string; title: string | null }[];
console.log(`[regen-db] ${convs.length} chunked conversations in ${DB}`);

/** Reconstruct the adapter's emitted JSON from the stored chunk rows. Compact,
 *  key order start/end/label — matching the adapter's output schema. */
function reconstructOutput(conv: string): string {
  const rows = chunkQuery.all(conv) as { s: string; e: string; label: string }[];
  const chunks = rows.map((r) => ({ start_message_uuid: r.s, end_message_uuid: r.e, label: r.label }));
  return JSON.stringify({ chunks });
}
function buildPromptIds(conv: string, title: string | null): number[] {
  const all = msgQuery.all(conv) as MsgRow[];
  const nonEmpty = all.filter((m) => m.text && m.text.trim());
  const prompt = promptHead + formatConversation(title ?? "", conv, nonEmpty);
  return memoryPromptIds("chunk", chunkInput(prompt), tok, template);
}

// --- serializer fidelity audit: generate LIVE and diff vs reconstruction ---
for (let a = 0; a < AUDIT && a < convs.length; a++) {
  const { conv, title } = convs[a]!;
  const pid = buildPromptIds(conv, title);
  const live = tok.decode(model.generate(pid, 512, eos), true).trim();
  const recon = reconstructOutput(conv);
  console.log(`\n[audit ${a}] conv=${conv} promptTok=${pid.length}`);
  console.log(`  LIVE  : ${live.slice(0, 240)}`);
  console.log(`  RECON : ${recon.slice(0, 240)}`);
  console.log(`  exact-match=${live === recon}  len(live)=${live.length} len(recon)=${recon.length}`);
}
if (AUDIT > 0 && !process.argv.includes("--proceed")) {
  console.log(`\n[regen-db] audit only — re-run with --proceed to dump shards.`);
  process.exit(0);
}

// --- resumability: a shard is only "done" once flushed to disk, so the
// progress ledger only ever names convs whose records are durably written —
// a kill mid-buffer just redoes that batch, never silently drops it. Skip
// reasons (too long/short) are cheap to recompute, so only KEPT convs are
// tracked. ---
const PROGRESS_FILE = join(OUT, "progress.txt");
const done = new Set(existsSync(PROGRESS_FILE) ? readFileSync(PROGRESS_FILE, "utf8").split("\n").filter(Boolean) : []);
let shardIdx = existsSync(OUT) ? readdirSync(OUT).filter((n) => n.startsWith("shard_")).length : 0;
if (done.size > 0) console.log(`[regen-db] resuming: ${done.size} convs already done, next shard ${shardIdx}`);

// --- main: reconstruct + forward once + dump response region ---
let records: DSparkRecord[] = [];
let pendingConvs: string[] = [];
let kept = done.size, skipShort = 0, skipLong = 0, totalTok = 0;
function flush() {
  if (!records.length) return;
  const meta = writeDSparkShard(OUT, shardIdx, records, H);
  console.log(`  shard ${shardIdx}: ${meta.nSeq} seqs, ${meta.nTokens} response tokens`);
  shardIdx++;
  appendFileSync(PROGRESS_FILE, pendingConvs.map((c) => c + "\n").join(""));
  records = []; pendingConvs = [];
}

for (let i = 0; i < convs.length && kept < LIMIT; i++) {
  const { conv, title } = convs[i]!;
  if (done.has(conv)) continue;
  const promptIds = buildPromptIds(conv, title);
  const respIds = tok.encode(reconstructOutput(conv), false);
  if (respIds.length < GAMMA_MIN) { skipShort++; continue; }
  if (promptIds.length + respIds.length > MAX_SEQ) { skipLong++; continue; }

  const fullIds = [...promptIds, ...respIds];
  const respStart = promptIds.length - 1;
  const cache = model.makeCache();
  try {
    const idArr = ops.fromInt32(fullIds, [1, fullIds.length]);
    const hidden = model.forwardHidden(idArr, cache);
    idArr.dispose();
    const L = fullIds.length;
    const rh = hidden.slice([0, respStart, 0], [1, L, H]);
    hidden.dispose();
    const flat = ops.reshape(rh, [L - respStart, H]); rh.dispose();
    const hbf = flat.astype(model.embed.scales.dtype); flat.dispose();
    const cont = ops.contiguous(hbf); hbf.dispose();
    records.push({ ids: fullIds.slice(respStart), hiddenBf16: cont.rawBytes() });
    pendingConvs.push(conv);
    cont.dispose();
    kept++; totalTok += L - respStart;
  } finally {
    for (const c of cache) c.dispose();
  }
  if (records.length >= SEQS_PER_SHARD) flush();
  if ((i + 1) % 50 === 0) console.log(`  …${i + 1}/${convs.length} (kept ${kept}, skip long ${skipLong}/short ${skipShort})`);
}
flush();
console.log(`[regen-db] done: ${kept} convs, ${totalTok} response tokens, ${shardIdx} shards in ${OUT} (skipped ${skipLong} long / ${skipShort} short)`);
