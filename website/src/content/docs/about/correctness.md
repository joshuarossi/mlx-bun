---
title: Correctness
description: Bit-exact logit parity with the Python reference is the project's oracle.
---

Logit parity with mlx-lm (same weights, Python reference) is the project's
**oracle**. The test suite holds the forward pass **bit-exact** against it —
including every quantized-KV configuration (kv8, kv4, and the 26B's mixed
per-layer scheme) and the fused quantized-attention prefill, which is bit-exact
against optiq's reference implementation.

Every ported helper follows the reference implementation's exact op composition,
down to constants built at load time. The one latent divergence ever found —
rope frequencies computed host-side instead of on-device — was root-caused and
fixed (see the findings log in
[PLAN.md](https://github.com/joshuarossi/mlx-bun/blob/main/PLAN.md)). Golden
files are regenerated only by explicit scripts running the Python oracle.

```sh
bun test    # fast tier runs everywhere; model-loaded tests auto-skip
            # unless the reference snapshot is in your HF cache
```

## Why this matters

A local model is only useful if it produces the *same* outputs as the reference
implementation it claims to run. "Close enough" quantization or a subtly
different attention kernel can silently change behavior — wrong tool calls,
drifting reasoning, different refusals. Holding the forward pass bit-exact means
mlx-bun's outputs are the reference's outputs, not an approximation of them.
