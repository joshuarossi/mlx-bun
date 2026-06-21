#!/usr/bin/env python
# Freeze optiq's EXACT MMLU eval set: replicate evaluate_mmlu's sampling verbatim
# (numpy RandomState(42), stratified per-subject) and dump the 1000 sampled test
# questions + the dev exemplars, so our harness can run the IDENTICAL questions and
# 5-shot prompts. Any remaining score gap is then pure forward-logit parity, not
# sampling. CPU/data only — no model, no GPU.
#
#   HF_HUB_DISABLE_XET=1 <optiq-venv>/bin/python scripts/experiments/capture-optiq-mmlu.py
import json, os
import numpy as np
from datasets import load_dataset

SEED = 42
N_SAMPLES = 1000  # optiq's evaluate_mmlu default
OUT_DIR = os.path.expanduser("~/.cache/mlx-bun/eval-data")
os.makedirs(OUT_DIR, exist_ok=True)

print("loading cais/mmlu test + dev …")
test_ds = load_dataset("cais/mmlu", "all", split="test")
dev_ds = load_dataset("cais/mmlu", "all", split="dev")

# --- dev exemplars grouped by subject (verbatim optiq order) ---
dev_by_subject = {}
for ex in dev_ds:
    dev_by_subject.setdefault(ex["subject"], []).append(ex)

# --- stratified sample, VERBATIM from optiq/eval/mmlu.py evaluate_mmlu ---
rng = np.random.RandomState(SEED)
test_by_subject = {}
for ex in test_ds:
    test_by_subject.setdefault(ex["subject"], []).append(ex)
subjects = sorted(test_by_subject.keys())
per_subject = max(1, N_SAMPLES // len(subjects))
sampled = []
for subj in subjects:
    pool = test_by_subject[subj]
    idxs = rng.choice(len(pool), size=min(per_subject, len(pool)), replace=False)
    for i in idxs:
        sampled.append(pool[int(i)])
if len(sampled) > N_SAMPLES:
    rng.shuffle(sampled)
    sampled = sampled[:N_SAMPLES]

def row(ex):
    return {"question": ex["question"], "subject": ex["subject"],
            "choices": list(ex["choices"]), "answer": int(ex["answer"])}

# frozen test set (optiq's exact 1000, in his order)
test_path = os.path.join(OUT_DIR, "mmlu_optiq_frozen.jsonl")
with open(test_path, "w") as f:
    for ex in sampled:
        f.write(json.dumps(row(ex)) + "\n")

# frozen dev exemplars (so the 5-shot prompts are identical)
dev_path = os.path.join(OUT_DIR, "mmlu_optiq_dev.jsonl")
with open(dev_path, "w") as f:
    for subj in sorted(dev_by_subject.keys()):
        for ex in dev_by_subject[subj]:
            f.write(json.dumps(row(ex)) + "\n")

print(f"subjects={len(subjects)}  per_subject={per_subject}")
print(f"wrote {len(sampled)} test questions -> {test_path}")
print(f"wrote dev exemplars ({sum(len(v) for v in dev_by_subject.values())}) -> {dev_path}")
# quick fingerprint so we can confirm reproducibility later
print("first sampled:", sampled[0]["subject"], "|", sampled[0]["question"][:60])
print("last  sampled:", sampled[-1]["subject"], "|", sampled[-1]["question"][:60])
