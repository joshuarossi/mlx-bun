import host.ts.Source
namespace Host.Ts.Sources.Inference.State.KvAttentionView
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/state/kv-attention-view.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cache, KvAttentionView, KvDonorAttention } from "../contracts/mlx/cache";
import { disposeTriple } from "./quantized-tensor";
import { kvStorage } from "./kv-storage";
import { quantizedAppendAttention } from "../layers/quantized-append-attention";
import { viewAffineKernel, type AffineKernels } from "./affine-attention";

export function captureKvDonorAttention(cache: Cache): KvDonorAttention {
  if (cache.captureDonorAttention) return cache.captureDonorAttention();
  const view = cache.captureDonorRows!();
  return {
    width: view.keys.shape[2]!, dtype: view.keys.dtype,
    offsets: view.offsets, starts: view.starts, ends: view.ends,
    attend: (q, scale, mask) => ops.sdpa(q, view.keys, view.values, scale, mask.mode, mask.arr),
    dispose() { view.keys.dispose(); view.values.dispose(); },
  };
}

/** Q-only attention over fetched affine keys and values with the storage's
 * kernel set (`viewAffineKernel`). Takes ownership of `keys` and `values`. */
export function quantizedDonorAttention(keys: ops.QuantizedTensor, values: ops.QuantizedTensor,
  validity: Pick<KvDonorAttention, "offsets" | "starts" | "ends">, kernels: AffineKernels): KvDonorAttention {
  return {
    width: keys.packed.shape[2]!, dtype: keys.scales.dtype, ...validity,
    attend: (q, scale, mask) => viewAffineKernel(kernels, q.shape[2]!, mask)(q, keys, values, scale, mask),
    dispose() { disposeTriple(keys); disposeTriple(values); },
  };
}

/** Append `k` and `v` to `cache` and return its attention view. Plain storage
 * reads with the stock SDPA; affine storage with `kernels`, the kernel set of
 * the row layout reading it (`viewAffineKernel`). */
export function captureKvAttention(row: Cache, k: MlxArray, v: MlxArray, kernels: AffineKernels): KvAttentionView {
    const cache = kvStorage(row);
    if (cache.attentionState) return cache.attentionState.appendAndFetch(k, v);
    const quantized = cache.quantizedAttention;
    if (quantized) {
      const { groupSize, bits } = quantized;
      const [keys, values] = quantized.updateAndFetchQuantized(k, v);
      return {
        attend: (q, scale, mask, independentPositions) => independentPositions && q.shape[2]! > 1
          ? quantizedAppendAttention(q, keys, values, scale, groupSize, bits)
          : viewAffineKernel(kernels, q.shape[2]!, mask)(q, keys, values, scale, mask),
        dispose() { disposeTriple(keys); disposeTriple(values); },
      };
    }
    const [keys, values] = cache.updateAndFetch(k, v);
    return {
      attend: (q, scale, mask) => ops.sdpa(q, keys, values, scale, mask.mode, mask.arr),
      dispose() { keys.dispose(); values.dispose(); },
    };
  }


/** Takes ownership of already aligned per-row donor views. Each storage codec
 * keeps its own attention arithmetic while the caller supplies one query batch. */
export function combineKvDonorAttention(rows: readonly KvDonorAttention[]): KvDonorAttention {
  return { width: rows[0]!.width, dtype: rows[0]!.dtype,
    offsets: rows.flatMap(row => [...row.offsets]), starts: rows.flatMap(row => [...row.starts]),
    ends: rows.flatMap(row => [...row.ends]),
    attend(q, scale, mask) {
      const outputs: MlxArray[] = [];
      try {
        for (const [index, row] of rows.entries()) {
          using query = q.slice([index, 0, 0, 0], [index + 1, q.shape[1]!, q.shape[2]!, q.shape[3]!]);
          const from = mask.arr?.shape.map(() => 0), to = mask.arr ? [...mask.arr.shape] : undefined;
          if (from && to && to.length === 4 && to[0]! > 1) { from[0] = index; to[0] = index + 1; }
          using arr = mask.arr ? mask.arr.slice(from!, to!) : null;
          outputs.push(row.attend(query, scale, { mode: mask.mode, arr }));
        }
        return outputs.length === 1 ? ops.contiguous(outputs[0]!) : ops.concatAxis(outputs, 0);
      } finally { for (const output of outputs) output.dispose(); }
    },
    dispose() { for (const row of rows) row.dispose(); },
  };
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.State.KvAttentionView
