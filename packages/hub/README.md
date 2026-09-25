# @mlx-bun/hub

Model discovery and artifact transfer for [`@mlx-bun/inference`](../inference/README.md).
The inference library opens local artifact directories; this package finds
and fetches them.

| Module | Owns |
| --- | --- |
| `registry` | A `bun:sqlite` index over the Hugging Face cache: canonical revisions, vision/audio capability, garbage-collection plans. Reads headers, never tensor bytes, and never loads MLX. |
| `download` | Resumable Hugging Face snapshot downloads with disk-space planning and a filename safety check. |
| `upload` | Repository creation, preupload classification, basic LFS transfer, and NDJSON commits for model or dataset folders. Callers supply an explicit token or null. |
| `fit` | Deterministic memory estimates: weights, KV bytes per token, prefill transients, and this machine's RAM and wired ceiling. |

It does not own model loading, serving, application credential storage, or any
HTTP route. Those consume it.

See the runnable [fit example](examples/fit-models.ts). It scans a cache, loads each
model's configuration, estimates fit for a context length, and closes the registry.
`bun packages/hub/examples/fit-models.ts [hub-directory] [context-tokens]` runs it
against your own Hugging Face cache; the package test runs it against a synthetic one.

Downloads read `HF_TOKEN` or `~/.cache/huggingface/token` for gated repos.
The exported `hfToken` reader accepts optional environment and cache-token path
inputs so callers can reuse that precedence without mutating process state.
Uploads never resolve credentials implicitly. The app chooses its token and
passes it to `createRepo` or `uploadFolder` from `@mlx-bun/hub/upload`.
The [upload protocol tests](tests/upload.test.ts) are executable examples using
a local mock Hub; they cover regular/LFS files, authentication, filtering, and
commit payloads without publishing anything.
