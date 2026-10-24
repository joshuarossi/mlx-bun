import metal.Elab
import metal.Frontend
import metal.Assemble
import host.mlx.PrefillKernelSources
import metal.kernels.DownMmaWide

namespace Metal.Kernels.DownK3iMmaWide
open Metal Metal.Core

/-! # down-mma-wide.ts: `mlx_bun_trellis_down_k3i_mma_wide`

The source and header are those of `mlx_bun_trellis_down_mma_wide`; the kernel name and the
template arguments differ.

The header functions the body calls (inlined below; their slots are listed under `body`):

```
static inline int trellis_y(uint s) {
  const uint x = s * 34038481u + 76625530u;
  const uint p = (x & 0x00FF00FFu) + ((x >> 8) & 0x00FF00FFu);
  return (int)((p & 0xFFFFu) + (p >> 16)) - 510;
}
static inline float trellis_y_f32(uint s) {
  return as_type<float>(0x4b000000u | uint(trellis_y(s) + 510)) - 8389118.0f;
}
#define TRELLIS_RCP (1.0f / 147.800537109375f)
template <int K, int L_>
inline uint block_state(thread const uint* w, thread const uint* v, uint t) {
  const uint b = t * (uint)K;
  const uint off = b & 31u;
  if (off + (uint)L_ <= 32u) return (w[b >> 5] >> off) & ((1u << (uint)L_) - 1u);
  const uint vi = (b + 16u) >> 5;
  return (v[vi] >> (b + 16u - 32u * vi)) & ((1u << (uint)L_) - 1u);
}
```
The body:

