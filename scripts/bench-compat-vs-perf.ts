// Compat-vs-perf head-to-head — COMPARISON 3 of the benchmark (our perf
// optimizations vs our own bit-parity build; the other two compare us to
// mlx-lm and optiq, bench-h2h.ts). Paired, in-process flag flips on ONE
// model so machine noise cancels (same design as bench-perf-kernel.ts).
//
//   COMPAT = the bit-parity path we bench vs the python libs: every
//            optimization that stays bit-exact (createModel/generated path,
//            E, fused GeGLU, compiled-decode). NO parity-breaking kernels.
//   PERF   = compat + the parity-breaking decode kernels (perf-kernel Metal /
//            tiled decode). No bit-parity required — the "what does perf-mode
//            buy" number.
//
// Comparison 3's requirement is NOT bit parity (perf uses online-softmax
// kernels): it is LOW KL + SIMILAR SCORES. So we report two things:
//   - SPEED: per (arm × context) prefill/decode tok/s, TTFT, peak, ratios.
//   - QUALITY: per-step KL(compat||perf) over the full vocab + greedy
//     token-match %, both arms teacher-forced down compat's greedy path so
//     the only variable is the kernel. KL is machine-independent, so it is a
//     real pass/warn verdict even on a dirty machine (the speed ratios are
//     dirty-robust by pairing; absolute tok/s still wants a clean machine).
//
//   bun scripts/bench-compat-vs-perf.ts          # @16k/@2k/@600, 3 pairs + KL
//   bun scripts/bench-compat-vs-perf.ts --smoke  # 1 short pair + short KL
//   bun scripts/bench-compat-vs-perf.ts --model gemma-4-12B-it-OptiQ-4bit
//
// DIRTY-machine runs give meaningful RATIOS (and KL) only; absolute tok/s
// wants the cleared-machine pass (reboot, nothing else open).

import { peakMemory, resetPeakMemory, clearCache } from "../src/mlx/ffi";

const { loadModelConfig } = await import("../src/config");
const { Weights } = await import("../src/weights");
const { createModel } = await import("../src/model/factory");
const { generate, maybeQuantizeKv } = await import("../src/generate");
const { checkMachine, machineStateJson } = await import("../src/preflight");
const { EvalDB, gitCommit } = await import("../src/evaldb");
const { Registry } = await import("../src/registry");
const { loadTokenizer } = await import("../src/tokenizer");
const { ChatTemplate } = await import("../src/chat-template");
const { argmaxLastPosition, lastPositionLogits } = await import("../src/model/gemma4");

function opt(name: string, dflt: string): string {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}

const SMOKE = process.argv.includes("--smoke");
const N_PAIRS = SMOKE ? 1 : 3;
const DECODE_TOKENS = SMOKE ? 16 : 128;
const CONTEXTS = SMOKE ? [512] : [16384, 2048, 600];

// compat = bit-parity (every bit-exact optimization on, no parity-breaking);
// perf = compat + the parity-breaking decode kernels. Both keep the bit-exact
// optimizations (compiled-decode, fused GeGLU) on.
const ARMS: Record<"compat" | "perf", Record<string, string>> = {
  compat: { MLX_BUN_COMPILED_DECODE: "1", MLX_BUN_FUSED_GELU: "1", MLX_BUN_PERF_KERNEL: "0", MLX_BUN_FUSED_DECODE: "0", MLX_BUN_NO_FUSED_SDPA: "0" },
  perf: { MLX_BUN_COMPILED_DECODE: "1", MLX_BUN_FUSED_GELU: "1", MLX_BUN_PERF_KERNEL: "1", MLX_BUN_FUSED_DECODE: "1", MLX_BUN_NO_FUSED_SDPA: "0" },
};

const query = opt("model", "gemma-4-e4b-it-OptiQ-4bit");
const dir = new Registry().resolve(query).path;
const config = await loadModelConfig(dir);
const weights = await Weights.open(dir);
const model = createModel(weights, config);
const kv = config.kvQuant?.length ? config.kvQuant : undefined;

const db = new EvalDB();
const machineState = machineStateJson(checkMachine());

const applyArm = (f: Record<string, string>) => { for (const [k, v] of Object.entries(f)) process.env[k] = v; };
const clearArm = (f: Record<string, string>) => { for (const k of Object.keys(f)) delete process.env[k]; };
const median = (xs: number[]) => [...xs].sort((a, b) => a - b)[Math.floor(xs.length / 2)]!;

