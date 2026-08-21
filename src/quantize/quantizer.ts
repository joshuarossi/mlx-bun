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
// Uniform affine (every eligible weight gets the same bits/group_size) is the
// default. When `opts.targetBpw` is set, the OptiQ sensitivity-driven
// mixed-precision path runs: calibration → per-layer KL sensitivity → greedy
// knapsack → a heterogeneous per-module bit allocation fed to the same writer.

import { join } from "node:path";
import { mkdirSync } from "node:fs";
import { clearCache, Dtype } from "../mlx/ffi";
import { cpuStream, type MlxArray } from "../mlx/array";
import { quantize, dequantize } from "../mlx/ops";
import { Weights } from "../weights";
import { loadModelConfig, quantFor, type QuantizationConfig } from "../config";
import { createModel } from "../model/factory";
import { loadTokenizer } from "../tokenizer";
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
import { loadLlmCalibration } from "./calibration";
import { analyzeSensitivityExact, type SensitivityResult } from "./sensitivity";
import { optimizeMixedPrecision } from "./allocator";
import type {
  WeightTransform,
  WeightTransformContext,
  WeightTransformPlan,
} from "./weight-transform";

/** Quantize the allocator cache this often (in modules processed). */
const CACHE_CLEAR_EVERY = 16;

/** Bits used per group for affine scale + bias (one bf16 each = 32 bits). */
const AFFINE_GROUP_OVERHEAD_BITS = 32;

export interface QuantizeOptions {
  bits: 4 | 8;
  groupSize: 32 | 64;
  /** Quantization scheme; v1 only exercises "affine". */
  mode?: string;
  /** Extra per-module gate on top of the shape-eligibility check: return
   *  false to keep a module full-precision even though its shape qualifies
   *  (e.g. the DeepSpec drafter's confidence_head — threshold-sensitive and
   *  tiny). Excluded modules are recorded as `false` in the quantization
   *  block (mlx's "not quantized" convention). Shape-ineligible modules
   *  never reach this. */
  quantizePredicate?: (base: string, fullShape: number[]) => boolean;
  /** Optional offline basis transform applied before quantization. */
  weightTransform?: WeightTransform;

  // --- mixed-precision (OptiQ sensitivity + knapsack) -------------------
  // Setting targetBpw switches quantizeModelDir to the mixed path: it loads the
  // model, runs calibration + per-layer KL sensitivity, knapsacks a per-module
  // bit allocation, and feeds that heterogeneous map to the same writer.
  /** Target bits-per-weight for sensitivity+knapsack mixed precision. */
  targetBpw?: number;
  /** Reference dtype for sensitivity scoring (e.g. "bf16"). Informational
   *  only — the native path dequantizes the running model's own weights as
   *  the self-contained bf16 source. */
  reference?: string;
  /** Candidate bit-widths the knapsack may choose from (e.g. [4, 8]). */
  candidateBits?: number[];
  /** Calibration data mixture spec ("optiq" or a JSONL path). */
  calibrationMix?: string;
  /** Number of calibration samples (forward passes per layer×bit probe). */
  nCalibration?: number;
  /** Dependency used to provide the loadable model for sensitivity sweeps. */
  probeSource?: ProbeSource;
}

export interface PreparedProbe {
  modelDir: string;
  dispose(): void | Promise<void>;
}

/** Supplies a loadable sensitivity model without re-entering the top-level
 *  quantization orchestrator. Tests and callers may inject an existing probe. */
