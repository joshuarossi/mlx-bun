import host.ts.Source
namespace Host.Ts.Sources.Inference.State.Ssm
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/state/ssm.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// Gated DeltaNet recurrence for Qwen3.5 linear-attention layers.
//
// Port target: mlx_lm.models.gated_delta (compute_g + the `gated_delta_step`
// Metal kernel) and the recurrent-state cache. mlx-lm runs the GPU kernel by
// default (use_kernel = not training), and its float accumulation / simd_sum
// reduction order differ from the pure-ops fallback — so BIT-EXACT parity with
// mlx-lm requires the SAME kernel, dispatched with the SAME grid/threadgroup.
// We port the non-vectorized variant (g.ndim == 3). Padded prefill selects
// the oracle masked specialization; unpadded execution retains its kernel.
//
// Numerics (must match the reference dtypes exactly — mlx infers the kernel's
// pointer element types from the input arrays):
//   q, k        bf16  [B, T, Hk, Dk]   (after inv_scale * rms_norm(., None))
//   v           bf16  [B, T, Hv, Dv]
//   g           f32   [B, T, Hv]        (= exp(-exp(A_log_f32) * softplus(a+dt_bias)))
//   beta        bf16  [B, T, Hv]        (= sigmoid(b))
//   state_in    f32   [B, Hv, Dv, Dk]
//   y (out)     bf16  [B, T, Hv, Dv]    (InT)
//   state_out   f32   [B, Hv, Dv, Dk]   (StT)
// GQA is handled inside the kernel (hk_idx = hv_idx / (Hv/Hk)); q/k stay at Hk.

import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { materializeCopy } from "@mlx-bun/mlx/materialize";
import * as ops from "@mlx-bun/mlx/ops";
import type { GatedDeltaCache, GatedDeltaParameters, Mask } from "../contracts/mlx/cache";
import { gatedDeltaUpdate } from "../kernels/delta/gated";
import { gatedDeltaState } from "../kernels/delta/state";
import { disposing } from "../layers/helpers";
import type { SsmPrefillPadding } from "./ssm-prefill-padding";

/** The causal convolution of `qkv` [B, S, convDim] over the stored `state`
 *  [B, K-1, convDim], copied from GatedDeltaNet's `#convolve` without the
 *  activation, which belongs to the block's glue (`layer.heads`). Returns the
 *  raw conv1d output and the next state: each row's last K-1 input columns,
 *  ending at `rowLengths[row]` when given, else at the window's end. Borrows
 *  its inputs. */
function convolve(qkv: MlxArray, state: MlxArray, weight: MlxArray, rowLengths?: readonly number[]): [MlxArray, MlxArray] {
  const [, S, D] = qkv.shape as [number, number, number];
  const input = ops.concatAxis([state, qkv], 1);
  // MLX copy and contiguous can both alias the whole prefill buffer.
  // Materialize only the tail so cache residency follows its logical size.
  const tail = convTail(input, S, weight.shape[1]! - 1, rowLengths);
  const conv = ops.conv1d(input, weight, 1, 0, 1, D);
  input.dispose();
  return [conv, tail];
}

function convTail(input: MlxArray, processed: number, nKeep: number, rowLengths?: readonly number[]): MlxArray {
  const [B, , D] = input.shape as [number, number, number];
  if (rowLengths) {
    using indices = ops.fromInt32(rowLengths.flatMap(length =>
      Array.from({ length: nKeep }, (_, position) => length + position)), [B, nKeep, 1]);
    return ops.takeAlongAxis(input, indices, 1);
  }
  using view = input.slice([0, processed, 0], [B, processed + nKeep, D]);
  return materializeCopy(view);
}

/** The recorded recurrence inputs of a verify window: the convolution inputs and
 *  the kernel's position-local inputs (the heads' k and v, the a and b
 *  projections), each [B, S, ...], and the layer they came from. The state after
 *  the first `keep` positions is the same arithmetic prefix whether or not the
 *  rest of the window was ever processed (the kernel walks positions in order;
 *  the convolution and the glue are per position), so a rejected tail needs no
 *  recomputation: the retained rows fold into the pre-round state. */
