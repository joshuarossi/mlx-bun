import metal.Elab
import metal.Frontend
import metal.Assemble
import host.mlx.PrefillKernelSources
import metal.kernels.GateUp

namespace Metal.Kernels.AffineSplitMma
open Metal Metal.Core

/-! # affine-split-mma.ts: `mlx_bun_affine_split_mma`

The header function the body calls (through `AFFINE_UNIT`, inlined below; its slots are listed
under `body`):

```
template <uint B>
inline float affine_unit(uint lo, uint hi, uint v) {
  const uint bit = v * B, off = bit & 31u;
  const uint top = 23u - B;
  uint u = off <= top ? lo << (top - off) : lo >> (off - top);
  if (off + B > 32u) u |= hi << (top + 32u - off);
  return as_type<float>((u & (((1u << B) - 1u) << top)) | 0x3f800000u);
}
#define AFFINE_UNIT(q, v) affine_unit<BITS>((q)[((v) * BITS) >> 5], (q)[metal::min((((v) * BITS) >> 5) + 1u, 2u * BITS - 1u)], (v))
```
The body:

```
const uint lane = thread_index_in_simdgroup;
const uint sg = simdgroup_index_in_threadgroup;
const uint fm = ((lane / 4u) & 4u) + ((lane / 2u) % 4u);
const uint fn = ((lane / 4u) & 2u) * 2u + (lane % 2u) * 2u;
const uint M = (uint)x_shape[0];
const uint n0 = threadgroup_position_in_grid.y * 8u * (uint)TILES;
const uint m0 = threadgroup_position_in_grid.z * 8u;
const uint groups = (uint)K / 64u;
const uint groupWords = 2u * (uint)BITS;
const device T* x0 = x + (ulong)metal::min(m0 + fn, M - 1u) * (ulong)K + fm * 32u;
const device T* x1 = x + (ulong)metal::min(m0 + fn + 1u, M - 1u) * (ulong)K + fm * 32u;
const device uint32_t* wRow[TILES];
metal::simdgroup_float8x8 acc[TILES];
#pragma clang loop unroll(full)
for (uint t = 0; t < (uint)TILES; ++t) {
  wRow[t] = (const device uint32_t*)w + (ulong)(n0 + 8u * t + fm) * groups * groupWords;
  acc[t] = metal::make_filled_simdgroup_matrix<float, 8, 8>(0.0f);
}
for (uint step = sg; step < (uint)K / 256u; step += (uint)SPLITS) {
  const uint base = step * 256u;
  const uint g = step * 4u + fn / 2u;
  uint q[TILES][2 * BITS];
  float s2[TILES], b2[TILES];
  #pragma clang loop unroll(full)
  for (uint t = 0; t < (uint)TILES; ++t) {
    const ulong at = (ulong)(n0 + 8u * t + fm) * groups + g;
    s2[t] = float(scales[at]) * (float)(1u << (uint)BITS);
    b2[t] = float(biases[at]) - s2[t];
    #pragma clang loop unroll(full)
    for (uint i = 0; i < groupWords; ++i) q[t][i] = wRow[t][g * groupWords + i];
  }
  const device metal::vec<T, 4>* xa = (const device metal::vec<T, 4>*)(x0 + base);
  const device metal::vec<T, 4>* xb = (const device metal::vec<T, 4>*)(x1 + base);
  #pragma clang loop unroll(full)
  for (uint s4 = 0; s4 < 8u; ++s4) {
    const float4 va = float4(xa[s4]);
    const float4 vb = float4(xb[s4]);
    #pragma clang loop unroll(full)
    for (uint c = 0; c < 4u; ++c) {
      const uint v = s4 * 4u + c;
      metal::simdgroup_float8x8 bx;
      bx.thread_elements()[0] = va[c];
      bx.thread_elements()[1] = vb[c];
      #pragma clang loop unroll(full)
      for (uint t = 0; t < (uint)TILES; ++t) {
        metal::simdgroup_float8x8 a;
        a.thread_elements()[0] = metal::fma(AFFINE_UNIT(q[t], v), s2[t], b2[t]);
        a.thread_elements()[1] = metal::fma(AFFINE_UNIT(q[t], v + 32u), s2[t], b2[t]);
        metal::simdgroup_multiply_accumulate(acc[t], a, bx, acc[t]);
      }
    }
  }
}
// Add the K splits: element (fm, fn | fn + 1) of each tile, then thread e of
// the threadgroup writes C element e of its tile, columns below M only.
threadgroup float part[SPLITS][TILES][64];
#pragma clang loop unroll(full)
for (uint t = 0; t < (uint)TILES; ++t) {
  part[sg][t][fm * 8u + fn] = acc[t].thread_elements()[0];
  part[sg][t][fm * 8u + fn + 1u] = acc[t].thread_elements()[1];
}
threadgroup_barrier(metal::mem_flags::mem_threadgroup);
for (uint e = sg * 32u + lane; e < 64u * (uint)TILES; e += 32u * (uint)SPLITS) {
  const uint t = e / 64u, r = (e % 64u) / 8u, m = e % 8u;
  if (m0 + m >= M) continue;
  float sum = 0.0f;
  for (uint s = 0; s < (uint)SPLITS; ++s) sum += part[s][t][r * 8u + m];
  y[(ulong)(m0 + m) * (ulong)N + n0 + 8u * t + r] = T(sum);
}
```
Launch (affine-split-mma.ts:128-140): inputs `x` bfloat16 `[M, K]` (M any; the row count is read from
`x_shape`), `w` uint32 `[N, K·BITS/32]`, `scales` and `biases` bfloat16 `[N, K/64]`, output `y`
bfloat16 `[M, N]`; grid `[32·SPLITS, N/(8·TILES), ⌈M/8⌉]`, threadgroup `[32·SPLITS, 1, 1]`; `T` = bfloat16,
template ints N, K, BITS, TILES, SPLITS, the last two by `affineSplitMmaPlan` (:116-118): TILES 2, SPLITS 2
for N ≥ 2048, else TILES 1, SPLITS 8. The route's instances are the `AffineMma` projections of the
4-to-223-row and chunk forwards (qwen38-27b-trellis-m1max.ts `#mma`, `#mmaFive`, `#wide`): the DeltaNet
in_proj_qkv (K 5120, N 10240) and in_proj_z (K 5120, N 6144) at 3 and 4 bits, in_proj_a/in_proj_b (K 5120,
N 48, 4 bits), out_proj (K 6144, N 5120, 3 and 4 bits), and the attention q_proj (K 5120, N 12288),
k_proj/v_proj (K 5120, N 1024) and o_proj (K 6144, N 5120), all 4 bits. The core is
`core N K bits tiles splits`. -/

def u32l (n : Nat) : CExpr := .lit (.int .u32 n)
def u64l (n : Nat) : CExpr := .lit (.int .u64 n)
def u16l (n : Nat) : CExpr := .lit (.int .u16 n)
def i32l (n : Nat) : CExpr := .lit (.int .i32 n)
def f32l (bits : Nat) : CExpr := .lit (.f32 (Val.ofF32Bits bits))

def u32 (op : Core.BinOp) (a b : CExpr) : CExpr := .bin op .u32 0 a b
def u64 (op : Core.BinOp) (a b : CExpr) : CExpr := .bin op .u64 0 a b
def toU64 (e : CExpr) : CExpr := .conv .u64 e

/-- `i = 0; i < n; ++i` over slot `i`. -/
def forU (i : Nat) (n : CExpr) (body : List CStmt) : List CStmt :=
  [.set i (u32l 0), .loop (u32 .lt (.local i) n) [.set i (u32 .add (.local i) (u32l 1))] body]

/-- binary32 bits of 2^b (b < 128). -/
def pow2Bits (b : Nat) : Nat := (127 + b) * 2 ^ 23

/-- `a[u]` of the thread array in slot `a` with rows of `stride` elements. -/
def row (a : Nat) (u : CExpr) (stride : Nat) : CExpr := .offset (.local a) (u64 .mul (toU64 u) (u64l stride))

/-! ## `affine_unit<BITS>` -/

/-- `affine_unit(lo, hi, v)` (lo, hi, v in slots `b - 2`, `b - 1`, `b`): slots `b + 1` the result, `b + 2` bit,
`b + 3` off, `b + 4` top, `b + 5` u. -/
def affineUnit (bits b : Nat) : CStmt :=
  .scope
    [.set (b + 2) (u32 .mul (.local b) (u32l bits)),
     .set (b + 3) (u32 .bitAnd (.local (b + 2)) (u32l 31)),
     .set (b + 4) (u32l (23 - bits)),
     .set (b + 5) (.cond (u32 .le (.local (b + 3)) (.local (b + 4)))
       (u32 .shl (.local (b - 2)) (u32 .sub (.local (b + 4)) (.local (b + 3))))
       (u32 .shr (.local (b - 2)) (u32 .sub (.local (b + 3)) (.local (b + 4))))),
     .ite (u32 .gt (u32 .add (.local (b + 3)) (u32l bits)) (u32l 32))
       [.set (b + 5) (u32 .bitOr (.local (b + 5))
         (u32 .shl (.local (b - 1)) (u32 .sub (u32 .add (.local (b + 4)) (u32l 32)) (.local (b + 3)))))] [],
     .set (b + 1) (.bitcast .f32 (u32 .bitOr (u32 .bitAnd (.local (b + 5)) (u32 .shl (u32l (2 ^ bits - 1)) (.local (b + 4))))
       (u32l 0x3F800000))),
     .leave]

/-- `AFFINE_UNIT(q[t], v)` for the value index `v` (an expression over slot 35), lo/hi/v in slots
`b - 2`, `b - 1`, `b`, then `affine_unit`, and element `k` of `a` (thread array in slot 38) set to
`fma(unit, s2[t], b2[t])`. -/
def unitElement (bits b k : Nat) (v : CExpr) : List CStmt :=
  let word : CExpr := u32 .shr (u32 .mul v (u32l bits)) (u32l 5)
  [.set (b - 2) (.load (.scalar .u32) (.offset (row 23 (.local 37) (2 * bits)) word)),
   .set (b - 1) (.load (.scalar .u32) (.offset (row 23 (.local 37) (2 * bits))
     (.bin .min .u32 0 (u32 .add word (u32l 1)) (u32l (2 * bits - 1))))),
   .set b v,
   affineUnit bits b,
   .store (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (.local 38)) (i32l k))
     (.fma (.local (b + 1)) (.load (.scalar .f32) (.offset (.local 24) (.local 37)))
       (.load (.scalar .f32) (.offset (.local 25) (.local 37))))]

/-! ## The K steps -/

/-- Tile `t` (slot 37) of value `v`: `a` (thread array 6, slot 38), its two elements, and
`acc[t] = a · bx + acc[t]` (collective into slot 55). -/
def tileBody (bits : Nat) : List CStmt :=
  [.array 38 false 6 (.vec .f32 2)] ++
  unitElement bits 41 0 (.local 35) ++
  unitElement bits 49 1 (u32 .add (.local 35) (u32l 32)) ++
  [.collective 1 55 (.mma .f32 .f32) .f32
     (.vector .f32 [.load (.vec .f32 2) (.local 38), .load (.vec .f32 2) (.local 36),
       .load (.vec .f32 2) (.offset (.local 18) (.local 37))]) (u16l 0),
   .store (.vec .f32 2) (.offset (.local 18) (.local 37)) (.local 55)]

/-- Column `c` (slot 34) of chunk `s4`: `v`, `bx` (thread array 5, slot 36) from `va[c]`, `vb[c]`, the tiles. -/
def columnBody (bits tiles : Nat) : List CStmt :=
  [.set 35 (u32 .add (u32 .mul (.local 31) (u32l 4)) (.local 34)),
   .array 36 false 5 (.vec .f32 2),
   .store (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (.local 36)) (i32l 0)) (.component (.local 32) (.local 34)),
   .store (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (.local 36)) (i32l 1)) (.component (.local 33) (.local 34))] ++
  forU 37 (u32l tiles) (tileBody bits)

/-- Tile `t` (slot 26) of a step's scales: `at`, `s2[t]`, `b2[t]`, `q[t][…]` from `wRow[t]`. -/
def scaleBody (bits : Nat) : List CStmt :=
  [.set 27 (u64 .add (u64 .mul (toU64 (u32 .add (u32 .add (.local 11) (u32 .mul (u32l 8) (.local 26))) (.local 8)))
     (toU64 (.local 13))) (toU64 (.local 22))),
   .store (.scalar .f32) (.offset (.local 24) (.local 26))
     (.bin .mul .f32 0 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 3) (.local 27)))) (f32l (pow2Bits bits))),
   .store (.scalar .f32) (.offset (.local 25) (.local 26))
     (.bin .sub .f32 0 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 4) (.local 27))))
       (.load (.scalar .f32) (.offset (.local 24) (.local 26))))] ++
  forU 28 (.local 14)
    [.store (.scalar .u32) (.offset (row 23 (.local 26) (2 * bits)) (.local 28))
      (.load (.scalar .u32) (.offset (.load (.ptr .device (.scalar .u32)) (.offset (.local 17) (.local 26)))
        (u32 .add (u32 .mul (.local 22) (.local 14)) (.local 28))))]

/-- K step `step` (slot 20): `base`, `g`, `q`, `s2`, `b2` (thread arrays 2-4), the scales, `xa`, `xb`, the
eight chunks. -/
def stepBody (bits tiles : Nat) : List CStmt :=
  [.set 21 (u32 .mul (.local 20) (u32l 256)),
   .set 22 (u32 .add (u32 .mul (.local 20) (u32l 4)) (u32 .div (.local 9) (u32l 2))),
   .array 23 false 2 (.scalar .u32),
   .array 24 false 3 (.scalar .f32),
   .array 25 false 4 (.scalar .f32)] ++
  forU 26 (u32l tiles) (scaleBody bits) ++
  [.set 29 (.ptrCast (.vec .bf16 4) (.offset (.local 15) (.local 21))),
   .set 30 (.ptrCast (.vec .bf16 4) (.offset (.local 16) (.local 21)))] ++
  forU 31 (u32l 8)
    ([.set 32 (.conv .f32 (.load (.vec .bf16 4) (.offset (.local 29) (.local 31)))),
      .set 33 (.conv .f32 (.load (.vec .bf16 4) (.offset (.local 30) (.local 31))))] ++
     forU 34 (u32l 4) (columnBody bits tiles))

/-! ## The split sum -/

/-- `part[s][t][i]` of the threadgroup array in slot 56. -/
def partAt (tiles : Nat) (s t i : CExpr) : CExpr :=
  .offset (.offset (.offset (.local 56) (u64 .mul (toU64 s) (u64l (64 * tiles)))) (u64 .mul (toU64 t) (u64l 64))) i

/-- Element `k` of the tile `t` (slot 57) of `acc`. -/
def accElement (k : Nat) : CExpr := .load (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (.offset (.local 18) (.local 57))) (i32l k))

/-- Output `e` (slot 58): `t`, `r`, `m`, skipped past `M`, the sum over the splits, `y[(m0 + m)·N + n0 + 8t + r]`. -/
def outBody (N tiles splits : Nat) : List CStmt :=
  [.set 59 (u32 .div (.local 58) (u32l 64)),
   .set 60 (u32 .div (u32 .rem (.local 58) (u32l 64)) (u32l 8)),
   .set 61 (u32 .rem (.local 58) (u32l 8)),
   .ite (u32 .ge (u32 .add (.local 12) (.local 61)) (.local 10)) [.continue_] [],
   .set 62 (f32l 0x0)] ++
  forU 63 (u32l splits)
    [.set 62 (.bin .add .f32 0 (.local 62) (.load (.scalar .f32)
      (partAt tiles (.local 63) (.local 59) (u32 .add (u32 .mul (.local 60) (u32l 8)) (.local 61)))))] ++
  [.store (.scalar .bf16)
    (.offset (.local 5) (u64 .add (u64 .add (u64 .add (u64 .mul (toU64 (u32 .add (.local 12) (.local 61))) (u64l N))
      (toU64 (.local 11))) (toU64 (u32 .mul (u32l 8) (.local 59)))) (toU64 (.local 60))))
    (.conv .bf16 (.local 62))]

/-- `x + min(m0 + fn + k, M - 1)·K + fm·32`. -/
def xRow (K : Nat) (k : Nat) : CExpr :=
  let col : CExpr := if k = 0 then u32 .add (.local 12) (.local 9) else u32 .add (u32 .add (.local 12) (.local 9)) (u32l k)
  .offset (.offset (.local 0) (u64 .mul (toU64 (.bin .min .u32 0 col (u32 .sub (.local 10) (u32l 1)))) (u64l K)))
    (u32 .mul (.local 8) (u32l 32))

/-- Slots: 0 x, 1 x_shape, 2 w, 3 scales, 4 biases, 5 y, 6 lane, 7 sg, 8 fm, 9 fn, 10 M, 11 n0, 12 m0,
13 groups, 14 groupWords, 15 x0, 16 x1, 17 wRow (thread array 0), 18 acc (thread array 1), 19 t, 20 step,
21 base, 22 g, 23 q (thread array 2), 24 s2 (thread array 3), 25 b2 (thread array 4), 26 t, 27 at, 28 i,
29 xa, 30 xb, 31 s4, 32 va, 33 vb, 34 c, 35 v, 36 bx (thread array 5), 37 t, 38 a (thread array 6), then
the two `AFFINE_UNIT`s: 39 lo, 40 hi, 41 v, 42 … 46 `affine_unit`'s (`affineUnit`), 47 lo, 48 hi, 49 v,
50 … 54; 55 the `simdgroup_multiply_accumulate` result, 56 part (threadgroup array 0), 57 t, 58 e, 59 t,
60 r, 61 m, 62 sum, 63 s. -/
def body (N K bits tiles splits : Nat) : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .bf16⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .i32⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .u32⟩)),
   .set 3 (.lit (.ptr ⟨3, 0, .scalar .bf16⟩)),
   .set 4 (.lit (.ptr ⟨4, 0, .scalar .bf16⟩)),
   .set 5 (.lit (.ptr ⟨5, 0, .scalar .bf16⟩)),
   .set 6 (.coord .threadIndexInSimdgroup),
   .set 7 (.coord .simdgroupIndexInThreadgroup),
   .set 8 (u32 .add (u32 .bitAnd (u32 .div (.local 6) (u32l 4)) (u32l 4)) (u32 .rem (u32 .div (.local 6) (u32l 2)) (u32l 4))),
   .set 9 (u32 .add (u32 .mul (u32 .bitAnd (u32 .div (.local 6) (u32l 4)) (u32l 2)) (u32l 2))
     (u32 .mul (u32 .rem (.local 6) (u32l 2)) (u32l 2))),
   .set 10 (.conv .u32 (.load (.scalar .i32) (.offset (.local 1) (i32l 0)))),
   .set 11 (u32 .mul (u32 .mul (.component (.coord .threadgroupPositionInGrid) (u32l 1)) (u32l 8)) (u32l tiles)),
   .set 12 (u32 .mul (.component (.coord .threadgroupPositionInGrid) (u32l 2)) (u32l 8)),
   .set 13 (u32l (K / 64)),
   .set 14 (u32l (2 * bits)),
   .set 15 (xRow K 0),
   .set 16 (xRow K 1),
   .array 17 false 0 (.ptr .device (.scalar .u32)),
   .array 18 false 1 (.vec .f32 2)] ++
  forU 19 (u32l tiles)
    [.store (.ptr .device (.scalar .u32)) (.offset (.local 17) (.local 19))
       (.offset (.local 2) (u64 .mul (u64 .mul (toU64 (u32 .add (u32 .add (.local 11) (u32 .mul (u32l 8) (.local 19))) (.local 8)))
         (toU64 (.local 13))) (toU64 (.local 14)))),
     .store (.vec .f32 2) (.offset (.local 18) (.local 19)) (.vector .f32 [f32l 0x0, f32l 0x0])] ++
  [.set 20 (.local 7),
   .loop (u32 .lt (.local 20) (u32l (K / 256))) [.set 20 (u32 .add (.local 20) (u32l splits))] (stepBody bits tiles),
   .array 56 true 0 (.scalar .f32)] ++
  forU 57 (u32l tiles)
    [.store (.scalar .f32) (partAt tiles (.local 7) (.local 57) (u32 .add (u32 .mul (.local 8) (u32l 8)) (.local 9)))
       (accElement 0),
     .store (.scalar .f32) (partAt tiles (.local 7) (.local 57) (u32 .add (u32 .add (u32 .mul (.local 8) (u32l 8)) (.local 9)) (u32l 1)))
       (accElement 1)] ++
  [.barrier 2 false true,
   .set 58 (u32 .add (u32 .mul (.local 7) (u32l 32)) (.local 6)),
   .loop (u32 .lt (.local 58) (u32l (64 * tiles))) [.set 58 (u32 .add (.local 58) (u32l (32 * splits)))]
     (outBody N tiles splits)]

/-- Threadgroup array `part[SPLITS][TILES][64]`; thread arrays `wRow[TILES]`, `acc[TILES]`,
`q[TILES][2·BITS]`, `s2[TILES]`, `b2[TILES]`, `bx`, `a`. -/
def core (N K bits tiles splits : Nat) : Kernel :=
  ⟨6, [(.scalar .f32, splits * tiles * 64)],
    [(.ptr .device (.scalar .u32), tiles), (.vec .f32 2, tiles), (.scalar .u32, tiles * (2 * bits)),
      (.scalar .f32, tiles), (.scalar .f32, tiles), (.vec .f32 2, 1), (.vec .f32 2, 1)],
    body N K bits tiles splits⟩

section Texts
open Host.Mlx
/-! ## The texts MLX compiles

`x` `[9, K]`: the text does not depend on the row count (read from `x_shape`); any shapes of at least 8
elements give the same text. -/

def inputs (N K bits : Nat) : List Assemble.Input :=
  [⟨chars!"x", .bfloat16, [9, K]⟩, ⟨chars!"w", .uint32, [N, K * bits / 32]⟩, ⟨chars!"scales", .bfloat16, [N, K / 64]⟩,
    ⟨chars!"biases", .bfloat16, [N, K / 64]⟩]

def args (N K bits tiles splits : Nat) : List Assemble.TemplateArg :=
  [.dtype chars!"T" .bfloat16, .int chars!"N" N, .int chars!"K" K, .int chars!"BITS" bits, .int chars!"TILES" tiles,
    .int chars!"SPLITS" splits]

def assembled (N K bits tiles splits : Nat) : Option (List Char) :=
  Assemble.assemble (PrefillSources.name .affineSplitMma) (inputs N K bits) [chars!"y"] [.bfloat16]
    (PrefillSources.source .affineSplitMma) (PrefillSources.header .affineSplitMma) (args N K bits tiles splits) false

def text (N K bits tiles splits : Nat) : List Char := (assembled N K bits tiles splits).getD []

/-- Every route instance assembles. -/
theorem assembled_route :
    (assembled 10240 5120 3 2 2).isSome ∧ (assembled 10240 5120 4 2 2).isSome ∧
    (assembled 6144 5120 3 2 2).isSome ∧ (assembled 6144 5120 4 2 2).isSome ∧ (assembled 48 5120 4 1 8).isSome ∧
    (assembled 5120 6144 3 2 2).isSome ∧ (assembled 5120 6144 4 2 2).isSome ∧
    (assembled 12288 5120 4 2 2).isSome ∧ (assembled 1024 5120 4 1 8).isSome := by
  decide +kernel

kernel_rfl compile_10240_5120_3 : (frontend (text 10240 5120 3 2 2)).bind elaborate = some (core 10240 5120 3 2 2)
kernel_rfl compile_10240_5120_4 : (frontend (text 10240 5120 4 2 2)).bind elaborate = some (core 10240 5120 4 2 2)
kernel_rfl compile_6144_5120_3 : (frontend (text 6144 5120 3 2 2)).bind elaborate = some (core 6144 5120 3 2 2)
kernel_rfl compile_6144_5120_4 : (frontend (text 6144 5120 4 2 2)).bind elaborate = some (core 6144 5120 4 2 2)
kernel_rfl compile_48_5120_4 : (frontend (text 48 5120 4 1 8)).bind elaborate = some (core 48 5120 4 1 8)
kernel_rfl compile_5120_6144_3 : (frontend (text 5120 6144 3 2 2)).bind elaborate = some (core 5120 6144 3 2 2)
kernel_rfl compile_5120_6144_4 : (frontend (text 5120 6144 4 2 2)).bind elaborate = some (core 5120 6144 4 2 2)
kernel_rfl compile_12288_5120_4 : (frontend (text 12288 5120 4 2 2)).bind elaborate = some (core 12288 5120 4 2 2)
kernel_rfl compile_1024_5120_4 : (frontend (text 1024 5120 4 1 8)).bind elaborate = some (core 1024 5120 4 1 8)

end Texts
end Metal.Kernels.AffineSplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

section Unit
variable (C : M1Max.Contract) {ctx : Ctx}

/-- The last two statements of `affine_unit`: the mask, the exponent of 1.0f, and `leave`. -/
theorem exec_unitFin (bits b : Nat) (hbits : bits = 3 ∨ bits = 4) {l : Locals} {sh : Shared} {u' : Nat}
    (h5 : l (b + 5) = some (u32 u')) (hu' : u' < 2 ^ 32) (h4 : l (b + 4) = some (u32 (23 - bits))) :
    Exec C ctx [.set (b + 1) (.bitcast .f32 (AffineSplitMma.u32 .bitOr (AffineSplitMma.u32 .bitAnd (.local (b + 5))
        (AffineSplitMma.u32 .shl (u32l (2 ^ bits - 1)) (.local (b + 4)))) (u32l 0x3F800000))), .leave] l sh .leave
      (setLocal l (b + 1) (.f32 (Val.ofF32Bits (0x3F800000 + u' / 2 ^ (23 - bits) % 2 ^ bits * 2 ^ (23 - bits))))) sh := by
  have hB : bits ≤ 4 := by omega
  have hmask : (2 ^ bits - 1) * 2 ^ (23 - bits) < 2 ^ 23 := by
    rcases hbits with rfl | rfl <;> norm_num
  have hq : u' / 2 ^ (23 - bits) % 2 ^ bits * 2 ^ (23 - bits) < 2 ^ 23 := by
    have h1 : u' / 2 ^ (23 - bits) % 2 ^ bits < 2 ^ bits := Nat.mod_lt _ (Nat.two_pow_pos _)
    have h2 : 2 ^ bits * 2 ^ (23 - bits) = 2 ^ 23 := by rw [← Nat.pow_add]; congr 1; omega
    calc u' / 2 ^ (23 - bits) % 2 ^ bits * 2 ^ (23 - bits) < 2 ^ bits * 2 ^ (23 - bits) :=
          Nat.mul_lt_mul_of_pos_right h1 (Nat.two_pow_pos _)
      _ = 2 ^ 23 := h2
  have hshl := eval_bin_u32 C (ctx := ctx) (l := l) (sh := sh) (op := .shl) (site := 0)
    (eval_u32lit C l sh (2 ^ bits - 1) (by rcases hbits with rfl | rfl <;> norm_num)) (eval_local' C h4 sh)
    (binary_shl_u32 C (2 ^ bits - 1) (23 - bits) (by omega))
  have hand := eval_bin_u32 C (op := .bitAnd) (site := 0) (eval_local' C h5 sh) hshl
    (binary_bitAnd_u32 C u' _ hu' (by omega))
  rw [and_mask_shift] at hand
  have hor := eval_bin_u32 C (op := .bitOr) (site := 0) hand (eval_u32lit C l sh 0x3F800000 (by norm_num))
    (binary_bitOr_u32 C _ 0x3F800000 (by omega) (by norm_num))
  rw [or_one _ _ hq] at hor
  exact .set (eval_bitcast C hor (bitcast_f32_u32 _ (by omega))) .leave

end Unit
end Metal.Kernels.SplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

section Unit2
variable (C : M1Max.Contract) {ctx : Ctx}

/-- `affine_unit<BITS>(lo, hi, v)` (`lo`, `hi`, `v` in slots `b - 2`, `b - 1`, `b`) on the words of a group
(`lo` word `v·BITS / 32`, `hi` the next, capped at the last): slot `b + 1` gets `1 + q/2^BITS` for the field `q`
at bit `v·BITS` of the group. -/
theorem exec_affineUnit (bits b : Nat) (hbits : bits = 3 ∨ bits = 4) (hb : 2 ≤ b) {Wd : Nat → Nat}
    (hW : ∀ i < 2 * bits, Wd i < 2 ^ 32) {v : Nat} (hv : v < 64) {l : Locals} {sh : Shared}
    (hlo : l (b - 2) = some (u32 (Wd (v * bits / 32))))
    (hhi : l (b - 1) = some (u32 (Wd (min (v * bits / 32 + 1) (2 * bits - 1)))))
    (hvl : l b = some (u32 v)) :
    ∃ l', (∀ j, j < b + 1 ∨ b + 5 < j → l' j = l j) ∧
      l' (b + 1) = some (.f32 (Val.ofF32Bits (0x3F800000 +
        runBits Wd (2 * bits) / 2 ^ (v * bits) % 2 ^ bits * 2 ^ (23 - bits)))) ∧
      ∀ {ss : List CStmt} {o : Outcome} {lf : Locals} {shf : Shared}, Exec C ctx ss l' sh o lf shf →
        Exec C ctx (affineUnit bits b :: ss) l sh o lf shf := by
  have hB : bits ≤ 4 := by omega
  have hB3 : 3 ≤ bits := by omega
  have hvb : v * bits + bits ≤ 64 * bits := by
    have := Nat.mul_le_mul_right bits (show v + 1 ≤ 64 by omega); rw [Nat.add_mul, Nat.one_mul] at this; exact this
  have hmul := binary_mul_u32 C v bits
  generalize hV : v * bits = vb at hlo hhi hvb hmul ⊢
  obtain ⟨off, hoff⟩ : ∃ off, vb % 32 = off := ⟨_, rfl⟩
  obtain ⟨w, hw⟩ : ∃ w, vb / 32 = w := ⟨_, rfl⟩
  rw [hw] at hlo hhi
  have hvbw : vb = 32 * w + off := by omega
  have hw2 : w < 2 * bits := by omega
  have hlo32 := hW w hw2
  have hoff32 : off < 32 := by omega
  have e1 : (eval C ctx l (AffineSplitMma.u32 .mul (.local b) (u32l bits))).run sh = some (u32 vb, sh) :=
    eval_bin_u32 C (eval_local' C hvl sh) (eval_u32lit C l sh bits (by omega)) hmul
  have h12 : setLocal l (b + 2) (u32 vb) (b + 2) = some (u32 vb) := setLocal_same _ _ _
  have hand := binary_bitAnd_u32 C vb 31 (by omega) (by norm_num)
  rw [show vb &&& 31 = off by rw [show (31 : Nat) = 2 ^ 5 - 1 by norm_num, Nat.and_two_pow_sub_one_eq_mod]; omega]
    at hand
  have e2 := eval_bin_u32 C (ctx := ctx) (op := .bitAnd) (site := 0) (eval_local' C h12 sh)
    (eval_u32lit C _ sh 31 (by norm_num)) hand
  generalize hl3 : setLocal (setLocal (setLocal l (b + 2) (u32 vb)) (b + 3) (u32 off)) (b + 4) (u32 (23 - bits)) = l3
  have h33 : l3 (b + 3) = some (u32 off) := by rw [← hl3, setLocal_other _ _ (by omega), setLocal_same]
  have h34 : l3 (b + 4) = some (u32 (23 - bits)) := by rw [← hl3, setLocal_same]
  have h3lo : l3 (b - 2) = some (u32 (Wd w)) := by
    rw [← hl3, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), hlo]
  have h3hi : l3 (b - 1) = some (u32 (Wd (min (w + 1) (2 * bits - 1)))) := by
    rw [← hl3, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), hhi]
  have h3ag : ∀ j, j < b + 1 ∨ b + 5 < j → l3 j = l j := by
    intro j hj
    rw [← hl3, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
  have hpre : ∀ {ss' : List CStmt} {o' : Outcome} {l' : Locals} {sh' : Shared}, Exec C ctx ss' l3 sh o' l' sh' →
      Exec C ctx (.set (b + 2) (AffineSplitMma.u32 .mul (.local b) (u32l bits)) ::
        .set (b + 3) (AffineSplitMma.u32 .bitAnd (.local (b + 2)) (u32l 31)) ::
        .set (b + 4) (u32l (23 - bits)) :: ss') l sh o' l' sh' := by
    intro ss' o' l' sh' h
    rw [← hl3] at h
    exact .set e1 (.set e2 (.set (eval_u32lit C _ sh (23 - bits) (by omega)) h))
  -- `u`, then the high word for a field across two words
  have key : ∃ l5 u', Exec C ctx
      [.set (b + 5) (.cond (AffineSplitMma.u32 .le (.local (b + 3)) (.local (b + 4)))
         (AffineSplitMma.u32 .shl (.local (b - 2)) (AffineSplitMma.u32 .sub (.local (b + 4)) (.local (b + 3))))
         (AffineSplitMma.u32 .shr (.local (b - 2)) (AffineSplitMma.u32 .sub (.local (b + 3)) (.local (b + 4))))),
       .ite (AffineSplitMma.u32 .gt (AffineSplitMma.u32 .add (.local (b + 3)) (u32l bits)) (u32l 32))
         [.set (b + 5) (AffineSplitMma.u32 .bitOr (.local (b + 5))
           (AffineSplitMma.u32 .shl (.local (b - 1))
             (AffineSplitMma.u32 .sub (AffineSplitMma.u32 .add (.local (b + 4)) (u32l 32)) (.local (b + 3)))))] []]
      l3 sh .normal l5 sh ∧ (∀ j, j ≠ b + 5 → l5 j = l3 j) ∧ l5 (b + 5) = some (u32 u') ∧ u' < 2 ^ 32 ∧
      u' / 2 ^ (23 - bits) % 2 ^ bits = runBits Wd (2 * bits) / 2 ^ vb % 2 ^ bits := by
    have hadd := eval_bin_u32 C (ctx := ctx) (op := .add) (site := 0) (l := l3) (eval_local' C h33 sh)
      (eval_u32lit C _ sh bits (by omega)) (binary_add_u32 C off bits)
    have hgt := eval_bin_u32 C (op := .gt) (site := 0) hadd (eval_u32lit C _ sh 32 (by norm_num))
      (binary_gt_u32 C (off + bits) 32 (by omega) (by norm_num))
    have hle := eval_bin_u32 C (ctx := ctx) (op := .le) (site := 0) (l := l3) (eval_local' C h33 sh)
      (eval_local' C h34 sh) (binary_le_u32 C off (23 - bits) (by omega) (by omega))
    by_cases hA : off ≤ 23 - bits
    · rw [decide_eq_true hA] at hle
      rw [decide_eq_false (by omega)] at hgt
      have hsub := eval_bin_u32 C (ctx := ctx) (op := .sub) (site := 0) (l := l3) (eval_local' C h34 sh)
        (eval_local' C h33 sh) (binary_sub_u32 C (23 - bits) off hA)
      have hshl := eval_bin_u32 C (op := .shl) (site := 0) (eval_local' C h3lo sh) hsub
        (binary_shl_u32 C (Wd w) (23 - bits - off) (by omega))
      rw [← u32_mod] at hshl
      refine ⟨_, Wd w * 2 ^ (23 - bits - off) % 2 ^ 32, .set (eval_cond C hle hshl) (.ite (v := false) ?_ (.nil _ _) (.nil _ _)),
        fun j hj => setLocal_other _ _ hj, setLocal_same _ _ _, Nat.mod_lt _ (by norm_num), ?_⟩
      · exact (eval_bin_u32 C (op := .gt) (site := 0) (eval_bin_u32 C (op := .add) (site := 0)
          (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact h33) sh) (eval_u32lit C _ sh bits (by omega))
          (binary_add_u32 C off bits)) (eval_u32lit C _ sh 32 (by norm_num))
          (binary_gt_u32 C (off + bits) 32 (by omega) (by norm_num))).trans (by rw [decide_eq_false (by omega)])
      · rw [field_shl _ _ _ _ hA (by omega), hvbw, runBits_field hW hw2 (by omega)]
    · rw [decide_eq_false hA] at hle
      have hgtX : ∀ X, (eval C ctx (setLocal l3 (b + 5) X)
          (AffineSplitMma.u32 .gt (AffineSplitMma.u32 .add (.local (b + 3)) (u32l bits)) (u32l 32))).run sh =
          some (.bool (decide (32 < off + bits)), sh) := fun X =>
        eval_bin_u32 C (op := .gt) (site := 0) (eval_bin_u32 C (op := .add) (site := 0)
          (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact h33) sh) (eval_u32lit C _ sh bits (by omega))
          (binary_add_u32 C off bits)) (eval_u32lit C _ sh 32 (by norm_num))
          (binary_gt_u32 C (off + bits) 32 (by omega) (by norm_num))
      have hsub := eval_bin_u32 C (ctx := ctx) (op := .sub) (site := 0) (l := l3) (eval_local' C h33 sh)
        (eval_local' C h34 sh) (binary_sub_u32 C off (23 - bits) (by omega))
      have hshr := eval_bin_u32 C (op := .shr) (site := 0) (eval_local' C h3lo sh) hsub
        (binary_shr_u32 C (Wd w) (off - (23 - bits)) hlo32 (by omega))
      have hu : Wd w / 2 ^ (off - (23 - bits)) < 2 ^ 32 := lt_of_le_of_lt (Nat.div_le_self _ _) hlo32
      by_cases hC : 32 < off + bits
      · have hw1 : w + 1 < 2 * bits := by omega
        generalize hl4 : setLocal l3 (b + 5) (u32 (Wd w / 2 ^ (off - (23 - bits)))) = l4
        have h45 : l4 (b + 5) = some (u32 (Wd w / 2 ^ (off - (23 - bits)))) := by rw [← hl4, setLocal_same]
        have h44 : l4 (b + 4) = some (u32 (23 - bits)) := by rw [← hl4, setLocal_other _ _ (by omega)]; exact h34
        have h43 : l4 (b + 3) = some (u32 off) := by rw [← hl4, setLocal_other _ _ (by omega)]; exact h33
        have h4hi : l4 (b - 1) = some (u32 (Wd (w + 1))) := by
          rw [← hl4, setLocal_other _ _ (by omega), h3hi, Nat.min_eq_left (by omega)]
        have hadd2 := eval_bin_u32 C (ctx := ctx) (op := .add) (site := 0) (eval_local' C h44 sh)
          (eval_u32lit C _ sh 32 (by norm_num)) (binary_add_u32 C (23 - bits) 32)
        have hsub2 := eval_bin_u32 C (op := .sub) (site := 0) hadd2 (eval_local' C h43 sh)
          (binary_sub_u32 C (23 - bits + 32) off (by omega))
        have hshl2 := eval_bin_u32 C (op := .shl) (site := 0) (eval_local' C h4hi sh) hsub2
          (binary_shl_u32 C (Wd (w + 1)) (23 - bits + 32 - off) (by omega))
        rw [← u32_mod] at hshl2
        have hor := eval_bin_u32 C (op := .bitOr) (site := 0) (eval_local' C h45 sh) hshl2
          (binary_bitOr_u32 C _ _ hu (Nat.mod_lt _ (by norm_num)))
        refine ⟨_, Wd w / 2 ^ (off - (23 - bits)) ||| Wd (w + 1) * 2 ^ (23 - bits + 32 - off) % 2 ^ 32,
          .set (eval_cond C hle hshr) (.ite (v := true) ((hgtX _).trans (by rw [decide_eq_true hC]))
            (by rw [hl4]; exact .set hor (.nil _ _)) (.nil _ _)),
          fun j hj => by rw [setLocal_other _ _ hj, ← hl4, setLocal_other _ _ hj], setLocal_same _ _ _,
          Nat.or_lt_two_pow hu (Nat.mod_lt _ (by norm_num)), ?_⟩
        rw [field_straddle _ _ _ _ _ hlo32 (by omega) hoff32 (by omega), hvbw,
          runBits_field2 hW hw1 hoff32 (by omega)]
      · refine ⟨_, Wd w / 2 ^ (off - (23 - bits)), .set (eval_cond C hle hshr)
          (.ite (v := false) ((hgtX _).trans (by rw [decide_eq_false hC])) (.nil _ _) (.nil _ _)),
          fun j hj => setLocal_other _ _ hj, setLocal_same _ _ _, hu, ?_⟩
        rw [field_shr _ _ _ _ (by omega), hvbw, runBits_field hW hw2 (by omega)]
  obtain ⟨l5, u', hex, hag, h5, hu', hq⟩ := key
  have h54 : l5 (b + 4) = some (u32 (23 - bits)) := by rw [hag _ (by omega)]; exact h34
  refine ⟨setLocal l5 (b + 1) (.f32 (Val.ofF32Bits (0x3F800000 + u' / 2 ^ (23 - bits) % 2 ^ bits * 2 ^ (23 - bits)))),
    fun j hj => ?_, ?_, fun h => .scope (hpre (hex.append (exec_unitFin C bits b hbits h5 hu' h54))) (.inr rfl) h⟩
  · rw [setLocal_other _ _ (by omega), hag _ (by omega), h3ag j hj]
  · rw [setLocal_same, hq]

end Unit2
end Metal.Kernels.SplitMma

namespace Metal.Kernels.AffineSplitMma
open Metal Metal.Core Inference.Contracts.Mlx

/-! ## Expected outputs

The quantities of the source on the inputs' elements, with the operations the core applies. The core's products
feed `fma`s or `simdgroup_multiply_accumulate`, or are not added, so the compiler's contraction choices do not
enter. The matrix product is the contract's `simdMma` on the SIMD-group's registers: each lane's two
`thread_elements()` of `a`, `bx` and `acc[t]`. -/

/-- The template ints `N`, `K`, `BITS`, `TILES`, `SPLITS` and the row count `M = x_shape[0]`. -/
structure Dims where
  N : Nat
  K : Nat
  bits : Nat
  tiles : Nat
  splits : Nat
  r : Nat

/-- The inputs' contents: `x`, `w`, `scales`, `biases`. -/
structure In where
  X : ByteMemory.Bytes
  W : ByteMemory.Bytes
  S : ByteMemory.Bytes
  B : ByteMemory.Bytes

section Spec
variable (C : M1Max.Contract) (D : Dims) (I : In)

def zero : Float32 := Val.ofF32Bits 0

/-- Element `i` of a bfloat16 array. -/
def bf (X : ByteMemory.Bytes) (i : Nat) : BF := Val.ofBf16Bits (bytesWord (cells X (2 * i) 2))

/-- Word `i` of a uint32 array. -/
def word (W : ByteMemory.Bytes) (i : Nat) : Nat := bytesWord (cells W (4 * i) 4)

/-- A lane's `fm` (its row of `a`, its 32-column block of `x`) and `fn` (its first column of `bx`). -/
def fmOf (lane : Nat) : Nat := (lane / 4 &&& 4) + lane / 2 % 4
def fnOf (lane : Nat) : Nat := (lane / 4 &&& 2) * 2 + lane % 2 * 2

/-- `(float)(1u << BITS)`. -/
def pow2 (bits : Nat) : Float32 := Val.ofF32Bits (pow2Bits bits)

/-- Group `g` of weight row `n` (`at`): its scale and bias, and its `2·BITS` words from word `at·2·BITS`. -/
def gidx (n g : Nat) : Nat := n * (D.K / 64) + g

/-- `s2 = float(scales[at]) * (float)(1u << BITS)`. -/
def s2v (n g : Nat) : Float32 := C.fmul (C.widen (bf I.S (gidx D n g))) (pow2 D.bits)

/-- `b2 = float(biases[at]) - s2`. -/
def b2v (n g : Nat) : Float32 := C.fadd (C.widen (bf I.B (gidx D n g))) (f32Neg (s2v C D I n g))

/-- Value `v` of the group: the `BITS`-bit field at bit `v·BITS` of its words (MLX's LSB-first packing). -/
def field (n g v : Nat) : Nat :=
  runBits (fun i => word I.W (gidx D n g * (2 * D.bits) + i)) (2 * D.bits) / 2 ^ (v * D.bits) % 2 ^ D.bits

/-- `affine_unit`: `1 + q/2^BITS`, the field `q` in the top mantissa bits of `1.0f`. -/
def unit (n g v : Nat) : Float32 := Val.ofF32Bits (0x3F800000 + field D I n g v * 2 ^ (23 - D.bits))

/-- The dequantized weight `fma(AFFINE_UNIT(q, v), s2, b2)`. -/
def weight (n g v : Nat) : Float32 := C.fma (unit D I n g v) (s2v C D I n g) (b2v C D I n g)

/-- Threadgroups along the grid's y: `N / (8·TILES)`. -/
def gy : Nat := D.N / (8 * D.tiles)

/-- K step `k` of SIMD-group `s`: `step = s + k·SPLITS`. -/
def stepOf (s k : Nat) : Nat := s + D.splits * k

/-- `a` of tile `t` at value `v` of SIMD-group `s`'s K step `k` in threadgroup column block `nb`: lane `l`'s
element `j` is the weight of row `n0 + 8t + fm`, group `4·step + fn/2`, value `v + 32j`. -/
def aRegs (nb s t k v : Nat) : Fin 32 → Fin 2 → Float32 := fun l j =>
  weight C D I (8 * D.tiles * nb + 8 * t + fmOf l) (4 * stepOf D s k + fnOf l / 2) (v + 32 * j)

/-- `bx` at value `v` of SIMD-group `s`'s K step `k` in row block `mb`: lane `l`'s element `j` is
`x[min(m0 + fn + j, M - 1)][32·fm + 256·step + v]`. -/
def bRegs (mb s k v : Nat) : Fin 32 → Fin 2 → Float32 := fun l j =>
  C.widen (bf I.X (min (8 * mb + fnOf l + j) (D.r - 1) * D.K + 32 * fmOf l + 256 * stepOf D s k + v))

/-- `acc[t]` of SIMD-group `s` after its first `p` multiply-accumulates (value `p % 32` of K step `p / 32`). -/
def accAt (nb mb s t : Nat) : Nat → Fin 32 → Fin 2 → Float32
  | 0 => fun _ _ => zero
  | p + 1 => C.simdMma (aRegs C D I nb s t (p / 32) (p % 32)) (bRegs C D I mb s (p / 32) (p % 32))
      (accAt nb mb s t p)

/-- The K steps of SIMD-group `s`: `step = s, s + SPLITS, … < K / 256`. -/
def nsteps (s : Nat) : Nat := (D.K / 256 - s + D.splits - 1) / D.splits

/-- The lane whose element `e % 2` is `C` element `e = 8·fm + fn + (e % 2)` of a tile. -/
def laneOf (e : Nat) : Fin 32 :=
  ⟨16 * (e / 32 % 2) + 8 * (e / 4 % 2) + 4 * (e / 16 % 2) + 2 * (e / 8 % 2) + e / 2 % 2, by omega⟩

/-- `part[s][t][e]`: element `e` of tile `t` of SIMD-group `s` after its K steps. -/
def part (nb mb s t e : Nat) : Float32 :=
  accAt C D I nb mb s t (32 * nsteps D s) (laneOf e) ⟨e % 2, Nat.mod_lt _ (by decide)⟩

/-- `float sum = 0.0f; for (s = 0; s < n; ++s) sum += f s;` -/
def splitSum (f : Nat → Float32) : Nat → Float32
  | 0 => zero
  | s + 1 => C.fadd (splitSum f s) (f s)

/-- `y[i][n] = T(sum)` over the splits of element `8·(n % 8) + i % 8` of tile `n % (8·TILES) / 8` of threadgroup
`(·, n / (8·TILES), i / 8)`. -/
def yv (i n : Nat) : BF :=
  C.narrow (splitSum C (fun s => part C D I (n / (8 * D.tiles)) (i / 8) s (n % (8 * D.tiles) / 8)
    (8 * (n % 8) + i % 8)) D.splits)

/-- Byte `b` of `y` `[M, N]` bfloat16. -/
def yBytes (b : Nat) : BitVec 8 :=
  if b < 2 * (D.r * D.N) then (wordBytes 2 (Val.bf16Bits (yv C D I (b / 2 / D.N) (b / 2 % D.N)))).getD (b % 2) 0
  else 0

end Spec

/-- MLX's `x_shape` buffer for `x` `[r, K]`: the two `int`s. -/
def shapeBytes (r K : Nat) : ByteMemory.Bytes := fun b => (wordBytes 4 r ++ wordBytes 4 K).getD b 0

/-- The output `y` of `x` `[r, K]`, `w`, `scales`, `biases` at `N`, `K`, `BITS`, `TILES`, `SPLITS`. -/
def expected (C : M1Max.Contract) (N K bits tiles splits r : Nat) (X W S B : ByteMemory.Bytes) : ByteMemory.Bytes :=
  yBytes C ⟨N, K, bits, tiles, splits, r⟩ ⟨X, W, S, B⟩

end Metal.Kernels.AffineSplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

/-! ## The launch -/

/-- The input buffers' base alignments: `x`, `x_shape`, `w`, `scales`, `biases`. -/
structure Al where
  x : Nat
  h : Nat
  w : Nat
  s : Nat
  b : Nat

/-- The input buffers: `x` `[r, K]`, its shape, `w` `[N, K·BITS/32]`, `scales` and `biases` `[N, K/64]`. -/
def bufs (D : Dims) (I : In) (A : Al) : List Buffer :=
  [⟨.device, 2 * (D.r * D.K), A.x, I.X⟩, ⟨.constant, 8, A.h, shapeBytes D.r D.K⟩,
   ⟨.device, 4 * (D.N * (D.K * D.bits / 32)), A.w, I.W⟩, ⟨.device, 2 * (D.N * (D.K / 64)), A.s, I.S⟩,
   ⟨.device, 2 * (D.N * (D.K / 64)), A.b, I.B⟩]

/-- Threadgroups along the grid's z: `⌈M / 8⌉`. -/
def gz (D : Dims) : Nat := (D.r + 7) / 8

/-- MLX's launch: grid `[32·SPLITS, N/(8·TILES), ⌈M/8⌉]`, threadgroup `[32·SPLITS, 1, 1]`, `y` `[M, N]` bfloat16. -/
def launch (D : Dims) (I : In) (A : Al) (initial : Nat → ByteMemory.Bytes) : Launch :=
  ⟨core D.N D.K D.bits D.tiles D.splits, (32 * D.splits, gy D, gz D), (32 * D.splits, 1, 1),
    buffers (bufs D I A) [2 * (D.r * D.N)] 16 initial⟩

/-- Dimensions the proof covers. -/
structure Ok (D : Dims) : Prop where
  bits : D.bits = 3 ∨ D.bits = 4
  K : D.K % 256 = 0
  Kle : D.K < 2 ^ 16
  N : D.N % (8 * D.tiles) = 0
  Npos : 0 < D.N
  Nle : D.N < 2 ^ 16
  tiles : 0 < D.tiles
  splits : 0 < D.splits
  splitsK : D.splits ≤ D.K / 256
  r : 0 < D.r
  rle : D.r < 2 ^ 31

/-- Thread array `j` of thread `th`. -/
def ta (th j : Nat) : Nat := 7 + th * 7 + j

/-- The regions as the kernel uses them. -/
structure Shape (L : Launch) (D : Dims) (A : Al) : Prop where
  r0 : L.regions 0 = some ⟨.device, 2 * (D.r * D.K), A.x⟩
  r1 : L.regions 1 = some ⟨.constant, 8, A.h⟩
  r2 : L.regions 2 = some ⟨.device, 4 * (D.N * (D.K * D.bits / 32)), A.w⟩
  r3 : L.regions 3 = some ⟨.device, 2 * (D.N * (D.K / 64)), A.s⟩
  r4 : L.regions 4 = some ⟨.device, 2 * (D.N * (D.K / 64)), A.b⟩
  r5 : L.regions 5 = some ⟨.device, 2 * (D.r * D.N), 16⟩
  r6 : L.regions 6 = some ⟨.threadgroup, 4 * (D.splits * D.tiles * 64), 4⟩
  t0 : ∀ th, L.regions (ta th 0) = some ⟨.thread, 8 * D.tiles, 8⟩
  t1 : ∀ th, L.regions (ta th 1) = some ⟨.thread, 8 * D.tiles, 8⟩
  t2 : ∀ th, L.regions (ta th 2) = some ⟨.thread, 4 * (D.tiles * (2 * D.bits)), 4⟩
  t3 : ∀ th, L.regions (ta th 3) = some ⟨.thread, 4 * D.tiles, 4⟩
  t4 : ∀ th, L.regions (ta th 4) = some ⟨.thread, 4 * D.tiles, 4⟩
  t5 : ∀ th, L.regions (ta th 5) = some ⟨.thread, 8, 8⟩
  t6 : ∀ th, L.regions (ta th 6) = some ⟨.thread, 8, 8⟩
  ax : A.x % 8 = 0
  ah : A.h % 4 = 0
  aw : A.w % 4 = 0
  as : A.s % 2 = 0
  ab : A.b % 2 = 0

theorem launch_buffers {D : Dims} {I : In} {A : Al} {initial : Nat → ByteMemory.Bytes} :
    (launch D I A initial).buffers = buffers (bufs D I A) [2 * (D.r * D.N)] 16 initial := rfl

theorem launch_shape {D : Dims} {I : In} {A : Al} {initial : Nat → ByteMemory.Bytes} (hax : A.x % 8 = 0)
    (hah : A.h % 4 = 0) (haw : A.w % 4 = 0) (has : A.s % 2 = 0) (hab : A.b % 2 = 0) :
    Shape (launch D I A initial) D A := by
  have hb := launch_buffers (D := D) (I := I) (A := A) (initial := initial)
  have ht : ∀ th j t n, (launch D I A initial).kernel.threadArrays[j]? = some (t, n) →
      (launch D I A initial).regions (ta th j) = some ⟨.thread, t.bytes * n, alignment t⟩ :=
    fun th j t n h => Launch.regions_threadArray _ th j t n h
  refine ⟨regions_input hb 0 (by simp [bufs]), regions_input hb 1 (by simp [bufs]),
    regions_input hb 2 (by simp [bufs]), regions_input hb 3 (by simp [bufs]), regions_input hb 4 (by simp [bufs]),
    regions_output hb 0 (by simp), ?_, fun th => ?_, fun th => ?_, fun th => ?_, fun th => ?_, fun th => ?_,
    fun th => ?_, fun th => ?_, hax, hah, haw, has, hab⟩
  · have := Launch.regions_groupArray (launch D I A initial) 0 (.scalar .f32) (D.splits * D.tiles * 64) rfl
    simpa [Ty.bytes, Scalar.bytes, alignment, bufs, launch_buffers, buffers] using this
  · have := ht th 0 (.ptr .device (.scalar .u32)) D.tiles rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 1 (.vec .f32 2) D.tiles rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 2 (.scalar .u32) (D.tiles * (2 * D.bits)) rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 3 (.scalar .f32) D.tiles rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 4 (.scalar .f32) D.tiles rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 5 (.vec .f32 2) 1 rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 6 (.vec .f32 2) 1 rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this

end Metal.Kernels.SplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

/-! ## Who writes what -/

/-- The threadgroup of output `y[i][n]`: `(·, n / (8·TILES), i / 8)`, linearly. -/
def grp (D : Dims) (i n : Nat) : Nat := n / (8 * D.tiles) + i / 8 * gy D

/-- The output loop's `e` of `y[i][n]` in its threadgroup: tile `t`, row `r`, column `m` as `64t + 8r + m`. -/
def eloc (D : Dims) (i n : Nat) : Nat := 64 * (n % (8 * D.tiles) / 8) + 8 * (n % 8) + i % 8

/-- The order outputs are written in: by threadgroup, thread (`e % (32·SPLITS)`), then iteration. -/
def key (D : Dims) (i n : Nat) : Nat :=
  (grp D i n * (32 * D.splits) + eloc D i n % (32 * D.splits)) * (64 * D.tiles) + eloc D i n / (32 * D.splits)

/-- The writer of `y` element `idx`. -/
def ywriter (D : Dims) (idx : Nat) : Writer :=
  ⟨grp D (idx / D.N) (idx % D.N) * (32 * D.splits) + eloc D (idx / D.N) (idx % D.N) % (32 * D.splits),
    grp D (idx / D.N) (idx % D.N), 0⟩

def dev (D : Dims) (region byte : Nat) : Option Writer := if region = 5 then some (ywriter D (byte / 2)) else none

/-- Before threadgroup `g`'s barrier (epoch `g`) `part[s][t][e]` is lane `laneOf e`'s of SIMD-group `s`; after
it nothing is written. -/
def tgo (D : Dims) (g ep region byte : Nat) : Option Nat :=
  if ep = g ∧ region = 6 then
    some (g * (32 * D.splits) + 32 * (byte / 4 / (64 * D.tiles)) + (laneOf (byte / 4 % 64)).val)
  else none

theorem eloc_lt (D : Dims) (ht : 0 < D.tiles) (i n : Nat) : eloc D i n < 64 * D.tiles := by
  have h1 : n % (8 * D.tiles) / 8 < D.tiles :=
    (Nat.div_lt_iff_lt_mul (by decide)).mpr (by rw [Nat.mul_comm]; exact Nat.mod_lt _ (by omega))
  unfold eloc; omega

theorem grp_lt (D : Dims) (ho : D.N % (8 * D.tiles) = 0) {i n : Nat} (hi : i < D.r) (hn : n < D.N) :
    grp D i n < gy D * gz D := by
  have h1 : n / (8 * D.tiles) < gy D := by
    unfold gy; exact Nat.div_lt_div_of_lt_of_dvd (Nat.dvd_of_mod_eq_zero ho) hn
  have h2 : i / 8 < gz D := by unfold gz; omega
  unfold grp
  calc n / (8 * D.tiles) + i / 8 * gy D < gy D + i / 8 * gy D := by omega
    _ = (i / 8 + 1) * gy D := by ring
    _ ≤ gz D * gy D := Nat.mul_le_mul_right _ h2
    _ = gy D * gz D := Nat.mul_comm _ _

theorem key_lt (D : Dims) (ho : D.N % (8 * D.tiles) = 0) (ht : 0 < D.tiles) (hs : 0 < D.splits) {i n : Nat}
    (hi : i < D.r) (hn : n < D.N) : key D i n < gy D * gz D * (32 * D.splits) * (64 * D.tiles) := by
  have hg := grp_lt D ho hi hn
  have he := eloc_lt D ht i n
  have h1 : eloc D i n / (32 * D.splits) < 64 * D.tiles := lt_of_le_of_lt (Nat.div_le_self _ _) he
  have h2 : eloc D i n % (32 * D.splits) < 32 * D.splits := Nat.mod_lt _ (by omega)
  unfold key
  have h3 : grp D i n * (32 * D.splits) + eloc D i n % (32 * D.splits) < gy D * gz D * (32 * D.splits) := by
    calc grp D i n * (32 * D.splits) + eloc D i n % (32 * D.splits) < (grp D i n + 1) * (32 * D.splits) := by
          rw [Nat.add_mul, Nat.one_mul]; omega
      _ ≤ gy D * gz D * (32 * D.splits) := Nat.mul_le_mul_right _ hg
  generalize grp D i n * (32 * D.splits) + eloc D i n % (32 * D.splits) = X at h3 ⊢
  generalize eloc D i n / (32 * D.splits) = Y at h1 ⊢
  calc X * (64 * D.tiles) + Y < (X + 1) * (64 * D.tiles) := by rw [Nat.add_mul, Nat.one_mul]; omega
    _ ≤ gy D * gz D * (32 * D.splits) * (64 * D.tiles) := Nat.mul_le_mul_right _ h3

theorem key_inj (D : Dims) (ho : D.N % (8 * D.tiles) = 0) (ht : 0 < D.tiles) (hs : 0 < D.splits) {i n i' n' : Nat}
    (hn : n < D.N) (hn' : n' < D.N) (h : key D i n = key D i' n') : i = i' ∧ n = n' := by
  have hS : 0 < 32 * D.splits := by omega
  obtain ⟨h1, h2⟩ := idx_inj (lt_of_le_of_lt (Nat.div_le_self _ _) (eloc_lt D ht i n))
    (lt_of_le_of_lt (Nat.div_le_self _ _) (eloc_lt D ht i' n')) h
  obtain ⟨h3, h4⟩ := idx_inj (Nat.mod_lt _ hS) (Nat.mod_lt _ hS) h1
  have he : eloc D i n = eloc D i' n' := eq_of_div_mod h2 h4
  have hgy : ∀ m, m < D.N → m / (8 * D.tiles) < gy D := fun m hm => by
    unfold gy; exact Nat.div_lt_div_of_lt_of_dvd (Nat.dvd_of_mod_eq_zero ho) hm
  obtain ⟨h5, h6⟩ := idx_inj (hgy n hn) (hgy n' hn')
    (by unfold grp at h3; rw [Nat.add_comm, Nat.add_comm (i' / 8 * gy D)]; exact h3)
  unfold eloc at he
  have hm8 : ∀ m, m % (8 * D.tiles) % 8 = m % 8 := fun m => Nat.mod_mod_of_dvd _ (Nat.dvd_mul_right 8 _)
  have e1 : n % (8 * D.tiles) / 8 = n' % (8 * D.tiles) / 8 := by omega
  have e2 : n % 8 = n' % 8 := by omega
  have e3 : n % (8 * D.tiles) = n' % (8 * D.tiles) := eq_of_div_mod (c := 8) e1 (by rw [hm8, hm8, e2])
  exact ⟨eq_of_div_mod (c := 8) h5 (by omega), eq_of_div_mod h6 e3⟩

end Metal.Kernels.SplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

/-! ## Memory -/

section Memory
variable (C : M1Max.Contract)

/-- Memory during the launch: the inputs intact, the epochs (`ge` the threadgroup epoch), the outputs before `P`
in `key` order, the `part` elements with `pw` of threadgroup `(·, nb, mb)`, and every access so far keeping the
ownership discipline. -/
structure Mem (L : Launch) (D : Dims) (I : In) (nb mb P ge : Nat) (pw : Nat → Nat → Nat → Prop) (sh : Shared) :
    Prop where
  regions : sh.regions = L.regions
  x : sh.bytes 0 = I.X
  h : sh.bytes 1 = shapeBytes D.r D.K
  w : sh.bytes 2 = I.W
  s : sh.bytes 3 = I.S
  b : sh.bytes 4 = I.B
  deve : sh.deviceEpoch = 0
  grpe : sh.groupEpoch = ge
  y : ∀ i < D.r, ∀ n < D.N, key D i n < P →
    cells (sh.bytes 5) (2 * (i * D.N + n)) 2 = wordBytes 2 (Val.bf16Bits (yv C D I i n))
  part : ∀ s < D.splits, ∀ t < D.tiles, ∀ e < 64, pw s t e →
    cells (sh.bytes 6) (4 * (s * (64 * D.tiles) + t * 64 + e)) 4 =
      wordBytes 4 (Val.f32Bits (AffineSplitMma.part C D I nb mb s t e))
  log : ∀ a ∈ sh.log, Owned L (dev D) (tgo D) a

variable {C} {L : Launch} {D : Dims} {I : In} {A : Al} {nb mb P ge : Nat} {pw : Nat → Nat → Nat → Prop} {sh : Shared}

theorem Mem.mono (h : Mem C L D I nb mb P ge pw sh) {pw' : Nat → Nat → Nat → Prop}
    (hp : ∀ s t e, pw' s t e → pw s t e) : Mem C L D I nb mb P ge pw' sh :=
  ⟨h.regions, h.x, h.h, h.w, h.s, h.b, h.deve, h.grpe, h.y, fun s hs t ht e he hw => h.part s hs t ht e he (hp s t e hw),
    h.log⟩

/-- A read of an input, or of `part` after the barrier. -/
theorem Mem.rd (h : Mem C L D I nb mb P ge pw sh) (hS : Shape L D A) (ctx : Ctx) (reg o n : Nat)
    (hreg : reg < 5 ∨ (reg = 6 ∧ ge ≠ ctx.group)) : Mem C L D I nb mb P ge pw (rdn ctx sh reg o n) :=
  ⟨h.regions, h.x, h.h, h.w, h.s, h.b, h.deve, h.grpe, h.y, h.part, forall_log _ n _ (fun j _ => by
    rcases hreg with hreg | ⟨rfl, hne⟩
    · obtain ⟨r, hr, hs⟩ : ∃ r, L.regions reg = some r ∧ r.space ≠ .threadgroup := by
        rcases (show reg = 0 ∨ reg = 1 ∨ reg = 2 ∨ reg = 3 ∨ reg = 4 by omega) with rfl | rfl | rfl | rfl | rfl
        exacts [⟨_, hS.r0, by simp⟩, ⟨_, hS.r1, by simp⟩, ⟨_, hS.r2, by simp⟩, ⟨_, hS.r3, by simp⟩,
          ⟨_, hS.r4, by simp⟩]
      exact owned_device_read L (dev D) (tgo D) ctx sh reg (o + j) r hr hs (by simp [dev]; omega)
    · exact owned_group_read L (dev D) (tgo D) ctx sh 6 (o + j) _ hS.r6 rfl (by simp [tgo, h.grpe, hne])) h.log⟩

/-- A write to thread memory. -/
theorem Mem.tput (h : Mem C L D I nb mb P ge pw sh) {reg : Nat} (o : Nat) (bs : List (BitVec 8)) (hreg : 7 ≤ reg) :
    Mem C L D I nb mb P ge pw (Metal.tput sh reg o bs) :=
  ⟨h.regions, by rw [tput_other _ _ _ (by omega)]; exact h.x, by rw [tput_other _ _ _ (by omega)]; exact h.h,
    by rw [tput_other _ _ _ (by omega)]; exact h.w, by rw [tput_other _ _ _ (by omega)]; exact h.s,
    by rw [tput_other _ _ _ (by omega)]; exact h.b, h.deve, h.grpe,
    fun i hi n hn hk => by rw [tput_other _ _ _ (by omega)]; exact h.y i hi n hn hk,
    fun s hs t ht e he hw => by rw [tput_other _ _ _ (by omega)]; exact h.part s hs t ht e he hw, h.log⟩

theorem part_idx_inj {T s t e s' t' e' : Nat} (ht : t < T) (he : e < 64) (ht' : t' < T) (he' : e' < 64)
    (h : s * (64 * T) + t * 64 + e = s' * (64 * T) + t' * 64 + e') : s = s' ∧ t = t' ∧ e = e' := by
  have hte : t * 64 + e < 64 * T := by
    calc t * 64 + e < (t + 1) * 64 := by omega
      _ ≤ T * 64 := Nat.mul_le_mul_right _ ht
      _ = 64 * T := Nat.mul_comm _ _
  have hte' : t' * 64 + e' < 64 * T := by
    calc t' * 64 + e' < (t' + 1) * 64 := by omega
      _ ≤ T * 64 := Nat.mul_le_mul_right _ ht'
      _ = 64 * T := Nat.mul_comm _ _
  obtain ⟨h1, h2⟩ := idx_inj hte hte' (by rw [Nat.add_assoc, Nat.add_assoc] at h; exact h)
  obtain ⟨h3, h4⟩ := idx_inj he he' h2
  exact ⟨h1, h3, h4⟩

theorem part_div {T s t e : Nat} (ht : t < T) (he : e < 64) :
    (s * (64 * T) + t * 64 + e) / (64 * T) = s ∧ (s * (64 * T) + t * 64 + e) % 64 = e := by
  have hte : t * 64 + e < 64 * T := by
    calc t * 64 + e < (t + 1) * 64 := by omega
      _ ≤ T * 64 := Nat.mul_le_mul_right _ ht
      _ = 64 * T := Nat.mul_comm _ _
  refine ⟨?_, ?_⟩
  · rw [Nat.add_assoc, Nat.add_comm, Nat.add_mul_div_right _ _ (by omega), Nat.div_eq_of_lt hte, Nat.zero_add]
  · rw [show s * (64 * T) + t * 64 + e = e + 64 * (s * T + t) by ring, Nat.add_mul_mod_self_left,
      Nat.mod_eq_of_lt he]

/-- Lane `laneOf e` of SIMD-group `s` writes `part[s][t][e]` before the barrier of threadgroup `g` (epoch `g`). -/
theorem Mem.wpart (h : Mem C L D I nb mb P g pw sh) (hS : Shape L D A) (ctx : Ctx) {s t e : Nat}
    (hs : s < D.splits) (ht : t < D.tiles) (he : e < 64)
    (hth : ctx.thread = g * (32 * D.splits) + 32 * s + (laneOf e).val) (hg : ctx.group = g) :
    Mem C L D I nb mb P g (fun s' t' e' => pw s' t' e' ∨ (s' = s ∧ t' = t ∧ e' = e))
      (wrn ctx sh 6 (4 * (s * (64 * D.tiles) + t * 64 + e)) 4
        (wordBytes 4 (Val.f32Bits (AffineSplitMma.part C D I nb mb s t e)))) := by
  have hl : (wordBytes 4 (Val.f32Bits (AffineSplitMma.part C D I nb mb s t e))).length = 4 := wordBytes_length 4 _
  obtain ⟨hd1, hd2⟩ := part_div (s := s) ht he
  refine ⟨h.regions, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.x, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.h,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.w, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.s,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.b, h.deve, h.grpe,
    fun i hi n hn hk => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.y i hi n hn hk, fun s' hs' t' ht' e' he' hw => ?_,
    forall_log _ 4 _ (fun j hj => owned_group L (dev D) (tgo D) ctx sh 6 _ _ hS.r6 true rfl ?_) h.log⟩
  · rw [wrn_same]
    by_cases hx : s' = s ∧ t' = t ∧ e' = e
    · obtain ⟨rfl, rfl, rfl⟩ := hx
      have := cells_writeBytes_same (sh.bytes 6) (4 * (s' * (64 * D.tiles) + t' * 64 + e'))
        (wordBytes 4 (Val.f32Bits (AffineSplitMma.part C D I nb mb s' t' e')))
      rwa [hl] at this
    · have hne : s' * (64 * D.tiles) + t' * 64 + e' ≠ s * (64 * D.tiles) + t * 64 + e := fun hq =>
        hx (part_idx_inj ht' he' ht he hq)
      rw [cells_writeBytes_other _ _ _ _ _ (by rw [hl]; omega)]
      exact h.part s' hs' t' ht' e' he' (hw.resolve_right hx)
  · have hb : (4 * (s * (64 * D.tiles) + t * 64 + e) + j) / 4 = s * (64 * D.tiles) + t * 64 + e := by omega
    simp only [tgo, h.grpe, hg, true_and, ite_true, hb, hd1, hd2, hth]

/-- The writer of `y[i][n]` writes it, the next output in order. -/
theorem Mem.wy (h : Mem C L D I nb mb P ge pw sh) (hS : Shape L D A) (hok : D.N % (8 * D.tiles) = 0)
    (ht0 : 0 < D.tiles) (hs0 : 0 < D.splits) (ctx : Ctx) {i n : Nat} (hi : i < D.r) (hn : n < D.N)
    (hP : key D i n = P) (hth : ctx.thread = (ywriter D (i * D.N + n)).thread)
    (hg : ctx.group = (ywriter D (i * D.N + n)).group) :
    Mem C L D I nb mb (P + 1) ge pw (wrn ctx sh 5 (2 * (i * D.N + n)) 2 (wordBytes 2 (Val.bf16Bits (yv C D I i n)))) := by
  have hl : (wordBytes 2 (Val.bf16Bits (yv C D I i n))).length = 2 := wordBytes_length 2 _
  refine ⟨h.regions, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.x, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.h,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.w, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.s,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.b, h.deve, h.grpe, fun i' hi' n' hn' hk => ?_,
    fun s hs t ht e he hw => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.part s hs t ht e he hw,
    forall_log _ 2 _ (fun j hj => owned_device L (dev D) (tgo D) ctx sh 5 _ _ hS.r5 true (by simp)
      (ywriter D (i * D.N + n)) (by simp only [dev, ite_true]; congr 2; omega) hth hg (by rw [h.deve]; exact Nat.zero_le _))
      h.log⟩
  rw [wrn_same]
  by_cases hx : i' = i ∧ n' = n
  · obtain ⟨rfl, rfl⟩ := hx
    have := cells_writeBytes_same (sh.bytes 5) (2 * (i' * D.N + n')) (wordBytes 2 (Val.bf16Bits (yv C D I i' n')))
    rwa [hl] at this
  · have hk' : key D i' n' < P := by
      have : key D i' n' ≠ key D i n := fun hq => hx (key_inj D hok ht0 hs0 hn' hn hq)
      omega
    have hne : i' * D.N + n' ≠ i * D.N + n := fun hq => hx ⟨(idx_inj hn' hn hq).1, (idx_inj hn' hn hq).2⟩
    rw [cells_writeBytes_other _ _ _ _ _ (by rw [hl]; omega)]
    exact h.y i' hi' n' hn' hk'

/-- Positions no output has. -/
theorem Mem.bump (h : Mem C L D I nb mb P ge pw sh) {P' : Nat} (hno : ∀ i < D.r, ∀ n < D.N, key D i n < P' → key D i n < P) :
    Mem C L D I nb mb P' ge pw sh :=
  ⟨h.regions, h.x, h.h, h.w, h.s, h.b, h.deve, h.grpe, fun i hi n hn hk => h.y i hi n hn (hno i hi n hn hk), h.part,
    h.log⟩

/-- The barrier (threadgroup memory only). -/
theorem Mem.pass (h : Mem C L D I nb mb P ge pw sh) : Mem C L D I nb mb P (ge + 1) pw (pass false true sh) :=
  ⟨h.regions, h.x, h.h, h.w, h.s, h.b, by simp [Metal.pass, h.deve], by simp [Metal.pass, h.grpe], h.y, h.part, h.log⟩

/-- A threadgroup starts: its `part` holds garbage. -/
theorem Mem.reset (h : Mem C L D I nb mb P ge pw sh) (hb : L.buffers.length = 6) (garbage : Garbage) (g nb' mb' : Nat) :
    Mem C L D I nb' mb' P ge (fun _ _ _ => False) { sh with bytes := L.resetGroup garbage g sh.bytes } :=
  ⟨h.regions, by show L.resetGroup garbage g sh.bytes 0 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.x,
    by show L.resetGroup garbage g sh.bytes 1 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.h,
    by show L.resetGroup garbage g sh.bytes 2 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.w,
    by show L.resetGroup garbage g sh.bytes 3 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.s,
    by show L.resetGroup garbage g sh.bytes 4 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.b,
    h.deve, h.grpe,
    fun i hi n hn hk => by
      show cells (L.resetGroup garbage g sh.bytes 5) _ 2 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]
      exact h.y i hi n hn hk,
    fun _ _ _ _ _ _ hf => hf.elim, h.log⟩

end Memory

/-! ## A lane -/

/-- Lane `i` of SIMD-group `s` of threadgroup `(0, nb, mb)`. -/
structure Lane (D : Dims) (ctx : Ctx) (nb mb s i : Nat) : Prop where
  lane : ctx.coord .threadIndexInSimdgroup = u32 i
  sg : ctx.coord .simdgroupIndexInThreadgroup = u32 s
  tgp : ctx.coord .threadgroupPositionInGrid = u32x3 0 nb mb
  thread : ctx.thread = (nb + mb * gy D) * (32 * D.splits) + (32 * s + i)
  group : ctx.group = nb + mb * gy D
  ga : ctx.groupArray 0 = 6
  ta : ∀ j, ctx.threadArray j = ta ctx.thread j
  hnb : nb < gy D
  hmb : mb < gz D
  hs : s < D.splits
  hi : i < 32

theorem gy_pos {D : Dims} (hok : Ok D) : 0 < gy D := by
  have h1 : 8 * D.tiles ≤ D.N := Nat.le_of_dvd hok.Npos (Nat.dvd_of_mod_eq_zero hok.N)
  unfold gy; exact Nat.div_pos h1 (by have := hok.tiles; omega)

theorem gz_pos {D : Dims} (hok : Ok D) : 0 < gz D := by have := hok.r; unfold gz; omega

theorem launch_tiles {D : Dims} {I : In} {A : Al} {initial : Nat → ByteMemory.Bytes} (hok : Ok D) :
    (launch D I A initial).Tiles (32 * D.splits) 1 1 1 (gy D) (gz D) D.splits :=
  ⟨rfl, by simp [launch], by ring, ⟨hok.splits, by decide, gy_pos hok, gz_pos hok⟩⟩

theorem lane_of {D : Dims} {I : In} {A : Al} {initial : Nat → ByteMemory.Bytes} (hok : Ok D) (fuse : Nat → Bool)
    {nb mb : Nat} (hnb : nb < gy D) (hmb : mb < gz D) (s : Fin D.splits) (i : Fin 32) :
    Lane D ((launch D I A initial).ctxAt fuse 0 nb mb (32 * s + i)) nb mb s i := by
  have hs := s.isLt; have hi := i.isLt
  refine ⟨Launch.ctxAt_lane _ _ _ _ _ _ _, Launch.ctxAt_simd _ _ _ _ _ _ _,
    Launch.ctxAt_threadgroupPositionInGrid _ _ _ _ _ _, ?_, ?_, rfl, fun j => ?_, hnb, hmb, hs, hi⟩
  · rw [(launch_tiles hok).thread]; ring
  · rw [(launch_tiles hok).group_id]; ring
  · rw [(launch_tiles hok).threadArray, (launch_tiles hok).thread,
      show (launch D I A initial).buffers.length = 6 from rfl, show (launch D I A initial).groupArrays = 1 from rfl,
      show (launch D I A initial).threadArrays = 7 from rfl]
    unfold ta; ring

end Metal.Kernels.SplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

/-! ## Before the K steps -/

/-- Row `min(m0 + fn + j, M - 1)` of `x` from column `32·fm`: where `x0` (`j = 0`) and `x1` (`j = 1`) point. -/
def xbase (D : Dims) (mb i j : Nat) : Nat := min (8 * mb + fnOf i + j) (D.r - 1) * D.K + 32 * fmOf i

/-- The values every K step reads: buffers, lane, SIMD-group, `fm`, `fn`, `M`, `n0`, `m0`, `groups`, `groupWords`,
`x0`, `x1`, `wRow`, `acc`. -/
structure Fix (D : Dims) (ctx : Ctx) (nb mb s i : Nat) (l : Locals) : Prop where
  l0 : l 0 = some (.ptr ⟨0, 0, .scalar .bf16⟩)
  l1 : l 1 = some (.ptr ⟨1, 0, .scalar .i32⟩)
  l2 : l 2 = some (.ptr ⟨2, 0, .scalar .u32⟩)
  l3 : l 3 = some (.ptr ⟨3, 0, .scalar .bf16⟩)
  l4 : l 4 = some (.ptr ⟨4, 0, .scalar .bf16⟩)
  l5 : l 5 = some (.ptr ⟨5, 0, .scalar .bf16⟩)
  l6 : l 6 = some (u32 i)
  l7 : l 7 = some (u32 s)
  l8 : l 8 = some (u32 (fmOf i))
  l9 : l 9 = some (u32 (fnOf i))
  l10 : l 10 = some (u32 D.r)
  l11 : l 11 = some (u32 (8 * D.tiles * nb))
  l12 : l 12 = some (u32 (8 * mb))
  l13 : l 13 = some (u32 (D.K / 64))
  l14 : l 14 = some (u32 (2 * D.bits))
  l15 : l 15 = some (.ptr ⟨0, ((2 * xbase D mb i 0 : Nat) : Int), .scalar .bf16⟩)
  l16 : l 16 = some (.ptr ⟨0, ((2 * xbase D mb i 1 : Nat) : Int), .scalar .bf16⟩)
  l17 : l 17 = some (.ptr ⟨ctx.threadArray 0, 0, .ptr .device (.scalar .u32)⟩)
  l18 : l 18 = some (.ptr ⟨ctx.threadArray 1, 0, .vec .f32 2⟩)

variable {D : Dims} {ctx : Ctx} {nb mb s i : Nat}

theorem Fix.of_eq {l l' : Locals} (h : Fix D ctx nb mb s i l) (h' : ∀ j, j ≤ 18 → l' j = l j) :
    Fix D ctx nb mb s i l' :=
  ⟨(h' 0 (by omega)).trans h.l0, (h' 1 (by omega)).trans h.l1, (h' 2 (by omega)).trans h.l2,
    (h' 3 (by omega)).trans h.l3, (h' 4 (by omega)).trans h.l4, (h' 5 (by omega)).trans h.l5,
    (h' 6 (by omega)).trans h.l6, (h' 7 (by omega)).trans h.l7, (h' 8 (by omega)).trans h.l8,
    (h' 9 (by omega)).trans h.l9, (h' 10 (by omega)).trans h.l10, (h' 11 (by omega)).trans h.l11,
    (h' 12 (by omega)).trans h.l12, (h' 13 (by omega)).trans h.l13, (h' 14 (by omega)).trans h.l14,
    (h' 15 (by omega)).trans h.l15, (h' 16 (by omega)).trans h.l16, (h' 17 (by omega)).trans h.l17,
    (h' 18 (by omega)).trans h.l18⟩

theorem Fix.set {l : Locals} (h : Fix D ctx nb mb s i l) {j : Nat} (v : Val) (hj : 18 < j) :
    Fix D ctx nb mb s i (setLocal l j v) :=
  h.of_eq fun k hk => setLocal_other _ _ (by omega)

/-- The declarations before the loops. -/
def pre (D : Dims) : List CStmt := (body D.N D.K D.bits D.tiles D.splits).take 19

theorem fm_lt (i : Nat) : fmOf i < 8 := by unfold fmOf; have : i / 4 &&& 4 ≤ 4 := Nat.and_le_right; omega

theorem fn_lt (i : Nat) : fnOf i < 8 := by unfold fnOf; have : i / 4 &&& 2 ≤ 2 := Nat.and_le_right; omega

/-- Sizes the bounds below use. -/
theorem Ok.tiles_lt {D : Dims} (hok : Ok D) : 8 * D.tiles ≤ D.N :=
  Nat.le_of_dvd hok.Npos (Nat.dvd_of_mod_eq_zero hok.N)

theorem n0_lt {D : Dims} {nb : Nat} (hnb : nb < gy D) : 8 * D.tiles * nb + 8 * D.tiles ≤ D.N := by
  have h2 : gy D * (8 * D.tiles) ≤ D.N := Nat.div_mul_le_self _ _
  have h3 : (nb + 1) * (8 * D.tiles) ≤ gy D * (8 * D.tiles) := Nat.mul_le_mul_right _ hnb
  have h4 : 8 * D.tiles * nb = nb * (8 * D.tiles) := by ring
  rw [Nat.add_mul, Nat.one_mul] at h3
  omega

section Pre
variable (C : M1Max.Contract) {L : Launch} {A : Al}

theorem exec_pre (hS : Shape L D A) (hok : Ok D) (hl : Lane D ctx nb mb s i) {sh : Shared}
    (hreg : sh.regions = L.regions) (hh : sh.bytes 1 = shapeBytes D.r D.K) :
    ∃ l, Exec C ctx (pre D) (fun _ => none) sh .normal l (rdn ctx sh 1 0 4) ∧ Fix D ctx nb mb s i l := by
  have hi := hl.hi; have hs := hl.hs
  have hr := hok.r; have hr31 := hok.rle; have hK := hok.Kle; have hN := hok.Nle; have hT := hok.tiles_lt
  have hfm := fm_lt i; have hfn := fn_lt i
  have hmb : 8 * mb < 2 ^ 31 := by have := hl.hmb; unfold gz at this; omega
  have hnb := n0_lt hl.hnb
  have hload : (loadAt ctx (.scalar .i32) ⟨1, ((0 : Nat) : Int), .scalar .i32⟩).run sh =
      some (.int .i32 D.r, rdn ctx sh 1 0 4) := by
    have h := load_shared ctx .i32 sh 1 0 ⟨.constant, 8, A.h⟩ (by rw [hreg]; exact hS.r1) (by simp)
      (by simpa [Scalar.bytes] using hS.ah) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]) (by simp [loadOffset])
    rw [h, hh, show Scalar.i32.bytes = 4 from rfl]
    unfold shapeBytes
    rw [cells_shape, ofWord_i32 hr31]
  generalize rdn ctx sh 1 0 4 = sh₁ at hload
  have e6 : ∀ (l : Locals) (sh : Shared), (eval C ctx l (.coord .threadIndexInSimdgroup)).run sh = some (u32 i, sh) :=
    fun l sh => by rw [eval_coord, hl.lane]
  have e7 : ∀ (l : Locals) (sh : Shared),
      (eval C ctx l (.coord .simdgroupIndexInThreadgroup)).run sh = some (u32 s, sh) :=
    fun l sh => by rw [eval_coord, hl.sg]
  have e8 : ∀ (l : Locals) (sh : Shared), l 6 = some (u32 i) →
      (eval C ctx l (AffineSplitMma.u32 .add
        (AffineSplitMma.u32 .bitAnd (AffineSplitMma.u32 .div (.local 6) (u32l 4)) (u32l 4))
        (AffineSplitMma.u32 .rem (AffineSplitMma.u32 .div (.local 6) (u32l 2)) (u32l 4)))).run sh =
        some (u32 (fmOf i), sh) :=
    fun l sh h => eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h sh)
      (eval_u32lit C _ sh 4 (by norm_num)) (binary_div_u32 C i 4 (by omega) (by norm_num) (by norm_num)))
      (eval_u32lit C _ sh 4 (by norm_num)) (binary_bitAnd_u32 C (i / 4) 4 (by omega) (by norm_num)))
      (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h sh) (eval_u32lit C _ sh 2 (by norm_num))
        (binary_div_u32 C i 2 (by omega) (by norm_num) (by norm_num))) (eval_u32lit C _ sh 4 (by norm_num))
        (binary_rem_u32 C (i / 2) 4 (by omega) (by norm_num) (by norm_num)))
      (binary_add_u32 C _ _)
  have e9 : ∀ (l : Locals) (sh : Shared), l 6 = some (u32 i) →
      (eval C ctx l (AffineSplitMma.u32 .add
        (AffineSplitMma.u32 .mul (AffineSplitMma.u32 .bitAnd (AffineSplitMma.u32 .div (.local 6) (u32l 4)) (u32l 2))
          (u32l 2))
        (AffineSplitMma.u32 .mul (AffineSplitMma.u32 .rem (.local 6) (u32l 2)) (u32l 2)))).run sh =
        some (u32 (fnOf i), sh) :=
    fun l sh h => eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h sh)
      (eval_u32lit C _ sh 4 (by norm_num)) (binary_div_u32 C i 4 (by omega) (by norm_num) (by norm_num)))
      (eval_u32lit C _ sh 2 (by norm_num)) (binary_bitAnd_u32 C (i / 4) 2 (by omega) (by norm_num)))
      (eval_u32lit C _ sh 2 (by norm_num)) (binary_mul_u32 C _ 2))
      (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h sh) (eval_u32lit C _ sh 2 (by norm_num))
        (binary_rem_u32 C i 2 (by omega) (by norm_num) (by norm_num))) (eval_u32lit C _ sh 2 (by norm_num))
        (binary_mul_u32 C _ 2))
      (binary_add_u32 C _ _)
  have e10 : ∀ (l : Locals), l 1 = some (.ptr ⟨1, 0, .scalar .i32⟩) →
      (eval C ctx l (.conv .u32 (.load (.scalar .i32) (.offset (.local 1) (i32l 0))))).run sh = some (u32 D.r, sh₁) := by
    intro l h
    have hp := eval_offset_i32 C (o := 0) (eval_local' C h sh) (eval_i32lit_raw C (ctx := ctx) (l := l) (sh := sh) 0)
      (by norm_num)
    exact eval_conv C ((eval_load C ctx l _ _ _ sh sh hp).trans hload) (convert_u32_i32 C D.r hr31)
  have e11 : ∀ (l : Locals) (sh : Shared),
      (eval C ctx l (AffineSplitMma.u32 .mul (AffineSplitMma.u32 .mul
        (.component (.coord .threadgroupPositionInGrid) (u32l 1)) (u32l 8)) (u32l D.tiles))).run sh =
        some (u32 (8 * D.tiles * nb), sh) := by
    intro l sh
    have := eval_bin_u32 C (op := .mul) (site := 0) (eval_bin_u32 C (op := .mul) (site := 0)
      (eval_coord1 C (l := l) (sh := sh) hl.tgp) (eval_u32lit C l sh 8 (by norm_num)) (binary_mul_u32 C nb 8))
      (eval_u32lit C l sh D.tiles (by omega)) (binary_mul_u32 C (nb * 8) D.tiles)
    rwa [show nb * 8 * D.tiles = 8 * D.tiles * nb by ring] at this
  have e12 : ∀ (l : Locals) (sh : Shared),
      (eval C ctx l (AffineSplitMma.u32 .mul (.component (.coord .threadgroupPositionInGrid) (u32l 2)) (u32l 8))).run
        sh = some (u32 (8 * mb), sh) := by
    intro l sh
    have := eval_bin_u32 C (op := .mul) (site := 0) (eval_coord2 C (l := l) (sh := sh) hl.tgp)
      (eval_u32lit C l sh 8 (by norm_num)) (binary_mul_u32 C mb 8)
    rwa [Nat.mul_comm mb 8] at this
  have hrK : (D.r - 1) * D.K < 2 ^ 47 := by
    have := Nat.mul_le_mul (show D.r - 1 ≤ 2 ^ 31 - 1 by omega) (show D.K ≤ 2 ^ 16 - 1 by omega)
    exact lt_of_le_of_lt this (by norm_num)
  have ex : ∀ (k : Nat), k < 2 → ∀ (l : Locals) (sh : Shared), l 0 = some (.ptr ⟨0, 0, .scalar .bf16⟩) →
      l 8 = some (u32 (fmOf i)) → l 9 = some (u32 (fnOf i)) → l 10 = some (u32 D.r) → l 12 = some (u32 (8 * mb)) →
      (eval C ctx l (xRow D.K k)).run sh = some (.ptr ⟨0, ((2 * xbase D mb i k : Nat) : Int), .scalar .bf16⟩, sh) := by
    intro k hk l sh h0 h8 h9 h10 h12
    have hcol : (eval C ctx l (if k = 0 then AffineSplitMma.u32 .add (.local 12) (.local 9)
        else AffineSplitMma.u32 .add (AffineSplitMma.u32 .add (.local 12) (.local 9)) (u32l k))).run sh =
        some (u32 (8 * mb + fnOf i + k), sh) := by
      have hadd := eval_bin_u32 C (ctx := ctx) (op := .add) (site := 0) (eval_local' C h12 sh) (eval_local' C h9 sh)
        (binary_add_u32 C (8 * mb) (fnOf i))
      rcases (show k = 0 ∨ k = 1 by omega) with rfl | rfl
      · exact hadd
      · exact eval_bin_u32 C hadd (eval_u32lit C _ sh 1 (by norm_num)) (binary_add_u32 C _ 1)
    have hmin := eval_bin_u32 C (op := .min) (site := 0) hcol (eval_bin_u32 C (op := .sub) (site := 0)
      (eval_local' C h10 sh) (eval_u32lit C _ sh 1 (by norm_num)) (binary_sub_u32 C D.r 1 hr))
      (binary_min_u32 C _ _ (by omega) (by omega))
    have hrowK := eval_mul_u64 C (site := 0) (eval_toU64 C hmin (by omega)) (eval_u64lit C l sh D.K
      (by omega))
    have hb : min (8 * mb + fnOf i + k) (D.r - 1) * D.K < 2 ^ 64 :=
      lt_of_le_of_lt (Nat.mul_le_mul_right _ (Nat.min_le_right _ _)) (lt_trans hrK (by norm_num))
    have hin := eval_offset_u64 C (o := 0) (eval_local' C h0 sh) hrowK hb
    have hout := eval_offset_u32 C hin (eval_bin_u32 C (op := .mul) (site := 0) (eval_local' C h8 sh)
      (eval_u32lit C _ sh 32 (by norm_num)) (binary_mul_u32 C _ 32)) (by omega)
    have e : 0 + min (8 * mb + fnOf i + k) (D.r - 1) * D.K * (Ty.scalar .bf16).bytes +
        fmOf i * 32 * (Ty.scalar .bf16).bytes = 2 * xbase D mb i k := by
      simp only [xbase, Ty.bytes, Scalar.bytes]; ring
    rw [e] at hout
    exact hout
  refine ⟨?l, ?ex, ?fx⟩
  case ex =>
    exact .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <|
      .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <|
      .set (e6 _ _) <| .set (e7 _ _) <| .set (e8 _ _ rfl) <| .set (e9 _ _ rfl) <| .set (e10 _ rfl) <|
      .set (e11 _ _) <| .set (e12 _ _) <| .set (eval_u32lit C _ _ (D.K / 64) (by omega)) <|
      .set (eval_u32lit C _ _ (2 * D.bits) (by have := hok.bits; omega)) <|
      .set (ex 0 (by omega) _ _ rfl rfl rfl rfl rfl) <| .set (ex 1 (by omega) _ _ rfl rfl rfl rfl rfl) <|
      .array <| .array <| (by simp only [List.take_zero]; exact .nil _ _)
  case fx =>
    exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

end Pre
end Metal.Kernels.SplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

/-! ### A thread's arrays -/

/-- Thread `th`'s seven thread arrays. -/
def tview (sh : Shared) (th : Nat) : Nat → ByteMemory.Bytes := fun j => if j < 7 then sh.bytes (ta th j) else fun _ => 0

theorem ta_inj {th th' j j' : Nat} (hj : j < 7) (hj' : j' < 7) (h : ta th j = ta th' j') : th = th' ∧ j = j' := by
  unfold ta at h
  exact idx_inj hj hj' (by omega)

theorem tview_tput_thread {sh : Shared} {th th' j o : Nat} {bs : List (BitVec 8)} (hth : th' ≠ th) (hj : j < 7) :
    tview (tput sh (ta th j) o bs) th' = tview sh th' := by
  funext j'
  unfold tview
  split
  · rw [tput_other _ _ _ (fun h => hth (ta_inj (by omega) hj h).1)]
  · rfl

theorem tview_tput {sh : Shared} {th j o : Nat} {bs : List (BitVec 8)} (hj : j < 7) :
    tview (tput sh (ta th j) o bs) th = fun j' => if j' = j then writeBytes (tview sh th j) o bs else tview sh th j' := by
  funext j'
  unfold tview
  by_cases h : j' = j
  · subst h; simp [hj, tput_same]
  · rw [ite_eq_right h]
    split
    · rw [tput_other _ _ _ (fun h' => h (ta_inj (by omega) hj h').2)]
    · rfl

theorem tview_wrn {ctx : Ctx} {sh : Shared} {th reg o n : Nat} {bs : List (BitVec 8)} (hreg : reg < 7) :
    tview (wrn ctx sh reg o n bs) th = tview sh th := by
  funext j'
  unfold tview
  split
  · rw [wrn_other _ _ _ _ _ (by unfold ta; omega)]
  · rfl

/-- `wRow[t]`: the word of a pointer to word `(n0 + 8t + fm)·groups·groupWords` of `w`. -/
def wrowWord (D : Dims) (nb fm t : Nat) : Nat :=
  2 * 2 ^ 40 + 4 * ((8 * D.tiles * nb + 8 * t + fm) * (D.K / 64) * (2 * D.bits))

def WRowOk (D : Dims) (nb fm : Nat) (V : Nat → ByteMemory.Bytes) : Prop :=
  ∀ t < D.tiles, cells (V 0) (8 * t) 8 = wordBytes 8 (wrowWord D nb fm t)

/-- `acc[t]`'s two elements. -/
def AccOk (D : Dims) (f : Nat → Fin 2 → Float32) (V : Nat → ByteMemory.Bytes) : Prop :=
  ∀ t < D.tiles, cells (V 1) (8 * t) 8 = pairBytes (f t 0) (f t 1)

/-- `q[t][j]`. -/
def QOk (D : Dims) (q : Nat → Nat → Nat) (V : Nat → ByteMemory.Bytes) : Prop :=
  ∀ t < D.tiles, ∀ j < 2 * D.bits, cells (V 2) (4 * (t * (2 * D.bits) + j)) 4 = wordBytes 4 (q t j)

/-- `s2[t]` (`k = 3`) or `b2[t]` (`k = 4`). -/
def FOk (D : Dims) (k : Nat) (f : Nat → Float32) (V : Nat → ByteMemory.Bytes) : Prop :=
  ∀ t < D.tiles, cells (V k) (4 * t) 4 = wordBytes 4 (Val.f32Bits (f t))

/-- `bx`'s two elements. -/
def BxOk (x y : Float32) (V : Nat → ByteMemory.Bytes) : Prop := cells (V 5) 0 8 = pairBytes x y

theorem rowWords_lt {D : Dims} (hok : Ok D) {n : Nat} (hn : n < D.N) : n * (D.K / 64) * (2 * D.bits) < 2 ^ 30 := by
  have h1 : n ≤ 2 ^ 16 := by have := hok.Nle; omega
  have h2 : D.K / 64 ≤ 2 ^ 10 := by have := hok.Kle; omega
  have h3 : 2 * D.bits ≤ 8 := by have := hok.bits; omega
  exact lt_of_le_of_lt (Nat.mul_le_mul (Nat.mul_le_mul h1 h2) h3) (by norm_num)

end Metal.Kernels.SplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

/-! ## The code, in pieces -/

def wrowStore : CStmt :=
  .store (.ptr .device (.scalar .u32)) (.offset (.local 17) (.local 19))
    (.offset (.local 2) (AffineSplitMma.u64 .mul (AffineSplitMma.u64 .mul (toU64 (AffineSplitMma.u32 .add
      (AffineSplitMma.u32 .add (.local 11) (AffineSplitMma.u32 .mul (u32l 8) (.local 19))) (.local 8)))
      (toU64 (.local 13))) (toU64 (.local 14))))

def accInit : CStmt := .store (.vec .f32 2) (.offset (.local 18) (.local 19)) (.vector .f32 [f32l 0x0, f32l 0x0])

def initFor (D : Dims) : List CStmt := forU 19 (u32l D.tiles) [wrowStore, accInit]

def stepLoop (D : Dims) : CStmt := loopOf 20 (u32l (D.K / 256)) D.splits (stepBody D.bits D.tiles)

/-- After the K steps: `part`, the barrier, the output loop. -/
def after (D : Dims) : List CStmt := (body D.N D.K D.bits D.tiles D.splits).drop 23

theorem body_eq (D : Dims) : body D.N D.K D.bits D.tiles D.splits =
    pre D ++ (initFor D ++ (.set 20 (.local 7) :: stepLoop D :: after D)) := rfl

def stepPre : List CStmt :=
  [.set 21 (AffineSplitMma.u32 .mul (.local 20) (u32l 256)),
   .set 22 (AffineSplitMma.u32 .add (AffineSplitMma.u32 .mul (.local 20) (u32l 4))
     (AffineSplitMma.u32 .div (.local 9) (u32l 2))),
   .array 23 false 2 (.scalar .u32), .array 24 false 3 (.scalar .f32), .array 25 false 4 (.scalar .f32)]

def xaxb : List CStmt :=
  [.set 29 (.ptrCast (.vec .bf16 4) (.offset (.local 15) (.local 21))),
   .set 30 (.ptrCast (.vec .bf16 4) (.offset (.local 16) (.local 21)))]

def s4Body (bits tiles : Nat) : List CStmt :=
  [.set 32 (.conv .f32 (.load (.vec .bf16 4) (.offset (.local 29) (.local 31)))),
   .set 33 (.conv .f32 (.load (.vec .bf16 4) (.offset (.local 30) (.local 31))))] ++
  forU 34 (u32l 4) (columnBody bits tiles)

theorem stepBody_eq (bits tiles : Nat) : stepBody bits tiles =
    stepPre ++ (forU 26 (u32l tiles) (scaleBody bits) ++ (xaxb ++ forU 31 (u32l 8) (s4Body bits tiles))) := rfl

def colPre : List CStmt :=
  [.set 35 (AffineSplitMma.u32 .add (AffineSplitMma.u32 .mul (.local 31) (u32l 4)) (.local 34)),
   .array 36 false 5 (.vec .f32 2),
   .store (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (.local 36)) (i32l 0)) (.component (.local 32) (.local 34)),
   .store (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (.local 36)) (i32l 1)) (.component (.local 33) (.local 34))]

theorem columnBody_eq (bits tiles : Nat) : columnBody bits tiles = colPre ++ forU 37 (u32l tiles) (tileBody bits) := rfl

def accStore : CStmt := .store (.vec .f32 2) (.offset (.local 18) (.local 37)) (.local 55)

/-- The collective's operands `[a, bx, acc[t]]`. -/
def mmaE : CExpr :=
  .vector .f32 [.load (.vec .f32 2) (.local 38), .load (.vec .f32 2) (.local 36),
    .load (.vec .f32 2) (.offset (.local 18) (.local 37))]

theorem tileBody_eq (bits : Nat) : tileBody bits =
    .array 38 false 6 (.vec .f32 2) :: (unitElement bits 41 0 (.local 35) ++
      (unitElement bits 49 1 (AffineSplitMma.u32 .add (.local 35) (u32l 32)) ++
        [.collective 1 55 (.mma .f32 .f32) .f32 mmaE (u16l 0), accStore])) := rfl

/-- A thread's frames at its `simdgroup_multiply_accumulate`. -/
def Fc (D : Dims) : List Frame :=
  [.block [accStore], frameOf 37 (u32l D.tiles) 1 (tileBody D.bits), .block [],
   frameOf 34 (u32l 4) 1 (columnBody D.bits D.tiles), .block [], frameOf 31 (u32l 8) 1 (s4Body D.bits D.tiles), .block [],
   frameOf 20 (u32l (D.K / 256)) D.splits (stepBody D.bits D.tiles), .block (after D)]

/-! ## A lane's K steps -/

/-- Element offsets in `x` of `x0 + base` (`j = 0`) and `x1 + base` (`j = 1`) at `step`. -/
def xoff (D : Dims) (mb i step j : Nat) : Nat := xbase D mb i j + 256 * step

/-- Weight row `n0 + 8t + fm` and group `4·step + fn/2` of lane `i` at K step `k`. -/
def nOf (D : Dims) (nb i t : Nat) : Nat := 8 * D.tiles * nb + 8 * t + fmOf i
def gOf (D : Dims) (s i k : Nat) : Nat := 4 * stepOf D s k + fnOf i / 2

/-- `q[t][j]` at K step `k`. -/
def qOf (D : Dims) (I : In) (nb s i k : Nat) (t j : Nat) : Nat :=
  word I.W (gidx D (nOf D nb i t) (gOf D s i k) * (2 * D.bits) + j)

/-- `float4(xa[s4])`: elements `o … o + 3` of `x`, widened (the vector keeps its source tag). -/
def x4 (C : M1Max.Contract) (X : ByteMemory.Bytes) (o : Nat) : Val :=
  .vec .bf16 [.f32 (C.widen (bf X o)), .f32 (C.widen (bf X (o + 1))), .f32 (C.widen (bf X (o + 2))),
    .f32 (C.widen (bf X (o + 3)))]

section Locals
variable (C : M1Max.Contract) (D : Dims) (I : In) (ctx : Ctx) (nb mb s i : Nat)

/-- The locals of K step `k`. -/
structure StepLoc (k : Nat) (l : Locals) : Prop where
  fix : Fix D ctx nb mb s i l
  l19 : l 19 = some (u32 D.tiles)
  l20 : l 20 = some (u32 (stepOf D s k))
  l21 : l 21 = some (u32 (256 * stepOf D s k))
  l22 : l 22 = some (u32 (gOf D s i k))
  l23 : l 23 = some (.ptr ⟨ta ctx.thread 2, 0, .scalar .u32⟩)
  l24 : l 24 = some (.ptr ⟨ta ctx.thread 3, 0, .scalar .f32⟩)
  l25 : l 25 = some (.ptr ⟨ta ctx.thread 4, 0, .scalar .f32⟩)
  l29 : l 29 = some (.ptr ⟨0, ((2 * xoff D mb i (stepOf D s k) 0 : Nat) : Int), .vec .bf16 4⟩)
  l30 : l 30 = some (.ptr ⟨0, ((2 * xoff D mb i (stepOf D s k) 1 : Nat) : Int), .vec .bf16 4⟩)

/-- The locals of value `v` (column `v % 4` of chunk `v / 4`) of K step `k`. -/
structure ColLoc (k v : Nat) (l : Locals) : Prop where
  step : StepLoc D ctx nb mb s i k l
  l31 : l 31 = some (u32 (v / 4))
  l32 : l 32 = some (x4 C I.X (xoff D mb i (stepOf D s k) 0 + 4 * (v / 4)))
  l33 : l 33 = some (x4 C I.X (xoff D mb i (stepOf D s k) 1 + 4 * (v / 4)))
  l34 : l 34 = some (u32 (v % 4))
  l35 : l 35 = some (u32 v)
  l36 : l 36 = some (.ptr ⟨ta ctx.thread 5, 0, .vec .f32 2⟩)

/-- The locals at tile `t`'s multiply-accumulate. -/
structure TileLoc (k v t : Nat) (l : Locals) : Prop where
  col : ColLoc C D I ctx nb mb s i k v l
  l37 : l 37 = some (u32 t)
  l38 : l 38 = some (.ptr ⟨ta ctx.thread 6, 0, .vec .f32 2⟩)

variable {C D I ctx nb mb s i}

theorem StepLoc.of_eq {k : Nat} {l l' : Locals} (h : StepLoc D ctx nb mb s i k l) (h' : ∀ j, j ≤ 30 → l' j = l j) :
    StepLoc D ctx nb mb s i k l' :=
  ⟨h.fix.of_eq fun j hj => h' j (by omega), (h' 19 (by omega)).trans h.l19, (h' 20 (by omega)).trans h.l20,
    (h' 21 (by omega)).trans h.l21, (h' 22 (by omega)).trans h.l22, (h' 23 (by omega)).trans h.l23,
    (h' 24 (by omega)).trans h.l24, (h' 25 (by omega)).trans h.l25, (h' 29 (by omega)).trans h.l29,
    (h' 30 (by omega)).trans h.l30⟩

theorem ColLoc.of_eq {k v : Nat} {l l' : Locals} (h : ColLoc C D I ctx nb mb s i k v l)
    (h' : ∀ j, j ≤ 36 → l' j = l j) : ColLoc C D I ctx nb mb s i k v l' :=
  ⟨h.step.of_eq fun j hj => h' j (by omega), (h' 31 (by omega)).trans h.l31, (h' 32 (by omega)).trans h.l32,
    (h' 33 (by omega)).trans h.l33, (h' 34 (by omega)).trans h.l34, (h' 35 (by omega)).trans h.l35,
    (h' 36 (by omega)).trans h.l36⟩

theorem TileLoc.of_eq {k v t : Nat} {l l' : Locals} (h : TileLoc C D I ctx nb mb s i k v t l)
    (h' : ∀ j, j ≤ 38 → l' j = l j) : TileLoc C D I ctx nb mb s i k v t l' :=
  ⟨h.col.of_eq fun j hj => h' j (by omega), (h' 37 (by omega)).trans h.l37, (h' 38 (by omega)).trans h.l38⟩

end Locals

/-- A thread's arrays at tile `t`'s multiply-accumulate of value `v` of K step `k` (lane `i`). -/
structure TAt (C : M1Max.Contract) (D : Dims) (I : In) (nb mb s : Nat) (i : Fin 32) (k v t : Nat)
    (V : Nat → ByteMemory.Bytes) : Prop where
  wrow : WRowOk D nb (fmOf i) V
  acc : AccOk D (fun t' j => accAt C D I nb mb s t' (32 * k + v + if t' < t then 1 else 0) i j) V
  q : QOk D (qOf D I nb s i k) V
  s2 : FOk D 3 (fun t' => s2v C D I (nOf D nb i t') (gOf D s i k)) V
  b2 : FOk D 4 (fun t' => b2v C D I (nOf D nb i t') (gOf D s i k)) V
  bx : BxOk (bRegs C D I mb s k v i 0) (bRegs C D I mb s k v i 1) V

theorem TAt.of_eq {C : M1Max.Contract} {D : Dims} {I : In} {nb mb s : Nat} {i : Fin 32} {k v t : Nat}
    {V V' : Nat → ByteMemory.Bytes} (h : TAt C D I nb mb s i k v t V) (h' : ∀ j < 6, V' j = V j) :
    TAt C D I nb mb s i k v t V' := by
  obtain ⟨h1, h2, h3, h4, h5, h6⟩ := h
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · intro t' ht'; rw [h' 0 (by omega)]; exact h1 t' ht'
  · intro t' ht'; rw [h' 1 (by omega)]; exact h2 t' ht'
  · intro t' ht' j hj; rw [h' 2 (by omega)]; exact h3 t' ht' j hj
  · intro t' ht'; rw [h' 3 (by omega)]; exact h4 t' ht'
  · intro t' ht'; rw [h' 4 (by omega)]; exact h5 t' ht'
  · unfold BxOk; rw [h' 5 (by omega)]; exact h6

/-- Lane `i`'s operands at tile `t`'s multiply-accumulate of value `v` of K step `k`. -/
def xval (C : M1Max.Contract) (D : Dims) (I : In) (nb mb s : Nat) (i : Fin 32) (k v t : Nat) : Val :=
  mmaArg .f32 .f32 (.f32 (aRegs C D I nb s t k v i 0), .f32 (aRegs C D I nb s t k v i 1))
    (.f32 (bRegs C D I mb s k v i 0), .f32 (bRegs C D I mb s k v i 1))
    (.f32 (accAt C D I nb mb s t (32 * k + v) i 0), .f32 (accAt C D I nb mb s t (32 * k + v) i 1))

end Metal.Kernels.SplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

theorem tview_lt {sh : Shared} {th j : Nat} (h : j < 7) : tview sh th j = sh.bytes (ta th j) := by
  simp [tview, h]

theorem Ok.tiles_lt13 {D : Dims} (hok : Ok D) : D.tiles < 2 ^ 13 := by
  have := hok.tiles_lt; have := hok.Nle; omega

theorem Ok.bits_le {D : Dims} (hok : Ok D) : 2 * D.bits ≤ 8 := by have := hok.bits; omega

section Tile
variable (C : M1Max.Contract) {ctx : Ctx} {D : Dims}

/-- `AFFINE_UNIT(q[t], v)` (`v` the value of `vE`), and element `k` of `a` set to `fma(unit, s2[t], b2[t])`. -/
theorem exec_unitElement (hok : Ok D) (b k : Nat) (hb : b = 41 ∨ b = 49) (hk : k < 2) (vE : CExpr) {vv t th : Nat}
    (hvv : vv < 64) (ht : t < D.tiles) {q : Nat → Nat → Nat} (hq : ∀ t j, q t j < 2 ^ 32) {s2f b2f : Nat → Float32}
    {l : Locals} {sh : Shared}
    (hev : ∀ l', (∀ j, j < 39 → l' j = l j) → (eval C ctx l' vE).run sh = some (u32 vv, sh))
    (h23 : l 23 = some (.ptr ⟨ta th 2, 0, .scalar .u32⟩)) (h24 : l 24 = some (.ptr ⟨ta th 3, 0, .scalar .f32⟩))
    (h25 : l 25 = some (.ptr ⟨ta th 4, 0, .scalar .f32⟩)) (h37 : l 37 = some (u32 t))
    (h38 : l 38 = some (.ptr ⟨ta th 6, 0, .vec .f32 2⟩))
    (hr2 : sh.regions (ta th 2) = some ⟨.thread, 4 * (D.tiles * (2 * D.bits)), 4⟩)
    (hr3 : sh.regions (ta th 3) = some ⟨.thread, 4 * D.tiles, 4⟩)
    (hr4 : sh.regions (ta th 4) = some ⟨.thread, 4 * D.tiles, 4⟩)
    (hr6 : sh.regions (ta th 6) = some ⟨.thread, 8, 8⟩)
    (hQ : QOk D q (tview sh th)) (hS2 : FOk D 3 s2f (tview sh th)) (hB2 : FOk D 4 b2f (tview sh th)) :
    ∃ l', (∀ j, j < b - 2 ∨ b + 5 < j → l' j = l j) ∧ ∀ {ss : List CStmt} {o : Outcome} {lf : Locals} {shf : Shared},
      Exec C ctx ss l' (tput sh (ta th 6) (4 * k) (wordBytes 4 (Val.f32Bits (C.fma
        (Val.ofF32Bits (0x3F800000 + runBits (q t) (2 * D.bits) / 2 ^ (vv * D.bits) % 2 ^ D.bits * 2 ^ (23 - D.bits)))
        (s2f t) (b2f t))))) o lf shf →
      Exec C ctx (unitElement D.bits b k vE ++ ss) l sh o lf shf := by
  have hB := hok.bits
  have hB8 := hok.bits_le
  have hT := hok.tiles_lt13
  have hw : vv * D.bits / 32 < 2 * D.bits := by rcases hB with h | h <;> rw [h] <;> omega
  have hvB : vv * D.bits < 2 ^ 32 := by rcases hB with h | h <;> rw [h] <;> omega
  have htB : t * (2 * D.bits) ≤ t * 8 := Nat.mul_le_mul_left t hB8
  have htB' : (t + 1) * (2 * D.bits) ≤ D.tiles * (2 * D.bits) := Nat.mul_le_mul_right _ ht
  rw [Nat.add_mul, Nat.one_mul] at htB'
  have hrow : ∀ (l' : Locals), l' 23 = l 23 → l' 37 = l 37 →
      (eval C ctx l' (row 23 (.local 37) (2 * D.bits))).run sh =
        some (.ptr ⟨ta th 2, ((0 + t * (2 * D.bits) * (Ty.scalar .u32).bytes : Nat) : Int), .scalar .u32⟩, sh) :=
    fun l' e23 e37 => eval_offset_u64 C (o := 0) (eval_local' C (e23.trans h23) sh)
      (eval_mul_u64 C (eval_toU64 C (eval_local' C (e37.trans h37) sh) (by omega)) (eval_u64lit C _ _ _ (by omega)))
      (by omega)
  have hword : ∀ (l' : Locals), (eval C ctx l' vE).run sh = some (u32 vv, sh) →
      (eval C ctx l' (AffineSplitMma.u32 .shr (AffineSplitMma.u32 .mul vE (u32l D.bits)) (u32l 5))).run sh =
        some (u32 (vv * D.bits / 32), sh) :=
    fun l' he => eval_bin_u32 C (eval_bin_u32 C he (eval_u32lit C _ sh D.bits (by omega)) (binary_mul_u32 C vv D.bits))
      (eval_u32lit C _ sh 5 (by norm_num)) (binary_shr_u32 C (vv * D.bits) 5 hvB (by norm_num))
  have hq2 : ∀ j < 2 * D.bits, (loadAt ctx (.scalar .u32)
      ⟨ta th 2, ((0 + t * (2 * D.bits) * (Ty.scalar .u32).bytes + j * (Ty.scalar .u32).bytes : Nat) : Int), .scalar .u32⟩).run sh =
      some (u32 (q t j), sh) := by
    intro j hj
    have e : 0 + t * (2 * D.bits) * (Ty.scalar .u32).bytes + j * (Ty.scalar .u32).bytes = 4 * (t * (2 * D.bits) + j) := by
      simp only [Ty.bytes, Scalar.bytes]; ring
    rw [e]
    have hc := hQ t ht j hj
    rw [tview_lt (by decide)] at hc
    exact load_t ctx _ _ sh (ta th 2) _ _ 4 _ hr2 (by simp [alignment, Scalar.bytes]) (by simp [alignment, Scalar.bytes])
      (by simp only [Ty.bytes, Scalar.bytes]; omega) (by rw [show (Ty.scalar .u32).bytes = 4 from rfl, hc]; exact decode_u32_bytes _)
  -- lo, hi, v
  have hlo : (eval C ctx l (.load (.scalar .u32) (.offset (row 23 (.local 37) (2 * D.bits))
      (AffineSplitMma.u32 .shr (AffineSplitMma.u32 .mul vE (u32l D.bits)) (u32l 5))))).run sh =
      some (u32 (q t (vv * D.bits / 32)), sh) :=
    (eval_load C ctx l _ _ _ sh sh (eval_offset_u32 C (hrow l rfl rfl) (hword l (hev l fun _ _ => rfl)) (by omega))).trans
      (hq2 _ hw)
  have hb2 : 39 ≤ b - 2 := by omega
  generalize hl1 : setLocal l (b - 2) (u32 (q t (vv * D.bits / 32))) = l₁
  have ag1 : ∀ j, j < 39 → l₁ j = l j := fun j hj => by rw [← hl1, setLocal_other _ _ (by omega)]
  have hmin := eval_bin_u32 C (op := .min) (site := 0) (eval_bin_u32 C (op := .add) (site := 0)
    (hword l₁ (hev l₁ ag1)) (eval_u32lit C _ sh 1 (by norm_num)) (binary_add_u32 C _ 1))
    (eval_u32lit C _ sh (2 * D.bits - 1) (by omega)) (binary_min_u32 C (vv * D.bits / 32 + 1) (2 * D.bits - 1) (by omega) (by omega))
  have hhi : (eval C ctx l₁ (.load (.scalar .u32) (.offset (row 23 (.local 37) (2 * D.bits))
      (.bin .min .u32 0 (AffineSplitMma.u32 .add (AffineSplitMma.u32 .shr (AffineSplitMma.u32 .mul vE (u32l D.bits)) (u32l 5))
        (u32l 1)) (u32l (2 * D.bits - 1)))))).run sh =
      some (u32 (q t (min (vv * D.bits / 32 + 1) (2 * D.bits - 1))), sh) :=
    (eval_load C ctx l₁ _ _ _ sh sh (eval_offset_u32 C (hrow l₁ (ag1 23 (by omega)) (ag1 37 (by omega))) hmin (by omega))).trans
      (hq2 _ (by omega))
  generalize hl2 : setLocal l₁ (b - 1) (u32 (q t (min (vv * D.bits / 32 + 1) (2 * D.bits - 1)))) = l₂
  have ag2 : ∀ j, j < 39 → l₂ j = l j := fun j hj => by rw [← hl2, setLocal_other _ _ (by omega), ag1 j hj]
  generalize hl3 : setLocal l₂ b (u32 vv) = l₃
  have ag3 : ∀ j, j < b - 2 ∨ b < j → l₃ j = l j := fun j hj => by
    rw [← hl3, setLocal_other _ _ (by omega), ← hl2, setLocal_other _ _ (by omega), ← hl1, setLocal_other _ _ (by omega)]
  have h3lo : l₃ (b - 2) = some (u32 (q t (vv * D.bits / 32))) := by
    rw [← hl3, setLocal_other _ _ (by omega), ← hl2, setLocal_other _ _ (by omega), ← hl1, setLocal_same]
  have h3hi : l₃ (b - 1) = some (u32 (q t (min (vv * D.bits / 32 + 1) (2 * D.bits - 1)))) := by
    rw [← hl3, setLocal_other _ _ (by omega), ← hl2, setLocal_same]
  have h3v : l₃ b = some (u32 vv) := by rw [← hl3, setLocal_same]
  obtain ⟨l', hag, hu, hcont⟩ := exec_affineUnit C (ctx := ctx) (sh := sh) D.bits b hB (by omega) (fun j _ => hq t j) hvv h3lo h3hi h3v
  have e : ∀ j, j < 39 → l' j = l j := fun j hj => (hag j (by omega)).trans (ag3 j (by omega))
  have hp := eval_offset_i32 C (o := 0) (r := ta th 6) (e := .scalar .f32)
    (eval_ptrCast C (t := .scalar .f32) (eval_local' C ((e 38 (by omega)).trans h38) sh))
    (eval_i32lit_raw C (ctx := ctx) (l := l') (sh := sh) k) (by omega)
  rw [show 0 + k * (Ty.scalar .f32).bytes = 4 * k by simp only [Ty.bytes, Scalar.bytes]; ring] at hp
  have hf : ∀ (j : Nat) (f : Nat → Float32) (hj : j = 3 ∨ j = 4), FOk D j f (tview sh th) →
      l' (21 + j) = some (.ptr ⟨ta th j, 0, .scalar .f32⟩) →
      (eval C ctx l' (.load (.scalar .f32) (.offset (.local (21 + j)) (.local 37)))).run sh = some (.f32 (f t), sh) := by
    intro j f hj hF hl'
    have hp' := eval_offset_u32 C (ctx := ctx) (o := 0) (eval_local' C hl' sh) (eval_local' C ((e 37 (by omega)).trans h37) sh)
      (by omega)
    rw [show 0 + t * (Ty.scalar .f32).bytes = 4 * t by simp only [Ty.bytes, Scalar.bytes]; ring] at hp'
    have hc := hF t ht
    rw [tview_lt (by omega)] at hc
    refine (eval_load C ctx l' _ _ _ sh sh hp').trans (load_t ctx _ _ sh (ta th j) _ (4 * D.tiles) 4 _ ?_
      (by simp [alignment, Scalar.bytes]) (by simp [alignment, Scalar.bytes]) (by simp only [Ty.bytes, Scalar.bytes]; omega)
      (by rw [show (Ty.scalar .f32).bytes = 4 from rfl, hc]; exact decode_f32_bytes _))
    rcases hj with rfl | rfl
    · exact hr3
    · exact hr4
  have hval := eval_fma C (eval_local' C hu sh)
    (hf 3 s2f (.inl rfl) hS2 ((e 24 (by omega)).trans h24)) (hf 4 b2f (.inr rfl) hB2 ((e 25 (by omega)).trans h25))
  have hst := store_t ctx (.scalar .f32) (.scalar .f32) sh (ta th 6) (4 * k) 8 8
    (.f32 (C.fma (Val.ofF32Bits (0x3F800000 + runBits (q t) (2 * D.bits) / 2 ^ (vv * D.bits) % 2 ^ D.bits * 2 ^ (23 - D.bits)))
      (s2f t) (b2f t))) _ hr6
    (by simp [alignment, Scalar.bytes]) (by simp [alignment, Scalar.bytes]) (by simp only [Ty.bytes, Scalar.bytes]; omega)
    (encode_f32 _)
  refine ⟨l', fun j hj => (hag j (by omega)).trans (ag3 j (by omega)), fun h => ?_⟩
  exact .set hlo (by rw [hl1]; exact .set hhi (by rw [hl2]; exact .set (hev l₂ ag2) (by rw [hl3]; exact hcont (.store hp hval hst h))))


theorem cells_pair_writes (B : ByteMemory.Bytes) (x y : Float32) :
    cells (writeBytes (writeBytes B 0 (wordBytes 4 (Val.f32Bits x))) 4 (wordBytes 4 (Val.f32Bits y))) 0 8 =
      pairBytes x y := by
  show cells _ 0 (4 + 4) = _
  rw [cells_append, cells_writeBytes_other _ _ _ _ _ (by rw [wordBytes_length]; omega)]
  have h1 := cells_writeBytes_same B 0 (wordBytes 4 (Val.f32Bits x))
  have h2 := cells_writeBytes_same (writeBytes B 0 (wordBytes 4 (Val.f32Bits x))) 4 (wordBytes 4 (Val.f32Bits y))
  rw [wordBytes_length] at h1 h2
  rw [h1, Nat.zero_add, h2]
  rfl

/-- The `float2` load of a pair. -/
theorem load_pair (ctx : Ctx) (sh : Shared) (reg o size : Nat) (e : Ty) (x y : Float32)
    (hr : sh.regions reg = some ⟨.thread, size, 8⟩) (hoa : o % 8 = 0) (hb : o + 8 ≤ size)
    (hc : cells (sh.bytes reg) o 8 = pairBytes x y) :
    (loadAt ctx (.vec .f32 2) ⟨reg, (o : Int), e⟩).run sh = some (.vec .f32 [.f32 x, .f32 y], sh) :=
  load_t ctx _ _ sh reg o size 8 _ hr (by simp [alignment, Ty.bytes, Scalar.bytes])
    (by simpa [alignment, Ty.bytes, Scalar.bytes] using hoa) (by simpa [Ty.bytes, Scalar.bytes] using hb)
    (by rw [show (Ty.vec .f32 2).bytes = 8 from rfl, hc]; exact decode_pair x y)

theorem exec_tile {L : Launch} {A : Al} {I : In} {nb mb s P ge : Nat} {pw : Nat → Nat → Nat → Prop} {i : Fin 32}
    {k v t : Nat} (hS : Shape L D A) (hok : Ok D) (hl : Lane D ctx nb mb s i) (hv : v < 32) (ht : t < D.tiles)
    {l : Locals} {sh : Shared} (hloc : ColLoc C D I ctx nb mb s i k v l) (h37 : l 37 = some (u32 t))
    (hm : Mem C L D I nb mb P ge pw sh) (hT : TAt C D I nb mb s i k v t (tview sh ctx.thread)) :
    ∃ l' sh', Exec C ctx (tileBody D.bits) l sh
        (.stop (.collective 1 55 (.mma .f32 .f32) .f32 (xval C D I nb mb s i k v t) 0) [.block [accStore]]) l' sh' ∧
      TileLoc C D I ctx nb mb s i k v t l' ∧ Mem C L D I nb mb P ge pw sh' ∧
      (∀ th', th' ≠ ctx.thread → tview sh' th' = tview sh th') ∧
      (∀ j < 6, tview sh' ctx.thread j = tview sh ctx.thread j) := by
  have hreg := hm.regions
  have hq : ∀ t j, qOf D I nb s i k t j < 2 ^ 32 := fun _ _ => bytesWord_cells_lt _ _
  have hst := hloc.step
  have hr2 : sh.regions (ta ctx.thread 2) = some ⟨.thread, 4 * (D.tiles * (2 * D.bits)), 4⟩ := by rw [hreg]; exact hS.t2 _
  have hr3 : sh.regions (ta ctx.thread 3) = some ⟨.thread, 4 * D.tiles, 4⟩ := by rw [hreg]; exact hS.t3 _
  have hr4 : sh.regions (ta ctx.thread 4) = some ⟨.thread, 4 * D.tiles, 4⟩ := by rw [hreg]; exact hS.t4 _
  have hr6 : sh.regions (ta ctx.thread 6) = some ⟨.thread, 8, 8⟩ := by rw [hreg]; exact hS.t6 _
  generalize hl1 : setLocal l 38 (.ptr ⟨if false = true then ctx.groupArray 6 else ctx.threadArray 6, 0, .vec .f32 2⟩) = l₁
  have h38 : l₁ 38 = some (.ptr ⟨ta ctx.thread 6, 0, .vec .f32 2⟩) := by rw [← hl1, setLocal_same, hl.ta]; rfl
  have ag1 : ∀ j, j < 38 → l₁ j = l j := fun j hj => by rw [← hl1, setLocal_other _ _ (by omega)]
  obtain ⟨l₂, hag2, hc2⟩ := exec_unitElement C (ctx := ctx) hok 41 0 (.inl rfl) (by norm_num) (.local 35) (vv := v) (by omega) ht hq
    (fun l' hag => eval_local' C ((hag 35 (by omega)).trans ((ag1 35 (by omega)).trans hloc.l35)) _)
    ((ag1 23 (by omega)).trans hst.l23) ((ag1 24 (by omega)).trans hst.l24) ((ag1 25 (by omega)).trans hst.l25)
    ((ag1 37 (by omega)).trans h37) h38 hr2 hr3 hr4 hr6 hT.q hT.s2 hT.b2
  generalize hsh2 : tput sh (ta ctx.thread 6) (4 * 0) _ = sh₂ at hc2
  have hv2 : ∀ j, j ≠ 6 → tview sh₂ ctx.thread j = tview sh ctx.thread j := fun j hj => by
    rw [← hsh2, tview_tput (by decide)]; simp [hj]
  have hT2 : TAt C D I nb mb s i k v t (tview sh₂ ctx.thread) := hT.of_eq fun j hj => hv2 j (by omega)
  have ag2 : ∀ j, j < 39 → l₂ j = l₁ j := fun j hj => hag2 j (by omega)
  obtain ⟨l₃, hag3, hc3⟩ := exec_unitElement C (ctx := ctx) (sh := sh₂) hok 49 1 (.inr rfl) (by norm_num)
    (AffineSplitMma.u32 .add (.local 35) (u32l 32)) (vv := v + 32) (by omega) ht hq
    (fun l' hag => eval_bin_u32 C (eval_local' C ((hag 35 (by omega)).trans ((ag2 35 (by omega)).trans
      ((ag1 35 (by omega)).trans hloc.l35))) _) (eval_u32lit C _ _ 32 (by norm_num)) (binary_add_u32 C v 32))
    ((ag2 23 (by omega)).trans ((ag1 23 (by omega)).trans hst.l23))
    ((ag2 24 (by omega)).trans ((ag1 24 (by omega)).trans hst.l24))
    ((ag2 25 (by omega)).trans ((ag1 25 (by omega)).trans hst.l25))
    ((ag2 37 (by omega)).trans ((ag1 37 (by omega)).trans h37)) ((ag2 38 (by omega)).trans h38)
    (by rw [← hsh2]; exact hr2) (by rw [← hsh2]; exact hr3) (by rw [← hsh2]; exact hr4) (by rw [← hsh2]; exact hr6)
    hT2.q hT2.s2 hT2.b2
  generalize hsh3 : tput sh₂ (ta ctx.thread 6) (4 * 1) _ = sh₃ at hc3
  have hv3 : ∀ j, j ≠ 6 → tview sh₃ ctx.thread j = tview sh ctx.thread j := fun j hj => by
    rw [← hsh3, tview_tput (by decide)]; simp [hj, hv2 j hj]
  have ag3 : ∀ j, j < 38 → l₃ j = l j := fun j hj =>
    (hag3 j (by omega)).trans ((ag2 j (by omega)).trans (ag1 j hj))
  have h38' : l₃ 38 = some (.ptr ⟨ta ctx.thread 6, 0, .vec .f32 2⟩) := (hag3 38 (by omega)).trans ((ag2 38 (by omega)).trans h38)
  have hm3 : Mem C L D I nb mb P ge pw sh₃ := by
    rw [← hsh3, ← hsh2]; exact (hm.tput _ _ (by unfold ta; omega)).tput _ _ (by unfold ta; omega)
  have hoth : ∀ th', th' ≠ ctx.thread → tview sh₃ th' = tview sh th' := fun th' h => by
    rw [← hsh3, ← hsh2, tview_tput_thread h (by decide), tview_tput_thread h (by decide)]
  -- the operands
  have ha : (eval C ctx l₃ (.load (.vec .f32 2) (.local 38))).run sh₃ =
      some (.vec .f32 [.f32 (aRegs C D I nb s t k v i 0), .f32 (aRegs C D I nb s t k v i 1)], sh₃) := by
    rw [eval_load C ctx l₃ _ _ _ sh₃ sh₃ (eval_local' C h38' sh₃)]
    refine load_pair ctx sh₃ (ta ctx.thread 6) 0 8 _ _ _ (by rw [← hsh3, ← hsh2]; exact hr6) (by norm_num) (by norm_num) ?_
    rw [← hsh3, ← hsh2, tput_same, tput_same, Nat.mul_zero, Nat.mul_one, cells_pair_writes]
    rfl
  have hbx : (eval C ctx l₃ (.load (.vec .f32 2) (.local 36))).run sh₃ =
      some (.vec .f32 [.f32 (bRegs C D I mb s k v i 0), .f32 (bRegs C D I mb s k v i 1)], sh₃) := by
    rw [eval_load C ctx l₃ _ _ _ sh₃ sh₃ (eval_local' C ((ag3 36 (by omega)).trans hloc.l36) sh₃)]
    refine load_pair ctx sh₃ (ta ctx.thread 5) 0 8 _ _ _ (by rw [← hsh3, ← hsh2]; show sh.regions _ = _; rw [hreg]; exact hS.t5 _) (by norm_num)
      (by norm_num) ?_
    have := hT.bx
    unfold BxOk at this
    rw [← tview_lt (by decide), hv3 5 (by decide)]
    exact this
  have hacc : (eval C ctx l₃ (.load (.vec .f32 2) (.offset (.local 18) (.local 37)))).run sh₃ =
      some (.vec .f32 [.f32 (accAt C D I nb mb s t (32 * k + v) i 0), .f32 (accAt C D I nb mb s t (32 * k + v) i 1)],
        sh₃) := by
    have hp := eval_offset_u32 C (ctx := ctx) (o := 0) (eval_local' C ((ag3 18 (by omega)).trans hst.fix.l18) sh₃)
      (eval_local' C ((ag3 37 (by omega)).trans h37) sh₃) (by have := hok.tiles_lt13; omega)
    rw [show 0 + t * (Ty.vec .f32 2).bytes = 8 * t by show 0 + t * 8 = 8 * t; ring, hl.ta] at hp
    rw [eval_load C ctx l₃ _ _ _ sh₃ sh₃ hp]
    refine load_pair ctx sh₃ (ta ctx.thread 1) (8 * t) (8 * D.tiles) _ _ _ (by rw [← hsh3, ← hsh2]; show sh.regions _ = _; rw [hreg]; exact hS.t1 _)
      (by omega) (by omega) ?_
    have := hT.acc t ht
    simp only [lt_irrefl, ite_false, Nat.add_zero] at this
    rw [← tview_lt (by decide), hv3 1 (by decide)]
    exact this
  have he := eval_vector C (s := .f32) (evalList_cons C ha (evalList_cons C hbx (evalList_cons C hacc (evalList_nil C))))
  have hcoll : Exec C ctx [.collective 1 55 (.mma .f32 .f32) .f32 mmaE (u16l 0), accStore] l₃ sh₃
      (.stop (.collective 1 55 (.mma .f32 .f32) .f32 (xval C D I nb mb s i k v t) 0) [.block [accStore]]) l₃ sh₃ :=
    .collective he (eval_lit C _ _ _ _) (natOf_unsigned 0 rfl)
  refine ⟨l₃, sh₃, ?_, ⟨hloc.of_eq fun j hj => ag3 j (by omega), (ag3 37 (by omega)).trans h37, h38'⟩, hm3, hoth,
    fun j hj => hv3 j (by omega)⟩
  rw [tileBody_eq]
  exact .array (by rw [hl1]; exact hc2 (hc3 hcoll))

end Tile
end Metal.Kernels.SplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

theorem tview_tput_at {sh : Shared} {th j o : Nat} {bs : List (BitVec 8)} (hj : j < 7) (j' : Nat) :
    tview (tput sh (ta th j) o bs) th j' = if j' = j then writeBytes (tview sh th j) o bs else tview sh th j' := by
  rw [tview_tput hj]

section Init
variable (C : M1Max.Contract) {L : Launch} {A : Al} {I : In} {P ge : Nat} {pw : Nat → Nat → Nat → Prop} {ctx : Ctx}
  {D : Dims} {nb mb s i : Nat}

/-- `wRow[t]` and `acc[t] = 0` for every tile. -/
theorem exec_init (hS : Shape L D A) (hok : Ok D) (hl : Lane D ctx nb mb s i) {l : Locals} {sh : Shared}
    (hF : Fix D ctx nb mb s i l) (hm : Mem C L D I nb mb P ge pw sh) :
    ∃ l' sh', Exec C ctx (initFor D) l sh .normal l' sh' ∧ Fix D ctx nb mb s i l' ∧ l' 19 = some (u32 D.tiles) ∧
      Mem C L D I nb mb P ge pw sh' ∧ (∀ th', th' ≠ ctx.thread → tview sh' th' = tview sh th') ∧
      (∀ j, 2 ≤ j → tview sh' ctx.thread j = tview sh ctx.thread j) ∧
      WRowOk D nb (fmOf i) (tview sh' ctx.thread) ∧ AccOk D (fun _ _ => zero) (tview sh' ctx.thread) := by
  have hT := hok.tiles_lt; have hT13 := hok.tiles_lt13
  have hfm := fm_lt i
  have hnb := n0_lt hl.hnb
  have hN := hok.Nle
  let J : Nat → Locals → Shared → Prop := fun k l' sh' => Fix D ctx nb mb s i l' ∧ l' 19 = some (u32 (0 + 1 * k)) ∧
    Mem C L D I nb mb P ge pw sh' ∧ (∀ th', th' ≠ ctx.thread → tview sh' th' = tview sh th') ∧
    (∀ j, 2 ≤ j → tview sh' ctx.thread j = tview sh ctx.thread j) ∧
    (∀ t < k, cells (tview sh' ctx.thread 0) (8 * t) 8 = wordBytes 8 (wrowWord D nb (fmOf i) t)) ∧
    (∀ t < k, cells (tview sh' ctx.thread 1) (8 * t) 8 = pairBytes zero zero)
  have hbody : ∀ k < D.tiles, ∀ l₀ sh₀, J k l₀ sh₀ → ∃ o l₁ sh₁, (o = .normal ∨ o = .continue_) ∧
      Exec C ctx [wrowStore, accInit] l₀ sh₀ o l₁ sh₁ ∧ l₁ 19 = some (u32 (0 + 1 * k)) ∧
      J (k + 1) (setLocal l₁ 19 (u32 (0 + 1 * (k + 1)))) sh₁ := by
    intro k hk l₀ sh₀ hJk
    obtain ⟨hF0, h19, hm0, hoth, hhi, hw0, ha0⟩ := hJk
    have h19' : l₀ 19 = some (u32 k) := by rw [h19, Nat.zero_add, Nat.one_mul]
    have hp1 := eval_offset_u32 C (ctx := ctx) (o := 0) (eval_local' C hF0.l17 sh₀) (eval_local' C h19' sh₀) (by omega)
    rw [show 0 + k * (Ty.ptr .device (.scalar .u32)).bytes = 8 * k by show 0 + k * 8 = 8 * k; ring, hl.ta] at hp1
    have hn : (eval C ctx l₀ (AffineSplitMma.u32 .add (AffineSplitMma.u32 .add (.local 11)
        (AffineSplitMma.u32 .mul (u32l 8) (.local 19))) (.local 8))).run sh₀ = some (u32 (nOf D nb i k), sh₀) :=
      eval_bin_u32 C (eval_bin_u32 C (eval_local' C hF0.l11 sh₀) (eval_bin_u32 C (eval_u32lit C _ _ 8 (by norm_num))
        (eval_local' C h19' sh₀) (binary_mul_u32 C 8 k)) (binary_add_u32 C _ _)) (eval_local' C hF0.l8 sh₀)
        (binary_add_u32 C _ _)
    have hnlt : nOf D nb i k < D.N := by unfold nOf; omega
    have hw := rowWords_lt hok hnlt
    have h64 := eval_mul_u64 C (site := 0) (eval_mul_u64 C (site := 0) (eval_toU64 C hn (by omega))
      (eval_toU64 C (eval_local' C hF0.l13 sh₀) (by have := hok.Kle; omega)))
      (eval_toU64 C (eval_local' C hF0.l14 sh₀) (by have := hok.bits; omega))
    have hv1 := eval_offset_u64 C (o := 0) (eval_local' C hF0.l2 sh₀) h64 (lt_trans hw (by norm_num))
    rw [show 0 + nOf D nb i k * (D.K / 64) * (2 * D.bits) * (Ty.scalar .u32).bytes =
      4 * (nOf D nb i k * (D.K / 64) * (2 * D.bits)) by simp only [Ty.bytes, Scalar.bytes]; ring] at hv1
    have hs1 := store_t ctx (.ptr .device (.scalar .u32)) (.ptr .device (.scalar .u32)) sh₀ (ta ctx.thread 0) (8 * k)
      (8 * D.tiles) 8 _ _ (by rw [hm0.regions]; exact hS.t0 _) (by simp [alignment, Ty.bytes]) (by simp [alignment, Ty.bytes])
      (by simp only [Ty.bytes]; omega) (encode_ptr (r := 2) (by norm_num)
        (lt_trans (show 4 * (nOf D nb i k * (D.K / 64) * (2 * D.bits)) < 2 ^ 32 by omega) (by norm_num)))
    generalize hsh1 : tput sh₀ (ta ctx.thread 0) (8 * k) _ = sh₁ at hs1
    have hp2 := eval_offset_u32 C (ctx := ctx) (o := 0) (sh := sh₁) (eval_local' C hF0.l18 sh₁) (eval_local' C h19' sh₁)
      (by omega)
    rw [show 0 + k * (Ty.vec .f32 2).bytes = 8 * k by show 0 + k * 8 = 8 * k; ring, hl.ta] at hp2
    have hv2 : (eval C ctx l₀ (.vector .f32 [f32l 0x0, f32l 0x0])).run sh₁ = some (.vec .f32 [.f32 zero, .f32 zero], sh₁) :=
      eval_vector C (evalList_cons C (eval_lit C _ _ _ _) (evalList_cons C (eval_lit C _ _ _ _) (evalList_nil C)))
    have hs2 := store_t ctx (.vec .f32 2) (.vec .f32 2) sh₁ (ta ctx.thread 1) (8 * k) (8 * D.tiles) 8 _ _
      (by rw [← hsh1]; show sh₀.regions _ = _; rw [hm0.regions]; exact hS.t1 _) (by simp [alignment, Ty.bytes, Scalar.bytes])
      (by simp [alignment, Ty.bytes, Scalar.bytes]) (by show 8 * k + 8 ≤ 8 * D.tiles; omega) (encode_pair zero zero)
    generalize hsh2 : tput sh₁ (ta ctx.thread 1) (8 * k) (pairBytes zero zero) = sh₂ at hs2
    have e1 : Exec C ctx [accInit] l₀ sh₁ .normal l₀ sh₂ := .store hp2 hv2 hs2 (.nil _ _)
    have e0 : Exec C ctx [wrowStore, accInit] l₀ sh₀ .normal l₀ sh₂ := .store hp1 hv1 hs1 e1
    refine ⟨.normal, l₀, sh₂, .inl rfl, e0, h19, hF0.set _ (by omega),
      setLocal_same _ _ _, ?_, ?_, ?_, ?_, ?_⟩
    · rw [← hsh2, ← hsh1]; exact (hm0.tput _ _ (by unfold ta; omega)).tput _ _ (by unfold ta; omega)
    · intro th' h; rw [← hsh2, ← hsh1, tview_tput_thread h (by decide), tview_tput_thread h (by decide)]; exact hoth th' h
    · intro j hj
      rw [← hsh2, ← hsh1, tview_tput_at (by decide), ite_eq_right (by omega), tview_tput_at (by decide), ite_eq_right (by omega)]
      exact hhi j hj
    · intro t ht
      rw [← hsh2, ← hsh1, tview_tput_at (by decide), ite_eq_right (by decide), tview_tput_at (by decide), ite_eq_left rfl]
      by_cases htk : t = k
      · subst htk; exact cells_writeBytes_of_length _ _ _ _ (wordBytes_length 8 _)
      · rw [cells_writeBytes_other _ _ _ _ _ (by rw [wordBytes_length]; omega)]; exact hw0 t (by omega)
    · intro t ht
      rw [← hsh2, ← hsh1, tview_tput_at (by decide), ite_eq_left rfl, tview_tput_at (by decide), ite_eq_right (by decide)]
      by_cases htk : t = k
      · subst htk; exact cells_writeBytes_of_length _ _ _ _ (pairBytes_length _ _)
      · rw [cells_writeBytes_other _ _ _ _ _ (by rw [pairBytes_length]; omega)]; exact ha0 t (by omega)
  obtain ⟨l', sh', hloop, hJ⟩ := exec_count C (ctx := ctx) 19 1 D.tiles D.tiles 0 (u32l D.tiles) [wrowStore, accInit] J
    (by omega) (by norm_num) (fun k _ => by omega) (by omega)
    (fun k _ l' sh' hk => ⟨hk.2.1, eval_u32lit C _ _ _ (by omega)⟩) hbody (l := setLocal l 19 (u32 0)) (sh := sh)
    ⟨hF.set _ (by omega), setLocal_same _ _ _, hm, fun _ _ => rfl, fun _ _ => rfl, fun t ht => absurd ht (by omega),
      fun t ht => absurd ht (by omega)⟩
  obtain ⟨hF', h19, hm', hoth, hhi, hw, ha⟩ := hJ
  exact ⟨l', sh', .set (eval_u32lit C _ _ 0 (by norm_num)) hloop, hF', by rw [h19, Nat.zero_add, Nat.one_mul], hm', hoth,
    hhi, hw, ha⟩

end Init
end Metal.Kernels.SplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

/-- The locals of K step `k` before `xa` and `xb`. -/
structure ScaleLoc (D : Dims) (ctx : Ctx) (nb mb s i k : Nat) (l : Locals) : Prop where
  fix : Fix D ctx nb mb s i l
  l19 : l 19 = some (u32 D.tiles)
  l20 : l 20 = some (u32 (stepOf D s k))
  l21 : l 21 = some (u32 (256 * stepOf D s k))
  l22 : l 22 = some (u32 (gOf D s i k))
  l23 : l 23 = some (.ptr ⟨ta ctx.thread 2, 0, .scalar .u32⟩)
  l24 : l 24 = some (.ptr ⟨ta ctx.thread 3, 0, .scalar .f32⟩)
  l25 : l 25 = some (.ptr ⟨ta ctx.thread 4, 0, .scalar .f32⟩)

theorem Ok.kbits {D : Dims} (hok : Ok D) : D.K * D.bits / 32 = D.K / 64 * (2 * D.bits) := by
  obtain ⟨m, hm⟩ : ∃ m, D.K = 64 * m := ⟨D.K / 64, by have := hok.K; omega⟩
  rw [hm, Nat.mul_div_cancel_left m (by norm_num), show 64 * m * D.bits = 32 * (m * (2 * D.bits)) by ring,
    Nat.mul_div_cancel_left _ (by norm_num)]

theorem gOf_lt {D : Dims} {s i k : Nat} (hok : Ok D) (hk : stepOf D s k < D.K / 256) : gOf D s i k < D.K / 64 := by
  have := fn_lt i; unfold gOf; have := hok.K; omega

theorem nOf_lt {D : Dims} {nb i t : Nat} (_hok : Ok D) (hnb : nb < gy D) (ht : t < D.tiles) : nOf D nb i t < D.N := by
  have := n0_lt hnb; have := fm_lt i; unfold nOf; omega

section Scale
variable (C : M1Max.Contract) {L : Launch} {A : Al} {I : In} {P ge : Nat} {pw : Nat → Nat → Nat → Prop} {ctx : Ctx}
  {D : Dims} {nb mb s i : Nat}

/-- The `q[t]` loop of tile `t`: word `j` of the tile's group for every `j < 2·BITS`. -/
theorem exec_words (hS : Shape L D A) (hok : Ok D) (hl : Lane D ctx nb mb s i) {k t : Nat}
    (hk : stepOf D s k < D.K / 256) (ht : t < D.tiles) {l : Locals} {sh : Shared}
    (hF : Fix D ctx nb mb s i l) (h22 : l 22 = some (u32 (gOf D s i k)))
    (h23 : l 23 = some (.ptr ⟨ta ctx.thread 2, 0, .scalar .u32⟩)) (h26 : l 26 = some (u32 t))
    (hm : Mem C L D I nb mb P ge pw sh) (hW : WRowOk D nb (fmOf i) (tview sh ctx.thread))
    (hQ : ∀ t' < D.tiles, ∀ j < 2 * D.bits, t' < t →
      cells (tview sh ctx.thread 2) (4 * (t' * (2 * D.bits) + j)) 4 = wordBytes 4 (qOf D I nb s i k t' j)) :
    ∃ l' sh', Exec C ctx (forU 28 (.local 14) [.store (.scalar .u32) (.offset (row 23 (.local 26) (2 * D.bits)) (.local 28))
        (.load (.scalar .u32) (.offset (.load (.ptr .device (.scalar .u32)) (.offset (.local 17) (.local 26)))
          (AffineSplitMma.u32 .add (AffineSplitMma.u32 .mul (.local 22) (.local 14)) (.local 28))))]) l sh .normal l' sh' ∧
      (∀ j, j ≠ 28 → l' j = l j) ∧ Mem C L D I nb mb P ge pw sh' ∧
      (∀ th', th' ≠ ctx.thread → tview sh' th' = tview sh th') ∧
      (∀ j, j ≠ 2 → tview sh' ctx.thread j = tview sh ctx.thread j) ∧
      (∀ t' < D.tiles, ∀ j < 2 * D.bits, t' < t + 1 →
        cells (tview sh' ctx.thread 2) (4 * (t' * (2 * D.bits) + j)) 4 = wordBytes 4 (qOf D I nb s i k t' j)) := by
  have hB8 := hok.bits_le; have hT13 := hok.tiles_lt13; have hN := hok.Nle; have hK := hok.Kle
  have hn := nOf_lt (i := i) hok hl.hnb ht
  have hg := gOf_lt (i := i) hok hk
  have hreg := hm.regions
  have hWt := hW t ht
  rw [tview_lt (by decide)] at hWt
  have hwp : ∀ (l' : Locals) (sh' : Shared), l' 17 = l 17 → l' 26 = l 26 →
      sh'.regions = sh.regions → sh'.bytes (ta ctx.thread 0) = sh.bytes (ta ctx.thread 0) →
      (eval C ctx l' (.load (.ptr .device (.scalar .u32)) (.offset (.local 17) (.local 26)))).run sh' =
        some (.ptr ⟨2, ((4 * (nOf D nb i t * (D.K / 64) * (2 * D.bits)) : Nat) : Int), .scalar .u32⟩, sh') := by
    intro l' sh' e17 e26 er eb
    have hp := eval_offset_u32 C (ctx := ctx) (o := 0) (sh := sh') (eval_local' C (e17.trans hF.l17) sh')
      (eval_local' C (e26.trans h26) sh') (by omega)
    rw [show 0 + t * (Ty.ptr .device (.scalar .u32)).bytes = 8 * t by show 0 + t * 8 = 8 * t; ring, hl.ta] at hp
    rw [eval_load C ctx l' _ _ _ sh' sh' hp]
    refine load_t ctx _ _ sh' (ta ctx.thread 0) (8 * t) (8 * D.tiles) 8 _ (by rw [er, hreg]; exact hS.t0 _)
      (by simp [alignment, Ty.bytes]) (by simp [alignment, Ty.bytes]) (by show 8 * t + 8 ≤ 8 * D.tiles; omega) ?_
    rw [show (Ty.ptr .device (.scalar .u32)).bytes = 8 from rfl, eb, hWt]
    exact decode_ptr (by norm_num) (lt_trans (show 4 * (nOf D nb i t * (D.K / 64) * (2 * D.bits)) < 2 ^ 32 by
      have := rowWords_lt hok hn; omega) (by norm_num)) _ _
  let Q : Nat → Locals → Shared → Prop := fun j' l' sh' => (∀ j, j ≠ 28 → l' j = l j) ∧ l' 28 = some (u32 (0 + 1 * j')) ∧
    Mem C L D I nb mb P ge pw sh' ∧ (∀ th', th' ≠ ctx.thread → tview sh' th' = tview sh th') ∧
    (∀ j, j ≠ 2 → tview sh' ctx.thread j = tview sh ctx.thread j) ∧
    (∀ t' < D.tiles, ∀ j < 2 * D.bits, (t' < t ∨ (t' = t ∧ j < j')) →
      cells (tview sh' ctx.thread 2) (4 * (t' * (2 * D.bits) + j)) 4 = wordBytes 4 (qOf D I nb s i k t' j))
  have hbody : ∀ j' < 2 * D.bits, ∀ l₀ sh₀, Q j' l₀ sh₀ → ∃ o l₁ sh₁, (o = .normal ∨ o = .continue_) ∧
      Exec C ctx [.store (.scalar .u32) (.offset (row 23 (.local 26) (2 * D.bits)) (.local 28))
        (.load (.scalar .u32) (.offset (.load (.ptr .device (.scalar .u32)) (.offset (.local 17) (.local 26)))
          (AffineSplitMma.u32 .add (AffineSplitMma.u32 .mul (.local 22) (.local 14)) (.local 28))))] l₀ sh₀ o l₁ sh₁ ∧
      l₁ 28 = some (u32 (0 + 1 * j')) ∧ Q (j' + 1) (setLocal l₁ 28 (u32 (0 + 1 * (j' + 1)))) sh₁ := by
    intro j' hj' l₀ sh₀ hQ0
    obtain ⟨ag, h28, hm0, hoth, hv0, hq0⟩ := hQ0
    have h28' : l₀ 28 = some (u32 j') := by rw [h28, Nat.zero_add, Nat.one_mul]
    -- the destination
    have hrow := eval_offset_u64 C (ctx := ctx) (o := 0) (sh := sh₀) (n := t * (2 * D.bits)) (eval_local' C ((ag 23 (by omega)).trans h23) sh₀)
      (eval_mul_u64 C (site := 0) (eval_toU64 C (eval_local' C ((ag 26 (by omega)).trans h26) sh₀) (by omega))
        (eval_u64lit C _ _ _ (by omega))) (by have : t * (2 * D.bits) ≤ t * 8 := Nat.mul_le_mul_left t hB8; omega)
    have hdst := eval_offset_u32 C hrow (eval_local' C h28' sh₀) (by omega)
    rw [show 0 + t * (2 * D.bits) * (Ty.scalar .u32).bytes + j' * (Ty.scalar .u32).bytes =
      4 * (t * (2 * D.bits) + j') by simp only [Ty.bytes, Scalar.bytes]; ring] at hdst
    -- the source
    have hidx := eval_bin_u32 C (ctx := ctx) (op := .add) (site := 0) (eval_bin_u32 C (op := .mul) (site := 0)
      (eval_local' C ((ag 22 (by omega)).trans h22) sh₀) (eval_local' C ((ag 14 (by omega)).trans hF.l14) sh₀)
      (binary_mul_u32 C (gOf D s i k) (2 * D.bits))) (eval_local' C h28' sh₀) (binary_add_u32 C _ j')
    have hsrc := eval_offset_u32 C (hwp l₀ sh₀ (ag 17 (by omega)) (ag 26 (by omega)) (by rw [hm0.regions, hreg])
      (by rw [← tview_lt (by decide), hv0 0 (by decide), tview_lt (by decide)])) hidx
      (by have : gOf D s i k * (2 * D.bits) ≤ gOf D s i k * 8 := Nat.mul_le_mul_left _ hB8; omega)
    have hwi : gidx D (nOf D nb i t) (gOf D s i k) * (2 * D.bits) + j' < D.N * (D.K / 64) * (2 * D.bits) :=
      idx_lt (idx_lt hn hg) hj'
    rw [show 4 * (nOf D nb i t * (D.K / 64) * (2 * D.bits)) + (gOf D s i k * (2 * D.bits) + j') * (Ty.scalar .u32).bytes =
      4 * (gidx D (nOf D nb i t) (gOf D s i k) * (2 * D.bits) + j') by simp only [Ty.bytes, Scalar.bytes, gidx]; ring] at hsrc
    have hld := load_shared ctx .u32 sh₀ 2 (4 * (gidx D (nOf D nb i t) (gOf D s i k) * (2 * D.bits) + j')) _
      (by rw [hm0.regions]; exact hS.r2) (by simp) (by simpa [Scalar.bytes] using hS.aw) (by simp [Scalar.bytes])
      (by simp only [Scalar.bytes]; rw [hok.kbits]; have := hwi; rw [Nat.mul_assoc] at this; omega)
      (by simp [loadOffset])
    rw [hm0.w, show Scalar.u32.bytes = 4 from rfl] at hld
    have hval := (eval_load C ctx l₀ _ _ _ sh₀ sh₀ hsrc).trans hld
    have hst := store_t ctx (.scalar .u32) (.scalar .u32) (rdn ctx sh₀ 2 (4 * (gidx D (nOf D nb i t) (gOf D s i k) * (2 * D.bits) + j')) 4) (ta ctx.thread 2) (4 * (t * (2 * D.bits) + j'))
      (4 * (D.tiles * (2 * D.bits))) 4 (u32 (qOf D I nb s i k t j')) _ (by rw [rdn_regions, hm0.regions]; exact hS.t2 _)
      (by simp [alignment, Scalar.bytes]) (by simp [alignment, Scalar.bytes])
      (by simp only [Ty.bytes, Scalar.bytes]; have := idx_lt ht hj'; omega)
      (encode_u32 _ (bytesWord_cells_lt _ _))
    refine ⟨.normal, l₀, _, .inl rfl, .store hdst hval hst (.nil _ _), h28, fun j hj => ?_, setLocal_same _ _ _,
      ((hm0.rd hS ctx 2 _ 4 (.inl (by decide))).tput (reg := ta ctx.thread 2) _ _ (by unfold ta; omega)), fun th' h => ?_, fun j hj => ?_,
      fun t' ht' j hj hc => ?_⟩
    · rw [setLocal_other _ _ hj]; exact ag j hj
    · rw [tview_tput_thread h (by decide)]; exact hoth th' h
    · rw [tview_tput_at (by decide), ite_eq_right hj]; exact hv0 j hj
    · rw [tview_tput_at (by decide), ite_eq_left rfl]
      by_cases hc' : t' = t ∧ j = j'
      · obtain ⟨rfl, rfl⟩ := hc'
        exact cells_writeBytes_of_length _ _ _ _ (wordBytes_length 4 _)
      · have hne : t' * (2 * D.bits) + j ≠ t * (2 * D.bits) + j' := fun h =>
          hc' (idx_inj (by omega) (by omega) h)
        rw [cells_writeBytes_other _ _ _ _ _ (by rw [wordBytes_length]; omega)]
        exact hq0 t' ht' j hj (by omega)
  obtain ⟨l', sh', hloop, hQ'⟩ := exec_count C (ctx := ctx) 28 1 (2 * D.bits) (2 * D.bits) 0 (.local 14) _ Q
    (by omega) (by norm_num) (fun k _ => by omega) (by omega)
    (fun k _ l' sh' hq => ⟨hq.2.1, eval_local' C ((hq.1 14 (by omega)).trans hF.l14) _⟩) hbody
    (l := setLocal l 28 (u32 0)) (sh := sh)
    ⟨fun j hj => setLocal_other _ _ hj, setLocal_same _ _ _, hm, fun _ _ => rfl, fun _ _ => rfl,
      fun t' ht' j hj hc => hQ t' ht' j hj (by omega)⟩
  obtain ⟨ag, -, hm', hoth, hv, hq⟩ := hQ'
  exact ⟨l', sh', .set (eval_u32lit C _ _ 0 (by norm_num)) hloop, fun j hj => ag j hj,
    hm', hoth, hv, fun t' ht' j hj hc => hq t' ht' j hj (by omega)⟩

theorem scaleBody_eq (bits : Nat) : scaleBody bits =
    [.set 27 (AffineSplitMma.u64 .add (AffineSplitMma.u64 .mul (toU64 (AffineSplitMma.u32 .add
      (AffineSplitMma.u32 .add (.local 11) (AffineSplitMma.u32 .mul (u32l 8) (.local 26))) (.local 8)))
       (toU64 (.local 13))) (toU64 (.local 22))),
     .store (.scalar .f32) (.offset (.local 24) (.local 26))
       (.bin .mul .f32 0 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 3) (.local 27)))) (f32l (pow2Bits bits))),
     .store (.scalar .f32) (.offset (.local 25) (.local 26))
       (.bin .sub .f32 0 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 4) (.local 27))))
         (.load (.scalar .f32) (.offset (.local 24) (.local 26))))] ++
    forU 28 (.local 14) [.store (.scalar .u32) (.offset (row 23 (.local 26) (2 * bits)) (.local 28))
        (.load (.scalar .u32) (.offset (.load (.ptr .device (.scalar .u32)) (.offset (.local 17) (.local 26)))
          (AffineSplitMma.u32 .add (AffineSplitMma.u32 .mul (.local 22) (.local 14)) (.local 28))))] := rfl

theorem Ok.groups_lt {D : Dims} (hok : Ok D) : D.N * (D.K / 64) < 2 ^ 26 := by
  have h1 : D.N ≤ 2 ^ 16 := by have := hok.Nle; omega
  have h2 : D.K / 64 ≤ 2 ^ 10 - 1 := by have := hok.Kle; omega
  exact lt_of_le_of_lt (Nat.mul_le_mul h1 h2) (by norm_num)

/-- A scale or bias of group `at`, as a float. -/
theorem eval_scale {L : Launch} {A : Al} (hS : Shape L D A) (hok : Ok D) {reg : Nat} (hreg : reg = 3 ∨ reg = 4)
    {X : ByteMemory.Bytes} {l : Locals} {sh : Shared} {ix : Nat} (hsh : sh.regions = L.regions) (hX : sh.bytes reg = X)
    (hp : l reg = some (.ptr ⟨reg, 0, .scalar .bf16⟩)) (h27 : l 27 = some (u64 ix)) (hat : ix < D.N * (D.K / 64)) :
    (eval C ctx l (.conv .f32 (.load (.scalar .bf16) (.offset (.local reg) (.local 27))))).run sh =
      some (.f32 (C.widen (bf X ix)), rdn ctx sh reg (2 * ix) 2) := by
  have hsm := hok.groups_lt
  have hp' := eval_offset_u64 C (ctx := ctx) (o := 0) (sh := sh) (r := reg) (e := .scalar .bf16) (eval_local' C hp sh)
    (eval_local' C h27 sh) (lt_trans hat (lt_trans hsm (by norm_num)))
  rw [show 0 + ix * (Ty.scalar .bf16).bytes = 2 * ix by simp only [Ty.bytes, Scalar.bytes]; ring] at hp'
  have hr : sh.regions reg = some ⟨.device, 2 * (D.N * (D.K / 64)), if reg = 3 then A.s else A.b⟩ := by
    rcases hreg with rfl | rfl
    · rw [hsh]; exact hS.r3
    · rw [hsh]; exact hS.r4
  have hal : (if reg = 3 then A.s else A.b) % Scalar.bf16.bytes = 0 := by
    rcases hreg with rfl | rfl
    · simpa [Scalar.bytes] using hS.as
    · simpa [Scalar.bytes] using hS.ab
  have hld := load_shared ctx .bf16 sh reg (2 * ix) _ hr (by simp) hal (by simp [Scalar.bytes])
    (by simp only [Scalar.bytes]; omega) (by simp [loadOffset])
  rw [hX, show Scalar.bf16.bytes = 2 from rfl] at hld
  exact eval_conv C ((eval_load C ctx l _ _ _ sh sh hp').trans hld) rfl

/-- The scales, biases and words of every tile at K step `k`. -/
theorem exec_scale (hS : Shape L D A) (hok : Ok D) (hl : Lane D ctx nb mb s i) {k : Nat}
    (hk : stepOf D s k < D.K / 256) {l : Locals} {sh : Shared} (hL : ScaleLoc D ctx nb mb s i k l)
    (hm : Mem C L D I nb mb P ge pw sh) (hW : WRowOk D nb (fmOf i) (tview sh ctx.thread)) :
    ∃ l' sh', Exec C ctx (forU 26 (u32l D.tiles) (scaleBody D.bits)) l sh .normal l' sh' ∧
      (∀ j, j ≤ 25 → l' j = l j) ∧ Mem C L D I nb mb P ge pw sh' ∧
      (∀ th', th' ≠ ctx.thread → tview sh' th' = tview sh th') ∧
      (∀ j, j ≠ 2 → j ≠ 3 → j ≠ 4 → tview sh' ctx.thread j = tview sh ctx.thread j) ∧
      QOk D (qOf D I nb s i k) (tview sh' ctx.thread) ∧
      FOk D 3 (fun t => s2v C D I (nOf D nb i t) (gOf D s i k)) (tview sh' ctx.thread) ∧
      FOk D 4 (fun t => b2v C D I (nOf D nb i t) (gOf D s i k)) (tview sh' ctx.thread) := by
  have hT13 := hok.tiles_lt13; have hN := hok.Nle; have hK := hok.Kle; have hB8 := hok.bits_le
  have hg := gOf_lt (i := i) hok hk
  let S : Nat → Locals → Shared → Prop := fun t l' sh' => (∀ j, j ≤ 25 → l' j = l j) ∧
    l' 26 = some (u32 (0 + 1 * t)) ∧ Mem C L D I nb mb P ge pw sh' ∧
    (∀ th', th' ≠ ctx.thread → tview sh' th' = tview sh th') ∧
    (∀ j, j ≠ 2 → j ≠ 3 → j ≠ 4 → tview sh' ctx.thread j = tview sh ctx.thread j) ∧
    (∀ t' < D.tiles, ∀ j < 2 * D.bits, t' < t →
      cells (tview sh' ctx.thread 2) (4 * (t' * (2 * D.bits) + j)) 4 = wordBytes 4 (qOf D I nb s i k t' j)) ∧
    (∀ t' < t, cells (tview sh' ctx.thread 3) (4 * t') 4 =
      wordBytes 4 (Val.f32Bits (s2v C D I (nOf D nb i t') (gOf D s i k)))) ∧
    (∀ t' < t, cells (tview sh' ctx.thread 4) (4 * t') 4 =
      wordBytes 4 (Val.f32Bits (b2v C D I (nOf D nb i t') (gOf D s i k))))
  have hbody : ∀ t < D.tiles, ∀ l₀ sh₀, S t l₀ sh₀ → ∃ o l₁ sh₁, (o = .normal ∨ o = .continue_) ∧
      Exec C ctx (scaleBody D.bits) l₀ sh₀ o l₁ sh₁ ∧ l₁ 26 = some (u32 (0 + 1 * t)) ∧
      S (t + 1) (setLocal l₁ 26 (u32 (0 + 1 * (t + 1)))) sh₁ := by
    intro t ht l₀ sh₀ hS0
    obtain ⟨ag, h26, hm0, hoth, hv0, hq0, hs0, hb0⟩ := hS0
    have h26' : l₀ 26 = some (u32 t) := by rw [h26, Nat.zero_add, Nat.one_mul]
    have hF0 : Fix D ctx nb mb s i l₀ := hL.fix.of_eq fun j hj => ag j (by omega)
    have hn := nOf_lt (i := i) hok hl.hnb ht
    have hat : gidx D (nOf D nb i t) (gOf D s i k) < D.N * (D.K / 64) := idx_lt hn hg
    have hnE : (eval C ctx l₀ (AffineSplitMma.u32 .add (AffineSplitMma.u32 .add (.local 11)
        (AffineSplitMma.u32 .mul (u32l 8) (.local 26))) (.local 8))).run sh₀ = some (u32 (nOf D nb i t), sh₀) :=
      eval_bin_u32 C (eval_bin_u32 C (eval_local' C hF0.l11 sh₀) (eval_bin_u32 C (eval_u32lit C _ _ 8 (by norm_num))
        (eval_local' C h26' sh₀) (binary_mul_u32 C 8 t)) (binary_add_u32 C _ _)) (eval_local' C hF0.l8 sh₀)
        (binary_add_u32 C _ _)
    have h27 := eval_add_u64 C (site := 0) (eval_mul_u64 C (site := 0) (eval_toU64 C hnE (by omega))
      (eval_toU64 C (eval_local' C hF0.l13 sh₀) (by omega)))
      (eval_toU64 C (eval_local' C ((ag 22 (by omega)).trans hL.l22) sh₀) (by omega))
    generalize hl1 : setLocal l₀ 27 (u64 (gidx D (nOf D nb i t) (gOf D s i k))) = l₁
    have ag1 : ∀ j, j ≠ 27 → l₁ j = l₀ j := fun j hj => by rw [← hl1, setLocal_other _ _ hj]
    have h1_27 : l₁ 27 = some (u64 (gidx D (nOf D nb i t) (gOf D s i k))) := by rw [← hl1, setLocal_same]
    have h1_26 : l₁ 26 = some (u32 t) := (ag1 26 (by omega)).trans h26'
    have hF1 : Fix D ctx nb mb s i l₁ := by rw [← hl1]; exact hF0.set _ (by omega)
    -- s2[t]
    have hs2v := eval_f32 C (ctx := ctx) (op := .mul) (site := 0) (.inl ⟨by decide, by decide⟩)
      (eval_scale C (ctx := ctx) hS hok (.inl rfl) hm0.regions hm0.s hF1.l3 h1_27 hat)
      (eval_lit C ctx l₁ (.f32 (Val.ofF32Bits (pow2Bits D.bits))) _) rfl
    have hp24 := eval_offset_u32 C (ctx := ctx) (o := 0) (sh := sh₀)
      (eval_local' C ((ag1 24 (by omega)).trans ((ag 24 (by omega)).trans hL.l24)) sh₀) (eval_local' C h1_26 sh₀)
      (by omega)
    rw [show 0 + t * (Ty.scalar .f32).bytes = 4 * t by simp only [Ty.bytes, Scalar.bytes]; ring] at hp24
    have hst2 := store_t ctx (.scalar .f32) (.scalar .f32) (rdn ctx sh₀ 3 (2 * gidx D (nOf D nb i t) (gOf D s i k)) 2)
      (ta ctx.thread 3) (4 * t) (4 * D.tiles) 4 (.f32 (s2v C D I (nOf D nb i t) (gOf D s i k))) _
      (by rw [rdn_regions, hm0.regions]; exact hS.t3 _) (by simp [alignment, Scalar.bytes])
      (by simp [alignment, Scalar.bytes]) (by simp only [Ty.bytes, Scalar.bytes]; omega) (encode_f32 _)
    generalize hsh1 : tput (rdn ctx sh₀ 3 (2 * gidx D (nOf D nb i t) (gOf D s i k)) 2) (ta ctx.thread 3) (4 * t)
      (wordBytes 4 (Val.f32Bits (s2v C D I (nOf D nb i t) (gOf D s i k)))) = sh₁ at hst2
    have hm1 : Mem C L D I nb mb P ge pw sh₁ := by
      rw [← hsh1]; exact (hm0.rd hS ctx 3 _ 2 (.inl (by decide))).tput (reg := ta ctx.thread 3) _ _ (by unfold ta; omega)
    -- b2[t]
    have hbias := eval_scale C (ctx := ctx) hS hok (.inr rfl) (sh := sh₁) hm1.regions hm1.b hF1.l4 h1_27 hat
    have hs2l : (eval C ctx l₁ (.load (.scalar .f32) (.offset (.local 24) (.local 26)))).run
        (rdn ctx sh₁ 4 (2 * gidx D (nOf D nb i t) (gOf D s i k)) 2) =
        some (.f32 (s2v C D I (nOf D nb i t) (gOf D s i k)), rdn ctx sh₁ 4 (2 * gidx D (nOf D nb i t) (gOf D s i k)) 2) := by
      have hp := eval_offset_u32 C (ctx := ctx) (o := 0) (sh := rdn ctx sh₁ 4 (2 * gidx D (nOf D nb i t) (gOf D s i k)) 2)
        (eval_local' C ((ag1 24 (by omega)).trans ((ag 24 (by omega)).trans hL.l24)) _) (eval_local' C h1_26 _) (by omega)
      rw [show 0 + t * (Ty.scalar .f32).bytes = 4 * t by simp only [Ty.bytes, Scalar.bytes]; ring] at hp
      refine (eval_load C ctx l₁ _ _ _ _ _ hp).trans (load_t ctx _ _ _ (ta ctx.thread 3) (4 * t) (4 * D.tiles) 4 _
        (by rw [rdn_regions, hm1.regions]; exact hS.t3 _) (by simp [alignment, Scalar.bytes])
        (by simp [alignment, Scalar.bytes]) (by simp only [Ty.bytes, Scalar.bytes]; omega) ?_)
      rw [rdn_bytes, ← hsh1, tput_same, show (Ty.scalar .f32).bytes = 4 from rfl,
        cells_writeBytes_of_length _ _ _ _ (wordBytes_length 4 _)]
      exact decode_f32_bytes _
    have hb2v := eval_f32 C (ctx := ctx) (op := .sub) (site := 0) (.inr ⟨rfl, rfl⟩) hbias hs2l rfl
    have hp25 := eval_offset_u32 C (ctx := ctx) (o := 0) (sh := sh₁)
      (eval_local' C ((ag1 25 (by omega)).trans ((ag 25 (by omega)).trans hL.l25)) sh₁) (eval_local' C h1_26 sh₁)
      (by omega)
    rw [show 0 + t * (Ty.scalar .f32).bytes = 4 * t by simp only [Ty.bytes, Scalar.bytes]; ring] at hp25
    have hst3 := store_t ctx (.scalar .f32) (.scalar .f32) (rdn ctx sh₁ 4 (2 * gidx D (nOf D nb i t) (gOf D s i k)) 2)
      (ta ctx.thread 4) (4 * t) (4 * D.tiles) 4 (.f32 (b2v C D I (nOf D nb i t) (gOf D s i k))) _
      (by rw [rdn_regions, hm1.regions]; exact hS.t4 _) (by simp [alignment, Scalar.bytes])
      (by simp [alignment, Scalar.bytes]) (by simp only [Ty.bytes, Scalar.bytes]; omega) (encode_f32 _)
    generalize hsh2 : tput (rdn ctx sh₁ 4 (2 * gidx D (nOf D nb i t) (gOf D s i k)) 2) (ta ctx.thread 4) (4 * t)
      (wordBytes 4 (Val.f32Bits (b2v C D I (nOf D nb i t) (gOf D s i k)))) = sh₂ at hst3
    have hm2 : Mem C L D I nb mb P ge pw sh₂ := by
      rw [← hsh2]; exact (hm1.rd hS ctx 4 _ 2 (.inl (by decide))).tput (reg := ta ctx.thread 4) _ _ (by unfold ta; omega)
    have hv1 : ∀ j, j ≠ 3 → tview sh₁ ctx.thread j = tview sh₀ ctx.thread j := fun j hj => by
      rw [← hsh1, tview_tput_at (by decide), ite_eq_right hj]; rfl
    have hv2 : ∀ j, j ≠ 4 → tview sh₂ ctx.thread j = tview sh₁ ctx.thread j := fun j hj => by
      rw [← hsh2, tview_tput_at (by decide), ite_eq_right hj]; rfl
    have hoth2 : ∀ th', th' ≠ ctx.thread → tview sh₂ th' = tview sh₀ th' := fun th' h => by
      rw [← hsh2, tview_tput_thread h (by decide), show tview (rdn ctx sh₁ 4 _ 2) th' = tview sh₁ th' from rfl, ← hsh1,
        tview_tput_thread h (by decide)]; rfl
    -- words
    obtain ⟨l₃, sh₃, hwx, ag3, hm3, hoth3, hv3, hq3⟩ := exec_words C hS hok hl hk ht (l := l₁) (sh := sh₂) hF1
      ((ag1 22 (by omega)).trans ((ag 22 (by omega)).trans hL.l22))
      ((ag1 23 (by omega)).trans ((ag 23 (by omega)).trans hL.l23)) h1_26 hm2
      (fun t' ht' => by rw [hv2 0 (by decide), hv1 0 (by decide), hv0 0 (by decide) (by decide) (by decide)]; exact hW t' ht')
      (fun t' ht' j hj hlt => by rw [hv2 2 (by decide), hv1 2 (by decide)]; exact hq0 t' ht' j hj hlt)
    refine ⟨.normal, l₃, sh₃, .inl rfl, ?_, by rw [ag3 26 (by omega), h1_26, Nat.zero_add, Nat.one_mul],
      fun j hj => ?_, setLocal_same _ _ _, hm3, fun th' h => ?_, fun j h2 h3 h4 => ?_, hq3, fun t' ht' => ?_,
      fun t' ht' => ?_⟩
    · rw [scaleBody_eq]
      exact .set h27 (by
        rw [show nOf D nb i t * (D.K / 64) + gOf D s i k = gidx D (nOf D nb i t) (gOf D s i k) from rfl, hl1]
        exact .store hp24 hs2v hst2 (.store hp25 hb2v hst3 hwx))
    · rw [setLocal_other _ _ (by omega), ag3 j (by omega), ag1 j (by omega)]; exact ag j hj
    · rw [hoth3 th' h, hoth2 th' h]; exact hoth th' h
    · rw [hv3 j h2, hv2 j h4, hv1 j h3]; exact hv0 j h2 h3 h4
    · rw [hv3 3 (by decide), hv2 3 (by decide), ← hsh1, tview_tput_at (by decide), ite_eq_left rfl]
      by_cases htt : t' = t
      · subst htt; exact cells_writeBytes_of_length _ _ _ _ (wordBytes_length 4 _)
      · rw [cells_writeBytes_other _ _ _ _ _ (by rw [wordBytes_length]; omega)]; exact hs0 t' (by omega)
    · rw [hv3 4 (by decide), ← hsh2, tview_tput_at (by decide), ite_eq_left rfl]
      by_cases htt : t' = t
      · subst htt; exact cells_writeBytes_of_length _ _ _ _ (wordBytes_length 4 _)
      · rw [cells_writeBytes_other _ _ _ _ _ (by rw [wordBytes_length]; omega),
          show tview (rdn ctx sh₁ 4 _ 2) ctx.thread 4 = tview sh₁ ctx.thread 4 from rfl, hv1 4 (by decide)]
        exact hb0 t' (by omega)
  obtain ⟨l', sh', hloop, hS'⟩ := exec_count C (ctx := ctx) 26 1 D.tiles D.tiles 0 (u32l D.tiles) _ S
    (by omega) (by norm_num) (fun k _ => by omega) (by omega)
    (fun k _ l' sh' hq => ⟨hq.2.1, eval_u32lit C _ _ _ (by omega)⟩) hbody (l := setLocal l 26 (u32 0)) (sh := sh)
    ⟨fun j hj => setLocal_other _ _ (by omega), setLocal_same _ _ _, hm, fun _ _ => rfl, fun _ _ _ _ => rfl,
      fun _ _ _ _ h => absurd h (by omega), fun _ h => absurd h (by omega), fun _ h => absurd h (by omega)⟩
  obtain ⟨ag, -, hm', hoth, hv, hq, hs2, hb2⟩ := hS'
  exact ⟨l', sh', .set (eval_u32lit C _ _ 0 (by norm_num)) hloop, ag, hm', hoth, hv,
    fun t ht j hj => hq t ht j hj ht, hs2, hb2⟩

end Scale
end Metal.Kernels.SplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

/-- The four elements of `x` a `vec<T, 4>` load reads, as `x4` holds them. -/
theorem x4_get (C : M1Max.Contract) (X : ByteMemory.Bytes) (o c : Nat) (hc : c < 4) :
    [Val.f32 (C.widen (bf X o)), .f32 (C.widen (bf X (o + 1))), .f32 (C.widen (bf X (o + 2))),
      .f32 (C.widen (bf X (o + 3)))][c]? = some (.f32 (C.widen (bf X (o + c)))) := by
  rcases (show c = 0 ∨ c = 1 ∨ c = 2 ∨ c = 3 by omega) with rfl | rfl | rfl | rfl <;> rfl

theorem decode_x4 (X : ByteMemory.Bytes) (o : Nat) :
    decode (.vec .bf16 4) (cells X (2 * o) 8) =
      some (.vec .bf16 [.bf16 (bf X o), .bf16 (bf X (o + 1)), .bf16 (bf X (o + 2)), .bf16 (bf X (o + 3))]) := by
  have e : ∀ j, j < 4 → Val.ofWord .bf16 (bytesWord (((cells X (2 * o) 8).drop (Scalar.bf16.bytes * j)).take
      Scalar.bf16.bytes)) = .bf16 (bf X (o + j)) := by
    intro j hj
    rw [show Scalar.bf16.bytes = 2 from rfl, cells_drop_take _ _ _ _ _ (by omega),
      show 2 * o + 2 * j = 2 * (o + j) by ring]
    rfl
  show (some (Val.vec .bf16 ((List.range 4).map (fun j => Val.ofWord .bf16
    (bytesWord (((cells X (2 * o) 8).drop (Scalar.bf16.bytes * j)).take Scalar.bf16.bytes))))) : Option Val) = _
  rw [show List.range 4 = [0, 1, 2, 3] from rfl]
  simp only [List.map_cons, List.map_nil]
  rw [e 0 (by norm_num), e 1 (by norm_num), e 2 (by norm_num), e 3 (by norm_num), Nat.add_zero]

section Col
variable (C : M1Max.Contract) {L : Launch} {A : Al} {I : In} {P ge : Nat} {pw : Nat → Nat → Nat → Prop} {ctx : Ctx}
  {D : Dims} {nb mb s : Nat}

/-- `float4(xa[s4])`: the load of `x` elements `o … o + 3` (`o` a multiple of 4, in bounds). -/
theorem eval_x4 {p : CExpr} {l : Locals} {sh : Shared} {o : Nat} (hS : Shape L D A) (hsh : sh.regions = L.regions)
    (hx : sh.bytes 0 = I.X) (hp : (eval C ctx l p).run sh = some (.ptr ⟨0, ((2 * o : Nat) : Int), .vec .bf16 4⟩, sh))
    (ho : o % 4 = 0) (hb : o + 4 ≤ D.r * D.K) :
    (eval C ctx l (.conv .f32 (.load (.vec .bf16 4) p))).run sh = some (x4 C I.X o, rdn ctx sh 0 (2 * o) 8) := by
  have hld := loadAt_run ctx (.vec .bf16 4) ⟨0, ((2 * o : Nat) : Int), .vec .bf16 4⟩ _ sh _ (by rw [hsh]; exact hS.r0)
    (by simp) (by simp) (by simpa [alignment, Ty.bytes, Scalar.bytes] using hS.ax)
    (by simp [loadOffset, alignment, Ty.bytes, Scalar.bytes]; omega)
    (by simp [loadOffset, Ty.bytes, Scalar.bytes]; omega)
    (by
      show decode (.vec .bf16 4) ((List.range 8).map fun i => sh.bytes 0 (loadOffset (.vec .bf16 4) _ (2 * o) + i)) = _
      rw [show loadOffset (.vec .bf16 4) ⟨.device, 2 * (D.r * D.K), A.x⟩ (2 * o) = 2 * o by simp [loadOffset], hx]
      exact decode_x4 I.X o)
  rw [show loadOffset (.vec .bf16 4) ⟨.device, 2 * (D.r * D.K), A.x⟩ (((2 * o : Nat) : Int)).toNat = 2 * o by
    simp [loadOffset]; omega] at hld
  exact eval_conv C ((eval_load C ctx l _ _ _ sh sh hp).trans hld) rfl

/-- A thread's arrays at value `v` of K step `k` before its `bx`. -/
structure TPre (C : M1Max.Contract) (D : Dims) (I : In) (nb mb s : Nat) (i : Fin 32) (k v : Nat)
    (V : Nat → ByteMemory.Bytes) : Prop where
  wrow : WRowOk D nb (fmOf i) V
  acc : AccOk D (fun t' j => accAt C D I nb mb s t' (32 * k + v) i j) V
  q : QOk D (qOf D I nb s i k) V
  s2 : FOk D 3 (fun t' => s2v C D I (nOf D nb i t') (gOf D s i k)) V
  b2 : FOk D 4 (fun t' => b2v C D I (nOf D nb i t') (gOf D s i k)) V

theorem TPre.of_eq {i : Fin 32} {k v : Nat} {V V' : Nat → ByteMemory.Bytes} (h : TPre C D I nb mb s i k v V)
    (h' : ∀ j < 5, V' j = V j) : TPre C D I nb mb s i k v V' := by
  obtain ⟨h1, h2, h3, h4, h5⟩ := h
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · intro t' ht'; rw [h' 0 (by omega)]; exact h1 t' ht'
  · intro t' ht'; rw [h' 1 (by omega)]; exact h2 t' ht'
  · intro t' ht' j hj; rw [h' 2 (by omega)]; exact h3 t' ht' j hj
  · intro t' ht'; rw [h' 3 (by omega)]; exact h4 t' ht'
  · intro t' ht'; rw [h' 4 (by omega)]; exact h5 t' ht'

theorem TPre.tat {i : Fin 32} {k v : Nat} {V : Nat → ByteMemory.Bytes} (h : TPre C D I nb mb s i k v V)
    (hb : BxOk (bRegs C D I mb s k v i 0) (bRegs C D I mb s k v i 1) V) : TAt C D I nb mb s i k v 0 V :=
  ⟨h.wrow, fun t' ht' => by simpa using h.acc t' ht', h.q, h.s2, h.b2, hb⟩

/-- The `s4`-level locals: the step's, `s4`, `va`, `vb`. -/
structure S4Loc (C : M1Max.Contract) (D : Dims) (I : In) (ctx : Ctx) (nb mb s i k s4 : Nat) (l : Locals) : Prop where
  step : StepLoc D ctx nb mb s i k l
  l31 : l 31 = some (u32 s4)
  l32 : l 32 = some (x4 C I.X (xoff D mb i (stepOf D s k) 0 + 4 * s4))
  l33 : l 33 = some (x4 C I.X (xoff D mb i (stepOf D s k) 1 + 4 * s4))

theorem bx_idx (D : Dims) (mb s k v : Nat) (i : Fin 32) (j : Nat) :
    xoff D mb i (stepOf D s k) j + 4 * (v / 4) + v % 4 =
      min (8 * mb + fnOf i + j) (D.r - 1) * D.K + 32 * fmOf i + 256 * stepOf D s k + v := by
  unfold xoff xbase; omega

/-- Column `c` of chunk `s4` (value `v = 4·s4 + c`): `v`, `bx`, then tile 0 up to its multiply-accumulate. -/
theorem exec_col (hS : Shape L D A) (hok : Ok D) {i : Fin 32} (hl : Lane D ctx nb mb s i) {k s4 c : Nat}
    (_hk : stepOf D s k < D.K / 256) (hs4 : s4 < 8) (hc : c < 4) {l : Locals} {sh : Shared}
    (hloc : S4Loc C D I ctx nb mb s i k s4 l) (h34 : l 34 = some (u32 c)) (hm : Mem C L D I nb mb P ge pw sh)
    (hT : TPre C D I nb mb s i k (4 * s4 + c) (tview sh ctx.thread)) :
    ∃ l' sh', Exec C ctx (columnBody D.bits D.tiles) l sh
        (.stop (.collective 1 55 (.mma .f32 .f32) .f32 (xval C D I nb mb s i k (4 * s4 + c) 0) 0)
          ([.block [accStore]] ++ [frameOf 37 (u32l D.tiles) 1 (tileBody D.bits), .block []])) l' sh' ∧
      TileLoc C D I ctx nb mb s i k (4 * s4 + c) 0 l' ∧ Mem C L D I nb mb P ge pw sh' ∧
      (∀ th', th' ≠ ctx.thread → tview sh' th' = tview sh th') ∧
      TAt C D I nb mb s i k (4 * s4 + c) 0 (tview sh' ctx.thread) := by
  have hT13 := hok.tiles_lt13
  have hreg := hm.regions
  have hv4 : (4 * s4 + c) / 4 = s4 := by omega
  have hvm : (4 * s4 + c) % 4 = c := by omega
  have h35 := eval_bin_u32 C (ctx := ctx) (l := l) (sh := sh) (op := .add) (site := 0)
    (eval_bin_u32 C (op := .mul) (site := 0) (eval_local' C hloc.l31 sh) (eval_u32lit C _ sh 4 (by norm_num))
      (binary_mul_u32 C s4 4)) (eval_local' C h34 sh) (binary_add_u32 C _ c)
  rw [show s4 * 4 + c = 4 * s4 + c by ring] at h35
  generalize hl1 : setLocal l 35 (u32 (4 * s4 + c)) = l₁
  generalize hl2 : setLocal l₁ 36 (.ptr ⟨if false = true then ctx.groupArray 5 else ctx.threadArray 5, 0, .vec .f32 2⟩) = l₂
  have ag2 : ∀ j, j < 35 → l₂ j = l j := fun j hj => by
    rw [← hl2, setLocal_other _ _ (by omega), ← hl1, setLocal_other _ _ (by omega)]
  have h36 : l₂ 36 = some (.ptr ⟨ta ctx.thread 5, 0, .vec .f32 2⟩) := by rw [← hl2, setLocal_same, hl.ta]; rfl
  have h235 : l₂ 35 = some (u32 (4 * s4 + c)) := by rw [← hl2, setLocal_other _ _ (by omega), ← hl1, setLocal_same]
  have hr5 : sh.regions (ta ctx.thread 5) = some ⟨.thread, 8, 8⟩ := by rw [hreg]; exact hS.t5 _
  -- bx[0], bx[1]
  have hbx : ∀ (j : Nat) (hj : j < 2) (slot : Nat), slot = 32 + j → ∀ (sh' : Shared),
      l₂ slot = some (x4 C I.X (xoff D mb i (stepOf D s k) j + 4 * s4)) →
      (eval C ctx l₂ (.component (.local slot) (.local 34))).run sh' =
        some (.f32 (bRegs C D I mb s k (4 * s4 + c) i ⟨j, hj⟩), sh') := by
    intro j hj slot hslot sh' hx
    refine eval_component C (eval_local' C hx sh') (eval_local' C ((ag2 34 (by omega)).trans h34) sh')
      (natOf_u32 c) ?_
    rw [Nat.mod_eq_of_lt (by omega : c < 2 ^ 32), x4_get C I.X _ c hc]
    have e := bx_idx D mb s k (4 * s4 + c) i j
    rw [hv4, hvm] at e
    simp only [bRegs]
    rw [e]
  have hp0 := eval_offset_i32 C (ctx := ctx) (o := 0) (r := ta ctx.thread 5) (e := .scalar .f32) (sh := sh)
    (eval_ptrCast C (t := .scalar .f32) (eval_local' C h36 sh)) (eval_i32lit_raw C (ctx := ctx) (l := l₂) (sh := sh) 0)
    (by norm_num)
  have hs0 := store_t ctx (.scalar .f32) (.scalar .f32) sh (ta ctx.thread 5) 0 8 8
    (.f32 (bRegs C D I mb s k (4 * s4 + c) i 0)) _ hr5 (by simp [alignment, Scalar.bytes])
    (by simp [alignment, Scalar.bytes]) (by simp [Ty.bytes, Scalar.bytes]) (encode_f32 _)
  generalize hsh1 : tput sh (ta ctx.thread 5) 0 (wordBytes 4 (Val.f32Bits (bRegs C D I mb s k (4 * s4 + c) i 0))) = sh₁
    at hs0
  have hp1 := eval_offset_i32 C (ctx := ctx) (o := 0) (r := ta ctx.thread 5) (e := .scalar .f32) (sh := sh₁)
    (eval_ptrCast C (t := .scalar .f32) (eval_local' C h36 sh₁)) (eval_i32lit_raw C (ctx := ctx) (l := l₂) (sh := sh₁) 1)
    (by norm_num)
  have hs1 := store_t ctx (.scalar .f32) (.scalar .f32) sh₁ (ta ctx.thread 5) 4 8 8
    (.f32 (bRegs C D I mb s k (4 * s4 + c) i 1)) _ (by rw [← hsh1]; exact hr5) (by simp [alignment, Scalar.bytes])
    (by simp [alignment, Scalar.bytes]) (by simp [Ty.bytes, Scalar.bytes]) (encode_f32 _)
  generalize hsh2 : tput sh₁ (ta ctx.thread 5) 4 (wordBytes 4 (Val.f32Bits (bRegs C D I mb s k (4 * s4 + c) i 1))) = sh₂
    at hs1
  have hv2 : ∀ j, j ≠ 5 → tview sh₂ ctx.thread j = tview sh ctx.thread j := fun j hj => by
    rw [← hsh2, ← hsh1, tview_tput_at (by decide), ite_eq_right hj, tview_tput_at (by decide), ite_eq_right hj]
  have hm2 : Mem C L D I nb mb P ge pw sh₂ := by
    rw [← hsh2, ← hsh1]; exact (hm.tput _ _ (by unfold ta; omega)).tput _ _ (by unfold ta; omega)
  have hbx2 : BxOk (bRegs C D I mb s k (4 * s4 + c) i 0) (bRegs C D I mb s k (4 * s4 + c) i 1) (tview sh₂ ctx.thread) := by
    unfold BxOk
    rw [← hsh2, ← hsh1, tview_tput_at (by decide), ite_eq_left rfl, tview_tput_at (by decide), ite_eq_left rfl]
    exact cells_pair_writes _ _ _
  have hT2 : TAt C D I nb mb s i k (4 * s4 + c) 0 (tview sh₂ ctx.thread) :=
    (hT.of_eq C fun j hj => hv2 j (by omega)).tat C hbx2
  -- tile 0
  generalize hl3 : setLocal l₂ 37 (u32 0) = l₃
  have hcol : ColLoc C D I ctx nb mb s i k (4 * s4 + c) l₃ := by
    rw [← hl3]
    refine ⟨hloc.step.of_eq fun j hj => by rw [setLocal_other _ _ (by omega), ag2 j (by omega)], ?_, ?_, ?_, ?_, ?_, ?_⟩
    · rw [setLocal_other _ _ (by omega), ag2 _ (by omega), hv4]; exact hloc.l31
    · rw [setLocal_other _ _ (by omega), ag2 _ (by omega), hv4]; exact hloc.l32
    · rw [setLocal_other _ _ (by omega), ag2 _ (by omega), hv4]; exact hloc.l33
    · rw [setLocal_other _ _ (by omega), ag2 _ (by omega), hvm]; exact h34
    · rw [setLocal_other _ _ (by omega)]; exact h235
    · rw [setLocal_other _ _ (by omega)]; exact h36
  have h37 : l₃ 37 = some (u32 0) := by rw [← hl3, setLocal_same]
  obtain ⟨l', sh', htile, hloc', hm', hoth', hv'⟩ := exec_tile C hS hok hl (by omega) hok.tiles hcol h37 hm2 hT2
  refine ⟨l', sh', ?_, hloc', hm', fun th' h => ?_, hT2.of_eq fun j hj => hv' j hj⟩
  · rw [columnBody_eq]
    refine .set h35 (by rw [hl1]; exact .array (by
      rw [hl2]
      exact .store (by rw [show 0 + 0 * (Ty.scalar .f32).bytes = 0 from rfl] at hp0; exact hp0)
        (hbx 0 (by norm_num) 32 rfl sh (by rw [ag2 32 (by omega)]; exact hloc.l32)) hs0
        (.store (by rw [show 0 + 1 * (Ty.scalar .f32).bytes = 4 from rfl] at hp1; exact hp1)
          (hbx 1 (by norm_num) 33 rfl sh₁ (by rw [ag2 33 (by omega)]; exact hloc.l33)) hs1
          (.set (eval_u32lit C _ _ 0 (by norm_num)) (by
            rw [hl3]
            exact exec_loop_stop C h37 (by norm_num) (by omega)
              (eval_u32lit C _ _ _ (by omega)) hok.tiles htile)))))
  · rw [hoth' th' h, ← hsh2, ← hsh1, tview_tput_thread h (by decide), tview_tput_thread h (by decide)]

theorem xoff_mod {D : Dims} (hok : Ok D) (mb i step j s4 : Nat) : (xoff D mb i step j + 4 * s4) % 4 = 0 := by
  have hK : D.K % 4 = 0 := by have := hok.K; omega
  have h1 : min (8 * mb + fnOf i + j) (D.r - 1) * D.K % 4 = 0 := by rw [Nat.mul_mod, hK, Nat.mul_zero, Nat.zero_mod]
  unfold xoff xbase; omega

theorem xoff_le {D : Dims} (hok : Ok D) {mb i step j s4 : Nat} (hstep : step < D.K / 256) (hs4 : s4 < 8) :
    xoff D mb i step j + 4 * s4 + 4 ≤ D.r * D.K := by
  have hfm := fm_lt i
  have h1 : min (8 * mb + fnOf i + j) (D.r - 1) * D.K ≤ (D.r - 1) * D.K := Nat.mul_le_mul_right _ (Nat.min_le_right _ _)
  have h2 : (D.r - 1) * D.K + D.K = D.r * D.K := by
    have := hok.r; obtain ⟨r', hr'⟩ : ∃ r', D.r = r' + 1 := ⟨D.r - 1, by omega⟩; rw [hr']; simp; ring
  have h3 : 256 * step + 256 ≤ D.K := by have := hok.K; omega
  unfold xoff xbase; omega

theorem exec_s4 (hS : Shape L D A) (hok : Ok D) {i : Fin 32} (hl : Lane D ctx nb mb s i) {k s4 : Nat}
    (hk : stepOf D s k < D.K / 256) (hs4 : s4 < 8) {l : Locals} {sh : Shared}
    (hst : StepLoc D ctx nb mb s i k l) (h31 : l 31 = some (u32 s4)) (hm : Mem C L D I nb mb P ge pw sh)
    (hT : TPre C D I nb mb s i k (4 * s4) (tview sh ctx.thread)) :
    ∃ l' sh', Exec C ctx (s4Body D.bits D.tiles) l sh
        (.stop (.collective 1 55 (.mma .f32 .f32) .f32 (xval C D I nb mb s i k (4 * s4) 0) 0)
          (([.block [accStore]] ++ [frameOf 37 (u32l D.tiles) 1 (tileBody D.bits), .block []]) ++
            [frameOf 34 (u32l 4) 1 (columnBody D.bits D.tiles), .block []])) l' sh' ∧
      TileLoc C D I ctx nb mb s i k (4 * s4) 0 l' ∧ Mem C L D I nb mb P ge pw sh' ∧
      (∀ th', th' ≠ ctx.thread → tview sh' th' = tview sh th') ∧
      TAt C D I nb mb s i k (4 * s4) 0 (tview sh' ctx.thread) := by
  have hx : ∀ (j : Nat) (slot : Nat) (l' : Locals) (sh' : Shared), j < 2 → slot = 29 + j →
      l' slot = some (.ptr ⟨0, ((2 * xoff D mb i (stepOf D s k) j : Nat) : Int), .vec .bf16 4⟩) →
      l' 31 = some (u32 s4) → sh'.regions = L.regions → sh'.bytes 0 = I.X →
      (eval C ctx l' (.conv .f32 (.load (.vec .bf16 4) (.offset (.local slot) (.local 31))))).run sh' =
        some (x4 C I.X (xoff D mb i (stepOf D s k) j + 4 * s4),
          rdn ctx sh' 0 (2 * (xoff D mb i (stepOf D s k) j + 4 * s4)) 8) := by
    intro j slot l' sh' hj hslot hl' h31' hr hX
    have hp := eval_offset_u32 C (ctx := ctx) (sh := sh') (eval_local' C hl' sh') (eval_local' C h31' sh') (by omega)
    rw [show 2 * xoff D mb i (stepOf D s k) j + s4 * (Ty.vec .bf16 4).bytes =
      2 * (xoff D mb i (stepOf D s k) j + 4 * s4) by show _ + s4 * 8 = _; ring] at hp
    exact eval_x4 C hS hr hX hp (xoff_mod hok _ _ _ _ _) (xoff_le hok hk hs4)
  have hva := hx 0 29 l sh (by norm_num) rfl hst.l29 h31 hm.regions hm.x
  generalize hsh1 : rdn ctx sh 0 (2 * (xoff D mb i (stepOf D s k) 0 + 4 * s4)) 8 = sh₁ at hva
  have hm1 : Mem C L D I nb mb P ge pw sh₁ := by rw [← hsh1]; exact hm.rd hS ctx 0 _ 8 (.inl (by decide))
  generalize hl1 : setLocal l 32 (x4 C I.X (xoff D mb i (stepOf D s k) 0 + 4 * s4)) = l₁
  have ag1 : ∀ j, j ≠ 32 → l₁ j = l j := fun j hj => by rw [← hl1, setLocal_other _ _ hj]
  have hvb := hx 1 30 l₁ sh₁ (by norm_num) rfl ((ag1 30 (by omega)).trans hst.l30) ((ag1 31 (by omega)).trans h31)
    hm1.regions hm1.x
  generalize hsh2 : rdn ctx sh₁ 0 (2 * (xoff D mb i (stepOf D s k) 1 + 4 * s4)) 8 = sh₂ at hvb
  have hm2 : Mem C L D I nb mb P ge pw sh₂ := by rw [← hsh2]; exact hm1.rd hS ctx 0 _ 8 (.inl (by decide))
  generalize hl2 : setLocal l₁ 33 (x4 C I.X (xoff D mb i (stepOf D s k) 1 + 4 * s4)) = l₂
  generalize hl3 : setLocal l₂ 34 (u32 0) = l₃
  have hv2 : tview sh₂ ctx.thread = tview sh ctx.thread := by rw [← hsh2, ← hsh1]; rfl
  have hloc : S4Loc C D I ctx nb mb s i k s4 l₃ := by
    rw [← hl3, ← hl2, ← hl1]
    refine ⟨hst.of_eq fun j hj => ?_, ?_, ?_, ?_⟩
    · rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
    · rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact h31
    · rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_same]
    · rw [setLocal_other _ _ (by omega), setLocal_same]
  have h34 : l₃ 34 = some (u32 0) := by rw [← hl3, setLocal_same]
  obtain ⟨l', sh', hcol, hloc', hm', hoth', hT'⟩ := exec_col C hS hok hl hk hs4 (by norm_num : 0 < 4) hloc h34 hm2
    (by rw [hv2]; exact hT)
  refine ⟨l', sh', ?_, hloc', hm', fun th' h => by rw [hoth' th' h, ← hsh2, ← hsh1]; rfl, hT'⟩
  show Exec C ctx (_ :: _ :: (.set 34 (u32l 0) :: [loopOf 34 (u32l 4) 1 (columnBody D.bits D.tiles)])) l sh _ l' sh'
  exact .set hva (by rw [hl1]; exact .set hvb (by
    rw [hl2]
    exact .set (eval_u32lit C _ _ 0 (by norm_num)) (by
      rw [hl3]
      exact exec_loop_stop C h34 (by norm_num) (by norm_num) (eval_u32lit C _ _ _ (by norm_num)) (by norm_num) hcol)))

theorem exec_step (hS : Shape L D A) (hok : Ok D) {i : Fin 32} (hl : Lane D ctx nb mb s i) {k : Nat}
    (hk : stepOf D s k < D.K / 256) {l : Locals} {sh : Shared} (hF : Fix D ctx nb mb s i l)
    (h19 : l 19 = some (u32 D.tiles)) (h20 : l 20 = some (u32 (stepOf D s k))) (hm : Mem C L D I nb mb P ge pw sh)
    (hW : WRowOk D nb (fmOf i) (tview sh ctx.thread))
    (hA : AccOk D (fun t' j => accAt C D I nb mb s t' (32 * k) i j) (tview sh ctx.thread)) :
    ∃ l' sh', Exec C ctx (stepBody D.bits D.tiles) l sh
        (.stop (.collective 1 55 (.mma .f32 .f32) .f32 (xval C D I nb mb s i k 0 0) 0)
          ((([.block [accStore]] ++ [frameOf 37 (u32l D.tiles) 1 (tileBody D.bits), .block []]) ++
            [frameOf 34 (u32l 4) 1 (columnBody D.bits D.tiles), .block []]) ++
            [frameOf 31 (u32l 8) 1 (s4Body D.bits D.tiles), .block []])) l' sh' ∧
      TileLoc C D I ctx nb mb s i k 0 0 l' ∧ Mem C L D I nb mb P ge pw sh' ∧
      (∀ th', th' ≠ ctx.thread → tview sh' th' = tview sh th') ∧
      TAt C D I nb mb s i k 0 0 (tview sh' ctx.thread) := by
  have hK := hok.Kle
  have h21 := eval_bin_u32 C (ctx := ctx) (l := l) (sh := sh) (op := .mul) (site := 0) (eval_local' C h20 sh)
    (eval_u32lit C _ sh 256 (by norm_num)) (binary_mul_u32 C (stepOf D s k) 256)
  rw [Nat.mul_comm (stepOf D s k) 256] at h21
  generalize hl1 : setLocal l 21 (u32 (256 * stepOf D s k)) = l₁
  have h1_20 : l₁ 20 = some (u32 (stepOf D s k)) := by rw [← hl1, setLocal_other _ _ (by decide)]; exact h20
  have h1_9 : l₁ 9 = some (u32 (fnOf i)) := by rw [← hl1, setLocal_other _ _ (by decide)]; exact hF.l9
  have h22 := eval_bin_u32 C (ctx := ctx) (l := l₁) (sh := sh) (op := .add) (site := 0)
    (eval_bin_u32 C (op := .mul) (site := 0) (eval_local' C h1_20 sh)
      (eval_u32lit C _ sh 4 (by norm_num)) (binary_mul_u32 C (stepOf D s k) 4))
    (eval_bin_u32 C (op := .div) (site := 0) (eval_local' C h1_9 sh)
      (eval_u32lit C _ sh 2 (by norm_num)) (binary_div_u32 C (fnOf i) 2 (by have := fn_lt i; omega) (by norm_num)
        (by norm_num)))
    (binary_add_u32 C _ _)
  rw [show stepOf D s k * 4 + fnOf i / 2 = gOf D s i k by unfold gOf; ring] at h22
  generalize hl2 : setLocal l₁ 22 (u32 (gOf D s i k)) = l₂
  generalize hl5 : setLocal (setLocal (setLocal l₂ 23 (.ptr ⟨if false = true then ctx.groupArray 2 else ctx.threadArray 2,
    0, .scalar .u32⟩)) 24 (.ptr ⟨if false = true then ctx.groupArray 3 else ctx.threadArray 3, 0, .scalar .f32⟩)) 25
    (.ptr ⟨if false = true then ctx.groupArray 4 else ctx.threadArray 4, 0, .scalar .f32⟩) = l₅
  have hsc : ScaleLoc D ctx nb mb s i k l₅ := by
    rw [← hl5, ← hl2, ← hl1]
    refine ⟨hF.of_eq fun j hj => by simp only [setLocal_other _ _ (show j ≠ 25 by omega), setLocal_other _ _ (show j ≠ 24 by omega),
      setLocal_other _ _ (show j ≠ 23 by omega), setLocal_other _ _ (show j ≠ 22 by omega),
      setLocal_other _ _ (show j ≠ 21 by omega)], ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · simp only [setLocal_other _ _ (show (19 : Nat) ≠ 25 by omega), setLocal_other _ _ (show (19 : Nat) ≠ 24 by omega),
        setLocal_other _ _ (show (19 : Nat) ≠ 23 by omega), setLocal_other _ _ (show (19 : Nat) ≠ 22 by omega),
        setLocal_other _ _ (show (19 : Nat) ≠ 21 by omega)]; exact h19
    · simp only [setLocal_other _ _ (show (20 : Nat) ≠ 25 by omega), setLocal_other _ _ (show (20 : Nat) ≠ 24 by omega),
        setLocal_other _ _ (show (20 : Nat) ≠ 23 by omega), setLocal_other _ _ (show (20 : Nat) ≠ 22 by omega),
        setLocal_other _ _ (show (20 : Nat) ≠ 21 by omega)]; exact h20
    · simp only [setLocal_other _ _ (show (21 : Nat) ≠ 25 by omega), setLocal_other _ _ (show (21 : Nat) ≠ 24 by omega),
        setLocal_other _ _ (show (21 : Nat) ≠ 23 by omega), setLocal_other _ _ (show (21 : Nat) ≠ 22 by omega),
        setLocal_same]
    · simp only [setLocal_other _ _ (show (22 : Nat) ≠ 25 by omega), setLocal_other _ _ (show (22 : Nat) ≠ 24 by omega),
        setLocal_other _ _ (show (22 : Nat) ≠ 23 by omega), setLocal_same]
    · simp only [setLocal_other _ _ (show (23 : Nat) ≠ 25 by omega), setLocal_other _ _ (show (23 : Nat) ≠ 24 by omega),
        setLocal_same, hl.ta]; rfl
    · simp only [setLocal_other _ _ (show (24 : Nat) ≠ 25 by omega), setLocal_same, hl.ta]; rfl
    · simp only [setLocal_same, hl.ta]; rfl
  obtain ⟨l₆, sh₆, hsx, ag6, hm6, hoth6, hv6, hq6, hs6, hb6⟩ := exec_scale C hS hok hl hk hsc hm hW
  -- xa, xb
  have hxp : ∀ (j : Nat) (slot : Nat), j < 2 → slot = 15 + j →
      l₆ slot = some (.ptr ⟨0, ((2 * xbase D mb i j : Nat) : Int), .scalar .bf16⟩) →
      (eval C ctx l₆ (.ptrCast (.vec .bf16 4) (.offset (.local slot) (.local 21)))).run sh₆ =
        some (.ptr ⟨0, ((2 * xoff D mb i (stepOf D s k) j : Nat) : Int), .vec .bf16 4⟩, sh₆) := by
    intro j slot hj hslot hl'
    have hp := eval_offset_u32 C (ctx := ctx) (sh := sh₆) (eval_local' C hl' sh₆)
      (eval_local' C ((ag6 21 (by omega)).trans hsc.l21) sh₆) (by omega)
    rw [show 2 * xbase D mb i j + 256 * stepOf D s k * (Ty.scalar .bf16).bytes = 2 * xoff D mb i (stepOf D s k) j by
      simp only [xoff, Ty.bytes, Scalar.bytes]; ring] at hp
    exact eval_ptrCast C hp
  have hx0 := hxp 0 15 (by norm_num) rfl ((ag6 15 (by omega)).trans hsc.fix.l15)
  generalize hl7 : setLocal l₆ 29 (.ptr ⟨0, ((2 * xoff D mb i (stepOf D s k) 0 : Nat) : Int), .vec .bf16 4⟩) = l₇
  have hx1 : (eval C ctx l₇ (.ptrCast (.vec .bf16 4) (.offset (.local 16) (.local 21)))).run sh₆ =
      some (.ptr ⟨0, ((2 * xoff D mb i (stepOf D s k) 1 : Nat) : Int), .vec .bf16 4⟩, sh₆) := by
    have h7_16 : l₇ 16 = some (.ptr ⟨0, ((2 * xbase D mb i 1 : Nat) : Int), .scalar .bf16⟩) := by
      rw [← hl7, setLocal_other _ _ (by decide)]; exact (ag6 16 (by omega)).trans hsc.fix.l16
    have h7_21 : l₇ 21 = some (u32 (256 * stepOf D s k)) := by
      rw [← hl7, setLocal_other _ _ (by decide)]; exact (ag6 21 (by omega)).trans hsc.l21
    have hp := eval_offset_u32 C (ctx := ctx) (sh := sh₆) (eval_local' C h7_16 sh₆) (eval_local' C h7_21 sh₆)
      (by omega)
    rw [show 2 * xbase D mb i 1 + 256 * stepOf D s k * (Ty.scalar .bf16).bytes = 2 * xoff D mb i (stepOf D s k) 1 by
      simp only [xoff, Ty.bytes, Scalar.bytes]; ring] at hp
    exact eval_ptrCast C hp
  generalize hl8 : setLocal l₇ 30 (.ptr ⟨0, ((2 * xoff D mb i (stepOf D s k) 1 : Nat) : Int), .vec .bf16 4⟩) = l₈
  generalize hl9 : setLocal l₈ 31 (u32 0) = l₉
  have ag9 : ∀ j, j ≤ 25 → l₉ j = l₅ j := fun j hj => by
    rw [← hl9, setLocal_other _ _ (by omega), ← hl8, setLocal_other _ _ (by omega), ← hl7, setLocal_other _ _ (by omega)]
    exact ag6 j hj
  have hst : StepLoc D ctx nb mb s i k l₉ :=
    ⟨hsc.fix.of_eq fun j hj => ag9 j (by omega), (ag9 19 (by omega)).trans hsc.l19, (ag9 20 (by omega)).trans hsc.l20,
      (ag9 21 (by omega)).trans hsc.l21, (ag9 22 (by omega)).trans hsc.l22, (ag9 23 (by omega)).trans hsc.l23,
      (ag9 24 (by omega)).trans hsc.l24, (ag9 25 (by omega)).trans hsc.l25,
      by rw [← hl9, setLocal_other _ _ (by omega), ← hl8, setLocal_other _ _ (by omega), ← hl7, setLocal_same],
      by rw [← hl9, setLocal_other _ _ (by omega), ← hl8, setLocal_same]⟩
  have h31 : l₉ 31 = some (u32 0) := by rw [← hl9, setLocal_same]
  have hT6 : TPre C D I nb mb s i k (4 * 0) (tview sh₆ ctx.thread) :=
    ⟨fun t ht => by rw [hv6 0 (by decide) (by decide) (by decide)]; exact hW t ht,
      fun t ht => by rw [hv6 1 (by decide) (by decide) (by decide)]; exact hA t ht, hq6, hs6, hb6⟩
  obtain ⟨l', sh', hs4x, hloc', hm', hoth', hT'⟩ := exec_s4 C hS hok hl hk (by norm_num : 0 < 8) hst h31 hm6 hT6
  refine ⟨l', sh', ?_, hloc', hm', fun th' h => by rw [hoth' th' h, hoth6 th' h], hT'⟩
  rw [stepBody_eq]
  refine .set (eval_bin_u32 C (op := .mul) (site := 0) (eval_local' C h20 sh) (eval_u32lit C _ sh 256 (by norm_num))
    (binary_mul_u32 C (stepOf D s k) 256)) ?_
  rw [Nat.mul_comm (stepOf D s k) 256, hl1]
  refine .set h22 ?_
  rw [hl2]
  refine .array (.array (.array ?_))
  rw [hl5]
  refine hsx.append ?_
  exact .set hx0 (by rw [hl7]; exact .set hx1 (by
    rw [hl8]
    exact .set (eval_u32lit C _ _ 0 (by norm_num)) (by
      rw [hl9]
      exact exec_loop_stop C h31 (by norm_num) (by norm_num) (eval_u32lit C _ _ _ (by norm_num)) (by norm_num) hs4x)))

end Col
end Metal.Kernels.SplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

/-- The status of lane `i` at tile `t`'s multiply-accumulate of value `v` of K step `k`. -/
def collAt (C : M1Max.Contract) (D : Dims) (I : In) (nb mb s : Nat) (i : Fin 32) (k v t : Nat) : Status :=
  .collective 1 55 (.mma .f32 .f32) .f32 (xval C D I nb mb s i k v t) 0

section Lanes
variable (C : M1Max.Contract) {L : Launch} {A : Al} {I : In} {P ge : Nat} {pw : Nat → Nat → Nat → Prop} {ctx : Ctx}
  {D : Dims} {nb mb s : Nat}

theorem Ok.s_lt {D : Dims} (hok : Ok D) {s : Nat} (hs : s < D.splits) : s < D.K / 256 := by
  have := hok.splitsK; omega

/-- A lane from the kernel's start to its first multiply-accumulate. -/
theorem lane_start (hS : Shape L D A) (hok : Ok D) {i : Fin 32} (hl : Lane D ctx nb mb s i) {sh : Shared}
    (hm : Mem C L D I nb mb P ge pw sh) :
    ∃ l' sh', Reaches C ⟨ctx, fun _ => none, [.block (body D.N D.K D.bits D.tiles D.splits)], .running⟩ sh
        ⟨ctx, l', Fc D, collAt C D I nb mb s i 0 0 0⟩ sh' ∧
      TileLoc C D I ctx nb mb s i 0 0 0 l' ∧ Mem C L D I nb mb P ge pw sh' ∧
      (∀ th', th' ≠ ctx.thread → tview sh' th' = tview sh th') ∧ TAt C D I nb mb s i 0 0 0 (tview sh' ctx.thread) := by
  obtain ⟨l₁, hpre, hF⟩ := exec_pre C hS hok hl hm.regions hm.h
  have hm1 := hm.rd hS ctx 1 0 4 (.inl (by decide))
  obtain ⟨l₂, sh₂, hinit, hF2, h19, hm2, hoth2, -, hW2, hA2⟩ := exec_init C hS hok hl hF hm1
  have hF3 : Fix D ctx nb mb s i (setLocal l₂ 20 (u32 s)) := hF2.set _ (by omega)
  have h20 : setLocal l₂ 20 (u32 s) 20 = some (u32 (stepOf D s 0)) := by rw [setLocal_same]; rfl
  obtain ⟨l', sh', hst, hloc, hm', hoth', hT'⟩ := exec_step C hS hok hl (k := 0) (by exact hok.s_lt hl.hs) hF3
    (by rw [setLocal_other _ _ (by decide)]; exact h19) h20 hm2 hW2 hA2
  have hsK := hok.s_lt hl.hs
  have hK := hok.Kle
  have hex : Exec C ctx (body D.N D.K D.bits D.tiles D.splits) (fun _ => none) sh
      (.stop (collAt C D I nb mb s i 0 0 0) (Fc D)) l' sh' := by
    rw [body_eq]
    exact hpre.append (hinit.append (.set (eval_local' C hF2.l7 sh₂) (exec_loop_stop C h20 (show stepOf D s 0 < 2 ^ 32 by
      show s + D.splits * 0 < 2 ^ 32; omega) (show D.K / 256 < 2 ^ 32 by omega) (eval_u32lit C _ _ _ (by omega)) hsK hst)))
  refine ⟨l', sh', by simpa using hex.reaches_stop (K := []), hloc, hm', fun th' h => ?_, hT'⟩
  rw [hoth' th' h, hoth2 th' h]; rfl

/-- `acc[t] = D`. -/
theorem exec_accStore (hS : Shape L D A) {i : Nat} (hl : Lane D ctx nb mb s i) {l : Locals} {sh : Shared} {t : Nat}
    {d0 d1 : Float32} (hF : Fix D ctx nb mb s i l) (h37 : l 37 = some (u32 t)) (ht : t < D.tiles)
    (h55 : l 55 = some (.vec .f32 [.f32 d0, .f32 d1])) (hreg : sh.regions = L.regions) (hT13 : D.tiles < 2 ^ 13) :
    Exec C ctx [accStore] l sh .normal l (tput sh (ta ctx.thread 1) (8 * t) (pairBytes d0 d1)) := by
  have hp := eval_offset_u32 C (ctx := ctx) (o := 0) (sh := sh) (eval_local' C hF.l18 sh) (eval_local' C h37 sh) (by omega)
  rw [show 0 + t * (Ty.vec .f32 2).bytes = 8 * t by show 0 + t * 8 = 8 * t; ring, hl.ta] at hp
  exact .store hp (eval_local' C h55 sh) (store_t ctx _ _ sh (ta ctx.thread 1) (8 * t) (8 * D.tiles) 8 _ _
    (by rw [hreg]; exact hS.t1 _) (by simp [alignment, Ty.bytes, Scalar.bytes])
    (by simp [alignment, Ty.bytes, Scalar.bytes]) (by show 8 * t + 8 ≤ 8 * D.tiles; omega) (encode_pair d0 d1)) (.nil _ _)

/-- The arrays after `acc[t]`'s store: the next tile's. -/
theorem TAt.next {i : Fin 32} {k v t : Nat} {V : Nat → ByteMemory.Bytes} (h : TAt C D I nb mb s i k v t V)
    (ht : t < D.tiles) :
    TAt C D I nb mb s i k v (t + 1) (fun j => if j = 1 then writeBytes (V 1) (8 * t)
      (pairBytes (accAt C D I nb mb s t (32 * k + v + 1) i 0) (accAt C D I nb mb s t (32 * k + v + 1) i 1)) else V j) := by
  obtain ⟨h1, h2, h3, h4, h5, h6⟩ := h
  refine ⟨h1, fun t' ht' => ?_, h3, h4, h5, h6⟩
  show cells (writeBytes (V 1) (8 * t) _) (8 * t') 8 = _
  by_cases htt : t' = t
  · subst htt
    rw [cells_writeBytes_of_length _ _ _ _ (pairBytes_length _ _)]
    dsimp only
    rw [ite_eq_left (Nat.lt_succ_self _)]
  · rw [cells_writeBytes_other _ _ _ _ _ (by rw [pairBytes_length]; omega), h2 t' ht']
    dsimp only
    by_cases h' : t' < t
    · rw [ite_eq_left h', ite_eq_left (by omega)]
    · rw [ite_eq_right h', ite_eq_right (by omega)]

end Lanes
end Metal.Kernels.SplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

/-- The multiply-accumulate's result in lane `i`: `acc[t]` after one more value. -/
def accV (C : M1Max.Contract) (D : Dims) (I : In) (nb mb s : Nat) (i : Fin 32) (k v t : Nat) : Val :=
  .vec .f32 [.f32 (accAt C D I nb mb s t (32 * k + v + 1) i 0), .f32 (accAt C D I nb mb s t (32 * k + v + 1) i 1)]

/-- The frames below the tile loop's. -/
def Krest (D : Dims) : List Frame :=
  [frameOf 34 (u32l 4) 1 (columnBody D.bits D.tiles), .block [], frameOf 31 (u32l 8) 1 (s4Body D.bits D.tiles), .block [],
   frameOf 20 (u32l (D.K / 256)) D.splits (stepBody D.bits D.tiles), .block (after D)]

theorem Fc_eq (D : Dims) : Fc D = .block [accStore] :: frameOf 37 (u32l D.tiles) 1 (tileBody D.bits) :: .block [] :: Krest D :=
  rfl

section Next
variable (C : M1Max.Contract) {L : Launch} {A : Al} {I : In} {P ge : Nat} {pw : Nat → Nat → Nat → Prop} {ctx : Ctx}
  {D : Dims} {nb mb s : Nat}

/-- Resumed at tile `t`: `acc[t]`'s store; the arrays then hold the next tile's state. -/
theorem resume_acc (hS : Shape L D A) (hok : Ok D) {i : Fin 32} (hl : Lane D ctx nb mb s i) {k v t : Nat}
    (ht : t < D.tiles) {l : Locals} {sh : Shared} (hloc : TileLoc C D I ctx nb mb s i k v t l)
    (hm : Mem C L D I nb mb P ge pw sh) (hT : TAt C D I nb mb s i k v t (tview sh ctx.thread)) :
    ∃ sh₁, Exec C ctx [accStore] (setLocal l 55 (accV C D I nb mb s i k v t)) sh .normal
        (setLocal l 55 (accV C D I nb mb s i k v t)) sh₁ ∧ Mem C L D I nb mb P ge pw sh₁ ∧
      (∀ th', th' ≠ ctx.thread → tview sh₁ th' = tview sh th') ∧
      TAt C D I nb mb s i k v (t + 1) (tview sh₁ ctx.thread) ∧ sh₁.regions = L.regions := by
  have hF := hloc.col.step.fix
  refine ⟨_, exec_accStore C hS hl (hF.set _ (by omega)) (by rw [setLocal_other _ _ (by decide)]; exact hloc.l37) ht
    (setLocal_same _ _ _) hm.regions hok.tiles_lt13, hm.tput _ _ (by unfold ta; omega),
    fun th' h => tview_tput_thread h (by decide), ?_, hm.regions⟩
  rw [tview_tput (by decide)]
  exact hT.next C ht

/-- The next tile. -/
theorem lane_tile (hS : Shape L D A) (hok : Ok D) {i : Fin 32} (hl : Lane D ctx nb mb s i) {k v t : Nat}
    (hv : v < 32) (ht : t + 1 < D.tiles) {l : Locals} {sh : Shared} (hloc : TileLoc C D I ctx nb mb s i k v t l)
    (hm : Mem C L D I nb mb P ge pw sh) (hT : TAt C D I nb mb s i k v t (tview sh ctx.thread)) :
    ∃ l' sh', Reaches C ⟨ctx, setLocal l 55 (accV C D I nb mb s i k v t), Fc D, .running⟩ sh
        ⟨ctx, l', Fc D, collAt C D I nb mb s i k v (t + 1)⟩ sh' ∧
      TileLoc C D I ctx nb mb s i k v (t + 1) l' ∧ Mem C L D I nb mb P ge pw sh' ∧
      (∀ th', th' ≠ ctx.thread → tview sh' th' = tview sh th') ∧
      TAt C D I nb mb s i k v (t + 1) (tview sh' ctx.thread) := by
  have hT13 := hok.tiles_lt13
  obtain ⟨sh₁, hacc, hm1, hoth1, hT1, -⟩ := resume_acc C hS hok hl (by omega) hloc hm hT
  have h37 : setLocal l 55 (accV C D I nb mb s i k v t) 37 = some (u32 t) := by
    rw [setLocal_other _ _ (by decide)]; exact hloc.l37
  generalize hl2 : setLocal (setLocal l 55 (accV C D I nb mb s i k v t)) 37 (u32 (t + 1)) = l₂
  have hcol : ColLoc C D I ctx nb mb s i k v l₂ :=
    hloc.col.of_eq fun j hj => by rw [← hl2, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
  have h37' : l₂ 37 = some (u32 (t + 1)) := by rw [← hl2, setLocal_same]
  obtain ⟨l', sh', htile, hloc', hm', hoth', hv'⟩ := exec_tile C hS hok hl hv ht hcol h37' hm1 hT1
  refine ⟨l', sh', ?_, hloc', hm', fun th' h => by rw [hoth' th' h, hoth1 th' h], hT1.of_eq fun j hj => hv' j hj⟩
  rw [Fc_eq]
  exact resume_loop_stop C hacc (.inl rfl) h37 (by norm_num) (by omega) (by omega)
    (eval_u32lit C _ _ _ (by omega)) ht (by rw [hl2]; exact htile)

/-- The last tile's step and the tile loop's exit. -/
theorem exit_tile (hS : Shape L D A) (hok : Ok D) {i : Fin 32} (hl : Lane D ctx nb mb s i) {k v t : Nat}
    (ht : t + 1 = D.tiles) {l : Locals} {sh : Shared} (hloc : TileLoc C D I ctx nb mb s i k v t l)
    (hm : Mem C L D I nb mb P ge pw sh) (hT : TAt C D I nb mb s i k v t (tview sh ctx.thread)) :
    ∃ sh₁, Reaches C ⟨ctx, setLocal l 55 (accV C D I nb mb s i k v t), Fc D, .running⟩ sh
        ⟨ctx, setLocal (setLocal l 55 (accV C D I nb mb s i k v t)) 37 (u32 D.tiles), .block [] :: Krest D, .running⟩ sh₁ ∧
      Mem C L D I nb mb P ge pw sh₁ ∧ (∀ th', th' ≠ ctx.thread → tview sh₁ th' = tview sh th') ∧
      TPre C D I nb mb s i k (v + 1) (tview sh₁ ctx.thread) := by
  have hT13 := hok.tiles_lt13
  obtain ⟨sh₁, hacc, hm1, hoth1, hT1, -⟩ := resume_acc C hS hok hl (by omega) hloc hm hT
  have h37 : setLocal l 55 (accV C D I nb mb s i k v t) 37 = some (u32 t) := by
    rw [setLocal_other _ _ (by decide)]; exact hloc.l37
  refine ⟨sh₁, ?_, hm1, hoth1, ⟨hT1.wrow, fun t' ht' => ?_, hT1.q, hT1.s2, hT1.b2⟩⟩
  · rw [Fc_eq, ← ht]
    exact resume_loop_exit C hacc (.inl rfl) h37 (by norm_num) (by omega) (by omega)
      (eval_u32lit C _ _ _ (by omega)) (by omega)
  · have := hT1.acc t' ht'
    simp only [show t' < t + 1 from by omega, ite_true] at this
    simpa [Nat.add_assoc] using this

/-- The next column of the chunk. -/
theorem lane_col (hS : Shape L D A) (hok : Ok D) {i : Fin 32} (hl : Lane D ctx nb mb s i) {k v t : Nat}
    (hk : stepOf D s k < D.K / 256) (hv : v < 32) (hc : v % 4 + 1 < 4) (ht : t + 1 = D.tiles) {l : Locals} {sh : Shared}
    (hloc : TileLoc C D I ctx nb mb s i k v t l) (hm : Mem C L D I nb mb P ge pw sh)
    (hT : TAt C D I nb mb s i k v t (tview sh ctx.thread)) :
    ∃ l' sh', Reaches C ⟨ctx, setLocal l 55 (accV C D I nb mb s i k v t), Fc D, .running⟩ sh
        ⟨ctx, l', Fc D, collAt C D I nb mb s i k (v + 1) 0⟩ sh' ∧
      TileLoc C D I ctx nb mb s i k (v + 1) 0 l' ∧ Mem C L D I nb mb P ge pw sh' ∧
      (∀ th', th' ≠ ctx.thread → tview sh' th' = tview sh th') ∧
      TAt C D I nb mb s i k (v + 1) 0 (tview sh' ctx.thread) := by
  obtain ⟨sh₁, hex, hm1, hoth1, hT1⟩ := exit_tile C hS hok hl ht hloc hm hT
  generalize hl1 : setLocal (setLocal l 55 (accV C D I nb mb s i k v t)) 37 (u32 D.tiles) = l₁ at hex
  have ag1 : ∀ j, j ≤ 36 → l₁ j = l j := fun j hj => by
    rw [← hl1, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
  have h34 : l₁ 34 = some (u32 (v % 4)) := (ag1 34 (by omega)).trans hloc.col.l34
  generalize hl2 : setLocal l₁ 34 (u32 (v % 4 + 1)) = l₂
  have hs4 : S4Loc C D I ctx nb mb s i k (v / 4) l₂ := by
    rw [← hl2]
    exact ⟨hloc.col.step.of_eq fun j hj => by rw [setLocal_other _ _ (by omega), ag1 j (by omega)],
      by rw [setLocal_other _ _ (by omega), ag1 _ (by omega)]; exact hloc.col.l31,
      by rw [setLocal_other _ _ (by omega), ag1 _ (by omega)]; exact hloc.col.l32,
      by rw [setLocal_other _ _ (by omega), ag1 _ (by omega)]; exact hloc.col.l33⟩
  have hv' : 4 * (v / 4) + (v % 4 + 1) = v + 1 := by omega
  obtain ⟨l', sh', hcol, hloc', hm', hoth', hT'⟩ := exec_col C hS hok hl hk (by omega) hc hs4
    (by rw [← hl2, setLocal_same]) hm1 (by rw [hv']; exact hT1)
  rw [hv'] at hcol hloc' hT'
  refine ⟨l', sh', hex.trans ?_, hloc', hm', fun th' h => by rw [hoth' th' h, hoth1 th' h], hT'⟩
  exact resume_loop_stop C (.nil _ _) (.inl rfl) h34 (by norm_num) (by omega) (by norm_num)
    (eval_u32lit C _ _ _ (by norm_num)) hc (by rw [hl2]; exact hcol)

/-- The next chunk. -/
theorem lane_chunk (hS : Shape L D A) (hok : Ok D) {i : Fin 32} (hl : Lane D ctx nb mb s i) {k v t : Nat}
    (hk : stepOf D s k < D.K / 256) (hv : v < 32) (hc : v % 4 = 3) (hs4 : v / 4 + 1 < 8) (ht : t + 1 = D.tiles)
    {l : Locals} {sh : Shared} (hloc : TileLoc C D I ctx nb mb s i k v t l) (hm : Mem C L D I nb mb P ge pw sh)
    (hT : TAt C D I nb mb s i k v t (tview sh ctx.thread)) :
    ∃ l' sh', Reaches C ⟨ctx, setLocal l 55 (accV C D I nb mb s i k v t), Fc D, .running⟩ sh
        ⟨ctx, l', Fc D, collAt C D I nb mb s i k (v + 1) 0⟩ sh' ∧
      TileLoc C D I ctx nb mb s i k (v + 1) 0 l' ∧ Mem C L D I nb mb P ge pw sh' ∧
      (∀ th', th' ≠ ctx.thread → tview sh' th' = tview sh th') ∧
      TAt C D I nb mb s i k (v + 1) 0 (tview sh' ctx.thread) := by
  obtain ⟨sh₁, hex, hm1, hoth1, hT1⟩ := exit_tile C hS hok hl ht hloc hm hT
  generalize hl1 : setLocal (setLocal l 55 (accV C D I nb mb s i k v t)) 37 (u32 D.tiles) = l₁ at hex
  have ag1 : ∀ j, j ≤ 36 → l₁ j = l j := fun j hj => by
    rw [← hl1, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
  have h34 : l₁ 34 = some (u32 (v % 4)) := (ag1 34 (by omega)).trans hloc.col.l34
  have hex2 := resume_loop_exit C (ctx := ctx) (ss := []) (K := [frameOf 31 (u32l 8) 1 (s4Body D.bits D.tiles), .block [],
    frameOf 20 (u32l (D.K / 256)) D.splits (stepBody D.bits D.tiles), .block (after D)])
    (i := 34) (n := 4) (d := 1) (bound := u32l 4) (body := columnBody D.bits D.tiles) (.nil l₁ sh₁) (.inl rfl) h34 (by norm_num) (by omega) (by norm_num)
    (eval_u32lit C _ _ _ (by norm_num)) (by omega)
  generalize hl2 : setLocal l₁ 34 (u32 (v % 4 + 1)) = l₂ at hex2
  have ag2 : ∀ j, j ≤ 33 → l₂ j = l j := fun j hj => by rw [← hl2, setLocal_other _ _ (by omega), ag1 j (by omega)]
  have h31 : l₂ 31 = some (u32 (v / 4)) := (ag2 31 (by omega)).trans hloc.col.l31
  generalize hl3 : setLocal l₂ 31 (u32 (v / 4 + 1)) = l₃
  have hst : StepLoc D ctx nb mb s i k l₃ :=
    hloc.col.step.of_eq fun j hj => by rw [← hl3, setLocal_other _ _ (by omega), ag2 j (by omega)]
  have hv' : 4 * (v / 4 + 1) = v + 1 := by omega
  obtain ⟨l', sh', hs4x, hloc', hm', hoth', hT'⟩ := exec_s4 C hS hok hl hk hs4 hst (by rw [← hl3, setLocal_same]) hm1
    (by rw [hv']; exact hT1)
  rw [hv'] at hs4x hloc' hT'
  refine ⟨l', sh', hex.trans (hex2.trans ?_), hloc', hm', fun th' h => by rw [hoth' th' h, hoth1 th' h], hT'⟩
  exact resume_loop_stop C (.nil _ _) (.inl rfl) h31 (by norm_num) (by omega) (by norm_num)
    (eval_u32lit C _ _ _ (by norm_num)) hs4 (by rw [hl3]; exact hs4x)

theorem stepOf_succ (D : Dims) (s k : Nat) : stepOf D s k + D.splits = stepOf D s (k + 1) := by unfold stepOf; ring

/-- The next K step. -/
theorem lane_kstep (hS : Shape L D A) (hok : Ok D) {i : Fin 32} (hl : Lane D ctx nb mb s i) {k t : Nat}
    (hk1 : stepOf D s (k + 1) < D.K / 256) (ht : t + 1 = D.tiles)
    {l : Locals} {sh : Shared} (hloc : TileLoc C D I ctx nb mb s i k 31 t l) (hm : Mem C L D I nb mb P ge pw sh)
    (hT : TAt C D I nb mb s i k 31 t (tview sh ctx.thread)) :
    ∃ l' sh', Reaches C ⟨ctx, setLocal l 55 (accV C D I nb mb s i k 31 t), Fc D, .running⟩ sh
        ⟨ctx, l', Fc D, collAt C D I nb mb s i (k + 1) 0 0⟩ sh' ∧
      TileLoc C D I ctx nb mb s i (k + 1) 0 0 l' ∧ Mem C L D I nb mb P ge pw sh' ∧
      (∀ th', th' ≠ ctx.thread → tview sh' th' = tview sh th') ∧
      TAt C D I nb mb s i (k + 1) 0 0 (tview sh' ctx.thread) := by
  have hK := hok.Kle
  obtain ⟨sh₁, hex, hm1, hoth1, hT1⟩ := exit_tile C hS hok hl ht hloc hm hT
  generalize hl1 : setLocal (setLocal l 55 (accV C D I nb mb s i k 31 t)) 37 (u32 D.tiles) = l₁ at hex
  have ag1 : ∀ j, j ≤ 36 → l₁ j = l j := fun j hj => by
    rw [← hl1, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
  have h34 : l₁ 34 = some (u32 3) := (ag1 34 (by omega)).trans hloc.col.l34
  have hex2 := resume_loop_exit C (ctx := ctx) (ss := []) (K := [frameOf 31 (u32l 8) 1 (s4Body D.bits D.tiles), .block [],
    frameOf 20 (u32l (D.K / 256)) D.splits (stepBody D.bits D.tiles), .block (after D)])
    (i := 34) (n := 4) (d := 1) (bound := u32l 4) (body := columnBody D.bits D.tiles) (.nil l₁ sh₁) (.inl rfl) h34 (by norm_num) (by omega) (by norm_num)
    (eval_u32lit C _ _ _ (by norm_num)) (by omega)
  generalize hl2 : setLocal l₁ 34 (u32 (3 + 1)) = l₂ at hex2
  have ag2 : ∀ j, j ≤ 33 → l₂ j = l j := fun j hj => by rw [← hl2, setLocal_other _ _ (by omega), ag1 j (by omega)]
  have h31 : l₂ 31 = some (u32 7) := (ag2 31 (by omega)).trans hloc.col.l31
  have hex3 := resume_loop_exit C (ctx := ctx) (ss := []) (K := [frameOf 20 (u32l (D.K / 256)) D.splits
    (stepBody D.bits D.tiles), .block (after D)]) (i := 31) (n := 8) (d := 1) (bound := u32l 8) (body := s4Body D.bits D.tiles) (.nil l₂ sh₁) (.inl rfl) h31
    (by norm_num) (by omega) (by norm_num) (eval_u32lit C _ _ _ (by norm_num)) (by omega)
  generalize hl3 : setLocal l₂ 31 (u32 (7 + 1)) = l₃ at hex3
  have ag3 : ∀ j, j ≤ 30 → l₃ j = l j := fun j hj => by rw [← hl3, setLocal_other _ _ (by omega), ag2 j (by omega)]
  have h20 : l₃ 20 = some (u32 (stepOf D s k)) := (ag3 20 (by omega)).trans hloc.col.step.l20
  generalize hl4 : setLocal l₃ 20 (u32 (stepOf D s k + D.splits)) = l₄
  have hF4 : Fix D ctx nb mb s i l₄ :=
    hloc.col.step.fix.of_eq fun j hj => by rw [← hl4, setLocal_other _ _ (by omega), ag3 j (by omega)]
  obtain ⟨l', sh', hstx, hloc', hm', hoth', hT'⟩ := exec_step C hS hok hl hk1 hF4
    (by rw [← hl4, setLocal_other _ _ (by omega), ag3 19 (by omega)]; exact hloc.col.step.l19)
    (by rw [← hl4, setLocal_same, stepOf_succ]) hm1 hT1.wrow
    (fun t' ht' => by have := hT1.acc t' ht'; rwa [show 32 * k + (31 + 1) = 32 * (k + 1) by ring] at this)
  refine ⟨l', sh', hex.trans (hex2.trans (hex3.trans ?_)), hloc', hm', fun th' h => by rw [hoth' th' h, hoth1 th' h], hT'⟩
  exact resume_loop_stop C (n := D.K / 256) (d := D.splits) (.nil _ _) (.inl rfl) h20 (by have := hok.splitsK; omega) (by rw [stepOf_succ]; omega)
    (by omega) (eval_u32lit C _ _ _ (by omega)) (by rw [stepOf_succ]; exact hk1) (by rw [hl4]; exact hstx)

end Next
end Metal.Kernels.SplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

/-- Lane `i`'s two `C` elements of a tile: `8·fm + fn + j`, and back. -/
theorem lane_facts : ∀ i < 32, ∀ j < 2, (laneOf (8 * fmOf i + fnOf i + j)).val = i ∧
    (8 * fmOf i + fnOf i + j) % 2 = j ∧ 8 * fmOf i + fnOf i + j < 64 := by decide

theorem lane_iff : ∀ i < 32, ∀ e < 64, ((laneOf e).val = i ↔ (e = 8 * fmOf i + fnOf i ∨ e = 8 * fmOf i + fnOf i + 1)) := by
  decide

theorem part_eq (C : M1Max.Contract) (D : Dims) (I : In) (nb mb s t : Nat) (i : Fin 32) (j : Nat) (hj : j < 2) :
    part C D I nb mb s t (8 * fmOf i + fnOf i + j) = accAt C D I nb mb s t (32 * nsteps D s) i ⟨j, hj⟩ := by
  obtain ⟨h1, h2, -⟩ := lane_facts i i.isLt j hj
  unfold part
  rw [show laneOf (8 * fmOf i + fnOf i + j) = i from Fin.ext h1,
    show (⟨(8 * fmOf i + fnOf i + j) % 2, Nat.mod_lt _ (by decide)⟩ : Fin 2) = ⟨j, hj⟩ from Fin.ext h2]

theorem cells_pair_split {B : ByteMemory.Bytes} {o : Nat} {x y : Float32} (h : cells B o 8 = pairBytes x y) :
    cells B o 4 = wordBytes 4 (Val.f32Bits x) ∧ cells B (o + 4) 4 = wordBytes 4 (Val.f32Bits y) := by
  have h' : cells B o (4 + 4) = pairBytes x y := h
  rw [cells_append] at h'
  exact List.append_inj h' (by rw [cells_length, wordBytes_length])

def ps0 (D : Dims) : CStmt :=
  .store (.scalar .f32) (partAt D.tiles (.local 7) (.local 57)
    (AffineSplitMma.u32 .add (AffineSplitMma.u32 .mul (.local 8) (u32l 8)) (.local 9))) (accElement 0)

def ps1 (D : Dims) : CStmt :=
  .store (.scalar .f32) (partAt D.tiles (.local 7) (.local 57)
    (AffineSplitMma.u32 .add (AffineSplitMma.u32 .add (AffineSplitMma.u32 .mul (.local 8) (u32l 8)) (.local 9))
      (u32l 1))) (accElement 1)

/-- After the barrier: `e` and the output loop. -/
def outRest (D : Dims) : List CStmt :=
  [.set 58 (AffineSplitMma.u32 .add (AffineSplitMma.u32 .mul (.local 7) (u32l 32)) (.local 6)),
   loopOf 58 (u32l (64 * D.tiles)) (32 * D.splits) (outBody D.N D.tiles D.splits)]

theorem after_eq (D : Dims) : after D =
    .array 56 true 0 (.scalar .f32) :: (forU 57 (u32l D.tiles) [ps0 D, ps1 D] ++ (.barrier 2 false true :: outRest D)) :=
  rfl

section Last
variable (C : M1Max.Contract) {L : Launch} {A : Al} {I : In} {P : Nat} {pw : Nat → Nat → Nat → Prop} {ctx : Ctx}
  {D : Dims} {nb mb s : Nat}

/-- `part[sg][t][8·fm + fn + j] = acc[t].thread_elements()[j]`. -/
theorem exec_pstore (hS : Shape L D A) (hok : Ok D) {i : Fin 32} (hl : Lane D ctx nb mb s i) (j : Nat) (hj : j < 2)
    {t : Nat} (ht : t < D.tiles) {l : Locals} {sh : Shared} (hF : Fix D ctx nb mb s i l)
    (h56 : l 56 = some (.ptr ⟨6, 0, .scalar .f32⟩)) (h57 : l 57 = some (u32 t))
    (hm : Mem C L D I nb mb P (nb + mb * gy D) pw sh)
    (hacc : cells (tview sh ctx.thread 1) (8 * t) 8 = pairBytes (accAt C D I nb mb s t (32 * nsteps D s) i 0)
      (accAt C D I nb mb s t (32 * nsteps D s) i 1)) :
    ∃ sh', Exec C ctx [if j = 0 then ps0 D else ps1 D] l sh .normal l sh' ∧
      Mem C L D I nb mb P (nb + mb * gy D) (fun s' t' e => pw s' t' e ∨ (s' = s ∧ t' = t ∧ e = 8 * fmOf i + fnOf i + j))
        sh' ∧ (∀ th', tview sh' th' = tview sh th') := by
  have hT13 := hok.tiles_lt13
  have hs := hl.hs
  have hsp : D.splits < 2 ^ 8 := by have := hok.splitsK; have := hok.Kle; omega
  obtain ⟨hl1, hl2, he⟩ := lane_facts i i.isLt j hj
  -- the value
  have hp1 := eval_offset_u32 C (ctx := ctx) (o := 0) (sh := sh) (eval_local' C hF.l18 sh) (eval_local' C h57 sh) (by omega)
  rw [show 0 + t * (Ty.vec .f32 2).bytes = 8 * t by show 0 + t * 8 = 8 * t; ring] at hp1
  have hp2 := eval_offset_i32 C (o := 8 * t) (eval_ptrCast C (t := .scalar .f32) hp1)
    (eval_i32lit_raw C (ctx := ctx) (l := l) (sh := sh) j) (by omega)
  rw [show 8 * t + j * (Ty.scalar .f32).bytes = 8 * t + 4 * j by simp only [Ty.bytes, Scalar.bytes]; ring, hl.ta] at hp2
  obtain ⟨hc0, hc1⟩ := cells_pair_split hacc
  rw [tview_lt (by decide)] at hc0 hc1
  have hval : (eval C ctx l (accElement j)).run sh =
      some (.f32 (accAt C D I nb mb s t (32 * nsteps D s) i ⟨j, hj⟩), sh) := by
    refine (eval_load C ctx l _ _ _ sh sh hp2).trans (load_t ctx _ _ sh (ta ctx.thread 1) (8 * t + 4 * j) (8 * D.tiles) 8 _
      (by rw [hm.regions]; exact hS.t1 _) (by simp [alignment, Scalar.bytes]) (by simp [alignment, Scalar.bytes]; omega)
      (by simp only [Ty.bytes, Scalar.bytes]; omega) ?_)
    rw [show (Ty.scalar .f32).bytes = 4 from rfl]
    rcases (show j = 0 ∨ j = 1 by omega) with rfl | rfl
    · rw [Nat.mul_zero, Nat.add_zero, hc0]; exact decode_f32_bytes _
    · rw [Nat.mul_one, hc1]; exact decode_f32_bytes _
  -- the destination
  have hgy : D.splits * (64 * D.tiles) < 2 ^ 32 := by
    have : D.splits * (64 * D.tiles) ≤ 2 ^ 8 * (64 * 2 ^ 13) := Nat.mul_le_mul (by omega) (by omega)
    omega
  have hst : s * (64 * D.tiles) < 2 ^ 32 :=
    lt_of_le_of_lt (Nat.mul_le_mul_right _ (by omega : s ≤ D.splits)) hgy
  have hq0 := eval_offset_u64 C (ctx := ctx) (o := 0) (sh := sh) (r := 6) (e := .scalar .f32) (n := s * (64 * D.tiles))
    (eval_local' C h56 sh) (eval_mul_u64 C (site := 0) (eval_toU64 C (eval_local' C hF.l7 sh) (by omega))
      (eval_u64lit C _ _ (64 * D.tiles) (by omega))) (by omega)
  have hq1 := eval_offset_u64 C (n := t * 64) hq0 (eval_mul_u64 C (site := 0) (eval_toU64 C (eval_local' C h57 sh) (by omega))
    (eval_u64lit C _ _ 64 (by norm_num))) (by omega)
  have hidx : (eval C ctx l (if j = 0 then AffineSplitMma.u32 .add (AffineSplitMma.u32 .mul (.local 8) (u32l 8)) (.local 9)
      else AffineSplitMma.u32 .add (AffineSplitMma.u32 .add (AffineSplitMma.u32 .mul (.local 8) (u32l 8)) (.local 9))
        (u32l 1))).run sh = some (u32 (8 * fmOf i + fnOf i + j), sh) := by
    have h0 := eval_bin_u32 C (ctx := ctx) (l := l) (sh := sh) (op := .add) (site := 0)
      (eval_bin_u32 C (op := .mul) (site := 0) (eval_local' C hF.l8 sh) (eval_u32lit C _ sh 8 (by norm_num))
        (binary_mul_u32 C _ 8)) (eval_local' C hF.l9 sh) (binary_add_u32 C _ _)
    rw [show fmOf i * 8 + fnOf i = 8 * fmOf i + fnOf i by ring] at h0
    rcases (show j = 0 ∨ j = 1 by omega) with rfl | rfl
    · exact h0
    · exact eval_bin_u32 C h0 (eval_u32lit C _ sh 1 (by norm_num)) (binary_add_u32 C _ 1)
  have hq2 := eval_offset_u32 C hq1 hidx (by omega)
  have hix : s * (64 * D.tiles) + t * 64 + (8 * fmOf i + fnOf i + j) < D.splits * (64 * D.tiles) := by
    have h1 : t * 64 + (8 * fmOf i + fnOf i + j) < 64 * D.tiles := by
      have : (t + 1) * 64 ≤ D.tiles * 64 := Nat.mul_le_mul_right _ ht
      rw [Nat.add_mul, Nat.one_mul] at this; omega
    have h2 : (s + 1) * (64 * D.tiles) ≤ D.splits * (64 * D.tiles) := Nat.mul_le_mul_right _ hs
    rw [Nat.add_mul, Nat.one_mul] at h2; omega
  rw [show 0 + s * (64 * D.tiles) * (Ty.scalar .f32).bytes + t * 64 * (Ty.scalar .f32).bytes +
    (8 * fmOf i + fnOf i + j) * (Ty.scalar .f32).bytes =
    4 * (s * (64 * D.tiles) + t * 64 + (8 * fmOf i + fnOf i + j)) by simp only [Ty.bytes, Scalar.bytes]; ring] at hq2
  have hsto := store_shared ctx .f32 sh 6 (4 * (s * (64 * D.tiles) + t * 64 + (8 * fmOf i + fnOf i + j))) _
    (.f32 (accAt C D I nb mb s t (32 * nsteps D s) i ⟨j, hj⟩)) _ (by rw [hm.regions]; exact hS.r6) (by simp) (by simp)
    (by simp [Scalar.bytes]) (by simp [Scalar.bytes])
    (by simp only [Scalar.bytes]; rw [show D.splits * D.tiles * 64 = D.splits * (64 * D.tiles) by ring]; omega)
    (encode_f32 _)
  rw [show Scalar.f32.bytes = 4 from rfl] at hsto
  have hw := hm.wpart hS ctx (s := s) (t := t) (e := 8 * fmOf i + fnOf i + j) hs ht he
    (by rw [hl.thread, hl1]; ring) hl.group
  rw [part_eq C D I nb mb s t i j hj] at hw
  refine ⟨_, ?_, hw, fun th' => tview_wrn (by decide)⟩
  have hex : Exec C ctx [.store (.scalar .f32) (partAt D.tiles (.local 7) (.local 57)
      (if j = 0 then AffineSplitMma.u32 .add (AffineSplitMma.u32 .mul (.local 8) (u32l 8)) (.local 9)
        else AffineSplitMma.u32 .add (AffineSplitMma.u32 .add (AffineSplitMma.u32 .mul (.local 8) (u32l 8)) (.local 9))
          (u32l 1))) (accElement j)] l sh .normal l _ :=
    .store hq2 hval hsto (.nil _ _)
  rcases (show j = 0 ∨ j = 1 by omega) with rfl | rfl
  · exact hex
  · exact hex

/-- The lane's last multiply-accumulate's step: the loops' exits, `part`, and the barrier. -/
theorem lane_last (hS : Shape L D A) (hok : Ok D) {i : Fin 32} (hl : Lane D ctx nb mb s i) {k t : Nat}
    (hkn : k + 1 = nsteps D s) (hk : stepOf D s k < D.K / 256) (hk1 : D.K / 256 ≤ stepOf D s (k + 1))
    (ht : t + 1 = D.tiles)
    {l : Locals} {sh : Shared} (hloc : TileLoc C D I ctx nb mb s i k 31 t l)
    (hm : Mem C L D I nb mb P (nb + mb * gy D) pw sh) (hT : TAt C D I nb mb s i k 31 t (tview sh ctx.thread)) :
    ∃ l' sh', Reaches C ⟨ctx, setLocal l 55 (accV C D I nb mb s i k 31 t), Fc D, .running⟩ sh
        ⟨ctx, l', [.block (outRest D)], .barrier 2 false true⟩ sh' ∧ Fix D ctx nb mb s i l' ∧
      l' 56 = some (.ptr ⟨6, 0, .scalar .f32⟩) ∧
      Mem C L D I nb mb P (nb + mb * gy D)
        (fun s' t' e => pw s' t' e ∨ (s' = s ∧ t' < D.tiles ∧ e < 64 ∧ (laneOf e).val = i)) sh' ∧
      (∀ th', th' ≠ ctx.thread → tview sh' th' = tview sh th') := by
  have hK := hok.Kle; have hT13 := hok.tiles_lt13
  have hsp : D.splits < 2 ^ 8 := by have := hok.splitsK; omega
  obtain ⟨sh₁, hex, hm1, hoth1, hT1⟩ := exit_tile C hS hok hl ht hloc hm hT
  generalize hl1 : setLocal (setLocal l 55 (accV C D I nb mb s i k 31 t)) 37 (u32 D.tiles) = l₁ at hex
  have ag1 : ∀ j, j ≤ 36 → l₁ j = l j := fun j hj => by
    rw [← hl1, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
  have h34 : l₁ 34 = some (u32 3) := (ag1 34 (by omega)).trans hloc.col.l34
  have hex2 := resume_loop_exit C (ctx := ctx) (ss := []) (K := [frameOf 31 (u32l 8) 1 (s4Body D.bits D.tiles), .block [],
    frameOf 20 (u32l (D.K / 256)) D.splits (stepBody D.bits D.tiles), .block (after D)])
    (i := 34) (n := 4) (d := 1) (bound := u32l 4) (body := columnBody D.bits D.tiles) (.nil l₁ sh₁) (.inl rfl) h34
    (by norm_num) (by omega) (by norm_num) (eval_u32lit C _ _ _ (by norm_num)) (by omega)
  generalize hl2 : setLocal l₁ 34 (u32 (3 + 1)) = l₂ at hex2
  have ag2 : ∀ j, j ≤ 33 → l₂ j = l j := fun j hj => by rw [← hl2, setLocal_other _ _ (by omega), ag1 j (by omega)]
  have h31 : l₂ 31 = some (u32 7) := (ag2 31 (by omega)).trans hloc.col.l31
  have hex3 := resume_loop_exit C (ctx := ctx) (ss := []) (K := [frameOf 20 (u32l (D.K / 256)) D.splits
    (stepBody D.bits D.tiles), .block (after D)]) (i := 31) (n := 8) (d := 1) (bound := u32l 8)
    (body := s4Body D.bits D.tiles) (.nil l₂ sh₁) (.inl rfl) h31
    (by norm_num) (by omega) (by norm_num) (eval_u32lit C _ _ _ (by norm_num)) (by omega)
  generalize hl3 : setLocal l₂ 31 (u32 (7 + 1)) = l₃ at hex3
  have ag3 : ∀ j, j ≤ 30 → l₃ j = l j := fun j hj => by rw [← hl3, setLocal_other _ _ (by omega), ag2 j (by omega)]
  have h20 : l₃ 20 = some (u32 (stepOf D s k)) := (ag3 20 (by omega)).trans hloc.col.step.l20
  have hex4 := resume_loop_exit C (ctx := ctx) (ss := after D) (K := []) (i := 20) (n := D.K / 256) (d := D.splits)
    (bound := u32l (D.K / 256)) (body := stepBody D.bits D.tiles) (.nil l₃ sh₁) (.inl rfl) h20 (by omega)
    (by have := stepOf_succ D s k; omega) (by omega) (eval_u32lit C _ _ _ (by omega)) (by rw [stepOf_succ]; exact hk1)
  generalize hl4 : setLocal l₃ 20 (u32 (stepOf D s k + D.splits)) = l₄ at hex4
  have hF4 : Fix D ctx nb mb s i l₄ :=
    hloc.col.step.fix.of_eq fun j hj => by rw [← hl4, setLocal_other _ _ (by omega), ag3 j (by omega)]
  generalize hl5 : setLocal l₄ 56 (.ptr ⟨if true = true then ctx.groupArray 0 else ctx.threadArray 0, 0, .scalar .f32⟩) = l₅
  have hF5 : Fix D ctx nb mb s i l₅ := by rw [← hl5]; exact hF4.set _ (by omega)
  have h56 : l₅ 56 = some (.ptr ⟨6, 0, .scalar .f32⟩) := by rw [← hl5, setLocal_same, ite_eq_left rfl, hl.ga]
  have hacc : ∀ t' < D.tiles, cells (tview sh₁ ctx.thread 1) (8 * t') 8 =
      pairBytes (accAt C D I nb mb s t' (32 * nsteps D s) i 0) (accAt C D I nb mb s t' (32 * nsteps D s) i 1) := by
    intro t' ht'
    have := hT1.acc t' ht'
    rwa [show 32 * k + (31 + 1) = 32 * nsteps D s by rw [← hkn]; ring] at this
  let R : Nat → Locals → Shared → Prop := fun t' l' sh' => (∀ j, j ≠ 57 → l' j = l₅ j) ∧
    l' 57 = some (u32 (0 + 1 * t')) ∧
    Mem C L D I nb mb P (nb + mb * gy D) (fun s' t'' e => pw s' t'' e ∨ (s' = s ∧ t'' < t' ∧ e < 64 ∧ (laneOf e).val = i))
      sh' ∧ (∀ th', tview sh' th' = tview sh₁ th')
  have hbody : ∀ t' < D.tiles, ∀ l₀ sh₀, R t' l₀ sh₀ → ∃ o l₁' sh₁', (o = .normal ∨ o = .continue_) ∧
      Exec C ctx [ps0 D, ps1 D] l₀ sh₀ o l₁' sh₁' ∧ l₁' 57 = some (u32 (0 + 1 * t')) ∧
      R (t' + 1) (setLocal l₁' 57 (u32 (0 + 1 * (t' + 1)))) sh₁' := by
    intro t' ht' l₀ sh₀ hR
    obtain ⟨ag, h57, hm0, hv0⟩ := hR
    have h57' : l₀ 57 = some (u32 t') := by rw [h57, Nat.zero_add, Nat.one_mul]
    have hF0 : Fix D ctx nb mb s i l₀ := hF5.of_eq fun j hj => ag j (by omega)
    have h56' : l₀ 56 = some (.ptr ⟨6, 0, .scalar .f32⟩) := (ag 56 (by omega)).trans h56
    obtain ⟨sha, hea, hma, hva⟩ := exec_pstore C hS hok hl 0 (by norm_num) ht' hF0 h56' h57' hm0
      (by rw [hv0]; exact hacc t' ht')
    obtain ⟨shb, heb, hmb, hvb⟩ := exec_pstore C hS hok hl 1 (by norm_num) ht' hF0 h56' h57' hma
      (by rw [hva, hv0]; exact hacc t' ht')
    refine ⟨.normal, l₀, shb, .inl rfl, hea.append heb, h57, fun j hj => ?_, setLocal_same _ _ _, ?_,
      fun th' => by rw [hvb, hva, hv0]⟩
    · rw [setLocal_other _ _ hj]; exact ag j hj
    · refine hmb.mono fun s' t'' e h => ?_
      rcases h with h | ⟨rfl, ht'', he, hle⟩
      · exact .inl (.inl (.inl h))
      · by_cases htt : t'' < t'
        · exact .inl (.inl (.inr ⟨rfl, htt, he, hle⟩))
        · have htt' : t'' = t' := by omega
          rcases (lane_iff i i.isLt e he).mp hle with h | h
          · exact .inl (.inr ⟨rfl, htt', by omega⟩)
          · exact .inr ⟨rfl, htt', h⟩
  obtain ⟨l₆, sh₂, hfor, hR⟩ := exec_count C (ctx := ctx) 57 1 D.tiles D.tiles 0 (u32l D.tiles) [ps0 D, ps1 D] R
    (by omega) (by norm_num) (fun k _ => by omega) (by omega)
    (fun k _ l' sh' hq => ⟨hq.2.1, eval_u32lit C _ _ _ (by omega)⟩) hbody (l := setLocal l₅ 57 (u32 0)) (sh := sh₁)
    ⟨fun j hj => setLocal_other _ _ hj, setLocal_same _ _ _,
      hm1.mono fun s' t' e h => h.elim id (fun ⟨_, h, _⟩ => absurd h (Nat.not_lt_zero _)), fun _ => rfl⟩
  obtain ⟨ag6, -, hm6, hv6⟩ := hR
  have hafter : Exec C ctx (after D) l₄ sh₁ (.stop (.barrier 2 false true) [.block (outRest D)]) l₆ sh₂ := by
    rw [after_eq]
    exact .array (by rw [hl5]; exact (Exec.set (eval_u32lit C _ _ 0 (by norm_num)) hfor).append .barrier)
  refine ⟨l₆, sh₂, hex.trans (hex2.trans (hex3.trans (hex4.trans ?_))),
    hF5.of_eq fun j hj => ag6 j (by omega), (ag6 56 (by omega)).trans h56, hm6, fun th' h => by rw [hv6, hoth1 th' h]⟩
  simpa using hafter.reaches_stop (K := [])

end Last
end Metal.Kernels.SplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

theorem out_div {T nb r : Nat} (hT : 0 < T) (hr : r < 8 * T) :
    (8 * T * nb + r) / (8 * T) = nb ∧ (8 * T * nb + r) % (8 * T) = r := by
  refine ⟨?_, ?_⟩
  · rw [Nat.add_comm, Nat.add_mul_div_left _ _ (by omega), Nat.div_eq_of_lt hr, Nat.zero_add]
  · rw [Nat.add_comm, Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt hr]

/-- The column and row of the output loop's iteration `e` in threadgroup `(·, nb, mb)`. -/
def ocol (D : Dims) (nb e : Nat) : Nat := 8 * D.tiles * nb + (8 * (e / 64) + e % 64 / 8)
def orow (mb e : Nat) : Nat := 8 * mb + e % 8

theorem out_facts (D : Dims) (hok : Ok D) {nb mb e : Nat} (hnb : nb < gy D) (he : e < 64 * D.tiles) :
    ocol D nb e < D.N ∧ ocol D nb e / (8 * D.tiles) = nb ∧ ocol D nb e % (8 * D.tiles) / 8 = e / 64 ∧
      ocol D nb e % 8 = e % 64 / 8 ∧ orow mb e / 8 = mb ∧ orow mb e % 8 = e % 8 ∧ eloc D (orow mb e) (ocol D nb e) = e ∧
      grp D (orow mb e) (ocol D nb e) = nb + mb * gy D := by
  have hT := hok.tiles
  have hr : 8 * (e / 64) + e % 64 / 8 < 8 * D.tiles := by
    have : e / 64 < D.tiles := by omega
    omega
  obtain ⟨h1, h2⟩ := out_div (nb := nb) hT hr
  have hn0 := n0_lt hnb
  have hn8 : ocol D nb e % 8 = e % 64 / 8 := by
    unfold ocol
    rw [show 8 * D.tiles * nb = 8 * (D.tiles * nb) by ring, Nat.add_comm, Nat.add_mul_mod_self_left]
    omega
  have hm1 : orow mb e / 8 = mb := by unfold orow; omega
  have hm2 : orow mb e % 8 = e % 8 := by unfold orow; omega
  refine ⟨by unfold ocol; omega, h1, by unfold ocol; rw [h2]; omega, hn8, hm1, hm2, ?_, ?_⟩
  · unfold eloc; rw [show ocol D nb e % (8 * D.tiles) = 8 * (e / 64) + e % 64 / 8 from h2, hn8, hm2]; omega
  · unfold grp; rw [show ocol D nb e / (8 * D.tiles) = nb from h1, hm1]

theorem outBody_eq (N tiles splits : Nat) : outBody N tiles splits =
    [.set 59 (AffineSplitMma.u32 .div (.local 58) (u32l 64)),
     .set 60 (AffineSplitMma.u32 .div (AffineSplitMma.u32 .rem (.local 58) (u32l 64)) (u32l 8)),
     .set 61 (AffineSplitMma.u32 .rem (.local 58) (u32l 8)),
     .ite (AffineSplitMma.u32 .ge (AffineSplitMma.u32 .add (.local 12) (.local 61)) (.local 10)) [.continue_] [],
     .set 62 (f32l 0x0)] ++
    (forU 63 (u32l splits) [.set 62 (.bin .add .f32 0 (.local 62) (.load (.scalar .f32)
      (partAt tiles (.local 63) (.local 59) (AffineSplitMma.u32 .add (AffineSplitMma.u32 .mul (.local 60) (u32l 8))
        (.local 61)))))] ++
    [.store (.scalar .bf16) (.offset (.local 5) (AffineSplitMma.u64 .add (AffineSplitMma.u64 .add
      (AffineSplitMma.u64 .add (AffineSplitMma.u64 .mul (toU64 (AffineSplitMma.u32 .add (.local 12) (.local 61)))
        (u64l N)) (toU64 (.local 11))) (toU64 (AffineSplitMma.u32 .mul (u32l 8) (.local 59)))) (toU64 (.local 60))))
      (.conv .bf16 (.local 62))]) := rfl

section Out
variable (C : M1Max.Contract) {L : Launch} {A : Al} {I : In} {pw : Nat → Nat → Nat → Prop} {ctx : Ctx}
  {D : Dims} {nb mb s : Nat}

/-- The sum over the splits of `part[·][t][8·r + m]` (`t`, `r`, `m` in slots 59 … 61). -/
theorem exec_sum (hS : Shape L D A) (hok : Ok D) {i : Fin 32} (hl : Lane D ctx nb mb s i) {t rr m : Nat}
    (ht : t < D.tiles) (hrr : rr < 8) (hm8 : m < 8) {l : Locals} {sh : Shared} {P : Nat}
    (h56 : l 56 = some (.ptr ⟨6, 0, .scalar .f32⟩)) (h59 : l 59 = some (u32 t)) (h60 : l 60 = some (u32 rr))
    (h61 : l 61 = some (u32 m)) (hm : Mem C L D I nb mb P (nb + mb * gy D + 1) pw sh)
    (hpw : ∀ s' < D.splits, ∀ t < D.tiles, ∀ e' < 64, pw s' t e') :
    ∃ l' sh', Exec C ctx (forU 63 (u32l D.splits) [.set 62 (.bin .add .f32 0 (.local 62) (.load (.scalar .f32)
        (partAt D.tiles (.local 63) (.local 59) (AffineSplitMma.u32 .add (AffineSplitMma.u32 .mul (.local 60) (u32l 8))
          (.local 61)))))]) (setLocal l 62 (.f32 zero)) sh .normal l' sh' ∧
      (∀ j, j ≠ 62 → j ≠ 63 → l' j = l j) ∧
      l' 62 = some (.f32 (splitSum C (fun s' => AffineSplitMma.part C D I nb mb s' t (8 * rr + m)) D.splits)) ∧
      Mem C L D I nb mb P (nb + mb * gy D + 1) pw sh' ∧ (∀ th', tview sh' th' = tview sh th') := by
  have hT13 := hok.tiles_lt13
  have hsp : D.splits < 2 ^ 8 := by have := hok.splitsK; have := hok.Kle; omega
  have hne : nb + mb * gy D + 1 ≠ ctx.group := by rw [hl.group]; omega
  let f := fun s' => AffineSplitMma.part C D I nb mb s' t (8 * rr + m)
  let SI : Nat → Locals → Shared → Prop := fun s' l' sh' => (∀ j, j ≠ 62 → j ≠ 63 → l' j = l j) ∧
    l' 63 = some (u32 (0 + 1 * s')) ∧ l' 62 = some (.f32 (splitSum C f s')) ∧
    Mem C L D I nb mb P (nb + mb * gy D + 1) pw sh' ∧ (∀ th', tview sh' th' = tview sh th')
  have hbody : ∀ s' < D.splits, ∀ l₀ sh₀, SI s' l₀ sh₀ → ∃ o l₁ sh₁, (o = .normal ∨ o = .continue_) ∧
      Exec C ctx [.set 62 (.bin .add .f32 0 (.local 62) (.load (.scalar .f32)
        (partAt D.tiles (.local 63) (.local 59) (AffineSplitMma.u32 .add (AffineSplitMma.u32 .mul (.local 60) (u32l 8))
          (.local 61)))))] l₀ sh₀ o l₁ sh₁ ∧ l₁ 63 = some (u32 (0 + 1 * s')) ∧
      SI (s' + 1) (setLocal l₁ 63 (u32 (0 + 1 * (s' + 1)))) sh₁ := by
    intro s' hs' l₀ sh₀ hSI
    obtain ⟨ag, h63, h62, hm0, hv0⟩ := hSI
    have h63' : l₀ 63 = some (u32 s') := by rw [h63, Nat.zero_add, Nat.one_mul]
    have hS64 : s' * (64 * D.tiles) < 2 ^ 32 := by
      have : s' * (64 * D.tiles) ≤ 2 ^ 8 * (64 * 2 ^ 13) := Nat.mul_le_mul (by omega) (by omega)
      omega
    have hq0 := eval_offset_u64 C (ctx := ctx) (o := 0) (sh := sh₀) (r := 6) (e := .scalar .f32) (n := s' * (64 * D.tiles))
      (eval_local' C ((ag 56 (by omega) (by omega)).trans h56) sh₀)
      (eval_mul_u64 C (site := 0) (eval_toU64 C (eval_local' C h63' sh₀) (by omega))
        (eval_u64lit C _ _ (64 * D.tiles) (by omega))) (by omega)
    have hq1 := eval_offset_u64 C (n := t * 64) hq0 (eval_mul_u64 C (site := 0)
      (eval_toU64 C (eval_local' C ((ag 59 (by omega) (by omega)).trans h59) sh₀) (by omega))
      (eval_u64lit C _ _ 64 (by norm_num))) (by omega)
    have hix := eval_bin_u32 C (ctx := ctx) (l := l₀) (sh := sh₀) (op := .add) (site := 0)
      (eval_bin_u32 C (op := .mul) (site := 0) (eval_local' C ((ag 60 (by omega) (by omega)).trans h60) sh₀)
        (eval_u32lit C _ sh₀ 8 (by norm_num)) (binary_mul_u32 C rr 8))
      (eval_local' C ((ag 61 (by omega) (by omega)).trans h61) sh₀) (binary_add_u32 C _ m)
    have hq2 := eval_offset_u32 C hq1 hix (by omega)
    rw [show 0 + s' * (64 * D.tiles) * (Ty.scalar .f32).bytes + t * 64 * (Ty.scalar .f32).bytes +
      (rr * 8 + m) * (Ty.scalar .f32).bytes = 4 * (s' * (64 * D.tiles) + t * 64 + (8 * rr + m)) by
      simp only [Ty.bytes, Scalar.bytes]; ring] at hq2
    have hix' : s' * (64 * D.tiles) + t * 64 + (8 * rr + m) < D.splits * (64 * D.tiles) := by
      have h1 : t * 64 + (8 * rr + m) < 64 * D.tiles := by
        have : (t + 1) * 64 ≤ D.tiles * 64 := Nat.mul_le_mul_right _ ht
        rw [Nat.add_mul, Nat.one_mul] at this; omega
      have h2 : (s' + 1) * (64 * D.tiles) ≤ D.splits * (64 * D.tiles) := Nat.mul_le_mul_right _ hs'
      rw [Nat.add_mul, Nat.one_mul] at h2; omega
    have hld := load_shared ctx .f32 sh₀ 6 (4 * (s' * (64 * D.tiles) + t * 64 + (8 * rr + m))) _
      (by rw [hm0.regions]; exact hS.r6) (by simp) (by simp [Scalar.bytes]) (by simp [Scalar.bytes])
      (by simp only [Scalar.bytes]; rw [show D.splits * D.tiles * 64 = D.splits * (64 * D.tiles) by ring]; omega)
      (by simp [loadOffset, Ty.bytes, Scalar.bytes])
    rw [show Scalar.f32.bytes = 4 from rfl, hm0.part s' hs' t ht (8 * rr + m) (by omega) (hpw s' hs' t ht _ (by omega)),
      ofWord_f32] at hld
    have hv := eval_f32 C (op := .add) (site := 0) (.inr ⟨rfl, rfl⟩) (eval_local' C h62 sh₀)
      ((eval_load C ctx l₀ _ _ _ sh₀ sh₀ hq2).trans hld) rfl
    refine ⟨.normal, _, _, .inl rfl, .set hv (.nil _ _), by rw [setLocal_other _ _ (by decide)]; exact h63,
      fun j h1 h2 => ?_, setLocal_same _ _ _, ?_, hm0.rd hS ctx 6 _ 4 (.inr ⟨rfl, hne⟩), fun th' => hv0 th'⟩
    · rw [setLocal_other _ _ h2, setLocal_other _ _ h1]; exact ag j h1 h2
    · rw [setLocal_other _ _ (by decide), setLocal_same]; rfl
  obtain ⟨l', sh', hloop, hSI⟩ := exec_count C (ctx := ctx) 63 1 D.splits D.splits 0 (u32l D.splits) _ SI
    (by omega) (by norm_num) (fun k _ => by omega) (by omega)
    (fun k _ l' sh' hq => ⟨hq.2.1, eval_u32lit C _ _ _ (by omega)⟩) hbody
    (l := setLocal (setLocal l 62 (.f32 zero)) 63 (u32 0)) (sh := sh)
    ⟨fun j h1 h2 => by rw [setLocal_other _ _ h2, setLocal_other _ _ h1], setLocal_same _ _ _,
      by rw [setLocal_other _ _ (by decide), setLocal_same]; rfl, hm, fun _ => rfl⟩
  obtain ⟨ag, -, h62, hm', hv'⟩ := hSI
  exact ⟨l', sh', .set (eval_u32lit C _ _ 0 (by norm_num)) hloop, ag, h62, hm', hv'⟩

end Out
end Metal.Kernels.SplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

section Out2
variable (C : M1Max.Contract) {L : Launch} {A : Al} {I : In} {pw : Nat → Nat → Nat → Prop} {ctx : Ctx}
  {D : Dims} {nb mb s : Nat}

theorem idx_div {i n N : Nat} (hn : n < N) : (i * N + n) / N = i ∧ (i * N + n) % N = n := by
  refine ⟨?_, ?_⟩
  · rw [Nat.add_comm, Nat.add_mul_div_right _ _ (by omega), Nat.div_eq_of_lt hn, Nat.zero_add]
  · rw [Nat.add_comm, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hn]

/-- Iteration `e` of the output loop: `y[m0 + m][n0 + 8t + r]`, or nothing past the last row. -/
theorem exec_outBody (hS : Shape L D A) (hok : Ok D) {i : Fin 32} (hl : Lane D ctx nb mb s i) {e : Nat}
    (he : e < 64 * D.tiles) {l : Locals} {sh : Shared} (hF : Fix D ctx nb mb s i l)
    (h56 : l 56 = some (.ptr ⟨6, 0, .scalar .f32⟩)) (h58 : l 58 = some (u32 e)) {P : Nat}
    (hP : key D (orow mb e) (ocol D nb e) = P)
    (hth : ctx.thread = (nb + mb * gy D) * (32 * D.splits) + e % (32 * D.splits))
    (hm : Mem C L D I nb mb P (nb + mb * gy D + 1) pw sh) (hpw : ∀ s' < D.splits, ∀ t < D.tiles, ∀ e' < 64, pw s' t e') :
    ∃ o l' sh', (o = .normal ∨ o = .continue_) ∧ Exec C ctx (outBody D.N D.tiles D.splits) l sh o l' sh' ∧
      (∀ j, j ≤ 58 → l' j = l j) ∧ Mem C L D I nb mb (P + 1) (nb + mb * gy D + 1) pw sh' ∧
      (∀ th', tview sh' th' = tview sh th') := by
  have hT13 := hok.tiles_lt13; have hN := hok.Nle; have hr31 := hok.rle
  obtain ⟨hn, hnd, hnt, hn8, hmd, hm8, hel, hgr⟩ := out_facts D hok (mb := mb) hl.hnb he
  have hmb : 8 * mb < D.r + 7 := by have := hl.hmb; unfold gz at this; omega
  have h59 := eval_bin_u32 C (ctx := ctx) (l := l) (sh := sh) (op := .div) (site := 0) (eval_local' C h58 sh)
    (eval_u32lit C _ sh 64 (by norm_num)) (binary_div_u32 C e 64 (by omega) (by norm_num) (by norm_num))
  generalize hl1 : setLocal l 59 (u32 (e / 64)) = l₁
  have h1_58 : l₁ 58 = some (u32 e) := by rw [← hl1, setLocal_other _ _ (by decide)]; exact h58
  have h60 := eval_bin_u32 C (ctx := ctx) (l := l₁) (sh := sh) (op := .div) (site := 0)
    (eval_bin_u32 C (op := .rem) (site := 0) (eval_local' C h1_58 sh)
      (eval_u32lit C _ sh 64 (by norm_num)) (binary_rem_u32 C e 64 (by omega) (by norm_num) (by norm_num)))
    (eval_u32lit C _ sh 8 (by norm_num)) (binary_div_u32 C (e % 64) 8 (by omega) (by norm_num) (by norm_num))
  generalize hl2 : setLocal l₁ 60 (u32 (e % 64 / 8)) = l₂
  have h61 := eval_bin_u32 C (ctx := ctx) (l := l₂) (sh := sh) (op := .rem) (site := 0)
    (eval_local' C (show l₂ 58 = some (u32 e) by rw [← hl2, setLocal_other _ _ (by decide)]; exact h1_58) sh)
    (eval_u32lit C _ sh 8 (by norm_num)) (binary_rem_u32 C e 8 (by omega) (by norm_num) (by norm_num))
  generalize hl3 : setLocal l₂ 61 (u32 (e % 8)) = l₃
  have ag3 : ∀ j, j ≤ 58 → l₃ j = l j := fun j hj => by
    rw [← hl3, setLocal_other _ _ (by omega), ← hl2, setLocal_other _ _ (by omega), ← hl1, setLocal_other _ _ (by omega)]
  have h3_61 : l₃ 61 = some (u32 (e % 8)) := by rw [← hl3, setLocal_same]
  have h3_60 : l₃ 60 = some (u32 (e % 64 / 8)) := by rw [← hl3, setLocal_other _ _ (by decide), ← hl2, setLocal_same]
  have h3_59 : l₃ 59 = some (u32 (e / 64)) := by
    rw [← hl3, setLocal_other _ _ (by decide), ← hl2, setLocal_other _ _ (by decide), ← hl1, setLocal_same]
  have hrow := eval_bin_u32 C (ctx := ctx) (l := l₃) (sh := sh) (op := .add) (site := 0)
    (eval_local' C ((ag3 12 (by omega)).trans hF.l12) sh) (eval_local' C h3_61 sh) (binary_add_u32 C (8 * mb) (e % 8))
  have hc := eval_bin_u32 C (op := .ge) (site := 0) hrow (eval_local' C ((ag3 10 (by omega)).trans hF.l10) sh)
    (binary_ge_u32 C (8 * mb + e % 8) D.r (by omega) (by omega))
  have hpre : ∀ {ss : List CStmt} {o : Outcome} {l' : Locals} {sh' : Shared}, Exec C ctx ss l₃ sh o l' sh' →
      Exec C ctx (.set 59 (AffineSplitMma.u32 .div (.local 58) (u32l 64)) ::
        .set 60 (AffineSplitMma.u32 .div (AffineSplitMma.u32 .rem (.local 58) (u32l 64)) (u32l 8)) ::
        .set 61 (AffineSplitMma.u32 .rem (.local 58) (u32l 8)) :: ss) l sh o l' sh' := fun h =>
    .set h59 (by rw [hl1]; exact .set h60 (by rw [hl2]; exact .set h61 (by rw [hl3]; exact h)))
  by_cases hskip : D.r ≤ 8 * mb + e % 8
  · -- past the last row
    rw [decide_eq_true hskip] at hc
    refine ⟨.continue_, l₃, sh, .inr rfl, ?_, ag3, hm.bump fun i' hi' n' hn' hk => ?_, fun _ => rfl⟩
    · rw [outBody_eq]; exact hpre (.ite_exit hc .continue_ (.inl rfl))
    · have hne : key D i' n' ≠ P := fun h => by
        have := (key_inj D hok.N hok.tiles hok.splits hn' hn (h.trans hP.symm)).1
        unfold orow at this; omega
      omega
  · rw [decide_eq_false hskip] at hc
    have hi : orow mb e < D.r := by unfold orow; omega
    obtain ⟨l₄, sh₄, hsum, ag4, h62, hm4, hv4⟩ := exec_sum C hS hok hl (t := e / 64) (rr := e % 64 / 8) (m := e % 8)
      (by omega) (by omega) (by omega) ((ag3 56 (by omega)).trans h56) h3_59 h3_60 h3_61 hm hpw
    have ag4' : ∀ j, j ≤ 61 → l₄ j = l₃ j := fun j hj => ag4 j (by omega) (by omega)
    -- the destination
    have hy0 := eval_mul_u64 C (ctx := ctx) (l := l₄) (sh := sh₄) (site := 0)
      (eval_toU64 C (eval_bin_u32 C (op := .add) (site := 0) (eval_local' C ((ag4' 12 (by omega)).trans
        ((ag3 12 (by omega)).trans hF.l12)) sh₄) (eval_local' C ((ag4' 61 (by omega)).trans h3_61) sh₄)
        (binary_add_u32 C (8 * mb) (e % 8))) (by omega)) (eval_u64lit C _ _ D.N (by omega))
    have hy1 := eval_add_u64 C (site := 0) hy0
      (eval_toU64 C (eval_local' C ((ag4' 11 (by omega)).trans ((ag3 11 (by omega)).trans hF.l11)) sh₄) (by
        have := n0_lt hl.hnb; omega))
    have hy2 := eval_add_u64 C (site := 0) hy1 (eval_toU64 C (eval_bin_u32 C (op := .mul) (site := 0)
      (eval_u32lit C _ sh₄ 8 (by norm_num)) (eval_local' C ((ag4' 59 (by omega)).trans h3_59) sh₄)
      (binary_mul_u32 C 8 (e / 64))) (by omega))
    have hy3 := eval_add_u64 C (site := 0) hy2 (eval_toU64 C (eval_local' C ((ag4' 60 (by omega)).trans h3_60) sh₄)
      (by omega))
    have hidx : (8 * mb + e % 8) * D.N + 8 * D.tiles * nb + 8 * (e / 64) + e % 64 / 8 =
        orow mb e * D.N + ocol D nb e := by unfold orow ocol; ring
    rw [hidx] at hy3
    have hidx' : orow mb e * D.N + ocol D nb e < D.r * D.N := idx_lt hi hn
    have hrN : D.r * D.N < 2 ^ 47 := by
      have := Nat.mul_le_mul (show D.r ≤ 2 ^ 31 - 1 by omega) (show D.N ≤ 2 ^ 16 - 1 by omega)
      exact lt_of_le_of_lt this (by norm_num)
    have hp := eval_offset_u64 C (o := 0) (eval_local' C ((ag4' 5 (by omega)).trans ((ag3 5 (by omega)).trans hF.l5)) sh₄)
      hy3 (by omega)
    rw [show 0 + (orow mb e * D.N + ocol D nb e) * (Ty.scalar .bf16).bytes = 2 * (orow mb e * D.N + ocol D nb e) by
      simp only [Ty.bytes, Scalar.bytes]; ring] at hp
    have hval := eval_conv C (ctx := ctx) (t := .bf16) (eval_local' C h62 sh₄) rfl
    have hyv : yv C D I (orow mb e) (ocol D nb e) =
        C.narrow (splitSum C (fun s' => AffineSplitMma.part C D I nb mb s' (e / 64) (8 * (e % 64 / 8) + e % 8)) D.splits) := by
      unfold yv; rw [hnd, hmd, hnt, hn8, hm8]
    have hst := store_shared ctx .bf16 sh₄ 5 (2 * (orow mb e * D.N + ocol D nb e)) _
      (.bf16 (C.narrow (splitSum C (fun s' => AffineSplitMma.part C D I nb mb s' (e / 64) (8 * (e % 64 / 8) + e % 8))
        D.splits))) _ (by rw [hm4.regions]; exact hS.r5) (by simp) (by simp) (by simp [Scalar.bytes])
      (by simp [Scalar.bytes]) (by simp only [Scalar.bytes]; omega) (encode_bf16 _)
    rw [show Scalar.bf16.bytes = 2 from rfl, ← hyv] at hst
    rw [← hyv] at hval
    have hq := idx_div (i := orow mb e) hn
    have hw := hm4.wy hS hok.N hok.tiles hok.splits ctx hi hn hP
      (by unfold ywriter; rw [hq.1, hq.2, hgr, hel]; exact hth)
      (by unfold ywriter; rw [hq.1, hq.2, hgr]; exact hl.group)
    refine ⟨.normal, l₄, _, .inl rfl, ?_, fun j hj => (ag4' j (by omega)).trans (ag3 j hj), hw,
      fun th' => by rw [tview_wrn (by decide), hv4]⟩
    rw [outBody_eq]
    exact hpre (.ite (v := false) hc (.nil _ _) (.set (eval_lit C _ _ _ _) (hsum.append (.store hp hval hst (.nil _ _)))))

theorem blk_eq {A B G T : Nat} (hB : B < T) (h1 : G * T ≤ A * T + B) (h2 : A * T + B < (G + 1) * T) : A = G := by
  rcases Nat.lt_trichotomy A G with h | h | h
  · have : (A + 1) * T ≤ G * T := Nat.mul_le_mul_right _ h
    rw [Nat.add_mul, Nat.one_mul] at this; omega
  · exact h
  · have : (G + 1) * T ≤ A * T := Nat.mul_le_mul_right _ h
    omega

/-- A lane's output loop after the barrier, to the end. -/
theorem lane_out (hS : Shape L D A) (hok : Ok D) {i : Fin 32} (hl : Lane D ctx nb mb s i) {l : Locals} {sh : Shared}
    (hF : Fix D ctx nb mb s i l) (h56 : l 56 = some (.ptr ⟨6, 0, .scalar .f32⟩))
    (hm : Mem C L D I nb mb (((nb + mb * gy D) * (32 * D.splits) + (32 * s + i)) * (64 * D.tiles))
      (nb + mb * gy D + 1) pw sh) (hpw : ∀ s' < D.splits, ∀ t < D.tiles, ∀ e' < 64, pw s' t e') :
    ∃ l' sh', Reaches C ⟨ctx, l, [.block (outRest D)], .running⟩ sh ⟨ctx, l', [], .done⟩ sh' ∧
      Mem C L D I nb mb (((nb + mb * gy D) * (32 * D.splits) + (32 * s + i) + 1) * (64 * D.tiles))
        (nb + mb * gy D + 1) pw sh' ∧ (∀ th', tview sh' th' = tview sh th') := by
  have hT13 := hok.tiles_lt13; have hs := hl.hs; have hi := hl.hi
  have hsp : D.splits < 2 ^ 8 := by have := hok.splitsK; have := hok.Kle; omega
  have hd : 0 < 32 * D.splits := by have := hok.splits; omega
  generalize hG : (nb + mb * gy D) * (32 * D.splits) + (32 * s + i) = G at hm ⊢
  have h58 := eval_bin_u32 C (ctx := ctx) (l := l) (sh := sh) (op := .add) (site := 0)
    (eval_bin_u32 C (op := .mul) (site := 0) (eval_local' C hF.l7 sh) (eval_u32lit C _ sh 32 (by norm_num))
      (binary_mul_u32 C s 32)) (eval_local' C hF.l6 sh) (binary_add_u32 C _ i)
  rw [show s * 32 + ↑i = 32 * s + ↑i by ring] at h58
  let Nl := (64 * D.tiles - (32 * s + i) + 32 * D.splits - 1) / (32 * D.splits)
  have hNl : 32 * D.splits * Nl ≤ 64 * D.tiles - (32 * s + i) + 32 * D.splits - 1 := by
    rw [Nat.mul_comm]; exact Nat.div_mul_le_self _ _
  let E : Nat → Locals → Shared → Prop := fun k l' sh' => (∀ j, j ≤ 57 → l' j = l j) ∧
    l' 58 = some (u32 (32 * s + i + 32 * D.splits * k)) ∧
    Mem C L D I nb mb (G * (64 * D.tiles) + k) (nb + mb * gy D + 1) pw sh' ∧ (∀ th', tview sh' th' = tview sh th')
  have hbody : ∀ k < Nl, ∀ l₀ sh₀, E k l₀ sh₀ → ∃ o l₁ sh₁, (o = .normal ∨ o = .continue_) ∧
      Exec C ctx (outBody D.N D.tiles D.splits) l₀ sh₀ o l₁ sh₁ ∧ l₁ 58 = some (u32 (32 * s + i + 32 * D.splits * k)) ∧
      E (k + 1) (setLocal l₁ 58 (u32 (32 * s + i + 32 * D.splits * (k + 1)))) sh₁ := by
    intro k hk l₀ sh₀ hE
    obtain ⟨ag, h58', hm0, hv0⟩ := hE
    have he : 32 * s + i + 32 * D.splits * k < 64 * D.tiles := (count_iff hd k).mpr hk
    have hmod : (32 * s + i + 32 * D.splits * k) % (32 * D.splits) = 32 * s + i := by
      rw [Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt (by omega)]
    have hdiv : (32 * s + i + 32 * D.splits * k) / (32 * D.splits) = k := by
      rw [Nat.add_mul_div_left _ _ hd, Nat.div_eq_of_lt (by omega), Nat.zero_add]
    obtain ⟨-, -, -, -, -, -, hel, hgr⟩ := out_facts D hok (mb := mb) hl.hnb he
    have hP : key D (orow mb (32 * s + i + 32 * D.splits * k)) (ocol D nb (32 * s + i + 32 * D.splits * k)) =
        G * (64 * D.tiles) + k := by
      unfold key; rw [hel, hgr, hmod, hdiv, ← hG]
    obtain ⟨o, l₁, sh₁, ho, hex, ag1, hm1, hv1⟩ := exec_outBody C hS hok hl he
      (hF.of_eq fun j hj => ag j (by omega)) ((ag 56 (by omega)).trans h56) h58' hP
      (by rw [hl.thread, hmod]) hm0 hpw
    refine ⟨o, l₁, sh₁, ho, hex, (ag1 58 (by omega)).trans h58', fun j hj => ?_, setLocal_same _ _ _, hm1,
      fun th' => by rw [hv1, hv0]⟩
    rw [setLocal_other _ _ (by omega), ag1 j (by omega), ag j hj]
  obtain ⟨l', sh', hloop, hE⟩ := exec_count C (ctx := ctx) 58 (32 * D.splits) (64 * D.tiles) Nl (32 * s + i)
    (u32l (64 * D.tiles)) _ E (by omega) (by omega) (fun k _ => count_iff hd k) (by omega)
    (fun k _ l' sh' hq => ⟨hq.2.1, eval_u32lit C _ _ _ (by omega)⟩) hbody (l := setLocal l 58 (u32 (32 * s + i)))
    (sh := sh) ⟨fun j hj => setLocal_other _ _ (by omega), by rw [setLocal_same, Nat.mul_zero, Nat.add_zero],
      by rw [Nat.add_zero]; exact hm, fun _ => rfl⟩
  obtain ⟨-, -, hm', hv'⟩ := hE
  refine ⟨l', sh', (Exec.set h58 hloop).reaches_done, hm'.bump fun i' hi' n' hn' hk' => ?_, hv'⟩
  by_contra hcon
  have hB : eloc D i' n' / (32 * D.splits) < 64 * D.tiles :=
    lt_of_le_of_lt (Nat.div_le_self _ _) (eloc_lt D hok.tiles i' n')
  have hge : G * (64 * D.tiles) + Nl ≤ key D i' n' := Nat.le_of_not_lt hcon
  have hk2 : key D i' n' = (grp D i' n' * (32 * D.splits) + eloc D i' n' % (32 * D.splits)) * (64 * D.tiles) +
      eloc D i' n' / (32 * D.splits) := rfl
  have hA := blk_eq (A := grp D i' n' * (32 * D.splits) + eloc D i' n' % (32 * D.splits))
    (B := eloc D i' n' / (32 * D.splits)) (G := G) (T := 64 * D.tiles) hB
    (by rw [← hk2]; exact le_trans (Nat.le_add_right _ _) hge) (by rw [← hk2]; exact hk')
  have h1 : eloc D i' n' % (32 * D.splits) = 32 * s + i :=
    (idx_inj (Nat.mod_lt _ hd) (show 32 * s + i < 32 * D.splits by omega) (hA.trans hG.symm)).2
  have h2 : Nl ≤ eloc D i' n' / (32 * D.splits) := by rw [hk2, hA] at hge; omega
  have h3 : eloc D i' n' = 32 * s + i + 32 * D.splits * (eloc D i' n' / (32 * D.splits)) := by
    have := Nat.div_add_mod (eloc D i' n') (32 * D.splits); omega
  have h4 := (count_iff hd (eloc D i' n' / (32 * D.splits)) (x0 := 32 * s + i) (n := 64 * D.tiles)).mp
    (by rw [← h3]; exact eloc_lt D hok.tiles i' n')
  omega

end Out2
end Metal.Kernels.SplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

/-! ## A lane's multiply-accumulates in order -/

/-- Multiply-accumulate `n` of a lane: tile `n % TILES` of value `(n / TILES) % 32` of K step `n / TILES / 32`. -/
def kOf (D : Dims) (n : Nat) : Nat := n / D.tiles / 32
def vOf (D : Dims) (n : Nat) : Nat := n / D.tiles % 32
def tOf (D : Dims) (n : Nat) : Nat := n % D.tiles

/-- SIMD-group `s`'s multiply-accumulates. -/
def ncoll (D : Dims) (s : Nat) : Nat := nsteps D s * 32 * D.tiles

theorem pos_succ {n T : Nat} (hT : 0 < T) :
    (n % T + 1 < T → (n + 1) / T = n / T ∧ (n + 1) % T = n % T + 1) ∧
    (n % T + 1 = T → (n + 1) / T = n / T + 1 ∧ (n + 1) % T = 0) := by
  have hn := Nat.div_add_mod n T
  refine ⟨fun h => ?_, fun h => ?_⟩
  · have e : n + 1 = (n % T + 1) + T * (n / T) := by omega
    rw [e, Nat.add_mul_div_left _ _ hT, Nat.div_eq_of_lt h, Nat.zero_add, Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt h]
    exact ⟨rfl, rfl⟩
  · have e : n + 1 = 0 + T * (n / T + 1) := by rw [Nat.mul_add, Nat.mul_one]; omega
    rw [e, Nat.add_mul_div_left _ _ hT, Nat.zero_div, Nat.zero_add, Nat.add_mul_mod_self_left, Nat.zero_mod]
    exact ⟨rfl, rfl⟩

theorem vOf_lt (D : Dims) (n : Nat) : vOf D n < 32 := Nat.mod_lt _ (by decide)
theorem tOf_lt (D : Dims) (hT : 0 < D.tiles) (n : Nat) : tOf D n < D.tiles := Nat.mod_lt _ hT

theorem kOf_lt {D : Dims} {s n : Nat} (hT : 0 < D.tiles) (hn : n < ncoll D s) : kOf D n < nsteps D s := by
  unfold kOf ncoll at *
  rw [Nat.div_div_eq_div_mul]
  exact (Nat.div_lt_iff_lt_mul (by have := hT; omega)).mpr (by rw [show nsteps D s * (D.tiles * 32) = nsteps D s * 32 * D.tiles by ring]; exact hn)

theorem step_lt_iff {D : Dims} (hok : Ok D) (s k : Nat) : stepOf D s k < D.K / 256 ↔ k < nsteps D s :=
  count_iff hok.splits k

section Step
variable (C : M1Max.Contract) {L : Launch} {A : Al} {I : In} {P ge : Nat} {pw : Nat → Nat → Nat → Prop} {ctx : Ctx}
  {D : Dims} {nb mb s : Nat}

/-- From multiply-accumulate `n` to `n + 1`. -/
theorem lane_step (hS : Shape L D A) (hok : Ok D) {i : Fin 32} (hl : Lane D ctx nb mb s i) {n : Nat}
    (hn : n + 1 < ncoll D s) {l : Locals} {sh : Shared}
    (hloc : TileLoc C D I ctx nb mb s i (kOf D n) (vOf D n) (tOf D n) l) (hm : Mem C L D I nb mb P ge pw sh)
    (hT : TAt C D I nb mb s i (kOf D n) (vOf D n) (tOf D n) (tview sh ctx.thread)) :
    ∃ l' sh', Reaches C ⟨ctx, setLocal l 55 (accV C D I nb mb s i (kOf D n) (vOf D n) (tOf D n)), Fc D, .running⟩ sh
        ⟨ctx, l', Fc D, collAt C D I nb mb s i (kOf D (n + 1)) (vOf D (n + 1)) (tOf D (n + 1))⟩ sh' ∧
      TileLoc C D I ctx nb mb s i (kOf D (n + 1)) (vOf D (n + 1)) (tOf D (n + 1)) l' ∧
      Mem C L D I nb mb P ge pw sh' ∧ (∀ th', th' ≠ ctx.thread → tview sh' th' = tview sh th') ∧
      TAt C D I nb mb s i (kOf D (n + 1)) (vOf D (n + 1)) (tOf D (n + 1)) (tview sh' ctx.thread) := by
  have hT0 := hok.tiles
  have hk : stepOf D s (kOf D n) < D.K / 256 := (step_lt_iff hok s _).mpr (kOf_lt hT0 (by omega))
  have hkn1 : kOf D (n + 1) < nsteps D s := kOf_lt hT0 hn
  have hv := vOf_lt D n
  obtain ⟨hA, hB⟩ := pos_succ (n := n) hT0
  by_cases ht : tOf D n + 1 < D.tiles
  · obtain ⟨hq, hr⟩ := hA ht
    have e1 : kOf D (n + 1) = kOf D n := by unfold kOf; rw [hq]
    have e2 : vOf D (n + 1) = vOf D n := by unfold vOf; rw [hq]
    have e3 : tOf D (n + 1) = tOf D n + 1 := hr
    rw [e1, e2, e3]
    exact lane_tile C hS hok hl hv ht hloc hm hT
  · have ht' : tOf D n + 1 = D.tiles := by have := tOf_lt D hT0 n; omega
    obtain ⟨hq, hr⟩ := hB ht'
    obtain ⟨hA', hB'⟩ := pos_succ (n := n / D.tiles) (T := 32) (by decide)
    have e3 : tOf D (n + 1) = 0 := hr
    by_cases hv1 : vOf D n + 1 < 32
    · obtain ⟨hq', hr'⟩ := hA' hv1
      have e1 : kOf D (n + 1) = kOf D n := by unfold kOf; rw [hq, hq']
      have e2 : vOf D (n + 1) = vOf D n + 1 := by unfold vOf; rw [hq, hr']
      rw [e1, e2, e3]
      by_cases hc : vOf D n % 4 + 1 < 4
      · exact lane_col C hS hok hl hk hv hc ht' hloc hm hT
      · exact lane_chunk C hS hok hl hk hv (by omega) (by omega) ht' hloc hm hT
    · have hv31 : vOf D n = 31 := by omega
      obtain ⟨hq', hr'⟩ := hB' (by unfold vOf at hv31; omega)
      have e1 : kOf D (n + 1) = kOf D n + 1 := by unfold kOf; rw [hq, hq']
      have e2 : vOf D (n + 1) = 0 := by unfold vOf; rw [hq, hr']
      rw [e1, e2, e3]
      rw [e1] at hkn1
      rw [hv31] at hloc hT ⊢
      exact lane_kstep C hS hok hl ((step_lt_iff hok s _).mpr hkn1) ht' hloc hm hT

end Step
end Metal.Kernels.SplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

/-! ## SIMD-groups -/

theorem resolve_at (C : M1Max.Contract) (D : Dims) (I : In) (nb mb s k v t : Nat) (hv : v < 32) :
    resolve C (.mma .f32 .f32) .f32 0 (List.ofFn fun i => xval C D I nb mb s i k v t) =
      some (List.ofFn fun i => accV C D I nb mb s i k v t) := by
  have hacc : accAt C D I nb mb s t (32 * k + v + 1) =
      C.simdMma (aRegs C D I nb s t k v) (bRegs C D I mb s k v) (accAt C D I nb mb s t (32 * k + v)) := by
    show C.simdMma (aRegs C D I nb s t ((32 * k + v) / 32) ((32 * k + v) % 32))
      (bRegs C D I mb s ((32 * k + v) / 32) ((32 * k + v) % 32)) _ = _
    rw [show (32 * k + v) / 32 = k by omega, show (32 * k + v) % 32 = v by omega]
  have h := resolve_mma C 0 (aRegs C D I nb s t k v) (bRegs C D I mb s k v) (accAt C D I nb mb s t (32 * k + v))
  rw [← hacc] at h
  exact h

theorem last_pos {D : Dims} {s : Nat} (hT : 0 < D.tiles) (hns : 0 < nsteps D s) :
    kOf D (ncoll D s - 1) + 1 = nsteps D s ∧ vOf D (ncoll D s - 1) = 31 ∧ tOf D (ncoll D s - 1) + 1 = D.tiles := by
  obtain ⟨a, ha⟩ : ∃ a, nsteps D s = a + 1 := ⟨nsteps D s - 1, by omega⟩
  obtain ⟨b, hb⟩ : ∃ b, D.tiles = b + 1 := ⟨D.tiles - 1, by omega⟩
  have e : ncoll D s - 1 = (32 * a + 31) * D.tiles + b := by
    unfold ncoll; rw [ha, hb]; ring_nf; omega
  have h1 : (ncoll D s - 1) / D.tiles = 32 * a + 31 := by
    rw [e, Nat.add_comm, Nat.add_mul_div_right _ _ hT, Nat.div_eq_of_lt (by omega), Nat.zero_add]
  have h2 : (ncoll D s - 1) % D.tiles = b := by
    rw [e, Nat.add_comm, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt (by omega)]
  unfold kOf vOf tOf
  rw [h1, h2]
  omega

theorem nsteps_pos {D : Dims} (hok : Ok D) {s : Nat} (hs : s < D.splits) : 0 < nsteps D s :=
  (step_lt_iff hok s 0).mp (by show s + D.splits * 0 < D.K / 256; have := hok.s_lt hs; omega)

section Simd
variable (C : M1Max.Contract) {L : Launch} {A : Al} {I : In} {P : Nat} {pw : Nat → Nat → Nat → Prop}
  {D : Dims} {nb mb s : Nat}

/-- Lane `i` at multiply-accumulate `n`. -/
def AtN (C : M1Max.Contract) (D : Dims) (I : In) (ctxs : Fin 32 → Ctx) (nb mb s n : Nat) (i : Fin 32) (U : Thread) :
    Prop :=
  ∃ l, U = ⟨ctxs i, l, Fc D, collAt C D I nb mb s i (kOf D n) (vOf D n) (tOf D n)⟩ ∧
    TileLoc C D I (ctxs i) nb mb s i (kOf D n) (vOf D n) (tOf D n) l

/-- Lane `i` at the barrier. -/
def AtBar (D : Dims) (ctxs : Fin 32 → Ctx) (nb mb s : Nat) (i : Fin 32) (U : Thread) : Prop :=
  ∃ l, U = ⟨ctxs i, l, [.block (outRest D)], .barrier 2 false true⟩ ∧ Fix D (ctxs i) nb mb s i l ∧
    l 56 = some (.ptr ⟨6, 0, .scalar .f32⟩)

theorem lane_threads {ctxs : Fin 32 → Ctx} (hL : ∀ i : Fin 32, Lane D (ctxs i) nb mb s i) {i j : Fin 32} (h : i ≠ j) :
    (ctxs j).thread ≠ (ctxs i).thread := by
  rw [(hL i).thread, (hL j).thread]; intro e; exact h (Fin.ext (by omega))

/-- A SIMD-group from multiply-accumulate `n` (its lanes resumed with its results) to the barrier. -/
theorem simd_rounds (hS : Shape L D A) (hok : Ok D) (ctxs : Fin 32 → Ctx) (hL : ∀ i : Fin 32, Lane D (ctxs i) nb mb s i) :
    ∀ d n, ncoll D s - 1 - n = d → n < ncoll D s → ∀ r, ncoll D s - n ≤ r → ∀ (U : Fin 32 → Thread) (sh : Shared),
      (∀ i, AtN C D I ctxs nb mb s n i (U i)) → Mem C L D I nb mb P (nb + mb * gy D) pw sh →
      (∀ i : Fin 32, TAt C D I nb mb s i (kOf D n) (vOf D n) (tOf D n) (tview sh (ctxs i).thread)) →
      ∃ (V : Fin 32 → Thread) (sh' : Shared), (Ev fun m => (runSimd C m r (List.ofFn fun i =>
          { U i with status := .running }.set 55 (accV C D I nb mb s i (kOf D n) (vOf D n) (tOf D n)))).run sh =
          some (List.ofFn V, sh')) ∧
        Mem C L D I nb mb P (nb + mb * gy D) (fun s' t e => pw s' t e ∨ (s' = s ∧ t < D.tiles ∧ e < 64)) sh' ∧
        ∀ i, (V i).status = .barrier 2 false true ∧ AtBar D ctxs nb mb s i (V i) := by
  intro d
  induction d with
  | zero =>
    intro n hd hn r hr U sh hU hm hT
    obtain ⟨r', rfl⟩ : ∃ r', r = r' + 1 := ⟨r - 1, by omega⟩
    have hn' : n = ncoll D s - 1 := by omega
    subst hn'
    obtain ⟨hk1, hv31, ht1⟩ := last_pos (s := s) hok.tiles (nsteps_pos hok (hL 0).hs)
    have hk : stepOf D s (kOf D (ncoll D s - 1)) < D.K / 256 := (step_lt_iff hok s _).mpr (by omega)
    have hk2 : D.K / 256 ≤ stepOf D s (kOf D (ncoll D s - 1) + 1) := by
      have := (step_lt_iff hok s (kOf D (ncoll D s - 1) + 1)).not.mpr (by omega); omega
    let Iv : Nat → Shared → Prop := fun idx sh' =>
      Mem C L D I nb mb P (nb + mb * gy D)
        (fun s' t e => pw s' t e ∨ (s' = s ∧ t < D.tiles ∧ e < 64 ∧ (laneOf e).val < idx)) sh' ∧
      ∀ i : Fin 32, idx ≤ i.val →
        TAt C D I nb mb s i (kOf D (ncoll D s - 1)) 31 (tOf D (ncoll D s - 1)) (tview sh' (ctxs i).thread)
    obtain ⟨V, sh', hrun, hI, hR⟩ := runSimd_blocked_ev C r' (fun i => { U i with status := .running }.set 55
        (accV C D I nb mb s i (kOf D (ncoll D s - 1)) (vOf D (ncoll D s - 1)) (tOf D (ncoll D s - 1)))) Iv
      (fun i t => (t.status = .barrier 2 false true) ∧ AtBar D ctxs nb mb s i t) (fun i sh₀ hI => by
        obtain ⟨l, hUi, hloc⟩ := hU i
        rw [hv31] at hloc
        obtain ⟨l', sh', hre, hF, h56, hm', hoth⟩ := lane_last C hS hok (hL i) hk1 hk hk2 ht1 hloc hI.1
          (hI.2 i (le_refl _))
        refine ⟨_, sh', ?_, ⟨hm'.mono fun s' t e h => ?_, fun j hj => ?_⟩, rfl, rfl, l', rfl, hF, h56⟩
        · rw [hUi, hv31]; exact hre.ev_stop rfl
        · rcases h with h | ⟨rfl, ht, he, hle⟩
          · exact .inl (.inl h)
          · by_cases hlt : (laneOf e).val < i.val
            · exact .inl (.inr ⟨rfl, ht, he, hlt⟩)
            · exact .inr ⟨rfl, ht, he, by omega⟩
        · rw [hoth _ (lane_threads hL (show i ≠ j from fun h => by subst h; omega))]
          exact hI.2 j (by omega)) sh ⟨hm.mono fun s' t e h => h.elim id (fun ⟨_, _, _, h⟩ => absurd h (by omega)),
        fun i _ => by rw [← hv31]; exact hT i⟩
    exact ⟨V, sh', hrun, hI.1.mono fun s' t e h => h.elim .inl fun ⟨h1, h2, h3⟩ => .inr ⟨h1, h2, h3, (laneOf e).isLt⟩,
      hR⟩
  | succ d ih =>
    intro n hd hn r hr U sh hU hm hT
    obtain ⟨r', rfl⟩ : ∃ r', r = r' + 1 := ⟨r - 1, by omega⟩
    have hn1 : n + 1 < ncoll D s := by omega
    let Iv : Nat → Shared → Prop := fun idx sh' => Mem C L D I nb mb P (nb + mb * gy D) pw sh' ∧
      ∀ i : Fin 32, TAt C D I nb mb s i (kOf D (if i.val < idx then n + 1 else n)) (vOf D (if i.val < idx then n + 1 else n))
        (tOf D (if i.val < idx then n + 1 else n)) (tview sh' (ctxs i).thread)
    refine runSimd_collective_ev C r' (fun i => { U i with status := .running }.set 55
        (accV C D I nb mb s i (kOf D n) (vOf D n) (tOf D n))) 1 55 (.mma .f32 .f32) .f32 0
      (fun i => xval C D I nb mb s i (kOf D (n + 1)) (vOf D (n + 1)) (tOf D (n + 1)))
      (fun i => accV C D I nb mb s i (kOf D (n + 1)) (vOf D (n + 1)) (tOf D (n + 1)))
      (resolve_at C D I nb mb s _ _ _ (vOf_lt D _)) Iv (AtN C D I ctxs nb mb s (n + 1))
      (Mem C L D I nb mb P (nb + mb * gy D) (fun s' t e => pw s' t e ∨ (s' = s ∧ t < D.tiles ∧ e < 64)))
      (fun i t => t.status = .barrier 2 false true ∧ AtBar D ctxs nb mb s i t) (fun i sh₀ hI => ?_)
      (fun U' sh₁ hU' hI' => ih (n + 1) (by omega) hn1 r' (by omega) U' sh₁ hU' hI'.1 (fun i => by
        have := hI'.2 i; simpa [show i.val < 32 from i.isLt] using this)) sh
      ⟨hm, fun i => by simpa using hT i⟩
    obtain ⟨l, hUi, hloc⟩ := hU i
    obtain ⟨l', sh', hre, hloc', hm', hoth, hT'⟩ := lane_step C hS hok (hL i) hn1 hloc hI.1
      (by have := hI.2 i; simpa using this)
    refine ⟨_, sh', by rw [hUi]; exact hre.ev_stop rfl, ⟨hm', fun j => ?_⟩, rfl, l', rfl, hloc'⟩
    by_cases hij : j = i
    · subst hij; simpa using hT'
    · rw [hoth _ (lane_threads hL (Ne.symm hij))]
      have := hI.2 j
      by_cases hj : j.val < i.val
      · simpa [hj, show j.val < i.val + 1 by omega] using this
      · simpa [hj, show ¬ j.val < i.val + 1 by omega] using this

end Simd
end Metal.Kernels.SplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

theorem pos_zero (D : Dims) : kOf D 0 = 0 ∧ vOf D 0 = 0 ∧ tOf D 0 = 0 := by simp [kOf, vOf, tOf]

theorem ncoll_pos {D : Dims} (hok : Ok D) {s : Nat} (hs : s < D.splits) : 0 < ncoll D s := by
  have := nsteps_pos hok hs; have := hok.tiles; unfold ncoll; positivity

theorem nsteps_le {D : Dims} (hok : Ok D) (s : Nat) : nsteps D s ≤ D.K / 256 := by
  unfold nsteps
  apply Nat.div_le_of_le_mul
  have hQ : 1 ≤ D.K / 256 := le_trans hok.splits hok.splitsK
  obtain ⟨S', hS'⟩ : ∃ S', D.splits = S' + 1 := ⟨D.splits - 1, by have := hok.splits; omega⟩
  rw [hS', Nat.add_mul, Nat.one_mul]
  have : S' ≤ S' * (D.K / 256) := Nat.le_mul_of_pos_right _ hQ
  omega

theorem ncoll_le {D : Dims} (hok : Ok D) (s : Nat) : ncoll D s ≤ D.K / 256 * 32 * D.tiles := by
  unfold ncoll
  exact Nat.mul_le_mul_right _ (Nat.mul_le_mul_right _ (nsteps_le hok s))

section Simd2
variable (C : M1Max.Contract) {L : Launch} {A : Al} {I : In} {P : Nat} {pw : Nat → Nat → Nat → Prop}
  {D : Dims} {nb mb s : Nat}

/-- A SIMD-group from the kernel's start to the barrier. -/
theorem simd_start (hS : Shape L D A) (hok : Ok D) (ctxs : Fin 32 → Ctx) (hL : ∀ i : Fin 32, Lane D (ctxs i) nb mb s i)
    {r : Nat} (hr : ncoll D s + 1 ≤ r) {sh : Shared} (hm : Mem C L D I nb mb P (nb + mb * gy D) pw sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared), (Ev fun m => (runSimd C m r (List.ofFn fun i =>
        (⟨ctxs i, fun _ => none, [.block (body D.N D.K D.bits D.tiles D.splits)], .running⟩ : Thread))).run sh =
        some (List.ofFn V, sh')) ∧
      Mem C L D I nb mb P (nb + mb * gy D) (fun s' t e => pw s' t e ∨ (s' = s ∧ t < D.tiles ∧ e < 64)) sh' ∧
      ∀ i, (V i).status = .barrier 2 false true ∧ AtBar D ctxs nb mb s i (V i) := by
  obtain ⟨r', rfl⟩ : ∃ r', r = r' + 1 := ⟨r - 1, by omega⟩
  have hnc := ncoll_pos hok (hL 0).hs
  obtain ⟨e1, e2, e3⟩ := pos_zero D
  let Iv : Nat → Shared → Prop := fun idx sh' => Mem C L D I nb mb P (nb + mb * gy D) pw sh' ∧
    ∀ i : Fin 32, i.val < idx → TAt C D I nb mb s i 0 0 0 (tview sh' (ctxs i).thread)
  refine runSimd_collective_ev C r' _ 1 55 (.mma .f32 .f32) .f32 0
    (fun i => xval C D I nb mb s i (kOf D 0) (vOf D 0) (tOf D 0))
    (fun i => accV C D I nb mb s i (kOf D 0) (vOf D 0) (tOf D 0))
    (resolve_at C D I nb mb s _ _ _ (vOf_lt D _)) Iv (AtN C D I ctxs nb mb s 0)
    (Mem C L D I nb mb P (nb + mb * gy D) (fun s' t e => pw s' t e ∨ (s' = s ∧ t < D.tiles ∧ e < 64)))
    (fun i t => t.status = .barrier 2 false true ∧ AtBar D ctxs nb mb s i t) (fun i sh₀ hI => ?_)
    (fun U' sh₁ hU' hI' => simd_rounds C hS hok ctxs hL (ncoll D s - 1 - 0) 0 rfl hnc r' (by omega) U' sh₁ hU' hI'.1
      (fun i => by rw [e1, e2, e3]; exact hI'.2 i i.isLt)) sh ⟨hm, fun _ h => absurd h (by omega)⟩
  obtain ⟨l', sh', hre, hloc, hm', hoth, hT⟩ := lane_start C hS hok (hL i) (I := I) hI.1
  refine ⟨_, sh', hre.ev_stop rfl, ⟨hm', fun j hj => ?_⟩, by rw [e1, e2, e3]; rfl, l', by rw [e1, e2, e3], by
    rw [e1, e2, e3]; exact hloc⟩
  by_cases hij : j = i
  · subst hij; exact hT
  · rw [hoth _ (lane_threads hL (Ne.symm hij))]; exact hI.2 j (by have : j.val ≠ i.val := fun h => hij (Fin.ext h); omega)

/-- A SIMD-group after the barrier: its lanes' outputs. -/
theorem simd_out (hS : Shape L D A) (hok : Ok D) (ctxs : Fin 32 → Ctx) (hL : ∀ i : Fin 32, Lane D (ctxs i) nb mb s i)
    {r : Nat} (hr : 1 ≤ r) (U : Fin 32 → Thread) (hU : ∀ i, AtBar D ctxs nb mb s i (U i)) {sh : Shared}
    (hm : Mem C L D I nb mb (((nb + mb * gy D) * (32 * D.splits) + 32 * s) * (64 * D.tiles)) (nb + mb * gy D + 1) pw sh)
    (hpw : ∀ s' < D.splits, ∀ t < D.tiles, ∀ e' < 64, pw s' t e') :
    ∃ (V : Fin 32 → Thread) (sh' : Shared), (Ev fun m => (runSimd C m r (List.ofFn fun i =>
        { U i with status := .running })).run sh = some (List.ofFn V, sh')) ∧
      Mem C L D I nb mb (((nb + mb * gy D) * (32 * D.splits) + 32 * (s + 1)) * (64 * D.tiles)) (nb + mb * gy D + 1) pw sh' ∧
      ∀ i, (V i).status = .done := by
  obtain ⟨r', rfl⟩ : ∃ r', r = r' + 1 := ⟨r - 1, by omega⟩
  obtain ⟨V, sh', hrun, hI, hR⟩ := runSimd_blocked_ev C r' (fun i => { U i with status := .running })
    (fun idx sh' => Mem C L D I nb mb (((nb + mb * gy D) * (32 * D.splits) + 32 * s + idx) * (64 * D.tiles))
      (nb + mb * gy D + 1) pw sh') (fun _ t => t.status = .done) (fun i sh₀ hI => by
      obtain ⟨l, hUi, hF, h56⟩ := hU i
      obtain ⟨l', sh', hre, hm', -⟩ := lane_out C hS hok (hL i) hF h56 (by rw [← Nat.add_assoc]; exact hI) hpw
      refine ⟨⟨ctxs i, l', [], .done⟩, sh', ?_, by rw [Nat.add_assoc] at hm' ⊢; exact hm', rfl, rfl⟩
      rw [hUi]; exact hre.ev_stop rfl) sh (by simpa using hm)
  exact ⟨V, sh', hrun, by rw [show 32 * (s + 1) = 32 * s + 32 by ring, ← Nat.add_assoc]; exact hI, hR⟩

end Simd2
end Metal.Kernels.SplitMma

namespace Metal.Kernels.SplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineSplitMma hiding u32 u64

/-! ## Threadgroups and the launch -/

section Group
variable (C : M1Max.Contract) {L : Launch} {A : Al} {I : In} {D : Dims}

/-- The rounds every SIMD-group's run fits in: its multiply-accumulates, then the barrier. -/
def rounds (D : Dims) : Nat := D.K / 256 * 32 * D.tiles + 1

/-- A threadgroup: its SIMD-groups to the barrier, then their outputs. -/
theorem group_run (hS : Shape L D A) (hok : Ok D) {nb mb : Nat} (ctxOf : Fin D.splits → Fin 32 → Ctx)
    (hL : ∀ (s : Fin D.splits) (i : Fin 32), Lane D (ctxOf s i) nb mb s i) {sh : Shared}
    (hm : Mem C L D I nb mb ((nb + mb * gy D) * (32 * D.splits) * (64 * D.tiles)) (nb + mb * gy D)
      (fun _ _ _ => False) sh) :
    ∃ sh', (Ev fun m => (runGroup C m (rounds D) 2 (List.ofFn fun s : Fin D.splits => List.ofFn fun i =>
        (⟨ctxOf s i, fun _ => none, [.block (body D.N D.K D.bits D.tiles D.splits)], .running⟩ : Thread))).run sh =
        some ((), sh')) ∧
      Mem C L D I nb mb ((nb + mb * gy D + 1) * (32 * D.splits) * (64 * D.tiles)) (nb + mb * gy D + 1)
        (fun s t e => s < D.splits ∧ t < D.tiles ∧ e < 64) sh' := by
  have hpw : ∀ s' < D.splits, ∀ t < D.tiles, ∀ e' < 64, (fun s t e => s < D.splits ∧ t < D.tiles ∧ e < 64) s' t e' :=
    fun s' hs t ht e he => ⟨hs, ht, he⟩
  refine runGroup_barrier_ev C hok.splits (rounds D) 1 _ 2 false true
    (fun j sh' => Mem C L D I nb mb ((nb + mb * gy D) * (32 * D.splits) * (64 * D.tiles)) (nb + mb * gy D)
      (fun s' t e => s' < j ∧ t < D.tiles ∧ e < 64) sh')
    (fun j i t => AtBar D (ctxOf j) nb mb j i t) _ (fun j sh' hj => ?_) (fun U sh' hU hI => ?_) sh
    (hm.mono fun s' t e h => absurd h.1 (by omega))
  · obtain ⟨V, sh'', hrun, hm', hV⟩ := simd_start C hS hok (ctxOf j) (hL j) (r := rounds D)
      (by have := ncoll_le hok j; unfold rounds; omega) hj
    refine ⟨V, sh'', hrun, hm'.mono fun s' t e h => ?_, hV⟩
    by_cases hs : s' < j
    · exact .inl ⟨hs, h.2⟩
    · exact .inr ⟨by omega, h.2⟩
  · have hp := hI.pass
    obtain ⟨sh'', hrun, hm''⟩ := runGroup_done_ev C (rounds D) 0 (fun j i => { U j i with status := .running })
      (fun j sh' => Mem C L D I nb mb (((nb + mb * gy D) * (32 * D.splits) + 32 * j) * (64 * D.tiles))
        (nb + mb * gy D + 1) (fun s t e => s < D.splits ∧ t < D.tiles ∧ e < 64) sh')
      (fun j sh' hj => simd_out C hS hok (ctxOf j) (hL j) (by unfold rounds; omega) (U j) (hU j) hj hpw) _
      (by rw [Nat.mul_zero, Nat.add_zero]; exact hp)
    refine ⟨sh'', hrun, ?_⟩
    rw [show (nb + mb * gy D + 1) * (32 * D.splits) * (64 * D.tiles) =
      ((nb + mb * gy D) * (32 * D.splits) + 32 * D.splits) * (64 * D.tiles) by ring]
    exact hm''

end Group

section LaunchRun
variable (C : M1Max.Contract) {D : Dims} {I : In} {A : Al} {initial : Nat → ByteMemory.Bytes}

theorem launch_run (hok : Ok D) (hS : Shape (launch D I A initial) D A) (fuse : Nat → Bool) (garbage : Garbage) :
    ∃ sh, (∃ nb mb pw, Mem C (launch D I A initial) D I nb mb (gy D * gz D * (32 * D.splits) * (64 * D.tiles))
        (gy D * gz D) pw sh) ∧
      Ev fun m => runLaunch C fuse (launch D I A initial) garbage m (rounds D) 2 = some ⟨sh.bytes, sh.log⟩ := by
  have hb := launch_buffers (D := D) (I := I) (A := A) (initial := initial)
  obtain ⟨sh, hI, hr⟩ := (launch_tiles (I := I) (A := A) (initial := initial) hok).launch_run_ev C fuse garbage
    (rounds D) 2 (fun G sh => ∃ nb mb pw, Mem C (launch D I A initial) D I nb mb (G * (32 * D.splits) * (64 * D.tiles))
      G pw sh)
    ⟨0, 0, fun _ _ _ => False, rfl, initial_input hb garbage 0 (by simp [bufs]),
      initial_input hb garbage 1 (by simp [bufs]), initial_input hb garbage 2 (by simp [bufs]),
      initial_input hb garbage 3 (by simp [bufs]), initial_input hb garbage 4 (by simp [bufs]), rfl, rfl,
      fun _ _ _ _ h => absurd h (by simp), fun _ _ _ _ _ _ h => h.elim, fun a ha => by simp [Launch.initial] at ha⟩
    (fun bx byy bz hx hy hz sh hI => by
      obtain rfl : bx = 0 := by omega
      obtain ⟨nb', mb', pw, hm⟩ := hI
      have hG : 0 + byy * 1 + bz * 1 * gy D = byy + bz * gy D := by ring
      have hm' := hm.reset rfl garbage (0 + byy * 1 + bz * 1 * gy D) byy bz
      rw [hG] at hm' ⊢
      obtain ⟨sh', hrun, hm''⟩ := group_run C hS hok (fun s i => (launch D I A initial).ctxAt fuse 0 byy bz (32 * s + i))
        (fun s i => lane_of hok fuse hy hz s i) hm'
      exact ⟨sh', hrun, _, _, _, hm''⟩)
  exact ⟨sh, by simpa using hI, hr⟩

end LaunchRun
end Metal.Kernels.SplitMma

namespace Metal.Kernels.AffineSplitMma
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.SplitMma

/-! ## The GPU's output -/

variable (C : M1Max.Contract)

/-- **The GPU runs the affine split-MMA kernel as its source says**, for every `N`, `K`, `BITS`, `TILES`, `SPLITS`
the route can take (`BITS` 3 or 4, `K` a multiple of 256 with at least `SPLITS` K steps, `N` a multiple of
`8·TILES`, both below 2^16) and every row count `r` (1 ≤ r < 2^31, `x_shape[0]` an `int`), given that the text
compiles to `core N K bits tiles splits`. Under the GPU assumption, MLX's launch on any `x` (8-byte aligned: the
kernel reads it as `vec<bfloat, 4>`), its shape, `w` (4-aligned), `scales` and `biases` (2-aligned) writes `y`,
every element the split sum of the SIMD-groups' `simdgroup_multiply_accumulate` accumulations
(`expected`). -/
theorem gpu_output_of (N K bits tiles splits : Nat) (hbits : bits = 3 ∨ bits = 4) (hK : K % 256 = 0) (hKle : K < 2 ^ 16)
    (hN : N % (8 * tiles) = 0) (hNpos : 0 < N) (hNle : N < 2 ^ 16) (ht : 0 < tiles) (hs : 0 < splits)
    (hsK : splits ≤ K / 256) (text : List Char) (hc : (frontend text).bind elaborate = some (core N K bits tiles splits))
    (G : Gpu C) (hmax : 32 * splits ≤ G.maxThreads text) (r : Nat) (hr : 0 < r) (hr31 : r < 2 ^ 31)
    (X W S B : ByteMemory.Bytes) (ax ah aw as ab : Nat) (hax : 8 ∣ ax) (hah : 4 ∣ ah) (haw : 4 ∣ aw) (has : 2 ∣ as)
    (hab : 2 ∣ ab) :
    G.execute text (32 * splits, N / (8 * tiles), (r + 7) / 8) (32 * splits, 1, 1)
      [⟨.device, 2 * (r * K), ax, X⟩, ⟨.constant, 8, ah, shapeBytes r K⟩, ⟨.device, 4 * (N * (K * bits / 32)), aw, W⟩,
        ⟨.device, 2 * (N * (K / 64)), as, S⟩, ⟨.device, 2 * (N * (K / 64)), ab, B⟩] [2 * (r * N)] =
      some [expected C N K bits tiles splits r X W S B] := by
  let D : Dims := ⟨N, K, bits, tiles, splits, r⟩
  have hok : Ok D := ⟨hbits, hK, hKle, hN, hNpos, hNle, ht, hs, hsK, hr, hr31⟩
  let I : In := ⟨X, W, S, B⟩
  let A : Al := ⟨ax, ah, aw, as, ab⟩
  have h := gpu_owned C G (text := text) (kernel := core N K bits tiles splits)
    (grid := (32 * splits, N / (8 * tiles), (r + 7) / 8)) (tg := (32 * splits, 1, 1))
    (inputs := bufs D I A) (sizes := [2 * (r * N)]) (fun _ => yBytes C D I) hc (by simpa using hmax)
    (fun initial garbage => by
      have hS := launch_shape (D := D) (I := I) (A := A) (initial := initial) (Nat.mod_eq_zero_of_dvd hax)
        (Nat.mod_eq_zero_of_dvd hah) (Nat.mod_eq_zero_of_dvd haw) (Nat.mod_eq_zero_of_dvd has)
        (Nat.mod_eq_zero_of_dvd hab)
      obtain ⟨sh, ⟨nb, mb, pw, hm⟩, n, hn⟩ := launch_run C hok hS (G.fusion text) garbage
      refine ⟨n, rounds D, 2, sh, dev D, tgo D, hn n le_rfl, hm.log, ?_⟩
      intro i hi b hb
      obtain rfl : i = 0 := by simp at hi; omega
      have hb' : b < 2 * (r * N) := by simpa using hb
      show sh.bytes 5 b = yBytes C D I b
      have hidx : b / 2 / N * N + b / 2 % N = b / 2 := by rw [Nat.mul_comm]; exact Nat.div_add_mod _ _
      have hi' : b / 2 / N < r := (Nat.div_lt_iff_lt_mul hNpos).mpr (by omega)
      have hy := hm.y (b / 2 / N) hi' (b / 2 % N) (Nat.mod_lt _ hNpos)
        (key_lt D hok.N ht hs hi' (Nat.mod_lt _ hNpos))
      rw [hidx] at hy
      unfold yBytes
      rw [ite_eq_left hb', ← hy, cells_getD _ _ _ _ (by omega), show 2 * (b / 2) + b % 2 = b by omega])
  refine h.trans ?_
  show some [fun b => if b < 2 * (r * N) then yBytes C D I b else 0] = _
  congr 2
  funext b
  show (if b < 2 * (r * N) then yBytes C D I b else 0) = yBytes C D I b
  unfold yBytes
  split <;> rfl

/-! ## The route's instances

The `AffineMma` projections of the 4-to-223-row and chunk forwards (64 and 128 rows), `r` their row count:
`in_proj_qkv` (N 10240, K 5120), `in_proj_z` (N 6144, K 5120) and `out_proj` (N 5120, K 6144) at 3 and 4 bits,
`in_proj_a`/`in_proj_b` (N 48), `q_proj` (N 12288), `k_proj`/`v_proj` (N 1024) at 4 bits; `affineSplitMmaPlan`
gives TILES 2, SPLITS 2 for N ≥ 2048, else TILES 1, SPLITS 8. Sizes: `x` `2·r·K` bytes, `w` `4·N·K·BITS/32`,
`scales` and `biases` `2·N·K/64`, `y` `2·r·N`. -/

section Route
variable {X W S B : ByteMemory.Bytes} {ax ah aw as ab : Nat} {r : Nat}

theorem gpu_output_10240_5120_3 (G : Gpu C) (hmax : 64 ≤ G.maxThreads (text 10240 5120 3 2 2))
    (hr : 4 ≤ r ∧ r ≤ 223) (hax : 8 ∣ ax) (hah : 4 ∣ ah) (haw : 4 ∣ aw) (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 10240 5120 3 2 2) (64, 640, (r + 7) / 8) (64, 1, 1)
      [⟨.device, 2 * (r * 5120), ax, X⟩, ⟨.constant, 8, ah, shapeBytes r 5120⟩, ⟨.device, 19660800, aw, W⟩,
        ⟨.device, 1638400, as, S⟩, ⟨.device, 1638400, ab, B⟩] [2 * (r * 10240)] =
      some [expected C 10240 5120 3 2 2 r X W S B] :=
  gpu_output_of C 10240 5120 3 2 2 (by decide) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) _ compile_10240_5120_3 G hmax r (by omega) (by omega) X W S B ax ah aw as ab
    hax hah haw has hab

theorem gpu_output_10240_5120_4 (G : Gpu C) (hmax : 64 ≤ G.maxThreads (text 10240 5120 4 2 2))
    (hr : 4 ≤ r ∧ r ≤ 223) (hax : 8 ∣ ax) (hah : 4 ∣ ah) (haw : 4 ∣ aw) (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 10240 5120 4 2 2) (64, 640, (r + 7) / 8) (64, 1, 1)
      [⟨.device, 2 * (r * 5120), ax, X⟩, ⟨.constant, 8, ah, shapeBytes r 5120⟩, ⟨.device, 26214400, aw, W⟩,
        ⟨.device, 1638400, as, S⟩, ⟨.device, 1638400, ab, B⟩] [2 * (r * 10240)] =
      some [expected C 10240 5120 4 2 2 r X W S B] :=
  gpu_output_of C 10240 5120 4 2 2 (by decide) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) _ compile_10240_5120_4 G hmax r (by omega) (by omega) X W S B ax ah aw as ab
    hax hah haw has hab

theorem gpu_output_6144_5120_3 (G : Gpu C) (hmax : 64 ≤ G.maxThreads (text 6144 5120 3 2 2))
    (hr : 4 ≤ r ∧ r ≤ 223) (hax : 8 ∣ ax) (hah : 4 ∣ ah) (haw : 4 ∣ aw) (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 6144 5120 3 2 2) (64, 384, (r + 7) / 8) (64, 1, 1)
      [⟨.device, 2 * (r * 5120), ax, X⟩, ⟨.constant, 8, ah, shapeBytes r 5120⟩, ⟨.device, 11796480, aw, W⟩,
        ⟨.device, 983040, as, S⟩, ⟨.device, 983040, ab, B⟩] [2 * (r * 6144)] =
      some [expected C 6144 5120 3 2 2 r X W S B] :=
  gpu_output_of C 6144 5120 3 2 2 (by decide) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) _ compile_6144_5120_3 G hmax r (by omega) (by omega) X W S B ax ah aw as ab
    hax hah haw has hab

theorem gpu_output_6144_5120_4 (G : Gpu C) (hmax : 64 ≤ G.maxThreads (text 6144 5120 4 2 2))
    (hr : 4 ≤ r ∧ r ≤ 223) (hax : 8 ∣ ax) (hah : 4 ∣ ah) (haw : 4 ∣ aw) (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 6144 5120 4 2 2) (64, 384, (r + 7) / 8) (64, 1, 1)
      [⟨.device, 2 * (r * 5120), ax, X⟩, ⟨.constant, 8, ah, shapeBytes r 5120⟩, ⟨.device, 15728640, aw, W⟩,
        ⟨.device, 983040, as, S⟩, ⟨.device, 983040, ab, B⟩] [2 * (r * 6144)] =
      some [expected C 6144 5120 4 2 2 r X W S B] :=
  gpu_output_of C 6144 5120 4 2 2 (by decide) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) _ compile_6144_5120_4 G hmax r (by omega) (by omega) X W S B ax ah aw as ab
    hax hah haw has hab

theorem gpu_output_48_5120_4 (G : Gpu C) (hmax : 256 ≤ G.maxThreads (text 48 5120 4 1 8))
    (hr : 4 ≤ r ∧ r ≤ 223) (hax : 8 ∣ ax) (hah : 4 ∣ ah) (haw : 4 ∣ aw) (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 48 5120 4 1 8) (256, 6, (r + 7) / 8) (256, 1, 1)
      [⟨.device, 2 * (r * 5120), ax, X⟩, ⟨.constant, 8, ah, shapeBytes r 5120⟩, ⟨.device, 122880, aw, W⟩,
        ⟨.device, 7680, as, S⟩, ⟨.device, 7680, ab, B⟩] [2 * (r * 48)] =
      some [expected C 48 5120 4 1 8 r X W S B] :=
  gpu_output_of C 48 5120 4 1 8 (by decide) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) _ compile_48_5120_4 G hmax r (by omega) (by omega) X W S B ax ah aw as ab
    hax hah haw has hab

theorem gpu_output_5120_6144_3 (G : Gpu C) (hmax : 64 ≤ G.maxThreads (text 5120 6144 3 2 2))
    (hr : 4 ≤ r ∧ r ≤ 223) (hax : 8 ∣ ax) (hah : 4 ∣ ah) (haw : 4 ∣ aw) (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 5120 6144 3 2 2) (64, 320, (r + 7) / 8) (64, 1, 1)
      [⟨.device, 2 * (r * 6144), ax, X⟩, ⟨.constant, 8, ah, shapeBytes r 6144⟩, ⟨.device, 11796480, aw, W⟩,
        ⟨.device, 983040, as, S⟩, ⟨.device, 983040, ab, B⟩] [2 * (r * 5120)] =
      some [expected C 5120 6144 3 2 2 r X W S B] :=
  gpu_output_of C 5120 6144 3 2 2 (by decide) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) _ compile_5120_6144_3 G hmax r (by omega) (by omega) X W S B ax ah aw as ab
    hax hah haw has hab

theorem gpu_output_5120_6144_4 (G : Gpu C) (hmax : 64 ≤ G.maxThreads (text 5120 6144 4 2 2))
    (hr : 4 ≤ r ∧ r ≤ 223) (hax : 8 ∣ ax) (hah : 4 ∣ ah) (haw : 4 ∣ aw) (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 5120 6144 4 2 2) (64, 320, (r + 7) / 8) (64, 1, 1)
      [⟨.device, 2 * (r * 6144), ax, X⟩, ⟨.constant, 8, ah, shapeBytes r 6144⟩, ⟨.device, 15728640, aw, W⟩,
        ⟨.device, 983040, as, S⟩, ⟨.device, 983040, ab, B⟩] [2 * (r * 5120)] =
      some [expected C 5120 6144 4 2 2 r X W S B] :=
  gpu_output_of C 5120 6144 4 2 2 (by decide) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) _ compile_5120_6144_4 G hmax r (by omega) (by omega) X W S B ax ah aw as ab
    hax hah haw has hab

theorem gpu_output_12288_5120_4 (G : Gpu C) (hmax : 64 ≤ G.maxThreads (text 12288 5120 4 2 2))
    (hr : 4 ≤ r ∧ r ≤ 223) (hax : 8 ∣ ax) (hah : 4 ∣ ah) (haw : 4 ∣ aw) (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 12288 5120 4 2 2) (64, 768, (r + 7) / 8) (64, 1, 1)
      [⟨.device, 2 * (r * 5120), ax, X⟩, ⟨.constant, 8, ah, shapeBytes r 5120⟩, ⟨.device, 31457280, aw, W⟩,
        ⟨.device, 1966080, as, S⟩, ⟨.device, 1966080, ab, B⟩] [2 * (r * 12288)] =
      some [expected C 12288 5120 4 2 2 r X W S B] :=
  gpu_output_of C 12288 5120 4 2 2 (by decide) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) _ compile_12288_5120_4 G hmax r (by omega) (by omega) X W S B ax ah aw as ab
    hax hah haw has hab

theorem gpu_output_1024_5120_4 (G : Gpu C) (hmax : 256 ≤ G.maxThreads (text 1024 5120 4 1 8))
    (hr : 4 ≤ r ∧ r ≤ 223) (hax : 8 ∣ ax) (hah : 4 ∣ ah) (haw : 4 ∣ aw) (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 1024 5120 4 1 8) (256, 128, (r + 7) / 8) (256, 1, 1)
      [⟨.device, 2 * (r * 5120), ax, X⟩, ⟨.constant, 8, ah, shapeBytes r 5120⟩, ⟨.device, 2621440, aw, W⟩,
        ⟨.device, 163840, as, S⟩, ⟨.device, 163840, ab, B⟩] [2 * (r * 1024)] =
      some [expected C 1024 5120 4 1 8 r X W S B] :=
  gpu_output_of C 1024 5120 4 1 8 (by decide) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) _ compile_1024_5120_4 G hmax r (by omega) (by omega) X W S B ax ah aw as ab
    hax hah haw has hab

end Route


end Metal.Kernels.AffineSplitMma
