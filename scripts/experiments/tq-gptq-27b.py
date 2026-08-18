# Chunked, true-sequential, RESUMABLE GPTQ for the 27B qwen3_5 VL trunk on a
# 32 GB box.
#
# v2 (2026-08-18, after the v1 lesson): v1 held every quantized layer in the
# model object and wrote ONE save() at the end — no resume, and a ~25 GB
# footprint gamble. v2 checkpoints EACH layer as it finishes
# (<ckpt>/layer-NNN.safetensors + the propagated activations + state.json),
# then STRIPS the layer from the model, so peak memory is one bf16 layer +
# one Hessian + the activation set (~6 GB), a crash resumes at the last
# finished layer, and the final artifact is ASSEMBLED from checkpoints +
# the source snapshot (never a whole-model save).
#
# Flow per layer: catch input Hessians (bf16 forward; outputs never
# evaluated) → corrected GPTQ (tq-gptq.py: gptq_one) + swap to quantized →
# propagate activations through the QUANTIZED layer (true-sequential) →
# checkpoint → strip. Embeddings quantize RTN at assembly; lm_head gets
# GPTQ on final-norm activations; the vision tower stays bf16.
#
#   .venv/bin/python -u scripts/experiments/tq-gptq-27b.py --model <bf16-trunk> \
#       --mlx-path <out> [--bits 4] [--group-size 64] [--num-samples 64] \
#       [--sequence-length 512]   # re-run the same command to RESUME

import argparse
import json
import os
import sys
import time
from pathlib import Path

import mlx.core as mx
import mlx.nn as nn

sys.path.insert(0, "scripts/experiments")
from importlib import import_module

tq_gptq = import_module("tq-gptq")
gptq_one_guarded = tq_gptq.gptq_one_guarded

from mlx_lm.models.base import create_attention_mask
from mlx_lm.models.qwen3_5 import create_ssm_mask
from mlx_lm.quant.gptq import Catcher
from mlx_lm.quant.utils import load_data
from mlx_lm.utils import load

FULL_ATTN_LINEARS = ["q_proj", "k_proj", "v_proj", "o_proj"]
DELTANET_LINEARS = ["in_proj_qkv", "in_proj_z", "in_proj_b", "in_proj_a", "out_proj"]
MLP_LINEARS = ["gate_proj", "up_proj", "down_proj"]
P = "language_model.model"


class Stub(nn.Module):
    """Replaces a finished layer so its arrays free; must never be called."""

    def __call__(self, *a, **k):
        raise RuntimeError("stripped layer called — resume bookkeeping bug")


