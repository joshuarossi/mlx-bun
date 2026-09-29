import { statSync } from "node:fs";
import type { ModelCatalog } from "@mlx-bun/app-core";
import { loadModelConfig } from "@mlx-bun/inference/artifacts/config";

const existsSyncSafe = (path: string): boolean => { try { statSync(path); return true; } catch { return false; } };

/** A path-looking id that exists is taken literally; anything else is a catalog query. */
const isLocalPath = (model: string) => model.includes("/") && existsSyncSafe(model);

/** Resolve the source model directory from a job config. Accepts an explicit
 *  filesystem path (src_dir) or a catalog query / model id (model_id). */
export async function resolveSrcDir(catalog: Pick<ModelCatalog, "find">, config: Readonly<Record<string, unknown>>): Promise<string> {
  const srcDir = config.src_dir as string | undefined;
  if (srcDir) return srcDir;
  const modelId = config.model_id as string | undefined;
  if (!modelId) throw new Error("quantize job: missing src_dir or model_id");
  if (isLocalPath(modelId)) return modelId;
  return (await catalog.find(modelId)).directory;
}

/** Lightweight model inspection for the `/api/quantize/inspect` route: report
 *  whether a model is quantizable and its on-disk size, from the catalog +
 *  config (never touches tensor bytes). */
export async function inspectModel(catalog: Pick<ModelCatalog, "find">, model_id: string): Promise<{
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

    if (!isLocalPath(model_id)) {
      const entry = await catalog.find(model_id);
      path = entry.directory;
      arch = entry.modelType ?? null;
      sizeBytes = entry.bytes;
    }

    const config = await loadModelConfig(path);
    arch = arch ?? config.modelType ?? (config.architectures[0] ?? null);
    // Supported = a text architecture this quantizer can walk. v1 quantizes
    // any model whose weights are plain 2D Linear/embedding tensors; we treat
    // every loadable text config as supported and let eligibility filter
    // per-tensor at quantize time.
    const support = config.text.numHiddenLayers > 0;

    return { ok: true, model_id, arch, support, size_gb: sizeBytes / (1 << 30) };
  } catch (e) {
    return { ok: false, model_id, arch: null, support: false, size_gb: 0, error: e instanceof Error ? e.message : String(e) };
  }
}
