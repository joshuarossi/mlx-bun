// E0 driver (PLAN Phase 19): load the 26B MoE once, trace its router
// decisions over representative coding / writing / chat prompts, write one
// JSONL per domain to /tmp. Then:
//   bun scripts/analyze-expert-trace.ts /tmp/expert-trace-{coding,writing,chat}.jsonl
//
// Routing is deterministic from the prompt and independent of machine load,
// so this does NOT need a cleared machine (unlike tok/s benchmarks). It DOES
// hold ~16 GB resident while it runs.
//
//   bun scripts/run-expert-trace.ts [registry-query]   (default: 26B)

import { Registry } from "../src/registry";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { createModel } from "../src/model/factory";
import { generate } from "../src/generate";
import { ChatTemplate } from "../src/chat-template";
import { loadTokenizer } from "../src/tokenizer";
import { beginExpertTrace, endExpertTrace } from "../src/expert-trace";

const QUERY = process.argv[2] ?? "26B";
const MAX_TOKENS = 160;
const OUTDIR = "/tmp";

const DOMAINS: Record<string, string[]> = {
  coding: [
    "How do I implement recursive functions in Python? Show an example.",
    "Write a function to reverse a singly linked list in Rust.",
    "Explain Python decorators and give a practical example.",
    "How do I properly handle errors in async/await JavaScript?",
    "Write a SQL query to find duplicate email addresses in a users table.",
    "Implement binary search over a sorted array in Go.",
    "Why might a React useEffect run twice, and how do I fix it?",
    "Write a Python class for a thread-safe LRU cache.",
  ],
  writing: [
    "Write an evocative opening paragraph for an essay about autumn.",
    "Draft a polite, concise email declining a meeting invitation.",
    "Write a short story about a lighthouse keeper who finds a message in a bottle.",
    "Compose three haiku about the ocean at dawn.",
    "Rewrite this to be more concise and vivid: 'The weather was very bad and it made everyone feel quite unhappy.'",
    "Write a warm product description for a handmade walnut writing desk.",
    "Summarize the plot of Romeo and Juliet in two paragraphs.",
    "Write the opening of a cover letter for a high-school teaching position.",
  ],
  chat: [
    "What's a good two-day weekend trip within driving distance of San Francisco?",
    "Explain how vaccines work, in simple terms.",
    "I have chicken, rice, and a few vegetables. What should I cook tonight?",
    "Tell me an interesting fact about octopuses.",
    "How does compound interest work, with a small example?",
    "What's the difference between weather and climate?",
    "Recommend three science-fiction novels and say why.",
    "Why is the sky blue? Keep it short.",
  ],
};

const reg = new Registry();
if (reg.list().length === 0) await reg.scan();
const resolved = reg.resolve(QUERY);
reg.close();
console.log(`model: ${resolved.path}`);

const config = await loadModelConfig(resolved.path);
const weights = await Weights.open(resolved.path);
const model = createModel(weights, config);
const tok = await loadTokenizer(resolved.path);
const template = await ChatTemplate.load(resolved.path);

function encode(userMsg: string): number[] {
  const ids = tok.encode(template.render([{ role: "user", content: userMsg }]));
  return ids[0] === ids[1] && ids[0] === tok.bosTokenId ? ids.slice(1) : ids;
}

// warmup (NOT traced) — materialize weights so the first traced prompt isn't
// dominated by lazy page-in. Routing is identical warm or cold; this is just
// to keep the run snappy.
{
  const g = generate(model, encode("hello"), { maxTokens: 2, temperature: 0 });
  for await (const _ of g) { /* discard */ }
}

const t0 = performance.now();
for (const [domain, prompts] of Object.entries(DOMAINS)) {
  const path = `${OUTDIR}/expert-trace-${domain}.jsonl`;
  beginExpertTrace(path);
  let toks = 0;
  for (const p of prompts) {
    const g = generate(model, encode(p), { maxTokens: MAX_TOKENS, temperature: 0 });
    for await (const _ of g) toks++;
  }
  endExpertTrace();
  console.log(`  ${domain}: ${prompts.length} prompts, ${toks} tokens -> ${path}`);
}
console.log(`done in ${((performance.now() - t0) / 1000).toFixed(0)}s`);
