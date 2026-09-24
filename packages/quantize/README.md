# @mlx-bun/quantize

Produces the quantized checkpoints that [`@mlx-bun/inference`](../inference/README.md)
loads and specializes on. Inference never quantizes; this package never serves.

| Module | Owns |
| --- | --- |
| `quantizer` | Quantize a checkpoint directory: per-module bit selection, dequantize/requantize through MLX, sharded output, config rewrite |
| `allocator` | Mixed-precision allocation from per-layer sensitivity under a bits-per-weight budget |
| `sensitivity` | Exact per-layer KL sensitivity on calibration text |
| `calibration` | Calibration sample loading and tokenization |
| `rotate`, `weight-transform` | Rotation and fold plans for Llama and Qwen families before quantization |
| `trellis` | Trellis codebooks, state packing, interleaving, and the host decoder that defines the packed format |
| `config-writer`, `atomic-output` | Quantization metadata and atomic directory publication |

Sharded safetensors writing lives in `@mlx-bun/inference/artifacts` and is
re-exported here for convenience.

```ts
import { quantizeModelDir } from "@mlx-bun/quantize";

await quantizeModelDir("/path/to/bf16-checkpoint", "/path/to/output", {
  bits: 4, groupSize: 64,
});
```

Job orchestration and the CLI verb belong to the app.
