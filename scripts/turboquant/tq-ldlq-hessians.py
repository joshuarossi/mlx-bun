# Stage 1 of the Q2c LDLQ-weighted trellis arm: per-layer MLP input Hessians
# for the 27B qwen3_5 trunk, transformed into the FOLDED (γ+R1) basis, block-LDL
# factorized, written as the L factors BlockLDLQ consumes.
#
# Why L and not H: mlx's Cholesky is CPU-only (verified: n=17408 in 6.66 s,
# n=5120 in 0.14 s on M1 Max), and the TS build driver has no LAPACK binding.
# Factorizing here keeps the TS side to matmuls.
#
# Two Hessians per layer (QTIP collects one per input site):
#   * gate_proj/up_proj SHARE an input — the post_attention_layernorm output.
#     Captured PRE-γ (n(h) = h·rsqrt(mean(h²)+eps)) because the fold moves γ
#     into the weight: W' = (W⊙γ)@R1 and the folded layer's input is
#     x' = R1ᵀ·n(h), so H' = R1ᵀ·E[n nᵀ]·R1 with NO γ term. Capturing at
#     gate_proj instead would give Γ·E[n nᵀ]·Γ and force a division by γ.
#   * down_proj has its own (post-activation) input, silu(gate(x))*up(x).
#     down's fold is output-side (R1ᵀ@W), so its input Hessian is basis-free.
#
# Streamed layer-by-layer (tq-bf16-ceiling.py's technique, as in
# tq-gptq-27b.py): peak is one bf16 layer + the activation set + one Hessian.
# Checkpointed and RESUMABLE — re-run the same command.
#
#   .venv/bin/python -u scripts/turboquant/tq-ldlq-hessians.py \
#       --model <bf16-src> --calib runs/kl-corpus/uf-calib-512x128 \
#       --signs runs/q2a/r1-signs-5120-seed42.f32 --out <hdir> [--batch 16]

import argparse
import json
import time
from pathlib import Path

import mlx.core as mx
import mlx.nn as nn
import numpy as np

from mlx_lm.utils import load

import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from tq_kl_common import _mask_for, read_tokens, load_manifest  # noqa: E402

ap = argparse.ArgumentParser()
ap.add_argument("--model", required=True)
ap.add_argument("--calib", required=True, help="corpus dir with tokens.bin + manifest.json")
ap.add_argument("--signs", required=True, help="R1 sign vector dumped from src/quantize/rotate.ts")
ap.add_argument("--out", required=True)
ap.add_argument("--batch", type=int, default=16)
ap.add_argument("--block", type=int, default=256, help="BlockLDLQ block size (= trellis block T)")
ap.add_argument("--sigma-reg", type=float, default=1e-2,
                help="first regularize_H damping; escalates 10x on Cholesky/NaN failure")
args = ap.parse_args()

OUT = Path(args.out)
OUT.mkdir(parents=True, exist_ok=True)
state_path = OUT / "state.json"

cm = load_manifest(Path(args.calib))
toks = read_tokens(Path(args.calib) / "tokens.bin", cm["n_seqs"], cm["ctx_len"])
params = {
    "model": args.model, "calib": str(Path(args.calib).resolve()),
    "calib_sha256": cm["tokens_sha256"], "n_seqs": cm["n_seqs"], "ctx_len": cm["ctx_len"],
    "block": args.block, "sigma_reg0": args.sigma_reg,
}
state = json.loads(state_path.read_text()) if state_path.exists() else None
if state and state.get("params") != params:
    raise SystemExit(f"{OUT} was built with different params — delete it or match them")
next_layer = state["next_layer"] if state else 0
sites = state["sites"] if state else {}

signs = mx.array(np.fromfile(args.signs, dtype=np.float32))
print(f"R1 signs: n={signs.size} sum={float(mx.sum(signs)):.0f}", flush=True)


def to_folded_basis(H, s):
    """H' = R1ᵀ H R1 for R1 = diag(s)·H_n/√n, via two hadamard transforms."""
    n = H.shape[0]
    sc = 1.0 / (n ** 0.5)
    B = H * s[:, None] * s[None, :]
    Hf = mx.hadamard_transform(B, scale=sc)
    Hf = mx.hadamard_transform(mx.contiguous(Hf.T), scale=sc)
    return (Hf + Hf.T) * 0.5


def fold_input_dim(W, s):
    """W' = W @ R1 — byte-for-byte the op chain in src/quantize/rotate.ts
    foldLastAxis(): hadamard(W ⊙ signs, 1/√n)."""
    n = W.shape[-1]
    return mx.hadamard_transform(W * s, scale=1.0 / (n ** 0.5))


