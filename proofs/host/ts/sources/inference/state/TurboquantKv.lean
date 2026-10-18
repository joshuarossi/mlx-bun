import host.ts.Source
namespace Host.Ts.Sources.Inference.State.TurboquantKv
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/state/turboquant-kv.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { AttentionRead,BlockAttentionCache,Cache,CommittedAttentionCache,CompiledDecodeCache,DecodeSlot,DecodeStepInputs,DecodeStepPlan,DecodeTrace,KvDonorAttention,KvDonorRows,Mask } from "../contracts/mlx/cache";
import type { RotatedValueAttentionState } from "./kv-storage";
import type { KvCodec } from "../contracts/mlx/kv-codec";
import * as tq from "../kernels/turboquant/ops";
import { TURBOQUANT_HEAD_DIMS } from "../kernels/turboquant/signs";
import { createCausalMask } from "../kernels/attention/masks";
import { decodedKvDonorAttention } from "./decoded-kv-donor";
import type { KVCache } from "./kv";
import type { RotatingKVCache } from "./rotating-kv";
import { TurboQuantCodec,disposeTurboQuant,turboQuantFusedDecode,type TurboQuantTensor } from "./turboquant-codec";
import { AttentionMasks, causalLease, sdpaRead, unmaskedLease } from "./attention-read";
import type { TurboQuantFetches, TurboQuantKernels } from "./turboquant-attention";

/** TurboQuant KV cache (`02d723a:docs/design/turboquant.md`): encoded at rest,
 *  decoded by its named reads with the kernel set the graph composed
 *  (`TurboQuantKernels`). Its own storage class, not a KVCache subclass; its
 *  row layouts are declared in `state/layout`. Only full-attention
 *  (non-rotating) layers use it; sliding-window layers stay bf16.
 *
 *  Storage: 5 arrays per the vllm-metal reference's `turbo_quant_encode`
 *  tuple — kIdx (int8 unpacked at kBits=8, else bit-packed uint8),
 *  kScales/kZeros (fp16, one pair per 32-group), vPacked (bit-packed
 *  uint8, no-op at vBits=8), vScales (fp16, one per 32-group).
 *  updateAndFetch quantizes ONLY the newly appended tokens (unlike
 *  QuantizedKVCache's whole-buffer-toQuantized conversion path — the
 *  streaming append is the whole point of a live cache) and returns the
 *  DEQUANTIZED bf16 active window so ops.sdpa runs unmodified — v1 pays
 *  a full-window dequant every step; the deferred-InvFWHT trick is a
 *  documented non-goal until the quality gate passes.
 *
 *  Reads: each named read appends and attends with the kernel set the cache
 *  was built with (`turboQuantKernels`): decoded values and the stock SDPA
 *  (`denseTurboQuantKernels`, Qwen 3.5's graph) or rotated values, the stock
 *  SDPA and the inverse rotation of its output (`deferredTurboQuantKernels`,
 *  Gemma 4's and MiniCPM5's). No caller sees rotated values. Decode passes no
 *  mask, a window the fused causal mask; at one query the two compute the same
 *  bits. A committed span is the window read: the graphs read TurboQuant
 *  storage the same way whether or not the positions are decided. This cache is
 *  full-attention only, so no read builds a mask array.
 *  Built empty, it encodes from token zero, unlike the served path's
 *  `Bf16FirstTurboQuantKVCache`, so its first chunk's numbers differ.
 *
 *  Compiled decode: a concat slot. The stored prefix is decoded outside the
 *  recorded graph, in the domain the kernel set's read takes
 *  (`TurboQuantKernels.fetch`), with the codec's own decode; inside it the new
 *  position is encoded, decoded from its codes and joined to the prefix, and the
 *  set reads the joined window as the ordinary decode read does. Decoding is per
 *  position and the codec's fused kernel computes the eager decode's arithmetic,
 *  so the joined window equals the window the ordinary read decodes. The codes
 *  leave the graph unpacked; the write after the step packs and stores them. */
export class TurboQuantKVCache implements CommittedAttentionCache, BlockAttentionCache, CompiledDecodeCache {
  minimumReusableOffset = 0;
  readonly stateNeedsDispose = true;
  static readonly STEP = 256;
  /** Set only by compiled-decode trace adapters (see Cache); a real cache
   *  leaves it unset. */
  readonly ropeOffsetArr?: MlxArray;
  #kv: TurboQuantTensor | null = null;
  offset = 0;
  /** Validated lazily on first update, once head_dim is known. */
  #headDim: number | null = null;
  /** Experimental operation selection, captured once for this cache. */
  readonly #codec: KvCodec<TurboQuantTensor>;

