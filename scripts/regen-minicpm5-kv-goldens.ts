// Regenerate MiniCPM5 mixed-KV goldens from the OptiQ/MLX oracle.
// This mirrors optiq serve's mixed-kv order: do not quantize empty caches;
// quantize populated caches after each model call.

import { mkdirSync } from "node:fs";
import { goldenOutDir } from "../tests/goldens";
import { ORACLE_PYTHON, SNAPSHOT_MINICPM5 } from "../tests/paths";

const OUT = goldenOutDir();
mkdirSync(OUT, { recursive: true });

const PROMPT = "The capital of France is";
const MAX_TOKENS = 100;
const LOGIT_STEPS = MAX_TOKENS;

const py = `
import sys, json, os
import mlx.core as mx
from mlx_lm import load
from mlx_lm.models.cache import make_prompt_cache
from optiq.serve import _load_kv_config, install_mixed_kv
import mlx_lm.generate as gen_mod

snap, prompt, max_tokens, logit_steps, outdir = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4]), sys.argv[5]
kv_path = os.path.join(snap, "kv_config.json")
install_mixed_kv(_load_kv_config(kv_path), quantized_kv_start=0)

model, tokenizer = load(snap)
ids = tokenizer.encode(prompt)
cache = make_prompt_cache(model)

def quantize_cache():
    gen_mod.maybe_quantize_kv_cache(cache, quantized_kv_start=0, kv_group_size=64, kv_bits=8)

greedy = []
y = mx.array([ids])
for step in range(max_tokens):
    logits = model(y, cache=cache)
    last = logits[0, -1, :].astype(mx.float32)
    mx.eval(last)
    if step < logit_steps:
        with open(f"{outdir}/minicpm5-kv-logits-step{step}.bin", "wb") as f:
            f.write(bytes(memoryview(last)))
    quantize_cache()
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
if (code !== 0) throw new Error(`MiniCPM5 mixed-KV oracle failed (${code}):\n${err}`);
await Bun.write(`${OUT}/minicpm5-kv-parity.json`, JSON.stringify(JSON.parse(out), null, 1));
console.log(`wrote ${OUT}/minicpm5-kv-parity.json + minicpm5-kv-logits-step*.bin`);
