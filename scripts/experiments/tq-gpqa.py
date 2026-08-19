# GPQA Diamond at reasoning_effort=xhigh — the certification benchmark for
# the chosen artifact (OUR harness on OUR hardware; not comparable to
# published-leaderboard numbers). Dataset: Idavidrein/gpqa (gated; uses the
# stored HF auth). Options shuffled per-row with a fixed seed; the model
# answers with a letter after its thinking block.
#
#   .venv/bin/python -u scripts/experiments/tq-gpqa.py <model_dir> [n=198]

import random
import re
import sys

import mlx.core as mx
from huggingface_hub import hf_hub_download
from mlx_lm.generate import generate
from mlx_lm.utils import load

model_dir = sys.argv[1]
n = int(sys.argv[2]) if len(sys.argv) > 2 else 198
MAX_TOKENS = int(sys.argv[3]) if len(sys.argv) > 3 else 12288
# resume: per-question results persisted; finished ids skipped on restart
import json as jsonmod, os
RES = os.path.join("runs", "tq-qwen", "gpqa-progress.jsonl")
done = {}
if os.path.exists(RES):
    for line in open(RES):
        r = jsonmod.loads(line)
        done[r["i"]] = r

csv_path = hf_hub_download("Idavidrein/gpqa", "gpqa_diamond.csv", repo_type="dataset")
import csv as csvmod
rows = list(csvmod.DictReader(open(csv_path)))[:n]
print(f"GPQA Diamond: {len(rows)} questions", flush=True)

model, tok = load(model_dir)
letters = ["A", "B", "C", "D"]
correct = 0
answered = 0
for i, r in enumerate(rows):
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
    body += "\nEnd your response with exactly: Answer: <letter>"
    msgs = [{"role": "user", "content": body}]
    prompt = tok.apply_chat_template(msgs, add_generation_prompt=True, tokenize=False,
                                     enable_thinking=True, reasoning_effort="xhigh")
    out = generate(model, tok, prompt=prompt, max_tokens=MAX_TOKENS)
    tail = out.split("</think>")[-1]
    m = re.search(r"Answer:\s*\(?([ABCD])", tail) or re.search(r"\b([ABCD])\)?\s*$", tail.strip()) \
        or re.search(r"Answer:\s*\(?([ABCD])", out)
    pred = m.group(1) if m else None
    ok = pred == gold_letter
    correct += int(ok)
    answered += int(pred is not None)
    print(f"  {i + 1}/{len(rows)} {'OK' if ok else ('MISS' if pred else 'NO-ANSWER')} "
          f"(acc {correct / (i + 1):.3f}, out {len(out)} ch)", flush=True)
    with open(RES, "a") as f:
        f.write(jsonmod.dumps({"i": i, "ok": ok, "pred": pred, "out_len": len(out)}) + "\n")
    mx.clear_cache()

print(f"RESULT gpqa-diamond-xhigh {model_dir}: {correct}/{len(rows)} = "
      f"{correct / len(rows) * 100:.1f}%  (answered {answered}/{len(rows)})")
