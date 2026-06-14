// Adapter export manifest (v1): a small JSON pointing at the base model and
// the adapter directory, so a downstream consumer can mount the adapter
// without rediscovering its base.

import { mkdirSync } from "node:fs";

export interface ExportManifest {
  version: 1;
  base_model: string;
  adapter_path: string;
  method?: string;
  created_at: string;
}

/** Write `manifest.json` into `outputDir` describing an exported adapter. */
export async function exportAdapter(
  outputDir: string,
  baseModel: string,
  adapterPath: string,
  method?: string,
): Promise<ExportManifest> {
  mkdirSync(outputDir, { recursive: true });
  const manifest: ExportManifest = {
    version: 1,
    base_model: baseModel,
    adapter_path: adapterPath,
    method,
    created_at: new Date().toISOString(),
  };
  await Bun.write(`${outputDir}/manifest.json`, JSON.stringify(manifest, null, 2) + "\n");
  return manifest;
}
