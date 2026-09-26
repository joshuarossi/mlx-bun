import { Registry, DEFAULT_HUB, visionCapable, audioCapable } from "@mlx-bun/hub";

/** Scan a Hugging Face cache and list the models it holds. The registry reads
 *  config.json and safetensors headers only; it never loads tensors or MLX. */
export async function listModels(hubDir: string) {
  const registry = new Registry(":memory:");
  try {
    await registry.scan(hubDir);
    return registry.list().map((record) => ({
      repoId: record.repoId,
      modelType: record.modelType,
      weightsBytes: record.sizeBytes,
      expertsBytes: record.expertsBytes,
      vision: visionCapable(record),
      audio: audioCapable(record),
    }));
  } finally {
    registry.close();
  }
}

if (import.meta.main) {
  const [hub = DEFAULT_HUB] = process.argv.slice(2);
  console.log(await listModels(hub));
}
