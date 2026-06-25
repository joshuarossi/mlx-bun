// Decisive L2 diagnostic: dequantize layer-0 K from (a) the reference QuantizedKVCache
// (bit-exact with the golden) and (b) the megakernel's kcache+sb, and compare. If they
// match → the divergence is the attention algorithm; if not → a quant/storage mismatch.
//   MLX_BUN_MEGAKERNEL_KVQUANT=1 bun scripts/experiments/megakernel-kv-cmpkv.ts
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { MiniCPM5Model } from "../../src/model/minicpm5";
import { MegakernelRunner } from "../../src/model/megakernel-kernel";
import { KVCache, RotatingKVCache, QuantizedKVCache, type Cache } from "../../src/model/gemma4-base";
import * as ops from "../../src/mlx/ops";
import { Dtype } from "../../src/mlx/ffi";
import { SNAPSHOT_MINICPM5 } from "../../tests/paths";

const config = await loadModelConfig(SNAPSHOT_MINICPM5);
const model = new MiniCPM5Model(await Weights.open(SNAPSHOT_MINICPM5), config);
const golden = await Bun.file("goldens/minicpm5-kv-parity.json").json();
const prompt: number[] = golden.prompt_ids;
const Lp = prompt.length;
const kvBits0 = config.kvQuant!.find((e) => e.layerIdx === 0)!.bits;
const HD = 128, NKV = 2;

// (a) Reference: prefill prompt bf16, then quantize (== golden flow), dequant layer-0 K.
const cache: Cache[] = model.makeCache();
model.forward(prompt, cache).dispose();
const byLayer = new Map(config.kvQuant!.map((e) => [e.layerIdx, e]));
for (let i = 0; i < cache.length; i++) {
  const c = cache[i]!;
  if ((c instanceof KVCache || c instanceof RotatingKVCache) && c.offset > 0) {
    const e = byLayer.get(i); if (e) cache[i] = c.toQuantized(e.groupSize, e.bits);
  }
}
const qc = cache[0] as QuantizedKVCache;
const refKa = ops.dequantize(qc.keys!.packed, qc.keys!.scales, qc.keys!.biases, { groupSize: 64, bits: kvBits0, mode: "affine" });
const refK = refKa.toFloat32(); // [1, NKV, paddedSeq, HD]
const paddedSeq = qc.keys!.packed.shape[2]!;
for (const c of cache) c.dispose();

// (b) Megakernel: feed prompt (KVQUANT), dequant layer-0 K from kcache(q) + sb(scale/bias).
const r = new MegakernelRunner(model);
for (const p of prompt) r.decodeStep(p).dispose();
const kc = r.kcache.astype(Dtype.float32).toFloat32(); // [NLAYERS, kvSeq, 256]
const sb = r.sb.astype(Dtype.float32).toFloat32();      // [NLAYERS, kvSeq, 16]
const kvSeq = r.kvSeq;

let maxDiff = 0, worst = "";
for (let p = 0; p < Lp; p++) for (let h = 0; h < NKV; h++) for (let d = 0; d < HD; d++) {
  const grp = (d / 64) | 0, slot = h * 2 + grp;
  const q = kc[(0 * kvSeq + p) * 256 + h * HD + d]!;
  const scale = sb[(0 * kvSeq + p) * 16 + slot]!, bias = sb[(0 * kvSeq + p) * 16 + 4 + slot]!;
  const megaK = scale * q + bias;
  const rK = refK[(h * paddedSeq + p) * HD + d]!;
  const diff = Math.abs(megaK - rK);
  if (diff > maxDiff) { maxDiff = diff; worst = `p${p} h${h} d${d}: mega=${megaK.toFixed(4)} ref=${rK.toFixed(4)} (q=${q})`; }
}
console.log(`layer0 K dequant: max |mega - ref| = ${maxDiff.toExponential(3)}`);
console.log(`worst: ${worst}`);
r.dispose();
