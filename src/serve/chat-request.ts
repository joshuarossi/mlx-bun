// Wire-level chat/completion request shapes and the pure per-request
// helpers: message normalization, sampling-field coercion, grammar-degrade
// prompt injection, and the mlx_lm.server-parity validators. No model, no
// server state. Extracted from src/server.ts (repo-taming Phase 4).
import type { ChatMessage, ToolDefinition } from "../chat-template";
import type { HlgConfig } from "../sampler";

export interface ChatRequest {
  messages: ChatMessage[];
  stream?: boolean;
  max_tokens?: number;
  max_completion_tokens?: number;
  temperature?: number;
  top_p?: number;
  top_k?: number;
  seed?: number;
  repetition_penalty?: number;
  /** mlx-lm extension: recent-token window for repetition_penalty
   *  (default 20; 0 = whole history, Python `[-0:]` semantics). */
  repetition_context_size?: number;
  /** min-p sampling (mlx_lm.server's `min_p`): keep tokens whose probability
   *  is ≥ min_p · p(top token). 0 = off. */
  min_p?: number;
  /** XTC sampling (mlx_lm.server names): with probability `xtc_probability`
   *  per step, remove every token above `xtc_threshold` except the least
   *  likely of them. EOS + the newline token are always exempt (the server
   *  injects them as xtc special tokens, matching mlx_lm.server). */
  xtc_probability?: number;
  xtc_threshold?: number;
  /** OpenAI logit_bias: {tokenId: additive bias}. JSON object keys arrive as
   *  strings; coerced to int keys / float values like mlx-lm (400 on failure). */
  logit_bias?: Record<string, number>;
  /** OpenAI presence/frequency penalties + mlx-lm's context-size extensions
   *  (window of recent tokens the penalty looks at; default 20). */
  presence_penalty?: number;
  presence_context_size?: number;
  frequency_penalty?: number;
  frequency_context_size?: number;
  /** mlx_lm.server logprobs: `logprobs` is a BOOL (even on /v1/completions —
   *  not OpenAI's legacy int), `top_logprobs` an int in [0, 11] or the -1
   *  "unset" sentinel (server.py validates exactly that; OpenAI's cap is 20,
   *  mlx-lm's is 11 — we copy the reference). Non-stream responses carry
   *  mlx-lm's logprobs block; stream chunks never do (reference behavior). */
  logprobs?: boolean;
  top_logprobs?: number;
  /** OpenAI stop sequences: plain string or array (spec allows up to 4).
   *  Matched on DECODED text, not token ids — see StopMatcher. */
  stop?: string | string[];
  tools?: ToolDefinition[];
  tool_choice?: "auto" | "none" | { type: string; function?: { name: string } };
  /** Forwarded to HF chat templates, matching optiq serve. MiniCPM5 uses
   *  enable_thinking to select direct answers vs the <think> channel; Qwen3.8
   *  adds preserve_thinking (keep think blocks from history; template default
   *  true — better prompt-cache reuse in agent loops). */
  chat_template_kwargs?: {
    enable_thinking?: boolean;
    preserve_thinking?: boolean;
    [key: string]: unknown;
  };
  /** OpenAI reasoning control. For models with a switchable <think> channel
   *  (Qwen3.5/MiniCPM5) it gates enable_thinking: "none" → off, any level → on.
   *  This is what Pi sends when the provider advertises reasoning. For
   *  templates that read a reasoning-depth variable (Qwen3.8: xhigh/medium/
   *  low), the level ALSO maps into the template via qwenReasoningEffort —
   *  "xhigh" accepted as a first-class value (Qwen3.8's default/deepest). */
  reasoning_effort?: "none" | "minimal" | "low" | "medium" | "high" | "xhigh";
  /** Mounted LoRA adapter selection: "id", "a+b" (stacked), or "none". */
  adapter?: string;
  /** HLG tone-curve sampling override (per request). Snake_case wire fields,
   *  merged over the server's --hlg-sampling config. docs/archive/hlg-sampling.md. */
  hlg?: {
    enabled?: boolean;
    width?: number;
    shoulder?: number;
    toe?: number;
    pivot_offset?: number;
  };
  /** OpenAI structured output: {type:"json_object"} | {type:"json_schema",
   *  json_schema:{name,schema,strict?}} | {type:"text"}. Enforced at the
   *  sampler via xgrammar token-bitmasks (src/grammar.ts). L2-class (oMLX
   *  oracle). On compile failure, degrades to a system-prompt injection +
   *  Warning header (oMLX parity), never 500. */
  response_format?: unknown;
  /** vLLM/oMLX grammar aliases (all compiled via xgrammar): raw EBNF/LARK
   *  grammar, regex, enum choice, and a bare JSON-schema object. Precedence
   *  (guided_grammar > json_schema > json_object > structured_outputs >
   *  guided_regex > guided_choice) mirrors oMLX _effective_guided_grammar. */
  guided_grammar?: string;
  guided_regex?: string;
  guided_choice?: string[];
  structured_outputs?: unknown;
}

