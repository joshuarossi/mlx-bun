# GPTQ for qwen3_5 VL snapshots — a minimal fork of mlx-lm's shipped
# implementation (mlx_lm/quant/gptq.py, the oracle; Apple 2025, MIT), changed
# ONLY to: (1) restrict GPTQ + fallback quantization to language_model.*
# modules (the vision tower receives no calibration activations — its H stays
# a zero scalar and Cholesky would crash — and must stay bf16 for mlx-bun's
# raw-tensor vision loader); (2) parameterize the model/out dirs. Calibration
# data is mlx-lm's own calibration_v5 set (distinct from our ppl corpus — no
# eval-set contamination).
#
#   .venv/bin/python scripts/turboquant/tq-gptq.py --model <dir> \
#       --mlx-path <out> [--bits 4] [--group-size 64] \
#       [--fallback-bits 4] [--num-samples 32] [--sequence-length 512]

import argparse
import copy

import mlx.core as mx
import mlx.nn as nn
from mlx.utils import tree_flatten, tree_unflatten
from tqdm import tqdm

from mlx_lm.quant.gptq import Catcher, quantize
from mlx_lm.quant.utils import load_data
from mlx_lm.utils import compute_bits_per_weight, load, save


def is_language_linear(key, module):
    return isinstance(module, nn.Linear) and "vision_tower" not in key


def compute_inverse_hessian(H, damp_factor=1e-2):
    # verbatim from mlx_lm.quant.gptq (upper-Cholesky of the damped inverse),
    # parameterized damping: rank-deficient H (early layers see low-rank
    # calibration activations; 27B hidden 5120 exceeded the rank the standard
    # 1% damping could regularize) needs escalation — see gptq_one_guarded.
    with mx.stream(mx.cpu):
        H = mx.array(H)  # copy — escalation retries need the undamped H
        damp = damp_factor * mx.mean(mx.diag(H))
        diag = mx.arange(H.shape[0])
        H[diag, diag] += damp
        H = mx.linalg.cholesky(H)
        H = mx.linalg.cholesky_inv(H)
        Hinv = mx.linalg.cholesky(H, upper=True)
        return Hinv


def pack_flat(q_indices, bits):
    """Pack integer grid indices into mlx's flat little-endian bitstream
    (verified layout: element i occupies bits [i*bits, (i+1)*bits) of the
    row, words little-endian). Covers bits ∈ {3, 5, 6} which the upstream
    packer (whole-words-per-element shifts) cannot express; roundtrip-
    verified against mx.quantize at 3-bit (max|diff| 0.0)."""
    import numpy as np
    q = np.array(q_indices, dtype=np.uint8)
    rows, n = q.shape
    bitplane = np.zeros((rows, n * bits), dtype=np.uint8)
    for j in range(bits):
        bitplane[:, j::bits] = (q >> j) & 1
    packed = np.packbits(bitplane, axis=1, bitorder="little")
    return mx.array(np.frombuffer(packed.tobytes(), dtype=np.uint32).reshape(rows, -1))


def _final_pack(W, bits, scales, biases):
    if bits in (2, 4, 8):
        return quantize(W, bits, scales, biases)
    n_bins = 2**bits - 1
    q = mx.clip(mx.round((mx.unflatten(W, -1, (scales.shape[-1], -1)) - biases[..., None]) / scales[..., None]), 0.0, n_bins)
    q = mx.flatten(q, -2, -1).astype(mx.uint32)
    mx.eval(q)
    return pack_flat(q, bits)


