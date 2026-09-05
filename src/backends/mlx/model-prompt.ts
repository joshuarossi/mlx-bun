import { ensureWav } from "../../audio/transcode";
import { DiffusionGemmaModel } from "../../model/diffusion-gemma";
import { Gemma4Model } from "../../model/gemma4";
import { Qwen35Model } from "../../model/qwen3_5";
import { spliceImageTokens } from "../../vision/diffusion-vision";
import { buildMultimodalPrompt, buildVisionPrompt, extractAudio, extractImages, extractVideos,
  type VisionEncoder, type VisionTokenIds } from "../../vision/prompt";
import { buildQwen3VLVisionPrompt } from "../../vision/qwen3vl-prompt";
import type { Qwen3VLVisionTower } from "../../vision/qwen3vl-tower";
import { normalizeMessages, type ChatRequestParams } from "../../serve/chat-request";
import { getAudioTower, getVisionTower, type ServerContext } from "../../serve/model-host";
import { RequestError } from "../../serve/pipeline";
import type { RequestOwnership } from "../../serve/request-plan";
import type { RequestPrep } from "../../serve/request-prep";
import type { BuiltPrompt } from "../../serve/model-binding";

export async function buildModelPrompt(
    ctx: ServerContext,
    prep: RequestPrep,
    body: ChatRequestParams,
    tools: ChatRequestParams["tools"] | null,
    ownership: RequestOwnership,
  ): Promise<BuiltPrompt> {
    const toolList = tools ?? null;
    const partOf = (types: string[]) => body.messages.some(
      (m) => Array.isArray(m.content) &&
        m.content.some((p: any) => types.includes(p.type)),
    );
    const hasImages = partOf(["image_url", "image"]);
    // Same shapes extractAudio accepts: OpenAI-canonical input_audio plus
    // optiq's audio / audio_url aliases (docs/design/generic-model-support.md §3.2).
    const hasAudio = partOf(["input_audio", "audio", "audio_url"]);
    // Video content parts (video_url / video with base64 data) —
    // Qwen3.5-family only (decoded to sampled frames via the
    // AVFoundation sidecar, vision/video-frames.ts).
    const hasVideos = partOf(["video_url", "video"]);
    const noMedia: Pick<BuiltPrompt, "startInThinking" | "probeStableLen" | "diffusionPixels"> =
      { startInThinking: false, probeStableLen: false, diffusionPixels: null };

    // Video is Qwen3.5-family only and never composes with audio —
    // one early guard so no downstream branch can silently drop a
    // video part (the gemma/diffusion builders don't know the type).
    if (hasVideos && (hasAudio || !(ctx.model instanceof Qwen35Model))) {
      throw new RequestError(400, hasAudio
        ? "video and audio content parts cannot be combined"
        : `model ${ctx.modelId} does not accept video input — video ` +
          `content parts need a Qwen3.5-family model (e.g. Qwen3.8-27B)`);
    }
    if (hasAudio) {
      // Audio (and MIXED image+audio) input — A4 of
      // docs/design/generic-model-support.md. One buildMultimodalPrompt call
      // splices both media kinds in document order. A request WITH
      // audio on a model whose tower is unavailable is an explicit 400
      // — never a silent text-only degrade (that leniency is only for
      // requests without the media, getVisionTower's contract).
      const audioTower = getAudioTower(ctx);
      if (!audioTower || !ctx.audioTokenIds) {
        throw new RequestError(400,
          `model ${ctx.modelId} has no audio tower — audio input needs ` +
          `a model whose config.json carries audio_config and whose ` +
          `sidecar ships the audio tensors (e.g. gemma-4 e4b OptiQ)`);
      }
      let visionSide: { tower: VisionEncoder; tokenIds: VisionTokenIds } | undefined;
      if (hasImages) {
        const tower = getVisionTower(ctx);
        if (!tower) throw new RequestError(400, "model has no vision sidecar");
        visionSide = { tower, tokenIds: ctx.visionTokenIds };
      }
      const { messages: withAudioParts, images } =
        await extractImages(normalizeMessages(body.messages));
      const { messages, audio } = await extractAudio(withAudioParts);
      // Non-WAV containers (mp3/m4a/flac/ogg/aiff/…) transcode to
      // 16 kHz WAV via CoreAudio; RIFF bytes pass through untouched.
      // Failures throw into the prompt-build 400.
      const wavs = await Promise.all(audio.map(ensureWav));
      // The towers are only ever non-null for Gemma4 (loader gates).
      const mp = await buildMultimodalPrompt(
        ctx.model as Gemma4Model,
        {
          ...(visionSide ? { vision: visionSide } : {}),
          audio: { tower: audioTower, tokenIds: ctx.audioTokenIds },
        },
        ctx.tokenizer, ctx.template, messages, images, wavs, toolList,
      );
      // bidirMask is null whenever audio is present (§3.3 Q1: mixed
      // prompts run fully causal); the union mask does the per-layer
      // id zeroing either way.
      return {
        ...noMedia,
        promptIds: mp.ids,
        vision: {
          embeddings: mp.embeddings,
          ...(mp.bidirMask ? { imageMask: mp.bidirMask } : {}),
          multimodalMask: mp.multimodalMask,
        },
      };
    }
    if (hasImages && ctx.model instanceof DiffusionGemmaModel) {
      // DiffusionGemma image-text-to-text: its OWN dedicated SigLIP tower +
      // encoder vision merge feed the denoising engine (NOT the AR
      // forwardEmbeddings path). v1 supports a single image.
      const dm = ctx.model;
      if (!dm.visionTower) throw new RequestError(400, "this checkpoint has no vision tower");
      const { messages, images } = await extractImages(normalizeMessages(body.messages));
      if (images.length !== 1)
        throw new RequestError(400, "DiffusionGemma image input supports exactly one image");
      const rendered = ctx.template.render(messages, { tools: toolList, addGenerationPrompt: true });
      const rawIds = ctx.tokenizer.encode(rendered, /* addSpecialTokens */ false);
      const { pixels, softTokens } = await dm.visionTower.preprocess(images[0]!);
      const diffusionPixels = ownership.own(pixels);
      const promptIds = spliceImageTokens(rawIds, [softTokens], {
        image: ctx.visionTokenIds.imageTokenId,
        boi: ctx.visionTokenIds.boiTokenId,
        eoi: ctx.visionTokenIds.eoiTokenId,
      });
      return { ...noMedia, promptIds, vision: undefined, diffusionPixels };
    }
    if ((hasImages || hasVideos) && ctx.model instanceof Qwen35Model) {
      // Qwen3.8 vision + video: the tower is a Qwen3VLVisionTower
      // riding the shared lazy slot (makeVisionLoader's qwen branch);
      // image/video spans splice into input embeddings and the request
      // carries mRoPE positions + delta (PLAN 14v/14w). Videos decode
      // to sampled frames via the AVFoundation sidecar.
      const tower = getVisionTower(ctx) as unknown as Qwen3VLVisionTower | null;
      if (!tower) throw new RequestError(400, "model has no vision sidecar");
      const { messages: withVideos, images } =
        await extractImages(normalizeMessages(body.messages));
      const { messages, videos } = await extractVideos(withVideos);
      const vp = await buildQwen3VLVisionPrompt(
        ctx.model, tower, ctx.tokenizer, ctx.template, messages, images,
        {
          imageTokenId: (ctx.model.config.raw.image_token_id as number) ?? 248056,
          videoTokenId: (ctx.model.config.raw.video_token_id as number) ?? 248057,
          visionStartId: (ctx.model.config.raw.vision_start_token_id as number) ?? 248053,
          visionEndId: (ctx.model.config.raw.vision_end_token_id as number) ?? 248054,
        },
        prep.templateOptionsFor(body, toolList),
        videos,
      );
      return { ...noMedia, promptIds: vp.ids, vision: { embeddings: vp.embeddings, mrope: vp.mrope } };
    }
    if (hasImages) {
      // Loads (and caches) the tower on first image request — text-only
      // sessions never pay for it.
      const tower = getVisionTower(ctx);
      if (!tower) throw new RequestError(400, "model has no vision sidecar");
      const { messages, images } = await extractImages(normalizeMessages(body.messages));
      // The tower is only ever non-null for Gemma4 (sidecar gate in
      // makeVisionLoader), so the model narrow is safe here.
      const vp = await buildVisionPrompt(
        ctx.model as Gemma4Model, tower, ctx.tokenizer, ctx.template,
        messages, images, ctx.visionTokenIds, toolList,
      );
      return { ...noMedia, promptIds: vp.ids, vision: { embeddings: vp.embeddings, imageMask: vp.imageMask } };
    }
    const text = prep.promptIdsFor(body, toolList);
    return {
      promptIds: text.ids,
      vision: undefined,
      startInThinking: text.startInThinking,
      probeStableLen: true,
      diffusionPixels: null,
    };
  }
