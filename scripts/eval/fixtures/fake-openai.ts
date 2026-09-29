// CPU-only stand-in for a serve command, for the evaluation runner's tests:
// accepts `--model PATH --port N`, answers the OpenAI routes the runner uses
// from a scripted rule list (the first rule whose `match` occurs in the prompt
// or last user message), logs every request body, and keeps the intended MLX
// library open as a real server maps it. No model, MLX or Python.
import { appendFileSync, openSync, readFileSync } from "node:fs";

export interface FakeRule {
  match: string;
  content?: string;
  reasoning?: string;
  toolCall?: { name: string; arguments: Record<string, unknown> };
  topLogprobs?: Array<{ token: string; logprob: number }>;
  status?: number;
  /** Exit the process instead of answering (a crashed server). */
  exit?: boolean;
  /** Answer only after this long (a request still running at an interrupt). */
  delayMs?: number;
}

const args = process.argv.slice(2);
const option = (name: string) => { const i = args.indexOf(`--${name}`); return i >= 0 ? args[i + 1] : undefined; };
const port = Number(option("port")), log = option("fake-log");
const rules = JSON.parse(readFileSync(option("fake-script")!, "utf8")) as FakeRule[];
if (process.env.MLX_BUN_LIBMLXC) openSync(process.env.MLX_BUN_LIBMLXC, "r");
console.error(`fake openai server on ${port} for ${option("model")}`);

Bun.serve({ hostname: "127.0.0.1", port, idleTimeout: 0, async fetch(request) {
  const path = new URL(request.url).pathname;
  if (path === "/v1/models") return Response.json({ object: "list", data: [{ id: option("model"), object: "model" }] });
  if (request.method !== "POST" || (path !== "/v1/chat/completions" && path !== "/v1/completions"))
    return new Response("not found", { status: 404 });
  const body = await request.json() as { prompt?: string; messages?: Array<{ content: string }>; logprobs?: boolean; tools?: unknown[] };
  if (log) appendFileSync(log, JSON.stringify({ path, body }) + "\n");
  const text = body.prompt ?? body.messages?.at(-1)?.content ?? "";
  const rule = rules.find(r => text.includes(r.match)) ?? { match: "", content: "" };
  if (rule.exit) process.exit(3);
  if (rule.delayMs) await Bun.sleep(rule.delayMs);
  if (rule.status) return Response.json({ error: { message: "scripted failure" } }, { status: rule.status });
  const usage = { prompt_tokens: Math.max(1, Math.round(text.length / 4)), completion_tokens: 3, total_tokens: 0 };
  const top = rule.topLogprobs;
  const logprobs = body.logprobs && top ? { content: [{ id: 0, ...top[0], top_logprobs: top.map((t, id) => ({ id, ...t })) }] } : undefined;
  if (path === "/v1/completions")
    return Response.json({ object: "text_completion", choices: [{ index: 0, text: rule.content ?? top?.[0]?.token ?? "",
      ...(logprobs ? { logprobs } : {}), finish_reason: "stop" }], usage });
  const toolCalls = rule.toolCall && body.tools
    ? [{ id: "call_0", type: "function", function: { name: rule.toolCall.name, arguments: JSON.stringify(rule.toolCall.arguments) } }] : undefined;
  return Response.json({ object: "chat.completion", choices: [{ index: 0, message: { role: "assistant",
    content: toolCalls ? null : rule.content ?? "", ...(rule.reasoning ? { reasoning: rule.reasoning } : {}),
    ...(toolCalls ? { tool_calls: toolCalls } : {}) }, finish_reason: toolCalls ? "tool_calls" : "stop" }], usage });
} });
