// Chat template rendering via @huggingface/jinja (pure JS, purpose-built
// for HF chat templates). Decision recorded in PLAN.md Phase 1 findings:
// rendering the model's own chat_template.jinja beats a hand-port because
// it can't rot when the model updates its template.

import { Template } from "@huggingface/jinja";

export interface ChatMessage {
  role: string;
  content: string;
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
    const tokenText = (t: unknown): string | null =>
      t == null ? null : typeof t === "string" ? t : (t as any).content;
    return new ChatTemplate(source, tokenText(config.bos_token), tokenText(config.eos_token));
  }

  render(messages: ChatMessage[], addGenerationPrompt = true): string {
    return this.#template.render({
      messages,
      add_generation_prompt: addGenerationPrompt,
      bos_token: this.#bosToken,
      eos_token: this.#eosToken,
    });
  }
}
