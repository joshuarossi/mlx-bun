// B=4 agg-collapse probe: reproduces the serve-matrix agg×4 defect
// (e4b/12B mlx-bun agg ≪ serial control; mixed arm unaffected) OUTSIDE the
// HTTP stack so the step tracer can see it. A/Bs prompt identity:
//   same    — 4 identical prompts → equal solo lengths → zero left-pad after
//             merge → #step takes the UNPADDED fast path
//   distinct— 4 different-length prompts (the bench's uuid trick) → nonzero
//             leftPad → the PADDED branch (per-step mask rebuild, the
//             PLAN-flagged unmeasured path)
//
//   bun scripts/experiments/batch-b4-probe.ts --model <registry name> [--tokens 128]
//   MLX_BUN_BATCH_STEP_TRACE=1 adds the per-phase step report.

import { Registry } from "../../src/registry";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
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
const STREAMS = Number(arg("--streams", "4"));

const reg = new Registry();
if (reg.list().length === 0) await reg.scan();
const dir = reg.resolve(arg("--model", "MiniCPM5-1B-OptiQ-4bit")).path;
const config = await loadModelConfig(dir);
const weights = await Weights.open(dir);
const model = createModel(weights, config);
const tok = await loadTokenizer(dir);
const template = await ChatTemplate.load(dir);

function encode(content: string): number[] {
  const ids0 = tok.encode(template.render([{ role: "user", content }]));
  return ids0[0] === ids0[1] && ids0[0] === tok.bosTokenId ? ids0.slice(1) : ids0;
}

async function leg(name: string, contents: string[]): Promise<void> {
  const sched = new BatchScheduler(model as any, { maxBatch: STREAMS });
  const t0 = performance.now();
  let firstAt = 0;
  const counts = new Array(contents.length).fill(0);
  await Promise.all(
    contents.map((content, i) =>
      sched.submit({
        promptIds: encode(content),
        maxTokens: TOKENS,
        eosTokenIds: [],
        plainGreedy: true,
        sample: (logits1V: any, _step: number) => {
          const lp = toLogprobs(logits1V);
          const t = ops.argmaxAxis(lp, -1);
          lp.dispose();
          return t;
        },
        onToken: () => {
          if (++counts[i]! === 1 && !firstAt) firstAt = performance.now();
          return true;
        },
      }),
    ),
  );
  const wallS = (performance.now() - t0) / 1000;
  const total = counts.reduce((a, b) => a + b!, 0);
  console.log(
    `${name}: agg ${(total / wallS).toFixed(1)} tok/s` +
      ` (${total} tok / ${wallS.toFixed(2)} s; per-stream ${counts.join("/")})`,
  );
  if (process.env.MLX_BUN_BATCH_STEP_TRACE === "1") {
    console.log(`  ${stepTraceReport()}`);
  }
}

const base = "Write a detailed essay about computers.";
console.log(`model=${arg("--model", "MiniCPM5-1B-OptiQ-4bit")} streams=${STREAMS} tokens=${TOKENS}`);

// warmup (weights hot, allocator primed)
await leg("warmup/same    ", [base, base, base, base].slice(0, STREAMS));

await leg("A same-prompt  ", [base, base, base, base].slice(0, STREAMS));
await leg("B distinct-pmt ", [base, base, base, base]
  .slice(0, STREAMS)
  .map((p, i) => `Agent ${i} ${crypto.randomUUID().slice(0, 8)}: ${p}`));

await leg("A same-prompt  ", [base, base, base, base].slice(0, STREAMS));
await leg("B distinct-pmt ", [base, base, base, base]
  .slice(0, STREAMS)
  .map((p, i) => `Agent ${i} ${crypto.randomUUID().slice(0, 8)}: ${p}`));
