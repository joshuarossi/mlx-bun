// Regenerate 26B-A4B MoE logit-parity goldens from the Python oracle.
// Explicit command, never automatic:  bun scripts/regen-parity-goldens-26b.ts
//
// Tier-d contract (PLAN testing strategy): bit-exact single-forward logits
// with explicit gate tie-break handling. Chat-templated prompt (Phase 6
// finding: non-templated goldens are useless for quality judgments).
//
// Writes to the machine-specific golden dir (goldenOutDir(): flat reference
// set on the reference box, goldens/<machine-key>/ elsewhere):
//   <out>/parity-26b.json          — prompt ids, greedy ids, per-step argmax
//   <out>/logits-26b-step<i>.bin   — full last-position logits (f32)
//   <out>/logits-26b-kvmix.bin     — mixed-precision KV single-forward logits

import { ORACLE_PYTHON, SNAPSHOT_26B } from "../tests/paths";
import { goldenOutDir } from "../tests/goldens";
import { mkdirSync } from "node:fs";

const OUT = goldenOutDir();
mkdirSync(OUT, { recursive: true });

const USER_MSG = "Name the four largest moons of Jupiter.";
const MAX_TOKENS = 16;
const LOGIT_STEPS = 4;

const py = `
import sys, json
import mlx.core as mx
from optiq.mlx_lm_patches._register import register
register()
from mlx_lm import load
from mlx_lm.models.cache import make_prompt_cache, KVCache

snap, user_msg, max_tokens, logit_steps, outdir = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4]), sys.argv[5]
model, tokenizer = load(snap)
ids = tokenizer.apply_chat_template(
    [{"role": "user", "content": user_msg}], add_generation_prompt=True
)

# Mixed-precision KV single-forward golden: pre-convert full-attention
# caches per kv_config.json (manual conversion — upstream's
# maybe_quantize_kv_cache crashes on gemma4's RotatingKVCache; Phase 6
# finding). Sliding caches stay bf16, matching our Phase-9 scope.
# Fused N-tiled SDPA installed for this leg (Phase 10): the serving
# reference for quantized-cache prefill is optiq-with-fused, and our
# L>1 dispatch matches it. Uninstalled before the stock greedy legs.
from optiq.runtime.fused_quant_sdpa import install as install_fused, uninstall as uninstall_fused
install_fused()
kv_cfg = {e["layer_idx"]: e for e in json.load(open(snap + "/kv_config.json"))}
mixed_cache = make_prompt_cache(model)
mixed_applied = {}
for i, c in enumerate(mixed_cache):
    if isinstance(c, KVCache) and i in kv_cfg:
        e = kv_cfg[i]
        mixed_cache[i] = c.to_quantized(group_size=e.get("group_size", 64), bits=e["bits"])
        mixed_applied[i] = e["bits"]
logits = model(mx.array([ids]), cache=mixed_cache)
last = logits[0, -1, :].astype(mx.float32)
mx.eval(last)
with open(f"{outdir}/logits-26b-kvmix.bin", "wb") as f:
    f.write(bytes(memoryview(last)))
del mixed_cache
uninstall_fused()

cache = make_prompt_cache(model)
greedy = []
y = mx.array([ids])
for step in range(max_tokens):
    logits = model(y, cache=cache)
    last = logits[0, -1, :].astype(mx.float32)
    mx.eval(last)
    if step < logit_steps:
        with open(f"{outdir}/logits-26b-step{step}.bin", "wb") as f:
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
    "kv_mixed_layers": {str(k): v for k, v in mixed_applied.items()},
}
print(json.dumps(out))
`;

const proc = Bun.spawn(
  [ORACLE_PYTHON, "-c", py, SNAPSHOT_26B, USER_MSG, String(MAX_TOKENS), String(LOGIT_STEPS), OUT],
  { stdout: "pipe", stderr: "pipe" },
);
const [out, err, code] = await Promise.all([
  new Response(proc.stdout).text(),
  new Response(proc.stderr).text(),
  proc.exited,
]);
if (code !== 0) throw new Error(`oracle failed (${code}):\n${err}`);
await Bun.write(`${OUT}/parity-26b.json`, JSON.stringify(JSON.parse(out), null, 1));
console.log(`wrote ${OUT}/parity-26b.json + logits-26b-step*.bin`);
