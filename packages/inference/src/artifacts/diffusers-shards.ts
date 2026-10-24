import { SafetensorsFile, ShardedSafetensors } from "./safetensors";

/** The shard reader bound by a diffusers component loader. Converted MLX
 * components keep the ordinary names; upstream components use
 * `diffusion_pytorch_model`. The ordinary model reader stays unchanged.
 * The returned mappings belong to the caller, as with ShardedSafetensors.open. */
export async function openDiffusersShards(directory: string): Promise<ShardedSafetensors> {
  for (const filename of ["model.safetensors.index.json", "model.safetensors", "weights.safetensors"])
    if (await Bun.file(`${directory}/${filename}`).exists()) return ShardedSafetensors.open(directory);

  const shards = new ShardedSafetensors();
  try {
    const indexFile = Bun.file(`${directory}/diffusion_pytorch_model.safetensors.index.json`);
    if (await indexFile.exists()) {
      const index = await indexFile.json() as { weight_map: Record<string, string> };
      for (const [tensor, filename] of Object.entries(index.weight_map)) {
        let file = shards.files.get(filename);
        if (!file) {
          file = SafetensorsFile.open(`${directory}/${filename}`);
          shards.files.set(filename, file);
        }
        shards.tensorToFile.set(tensor, file);
      }
    } else {
      const filename = "diffusion_pytorch_model.safetensors";
      const file = SafetensorsFile.open(`${directory}/${filename}`);
      shards.files.set(filename, file);
      for (const name of file.tensors.keys()) shards.tensorToFile.set(name, file);
    }
    return shards;
  } catch (error) {
    for (const file of shards.files.values()) file.mmap.unmap();
    throw error;
  }
}
