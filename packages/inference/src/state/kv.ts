import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { AttentionRead,BidirectionalAttentionCache,BlockAttentionCache,Cache,CommittedAttentionCache,CompiledDecodeCache,DecodeSlot,DecodeStepInputs,DecodeStepPlan,DecodeTrace,KvDonorRows,Mask } from "../contracts/mlx/cache";
import { bidirMask, createCausalMask } from "../kernels/attention/masks";
import { QuantizedKVCache } from "./quantized-kv";
import { plainKvStorage } from "./dense-kv-reads";
import { AttentionMasks, causalLease, sdpaRead, unmaskedLease, withLease } from "./attention-read";
import { unfusedAffineKernels } from "./affine-attention";


/** KV cache — port of mlx-lm cache.py KVCache: preallocated in steps of
 *  256 along the sequence axis, updated in place via slice_update.
 *
 *  Reads: each named read appends through `updateAndFetch` and attends the
 *  fetched prefix with the stock fused SDPA, the call every graph makes after
 *  `updateAndFetch` today. Decode passes no mask and a window the fused causal
 *  mask; at one query the two compute the same bits, so a one-row window needs
 *  no case of its own. This cache has no sliding window (graphs compose
 *  `RotatingKVCache` for sliding layers), so only a bidirectional read builds
 *  a mask array. */
export class KVCache implements CompiledDecodeCache, CommittedAttentionCache, BidirectionalAttentionCache, BlockAttentionCache {
  readonly denseKvReads = plainKvStorage;
  static readonly STEP = 256;
  /** Set only by compiled-decode trace adapters (see Cache). */
  readonly ropeOffsetArr?: MlxArray;
  keys: MlxArray | null = null;
  values: MlxArray | null = null;
  offset = 0;

  constructor(
    /** The per-forward masks of the model this cache belongs to. Row layouts
     * made from this cache (`state/layout`) share them. */
    readonly masks = new AttentionMasks(),
  ) {}

  signature(): string { return "kv:plain"; }

  appendDecode(k: MlxArray, v: MlxArray): AttentionRead {
    const [keys, values] = this.updateAndFetch(k, v);
    return sdpaRead(keys, values, unmaskedLease);
  }

  appendWindow(k: MlxArray, v: MlxArray): AttentionRead {
    const [keys, values] = this.updateAndFetch(k, v);
    return sdpaRead(keys, values, causalLease);
  }

  /** The graph qualifies bf16 committed spans as the window read
   * (`supportsCommittedAppendCache` admits storage without `kvBits`), so a
   * committed span reads exactly as a window does. */
  appendCommitted(k: MlxArray, v: MlxArray): AttentionRead {
    return this.appendWindow(k, v);
  }

  /** Gemma 4's vision prefill read: the causal mask OR'd with the image block
   * overlay (`bidirMask`), then the fused SDPA with that array mask. One mask
   * per forward: every layer passes the same `bidirectional` tensor. */
  appendBidirectional(k: MlxArray, v: MlxArray, bidirectional: MlxArray): AttentionRead {
    const L = k.shape[2]!;
    const mask = this.masks.lease("bidirectional:none", `${L}`, () => bidirMask(L, null, bidirectional), bidirectional);
    return withLease(mask, held => {
      const [keys, values] = this.updateAndFetch(k, v);
      return sdpaRead(keys, values, held);
    });
  }

  /** DiffusionGemma's canvas read on a full-attention layer: the stored
   * positions in order, then the block's keys and values, with no mask. */
  readBlock(k: MlxArray, v: MlxArray): AttentionRead {
    const [storedK, storedV] = this.temporalView();
    let keys: MlxArray, values: MlxArray;
    try {
      keys = ops.concatAxis([storedK, k], 2);
      try { values = ops.concatAxis([storedV, v], 2); }
      catch (error) { keys.dispose(); throw error; }
    } finally { storedK.dispose(); storedV.dispose(); }
    return sdpaRead(keys, values, unmaskedLease);
  }