```
const uint M = (uint)x_shape[0];
const uint lane = thread_index_in_simdgroup;
threadgroup half codebook[1 << L];
for (uint i = simdgroup_index_in_threadgroup * 32u + lane; i < (1u << (uint)L); i += 32u * (uint)SG_TG)
  codebook[i] = half(trellis_y_f32(i));
threadgroup_barrier(metal::mem_flags::mem_threadgroup);
const uint id = threadgroup_position_in_grid.y * (uint)SG_TG + simdgroup_index_in_threadgroup;
const uint groupsPerBlock = 32u / (uint)S;
const uint nGroups = ((uint)C / 256u) * groupsPerBlock;
if (id >= nGroups * (uint)SPLITS) return;
const uint cg = id % nGroups, split = id / nGroups;
const uint block = cg / groupsPerBlock, pg = (cg % groupsPerBlock) * 8u * (uint)S;
const uint fm = ((lane / 4u) & 4u) + ((lane / 2u) % 4u);
const uint fn = ((lane / 4u) & 2u) * 2u + (lane % 2u) * 2u;
const uint wpb = 8u * (uint)K;
const ulong rowWords = (ulong)(INTERLEAVE ? 2u : (uint)C / 256u) * wpb;
const device uint32_t* words = codes + (INTERLEAVE
  ? (ulong)(block / 2u) * (ulong)R * 2u * wpb + (block % 2u) * wpb : (ulong)block * wpb);
// This lane's 2S positions start at p0; realign its bit window to bit 0.
const uint p0 = pg + (uint)S * fn;
const uint bit0 = p0 * (uint)K, w0 = bit0 >> 5, off0 = bit0 & 31u;
const uint mBase = threadgroup_position_in_grid.z * 8u * (uint)MT;
const uint rowsPer = (((uint)R + (uint)SPLITS - 1u) / (uint)SPLITS + 7u) & ~7u;
const uint r0 = split * rowsPer;
const uint r1 = metal::min((uint)R, r0 + rowsPer);
const device T* xm[MT];
metal::simdgroup_float8x8 acc[S][MT];
#pragma clang loop unroll(full)
for (uint bk = 0; bk < (uint)MT; ++bk) {
  xm[bk] = x + (ulong)metal::min(mBase + 8u * bk + fm, M - 1u) * (ulong)R;
  #pragma clang loop unroll(full)
  for (uint s = 0; s < (uint)S; ++s) acc[s][bk] = metal::make_filled_simdgroup_matrix<float, 8, 8>(0.0f);
}
// The window's words in a row's block (the last ones wrap to its first).
uint wordAt[NW + 1];
#pragma clang loop unroll(full)
for (uint i = 0; i <= (uint)NW; ++i) wordAt[i] = (w0 + i) % wpb;
const device uint32_t* rowCodes = words + (ulong)(r0 + fm) * rowWords;
for (uint r = r0; r < r1; r += 8u, rowCodes += 8u * rowWords) {
  uint raw[NW + 1];
  #pragma clang loop unroll(full)
  for (uint i = 0; i <= (uint)NW; ++i) raw[i] = rowCodes[wordAt[i]];
  uint w[NW], v[NW];
  #pragma clang loop unroll(full)
  for (uint i = 0; i < (uint)NW; ++i) w[i] = off0 ? (raw[i] >> off0) | (raw[i + 1] << (32u - off0)) : raw[i];
  // Virtual word i: bits [32i - 16, 32i + 16) of the realigned window.
  #pragma clang loop unroll(full)
  for (uint i = 1; i < (uint)NW; ++i) v[i] = (w[i - 1] >> 16) | (w[i] << 16);
  const uint ra = r + fn;
  const float sa = float(scales[ra]) * TRELLIS_RCP, sb = float(scales[ra + 1u]) * TRELLIS_RCP;
  metal::simdgroup_float8x8 a[MT];
  #pragma clang loop unroll(full)
  for (uint bk = 0; bk < (uint)MT; ++bk) {
    a[bk].thread_elements()[0] = float(xm[bk][ra]) * sa;
    a[bk].thread_elements()[1] = float(xm[bk][ra + 1u]) * sb;
  }
  #pragma clang loop unroll(full)
  for (uint s = 0; s < (uint)S; ++s) {
    metal::simdgroup_half8x8 b;
    b.thread_elements()[0] = codebook[block_state<K, L>(w, v, s)];
    b.thread_elements()[1] = codebook[block_state<K, L>(w, v, s + (uint)S)];
    #pragma clang loop unroll(full)
    for (uint bk = 0; bk < (uint)MT; ++bk)
      metal::simdgroup_multiply_accumulate(acc[s][bk], a[bk], b, acc[s][bk]);
  }
}
#pragma clang loop unroll(full)
for (uint bk = 0; bk < (uint)MT; ++bk) {
  const uint m = mBase + 8u * bk + fm;
  if (m >= M) continue;
  device float* out = partial + ((ulong)m * (ulong)SPLITS + split) * (ulong)C + (ulong)block * 256u + 255u - p0;
  #pragma clang loop unroll(full)
  for (uint s = 0; s < (uint)S; ++s) {
    out[-(int)s] = acc[s][bk].thread_elements()[0];
    out[-(int)((uint)S + s)] = acc[s][bk].thread_elements()[1];
  }
}
```
Launch (down-mma-wide.ts:147-165, 179-185, `downK3InterleavedMmaWidePass`): inputs `x` bfloat16
`[M, R]` (its `x_shape` read), `codes` uint32 (3-bit block-interleaved words `[C/512, R, 48]`),
`scales` float16 `[R]`; output `partial` float32 `[M, SPLITS, C]`; `T` = bfloat16; template ints R,
C, K, L, SPLITS, SG_TG, INTERLEAVE, MT, S, NW with NW = ⌈(2·S·K + L − 1)/32⌉ + 1. The route's one
instance is the down projection of the 40 layers with interleaved 3-bit down codes, for every row
count (`plan("interleaved", M)` and `CodebookMmaDownK3i` both take `DOWN_ONE_BLOCK`): R = 17408,
C = 5120, K = 3, L = 12, SPLITS = 8, SG_TG = 4, INTERLEAVE = 1, MT = 1, S = 16, NW = 5. The
SIMD-group matrices `a` and `b` (declared without initializer) are thread arrays; `acc[s][bk]` is
`acc`'s element s·MT + bk. The core is stated generic over K, S, MT, NW and whether INTERLEAVE is
nonzero (`core k s mt nw il`), at the instance `core 3 16 1 5 true`. -/

def u32l (n : Nat) : CExpr := .lit (.int .u32 n)
def u64l (n : Nat) : CExpr := .lit (.int .u64 n)
def u16l (n : Nat) : CExpr := .lit (.int .u16 n)
def i32l (n : Nat) : CExpr := .lit (.int .i32 n)
def f32l (bits : Nat) : CExpr := .lit (.f32 (Val.ofF32Bits bits))