/** POST /v1/completions body (mlx_lm.server's raw text completion — no chat
 *  template). Sampling/penalty/stop fields are the same names as ChatRequest;
 *  `prompt` replaces `messages`. mlx_lm.server accepts only a STRING prompt
 *  (it calls `tokenizer.encode(request.prompt)` directly) — token-array
 *  prompts are rejected there too, so we match. No `echo` (mlx-lm has none). */
export type TextCompletionRequest = Omit<ChatRequest, "messages" | "tools" | "tool_choice"> & {
  prompt?: unknown;
};


/** Per-field default HLG knobs when enabling without specifying them. */
export const HLG_DEFAULTS = { width: 4, shoulder: 4, toe: 6, pivotOffset: 6 } as const;

/** Resolve the effective HLG config: a per-request `hlg` object overrides the
 *  server's --hlg-sampling default field-by-field. Returns undefined (HLG off)
 *  unless enabled by the request or the server. */
export function resolveHlg(
  reqHlg: ChatRequest["hlg"],
  serverHlg: HlgConfig | undefined,
): HlgConfig | undefined {
  const enabled = reqHlg?.enabled ?? serverHlg?.enabled ?? false;
  if (!enabled) return undefined;
  const base = serverHlg ?? HLG_DEFAULTS;
  return {
    enabled: true,
    width: reqHlg?.width ?? base.width,
    shoulder: reqHlg?.shoulder ?? base.shoulder,
    toe: reqHlg?.toe ?? base.toe,
    pivotOffset: reqHlg?.pivot_offset ?? base.pivotOffset,
    pivot: "top",
  };
}

/** True when a rendered prompt ends INSIDE an unclosed `<think>` block — the
 *  generation prompt primed reasoning (Qwen3.5 / MiniCPM5 with thinking on),
 *  so the model continues the chain-of-thought and emits only the closing
 *  `</think>`. Seeds ThinkingTagSplitter so reasoning is split out correctly.
 *  Thinking-off primes a CLOSED empty block (`<think>\n\n</think>`), and
 *  no-thinking templates have no `<think>` at all — both return false. */
export function promptEndsInOpenThink(rendered: string): boolean {
  const open = rendered.lastIndexOf("<think>");
  return open !== -1 && open > rendered.lastIndexOf("</think>");
}

/** Concatenate the text of an OpenAI content-part array, ignoring non-text
 *  parts. Tolerant of the part shapes clients actually send: `{type:"text",
 *  text}` (OpenAI/pi), `{type:"input_text", text}` (Responses-style), or any
 *  part carrying a string `text`. */
export function contentPartsToText(parts: Array<Record<string, unknown>>): string {
  return parts
    .map((p) => (p && typeof p.text === "string" ? p.text : ""))
    .join("");
}

/** True if any content part is media — image OR audio — so the multimodal
 *  path must keep the array form for extractImages/extractAudio. */
export function hasMediaPart(parts: Array<Record<string, unknown>>): boolean {
  return parts.some(
    (p) =>
      p &&
      (p.type === "image" || p.type === "image_url" ||
        p.type === "audio" || p.type === "input_audio" || p.type === "audio_url" ||
        p.type === "video" || p.type === "video_url"),
  );
}

