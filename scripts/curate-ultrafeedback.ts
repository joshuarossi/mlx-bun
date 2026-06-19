// Curate UltraFeedback (binarized) into an mlx-bun preference dataset for ORPO.
//
//   bun scripts/curate-ultrafeedback.ts <input.jsonl> <out-dir> [maxTokens] [valFrac]
//
// <input.jsonl> = HuggingFaceH4/ultrafeedback_binarized exported to JSONL (one
// row per line, binarized schema: prompt + chosen[] + rejected[]). Obtain it
// with the `datasets` library or `hf download` + a parquet→jsonl convert — kept
// out of this script so it triggers no surprise multi-GB download. Writes
// <out-dir>/train.jsonl (+ valid.jsonl) in {prompt, chosen, rejected} form,
// length-filtered, ready for `method: "orpo"`.

import { mkdirSync, writeFileSync, existsSync } from "node:fs";
import { curate } from "../src/eval/ultrafeedback";

const [input, outDir, maxTokStr, valFracStr] = process.argv.slice(2);
if (!input || !outDir) {
  console.error("usage: bun scripts/curate-ultrafeedback.ts <input.jsonl> <out-dir> [maxTokens=2048] [valFrac=0.02]");
  process.exit(1);
}
if (!existsSync(input)) { console.error(`input not found: ${input}`); process.exit(1); }
const maxTokens = Number(maxTokStr ?? 2048);
const valFrac = Number(valFracStr ?? 0.02);

const text = await Bun.file(input).text();
const rows: Record<string, unknown>[] = [];
for (const line of text.split("\n")) {
  const t = line.trim();
  if (t) { try { rows.push(JSON.parse(t)); } catch { /* skip malformed */ } }
}
console.log(`read ${rows.length} rows from ${input}`);

const prefs = curate(rows, maxTokens);
console.log(`curated ${prefs.length} usable preference pairs (≤${maxTokens} approx tokens)`);

const nVal = Math.min(Math.max(1, Math.floor(prefs.length * valFrac)), Math.max(0, prefs.length - 1));
const valid = prefs.slice(0, nVal);
const train = prefs.slice(nVal);

mkdirSync(outDir, { recursive: true });
writeFileSync(`${outDir}/train.jsonl`, train.map((r) => JSON.stringify(r)).join("\n") + "\n");
if (valid.length) writeFileSync(`${outDir}/valid.jsonl`, valid.map((r) => JSON.stringify(r)).join("\n") + "\n");
console.log(`wrote ${train.length} train + ${valid.length} valid to ${outDir}/`);
