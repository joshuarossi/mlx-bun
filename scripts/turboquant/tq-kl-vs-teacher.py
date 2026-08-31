# Score any MLX model directory against a bf16 teacher dump.
#
# Teacher-forces the dump's own tokens.bin through the candidate (stock mlx-lm,
# so quantized artifacts load unchanged — cross-stack parity is certified) and
# computes, per position, over the teacher's top-k support:
#
#   p_j    = exp(ref_logit_j - ref_logsumexp_FULL)      # TRUE probabilities
#   log q_j= cand_logit_j - logsumexp_FULL(cand)
#   KL     = sum_j p_j * (log p_j - log q_j)
#
# p is NOT renormalized over the top-k, so KL is a lower bound on the full-vocab
# KL that tightens as the captured mass sum_j p_j approaches 1; the run warns
# if the mean captured mass drops below 0.9999. All arithmetic is float32.
#
# Memory: the candidate's weights stay resident (17 GB at 27B 4-bit) and the
# lm_head runs in position chunks, so the transient is one [chunk, vocab]
# float32 block. --stream falls back to the layer-streamed trunk of
# tq-dump-teacher-logits.py for a candidate that does not fit.
#
#   .venv/bin/python -u scripts/turboquant/tq-kl-vs-teacher.py \
#       --model <model_dir> --dump runs/kl-teacher/<tag> \
#       [--head-chunk 512] [--max-seqs N] [--stream] [--out row.json]

import argparse
import json
import sys
import time
from pathlib import Path

import mlx.core as mx
import numpy as np
from mlx_lm.utils import load

sys.path.insert(0, str(Path(__file__).resolve().parent))
from tq_kl_common import (  # noqa: E402
    dense_hidden, head_gather, load_manifest, read_records, read_tokens,
    record_bytes, sha256_file, streamed_hidden, unwrap,
)

ap = argparse.ArgumentParser()
ap.add_argument("--model", required=True)
ap.add_argument("--dump", required=True, help="runs/kl-teacher/<tag>")
ap.add_argument("--head-chunk", type=int, default=512)
ap.add_argument("--max-seqs", type=int, default=-1)
ap.add_argument("--stream", action="store_true",
                help="layer-stream the candidate too (model larger than RAM)")
ap.add_argument("--out", default="", help="write the JSON row here as well")
ap.add_argument("--label", default="")
ap.add_argument("--mass-warn", type=float, default=0.9999,
                help="warn below this mean captured mass (measured: top-2048 captures "
                     "~0.9986 of the mass but 99.79%% of the full-vocab KL on a 0.8B)")
args = ap.parse_args()

dump = Path(args.dump)
dm = load_manifest(dump)
if dm.get("format_version") != 1:
    raise SystemExit(f"{dump}: unsupported format_version {dm.get('format_version')}")
ctx_len, top_k = dm["ctx_len"], dm["top_k"]
n_pos = dm["positions_per_seq"]
n_seqs = dm["n_seqs"] if args.max_seqs < 0 else min(args.max_seqs, dm["n_seqs"])
rec = record_bytes(top_k)
toks = read_tokens(dump / "tokens.bin", dm["n_seqs"], ctx_len)

t0 = time.time()
model, _ = load(args.model, lazy=args.stream)
_, inner, head = unwrap(model)
print(f"loaded {args.model} in {time.time() - t0:.1f}s "
      f"({'streamed' if args.stream else 'resident'}); scoring {n_seqs} x {n_pos} positions",
      flush=True)

kl = np.empty(n_seqs * n_pos, dtype=np.float64)
mass = np.empty(n_seqs * n_pos, dtype=np.float64)
agree = 0
w = 0

t1 = time.time()
if args.stream:
    streams = [mx.array(toks[i : i + 1]) for i in range(n_seqs)]
    hiddens = streamed_hidden(inner, streams, progress_every=8,
                              log=lambda m: print(m, flush=True))
else:
    hiddens = None

for i in range(n_seqs):
    hn = hiddens[i] if args.stream else dense_hidden(inner, mx.array(toks[i : i + 1]))
    with open(dump / f"seq-{i}.bin", "rb") as f:
        ref_idx, ref_log, ref_lse = read_records(f, top_k, 0, n_pos)
    # p over the teacher's support: TRUE probabilities (full-vocab lse).
    log_p = ref_log - ref_lse[:, None]
    p = np.exp(log_p, dtype=np.float32)
    for start, cand_log, cand_lse, cand_top1 in head_gather(
            head, hn, ref_idx, args.head_chunk, n_pos):
        end = start + cand_log.shape[0]
        log_q = cand_log - cand_lse[:, None]
        d = (p[start:end] * (log_p[start:end] - log_q)).sum(axis=-1)
        kl[w + start : w + end] = d
        mass[w + start : w + end] = p[start:end].sum(axis=-1)
        agree += int((cand_top1 == ref_idx[start:end, 0]).sum())
    w += n_pos
    if args.stream:
        hiddens[i] = None
    del hn, ref_idx, ref_log, ref_lse, log_p, p
    mx.clear_cache()
    print(f"  seq {i}: mean KL {kl[w - n_pos:w].mean():.6f}  [{time.time() - t1:.0f}s]", flush=True)

total = n_seqs * n_pos
row = {
    "model": str(Path(args.model).resolve()),
    "label": args.label or Path(args.model).name,
    "dump": str(dump.resolve()),
    "dump_tag": dump.name,
    "teacher": dm["model"],
    "corpus_sha256": dm["corpus_sha256"],
    "tokens_sha256": sha256_file(dump / "tokens.bin"),
    "n_seqs": n_seqs,
    "ctx_len": ctx_len,
    "positions": total,
    "top_k": top_k,
    "mean_kl": float(kl.mean()),
    "median_kl": float(np.median(kl)),
    "p95_kl": float(np.percentile(kl, 95)),
    "max_kl": float(kl.max()),
    "top1_agreement": agree / total,
    "mean_captured_mass": float(mass.mean()),
    "min_captured_mass": float(mass.min()),
    "streamed": bool(args.stream),
    "seconds": round(time.time() - t0, 1),
    "created": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
}
line = json.dumps(row)
if args.out:
    Path(args.out).parent.mkdir(parents=True, exist_ok=True)
    Path(args.out).write_text(line + "\n")
print(line)

print(f"\nRESULT kl-vs-teacher {row['label']} vs {dump.name}")
print(f"  KL(ref||cand)   mean {row['mean_kl']:.6f}  median {row['median_kl']:.6f}  "
      f"p95 {row['p95_kl']:.6f}  max {row['max_kl']:.4f}")
print(f"  top-1 agreement {row['top1_agreement'] * 100:.2f}%  ({agree}/{total} positions)")
print(f"  captured mass   mean {row['mean_captured_mass']:.6f}  min {row['min_captured_mass']:.6f}"
      f"  (top-{top_k} of the teacher)")
if row["mean_captured_mass"] < args.mass_warn:
    print(f"  WARNING captured mass {row['mean_captured_mass']:.6f} < {args.mass_warn} — the "
          f"top-{top_k} support misses real probability, so KL is a lower bound. Measured on "
          f"a 0.8B teacher: k=2048 captures 0.9986 mass / 99.79% of the full-vocab KL, "
          f"k=32768 is needed for 0.9999 mass (16x the dump). Raise --top-k in the dump, or "
          f"--mass-warn here once the truncation bias is known to be acceptable.")
