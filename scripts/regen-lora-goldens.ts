// Regenerate LoRA adapter-applied parity goldens from the Python oracle.
// Explicit command, never automatic:  bun scripts/regen-lora-goldens.ts
//
// Oracle composition is mlx-lm's load(adapter_path=...) → LoRALinear
// (`y + (scale·z).astype(x.dtype)`), the same form as optiq apply.py and
// what the adapters were trained behind. optiq mount.py's uncast-f32 add
// is a documented divergence we do NOT follow.
//
// Writes per adapter {upper,french}:
//   goldens/lora-<id>.json        — prompt ids, greedy prefix
//   goldens/lora-<id>-logits.bin  — step-0 last-position logits (f32)

import { ORACLE_PYTHON } from "../tests/paths";

const E4B = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/fcdb12d740cd813634064567fc7cb51159b34253`;
const ADAPTERS = {
  upper: "fixtures/adapters/upper",
  french: "fixtures/adapters/french",
};
const USER_MSG = "What color is the sky?";
const GREEDY_STEPS = 12;

const py = `
import sys, json
import mlx.core as mx
from optiq.mlx_lm_patches._register import register
register()
from mlx_lm import load
from mlx_lm.models.cache import make_prompt_cache

snap, adapter_dir, adapter_id, user_msg, steps = (
    sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], int(sys.argv[5])
)
model, tokenizer = load(snap, adapter_path=adapter_dir)
ids = tokenizer.apply_chat_template(
    [{"role": "user", "content": user_msg}], add_generation_prompt=True
)
cache = make_prompt_cache(model)
greedy = []
y = mx.array([ids])
for step in range(steps):
    logits = model(y, cache=cache)
    last = logits[0, -1, :].astype(mx.float32)
    mx.eval(last)
    if step == 0:
        with open(f"goldens/lora-{adapter_id}-logits.bin", "wb") as f:
            f.write(bytes(memoryview(last)))
    tok = mx.argmax(last).item()
    greedy.append(tok)
    y = mx.array([[tok]])

print(json.dumps({
    "adapter": adapter_id,
    "prompt_ids": [int(i) for i in ids],
    "greedy_ids": greedy,
    "text": tokenizer.decode(greedy),
}))
`;

for (const [id, dir] of Object.entries(ADAPTERS)) {
  const proc = Bun.spawn(
    [ORACLE_PYTHON, "-c", py, E4B, dir, id, USER_MSG, String(GREEDY_STEPS)],
    { stdout: "pipe", stderr: "pipe" },
  );
  const [out, err, code] = await Promise.all([
    new Response(proc.stdout).text(),
    new Response(proc.stderr).text(),
    proc.exited,
  ]);
  if (code !== 0) throw new Error(`oracle failed for ${id} (${code}):\n${err}`);
  await Bun.write(`goldens/lora-${id}.json`, JSON.stringify(JSON.parse(out), null, 1));
  console.log(`wrote goldens/lora-${id}.json + logits`);
}
