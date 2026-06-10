// Phase 10 exit-criterion harness: peak transient of a long prefill over
// a quantized KV cache, fused (N-tiled) vs unfused (stock).
//
//   bun scripts/bench-fused-prefill.ts                  # fused (default)
//   MLX_BUN_NO_FUSED_SDPA=1 bun scripts/bench-fused-prefill.ts   # unfused A/B
//
// 8k-token prompt, kv8 on full-attention layers from token 0, prefill
// chunk 2048 (generate.ts default) — so the final chunk is a 2048-row
// prefill over a ~6k-token quantized cache, the exact scores-matrix
// transient the fused path exists to bound. Generation-only peak: the
// peak counter resets after load + a small warmup (Phase 15 finding —
// load transients and kernel compilation would otherwise dominate).
// Records an eval-DB row either way; memory peaks are meaningful on a
// non-pristine machine, throughput numbers are NOT headline-quotable
// unless machine_state is clean (standing rule).

import { SNAPSHOT } from "../tests/paths";
import { peakMemory, resetPeakMemory } from "../src/mlx/ffi";

const CTX = 8192;
const MAX_TOKENS = 16;
const KV_BITS = 8;

const fused = process.env.MLX_BUN_NO_FUSED_SDPA === "1" ? "off" : "on";

const { loadModelConfig } = await import("../src/config");
const { Weights } = await import("../src/weights");
const { Gemma4Model } = await import("../src/model/gemma4");
const { generate } = await import("../src/generate");
const { loadTokenizer } = await import("../src/tokenizer");
const { checkMachine, machineStateJson } = await import("../src/preflight");

const config = await loadModelConfig(SNAPSHOT);
const weights = await Weights.open(SNAPSHOT);
const model = new Gemma4Model(weights, config);
const tok = await loadTokenizer(SNAPSHOT);

// ~8k of real-ish token ids: repeat a tokenized paragraph (content is
// irrelevant for memory; ids must just be valid vocab)
const para = tok.encode(
  "The unified memory architecture lets the CPU and GPU share one pool, " +
  "so a model's weights are mapped once and read by both without copies. " +
  "Decode speed is bounded by how fast those bytes stream from DRAM. ",
);
const promptIds: number[] = [2 /* bos */];
while (promptIds.length < CTX) promptIds.push(...para);
promptIds.length = CTX;

// warmup: small generate to compile decode/prefill kernels outside the
// measured window (first-step Metal compilation is ~500 ms otherwise)
{
  const warm = generate(model, promptIds.slice(0, 64), {
    maxTokens: 2, temperature: 0, kvBits: KV_BITS, kvGroupSize: 64, quantizedKvStart: 0,
  });
  for await (const _ of warm) { /* drain */ }
}

resetPeakMemory();
const gen = generate(model, promptIds, {
  maxTokens: MAX_TOKENS, temperature: 0,
  kvBits: KV_BITS, kvGroupSize: 64, quantizedKvStart: 0,
});
const out: number[] = [];
for await (const t of gen) out.push(t.token);
const s = gen.stats!;
const peak = peakMemory();

console.log(`fused=${fused} ctx=${CTX} kv${KV_BITS} chunk=2048`);
console.log(`prefill: ${s.promptTokens} tok @ ${s.prefillTps.toFixed(1)} tok/s`);
console.log(`decode:  ${s.generatedTokens} tok @ ${s.decodeTps.toFixed(1)} tok/s`);
console.log(`generation-only peak: ${(peak / 1e9).toFixed(3)} GB`);

const { EvalDB, gitCommit } = await import("../src/evaldb");
const db = new EvalDB();
db.record({
  modelPath: SNAPSHOT,
  commitSha: gitCommit(),
  promptTokens: s.promptTokens,
  cachedTokens: s.cachedTokens,
  generatedTokens: s.generatedTokens,
  prefillTps: s.prefillTps,
  decodeTps: s.decodeTps,
  peakBytes: peak,
  notes: `bench-fused-prefill kv${KV_BITS} fused=${fused} ctx=${CTX} chunk=2048 generation-only-peak`,
  machineState: machineStateJson(checkMachine()),
});
console.log("recorded in eval DB");
