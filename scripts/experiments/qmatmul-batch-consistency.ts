// The warm-cold split starts at layer 0 in the BOUNDARY token's own compute, with
// the cached prefix bit-identical. Prime suspect: the OptiQ quantized matmul is not
// bit-exact for a single row (decode, batch=1 GEMV) vs the same row inside a batch
// (prefill, batch=T GEMM). Isolate it on the quantized lm_head: feed a [1,T,H]
// input, compare row T-1 of forward([1,T,H]) against forward(just that row).
//
//   bun scripts/experiments/qmatmul-batch-consistency.ts
import { readdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import * as ops from "../../src/mlx/ops";
import { evalAll } from "../../src/mlx/ops";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";

const HOME = process.env.HOME!;
const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots`;
const MODEL = `${base}/${readdirSync(base)[0]}`;
const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config) as any;
const H = config.text.hiddenSize, V = config.text.vocabSize;

for (const T of [4, 14, 64]) {
  const f = new Float32Array(T * H);
  for (let i = 0; i < f.length; i++) f[i] = Math.random() * 2 - 1;
  const inp = MlxArray.fromFloat32(f, [1, T, H]).astype(Dtype.bfloat16);
  const start = MlxArray.fromInt32(new Int32Array([T - 1]), [1]);
  const inpLast = ops.sliceDynamic(inp, start, [1], [1, 1, H]); // [1,1,H]

  const full = model.lmHead.forward(inp);        // [1,T,V] — batched (prefill-shaped)
  const single = model.lmHead.forward(inpLast);  // [1,1,V] — single row (decode-shaped)
  const fullLast = ops.reshape(ops.sliceDynamic(full, start, [1], [1, 1, V]), [V]);
  const singleV = ops.reshape(single, [V]);
  evalAll([fullLast, singleV]);
  const a = fullLast.toFloat32(), b = singleV.toFloat32();
  let mx = 0, n = 0; for (let i = 0; i < V; i++) { const d = Math.abs(a[i]! - b[i]!); if (d > mx) mx = d; if (d !== 0) n++; }
  console.log(`### T=${String(T).padStart(2)}: lm_head(batch)[last] vs lm_head(single) — maxAbsΔ=${mx.toExponential(3)}  differing=${n}/${V}  ${mx === 0 ? "BIT-IDENTICAL ✓" : "DIFFERS ← quantized matmul is batch-shape-dependent"}`);
  for (const x of [inp, start, inpLast, full, single, fullLast, singleV]) x.dispose();
}
weights.dispose();
console.log("### done");
