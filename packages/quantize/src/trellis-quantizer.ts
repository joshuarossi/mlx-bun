// Packed-Trellis quantizer for the HF Qwen3.5 layout (Qwen3.8-27B family):
// fold the checkpoint (γ + R1), code every MLP tensor with the bitshift trellis
// (QTIP TCQ, L=12, 1MAD, T=256, tail-biting) and write the on-disk packed
// format `@mlx-bun/inference` serves. Everything else follows the shipped
// compact allocation: 4-bit affine embed/lm_head/attention, 3-bit affine for the
// rest, vision tower bf16. Stock mlx-lm cannot load the result (config mode
// "trellis"); this engine can.
//
// STREAMING: source shard in → fold → code → incremental shard writer, releasing
// each source shard, so peak memory is one source shard plus one output shard
// plus the tensor in flight.
//
// Optional inputs, all of which change which codes are produced and never how:
//   * `kMap`       per-tensor bits from an allocation file (mixed k)
//   * `ldlq`       a directory of per-layer Hessian factors (layer-NNN-{mlp,down}.safetensors,
//                  tensor `L`), switching the objective to BlockLDLQ error feedback
//   * `reuse`      packed artifacts whose tensors of unchanged geometry are copied
//                  instead of re-encoded (a variant bank)
//   * `interleave` reorder eligible k=3 axis-0 codes into the two-block layout
//                  the scatter kernel reads
//
// The Hessian factors and the k-map are inputs: collecting activation Hessians
// needs a forward pass over calibration text and is not part of this producer.

