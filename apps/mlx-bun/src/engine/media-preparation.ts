// Family media preparation, bound once when a model loads. The server owns
// request validation, HTTP errors and ownership of what it receives; each
// route here borrows the loaded context's tokenizer, template, token ids and
// lazily-loaded towers, and calls the existing numerical prompt builders.
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { ObjectCache, PromptNativeWork } from "@mlx-bun/inference/contracts/portable";
import type { AudioEncoder, PixelInput, TextEmbeddingModel, Vision } from "@mlx-bun/inference/contracts/mlx";
import type { ChatMessage, ChatTemplate, LoadedTokenizer, RenderOptions, ToolDefinition } from "@mlx-bun/inference/input";
import type { AudioTokenIds, MultimodalTowers, VisionEncoder, VisionTokenIds } from "@mlx-bun/inference/input/vision";
import type { QwenVisionEncoder } from "@mlx-bun/inference/input/vision/qwen3vl-prompt";
import { declaredGraph, type RuntimeModel } from "@mlx-bun/inference/models";
import type { CheckpointAttachment } from "@mlx-bun/inference/state";
import { ensureWav } from "@mlx-bun/inference/input/audio";
import { buildMultimodalPrompt, buildVisionPrompt, extractAudio, extractImages, extractVideos } from "@mlx-bun/inference/input/vision";
import { buildQwen3VLVisionPrompt } from "@mlx-bun/inference/input/vision/qwen3vl-prompt";
import { EncoderCache } from "@mlx-bun/inference/state";

/** What a route borrows from the loaded context. The context owns the towers;
 *  `visionTower`/`audioTower` load them lazily through its own slots. */
export interface MediaSource {
  readonly modelId: string;
  readonly tokenizer: LoadedTokenizer;
  readonly template: ChatTemplate | null;
  readonly visionTokenIds: VisionTokenIds;
  readonly audioTokenIds: AudioTokenIds | null;
  visionTower(): VisionEncoder | null;
  audioTower(): AudioEncoder | null;
}

export interface MediaParts { readonly images: boolean; readonly audio: boolean; readonly videos: boolean }

export interface MediaRequest {
  /** Already normalized by the server. */
  readonly messages: ChatMessage[];
  readonly parts: MediaParts;
  readonly tools: ToolDefinition[] | null;
  /** The request's chat-template options; read only by routes that render with them. */
  readonly templateOptions: () => RenderOptions;
  readonly nativeWork: PromptNativeWork;
  readonly objects?: ObjectCache<CheckpointAttachment[]>;
}

export type MediaRejection =
  | "audio-tower-unavailable" | "vision-sidecar-unavailable" | "vision-tower-absent" | "single-image-only";

/** Every tensor here belongs to the caller once `prepare` resolves. */
export interface PreparedMedia { readonly promptIds: number[]; readonly vision?: Vision; readonly pixels?: MlxArray }

export interface MediaPreparation {
  /** Video content parts are accepted (Qwen3.5 family only). */
  readonly video: boolean;
  prepare(request: MediaRequest): Promise<PreparedMedia | { readonly rejected: MediaRejection }>;
}

type Prepared = Promise<PreparedMedia | { readonly rejected: MediaRejection }>;

/** Select the route the graph's declared media input calls for, once, at load.
 *  Audio requests share one route for every graph; its towers are only ever
 *  non-null for a graph that ships them. */
export function bindMediaPreparation(source: MediaSource, model: RuntimeModel): MediaPreparation {
  const graph = declaredGraph(model);
  const media = graph.graphCapabilities.media;
  // The graph's own token embeddings, read when a request splices them.
  const tokens: TextEmbeddingModel & { readonly config: RuntimeModel["config"] } = {
    get embed() { return graph.embed!; }, config: model.config,
  };
  const embeddings = media?.input === "embeddings" ? tokens : null;
  const withAudio = (images: (request: MediaRequest) => Prepared) => (request: MediaRequest) =>
    request.parts.audio ? prepareAudio(source, embeddings, request) : images(request);
  const video = media?.video ?? false;
  if (media?.input === "pixels")
    return { video, prepare: withAudio(request => prepareDiffusionImage(source, () => graph.pixelInput?.(), request)) };
  if (media?.input === "embeddings+positions")
    return { video, prepare: withAudio(request => prepareQwenMedia(source, tokens, request)) };
  return { video, prepare: withAudio(request => prepareTowerImages(source, embeddings, request)) };
}

function template(source: MediaSource): ChatTemplate {
  if (!source.template) throw new Error(`model ${source.modelId} has no chat template`);
  return source.template;
}

/** Audio (and MIXED image+audio) input (`02d723a:docs/design/generic-model-support.md`
 *  §6.6). One buildMultimodalPrompt call
 *  splices both media kinds in document order. A request WITH
 *  audio on a model whose tower is unavailable is an explicit 400
 *  — never a silent text-only degrade (that leniency is only for
 *  requests without the media, getVisionTower's contract). */
