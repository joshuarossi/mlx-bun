# GPQA Diamond at reasoning_effort=xhigh — the certification benchmark for
# the chosen artifact (OUR harness on OUR hardware; not comparable to
# published-leaderboard numbers). Dataset: Idavidrein/gpqa (gated; uses the
# stored HF auth). Options shuffled per-row with a fixed seed; the model
# answers with a letter after its thinking block.
#
#   .venv/bin/python -u scripts/turboquant/tq-gpqa.py <model_dir> [n=198]

import random
import re
import sys

import mlx.core as mx
from huggingface_hub import hf_hub_download
from mlx_lm.generate import generate
from mlx_lm.sample_utils import make_sampler
from mlx_lm.utils import load

model_dir = sys.argv[1]
n = int(sys.argv[2]) if len(sys.argv) > 2 else 198
MAX_TOKENS = int(sys.argv[3]) if len(sys.argv) > 3 else 12288
# --server-url http://host:port — generate through a running `mlx-bun serve`
# (the product path: template + sampler + MTP spec lane) instead of local
# mlx-lm. Everything else (dataset, shuffle seeds, extraction, scoring) is
# IDENTICAL, so scores compare directly. Greedy runs are bit-identical
# cross-engine; at the official temp-1.0 sampling the engines draw from
# different RNG streams (statistically equivalent, not token-identical).
SERVER_URL = None
if "--server-url" in sys.argv:
    SERVER_URL = sys.argv[sys.argv.index("--server-url") + 1].rstrip("/")
# --shard K/N — process only questions where i % N == K (0-based). Each shard
# writes its own progress file; shards merge by concatenation (per-question
# rows are self-describing). Farm mode: run N rented boxes, one shard each.
SHARD_K, SHARD_N = 0, 1
if "--shard" in sys.argv:
    SHARD_K, SHARD_N = map(int, sys.argv[sys.argv.index("--shard") + 1].split("/"))
# resume: per-question results persisted; finished ids skipped on restart
import json as jsonmod, os
s_suffix = "-serve" if ("--server-url" in sys.argv) else ""
sh_suffix = "" if ("--shard" not in sys.argv) else f"-shard{sys.argv[sys.argv.index('--shard')+1].replace('/','of')}"
RES = os.path.join("runs", "tq-qwen", f"gpqa-progress{s_suffix}{sh_suffix}.jsonl")
done = {}
if os.path.exists(RES):
    for line in open(RES):
        r = jsonmod.loads(line)
        done[r["i"]] = r

csv_path = hf_hub_download("Idavidrein/gpqa", "gpqa_diamond.csv", repo_type="dataset")
import csv as csvmod
rows = list(csvmod.DictReader(open(csv_path)))[:n]
print(f"GPQA Diamond: {len(rows)} questions", flush=True)

if SERVER_URL is None:
    model, tok = load(model_dir)
else:
    import urllib.request
    def serve_generate(body_text):
        req = urllib.request.Request(
            f"{SERVER_URL}/v1/chat/completions",
            data=jsonmod.dumps({
                "model": "gpqa", "max_tokens": MAX_TOKENS,
                "messages": [{"role": "user", "content": body_text}],
                # Official thinking-mode sampling (model card Best Practices §1);
                # reasoning_effort xhigh = the certification methodology.
                "temperature": 1.0, "top_p": 0.95, "top_k": 20,
                "reasoning_effort": "xhigh",
            }).encode(),
            headers={"Content-Type": "application/json"})
        with urllib.request.urlopen(req, timeout=14400) as r:
            resp = jsonmod.load(r)
        msg = resp["choices"][0]["message"]
        # Reassemble the raw-transcript shape the extraction regexes expect.
        reasoning = msg.get("reasoning") or ""
        content = msg.get("content") or ""
        return (f"{reasoning}</think>{content}" if reasoning else content)
letters = ["A", "B", "C", "D"]
correct = 0
answered = 0
for i, r in enumerate(rows):
    if i % SHARD_N != SHARD_K:
        continue
    if i in done:
        correct += int(done[i]["ok"])
        answered += int(done[i]["pred"] is not None)
        continue
    opts = [r["Correct Answer"], r["Incorrect Answer 1"], r["Incorrect Answer 2"], r["Incorrect Answer 3"]]
    rng = random.Random(1000 + i)
    order = [0, 1, 2, 3]
    rng.shuffle(order)
    gold_letter = letters[order.index(0)]
    body = r["Question"].strip() + "\n\n"
    for li, oi in enumerate(order):
        body += f"{letters[li]}) {opts[oi].strip()}\n"
    # Official Qwen3.8 GPQA prompt (model card, verbatim) + official
    # thinking-mode sampling below (temp 1.0 / top_p 0.95 / top_k 20).
    body += "\nPlease reason step by step, and put your final answer within \\boxed{}."
    if SERVER_URL is not None:
        out = serve_generate(body)
    else:
        msgs = [{"role": "user", "content": body}]
        prompt = tok.apply_chat_template(msgs, add_generation_prompt=True, tokenize=False,
                                         enable_thinking=True, reasoning_effort="xhigh")
        mx.random.seed(1000 + i)  # per-question seed: resumable-deterministic
        sampler = make_sampler(temp=1.0, top_p=0.95, top_k=20, min_p=0.0)
        out = generate(model, tok, prompt=prompt, max_tokens=MAX_TOKENS, sampler=sampler)
    tail = out.split("</think>")[-1]
    m = re.search(r"boxed\{+\s*\\?(?:text\{)?\(?([ABCD])", tail) \
        or re.search(r"Answer:\s*\(?([ABCD])", tail) \
        or re.search(r"\b([ABCD])\)?\s*$", tail.strip())
    pred = m.group(1) if m else None
    ok = pred == gold_letter
    correct += int(ok)
    answered += int(pred is not None)
    print(f"  {i + 1}/{len(rows)} {'OK' if ok else ('MISS' if pred else 'NO-ANSWER')} "
          f"(acc {correct / (i + 1):.3f}, out {len(out)} ch)", flush=True)
    with open(RES, "a") as f:
        f.write(jsonmod.dumps({"i": i, "ok": ok, "pred": pred, "out_len": len(out)}) + "\n")
    mx.clear_cache()

n_proc = len([i for i in range(len(rows)) if i % SHARD_N == SHARD_K])
print(f"RESULT gpqa-diamond-xhigh {model_dir} shard {SHARD_K}/{SHARD_N}: {correct}/{n_proc} = "
      f"{correct / max(1, n_proc) * 100:.1f}%  (answered {answered}/{n_proc})")
