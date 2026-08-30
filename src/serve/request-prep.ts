// Per-request preparation shared by every completion surface (chat,
// raw text, /signal, /generate): request → GenerateOptions with the
// server/model defaults folded in, chat-template rendering + prompt ids,
// the stable prompt-cache boundary probe, grammar compilation, and the
// tool-call stream router. Resolved ONCE per server (createRequestPrep) and
// captured by the route handlers. Extracted from src/server.ts (repo-taming
// Phase 4).
import type { ToolDefinition } from "../chat-template";
import type { GenerateOptions } from "../generate";
import { compileGrammarRequest, grammarEnabled, type GrammarRequest } from "../grammar";
import type { KvSchemeOptions } from "../kv-scheme";
import { isMiniCPM5Config } from "../model/support";
import type { HlgConfig } from "../sampler";
import {
  nextDefaultSeed,
  normalizeMessages,
  parseLogitBias,
  promptEndsInOpenThink,
  resolveHlg,
  type ChatRequestParams,
} from "./chat-request";
import type { ServerContext } from "./model-host";
import { selectToolStreamMode, ToolAwareStream, type ToolStreamMode } from "./token-streams";

/** The ServerOptions fields request preparation reads (server-wide
 *  defaults a request field overrides). */
export interface RequestPrepOptions {
  defaultThinking?: boolean;
  defaultTemperature?: number;
  defaultTopP?: number;
  defaultTopK?: number;
  hlg?: HlgConfig;
  pagedKv?: { blockSize?: number };
}