def layer_sites(layer):
    if bool(layer.is_linear):
        return [(layer.linear_attn, f"linear_attn.{n}", n) for n in DELTANET_LINEARS] + [
            (layer.mlp, f"mlp.{n}", n) for n in MLP_LINEARS
        ]
    return [(layer.self_attn, f"self_attn.{n}", n) for n in FULL_ATTN_LINEARS] + [
        (layer.mlp, f"mlp.{n}", n) for n in MLP_LINEARS
    ]


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--model", "-m", required=True)
    p.add_argument("--mlx-path", required=True)
    p.add_argument("--bits", type=int, default=4)
    p.add_argument("--group-size", type=int, default=64)
    p.add_argument("--num-samples", type=int, default=128)
    p.add_argument("--sensitivity", default=None,
                   help="optiq sensitivity.json — drives per-module 8-bit upgrades")
    p.add_argument("--target-bpw", type=float, default=4.8)
    p.add_argument("--high-bits", type=int, default=8)
    p.add_argument("--sequence-length", type=int, default=512)
    p.add_argument("--batch-size", type=int, default=8)
    p.add_argument("--seed", type=int, default=123)
    args = p.parse_args()

    ckpt = Path(args.mlx_path + ".ckpt")
    ckpt.mkdir(parents=True, exist_ok=True)
    params = {
        "bits": args.bits, "group_size": args.group_size,
        "num_samples": args.num_samples, "sequence_length": args.sequence_length,
        "seed": args.seed, "model": args.model,
        "sensitivity": args.sensitivity, "target_bpw": args.target_bpw,
        "high_bits": args.high_bits,
    }
    state_path = ckpt / "state.json"
    state = json.loads(state_path.read_text()) if state_path.exists() else None
    if state and state.get("params") != params:
        raise SystemExit(f"checkpoint {ckpt} was made with different params — delete it or match them")
    next_layer = state["next_layer"] if state else 0

    # Sensitivity-driven aggressiveness (Josh 2026-08-18): upgrade the most
    # KL-sensitive modules to high_bits, greedily by benefit-per-parameter,
    # until the projected bpw hits --target-bpw. Source: OptiQ's published
    # optiq/sensitivity.json for this exact trunk.
    high_modules = {}
    if args.sensitivity:
        sens = json.loads(Path(args.sensitivity).read_text())
        rows = []
        total_params = sum(l["param_count"] for l in sens["layers"])
        for l in sens["layers"]:
            benefit = l["sensitivities"][str(args.bits)] - l["sensitivities"][str(args.high_bits)]
            rows.append((benefit / max(l["param_count"], 1), benefit, l["layer_name"], l["param_count"]))
        rows.sort(reverse=True)
        base_bits_total = total_params * (args.bits + 32 / args.group_size)
        budget_bits = args.target_bpw * total_params - base_bits_total
        used = 0.0
        for _, benefit, name, pcount in rows:
            extra = pcount * (args.high_bits - args.bits)
            if benefit <= 0 or used + extra > budget_bits:
                continue
            used += extra
            high_modules[name] = args.high_bits
        proj = (base_bits_total + used) / total_params
        print(f"sensitivity allocation: {len(high_modules)} modules @ {args.high_bits}-bit, "
              f"projected {proj:.2f} bpw", flush=True)
    ckpt.mkdir(parents=True, exist_ok=True)
    (ckpt / "bits.json").write_text(json.dumps(high_modules))

    def bits_for(base):
        return high_modules.get(base, args.bits)

    mx.random.seed(args.seed)
    model, tokenizer, config = load(args.model, lazy=True, return_config=True)
    lm = model.language_model
    inner = lm.model
    n_layers = len(inner.layers)
    bits, gs = args.bits, args.group_size

    # Calibration activations: fresh from the (deterministic) data on a cold
    # start; from the checkpoint on resume.
    if next_layer == 0:
        data = load_data(tokenizer, args.num_samples, args.sequence_length)
        batches = [data[s : s + args.batch_size] for s in range(0, len(data), args.batch_size)]
        hs = []
        for b in batches:
            h = inner.embed_tokens(b)
            mx.eval(h)
            hs.append(h)
    else:
        saved = mx.load(str(ckpt / "hs.safetensors"))
        hs = [saved[f"h{i}"] for i in range(len(saved))]
        mx.eval(hs)
        print(f"resuming at layer {next_layer}/{n_layers}", flush=True)
    mx.clear_cache()

    def quantize_linear(linear, H, mbits, label=""):
        orig_type = linear.weight.dtype
        scales, biases, Wq, note = gptq_one_guarded(linear.weight, H, mbits, gs)
        if note:
            print(f"  {label}: {note}", flush=True)
        q = linear.to_quantized(bits=mbits, group_size=gs)
        q.weight = Wq
        q.scales = scales
        q.biases = biases
        q.set_dtype(orig_type)
        mx.eval(q)
        return q

    t0 = time.time()
    for li in range(n_layers):
        layer = inner.layers[li]
        if li < next_layer:
            inner.layers[li] = Stub()  # already checkpointed — never touch its weights
            continue
        sites = layer_sites(layer)
        for parent, _, name in sites:
            setattr(parent, name, Catcher(getattr(parent, name)))
        is_lin = bool(layer.is_linear)
        for h in hs:
            mask = create_ssm_mask(h, None) if is_lin else create_attention_mask(h, None)
            layer(h, mask=mask, cache=None)
            for parent, _, name in sites:
                mx.eval(getattr(parent, name).H)
        out_tensors = {}
        for parent, rel, name in sites:
            catcher = getattr(parent, name)
            H = catcher.H
            catcher.H = None
            base = f"{P}.layers.{li}.{rel}"
            q = quantize_linear(catcher.module, H, bits_for(base), base)
            del H
            setattr(parent, name, q)
            out_tensors[f"{base}.weight"] = q.weight
            out_tensors[f"{base}.scales"] = q.scales
            out_tensors[f"{base}.biases"] = q.biases
            mx.clear_cache()
        new_hs = []
        for h in hs:
            mask = create_ssm_mask(h, None) if is_lin else create_attention_mask(h, None)
            out = layer(h, mask=mask, cache=None)
            mx.eval(out)
            new_hs.append(out)
        hs = new_hs
        # Checkpoint: layer tensors + activations + state, THEN strip.
        mx.save_safetensors(str(ckpt / f"layer-{li:03d}"), out_tensors)
        mx.save_safetensors(str(ckpt / "hs"), {f"h{i}": h for i, h in enumerate(hs)})
        state_path.write_text(json.dumps({"params": params, "next_layer": li + 1}))
        inner.layers[li] = Stub()
        mx.clear_cache()
        el = time.time() - t0
        print(f"layer {li + 1}/{n_layers} done  ({el / 60:.1f} min elapsed)", flush=True)

    # lm_head (untied on the 27B): GPTQ on final-norm activations.
    if not (ckpt / "lm_head.safetensors").exists():
        if isinstance(getattr(lm, "lm_head", None), nn.Linear):
            lm.lm_head = Catcher(lm.lm_head)
            for h in hs:
                hn = inner.norm(h)
                lm.lm_head(hn)
                mx.eval(lm.lm_head.H)
            H = lm.lm_head.H
            lm.lm_head.H = None
            q = quantize_linear(lm.lm_head.module, H, bits_for("language_model.lm_head"), "lm_head")
            mx.save_safetensors(str(ckpt / "lm_head"), {
                "language_model.lm_head.weight": q.weight,
                "language_model.lm_head.scales": q.scales,
                "language_model.lm_head.biases": q.biases,
            })
            del q
            mx.clear_cache()
        print("lm_head done", flush=True)

    assemble(args, ckpt, config)


