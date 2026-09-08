import { expect, test } from "bun:test";
import * as ops from "../../src/mlx/ops";
import { Dtype } from "../../src/mlx/ffi";
import { fusedQwenConvolution } from "../../src/model/qwen-conv";
import { compiledSilu } from "../../src/model/qwen3_5";

test("fused Qwen convolution preserves typed SiLU and independent multi-batch state tails", () => {
  for (const dtype of [Dtype.bfloat16, Dtype.float32]) for (const B of [1, 2])
    for (const M of [1, 2, 3, 4, 16, 128]) {
      const D = 128, K = 4, key = ops.randomKey(BigInt(B * 129 + M));
      const x = ops.randomNormal([B, M, D], dtype, 0, 3, key);
      const state = ops.randomNormal([B, K - 1, D], dtype, 0, 3, key);
      const weight = ops.randomNormal([D, K, 1], dtype, 0, 1, key);
      key.dispose();
      const input = ops.concatAxis([state, x], 1);
      const tailView = input.slice([0, M, 0], [B, M + K - 1, D]);
      const tail = ops.copyOf(tailView); tailView.dispose();
      const conv = ops.conv1d(input, weight, 1, 0, 1, D);
      const expected = compiledSilu(conv);
      conv.dispose(); input.dispose();
      const [out, actualTail] = fusedQwenConvolution(x, state, weight);
      try {
        for (const [a, b] of [[out, expected], [actualTail, tail]] as const) {
          const ac = ops.contiguous(a), bc = ops.contiguous(b);
          try { expect(Buffer.from(ac.rawBytesView()).equals(Buffer.from(bc.rawBytesView()))).toBe(true); }
          finally { ac.dispose(); bc.dispose(); }
        }
        // The returned tail remains valid after releasing both borrowed inputs.
        x.dispose(); state.dispose();
        const ac = ops.contiguous(actualTail), bc = ops.contiguous(tail);
        try { expect(Buffer.from(ac.rawBytesView()).equals(Buffer.from(bc.rawBytesView()))).toBe(true); }
        finally { ac.dispose(); bc.dispose(); }
      } finally {
        x.dispose(); state.dispose(); weight.dispose(); out.dispose(); actualTail.dispose(); expected.dispose(); tail.dispose();
      }
    }
});
