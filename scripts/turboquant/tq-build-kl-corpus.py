# Build the FIXED held-out KL eval corpus: sequences packed to ctx_len tokens
# from the held-out slice of the UF-derived corpus family that carries every
# ppl number in this program (~/.cache/mlx-bun/eval-data/uf-cpm5/). The corpus
# is conversational ({prompt, chosen, rejected}), so each row is rendered
# through the model's chat template — mirroring AtomicChat's protocol of a
# held-out chat eval at 4096 context against a BF16 reference.
#
# Held-out ordering: uf-cpm5/valid.jsonl first (the curated validation split),
# then, only if valid.jsonl cannot fill n_seqs, the TAIL of uf-cpm5/train.jsonl
# (defaults to the last 4096 rows). Nothing here fits a quantizer — GPTQ
# calibrates on mlx-lm's own calibration_v5 set (scripts/turboquant/tq-gptq.py).
#
# Deterministic: seeded shuffle within each source, fixed template flags
# (enable_thinking pinned — see docs/reference/environment.md on mlx-lm
# injecting enable_thinking=True when the caller stays silent). The manifest
# records the SHA-256 of the token stream; the teacher dump copies it into
# `corpus_sha256` and every scored candidate is checked against it.
#
#   .venv/bin/python scripts/turboquant/tq-build-kl-corpus.py \
#       --out runs/kl-corpus/uf-4096x32 [--ctx-len 4096] [--n-seqs 32] \
#       [--seed 123] [--tokenizer <dir>] [--train-tail 4096]
#
# Writes <out>/tokens.bin (int32 LE [n_seqs][ctx_len]) + <out>/manifest.json.

import argparse
import json
import random
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from tq_kl_common import sha256_file, write_manifest, write_tokens  # noqa: E402

from mlx_lm.tokenizer_utils import load as load_tokenizer  # noqa: E402

DATA = Path.home() / ".cache/mlx-bun/eval-data/uf-cpm5"
# The Qwen3.8-27B tokenizer. The published bf16 repo is a large download; the
# local quantized snapshot of the SAME base model carries a byte-identical
# tokenizer, so the corpus can be built without it. Override with --tokenizer.
DEFAULT_TOKENIZER = (
    Path.home()
    / ".cache/huggingface/hub/models--mjriii--Qwen3.8-27B/snapshots/staged"
)

ap = argparse.ArgumentParser()
ap.add_argument("--out", required=True)
ap.add_argument("--ctx-len", type=int, default=4096)
ap.add_argument("--n-seqs", type=int, default=32)
ap.add_argument("--seed", type=int, default=123)
ap.add_argument("--tokenizer", default=str(DEFAULT_TOKENIZER))
ap.add_argument("--valid", default=str(DATA / "valid.jsonl"))
ap.add_argument("--train", default=str(DATA / "train.jsonl"))
ap.add_argument("--train-tail", type=int, default=4096,
                help="rows taken from the END of train.jsonl when valid.jsonl is short")
ap.add_argument("--notes", default="")
args = ap.parse_args()

out = Path(args.out)
out.mkdir(parents=True, exist_ok=True)
need = args.n_seqs * args.ctx_len

tok = load_tokenizer(Path(args.tokenizer))


def rows_of(path):
    rows = []
    with open(path) as f:
        for line in f:
            try:
                r = json.loads(line)
            except Exception:
                continue
            if isinstance(r.get("prompt"), str) and isinstance(r.get("chosen"), str):
                rows.append(r)
    return rows


valid_rows = rows_of(args.valid)
train_rows = rows_of(args.train)
train_tail = train_rows[-args.train_tail :] if args.train_tail > 0 else []

random.Random(args.seed).shuffle(valid_rows)
random.Random(args.seed).shuffle(train_tail)

sources = [
    {"path": str(Path(args.valid).resolve()), "role": "held-out validation split",
     "rows_available": len(valid_rows), "rows_used": 0},
    {"path": str(Path(args.train).resolve()), "role": f"held-out tail (last {args.train_tail} rows)",
     "rows_available": len(train_tail), "rows_used": 0},
]

ids: list[int] = []
for si, pool in enumerate((valid_rows, train_tail)):
    for r in pool:
        if len(ids) >= need:
            break
        ids.extend(tok.apply_chat_template(
            [{"role": "user", "content": r["prompt"]},
             {"role": "assistant", "content": r["chosen"]}],
            tokenize=True, add_generation_prompt=False, enable_thinking=False,
        ))
        sources[si]["rows_used"] += 1
    if len(ids) >= need:
        break

if len(ids) < need:
    raise SystemExit(
        f"held-out pool yields {len(ids)} tokens, need {need} "
        f"({args.n_seqs}x{args.ctx_len}); raise --train-tail or lower --n-seqs"
    )

rows = [ids[i * args.ctx_len : (i + 1) * args.ctx_len] for i in range(args.n_seqs)]
sha = write_tokens(out / "tokens.bin", rows)

write_manifest(out, {
    "format_version": 1,
    "kind": "kl-eval-corpus",
    "tokenizer": str(Path(args.tokenizer).resolve()),
    "vocab_size": int(len(tok.vocab)),
    "ctx_len": args.ctx_len,
    "n_seqs": args.n_seqs,
    "n_tokens": args.n_seqs * args.ctx_len,
    "seed": args.seed,
    "chat_template": {"add_generation_prompt": False, "enable_thinking": False,
                      "turns": ["user:prompt", "assistant:chosen"]},
    "sources": sources,
    "tokens_sha256": sha,
    "created": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
    "notes": args.notes or "UF-derived (uf-cpm5) held-out chat eval, packed to ctx_len; "
                          "valid.jsonl first, then the train.jsonl tail.",
})

used = " + ".join(f"{s['rows_used']} rows from {Path(s['path']).name}" for s in sources if s["rows_used"])
print(f"corpus {out}: {args.n_seqs}x{args.ctx_len} = {need} tokens ({used})")
print(f"  tokens.bin sha256 {sha}")
print(f"  {sha256_file(out / 'tokens.bin') == sha and 'verified' or 'MISMATCH'}")
