# Teacher-forced logit parity: plain vs rotation-folded qwen3_5 snapshot,
# through STOCK mlx-lm (cross-stack check for the TurboQuant weight fold).
#
#   /Users/joshrossi/Code/mlx-lm/.venv/bin/python \
#       scripts/experiments/tq-fold-parity.py <plain_dir> <folded_dir>

import sys

import mlx.core as mx
from mlx_lm.utils import load

plain_dir, folded_dir = sys.argv[1], sys.argv[2]

PROMPTS = [
    "The first eight prime numbers are",
    "Explain why the sky appears blue during the day.",
    "def fibonacci(n):",
    "In 1969, the Apollo 11 mission achieved",
    "Water is composed of two elements:",
]


def forward_all(model_dir, token_lists):
    model, tok = load(model_dir)
    outs = []
    for ids in token_lists:
        logits = model(mx.array([ids]))
        outs.append(logits.astype(mx.float32))
        mx.eval(outs[-1])
    del model
    mx.clear_cache()
    return outs, tok


# Tokenize with the plain model's tokenizer (identical files in both dirs).
model, tok = load(plain_dir)
token_lists = [tok.encode(p) for p in PROMPTS]
p_logits = []
for ids in token_lists:
    out = model(mx.array([ids])).astype(mx.float32)
    mx.eval(out)
    p_logits.append(out)
del model
mx.clear_cache()

model2, _ = load(folded_dir)
q_logits = []
for ids in token_lists:
    out = model2(mx.array([ids])).astype(mx.float32)
    mx.eval(out)
    q_logits.append(out)
del model2
mx.clear_cache()

worst_kl = 0.0
worst_flip_margin = None
total_pos = 0
flips = 0
for pi, (p, q) in enumerate(zip(p_logits, q_logits)):
    lp = p - mx.logsumexp(p, axis=-1, keepdims=True)
    lq = q - mx.logsumexp(q, axis=-1, keepdims=True)
    kl = mx.sum(mx.exp(lp) * (lp - lq), axis=-1)  # [1, T]
    mean_kl = float(mx.mean(kl))
    max_kl = float(mx.max(kl))
    worst_kl = max(worst_kl, max_kl)
    pa = mx.argmax(p, axis=-1)
    qa = mx.argmax(q, axis=-1)
    same = mx.sum(pa == qa)
    T = pa.shape[1]
    total_pos += T
    n_flip = T - int(same)
    flips += n_flip
    # margin at each flip position (top1-top2 gap in the reference)
    if n_flip:
        idx = [t for t in range(T) if int(pa[0, t]) != int(qa[0, t])]
        for t in idx:
            row = p[0, t]
            top2 = mx.topk(row, 2)
            margin = float(top2[1] - top2[0])
            margin = abs(margin)
            if worst_flip_margin is None or margin > worst_flip_margin:
                worst_flip_margin = margin
    print(f"prompt {pi}: T={T} meanKL={mean_kl:.5f} maxKL={max_kl:.5f} argmax_flips={n_flip}")

print(f"\nTOTAL: positions={total_pos} flips={flips} worstKL={worst_kl:.5f} "
      f"worst_flip_ref_margin={worst_flip_margin}")
