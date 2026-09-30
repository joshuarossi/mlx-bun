// A stand-in isolation worker for the parent-side tests (jobs/worker-supervisor,
// server/proxy-routes, cli/serve-isolated, cli/library-host): it speaks the worker handshake
// (the launch record on stdin, the ready line on stdout echoing its version,
// the end of stdin means the parent left, SIGTERM stops it) and serves a fake
// model surface on the socket. Behavior is driven by request content and `/fake/*` control
// routes, so a test reaches everything through the parent's proxy. Env:
// FAKE_WORKER_RECORD appends `{ argv, pid, launch }` per launch (the launch line as received);
// FAKE_WORKER_EVENTS appends `{ event, model, pid, at }` for loading, ready, drain, stop, and stopped (the exit after a slow close);
// FAKE_WORKER_FAIL=start exits 1 before ready, like a failed model load;
// FAKE_WORKER_FAIL_MODEL=<id> does the same for that model only (a worker that cannot load it);
// FAKE_WORKER_LOAD_MS delays the ready line, like a weights load.
// FAKE_WORKER_BAD_READY=1 sends a malformed handshake and remains alive.
// FAKE_WORKER_VERSION=<v> plays a worker of that package version: a launch record
// with another one is refused as the real entry refuses it (exit 2, the reason on stderr).
// FAKE_WORKER_STOP_MS delays the exit after SIGTERM, like an app closing; FAKE_WORKER_STOP_CODE is its exit code (3: the saved state was not durable);
// FAKE_WORKER_STOP_GATE=<path> holds it until that file exists (no clock involved).
// `POST /admin/memory/complete` plays the memory task model: each row answers
// `task <stage>: <user>` in order; a row whose user text contains `hold` waits
// for `/fake/memory/release` or the parent's disconnect, and `crash` exits 137
// under the call (events: memory, memory aborted, memory answered). The first
// call that answers "loads" the snapshot it carries (`task_snapshot` in
// `/fake/seen`), after any hold, like a lazy load behind the execution lease.
// FAKE_WORKER_MEMORY_JOIN_GATE=<path> holds an aborted call's settling until that
// file exists, like rows joining; SIGTERM waits for those joins, as the real
// worker's close does.
// `GET /admin/events` streams the worker's bus as JSON lines (a scheduler sample per `/fake/emit`).
// FAKE_WORKER_MEMORY={"<model id or *>":[active,cache,peak,workingSet]} plays a worker that measures its MLX memory: `/health` reports it,
// and the event stream carries it as a `worker.memory` line at connect and whenever `/fake/measure?active=&cache=&peak=` changes it.
// The app launch form (`{ kind: "app", argv }`) serves the `--model` argument as its model id.
import { appendFileSync, existsSync, readFileSync } from "node:fs";

const PREFIX = "<mlx-bun-worker>";
const reader = Bun.stdin.stream().getReader(), decoder = new TextDecoder(), encoder = new TextEncoder();
let text = "";
while (!text.includes("\n")) { const { done, value } = await reader.read(); if (done) break; text += decoder.decode(value, { stream: true }); }
const launchLine = text.slice(0, text.indexOf("\n"));
const launch = JSON.parse(launchLine, (_key, value: unknown) =>
  value !== null && typeof value === "object" && "$number" in value ? Number((value as { $number: string }).$number) : value) as
  { version?: string; socketPath: string; model?: { repoId: string; path: string }; options?: Record<string, unknown>; kind?: string; argv?: string[] };
