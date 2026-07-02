// The measurement that REFUTED kernel-review backlog #4 (2026-07-02): passing
// FULL-CAPACITY KV buffers + an activeN bound to the fused decode kernel
// (instead of the step-padded fetch views under ensureRowContiguous) measured
// SLOWER end-to-end, not 1-3% faster — the variant was built, gated
// byte-identical, then REVERTED (this probe's MLX_BUN_FUSED_ACTIVEN lever no
// longer exists; re-apply the variant to reproduce):
//   variant = (a) fused-decode-kernel.ts: `an` int32[1] input, N=an[0],
//   rowOff strided by kp_shape[2]; (b) QuantizedKVCache fetch attaches
//   {full: buffers, activeN: offset}; (c) fusedDecodeSdpa prefers them.
//
// Interleaved in-process arms (flag read per fetch), 12B uniform kv4,
// MLX_BUN_PERF_KERNEL=1, greedy tokens IDENTICAL across arms, M1 Max:
//   @8k  (3 pairs): activeN 24.64 vs views 26.18 tok/s  (0.941)
//   @22k (2 pairs): activeN 23.07 vs views 23.83 tok/s  (0.968)
// Also: the 12B's recorded full-attn dispatch shape is KV=1 (H16 D512) —
// a [1,1,offset,D'] fetch view is a CONTIGUOUS PREFIX, so the "six copies
// per layer per step" cost model didn't hold on the shape that matters;
// micro-A/Bs of the kernel alone were unstable (±50% run-to-run) and are
// not evidence either way.
//
//   CTX=7800 bun scripts/experiments/fused-decode-activen-ab.ts
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { Gemma4Model } from "../../src/model/gemma4";
import { generate } from "../../src/generate";
import { loadTokenizer } from "../../src/tokenizer";
import { ChatTemplate } from "../../src/chat-template";

process.env.MLX_BUN_PERF_KERNEL = "1"; // the kernel under test
process.env.MLX_BUN_COMPILED_DECODE = "0"; // perf kernel never lives in traces anyway; keep arms simple

const SNAP = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-12B-it-OptiQ-4bit/snapshots/5b1101065d2094c8f12aa87fee80e0afa5b292b7`;
const config = await loadModelConfig(SNAP);
const weights = await Weights.open(SNAP);
const model = new Gemma4Model(weights, config);
const tok = await loadTokenizer(SNAP);
const template = await ChatTemplate.load(SNAP);

const CTXTARGET = Number(process.env.CTX ?? 7800);
const filler = "Background context: relays, tubes, transistors, integrated circuits, accelerators. ";
const per = tok.encode(filler).length;
const msg = filler.repeat(Math.ceil(CTXTARGET / per)).slice(0, undefined) + "Write a detailed essay about the history of computing.";
const ids = tok.encode(template.render([{ role: "user", content: msg }]));
const promptIds = ids[0] === ids[1] && ids[0] === tok.bosTokenId ? ids.slice(1) : ids;
console.log(`prompt ${promptIds.length} tokens`);

const DECODE = 96;
const runArm = async (activen: boolean): Promise<{ tokSec: number; tokens: number[] }> => {
  process.env.MLX_BUN_FUSED_ACTIVEN = activen ? "1" : "0";
  const out: number[] = [];
  const gen = generate(model, promptIds, { maxTokens: DECODE, temperature: 0, kvBits: 4, kvGroupSize: 64, quantizedKvStart: 0 });
  for await (const t of gen) out.push(t.token);
  return { tokSec: gen.stats?.decodeTps ?? NaN, tokens: out };
};

// interleave: new, old, new, old (first pair is warmup-ish; report medians of all)
const results: { arm: string; tokSec: number }[] = [];
let refTokens: number[] | null = null;
for (const arm of [true, false, true, false]) {
  const { tokSec, tokens } = await runArm(arm);
  if (refTokens === null) refTokens = tokens;
  const same = tokens.length === refTokens.length && tokens.every((t, i) => t === refTokens![i]);
  results.push({ arm: arm ? "activeN" : "views", tokSec });
  console.log(`${arm ? "activeN" : "views  "}: ${tokSec.toFixed(2)} tok/s  ${same ? "IDENTICAL" : "DIVERGED"}`);
}
const med = (xs: number[]): number => xs.slice().sort((a, b) => a - b)[Math.floor(xs.length / 2)]!;
const a = med(results.filter((r) => r.arm === "activeN").map((r) => r.tokSec));
const v = med(results.filter((r) => r.arm === "views").map((r) => r.tokSec));
console.log(`### median: activeN=${a.toFixed(2)} views=${v.toFixed(2)} tok/s  ratio=${(a / v).toFixed(3)}`);
weights.dispose();
