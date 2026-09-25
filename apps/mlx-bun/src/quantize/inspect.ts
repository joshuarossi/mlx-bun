import { statSync } from "node:fs";
import { Registry } from "@mlx-bun/hub/registry";
import { loadModelConfig } from "@mlx-bun/inference/artifacts/config";

/** Resolve the source model directory from a job config. Accepts an explicit
 *  filesystem path (src_dir) or a registry query / model id (model_id). */
export function resolveSrcDir(config: Record<string, unknown>): string {
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

