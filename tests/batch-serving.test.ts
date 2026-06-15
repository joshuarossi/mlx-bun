// GATED integration: `--batch N` end to end through the HTTP server. Ephemeral
// in-process server (dies with the test), real concurrent chat requests routed
// through the continuous-batching scheduler.
//
//   MLX_BUN_TEST_BATCH_DECODE=1 bun test tests/batch-serving.test.ts
//
// The scheduler's NUMERICS are gated elsewhere (tests/batch-scheduler.test.ts,
// teacher-forced). This gates the WIRING: that --batch 2 actually engages on a
// full-attention model, concurrent requests fan out to their own SSE streams
// and all complete, and the serial/batched lanes are mutually exclusive (a
// non-batchable request — user-fixed seed — drains and runs alongside batched
// ones without deadlock). Uses CPM (full-attention; the default Gemma SNAPSHOT
// is sliding-window → serial fallback, which wouldn't exercise the batch path).

import { afterAll, describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";

const optIn = process.env.MLX_BUN_TEST_BATCH_DECODE === "1";
const CPM_BASE =
  `${process.env.HOME}/.cache/huggingface/hub/` +
  `models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/` +
  `664aabaed233c653f82716d8dc822234d0091f78`;
const haveCpm = existsSync(`${CPM_BASE}/config.json`);

describe.skipIf(!optIn || !haveCpm)("--batch N serving (CPM, full-attention)", async () => {
  if (!optIn || !haveCpm) return;
  const { createServer, loadContext } = await import("../src/server");
  const ctx = await loadContext(CPM_BASE, "minicpm5-1b-cpm");
  const server = createServer(ctx, 0, { batch: 2 });
  const base = `http://localhost:${server.port}`;
  afterAll(() => server.stop(true));

  const chat = (body: Record<string, unknown>) =>
    fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify(body),
    });
  const req = (prompt: string, extra: Record<string, unknown> = {}) => ({
    messages: [{ role: "user", content: prompt }],
    max_tokens: 12, temperature: 0, ...extra,
  });

  test("/stats reports batching live for a full-attention model", async () => {
    const s = (await (await fetch(`${base}/stats`)).json()) as any;
    expect(s.batch.configured).toBe(2);
    expect(s.batch.batched).toBe(true);
  });

  test("concurrent requests all complete with coherent output", async () => {
    const prompts = ["Count: one two", "Name a color:", "The capital of France is"];
    const resps = await Promise.all(prompts.map((p) => chat(req(p))));
    for (const r of resps) expect(r.status).toBe(200);
    const bodies = (await Promise.all(resps.map((r) => r.json()))) as any[];
    for (const b of bodies) {
      expect(typeof b.choices[0].message.content).toBe("string");
      expect(b.choices[0].message.content.length).toBeGreaterThan(0);
      expect(["stop", "length", "tool_calls"]).toContain(b.choices[0].finish_reason);
      expect(b.usage.completion_tokens).toBeGreaterThan(0);
    }
  }, 120_000);

  test("streaming request fans out (role + content deltas + [DONE])", async () => {
    const r = await chat(req("List two fruits:", { stream: true }));
    expect(r.status).toBe(200);
    const text = await r.text();
    expect(text).toContain('"role":"assistant"');
    expect(text).toContain("data: [DONE]");
    // at least one content delta
    expect(text).toMatch(/"content":"[^"]/);
  }, 120_000);

  test("batched + serial (user-seed) lanes coexist without deadlock", async () => {
    const batched = chat(req("Say hello:"));
    const serial = chat(req("Say goodbye:", { seed: 123 })); // user seed → serial lane
    const [rb, rs] = await Promise.all([batched, serial]);
    expect(rb.status).toBe(200);
    expect(rs.status).toBe(200);
    const [bb, bs] = (await Promise.all([rb.json(), rs.json()])) as any[];
    expect(bb.choices[0].message.content.length).toBeGreaterThan(0);
    expect(bs.choices[0].message.content.length).toBeGreaterThan(0);
  }, 120_000);
});