def gptq_one(W_in, Hinv, bits, group_size):
    """Corrected GPTQ for one [out, in] weight: returns (scales, biases,
    packed) with the compensated rounding baked in. Paper-form update
    window [k, j) — see the fork header for the two upstream defects."""
    n_bins = 2**bits - 1

    @mx.compile
    def gptq_error(w, d, scales, biases):
        q = mx.clip(mx.round((w - biases) / scales), 0.0, n_bins)
        q = scales * q + biases
        return (w - q) / d

    W = W_in.astype(mx.float32)
    all_scales = []
    all_biases = []
    for i in range(0, W.shape[-1], group_size):
        j = i + group_size
        Wl = W[..., i:j]
        err = mx.zeros_like(Wl)
        _, scales, biases = mx.quantize(Wl, bits=bits, group_size=group_size)
        all_scales.append(scales)
        all_biases.append(biases)
        for k in range(group_size):
            k += i
            w = W[..., k : k + 1]
            d = Hinv[k, k]
            e = gptq_error(w, d, scales, biases)
            W[..., k : j] -= e @ Hinv[k : k + 1, k : j]
            err[..., k - i : k - i + 1] = e
            mx.eval(err, W)
        W[..., j:] -= err @ Hinv[i:j, j:]
    scales = mx.concatenate(all_scales, axis=-1)
    biases = mx.concatenate(all_biases, axis=-1)
    return scales, biases, _final_pack(W, bits, scales, biases)


def gptq_one_guarded(W_in, H, bits, group_size):
    """GPTQ with a divergence guard: rank-deficient Hessians make the
    compensation loop explode (2026-08-18 27B run: layer-0 down_proj scales
    grew 0.003 → 27 across column groups, max 28e6 — cosine ~0 vs source).
    Guard: GPTQ scales must stay within 4× the plain-RTN scale ceiling;
    on blow-up, retry with 10×/100×/1000× damping, else fall back to RTN
    (never worse than RTN by construction). Returns
    (scales, biases, packed, note)."""
    _, rtn_scales, _ = mx.quantize(W_in.astype(mx.float32), bits=bits, group_size=group_size)
    ceiling = 4.0 * float(mx.max(mx.abs(rtn_scales)))
    for damp in (1e-2, 1e-1, 1.0, 10.0):
        Hinv = compute_inverse_hessian(H, damp)
        mx.eval(Hinv)
        scales, biases, packed = gptq_one(W_in, Hinv, bits, group_size)
        if float(mx.max(mx.abs(scales))) <= ceiling:
            note = "" if damp == 1e-2 else f"damp={damp}"
            return scales, biases, packed, note
    # RTN fallback — identical to the mx.quantize grid, packed the same way.
    Wq, scales, biases = mx.quantize(W_in.astype(mx.float32), bits=bits, group_size=group_size)
    return scales, biases, Wq, "RTN-fallback"


