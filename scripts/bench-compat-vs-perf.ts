// Compat-vs-perf head-to-head — the in-house performance comparison that
// complements the bench-h2h matrix (compat vs the python libs). Paired,
// in-process flag flips on ONE model so machine noise cancels (same design
// as bench-perf-kernel.ts). Per (arm × context): prefill tok/s, decode
// tok/s, TTFT (ms), peak memory, and the perf/compat ratio.
//
//   COMPAT = the bit-parity path we bench vs the python libs: every
//            optimization that stays bit-exact (createModel/generated path,
//            E, fused GeGLU, compiled-decode). NO parity-breaking kernels.
//   PERF   = compat + the parity-breaking decode kernels (perf-kernel Metal /
//            tiled decode). No bit-parity required — the "what does perf-mode
//            buy" number.
//
//   bun scripts/bench-compat-vs-perf.ts          # @16k/@2k/@600, 3 pairs
//   bun scripts/bench-compat-vs-perf.ts --smoke  # 1 short pair (plumbing)
//   bun scripts/bench-compat-vs-perf.ts --model gemma-4-12B-it-OptiQ-4bit
//
// DIRTY-machine runs give meaningful RATIOS only; the cleared-machine pass
// (reboot, nothing else open) is what we'd quote.

import { peakMemory, resetPeakMemory, clearCache } from "../src/mlx/ffi";

const { loadModelConfig } = await import("../src/config");
const { Weights } = await import("../src/weights");
const { createModel } = await import("../src/model/factory");
const { generate } = await import("../src/generate");
const { checkMachine, machineStateJson } = await import("../src/preflight");
const { EvalDB, gitCommit } = await import("../src/evaldb");
const { Registry } = await import("../src/registry");

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
db.close();