export interface ProbeSource {
  prepare(
    srcDir: string,
    opts: QuantizeOptions,
    onProgress?: (e: ProgressEvent) => void,
  ): Promise<PreparedProbe>;
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
 * Quantize a model directory and write a loadable snapshot to `outDir`.
 *
 * Uniform affine N-bit by default. When `opts.targetBpw` is set, runs the
 * OptiQ mixed-precision path (calibration → sensitivity → knapsack) to choose
 * per-module bit-widths before writing.
 */
export async function quantizeModelDir(
  srcDir: string,
  outDir: string,
  opts: QuantizeOptions,
  onProgress?: (e: ProgressEvent) => void,
): Promise<QuantizeResult> {
  // Mixed-precision path: derive a per-module bit allocation first, then write.
  let perLayerBits: Map<string, number> | undefined;
  let mixedMeta: MixedMeta | undefined;
  if (opts.targetBpw !== undefined) {
    const alloc = await computeMixedAllocation(srcDir, opts, onProgress);
    perLayerBits = alloc.perLayerBits;
    mixedMeta = alloc.meta;
  }

  return writeQuantizedModelDir(
    srcDir,
    outDir,
    opts,
    perLayerBits,
    mixedMeta,
    onProgress,
  );
}

/** Lower-level writer used by the public orchestrator and its probe source.
 *  Deliberately does not perform sensitivity/allocation or call back into
 *  quantizeModelDir. */
async function writeQuantizedModelDir(
  srcDir: string,
  outDir: string,
  opts: QuantizeOptions,
  perLayerBits?: Map<string, number>,
  mixedMeta?: MixedMeta,
  onProgress?: (e: ProgressEvent) => void,
): Promise<QuantizeResult> {
  const groupSize = opts.groupSize;
  const mode = opts.mode ?? "affine";

  const bits = opts.bits;

  mkdirSync(outDir, { recursive: true });

  const progress = (stage: string, message: string, frac: number) =>
    onProgress?.({ stage, message, progress: frac });

  progress("loading", `Reading ${srcDir}`, 0);

  const config = await loadModelConfig(srcDir);
  const srcQuant: QuantizationConfig | null = config.quantization;
  const weights = await Weights.open(srcDir);
  let transformPlan: WeightTransformPlan | undefined;
  let transformContext: WeightTransformContext | undefined;
  try {
    if (opts.weightTransform && srcQuant)
      throw new Error(
        `weight transform ${opts.weightTransform.id} requires full-precision source weights`,
      );
    transformPlan = opts.weightTransform?.plan(weights.tensorNames, config);
    if (transformPlan) {
      validateTransformPlan(transformPlan, weights.tensorNames);
      transformContext = opts.weightTransform!.createContext(weights, transformPlan);
      progress("transforming", `Planned ${transformPlan.id}`, 0);
    }
  } catch (error) {
    transformContext?.dispose();
    weights.dispose();
    throw error;
  }

  // Preserve the source tensor order so the output diff is mlx-lm-shaped.
  // tensorNames is sorted; we walk modules in that order. For each module's
  // `.weight` we decide quantize / pass-through, then emit its tensors. We
  // skip the source `.scales`/`.biases` of already-quantized modules (they're
  // regenerated) and pass through everything else verbatim.
  const names = transformPlan?.outputNames ?? weights.tensorNames;

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
        for (const suf of suffixes)
          out.push(outputTensor(weights, transformPlan, transformContext, `${base}.${suf}`));
        bumpProgress();
        continue;
      }

      // Materialize the full-precision weight for this module.
      const weightName = `${base}.weight`;
      let fullWeight = outputArray(weights, transformPlan, transformContext, weightName);
      const shape = fullWeight.shape;

      // Determine the *original* (full-precision) shape: if already quantized,
      // the packed weight's last dim is compressed — recover the real width
      // from the scales (groups × srcGroupSize) when dequantizing.
      let materialized: MlxArray | null = null;

