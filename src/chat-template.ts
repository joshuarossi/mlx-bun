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
  readonly #template: Template;
  readonly #bosToken: string | null;
  readonly #eosToken: string | null;
  /** True when the template gates reasoning on `enable_thinking` AND uses the
   *  `<think>…</think>` channel our /v1 ThinkingTagSplitter normalizes (Qwen3.5,
   *  MiniCPM5). Requiring `<think>` excludes models that gate on enable_thinking
   *  but emit a DIFFERENT reasoning format we don't yet split — e.g. Gemma e4b /
   *  gpt-oss use a `<|channel>thought…<channel|>` (harmony-style) channel, so
   *  turning their thinking on leaks the raw markers + reasoning into the answer.
   *  Drives the reasoning capability advertised to Pi/clients. */
  readonly supportsThinking: boolean;

  private constructor(source: string, bosToken: string | null, eosToken: string | null) {
    this.#template = new Template(source);
    this.#bosToken = bosToken;
    this.#eosToken = eosToken;
    this.supportsThinking = source.includes("enable_thinking") && source.includes("<think>");
  }

  static async load(modelDir: string): Promise<ChatTemplate> {
    const config = (await Bun.file(`${modelDir}/tokenizer_config.json`).json()) as Record<string, any>;
    let source: string | undefined = config.chat_template;
    if (!source) {
      const jinjaFile = Bun.file(`${modelDir}/chat_template.jinja`);
      if (await jinjaFile.exists()) source = await jinjaFile.text();
    }
    if (!source) throw new Error(`${modelDir}: no chat template found`);
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
    const { addGenerationPrompt = true, tools = null, enableThinking } = options;
    return this.#template.render({
      messages,
      add_generation_prompt: addGenerationPrompt,
      // Guarantee every tool param schema has a `type` so templates that do
      // `value['type'] | upper` (Gemma) never see UndefinedValue.
      tools: normalizeToolSchemas(tools),
      ...(enableThinking !== undefined ? { enable_thinking: enableThinking } : {}),
      bos_token: this.#bosToken,
      eos_token: this.#eosToken,
    });
  }
}
