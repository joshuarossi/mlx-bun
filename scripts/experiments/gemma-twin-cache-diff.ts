// Cache-level byte diff: real 12B layer-0 rot-quant cache after prefill,
// vs a twin built from its temporalView — feed ONE identical decode row and
// compare EVERYTHING the model consumes: returned fetch triples, mask,
// rope offsets, scalar offset, groupSize/bits.
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { maybeQuantizeKv } from "../../src/generate";
import { RotatingQuantizedKVCache } from "../../src/model/gemma4-base";
import { BatchedRotatingQuantCache } from "../../src/model/batched-rotating-quant";
import { SNAPSHOT } from "../../tests/paths";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";

const config = await loadModelConfig(SNAPSHOT);
const weights = await Weights.open(SNAPSHOT);
const model = createModel(weights, config);
const prompt = [2, 100, 200, 300, 400, 500, 600, 700];

const caches = model.makeCache();
const l = model.forward(prompt, caches);
l.dispose();
maybeQuantizeKv(caches, { kvConfig: config.kvQuant!, quantizedKvStart: 0 });
const serial = caches[0] as RotatingQuantizedKVCache;
console.log("serial:", { offset: serial.offset, ringIdx: serial.ringIdx, maxSize: serial.maxSize, groupSize: serial.groupSize, bits: serial.bits });

const [k0, v0] = serial.temporalView();
console.log("view shapes:", k0.packed.shape, k0.scales.shape);
const twin = BatchedRotatingQuantCache.merge([{ keys: k0, values: v0 }], [serial.offset], serial.maxSize, serial.groupSize, serial.bits);
for (const t of [k0, v0]) { t.packed.dispose(); t.scales.dispose(); t.biases.dispose(); }
console.log("twin:", { offset: twin.offset, ringIdx: twin.ringIdx, leftPad: twin.leftPad, offsetArr: twin.offsetArr });
console.log("twin rope value:", twin.ropeOffsetArr.toIntTokens(), "| serial ropeOffsetArr:", (serial as { ropeOffsetArr?: unknown }).ropeOffsetArr);

// BEFORE the decode write, compare the two caches' logical content.
{
  const [sk] = serial.temporalView();
  const [tk] = twin.temporalView();
  const a = sk.packed.toIntTokens(), b = tk.packed.toIntTokens();
  let diff = 0; for (let i = 0; i < Math.max(a.length, b.length); i++) if (a[i] !== b[i]) diff++;
  console.log(`pre-write temporal K packed: len ${a.length}/${b.length}, mismatches ${diff}`);
  for (const t of [sk, tk]) { t.packed.dispose(); t.scales.dispose(); t.biases.dispose(); }
}

// One identical decode row through both.
const H = 4, D = 256; // 12B kv heads / head dim — verify against shapes above
const kHW = (serial.keys!.packed.shape as number[])[1]!;
const kD = (serial.keys!.packed.shape as number[])[3]! * (32 / serial.bits);
const f = new Float32Array(1 * kHW * 1 * kD);
let s0 = 12345; const rnd = () => { s0 = (s0 * 1664525 + 1013904223) >>> 0; return (s0 / 0xffffffff) - 0.5; };
for (let i = 0; i < f.length; i++) f[i] = rnd();
const mk = () => { const a = MlxArray.fromFloat32(f, [1, kHW, 1, kD]); const b = a.astype(Dtype.bfloat16); a.dispose(); return b; };

const masks = [serial.makeMask(1, 1024), twin.makeMask(1, 1024)];
console.log("mask modes:", masks.map((m) => m.mode));
masks.forEach((m) => m.arr?.dispose());

const kS = mk(), vS = mk(), kT = mk(), vT = mk();
const [sfk, sfv] = serial.updateAndFetchQuantized(kS, vS);
const [tfk, tfv] = twin.updateAndFetchQuantized(kT, vT);
for (const a of [kS, vS, kT, vT]) a.dispose();

const cmp = (a: ops.QuantizedTensor, b: ops.QuantizedTensor, tag: string) => {
  console.log(`${tag}: serial ${JSON.stringify(a.packed.shape)} twin ${JSON.stringify(b.packed.shape)}`);
  const pa = a.packed.toIntTokens(), pb = b.packed.toIntTokens();
  let diff = 0; for (let i = 0; i < Math.max(pa.length, pb.length); i++) if (pa[i] !== pb[i]) diff++;
  const sa = a.scales.toFloat32(), sb = b.scales.toFloat32();
  let sdiff = 0; for (let i = 0; i < Math.max(sa.length, sb.length); i++) if (sa[i] !== sb[i]) sdiff++;
  console.log(`${tag}: packed len ${pa.length}/${pb.length} mismatch ${diff} · scales len ${sa.length}/${sb.length} mismatch ${sdiff}`);
};
cmp(sfk, tfk, "fetch K");
cmp(sfv, tfv, "fetch V");
console.log("post offsets:", { serial: serial.offset, twin: twin.offset, twinRope: twin.ropeOffsetArr.toIntTokens() });