  bytesPerToken(): number {
    const steps = this.keys?.shape[2] ?? 0;
    return steps > 0 ? (this.keys!.nbytes + this.values!.nbytes) / steps : 0;
  }

  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    const prev = this.offset;
    const L = k.shape[2]!;
    if (!this.keys || prev + L > this.keys.shape[2]!) {
      const [B, H, , D] = k.shape as [number, number, number, number];
      const vD = v.shape[3]!;
      const nSteps = Math.floor((KVCache.STEP + L - 1) / KVCache.STEP);
      const newK = ops.zeros([B, H, nSteps * KVCache.STEP, D], k.dtype);
      const newV = ops.zeros([B, H, nSteps * KVCache.STEP, vD], v.dtype);
      if (this.keys && this.values) {
        let oldK = this.keys;
        let oldV = this.values;
        if (prev % KVCache.STEP !== 0) {
          const trimK = oldK.slice([0, 0, 0, 0], [B, H, prev, D]);
          const trimV = oldV.slice([0, 0, 0, 0], [B, H, prev, vD]);
          oldK.dispose();
          oldV.dispose();
          oldK = trimK;
          oldV = trimV;
        }
        this.keys = ops.concatAxis([oldK, newK], 2);
        this.values = ops.concatAxis([oldV, newV], 2);
        for (const a of [oldK, oldV, newK, newV]) a.dispose();
      } else {
        this.keys = newK;
        this.values = newV;
      }
    }

    this.offset += L;
    const [B, H, S, D] = this.keys!.shape as [number, number, number, number];
    const vD = this.values!.shape[3]!;
    const k2 = ops.sliceUpdate(this.keys!, k, [0, 0, prev, 0], [B, H, this.offset, D]);
    const v2 = ops.sliceUpdate(this.values!, v, [0, 0, prev, 0], [B, H, this.offset, vD]);
    this.keys!.dispose();
    this.values!.dispose();
    this.keys = k2;
    this.values = v2;
    return [
      this.keys.slice([0, 0, 0, 0], [B, H, this.offset, D]),
      this.values.slice([0, 0, 0, 0], [B, H, this.offset, vD]),
    ];
  }

  makeMask(N: number, windowSize: number | null): Mask {
    if (N === 1) return { mode: "", arr: null };
    // Windowless multi-token chunks get the STRING "causal" at ANY offset —
    // mlx-lm cache.py:114-125 create_attention_mask does exactly this, and
    // mx.fast SDPA aligns the string bottom-right, i.e. the same values as
    // our materialized matrix. Shipping the array instead (the old
    // offset>0 branch) forced a materialize-and-add mask path: a bool
    // [N, offset+N] built PER CHUNK and read by every full-attention layer
    // — the e4b 16k prefill gap vs mlx-lm (2026-07-06b, hd=512 layers
    // where the fallback dispatch can't block-skip an array mask).
    if (windowSize === null) return { mode: "causal", arr: null };
    if (this.offset === 0 && N <= windowSize) return { mode: "causal", arr: null };
    return { mode: "array", arr: createCausalMask(N, this.offset, windowSize) };
  }

  /** Arrays to eval to materialize cache state (prefill chunk boundary). */
  state(): MlxArray[] {
    return this.keys && this.values ? [this.keys, this.values] : [];
  }

  isTrimmable(): boolean {
    return true;
  }

  trim(n: number): void {
    this.offset = Math.max(0, this.offset - n);
  }

  /** Chronological (K, V) view sliced to offset (drafter donor read). */
  captureDonorRows(): KvDonorRows {
    const [keys, values] = this.temporalView();
    const B = keys.shape[0]!, width = keys.shape[2]!;
    return { keys, values, offsets: Array(B).fill(this.offset),
      starts: Array(B).fill(0), ends: Array(B).fill(width) };
  }

  temporalView(): [MlxArray, MlxArray] {
    if (!this.keys || !this.values) throw new Error("cache is empty");
    const [B, H, , D] = this.keys.shape as [number, number, number, number];
    const vD = this.values.shape[3]!;
    return [
      this.keys.slice([0, 0, 0, 0], [B, H, this.offset, D]),
      this.values.slice([0, 0, 0, 0], [B, H, this.offset, vD]),
    ];
  }

  /** Compiled decode: host-side bookkeeping for a 1-token step — the
   *  growth/trim half of updateAndFetch (L=1), without the write. */
  prepareDecodeStep(): DecodeStepPlan {
    const prev = this.offset;
    if (!this.keys || !this.values) throw new Error("compiled decode on an empty cache");
    if (prev + 1 > this.keys.shape[2]!) {
      const [B, H, , D] = this.keys.shape as [number, number, number, number];
      const vD = this.values.shape[3]!;
      let oldK = this.keys;
      let oldV = this.values;
      if (prev % KVCache.STEP !== 0) {
        const trimK = oldK.slice([0, 0, 0, 0], [B, H, prev, D]);
        const trimV = oldV.slice([0, 0, 0, 0], [B, H, prev, vD]);
        oldK.dispose();
        oldV.dispose();
        oldK = trimK;
        oldV = trimV;
      }
      const newK = ops.zeros([B, H, KVCache.STEP, D], oldK.dtype);
      const newV = ops.zeros([B, H, KVCache.STEP, vD], oldV.dtype);
      this.keys = ops.concatAxis([oldK, newK], 2);
      this.values = ops.concatAxis([oldV, newV], 2);
      for (const a of [oldK, oldV, newK, newV]) a.dispose();
    }
    return { fetch: "concat", writePos: prev, activeLen: prev };
  }

  decodePhase(): DecodeStepPlan["fetch"] { return "concat"; }

  decodeSlot(_plan: DecodeStepPlan): DecodeSlot { return concatDecodeSlot(this.offset); }

  decodeInputs(plan: DecodeStepPlan, step: DecodeStepInputs): MlxArray[] {
    return [step.activeView(this.keys!, plan.activeLen), step.activeView(this.values!, plan.activeLen)];
  }

  commitDecodeStep(_slot: DecodeSlot, outputs: MlxArray[]): MlxArray[] {
    return this.writeDecodeStep(outputs[0]!, outputs[1]!);
  }

  /** Compiled decode: the write half (same sliceUpdate as updateAndFetch).
   *  Takes ownership of kNew/vNew; returns the arrays to async-eval with
   *  the step (the updated buffers). */
  writeDecodeStep(kNew: MlxArray, vNew: MlxArray): MlxArray[] {
    const prev = this.offset;
    const [B, H, , D] = this.keys!.shape as [number, number, number, number];
    const vD = this.values!.shape[3]!;
    const k2 = ops.sliceUpdate(this.keys!, kNew, [0, 0, prev, 0], [B, H, prev + 1, D]);
    const v2 = ops.sliceUpdate(this.values!, vNew, [0, 0, prev, 0], [B, H, prev + 1, vD]);
    this.keys!.dispose();
    this.values!.dispose();
    kNew.dispose();
    vNew.dispose();
    this.keys = k2;
    this.values = v2;
    this.offset = prev + 1;
    return [k2, v2];
  }

  /** Adopt persisted state (takes ownership of the arrays). */
  restoreState(keys: MlxArray, values: MlxArray, offset: number): void {
    this.dispose();
    this.keys = keys;
    this.values = values;
    this.offset = offset;
  }

  /** Port of mlx-lm KVCache.to_quantized: quantize the whole buffer
   *  (padding included — it's overwritten before being read). */
  toQuantized(groupSize: number, bits: number): QuantizedKVCache {
    // Converted caches are not composed yet (B1's quantized lego): unfused, the
    // uniform `--kv-quant N` composition.
    const q = new QuantizedKVCache(groupSize, bits, unfusedAffineKernels(bits, groupSize, this.keys?.dtype ?? Dtype.bfloat16), this.masks);
    q.offset = this.offset;
    if (this.keys && this.values) {
      q.keys = ops.quantize(this.keys, groupSize, bits);
      q.values = ops.quantize(this.values, groupSize, bits);
    }
    this.dispose();
    return q;
  }

  dispose(): void {
    this.keys?.dispose();
    this.values?.dispose();
    this.keys = this.values = null;
    this.offset = 0;
    this.masks.clear();
  }
}

