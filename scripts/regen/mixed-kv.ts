// Regenerate PER-LAYER MIXED (kv_config.json) quantized-KV parity goldens
// from the Python oracle — the comparison-2 gap closer (before this, mixed-KV
// bit parity was only verified ours-fast vs ours-monolith, and the config
// path was compared against the UNIFORM kv4 golden). Explicit command, never
// automatic:
//   bun scripts/regen.ts mixed-kv
//
// Reference composition — the MIXED path differs from regen-kvq-goldens.ts's
// uniform one, mirroring optiq's install_mixed_kv hook (and our
// maybeQuantizeKv, which copies it) AT THE ORACLE'S SERVE-LOOP GEOMETRY
// (re-anchored 2026-07-07 with the prefill tail-split fix):
//   1. the prompt prefill runs BF16 over ids[:-1] — mlx-lm generate_step
//      drains the prompt to len-1 (generate.py:430-453); the hook skips
//      empty caches, so conversion happens at this first chunk boundary,
//   2. the populated caches are converted per kv_config.json — BOTH
//      full-attention KVCache and sliding RotatingKVCache (Phase 9;
//      patch_rotating_to_quantized supplies rotating to_quantized), each
//      with its own bits/group_size,
//   3. step-0 logits come from an L=1 forward of the LAST prompt token
//      (oracle _step; its KV lands in the already-quantized caches),
//   4. decode runs stock UNFUSED quantized SDPA (mlx-lm base.py — our L = 1
//      dispatch; fused N-tiled only covers L > 1, which mixed never re-hits
//      in this single-prompt scenario).
// The hook decides WHICH bits per layer at quantize time; converting
// manually with the same map at the same boundary reproduces the oracle
// generation loop's numerics exactly.
//
// Prompt ids are reused from goldens/kv-quant.json so trajectory history
// stays comparable across schemes.
//
// Writes to goldenOutDir():
//   <out>/mixed-kv.json              — prompt ids + 48 greedy ids + layer map
//   <out>/mixedkv-logits-step<i>.bin — last-position logits (f32) for decode
//                                      steps 0..3 (step 0 = bf16 prefill
//                                      output; 1..3 read quantized caches)

import { ORACLE_PYTHON, SNAPSHOT } from "../../tests/support/paths";
import { goldenAt, goldenOutDir } from "../../tests/support/goldens";
import { mkdirSync } from "node:fs";
import { resolve } from "node:path";

const OUT = goldenOutDir();
mkdirSync(OUT, { recursive: true });

const MAX_TOKENS = 48;
const LOGIT_STEPS = 4;

// --model <snapshot dir> --name <suffix>: generate the golden for another
// model (Phase 3.1 needs a cpm5 golden — its kv_config is all-full-attention,
// the P1 batchable set). Default: the 12B reference snapshot, original names.
const argOf = (n: string): string | null => {
  const i = process.argv.indexOf(`--${n}`);
  return i > -1 ? process.argv[i + 1]! : null;
};
const MODEL = argOf("model") ?? SNAPSHOT;
const NAME = argOf("name"); // e.g. "cpm" → mixed-kv-cpm.json + mixedkv-cpm-logits-step*.bin
const JSON_NAME = NAME ? `mixed-kv-${NAME}.json` : "mixed-kv.json";
const BIN_PREFIX = NAME ? `mixedkv-${NAME}-logits-step` : "mixedkv-logits-step";

// Prompt ids: the default (12B) reuses kv-quant.json's ids for cross-scheme
// comparability; other models tokenize the standard essay prompt themselves
// (ids are tokenizer-specific).
const existing = NAME
  ? { prompt_ids: [] as number[] }
  : ((await goldenAt("kv-quant.json").json()) as { prompt_ids: number[] });