      if (alreadyQuant) {
        const srcSpec = quantFor(srcQuant, base);
        if (!srcSpec) {
          // Has scales but config says unquantized — fall back to passthrough.
          for (const suf of suffixes)
            out.push(outputTensor(weights, transformPlan, transformContext, `${base}.${suf}`));
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

      const predicateExcluded =
        isQuantizable(fullShape, groupSize) &&
        opts.quantizePredicate !== undefined &&
        !opts.quantizePredicate(base, fullShape);
      if (!isQuantizable(fullShape, groupSize) || predicateExcluded) {
        // Not eligible: pass the full-precision weight through unchanged
        // (re-materialized to bf16 if it had been quantized).
        if (alreadyQuant) {
          const bf16 = materialized!.astype(Dtype.bfloat16, cpuStream);
          out.push({ name: weightName, array: bf16 });
          materialized!.dispose();
        } else {
          out.push({ name: weightName, array: fullWeight });
        }
        // Policy-excluded (shape-eligible) modules get an explicit `false`
        // in the quantization block — the loader must not apply the block's
        // default spec to them (mlx's "not quantized" convention).
        if (predicateExcluded) perLayer.set(base, false);
        bumpProgress();
        continue;
      }

      // Resolve this module's bit-width: the allocator's per-layer choice in
      // mixed mode, else the uniform `bits`. The allocation map is keyed by
      // module base path (e.g. "model.layers.0.self_attn.q_proj").
      const moduleBits = perLayerBits?.get(base) ?? bits;

      // Cast to bf16 before quantizing (mx.quantize expects a float weight;
      // bf16 matches the reference dtype and the scales/biases dtype on disk).
      const bf16 = fullWeight.astype(Dtype.bfloat16, cpuStream);
      if (materialized) materialized.dispose();
      else if (transformContext) fullWeight.dispose();

      const q = quantize(bf16, groupSize, moduleBits, mode, cpuStream);
      bf16.dispose();

      out.push({ name: `${base}.weight`, array: q.packed });
      out.push({ name: `${base}.scales`, array: q.scales });
      out.push({ name: `${base}.biases`, array: q.biases });

      // Account: every element of the original 2D weight is now `moduleBits`
      // bits, plus 32 bits (bf16 scale + bf16 bias) per group of `groupSize`.
      const params = fullShape.reduce((a, b) => a * b, 1);
      quantizedParams += params;
      quantizedBits += params * moduleBits + (params / groupSize) * AFFINE_GROUP_OVERHEAD_BITS;
      perLayer.set(base, { bits: moduleBits, groupSize });
      nQuantized++;

      bumpProgress();
    }

    // Pass through non-weight/scale/bias tensors (e.g. anything unusual).
    for (const name of passthroughNames)
      out.push(outputTensor(weights, transformPlan, transformContext, name));

    progress("writing", `Writing ${out.length} tensors to ${outDir}`, 1);
    const write = writeShardedSafetensors(outDir, out);

    const achievedBpw = quantizedParams > 0 ? quantizedBits / quantizedParams : 0;

    // Default block bits: the uniform `bits` normally; in mixed mode use the
    // lowest allocated bit-width so the loader's per-module overrides describe
    // every deviation above the floor.
    let defaultBits: number = bits;
    if (perLayerBits && perLayerBits.size > 0) {
      defaultBits = Math.min(...perLayerBits.values());
    }

    // Build + write the config block. For uniform mode, let the config writer
    // emit its standard optiq_metadata.json sidecar. For mixed mode we write a
    // richer OptiQ-style sidecar ourselves below (method "mixed_precision").
    const block = buildQuantizationBlock({ bits: defaultBits, groupSize, mode }, perLayer);
    const outputConfig = transformedConfig(config.raw, transformPlan);
    const weightTransforms = transformPlan ? [transformPlan.metadata] : undefined;
    await writeQuantizedConfig(outputConfig, outDir, block, {
      srcDir,
      optiq: mixedMeta
        ? undefined
        : {
            method: "uniform_affine",
            base_model: srcDir,
            bits,
            group_size: groupSize,
            achieved_bpw: achievedBpw,
            per_layer_count: nQuantized,
            weight_transforms: weightTransforms,
          },
    });

    if (mixedMeta) {
      await Bun.write(
        join(outDir, "optiq_metadata.json"),
        JSON.stringify(
          {
            method: "mixed_precision",
            base_model: srcDir,
            bits: defaultBits,
            group_size: groupSize,
            target_bpw: mixedMeta.targetBpw,
            achieved_bpw: achievedBpw,
            candidate_bits: mixedMeta.candidateBits,
            n_high: mixedMeta.nHigh,
            n_low: mixedMeta.nLow,
            per_layer_count: nQuantized,
            weight_transforms: weightTransforms,
            per_layer: Object.fromEntries(
              [...perLayer].map(([p, e]) => [
                p,
                e === false ? false : { bits: e.bits, group_size: e.groupSize },
              ]),
            ),
          },
          null,
          2,
        ),
      );
    }

    progress("done", `Quantized ${nQuantized} modules → ${outDir}`, 1);
    return { outDir, achievedBpw, nQuantized, write };
  } finally {
    // Dispose every emitted array (their bytes are now on disk) and the source.
    for (const t of out) {
      try { t.array.dispose(); } catch {}
    }
    transformContext?.dispose();
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
function outputTensor(
  weights: Weights,
  plan: WeightTransformPlan | undefined,
  context: WeightTransformContext | undefined,
  name: string,
): NamedTensor {
  return { name, array: outputArray(weights, plan, context, name) };
}

function outputArray(
  weights: Weights,
  plan: WeightTransformPlan | undefined,
  context: WeightTransformContext | undefined,
  name: string,
): MlxArray {
  if (!plan || !context) return weights.tensor(name);
  const sourceName = plan.sourceByOutput.get(name);
  if (!sourceName) throw new Error(`weight transform ${plan.id}: no source for ${name}`);
  return context.apply(name, weights.tensor(sourceName));
}

function validateTransformPlan(
  plan: WeightTransformPlan,
  sourceNames: readonly string[],
): void {
  const seen = new Set<string>();
  const sources = new Set(sourceNames);
  for (const name of plan.outputNames) {
    if (seen.has(name)) throw new Error(`weight transform ${plan.id}: duplicate output ${name}`);
    seen.add(name);
    const sourceName = plan.sourceByOutput.get(name);
    if (!sourceName)
      throw new Error(`weight transform ${plan.id}: no source for ${name}`);
    if (!sources.has(sourceName))
      throw new Error(`weight transform ${plan.id}: missing source tensor ${sourceName}`);
  }
}

function transformedConfig(
  raw: Record<string, unknown>,
  plan: WeightTransformPlan | undefined,
): Record<string, unknown> {
  if (!plan?.untieWordEmbeddings) return raw;
  const out: Record<string, unknown> = { ...raw, tie_word_embeddings: false };
  if (raw.text_config && typeof raw.text_config === "object") {
    out.text_config = {
      ...(raw.text_config as Record<string, unknown>),
      tie_word_embeddings: false,
    };
  }
  return out;
}

/** Summary of a mixed-precision allocation, for the sidecar + return value. */
interface MixedMeta {
  targetBpw: number;
  candidateBits: number[];
  nHigh: number;
  nLow: number;
  /** Knapsack's own BPW estimate over the analyzed layers (params-weighted,
   *  no group overhead) — distinct from the writer's achievedBpw. */
  allocBpw: number;
}

const defaultProbeSource: ProbeSource = {
  async prepare(srcDir, opts, onProgress) {
    const config = await loadModelConfig(srcDir);
    if (config.quantization) return { modelDir: srcDir, dispose() {} };

    const { mkdtempSync, rmSync } = await import("node:fs");
    const { tmpdir } = await import("node:os");
    const tempDir = mkdtempSync(join(tmpdir(), "mlx-bun-qbaseline-"));
    onProgress?.({
      stage: "sensitivity",
      message: "Unquantized source — building an 8-bit baseline for the sweep",
      progress: 0,
    });
    try {
      await writeQuantizedModelDir(
        srcDir,
        tempDir,
        {
          ...opts,
          bits: 8,
          targetBpw: undefined,
          probeSource: undefined,
        },
      );
    } catch (error) {
      rmSync(tempDir, { recursive: true, force: true });
      throw error;
    }
    return {
      modelDir: tempDir,
      dispose: () => rmSync(tempDir, { recursive: true, force: true }),
    };
  },
};

/** Acquire/use/release helper that pins the injected ProbeSource lifecycle. */
export async function withPreparedProbe<T>(
  source: ProbeSource,
  srcDir: string,
  opts: QuantizeOptions,
  run: (modelDir: string) => Promise<T>,
  onProgress?: (e: ProgressEvent) => void,
): Promise<T> {
  const prepared = await source.prepare(srcDir, opts, onProgress);
  try {
    return await run(prepared.modelDir);
  } finally {
    await prepared.dispose();
  }
}

/**
 * Run the OptiQ mixed-precision pipeline for `srcDir`:
 *   load model + tokenizer → calibration → per-layer KL sensitivity →
 *   greedy knapsack → per-module bit allocation.
 *
 * Returns a `Map<modulePath, bits>` keyed by weight-file module base path
 * (the same key the writer loop uses) plus a metadata summary. Modules not in
 * the map fall back to the uniform `opts.bits` at write time.
 */
async function computeMixedAllocation(
  srcDir: string,
  opts: QuantizeOptions,
  onProgress?: (e: ProgressEvent) => void,
): Promise<{ perLayerBits: Map<string, number>; meta: MixedMeta }> {
  const targetBpw = opts.targetBpw!;
  const groupSize = opts.groupSize;
  const candidateBits = (opts.candidateBits ?? [4, 8]).slice().sort((a, b) => a - b);
  const nCalibration = opts.nCalibration ?? 2;
  const calibrationMix = opts.calibrationMix ?? "optiq";

  const progress = (stage: string, message: string, frac: number) =>
    onProgress?.({ stage, message, progress: frac });

  progress("sensitivity", "Loading model for sensitivity analysis", 0.0);

  // The source dependency owns preparation and cleanup. The default builds a
  // temporary uniform 8-bit baseline from bf16 through the lower-level writer;
  // an injected source can point at a prebuilt probe without orchestrator
  // recursion.
  return withPreparedProbe(
    opts.probeSource ?? defaultProbeSource,
    srcDir,
    opts,
    async (probeDir) => {
      const config = await loadModelConfig(probeDir);
      const weights = await Weights.open(probeDir);
      try {
        const model = createModel(weights, config);
        const tokenizer = await loadTokenizer(srcDir);

        // Calibration: short sequences keep per-probe forward memory modest.
        progress("sensitivity", "Building calibration set", 0.02);
        const calibrationFn = loadLlmCalibration(tokenizer, {
          nSamples: nCalibration,
          seqLen: 128,
          mix: calibrationMix,
        });
        const calIds = calibrationFn();

        // Quantizable linears to probe: the model's LoRA-target linears
        // (attention + MLP projections), keyed by full module path.
        const layers = model.loraTargets();

        progress(
          "sensitivity",
          `Probing ${layers.size} layers × ${candidateBits.length} bit-widths`,
          0.05,
        );
        const sensitivity: SensitivityResult[] = analyzeSensitivityExact(
          model,
          layers,
          calIds,
          { candidateBits, groupSize },
          (done, total, layerName) =>
            progress(
              "sensitivity",
              `Sensitivity ${done}/${total}: ${layerName}`,
              0.05 + 0.85 * (done / Math.max(total, 1)),
            ),
        );

        // Greedy knapsack → per-layer bit allocation.
        progress("allocating", "Optimizing per-layer bit allocation", 0.92);
        const opt = optimizeMixedPrecision(sensitivity, {
          targetBpw,
          candidateBits,
          groupSize,
        });

        const perLayerBits = new Map<string, number>();
        for (const c of opt.configs) perLayerBits.set(c.layerName, c.bits);

        const meta: MixedMeta = {
          targetBpw,
          candidateBits,
          nHigh: opt.nHighBits,
          nLow: opt.nLowBits,
          allocBpw: opt.achievedBpw,
        };

        progress(
          "allocating",
          `Allocated ${opt.nHighBits} high / ${opt.nLowBits} low (alloc bpw ${opt.achievedBpw.toFixed(2)})`,
          0.95,
        );

        return { perLayerBits, meta };
      } finally {
        weights.dispose();
        clearCache();
      }
    },
    onProgress,
  );
}
