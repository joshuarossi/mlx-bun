import { expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, readFileSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { RunningApp } from "../../src/cli/serve";
import type { ClientMessage, ServerMessage } from "../../src/chat/protocol";

const modelDir = process.env.MLX_BUN_APP_TEST_MODEL;

function contentText(content: unknown): string {
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return "";
  return content.map(part => part && typeof part === "object" &&
    part.type === "text" && typeof part.text === "string" ? part.text : "").join("");
}

async function deadline<T>(promise: Promise<T>, description: string, signal: AbortSignal): Promise<T> {
  let abort: (() => void) | undefined;
  try {
    return await Promise.race([promise, new Promise<never>((_, reject) => {
      abort = () => reject(new Error(`Aborted waiting for ${description}`, { cause: signal.reason }));
      signal.addEventListener("abort", abort, { once: true });
      if (signal.aborted) abort();
    })]);
  } finally { if (abort) signal.removeEventListener("abort", abort); }
}

function expectResponseContent(response: any) {
  const text = response.output.flatMap((item: any) => item.type === "message" && item.role === "assistant"
    ? item.content.filter((part: any) => part.type === "output_text").map((part: any) => part.text) : []).join("");
  const reasoning = response.output.flatMap((item: any) => item.type === "reasoning"
    ? item.summary.map((part: any) => part.text) : []).join("");
  // A short token budget may end in reasoning on a thinking checkpoint.
  expect((text || reasoning).trim().length).toBeGreaterThan(0);
}

/** Real WebSocket → Pi SDK → loopback HTTP → shared model, without an external
 * provider. All persistence belongs to the caller's temporary app paths. */
async function webChatTurn(base: URL, signal: AbortSignal) {
  const frames: ServerMessage[] = [];
  const observers = new Set<() => void>();
  const closed = Promise.withResolvers<void>();
  let failure: Error | undefined, socketClosed = false;
  const socket = new WebSocket(new URL("/ws/chat", base).href.replace("http:", "ws:"));
  const notify = () => { for (const observer of [...observers]) observer(); };
  socket.addEventListener("message", event => {
    try {
      const frame = JSON.parse(String(event.data)) as ServerMessage;
      frames.push(frame);
      if (frame.type === "error") failure = new Error(`Web chat error: ${frame.message}`);
      if (frame.type === "tool_start") failure = new Error(`Simple greeting unexpectedly invoked ${frame.tool}`);
    } catch (error) { failure = error as Error; }
    notify();
  });
  socket.addEventListener("error", () => { failure = new Error("Web chat socket failed"); notify(); });
  socket.addEventListener("close", () => { socketClosed = true; closed.resolve(); notify(); });
  async function waitFor(predicate: () => boolean, description: string) {
    let observer: (() => void) | undefined;
    try {
      await deadline(new Promise<void>((resolve, reject) => {
        observer = () => {
          if (failure) reject(failure);
          else if (predicate()) resolve();
          else if (socketClosed) reject(new Error(`Web chat closed before ${description}`));
        };
        observers.add(observer); observer();
      }), description, signal);
    } finally { if (observer) observers.delete(observer); }
  }
  const send = (message: ClientMessage) => socket.send(JSON.stringify(message));
  const prompt = "Reply with one short greeting. Do not use any tools.";
  try {
    await waitFor(() => frames.some(frame => frame.type === "ready"), "web chat ready");
    send({ type: "set_thinking", enabled: false });
    send({ type: "set_sampling", temperature: 0 });
    send({ type: "prompt", text: prompt });
    await waitFor(() => frames.some(frame => frame.type === "turn_end"), "real web chat turn");
    expect(frames.some(frame => frame.type === "turn_start")).toBe(true);
    const text = frames.flatMap(frame => frame.type === "text_delta" ? [frame.delta] : []).join("");
    expect(text.trim().length).toBeGreaterThan(0);
    expect(frames.filter(frame => frame.type === "error" || frame.type === "tool_approval_request")).toEqual([]);
    await waitFor(() => frames.some(frame => frame.type === "sessions" &&
      frame.items.some(item => item.path === frame.activePath)), "persisted session listing");
    const listing = frames.findLast(frame => frame.type === "sessions" && frame.activePath);
    if (listing?.type !== "sessions" || !listing.activePath) throw new Error("Missing active session path");
    const beforeReplay = frames.length;
    send({ type: "open_session", path: listing.activePath });
    await waitFor(() => frames.slice(beforeReplay).some(frame => frame.type === "history" &&
      frame.items.some(item => item.role === "user" && item.text === prompt) &&
      frame.items.some(item => item.role === "assistant" && item.text.trim().length > 0)), "persisted chat replay");
    return { prompt, text };
  } finally {
    socket.close(1000, "test complete");
    await deadline(closed.promise, "web chat close", AbortSignal.timeout(5_000));
  }
}

test("one abort budget ends stalled HTTP body and WebSocket waits and closes the socket", async () => {
  const budget = new AbortController();
  const prompted = Promise.withResolvers<void>();
  const closed = Promise.withResolvers<void>();
  const server = Bun.serve({
    hostname: "127.0.0.1", port: 0,
    fetch(request, server) {
      if (new URL(request.url).pathname === "/ws/chat") {
        if (server.upgrade(request)) return;
        return new Response("Upgrade required", { status: 400 });
      }
      return new Response(new ReadableStream({ start(controller) { controller.enqueue(new Uint8Array([1])); } }));
    },
    websocket: {
      open(socket) { socket.send(JSON.stringify({ type: "ready" })); },
      message(_socket, message) { if (JSON.parse(String(message)).type === "prompt") prompted.resolve(); },
      close() { closed.resolve(); },
    },
  });
  try {
    const response = await fetch(server.url, { signal: budget.signal });
    const body = deadline(response.arrayBuffer(), "stalled HTTP body", budget.signal);
    const chat = webChatTurn(server.url, budget.signal);
    const results = Promise.allSettled([body, chat]);
    await deadline(prompted.promise, "synthetic chat prompt", AbortSignal.timeout(2_000));
    budget.abort(new Error("Shared network budget exhausted"));
    expect((await results).map(result => result.status)).toEqual(["rejected", "rejected"]);
    await deadline(closed.promise, "synthetic socket cleanup", AbortSignal.timeout(2_000));
  } finally { budget.abort(); await server.stop(true); }
}, 10_000);

// Opt-in: uses an already-downloaded autoregressive model, never downloads one.
// Imports that can load native MLX remain inside the skipped test body. A supplied
// invalid model path or missing native runtime must fail rather than skip.
test.skipIf(!modelDir)("real HTTP protocols and Pi web chat share the continuous engine and persist an isolated session", async () => {
  const { startModelServer, parseServeOptions } = await import("../../src/cli/serve");
  const { scanSnapshot } = await import("@mlx-bun/hub/registry");
  const model = await scanSnapshot(modelDir!, "test-model");
  if (!model) throw new Error("Model path has no loadable checkpoint");
  const root = mkdtempSync(join(tmpdir(), "mlx-real-app-"));
  const cwd = join(root, "project"), vault = join(root, "vault"), sessions = join(root, "sessions");
  mkdirSync(cwd); mkdirSync(join(vault, "articles"), { recursive: true });
  writeFileSync(join(vault, "articles", "Travel.md"), "# Travel\n\nTravel preferences.\n\n## Preference\n\nTake the early train.\n");
  const options = parseServeOptions({ values: { port: "0", "max-tokens": "8", "prompt-cache": "0.125", "no-open": true,
    thinking: "off" }, positionals: [] });
  // Pi includes its system prompt and actual tool schemas. This is a
  // programmatic test budget, not a new serving CLI flag or product default.
  options.contextLimit = 16_384;
  options.readOnly = true;
  options.chatPaths = { cwd, agentDir: join(root, "agent"), sessionDir: sessions, toolApprovalsFile: join(root, "approvals.json") };
  options.memoryPaths = { vault, skills: join(root, "skills") };
  let app: RunningApp | undefined;
  // One cumulative network budget leaves time for cleanup below Bun's 180s cap.
  const budget = new AbortController();
  const timer = setTimeout(() => budget.abort(new Error("Network budget exhausted")), 120_000);
  const signal = budget.signal;
  const json = (response: Response) => deadline(response.json(), "HTTP JSON body", signal);
  try {
    app = await startModelServer(model, options);
    const base = new URL(`http://127.0.0.1:${app.port}`);
    const page = await fetch(base, { signal });
    expect(page.headers.get("content-type")).toContain("text/html");
    await deadline(page.arrayBuffer(), "browser HTML", signal);
    const health = await fetch(new URL("/health", base), { signal });
    expect(health.status).toBe(200);
    await deadline(health.arrayBuffer(), "health body", signal);
    const stats = await fetch(new URL("/stats", base), { signal });
    expect(stats.status).toBe(200);
    expect((await json(stats)).batch).toMatchObject({ mode: "batch", batched: true });
    const fit = await fetch(new URL("/fit", base), { signal });
    expect(fit.status).toBe(200);
    expect((await json(fit)).report.max_safe_context).toBeGreaterThan(0);
    const post = (path: string, body: unknown) => fetch(new URL(path, base), { method: "POST", signal,
      headers: { "content-type": "application/json" }, body: JSON.stringify(body) });
    const body = { messages: [{ role: "user", content: "Say hello in one sentence." }], max_tokens: 8, temperature: 0 };
    const request = (options: typeof body & { stream?: boolean } = body) => post("/v1/chat/completions", options);
    const baselineResponse = await request();
    expect(baselineResponse.status).toBe(200);
    const baseline = await json(baselineResponse);
    expect(baseline.choices).toHaveLength(1);
    const pair = await Promise.all([request(), request()]);
    for (const response of pair) {
      expect(response.status).toBe(200);
      const repeated = await json(response);
      expect(repeated.choices).toEqual(baseline.choices);
      expect(repeated.usage.prompt_tokens_details.cached_tokens).toBeGreaterThan(0);
    }
    const liveStatsResponse = await fetch(new URL("/stats", base), { signal });
    expect(liveStatsResponse.status).toBe(200);
    const liveStats = await json(liveStatsResponse);
    expect(liveStats.prompt_cache.hits).toBeGreaterThanOrEqual(2);
    expect(liveStats.admission.weights_bytes).toBeGreaterThan(0);
    const stream = await request({ ...body, max_tokens: 128, stream: true });
    expect(stream.status).toBe(200);
    const reader = stream.body!.getReader();
    try { expect((await deadline(reader.read(), "stream chunk", signal)).done).toBe(false); }
    finally { await deadline(reader.cancel(), "stream cancellation", signal); }
    const afterCancel = await request();
    expect(afterCancel.status).toBe(200);
    await deadline(afterCancel.arrayBuffer(), "completion after cancellation", signal);

    const messagesResponse = await post("/v1/messages", { ...body, model: "local" });
    expect(messagesResponse.status).toBe(200);
    const message = await json(messagesResponse);
    expect(message.type).toBe("message"); expect(message.role).toBe("assistant");
    expect(Array.isArray(message.content)).toBe(true);
    const messageReasoning = message.content.filter((part: any) => part.type === "thinking")
      .map((part: any) => part.thinking).join("");
    expect((contentText(message.content) || messageReasoning).trim().length).toBeGreaterThan(0);
    expect(["end_turn", "max_tokens"]).toContain(message.stop_reason);
    expect(message.usage.input_tokens).toBeGreaterThan(0);
    expect(message.usage.output_tokens).toBeGreaterThan(0);
    expect(message.usage.output_tokens).toBeLessThanOrEqual(8);

    const responseResponse = await post("/v1/responses", { model: "local", input: "Say hello in one sentence.", max_output_tokens: 8, temperature: 0 });
    expect(responseResponse.status).toBe(200);
    const response = await json(responseResponse);
    expect(response.object).toBe("response"); expect(Array.isArray(response.output)).toBe(true);
    expect(["completed", "incomplete"]).toContain(response.status);
    expectResponseContent(response);
    expect(response.usage.input_tokens).toBeGreaterThan(0);
    expect(response.usage.output_tokens).toBeGreaterThan(0);
    expect(response.usage.output_tokens).toBeLessThanOrEqual(8);
    const followupResponse = await post("/v1/responses", { model: "local", previous_response_id: response.id,
      input: "Now say goodbye in one sentence.", max_output_tokens: 8, temperature: 0 });
    expect(followupResponse.status).toBe(200);
    const followup = await json(followupResponse);
    expect(followup.object).toBe("response"); expect(followup.id).not.toBe(response.id);
    expectResponseContent(followup);
    expect(followup.previous_response_id).toBe(response.id);
    expect(followup.usage.input_tokens).toBeGreaterThan(response.usage.input_tokens);
    expect(followup.usage.output_tokens).toBeGreaterThan(0);
    expect(followup.usage.output_tokens).toBeLessThanOrEqual(8);

    const chat = await webChatTurn(base, signal);
    await app.close();
    await expect(fetch(base, { signal })).rejects.toThrow();
    const transcripts = readdirSync(sessions).filter(name => name.endsWith(".jsonl"));
    expect(transcripts).toHaveLength(1);
    const entries = readFileSync(join(sessions, transcripts[0]!), "utf8").trim().split("\n")
      .map(line => JSON.parse(line));
    expect(entries.some(entry => entry.type === "message" && entry.message?.role === "user" && contentText(entry.message.content) === chat.prompt)).toBe(true);
    expect(entries.some(entry => entry.type === "message" && entry.message?.role === "assistant" && contentText(entry.message.content).trim() === chat.text.trim())).toBe(true);
    expect(readFileSync(join(root, "skills", "memory", "SKILL.md"), "utf8")).toContain("name: memory");
  } finally {
    clearTimeout(timer); budget.abort();
    try { await app?.close(); } finally { rmSync(root, { recursive: true, force: true }); }
  }
}, 180_000);