interface Sample { prefillTps: number; decodeTps: number; ttftMs: number; peak: number }

console.log(`model=${query}  pairs=${N_PAIRS}  decode-tokens=${DECODE_TOKENS}\n`);

for (const CTX of CONTEXTS) {
  const promptIds = [2, ...Array.from({ length: CTX - 1 }, (_, i) => 2000 + (i % 500))];

  const runArm = async (f: Record<string, string>): Promise<Sample> => {
    applyArm(f);
    resetPeakMemory();
    const gen = generate(model, promptIds, {
      maxTokens: DECODE_TOKENS, temperature: 0, eosTokenIds: [],
      ...(kv ? { kvConfig: kv, quantizedKvStart: 0 } : {}),
    });
    for await (const _ of gen) { /* drain */ }
    clearCache();
    clearArm(f);
    const s = gen.stats!;
    return { prefillTps: s.prefillTps, decodeTps: s.decodeTps, ttftMs: s.prefillMs, peak: peakMemory() };
  };

  await runArm(ARMS.compat); // warm
  await runArm(ARMS.perf);

  const acc: Record<"compat" | "perf", { prefill: number[]; decode: number[]; ttft: number[]; peak: number }> = {
    compat: { prefill: [], decode: [], ttft: [], peak: 0 },
    perf: { prefill: [], decode: [], ttft: [], peak: 0 },
  };
  for (let i = 0; i < N_PAIRS; i++) {
    for (const arm of ["compat", "perf"] as const) {
      const s = await runArm(ARMS[arm]);
      acc[arm].prefill.push(s.prefillTps);
      acc[arm].decode.push(s.decodeTps);
      acc[arm].ttft.push(s.ttftMs);
      acc[arm].peak = Math.max(acc[arm].peak, s.peak);
    }
  }

  const c = acc.compat;
  const p = acc.perf;
  const row = (label: string, cv: number, pv: number, unit: string, lowerBetter = false) => {
    const ratio = lowerBetter ? cv / pv : pv / cv; // >1 = perf better
    console.log(`  ${label.padEnd(14)} ${cv.toFixed(2).padStart(10)} ${pv.toFixed(2).padStart(10)} ${unit.padEnd(7)} ${ratio.toFixed(3)}×`);
  };
  console.log(`ctx=${CTX}   ${"compat".padStart(10)} ${"perf".padStart(10)}         perf/compat`);
  row("prefill", median(c.prefill), median(p.prefill), "tok/s");
  row("decode", median(c.decode), median(p.decode), "tok/s");
  row("TTFT", median(c.ttft), median(p.ttft), "ms", true);
  row("peak mem", c.peak / 1e9, p.peak / 1e9, "GB", true);
  console.log("");

  for (const arm of ["compat", "perf"] as const) {
    const a = acc[arm];
    db.record({
      modelPath: dir, commitSha: gitCommit(), promptTokens: CTX, generatedTokens: DECODE_TOKENS,
      prefillTps: median(a.prefill), decodeTps: median(a.decode), peakBytes: a.peak,
      notes: `bench-compat-vs-perf arm=${arm} ctx=${CTX} ttftMs=${median(a.ttft).toFixed(0)} paired-median-of-${N_PAIRS}`,
      machineState,
    });
  }
}

// --- QUALITY: KL(compat||perf) + greedy token-match -------------------------
// Comparison 3's requirement is "low KL + similar scores", NOT bit parity.
// Both arms run the SAME real prompt and are teacher-forced down compat's
// greedy path, so the only variable is the perf kernel. KL is over the full
// vocab softmax and is machine-independent — a real verdict on any machine.
const KL_STEPS = SMOKE ? 4 : 24;
// Heuristic gate: perf's online-softmax kernels perturb logits at the ~1e-4
// nats level; flag anything materially above that for a human look.
const KL_MEAN_OK = 5e-3;
const KL_MAX_OK = 5e-2;
const KL_PROMPT =
  "Write a detailed essay about the history of computing, starting with mechanical calculators.";

const tokKl = await loadTokenizer(dir);
const template = await ChatTemplate.load(dir);
const rendered = template.render([{ role: "user", content: KL_PROMPT }]);
const encoded = tokKl.encode(rendered);
// template includes <bos>; tokenizer also prepends BOS — drop the duplicate
const klIds =
  encoded[0] === encoded[1] && encoded[0] === tokKl.bosTokenId ? encoded.slice(1) : encoded;
