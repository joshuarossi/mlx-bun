// The chat-completions core, shared by every chat-shaped protocol surface:
// /v1/chat/completions calls it directly; /v1/messages (Anthropic) and
// /v1/responses translate their bodies into this shape and the Response
// back — generation, tools, vision/audio/video prompt building, stop
// sequences, prompt cache, grammar, and admission control all live here
// exactly once. Built ONCE per server (createChatHandler) with its
// collaborators injected; the returned handler is per-request. Extracted
// from src/server.ts (repo-taming Phase 4).
import { ensureWav } from "../audio/transcode";
import { DiffusionGemmaModel } from "../model/diffusion-gemma";
import { Gemma4Model } from "../model/gemma4";
import { Qwen35Model } from "../model/qwen3_5";
import type { PromptCache } from "../prompt-cache";
import { runtimeValue } from "../runtime-config";
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
  validateLogprobsParams,
  validateReasoningEffort,
  type ChatRequest,
} from "./chat-request";
import {
  CompletionRejected,
  prepareCompletion,
  type CompletionExecutor,
  type CompletionSummary,
  type PreparedCompletion,
} from "./completion-executor";
import {
  createTimedFlowControl,
  type CompletionEvent,
  type CompletionStreamProtocol,
} from "./completion-sink";
import type { Vision } from "./generation-gateway";
import { getAudioTower, getVisionTower, type ServerContext } from "./model-host";
import type { PromptResponseTrace } from "./prompt-response-trace";
import { RequestOwnership } from "./request-plan";
import type { RequestPrep } from "./request-prep";
import { StopMatcher, ThinkingTagSplitter } from "./token-streams";

// OpenAI-shaped usage blocks: the wire protocol's fields, plus mlx-bun's
// `lane` (batch|serial|spec…) on the final/non-stream summary.
export const completionProtocolUsage = (usage: CompletionSummary["usage"]) => ({
    prompt_tokens: usage.promptTokens,
    completion_tokens: usage.completionTokens,
    total_tokens: usage.totalTokens,
    prompt_tokens_details: { cached_tokens: usage.cachedTokens },
    ...(usage.speculation ? { speculation: usage.speculation } : {}),
  });
export const completionUsage = (summary: CompletionSummary) => ({
    ...completionProtocolUsage(summary.usage),
    lane: summary.lane,
  });

export interface ChatHandlerDeps {
  ctx: ServerContext;
  prep: RequestPrep;
  promptCache: Pick<PromptCache, "peekPrefixLen">;
  completionExecutor: Pick<CompletionExecutor, "execute">;
  /** Admission ceiling (fit() / the GLM memory plan), resolved once. */
  maxSafeContext: number;
  /** `serve --adapter <dir>` startup default; a request's explicit
   *  `adapter` (incl. "none") wins. */
  defaultAdapter?: string;
}

export type ChatHandler = (
  body: ChatRequest,
  signal: AbortSignal,
  streamProtocol?: CompletionStreamProtocol,
  requestId?: string,
  trace?: PromptResponseTrace,
) => Promise<Response>;

