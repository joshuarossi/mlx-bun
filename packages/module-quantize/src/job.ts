import type { JobEmit, JobRunner, ModelCatalog } from "@mlx-bun/app-core";
import { resolveSrcDir } from "./inspect";
import { CONVERT_DTYPES } from "./output-name";
import type { quantizeModelDir, QuantizeOptions, ConvertDtype } from "@mlx-bun/quantize/quantizer";
import type { convertModelDir } from "@mlx-bun/quantize/convert";
import type { automaticRotationWeightTransform } from "@mlx-bun/quantize/weight-transform";
import type { quantizeTrellisModelDir } from "@mlx-bun/quantize/trellis-quantizer";

/** The quantize job's producer. `catalog` resolves a `model_id` source; `supplied` replaces the native producers (tests). */
export function createQuantizeRunner(catalog: Pick<ModelCatalog, "find">, supplied: Partial<{
  quantize: typeof quantizeModelDir; rotation: typeof automaticRotationWeightTransform; convert: typeof convertModelDir;
  trellis: typeof quantizeTrellisModelDir;
}> = {}): JobRunner {
 return async (emit: JobEmit, config) => {
  const outDir = String(config.out_dir ?? "");
  if (!outDir) throw new Error("quantize job: missing out_dir");

  const dtype = config.dtype === undefined ? undefined : String(config.dtype) as ConvertDtype;
  if (dtype !== undefined && !CONVERT_DTYPES.includes(dtype))
    throw new Error(`quantize job: dtype must be float16, bfloat16 or float32 (got ${String(config.dtype)})`);

  // No quantization requested: rewrite the checkpoint with --dtype and/or dequantized weights.
  if (config.quantize === false) {
    const srcDir = await resolveSrcDir(catalog, config);
    emit({ type: "stage", stage: "starting", progress: 0.01,
      message: `Converting ${srcDir}${config.dequantize ? " → dense" : ""}${dtype ? ` (${dtype})` : ""}` });
    const convert = supplied.convert ?? (await import("@mlx-bun/quantize/convert")).convertModelDir;
    const r = await convert(srcDir, outDir, { dtype, dequantize: config.dequantize === true },
      (e) => emit({ type: "stage", stage: e.stage, progress: e.progress, message: e.message }));
    emit({ type: "stage", stage: "done", progress: 1,
      message: r.nDequantized ? `Dequantized ${r.nDequantized} modules` : "Converted", output_dir: r.outDir });
    return { outputPath: r.outDir };
  }

  // Packed Trellis (TCQ) MLP tensors on the rotation-folded checkpoint: its own producer and options.
  if (config.mode === "trellis") {
    const srcDir = await resolveSrcDir(catalog, config);
    const seed = Number(config.rotation_seed ?? 42);
    if (!Number.isInteger(seed)) throw new Error(`quantize job: rotation_seed must be an integer (got ${String(config.rotation_seed)})`);
    const downAxis = config.trellis_down_axis === undefined ? "out" : String(config.trellis_down_axis);
    if (downAxis !== "out" && downAxis !== "in") throw new Error(`quantize job: trellis_down_axis must be out or in (got ${downAxis})`);
    emit({ type: "stage", stage: "starting", progress: 0.01, message: `Quantizing ${srcDir} → packed trellis (Viterbi encode, slow)` });
    const trellis = supplied.trellis ?? (await import("@mlx-bun/quantize/trellis-quantizer")).quantizeTrellisModelDir;
    const r = await trellis(srcDir, outDir, {
      bits: Number(config.trellis_bits ?? 3), seed, downAxis,
      ...(config.trellis_k_map ? { kMap: { path: String(config.trellis_k_map), ...(config.trellis_k_budget ? { budget: String(config.trellis_k_budget) } : {}) } } : {}),
      ...(config.trellis_ldlq ? { ldlq: String(config.trellis_ldlq) } : {}),
      ...(Array.isArray(config.trellis_reuse) ? { reuse: config.trellis_reuse.map(String) } : {}),
      ...(config.trellis_interleave === true ? { interleave: true } : {}),
      ...(config.trellis_layers != null ? { layers: Number(config.trellis_layers) } : {}),
    }, (e) => emit({ type: "stage", stage: e.stage, progress: e.progress, message: e.message }));
    emit({ type: "stage", stage: "done", progress: 1,
      message: `Quantized ${r.nTrellis} trellis + ${r.nAffine} affine modules (${r.effectiveBpw.toFixed(2)} bpw)`, output_dir: r.outDir });
    return { outputPath: r.outDir };
  }

  const bits = Number(config.bits ?? 4) as 4 | 8;
  const groupSize = Number(config.group_size ?? 64) as 32 | 64;
  if (bits !== 4 && bits !== 8) throw new Error(`quantize job: bits must be 4 or 8 (got ${bits})`);
  if (groupSize !== 32 && groupSize !== 64)
    throw new Error(`quantize job: group_size must be 32 or 64 (got ${groupSize})`);

  const srcDir = await resolveSrcDir(catalog, config);

  // Mixed-precision (OptiQ sensitivity sweep + knapsack) is triggered by
  // targetBpw. The server/CLI send these as snake_case in the job config — they
  // MUST be forwarded into opts or quantizeModelDir silently runs uniform.
  const targetBpw = config.target_bpw != null ? Number(config.target_bpw) : undefined;
  const mixed = targetBpw !== undefined;
  const rotationSeed = Number(config.rotation_seed ?? 42);
  if (config.rotate_weights && !Number.isInteger(rotationSeed))
    throw new Error(`quantize job: rotation_seed must be an integer (got ${String(config.rotation_seed)})`);

  emit({
    type: "stage",
    stage: "starting",
    progress: 0.01,
    message: mixed
      ? `Quantizing ${srcDir} → mixed ${targetBpw} bpw (OptiQ sensitivity sweep, ~minutes)`
      : `Quantizing ${srcDir} → ${bits}-bit (g${groupSize})`,
  });

  const quantize = supplied.quantize ?? (await import("@mlx-bun/quantize/quantizer")).quantizeModelDir;
  const rotation = config.rotate_weights ? supplied.rotation ??
    (await import("@mlx-bun/quantize/weight-transform")).automaticRotationWeightTransform : undefined;
  const opts: QuantizeOptions = {
    bits, groupSize, mode: String(config.mode ?? "affine"),
    ...(dtype ? { dtype } : {}),
    ...(targetBpw !== undefined ? { targetBpw } : {}),
    ...(Array.isArray(config.candidate_bits) ? { candidateBits: (config.candidate_bits as number[]).map(Number) } : {}),
    ...(config.reference ? { reference: String(config.reference) } : {}),
    ...(config.calibration_mix ? { calibrationMix: String(config.calibration_mix) } : {}),
    ...(config.n_calibration != null ? { nCalibration: Number(config.n_calibration) } : {}),
    ...(config.rotate_weights
      ? {
          weightTransform: rotation!({
            seed: rotationSeed,
          }),
        }
      : {}),
  };

  const r = await quantize(srcDir, outDir, opts, (e) =>
    emit({ type: "stage", stage: e.stage, progress: e.progress, message: e.message }),
  );

  emit({
    type: "stage",
    stage: "done",
    progress: 1,
    message: `Quantized ${r.nQuantized} modules (${r.achievedBpw.toFixed(2)} bpw)`,
    output_dir: r.outDir,
  });

  return { outputPath: r.outDir };
};

}
