import { normalizeMessages, type ChatRequestParams } from "./chat-request";
import { requireChatTemplate, type LoadedModelContext as ModelContext } from "../engine/model-host";
import { mediaRefusalMessage } from "../engine/media-preparation";
import { RequestError } from "./pipeline";
import type { RequestOwnership } from "./request-plan";
import type { RequestPrep } from "./request-prep";
import type { BuiltPrompt, PromptNativeWork } from "./prompt-contracts";

export async function buildModelPrompt(
    ctx: ModelContext,
    prep: RequestPrep,
    body: ChatRequestParams,
    tools: ChatRequestParams["tools"] | null,
    _ownership: RequestOwnership,
    nativeWork: PromptNativeWork = (work) => work(),
    objects?: import("@mlx-bun/inference/contracts/portable").ObjectCache<import("@mlx-bun/inference/state").CheckpointAttachment[]>,
  ): Promise<BuiltPrompt> {
    requireChatTemplate(ctx);
    const toolList = tools ?? null;
    const partOf = (types: string[]) => body.messages.some(
      (m) => Array.isArray(m.content) &&
        m.content.some((p: any) => types.includes(p.type)),
    );
    const hasImages = partOf(["image_url", "image"]);
    // Same shapes extractAudio accepts: OpenAI-canonical input_audio plus
    // optiq's audio / audio_url aliases (`02d723a:docs/design/generic-model-support.md` §6.6).
    const hasAudio = partOf(["input_audio", "audio", "audio_url"]);
    // Video content parts (video_url / video with base64 data) — accepted only
    // by graphs whose media route declares video (decoded to sampled frames via
    // the AVFoundation sidecar, packages/inference/src/input/vision/video-frames.ts).
    const hasVideos = partOf(["video_url", "video"]);

    // Video never composes with audio — one early guard so no downstream
    // branch can silently drop a video part.
    if (hasVideos && (hasAudio || !ctx.media.video))
      throw new RequestError(400, mediaRefusalMessage(hasAudio ? "video-with-audio" : "video-unsupported", ctx.modelId));
    if (hasImages || hasAudio || hasVideos) {
      const prepared = await ctx.media.prepare({
        messages: normalizeMessages(body.messages),
        parts: { images: hasImages, audio: hasAudio, videos: hasVideos },
        tools: toolList,
        templateOptions: () => prep.templateOptionsFor(body, toolList),
        nativeWork,
        objects,
      });
      if ("rejected" in prepared) throw new RequestError(400, mediaRefusalMessage(prepared.rejected, ctx.modelId));
      return {
        promptIds: prepared.promptIds,
        vision: prepared.vision,
        startInThinking: false,
        probeStableLen: false,
        diffusionPixels: prepared.pixels ?? null,
      };
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