export function createChatHandler(deps: ChatHandlerDeps): ChatHandler {
  const { ctx, promptCache, completionExecutor, maxSafeContext, defaultAdapter } = deps;
  const {
    toOptions, promptIdsFor, stableLenFor, templateOptionsFor, toolRouter,
    compileGrammarForRequest,
  } = deps.prep;

  const handleChat = async (
    body: ChatRequest,
    signal: AbortSignal,
    streamProtocol?: CompletionStreamProtocol,
    requestId?: string,
    trace?: PromptResponseTrace,
  ): Promise<Response> => {
    if (!Array.isArray(body.messages) || body.messages.length === 0)
      return Response.json({ error: { message: "messages required" } }, { status: 400 });
    // mlx-lm validates logprobs params up front (ValueError → 400)
    const lpParamError = validateLogprobsParams(body);
    if (lpParamError)
      return Response.json({ error: { message: lpParamError } }, { status: 400 });
    // Covers /v1/messages and /v1/responses too — both funnel through
    // this handler after translation.
    const effortError = validateReasoningEffort(body);
    if (effortError)
      return Response.json({ error: { message: effortError } }, { status: 400 });

    const id = requestId ?? `chatcmpl-${crypto.randomUUID()}`;
    const closePromptPrepare = trace?.begin("request.prompt_prepare");
    const created = Math.floor(Date.now() / 1000);
    const tools =
      body.tool_choice === "none" ? null : (body.tools?.length ? body.tools : null);
    const hasImages = body.messages.some(
      (m) => Array.isArray(m.content) &&
        m.content.some((p: any) => p.type === "image_url" || p.type === "image"),
    );
    // Same shapes extractAudio accepts: OpenAI-canonical input_audio plus
    // optiq's audio / audio_url aliases (docs/design/generic-model-support.md §3.2).
    const hasAudio = body.messages.some(
      (m) => Array.isArray(m.content) &&
        m.content.some(
          (p: any) => p.type === "input_audio" || p.type === "audio" || p.type === "audio_url",
        ),
    );
    // Video content parts (video_url / video with base64 data) —
    // Qwen3.5-family only (decoded to sampled frames via the
    // AVFoundation sidecar, vision/video-frames.ts).
    const hasVideos = body.messages.some(
      (m) => Array.isArray(m.content) &&
        m.content.some((p: any) => p.type === "video_url" || p.type === "video"),
    );
    let promptIds: number[];
    let stableLen: number | null = null;
    // Whether the prompt primed an open <think> (Qwen3.5/MiniCPM5 thinking
    // on) so the model's output starts mid-reasoning — seeds the splitter.
    // Vision is Gemma4-only (no switchable thinking channel), so it's false.
    let startInThinking = false;
    let vision: Vision | undefined;
    let diffusionPixels: import("../mlx/array").MlxArray | null = null;
    const ownership = new RequestOwnership();
    // Grammar-constrained decoding (src/grammar.ts). Compile BEFORE prompt
    // rendering: on the degrade path (compile failed but a constraint was
    // requested) inject a system message instructing valid JSON so the
    // model still best-efforts schema-conformant output (oMLX parity —
    // _compile_grammar_for_request returning None + build_json_system_prompt).
    let grammarCtrl: import("../grammar").GrammarController | null = null;
    let grammarWarning: string | null = null;
    const grammarReq =
      body.response_format != null || !!body.guided_grammar ||
      !!body.guided_regex || !!body.guided_choice?.length ||
      body.structured_outputs != null;
    if (grammarReq) {
      const g = await compileGrammarForRequest(body);
      grammarCtrl = ownership.own(g.controller);
      if (!g.controller && g.degradeHint) {
        const degraded = applyGrammarDegrade(body, g.degradeHint);
        grammarWarning = degraded.warning;
        body = degraded.body;
      }
    }
    const rejectBeforeRun = (response: Response): Response => {
      ownership.dispose();
      return response;
    };
    try {
      // Video is Qwen3.5-family only and never composes with audio —
      // one early guard so no downstream branch can silently drop a
      // video part (the gemma/diffusion builders don't know the type).
      if (hasVideos && (hasAudio || !(ctx.model instanceof Qwen35Model))) {
        return rejectBeforeRun(Response.json(
          { error: { message: hasAudio
              ? "video and audio content parts cannot be combined"
              : `model ${ctx.modelId} does not accept video input — video ` +
                `content parts need a Qwen3.5-family model (e.g. Qwen3.8-27B)` } },
          { status: 400 },
        ));
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
          return rejectBeforeRun(Response.json(
            {
              error: {
                message:
                  `model ${ctx.modelId} has no audio tower — audio input needs ` +
                  `a model whose config.json carries audio_config and whose ` +
                  `sidecar ships the audio tensors (e.g. gemma-4 e4b OptiQ)`,
              },
            },
            { status: 400 },
          ));
        }
        let visionSide:
          | { tower: VisionEncoder; tokenIds: VisionTokenIds }
          | undefined;
        if (hasImages) {
          const tower = getVisionTower(ctx);
          if (!tower) {
            return rejectBeforeRun(Response.json(
              { error: { message: "model has no vision sidecar" } }, { status: 400 },
            ));
          }
          visionSide = { tower, tokenIds: ctx.visionTokenIds };
        }
        const { messages: withAudioParts, images } =
          await extractImages(normalizeMessages(body.messages));
        const { messages, audio } = await extractAudio(withAudioParts);
        // Non-WAV containers (mp3/m4a/flac/ogg/aiff/…) transcode to
        // 16 kHz WAV via CoreAudio; RIFF bytes pass through untouched.
        // Failures throw into the prompt-build 400 below.
        const wavs = await Promise.all(audio.map(ensureWav));
        // The towers are only ever non-null for Gemma4 (loader gates).
        const mp = await buildMultimodalPrompt(
          ctx.model as Gemma4Model,
          {
            ...(visionSide ? { vision: visionSide } : {}),
            audio: { tower: audioTower, tokenIds: ctx.audioTokenIds },
          },
          ctx.tokenizer, ctx.template, messages, images, wavs, tools,
        );
        promptIds = mp.ids;
        // bidirMask is null whenever audio is present (§3.3 Q1: mixed
        // prompts run fully causal); the union mask does the per-layer
        // id zeroing either way.
        vision = {
          embeddings: mp.embeddings,
          ...(mp.bidirMask ? { imageMask: mp.bidirMask } : {}),
          multimodalMask: mp.multimodalMask,
        };
      } else if (hasImages && ctx.model instanceof DiffusionGemmaModel) {
        // DiffusionGemma image-text-to-text: its OWN dedicated SigLIP tower +
        // encoder vision merge feed the denoising engine (NOT the AR
        // forwardEmbeddings path). v1 supports a single image.
        const dm = ctx.model;
        if (!dm.visionTower) {
          return rejectBeforeRun(Response.json(
            { error: { message: "this checkpoint has no vision tower" } }, { status: 400 },
          ));
        }
        const { messages, images } = await extractImages(normalizeMessages(body.messages));
        if (images.length !== 1) {
          return rejectBeforeRun(Response.json(
            { error: { message: "DiffusionGemma image input supports exactly one image" } },
            { status: 400 },
          ));
        }
        const rendered = ctx.template.render(messages, { tools, addGenerationPrompt: true });
        const rawIds = ctx.tokenizer.encode(rendered, /* addSpecialTokens */ false);
        const { pixels, softTokens } = await dm.visionTower.preprocess(images[0]!);
        diffusionPixels = ownership.own(pixels);
        promptIds = spliceImageTokens(rawIds, [softTokens], {
          image: ctx.visionTokenIds.imageTokenId,
          boi: ctx.visionTokenIds.boiTokenId,
          eoi: ctx.visionTokenIds.eoiTokenId,
        });
      } else if ((hasImages || hasVideos) && ctx.model instanceof Qwen35Model) {
        // Qwen3.8 vision + video: the tower is a Qwen3VLVisionTower
        // riding the shared lazy slot (makeVisionLoader's qwen branch);
        // image/video spans splice into input embeddings and the request
        // carries mRoPE positions + delta (PLAN 14v/14w). Videos decode
        // to sampled frames via the AVFoundation sidecar.
        const tower = getVisionTower(ctx) as unknown as Qwen3VLVisionTower | null;
        if (!tower) {
          return rejectBeforeRun(Response.json(
            { error: { message: "model has no vision sidecar" } }, { status: 400 },
          ));
        }
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
          templateOptionsFor(body, tools),
          videos,
        );
        promptIds = vp.ids;
        vision = { embeddings: vp.embeddings, mrope: vp.mrope };
      } else if (hasImages) {
        // Loads (and caches) the tower on first image request — text-only
        // sessions never pay for it.
        const tower = getVisionTower(ctx);
        if (!tower) {
          return rejectBeforeRun(Response.json(
            { error: { message: "model has no vision sidecar" } }, { status: 400 },
          ));
        }
        const { messages, images } = await extractImages(normalizeMessages(body.messages));
        // The tower is only ever non-null for Gemma4 (sidecar gate in
        // makeVisionLoader), so the model narrow is safe here.
        const vp = await buildVisionPrompt(
          ctx.model as Gemma4Model, tower, ctx.tokenizer, ctx.template,
          messages, images, ctx.visionTokenIds, tools,
        );
        promptIds = vp.ids;
        vision = { embeddings: vp.embeddings, imageMask: vp.imageMask };
      } else {
        const built = promptIdsFor(body, tools);
        promptIds = built.ids;
        startInThinking = built.startInThinking;
        stableLen = -1; // marker: chat path, probe lazily below
      }
    } catch (e) {
      return rejectBeforeRun(Response.json(
        { error: { message: `prompt build failed: ${(e as Error).message}` } },
        { status: 400 },
      ));
    }
    ownership.own(vision?.embeddings);
    ownership.own(vision?.imageMask);
    ownership.own(vision?.multimodalMask);
    ownership.own(diffusionPixels);
    let options: ReturnType<typeof toOptions>;
    try {
      options = toOptions(body);
      // Stable cache boundary for the prompt-boundary snapshot (chat
      // prompts end in a generation primer the next turn won't contain).
      // The probe costs a second full render+encode (~150 ms at 16k), so
      // run it ONLY when a snapshot can actually be taken: the cache
      // must not already hold the strict prefix (warm repeats peek at
      // len-1 → skip; the snapshot gate needs boundary > cached prefix).
      if (stableLen !== null) {
        const cachePeek = promptCache.peekPrefixLen(
          promptIds, options.adapters?.join("+") ?? "");
        if (cachePeek < promptIds.length - 1)
          options.snapshotAt = stableLenFor(body, tools, promptIds);
      }
    } catch (e) {
      // bad logit_bias (non-numeric keys/values) — mlx-lm's coercion error
      return rejectBeforeRun(
        Response.json({ error: { message: (e as Error).message } }, { status: 400 }),
      );
    }
    if (diffusionPixels) options.visionPixels = diffusionPixels;
    // Attach the compiled grammar controller (null when no constraint /
    // degrade — generate() runs the unmasked fast pipelined loop).
    if (grammarCtrl) options.grammar = grammarCtrl;
    const requestedMaxTokens = options.maxTokens ?? 1024;
    let adapterIds: string[];
    try {
      // A request's explicit `adapter` (incl. "none") wins over the
      // startup default from `serve --adapter <dir>`.
      adapterIds = ctx.adapters.resolveSpec(body.adapter ?? defaultAdapter);
    } catch (e) {
      return rejectBeforeRun(
        Response.json({ error: { message: (e as Error).message } }, { status: 400 }),
      );
    }

    const wantLogprobs = body.logprobs === true;
    const topLogprobs =
      typeof body.top_logprobs === "number" && body.top_logprobs > 0
        ? body.top_logprobs : 0;
    let prepared: PreparedCompletion;
    try {
      prepared = prepareCompletion({
        requestId: id,
        plan: {
          promptIds,
          options,
          requestedMaxTokens,
          maxSafeContext: maxSafeContext,
          stream: body.stream === true,
          wantLogprobs,
          topLogprobs,
          adapterIds,
          hasVision: !!vision,
          userSeed: body.seed !== undefined,
          hasGrammar: !!grammarCtrl,
          hasDraft: !!ctx.draft,
          ownership,
        },
        vision,
        pipeline: {
          router: toolRouter(tools),
          stopper: new StopMatcher(options.stopSequences),
          thinking: new ThinkingTagSplitter(
            ctx.template.thinkingFormat === "think-tag",
            startInThinking,
          ),
          collectToolCalls: true,
        },
        ...(body.stream
          ? {
              createFlowControl: ({ mechanism }) =>
                createTimedFlowControl(mechanism === "serial"),
            }
          : {}),
        onPlacement: ({ mechanism, shape }) => {
          if (runtimeValue("MLX_BUN_LANE_DEBUG") === "1")
            console.error(
              `[scheduling] mechanism=${mechanism} shape=${JSON.stringify(shape)} ` +
                `t=${Date.now() % 100000}`,
            );
        },
        idToToken: (tokenId) => ctx.tokenizer.idToToken(tokenId),
      });
    } catch (error) {
      closePromptPrepare?.();
      trace?.finish("error", { stage: "prepare_completion" });
      if (!(error instanceof CompletionRejected)) throw error;
      return Response.json({ error: error.error }, { status: error.status });
    }
    closePromptPrepare?.();

    if (body.stream) {
      const streamAbort = new AbortController();
      const generationSignal = AbortSignal.any([signal, streamAbort.signal]);
      let cancelled = false;
      const stream = new ReadableStream<Uint8Array>({
        start(controller) {
          const enc = new TextEncoder();
          const send = (obj: unknown) => {
            if (!generationSignal.aborted)
              controller.enqueue(enc.encode(`data: ${JSON.stringify(obj)}\n\n`));
          };
          const emitFrames = (frames: string[]) => {
            if (generationSignal.aborted) return;
            for (const frame of frames) controller.enqueue(enc.encode(frame));
          };
          let latestUsage: Readonly<CompletionSummary["usage"]> | null = null;
          let wroteFirstEvent = false;
          let traceOutcome: "success" | "error" | "abort" = "success";
          const chunk = (delta: Record<string, unknown>, finish: string | null) => ({
            id, object: "chat.completion.chunk", created, model: ctx.modelId,
            choices: [{ index: 0, delta, finish_reason: finish }],
          });
          void (async () => {
            try {
            // The gateway owns lane selection + GPU exclusivity; this body
            // runs per-request (concurrently in batched mode, each writing
            // its own SSE stream — the per-row fan-out).
            if (streamProtocol) emitFrames(streamProtocol.start());
            else send(chunk({ role: "assistant", content: "" }, null));
            const sendEvents = (events: readonly CompletionEvent[]) => {
              if (events.length && !wroteFirstEvent) {
                wroteFirstEvent = true;
                trace?.mark("response.first_write");
              }
              if (streamProtocol) {
                emitFrames(streamProtocol.addEvents([...events]));
                return;
              }
              for (const event of events) {
                if (event.type === "reasoning") {
                  send(chunk({ reasoning: event.text }, null));
                } else if (event.type === "content") {
                  send(chunk({ content: event.text }, null));
                } else {
                  send(chunk({
                    tool_calls: event.calls.map((call, index) => ({ index, ...call })),
                  }, null));
                }
              }
            };
            const summary = await completionExecutor.execute(prepared, {
              signal: generationSignal,
              trace,
              onEvents: sendEvents,
              ...(streamProtocol
                ? { onUsageProgress: (usage) => { latestUsage = usage; } }
                : {}),
            });
            const usage = completionUsage(summary);
            if (streamProtocol) {
              emitFrames(streamProtocol.finish(summary.finishReason, usage));
            } else {
              send({ ...chunk({}, summary.finishReason), usage });
              // bare sentinel per the OpenAI spec — strict SDK clients
              // require the unquoted terminator.
              controller.enqueue(enc.encode("data: [DONE]\n\n"));
            }
            trace?.mark("response.final_write");
            } catch (e) {
              traceOutcome = generationSignal.aborted ? "abort" : "error";
              if (!generationSignal.aborted) {
                const message = (e as Error).message;
                if (streamProtocol) {
                  emitFrames([
                    ...streamProtocol.error(message),
                    ...streamProtocol.finish(
                      "stop",
                      latestUsage ? completionProtocolUsage(latestUsage) : {},
                    ),
                  ]);
                } else {
                  send({ error: { message } });
                }
              }
            } finally {
              trace?.finish(traceOutcome);
              if (!cancelled) {
                if (generationSignal.aborted) controller.error(generationSignal.reason);
                else controller.close();
              }
            }
          })();
        },
        cancel(reason) {
          cancelled = true;
          streamAbort.abort(reason);
        },
      });
      return new Response(stream, {
        headers: {
          "content-type": "text/event-stream",
          "cache-control": "no-cache",
          connection: "keep-alive",
          ...(grammarWarning ? { Warning: grammarWarning } : {}),
        },
      });
    }

    try {
      {
        const summary = await completionExecutor.execute(prepared, { signal, trace });
        trace?.mark("response.final_write");
        const response = Response.json({
          id, object: "chat.completion", created, model: ctx.modelId,
          choices: [{
            index: 0,
            message: {
              role: "assistant",
              content: summary.content || (summary.toolCalls.length ? null : ""),
              ...(summary.reasoning ? { reasoning: summary.reasoning } : {}),
              ...(summary.toolCalls.length ? { tool_calls: summary.toolCalls } : {}),
            },
            ...(summary.logprobs ? { logprobs: summary.logprobs } : {}),
            finish_reason: summary.finishReason,
          }],
          usage: completionUsage(summary),
        }, grammarWarning ? { headers: { Warning: grammarWarning } } : undefined);
        trace?.finish("success");
        return response;
      }
    } catch (e) {
      trace?.finish(signal.aborted ? "abort" : "error");
      // A 500 with no server-side trace is undebuggable in the field —
      // always log the stack (the JSON body keeps only the message).
      console.error(`[serve] 500 on chat request:\n${(e as Error).stack ?? e}`);
      return Response.json({ error: { message: (e as Error).message } }, { status: 500 });
    }
  };

  return handleChat;
}
