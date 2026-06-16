// Definitive A/B: does the custom decode kernel (fusedDecodeSdpa, the
// "perf kernel", MLX_BUN_PERF_KERNEL) improve e4b decode throughput?
//
// Isolates EXACTLY one lever — perf-kernel on vs off (compat) — holding
// everything else fixed, across two backgrounds and a context sweep:
//   • prod  : CD+ SD+ FD-   (shipping default; PK layers run as JS/concat)
//   • eager : CD- SD- FD-   (no compiled machinery; the ONLY change is the
//                            decode attention kernel: fusedDecodeSdpa vs
//                            the spelled-out quantizedSdpaUnfused)
//
// PROOF the lever actually toggles the kernel: fusedKernelCalls (dispatch
// counter inside fusedDecodeSdpa) must be 0 in compat and >0 in perf. If a
// run shows no delta AND the counter never moved, the kernel isn't even on
// the path — a different conclusion than "kernel is slow".
//
//   bun scripts/bench-e4b-perf-kernel.ts
//   bun scripts/bench-e4b-perf-kernel.ts --repeats 3 --contexts 600,2048,8192,16384

import { peakMemory, resetPeakMemory, clearCache } from "../src/mlx/ffi";

const { loadModelConfig } = await import("../src/config");
const { Weights } = await import("../src/weights");
const { createModel } = await import("../src/model/factory");
const { generate } = await import("../src/generate");
const { checkMachine, machineStateJson } = await import("../src/preflight");
const { gitCommit } = await import("../src/evaldb");
const { Registry } = await import("../src/registry");
const fdk = await import("../src/model/fused-decode-kernel");

function opt(name: string, dflt: string): string {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}
const REPEATS = Number(opt("repeats", "3"));
const WARMUP = 1;
const DECODE_TOKENS = Number(opt("decode-tokens", "96"));
const CONTEXTS = opt("contexts", "600,2048,8192,16384").split(",").map(Number);
const MODEL = opt("model", "gemma-4-e4b-it-OptiQ-4bit");
const OUT = opt("out", `benchmarks-e4b-perf-kernel-${new Date().toISOString().slice(0, 10)}.json`);

// background = the three OTHER levers, held fixed while PK toggles
interface Bg { name: string; cd: boolean; sd: boolean; fd: boolean }
const BACKGROUNDS: Bg[] = [
  { name: "prod",  cd: true,  sd: true,  fd: false }, // shipping default
  { name: "eager", cd: false, sd: false, fd: false }, // pure kernel isolation
];

function applyEnv(bg: Bg, perfKernel: boolean) {
  process.env.MLX_BUN_PERF_KERNEL = perfKernel ? "1" : "0";
  process.env.MLX_BUN_FUSED_DECODE = bg.fd ? "1" : "0";
  process.env.MLX_BUN_COMPILED_DECODE = bg.cd ? "1" : "0";
  process.env.MLX_BUN_NO_FUSED_SDPA = bg.sd ? "0" : "1"; // inverted env
  process.env.MLX_BUN_FUSED_GELU = "1"; // held on (bit-exact), not under test
}

const median = (xs: number[]) => [...xs].sort((a, b) => a - b)[Math.floor(xs.length / 2)]!;

const dir = new Registry().resolve(MODEL).path;
const config = await loadModelConfig(dir);
const weights = await Weights.open(dir);
const model = createModel(weights, config);
const kv = config.kvQuant?.length ? config.kvQuant : undefined;
const machineState = machineStateJson(checkMachine());

interface Sample { decodeTps: number; prefillTps: number; ttftMs: number; peak: number; kernelCalls: number }
async function runOnce(promptIds: number[], bg: Bg, perfKernel: boolean): Promise<Sample> {
  applyEnv(bg, perfKernel);
  resetPeakMemory();
  const before = fdk.fusedKernelCalls;
  const gen = generate(model, promptIds, {
    maxTokens: DECODE_TOKENS, temperature: 0, eosTokenIds: [],
    ...(kv ? { kvConfig: kv, quantizedKvStart: 0 } : {}),
  });
  for await (const _ of gen) { /* drain */ }
  clearCache();
  const s = gen.stats!;
  return {
    decodeTps: s.decodeTps, prefillTps: s.prefillTps, ttftMs: s.prefillMs,
    peak: peakMemory(), kernelCalls: fdk.fusedKernelCalls - before,
  };
}

