// Gated DeltaNet recurrence for Qwen3.5 linear-attention layers.
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
import { materializeCopy } from "@mlx-bun/mlx/materialize";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cache,Mask } from "../contracts/mlx/cache";
import type { SsmPrefillPadding } from "./ssm-prefill-padding";

/** Recurrent cache for a gated-DeltaNet layer — port of mlx-lm
 *  cache.ArraysCache(size=2): slot 0 = causal-conv state [B, K-1, conv_dim],
 *  slot 1 = recurrent state [B, Hv, Dv, Dk] f32. The linear-attn layer reads
 *  and writes these slots directly; `advance(N)` only tracks token count for
 *  B=1 single-stream (lengths / left_padding are batched-decode concerns).
 *  Not a KVCache, so maybeQuantizeKv skips it. */
/** One armed speculative verify round on an SSMCache: the pre-round state
 *  snapshot (retained refs — MLX arrays are immutable, so this is free) plus
 *  the layer's recorded position-local kernel inputs, which make a partial
 *  reject bit-exactly replayable: state after the first `keep` window tokens
 *  is the same arithmetic prefix whether or not the rejected tail was ever
 *  processed. The replay is installed by the OWNING layer (it needs the conv
 *  weight / A_log / dt_bias); the cache only stores and frees. */
export interface SsmSpecRound {
  /** True from specRoundBegin() until the layer's forward records. */
  armed: boolean;
  prevConv: MlxArray | null;
  prevRecurrent: MlxArray | null;
  prevOffset: number;
  prevOffsets: number[] | null;
  /** Pre-conv in_proj output [B,S,convDim] — position-local. */
  qkv: MlxArray | null;
  /** Gate/beta projections [B,S,Hv] — position-local. */
  a: MlxArray | null;
  b: MlxArray | null;
  /** Window length S of the recorded verify forward. */
  S: number;
  /** Layer-bound prefix replay: called AFTER the snapshot is restored onto
   *  the cache; advances conv/recurrent/offset by `keep` tokens. */
  replay: ((cache: SSMCache, keep: number | readonly number[]) => void) | null;
}

export class SSMCache implements Cache {
  conv: MlxArray | null = null;
  recurrent: MlxArray | null = null;
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
    const out: MlxArray[] = [];
    if (this.conv) out.push(this.conv);
    if (this.recurrent) out.push(this.recurrent);
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
  // its replaced state slots to the round instead of disposing them, records
  // qkv/a/b, and installs the replay. Cache/interface contract:
  // rollback(keep) restores the snapshot then replays `keep` window tokens
  // bit-exactly; commit frees the snapshot + recordings.

  specRoundBegin(): void {
    this.#dropSpecRound(); // defensive: a mid-round throw left a stale round
    this.specRound = {
      armed: true,
      prevConv: null,
      prevRecurrent: null,
      prevOffset: this.offset,
      prevOffsets: this.offsets ? [...this.offsets] : null,
      qkv: null,
      a: null,
      b: null,
      S: 0,
      replay: null,
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
    // Restore the pre-round snapshot (ownership moves back to the cache).
    this.conv?.dispose();
    this.recurrent?.dispose();
    this.conv = r.prevConv;
    this.recurrent = r.prevRecurrent;
    r.prevConv = null;
    r.prevRecurrent = null;
    this.offset = r.prevOffset;
    this.offsets = r.prevOffsets;
    if (typeof keep === "number" ? keep > 0 : keep.some(count => count > 0)) {
      if (!r.replay) throw new Error("SSMCache.specRoundRollback with no recorded replay");
      r.replay(this, keep); // advances conv/recurrent/offset by `keep`
    }
    this.#dropSpecRound();
  }

  #dropSpecRound(): void {
    const r = this.specRound;
    if (!r) return;
    r.prevConv?.dispose();
    r.prevRecurrent?.dispose();
    r.qkv?.dispose();
    r.a?.dispose();
    r.b?.dispose();
    this.specRound = null;
  }

  dispose(): void {
    this.#dropSpecRound();
    this.conv?.dispose();
    this.recurrent?.dispose();
    this.conv = null;
    this.recurrent = null;
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
