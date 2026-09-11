# GPTQ block-indexing reproduction and upstream report draft

Status: reproduced locally; not submitted upstream. The source review targets
[mlx-lm `e5962529`](https://github.com/ml-explore/mlx-lm/blob/e5962529e5614ce00f14bdd39fe5fc6e410ca2b0/mlx_lm/quant/gptq.py#L117).
The reproduction runs the installed mlx-lm 0.31.3 implementation, checks that
both offending expressions are present, and creates a corrected function in
memory. It does not edit the installed package or import mlx-bun's quantizer.
The same fixture also passes against the cited upstream file loaded with
`--upstream-file`; both runs change 23 packed weight words. The Python
dependencies remain those of the installed reference environment.

## Run

Use an existing Python environment containing MLX and mlx-lm:

```sh
python repro.py
# Or check a locally saved, pinned upstream gptq.py:
python repro.py --upstream-file /path/to/gptq.py
```

Run from this directory. No model, network access, Metal computation, or GPU
allocation is required by the fixture; it selects the CPU device. The observed
result with MLX 0.32.2 and mlx-lm 0.31.3 was:

```json
{
  "mlx": "0.32.2",
  "mlx_lm": "0.31.3",
  "device": "cpu",
  "later_group_global_write_sum": 0,
  "later_group_local_write_sum": 1,
  "packed_weight_words_changed": 23
}
```

The packed-weight difference shows that the indexing affects the quantizer's
output on this fixture. It is not a model-quality measurement or proof that
all checkpoints improve. A patch should also add a regression test against
an independently implemented GPTQ reference.

## Draft issue

Title: GPTQ error propagation mixes global and block-local column indices

`gptq_quantize` appears to have two interacting block-indexing errors:

1. `k` is a global weight-column index, but `err` has only `group_size`
   columns. After the first group, writing `err[..., k:k+1]` is out of range;
   on MLX 0.32.2 the write has no effect.
2. The inner update ends at `k+j`, although `j` is already the group's global
   end. This updates columns in later groups before the deferred matrix update
   applies the group's errors there again.

Both expressions are present in the linked revision. The attached CPU-only
fixture isolates the dropped write and runs the actual quantizer on a
synthetic linear layer, comparing it with an in-memory two-line correction.
It needs no model weights or calibration download.

Proposed correction:

```diff
- W[..., k : k + j] -= e @ Hinv[k : k + 1, k : k + j]
- err[..., k : k + 1] = e
+ W[..., k : j] -= e @ Hinv[k : k + 1, k : j]
+ err[..., k - i : k - i + 1] = e
```

Is the intended algorithm to update only the current group inside the loop,
then apply its buffered errors to the remaining columns once? If so, I can
send this correction with a regression test covering multiple groups and
the single-group control.

## Duplicate search

A search of open and closed mlx-lm issues and pull requests for GPTQ on
2026-09-11 found synchronization and loading reports, including #1122,
#1094 and #1086, but no matching indexing report. This is a bounded search,
not proof that the issue has never been reported. Recheck before posting.