  constructor(readonly kBits: number, readonly vBits: number,
    /** How the named reads attend, named by the graph the cache serves; copies,
     * row layouts and extracted rows keep it. */
    readonly turboQuantKernels: TurboQuantKernels,
    readonly fusedDecode = turboQuantFusedDecode(),
    /** The per-forward masks of the model this cache belongs to. Row layouts
     * made from this cache (`state/layout`) share them. */
    readonly masks = new AttentionMasks()) {
    this.#codec = new TurboQuantCodec(kBits, vBits, fusedDecode);
  }

  appendDecode(k: MlxArray, v: MlxArray): AttentionRead {
    return this.turboQuantKernels.read(this.#fetches(k, v), unmaskedLease);
  }

  appendWindow(k: MlxArray, v: MlxArray): AttentionRead {
    return this.turboQuantKernels.read(this.#fetches(k, v), causalLease);
  }

  /** The window read: a committed span on this storage (Qwen 3.5's
   * `appendKnown`) attends with the same call as a window. */
  appendCommitted(k: MlxArray, v: MlxArray): AttentionRead {
    return this.appendWindow(k, v);
  }

  /** A block read (`BlockAttentionCache.readBlock`): the stored positions
   * decoded, then the block's keys and values, not appended, through the stock
   * fused SDPA with no mask (the dense read, whichever kernel set the cache
   * composes, since the block's values are not in the rotated domain). */
  readBlock(k: MlxArray, v: MlxArray): AttentionRead {
    if (!this.#kv || this.#headDim === null) throw new Error("cache is empty");
    const [storedK, storedV] = this.#decode(this.#kv, this.offset, this.#headDim, false);
    let keys: MlxArray, values: MlxArray;
    try {
      keys = ops.concatAxis([storedK, k], 2);
      try { values = ops.concatAxis([storedV, v], 2); }
      catch (error) { keys.dispose(); throw error; }
    } finally { storedK.dispose(); storedV.dispose(); }
    return sdpaRead(keys, values, unmaskedLease);
  }

  /** The appends a kernel set chooses between for `k` and `v`. */
  #fetches(k: MlxArray, v: MlxArray): TurboQuantFetches {
    return {
      decoded: () => this.updateAndFetch(k, v),
      rotated: () => {
        const [keys, values] = this.updateAndFetchDeferredV(k, v);
        return { keys, values, restore: tq.unrotateValues };
      },
    };
  }

  captureDonorRows(): KvDonorRows {
    if (!this.#kv || this.#headDim === null) throw new Error("cache is empty");
    const [keys, values] = this.#decode(this.#kv, this.offset, this.#headDim, false);
    const B = keys.shape[0]!;
    return { keys, values, offsets: Array(B).fill(this.offset),
      starts: Array(B).fill(0), ends: Array(B).fill(this.offset) };
  }
  captureDonorAttention(): KvDonorAttention { return decodedKvDonorAttention(this.captureDonorRows()); }

  get rotatedValueAttention(): RotatedValueAttentionState { return this; }
  signature(): string { return `kv:turboquant:${this.kBits}:${this.vBits}`; }

  bytesPerToken(): number {
    const steps = this.#seqLen();
    if (steps === 0 || !this.#kv) return 0;
    return [
      this.#kv.kIdx, this.#kv.kScales, this.#kv.kZeros,
      this.#kv.vPacked, this.#kv.vScales,
    ].reduce((bytes, array) => bytes + array.nbytes, 0) / steps;
  }

  get headDim(): number | null {
    return this.#headDim;
  }

  #validateHeadDim(dim: number): void {
    if (this.#headDim !== null) return;
    const supported: readonly number[] = TURBOQUANT_HEAD_DIMS;
    if (dim % 32 !== 0 || !supported.includes(dim)) {
      throw new Error(
        `TurboQuantKVCache: head_dim ${dim} must be divisible by 32 and in {${supported.join(",")}}`,
      );
    }
    this.#headDim = dim;
  }

  #packedKDim(dim: number): number {
    return tq.packedDim(dim, this.kBits);
  }
  #packedVDim(dim: number): number {
    return tq.packedDim(dim, this.vBits);
  }
  #nGroups(dim: number): number {
    return dim / tq.TURBOQUANT_BLOCK_SIZE;
  }

  #alloc(B: number, H: number, T: number, dim: number): TurboQuantTensor {
    const kIdxDtype = this.kBits === 8 ? Dtype.int8 : Dtype.uint8;
    return {
      kIdx: ops.zeros([B, H, T, this.#packedKDim(dim)], kIdxDtype),
      kScales: ops.zeros([B, H, T, this.#nGroups(dim)], Dtype.float16),
      kZeros: ops.zeros([B, H, T, this.#nGroups(dim)], Dtype.float16),
      vPacked: ops.zeros([B, H, T, this.#packedVDim(dim)], Dtype.uint8),
      vScales: ops.zeros([B, H, T, this.#nGroups(dim)], Dtype.float16),
    };
  }

  #seqLen(): number {
    return this.#kv ? this.#kv.kIdx.shape[2]! : 0;
  }

  #encode(k: MlxArray, v: MlxArray): TurboQuantTensor { return this.#codec.encode(k, v); }
  #decode(t: TurboQuantTensor, upTo: number, headDim: number, deferV = false): [MlxArray, MlxArray] {
    return this.#codec.decode(t, upTo, headDim, deferV);
  }

  /** Quantize the newly-appended k/v, append into growable packed
   *  storage (256-step growth, mirroring KVCache), advance offset, then
   *  dequantize the WHOLE active window (v1 semantics) so the standard
   *  ops.sdpa path runs unmodified. */
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    const D = this.#append(k, v);
    return this.#decode(this.#kv!, this.offset, D);
  }

  /** Deferred-inverse-FWHT read path: same append, but the returned V
   *  window stays in the ROTATED domain. The caller MUST un-rotate its
   *  attention output with tq.unrotateValues (see SharedKv.vRotated) —
   *  same decode by linearity, O(q·d log d) per step instead of
   *  O(T·d log d). Opt-in per attention site; sites that don't know about
   *  rotation keep calling updateAndFetch and stay correct. */
  updateAndFetchDeferredV(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    const D = this.#append(k, v);
    return this.#decode(this.#kv!, this.offset, D, true);
  }

  /** Shared append: grow storage, encode the new tokens, slice-write them
   *  at the previous offset, advance offset. Returns head_dim. */
  #append(k: MlxArray, v: MlxArray): number {
    const [B, H, L, D] = k.shape as [number, number, number, number];
    this.#validateHeadDim(D);
    const prev = this.offset;
    this.#reserve(B, H, L, D);

    this.offset += L;
    this.#write(this.#encode(k, v), prev);
    return D;
  }

  /** Room for `L` more positions: 256-step growth, mirroring KVCache. */
  #reserve(B: number, H: number, L: number, D: number): void {
    const prev = this.offset;
    if (!this.#kv || prev + L > this.#seqLen()) {
      const nSteps = Math.floor((TurboQuantKVCache.STEP + L - 1) / TurboQuantKVCache.STEP);
      const newSteps = nSteps * TurboQuantKVCache.STEP;
      if (this.#kv && prev % TurboQuantKVCache.STEP !== 0) {
        const trimTo = (t: TurboQuantTensor): TurboQuantTensor => {
          const cut = (a: MlxArray): MlxArray => {
            const [b, h, , d] = a.shape as [number, number, number, number];
            const s = a.slice([0, 0, 0, 0], [b, h, prev, d]);
            a.dispose();
            return s;
          };
          return { kIdx: cut(t.kIdx), kScales: cut(t.kScales), kZeros: cut(t.kZeros),
            vPacked: cut(t.vPacked), vScales: cut(t.vScales) };
        };
        this.#kv = trimTo(this.#kv);
      }
      const grown = this.#alloc(B, H, newSteps, D);
      if (this.#kv) {
        const cat = (a: MlxArray, b: MlxArray): MlxArray => {
          const out = ops.concatAxis([a, b], 2);
          a.dispose();
          b.dispose();
          return out;
        };
        this.#kv = {
          kIdx: cat(this.#kv.kIdx, grown.kIdx),
          kScales: cat(this.#kv.kScales, grown.kScales),
          kZeros: cat(this.#kv.kZeros, grown.kZeros),
          vPacked: cat(this.#kv.vPacked, grown.vPacked),
          vScales: cat(this.#kv.vScales, grown.vScales),
        };
      } else {
        this.#kv = grown;
      }
    }
  }

  /** Write encoded positions (taking ownership) at `prev`, up to the offset. */
  #write(enc: TurboQuantTensor, prev: number): void {
    const write = (dst: MlxArray, src: MlxArray): MlxArray => {
      const [b, h, , d] = dst.shape as [number, number, number, number];
      const u = ops.sliceUpdate(dst, src, [0, 0, prev, 0], [b, h, this.offset, d]);
      dst.dispose();
      src.dispose();
      return u;
    };
    this.#kv = {
      kIdx: write(this.#kv!.kIdx, enc.kIdx),
      kScales: write(this.#kv!.kScales, enc.kScales),
      kZeros: write(this.#kv!.kZeros, enc.kZeros),
      vPacked: write(this.#kv!.vPacked, enc.vPacked),
      vScales: write(this.#kv!.vScales, enc.vScales),
    };
  }

  /** Compiled decode: the growth half of a one-position append, without the write. */
  prepareDecodeStep(): DecodeStepPlan {
    if (!this.#kv || this.#headDim === null) throw new Error("compiled decode on an empty cache");
    const [B, H] = this.#kv.kIdx.shape as [number, number];
    this.#reserve(B, H, 1, this.#headDim);
    return { fetch: "concat", writePos: this.offset, activeLen: this.offset };
  }

  decodePhase(): DecodeStepPlan["fetch"] { return "concat"; }

  decodeSlot(_plan: DecodeStepPlan): DecodeSlot {
    return turboQuantDecodeSlot(this.offset, this.kBits, this.vBits, this.turboQuantKernels);
  }

  /** The stored prefix, decoded as the kernel set's read decodes it (owned by the step). */
  decodeInputs(plan: DecodeStepPlan, step: DecodeStepInputs): MlxArray[] {
    const [keys, values] = this.#decode(this.#kv!, plan.activeLen, this.#headDim!, this.turboQuantKernels.fetch === "rotated");
    return [step.own(keys), step.own(values)];
  }

  /** The write half: pack the step's codes as the codec packs them and store
   *  them at the offset. Takes ownership of `outputs`; returns the storage to
   *  evaluate with the step. */
  commitDecodeStep(_slot: DecodeSlot, outputs: MlxArray[]): MlxArray[] {
    const [kCodes, kScales, kZeros, vCodes, vScales] = outputs as [MlxArray, MlxArray, MlxArray, MlxArray, MlxArray];
    const kIdx = this.kBits < 8 ? tq.packBits(kCodes, this.kBits) : kCodes;
    if (kIdx !== kCodes) kCodes.dispose();
    const vPacked = this.vBits < 8 ? tq.packBits(vCodes, this.vBits) : vCodes;
    if (vPacked !== vCodes) vCodes.dispose();
    const prev = this.offset;
    this.offset = prev + 1;
    this.#write({ kIdx, kScales, kZeros, vPacked, vScales }, prev);
    const kv = this.#kv!;
    return [kv.kIdx, kv.kScales, kv.kZeros, kv.vPacked, kv.vScales];
  }

  /** Same rule as KVCache/QuantizedKVCache.makeMask (mlx-lm cache.py:114-125):
   *  windowless multi-token chunks are the string "causal" at any offset —
   *  TurboQuant v1 is full-attention-only, never windowed. */
  makeMask(N: number, windowSize: number | null): Mask {
    if (N === 1) return { mode: "", arr: null };
    if (windowSize === null) return { mode: "causal", arr: null };
    if (this.offset === 0 && N <= windowSize) return { mode: "causal", arr: null };
    return { mode: "array", arr: createCausalMask(N, this.offset, windowSize) };
  }

  /** Trimmed-to-offset arrays in documented order: kIdx, kScales, kZeros,
   *  vPacked, vScales (packages/inference/src/state/persistence.ts tensor-slot ordering for kind
   *  "turboquant"). Empty cache → []. */
  state(): MlxArray[] {
    if (!this.#kv) return [];
    const cut = (a: MlxArray): MlxArray => {
      const [B, H, , D] = a.shape as [number, number, number, number];
      return a.slice([0, 0, 0, 0], [B, H, this.offset, D]);
    };
    return [cut(this.#kv.kIdx), cut(this.#kv.kScales), cut(this.#kv.kZeros),
      cut(this.#kv.vPacked), cut(this.#kv.vScales)];
  }

  isTrimmable(): boolean {
    return true;
  }

  /** Drop the last n tokens (byte-safe: groups run along head_dim, so a
   *  token-axis slice never splits a group). Same front/back convention
   *  as KVCache.trim: offset shrinks, storage is overwritten on next write. */
  trim(n: number): void {
    this.offset = Math.max(0, this.offset - n);
  }

  /** Adopt persisted/converted state (takes ownership of the arrays). */
  restoreState(t: TurboQuantTensor, offset: number, headDim: number): void {
    this.dispose();
    this.#kv = t;
    this.offset = offset;
    this.#headDim = headDim;
  }

  /** Convert an existing bf16 KVCache/RotatingKVCache's live window in one
   *  shot: quantize the whole [.., :offset, :] region, preserve offset,
   *  dispose the source's arrays. Mirrors KVCache.toQuantized/
   *  RotatingKVCache.toQuantized's contract (source cache is consumed).
   *  `kernels` is the converted cache's read: for a graph's KVCache, the read
   *  the graph composed into it (`KVCache.turboQuantKernels`). `fusedDecode` is
   *  the converted cache's decode policy; a caller that has resolved it passes
   *  it, the default reads the runtime configuration. */
  static fromKVCache(cache: KVCache | RotatingKVCache, kBits: number, vBits: number, kernels: TurboQuantKernels,
    fusedDecode = turboQuantFusedDecode()): TurboQuantKVCache {
    const q = new TurboQuantKVCache(kBits, vBits, kernels, fusedDecode);
    const [k, v] = cache.keys && cache.values ? cache.temporalView() : [null, null];
    if (k && v) {
      const D = k.shape[3]!;
      q.#validateHeadDim(D);
      const enc = q.#encode(k, v);
      k.dispose();
      v.dispose();
      q.#kv = enc;
      q.#headDim = D;
    }
    q.offset = cache.offset;
    q.minimumReusableOffset = (cache as Cache).minimumReusableOffset ?? 0;
    cache.dispose();
    return q;
  }

  dispose(): void {
    if (this.#kv) disposeTurboQuant(this.#kv);
    this.#kv = null;
    this.offset = 0;
    this.minimumReusableOffset = 0;
    this.masks.clear();
  }
}

/** A TurboQuant cache inside a compiled decode trace: the new position is
 *  encoded and decoded from its codes in the graph, joined to the prefix the
 *  cache decoded outside it, and read by the cache's kernel set; the five codes
 *  (indices unpacked) are the closure outputs. */
class TracedTurboQuantKVCache implements DecodeTrace {
  outs: MlxArray[] = [];
  constructor(
    readonly offset: number,
    readonly kBits: number,
    readonly vBits: number,
    readonly kernels: TurboQuantKernels,
    readonly prefixKeys: MlxArray,
    readonly prefixValues: MlxArray,
    readonly ropeOffsetArr: MlxArray,
  ) {}

  appendDecode(k: MlxArray, v: MlxArray): AttentionRead {
    const kEnc = tq.encodeKeys(k, this.kBits, this.kBits === 8);
    const vEnc = tq.encodeValues(v, this.vBits);
    this.outs = [kEnc.indices, kEnc.scales, kEnc.zeros, vEnc.indices, vEnc.scales];
    const rotated = this.kernels.fetch === "rotated";
    const join = (prefix: MlxArray, row: MlxArray): MlxArray => {
      try { return ops.concatAxis([prefix, row], 2); } finally { row.dispose(); }
    };
    const keys = join(this.prefixKeys, tq.decodeKeys(kEnc.indices, kEnc.scales, kEnc.zeros));
    let values: MlxArray;
    try {
      values = join(this.prefixValues, rotated ? tq.decodeValuesRotated(vEnc.indices, vEnc.scales, this.vBits)
        : tq.decodeValues(vEnc.indices, vEnc.scales, this.vBits));
    } catch (error) { keys.dispose(); throw error; }
    return this.kernels.read({
      decoded: () => [keys, values],
      rotated: () => ({ keys, values, restore: tq.unrotateValues }),
    }, unmaskedLease);
  }

  signature(): string { return `kv:turboquant-trace:${this.kBits}:${this.vBits}`; }
  state(): MlxArray[] { return []; }
  isTrimmable(): boolean { return false; }
  trim(): void { throw new Error("a compiled decode trace is not trimmed"); }
  dispose(): void {}
}

/** The concat slot of a TurboQuant cache at `offset` whose reads take `kernels`.
 *  The kernel set is part of the graph shape: a dense and a deferred set trace
 *  different reads. */
export function turboQuantDecodeSlot(offset: number, kBits: number, vBits: number, kernels: TurboQuantKernels): DecodeSlot {
  return {
    key: `tq-cat:${kBits}:${vBits}:${kernels.fetch}`, fetch: "concat", inputs: 2, outputs: 5,
    trace: (inputs, ropeOffset) => new TracedTurboQuantKVCache(offset, kBits, vBits, kernels, inputs[0]!, inputs[1]!, ropeOffset),
  };
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.State.TurboquantKv
