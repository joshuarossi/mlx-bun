// Integration: run generate() with a grammar constraint, verify the output is
// valid JSON matching the schema, AND compare token-for-token against the oMLX
// oracle (L2 parity — same model+prompt+schema+seed must produce the same
// token stream). mlx-lm has no grammar support; oMLX is the reference.
//
// Run: bun scripts/experiments/xgrammar-integrate.ts
// Requires oMLX running on :8000 (key josh3218) and Llama-3.2-1B downloaded.

import { createModel, type RuntimeModel } from "../../src/model/factory";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { loadTokenizer } from "../../src/tokenizer";
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
  const config = await loadModelConfig(SNAPSHOT);
  const weights = await Weights.open(SNAPSHOT);
  const model = createModel(weights, config);
  const tok = await loadTokenizer(SNAPSHOT);
  // render a minimal chat prompt (Llama-3 chat template)
  const rendered = `<|begin_of_text|><|start_header_id|>user<|end_header_id|>\n\n${PROMPT}<|eot_id|><|start_header_id|>assistant<|end_header_id|>\n\n`;
  const ids = tok.encode(rendered, false);
  const g = await compileGrammarRequest(
    {
      responseFormat: {
        type: "json_schema",
        json_schema: { name: "person", schema: SCHEMA, strict: true },
      },
    },
    tok,
    config.text.vocabSize ?? tok.vocabSize,
  );
  if (!g) throw new Error("grammar compile returned null");
  const gen = generate(model, ids, {
    maxTokens: opts.maxTokens,
    temperature: opts.temperature,
    topP: 1,
    seed: opts.seed,
    grammar: g.controller!,
    eosTokenIds: config.eosTokenIds,
  });
  const tokens: number[] = [];
  for await (const t of gen) tokens.push(t.token);
  const text = tok.decode(tokens, true);
  weights.dispose();
  // grammar controller is disposed by generate()'s finally — don't double-dispose
  // (xgrammar throws BindingError: instance already deleted).
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
  console.log("=== ours (mlx-bun + xgrammar) ===");
  const ours_greedy = await ours(opts);
  console.log("tokens:", ours_greedy.tokens.length);
  console.log("text:", ours_greedy.text);
  let parsed: unknown;
  try { parsed = JSON.parse(ours_greedy.text); } catch (e) { console.log("JSON.parse FAILED:", e); }
  console.log("parses:", parsed);

  console.log("\n=== oMLX oracle ===");
  const ref = await omlx(opts);
  console.log("text:", ref.text);
  let refParsed: unknown;
  try { refParsed = JSON.parse(ref.text); } catch (e) { console.log("oMLX JSON.parse FAILED:", e); }
  console.log("parses:", refParsed);

  console.log("\n=== parity check ===");
  console.log("texts equal:", ours_greedy.text === ref.text);
  if (ours_greedy.text !== ref.text) {
    console.log("ours:", JSON.stringify(ours_greedy.text));
    console.log("ref :", JSON.stringify(ref.text));
  }
})().catch((e) => { console.error(e); process.exit(1); });
