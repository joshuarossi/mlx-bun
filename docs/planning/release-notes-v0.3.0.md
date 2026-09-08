# mlx-bun v0.3.0

This release adds the Qwen inference performance work, fixes long-generation
memory retention, and makes configured serving benchmarks reproducible.

- Packed Trellis decode and prefill kernels, interleaved weight readers,
  joint TurboQuant K/V operations and inverse rotation optimizations.
- Opt-in Qwen uniform KV4 speculation with MTP and bounded paired target/draft
  RAM prefixes. Exact history, model identity and adapter namespace govern
  reuse; paired speculative state does not persist across server restarts.
- Model-owned structural token appends, serving ownership and parser fixes,
  and a bounded range cache for sustained generation.
- SSD flushes recognize prefixes covered by snapshots committed later in the
  same flush, preserving errors for genuinely missing state.
- Native runtime pack 0.4.0, bundling MLX 0.32.2 and the matching MLX-C API.
  Persistent cache compatibility includes the runtime and GPU identity.
- Serving benchmark controls for explicit draft, KV and prompt-cache settings,
  with saved commands, request hashes, complete-request timing and raw results.

The required packed Qwen target completes the fresh Luke Kanban task with
thinking enabled and the published profile. Its configured KV4/MTP serving
suite passes every phase on the M4 Pro. Full measurements, machine labels and
limits are in the [benchmark record](https://github.com/joshuarossi/mlx-bun/blob/v0.3.0/docs/reference/benchmarks.md).
No matched successful original/final Kanban timing is available, so this
release claims no percentage reduction in full-task completion time.

Optimization defaults remain gated. The standard-suite MiniCPM/Qwen timed
output differences against the reference and the larger Qwen 4/8-bit
artifact's prefill memory failures on the 24 GB Mac remain under investigation.
The SSD restart failures from that suite are fixed and all four affected
default/mixed serving repeats pass on their first attempt.

The [server configuration reference](https://github.com/joshuarossi/mlx-bun/blob/v0.3.0/docs/reference/server-config.md)
documents experimental switches and their supported combinations. Requires
Apple Silicon, macOS 14 or later, and Bun 1.4.0 or later for npm installs.
