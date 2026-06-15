// E1c (PLAN Phase 19): measure --expert-offload on the real 26B.
//   bun scripts/measure-offload.ts                         # offload OFF
//   MLX_BUN_EXPERT_OFFLOAD=/tmp/expert-offload bun ...     # offload ON
// Prints phys_footprint (vmmap), decode tok/s, and the generated token ids so
// two runs can be diffed for the bit-exact gate.

import { Registry } from "../src/registry";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { createModel } from "../src/model/factory";
import { generate } from "../src/generate";
import { ChatTemplate } from "../src/chat-template";
import { loadTokenizer } from "../src/tokenizer";
import { isExpertOffload } from "../src/expert-offload";

function footprintGB(): number {
  const out = Bun.spawnSync(["vmmap", "--summary", String(process.pid)]).stdout.toString();
  const m = out.match(/Physical footprint:\s+([\d.]+)([KMG])/);
  if (!m) return NaN;
  const v = parseFloat(m[1]!), u = m[2]!;
  return u === "G" ? v : u === "M" ? v / 1024 : v / 1024 / 1024;
}

const QUERY = process.argv[2] ?? "26B";
const reg = new Registry();
if (reg.list().length === 0) await reg.scan();
const path = reg.resolve(QUERY).path;
reg.close();

const config = await loadModelConfig(path);
const weights = await Weights.open(path);
const model = createModel(weights, config);
const tok = await loadTokenizer(path);
const template = await ChatTemplate.load(path);
const enc = (m: string) => {
  const ids = tok.encode(template.render([{ role: "user", content: m }]));
  return ids[0] === ids[1] && ids[0] === tok.bosTokenId ? ids.slice(1) : ids;
};

const prompt = enc("Explain how a hash map works, with a short example.");
// warmup: one full forward materializes/faults the per-layer weights
{ const w = generate(model, prompt.slice(0, Math.min(8, prompt.length - 1)), { maxTokens: 1, temperature: 0 }); for await (const _ of w) { /* */ } }
const fpLoad = footprintGB();

const g = generate(model, prompt, { maxTokens: 80, temperature: 0 });
const out: number[] = [];
for await (const t of g) out.push(t.token);
const s = g.stats!;
const fpGen = footprintGB();

console.log(`offload:        ${isExpertOffload()}`);
console.log(`phys_footprint: ${fpLoad.toFixed(2)} GB after load, ${fpGen.toFixed(2)} GB after gen`);
console.log(`decode:         ${s.decodeTps.toFixed(1)} tok/s (${s.generatedTokens} tok), prefill ${s.prefillTps.toFixed(1)} tok/s`);
console.log(`TOKENS: ${out.join(",")}`);
