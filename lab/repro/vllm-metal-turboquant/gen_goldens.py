"""Generate TurboQuant parity goldens from the vendored vllm-metal reference.

Never imported by the mlx-bun product. Driven only by
scripts/regen-turboquant-goldens.ts, which shells out to this file under the
oracle venv (mlx 0.31.2). Emits one JSON document on stdout:

  {
    "signs":      { "64": [...], "128": [...], "256": [...], "512": [...] },
    "lloyd_max":  { "2": {centroids, boundaries}, "3": {...}, "4": {...},
                    "5": {...}, "8": {...} },
    "vectors":    [ { head_dim, config, k_quant_type, k_bits, v_bits,
                      input_k, input_v, k_indices, k_scale, k_zero,
                      k_packed, v_indices, v_packed, v_scale, k_dequant,
                      v_dequant }, ... ]
  }

Shim required (documented in PROVENANCE.md): the vendored file imports
``from vllm.logger import init_logger``. We install fake ``vllm`` /
``vllm.logger`` modules in sys.modules before importing it, exposing a
plain ``init_logger(name) -> logging.Logger``. No other symbol in the
vendored file needs shimming — everything else is stock ``mlx.core``.

Determinism: sign vectors and the 3-bit table are closed-form (fixed
mx.random.key(42), no iteration). Lloyd-Max for bits != 3 iterates
mx.random.normal(key=mx.random.key(0)) — same fixed key as the vendored
file's own default, so it is deterministic across runs/machines by
construction (not just by re-seeding here); we do not override the
reference's key(0), we simply rely on it being hardcoded in the vendored
source (`_compute_lloyd_max_normal`'s `mx.random.key(0)` literal).

JSON encoding note: one adversarial golden (a constant-value input row)
triggers the reference's genuine fp16 zero_point overflow (scale==0 exactly
-> (x_max+x_min)/(2*(0+1e-8)) overflows fp16 to +-inf, and dequant of that
is NaN) — this is real, intentional reference behavior we must capture, not
paper over (see docs/design/turboquant-kv.md's "deliberately drops the
+1e-8 scale epsilon" note). Standard JSON has no Infinity/NaN literal, so
float leaves are encoded via _json_safe_float: finite values as JSON
numbers, non-finite as the sentinel strings "Infinity"/"-Infinity"/"NaN".
Consumers (the regen TS script, tests) must special-case those three
strings back to +-Inf/NaN rather than parsing them as plain numbers.
"""

import json
import logging
import sys
import types

# --- shim: vllm.logger (see PROVENANCE.md "Shims required") ---
_vllm_mod = types.ModuleType("vllm")
_vllm_logger_mod = types.ModuleType("vllm.logger")


def _init_logger(name: str) -> logging.Logger:
    return logging.getLogger(name)


_vllm_logger_mod.init_logger = _init_logger
_vllm_mod.logger = _vllm_logger_mod
sys.modules["vllm"] = _vllm_mod
sys.modules["vllm.logger"] = _vllm_logger_mod

sys.path.insert(0, __file__.rsplit("/", 1)[0])
import turboquant_reference as tq  # noqa: E402
import mlx.core as mx  # noqa: E402


def _json_safe_float(v) -> float | str:
    """Standard JSON has no Infinity/NaN literals. Some adversarial goldens
    (e.g. a constant-value block, whose key scale is exactly 0) hit the
    reference's genuine fp16 zero_point overflow — see turboquant-kv.md's
    "deliberately drops the +1e-8 scale epsilon because it underflows in
    fp16" note — so we must round-trip these exactly, not paper over them.
    Encode as the sentinel strings "Infinity"/"-Infinity"/"NaN" (the
    inverse of Python's own float(str) parsing for these tokens); the TS
    reader must special-case them back to +Inf/-Inf/NaN rather than parsing
    as a number."""
    f = float(v)
    if f != f:  # NaN
        return "NaN"
    if f == float("inf"):
        return "Infinity"
    if f == float("-inf"):
        return "-Infinity"
    return f


def _cast_nested(v, cast):
    """Recursively cast a (possibly nested) Python list/scalar from
    mx.array.tolist() to `cast` (float or int), preserving full precision —
    `.tolist()` already yields real Python floats/ints (repr-exact), we only
    need to normalize numpy/mlx scalar wrapper types at the leaves."""
    if isinstance(v, list):
        return [_cast_nested(x, cast) for x in v]
    return cast(v)


def arr_to_list(a: mx.array) -> list:
    """Full round-trip float32 precision (JSON stores it as float64-exact
    Python floats — no precision lost beyond the array's own float32).
    NaN/Infinity are encoded as sentinel strings (see _json_safe_float)."""
    return _cast_nested(a.astype(mx.float32).tolist(), _json_safe_float)


def int_arr_to_list(a: mx.array) -> list:
    return _cast_nested(a.tolist(), int)


HEAD_DIMS = (64, 128, 256, 512)
VALUE_BITS = (2, 3, 4, 5, 8)

# --- 1. sign vectors per head_dim (the fwht() sign table from key(42)) ---
signs_out = {}
for d in HEAD_DIMS:
    sign01 = mx.random.randint(0, 2, shape=(d,), key=mx.random.key(42))
    signs = 1 - 2 * sign01
    signs_out[str(d)] = int_arr_to_list(signs)

