import type { ModelBinding } from "../engine/model-binding";
import type { LoadedModelContext } from "../engine/model-host";
import type { GenerationGateway } from "../engine/generation-gateway";
import type { ModelPromptBuilder } from "./prompt-contracts";
import { modelPromptBuilder } from "./prompt-builder";
import { createRequestPrep } from "./request-prep";
import { RequestOwnership } from "./request-plan";
import { RequestError } from "./pipeline";
import { errorResponse } from "./http";
import { readDecisionBody } from "./decision-body";
import { decisionAnswer, decisionCandidates, decisionMessages, DecisionValidationError,
  parseJevDecision, parseOpenAiDecision } from "./decision-wire";

export function createDecisionRoutes(engine: {
  context: LoadedModelContext;
  binding: Pick<ModelBinding, "decide"> & Partial<Pick<ModelBinding, "gateway">>;
  gateway: Pick<GenerationGateway, "runExclusive"> & Partial<Pick<GenerationGateway, "runPreparation">>;
}, options: { contextLimit: number | null; defaultAdapter?: string; buildPrompt?: ModelPromptBuilder }) {
  const ctx = engine.context, build = options.buildPrompt ?? modelPromptBuilder(ctx);
  const prep = createRequestPrep({ ctx, serverOptions: { defaultThinking: false }, defaultGeneratedTokens: undefined });
  return {
    async handle(request: Request): Promise<Response | null> {
      const path = new URL(request.url).pathname;
      if (request.method !== "POST") return null;
      const jev = path === "/v1/systemone";
      if (!jev && path !== "/v1/decisions") return null;
      try {
        const body = await readDecisionBody(request);
        const parsed = jev ? parseJevDecision(body) : parseOpenAiDecision(body);
        const decide = engine.binding.decide?.bind(engine.binding);
        if (!decide) throw new RequestError(501, `model "${ctx.modelId}" declares no decision scoring operation`,
          { message: `model "${ctx.modelId}" declares no decision scoring operation`, type: "not_implemented", code: "unsupported_execution" });
        const schedule = <T>(work: () => Promise<T>): Promise<T> => engine.gateway.runPreparation
          ? engine.gateway.runPreparation(work, request.signal) : engine.gateway.runExclusive(work, undefined, request.signal);
        request.signal.throwIfAborted();
        const answers: Record<string, unknown>[] = [];
        let inputTokens = 0;
        for (const question of parsed.questions) {
          request.signal.throwIfAborted();
          const terminator = ctx.tokenizer.eosTokenId ?? ctx.model.config.eosTokenIds[0];
          if (terminator === undefined) throw new RequestError(501, "decision scoring requires an answer terminator token");
          const candidates = decisionCandidates(ctx.tokenizer, question, terminator);
          const ownership = new RequestOwnership();
          try {
            const built = await build({ messages: decisionMessages(parsed.input, question),
              reasoning_effort: "none", chat_template_kwargs: { enable_thinking: false } }, null, ownership, prep, schedule);
            ownership.own(built.vision?.embeddings);
            ownership.own(built.vision?.imageMask);
            ownership.own(built.vision?.multimodalMask);
            ownership.own(built.diffusionPixels);
            request.signal.throwIfAborted();
            if (built.diffusionPixels) throw new RequestError(501, "pixel-input decision scoring is unavailable for this graph");
            if (options.contextLimit !== null && candidates.some(answer => built.promptIds.length + answer.length - 1 > options.contextLimit!))
              throw new RequestError(400, `decision prompt exceeds the ${options.contextLimit}-token context limit`,
                { message: "decision prompt exceeds the context limit", type: "invalid_request_error", code: "max_tokens_exceeded" });
            const adapters = options.defaultAdapter ? [options.defaultAdapter] : [];
            const probabilities = await decide({ prompt: built.promptIds, candidates, vision: built.vision, signal: request.signal,
              execute: work => schedule(async () => {
                request.signal.throwIfAborted();
                const restore = engine.binding.gateway?.bindAdapterContext?.(adapters, `decision:${JSON.stringify(adapters)}`).enter();
                try { return await work(); } finally { restore?.(); }
              }) });
            request.signal.throwIfAborted();
            if (probabilities.length !== candidates.length || probabilities.some(p => !Number.isFinite(p) || p < 0 || p > 1) ||
                Math.abs(probabilities.reduce((sum, p) => sum + p, 0) - 1) > 1e-5)
              throw new Error("decision binding returned an invalid probability distribution");
            inputTokens += candidates.reduce((sum, answer) => sum + built.promptIds.length + answer.length - 1, 0);
            answers.push(decisionAnswer(question, probabilities, jev));
          } finally { ownership.dispose(); }
          await new Promise<void>(resolve => setImmediate(resolve));
        }
        request.signal.throwIfAborted();
        return Response.json({ model: ctx.modelId,
          answers: jev ? Object.fromEntries(parsed.questions.map((q, i) => [q.name!, answers[i]])) : answers,
          usage: jev ? { input_tokens: inputTokens, output_tokens: 0 } : {
            input_tokens: inputTokens, input_tokens_details: { cached_tokens: 0, cache_write_tokens: 0 },
            output_tokens: 0, output_tokens_details: { reasoning_tokens: 0 }, total_tokens: inputTokens,
          } });
      } catch (error) {
        if (error instanceof DecisionValidationError) return jev
          ? Response.json({ detail: [{ loc: ["body", ...error.field.split(".")], msg: error.message, type: "value_error" }] }, { status: 422 })
          : Response.json({ error: { message: error.message, type: "invalid_request_error", param: error.field, code: null } }, { status: 400 });
        return errorResponse(error, path, undefined, request.signal);
      }
    },
  };
}
