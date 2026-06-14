// Loopback chat client for LLM-driven dataset templates. Posts to the
// mlx-bun server's own /v1/chat/completions endpoint (OpenAI shape, with
// tool calling). Ports the _llm_call / _llm_chat / _llm_chat_raw helpers
// from optiq's dataset_templates.py.

export interface ChatMessage {
  role: string;
  content: string;
  // Tool-call traces carry extra fields (tool_calls, tool_call_id, name).
  [k: string]: unknown;
}

export interface ChatOpts {
  maxTokens?: number;
  temperature?: number;
  /** Defaults to false: dataset generators need `content`, not a hidden
   *  `<think>` channel that eats the whole token budget. */
  enableThinking?: boolean;
  /** OpenAI tools array, forwarded for tool-use traces. */
  tools?: unknown[];
}

export interface LlmClient {
  /** One-shot/multi-turn chat; returns the assistant content string. */
  chat(messages: ChatMessage[], opts?: ChatOpts): Promise<string>;
  /** Non-streaming chat returning the full JSON body (for tool_calls). */
  chatRaw(messages: ChatMessage[], opts?: ChatOpts): Promise<any>;
}

const LOOPBACK_TOKEN = "sk-mlx-bun-local";

/**
 * Build a loopback chat client targeting `apiUrl` (the server's own base,
 * e.g. http://127.0.0.1:8080). `model` defaults to "local", the stable id
 * mlx-bun advertises for its served model.
 */
export function makeLlmClient(apiUrl: string, model = "local"): LlmClient {
  const base = apiUrl.replace(/\/+$/, "");

  async function chatRaw(messages: ChatMessage[], opts: ChatOpts = {}): Promise<any> {
    const body: Record<string, unknown> = {
      model,
      messages,
      max_tokens: opts.maxTokens ?? 512,
      temperature: opts.temperature ?? 0.7,
      chat_template_kwargs: { enable_thinking: opts.enableThinking ?? false },
    };
    if (opts.tools && opts.tools.length) body.tools = opts.tools;

    const resp = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${LOOPBACK_TOKEN}`,
      },
      body: JSON.stringify(body),
    });
    if (!resp.ok) {
      const detail = await resp.text().catch(() => "");
      throw new Error(`chat/completions ${resp.status}: ${detail.slice(0, 400)}`);
    }
    return resp.json();
  }

  async function chat(messages: ChatMessage[], opts?: ChatOpts): Promise<string> {
    const data = await chatRaw(messages, opts);
    return data?.choices?.[0]?.message?.content ?? "";
  }

  return { chat, chatRaw };
}