/** The growing plain cache inside a compiled decode trace (also a rotating
 *  cache before its window fills): fetch = concat(active prefix, new row); the
 *  new row is a closure output for the write after the step. `offset` is set for
 *  completeness only: at L=1 every makeMask returns mode "" and the RoPE offset
 *  rides `ropeOffsetArr`, so the baked value cannot leak into the graph. */
class TracedConcatKVCache extends KVCache implements DecodeTrace {
  override readonly ropeOffsetArr: MlxArray;
  outs: MlxArray[] = [];
  constructor(
    offset: number,
    readonly activeK: MlxArray,
    readonly activeV: MlxArray,
    ropeOffsetArr: MlxArray,
  ) {
    super();
    this.offset = offset;
    this.ropeOffsetArr = ropeOffsetArr;
  }

  override updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    // same-shape reshape: an owned alias that survives the caller's
    // dispose of k/v, so the row can be a closure output
    this.outs = [ops.reshape(k, k.shape), ops.reshape(v, v.shape)];
    return [
      ops.concatAxis([this.activeK, k], 2),
      ops.concatAxis([this.activeV, v], 2),
    ];
  }
}

/** The concat-fetch slot of a plain cache at `offset` (KVCache, and RotatingKVCache before the window fills). */
export function concatDecodeSlot(offset: number): DecodeSlot {
  return {
    key: "p-cat:0:0", fetch: "concat", inputs: 2, outputs: 2,
    trace: (inputs, ropeOffset) => new TracedConcatKVCache(offset, inputs[0]!, inputs[1]!, ropeOffset),
  };
}
