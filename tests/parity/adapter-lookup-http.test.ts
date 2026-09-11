import { describe, expect, test } from "bun:test";
import { cpSync, existsSync, mkdtempSync, readdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const target = Bun.env.MLX_BUN_TEST_BATCH_ADAPTER_MODEL ??
  `${Bun.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/98d7dc6a93ae05583e8a10018c8099459b58aeeb`;
const enabled = Bun.env.MLX_BUN_TEST_ADAPTER_LOOKUP === "1" && existsSync(`${target}/config.json`) &&
  ["upper", "french"].every(name => existsSync(`fixtures/adapters/${name}/adapters.safetensors`));

function commonPrefix(a: readonly number[], b: readonly number[]): number {
  let count = 0;
  while (count < a.length && count < b.length && a[count] === b[count]) count++;
  return count;
}

// Header-only traversal: no tensors are restored and no cache files mutated.
function cacheFiles(directory: string): string[] {
  return readdirSync(directory, { withFileTypes: true }).flatMap(entry => {
    const path = join(directory, entry.name);
    return entry.isDirectory() ? cacheFiles(path) : entry.name.endsWith(".mlxkv") ? [path] : [];
  });
}

describe.skipIf(!enabled)("adapter lookup HTTP and generated SSD prefixes", () => {
  test("tokenizer explains observed bare-colon newline cache boundary", async () => {
    const { loadTokenizer } = await import("../../src/tokenizer");
    const tokenizer = await loadTokenizer(target);
    // Captured M4 KV4 response: newline (107), then EOS. The durable
    // generated checkpoint contains prompt+newline, excluding EOS.
    const prompt = "Rewrite in uppercase: The workshop inventory contains brass washers and maple dowels.\nAnswer:";
    const ids = tokenizer.encode(prompt);
    const saved = [...ids, 107];
    const continuation = tokenizer.encode(prompt + "\n\nContinue:");
    expect(ids.length).toBe(18);
    expect(tokenizer.decode([107])).toBe("\n");
    expect(saved.length).toBe(19);
    expect(commonPrefix(saved, continuation)).toBe(18);
    expect(continuation[18]).toBe(108); // two newlines merge into one token
    // Generated entries carry lookup attachments and cannot be trimmed;
    // therefore the observed reusable donor is the earlier prompt boundary17.
    const earlierPromptBoundary = ids.slice(0, -1);
    const reusable = [earlierPromptBoundary, saved].filter(tokens => commonPrefix(tokens, continuation) === tokens.length);
    expect(Math.max(...reusable.map(tokens => tokens.length))).toBe(17);
    console.error(JSON.stringify({ tokenizerRegression: { saved, continuation,
      savedPiece: tokenizer.idToToken(saved[18]!), nextPiece: tokenizer.idToToken(continuation[18]!) } }));
  });

  test("generated adapter lookup continuation survives a fresh server process", async () => {
    const directory = mkdtempSync(join(tmpdir(), "mtp-generated-serving-"));
    const live = join(directory, "live"), durable = join(directory, "durable");
    const kv = Bun.env.MLX_BUN_TEST_BATCH_ADAPTER_KV_BITS || "off";
    const depth = "3";
    const draftArgs = ["--draft-kind", "ngram"];
    const processes: ReturnType<typeof Bun.spawn>[] = [];
    const stderrLogs: Promise<string>[] = []; let completed = false;
    const start = async (cache: string) => {
      const reservation = Bun.serve({ hostname: "127.0.0.1", port: 0, fetch: () => new Response() });
      const port = reservation.port!; await reservation.stop(true);
      const process = Bun.spawn([Bun.env.BUN_EXEC_PATH || globalThis.process.execPath,
        new URL("../../src/cli.ts", import.meta.url).pathname, "serve", "--model", target,
        ...draftArgs, "--num-draft-tokens", depth,
        "--batch", "4", "--kv-quant", kv, "--prompt-cache", "2", "--ssd-cache", cache,
        "--port", String(port), "--no-open"], { stdout: "pipe", stderr: "pipe", env: Bun.env });
      processes.push(process);
      const stdout = new Response(process.stdout).text(), stderr = new Response(process.stderr).text();
      stderrLogs.push(stderr);
      const base = `http://127.0.0.1:${port}`;
      const deadline = Date.now() + 120000;
      while (Date.now() < deadline) {
        if (process.exitCode !== null) throw new Error(`server exited ${process.exitCode}: ${await stdout}\n${await stderr}`);
        try { if ((await fetch(`${base}/health`, { signal: AbortSignal.timeout(1000) })).ok) return { process, base, stdout, stderr }; } catch {}
        await Bun.sleep(50);
      }
      throw new Error("generated-prefix server did not become ready");
    };
    const stop = async (server: Awaited<ReturnType<typeof start>>) => {
      server.process.kill("SIGTERM");
      const timeout = setTimeout(() => server.process.kill("SIGKILL"), 125000);
      try { expect(await server.process.exited, await server.stderr).toBe(0); }
      finally { clearTimeout(timeout); }
    };
    const json = async (base: string, path: string, body?: unknown) => {
      const response = await fetch(`${base}${path}`, { method: body === undefined ? "GET" : "POST",
        ...(body === undefined ? {} : { headers: { "content-type": "application/json" }, body: JSON.stringify(body) }),
        signal: AbortSignal.timeout(180000) });
      const result = await response.json() as any;
      expect(response.status, JSON.stringify(result)).toBe(200);
      return result;
    };
    try {
      const server = await start(live);
      const mount = async (base: string) => {
        for (const id of ["upper", "french"])
          await json(base, "/v1/adapters", { id, path: new URL(`../../fixtures/adapters/${id}`, import.meta.url).pathname });
      };
      await mount(server.base);
      const settings = { adapter: "upper", temperature: 0.7, seed: 42,
        max_tokens: 32, logprobs: true, top_logprobs: 3 };
      const prompt = "Rewrite in uppercase: The workshop inventory contains brass washers and maple dowels.\nAnswer:";
      const initial = await json(server.base, "/v1/completions", { ...settings, temperature: 0, prompt });
      expect(initial.usage.lane).toBe("batched");
      expect(initial.usage.speculation.rounds).toBeGreaterThan(0);
      expect(initial.choices[0].text.length).toBeGreaterThan(0);
      const flushed = await json(server.base, "/admin/cache/flush", {});
      expect(flushed.durable).toBe(true);
      expect(flushed.longest_durable_prefix_tokens).toBeGreaterThan(initial.usage.prompt_tokens);
      // Preserve only the first turn's durable state. The RAM continuation must
      // not populate the SSD input used by the fresh-process continuation.
      cpSync(live, durable, { recursive: true });
      const next = { ...settings, max_tokens: 12,
        prompt: prompt + initial.choices[0].text + "Continue:" };
      const { loadTokenizer } = await import("../../src/tokenizer");
      const { readKvHeader } = await import("../../src/kv-store");
      const tokenizer = await loadTokenizer(target);
      const headers = cacheFiles(durable).map(path => readKvHeader(path));
      const longest = headers.sort((a, b) => b.tokens.length - a.tokens.length)[0]!;
      expect(longest).toBeDefined();
      expect(longest.tokens.length).toBe(flushed.longest_durable_prefix_tokens);
      const nextIds = tokenizer.encode(next.prompt);
      const aligned = commonPrefix(longest.tokens, nextIds);
      console.error(JSON.stringify({ generatedAlignment: { initialTokens: initial.usage.prompt_tokens,
        saved: longest.tokens, nextIds, aligned } }));
      expect(aligned).toBeGreaterThan(initial.usage.prompt_tokens);
      expect(aligned).toBe(longest.tokens.length); // lookup attachments require the complete donor boundary
      const warm = await json(server.base, "/v1/completions", next);
      const cached = warm.usage.prompt_tokens_details.cached_tokens;
      if(cached <= initial.usage.prompt_tokens) console.error(JSON.stringify({prompt,initial,next,warm,flushed}));
      expect(cached).toBeGreaterThan(initial.usage.prompt_tokens);
      expect(cached).toBeLessThanOrEqual(flushed.longest_durable_prefix_tokens);
      expect(warm.usage.lane).toBe("batched");
      await stop(server);
      const restarted = await start(durable);
      expect(restarted.process.pid).not.toBe(server.process.pid);
      await mount(restarted.base);
      const before = await json(restarted.base, "/stats");
      expect(before.ssd_cache.restores).toBe(0);
      const restored = await json(restarted.base, "/v1/completions", next);
      expect(restored.usage.prompt_tokens_details.cached_tokens).toBe(cached);
      expect(restored.usage.lane).toBe("batched");
      expect(restored.choices).toEqual(warm.choices);
      expect(restored.usage.completion_tokens).toBe(warm.usage.completion_tokens);
      expect(restored.usage.speculation).toEqual(warm.usage.speculation);
      const after = await json(restarted.base, "/stats");
      expect(after.ssd_cache.restores).toBeGreaterThan(0);
      // Adapter namespaces must exclude the upper checkpoint even when the
      // prompt bytes match. This request has no earlier French donor.
      const french = await json(restarted.base, "/v1/completions", { ...next, adapter: "french" });
      expect(french.usage.prompt_tokens_details.cached_tokens).toBe(0);
      expect(french.usage.lane).toBe("batched");
      expect(french.usage.speculation.rounds).toBeGreaterThan(0);
      const repeated = await Promise.all(Array.from({ length: 4 }, () =>
        json(restarted.base, "/v1/completions", next)));
      for (const response of repeated) {
        expect(response.usage.lane).toBe("batched");
        expect(response.usage.speculation.rounds).toBeGreaterThan(0);
        expect(response.choices[0].logprobs).toBeDefined();
      }
      console.error(JSON.stringify({ kv, depth, initial: initial.usage, cached,
        next: restored.usage, ssdRestores: after.ssd_cache.restores }));
      await stop(restarted);
      completed = true;
    } finally {
      for (const process of processes) if (process.exitCode === null) { process.kill("SIGKILL"); await process.exited; }
      if (!completed) for (const log of stderrLogs) console.error(await log);
      rmSync(directory, { recursive: true, force: true });
    }
  }, 600000);
});
