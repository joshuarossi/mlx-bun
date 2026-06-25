// Confirm the L2 root cause: compare the megakernel's bf16 roped K (L1, no quant) vs
// the reference model's bf16 K for layer 0. If they differ by ~1 bf16 ULP, that GEMV-
// level difference (qmv4 vs ops.quantizedMatmul) is what quantization's discontinuity
// amplifies into the L2 gap. Run WITHOUT MLX_BUN_MEGAKERNEL_KVQUANT (L1 bf16).
//   bun scripts/experiments/megakernel-kv-cmpl1.ts
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { MegakernelRunner } from "../../src/model/megakernel-kernel";
import { KVCache, type Cache } from "../../src/model/gemma4-base";
import { Dtype } from "../../src/mlx/ffi";
import { SNAPSHOT_MINICPM5 } from "../../tests/paths";

const config = await loadModelConfig(SNAPSHOT_MINICPM5);
const model = new MiniCPM5Model(await Weights.open(SNAPSHOT_MINICPM5), config);
const golden = await Bun.file("goldens/minicpm5-kv-parity.json").json();
const prompt: number[] = golden.prompt_ids;
const Lp = prompt.length, HD = 128, NKV = 2;

// reference bf16 K for layer 0 (no quant)
const cache: Cache[] = model.makeCache();
model.forward(prompt, cache).dispose();
const refC = cache[0] as KVCache;
const refK = refC.keys!.toFloat32(); // [1, NKV, paddedSeq, HD]
const paddedSeq = refC.keys!.shape[2]!;
for (const c of cache) c.dispose();

// megakernel bf16 K (L1) for layer 0
const r = new MegakernelRunner(model);
for (const p of prompt) r.decodeStep(p).dispose();
const kc = r.kcache.astype(Dtype.float32).toFloat32(); // [NLAYERS, kvSeq, 256]
const kvSeq = r.kvSeq;

let maxDiff = 0, ulps = 0, n = 0, worst = "";
for (let p = 0; p < Lp; p++) for (let h = 0; h < NKV; h++) for (let d = 0; d < HD; d++) {
  const mega = kc[(0 * kvSeq + p) * 256 + h * HD + d]!;
  const ref = refK[(h * paddedSeq + p) * HD + d]!;
  const diff = Math.abs(mega - ref);
  if (diff > maxDiff) { maxDiff = diff; worst = `p${p} h${h} d${d}: mega=${mega.toFixed(5)} ref=${ref.toFixed(5)}`; }
  // bf16 ULP at this magnitude ≈ |ref| * 2^-8
  const ulp = Math.max(Math.abs(ref), 1e-3) * Math.pow(2, -8);
  if (diff > ulp) ulps++;
  n++;
}
console.log(`layer0 bf16 K (megakernel L1 vs reference): max |diff| = ${maxDiff.toExponential(3)}`);
console.log(`elements exceeding 1 bf16 ULP: ${ulps}/${n}`);
console.log(`worst: ${worst}`);
r.dispose();