if (process.env.FAKE_WORKER_RECORD) appendFileSync(process.env.FAKE_WORKER_RECORD, JSON.stringify({ argv: process.argv, pid: process.pid, launch: launchLine }) + "\n");
if (process.env.FAKE_WORKER_VERSION && launch.version !== process.env.FAKE_WORKER_VERSION) {
  console.error(`worker protocol version mismatch: the launch record is ${launch.version ?? "unversioned"}, this worker is ${process.env.FAKE_WORKER_VERSION}`);
  process.exit(2);
}
const modelId = launch.kind === "app" ? launch.argv![launch.argv!.lastIndexOf("--model") + 1]! : launch.model!.repoId;
const event = (name: string) => { if (process.env.FAKE_WORKER_EVENTS) appendFileSync(process.env.FAKE_WORKER_EVENTS, JSON.stringify({ event: name, model: modelId, pid: process.pid, at: Date.now() }) + "\n"); };
if (process.env.FAKE_WORKER_FAIL === "start" || process.env.FAKE_WORKER_FAIL_MODEL === modelId) { console.error("worker startup failed: fake load failure"); process.exit(1); }
console.log(`loading ${modelId}`);
event("loading");
if (process.env.FAKE_WORKER_LOAD_MS) await Bun.sleep(Number(process.env.FAKE_WORKER_LOAD_MS));

