import { expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { superviseWorker, type WorkerSupervisor } from "../../src/jobs/worker-supervisor";
import { createProxyRoutes, unavailableFrame } from "../../src/server/proxy-routes";
import { createResponsesClient } from "../../src/server/responses-client";
import { ResponseStore } from "../../src/server/responses";

// The parent's proxy group over a real supervisor and the fake worker
// (tests/fake-worker.ts) on a Unix socket: streaming pass-through, abort and
// crash semantics, the parent-owned answers, and the Responses history.
const entry = new URL("../fake-worker.ts", import.meta.url).pathname;
const env = { MLX_BUN_LIBMLXC: "/does-not-exist", HF_HUB_OFFLINE: "1" };
const launch = (socketPath: string) => ({ socketPath, model: { repoId: "org/model", path: "/unused", expertsBytes: 0 },
  options: { query: null, hostname: "127.0.0.1", port: 0, capacity: 8, contextLimit: null, readOnly: false, noOpen: true, request: {}, cache: { kvQuant: "off" } } });

async function until(check: () => boolean | Promise<boolean>, what: string, timeoutMs = 5_000) {
  const end = Date.now() + timeoutMs;
  while (!await check()) { if (Date.now() > end) throw new Error(`timed out waiting for ${what}`); await Bun.sleep(5); }
}
// A respawn waits 200 ms so the down state is observable between a crash and the next worker.
function fixture(restarts = { max: 2, windowMs: 60_000, delayMs: 200 }) {
  const dir = mkdtempSync(join(tmpdir(), "mlx-worker-"));
  const socketPath = join(dir, "engine.sock");
  const notices: string[] = [];
  const engine = superviseWorker({ entry, socketPath, launch: launch(socketPath), env, graceMs: 500, restarts,
    notice: line => notices.push(line), error: () => {}, log: () => {} });
  const store = new ResponseStore();
  const downloads: { repoId: string; state: string }[] = [];
  const proxy = createProxyRoutes({ engine, responses: createResponsesClient(store), downloads: () => downloads, modelId: "org/model", startedAt: 42 });
  const request = (path: string, init: RequestInit = {}) => proxy.handle(new Request(`http://127.0.0.1:8080${path}`, init)) as Promise<Response>;
  const direct = (path: string, init: RequestInit = {}) => fetch(`http://worker${path}`, { ...init, unix: socketPath } as RequestInit);
  const seen = async () => (await (await request("/fake/seen")).json() as { pid: number; seen: { path: string; method: string; aborted: boolean; headers: Record<string, string>; body?: unknown }[] });
  return { dir, socketPath, engine, proxy, store, downloads, notices, request, direct, seen, remove: () => rmSync(dir, { recursive: true, force: true }) };
}
const chat = (text: string, stream = true) => ({ method: "POST", headers: { "content-type": "application/json", "proxy-authorization": "hop", "x-mlx-bun-trace-id": "trace-1" },
  body: JSON.stringify({ model: "local", stream, messages: [{ role: "user", content: text }] }) });
const readAll = async (response: Response) => new TextDecoder().decode(new Uint8Array(await response.arrayBuffer()));
const firstChunk = async (response: Response) => {
  const reader = response.body!.getReader();
  const { value } = await reader.read();
  return { reader, text: new TextDecoder().decode(value) };
};

test("model-scoped requests stream through byte for byte with hop-by-hop headers stripped; a client abort answers 499 and aborts the worker's request", async () => {
  const fake = fixture();
  const { request, engine } = fake;
  try {
    await engine.ready;
    const proxied = await request("/v1/chat/completions", chat("hello"));
    expect([proxied.status, proxied.headers.get("content-type")]).toEqual([200, "text/event-stream"]);
    expect(await readAll(proxied)).toBe(await readAll(await fake.direct("/v1/chat/completions", chat("hello"))));
    const json = await request("/v1/chat/completions", chat("hello", false));
    expect((await json.json() as { choices: { message: { content: string } }[] }).choices[0]!.message.content).toBe("echo: hello");
    const models = await request("/v1/models");
    expect((await models.json() as { data: { id: string }[] }).data[0]!.id).toBe("org/model");
    expect((await request("/nowhere")).status).toBe(404);
    const observed = await fake.seen();
    const streamed = observed.seen.find(entry => entry.path === "/v1/chat/completions")!;
    expect([streamed.headers["content-type"], streamed.headers["x-mlx-bun-trace-id"]]).toEqual(["application/json", "trace-1"]);
    expect(streamed.headers["proxy-authorization"]).toBeUndefined();
    expect(streamed.aborted).toBe(false);
    // A request already abandoned by its client answers 499 without reaching the worker.
    const gone = new AbortController(); gone.abort();
    expect((await request("/v1/models", { signal: gone.signal })).status).toBe(499);
    // An abort mid-stream ends the client's response and the worker sees the disconnect.
    const client = new AbortController();
    const hanging = await request("/v1/chat/completions", { ...chat("hang"), signal: client.signal });
    const { reader, text } = await firstChunk(hanging);
    expect(text).toContain('"role":"assistant"');
    client.abort();
    await reader.cancel().catch(() => {});
    await until(async () => (await fake.seen()).seen.some(entry => entry.body && JSON.stringify(entry.body).includes("hang") && entry.aborted), "the worker to see the abort");
    expect((await fake.seen()).seen.filter(entry => entry.path === "/v1/models").length).toBe(1);
    expect(engine.state).toBe("ready");
  } finally { await engine.close(); fake.remove(); }
});

test("a worker dying under a stream ends it with the protocol's error frame; requests answer 502 until the respawn, then serve again; exhaustion is a 502 until the server restarts", async () => {
  const fake = fixture({ max: 3, windowMs: 60_000, delayMs: 200 });
  const { request, engine } = fake;
  try {
    await engine.ready;
    const first = engine.pid!;
    for (const [path, init, prefix] of [
      ["/v1/messages", { method: "POST", body: JSON.stringify({ model: "local", stream: true, max_tokens: 8, messages: [{ role: "user", content: "hang" }] }) }, "event: message_start"],
      ["/v1/responses", { method: "POST", body: JSON.stringify({ model: "local", stream: true, input: "hang" }) }, "event: response.created"],
      ["/v1/chat/completions", chat("hang"), "data: "],
    ] as const) {
      await until(() => engine.state === "ready", `a serving worker before ${path}`);
      const pid = engine.pid!;
      const response = await request(path, init);
      const { reader, text } = await firstChunk(response);
      expect(text.startsWith(prefix)).toBe(true);
      process.kill(pid, "SIGKILL");
      let rest = "";
      for (;;) { const { done, value } = await reader.read(); if (done) break; rest += new TextDecoder().decode(value); }
      const message = /inference engine unavailable: the engine worker stopped while streaming this response(?: \(the worker was killed by SIGKILL\))?; it is being respawned/;
      expect(rest.endsWith("\n\n")).toBe(true);
      expect(rest.match(message)).not.toBeNull();
      expect(rest).toBe(unavailableFrame(path, rest.match(message)![0]));
      if (path !== "/v1/chat/completions") await until(() => engine.state === "ready" && engine.pid !== pid, "the respawn");
    }
    // The last crash spent the third restart; while the worker is down the answer is 502 with the reason and the state.
    await until(() => engine.state === "restarting", "the exit to be noticed");
    const down = await request("/v1/models");
    expect(down.status).toBe(502);
    expect(await down.json()).toEqual({ error: { message: "inference engine unavailable: the worker was killed by SIGKILL; respawning — retry shortly", type: "engine_unavailable", state: "restarting" } });
    await until(() => engine.state === "ready", "the respawn");
    expect(engine.pid).not.toBe(first);
    expect(engine.restarts).toBe(3);
    expect((await request("/v1/models")).status).toBe(200);
    // The budget is spent: one more crash is final, and the error says what to do.
    expect((await (await request("/fake/crash")).json())).toEqual({ crashing: true });
    await until(() => engine.state === "exhausted", "exhaustion");
    const exhausted = await request("/v1/chat/completions", chat("hello", false));
    expect(exhausted.status).toBe(502);
    expect(await exhausted.json()).toEqual({ error: { message: "inference engine unavailable: engine restart limit reached (3 in 60 s) after the worker exited with code 137; restart the server", type: "engine_unavailable", state: "exhausted" } });
    expect(fake.notices.at(-1)).toContain("restart limit reached");
  } finally { await engine.close(); fake.remove(); }
});

test("the parent answers /engine, /health, /stats and /downloads itself with the worker's contribution when it serves, and never forwards the private admin paths", async () => {
  const fake = fixture({ max: 1, windowMs: 60_000, delayMs: 200 });
  const { request, engine, proxy } = fake;
  try {
    // Before the first worker is ready: the parent already reports.
    expect(await (await request("/engine")).json()).toEqual({ isolated: true, state: "starting", pid: engine.pid, restarts: 0, socket: fake.socketPath,
      model: "org/model", last_exit: null, response_store: { entries: 0, bytes: 0, max_bytes: 32 * 1024 * 1024, ttl_ms: 3_600_000 } });
    expect((await request("/v1/models")).status).toBe(502);
    await engine.ready;
    const pid = engine.pid!;
    expect(await (await request("/engine")).json()).toMatchObject({ isolated: true, state: "ready", pid, restarts: 0, model: "org/model", last_exit: null });
    expect(await (await request("/health")).json()).toEqual({ status: "ok", isolated: true,
      engine: { state: "ready", pid, restarts: 0, socket: fake.socketPath, model: "org/model", last_exit: null, in_flight: 0, leases: 0 } });
    fake.downloads.push({ repoId: "org/other", state: "active" });
    expect(await (await request("/downloads")).json()).toEqual({ downloads: [{ repoId: "org/other", state: "active" }] });
    // /stats is the worker's, with the parent's Responses history and engine report on top.
    const stats = await (await request("/stats")).json() as Record<string, unknown>;
    expect(stats.server).toEqual({ owner: "serve", model: "org/model", started_at: 1 });
    expect(stats.admission).toEqual({ enforced_context_tokens: 2048, max_safe_context: 8192 });
    expect(stats.response_store).toEqual({ entries: 0, bytes: 0, max_bytes: 32 * 1024 * 1024, ttl_ms: 3_600_000 });
    expect(stats.engine).toMatchObject({ isolated: true, state: "ready", pid });
    // Worker-private and unmigrated paths are the listener's (501), never the worker's; /engine takes GET only.
    for (const [path, init] of [["/admin/lease", { method: "POST" }], ["/admin/drain", { method: "POST" }], ["/v1/memory/synthesize", { method: "POST" }], ["/engine", { method: "POST" }]] as const)
      expect(await request(path, init)).toBeNull();
    const seenBefore = (await fake.seen()).seen.map(entry => entry.path);
    expect(seenBefore.filter(path => path.startsWith("/admin") || path === "/engine")).toEqual([]);
    // Library invalidation reaches the worker's discovery cache.
    proxy.invalidateLibrary();
    await until(() => false, "", 100).catch(() => {});
    expect((await fake.seen()).seen.some(entry => entry.path === "/library")).toBe(true);
    // Down: the parent still answers; the worker's contribution is its absence.
    process.kill(pid, "SIGKILL");
    await until(() => engine.state === "restarting", "the exit");
    expect(await (await request("/health")).json()).toEqual({ status: "ok", isolated: true,
      engine: { state: "restarting", pid: null, restarts: 1, socket: fake.socketPath, model: "org/model", last_exit: { code: null, signal: "SIGKILL" } } });
    const partial = await request("/stats");
    expect(partial.status).toBe(200);
    expect(await partial.json()).toEqual({ server: { owner: "serve", model: "org/model", started_at: 42 },
      response_store: { entries: 0, bytes: 0, max_bytes: 32 * 1024 * 1024, ttl_ms: 3_600_000 },
      engine: { isolated: true, state: "restarting", pid: null, restarts: 1, socket: fake.socketPath, model: "org/model", last_exit: { code: null, signal: "SIGKILL" },
        response_store: { entries: 0, bytes: 0, max_bytes: 32 * 1024 * 1024, ttl_ms: 3_600_000 } },
      unavailable: "inference engine unavailable: the worker was killed by SIGKILL; respawning — retry shortly" });
    proxy.invalidateLibrary();
    await until(() => engine.state === "ready", "the respawn");
    expect(await (await request("/engine")).json()).toMatchObject({ state: "ready", restarts: 1, last_exit: { code: null, signal: "SIGKILL" } });
    expect(engine.pid).not.toBe(pid);
  } finally { await engine.close(); fake.remove(); }
});

test("the Responses history is the parent's: previous_response_id resolves here, the worker gets the resolved conversation, and records survive a worker restart", async () => {
  const fake = fixture({ max: 1, windowMs: 60_000, delayMs: 200 });
  const { request, engine, store } = fake;
  const responses = (body: unknown) => request("/v1/responses", { method: "POST", headers: { "content-type": "application/json", "content-length": "1" }, body: JSON.stringify(body) });
  try {
    await engine.ready;
    const first = await responses({ model: "local", input: "first question", instructions: "be brief" });
    expect(first.status).toBe(200);
    const record = await first.json() as { id: string; previous_response_id: string | null };
    expect(record).toMatchObject({ id: "resp_1", previous_response_id: null });
    expect(store.size).toBe(1);
    expect(store.get("resp_1")).toEqual({ input: [{ type: "message", role: "user", content: "first question" }],
      output: [{ type: "message", id: "msg_1", role: "assistant", status: "completed", content: [{ type: "output_text", text: "echo: first question", annotations: [] }] }],
      instructions: "be brief" });
    // A follow-up: the worker sees the whole conversation and no previous id; the caller gets the id back.
    const second = await responses({ model: "local", input: "second question", previous_response_id: "resp_1" });
    expect(await second.json()).toMatchObject({ id: "resp_2", previous_response_id: "resp_1" });
    const forwarded = (await fake.seen()).seen.filter(entry => entry.path === "/v1/responses");
    expect(forwarded).toHaveLength(2);
    expect(forwarded[1]!.headers["x-mlx-bun-response-owner"]).toBe("parent");
    expect(forwarded[1]!.headers["content-length"]).not.toBe("1");
    const conversation = forwarded[1]!.body as { model: string; instructions: string; previous_response_id?: unknown; input: { role: string }[] };
    expect([conversation.model, conversation.instructions, "previous_response_id" in conversation]).toEqual(["local", "be brief", false]);
    expect(conversation.input.map(item => item.role)).toEqual(["user", "assistant", "user"]);
    expect(JSON.stringify(conversation.input)).toContain("echo: first question");
    // Streaming: response objects carry the previous id and the completed record is remembered.
    const streamed = await responses({ model: "local", stream: true, input: "third", previous_response_id: "resp_2" });
    const frames = (await readAll(streamed)).split("\n\n").filter(Boolean);
    expect(frames[0]!.startsWith("event: response.created\ndata: ")).toBe(true);
    expect(JSON.parse(frames[0]!.split("\ndata: ")[1]!).response.previous_response_id).toBe("resp_2");
    expect(frames[1]).toBe(`event: response.output_text.delta\ndata: ${JSON.stringify({ type: "response.output_text.delta", delta: "echo: third" })}`);
    expect(frames[2]!.startsWith("event: response.completed\n")).toBe(true);
    expect(JSON.parse(frames[2]!.split("\ndata: ")[1]!).response.previous_response_id).toBe("resp_2");
    expect(store.size).toBe(3);
    expect(store.get("resp_3")!.input).toHaveLength(5);
    // Bad input answers here, before any worker traffic.
    expect((await responses({ input: "x", previous_response_id: "resp_missing" })).status).toBe(404);
    expect((await responses({ input: 5 })).status).toBe(400);
    expect((await request("/v1/responses", { method: "POST", body: "{" })).status).toBe(400);
    expect((await fake.seen()).seen.filter(entry => entry.path === "/v1/responses")).toHaveLength(3);
    // The worker restarts; the parent's records still resolve.
    process.kill(engine.pid!, "SIGKILL");
    await until(() => engine.state === "restarting", "the exit");
    expect((await responses({ input: "while down", previous_response_id: "resp_3" })).status).toBe(502);
    await until(() => engine.state === "ready", "the respawn");
    const afterRestart = await responses({ model: "local", input: "fourth", previous_response_id: "resp_3" });
    expect(await afterRestart.json()).toMatchObject({ id: "resp_1", previous_response_id: "resp_3" });
    expect(store.get("resp_1")!.input).toHaveLength(7);
  } finally { await engine.close(); fake.remove(); }
});
