# Qwen3.8 VIDEO oracle capture (PLAN 14w) — golden chain from mlx-vlm
# (pinned mlx): the video processor (T-aware smart_resize, frame padding,
# temporal-pair patchify), tower forward on the video grid, mRoPE positions,
# and a manual greedy trajectory. Frames come from PNGs extracted by the
# AVFoundation sidecar (lab/spikes/qwen38-video-sidecar) from the committed
# fixture clip — BOTH stacks consume identical decoded frames, so no video
# codec enters the comparison.
#
#   /tmp/mlxvlm31/bin/python scripts/experiments/oracle-qwen38-video.py \
#       <target_snapshot> <out_dir> <framesDir> [max_tokens=24]

import json
import sys
from pathlib import Path

import mlx.core as mx
import numpy as np
from PIL import Image
from mlx_vlm import load
from mlx_vlm.models.qwen3_vl.processing_qwen3_vl import Qwen3VLVideoProcessor

tgt, out_dir, frames_dir = sys.argv[1], Path(sys.argv[2]), Path(sys.argv[3])
MAXTOK = int(sys.argv[4]) if len(sys.argv) > 4 else 24
out_dir.mkdir(parents=True, exist_ok=True)

frame_files = sorted(frames_dir.glob("frame-*.png"))
if not frame_files:
    raise SystemExit(f"no frames in {frames_dir}")
frames = np.stack([
    np.transpose(np.asarray(Image.open(f).convert("RGB")), (2, 0, 1))
    for f in frame_files
])  # (T, C, H, W) uint8
T, _, H, W = frames.shape
print("frames", frames.shape)

proc = Qwen3VLVideoProcessor()
pixel_values, grid = proc._process_one(frames)
pixel_values = np.ascontiguousarray(pixel_values, dtype=np.float32)
grid_t, grid_h, grid_w = (int(v) for v in grid)
print("grid", grid, "pixels", pixel_values.shape)

model, processor = load(tgt)
pv = mx.array(pixel_values).astype(model.vision_tower.patch_embed.proj.weight.dtype)
hidden, _ = model.vision_tower(pv, mx.array([[grid_t, grid_h, grid_w]]))
mx.eval(hidden)
hidden_f32 = np.asarray(hidden.astype(mx.float32))
print("hidden", hidden_f32.shape)

# Prompt: template with one video part, video_pad expanded by merge_length.
tok = processor.tokenizer if hasattr(processor, "tokenizer") else processor
prompt_str = tok.apply_chat_template(
    [{"role": "user", "content": [
        {"type": "video"},
        {"type": "text", "text": "Describe this video in one short sentence."},
    ]}],
    add_generation_prompt=True, tokenize=False,
)
raw_ids = tok.encode(prompt_str)
VIDEO_TOKEN = 248057
n_video_tokens = grid_t * (grid_h // 2) * (grid_w // 2)
ids = []
for t in raw_ids:
    if t == VIDEO_TOKEN:
        ids.extend([VIDEO_TOKEN] * n_video_tokens)
    else:
        ids.append(t)

pos_ids, deltas = model.language_model.get_rope_index(
    mx.array(ids)[None], None, mx.array([[grid_t, grid_h, grid_w]]), None
)
mx.eval(pos_ids, deltas)
delta = int(np.asarray(deltas).reshape(-1)[0])

# Manual greedy: spliced embeds prefill + L=1 decode with delta positions.
emb = model.language_model.model.embed_tokens(mx.array(ids)[None])
idx = np.nonzero(np.asarray(mx.array(ids) == VIDEO_TOKEN))[0]
start, count = int(idx[0]), len(idx)
emb = mx.concatenate(
    [emb[:, :start], hidden[None].astype(emb.dtype), emb[:, start + count:]], axis=1
)
cache = model.language_model.make_cache()
out = model.language_model(
    mx.array(ids)[None], inputs_embeds=emb, position_ids=pos_ids, cache=cache
)
logits = out.logits if hasattr(out, "logits") else out
mx.eval(logits)
step0 = np.asarray(logits[0, -1].astype(mx.float32))
step0.tofile(out_dir / "clip-step0-logits.f32.bin")
gen = [int(step0.argmax())]
L = len(ids)
eos = {248046, 248044}
while len(gen) < MAXTOK and gen[-1] not in eos:
    pos = L + len(gen) - 1
    pid = mx.full((3, 1, 1), pos + delta, dtype=mx.int32)
    o = model.language_model(
        mx.array([[gen[-1]]]), position_ids=pid, cache=cache
    )
    lg = o.logits if hasattr(o, "logits") else o
    mx.eval(lg)
    gen.append(int(np.asarray(lg[0, -1].astype(mx.float32)).argmax()))

pixel_values.tofile(out_dir / "clip-pixels.f32.bin")
hidden_f32.tofile(out_dir / "clip-hidden.f32.bin")
manifest = {
    "mlx_version": mx.__version__,
    "frames": T, "frame_h": H, "frame_w": W,
    "grid_thw": [grid_t, grid_h, grid_w],
    "input_ids": ids,
    "position_ids": np.asarray(pos_ids).astype(np.int64)[:, 0, :].tolist(),
    "rope_delta": delta,
    "gen_ids": gen,
    "gen_text": tok.decode(gen),
    "pixel_shape": list(pixel_values.shape),
    "hidden_shape": list(hidden_f32.shape),
}
(out_dir / "clip-manifest.json").write_text(json.dumps(manifest))
print("gen:", gen)
print("text:", manifest["gen_text"][:100])
