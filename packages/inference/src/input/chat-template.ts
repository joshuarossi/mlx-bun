// Chat template rendering via @huggingface/jinja (pure JS, purpose-built
// for HF chat templates). Decision recorded in PLAN.md Phase 1 findings:
// rendering the model's own chat_template.jinja beats a hand-port because
// it can't rot when the model updates its template.

import { Template } from "@huggingface/jinja";

export interface ToolCall {
  id?: string;
  type?: "function";
  function: {
    name: string;
    /** Object form preferred; OpenAI's JSON-string form is normalized by
     *  the server before rendering. */
    arguments: Record<string, unknown> | string;
  };
}

export interface ChatMessage {
  role: string;
  content?: string | Array<Record<string, unknown>> | null;
  tool_calls?: ToolCall[];
  tool_call_id?: string;
  name?: string;
  reasoning?: string;
  reasoning_content?: string;
}

/** OpenAI-style tool definition (function type). */
export interface ToolDefinition {
  type: "function";
  function: {
    name: string;
    description?: string;
    parameters?: Record<string, unknown>;
  };
}

export interface RenderOptions {
  addGenerationPrompt?: boolean;
  tools?: ToolDefinition[] | null;
  enableThinking?: boolean;
  /** Template-level reasoning depth (Qwen3.8: xhigh|medium|low — the template
   *  RAISES on other values, so callers must map OpenAI levels first and only
   *  set this for templates that read it; see ChatTemplate.readsReasoningEffort). */
  reasoningEffort?: "xhigh" | "medium" | "low";
  /** Keep think blocks from historical assistant turns in the rendered prompt
   *  (Qwen3.8 `preserve_thinking`, template default true — better prompt-cache
   *  reuse and agent-trace continuity). Only passed when the template reads it. */
  preserveThinking?: boolean;
}

type ChatRenderer = (
  messages: ChatMessage[],
  options: RenderOptions,
) => string;

function glm52ContentText(content: ChatMessage["content"], label: string): string {
  if (typeof content === "string") return content;
  if (!Array.isArray(content))
    throw new Error(`${label} must be a string or an array of text parts`);
  return content.map((part, index) => {
    if (
      !part ||
      (part.type !== "text" && part.type !== "input_text") ||
      typeof part.text !== "string"
    ) {
      throw new Error(`${label}.${index}: GLM-5.2 supports text content only`);
    }
    return part.text;
  }).join("");
}