def gptq_quantize_lm(model, data, bits, group_size, fallback_bits, fallback_group_size, batch_size=8):
    # === verbatim from mlx_lm.quant.gptq.gptq_quantize except the key filter ===
    layers = []
    for k, l in tree_flatten(model.leaf_modules(), is_leaf=nn.Module.is_module):
        if is_language_linear(k, l):
            layers.append((k, Catcher(l)))
    model.update_modules(tree_unflatten(layers))

    for e, s in tqdm(
        enumerate(range(0, len(data), batch_size)),
        total=len(data) // batch_size,
        desc="Computing Hessians",
    ):
        batch = data[s : s + batch_size]
        model(batch)
        mx.eval(layers)

    def compute_inverse_hessian(H):
        with mx.stream(mx.cpu):
            damp = 1e-2 * mx.mean(mx.diag(H))
            diag = mx.arange(H.shape[0])
            H[diag, diag] += damp
            H = mx.linalg.cholesky(H)
            H = mx.linalg.cholesky_inv(H)
            Hinv = mx.linalg.cholesky(H, upper=True)
            return Hinv

    @mx.compile
    def gptq_error(w, d, scales, biases):
        n_bins = 2**bits - 1
        q = mx.clip(mx.round((w - biases) / scales), 0.0, n_bins)
        q = scales * q + biases
        return (w - q) / d

    for lid, (key, l) in tqdm(enumerate(layers), total=len(layers), desc="Quantizing"):
        Hinv = compute_inverse_hessian(l.H)
        del l.H
        mx.eval(Hinv)

        orig_type = l.module.weight.dtype
        W = l.module.weight.astype(mx.float32)

        all_scales = []
        all_biases = []
        for i in range(0, W.shape[-1], group_size):
            j = i + group_size
            Wl = W[..., i:j]
            err = mx.zeros_like(Wl)
            _, scales, biases = mx.quantize(Wl, bits=bits, group_size=group_size)
            all_scales.append(scales)
            all_biases.append(biases)
            for k in range(group_size):
                k += i
                w = W[..., k : k + 1]
                d = Hinv[k, k]
                e = gptq_error(w, d, scales, biases)
                # Paper-form update: window [k, j) WITHIN the block — the k
                # term itself writes the quantized value (e·Hinv[k,k] = w−q);
                # upstream's `k : k+j` over-propagates past the block edge,
                # and its `err[..., k:k+1]` (global index on a group-local
                # buffer) silently no-ops for every block after the first —
                # the two defects partially cancel; both fixed here.
                W[..., k : j] -= e @ Hinv[k : k + 1, k : j]
                err[..., k - i : k - i + 1] = e
                mx.eval(err, W)
            W[..., j:] -= err @ Hinv[i:j, j:]

        scales = mx.concatenate(all_scales, axis=-1)
        biases = mx.concatenate(all_biases, axis=-1)
        Wq = quantize(W, bits, scales, biases)
        layer = l.module.to_quantized(bits=bits, group_size=group_size)
        layer.weight = Wq
        layer.scales = scales
        layer.biases = biases
        layer.set_dtype(orig_type)
        mx.eval(layer)
        layers[lid] = (key, layer)

    model.update_modules(tree_unflatten(layers))

    all_modules = tree_flatten(model.leaf_modules(), is_leaf=nn.Module.is_module)
    config = {"bits": bits, "group_size": group_size}
    fallback_config = {"bits": fallback_bits, "group_size": fallback_group_size}
    q_layers = []
    for k, l in all_modules:
        if "vision_tower" in k:
            continue  # bf16 vision stays raw (mlx-bun loader + no calibration)
        if hasattr(l, "to_quantized"):
            config[k] = fallback_config
            q_layers.append((k, l.to_quantized(**fallback_config)))
    if len(q_layers) > 0:
        model.update_modules(tree_unflatten(q_layers))
    # vision stays unquantized: mark eligible vision modules false so loaders
    # don't apply the default spec to them.
    for k, l in all_modules:
        if "vision_tower" in k and hasattr(l, "to_quantized"):
            config[k] = False
    return model, config


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", "-m", required=True)
    parser.add_argument("--mlx-path", required=True)
    parser.add_argument("--bits", type=int, default=4)
    parser.add_argument("--group-size", type=int, default=64)
    parser.add_argument("--fallback-bits", type=int, default=4)
    parser.add_argument("--fallback-group-size", type=int, default=64)
    parser.add_argument("--num-samples", type=int, default=32)
    parser.add_argument("--sequence-length", type=int, default=512)
    parser.add_argument("--seed", type=int, default=123)
    args = parser.parse_args()

    mx.random.seed(args.seed)
    model, tokenizer, config = load(args.model, lazy=True, return_config=True)
    calibration_data = load_data(tokenizer, args.num_samples, args.sequence_length)

    model, config["quantization"] = gptq_quantize_lm(
        model, calibration_data,
        args.bits, args.group_size,
        args.fallback_bits, args.fallback_group_size,
    )
    config["quantization_config"] = copy.copy(config["quantization"])
    print(f"bits per weight: {compute_bits_per_weight(model):.3f}")
    save(args.mlx_path, args.model, model, tokenizer, config)


if __name__ == "__main__":
    main()
