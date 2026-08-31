# Shared plumbing for the KL-vs-bf16 instrument (tq-build-kl-corpus.py,
# tq-dump-teacher-logits.py, tq-kl-vs-teacher.py). Runs under the pinned
# oracle venv (docs/reference/environment.md) — stock mlx-lm only, so a
# quantized artifact and its bf16 parent are scored by the SAME code.
#
# The teacher-dump on-disk contract (format_version 1) lives here in ONE
# place; the TypeScript reader is written against the same layout:
#
#   <dump>/manifest.json  { format_version, model, corpus_sha256, ctx_len,
#                           n_seqs, top_k, positions_per_seq, created, notes }
#   <dump>/tokens.bin     int32 LE [n_seqs][ctx_len]
#   <dump>/seq-<i>.bin    ctx_len-1 records, record r = distribution over the
#                         token at index r+1 (i.e. logits at position r):
#                           int32  [top_k]  top-k reference logit indices, desc
#                           float16[top_k]  those reference logits
#                           float32         logsumexp over the FULL vocab (f32)

import hashlib
import json
from pathlib import Path

import mlx.core as mx
import mlx.nn as nn
import numpy as np
from mlx_lm.models.base import create_attention_mask

try:  # only qwen3_5-family trunks have a DeltaNet mask
    from mlx_lm.models.qwen3_5 import create_ssm_mask
except Exception:  # pragma: no cover - other architectures
    create_ssm_mask = None


# ---------------------------------------------------------------------------
# record layout
# ---------------------------------------------------------------------------

def record_bytes(top_k: int) -> int:
    """int32[K] + float16[K] + float32."""
    return 4 * top_k + 2 * top_k + 4


def pack_records(idx: np.ndarray, val: np.ndarray, lse: np.ndarray) -> bytes:
    """[c,K] int32 + [c,K] float16 + [c] float32 -> concatenated records."""
    c, k = idx.shape
    rec = record_bytes(k)
    buf = np.empty((c, rec), dtype=np.uint8)
    buf[:, : 4 * k] = np.ascontiguousarray(idx, dtype="<i4").view(np.uint8).reshape(c, 4 * k)
    buf[:, 4 * k : 6 * k] = np.ascontiguousarray(val, dtype="<f2").view(np.uint8).reshape(c, 2 * k)
    buf[:, 6 * k :] = np.ascontiguousarray(lse, dtype="<f4").view(np.uint8).reshape(c, 4)
    return buf.tobytes()


def read_records(fh, top_k: int, start: int, count: int):
    """-> (idx int32[c,K], logits float32[c,K], lse float32[c])."""
    rec = record_bytes(top_k)
    fh.seek(start * rec)
    raw = np.frombuffer(fh.read(count * rec), dtype=np.uint8)
    if raw.size != count * rec:
        raise RuntimeError(f"short read: wanted {count} records at {start}")
    raw = raw.reshape(count, rec)
    idx = raw[:, : 4 * top_k].copy().view("<i4")
    val = raw[:, 4 * top_k : 6 * top_k].copy().view("<f2").astype(np.float32)
    lse = raw[:, 6 * top_k :].copy().view("<f4")[:, 0]
    return idx, val, lse


# ---------------------------------------------------------------------------
# token streams
# ---------------------------------------------------------------------------

