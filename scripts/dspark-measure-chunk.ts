// Measure DSpark speedup on the chunk task. Compares dsparkGenerate vs vanilla
// e4b decode (both WITH the chunk adapter mounted — the drafter is adapter-
// specific) on real chunk prompts, reporting tokens/sec and the speedup ratio
// at temp 0 (greedy, also the losslessness gate) and temp>0 (sampling).
//
// CAVEAT (long-context trim wall): e4b's rotating KV cache stops being trimmable
// past ~4096 tokens, so spec rollback throws on long context. Chunk transcripts
// are huge, so we TRUNCATE the user transcript to keep total context < ~4096 for
// the measurement. This is a lower bound — full-context production chunking (once
// trimmable sliding caches exist) should accept at least as well. The in-
// distribution τ on FULL context is the held-out τ reported by dspark-train.
//
//   bun scripts/dspark-measure-chunk.ts --drafter <ckpt> \
//     --adapter ~/.cache/mlx-bun/adapters/memory-chunk \
//     --data ~/Code/lucien/benchmark/finetune/chunk-v3/dpo/orpo-curated-valid.fixed.jsonl

import { Gemma4Model } from "../src/model/gemma4";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import { AdapterManager } from "../src/lora";
import { ChatTemplate, type ChatMessage } from "../src/chat-template";
import { DSparkDrafter } from "../src/spec/dspark/module";
import { dsparkGenerate } from "../src/spec/dspark/generate";

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
const DRAFTER = arg("drafter");
const ADAPTER = arg("adapter", ""); // empty → base model (generation stages run on base e4b)
const DATA = arg("data");
const TRUNC_CHARS = parseInt(arg("trunc-chars", "200000"), 10); // ~no truncation; trimmable cache handles long ctx
const MAX_CTX = parseInt(arg("max-ctx", "8000"), 10);
const MAX_TOKENS = parseInt(arg("max-tokens", "96"), 10);
const N = parseInt(arg("n", "8"), 10);
const TEMP = parseFloat(arg("temp", "0.7"));

const host = (await Bun.$`scutil --get LocalHostName`.text().catch(() => "unknown")).trim();
const ram = Math.round(Number((await Bun.$`sysctl -n hw.memsize`.text()).trim()) / 1073741824);

const dir = new Registry().resolve(MODEL).path;
const config = await loadModelConfig(dir);
const model = createModel(await Weights.open(dir), config) as Gemma4Model;
const tok = await loadTokenizer(dir);
const template = await ChatTemplate.load(dir);
const eos = config.eosTokenIds;
if (ADAPTER) {
  const adapters = new AdapterManager(model);
  await adapters.mount("chunk", ADAPTER);
  model.loraState.active = ["chunk"];
}
const drafter = DSparkDrafter.load(DRAFTER);
console.log(`[measure-chunk] ${host} · ${ram}GB · ${MODEL} + chunk adapter · γ=${drafter.cfg.gamma} · maxTokens=${MAX_TOKENS}`);

interface Row { prompt: ChatMessage[]; chosen: string }
const rows = (await Bun.file(DATA).text()).split("\n").filter(Boolean).map((l) => JSON.parse(l) as Row);

function promptIdsFor(row: Row): number[] | null {
  const msgs: ChatMessage[] = row.prompt.map((m) =>
    m.role === "user" ? { role: "user", content: (m.content || "").slice(0, TRUNC_CHARS) } : m);
  const text = template.render(msgs, { addGenerationPrompt: true });
  let ids = tok.encode(text, true);
  if (ids.length >= 2 && ids[0] === ids[1] && ids[0] === tok.bosTokenId) ids = ids.slice(1);
  return ids.length <= MAX_CTX ? ids : null;
}
const firstDiff = (a: number[], b: number[]) => {
  const n = Math.min(a.length, b.length);
  for (let i = 0; i < n; i++) if (a[i] !== b[i]) return i;
  return a.length === b.length ? -1 : n;
};

/** Vanilla greedy DECODE-only tok/s (prefill excluded), to compare apples-to-
 *  apples with dspark's stats.decodeMs. Uses the production rotating cache. */
