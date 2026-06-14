// Native model quantizer: walk a model directory's weights, quantize every
// eligible Linear / embedding / lm_head weight to uniform affine N-bit, pass
// everything else through unchanged, and write a loadable quantized snapshot.
//
// No Python. The whole pipeline (load → dequantize-if-needed → cast bf16 →
// mx.quantize → save) runs through the mlx-c FFI on the CPU stream where the
// safetensors loader lives.
//
// Memory discipline: one module is materialized, quantized, written, and
// disposed at a time; the allocator cache is cleared every CACHE_CLEAR_EVERY
// modules so a large model never holds more than a few resident tensors.
//
// v1 = uniform affine (every eligible weight gets the same bits/group_size).
// The mixed-precision (OptiQ sensitivity + knapsack) path is a declared seam:
// the option fields exist on QuantizeOptions and throw if used — see below.

import { join } from "node:path";
import { mkdirSync } from "node:fs";
import { clearCache, Dtype } from "../mlx/ffi";
import { cpuStream, type MlxArray } from "../mlx/array";
import { quantize, dequantize } from "../mlx/ops";
import { Weights } from "../weights";
import { loadModelConfig, quantFor, type QuantizationConfig } from "../config";
import {
  writeShardedSafetensors,
  type NamedTensor,
  type WriteResult,
} from "./safetensors-writer";
import {
  buildQuantizationBlock,
  writeQuantizedConfig,
  type PerLayerEntry,
} from "./config-writer";

/** Quantize the allocator cache this often (in modules processed). */
const CACHE_CLEAR_EVERY = 16;

/** Bits used per group for affine scale + bias (one bf16 each = 32 bits). */
const AFFINE_GROUP_OVERHEAD_BITS = 32;

export interface QuantizeOptions {
  bits: 4 | 8;
  groupSize: 32 | 64;
  /** Quantization scheme; v1 only exercises "affine". */
  mode?: string;

  // --- mixed-precision seam (NOT implemented in v1) ---------------------
  // Present so the UI / OptiQ port compiles against one option type; setting
  // targetBpw triggers an explicit "not implemented" throw in quantizeModelDir.
  /** Target bits-per-weight for sensitivity+knapsack mixed precision. */
  targetBpw?: number;
  /** Reference dtype for sensitivity scoring (e.g. "bf16"). */
  reference?: string;
  /** Candidate bit-widths the knapsack may choose from (e.g. [4, 8]). */
  candidateBits?: number[];
  /** Calibration data mixture spec for sensitivity scoring. */
  calibrationMix?: Record<string, number>;
  /** Number of calibration samples. */
  nCalibration?: number;
}

export interface ProgressEvent {
  stage: string;
  message: string;
  /** 0..1 fraction of modules processed. */
  progress: number;
}

export interface QuantizeResult {
  outDir: string;
  /** Achieved bits-per-weight over the quantized parameters (incl overhead). */
  achievedBpw: number;
  /** Number of modules quantized. */
  nQuantized: number;
  /** Sharding / size details from the writer. */
  write: WriteResult;
}

type Suffix = "weight" | "scales" | "biases";

/** Split a tensor name into (modulePath, suffix) for `.weight|.scales|.biases`. */
function splitName(name: string): { base: string; suffix: Suffix } | null {
  const m = /^(.*)\.(weight|scales|biases)$/.exec(name);
  if (!m) return null;
  return { base: m[1]!, suffix: m[2] as Suffix };
}

/**
 * Eligibility predicate (port of mlx-lm's default class_predicate): a module
 * is quantizable iff it has a 2D `.weight` whose last dim is divisible by the
 * group size. This captures Linear projections, the token embedding, and the
 * (untied) lm_head, and excludes norms/biases/1D tensors.
 */
export function isQuantizable(weightShape: number[], groupSize: number): boolean {
  return weightShape.length === 2 && weightShape[weightShape.length - 1]! % groupSize === 0;
}

/**
 * Quantize a model directory to uniform affine N-bit and write a loadable
 * snapshot to `outDir`.
 */
