// The MOSS-Image pipeline: binds the family's three stage implementations to
// the text-to-image contract. Each stage opens its own component directory on
// first use and frees its weights on release, so a 24 GB machine holds one
// stage at a time; the caller (a host's residency policy) decides when.

import { loadModelConfig, type ModelConfig } from "../../artifacts/config";
import { pipelineComponentDir, readPipelineIndex } from "../../artifacts/pipeline-index";
import { openDiffusersShards } from "../../artifacts/diffusers-shards";
import type {
  ImageConditioner, ImageDenoiser, ImageLatentDecoder, TextToImagePipeline,
} from "../../contracts/mlx/image-generation";
import type { ImageGenerationDefaults, ImageStage } from "../../contracts/portable/image-generation";
import { MossImageSchedule, parseMossImageScheduleConfig } from "./scheduler";
import { MossImageConditioner } from "./text-encoder";
import { MossImageTransformer, parseMossTransformerConfig, type MossTransformerConfig } from "./transformer";
import { Flux2VaeDecoder, parseFlux2VaeConfig, type Flux2VaeConfig } from "./vae";

/** The model card's sampling settings (Base and SFT publish the same). */
export const MOSS_IMAGE_DEFAULTS: ImageGenerationDefaults = Object.freeze({
  width: 1024, height: 1024, steps: 50, guidance: 3, negativePrompt: "", uncondSkipLayers: Object.freeze([22]),
});

/** Bytes of the tensors in a component directory whose names pass `include`. */
async function componentBytes(dir: string, include: (name: string) => boolean): Promise<number> {
  const shards = await openDiffusersShards(dir);
  try {
    let bytes = 0;
    for (const name of shards.tensorNames) if (include(name)) { const info = shards.info(name); bytes += info.end - info.begin; }
    return bytes;
  } finally {
    for (const file of shards.files.values()) file.mmap.unmap();
  }
}

class MossImagePipeline implements TextToImagePipeline {
  readonly defaults = MOSS_IMAGE_DEFAULTS;
  readonly latentChannels: number;
  readonly pixelsPerLatent: number;
  readonly depth: number;
  /** Each open (or opening) stage. */
  readonly #slots = new Map<ImageStage, Promise<{ dispose(): void }>>();
  #disposed = false;

  constructor(
    readonly schedule: MossImageSchedule,
    readonly stageBytes: Readonly<Record<ImageStage, number>>,
    readonly dirs: { readonly text: string; readonly tokenizer: string; readonly transformer: string; readonly vae: string },
    readonly transformer: MossTransformerConfig,
    readonly vae: Flux2VaeConfig,
  ) {
    this.latentChannels = transformer.latentChannels;
    this.pixelsPerLatent = vae.downsample * vae.patch;
    this.depth = transformer.numLayers;
  }

  #open<T extends { dispose(): void }>(stage: ImageStage, open: () => Promise<T>): Promise<T> {
    if (this.#disposed) return Promise.reject(new Error("the image pipeline is disposed"));
    const slot = this.#slots.get(stage);
    if (slot) return slot as Promise<T>;
    const opening = open();
    this.#slots.set(stage, opening);
    // A failed open leaves the slot empty so the next request retries.
    opening.catch(() => { if (this.#slots.get(stage) === opening) this.#slots.delete(stage); });
    return opening;
  }

  conditioner(): Promise<ImageConditioner> {
    return this.#open("conditioner", () => MossImageConditioner.open(this.dirs.text, this.dirs.tokenizer));
  }

  denoiser(): Promise<ImageDenoiser> {
    return this.#open("denoiser", () => MossImageTransformer.open(this.dirs.transformer, this.transformer));
  }

  decoder(): Promise<ImageLatentDecoder> {
    return this.#open("decoder", () => Flux2VaeDecoder.open(this.dirs.vae, this.vae));
  }

  release(stage: ImageStage): void {
    const slot = this.#slots.get(stage);
    if (!slot) return;
    this.#slots.delete(stage);
    // An open still in flight is disposed when it lands; a failed one has nothing to free.
    slot.then(component => component.dispose(), () => {});
  }

  dispose(): void {
    if (this.#disposed) return;
    for (const stage of [...this.#slots.keys()]) this.release(stage);
    this.#disposed = true;
  }
}

/** Open a MOSS-Image snapshot (Base or SFT). Reads the index and every
 * component config, checks that the transformer's latent channels equal the
 * VAE's patched latent channels, and loads no weights. */
export async function openMossImagePipeline(modelDir: string, _config: ModelConfig): Promise<TextToImagePipeline> {
  const index = await readPipelineIndex(modelDir);
  const transformer = await pipelineComponentDir(modelDir, index, "transformer");
  const text = await pipelineComponentDir(modelDir, index, "text_encoder");
  const tokenizer = await pipelineComponentDir(modelDir, index, "tokenizer", "tokenizer.json");
  const vae = await pipelineComponentDir(modelDir, index, "vae");
  const scheduler = await pipelineComponentDir(modelDir, index, "scheduler", "scheduler_config.json");
  const transformerConfig = parseMossTransformerConfig(await Bun.file(`${transformer}/config.json`).json());
  const vaeConfig = parseFlux2VaeConfig(await Bun.file(`${vae}/config.json`).json());
  if (transformerConfig.latentChannels !== vaeConfig.latentChannels * vaeConfig.patch * vaeConfig.patch)
    throw new Error(`${modelDir}: transformer latent_channels ${transformerConfig.latentChannels} != VAE latent_channels ` +
      `${vaeConfig.latentChannels} x patch ${vaeConfig.patch}^2`);
  const textConfig = await loadModelConfig(text);
  if (textConfig.text.hiddenSize !== transformerConfig.textDim)
    throw new Error(`${modelDir}: text encoder hidden_size ${textConfig.text.hiddenSize} != transformer text_dim ${transformerConfig.textDim}`);
  const schedule = new MossImageSchedule(parseMossImageScheduleConfig(await Bun.file(`${scheduler}/scheduler_config.json`).json()));
  const stageBytes = {
    conditioner: await componentBytes(text, MossImageConditioner.usesTensor),
    denoiser: await componentBytes(transformer, MossImageTransformer.usesTensor),
    decoder: await componentBytes(vae, Flux2VaeDecoder.usesTensor),
  };
  return new MossImagePipeline(schedule, stageBytes, { text, tokenizer, transformer, vae }, transformerConfig, vaeConfig);
}
