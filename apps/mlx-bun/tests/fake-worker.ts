// A stand-in isolation worker for the parent-side tests (jobs/worker-supervisor,
// server/proxy-routes, cli/serve-isolated): it speaks the worker handshake
// (the launch record on stdin, the ready line on stdout, the end of stdin
// means the parent left, SIGTERM stops it) and serves a fake model surface on
// the socket. Behavior is driven by request content and `/fake/*` control
// routes, so a test reaches everything through the parent's proxy. Env:
// FAKE_WORKER_RECORD appends `{ argv, pid, launch }` per launch (the launch line as received);
// FAKE_WORKER_FAIL=start exits 1 before ready, like a failed model load.
import { appendFileSync } from "node:fs";

const PREFIX = "<mlx-bun-worker>";
const reader = Bun.stdin.stream().getReader(), decoder = new TextDecoder(), encoder = new TextEncoder();
let text = "";
while (!text.includes("\n")) { const { done, value } = await reader.read(); if (done) break; text += decoder.decode(value, { stream: true }); }
const launchLine = text.slice(0, text.indexOf("\n"));
const launch = JSON.parse(launchLine, (_key, value: unknown) =>
  value !== null && typeof value === "object" && "$number" in value ? Number((value as { $number: string }).$number) : value) as
  { socketPath: string; model: { repoId: string; path: string }; options: Record<string, unknown> };
if (process.env.FAKE_WORKER_RECORD) appendFileSync(process.env.FAKE_WORKER_RECORD, JSON.stringify({ argv: process.argv, pid: process.pid, launch: launchLine }) + "\n");
if (process.env.FAKE_WORKER_FAIL === "start") { console.error("worker startup failed: fake load failure"); process.exit(1); }
console.log(`loading ${launch.model.repoId}`);

const modelId = launch.model.repoId;
interface Seen { path: string; method: string; aborted: boolean; headers: Record<string, string>; body?: unknown }
const seen: Seen[] = [];
const leases = new Set<object>();
let draining = false, inFlight = 0, responseCount = 0;
const chunk = (delta: Record<string, unknown>, finish: string | null) => ({
  id: "chatcmpl-fake", object: "chat.completion.chunk", created: 1, model: modelId, choices: [{ index: 0, delta, finish_reason: finish }],
});
const sse = (value: unknown) => `data: ${JSON.stringify(value)}\n\n`;
const event = (name: string, value: unknown) => `event: ${name}\ndata: ${JSON.stringify(value)}\n\n`;
/** The last user turn's text, from chat messages or Responses input items. */
const userText = (body: { messages?: unknown; input?: unknown }): string => {
  const items = Array.isArray(body.messages) ? body.messages : Array.isArray(body.input) ? body.input
    : typeof body.input === "string" ? [{ role: "user", content: body.input }] : [];
  const last = items.findLast((item: unknown) => !!item && typeof item === "object" && (item as { role?: unknown }).role === "user") as { content?: unknown } | undefined;
  const content = last?.content;
  return typeof content === "string" ? content : Array.isArray(content)
    ? content.map(part => part && typeof part === "object" && "text" in part ? String((part as { text: unknown }).text) : "").join("") : "";
};
// The same bytes every time, so a proxy test compares the proxied stream with a direct read.
const HELLO_FRAMES = [
  sse(chunk({ role: "assistant", content: "" }, null)), sse(chunk({ content: "Hello" }, null)), sse(chunk({ content: " from" }, null)),
  sse(chunk({ content: " the worker." }, null)), sse({ ...chunk({}, "stop"), usage: { prompt_tokens: 3, completion_tokens: 4, total_tokens: 7 } }), "data: [DONE]\n\n",
];
const crash = (code: number) => setTimeout(() => process.exit(code), 30);
const hold = (request: Request, first: Uint8Array, entry: Seen) => new Response(new ReadableStream<Uint8Array>({
  start(controller) {
    controller.enqueue(first);
    request.signal.addEventListener("abort", () => { entry.aborted = true; inFlight--; try { controller.close(); } catch { /* closed */ } }, { once: true });
  },
  cancel() { entry.aborted = true; },
}), { headers: { "content-type": "text/event-stream" } });

