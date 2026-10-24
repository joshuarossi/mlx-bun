// Quantize a MOSS-Image snapshot (Base or SFT) into a local MLX pipeline
// directory the inference loader opens with `openImagePipeline`.
//
// A thin policy layer over this package's quantizer, applied per component:
//
//   transformer/   the 252 joint-block projections (`layers.N.proj.*`); the
//                  embedders, timestep MLP, modulations, text refiner and video
//                  head stay bf16 (the allocation unsloth's MOSS-Image INT8
//                  release uses for the DiT).
//   text_encoder/  the Qwen3.5 language model's projections and token
//                  embedding; the Gated DeltaNet's per-head `in_proj_a` and
//                  `in_proj_b` stay bf16 (Unsloth's and OptiQ's Qwen3.8
//                  allocations keep them high precision), and the vision tower
//                  (`visual.*`, never read) is copied as stored.
//   vae/, tokenizer/, scheduler/, model_index.json: copied unchanged.
//
// The source must be the full-precision release; the output keeps the snapshot
// layout, so Base and SFT quantize the same way. Nothing here serves.

import { copyFileSync, mkdirSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";
import { loadModelConfig } from "@mlx-bun/inference/artifacts/config";
import { loadPipelineConfig, openDiffusersShards, Weights } from "@mlx-bun/inference/artifacts";
import { isImageModelType } from "@mlx-bun/inference/models/support";
import { writeAtomicDirectory } from "./atomic-output";
import { quantizeModelDir, type QuantizeResult } from "./quantizer";

/** DiT modules quantized: the joint blocks' projections. */
export function mossImageTransformerPredicate(base: string): boolean {
  return /^layers\.\d+\.proj\./.test(base);
}

/** Conditioner modules quantized: the language model's projections and embedding, but not the DeltaNet's a/b heads. */
export function mossImageTextEncoderPredicate(base: string): boolean {
  return base.startsWith("language_model.") && !/\.linear_attn\.in_proj_[ab]$/.test(base);
}

export interface QuantizeMossImageOptions {
  bits: 4 | 8;
  groupSize: 32 | 64;
  onProgress?: (component: string, stage: string, message: string, progress: number) => void;
}

export interface QuantizeMossImageResult {
  readonly outDir: string;
  readonly transformer: QuantizeResult;
  readonly textEncoder: QuantizeResult;
}

/** Copy a component directory as it is (files only; the snapshot has no nesting below a component). */
function copyComponent(source: string, destination: string): void {
  mkdirSync(destination, { recursive: true });
  for (const name of readdirSync(source))
    if (statSync(join(source, name)).isFile()) copyFileSync(join(source, name), join(destination, name));
}

/** Quantize the snapshot at `srcDir` into `outDir` (which must not exist or be empty). */
export async function quantizeMossImageDir(srcDir: string, outDir: string, opts: QuantizeMossImageOptions): Promise<QuantizeMossImageResult> {
  const config = await loadPipelineConfig(srcDir);
  if (!isImageModelType(config.modelType))
    throw new Error(`quantizeMossImageDir: ${srcDir} is not a text-to-image pipeline snapshot`);
  for (const [component, tensor] of [["transformer", "layers.0.proj.q.weight"], ["text_encoder", "language_model.embed_tokens.weight"]] as const) {
    const componentConfig = await loadModelConfig(join(srcDir, component));
    if (componentConfig.quantization)
      throw new Error(`quantizeMossImageDir: ${component} is already quantized; start from the full-precision release`);
    // The tensor names from the shard index or the single file alike: an unsupported layout must fail, not convert.
    const shards = await openDiffusersShards(join(srcDir, component));
    const present = shards.tensorToFile.has(tensor);
    for (const file of shards.files.values()) file.mmap.unmap();
    if (!present) throw new Error(`quantizeMossImageDir: ${component} has no ${tensor}; this is not the MOSS-Image layout`);
  }
  const progress = (component: string) => opts.onProgress
    ? (e: { stage: string; message: string; progress: number }) => opts.onProgress!(component, e.stage, e.message, e.progress) : undefined;
  return writeAtomicDirectory(outDir, async staging => {
    copyFileSync(join(srcDir, "model_index.json"), join(staging, "model_index.json"));
    for (const component of ["vae", "tokenizer", "scheduler"]) copyComponent(join(srcDir, component), join(staging, component));
    const transformer = await quantizeModelDir(join(srcDir, "transformer"), join(staging, "transformer"),
      { bits: opts.bits, groupSize: opts.groupSize, quantizePredicate: mossImageTransformerPredicate,
        openWeights: directory => Weights.open(directory, { openShards: openDiffusersShards }) }, progress("transformer"));
    const textEncoder = await quantizeModelDir(join(srcDir, "text_encoder"), join(staging, "text_encoder"),
      { bits: opts.bits, groupSize: opts.groupSize, quantizePredicate: mossImageTextEncoderPredicate }, progress("text_encoder"));
    return { transformer, textEncoder };
  }).then(({ transformer, textEncoder }) => ({
    // The components were written under the staging directory; report where they were published.
    outDir,
    transformer: { ...transformer, outDir: join(outDir, "transformer") },
    textEncoder: { ...textEncoder, outDir: join(outDir, "text_encoder") },
  }));
}
