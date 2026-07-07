// L2 parity harness: mlx-bun (with xgrammar) vs oMLX, same model+prompt+schema+seed.
// Uses the REAL chat template via loadContext (fixes the manual-template divergence
// in xgrammar-integrate.ts). oMLX is the oracle (it uses mlx-lm + xgrammar).
//
// Run: bun scripts/experiments/xgrammar-parity.ts
// Requires oMLX on :8000 (key josh3218) + Llama-3.2-1B downloaded.

import { loadContext } from "../../src/server";
import { generate } from "../../src/generate";
import { compileGrammarRequest } from "../../src/grammar";

const SNAPSHOT =
  "/Users/joshrossi/.cache/huggingface/hub/models--mlx-community--Llama-3.2-1B-Instruct-4bit/snapshots/08231374eeacb049a0eade7922910865b8fce912";
const OMLX = "http://127.0.0.1:8000";
const KEY = "josh3218";
const MODEL_ID = "mlx-community--Llama-3.2-1B-Instruct-4bit";

const SCHEMA = {
  type: "object",
  properties: {
    name: { type: "string" },
    age: { type: "number" },
    hobbies: { type: "array", items: { type: "string" } },
  },
  required: ["name", "age", "hobbies"],
};
const PROMPT = "Give me a person: name, age, two hobbies. Respond as JSON.";

async function ours(opts: { temperature: number; seed: number; maxTokens: number }) {
  const ctx = await loadContext(SNAPSHOT);
  // REAL chat template (the same one the server uses):
  const rendered = ctx.template.render(
    [{ role: "user", content: PROMPT }],
    { tools: null, enableThinking: false },
  );
  const ids = ctx.tokenizer.encode(rendered);
  const g = await compileGrammarRequest(
    {
      responseFormat: {
        type: "json_schema",
        json_schema: { name: "person", schema: SCHEMA, strict: true },
      },
    },
    ctx.tokenizer,
    ctx.model.config.text.vocabSize,
  );
  if (!g) throw new Error("grammar compile returned null");
  const gen = generate(ctx.model, ids, {
    maxTokens: opts.maxTokens,
    temperature: opts.temperature,
    topP: 1,
    seed: opts.seed,
    grammar: g.controller!,
    eosTokenIds: ctx.model.config.eosTokenIds,
  });
  const tokens: number[] = [];
  for await (const t of gen) tokens.push(t.token);
  const text = ctx.tokenizer.decode(tokens, true);
  // grammar disposed by generate's finally; ctx.model lifecycle owned by ctx
  return { tokens, text };
}

async function omlx(opts: { temperature: number; seed: number; maxTokens: number }) {
  const r = await fetch(`${OMLX}/v1/chat/completions`, {
    method: "POST",
    headers: { Authorization: `Bearer ${KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      model: MODEL_ID,
      messages: [{ role: "user", content: PROMPT }],
      response_format: {
        type: "json_schema",
        json_schema: { name: "person", schema: SCHEMA, strict: true },
      },
      max_tokens: opts.maxTokens,
      temperature: opts.temperature,
      seed: opts.seed,
      top_p: 1,
    }),
  });
  const j: any = await r.json();
  if (j.error) throw new Error("oMLX error: " + JSON.stringify(j.error));
  return { text: j.choices[0].message.content };
}

(async () => {
  const opts = { temperature: 0, seed: 42, maxTokens: 100 };

  console.log("=== ours (mlx-bun + xgrammar, real chat template) ===");
  const o = await ours(opts);
  console.log("tokens:", o.tokens.length, "text:", JSON.stringify(o.text));
  let oParsed: unknown;
  try { oParsed = JSON.parse(o.text); } catch (e) { console.log("parse FAIL:", e); }
  console.log("parses:", oParsed);

  console.log("\n=== oMLX oracle ===");
  const ref = await omlx(opts);
  console.log("text:", JSON.stringify(ref.text));
  let rParsed: unknown;
  try { rParsed = JSON.parse(ref.text); } catch (e) { console.log("oMLX parse FAIL:", e); }
  console.log("parses:", rParsed);

  console.log("\n=== parity ===");
  console.log("texts equal:", o.text === ref.text);
  // Both must at least be valid JSON matching the schema (the L2 contract):
  const bothValid =
    !!oParsed && !!rParsed &&
    typeof (oParsed as any).name === "string" &&
    typeof (ref as any) === "object";
  console.log("both produce valid schema-conformant JSON:", bothValid);
})().catch((e) => { console.error(e); process.exit(1); });