def _self_test():
    """R1 is orthogonal, and the LDLQ objective is basis-invariant:
    W' H' W'ᵀ must equal W H Wᵀ for W' = W@R1, H' = R1ᵀ H R1."""
    n = int(signs.size)
    eye = to_folded_basis(mx.eye(n), signs)
    err_i = float(mx.max(mx.abs(eye - mx.eye(n))))
    mx.random.seed(0)
    A = mx.random.normal((n, 512))
    H = (A @ A.T) / 512 + mx.eye(n) * 1e-3
    W = mx.random.normal((8, n))
    lhs = fold_input_dim(W, signs) @ to_folded_basis(H, signs) @ fold_input_dim(W, signs).T
    rhs = W @ H @ W.T
    err_o = float(mx.max(mx.abs(lhs - rhs)) / mx.max(mx.abs(rhs)))
    print(f"self-test: R1ᵀ·I·R1 vs I max|Δ|={err_i:.2e} | "
          f"W'H'W'ᵀ vs WHWᵀ rel={err_o:.2e}", flush=True)
    if err_i > 1e-3 or err_o > 1e-4:
        raise SystemExit("basis-transform self-test FAILED — refusing to build Hessians")


_self_test()


def block_LDL(H, b):
    """QTIP lib/utils/math_utils.py block_LDL, ported to mlx (CPU stream).
    Returns L with IDENTITY diagonal blocks (the strictly-block-lower part is
    the feedback operator BlockLDLQ uses), or None on failure."""
    n = H.shape[0]
    assert n % b == 0
    m = n // b
    with mx.stream(mx.cpu):
        try:
            L = mx.linalg.cholesky(H)
        except Exception as e:  # noqa: BLE001
            print(f"    cholesky failed: {type(e).__name__}: {str(e)[:70]}", flush=True)
            return None
        mx.eval(L)
        if bool(mx.any(mx.isnan(L))):
            return None
        # DL[i] = the i-th diagonal b x b block of L
        L4 = L.reshape(m, b, m, b)
        DL = mx.stack([L4[i, :, i, :] for i in range(m)])          # [m, b, b]
        DLinv = mx.linalg.inv(DL)
        mx.eval(DLinv)
        if bool(mx.any(mx.isnan(DLinv))):
            return None
        # L[:, i, :] = L[:, i, :] @ DLinv[i]
        L3 = L.reshape(n, m, b)
        cols = [L3[:, i, :] @ DLinv[i] for i in range(m)]
        L = mx.stack(cols, axis=1).reshape(n, n)
        mx.eval(L)
        if bool(mx.any(mx.isnan(L))):
            return None
    # QTIP then overwrites the DIAGONAL blocks with identity. Skipped here: with
    # buf_size == 1 (buf_cols == td_y == block) BlockLDLQ reads prod[block] only
    # BEFORE that block contributes to it, and never re-reads a finished block,
    # so the diagonal blocks of L are never consumed. Rebuilding them would cost
    # an extra 1.2 GiB copy and 68x68 graph nodes at n=17408 for no effect.
    return L


def regularize(H, sigma_reg):
    """QTIP regularize_H: normalize by the mean diagonal, add sigma_reg, restore."""
    dm = mx.mean(mx.diag(H))
    n = H.shape[0]
    return (H / dm + mx.eye(n) * sigma_reg) * dm


def factorize(H, name):
    """regularize -> block_LDL, escalating sigma_reg. Returns (L, sigma, note)."""
    sigma = args.sigma_reg
    for _ in range(5):
        L = block_LDL(regularize(H.astype(mx.float32), sigma), args.block)
        if L is not None:
            off = float(mx.max(mx.abs(L)))
            if off < 1e4:
                return L, sigma, ("" if sigma == args.sigma_reg else f"sigma={sigma:g}")
            print(f"    {name}: |L|max={off:.3g} too large at sigma={sigma:g}", flush=True)
        sigma *= 10.0
    return None, sigma, "UNWEIGHTED-FALLBACK"


model, _ = load(args.model, lazy=True)
inner = model.language_model.model
n_layers = len(inner.layers)
eps = float(inner.layers[0].post_attention_layernorm.eps)
H_DIM = int(signs.size)


class Stub(nn.Module):
    def __call__(self, *a, **k):
        raise RuntimeError("stripped layer called")


