import { expect, test } from "bun:test";
import { resolve } from "node:path";
import { createCompletionClient, createDirectHost, type CompletionClient, type CompletionCall,
  type CompletionResponse, type EngineHost } from "mlx-bun/client";

// The public `mlx-bun/client` entry, imported through the package export map
// as a consumer would. No model, no native library; transports are recorded
// hosts or a loopback listener this file starts and stops.

const packageRoot = resolve(import.meta.dir, "..");

interface Seen { url: string; method: string; headers: Record<string, string>; body: unknown }
function recordingHost(reply: () => Response | Promise<Response> = () => Response.json({ choices: [] })) {
  const seen: Seen[] = [];
  const host: EngineHost<Request, Response> = createDirectHost(async request => {
    seen.push({ url: request.url, method: request.method, headers: Object.fromEntries(request.headers), body: await request.json() });
    return reply();
  });
  return { seen, host };
}

test("the entry imports through the export map without native MLX and exposes only the client values", async () => {
  const child = Bun.spawn([process.execPath, "--no-env-file", "-e",
    'const entry = await import("mlx-bun/client"); console.log(JSON.stringify(Object.keys(entry).sort()));'], {
    cwd: packageRoot, stdout: "pipe", stderr: "pipe",
    env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent/mlx-client-import-test.dylib" },
  });
  const deadline = setTimeout(() => child.kill("SIGKILL"), 10_000);
  try {
    const [stdout, stderr, code] = await Promise.all([
      new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited,
    ]);
    expect({ code, stderr }).toEqual({ code: 0, stderr: "" });
    expect(JSON.parse(stdout)).toEqual(["createCompletionClient", "createDirectHost"]);
  } finally { clearTimeout(deadline); }
});

test("requests post the exact route with merged JSON headers and a non-streaming body", async () => {
  const { seen, host } = recordingHost();
  try {
    const headers = { authorization: "Bearer local", "content-type": "text/plain" };
    for (const baseUrl of ["http://engine/v1", "http://engine/v1/"]) {
      const client = createCompletionClient({ baseUrl, headers, host });
      await client.complete({ body: { messages: [], stream: true } });
      await client.complete({ body: { prompt: "p", stream: true }, route: "completions" });
    }
    expect(seen.map(item => item.url)).toEqual([
      "http://engine/v1/chat/completions", "http://engine/v1/completions",
      "http://engine/v1/chat/completions", "http://engine/v1/completions",
    ]);
    for (const item of seen) {
      expect(item.method).toBe("POST");
      expect(item.headers).toMatchObject({ authorization: "Bearer local", "content-type": "application/json" });
    }
    expect(seen[0]!.body).toEqual({ messages: [], stream: false });
    expect(seen[1]!.body).toEqual({ prompt: "p", stream: false });
    expect(headers).toEqual({ authorization: "Bearer local", "content-type": "text/plain" });
  } finally { await host.close(); }
});

test("a supplied host is the transport, called as a method; otherwise the global fetch is", async () => {
  class Host {
    calls = 0;
    async forward(request: Request): Promise<Response> {
      this.calls++;
      return Response.json({ choices: [{ text: new URL(request.url).pathname }] });
    }
  }
  const host = new Host();
  const client: CompletionClient<CompletionCall, CompletionResponse> =
    createCompletionClient({ baseUrl: "http://unreachable.invalid/v1", host });
  expect(await client.complete({ body: {}, route: "completions" })).toEqual({ choices: [{ text: "/v1/completions" }] });
  expect(host.calls).toBe(1);

  const received: { path: string; body: unknown }[] = [];
  const server = Bun.serve({ port: 0, hostname: "127.0.0.1", async fetch(request) {
    received.push({ path: new URL(request.url).pathname, body: await request.json() });
    return Response.json({ choices: [{ message: { content: "over http" } }], usage: { total_tokens: 3 } });
  } });
  try {
    const http = createCompletionClient({ baseUrl: `http://127.0.0.1:${server.port}/v1/` });
    expect(await http.complete({ body: { messages: [{ role: "user", content: "hi" }] } }))
      .toEqual({ choices: [{ message: { content: "over http" } }], usage: { total_tokens: 3 } });
    expect(received).toEqual([{ path: "/v1/chat/completions", body: { messages: [{ role: "user", content: "hi" }], stream: false } }]);
  } finally { await server.stop(true); }
});

test("completion client uses the supplied transport and never retries a POST", async () => {
  let requests = 0;
  const host = createDirectHost(async (request) => {
    requests++;
    expect(request.method).toBe("POST");
    expect(await request.json()).toEqual({ prompt: "hello", stream: false });
    return new Response("engine overloaded", { status: 503 });
  });
  try {
    const client = createCompletionClient({ baseUrl: "http://local/v1", host });
    await expect(client.complete({ body: { prompt: "hello" }, route: "completions" }))
      .rejects.toThrow("completion failed (503): engine overloaded");
    expect(requests).toBe(1);
  } finally { await host.close(); }

  let attempts = 0;
  const failing = createCompletionClient({ baseUrl: "http://local/v1",
    host: { forward: async () => { attempts++; throw new Error("socket closed"); } } });
  await expect(failing.complete({ body: {} })).rejects.toThrow("socket closed");
  expect(attempts).toBe(1);
});