/** Text/tool subset of the pinned GLM-5.2 template used by Colibri. */
export function renderGlm52Chat(
  messages: ChatMessage[],
  options: RenderOptions = {},
): string {
  if (!Array.isArray(messages) || messages.length === 0)
    throw new Error("GLM-5.2 messages must be a non-empty array");
  const {
    addGenerationPrompt = true,
    tools = null,
    enableThinking = false,
  } = options;
  const prompt = ["[gMASK]<sop>"];
  if (enableThinking)
    prompt.push("<|system|>Reasoning Effort: Max");

  const normalizedTools = normalizeToolSchemas(tools);
  if (normalizedTools && normalizedTools.length > 0) {
    prompt.push(
      "<|system|>\n# Tools\n\nYou may call one or more functions to assist with the " +
      "user query.\n\nYou are provided with function signatures within <tools></tools> " +
      "XML tags:\n<tools>\n",
    );
    for (const tool of normalizedTools) {
      const fn = { ...tool.function } as Record<string, unknown>;
      delete fn.defer_loading;
      delete fn.strict;
      prompt.push(`${JSON.stringify(fn)}\n`);
    }
    prompt.push(
      "</tools>\n\nFor each function call, output the function name and arguments " +
      "within the following XML format:\n<tool_call>{function-name}" +
      "<arg_key>{arg-key-1}</arg_key><arg_value>{arg-value-1}</arg_value>" +
      "<arg_key>{arg-key-2}</arg_key><arg_value>{arg-value-2}</arg_value>...</tool_call>",
    );
  }

  let previousWasTool = false;
  for (let index = 0; index < messages.length; index++) {
    const message = messages[index]!;
    const role = message.role;
    if (role === "system" || role === "developer") {
      prompt.push(
        `<|system|>${glm52ContentText(message.content, `messages.${index}.content`)}`,
      );
    } else if (role === "user") {
      prompt.push(
        `<|user|>${glm52ContentText(message.content, `messages.${index}.content`)}`,
      );
    } else if (role === "assistant") {
      const content = message.content === null || message.content === undefined
        ? ""
        : glm52ContentText(message.content, `messages.${index}.content`);
      prompt.push(`<|assistant|><think></think>${content.trim()}`);
      for (const call of message.tool_calls ?? []) {
        const raw = call.function.arguments;
        let args: Record<string, unknown> = {};
        if (typeof raw === "string") {
          try {
            const parsed = JSON.parse(raw);
            if (parsed && typeof parsed === "object" && !Array.isArray(parsed))
              args = parsed as Record<string, unknown>;
          } catch {
            // Match the pinned template path: malformed historical arguments
            // contribute an empty call body rather than changing the prompt.
          }
        } else {
          args = raw;
        }
        prompt.push(`<tool_call>${call.function.name}`);
        for (const [key, value] of Object.entries(args)) {
          prompt.push(
            `<arg_key>${key}</arg_key><arg_value>` +
            `${typeof value === "string" ? value : JSON.stringify(value)}</arg_value>`,
          );
        }
        prompt.push("</tool_call>");
      }
    } else if (role === "tool") {
      if (!previousWasTool) prompt.push("<|observation|>");
      prompt.push(
        `<tool_response>${glm52ContentText(message.content, `messages.${index}.content`)}` +
        "</tool_response>",
      );
    } else {
      throw new Error(`GLM-5.2 unsupported message role ${JSON.stringify(role)}`);
    }
    previousWasTool = role === "tool";
  }
  if (addGenerationPrompt) {
    prompt.push(
      enableThinking
        ? "<|assistant|><think>"
        : "<|assistant|><think></think>",
    );
  }
  return prompt.join("");
}

/** JSON-schema type implied by a literal value. */
function jsonTypeOf(v: unknown): string {
  if (typeof v === "number") return Number.isInteger(v) ? "integer" : "number";
  if (typeof v === "boolean") return "boolean";
  if (Array.isArray(v)) return "array";
  if (v !== null && typeof v === "object") return "object";
  return "string";
}

/** Infer a JSON-schema `type` for a node that lacks one (enum/const/anyOf/…). */
function inferSchemaType(node: Record<string, unknown>): string {
  if (Array.isArray(node.enum) && node.enum.length > 0) return jsonTypeOf(node.enum[0]);
  if ("const" in node) return jsonTypeOf(node.const);
  if (node.properties || node.additionalProperties) return "object";
  if (node.items !== undefined || node.prefixItems !== undefined) return "array";
  for (const key of ["anyOf", "oneOf", "allOf"] as const) {
    const subs = node[key];
    if (Array.isArray(subs) && subs.length > 0) {
      const types = subs
        .map((s) => (s && typeof s === "object" ? (s as Record<string, unknown>).type : undefined))
        .filter((t): t is string => typeof t === "string");
      const first = types[0];
      if (first !== undefined) return first;
    }
  }
  return "string";
}

/**
 * Recursively ensure every JSON-schema node carries a `type`.
 *
 * Why: HF chat templates (e.g. Gemma's tool-declaration block) do
 * `value['type'] | upper`, which throws "Cannot apply filter upper to
 * UndefinedValue" for schemas that describe a parameter via `anyOf`/`enum`/
 * `const` without a top-level `type` (TypeBox unions/literals emit exactly
 * this). We synthesize a sensible `type` so any tool renders, regardless of
 * how its schema was authored. Returns a new object; never mutates input.
 */
