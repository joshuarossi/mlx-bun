// Fake inference engine for the isolate-proxy tests: a tiny UDS server
// with the endpoints the proxy machinery needs to prove — health gating,
// body passthrough, SSE chunk granularity, abort propagation, crash/respawn.
// Spawned by tests/isolate-proxy.test.ts with SOCK in the environment.

const flagVal = (name: string): string | null => {
  const i = process.argv.indexOf(name);
  return i > -1 ? process.argv[i + 1]! : null;
};
const sock = flagVal("--unix") ?? process.argv[2] ?? process.env.SOCK!;
const model = flagVal("--model") ?? "default-model";
try { require("node:fs").unlinkSync(sock); } catch {}

let lastForeverAborted: boolean | null = null;

Bun.serve({
  unix: sock,
  async fetch(req) {
    const url = new URL(req.url);
    if (url.pathname === "/health") return Response.json({ ok: true, pid: process.pid });
    if (url.pathname === "/whoami") return Response.json({ model, pid: process.pid });
    if (url.pathname === "/v1/chat/completions" && req.method === "POST") {
      const body = await req.json() as { model?: string };
      return Response.json({ served_by: model, requested: body.model ?? null });
    }
    if (url.pathname === "/admin/drain" && req.method === "POST") {
      // Cross-process observability for eviction tests.
      require("node:fs").writeFileSync(`${sock}.drained`, model);
      return Response.json({ drained: true });
    }
    if (url.pathname === "/echo") {
      const body = await req.text();
      return Response.json({
        method: req.method,
        body,
        header: req.headers.get("x-probe") ?? null,
      });
    }
    if (url.pathname === "/sse") {
      // 4 chunks, 40 ms apart — the proxy must deliver them as separate
      // reads with the gaps preserved (no coalescing).
      return new Response(new ReadableStream({
        async start(c) {
          for (let i = 0; i < 4; i++) {
            c.enqueue(new TextEncoder().encode(`data: chunk${i} t=${Date.now()}\n\n`));
            await new Promise((r) => setTimeout(r, 40));
          }
          c.close();
        },
      }), { headers: { "content-type": "text/event-stream" } });
    }
    if (url.pathname === "/sse-forever") {
      lastForeverAborted = false;
      req.signal.addEventListener("abort", () => { lastForeverAborted = true; });
      return new Response(new ReadableStream({
        async pull(c) {
          c.enqueue(new TextEncoder().encode(`data: tick\n\n`));
          await new Promise((r) => setTimeout(r, 25));
        },
      }), { headers: { "content-type": "text/event-stream" } });
    }
    if (url.pathname === "/abort-status")
      return Response.json({ aborted: lastForeverAborted });
    if (url.pathname === "/die") {
      setTimeout(() => process.exit(7), 10);
      return Response.json({ dying: true });
    }
    return new Response("not found", { status: 404 });
  },
});
