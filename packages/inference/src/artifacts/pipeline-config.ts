import { loadModelConfig, type ModelConfig } from "./config";
import { PIPELINE_INDEX_FILE, parsePipelineIndex, pipelineComponentDir } from "./pipeline-index";

/** A text-to-image snapshot's identity and its conditioner's text geometry.
 * Pipeline loading binds this reader explicitly; the existing config.json
 * reader never inspects a pipeline index. Stage configs remain stage-owned. */
export async function loadPipelineConfig(modelDir: string): Promise<ModelConfig> {
  const file = Bun.file(`${modelDir}/${PIPELINE_INDEX_FILE}`);
  if (!await file.exists()) throw new Error(`${modelDir} is not a text-to-image pipeline snapshot: no ${PIPELINE_INDEX_FILE}`);
  const raw = await file.json();
  const index = parsePipelineIndex(raw);
  const textDir = await pipelineComponentDir(modelDir, index, "text_encoder");
  const conditioner = await loadModelConfig(textDir);
  return {
    ...conditioner, modelDir, modelType: index.className, architectures: [index.className],
    quantization: null, kvQuant: null, hasVisionSidecar: false, eosTokenIds: [], raw,
  };
}
