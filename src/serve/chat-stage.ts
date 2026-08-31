// ChatStage: ChatRequest in, InferenceRequest out. Turns a chat conversation
// (messages, tools, media parts, sampling fields) into the prompt token ids,
// media embeddings, resolved generation options, adapter selection, grammar
// controller, and the token→text pipeline the model needs. Every chat-shaped
// surface (OpenAI chat, Anthropic Messages, Responses) runs this stage; the
// wire format is not its business.
import { ensureWav } from "../audio/transcode";
import { DiffusionGemmaModel } from "../model/diffusion-gemma";
import { Gemma4Model } from "../model/gemma4";
import { Qwen35Model } from "../model/qwen3_5";
import type { PromptCache } from "../prompt-cache";
import { spliceImageTokens } from "../vision/diffusion-vision";
import {
  buildMultimodalPrompt, buildVisionPrompt, extractAudio, extractImages, extractVideos,
  type VisionEncoder, type VisionTokenIds,
} from "../vision/prompt";
import { buildQwen3VLVisionPrompt } from "../vision/qwen3vl-prompt";
import type { Qwen3VLVisionTower } from "../vision/qwen3vl-tower";
import {
  applyGrammarDegrade,
  normalizeMessages,
  type ChatRequest,
  type ChatRequestParams,
} from "./chat-request";
import type { Vision } from "./generation-gateway";
import type { InferenceRequest } from "./inference-request";
import { getAudioTower, getVisionTower, type ServerContext } from "./model-host";
import { RequestError } from "./pipeline";
import { RequestOwnership } from "./request-plan";
import type { RequestPrep } from "./request-prep";
import { StopMatcher, ThinkingTagSplitter } from "./token-streams";

interface BuiltPrompt {
  promptIds: number[];
  vision: Vision | undefined;
  /** The prompt primed an open <think> (Qwen3.5/MiniCPM5 thinking on) so
   *  the model's output starts mid-reasoning — seeds the splitter. */
  startInThinking: boolean;
  /** Text-only chat path: probe the stable cache boundary lazily. */
  probeStableLen: boolean;
  diffusionPixels: import("../mlx/array").MlxArray | null;
}

export class ChatStage {
  constructor(
    private readonly ctx: ServerContext,
    private readonly prep: RequestPrep,
    private readonly promptCache: Pick<PromptCache, "peekPrefixLen">,
    /** Admission ceiling (fit() / the GLM memory plan), resolved once. */
    private readonly maxSafeContext: number,
    /** `serve --adapter <dir>` startup default; a request's explicit
     *  `adapter` (incl. "none") wins. */
    private readonly defaultAdapter?: string,
  ) {}

