// Run through the machine's gpu.sh. Synthetic completed-work screening only;
// this does not qualify real-model numerical behavior or serving performance.
import { createHash } from "node:crypto";
import { readFileSync, writeFileSync } from "node:fs";
import { hostname } from "node:os";
import { dirname, join, relative, resolve } from "node:path";
import { parseArgs } from "node:util";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype, LIBMLXC_PATH, MLX_VERSION, deviceArchitecture } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { fusedDelta, referenceDelta, type DeltaInput } from "./delta";
import { ChunkedDelta, type RecurrenceInput } from "./chunked";
import { retainedBaseline, retainedFirst } from "./prefix";
import { gatedDeltaUpdate } from "../../src/kernels/delta/gated";
import { mppAffine } from "./mpp";
import { route, referenceRoute, ExpertPlan, sortedPlan } from "./moe";
import { realDelta } from "./real-delta";

const { values } = parseArgs({ options: { out: { type: "string" }, quick: { type: "boolean" },
  only: { type: "string", default: "fused,prefix,chunked,mpp,moe" }, strata: { type: "string" }, model: { type: "string" }, help: { type: "boolean" } } });
if (values.help) {
  console.log(`GPU-locked kernel screen (no serving changes):
  gpu.sh bun --no-env-file packages/inference/scripts/strata/screen.ts --strata /path/to/Strata --out /external/report.json
  --only fused,prefix,chunked,mpp,moe  Select experiments (all by default).
  --only real --model /cached/model  Compare the first real recurrent layer, after a 16-token prefix.
  --only real-split --model /model  Sweep narrower fusion partitions with a separate output norm.
  --quick                           Reduce synthetic cases, not correctness thresholds.
Timings complete fresh output graphs; real-layer results also include native compiled replay.
Chunked state assumes an alternate cache layout prepared once outside timing. Expert-plan timings compare
different plan formats and exclude expert GEMMs. MPP uses fp16 decoded weights and changes rounding.
Real-layer inputs are checkpoint embeddings plus layer-0 RMSNorm, not a whole-model trajectory.
Existing report files are never overwritten. Reports must stay outside the source tree.`);
  process.exit(0);
}
const root = resolve(import.meta.dir, "../../../..");
if (values.out) {
  const path = relative(root, resolve(values.out));
  if (!path.startsWith("../")) throw new Error("report must be outside the source tree");
}
const selected = new Set(values.only!.split(","));
for (const name of selected) if (!["fused", "prefix", "chunked", "mpp", "moe", "real", "real-split"].includes(name)) throw new Error(`unknown experiment ${name}`);
const hash = (x: Uint8Array | string) => createHash("sha256").update(x).digest("hex");
export const median = (v: number[]) => [...v].sort((a, b) => a - b)[Math.floor(v.length / 2)]!;
export function tensor(shape: number[], dtype: Dtype, seed: number, scale = 1, shift = 0): MlxArray {
  using wide = MlxArray.fromFloat32(Float32Array.from({ length: shape.reduce((a, b) => a * b, 1) },
    (_, i) => shift + scale * (Math.sin(i * 1.72 + seed) + Math.cos(i * 0.23 - seed))), shape);
  return wide.astype(dtype);
}
export function difference(a: MlxArray, b: MlxArray) {
  if (a.dtype !== b.dtype || JSON.stringify(a.shape) !== JSON.stringify(b.shape)) throw new Error("incompatible comparison");
  using ac = ops.contiguous(a); using bc = ops.contiguous(b);
  const ab = ac.rawBytes(), bb = bc.rawBytes();
  const av = ac.toFloat32(), bv = bc.toFloat32();
  let max = 0, sum = 0, ref = 0, unequal = 0, nonfinite = 0;
  for (let i = 0; i < av.length; ++i) {
    const e = Math.abs(av[i]! - bv[i]!);
    max = Math.max(max, e); sum += e * e; ref += bv[i]! * bv[i]!;
    unequal += Number(av[i] !== bv[i]); nonfinite += Number(!Number.isFinite(e));
  }
  return { exact: Buffer.from(ab).equals(Buffer.from(bb)), max, relativeRms: Math.sqrt(sum / Math.max(ref, 1e-30)), unequal, nonfinite };
}
export function release(xs: MlxArray[]) { for (const x of xs) x.dispose(); }
export function completed(fn: () => MlxArray[], count: number): number {
  const start = performance.now();
  const live: MlxArray[] = [];
  try {
    for (let i = 0; i < count; ++i) live.push(...fn());
    ops.evalAll(live);
    return (performance.now() - start) / count;
  } finally { release(live); }
}
export function paired(a: () => MlxArray[], b: () => MlxArray[], count = 8, rounds = 7) {
  for (let i = 0; i < 3; ++i) { completed(a, count); completed(b, count); }
  const baseline: number[] = [], candidate: number[] = [];
  for (let i = 0; i < rounds; ++i) {
    if (i % 2 === 0) { baseline.push(completed(a, count)); candidate.push(completed(b, count)); }
    else { candidate.push(completed(b, count)); baseline.push(completed(a, count)); }
  }
  return { baselineMs: median(baseline), candidateMs: median(candidate), ratio: median(candidate) / median(baseline), baseline, candidate };
}
function input(B: number, S: number, hk: number, hv: number, dtype: Dtype): DeltaInput {
  const C = (2 * hk + hv) * 128;
  return { qkv: tensor([B, S, C], dtype, 1), history: tensor([B, 3, C], dtype, 2),
    conv: tensor([C, 4, 1], dtype, 3, .15), a: tensor([B, S, hv], dtype, 4), b: tensor([B, S, hv], dtype, 5),
    aLog: tensor([hv], Dtype.float32, 6, .3), dt: tensor([hv], dtype, 7),
    state: tensor([B, hv, 128, 128], Dtype.float32, 8, .03), z: tensor([B, S, hv, 128], dtype, 9),
    norm: tensor([128], dtype, 10, .2, 1), qScale: tensor([128], dtype, 0, 0, 1 / 128),
    kScale: tensor([128], dtype, 0, 0, 128 ** -.5), hk, hv };
}
const cells: unknown[] = [];
if (selected.has("fused"))
for (const dtype of [Dtype.bfloat16, ...(values.quick ? [] : [Dtype.float32])]) {
  for (const [B, S, hk, hv] of (values.quick ? [[1, 1, 4, 16], [1, 4, 4, 16]] :
    [[1, 1, 4, 16], [1, 4, 4, 16], [2, 1, 4, 16], [2, 8, 4, 16], [1, 1, 16, 48], [1, 8, 16, 48]])) {
    const x = input(B!, S!, hk!, hv!, dtype);
    try {
      ops.evalAll(Object.values(x).filter((v): v is MlxArray => v instanceof MlxArray));
      const ref = referenceDelta(x), candidate = fusedDelta(x, true);
      try {
        const diff = ref.map((r, i) => difference(candidate[i]!, r));
        const cell = { experiment: "fused-delta", B, S, hk, hv, dtype, diff,
          timing: paired(() => referenceDelta(x), () => fusedDelta(x), 8, values.quick ? 3 : 7),
          snapshotTiming: paired(() => fusedDelta(x), () => fusedDelta(x, true), 8, values.quick ? 3 : 7) };
        console.log(JSON.stringify(cell)); cells.push(cell);
      } finally { release([...ref, ...candidate]); }
    } finally { for (const v of Object.values(x)) if (v instanceof MlxArray) v.dispose(); }
  }
}
function recurrentInput(B: number, T: number, hk: number, hv: number): RecurrenceInput {
  const dtype = Dtype.bfloat16;
  return { q: tensor([B, T, hk, 128], dtype, 1, .01), k: tensor([B, T, hk, 128], dtype, 2, .07),
    v: tensor([B, T, hv, 128], dtype, 3, .4), a: tensor([B, T, hv], dtype, 4), b: tensor([B, T, hv], dtype, 5),
    aLog: tensor([hv], Dtype.float32, 6, .3), dt: tensor([hv], dtype, 7), state: tensor([B, hv, 128, 128], Dtype.float32, 8, .03) };
}
if (selected.has("prefix")) {
  for (const [B, S, lengths] of [[1, 4, [1]], [1, 4, [2]], [1, 8, [4]], [2, 8, [1, 5]]] as const) {
    const x = recurrentInput(B, S, 16, 48);
    try {
      ops.evalAll(Object.values(x));
      const keep = [...lengths];
      const a = retainedBaseline(x, keep), b = retainedFirst(x, keep);
      try {
        const cell = { experiment: "first-state", B, S, keep, diff: a.map((v, i) => difference(b[i]!, v)),
          timing: paired(() => retainedBaseline(x, keep), () => retainedFirst(x, keep), 8, values.quick ? 3 : 7) };
        console.log(JSON.stringify(cell)); cells.push(cell);
      } finally { release([...a, ...b]); }
    } finally { release(Object.values(x)); }
  }
}
if (selected.has("chunked")) {
  if (!values.strata) throw new Error("chunked requires --strata /path/to/Strata");
  using operation = new ChunkedDelta(values.strata);
  for (const T of (values.quick ? [37, 128] : [37, 128, 512, 2048])) {
    const x = recurrentInput(1, T, 16, 48);
    try {
      ops.evalAll(Object.values(x));
      using stateView = ops.transposeAxes(x.state, [3, 1, 2, 0]);
      using state = ops.contiguous(stateView);
      state.eval();
      const candidate = () => operation.apply({ ...x, state });
      const baseline = () => gatedDeltaUpdate(x.q, x.k, x.v, x.a, x.b, x.aLog, x.dt, x.state);
      const a = baseline(), b = candidate();
      try {
        using restored = ops.transposeAxes(b[1]!, [3, 1, 2, 0]);
        const cell = { experiment: "chunked-delta", T, sourceSha256: operation.sha256,
          diff: [difference(b[0]!, a[0]!), difference(restored, a[1]!)],
          timing: paired(baseline, candidate, 1, values.quick ? 3 : 7) };
        console.log(JSON.stringify(cell)); cells.push(cell);
      } finally { release([...a, ...b]); }
    } finally { release(Object.values(x)); }
  }
}
if (selected.has("mpp")) {
  for (const [M, N, K] of (values.quick ? [[16, 256, 512], [64, 1024, 1024]] : [[16, 256, 512], [64, 1024, 1024], [64, 6144, 5120], [256, 6144, 5120]])) {
    using x = tensor([M!, K!], Dtype.float16, 1, .3);
    using w = tensor([N!, K!], Dtype.float16, 2, .1);
    const quant = ops.quantize(w, 64, 4);
    try {
      ops.evalAll([x, ...Object.values(quant)]);
      const baseline = () => [ops.quantizedMatmul(x, quant.packed, quant.scales, quant.biases, { bits: 4, groupSize: 64, mode: "affine" }, true)];
      const candidate = () => mppAffine(x, quant);
      const a = baseline(), b = candidate();
      try {
        const cell = { experiment: "mpp-affine", M, N, K, diff: difference(b[0]!, a[0]!), timing: paired(baseline, candidate, 4) };
        console.log(JSON.stringify(cell)); cells.push(cell);
      } finally { release([...a, ...b]); }
    } catch (error) {
      const cell = { experiment: "mpp-affine", M, N, K, error: String(error) };
      console.log(JSON.stringify(cell)); cells.push(cell);
    } finally { release(Object.values(quant)); }
  }
}
if (selected.has("moe")) {
  for (const T of [1, 8, 128]) {
    using logits = tensor([T, 512], Dtype.float32, 1, 2);
    logits.eval();
    const a = referenceRoute(logits, 10), b = route(logits, 10);
    try {
      const ids = (v: MlxArray) => { using contiguous = ops.contiguous(v); return Array.from(contiguous.toIntTokens()); };
      const ai = ids(a[0]!), bi = ids(b[0]!), aw = a[1]!.toFloat32(), bw = b[1]!.toFloat32();
      let same = true, maxWeight = 0;
      let mismatch: unknown;
      for (let row = 0; row < T; ++row) {
        const weights = new Map(Array.from({ length: 10 }, (_, k) => [ai[row * 10 + k]!, aw[row * 10 + k]!]));
        for (let k = 0; k < 10; ++k) {
          const v = weights.get(bi[row * 10 + k]!);
          if (v === undefined) {
            same = false;
            if (!mismatch) mismatch = { row, reference: ai.slice(row * 10, row * 10 + 10), candidate: bi.slice(row * 10, row * 10 + 10),
              cpu: Array.from(logits.toFloat32().slice(row * 512, (row + 1) * 512), (v, id) => ({ v, id })).sort((a, b) => b.v - a.v).slice(0, 10) };
          }
          else maxWeight = Math.max(maxWeight, Math.abs(v - bw[row * 10 + k]!));
        }
      }
      const cell = { experiment: "router-tail", T, selectedExpertsEqual: same, mismatch, maxWeightDifference: maxWeight,
        timing: paired(() => referenceRoute(logits, 10), () => route(logits, 10)) };
      console.log(JSON.stringify(cell)); cells.push(cell);
    } finally { release([...a, ...b]); }
  }
  if (!values.strata) throw new Error("expert plan requires --strata /path/to/Strata");
  using plan = new ExpertPlan(values.strata);
  for (const T of (values.quick ? [128] : [128, 512, 2048])) {
    const E = 512, TOP = 10;
    const hostIds = Int32Array.from({ length: T * TOP }, (_, i) => (Math.floor(i / TOP) * 17 + (i % TOP) * 43) % E);
    using ids = MlxArray.fromInt32(hostIds, [T, TOP]);
    using weights = tensor([T, TOP], Dtype.float32, 4, .1, .2);
    ops.evalAll([ids, weights]);
    const result = plan.apply(ids, weights, E, TOP);
    try {
      const positions = result[0]!.toIntTokens(), tokens = result[1]!.toIntTokens(), sortedWeights = result[2]!.toFloat32();
      const expectedWeights = weights.toFloat32(), starts = result[3]!.toIntTokens();
      const expected: number[][] = Array.from({ length: E }, () => []);
      for (let i = 0; i < hostIds.length; ++i) expected[hostIds[i]!]!.push(i);
      let correct = true, offset = 0;
      for (let e = 0; e < E; ++e) {
        correct &&= starts[e] === offset;
        for (let rank = 0; rank < expected[e]!.length; ++rank) {
          const i = expected[e]![rank]!, p = offset + rank;
          correct &&= positions[i] === p && tokens[p] === Math.floor(i / TOP) && sortedWeights[p] === expectedWeights[i];
        }
        offset += Math.ceil(expected[e]!.length / 16) * 16;
      }
      const cell = { experiment: "expert-plan", T, exactStablePlacement: correct, paddedRows: offset, sourceSha256: plan.sha256,
        timing: paired(() => sortedPlan(ids, weights, TOP), () => plan.apply(ids, weights, E, TOP), 4) };
      console.log(JSON.stringify(cell)); cells.push(cell);
    } finally { release(result); }
  }
}
for (const name of ["real", "real-split"]) if (selected.has(name)) {
  if (!values.model) throw new Error("real requires --model /path/to/cached/checkpoint");
  cells.push(...await realDelta(values.model, { difference, paired }, name === "real-split"));
}
const report = { schema: 1, kind: "kernel-screen", date: new Date().toISOString(), host: hostname(), architecture: deviceArchitecture(),
  acceptance: { fusedAndPrefix: "exact output and states", chunked: "finite, output relative RMS <=2e-4, state <=1e-4",
    mpp: "finite, output relative RMS <=2e-3", router: "same expert set, weights max difference <=1e-6", expertPlan: "exact stable CPU placement",
    scope: "only these inputs; no real-model acceptance for altered-rounding paths" },
  command: process.argv, timing: "completed graph construction + execution, alternating paired rounds; compiledReplay reported separately",
  environment: Object.fromEntries(["MLX_MAX_OPS_PER_BUFFER", "MLX_MAX_MB_PER_BUFFER", "MLX_BUN_LIBMLXC"].map(k => [k, process.env[k]])),
  machine: Bun.spawnSync(["/usr/sbin/sysctl", "machdep.cpu.brand_string", "hw.memsize", "kern.osversion"]).stdout.toString().trim(),
  bun: Bun.version, mlx: MLX_VERSION, native: Object.fromEntries(["libmlxc.dylib", "libmlx.dylib", "mlx.metallib"].map(n => [n, hash(readFileSync(join(dirname(LIBMLXC_PATH), n)))])),
  source: Bun.spawnSync(["git", "-C", root, "rev-parse", "HEAD"]).stdout.toString().trim(),
  strataRevision: values.strata ? Bun.spawnSync(["git", "-C", values.strata, "rev-parse", "HEAD"]).stdout.toString().trim() : undefined,
  references: Object.fromEntries(["kernels/delta/gated.ts", "kernels/delta/state.ts", "kernels/delta/silu-rms-heads.ts", "kernels/gated-rms-norm.ts"].map(n => [n, hash(readFileSync(resolve(import.meta.dir, "../../src", n)))])),
  scripts: Object.fromEntries(["delta.ts", "screen.ts", "prefix.ts", "chunked.ts", "source.ts", "mpp.ts", "moe.ts", "real-delta.ts"].map(name => [name, hash(readFileSync(`${import.meta.dir}/${name}`))])), cells };
