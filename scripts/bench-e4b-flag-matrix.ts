// e4b flag-mixture sweep — maps decode / prefill / TTFT / peak-mem + KL-vs-
// baseline for EVERY cartesian combination of the four CLI perf levers, at
// 600 / 2k / 8k. One process: the 7 GB model loads ONCE and we flip env
// between combos (same design as bench-compat-vs-perf.ts), so machine noise
// largely cancels and the RATIOS/ordering are valid even on a dirty machine.
// Absolute tok/s still wants a cleared machine; KL is machine-independent.
//
//   levers (env)                  CLI flag           parity?
//   MLX_BUN_PERF_KERNEL           --perf-kernel      BREAKS parity (decode)
//   MLX_BUN_FUSED_DECODE          --fused-decode     BREAKS parity (decode)
//   MLX_BUN_COMPILED_DECODE       --compiled-decode  bit-exact
//   MLX_BUN_NO_FUSED_SDPA (inv.)  --fused-sdpa       bit-exact (prefill)
//   MLX_BUN_FUSED_GELU held ON (bit-exact, not a serve lever).
//
// Logits depend only on (perf-kernel, fused-decode); the other two are
// bit-exact, so KL is computed for the 4 (pk,fd) states and mapped onto all 16.
//
//   bun scripts/bench-e4b-flag-matrix.ts                 # full 16×3 + KL
//   bun scripts/bench-e4b-flag-matrix.ts --probe         # 1 combo × 3 ctx ×1, timings only
//   bun scripts/bench-e4b-flag-matrix.ts --repeats 3 --decode-tokens 128

import { peakMemory, resetPeakMemory, clearCache } from "../src/mlx/ffi";

const { loadModelConfig } = await import("../src/config");
const { Weights } = await import("../src/weights");
const { createModel } = await import("../src/model/factory");
const { generate, maybeQuantizeKv } = await import("../src/generate");
const { checkMachine, machineStateJson } = await import("../src/preflight");
const { gitCommit } = await import("../src/evaldb");
const { Registry } = await import("../src/registry");
const { loadTokenizer } = await import("../src/tokenizer");
const { ChatTemplate } = await import("../src/chat-template");
const { argmaxLastPosition, lastPositionLogits } = await import("../src/model/gemma4");

function opt(name: string, dflt: string): string {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}
const PROBE = process.argv.includes("--probe");
const SKIP_KL = process.argv.includes("--skip-kl");
const REPEATS = Number(opt("repeats", "2"));
const WARMUP = 1;
const DECODE_TOKENS = Number(opt("decode-tokens", "96"));
const CONTEXTS = PROBE ? [600, 2048, 8192] : [600, 2048, 8192];
const MODEL = opt("model", "gemma-4-e4b-it-OptiQ-4bit");
const OUT = opt("out", `benchmarks-e4b-flag-matrix-${new Date().toISOString().slice(0, 10)}.json`);

interface Combo { perfKernel: boolean; fusedDecode: boolean; compiledDecode: boolean; fusedSdpa: boolean }
const COMBOS: Combo[] = Array.from({ length: 16 }, (_, m) => ({
  perfKernel: !!(m & 1), fusedDecode: !!(m & 2), compiledDecode: !!(m & 4), fusedSdpa: !!(m & 8),
}));
const code = (c: Combo) =>
  `PK${c.perfKernel ? "+" : "-"} FD${c.fusedDecode ? "+" : "-"} CD${c.compiledDecode ? "+" : "-"} SD${c.fusedSdpa ? "+" : "-"}`;
const isBaseline = (c: Combo) => !c.perfKernel && !c.fusedDecode && c.compiledDecode && c.fusedSdpa;
const isDefault = (c: Combo) => c.perfKernel && !c.fusedDecode && c.compiledDecode && c.fusedSdpa;

function applyCombo(c: Combo) {
  process.env.MLX_BUN_PERF_KERNEL = c.perfKernel ? "1" : "0";
  process.env.MLX_BUN_FUSED_DECODE = c.fusedDecode ? "1" : "0";
  process.env.MLX_BUN_COMPILED_DECODE = c.compiledDecode ? "1" : "0";
  process.env.MLX_BUN_NO_FUSED_SDPA = c.fusedSdpa ? "0" : "1"; // inverted env
  process.env.MLX_BUN_FUSED_GELU = "1";
}

const median = (xs: number[]) => [...xs].sort((a, b) => a - b)[Math.floor(xs.length / 2)]!;