def assemble(args, ckpt, config):
    """Build the artifact from checkpoints + the source snapshot, streaming
    shard-by-shard — the model object is never materialized whole."""
    import glob
    import shutil

    src = args.model
    out = Path(args.mlx_path)
    out.mkdir(parents=True, exist_ok=True)
    bits, gs = args.bits, args.group_size
    high_modules = json.loads((ckpt / "bits.json").read_text()) if (ckpt / "bits.json").exists() else {}

    replaced = {}
    for f in sorted(glob.glob(str(ckpt / "layer-*.safetensors"))) + [str(ckpt / "lm_head.safetensors")]:
        if os.path.exists(f):
            replaced.update(mx.load(f))  # lazy

    shard_files = sorted(glob.glob(os.path.join(src, "model*.safetensors")))
    shard_files = [f for f in shard_files if not f.endswith("index.json")]
    embed_name = f"{P}.embed_tokens.weight"
    covered_bases = {k[: -len(".weight")] for k in replaced if k.endswith(".weight")}

    cur, cur_bytes = {}, 0
    done_shards = []  # (tmp_path, names, bytes)
    CAP = 4 << 30

    def flush():
        nonlocal cur, cur_bytes
        if cur:
            tmp = out / f"model-tmp-{len(done_shards):05d}"
            mx.save_safetensors(str(tmp), cur, {"format": "mlx"})
            done_shards.append((str(tmp) + ".safetensors", list(cur.keys()), cur_bytes))
            cur, cur_bytes = {}, 0
            mx.clear_cache()

    def add(name, arr):
        nonlocal cur_bytes
        mx.eval(arr)
        nb = arr.nbytes
        if cur and cur_bytes + nb > CAP:
            flush()
        cur[name] = arr
        cur_bytes += nb

    qcfg = {"group_size": gs, "bits": bits}
    for mod, mbits in high_modules.items():
        qcfg[mod] = {"bits": mbits, "group_size": gs}
    for f in shard_files:
        tensors = mx.load(f)  # lazy per shard
        for name in tensors:
            base = name[: name.rfind(".")]
            if base in covered_bases:
                if name.endswith(".weight"):
                    add(f"{base}.weight", replaced[f"{base}.weight"])
                    add(f"{base}.scales", replaced[f"{base}.scales"])
                    add(f"{base}.biases", replaced[f"{base}.biases"])
                continue
            if name == embed_name:
                ebits = high_modules.get(f"{P}.embed_tokens", bits)
                w, s, b = mx.quantize(tensors[name], group_size=gs, bits=ebits)
                add(f"{P}.embed_tokens.weight", w)
                add(f"{P}.embed_tokens.scales", s)
                add(f"{P}.embed_tokens.biases", b)
                if ebits != bits:
                    qcfg[f"{P}.embed_tokens"] = {"bits": ebits, "group_size": gs}
                continue
            if name.startswith("vision_tower.") and name.endswith(".weight"):
                t = tensors[name]
                if t.ndim == 2 and t.shape[-1] % gs == 0:
                    qcfg[name[: -len(".weight")]] = False
            add(name, tensors[name])
        del tensors
        mx.clear_cache()
        print(f"assembled through {os.path.basename(f)}", flush=True)
    flush()

    n = len(done_shards)
    weight_map = {}
    total = 0
    for i, (tmp, names, nbytes) in enumerate(done_shards):
        fname = "model.safetensors" if n == 1 else f"model-{i + 1:05d}-of-{n:05d}.safetensors"
        os.rename(tmp, out / fname)
        for k in names:
            weight_map[k] = fname
        total += nbytes
    if n > 1:
        (out / "model.safetensors.index.json").write_text(json.dumps({
            "metadata": {"total_size": total},
            "weight_map": {k: weight_map[k] for k in sorted(weight_map)},
        }, indent=2))

    cfg = dict(config)
    cfg["quantization"] = qcfg
    cfg["quantization_config"] = dict(qcfg)
    (out / "config.json").write_text(json.dumps(cfg, indent=2))
    for aux in ["tokenizer.json", "tokenizer_config.json", "special_tokens_map.json",
                "generation_config.json", "chat_template.jinja", "vocab.json", "merges.txt",
                "preprocessor_config.json", "video_preprocessor_config.json"]:
        s = os.path.join(src, aux)
        if os.path.exists(s):
            shutil.copy(s, out / aux)
    print(f"assembled artifact: {total / 1e9:.2f} GB → {out}", flush=True)


if __name__ == "__main__":
    main()