export function normalizeSchemaTypes(node: unknown): unknown {
  if (Array.isArray(node)) return node.map(normalizeSchemaTypes);
  if (!node || typeof node !== "object") return node;
  const out: Record<string, unknown> = { ...(node as Record<string, unknown>) };
  if (out.properties && typeof out.properties === "object") {
    const props: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(out.properties as Record<string, unknown>)) props[k] = normalizeSchemaTypes(v);
    out.properties = props;
  }
  if (out.items !== undefined) out.items = normalizeSchemaTypes(out.items);
  if (out.prefixItems !== undefined) out.prefixItems = normalizeSchemaTypes(out.prefixItems);
  if (out.additionalProperties && typeof out.additionalProperties === "object") {
    out.additionalProperties = normalizeSchemaTypes(out.additionalProperties);
  }
  for (const key of ["anyOf", "oneOf", "allOf"] as const) {
    if (Array.isArray(out[key])) out[key] = (out[key] as unknown[]).map(normalizeSchemaTypes);
  }
  if (typeof out.type !== "string") out.type = inferSchemaType(out);
  return out;
}

/** Apply normalizeSchemaTypes to every tool's parameter schema. */
export function normalizeToolSchemas(tools: ToolDefinition[] | null): ToolDefinition[] | null {
  if (!tools) return tools;
  return tools.map((t) => ({
    ...t,
    function: {
      ...t.function,
      parameters: t.function.parameters
        ? (normalizeSchemaTypes(t.function.parameters) as Record<string, unknown>)
        : t.function.parameters,
    },
  }));
}

export class ChatTemplate {
  readonly #template: Template | null;
  readonly #renderer: ChatRenderer | null;
  readonly #bosToken: string | null;
  readonly #eosToken: string | null;
  /** True when the template reads `reasoning_effort` (Qwen3.8's xhigh/medium/
   *  low depth control). Callers must not pass the variable otherwise — and
   *  must never pass unmapped OpenAI level names; this template family raises
   *  on values outside its supported set. */
  readonly readsReasoningEffort: boolean;
  /** True when the template reads `preserve_thinking` (Qwen3.8: keep think
   *  blocks from historical turns; template default true). */
  readonly readsPreserveThinking: boolean;
  /** Which reasoning format the template's `enable_thinking` channel uses, or
   *  null if the model has no switchable reasoning:
   *   - "think-tag": `<think>…</think>` text markers (Qwen3.5, MiniCPM5) — split
   *     from decoded text by ThinkingTagSplitter.
   *   - "gemma-channel": `<|channel>thought\n…<channel|>` (Gemma 4) — the markers
   *     are SPECIAL TOKENS stripped at decode, so reasoning is split at the token
   *     level in ToolAwareStream (gemma-sentinel mode), not from decoded text.
   *  Drives both the parser path and the reasoning capability advertised to Pi. */
  readonly thinkingFormat: "think-tag" | "gemma-channel" | null;
  /** True when the model has a switchable reasoning channel we can parse. */
  readonly supportsThinking: boolean;

  private constructor(
    source: string | null,
    bosToken: string | null,
    eosToken: string | null,
    forceNoThinking = false,
    renderer: ChatRenderer | null = null,
    explicitThinkingFormat: "think-tag" | "gemma-channel" | null = null,
  ) {
    if (source === null && renderer === null)
      throw new Error("ChatTemplate needs a Jinja source or renderer");
    this.#template = source === null ? null : new Template(source);
    this.#renderer = renderer;
    this.#bosToken = bosToken;
    this.#eosToken = eosToken;
    const gatesThinking = source?.includes("enable_thinking") ?? false;
    this.readsReasoningEffort = source?.includes("reasoning_effort") ?? false;
    this.readsPreserveThinking = source?.includes("preserve_thinking") ?? false;
    // `forceNoThinking` suppresses the switchable channel even when the template
    // carries the gemma markers. DiffusionGemma ships the shared gemma-family
    // template (with the `<|channel>thought…<channel|>` reasoning channel), but
    // its non-autoregressive canvas decode cannot reliably emit the `<channel|>`
    // close, so an enabled channel never ends (everything is captured as
    // reasoning, no answer). The OptiQ reference never enables thinking for this
    // model — it always renders the template's `default(false)` pre-closed empty
    // channel and decodes the whole canvas as plain text. We match that.
    this.thinkingFormat = explicitThinkingFormat ?? (forceNoThinking
      ? null
      : gatesThinking && source!.includes("<think>")
        ? "think-tag"
        : gatesThinking && source!.includes("<|channel>")
          ? "gemma-channel"
          : null);
    this.supportsThinking = this.thinkingFormat !== null;
  }

