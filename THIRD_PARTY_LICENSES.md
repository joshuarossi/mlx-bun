# Third-party licenses

mlx-bun is MIT-licensed. It builds on, links against, and ports code
from the following projects.

## Linked libraries

| Project | License | Use |
|---|---|---|
| [MLX](https://github.com/ml-explore/mlx) (Apple) | MIT | All GPU compute — Metal kernels, lazy eval engine (`libmlx`) |
| [mlx-c](https://github.com/ml-explore/mlx-c) (Apple) | MIT | C API we bind via `bun:ffi` (`libmlxc.dylib`, installed via Homebrew) |

## Ported code

These files are TypeScript ports of Python sources; the port preserves
the upstream algorithm and is a derivative work of the original.

| Source | License | Ported into |
|---|---|---|
| [mlx-lm](https://github.com/ml-explore/mlx-lm) (Apple, MIT) — `models/gemma4_text.py`, `models/cache.py`, `models/base.py`, `models/rope_utils.py`, `sample_utils.py`, `tool_parsers/gemma4.py` | MIT | `src/model/gemma4.ts`, `src/sampler.ts`, `src/tool-call.ts` |
| [mlx-vlm](https://github.com/Blaizzy/mlx-vlm) (BSD-3-Clause) — Gemma-4 unified `VisionEmbedder`, `MultimodalEmbedder`, image preprocessing (as vendored in mlx-optiq) | BSD-3-Clause | `src/vision/embedder.ts`, `src/vision/preprocess.ts` |
| mlx-optiq (MIT) — vision sidecar wiring, fused quantized SDPA orchestration | MIT | `src/vision/`, quantized-KV paths in `src/model/gemma4.ts` |
| [Pillow](https://github.com/python-pillow/Pillow) (MIT-CMU / HPND) — `ImagingResample` bicubic convolution algorithm | HPND | `resizeBicubic` in `src/vision/preprocess.ts` (algorithm port) |

## Runtime npm dependencies

| Package | License | Use |
|---|---|---|
| `@huggingface/tokenizers` | Apache-2.0 | Pure-JS tokenizer (tokenizer.json) |
| `@huggingface/jinja` | MIT | Chat-template rendering |
| `fast-png` | MIT | PNG decode (raw pixels for the vision path) |

Run `bun pm licenses` (or inspect `node_modules/*/LICENSE`) for the full
text of each npm dependency's license, including transitive ones.

## Models

Model weights (e.g. `mlx-community/gemma-4-12B-it-OptiQ-4bit`) are not
part of this repository and are governed by their own licenses and use
policies (e.g. Google's Gemma Terms of Use). Check the model card on
Hugging Face before redistribution.
