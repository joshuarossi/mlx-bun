import type { PromptCache } from "@mlx-bun/inference/state";
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
import { admit, errorResponse, respondJson, respondStream } from "./http";
import { chatCompletionJson, chatCompletionStream, textCompletionJson, textCompletionStream } from "./openai-wire";
import { createDiscoveryRoutes } from "./discovery-routes";

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
}) {
  const ctx = engine.context;
  const prep = createRequestPrep({ ctx, serverOptions: options, kvScheme: options.kvScheme ?? {},
    defaultGeneratedTokens: options.defaultGeneratedTokens, tokenHistory: options.tokenHistory });
  const chat = new ChatStage(ctx, prep, options.promptCache, options.contextLimit,
    options.defaultAdapter, engine.preparation, options.buildPrompt);
  const text = new TextCompletionStage(ctx, prep, options.contextLimit, options.defaultGeneratedTokens, options.defaultAdapter, engine.preparation);
  const inference = new InferenceStage(new CompletionExecutor(engine.completion));
  const discovery = createDiscoveryRoutes(ctx, engine.binding, Date.now());
  return {
    invalidateLibrary: discovery.invalidateLibrary,
    /** null means another app surface may handle this request. */
    async handle(request: Request): Promise<Response | null> {
      const url = new URL(request.url);
      try {
        const discovered = await discovery.handle(url, request);
        if (discovered) return discovered;
        if (request.method !== "POST") return null;
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
        const session = typeof body.session_id === "string" ? body.session_id :
          typeof body.prompt_cache_key === "string" ? body.prompt_cache_key :
          request.headers.get("x-session-affinity") ?? request.headers.get("session_id") ?? undefined;
        if (runtimeValue("MLX_BUN_SESSION_CACHE") !== "0") body.session_id = session;
        else { delete body.session_id; delete body.prompt_cache_key; }
        const admitted = await admit(inference, () => chatRoute
          ? chat.run(new ChatRequest(body), id, request.signal)
          : text.run(new TextCompletionRequest(body), id, request.signal), trace, chatRoute ? "chat request" : "text completion", undefined, request.signal);
        if ("response" in admitted) return admitted.response;
        const meta = { id, created: Math.floor(Date.now() / 1000), model: ctx.modelId };
        return body.stream
          ? respondStream(inference, admitted.admitted, chatRoute ? chatCompletionStream(meta) : textCompletionStream(meta), request.signal, trace)
          : respondJson(inference, admitted.admitted, result => chatRoute ? chatCompletionJson(result, meta) : textCompletionJson(result, meta), request.signal, trace);
      } catch (error) { return errorResponse(error, url.pathname, undefined, request.signal); }
    },
  };
}