export async function prepareAudio(source: MediaSource, model: TextEmbeddingModel | null, request: MediaRequest): Prepared {
  const { objects, nativeWork } = request;
  const { messages: withAudioParts, images } = await extractImages(request.messages);
  const { messages, audio } = await extractAudio(withAudioParts);
  // Non-WAV containers (mp3/m4a/flac/ogg/aiff/…) transcode to
  // 16 kHz WAV via CoreAudio; RIFF bytes pass through untouched.
  // Failures throw into the prompt-build 400.
  const wavs = await Promise.all(audio.map(ensureWav));
  const loaded = await nativeWork(async (): Promise<
    { model: TextEmbeddingModel; towers: MultimodalTowers<{ softTokens: number }> } | { rejected: MediaRejection }> => {
    const audioTower = source.audioTower();
    if (!audioTower || !source.audioTokenIds || !model) return { rejected: "audio-tower-unavailable" };
    let visionSide: MultimodalTowers<{ softTokens: number }>["vision"];
    if (request.parts.images) {
      const tower = source.visionTower();
      if (!tower) return { rejected: "vision-sidecar-unavailable" };
      visionSide = { tower, tokenIds: source.visionTokenIds,
        cache: objects && tower.cacheIdentity ? new EncoderCache(objects, tower.cacheIdentity) : undefined };
    }
    return { model, towers: {
      ...(visionSide ? { vision: visionSide } : {}),
      audio: { tower: audioTower, tokenIds: source.audioTokenIds,
        cache: objects && audioTower.cacheIdentity ? new EncoderCache(objects, audioTower.cacheIdentity) : undefined },
    } };
  });
  if ("rejected" in loaded) return loaded;
  const mp = await buildMultimodalPrompt(
    loaded.model, loaded.towers, source.tokenizer, template(source),
    messages, images, wavs, request.tools, nativeWork,
  );
  // bidirMask is null whenever audio is present (mixed prompts run
  // fully causal, `02d723a:docs/design/generic-model-support.md` §6.6);
  // the union mask does the per-layer id zeroing either way.
  return {
    promptIds: mp.ids,
    vision: {
      embeddings: mp.embeddings, prefixIdentity: mp.prefixIdentity,
      ...(mp.bidirMask ? { imageMask: mp.bidirMask } : {}),
      multimodalMask: mp.multimodalMask,
    },
  };
}

/** Pixel-input image-text-to-text (the denoising graph): its own dedicated tower
 *  and encoder vision merge feed the denoising engine, not the AR embeddings
 *  path. Pixels are the denoising engine's once returned. v1 supports a single
 *  image. */
export async function prepareDiffusionImage(
  source: MediaSource, pixelInput: () => PixelInput | null | undefined, request: MediaRequest,
): Prepared {
  const tower = pixelInput();
  if (!tower) return { rejected: "vision-tower-absent" };
  const { messages, images } = await extractImages(request.messages);
  if (images.length !== 1) return { rejected: "single-image-only" };
  const rendered = template(source).render(messages, { tools: request.tools, addGenerationPrompt: true });
  const rawIds = source.tokenizer.encode(rendered, /* addSpecialTokens */ false);
  const { pixels, softTokens } = await request.nativeWork(() => tower.preprocess(images[0]!));
  try {
    const promptIds = tower.spliceTokens(rawIds, softTokens, {
      image: source.visionTokenIds.imageTokenId,
      boi: source.visionTokenIds.boiTokenId,
      eoi: source.visionTokenIds.eoiTokenId,
    });
    return { promptIds, pixels };
  } catch (error) { pixels.dispose(); throw error; }
}

/** Embeddings-with-positions vision + video: the encoder rides the shared lazy
 *  slot; image/video spans splice into input embeddings and the request
 *  carries the mRoPE positions and delta that the graph's media prompt
 *  input consumes. Videos decode to sampled frames via the
 *  AVFoundation sidecar. */
export async function prepareQwenMedia(
  source: MediaSource, model: TextEmbeddingModel & { readonly config: { readonly raw: Record<string, unknown> } },
  request: MediaRequest,
): Prepared {
  const { objects, nativeWork } = request;
  const { messages: withVideos, images } = await extractImages(request.messages);
  const { messages, videos } = await extractVideos(withVideos);
  const towers = await nativeWork(async () => {
    const tower = source.visionTower() as unknown as (QwenVisionEncoder & { readonly cacheIdentity: string }) | null;
    if (!tower) return null;
    return { tower, encoderCache: objects ? new EncoderCache(objects, tower.cacheIdentity) : undefined };
  });
  if (!towers) return { rejected: "vision-sidecar-unavailable" };
  const vp = await buildQwen3VLVisionPrompt(
    model, towers.tower, source.tokenizer, template(source), messages, images,
    {
      imageTokenId: (model.config.raw.image_token_id as number) ?? 248056,
      videoTokenId: (model.config.raw.video_token_id as number) ?? 248057,
      visionStartId: (model.config.raw.vision_start_token_id as number) ?? 248053,
      visionEndId: (model.config.raw.vision_end_token_id as number) ?? 248054,
    },
    request.templateOptions(),
    videos, nativeWork, towers.encoderCache,
  );
  return { promptIds: vp.ids, vision: { embeddings: vp.embeddings, mrope: vp.mrope, prefixIdentity: vp.prefixIdentity } };
}

/** Loads (and caches) the tower on first image request — text-only
 *  sessions never pay for it. The tower is only ever non-null for a graph
 *  that ships one (its mediaEncoders). */
export async function prepareTowerImages(source: MediaSource, model: TextEmbeddingModel | null, request: MediaRequest): Prepared {
  const { objects, nativeWork } = request;
  const { messages, images } = await extractImages(request.messages);
  const towers = await nativeWork(async () => {
    const tower = source.visionTower();
    if (!tower || !model) return null;
    return { model, tower, encoderCache: objects && tower.cacheIdentity
      ? new EncoderCache(objects, tower.cacheIdentity) : undefined };
  });
  if (!towers) return { rejected: "vision-sidecar-unavailable" };
  const vp = await buildVisionPrompt(
    towers.model, towers.tower, source.tokenizer, template(source),
    messages, images, source.visionTokenIds, request.tools, nativeWork, towers.encoderCache,
  );
  return { promptIds: vp.ids, vision: { embeddings: vp.embeddings, imageMask: vp.imageMask, prefixIdentity: vp.prefixIdentity } };
}
