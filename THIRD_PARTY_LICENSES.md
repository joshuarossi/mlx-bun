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
| [Colibri](https://github.com/JustVugg/colibri) (pinned development oracle `44e489b196c9b7876b3d37a0570ebf1c6f90f54c`) — direct-container layout, expert-residency/I/O policy, GLM-5.2 execution and Metal-kernel reference | Apache-2.0 | Native GLM-5.2 implementation under `src/model/glm52-*`, `src/expert-*`, and `src/native/expert_io.c`; rewritten for Bun + MLX, with direct Colibri retained only as an external oracle |

## Runtime npm dependencies

| Package | License | Use |
|---|---|---|
| `@huggingface/tokenizers` | Apache-2.0 | Pure-JS tokenizer (tokenizer.json) |
| `@huggingface/jinja` | MIT | Chat-template rendering |
| `fast-png` | MIT | PNG decode (raw pixels for the vision path) |
| `@mlc-ai/web-xgrammar` | Apache-2.0 | Grammar-constrained decoding (WASM build of [xgrammar](https://github.com/mlc-ai/xgrammar) by the MLC-ai team). `response_format` / `guided_grammar` / `guided_regex` / `guided_choice` compile to a GrammarMatcher whose per-step token bitmask masks invalid logits (`src/grammar.ts`). Idea ported from oMLX (`api/grammar.py`), same engine, WASM-packaged. |

Run `bun pm licenses` (or inspect `node_modules/*/LICENSE`) for the full
text of each npm dependency's license, including transitive ones.

## Models

Model weights (e.g. `mlx-community/gemma-4-12B-it-OptiQ-4bit`) are not
part of this repository and are governed by their own licenses and use
policies (e.g. Google's Gemma Terms of Use). Check the model card on
Hugging Face before redistribution.

The validated GLM-5.2 direct-container artifact,
[`mateogrgic/GLM-5.2-colibri-int4-with-int8-mtp`](https://huggingface.co/mateogrgic/GLM-5.2-colibri-int4-with-int8-mtp),
declares MIT and identifies itself as a Colibri conversion/derivative of
[`zai-org/GLM-5.2-FP8`](https://huggingface.co/zai-org/GLM-5.2-FP8), with
lineage through `jlnsrk/GLM-5.2-colibri-int4` and added int8 MTP weights. The
artifact is downloaded separately into the Hugging Face cache and is not part
of the mlx-bun distribution.
