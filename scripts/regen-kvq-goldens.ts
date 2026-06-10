// Regenerate quantized-KV parity goldens from the Python oracle.
// Explicit command, never automatic:  bun scripts/regen-kvq-goldens.ts
//
// (The originals were generated ad hoc in the Phase 6 session — commit
// 6c37246 shipped goldens without keeping the script; this is the
// missing producer, brought up in Phase 10.)
//
// Reference composition (Phase 10): optiq serve installs
// fused_quant_sdpa whenever kv-quant is enabled, so the serving
// reference for quantized-cache numerics is the FUSED N-tiled path for
// L > 1. Our dispatch tiles L > 1 and keeps decode (L = 1) on the stock
// unfused port, so:
//   - single-forward (prefill) goldens: fused INSTALLED
//   - greedy trajectories: fused for the prompt forward, uninstalled
//     for the decode loop — mirrors our dispatch op-for-op. (optiq
//     itself tiles L = 1 decode too; at L = 1 that is a perf choice in
//     the reference, and our L = 1 path is the stock mlx-lm reference.)
//
// Keeps the original goldens' prompt ids (read from goldens/kv-quant.json)
// so trajectory history stays comparable across regens.
//
// Writes:
//   goldens/kv-quant.json         — prompt ids + fp16/kv8/kv4 greedy ids
//   goldens/kvq-logits-{fp16,kv8,kv4}.bin — last-position logits (f32)

import { ORACLE_PYTHON, SNAPSHOT } from "../tests/paths";

const MAX_TOKENS = 48;

const existing = (await Bun.file("goldens/kv-quant.json").json()) as {
  prompt_ids: number[];
};

const py = `
import sys, json
import mlx.core as mx
from optiq.mlx_lm_patches._register import register
register()
from mlx_lm import load
from mlx_lm.models.cache import make_prompt_cache, KVCache
from optiq.runtime.fused_quant_sdpa import install as install_fused, uninstall as uninstall_fused

snap = sys.argv[1]
ids = json.loads(sys.argv[2])
max_tokens = int(sys.argv[3])

model, tokenizer = load(snap)

def make_caches(bits):
    cache = make_prompt_cache(model)
    if bits is not None:
        # manual pre-conversion — upstream maybe_quantize_kv_cache crashes
        # on gemma4's RotatingKVCache (Phase 6 finding)
        for i, c in enumerate(cache):
            if isinstance(c, KVCache):
                cache[i] = c.to_quantized(group_size=64, bits=bits)
    return cache

out = {"prompt_ids": ids}
for key, bits in (("fp16", None), ("kv8", 8), ("kv4", 4)):
    # single-forward last-position logits from identical state (fused:
    # the prompt forward is L > 1 — the path our dispatch tiles)
    install_fused()
    cache = make_caches(bits)
    logits = model(mx.array([ids]), cache=cache)
    last = logits[0, -1, :].astype(mx.float32)
    mx.eval(last)
    with open(f"goldens/kvq-logits-{key}.bin", "wb") as f:
        f.write(bytes(memoryview(last)))
    del cache, logits, last

    # greedy trajectory: fused prefill, stock decode (our composition)
    cache = make_caches(bits)
    y = mx.array([ids])
    toks = []
    for step in range(max_tokens):
        logits = model(y, cache=cache)
        tok = int(mx.argmax(logits[0, -1, :]).item())
        if step == 0:
            uninstall_fused()
        toks.append(tok)
        y = mx.array([[tok]])
    out[key] = toks
    del cache
print(json.dumps(out))
`;

const proc = Bun.spawn(
  [ORACLE_PYTHON, "-c", py, SNAPSHOT, JSON.stringify(existing.prompt_ids), String(MAX_TOKENS)],
  { stdout: "pipe", stderr: "pipe", cwd: import.meta.dir + "/.." },
);
const [out, err, code] = await Promise.all([
  new Response(proc.stdout).text(),
  new Response(proc.stderr).text(),
  proc.exited,
]);
if (code !== 0) throw new Error(`oracle failed (${code}):\n${err}`);
await Bun.write("goldens/kv-quant.json", JSON.stringify(JSON.parse(out)));
console.log("wrote goldens/kv-quant.json + kvq-logits-{fp16,kv8,kv4}.bin");