def u32 (op : Core.BinOp) (a b : CExpr) : CExpr := .bin op .u32 0 a b
def u64 (op : Core.BinOp) (a b : CExpr) : CExpr := .bin op .u64 0 a b
def toU64 (e : CExpr) : CExpr := .conv .u64 e

/-! ## The header functions -/

/-- `trellis_y(s)` with `s` in slot `b`: slots `b` s, `b + 1` the result, `b + 2` x, `b + 3` p. -/
def trellisY (b : Nat) : CStmt :=
  .scope
    [.set (b + 2) (u32 .add (u32 .mul (.local b) (u32l 34038481)) (u32l 76625530)),
     .set (b + 3) (u32 .add (u32 .bitAnd (.local (b + 2)) (u32l 0x00FF00FF))
       (u32 .bitAnd (u32 .shr (.local (b + 2)) (u32l 8)) (u32l 0x00FF00FF))),
     .set (b + 1) (.bin .sub .i32 0
       (.conv .i32 (u32 .add (u32 .bitAnd (.local (b + 3)) (u32l 0xFFFF)) (u32 .shr (.local (b + 3)) (u32l 16))))
       (i32l 510)),
     .leave]

/-- `trellis_y_f32(s)` with `s` in slot `b`: slots `b` s, `b + 1` the result, `trellis_y` at `b + 2`. -/
def trellisYF32 (b : Nat) : CStmt :=
  .scope
    [.set (b + 2) (.local b),
     trellisY (b + 2),
     .set (b + 1) (.bin .sub .f32 0
       (.bitcast .f32 (u32 .bitOr (u32l 0x4B000000) (.conv .u32 (.bin .add .i32 0 (.local (b + 3)) (i32l 510)))))
       (f32l 0x4B0001FE)),
     .leave]

/-- `block_state<K, 12>(w, v, t)` with `w`, `v`, `t` in slots `b`, `b + 1`, `b + 2`: slots `b + 3` the
result, `b + 4` b, `b + 5` off, `b + 6` vi. -/
def blockState (k b : Nat) : CStmt :=
  .scope
    [.set (b + 4) (u32 .mul (.local (b + 2)) (u32l k)),
     .set (b + 5) (u32 .bitAnd (.local (b + 4)) (u32l 31)),
     .ite (u32 .le (u32 .add (.local (b + 5)) (u32l 12)) (u32l 32))
       [.set (b + 3) (u32 .bitAnd
          (u32 .shr (.load (.scalar .u32) (.offset (.local b) (u32 .shr (.local (b + 4)) (u32l 5)))) (.local (b + 5)))
          (u32l 4095)),
        .leave] [],
     .set (b + 6) (u32 .shr (u32 .add (.local (b + 4)) (u32l 16)) (u32l 5)),
     .set (b + 3) (u32 .bitAnd
       (u32 .shr (.load (.scalar .u32) (.offset (.local (b + 1)) (.local (b + 6))))
         (u32 .sub (u32 .add (.local (b + 4)) (u32l 16)) (u32 .mul (u32l 32) (.local (b + 6)))))
       (u32l 4095)),
     .leave]

/-! ## The body -/

/-- The threadgroup codebook: `codebook[i] = half(trellis_y_f32(i))` (slot 8 i, `trellis_y_f32` at 9). -/
def codebookLoop : List CStmt :=
  [.set 8 (u32 .add (u32 .mul (.coord .simdgroupIndexInThreadgroup) (u32l 32)) (.local 6)),
   .loop (u32 .lt (.local 8) (u32l 4096)) [.set 8 (u32 .add (.local 8) (u32l 128))]
     [.set 9 (.local 8),
      trellisYF32 9,
      .store (.scalar .f16) (.offset (.local 7) (.local 8)) (.conv .f16 (.local 10))]]

/-- `acc[s][bk]`: element s·MT + bk of `acc` (slot 36). -/
def accAt (mt : Nat) (s bk : CExpr) : CExpr := .offset (.offset (.local 36) (u64 .mul (toU64 s) (u64l mt))) bk

def inc (i : Nat) : List CStmt := [.set i (u32 .add (.local i) (u32l 1))]
def lt (i : Nat) (n : CExpr) : CExpr := u32 .lt (.local i) n
def ld (t : Scalar) (p : CExpr) : CExpr := .load (.scalar t) p
def ptrAt (b : Nat) (i : CExpr) : CExpr := .offset (.local b) i

