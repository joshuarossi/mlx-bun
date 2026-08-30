// TextCompletionStage: TextCompletionRequest in, InferenceRequest out.
// mlx_lm.server's raw text completion: NO chat template — the prompt string
// is tokenized directly (tokenizer.encode with the tokenizer's own
// special-token handling, exactly mlx-lm's `tokenizer.encode(request.prompt)`).
// Same admission / adapter / lane path as chat; no tool router or thinking
// splitter (raw text in, raw text out).
import type { ServerContext } from "./model-host";
import type { TextCompletionRequest } from "./chat-request";
import type { InferenceRequest } from "./inference-request";
import { RequestError } from "./pipeline";
import { RequestOwnership } from "./request-plan";
import type { RequestPrep } from "./request-prep";
import { StopMatcher, ThinkingTagSplitter, ToolAwareStream } from "./token-streams";

export class TextCompletionStage {
  constructor(
    private readonly ctx: ServerContext,
    private readonly prep: RequestPrep,
    private readonly maxSafeContext: number,
    /** `--max-tokens` / the GLM plan's reservation. No invented fallback:
     *  unset runs to EOS or the admitted context (with no template an EOS
     *  may never come — that run is bounded by admission, the real limit). */
    private readonly defaultGeneratedTokens: number | undefined,
    private readonly defaultAdapter?: string,
  ) {}

  async run(request: TextCompletionRequest, requestId?: string): Promise<InferenceRequest> {
    const { ctx, prep } = this;
    const body = request.params;
    const id = requestId ?? `cmpl-${crypto.randomUUID()}`;
    const promptIds = ctx.tokenizer.encode(body.prompt);
    const ownership = new RequestOwnership();
    const warnings: string[] = [];
    const reject = (message: string): never => {
      ownership.dispose();
      throw new RequestError(400, message);
    };
    let options: ReturnType<RequestPrep["toOptions"]>;
    try {
      options = prep.toOptions(body as never);
    } catch (e) {
      // bad logit_bias (non-numeric keys/values) — mlx-lm's coercion error
      return reject((e as Error).message);
    }
    // Grammar-constrained decoding on raw completions too (response_format /
    // guided_* / structured_outputs). The degrade path has no chat template
    // to inject a system message into, so a degrade only emits the Warning
    // header (no prompt injection) — documented gap vs the chat lane, which
    // mirrors oMLX's text-completions behavior.
    const grammarReq =
      body.response_format != null || !!body.guided_grammar ||
      !!body.guided_regex || !!body.guided_choice?.length ||
      body.structured_outputs != null;
    if (grammarReq) {
      const g = await prep.compileGrammarForRequest(body as never);
      if (g.controller) options.grammar = ownership.own(g.controller);
      else if (g.degradeHint)
        warnings.push(
          `grammar not enforced: ${g.degradeHint} - no prompt injection on /v1/completions`);
    }
    // Unset = no request-level ceiling; admission clamps to the admitted
    // context. DEVIATION from mlx_lm.server (which stops a defaulted
    // request at 512): pass --max-tokens 512 to reproduce the reference.
    const requestedMaxTokens = body.max_completion_tokens ?? body.max_tokens ??
      this.defaultGeneratedTokens ?? Infinity;
    let adapterIds: string[];
    try {
      adapterIds = ctx.adapters.resolveSpec(body.adapter ?? this.defaultAdapter);
    } catch (e) {
      return reject((e as Error).message);
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
        hasVision: false,
        userSeed: body.seed !== undefined,
        hasGrammar: !!options.grammar,
        hasDraft: !!ctx.draft,
        ownership,
      },
      pipeline: {
        router: new ToolAwareStream(ctx.tokenizer, "plain", null),
        stopper: new StopMatcher(options.stopSequences),
        thinking: new ThinkingTagSplitter(false),
        collectToolCalls: false,
      },
      idToToken: (tokenId) => ctx.tokenizer.idToToken(tokenId),
    };
  }
}