const server = Bun.serve({ unix: launch.socketPath, idleTimeout: 0, async fetch(request: Request) {
  const url = new URL(request.url), path = url.pathname;
  const entry: Seen = { path, method: request.method, aborted: false, headers: Object.fromEntries(request.headers) };
  seen.push(entry);
  request.signal.addEventListener("abort", () => { entry.aborted = true; }, { once: true });
  if (path === "/health") return Response.json({ status: "ok", state: draining ? "draining" : "ready", model: modelId, pid: process.pid, in_flight: inFlight, leases: leases.size });
  if (path === "/admin/lease") {
    const lease = {};
    leases.add(lease);
    const release = () => { leases.delete(lease); };
    request.signal.addEventListener("abort", release, { once: true });
    return new Response(new ReadableStream<Uint8Array>({ start(controller) { controller.enqueue(encoder.encode("leased\n")); }, cancel: release }),
      { headers: { "content-type": "application/octet-stream" } });
  }
  if (path === "/admin/drain") {
    draining = true;
    console.error("drain requested");
    return Response.json({ drained: true, state: "draining", model: modelId, in_flight: inFlight, leases: leases.size, waited_ms: 0, timed_out: false });
  }
  if (path === "/fake/seen") return Response.json({ pid: process.pid, seen });
  if (path === "/fake/crash") { crash(Number(url.searchParams.get("code") ?? "137")); return Response.json({ crashing: true }); }
  if (draining) return Response.json({ error: { message: "worker is draining; no new requests are admitted", type: "draining" } }, { status: 503 });
  if (path === "/v1/models") return Response.json({ object: "list", data: [{ id: modelId, object: "model", created: 1, owned_by: "mlx-bun",
    context_window: 4096, reasoning: false, vision: false, audio: false, gen_defaults: { temperature: 0.6, top_p: 0.9, top_k: null },
    capabilities: { chat_completions: true, transcription: false } }] });
  if (path === "/stats") return Response.json({ server: { owner: "serve", model: modelId, started_at: 1 },
    prompt_cache: { entries: 1, bytes: 2, max_bytes: 3 }, response_store: { entries: 99, bytes: 99, max_bytes: 99, ttl_ms: 99 },
    admission: { enforced_context_tokens: 2048, max_safe_context: 8192 }, batch: { configured: 8, active_rows: 0 } });
  if (path === "/library") return Response.json({ models: [{ repo_id: modelId, serving: true, refreshed: url.searchParams.get("refresh") === "1" }] });
  if (path === "/v1/chat/completions" && request.method === "POST") {
    const body = await request.json() as { stream?: boolean; messages?: { role: string; content: unknown }[] };
    entry.body = body;
    const prompt = userText(body);
    if (!body.stream) return Response.json({ id: "chatcmpl-fake", object: "chat.completion", created: 1, model: modelId,
      choices: [{ index: 0, message: { role: "assistant", content: `echo: ${prompt}` }, finish_reason: "stop" }],
      usage: { prompt_tokens: 3, completion_tokens: 4, total_tokens: 7 } });
    inFlight++;
    if (prompt.includes("hang")) return hold(request, encoder.encode(HELLO_FRAMES[0]! + sse(chunk({ content: "partial" }, null))), entry);
    if (prompt.includes("crash")) { crash(137); return hold(request, encoder.encode(HELLO_FRAMES[0]! + sse(chunk({ content: "partial" }, null))), entry); }
    inFlight--;
    return new Response(HELLO_FRAMES.join(""), { headers: { "content-type": "text/event-stream" } });
  }
  if (path === "/v1/messages" && request.method === "POST") {
    const body = await request.json() as { messages?: { role: string; content: unknown }[] };
    entry.body = body;
    return hold(request, encoder.encode(event("message_start", { type: "message_start", message: { id: "msg_fake", role: "assistant" } })), entry);
  }
  if (path === "/v1/responses" && request.method === "POST") {
    const body = await request.json() as { stream?: boolean; input?: unknown; instructions?: string | null; previous_response_id?: unknown };
    entry.body = body;
    const prompt = userText(body);
    const response = { id: `resp_${++responseCount}`, object: "response", model: modelId, previous_response_id: null,
      output: [{ type: "message", id: `msg_${responseCount}`, role: "assistant", status: "completed", content: [{ type: "output_text", text: `echo: ${prompt}`, annotations: [] }] }],
      instructions: body.instructions ?? null };
    if (!body.stream) return Response.json(response);
    if (prompt.includes("hang")) return hold(request, encoder.encode(event("response.created", { type: "response.created", response })), entry);
    return new Response([event("response.created", { type: "response.created", response }),
      event("response.output_text.delta", { type: "response.output_text.delta", delta: `echo: ${prompt}` }),
      event("response.completed", { type: "response.completed", response })].join(""), { headers: { "content-type": "text/event-stream" } });
  }
  return Response.json({ error: { message: "Not found" } }, { status: 404 });
} } as unknown as Parameters<typeof Bun.serve>[0]);

console.log(PREFIX + JSON.stringify({ type: "ready", socketPath: launch.socketPath, modelId, pid: process.pid }));
const stop = () => { console.error("stopping"); void server.stop(true); process.exit(0); };
process.on("SIGTERM", stop);
void (async () => { for (;;) { const { done } = await reader.read(); if (done) { console.error("parent left"); process.exit(0); } } })();
