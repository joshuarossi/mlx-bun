import type { ModelBinding } from "../engine/model-binding";
import type { LoadedModelContext } from "../engine/model-host";
import type { PreparationExecutor } from "../engine/preparation";
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
  preparation: PreparationExecutor;
}, options: { contextLimit: number | null; defaultAdapter?: string; buildPrompt?: ModelPromptBuilder }) {
  const ctx = engine.context, build = options.buildPrompt ?? modelPromptBuilder(ctx);
  const prep = createRequestPrep({ ctx, serverOptions: { defaultThinking: false }, defaultGeneratedTokens: undefined });
  return {
    async handle(request: Request): Promise<Response | null> {
      const path = new URL(request.url).pathname;
      if (request.method !== "POST") return null;
      const jev = path === "/v1/systemone";
      if (!jev && path !== "/v1/decisions") return null;
      const requestOwnership = new RequestOwnership();
      try {
        const reservation = await engine.preparation.reserve?.("decision", request.signal);
        if (reservation) requestOwnership.retain(reservation);
        const body = await readDecisionBody(request);
        const parsed = jev ? parseJevDecision(body) : parseOpenAiDecision(body);
        const decide = engine.binding.decide?.bind(engine.binding);
        if (!decide) throw new RequestError(501, `model "${ctx.modelId}" declares no decision scoring operation`,
          { message: `model "${ctx.modelId}" declares no decision scoring operation`, type: "not_implemented", code: "unsupported_execution" });
        const schedule = <T>(work: () => Promise<T>): Promise<T> => engine.preparation.run(work, request.signal);
        request.signal.throwIfAborted();
        const ending = decisionAnswerEnding(ctx, prep);
        const answers: Record<string, unknown>[] = [];
        let inputTokens = 0;
        for (const question of parsed.questions) {
          request.signal.throwIfAborted();
          const candidates = decisionCandidates(ctx.tokenizer, question, ending);
          const ownership = new RequestOwnership();
          try {
            const messages = decisionMessages(parsed.input, question);
            const media = messages.some(message => Array.isArray(message.content) && message.content.some(part => part.type !== "text"));
            if (media) {
              const reservation = await engine.preparation.reserve?.("media", request.signal);
              if (reservation) ownership.retain(reservation);
            }
            let built: Awaited<ReturnType<ModelPromptBuilder>>;
            try {
              built = await build({ messages, reasoning_effort: "none", chat_template_kwargs: { enable_thinking: false } },
                null, ownership, prep, schedule);
            } catch (error) {
              if (error instanceof RequestError) throw error;
              throw new RequestError(400, `prompt build failed: ${error instanceof Error ? error.message : String(error)}`);
            }
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
      } finally { requestOwnership.dispose(); }
    },
  };
}

/** Score the template's completed assistant turn through its first stop marker,
 * excluding layout after the marker. Encode answer + ending together so BPE
 * merges at that boundary match the supplied text. */
function decisionAnswerEnding(ctx: LoadedModelContext, prep: ReturnType<typeof createRequestPrep>): string {
  const stops = [...new Set([...ctx.model.config.eosTokenIds, ...(ctx.tokenizer.eosTokenId === null ? [] : [ctx.tokenizer.eosTokenId])])]
    .map(id => ctx.tokenizer.decode([id], false)).filter(Boolean);
  if (ctx.template) {
    const marker = "mlx_bun_decision_answer_9d041a";
    const messages = [{ role: "user" as const, content: "x" }, { role: "assistant" as const, content: marker }];
    const rendered = ctx.template.render(messages, { ...prep.templateOptionsFor({ messages,
      reasoning_effort: "none", chat_template_kwargs: { enable_thinking: false } }, null), addGenerationPrompt: false });
    const at = rendered.indexOf(marker);
    if (at < 0 || rendered.indexOf(marker, at + marker.length) >= 0)
      throw new RequestError(501, "decision scoring requires a chat template that preserves assistant answers");
    const suffix = rendered.slice(at + marker.length);
    const first = stops.map(text => ({ text, at: suffix.indexOf(text) })).filter(stop => stop.at >= 0)
      .sort((a, b) => a.at - b.at)[0];
    if (first) return suffix.slice(0, first.at + first.text.length);
    if (suffix.trim()) return suffix;
  }
  const fallback = ctx.tokenizer.eosTokenId ?? ctx.model.config.eosTokenIds[0];
  if (fallback === undefined || fallback === null) throw new RequestError(501, "decision scoring requires an answer terminator token");
  return ctx.tokenizer.decode([fallback], false);
}
