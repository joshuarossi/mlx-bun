import { expect, test } from "bun:test";
import { createDecisionRoutes } from "../../src/server/decision-routes";
import { readDecisionBody } from "../../src/server/decision-body";
import type { LoadedModelContext } from "../../src/engine/model-host";

test("OpenAI and Jev SDKs accept unchanged cloud names and explicit local model IDs", async () => {
  const seen: { path: string; encoding: string | null; model: string }[] = [];
  let images = 0;
  const context = { modelId: "local/checkpoint", model: { config: { eosTokenIds: [0] } }, genDefaults: {},
    tokenizer: { encode: (text: string) => [...new TextEncoder().encode(text)], eosTokenId: 0 } } as unknown as LoadedModelContext;
  const routes = createDecisionRoutes({ context,
    binding: { decide: async input => {
      for (const _ of input.candidates) await input.execute!(async () => {});
      return input.candidates.map((_, i) => input.candidates.length === 1 ? 1 : i === 0 ? 0.8 : 0.2 / (input.candidates.length - 1));
    } },
    gateway: { runExclusive: work => work(), runPreparation: work => work() },
  }, { contextLimit: 10000, buildPrompt: async body => {
    images += body.messages.flatMap(message => Array.isArray(message.content) ? message.content : [])
      .filter(part => part.type === "image_url").length;
    return { promptIds: [1, 2], vision: undefined, diffusionPixels: null, startInThinking: false, probeStableLen: false };
  } });
  const server = Bun.serve({ port: 0, hostname: "127.0.0.1", fetch: async request => {
    const body = await readDecisionBody(request.clone()) as { model: string };
    seen.push({ path: new URL(request.url).pathname, encoding: request.headers.get("content-encoding"), model: body.model });
    return await routes.handle(request) ?? new Response(null, { status: 404 });
  } });
  try {
    const base = `http://127.0.0.1:${server.port}`;
    // TypeSafe 0.7 targets Node 22+: run its unmodified website calling pattern
    // in Node. Its response-clone buffering currently consumes Bun fetch bodies.
    // Both clients run in a child so DOM globals from other tests cannot make
    // OpenAI mistake this server-side example for a browser with a secret key.
    const node = Bun.which("node");
    if (!node) throw new Error("The Jev SDK compatibility check requires Node 22+");
    const child = Bun.spawn([node, "--input-type=module", "--eval", `
      import assert from "node:assert/strict";
      import OpenAI from ${JSON.stringify(import.meta.resolve("openai"))};
      import { TypeSafeClient, noul, choice, score, image } from ${JSON.stringify(import.meta.resolve("@typesafe-ai/sdk"))};
      import { runWebsiteExamples, decisionExampleModel } from ${JSON.stringify(new URL("../../scripts/decision-website-examples.mjs", import.meta.url).href)};
      const openai = new OpenAI({ apiKey: "local", baseURL: ${JSON.stringify(`${base}/v1`)}, maxRetries: 0 });
      const decision = await openai.decisions.create({ model: "gpt-6-luna", input: "The package arrived with a broken screen.",
        questions: [{ type: "predicate", name: "damaged", instructions: "Does the customer report a damaged item?" },
          { type: "choice", name: "route", instructions: "Who handles this?", choices: [{ value: "returns" }, { value: "sales" }] },
          { type: "score", name: "severity", instructions: "How severe?", levels: [{ label: "Minor" }, { label: "Major" }] }] });
      assert.equal(decision.model, "local/checkpoint");
      assert.deepEqual(decision.answers[0], { type: "predicate", name: "damaged", probability: 0.2 });
      assert.equal(decision.usage.output_tokens, 0);
      await assert.rejects(openai.decisions.create({ model: "gpt-6-luna", input: "x", questions: [] }),
        error => error.status === 400);
      const client = new TypeSafeClient({ apiKey: "local", baseURL: ${JSON.stringify(base)} });
      const result = await client.systemOne({ state: { document: "I was charged twice. ".repeat(100) }, questions: {
        refund: noul("Is a refund requested?"),
        category: choice("What is this ticket about?", { billing: null, technical: null, other: null }),
        severity: score("How severe?", ["Minor", "Major", "Critical"]),
      } });
      assert.equal(result.model, "local/checkpoint");
      assert.equal(result.answers.category.choice, "billing");
      assert.equal(result.answers.refund.noul, 0.2);
      assert.deepEqual(result.answers.severity.legend, { "0": "Minor", "1": "Major", "2": "Critical" });
      assert.equal(result.usage.output_tokens, 0);
      const optional = await client.systemOne({ state: "x", questions: {
        only: { type: "choice", criteria: { single: null } },
        rubric: { type: "score", criteria: [{ details: ["low"] }, null] },
      } });
      assert.equal(optional.answers.only.confidence, 1);
      assert.deepEqual(optional.answers.rubric.legend, { "0": { details: ["low"] }, "1": null });
      const png = Buffer.from("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jgXkAAAAASUVORK5CYII=", "base64");
      await client.systemOne({ state: { photo: image(png) }, questions: { visible: noul("Is anything visible?") } },
        { headers: { "TypeSafe-Danger-Zone-Images": "true" } });
      const local = await runWebsiteExamples(${JSON.stringify(base)}, "local/checkpoint");
      assert.equal(local.openai.model, "local/checkpoint"); assert.equal(local.jev.model, "local/checkpoint");
      assert.equal(decisionExampleModel, "mlx-community/gemma-4-e4b-it-OptiQ-4bit");
      await runWebsiteExamples(${JSON.stringify(base)});
    `], { stdout: "pipe", stderr: "pipe" });
    const [code, error] = await Promise.all([child.exited, new Response(child.stderr).text()]);
    expect(error).toBe(""); expect(code).toBe(0);
    expect(seen.some(request => request.path === "/v1/systemone" && request.encoding === "zstd")).toBe(true);
    for (const path of ["/v1/decisions", "/v1/systemone"])
      expect(seen.filter(request => request.path === path).slice(-2).map(request => request.model))
        .toEqual(["local/checkpoint", "mlx-community/gemma-4-e4b-it-OptiQ-4bit"]);
    expect(images).toBe(1);
  } finally { await server.stop(true); }
});
