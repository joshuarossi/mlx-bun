// Per-kernel decode microbench for the packed trellis format (Q2b) on the real
// Qwen3.8-27B MLP geometry, against MLX's stock affine quantized_matmul at
// the same M. Numbers are for THIS machine — label the host when quoting.
//
//   bun scripts/turboquant/tq-trellis-kernel-bench.ts [--k 3] [--m 1] [--reps 20]
//   ... --model-path <packed artifact> --k 3 --m 5 --skip-affine --json reports/cell.json
//   ... --k 3 --m 4 --variants 6,7 --reference-variant 6 --model-path <packed artifact>
// Add --time-reference to time the built-in reference alongside a custom module.
// Only the selected layer's three packed MLP matrices are materialized.
// This is a kernel diagnostic, not a full-model throughput or quality comparison.
import { createHash } from "node:crypto";
import { mkdirSync } from "node:fs";
import { basename, dirname, resolve } from "node:path";
import { hostname } from "node:os";
import { MlxArray } from "../../src/mlx/array";
import { Dtype, activeMemory, peakMemory, resetPeakMemory } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { Trellis } from "../../src/quantize/trellis";
import * as defaultKernels from "../../src/model/trellis-linear";
import type { TrellisLinear as TrellisLinearType } from "../../src/model/trellis-linear";
import { compiledSwiglu } from "../../src/model/qwen3_5";
import { loadModelConfig, quantFor, type QuantSpec } from "../../src/config";
import { Weights } from "../../src/weights";
import { checkMachine } from "../../src/preflight";

const argv = process.argv.slice(2);
const opt = (k: string, d: string) => { const i = argv.indexOf(`--${k}`); return i >= 0 ? argv[i + 1]! : d; };
const K = Number(opt("k", "3")), M = Number(opt("m", "1")), REPS = Number(opt("reps", "20")), PIPE = Number(opt("pipe", "8"));
const HID = 5120, INTER = 17408, T = 256, L = 12;
if (![2, 3, 4].includes(K) || ![M, REPS, PIPE].every((v) => Number.isSafeInteger(v) && v > 0))
  throw new Error("k must be 2/3/4; m, reps and pipe must be positive integers");
const variants = opt("variants", "6").split(",").map(Number);
if (!variants.length || variants.some((v) => !Number.isInteger(v) || v < 0 || v > 13))
  throw new Error("variants must be a comma-separated list of integers in 0..13; 4 has wrong numerics, 7..13 are experimental");
const modelPath = opt("model-path", "");
const jsonPath = opt("json", "");
const kernelModule = opt("kernel-module", "");
const inputSeed = BigInt(opt("seed", "1"));
const referenceOption = opt("reference-variant", variants.some((v) => v >= 7) ? "6" : "");
if (referenceOption && (!Number.isInteger(Number(referenceOption)) || Number(referenceOption) < 0 || Number(referenceOption) > 13))
  throw new Error("reference-variant must be an integer in 0..13");
const kernelPath = kernelModule ? resolve(kernelModule) : new URL("../../src/model/trellis-linear.ts", import.meta.url).pathname;
const { TrellisLinear, setTrellisVariant, fusedGateUpSwiglu, fusedGateUpEligible, TRELLIS_MATVEC_MAX_M } =
  kernelModule ? await import(kernelPath) as typeof defaultKernels : defaultKernels;
const sha = (data: string | Uint8Array) => createHash("sha256").update(data).digest("hex");
const shell = (args: string[]) => Bun.spawnSync(args, { stdout: "pipe", stderr: "pipe" }).stdout.toString().trim();
const source = { commit: shell(["git", "rev-parse", "HEAD"]),
  diffSha256: sha(shell(["git", "diff", "HEAD", "--", "src", "scripts/turboquant/tq-trellis-kernel-bench.ts"])),
  harnessSha256: sha(await Bun.file(import.meta.path).bytes()),
  kernelModule: kernelPath, kernelSha256: sha(await Bun.file(kernelPath).bytes()),
  sharedKernelSha256: sha(await Bun.file(new URL("../../src/model/trellis-shared-m.ts", import.meta.url)).bytes()),
  scatterKernelSha256: sha(await Bun.file(new URL("../../src/model/trellis-balanced-scatter.ts", import.meta.url)).bytes()),
  sharedScatterKernelSha256: sha(await Bun.file(new URL("../../src/model/trellis-shared-scatter.ts", import.meta.url)).bytes()),
  tiledPrefillKernelSha256: sha(await Bun.file(new URL("../../src/model/trellis-tiled-prefill.ts", import.meta.url)).bytes()),
  splitKPrefillKernelSha256: sha(await Bun.file(new URL("../../src/model/trellis-splitk-prefill.ts", import.meta.url)).bytes()) };
