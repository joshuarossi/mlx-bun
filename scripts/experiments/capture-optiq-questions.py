#!/usr/bin/env python
"""COPY mlx-optiq's EXACT eval questions by running optiq's OWN eval code.

We do NOT reimplement any sampling. We import optiq's real `evaluate_<task>`
functions and run them, but STUB the model + generation so there is zero GPU
forward — optiq's own dataset-load + deterministic selection + few-shot +
chat-template code builds each item, and we tee it out verbatim:

  * mlx_lm.load     -> (DummyModel, REAL tokenizer)   # real chat template, no weights
  * mlx_lm.generate -> record the exact rendered prompt, return ""   # no forward
  * tqdm            -> tee the current dataset row (question + ground truth)
  * humaneval.run_python / hashhop._format_prompt -> capture GT, skip sandbox

Output: ~/.cache/mlx-bun/eval-data/<task>_optiq_frozen.jsonl — one row per item,
in optiq's exact order, with the rendered prompt + all scoring metadata. Our TS
eval then feeds these EXACT inputs; the only remaining difference is the forward
logits, which is the thing we actually want to measure.

Run in the optiq oracle venv (CPU only — safe, ~seconds):
  HF_HUB_DISABLE_XET=1 /Users/joshrossi/Code/mlx-lm-example/.venv/bin/python \
    scripts/experiments/capture-optiq-questions.py <model_path>

<model_path> = the SAME MiniCPM5-1B-OptiQ-4bit snapshot optiq published on.
MMLU is already captured (mmlu_optiq_frozen.jsonl) and is skipped by default.
"""
import json, os, sys, types

MODEL = sys.argv[1] if len(sys.argv) > 1 else None
if not MODEL:
    sys.exit("usage: capture-optiq-questions.py <model_path>")
OUT_DIR = os.path.expanduser("~/.cache/mlx-bun/eval-data")
os.makedirs(OUT_DIR, exist_ok=True)

# Headline-run counts (optiq/cli.py capability path: lines 918-926, 745-754).
COUNTS = {"gsm8k": 1000, "ifeval": None, "humaneval": None, "bfcl": 200}

# --- load the REAL tokenizer (chat template) WITHOUT model weights ---
def _load_real_tokenizer(path):
    for mod, fn in (("mlx_lm.tokenizer_utils", "load_tokenizer"),
                    ("mlx_lm.utils", "load_tokenizer")):
        try:
            m = __import__(mod, fromlist=[fn])
            from pathlib import Path
            return getattr(m, fn)(Path(path))
        except Exception:
            continue
    from transformers import AutoTokenizer  # last resort (delegates apply_chat_template)
    return AutoTokenizer.from_pretrained(path)

_TOK = _load_real_tokenizer(MODEL)

# --- shared capture state ---
_CUR = {"row": None}      # current dataset row (set by the tqdm tee)
_RECORDS = []             # captured items for the running task

class _DummyModel:        # never used for a forward (generate is stubbed)
    def __call__(self, *a, **k):
        raise RuntimeError("stub model should not be called for a forward")

def _fake_load(*a, **k):
    return _DummyModel(), _TOK

def _fake_generate(model, tokenizer, prompt=None, **k):
    # optiq calls generate(model, tok, prompt=..., max_tokens=..., sampler=...)
    rec = {"rendered_prompt": prompt}
    if isinstance(_CUR["row"], dict):
        rec.update(_CUR["row"])           # question + ground-truth fields, verbatim
    elif _CUR["row"] is not None:
        rec["_row"] = _CUR["row"]
    _RECORDS.append(rec)
    return ""                              # no forward

def _tee_tqdm(iterable=None, *a, **k):
    # optiq does `for ex in tqdm(rows, desc=...)` — tee each yielded row so the
    # generate stub can pair the rendered prompt with its source row.
    for x in (iterable if iterable is not None else []):
        _CUR["row"] = x if isinstance(x, dict) else None
        yield x

