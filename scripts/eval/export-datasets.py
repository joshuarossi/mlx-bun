#!/usr/bin/env python
"""Export the downloaded HF eval datasets to jsonl the TS harness can read.

Bun can't read HF's parquet/arrow, so this one-time pass (run in the oracle
venv, which has `datasets`) dumps each task's rows verbatim to
~/.cache/mlx-bun/eval-data/<name>.jsonl. The TS task modules — ports of
optiq/eval/*.py — pick the fields they need, so we dump full rows here
rather than reshaping (robust to schema drift).

  /Users/joshrossi/Code/mlx-lm/.venv/bin/python scripts/eval/export-datasets.py

Datasets + configs/splits match optiq/eval/* exactly (gsm8k.py:133,
mmlu.py:118-119, ifeval.py:288, humaneval.py:184, bfcl.py:339-343).
"""
from __future__ import annotations

import json
import os

os.environ.setdefault("HF_HUB_DISABLE_XET", "1")

OUT = os.path.expanduser("~/.cache/mlx-bun/eval-data")
os.makedirs(OUT, exist_ok=True)

# (outfile, repo, config-or-None, split)
JOBS = [
    ("gsm8k", "openai/gsm8k", "main", "test"),
    ("mmlu_test", "cais/mmlu", "all", "test"),
    ("mmlu_dev", "cais/mmlu", "all", "dev"),        # 5-shot exemplars
    ("ifeval", "google/IFEval", None, "train"),     # IFEval ships one split
    ("humaneval", "openai/openai_humaneval", None, "test"),
]


def dump(rows, name: str) -> int:
    path = os.path.join(OUT, f"{name}.jsonl")
    n = 0
    with open(path, "w") as f:
        for row in rows:
            f.write(json.dumps(dict(row), ensure_ascii=False) + "\n")
            n += 1
    print(f"  wrote {n:>6} rows -> {path}")
    return n


def main() -> None:
    from datasets import load_dataset

    for name, repo, config, split in JOBS:
        try:
            ds = load_dataset(repo, config, split=split) if config \
                else load_dataset(repo, split=split)
            dump(ds, name)
        except Exception as e:  # noqa: BLE001 — one task failing shouldn't kill the rest
            print(f"  !! {name} ({repo}): {type(e).__name__}: {e}")

    # BFCL is file-based (hf_hub_download of two jsonl files), not load_dataset.
    try:
        from huggingface_hub import hf_hub_download
        repo = "gorilla-llm/Berkeley-Function-Calling-Leaderboard"
        q = hf_hub_download(repo, "BFCL_v3_simple.json", repo_type="dataset")
        a = hf_hub_download(repo, "possible_answer/BFCL_v3_simple.json", repo_type="dataset")
        ql = [json.loads(l) for l in open(q) if l.strip()]
        al = [json.loads(l) for l in open(a) if l.strip()]
        merged = [{"query": x, "answer": y} for x, y in zip(ql, al)]
        dump(merged, "bfcl")
    except Exception as e:  # noqa: BLE001
        print(f"  !! bfcl: {type(e).__name__}: {e}")

    print(f"\neval-data ready at {OUT}")


if __name__ == "__main__":
    main()