const machineBefore = checkMachine();
if (!machineBefore.ok) console.warn(`Diagnostic only: ${machineBefore.problems.join("; ")}`);
let artifact: unknown = { synthetic: true, seed: 3 };
let weights: Weights | undefined;
const owned: MlxArray[] = [];
const rows: { label: string; weightBytes: number; samplesMs: number[]; medianMs: number }[] = [];
const skipped: string[] = [];
const validation: { label: string; mismatches: number; maxAbsError: number }[] = [];

function compare(label: string, actual: MlxArray, expected: MlxArray): void {
  try {
    const a = actual.toFloat32(), b = expected.toFloat32();
    if (a.length !== b.length) throw new Error("validation output length mismatch");
    let mismatches = 0, maxAbsError = 0;
    for (let i = 0; i < a.length; i++) {
      if (!Number.isFinite(a[i]) || !Number.isFinite(b[i])) throw new Error("nonfinite validation output");
      if (!Object.is(a[i], b[i])) mismatches++;
      maxAbsError = Math.max(maxAbsError, Math.abs(a[i]! - b[i]!));
    }
    validation.push({ label, mismatches, maxAbsError });
  } finally { actual.dispose(); expected.dispose(); }
}

type Cell = { label: string; fn: () => MlxArray; bytes: number };
/** Alternate cell order each round; retain every host-wall-time sample.
 * Includes graph construction and required evals, not isolated GPU duration. */
function timeCells(cells: Cell[]): void {
  for (const c of cells) for (let i = 0; i < 3; i++) { const y = c.fn(); y.eval(); y.dispose(); }
  const ts = cells.map(() => [] as number[]);
  // PIPE calls are queued before one eval, like a compiled decode graph queues
  // its 192 MLP matvecs — the per-call sync overhead of eval-per-call would
  // otherwise dominate a 0.2 ms kernel.
  for (let i = 0; i < REPS; i++) {
    for (let offset = 0; offset < cells.length; offset++) {
      const ci = i % 2 ? cells.length - 1 - offset : offset;
      const t0 = performance.now();
      const ys: MlxArray[] = [];
      for (let p = 0; p < PIPE; p++) ys.push(cells[ci]!.fn());
      ops.evalAll(ys);
      ts[ci]!.push((performance.now() - t0) / PIPE);
      for (const y of ys) y.dispose();
    }
  }
  for (let ci = 0; ci < cells.length; ci++) {
    const a = [...ts[ci]!].sort((x, y) => x - y);
    const med = (a[Math.floor((a.length - 1) / 2)]! + a[Math.floor(a.length / 2)]!) / 2;
    rows.push({ label: cells[ci]!.label, weightBytes: cells[ci]!.bytes, samplesMs: ts[ci]!, medianMs: med });
    console.log(`${cells[ci]!.label.padEnd(52)} median ${med.toFixed(3)} ms`);
  }
}

// Encode a random matrix once per geometry (codec at k, real block/T).
function packed(rows: number, cols: number) {
  const tr = new Trellis({ L, K, T, code: "1mad", tailBiting: true });
  const key = ops.randomKey(3n);
  const W = ops.randomNormal([rows, cols], Dtype.float32, 0, 0.02, key);
  ops.evalAll([W]);
  const { rec, codes, scales } = tr.fakeQuantRowsPacked(W, 16384);
  rec.dispose(); W.dispose(); tr.dispose();
  key.dispose();
  owned.push(codes, scales);
  return { codes, scales };
}
const spec = (axis: 0 | 1): QuantSpec => ({ bits: K, groupSize: T, mode: "trellis", trellis: { L, code: "1mad", axis } });

