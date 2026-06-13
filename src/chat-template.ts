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

export class ChatTemplate {
  readonly #template: Template;
  readonly #bosToken: string | null;
  readonly #eosToken: string | null;

  private constructor(source: string, bosToken: string | null, eosToken: string | null) {
    this.#template = new Template(source);
    this.#bosToken = bosToken;
    this.#eosToken = eosToken;
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
      tools,
      ...(enableThinking !== undefined ? { enable_thinking: enableThinking } : {}),
      bos_token: this.#bosToken,
      eos_token: this.#eosToken,
    });
  }
}
