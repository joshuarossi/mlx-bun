# Qwen3.8 vision oracle capture (PLAN 14v) — dumps the COMPLETE golden chain
# from mlx-vlm for each fixture image so every TS port stage gates directly:
#   processor:  pixel_values (f32) + grid_thw
#   tower:      merged hidden_states (f32)
#   language:   expanded input_ids, position_ids (3,L), rope_delta
#   e2e:        greedy token ids
#
#   /tmp/mlxvlm-venv/bin/python scripts/oracle/oracle-qwen38-vision.py \
#       <target_snapshot> <out_dir> <image...> [--max-tokens N]

import json
import sys
from pathlib import Path

import mlx.core as mx
import numpy as np
from mlx_vlm import load
from mlx_vlm.prompt_utils import apply_chat_template

args = [a for a in sys.argv[1:] if not a.startswith("--")]
tgt, out_dir = args[0], Path(args[1])
images = args[2:]
max_tokens = 32
for a in sys.argv[1:]:
    if a.startswith("--max-tokens="):
        max_tokens = int(a.split("=")[1])
out_dir.mkdir(parents=True, exist_ok=True)

model, processor = load(tgt)
cfg = model.config
PROMPT = "Describe this image in one short sentence."

manifest = {"mlx_version": mx.__version__, "prompt": PROMPT, "images": {}}

for img_path in images:
    name = Path(img_path).stem
    prompt_str = apply_chat_template(processor, cfg, PROMPT, num_images=1)
    inputs = processor(
        text=[prompt_str], images=[img_path], padding=True, return_tensors="np"
    )
    input_ids = np.asarray(inputs["input_ids"])[0].tolist()
    pixel_values = np.asarray(inputs["pixel_values"], dtype=np.float32)
    grid_thw = np.asarray(inputs["image_grid_thw"]).tolist()

    # Tower output on exactly these pixel_values.
    pv = mx.array(pixel_values).astype(model.vision_tower.patch_embed.proj.weight.dtype)
    hidden, _ = model.vision_tower(pv, mx.array(grid_thw))
    mx.eval(hidden)
    hidden_f32 = np.asarray(hidden.astype(mx.float32))

    # Language positions.
    pos_ids, deltas = model.language_model.get_rope_index(
        mx.array(input_ids)[None], mx.array(grid_thw), None, None
    )
    mx.eval(pos_ids, deltas)

    # E2E greedy TOKEN IDS through the reference generate path.
    from mlx_vlm.generate import stream_generate
    gen_ids = []
    gen_text = ""
    for r in stream_generate(
        model, processor, prompt_str, image=[img_path],
        max_tokens=max_tokens, temperature=0.0,
    ):
        if getattr(r, "token", None) is not None:
            gen_ids.append(int(r.token))
        gen_text += r.text or ""

    np.savez(
        out_dir / f"{name}.npz",
        pixel_values=pixel_values,
        hidden=hidden_f32,
    )
    manifest["images"][name] = {
        "input_ids": input_ids,
        "grid_thw": grid_thw,
        "position_ids": np.asarray(pos_ids).astype(np.int64)[:, 0, :].tolist(),
        "rope_delta": int(np.asarray(deltas).reshape(-1)[0]),
        "gen_ids": gen_ids,
        "gen_text": gen_text,
        "pixel_shape": list(pixel_values.shape),
        "hidden_shape": list(hidden_f32.shape),
    }
    print(name, "grid", grid_thw, "pixels", pixel_values.shape,
          "hidden", hidden_f32.shape, "delta", manifest["images"][name]["rope_delta"])
    print("  ids:", gen_ids[:12], "text:", gen_text[:80])

(out_dir / "manifest.json").write_text(json.dumps(manifest))
print("wrote", out_dir)
