# @mlx-bun/hub

Model discovery and acquisition for [`@mlx-bun/inference`](../inference/README.md).
The inference library opens local artifact directories; this package finds
and fetches them.

| Module | Owns |
| --- | --- |
| `registry` | A `bun:sqlite` index over the Hugging Face cache: canonical revisions, vision/audio capability, garbage-collection plans. Reads headers, never tensor bytes. |
| `download` | Resumable Hugging Face snapshot downloads with disk-space planning and a filename safety check. |
| `fit` | Deterministic memory estimates: weights, KV bytes per token, prefill transients, and this machine's RAM and wired ceiling. |

It does not own model loading, serving, or any HTTP route. Those consume it.

```ts
import { Registry, fit, thisMachine } from "@mlx-bun/hub";

const registry = new Registry();
registry.scan();
for (const record of registry.list()) {
  console.log(record.repoId, fit(record, thisMachine()).verdict);
}
```

Downloads read `HF_TOKEN` or `~/.cache/huggingface/token` for gated repos.