const py = `
import sys, json, hashlib, os
import mlx.core as mx
from optiq.mlx_lm_patches._register import register
register()
import mlx_lm
import optiq
from mlx_lm import load
from mlx_lm.models.cache import make_prompt_cache, KVCache, RotatingKVCache
from optiq.runtime.kv.rotating import patch_rotating_to_quantized

snap = sys.argv[1]
ids = json.loads(sys.argv[2])
max_tokens = int(sys.argv[3])
logit_steps = int(sys.argv[4])
outdir = sys.argv[5]
bin_prefix = sys.argv[6]

with open(f"{snap}/kv_config.json") as f:
    entries = json.load(f)
by_layer = {int(e["layer_idx"]): (int(e["bits"]), int(e.get("group_size", 64))) for e in entries}

patch_rotating_to_quantized()  # gives RotatingKVCache.to_quantized (Phase 9)
model, tokenizer = load(snap)

cache = make_prompt_cache(model)
logit_sha256 = []

def dump(last, step):
    data = bytes(memoryview(last))
    with open(f"{outdir}/{bin_prefix}{step}.bin", "wb") as f:
        f.write(data)
    logit_sha256.append(hashlib.sha256(data).hexdigest())

if not ids:
    ids = tokenizer.apply_chat_template(
        [{"role": "user", "content": "Write a detailed essay about the history of computing, starting with mechanical calculators."}],
        tokenize=True, add_generation_prompt=True,
    )

# 1. bf16 prefill of ids[:-1] — the ORACLE SERVE-LOOP convention (mlx-lm
#    0.31.3 generate_step drains the prompt to len-1, generate.py:430-453;
#    its server's batched engine forces a final 1-token segment). The mixed
#    hook fires at the first non-empty chunk boundary, i.e. HERE.
model(mx.array([ids[:-1]]), cache=cache)

# 2. quantize the POPULATED caches per the per-layer map (mixed hook semantics)
for i, c in enumerate(cache):
    if i in by_layer and isinstance(c, (KVCache, RotatingKVCache)):
        bits, group = by_layer[i]
        cache[i] = c.to_quantized(group_size=group, bits=bits)

# 3. step-0 logits from an L=1 forward of the LAST prompt token — its KV is
#    written into the already-quantized caches, exactly like _step in the
#    oracle's generation loop (and our tail-split prefill, 2026-07-07).
logits = model(mx.array([[ids[-1]]]), cache=cache)
last = logits[0, -1, :].astype(mx.float32)
mx.eval(last)
dump(last, 0)
toks = [int(mx.argmax(last).item())]

# 4. stock unfused quantized decode (mlx-lm base.py = our L=1 dispatch)
y = mx.array([[toks[0]]])
for step in range(1, max_tokens):
    logits = model(y, cache=cache)
    last = logits[0, -1, :].astype(mx.float32)
    mx.eval(last)
    if step < logit_steps:
        dump(last, step)
    tok = int(mx.argmax(last).item())
    toks.append(tok)
    y = mx.array([[tok]])

print(json.dumps({
    "oracle": {
        "mlx": mx.__version__,
        "mlx_lm": mlx_lm.__version__,
        "optiq": optiq.__version__,
        "model_revision": os.path.basename(os.path.realpath(snap)),
        "generator": "scripts/regen.ts mixed-kv",
    },
    "prompt_ids": ids, "mixed": toks, "logit_steps": logit_steps,
    "layers": sorted(by_layer), "logit_sha256": logit_sha256,
}))
`;

const proc = Bun.spawn(
  [ORACLE_PYTHON, "-c", py, MODEL, JSON.stringify(existing.prompt_ids),
   String(MAX_TOKENS), String(LOGIT_STEPS), resolve(OUT), BIN_PREFIX],
  { stdout: "pipe", stderr: "pipe" },
);
const [out, err, code] = await Promise.all([
  new Response(proc.stdout).text(),
  new Response(proc.stderr).text(),
  proc.exited,
]);
if (code !== 0) throw new Error(`oracle failed (${code}):\n${err.slice(-2000)}`);
await Bun.write(`${OUT}/${JSON_NAME}`, JSON.stringify(JSON.parse(out)));
console.log(`wrote ${OUT}/${JSON_NAME} + ${BIN_PREFIX}*.bin`);
