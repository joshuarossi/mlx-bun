// Fuse a LoRA adapter into base model weights → a standalone model snapshot
// (mlx_lm.fuse counterpart, minus GGUF/de-quantize export).
//
// Math (matches mlx-lm's LoRALinear.fuse and our QuantizedLinear.forward):
//   forward:  y = x @ W_dequantᵀ + scale · ((x @ A) @ B)
//   fused:    W'[out,in] = W + (scale · B)ᵀ.astype(bf16) @ Aᵀ.astype(bf16)
// mlx-lm casts the (scaled) LoRA factors to the base dtype BEFORE the matmul,
// then re-quantizes with the module's OWN source spec (bits/group unchanged) —
// we do the same, so the output config.json is the source config verbatim.
//
// Everything runs on the CPU stream (same discipline as src/quantize/quantizer:
// the safetensors loader lives there, and one module is materialized, fused,
// and disposed at a time). Modules the adapter does not touch pass through
// bit-identical (no dequant→requant round trip).

import { existsSync, mkdirSync } from "node:fs";
import { join } from "node:path";
import { clearCache, Dtype } from "../mlx/ffi";
import { cpuStream, type MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { Weights } from "../weights";
import { loadModelConfig, quantFor } from "../config";
import { loadAdapterTensors, readAdapterScale, adapterWeightsFile } from "../lora";
import { writeShardedSafetensors, type NamedTensor } from "../quantize/safetensors-writer";
import { copyAuxFiles } from "../quantize/config-writer";

/** Quantize the allocator cache this often (in modules processed). */
const CACHE_CLEAR_EVERY = 16;

export interface FuseStats {
  outDir: string;
  /** Modules whose weights had an adapter delta folded in. */
  fusedModules: number;
  /** Adapter tensors that matched no base weight (skipped). */
  skippedAdapterTensors: number;
  totalTensors: number;
}

export interface FuseProgress {
  stage: string;
  message: string;
  /** 0..1 fraction of modules processed. */
  progress: number;
}

/** Resolve the adapter safetensors file: `<dir>/adapters.safetensors`,
 *  `<dir>/best/adapters.safetensors`, `adapter_model.safetensors`, or an
 *  explicit file path. */
function resolveAdapterFile(dir: string): string {
  const best = join(dir, "best");
  if (existsSync(join(best, "adapters.safetensors"))) return join(best, "adapters.safetensors");
  if (dir.endsWith(".safetensors") && existsSync(dir)) return dir;
  return adapterWeightsFile(dir);
}

/** Group adapter tensors into (modulePath → {a, b}); disposes non-LoRA
 *  tensors and returns how many were skipped. */
function groupPairs(tensors: Map<string, MlxArray>): {
  pairs: Map<string, { a?: MlxArray; b?: MlxArray }>;
  skipped: number;
} {
  const pairs = new Map<string, { a?: MlxArray; b?: MlxArray }>();
  let skipped = 0;
  for (const [name, arr] of tensors) {
    const m = name.match(/^(.*)\.(lora_a|lora_A|lora_b|lora_B)(\.weight)?$/);
    if (!m) { skipped++; arr.dispose(); continue; }
    const slot = pairs.get(m[1]!) ?? {};
    if (m[2]!.toLowerCase() === "lora_a") slot.a = arr; else slot.b = arr;
    pairs.set(m[1]!, slot);
  }
  return { pairs, skipped };
}

/**
 * Fuse the adapter at `adapterDir` into the base model at `modelDir` and
 * write a complete, loadable snapshot to `outDir` (weights + config.json +
 * tokenizer aux files). Quantization layout is preserved verbatim: fused
 * modules are dequantized, updated, and re-quantized with their own source
 * spec; untouched modules pass through bit-identical.
 */
export async function fuseAdapter(
  modelDir: string,
  adapterDir: string,
  outDir: string,
  onProgress?: (e: FuseProgress) => void,
): Promise<FuseStats> {
  const progress = (stage: string, message: string, frac: number) =>
    onProgress?.({ stage, message, progress: frac });

  progress("loading", `Reading ${modelDir}`, 0);
  const config = await loadModelConfig(modelDir);
  const weights = await Weights.open(modelDir);

  const adapterFile = resolveAdapterFile(adapterDir);
  const { scale, rsLora } = await readAdapterScale(adapterDir);
  const { pairs, skipped } = groupPairs(loadAdapterTensors(adapterFile));

  // Map each adapter module path to the base weight-file module path,
  // probing the VLM-wrapped/unwrapped `language_model.` prefixes both ways
  // (same normalization as AdapterManager.mount).
  const weightNames = new Set(weights.tensorNames);
  const byModule = new Map<string, { a: MlxArray; b: MlxArray }>();
  let unmatched = 0;
  const disposeAll = () => {
    for (const { a, b } of pairs.values()) { a?.dispose(); b?.dispose(); }
  };
  try {
    for (const [path, { a, b }] of pairs) {
      if (!a || !b) throw new Error(`${path}: adapter has only one of lora_a/lora_b`);
      const candidates = [
        path,
        `language_model.${path}`,
        path.startsWith("language_model.") ? path.slice("language_model.".length) : null,
      ].filter((c): c is string => c !== null);
      const hit = candidates.find((c) => weightNames.has(`${c}.weight`));
      if (!hit) { unmatched++; continue; }
      byModule.set(hit, { a, b });
    }
    if (byModule.size === 0)
      throw new Error(
        `no adapter tensors match the base model's weights — was ` +
        `${adapterFile} trained for a different base?`,
      );
  } catch (e) {
    disposeAll();
    weights.dispose();
    throw e;
  }

  mkdirSync(outDir, { recursive: true });

  // Walk tensors in source order (diff-friendly like the quantizer): group
  // names into module bases so a fused module's weight/scales/biases are
  // regenerated together.
  const names = weights.tensorNames;
  const moduleSuffixes = new Map<string, Set<string>>();
  const passthroughNames: string[] = [];
  for (const name of names) {
    const m = /^(.*)\.(weight|scales|biases)$/.exec(name);
    if (!m) { passthroughNames.push(name); continue; }
    let set = moduleSuffixes.get(m[1]!);
    if (!set) { set = new Set(); moduleSuffixes.set(m[1]!, set); }
    set.add(m[2]!);
  }

  const out: NamedTensor[] = [];
  let fusedModules = 0;
  let processed = 0;
  const totalModules = moduleSuffixes.size;

  try {
    for (const [base, suffixes] of moduleSuffixes) {
      processed++;
      if (processed % CACHE_CLEAR_EVERY === 0) clearCache();
      const pair = suffixes.has("weight") ? byModule.get(base) : undefined;
      if (!pair) {
        for (const suf of suffixes) {
          const n = `${base}.${suf}`;
          out.push({ name: n, array: weights.tensor(n) });
        }
        continue;
      }
      progress("fusing", `Module ${processed}/${totalModules}: ${base}`, processed / totalModules);

      // Materialize the full-precision weight [out, in].
      const srcSpec = suffixes.has("scales") ? quantFor(config.quantization, base) : null;
      let w: MlxArray;
      if (srcSpec) {
        const packed = weights.tensor(`${base}.weight`);
        const scales = weights.tensor(`${base}.scales`);
        const biases = suffixes.has("biases") ? weights.tensor(`${base}.biases`) : null;
        w = ops.dequantize(packed, scales, biases, srcSpec, cpuStream);
      } else {
        w = weights.tensor(`${base}.weight`);
      }
      const [outF, inF] = w.shape as [number, number];
      const { a, b } = pair;
      const [aIn, rank] = a.shape as [number, number];
      const [bRank, bOut] = b.shape as [number, number];
      if (aIn !== inF || bRank !== rank || bOut !== outF)
        throw new Error(
          `${base}: shape mismatch — lora_a [${a.shape}] / lora_b [${b.shape}] ` +
          `vs base [out ${outF}, in ${inF}]`,
        );

      // delta[out,in] = (scale·B)ᵀ.astype(bf16) @ Aᵀ.astype(bf16)
      // (rsLoRA: effective per-layer scale is α/√rank, matching mount/training.)
      const effScale = rsLora ? scale / Math.sqrt(rank) : scale;
      const bScaled = ops.mulScalar(b, effScale, cpuStream);
      const bT = ops.transposeAxes(bScaled, [1, 0], cpuStream);
      bScaled.dispose();
      const bT16 = bT.astype(Dtype.bfloat16, cpuStream);
      bT.dispose();
      const aT = ops.transposeAxes(a, [1, 0], cpuStream);
      const aT16 = aT.astype(Dtype.bfloat16, cpuStream);
      aT.dispose();
      const delta = ops.matmul(bT16, aT16, cpuStream);
      bT16.dispose();
      aT16.dispose();

      const w16 = w.dtype === Dtype.bfloat16 ? w : w.astype(Dtype.bfloat16, cpuStream);
      if (w16 !== w) w.dispose();
      const fusedW = ops.add(w16, delta, cpuStream);
      w16.dispose();
      delta.dispose();

      if (srcSpec) {
        const q = ops.quantize(fusedW, srcSpec.groupSize, srcSpec.bits, srcSpec.mode, cpuStream);
        fusedW.dispose();
        out.push({ name: `${base}.weight`, array: q.packed });
        out.push({ name: `${base}.scales`, array: q.scales });
        out.push({ name: `${base}.biases`, array: q.biases });
      } else {
        out.push({ name: `${base}.weight`, array: fusedW });
      }
      fusedModules++;
    }
    for (const name of passthroughNames) out.push({ name, array: weights.tensor(name) });

    progress("writing", `Writing ${out.length} tensors to ${outDir}`, 1);
    writeShardedSafetensors(outDir, out);

    // Config is unchanged (same quantization layout) — copy it and the aux
    // files (tokenizer, chat template, …) verbatim for a loadable snapshot.
    await Bun.write(join(outDir, "config.json"), Bun.file(join(modelDir, "config.json")));
    await copyAuxFiles(modelDir, outDir);

    progress("done", `Fused ${fusedModules} module(s) → ${outDir}`, 1);
    return {
      outDir,
      fusedModules,
      skippedAdapterTensors: skipped + unmatched * 2,
      totalTensors: out.length,
    };
  } finally {
    for (const t of out) {
      try { t.array.dispose(); } catch {}
    }
    disposeAll();
    weights.dispose();
    clearCache();
  }
}
