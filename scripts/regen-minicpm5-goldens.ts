// Regenerate MiniCPM5-1B llama-family goldens from the Python oracle.
// Explicit command:
//   MLX_BUN_ORACLE_VENV=/Users/joshrossi/Code/mlx-lm-example/.venv \
//     bun scripts/regen-minicpm5-goldens.ts
//
// Writes:
//   <goldenOutDir>/minicpm5-parity.json
//   <goldenOutDir>/minicpm5-logits-step<i>.bin

import { mkdirSync } from "node:fs";
import { goldenOutDir } from "../tests/goldens";
import { ORACLE_PYTHON, SNAPSHOT_MINICPM5 } from "../tests/paths";

const OUT = goldenOutDir();
mkdirSync(OUT, { recursive: true });

const PROMPT = "The capital of France is";
const MAX_TOKENS = 100;
const LOGIT_STEPS = MAX_TOKENS;

const py = `
import sys, json
import mlx.core as mx
from mlx_lm import load
from mlx_lm.models.cache import make_prompt_cache

snap, prompt, max_tokens, logit_steps, outdir = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4]), sys.argv[5]
model, tokenizer = load(snap)
ids = tokenizer.encode(prompt)

cache = make_prompt_cache(model)
greedy = []
y = mx.array([ids])
for step in range(max_tokens):
    logits = model(y, cache=cache)
    last = logits[0, -1, :].astype(mx.float32)
    mx.eval(last)
    if step < logit_steps:
        with open(f"{outdir}/minicpm5-logits-step{step}.bin", "wb") as f:
            f.write(bytes(memoryview(last)))
    tok = mx.argmax(last).item()
    greedy.append(tok)
    y = mx.array([[tok]])

out = {
    "model": "mlx-community/MiniCPM5-1B-OptiQ-4bit",
    "snapshot": snap,
    "prompt": prompt,
    "prompt_ids": ids,
    "greedy_ids": greedy,
    "logit_steps": logit_steps,
    "vocab_size": int(last.shape[0]),
}
print(json.dumps(out))
`;

const proc = Bun.spawn(
  [ORACLE_PYTHON, "-c", py, SNAPSHOT_MINICPM5, PROMPT, String(MAX_TOKENS), String(LOGIT_STEPS), OUT],
  { stdout: "pipe", stderr: "pipe" },
);
const [out, err, code] = await Promise.all([
  new Response(proc.stdout).text(),
  new Response(proc.stderr).text(),
  proc.exited,
]);
if (code !== 0) throw new Error(`MiniCPM5 oracle failed (${code}):\n${err}`);
await Bun.write(`${OUT}/minicpm5-parity.json`, JSON.stringify(JSON.parse(out), null, 1));
console.log(`wrote ${OUT}/minicpm5-parity.json + minicpm5-logits-step*.bin`);