import { copyFileSync, existsSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { MlxArray as Arr, cpuStream, gpuStream, type MlxArray } from "@mlx-bun/mlx/array";
import { Dtype, activeMemory, cacheMemory, clearCache } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { quantize } from "@mlx-bun/mlx/ops";
import { Weights, ShardedWriter, type WriteResult } from "@mlx-bun/inference/artifacts";
import { writeAtomicDirectory } from "./atomic-output";
import { buildQuantizationBlock, writeQuantizedConfig, type PerLayerEntry } from "./config-writer";
import type { ProgressEvent } from "./quantizer";
import { QwenFoldContext } from "./rotate";
import { planQwen35HfFold } from "./qwen35-hf-fold";
import { TRELLIS_L, TRELLIS_T, interleaveTrellisCodes } from "./trellis";
import { TrellisEncoder, loadHessianFactor, type PackedTrellisTensor } from "./trellis-encoder";
import {
  LM_PREFIX, TRELLIS_AFFINE_GROUP, TRELLIS_BASE_BITS, mlxLmPath, parseKMap, treatmentFor, trellisBpw,
  type DownAxis, type Treatment, type TrellisKMap, type TreatmentPolicy,
} from "./trellis-allocation";

/** The k=3 axis-0 two-block interleave needs whole 48-word groups (2 blocks × 24 words). */
const INTERLEAVE_WORDS = 48;
/** The trellis encoder holds ~2 GB of its own, so shards stay below the writer's default ceiling. */
const DEFAULT_SHARD_BYTES = 2 * 1024 ** 3;

export interface TrellisQuantizeOptions {
  /** Trellis bits per weight for every coded tensor without a k-map entry. Default 3. */
  bits?: number;
  /** Per-tensor bits (and affine overrides) from an allocation file's `budgets[budget]`. */
  kMap?: { path: string; budget?: string };
  /** Dim of down_proj the trellis runs along. Default `out` (the rotated dim). */
  downAxis?: DownAxis;
  /** Directory of per-layer Hessian factors; enables BlockLDLQ. */
  ldlq?: string;
  /** Packed artifacts to copy unchanged-geometry tensors from, first match wins. */
  reuse?: string[];
  /** Reorder eligible k=3 axis-0 codes into the two-block scatter layout. */
  interleave?: boolean;
  /** Trellis-code only the first N decoder layers (the rest ride the affine base tier). */
  layers?: number;
  /** Rotation seed (the MTP companion must use its trunk's). Default 42. */
  seed?: number;
  /** Coded rows per Viterbi batch; a memory knob that never changes the codes. Default 16384. */
  batch?: number;
  /** Output shard size in bytes. Default 2 GiB. */
  shardBytes?: number;
}

export interface TrellisQuantizeResult {
  outDir: string;
  nTrellis: number;
  nAffine: number;
  /** Coded bits per weight over the coded modules (fp16 row scales / affine group overhead included). */
  effectiveBpw: number;
  /** Trellis tensors copied from `reuse` sources. */
  reused: number;
  ldlq: { applied: number; guardTrips: number; missingFactors: number; trippedTensors: string[] } | null;
  write: WriteResult;
}

/** Quantize the full-precision HF-layout Qwen3.5-family checkpoint `srcDir`
 *  into a packed-Trellis artifact at `outDir` (published atomically). */
export async function quantizeTrellisModelDir(
  srcDir: string,
  outDir: string,
  opts: TrellisQuantizeOptions = {},
  onProgress?: (e: ProgressEvent) => void,
): Promise<TrellisQuantizeResult> {
  const result = await writeAtomicDirectory(outDir, (staging) => produce(srcDir, staging, opts, onProgress));
  return { ...result, outDir };
}

async function produce(
  srcDir: string,
  outDir: string,
  opts: TrellisQuantizeOptions,
  onProgress?: (e: ProgressEvent) => void,
): Promise<TrellisQuantizeResult> {
  const seed = opts.seed ?? 42;
  const bits = opts.bits ?? 3;
  const downAxis: DownAxis = opts.downAxis ?? "out";
  const ldlqDir = opts.ldlq ?? "";
  const kMapPath = opts.kMap?.path;
  const kBudget = opts.kMap?.budget ?? "3.00";
  if (!Number.isInteger(bits) || bits < 1 || bits > 8) throw new Error(`trellis bits must be an integer in [1, 8] (got ${bits})`);
  if (!Number.isInteger(seed)) throw new Error(`rotation seed must be an integer (got ${seed})`);
  const groupSize = TRELLIS_AFFINE_GROUP;
  const progress = (stage: string, message: string, fraction: number) => onProgress?.({ stage, message, progress: fraction });
  progress("loading", `Reading ${srcDir}`, 0);

  // ------------------------------------------------------------- config ---
  const raw = JSON.parse(readFileSync(join(srcDir, "config.json"), "utf8")) as Record<string, unknown>;
  if (raw.quantization || raw.quantization_config)
    throw new Error("source is already quantized — the fold needs full-precision weights");
  const textCfg = (raw.text_config ?? raw) as Record<string, unknown>;
  const hiddenSize = Number(textCfg.hidden_size);
  const numHiddenLayers = Number(textCfg.num_hidden_layers);
  const layerTypes = textCfg.layer_types as string[];

  const kMap: TrellisKMap | undefined = kMapPath
    ? parseKMap(JSON.parse(readFileSync(kMapPath, "utf8")), kBudget, `k-map ${kMapPath}`)
    : undefined;
  const policy: TreatmentPolicy = { bits, kMap, downAxis, layers: opts.layers };

  // ---------------------------------------------------------------- run ---
  const weights = await Weights.open(srcDir);
  const names = weights.tensorNames;
  const plan = (() => {
    try { return planQwen35HfFold(weights, { numHiddenLayers, layerTypes }); }
    catch (error) { weights.dispose(); throw error; }
  })();
  const { ops: foldOps, gammaNames, zeroNorms } = plan;

  const one = Arr.fromFloat32(new Float32Array(1).fill(1), [1]);
  // Stored gains are γ−1: the fold context reads γ = stored + 1.
  const gammaSource: Pick<Weights, "tensor"> = {
    tensor(name: string): MlxArray {
      const f32 = weights.tensor(name).astype(Dtype.float32, cpuStream);
      const shifted = ops.add(f32, one, cpuStream);
      shifted.eval();
      f32.dispose();
      return shifted;
    },
  };
  const ctx = new QwenFoldContext(gammaSource, hiddenSize, seed, gammaNames, true);
  const encoder = new TrellisEncoder({ batch: opts.batch });

  const zerosLike = (src: MlxArray): MlxArray => {
    const n = src.shape[0]!;
    const z = Arr.fromFloat32(new Float32Array(n), [n]);
    const out = z.astype(Dtype.bfloat16, cpuStream);
    out.eval();
    z.dispose();
    return out;
  };

  if (kMap) {
    const hist = new Map<number, number>();
    for (const k of kMap.k.values()) hist.set(k, (hist.get(k) ?? 0) + 1);
    progress("planning", `k-map ${kMapPath} budget ${kBudget}: ` +
      [...hist].sort((a, b) => a[0] - b[0]).map(([k, n]) => `k${k}×${n}`).join(" "), 0);
  }

  /** Calibration provenance, lifted verbatim from the Hessian stage's state.json
   *  so the artifact records WHICH corpus the LDLQ objective was fitted on. */
  const ldlqCalib: unknown = ldlqDir && existsSync(join(ldlqDir, "state.json"))
    ? (JSON.parse(readFileSync(join(ldlqDir, "state.json"), "utf8")) as Record<string, unknown>).calibration
    : null;

  const reuseSources = await Promise.all((opts.reuse ?? []).map(async (dir) => ({
    dir,
    weights: await Weights.open(dir),
    config: (JSON.parse(readFileSync(join(dir, "config.json"), "utf8")) as { quantization: Record<string, unknown> }).quantization,
  })));
  /** Find a trellis entry with the same k and axis in the ordered source bank. */
  const reusable = (base: string, k: number, axis: 0 | 1) =>
    reuseSources.find(({ weights: w, config }) => {
      const e = config[base] as { mode?: string; bits?: number; trellis?: { axis?: number } } | undefined;
      return !!e && e.mode === "trellis" && e.bits === k && e.trellis?.axis === axis &&
        w.has(`${base}.weight`) && w.has(`${base}.scales`);
    });

  // ----------------------------------------------------------- accounting ---
  const perLayer = new Map<string, PerLayerEntry>();
  let nAffine = 0, affineParams = 0, affineBits = 0;
  let nTrellis = 0, trellisParams = 0, trellisBits = 0;
  let ldlqApplied = 0, ldlqTrips = 0, ldlqMissing = 0;
  const trippedTensors: string[] = [];
  const kHist = new Map<number, number>();
  let reused = 0;
  const reusedBySource = new Map<string, number>();
  let interleavedTensors = 0;
  let trellisSeconds = 0;

  const writer = new ShardedWriter(outDir, { shardBytes: opts.shardBytes ?? DEFAULT_SHARD_BYTES });
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
        let folded: MlxArray;
        if (zeroNorms.has(name)) folded = zerosLike(src);
        else folded = ctx.apply(foldOps.get(name) ?? { kind: "passthrough" }, src);

        const base = name.endsWith(".weight") ? name.slice(0, -".weight".length) : null;
        const shape = folded.shape;
        const eligible = base !== null && shape.length === 2 && shape[1]! % groupSize === 0;
        const t: Treatment = eligible ? treatmentFor(base!, policy) : { kind: "bf16" };

        if (!eligible) {
          writer.add(name, folded);
        } else if (t.kind === "bf16") {
          writer.add(name, folded);
          perLayer.set(base!, false);
        } else if (t.kind === "trellis") {
          const tt = performance.now();
          let rec: PackedTrellisTensor;
          const source = reusable(base!, t.k, t.axis);
          if (source) {
            rec = {
              codes: ops.copyOf(source.weights.tensor(`${base}.weight`), gpuStream),
              scales: ops.copyOf(source.weights.tensor(`${base}.scales`), gpuStream),
            };
            ops.evalAll([rec.codes, rec.scales]);
            source.weights.release(`${base}.weight`); source.weights.release(`${base}.scales`);
            reused++;
            reusedBySource.set(source.dir, (reusedBySource.get(source.dir) ?? 0) + 1);
            ldlqApplied++; // the reused codes carry the source artifact's LDLQ
          } else if (ldlqDir) {
            const rest = base!.slice(`${LM_PREFIX}layers.`.length);
            const li = Number(rest.slice(0, rest.indexOf(".")));
            const site = base!.endsWith("mlp.down_proj") ? "down" : "mlp"; // by MODULE, not axis (downAxis "in")
            const lp = join(ldlqDir, `layer-${String(li).padStart(3, "0")}-${site}.safetensors`);
            if (!existsSync(lp)) {
              rec = encoder.encode(folded, t.axis, t.k);
              ldlqMissing++;
            } else {
              const Lm = loadHessianFactor(lp);
              const r = encoder.encodeLdlq(folded, t.axis, Lm, t.k);
              Lm.dispose();
              clearCache();
              rec = { codes: r.codes, scales: r.scales };
              if (r.tripped) {
                ldlqTrips++;
                trippedTensors.push(base!);
              } else ldlqApplied++;
            }
          } else {
            rec = encoder.encode(folded, t.axis, t.k);
          }
          trellisSeconds += (performance.now() - tt) / 1000;
          folded.dispose();
          if (opts.interleave && t.axis === 0 && t.k === 3 && rec.codes.ndim === 2 &&
              rec.codes.shape[1]! % INTERLEAVE_WORDS === 0) {
            const packed = interleaveTrellisCodes(rec.codes);
            packed.eval(); rec.codes.dispose(); rec.codes = packed;
          }
          if (rec.codes.ndim === 3) interleavedTensors++;
          writer.add(`${base}.weight`, rec.codes);
          writer.add(`${base}.scales`, rec.scales);
          perLayer.set(base!, {
            bits: t.k, groupSize: TRELLIS_T, mode: "trellis",
            trellis: { L: TRELLIS_L, code: "1mad", axis: t.axis },
          });
          const params = shape[0]! * shape[1]!;
          const cols = t.axis === 1 ? shape[1]! : shape[0]!;
          nTrellis++; trellisParams += params; trellisBits += params * trellisBpw(cols, t.k);
          kHist.set(t.k, (kHist.get(t.k) ?? 0) + 1);
        } else {
          const q = quantize(folded, groupSize, t.bits, "affine", gpuStream);
          folded.dispose();
          writer.add(`${base}.weight`, q.packed);
          writer.add(`${base}.scales`, q.scales);
          if (q.biases) writer.add(`${base}.biases`, q.biases);
          if (t.bits !== TRELLIS_BASE_BITS) perLayer.set(base!, { bits: t.bits, groupSize });
          nAffine++;
          const params = shape[0]! * shape[1]!;
          affineParams += params; affineBits += params * (t.bits + 32 / groupSize);
        }
        done++;
        progress("quantizing",
          `${done}/${names.length} tensors · trellis ${nTrellis} ` +
          `(${(trellisSeconds / 60).toFixed(1)} min, ` +
          `${trellisSeconds > 0 ? (trellisParams / 1e6 / trellisSeconds).toFixed(2) : "—"} Mw/s) · ` +
          `mlx ${(activeMemory() / 2 ** 30).toFixed(2)}+${(cacheMemory() / 2 ** 30).toFixed(2)} GiB`,
          done / names.length);
      }
      weights.releaseShard(file);
      clearCache();
    }
    const write = writer.finish();
    const totalParams = affineParams + trellisParams, totalBits = affineBits + trellisBits;

    const blockEntries = new Map<string, PerLayerEntry>();
    for (const [path, entry] of perLayer) {
      blockEntries.set(path, entry);
      // Entries land in BOTH key spaces: the qwen3_5 graph resolves module paths
      // in mlx-lm's, the artifact stores tensors in the HF space.
      const p = mlxLmPath(path);
      if (p && p !== path) blockEntries.set(p, entry);
    }
    const block = buildQuantizationBlock({ bits: TRELLIS_BASE_BITS, groupSize, mode: "affine" }, blockEntries);
    await writeQuantizedConfig(raw, outDir, block, { srcDir });
    await Bun.write(join(outDir, "optiq_metadata.json"), JSON.stringify({
      method: "rotation+trellis_tcq(mlp,packed)+rtn(rest)",
      base_model: srcDir,
      bits: TRELLIS_BASE_BITS,
      group_size: groupSize,
      trellis: {
        L: TRELLIS_L, V: 1, block: TRELLIS_T, code: "1mad",
        k: kMap ? "mixed (see k_map)" : bits,
        k_map: kMap
          ? {
              file: kMapPath, budget: kBudget,
              modules_by_k: Object.fromEntries([...kHist].sort((a, b) => a[0] - b[0]).map(([k, n]) => [`k${k}`, n])),
              per_tensor: Object.fromEntries([...kMap.k].map(([n, k]) => [n.replace(LM_PREFIX, "model."), k])),
            }
          : null,
        tail_biting: true,
        reference: "arXiv:2406.11235v3 (QTIP); Cornell-RelaxML/qtip lib/codebook/bitshift.py",
        distortion: ldlqDir
          ? "BlockLDLQ Hessian-weighted error feedback (QTIP lib/algo/ldlq.py, " +
            `block ${TRELLIS_T} = trellis T, for_kernel=False path)`
          : "unweighted squared error (no Hessian/LDLQ)",
        ldlq: ldlqDir
          ? {
              hessians: ldlqDir,
              applied: ldlqApplied, guard_trips: ldlqTrips, missing_L: ldlqMissing,
              tripped_tensors: trippedTensors,
              guard: "xn peak > 4x the unweighted normalized max -> " +
                     "fall back to unweighted Viterbi for that tensor",
              calibration: ldlqCalib,
            }
          : null,
        scale: "per coded row, fp16 (QTIP uses one per-tensor Wscale after TWO-sided IP)",
        down_axis: downAxis === "in" ? "input (un-rotated intermediate dim; plain reduce kernel)" : "output (rotated dim; scatter kernel)",
        reused_from: reuseSources.length ? {
          tensors: reused,
          sources: Object.fromEntries(reusedBySource),
        } : null,
        interleaved_modules: interleavedTensors,
        packaging: "packed: uint32 bit-stream (reversed-time symbols, tail-biting window) + fp16 row scales; " +
          "config mode \"trellis\" (packages/quantize/src/trellis.ts, packages/inference/src/layers/trellis-linear.ts); mlx-lm cannot load it",
        modules: nTrellis, params: trellisParams,
        effective_bpw: trellisParams > 0 ? trellisBits / trellisParams : 0,
      },
      achieved_bpw_coded: totalBits / totalParams,
      affine_modules: nAffine,
      total_bytes: write.totalSize,
      allocation: "shipped-compact (base 3 g64; 4-bit embed/lm_head/attn; vision bf16) with the 3-bit MLP tier replaced by the trellis",
      weight_transforms: [{
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
      if (existsSync(join(srcDir, f))) copyFileSync(join(srcDir, f), join(outDir, f));
    writeFileSync(join(outDir, "turboquant_fold.json"), JSON.stringify({
      source: srcDir, generatedAt: new Date().toISOString(), seed,
      r1: true, r2: false, hiddenSize,
      gamma_convention: "stored+1 folded in; folded norms written as zeros",
    }, null, 2));
    progress("done", `${nAffine} affine + ${nTrellis} trellis modules · ${(totalBits / totalParams).toFixed(4)} coded bpw · ` +
      `${(write.totalSize / 2 ** 30).toFixed(3)} GiB · ${((performance.now() - t0) / 60000).toFixed(1)} min`, 1);
    return {
      outDir, nTrellis, nAffine, effectiveBpw: totalBits / totalParams, reused,
      ldlq: ldlqDir ? { applied: ldlqApplied, guardTrips: ldlqTrips, missingFactors: ldlqMissing, trippedTensors } : null,
      write,
    };
  } finally {
    ctx.dispose();
    one.dispose();
    encoder.dispose();
    for (const source of reuseSources) source.weights.dispose();
    weights.dispose();
    clearCache();
  }
}