console.log(
  `model=${MODEL}  contexts=[${CONTEXTS}]  repeats=${REPEATS}(+${WARMUP} warm)  ` +
  `decode=${DECODE_TOKENS}  kv=${kv ? "config(mixed)" : "off"}`,
);
console.log(`machine: ${machineState}\n`);

interface Row {
  bg: string; ctx: number;
  compatDecode: number; perfDecode: number; deltaPct: number;
  compatPrefill: number; perfPrefill: number;
  compatKernelCalls: number; perfKernelCalls: number;
  peakGB: number;
}
const rows: Row[] = [];

for (const bg of BACKGROUNDS) {
  console.log(`══ background ${bg.name} (CD${bg.cd ? "+" : "-"} SD${bg.sd ? "+" : "-"} FD${bg.fd ? "+" : "-"}) ${"═".repeat(28)}`);
  console.log(
    `  ${"ctx".padStart(6)} ${"compat".padStart(9)} ${"perf".padStart(9)} ${"Δ%".padStart(7)} ` +
    `${"kcalls c/p".padStart(13)} ${"prefill c/p".padStart(14)}`,
  );
  for (const CTX of CONTEXTS) {
    const promptIds = [2, ...Array.from({ length: CTX - 1 }, (_, i) => 2000 + (i % 500))];
    const measure = async (perfKernel: boolean) => {
      for (let w = 0; w < WARMUP; w++) await runOnce(promptIds, bg, perfKernel);
      const dec: number[] = [], pre: number[] = []; let peak = 0, kcalls = 0;
      for (let r = 0; r < REPEATS; r++) {
        const s = await runOnce(promptIds, bg, perfKernel);
        dec.push(s.decodeTps); pre.push(s.prefillTps);
        peak = Math.max(peak, s.peak); kcalls = s.kernelCalls;
      }
      return { decode: median(dec), prefill: median(pre), peak, kcalls };
    };
    const compat = await measure(false);
    const perf = await measure(true);
    const deltaPct = ((perf.decode - compat.decode) / compat.decode) * 100;
    const row: Row = {
      bg: bg.name, ctx: CTX,
      compatDecode: compat.decode, perfDecode: perf.decode, deltaPct,
      compatPrefill: compat.prefill, perfPrefill: perf.prefill,
      compatKernelCalls: compat.kcalls, perfKernelCalls: perf.kcalls,
      peakGB: Math.max(compat.peak, perf.peak) / 1e9,
    };
    rows.push(row);
    console.log(
      `  ${String(CTX).padStart(6)} ${compat.decode.toFixed(1).padStart(9)} ${perf.decode.toFixed(1).padStart(9)} ` +
      `${(deltaPct >= 0 ? "+" : "") + deltaPct.toFixed(1)}%`.padStart(7) +
      ` ${`${compat.kcalls}/${perf.kcalls}`.padStart(13)} ` +
      `${`${compat.prefill.toFixed(0)}/${perf.prefill.toFixed(0)}`.padStart(14)}`,
    );
  }
  console.log("");
}

await Bun.write(OUT, JSON.stringify({
  model: MODEL, commit: gitCommit(), date: new Date().toISOString(), machineState,
  contexts: CONTEXTS, decodeTokens: DECODE_TOKENS, repeats: REPEATS, warmup: WARMUP,
  backgrounds: BACKGROUNDS, rows,
}, null, 2));
console.log(`wrote ${OUT} (${rows.length} rows)`);

// ── verdict ───────────────────────────────────────────────────────────────
const fired = rows.every((r) => r.compatKernelCalls === 0 && r.perfKernelCalls > 0);
console.log(`\nkernel-fired proof: ${fired ? "OK (compat=0, perf>0 everywhere)" : "⚠ UNEXPECTED — check kcalls column"}`);
for (const bg of BACKGROUNDS) {
  const rs = rows.filter((r) => r.bg === bg.name);
  const mean = rs.reduce((a, r) => a + r.deltaPct, 0) / rs.length;
  const best = rs.reduce((a, r) => (r.deltaPct > a.deltaPct ? r : a));
  console.log(`  ${bg.name}: mean Δ ${mean >= 0 ? "+" : ""}${mean.toFixed(1)}%  ·  best ${best.deltaPct >= 0 ? "+" : ""}${best.deltaPct.toFixed(1)}% @ctx=${best.ctx}`);
}
