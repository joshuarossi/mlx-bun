import { expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const model = process.env.MLX_BUN_APP_TEST_MODEL;
const native = process.env.MLX_BUN_TEST_NATIVE === "1" && !!model;

for (const isolated of [false, true]) test.skipIf(!native)(`${isolated ? "isolated worker" : "in-process"}: one model serves both decision APIs, website examples, and concurrent generation`, async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-bun-decision-acceptance-"));
  const program = `
    import assert from "node:assert/strict";
    import { createServer, loadContext } from "./src/cli/server-entry.ts";
    import { runDecisionExample } from "./scripts/decision-example.ts";
    let server;
    if (process.env.DECISION_ISOLATED === "1") {
      const { startModelServer, parseServeOptions } = await import("./src/cli/serve.ts");
      const { scanSnapshot } = await import("@mlx-bun/hub/registry");
      const source = await scanSnapshot(process.env.MLX_BUN_APP_TEST_MODEL, "local-poc");
      assert.ok(source);
      const options = parseServeOptions({ values: { port: "0", "no-open": true, batch: "2", "prompt-cache": "0", "ssd-cache": "off" }, positionals: [] });
      server = await startModelServer(source, options);
    } else {
      const context = await loadContext(process.env.MLX_BUN_APP_TEST_MODEL, "local-poc");
      server = await createServer(context, 0, { hostname: "127.0.0.1", ownership: "owned", capacity: 2,
        cache: { promptCacheBytes: 0, ssdCacheDir: false } });
    }
    const base = "http://127.0.0.1:" + server.port;
    const post = async (path, body) => {
      const response = await fetch(base + path, { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify(body) });
      const result = await response.json();
      assert.equal(response.status, 200, JSON.stringify(result)); return result;
    };
    try {
      const result = await runDecisionExample(base);
      assert.equal(result.openai.model, "local-poc"); assert.equal(result.jev.model, "local-poc");
      assert.equal(result.openai.usage.output_tokens, 0); assert.equal(result.jev.usage.output_tokens, 0);
      assert.equal(result.openai.answers[0].probability, result.jev.answers.refund.noul);
      assert.equal(result.openai.answers[1].choice, result.jev.answers.department.choice);
      assert.equal(result.openai.answers[2].score, result.jev.answers.severity.score);
      const chat = { model: "local", messages: [{ role: "user", content: "Count from one to twenty, separated by commas." }],
        max_tokens: 24, temperature: 0, chat_template_kwargs: { enable_thinking: false } };
      const solo = await post("/v1/chat/completions", chat);
      // Start generation, then queue scoring while that stream is live.
      const stream = await fetch(base + "/v1/chat/completions", { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ ...chat, stream: true }) });
      const reader = stream.body.getReader(); let text = "", pending, count = 0;
      while (true) {
        const chunk = await reader.read(); if (chunk.done) break;
        text += new TextDecoder().decode(chunk.value); count++;
        if (!pending && text.includes('"content":')) pending = post("/v1/decisions", {
          model: "gpt-6-luna", input: "I was charged twice.", questions: [{ type: "predicate", instructions: "Is this a payment problem?" }] });
      }
      assert.ok(pending); const concurrent = await pending;
      assert.equal(concurrent.usage.output_tokens, 0);
      const content = text.split("\\n").filter(line => line.startsWith("data: {")).map(line => JSON.parse(line.slice(6)).choices?.[0]?.delta?.content ?? "").join("");
      assert.equal(content, solo.choices[0].message.content);
      // Run the exact SDK patterns in their upstream-supported Node runtime.
      const command = [process.env.DECISION_NODE, "./scripts/decision-website-examples.mjs", base];
      if (process.env.MLX_BUN_DECISION_IMAGE) command.push(process.env.MLX_BUN_DECISION_IMAGE);
      const child = Bun.spawn(command, { stdout: "pipe", stderr: "pipe" });
      const [code, output, error] = await Promise.all([child.exited, new Response(child.stdout).text(), new Response(child.stderr).text()]);
      assert.equal(code, 0, error); const website = JSON.parse(output);
      assert.equal(website.openai.model, "local-poc"); assert.equal(website.jev.model, "local-poc");
      if (process.env.MLX_BUN_DECISION_IMAGE) assert.equal(website.lane.answers[0].type, "choice");
      console.log(JSON.stringify({ example: result, website, concurrent: { tokens: solo.usage.completion_tokens, matched: true, decision: concurrent } }));
    } finally {
      const closed = await server.close({ timeoutMs: Infinity }); if (closed) assert.equal(closed.stopped, true);
    }
  `;
  try {
    const child = Bun.spawn([process.execPath, "--no-env-file", "--eval", program], {
      cwd: new URL("../../", import.meta.url).pathname,
      env: { ...process.env, MLX_BUN_HOME: root, DECISION_NODE: Bun.which("node") ?? "node", DECISION_ISOLATED: isolated ? "1" : "0", HF_HUB_OFFLINE: "1" },
      stdout: "pipe", stderr: "pipe",
    });
    const [code, output, error] = await Promise.all([child.exited, new Response(child.stdout).text(), new Response(child.stderr).text()]);
    console.log(output);
    expect(error).not.toContain("500 on"); expect(code, error).toBe(0);
  } finally { rmSync(root, { recursive: true, force: true }); }
}, 180_000);
