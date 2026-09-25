import type { Emit, JobRunner } from "../jobs/protocol";
import { resolveSrcDir } from "./inspect";
import type { quantizeModelDir, QuantizeOptions } from "@mlx-bun/quantize/quantizer";
import type { automaticRotationWeightTransform } from "@mlx-bun/quantize/weight-transform";

export function createQuantizeRunner(supplied: Partial<{
  quantize: typeof quantizeModelDir; rotation: typeof automaticRotationWeightTransform;
}> = {}): JobRunner {
 return async (emit: Emit, config) => {
  const outDir = String(config.out_dir ?? "");
  if (!outDir) throw new Error("quantize job: missing out_dir");

  const bits = Number(config.bits ?? 4) as 4 | 8;
  const groupSize = Number(config.group_size ?? 64) as 32 | 64;
  if (bits !== 4 && bits !== 8) throw new Error(`quantize job: bits must be 4 or 8 (got ${bits})`);
  if (groupSize !== 32 && groupSize !== 64)
    throw new Error(`quantize job: group_size must be 32 or 64 (got ${groupSize})`);

  const srcDir = resolveSrcDir(config);

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