function vanillaDecodeTps(ids: number[]): number {
  const cache = model.makeCache();
  try {
    const pid = ops.fromInt32(ids, [1, ids.length]);
    const h = model.forwardHidden(pid, cache); // prefill (untimed)
    pid.dispose();
    const Lp = h.shape[1]!, H = h.shape[2]!;
    const lastSl = h.slice([0, Lp - 1, 0], [1, Lp, H]);
    h.dispose();
    let logits = model.logitsFromHidden(lastSl); lastSl.dispose();
    let next = pickArgmax(logits); logits.dispose();
    const t0 = performance.now();
    let n = 0;
    for (; n < MAX_TOKENS; n++) {
      if (eos.includes(next)) break;
      const tid = ops.fromInt32([next], [1, 1]);
      const hd = model.forwardHidden(tid, cache); tid.dispose();
      logits = model.logitsFromHidden(hd); hd.dispose();
      next = pickArgmax(logits); logits.dispose();
    }
    const dt = (performance.now() - t0) / 1000;
    return n / dt;
  } finally {
    for (const c of cache) c.dispose();
  }
}
function pickArgmax(logits: MlxArray): number {
  const V = logits.shape[2]!;
  const flat = ops.reshape(logits.slice([0, logits.shape[1]! - 1, 0], [1, logits.shape[1]!, V]), [1, V]);
  const am = ops.argmaxAxis(flat, -1); flat.dispose();
  const t = ops.itemUint32(am); am.dispose();
  return t;
}

let vTps = 0, dTpsG = 0, dTpsT = 0, tauG = 0, tauT = 0, gate = 0, used = 0;
for (let i = 0; i < rows.length && used < N; i++) {
  const ids = promptIdsFor(rows[i]!);
  if (!ids) continue;
  used++;

  // all three measured DECODE-ONLY (prefill excluded) for a fair comparison.
  const vtps = vanillaDecodeTps(ids);
  const ref = model.generate(ids, MAX_TOKENS, eos); // for the losslessness gate

  const dg = dsparkGenerate(model, drafter, ids, { maxTokens: MAX_TOKENS });
  const dtpsG = dg.tokens.length / (dg.stats.decodeMs / 1000);
  const div = firstDiff(ref, dg.tokens);
  if (div === -1) gate++;

  const dt = dsparkGenerate(model, drafter, ids, { maxTokens: MAX_TOKENS, sample: { temperature: TEMP, seed: i } });
  const dtpsT = dt.tokens.length / (dt.stats.decodeMs / 1000);

  vTps += vtps; dTpsG += dtpsG; dTpsT += dtpsT; tauG += dg.stats.meanAcceptLen; tauT += dt.stats.meanAcceptLen;
  console.log(`  [${used}] ctx=${ids.length}  vanilla=${vtps.toFixed(1)}  dspark₀=${dtpsG.toFixed(1)} (τ${dg.stats.meanAcceptLen.toFixed(2)} ${div===-1?"gate✓":"div@"+div})  dspark₀.₇=${dtpsT.toFixed(1)} (τ${dt.stats.meanAcceptLen.toFixed(2)})  tok/s [decode-only]`);
}

if (used === 0) { console.log("[measure-chunk] no prompts fit the context budget"); process.exit(1); }
const v = vTps / used, g = dTpsG / used, tt = dTpsT / used;
console.log(`\n[measure-chunk] ${host} · ${ram}GB — mean over ${used} chunk prompts (ctx<${MAX_CTX})`);
console.log(`  vanilla e4b:      ${v.toFixed(1)} tok/s`);
console.log(`  DSpark greedy:    ${g.toFixed(1)} tok/s  →  ${(g / v).toFixed(2)}× speedup   (τ=${(tauG / used).toFixed(2)}, gate ${gate}/${used})`);
console.log(`  DSpark temp=${TEMP}:   ${tt.toFixed(1)} tok/s  →  ${(tt / v).toFixed(2)}× speedup   (τ=${(tauT / used).toFixed(2)})`);