/-- MLX's fragment coordinates of lane (slot 6): row `fm`, first column `fn`. -/
def fmExpr : CExpr :=
  u32 .add (u32 .bitAnd (u32 .div (.local 6) (u32l 4)) (u32l 4)) (u32 .rem (u32 .div (.local 6) (u32l 2)) (u32l 4))
def fnExpr : CExpr :=
  u32 .add (u32 .mul (u32 .bitAnd (u32 .div (.local 6) (u32l 4)) (u32l 2)) (u32l 2))
    (u32 .mul (u32 .rem (.local 6) (u32l 2)) (u32l 2))

/-- `words`' offset from `codes`: row-major `block·wpb`, interleaved block pairs of all R rows. -/
def wordsOffset (il : Bool) : CExpr :=
  if il then
    u64 .add (u64 .mul (u64 .mul (u64 .mul (toU64 (u32 .div (.local 20) (u32l 2))) (u64l 17408)) (u64l 2)) (toU64 (.local 24)))
      (toU64 (u32 .mul (u32 .rem (.local 20) (u32l 2)) (.local 24)))
  else u64 .mul (toU64 (.local 20)) (toU64 (.local 24))

/-- The SIMD-group's place (slots 15 … 34): `id`, the group and split, the lane's fragment, its code
window. -/
def setup (k s mt : Nat) (il : Bool) : List CStmt :=
  [.set 15 (u32 .add (u32 .mul (.component (.coord .threadgroupPositionInGrid) (u32l 1)) (u32l 4))
     (.coord .simdgroupIndexInThreadgroup)),
   .set 16 (u32l (32 / s)),
   .set 17 (u32 .mul (u32l 20) (.local 16)),
   .ite (u32 .ge (.local 15) (u32 .mul (.local 17) (u32l 8))) [.leave] [],
   .set 18 (u32 .rem (.local 15) (.local 17)),
   .set 19 (u32 .div (.local 15) (.local 17)),
   .set 20 (u32 .div (.local 18) (.local 16)),
   .set 21 (u32 .mul (u32 .mul (u32 .rem (.local 18) (.local 16)) (u32l 8)) (u32l s)),
   .set 22 fmExpr,
   .set 23 fnExpr,
   .set 24 (u32l (8 * k)),
   .set 25 (u64 .mul (u64l (if il then 2 else 20)) (toU64 (.local 24))),
   .set 26 (.offset (.local 2) (wordsOffset il)),
   .set 27 (u32 .add (.local 21) (u32 .mul (u32l s) (.local 23))),
   .set 28 (u32 .mul (.local 27) (u32l k)),
   .set 29 (u32 .shr (.local 28) (u32l 5)),
   .set 30 (u32 .bitAnd (.local 28) (u32l 31)),
   .set 31 (u32 .mul (u32 .mul (.component (.coord .threadgroupPositionInGrid) (u32l 2)) (u32l 8)) (u32l mt)),
   .set 32 (u32l 2176),
   .set 33 (u32 .mul (.local 19) (.local 32)),
   .set 34 (.bin .min .u32 0 (u32l 17408) (u32 .add (.local 33) (.local 32)))]

/-- `xm` (slot 35, thread array 0) and `acc` (slot 36, thread array 1) for block `bk` (slot 37). -/
def initBlock (s mt : Nat) : List CStmt :=
  [.store (.ptr .device (.scalar .bf16)) (ptrAt 35 (.local 37))
     (.offset (.local 0) (u64 .mul
       (toU64 (.bin .min .u32 0 (u32 .add (u32 .add (.local 31) (u32 .mul (u32l 8) (.local 37))) (.local 22))
         (u32 .sub (.local 5) (u32l 1))))
       (u64l 17408))),
   .set 38 (u32l 0),
   .loop (lt 38 (u32l s)) (inc 38) [.store (.vec .f32 2) (accAt mt (.local 38) (.local 37)) (.vector .f32 [f32l 0, f32l 0])]]

