# Teacher-forced logit dump from a bf16 model that need not fit in RAM.
#
# The 27B bf16 trunk is ~52 GB on a 32 GB box, so the forward is LAYER-STREAMED
# exactly as scripts/turboquant/tq-bf16-ceiling.py does it: lazy load, push
# every sequence through layer i while its bf16 weights are resident, strip the
# layer, carry activations forward. Peak ~= one layer + the activation set
# (32x4096x5120 bf16 = 1.3 GB at 27B). The lm_head runs in position chunks so
# the [chunk, vocab] float32 block stays bounded. Logits are float32 at every
# reduction; only the stored top-k values are narrowed to float16 (dump
# contract), and the full-vocab logsumexp is kept in float32 so the recorded
# probabilities are TRUE probabilities, not top-k renormalized ones.
#
#   .venv/bin/python -u scripts/turboquant/tq-dump-teacher-logits.py \
#       --model <bf16_dir> --corpus runs/kl-corpus/<name> \
#       --out runs/kl-teacher/<tag> [--top-k 2048] [--head-chunk 512] \
#       [--seq-start 0] [--seq-end N]
#
# Output contract (format_version 1) — see scripts/turboquant/tq_kl_common.py.

import argparse
import sys
import time
from pathlib import Path

import mlx.core as mx
from mlx_lm.utils import load

sys.path.insert(0, str(Path(__file__).resolve().parent))
from tq_kl_common import (  # noqa: E402
    head_topk, load_manifest, pack_records, read_tokens, record_bytes,
    sha256_file, streamed_hidden, unwrap, write_manifest, write_tokens,
)

ap = argparse.ArgumentParser()
ap.add_argument("--model", required=True, help="bf16 MLX model dir")
ap.add_argument("--corpus", required=True, help="dir from tq-build-kl-corpus.py")
ap.add_argument("--out", required=True, help="runs/kl-teacher/<tag>")
ap.add_argument("--top-k", type=int, default=2048)
ap.add_argument("--head-chunk", type=int, default=512)
ap.add_argument("--seq-start", type=int, default=0)
ap.add_argument("--seq-end", type=int, default=-1, help="exclusive; -1 = all")
ap.add_argument("--notes", default="")
args = ap.parse_args()

corpus = Path(args.corpus)
cm = load_manifest(corpus)
ctx_len, n_all = cm["ctx_len"], cm["n_seqs"]
if sha256_file(corpus / "tokens.bin") != cm["tokens_sha256"]:
    raise SystemExit(f"{corpus}/tokens.bin does not match its manifest sha256")
toks = read_tokens(corpus / "tokens.bin", n_all, ctx_len)

lo = args.seq_start
hi = n_all if args.seq_end < 0 else min(args.seq_end, n_all)
if not 0 <= lo < hi:
    raise SystemExit(f"empty sequence range [{lo},{hi})")
sel = toks[lo:hi]
n_seqs = sel.shape[0]
n_pos = ctx_len - 1  # record r = distribution over token r+1

out = Path(args.out)
out.mkdir(parents=True, exist_ok=True)

t0 = time.time()
model, _ = load(args.model, lazy=True)
_, inner, head = unwrap(model)
print(f"loaded (lazy) {args.model} in {time.time() - t0:.1f}s; "
      f"{len(inner.layers)} layers, streaming {n_seqs} seq x {ctx_len} tok", flush=True)

streams = [mx.array(sel[i : i + 1]) for i in range(n_seqs)]
t1 = time.time()
hs = streamed_hidden(inner, streams, progress_every=8,
                     log=lambda m: print(m + f"  [{time.time() - t1:.0f}s]", flush=True))
t_fwd = time.time() - t1
print(f"trunk done in {t_fwd:.1f}s ({n_seqs * ctx_len / t_fwd:.0f} tok/s)", flush=True)

t2 = time.time()
rec = record_bytes(args.top_k)
for i, hn in enumerate(hs):
    # Files are seq-0..seq-(n_seqs-1) of THIS run: a --seq-start/--seq-end
    # slice produces a self-contained dump (its own tokens.bin), never a
    # fragment that has to be stitched.
    path = out / f"seq-{i}.bin"
    with open(path, "wb") as f:
        for _, idx, val, lse in head_topk(head, hn, args.top_k, args.head_chunk, n_pos):
            f.write(pack_records(idx, val, lse))
    got = path.stat().st_size
    if got != n_pos * rec:
        raise SystemExit(f"{path}: wrote {got} bytes, expected {n_pos * rec}")
    print(f"  seq {i} (corpus row {lo + i}): {got / 1e6:.1f} MB  [{time.time() - t2:.0f}s]", flush=True)
    hs[i] = None
    mx.clear_cache()
t_head = time.time() - t2

# tokens.bin in the dump is the exact teacher-forced stream that was scored.
tok_sha = write_tokens(out / "tokens.bin", sel.tolist())

write_manifest(out, {
    "format_version": 1,
    "model": str(Path(args.model).resolve()),
    "corpus_sha256": cm["tokens_sha256"],
    "ctx_len": ctx_len,
    "n_seqs": n_seqs,
    "top_k": args.top_k,
    "positions_per_seq": n_pos,
    "created": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
    "notes": (args.notes + " | " if args.notes else "")
             + f"layer-streamed bf16 teacher forcing; corpus={corpus.resolve()}; "
               f"seqs {lo}..{hi - 1} of {n_all}; dump tokens.bin sha256={tok_sha}; "
               f"seq-<i>.bin record = int32[{args.top_k}] idx desc + "
               f"float16[{args.top_k}] logits + float32 full-vocab logsumexp "
               f"({rec} B/record, record r = distribution over token r+1); "
               f"trunk {t_fwd:.0f}s, heads {t_head:.0f}s",
})

print(f"RESULT teacher-dump {out}: {n_seqs} seq x {n_pos} pos x top{args.top_k}, "
      f"{n_seqs * n_pos * rec / 1e9:.2f} GB, {time.time() - t0:.0f}s total")
