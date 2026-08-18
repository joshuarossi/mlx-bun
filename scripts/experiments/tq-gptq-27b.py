# Chunked, true-sequential GPTQ for the 27B qwen3_5 VL trunk on a 32 GB box.
#
# mlx-lm's stock gptq loads the whole bf16 model and holds every Hessian at
# once (54 GB + ~100 GB) — impossible here. This driver processes layer by
# layer with the model loaded LAZY: for each decoder layer, (1) catch input
# Hessians by forwarding the calibration activations through the bf16 layer
# (outputs never evaluated — H depends only on inputs), (2) GPTQ each linear
# with the corrected update (scripts/experiments/tq-gptq.py: gptq_one) and
# swap it to its quantized module (frees the bf16), (3) propagate activations
# through the now-QUANTIZED layer (true-sequential — later layers calibrate
# against the actual degraded inputs). Peak ≈ quantized prefix + one bf16
# layer + one Hessian ≈ 19 GB. Embeddings quantize RTN (not a Linear); the
# lm_head gets GPTQ on final-norm activations; the vision tower stays bf16.
#
#   .venv/bin/python scripts/experiments/tq-gptq-27b.py --model <bf16-trunk> \
#       --mlx-path <out> [--bits 4] [--group-size 64] [--num-samples 64] \
#       [--sequence-length 512]

import argparse
import copy
import sys
import time

import mlx.core as mx
import mlx.nn as nn
from tqdm import tqdm

sys.path.insert(0, "scripts/experiments")
from importlib import import_module

tq_gptq = import_module("tq-gptq")
gptq_one = tq_gptq.gptq_one
compute_inverse_hessian = tq_gptq.compute_inverse_hessian

from mlx_lm.models.base import create_attention_mask
from mlx_lm.models.qwen3_5 import create_ssm_mask
from mlx_lm.quant.gptq import Catcher
from mlx_lm.quant.utils import load_data
from mlx_lm.utils import compute_bits_per_weight, load, save

FULL_ATTN_LINEARS = ["q_proj", "k_proj", "v_proj", "o_proj"]
DELTANET_LINEARS = ["in_proj_qkv", "in_proj_z", "in_proj_b", "in_proj_a", "out_proj"]
MLP_LINEARS = ["gate_proj", "up_proj", "down_proj"]


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--model", "-m", required=True)
    p.add_argument("--mlx-path", required=True)
    p.add_argument("--bits", type=int, default=4)
    p.add_argument("--group-size", type=int, default=64)
    p.add_argument("--num-samples", type=int, default=64)
    p.add_argument("--sequence-length", type=int, default=512)
    p.add_argument("--batch-size", type=int, default=8)
    p.add_argument("--seed", type=int, default=123)
    args = p.parse_args()

    mx.random.seed(args.seed)
    model, tokenizer, config = load(args.model, lazy=True, return_config=True)
    data = load_data(tokenizer, args.num_samples, args.sequence_length)
    batches = [data[s : s + args.batch_size] for s in range(0, len(data), args.batch_size)]

    lm = model.language_model
    inner = lm.model  # embed_tokens, layers, norm
    bits, gs = args.bits, args.group_size

    def swap_quantized(parent, name, H):
        linear = getattr(parent, name)
        if isinstance(linear, Catcher):
            linear = linear.module
        Hinv = compute_inverse_hessian(H)
        mx.eval(Hinv)
        orig_type = linear.weight.dtype
        scales, biases, Wq = gptq_one(linear.weight, Hinv, bits, gs)
        q = linear.to_quantized(bits=bits, group_size=gs)
        q.weight = Wq
        q.scales = scales
        q.biases = biases
        q.set_dtype(orig_type)
        mx.eval(q)
        setattr(parent, name, q)

    # Embed: forward the calibration set (bf16 rows), then swap to RTN-4bit.
    hs = []
    for b in batches:
        h = inner.embed_tokens(b)
        mx.eval(h)
        hs.append(h)
    inner.embed_tokens = inner.embed_tokens.to_quantized(group_size=gs, bits=bits)
    mx.eval(inner.embed_tokens)
    mx.clear_cache()

    t0 = time.time()
    for li, layer in enumerate(tqdm(inner.layers, desc="Layers")):
        is_linear_attn = bool(layer.is_linear)
        attn_parent = layer.linear_attn if is_linear_attn else layer.self_attn
        attn_names = DELTANET_LINEARS if is_linear_attn else FULL_ATTN_LINEARS
        sites = [(attn_parent, n) for n in attn_names] + [(layer.mlp, n) for n in MLP_LINEARS]

        # 1. Catch pass (bf16 weights, outputs discarded unevaluated).
        for parent, name in sites:
            setattr(parent, name, Catcher(getattr(parent, name)))
        for h in hs:
            fa_mask = create_attention_mask(h, None)
            ssm_mask = create_ssm_mask(h, None)
            layer(h, mask=ssm_mask if is_linear_attn else fa_mask, cache=None)
            for parent, name in sites:
                mx.eval(getattr(parent, name).H)
        # 2. GPTQ + swap.
        for parent, name in sites:
            catcher = getattr(parent, name)
            H = catcher.H
            catcher.H = None
            swap_quantized(parent, name, H)
            del H
            mx.clear_cache()
        # 3. Propagate through the quantized layer.
        new_hs = []
        for h in hs:
            fa_mask = create_attention_mask(h, None)
            ssm_mask = create_ssm_mask(h, None)
            out = layer(h, mask=ssm_mask if is_linear_attn else fa_mask, cache=None)
            mx.eval(out)
            new_hs.append(out)
        for h in hs:
            del h
        hs = new_hs
        mx.clear_cache()

    # lm_head: GPTQ on final-norm activations (tied models have no separate
    # head — the quantized embedding already covers it).
    if isinstance(getattr(lm, "lm_head", None), nn.Linear):
        lm.lm_head = Catcher(lm.lm_head)
        for h in hs:
            hn = inner.norm(h)
            lm.lm_head(hn)
            mx.eval(lm.lm_head.H)
        H = lm.lm_head.H
        lm.lm_head.H = None
        swap_quantized(lm, "lm_head", H)
        mx.clear_cache()

    # Quantization block: default bits/gs; vision-tower eligible linears
    # explicitly false (they stay bf16 for the raw-tensor vision loader).
    qcfg = {"group_size": gs, "bits": bits}
    from mlx.utils import tree_flatten
    for k, l in tree_flatten(model.leaf_modules(), is_leaf=nn.Module.is_module):
        if "vision_tower" in k and hasattr(l, "to_quantized"):
            qcfg[k] = False
    config["quantization"] = qcfg
    config["quantization_config"] = copy.copy(qcfg)

    print(f"\nbits per weight: {compute_bits_per_weight(model):.3f}  "
          f"({(time.time() - t0) / 60:.0f} min)")
    save(args.mlx_path, args.model, model, tokenizer, config)


if __name__ == "__main__":
    main()