interface Seen { path: string; method: string; aborted: boolean; headers: Record<string, string>; body?: unknown; raw?: string }
const seen: Seen[] = [];
const leases = new Set<object>();
const gateOpen = async (path: string | undefined) => { while (path && !existsSync(path)) await Bun.sleep(10); };
const heldMemory = new Set<() => void>(), memoryJoins = new Set<Promise<void>>();
let taskSnapshot: string | undefined;
let draining = false, inFlight = 0, responseCount = 0;
/** The model the worker answers as: the one it was launched with. */
let current = modelId;
const emitters = new Set<() => void>();
const measuring = new Set<() => void>();
const memoryFor = (): number[] | undefined => {
  const raw = process.env.FAKE_WORKER_MEMORY;
  if (!raw) return undefined;
  const byModel = JSON.parse(raw) as Record<string, number[]>;
  return byModel[modelId] ?? byModel["*"];
};
let memory = memoryFor();
const chunk = (delta: Record<string, unknown>, finish: string | null) => ({
  id: "chatcmpl-fake", object: "chat.completion.chunk", created: 1, model: current, choices: [{ index: 0, delta, finish_reason: finish }],
});
const sse = (value: unknown) => `data: ${JSON.stringify(value)}\n\n`;
const frame = (name: string, value: unknown) => `event: ${name}\ndata: ${JSON.stringify(value)}\n\n`;
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
  if (path === "/health") return Response.json({ status: "ok", state: draining ? "draining" : "ready", model: current, pid: process.pid, in_flight: inFlight, leases: leases.size,
    ...(memory ? { memory: { active_bytes: memory[0], cache_bytes: memory[1], peak_bytes: memory[2], working_set_bytes: memory[3] ?? 0 } } : {}) });
  if (path === "/admin/lease") {
    const lease = {};
    leases.add(lease);
    const release = () => { leases.delete(lease); };
    request.signal.addEventListener("abort", release, { once: true });
    return new Response(new ReadableStream<Uint8Array>({ start(controller) { controller.enqueue(encoder.encode("leased\n")); }, cancel: release }),
      { headers: { "content-type": "application/octet-stream" } });
  }
  if (path === "/admin/events") {
    // The worker's own bus: a sample now and then, like the engine's telemetry; a test asks for one through /fake/emit.
    return new Response(new ReadableStream<Uint8Array>({ start(controller) {
      controller.enqueue(encoder.encode("\n"));
      const emit = () => { try { controller.enqueue(encoder.encode(JSON.stringify({ type: "scheduler.sample", at: Date.now(), model: current, active: 0, capacity: 8, queued: 0, tokensPerSecond: 0 }) + "\n")); } catch { /* closed */ } };
      emitters.add(emit);
      const measure = () => { if (memory) try { controller.enqueue(encoder.encode(JSON.stringify({ type: "worker.memory", at: Date.now(), activeBytes: memory[0], cacheBytes: memory[1], peakBytes: memory[2], workingSetBytes: memory[3] ?? 0 }) + "\n")); } catch { /* closed */ } };
      measuring.add(measure); measure();
      request.signal.addEventListener("abort", () => { emitters.delete(emit); measuring.delete(measure); }, { once: true });
    } }), { headers: { "content-type": "application/x-ndjson" } });
  }
  if (path === "/fake/measure") {
    const at = (name: string, index: number) => url.searchParams.has(name) ? Number(url.searchParams.get(name)) : memory?.[index] ?? 0;
    memory = [at("active", 0), at("cache", 1), at("peak", 2), memory?.[3] ?? 0];
    for (const measure of measuring) measure();
    return Response.json({ memory });
  }
  if (path === "/fake/emit") { for (const emit of emitters) emit(); return Response.json({ emitted: emitters.size }); }
  if (path === "/admin/drain") {
    entry.raw = await request.text();
    draining = true;
    console.error("drain requested");
    event("drain");
    return Response.json({ drained: true, state: "draining", model: current, in_flight: inFlight, leases: leases.size, waited_ms: 0, timed_out: false });
  }
  if (path === "/fake/seen") return Response.json({ pid: process.pid, model: current, seen, task_snapshot: taskSnapshot ?? null });
  if (path === "/fake/crash") { crash(Number(url.searchParams.get("code") ?? "137")); return Response.json({ crashing: true }); }
  // Until the marker file lists `times` pids (default 1), a worker appends its pid and exits without
  // answering (a transport failure for the caller); later requests are answered.
  if (path === "/fake/die") {
    const marker = url.searchParams.get("marker")!;
    const deaths = existsSync(marker) ? readFileSync(marker, "utf8").split("\n").filter(Boolean).length : 0;
    if (deaths < Number(url.searchParams.get("times") ?? "1")) { appendFileSync(marker, `${process.pid}\n`); process.exit(137); }
    return Response.json({ pid: process.pid, method: request.method });
  }
  if (path === "/fake/headers") return new Response("hop", { headers: { "x-kept": "yes", connection: "x-private-hop", "x-private-hop": "1",
    "keep-alive": "timeout=5", "proxy-authenticate": "Basic", trailer: "x-trailer", upgrade: "h2c" } });
  if (path === "/fake/memory/release") { const count = heldMemory.size; for (const release of [...heldMemory]) release(); return Response.json({ released: count }); }
  if (draining) return Response.json({ error: { message: "worker is draining; no new requests are admitted", type: "draining" } }, { status: 503 });
  if (path === "/admin/memory/complete" && request.method === "POST") {
    entry.raw = await request.text();
    const body = JSON.parse(entry.raw) as { call: string; snapshot: string; requests: { stage: string; input: { user: string }; maxTokens: number }[] };
    entry.body = body;
    event("memory");
    const users = body.requests.map(row => row.input.user);
    if (users.some(user => user.includes("crash"))) { crash(137); return new Promise<Response>(() => {}); }
    inFlight++;
    if (users.some(user => user.includes("hold"))) await new Promise<void>(resolve => {
      const release = () => { heldMemory.delete(release); resolve(); };
      heldMemory.add(release);
      request.signal.addEventListener("abort", () => {
        entry.aborted = true;
        const join = gateOpen(process.env.FAKE_WORKER_MEMORY_JOIN_GATE).then(() => { event("memory aborted"); release(); });
        memoryJoins.add(join);
        void join.finally(() => memoryJoins.delete(join));
      }, { once: true });
    });
    inFlight--;
    if (request.signal.aborted) return new Response(null, { status: 499 });
    taskSnapshot ??= body.snapshot;
    event("memory answered");
    return Response.json({ outputs: body.requests.map(row => `task ${row.stage}: ${row.input.user}`) });
  }
  if (path === "/v1/models") return Response.json({ object: "list", data: [{ id: current, object: "model", created: 1, owned_by: "mlx-bun",
    context_window: 4096, reasoning: false, vision: false, audio: false, gen_defaults: { temperature: 0.6, top_p: 0.9, top_k: null },
    capabilities: { chat_completions: true, transcription: false }, resident: true, current: true },
    // Like the real worker, the other local models follow as the registry knows them (FAKE_WORKER_MODELS, comma separated).
    ...(process.env.FAKE_WORKER_MODELS ?? "").split(",").filter(id => id && id !== current).map(id => ({ id, object: "model", created: 1, tier: "targeted" }))] });
  if (path === "/stats") return Response.json({ server: { owner: "serve", model: current, started_at: 1 },
    prompt_cache: { entries: 1, bytes: 2, max_bytes: 3 }, response_store: { entries: 99, bytes: 99, max_bytes: 99, ttl_ms: 99 },
    admission: { enforced_context_tokens: 2048, max_safe_context: 8192 }, batch: { configured: 8, active_rows: 0 } });
  if (path === "/library") return Response.json({ models: [{ repo_id: current, serving: true, refreshed: url.searchParams.get("refresh") === "1" }] });
  if (path.startsWith("/v1/audio/") && request.method === "POST") return Response.json({ text: "fake transcript", model: current });
  if (path === "/v1/chat/completions" && request.method === "POST") {
    entry.raw = await request.text();
    let body: { stream?: boolean; messages?: { role: string; content: unknown }[] };
    try { body = JSON.parse(entry.raw) as typeof body; } catch { return Response.json({ error: { message: "invalid JSON body", type: "invalid_request_error" } }, { status: 400 }); }
    entry.body = body;
    const prompt = userText(body);
    if (!body.stream) return Response.json({ id: "chatcmpl-fake", object: "chat.completion", created: 1, model: current,
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
    return hold(request, encoder.encode(frame("message_start", { type: "message_start", message: { id: "msg_fake", role: "assistant" } })), entry);
  }
  if (path === "/v1/responses" && request.method === "POST") {
    const body = await request.json() as { stream?: boolean; input?: unknown; instructions?: string | null; previous_response_id?: unknown };
    entry.body = body;
    const prompt = userText(body);
    const response = { id: `resp_${++responseCount}`, object: "response", model: current, previous_response_id: null,
      output: [{ type: "message", id: `msg_${responseCount}`, role: "assistant", status: "completed", content: [{ type: "output_text", text: `echo: ${prompt}`, annotations: [] }] }],
      instructions: body.instructions ?? null };
    if (!body.stream) return Response.json(response);
    if (prompt.includes("hang")) return hold(request, encoder.encode(frame("response.created", { type: "response.created", response })), entry);
    return new Response([frame("response.created", { type: "response.created", response }),
      frame("response.output_text.delta", { type: "response.output_text.delta", delta: `echo: ${prompt}` }),
      frame("response.completed", { type: "response.completed", response })].join(""), { headers: { "content-type": "text/event-stream" } });
  }
  return Response.json({ error: { message: "Not found" } }, { status: 404 });
} } as unknown as Parameters<typeof Bun.serve>[0]);

const stop = async () => {
  await Promise.allSettled([...memoryJoins]);
  console.error("stopping"); event("stop");
  if (process.env.FAKE_WORKER_STOP_MS) await Bun.sleep(Number(process.env.FAKE_WORKER_STOP_MS));
  await gateOpen(process.env.FAKE_WORKER_STOP_GATE);
  event("stopped");
  // FAKE_WORKER_STOP_CODE=3 plays a close whose saved state was not durable.
  void server.stop(true); process.exit(Number(process.env.FAKE_WORKER_STOP_CODE ?? "0"));
};
process.on("SIGTERM", stop);
void (async () => { for (;;) { const { done } = await reader.read(); if (done) { console.error("parent left"); process.exit(0); } } })();
// Ready only once SIGTERM and the parent's departure are handled, so a stop right after readiness is always observed.
console.log(PREFIX + (process.env.FAKE_WORKER_BAD_READY === "1" ? "invalid-json" : JSON.stringify({ type: "ready", socketPath: launch.socketPath, modelId, pid: process.pid, version: launch.version })));
event("ready");