interface SsmWindowRows {
  qkv: MlxArray;
  k: MlxArray;
  v: MlxArray;
  a: MlxArray;
  b: MlxArray;
  layer: GatedDeltaParameters;
}

/** One armed speculative verify round on an SSMCache: the pre-round state
 *  snapshot (retained refs — MLX arrays are immutable, so this is free) plus
 *  the window's recorded rows. `recurDecode`/`recurWindow` record them. */
export interface SsmSpecRound {
  /** True from specRoundBegin() until the layer's forward records. */
  armed: boolean;
  prevConv: MlxArray | null;
  prevRecurrent: MlxArray | null;
  prevOffset: number;
  prevOffsets: number[] | null;
  /** The window's recorded rows; null until the verify forward records. */
  rows: SsmWindowRows | null;
  /** Window length S of the recorded verify forward. */
  S: number;
}

/** Recurrent cache for a gated-DeltaNet layer — port of mlx-lm
 *  cache.ArraysCache(size=2): slot 0 = causal-conv state [B, K-1, conv_dim],
 *  slot 1 = recurrent state [B, Hv, Dv, Dk] f32. `recurDecode` and
 *  `recurWindow` own both slots and the kernels that update them
 *  (GatedDeltaCache); the DeltaNet block hands them its projections. `advance(N)` only
 *  tracks token count for B=1 single-stream (lengths / left_padding are
 *  batched-decode concerns). Not a key/value cache: no KV scheme converts it.
 *
 *  A rolled-back speculative round leaves the snapshot in the slots and its
 *  retained window rows pending; they fold in (the state-only kernel over the
 *  recorded rows, and the convolution tail) the next time anything reads the
 *  state: the next forward, `state()`, the slots, row moves or persistence. The
 *  rollback itself builds no graph. */
export class SSMCache implements GatedDeltaCache {
  #conv: MlxArray | null = null;
  #recurrent: MlxArray | null = null;
  /** Rows a rolled-back round retained, not yet folded into the slots, with each row's kept count. */
  #pending: { rows: SsmWindowRows; keep: readonly number[] } | null = null;
  offset = 0;
  prefillPadding: SsmPrefillPadding | null = null;
  /** Live speculative verify round; null outside a verify transaction. */
  specRound: SsmSpecRound | null = null;
  /** Per-row token coverage (batch lane only; null on serial B=1 caches,
   *  where `offset` IS the row's count). mlx-lm's ArraysCache tracks no
   *  offset at all (cache.py:594-722) — per-sequence coverage is the
   *  server's bookkeeping; ours lives here because prompt-cache put()
   *  keys on EXACT coverage (#putOrDispose offset === tokens.length) and
   *  merged rows carry different totals. Seeded by mergeRows, advanced in
   *  lockstep by advance(), row-filtered by filter(). */
  offsets: number[] | null = null;