if (values.out) writeFileSync(values.out, JSON.stringify(report, null, 2) + "\n", { flag: "wx" });
type Check = ReturnType<typeof difference>;
type Cell = { experiment: string; diff?: Check[] | Check; compiledDiff?: Check[]; firstState?: Check;
  error?: string; selectedExpertsEqual?: boolean; maxWeightDifference?: number; exactStablePlacement?: boolean };
const failed = (cells as Cell[]).filter(c => {
  if (c.error) return true;
  if (c.experiment === "router-tail") return !c.selectedExpertsEqual || c.maxWeightDifference! > 1e-6;
  if (c.experiment === "expert-plan") return !c.exactStablePlacement;
  const diffs = Array.isArray(c.diff) ? c.diff : c.diff ? [c.diff] : [];
  if (c.experiment === "chunked-delta") return diffs.some((d, i) => d.nonfinite || d.relativeRms > (i === 0 ? 2e-4 : 1e-4));
  if (c.experiment === "mpp-affine") return diffs.some(d => d.nonfinite || d.relativeRms > 2e-3);
  return [...diffs, ...(c.compiledDiff ?? []), ...(c.firstState ? [c.firstState] : [])].some(d => !d.exact || d.nonfinite);
});
if (failed.length) throw new Error(`screen correctness failed: ${failed.map(c => c.experiment).join(", ")}; see saved report`);
