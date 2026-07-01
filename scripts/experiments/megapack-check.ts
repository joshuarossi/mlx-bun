// Phase 1 gate: slice the packed WBYTES/SCALES/BIASES at the recorded offsets,
// rebuild a QuantizedLinear, and assert BYTE-IDENTICAL ops.quantizedMatmul vs the
// original linear's .forward on a fixed input. Catches layout bugs before any kernel.
//   bun scripts/experiments/megapack-check.ts
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { packMiniCpm5, type MatLayout } from "./megakernel-pack";
import { QuantizedLinear } from "../../src/model/gemma4-base";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { SNAPSHOT_MINICPM5 } from "../../tests/paths";

const model = new MiniCPM5Model(await Weights.open(SNAPSHOT_MINICPM5), await loadModelConfig(SNAPSHOT_MINICPM5)) as any;
const packed = packMiniCpm5(model);

// Read packed buffers back to host bytes once.
packed.wbytes.eval(); packed.scales.eval(); packed.biases.eval();
const wb = packed.wbytes.rawBytes();
const sb = packed.scales.rawBytes(); // bf16 bytes
const bb = packed.biases.rawBytes();

function rebuild(m: MatLayout): QuantizedLinear {
  const wBytesLen = (m.N * m.K * m.bits) / 8;
  const w = MlxArray.fromBytesCopy(wb.slice(m.wOff, m.wOff + wBytesLen), [m.N, (m.K * m.bits) / 32], Dtype.uint32);
  const sLen = (m.N * m.K) / m.groupSize;
  const scales = MlxArray.fromBytesCopy(sb.slice(m.sOff * 2, (m.sOff + sLen) * 2), [m.N, m.K / m.groupSize], Dtype.bfloat16);
  const biases = MlxArray.fromBytesCopy(bb.slice(m.bOff * 2, (m.bOff + sLen) * 2), [m.N, m.K / m.groupSize], Dtype.bfloat16);
  return new QuantizedLinear(w, scales, biases, { bits: m.bits, groupSize: m.groupSize, mode: "affine" });
}

function bytesEqual(a: MlxArray, b: MlxArray): boolean {
  a.eval(); b.eval();
  const x = a.rawBytes(), y = b.rawBytes();
  if (x.byteLength !== y.byteLength) return false;
  for (let i = 0; i < x.byteLength; i++) if (x[i] !== y[i]) return false;
  return true;
}

// Sample matrices across layers/matrices (8-bit, 4-bit, lm_head).
const L = model.layers;
const samples: { name: string; lin: QuantizedLinear; mat: MatLayout }[] = [
  { name: "L0.q (8b)", lin: L[0].attn.qProj, mat: packed.layout.layers[0]!.q },
  { name: "L1.gate (4b)", lin: L[1].mlp.gate, mat: packed.layout.layers[1]!.gate },
  { name: "L7.down (4b)", lin: L[7].mlp.down, mat: packed.layout.layers[7]!.down },
  { name: "L23.o (8b)", lin: L[23].attn.oProj, mat: packed.layout.layers[23]!.o },
  { name: "lm_head", lin: model.lmHead, mat: packed.layout.lmHead },
];

let allOk = true;
for (const s of samples) {
  const K = s.mat.K, N = s.mat.N;
  // fixed pseudo-random input [3, K] bf16
  const data = new Float32Array(3 * K);
  for (let i = 0; i < data.length; i++) data[i] = Math.sin(i * 0.013 + 1.0) * 0.5;
  const x = MlxArray.fromFloat32(data, [3, K]).astype(Dtype.bfloat16);
  const rebuilt = rebuild(s.mat);
  const ref = s.lin.forward(x);
  const got = ops.quantizedMatmul(x, rebuilt.w, rebuilt.scales, rebuilt.biases, rebuilt.spec, true);
  const ok = bytesEqual(ref, got) && ref.shape[1] === N;
  console.log(`${ok ? "OK  " : "FAIL"} ${s.name}  N=${N} K=${K} bits=${s.mat.bits} wOff=${s.mat.wOff}`);
  allOk = allOk && ok;
  for (const a of [x, ref, got, rebuilt.w, rebuilt.scales, rebuilt.biases!]) a.dispose();
}
console.log(allOk ? "\nPhase 1 gate: PASS (byte-identical)" : "\nPhase 1 gate: FAIL");
console.log(`packed sizes: WBYTES=${(packed.wbytes.nbytes / 1e6).toFixed(1)}MB SCALES=${(packed.scales.size / 1e6).toFixed(2)}M els BIASES=${(packed.biases.size / 1e6).toFixed(2)}M els NORMS=${packed.norms.size}`);
process.exit(allOk ? 0 : 1);
