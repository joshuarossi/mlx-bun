#!/usr/bin/env python3
"""Capture tiny quantization constants from an archived Colibri source tree.

This helper is invoked only by capture-colibri-glm52-oracle.ts. It imports the
exact archived convert_fp8_to_int4.py module, calls its quantization functions,
and writes both JSON evidence and a temporary C header consumed by the compiled
capture harness. It has no network or model dependency.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path

import numpy as np


def load_converter(source_root: Path):
    path = source_root / "c" / "tools" / "convert_fp8_to_int4.py"
    spec = importlib.util.spec_from_file_location("colibri_capture_converter", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot import pinned converter: {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def f32_rows(values):
    return np.asarray(values, dtype=np.float32)


def signed_i8(qbytes: np.ndarray) -> np.ndarray:
    return np.asarray(qbytes, dtype=np.uint8).view(np.int8)


def unpack_i4(qbytes: np.ndarray, rows: int, columns: int) -> np.ndarray:
    packed = np.asarray(qbytes, dtype=np.uint8).reshape(rows, (columns + 1) // 2)
    result = np.empty((rows, columns), dtype=np.int8)
    result[:, 0::2] = (packed[:, : (columns + 1) // 2] & 0xF).astype(np.int8) - 8
    if columns > 1:
        result[:, 1::2] = (packed[:, : columns // 2] >> 4).astype(np.int8) - 8
    return result


def c_float(value: float) -> str:
    value = float(np.float32(value))
    if value == 0.0:
        return "-0x0p+0f" if np.signbit(np.float32(value)) else "0x0p+0f"
    return value.hex() + "f"


def c_array(name: str, c_type: str, values, formatter=str) -> str:
    flat = np.asarray(values).reshape(-1)
    body = ", ".join(formatter(item) for item in flat)
    return f"static const {c_type} {name}[{flat.size}] = {{{body}}};"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-root", type=Path, required=True)
    parser.add_argument("--json-out", type=Path, required=True)
    parser.add_argument("--header-out", type=Path, required=True)
    args = parser.parse_args()

    converter = load_converter(args.source_root)

    # Row 1 makes scale exactly 1.0, exposing np.rint's half-to-even behavior.
    int8_weights = f32_rows([
        [0, 0, 0, 0, 0, 0, 0, 0],
        [0.5, 1.5, 2.5, -0.5, -1.5, -2.5, -127, 127],
        [12.7, -12.7, 6.35, -6.35, 3.175, -3.175, 0.1, -0.1],
    ])
    int8_inputs = f32_rows([
        [1, -1, 0.5, -0.5, 2, -2, 0.25, -0.25],
        [0.25, 0.5, -0.75, 1, -1.25, 1.5, -1.75, 2],
    ])
    int8_qbytes, int8_scales = converter.quant_int8(int8_weights, 8)
    int8_qvalues = signed_i8(int8_qbytes).reshape(int8_weights.shape)

    # First non-zero group also has scale 1.0 and half ties. Width 19 covers
    # both an odd packed tail and a partial final group at group_size=16.
    int4_weights = f32_rows([
        [0] * 19,
        [-7, -6.5, -5.5, -4.5, -3.5, -2.5, -1.5, -0.5,
         0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7, -1, 0.5, 1],
        [3.25, -3.25, 2.75, -2.75, 2.25, -2.25, 1.75, -1.75,
         1.25, -1.25, 0.75, -0.75, 0.25, -0.25, 0, 3, -0.5, 0.25, 0.5],
    ])
    int4_inputs = f32_rows([
        [-1, -2/3, -1/3, 0, 1/3, 2/3, 1, -1, -2/3, -1/3,
         0, 1/3, 2/3, 1, -1, -2/3, -1/3, 0, 1/3],
        [1.5, -1.25, 1, -0.75, 0.5, -0.25, 0, 0.25, -0.5, 0.75,
         -1, 1.25, -1.5, 1.125, -0.875, 0.625, -0.375, 0.125, 0.0625],
    ])
    int4_qbytes, int4_scales = converter.quant_int4_grouped(int4_weights, 4, 16)
    int4_qvalues = unpack_i4(int4_qbytes, *int4_weights.shape)

    # The row-scaled public functions cannot naturally reach the asymmetric
    # lower clamp endpoint. Capture the exact inner np.rint+np.clip operation
    # separately so clipping and tie behavior are still pinned to NumPy.
    int8_clip_input = np.asarray(
        [-200, -128.5, -127.5, -126.5, -0.5, 0.5, 126.5, 127.5, 200],
        dtype=np.float32,
    )
    int8_clip_output = np.clip(np.rint(int8_clip_input), -128, 127).astype(np.int16)
    int4_clip_input = np.asarray(
        [-20, -8.5, -7.5, -6.5, -0.5, 0.5, 6.5, 7.5, 20],
        dtype=np.float32,
    )
    int4_clip_output = np.clip(np.rint(int4_clip_input), -8, 7).astype(np.int16)

    capture = {
        "numpy_version": np.__version__,
        "int8_per_row": {
            "bits": 8,
            "weights_f32": int8_weights.tolist(),
            "input_f32": int8_inputs.tolist(),
            "scales_f32": int8_scales.tolist(),
            "qbytes_u8": np.asarray(int8_qbytes, dtype=np.uint8).tolist(),
            "qvalues_i8": int8_qvalues.tolist(),
        },
        "int4_grouped": {
            "bits": 4,
            "group_size": 16,
            "weights_f32": int4_weights.tolist(),
            "input_f32": int4_inputs.tolist(),
            "scales_f32": int4_scales.tolist(),
            "qbytes_u8": np.asarray(int4_qbytes, dtype=np.uint8).tolist(),
            "qvalues_i4": int4_qvalues.tolist(),
        },
        "round_clip_edges": {
            "int8_input_f32": int8_clip_input.tolist(),
            "int8_expected_i16": int8_clip_output.tolist(),
            "int4_input_f32": int4_clip_input.tolist(),
            "int4_expected_i16": int4_clip_output.tolist(),
        },
    }
    args.json_out.write_text(json.dumps(capture, indent=2) + "\n")

    header = "\n".join([
        "/* Generated in a temporary exact-pin capture tree; never checked in. */",
        "#include <stdint.h>",
        "enum { CAP_I8_O=3, CAP_I8_I=8, CAP_I8_S=2 };",
        "enum { CAP_I4_O=3, CAP_I4_I=19, CAP_I4_S=2, CAP_I4_GS=16 };",
        c_array("cap_i8_q", "uint8_t", int8_qbytes, lambda value: str(int(value))),
        c_array("cap_i8_s", "float", int8_scales, c_float),
        c_array("cap_i8_x", "float", int8_inputs, c_float),
        c_array("cap_i4_q", "uint8_t", int4_qbytes, lambda value: str(int(value))),
        c_array("cap_i4_s", "float", int4_scales, c_float),
        c_array("cap_i4_x", "float", int4_inputs, c_float),
        "",
    ])
    args.header_out.write_text(header)


if __name__ == "__main__":
    main()
