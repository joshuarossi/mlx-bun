// Paired MTP-on/off A/B for Qwen3.8-27B + its native MTP head (PLAN 14g TPS
// item). Interleaved arms (off,on ×R) so machine drift cancels; asserts the
// two arms stay token-identical every repeat (losslessness re-checked in
// passing). Decode tok/s is wall-clock over the generated tokens after the
// first (prefill-bound) token. Run on a QUIET box; absolute numbers from a
// loaded machine are garbage (dirty-machine doctrine).
//
//   bun scripts/experiments/qwen38-mtp-ab.ts [maxTokens=128] [repeats=3]

import { SNAPSHOT_QWEN38, SNAPSHOT_QWEN38_MTP } from "../../tests/paths";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { Qwen35Model } from "../../src/model/qwen3_5";
import { setMemoryLimit } from "../../src/mlx/ffi";
import { generate } from "../../src/generate";
import { specServeRun } from "../../src/spec/serve-loop";
import { QwenMtpProvider } from "../../src/spec/qwen-mtp-source";
import { loadTokenizer } from "../../src/tokenizer";
import { ChatTemplate } from "../../src/chat-template";

const MAX_TOKENS = Number(process.argv[2] ?? 128);
const REPEATS = Number(process.argv[3] ?? 3);

setMemoryLimit(23_000_000_000);
const config = await loadModelConfig(SNAPSHOT_QWEN38);
const model = new Qwen35Model(await Weights.open(SNAPSHOT_QWEN38), config);
const provider = await QwenMtpProvider.load(SNAPSHOT_QWEN38_MTP);
const tok = await loadTokenizer(SNAPSHOT_QWEN38);
const template = await ChatTemplate.load(SNAPSHOT_QWEN38);

const PROMPT =
  "Write a step-by-step explanation of how a refrigerator keeps food cold, " +
  "in numbered steps, plain language.";
const rendered = template.render([{ role: "user", content: PROMPT }], { enableThinking: false });
const idsAll = tok.encode(rendered);
const ids = idsAll[0] === idsAll[1] && idsAll[0] === tok.bosTokenId ? idsAll.slice(1) : idsAll;

interface ArmResult { tokens: number[]; decodeTps: number; note: string }

async function armOff(): Promise<ArmResult> {
  const t0 = performance.now();
  let firstAt = 0;
  const out: number[] = [];
  for await (const t of generate(model, ids, { maxTokens: MAX_TOKENS, temperature: 0 })) {
    if (out.length === 0) firstAt = performance.now();
    out.push(t.token);
  }
  const decodeMs = performance.now() - firstAt;
  return {
    tokens: out,
    decodeTps: ((out.length - 1) / Math.max(decodeMs, 1e-6)) * 1000,
    note: "",
  };
}

async function armOn(): Promise<ArmResult> {
  const out: number[] = [];
  const stats = await specServeRun(
    model, provider, 2, ids,
    { maxTokens: MAX_TOKENS, temperature: 0 },
    (token: number) => { out.push(token); },
  );
  const s = stats.spec!;
  return {
    tokens: out,
    decodeTps: stats.decodeTps,
    note: `accept ${s.accepted}/${s.drafted} (${((s.accepted / Math.max(s.drafted, 1)) * 100).toFixed(0)}%), ` +
      `tok/fwd ${(out.length / Math.max(s.targetCalls - 1, 1)).toFixed(2)}, rounds ${s.rounds}`,
  };
}

console.log(`prompt ${ids.length} tok, maxTokens ${MAX_TOKENS}, repeats ${REPEATS} (interleaved off,on)`);
const offTps: number[] = [];
const onTps: number[] = [];
let refTokens: number[] | null = null;
for (let r = 1; r <= REPEATS; r++) {
  const off = await armOff();
  const on = await armOn();
  if (!refTokens) refTokens = off.tokens;
  const offSame = JSON.stringify(off.tokens) === JSON.stringify(refTokens);
  const onSame = JSON.stringify(on.tokens) === JSON.stringify(refTokens);
  offTps.push(off.decodeTps);
  onTps.push(on.decodeTps);
  console.log(
    `r${r}  OFF ${off.decodeTps.toFixed(2)} tok/s ${offSame ? "" : "TOKENS-DIVERGED!"}  |  ` +
    `ON ${on.decodeTps.toFixed(2)} tok/s ${onSame ? "" : "TOKENS-DIVERGED!"}  ${on.note}`,
  );
}
const med = (a: number[]) => [...a].sort((x, y) => x - y)[Math.floor(a.length / 2)]!;
const spread = (a: number[]) =>
  ((Math.max(...a) - Math.min(...a)) / med(a) * 100).toFixed(1);
console.log(
  `median  OFF ${med(offTps).toFixed(2)} tok/s (spread ${spread(offTps)}%)  |  ` +
  `ON ${med(onTps).toFixed(2)} tok/s (spread ${spread(onTps)}%)  |  ` +
  `ratio ON/OFF ${(med(onTps) / med(offTps)).toFixed(3)}`,
);
