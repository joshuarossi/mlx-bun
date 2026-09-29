// Opt-in with real weights: `--paged-kv` on a cached Gemma4 snapshot named by
// MLX_BUN_COMPILED_GEMMA_E4B serves completions through the paged path, and
// on a non-Gemma4 model (MLX_BUN_APP_TEST_MODEL) the request answers the
// typed capability error instead of a hidden serial fallback.
//
// HTTP cancellation, once per paged reader (the gathered SDPA reader and the
// direct reader MLX_BUN_PAGED_ATTN=1 selects, which the app reads from its
// runtime snapshot): a greedy /v1/completions stream is abandoned by its
// client mid-generation; the server observes the disconnect and drains; the
// same server then answers a different prompt and the abandoned prompt
// exactly as a fresh paged server with the same reader does, and the frames
// the client received equal a control stopped (max_tokens) at the token that
// published the last of them. Every paged cache touched in the case must use
// the selected reader. Both servers run without the RAM prompt cache, so
// every compared request prefills cold. References are produced at run time;
// nothing is committed.
import { expect, spyOn, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { AppSocketHooks, RunningApp } from "../../src/cli/serve";

const gemma = process.env.MLX_BUN_COMPILED_GEMMA_E4B;
const other = process.env.MLX_BUN_APP_TEST_MODEL;

async function serveWithPaging(root: string, snapshot: string,
  { blockSize = "256", promptCacheGiB = "0.125", hooks = {} }: { blockSize?: string; promptCacheGiB?: string; hooks?: AppSocketHooks } = {}) {
  const { startModelServer, parseServeOptions } = await import("../../src/cli/serve");
  const { scanSnapshot } = await import("@mlx-bun/hub/registry");
  const model = await scanSnapshot(snapshot, "test-model");
  if (!model) throw new Error(`${snapshot} has no loadable checkpoint`);
  const options = parseServeOptions({ values: { port: "0", "max-tokens": "16", "prompt-cache": promptCacheGiB, "no-open": true, thinking: "off",
    "paged-kv": true, "paged-kv-block-size": blockSize }, positionals: [] });
  options.readOnly = true;
  options.chatPaths = { cwd: join(root, "project"), agentDir: join(root, "agent"), sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
  options.memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
  options.storagePaths = { jobsDb: join(root, "jobs.sqlite"), jobsLogs: join(root, "jobs"), credentialsFile: join(root, "hf.json"), artifactRoot: join(root, "artifacts") };
  return startModelServer(model, options, hooks);
}
const chat = (app: RunningApp) => fetch(new URL("/v1/chat/completions", `http://127.0.0.1:${app.port}`), { method: "POST",
  headers: { "content-type": "application/json" }, body: JSON.stringify({ messages: [{ role: "user", content: "Say hello." }], max_tokens: 16, temperature: 0 }) });

test.skipIf(!gemma)("paged KV serves a Gemma4 completion", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-paged-")); mkdirSync(join(root, "project"));
  let app: RunningApp | undefined;
  try {
    app = await serveWithPaging(root, gemma!);
    const response = await chat(app);
    expect(response.status).toBe(200);
    const body = await response.json();
    expect(body.usage.completion_tokens).toBeGreaterThan(0);
  } finally { try { await app?.close(); } finally { rmSync(root, { recursive: true, force: true }); } }
}, 300_000);

test.skipIf(!other)("paged KV on a non-Gemma4 model answers the typed capability error", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-paged-")); mkdirSync(join(root, "project"));
  let app: RunningApp | undefined;
  try {
    app = await serveWithPaging(root, other!);
    const response = await chat(app);
    expect(response.status).toBe(501);
    const body = await response.json();
    expect(body.error).toMatchObject({ type: "not_implemented", code: "unsupported_execution" });
    expect(body.error.reasons).toContain("paged-kv-batch-unsupported");
  } finally { try { await app?.close(); } finally { rmSync(root, { recursive: true, force: true }); } }
}, 300_000);

// A raw completion (no chat template): the text-completion router streams one
// frame per token whose decoded delta is non-empty, which the stopped control
// below relies on and verifies against the uninterrupted control.
const STORY = "The following is a long, detailed story about a lighthouse keeper named Elias, who lives alone on a rocky island.\n\nChapter One\n\n";
const OTHER = "A short explanation of why the sky looks blue during the day:";
/** Content frames a client must have received before it leaves. */
const LEAVE_AFTER = 4;
/** Small blocks, so rows span several; no RAM prompt cache, so every compared
 * request prefills cold. A prefix restored from the cache prefills only its
 * suffix, through a different attention shape (with the direct reader, a
 * different kernel), which this case does not claim is bit-identical. */