/-- `b`'s two elements (slot 55, thread array 7) and the `mt` multiply-accumulates of sub-tile `s`
(slot 54): `block_state` at 56 and 63, block `bk` in slot 70, the result in 71. -/
def subTile (k s mt : Nat) : List CStmt :=
  [.array 55 false 7 (.vec .f16 2),
   .set 56 (.local 45), .set 57 (.local 46), .set 58 (.local 54),
   blockState k 56,
   .store (.scalar .f16) (.offset (.ptrCast (.scalar .f16) (.local 55)) (i32l 0)) (ld .f16 (ptrAt 7 (.local 59))),
   .set 63 (.local 45), .set 64 (.local 46), .set 65 (u32 .add (.local 54) (u32l s)),
   blockState k 63,
   .store (.scalar .f16) (.offset (.ptrCast (.scalar .f16) (.local 55)) (i32l 1)) (ld .f16 (ptrAt 7 (.local 66))),
   .set 70 (u32l 0),
   .loop (lt 70 (u32l mt)) (inc 70)
     [.collective 2 71 (.mma .f32 .f16) .f32
        (.vector .f32 [.load (.vec .f32 2) (ptrAt 52 (.local 70)), .load (.vec .f16 2) (.local 55),
          .load (.vec .f32 2) (accAt mt (.local 54) (.local 70))])
        (u16l 0),
      .store (.vec .f32 2) (accAt mt (.local 54) (.local 70)) (.local 71)]]

/-- One row block `r` (slot 42): `raw` (43), `w` (45), `v` (46), `ra` (49), `sa`, `sb` (50, 51), `a`
(52, thread array 6) for each block `bk` (53), then the sub-tiles `s` (54). -/
def rowBody (k s mt nw : Nat) : List CStmt :=
  [.array 43 false 3 (.scalar .u32),
   .set 44 (u32l 0),
   .loop (u32 .le (.local 44) (u32l nw)) (inc 44)
     [.store (.scalar .u32) (ptrAt 43 (.local 44)) (ld .u32 (ptrAt 41 (ld .u32 (ptrAt 39 (.local 44)))))],
   .array 45 false 4 (.scalar .u32),
   .array 46 false 5 (.scalar .u32),
   .set 47 (u32l 0),
   .loop (lt 47 (u32l nw)) (inc 47)
     [.store (.scalar .u32) (ptrAt 45 (.local 47))
       (.cond (.conv .bool (.local 30))
         (u32 .bitOr (u32 .shr (ld .u32 (ptrAt 43 (.local 47))) (.local 30))
           (u32 .shl (ld .u32 (ptrAt 43 (u32 .add (.local 47) (u32l 1)))) (u32 .sub (u32l 32) (.local 30))))
         (ld .u32 (ptrAt 43 (.local 47))))],
   .set 48 (u32l 1),
   .loop (lt 48 (u32l nw)) (inc 48)
     [.store (.scalar .u32) (ptrAt 46 (.local 48))
       (u32 .bitOr (u32 .shr (ld .u32 (ptrAt 45 (u32 .sub (.local 48) (u32l 1)))) (u32l 16))
         (u32 .shl (ld .u32 (ptrAt 45 (.local 48))) (u32l 16)))],
   .set 49 (u32 .add (.local 42) (.local 23)),
   .set 50 (.bin .mul .f32 0 (.conv .f32 (ld .f16 (ptrAt 3 (.local 49)))) (f32l 0x3BDDB447)),
   .set 51 (.bin .mul .f32 0 (.conv .f32 (ld .f16 (ptrAt 3 (u32 .add (.local 49) (u32l 1))))) (f32l 0x3BDDB447)),
   .array 52 false 6 (.vec .f32 2),
   .set 53 (u32l 0),
   .loop (lt 53 (u32l mt)) (inc 53)
     [.store (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (ptrAt 52 (.local 53))) (i32l 0))
        (.bin .mul .f32 0 (.conv .f32 (ld .bf16 (.offset (.load (.ptr .device (.scalar .bf16)) (ptrAt 35 (.local 53))) (.local 49))))
          (.local 50)),
      .store (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (ptrAt 52 (.local 53))) (i32l 1))
        (.bin .mul .f32 0
          (.conv .f32 (ld .bf16 (.offset (.load (.ptr .device (.scalar .bf16)) (ptrAt 35 (.local 53)))
            (u32 .add (.local 49) (u32l 1)))))
          (.local 51))],
   .set 54 (u32l 0),
   .loop (lt 54 (u32l s)) (inc 54) (subTile k s mt)]

