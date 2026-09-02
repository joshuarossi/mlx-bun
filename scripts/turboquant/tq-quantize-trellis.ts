// Q2a: rotated (γ+R1) trunk + QTIP-style trellis-coded quantization of the 192
// MLP tensors, affine-quantized everything else per the SHIPPED COMPACT
// allocation (base 3-bit g64; 4-bit for embed/lm_head/all attention; vision
// bf16). Fake-quant: the trellis tensors are decoded back to bf16 and written
// bf16 with a `false` entry in the quantization block, exactly like vision, so
// stock mlx-lm loads/streams the artifact unchanged.
//
// Fold machinery, γ+1/zeros convention and streaming shard walk are copied from
// tq-quantize-alloc.ts (same checkpoint family). Codec: tq-trellis.ts.
//
//   bun scripts/turboquant/tq-quantize-trellis.ts <src> <out> \
//       [--L 12] [--k 3] [--block 256] [--batch 16384] [--no-tail-biting]
//       [--no-trellis] [--no-rotate] [--layers N] [--probe] [--dry-run]
//       [--ldlq <hdir>] [--k-map <trellis-kmap.json> [--k-budget 3.00]]
//
// --k-map: per-tensor k in {2,3,4} (mixed precision) from a sensitivity-derived
// allocation file (reports/qwen38-allocation/trellis-kmap.json: budgets[<bpw>]
// .kmap maps `model.layers.N.mlp.{gate,up,down}_proj` -> k). Every in-scope
// MLP tensor must be listed; --k is the uniform fallback when no map is given.

