import type { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import type { Cache, KvAttentionView, KvDonorAttention } from "./gemma4-base";
import { quantizedSdpa, disposeTriple } from "./gemma4-base";

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

export function quantizedDonorAttention(keys: ops.QuantizedTensor, values: ops.QuantizedTensor,
  validity: Pick<KvDonorAttention, "offsets" | "starts" | "ends">,
  groupSize: number, bits: number): KvDonorAttention {
  return {
    width: keys.packed.shape[2]!, dtype: keys.scales.dtype, ...validity,
    attend: (q, scale, mask) => quantizedSdpa(q, keys, values, scale, mask, groupSize, bits),
    dispose() { disposeTriple(keys); disposeTriple(values); },
  };
}

export function captureKvAttention(cache: Cache, k: MlxArray, v: MlxArray): KvAttentionView {
    if (cache.attentionState) return cache.attentionState.appendAndFetch(k, v);
    const quantized = cache.quantizedAttention;
    if (quantized) {
      const { groupSize, bits } = quantized;
      const [keys, values] = quantized.updateAndFetchQuantized(k, v);
      return {
        attend: (q, scale, mask) => quantizedSdpa(q, keys, values, scale, mask, groupSize, bits),
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
