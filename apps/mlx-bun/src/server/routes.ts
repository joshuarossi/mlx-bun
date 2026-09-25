import type { PromptCache } from "@mlx-bun/inference/state";
import type { DownloadStatus } from "@mlx-bun/hub/download";
import type { KvSchemeOptions } from "@mlx-bun/inference/state/kv-scheme";
import { runtimeValue } from "@mlx-bun/inference/runtime/config";
import { createPromptResponseTrace } from "@mlx-bun/inference/runtime/trace";
import type { LoadedModelContext as ModelContext } from "../engine/model-host";
import type { CompletionEngine } from "../engine/completion";
import type { ModelBinding } from "../engine/model-binding";
import type { GenerationGateway } from "../engine/generation-gateway";
import type { PreparationExecutor } from "../engine/preparation";
import { ChatRequest, TextCompletionRequest, type ChatRequestParams } from "./chat-request";
import { ChatStage } from "./chat-stage";
import { TextCompletionStage } from "./text-completion-stage";
import { CompletionExecutor } from "./completion-executor";
import { InferenceStage } from "./inference-request";
import { createRequestPrep, type RequestPrepOptions } from "./request-prep";
import type { PromptTokenHistory } from "./generated-token-history";
import type { ModelPromptBuilder } from "./prompt-contracts";
import { admit, errorResponse, respondJson, respondStream, type ErrorFormatter } from "./http";
import { chatCompletionJson, chatCompletionStream, textCompletionJson, textCompletionStream } from "./openai-wire";
import { createDiscoveryRoutes, type TranscriptionInfo } from "./discovery-routes";
import { anthropicToChatBody, chatJsonToAnthropic, createAnthropicStreamProtocol, type AnthropicRequest } from "./anthropic";

import { ResponseStore, resolveResponsesConversation, responsesToChatBody, chatJsonToResponses,
  createResponsesStreamProtocol, type ResponseHistory, type ResponsesRequest } from "./responses";

const anthropicError: ErrorFormatter = (status, message, body) => Response.json({ type: "error",
  error: { ...body, type: status >= 500 ? "api_error" : "invalid_request_error", message },
}, { status });

const responsesError: ErrorFormatter = (status, message, body) => Response.json({ error: {
  ...body, message, type: status >= 500 ? "server_error" : "invalid_request_error", param: null, code: body.code ?? null,
} }, { status });

/** HTTP adapters borrow the engine; the application owns its lifetime. No
 * socket, loaded model, cache, or scheduler is created by these routes. */
