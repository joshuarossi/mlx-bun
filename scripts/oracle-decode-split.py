# Decode-gap instrumentation, python side — the same per-step wall-time
# split as scripts/decode-split.ts, on a hand-rolled copy of mlx-lm's
# generate_step pipelined loop (greedy, bf16 KV, generation_stream).
# t_build = graph construction + async_eval dispatch; t_read = blocked
# in y.item(). Run with the oracle venv python:
#
#   /Users/joshrossi/Code/mlx-lm/.venv/bin/python scripts/oracle-decode-split.py \
#       <model_path> [prompt_tokens] [steps]

import sys, time
import mlx.core as mx
from optiq.mlx_lm_patches._register import register
register()
from mlx_lm import load
from mlx_lm.models import cache as cache_mod
from mlx_lm.generate import generation_stream

model_path = sys.argv[1]
prompt_tokens = int(sys.argv[2]) if len(sys.argv) > 2 else 600
steps = int(sys.argv[3]) if len(sys.argv) > 3 else 128

model, tokenizer = load(model_path)

user_msg = ("Write a detailed essay about the history of computing, "
            "starting with mechanical calculators.")
filler = ("Background context: the history of computation spans mechanical "
          "calculators, electromechanical relays, vacuum tubes, transistors, "
          "integrated circuits, and modern accelerators. ")
while len(tokenizer.encode(user_msg)) < prompt_tokens - 24:
    user_msg = filler + user_msg
prompt = mx.array(tokenizer.apply_chat_template(
    [{"role": "user", "content": user_msg}], add_generation_prompt=True))

# warmup: materialize weights + compile decode-shape kernels (mirrors
# the JS script's warmup; excluded from all timers)
wc = cache_mod.make_prompt_cache(model)
with mx.stream(generation_stream):
    mx.eval(model(prompt[:8][None], cache=wc))
    mx.eval(model(prompt[8:9][None], cache=wc))
del wc
mx.clear_cache()

prompt_cache = cache_mod.make_prompt_cache(model)

def step_graph(y):
    # mlx-lm _step: forward → last-position logits → logprobs → sample
    with mx.stream(generation_stream):
        logits = model(y[None], cache=prompt_cache)
        logits = logits[:, -1, :]
        logprobs = logits - mx.logsumexp(logits, keepdims=True)
        return mx.argmax(logprobs, axis=-1)

# ---- prefill (chunked like generate_step; same chunk convention as ours) ----
CHUNK = 2048
t0 = time.perf_counter()
p = prompt
with mx.stream(generation_stream):
    while p.size > CHUNK:
        model(p[:CHUNK][None], cache=prompt_cache)
        mx.eval([c.state for c in prompt_cache])
        p = p[CHUNK:]
        mx.clear_cache()
    y = step_graph(p)
mx.async_eval(y)
mx.eval(y)
prefill_ms = (time.perf_counter() - t0) * 1000

# ---- pipelined decode with per-step split timers ----
build, read = [], []
t_dec = time.perf_counter()
for n in range(steps):
    t0 = time.perf_counter()
    next_y = step_graph(y)        # build step n+1's graph from unread y
    mx.async_eval(next_y)
    t1 = time.perf_counter()
    y.item()                      # sync-read step n while n+1 computes
    t2 = time.perf_counter()
    y = next_y
    build.append((t1 - t0) * 1000)
    read.append((t2 - t1) * 1000)
decode_ms = (time.perf_counter() - t_dec) * 1000
y.item()

def q(xs, pct):
    s = sorted(xs)
    return s[min(len(s) - 1, int(pct * len(s)))]

def fmt(xs):
    return (f"median {q(xs, 0.5):.2f} ms  p10 {q(xs, 0.1):.2f}  "
            f"p90 {q(xs, 0.9):.2f}  total {sum(xs):.0f} ms")

print(f"ctx={prompt.size} steps={steps} prefill={prefill_ms:.0f} ms")
print(f"decode {steps / decode_ms * 1000:.1f} tok/s ({decode_ms / steps:.2f} ms/step)")
print(f"t_build (graph + dispatch): {fmt(build)}")
print(f"t_read  (blocked on GPU):   {fmt(read)}")
print(f"split: build {100 * sum(build) / decode_ms:.1f}% / read {100 * sum(read) / decode_ms:.1f}% of decode wall")
