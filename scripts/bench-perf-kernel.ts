// Perf-kernel A/B (optimization_plan Phase E v2): decides the
// MLX_BUN_PERF_KERNEL default. Paired in-process flag flips on the 12B
// under the SHIPPED kv_config serve scenario (the config the kernel was
// specialized for), compiled decode at its default — i.e. exactly the
// production path either way.
//
//   bun scripts/bench-perf-kernel.ts            # @8k and @2k, 3 pairs each
//   bun scripts/bench-perf-kernel.ts --smoke    # 1 short pair (plumbing check)
//
// Dirty-machine runs give meaningful RATIOS only; the cleared-machine
// ./benchmark.sh pass is what flips the default. Records eval-DB rows
// per arm. Reference paired ratios at v2.2 (2026-06-11, dirty):
// 1.038 @8k isolated, 1.027 production, 1.022 @2k.

import { SNAPSHOT } from "../tests/paths";
import { peakMemory, resetPeakMemory, clearCache } from "../src/mlx/ffi";

const SMOKE = process.argv.includes("--smoke");
const N_PAIRS = SMOKE ? 1 : 3;
const DECODE_TOKENS = SMOKE ? 32 : 128;
const CONTEXTS = SMOKE ? [2048] : [8192, 2048];

const { loadModelConfig } = await import("../src/config");
const { Weights } = await import("../src/weights");
const { createModel } = await import("../src/model/factory");
const { generate } = await import("../src/generate");
const { checkMachine, machineStateJson } = await import("../src/preflight");
const { EvalDB, gitCommit } = await import("../src/evaldb");

const config = await loadModelConfig(SNAPSHOT);
if (!config.kvQuant?.length) throw new Error("12B snapshot has no kv_config.json — nothing to A/B");
const weights = await Weights.open(SNAPSHOT);
const model = createModel(weights, config); // production dispatch (generated 12B)

const db = new EvalDB();
const machineState = machineStateJson(checkMachine());

for (const CTX of CONTEXTS) {
  const promptIds = [2, ...Array.from({ length: CTX - 1 }, (_, i) => 2000 + (i % 500))];

  const runArm = async (kernel: boolean): Promise<{ decodeTps: number; peak: number }> => {
    if (kernel) process.env.MLX_BUN_PERF_KERNEL = "1";
    else delete process.env.MLX_BUN_PERF_KERNEL;
    resetPeakMemory();
    const gen = generate(model, promptIds, {
      maxTokens: DECODE_TOKENS, temperature: 0, eosTokenIds: [],
      kvConfig: config.kvQuant!, quantizedKvStart: 0,
    });
    for await (const _ of gen) { /* drain */ }
    clearCache();
    return { decodeTps: gen.stats!.decodeTps, peak: peakMemory() };
  };

  // warm both arms (kernel JIT, compiled closures per flag layout)
  await runArm(false);
  await runArm(true);

  const compat: number[] = [];
  const kernel: number[] = [];
  const peaks: Record<string, number> = {};
  for (let i = 0; i < N_PAIRS; i++) {
    const a = await runArm(false);
    compat.push(a.decodeTps);
    peaks["compat"] = Math.max(peaks["compat"] ?? 0, a.peak);
    const b = await runArm(true);
    kernel.push(b.decodeTps);
    peaks["kernel"] = Math.max(peaks["kernel"] ?? 0, b.peak);
    console.log(
      `@${CTX} pair ${i + 1}/${N_PAIRS}: compat ${a.decodeTps.toFixed(2)} vs kernel ${b.decodeTps.toFixed(2)} tok/s` +
      ` (ratio ${(b.decodeTps / a.decodeTps).toFixed(3)})`,
    );
  }

  const median = (xs: number[]) => [...xs].sort((a, b) => a - b)[Math.floor(xs.length / 2)]!;
  const mCompat = median(compat);
  const mKernel = median(kernel);
  console.log(`@${CTX} median: compat ${mCompat.toFixed(2)} vs kernel ${mKernel.toFixed(2)} tok/s — ratio ${(mKernel / mCompat).toFixed(3)}`);
  console.log(`@${CTX} peaks: compat ${(peaks["compat"]! / 1e9).toFixed(2)} GB, kernel ${(peaks["kernel"]! / 1e9).toFixed(2)} GB`);

  for (const [arm, tps, peak] of [["compat", mCompat, peaks["compat"]!], ["kernel", mKernel, peaks["kernel"]!]] as const) {
    db.record({
      modelPath: SNAPSHOT,
      commitSha: gitCommit(),
      promptTokens: CTX,
      generatedTokens: DECODE_TOKENS,
      prefillTps: 0, // decode experiment; prefill not the measurand
      decodeTps: tps,
      peakBytes: peak,
      notes: `bench-perf-kernel kv=config ctx=${CTX} decode-arm=${arm} paired-median-of-${N_PAIRS}${SMOKE ? " SMOKE" : ""}`,
      machineState,
    });
  }
}
console.log("recorded in eval DB");