/** OpenAI sends assistant tool_call arguments as JSON strings; the
 *  template renders the object form natively — normalize before render.
 *
 *  Two more wire-format → template-format fixes, both "match the format the
 *  model's chat template expects":
 *
 *  1. Map the OpenAI reasoning-model "developer" role to "system": pi-ai (and
 *     OpenAI's own SDKs) rename the system prompt to `developer` whenever a
 *     model advertises reasoning, but our chat templates only know
 *     system/user/assistant/tool and raise "Unexpected message role." This is
 *     why Qwen3.5/MiniCPM5 chat got no messages while Gemma (non-reasoning, so
 *     pi keeps `system`) worked. `developer` IS the system prompt, so the remap
 *     is semantics-preserving.
 *
 *  2. Flatten text-only content-part arrays to a plain string. pi (and any
 *     OpenAI multimodal client) sends user content as `[{type:"text",text}]`,
 *     but non-vision chat templates expect `content` to be a STRING and render
 *     nothing for an array — so the user's turn silently vanishes and the model
 *     replies "I don't see any message." Arrays that carry a media part
 *     (image or audio) are left intact for the multimodal path
 *     (extractImages/extractAudio); only text-only arrays are collapsed
 *     here, which is a no-op for the vision templates too. */
export function normalizeMessages(messages: ChatMessage[]): ChatMessage[] {
  return messages.map((raw) => {
    let m = raw.role === "developer" ? { ...raw, role: "system" } : raw;
    if (Array.isArray(m.content) && !hasMediaPart(m.content)) {
      m = { ...m, content: contentPartsToText(m.content) };
    }
    if (!m.tool_calls) return m;
    return {
      ...m,
      tool_calls: m.tool_calls.map((tc) => ({
        ...tc,
        function: {
          ...tc.function,
          arguments:
            typeof tc.function.arguments === "string"
              ? (JSON.parse(tc.function.arguments) as Record<string, unknown>)
              : tc.function.arguments,
        },
      })),
    };
  });
}

/** Coerce a wire `logit_bias` ({"tokenId": bias}) to numeric keys/values —
 *  mlx_lm.server's `{int(k): float(v)}` coercion; throws its exact error
 *  message on anything non-numeric (surfaced as a 400). JSON object keys
 *  always arrive as strings, hence the coercion. */
export function parseLogitBias(
  raw: Record<string, number> | undefined | null,
): Record<number, number> | undefined {
  if (raw == null) return undefined;
  if (typeof raw !== "object" || Array.isArray(raw))
    throw new Error("logit_bias must be a dict of int to float");
  const out: Record<number, number> = {};
  for (const [k, v] of Object.entries(raw)) {
    const id = Number(k);
    const bias = Number(v);
    if (!Number.isInteger(id) || !Number.isFinite(bias))
      throw new Error("logit_bias must be a dict of int to float");
    out[id] = bias;
  }
  return Object.keys(out).length ? out : undefined;
}

/** Default seed for a request that didn't pin one. `Date.now()` alone is NOT
 *  request-unique: under `--batch N` the batch lane serves ONLY default-seed
 *  requests (explicit-seed requests use the serial mechanism, see
 *  GenerationGateway.place),
 *  so two identical prompts arriving in the same millisecond would share a seed
 *  and — with per-row RNG keyed as stepKey(seed, generatedCount) — produce
 *  byte-identical completions, silently collapsing best-of-N diversity. Mix a
 *  per-process Weyl counter (golden-ratio increment, period 2^32) into the
 *  timestamp so every call yields a distinct uint32 within any given ms.
 *  Determinism contract unchanged: reproducibility is only promised for an
 *  EXPLICIT request seed (`req.seed ?? nextDefaultSeed()` — explicit wins,
 *  byte-identical to before); a default seed is fresh entropy per request. */
let seedWeyl = 0;
export function nextDefaultSeed(): number {
  seedWeyl = (seedWeyl + 0x9e3779b9) >>> 0;
  return ((Date.now() & 0xffffffff) ^ seedWeyl) >>> 0;
}

/** mlx_lm.server's logprobs request validation, copied exactly (server.py
 *  APIHandler.validate_model_parameters: `_validate("logprobs", bool)` and
 *  `_validate("top_logprobs", int, min_val=0, max_val=11, whitelist=[-1])`
 *  with defaults logprobs=False / top_logprobs=-1). Returns the reference's
 *  error message (→ 400) or null when valid. Note mlx-lm caps top_logprobs
 *  at 11, not OpenAI's 20 — we mirror the reference. */
