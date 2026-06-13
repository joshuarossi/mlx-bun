// NEXT UP 1b experiment harness: does tiling DECODE (L=1) over
// quantized caches pay at long context? (optiq's wrapper tiles decode —
// no L gate — and its kv-mixed decode tax @8k measured ~free where ours
// is ~3%; Phase 15.)
//
//   bun scripts/bench-fused-decode.ts
//
// Interleaved paired A/B in ONE process (stock/tiled/stock/tiled...,
// N_PAIRS each): the flag is read per dispatch call, so arms differ only
// in the decode SDPA path. Paired ratios survive a non-pristine machine
// (standing rule: the ABSOLUTE numbers here are not headline-quotable;
// the cleared-machine ./benchmark.sh A/B settles the default). Each arm
// re-prefills — at 64k the sliding rings have wrapped, so caches cannot
// be trimmed back for reuse. Records eval-DB rows per arm.

import { SNAPSHOT } from "../tests/paths";
import { peakMemory, resetPeakMemory } from "../src/mlx/ffi";

const CTX = 65536;
const DECODE_TOKENS = 128;
const N_PAIRS = 3;
const KV_BITS = 8;

const { loadModelConfig } = await import("../src/config");
const { Weights } = await import("../src/weights");
const { Gemma4Model } = await import("../src/model/gemma4");
const { generate } = await import("../src/generate");
const { loadTokenizer } = await import("../src/tokenizer");
const { checkMachine, machineStateJson } = await import("../src/preflight");
const { EvalDB, gitCommit } = await import("../src/evaldb");

const config = await loadModelConfig(SNAPSHOT);
const weights = await Weights.open(SNAPSHOT);
const model = new Gemma4Model(weights, config);
const tok = await loadTokenizer(SNAPSHOT);

const para = tok.encode(
  "The unified memory architecture lets the CPU and GPU share one pool, " +
  "so a model's weights are mapped once and read by both without copies. " +
  "Decode speed is bounded by how fast those bytes stream from DRAM. ",
);
const promptIds: number[] = [2 /* bos */];
while (promptIds.length < CTX) promptIds.push(...para);
promptIds.length = CTX;

async function runArm(fusedDecode: boolean): Promise<{ decodeTps: number; peak: number }> {
  if (fusedDecode) process.env.MLX_BUN_FUSED_DECODE = "1";
  else delete process.env.MLX_BUN_FUSED_DECODE;
  resetPeakMemory();
  const gen = generate(model, promptIds, {
    maxTokens: DECODE_TOKENS, temperature: 0,
    kvBits: KV_BITS, kvGroupSize: 64, quantizedKvStart: 0,
  });
  for await (const _ of gen) { /* drain */ }
  return { decodeTps: gen.stats!.decodeTps, peak: peakMemory() };
}

// warmup (kernel compilation for both paths, small ctx)
{
  const warmIds = promptIds.slice(0, 64);
  for (const f of [false, true]) {
    if (f) process.env.MLX_BUN_FUSED_DECODE = "1";
    else delete process.env.MLX_BUN_FUSED_DECODE;
    const w = generate(model, warmIds, {
      maxTokens: 4, temperature: 0, kvBits: KV_BITS, kvGroupSize: 64, quantizedKvStart: 0,
    });
    for await (const _ of w) { /* drain */ }
  }
  delete process.env.MLX_BUN_FUSED_DECODE;
}

const stock: number[] = [];
const tiled: number[] = [];
const peaks: Record<string, number> = {};
for (let i = 0; i < N_PAIRS; i++) {
  const a = await runArm(false);
  stock.push(a.decodeTps);
  peaks["stock"] = Math.max(peaks["stock"] ?? 0, a.peak);
  const b = await runArm(true);
  tiled.push(b.decodeTps);
  peaks["tiled"] = Math.max(peaks["tiled"] ?? 0, b.peak);
  console.log(
    `pair ${i + 1}/${N_PAIRS}: stock ${a.decodeTps.toFixed(2)} vs tiled ${b.decodeTps.toFixed(2)} tok/s` +
    ` (ratio ${(b.decodeTps / a.decodeTps).toFixed(3)})`,
  );
}

const median = (xs: number[]) => [...xs].sort((a, b) => a - b)[Math.floor(xs.length / 2)]!;
const mStock = median(stock);
const mTiled = median(tiled);
console.log(`\nmedian decode @${CTX} kv${KV_BITS}: stock ${mStock.toFixed(2)} vs tiled ${mTiled.toFixed(2)} tok/s`);
console.log(`paired ratio (tiled/stock): ${(mTiled / mStock).toFixed(3)}`);
console.log(`peaks: stock ${(peaks["stock"]! / 1e9).toFixed(2)} GB, tiled ${(peaks["tiled"]! / 1e9).toFixed(2)} GB`);

const db = new EvalDB();
const machineState = machineStateJson(checkMachine());
for (const [arm, tps, peak] of [["stock", mStock, peaks["stock"]!], ["tiled", mTiled, peaks["tiled"]!]] as const) {
  db.record({
    modelPath: SNAPSHOT,
    commitSha: gitCommit(),
    promptTokens: CTX,
    generatedTokens: DECODE_TOKENS,
    prefillTps: 0, // decode experiment; prefill not the measurand
    decodeTps: tps,
    peakBytes: peak,
    notes: `bench-fused-decode kv${KV_BITS} ctx=${CTX} decode-arm=${arm} paired-median-of-${N_PAIRS}`,
    machineState,
  });
}
console.log("recorded in eval DB");