class NormCatch(nn.Module):
    """Wraps post_attention_layernorm: accumulates E[n nᵀ] on the PRE-γ
    normalized activation, then delegates to the real norm."""

    def __init__(self, mod):
        super().__init__()
        self.mod = mod
        self.acc = None

    def __call__(self, x, *a, **k):
        xf = x.reshape(-1, x.shape[-1]).astype(mx.float32)
        n = xf * mx.rsqrt(mx.mean(xf * xf, axis=-1, keepdims=True) + eps)
        self.acc = n.T @ n if self.acc is None else self.acc + n.T @ n
        mx.eval(self.acc)
        return self.mod(x, *a, **k)


class LinCatch(nn.Module):
    """Wraps down_proj: accumulates E[y yᵀ] on its input."""

    def __init__(self, mod):
        super().__init__()
        self.mod = mod
        self.acc = None

    def __call__(self, x, *a, **k):
        xf = x.reshape(-1, x.shape[-1]).astype(mx.float32)
        self.acc = xf.T @ xf if self.acc is None else self.acc + xf.T @ xf
        mx.eval(self.acc)
        return self.mod(x, *a, **k)


# activation set: fresh on a cold start, from the checkpoint on resume
if next_layer == 0:
    hs = []
    for s in range(0, cm["n_seqs"], args.batch):
        h = inner.embed_tokens(mx.array(toks[s : s + args.batch]))
        mx.eval(h)
        hs.append(h)
else:
    saved = mx.load(str(OUT / "hs.safetensors"))
    hs = [saved[f"h{i}"] for i in range(len(saved))]
    mx.eval(hs)
    print(f"resuming at layer {next_layer}/{n_layers}", flush=True)
mx.clear_cache()

t0 = time.time()
for li in range(n_layers):
    layer = inner.layers[li]
    if li < next_layer:
        inner.layers[li] = Stub()
        mx.clear_cache()
        continue

    nc = NormCatch(layer.post_attention_layernorm)
    lc = LinCatch(layer.mlp.down_proj)
    layer.post_attention_layernorm = nc
    layer.mlp.down_proj = lc

    new_hs = []
    for h in hs:
        out = layer(h, mask=_mask_for(layer, h), cache=None)
        mx.eval(out)
        new_hs.append(out)
    hs = new_hs

    H_mlp, H_down = nc.acc, lc.acc
    layer.post_attention_layernorm = nc.mod
    layer.mlp.down_proj = lc.mod
    mx.clear_cache()

    # gate/up: into the folded (γ+R1) basis. down_proj needs no transform.
    Hf = to_folded_basis(H_mlp, signs)
    mx.eval(Hf)
    del H_mlp

    rec = {}
    for name, H in (("mlp", Hf), ("down", H_down)):
        ts = time.time()
        L, sigma, note = factorize(H, f"L{li}.{name}")
        took = time.time() - ts
        if L is None:
            rec[name] = {"status": "fallback", "sigma": sigma, "seconds": round(took, 1)}
            print(f"  layer {li} {name}: UNWEIGHTED-FALLBACK ({took:.1f}s)", flush=True)
        else:
            mx.save_safetensors(str(OUT / f"layer-{li:03d}-{name}.safetensors"), {"L": L})
            rec[name] = {"status": "ok", "sigma": sigma, "n": int(H.shape[0]),
                         "seconds": round(took, 1), "note": note}
        del L
        mx.clear_cache()
    del Hf, H_down
    sites[str(li)] = rec

    inner.layers[li] = Stub()
    mx.clear_cache()
    mx.save_safetensors(str(OUT / "hs.safetensors"), {f"h{i}": h for i, h in enumerate(hs)})
    state_path.write_text(json.dumps({
        "params": params, "next_layer": li + 1, "sites": sites,
        "calibration": {
            "corpus": str(Path(args.calib).resolve()),
            "tokens_sha256": cm["tokens_sha256"],
            "n_tokens": cm["n_tokens"],
            "domain": "uf-cpm5 chat (UltraFeedback-derived), SAME domain+template+tokenizer "
                      "as the scored uf-4096x32 corpus, DISJOINT rows "
                      "(train.jsonl[0:10595]; eval uses valid.jsonl + the last 4096 train rows)",
            "alternative_not_used": "mlx-lm load_data / calibration_v5.txt (general web text) — "
                                    "rejected because a calibration-domain mismatch was measured "
                                    "to hurt GPTQ on this chat eval",
        },
    }, indent=2))
    el = time.time() - t0
    print(f"  layer {li + 1}/{n_layers} done ({el / 60:.1f} min elapsed, "
          f"{el / (li + 1 - next_layer) :.0f}s/layer)", flush=True)

print(f"DONE in {(time.time() - t0) / 60:.1f} min", flush=True)
fb = sum(1 for r in sites.values() for s in r.values() if s["status"] == "fallback")
print(f"factorization fallbacks: {fb}/{2 * n_layers}", flush=True)
