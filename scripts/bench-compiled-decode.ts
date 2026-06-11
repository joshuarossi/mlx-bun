// Compiled-decode A/B (optimization_plan Phase A): the cleared-machine
// confirmation of the mx.compile lever. Paired in-process flips of
// MLX_BUN_COMPILED_DECODE on the production path (generated dispatch,
// shipped kv_config). e4b is the headline (dirty-paired: +5.2% @600
// fading to ~0 @8k); the 12B is GPU-bound (~0 to +1%).
//
//   bun scripts/bench-compiled-decode.ts          # 12B @8k, e4b @600 + @8k
//   bun scripts/bench-compiled-decode.ts --smoke  # 1 short pair, 12B @2k
//
// Records eval-DB rows per arm.

import { SNAPSHOT } from "../tests/paths";
import { peakMemory, resetPeakMemory, clearCache } from "../src/mlx/ffi";

const SMOKE = process.argv.includes("--smoke");
const N_PAIRS = SMOKE ? 1 : 3;
const DECODE_TOKENS = SMOKE ? 32 : 128;

const E4B = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/fcdb12d740cd813634064567fc7cb51159b34253`;

const { loadModelConfig } = await import("../src/config");
const { Weights } = await import("../src/weights");
const { createModel } = await import("../src/model/factory");
const { generate } = await import("../src/generate");
const { checkMachine, machineStateJson } = await import("../src/preflight");
const { EvalDB, gitCommit } = await import("../src/evaldb");

const db = new EvalDB();
const machineState = machineStateJson(checkMachine());

const PLAN: [string, string, number[]][] = SMOKE
  ? [["12b", SNAPSHOT, [2048]]]
  : [
      ["12b", SNAPSHOT, [8192]],
      ["e4b", E4B, [600, 8192]],
    ];

for (const [name, dir, contexts] of PLAN) {
  if (!(await Bun.file(`${dir}/config.json`).exists())) {
    console.log(`${name}: snapshot missing, skipped`);
    continue;
  }
  const config = await loadModelConfig(dir);
  const weights = await Weights.open(dir);
  const model = createModel(weights, config);

  for (const CTX of contexts) {
    const promptIds = [2, ...Array.from({ length: CTX - 1 }, (_, i) => 2000 + (i % 500))];

    const runArm = async (compiled: boolean): Promise<{ decodeTps: number; peak: number }> => {
      process.env.MLX_BUN_COMPILED_DECODE = compiled ? "1" : "0";
      resetPeakMemory();
      const gen = generate(model, promptIds, {
        maxTokens: DECODE_TOKENS, temperature: 0, eosTokenIds: [],
        kvConfig: config.kvQuant ?? undefined,
        quantizedKvStart: config.kvQuant?.length ? 0 : undefined,
      });
      for await (const _ of gen) { /* drain */ }
      clearCache();
      delete process.env.MLX_BUN_COMPILED_DECODE;
      return { decodeTps: gen.stats!.decodeTps, peak: peakMemory() };
    };

    await runArm(false); // warm both paths (kernels, closures)
    await runArm(true);

    const off: number[] = [];
    const on: number[] = [];
    const peaks: Record<string, number> = {};
    for (let i = 0; i < N_PAIRS; i++) {
      const a = await runArm(false);
      off.push(a.decodeTps);
      peaks["uncompiled"] = Math.max(peaks["uncompiled"] ?? 0, a.peak);
      const b = await runArm(true);
      on.push(b.decodeTps);
      peaks["compiled"] = Math.max(peaks["compiled"] ?? 0, b.peak);
      console.log(
        `${name} @${CTX} pair ${i + 1}/${N_PAIRS}: uncompiled ${a.decodeTps.toFixed(2)} vs compiled ${b.decodeTps.toFixed(2)} tok/s` +
        ` (ratio ${(b.decodeTps / a.decodeTps).toFixed(3)})`,
      );
    }

    const median = (xs: number[]) => [...xs].sort((a, b) => a - b)[Math.floor(xs.length / 2)]!;
    const mOff = median(off);
    const mOn = median(on);
    console.log(`${name} @${CTX} median: uncompiled ${mOff.toFixed(2)} vs compiled ${mOn.toFixed(2)} tok/s — ratio ${(mOn / mOff).toFixed(3)}`);

    for (const [arm, tps, peak] of [["uncompiled", mOff, peaks["uncompiled"]!], ["compiled", mOn, peaks["compiled"]!]] as const) {
      db.record({
        modelPath: dir,
        commitSha: gitCommit(),
        promptTokens: CTX,
        generatedTokens: DECODE_TOKENS,
        prefillTps: 0, // decode experiment; prefill not the measurand
        decodeTps: tps,
        peakBytes: peak,
        notes: `bench-compiled-decode kv=config ctx=${CTX} decode-arm=${arm} paired-median-of-${N_PAIRS}${SMOKE ? " SMOKE" : ""}`,
        machineState,
      });
    }
  }
  weights.dispose();
  clearCache();
}
console.log("recorded in eval DB");