# --- 2. Lloyd-Max centroids + boundaries per value bit-width ---
lloyd_max_out = {}
for bits in VALUE_BITS:
    centroids, boundaries = tq.lloyd_max_centroids(bits)
    lloyd_max_out[str(bits)] = {
        "centroids": arr_to_list(centroids),
        "boundaries": arr_to_list(boundaries),
    }
    if bits == 3:
        # hard equality check against the hardcoded fast-path table
        assert mx.array_equal(centroids, tq.CENTROIDS_3BIT).item()
        assert mx.array_equal(boundaries, tq.BOUNDARIES_3BIT).item()

# --- 3. golden vectors: head_dim in {64,128} ---
# Configs cover every kBits/vBits value the CLI accepts (config.ts
# TURBOQUANT_VALID_KBITS {2,4,5,8} / VBITS {2,3,4,5,8}): k2v5 + k5v8 close
# the k∈{2,5}, v∈{5,8} gap the integration review flagged (Gate 1 must span
# the whole CLI-reachable matrix, not just the curve-script configs).
CONFIGS = [
    {"k_quant": "q8_0", "k_bits": 8, "v_bits": 3, "tag": "k8v3"},
    {"k_quant": "q4_0", "k_bits": 4, "v_bits": 3, "tag": "k4v3"},
    {"k_quant": "q4_0", "k_bits": 4, "v_bits": 2, "tag": "k4v2"},
    {"k_quant": "q8_0", "k_bits": 8, "v_bits": 4, "tag": "k8v4"},
    {"k_quant": "int2", "k_bits": 2, "v_bits": 5, "tag": "k2v5"},
    {"k_quant": "q5_0", "k_bits": 5, "v_bits": 8, "tag": "k5v8"},
]

NUM_HEADS = 2
NUM_TOKENS = 5


def make_block(head_dim: int, variant: str) -> mx.array:
    """[1, NUM_HEADS, NUM_TOKENS, head_dim] fixed deterministic block, with
    the last three rows overridden to be adversarial (all-zero, constant,
    one huge-outlier row), shared across both K and V generation (variant
    distinguishes the two RNG streams so K != V)."""
    key = mx.random.key(1234 if variant == "k" else 5678)
    x = mx.random.normal(shape=(1, NUM_HEADS, NUM_TOKENS, head_dim), key=key)
    x = x.astype(mx.float32)
    # adversarial rows, applied per-head identically: token 2 = all zero,
    # token 3 = constant, token 4 = one huge outlier plus small noise.
    zero_row = mx.zeros((1, NUM_HEADS, 1, head_dim))
    const_row = mx.full((1, NUM_HEADS, 1, head_dim), 0.5)
    outlier_row = mx.random.normal(shape=(1, NUM_HEADS, 1, head_dim), key=mx.random.key(9999 if variant == "k" else 8888)) * 0.01
    outlier_row = outlier_row.astype(mx.float32)
    # set element 0 of the outlier row to a huge value
    idx = mx.zeros((1, NUM_HEADS, 1, head_dim))
    onehot = mx.arange(head_dim) == 0
    outlier_row = mx.where(onehot, mx.full(outlier_row.shape, 1000.0), outlier_row)
    rows = [x[:, :, 0:2, :], zero_row, const_row, outlier_row]
    out = mx.concatenate(rows, axis=2)
    mx.eval(out)
    return out


vectors_out = []
for head_dim in (64, 128):
    k_block = make_block(head_dim, "k")
    v_block = make_block(head_dim, "v")
    for cfg in CONFIGS:
        k_quant_type = cfg["k_quant"]
        v_bits = cfg["v_bits"]

        k_indices, k_scale, k_zero = tq.turbo_quant_encode_key(k_block, k_quant_type)
        v_indices, v_scale = tq.turbo_quant_encode_value(v_block, bits=v_bits)

        k_bits = tq.QUANT_PARAMS[k_quant_type]["bits"]
        v_packed = tq.pack_bits(v_indices, v_bits) if v_bits < 8 else v_indices
        k_packed = tq.pack_bits(k_indices.astype(mx.uint8), k_bits) if k_bits < 8 else k_indices

        k_dequant = tq.turbo_quant_decode_key(k_indices, k_scale, k_zero, mx.float32)
        v_dequant = tq.turbo_quant_decode_value(v_indices, v_scale, mx.float32, bits=v_bits)
        mx.eval(k_dequant, v_dequant, k_packed, v_packed)

        vectors_out.append(
            {
                "head_dim": head_dim,
                "config": cfg["tag"],
                "k_quant_type": k_quant_type,
                "k_bits": k_bits,
                "v_bits": v_bits,
                "input_k": arr_to_list(k_block),
                "input_v": arr_to_list(v_block),
                "k_indices": int_arr_to_list(k_indices),
                "k_scale": arr_to_list(k_scale),
                "k_zero": arr_to_list(k_zero),
                "k_packed": int_arr_to_list(k_packed),
                "v_indices": int_arr_to_list(v_indices),
                "v_packed": int_arr_to_list(v_packed),
                "v_scale": arr_to_list(v_scale),
                "k_dequant": arr_to_list(k_dequant),
                "v_dequant": arr_to_list(v_dequant),
            }
        )

result = {
    "signs": signs_out,
    "lloyd_max": lloyd_max_out,
    "vectors": vectors_out,
}

print(json.dumps(result))
