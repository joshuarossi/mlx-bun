import { describe, expect, test } from "bun:test";
import { cpSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const enabled = Bun.env.MLX_BUN_TEST_MTP_PREFIX === "1";

describe.skipIf(!enabled)("generated chat prefixes across server processes", () => {
  test.each([false, true])("a completed tool turn survives RAM reuse and SSD restart, thinking=%s", async thinking => {
    const directory = mkdtempSync(join(tmpdir(), "mtp-generated-serving-"));
    const live = join(directory, "live"), durable = join(directory, "durable");
    const target = Bun.env.MLX_BUN_TEST_MTP_TARGET!, draft = Bun.env.MLX_BUN_TEST_MTP_DRAFT!;
    const kv = Bun.env.MLX_BUN_TEST_MTP_TURBO === "1" ? "turbo:k8v3" : Bun.env.MLX_BUN_TEST_MTP_KV_BITS || "off";
    const depth = Bun.env.MLX_BUN_TEST_MTP_DEPTH || "3";
    const draftArgs = Bun.env.MLX_BUN_TEST_GROUP_NGRAM === "1" ? ["--draft-kind", "ngram"]
      : ["--draft-model", draft, "--draft-kind", "mtp"];
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
      const tools = [{ type: "function", function: { name: "echo", description: "Echo a message.",
        parameters: { type: "object", properties: { message: { type: "string" } }, required: ["message"] } } }];
      const messages: any[] = [{ role: "user", content: "Call the echo tool once with message hello. Do not add any other text." }];
      const settings = { tools, temperature: 0, seed: 42,
        chat_template_kwargs: { enable_thinking: thinking, preserve_thinking: true },
        reasoning_effort: "low", max_tokens: 256 };
      const initial = await json(server.base, "/v1/chat/completions", { ...settings, messages });
      expect(initial.usage.lane).toBe("batched");
      expect(initial.usage.speculation.rounds).toBeGreaterThan(0);
      const assistant = initial.choices[0].message;
      expect(Boolean(assistant.reasoning?.length)).toBe(thinking);
      expect(assistant.tool_calls).toHaveLength(1);
      expect(assistant.tool_calls[0].function.name).toBe("echo");
      const flushed = await json(server.base, "/admin/cache/flush", {});
      expect(flushed.durable).toBe(true);
      expect(flushed.longest_durable_prefix_tokens).toBeGreaterThan(initial.usage.prompt_tokens);
      // Preserve only the first turn's durable state. The RAM continuation must
      // not populate the SSD input used by the fresh-process continuation.
      cpSync(live, durable, { recursive: true });
      const next = { ...settings, max_tokens: 24, logprobs: true, top_logprobs: 3,
        messages: [...messages, assistant, { role: "tool", tool_call_id: assistant.tool_calls[0].id, content: "hello" }] };
      const warm = await json(server.base, "/v1/chat/completions", next);
      const cached = warm.usage.prompt_tokens_details.cached_tokens;
      expect(cached).toBeGreaterThan(initial.usage.prompt_tokens);
      expect(cached).toBe(flushed.longest_durable_prefix_tokens);
      expect(warm.usage.lane).toBe("batched");
      await stop(server);
      const restarted = await start(durable);
      expect(restarted.process.pid).not.toBe(server.process.pid);
      const before = await json(restarted.base, "/stats");
      expect(before.ssd_cache.restores).toBe(0);
      const restored = await json(restarted.base, "/v1/chat/completions", next);
      expect(restored.usage.prompt_tokens_details.cached_tokens).toBe(cached);
      expect(restored.usage.lane).toBe("batched");
      expect(restored.choices).toEqual(warm.choices);
      expect(restored.usage.completion_tokens).toBe(warm.usage.completion_tokens);
      expect(restored.usage.speculation).toEqual(warm.usage.speculation);
      const after = await json(restarted.base, "/stats");
      expect(after.ssd_cache.restores).toBeGreaterThan(0);
      console.error(JSON.stringify({ thinking, kv, depth, initial: initial.usage, cached,
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