def sha256_file(path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def write_tokens(path, rows) -> str:
    """rows: [n_seqs][ctx_len] python ints -> int32 LE. Returns sha256."""
    arr = np.asarray(rows, dtype="<i4")
    if arr.ndim != 2:
        raise ValueError(f"tokens must be 2-D, got {arr.shape}")
    Path(path).write_bytes(arr.tobytes())
    return sha256_file(path)


def read_tokens(path, n_seqs: int, ctx_len: int) -> np.ndarray:
    arr = np.fromfile(path, dtype="<i4")
    if arr.size != n_seqs * ctx_len:
        raise RuntimeError(
            f"{path}: {arr.size} ids, manifest says {n_seqs}x{ctx_len}={n_seqs * ctx_len}"
        )
    return arr.reshape(n_seqs, ctx_len)


def load_manifest(dirpath) -> dict:
    return json.loads((Path(dirpath) / "manifest.json").read_text())


def write_manifest(dirpath, obj) -> None:
    (Path(dirpath) / "manifest.json").write_text(json.dumps(obj, indent=2) + "\n")


# ---------------------------------------------------------------------------
# model plumbing (stock mlx-lm objects)
# ---------------------------------------------------------------------------

class Stub(nn.Module):
    """Replaces a finished layer so its weights free; must never be called."""

    def __call__(self, *a, **k):
        raise RuntimeError("stripped layer called — streaming bookkeeping bug")


def unwrap(model):
    """-> (lm, inner, head_fn). `lm` owns lm_head/args, `inner` owns layers."""
    lm = getattr(model, "language_model", model)
    inner = lm.model
    tie = bool(getattr(getattr(lm, "args", None), "tie_word_embeddings", False))
    head = (lambda x: inner.embed_tokens.as_linear(x)) if tie else lm.lm_head
    return lm, inner, head


def _mask_for(layer, h):
    if getattr(layer, "is_linear", False):
        if create_ssm_mask is None:
            raise RuntimeError("linear-attention layer but create_ssm_mask unavailable")
        return create_ssm_mask(h, None)
    return create_attention_mask(h, None)


def streamed_hidden(inner, streams, progress_every=8, log=print):
    """Layer-STREAMED teacher-forced forward (tq-bf16-ceiling.py's technique):
    push every stream through layer i while its weights are resident, then
    strip the layer. Peak ~= one layer + the activation set. Returns the
    FINAL-NORMED hidden states, one per stream. Destroys `inner`."""
    hs = []
    for s in streams:
        h = inner.embed_tokens(s)
        mx.eval(h)
        hs.append(h)
    mx.clear_cache()

    n = len(inner.layers)
    for li in range(n):
        layer = inner.layers[li]
        new_hs = []
        for h in hs:
            out = layer(h, mask=_mask_for(layer, h), cache=None)
            mx.eval(out)
            new_hs.append(out)
        hs = new_hs
        inner.layers[li] = Stub()
        mx.clear_cache()
        if progress_every and (li + 1) % progress_every == 0:
            log(f"  layer {li + 1}/{n}")

    out = []
    for h in hs:
        hn = inner.norm(h)
        mx.eval(hn)
        out.append(hn)
    mx.clear_cache()
    return out


def dense_hidden(inner, tokens):
    """Whole-weights forward of one [1, L] stream -> final-normed hidden.
    mlx-lm trunks apply the final norm inside `inner.__call__`."""
    hn = inner(tokens)
    mx.eval(hn)
    return hn


def head_topk(head, hn, top_k, chunk, n_pos):
    """Yield (start, idx[c,K] int32, logits[c,K] float16, lse[c] float32) over
    positions 0..n_pos-1 of `hn`, computing logits in float32. Chunked so the
    [chunk, vocab] float32 block stays bounded."""
    for start in range(0, n_pos, chunk):
        end = min(start + chunk, n_pos)
        logits = head(hn[:, start:end]).astype(mx.float32)[0]  # [c, V]
        lse = mx.logsumexp(logits, axis=-1)  # [c]
        part = mx.argpartition(-logits, top_k, axis=-1)[:, :top_k]
        vals = mx.take_along_axis(logits, part, axis=-1)
        order = mx.argsort(-vals, axis=-1)
        idx = mx.take_along_axis(part, order, axis=-1).astype(mx.int32)
        top = mx.take_along_axis(vals, order, axis=-1).astype(mx.float16)
        mx.eval(idx, top, lse)
        yield start, np.array(idx), np.array(top), np.array(lse)
        del logits, lse, part, vals, order, idx, top
        mx.clear_cache()


def head_gather(head, hn, ref_idx, chunk, n_pos):
    """Yield (start, cand_logits_at_ref_idx[c,K] float32, cand_lse[c] float32,
    cand_argmax[c] int32) — the candidate side of the KL, f32 throughout."""
    for start in range(0, n_pos, chunk):
        end = min(start + chunk, n_pos)
        logits = head(hn[:, start:end]).astype(mx.float32)[0]  # [c, V]
        lse = mx.logsumexp(logits, axis=-1)
        top1 = mx.argmax(logits, axis=-1).astype(mx.int32)
        gi = mx.array(np.ascontiguousarray(ref_idx[start:end]))
        gathered = mx.take_along_axis(logits, gi, axis=-1)
        mx.eval(lse, top1, gathered)
        yield start, np.array(gathered), np.array(lse), np.array(top1)
        del logits, lse, top1, gi, gathered
        mx.clear_cache()
