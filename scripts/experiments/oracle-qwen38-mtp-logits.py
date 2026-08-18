# Direct Qwen3.8 native-MTP drafter-logit oracle (PLAN 14g parity item).
#
# Runs the REFERENCE drafter (mlx_vlm.speculative.drafters.qwen3_5_mtp) on the
# real target's pre-final-norm hiddens and dumps everything the TS side needs
# to reproduce the FIRST DRAFT BLOCK on identical inputs:
#   prompt ids, the tapped hidden grid [L,H] (f32 of the bf16 values), greedy
#   token0, the gamma greedy draft tokens, and per-draft-step top-K logprobs.
#
# The TS comparator (qwen38-mtp-logit-parity.ts) feeds the SAME hidden grid to
# our drafter, isolating drafter math from any cross-version target drift; the
# target-tap agreement is reported separately there.
#
#   /tmp/mlxvlm-venv/bin/python scripts/experiments/oracle-qwen38-mtp-logits.py \
#       <target_snapshot> <head_snapshot> <out.json> [gamma]
#
# NOTE: runs in the scratch mlx-vlm venv (mlx may be NEWER than the pinned
# oracle venv — versions are recorded in the dump; drafter parity is judged on
# identical inputs so target-stack drift cannot leak in).

import json
import sys

import mlx.core as mx
from mlx_lm import load
from mlx_lm.models.cache import make_prompt_cache
from mlx_vlm.speculative.drafters.qwen3_5_mtp.config import Qwen3_5MTPConfig
from mlx_vlm.speculative.drafters.qwen3_5_mtp.qwen3_5_mtp import Qwen3_5MTPDraftModel

target_dir, head_dir, out_path = sys.argv[1], sys.argv[2], sys.argv[3]
GAMMA = int(sys.argv[4]) if len(sys.argv) > 4 else 3
TOPK = 8

model, tokenizer = load(target_dir)

PROMPT = "List the planets of the solar system in order from the Sun."
prompt_str = tokenizer.apply_chat_template(
    [{"role": "user", "content": PROMPT}],
    add_generation_prompt=True, tokenize=False, enable_thinking=False,
)
ids = tokenizer.encode(prompt_str)

# Tap the input of the final norm (= pre-final-norm hidden, every position).
# Walk the wrapper chain (Model → language_model → model …) to the module
# that owns embed_tokens/layers/norm — layout differs across mlx_lm versions.
inner = model
while not (hasattr(inner, "norm") and hasattr(inner, "embed_tokens")):
    if hasattr(inner, "language_model"):
        inner = inner.language_model
    elif hasattr(inner, "model"):
        inner = inner.model
    else:
        raise AttributeError(f"cannot find inner text model in {type(model).__name__}")
orig_norm = inner.norm
captured = {}

def tapped_norm(x):
    captured["pre"] = x
    return orig_norm(x)

inner.norm = tapped_norm

cache = make_prompt_cache(model)
logits = model(mx.array(ids)[None], cache=cache)
mx.eval(logits)
hidden = captured["pre"]  # [1, L, H] bf16
token0 = int(mx.argmax(logits[0, -1]).item())

# Reference drafter on the published (pre-sanitized) head.
with open(f"{head_dir}/config.json") as f:
    cfg = Qwen3_5MTPConfig.from_dict(json.load(f))
drafter = Qwen3_5MTPDraftModel(cfg)
weights = mx.load(f"{head_dir}/model.safetensors")
drafter.load_weights(list(drafter.sanitize(weights).items()))
drafter.reset(model)

# Record every lm-head evaluation (drafter step logits) in call order.
orig_lm = drafter._lm_head_fn
steps = []

def recording_lm(h):
    logits = orig_lm(h)
    lp = mx.log(mx.softmax(logits[0, -1].astype(mx.float32), axis=-1))
    top = mx.argsort(lp)[::-1][:TOPK]
    steps.append({
        "top_ids": [int(i) for i in top.tolist()],
        "top_logprobs": [float(lp[i].item()) for i in top.tolist()],
    })
    return logits

drafter._lm_head_fn = recording_lm

drafter.prefill_from_target_hidden(
    mx.array(ids)[None], hidden, token0, sampler=None, greedy=True,
)
block = drafter.draft_block(
    token0, hidden[:, -1:, :], None, GAMMA + 1, sampler=None, greedy=True,
)
mx.eval(block)
draft_tokens = [int(t) for t in block[0].tolist()]

out = {
    "mlx_version": mx.__version__,
    "prompt_ids": ids,
    "gamma": GAMMA,
    "token0": token0,
    "draft_tokens": draft_tokens,
    "steps": steps,  # index 0 = seed (our drafts[0]), then chained steps
    "hidden_f32": [float(v) for v in hidden[0].astype(mx.float32).flatten().tolist()],
    "hidden_shape": list(hidden.shape),
}
with open(out_path, "w") as f:
    json.dump(out, f)
print("token0:", token0)
print("draft_tokens:", draft_tokens)
print("steps recorded:", len(steps))
print("wrote", out_path)