async function matrices(): Promise<{ gate: TrellisLinearType; up: TrellisLinearType; down: TrellisLinearType }> {
  if (!modelPath) {
    const g = packed(INTER, HID), u = packed(INTER, HID), d = packed(INTER, HID);
    return { gate: new TrellisLinear(g.codes, g.scales, spec(1), "kernel"),
      up: new TrellisLinear(u.codes, u.scales, spec(1), "kernel"),
      down: new TrellisLinear(d.codes, d.scales, spec(0), "kernel") };
  }
  const config = await loadModelConfig(modelPath);
  weights = await Weights.open(modelPath);
  const requestedLayer = opt("layer", "");
  const gateName = weights.tensorNames.find((name) => {
    const match = name.match(/\.layers\.(\d+)\.mlp\.gate_proj\.weight$/);
    const q = quantFor(config.quantization, name.slice(0, -7));
    return match && (!requestedLayer || Number(match[1]) === Number(requestedLayer)) &&
      q?.mode === "trellis" && q.bits === K;
  });
  if (!gateName) throw new Error(`no packed gate matrix at k=${K}${requestedLayer ? `, layer=${requestedLayer}` : ""}`);
  const prefix = gateName.slice(0, -"gate_proj.weight".length);
  const tensors: { name: string; sha256: string; bytes: number }[] = [];
  const load = (role: string) => {
    const name = prefix + role;
    const q = quantFor(config.quantization, name);
    if (q?.mode !== "trellis") throw new Error(`${name} is not packed trellis`);
    const codes = weights!.tensor(`${name}.weight`), scales = weights!.tensor(`${name}.scales`);
    ops.evalAll([codes, scales]);
    for (const [suffix, arr] of [["weight", codes], ["scales", scales]] as const)
      tensors.push({ name: `${name}.${suffix}`, sha256: sha(arr.rawBytesView()), bytes: arr.nbytes });
    return new TrellisLinear(codes, scales, q, "kernel");
  };
  const gate = load("gate_proj"), up = load("up_proj"), down = load("down_proj");
  if (gate.inFeatures !== HID || gate.outFeatures !== INTER || up.inFeatures !== HID ||
      up.outFeatures !== INTER || down.inFeatures !== INTER || down.outFeatures !== HID)
    throw new Error("selected layer does not have the Qwen3.8-27B MLP geometry");
  artifact = { path: resolve(modelPath), configSha256: sha(await Bun.file(`${modelPath}/config.json`).bytes()),
    prefix, geometry: { gate: gate.geometry, up: up.geometry, down: down.geometry }, tensors };
  return { gate, up, down };
}

