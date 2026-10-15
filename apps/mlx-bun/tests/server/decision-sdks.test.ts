import { expect, test } from "bun:test";
import OpenAI from "openai";
import { createDecisionRoutes } from "../../src/server/decision-routes";
import type { LoadedModelContext } from "../../src/engine/model-host";

test("published OpenAI and Jev SDK examples work with only local base URLs and keys", async () => {
  const seen: { path: string; encoding: string | null }[] = [];
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
    seen.push({ path: new URL(request.url).pathname, encoding: request.headers.get("content-encoding") });
    return await routes.handle(request) ?? new Response(null, { status: 404 });
  } });
  try {
    const base = `http://127.0.0.1:${server.port}`;
    const openai = new OpenAI({ apiKey: "local", baseURL: `${base}/v1`, maxRetries: 0 });
    const decision = await openai.decisions.create({ model: "gpt-6-luna", input: "The package arrived with a broken screen.",
      questions: [{ type: "predicate", name: "damaged", instructions: "Does the customer report a damaged item?" },
        { type: "choice", name: "route", instructions: "Who handles this?", choices: [{ value: "returns" }, { value: "sales" }] },
        { type: "score", name: "severity", instructions: "How severe?", levels: [{ label: "Minor" }, { label: "Major" }] }] });
    expect(decision.model).toBe("local/checkpoint");
    expect(decision.answers[0]).toEqual({ type: "predicate", name: "damaged", probability: 0.2 });
    expect(decision.usage.output_tokens).toBe(0);
    // TypeSafe 0.7 targets Node 22+: run its unmodified website calling pattern
    // in Node. Its response-clone buffering currently consumes Bun fetch bodies.
    const node = Bun.which("node");
    if (!node) throw new Error("The Jev SDK compatibility check requires Node 22+");
    const child = Bun.spawn([node, "--input-type=module", "--eval", `
      import assert from "node:assert/strict";
      import { TypeSafeClient, noul, choice, score, image } from ${JSON.stringify(import.meta.resolve("@typesafe-ai/sdk"))};
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
    `], { stdout: "pipe", stderr: "pipe" });
    const [code, error] = await Promise.all([child.exited, new Response(child.stderr).text()]);
    expect(error).toBe(""); expect(code).toBe(0);
    expect(seen.some(request => request.path === "/v1/systemone" && request.encoding === "zstd")).toBe(true);
    expect(images).toBe(1);
    let status: unknown;
    try { await openai.decisions.create({ model: "gpt-6-luna", input: "x", questions: [] }); }
    catch (error) { status = (error as { status: number }).status; }
    expect(status).toBe(400);
  } finally { await server.stop(true); }
});
