# optiq spec_generate oracle — dumps prompt ids + output token ids for a
# fixed prompt, to cross-check mlx-bun's specGenerate against the ACTUAL
# optiq implementation (the correctness oracle for assistant-drafter spec
# decode, which mlx-lm does not have). Run with the oracle venv python:
#
#   /Users/joshrossi/Code/mlx-lm/.venv/bin/python scripts/oracle-spec.py \
#       <target_snapshot_dir> <drafter_snapshot_dir> [gamma] [maxtok]
#
# Prints PROMPT_IDS (exactly what spec_generate encodes internally) so the
# TS side (scripts/spec-dump.ts) can run on the IDENTICAL prompt ids —
# isolating the comparison to the spec loop, not tokenization.
import sys
from optiq.mlx_lm_patches._register import register
register()
from mlx_lm import load
from optiq.runtime.spec.runtime import spec_generate, SpecConfig
from optiq.runtime.spec.drafters.gemma_assistant import GemmaAssistantDrafter

target_path, drafter_path = sys.argv[1], sys.argv[2]
gamma = int(sys.argv[3]) if len(sys.argv) > 3 else 2
maxtok = int(sys.argv[4]) if len(sys.argv) > 4 else 48

model, tokenizer = load(target_path)
drafter = GemmaAssistantDrafter.from_pretrained(drafter_path)

prompt_str = tokenizer.apply_chat_template(
    [{"role": "user", "content": "List the planets of the solar system in order from the Sun."}],
    add_generation_prompt=True, tokenize=False)
prompt_ids = tokenizer.encode(prompt_str)
print("PROMPT_IDS:", ",".join(map(str, prompt_ids)), flush=True)

out, n_acc, n_draft = [], 0, 0
for ev in spec_generate(model, drafter, tokenizer, prompt_str,
                        SpecConfig(gamma=gamma, max_tokens=maxtok)):
    if ev.kind == "token":
        out.append(ev.token_id)
    elif ev.kind == "done":
        print("DONE:", ev.text, flush=True)
print("OUT_IDS:", ",".join(map(str, out)), flush=True)
