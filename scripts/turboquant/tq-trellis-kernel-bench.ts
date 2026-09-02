// Per-kernel decode microbench for the packed trellis format (Q2b) on the real
// Qwen3.8-27B MLP geometry, against MLX's stock affine quantized_matmul at
// the same M. Numbers are for THIS machine — label the host when quoting.
//
//   bun scripts/turboquant/tq-trellis-kernel-bench.ts [--k 3] [--m 1] [--reps 20]
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { Trellis } from "../../src/quantize/trellis";
import { TrellisLinear, expandTrellis } from "../../src/model/trellis-linear";

const argv = process.argv.slice(2);
const opt = (k: string, d: string) => { const i = argv.indexOf(`--${k}`); return i >= 0 ? argv[i + 1]! : d; };
const K = Number(opt("k", "3")), M = Number(opt("m", "1")), REPS = Number(opt("reps", "20"));
const HID = 5120, INTER = 17408, T = 256, L = 12;

function timeIt(label: string, fn: () => MlxArray, bytes: number): void {
  for (let i = 0; i < 3; i++) { const y = fn(); y.eval(); y.dispose(); }
  const ts: number[] = [];
  for (let i = 0; i < REPS; i++) {
    const t0 = performance.now(); const y = fn(); y.eval(); ts.push(performance.now() - t0); y.dispose();
  }
  ts.sort((a, b) => a - b);
  const med = ts[ts.length >> 1]!;
  console.log(`${label.padEnd(44)} ${med.toFixed(3)} ms  (${(bytes / med / 1e6).toFixed(0)} GB/s of weight bytes)`);
}

// Encode a random matrix once per geometry (codec at k, real block/T).
function packed(rows: number, cols: number) {
  const tr = new Trellis({ L, K, T, code: "1mad", tailBiting: true });
  const key = ops.randomKey(3n);
  const W = ops.randomNormal([rows, cols], Dtype.float32, 0, 0.02, key);
  ops.evalAll([W]);
  const { rec, codes, scales } = tr.fakeQuantRowsPacked(W, 16384);
  rec.dispose(); W.dispose(); tr.dispose();
  return { codes, scales };
}
const spec = (axis: 0 | 1) => ({ bits: K, groupSize: T, mode: "trellis", trellis: { L, code: "1mad", axis } });

console.log(`k=${K} M=${M} reps=${REPS} · gate/up [${INTER}x${HID}] axis1 · down [${HID}x${INTER}] axis0 (stored [${INTER},${HID}·k/32])`);
const g = packed(INTER, HID);                       // gate: coded along in=5120
const gate = new TrellisLinear(g.codes, g.scales, spec(1) as any, "kernel");
const xg = ops.randomNormal([M, HID], Dtype.float32, 0, 1, ops.randomKey(1n)).astype(Dtype.bfloat16);
timeIt(`trellis reduce  gate k${K} M=${M}`, () => gate.forward(xg), g.codes.nbytes);
timeIt(`trellis expand  gate k${K} (whole tensor)`, () => expandTrellis(g.codes, g.scales, gate.geometry, Dtype.bfloat16), g.codes.nbytes);

const d = packed(INTER, HID);                       // down stored [in=17408, out·k/32]
const down = new TrellisLinear(d.codes, d.scales, spec(0) as any, "kernel");
const xd = ops.randomNormal([M, INTER], Dtype.float32, 0, 1, ops.randomKey(2n)).astype(Dtype.bfloat16);
timeIt(`trellis scatter down k${K} M=${M}`, () => down.forward(xd), d.codes.nbytes);

// Stock affine references at the same shapes.
for (const bits of [3, 4]) {
  const Wg = ops.randomNormal([INTER, HID], Dtype.float32, 0, 0.02, ops.randomKey(5n));
  const qg = ops.quantize(Wg, 64, bits, "affine"); Wg.dispose();
  timeIt(`affine qmm gate ${bits}-bit g64 M=${M}`, () => ops.quantizedMatmul(xg, qg.packed, qg.scales, qg.biases, { bits, groupSize: 64, mode: "affine" }, true), qg.packed.nbytes);
  const Wd = ops.randomNormal([HID, INTER], Dtype.float32, 0, 0.02, ops.randomKey(6n));
  const qd = ops.quantize(Wd, 64, bits, "affine"); Wd.dispose();
  timeIt(`affine qmm down ${bits}-bit g64 M=${M}`, () => ops.quantizedMatmul(xd, qd.packed, qd.scales, qd.biases, { bits, groupSize: 64, mode: "affine" }, true), qd.packed.nbytes);
}
