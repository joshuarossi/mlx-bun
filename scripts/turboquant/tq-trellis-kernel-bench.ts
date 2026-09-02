// Per-kernel decode microbench for the packed trellis format (Q2b) on the real
// Qwen3.8-27B MLP geometry, against MLX's stock affine quantized_matmul at
// the same M. Numbers are for THIS machine — label the host when quoting.
//
//   bun scripts/turboquant/tq-trellis-kernel-bench.ts [--k 3] [--m 1] [--reps 20]
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { Trellis } from "../../src/quantize/trellis";
import { TrellisLinear, expandTrellis, setTrellisVariant, fusedGateUpSwiglu } from "../../src/model/trellis-linear";

const argv = process.argv.slice(2);
const opt = (k: string, d: string) => { const i = argv.indexOf(`--${k}`); return i >= 0 ? argv[i + 1]! : d; };
const K = Number(opt("k", "3")), M = Number(opt("m", "1")), REPS = Number(opt("reps", "20")), PIPE = Number(opt("pipe", "8"));
const HID = 5120, INTER = 17408, T = 256, L = 12;

type Cell = { label: string; fn: () => MlxArray; bytes: number };
/** Interleaved round-robin timing: every rep touches every cell in turn, so
 *  clock/thermal drift lands on all of them; report MIN (the machine's true
 *  cost) and median. */
function timeCells(cells: Cell[]): void {
  for (const c of cells) for (let i = 0; i < 3; i++) { const y = c.fn(); y.eval(); y.dispose(); }
  const ts = cells.map(() => [] as number[]);
  // PIPE calls are queued before one eval, like a compiled decode graph queues
  // its 192 MLP matvecs — the per-call sync overhead of eval-per-call would
  // otherwise dominate a 0.2 ms kernel.
  for (let i = 0; i < REPS; i++) {
    for (let ci = 0; ci < cells.length; ci++) {
      const t0 = performance.now();
      const ys: MlxArray[] = [];
      for (let p = 0; p < PIPE; p++) ys.push(cells[ci]!.fn());
      ops.evalAll(ys);
      ts[ci]!.push((performance.now() - t0) / PIPE);
      for (const y of ys) y.dispose();
    }
  }
  for (let ci = 0; ci < cells.length; ci++) {
    const a = ts[ci]!.sort((x, y) => x - y);
    const min = a[0]!, med = a[a.length >> 1]!;
    console.log(`${cells[ci]!.label.padEnd(44)} min ${min.toFixed(3)} ms · med ${med.toFixed(3)} ms  (${(cells[ci]!.bytes / min / 1e6).toFixed(0)} GB/s at min)`);
  }
}
function timeIt(label: string, fn: () => MlxArray, bytes: number): void { timeCells([{ label, fn, bytes }]); }

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
const g2 = packed(INTER, HID);
const up = new TrellisLinear(g2.codes, g2.scales, spec(1) as any, "kernel");
const xg = ops.randomNormal([M, HID], Dtype.float32, 0, 1, ops.randomKey(1n)).astype(Dtype.bfloat16);
const d = packed(INTER, HID);                       // down stored [in=17408, out·k/32]
const down = new TrellisLinear(d.codes, d.scales, spec(0) as any, "kernel");
const xd = ops.randomNormal([M, INTER], Dtype.float32, 0, 1, ops.randomKey(2n)).astype(Dtype.bfloat16);
const variants = opt("variants", "0,1,2,3").split(",").map(Number);
const cells: Cell[] = [];
for (const v of variants) {
  cells.push({ label: `v${v} trellis reduce  gate k${K} M=${M}`, fn: () => { setTrellisVariant(v); return gate.forward(xg); }, bytes: g.codes.nbytes });
  cells.push({ label: `v${v} trellis fused gate+up+swiglu k${K} M=${M}`, fn: () => { setTrellisVariant(v); return fusedGateUpSwiglu(xg, gate, up); }, bytes: 2 * g.codes.nbytes });
  cells.push({ label: `v${v} trellis scatter down k${K} M=${M}`, fn: () => { setTrellisVariant(v); return down.forward(xd); }, bytes: d.codes.nbytes });
}
// Stock affine references at the same shapes, timed in the same round-robin.
for (const bits of [3, 4]) {
  const Wg = ops.randomNormal([INTER, HID], Dtype.float32, 0, 0.02, ops.randomKey(5n));
  const qg = ops.quantize(Wg, 64, bits, "affine"); Wg.dispose();
  cells.push({ label: `affine qmm gate ${bits}-bit g64 M=${M}`, fn: () => ops.quantizedMatmul(xg, qg.packed, qg.scales, qg.biases, { bits, groupSize: 64, mode: "affine" }, true), bytes: qg.packed.nbytes });
  const Wd = ops.randomNormal([HID, INTER], Dtype.float32, 0, 0.02, ops.randomKey(6n));
  const qd = ops.quantize(Wd, 64, bits, "affine"); Wd.dispose();
  cells.push({ label: `affine qmm down ${bits}-bit g64 M=${M}`, fn: () => ops.quantizedMatmul(xd, qd.packed, qd.scales, qd.biases, { bits, groupSize: 64, mode: "affine" }, true), bytes: qd.packed.nbytes });
}
timeCells(cells);