/** Build a degrade-path system-prompt instruction for JSON output, mirroring
 *  oMLX's api.tool_calling.build_json_system_prompt (used when xgrammar
 *  compile fails — the response_format degrades to prompt injection rather
 *  than a 500, oMLX parity). Returns null for {type:"text"} / unset. */
export function degradeJsonSystemPrompt(body: ChatRequest): string | null {
  if (body.guided_grammar) {
    return "You must respond with text matching this grammar:\n\n" + body.guided_grammar;
  }
  const rf = body.response_format as { type?: string; json_schema?: { name?: string; description?: string; schema?: unknown } } | undefined;
  if (rf && typeof rf === "object" && rf.type === "json_object") {
    return "You must respond with valid JSON only. " +
      "Do not include any explanation or text outside the JSON object.";
  }
  const schemaSpec = rf && typeof rf === "object" && rf.type === "json_schema"
    ? rf.json_schema
    : body.structured_outputs && typeof body.structured_outputs === "object"
      ? { schema: body.structured_outputs }
      : null;
  if (schemaSpec) {
    const spec = schemaSpec;
    const schema = spec.schema ?? body.structured_outputs ?? {};
    const name = spec.name ?? "response";
    const description = spec.description ?? "";
    let prompt = `You must respond with valid JSON matching the '${name}' schema.`;
    if (description) prompt += ` ${description}`;
    prompt += `\n\nJSON Schema:\n\`\`\`json\n${JSON.stringify(schema, null, 2)}\n\`\`\`\n\n` +
      "Respond with only the JSON object, no additional text or explanation.";
    return prompt;
  }
  if (body.guided_regex) {
    return "You must respond with text matching this regular expression:\n\n" +
      body.guided_regex;
  }
  if (body.guided_choice?.length) {
    return "You must respond with exactly one of these choices:\n\n" +
      body.guided_choice.map((choice) => JSON.stringify(choice)).join("\n");
  }
  return null;
}

export function applyGrammarDegrade(
  body: ChatRequest,
  degradeHint: string,
): { body: ChatRequest; warning: string } {
  const content = degradeJsonSystemPrompt(body) ??
    "Follow the requested output constraint exactly.";
  return {
    warning:
      `grammar not enforced: ${degradeHint} - falling back to prompt injection`,
    body: {
      ...body,
      messages: [{ role: "system", content }, ...body.messages],
    },
  };
}

export function validateLogprobsParams(body: {
  logprobs?: unknown;
  top_logprobs?: unknown;
}): string | null {
  const lp = body.logprobs ?? false;
  if (typeof lp !== "boolean") return "logprobs must be of type bool";
  const tl = body.top_logprobs ?? -1;
  if (typeof tl !== "number" || !Number.isInteger(tl))
    return "top_logprobs must be of type int";
  if (tl === -1) return null; // the "unset" whitelist sentinel
  if (tl < 0) return "top_logprobs must be at least 0";
  if (tl > 11) return "top_logprobs must be at most 11";
  return null;
}

const REASONING_EFFORT_LEVELS =
  ["none", "minimal", "low", "medium", "high", "xhigh"] as const;

/** Validate `reasoning_effort` against the accepted level names. An invalid
 *  string must NOT pass through: resolveEnableThinking treats any defined
 *  value ≠ "none" as thinking-ON, so a typo like "hihg" silently flipped the
 *  thinking channel (and its hotter temperature) on thinking-off models and
 *  burned a full default-depth reasoning budget (2026-08-18 review). Same
 *  contract style as validateLogprobsParams above. */
export function validateReasoningEffort(body: {
  reasoning_effort?: unknown;
}): string | null {
  const v = body.reasoning_effort;
  if (v === undefined || v === null) return null;
  if (typeof v !== "string" || !(REASONING_EFFORT_LEVELS as readonly string[]).includes(v))
    return "reasoning_effort must be one of " +
      "'none', 'minimal', 'low', 'medium', 'high', 'xhigh'";
  return null;
}