export function createCompletionRoutes(engine: {
  context: ModelContext;
  completion: CompletionEngine;
  preparation: PreparationExecutor;
  binding: Pick<ModelBinding, "discovery" | "embed">;
  gateway: Pick<GenerationGateway, "runExclusive">;
}, options: RequestPrepOptions & {
  promptCache: Pick<PromptCache, "peekPrefixLen"> & Partial<Pick<PromptCache, "objects">>;
  contextLimit: number | null;
  kvScheme?: KvSchemeOptions;
  defaultGeneratedTokens?: number;
  defaultAdapter?: string;
  tokenHistory?: PromptTokenHistory;
  buildPrompt?: ModelPromptBuilder;
  /** Process-local history by default; composition owns any replacement store. */
  responseHistory?: ResponseHistory;
  /** Progress rows for `GET /downloads`; the default is the hub package's process tracker. */
  downloads?: () => readonly DownloadStatus[];
  /** The Whisper companion `/v1/models` lists beside the chat model; absent means none is configured. */
  transcription?: () => Promise<TranscriptionInfo | null>;
}) {
  const ctx = engine.context;
  const responseHistory = options.responseHistory ?? new ResponseStore();
  const prep = createRequestPrep({ ctx, serverOptions: options, kvScheme: options.kvScheme ?? {},
    defaultGeneratedTokens: options.defaultGeneratedTokens, tokenHistory: options.tokenHistory });
  const chat = new ChatStage(ctx, prep, options.promptCache, options.contextLimit,
    options.defaultAdapter, engine.preparation, options.buildPrompt);
  const text = new TextCompletionStage(ctx, prep, options.contextLimit, options.defaultGeneratedTokens, options.defaultAdapter, engine.preparation);
  const inference = new InferenceStage(new CompletionExecutor(engine.completion));
  const discovery = createDiscoveryRoutes(ctx, engine.binding, Date.now(), options.transcription, undefined, options.downloads);
  const applyCacheSession = (body: ChatRequestParams, request: Request, original: unknown = body) => {
    const fields = original as { session_id?: unknown; prompt_cache_key?: unknown };
    const session = typeof fields.session_id === "string" ? fields.session_id :
      typeof fields.prompt_cache_key === "string" ? fields.prompt_cache_key :
      request.headers.get("x-session-affinity") ?? request.headers.get("session_id") ?? undefined;
    if (runtimeValue("MLX_BUN_SESSION_CACHE") !== "0") body.session_id = session;
    else { delete body.session_id; delete body.prompt_cache_key; }
  };
  return {
    invalidateLibrary: discovery.invalidateLibrary,
    responseStats: () => ({ entries: responseHistory.size, bytes: responseHistory.totalBytes,
      max_bytes: responseHistory.maxBytes, ttl_ms: responseHistory.ttlMs }),
    /** null means another app surface may handle this request. */
    async handle(request: Request): Promise<Response | null> {
      const url = new URL(request.url);
      const format = url.pathname === "/v1/messages" ? anthropicError
        : url.pathname === "/v1/responses" ? responsesError : undefined;
      try {
        const discovered = await discovery.handle(url, request);
        if (discovered) return discovered;
        if (request.method !== "POST") return null;
        if (url.pathname === "/v1/messages") {
          let body: AnthropicRequest;
          try {
            body = await request.json();
            if (!body || typeof body !== "object" || Array.isArray(body)) throw new Error("invalid JSON body");
          } catch (error) {
            return request.signal.aborted ? errorResponse(error, url.pathname, format, request.signal)
              : anthropicError(400, "invalid JSON body", {});
          }
          let chatBody: ChatRequestParams;
          try {
            chatBody = anthropicToChatBody(body) as unknown as ChatRequestParams;
            applyCacheSession(chatBody, request, body);
          } catch (error) {
            return anthropicError(400, error instanceof Error ? error.message : String(error), {});
          }
          const id = `chatcmpl-${crypto.randomUUID()}`;
          const admitted = await admit(inference, () => chat.run(new ChatRequest(chatBody), id, request.signal),
            undefined, "anthropic request", anthropicError, request.signal);
          if ("response" in admitted) return admitted.response;
          return body.stream
            ? respondStream(inference, admitted.admitted, createAnthropicStreamProtocol(ctx.modelId), request.signal)
            : respondJson(inference, admitted.admitted, result => chatJsonToAnthropic(chatCompletionJson(result,
              { id, created: Math.floor(Date.now() / 1000), model: ctx.modelId }), ctx.modelId), request.signal, undefined, anthropicError);
        }
        if (url.pathname === "/v1/responses") {
          let body: ResponsesRequest;
          try {
            body = await request.json();
            if (!body || typeof body !== "object" || Array.isArray(body)) throw new Error("invalid JSON body");
          } catch (error) {
            return request.signal.aborted ? errorResponse(error, url.pathname, format, request.signal)
              : responsesError(400, "invalid JSON body", {});
          }
          // Validate the conversation container before resolving a previous ID;
          // only a missing/expired previous response is a 404.
          if ((body.input != null && typeof body.input !== "string" && !Array.isArray(body.input)) ||
              (body.previous_response_id != null && typeof body.previous_response_id !== "string"))
            return responsesError(400, "input must be a string or array; previous_response_id must be a string", {});
          let conversation: ReturnType<typeof resolveResponsesConversation>;
          try { conversation = resolveResponsesConversation(body, responseHistory); }
          catch (error) { return responsesError(404, error instanceof Error ? error.message : String(error), {}); }
          body = conversation.body;
          const remember = (final: Record<string, unknown>) => responseHistory.put(final.id as string, {
            input: conversation.input, output: final.output as unknown[], instructions: conversation.instructions,
          });
          let chatBody: ChatRequestParams;
          try {
            chatBody = responsesToChatBody(body) as unknown as ChatRequestParams;
            applyCacheSession(chatBody, request, body);
          } catch (error) {
            return responsesError(400, error instanceof Error ? error.message : String(error), {});
          }
          const id = `chatcmpl-${crypto.randomUUID()}`;
          const admitted = await admit(inference, () => chat.run(new ChatRequest(chatBody), id, request.signal),
            undefined, "responses request", responsesError, request.signal);
          if ("response" in admitted) return admitted.response;
          return body.stream
            ? respondStream(inference, admitted.admitted,
              createResponsesStreamProtocol(ctx.modelId, conversation.previousId, remember), request.signal)
            : respondJson(inference, admitted.admitted, result => {
              const response = chatJsonToResponses(chatCompletionJson(result,
                { id, created: Math.floor(Date.now() / 1000), model: ctx.modelId }), ctx.modelId, conversation.previousId);
              remember(response);
              return response;
            }, request.signal, undefined, responsesError);
        }
        if (url.pathname === "/v1/embeddings") {
          const embed = engine.binding.embed?.bind(engine.binding);
          if (!embed) return Response.json({ error: {
            message: `served model "${ctx.modelId}" is not an embedding model; serve an embedding model (e.g. Qwen3-Embedding) to use /v1/embeddings`,
            type: "invalid_request_error",
          } }, { status: 400 });
          let body: { input?: unknown; instruction?: unknown };
          try { body = await request.json(); }
          catch (error) {
            if (request.signal.aborted) return errorResponse(error, url.pathname, undefined, request.signal);
            return Response.json({ error: { message: "invalid JSON body" } }, { status: 400 });
          }
          const inputs = Array.isArray(body?.input) ? body.input : body?.input != null ? [body.input] : [];
          if (!inputs.length || !inputs.every(input => typeof input === "string"))
            return Response.json({ error: { message: "`input` must be a string or array of strings", type: "invalid_request_error" } }, { status: 400 });
          const instruction = typeof body.instruction === "string" ? body.instruction : undefined;
          const results = await engine.gateway.runExclusive(async () => embed(inputs, instruction), undefined, request.signal);
          request.signal.throwIfAborted();
          const total = results.reduce((sum, result) => sum + result.tokens, 0);
          return Response.json({ object: "list", model: ctx.modelId,
            data: results.map((result, index) => ({ object: "embedding", index, embedding: Array.from(result.vector) })),
            usage: { prompt_tokens: total, total_tokens: total } });
        }
        const chatRoute = url.pathname === "/v1/chat/completions";
        if (!chatRoute && url.pathname !== "/v1/completions") return null;
        const id = `${chatRoute ? "chatcmpl" : "cmpl"}-${crypto.randomUUID()}`;
        const trace = createPromptResponseTrace({ traceId: request.headers.get("x-mlx-bun-trace-id") ?? id, requestId: id, route: url.pathname });
        let body: ChatRequestParams;
        const closeParse = trace?.begin("request.body_parse");
        try {
          const parsed = await request.json();
          if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) throw new Error("invalid JSON body");
          body = parsed;
        } catch {
          trace?.finish(request.signal.aborted ? "abort" : "error", { stage: "body_parse" });
          if (request.signal.aborted) return errorResponse(request.signal.reason, url.pathname, undefined, request.signal);
          return Response.json({ error: { message: "invalid JSON body" } }, { status: 400 });
        } finally { closeParse?.(); }
        applyCacheSession(body, request);
        const admitted = await admit(inference, () => chatRoute
          ? chat.run(new ChatRequest(body), id, request.signal)
          : text.run(new TextCompletionRequest(body), id, request.signal), trace, chatRoute ? "chat request" : "text completion", undefined, request.signal);
        if ("response" in admitted) return admitted.response;
        const meta = { id, created: Math.floor(Date.now() / 1000), model: ctx.modelId };
        return body.stream
          ? respondStream(inference, admitted.admitted, chatRoute ? chatCompletionStream(meta) : textCompletionStream(meta), request.signal, trace)
          : respondJson(inference, admitted.admitted, result => chatRoute ? chatCompletionJson(result, meta) : textCompletionJson(result, meta), request.signal, trace);
      } catch (error) { return errorResponse(error, url.pathname, format, request.signal); }
    },
  };
}
