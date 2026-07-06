// Phase-2 profiling: WHERE does the batch lane's B=1 decode step spend its
// extra ~4-6 ms/token vs the serial loop? Drives the same model through
// (a) generate() serial and (b) BatchScheduler B=1 in ONE process, then
// prints per-step wall breakdowns. cpm5 (no rot layers, no compiled decode)
// isolates the scheduler/step overhead from everything model-specific.
//
//   bun scripts/experiments/batch-b1-step-profile.ts [--tokens 128] [--model <registry name>]
// (--model defaults to cpm5; gemma names exercise the Phase-3.2 compiled-B1 path)

import { Registry } from "../../src/registry";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { generate } from "../../src/generate";
import { BatchScheduler, stepTraceReport } from "../../src/serve/batch-scheduler";
import { loadTokenizer } from "../../src/tokenizer";
import { toLogprobs } from "../../src/sampler";
import * as ops from "../../src/mlx/ops";
import { ChatTemplate } from "../../src/chat-template";

const arg = (n: string, d: string) => {
  const i = process.argv.indexOf(n);
  return i > -1 ? process.argv[i + 1]! : d;
};
const TOKENS = Number(arg("--tokens", "128"));

const reg = new Registry();
if (reg.list().length === 0) await reg.scan();
const dir = reg.resolve(arg("--model", "MiniCPM5-1B-OptiQ-4bit")).path;
const config = await loadModelConfig(dir);
const weights = await Weights.open(dir);
const model = createModel(weights, config);
const tok = await loadTokenizer(dir);
const template = await ChatTemplate.load(dir);

const rendered = template.render([{ role: "user", content: "Write a detailed essay about the history of computing." }]);
const ids0 = tok.encode(rendered);
const promptIds = ids0[0] === ids0[1] && ids0[0] === tok.bosTokenId ? ids0.slice(1) : ids0;

async function serial(): Promise<number> {
  const t0 = performance.now();
  let n = 0;
  let firstAt = 0;
  const gen = generate(model, promptIds, { maxTokens: TOKENS, temperature: 0, eosTokenIds: [] });
  for await (const _ of gen) {
    if (++n === 1) firstAt = performance.now();
  }
  const dt = performance.now() - firstAt;
  console.log(`serial: ${n} tok, decode ${(((n - 1) * 1000) / dt).toFixed(1)} tok/s (total ${(performance.now() - t0).toFixed(0)} ms)`);
  return ((n - 1) * 1000) / dt;
}

async function batched(): Promise<number> {
  const sched = new BatchScheduler(model as any, { maxBatch: 2 });
  const t0 = performance.now();
  let n = 0;
  let firstAt = 0;
  await sched.submit({
    promptIds,
    maxTokens: TOKENS,
    eosTokenIds: [],
    plainGreedy: true,
    // greedy row sampler (prefill samples token 0 through it; decode uses
    // the vectorized plainGreedy path)
    sample: (logits1V: any, _step: number) => {
      const lp = toLogprobs(logits1V);
      const t = ops.argmaxAxis(lp, -1);
      lp.dispose();
      return t;
    },
    onToken: () => {
      if (++n === 1) firstAt = performance.now();
      return true;
    },
  });
  const dt = performance.now() - firstAt;
  console.log(`batch B=1: ${n} tok, decode ${(((n - 1) * 1000) / dt).toFixed(1)} tok/s (total ${(performance.now() - t0).toFixed(0)} ms)`);
  if (process.env.MLX_BUN_BATCH_STEP_TRACE === "1") console.log(`  ${stepTraceReport()}`);
  return ((n - 1) * 1000) / dt;
}

// warmup then alternate
await serial();
await batched();
const s1 = await serial();
const b1 = await batched();
const s2 = await serial();
const b2 = await batched();
console.log(`\nserial best ${Math.max(s1, s2).toFixed(1)} vs batch-B1 best ${Math.max(b1, b2).toFixed(1)} → ratio ${(Math.max(b1, b2) / Math.max(s1, s2)).toFixed(3)}`);
