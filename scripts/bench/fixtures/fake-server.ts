// CPU-only stand-in for a serve command, for the runner's tests: accepts the
// same serve arguments, speaks the OpenAI streaming surface the benchmark
// measures, and misbehaves on request (--fake-mode) so supervision, cleanup and
// qualification paths are exercised without models or MLX.
import { appendFileSync, openSync, writeFileSync } from "node:fs";

const args = process.argv.slice(2);
const option = (name: string) => { const i = args.indexOf(`--${name}`); return i >= 0 ? args[i + 1] : undefined; };
const mode = option("fake-mode") ?? "ok";
const port = Number(option("port"));
const disconnectLog = option("fake-disconnect-log");
console.error(`fake server ${mode} on ${port}`);
if (mode === "exit") { console.error("fatal: fake startup failure marker"); process.exit(3); }
if (mode === "ignore-term") process.on("SIGTERM", () => console.error("ignoring SIGTERM"));
// Keep the intended library open, as a real server maps its MLX library.
if (process.env.MLX_BUN_LIBMLXC) openSync(process.env.MLX_BUN_LIBMLXC, "r");
// A second runtime library from elsewhere, as a mismatched install would load.
if (option("fake-open")) openSync(option("fake-open")!, "r");
// A relative output, as a server writing logs or caches next to itself would.
if (option("fake-touch")) writeFileSync(option("fake-touch")!, "relative output\n");

let requests = 0, failedOnce = false;
const seen = new Set<string>();
const encoder = new TextEncoder();
const promptTokens = (text: string) => Math.max(1, Math.round(text.length / 4));
function stream(tokens: number, perTokenMs: number, prompt: string, route: string, variant: string, signal: AbortSignal) {
  const cached = seen.has(prompt) ? promptTokens(prompt) : 0;
  seen.add(prompt);
  return new ReadableStream<Uint8Array>({
    async start(controller) {
      const send = (value: unknown) => controller.enqueue(encoder.encode(`data: ${JSON.stringify(value)}\n\n`));
      try {
        const t0 = performance.now();
        for (let i = 0; i < tokens; i++) {
          if (signal.aborted) throw signal.reason;
          // Absolute deadlines: timer jitter never accumulates into the measured rate.
          const wait = t0 + (i + 1) * perTokenMs - performance.now();
          if (wait > 0) await Bun.sleep(wait);
          const piece = `t${i}${variant} `;
          send(route === "completions" ? { choices: [{ text: piece }] } : { choices: [{ delta: { content: piece } }] });
        }
        send({ choices: [{ ...(route === "completions" ? { text: "" } : { delta: {} }), finish_reason: "length" }] });
        send({ choices: [], usage: { prompt_tokens: promptTokens(prompt), completion_tokens: tokens,
          prompt_tokens_details: { cached_tokens: cached } } });
        controller.enqueue(encoder.encode("data: [DONE]\n\n"));
        controller.close();
      } catch { /* client went away */ }
    },
    cancel() { if (disconnectLog) appendFileSync(disconnectLog, `disconnect ${Date.now()}\n`); },
  });
}

Bun.serve({ hostname: "127.0.0.1", port, idleTimeout: 0, async fetch(request) {
  const path = new URL(request.url).pathname;
  if (path === "/v1/models") return mode === "never-ready" ? new Response("loading", { status: 503 }) : Response.json({ data: [{ id: "fake" }] });
  if (path === "/admin/cache/flush")
    return mode === "no-flush" ? Response.json({ durable: false }, { status: 503 })
      : Response.json({ durable: true, pendingSnapshots: 0, pendingSpills: 0, droppedSpills: 0, failedSpills: 0, entries: 1, longest_durable_prefix_tokens: 16 });
  const body = await request.json() as { messages?: Array<{ content: string }>; prompt?: string; max_tokens: number; stream?: boolean };
  const prompt = body.prompt ?? body.messages?.[0]?.content ?? "";
  const variant = mode === "diverge" ? "x" : "";
  if (path === "/v1/completions" && !body.stream)
    return Response.json(mode === "empty-probe" ? { choices: [], usage: { prompt_tokens: 7 } }
      : { choices: [{ text: `2, 3, 5, 7${variant}`, finish_reason: "length" }], usage: { prompt_tokens: promptTokens(prompt), completion_tokens: 4 } });
  // agg-fail: the first attempt's second concurrent stream fails at once while its siblings are mid-stream.
  if (mode === "agg-fail" && prompt.startsWith("Agent 1 ") && !failedOnce) {
    failedOnce = true;
    return Response.json({ error: { message: "injected aggregate failure" } }, { status: 500 });
  }
  requests++;
  // Unstable: alternate decode rates far beyond the stability guard.
  const perTokenMs = mode === "slow" ? 400 : mode === "unstable" ? (requests % 2 ? 10 : 50)
    : mode === "agg-fail" && prompt.startsWith("Agent ") ? 60 : 25;
  if (path === "/v1/chat/completions" || path === "/v1/completions")
    return new Response(stream(body.max_tokens, perTokenMs, prompt, path.slice(4), variant, request.signal),
      { headers: { "content-type": "text/event-stream" } });
  return new Response("not found", { status: 404 });
} });
