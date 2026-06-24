// The quantize JobRunner: wires a submitted quantize job to quantizeModelDir().
// Speaks the shared src/jobs/types.ts contract. The submit config carries the
// source model (a registry query, a model_id, or an explicit src_dir), the
// output dir, and the target bits / group size.
//
// Registers itself with the jobs runner registry on import so both the
// in-process submit path and the subprocess job-entry resolver (which
// dynamic-imports this module via KIND_MODULES) find the "quantize" runner.

import { statSync } from "node:fs";
import type { Emit, JobRunner } from "../jobs/types";
import { registerRunner } from "../jobs/runner";
import { Registry } from "../registry";
import { loadModelConfig } from "../config";
import { quantizeModelDir, type QuantizeOptions } from "./quantizer";

/** Resolve the source model directory from a job config. Accepts an explicit
 *  filesystem path (src_dir) or a registry query / model id (model_id). */
function resolveSrcDir(config: Record<string, unknown>): string {
  const srcDir = config.src_dir as string | undefined;
  if (srcDir) return srcDir;
  const modelId = config.model_id as string | undefined;
  if (!modelId) throw new Error("quantize job: missing src_dir or model_id");
  // A path-looking model_id is taken literally; otherwise resolve via registry.
  if (modelId.includes("/") && existsSyncSafe(modelId)) return modelId;
  const reg = new Registry();
  try {
    return reg.resolve(modelId).path;
  } finally {
    reg.close();
  }
}

function existsSyncSafe(p: string): boolean {
  try {
    statSync(p);
    return true;
  } catch {
    return false;
  }
}

export const quantizeRunner: JobRunner = async (emit: Emit, config) => {
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

  emit({
    type: "stage",
    stage: "starting",
    progress: 0.01,
    message: mixed
      ? `Quantizing ${srcDir} → mixed ${targetBpw} bpw (OptiQ sensitivity sweep, ~minutes)`
      : `Quantizing ${srcDir} → ${bits}-bit (g${groupSize})`,
  });

  const opts: QuantizeOptions = {
    bits, groupSize, mode: String(config.mode ?? "affine"),
    ...(targetBpw !== undefined ? { targetBpw } : {}),
    ...(Array.isArray(config.candidate_bits) ? { candidateBits: (config.candidate_bits as number[]).map(Number) } : {}),
    ...(config.reference ? { reference: String(config.reference) } : {}),
    ...(config.calibration_mix ? { calibrationMix: String(config.calibration_mix) } : {}),
    ...(config.n_calibration != null ? { nCalibration: Number(config.n_calibration) } : {}),
  };

  const r = await quantizeModelDir(srcDir, outDir, opts, (e) =>
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

/** Lightweight model inspection for the `/api/quantize/inspect` route: report
 *  whether a model is quantizable and its on-disk size, from the registry +
 *  config (never touches tensor bytes). */
export async function inspectModel(model_id: string): Promise<{
  ok: boolean;
  model_id: string;
  arch: string | null;
  support: boolean;
  size_gb: number;
  error?: string;
}> {
  try {
    let path = model_id;
    let arch: string | null = null;
    let sizeBytes = 0;

    if (!(model_id.includes("/") && existsSyncSafe(model_id))) {
      const reg = new Registry();
      try {
        const rec = reg.resolve(model_id);
        path = rec.path;
        arch = rec.modelType;
        sizeBytes = rec.sizeBytes;
      } finally {
        reg.close();
      }
    }

    const config = await loadModelConfig(path);
    arch = arch ?? config.modelType ?? (config.architectures[0] ?? null);
    // Supported = a text architecture this quantizer can walk. v1 quantizes
    // any model whose weights are plain 2D Linear/embedding tensors; we treat
    // every loadable text config as supported and let eligibility filter
    // per-tensor at quantize time.
    const support = config.text.numHiddenLayers > 0;

    return {
      ok: true,
      model_id,
      arch,
      support,
      size_gb: sizeBytes / (1 << 30),
    };
  } catch (e) {
    return {
      ok: false,
      model_id,
      arch: null,
      support: false,
      size_gb: 0,
      error: e instanceof Error ? e.message : String(e),
    };
  }
}

// Self-register on import: `kind: "quantize"` resolves both for in-process
// submit and for the subprocess job-entry (KIND_MODULES → ../quantize/job.ts).
registerRunner("quantize", quantizeRunner);
