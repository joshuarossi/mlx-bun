# mlx-bun v0.4.0

This release brings shared batched decode, generated-history cache reuse and
resumable generation together through separate scheduling, inference, sampling
and persistence interfaces.

- Shared ordinary and speculative execution supports Qwen MTP, prompt lookup,
  standalone, assistant, DeepSpec and DSpark/DFlash providers on qualified
  model/request combinations. Single requests run at B=1 through the scheduler.
- Full and rotating affine/TurboQuant cache layouts compose with delayed and
  per-layer precision, speculative rollback and generated target/draft state.
- Completed decode populates the shared RAM/SSD cache so later turns can reuse
  generated history. SSD persistence is queued and runs during idle ownership.
- Ordinary interrupted-generation resume now works through shared execution,
  including compatible adapters and quantized caches. Restored sampler history,
  pending tokens and usage accounting preserve the continuation contract.
- Ordinary paged storage and adapter-qualified prompt lookup use the same state
  and execution interfaces. GLM native MTP gains shared cache transactions and
  row state; final real-artifact testing remains deferred.
- Measured Trellis v13 is selected by default, and eligible Qwen KV4 speculation
  is enabled. Workload-dependent lookup and other experimental settings remain
  opt-in. Memory fit estimates are advisory unless users choose explicit limits.
- Benchmark reporting retains request/source identities, paired comparisons,
  failures and configuration differences. CI and the release build use Bun 1.4.2.

Serving keeps its existing `--batch 8` default. A lone eligible request starts
immediately at B=1; the cap does not wait for eight requests. `--batch 1` retains
the serial executor, and unsupported compositions can still use it. Removing
serial and completing every feature combination are follow-up work.

Checkpoint capture is eventually persistent: queued snapshots can remain in RAM
during uninterrupted traffic. A successful explicit flush is the durability
boundary. Media, fill/grammar-jump and direct paged-attention work remain tracked.
No DSpark/DFlash checkpoint has been trained for this campaign; execution fixtures
do not establish trained-drafter performance.

Measured performance and its workload limits are in the
[benchmark record](https://github.com/joshuarossi/mlx-bun/blob/v0.4.0/docs/reference/benchmarks.md).
This release does not claim a matched full-task Kanban speedup or completion of
the entire optimization program. Supported settings are documented in the
[server configuration reference](https://github.com/joshuarossi/mlx-bun/blob/v0.4.0/docs/reference/server-config.md).

Requires Apple Silicon and macOS 14 or later. npm installs require Bun 1.4.0 or
later; Bun 1.4.2 is the tested version. The existing native runtime pack 0.4.0
provides MLX 0.32.2 and its matching C API.
