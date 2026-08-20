// The winner's speed row for the release card: prefill tok/s, TTFT, and
// decode-at-depth through OUR engine at several prompt lengths. Same honesty
// rules as tq-tps.ts (wall-clock decode after first token; median of R reps;
// quiet-box doctrine — the caller labels host/chip/RAM and machine state;
// note cold-start vs steady-state thermals: sustained load derates the GPU
// clock ~10%, so record which regime the run was in).
//
// The MTP/speculative arm is NOT here — measure it with the existing
// specServeRun harness (scripts/experiments/qwen38-mtp-ab.ts) back-to-back
// in the same sitting.
//
//   bun scripts/experiments/tq-speed-row.ts <model-dir> [lens=1024,8192,32768] [gen=128] [reps=3] [kv=plain|kv8|turbo|turbo:kXvY]
//
// kv: the KV scheme for the run — "plain" (bf16, default), "kv8" (uniform
// 8-bit affine, L1), or a turbo scheme. On 24 GB boxes the 17 GB artifact's
// 32k row NEEDS quantized KV (bf16 KV + weights exceed the wired ceiling —
// M4 2026-08-20 async-OOM); label rows with the scheme.

import { loadModelConfig, parseTurboQuantScheme } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { loadTokenizer } from "../../src/tokenizer";
import { ChatTemplate } from "../../src/chat-template";
import { generate } from "../../src/generate";

const dir = process.argv[2]!;
const lens = (process.argv[3] ?? "1024,8192,32768").split(",").map(Number);
const gen = Number(process.argv[4] ?? 128);
const reps = Number(process.argv[5] ?? 3);
const kvArg = process.argv[6] ?? "plain";
const kvOpts =
  kvArg === "plain" ? {}
  : kvArg === "kv8" ? { kvBits: 8, quantizedKvStart: 0 }
  : { turboQuant: parseTurboQuantScheme(kvArg) ?? (() => { throw new Error(`bad kv arg: ${kvArg}`); })(), quantizedKvStart: 0 };

const config = await loadModelConfig(dir);
const weights = await Weights.open(dir);
const model = createModel(weights, config);
const tok = await loadTokenizer(dir);
const template = await ChatTemplate.load(dir);

// Long-prompt builder: repeat a paragraph inside ONE user turn, then trim the
// ENCODED ids to the target length while keeping the generation-prompt tail
// intact (the template suffix must stay adjacent to the generation point).
const PARA =
  "The tidal cycle is driven by the combined gravitational pull of the moon " +
  "and the sun acting on the ocean, modulated by coastline geometry, basin " +
  "resonance, and the rotation of the earth through the Coriolis effect. ";
function promptOfLength(target: number): number[] {
  const full = template.render(
    [{ role: "user", content: PARA.repeat(Math.ceil((target * 8) / PARA.length)) }],
    { addGenerationPrompt: true, enableThinking: false },
  );
  const ids = tok.encode(full);
  if (ids.length <= target) return ids;
  // trim from the MIDDLE of the body so the template head and the
  // generation-prompt tail stay untouched
  const cut = ids.length - target;
  const mid = Math.floor(ids.length / 2);
  return [...ids.slice(0, mid - Math.ceil(cut / 2)), ...ids.slice(mid + Math.floor(cut / 2))];
}

const med = (a: number[]) => [...a].sort((x, y) => x - y)[Math.floor(a.length / 2)]!;
const spread = (a: number[]) => a.length > 1 ? ((Math.max(...a) - Math.min(...a)) / med(a) * 100).toFixed(1) : "0.0";

console.log(`speed-row ${dir}\n  kv ${kvArg} · gen ${gen} tok · ${reps} reps · ${new Date().toISOString()}`);
console.log("| prompt tok | prefill tok/s | TTFT ms | decode tok/s (spread) |");
console.log("|---|---|---|---|");
for (const target of lens) {
  const ids = promptOfLength(target);
  const ttft: number[] = [];
  const dec: number[] = [];
  for (let r = 0; r < reps; r++) {
    const t0 = performance.now();
    let first = 0;
    let n = 0;
    for await (const t of generate(model, ids, { maxTokens: gen, temperature: 0, ...kvOpts, ...(process.env.MLX_BUN_SPEEDROW_CHUNK ? { prefillChunkSize: Number(process.env.MLX_BUN_SPEEDROW_CHUNK) } : {}) })) {
      if (n === 0) first = performance.now();
      n++;
    }
    const end = performance.now();
    ttft.push(first - t0);
    dec.push(((n - 1) / Math.max(end - first, 1e-6)) * 1000);
  }
  const tf = med(ttft);
  console.log(
    `| ${ids.length} | ${(ids.length / tf * 1000).toFixed(0)} | ${tf.toFixed(0)} | ` +
    `${med(dec).toFixed(2)} (${spread(dec)}%) |`,
  );
}