const dir = new Registry().resolve(MODEL).path;
const config = await loadModelConfig(dir);
const weights = await Weights.open(dir);
const model = createModel(weights, config);
const kv = config.kvQuant?.length ? config.kvQuant : undefined;
const machineState = machineStateJson(checkMachine());

interface Sample { prefillTps: number; decodeTps: number; ttftMs: number; peak: number }
async function runOnce(promptIds: number[], c: Combo): Promise<Sample> {
  applyCombo(c);
  resetPeakMemory();
  const gen = generate(model, promptIds, {
    maxTokens: DECODE_TOKENS, temperature: 0, eosTokenIds: [],
    ...(kv ? { kvConfig: kv, quantizedKvStart: 0 } : {}),
  });
  for await (const _ of gen) { /* drain */ }
  clearCache();
  const s = gen.stats!;
  return { prefillTps: s.prefillTps, decodeTps: s.decodeTps, ttftMs: s.prefillMs, peak: peakMemory() };
}

console.log(
  `model=${MODEL}  combos=${COMBOS.length}  contexts=[${CONTEXTS}]  ` +
  `repeats=${REPEATS}(+${WARMUP} warm)  decode=${DECODE_TOKENS}  kv=${kv ? "config(mixed)" : "off"}`,
);
console.log(`machine: ${machineState}\n`);

interface Row { ctx: number; combo: Combo; prefill: number; decode: number; ttft: number; peakGB: number }
const rows: Row[] = [];

if (PROBE) {
  const probe = COMBOS.find(isDefault)!;
  console.log(`PROBE — default combo (${code(probe)}), 1 sample per context, timing wall-clock:`);
  for (const CTX of CONTEXTS) {
    const promptIds = [2, ...Array.from({ length: CTX - 1 }, (_, i) => 2000 + (i % 500))];
    const t0 = performance.now();
    const s = await runOnce(promptIds, probe);
    const wall = (performance.now() - t0) / 1000;
    console.log(
      `  ctx=${String(CTX).padStart(5)}  wall=${wall.toFixed(1)}s  ` +
      `prefill=${s.prefillTps.toFixed(0)} tok/s  decode=${s.decodeTps.toFixed(1)} tok/s  ` +
      `ttft=${s.ttftMs.toFixed(0)}ms  peak=${(s.peak / 1e9).toFixed(2)}GB`,
    );
  }
  const est = CONTEXTS.length * COMBOS.length * (WARMUP + REPEATS);
  console.log(`\nfull sweep = ${COMBOS.length} combos × ${CONTEXTS.length} ctx × ${WARMUP + REPEATS} calls = ${est} generate() calls.`);
  process.exit(0);
}

for (const CTX of CONTEXTS) {
  const promptIds = [2, ...Array.from({ length: CTX - 1 }, (_, i) => 2000 + (i % 500))];
  console.log(`── ctx=${CTX} ${"─".repeat(40)}`);
  console.log(`  ${"combo".padEnd(22)} ${"decode".padStart(9)} ${"prefill".padStart(9)} ${"ttft".padStart(7)} ${"peakGB".padStart(7)}`);
  for (const c of COMBOS) {
    for (let w = 0; w < WARMUP; w++) await runOnce(promptIds, c); // compile / warm
    const dec: number[] = [], pre: number[] = [], tt: number[] = [];
    let peak = 0;
    for (let r = 0; r < REPEATS; r++) {
      const s = await runOnce(promptIds, c);
      dec.push(s.decodeTps); pre.push(s.prefillTps); tt.push(s.ttftMs); peak = Math.max(peak, s.peak);
    }
    const row: Row = { ctx: CTX, combo: c, prefill: median(pre), decode: median(dec), ttft: median(tt), peakGB: peak / 1e9 };
    rows.push(row);
    const tag = isBaseline(c) ? " ◇baseline" : isDefault(c) ? " ★default" : "";
    console.log(
      `  ${code(c).padEnd(22)} ${row.decode.toFixed(1).padStart(9)} ${row.prefill.toFixed(0).padStart(9)} ` +
      `${row.ttft.toFixed(0).padStart(7)} ${row.peakGB.toFixed(2).padStart(7)}${tag}`,
    );
  }
  console.log("");
}

// ── QUALITY: KL(baseline || combo) for the 4 (pk,fd) states ──────────────────
const KL_STEPS = 24;
const KL_MEAN_OK = 5e-3, KL_MAX_OK = 5e-2;
const KL_PROMPT = "Write a detailed essay about the history of computing, starting with mechanical calculators.";

