import { afterEach, describe, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { configureRuntime } from "@mlx-bun/inference/runtime/config";
import { createLoopbackMemoryClient } from "@mlx-bun/module-memory/completion-client";
import { createWorkerMemoryClient, type MemoryTarget } from "../../src/server/memory-completion-client";
import { memoryMessages } from "@mlx-bun/module-memory/model";
import { CHUNK_SYSTEM, chunkInput } from "@mlx-bun/module-memory/chunk";

// The HTTP implementations of the memory domain's completion seam. The loopback
// client posts every stage call to the serving mlx-bun's own
// /v1/chat/completions, greedy, with main's adapter policy (memory-chunk for the
// chunk stage when present, base otherwise); the --isolate parent's worker
// client posts each call or batch to the default model worker's private route.
// Fake fetch; no server, no model.

interface Seen { method: string; path: string; body: any; headers: Record<string, string> }
const fetcher = (fn: (input: string | URL | Request, init?: RequestInit) => Promise<Response>) => fn as typeof fetch;
function fakeServer(reply: (seen: Seen) => Response | Promise<Response> = () => completion("ok")) {
  const seen: Seen[] = [];
  const fetch = fetcher(async (input, init) => {
    const url = new URL(String(input));
    const headers = Object.fromEntries(Object.entries((init?.headers ?? {}) as Record<string, string>));
    const entry: Seen = { method: init?.method ?? "GET", path: url.pathname, body: init?.body ? JSON.parse(String(init.body)) : undefined, headers };
    seen.push(entry);
    return reply(entry);
  });
  return { seen, fetch };
}
const completion = (content: string | null) => Response.json({ choices: [{ message: { role: "assistant", content } }] });
const base = () => "http://127.0.0.1:8080/";

let restoreHome: (() => void) | undefined, restoreRuntime: (() => void) | undefined;
afterEach(() => { restoreHome?.(); restoreHome = undefined; restoreRuntime?.(); restoreRuntime = undefined; });
function temporaryHome(): string {
  const previous = process.env.HOME;
  const home = mkdtempSync(join(tmpdir(), "mlx-memory-client-home-"));
  process.env.HOME = home;
  restoreHome = () => { process.env.HOME = previous; rmSync(home, { recursive: true, force: true }); };
  return home;
}

describe("loopback memory completion client", () => {
  test("a base-stage call posts the stage's rendered messages greedily with adapter none", async () => {
    temporaryHome();
    const { seen, fetch } = fakeServer(() => completion("Panasonic Lumix S5IIX\nL-Mount"));
    const client = createLoopbackMemoryClient(base, { fetch });
    const out = await client.complete({ stage: "entity", input: { user: "chunk body" }, maxTokens: 64_000 });
    expect(out).toBe("Panasonic Lumix S5IIX\nL-Mount");
    expect(seen).toHaveLength(1);
    expect(seen[0]!.method).toBe("POST");
    expect(seen[0]!.path).toBe("/v1/chat/completions");
    expect(seen[0]!.headers.Authorization).toBe("Bearer sk-mlx-bun-local");
    expect(seen[0]!.body).toEqual({
      model: "local", messages: memoryMessages("entity", { user: "chunk body" }), max_tokens: 64_000,
      temperature: 0, top_p: 0, top_k: 0, min_p: 0,
      repetition_penalty: 1, presence_penalty: 0, frequency_penalty: 0, logit_bias: {},
      xtc_probability: 0, xtc_threshold: 0, hlg: { enabled: false },
      chat_template_kwargs: { enable_thinking: null }, stream: false, adapter: "none",
    });
    expect(seen[0]!.body.messages[0]).toEqual({ role: "system", content: expect.stringContaining("entity extractor") });
    expect(seen[0]!.body.messages[1]).toEqual({ role: "user", content: "chunk body" });
  });

  test("a null assistant content degrades to an empty string", async () => {
    temporaryHome();
    const { fetch } = fakeServer(() => completion(null));
    const client = createLoopbackMemoryClient(base, { fetch });
    expect(await client.complete({ stage: "route", input: { user: "same thing?" }, maxTokens: 8 })).toBe("");
  });

  test("the chunk stage runs base when no memory-chunk adapter directory exists", async () => {
    temporaryHome();
    const { seen, fetch } = fakeServer();
    const client = createLoopbackMemoryClient(base, { fetch });
    await client.complete({ stage: "chunk", input: chunkInput("transcript"), maxTokens: 64_000 });
    expect(seen.map((s) => `${s.method} ${s.path}`)).toEqual(["POST /v1/chat/completions"]);
    expect(seen[0]!.body.adapter).toBe("none");
    expect(seen[0]!.body.messages).toEqual([{ role: "system", content: CHUNK_SYSTEM }, { role: "user", content: "transcript" }]);
  });

  test("the chunk stage mounts memory-chunk once through /v1/adapters and selects it per call", async () => {
    const home = temporaryHome();
    const directory = join(home, ".mlx-bun", "adapters", "memory-chunk");
    mkdirSync(directory, { recursive: true });
    const { seen, fetch } = fakeServer((s) => {
      if (s.path === "/v1/adapters" && s.method === "GET") return Response.json({ adapters: [] });
      if (s.path === "/v1/adapters") return Response.json({ id: s.body.id, mounted_layers: 3 });
      return completion('{"chunks": []}');
    });
    const client = createLoopbackMemoryClient(base, { fetch });
    await client.complete({ stage: "chunk", input: chunkInput("one"), maxTokens: 64_000 });
    await client.complete({ stage: "chunk", input: chunkInput("two"), maxTokens: 64_000 });
    await client.complete({ stage: "entity", input: { user: "base stage between" }, maxTokens: 64_000 });
    expect(seen.map((s) => `${s.method} ${s.path}`)).toEqual([
      "GET /v1/adapters", "POST /v1/adapters", "POST /v1/chat/completions", "POST /v1/chat/completions", "POST /v1/chat/completions",
    ]);
    expect(seen[1]!.body).toEqual({ id: "memory-chunk", path: directory });
    expect(seen.slice(2).map((s) => s.body.adapter)).toEqual(["memory-chunk", "memory-chunk", "none"]);
  });

  test("an already-mounted memory-chunk adapter is reused without a second mount", async () => {
    const home = temporaryHome();
    mkdirSync(join(home, ".mlx-bun", "adapters", "memory-chunk"), { recursive: true });
    const { seen, fetch } = fakeServer((s) => s.path === "/v1/adapters"
      ? Response.json({ adapters: [{ id: "memory-chunk" }] }) : completion("x"));
    const client = createLoopbackMemoryClient(base, { fetch });
    await client.complete({ stage: "chunk", input: chunkInput("one"), maxTokens: 8 });
    expect(seen.map((s) => `${s.method} ${s.path}`)).toEqual(["GET /v1/adapters", "POST /v1/chat/completions"]);
    expect(seen[1]!.body.adapter).toBe("memory-chunk");
  });

  test("completeBatch preserves order and runs one call at a time by default", async () => {
    temporaryHome();
    let inFlight = 0, peak = 0;
    const { seen, fetch } = fakeServer(async (s) => {
      inFlight++; peak = Math.max(peak, inFlight);
      await new Promise((resolve) => setTimeout(resolve, 5));
      inFlight--;
      return completion(`out:${s.body.messages.at(-1).content}`);
    });
    const client = createLoopbackMemoryClient(base, { fetch });
    const inputs = ["a", "b", "c", "d"].map((user) => ({ stage: "entity", input: { user }, maxTokens: 8 }));
    expect(await client.completeBatch(inputs)).toEqual(["out:a", "out:b", "out:c", "out:d"]);
    expect(peak).toBe(1);
    expect(seen.map((s) => s.body.messages.at(-1).content)).toEqual(["a", "b", "c", "d"]);
    expect(await client.completeBatch([])).toEqual([]);
  });

  test("MLX_BUN_MEMORY_BATCH widens the in-flight bound while keeping order", async () => {
    temporaryHome();
    restoreRuntime = configureRuntime({ MLX_BUN_MEMORY_BATCH: "3" });
    let inFlight = 0, peak = 0;
    const { fetch } = fakeServer(async (s) => {
      inFlight++; peak = Math.max(peak, inFlight);
      await new Promise((resolve) => setTimeout(resolve, 10));
      inFlight--;
      return completion(`out:${s.body.messages.at(-1).content}`);
    });
    const client = createLoopbackMemoryClient(base, { fetch });
    const inputs = ["a", "b", "c", "d", "e"].map((user) => ({ stage: "entity", input: { user }, maxTokens: 8 }));
    expect(await client.completeBatch(inputs)).toEqual(["out:a", "out:b", "out:c", "out:d", "out:e"]);
    expect(peak).toBe(3);
  });

  test("an unreachable server and a rejected request both fail with actionable errors", async () => {
    temporaryHome();
    const down = createLoopbackMemoryClient(base, { fetch: fetcher(async () => { throw new Error("ECONNREFUSED"); }) });
    await expect(down.complete({ stage: "entity", input: { user: "x" }, maxTokens: 8 })).rejects.toThrow(/no mlx-bun server answered at http:\/\/127\.0\.0\.1:8080 \(ECONNREFUSED\).*mlx-bun serve/);
    const rejecting = createLoopbackMemoryClient(base, { fetch: fetcher(async () => new Response("model busy", { status: 503 })) });
    await expect(rejecting.complete({ stage: "entity", input: { user: "x" }, maxTokens: 8 })).rejects.toThrow("memory: POST /v1/chat/completions 503: model busy");
    const abort = new AbortController();
    abort.abort(new Error("stopped"));
    const aborted = createLoopbackMemoryClient(base, { signal: abort.signal, fetch: fetcher(async () => completion("never")) });
    await expect(aborted.complete({ stage: "entity", input: { user: "x" }, maxTokens: 8 })).rejects.toThrow("stopped");
  });

  test("a failed adapter mount is retried on the next chunk call", async () => {
    const home = temporaryHome();
    mkdirSync(join(home, ".mlx-bun", "adapters", "memory-chunk"), { recursive: true });
    let mounts = 0;
    const { seen, fetch } = fakeServer((s) => {
      if (s.path === "/v1/adapters" && s.method === "GET") return Response.json({ adapters: [] });
      if (s.path === "/v1/adapters") return ++mounts === 1 ? new Response("busy", { status: 503 }) : Response.json({ id: "memory-chunk" });
      return completion("x");
    });
    const client = createLoopbackMemoryClient(base, { fetch });
    await expect(client.complete({ stage: "chunk", input: chunkInput("one"), maxTokens: 8 })).rejects.toThrow("503");
    await client.complete({ stage: "chunk", input: chunkInput("two"), maxTokens: 8 });
    expect(seen.filter((s) => s.path === "/v1/adapters" && s.method === "POST")).toHaveLength(2);
    expect(seen.at(-1)!.body.adapter).toBe("memory-chunk");
  });
});


test("a failed batch stops admission, aborts siblings, and joins them before rejecting the original error", async () => {
  temporaryHome();
  restoreRuntime = configureRuntime({ MLX_BUN_MEMORY_BATCH: "2" });
  const started: string[] = [];
  const bothStarted = Promise.withResolvers<void>();
  const release = Promise.withResolvers<void>();
  const sawAbort = Promise.withResolvers<void>();
  let settled = false;
  const client = createLoopbackMemoryClient(base, { fetch: fetcher(async (_url, init) => {
    const name = JSON.parse(String(init!.body)).messages.at(-1).content;
    started.push(name);
    if (started.length === 2) bothStarted.resolve();
    if (name === "first") {
      await bothStarted.promise;
      return new Response("original failure", { status: 500 });
    }
    init!.signal!.addEventListener("abort", () => sawAbort.resolve(), { once: true });
    await release.promise; // Simulates a transport that needs cleanup after abort.
    throw new Error("sibling cleanup failure");
  }) });
  const result = client.completeBatch(["first", "second", "third", "fourth"].map(user => ({ stage: "entity", input: { user }, maxTokens: 8 })))
    .then(value => { settled = true; return value; }, error => { settled = true; return error; });
  try {
    await sawAbort.promise;
    expect(started).toEqual(["first", "second"]);
    expect(settled).toBe(false);
  } finally { release.resolve(); }
  expect(String(await result)).toContain("500: original failure");
  expect(started).toEqual(["first", "second"]);
});

describe("worker memory completion client", () => {
  const rows = (users: string[]) => users.map(user => ({ stage: "entity", input: { user }, maxTokens: 8 }));
  function fakeWorker(reply: (body: { call: string; requests: { input: { user: string } }[] }, init: RequestInit) => Response | Promise<Response> =
    body => Response.json({ outputs: body.requests.map(row => `task ${row.input.user}`) })) {
    const seen: { url: string; method?: string; body: unknown; headers: unknown; signal?: AbortSignal | null }[] = [];
    let selected = 0;
    const worker: MemoryTarget["worker"] = { async fetch(url: string, init: RequestInit = {}) {
      seen.push({ url, method: init.method, body: JSON.parse(String(init.body)), headers: init.headers, signal: init.signal });
      return reply(JSON.parse(String(init.body)), init);
    } };
    // Each selection picks the snapshot anew; the call carries the one selected for it.
    return { seen, get selected() { return selected; },
      select: async (signal: AbortSignal): Promise<MemoryTarget> => { selected++; signal.throwIfAborted(); return { worker, snapshot: `/hub/snapshots/rev${selected}` }; } };
  }

  test("each call or batch is one POST of the rows and the snapshot selected for it to the selected worker's private route, answered with its ordered raw outputs", async () => {
    const fake = fakeWorker();
    const client = createWorkerMemoryClient(fake.select, new AbortController().signal);
    expect(await client.completeBatch(rows(["a", "b", "c"]))).toEqual(["task a", "task b", "task c"]);
    expect(await client.complete({ stage: "route", input: { system: "yes or no", user: "d" }, maxTokens: 4 })).toBe("task d");
    // An empty batch is answered without a call, as the task model answers it.
    expect(await client.completeBatch([])).toEqual([]);
    expect(fake.selected).toBe(2);
    expect(fake.seen.map(({ url, method, body, headers }) => ({ url, method, body, headers }))).toEqual([
      { url: "http://engine/admin/memory/complete", method: "POST", headers: { "content-type": "application/json" },
        body: { call: "completeBatch", snapshot: "/hub/snapshots/rev1", requests: rows(["a", "b", "c"]) } },
      { url: "http://engine/admin/memory/complete", method: "POST", headers: { "content-type": "application/json" },
        body: { call: "complete", snapshot: "/hub/snapshots/rev2", requests: [{ stage: "route", input: { system: "yes or no", user: "d" }, maxTokens: 4 }] } },
    ]);
  });

  test("a failed call carries the worker's message; a stopped worker fails the call once, never retried; a failed selection fails it as it is; malformed outputs are refused", async () => {
    const failing = fakeWorker(() => Response.json({ error: { message: "row failed", type: "memory_failed" } }, { status: 500 }));
    await expect(createWorkerMemoryClient(failing.select, new AbortController().signal).completeBatch(rows(["a"])))
      .rejects.toThrow("memory: the model worker's task model completeBatch failed (500): row failed");
    const draining = fakeWorker(() => new Response("worker is draining", { status: 503 }));
    await expect(createWorkerMemoryClient(draining.select, new AbortController().signal).complete(rows(["a"])[0]!))
      .rejects.toThrow("memory: the model worker's task model complete failed (503): worker is draining");
    const died = fakeWorker(() => { throw new Error("The socket connection was closed unexpectedly"); });
    await expect(createWorkerMemoryClient(died.select, new AbortController().signal).completeBatch(rows(["a", "b"])))
      .rejects.toThrow("memory: the model worker did not complete the task model completeBatch (The socket connection was closed unexpectedly); it is not retried");
    expect([died.selected, died.seen.length]).toEqual([1, 1]);
    const missing = new Error("memory: Gemma-4-e4b is not downloaded");
    const unselected = createWorkerMemoryClient(async () => { throw missing; }, new AbortController().signal);
    await expect(unselected.complete(rows(["a"])[0]!)).rejects.toBe(missing);
    for (const outputs of [undefined, ["only one"], ["a", 2]]) {
      const odd = fakeWorker(() => Response.json({ outputs }));
      await expect(createWorkerMemoryClient(odd.select, new AbortController().signal).completeBatch(rows(["a", "b"])))
        .rejects.toThrow("memory: the model worker's task model completeBatch answered no ordered outputs");
    }
  });

  test("the run's signal aborts the request in flight and starts nothing once aborted", async () => {
    const run = new AbortController();
    const reached = Promise.withResolvers<void>();
    const fake = fakeWorker((_body, init) => new Promise<Response>((_resolve, reject) => {
      init.signal!.addEventListener("abort", () => reject(init.signal!.reason), { once: true });
      reached.resolve();
    }));
    const client = createWorkerMemoryClient(fake.select, run.signal);
    const pending = client.completeBatch(rows(["a", "b"]));
    await reached.promise;
    run.abort(new Error("run cancelled"));
    await expect(pending).rejects.toThrow("run cancelled");
    expect(fake.seen[0]!.signal).toBe(run.signal);
    await expect(client.complete(rows(["c"])[0]!)).rejects.toThrow("run cancelled");
    expect([fake.selected, fake.seen.length]).toEqual([1, 1]);
  });
});
