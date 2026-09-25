import { afterEach, describe, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { configureRuntime } from "@mlx-bun/inference/runtime/config";
import { createLoopbackMemoryClient } from "../../src/server/memory-completion-client";
import { memoryMessages } from "../../src/memory/model";
import { CHUNK_SYSTEM, chunkInput } from "../../src/memory/chunk";

// The loopback client is the only implementation of the memory domain's
// completion seam: every stage call is one POST to the serving mlx-bun's own
// /v1/chat/completions, greedy, with main's adapter policy (memory-chunk for the
// chunk stage when present, base otherwise). Fake fetch; no server, no model.

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
      temperature: 0, stream: false, adapter: "none",
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
    const directory = join(home, ".cache", "mlx-bun", "adapters", "memory-chunk");
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
    mkdirSync(join(home, ".cache", "mlx-bun", "adapters", "memory-chunk"), { recursive: true });
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
    mkdirSync(join(home, ".cache", "mlx-bun", "adapters", "memory-chunk"), { recursive: true });
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