  /** The causal-conv state, with any retained rows folded in. */
  get conv(): MlxArray | null { this.#fold(); return this.#conv; }
  set conv(value: MlxArray | null) { this.#fold(); this.#conv = value; }
  /** The recurrent state, with any retained rows folded in. */
  get recurrent(): MlxArray | null { this.#fold(); return this.#recurrent; }
  set recurrent(value: MlxArray | null) { this.#fold(); this.#recurrent = value; }

  signature(): string { return "ssm"; }
  bytesPerToken(): number { return 0; }
  get batchSize(): number { return this.offsets?.length ?? 1; }

  /** Row `i`'s own token coverage (per-row when batched, `offset` serial). */
  rowOffset(i: number): number {
    return this.offsets ? this.offsets[i]! : this.offset;
  }

  /** Linear-attn layers don't go through the KV update path. */
  updateAndFetch(): [MlxArray, MlxArray] {
    throw new Error("SSMCache has no KV updateAndFetch (gated-DeltaNet layer)");
  }

  makeMask(N: number, _windowSize: number | null): Mask {
    const arr = this.prefillPadding?.makeMask(N) ?? null;
    return { mode: arr ? "array" : "", arr };
  }

  recurDecode(qkv: MlxArray, a: MlxArray, b: MlxArray, layer: GatedDeltaParameters): MlxArray {
    return this.#recur(qkv, a, b, layer, null);
  }

  recurWindow(qkv: MlxArray, a: MlxArray, b: MlxArray, layer: GatedDeltaParameters): MlxArray {
    return this.#recur(qkv, a, b, layer, this.prefillPadding);
  }

  /** GatedDeltaNet.forward from its projections to the recurrence output,
   *  copied: zero the padded positions, convolve over the stored conv state,
   *  run the block's glue, run the gated-delta kernel over the stored
   *  recurrent state, replace both states and advance. Inside an armed round
   *  the replaced states and the inputs go to the round instead of being
   *  disposed, and the round replays through `layer`. */
  #recur(qkv: MlxArray, a: MlxArray, b: MlxArray, layer: GatedDeltaParameters,
    padding: SsmPrefillPadding | null): MlxArray {
    const [B, S, convDim] = qkv.shape as [number, number, number];
    const nKeep = layer.convWeight.shape[1]! - 1;
    this.#fold();

    const spec = this.specRound;
    if (spec) {
      if (!spec.armed)
        throw new Error("SSMCache: spec round already recorded this round");
      spec.armed = false;
      spec.S = S;
    }

    using mask = padding?.makeMask(S) ?? null;
    if (mask) {
      using expanded = ops.reshape(mask, [B, S, 1]);
      using zero = MlxArray.fromBytesCopy(new Uint8Array(qkv.dtype === Dtype.float32 ? 4 : 2), [], qkv.dtype);
      qkv = disposing(qkv, ops.where(expanded, qkv, zero));
    }
    // Convolution keeps each row's last real-token tail, including empty rows.
    const convState = this.#conv ?? ops.zeros([B, nKeep, convDim], qkv.dtype);
    const [conv, newConv] = convolve(qkv, convState, layer.convWeight, padding?.convolutionLengths(S));
    if (!this.#conv) convState.dispose();
    if (spec) spec.prevConv = this.#conv;
    else this.#conv?.dispose();
    this.#conv = newConv;

    const { q, k, v } = layer.heads(conv);
    conv.dispose();
    const [out, newState] = gatedDeltaUpdate(q, k, v, a, b, layer.aLog, layer.dtBias, this.#recurrent, mask);
    q.dispose();
    if (spec) {
      spec.rows = { qkv, k, v, a, b, layer };
      spec.prevRecurrent = this.#recurrent;
    } else {
      for (const array of [qkv, k, v, a, b]) array.dispose();
      this.#recurrent?.dispose();
    }
    this.#recurrent = newState;
    this.advance(S);
    return out;
  }

  /** Fold a rolled-back round's retained rows into the slots: each row's
   *  convolution tail ends at its kept count, and the state-only kernel walks the
   *  kept positions of the recorded k, v, a and b from the restored state. The
   *  values are the verify window's own, and the kernel's recurrence is the
   *  update kernel's, so both slots are bit for bit those of a call over only
   *  the retained positions. */
  #fold(): void {
    const pending = this.#pending;
    if (!pending) return;
    this.#pending = null;
    const { rows, keep } = pending;
    try {
      const [B, , convDim] = rows.qkv.shape as [number, number, number];
      const nKeep = rows.layer.convWeight.shape[1]! - 1;
      const uniform = keep.every(count => count === keep[0]);
      using zeros = this.#conv ? null : ops.zeros([B, nKeep, convDim], rows.qkv.dtype);
      using input = ops.concatAxis([this.#conv ?? zeros!, rows.qkv], 1);
      const conv = convTail(input, keep[0]!, nKeep, uniform ? undefined : keep);
      let recurrent: MlxArray;
      try { recurrent = gatedDeltaState(rows.k, rows.v, rows.a, rows.b, rows.layer.aLog, rows.layer.dtBias, this.#recurrent, keep); }
      catch (error) { conv.dispose(); throw error; }
      this.#conv?.dispose();
      this.#recurrent?.dispose();
      this.#conv = conv;
      this.#recurrent = recurrent;
    } finally { for (const array of [rows.qkv, rows.k, rows.v, rows.a, rows.b]) array.dispose(); }
  }

  advance(n: number): void {
    if (this.prefillPadding) { this.advanceRows(this.prefillPadding.advance(n)); return; }
    this.offset += n;
    // Batched rows step together (one forward advances every row), so the
    // per-row counts move in lockstep; they DIFFER only in their merge-time
    // seeds (each row's prompt length).
    if (this.offsets) for (let i = 0; i < this.offsets.length; i++) this.offsets[i]! += n;
  }

  /** Methods may retain different verified prefixes for each active request. */
  advanceRows(counts: readonly number[]): void {
    if (!this.offsets) { this.offset += counts[0]!; return; }
    for (let row = 0; row < this.offsets.length; row++) this.offsets[row]! += counts[row]!;
    this.offset = Math.max(...this.offsets);
  }

  state(): MlxArray[] {
    this.#fold();
    const out: MlxArray[] = [];
    if (this.#conv) out.push(this.#conv);
    if (this.#recurrent) out.push(this.#recurrent);
    return out;
  }

  isTrimmable(): boolean {
    return false; // recurrent state can't be trimmed per token — see specRound*
  }

  trim(_n: number): void {
    throw new Error("SSMCache is not trimmable");
  }

  // --- speculative verify-round support -----------------------------------
  // The serve loop arms a round before the verify forward and resolves it
  // after the accept walk. The layer's forward, seeing an armed round, hands
  // its replaced state slots to the round instead of disposing them and
  // records the window's rows. Cache/interface contract: rollback(keep)
  // restores the snapshot and retains the first `keep` window rows, which fold
  // in bit-exactly before the state is next read; commit frees the snapshot
  // and the recordings.

  specRoundBegin(): void {
    this.#dropSpecRound(); // defensive: a mid-round throw left a stale round
    this.#fold();
    this.specRound = {
      armed: true,
      prevConv: null,
      prevRecurrent: null,
      prevOffset: this.offset,
      prevOffsets: this.offsets ? [...this.offsets] : null,
      rows: null,
      S: 0,
    };
  }

  specRoundCommit(): void {
    this.#dropSpecRound();
  }

  specRoundRollback(keep: number | readonly number[]): void {
    const r = this.specRound;
    if (!r) throw new Error("SSMCache.specRoundRollback without an armed round");
    if (r.armed)
      throw new Error("SSMCache.specRoundRollback before the verify forward recorded");
    if (typeof keep === "number" ? keep < 0 || keep > r.S : keep.some(count => count < 0 || count > r.S))
      throw new Error(`SSMCache.specRoundRollback keep=${keep} outside window S=${r.S}`);
    if (!r.rows) throw new Error("SSMCache.specRoundRollback with no recorded window");
    // Restore the pre-round snapshot (ownership moves back to the cache).
    this.#conv?.dispose();
    this.#recurrent?.dispose();
    this.#conv = r.prevConv;
    this.#recurrent = r.prevRecurrent;
    r.prevConv = null;
    r.prevRecurrent = null;
    this.offset = r.prevOffset;
    this.offsets = r.prevOffsets;
    const rows = typeof keep === "number" ? Array<number>(r.rows.qkv.shape[0]!).fill(keep) : keep;
    if (rows.some(count => count > 0)) {
      // The kept rows move to the cache, which folds them in before the next read.
      this.#pending = { rows: r.rows, keep: [...rows] };
      r.rows = null;
    }
    if (typeof keep === "number") this.advance(keep);
    else this.advanceRows(keep);
    this.#dropSpecRound();
  }

  #dropSpecRound(): void {
    const r = this.specRound;
    if (!r) return;
    r.prevConv?.dispose();
    r.prevRecurrent?.dispose();
    if (r.rows) for (const array of [r.rows.qkv, r.rows.k, r.rows.v, r.rows.a, r.rows.b]) array.dispose();
    this.specRound = null;
  }

  dispose(): void {
    this.#dropSpecRound();
    const pending = this.#pending?.rows;
    this.#pending = null;
    if (pending) for (const array of [pending.qkv, pending.k, pending.v, pending.a, pending.b]) array.dispose();
    this.#conv?.dispose();
    this.#recurrent?.dispose();
    this.#conv = null;
    this.#recurrent = null;
    this.prefillPadding = null;
  }

  // --- batch-lane dynamic-B ops (BatchScheduler only) ----------------------
  // Both state slots are plain [B, ...] tensors with no temporal axis and no
  // left-padding, so the batched twins of mergeKVRows/filterKVRows collapse
  // to B-axis concat/take. `offset` is bookkeeping only for SSM layers (RoPE
  // reads the FULL-attention caches; the linear-attn forward never reads it),
  // so merged rows carrying different token counts share the max; the exact
  // per-row counts live in `offsets` (extraction's coverage key).

  /** Merge a fully-prefilled solo row into a running batched cache (`prev`
   *  null ⇒ the solo row becomes the batch). The returned cache owns fresh
   *  arrays — or, when there is nothing to concat, arrays STOLEN from `solo`
   *  (nulled there so the scheduler's unconditional dispose of the solo
   *  caches stays safe). `prev`/`solo` disposal remains the caller's job. */
  static mergeRows(prev: SSMCache | null, solo: SSMCache): SSMCache {
    if (!solo.conv || !solo.recurrent)
      throw new Error("SSMCache.mergeRows: solo row has no state (prefill first)");
    const out = new SSMCache();
    if (prev) {
      if (!prev.conv || !prev.recurrent)
        throw new Error("SSMCache.mergeRows: batched cache has no state");
      out.conv = ops.concatAxis([prev.conv, solo.conv], 0);
      out.recurrent = ops.concatAxis([prev.recurrent, solo.recurrent], 0);
    } else {
      out.conv = solo.conv;
      out.recurrent = solo.recurrent;
      solo.conv = null;
      solo.recurrent = null;
    }
    out.offset = Math.max(prev?.offset ?? 0, solo.offset);
    // Seed per-row coverage: an adopted serial `prev` (offsets null) is one
    // row whose exact count is its scalar offset.
    out.offsets = [...(prev ? prev.offsets ?? [prev.offset] : []), solo.offset];
    return out;
  }

  /** Evict rows not in `keep` (ascending row indices), in place. */
  filter(keep: number[]): void {
    if (this.conv && this.recurrent) {
      const idx = ops.fromInt32(keep, [keep.length]);
      const conv = ops.takeAxis(this.conv, idx, 0);
      const recurrent = ops.takeAxis(this.recurrent, idx, 0);
      idx.dispose();
      this.conv.dispose();
      this.recurrent.dispose();
      this.conv = conv;
      this.recurrent = recurrent;
    }
    this.prefillPadding?.filter(keep);
    if (this.offsets) {
      this.offsets = keep.map((i) => this.offsets![i]!);
      this.offset = Math.max(0, ...this.offsets);
    }
  }

  filterRows(keep: readonly number[]): void { this.filter([...keep]); }

  /** Row `i` as a fresh SERIAL cache — port of mlx-lm ArraysCache.extract
   *  (cache.py:673-676: `cache.cache = [c[idx : idx + 1] for c in self.cache]`,
   *  a B-axis slice of every state slot). A proper subset gets compact storage
   *  so retaining one row does not pin the other rows. A singleton retains an
   *  independent handle over its complete allocation. Offset =
   *  the row's OWN coverage, not the shared max. */
  extractRow(i: number): SSMCache {
    if (!this.conv || !this.recurrent)
      throw new Error("SSMCache.extractRow: empty cache");
    const cut = (a: MlxArray): MlxArray => {
      const lo = a.shape.map(() => 0);
      lo[0] = i;
      const hi = [...a.shape];
      hi[0] = i + 1;
      using view = a.slice(lo, hi);
      return a.shape[0] === 1 ? ops.contiguous(view) : materializeCopy(view);
    };
    const out = new SSMCache();
    out.conv = cut(this.conv);
    out.recurrent = cut(this.recurrent);
    out.offset = this.rowOffset(i);
    return out;
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.State.Ssm
