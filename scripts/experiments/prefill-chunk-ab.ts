// One-off (2026-08-22 prefill-vs-mlx-lm analysis): isolate whether the 12B
// prefill deficit vs mlx-lm @4k/8k is per-chunk boundary cost or intra-chunk
// compute. Sweeps the prefill chunk size at a fixed ~8k prompt on BOTH
// stacks, timing drain+step-0 only (no decode). Fresh caches per rep;
// one throwaway rep per chunk size absorbs shape-keyed kernel compile.
//
//   bun scripts/experiments/prefill-chunk-ab.ts [--model <query>] [--ctx N]
//
// Conventions mirror scripts/bench.ts (same filler padding + chat template),
// so numbers are comparable with today's bench.ts matrix rows.

const MODEL_QUERY_IDX = process.argv.indexOf("--model");
const MODEL_QUERY = MODEL_QUERY_IDX > -1 ? process.argv[MODEL_QUERY_IDX + 1]! : "12B-it-OptiQ";
const CTX_IDX = process.argv.indexOf("--ctx");
const CTX = CTX_IDX > -1 ? Number(process.argv[CTX_IDX + 1]) : 8192;
const CHUNK_SIZES = [512, 1024, 2048];
const REPS = 2;

import { ORACLE_PYTHON } from "../../tests/paths";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { generate } from "../../src/generate";
import { ChatTemplate } from "../../src/chat-template";
import { loadTokenizer } from "../../src/tokenizer";

function paddedUserMessage(tokenizer: { encode(s: string): ArrayLike<number> }): string {
  let userMsg =
    "Write a detailed essay about the history of computing, starting with mechanical calculators.";
  const filler =
    "Background context: the history of computation spans mechanical " +
    "calculators, electromechanical relays, vacuum tubes, transistors, " +
    "integrated circuits, and modern accelerators. ";
  while (tokenizer.encode(userMsg).length < CTX - 24) userMsg = filler + userMsg;
  return userMsg;
}

if (process.argv.includes("--baseline")) {
  // python arm: manual drain loop mirroring mlx_lm generate.py:427-467
  // (chunked drain to len-1, eval cache states per chunk, clear_cache,
  // step-0 forward of the last token), timed around wall clock.
  const py = `
import sys, time
import mlx.core as mx
from optiq.mlx_lm_patches._register import register
register()
from mlx_lm import load
from mlx_lm.models.cache import make_prompt_cache

model, tokenizer = load(sys.argv[1])
target = int(sys.argv[2])
user_msg = sys.argv[3]
filler = ("Background context: the history of computation spans mechanical "
          "calculators, electromechanical relays, vacuum tubes, transistors, "
          "integrated circuits, and modern accelerators. ")
while len(tokenizer.encode(user_msg)) < target - 24:
    user_msg = filler + user_msg
prompt = tokenizer.apply_chat_template(
    [{"role": "user", "content": user_msg}],
    tokenize=True, add_generation_prompt=True,
)
sizes = [int(s) for s in sys.argv[4].split(",")]
reps = int(sys.argv[5])
for step in sizes:
    for rep in range(reps + 1):   # rep 0 = throwaway (compile per shape)
        cache = make_prompt_cache(model)
        processed = 0
        t0 = time.perf_counter()
        while len(prompt) - processed > 1:
            remaining = (len(prompt) - processed) - 1
            n = min(step, remaining)
            model(mx.array(prompt[processed : processed + n])[None], cache=cache)
            mx.eval([c.state for c in cache])
            processed += n
            mx.clear_cache()
        y = model(mx.array(prompt[processed:])[None], cache=cache)
        mx.eval(y)
        dt = time.perf_counter() - t0
        if rep > 0:
            print(f"PY step={step} rep={rep} tokens={len(prompt)} prefill_tps={len(prompt)/dt:.1f}")
`;
  const { Registry } = await import("../../src/registry");
  const reg = new Registry();
  if (reg.list().length === 0) await reg.scan();
  const m = reg.resolve(MODEL_QUERY);
  reg.close();
  // pad the message in JS so both arms use identical text
  const tok = await loadTokenizer(m.path);
  const msg = paddedUserMessage(tok as never);
  const proc = Bun.spawn(
    [ORACLE_PYTHON, "-c", py, m.path, String(CTX), msg, CHUNK_SIZES.join(","), String(REPS)],
    { stdout: "inherit", stderr: "inherit" },
  );
  process.exit(await proc.exited);
}

// ---- bun arm ----
const { Registry } = await import("../../src/registry");
const reg = new Registry();
if (reg.list().length === 0) await reg.scan();
const m = reg.resolve(MODEL_QUERY);
reg.close();
const cfg = await loadModelConfig(m.path);
const weights = await Weights.open(m.path);
const model = createModel(weights, cfg);
const tok = await loadTokenizer(m.path);
const template = await ChatTemplate.load(m.path);

const rendered = template.render([{ role: "user", content: paddedUserMessage(tok) }]);
const idsAll = tok.encode(rendered);
const promptIds =
  idsAll[0] === idsAll[1] && idsAll[0] === tok.bosTokenId ? idsAll.slice(1) : idsAll;

// --warmup: replicate scripts/bench.ts's exact pre-measurement block
// (8-token warmup generate, cache dispose, peak-memory reset) to bisect
// why fresh-process bench.ts reads slower than this harness's cold rep.
if (process.argv.includes("--warmup")) {
  const { resetPeakMemory } = await import("../../src/mlx/ffi");
  const wCache = model.makeCache();
  const wGen = generate(model, promptIds.slice(0, Math.min(8, promptIds.length - 1)), {
    maxTokens: 1, temperature: 0, cache: wCache,
  });
  for await (const _ of wGen) { /* discard */ }
  for (const c of wCache) c.dispose();
  resetPeakMemory();
}

for (const chunk of CHUNK_SIZES) {
  for (let rep = 0; rep <= REPS; rep++) {
    const gen = generate(model, promptIds, {
      maxTokens: 1,
      temperature: 0,
      prefillChunkSize: chunk,
    });
    for await (const _ of gen) { /* single token */ }
    const s = gen.stats!;
    const tag = rep === 0 ? "cold" : `rep=${rep}`; // rep0 ≈ fresh-process state
    console.log(
      `BUN chunk=${chunk} ${tag} tokens=${s.promptTokens} prefill_tps=${s.prefillTps.toFixed(1)}`,
    );
  }
}

// --twice: fresh-process warm-in probe — two measured 2048-chunked prefills
// back-to-back in THIS process (default arm above already ran them, but the
// dedicated flag documents intent when called standalone with CHUNK_SIZES
// trimmed). Reads off the default arm output instead; kept for clarity.