  static async load(
    modelDir: string,
    opts: { disableThinking?: boolean } = {},
  ): Promise<ChatTemplate> {
    const config = (await Bun.file(`${modelDir}/tokenizer_config.json`).json()) as Record<string, any>;
    let source: string | undefined = config.chat_template;
    if (!source) {
      const jinjaFile = Bun.file(`${modelDir}/chat_template.jinja`);
      if (await jinjaFile.exists()) source = await jinjaFile.text();
    }
    if (!source) {
      const modelConfigFile = Bun.file(`${modelDir}/config.json`);
      const modelConfig = await modelConfigFile.exists()
        ? await modelConfigFile.json() as Record<string, unknown>
        : null;
      if (modelConfig?.model_type === "glm_moe_dsa") {
        const tokenText = (t: unknown): string | null =>
          t == null ? null : typeof t === "string" ? t : (t as any).content;
        return new ChatTemplate(
          null,
          tokenText(config.bos_token),
          tokenText(config.eos_token),
          false,
          renderGlm52Chat,
          "think-tag",
        );
      }
      throw new Error(`${modelDir}: no chat template found`);
    }
    // @huggingface/jinja lacks the `min`/`max` array filters that real
    // Jinja2 has. MiniCPM5's template uses `[a, b]|min` in its assistant
    // tool-call history branch, so without this rewrite every multi-turn
    // tool conversation fails at render time ("Unknown ArrayValue filter").
    source = source
      .replace(
        /\[\s*([\w.]+)\s*,\s*([\w.]+)\s*\]\s*\|\s*min\b/g,
        "($1 if $1 < $2 else $2)",
      )
      .replace(
        /\[\s*([\w.]+)\s*,\s*([\w.]+)\s*\]\s*\|\s*max\b/g,
        "($1 if $1 > $2 else $2)",
      );
    const tokenText = (t: unknown): string | null =>
      t == null ? null : typeof t === "string" ? t : (t as any).content;
    return new ChatTemplate(source, tokenText(config.bos_token), tokenText(config.eos_token));
  }

  render(messages: ChatMessage[], options: RenderOptions = {}): string {
    if (this.#renderer) return this.#renderer(messages, options);
    const {
      addGenerationPrompt = true,
      tools = null,
      enableThinking,
      reasoningEffort,
      preserveThinking,
    } = options;
    return this.#template!.render({
      messages,
      add_generation_prompt: addGenerationPrompt,
      // Guarantee every tool param schema has a `type` so templates that do
      // `value['type'] | upper` (Gemma) never see UndefinedValue.
      tools: normalizeToolSchemas(tools),
      ...(enableThinking !== undefined ? { enable_thinking: enableThinking } : {}),
      // Only set for templates that read them: reasoning_effort values are
      // template-validated (Qwen3.8 raises on unknown levels), and an unread
      // variable in other templates is dead context at best.
      ...(reasoningEffort !== undefined && this.readsReasoningEffort
        ? { reasoning_effort: reasoningEffort }
        : {}),
      ...(preserveThinking !== undefined && this.readsPreserveThinking
        ? { preserve_thinking: preserveThinking }
        : {}),
      bos_token: this.#bosToken,
      eos_token: this.#eosToken,
    });
  }
}
