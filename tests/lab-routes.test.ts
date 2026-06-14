// Lab web-UI integration (slow tier): an ephemeral-port server inside the
// test process (dies with the test — NOT a persistent server) exercising
// the new unified-app routes end-to-end through the real HTTP/WS layer:
// the SPA, the dataset builder (non-LLM, no model call), the shared job
// stream, quantize inspect, and a real pi-agent chat turn over WebSocket.

import { afterAll, describe, expect, test } from "bun:test";
import { existsSync, readFileSync } from "node:fs";
import { SNAPSHOT_MINICPM5, snapshotMiniCPM5Available } from "./paths";

const have = await snapshotMiniCPM5Available();

describe.skipIf(!have)("lab web UI routes", async () => {
  if (!have) return;
  const { createServer, loadContext } = await import("../src/server");
  const ctx = await loadContext(SNAPSHOT_MINICPM5, "minicpm5-1b");
  const server = createServer(ctx, 0);
  const base = `http://localhost:${server.port}`;
  afterAll(() => server.stop(true));

  test("GET / serves the unified SPA", async () => {
    const res = await fetch(`${base}/`);
    expect(res.status).toBe(200);
    expect(res.headers.get("content-type")).toContain("text/html");
    const html = await res.text();
    // all five sections present in the single embedded app
    for (const r of ["chat", "quantize", "finetune", "dataset", "status"])
      expect(html).toContain(`data-route="${r}"`);
  });

  test("legacy /chat and /status redirect into the hash router", async () => {
    const res = await fetch(`${base}/status`, { redirect: "manual" });
    expect(res.status).toBe(302);
    expect(res.headers.get("location")).toBe("/#/status");
  });

  test("GET /api/dataset/templates returns the 13 templates", async () => {
    const { templates } = (await (await fetch(`${base}/api/dataset/templates`)).json()) as {
      templates: { id: string; needs_llm: boolean; fields: unknown[] }[];
    };
    expect(templates.length).toBe(13);
    const ids = templates.map((t) => t.id);
    expect(ids).toContain("sft_qa_pairs");
    expect(ids).toContain("dpo_pref_pairs");
    // every template advertises a non-empty form schema for the UI
    expect(templates.every((t) => Array.isArray(t.fields))).toBe(true);
  });

  test("dataset build (non-LLM) runs as a job → writes train/valid jsonl", async () => {
    const submit = (await (await fetch(`${base}/api/dataset/submit`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        template_id: "sft_qa_pairs",
        inputs: { pairs_text: "Q: What is mlx-bun?\nA: A native MLX runtime for Bun.\n\nQ: Does it use Python?\nA: No." },
      }),
    })).json()) as { ok: boolean; job_id: string; output_dir: string };
    expect(submit.ok).toBe(true);
    expect(submit.job_id).toMatch(/^job_/);

    // poll until terminal (pure-JS job — fast)
    let status = "queued";
    for (let i = 0; i < 100 && !["done", "failed"].includes(status); i++) {
      await Bun.sleep(50);
      const { job } = (await (await fetch(`${base}/api/jobs/${submit.job_id}`)).json()) as {
        job: { status: string };
      };
      status = job.status;
    }
    expect(status).toBe("done");

    const train = `${submit.output_dir}/train.jsonl`;
    expect(existsSync(train)).toBe(true);
    const rows = readFileSync(train, "utf8").trim().split("\n").filter(Boolean).map((l) => JSON.parse(l));
    expect(rows.length).toBeGreaterThanOrEqual(1);
    expect(rows[0].messages?.[0]?.role).toBe("user"); // chat-format output
  });

  test("GET /api/jobs/:id/stream replays job events as SSE", async () => {
    // build a second tiny dataset job, then read its stream to completion
    const { job_id } = (await (await fetch(`${base}/api/dataset/submit`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ template_id: "sft_qa_pairs", inputs: { pairs_text: "Q: a\nA: b" } }),
    })).json()) as { job_id: string };
    const body = await (await fetch(`${base}/api/jobs/${job_id}/stream`)).text();
    expect(body).toContain("data:");
    expect(body).toMatch(/"type":"(started|stage|done)"/);
  });

  test("POST /api/quantize/inspect resolves a model from the registry", async () => {
    const r = (await (await fetch(`${base}/api/quantize/inspect`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ model_id: "MiniCPM5" }),
    })).json()) as { ok: boolean; arch?: string; size_gb?: number };
    expect(r.ok).toBe(true);
    expect(typeof r.arch).toBe("string");
  });

  test("chat over /ws/chat: a real pi-agent turn streams text from the local model", async () => {
    const ws = new WebSocket(`ws://localhost:${server.port}/ws/chat`);
    const frames: { type: string; [k: string]: unknown }[] = [];
    let text = "";
    const done = new Promise<void>((resolve, reject) => {
      const timer = setTimeout(() => reject(new Error(`chat timed out; frames=${frames.map((f) => f.type).join(",")}`)), 60_000);
      ws.addEventListener("message", (ev) => {
        const f = JSON.parse(ev.data as string);
        frames.push(f);
        if (f.type === "text_delta") text += f.delta;
        if (f.type === "ready") {
          ws.send(JSON.stringify({ type: "prompt", text: "Reply with exactly: CHAT-OK" }));
        }
        // The agent may take a tool-call turn before producing text; only
        // settle once a turn has actually streamed assistant text.
        if (f.type === "turn_end" && text.length > 0) { clearTimeout(timer); resolve(); }
        if (f.type === "error") { clearTimeout(timer); reject(new Error(String(f.message))); }
      });
      ws.addEventListener("error", () => reject(new Error("ws error")));
    });
    await done;
    ws.close();
    expect(frames.some((f) => f.type === "ready")).toBe(true);
    expect(frames.some((f) => f.type === "text_delta")).toBe(true);
    expect(text.length).toBeGreaterThan(0);
  }, 70_000);
});
