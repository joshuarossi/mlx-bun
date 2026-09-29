# @mlx-bun/hub

Model discovery and artifact transfer for [`@mlx-bun/inference`](../inference/README.md).
The inference library opens local artifact directories; this package finds
and fetches them.

| Module | Owns |
| --- | --- |
| `registry` | A `bun:sqlite` index over the Hugging Face cache (`hubCacheRoot()`: `HF_HUB_CACHE`, `HF_HOME/hub`, `XDG_CACHE_HOME/huggingface/hub`, `~/.cache/huggingface/hub`) and any plain model directories the caller names: canonical revisions, vision/audio capability, garbage-collection plans. The caller chooses the index file. Reads headers, never tensor bytes, and never loads MLX. |
| `download` | Resumable Hugging Face snapshot downloads with disk-space planning, a filename safety check, and caller-owned cancellation that keeps partials resumable. |
| `upload` | Repository creation, preupload classification, basic LFS transfer, and NDJSON commits for model or dataset folders. Callers supply an explicit token or null. |

It does not own model loading, memory estimates, serving, application credential
storage, or any HTTP route. Those consume it; fit estimates live in
[`@mlx-bun/inference/execution/fit`](../inference/README.md#optional-execution-and-persistence),
which takes the registry's language-weight and expert bytes as inputs.
The package has no workspace dependencies and never loads MLX.

See the runnable [listing example](examples/list-models.ts). It scans a cache, lists
each model's type, weight and expert bytes, and vision and audio capability, and
closes the registry. `bun packages/hub/examples/list-models.ts [hub-directory]` runs it
against your own Hugging Face cache; the package test runs it against a synthetic one.

Downloads read `HF_TOKEN` or `~/.cache/huggingface/token` for gated repos.
The exported `hfToken` reader accepts optional environment and cache-token path
inputs so callers can reuse that precedence without mutating process state.
`downloadModel` accepts an `AbortSignal`. An abort rejects with the signal's
reason at the next checkpoint (metadata request, lock attempt, Range retry,
streamed chunk, or final publish) after pending writes settle, so the
`.incomplete` prefix resumes on the next run; the blob rename, the revision ref,
and the tracker's completion are never published after an abort. `onStatus`
hands the caller the live tracker row once the listing and preflight succeed,
so a caller can show one lifecycle from its own admission onward. The
[download tests](tests/download.test.ts) run every path against a local fake Hub.
Uploads never resolve credentials implicitly. The app chooses its token and
passes it to `createRepo` or `uploadFolder` from `@mlx-bun/hub/upload`.
Both accept an optional `signal`: an abort cancels the in-flight request or body
read, starts no later request once cancellation is observed, and rejects with
the signal's reason; a commit request already submitted may have been accepted
by the Hub, and the caller cannot roll it back. The [upload protocol tests](tests/upload.test.ts) are executable
examples using a local mock Hub; they cover regular/LFS files, authentication,
filtering, commit payloads, and cancellation without publishing anything.
