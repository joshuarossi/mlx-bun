// Dev stub for the browser chat page: serves src/chat-page.html with a
// /v1/models payload and a fake streaming /v1/chat/completions that echoes
// the received turns — so the chat UI (incl. the system-prompt field) can
// be styled and verified without loading a model. Mirrors status-page-stub.
import chatPageHtml from "../src/chat-page.html" with { type: "text" };

const port = Number(process.argv[2] ?? 8098);
const enc = new TextEncoder();

Bun.serve({
  port,
  async fetch(req) {
    const path = new URL(req.url).pathname;
    if (path === "/" || path === "/chat")
      return new Response(chatPageHtml as unknown as string, {
        headers: { "content-type": "text/html; charset=utf-8" },
      });
    if (path === "/v1/models")
      return Response.json({ data: [{ id: "mlx-community/MiniCPM5-1B-OptiQ-4bit (stub)", context_window: 131072 }] });
    if (path === "/v1/chat/completions" && req.method === "POST") {
      const body = (await req.json().catch(() => ({}))) as {
        messages?: { role: string; content: string }[];
      };
      const msgs = body.messages ?? [];
      const sys = msgs.find((m) => m.role === "system");
      const user = [...msgs].reverse().find((m) => m.role === "user");
      // Echo back what the page sent — proves the system-prompt field is
      // captured (multi-line included) and the turns are structured.
      const reply =
        `Stub reply (no model loaded).\n\n` +
        `System prompt received: ${sys ? `${sys.content.length} chars across ${sys.content.split("\n").length} line(s)` : "none"}.\n` +
        (sys ? `First line: "${(sys.content.split("\n")[0] ?? "").slice(0, 80)}"\n` : "") +
        `You said: "${(user?.content ?? "").slice(0, 120)}"`;
      const chunks = reply.match(/\S+\s*/g) ?? [reply];
      const stream = new ReadableStream({
        start(controller) {
          for (const c of chunks)
            controller.enqueue(enc.encode(`data: ${JSON.stringify({ choices: [{ delta: { content: c } }] })}\n\n`));
          controller.enqueue(enc.encode("data: [DONE]\n\n"));
          controller.close();
        },
      });
      return new Response(stream, { headers: { "content-type": "text/event-stream" } });
    }
    return new Response("not found", { status: 404 });
  },
});
console.log(`chat-page stub on http://localhost:${port}/`);