interface KlRow { perfKernel: boolean; fusedDecode: boolean; klMean: number; klMax: number; tokenMatchPct: number; verdict: string }
const klRows: KlRow[] = [];

if (!SKIP_KL) {
  const tok = await loadTokenizer(dir);
  const template = await ChatTemplate.load(dir);
  const encoded = tok.encode(template.render([{ role: "user", content: KL_PROMPT }]));
  const klIds = encoded[0] === encoded[1] && encoded[0] === tok.bosTokenId ? encoded.slice(1) : encoded;
  const kvOpts = kv ? { kvConfig: kv, quantizedKvStart: 0 } : {};

  // KL depends only on (pk,fd); hold cd ON and fused-sdpa ON (bit-exact levers).
  const klCombo = (pk: boolean, fd: boolean): Combo => ({ perfKernel: pk, fusedDecode: fd, compiledDecode: true, fusedSdpa: true });
  function captureLogits(c: Combo, feed: number[] | null): { logits: Float32Array[]; argmax: number[] } {
    applyCombo(c);
    const cache = model.makeCache();
    const logits: Float32Array[] = [], argmax: number[] = [];
    maybeQuantizeKv(cache, kvOpts);
    let l = model.forward(klIds, cache);
    logits.push(Float32Array.from(lastPositionLogits(l))); let am = argmaxLastPosition(l); argmax.push(am); l.dispose();
    maybeQuantizeKv(cache, kvOpts);
    for (let s = 1; s < KL_STEPS; s++) {
      const fed = feed ? feed[s - 1]! : am;
      l = model.forward([fed], cache);
      logits.push(Float32Array.from(lastPositionLogits(l))); am = argmaxLastPosition(l); argmax.push(am); l.dispose();
    }
    for (const c of cache) c.dispose();
    clearCache();
    return { logits, argmax };
  }
  function klDiv(x: Float32Array, y: Float32Array): number {
    const V = x.length; let mx = -Infinity, my = -Infinity;
    for (let i = 0; i < V; i++) { if (x[i]! > mx) mx = x[i]!; if (y[i]! > my) my = y[i]!; }
    let sx = 0, sy = 0;
    for (let i = 0; i < V; i++) { sx += Math.exp(x[i]! - mx); sy += Math.exp(y[i]! - my); }
    const lsx = Math.log(sx), lsy = Math.log(sy); let kl = 0;
    for (let i = 0; i < V; i++) { const lp = x[i]! - mx - lsx; const p = Math.exp(lp); if (p > 0) kl += p * (lp - (y[i]! - my - lsy)); }
    return kl;
  }

  console.log(`=== quality: KL(baseline || combo), ${KL_STEPS} steps, kv=${kv ? "config" : "off"} ===`);
  const base = captureLogits(klCombo(false, false), null);
  for (const [pk, fd] of [[false, false], [true, false], [false, true], [true, true]] as const) {
    const arm = pk === false && fd === false ? base : captureLogits(klCombo(pk, fd), base.argmax);
    const kls = base.logits.map((b, s) => klDiv(b, arm.logits[s]!));
    const klMean = kls.reduce((a, b) => a + b, 0) / kls.length;
    const klMax = Math.max(...kls);
    const matches = arm.argmax.filter((t, s) => t === base.argmax[s]!).length;
    const tokenMatchPct = (100 * matches) / KL_STEPS;
    const verdict = klMean <= KL_MEAN_OK && klMax <= KL_MAX_OK ? "PASS" : "WARN";
    klRows.push({ perfKernel: pk, fusedDecode: fd, klMean, klMax, tokenMatchPct, verdict });
    console.log(
      `  PK${pk ? "+" : "-"} FD${fd ? "+" : "-"}  KL mean ${klMean.toExponential(2)} max ${klMax.toExponential(2)} ` +
      `match ${tokenMatchPct.toFixed(1)}% → ${verdict}`,
    );
  }
}

await Bun.write(OUT, JSON.stringify({
  model: MODEL, commit: gitCommit(), date: new Date().toISOString(), machineState,
  contexts: CONTEXTS, decodeTokens: DECODE_TOKENS, repeats: REPEATS, warmup: WARMUP,
  rows: rows.map((r) => ({ ...r.combo, ctx: r.ctx, decode: r.decode, prefill: r.prefill, ttft: r.ttft, peakGB: r.peakGB })),
  kl: klRows,
}, null, 2));
console.log(`\nwrote ${OUT} (${rows.length} rows, ${klRows.length} KL states)`);
