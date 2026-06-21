// Throwaway diagnostic: capture the EXACT /v1/chat/completions request that a
// pi web session emits for one user turn, by pointing a real pi AgentSession at
// a tiny in-process capture endpoint (ephemeral port, single request, exits).
// Mirrors src/pi-web.ts createRuntimeFactory wiring so the captured body is
// representative of the live web chat.

import {
  createAgentSessionFromServices,
  createAgentSessionServices,
  SessionManager,
} from "@earendil-works/pi-coding-agent";
import { buildPiAgentSurface } from "../../src/pi-session";
import { buildPiProvider } from "../../src/pi-provider";
import { buildWebChatSystemPrompt } from "../../src/pi-web";

let captured: any = null;

const server = Bun.serve({
  port: 0,
  async fetch(req) {
    const url = new URL(req.url);
    if (url.pathname === "/v1/chat/completions" && req.method === "POST") {
      if (!captured) captured = await req.json();
      // Return a minimal non-streaming OpenAI completion so the turn ends.
      return Response.json({
        id: "chatcmpl-capture",
        object: "chat.completion",
        created: 0,
        model: "local",
        choices: [{ index: 0, message: { role: "assistant", content: "ok" }, finish_reason: "stop" }],
        usage: { prompt_tokens: 0, completion_tokens: 0, total_tokens: 0 },
      });
    }
    if (url.pathname === "/v1/models") {
      return Response.json({ data: [{ id: "local", object: "model", context_window: 32768 }] });
    }
    return new Response("{}", { headers: { "content-type": "application/json" } });
  },
});

const baseUrl = `http://127.0.0.1:${server.port}/v1`;
const provider = buildPiProvider(baseUrl, { contextWindow: 32768, reasoning: true });
const surface = await buildPiAgentSurface();
const systemPrompt = buildWebChatSystemPrompt(false, { modelId: "cpm5" }) + surface.memoryHint;

const services = await createAgentSessionServices({
  cwd: process.cwd(),
  authStorage: provider.authStorage,
  modelRegistry: provider.modelRegistry,
  resourceLoaderOptions: {
    noExtensions: true,
    noSkills: true,
    noPromptTemplates: true,
    noThemes: true,
    noContextFiles: true,
    additionalSkillPaths: surface.skillPaths,
    systemPrompt,
  },
});

const { session } = await createAgentSessionFromServices({
  services,
  sessionManager: SessionManager.inMemory(process.cwd()),
  model: provider.model,
  tools: surface.tools,
  customTools: surface.customTools,
});

console.error("default thinkingLevel:", session.thinkingLevel);
session.setThinkingLevel("off");
console.error("after setThinkingLevel('off'):", session.thinkingLevel);

await session.prompt("what's the weather like in Tokyo?");

server.stop(true);

if (!captured) {
  console.error("NO REQUEST CAPTURED");
  process.exit(1);
}

await Bun.write("/tmp/pi_body.json", JSON.stringify(captured));
console.log("WROTE /tmp/pi_body.json\n");
console.log("=== TOOLS (names) ===");
console.log((captured.tools ?? []).map((t: any) => t?.function?.name).join(", ") || "(none)");
console.log("\n=== MESSAGES (roles + previews) ===");
for (const m of captured.messages ?? []) {
  const text = typeof m.content === "string"
    ? m.content
    : Array.isArray(m.content)
      ? m.content.map((p: any) => p?.text ?? `[${p?.type}]`).join("")
      : JSON.stringify(m.content);
  console.log(`\n--- role=${m.role} (len ${text.length}) ---`);
  console.log(text.slice(0, 1400));
}
console.log("\n=== TOP-LEVEL KEYS ===");
console.log(Object.keys(captured).join(", "));
console.log("\n=== chat_template_kwargs / tool_choice / stop ===");
console.log(JSON.stringify({
  chat_template_kwargs: captured.chat_template_kwargs,
  tool_choice: captured.tool_choice,
  stop: captured.stop,
  enable_thinking: captured.enable_thinking,
}, null, 2));

process.exit(0);
