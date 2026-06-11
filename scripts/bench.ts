// Decode benchmark — Phase 3 exit criterion: within 5% of mlx-lm on this
// machine. Run mlx-lm's own generate for the same workload to compare:
//
//   bun scripts/bench.ts [--tokens 600] [--baseline] [--model <query>]
//                        [--prompt-tokens N] [--kv off|config|<bits>]
//
// --baseline runs the Python reference (mlx_lm.generate) instead of ours.
// --model resolves a registry query (default: the 12B oracle snapshot).

import { ORACLE_PYTHON, SNAPSHOT } from "../tests/paths";
import { peakMemory, resetPeakMemory } from "../src/mlx/ffi";

const tokensIdx = process.argv.indexOf("--tokens");
const MAX_TOKENS = tokensIdx > -1 ? Number(process.argv[tokensIdx + 1]) : 600;
const PROMPT = "Write a detailed essay about the history of computing, starting with mechanical calculators.";

const modelIdx = process.argv.indexOf("--model");
let MODEL_PATH = SNAPSHOT;
let EXPERTS_BYTES = 0;
if (modelIdx > -1) {
  const { Registry } = await import("../src/registry");
  const reg = new Registry();
  if (reg.list().length === 0) await reg.scan();
  const m = reg.resolve(process.argv[modelIdx + 1]!);
  MODEL_PATH = m.path;
  EXPERTS_BYTES = m.expertsBytes;
  reg.close();
}

// Parsed BEFORE the --baseline branch: the python reference must pad its
// prompt to the same target, or "@8k" python rows silently measure a
// ~31-token context. That exact bug shipped the original Phase 15
// matrix's @8k baseline rows (ctx=31 in the eval-DB notes) and
// fabricated the "−10% @8k decode gap" headline — found 2026-06-10
// when the cross-machine run reproduced a context-independent python
// decode rate that physics rules out.
const ptIdxEarly = process.argv.indexOf("--prompt-tokens");
const PROMPT_TOKENS_EARLY = ptIdxEarly > -1 ? Number(process.argv[ptIdxEarly + 1]) : 0;

if (process.argv.includes("--baseline")) {
  // --baseline-kv config → optiq's per-layer mixed-precision KV patch
  // (install_mixed_kv + kv args), i.e. the "optiq direct" engine row.
  const blKvIdx = process.argv.indexOf("--baseline-kv");
  const kvCfgPath =
    blKvIdx > -1 && process.argv[blKvIdx + 1] === "config"
      ? `${MODEL_PATH}/kv_config.json`
      : "";
  const py = `
import sys, time
import mlx.core as mx
from optiq.mlx_lm_patches._register import register
register()
from mlx_lm import load
from mlx_lm.generate import stream_generate

model, tokenizer = load(sys.argv[1])
user_msg = sys.argv[2]
prompt_tokens = int(sys.argv[5]) if len(sys.argv) > 5 else 0
if prompt_tokens > 0:
    # same filler + same target convention as the JS path below
    filler = ("Background context: the history of computation spans mechanical "
              "calculators, electromechanical relays, vacuum tubes, transistors, "
              "integrated circuits, and modern accelerators. ")
    while len(tokenizer.encode(user_msg)) < prompt_tokens - 24:
        user_msg = filler + user_msg
prompt = tokenizer.apply_chat_template(
    [{"role": "user", "content": user_msg}],
    tokenize=True, add_generation_prompt=True,
)
extra = {}
kvcfg = sys.argv[4] if len(sys.argv) > 4 else ""
if kvcfg:
    from optiq.serve import _load_kv_config, install_mixed_kv
    install_mixed_kv(_load_kv_config(kvcfg), 0)
    # non-None kv_bits makes the quantize hook run; the patched hook
    # ignores it and uses the per-layer map (optiq serve behavior)
    extra = dict(kv_bits=8, kv_group_size=64, quantized_kv_start=0)
# generation-only peak: python load() materializes non-lazily and its
# transient otherwise dominates peak_memory (constant 9.84 GB on the 12B
# at every context — a load figure, not a serving one)
mx.reset_peak_memory()
last = None
for r in stream_generate(model, tokenizer, prompt, max_tokens=int(sys.argv[3]), **extra):
    last = r
print(f"prompt: {last.prompt_tokens} tok @ {last.prompt_tps:.1f} tok/s")
print(f"decode: {last.generation_tokens} tok @ {last.generation_tps:.1f} tok/s")
print(f"peak mem: {last.peak_memory:.2f} GB")
`;
  const proc = Bun.spawn(
    [ORACLE_PYTHON, "-c", py, MODEL_PATH, PROMPT, String(MAX_TOKENS), kvCfgPath,
     String(PROMPT_TOKENS_EARLY)],
    { stdout: "inherit", stderr: "pipe" },
  );
  const code = await proc.exited;
  if (code !== 0) console.error(await new Response(proc.stderr).text());
  process.exit(code);
}