  async run(request: ChatRequest, requestId?: string): Promise<InferenceRequest> {
    const { ctx, prep } = this;
    let body = request.params;
    const id = requestId ?? `chatcmpl-${crypto.randomUUID()}`;
    const tools =
      body.tool_choice === "none" ? null : (body.tools?.length ? body.tools : null);
    const ownership = new RequestOwnership();
    const warnings: string[] = [];
    const reject = (status: number, message: string): never => {
      ownership.dispose();
      throw new RequestError(status, message);
    };

    // Grammar-constrained decoding (src/grammar.ts). Compile BEFORE prompt
    // rendering: on the degrade path (compile failed but a constraint was
    // requested) inject a system message instructing valid JSON so the
    // model still best-efforts schema-conformant output (oMLX parity —
    // _compile_grammar_for_request returning None + build_json_system_prompt).
    let grammarCtrl: import("../grammar").GrammarController | null = null;
    const grammarReq =
      body.response_format != null || !!body.guided_grammar ||
      !!body.guided_regex || !!body.guided_choice?.length ||
      body.structured_outputs != null;
    if (grammarReq) {
      const g = await prep.compileGrammarForRequest(body);
      grammarCtrl = ownership.own(g.controller);
      if (!g.controller && g.degradeHint) {
        const degraded = applyGrammarDegrade(body, g.degradeHint);
        warnings.push(degraded.warning);
        body = degraded.body;
      }
    }

    let built: BuiltPrompt;
    try {
      built = await this.buildPrompt(body, tools, ownership);
    } catch (e) {
      if (e instanceof RequestError) return reject(e.status, e.message);
      return reject(400, `prompt build failed: ${(e as Error).message}`);
    }
    const { promptIds, vision, startInThinking, diffusionPixels } = built;
    ownership.own(vision?.embeddings);
    ownership.own(vision?.imageMask);
    ownership.own(vision?.multimodalMask);
    ownership.own(diffusionPixels);

    let options: ReturnType<RequestPrep["toOptions"]>;
    try {
      options = prep.toOptions(body);
      // Stable cache boundary for the prompt-boundary snapshot (chat
      // prompts end in a generation primer the next turn won't contain).
      // The probe costs a second full render+encode (~150 ms at 16k), so
      // run it ONLY when a snapshot can actually be taken: the cache
      // must not already hold the strict prefix (warm repeats peek at
      // len-1 → skip; the snapshot gate needs boundary > cached prefix).
      if (built.probeStableLen) {
        const cachePeek = this.promptCache.peekPrefixLen(
          promptIds, options.adapters?.join("+") ?? "");
        if (cachePeek < promptIds.length - 1)
          options.snapshotAt = prep.stableLenFor(body, tools, promptIds);
      }
    } catch (e) {
      // bad logit_bias (non-numeric keys/values) — mlx-lm's coercion error
      return reject(400, (e as Error).message);
    }
    if (diffusionPixels) options.visionPixels = diffusionPixels;
    // Attach the compiled grammar controller (null when no constraint /
    // degrade — generate() runs the unmasked fast pipelined loop).
    if (grammarCtrl) options.grammar = grammarCtrl;
    // Token fast-forwarding (K3, MLX_BUN_FILL=strict): the determined-span
    // table for this request's tools. Refused for the shapes only this stage
    // can see — a compiled grammar (forced tokens are its job), media prompts
    // (embeddings prefill / mRoPE), a mounted draft model (the spec loop is a
    // different executor and never reads options.fill), and quantized-KV
    // schemes (post-conversion multi-token append is unvalidated). The
    // body-level refusals live in prep.fillPlanFor.
    let fillSession: import("../fill/fill-session").FillSession | null = null;
    if (!grammarCtrl && !vision && !diffusionPixels && !ctx.draft &&
        !options.kvBits && !options.kvConfig?.length && !options.turboQuant) {
      fillSession = prep.fillPlanFor(body, tools, promptIds);
      if (fillSession) options.fill = fillSession;
    }
    // Unset = no request-level ceiling; admission clamps to the admitted
    // context (the program is the cap).
    const requestedMaxTokens = options.maxTokens ?? Infinity;
    let adapterIds: string[];
    try {
      // A request's explicit `adapter` (incl. "none") wins over the
      // startup default from `serve --adapter <dir>`.
      adapterIds = ctx.adapters.resolveSpec(body.adapter ?? this.defaultAdapter);
    } catch (e) {
      return reject(400, (e as Error).message);
    }

    const wantLogprobs = body.logprobs === true;
    const topLogprobs =
      typeof body.top_logprobs === "number" && body.top_logprobs > 0
        ? body.top_logprobs : 0;
    return {
      requestId: id,
      stream: request.stream,
      warnings,
      plan: {
        promptIds,
        options,
        requestedMaxTokens,
        maxSafeContext: this.maxSafeContext,
        stream: request.stream,
        wantLogprobs,
        topLogprobs,
        adapterIds,
        hasVision: !!vision,
        userSeed: body.seed !== undefined,
        hasGrammar: !!grammarCtrl,
        hasDraft: !!ctx.draft,
        ownership,
      },
      ...(vision ? { vision } : {}),
      pipeline: {
        // The router's parse-failure hook disarms this request's strict fill
        // rows (and records `usage.fill.parseFallback`).
        router: prep.toolRouter(tools, fillSession ? () => fillSession!.noteParseFailure() : undefined),
        stopper: new StopMatcher(options.stopSequences),
        thinking: new ThinkingTagSplitter(
          ctx.template.thinkingFormat === "think-tag",
          startInThinking,
        ),
        collectToolCalls: true,
      },
      idToToken: (tokenId) => ctx.tokenizer.idToToken(tokenId),
    };
  }

  /** Messages (+ image / audio / video parts) → prompt token ids and media
   *  embeddings for this model family. Throws RequestError for a media kind
   *  the served model cannot take; any other throw is a prompt-build 400. */
  private async buildPrompt(
    body: ChatRequestParams,
    tools: ChatRequestParams["tools"] | null,
    ownership: RequestOwnership,
  ): Promise<BuiltPrompt> {
    const { ctx, prep } = this;
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
}
