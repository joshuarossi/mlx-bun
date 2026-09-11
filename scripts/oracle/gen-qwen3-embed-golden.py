#!/usr/bin/env python3
# Generate Qwen3-Embedding parity goldens from the mlx-lm reference (the L1
# oracle). Companion to tests/parity/qwen3-embed-parity.test.ts — the mlx-bun side runs
# the SAME token ids through its Qwen3Model and compares hidden states + the
# pooled embedding.
#
# Run with the matching oracle from docs/reference/environment.md:
#   ../mlx-lm/.venv/bin/python scripts/oracle/gen-qwen3-embed-golden.py [MODEL_DIR]
#
# Writes the machine-specific goldens/qwen3-embed/ directory. The ids live in
# meta.json so the TS test uses byte-identical input (no tokenizer in the test).

import glob
import argparse
import hashlib
import importlib.metadata
import json
import os
from pathlib import Path
import subprocess

import mlx.core as mx
import numpy as np
from mlx_lm import load

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("model", nargs="?")
parser.add_argument("--replay", type=Path, help="Preserve token IDs and text from an existing meta.json")
parser.add_argument("--output-dir", type=Path, help="Explicit review directory")
args = parser.parse_args()


def resolve_model() -> str:
    if args.model:
        return args.model
    hub = os.path.expanduser("~/.cache/huggingface/hub")
    hits = glob.glob(
        os.path.join(hub, "models--mlx-community--Qwen3-Embedding-*", "snapshots", "*", "config.json")
    )
    if not hits:
        raise SystemExit("no Qwen3-Embedding snapshot in HF cache; pass MODEL_DIR")
    return os.path.dirname(hits[0])


MODEL = resolve_model()
ROOT = Path(__file__).resolve().parents[2]
# Reuse the same machine/override resolution as the tests. This child only
# reads metadata; it imports neither MLX nor model code.
golden_root = subprocess.check_output([
    "bun", "-e", "import { goldenOutDir } from './tests/support/goldens'; process.stdout.write(goldenOutDir());"
], cwd=ROOT, text=True)
OUTDIR = args.output_dir or ROOT / golden_root / "qwen3-embed"
os.makedirs(OUTDIR, exist_ok=True)

print(f"[gen-qwen3-embed-golden] model: {MODEL}")
model, tok = load(MODEL)

# A representative sentence + the <|endoftext|> pooling token Qwen3-Embedding
# terminates inputs with. Encode WITHOUT extra specials (Qwen3 has no BOS).
replay = json.loads(args.replay.read_text()) if args.replay else None
TEXT = replay["text"] if replay else "The cat sat on the warm windowsill in the afternoon sun."
EOD = replay["eod"] if replay else 151643  # <|endoftext|>
ids = replay["ids"] if replay else list(tok.encode(TEXT, add_special_tokens=False)) + [EOD]
assert ids == list(tok.encode(TEXT, add_special_tokens=False)) + [EOD], "replay tokenizer/artifact mismatch"
print(f"[gen-qwen3-embed-golden] {len(ids)} ids: {ids}")

arr = mx.array([ids])
hidden = model.model(arr)  # post-final-norm hidden [1, L, H]
mx.eval(hidden)
_, L, H = hidden.shape

pooled = hidden[:, -1, :]  # last-token pooling
norm = pooled / mx.sqrt((pooled * pooled).sum(axis=-1, keepdims=True))
mx.eval(norm)

np.array(hidden.astype(mx.float32)).reshape(-1).astype(np.float32).tofile(os.path.join(OUTDIR, "hidden.bin"))
np.array(norm.astype(mx.float32)).reshape(-1).astype(np.float32).tofile(os.path.join(OUTDIR, "pooled.bin"))
with open(os.path.join(OUTDIR, "meta.json"), "w") as f:
    json.dump({"ids": ids, "seqLen": L, "hidden": H, "text": TEXT, "eod": EOD,
               "oracle": {"model": MODEL, "mlx": mx.__version__,
                          "mlx_lm": importlib.metadata.version("mlx-lm"),
                          "device": mx.device_info(),
                          "config_sha256": hashlib.sha256(Path(MODEL, "config.json").read_bytes()).hexdigest(),
                          "replayed_meta_sha256": hashlib.sha256(args.replay.read_bytes()).hexdigest() if args.replay else None,
                          "blobs": {name: hashlib.sha256(Path(OUTDIR, name).read_bytes()).hexdigest()
                                    for name in ["hidden.bin", "pooled.bin"]}}}, f, indent=1)

print(f"[gen-qwen3-embed-golden] wrote hidden [{L},{H}] + pooled [{H}] to {OUTDIR}")
