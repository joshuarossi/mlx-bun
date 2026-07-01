// Measure faithful DFlash speedup vs vanilla e4b (decode-only tok/s) on
// generation prompts. Base model (no adapter). Greedy = losslessness gate.
//
//   bun scripts/dspark-measure-dflash.ts --drafter <ckpt> --data <prompts.jsonl>

import { Gemma4Model } from "../src/model/gemma4";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import { ChatTemplate, type ChatMessage } from "../src/chat-template";
import { DflashDrafter } from "../src/spec/dspark/module-dflash";
import { dflashGenerate } from "../src/spec/dspark/generate-dflash";

const { Registry } = await import("../src/registry");
const { loadModelConfig } = await import("../src/config");
const { Weights } = await import("../src/weights");
const { createModel } = await import("../src/model/factory");
const { loadTokenizer } = await import("../src/tokenizer");

const arg = (n: string, d?: string) => { const i = process.argv.indexOf(`--${n}`); if (i >= 0 && i + 1 < process.argv.length) return process.argv[i + 1]!; if (d !== undefined) return d; throw new Error(`missing --${n}`); };
const MODEL = arg("model", "gemma-4-e4b-it-OptiQ-4bit");
const DRAFTER = arg("drafter");
const DATA = arg("data");
const MAX_TOKENS = parseInt(arg("max-tokens", "128"), 10);
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
const drafter = DflashDrafter.load(DRAFTER);
console.log(`[measure-dflash] ${host} · ${ram}GB · ${MODEL} · γ=${drafter.cfg.gamma} tapLayers=${drafter.cfg.tapLayers} layers=${drafter.cfg.nLayers}`);

interface Row { prompt: ChatMessage[] }
const rows = (await Bun.file(DATA).text()).split("\n").filter(Boolean).map((l) => JSON.parse(l) as Row);
const enc = (row: Row) => { const t = template.render(row.prompt, { addGenerationPrompt: true }); let ids = tok.encode(t, true); if (ids.length >= 2 && ids[0] === ids[1] && ids[0] === tok.bosTokenId) ids = ids.slice(1); return ids; };
const firstDiff = (a: number[], b: number[]) => { const n = Math.min(a.length, b.length); for (let i = 0; i < n; i++) if (a[i] !== b[i]) return i; return a.length === b.length ? -1 : n; };

function pickArgmax(logits: MlxArray): number {
  const V = logits.shape[2]!;
  const flat = ops.reshape(logits.slice([0, logits.shape[1]! - 1, 0], [1, logits.shape[1]!, V]), [1, V]);
  const am = ops.argmaxAxis(flat, -1); flat.dispose(); const t = ops.itemUint32(am); am.dispose(); return t;
}
function vanillaDecodeTps(ids: number[]): number {
  const cache = model.makeCache();
  try {
    const pid = ops.fromInt32(ids, [1, ids.length]);
    const h = model.forwardHidden(pid, cache); pid.dispose();
    const Lp = h.shape[1]!, H = h.shape[2]!;
    const last = h.slice([0, Lp - 1, 0], [1, Lp, H]); h.dispose();
    let logits = model.logitsFromHidden(last); last.dispose();
    let next = pickArgmax(logits); logits.dispose();
    const t0 = performance.now(); let n = 0;
    for (; n < MAX_TOKENS; n++) { if (eos.includes(next)) break; const tid = ops.fromInt32([next], [1, 1]); const hd = model.forwardHidden(tid, cache); tid.dispose(); logits = model.logitsFromHidden(hd); hd.dispose(); next = pickArgmax(logits); logits.dispose(); }
    return n / ((performance.now() - t0) / 1000);
  } finally { for (const c of cache) c.dispose(); }
}

let vT = 0, dG = 0, dT = 0, tauG = 0, tauT = 0, gate = 0, used = 0;
for (let i = 0; i < rows.length && used < N; i++) {
  const ids = enc(rows[i]!); used++;
  const vtps = vanillaDecodeTps(ids);
  const ref = model.generate(ids, MAX_TOKENS, eos);
  const dg = dflashGenerate(model, drafter, ids, { maxTokens: MAX_TOKENS });
  const dgTps = dg.tokens.length / (dg.stats.decodeMs / 1000);
  const div = firstDiff(ref, dg.tokens); if (div === -1) gate++;
  const dt = dflashGenerate(model, drafter, ids, { maxTokens: MAX_TOKENS, sample: { temperature: TEMP, seed: i } });
  const dtTps = dt.tokens.length / (dt.stats.decodeMs / 1000);
  vT += vtps; dG += dgTps; dT += dtTps; tauG += dg.stats.meanAcceptLen; tauT += dt.stats.meanAcceptLen;
  console.log(`  [${used}] ctx=${ids.length}  vanilla=${vtps.toFixed(1)}  dflash₀=${dgTps.toFixed(1)} (τ${dg.stats.meanAcceptLen.toFixed(2)} ${div === -1 ? "gate✓" : "div@" + div})  dflash₀.₇=${dtTps.toFixed(1)} (τ${dt.stats.meanAcceptLen.toFixed(2)})`);
}
const v = vT / used, g = dG / used, tt = dT / used;
console.log(`\n[measure-dflash] ${host} · ${ram}GB — mean over ${used} prompts`);
console.log(`  vanilla e4b:     ${v.toFixed(1)} tok/s`);
console.log(`  DFlash greedy:   ${g.toFixed(1)} tok/s  →  ${(g / v).toFixed(2)}×  (τ=${(tauG / used).toFixed(2)}, gate ${gate}/${used})`);
console.log(`  DFlash temp=${TEMP}:  ${tt.toFixed(1)} tok/s  →  ${(tt / v).toFixed(2)}×  (τ=${(tauT / used).toFixed(2)})`);