const { loadModelConfig } = await import("../src/config");
const { Weights } = await import("../src/weights");
const { Gemma4Model } = await import("../src/model/gemma4");
const { generate } = await import("../src/generate");
const { ChatTemplate } = await import("../src/chat-template");
const { loadTokenizer } = await import("../src/tokenizer");

const config = await loadModelConfig(MODEL_PATH);
const weights = await Weights.open(MODEL_PATH);
const model = new Gemma4Model(weights, config);
const tok = await loadTokenizer(MODEL_PATH);
const template = await ChatTemplate.load(MODEL_PATH);

// --prompt-tokens N pads the user message to ~N prompt tokens (filler
// paragraphs) for long-context KV measurements; --kv off|config|<bits>
// selects the KV scheme (default off = bf16, the historical baseline).
const ptIdx = process.argv.indexOf("--prompt-tokens");
const PROMPT_TOKENS = ptIdx > -1 ? Number(process.argv[ptIdx + 1]) : 0;
const kvIdx = process.argv.indexOf("--kv");
const KV_MODE = kvIdx > -1 ? process.argv[kvIdx + 1]! : "off";

let userMsg = PROMPT;
if (PROMPT_TOKENS > 0) {
  const filler =
    "Background context: the history of computation spans mechanical " +
    "calculators, electromechanical relays, vacuum tubes, transistors, " +
    "integrated circuits, and modern accelerators. ";
  while (tok.encode(userMsg).length < PROMPT_TOKENS - 24) userMsg = filler + userMsg;
}

const rendered = template.render([{ role: "user", content: userMsg }]);
const ids = tok.encode(rendered);
// template includes <bos>; tokenizer also prepends BOS — drop the duplicate
const promptIds = ids[0] === ids[1] && ids[0] === tok.bosTokenId ? ids.slice(1) : ids;

const kvOptions =
  KV_MODE === "config"
    ? (() => {
        if (!config.kvQuant?.length) throw new Error("model has no kv_config.json");
        return { kvConfig: config.kvQuant };
      })()
    : KV_MODE !== "off"
      ? { kvBits: Number(KV_MODE), quantizedKvStart: 0 }
      : {};

// Warmup forward (1 token over a tiny prompt, discarded): materializes
// every weight so the measured prefill timer covers PREFILL, not lazy
// weight load — python's prompt_tps starts after load(); without this
// ours read 10-24 "prefill tok/s" on short prompts (pure page-in).
{
  const wCache = model.makeCache();
  const wGen = generate(model, promptIds.slice(0, Math.min(8, promptIds.length - 1)), {
    maxTokens: 1, temperature: 0, cache: wCache,
  });
  for await (const _ of wGen) { /* discard */ }
  for (const c of wCache) c.dispose();
}
// peak from here on = GENERATION-ONLY (load/warmup transient excluded) —
// the python baseline resets after load() too, so the columns compare.
resetPeakMemory();

const gen = generate(model, promptIds, { maxTokens: MAX_TOKENS, temperature: 0, ...kvOptions });
const out: number[] = [];
for await (const t of gen) out.push(t.token);

const s = gen.stats!;
console.log(tok.decode(out, true).slice(0, 200) + "…\n");
console.log(`prompt: ${s.promptTokens} tok @ ${s.prefillTps.toFixed(1)} tok/s`);
console.log(`decode: ${s.generatedTokens} tok @ ${s.decodeTps.toFixed(1)} tok/s`);
console.log(`peak mem: ${(peakMemory() / 1e9).toFixed(2)} GB`);

// record in the eval DB with fit predictions for validation
const { EvalDB, gitCommit } = await import("../src/evaldb");
const { fit } = await import("../src/fit");
const weightsBytes = [...weights.shards.files.values()]
  .reduce((a, f) => a + f.mmap.size, 0);
const ctxTokens = s.promptTokens + s.generatedTokens;
const prediction = fit(config, weightsBytes, ctxTokens, undefined, undefined, EXPERTS_BYTES);
const db = new EvalDB();
db.record({
  modelPath: MODEL_PATH,
  commitSha: gitCommit(),
  promptTokens: s.promptTokens,
  cachedTokens: s.cachedTokens,
  generatedTokens: s.generatedTokens,
  prefillTps: s.prefillTps,
  decodeTps: s.decodeTps,
  peakBytes: peakMemory(),
  predictedPeakBytes: prediction.totalBytes,
  predictedDecodeTps: prediction.predictedDecodeTps,
  notes: `bench.ts ${MAX_TOKENS}tok kv=${KV_MODE}${PROMPT_TOKENS ? ` ctx=${s.promptTokens}` : ""}`,
});
console.log(
  `recorded (predicted: ${prediction.predictedDecodeTps.toFixed(1)} tok/s, ` +
  `${(prediction.totalBytes / 1e9).toFixed(2)} GB peak)`,
);
