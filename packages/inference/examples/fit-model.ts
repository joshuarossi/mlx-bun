import { readdir, stat } from "node:fs/promises";
import { join } from "node:path";
import { loadModelConfig } from "@mlx-bun/inference/artifacts/config";
import { fit, thisMachine, type MachineSpec } from "@mlx-bun/inference/execution/fit";

/** Estimate whether one checkpoint directory fits a machine at a context length.
 *  Weight bytes here are every `.safetensors` file in the directory: a sidecar
 *  such as a vision tower counts as resident weight, and MoE expert bytes are
 *  not separated, so the decode estimate assumes every weight is read per token.
 *  A registry that classifies files (such as `@mlx-bun/hub`) supplies exact
 *  language-weight and expert bytes. Estimates are advisory. */
export async function fitModel(modelDir: string, contextTokens: number, machine: MachineSpec = thisMachine()) {
  const config = await loadModelConfig(modelDir);
  let weightsBytes = 0;
  for (const name of await readdir(modelDir))
    if (name.endsWith(".safetensors")) weightsBytes += (await stat(join(modelDir, name))).size;
  return fit(config, weightsBytes, contextTokens, machine);
}

if (import.meta.main) {
  const [modelDir, context = "8192"] = process.argv.slice(2);
  if (!modelDir) throw new Error("usage: bun packages/inference/examples/fit-model.ts <model-directory> [context-tokens]");
  const { fits, maxSafeContext, totalBytes, predictedDecodeTps } = await fitModel(modelDir, Number(context));
  console.log({ fits, maxSafeContext, totalBytes, predictedDecodeTps });
}