# --- install stubs on the modules optiq imports from (lazy `from x import y`
#     inside each evaluate() picks these up at call time) ---
import mlx_lm
mlx_lm.load = _fake_load
mlx_lm.generate = _fake_generate
import tqdm as _tqdm_mod
_tqdm_mod.tqdm = _tee_tqdm

def _dump(task):
    path = os.path.join(OUT_DIR, f"{task}_optiq_frozen.jsonl")
    with open(path, "w") as f:
        for r in _RECORDS:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")
    print(f"  wrote {len(_RECORDS)} items -> {path}")
    if _RECORDS:
        print(f"    first prompt[:80]: {(_RECORDS[0].get('rendered_prompt') or '')[:80]!r}")
    _RECORDS.clear()
    _CUR["row"] = None

# === GSM8K (1000, RandomState(42).choice.sort) ===
# gsm8k iterates `for idx in tqdm(indices)` (ints), so the tqdm tee can't see the
# row. Hook _extract_ground_truth (called once per item with item["answer"]) to tee
# the answer just before the generate() call in the same loop iteration.
import optiq.eval.gsm8k as _gs
_gs_orig_gt = _gs._extract_ground_truth
def _gs_tee_gt(answer_text):
    _CUR["row"] = {**(_CUR["row"] or {}), "answer": answer_text}
    return _gs_orig_gt(answer_text)
_gs._extract_ground_truth = _gs_tee_gt
_gs_orig_bp = _gs._build_prompt
def _gs_tee_bp(question, *a, **k):            # tee the RAW question (the data)
    _CUR["row"] = {**(_CUR["row"] or {}), "question": question}
    return _gs_orig_bp(question, *a, **k)
_gs._build_prompt = _gs_tee_bp
from optiq.eval.gsm8k import evaluate_gsm8k
print("GSM8K …"); evaluate_gsm8k(MODEL, n_samples=COUNTS["gsm8k"]); _dump("gsm8k")

# === IFEval (full 540) ===
from optiq.eval.ifeval import evaluate_ifeval
print("IFEval …"); evaluate_ifeval(MODEL, n_samples=COUNTS["ifeval"]); _dump("ifeval")

# === BFCL-V3 simple (200, RandomState(42).choice) ===
from optiq.eval.bfcl import evaluate_bfcl
print("BFCL …"); evaluate_bfcl(MODEL, n_samples=COUNTS["bfcl"]); _dump("bfcl")

# === HumanEval (full 164) — stub the sandbox so empty programs don't execute ===
import optiq.eval.humaneval as _he
_he.run_python = lambda *a, **k: types.SimpleNamespace(returncode=1, timed_out=False, stderr="")
from optiq.eval.humaneval import evaluate_humaneval
print("HumanEval …"); evaluate_humaneval(MODEL, n_samples=COUNTS["humaneval"]); _dump("humaneval")

# === HashHop (synthetic, seed 42 → deterministic problems) ===
# hashhop builds each problem in-loop via MultiHopEval.make_one; capture the
# (prompt, expected) by wrapping optiq's _format_prompt so we get the GT.
# Requires the `hashhop` package in the venv (pip install hashhop).
try:
    import optiq.eval.hashhop as _hh
    _orig_format = _hh._format_prompt
    def _wrap_format(sample):
        prompt_text, query, expected = _orig_format(sample)
        # raw_problem = the synthetic context+query BEFORE chat templating (the data)
        _CUR["row"] = {"raw_problem": prompt_text, "query": query, "expected": expected}
        return prompt_text, query, expected
    _hh._format_prompt = _wrap_format
    from optiq.eval.hashhop import evaluate_hashhop
    print("HashHop …"); evaluate_hashhop(MODEL); _dump("hashhop")
except ModuleNotFoundError as e:
    print(f"HashHop SKIPPED — missing dependency: {e}. `pip install hashhop` in the "
          f"oracle venv to capture it (synthetic, seed 42 — deterministic).")

print("\nDONE. Frozen optiq questions for gsm8k/ifeval/bfcl/humaneval/hashhop are in", OUT_DIR)
print("(MMLU already captured as mmlu_optiq_frozen.jsonl)")
