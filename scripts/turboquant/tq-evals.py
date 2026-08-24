# Lean MMLU / GSM8K runner through stock mlx-lm — one arm per process, no
# generation for MMLU (answer-letter logprob comparison = one forward per
# question), greedy short generation for GSM8K. Built after the in-engine
# eval sweep swap-thrashed a 32 GB box (73 GB swap, 0.7 GB resident); the
# mlx-lm scoring path handled every 27B ppl run without drama.
#
# Cross-arm comparisons are PAIRED (same items, same prompts, same scorer);
# absolute numbers are not comparable to published harnesses.
#
#   .venv/bin/python -u scripts/turboquant/tq-evals.py <model_dir> mmlu 100
#   .venv/bin/python -u scripts/turboquant/tq-evals.py <model_dir> gsm8k 50

import json
import re
import sys
from pathlib import Path

import mlx.core as mx
from mlx_lm.utils import load

model_dir, task, n = sys.argv[1], sys.argv[2], int(sys.argv[3])
DATA = Path.home() / ".cache/mlx-bun/eval-data"

# --- pause/resume: per-item progress, fingerprinted to the artifact so a
# swapped model at the same path can never resume stale results ---------------
import glob as _glob
import os as _os

def _fingerprint(d):
    fs = sorted(_glob.glob(_os.path.join(d, "model*.safetensors")))
    if not fs:
        return "none"
    st = _os.stat(fs[0])
    return f"{len(fs)}-{st.st_size}-{int(st.st_mtime)}"

_FP = _fingerprint(model_dir)
_slug = model_dir.rstrip("/").replace("/", "_").replace(".", "_")[-80:]
_PROG = Path("runs/tq-qwen") / f"progress-{task}-{_slug}.jsonl"
_done = {}
if _PROG.exists():
    for _line in open(_PROG):
        _r = json.loads(_line)
        if _r.get("fp") == _FP:
            _done[_r["i"]] = _r

def _resume(i):
    """Return the stored ok-flag if item i is already scored, else None."""
    return _done[i]["ok"] if i in _done else None

def _record(i, ok):
    _PROG.parent.mkdir(parents=True, exist_ok=True)
    with open(_PROG, "a") as f:
        f.write(json.dumps({"i": i, "ok": bool(ok), "fp": _FP}) + "\n")

model, tok = load(model_dir)

if task == "mmlu":
    rows = [json.loads(l) for l in open(DATA / "mmlu_optiq_frozen.jsonl")][:n]
    letters = ["A", "B", "C", "D"]
    letter_ids = [tok.encode(f" {l}", add_special_tokens=False)[-1] for l in letters]
    correct = 0
    for i, r in enumerate(rows):
        prev = _resume(i)
        if prev is not None:
            correct += int(prev)
            continue
        prompt = r["question"].strip() + "\n"
        for li, c in enumerate(r["choices"]):
            prompt += f"{letters[li]}. {c}\n"
        prompt += "Answer:"
        ids = mx.array([tok.encode(prompt)])
        logits = model(ids)[0, -1]
        mx.eval(logits)
        pick = int(mx.argmax(mx.array([logits[t] for t in letter_ids])))
        correct += int(pick == r["answer"])
        _record(i, pick == r["answer"])
        if (i + 1) % 25 == 0:
            print(f"  {i + 1}/{len(rows)}  acc so far {correct / (i + 1):.3f}", flush=True)
        mx.clear_cache()
    print(f"RESULT mmlu {model_dir}: {correct}/{len(rows)} = {correct / len(rows) * 100:.1f}%")

elif task == "gsm8k-xhigh":
    # Thinking ON at reasoning_effort=xhigh — Qwen3.8's headline mode and the
    # model's default. Long traces (1-3k tok) make this both the max-capability
    # row AND the most degradation-sensitive instrument (error compounds over
    # the chain). Extraction reads AFTER the </think> block.
    from mlx_lm.generate import generate

    rows = [json.loads(l) for l in open(DATA / "gsm8k_optiq_frozen.jsonl")][:n]
    correct = 0
    for i, r in enumerate(rows):
        prev = _resume(i)
        if prev is not None:
            correct += int(prev)
            continue
        msgs = [{"role": "user", "content": r["question"] +
                 "\nGive the final number after '####'."}]
        prompt = tok.apply_chat_template(msgs, add_generation_prompt=True,
                                         tokenize=False, enable_thinking=True,
                                         reasoning_effort="xhigh")
        out = generate(model, tok, prompt=prompt, max_tokens=3584)
        answer = out.split("</think>")[-1]
        m = re.search(r"####\s*\$?([-\d,.]+)", answer)
        if not m:
            m = re.search(r"####\s*\$?([-\d,.]+)", out)
        pred = m.group(1).replace(",", "").rstrip(".") if m else None
        gm = re.search(r"####\s*([-\d,.]+)", r["answer"])
        g = gm.group(1).replace(",", "").rstrip(".")
        try:
            ok = pred is not None and abs(float(pred) - float(g)) < 1e-6
        except Exception:
            ok = pred == g
        correct += int(ok)
        _record(i, ok)
        print(f"  {i + 1}/{len(rows)} {'OK' if ok else 'MISS'} (out {len(out)} ch)", flush=True)
        mx.clear_cache()
    print(f"RESULT gsm8k-xhigh {model_dir}: {correct}/{len(rows)} = {correct / len(rows) * 100:.1f}%")