/-- The partials of block `bk` (slot 72): row `m` (73), `out` (74), sub-tile `s` (75). -/
def outBody (s mt : Nat) : List CStmt :=
  [.set 73 (u32 .add (u32 .add (.local 31) (u32 .mul (u32l 8) (.local 72))) (.local 22)),
   .ite (u32 .ge (.local 73) (.local 5)) [.continue_] [],
   .set 74 (.offset (.offset (.offset (.offset (.local 4)
       (u64 .mul (u64 .add (u64 .mul (toU64 (.local 73)) (u64l 8)) (toU64 (.local 19))) (u64l 5120)))
       (u64 .mul (toU64 (.local 20)) (u64l 256))) (u32l 255))
     (.un .neg .i64 (.conv .i64 (.local 27)))),
   .set 75 (u32l 0),
   .loop (lt 75 (u32l s)) (inc 75)
     [.store (.scalar .f32) (.offset (.local 74) (.un .neg .i32 (.conv .i32 (.local 75))))
        (ld .f32 (.offset (.ptrCast (.scalar .f32) (accAt mt (.local 75) (.local 72))) (i32l 0))),
      .store (.scalar .f32) (.offset (.local 74) (.un .neg .i32 (.conv .i32 (u32 .add (u32l s) (.local 75)))))
        (ld .f32 (.offset (.ptrCast (.scalar .f32) (accAt mt (.local 75) (.local 72))) (i32l 1)))]]

/-- Slots: 0 x, 1 x_shape, 2 codes, 3 scales, 4 partial, 5 M, 6 lane, 7 codebook (threadgroup array 0),
8 i, 9 … 14 `trellis_y_f32`'s, 15 id, 16 groupsPerBlock, 17 nGroups, 18 cg, 19 split, 20 block, 21 pg,
22 fm, 23 fn, 24 wpb, 25 rowWords, 26 words, 27 p0, 28 bit0, 29 w0, 30 off0, 31 mBase, 32 rowsPer,
33 r0, 34 r1, 35 xm (thread array 0), 36 acc (thread array 1), 37 bk, 38 s, 39 wordAt (thread array
2), 40 i, 41 rowCodes, 42 r, 43 raw (thread array 3), 44 i, 45 w (4), 46 v (5), 47 i, 48 i, 49 ra,
50 sa, 51 sb, 52 a (6), 53 bk, 54 s, 55 b (7), 56 … 62 and 63 … 69 the two `block_state`s, 70 bk,
71 the multiply-accumulate's result, 72 bk, 73 m, 74 out, 75 s. -/
def body (k s mt nw : Nat) (il : Bool) : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .bf16⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .i32⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .u32⟩)),
   .set 3 (.lit (.ptr ⟨3, 0, .scalar .f16⟩)),
   .set 4 (.lit (.ptr ⟨4, 0, .scalar .f32⟩)),
   .scope
     ([.set 5 (.conv .u32 (ld .i32 (ptrAt 1 (i32l 0)))),
       .set 6 (.coord .threadIndexInSimdgroup),
       .array 7 true 0 (.scalar .f16)] ++
      codebookLoop ++
      [.barrier 1 false true] ++
      setup k s mt il ++
      [.array 35 false 0 (.ptr .device (.scalar .bf16)),
       .array 36 false 1 (.vec .f32 2),
       .set 37 (u32l 0),
       .loop (lt 37 (u32l mt)) (inc 37) (initBlock s mt),
       .array 39 false 2 (.scalar .u32),
       .set 40 (u32l 0),
       .loop (u32 .le (.local 40) (u32l nw)) (inc 40)
         [.store (.scalar .u32) (ptrAt 39 (.local 40)) (u32 .rem (u32 .add (.local 29) (.local 40)) (.local 24))],
       .set 41 (.offset (.local 26) (u64 .mul (toU64 (u32 .add (.local 33) (.local 22))) (.local 25))),
       .set 42 (.local 33),
       .loop (lt 42 (.local 34))
         [.set 42 (u32 .add (.local 42) (u32l 8)), .set 41 (.offset (.local 41) (u64 .mul (u64l 8) (.local 25)))]
         (rowBody k s mt nw),
       .set 72 (u32l 0),
       .loop (lt 72 (u32l mt)) (inc 72) (outBody s mt)])]

