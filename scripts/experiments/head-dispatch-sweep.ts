// head-dispatch-sweep.ts — kernel backlog #3 measurement: the ORPO/SFT head's
// flash-vs-fused crossover in M. Drives fusedRespLogpMean (the shared seam)
// with flash=true / flash=false through a Vjp (fwd + dh backward, unit
// cotangent — exactly how training invokes it) and reports per-M time + peak.
// The flash head's advantage is residency ([M,V]-free), not speed; the fused
// QM head is expected to win at short M (review: e4b M=512 fused 481 ms vs
// flash 934 ms). The measured crossover sets FLASH_MIN_M's default.
//
//   bun scripts/experiments/head-dispatch-sweep.ts            # MiniCPM5
//   E4B=1 bun scripts/experiments/head-dispatch-sweep.ts      # gemma e4b (262k vocab)

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import * as ops from "../../src/mlx/ops";
import { clearCache, peakMemory, resetPeakMemory, Dtype } from "../../src/mlx/ffi";
import { MlxArray } from "../../src/mlx/array";
import { Vjp } from "../../src/mlx/autograd";
import { fusedRespLogpMean } from "../../src/train/loss";

process.env.MLX_BUN_PERF_KERNEL = "0";
process.env.MLX_BUN_FUSED_GELU = "0";

const HOME = process.env.HOME!;
const E4B = process.env.E4B === "1";
const repo = E4B
  ? "models--mlx-community--gemma-4-e4b-it-OptiQ-4bit"
  : "models--mlx-community--MiniCPM5-1B-OptiQ-4bit";
const base = `${HOME}/.cache/huggingface/hub/${repo}/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base).filter((d) => !d.startsWith("."))[0]}`;
const CHUNK = Number(process.env.CHUNK ?? 512);

const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
const H = config.text.hiddenSize, V = config.text.vocabSize;
console.log(`### head-dispatch-sweep  model=${E4B ? "e4b" : "MiniCPM5"} H=${H} V=${V} chunk=${CHUNK}`);
console.log(`M     | head  | ms/call | peak GB | Δlogp vs other head`);

let seed = 11;
const rnd = (): number => { seed = (seed * 1103515245 + 12345) & 0x7fffffff; return (seed / 0x7fffffff) - 0.5; };
const one = MlxArray.fromFloat32(new Float32Array([1]), [1]); // matches the head's [1] output

for (const M of [64, 128, 256, 512, 1024, 2048, 4096, 8192]) {
  const hData = new Float32Array(M * H);
  for (let i = 0; i < hData.length; i++) hData[i] = rnd();
  const hResp = MlxArray.fromFloat32(hData, [M, H]).astype(Dtype.bfloat16);
  const targets = new Int32Array(M);
  for (let i = 0; i < M; i++) targets[i] = 1 + (i * 2659 + 13) % (V - 2);

  const results: Record<string, number> = {};
  for (const flash of [false, true]) {
    const call = (): number => {
      const sink: Array<{ dispose(): void }> = [];
      const vjp = new Vjp((p) => [fusedRespLogpMean(model, p[0]!, targets, CHUNK, sink, 0, flash)], 1);
      const { outputs, vjps } = vjp.apply([hResp], [one]);
      ops.evalAll([outputs[0]!, vjps[0]!]);
      const v = outputs[0]!.toFloat32()[0]!;
      for (const a of [...outputs, ...vjps]) a.dispose();
      vjp.dispose();
      for (const d of sink) d.dispose();
      return v;
    };
    call(); // warm (compile kernels at this shape)
    clearCache(); resetPeakMemory();
    const t0 = performance.now();
    const N = M >= 4096 ? 3 : 5;
    let v = 0;
    for (let i = 0; i < N; i++) v = call();
    const ms = (performance.now() - t0) / N;
    const pk = peakMemory() / 1e9;
    results[flash ? "flash" : "fused"] = v;
    console.log(`${String(M).padEnd(5)} | ${flash ? "flash" : "fused"} | ${ms.toFixed(0).padStart(7)} | ${pk.toFixed(2).padStart(7)} | ${results.fused !== undefined && results.flash !== undefined ? Math.abs(results.fused - results.flash).toExponential(2) : "-"}`);
    clearCache();
  }
  hResp.dispose();
}
weights.dispose();
