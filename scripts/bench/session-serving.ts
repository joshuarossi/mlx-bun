/** Paired fixed-input HTTP conversation replay. The first arm records inputs;
 * subsequent arms send those exact histories, so output drift cannot alter work.
 * This is a bounded serving probe, not a complete agent/app benchmark. */
import { mkdtempSync, rmSync, mkdirSync, writeFileSync, readFileSync } from "node:fs";
import { tmpdir, hostname, cpus } from "node:os";
import { join, dirname } from "node:path";
import { createHash } from "node:crypto";
import { loadContext, createServer, shutdownServer, flushServerCacheDurability } from "../../src/server";
import { configureRuntime } from "../../src/runtime-config";
const arg = (key: string, fallback = "") => process.argv.includes(key) ? process.argv[process.argv.indexOf(key) + 1]! : fallback;
const model = arg("--model"), draft = arg("--draft"), count = Number(arg("--tokens", "64")), turns = Number(arg("--turns", "6"));
const initial = arg("--request") ? JSON.parse(readFileSync(arg("--request"), "utf8")) : {
  messages: [{ role: "user", content: "Build a Kanban board with columns, cards and editing. Describe your next implementation step. ".repeat(20) }] };
const ctx = await loadContext(model, "session-bench", draft ? { draftModelDir: draft, draftKind: "mtp", numDraftTokens: 2 } : {});
const hash = (value: unknown) => createHash("sha256").update(JSON.stringify(value)).digest("hex");
const inputs: any[] = [], expected: string[] = [], results: any[] = [];
for (const enabled of [false, true, true, false]) {
  const dir = mkdtempSync(join(tmpdir(), "session-serving-"));
  const reset = configureRuntime({ MLX_BUN_SESSION_CACHE: enabled ? "1" : "0" });
  const server = createServer(ctx, 0, { hostname: "127.0.0.1", batch: 8, kvQuant: 4,
    promptCacheBytes: 4 * 1024 ** 3, ssdCacheDir: dir });
  const base = `http://127.0.0.1:${server.port}`;
  let messages = initial.messages;
  try {
    const measurements = [];
    for (let turn = 0; turn < turns; turn++) {
      const payload = inputs[turn] ?? { ...initial, messages, temperature: 0, seed: 42,
        max_tokens: count, stream: true, stream_options: { include_usage: true } };
      if (!inputs[turn]) inputs.push(structuredClone(payload));
      const started = performance.now(); let first = 0, text = "", reasoning = "", usage: any, finishReason: any;
      const response = await fetch(`${base}/v1/chat/completions`, { method: "POST", headers: {
        "content-type": "application/json", "x-session-affinity": "kanban-agent" }, body: JSON.stringify(payload) });
      if (!response.ok) throw new Error(await response.text());
      let pending = ""; const decoder = new TextDecoder();
      for await (const bytes of response.body!) {
        pending += decoder.decode(bytes, { stream: true });
        let end;
        while ((end = pending.indexOf("\n")) >= 0) {
          const line = pending.slice(0, end).trim(); pending = pending.slice(end + 1);
          if (!line.startsWith("data:") || line === "data: [DONE]") continue;
          const event = JSON.parse(line.slice(5));
          if (event.error) throw new Error(JSON.stringify(event.error));
          if (event.usage) usage = event.usage;
          for (const choice of event.choices ?? []) {
            const delta = choice.delta ?? {};
            if (!first && (delta.content || delta.reasoning || delta.reasoning_content || delta.tool_calls)) first = performance.now();
            text += delta.content ?? ""; reasoning += delta.reasoning_content ?? delta.reasoning ?? "";
            if (choice.finish_reason) finishReason = choice.finish_reason;
          }
        }
      }
      const elapsed = performance.now() - started;
      if (!usage || !finishReason) throw new Error("incomplete response");
      const identity = hash({ text, reasoning, finishReason, tokens: usage.completion_tokens });
      expected[turn] ??= identity;
      if (identity !== expected[turn]) throw new Error(`output changed at turn ${turn}`);
      measurements.push({ turn, inputHash: hash(payload), outputHash: identity, ttftMs: first - started,
        wallMs: elapsed, decodeTps: (usage.completion_tokens - 1) / (elapsed - (first - started)) * 1000, usage });
      if (results.length === 0) messages = [...messages, { role: "assistant", content: text, reasoning_content: reasoning },
        { role: "user", content: `Continue with implementation step ${turn + 2}.` }];
    }
    const durability = await flushServerCacheDurability(server);
    const stats = await (await fetch(`${base}/stats`)).json();
    results.push({ enabled, measurements, durability, stats });
    console.log(JSON.stringify({ enabled, turns, cache: (stats as any).prompt_cache }));
  } finally { await shutdownServer(server); reset(); rmSync(dir, { recursive: true, force: true }); }
}
const report = { machine: hostname(), cpu: cpus()[0]?.model, bun: Bun.version, model, draft,
  workload: "ABBA fixed HTTP histories; bounded continuations; first turn cold in each arm; not a full Kanban task",
  count, turns, inputSource: arg("--request") || null, results };
const output = arg("--output"); if (output) { mkdirSync(dirname(output), { recursive: true }); writeFileSync(output, JSON.stringify(report, null, 2)); }
