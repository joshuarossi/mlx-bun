// Rotated (γ+R1) + RTN quantizer with an EXPLICIT per-module bit allocation,
// for the Q1 territory-map candidate on Qwen3.8-27B.
//
// Why this exists (the tooling gap it bridges):
//  1. The production `mlx-bun convert --rotate-weights` path (quantizeModelDir +
//     automaticRotationWeightTransform) can only derive a mixed-precision map
//     from its own sensitivity+knapsack pass (`--target-bpw`); there is no way
//     to inject an allocation computed elsewhere.
//  2. `planQwen35Fold` assumes the OLD HF tensor naming (`language_model.model.*`,
//     `vision_tower.*`). This Qwen3.8-27B snapshot (transformers 5.8.0.dev0) uses
//     `model.language_model.*` / `model.visual.*` / top-level `lm_head.weight` /
//     in-repo `mtp.*`, so the production planner throws.
//  3. mlx-lm's qwen3_5 `sanitize()` ADDS 1.0 to every RMSNorm gain when the
//     checkpoint carries mtp weights or an unsanitized conv1d — this checkpoint
//     stores γ−1. The γ-fold must therefore use (stored + 1) and write ZEROS
//     back (not ones) so the loader's shift yields gain-free norms.
//
// Fold math is the production one (src/quantize/rotate.ts QwenFoldContext,
// R1-only + γ, seed 42); only the plan and the γ convention are local.
//
// STREAMING: source shard in → fold → quantize → incremental writer, releasing
// each source shard. Peak is one source shard + one output shard + the tensor
// in flight (the 51 GB bf16 source never goes resident).
//
//   bun scripts/turboquant/tq-quantize-alloc.ts <src> <out> \
//       --allocation reports/qwen38-allocation/allocation-proposal.json \
//       --variant 13.3GB_q1_target [--seed 42] [--group 64] [--dry-run]