const kvOpts = kv ? { kvConfig: kv, quantizedKvStart: 0 } : {};

/** Teacher-forced decode capturing per-step last-position logits and the
 *  arm's own argmax. feed=null → greedy (feeds its own argmax, produces the
 *  reference path); feed=ref → forced down ref so KL/token-match align step
 *  for step. Mirrors generate()'s prefill→quantize→decode flow so the perf
 *  decode kernels (quantized-KV only) actually engage. */
function captureLogits(arm: Record<string, string>, feed: number[] | null): {
  logits: Float32Array[]; argmax: number[];
} {
  applyArm(arm);
  const cache = model.makeCache();
  const logits: Float32Array[] = [];
  const argmax: number[] = [];
  maybeQuantizeKv(cache, kvOpts); // no-op at offset 0 (matches generate)
  let l = model.forward(klIds, cache);
  logits.push(Float32Array.from(lastPositionLogits(l)));
  let am = argmaxLastPosition(l);
  argmax.push(am);
  l.dispose();
  maybeQuantizeKv(cache, kvOpts); // offset > 0 now → cache converts, like generate
  for (let s = 1; s < KL_STEPS; s++) {
    const fed = feed ? feed[s - 1]! : am;
    l = model.forward([fed], cache);
    logits.push(Float32Array.from(lastPositionLogits(l)));
    am = argmaxLastPosition(l);
    argmax.push(am);
    l.dispose();
  }
  for (const c of cache) c.dispose();
  clearArm(arm);
  clearCache();
  return { logits, argmax };
}

/** KL(p||q) in nats, p=softmax(x), q=softmax(y), computed log-stably. */
function klDiv(x: Float32Array, y: Float32Array): number {
  const V = x.length;
  let mx = -Infinity, my = -Infinity;
  for (let i = 0; i < V; i++) { if (x[i]! > mx) mx = x[i]!; if (y[i]! > my) my = y[i]!; }
  let sx = 0, sy = 0;
  for (let i = 0; i < V; i++) { sx += Math.exp(x[i]! - mx); sy += Math.exp(y[i]! - my); }
  const lsx = Math.log(sx), lsy = Math.log(sy);
  let kl = 0;
  for (let i = 0; i < V; i++) {
    const lp = x[i]! - mx - lsx;
    const p = Math.exp(lp);
    if (p > 0) kl += p * (lp - (y[i]! - my - lsy));
  }
  return kl;
}

console.log(`\n=== quality: KL(compat||perf) + token-match (${KL_STEPS} steps, kv=${kv ? "config" : "off"}) ===`);
const compat = captureLogits(ARMS.compat, null);
const perf = captureLogits(ARMS.perf, compat.argmax);
const kls = compat.logits.map((c, s) => klDiv(c, perf.logits[s]!));
const klMean = kls.reduce((a, b) => a + b, 0) / kls.length;
const klMax = Math.max(...kls);
const matches = perf.argmax.filter((t, s) => t === compat.argmax[s]!).length;
const tokenMatchPct = (100 * matches) / KL_STEPS;
const verdict = klMean <= KL_MEAN_OK && klMax <= KL_MAX_OK ? "PASS" : "WARN";
console.log(
  `  KL nats: mean ${klMean.toExponential(2)} (≤ ${KL_MEAN_OK.toExponential(0)}), ` +
  `max ${klMax.toExponential(2)} (≤ ${KL_MAX_OK.toExponential(0)})`,
);
console.log(`  greedy token-match: ${matches}/${KL_STEPS} (${tokenMatchPct.toFixed(1)}%) → ${verdict}`);
db.record({
  modelPath: dir, commitSha: gitCommit(), promptTokens: klIds.length, generatedTokens: KL_STEPS,
  prefillTps: 0, decodeTps: 0, peakBytes: 0, machineState,
  notes:
    `bench-compat-vs-perf-kl kv=${kv ? "config" : "off"} steps=${KL_STEPS} ` +
    `klMeanNats=${klMean.toExponential(3)} klMaxNats=${klMax.toExponential(3)} ` +
    `tokenMatchPct=${tokenMatchPct.toFixed(1)} verdict=${verdict}`,
});

db.close();
