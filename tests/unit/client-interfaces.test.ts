import { expect, test } from "bun:test";
import { createCompletionClient, createDirectHost } from "../../src/client";
import { createMemoryCalls } from "../../src/memory/model";

test("CPU entry points import with an unusable native library path", async () => {
  const process = Bun.spawn([Bun.which("bun")!, "-e",
    'await import("mlx-bun/engine"); await import("mlx-bun/client"); await import("./src/memory/model.ts"); await import("./src/serve/isolate.ts");'], {
    cwd: new URL("../..", import.meta.url).pathname,
    env: { ...globalThis.process.env, MLX_BUN_LIBMLXC: "/nonexistent/mlx-client-import-test.dylib" },
    stdout: "pipe", stderr: "pipe",
  });
  const stderr = await new Response(process.stderr).text();
  expect({ code: await process.exited, stderr }).toEqual({ code: 0, stderr: "" });
});

test("completion client uses the supplied transport and never retries a POST", async () => {
  let requests = 0;
  const host = createDirectHost(async (request) => {
    requests++;
    expect(request.method).toBe("POST");
    expect(await request.json()).toEqual({ prompt: "hello", stream: false });
    return Response.json({ error: "failed" }, { status: 503 });
  });
  try {
    const client = createCompletionClient({ baseUrl: "http://local/v1", host });
    await expect(client.complete({ body: { prompt: "hello" }, route: "completions" })).rejects.toThrow("503");
    expect(requests).toBe(1);
  } finally { await host.close(); }
});

test("memory callers replace their client without importing a model or changing request semantics", async () => {
  const calls: unknown[] = [];
  const caller = createMemoryCalls({
    async complete(request) { calls.push(request); return request.input.user; },
    async completeBatch(requests) { calls.push(requests); return requests.map((request) => request.input.user); },
  });
  expect(await caller.callLocal("chunk", { system: "rules", user: "a" })).toBe("a");
  expect(await caller.callLocalBatch("entity", [{ user: "b" }, { user: "c" }], { maxTokens: 5 })).toEqual(["b", "c"]);
  expect(calls).toEqual([
    { stage: "chunk", input: { system: "rules", user: "a" }, maxTokens: 256 },
    [{ stage: "entity", input: { user: "b" }, maxTokens: 5 }, { stage: "entity", input: { user: "c" }, maxTokens: 5 }],
  ]);
});

test("direct host waits for active handlers and closes once", async () => {
  let finish!: () => void;
  let closed = 0;
  const gate = new Promise<void>((resolve) => { finish = resolve; });
  const host = createDirectHost(async () => { await gate; return Response.json({ choices: [] }); }, async () => { closed++; });
  const client = createCompletionClient({ baseUrl: "http://local/v1", host });
  const work = client.complete({ body: { prompt: "a" } });
  const closing = host.close();
  expect(closed).toBe(0);
  finish();
  expect((await work).choices).toEqual([]);
  await closing;
  await host.close();
  expect(closed).toBe(1);
  await expect(client.complete({ body: {} })).rejects.toThrow("closed");
});

test("task clients preserve progress and artifact results and cancel at progress boundaries", async () => {
  const { createJobTaskClient } = await import("../../src/jobs/task-client");
  const { CancellationSource } = await import("../../src/engine/cancellation");
  const events: string[] = [];
  let finished = 0;
  const client = createJobTaskClient(async (emit, config) => {
    emit({ type: "stage", stage: "prepare" });
    emit({ type: "stage", stage: "write" });
    finished++;
    return { outputPath: String(config.output) };
  });
  expect(await client.run({ output: "/artifact" }, (event) => events.push(event.type)))
    .toEqual({ outputPath: "/artifact" });
  expect(events).toEqual(["stage", "stage"]);
  const cancellation = new CancellationSource();
  await expect(client.run({}, () => cancellation.cancel("requested"), cancellation)).rejects.toThrow("cancelled");
  expect(finished).toBe(1);
  await expect(client.run({}, () => { throw new Error("must not report"); }, cancellation)).rejects.toThrow("cancelled");
});