/-- The kernel: threadgroup `codebook`; thread arrays `xm`, `acc`, `wordAt`, `raw`, `w`, `v`, `a`, `b`. -/
def core (k s mt nw : Nat) (il : Bool) : Kernel :=
  ⟨5, [(.scalar .f16, 4096)],
    [(.ptr .device (.scalar .bf16), mt), (.vec .f32 2, s * mt), (.scalar .u32, nw + 1), (.scalar .u32, nw + 1),
      (.scalar .u32, nw), (.scalar .u32, nw), (.vec .f32 2, mt), (.vec .f16 2, 1)],
    body k s mt nw il⟩

section Texts
open Host.Mlx
/-! ## The texts MLX compiles

`x` `bfloat16 [M, 17408]` (any M), `codes` `uint32 [10, 17408, 48]` (block-interleaved words), `scales`
`float16 [17408]`; any shapes of at least 8 elements give the same text. -/

def inputs : List Assemble.Input :=
  [⟨chars!"x", .bfloat16, [9, 17408]⟩, ⟨chars!"codes", .uint32, [10, 17408, 48]⟩, ⟨chars!"scales", .float16, [17408]⟩]

def args (k s mt nw : Nat) : List Assemble.TemplateArg :=
  [.dtype chars!"T" .bfloat16, .int chars!"R" 17408, .int chars!"C" 5120, .int chars!"K" k, .int chars!"L" 12,
    .int chars!"SPLITS" 8, .int chars!"SG_TG" 4, .int chars!"INTERLEAVE" 1, .int chars!"MT" mt, .int chars!"S" s,
    .int chars!"NW" nw]

def assembled (k s mt nw : Nat) : Option (List Char) :=
  Assemble.assemble (PrefillSources.name .downK3iMmaWide) inputs [chars!"partial"] [.float32]
    (PrefillSources.source .downK3iMmaWide) (PrefillSources.header .downK3iMmaWide) (args k s mt nw) false

def text (k s mt nw : Nat) : List Char := (assembled k s mt nw).getD []

/-- Every route instance assembles. -/
theorem assembled_route : (assembled 3 16 1 5).isSome := by
  decide +kernel

kernel_rfl compile_eq : (frontend (text 3 16 1 5)).bind elaborate = some (core 3 16 1 5 true)

end Texts
end Metal.Kernels.DownK3iMmaWide

namespace Metal.Kernels.DownK3iMmaWide
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis

/-! ## The output

The core is `mlx_bun_trellis_down_mma_wide`'s at the same parameters, so its theorem (DownMmaWide.lean
`gpu_output_of`) applies: 3-bit interleaved codes `[10, 17408, 48]` (33423360 bytes), S 16, MT 1, NW 5, for rows
`2 ≤ M ≤ 223`; grid `[128, 80, ⌈M / 8⌉]`. -/

theorem core_eq : core 3 16 1 5 true = DownMmaWide.core 3 16 1 5 true := rfl

variable (C : M1Max.Contract) {X Xs Cd S : ByteMemory.Bytes} {ax ash ac as : Nat}

theorem gpu_output (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 3 16 1 5)) (M : Nat) (hM : 2 ≤ M ∧ M ≤ 223)
    (hax : 2 ∣ ax) (hash : 4 ∣ ash) (hac : 4 ∣ ac) (has : 2 ∣ as) (hXs : word32 Xs 0 = M) :
    G.execute (text 3 16 1 5) (128, 80, ceilDiv M 8) (128, 1, 1)
      [⟨.device, 34816 * M, ax, X⟩, ⟨.constant, 8, ash, Xs⟩, ⟨.device, 33423360, ac, Cd⟩, ⟨.device, 34816, as, S⟩]
      [163840 * M] = some [DownMmaWide.expected C 3 true 16 1 M X Cd S] :=
  DownMmaWide.gpu_output_of C 3 16 1 5 true (.inr (.inr (.inr (.inr (.inr (.inr ⟨rfl, rfl, rfl, rfl, rfl⟩)))))) _
    (compile_eq.trans (by rw [core_eq])) G hmax M (by omega) (by omega) X Xs Cd S ax ash ac as hax hash hac has hXs

end Metal.Kernels.DownK3iMmaWide