export function createRequestPrep(input: {
  ctx: ServerContext;
  serverOptions: RequestPrepOptions;
  /** The server-wide KV scheme (resolveKvScheme(...).generationOptions),
   *  spread into every request's GenerateOptions. */
  kvScheme: KvSchemeOptions;
  /** `--max-tokens` / the GLM memory plan's generation cap; undefined = the
   *  surface's own default (chat 65 536, raw completion 512). */
  defaultGeneratedTokens: number | undefined;
}) {
  const { ctx, serverOptions, kvScheme, defaultGeneratedTokens } = input;

  // XTC never removes EOS or the newline token: mlx_lm.server passes
  // [tokenizer.eos_token_id, tokenizer.encode("\n")] as xtc_special_tokens.
  // We pass the flat equivalent — ALL configured EOS ids plus the bare newline
  // id(s), encoded WITHOUT special tokens (mlx-lm's encode("\n") can drag a
  // BOS along on some tokenizers; protecting BOS from XTC is a no-op, so the
  // flat/no-BOS form is behaviorally identical and cleaner).
  const xtcSpecialTokens = [
    ...ctx.model.config.eosTokenIds,
    ...ctx.tokenizer.encode("\n", false),
  ];

  // Effective enable_thinking for a request, with the same precedence the chat
  // template uses (extracted so sampling and template rendering can't disagree):
  // explicit chat_template_kwargs.enable_thinking → reasoning_effort ("none" =
  // off) → server --thinking default → model default (MiniCPM5 → off). undefined
  // means "not a switchable-thinking model / leave the template default".
  const resolveEnableThinking = (req: ChatRequestParams): boolean | undefined => {
    const explicit = req.chat_template_kwargs?.enable_thinking;
    if (typeof explicit === "boolean") return explicit;
    const effort = req.reasoning_effort;
    if (effort !== undefined) return effort !== "none";
    if (serverOptions.defaultThinking !== undefined) return serverOptions.defaultThinking;
    return isMiniCPM5Config(ctx.model.config) ? false : undefined;
  };

  const toOptions = (req: ChatRequestParams): GenerateOptions & { stopSequences: string[] } => {
    // Sampling follows the thinking state — which the web UI's thinking button
    // drives via enable_thinking. Model authors publish a SINGLE
    // generation_config temperature (the think-mode value) but recommend a
    // cooler one for direct, no-think replies (MiniCPM5 card: 0.9 think / 0.7
    // no-think, top_p 0.95 for both). So with no explicit temperature set, a
    // no-think turn runs at most NO_THINK_TEMPERATURE while a think turn keeps
    // the model's hotter configured default. An explicit request/CLI
    // temperature always wins. top_p is unchanged by mode.
    const NO_THINK_TEMPERATURE = 0.7;
    const genTemp = ctx.genDefaults.temperature ?? 0.7;
    const defaultTemp = resolveEnableThinking(req) === false
      ? Math.min(genTemp, NO_THINK_TEMPERATURE)
      : genTemp;
    return {
      // A thinking turn emits <think>…</think> AND the answer, so a tight cap
      // truncates the visible reply. Default very generously (the model's
      // context is far larger); only an explicit max_tokens narrows it. The
      // model still stops at its eos_token well before this in normal replies.
      maxTokens: req.max_completion_tokens ?? req.max_tokens ??
        defaultGeneratedTokens ?? 65_536,
      temperature: req.temperature ?? serverOptions.defaultTemperature ?? defaultTemp,
      topP: req.top_p ?? serverOptions.defaultTopP ?? ctx.genDefaults.topP ?? 0,
      topK: req.top_k ?? serverOptions.defaultTopK ?? ctx.genDefaults.topK ?? 0,
      seed: req.seed ?? nextDefaultSeed(),
      repetitionPenalty: req.repetition_penalty ?? ctx.genDefaults.repetitionPenalty,
      // mlx_lm.server sampling extensions (defaults mirror server.py: min_p /
      // xtc off, context windows 20). parseLogitBias throws on non-numeric
      // input — callers surface it as a 400 (mlx-lm's coercion error).
      minP: req.min_p ?? 0,
      xtcProbability: req.xtc_probability ?? 0,
      xtcThreshold: req.xtc_threshold ?? 0,
      ...(req.xtc_probability ? { xtcSpecialTokens } : {}),
      logitBias: parseLogitBias(req.logit_bias),
      repetitionContextSize: req.repetition_context_size ?? 20,
      presencePenalty: req.presence_penalty ?? 0,
      presenceContextSize: req.presence_context_size ?? 20,
      frequencyPenalty: req.frequency_penalty ?? 0,
      frequencyContextSize: req.frequency_context_size ?? 20,
      hlg: resolveHlg(req.hlg, serverOptions.hlg),
      // generate() yields token ids; stop sequences match on decoded text
      // (they can span token boundaries), so the StopMatcher sits at the
      // decode layer below and halts the loop via onToken → false.
      stopSequences: (typeof req.stop === "string" ? [req.stop] : req.stop ?? [])
        .filter((s) => typeof s === "string" && s.length > 0),
      ...kvScheme,
      // Paged KV is a server-wide mode like the kv scheme above (v1:
      // serial bf16 gemma4 — the createServer refusals hold the invariants).
      ...(serverOptions.pagedKv ? { pagedKv: serverOptions.pagedKv } : {}),
    };
  };

  /** Compile a grammar controller from the request's structured-output fields
   *  (response_format / guided_* / structured_outputs). Returns null when no
   *  constraint is requested OR when compile failed (degrade path). On degrade,
   *  `degradeHint` carries a human description for the system-prompt injection
   *  + Warning header (oMLX parity — never 500). Honors MLX_BUN_GRAMMAR=0. */
  const compileGrammarForRequest = async (
    req: ChatRequestParams,
  ): Promise<{ controller: import("../grammar").GrammarController | null; degradeHint: string | null }> => {
    if (!grammarEnabled()) {
      return {
        controller: null,
        degradeHint: "grammar compilation disabled by MLX_BUN_GRAMMAR=0",
      };
    }
    const r = await compileGrammarRequest(
      req as GrammarRequest,
      ctx.tokenizer,
      ctx.model.config.text.vocabSize,
    );
    if (!r) return { controller: null, degradeHint: null };
    return { controller: r.controller, degradeHint: r.degradeHint };
  };

  // Map OpenAI reasoning_effort levels onto the Qwen3.8 template's supported
  // set (xhigh|medium|low — the template raises on anything else). "none"
  // means thinking off (handled by resolveEnableThinking), so no depth is
  // passed. Only consumed for templates with readsReasoningEffort.
  const qwenReasoningEffort = (
    effort: ChatRequestParams["reasoning_effort"],
  ): "xhigh" | "medium" | "low" | undefined => {
    switch (effort) {
      case "minimal":
      case "low":
        return "low";
      case "medium":
        return "medium";
      case "high":
      case "xhigh":
        return "xhigh";
      default:
        return undefined; // "none" / unset → template default (xhigh)
    }
  };

  const templateOptionsFor = (req: ChatRequestParams, tools: ToolDefinition[] | null) => {
    // enableThinking resolution (and its precedence) lives in
    // resolveEnableThinking so template rendering and sampling stay in sync.
    return {
      tools,
      enableThinking: resolveEnableThinking(req),
      reasoningEffort: qwenReasoningEffort(req.reasoning_effort),
      preserveThinking: req.chat_template_kwargs?.preserve_thinking,
    };
  };

  const promptIdsFor = (
    req: ChatRequestParams,
    tools: ToolDefinition[] | null,
  ): { ids: number[]; startInThinking: boolean } => {
    const opts = templateOptionsFor(req, tools);
    const rendered = ctx.template.render(normalizeMessages(req.messages), opts);
    const ids = ctx.tokenizer.encode(rendered);
    // template includes <bos>; tokenizer post-processor also prepends one
    const trimmed = ids[0] === ids[1] && ids[0] === ctx.tokenizer.bosTokenId ? ids.slice(1) : ids;
    return { ids: trimmed, startInThinking: promptEndsInOpenThink(rendered) };
  };

  /** STABLE cache boundary: the prompt's tail is a generation primer (e.g.
   *  12B's `<|channel>thought` tokens) that the NEXT turn's re-render does
   *  not contain — a cache entry ending there can never prefix-match again
   *  once the rings wrap. Probe by rendering this conversation as if a
   *  reply existed; the common prefix is what every future turn preserves.
   *  The probe is EXPENSIVE (a second full render + encode — ~150 ms at
   *  16k with our tokenizer; 30-50% of the 12B ctx-repeat TTFT,
   *  2026-07-06b), but the PRIMER LENGTH it measures is constant per
   *  template mode: the divergence sits after a special-token turn
   *  delimiter, and special tokens break BPE merges, so message content
   *  can't shift it. So the full probe runs ONCE per mode and later
   *  requests pay a subtraction. (A wrong boundary is a QUALITY knob, not
   *  a correctness one — any prefix ≤ len-1 is a valid snapshot point.) */
  const primerLenByMode = new Map<string, number>();
  const stableLenFor = (
    req: ChatRequestParams,
    tools: ToolDefinition[] | null,
    trimmed: number[],
  ): number => {
    const opts = templateOptionsFor(req, tools);
    const mode = `${opts.enableThinking}|${!!tools?.length}|${opts.reasoningEffort ?? ""}|${opts.preserveThinking ?? ""}`;
    const primer = primerLenByMode.get(mode);
    if (primer !== undefined) return Math.max(0, trimmed.length - primer);
    let stableLen = trimmed.length;
    try {
      const probe = ctx.tokenizer.encode(
        ctx.template.render(
          [...normalizeMessages(req.messages), { role: "assistant", content: "x" }],
          opts,
        ),
      );
      const probeTrimmed =
        probe[0] === probe[1] && probe[0] === ctx.tokenizer.bosTokenId ? probe.slice(1) : probe;
      let i = 0;
      const n = Math.min(trimmed.length, probeTrimmed.length);
      while (i < n && trimmed[i] === probeTrimmed[i]) i++;
      stableLen = i;
      // Memoize the mode's primer length (sanity-capped: a "primer" longer
      // than 64 tokens means the probe diverged for content reasons —
      // don't generalize that).
      const p = trimmed.length - stableLen;
      if (p >= 0 && p <= 64) primerLenByMode.set(mode, p);
    } catch { /* probe is best-effort; full boundary is the fallback */ }
    return stableLen;
  };

  const toolStreamMode = (tools: ToolDefinition[] | null): ToolStreamMode =>
    // Gemma-4 keeps the token-level sentinel path; every other family
    // (MiniCPM5, Qwen3/3.5, Tier-0 generics) emits tool calls as DECODED TEXT
    // — see selectToolStreamMode for why sentinel ids must stay family-gated.
    selectToolStreamMode(ctx.model.config.modelType, !!tools?.length);

  const toolRouter = (tools: ToolDefinition[] | null): ToolAwareStream =>
    new ToolAwareStream(ctx.tokenizer, toolStreamMode(tools), tools);

  return {
    resolveEnableThinking,
    toOptions,
    compileGrammarForRequest,
    templateOptionsFor,
    promptIdsFor,
    stableLenFor,
    toolRouter,
  };
}

export type RequestPrep = ReturnType<typeof createRequestPrep>;