import { existsSync, mkdirSync, copyFileSync, writeFileSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { Weights } from "../../src/weights";
import { ptr, read } from "bun:ffi";
import { MlxArray as Arr, MlxArray, cpuStream, gpuStream } from "../../src/mlx/array";
import { C, Dtype, clearCache, activeMemory, cacheMemory, peakMemory } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { quantize, dequantize } from "../../src/mlx/ops";
import { QwenFoldContext, type FoldOp } from "../../src/quantize/rotate";
import { ShardedWriter } from "../../src/quantize/safetensors-writer";
import {
  buildQuantizationBlock, writeQuantizedConfig, type PerLayerEntry,
} from "../../src/quantize/config-writer";
import { Trellis } from "./tq-trellis";

// ---------------------------------------------------------------- args -----
const argv = process.argv.slice(2);
const positional = argv.filter((a) => !a.startsWith("--") && !isValueOf(argv, a));
function isValueOf(args: string[], a: string): boolean {
  const i = args.indexOf(a);
  return i > 0 && args[i - 1]!.startsWith("--");
}
const [srcDir, outDir] = positional;
const opt = (name: string, dflt: string): string => {
  const i = argv.indexOf(`--${name}`);
  return i > -1 ? argv[i + 1]! : dflt;
};
const flag = (name: string): boolean => argv.includes(`--${name}`);
if (!srcDir || (!outDir && !flag("probe") && !flag("ldlq-selftest"))) {
  console.error("usage: bun scripts/turboquant/tq-quantize-trellis.ts <src> <out> [flags]");
  process.exit(1);
}
const seed = Number(opt("seed", "42"));
const groupSize = 64 as const;
const BASE_BITS = 3;          // shipped-compact base
const PROT_BITS = 4;          // shipped-compact protection tier (embed/head/attn)
const TRELLIS_L = Number(opt("L", "12"));
const TRELLIS_K = Number(opt("k", "3"));
const BLOCK_T = Number(opt("block", "256"));
const BATCH = Number(opt("batch", "16384"));
const tailBiting = !flag("no-tail-biting");
const useTrellis = !flag("no-trellis");
const noRotate = flag("no-rotate");
const dryRun = flag("dry-run");
const probe = flag("probe");
const maxLayers = Number(opt("layers", "-1"));
// Q2c: BlockLDLQ error feedback against per-layer L factors from
// tq-ldlq-hessians.py. Absent -> unweighted Viterbi (the q2a objective).
const ldlqDir = opt("ldlq", "");
const kMapPath = opt("k-map", "");
const kBudget = opt("k-budget", "3.00");

// ---------------------------------------------------------------- config ---
const raw = JSON.parse(readFileSync(join(srcDir, "config.json"), "utf8")) as Record<string, unknown>;
if (raw.quantization || raw.quantization_config)
  throw new Error("source is already quantized — the fold needs full-precision weights");
const textCfg = (raw.text_config ?? raw) as Record<string, unknown>;
const hiddenSize = Number(textCfg.hidden_size);
const nLayers = Number(textCfg.num_hidden_layers);
const layerTypes = textCfg.layer_types as string[];

const LM = "model.language_model.";
const VIS = "model.visual.";
const MTP = "mtp.";

type Treatment =
  | { kind: "bf16" }
  | { kind: "affine"; bits: number }
  | { kind: "trellis"; axis: 0 | 1; k: number };

/** Per-tensor k from the allocation file, keyed by OUR base names
 *  (model.language_model.layers.N.mlp.X); null = uniform --k. */
const kMap: Map<string, number> | null = (() => {
  if (!kMapPath) return null;
  const doc = JSON.parse(readFileSync(kMapPath, "utf8")) as Record<string, unknown>;
  const budgets = doc.budgets as Record<string, { kmap?: Record<string, number> }> | undefined;
  const km = budgets?.[kBudget]?.kmap;
  if (!km) throw new Error(`--k-map: no budgets["${kBudget}"].kmap in ${kMapPath} (have ${Object.keys(budgets ?? {}).join(", ")})`);
  const out = new Map<string, number>();
  for (const [name, k] of Object.entries(km)) {
    if (!Number.isInteger(k) || k < 1 || k > 8) throw new Error(`--k-map: bad k=${k} for ${name}`);
    out.set(name.replace(/^model\.layers\./, `${LM}layers.`), k);
  }
  return out;
})();
const kOf = (base: string): number => {
  if (!kMap) return TRELLIS_K;
  const k = kMap.get(base);
  if (k === undefined) throw new Error(`--k-map: no entry for in-scope trellis tensor ${base}`);
  return k;
};

/** Shipped-compact allocation, with the 3-bit MLP tier replaced by the trellis.
 *  Trellis axis = the ROTATED axis (R1 acts on the input dim of gate/up and on
 *  the output dim of down_proj), so the coded sequence runs along the direction
 *  the Hadamard actually gaussianized. */
function treat(base: string): Treatment {
  if (base.startsWith(VIS)) return { kind: "bf16" };
  if (base.startsWith(`${LM}layers.`)) {
    const rest = base.slice(`${LM}layers.`.length);
    const layer = Number(rest.slice(0, rest.indexOf(".")));
    const mod = rest.slice(rest.indexOf(".") + 1);
    const inScope = maxLayers < 0 || layer < maxLayers;
    if (mod === "mlp.gate_proj" || mod === "mlp.up_proj")
      return useTrellis && inScope ? { kind: "trellis", axis: 1, k: kOf(base) } : { kind: "affine", bits: BASE_BITS };
    if (mod === "mlp.down_proj")
      return useTrellis && inScope ? { kind: "trellis", axis: 0, k: kOf(base) } : { kind: "affine", bits: BASE_BITS };
    return { kind: "affine", bits: PROT_BITS };
  }
  if (base === "lm_head" || base === `${LM}embed_tokens`) return { kind: "affine", bits: PROT_BITS };
  return { kind: "affine", bits: BASE_BITS };   // mtp.* rides the base tier
}

function mlxLmPath(base: string): string | null {
  if (base.startsWith(VIS)) return null;
  if (base.startsWith(MTP)) return null;
  if (base.startsWith("model.language_model"))
    return base.replace("model.language_model", "language_model.model");
  return `language_model.${base}`;
}

// ------------------------------------------------------------- fold plan ---
const foldOps = new Map<string, FoldOp>();
const gammaNames: string[] = [];
const zeroNorms = new Set<string>();
function addGamma(name: string): void { gammaNames.push(name); zeroNorms.add(name); }

const finalNorm = `${LM}norm.weight`;
addGamma(finalNorm);
foldOps.set(`${LM}embed_tokens.weight`, { kind: "input" });
foldOps.set("lm_head.weight", { kind: "input", gamma: finalNorm });

for (let i = 0; i < nLayers; i++) {
  const L = `${LM}layers.${i}`;
  const inNorm = `${L}.input_layernorm.weight`;
  const postNorm = `${L}.post_attention_layernorm.weight`;
  addGamma(inNorm);
  addGamma(postNorm);
  const isLinear = layerTypes[i] === "linear_attention";
  const readers = isLinear
    ? ["linear_attn.in_proj_qkv", "linear_attn.in_proj_z", "linear_attn.in_proj_b", "linear_attn.in_proj_a"]
    : ["self_attn.q_proj", "self_attn.k_proj", "self_attn.v_proj"];
  const writer = isLinear ? "linear_attn.out_proj" : "self_attn.o_proj";
  for (const r of readers) foldOps.set(`${L}.${r}.weight`, { kind: "input", gamma: inNorm });
  foldOps.set(`${L}.${writer}.weight`, { kind: "output" });
  for (const r of ["mlp.gate_proj", "mlp.up_proj"])
    foldOps.set(`${L}.${r}.weight`, { kind: "input", gamma: postNorm });
  foldOps.set(`${L}.mlp.down_proj.weight`, { kind: "output" });
}

foldOps.set(`${VIS}merger.linear_fc2.weight`, { kind: "output" });
foldOps.set(`${VIS}merger.linear_fc2.bias`, { kind: "bias" });

const mtpEmbedNorm = `${MTP}pre_fc_norm_embedding.weight`;
const mtpHiddenNorm = `${MTP}pre_fc_norm_hidden.weight`;
addGamma(mtpEmbedNorm);
addGamma(mtpHiddenNorm);
zeroNorms.add(`${MTP}norm.weight`);
foldOps.set(`${MTP}fc.weight`, { kind: "mtp-fc", gammaEmbed: mtpEmbedNorm, gammaHidden: mtpHiddenNorm });
{
  const L = `${MTP}layers.0`;
  const inNorm = `${L}.input_layernorm.weight`;
  const postNorm = `${L}.post_attention_layernorm.weight`;
  addGamma(inNorm);
  addGamma(postNorm);
  for (const r of ["self_attn.q_proj", "self_attn.k_proj", "self_attn.v_proj"])
    foldOps.set(`${L}.${r}.weight`, { kind: "input", gamma: inNorm });
  foldOps.set(`${L}.self_attn.o_proj.weight`, { kind: "output" });
  for (const r of ["mlp.gate_proj", "mlp.up_proj"])
    foldOps.set(`${L}.${r}.weight`, { kind: "input", gamma: postNorm });
  foldOps.set(`${L}.mlp.down_proj.weight`, { kind: "output" });
}

// ------------------------------------------------------------------ run ----
if (outDir) mkdirSync(outDir, { recursive: true });
const weights = await Weights.open(srcDir);
const names = weights.tensorNames;

for (const n of foldOps.keys())
  if (!weights.has(n)) throw new Error(`fold plan: missing source tensor ${n}`);
for (const n of gammaNames)
  if (!weights.has(n)) throw new Error(`fold plan: missing γ tensor ${n}`);
const unplannedProj = names.filter(
  (n) => n.endsWith(".weight") && !foldOps.has(n) && !zeroNorms.has(n) &&
    (n.startsWith(LM) || n.startsWith(MTP)) &&
    weights.info(n).shape.length === 2 && !n.includes("_norm.") && !n.endsWith("attn.norm.weight"),
);
if (unplannedProj.length) throw new Error(`fold plan: unplanned 2-D trunk tensors ${unplannedProj.join(", ")}`);

const one = Arr.fromFloat32(new Float32Array(1).fill(1), [1]);
const gammaShim = {
  tensor(name: string): MlxArray {
    const f32 = weights.tensor(name).astype(Dtype.float32, cpuStream);
    const shifted = ops.add(f32, one, cpuStream);
    shifted.eval();
    f32.dispose();
    return shifted;
  },
} as unknown as Weights;
const ctx = new QwenFoldContext(gammaShim, hiddenSize, seed, gammaNames, true);

function zerosLike(src: MlxArray): MlxArray {
  const n = src.shape[0]!;
  const z = Arr.fromFloat32(new Float32Array(n), [n]);
  const out = z.astype(Dtype.bfloat16, cpuStream);
  out.eval();
  z.dispose();
  return out;
}

/** One codec per distinct k (the L=12 1MAD codebook is shared; k only changes
 *  the branching), created lazily so a uniform run still builds exactly one. */
const codecs = new Map<number, Trellis>();
function trellisFor(k: number): Trellis {
  let t = codecs.get(k);
  if (!t) codecs.set(k, (t = new Trellis({ L: TRELLIS_L, K: k, T: BLOCK_T, code: "1mad", tailBiting })));
  return t;
}
const disposeCodecs = (): void => { for (const t of codecs.values()) t.dispose(); codecs.clear(); };
if (kMap) {
  const hist = new Map<number, number>();
  for (const k of kMap.values()) hist.set(k, (hist.get(k) ?? 0) + 1);
  console.log(`k-map ${kMapPath} budget ${kBudget}: ` +
    [...hist].sort((a, b) => a[0] - b[0]).map(([k, n]) => `k${k}×${n}`).join(" "));
}

/** Calibration provenance, lifted verbatim from the Hessian stage's state.json
 *  so the artifact records WHICH corpus the LDLQ objective was fitted on
 *  (calibration-domain mismatch is a known confound on this eval). */
const ldlqCalib: unknown = ldlqDir && existsSync(join(ldlqDir, "state.json"))
  ? (JSON.parse(readFileSync(join(ldlqDir, "state.json"), "utf8")) as Record<string, unknown>).calibration
  : null;
if (ldlqDir) console.log("LDLQ calibration:", JSON.stringify(ldlqCalib));

/** Trellis fake-quant of a folded 2-D tensor; returns bf16. */
function trellisTensor(folded: MlxArray, axis: 0 | 1, k: number = TRELLIS_K): MlxArray {
  // Every intermediate handle is disposed: an undisposed VIEW handle pins its
  // parent buffer (that leak cost ~1.4 GB per tensor on the first attempt).
  const f32 = folded.astype(Dtype.float32, gpuStream);
  let X = f32;
  if (axis === 0) {
    const t = ops.transposeAxes(f32, [1, 0], gpuStream);
    X = ops.contiguous(t, gpuStream);
    t.dispose(); f32.dispose();
  }
  ops.evalAll([X]);
  const rec = trellisFor(k).fakeQuantRows(X, BATCH);
  X.dispose();
  let back = rec;
  if (axis === 0) {
    const t = ops.transposeAxes(rec, [1, 0], gpuStream);
    back = ops.contiguous(t, gpuStream);
    t.dispose(); rec.dispose();
  }
  const out = back.astype(Dtype.bfloat16, gpuStream);
  back.dispose();
  ops.evalAll([out]);
  clearCache();
  return out;
}

// ------------------------------------------------------------- BlockLDLQ ---
// Port of Cornell-RelaxML/qtip lib/algo/ldlq.py LDLQ, at block size 256 with
// `for_kernel=False` semantics — which is QTIP's own non-kernel path: it calls
// `cb.quantize(WXWX.T)`, i.e. a trellis of length td_y along the INPUT dim with
// one independent sequence per output row. Choosing td_y = T = 256 makes the
// LDLQ column-blocks coincide exactly with the q2a trellis blocks, so this arm
// changes ONLY the distortion objective (their td_y=16 + 16x16 tiling exists to
// satisfy the CUDA kernel's layout, and would have changed the blocking too).
//
// With buf_cols == td_y the buffer degenerates to one block: all feedback
// arrives through prod_cache, and the intra-buffer term of ldlq.py vanishes.
//
//   for k = K-1 .. 0:   x_k = W_k + prod_k ; Ŵ_k = Viterbi(x_k / s) * s
//                       prod += L[k-block, :]ᵀ @ (W_k − Ŵ_k)
// The error fed forward is (W − Ŵ) against the ORIGINAL weight, per ldlq.py.

const LDLQ_CEILING = 4.0;   // tq-gptq.py's guard shape: 4x the unweighted max
/** Hard abort if MLX's live allocation runs away — turns a silent OOM kill
 *  (which is how the first LDLQ build died, at 86.24 GiB) into a diagnosable
 *  failure. Working set for a down_proj tensor is ~4 GiB. */
const MEM_ABORT = 20 * 2 ** 30;

interface LdlqResult { out: MlxArray; tripped: boolean; }

function loadL(path: string): MlxArray {
  const slot = new BigUint64Array([C.mlx_map_string_to_array_new()]);
  const meta = new BigUint64Array([C.mlx_map_string_to_string_new()]);
  try {
    if (C.mlx_load_safetensors(ptr(slot), ptr(meta), ptr(Buffer.from(path + "\0", "utf8")), cpuStream) !== 0)
      throw new Error(`mlx_load_safetensors(${path}) failed`);
    const out = new BigUint64Array([C.mlx_array_new()]);
    if (C.mlx_map_string_to_array_get(ptr(out), read.u64(ptr(slot), 0), ptr(Buffer.from("L\0", "utf8"))) !== 0)
      throw new Error(`tensor L missing from ${path}`);
    return new MlxArray(read.u64(ptr(out), 0));
  } finally {
    C.mlx_map_string_to_string_free(read.u64(ptr(meta), 0));
    C.mlx_map_string_to_array_free(read.u64(ptr(slot), 0));
  }
}

/** [256, m] LDLQ tile -> [B, T] trellis batch, and back. For gate/up the
 *  trellis axis IS the LDLQ axis (transpose); for down_proj it is the output
 *  axis, so the tile splits into 256-long runs down `m` (reshape only). Both
 *  reproduce the q2a block partition exactly. */
/** contiguous(transpose(x)) with the intermediate VIEW handle disposed. An
 *  undisposed view pins its parent buffer — leaving these unhandled is what
 *  OOM-killed the first LDLQ build at 86 GiB (the L.slice views alone pin
 *  1.21 GiB per down_proj tensor). */
function tContig(x: MlxArray): MlxArray {
  const t = ops.transposeAxes(x, [1, 0], gpuStream);
  const c = ops.contiguous(t, gpuStream);
  t.dispose();
  return c;
}
/** owned contiguous copy of a row range; the slice view is disposed. */
function rows(a: MlxArray, r0: number, r1: number, cols: number): MlxArray {
  const sl = a.slice([r0, 0], [r1, cols], gpuStream);
  const c = ops.contiguous(sl, gpuStream);
  sl.dispose();
  return c;
}
function maxAbs(a: MlxArray): number {
  const ab = ops.abs(a, gpuStream);
  const fl = ops.reshape(ab, [a.shape[0]! * a.shape[1]!], gpuStream);
  const mx = ops.maxAxis(fl, 0, false, gpuStream);
  const v = mx.toFloat32()[0]!;
  ab.dispose(); fl.dispose(); mx.dispose();
  return v;
}

function tileToBatch(x: MlxArray, axis: 0 | 1, m: number, T: number): MlxArray {
  // axis 1: [T, m] -> [m, T]  (row = output row, cols = T input dims)
  // axis 0: [T, m] -> [m, T]  by RESHAPE — row i = (input col i div (m/T),
  //         out-block i mod (m/T)), cols = T consecutive output dims.
  if (axis === 1) return tContig(x);
  return ops.reshape(x, [m, T], gpuStream);
}
function batchToTile(b: MlxArray, axis: 0 | 1, m: number, T: number): MlxArray {
  if (axis === 1) return tContig(b);
  return ops.reshape(b, [T, m], gpuStream);
}

/** Per-batch-row scale for one LDLQ block. gate/up: scale is indexed by output
 *  row (m-indexed, block-independent). down_proj: indexed by input column
 *  (n-indexed), and each input column owns m/T consecutive batch rows. */
function blockScale(scale: MlxArray, axis: 0 | 1, k: number, m: number, T: number): MlxArray {
  if (axis === 1) return scale;                                  // [m,1], reused
  const sl = scale.slice([k * T, 0], [(k + 1) * T, 1], gpuStream);   // [T,1]
  const z = ops.zeros([T, m / T], Dtype.float32, gpuStream);
  const b = ops.add(z, sl, gpuStream);                              // [T, m/T]
  const out = ops.reshape(b, [m, 1], gpuStream);
  sl.dispose(); z.dispose(); b.dispose();
  return out;
}

/** The per-coded-row fp16 scale q2a uses, computed on the ORIGINAL folded
 *  weight so both arms share it exactly. Returned in the LDLQ orientation:
 *  gate/up -> [m,1] (per output row); down_proj -> [n,1] (per input column). */
function rowScale(Wt: MlxArray, axis: 0 | 1, k: number): MlxArray {
  // Wt is [n, m]. q2a's scale axis: gate/up = m (rows of the [m,n] folded
  // tensor); down_proj = n (rows of the transposed [n,m] tensor).
  const src = axis === 1 ? tContig(Wt) : Wt;
  const sq = ops.square(src, gpuStream);
  const ms = ops.meanAxis(sq, 1, true, gpuStream);
  const rms = ops.sqrt(ms, gpuStream);
  const inv = ops.mulScalar(rms, 1 / trellisFor(k).lutRms, gpuStream);
  const zero = Arr.fromFloat32(new Float32Array([0]), []);
  const one = Arr.fromFloat32(new Float32Array([1]), []);
  const isz = ops.equal(inv, zero, gpuStream);
  const guarded = ops.where(isz, one, inv, gpuStream);
  const s16 = guarded.astype(Dtype.float16, gpuStream);
  const out = s16.astype(Dtype.float32, gpuStream);
  for (const a of [sq, ms, rms, inv, zero, one, isz, guarded, s16]) a.dispose();
  if (axis === 1) src.dispose();
  ops.evalAll([out]);
  return out;
}

function trellisTensorLDLQ(folded: MlxArray, axis: 0 | 1, L: MlxArray, k: number = TRELLIS_K): LdlqResult {
  const T = BLOCK_T;
  const f32 = folded.astype(Dtype.float32, gpuStream);
  const Wt = tContig(f32);                                  // [n, m]
  f32.dispose();
  ops.evalAll([Wt]);
  const [n, m] = Wt.shape as [number, number];
  if (L.shape[0] !== n) throw new Error(`L dim ${L.shape[0]} != LDLQ dim ${n}`);
  const K = n / T;
  const scale = rowScale(Wt, axis, k);

  // Guard ceiling from the UNWEIGHTED normalized weight (tq-gptq.py discipline:
  // gate the weighted path against a multiple of the unweighted magnitude).
  let ceiling: number;
  {
    const s0 = blockScale(scale, axis, 0, m, T);
    const w0 = rows(Wt, 0, T, m);
    const b0 = tileToBatch(w0, axis, m, T);
    const nrm = ops.div(b0, s0, gpuStream);
    ceiling = LDLQ_CEILING * maxAbs(nrm);
    w0.dispose(); b0.dispose(); nrm.dispose();
    if (axis === 0) s0.dispose();
  }

  let prod = ops.zeros([n, m], Dtype.float32, gpuStream);
  let What = ops.zeros([n, m], Dtype.float32, gpuStream);
  ops.evalAll([prod, What]);
  let tripped = false;

  for (let k = K - 1; k >= 0; k--) {
    const w = rows(Wt, k * T, (k + 1) * T, m);
    const p = rows(prod, k * T, (k + 1) * T, m);
    const x = ops.add(w, p, gpuStream);
    p.dispose();
    const s = blockScale(scale, axis, k, m, T);
    const batch = tileToBatch(x, axis, m, T);
    const xn = ops.div(batch, s, gpuStream);
    ops.evalAll([xn]);
    batch.dispose(); x.dispose();

    const peak = maxAbs(xn);
    if (!Number.isFinite(peak) || peak > ceiling) {
      tripped = true;
      for (const y of [w, xn]) y.dispose();
      if (axis === 0) s.dispose();
      break;
    }

    const rec = trellisFor(k).encodeDecodeChunked(xn, BATCH);
    xn.dispose();
    const hatB = ops.mul(rec, s, gpuStream);
    rec.dispose();
    if (axis === 0) s.dispose();
    const hat = batchToTile(hatB, axis, m, T);
    hatB.dispose();

    const err = ops.sub(w, hat, gpuStream);
    w.dispose();
    const nw = ops.sliceUpdate(What, hat, [k * T, 0], [(k + 1) * T, m], gpuStream);
    What.dispose(); hat.dispose();
    What = nw;

    // prod += L[block, :]ᵀ @ err        ([n,T] @ [T,m])
    const Lb = rows(L, k * T, (k + 1) * T, n);
    const Lt = tContig(Lb);
    const contrib = ops.matmul(Lt, err, gpuStream);
    const np2 = ops.add(prod, contrib, gpuStream);
    prod.dispose();
    prod = np2;
    ops.evalAll([prod, What]);
    for (const y of [err, Lb, Lt, contrib]) y.dispose();
    clearCache();
    if (activeMemory() > MEM_ABORT)
      throw new Error(
        `LDLQ leak guard: mlx active ${(activeMemory() / 2 ** 30).toFixed(1)} GiB > ` +
        `${(MEM_ABORT / 2 ** 30).toFixed(0)} GiB at block ${k} — aborting instead of OOM-killing`,
      );
  }

  prod.dispose();
  scale.dispose();
  if (tripped) {
    Wt.dispose(); What.dispose();
    clearCache();
    return { out: trellisTensor(folded, axis, k), tripped: true };
  }
  Wt.dispose();
  const bt = ops.transposeAxes(What, [1, 0], gpuStream);
  const back = ops.contiguous(bt, gpuStream);
  bt.dispose(); What.dispose();
  const out = back.astype(Dtype.bfloat16, gpuStream);
  back.dispose();
  ops.evalAll([out]);
  clearCache();
  return { out, tripped: false };
}

function mseOf(a: MlxArray, b: MlxArray): number {
  const af = a.astype(Dtype.float32, gpuStream), bf = b.astype(Dtype.float32, gpuStream);
  const d = ops.sub(af, bf, gpuStream);
  const sq = ops.square(d, gpuStream);
  const m = ops.meanAll(sq, false, gpuStream);
  const v = m.toFloat32()[0]!;
  for (const x of [af, bf, d, sq, m]) x.dispose();
  return v;
}

function affineRoundTrip(folded: MlxArray, bits: number): MlxArray {
  const q = quantize(folded, groupSize, bits, "affine", gpuStream);
  const d = dequantize(q.packed, q.scales, q.biases, { groupSize, bits, mode: "affine" }, gpuStream);
  q.packed.dispose(); q.scales.dispose(); q.biases?.dispose();
  ops.evalAll([d]);
  return d;
}

// --------------------------------------------------------- ldlq selftest ---
// With L = 0 there is no error feedback, so BlockLDLQ must degenerate to the
// EXACT q2a unweighted path. Any mismatch means the tiling / per-row scale /
// reshape plumbing differs, which would silently confound the paired arm.
if (flag("ldlq-selftest")) {
  const li = Number(opt("probe-layers", "21"));
  let bad = 0;
  for (const [mod, axis] of [["mlp.gate_proj", 1], ["mlp.down_proj", 0]] as const) {
    const name = `${LM}layers.${li}.${mod}.weight`;
    const src = weights.tensor(name);
    const folded = ctx.apply(foldOps.get(name)!, src);
    ops.evalAll([folded]);
    const n = folded.shape[1]!;   // LDLQ acts on the INPUT dim for both layouts
    // With --ldlq, use the REAL L (smoke test: bounded memory, guard, and a
    // genuinely different objective). Without it, L = 0 must reproduce q2a.
    const site = axis === 0 ? "down" : "mlp";
    const real = ldlqDir
      ? loadL(join(ldlqDir, `layer-${String(li).padStart(3, "0")}-${site}.safetensors`))
      : null;
    const Lm = real ?? ops.zeros([n, n], Dtype.float32, gpuStream);
    ops.evalAll([Lm]);
    const a = trellisTensor(folded, axis);
    const b = trellisTensorLDLQ(folded, axis, Lm);
    const d = mseOf(a, b.out);
    const uwA = mseOf(a, folded), uwB = mseOf(b.out, folded);
    if (!real && d !== 0) bad++;
    console.log(
      real
        ? `  LDLQ probe   L${li} ${mod.padEnd(14)} axis=${axis}  ` +
          `unweighted mse: q2a ${uwA.toExponential(4)} -> ldlq ${uwB.toExponential(4)} ` +
          `(${((uwB / uwA - 1) * 100).toFixed(1)}%)  |Δrecon| mse ${d.toExponential(3)}` +
          `${b.tripped ? "  GUARD TRIPPED" : ""}  peak ${(peakMemory() / 2 ** 30).toFixed(1)} GiB`
        : `  L=0 selftest  L${li} ${mod.padEnd(14)} axis=${axis}  ` +
          `mse(q2a, ldlq)=${d.toExponential(3)}  ${d === 0 ? "IDENTICAL" : "MISMATCH"}`,
    );
    for (const x of [folded, Lm, a, b.out]) x.dispose();
    clearCache();
  }
  ctx.dispose(); one.dispose(); disposeCodecs(); weights.dispose();
  process.exit(bad ? 1 : 0);
}

// ---------------------------------------------------------------- probe ----
if (probe) {
  const layers = (opt("probe-layers", "0,21,42,63")).split(",").map(Number);
  console.log("layer  module      rot   trellis-k3      affine-3      affine-4   (Frobenius MSE)");
  for (const li of layers) {
    for (const mod of ["mlp.gate_proj", "mlp.up_proj", "mlp.down_proj"] as const) {
      const name = `${LM}layers.${li}.${mod}.weight`;
      const axis: 0 | 1 = mod === "mlp.down_proj" ? 0 : 1;
      for (const rot of [true, false]) {
        const src = weights.tensor(name);
        const folded = rot ? ctx.apply(foldOps.get(name)!, src) : ctx.apply({ kind: "passthrough" }, src);
        ops.evalAll([folded]);
        const t = trellisTensor(folded, axis);
        const a3 = affineRoundTrip(folded, 3);
        const a4 = affineRoundTrip(folded, 4);
        console.log(
          `${String(li).padStart(4)}  ${mod.padEnd(14)}${rot ? "R1" : "--"}  ` +
          `${mseOf(t, folded).toExponential(4)}  ${mseOf(a3, folded).toExponential(4)}  ` +
          `${mseOf(a4, folded).toExponential(4)}`,
        );
        for (const x of [folded, t, a3, a4]) x.dispose();
        clearCache();
      }
    }
    weights.releaseShard(weights.fileOf(`${LM}layers.${li}.mlp.gate_proj.weight`)!);
    clearCache();
  }
  ctx.dispose(); one.dispose(); disposeCodecs(); weights.dispose();
  process.exit(0);
}

// -------------------------------------------------------------- quantize ---
const perLayer = new Map<string, PerLayerEntry>();
let nQuant = 0, qParams = 0, qBits = 0, bf16Bytes = 0;
let nTrellis = 0, trellisParams = 0, trellisBits = 0;
let ldlqApplied = 0, ldlqTrips = 0, ldlqMissing = 0;
const trippedTensors: string[] = [];
const kHist = new Map<number, number>();
const byBits = new Map<string, { n: number; bytes: number }>();
const bump = (k: string, bytes: number) => {
  const e = byBits.get(k) ?? { n: 0, bytes: 0 };
  e.n++; e.bytes += bytes; byBits.set(k, e);
};
/** Hypothetical packed cost of a trellis tensor: k bits/weight (the tail-biting
 *  block carries no initial state) or k + L/T without tail-biting, plus one
 *  fp16 scale per coded row. */
const trellisBpw = (rows: number, cols: number, k: number): number =>
  k + (tailBiting ? 0 : TRELLIS_L / BLOCK_T) + 16 / cols;

if (dryRun) {
  for (const name of names) {
    if (!name.endsWith(".weight")) continue;
    const base = name.slice(0, -".weight".length);
    const shape = weights.info(name).shape;
    if (shape.length !== 2 || shape[1]! % groupSize !== 0) continue;
    const params = shape[0]! * shape[1]!;
    const t = treat(base);
    if (t.kind === "bf16") { bump("bf16", params * 2); continue; }
    if (t.kind === "trellis") {
      const cols = t.axis === 1 ? shape[1]! : shape[0]!;
      const eff = trellisBpw(params / cols, cols, t.k);
      nTrellis++; trellisParams += params; trellisBits += params * eff;
      kHist.set(t.k, (kHist.get(t.k) ?? 0) + 1);
      bump(`trellis-${t.k}`, (params * eff) / 8);
      continue;
    }
    const eff = t.bits + 32 / groupSize;
    nQuant++; qParams += params; qBits += params * eff;
    bump(`${t.bits}-bit`, (params * eff) / 8);
  }
  const tot = qBits + trellisBits, totP = qParams + trellisParams;
  console.log(`dry run: ${nQuant} affine + ${nTrellis} trellis modules`);
  console.log(`  coded bpw ${(tot / totP).toFixed(4)} over ${(totP / 1e9).toFixed(3)} G params`);
  for (const [k, v] of [...byBits].sort())
    console.log(`  ${k.padEnd(10)} n=${String(v.n).padStart(4)} ${(v.bytes / 2 ** 30).toFixed(3)} GiB`);
  weights.dispose();
  process.exit(0);
}

// 2 GiB shards: the trellis encoder holds ~2 GB of its own and the fake-quant
// artifact is ~41 GB of bf16 MLP, so a smaller ceiling than the writer's
// default keeps the peak down on a 32 GB box. NOTE: written as `2 * 1024 ** 3`,
// not `2 << 30` — JS bitwise shifts truncate to int32 (`3 << 30` is NEGATIVE,
// and safetensors-writer.ts's own `DEFAULT_SHARD_BYTES = 5 << 30` is really
// 1 GiB, not 5 — latent repo bug, harmless there, fatal here).
const writer = new ShardedWriter(outDir!, { shardBytes: 2 * 1024 ** 3 });
const t0 = performance.now();
let trellisSeconds = 0;
try {
  const byFile = new Map<string, string[]>();
  for (const n of names) {
    const f = weights.fileOf(n)!;
    let list = byFile.get(f);
    if (!list) byFile.set(f, (list = []));
    list.push(n);
  }
  let done = 0;
  for (const [file, list] of byFile) {
    for (const name of list) {
      const src = weights.tensor(name);
      let folded: MlxArray;
      if (noRotate) folded = ctx.apply({ kind: "passthrough" }, src);
      else if (zeroNorms.has(name)) folded = zerosLike(src);
      else folded = ctx.apply(foldOps.get(name) ?? { kind: "passthrough" }, src);

      const base = name.endsWith(".weight") ? name.slice(0, -".weight".length) : null;
      const shape = folded.shape;
      const eligible = base !== null && shape.length === 2 && shape[1]! % groupSize === 0;
      const t: Treatment = eligible ? treat(base!) : { kind: "bf16" };

      if (!eligible) {
        writer.add(name, folded);
        bf16Bytes += folded.nbytes;
      } else if (t.kind === "bf16") {
        writer.add(name, folded);
        perLayer.set(base!, false);
        bump("bf16", folded.nbytes);
      } else if (t.kind === "trellis") {
        const tt = performance.now();
        let rec: MlxArray;
        if (ldlqDir) {
          const rest = base!.slice(`${LM}layers.`.length);
          const li = Number(rest.slice(0, rest.indexOf(".")));
          const site = t.axis === 0 ? "down" : "mlp";
          const lp = join(ldlqDir, `layer-${String(li).padStart(3, "0")}-${site}.safetensors`);
          if (!existsSync(lp)) {
            rec = trellisTensor(folded, t.axis, t.k);
            ldlqMissing++;
          } else {
            const Lm = loadL(lp);
            const r = trellisTensorLDLQ(folded, t.axis, Lm, t.k);
            Lm.dispose();
            clearCache();
            rec = r.out;
            if (r.tripped) {
              ldlqTrips++;
              trippedTensors.push(base!);
            } else ldlqApplied++;
          }
        } else {
          rec = trellisTensor(folded, t.axis, t.k);
        }
        trellisSeconds += (performance.now() - tt) / 1000;
        folded.dispose();
        writer.add(name, rec);
        perLayer.set(base!, false);            // stored bf16, flagged unquantized
        const params = shape[0]! * shape[1]!;
        const cols = t.axis === 1 ? shape[1]! : shape[0]!;
        const eff = trellisBpw(params / cols, cols, t.k);
        nTrellis++; trellisParams += params; trellisBits += params * eff;
        kHist.set(t.k, (kHist.get(t.k) ?? 0) + 1);
        bump(`trellis-${t.k}`, (params * eff) / 8);
      } else {
        const q = quantize(folded, groupSize, t.bits, "affine", gpuStream);
        folded.dispose();
        writer.add(`${base}.weight`, q.packed);
        writer.add(`${base}.scales`, q.scales);
        if (q.biases) writer.add(`${base}.biases`, q.biases);
        if (t.bits !== BASE_BITS) perLayer.set(base!, { bits: t.bits, groupSize });
        nQuant++;
        const params = shape[0]! * shape[1]!;
        const eff = t.bits + 32 / groupSize;
        qParams += params; qBits += params * eff;
        bump(`${t.bits}-bit`, (params * eff) / 8);
      }
      done++;
      process.stdout.write(
        `\r  ${done}/${names.length} tensors · trellis ${nTrellis} ` +
        `(${(trellisSeconds / 60).toFixed(1)} min, ` +
        `${trellisSeconds > 0 ? (trellisParams / 1e6 / trellisSeconds).toFixed(2) : "—"} Mw/s) · ` +
        `mlx ${(activeMemory() / 2 ** 30).toFixed(2)}+${(cacheMemory() / 2 ** 30).toFixed(2)} GiB   `,
      );
    }
    weights.releaseShard(file);
    clearCache();
  }
  const res = writer.finish();
  const totP = qParams + trellisParams, totB = qBits + trellisBits;
  console.log(
    `\n${nQuant} affine + ${nTrellis} trellis modules · effective coded bpw ` +
    `${(totB / totP).toFixed(4)} over ${(totP / 1e9).toFixed(3)} G params · ` +
    `on-disk ${(res.totalSize / 2 ** 30).toFixed(3)} GiB (fake-quant) · ` +
    `${((performance.now() - t0) / 60000).toFixed(1)} min total, ` +
    `${(trellisSeconds / 60).toFixed(1)} min in the trellis encoder`,
  );
  for (const [k, v] of [...byBits].sort())
    console.log(`  ${k.padEnd(10)} n=${String(v.n).padStart(4)} ${(v.bytes / 2 ** 30).toFixed(3)} GiB (packed-equivalent)`);
  console.log(`  other passthrough ${(bf16Bytes / 2 ** 30).toFixed(3)} GiB`);

  const blockEntries = new Map<string, PerLayerEntry>();
  for (const [path, entry] of perLayer) {
    blockEntries.set(path, entry);
    const p = mlxLmPath(path);
    // MLP `false` entries MUST also land in mlx-lm's key space (unlike vision,
    // which mlx-lm drops) so its class_predicate sees them.
    if (p && p !== path) blockEntries.set(p, entry);
  }
  const block = buildQuantizationBlock({ bits: BASE_BITS, groupSize, mode: "affine" }, blockEntries);
  await writeQuantizedConfig(raw, outDir!, block, { srcDir });
  await Bun.write(join(outDir!, "optiq_metadata.json"), JSON.stringify({
    method: "rotation+trellis_tcq(mlp)+rtn(rest)",
    base_model: srcDir,
    bits: BASE_BITS,
    group_size: groupSize,
    trellis: {
      L: TRELLIS_L, V: 1, block: BLOCK_T, code: "1mad",
      k: kMap ? "mixed (see k_map)" : TRELLIS_K,
      k_map: kMap
        ? {
            file: kMapPath, budget: kBudget,
            modules_by_k: Object.fromEntries([...kHist].sort((a, b) => a[0] - b[0]).map(([k, n]) => [`k${k}`, n])),
            per_tensor: Object.fromEntries([...kMap].map(([n, k]) => [n.replace(LM, "model."), k])),
          }
        : null,
      tail_biting: tailBiting,
      reference: "arXiv:2406.11235v3 (QTIP); Cornell-RelaxML/qtip lib/codebook/bitshift.py",
      distortion: ldlqDir
        ? "BlockLDLQ Hessian-weighted error feedback (QTIP lib/algo/ldlq.py, " +
          `block ${BLOCK_T} = trellis T, for_kernel=False path)`
        : "unweighted squared error (no Hessian/LDLQ — v2 lever)",
      ldlq: ldlqDir
        ? {
            hessians: ldlqDir,
            applied: ldlqApplied, guard_trips: ldlqTrips, missing_L: ldlqMissing,
            tripped_tensors: trippedTensors,
            guard: `xn peak > ${LDLQ_CEILING}x the unweighted normalized max -> ` +
                   "fall back to unweighted Viterbi for that tensor (tq-gptq.py discipline)",
            calibration: ldlqCalib,
          }
        : null,
      scale: "per coded row, fp16 (QTIP uses one per-tensor Wscale after TWO-sided IP)",
      packaging: "fake-quant: decoded to bf16, flagged false in the quantization block",
      modules: nTrellis, params: trellisParams,
      effective_bpw: trellisParams > 0 ? trellisBits / trellisParams : 0,
    },
    achieved_bpw_coded: totB / totP,
    affine_modules: nQuant,
    total_bytes: res.totalSize,
    allocation: "shipped-compact (base 3 g64; 4-bit embed/lm_head/attn; vision bf16) with the 3-bit MLP tier replaced by the trellis",
    weight_transforms: noRotate ? [] : [{
      id: "rotation.qwen3_5", seed, family: "qwen3_5",
      deviations: [
        "no-R2 (attn_output_gate does not commute with per-head rotation)",
        "no-embedding-mean-centering", "no-R4-downproj-input-fold", "no-R3",
        "gamma-folded; norms written as ZEROS (mlx-lm qwen3_5 sanitize adds 1.0 for this checkpoint family)",
        "fold-precision-f32",
        "vision folded at merger.linear_fc2 only (deepstack empty); vision tower left bf16",
        "mtp companion folded with the trunk seed (unverified — mlx-lm drops mtp)",
        "one-sided incoherence processing only (R1 folds into adjacent matrices; QTIP's SU/SV pair does not)",
      ],
    }],
  }, null, 2));
  for (const f of ["preprocessor_config.json", "video_preprocessor_config.json"])
    if (existsSync(join(srcDir, f))) copyFileSync(join(srcDir, f), join(outDir!, f));
  writeFileSync(join(outDir!, "turboquant_fold.json"), JSON.stringify({
    source: srcDir, generatedAt: new Date().toISOString(), seed,
    r1: !noRotate, r2: false, hiddenSize,
    gamma_convention: noRotate
      ? "none (control arm: no basis change)"
      : "stored+1 folded in; folded norms written as zeros",
  }, null, 2));
  console.log("config + aux files + sidecars written");
} finally {
  ctx.dispose();
  one.dispose();
  disposeCodecs();
  weights.dispose();
  clearCache();
}
