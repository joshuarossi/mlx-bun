// Regenerate Qwen3.5-architecture parity goldens from the mlx-lm / OptiQ oracle.
//
//   bun scripts/regen.ts qwen-parity [38|27b|4b|moe]   (default: 38)
//
// 38 = Qwen3.8-27B (same qwen3_5 graph as 27b, current checkpoint). optiq
// has published nothing for this model → NO mixed-KV oracle: bf16 bar only
// (mixed-KV serving for 3.8 is Lab-tier, KL-gated — see PLAN.md Phase 14
// retarget). moe = Qwen3-30B-A3B (qwen3_moe, plain 4-bit, no kv_config →
// bf16 bar only), the parity target for the faithful Qwen3MoeModel port.
//
// Per parity bar (mixed-KV is generated only when the checkpoint ships
// kv_config.json — the 4B and 38 do not):
//   - bf16 KV  (KV-quant OFF) → vs stock mlx-lm  → <prefix>-parity.json + <prefix>-logits-step*.bin
//   - mixed KV (KV-quant ON)  → vs mlx-optiq     → <prefix>-kv-parity.json + <prefix>-kv-logits-step*.bin
//
// Both feed EXPLICIT token ids (no cross-stack tokenizer dependency). The
// mixed-KV path mirrors optiq serve exactly: install_mixed_kv (per-layer bits
// from kv_config.json), don't quantize empty caches, quantize populated caches
// after each model call. Logit goldens are bit-exact only on the GPU that
// produced them, so run this on the SAME machine the parity test runs on.
//
// Heavy: loads the model (38 ~17.4 GB, 27b ~15 GB, 4b ~4.5 GB). Never run
// automatically.

import { existsSync, mkdirSync } from "node:fs";
import { goldenOutDir } from "../../tests/support/goldens";
import {
  ORACLE_PYTHON,
  SNAPSHOT_QWEN3_MOE,
  SNAPSHOT_QWEN35,
  SNAPSHOT_QWEN35_4B,
  SNAPSHOT_QWEN38,
} from "../../tests/support/paths";

const MODELS: Record<string, { snapshot: string; prefix: string }> = {
  "38": { snapshot: SNAPSHOT_QWEN38, prefix: "qwen38" },
  "27b": { snapshot: SNAPSHOT_QWEN35, prefix: "qwen35" },
  "4b": { snapshot: SNAPSHOT_QWEN35_4B, prefix: "qwen35-4b" },
  moe: { snapshot: SNAPSHOT_QWEN3_MOE, prefix: "qwen3-moe" },
};
const key = (process.argv[2] ?? "38").toLowerCase();
const sel = MODELS[key];
if (!sel) throw new Error(`unknown model key ${key} (use 38 | 27b | 4b | moe)`);

const OUT = goldenOutDir();
mkdirSync(OUT, { recursive: true });

const PROMPT = "The capital of France is";
// MLX_BUN_PARITY_STEPS overrides the decode-step count (manifest records it;
// the parity test reads logit_steps from the manifest, not a constant).
const STEPS = Number(process.env.MLX_BUN_PARITY_STEPS ?? 12);
// Mixed-KV (vs optiq) only applies when the checkpoint ships kv_config.json.
const HAS_KV_CONFIG = existsSync(`${sel.snapshot}/kv_config.json`);

// mode: "bf16" (no kv quant) | "mixed" (optiq per-layer kv quant)
const PY = `
import sys, json, os
import mlx.core as mx
from mlx_lm import load
from mlx_lm.models.cache import make_prompt_cache

snap, prompt, steps, outdir, mode, base = sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4], sys.argv[5], sys.argv[6]
prefix = f"{base}-kv" if mode == "mixed" else base

quantize_cache = lambda: None
if mode == "mixed":
    from optiq.serve import _load_kv_config, install_mixed_kv
    import mlx_lm.generate as gen_mod
    install_mixed_kv(_load_kv_config(os.path.join(snap, "kv_config.json")), quantized_kv_start=0)
    quantize_cache = lambda: gen_mod.maybe_quantize_kv_cache(
        cache, quantized_kv_start=0, kv_group_size=64, kv_bits=8
    )

model, tokenizer = load(snap)
ids = tokenizer.encode(prompt)
cache = make_prompt_cache(model)

greedy = []
y = mx.array([ids])
for step in range(steps):
    logits = model(y, cache=cache)
    if step == 0:
        # Full prefill grid: logits at EVERY prompt position, not just the
        # last — catches masking/position bugs a last-position check can't.
        grid = logits[0].astype(mx.float32)
        mx.eval(grid)
        with open(f"{outdir}/{prefix}-prefill-logits.bin", "wb") as f:
            f.write(bytes(memoryview(grid)))
    last = logits[0, -1, :].astype(mx.float32)
    mx.eval(last)
    with open(f"{outdir}/{prefix}-logits-step{step}.bin", "wb") as f:
        f.write(bytes(memoryview(last)))
    quantize_cache()
    tok = mx.argmax(last).item()
    greedy.append(tok)
    y = mx.array([[tok]])

print(json.dumps({
    "snapshot": snap, "mode": mode, "prompt": prompt,
    "prompt_ids": ids, "greedy_ids": greedy, "logit_steps": steps,
    "prefill_positions": len(ids),
    "vocab_size": int(last.shape[0]),
}))
`;

async function gen(mode: "bf16" | "mixed"): Promise<void> {
  const proc = Bun.spawn(
    [ORACLE_PYTHON, "-c", PY, sel!.snapshot, PROMPT, String(STEPS), OUT, mode, sel!.prefix],
    { stdout: "pipe", stderr: "pipe" },
  );
  const [out, err, code] = await Promise.all([
    new Response(proc.stdout).text(),
    new Response(proc.stderr).text(),
    proc.exited,
  ]);
  if (code !== 0) throw new Error(`Qwen (${key}) ${mode} oracle failed (${code}):\n${err}`);
  const pfx = mode === "mixed" ? `${sel!.prefix}-kv` : sel!.prefix;
  await Bun.write(`${OUT}/${pfx}-parity.json`, JSON.stringify(JSON.parse(out), null, 1));
  console.log(`wrote ${OUT}/${pfx}-parity.json + ${pfx}-logits-step*.bin`);
}

await gen("bf16");
if (HAS_KV_CONFIG) await gen("mixed");
else console.log(`(${key}: no kv_config.json — skipping mixed-KV golden)`);
console.log(`Qwen (${key}) parity goldens regenerated.`);