try {
const { gate, up, down } = await matrices();
console.log(`M=${M} reps=${REPS} · gate [${gate.outFeatures}x${gate.inFeatures}] k${gate.geometry.k} axis${gate.geometry.axis} · down [${down.outFeatures}x${down.inFeatures}] k${down.geometry.k} axis${down.geometry.axis}`);
const keyG = ops.randomKey(inputSeed), keyD = ops.randomKey(inputSeed + 1n);
const xg = ops.randomNormal([M, HID], Dtype.bfloat16, 0, 1, keyG);
const xd = ops.randomNormal([M, INTER], Dtype.bfloat16, 0, 1, keyD);
owned.push(keyG, keyD, xg, xd);
ops.evalAll([xg, xd]);
const weightBytes = (linear: TrellisLinearType) => linear.codes.nbytes + linear.scales.nbytes;
const mlp = () => {
  let mid: MlxArray;
  if (M <= TRELLIS_MATVEC_MAX_M && fusedGateUpEligible(gate, up)) mid = fusedGateUpSwiglu(xg, gate, up);
  else {
    const g = gate.forward(xg), u = up.forward(xg);
    try { mid = compiledSwiglu(g, u); } finally { g.dispose(); u.dispose(); }
  }
  try { return down.forward(mid); } finally { mid.dispose(); }
};
const cells: Cell[] = [];
for (const v of variants) {
  if (kernelModule || referenceOption) {
    const referenceVariant = referenceOption ? Number(referenceOption) : v;
    const check = (label: string, actualFn: () => MlxArray, expectedFn: () => MlxArray) => {
      setTrellisVariant(v);
      const actual = actualFn();
      let expected: MlxArray | undefined;
      try {
        defaultKernels.setTrellisVariant(referenceVariant);
        expected = expectedFn();
        compare(`${label} vs v${referenceVariant}`, actual, expected);
      } finally { actual.dispose(); expected?.dispose(); setTrellisVariant(v); }
    };
    for (const [role, linear, input] of [["gate", gate, xg], ["up", up, xg], ["down", down, xd]] as const) {
      const reference = new defaultKernels.TrellisLinear(linear.codes, linear.scales, linear.spec, "kernel");
      check(`v${v} ${role} M=${M}`, () => linear.forward(input), () => reference.forward(input));
    }
    const rg = new defaultKernels.TrellisLinear(gate.codes, gate.scales, gate.spec, "kernel");
    const ru = new defaultKernels.TrellisLinear(up.codes, up.scales, up.spec, "kernel");
    if (M <= Math.min(TRELLIS_MATVEC_MAX_M, defaultKernels.TRELLIS_MATVEC_MAX_M) && fusedGateUpEligible(gate, up))
      check(`v${v} fused gate/up M=${M}`, () => fusedGateUpSwiglu(xg, gate, up), () => defaultKernels.fusedGateUpSwiglu(xg, rg, ru));
    const rd = new defaultKernels.TrellisLinear(down.codes, down.scales, down.spec, "kernel");
    check(`v${v} complete MLP M=${M}`, mlp, () => {
      let mid: MlxArray;
      if (M <= defaultKernels.TRELLIS_MATVEC_MAX_M && defaultKernels.fusedGateUpEligible(rg, ru))
        mid = defaultKernels.fusedGateUpSwiglu(xg, rg, ru);
      else {
        const g = rg.forward(xg), u = ru.forward(xg);
        try { mid = compiledSwiglu(g, u); } finally { g.dispose(); u.dispose(); }
      }
      try { return rd.forward(mid); } finally { mid.dispose(); }
    });
  }
  const path = kernelModule ? `custom:${basename(kernelPath)}`
    : M <= TRELLIS_MATVEC_MAX_M ? "packed" : v >= 11 ? "prefill dispatch" : "expand+matmul";
  cells.push({ label: `v${v} ${path} gate k${gate.geometry.k} M=${M}`, fn: () => { setTrellisVariant(v); return gate.forward(xg); }, bytes: weightBytes(gate) });
  if (M <= TRELLIS_MATVEC_MAX_M && fusedGateUpEligible(gate, up))
    cells.push({ label: `v${v} fused gate+up+swiglu k${K} M=${M}`, fn: () => { setTrellisVariant(v); return fusedGateUpSwiglu(xg, gate, up); }, bytes: weightBytes(gate) + weightBytes(up) });
  else skipped.push(`v${v} fused gate/up: M=${M} or incompatible geometry`);
  cells.push({ label: `v${v} separate gate+up+swiglu M=${M}`, fn: () => {
    setTrellisVariant(v);
    const g = gate.forward(xg), u = up.forward(xg);
    try { return compiledSwiglu(g, u); } finally { g.dispose(); u.dispose(); }
  }, bytes: weightBytes(gate) + weightBytes(up) });
  cells.push({ label: `v${v} ${path} down k${down.geometry.k} M=${M}`, fn: () => { setTrellisVariant(v); return down.forward(xd); }, bytes: weightBytes(down) });
  cells.push({ label: `v${v} complete MLP M=${M}`, fn: () => { setTrellisVariant(v); return mlp(); },
    bytes: weightBytes(gate) + weightBytes(up) + weightBytes(down) });
}
if (argv.includes("--time-reference")) {
  const v = referenceOption ? Number(referenceOption) : variants[0]!;
  const rg = new defaultKernels.TrellisLinear(gate.codes, gate.scales, gate.spec, "kernel");
  const ru = new defaultKernels.TrellisLinear(up.codes, up.scales, up.spec, "kernel");
  const rd = new defaultKernels.TrellisLinear(down.codes, down.scales, down.spec, "kernel");
  const referenceMid = () => {
    if (M <= defaultKernels.TRELLIS_MATVEC_MAX_M && defaultKernels.fusedGateUpEligible(rg, ru))
      return defaultKernels.fusedGateUpSwiglu(xg, rg, ru);
    const g = rg.forward(xg), u = ru.forward(xg);
    try { return compiledSwiglu(g, u); } finally { g.dispose(); u.dispose(); }
  };
  cells.push({ label: `v${v} built-in reference gate k${gate.geometry.k} M=${M}`, bytes: weightBytes(gate),
    fn: () => { defaultKernels.setTrellisVariant(v); return rg.forward(xg); } });
  cells.push({ label: `v${v} built-in reference gate+up+swiglu M=${M}`, bytes: weightBytes(gate) + weightBytes(up),
    fn: () => { defaultKernels.setTrellisVariant(v); return referenceMid(); } });
  cells.push({ label: `v${v} built-in reference down k${down.geometry.k} M=${M}`, bytes: weightBytes(down),
    fn: () => { defaultKernels.setTrellisVariant(v); return rd.forward(xd); } });
  cells.push({ label: `v${v} built-in reference complete MLP M=${M}`,
    bytes: weightBytes(gate) + weightBytes(up) + weightBytes(down), fn: () => {
      defaultKernels.setTrellisVariant(v);
      const mid = referenceMid();
      try { return rd.forward(mid); } finally { mid.dispose(); }
    } });
}
// Stock affine references at the same shapes, timed in the same round-robin.
for (const bits of argv.includes("--skip-affine") ? [] : [3, 4]) {
  const Wg = ops.randomNormal([INTER, HID], Dtype.float32, 0, 0.02, ops.randomKey(5n));
  const qg = ops.quantize(Wg, 64, bits, "affine"); Wg.dispose();
  owned.push(qg.packed, qg.scales, qg.biases);
  cells.push({ label: `synthetic affine gate ${bits}-bit g64 M=${M}`, fn: () => ops.quantizedMatmul(xg, qg.packed, qg.scales, qg.biases, { bits, groupSize: 64, mode: "affine" }, true), bytes: qg.packed.nbytes + qg.scales.nbytes + qg.biases.nbytes });
  const Wd = ops.randomNormal([HID, INTER], Dtype.float32, 0, 0.02, ops.randomKey(6n));
  const qd = ops.quantize(Wd, 64, bits, "affine"); Wd.dispose();
  owned.push(qd.packed, qd.scales, qd.biases);
  cells.push({ label: `synthetic affine down ${bits}-bit g64 M=${M}`, fn: () => ops.quantizedMatmul(xd, qd.packed, qd.scales, qd.biases, { bits, groupSize: 64, mode: "affine" }, true), bytes: qd.packed.nbytes + qd.scales.nbytes + qd.biases.nbytes });
}
resetPeakMemory();
timeCells(cells);
if (jsonPath) {
  const report = { kind: "kernel-diagnostic", fullModelMeasurement: false,
    host: hostname(), chip: shell(["sysctl", "-n", "machdep.cpu.brand_string"]),
    ramBytes: Number(shell(["sysctl", "-n", "hw.memsize"])), bun: Bun.version, source,
    machineBefore, machineAfter: checkMachine(), artifact, m: M, variants, reps: REPS, pipe: PIPE,
    input: { distribution: "synthetic bf16 normal activations", seed: inputSeed.toString() },
    pipeline: "independent outputs, shared input and weights; complete MLP retains gate/up -> activation -> down dependencies; the selected kernel module controls its evaluation boundaries",
    activeBytes: activeMemory(), peakBytes: peakMemory(), validation, skipped, rows };
  mkdirSync(dirname(resolve(jsonPath)), { recursive: true });
  await Bun.write(jsonPath, JSON.stringify(report, null, 2) + "\n");
}
} finally {
  setTrellisVariant(null);
  defaultKernels.setTrellisVariant(null);
  for (const arr of owned) arr.dispose();
  weights?.dispose();
}