const cold = { blockSize: "16", promptCacheGiB: "0" };

type Terminal = { finish: string; promptTokens: number; completionTokens: number };
type Stream = { frames: string[] } & Terminal;
type Received = { frames: string[]; terminal?: Terminal };
const completions = (base: URL, body: Record<string, unknown>, signal?: AbortSignal) => fetch(new URL("/v1/completions", base), {
  method: "POST", signal, headers: { "content-type": "application/json" }, body: JSON.stringify({ temperature: 0, ...body }) });

/** Parse complete SSE frames from `buffer`; returns the unparsed remainder. */
function parseFrames(buffer: string, stream: Received): string {
  for (let boundary = buffer.indexOf("\n\n"); boundary >= 0; boundary = buffer.indexOf("\n\n")) {
    const frame = buffer.slice(0, boundary); buffer = buffer.slice(boundary + 2);
    if (!frame.startsWith("data: ") || frame === "data: [DONE]") continue;
    const chunk = JSON.parse(frame.slice(6));
    if (chunk.error) throw new Error(`stream error: ${JSON.stringify(chunk.error)}`);
    const choice = chunk.choices[0];
    if (choice.finish_reason) stream.terminal = { finish: choice.finish_reason,
      promptTokens: chunk.usage.prompt_tokens, completionTokens: chunk.usage.completion_tokens };
    else stream.frames.push(choice.text);
  }
  return buffer;
}

async function streamed(base: URL, body: Record<string, unknown>): Promise<Stream> {
  const response = await completions(base, { ...body, stream: true });
  expect(response.status).toBe(200);
  const stream: Received = { frames: [] };
  const rest = parseFrames(await response.text(), stream);
  if (!stream.terminal || rest.trim()) throw new Error(`stream ended without its terminal frame: ${JSON.stringify(rest)}`);
  return { frames: stream.frames, ...stream.terminal };
}

async function whole(base: URL, body: Record<string, unknown>) {
  const response = await completions(base, body);
  const payload = await response.json();
  expect(response.status, JSON.stringify(payload)).toBe(200);
  return payload;
}

async function until(label: string, check: () => Promise<boolean> | boolean) {
  const deadline = Date.now() + 60_000;
  while (!(await check())) {
    if (Date.now() > deadline) throw new Error(`timed out waiting for ${label}`);
    await Bun.sleep(50);
  }
}