export async function quantizeModelDir(
  srcDir: string,
  outDir: string,
  opts: QuantizeOptions,
  onProgress?: (e: ProgressEvent) => void,
): Promise<QuantizeResult> {
  if (opts.targetBpw !== undefined) {
    throw new Error("mixed-precision (sensitivity+knapsack) not implemented in v1");
  }
  const bits = opts.bits;
  const groupSize = opts.groupSize;
  const mode = opts.mode ?? "affine";

  mkdirSync(outDir, { recursive: true });

  const progress = (stage: string, message: string, frac: number) =>
    onProgress?.({ stage, message, progress: frac });

  progress("loading", `Reading ${srcDir}`, 0);

  const config = await loadModelConfig(srcDir);
  const srcQuant: QuantizationConfig | null = config.quantization;
  const weights = await Weights.open(srcDir);

  // Preserve the source tensor order so the output diff is mlx-lm-shaped.
  // tensorNames is sorted; we walk modules in that order. For each module's
  // `.weight` we decide quantize / pass-through, then emit its tensors. We
  // skip the source `.scales`/`.biases` of already-quantized modules (they're
  // regenerated) and pass through everything else verbatim.
  const names = weights.tensorNames;

  // Group names by module base so we can detect "already quantized" (has a
  // sibling `.scales`) and process a module atomically.
  const moduleSuffixes = new Map<string, Set<Suffix>>();
  const passthroughNames: string[] = []; // non-(weight/scales/biases) tensors
  for (const name of names) {
    const sp = splitName(name);
    if (!sp) {
      passthroughNames.push(name);
      continue;
    }
    let set = moduleSuffixes.get(sp.base);
    if (!set) {
      set = new Set();
      moduleSuffixes.set(sp.base, set);
    }
    set.add(sp.suffix);
  }

  // Decide the per-module plan in source order.
  const moduleBases = [...moduleSuffixes.keys()];
  const totalModules = moduleBases.length;

  const out: NamedTensor[] = [];
  const perLayer = new Map<string, PerLayerEntry>();
  let nQuantized = 0;
  let quantizedParams = 0;
  let quantizedBits = 0;
  let processed = 0;

  try {
    for (const base of moduleBases) {
      const suffixes = moduleSuffixes.get(base)!;
      const alreadyQuant = suffixes.has("scales");
      const hasWeight = suffixes.has("weight");

      if (!hasWeight) {
        // Module with only scales/biases and no weight — shouldn't happen, but
        // pass any present tensors through unchanged.
        for (const suf of suffixes) out.push(named(weights, `${base}.${suf}`));
        bumpProgress();
        continue;
      }

      // Materialize the full-precision weight for this module.
      const weightName = `${base}.weight`;
      const shape = weights.info(weightName).shape;

      // Determine the *original* (full-precision) shape: if already quantized,
      // the packed weight's last dim is compressed — recover the real width
      // from the scales (groups × srcGroupSize) when dequantizing.
      let fullWeight = weights.tensor(weightName);
      let materialized: MlxArray | null = null;

      if (alreadyQuant) {
        const srcSpec = quantFor(srcQuant, base);
        if (!srcSpec) {
          // Has scales but config says unquantized — fall back to passthrough.
          for (const suf of suffixes) out.push(named(weights, `${base}.${suf}`));
          bumpProgress();
          continue;
        }
        const scales = weights.tensor(`${base}.scales`);
        const biases = suffixes.has("biases") ? weights.tensor(`${base}.biases`) : null;
        materialized = dequantize(
          fullWeight, scales, biases,
          { bits: srcSpec.bits, groupSize: srcSpec.groupSize, mode: srcSpec.mode },
          cpuStream,
        );
        fullWeight = materialized;
      }

      // Recover the full-precision 2D shape for eligibility + param counting.
      // For a freshly-loaded bf16 weight this is just `shape`; for a
      // re-quantized weight it is the dequantized array's shape.
      const fullShape = alreadyQuant ? materialized!.shape : shape;

      if (!isQuantizable(fullShape, groupSize)) {
        // Not eligible: pass the full-precision weight through unchanged
        // (re-materialized to bf16 if it had been quantized).
        if (alreadyQuant) {
          const bf16 = materialized!.astype(Dtype.bfloat16, cpuStream);
          out.push({ name: weightName, array: bf16 });
          materialized!.dispose();
        } else {
          out.push({ name: weightName, array: fullWeight });
        }
        bumpProgress();
        continue;
      }

      // Cast to bf16 before quantizing (mx.quantize expects a float weight;
      // bf16 matches the reference dtype and the scales/biases dtype on disk).
      const bf16 = fullWeight.astype(Dtype.bfloat16, cpuStream);
      if (materialized) materialized.dispose();

      const q = quantize(bf16, groupSize, bits, mode, cpuStream);
      bf16.dispose();

      out.push({ name: `${base}.weight`, array: q.packed });
      out.push({ name: `${base}.scales`, array: q.scales });
      out.push({ name: `${base}.biases`, array: q.biases });

      // Account: every element of the original 2D weight is now `bits` bits,
      // plus 32 bits (bf16 scale + bf16 bias) per group of `groupSize`.
      const params = fullShape.reduce((a, b) => a * b, 1);
      quantizedParams += params;
      quantizedBits += params * bits + (params / groupSize) * AFFINE_GROUP_OVERHEAD_BITS;
      perLayer.set(base, { bits, groupSize });
      nQuantized++;

      bumpProgress();
    }

    // Pass through non-weight/scale/bias tensors (e.g. anything unusual).
    for (const name of passthroughNames) out.push(named(weights, name));

    progress("writing", `Writing ${out.length} tensors to ${outDir}`, 1);
    const write = writeShardedSafetensors(outDir, out);

    const achievedBpw = quantizedParams > 0 ? quantizedBits / quantizedParams : 0;

    // Build + write the config block and sidecar.
    const block = buildQuantizationBlock({ bits, groupSize, mode }, perLayer);
    await writeQuantizedConfig(config.raw, outDir, block, {
      srcDir,
      optiq: {
        method: "uniform_affine",
        base_model: srcDir,
        bits,
        group_size: groupSize,
        achieved_bpw: achievedBpw,
        per_layer_count: nQuantized,
      },
    });

    progress("done", `Quantized ${nQuantized} modules → ${outDir}`, 1);
    return { outDir, achievedBpw, nQuantized, write };
  } finally {
    // Dispose every emitted array (their bytes are now on disk) and the source.
    for (const t of out) {
      try { t.array.dispose(); } catch {}
    }
    weights.dispose();
    clearCache();
  }

  function bumpProgress(): void {
    processed++;
    if (processed % CACHE_CLEAR_EVERY === 0) clearCache();
    progress(
      "quantizing",
      `Module ${processed}/${totalModules}`,
      totalModules > 0 ? processed / totalModules : 1,
    );
  }
}

/** Pass-through tensor: the lazy mlx array straight from the source weights. */
function named(weights: Weights, name: string): NamedTensor {
  return { name, array: weights.tensor(name) };
}
