# L1 oracle for serve --draft-model (two-model speculative decoding):
# mlx-lm's own speculative path on an explicit (target, draft) pair.
# Run with the oracle venv python:
#   /Users/joshrossi/Code/mlx-lm/.venv/bin/python scripts/oracle/oracle-spec-two-model.py \
#       <target_dir> <draft_dir> <num_draft_tokens> <max_tokens> <prompt_ids_json>
# Prints one JSON object: {"tokens": [...]} — the greedy spec token stream
# (content tokens, EOS excluded), for token-for-token comparison against
# specServeRun. Compare SPEC-vs-SPEC (both batch the verify lm-head; neither
# is bit-exact to stock decode at bf16 knife-edges).
import json
import sys

from mlx_lm import load
from mlx_lm.generate import stream_generate
from mlx_lm.sample_utils import make_sampler

target_dir, draft_dir, num_draft, max_tokens, ids_json = sys.argv[1:6]
model, tokenizer = load(target_dir)
draft_model, _ = load(draft_dir)
prompt_ids = json.loads(ids_json)

tokens = []
for r in stream_generate(
    model,
    tokenizer,
    prompt=prompt_ids,
    max_tokens=int(max_tokens),
    draft_model=draft_model,
    num_draft_tokens=int(num_draft),
    sampler=make_sampler(temp=0.0),
):
    tokens.append(r.token)

# stream_generate yields the finishing EOS token as its last event; our serve
# loop never emits EOS as content — drop it for the comparison.
if tokens and tokens[-1] in (
    set(tokenizer.eos_token_ids) if hasattr(tokenizer, "eos_token_ids") else {tokenizer.eos_token_id}
):
    tokens = tokens[:-1]

print(json.dumps({"tokens": tokens}))