elif task == "gsm8k-templated":
    # Native-chat-template GSM8K — the serving-path reasoning measure. The
    # raw-completion variant below doubles as an EOS-cliff robustness probe
    # (2026-08-19 finding: quant arms with near-best ppl can emit instant
    # EOS in raw few-shot format while answering perfectly when templated).
    from mlx_lm.generate import generate

    rows = [json.loads(l) for l in open(DATA / "gsm8k_optiq_frozen.jsonl")][:n]

    def gold(ans):
        m = re.search(r"####\s*([-\d,.]+)", ans)
        return m.group(1).replace(",", "").rstrip(".") if m else None

    correct = 0
    for i, r in enumerate(rows):
        prev = _resume(i)
        if prev is not None:
            correct += int(prev)
            continue
        msgs = [{"role": "user", "content": r["question"] +
                 "\nSolve step by step, then give the final number after '####'."}]
        prompt = tok.apply_chat_template(msgs, add_generation_prompt=True,
                                         tokenize=False, enable_thinking=False)
        out = generate(model, tok, prompt=prompt, max_tokens=640)
        m = re.search(r"####\s*\$?([-\d,.]+)", out)
        pred = m.group(1).replace(",", "").rstrip(".") if m else None
        g = gold(r["answer"])
        try:
            ok = pred is not None and abs(float(pred) - float(g)) < 1e-6
        except Exception:
            ok = pred == g
        correct += int(ok)
        _record(i, ok)
        if (i + 1) % 10 == 0:
            print(f"  {i + 1}/{len(rows)}  acc so far {correct / (i + 1):.3f}", flush=True)
        mx.clear_cache()
    print(f"RESULT gsm8k-templated {model_dir}: {correct}/{len(rows)} = {correct / len(rows) * 100:.1f}%")

elif task == "gsm8k":
    from mlx_lm.generate import generate

    rows = [json.loads(l) for l in open(DATA / "gsm8k_optiq_frozen.jsonl")][:n]
    # 4-shot prefix from the tail of the pool (never overlaps the scored head).
    shots = [json.loads(l) for l in open(DATA / "gsm8k_optiq_frozen.jsonl")][-4:]

    def gold(ans):
        m = re.search(r"####\s*([-\d,.]+)", ans)
        return m.group(1).replace(",", "").rstrip(".") if m else None

    prefix = ""
    for s in shots:
        m = re.search(r"####\s*([-\d,.]+)", s["answer"])
        short = s["answer"].split("####")[0].strip()
        prefix += f"Q: {s['question']}\nA: {short}\n#### {m.group(1)}\n\n"

    correct = 0
    for i, r in enumerate(rows):
        prev = _resume(i)
        if prev is not None:
            correct += int(prev)
            continue
        prompt = prefix + f"Q: {r['question']}\nA:"
        out = generate(model, tok, prompt=prompt, max_tokens=320)
        first = out.split("Q:")[0]
        m = re.search(r"####\s*([-\d,.]+)", first)
        pred = m.group(1).replace(",", "").rstrip(".") if m else (
            re.findall(r"[-\d,.]*\d", first)[-1].replace(",", "") if re.findall(r"[-\d,.]*\d", first) else None)
        g = gold(r["answer"])
        try:
            ok = pred is not None and abs(float(pred) - float(g)) < 1e-6
        except Exception:
            ok = pred == g
        correct += int(ok)
        _record(i, ok)
        if (i + 1) % 10 == 0:
            print(f"  {i + 1}/{len(rows)}  acc so far {correct / (i + 1):.3f}", flush=True)
        mx.clear_cache()
    print(f"RESULT gsm8k {model_dir}: {correct}/{len(rows)} = {correct / len(rows) * 100:.1f}%")
else:
    raise SystemExit(f"unknown task {task}")
