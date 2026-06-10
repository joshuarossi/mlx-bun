// Regenerate Phase 2 logit-parity goldens from the Python oracle.
// Explicit command, never automatic:  bun scripts/regen-parity-goldens.ts
//
// Writes to the machine-specific golden dir (goldenOutDir(): the flat
// reference set on the reference box, goldens/<machine-key>/ elsewhere —
// logit goldens are bit-exact only on the GPU that produced them):
//   <out>/parity.json          — prompt ids, 100 greedy ids, per-step argmax
//   <out>/logits-step<i>.bin   — full last-position logits (f32) for the
//                                first LOGIT_STEPS decode steps

import { ORACLE_PYTHON, SNAPSHOT } from "../tests/paths";
import { goldenOutDir } from "../tests/goldens";
import { mkdirSync } from "node:fs";

const OUT = goldenOutDir();
mkdirSync(OUT, { recursive: true });

const PROMPT = "The capital of France is";
const MAX_TOKENS = 100;
const LOGIT_STEPS = 4;

const py = `
import sys, json
import mlx.core as mx
from optiq.mlx_lm_patches._register import register
register()  # maps gemma4_unified -> mlx-lm's gemma4 classes
from mlx_lm import load
from mlx_lm.models.cache import make_prompt_cache

snap, prompt, max_tokens, logit_steps, outdir = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4]), sys.argv[5]
model, tokenizer = load(snap)
ids = tokenizer.encode(prompt)

cache = make_prompt_cache(model)
greedy = []
step_argmax = []
y = mx.array([ids])
for step in range(max_tokens):
    logits = model(y, cache=cache)
    last = logits[0, -1, :].astype(mx.float32)
    mx.eval(last)
    if step < logit_steps:
        with open(f"{outdir}/logits-step{step}.bin", "wb") as f:
            f.write(bytes(memoryview(last)))
    tok = mx.argmax(last).item()
    step_argmax.append(tok)
    greedy.append(tok)
    y = mx.array([[tok]])

out = {
    "prompt": prompt,
    "prompt_ids": ids,
    "greedy_ids": greedy,
    "logit_steps": logit_steps,
    "vocab_size": int(last.shape[0]),
}
print(json.dumps(out))
`;

const proc = Bun.spawn(
  [ORACLE_PYTHON, "-c", py, SNAPSHOT, PROMPT, String(MAX_TOKENS), String(LOGIT_STEPS), OUT],
  { stdout: "pipe", stderr: "pipe" },
);
const [out, err, code] = await Promise.all([
  new Response(proc.stdout).text(),
  new Response(proc.stderr).text(),
  proc.exited,
]);
if (code !== 0) throw new Error(`oracle failed (${code}):\n${err}`);
await Bun.write(`${OUT}/parity.json`, JSON.stringify(JSON.parse(out), null, 1));
console.log(`wrote ${OUT}/parity.json + logits-step*.bin`);