test("a response without a choices array rejects", async () => {
  for (const body of [{ object: "chat.completion" }, { choices: { text: "not a list" } }]) {
    const host = createDirectHost(async () => Response.json(body));
    try {
      await expect(createCompletionClient({ baseUrl: "http://local/v1", host }).complete({ body: {} }))
        .rejects.toThrow("completion response has no choices");
    } finally { await host.close(); }
  }
});

test("cancellation rejects before sending when already aborted and reaches the handler in flight", async () => {
  let requests = 0;
  const idle = createCompletionClient({ baseUrl: "http://local/v1",
    host: { forward: async () => { requests++; return Response.json({ choices: [] }); } } });
  const early = new AbortController();
  early.abort(new Error("caller left early"));
  await expect(idle.complete({ body: {}, signal: early.signal })).rejects.toThrow("caller left early");
  expect(requests).toBe(0);

  const entered = Promise.withResolvers<Request>();
  const host = createDirectHost(request => new Promise<Response>((_, reject) => {
    entered.resolve(request);
    request.signal.addEventListener("abort", () => reject(request.signal.reason), { once: true });
  }));
  try {
    const abort = new AbortController();
    const reason = new Error("caller left");
    const work = createCompletionClient({ baseUrl: "http://local/v1", host }).complete({ body: {}, signal: abort.signal });
    const request = await entered.promise;
    expect(request.signal.aborted).toBe(false);
    abort.abort(reason);
    await expect(work).rejects.toBe(reason);
    expect(request.signal.aborted).toBe(true);
    expect(request.signal.reason).toBe(reason);
  } finally { await host.close(); }
});

test("direct host waits for active handlers and closes once", async () => {
  let finish!: () => void;
  let closed = 0;
  const gate = new Promise<void>((resolve) => { finish = resolve; });
  const host = createDirectHost(async () => { await gate; return Response.json({ choices: [] }); }, async () => { closed++; });
  const client = createCompletionClient({ baseUrl: "http://local/v1", host });
  const work = client.complete({ body: { prompt: "a" } });
  const closing = host.close();
  expect(host.close()).toBe(closing);
  await Bun.sleep(5);
  expect(closed).toBe(0);
  finish();
  expect((await work).choices).toEqual([]);
  await closing;
  await host.close();
  expect(closed).toBe(1);
  await expect(client.complete({ body: {} })).rejects.toThrow("closed");
  await expect(host.forward(new Request("http://local/health"))).rejects.toThrow("engine host is closed");
});

test("direct host serves the same completion contract an isolated host would", async () => {
  const direct = createDirectHost(async (request) => {
    const body = await request.json() as { prompt: string };
    return Response.json({ choices: [{ text: body.prompt }] });
  });
  try {
    await direct.ready;
    const client = createCompletionClient({ baseUrl: "http://engine/v1", host: direct });
    expect(await client.complete({ route: "completions", body: { prompt: "same request" } }))
      .toEqual({ choices: [{ text: "same request" }] });
  } finally { await direct.close(); }
});

test("direct host runs handlers on a microtask, refuses aborted requests, and propagates handler failures", async () => {
  let calls = 0;
  const host = createDirectHost((request: Request): Promise<Response> => {
    calls++;
    if (new URL(request.url).pathname === "/sync") throw new Error("thrown synchronously");
    return Promise.reject(new Error("handler failed"));
  });
  try {
    const pending = host.forward(new Request("http://local/async"));
    expect(calls).toBe(0);
    await expect(pending).rejects.toThrow("handler failed");
    await expect(host.forward(new Request("http://local/sync"))).rejects.toThrow("thrown synchronously");
    expect(calls).toBe(2);
    const abort = new AbortController();
    const reason = new Error("already gone");
    abort.abort(reason);
    await expect(host.forward(new Request("http://local/async", { signal: abort.signal }))).rejects.toBe(reason);
    expect(calls).toBe(2);
  } finally { await host.close(); }

  let shutdowns = 0;
  const failed = createDirectHost(async () => { throw new Error("late failure"); }, async () => { shutdowns++; });
  const work = failed.forward(new Request("http://local/"));
  const closing = failed.close();
  await expect(work).rejects.toThrow("late failure");
  await closing;
  expect(shutdowns).toBe(1);
});

test("a streaming response passes through untouched and stays readable after forward and close", async () => {
  const release = Promise.withResolvers<void>();
  const encoder = new TextEncoder();
  const stream = new ReadableStream<Uint8Array<ArrayBuffer>>({
    async start(controller) {
      controller.enqueue(encoder.encode("data: one\n\n"));
      await release.promise;
      controller.enqueue(encoder.encode("data: two\n\n"));
      controller.close();
    },
  });
  const original = new Response(stream, { headers: { "content-type": "text/event-stream" } });
  let shutdowns = 0;
  const host = createDirectHost(async () => original, async () => { shutdowns++; });
  const response = await host.forward(new Request("http://local/v1/chat/completions", { method: "POST", body: "{}" }));
  expect(response).toBe(original);
  expect(response.body).toBe(stream);
  expect(response.headers.get("content-type")).toBe("text/event-stream");
  await host.close();
  expect(shutdowns).toBe(1);
  const reader = response.body!.getReader(), decoder = new TextDecoder();
  expect(decoder.decode((await reader.read()).value)).toBe("data: one\n\n");
  release.resolve();
  expect(decoder.decode((await reader.read()).value)).toBe("data: two\n\n");
  expect((await reader.read()).done).toBe(true);
});