for (const direct of [false, true]) {
  const reader = direct ? "direct" : "gathered";
  test.skipIf(!gemma)(`paged KV (${reader} reader): a client that leaves mid-stream is cancelled and drained, its received frames equal a stopped control, and the server then answers exactly as a fresh paged server`, async () => {
    const { configureRuntime } = await import("@mlx-bun/inference/runtime/config");
    const { PagedKVCache } = await import("@mlx-bun/inference/state/paged");
    const { loadTokenizer } = await import("@mlx-bun/inference/input");
    const { ToolAwareStream } = await import("../../src/server/token-streams");
    const root = mkdtempSync(join(tmpdir(), "mlx-paged-cancel-")); mkdirSync(join(root, "project"));
    // Every paged cache that stores or reads KV in this case reports its reader;
    // while the abandoned row is the only one, the tokens it stored are tracked.
    const readers: boolean[] = [];
    let abandoning = false, abandonedOffset = 0;
    const spies = (["appendAndFetch", "updateAndFetch"] as const).map(method => {
      const original = PagedKVCache.prototype[method] as (this: InstanceType<typeof PagedKVCache>, ...args: unknown[]) => unknown;
      return spyOn(PagedKVCache.prototype, method).mockImplementation(function (this: InstanceType<typeof PagedKVCache>, ...args: unknown[]) {
        readers.push(this.direct);
        const result = original.apply(this, args);
        if (abandoning) abandonedOffset = Math.max(abandonedOffset, this.offset);
        return result;
      } as never);
    });
    // The app's runtime snapshot is read when the gateway binds; keep it for the servers' lifetime.
    const restoreRuntime = configureRuntime({ MLX_BUN_PAGED_ATTN: direct ? "1" : "0" });
    let app: RunningApp | undefined;
    try {
      // 1. A fresh paged server whose first request is abandoned by its client.
      const served: { aborted: boolean }[] = [];
      app = await serveWithPaging(root, gemma!, { ...cold, hooks: { routes: group => ({ async handle(request) {
        if (request.method === "POST" && new URL(request.url).pathname === "/v1/completions") {
          const entry = { aborted: false };
          served.push(entry);
          request.signal.addEventListener("abort", () => { entry.aborted = true; }, { once: true });
        }
        return group.handle(request);
      } }) } });
      let base = new URL(`http://127.0.0.1:${app.port}`);
      const leave = new AbortController();
      abandoning = true;
      const response = await completions(base, { prompt: STORY, max_tokens: 256, stream: true }, leave.signal);
      expect(response.status).toBe(200);
      const leaving = served.at(-1)!;
      const received: Received = { frames: [] };
      const body = response.body!.getReader(), decoder = new TextDecoder();
      let buffer = "";
      while (received.frames.length < LEAVE_AFTER) {
        const { value, done } = await body.read();
        if (done) throw new Error(`the stream ended after ${received.frames.length} frames, before the client left`);
        buffer = parseFrames(buffer + decoder.decode(value, { stream: true }), received);
        if (received.terminal) throw new Error(`the stream finished (${received.terminal.finish}) before the client left`);
      }
      expect(leaving.aborted).toBe(false);
      leave.abort(new Error("client left"));
      await body.cancel().catch(() => undefined);
      await until("the server to observe the disconnect", () => leaving.aborted);
      await until("the abandoned row to drain", async () => {
        const { batch } = await (await fetch(new URL("/stats", base))).json();
        return batch.active_rows === 0 && batch.pending_rows === 0;
      });
      abandoning = false;
      const published = received.frames;
      // Recovery on the same server: a different prompt, then the abandoned one uninterrupted.
      const otherAfter = await whole(base, { prompt: OTHER, max_tokens: 32 });
      const storyAfter = await streamed(base, { prompt: STORY, max_tokens: 256 });
      await app.close(); app = undefined;

      // 2. References from a fresh paged server with the same reader.
      app = await serveWithPaging(root, gemma!, cold);
      base = new URL(`http://127.0.0.1:${app.port}`);
      const otherControl = await whole(base, { prompt: OTHER, max_tokens: 32 });
      const control = await streamed(base, { prompt: STORY, max_tokens: 256 });
      expect(otherAfter.choices).toEqual(otherControl.choices);
      expect(otherAfter.usage.completion_tokens).toBe(otherControl.usage.completion_tokens);
      expect(storyAfter).toEqual(control);
      // The client received a strict prefix of the uninterrupted control's frames.
      expect(control.frames.length).toBeGreaterThan(published.length);
      expect(published).toEqual(control.frames.slice(0, published.length));

      // Locate the token that published the last received frame: replay the
      // control's token ids through the server's text-completion router, which
      // must reproduce the control's frames exactly.
      const scored = await whole(base, { prompt: STORY, max_tokens: 256, logprobs: true });
      expect(scored.choices[0].text).toBe(control.frames.join(""));
      const ids: number[] = scored.choices[0].logprobs.content.map((entry: { id: number }) => entry.id);
      expect(ids).toHaveLength(control.completionTokens);
      const tokenizer = await loadTokenizer(gemma!);
      const replay = (tokens: number[]) => {
        const router = new ToolAwareStream(tokenizer, "plain", null);
        const deltas = tokens.map(token => router.push(token));
        return { deltas, tail: router.flush() };
      };
      const all = replay(ids);
      expect([...all.deltas, all.tail].filter(Boolean)).toEqual(control.frames);
      let counted = 0;
      const stopAt = all.deltas.findIndex(delta => delta !== "" && ++counted === published.length) + 1;
      expect(stopAt).toBeGreaterThan(0);
      expect(stopAt).toBeLessThan(control.completionTokens);
      // The abandoned row stopped decoding early: it stored fewer tokens than
      // the uninterrupted row, whose last generated token is never stored.
      expect(abandonedOffset).toBeGreaterThanOrEqual(control.promptTokens);
      expect(abandonedOffset).toBeLessThan(control.promptTokens + control.completionTokens - 1);
      // A stop is followed by the decoder's flush, which an abandoned row never reaches.
      const { tail } = replay(ids.slice(0, stopAt));
      const stopped = await streamed(base, { prompt: STORY, max_tokens: stopAt });
      expect(stopped).toEqual({ frames: tail ? [...published, tail] : published, finish: "length",
        promptTokens: control.promptTokens, completionTokens: stopAt });
      await app.close(); app = undefined;

      expect(readers.length).toBeGreaterThan(0);
      expect(readers.filter(flag => flag !== direct)).toEqual([]);
    } finally {
      try { await app?.close(); } finally {
        restoreRuntime();
        for (const spy of spies) spy.mockRestore();
        rmSync(root, { recursive: true, force: true });
      }
    }
  }, 900_000);
}