import { existsSync, mkdirSync, copyFileSync, writeFileSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { Weights } from "../../src/weights";
import { MlxArray as Arr, cpuStream, type MlxArray } from "../../src/mlx/array";
import { Dtype, clearCache } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { quantize } from "../../src/mlx/ops";
import { QwenFoldContext, type FoldOp } from "../../src/quantize/rotate";
import { ShardedWriter } from "../../src/quantize/safetensors-writer";
import {
  buildQuantizationBlock,
  writeQuantizedConfig,
  type PerLayerEntry,
} from "../../src/quantize/config-writer";

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
if (!srcDir || !outDir) {
  console.error(
    "usage: bun scripts/turboquant/tq-quantize-alloc.ts <src> <out> " +
    "--allocation <proposal.json> --variant <key> [--seed 42] [--group 64] [--dry-run]",
  );
  process.exit(1);
}
const seed = Number(opt("seed", "42"));
const groupSize = Number(opt("group", "64")) as 32 | 64;
const allocPath = opt("allocation", "reports/qwen38-allocation/allocation-proposal.json");
const variantKey = opt("variant", "13.3GB_q1_target");
const dryRun = flag("dry-run");
// Control arm: same allocation, NO basis change (no γ-fold, no R1). Isolates
// "did rotation help/hurt" from "is the allocation right".
const noRotate = flag("no-rotate");
// Control arm: ignore the allocation, use one uniform bit-width everywhere
// (vision still bf16). Anchors the fold against the existing plain-RTN-4 row.
const uniformBits = argv.includes("--uniform") ? Number(opt("uniform", "4")) : null;
// Control arm: an explicit {on-disk module base -> bits} map that REPLACES the
// proposal's rules verbatim (used to replay a shipped artifact's allocation).
// Modules absent from the map ride the base bits.
const bitsMap: Record<string, number> | null = argv.includes("--bits-map")
  ? (JSON.parse(readFileSync(opt("bits-map", ""), "utf8")) as Record<string, number>)
  : null;

// ------------------------------------------------------------ allocation ---
interface Proposal {
  base: { bits: number; group_size: number; mode: string };
  common_protections_all_variants: Record<string, { bits: number }>;
  variants: Record<string, {
    mlp_late_promoted_layers: number[];
    mlp_bits: number;
    linear_attn_early_promoted_layers: number[];
    linear_attn_bits: number;
    linear_attn_promoted_modules: string[];
    self_attn_qo_early_promoted_layers: number[];
    self_attn_qo_bits?: number;
  }>;
}
const proposal = JSON.parse(readFileSync(allocPath, "utf8")) as Proposal;
// Bind through a second const so the non-undefined narrowing survives into
// `bitsFor`'s closure (TS does not carry the `if (!variant) throw` guard into
// a function body for an index-signature read under noUncheckedIndexedAccess).
const variantEntry = proposal.variants[variantKey];
if (!variantEntry) throw new Error(`no variant ${variantKey} in ${allocPath}`);
const variant = variantEntry;
const BASE_BITS = proposal.base.bits;
if (proposal.base.group_size !== groupSize)
  throw new Error(`proposal group_size ${proposal.base.group_size} != --group ${groupSize}`);

const prot = proposal.common_protections_all_variants;
const AB_BITS = prot["linear_attn.in_proj_a"]!.bits;          // 8
const KV_BITS = prot["self_attn.k_proj"]!.bits;               // 8
const HEAD_BITS = prot["lm_head"]!.bits;                      // 4
const EMBED_BITS = prot["embed_tokens"]!.bits;                // 3
const mlpLate = new Set(variant.mlp_late_promoted_layers);
const laEarly = new Set(variant.linear_attn_early_promoted_layers);
const laMods = new Set(variant.linear_attn_promoted_modules.map((m) => `linear_attn.${m}`));
const qoEarly = new Set(variant.self_attn_qo_early_promoted_layers);

// ---------------------------------------------------------------- config ---
const raw = JSON.parse(readFileSync(join(srcDir, "config.json"), "utf8")) as Record<string, unknown>;
if (raw.quantization || raw.quantization_config)
  throw new Error("source is already quantized — the fold needs full-precision weights");
const textCfg = (raw.text_config ?? raw) as Record<string, unknown>;
const hiddenSize = Number(textCfg.hidden_size);
const nLayers = Number(textCfg.num_hidden_layers);
const layerTypes = textCfg.layer_types as string[];

const LM = "model.language_model.";        // trunk prefix in this snapshot
const VIS = "model.visual.";               // vision tower (kept bf16)
const MTP = "mtp.";                        // in-repo MTP companion

/** Per-module target bits, keyed by ON-DISK module base (name minus `.weight`).
 *  `null` = keep bf16 (never quantized). */
function bitsFor(base: string): number | null {
  if (base.startsWith(VIS)) return null;                       // vision tower bf16
  if (uniformBits !== null) return uniformBits;
  if (bitsMap) return bitsMap[base] ?? BASE_BITS;
  if (base === "lm_head") return HEAD_BITS;
  if (base === `${LM}embed_tokens`) return EMBED_BITS;
  if (base.startsWith(`${LM}layers.`)) {
    const rest = base.slice(`${LM}layers.`.length);
    const layer = Number(rest.slice(0, rest.indexOf(".")));
    const mod = rest.slice(rest.indexOf(".") + 1);
    if (mod === "linear_attn.in_proj_a" || mod === "linear_attn.in_proj_b") return AB_BITS;
    if (mod === "self_attn.k_proj" || mod === "self_attn.v_proj") return KV_BITS;
    if (mod.startsWith("mlp.") && mlpLate.has(layer)) return variant.mlp_bits;
    if (laMods.has(mod) && laEarly.has(layer)) return variant.linear_attn_bits;
    if ((mod === "self_attn.q_proj" || mod === "self_attn.o_proj") && qoEarly.has(layer))
      return variant.self_attn_qo_bits ?? BASE_BITS;
    return BASE_BITS;
  }
  return BASE_BITS; // mtp.* and anything else rides the base
}

/** mlx-lm's internal module path for an on-disk module base (qwen3_5 sanitize:
 *  `model.language_model.*` → `language_model.model.*`, everything else that is
 *  neither vision nor already prefixed gets a bare `language_model.` prefix). */
function mlxLmPath(base: string): string | null {
  if (base.startsWith(VIS)) return null;      // dropped by mlx-lm (text-only model)
  if (base.startsWith(MTP)) return null;      // dropped by mlx-lm
  if (base.startsWith("model.language_model")) return base.replace("model.language_model", "language_model.model");
  return `language_model.${base}`;
}

// ------------------------------------------------------------- fold plan ---
// Mirror of planQwen35Fold for this snapshot's naming. Corridor map:
// docs/design/turboquant.md §W1.
const foldOps = new Map<string, FoldOp>();
const gammaNames: string[] = [];
/** Norm tensors whose γ is folded into consumers: written back as ZEROS
 *  because mlx-lm re-adds 1.0 on load for this checkpoint family. */
const zeroNorms = new Set<string>();

function addGamma(name: string): void {
  gammaNames.push(name);
  zeroNorms.add(name);
}

const finalNorm = `${LM}norm.weight`;
const embedName = `${LM}embed_tokens.weight`;
addGamma(finalNorm);
foldOps.set(embedName, { kind: "input" });                     // writes residual (rows)
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

// Vision: the merger's final projection is the ONLY vision→residual seam.
foldOps.set(`${VIS}merger.linear_fc2.weight`, { kind: "output" });
foldOps.set(`${VIS}merger.linear_fc2.bias`, { kind: "bias" });

// MTP companion (same R1/seed as the trunk — shared residual basis). mlx-lm
// drops these entirely; folded for coherence with the trunk, NOT verified.
const mtpEmbedNorm = `${MTP}pre_fc_norm_embedding.weight`;
const mtpHiddenNorm = `${MTP}pre_fc_norm_hidden.weight`;
addGamma(mtpEmbedNorm);
addGamma(mtpHiddenNorm);
zeroNorms.add(`${MTP}norm.weight`);   // dropped γ: draft logits ride the trunk head
foldOps.set(`${MTP}fc.weight`, {
  kind: "mtp-fc", gammaEmbed: mtpEmbedNorm, gammaHidden: mtpHiddenNorm,
});
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
mkdirSync(outDir, { recursive: true });
const weights = await Weights.open(srcDir);
const names = weights.tensorNames;

// Plan/coverage assertions: every planned tensor exists, and no 2-D trunk
// projection was left in passthrough (that would be a silent mis-fold).
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

// γ convention: this checkpoint stores (γ − 1); mlx-lm adds 1.0 back on load.
// Feed the fold context γ_effective = stored + 1 through a Weights shim.
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

/** bf16 zeros of the same shape — the folded (gain-free) norm under the +1
 *  loader convention. */
function zerosLike(src: MlxArray): MlxArray {
  const n = src.shape[0]!;
  const z = Arr.fromFloat32(new Float32Array(n), [n]);
  const out = z.astype(Dtype.bfloat16, cpuStream);
  out.eval();
  z.dispose();
  return out;
}

const perLayer = new Map<string, PerLayerEntry>();
let nQuantized = 0, quantizedParams = 0, quantizedBits = 0, bf16Bytes = 0;
const byBits = new Map<string, { n: number; bytes: number }>();
const bump = (k: string, bytes: number) => {
  const e = byBits.get(k) ?? { n: 0, bytes: 0 };
  e.n++; e.bytes += bytes; byBits.set(k, e);
};

if (dryRun) {
  for (const name of names) {
    if (!name.endsWith(".weight")) continue;
    const base = name.slice(0, -".weight".length);
    const shape = weights.info(name).shape;
    if (shape.length !== 2 || shape[1]! % groupSize !== 0) continue;
    const params = shape[0]! * shape[1]!;
    const b = bitsFor(base);
    if (b === null) { bump("bf16", params * 2); continue; }
    const eff = b + 32 / groupSize;
    nQuantized++; quantizedParams += params; quantizedBits += params * eff;
    bump(`${b}-bit`, (params * eff) / 8);
  }
  console.log(`dry run: ${nQuantized} modules, bpw ${(quantizedBits / quantizedParams).toFixed(4)}`);
  for (const [k, v] of [...byBits].sort()) console.log(`  ${k.padEnd(8)} n=${v.n} ${(v.bytes / 2 ** 30).toFixed(3)} GiB`);
  weights.dispose();
  process.exit(0);
}

const writer = new ShardedWriter(outDir);
const t0 = performance.now();
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
      // 1. fold (γ+R1) — or emit the gain-free norm / a plain copy.
      let folded: MlxArray;
      if (noRotate) folded = ctx.apply({ kind: "passthrough" }, src);
      else if (zeroNorms.has(name)) folded = zerosLike(src);
      else folded = ctx.apply(foldOps.get(name) ?? { kind: "passthrough" }, src);

      // 2. quantize at the allocated bit-width, if eligible and not excluded.
      const base = name.endsWith(".weight") ? name.slice(0, -".weight".length) : null;
      const shape = folded.shape;
      const eligible = base !== null && shape.length === 2 && shape[1]! % groupSize === 0;
      const bits = eligible ? bitsFor(base!) : null;
      if (!eligible || bits === null) {
        writer.add(name, folded);
        if (eligible) { perLayer.set(base!, false); bump("bf16", folded.nbytes); }
        else bf16Bytes += folded.nbytes;
      } else {
        const q = quantize(folded, groupSize, bits, "affine", cpuStream);
        folded.dispose();
        writer.add(`${base}.weight`, q.packed);
        writer.add(`${base}.scales`, q.scales);
        if (q.biases) writer.add(`${base}.biases`, q.biases);
        if (bits !== (uniformBits ?? BASE_BITS)) perLayer.set(base!, { bits, groupSize });
        nQuantized++;
        const params = shape[0]! * shape[1]!;
        const eff = bits + 32 / groupSize;
        quantizedParams += params;
        quantizedBits += params * eff;
        bump(`${bits}-bit`, (params * eff) / 8);
      }
      done++;
    }
    weights.releaseShard(file);
    clearCache();
    process.stdout.write(`\r  ${done}/${names.length} tensors (${file})   `);
  }
  const res = writer.finish();
  const achievedBpw = quantizedBits / quantizedParams;
  console.log(
    `\nquantized ${nQuantized} modules, ${achievedBpw.toFixed(4)} bpw, ` +
    `${(res.totalSize / 2 ** 30).toFixed(3)} GiB in ` +
    `${((performance.now() - t0) / 1000).toFixed(0)}s`,
  );
  for (const [k, v] of [...byBits].sort())
    console.log(`  ${k.padEnd(8)} n=${String(v.n).padStart(4)} ${(v.bytes / 2 ** 30).toFixed(3)} GiB`);
  console.log(`  other passthrough ${(bf16Bytes / 2 ** 30).toFixed(3)} GiB`);

  // The quantization block carries BOTH key spaces: on-disk module paths (what
  // a name-faithful loader keys on, incl. the vision `false` entries) and
  // mlx-lm's post-sanitize internal paths (what its class_predicate looks up).
  const blockEntries = new Map<string, PerLayerEntry>();
  for (const [path, entry] of perLayer) {
    blockEntries.set(path, entry);
    const p = mlxLmPath(path);
    if (p && p !== path && entry !== false) blockEntries.set(p, entry);
  }
  const block = buildQuantizationBlock(
    { bits: uniformBits ?? BASE_BITS, groupSize, mode: proposal.base.mode },
    blockEntries,
  );
  await writeQuantizedConfig(raw, outDir, block, { srcDir });
  await Bun.write(join(outDir, "optiq_metadata.json"), JSON.stringify({
    method: "rotation+rtn+explicit_allocation",
    base_model: srcDir,
    bits: BASE_BITS,
    group_size: groupSize,
    achieved_bpw: achievedBpw,
    per_layer_count: nQuantized,
    total_bytes: res.totalSize,
    allocation: { source: allocPath, variant: variantKey },
    weight_transforms: noRotate ? [] : [{
      id: "rotation.qwen3_5", seed, family: "qwen3_5",
      deviations: [
        "no-R2 (attn_output_gate does not commute with per-head rotation)",
        "no-embedding-mean-centering", "no-R4-downproj-input-fold", "no-R3",
        "gamma-folded; norms written as ZEROS (mlx-lm qwen3_5 sanitize adds 1.0 for this checkpoint family)",
        "fold-precision-f32",
        "vision folded at merger.linear_fc2 only (deepstack empty); vision tower left bf16",
        "mtp companion folded with the trunk seed (unverified — mlx-lm drops mtp)",
      ],
    }],
  }, null, 2));
  for (const f of ["preprocessor_config.json", "video_preprocessor_config.json"])
    if (existsSync(join(srcDir, f))) copyFileSync(join(srcDir, f), join(outDir, f));
  writeFileSync(join(outDir, "turboquant_fold.json"), JSON.stringify({
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
  weights.dispose();
  clearCache();
}
