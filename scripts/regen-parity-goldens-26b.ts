// Regenerate 26B-A4B MoE logit-parity goldens from the Python oracle.
// Explicit command, never automatic:  bun scripts/regen-parity-goldens-26b.ts
//
// Tier-d contract (PLAN testing strategy): bit-exact single-forward logits
// with explicit gate tie-break handling. Chat-templated prompt (Phase 6
// finding: non-templated goldens are useless for quality judgments).
//
// Writes:
//   goldens/parity-26b.json          — prompt ids, greedy ids, per-step argmax
//   goldens/logits-26b-step<i>.bin   — full last-position logits (f32)

import { ORACLE_PYTHON, SNAPSHOT_26B } from "../tests/paths";

const USER_MSG = "Name the four largest moons of Jupiter.";
const MAX_TOKENS = 16;
const LOGIT_STEPS = 4;

const py = `
import sys, json
import mlx.core as mx
from optiq.mlx_lm_patches._register import register
register()
from mlx_lm import load
from mlx_lm.models.cache import make_prompt_cache

snap, user_msg, max_tokens, logit_steps = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
model, tokenizer = load(snap)
ids = tokenizer.apply_chat_template(
    [{"role": "user", "content": user_msg}], add_generation_prompt=True
)

cache = make_prompt_cache(model)
greedy = []
y = mx.array([ids])
for step in range(max_tokens):
    logits = model(y, cache=cache)
    last = logits[0, -1, :].astype(mx.float32)
    mx.eval(last)
    if step < logit_steps:
        with open(f"goldens/logits-26b-step{step}.bin", "wb") as f:
            f.write(bytes(memoryview(last)))
    tok = mx.argmax(last).item()
    greedy.append(tok)
    if tok in (tokenizer.eos_token_ids if hasattr(tokenizer, "eos_token_ids") else [tokenizer.eos_token_id]):
        break
    y = mx.array([[tok]])

out = {
    "user_msg": user_msg,
    "prompt_ids": [int(i) for i in ids],
    "greedy_ids": greedy,
    "logit_steps": logit_steps,
    "vocab_size": int(last.shape[0]),
    "text": tokenizer.decode(greedy),
}
print(json.dumps(out))
`;

const proc = Bun.spawn(
  [ORACLE_PYTHON, "-c", py, SNAPSHOT_26B, USER_MSG, String(MAX_TOKENS), String(LOGIT_STEPS)],
  { stdout: "pipe", stderr: "pipe" },
);
const [out, err, code] = await Promise.all([
  new Response(proc.stdout).text(),
  new Response(proc.stderr).text(),
  proc.exited,
]);
if (code !== 0) throw new Error(`oracle failed (${code}):\n${err}`);
await Bun.write("goldens/parity-26b.json", JSON.stringify(JSON.parse(out), null, 1));
console.log("wrote goldens/parity-26b.json + logits-26b-step*.bin");
