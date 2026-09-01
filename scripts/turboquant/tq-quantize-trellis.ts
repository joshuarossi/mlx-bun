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

import { existsSync, mkdirSync, copyFileSync, writeFileSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { Weights } from "../../src/weights";
import { MlxArray as Arr, cpuStream, gpuStream, type MlxArray } from "../../src/mlx/array";
import { Dtype, clearCache, activeMemory, cacheMemory } from "../../src/mlx/ffi";
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
if (!srcDir || (!outDir && !flag("probe"))) {
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
  | { kind: "trellis"; axis: 0 | 1 };

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
      return useTrellis && inScope ? { kind: "trellis", axis: 1 } : { kind: "affine", bits: BASE_BITS };
    if (mod === "mlp.down_proj")
      return useTrellis && inScope ? { kind: "trellis", axis: 0 } : { kind: "affine", bits: BASE_BITS };
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

const trellis = new Trellis({ L: TRELLIS_L, K: TRELLIS_K, T: BLOCK_T, code: "1mad", tailBiting });

/** Trellis fake-quant of a folded 2-D tensor; returns bf16. */
function trellisTensor(folded: MlxArray, axis: 0 | 1): MlxArray {
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
  const rec = trellis.fakeQuantRows(X, BATCH);
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
  ctx.dispose(); one.dispose(); trellis.dispose(); weights.dispose();
  process.exit(0);
}

// -------------------------------------------------------------- quantize ---
const perLayer = new Map<string, PerLayerEntry>();
let nQuant = 0, qParams = 0, qBits = 0, bf16Bytes = 0;
let nTrellis = 0, trellisParams = 0, trellisBits = 0;
const byBits = new Map<string, { n: number; bytes: number }>();
const bump = (k: string, bytes: number) => {
  const e = byBits.get(k) ?? { n: 0, bytes: 0 };
  e.n++; e.bytes += bytes; byBits.set(k, e);
};
/** Hypothetical packed cost of a trellis tensor: k bits/weight (the tail-biting
 *  block carries no initial state) or k + L/T without tail-biting, plus one
 *  fp16 scale per coded row. */
const trellisBpw = (rows: number, cols: number): number =>
  TRELLIS_K + (tailBiting ? 0 : TRELLIS_L / BLOCK_T) + 16 / cols;

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
      const eff = trellisBpw(params / cols, cols);
      nTrellis++; trellisParams += params; trellisBits += params * eff;
      bump(`trellis-${TRELLIS_K}`, (params * eff) / 8);
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
        const rec = trellisTensor(folded, t.axis);
        trellisSeconds += (performance.now() - tt) / 1000;
        folded.dispose();
        writer.add(name, rec);
        perLayer.set(base!, false);            // stored bf16, flagged unquantized
        const params = shape[0]! * shape[1]!;
        const cols = t.axis === 1 ? shape[1]! : shape[0]!;
        const eff = trellisBpw(params / cols, cols);
        nTrellis++; trellisParams += params; trellisBits += params * eff;
        bump(`trellis-${TRELLIS_K}`, (params * eff) / 8);
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
      L: TRELLIS_L, k: TRELLIS_K, V: 1, block: BLOCK_T, code: "1mad",
      tail_biting: tailBiting,
      reference: "arXiv:2406.11235v3 (QTIP); Cornell-RelaxML/qtip lib/codebook/bitshift.py",
      distortion: "unweighted squared error (no Hessian/LDLQ — v2 lever)",
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
  trellis.dispose();
  weights.dispose();
  clearCache();
}
