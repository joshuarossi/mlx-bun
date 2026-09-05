// ChatStage: ChatRequest in, InferenceRequest out. Turns a chat conversation
// (messages, tools, media parts, sampling fields) into the prompt token ids,
// media embeddings, resolved generation options, adapter selection, grammar
// controller, and the token→text pipeline the model needs. Every chat-shaped
// surface (OpenAI chat, Anthropic Messages, Responses) runs this stage; the
// wire format is not its business.
import type { PromptCache } from "../prompt-cache";
import {
  applyGrammarDegrade,
  type ChatRequest,
  type ChatRequestParams,
} from "./chat-request";
import type { InferenceRequest } from "./inference-request";
import type { ServingContext } from "./model-host";
import type { BuiltPrompt, ModelPromptBuilder } from "./model-binding";
import { modelPromptBuilder } from "../backends/mlx/model-serving";
import { RequestError } from "./pipeline";
import { RequestOwnership } from "./request-plan";
import type { RequestPrep } from "./request-prep";
import { StopMatcher, ThinkingTagSplitter } from "./token-streams";

export class ChatStage {
  constructor(
    private readonly ctx: ServingContext,
    private readonly prep: RequestPrep,
    private readonly promptCache: Pick<PromptCache, "peekPrefixLen">,
    /** Admission ceiling (fit() / the GLM memory plan), resolved once. */
    private readonly maxSafeContext: number,
    /** `serve --adapter <dir>` startup default; a request's explicit
     *  `adapter` (incl. "none") wins. */
    private readonly defaultAdapter?: string,
    private readonly preparation?: import("./preparation").PreparationExecutor,
    private readonly buildPrompt: ModelPromptBuilder = modelPromptBuilder(ctx),
  ) {}

  async run(request: ChatRequest, requestId?: string, signal?: AbortSignal): Promise<InferenceRequest> {
    signal?.throwIfAborted();
    const body = request.params;
    const media = body.messages.some((message) => Array.isArray(message.content) &&
        message.content.some((part) => part.type !== "text"));
    const native = media || body.response_format != null || !!body.guided_grammar ||
      !!body.guided_regex || !!body.guided_choice?.length || body.structured_outputs != null;
    const build = async () => {
      signal?.throwIfAborted();
      const result = await this.runPrepared(request, requestId);
      if (signal?.aborted) {
        result.plan.ownership.dispose();
        signal.throwIfAborted();
      }
      return result;
    };
    if (!native || !this.preparation) return build();
    let reservation = await this.preparation.reserve?.(media ? "media" : "constraint", signal);
    try {
      const result = await this.preparation.run(build, signal);
      if (reservation) result.plan.ownership.retain(reservation);
      reservation = undefined;
      return result;
    } finally { reservation?.dispose(); }
  }

  private async runPrepared(request: ChatRequest, requestId?: string): Promise<InferenceRequest> {
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
      built = await this.buildPrompt(body, tools, ownership, prep);
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
          promptIds, options.adapters?.length ? ctx.adapters.cacheNamespace(options.adapters) : "");
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

}
