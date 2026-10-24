import metal.Elab
import metal.Frontend
import metal.Assemble
import host.mlx.PrefillKernelSources
import metal.kernels.DownPartial

namespace Metal.Kernels.DownMmaWide
open Metal Metal.Core

/-! # down-mma-wide.ts: `mlx_bun_trellis_down_mma_wide`

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
Launch (down-mma-wide.ts:147-176, `downMmaWidePass`): inputs `x` bfloat16 `[M, R]` (its `x_shape`
read), `codes` uint32 (row-major words), `scales` float16 `[R]`; output `partial` float32
`[M, SPLITS, C]`; `T` = bfloat16; template ints R, C, K, L, SPLITS, SG_TG, INTERLEAVE, MT, S, NW with
NW = ⌈(2·S·K + L − 1)/32⌉ + 1. The route's instances are the down projections of the layers with
row-major down codes (K 2 or 4) at R = 17408, C = 5120, L = 12, SPLITS = 8, SG_TG = 4,
INTERLEAVE = 0: `CodebookMmaDown`'s one block for 2..8 rows (`DOWN_ONE_BLOCK`, S 16, MT 1) and
`plan("rowMajor", M)` for more rows (S 8, MT 2 or 3), so (S, MT) ∈ {(16, 1), (8, 2), (8, 3)}. The
SIMD-group matrices `a` and `b` (declared without initializer) are thread arrays; `acc[s][bk]` is
`acc`'s element s·MT + bk. The core depends on K, S, MT, NW and whether INTERLEAVE is nonzero:
`core k s mt nw il`. -/

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

`x` `bfloat16 [M, 17408]` (any M), `codes` `uint32 [17408, 160·K]` (row-major words), `scales`
`float16 [17408]`; any shapes of at least 8 elements give the same text. -/

def inputs (k : Nat) : List Assemble.Input :=
  [⟨chars!"x", .bfloat16, [9, 17408]⟩, ⟨chars!"codes", .uint32, [17408, 160 * k]⟩, ⟨chars!"scales", .float16, [17408]⟩]

def args (k s mt nw : Nat) : List Assemble.TemplateArg :=
  [.dtype chars!"T" .bfloat16, .int chars!"R" 17408, .int chars!"C" 5120, .int chars!"K" k, .int chars!"L" 12,
    .int chars!"SPLITS" 8, .int chars!"SG_TG" 4, .int chars!"INTERLEAVE" 0, .int chars!"MT" mt, .int chars!"S" s,
    .int chars!"NW" nw]

def assembled (k s mt nw : Nat) : Option (List Char) :=
  Assemble.assemble (PrefillSources.name .downMmaWide) (inputs k) [chars!"partial"] [.float32]
    (PrefillSources.source .downMmaWide) (PrefillSources.header .downMmaWide) (args k s mt nw) false

def text (k s mt nw : Nat) : List Char := (assembled k s mt nw).getD []

/-- Every route instance assembles. -/
theorem assembled_route :
    (assembled 2 16 1 4).isSome ∧ (assembled 4 16 1 6).isSome ∧ (assembled 2 8 2 3).isSome ∧
    (assembled 4 8 2 4).isSome ∧ (assembled 2 8 3 3).isSome ∧ (assembled 4 8 3 4).isSome := by
  decide +kernel

kernel_rfl compile_2_16_1 : (frontend (text 2 16 1 4)).bind elaborate = some (core 2 16 1 4 false)
kernel_rfl compile_4_16_1 : (frontend (text 4 16 1 6)).bind elaborate = some (core 4 16 1 6 false)
kernel_rfl compile_2_8_2 : (frontend (text 2 8 2 3)).bind elaborate = some (core 2 8 2 3 false)
kernel_rfl compile_4_8_2 : (frontend (text 4 8 2 4)).bind elaborate = some (core 4 8 2 4 false)
kernel_rfl compile_2_8_3 : (frontend (text 2 8 3 3)).bind elaborate = some (core 2 8 3 3 false)
kernel_rfl compile_4_8_3 : (frontend (text 4 8 3 4)).bind elaborate = some (core 4 8 3 4 false)

end Texts
end Metal.Kernels.DownMmaWide

set_option linter.constructorNameAsVariable false

namespace Metal.Kernels.DownWideRun
open Metal Metal.Core Inference.Contracts.Mlx

section Trellis
open Metal.Kernels.Trellis

/-- A state window of a block from its words loaded at `w0 = ⌊p0·K / 32⌋` (wrapping at the block's end), moved
down `p0·K mod 32` bits: the block's state at position `p0 + t`. -/
theorem state_window {K : Nat} (B : ByteMemory.Bytes) (base p0 t nw : Nat)
    (h1 : p0 * K % 32 + t * K + 12 ≤ 32 * (nw + 1)) (h2 : K * (p0 + t) + 12 ≤ 32 * (8 * K + 1)) :
    runBits (fun i => word32 B (base + (p0 * K / 32 + i) % (8 * K))) (nw + 1) / 2 ^ (p0 * K % 32 + t * K) % 2 ^ 12 =
      blockBits K B base / 2 ^ (K * (p0 + t)) % 2 ^ 12 := by
  let W : Nat → Nat := fun i => word32 B (base + i % (8 * K))
  have hW : ∀ N, ∀ i < N, W i < 2 ^ 32 := fun _ _ _ => word32_lt B _
  have hs := runBits_slice (hW (p0 * K / 32 + (nw + 1))) (p0 * K / 32) (nw + 1) le_rfl
  have e : (fun i => word32 B (base + (p0 * K / 32 + i) % (8 * K))) = fun i => W (p0 * K / 32 + i) := rfl
  rw [e, ← hs, window_mod _ _ _ h1, Nat.div_div_eq_div_mul, ← Nat.pow_add,
    show 32 * (p0 * K / 32) + (p0 * K % 32 + t * K) = K * (p0 + t) by
      rw [Nat.mul_add, Nat.mul_comm K p0, Nat.mul_comm K t]; omega]
  have hk : K * (p0 + t) = p0 * K + t * K := by ring
  unfold blockBits
  rw [runBits_window_ext (hW (p0 * K / 32 + (nw + 1) + (8 * K + 1))) (by omega) (by omega),
    runBits_window_ext (N := 8 * K + 1) (hW (p0 * K / 32 + (nw + 1) + (8 * K + 1))) (by omega) h2]

end Trellis

end Metal.Kernels.DownWideRun

namespace Metal.Kernels.DownMmaWide
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis

/-! ## Expected outputs

The quantities of the source on the inputs' elements, with the operations the core applies. The kernel has no
contraction sites (no product feeds an addition; the accumulation is the SIMD-group multiply-accumulate), so the
compiler's fusion choices do not enter. A SIMD-group's accumulators are its 32 lanes' registers of
`simdgroup_multiply_accumulate` (`C.simdMmaHalfB`, no layout assumed): each output element is a register of one
lane after the 272 row steps of its split. -/

section Spec
variable (C : M1Max.Contract)

def zero : Float32 := Val.ofF32Bits 0

/-- `TRELLIS_RCP`, `1.0f / 147.800537109375f`, folded to the word `0x3BDDB447`. -/
def rcp : Float32 := Val.ofF32Bits 0x3BDDB447

/-- `codebook[e] = half(trellis_y_f32(e))`: the float of the word `0x4b000000 | (trellis_y(e) + 510)`, less
`8389118.0f` (the word `0x4B0001FE`), rounded to half. -/
def cbHalf (e : Nat) : Float16.Value :=
  C.narrowHalf (C.fadd (Val.ofF32Bits (0x4B000000 ||| (trellisYv e + 510).toNat)) (f32Neg (Val.ofF32Bits 0x4B0001FE)))

/-- `float(x[row][c])`, `x` bfloat16 `[M, 17408]`. -/
def xval (X : ByteMemory.Bytes) (row c : Nat) : Float32 := C.widen (Val.ofBf16Bits (half X (17408 * row + c)))

/-- `float(scales[c]) * TRELLIS_RCP`. -/
def sval (S : ByteMemory.Bytes) (c : Nat) : Float32 := C.fmul (scale S c) rcp

/-- MLX's fragment coordinates of lane `l`: `fm = ((l / 4) & 4) + ((l / 2) % 4)`, `fn = ((l / 4) & 2)·2 + (l % 2)·2`. -/
def fmOf (l : Nat) : Nat := 4 * (l / 16) + l / 2 % 4
def fnOf (l : Nat) : Nat := 4 * (l / 8 % 2) + 2 * (l % 2)

/-- A SIMD-group's work: input rows `2176·split …` (its split), code block `block`, positions `8·S·q …` of the
block, activation rows `mBase …`. -/
structure Tile where
  split : Nat
  block : Nat
  q : Nat
  mBase : Nat

/-- Lane `l`'s first position in the block: `p0 = pg + S·fn`, `pg = 8·S·q`. -/
def p0Of (s : Nat) (T : Tile) (l : Nat) : Nat := 8 * s * T.q + s * fnOf l

/-- `a[bk].thread_elements()[j]` of lane `l` at row step `n` (`r = 2176·split + 8n`, `ra = r + fn`):
`float(xm[bk][ra + j]) * (float(scales[ra + j]) * TRELLIS_RCP)`, the activation row `mBase + 8·bk + fm` clamped
to `M - 1`. -/
def aReg (M : Nat) (X S : ByteMemory.Bytes) (T : Tile) (n bk : Nat) (l : Fin 32) (j : Fin 2) : Float32 :=
  C.fmul (xval C X (min (T.mBase + 8 * bk + fmOf l) (M - 1)) (2176 * T.split + 8 * n + fnOf l + j))
    (sval C S (2176 * T.split + 8 * n + fnOf l + j))

/-- `b.thread_elements()[j]` of lane `l` for sub-tile `st` at row step `n`: the codebook entry of the trellis state
of position `p0 + st + S·j` of block `block` in code row `r + fm` (block column `255 - position`). -/
def bReg (K : Nat) (il : Bool) (s : Nat) (Cd : ByteMemory.Bytes) (T : Tile) (n st : Nat) (l : Fin 32) (j : Fin 2) :
    Float16.Value :=
  cbHalf C (trellisCode K Cd (DownPartial.dbase K il (2176 * T.split + 8 * n + fmOf l) T.block)
    (255 - (p0Of s T l + st + s * j)))

/-- The lanes' registers of `acc[st][bk]` after `n` row steps: zero, then one multiply-accumulate per step. -/
def accReg (K : Nat) (il : Bool) (s M : Nat) (X Cd S : ByteMemory.Bytes) (T : Tile) (st bk : Nat) :
    Nat → Fin 32 → Fin 2 → Float32
  | 0 => fun _ _ => zero
  | n + 1 => C.simdMmaHalfB (aReg C M X S T n bk) (bReg C K il s Cd T n st) (accReg K il s M X Cd S T st bk n)

/-- The lane of fragment row `fm` and column pair `fn2` (`fn = 2·fn2`). -/
def laneOf (fm fn2 : Nat) : Nat := 16 * (fm / 4) + 8 * (fn2 / 2) + 4 * (fm / 2 % 2) + 2 * (fm % 2) + fn2 % 2

/-- `partial` element `E = (m·8 + split)·5120 + col` (`m = E / 40960`): its SIMD-group's tile, its position
`255 - col % 256` in the block less `8·S·q`, its block of 8 rows, sub-tile, lane and register. -/
def eTile (s mt E : Nat) : Tile :=
  ⟨E / 5120 % 8, E % 5120 / 256, (255 - E % 256) / (8 * s), 8 * mt * (E / 40960 / (8 * mt))⟩
def ePos (s E : Nat) : Nat := (255 - E % 256) % (8 * s)
def eBk (mt E : Nat) : Nat := E / 40960 % (8 * mt) / 8
def eSt (s E : Nat) : Nat := ePos s E % (2 * s) % s
def eLane (s E : Nat) : Fin 32 := ⟨laneOf (E / 40960 % 8) (ePos s E / (2 * s)) % 32, Nat.mod_lt _ (by decide)⟩
def eReg (s E : Nat) : Fin 2 := ⟨ePos s E % (2 * s) / s % 2, Nat.mod_lt _ (by decide)⟩

/-- `partial` element `E`: `acc[st][bk].thread_elements()[j]` of its lane after the split's 272 row steps. -/
def outVal (K : Nat) (il : Bool) (s mt M : Nat) (X Cd S : ByteMemory.Bytes) (E : Nat) : Float32 :=
  accReg C K il s M X Cd S (eTile s mt E) (eSt s E) (eBk mt E) 272 (eLane s E) (eReg s E)

/-- Byte `b` of `partial` `[M, 8, 5120]` float32. -/
def expected (K : Nat) (il : Bool) (s mt M : Nat) (X Cd S : ByteMemory.Bytes) (b : Nat) : BitVec 8 :=
  if b < 163840 * M then (wordBytes 4 (Val.f32Bits (outVal C K il s mt M X Cd S (b / 4)))).getD (b % 4) 0 else 0

end Spec

/-! ## The launch -/

/-- The route's instances: row-major 2- and 4-bit codes at (S, MT) ∈ {(16, 1), (8, 2), (8, 3)}, and interleaved
3-bit codes at (16, 1), each with its `NW`. -/
def Geo (k s mt nw : Nat) (il : Bool) : Prop :=
  (k = 2 ∧ s = 16 ∧ mt = 1 ∧ nw = 4 ∧ il = false) ∨ (k = 4 ∧ s = 16 ∧ mt = 1 ∧ nw = 6 ∧ il = false) ∨
  (k = 2 ∧ s = 8 ∧ mt = 2 ∧ nw = 3 ∧ il = false) ∨ (k = 4 ∧ s = 8 ∧ mt = 2 ∧ nw = 4 ∧ il = false) ∨
  (k = 2 ∧ s = 8 ∧ mt = 3 ∧ nw = 3 ∧ il = false) ∨ (k = 4 ∧ s = 8 ∧ mt = 3 ∧ nw = 4 ∧ il = false) ∨
  (k = 3 ∧ s = 16 ∧ mt = 1 ∧ nw = 5 ∧ il = true)

/-- `nGroups = (C / 256)·(32 / S)`; the grid's threadgroups along y, `⌈8·nGroups / 4⌉`. -/
def nGOf (s : Nat) : Nat := 20 * (32 / s)
def gyOf (s : Nat) : Nat := 2 * nGOf s

/-- Bytes of `K`-bit codes: `uint32 [17408, 160·K]`, or `[10, 17408, 48]` at `K = 3`. -/
def codesBytes (k : Nat) : Nat := 17408 * 640 * k

/-- The inputs: `x` (bfloat16 `[M, 17408]`), its `x_shape`, the codes and scales, and their base alignments. -/
structure In where
  X : ByteMemory.Bytes
  Xs : ByteMemory.Bytes
  Cd : ByteMemory.Bytes
  S : ByteMemory.Bytes
  ax : Nat
  ash : Nat
  ac : Nat
  as : Nat

def bufs (k M : Nat) (I : In) : List Buffer :=
  [⟨.device, 34816 * M, I.ax, I.X⟩, ⟨.constant, 8, I.ash, I.Xs⟩, ⟨.device, codesBytes k, I.ac, I.Cd⟩,
    ⟨.device, 34816, I.as, I.S⟩]

/-- MLX's launch: grid `[128, 2·nGroups, ⌈M / (8·MT)⌉]`, threadgroup `[128, 1, 1]`, `partial` `[M, 8, 5120]` f32. -/
def launch (k s mt nw : Nat) (il : Bool) (M : Nat) (I : In) (initial : Nat → ByteMemory.Bytes) : Launch :=
  ⟨core k s mt nw il, (128, gyOf s, ceilDiv M (8 * mt)), (128, 1, 1), buffers (bufs k M I) [163840 * M] 16 initial⟩

end Metal.Kernels.DownMmaWide

namespace Metal.Kernels.DownWideRun
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis
open Metal.Kernels.DownMmaWide (Tile p0Of fmOf fnOf laneOf eTile ePos eBk eSt eLane eReg outVal expected aReg bReg accReg
  cbHalf xval sval zero rcp Geo nGOf gyOf codesBytes In bufs)

/-! ## The launch's structure -/

/-- The kernel's parameters and the row count. -/
structure Par where
  k : Nat
  s : Nat
  mt : Nat
  nw : Nat
  il : Bool
  M : Nat

/-- The grid's threadgroups along z. -/
def Par.gz (p : Par) : Nat := ceilDiv p.M (8 * p.mt)

/-- The parameters the proof covers: a route instance and `1 ≤ M < 2^24`. -/
structure Par.Ok (p : Par) : Prop where
  geo : Geo p.k p.s p.mt p.nw p.il
  m1 : 1 ≤ p.M
  m2 : p.M < 2 ^ 24

theorem Par.Ok.sm {p : Par} (h : p.Ok) : (p.s = 16 ∧ p.mt = 1) ∨ (p.s = 8 ∧ p.mt = 2) ∨ (p.s = 8 ∧ p.mt = 3) := by
  rcases h.geo with ⟨-, h1, h2, -⟩ | ⟨-, h1, h2, -⟩ | ⟨-, h1, h2, -⟩ | ⟨-, h1, h2, -⟩ | ⟨-, h1, h2, -⟩ |
    ⟨-, h1, h2, -⟩ | ⟨-, h1, h2, -⟩ <;> simp [h1, h2]

theorem Par.Ok.k {p : Par} (h : p.Ok) : 2 ≤ p.k ∧ p.k ≤ 4 := by
  rcases h.geo with ⟨h1, -⟩ | ⟨h1, -⟩ | ⟨h1, -⟩ | ⟨h1, -⟩ | ⟨h1, -⟩ | ⟨h1, -⟩ | ⟨h1, -⟩ <;> omega

theorem Par.Ok.nw {p : Par} (h : p.Ok) : 3 ≤ p.nw ∧ p.nw ≤ 6 ∧ (2 * p.s - 1) * p.k + 16 < 32 * p.nw := by
  rcases h.geo with ⟨h1, h2, -, h4, -⟩ | ⟨h1, h2, -, h4, -⟩ | ⟨h1, h2, -, h4, -⟩ | ⟨h1, h2, -, h4, -⟩ |
    ⟨h1, h2, -, h4, -⟩ | ⟨h1, h2, -, h4, -⟩ | ⟨h1, h2, -, h4, -⟩ <;> rw [h1, h2, h4] <;> omega

theorem Par.Ok.gz {p : Par} (h : p.Ok) : 0 < p.gz := by
  have := h.m1
  unfold Par.gz ceilDiv
  exact Nat.div_pos (by omega) (by rcases h.sm with ⟨-, h2⟩ | ⟨-, h2⟩ | ⟨-, h2⟩ <;> omega)

/-- Thread array `j` of thread `th`. -/
def ta (th j : Nat) : Nat := 6 + th * 8 + j

/-- Thread `32·sg + i` of threadgroup `(0, y, z)`. -/
def thOf (s y z sg i : Nat) : Nat := (y + z * gyOf s) * 128 + (32 * sg + i)

/-- SIMD-group `sg` of threadgroup `(0, y, z)`: `id = 4y + sg`, `split = id / nGroups`, `cg = id % nGroups`,
`block = cg / groupsPerBlock`, `q = cg % groupsPerBlock`, `mBase = 8·MT·z`. -/
def tileOf (s mt y z sg : Nat) : Tile :=
  ⟨(4 * y + sg) / nGOf s, (4 * y + sg) % nGOf s / (32 / s), (4 * y + sg) % nGOf s % (32 / s), 8 * mt * z⟩

/-! ### Who writes what -/

/-- The SIMD-group, threadgroup and thread of `partial` element `E`. -/
def eId (s E : Nat) : Nat := E / 5120 % 8 * nGOf s + E % 5120 / 256 * (32 / s) + (255 - E % 256) / (8 * s)
def eZ (mt E : Nat) : Nat := E / 40960 / (8 * mt)
def eGroup (s mt E : Nat) : Nat := eId s E / 4 + eZ mt E * gyOf s
def eThread (s mt E : Nat) : Nat := eGroup s mt E * 128 + (32 * (eId s E % 4) + (eLane s E).val)

/-- The writer of each device byte: `partial` element `E` by its thread, in device epoch 0. -/
def dev (s mt : Nat) (region byte : Nat) : Option Writer :=
  if region = 4 then some ⟨eThread s mt (byte / 4), eGroup s mt (byte / 4), 0⟩ else none

/-- The owner of each threadgroup byte: in threadgroup `g`'s first epoch (`g`) codebook entry `e` is thread
`e % 128`'s; in its second nothing is written. -/
def tgo (g e region byte : Nat) : Option Nat :=
  if region = 5 ∧ e = g then some (g * 128 + byte / 2 % 128) else none

theorem lane_fm_fn : ∀ i < 32, laneOf (fmOf i) (fnOf i / 2) = i ∧ fmOf i < 8 ∧ fnOf i % 2 = 0 ∧ fnOf i ≤ 6 := by
  decide

theorem fm_fn_code : ∀ i < 32, (i / 4 &&& 4) + i / 2 % 4 = fmOf i ∧ (i / 4 &&& 2) * 2 + i % 2 * 2 = fnOf i := by
  decide

/-- The element lane `i` of SIMD-group `sg` of threadgroup `(0, y, z)` stores for `acc[st][bk]`'s register `e`. -/
def elemOf (s mt y z sg i bk st e : Nat) : Nat :=
  ((8 * mt * z + 8 * bk + fmOf i) * 8 + (tileOf s mt y z sg).split) * 5120 + (tileOf s mt y z sg).block * 256 + 255 -
    p0Of s (tileOf s mt y z sg) i - (st + s * e)

theorem div256 (b x : Nat) (h : x < 256) : (b * 256 + x) / 256 = b := by omega

theorem elem_fwd {s mt : Nat} (hsm : (s = 16 ∧ mt = 1) ∨ (s = 8 ∧ mt = 2) ∨ (s = 8 ∧ mt = 3)) {y z sg i bk st e : Nat}
    (hy : y < gyOf s) (hsg : sg < 4) (hi : i < 32) (hbk : bk < mt) (hst : st < s) (he : e < 2) :
    eTile s mt (elemOf s mt y z sg i bk st e) = tileOf s mt y z sg ∧ eBk mt (elemOf s mt y z sg i bk st e) = bk ∧
      eSt s (elemOf s mt y z sg i bk st e) = st ∧ (eLane s (elemOf s mt y z sg i bk st e)).val = i ∧
      (eReg s (elemOf s mt y z sg i bk st e)).val = e ∧
      eThread s mt (elemOf s mt y z sg i bk st e) = thOf s y z sg i ∧
      eGroup s mt (elemOf s mt y z sg i bk st e) = y + z * gyOf s ∧
      elemOf s mt y z sg i bk st e / 40960 = 8 * mt * z + 8 * bk + fmOf i := by
  obtain ⟨hl, hfm, hfn2, hfn6⟩ := lane_fm_fn i hi
  generalize hF : fmOf i = F at *
  generalize hN : fnOf i = N at *
  obtain ⟨n2, rfl⟩ : ∃ n2, N = 2 * n2 := ⟨N / 2, by omega⟩
  rw [show 2 * n2 / 2 = n2 by omega] at hl
  have hsplit : (tileOf s mt y z sg).split < 8 := by
    simp only [tileOf, gyOf, nGOf] at *; rcases hsm with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> omega
  have hblock : (tileOf s mt y z sg).block < 20 := by
    simp only [tileOf, gyOf, nGOf] at *; rcases hsm with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> omega
  have hpos : p0Of s (tileOf s mt y z sg) i + (st + s * e) ≤ 255 ∧
      (p0Of s (tileOf s mt y z sg) i + (st + s * e)) / (8 * s) = (tileOf s mt y z sg).q ∧
      (p0Of s (tileOf s mt y z sg) i + (st + s * e)) % (8 * s) = 2 * s * n2 + (st + s * e) := by
    simp only [p0Of, tileOf, gyOf, nGOf] at *; rw [hN]
    rcases hsm with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> omega
  generalize hT : tileOf s mt y z sg = T at *
  generalize hP : p0Of s T i + (st + s * e) = P at hpos
  have hE : elemOf s mt y z sg i bk st e = ((8 * mt * z + 8 * bk + F) * 8 + T.split) * 5120 + (T.block * 256 + (255 - P)) := by
    unfold elemOf; rw [hT, hF, ← hP]; omega
  rw [hE]
  generalize hm : 8 * mt * z + 8 * bk + F = m
  have hm' : m = 8 * (mt * z) + 8 * bk + F := by rw [← hm]; ring
  have e1 : (((m * 8 + T.split) * 5120 + (T.block * 256 + (255 - P))) / 5120) = m * 8 + T.split := by omega
  have e2 : (((m * 8 + T.split) * 5120 + (T.block * 256 + (255 - P))) % 5120) = T.block * 256 + (255 - P) := by omega
  have e3 : (((m * 8 + T.split) * 5120 + (T.block * 256 + (255 - P))) % 256) = 255 - P := by omega
  have e4 : (((m * 8 + T.split) * 5120 + (T.block * 256 + (255 - P))) / 40960) = m := by omega
  have hm8 : m % 8 = F := by omega
  have hmz : m / (8 * mt) = z ∧ m % (8 * mt) / 8 = bk := by
    rw [← hm]; rcases hsm with ⟨-, rfl⟩ | ⟨-, rfl⟩ | ⟨-, rfl⟩ <;> omega
  have hq : T.q = (4 * y + sg) % nGOf s % (32 / s) ∧ T.block = (4 * y + sg) % nGOf s / (32 / s) ∧
      T.split = (4 * y + sg) / nGOf s ∧ T.mBase = 8 * mt * z := by rw [← hT]; exact ⟨rfl, rfl, rfl, rfl⟩
  have hid : (m * 8 + T.split) % 8 * nGOf s + (T.block * 256 + (255 - P)) / 256 * (32 / s) + (255 - (255 - P)) / (8 * s) =
      4 * y + sg := by
    rw [hq.2.1, hq.2.2.1, show 255 - (255 - P) = P by omega, hpos.2.1, hq.1]
    simp only [gyOf, nGOf] at *; rcases hsm with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> omega
  have hlane : laneOf F ((255 - (255 - P)) % (8 * s) / (2 * s)) % 32 = i := by
    rw [show 255 - (255 - P) = P by omega, hpos.2.2]
    have : (2 * s * n2 + (st + s * e)) / (2 * s) = n2 := by
      rcases hsm with ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ <;> omega
    rw [this, hl]; omega
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, e4⟩
  · have : eTile s mt ((m * 8 + T.split) * 5120 + (T.block * 256 + (255 - P))) = ⟨T.split, T.block, T.q, T.mBase⟩ := by
      unfold eTile
      rw [e1, e2, e3, e4, Tile.mk.injEq]
      refine ⟨?_, ?_, ?_, ?_⟩
      · omega
      · exact div256 _ _ (by omega)
      · rw [show 255 - (255 - P) = P by omega]; exact hpos.2.1
      · rw [hmz.1, hq.2.2.2]
    rw [this]
  · unfold eBk; rw [e4, hmz.2]
  · unfold eSt ePos; rw [e3, show 255 - (255 - P) = P by omega, hpos.2.2]
    rcases hsm with ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ <;> omega
  · unfold eLane; simp only; rw [e4, hm8]; unfold ePos; rw [e3]; exact hlane
  · unfold eReg ePos; simp only; rw [e3, show 255 - (255 - P) = P by omega, hpos.2.2]
    rcases hsm with ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ <;> omega
  · unfold eThread eGroup eId eZ thOf; rw [e1, e2, e3, e4, hid, hmz.1]
    have hl' : (eLane s ((m * 8 + T.split) * 5120 + (T.block * 256 + (255 - P)))).val = i := by
      unfold eLane; simp only; rw [e4, hm8]; unfold ePos; rw [e3]; exact hlane
    rw [hl']
    unfold gyOf nGOf at hy; rcases hsm with ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ <;> simp only [gyOf, nGOf] at * <;> omega
  · unfold eGroup eId eZ; rw [e1, e2, e3, e4, hid, hmz.1]
    unfold gyOf nGOf at hy; rcases hsm with ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ <;> simp only [gyOf, nGOf] at * <;> omega

theorem fm_fn_lane : ∀ a < 8, ∀ b < 4, fmOf (laneOf a b) = a ∧ fnOf (laneOf a b) = 2 * b ∧ laneOf a b < 32 := by
  decide


theorem radix_eq {a b c d G : Nat} (ha : a < G) (hc : c < G) (h : a + b * G = c + d * G) : a = c ∧ b = d := by
  have h1 : (a + b * G) / G = b := by rw [Nat.add_mul_div_right _ _ (by omega), Nat.div_eq_of_lt ha, Nat.zero_add]
  have h2 : (c + d * G) / G = d := by rw [Nat.add_mul_div_right _ _ (by omega), Nat.div_eq_of_lt hc, Nat.zero_add]
  have hbd : b = d := by rw [← h1, ← h2, h]
  subst hbd; omega

theorem radix3 (A Bk Q g : Nat) (hg : 0 < g) (hBk : Bk < 20) (hQ : Q < g) :
    (A * (20 * g) + Bk * g + Q) / (20 * g) = A ∧ (A * (20 * g) + Bk * g + Q) % (20 * g) / g = Bk ∧
      (A * (20 * g) + Bk * g + Q) % (20 * g) % g = Q := by
  have hX : Bk * g + Q < 20 * g := by nlinarith
  have e1 : A * (20 * g) + Bk * g + Q = Bk * g + Q + 20 * g * A := by ring
  have hmod : (A * (20 * g) + Bk * g + Q) % (20 * g) = Bk * g + Q := by
    rw [e1, Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt hX]
  refine ⟨?_, ?_, ?_⟩
  · rw [e1, Nat.add_mul_div_left _ _ (by omega), Nat.div_eq_of_lt hX, Nat.zero_add]
  · rw [hmod, Nat.add_comm, Nat.add_mul_div_right _ _ hg, Nat.div_eq_of_lt hQ, Nat.zero_add]
  · rw [hmod, Nat.add_comm, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hQ]

/-- Every `partial` element is its writer's `elemOf`. -/
theorem elem_inv {s mt : Nat} (hsm : (s = 16 ∧ mt = 1) ∨ (s = 8 ∧ mt = 2) ∨ (s = 8 ∧ mt = 3)) {E y z sg i : Nat}
    (hy : y < gyOf s) (hsg : sg < 4) (hi : i < 32) (hE : eThread s mt E = thOf s y z sg i) :
    E = elemOf s mt y z sg i (eBk mt E) (eSt s E) (eReg s E).val ∧ E / 40960 = 8 * mt * z + 8 * eBk mt E + fmOf i := by
  have hs0 : 0 < s := by rcases hsm with ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ <;> decide
  have hg0 : 0 < 32 / s ∧ 32 / s * s = 32 := by rcases hsm with ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ <;> decide
  -- the writer's coordinates
  generalize hP : 255 - E % 256 = P
  have hPl : P ≤ 255 := by omega
  generalize hW : P % (8 * s) = W
  generalize hQ : P / (8 * s) = Q
  generalize hW2 : W % (2 * s) = W2
  generalize hF2 : W / (2 * s) = F2
  have hF2l : F2 < 4 := by rw [← hF2, ← hW]; rcases hsm with ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ <;> omega
  have hQl : Q < 32 / s := by rw [← hQ]; rcases hsm with ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ <;> omega
  have hlane : (eLane s E).val = laneOf (E / 40960 % 8) F2 := by
    have := (fm_fn_lane (E / 40960 % 8) (by omega) F2 hF2l).2.2
    unfold eLane ePos; simp only; rw [hP, hW, hF2]; omega
  have hlt : 32 * (eId s E % 4) + (eLane s E).val < 128 := by have := (eLane s E).isLt; omega
  have h1 : eGroup s mt E = y + z * gyOf s ∧ 32 * (eId s E % 4) + (eLane s E).val = 32 * sg + i := by
    unfold eThread thOf at hE; omega
  have h2 : eId s E % 4 = sg ∧ (eLane s E).val = i := by omega
  have hid : eId s E / 4 < gyOf s := by
    unfold eId gyOf nGOf; rw [hP]; rcases hsm with ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ <;> omega
  have h3 := radix_eq hid hy h1.1
  obtain ⟨hfm, hfn, -⟩ := fm_fn_lane (E / 40960 % 8) (by omega) F2 hF2l
  rw [← hlane, h2.2] at hfm hfn
  have hrow : E / 40960 = 8 * mt * z + 8 * eBk mt E + fmOf i := by
    have hz := h3.2
    unfold eZ at hz
    rw [hfm, ← hz]; unfold eBk
    rcases hsm with ⟨-, rfl⟩ | ⟨-, rfl⟩ | ⟨-, rfl⟩ <;> omega
  refine ⟨?_, hrow⟩
  have hidv : eId s E = 4 * y + sg := by omega
  have hid3 := radix3 (E / 5120 % 8) (E % 5120 / 256) Q (32 / s) hg0.1 (by omega) hQl
  have hide : eId s E = E / 5120 % 8 * (20 * (32 / s)) + E % 5120 / 256 * (32 / s) + Q := by
    unfold eId nGOf; rw [hP, hQ]
  rw [← hide, hidv] at hid3
  have hTs : (tileOf s mt y z sg).split = E / 5120 % 8 := hid3.1
  have hTb : (tileOf s mt y z sg).block = E % 5120 / 256 := hid3.2.1
  have hTq : (tileOf s mt y z sg).q = Q := hid3.2.2
  have hst : eSt s E = W2 % s := by unfold eSt ePos; rw [hP, hW, hW2]
  have hre : (eReg s E).val = W2 / s := by
    have : W2 < 2 * s := by rw [← hW2]; exact Nat.mod_lt _ (by omega)
    have : W2 / s < 2 := by rw [Nat.div_lt_iff_lt_mul hs0]; omega
    unfold eReg ePos; simp only; rw [hP, hW, hW2]; exact Nat.mod_eq_of_lt this
  have d1 : 8 * s * Q + W = P := by rw [← hQ, ← hW]; exact Nat.div_add_mod P (8 * s)
  have d2 : 2 * s * F2 + W2 = W := by rw [← hF2, ← hW2]; exact Nat.div_add_mod W (2 * s)
  have d3 : s * (W2 / s) + W2 % s = W2 := Nat.div_add_mod W2 s
  have hX : s * (2 * F2) = 2 * s * F2 := by ring
  unfold elemOf p0Of
  rw [← hrow, hTs, hTb, hTq, hfn, hst, hre, hX]
  generalize 8 * s * Q = X1 at d1 ⊢
  generalize 2 * s * F2 = X2 at d2 ⊢
  generalize W2 / s = E1 at d3 ⊢
  generalize s * E1 = X3 at d3 ⊢
  generalize W2 % s = E0 at d3 ⊢
  omega

end Metal.Kernels.DownWideRun

namespace Metal.Kernels.DownWideRun
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis
open Metal.Kernels.DownMmaWide (Tile p0Of fmOf fnOf laneOf eTile ePos eBk eSt eLane eReg outVal expected aReg bReg accReg
  cbHalf xval sval zero rcp Geo nGOf gyOf codesBytes In bufs)

def Par.launch (p : Par) (I : In) (initial : Nat → ByteMemory.Bytes) : Launch :=
  DownMmaWide.launch p.k p.s p.mt p.nw p.il p.M I initial

/-- The regions as the kernel uses them. -/
structure Shape (L : Launch) (p : Par) (I : In) : Prop where
  r0 : L.regions 0 = some ⟨.device, 34816 * p.M, I.ax⟩
  r1 : L.regions 1 = some ⟨.constant, 8, I.ash⟩
  r2 : L.regions 2 = some ⟨.device, codesBytes p.k, I.ac⟩
  r3 : L.regions 3 = some ⟨.device, 34816, I.as⟩
  r4 : L.regions 4 = some ⟨.device, 163840 * p.M, 16⟩
  r5 : L.regions 5 = some ⟨.threadgroup, 8192, 2⟩
  t0 : ∀ th, L.regions (ta th 0) = some ⟨.thread, 8 * p.mt, 8⟩
  t1 : ∀ th, L.regions (ta th 1) = some ⟨.thread, 8 * (p.s * p.mt), 8⟩
  t2 : ∀ th, L.regions (ta th 2) = some ⟨.thread, 4 * (p.nw + 1), 4⟩
  t3 : ∀ th, L.regions (ta th 3) = some ⟨.thread, 4 * (p.nw + 1), 4⟩
  t4 : ∀ th, L.regions (ta th 4) = some ⟨.thread, 4 * p.nw, 4⟩
  t5 : ∀ th, L.regions (ta th 5) = some ⟨.thread, 4 * p.nw, 4⟩
  t6 : ∀ th, L.regions (ta th 6) = some ⟨.thread, 8 * p.mt, 8⟩
  t7 : ∀ th, L.regions (ta th 7) = some ⟨.thread, 4, 4⟩
  ax : I.ax % 2 = 0
  ash : I.ash % 4 = 0
  ac : I.ac % 4 = 0
  as : I.as % 2 = 0

theorem launch_buffers (p : Par) (I : In) (initial : Nat → ByteMemory.Bytes) :
    (p.launch I initial).buffers = buffers (bufs p.k p.M I) [163840 * p.M] 16 initial := rfl

theorem launch_shape {p : Par} {I : In} {initial : Nat → ByteMemory.Bytes}
    (hax : I.ax % 2 = 0) (hash : I.ash % 4 = 0) (hac : I.ac % 4 = 0) (has : I.as % 2 = 0) :
    Shape (p.launch I initial) p I := by
  have hb := launch_buffers p I initial
  have ht : ∀ th j t n, (p.launch I initial).kernel.threadArrays[j]? = some (t, n) →
      (p.launch I initial).regions (ta th j) = some ⟨.thread, t.bytes * n, alignment t⟩ := fun th j t n h => by
    have := Launch.regions_threadArray _ th j t n h
    have e : (p.launch I initial).buffers.length + (p.launch I initial).groupArrays + th * (p.launch I initial).threadArrays + j =
        ta th j := by
      rw [hb, buffers_length]; simp [Launch.groupArrays, Launch.threadArrays, Par.launch, DownMmaWide.launch, DownMmaWide.core, bufs, ta]
    rwa [e] at this
  refine ⟨regions_input hb 0 (by simp [bufs]), regions_input hb 1 (by simp [bufs]), regions_input hb 2 (by simp [bufs]),
    regions_input hb 3 (by simp [bufs]), regions_output hb 0 (by simp), ?_, fun th => ?_, fun th => ?_, fun th => ?_,
    fun th => ?_, fun th => ?_, fun th => ?_, fun th => ?_, fun th => ?_, hax, hash, hac, has⟩
  · have := Launch.regions_groupArray (p.launch I initial) 0 (.scalar .f16) 4096 rfl
    rw [hb, buffers_length] at this
    simpa [bufs, Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 0 (.ptr .device (.scalar .bf16)) p.mt rfl; simpa [Ty.bytes, alignment, Nat.mul_comm] using this
  · have := ht th 1 (.vec .f32 2) (p.s * p.mt) rfl; simpa [Ty.bytes, Scalar.bytes, alignment, Nat.mul_comm] using this
  · have := ht th 2 (.scalar .u32) (p.nw + 1) rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 3 (.scalar .u32) (p.nw + 1) rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 4 (.scalar .u32) p.nw rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 5 (.scalar .u32) p.nw rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 6 (.vec .f32 2) p.mt rfl; simpa [Ty.bytes, Scalar.bytes, alignment, Nat.mul_comm] using this
  · have := ht th 7 (.vec .f16 2) 1 rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this

/-! ## Memory -/

section Memory
variable (C : M1Max.Contract)

/-- `partial` element `E`'s expected value. -/
def Par.outV (p : Par) (I : In) (E : Nat) : Float32 := outVal C p.k p.il p.s p.mt p.M I.X I.Cd I.S E

/-- Memory during the launch: inputs intact, the epochs, codebook entries `cbOk` in the threadgroup array, the
`partial` elements `outOk`, and every access so far keeping the ownership discipline. -/
structure Mem (p : Par) (L : Launch) (I : In) (ge : Nat) (cbOk outOk : Nat → Prop) (sh : Shared) : Prop where
  regions : sh.regions = L.regions
  x : sh.bytes 0 = I.X
  xs : sh.bytes 1 = I.Xs
  cd : sh.bytes 2 = I.Cd
  sc : sh.bytes 3 = I.S
  deve : sh.deviceEpoch = 0
  grpe : sh.groupEpoch = ge
  cb : ∀ e < 4096, cbOk e → cells (sh.bytes 5) (2 * e) 2 = wordBytes 2 (Val.f16Bits (cbHalf C e))
  out : ∀ E < 40960 * p.M, outOk E → cells (sh.bytes 4) (4 * E) 4 = wordBytes 4 (Val.f32Bits (p.outV C I E))
  log : ∀ a ∈ sh.log, Owned L (dev p.s p.mt) tgo a

variable {C} {p : Par} {L : Launch} {I : In} {ge : Nat} {cbOk outOk : Nat → Prop} {sh : Shared}

theorem Mem.mono (h : Mem C p L I ge cbOk outOk sh) {cbOk' outOk' : Nat → Prop} (hc : ∀ e < 4096, cbOk' e → cbOk e)
    (ho : ∀ E < 40960 * p.M, outOk' E → outOk E) : Mem C p L I ge cbOk' outOk' sh :=
  ⟨h.regions, h.x, h.xs, h.cd, h.sc, h.deve, h.grpe, fun e he h' => h.cb e he (hc e he h'),
    fun E hE h' => h.out E hE (ho E hE h'), h.log⟩

/-- A read of an input, or of the codebook in an epoch its threadgroup does not write it. -/
theorem Mem.rd (h : Mem C p L I ge cbOk outOk sh) (hS : Shape L p I) (ctx : Ctx) (reg o n : Nat)
    (hreg : reg < 4 ∨ (reg = 5 ∧ ge ≠ ctx.group)) : Mem C p L I ge cbOk outOk (rdn ctx sh reg o n) :=
  ⟨h.regions, h.x, h.xs, h.cd, h.sc, h.deve, h.grpe, h.cb, h.out, forall_log _ n _ (fun j _ => by
    rcases hreg with hreg | ⟨rfl, h1⟩
    · obtain ⟨r, hr, hs⟩ : ∃ r, L.regions reg = some r ∧ r.space ≠ .threadgroup := by
        rcases (show reg = 0 ∨ reg = 1 ∨ reg = 2 ∨ reg = 3 by omega) with rfl | rfl | rfl | rfl
        exacts [⟨_, hS.r0, by simp⟩, ⟨_, hS.r1, by simp⟩, ⟨_, hS.r2, by simp⟩, ⟨_, hS.r3, by simp⟩]
      exact owned_device_read L _ tgo ctx sh reg (o + j) r hr hs (by simp [dev]; omega)
    · exact owned_group_read L _ tgo ctx sh 5 (o + j) _ hS.r5 rfl (by simp [tgo, h.grpe]; omega)) h.log⟩

/-- A write to thread memory. -/
theorem Mem.tput (h : Mem C p L I ge cbOk outOk sh) {reg : Nat} (o : Nat) (bs : List (BitVec 8)) (hreg : 6 ≤ reg) :
    Mem C p L I ge cbOk outOk (tput sh reg o bs) :=
  ⟨h.regions, by rw [tput_other _ _ _ (by omega)]; exact h.x, by rw [tput_other _ _ _ (by omega)]; exact h.xs,
    by rw [tput_other _ _ _ (by omega)]; exact h.cd, by rw [tput_other _ _ _ (by omega)]; exact h.sc, h.deve, h.grpe,
    fun e he hc => by rw [tput_other _ _ _ (by omega)]; exact h.cb e he hc,
    fun E hE hc => by rw [tput_other _ _ _ (by omega)]; exact h.out E hE hc, h.log⟩

/-- Thread `e % 128` of threadgroup `g` writes `codebook[e]` in its first epoch. -/
theorem Mem.wcb {g : Nat} (h : Mem C p L I g cbOk outOk sh) (hS : Shape L p I) (ctx : Ctx) (e : Nat) (he : e < 4096)
    (ht : ctx.thread = g * 128 + e % 128) (hg : ctx.group = g) :
    Mem C p L I g (fun e' => cbOk e' ∨ e' = e) outOk
      (wrn ctx sh 5 (2 * e) 2 (wordBytes 2 (Val.f16Bits (cbHalf C e)))) := by
  have hl : (wordBytes 2 (Val.f16Bits (cbHalf C e))).length = 2 := wordBytes_length 2 _
  refine ⟨h.regions, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.x, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.xs,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.cd, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.sc, h.deve, h.grpe,
    fun e' he' hc => ?_, fun E hE hc => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.out E hE hc,
    forall_log _ 2 _ (fun j hj => owned_group L _ tgo ctx sh 5 (2 * e + j) _ hS.r5 true rfl
      (by simp only [tgo, h.grpe, hg, and_self, ite_true]; rw [ht]; congr 2; omega)) h.log⟩
  rw [wrn_same]
  by_cases hee : e' = e
  · subst hee
    have := cells_writeBytes_same (sh.bytes 5) (2 * e') (wordBytes 2 (Val.f16Bits (cbHalf C e')))
    rwa [hl] at this
  · rw [cells_writeBytes_other _ _ _ _ _ (by rw [hl]; omega)]
    exact h.cb e' he' (hc.resolve_right hee)

/-- `partial` element `E`'s writer stores it. -/
theorem Mem.wout (h : Mem C p L I ge cbOk outOk sh) (hS : Shape L p I) (ctx : Ctx) (E : Nat) (hE : E < 40960 * p.M)
    (ht : ctx.thread = eThread p.s p.mt E) (hg : ctx.group = eGroup p.s p.mt E) :
    Mem C p L I ge cbOk (fun E' => outOk E' ∨ E' = E)
      (wrn ctx sh 4 (4 * E) 4 (wordBytes 4 (Val.f32Bits (p.outV C I E)))) := by
  have hl : (wordBytes 4 (Val.f32Bits (p.outV C I E))).length = 4 := wordBytes_length 4 _
  refine ⟨h.regions, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.x, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.xs,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.cd, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.sc, h.deve, h.grpe,
    fun e he hc => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.cb e he hc, fun E' hE' hc => ?_,
    forall_log _ 4 _ (fun j hj => owned_device L _ tgo ctx sh 4 (4 * E + j) _ hS.r4 true (by simp)
      ⟨eThread p.s p.mt E, eGroup p.s p.mt E, 0⟩
      (by simp only [dev, ite_true]; rw [show (4 * E + j) / 4 = E by omega]) ht hg (by rw [h.deve])) h.log⟩
  rw [wrn_same]
  by_cases hee : E' = E
  · subst hee
    have := cells_writeBytes_same (sh.bytes 4) (4 * E') (wordBytes 4 (Val.f32Bits (p.outV C I E')))
    rwa [hl] at this
  · rw [cells_writeBytes_other _ _ _ _ _ (by rw [hl]; omega)]
    exact h.out E' hE' (hc.resolve_right hee)

/-- The barrier (threadgroup memory only). -/
theorem Mem.pass (h : Mem C p L I ge cbOk outOk sh) : Mem C p L I (ge + 1) cbOk outOk (pass false true sh) :=
  ⟨h.regions, h.x, h.xs, h.cd, h.sc, by simp [Metal.pass, h.deve], by simp [Metal.pass, h.grpe], h.cb, h.out, h.log⟩

/-- A threadgroup starts: its threadgroup array holds garbage. -/
theorem Mem.reset (h : Mem C p L I ge cbOk outOk sh) (hb : L.buffers.length = 5) (garbage : Garbage) (g : Nat) :
    Mem C p L I ge (fun _ => False) outOk { sh with bytes := L.resetGroup garbage g sh.bytes } :=
  ⟨h.regions, by show L.resetGroup garbage g sh.bytes 0 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.x,
    by show L.resetGroup garbage g sh.bytes 1 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.xs,
    by show L.resetGroup garbage g sh.bytes 2 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.cd,
    by show L.resetGroup garbage g sh.bytes 3 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.sc,
    h.deve, h.grpe, fun _ _ hf => hf.elim,
    fun E hE hc => by
      show cells (L.resetGroup garbage g sh.bytes 4) (4 * E) 4 = _
      rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.out E hE hc, h.log⟩

end Memory

/-! ### A lane's own memory -/

/-- `sh` keeps `sh0`'s bytes outside thread `th`'s arrays and `partial`. -/
def Keep (th : Nat) (sh0 sh : Shared) : Prop :=
  ∀ R, (R < ta th 0 ∨ ta th 8 ≤ R) → R ≠ 4 → sh.bytes R = sh0.bytes R

theorem Keep.refl (th : Nat) (sh : Shared) : Keep th sh sh := fun _ _ _ => rfl

theorem Keep.trans {th : Nat} {a b c : Shared} (h1 : Keep th a b) (h2 : Keep th b c) : Keep th a c :=
  fun R h h' => (h2 R h h').trans (h1 R h h')

theorem Keep.rdn {th : Nat} {a b : Shared} (h : Keep th a b) (ctx : Ctx) (reg o n : Nat) :
    Keep th a (rdn ctx b reg o n) := h

theorem Keep.tput {th : Nat} {a b : Shared} (h : Keep th a b) {reg : Nat} (hreg : ta th 0 ≤ reg ∧ reg < ta th 8)
    (o : Nat) (bs : List (BitVec 8)) : Keep th a (tput b reg o bs) := fun R hR h4 => by
  rw [tput_other _ _ _ (by omega)]; exact h R hR h4

theorem Keep.wrn4 {th : Nat} {a b : Shared} (h : Keep th a b) (ctx : Ctx) (o n : Nat) (bs : List (BitVec 8)) :
    Keep th a (wrn ctx b 4 o n bs) := fun R hR h4 => by
  rw [wrn_other _ _ _ _ _ h4]; exact h R hR h4

/-! ## A thread -/

/-- Lane `i` of SIMD-group `sg` of threadgroup `(0, y, z)`. -/
structure Lane (p : Par) (ctx : Ctx) (y z sg i : Nat) : Prop where
  gpos : ctx.coord .threadgroupPositionInGrid = u32x3 0 y z
  lane : ctx.coord .threadIndexInSimdgroup = u32 i
  sgc : ctx.coord .simdgroupIndexInThreadgroup = u32 sg
  thread : ctx.thread = thOf p.s y z sg i
  group : ctx.group = y + z * gyOf p.s
  ga0 : ctx.groupArray 0 = 5
  ta : ∀ j, ctx.threadArray j = ta (thOf p.s y z sg i) j
  hy : y < gyOf p.s
  hz : z < p.gz
  hsg : sg < 4
  hi : i < 32

theorem gyOf_pos {p : Par} (hp : p.Ok) : 0 < gyOf p.s := by
  unfold gyOf nGOf; rcases hp.sm with ⟨h, -⟩ | ⟨h, -⟩ | ⟨h, -⟩ <;> rw [h] <;> decide

theorem launch_tiles {p : Par} (hp : p.Ok) {I : In} {initial : Nat → ByteMemory.Bytes} :
    (p.launch I initial).Tiles 128 1 1 1 (gyOf p.s) p.gz 4 :=
  ⟨rfl, by simp [Par.launch, DownMmaWide.launch, Par.gz], rfl, ⟨by decide, by decide, gyOf_pos hp, hp.gz⟩⟩

theorem lane_of {p : Par} (hp : p.Ok) {I : In} {initial : Nat → ByteMemory.Bytes} (fuse : Nat → Bool) {y z : Nat}
    (hy : y < gyOf p.s) (hz : z < p.gz) (sg : Fin 4) (i : Fin 32) :
    Lane p ((p.launch I initial).ctxAt fuse 0 y z (32 * sg + i)) y z sg i := by
  have hs := sg.isLt; have hi := i.isLt
  have hT := launch_tiles hp (I := I) (initial := initial)
  refine ⟨Launch.ctxAt_threadgroupPositionInGrid _ _ _ _ _ _, Launch.ctxAt_lane _ _ _ _ _ _ _,
    Launch.ctxAt_simd _ _ _ _ _ _ _, ?_, ?_, rfl, fun j => ?_, hy, hz, hs, hi⟩
  · rw [hT.thread]; unfold thOf; ring
  · rw [hT.group_id]; ring
  · rw [hT.threadArray, launch_buffers, buffers_length]
    simp [Launch.groupArrays, Launch.threadArrays, Par.launch, DownMmaWide.launch, DownMmaWide.core, bufs, ta, thOf]

end Metal.Kernels.DownWideRun

/-! ## The code's parts -/

namespace Metal.Kernels.DownMmaWide
open Metal Metal.Core

def bodyPre : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .bf16⟩)), .set 1 (.lit (.ptr ⟨1, 0, .scalar .i32⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .u32⟩)), .set 3 (.lit (.ptr ⟨3, 0, .scalar .f16⟩)),
   .set 4 (.lit (.ptr ⟨4, 0, .scalar .f32⟩))]
def pre1 : List CStmt :=
  [.set 5 (.conv .u32 (ld .i32 (ptrAt 1 (i32l 0)))), .set 6 (.coord .threadIndexInSimdgroup),
   .array 7 true 0 (.scalar .f16)] ++ codebookLoop
def waStore : CStmt := .store (.scalar .u32) (ptrAt 39 (.local 40)) (u32 .rem (u32 .add (.local 29) (.local 40)) (.local 24))
def rowCodes0 : CExpr := .offset (.local 26) (u64 .mul (toU64 (u32 .add (.local 33) (.local 22))) (.local 25))
def initPart (s mt nw : Nat) : List CStmt :=
  [.array 35 false 0 (.ptr .device (.scalar .bf16)), .array 36 false 1 (.vec .f32 2), .set 37 (u32l 0),
   .loop (lt 37 (u32l mt)) (inc 37) (initBlock s mt), .array 39 false 2 (.scalar .u32), .set 40 (u32l 0),
   .loop (u32 .le (.local 40) (u32l nw)) (inc 40) [waStore], .set 41 rowCodes0, .set 42 (.local 33)]
def rC : CExpr := lt 42 (.local 34)
def rSt : List CStmt :=
  [.set 42 (u32 .add (.local 42) (u32l 8)), .set 41 (.offset (.local 41) (u64 .mul (u64l 8) (.local 25)))]
def outPart (s mt : Nat) : List CStmt := [.set 72 (u32l 0), .loop (lt 72 (u32l mt)) (inc 72) (outBody s mt)]
def rest2 (k s mt nw : Nat) (il : Bool) : List CStmt :=
  setup k s mt il ++ (initPart s mt nw ++ (.loop rC rSt (rowBody k s mt nw) :: outPart s mt))

theorem body_eq (k s mt nw : Nat) (il : Bool) :
    body k s mt nw il = bodyPre ++ [.scope (pre1 ++ .barrier 1 false true :: rest2 k s mt nw il)] := rfl

def collArg (mt : Nat) : CExpr :=
  .vector .f32 [.load (.vec .f32 2) (ptrAt 52 (.local 70)), .load (.vec .f16 2) (.local 55),
    .load (.vec .f32 2) (accAt mt (.local 54) (.local 70))]
def storeAcc (mt : Nat) : CStmt := .store (.vec .f32 2) (accAt mt (.local 54) (.local 70)) (.local 71)
def bkBody (mt : Nat) : List CStmt := [.collective 2 71 (.mma .f32 .f16) .f32 (collArg mt) (u16l 0), storeAcc mt]
def bC (mt : Nat) : CExpr := lt 70 (u32l mt)
def bStore (j b : Nat) : CStmt :=
  .store (.scalar .f16) (.offset (.ptrCast (.scalar .f16) (.local 55)) (i32l j)) (ld .f16 (ptrAt 7 (.local b)))
def spre (k s : Nat) : List CStmt :=
  [.array 55 false 7 (.vec .f16 2), .set 56 (.local 45), .set 57 (.local 46), .set 58 (.local 54), blockState k 56,
   bStore 0 59, .set 63 (.local 45), .set 64 (.local 46), .set 65 (u32 .add (.local 54) (u32l s)), blockState k 63,
   bStore 1 66, .set 70 (u32l 0)]

theorem subTile_eq (k s mt : Nat) : subTile k s mt = spre k s ++ [.loop (bC mt) (inc 70) (bkBody mt)] := rfl

def rawStore : CStmt := .store (.scalar .u32) (ptrAt 43 (.local 44)) (ld .u32 (ptrAt 41 (ld .u32 (ptrAt 39 (.local 44)))))
def wVal : CExpr :=
  .cond (.conv .bool (.local 30))
    (u32 .bitOr (u32 .shr (ld .u32 (ptrAt 43 (.local 47))) (.local 30))
      (u32 .shl (ld .u32 (ptrAt 43 (u32 .add (.local 47) (u32l 1)))) (u32 .sub (u32l 32) (.local 30))))
    (ld .u32 (ptrAt 43 (.local 47)))
def wStore : CStmt := .store (.scalar .u32) (ptrAt 45 (.local 47)) wVal
def vStore : CStmt :=
  .store (.scalar .u32) (ptrAt 46 (.local 48))
    (u32 .bitOr (u32 .shr (ld .u32 (ptrAt 45 (u32 .sub (.local 48) (u32l 1)))) (u32l 16))
      (u32 .shl (ld .u32 (ptrAt 45 (.local 48))) (u32l 16)))
def saE : CExpr := .bin .mul .f32 0 (.conv .f32 (ld .f16 (ptrAt 3 (.local 49)))) (f32l 0x3BDDB447)
def sbE : CExpr := .bin .mul .f32 0 (.conv .f32 (ld .f16 (ptrAt 3 (u32 .add (.local 49) (u32l 1))))) (f32l 0x3BDDB447)
def xmE (j : CExpr) : CExpr := ld .bf16 (.offset (.load (.ptr .device (.scalar .bf16)) (ptrAt 35 (.local 53))) j)
def aBody : List CStmt :=
  [.store (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (ptrAt 52 (.local 53))) (i32l 0))
     (.bin .mul .f32 0 (.conv .f32 (xmE (.local 49))) (.local 50)),
   .store (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (ptrAt 52 (.local 53))) (i32l 1))
     (.bin .mul .f32 0 (.conv .f32 (xmE (u32 .add (.local 49) (u32l 1)))) (.local 51))]
def rpre (mt nw : Nat) : List CStmt :=
  [.array 43 false 3 (.scalar .u32), .set 44 (u32l 0), .loop (u32 .le (.local 44) (u32l nw)) (inc 44) [rawStore],
   .array 45 false 4 (.scalar .u32), .array 46 false 5 (.scalar .u32), .set 47 (u32l 0),
   .loop (lt 47 (u32l nw)) (inc 47) [wStore], .set 48 (u32l 1), .loop (lt 48 (u32l nw)) (inc 48) [vStore],
   .set 49 (u32 .add (.local 42) (.local 23)), .set 50 saE, .set 51 sbE, .array 52 false 6 (.vec .f32 2),
   .set 53 (u32l 0), .loop (lt 53 (u32l mt)) (inc 53) aBody, .set 54 (u32l 0)]
def sC (s : Nat) : CExpr := lt 54 (u32l s)

theorem rowBody_eq (k s mt nw : Nat) :
    rowBody k s mt nw = rpre mt nw ++ [.loop (sC s) (inc 54) (subTile k s mt)] := rfl

end Metal.Kernels.DownMmaWide

namespace Metal.Kernels.DownWideRun
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis
open Metal.Kernels.DownMmaWide (Tile p0Of fmOf fnOf laneOf eTile ePos eBk eSt eLane eReg outVal expected aReg bReg accReg
  cbHalf xval sval zero rcp Geo nGOf gyOf codesBytes In bufs)

/-! ## The codebook: `trellis_y_f32` -/

section Codebook
variable (C : M1Max.Contract) {ctx : Ctx}

def cbF32 (e : Nat) : Float32 :=
  C.fadd (Val.ofF32Bits (0x4B000000 ||| (trellisYv e + 510).toNat)) (f32Neg (Val.ofF32Bits 0x4B0001FE))

theorem trellisY_eq (b : Nat) : DownMmaWide.trellisY b = Trellis.trellisYAt b := rfl

/-- The inlined `trellis_y_f32(s)` with `s` in slot `b`: its float in slot `b + 1`. -/
theorem exec_trellisYF32 (b : Nat) {l : Locals} {sh : Shared} {s : Nat} (h : l b = some (u32 s)) :
    ∃ l', Exec C ctx [DownMmaWide.trellisYF32 b] l sh .normal l' sh ∧ l' (b + 1) = some (.f32 (cbF32 C s)) ∧
      ∀ j, j ≤ b ∨ b + 5 < j → l' j = l j := by
  generalize hx : (s * 34038481 + 76625530) % 2 ^ 32 = x
  have hxl : x < 2 ^ 32 := by rw [← hx]; exact Nat.mod_lt _ (by decide)
  obtain ⟨P, hP, hPl⟩ : ∃ P, trellisP s = P ∧ P < 2 ^ 25 := ⟨_, rfl, trellisP_lt s⟩
  have hp : P = (x &&& 16711935) + (x / 2 ^ 8 &&& 16711935) := by rw [← hP, trellisP, hx]
  obtain ⟨Y, hY, hYl⟩ : ∃ Y, (P &&& 65535) + P / 2 ^ 16 = Y ∧ Y < 2 ^ 31 :=
    ⟨_, rfl, by have := Nat.and_le_right (n := P) (m := 65535); omega⟩
  have hcb : cbF32 C s = C.fadd (Val.ofF32Bits (0x4B000000 ||| Y)) (f32Neg (Val.ofF32Bits 0x4B0001FE)) := by
    unfold cbF32 trellisYv
    rw [hP, show (P &&& 0xFFFF) = (P &&& 65535) from rfl, hY, show ((Y : Int) - 510 + 510).toNat = Y by omega]
  rw [hcb]
  generalize hl₀ : setLocal l (b + 2) (u32 s) = l₀
  have h2 : l₀ (b + 2) = some (u32 s) := by rw [← hl₀, setLocal_same]
  have e1 : (eval C ctx l₀ (.bin .add .u32 0 (.bin .mul .u32 0 (.local (b + 2)) (.lit (.int .u32 34038481)))
      (.lit (.int .u32 76625530)))).run sh = some (u32 x, sh) := by
    rw [← hx, u32_mod]
    exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C h2 sh) (eval_u32lit C _ _ _ (by decide))
      (binary_mul_u32 C s 34038481)) (eval_u32lit C _ _ _ (by decide)) (binary_add_u32 C _ 76625530)
  generalize hl₁ : setLocal l₀ (b + 4) (u32 x) = l₁
  have h4 : l₁ (b + 4) = some (u32 x) := by rw [← hl₁, setLocal_same]
  have e2 : (eval C ctx l₁ (.bin .add .u32 0 (.bin .bitAnd .u32 0 (.local (b + 4)) (.lit (.int .u32 16711935)))
      (.bin .bitAnd .u32 0 (.bin .shr .u32 0 (.local (b + 4)) (.lit (.int .u32 8))) (.lit (.int .u32 16711935))))).run sh =
      some (u32 P, sh) := by
    rw [hp]
    exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C h4 sh) (eval_u32lit C _ _ _ (by decide))
      (binary_bitAnd_u32 C x 16711935 hxl (by decide)))
      (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h4 sh) (eval_u32lit C _ _ _ (by decide))
        (binary_shr_u32 C x 8 hxl (by decide))) (eval_u32lit C _ _ _ (by decide))
        (binary_bitAnd_u32 C (x / 2 ^ 8) 16711935 (lt_of_le_of_lt (Nat.div_le_self _ _) hxl) (by decide)))
      (binary_add_u32 C _ _)
  generalize hl₂ : setLocal l₁ (b + 5) (u32 P) = l₂
  have h5 : l₂ (b + 5) = some (u32 P) := by rw [← hl₂, setLocal_same]
  have e3 : (eval C ctx l₂ (.bin .sub .i32 0
      (.conv .i32 (.bin .add .u32 0 (.bin .bitAnd .u32 0 (.local (b + 5)) (.lit (.int .u32 65535)))
        (.bin .shr .u32 0 (.local (b + 5)) (.lit (.int .u32 16))))) (.lit (.int .i32 510)))).run sh =
      some (i32 ((Y : Int) - 510), sh) := by
    have hz : binary C .sub .i32 (.int .i32 Y) (.int .i32 510) = some (i32 ((Y : Int) - 510)) := by
      exact binary_sub_i32_nat C _ _ hYl (by decide)
    have hadd : (eval C ctx l₂ (.bin .add .u32 0 (.bin .bitAnd .u32 0 (.local (b + 5)) (.lit (.int .u32 65535)))
        (.bin .shr .u32 0 (.local (b + 5)) (.lit (.int .u32 16))))).run sh = some (u32 Y, sh) := by
      rw [← hY]
      exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C h5 sh) (eval_u32lit C _ _ _ (by decide))
        (binary_bitAnd_u32 C _ 65535 (by omega) (by decide)))
        (eval_bin_u32 C (eval_local' C h5 sh) (eval_u32lit C _ _ _ (by decide))
          (binary_shr_u32 C _ 16 (by omega) (by decide))) (binary_add_u32 C _ _)
    exact eval_int C (by decide) (eval_conv C (t := .i32) hadd (convert_i32_u32 C _ hYl)) (eval_lit C _ _ _ _) hz
  generalize hl₃ : setLocal l₂ (b + 3) (i32 ((Y : Int) - 510)) = l₃
  have h3 : l₃ (b + 3) = some (i32 ((Y : Int) - 510)) := by rw [← hl₃, setLocal_same]
  have hor : 1258291200 ||| Y < 2 ^ 32 := Nat.or_lt_two_pow (by decide) (by omega)
  have e4 : (eval C ctx l₃ (.bin .sub .f32 0
      (.bitcast .f32 (.bin .bitOr .u32 0 (.lit (.int .u32 0x4B000000))
        (.conv .u32 (.bin .add .i32 0 (.local (b + 3)) (.lit (.int .i32 510))))))
      (.lit (.f32 (Val.ofF32Bits 0x4B0001FE))))).run sh =
      some (.f32 (C.fadd (Val.ofF32Bits (0x4B000000 ||| Y)) (f32Neg (Val.ofF32Bits 0x4B0001FE))), sh) := by
    have hz : binary C .add .i32 (i32 ((Y : Int) - 510)) (.int .i32 510) = some (.int .i32 Y) := by
      exact binary_add_i32_sub C hYl (by decide)
    have hbc : (eval C ctx l₃ (.bitcast .f32 (.bin .bitOr .u32 0 (.lit (.int .u32 0x4B000000))
        (.conv .u32 (.bin .add .i32 0 (.local (b + 3)) (.lit (.int .i32 510))))))).run sh =
        some (.f32 (Val.ofF32Bits (0x4B000000 ||| Y)), sh) :=
      eval_bitcast C (eval_bin_u32 C (eval_u32lit C _ _ _ (by decide))
        (eval_conv C (t := .u32) (eval_int C (by decide) (eval_local' C h3 sh) (eval_lit C _ _ _ _) hz)
          (convert_u32_i32 C _ hYl))
        (binary_bitOr_u32 C 1258291200 _ (by decide) (by omega))) (bitcast_f32_u32 _ hor)
    exact eval_f32 C (.inr ⟨rfl, rfl⟩) hbc (eval_lit C _ _ _ _) rfl
  refine ⟨setLocal l₃ (b + 1) (.f32 (C.fadd (Val.ofF32Bits (0x4B000000 ||| Y)) (f32Neg (Val.ofF32Bits 0x4B0001FE)))),
    ?_, setLocal_same _ _ _, fun j hj => ?_⟩
  · have hy : Exec C ctx [DownMmaWide.trellisY (b + 2)] l₀ sh .normal l₃ sh := by
      rw [trellisY_eq]
      exact .scope (.set e1 (by rw [hl₁]; exact .set e2 (by rw [hl₂]; exact .set e3 (by rw [hl₃]; exact .leave))))
        (.inr rfl) (.nil _ _)
    have hfull : Exec C ctx [.set (b + 2) (.local b), DownMmaWide.trellisY (b + 2), .set (b + 1) (.bin .sub .f32 0
        (.bitcast .f32 (.bin .bitOr .u32 0 (.lit (.int .u32 0x4B000000))
          (.conv .u32 (.bin .add .i32 0 (.local (b + 3)) (.lit (.int .i32 510))))))
        (.lit (.f32 (Val.ofF32Bits 0x4B0001FE)))), .leave] l sh .leave
        (setLocal l₃ (b + 1) (.f32 (C.fadd (Val.ofF32Bits (0x4B000000 ||| Y)) (f32Neg (Val.ofF32Bits 0x4B0001FE))))) sh :=
      .set (eval_local' C h sh) (by rw [hl₀]; exact hy.append (.set e4 .leave))
    exact .scope hfull (.inr rfl) (.nil _ _)
  · rw [setLocal_other _ _ (by omega), ← hl₃, setLocal_other _ _ (by omega), ← hl₂, setLocal_other _ _ (by omega),
      ← hl₁, setLocal_other _ _ (by omega), ← hl₀, setLocal_other _ _ (by omega)]

end Codebook

end Metal.Kernels.DownWideRun

namespace Metal.Kernels.DownMmaWide
open Metal Metal.Core

def cbBody : List CStmt :=
  [.set 9 (.local 8), trellisYF32 9, .store (.scalar .f16) (.offset (.local 7) (.local 8)) (.conv .f16 (.local 10))]
def cbLoop : CStmt := .loop (u32 .lt (.local 8) (u32l 4096)) [.set 8 (u32 .add (.local 8) (u32l 128))] cbBody
def cbStart : CStmt := .set 8 (u32 .add (u32 .mul (.coord .simdgroupIndexInThreadgroup) (u32l 32)) (.local 6))

theorem pre1_eq : pre1 = [.set 5 (.conv .u32 (ld .i32 (ptrAt 1 (i32l 0)))), .set 6 (.coord .threadIndexInSimdgroup),
    .array 7 true 0 (.scalar .f16), cbStart, cbLoop] := rfl

end Metal.Kernels.DownMmaWide

namespace Metal.Kernels.DownWideRun
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis
open Metal.Kernels.DownMmaWide (Tile p0Of fmOf fnOf laneOf eTile ePos eBk eSt eLane eReg outVal expected aReg bReg accReg
  cbHalf xval sval zero rcp Geo nGOf gyOf codesBytes In bufs)

def Par.body (p : Par) : List CStmt := DownMmaWide.body p.k p.s p.mt p.nw p.il
def Par.rest2 (p : Par) : List CStmt := DownMmaWide.rest2 p.k p.s p.mt p.nw p.il

/-! ### Before the barrier: the codebook -/

/-- The buffer pointers, `M`, the lane and the codebook pointer. -/
structure Fix1 (p : Par) (i : Nat) (l : Locals) : Prop where
  l0 : l 0 = some (.ptr ⟨0, 0, .scalar .bf16⟩)
  l1 : l 1 = some (.ptr ⟨1, 0, .scalar .i32⟩)
  l2 : l 2 = some (.ptr ⟨2, 0, .scalar .u32⟩)
  l3 : l 3 = some (.ptr ⟨3, 0, .scalar .f16⟩)
  l4 : l 4 = some (.ptr ⟨4, 0, .scalar .f32⟩)
  l5 : l 5 = some (u32 p.M)
  l6 : l 6 = some (u32 i)
  l7 : l 7 = some (.ptr ⟨5, 0, .scalar .f16⟩)

theorem Fix1.of_eq {p : Par} {i : Nat} {l l' : Locals} (h : Fix1 p i l) (h' : ∀ j, j ≤ 7 → l' j = l j) : Fix1 p i l' :=
  ⟨(h' 0 (by omega)).trans h.l0, (h' 1 (by omega)).trans h.l1, (h' 2 (by omega)).trans h.l2,
    (h' 3 (by omega)).trans h.l3, (h' 4 (by omega)).trans h.l4, (h' 5 (by omega)).trans h.l5,
    (h' 6 (by omega)).trans h.l6, (h' 7 (by omega)).trans h.l7⟩

section Phase1
variable (C : M1Max.Contract) {p : Par} {L : Launch} {I : In} {outOk : Nat → Prop} {ctx : Ctx} {y z sg i g : Nat}

/-- At the `n`-th test of the codebook loop of local thread `t = 32·sg + i`. -/
def FillI (C : M1Max.Contract) (p : Par) (L : Launch) (I : In) (outOk : Nat → Prop) (g i t : Nat) (n : Nat)
    (l : Locals) (sh : Shared) : Prop :=
  Fix1 p i l ∧ l 8 = some (u32 (t + 128 * n)) ∧
    Mem C p L I g (fun e => e % 128 < t ∨ (e % 128 = t ∧ e / 128 < n)) outOk sh

theorem fill_loop (hS : Shape L p I) (hl : Lane p ctx y z sg i) (hg : g = y + z * gyOf p.s) {l : Locals} {sh : Shared}
    (h0 : FillI C p L I outOk g i (32 * sg + i) 0 l sh) :
    ∃ l' sh', Exec C ctx [DownMmaWide.cbLoop] l sh .normal l' sh' ∧
      FillI C p L I outOk g i (32 * sg + i) 32 l' sh' := by
  have hs := hl.hsg; have hi := hl.hi
  refine Exec.loop_count 32 (FillI C p L I outOk g i (32 * sg + i)) (FillI C p L I outOk g i (32 * sg + i))
    (fun n hn l sh hI => ⟨sh, ?_, hI⟩) (fun n hn l sh hI => ?_) h0
  · have h := eval_lt_u32 C (ctx := ctx) (sh := sh) (b := 4096) hI.2.1 (by omega) (by decide)
    rwa [show decide (32 * sg + i + 128 * n < 4096) = decide (n < 32) from decide_eq_decide.mpr (by omega)] at h
  · obtain ⟨hF, h8, hm⟩ := hI
    have he : 32 * sg + i + 128 * n < 4096 := by omega
    obtain ⟨l₂, hcb, h10, hag⟩ := exec_trellisYF32 C (ctx := ctx) 9 (l := setLocal l 9 (u32 (32 * sg + i + 128 * n)))
      (sh := sh) (s := 32 * sg + i + 128 * n) (setLocal_same _ _ _)
    have h7 : l₂ 7 = some (.ptr ⟨5, 0, .scalar .f16⟩) := by rw [hag 7 (by omega), setLocal_other _ _ (by omega)]; exact hF.l7
    have h8' : l₂ 8 = some (u32 (32 * sg + i + 128 * n)) := by
      rw [hag 8 (by omega), setLocal_other _ _ (by omega)]; exact h8
    have hp := eval_ptr_u32 C (ctx := ctx) (eval_local' C h7 sh) (eval_local' C h8' sh) (by omega)
    rw [show (32 * sg + i + 128 * n) * (Ty.scalar .f16).bytes = 2 * (32 * sg + i + 128 * n) by
      simp [Ty.bytes, Scalar.bytes]; ring] at hp
    have hv : (eval C ctx l₂ (.conv .f16 (.local 10))).run sh = some (.f16 (cbHalf C (32 * sg + i + 128 * n)), sh) :=
      eval_conv C (eval_local' C h10 sh) rfl
    have hst := store_shared ctx .f16 sh 5 (2 * (32 * sg + i + 128 * n)) _ _ _ (by rw [hm.regions]; exact hS.r5)
      (by simp) (by simp) (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega)
      (encode_f16 (cbHalf C (32 * sg + i + 128 * n)))
    have hm' := hm.wcb hS ctx (32 * sg + i + 128 * n) he (by rw [hl.thread, thOf, ← hg]; omega) (by rw [hl.group, hg])
    rw [show Scalar.f16.bytes = 2 from rfl] at hst
    generalize wrn ctx sh 5 (2 * (32 * sg + i + 128 * n)) 2
      (wordBytes 2 (Val.f16Bits (cbHalf C (32 * sg + i + 128 * n)))) = sh₁ at hst hm'
    refine ⟨.normal, l₂, sh₁, setLocal l₂ 8 (u32 (32 * sg + i + 128 * n + 128)), sh₁, .inl rfl, ?_,
      .set (eval_bin_u32 C (eval_local' C h8' _) (eval_u32lit C _ _ 128 (by decide)) (binary_add_u32 C _ 128)) (.nil _ _),
      ⟨?_, by rw [setLocal_same, show 32 * sg + i + 128 * n + 128 = 32 * sg + i + 128 * (n + 1) by ring], ?_⟩⟩
    · exact .set (eval_local' C h8 sh) (hcb.append (.store hp hv hst (.nil _ _)))
    · exact hF.of_eq fun j hj => by rw [setLocal_other _ _ (by omega), hag j (by omega), setLocal_other _ _ (by omega)]
    · refine hm'.mono (fun e _ h => ?_) (fun _ _ h => h)
      rcases h with h | ⟨h1, h2⟩
      · exact .inl (.inl h)
      · by_cases hn' : e / 128 < n
        · exact .inl (.inr ⟨h1, hn'⟩)
        · exact .inr (by omega)

/-- A lane runs to the barrier: `M`, the lane, its codebook entries. -/
theorem lane_phase1 (hS : Shape L p I) (hp : p.Ok) (hl : Lane p ctx y z sg i) (hg : g = y + z * gyOf p.s)
    (hM : word32 I.Xs 0 = p.M) {sh : Shared}
    (hm : Mem C p L I g (fun e => e % 128 < 32 * sg + i) outOk sh) :
    ∃ t sh', (Ev fun m => (runThread C m ⟨ctx, fun _ => none, [.block p.body], .running⟩).run sh = some (t, sh')) ∧
      Mem C p L I g (fun e => e % 128 < 32 * sg + i + 1) outOk sh' ∧
      t.status = .barrier 1 false true ∧ t.ctx = ctx ∧ t.frames = [.block p.rest2, .scope, .block []] ∧
      Fix1 p i t.locals := by
  have hs := hl.hsg; have hi := hl.hi
  have hM2 := hp.m2
  -- the five buffer pointers
  generalize hl₀ : setLocal (setLocal (setLocal (setLocal (setLocal (fun _ => none) 0 (.ptr ⟨0, 0, .scalar .bf16⟩)) 1
    (.ptr ⟨1, 0, .scalar .i32⟩)) 2 (.ptr ⟨2, 0, .scalar .u32⟩)) 3 (.ptr ⟨3, 0, .scalar .f16⟩)) 4
    (.ptr ⟨4, 0, .scalar .f32⟩) = l₀
  have x0 : Exec C ctx DownMmaWide.bodyPre (fun _ => none) sh .normal l₀ sh := by
    rw [← hl₀]
    exact .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <|
      .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) (.nil _ _)
  have h1 : l₀ 1 = some (.ptr ⟨1, 0, .scalar .i32⟩) := by rw [← hl₀]; simp [setLocal]
  -- `M`
  have hp1 := eval_offset_i32 C (ctx := ctx) (l := l₀) (sh := sh) (i := .lit (.int .i32 0)) (o := 0) (n := 0)
    (eval_local' C h1 sh) (eval_lit C _ _ _ _) (by decide)
  have hld := load_shared ctx .i32 sh 1 0 _ (by rw [hm.regions]; exact hS.r1) (by simp) (by simp [Scalar.bytes]; exact hS.ash)
    (by simp [Scalar.bytes]) (by simp [Scalar.bytes]) (by simp [loadOffset])
  have hw : Val.ofWord .i32 (bytesWord (cells (sh.bytes 1) 0 Scalar.i32.bytes)) = .int .i32 p.M := by
    rw [hm.xs]
    show Val.int .i32 (word32 I.Xs 0 % 2 ^ 32) = _
    rw [hM, Nat.mod_eq_of_lt (by omega)]
  rw [hw] at hld
  have e5 : (eval C ctx l₀ (.conv .u32 (.load (.scalar .i32) (.offset (.local 1) (.lit (.int .i32 0)))))).run sh =
      some (u32 p.M, rdn ctx sh 1 0 Scalar.i32.bytes) :=
    eval_conv C ((eval_load C _ _ _ _ _ _ _ hp1).trans hld) (convert_u32_i32 C p.M (by omega))
  have hm₁ := hm.rd hS ctx 1 0 Scalar.i32.bytes (.inl (by decide))
  generalize rdn ctx sh 1 0 Scalar.i32.bytes = sh₁ at e5 hm₁
  generalize hl₁ : setLocal (setLocal (setLocal l₀ 5 (u32 p.M)) 6 (u32 i)) 7 (.ptr ⟨5, 0, .scalar .f16⟩) = l₁
  have hF₁ : Fix1 p i l₁ := by
    rw [← hl₁, ← hl₀]; exact ⟨by simp [setLocal], by simp [setLocal], by simp [setLocal], by simp [setLocal],
      by simp [setLocal], by simp [setLocal], by simp [setLocal], by simp [setLocal]⟩
  have x1 : Exec C ctx [.set 5 (.conv .u32 (.load (.scalar .i32) (.offset (.local 1) (.lit (.int .i32 0))))),
      .set 6 (.coord .threadIndexInSimdgroup), .array 7 true 0 (.scalar .f16)] l₀ sh .normal l₁ sh₁ := by
    rw [← hl₁]
    refine .set e5 (.set (by rw [eval_coord, hl.lane]) (.array ?_))
    rw [hl.ga0]; exact .nil _ _
  -- the codebook loop
  have e8 : (eval C ctx l₁ (DownMmaWide.u32 .add (DownMmaWide.u32 .mul (.coord .simdgroupIndexInThreadgroup)
      (DownMmaWide.u32l 32)) (.local 6))).run sh₁ = some (u32 (32 * sg + i), sh₁) := by
    rw [show 32 * sg + i = sg * 32 + i by ring]
    exact eval_bin_u32 C (eval_bin_u32 C (by rw [eval_coord, hl.sgc]) (eval_u32lit C _ _ 32 (by decide))
      (binary_mul_u32 C sg 32)) (eval_local' C hF₁.l6 sh₁) (binary_add_u32 C _ _)
  obtain ⟨l₂, sh₂, xf, hF₂, -, hm₂⟩ := fill_loop C hS hl hg (l := setLocal l₁ 8 (u32 (32 * sg + i))) (sh := sh₁)
    ⟨hF₁.of_eq fun j hj => setLocal_other _ _ (by omega), by rw [setLocal_same, Nat.mul_zero, Nat.add_zero],
      hm₁.mono (fun e _ h => by rcases h with h | ⟨-, h⟩ <;> omega) (fun _ _ h => h)⟩
  have hpre : Exec C ctx DownMmaWide.pre1 l₀ sh .normal l₂ sh₂ := by
    rw [DownMmaWide.pre1_eq]
    exact x1.append (.set e8 xf)
  have hbody : Exec C ctx p.body (fun _ => none) sh (.stop (.barrier 1 false true) [.block p.rest2, .scope, .block []])
      l₂ sh₂ := by
    unfold Par.body Par.rest2
    rw [DownMmaWide.body_eq]
    exact x0.append (.scope_stop (hpre.append .barrier))
  refine ⟨⟨ctx, l₂, [.block p.rest2, .scope, .block []], .barrier 1 false true⟩, sh₂, ?_,
    hm₂.mono (fun e he h => ?_) (fun _ _ h => h), rfl, rfl, rfl, hF₂⟩
  · exact (hbody.reaches_stop (K := [])).ev_stop rfl
  · by_cases h' : e % 128 < 32 * sg + i
    · exact .inl h'
    · exact .inr ⟨by omega, by omega⟩

end Phase1

end Metal.Kernels.DownWideRun

namespace Metal.Kernels.DownWideRun
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis
open Metal.Kernels.DownMmaWide (Tile p0Of fmOf fnOf laneOf eTile ePos eBk eSt eLane eReg outVal expected aReg bReg accReg
  cbHalf xval sval zero rcp Geo nGOf gyOf codesBytes In bufs)

/-! ### After the barrier: the SIMD-group's place -/

/-- The lane's slots after `setup`. -/
structure SLoc (p : Par) (T : Tile) (i : Nat) (l : Locals) : Prop where
  fix : Fix1 p i l
  l19 : l 19 = some (u32 T.split)
  l20 : l 20 = some (u32 T.block)
  l22 : l 22 = some (u32 (fmOf i))
  l23 : l 23 = some (u32 (fnOf i))
  l24 : l 24 = some (u32 (8 * p.k))
  l25 : l 25 = some (u64 (DownPartial.roww p.k p.il))
  l26 : l 26 = some (.ptr ⟨2, ((4 * DownPartial.blockOff p.k p.il T.block : Nat) : Int), .scalar .u32⟩)
  l27 : l 27 = some (u32 (p0Of p.s T i))
  l29 : l 29 = some (u32 (p0Of p.s T i * p.k / 32))
  l30 : l 30 = some (u32 (p0Of p.s T i * p.k % 32))
  l31 : l 31 = some (u32 T.mBase)
  l33 : l 33 = some (u32 (2176 * T.split))
  l34 : l 34 = some (u32 (2176 * T.split + 2176))

theorem SLoc.of_eq {p : Par} {T : Tile} {i : Nat} {l l' : Locals} (h : SLoc p T i l) (h' : ∀ j, j ≤ 34 → l' j = l j) :
    SLoc p T i l' :=
  ⟨h.fix.of_eq fun j hj => h' j (by omega), (h' 19 (by omega)).trans h.l19, (h' 20 (by omega)).trans h.l20,
    (h' 22 (by omega)).trans h.l22, (h' 23 (by omega)).trans h.l23, (h' 24 (by omega)).trans h.l24,
    (h' 25 (by omega)).trans h.l25, (h' 26 (by omega)).trans h.l26, (h' 27 (by omega)).trans h.l27,
    (h' 29 (by omega)).trans h.l29, (h' 30 (by omega)).trans h.l30, (h' 31 (by omega)).trans h.l31,
    (h' 33 (by omega)).trans h.l33, (h' 34 (by omega)).trans h.l34⟩

/-- Facts on a SIMD-group's tile. -/
theorem tile_facts {p : Par} (hp : p.Ok) {y z sg : Nat} (hy : y < gyOf p.s) (hz : z < p.gz) (hsg : sg < 4) :
    (tileOf p.s p.mt y z sg).split < 8 ∧ (tileOf p.s p.mt y z sg).block < 20 ∧
      (tileOf p.s p.mt y z sg).q < 32 / p.s ∧ (tileOf p.s p.mt y z sg).mBase < p.M ∧
      (tileOf p.s p.mt y z sg).mBase = 8 * p.mt * z := by
  have hM := hp.m1
  have hzM : 8 * p.mt * z < p.M := by
    have h := hz
    unfold Par.gz ceilDiv at h
    rcases hp.sm with ⟨-, h2⟩ | ⟨-, h2⟩ | ⟨-, h2⟩ <;> rw [h2] at h ⊢ <;> omega
  refine ⟨?_, ?_, ?_, hzM, rfl⟩ <;> simp only [tileOf, nGOf] <;> unfold gyOf nGOf at hy <;>
    rcases hp.sm with ⟨h1, -⟩ | ⟨h1, -⟩ | ⟨h1, -⟩ <;> rw [h1] at hy ⊢ <;> omega

section Setup
variable (C : M1Max.Contract) {p : Par} {ctx : Ctx} {y z sg i : Nat}

theorem roww_eq (k : Nat) (il : Bool) : (if il then 2 else 20) * (8 * k) = DownPartial.roww k il := by
  cases il <;> simp [DownPartial.roww, DownPartial.wpb]

/-- `words`' offset from `codes`. -/
theorem eval_wordsOffset (il : Bool) {k blk : Nat} {l : Locals} {sh : Shared} (hk : k ≤ 4) (hblk : blk < 20)
    (h20 : l 20 = some (u32 blk)) (h24 : l 24 = some (u32 (8 * k))) :
    (eval C ctx l (DownMmaWide.wordsOffset il)).run sh = some (u64 (DownPartial.blockOff k il blk), sh) := by
  unfold DownMmaWide.wordsOffset DownPartial.blockOff DownPartial.wpb
  cases il with
  | true =>
    simp only [ite_true]
    refine eval_int C (by decide) (eval_int C (by decide) (eval_int C (by decide) (eval_int C (by decide)
      (eval_conv C (t := .u64) (eval_bin_u32 C (eval_local' C h20 sh) (eval_u32lit C _ _ 2 (by decide))
        (binary_div_u32 C _ 2 (by omega) (by decide) (by decide))) (convert_u64_u32 C _ (by omega)))
      (eval_u64lit C _ _ 17408 (by decide)) (binary_mul_u64 C _ _))
      (eval_u64lit C _ _ 2 (by decide)) (binary_mul_u64 C _ _))
      (eval_conv C (t := .u64) (eval_local' C h24 sh) (convert_u64_u32 C _ (by omega))) (binary_mul_u64 C _ _))
      (eval_conv C (t := .u64) (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h20 sh) (eval_u32lit C _ _ 2 (by decide))
        (binary_rem_u32 C _ 2 (by omega) (by decide) (by decide))) (eval_local' C h24 sh)
        (binary_mul_u32 C _ _)) (convert_u64_u32 C _ ?_)) (binary_add_u64 C _ _)
    have := Nat.mod_lt blk (show 0 < 2 by decide); nlinarith
  | false =>
    simp only [Bool.false_eq_true, ite_false]
    exact eval_int C (by decide) (eval_conv C (t := .u64) (eval_local' C h20 sh) (convert_u64_u32 C _ (by omega)))
      (eval_conv C (t := .u64) (eval_local' C h24 sh) (convert_u64_u32 C _ (by omega))) (binary_mul_u64 C _ _)

/-- `setup`: `id`, the group and split, the lane's fragment, its code window, `mBase`, `r0`, `r1`. -/
theorem lane_setup (hp : p.Ok) (hl : Lane p ctx y z sg i) {l : Locals} {sh : Shared} (hF : Fix1 p i l) :
    ∃ l', Exec C ctx (DownMmaWide.setup p.k p.s p.mt p.il) l sh .normal l' sh ∧
      SLoc p (tileOf p.s p.mt y z sg) i l' := by
  have hy := hl.hy; have hz := hl.hz; have hsg := hl.hsg; have hi := hl.hi
  obtain ⟨hk1, hk2⟩ := hp.k
  obtain ⟨ht1, ht2, ht3, ht4, ht5⟩ := tile_facts hp hy hz hsg
  obtain ⟨hfm, hfn⟩ := fm_fn_code i hi
  have hli := lane_fm_fn i hi
  have hM := hp.m2
  have hs : p.s = 16 ∨ p.s = 8 := by rcases hp.sm with ⟨h, -⟩ | ⟨h, -⟩ | ⟨h, -⟩ <;> simp [h]
  have hgy : gyOf p.s ≤ 160 := by unfold gyOf nGOf; rcases hs with h | h <;> simp [h]
  have hgpb : 0 < 32 / p.s ∧ 32 / p.s ≤ 4 ∧ 32 / p.s * p.s = 32 := by rcases hs with h | h <;> rw [h] <;> decide
  have hnG : nGOf p.s = 20 * (32 / p.s) := rfl
  have hid : 4 * y + sg < nGOf p.s * 8 := by unfold gyOf at hy; omega
  have hq : (4 * y + sg) % nGOf p.s % (32 / p.s) * 8 * p.s + p.s * fnOf i = p0Of p.s (tileOf p.s p.mt y z sg) i := by
    simp only [p0Of, tileOf]; ring
  have hp0 : p0Of p.s (tileOf p.s p.mt y z sg) i + 2 * p.s ≤ 256 := by
    simp only [p0Of, tileOf]
    have hq' := Nat.mod_lt ((4 * y + sg) % nGOf p.s) hgpb.1
    rcases hs with h | h <;> rw [h] at hq' ⊢ <;> omega
  have hrw := roww_eq p.k p.il
  have hnG0 : 0 < nGOf p.s ∧ nGOf p.s ≤ 80 := by rw [hnG]; omega
  have hcg : (4 * y + sg) % nGOf p.s < nGOf p.s := Nat.mod_lt _ hnG0.1
  have hpk : p0Of p.s (tileOf p.s p.mt y z sg) i * p.k < 2 ^ 32 := by nlinarith
  have hmt : p.mt ≤ 3 := by rcases hp.sm with ⟨-, h⟩ | ⟨-, h⟩ | ⟨-, h⟩ <;> rw [h] <;> decide
  -- the evaluations, for any locals holding their operands
  have e15 : ∀ L : Locals, (eval C ctx L (DownMmaWide.u32 .add (DownMmaWide.u32 .mul
      (.component (.coord .threadgroupPositionInGrid) (DownMmaWide.u32l 1)) (DownMmaWide.u32l 4))
      (.coord .simdgroupIndexInThreadgroup))).run sh = some (u32 (4 * y + sg), sh) := fun L => by
    rw [show 4 * y + sg = y * 4 + sg by ring]
    exact eval_bin_u32 C (eval_bin_u32 C (eval_coord1 C hl.gpos) (eval_u32lit C _ _ 4 (by decide))
      (binary_mul_u32 C y 4)) (by rw [eval_coord, hl.sgc]) (binary_add_u32 C _ _)
  have e17 : ∀ L : Locals, L 16 = some (u32 (32 / p.s)) →
      (eval C ctx L (DownMmaWide.u32 .mul (DownMmaWide.u32l 20) (.local 16))).run sh = some (u32 (nGOf p.s), sh) :=
    fun L h => eval_bin_u32 C (eval_u32lit C _ _ 20 (by decide)) (eval_local' C h sh) (binary_mul_u32 C 20 (32 / p.s))
  have eite : ∀ L : Locals, L 15 = some (u32 (4 * y + sg)) → L 17 = some (u32 (nGOf p.s)) →
      (eval C ctx L (DownMmaWide.u32 .ge (.local 15) (DownMmaWide.u32 .mul (.local 17) (DownMmaWide.u32l 8)))).run sh =
        some (.bool false, sh) := fun L h15 h17 =>
    eval_bin_u32 C (eval_local' C h15 sh) (eval_bin_u32 C (eval_local' C h17 sh) (eval_u32lit C _ _ 8 (by decide))
      (binary_mul_u32 C (nGOf p.s) 8))
      (by rw [binary_ge_u32 C (4 * y + sg) (nGOf p.s * 8) (by omega) (by omega), decide_eq_false (by omega)])
  have e18 : ∀ L : Locals, L 15 = some (u32 (4 * y + sg)) → L 17 = some (u32 (nGOf p.s)) →
      (eval C ctx L (DownMmaWide.u32 .rem (.local 15) (.local 17))).run sh = some (u32 ((4 * y + sg) % nGOf p.s), sh) :=
    fun L h15 h17 => eval_bin_u32 C (eval_local' C h15 sh) (eval_local' C h17 sh)
      (binary_rem_u32 C (4 * y + sg) (nGOf p.s) (by omega) (by omega) hnG0.1)
  have e19 : ∀ L : Locals, L 15 = some (u32 (4 * y + sg)) → L 17 = some (u32 (nGOf p.s)) →
      (eval C ctx L (DownMmaWide.u32 .div (.local 15) (.local 17))).run sh = some (u32 ((4 * y + sg) / nGOf p.s), sh) :=
    fun L h15 h17 => eval_bin_u32 C (eval_local' C h15 sh) (eval_local' C h17 sh)
      (binary_div_u32 C (4 * y + sg) (nGOf p.s) (by omega) (by omega) hnG0.1)
  have e20 : ∀ L : Locals, L 18 = some (u32 ((4 * y + sg) % nGOf p.s)) → L 16 = some (u32 (32 / p.s)) →
      (eval C ctx L (DownMmaWide.u32 .div (.local 18) (.local 16))).run sh =
        some (u32 ((4 * y + sg) % nGOf p.s / (32 / p.s)), sh) :=
    fun L h18 h16 => eval_bin_u32 C (eval_local' C h18 sh) (eval_local' C h16 sh)
      (binary_div_u32 C ((4 * y + sg) % nGOf p.s) (32 / p.s) (by omega) (by omega) hgpb.1)
  have e21 : ∀ L : Locals, L 18 = some (u32 ((4 * y + sg) % nGOf p.s)) → L 16 = some (u32 (32 / p.s)) →
      (eval C ctx L (DownMmaWide.u32 .mul (DownMmaWide.u32 .mul (DownMmaWide.u32 .rem (.local 18) (.local 16))
        (DownMmaWide.u32l 8)) (DownMmaWide.u32l p.s))).run sh =
        some (u32 ((4 * y + sg) % nGOf p.s % (32 / p.s) * 8 * p.s), sh) :=
    fun L h18 h16 => eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h18 sh) (eval_local' C h16 sh)
      (binary_rem_u32 C ((4 * y + sg) % nGOf p.s) (32 / p.s) (by omega) (by omega) hgpb.1))
      (eval_u32lit C _ _ 8 (by decide)) (binary_mul_u32 C _ 8)) (eval_u32lit C _ _ p.s (by omega))
      (binary_mul_u32 C _ p.s)
  have e22 : ∀ L : Locals, L 6 = some (u32 i) → (eval C ctx L DownMmaWide.fmExpr).run sh = some (u32 (fmOf i), sh) :=
    fun L h6 => by
      rw [← hfm]
      exact eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h6 sh) (eval_u32lit C _ _ 4 (by decide))
        (binary_div_u32 C i 4 (by omega) (by decide) (by decide))) (eval_u32lit C _ _ 4 (by decide))
        (binary_bitAnd_u32 C _ 4 (by omega) (by decide)))
        (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h6 sh) (eval_u32lit C _ _ 2 (by decide))
          (binary_div_u32 C i 2 (by omega) (by decide) (by decide))) (eval_u32lit C _ _ 4 (by decide))
          (binary_rem_u32 C _ 4 (by omega) (by decide) (by decide))) (binary_add_u32 C _ _)
  have e23 : ∀ L : Locals, L 6 = some (u32 i) → (eval C ctx L DownMmaWide.fnExpr).run sh = some (u32 (fnOf i), sh) :=
    fun L h6 => by
      rw [← hfn]
      exact eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h6 sh)
        (eval_u32lit C _ _ 4 (by decide)) (binary_div_u32 C i 4 (by omega) (by decide) (by decide)))
        (eval_u32lit C _ _ 2 (by decide)) (binary_bitAnd_u32 C _ 2 (by omega) (by decide)))
        (eval_u32lit C _ _ 2 (by decide)) (binary_mul_u32 C _ 2))
        (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h6 sh) (eval_u32lit C _ _ 2 (by decide))
          (binary_rem_u32 C i 2 (by omega) (by decide) (by decide))) (eval_u32lit C _ _ 2 (by decide))
          (binary_mul_u32 C _ 2)) (binary_add_u32 C _ _)
  have e25 : ∀ L : Locals, L 24 = some (u32 (8 * p.k)) →
      (eval C ctx L (DownMmaWide.u64 .mul (DownMmaWide.u64l (if p.il then 2 else 20)) (DownMmaWide.toU64 (.local 24)))).run sh =
        some (u64 (DownPartial.roww p.k p.il), sh) := fun L h24 => by
    rw [← hrw]
    exact eval_int C (by decide) (eval_u64lit C _ _ _ (by cases p.il <;> decide))
      (eval_conv C (t := .u64) (eval_local' C h24 sh) (convert_u64_u32 C _ (by omega))) (binary_mul_u64 C _ _)
  have hlt : DownPartial.blockOff p.k p.il (tileOf p.s p.mt y z sg).block < 2 ^ 64 := by
    unfold DownPartial.blockOff DownPartial.wpb
    split
    · have h1 : (tileOf p.s p.mt y z sg).block / 2 * 17408 * 2 * (8 * p.k) ≤ 20 * 17408 * 2 * 32 :=
        Nat.mul_le_mul (by omega) (by omega)
      have h2 : (tileOf p.s p.mt y z sg).block % 2 * (8 * p.k) ≤ 1 * 32 := Nat.mul_le_mul (by omega) (by omega)
      omega
    · have h1 : (tileOf p.s p.mt y z sg).block * (8 * p.k) ≤ 20 * 32 := Nat.mul_le_mul (by omega) (by omega)
      omega
  have e26 : ∀ L : Locals, L 2 = some (.ptr ⟨2, 0, .scalar .u32⟩) → L 20 = some (u32 (tileOf p.s p.mt y z sg).block) →
      L 24 = some (u32 (8 * p.k)) → (eval C ctx L (.offset (.local 2) (DownMmaWide.wordsOffset p.il))).run sh =
      some (.ptr ⟨2, ((4 * DownPartial.blockOff p.k p.il (tileOf p.s p.mt y z sg).block : Nat) : Int), .scalar .u32⟩, sh) := by
    intro L h2 h20 h24
    have := eval_offset_u64 C (ctx := ctx) (o := 0) (eval_local' C h2 sh) (eval_wordsOffset C p.il (by omega) ht2 h20 h24) hlt
    rwa [show 0 + DownPartial.blockOff p.k p.il (tileOf p.s p.mt y z sg).block * (Ty.scalar .u32).bytes =
      4 * DownPartial.blockOff p.k p.il (tileOf p.s p.mt y z sg).block by simp [Ty.bytes, Scalar.bytes]; ring] at this
  have e27 : ∀ L : Locals, L 21 = some (u32 ((4 * y + sg) % nGOf p.s % (32 / p.s) * 8 * p.s)) →
      L 23 = some (u32 (fnOf i)) → (eval C ctx L (DownMmaWide.u32 .add (.local 21) (DownMmaWide.u32 .mul
        (DownMmaWide.u32l p.s) (.local 23)))).run sh = some (u32 (p0Of p.s (tileOf p.s p.mt y z sg) i), sh) :=
    fun L h21 h23 => by
      rw [← hq]
      exact eval_bin_u32 C (eval_local' C h21 sh) (eval_bin_u32 C (eval_u32lit C _ _ p.s (by omega))
        (eval_local' C h23 sh) (binary_mul_u32 C p.s _)) (binary_add_u32 C _ _)
  have e28 : ∀ L : Locals, L 27 = some (u32 (p0Of p.s (tileOf p.s p.mt y z sg) i)) →
      (eval C ctx L (DownMmaWide.u32 .mul (.local 27) (DownMmaWide.u32l p.k))).run sh =
        some (u32 (p0Of p.s (tileOf p.s p.mt y z sg) i * p.k), sh) :=
    fun L h => eval_bin_u32 C (eval_local' C h sh) (eval_u32lit C _ _ p.k (by omega)) (binary_mul_u32 C _ p.k)
  have e29 : ∀ L : Locals, L 28 = some (u32 (p0Of p.s (tileOf p.s p.mt y z sg) i * p.k)) →
      (eval C ctx L (DownMmaWide.u32 .shr (.local 28) (DownMmaWide.u32l 5))).run sh =
        some (u32 (p0Of p.s (tileOf p.s p.mt y z sg) i * p.k / 32), sh) :=
    fun L h => eval_bin_u32 C (eval_local' C h sh) (eval_u32lit C _ _ 5 (by decide))
      (by rw [binary_shr_u32 C _ 5 hpk (by decide)]; rfl)
  have e30 : ∀ L : Locals, L 28 = some (u32 (p0Of p.s (tileOf p.s p.mt y z sg) i * p.k)) →
      (eval C ctx L (DownMmaWide.u32 .bitAnd (.local 28) (DownMmaWide.u32l 31))).run sh =
        some (u32 (p0Of p.s (tileOf p.s p.mt y z sg) i * p.k % 32), sh) :=
    fun L h => eval_bin_u32 C (eval_local' C h sh) (eval_u32lit C _ _ 31 (by decide))
      (by rw [binary_bitAnd_u32 C (p0Of p.s (tileOf p.s p.mt y z sg) i * p.k) 31 hpk (by decide),
        show (31 : Nat) = 2 ^ 5 - 1 from rfl, Nat.and_two_pow_sub_one_eq_mod])
  have e31 : ∀ L : Locals, (eval C ctx L (DownMmaWide.u32 .mul (DownMmaWide.u32 .mul
      (.component (.coord .threadgroupPositionInGrid) (DownMmaWide.u32l 2)) (DownMmaWide.u32l 8))
      (DownMmaWide.u32l p.mt))).run sh = some (u32 (tileOf p.s p.mt y z sg).mBase, sh) := fun L => by
    rw [ht5, show 8 * p.mt * z = z * 8 * p.mt by ring]
    exact eval_bin_u32 C (eval_bin_u32 C (eval_coord2 C hl.gpos) (eval_u32lit C _ _ 8 (by decide))
      (binary_mul_u32 C z 8)) (eval_u32lit C _ _ _ (by omega)) (binary_mul_u32 C _ _)
  have e33 : ∀ L : Locals, L 19 = some (u32 (tileOf p.s p.mt y z sg).split) → L 32 = some (u32 2176) →
      (eval C ctx L (DownMmaWide.u32 .mul (.local 19) (.local 32))).run sh =
        some (u32 (2176 * (tileOf p.s p.mt y z sg).split), sh) := fun L h19 h32 => by
    rw [Nat.mul_comm]
    exact eval_bin_u32 C (eval_local' C h19 sh) (eval_local' C h32 sh) (binary_mul_u32 C _ _)
  have e34 : ∀ L : Locals, L 33 = some (u32 (2176 * (tileOf p.s p.mt y z sg).split)) → L 32 = some (u32 2176) →
      (eval C ctx L (.bin .min .u32 0 (DownMmaWide.u32l 17408) (DownMmaWide.u32 .add (.local 33) (.local 32)))).run sh =
        some (u32 (2176 * (tileOf p.s p.mt y z sg).split + 2176), sh) := fun L h33 h32 =>
    eval_bin_u32 C (eval_u32lit C _ _ 17408 (by decide))
      (eval_bin_u32 C (eval_local' C h33 sh) (eval_local' C h32 sh)
        (binary_add_u32 C (2176 * (tileOf p.s p.mt y z sg).split) 2176))
      (by rw [binary_min_u32 C 17408 (2176 * (tileOf p.s p.mt y z sg).split + 2176) (by decide) (by omega),
        Nat.min_eq_right (by omega)])
  unfold DownMmaWide.setup
  refine ⟨_, .set (e15 _) <| .set (eval_u32lit C _ _ (32 / p.s) (by omega)) <| .set (e17 _ rfl) <|
    .ite (eite _ rfl rfl) (.nil _ _) <| .set (e18 _ rfl rfl) <| .set (e19 _ rfl rfl) <| .set (e20 _ rfl rfl) <|
    .set (e21 _ rfl rfl) <| .set (e22 _ (Eq.trans rfl hF.l6)) <| .set (e23 _ (Eq.trans rfl hF.l6)) <|
    .set (eval_u32lit C _ _ (8 * p.k) (by omega)) <| .set (e25 _ rfl) <| .set (e26 _ (Eq.trans rfl hF.l2) rfl rfl) <|
    .set (e27 _ rfl rfl) <| .set (e28 _ rfl) <| .set (e29 _ rfl) <| .set (e30 _ rfl) <| .set (e31 _) <|
    .set (eval_u32lit C _ _ 2176 (by decide)) <| .set (e33 _ rfl rfl) <| .set (e34 _ rfl rfl) <| .nil _ _, ?_⟩
  refine ⟨⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  all_goals first
    | rfl
    | exact Eq.trans rfl hF.l0
    | exact Eq.trans rfl hF.l1
    | exact Eq.trans rfl hF.l2
    | exact Eq.trans rfl hF.l3
    | exact Eq.trans rfl hF.l4
    | exact Eq.trans rfl hF.l5
    | exact Eq.trans rfl hF.l6
    | exact Eq.trans rfl hF.l7

end Setup

end Metal.Kernels.DownWideRun

namespace Metal.Kernels.DownWideRun
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis
open Metal.Kernels.DownMmaWide (Tile p0Of fmOf fnOf laneOf eTile ePos eBk eSt eLane eReg outVal expected aReg bReg accReg
  cbHalf xval sval zero rcp Geo nGOf gyOf codesBytes In bufs)

/-! ### The lane's slots and thread memory through the row loop -/

/-- After the declarations before the row loop. -/
structure GLoc (p : Par) (th : Nat) (T : Tile) (i : Nat) (l : Locals) : Prop where
  s : SLoc p T i l
  l35 : l 35 = some (.ptr ⟨ta th 0, 0, .ptr .device (.scalar .bf16)⟩)
  l36 : l 36 = some (.ptr ⟨ta th 1, 0, .vec .f32 2⟩)
  l39 : l 39 = some (.ptr ⟨ta th 2, 0, .scalar .u32⟩)

theorem GLoc.of_eq {p : Par} {th : Nat} {T : Tile} {i : Nat} {l l' : Locals} (h : GLoc p th T i l)
    (h' : ∀ j, j ≤ 39 → l' j = l j) : GLoc p th T i l' :=
  ⟨h.s.of_eq fun j hj => h' j (by omega), (h' 35 (by omega)).trans h.l35, (h' 36 (by omega)).trans h.l36,
    (h' 39 (by omega)).trans h.l39⟩

/-- The first word of row `2176·split + 8n + fm`'s block `block` (`rowCodes`). -/
def rowBase (p : Par) (T : Tile) (i n : Nat) : Nat :=
  DownPartial.dbase p.k p.il (2176 * T.split + 8 * n + fmOf i) T.block

/-- At row step `n`. -/
structure RLoc (p : Par) (th : Nat) (T : Tile) (i n : Nat) (l : Locals) : Prop where
  g : GLoc p th T i l
  l41 : l 41 = some (.ptr ⟨2, ((4 * rowBase p T i n : Nat) : Int), .scalar .u32⟩)
  l42 : l 42 = some (u32 (2176 * T.split + 8 * n))

theorem RLoc.of_eq {p : Par} {th : Nat} {T : Tile} {i n : Nat} {l l' : Locals} (h : RLoc p th T i n l)
    (h' : ∀ j, j ≤ 42 → l' j = l j) : RLoc p th T i n l' :=
  ⟨h.g.of_eq fun j hj => h' j (by omega), (h' 41 (by omega)).trans h.l41, (h' 42 (by omega)).trans h.l42⟩

/-- The `xm` pointers: `x + min(mBase + 8·bk + fm, M - 1)·R`. -/
def XmArr (p : Par) (T : Tile) (i : Nat) (B : ByteMemory.Bytes) : Prop :=
  ∀ b < p.mt, cells B (8 * b) 8 = wordBytes 8 (34816 * min (T.mBase + 8 * b + fmOf i) (p.M - 1))

/-- `wordAt[m] = (w0 + m) % wpb`. -/
def WaArr (p : Par) (T : Tile) (i : Nat) (B : ByteMemory.Bytes) : Prop :=
  ∀ m < p.nw + 1, cells B (4 * m) 4 = wordBytes 4 ((p0Of p.s T i * p.k / 32 + m) % (8 * p.k))

/-- `acc[s'][b]`'s registers of lane `i` after `cnt s' b` row steps. -/
def AccArr (C : M1Max.Contract) (p : Par) (I : In) (T : Tile) (i : Fin 32) (cnt : Nat → Nat → Nat)
    (B : ByteMemory.Bytes) : Prop :=
  ∀ s' < p.s, ∀ b < p.mt, ∀ e : Fin 2, cells B (8 * (s' * p.mt + b) + 4 * e) 4 =
    wordBytes 4 (Val.f32Bits (accReg C p.k p.il p.s p.M I.X I.Cd I.S T s' b (cnt s' b) i e))

/-- A row's code words lie in the codes. -/
theorem rowBase_lt {p : Par} (hp : p.Ok) {T : Tile} {i n j : Nat} (hs : T.split < 8) (hb : T.block < 20)
    (hi : i < 32) (hn : n < 272) (hj : j < 8 * p.k) : rowBase p T i n + j < 17408 * 160 * p.k := by
  have hfm := (lane_fm_fn i hi).2.1
  unfold rowBase
  rw [DownPartial.dbase_eq]
  unfold DownPartial.blockOff DownPartial.roww DownPartial.wpb
  have hk := hp.k
  rcases hp.geo with ⟨h1, -, -, -, h5⟩ | ⟨h1, -, -, -, h5⟩ | ⟨h1, -, -, -, h5⟩ | ⟨h1, -, -, -, h5⟩ | ⟨h1, -, -, -, h5⟩ |
    ⟨h1, -, -, -, h5⟩ | ⟨h1, -, -, -, h5⟩ <;> rw [h1, h5] at ⊢ <;> rw [h1] at hj <;>
    simp only [Bool.false_eq_true, ↓reduceIte] <;> omega


section Init
variable (C : M1Max.Contract) {p : Par} {L : Launch} {I : In} {ge : Nat} {cbOk outOk : Nat → Prop} {ctx : Ctx}
  {y z sg i : Nat}

/-- `acc[s][bk]`: element `s·MT + bk` of thread array `acc` (slot 36). -/
theorem eval_accAt {l : Locals} {sh : Shared} {mt reg a b : Nat} {sE bE : CExpr}
    (h36 : l 36 = some (.ptr ⟨reg, 0, .vec .f32 2⟩)) (hs : (eval C ctx l sE).run sh = some (u32 a, sh))
    (hb : (eval C ctx l bE).run sh = some (u32 b, sh)) (ha : a < 2 ^ 16) (hbl : b < 2 ^ 16) (hmt : mt < 2 ^ 16) :
    (eval C ctx l (DownMmaWide.accAt mt sE bE)).run sh =
      some (.ptr ⟨reg, ((8 * (a * mt + b) : Nat) : Int), .vec .f32 2⟩, sh) := by
  have ham : a * mt < 2 ^ 32 := by have := Nat.mul_lt_mul'' ha hmt; omega
  have h1 := eval_offset_u64 C (ctx := ctx) (o := 0) (n := a * mt) (eval_local' C h36 sh)
    (eval_int C (site := 0) (by decide) (eval_conv C (t := .u64) hs (convert_u64_u32 C _ (by omega)))
      (eval_u64lit C _ _ mt (by omega)) (binary_mul_u64 C _ _)) (by omega)
  have h2 := eval_offset_u32 C (ctx := ctx) h1 hb (by omega)
  rwa [show 0 + a * mt * (Ty.vec .f32 2).bytes + b * (Ty.vec .f32 2).bytes = 8 * (a * mt + b) by
    simp [Ty.bytes, Scalar.bytes]; ring] at h2


/-- The `xm`/`acc` loop: the pointers and zero accumulators. -/
theorem init_loop (hS : Shape L p I) (hp : p.Ok) (hl : Lane p ctx y z sg i) {l : Locals} {sh : Shared}
    (hs : SLoc p (tileOf p.s p.mt y z sg) i l)
    (h35 : l 35 = some (.ptr ⟨ta (thOf p.s y z sg i) 0, 0, .ptr .device (.scalar .bf16)⟩))
    (h36 : l 36 = some (.ptr ⟨ta (thOf p.s y z sg i) 1, 0, .vec .f32 2⟩))
    (hm : Mem C p L I ge cbOk outOk sh) :
    ∃ l' sh', Exec C ctx [.set 37 (.lit (.int .u32 0)),
        .loop (DownMmaWide.lt 37 (DownMmaWide.u32l p.mt)) (DownMmaWide.inc 37) (DownMmaWide.initBlock p.s p.mt)]
        l sh .normal l' sh' ∧ (∀ j, j ≠ 37 → j ≠ 38 → l' j = l j) ∧ Mem C p L I ge cbOk outOk sh' ∧
      Keep (thOf p.s y z sg i) sh sh' ∧ (∀ j, j ≥ 2 → sh'.bytes (ta (thOf p.s y z sg i) j) =
        sh.bytes (ta (thOf p.s y z sg i) j)) ∧
      XmArr p (tileOf p.s p.mt y z sg) i (sh'.bytes (ta (thOf p.s y z sg i) 0)) ∧
      AccArr C p I (tileOf p.s p.mt y z sg) ⟨i, hl.hi⟩ (fun _ _ => 0) (sh'.bytes (ta (thOf p.s y z sg i) 1)) := by
  generalize hT : tileOf p.s p.mt y z sg = T at *
  generalize hth : thOf p.s y z sg i = th at *
  have hmt : 1 ≤ p.mt ∧ p.mt ≤ 3 ∧ 8 ≤ p.s ∧ p.s ≤ 16 := by
    rcases hp.sm with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> rw [h1, h2] <;> decide
  have hM := hp.m2; have hM1 := hp.m1
  have hfm := (lane_fm_fn i hl.hi).2.1
  have hmB : T.mBase < p.M := by rw [← hT]; exact (tile_facts hp hl.hy hl.hz hl.hsg).2.2.2.1
  let J : Nat → Locals → Shared → Prop := fun n l' sh' => (∀ j, j ≠ 37 → j ≠ 38 → l' j = l j) ∧
    l' 37 = some (u32 n) ∧ Mem C p L I ge cbOk outOk sh' ∧ Keep th sh sh' ∧
    (∀ j, j ≥ 2 → sh'.bytes (ta th j) = sh.bytes (ta th j)) ∧
    (∀ b < n, cells (sh'.bytes (ta th 0)) (8 * b) 8 = wordBytes 8 (34816 * min (T.mBase + 8 * b + fmOf i) (p.M - 1))) ∧
    ∀ s' < p.s, ∀ b < n, ∀ e : Fin 2, cells (sh'.bytes (ta th 1)) (8 * (s' * p.mt + b) + 4 * e) 4 =
      wordBytes 4 (Val.f32Bits zero)
  obtain ⟨l', sh', hex, hJ⟩ := Exec.loop_count (ctx := ctx) (C := C) (c := DownMmaWide.lt 37 (DownMmaWide.u32l p.mt)) (st := DownMmaWide.inc 37)
    (b := DownMmaWide.initBlock p.s p.mt) p.mt J J
    (fun n hn l' sh' hJ => ⟨sh', by
      have := eval_lt_u32 C (ctx := ctx) (sh := sh') (b := p.mt) hJ.2.1 (by omega) (by omega)
      exact this, hJ⟩)
    (fun n hn l' sh' hJ => by
      obtain ⟨hag, h37, hm', hk, hfr, hxm, hacc⟩ := hJ
      have hreg := hm'.regions
      -- `xm[bk]`
      have hrow : min (T.mBase + 8 * n + fmOf i) (p.M - 1) < 2 ^ 24 := by omega
      have hptr : (eval C ctx l' (DownMmaWide.ptrAt 35 (.local 37))).run sh' =
          some (.ptr ⟨ta th 0, ((8 * n : Nat) : Int), .ptr .device (.scalar .bf16)⟩, sh') := by
        have := eval_ptr_u32 C (ctx := ctx) (eval_local' C (by rw [hag 35 (by omega) (by omega)]; exact h35) sh')
          (eval_local' C h37 sh') (by omega)
        rwa [show n * (Ty.ptr .device (.scalar .bf16)).bytes = 8 * n by simp [Ty.bytes]; ring] at this
      have hval : (eval C ctx l' (.offset (.local 0) (DownMmaWide.u64 .mul (DownMmaWide.toU64 (.bin .min .u32 0
          (DownMmaWide.u32 .add (DownMmaWide.u32 .add (.local 31) (DownMmaWide.u32 .mul (DownMmaWide.u32l 8) (.local 37)))
            (.local 22)) (DownMmaWide.u32 .sub (.local 5) (DownMmaWide.u32l 1)))) (DownMmaWide.u64l 17408)))).run sh' =
          some (.ptr ⟨0, ((34816 * min (T.mBase + 8 * n + fmOf i) (p.M - 1) : Nat) : Int), .scalar .bf16⟩, sh') := by
        have hl' : ∀ j, j < 37 → l' j = l j := fun j hj => hag j (by omega) (by omega)
        have hmin := eval_bin_u32 C (ctx := ctx) (l := l') (sh := sh') (op := .min) (site := 0)
          (a := DownMmaWide.u32 .add (DownMmaWide.u32 .add (.local 31) (DownMmaWide.u32 .mul (DownMmaWide.u32l 8)
            (.local 37))) (.local 22)) (b := DownMmaWide.u32 .sub (.local 5) (DownMmaWide.u32l 1))
          (eval_bin_u32 C (eval_bin_u32 C (eval_local' C (by rw [hl' 31 (by omega)]; exact hs.l31) sh')
            (eval_bin_u32 C (eval_u32lit C _ _ 8 (by decide)) (eval_local' C h37 sh') (binary_mul_u32 C 8 n))
            (binary_add_u32 C _ _)) (eval_local' C (by rw [hl' 22 (by omega)]; exact hs.l22) sh') (binary_add_u32 C _ _))
          (eval_bin_u32 C (eval_local' C (by rw [hl' 5 (by omega)]; exact hs.fix.l5) sh') (eval_u32lit C _ _ 1 (by decide))
            (binary_sub_u32 C p.M 1 (by omega)))
          (binary_min_u32 C (T.mBase + 8 * n + fmOf i) (p.M - 1) (by omega) (by omega))
        have := eval_offset_u64 C (ctx := ctx) (o := 0) (eval_local' C (by rw [hl' 0 (by omega)]; exact hs.fix.l0) sh')
          (eval_int C (site := 0) (by decide) (eval_conv C (t := .u64) hmin (convert_u64_u32 C _ (by omega)))
            (eval_u64lit C _ _ 17408 (by decide)) (binary_mul_u64 C _ _)) (by omega)
        rwa [show 0 + min (T.mBase + 8 * n + fmOf i) (p.M - 1) * 17408 * (Ty.scalar .bf16).bytes =
          34816 * min (T.mBase + 8 * n + fmOf i) (p.M - 1) by simp [Ty.bytes, Scalar.bytes]; ring] at this
      have hst := store_ptr_x (ctx := ctx) (sh := sh') (reg := ta th 0) (size := 8 * p.mt) (o := 8 * n)
        (by rw [hreg]; exact hS.t0 th) (by omega) (by omega) (show 34816 * min (T.mBase + 8 * n + fmOf i) (p.M - 1) < 2 ^ 40 by omega)
      have hxw := pairBytes_length zero zero
      -- after `xm[bk]`: the inner loop over `s`
      let K : Nat → Locals → Shared → Prop := fun m l'' sh'' => (∀ j, j ≠ 37 → j ≠ 38 → l'' j = l j) ∧
        l'' 37 = some (u32 n) ∧ l'' 38 = some (u32 m) ∧ Mem C p L I ge cbOk outOk sh'' ∧ Keep th sh sh'' ∧
        (∀ j, j ≥ 2 → sh''.bytes (ta th j) = sh.bytes (ta th j)) ∧
        (∀ b < n + 1, cells (sh''.bytes (ta th 0)) (8 * b) 8 =
          wordBytes 8 (34816 * min (T.mBase + 8 * b + fmOf i) (p.M - 1))) ∧
        ∀ s' < p.s, ∀ b, ∀ e : Fin 2, (b < n ∨ (b = n ∧ s' < m)) →
          cells (sh''.bytes (ta th 1)) (8 * (s' * p.mt + b) + 4 * e) 4 = wordBytes 4 (Val.f32Bits zero)
      have hK0 : K 0 (setLocal l' 38 (u32 0)) (tput sh' (ta th 0) (8 * n)
          (wordBytes 8 (34816 * min (T.mBase + 8 * n + fmOf i) (p.M - 1)))) := by
        refine ⟨fun j h1 h2 => by rw [setLocal_other _ _ h2]; exact hag j h1 h2,
          by rw [setLocal_other _ _ (by omega)]; exact h37, setLocal_same _ _ _, hm'.tput _ _ (by unfold ta; omega),
          hk.tput (by unfold ta; omega) _ _, fun j hj => by rw [tput_other _ _ _ (by unfold ta; omega)]; exact hfr j hj,
          fun b hb => ?_, fun s' hs' b e hb => ?_⟩
        · rw [tput_same]
          by_cases hbn : b = n
          · subst hbn
            have := cells_writeBytes_same (sh'.bytes (ta th 0)) (8 * b)
              (wordBytes 8 (34816 * min (T.mBase + 8 * b + fmOf i) (p.M - 1)))
            rwa [wordBytes_length] at this
          · rw [cells_writeBytes_other _ _ _ _ _ (by rw [wordBytes_length]; omega)]
            exact hxm b (by omega)
        · rw [tput_other _ _ _ (by unfold ta; omega)]
          rcases hb with hb | ⟨-, hb⟩
          · exact hacc s' hs' b hb e
          · omega
      obtain ⟨l₂, sh₂, hex₂, hK⟩ := Exec.loop_count (ctx := ctx) (C := C) (c := DownMmaWide.lt 38 (DownMmaWide.u32l p.s))
        (st := DownMmaWide.inc 38) (b := [.store (.vec .f32 2) (DownMmaWide.accAt p.mt (.local 38) (.local 37))
          (.vector .f32 [DownMmaWide.f32l 0, DownMmaWide.f32l 0])]) p.s K K
        (fun m hm l'' sh'' hK => ⟨sh'', by
          have := eval_lt_u32 C (ctx := ctx) (sh := sh'') (b := p.s) hK.2.2.1 (by omega) (by omega)
          exact this, hK⟩)
        (fun m hm l'' sh'' hK => by
          obtain ⟨hag', h37', h38', hm'', hk', hfr', hxm', hacc'⟩ := hK
          have hreg := hm''.regions
          have hpa := eval_accAt C (ctx := ctx) (l := l'') (sh := sh'') (mt := p.mt) (sE := .local 38)
            (bE := .local 37) (by rw [hag' 36 (by omega) (by omega)]; exact h36) (eval_local' C h38' sh'')
            (eval_local' C h37' sh'') (by omega) (by omega) (by omega)
          have hv : (eval C ctx l'' (.vector .f32 [DownMmaWide.f32l 0, DownMmaWide.f32l 0])).run sh'' =
              some (.vec .f32 [.f32 zero, .f32 zero], sh'') :=
            eval_vector C (evalList_cons C (eval_lit C _ _ _ _) (evalList_cons C (eval_lit C _ _ _ _) (evalList_nil C)))
          have hst2 := store_pair_f32 (ctx := ctx) (sh := sh'') (reg := ta th 1) (size := 8 * (p.s * p.mt))
            (o := 8 * (m * p.mt + n)) zero zero (by rw [hreg]; exact hS.t1 th) (by omega)
            (by have := idx_lt (a := p.s) hm hn; omega)
          refine ⟨.normal, l'', _, setLocal l'' 38 (u32 (m + 1)), _, .inl rfl, .store hpa hv hst2 (.nil _ _),
            .set (eval_bin_u32 C (eval_local' C h38' _) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C m 1))
              (.nil _ _), fun j h1 h2 => by rw [setLocal_other _ _ h2]; exact hag' j h1 h2,
            by rw [setLocal_other _ _ (by omega)]; exact h37', setLocal_same _ _ _, hm''.tput _ _ (by unfold ta; omega),
            hk'.tput (by unfold ta; omega) _ _, fun j hj => by rw [tput_other _ _ _ (by unfold ta; omega)]; exact hfr' j hj,
            fun b hb => by rw [tput_other _ _ _ (by unfold ta; omega)]; exact hxm' b hb, fun s' hs' b e hb => ?_⟩
          rw [tput_same]
          by_cases hsb : s' = m ∧ b = n
          · obtain ⟨rfl, rfl⟩ := hsb
            rcases e with ⟨_ | _ | _, he⟩
            · simpa using pairBytes_lo (sh''.bytes (ta th 1)) (8 * (s' * p.mt + b)) zero zero
            · simpa using pairBytes_hi (sh''.bytes (ta th 1)) (8 * (s' * p.mt + b)) zero zero
            · omega
          · have hbm : b < p.mt := by rcases hb with h | ⟨h, -⟩ <;> omega
            have hne : s' * p.mt + b ≠ m * p.mt + n := fun h => hsb (idx_inj hbm hn h)
            have he2 := e.isLt
            rw [cells_writeBytes_other _ _ _ _ _ (by rw [pairBytes_length]; omega)]
            exact hacc' s' hs' b e (by omega))
        hK0
      obtain ⟨hag₂, h37₂, -, hm₂, hk₂, hfr₂, hxm₂, hacc₂⟩ := hK
      refine ⟨.normal, l₂, sh₂, setLocal l₂ 37 (u32 (n + 1)), sh₂, .inl rfl, ?_,
        .set (eval_bin_u32 C (eval_local' C h37₂ _) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C n 1)) (.nil _ _),
        fun j h1 h2 => by rw [setLocal_other _ _ h1]; exact hag₂ j h1 h2, setLocal_same _ _ _, hm₂, hk₂, hfr₂, hxm₂,
        fun s' hs' b hb e => hacc₂ s' hs' b e (by omega)⟩
      exact .store hptr hval hst (.set (eval_u32lit C _ _ 0 (by decide)) hex₂))
    (l := setLocal l 37 (u32 0)) (sh := sh)
    ⟨fun j h1 _ => setLocal_other _ _ h1, setLocal_same _ _ _, hm, Keep.refl _ _, fun _ _ => rfl,
      fun b hb => absurd hb (by omega), fun _ _ b hb => absurd hb (by omega)⟩
  obtain ⟨hag, -, hm', hk, hfr, hxm, hacc⟩ := hJ
  refine ⟨l', sh', .set (eval_u32lit C _ _ 0 (by decide)) hex, hag, hm', hk, hfr, hxm, fun s' hs' b hb e => ?_⟩
  rw [hacc s' hs' b hb e]; rfl

theorem initPart_eq (s mt nw : Nat) : DownMmaWide.initPart s mt nw =
    [.array 35 false 0 (.ptr .device (.scalar .bf16)), .array 36 false 1 (.vec .f32 2)] ++
      ([.set 37 (.lit (.int .u32 0)), .loop (DownMmaWide.lt 37 (DownMmaWide.u32l mt)) (DownMmaWide.inc 37)
        (DownMmaWide.initBlock s mt)] ++ ([.array 39 false 2 (.scalar .u32)] ++
      ([.set 40 (.lit (.int .u32 0)), .loop (DownMmaWide.u32 .le (.local 40) (DownMmaWide.u32l nw)) [.set 40 (.bin .add .u32 0
        (.local 40) (.lit (.int .u32 1)))] [.store (.scalar .u32) (.offset (.local 39) (.local 40))
        (DownMmaWide.u32 .rem (DownMmaWide.u32 .add (.local 29) (.local 40)) (.local 24))]] ++
      [.set 41 DownMmaWide.rowCodes0, .set 42 (.local 33)]))) := rfl

/-- The declarations before the row loop: `xm`, `acc` zeroed, `wordAt`, `rowCodes`, `r = r0`. -/
theorem lane_init (hS : Shape L p I) (hp : p.Ok) (hl : Lane p ctx y z sg i) {l : Locals} {sh : Shared}
    (hs : SLoc p (tileOf p.s p.mt y z sg) i l) (hm : Mem C p L I ge cbOk outOk sh) :
    ∃ l' sh', Exec C ctx (DownMmaWide.initPart p.s p.mt p.nw) l sh .normal l' sh' ∧
      RLoc p (thOf p.s y z sg i) (tileOf p.s p.mt y z sg) i 0 l' ∧ Mem C p L I ge cbOk outOk sh' ∧
      Keep (thOf p.s y z sg i) sh sh' ∧
      (∀ j, j ≥ 3 → sh'.bytes (ta (thOf p.s y z sg i) j) = sh.bytes (ta (thOf p.s y z sg i) j)) ∧
      XmArr p (tileOf p.s p.mt y z sg) i (sh'.bytes (ta (thOf p.s y z sg i) 0)) ∧
      AccArr C p I (tileOf p.s p.mt y z sg) ⟨i, hl.hi⟩ (fun _ _ => 0) (sh'.bytes (ta (thOf p.s y z sg i) 1)) ∧
      WaArr p (tileOf p.s p.mt y z sg) i (sh'.bytes (ta (thOf p.s y z sg i) 2)) := by
  have hk := hp.k; have hnw := hp.nw
  generalize hl₁ : setLocal (setLocal l 35 (.ptr ⟨ta (thOf p.s y z sg i) 0, 0, .ptr .device (.scalar .bf16)⟩)) 36
    (.ptr ⟨ta (thOf p.s y z sg i) 1, 0, .vec .f32 2⟩) = l₁
  have x1 : Exec C ctx [.array 35 false 0 (.ptr .device (.scalar .bf16)), .array 36 false 1 (.vec .f32 2)] l sh .normal
      l₁ sh := by
    rw [← hl₁]; refine .array (.array ?_); simp only [Bool.false_eq_true, ite_false, hl.ta]; exact .nil _ _
  have hs₁ : SLoc p (tileOf p.s p.mt y z sg) i l₁ := hs.of_eq fun j hj => by
    rw [← hl₁, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
  obtain ⟨l₂, sh₂, x2, hag₂, hm₂, hk₂, hfr₂, hxm₂, hacc₂⟩ := init_loop C hS hp hl hs₁
    (by rw [← hl₁, setLocal_other _ _ (by omega), setLocal_same])
    (by rw [← hl₁, setLocal_same]) hm
  generalize hth : thOf p.s y z sg i = th at *
  generalize hT : tileOf p.s p.mt y z sg = T at *
  have hs₂ : SLoc p T i l₂ := hs₁.of_eq fun j hj => hag₂ j (by omega) (by omega)
  generalize hl₃ : setLocal l₂ 39 (.ptr ⟨ta th 2, 0, .scalar .u32⟩) = l₃
  have x3 : Exec C ctx [.array 39 false 2 (.scalar .u32)] l₂ sh₂ .normal l₃ sh₂ := by
    rw [← hl₃]; refine .array ?_; simp only [Bool.false_eq_true, ite_false, hl.ta, hth]; exact .nil _ _
  have h29 : l₃ 29 = some (u32 (p0Of p.s T i * p.k / 32)) := by rw [← hl₃, setLocal_other _ _ (by omega)]; exact hs₂.l29
  have h24 : l₃ 24 = some (u32 (8 * p.k)) := by rw [← hl₃, setLocal_other _ _ (by omega)]; exact hs₂.l24
  have hw0 : p0Of p.s T i * p.k / 32 < 2 ^ 16 := by
    have : p0Of p.s T i + 2 * p.s ≤ 256 := by
      rw [← hT]; simp only [p0Of, tileOf]
      have hq := (tile_facts hp hl.hy hl.hz hl.hsg).2.2.1
      simp only [tileOf] at hq
      have hfn := (lane_fm_fn i hl.hi).2.2.2
      rcases hp.sm with ⟨h1, -⟩ | ⟨h1, -⟩ | ⟨h1, -⟩ <;> rw [h1] at hq ⊢ <;> omega
    have : p0Of p.s T i * p.k ≤ 256 * 4 := Nat.mul_le_mul (by omega) hk.2
    omega
  obtain ⟨l₄, sh₄, x4, hm₄, hag₄, hoth₄, -, hwa₄⟩ := exec_fill32 C (ctx := ctx)
    (Inv := fun sh' => Mem C p L I ge cbOk outOk sh') (reg := ta th 2) (l := l₃) (sh := sh₂) (size := 4 * (p.nw + 1))
    (fun sh o bs h => h.tput o bs (by unfold ta; omega)) (p.nw + 1) 40 39 0
    (DownMmaWide.u32 .le (.local 40) (DownMmaWide.u32l p.nw))
    (DownMmaWide.u32 .rem (DownMmaWide.u32 .add (.local 29) (.local 40)) (.local 24))
    (fun m => (p0Of p.s T i * p.k / 32 + m) % (8 * p.k))
    (fun l' sh' m _ hm hc _ _ => by
      have := eval_bin_u32 C (ctx := ctx) (l := l') (sh := sh') (op := .le) (site := 0) (eval_local' C hc sh')
        (eval_u32lit C _ _ p.nw (by omega)) (binary_le_u32 C m p.nw (by omega) (by omega))
      rwa [show decide (m ≤ p.nw) = decide (m < p.nw + 1) from decide_eq_decide.mpr (by omega)] at this)
    (fun l' sh' m _ hm hc hag hI => ⟨sh', eval_bin_u32 C (eval_bin_u32 C
      (eval_local' C (by rw [hag 29 (by omega)]; exact h29) sh') (eval_local' C hc sh') (binary_add_u32 C _ m))
      (eval_local' C (by rw [hag 24 (by omega)]; exact h24) sh') (binary_rem_u32 C _ _ (by omega) (by omega) (by omega)),
      hI, rfl⟩)
    (fun m => by have := Nat.mod_lt (p0Of p.s T i * p.k / 32 + m) (show 0 < 8 * p.k by omega); omega)
    (by rw [← hl₃, setLocal_same]) (by decide) (fun sh' h => by rw [h.regions]; exact hS.t2 th) le_rfl (by omega)
    (by omega) hm₂
  -- `rowCodes`, `r`
  have hl₄ : ∀ j, j ≠ 40 → l₄ j = l₃ j := hag₄
  have hs₄ : SLoc p T i l₄ := hs₂.of_eq fun j hj => by rw [hl₄ j (by omega), ← hl₃, setLocal_other _ _ (by omega)]
  have hfm := (lane_fm_fn i hl.hi).2.1
  have hsplit := (tile_facts hp hl.hy hl.hz hl.hsg).1
  rw [hT] at hsplit
  have hrb : rowBase p T i 0 + 8 * p.k ≤ 17408 * 160 * p.k := by
    have := rowBase_lt hp (T := T) (i := i) (n := 0) (j := 8 * p.k - 1) hsplit (by rw [← hT]; exact
      (tile_facts hp hl.hy hl.hz hl.hsg).2.1) hl.hi (by decide) (by omega)
    omega
  have hr41 : (eval C ctx l₄ DownMmaWide.rowCodes0).run sh₄ =
      some (.ptr ⟨2, ((4 * rowBase p T i 0 : Nat) : Int), .scalar .u32⟩, sh₄) := by
    have hmul := eval_int C (ctx := ctx) (l := l₄) (sh := sh₄) (op := .mul) (s := .u64) (site := 0) (by decide)
      (eval_conv C (t := .u64) (eval_bin_u32 C (site := 0) (eval_local' C hs₄.l33 sh₄) (eval_local' C hs₄.l22 sh₄)
        (binary_add_u32 C _ _)) (convert_u64_u32 C _ (by omega))) (eval_local' C hs₄.l25 sh₄) (binary_mul_u64 C _ _)
    have hroww : DownPartial.roww p.k p.il ≤ 640 := by
      have := hp.k; unfold DownPartial.roww DownPartial.wpb; split <;> omega
    have hprod : (2176 * T.split + fmOf i) * DownPartial.roww p.k p.il ≤ 17408 * 640 := Nat.mul_le_mul (by omega) hroww
    have := eval_offset_u64 C (ctx := ctx) (eval_local' C hs₄.l26 sh₄) hmul (by omega)
    unfold rowBase
    rw [DownPartial.dbase_eq, show 2176 * T.split + 8 * 0 + fmOf i = 2176 * T.split + fmOf i by omega]
    rwa [show 4 * DownPartial.blockOff p.k p.il T.block + (2176 * T.split + fmOf i) * DownPartial.roww p.k p.il *
      (Ty.scalar .u32).bytes = 4 * (DownPartial.blockOff p.k p.il T.block + (2176 * T.split + fmOf i) *
      DownPartial.roww p.k p.il) by simp [Ty.bytes, Scalar.bytes]; ring] at this
  refine ⟨setLocal (setLocal l₄ 41 (.ptr ⟨2, ((4 * rowBase p T i 0 : Nat) : Int), .scalar .u32⟩)) 42
    (u32 (2176 * T.split)), sh₄, ?_, ⟨⟨hs₄.of_eq fun j hj => by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)], ?_, ?_, ?_⟩, by simp [setLocal], by simp [setLocal]⟩, hm₄, ?_, ?_, ?_, ?_, ?_⟩
  · rw [initPart_eq]
    exact x1.append (x2.append (x3.append (x4.append (.set hr41 (.set (eval_local' C (by
      rw [setLocal_other _ _ (by omega)]; exact hs₄.l33) _) (.nil _ _))))))
  · rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), hl₄ 35 (by omega), ← hl₃, setLocal_other _ _ (by omega), hag₂ 35 (by omega) (by omega),
      ← hl₁, setLocal_other _ _ (by omega), setLocal_same]
  · rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), hl₄ 36 (by omega), ← hl₃, setLocal_other _ _ (by omega), hag₂ 36 (by omega) (by omega),
      ← hl₁, setLocal_same]
  · rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), hl₄ 39 (by omega), ← hl₃, setLocal_same]
  · intro R hR h4
    by_cases hR2 : R = ta th 2
    · subst hR2; unfold ta at hR; omega
    · rw [hoth₄ R hR2]; exact hk₂ R hR h4
  · intro j hj
    rw [hoth₄ _ (by unfold ta; omega)]; exact hfr₂ j (by omega)
  · intro b hb; rw [hoth₄ _ (by unfold ta; omega)]; exact hxm₂ b hb
  · intro s' hs' b hb e; rw [hoth₄ _ (by unfold ta; omega)]; exact hacc₂ s' hs' b hb e
  · intro m hm; exact hwa₄ m (by omega) hm

end Init

end Metal.Kernels.DownWideRun

namespace Metal.Kernels.DownWideRun
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis
open Metal.Kernels.DownMmaWide (Tile p0Of fmOf fnOf laneOf eTile ePos eBk eSt eLane eReg outVal expected aReg bReg accReg
  cbHalf xval sval zero rcp Geo nGOf gyOf codesBytes In bufs)

/-! ### A row's words -/

/-- `raw[m] = rowCodes[wordAt[m]]` of row step `n`. -/
def rawW (p : Par) (Cd : ByteMemory.Bytes) (T : Tile) (i n m : Nat) : Nat :=
  word32 Cd (rowBase p T i n + (p0Of p.s T i * p.k / 32 + m) % (8 * p.k))
/-- `w[m]`: the raw words moved down `off0` bits. -/
def wW (p : Par) (Cd : ByteMemory.Bytes) (T : Tile) (i n m : Nat) : Nat :=
  runBits (rawW p Cd T i n) (p.nw + 1) / 2 ^ (p0Of p.s T i * p.k % 32) / 2 ^ (32 * m) % 2 ^ 32
/-- `v[m]`: the words moved up 16 bits. -/
def vW (p : Par) (Cd : ByteMemory.Bytes) (T : Tile) (i n m : Nat) : Nat :=
  runBits (wW p Cd T i n) p.nw * 2 ^ 16 / 2 ^ (32 * m) % 2 ^ 32

def WArr (p : Par) (Cd : ByteMemory.Bytes) (T : Tile) (i n : Nat) (B : ByteMemory.Bytes) : Prop :=
  ∀ m < p.nw, cells B (4 * m) 4 = wordBytes 4 (wW p Cd T i n m)
def VArr (p : Par) (Cd : ByteMemory.Bytes) (T : Tile) (i n : Nat) (B : ByteMemory.Bytes) : Prop :=
  ∀ m, 1 ≤ m → m < p.nw → cells B (4 * m) 4 = wordBytes 4 (vW p Cd T i n m)
def AArr (C : M1Max.Contract) (p : Par) (I : In) (T : Tile) (i : Fin 32) (n : Nat) (B : ByteMemory.Bytes) : Prop :=
  ∀ b < p.mt, ∀ e : Fin 2, cells B (8 * b + 4 * e) 4 = wordBytes 4 (Val.f32Bits (aReg C p.M I.X I.S T n b i e))
def BArr (C : M1Max.Contract) (p : Par) (I : In) (T : Tile) (i : Fin 32) (n st : Nat) (B : ByteMemory.Bytes) : Prop :=
  ∀ e : Fin 2, cells B (2 * e) 2 = wordBytes 2 (Val.f16Bits (bReg C p.k p.il p.s I.Cd T n st i e))

theorem rawW_lt (p : Par) (Cd : ByteMemory.Bytes) (T : Tile) (i n m : Nat) : rawW p Cd T i n m < 2 ^ 32 :=
  word32_lt _ _
theorem wW_lt (p : Par) (Cd : ByteMemory.Bytes) (T : Tile) (i n m : Nat) : wW p Cd T i n m < 2 ^ 32 :=
  Nat.mod_lt _ (by decide)
theorem vW_lt (p : Par) (Cd : ByteMemory.Bytes) (T : Tile) (i n m : Nat) : vW p Cd T i n m < 2 ^ 32 :=
  Nat.mod_lt _ (by decide)

/-- The state `block_state(w, v, t)` reads: the trellis state of position `p0 + t` of the row's block. -/
theorem state_eq {p : Par} (hp : p.Ok) (Cd : ByteMemory.Bytes) (T : Tile) (i n t : Nat)
    (hp0 : p0Of p.s T i + 2 * p.s ≤ 256) (ht : t < 2 * p.s) :
    runBits (wW p Cd T i n) p.nw / 2 ^ (t * p.k) % 2 ^ 12 =
      trellisCode p.k Cd (rowBase p T i n) (255 - (p0Of p.s T i + t)) := by
  obtain ⟨hn1, hn2, hn3⟩ := hp.nw
  have hk := hp.k
  have htk : t * p.k + 12 ≤ 32 * p.nw := by
    have : t * p.k ≤ (2 * p.s - 1) * p.k := Nat.mul_le_mul_right _ (by omega)
    omega
  unfold wW
  rw [runBits_words, window_mod _ _ _ htk, Nat.div_div_eq_div_mul, ← Nat.pow_add]
  unfold rawW trellisCode
  have h1 : p0Of p.s T i * p.k % 32 + t * p.k + 12 ≤ 32 * (p.nw + 1) := by
    have := Nat.mod_lt (p0Of p.s T i * p.k) (show 0 < 32 by decide); omega
  have h2 : p.k * (p0Of p.s T i + t) + 12 ≤ 32 * (8 * p.k + 1) := by
    have : p0Of p.s T i + t ≤ 255 := by omega
    have : p.k * (p0Of p.s T i + t) ≤ p.k * 255 := Nat.mul_le_mul_left _ this
    omega
  rw [state_window Cd (rowBase p T i n) (p0Of p.s T i) t p.nw h1 h2,
    show 255 - (255 - (p0Of p.s T i + t)) = p0Of p.s T i + t by omega]

section Exprs
variable (C : M1Max.Contract) {ctx : Ctx}


/-- A thread-array `uint` element. -/
theorem eval_ld32 {l : Locals} {sh : Shared} {ptr reg size m w : Nat} {iE : CExpr}
    (hp : l ptr = some (.ptr ⟨reg, 0, .scalar .u32⟩)) (hi : (eval C ctx l iE).run sh = some (u32 m, sh))
    (hr : sh.regions reg = some ⟨.thread, size, 4⟩) (hm : 4 * m + 4 ≤ size) (hw : cells (sh.bytes reg) (4 * m) 4 = wordBytes 4 w)
    (hml : m < 2 ^ 32 := by omega) :
    (eval C ctx l (.load (.scalar .u32) (.offset (.local ptr) iE))).run sh = some (u32 w, sh) := by
  have hpt := eval_ptr_u32 C (ctx := ctx) (eval_local' C hp sh) hi (by omega)
  rw [show m * (Ty.scalar .u32).bytes = 4 * m by simp [Ty.bytes, Scalar.bytes]; ring] at hpt
  rw [eval_load C _ _ _ _ _ _ _ hpt, load_thread ctx .u32 sh reg (4 * m) size 4 hr (by decide)
    (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega)]
  simp only [Scalar.bytes]
  rw [hw, ofWord_u32]

/-- **`block_state<K, 12>(w, v, t)`**, with `w`, `v`, `t` in slots `b … b + 2`: bits `t·K …` of the words. -/
theorem exec_blockState (k b : Nat) {l : Locals} {sh : Shared} {rw rv nw t : Nat} {W : Nat → Nat}
    (hw : l b = some (.ptr ⟨rw, 0, .scalar .u32⟩)) (hv : l (b + 1) = some (.ptr ⟨rv, 0, .scalar .u32⟩))
    (ht : l (b + 2) = some (u32 t)) (hrw : sh.regions rw = some ⟨.thread, 4 * nw, 4⟩)
    (hrv : sh.regions rv = some ⟨.thread, 4 * nw, 4⟩) (hW : ∀ m < nw, W m < 2 ^ 32)
    (hwc : ∀ m < nw, cells (sh.bytes rw) (4 * m) 4 = wordBytes 4 (W m))
    (hvc : ∀ m, 1 ≤ m → m < nw → cells (sh.bytes rv) (4 * m) 4 = wordBytes 4 (runBits W nw * 2 ^ 16 / 2 ^ (32 * m) % 2 ^ 32))
    (hk : k < 2 ^ 8) (htl : t < 2 ^ 16) (htk : t * k + 16 < 32 * nw) :
    ∃ l', Exec C ctx [DownMmaWide.blockState k b] l sh .normal l' sh ∧
      l' (b + 3) = some (u32 (runBits W nw / 2 ^ (t * k) % 2 ^ 12)) ∧ ∀ j, j < b + 3 ∨ b + 6 < j → l' j = l j := by
  have hB : t * k < 2 ^ 24 := by have := Nat.mul_lt_mul'' htl hk; omega
  generalize hBdef : t * k = B at *
  have hB32 : B < 2 ^ 32 := by omega
  have e4 : (eval C ctx l (DownMmaWide.u32 .mul (.local (b + 2)) (DownMmaWide.u32l k))).run sh = some (u32 B, sh) := by
    rw [← hBdef]; exact eval_bin_u32 C (eval_local' C ht sh) (eval_u32lit C _ _ k (by omega)) (binary_mul_u32 C t k)
  generalize hl₁ : setLocal l (b + 4) (u32 B) = l₁
  have h4 : l₁ (b + 4) = some (u32 B) := by rw [← hl₁, setLocal_same]
  have e5 : (eval C ctx l₁ (DownMmaWide.u32 .bitAnd (.local (b + 4)) (DownMmaWide.u32l 31))).run sh =
      some (u32 (B % 32), sh) :=
    eval_bin_u32 C (eval_local' C h4 sh) (eval_u32lit C _ _ 31 (by decide))
      (by rw [binary_bitAnd_u32 C B 31 hB32 (by decide), show (31 : Nat) = 2 ^ 5 - 1 from rfl, Nat.and_two_pow_sub_one_eq_mod])
  generalize hl₂ : setLocal l₁ (b + 5) (u32 (B % 32)) = l₂
  have h5 : l₂ (b + 5) = some (u32 (B % 32)) := by rw [← hl₂, setLocal_same]
  have h4' : l₂ (b + 4) = some (u32 B) := by rw [← hl₂, setLocal_other _ _ (by omega)]; exact h4
  have hlb : ∀ j, j < b + 3 ∨ b + 6 < j → l₂ j = l j := fun j hj => by
    rw [← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_other _ _ (by omega)]
  have ec : (eval C ctx l₂ (DownMmaWide.u32 .le (DownMmaWide.u32 .add (.local (b + 5)) (DownMmaWide.u32l 12))
      (DownMmaWide.u32l 32))).run sh = some (.bool (decide (B % 32 + 12 ≤ 32)), sh) :=
    eval_bin_u32 C (eval_bin_u32 C (eval_local' C h5 sh) (eval_u32lit C _ _ 12 (by decide)) (binary_add_u32 C _ 12))
      (eval_u32lit C _ _ 32 (by decide)) (binary_le_u32 C _ 32 (by omega) (by decide))
  by_cases hin : B % 32 + 12 ≤ 32
  · rw [decide_eq_true hin] at ec
    have hm : B / 32 < nw := by omega
    have hWm := hW _ hm
    have eld : (eval C ctx l₂ (.load (.scalar .u32) (.offset (.local b)
        (DownMmaWide.u32 .shr (.local (b + 4)) (DownMmaWide.u32l 5))))).run sh = some (u32 (W (B / 32)), sh) :=
      eval_ld32 C (by rw [hlb b (.inl (by omega))]; exact hw)
        (eval_bin_u32 C (eval_local' C h4' sh) (eval_u32lit C _ _ 5 (by decide))
          (by rw [binary_shr_u32 C B 5 hB32 (by decide)]; rfl)) hrw (by omega) (hwc _ hm)
    have ef : (eval C ctx l₂ (DownMmaWide.u32 .bitAnd (DownMmaWide.u32 .shr (.load (.scalar .u32) (.offset (.local b)
        (DownMmaWide.u32 .shr (.local (b + 4)) (DownMmaWide.u32l 5)))) (.local (b + 5))) (DownMmaWide.u32l 4095))).run sh =
        some (u32 (runBits W nw / 2 ^ B % 2 ^ 12), sh) := by
      refine eval_bin_u32 C (eval_bin_u32 C eld (eval_local' C h5 sh) (binary_shr_u32 C _ _ hWm (by omega)))
        (eval_u32lit C _ _ 4095 (by decide)) ?_
      rw [binary_bitAnd_u32 C _ 4095 (lt_of_le_of_lt (Nat.div_le_self _ _) hWm) (by decide),
        show (4095 : Nat) = 2 ^ 12 - 1 from rfl, Nat.and_two_pow_sub_one_eq_mod, ← runBits_word hW _ hm,
        field_in_word _ _ hin]
    refine ⟨setLocal l₂ (b + 3) (u32 (runBits W nw / 2 ^ B % 2 ^ 12)), ?_, setLocal_same _ _ _,
      fun j hj => by rw [setLocal_other _ _ (by omega), hlb j hj]⟩
    unfold DownMmaWide.blockState
    refine .scope (o₁ := .leave) ?_ (.inr rfl) (.nil _ _)
    exact .set e4 (by rw [hl₁]; exact .set e5 (by rw [hl₂]; exact .ite_exit ec (.set ef .leave) (.inr (.inr rfl))))
  · rw [decide_eq_false hin] at ec
    have hvi : (B + 16) / 32 < nw ∧ 1 ≤ (B + 16) / 32 := by omega
    have e6 : (eval C ctx l₂ (DownMmaWide.u32 .shr (DownMmaWide.u32 .add (.local (b + 4)) (DownMmaWide.u32l 16))
        (DownMmaWide.u32l 5))).run sh = some (u32 ((B + 16) / 32), sh) :=
      eval_bin_u32 C (eval_bin_u32 C (eval_local' C h4' sh) (eval_u32lit C _ _ 16 (by decide)) (binary_add_u32 C B 16))
        (eval_u32lit C _ _ 5 (by decide)) (by rw [binary_shr_u32 C (B + 16) 5 (by omega) (by decide)]; rfl)
    generalize hl₃ : setLocal l₂ (b + 6) (u32 ((B + 16) / 32)) = l₃
    have h6 : l₃ (b + 6) = some (u32 ((B + 16) / 32)) := by rw [← hl₃, setLocal_same]
    have h4'' : l₃ (b + 4) = some (u32 B) := by rw [← hl₃, setLocal_other _ _ (by omega)]; exact h4'
    have hv' : l₃ (b + 1) = some (.ptr ⟨rv, 0, .scalar .u32⟩) := by
      rw [← hl₃, setLocal_other _ _ (by omega), hlb _ (.inl (by omega))]; exact hv
    have hV := Nat.mod_lt (runBits W nw * 2 ^ 16 / 2 ^ (32 * ((B + 16) / 32))) (show 0 < 2 ^ 32 by decide)
    have eld : (eval C ctx l₃ (.load (.scalar .u32) (.offset (.local (b + 1)) (.local (b + 6))))).run sh =
        some (u32 (runBits W nw * 2 ^ 16 / 2 ^ (32 * ((B + 16) / 32)) % 2 ^ 32), sh) :=
      eval_ld32 C hv' (eval_local' C h6 sh) hrv (by omega) (hvc _ hvi.2 hvi.1)
    have esh : (eval C ctx l₃ (DownMmaWide.u32 .sub (DownMmaWide.u32 .add (.local (b + 4)) (DownMmaWide.u32l 16))
        (DownMmaWide.u32 .mul (DownMmaWide.u32l 32) (.local (b + 6))))).run sh =
        some (u32 (B + 16 - 32 * ((B + 16) / 32)), sh) :=
      eval_bin_u32 C (eval_bin_u32 C (eval_local' C h4'' sh) (eval_u32lit C _ _ 16 (by decide)) (binary_add_u32 C B 16))
        (eval_bin_u32 C (eval_u32lit C _ _ 32 (by decide)) (eval_local' C h6 sh) (binary_mul_u32 C 32 _))
        (binary_sub_u32 C _ _ (by omega))
    have ef : (eval C ctx l₃ (DownMmaWide.u32 .bitAnd (DownMmaWide.u32 .shr (.load (.scalar .u32)
        (.offset (.local (b + 1)) (.local (b + 6)))) (DownMmaWide.u32 .sub (DownMmaWide.u32 .add (.local (b + 4))
        (DownMmaWide.u32l 16)) (DownMmaWide.u32 .mul (DownMmaWide.u32l 32) (.local (b + 6))))) (DownMmaWide.u32l 4095))).run sh =
        some (u32 (runBits W nw / 2 ^ B % 2 ^ 12), sh) := by
      refine eval_bin_u32 C (eval_bin_u32 C eld esh (binary_shr_u32 C _ _ hV (by omega))) (eval_u32lit C _ _ 4095 (by decide)) ?_
      rw [binary_bitAnd_u32 C _ 4095 (lt_of_le_of_lt (Nat.div_le_self _ _) hV) (by decide),
        show (4095 : Nat) = 2 ^ 12 - 1 from rfl, Nat.and_two_pow_sub_one_eq_mod, field_virtual_of_bit _ _ (by omega)]
    refine ⟨setLocal l₃ (b + 3) (u32 (runBits W nw / 2 ^ B % 2 ^ 12)), ?_, setLocal_same _ _ _, fun j hj => ?_⟩
    · unfold DownMmaWide.blockState
      refine .scope (o₁ := .leave) ?_ (.inr rfl) (.nil _ _)
      exact .set e4 (by rw [hl₁]; exact .set e5 (by rw [hl₂]; exact .ite ec (.nil _ _) (.set e6 (by rw [hl₃]; exact .set ef .leave))))
    · rw [setLocal_other _ _ (by omega), ← hl₃, setLocal_other _ _ (by omega), hlb j hj]

end Exprs

end Metal.Kernels.DownWideRun

namespace Metal.Kernels.DownWideRun
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis
open Metal.Kernels.DownMmaWide (Tile p0Of fmOf fnOf laneOf eTile ePos eBk eSt eLane eReg outVal expected aReg bReg accReg
  cbHalf xval sval zero rcp Geo nGOf gyOf codesBytes In bufs)

/-! ### A row step's prefix: the words, the virtual words, `a` -/

/-- After a row step's prefix. -/
structure WLoc (p : Par) (th : Nat) (T : Tile) (i n : Nat) (l : Locals) : Prop where
  r : RLoc p th T i n l
  l45 : l 45 = some (.ptr ⟨ta th 4, 0, .scalar .u32⟩)
  l46 : l 46 = some (.ptr ⟨ta th 5, 0, .scalar .u32⟩)
  l52 : l 52 = some (.ptr ⟨ta th 6, 0, .vec .f32 2⟩)

theorem WLoc.of_eq {p : Par} {th : Nat} {T : Tile} {i n : Nat} {l l' : Locals} (h : WLoc p th T i n l)
    (h' : ∀ j, j ≤ 52 → l' j = l j) : WLoc p th T i n l' :=
  ⟨h.r.of_eq fun j hj => h' j (by omega), (h' 45 (by omega)).trans h.l45, (h' 46 (by omega)).trans h.l46,
    (h' 52 (by omega)).trans h.l52⟩

/-- At sub-tile `st`, block `bk`. -/
structure CLoc (p : Par) (th : Nat) (T : Tile) (i n st bk : Nat) (l : Locals) : Prop where
  w : WLoc p th T i n l
  l54 : l 54 = some (u32 st)
  l55 : l 55 = some (.ptr ⟨ta th 7, 0, .vec .f16 2⟩)
  l70 : l 70 = some (u32 bk)

theorem rpre_eq (mt nw : Nat) : DownMmaWide.rpre mt nw =
    [.array 43 false 3 (.scalar .u32)] ++ ([.set 44 (.lit (.int .u32 0)), .loop (DownMmaWide.u32 .le (.local 44)
      (DownMmaWide.u32l nw)) [.set 44 (.bin .add .u32 0 (.local 44) (.lit (.int .u32 1)))]
      [.store (.scalar .u32) (.offset (.local 43) (.local 44)) (DownMmaWide.ld .u32 (DownMmaWide.ptrAt 41
        (DownMmaWide.ld .u32 (DownMmaWide.ptrAt 39 (.local 44)))))]] ++
    ([.array 45 false 4 (.scalar .u32), .array 46 false 5 (.scalar .u32)] ++
    ([.set 47 (.lit (.int .u32 0)), .loop (DownMmaWide.lt 47 (DownMmaWide.u32l nw))
      [.set 47 (.bin .add .u32 0 (.local 47) (.lit (.int .u32 1)))]
      [.store (.scalar .u32) (.offset (.local 45) (.local 47)) DownMmaWide.wVal]] ++
    ([.set 48 (.lit (.int .u32 1)), .loop (DownMmaWide.lt 48 (DownMmaWide.u32l nw))
      [.set 48 (.bin .add .u32 0 (.local 48) (.lit (.int .u32 1)))]
      [.store (.scalar .u32) (.offset (.local 46) (.local 48))
        (DownMmaWide.u32 .bitOr (DownMmaWide.u32 .shr (DownMmaWide.ld .u32 (DownMmaWide.ptrAt 45 (DownMmaWide.u32 .sub
          (.local 48) (DownMmaWide.u32l 1)))) (DownMmaWide.u32l 16)) (DownMmaWide.u32 .shl (DownMmaWide.ld .u32
          (DownMmaWide.ptrAt 45 (.local 48))) (DownMmaWide.u32l 16)))]] ++
    ([.set 49 (DownMmaWide.u32 .add (.local 42) (.local 23)), .set 50 DownMmaWide.saE, .set 51 DownMmaWide.sbE,
      .array 52 false 6 (.vec .f32 2)] ++
    ([.set 53 (.lit (.int .u32 0)), .loop (DownMmaWide.lt 53 (DownMmaWide.u32l mt)) (DownMmaWide.inc 53)
      DownMmaWide.aBody] ++ [.set 54 (DownMmaWide.u32l 0)])))))) := rfl

section RowPre
variable (C : M1Max.Contract) {p : Par} {L : Launch} {I : In} {ge : Nat} {outOk : Nat → Prop} {ctx : Ctx}
  {y z sg i : Nat}

/-- `float(scales[ra + j]) * TRELLIS_RCP`. -/
theorem eval_sval (hS : Shape L p I) {l : Locals} {sh : Shared} {c : Nat} {e : CExpr}
    (hm : Mem C p L I ge (fun _ => True) outOk sh) (h3 : l 3 = some (.ptr ⟨3, 0, .scalar .f16⟩))
    (he : (eval C ctx l e).run sh = some (u32 c, sh)) (hc : c < 17408) :
    (eval C ctx l (.bin .mul .f32 0 (.conv .f32 (DownMmaWide.ld .f16 (DownMmaWide.ptrAt 3 e)))
      (DownMmaWide.f32l 0x3BDDB447))).run sh = some (.f32 (sval C I.S c), rdn ctx sh 3 (2 * c) 2) := by
  have hp := eval_ptr_u32 C (ctx := ctx) (eval_local' C h3 sh) he (by omega)
  rw [show c * (Ty.scalar .f16).bytes = 2 * c by simp [Ty.bytes, Scalar.bytes]; ring] at hp
  have hld := load_shared ctx .f16 sh 3 (2 * c) _ (by rw [hm.regions]; exact hS.r3) (by simp)
    (by simp [Scalar.bytes]; exact hS.as) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset])
  rw [hm.sc] at hld
  exact eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_conv C ((eval_load C _ _ _ _ _ _ _ hp).trans hld) rfl)
    (eval_lit C _ _ _ _) rfl

/-- `raw[m] = rowCodes[wordAt[m]]` for `m ≤ NW`. -/
theorem exec_raw (hS : Shape L p I) (hp : p.Ok) {th : Nat} {T : Tile} {n : Nat} (hn : n < 272) (hsplit : T.split < 8)
    (hblock : T.block < 20) (hi : i < 32) {l : Locals} {sh : Shared}
    (h41 : l 41 = some (.ptr ⟨2, ((4 * rowBase p T i n : Nat) : Int), .scalar .u32⟩))
    (h39 : l 39 = some (.ptr ⟨ta th 2, 0, .scalar .u32⟩)) (h43 : l 43 = some (.ptr ⟨ta th 3, 0, .scalar .u32⟩))
    (hm : Mem C p L I ge (fun _ => True) outOk sh) (hwa : WaArr p T i (sh.bytes (ta th 2))) :
    ∃ l' sh', Exec C ctx [.set 44 (.lit (.int .u32 0)), .loop (DownMmaWide.u32 .le (.local 44)
      (DownMmaWide.u32l p.nw)) [.set 44 (.bin .add .u32 0 (.local 44) (.lit (.int .u32 1)))]
      [.store (.scalar .u32) (.offset (.local 43) (.local 44)) (DownMmaWide.ld .u32 (DownMmaWide.ptrAt 41
        (DownMmaWide.ld .u32 (DownMmaWide.ptrAt 39 (.local 44)))))]] l sh .normal l' sh' ∧
      Mem C p L I ge (fun _ => True) outOk sh' ∧ (∀ j, j ≠ 44 → l' j = l j) ∧
      (∀ r, r ≠ ta th 3 → sh'.bytes r = sh.bytes r) ∧
      ∀ m < p.nw + 1, cells (sh'.bytes (ta th 3)) (4 * m) 4 = wordBytes 4 (rawW p I.Cd T i n m) := by
  have hk := hp.k; have hnw := hp.nw
  generalize hB2 : sh.bytes (ta th 2) = B2 at hwa
  obtain ⟨l', sh', hex, ⟨hm', -⟩, hag, hoth, -, hw⟩ := exec_fill32 C (ctx := ctx)
    (Inv := fun sh' => Mem C p L I ge (fun _ => True) outOk sh' ∧ sh'.bytes (ta th 2) = B2) (reg := ta th 3) (l := l)
    (sh := sh) (size := 4 * (p.nw + 1))
    (fun sh o bs h => ⟨h.1.tput o bs (by unfold ta; omega), by rw [tput_other _ _ _ (by unfold ta; omega)]; exact h.2⟩)
    (p.nw + 1) 44 43 0 (DownMmaWide.u32 .le (.local 44) (DownMmaWide.u32l p.nw))
    (DownMmaWide.ld .u32 (DownMmaWide.ptrAt 41 (DownMmaWide.ld .u32 (DownMmaWide.ptrAt 39 (.local 44))))) (rawW p I.Cd T i n)
    (fun l' sh' m _ hm' hc _ _ => by
      have := eval_bin_u32 C (ctx := ctx) (l := l') (sh := sh') (op := .le) (site := 0) (eval_local' C hc sh')
        (eval_u32lit C _ _ p.nw (by omega)) (binary_le_u32 C m p.nw (by omega) (by omega))
      rwa [show decide (m ≤ p.nw) = decide (m < p.nw + 1) from decide_eq_decide.mpr (by omega)] at this)
    (fun l' sh' m _ hm' hc hag hI => by
      have hreg := hI.1.regions
      have hW := Nat.mod_lt (p0Of p.s T i * p.k / 32 + m) (show 0 < 8 * p.k by omega)
      have hin := eval_ld32 C (ctx := ctx) (l := l') (sh := sh') (by rw [hag 39 (by omega)]; exact h39)
        (eval_local' C hc sh') (by rw [hreg]; exact hS.t2 th) (by omega) (by rw [hI.2]; exact hwa m hm')
      have hbd := rowBase_lt hp (n := n) hsplit hblock hi hn hW
      have hpt := eval_offset_u32 C (ctx := ctx) (eval_local' C (by rw [hag 41 (by omega)]; exact h41) sh') hin
        (by omega)
      rw [show 4 * rowBase p T i n + (p0Of p.s T i * p.k / 32 + m) % (8 * p.k) * (Ty.scalar .u32).bytes =
        4 * (rowBase p T i n + (p0Of p.s T i * p.k / 32 + m) % (8 * p.k)) by simp [Ty.bytes, Scalar.bytes]; ring] at hpt
      have hld := load_shared ctx .u32 sh' 2 (4 * (rowBase p T i n + (p0Of p.s T i * p.k / 32 + m) % (8 * p.k))) _
        (by rw [hreg]; exact hS.r2) (by simp) (by simp [Scalar.bytes]; exact hS.ac) (by simp [Scalar.bytes])
        (by simp [Scalar.bytes, codesBytes]; omega) (by simp [loadOffset])
      rw [hI.1.cd] at hld
      exact ⟨_, (eval_load C _ _ _ _ _ _ _ hpt).trans hld, ⟨hI.1.rd hS ctx 2 _ _ (.inl (by decide)), hI.2⟩, rfl⟩)
    (fun m => rawW_lt _ _ _ _ _ _) h43 (by decide) (fun sh' h => by rw [h.1.regions]; exact hS.t3 th) le_rfl
    (by omega) (by omega) ⟨hm, hB2⟩
  exact ⟨l', sh', hex, hm', hag, hoth, fun m hm' => hw m (by omega) hm'⟩

/-- `w[m] = off0 ? (raw[m] >> off0) | (raw[m + 1] << (32 - off0)) : raw[m]` for `m < NW`. -/
theorem exec_w (hS : Shape L p I) (hp : p.Ok) {th : Nat} {T : Tile} {n : Nat} {l : Locals} {sh : Shared}
    (h30 : l 30 = some (u32 (p0Of p.s T i * p.k % 32))) (h43 : l 43 = some (.ptr ⟨ta th 3, 0, .scalar .u32⟩))
    (h45 : l 45 = some (.ptr ⟨ta th 4, 0, .scalar .u32⟩)) (hm : Mem C p L I ge (fun _ => True) outOk sh)
    (hraw : ∀ m < p.nw + 1, cells (sh.bytes (ta th 3)) (4 * m) 4 = wordBytes 4 (rawW p I.Cd T i n m)) :
    ∃ l' sh', Exec C ctx [.set 47 (.lit (.int .u32 0)), .loop (DownMmaWide.lt 47 (DownMmaWide.u32l p.nw))
      [.set 47 (.bin .add .u32 0 (.local 47) (.lit (.int .u32 1)))]
      [.store (.scalar .u32) (.offset (.local 45) (.local 47)) DownMmaWide.wVal]] l sh .normal l' sh' ∧
      Mem C p L I ge (fun _ => True) outOk sh' ∧ (∀ j, j ≠ 47 → l' j = l j) ∧
      (∀ r, r ≠ ta th 4 → sh'.bytes r = sh.bytes r) ∧ WArr p I.Cd T i n (sh'.bytes (ta th 4)) := by
  have hnw := hp.nw
  generalize hB3 : sh.bytes (ta th 3) = B3 at hraw
  generalize ho : p0Of p.s T i * p.k % 32 = o at h30
  have hol : o < 32 := by rw [← ho]; exact Nat.mod_lt _ (by decide)
  have hRW : ∀ m < p.nw + 1, rawW p I.Cd T i n m < 2 ^ 32 := fun m _ => rawW_lt _ _ _ _ _ _
  obtain ⟨l', sh', hex, ⟨hm', -⟩, hag, hoth, -, hw⟩ := exec_fill32 C (ctx := ctx)
    (Inv := fun sh' => Mem C p L I ge (fun _ => True) outOk sh' ∧ sh'.bytes (ta th 3) = B3) (reg := ta th 4) (l := l)
    (sh := sh) (size := 4 * p.nw)
    (fun sh o bs h => ⟨h.1.tput o bs (by unfold ta; omega), by rw [tput_other _ _ _ (by unfold ta; omega)]; exact h.2⟩)
    p.nw 47 45 0 (DownMmaWide.lt 47 (DownMmaWide.u32l p.nw)) DownMmaWide.wVal (wW p I.Cd T i n)
    (fun l' sh' m _ hm' hc _ _ => eval_lt_u32 C (ctx := ctx) hc (by omega) (by omega))
    (fun l' sh' m _ hm' hc hag hI => by
      have hreg := hI.1.regions
      have hld : ∀ (j : Nat) (e : CExpr), j < p.nw + 1 → (eval C ctx l' e).run sh' = some (u32 j, sh') →
          (eval C ctx l' (DownMmaWide.ld .u32 (DownMmaWide.ptrAt 43 e))).run sh' = some (u32 (rawW p I.Cd T i n j), sh') :=
        fun j e hj he => eval_ld32 C (by rw [hag 43 (by omega)]; exact h43) he (by rw [hreg]; exact hS.t3 th) (by omega)
          (by rw [hI.2]; exact hraw j hj)
      have h30' : l' 30 = some (u32 o) := by rw [hag 30 (by omega)]; exact h30
      have hb : (eval C ctx l' (.conv .bool (.local 30))).run sh' = some (.bool (decide (o ≠ 0)), sh') := by
        have := eval_conv C (ctx := ctx) (t := .bool) (eval_local' C h30' sh') (w := .bool (decide (o % 2 ^ 32 ≠ 0))) rfl
        rwa [Nat.mod_eq_of_lt (show o < 2 ^ 32 by omega)] at this
      refine ⟨sh', eval_cond C hb ?_, hI, rfl⟩
      by_cases ho0 : o = 0
      · rw [decide_eq_false (by omega)]
        have e : wW p I.Cd T i n m = rawW p I.Cd T i n m := by
          unfold wW; rw [ho, ho0, Nat.pow_zero, Nat.div_one, runBits_word hRW m (by omega)]
        rw [e]; exact hld m (.local 47) (by omega) (eval_local' C hc sh')
      · rw [decide_eq_true ho0]
        have e : wW p I.Cd T i n m = rawW p I.Cd T i n m / 2 ^ o ||| rawW p I.Cd T i n (m + 1) * 2 ^ (32 - o) % 2 ^ 32 := by
          unfold wW; rw [ho, realign_word hRW (by omega) hol (by omega)]
        rw [e]
        have h1 := hRW m (by omega)
        refine eval_bin_u32 C (eval_bin_u32 C (hld m (.local 47) (by omega) (eval_local' C hc sh')) (eval_local' C h30' sh')
          (binary_shr_u32 C _ _ h1 hol)) ?_
          (binary_bitOr_u32 C _ _ (lt_of_le_of_lt (Nat.div_le_self _ _) h1) (Nat.mod_lt _ (by decide)))
        rw [u32_mod]
        exact eval_bin_u32 C (hld (m + 1) _ (by omega) (eval_bin_u32 C (eval_local' C hc sh') (eval_u32lit C _ _ 1 (by decide))
            (binary_add_u32 C m 1)))
          (eval_bin_u32 C (eval_u32lit C _ _ 32 (by decide)) (eval_local' C h30' sh') (binary_sub_u32 C 32 o (by omega)))
          (binary_shl_u32 C _ _ (by omega)))
    (fun m => wW_lt _ _ _ _ _ _) h45 (by decide) (fun sh' h => by rw [h.1.regions]; exact hS.t4 th) le_rfl
    (by omega) (by omega) ⟨hm, hB3⟩
  exact ⟨l', sh', hex, hm', hag, hoth, fun m hm' => hw m (by omega) hm'⟩

/-- `v[m] = (w[m - 1] >> 16) | (w[m] << 16)` for `1 ≤ m < NW`. -/
theorem exec_v (hS : Shape L p I) (hp : p.Ok) {th : Nat} {T : Tile} {n : Nat} {l : Locals} {sh : Shared}
    (h45 : l 45 = some (.ptr ⟨ta th 4, 0, .scalar .u32⟩)) (h46 : l 46 = some (.ptr ⟨ta th 5, 0, .scalar .u32⟩))
    (hm : Mem C p L I ge (fun _ => True) outOk sh) (hwc : WArr p I.Cd T i n (sh.bytes (ta th 4))) :
    ∃ l' sh', Exec C ctx [.set 48 (.lit (.int .u32 1)), .loop (DownMmaWide.lt 48 (DownMmaWide.u32l p.nw))
      [.set 48 (.bin .add .u32 0 (.local 48) (.lit (.int .u32 1)))]
      [.store (.scalar .u32) (.offset (.local 46) (.local 48))
        (DownMmaWide.u32 .bitOr (DownMmaWide.u32 .shr (DownMmaWide.ld .u32 (DownMmaWide.ptrAt 45 (DownMmaWide.u32 .sub
          (.local 48) (DownMmaWide.u32l 1)))) (DownMmaWide.u32l 16)) (DownMmaWide.u32 .shl (DownMmaWide.ld .u32
          (DownMmaWide.ptrAt 45 (.local 48))) (DownMmaWide.u32l 16)))]] l sh .normal l' sh' ∧
      Mem C p L I ge (fun _ => True) outOk sh' ∧ (∀ j, j ≠ 48 → l' j = l j) ∧
      (∀ r, r ≠ ta th 5 → sh'.bytes r = sh.bytes r) ∧ VArr p I.Cd T i n (sh'.bytes (ta th 5)) := by
  have hnw := hp.nw
  generalize hB4 : sh.bytes (ta th 4) = B4 at hwc
  have hWW : ∀ m < p.nw, wW p I.Cd T i n m < 2 ^ 32 := fun m _ => wW_lt _ _ _ _ _ _
  obtain ⟨l', sh', hex, ⟨hm', -⟩, hag, hoth, -, hw⟩ := exec_fill32 C (ctx := ctx)
    (Inv := fun sh' => Mem C p L I ge (fun _ => True) outOk sh' ∧ sh'.bytes (ta th 4) = B4) (reg := ta th 5) (l := l)
    (sh := sh) (size := 4 * p.nw)
    (fun sh o bs h => ⟨h.1.tput o bs (by unfold ta; omega), by rw [tput_other _ _ _ (by unfold ta; omega)]; exact h.2⟩)
    p.nw 48 46 1 (DownMmaWide.lt 48 (DownMmaWide.u32l p.nw))
    (DownMmaWide.u32 .bitOr (DownMmaWide.u32 .shr (DownMmaWide.ld .u32 (DownMmaWide.ptrAt 45 (DownMmaWide.u32 .sub
      (.local 48) (DownMmaWide.u32l 1)))) (DownMmaWide.u32l 16)) (DownMmaWide.u32 .shl (DownMmaWide.ld .u32
      (DownMmaWide.ptrAt 45 (.local 48))) (DownMmaWide.u32l 16))) (vW p I.Cd T i n)
    (fun l' sh' m _ hm' hc _ _ => eval_lt_u32 C (ctx := ctx) hc (by omega) (by omega))
    (fun l' sh' m h1 hm' hc hag hI => by
      have hreg := hI.1.regions
      have hld : ∀ (j : Nat) (e : CExpr), j < p.nw → (eval C ctx l' e).run sh' = some (u32 j, sh') →
          (eval C ctx l' (DownMmaWide.ld .u32 (DownMmaWide.ptrAt 45 e))).run sh' = some (u32 (wW p I.Cd T i n j), sh') :=
        fun j e hj he => eval_ld32 C (by rw [hag 45 (by omega)]; exact h45) he (by rw [hreg]; exact hS.t4 th) (by omega)
          (by rw [hI.2]; exact hwc j hj)
      have e : vW p I.Cd T i n m = wW p I.Cd T i n (m - 1) / 2 ^ 16 ||| wW p I.Cd T i n (m - 1 + 1) * 2 ^ 16 % 2 ^ 32 := by
        unfold vW; rw [shifted_word hWW (by omega), show m - 1 + 1 = m by omega]
      rw [e, show m - 1 + 1 = m by omega]
      have hw0 := hWW (m - 1) (by omega)
      refine ⟨sh', eval_bin_u32 C (eval_bin_u32 C (hld (m - 1) _ (by omega) (eval_bin_u32 C (eval_local' C hc sh')
        (eval_u32lit C _ _ 1 (by decide)) (binary_sub_u32 C m 1 (by omega)))) (eval_u32lit C _ _ 16 (by decide))
        (binary_shr_u32 C _ 16 hw0 (by decide))) ?_
        (binary_bitOr_u32 C _ _ (lt_of_le_of_lt (Nat.div_le_self _ _) hw0) (Nat.mod_lt _ (by decide))), hI, rfl⟩
      rw [u32_mod]
      exact eval_bin_u32 C (hld m _ (by omega) (eval_local' C hc sh')) (eval_u32lit C _ _ 16 (by decide))
        (binary_shl_u32 C _ 16 (by decide)))
    (fun m => vW_lt _ _ _ _ _ _) h46 (by decide) (fun sh' h => by rw [h.1.regions]; exact hS.t5 th) le_rfl
    (by omega) (by omega) ⟨hm, hB4⟩
  exact ⟨l', sh', hex, hm', hag, hoth, fun m h1 hm' => hw m h1 hm'⟩

/-- `float(xm[bk][j])` for the row `xm[bk]` points at. -/
theorem eval_xm (hS : Shape L p I) (hp : p.Ok) {th : Nat} {l : Locals} {sh : Shared} {b row c : Nat} {jE : CExpr}
    (hm : Mem C p L I ge (fun _ => True) outOk sh) (hb : b < p.mt) (hrow : row < p.M) (hc : c < 17408)
    (h35 : l 35 = some (.ptr ⟨ta th 0, 0, .ptr .device (.scalar .bf16)⟩)) (h53 : l 53 = some (u32 b))
    (hx : cells (sh.bytes (ta th 0)) (8 * b) 8 = wordBytes 8 (34816 * row))
    (hj : (eval C ctx l jE).run sh = some (u32 c, sh)) :
    (eval C ctx l (.conv .f32 (DownMmaWide.xmE jE))).run sh =
      some (.f32 (xval C I.X row c), rdn ctx sh 0 (2 * (17408 * row + c)) 2) := by
  have hM := hp.m2
  have hmt3 : p.mt ≤ 3 := by rcases hp.sm with ⟨-, h⟩ | ⟨-, h⟩ | ⟨-, h⟩ <;> rw [h] <;> decide
  have hreg := hm.regions
  have hp1 := eval_ptr_u32 C (ctx := ctx) (eval_local' C h35 sh) (eval_local' C h53 sh) (by omega)
  rw [show b * (Ty.ptr .device (.scalar .bf16)).bytes = 8 * b by simp [Ty.bytes]; ring] at hp1
  have hl1 := load_ptr_x (ctx := ctx) (sh := sh) (by rw [hreg]; exact hS.t0 th) (by omega) (by omega)
    (show 34816 * row < 2 ^ 40 by omega) hx
  have hp2 := eval_offset_u32 C (ctx := ctx) ((eval_load C _ _ _ _ _ _ _ hp1).trans hl1) hj (by omega)
  rw [show 34816 * row + c * (Ty.scalar .bf16).bytes = 2 * (17408 * row + c) by simp [Ty.bytes, Scalar.bytes]; ring]
    at hp2
  have hld := load_shared ctx .bf16 sh 0 (2 * (17408 * row + c)) _ (by rw [hreg]; exact hS.r0) (by simp)
    (by simp [Scalar.bytes]; exact hS.ax) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset])
  rw [hm.x] at hld
  exact eval_conv C ((eval_load C _ _ _ _ _ _ _ hp2).trans hld) rfl

/-- `a[bk].thread_elements() = {float(xm[bk][ra]) * sa, float(xm[bk][ra + 1]) * sb}` for `bk < MT`. -/
theorem exec_a (hS : Shape L p I) (hp : p.Ok) {th : Nat} {T : Tile} {n : Nat} (hn : n < 272) (hsplit : T.split < 8)
    (hmB : T.mBase < p.M) (hi : i < 32) {l : Locals} {sh : Shared}
    (h35 : l 35 = some (.ptr ⟨ta th 0, 0, .ptr .device (.scalar .bf16)⟩))
    (h52 : l 52 = some (.ptr ⟨ta th 6, 0, .vec .f32 2⟩))
    (h49 : l 49 = some (u32 (2176 * T.split + 8 * n + fnOf i)))
    (h50 : l 50 = some (.f32 (sval C I.S (2176 * T.split + 8 * n + fnOf i))))
    (h51 : l 51 = some (.f32 (sval C I.S (2176 * T.split + 8 * n + fnOf i + 1))))
    (hm : Mem C p L I ge (fun _ => True) outOk sh) (hxm : XmArr p T i (sh.bytes (ta th 0))) :
    ∃ l' sh', Exec C ctx [.set 53 (.lit (.int .u32 0)), .loop (DownMmaWide.lt 53 (DownMmaWide.u32l p.mt))
      (DownMmaWide.inc 53) DownMmaWide.aBody] l sh .normal l' sh' ∧ Mem C p L I ge (fun _ => True) outOk sh' ∧
      (∀ j, j ≠ 53 → l' j = l j) ∧ (∀ r, r ≠ ta th 6 → sh'.bytes r = sh.bytes r) ∧
      AArr C p I T ⟨i, hi⟩ n (sh'.bytes (ta th 6)) := by
  have hmt : 1 ≤ p.mt ∧ p.mt ≤ 3 := by rcases hp.sm with ⟨-, h⟩ | ⟨-, h⟩ | ⟨-, h⟩ <;> rw [h] <;> decide
  have hfn := (lane_fm_fn i hi).2.2.2
  have hfm := (lane_fm_fn i hi).2.1
  have hM := hp.m2
  have hra : 2176 * T.split + 8 * n + fnOf i + 1 < 17408 := by omega
  let J : Nat → Locals → Shared → Prop := fun k l' sh' => (∀ j, j ≠ 53 → l' j = l j) ∧ l' 53 = some (u32 k) ∧
    Mem C p L I ge (fun _ => True) outOk sh' ∧ (∀ r, r ≠ ta th 6 → sh'.bytes r = sh.bytes r) ∧
    ∀ b < k, ∀ e : Fin 2, cells (sh'.bytes (ta th 6)) (8 * b + 4 * e) 4 =
      wordBytes 4 (Val.f32Bits (aReg C p.M I.X I.S T n b ⟨i, hi⟩ e))
  obtain ⟨l', sh', hex, hJ⟩ := Exec.loop_count (ctx := ctx) (C := C) (c := DownMmaWide.lt 53 (DownMmaWide.u32l p.mt)) (st := DownMmaWide.inc 53)
    (b := DownMmaWide.aBody) p.mt J J
    (fun k hk l' sh' hJ => ⟨sh', eval_lt_u32 C (ctx := ctx) hJ.2.1 (by omega) (by omega), hJ⟩)
    (fun k hk l' sh' hJ => by
      obtain ⟨hag, h53, hm', hoth, hw⟩ := hJ
      have hreg := hm'.regions
      have hrow : min (T.mBase + 8 * k + fmOf i) (p.M - 1) < p.M := by omega
      have hx : cells (sh'.bytes (ta th 0)) (8 * k) 8 = wordBytes 8 (34816 * min (T.mBase + 8 * k + fmOf i) (p.M - 1)) := by
        rw [hoth _ (by unfold ta; omega)]; exact hxm k hk
      have h35' : l' 35 = some (.ptr ⟨ta th 0, 0, .ptr .device (.scalar .bf16)⟩) := by rw [hag 35 (by omega)]; exact h35
      have h52' : l' 52 = some (.ptr ⟨ta th 6, 0, .vec .f32 2⟩) := by rw [hag 52 (by omega)]; exact h52
      have hpe : ∀ (j : Nat) (shx : Shared), j < 2 → (eval C ctx l' (.offset (.ptrCast (.scalar .f32)
          (DownMmaWide.ptrAt 52 (.local 53))) (.lit (.int .i32 j)))).run shx =
          some (.ptr ⟨ta th 6, ((8 * k + 4 * j : Nat) : Int), .scalar .f32⟩, shx) := by
        intro j shx hj
        have h1 := eval_ptrCast C (ctx := ctx) (t := .scalar .f32) (eval_ptr_u32 C (ctx := ctx) (eval_local' C h52' shx)
          (eval_local' C h53 shx) (by omega))
        have h2 := eval_offset_i32 C (ctx := ctx) (n := j) h1 (eval_lit C _ _ _ _) (by omega)
        rwa [show k * (Ty.vec .f32 2).bytes + j * (Ty.scalar .f32).bytes = 8 * k + 4 * j by
          simp [Ty.bytes, Scalar.bytes]; ring] at h2
      generalize hrw : min (T.mBase + 8 * k + fmOf i) (p.M - 1) = row at hrow hx
      have hra0 : 2176 * T.split + 8 * n + fnOf i < 17408 := by omega
      -- element 0
      have hv0 := eval_xm C hS hp (ctx := ctx) (th := th) (hm := hm') hk hrow hra0 h35' h53 hx
        (eval_local' C (by rw [hag 49 (by omega)]; exact h49) sh')
      have hval0 : (eval C ctx l' (.bin .mul .f32 0 (.conv .f32 (DownMmaWide.xmE (.local 49))) (.local 50))).run sh' =
          some (.f32 (aReg C p.M I.X I.S T n k ⟨i, hi⟩ 0), rdn ctx sh' 0 (2 * (17408 * row + (2176 * T.split + 8 * n + fnOf i))) 2) := by
        rw [show aReg C p.M I.X I.S T n k ⟨i, hi⟩ 0 = C.fmul (xval C I.X row (2176 * T.split + 8 * n + fnOf i))
          (sval C I.S (2176 * T.split + 8 * n + fnOf i)) by rw [← hrw]; rfl]
        exact eval_f32 C (.inl ⟨by decide, by decide⟩) hv0 (eval_local' C (by rw [hag 50 (by omega)]; exact h50) _) rfl
      generalize hsh₂ : rdn ctx sh' 0 (2 * (17408 * row + (2176 * T.split + 8 * n + fnOf i))) 2 = sh₂ at hval0
      have hm₂ : Mem C p L I ge (fun _ => True) outOk sh₂ := by rw [← hsh₂]; exact hm'.rd hS ctx 0 _ 2 (.inl (by decide))
      have hb₂ : sh₂.bytes = sh'.bytes := by rw [← hsh₂]; rfl
      have hst0 := store_thread ctx .f32 sh₂ (ta th 6) (8 * k + 4 * 0) (8 * p.mt) 8 _ _
        (by rw [hm₂.regions]; exact hS.t6 th) (by decide) (by simp [Scalar.bytes]; omega)
        (by simp [Scalar.bytes]; omega) (encode_f32 (aReg C p.M I.X I.S T n k ⟨i, hi⟩ 0))
      generalize hsh₃ : tput sh₂ (ta th 6) (8 * k + 4 * 0) (wordBytes 4 (Val.f32Bits (aReg C p.M I.X I.S T n k ⟨i, hi⟩ 0)))
        = sh₃ at hst0
      have hm₃ : Mem C p L I ge (fun _ => True) outOk sh₃ := by rw [← hsh₃]; exact hm₂.tput _ _ (by unfold ta; omega)
      have hb₃ : ∀ r, r ≠ ta th 6 → sh₃.bytes r = sh'.bytes r := fun r hr => by
        rw [← hsh₃, tput_other _ _ _ hr, hb₂]
      have hc₃ : sh₃.bytes (ta th 6) = writeBytes (sh'.bytes (ta th 6)) (8 * k + 4 * 0)
          (wordBytes 4 (Val.f32Bits (aReg C p.M I.X I.S T n k ⟨i, hi⟩ 0))) := by rw [← hsh₃, tput_same, hb₂]
      -- element 1
      have hv1 := eval_xm C hS hp (ctx := ctx) (th := th) (hm := hm₃) hk hrow hra (sh := sh₃)
        (jE := DownMmaWide.u32 .add (.local 49) (DownMmaWide.u32l 1)) h35' h53
        (by rw [hb₃ _ (by unfold ta; omega)]; exact hx)
        (eval_bin_u32 C (eval_local' C (by rw [hag 49 (by omega)]; exact h49) sh₃) (eval_u32lit C _ _ 1 (by decide))
          (binary_add_u32 C _ 1))
      have hval1 : (eval C ctx l' (.bin .mul .f32 0 (.conv .f32 (DownMmaWide.xmE (DownMmaWide.u32 .add (.local 49)
          (DownMmaWide.u32l 1)))) (.local 51))).run sh₃ =
          some (.f32 (aReg C p.M I.X I.S T n k ⟨i, hi⟩ 1),
            rdn ctx sh₃ 0 (2 * (17408 * row + (2176 * T.split + 8 * n + fnOf i + 1))) 2) := by
        rw [show aReg C p.M I.X I.S T n k ⟨i, hi⟩ 1 = C.fmul (xval C I.X row (2176 * T.split + 8 * n + fnOf i + 1))
          (sval C I.S (2176 * T.split + 8 * n + fnOf i + 1)) by rw [← hrw]; rfl]
        exact eval_f32 C (.inl ⟨by decide, by decide⟩) hv1 (eval_local' C (by rw [hag 51 (by omega)]; exact h51) _) rfl
      generalize hsh₄ : rdn ctx sh₃ 0 (2 * (17408 * row + (2176 * T.split + 8 * n + fnOf i + 1))) 2 = sh₄ at hval1
      have hm₄ : Mem C p L I ge (fun _ => True) outOk sh₄ := by rw [← hsh₄]; exact hm₃.rd hS ctx 0 _ 2 (.inl (by decide))
      have hb₄ : sh₄.bytes = sh₃.bytes := by rw [← hsh₄]; rfl
      have hst1 := store_thread ctx .f32 sh₄ (ta th 6) (8 * k + 4 * 1) (8 * p.mt) 8 _ _
        (by rw [hm₄.regions]; exact hS.t6 th) (by decide) (by simp [Scalar.bytes]; omega)
        (by simp [Scalar.bytes]; omega) (encode_f32 (aReg C p.M I.X I.S T n k ⟨i, hi⟩ 1))
      generalize hsh₅ : tput sh₄ (ta th 6) (8 * k + 4 * 1) (wordBytes 4 (Val.f32Bits (aReg C p.M I.X I.S T n k ⟨i, hi⟩ 1)))
        = sh₅ at hst1
      refine ⟨.normal, l', sh₅, setLocal l' 53 (u32 (k + 1)), sh₅, .inl rfl,
        .store (hpe 0 sh' (by decide)) hval0 hst0 (.store (hpe 1 sh₃ (by decide)) hval1 hst1 (.nil _ _)),
        .set (eval_bin_u32 C (eval_local' C h53 _) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C k 1)) (.nil _ _),
        fun j hj => by rw [setLocal_other _ _ hj]; exact hag j hj, setLocal_same _ _ _,
        by rw [← hsh₅]; exact hm₄.tput _ _ (by unfold ta; omega),
        fun r hr => by rw [← hsh₅, tput_other _ _ _ hr, hb₄, hb₃ r hr, hoth r hr], fun b hb e => ?_⟩
      rw [← hsh₅, tput_same, hb₄, hc₃]
      have hl4 := wordBytes_length 4 (Val.f32Bits (aReg C p.M I.X I.S T n k ⟨i, hi⟩ 0))
      have hl4' := wordBytes_length 4 (Val.f32Bits (aReg C p.M I.X I.S T n k ⟨i, hi⟩ 1))
      have he2 := e.isLt
      by_cases hbk : b = k
      · rw [hbk]
        rcases e with ⟨_ | _ | _, he⟩
        · show cells (writeBytes (writeBytes (sh'.bytes (ta th 6)) (8 * k + 4 * 0) _) (8 * k + 4 * 1) _) (8 * k + 4 * 0) 4 = _
          rw [cells_writeBytes_other _ _ _ _ _ (by rw [hl4']; omega)]
          have := cells_writeBytes_same (sh'.bytes (ta th 6)) (8 * k + 4 * 0)
            (wordBytes 4 (Val.f32Bits (aReg C p.M I.X I.S T n k ⟨i, hi⟩ 0)))
          rw [hl4] at this; exact this
        · show cells (writeBytes (writeBytes (sh'.bytes (ta th 6)) (8 * k + 4 * 0) _) (8 * k + 4 * 1) _) (8 * k + 4 * 1) 4 = _
          have := cells_writeBytes_same (writeBytes (sh'.bytes (ta th 6)) (8 * k + 4 * 0)
            (wordBytes 4 (Val.f32Bits (aReg C p.M I.X I.S T n k ⟨i, hi⟩ 0)))) (8 * k + 4 * 1)
            (wordBytes 4 (Val.f32Bits (aReg C p.M I.X I.S T n k ⟨i, hi⟩ 1)))
          rw [hl4'] at this; exact this
        · omega
      · rw [cells_writeBytes_other _ _ _ _ _ (by rw [hl4']; omega), cells_writeBytes_other _ _ _ _ _ (by rw [hl4]; omega)]
        exact hw b (by omega) e)
    (l := setLocal l 53 (u32 0)) (sh := sh)
    ⟨fun j hj => setLocal_other _ _ hj, setLocal_same _ _ _, hm, fun _ _ => rfl, fun b hb => absurd hb (by omega)⟩
  exact ⟨l', sh', .set (eval_u32lit C _ _ 0 (by decide)) hex, hJ.2.2.1, hJ.1, hJ.2.2.2.1, hJ.2.2.2.2⟩

/-- A row step's prefix: `raw`, `w`, `v`, `ra`, `sa`, `sb`, `a`, `s = 0`. -/
theorem lane_rpre (hS : Shape L p I) (hp : p.Ok) (hl : Lane p ctx y z sg i) {n : Nat} (hn : n < 272)
    {l : Locals} {sh : Shared}
    (hR : RLoc p (thOf p.s y z sg i) (tileOf p.s p.mt y z sg) i n l) (hm : Mem C p L I ge (fun _ => True) outOk sh)
    (hxm : XmArr p (tileOf p.s p.mt y z sg) i (sh.bytes (ta (thOf p.s y z sg i) 0)))
    (hwa : WaArr p (tileOf p.s p.mt y z sg) i (sh.bytes (ta (thOf p.s y z sg i) 2))) :
    ∃ l' sh', Exec C ctx (DownMmaWide.rpre p.mt p.nw) l sh .normal l' sh' ∧
      WLoc p (thOf p.s y z sg i) (tileOf p.s p.mt y z sg) i n l' ∧ l' 54 = some (u32 0) ∧
      Mem C p L I ge (fun _ => True) outOk sh' ∧
      (∀ r, (r < ta (thOf p.s y z sg i) 3 ∨ ta (thOf p.s y z sg i) 7 ≤ r) → sh'.bytes r = sh.bytes r) ∧
      WArr p I.Cd (tileOf p.s p.mt y z sg) i n (sh'.bytes (ta (thOf p.s y z sg i) 4)) ∧
      VArr p I.Cd (tileOf p.s p.mt y z sg) i n (sh'.bytes (ta (thOf p.s y z sg i) 5)) ∧
      AArr C p I (tileOf p.s p.mt y z sg) ⟨i, hl.hi⟩ n (sh'.bytes (ta (thOf p.s y z sg i) 6)) := by
  obtain ⟨hsplit, hblock, -, hmB, -⟩ := tile_facts hp hl.hy hl.hz hl.hsg
  have hfn := (lane_fm_fn i hl.hi).2.2.2
  have hta := hl.ta
  generalize hT : tileOf p.s p.mt y z sg = T at *
  generalize hth : thOf p.s y z sg i = th at *
  have hs := hR.g.s
  -- `raw`
  have h43 : (setLocal l 43 (.ptr ⟨ta th 3, 0, .scalar .u32⟩)) 43 = some (.ptr ⟨ta th 3, 0, .scalar .u32⟩) :=
    setLocal_same _ _ _
  obtain ⟨l₂, sh₂, x2, hm₂, hag₂, hoth₂, hraw₂⟩ := exec_raw C hS hp (th := th) (T := T) hn hsplit hblock hl.hi
    (l := setLocal l 43 (.ptr ⟨ta th 3, 0, .scalar .u32⟩)) (sh := sh)
    (by rw [setLocal_other _ _ (by omega)]; exact hR.l41) (by rw [setLocal_other _ _ (by omega)]; exact hR.g.l39) h43
    hm hwa
  have x1 : Exec C ctx [.array 43 false 3 (.scalar .u32)] l sh .normal (setLocal l 43 (.ptr ⟨ta th 3, 0, .scalar .u32⟩)) sh := by
    refine .array ?_; simp only [Bool.false_eq_true, ite_false, hta]; exact .nil _ _
  have hl₂ : ∀ j, j ≠ 43 → j ≠ 44 → l₂ j = l j := fun j h1 h2 => by rw [hag₂ j h2, setLocal_other _ _ h1]
  -- `w`, `v`
  generalize hl₃ : setLocal (setLocal l₂ 45 (.ptr ⟨ta th 4, 0, .scalar .u32⟩)) 46 (.ptr ⟨ta th 5, 0, .scalar .u32⟩) = l₃
  have x3 : Exec C ctx [.array 45 false 4 (.scalar .u32), .array 46 false 5 (.scalar .u32)] l₂ sh₂ .normal l₃ sh₂ := by
    rw [← hl₃]; refine .array (.array ?_); simp only [Bool.false_eq_true, ite_false, hta]; exact .nil _ _
  have hl₃b : ∀ j, j < 45 → j ≠ 43 → j ≠ 44 → l₃ j = l j := fun j hj h1 h2 => by
    rw [← hl₃, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), hl₂ j h1 h2]
  have h43₃ : l₃ 43 = some (.ptr ⟨ta th 3, 0, .scalar .u32⟩) := by
    rw [← hl₃, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), hag₂ 43 (by omega)]; exact h43
  have h45₃ : l₃ 45 = some (.ptr ⟨ta th 4, 0, .scalar .u32⟩) := by
    rw [← hl₃, setLocal_other _ _ (by omega), setLocal_same]
  have h46₃ : l₃ 46 = some (.ptr ⟨ta th 5, 0, .scalar .u32⟩) := by rw [← hl₃, setLocal_same]
  obtain ⟨l₄, sh₄, x4, hm₄, hag₄, hoth₄, hw₄⟩ := exec_w C hS hp (ctx := ctx) (th := th) (T := T) (n := n) (l := l₃) (sh := sh₂)
    (by rw [hl₃b 30 (by omega) (by omega) (by omega)]; exact hs.l30) h43₃ h45₃ hm₂ hraw₂
  obtain ⟨l₅, sh₅, x5, hm₅, hag₅, hoth₅, hv₅⟩ := exec_v C hS hp (ctx := ctx) (th := th) (T := T) (n := n) (l := l₄) (sh := sh₄)
    (by rw [hag₄ 45 (by omega)]; exact h45₃) (by rw [hag₄ 46 (by omega)]; exact h46₃) hm₄ hw₄
  have hl₅ : ∀ j, j < 49 → j ≠ 47 → j ≠ 48 → l₅ j = l₃ j := fun j hj h1 h2 => by rw [hag₅ j h2, hag₄ j h1]
  -- `ra`, `sa`, `sb`
  have h42 : l₅ 42 = some (u32 (2176 * T.split + 8 * n)) := by
    rw [hl₅ 42 (by omega) (by omega) (by omega), hl₃b 42 (by omega) (by omega) (by omega)]; exact hR.l42
  have h23 : l₅ 23 = some (u32 (fnOf i)) := by
    rw [hl₅ 23 (by omega) (by omega) (by omega), hl₃b 23 (by omega) (by omega) (by omega)]; exact hs.l23
  have h3 : l₅ 3 = some (.ptr ⟨3, 0, .scalar .f16⟩) := by
    rw [hl₅ 3 (by omega) (by omega) (by omega), hl₃b 3 (by omega) (by omega) (by omega)]; exact hs.fix.l3
  have hra : 2176 * T.split + 8 * n + fnOf i + 1 < 17408 := by omega
  have e49 : (eval C ctx l₅ (DownMmaWide.u32 .add (.local 42) (.local 23))).run sh₅ =
      some (u32 (2176 * T.split + 8 * n + fnOf i), sh₅) :=
    eval_bin_u32 C (eval_local' C h42 sh₅) (eval_local' C h23 sh₅) (binary_add_u32 C _ _)
  generalize hl₆ : setLocal l₅ 49 (u32 (2176 * T.split + 8 * n + fnOf i)) = l₆
  have h49₆ : l₆ 49 = some (u32 (2176 * T.split + 8 * n + fnOf i)) := by rw [← hl₆, setLocal_same]
  have e50 := eval_sval C hS (ctx := ctx) (l := l₆) hm₅ (by rw [← hl₆, setLocal_other _ _ (by omega)]; exact h3)
    (eval_local' C h49₆ sh₅) (by omega)
  have hm₆ := hm₅.rd hS ctx 3 (2 * (2176 * T.split + 8 * n + fnOf i)) 2 (.inl (by decide))
  generalize hsh₆ : rdn ctx sh₅ 3 (2 * (2176 * T.split + 8 * n + fnOf i)) 2 = sh₆ at e50 hm₆
  generalize hl₇ : setLocal l₆ 50 (.f32 (sval C I.S (2176 * T.split + 8 * n + fnOf i))) = l₇
  have h3₇ : l₇ 3 = some (.ptr ⟨3, 0, .scalar .f16⟩) := by
    rw [← hl₇, setLocal_other _ _ (by omega), ← hl₆, setLocal_other _ _ (by omega)]; exact h3
  have h49₇ : l₇ 49 = some (u32 (2176 * T.split + 8 * n + fnOf i)) := by
    rw [← hl₇, setLocal_other _ _ (by omega)]; exact h49₆
  have e51 := eval_sval C hS (ctx := ctx) (l := l₇) hm₆ h3₇
    (eval_bin_u32 C (site := 0) (eval_local' C h49₇ sh₆)
      (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C _ 1)) hra
  have hm₇ := hm₆.rd hS ctx 3 (2 * (2176 * T.split + 8 * n + fnOf i + 1)) 2 (.inl (by decide))
  generalize hsh₇ : rdn ctx sh₆ 3 (2 * (2176 * T.split + 8 * n + fnOf i + 1)) 2 = sh₇ at e51 hm₇
  generalize hl₈ : setLocal (setLocal l₇ 51 (.f32 (sval C I.S (2176 * T.split + 8 * n + fnOf i + 1)))) 52
    (.ptr ⟨ta th 6, 0, .vec .f32 2⟩) = l₈
  have x6 : Exec C ctx [.set 49 (DownMmaWide.u32 .add (.local 42) (.local 23)), .set 50 DownMmaWide.saE,
      .set 51 DownMmaWide.sbE, .array 52 false 6 (.vec .f32 2)] l₅ sh₅ .normal l₈ sh₇ := by
    refine .set e49 ?_; rw [hl₆]; refine .set e50 ?_; rw [hl₇]; refine .set e51 (.array ?_)
    rw [← hl₈]; simp only [Bool.false_eq_true, ite_false, hta]; exact .nil _ _
  have hb₇ : sh₇.bytes = sh₅.bytes := by rw [← hsh₇, ← hsh₆]; rfl
  have hl₈b : ∀ j, j < 49 → l₈ j = l₅ j := fun j hj => by
    rw [← hl₈, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), ← hl₇, setLocal_other _ _ (by omega),
      ← hl₆, setLocal_other _ _ (by omega)]
  have h35₈ : l₈ 35 = some (.ptr ⟨ta th 0, 0, .ptr .device (.scalar .bf16)⟩) := by
    rw [hl₈b 35 (by omega), hl₅ 35 (by omega) (by omega) (by omega), hl₃b 35 (by omega) (by omega) (by omega)]
    exact hR.g.l35
  have h52₈ : l₈ 52 = some (.ptr ⟨ta th 6, 0, .vec .f32 2⟩) := by rw [← hl₈, setLocal_same]
  have h49₈ : l₈ 49 = some (u32 (2176 * T.split + 8 * n + fnOf i)) := by
    rw [← hl₈, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact h49₇
  have h50₈ : l₈ 50 = some (.f32 (sval C I.S (2176 * T.split + 8 * n + fnOf i))) := by
    rw [← hl₈, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), ← hl₇, setLocal_same]
  have h51₈ : l₈ 51 = some (.f32 (sval C I.S (2176 * T.split + 8 * n + fnOf i + 1))) := by
    rw [← hl₈, setLocal_other _ _ (by omega), setLocal_same]
  obtain ⟨l₉, sh₉, x7, hm₉, hag₉, hoth₉, ha₉⟩ := exec_a C hS hp (ctx := ctx) (th := th) (T := T) hn hsplit hmB hl.hi
    (l := l₈) (sh := sh₇) h35₈ h52₈ h49₈ h50₈ h51₈ hm₇
    (by rw [hb₇, hoth₅ _ (by unfold ta; omega), hoth₄ _ (by unfold ta; omega), hoth₂ _ (by unfold ta; omega)]; exact hxm)
  have hbytes : ∀ r, (r < ta th 3 ∨ ta th 7 ≤ r) → sh₉.bytes r = sh.bytes r := fun r hr => by
    rw [hoth₉ r (by unfold ta at *; omega), hb₇, hoth₅ r (by unfold ta at *; omega), hoth₄ r (by unfold ta at *; omega),
      hoth₂ r (by unfold ta at *; omega)]
  refine ⟨setLocal l₉ 54 (u32 0), sh₉, ?_, ⟨hR.of_eq fun j hj => ?_, ?_, ?_, ?_⟩, setLocal_same _ _ _, hm₉, hbytes,
    fun m hm' => ?_, fun m h1 h2 => ?_, ha₉⟩
  · rw [rpre_eq]
    exact x1.append (x2.append (x3.append (x4.append (x5.append (x6.append (x7.append
      (.set (eval_u32lit C _ _ 0 (by decide)) (.nil _ _))))))))
  · rw [setLocal_other _ _ (by omega), hag₉ j (by omega), hl₈b j (by omega), hl₅ j (by omega) (by omega) (by omega),
      hl₃b j (by omega) (by omega) (by omega)]
  · rw [setLocal_other _ _ (by omega), hag₉ 45 (by omega), hl₈b 45 (by omega), hl₅ 45 (by omega) (by omega) (by omega)]
    exact h45₃
  · rw [setLocal_other _ _ (by omega), hag₉ 46 (by omega), hl₈b 46 (by omega), hl₅ 46 (by omega) (by omega) (by omega)]
    exact h46₃
  · rw [setLocal_other _ _ (by omega), hag₉ 52 (by omega), ← hl₈, setLocal_same]
  · rw [hoth₉ _ (by unfold ta; omega), hb₇, hoth₅ _ (by unfold ta; omega)]; exact hw₄ m hm'
  · rw [hoth₉ _ (by unfold ta; omega), hb₇]; exact hv₅ m h1 h2

end RowPre

end Metal.Kernels.DownWideRun

namespace Metal.Kernels.DownWideRun
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis
open Metal.Kernels.DownMmaWide (Tile p0Of fmOf fnOf laneOf eTile ePos eBk eSt eLane eReg outVal expected aReg bReg accReg
  cbHalf xval sval zero rcp Geo nGOf gyOf codesBytes In bufs)

/-! ### A sub-tile: `b`, then the multiply-accumulates -/

section SubTile
variable (C : M1Max.Contract) {p : Par} {L : Launch} {I : In} {ge : Nat} {outOk : Nat → Prop} {ctx : Ctx}
  {y z sg i : Nat}

/-- `codebook[state]` after the barrier. -/
theorem eval_cb (hS : Shape L p I) {l : Locals} {sh : Shared} {e : Nat} {b : Nat}
    (hm : Mem C p L I ge (fun _ => True) outOk sh) (h7 : l 7 = some (.ptr ⟨5, 0, .scalar .f16⟩))
    (hb : l b = some (u32 e)) (he : e < 4096) :
    (eval C ctx l (DownMmaWide.ld .f16 (DownMmaWide.ptrAt 7 (.local b)))).run sh =
      some (.f16 (cbHalf C e), rdn ctx sh 5 (2 * e) 2) := by
  have hp := eval_ptr_u32 C (ctx := ctx) (eval_local' C h7 sh) (eval_local' C hb sh) (by omega)
  rw [show e * (Ty.scalar .f16).bytes = 2 * e by simp [Ty.bytes, Scalar.bytes]; ring] at hp
  have hld := load_shared ctx .f16 sh 5 (2 * e) _ (by rw [hm.regions]; exact hS.r5) (by simp)
    (by simp [Scalar.bytes]) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset, Ty.bytes, Scalar.bytes])
  rw [show Scalar.f16.bytes = 2 from rfl, hm.cb e he trivial, ofWord_f16] at hld
  exact (eval_load C _ _ _ _ _ _ _ hp).trans hld

theorem spre_eq (k s : Nat) : DownMmaWide.spre k s =
    [.array 55 false 7 (.vec .f16 2), .set 56 (.local 45), .set 57 (.local 46), .set 58 (.local 54)] ++
      ([DownMmaWide.blockState k 56] ++ ([DownMmaWide.bStore 0 59] ++
      ([.set 63 (.local 45), .set 64 (.local 46), .set 65 (DownMmaWide.u32 .add (.local 54) (DownMmaWide.u32l s))] ++
      ([DownMmaWide.blockState k 63] ++ ([DownMmaWide.bStore 1 66] ++ [.set 70 (DownMmaWide.u32l 0)]))))) := rfl

/-- The state window of sub-tile position `t`, through `block_state` (slots `b …`), into `b`'s element `j`. -/
theorem exec_bstate (hS : Shape L p I) (hp : p.Ok) {th : Nat} {T : Tile} {n t b j : Nat} (ht : t < 2 * p.s)
    (hp0 : p0Of p.s T i + 2 * p.s ≤ 256) (hj : j < 2) (hge : ge ≠ ctx.group) {l : Locals} {sh : Shared}
    (hw : l b = some (.ptr ⟨ta th 4, 0, .scalar .u32⟩)) (hv : l (b + 1) = some (.ptr ⟨ta th 5, 0, .scalar .u32⟩))
    (htl : l (b + 2) = some (u32 t)) (h7 : l 7 = some (.ptr ⟨5, 0, .scalar .f16⟩))
    (h55 : l 55 = some (.ptr ⟨ta th 7, 0, .vec .f16 2⟩)) (hb55 : 55 < b)
    (hm : Mem C p L I ge (fun _ => True) outOk sh) (hwc : WArr p I.Cd T i n (sh.bytes (ta th 4)))
    (hvc : VArr p I.Cd T i n (sh.bytes (ta th 5))) :
    ∃ l' sh', Exec C ctx [DownMmaWide.blockState p.k b, .store (.scalar .f16) (.offset (.ptrCast (.scalar .f16)
        (.local 55)) (.lit (.int .i32 j))) (DownMmaWide.ld .f16 (DownMmaWide.ptrAt 7 (.local (b + 3))))] l sh .normal l' sh' ∧
      Mem C p L I ge (fun _ => True) outOk sh' ∧ (∀ j', j' < b + 3 ∨ b + 6 < j' → l' j' = l j') ∧
      (∀ r, r ≠ ta th 7 → sh'.bytes r = sh.bytes r) ∧
      sh'.bytes (ta th 7) = writeBytes (sh.bytes (ta th 7)) (2 * j)
        (wordBytes 2 (Val.f16Bits (cbHalf C (trellisCode p.k I.Cd (rowBase p T i n) (255 - (p0Of p.s T i + t)))))) := by
  have hk := hp.k; have hnw := hp.nw
  have hreg := hm.regions
  have htk : t * p.k + 16 < 32 * p.nw := by
    have : t * p.k ≤ (2 * p.s - 1) * p.k := Nat.mul_le_mul_right _ (by omega)
    omega
  obtain ⟨l₁, x1, h3, hag⟩ := exec_blockState C (ctx := ctx) p.k b (l := l) (sh := sh) (rw := ta th 4) (rv := ta th 5)
    (nw := p.nw) (t := t) (W := wW p I.Cd T i n) hw hv htl (by rw [hreg]; exact hS.t4 th) (by rw [hreg]; exact hS.t5 th)
    (fun m _ => wW_lt _ _ _ _ _ _) hwc (fun m h1 h2 => hvc m h1 h2) (by omega) (by omega) htk
  rw [state_eq hp I.Cd T i n t hp0 ht] at h3
  generalize hE : trellisCode p.k I.Cd (rowBase p T i n) (255 - (p0Of p.s T i + t)) = E at h3 ⊢
  have hEl : E < 4096 := by rw [← hE]; exact Nat.mod_lt _ (by decide)
  have hv := eval_cb C hS (ctx := ctx) (l := l₁) hm (by rw [hag 7 (.inl (by omega))]; exact h7) h3 hEl
  have h55₁ : l₁ 55 = some (.ptr ⟨ta th 7, 0, .vec .f16 2⟩) := by rw [hag 55 (.inl (by omega))]; exact h55
  have hpt : (eval C ctx l₁ (.offset (.ptrCast (.scalar .f16) (.local 55)) (.lit (.int .i32 j)))).run sh =
      some (.ptr ⟨ta th 7, ((2 * j : Nat) : Int), .scalar .f16⟩, sh) := by
    have h1 := eval_ptrCast C (ctx := ctx) (t := .scalar .f16) (eval_local' C h55₁ sh)
    have h2 := eval_offset_i32 C (ctx := ctx) (n := j) (o := 0) h1 (eval_lit C _ _ _ _) (by omega)
    rwa [show 0 + j * (Ty.scalar .f16).bytes = 2 * j by simp [Ty.bytes, Scalar.bytes]; ring] at h2
  have hst := store_thread ctx .f16 (rdn ctx sh 5 (2 * E) 2) (ta th 7) (2 * j) 4 4 (.f16 (cbHalf C E))
    (wordBytes 2 (Val.f16Bits (cbHalf C E))) (by rw [rdn_regions, hreg]; exact hS.t7 th) (by decide)
    (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (encode_f16 _)
  refine ⟨l₁, _, x1.append (.store hpt hv hst (.nil _ _)), (hm.rd hS ctx 5 (2 * E) 2 (.inr ⟨rfl, hge⟩)).tput _ _
    (by unfold ta; omega), hag, fun r hr => by rw [tput_other _ _ _ hr]; rfl, by rw [tput_same]; rfl⟩

/-- A sub-tile's prefix: `b`'s elements, the codebook entries of positions `p0 + st` and `p0 + S + st`. -/
theorem lane_spre (hS : Shape L p I) (hp : p.Ok) (hl : Lane p ctx y z sg i) {n st : Nat} (hst : st < p.s)
    (hge : ge ≠ ctx.group) {l : Locals} {sh : Shared}
    (hW : WLoc p (thOf p.s y z sg i) (tileOf p.s p.mt y z sg) i n l) (h54 : l 54 = some (u32 st))
    (hm : Mem C p L I ge (fun _ => True) outOk sh)
    (hwc : WArr p I.Cd (tileOf p.s p.mt y z sg) i n (sh.bytes (ta (thOf p.s y z sg i) 4)))
    (hvc : VArr p I.Cd (tileOf p.s p.mt y z sg) i n (sh.bytes (ta (thOf p.s y z sg i) 5))) :
    ∃ l' sh', Exec C ctx (DownMmaWide.spre p.k p.s) l sh .normal l' sh' ∧
      CLoc p (thOf p.s y z sg i) (tileOf p.s p.mt y z sg) i n st 0 l' ∧ Mem C p L I ge (fun _ => True) outOk sh' ∧
      (∀ r, r ≠ ta (thOf p.s y z sg i) 7 → sh'.bytes r = sh.bytes r) ∧
      BArr C p I (tileOf p.s p.mt y z sg) ⟨i, hl.hi⟩ n st (sh'.bytes (ta (thOf p.s y z sg i) 7)) := by
  have hp0 : p0Of p.s (tileOf p.s p.mt y z sg) i + 2 * p.s ≤ 256 := by
    simp only [p0Of, tileOf]
    have hq := (tile_facts hp hl.hy hl.hz hl.hsg).2.2.1
    simp only [tileOf] at hq
    have hfn := (lane_fm_fn i hl.hi).2.2.2
    rcases hp.sm with ⟨h1, -⟩ | ⟨h1, -⟩ | ⟨h1, -⟩ <;> rw [h1] at hq ⊢ <;> omega
  have hta := hl.ta
  have h7 := hW.r.g.s.fix.l7
  generalize hT : tileOf p.s p.mt y z sg = T at *
  generalize hth : thOf p.s y z sg i = th at *
  generalize hl₂ : setLocal (setLocal (setLocal (setLocal l 55 (.ptr ⟨ta th 7, 0, .vec .f16 2⟩)) 56
    (.ptr ⟨ta th 4, 0, .scalar .u32⟩)) 57 (.ptr ⟨ta th 5, 0, .scalar .u32⟩)) 58 (u32 st) = l₂
  have x1 : Exec C ctx [.array 55 false 7 (.vec .f16 2), .set 56 (.local 45), .set 57 (.local 46), .set 58 (.local 54)]
      l sh .normal l₂ sh := by
    rw [← hl₂]
    refine .array (.set (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact hW.l45) _)
      (.set (eval_local' C (by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact hW.l46) _)
      (.set (eval_local' C (by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega),
        setLocal_other _ _ (by omega)]; exact h54) _) ?_)))
    simp only [Bool.false_eq_true, ite_false, hta]; exact .nil _ _
  have hl₂b : ∀ j, j < 55 → l₂ j = l j := fun j hj => by
    rw [← hl₂]; simp (disch := omega) only [setLocal_lt]
  have h55₂ : l₂ 55 = some (.ptr ⟨ta th 7, 0, .vec .f16 2⟩) := by rw [← hl₂]; simp [setLocal]
  obtain ⟨l₃, sh₃, x2, hm₃, hag₃, hoth₃, hb₃⟩ := exec_bstate C hS hp (th := th) (T := T) (n := n) (t := st) (b := 56)
    (j := 0) (by omega) hp0 (by decide) hge (l := l₂) (sh := sh) (by rw [← hl₂]; simp [setLocal])
    (by rw [← hl₂]; simp [setLocal]) (by rw [← hl₂]; simp [setLocal]) (by rw [hl₂b 7 (by omega)]; exact h7) h55₂
    (by omega) hm hwc hvc
  have hl₃b : ∀ j, j < 59 → l₃ j = l₂ j := fun j hj => hag₃ j (.inl (by omega))
  generalize hl₄ : setLocal (setLocal (setLocal l₃ 63 (.ptr ⟨ta th 4, 0, .scalar .u32⟩)) 64
    (.ptr ⟨ta th 5, 0, .scalar .u32⟩)) 65 (u32 (st + p.s)) = l₄
  have x3 : Exec C ctx [.set 63 (.local 45), .set 64 (.local 46), .set 65 (DownMmaWide.u32 .add (.local 54)
      (DownMmaWide.u32l p.s))] l₃ sh₃ .normal l₄ sh₃ := by
    rw [← hl₄]
    exact .set (eval_local' C (by rw [hl₃b 45 (by omega), hl₂b 45 (by omega)]; exact hW.l45) _)
      (.set (eval_local' C (by rw [setLocal_other _ _ (by omega), hl₃b 46 (by omega), hl₂b 46 (by omega)]; exact hW.l46) _)
      (.set (eval_bin_u32 C (eval_local' C (by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega),
        hl₃b 54 (by omega), hl₂b 54 (by omega)]; exact h54) _) (eval_u32lit C _ _ p.s (by omega))
        (binary_add_u32 C st p.s)) (.nil _ _)))
  have hl₄b : ∀ j, j < 63 → l₄ j = l₃ j := fun j hj => by
    rw [← hl₄]; simp (disch := omega) only [setLocal_lt]
  obtain ⟨l₅, sh₅, x4, hm₅, hag₅, hoth₅, hb₅⟩ := exec_bstate C hS hp (th := th) (T := T) (n := n) (t := st + p.s)
    (b := 63) (j := 1) (by omega) hp0 (by decide) hge (l := l₄) (sh := sh₃) (by rw [← hl₄]; simp [setLocal])
    (by rw [← hl₄]; simp [setLocal]) (by rw [← hl₄]; simp [setLocal])
    (by rw [hl₄b 7 (by omega), hl₃b 7 (by omega), hl₂b 7 (by omega)]; exact h7)
    (by rw [hl₄b 55 (by omega), hl₃b 55 (by omega)]; exact h55₂) (by omega) hm₃
    (by rw [hoth₃ _ (by unfold ta; omega)]; exact hwc) (by rw [hoth₃ _ (by unfold ta; omega)]; exact hvc)
  have hl₅b : ∀ j, j < 66 → l₅ j = l₄ j := fun j hj => hag₅ j (.inl (by omega))
  refine ⟨setLocal l₅ 70 (u32 0), sh₅, ?_, ⟨hW.of_eq fun j hj => ?_, ?_, ?_, setLocal_same _ _ _⟩, hm₅,
    fun r hr => by rw [hoth₅ r hr, hoth₃ r hr], fun e => ?_⟩
  · rw [spre_eq]
    exact x1.append (x2.append (x3.append (x4.append (.set (eval_u32lit C _ _ 0 (by decide)) (.nil _ _)))))
  · rw [setLocal_other _ _ (by omega), hl₅b j (by omega), hl₄b j (by omega), hl₃b j (by omega), hl₂b j (by omega)]
  · rw [setLocal_other _ _ (by omega), hl₅b 54 (by omega), hl₄b 54 (by omega), hl₃b 54 (by omega), hl₂b 54 (by omega)]
    exact h54
  · rw [setLocal_other _ _ (by omega), hl₅b 55 (by omega), hl₄b 55 (by omega), hl₃b 55 (by omega)]; exact h55₂
  · rw [hb₅, hb₃]
    have hl2 := wordBytes_length 2 (Val.f16Bits (cbHalf C (trellisCode p.k I.Cd (rowBase p T i n)
      (255 - (p0Of p.s T i + st)))))
    have hl2' := wordBytes_length 2 (Val.f16Bits (cbHalf C (trellisCode p.k I.Cd (rowBase p T i n)
      (255 - (p0Of p.s T i + (st + p.s))))))
    rcases e with ⟨_ | _ | _, he⟩
    · show cells (writeBytes (writeBytes (sh.bytes (ta th 7)) (2 * 0) _) (2 * 1) _) (2 * 0) 2 = _
      rw [cells_writeBytes_other _ _ _ _ _ (by rw [hl2']; omega)]
      have := cells_writeBytes_same (sh.bytes (ta th 7)) (2 * 0) (wordBytes 2 (Val.f16Bits (cbHalf C (trellisCode p.k I.Cd
        (rowBase p T i n) (255 - (p0Of p.s T i + st))))))
      rw [hl2] at this; exact this
    · show cells (writeBytes (writeBytes (sh.bytes (ta th 7)) (2 * 0) _) (2 * 1) _) (2 * 1) 2 = _
      have := cells_writeBytes_same (writeBytes (sh.bytes (ta th 7)) (2 * 0) (wordBytes 2 (Val.f16Bits (cbHalf C
        (trellisCode p.k I.Cd (rowBase p T i n) (255 - (p0Of p.s T i + st))))))) (2 * 1)
        (wordBytes 2 (Val.f16Bits (cbHalf C (trellisCode p.k I.Cd (rowBase p T i n) (255 - (p0Of p.s T i + (st + p.s)))))))
      rw [hl2'] at this
      rw [this, show p0Of p.s T i + (st + p.s) = p0Of p.s T i + st + p.s * 1 by ring]; rfl
    · omega

/-- The operands of `simdgroup_multiply_accumulate(acc[st][bk], a[bk], b, acc[st][bk])`. -/
def collV (C : M1Max.Contract) (p : Par) (I : In) (T : Tile) (i : Fin 32) (n st bk c : Nat) : Val :=
  mmaArg .f32 .f16 (.f32 (aReg C p.M I.X I.S T n bk i 0), .f32 (aReg C p.M I.X I.S T n bk i 1))
    (.f16 (bReg C p.k p.il p.s I.Cd T n st i 0), .f16 (bReg C p.k p.il p.s I.Cd T n st i 1))
    (.f32 (accReg C p.k p.il p.s p.M I.X I.Cd I.S T st bk c i 0),
      .f32 (accReg C p.k p.il p.s p.M I.X I.Cd I.S T st bk c i 1))

/-- The lane stops at the multiply-accumulate of sub-tile `st`, block `bk`. -/
theorem exec_coll (hS : Shape L p I) (hp : p.Ok) {th : Nat} {T : Tile} {n st bk : Nat} {i' : Fin 32}
    {cnt : Nat → Nat → Nat} (hbk : bk < p.mt) (hst : st < p.s) {l : Locals} {sh : Shared}
    (hC : CLoc p th T i' n st bk l) (hreg : sh.regions = L.regions)
    (hacc : AccArr C p I T i' cnt (sh.bytes (ta th 1))) (ha : AArr C p I T i' n (sh.bytes (ta th 6)))
    (hb : BArr C p I T i' n st (sh.bytes (ta th 7))) :
    Exec C ctx (DownMmaWide.bkBody p.mt) l sh
      (.stop (.collective 2 71 (.mma .f32 .f16) .f32 (collV C p I T i' n st bk (cnt st bk)) 0)
        [.block [DownMmaWide.storeAcc p.mt]]) l sh := by
  have hmt : p.mt ≤ 3 ∧ p.s ≤ 16 := by rcases hp.sm with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> rw [h1, h2] <;> decide
  have hpa := eval_ptr_u32 C (ctx := ctx) (eval_local' C hC.w.l52 sh) (eval_local' C hC.l70 sh) (by omega)
  rw [show bk * (Ty.vec .f32 2).bytes = 8 * bk by simp [Ty.bytes, Scalar.bytes]; ring] at hpa
  have la := load_pair_f32 (ctx := ctx) (sh := sh) (reg := ta th 6) (size := 8 * p.mt) (o := 8 * bk)
    (x := aReg C p.M I.X I.S T n bk i' 0) (y := aReg C p.M I.X I.S T n bk i' 1) (by rw [hreg]; exact hS.t6 th) (by omega)
    (by omega) (by simpa using ha bk hbk 0) (by simpa using ha bk hbk 1)
  have lb := load_pair_f16 (ctx := ctx) (sh := sh) (reg := ta th 7) (size := 4) (al := 4) (o := 0)
    (x := bReg C p.k p.il p.s I.Cd T n st i' 0) (y := bReg C p.k p.il p.s I.Cd T n st i' 1) (by rw [hreg]; exact hS.t7 th)
    (by decide) (by decide) (by decide) (by simpa using hb 0) (by simpa using hb 1)
  have hpc := eval_accAt C (ctx := ctx) (mt := p.mt) (sE := .local 54) (bE := .local 70) hC.w.r.g.l36
    (eval_local' C hC.l54 sh) (eval_local' C hC.l70 sh) (by omega) (by omega) (by omega)
  have lc := load_pair_f32 (ctx := ctx) (sh := sh) (reg := ta th 1) (size := 8 * (p.s * p.mt)) (o := 8 * (st * p.mt + bk))
    (x := accReg C p.k p.il p.s p.M I.X I.Cd I.S T st bk (cnt st bk) i' 0)
    (y := accReg C p.k p.il p.s p.M I.X I.Cd I.S T st bk (cnt st bk) i' 1) (by rw [hreg]; exact hS.t1 th) (by omega)
    (by have := idx_lt (a := p.s) hst hbk; omega) (by simpa using hacc st hst bk hbk 0)
    (by simpa using hacc st hst bk hbk 1)
  exact .collective (eval_vector C (evalList_cons C ((eval_load C _ _ _ _ _ _ _ hpa).trans la)
    (evalList_cons C ((eval_load C _ _ _ _ _ _ _ (eval_local' C hC.l55 sh)).trans lb)
    (evalList_cons C ((eval_load C _ _ _ _ _ _ _ hpc).trans lc) (evalList_nil C))))) (eval_lit C _ _ _ _)
    (natOf_unsigned 0 rfl)

/-- `acc[st][bk] = D`. -/
theorem exec_storeAcc (hS : Shape L p I) (hp : p.Ok) {th : Nat} {T : Tile} {n st bk : Nat} {d0 d1 : Float32}
    (hbk : bk < p.mt) (hst : st < p.s) {l : Locals} {sh : Shared} (hC : CLoc p th T i n st bk l)
    (h71 : l 71 = some (.vec .f32 [.f32 d0, .f32 d1])) (hreg : sh.regions = L.regions) :
    Exec C ctx [DownMmaWide.storeAcc p.mt] l sh .normal l (tput sh (ta th 1) (8 * (st * p.mt + bk)) (pairBytes d0 d1)) := by
  have hmt : p.mt ≤ 3 ∧ p.s ≤ 16 := by rcases hp.sm with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> rw [h1, h2] <;> decide
  have hpc := eval_accAt C (ctx := ctx) (mt := p.mt) (sE := .local 54) (bE := .local 70) hC.w.r.g.l36
    (eval_local' C hC.l54 sh) (eval_local' C hC.l70 sh) (by omega) (by omega) (by omega)
  exact .store hpc (eval_local' C h71 sh) (store_pair_f32 d0 d1 (by rw [hreg]; exact hS.t1 th) (by omega)
    (by have := idx_lt (a := p.s) hst hbk; omega)) (.nil _ _)

end SubTile

end Metal.Kernels.DownWideRun

namespace Metal.Kernels.DownMmaWide
open Metal Metal.Core

def outPtr : CExpr :=
  .offset (.offset (.offset (.offset (.local 4)
      (u64 .mul (u64 .add (u64 .mul (toU64 (.local 73)) (u64l 8)) (toU64 (.local 19))) (u64l 5120)))
      (u64 .mul (toU64 (.local 20)) (u64l 256))) (u32l 255))
    (.un .neg .i64 (.conv .i64 (.local 27)))
def outStores (s mt : Nat) : List CStmt :=
  [.store (.scalar .f32) (.offset (.local 74) (.un .neg .i32 (.conv .i32 (.local 75))))
     (ld .f32 (.offset (.ptrCast (.scalar .f32) (accAt mt (.local 75) (.local 72))) (i32l 0))),
   .store (.scalar .f32) (.offset (.local 74) (.un .neg .i32 (.conv .i32 (u32 .add (u32l s) (.local 75)))))
     (ld .f32 (.offset (.ptrCast (.scalar .f32) (accAt mt (.local 75) (.local 72))) (i32l 1)))]

theorem outBody_eq (s mt : Nat) : outBody s mt =
    [.set 73 (u32 .add (u32 .add (.local 31) (u32 .mul (u32l 8) (.local 72))) (.local 22)),
     .ite (u32 .ge (.local 73) (.local 5)) [.continue_] [], .set 74 outPtr, .set 75 (u32l 0),
     .loop (lt 75 (u32l s)) (inc 75) (outStores s mt)] := rfl

end Metal.Kernels.DownMmaWide

namespace Metal.Kernels.DownWideRun
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis
open Metal.Kernels.DownMmaWide (Tile p0Of fmOf fnOf laneOf eTile ePos eBk eSt eLane eReg outVal expected aReg bReg accReg
  cbHalf xval sval zero rcp Geo nGOf gyOf codesBytes In bufs)

/-! ### After the row loop: the partials -/

section Out
variable (C : M1Max.Contract) {p : Par} {L : Launch} {I : In} {ge : Nat} {cbOk : Nat → Prop} {ctx : Ctx}
  {y z sg i : Nat}

theorem eBk_lt {mt : Nat} (h : 0 < mt) (E : Nat) : eBk mt E < mt := by
  unfold eBk
  have := Nat.mod_lt (E / 40960) (show 0 < 8 * mt by omega)
  omega

/-- The partials of block `bk`: elements `elemOf … bk st e` of the lane, from `acc[st][bk]` after the 272 row steps. -/
theorem exec_outStores (hS : Shape L p I) (hp : p.Ok) (hl : Lane p ctx y z sg i) {bk : Nat} (hbk : bk < p.mt)
    (hrow : 8 * p.mt * z + 8 * bk + fmOf i < p.M) {l : Locals} {sh : Shared}
    (hG : GLoc p (thOf p.s y z sg i) (tileOf p.s p.mt y z sg) i l) (h72 : l 72 = some (u32 bk))
    (h74 : l 74 = some (.ptr ⟨4, ((4 * (((8 * p.mt * z + 8 * bk + fmOf i) * 8 + (tileOf p.s p.mt y z sg).split) * 5120 +
      (tileOf p.s p.mt y z sg).block * 256 + 255 - p0Of p.s (tileOf p.s p.mt y z sg) i) : Nat) : Int), .scalar .f32⟩))
    (hm : Mem C p L I ge cbOk (fun E => eThread p.s p.mt E < thOf p.s y z sg i ∨
      (eThread p.s p.mt E = thOf p.s y z sg i ∧ eBk p.mt E < bk)) sh)
    (hacc : AccArr C p I (tileOf p.s p.mt y z sg) ⟨i, hl.hi⟩ (fun _ _ => 272) (sh.bytes (ta (thOf p.s y z sg i) 1))) :
    ∃ l' sh', Exec C ctx [.set 75 (DownMmaWide.u32l 0), .loop (DownMmaWide.lt 75 (DownMmaWide.u32l p.s))
        (DownMmaWide.inc 75) (DownMmaWide.outStores p.s p.mt)] l sh .normal l' sh' ∧
      (∀ j, j ≠ 75 → l' j = l j) ∧
      Mem C p L I ge cbOk (fun E => eThread p.s p.mt E < thOf p.s y z sg i ∨
        (eThread p.s p.mt E = thOf p.s y z sg i ∧ eBk p.mt E < bk + 1)) sh' ∧
      Keep (thOf p.s y z sg i) sh sh' ∧ (∀ j, j < 8 → sh'.bytes (ta (thOf p.s y z sg i) j) =
        sh.bytes (ta (thOf p.s y z sg i) j)) := by
  have hsm := hp.sm
  have hmt : 1 ≤ p.mt ∧ p.mt ≤ 3 ∧ 8 ≤ p.s ∧ p.s ≤ 16 := by
    rcases hsm with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> rw [h1, h2] <;> decide
  have hy := hl.hy; have hsg := hl.hsg; have hi := hl.hi
  have hp0 : p0Of p.s (tileOf p.s p.mt y z sg) i + 2 * p.s ≤ 256 := by
    simp only [p0Of, tileOf]
    have hq := (tile_facts hp hl.hy hl.hz hl.hsg).2.2.1
    simp only [tileOf] at hq
    have hfn := (lane_fm_fn i hl.hi).2.2.2
    rcases hp.sm with ⟨h1, -⟩ | ⟨h1, -⟩ | ⟨h1, -⟩ <;> rw [h1] at hq ⊢ <;> omega
  let O : Nat → Locals → Shared → Prop := fun m l' sh' => (∀ j, j ≠ 75 → l' j = l j) ∧ l' 75 = some (u32 m) ∧
    Mem C p L I ge cbOk (fun E => eThread p.s p.mt E < thOf p.s y z sg i ∨ (eThread p.s p.mt E = thOf p.s y z sg i ∧
      (eBk p.mt E < bk ∨ (eBk p.mt E = bk ∧ eSt p.s E < m)))) sh' ∧
    Keep (thOf p.s y z sg i) sh sh' ∧ (∀ j, j < 8 → sh'.bytes (ta (thOf p.s y z sg i) j) =
      sh.bytes (ta (thOf p.s y z sg i) j))
  obtain ⟨l', sh', hex, hO⟩ := Exec.loop_count (ctx := ctx) (C := C) (c := DownMmaWide.lt 75 (DownMmaWide.u32l p.s)) (st := DownMmaWide.inc 75)
    (b := DownMmaWide.outStores p.s p.mt) p.s O O
    (fun m hm l' sh' hO => ⟨sh', eval_lt_u32 C (ctx := ctx) hO.2.1 (by omega) (by omega), hO⟩)
    (fun m hm l' sh' hO => by
      obtain ⟨hag, h75, hm', hk, hfr⟩ := hO
      have hreg := hm'.regions
      have hEl : ∀ e < 2, elemOf p.s p.mt y z sg i bk m e < 40960 * p.M := by
        intro e he
        have h1 := (elem_fwd hsm (z := z) hy hsg hi hbk hm he).2.2.2.2.2.2.2
        have h2 : elemOf p.s p.mt y z sg i bk m e / 40960 < p.M := by rw [h1]; exact hrow
        have := (Nat.div_lt_iff_lt_mul (show 0 < 40960 by decide)).mp h2
        omega
      -- the element pointers
      have hE : ∀ e, e < 2 → 4 * elemOf p.s p.mt y z sg i bk m e = 4 * (((8 * p.mt * z + 8 * bk + fmOf i) * 8 +
          (tileOf p.s p.mt y z sg).split) * 5120 + (tileOf p.s p.mt y z sg).block * 256 + 255 -
          p0Of p.s (tileOf p.s p.mt y z sg) i) - (m + p.s * e) * (Ty.scalar .f32).bytes := by
        intro e he; unfold elemOf; simp only [Ty.bytes, Scalar.bytes]
        have : m + p.s * e < 2 * p.s := by rcases (show e = 0 ∨ e = 1 by omega) with rfl | rfl <;> omega
        omega
      have h74' : l' 74 = some (.ptr ⟨4, ((4 * (((8 * p.mt * z + 8 * bk + fmOf i) * 8 + (tileOf p.s p.mt y z sg).split) *
          5120 + (tileOf p.s p.mt y z sg).block * 256 + 255 - p0Of p.s (tileOf p.s p.mt y z sg) i) : Nat) : Int),
          .scalar .f32⟩) := by rw [hag 74 (by omega)]; exact h74
      have hval : ∀ (e : Nat) (shx : Shared) (he : e < 2), shx.regions = L.regions →
          shx.bytes (ta (thOf p.s y z sg i) 1) = sh.bytes (ta (thOf p.s y z sg i) 1) →
          (eval C ctx l' (DownMmaWide.ld .f32 (.offset (.ptrCast (.scalar .f32) (DownMmaWide.accAt p.mt (.local 75)
            (.local 72))) (.lit (.int .i32 e))))).run shx =
          some (.f32 (accReg C p.k p.il p.s p.M I.X I.Cd I.S (tileOf p.s p.mt y z sg) m bk 272 ⟨i, hi⟩ ⟨e, by omega⟩),
            shx) := by
        intro e shx he hrx hbx
        have hpc := eval_accAt C (ctx := ctx) (l := l') (sh := shx) (mt := p.mt) (sE := .local 75) (bE := .local 72)
          (by rw [hag 36 (by omega)]; exact hG.l36) (eval_local' C h75 shx)
          (eval_local' C (by rw [hag 72 (by omega)]; exact h72) shx) (by omega) (by omega) (by omega)
        have hp2 := eval_offset_i32 C (ctx := ctx) (n := e) (eval_ptrCast C (t := .scalar .f32) hpc) (eval_lit C _ _ _ _)
          (by omega)
        rw [show 8 * (m * p.mt + bk) + e * (Ty.scalar .f32).bytes = 8 * (m * p.mt + bk) + 4 * e by
          simp [Ty.bytes, Scalar.bytes]; ring] at hp2
        have hb := idx_lt (a := p.s) hm hbk
        unfold DownMmaWide.ld
        rw [eval_load C _ _ _ _ _ _ _ hp2, load_thread ctx .f32 shx _ _ (8 * (p.s * p.mt)) 8
          (by rw [hrx]; exact hS.t1 _) (by decide) (by simp [Scalar.bytes]; omega) (by simp [Scalar.bytes]; omega)]
        simp only [Scalar.bytes]
        have hc := hacc m hm bk hbk ⟨e, by omega⟩
        simp only at hc
        rw [hbx, hc, ofWord_f32]
      -- the two stores
      have hstore : ∀ (e : Nat) (iE : CExpr) (shx : Shared), e < 2 →
          (eval C ctx l' iE).run shx = some (.int .i32 ((-((m + p.s * e : Nat) : Int)) % 2 ^ 32).toNat, shx) →
          Mem C p L I ge cbOk (fun E => eThread p.s p.mt E < thOf p.s y z sg i ∨ (eThread p.s p.mt E = thOf p.s y z sg i ∧
            (eBk p.mt E < bk ∨ (eBk p.mt E = bk ∧ (eSt p.s E < m ∨ (eSt p.s E = m ∧ (eReg p.s E).val < e)))))) shx →
          shx.bytes (ta (thOf p.s y z sg i) 1) = sh.bytes (ta (thOf p.s y z sg i) 1) →
          ∃ shy, Exec C ctx [.store (.scalar .f32) (.offset (.local 74) iE) (DownMmaWide.ld .f32 (.offset (.ptrCast
            (.scalar .f32) (DownMmaWide.accAt p.mt (.local 75) (.local 72))) (.lit (.int .i32 e))))] l' shx .normal l' shy ∧
          Mem C p L I ge cbOk (fun E => eThread p.s p.mt E < thOf p.s y z sg i ∨ (eThread p.s p.mt E = thOf p.s y z sg i ∧
            (eBk p.mt E < bk ∨ (eBk p.mt E = bk ∧ (eSt p.s E < m ∨ (eSt p.s E = m ∧ (eReg p.s E).val < e + 1)))))) shy ∧
          shy = wrn ctx shx 4 (4 * elemOf p.s p.mt y z sg i bk m e) 4
            (wordBytes 4 (Val.f32Bits (p.outV C I (elemOf p.s p.mt y z sg i bk m e)))) := by
        intro e iE shx he hie hmx hbx
        obtain ⟨hT, hB, hS', hL, hR, hTh, hGr, hDiv⟩ := elem_fwd hsm (z := z) hy hsg hi hbk hm he
        have hlt2 : m + p.s * e < 2 * p.s := by rcases (show e = 0 ∨ e = 1 by omega) with rfl | rfl <;> omega
        have hsgn : Val.signed .i32 ((-((m + p.s * e : Nat) : Int)) % 2 ^ 32).toNat = -((m + p.s * e : Nat) : Int) :=
          signed_i32v (by omega) (by omega)
        have hpo := eval_offset_back C (ctx := ctx) (eval_local' C h74' shx) hie hsgn
          (by simp only [Ty.bytes, Scalar.bytes]; omega)
        rw [← hE e he] at hpo
        have hv := hval e shx he hmx.regions hbx
        have hov : accReg C p.k p.il p.s p.M I.X I.Cd I.S (tileOf p.s p.mt y z sg) m bk 272 ⟨i, hi⟩ ⟨e, by omega⟩ =
            p.outV C I (elemOf p.s p.mt y z sg i bk m e) := by
          unfold Par.outV outVal
          rw [hT, hS', hB, show (⟨i, hi⟩ : Fin 32) = eLane p.s (elemOf p.s p.mt y z sg i bk m e) from Fin.ext hL.symm,
            show (⟨e, by omega⟩ : Fin 2) = eReg p.s (elemOf p.s p.mt y z sg i bk m e) from Fin.ext hR.symm]
        rw [hov] at hv
        have hst := store_shared ctx .f32 shx 4 (4 * elemOf p.s p.mt y z sg i bk m e) _ _ _ (by rw [hmx.regions]; exact hS.r4)
          (by simp) (by simp) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; have := hEl e he; omega)
          (encode_f32 (p.outV C I (elemOf p.s p.mt y z sg i bk m e)))
        refine ⟨_, .store hpo hv hst (.nil _ _), ?_, rfl⟩
        have hw := hmx.wout hS ctx (elemOf p.s p.mt y z sg i bk m e) (hEl e he) (by rw [hl.thread, hTh]) (by rw [hl.group, hGr])
        refine hw.mono (fun _ _ h => h) (fun E hE' h => ?_)
        rcases h with h | ⟨h1, h | ⟨h2, h | ⟨h3, h4⟩⟩⟩
        · exact .inl (.inl h)
        · exact .inl (.inr ⟨h1, .inl h⟩)
        · exact .inl (.inr ⟨h1, .inr ⟨h2, .inl h⟩⟩)
        · by_cases h5 : (eReg p.s E).val < e
          · exact .inl (.inr ⟨h1, .inr ⟨h2, .inr ⟨h3, h5⟩⟩⟩)
          · right
            obtain ⟨hinv, -⟩ := elem_inv hsm hy hsg hi h1
            rw [hinv, h2, h3, show (eReg p.s E).val = e by omega]
      have hi0 : (eval C ctx l' (.un .neg .i32 (.conv .i32 (.local 75)))).run sh' =
          some (.int .i32 ((-((m + p.s * 0 : Nat) : Int)) % 2 ^ 32).toNat, sh') :=
        eval_neg_i32 C (eval_local' C h75 sh') (by omega)
      obtain ⟨sh₁, x1, hm₁, hsh₁⟩ := hstore 0 _ sh' (by decide) hi0 (hm'.mono (fun _ _ h => h) (fun E _ h => by
        rcases h with h | ⟨h1, h | ⟨h2, h | ⟨-, h⟩⟩⟩
        · exact .inl h
        · exact .inr ⟨h1, .inl h⟩
        · exact .inr ⟨h1, .inr ⟨h2, h⟩⟩
        · omega)) (by rw [hfr 1 (by omega)])
      have hb₁ : sh₁.bytes (ta (thOf p.s y z sg i) 1) = sh.bytes (ta (thOf p.s y z sg i) 1) := by
        rw [hsh₁, wrn_other _ _ _ _ _ (by unfold ta; omega), hfr 1 (by omega)]
      have hi1 : (eval C ctx l' (.un .neg .i32 (.conv .i32 (DownMmaWide.u32 .add (DownMmaWide.u32l p.s)
          (.local 75))))).run sh₁ = some (.int .i32 ((-((m + p.s * 1 : Nat) : Int)) % 2 ^ 32).toNat, sh₁) := by
        rw [show m + p.s * 1 = p.s + m by ring]
        exact eval_neg_i32 C (eval_bin_u32 C (eval_u32lit C _ _ _ (by omega)) (eval_local' C h75 sh₁)
          (binary_add_u32 C _ _)) (by omega)
      obtain ⟨sh₂, x2, hm₂, hsh₂⟩ := hstore 1 _ sh₁ (by decide) hi1 hm₁ hb₁
      refine ⟨.normal, l', sh₂, setLocal l' 75 (u32 (m + 1)), sh₂, .inl rfl, x1.append x2,
        .set (eval_bin_u32 C (eval_local' C h75 _) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C m 1)) (.nil _ _),
        fun j hj => by rw [setLocal_other _ _ hj]; exact hag j hj, setLocal_same _ _ _, ?_, ?_, ?_⟩
      · refine hm₂.mono (fun _ _ h => h) (fun E _ h => ?_)
        rcases h with h | ⟨h1, h | ⟨h2, h⟩⟩
        · exact .inl h
        · exact .inr ⟨h1, .inl h⟩
        · by_cases h3 : eSt p.s E < m
          · exact .inr ⟨h1, .inr ⟨h2, .inl h3⟩⟩
          · have := (eReg p.s E).isLt
            exact .inr ⟨h1, .inr ⟨h2, .inr ⟨by omega, by omega⟩⟩⟩
      · rw [hsh₂, hsh₁]; exact (hk.wrn4 _ _ _ _).wrn4 _ _ _ _
      · intro j hj
        rw [hsh₂, wrn_other _ _ _ _ _ (by unfold ta; omega), hsh₁, wrn_other _ _ _ _ _ (by unfold ta; omega)]
        exact hfr j hj)
    (l := setLocal l 75 (u32 0)) (sh := sh)
    ⟨fun j hj => setLocal_other _ _ hj, setLocal_same _ _ _, hm.mono (fun _ _ h => h) (fun E _ h => by
      rcases h with h | ⟨h1, h | ⟨-, h⟩⟩
      · exact .inl h
      · exact .inr ⟨h1, h⟩
      · omega), Keep.refl _ _, fun _ _ => rfl⟩
  obtain ⟨hag, -, hm', hk, hfr⟩ := hO
  refine ⟨l', sh', .set (eval_u32lit C _ _ 0 (by decide)) hex, hag, hm'.mono (fun _ _ h => h) (fun E _ h => ?_), hk, hfr⟩
  rcases h with h | ⟨h1, h⟩
  · exact .inl h
  · by_cases h2 : eBk p.mt E < bk
    · exact .inr ⟨h1, .inl h2⟩
    · have := (show eSt p.s E < p.s by unfold eSt; exact Nat.mod_lt _ (by omega))
      exact .inr ⟨h1, .inr ⟨by omega, this⟩⟩

/-- The partials' pointer `out` of row `m` (slot 73). -/
theorem eval_outPtr (hp : p.Ok) {th : Nat} {T : Tile} {m : Nat} {l : Locals} {sh : Shared} (hG : GLoc p th T i l)
    (h73 : l 73 = some (u32 m)) (hmM : m < p.M) (hsplit : T.split < 8) (hblock : T.block < 20)
    (hp0 : p0Of p.s T i ≤ 255) :
    (eval C ctx l DownMmaWide.outPtr).run sh =
      some (.ptr ⟨4, ((4 * ((m * 8 + T.split) * 5120 + T.block * 256 + 255 - p0Of p.s T i) : Nat) : Int), .scalar .f32⟩,
        sh) := by
  have hM := hp.m2
  have hs := hG.s
  have hA := eval_int C (ctx := ctx) (l := l) (sh := sh) (op := .mul) (s := .u64) (site := 0) (by decide)
    (eval_int C (op := .add) (s := .u64) (site := 0) (by decide)
      (eval_int C (op := .mul) (s := .u64) (site := 0) (by decide)
        (eval_conv C (t := .u64) (eval_local' C h73 sh) (convert_u64_u32 C _ (by omega)))
        (eval_u64lit C _ _ 8 (by decide)) (binary_mul_u64 C m 8))
      (eval_conv C (t := .u64) (eval_local' C hs.l19 sh) (convert_u64_u32 C _ (by omega))) (binary_add_u64 C _ _))
    (eval_u64lit C _ _ 5120 (by decide)) (binary_mul_u64 C _ 5120)
  have h1 := eval_offset_u64 C (ctx := ctx) (o := 0) (eval_local' C hs.fix.l4 sh) hA (by omega)
  have hB := eval_int C (ctx := ctx) (l := l) (sh := sh) (op := .mul) (s := .u64) (site := 0) (by decide)
    (eval_conv C (t := .u64) (eval_local' C hs.l20 sh) (convert_u64_u32 C _ (by omega)))
    (eval_u64lit C _ _ 256 (by decide)) (binary_mul_u64 C _ 256)
  have h2 := eval_offset_u64 C (ctx := ctx) h1 hB (by omega)
  have h3 := eval_offset_u32 C (ctx := ctx) h2 (eval_u32lit C _ _ 255 (by decide)) (by decide)
  have hn := eval_neg_i64 C (ctx := ctx) (l := l) (sh := sh) (eval_local' C hs.l27 sh) (by omega)
  have h4 := eval_offset_back C (ctx := ctx) h3 hn (signed_i64v (by omega) (by omega)) (by simp [Ty.bytes, Scalar.bytes]; omega)
  rw [show 0 + (m * 8 + T.split) * 5120 * (Ty.scalar .f32).bytes + T.block * 256 * (Ty.scalar .f32).bytes +
    255 * (Ty.scalar .f32).bytes - p0Of p.s T i * (Ty.scalar .f32).bytes =
    4 * ((m * 8 + T.split) * 5120 + T.block * 256 + 255 - p0Of p.s T i) by simp [Ty.bytes, Scalar.bytes]; omega] at h4
  exact h4

/-- The partials of the lane's rows (`outPart`). -/
theorem lane_out (hS : Shape L p I) (hp : p.Ok) (hl : Lane p ctx y z sg i) {l : Locals} {sh : Shared}
    (hG : GLoc p (thOf p.s y z sg i) (tileOf p.s p.mt y z sg) i l)
    (hm : Mem C p L I ge cbOk (fun E => eThread p.s p.mt E < thOf p.s y z sg i) sh)
    (hacc : AccArr C p I (tileOf p.s p.mt y z sg) ⟨i, hl.hi⟩ (fun _ _ => 272) (sh.bytes (ta (thOf p.s y z sg i) 1))) :
    ∃ l' sh', Exec C ctx (DownMmaWide.outPart p.s p.mt) l sh .normal l' sh' ∧
      Mem C p L I ge cbOk (fun E => eThread p.s p.mt E < thOf p.s y z sg i + 1) sh' ∧
      Keep (thOf p.s y z sg i) sh sh' := by
  have hsm := hp.sm
  have hmt : 1 ≤ p.mt ∧ p.mt ≤ 3 := by rcases hsm with ⟨-, h⟩ | ⟨-, h⟩ | ⟨-, h⟩ <;> rw [h] <;> decide
  have hM := hp.m2
  obtain ⟨hsplit, hblock, -, -, hmB⟩ := tile_facts hp hl.hy hl.hz hl.hsg
  have hfm := (lane_fm_fn i hl.hi).2.1
  have hp0 : p0Of p.s (tileOf p.s p.mt y z sg) i + 2 * p.s ≤ 256 := by
    simp only [p0Of, tileOf]
    have hq := (tile_facts hp hl.hy hl.hz hl.hsg).2.2.1
    simp only [tileOf] at hq
    have hfn := (lane_fm_fn i hl.hi).2.2.2
    rcases hp.sm with ⟨h1, -⟩ | ⟨h1, -⟩ | ⟨h1, -⟩ <;> rw [h1] at hq ⊢ <;> omega
  let Q : Nat → Locals → Shared → Prop := fun k l' sh' =>
    (∀ j, j ≠ 72 → j ≠ 73 → j ≠ 74 → j ≠ 75 → l' j = l j) ∧ l' 72 = some (u32 k) ∧
    Mem C p L I ge cbOk (fun E => eThread p.s p.mt E < thOf p.s y z sg i ∨
      (eThread p.s p.mt E = thOf p.s y z sg i ∧ eBk p.mt E < k)) sh' ∧
    Keep (thOf p.s y z sg i) sh sh' ∧ (∀ j, j < 8 → sh'.bytes (ta (thOf p.s y z sg i) j) =
      sh.bytes (ta (thOf p.s y z sg i) j))
  obtain ⟨l', sh', hex, hQ⟩ := Exec.loop_count (ctx := ctx) (C := C) (c := DownMmaWide.lt 72 (DownMmaWide.u32l p.mt)) (st := DownMmaWide.inc 72)
    (b := DownMmaWide.outBody p.s p.mt) p.mt Q Q
    (fun k hk l' sh' hQ => ⟨sh', eval_lt_u32 C (ctx := ctx) hQ.2.1 (by omega) (by omega), hQ⟩)
    (fun k hk l' sh' hQ => by
      obtain ⟨hag, h72, hm', hkp, hfr⟩ := hQ
      have hG' : GLoc p (thOf p.s y z sg i) (tileOf p.s p.mt y z sg) i l' :=
        hG.of_eq fun j hj => hag j (by omega) (by omega) (by omega) (by omega)
      have e73 : (eval C ctx l' (DownMmaWide.u32 .add (DownMmaWide.u32 .add (.local 31) (DownMmaWide.u32 .mul
          (DownMmaWide.u32l 8) (.local 72))) (.local 22))).run sh' = some (u32 (8 * p.mt * z + 8 * k + fmOf i), sh') := by
        rw [← hmB]
        exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C hG'.s.l31 sh') (eval_bin_u32 C (eval_u32lit C _ _ 8 (by decide))
          (eval_local' C h72 sh') (binary_mul_u32 C 8 k)) (binary_add_u32 C _ _)) (eval_local' C hG'.s.l22 sh')
          (binary_add_u32 C _ _)
      have hmB' : (tileOf p.s p.mt y z sg).mBase < p.M := (tile_facts hp hl.hy hl.hz hl.hsg).2.2.2.1
      have h73 : (setLocal l' 73 (u32 (8 * p.mt * z + 8 * k + fmOf i))) 73 = some (u32 (8 * p.mt * z + 8 * k + fmOf i)) :=
        setLocal_same _ _ _
      have hc : (eval C ctx (setLocal l' 73 (u32 (8 * p.mt * z + 8 * k + fmOf i))) (DownMmaWide.u32 .ge (.local 73)
          (.local 5))).run sh' = some (.bool (decide (p.M ≤ 8 * p.mt * z + 8 * k + fmOf i)), sh') :=
        eval_bin_u32 C (eval_local' C h73 sh') (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact hG'.s.fix.l5) sh')
          (binary_ge_u32 C _ _ (by omega) (by omega))
      by_cases hrow : p.M ≤ 8 * p.mt * z + 8 * k + fmOf i
      · rw [decide_eq_true hrow] at hc
        refine ⟨.continue_, _, sh', setLocal (setLocal l' 73 (u32 (8 * p.mt * z + 8 * k + fmOf i))) 72 (u32 (k + 1)), sh',
          .inr rfl, ?_, .set (eval_bin_u32 C (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact h72) _)
            (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C k 1)) (.nil _ _), ?_, setLocal_same _ _ _, ?_, hkp, hfr⟩
        · rw [DownMmaWide.outBody_eq]
          exact .set e73 (.ite_exit hc .continue_ (.inl rfl))
        · intro j h1 h2 h3 h4
          rw [setLocal_other _ _ h1, setLocal_other _ _ h2]; exact hag j h1 h2 h3 h4
        · refine hm'.mono (fun _ _ h => h) (fun E hE h => ?_)
          rcases h with h | ⟨h1, h2⟩
          · exact .inl h
          · by_cases h3 : eBk p.mt E < k
            · exact .inr ⟨h1, h3⟩
            · exfalso
              obtain ⟨-, hrow'⟩ := elem_inv hsm hl.hy hl.hsg hl.hi h1
              have hk' : eBk p.mt E = k := by omega
              have := (Nat.div_lt_iff_lt_mul (show 0 < 40960 by decide)).mpr (show E < p.M * 40960 by omega)
              omega
      · rw [decide_eq_false hrow] at hc
        have hmM : 8 * p.mt * z + 8 * k + fmOf i < p.M := by omega
        have e74 := eval_outPtr C (ctx := ctx) hp (sh := sh')
          (hG'.of_eq (l' := setLocal l' 73 (u32 (8 * p.mt * z + 8 * k + fmOf i))) fun j hj =>
            setLocal_other _ _ (by omega)) h73 hmM hsplit hblock (by omega)
        generalize hl₁ : setLocal (setLocal l' 73 (u32 (8 * p.mt * z + 8 * k + fmOf i))) 74
          (.ptr ⟨4, ((4 * (((8 * p.mt * z + 8 * k + fmOf i) * 8 + (tileOf p.s p.mt y z sg).split) * 5120 +
            (tileOf p.s p.mt y z sg).block * 256 + 255 - p0Of p.s (tileOf p.s p.mt y z sg) i) : Nat) : Int),
            .scalar .f32⟩) = l₁
        have h72₁ : l₁ 72 = some (u32 k) := by
          rw [← hl₁, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact h72
        obtain ⟨l₂, sh₂, x2, hag₂, hm₂, hk₂, hfr₂⟩ := exec_outStores C hS hp hl hk hmM (l := l₁) (sh := sh')
          (by rw [← hl₁]; exact hG'.of_eq fun j hj => by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)])
          h72₁ (by rw [← hl₁, setLocal_same]) hm' (by rw [hfr 1 (by omega)]; exact hacc)
        have h72₂ : l₂ 72 = some (u32 k) := by rw [hag₂ 72 (by omega)]; exact h72₁
        refine ⟨.normal, l₂, sh₂, setLocal l₂ 72 (u32 (k + 1)), sh₂, .inl rfl, ?_,
          .set (eval_bin_u32 C (eval_local' C h72₂ _) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C k 1))
            (.nil _ _), fun j h1 h2 h3 h4 => ?_, setLocal_same _ _ _, hm₂, hkp.trans hk₂,
          fun j hj => by rw [hfr₂ j hj, hfr j hj]⟩
        · rw [DownMmaWide.outBody_eq]
          exact .set e73 (.ite hc (.nil _ _) (.set e74 (by rw [hl₁]; exact x2)))
        · rw [setLocal_other _ _ h1, hag₂ j h4, ← hl₁, setLocal_other _ _ h3, setLocal_other _ _ h2]
          exact hag j h1 h2 h3 h4)
    (l := setLocal l 72 (u32 0)) (sh := sh)
    ⟨fun j h1 _ _ _ => setLocal_other _ _ h1, setLocal_same _ _ _, hm.mono (fun _ _ h => h) (fun E _ h => by
      rcases h with h | ⟨-, h⟩
      · exact h
      · omega), Keep.refl _ _, fun _ _ => rfl⟩
  obtain ⟨-, -, hm', hk, -⟩ := hQ
  refine ⟨l', sh', .set (eval_u32lit C _ _ 0 (by decide)) hex, hm'.mono (fun _ _ h => h) (fun E _ h => ?_), hk⟩
  by_cases h1 : eThread p.s p.mt E < thOf p.s y z sg i
  · exact .inl h1
  · exact .inr ⟨by omega, eBk_lt (by omega) E⟩

end Out

end Metal.Kernels.DownWideRun

namespace Metal.Kernels.DownWideRun
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis
open Metal.Kernels.DownMmaWide (Tile p0Of fmOf fnOf laneOf eTile ePos eBk eSt eLane eReg outVal expected aReg bReg accReg
  cbHalf xval sval zero rcp Geo nGOf gyOf codesBytes In bufs)

/-! ### The multiply-accumulates in order -/

/-- The SIMD-group's collectives: `272·S·MT`, the `c`-th at row step `nOf c`, sub-tile `stOf c`, block `bkOf c`. -/
def Par.T (p : Par) : Nat := 272 * (p.s * p.mt)
def nOf (p : Par) (c : Nat) : Nat := c / (p.s * p.mt)
def stOf (p : Par) (c : Nat) : Nat := c % (p.s * p.mt) / p.mt
def bkOf (p : Par) (c : Nat) : Nat := c % p.mt
/-- The row steps `acc[s'][b]` has taken before the `c`-th collective. -/
def cntOf (p : Par) (c : Nat) (s' b : Nat) : Nat := c / (p.s * p.mt) + if s' * p.mt + b < c % (p.s * p.mt) then 1 else 0

section Stages
variable {p : Par}

theorem stage_lt (hp : p.Ok) {c : Nat} (hc : c < p.T) : nOf p c < 272 ∧ stOf p c < p.s ∧ bkOf p c < p.mt := by
  unfold Par.T at hc
  unfold nOf stOf bkOf
  rcases hp.sm with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> rw [h1, h2] at hc ⊢ <;> omega

theorem stage_next (hp : p.Ok) (c : Nat) :
    (bkOf p c + 1 < p.mt → nOf p (c + 1) = nOf p c ∧ stOf p (c + 1) = stOf p c ∧ bkOf p (c + 1) = bkOf p c + 1) ∧
    (bkOf p c + 1 = p.mt → stOf p c + 1 < p.s → nOf p (c + 1) = nOf p c ∧ stOf p (c + 1) = stOf p c + 1 ∧
      bkOf p (c + 1) = 0) ∧
    (bkOf p c + 1 = p.mt → stOf p c + 1 = p.s → nOf p (c + 1) = nOf p c + 1 ∧ stOf p (c + 1) = 0 ∧ bkOf p (c + 1) = 0) := by
  unfold nOf stOf bkOf
  rcases hp.sm with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> rw [h1, h2] <;> omega

theorem cnt_succ (hp : p.Ok) (c : Nat) {s' b : Nat} (hs : s' < p.s) (hb : b < p.mt) :
    cntOf p (c + 1) s' b = if s' = stOf p c ∧ b = bkOf p c then cntOf p c s' b + 1 else cntOf p c s' b := by
  unfold cntOf stOf bkOf
  rcases hp.sm with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> rw [h1] at hs <;> rw [h2] at hb <;> rw [h1, h2] <;> split_ifs <;>
    omega

theorem cnt_self (hp : p.Ok) (c : Nat) : cntOf p c (stOf p c) (bkOf p c) = nOf p c := by
  unfold cntOf stOf bkOf nOf
  rcases hp.sm with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> rw [h1, h2] <;> split_ifs <;> omega

theorem cnt_zero (s' b : Nat) : cntOf p 0 s' b = 0 := by simp [cntOf]

theorem cnt_T (hp : p.Ok) {s' b : Nat} (hs : s' < p.s) (hb : b < p.mt) : cntOf p p.T s' b = 272 := by
  unfold cntOf Par.T
  rcases hp.sm with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> rw [h1] at hs <;> rw [h2] at hb <;> rw [h1, h2] <;> split_ifs <;>
    omega

theorem stage_last (hp : p.Ok) : nOf p (p.T - 1) = 271 ∧ stOf p (p.T - 1) + 1 = p.s ∧ bkOf p (p.T - 1) + 1 = p.mt := by
  unfold nOf stOf bkOf Par.T
  rcases hp.sm with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> rw [h1, h2] <;> decide

end Stages

/-- A lane's thread memory at its `c`-th collective. -/
structure TMem (C : M1Max.Contract) (p : Par) (I : In) (th : Nat) (T : Tile) (i : Fin 32) (c : Nat) (sh : Shared) :
    Prop where
  xm : XmArr p T i (sh.bytes (ta th 0))
  acc : AccArr C p I T i (cntOf p c) (sh.bytes (ta th 1))
  wa : WaArr p T i (sh.bytes (ta th 2))
  w : WArr p I.Cd T i (nOf p c) (sh.bytes (ta th 4))
  v : VArr p I.Cd T i (nOf p c) (sh.bytes (ta th 5))
  a : AArr C p I T i (nOf p c) (sh.bytes (ta th 6))
  b : BArr C p I T i (nOf p c) (stOf p c) (sh.bytes (ta th 7))

theorem TMem.congr {C : M1Max.Contract} {p : Par} {I : In} {th : Nat} {T : Tile} {i : Fin 32} {c : Nat} {sh sh' : Shared}
    (h : TMem C p I th T i c sh) (hb : ∀ j, j < 8 → sh'.bytes (ta th j) = sh.bytes (ta th j)) :
    TMem C p I th T i c sh' :=
  ⟨by rw [hb 0 (by omega)]; exact h.xm, by rw [hb 1 (by omega)]; exact h.acc, by rw [hb 2 (by omega)]; exact h.wa,
    by rw [hb 4 (by omega)]; exact h.w, by rw [hb 5 (by omega)]; exact h.v, by rw [hb 6 (by omega)]; exact h.a,
    by rw [hb 7 (by omega)]; exact h.b⟩

/-! ### The frames at a collective -/

def innerB (p : Par) : List Frame :=
  [.block [DownMmaWide.storeAcc p.mt], .loop (DownMmaWide.bC p.mt) (DownMmaWide.inc 70) (DownMmaWide.bkBody p.mt),
    .block []]
def innerS (p : Par) : List Frame :=
  innerB p ++ [.loop (DownMmaWide.sC p.s) (DownMmaWide.inc 54) (DownMmaWide.subTile p.k p.s p.mt), .block []]
def innerR (p : Par) : List Frame :=
  innerS p ++ [.loop DownMmaWide.rC DownMmaWide.rSt (DownMmaWide.rowBody p.k p.s p.mt p.nw),
    .block (DownMmaWide.outPart p.s p.mt)]
/-- Below the row body: the row loop, `outPart`, the body's scope. -/
def Kr (p : Par) : List Frame :=
  [.loop DownMmaWide.rC DownMmaWide.rSt (DownMmaWide.rowBody p.k p.s p.mt p.nw), .block (DownMmaWide.outPart p.s p.mt),
    .scope, .block []]
def Ks (p : Par) : List Frame :=
  .loop (DownMmaWide.sC p.s) (DownMmaWide.inc 54) (DownMmaWide.subTile p.k p.s p.mt) :: .block [] :: Kr p
/-- A lane's frames at a collective. -/
def Fc (p : Par) : List Frame := innerR p ++ [.scope, .block []]

/-- The lane's status at its `c`-th collective. -/
def collSt (C : M1Max.Contract) (p : Par) (I : In) (T : Tile) (i : Fin 32) (c : Nat) : Status :=
  .collective 2 71 (.mma .f32 .f16) .f32 (collV C p I T i (nOf p c) (stOf p c) (bkOf p c) (nOf p c)) 0

/-- The collective's result in a lane: its registers of `acc[st][bk]` after one more row step. -/
def resV (C : M1Max.Contract) (p : Par) (I : In) (T : Tile) (i : Fin 32) (c : Nat) : Val :=
  .vec .f32 [.f32 (accReg C p.k p.il p.s p.M I.X I.Cd I.S T (stOf p c) (bkOf p c) (nOf p c + 1) i 0),
    .f32 (accReg C p.k p.il p.s p.M I.X I.Cd I.S T (stOf p c) (bkOf p c) (nOf p c + 1) i 1)]

/-- The SIMD-group resolves its `c`-th collective. -/
theorem resolve_coll (C : M1Max.Contract) (p : Par) (I : In) (T : Tile) (c : Nat) :
    resolve C (.mma .f32 .f16) .f32 0
      (List.ofFn fun i => collV C p I T i (nOf p c) (stOf p c) (bkOf p c) (nOf p c)) =
    some (List.ofFn fun i => resV C p I T i c) :=
  resolve_mma_halfB C 0 (aReg C p.M I.X I.S T (nOf p c) (bkOf p c)) (bReg C p.k p.il p.s I.Cd T (nOf p c) (stOf p c))
    (accReg C p.k p.il p.s p.M I.X I.Cd I.S T (stOf p c) (bkOf p c) (nOf p c))

end Metal.Kernels.DownWideRun

namespace Metal.Kernels.DownWideRun
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis
open Metal.Kernels.DownMmaWide (Tile p0Of fmOf fnOf laneOf eTile ePos eBk eSt eLane eReg outVal expected aReg bReg accReg
  cbHalf xval sval zero rcp Geo nGOf gyOf codesBytes In bufs)

/-! ### A lane from collective to collective -/

section Lane2
variable (C : M1Max.Contract) {p : Par} {L : Launch} {I : In} {ge : Nat} {outOk : Nat → Prop} {ctx : Ctx}
  {y z sg i : Nat}

local notation "TH" => thOf p.s y z sg i
local notation "TT" => tileOf p.s p.mt y z sg

/-- A sub-tile from its start to its first multiply-accumulate. -/
theorem sub_body (hS : Shape L p I) (hp : p.Ok) (hl : Lane p ctx y z sg i) {n st : Nat} (hst : st < p.s)
    (hge : ge ≠ ctx.group) {cnt : Nat → Nat → Nat} {l : Locals} {sh : Shared}
    (hW : WLoc p TH TT i n l) (h54 : l 54 = some (u32 st)) (hm : Mem C p L I ge (fun _ => True) outOk sh)
    (hwc : WArr p I.Cd TT i n (sh.bytes (ta TH 4))) (hvc : VArr p I.Cd TT i n (sh.bytes (ta TH 5)))
    (ha : AArr C p I TT ⟨i, hl.hi⟩ n (sh.bytes (ta TH 6))) (hacc : AccArr C p I TT ⟨i, hl.hi⟩ cnt (sh.bytes (ta TH 1))) :
    ∃ l' sh', Exec C ctx (DownMmaWide.subTile p.k p.s p.mt) l sh
        (.stop (.collective 2 71 (.mma .f32 .f16) .f32 (collV C p I TT ⟨i, hl.hi⟩ n st 0 (cnt st 0)) 0) (innerB p)) l' sh' ∧
      CLoc p TH TT i n st 0 l' ∧ Mem C p L I ge (fun _ => True) outOk sh' ∧
      (∀ r, r ≠ ta TH 7 → sh'.bytes r = sh.bytes r) ∧ BArr C p I TT ⟨i, hl.hi⟩ n st (sh'.bytes (ta TH 7)) := by
  have hmt : 1 ≤ p.mt ∧ p.mt ≤ 3 := by rcases hp.sm with ⟨-, h⟩ | ⟨-, h⟩ | ⟨-, h⟩ <;> rw [h] <;> decide
  obtain ⟨l₁, sh₁, x1, hC₁, hm₁, hoth₁, hb₁⟩ := lane_spre C hS hp hl hst hge hW h54 hm hwc hvc
  have hc : (eval C ctx l₁ (DownMmaWide.bC p.mt)).run sh₁ = some (.bool true, sh₁) := by
    have := eval_lt_u32 C (ctx := ctx) (sh := sh₁) (b := p.mt) hC₁.l70 (by omega) (by omega)
    rwa [decide_eq_true (show 0 < p.mt by omega)] at this
  have xc := exec_coll C hS hp (ctx := ctx) (th := TH) (T := TT) (n := n) (st := st) (bk := 0) (i' := ⟨i, hl.hi⟩)
    (cnt := cnt) (by omega) hst hC₁ hm₁.regions (by rw [hoth₁ _ (by unfold ta; omega)]; exact hacc)
    (by rw [hoth₁ _ (by unfold ta; omega)]; exact ha) hb₁
  refine ⟨l₁, sh₁, ?_, hC₁, hm₁, hoth₁, hb₁⟩
  rw [DownMmaWide.subTile_eq]
  exact x1.append (.loop_stop hc xc)

/-- A row step from its start to its first multiply-accumulate. -/
theorem row_body (hS : Shape L p I) (hp : p.Ok) (hl : Lane p ctx y z sg i) {n : Nat} (hn : n < 272)
    (hge : ge ≠ ctx.group) {cnt : Nat → Nat → Nat} {l : Locals} {sh : Shared}
    (hR : RLoc p TH TT i n l) (hm : Mem C p L I ge (fun _ => True) outOk sh)
    (hxm : XmArr p TT i (sh.bytes (ta TH 0))) (hwa : WaArr p TT i (sh.bytes (ta TH 2)))
    (hacc : AccArr C p I TT ⟨i, hl.hi⟩ cnt (sh.bytes (ta TH 1))) :
    ∃ l' sh', Exec C ctx (DownMmaWide.rowBody p.k p.s p.mt p.nw) l sh
        (.stop (.collective 2 71 (.mma .f32 .f16) .f32 (collV C p I TT ⟨i, hl.hi⟩ n 0 0 (cnt 0 0)) 0) (innerS p)) l' sh' ∧
      CLoc p TH TT i n 0 0 l' ∧ Mem C p L I ge (fun _ => True) outOk sh' ∧
      (∀ r, (r < ta TH 3 ∨ ta TH 8 ≤ r) → sh'.bytes r = sh.bytes r) ∧
      WArr p I.Cd TT i n (sh'.bytes (ta TH 4)) ∧ VArr p I.Cd TT i n (sh'.bytes (ta TH 5)) ∧
      AArr C p I TT ⟨i, hl.hi⟩ n (sh'.bytes (ta TH 6)) ∧ BArr C p I TT ⟨i, hl.hi⟩ n 0 (sh'.bytes (ta TH 7)) := by
  have hs8 : 8 ≤ p.s ∧ p.s ≤ 16 := by rcases hp.sm with ⟨h, -⟩ | ⟨h, -⟩ | ⟨h, -⟩ <;> rw [h] <;> decide
  obtain ⟨l₁, sh₁, x1, hW₁, h54, hm₁, hoth₁, hw₁, hv₁, ha₁⟩ := lane_rpre C hS hp hl hn hR hm hxm hwa
  have hc : (eval C ctx l₁ (DownMmaWide.sC p.s)).run sh₁ = some (.bool true, sh₁) := by
    have := eval_lt_u32 C (ctx := ctx) (sh := sh₁) (b := p.s) h54 (by omega) (by omega)
    rwa [decide_eq_true (show 0 < p.s by omega)] at this
  obtain ⟨l₂, sh₂, x2, hC₂, hm₂, hoth₂, hb₂⟩ := sub_body C hS hp hl (n := n) (st := 0) (by omega) hge (cnt := cnt) hW₁ h54
    hm₁ hw₁ hv₁ ha₁ (by rw [hoth₁ _ (by unfold ta; omega)]; exact hacc)
  refine ⟨l₂, sh₂, ?_, hC₂, hm₂, fun r hr => ?_, ?_, ?_, ?_, hb₂⟩
  · rw [DownMmaWide.rowBody_eq]
    exact x1.append (.loop_stop hc x2)
  · rw [hoth₂ r (by unfold ta at *; omega), hoth₁ r (by unfold ta at *; omega)]
  · rw [hoth₂ _ (by unfold ta; omega)]; exact hw₁
  · rw [hoth₂ _ (by unfold ta; omega)]; exact hv₁
  · rw [hoth₂ _ (by unfold ta; omega)]; exact ha₁

/-- A lane at its `c`-th collective. -/
def AtColl (C : M1Max.Contract) (p : Par) (I : In) (ctx : Ctx) (th : Nat) (T : Tile) (i : Fin 32) (c : Nat)
    (t : Thread) : Prop :=
  t.ctx = ctx ∧ t.frames = Fc p ∧ CLoc p th T i (nOf p c) (stOf p c) (bkOf p c) t.locals ∧ t.status = collSt C p I T i c

/-- After the barrier, a lane runs to its first collective. -/
theorem lane_first (hS : Shape L p I) (hp : p.Ok) (hl : Lane p ctx y z sg i) (hge : ge ≠ ctx.group) {l : Locals}
    {sh : Shared} (hF : Fix1 p i l) (hm : Mem C p L I ge (fun _ => True) outOk sh) :
    ∃ t sh', (Ev fun m => (runThread C m ⟨ctx, l, [.block p.rest2, .scope, .block []], .running⟩).run sh =
        some (t, sh')) ∧ AtColl C p I ctx TH TT ⟨i, hl.hi⟩ 0 t ∧ Mem C p L I ge (fun _ => True) outOk sh' ∧
      Keep TH sh sh' ∧ TMem C p I TH TT ⟨i, hl.hi⟩ 0 sh' := by
  obtain ⟨l₁, x1, hs₁⟩ := lane_setup C hp hl (sh := sh) hF
  obtain ⟨l₂, sh₂, x2, hR₂, hm₂, hk₂, hfr₂, hxm₂, hacc₂, hwa₂⟩ := lane_init C hS hp hl hs₁ hm
  have hc : (eval C ctx l₂ DownMmaWide.rC).run sh₂ = some (.bool true, sh₂) := by
    have := eval_bin_u32 C (ctx := ctx) (l := l₂) (sh := sh₂) (op := .lt) (site := 0) (a := .local 42) (b := .local 34)
      (eval_local' C hR₂.l42 sh₂) (eval_local' C hR₂.g.s.l34 sh₂)
      (binary_lt_u32 C _ _ (by have := (tile_facts hp hl.hy hl.hz hl.hsg).1; omega)
        (by have := (tile_facts hp hl.hy hl.hz hl.hsg).1; omega))
    rwa [decide_eq_true (by omega)] at this
  obtain ⟨l₃, sh₃, x3, hC₃, hm₃, hoth₃, hw₃, hv₃, ha₃, hb₃⟩ := row_body C hS hp hl (n := 0) (by decide) hge
    (cnt := fun _ _ => 0) hR₂ hm₂ hxm₂ hwa₂ hacc₂
  have hex : Exec C ctx p.rest2 l sh (.stop (collSt C p I TT ⟨i, hl.hi⟩ 0) (innerR p)) l₃ sh₃ := by
    have hcs : collSt C p I TT ⟨i, hl.hi⟩ 0 =
        .collective 2 71 (.mma .f32 .f16) .f32 (collV C p I TT ⟨i, hl.hi⟩ 0 0 0 0) 0 := by
      simp [collSt, nOf, stOf, bkOf]
    rw [hcs]
    unfold Par.rest2 DownMmaWide.rest2
    exact x1.append (x2.append (.loop_stop (st := DownMmaWide.rSt) (ss := DownMmaWide.outPart p.s p.mt) hc x3))
  refine ⟨⟨ctx, l₃, Fc p, collSt C p I TT ⟨i, hl.hi⟩ 0⟩, sh₃, (hex.reaches_stop (K := [.scope, .block []])).ev_stop rfl,
    ⟨rfl, rfl, by simpa [nOf, stOf, bkOf] using hC₃, rfl⟩, hm₃, fun R hR h4 => ?_, ?_⟩
  · rw [hoth₃ R (by unfold ta at *; omega)]; exact hk₂ R hR h4
  · refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · rw [hoth₃ _ (by unfold ta; omega)]; exact hxm₂
    · rw [hoth₃ _ (by unfold ta; omega)]
      exact fun s' hs' b hb e => by rw [hacc₂ s' hs' b hb e, cnt_zero]
    · rw [hoth₃ _ (by unfold ta; omega)]; exact hwa₂
    · simpa [nOf] using hw₃
    · simpa [nOf] using hv₃
    · simpa [nOf] using ha₃
    · simpa [nOf, stOf] using hb₃

/-- `acc[st][bk]` after the store of its next registers. -/
theorem acc_store {C : M1Max.Contract} {p : Par} {I : In} {T : Tile} {i' : Fin 32} {cnt : Nat → Nat → Nat}
    {B : ByteMemory.Bytes} (hacc : AccArr C p I T i' cnt B) {st bk : Nat} (hst : st < p.s) (hbk : bk < p.mt) :
    AccArr C p I T i' (fun s' b => if s' = st ∧ b = bk then cnt st bk + 1 else cnt s' b)
      (writeBytes B (8 * (st * p.mt + bk)) (pairBytes
        (accReg C p.k p.il p.s p.M I.X I.Cd I.S T st bk (cnt st bk + 1) i' 0)
        (accReg C p.k p.il p.s p.M I.X I.Cd I.S T st bk (cnt st bk + 1) i' 1))) := by
  intro s' hs' b hb e
  have he := e.isLt
  by_cases h : s' = st ∧ b = bk
  · obtain ⟨rfl, rfl⟩ := h
    simp only [and_self, ite_true]
    rcases e with ⟨_ | _ | _, he'⟩
    · simpa using pairBytes_lo B (8 * (s' * p.mt + b)) _ _
    · simpa using pairBytes_hi B (8 * (s' * p.mt + b)) _ _
    · omega
  · simp only [ite_eq_right h]
    rw [cells_writeBytes_other _ _ _ _ _ ?_]
    · exact hacc s' hs' b hb e
    · have hne : s' * p.mt + b ≠ st * p.mt + bk := fun h' => h (idx_inj hb hbk h')
      rw [pairBytes_length]; omega

theorem rowBase_succ (p : Par) (T : Tile) (i n : Nat) :
    rowBase p T i (n + 1) = rowBase p T i n + 8 * DownPartial.roww p.k p.il := by
  unfold rowBase; rw [DownPartial.dbase_eq, DownPartial.dbase_eq]; ring

/-- The row loop's step: `r += 8`, `rowCodes += 8·rowWords`. -/
theorem exec_rSt {th : Nat} {T : Tile} {n : Nat} (hk : p.k ≤ 4)
    {l : Locals} {sh : Shared} (hR : RLoc p th T i n l) :
    Exec C ctx DownMmaWide.rSt l sh .normal
      (setLocal (setLocal l 42 (u32 (2176 * T.split + 8 * (n + 1)))) 41
        (.ptr ⟨2, ((4 * rowBase p T i (n + 1) : Nat) : Int), .scalar .u32⟩)) sh := by
  have e42 : (eval C ctx l (DownMmaWide.u32 .add (.local 42) (DownMmaWide.u32l 8))).run sh =
      some (u32 (2176 * T.split + 8 * (n + 1)), sh) := by
    rw [show 2176 * T.split + 8 * (n + 1) = 2176 * T.split + 8 * n + 8 by ring]
    exact eval_bin_u32 C (eval_local' C hR.l42 sh) (eval_u32lit C _ _ 8 (by decide)) (binary_add_u32 C _ 8)
  have hrw : DownPartial.roww p.k p.il ≤ 640 := by
    unfold DownPartial.roww DownPartial.wpb; split <;> omega
  have h41' : (setLocal l 42 (u32 (2176 * T.split + 8 * (n + 1)))) 41 =
      some (.ptr ⟨2, ((4 * rowBase p T i n : Nat) : Int), .scalar .u32⟩) := by
    rw [setLocal_other _ _ (by omega)]; exact hR.l41
  have h25' : (setLocal l 42 (u32 (2176 * T.split + 8 * (n + 1)))) 25 = some (u64 (DownPartial.roww p.k p.il)) := by
    rw [setLocal_other _ _ (by omega)]; exact hR.g.s.l25
  have e41 := eval_offset_u64 C (ctx := ctx) (l := setLocal l 42 (u32 (2176 * T.split + 8 * (n + 1)))) (sh := sh)
    (eval_local' C h41' sh)
    (eval_int C (site := 0) (by decide) (eval_u64lit C _ _ 8 (by decide))
      (eval_local' C h25' sh) (binary_mul_u64 C 8 _)) (by omega)
  rw [show 4 * rowBase p T i n + 8 * DownPartial.roww p.k p.il * (Ty.scalar .u32).bytes = 4 * rowBase p T i (n + 1) by
    rw [rowBase_succ]; simp [Ty.bytes, Scalar.bytes]; ring] at e41
  exact .set e42 (.set e41 (.nil _ _))

/-- The step after a collective: the accumulator stored, the block counter's step. -/
theorem after_coll (hS : Shape L p I) (hp : p.Ok) (hl : Lane p ctx y z sg i) {c : Nat} (hc : c < p.T)
    {tl : Locals} {sh : Shared} (hC : CLoc p TH TT i (nOf p c) (stOf p c) (bkOf p c) tl)
    (hm : Mem C p L I ge (fun _ => True) outOk sh) (htm : TMem C p I TH TT ⟨i, hl.hi⟩ c sh) :
    let l₀ := setLocal tl 71 (resV C p I TT ⟨i, hl.hi⟩ c)
    let sh₁ := tput sh (ta TH 1) (8 * (stOf p c * p.mt + bkOf p c))
      (pairBytes (accReg C p.k p.il p.s p.M I.X I.Cd I.S TT (stOf p c) (bkOf p c) (nOf p c + 1) ⟨i, hl.hi⟩ 0)
        (accReg C p.k p.il p.s p.M I.X I.Cd I.S TT (stOf p c) (bkOf p c) (nOf p c + 1) ⟨i, hl.hi⟩ 1))
    Exec C ctx [DownMmaWide.storeAcc p.mt] l₀ sh .normal l₀ sh₁ ∧
      Exec C ctx (DownMmaWide.inc 70) l₀ sh₁ .normal (setLocal l₀ 70 (u32 (bkOf p c + 1))) sh₁ ∧
      Mem C p L I ge (fun _ => True) outOk sh₁ ∧ Keep TH sh sh₁ ∧
      AccArr C p I TT ⟨i, hl.hi⟩ (cntOf p (c + 1)) (sh₁.bytes (ta TH 1)) ∧
      (∀ j, j ≠ 1 → sh₁.bytes (ta TH j) = sh.bytes (ta TH j)) := by
  intro l₀ sh₁
  obtain ⟨hn, hst, hbk⟩ := stage_lt hp hc
  have hC₀ : CLoc p TH TT i (nOf p c) (stOf p c) (bkOf p c) l₀ :=
    ⟨hC.w.of_eq fun j hj => setLocal_other _ _ (by omega), (setLocal_other _ _ (by omega)).trans hC.l54,
      (setLocal_other _ _ (by omega)).trans hC.l55, (setLocal_other _ _ (by omega)).trans hC.l70⟩
  refine ⟨exec_storeAcc C hS hp hbk hst hC₀ (setLocal_same _ _ _) hm.regions, ?_, hm.tput _ _ (by unfold ta; omega),
    (Keep.refl _ _).tput (by unfold ta; omega) _ _, ?_, fun j hj => tput_other _ _ _ (by unfold ta; omega)⟩
  · exact .set (eval_bin_u32 C (eval_local' C hC₀.l70 _) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C _ 1))
      (.nil _ _)
  · have h := acc_store htm.acc hst hbk
    rw [cnt_self hp c] at h
    intro s' hs' b hb e
    have h' := h s' hs' b hb e
    simp only at h'
    show cells ((tput sh (ta TH 1) _ _).bytes (ta TH 1)) _ 4 = _
    rw [tput_same, h', cnt_succ hp c hs' hb]
    split_ifs with hh
    · obtain ⟨rfl, rfl⟩ := hh; rw [cnt_self hp c]
    · rfl

/-- From a collective's block loop, its exit and the sub-tile loop's next test. -/
theorem to_Ks {c : Nat} (hp : p.Ok) (h1 : bkOf p c + 1 = p.mt) {l₀ : Locals} {sh sh₁ : Shared}
    (hstore : Exec C ctx [DownMmaWide.storeAcc p.mt] l₀ sh .normal l₀ sh₁)
    (hinc : Exec C ctx (DownMmaWide.inc 70) l₀ sh₁ .normal (setLocal l₀ 70 (u32 (bkOf p c + 1))) sh₁) :
    Reaches C ⟨ctx, l₀, Fc p, .running⟩ sh ⟨ctx, setLocal l₀ 70 (u32 (bkOf p c + 1)), Ks p, .running⟩ sh₁ := by
  have hmt : p.mt ≤ 3 := by rcases hp.sm with ⟨-, h⟩ | ⟨-, h⟩ | ⟨-, h⟩ <;> rw [h] <;> decide
  have hcnd : (eval C ctx (setLocal l₀ 70 (u32 (bkOf p c + 1))) (DownMmaWide.bC p.mt)).run sh₁ = some (.bool false, sh₁) := by
    have := eval_lt_u32 C (ctx := ctx) (sh := sh₁) (b := p.mt) (setLocal_same l₀ 70 (u32 (bkOf p c + 1))) (by omega)
      (by omega)
    rwa [decide_eq_false (by omega)] at this
  exact Exec.resume hstore (.inl rfl) hinc (.loop_exit hcnd (.nil _ _)) rfl

/-- A lane resumed after its `c`-th collective runs to its next. -/
theorem lane_next (hS : Shape L p I) (hp : p.Ok) (hl : Lane p ctx y z sg i) (hge : ge ≠ ctx.group) {c : Nat}
    (hc : c + 1 < p.T) {t : Thread} {sh : Shared} (ht : AtColl C p I ctx TH TT ⟨i, hl.hi⟩ c t)
    (hm : Mem C p L I ge (fun _ => True) outOk sh) (htm : TMem C p I TH TT ⟨i, hl.hi⟩ c sh) :
    ∃ t' sh', (Ev fun m => (runThread C m ({ t with status := .running }.set 71 (resV C p I TT ⟨i, hl.hi⟩ c))).run sh =
        some (t', sh')) ∧ AtColl C p I ctx TH TT ⟨i, hl.hi⟩ (c + 1) t' ∧ Mem C p L I ge (fun _ => True) outOk sh' ∧
      Keep TH sh sh' ∧ TMem C p I TH TT ⟨i, hl.hi⟩ (c + 1) sh' := by
  obtain ⟨tc, tl, tf, ts⟩ := t
  obtain ⟨htc, htf, hC, -⟩ := ht
  simp only at htc htf hC
  subst tc tf
  rw [resumed]
  obtain ⟨hn, hst, hbk⟩ := stage_lt hp (show c < p.T by omega)
  obtain ⟨hn', hst', hbk'⟩ := stage_lt hp hc
  obtain ⟨hA, hB, hCc⟩ := stage_next hp c
  obtain ⟨hstore, hinc, hm₁, hk₁, hacc₁, hoth₁⟩ := after_coll C hS hp hl (show c < p.T by omega) hC hm htm
  generalize hl₀ : setLocal tl 71 (resV C p I TT ⟨i, hl.hi⟩ c) = l₀ at hstore hinc
  generalize hsh₁ : tput sh (ta TH 1) (8 * (stOf p c * p.mt + bkOf p c)) (pairBytes
    (accReg C p.k p.il p.s p.M I.X I.Cd I.S TT (stOf p c) (bkOf p c) (nOf p c + 1) ⟨i, hl.hi⟩ 0)
    (accReg C p.k p.il p.s p.M I.X I.Cd I.S TT (stOf p c) (bkOf p c) (nOf p c + 1) ⟨i, hl.hi⟩ 1)) = sh₁
    at hstore hinc hm₁ hk₁ hacc₁ hoth₁
  have hl₀b : ∀ j, j ≠ 71 → l₀ j = tl j := fun j hj => by rw [← hl₀, setLocal_other _ _ hj]
  have hW₀ : WLoc p TH TT i (nOf p c) l₀ := hC.w.of_eq fun j hj => hl₀b j (by omega)
  have hmt : p.mt ≤ 3 ∧ 8 ≤ p.s ∧ p.s ≤ 16 := by
    rcases hp.sm with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> rw [h1, h2] <;> decide
  by_cases h1 : bkOf p c + 1 < p.mt
  · -- the next block of the sub-tile
    obtain ⟨e1, e2, e3⟩ := hA h1
    have hC₁ : CLoc p TH TT i (nOf p (c + 1)) (stOf p (c + 1)) (bkOf p (c + 1)) (setLocal l₀ 70 (u32 (bkOf p c + 1))) := by
      rw [e1, e2, e3]
      exact ⟨hW₀.of_eq fun j hj => setLocal_other _ _ (by omega),
        by rw [setLocal_other _ _ (by omega), hl₀b 54 (by omega)]; exact hC.l54,
        by rw [setLocal_other _ _ (by omega), hl₀b 55 (by omega)]; exact hC.l55, setLocal_same _ _ _⟩
    have hcnd : (eval C ctx (setLocal l₀ 70 (u32 (bkOf p c + 1))) (DownMmaWide.bC p.mt)).run sh₁ =
        some (.bool true, sh₁) := by
      have := eval_lt_u32 C (ctx := ctx) (sh := sh₁) (b := p.mt) (setLocal_same l₀ 70 (u32 (bkOf p c + 1))) (by omega)
        (by omega)
      rwa [decide_eq_true h1] at this
    have hcoll := exec_coll C hS hp (ctx := ctx) (th := TH) (T := TT) (i' := ⟨i, hl.hi⟩) (cnt := cntOf p (c + 1))
      hbk' hst' hC₁ hm₁.regions hacc₁ (by rw [hoth₁ 6 (by omega), e1]; exact htm.a)
      (by rw [hoth₁ 7 (by omega), e1, e2]; exact htm.b)
    rw [cnt_self hp (c + 1)] at hcoll
    refine ⟨⟨ctx, setLocal l₀ 70 (u32 (bkOf p c + 1)), Fc p, collSt C p I TT ⟨i, hl.hi⟩ (c + 1)⟩, sh₁,
      (Exec.resume_stop hstore (.inl rfl) hinc hcnd hcoll).ev_stop rfl, ⟨rfl, rfl, hC₁, rfl⟩, hm₁, hk₁, ?_⟩
    exact ⟨by rw [hoth₁ 0 (by omega)]; exact htm.xm, hacc₁, by rw [hoth₁ 2 (by omega)]; exact htm.wa,
      by rw [hoth₁ 4 (by omega), e1]; exact htm.w, by rw [hoth₁ 5 (by omega), e1]; exact htm.v,
      by rw [hoth₁ 6 (by omega), e1]; exact htm.a, by rw [hoth₁ 7 (by omega), e1, e2]; exact htm.b⟩
  have h1' : bkOf p c + 1 = p.mt := by omega
  have r1 := to_Ks C (ctx := ctx) hp h1' hstore hinc
  generalize hl₁ : setLocal l₀ 70 (u32 (bkOf p c + 1)) = l₁ at r1
  have hl₁b : ∀ j, j ≠ 70 → j ≠ 71 → l₁ j = tl j := fun j h1 h2 => by rw [← hl₁, setLocal_other _ _ h1, hl₀b j h2]
  have hinc54 : Exec C ctx (DownMmaWide.inc 54) l₁ sh₁ .normal (setLocal l₁ 54 (u32 (stOf p c + 1))) sh₁ :=
    .set (eval_bin_u32 C (eval_local' C (by rw [hl₁b 54 (by omega) (by omega)]; exact hC.l54) _)
      (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C _ 1)) (.nil _ _)
  generalize hl₂ : setLocal l₁ 54 (u32 (stOf p c + 1)) = l₂ at hinc54
  have hl₂b : ∀ j, j < 54 → l₂ j = tl j := fun j hj => by
    rw [← hl₂, setLocal_other _ _ (by omega), hl₁b j (by omega) (by omega)]
  have hW₂ : WLoc p TH TT i (nOf p c) l₂ := hC.w.of_eq fun j hj => hl₂b j (by omega)
  have h54 : l₂ 54 = some (u32 (stOf p c + 1)) := by rw [← hl₂, setLocal_same]
  by_cases h2 : stOf p c + 1 < p.s
  · -- the next sub-tile
    obtain ⟨e1, e2, e3⟩ := hB h1' h2
    have hcnd : (eval C ctx l₂ (DownMmaWide.sC p.s)).run sh₁ = some (.bool true, sh₁) := by
      have := eval_lt_u32 C (ctx := ctx) (sh := sh₁) (b := p.s) h54 (by omega) (by omega)
      rwa [decide_eq_true h2] at this
    obtain ⟨l₃, sh₃, xsub, hC₃, hm₃, hoth₃, hb₃⟩ := sub_body C hS hp hl (n := nOf p c) h2 hge (cnt := cntOf p (c + 1))
      hW₂ h54 hm₁ (by rw [hoth₁ 4 (by omega)]; exact htm.w) (by rw [hoth₁ 5 (by omega)]; exact htm.v)
      (by rw [hoth₁ 6 (by omega)]; exact htm.a) hacc₁
    have hcnt := cnt_self hp (c + 1)
    rw [e1, e2, e3] at hcnt
    have hcv : collV C p I TT ⟨i, hl.hi⟩ (nOf p c) (stOf p c + 1) 0 (cntOf p (c + 1) (stOf p c + 1) 0) =
        collV C p I TT ⟨i, hl.hi⟩ (nOf p (c + 1)) (stOf p (c + 1)) (bkOf p (c + 1)) (nOf p (c + 1)) := by
      rw [e1, e2, e3, hcnt]
    rw [hcv] at xsub
    rw [← e1, ← e2, ← e3] at hC₃
    rw [← e1, ← e2] at hb₃
    have r2 := Exec.resume_loop hinc54 (.loop_stop hcnd xsub) (ss := []) (K := Kr p) rfl
    refine ⟨⟨ctx, l₃, Fc p, collSt C p I TT ⟨i, hl.hi⟩ (c + 1)⟩, sh₃, (r1.trans r2).ev_stop rfl, ⟨rfl, rfl, hC₃, rfl⟩,
      hm₃, fun R hR h4 => ?_, ?_⟩
    · rw [hoth₃ R (by unfold ta at *; omega)]; exact hk₁ R hR h4
    · exact ⟨by rw [hoth₃ _ (by unfold ta; omega), hoth₁ 0 (by omega)]; exact htm.xm,
        by rw [hoth₃ _ (by unfold ta; omega)]; exact hacc₁,
        by rw [hoth₃ _ (by unfold ta; omega), hoth₁ 2 (by omega)]; exact htm.wa,
        by rw [hoth₃ _ (by unfold ta; omega), hoth₁ 4 (by omega), e1]; exact htm.w,
        by rw [hoth₃ _ (by unfold ta; omega), hoth₁ 5 (by omega), e1]; exact htm.v,
        by rw [hoth₃ _ (by unfold ta; omega), hoth₁ 6 (by omega), e1]; exact htm.a, hb₃⟩
  -- the next row step
  have h2' : stOf p c + 1 = p.s := by omega
  obtain ⟨e1, e2, e3⟩ := hCc h1' h2'
  have hcndS : (eval C ctx l₂ (DownMmaWide.sC p.s)).run sh₁ = some (.bool false, sh₁) := by
    have := eval_lt_u32 C (ctx := ctx) (sh := sh₁) (b := p.s) h54 (by omega) (by omega)
    rwa [decide_eq_false (by omega)] at this
  have r2 := Exec.resume_loop hinc54 (.loop_exit hcndS (.nil _ _)) (b := DownMmaWide.subTile p.k p.s p.mt) (K := Kr p) rfl
  have hR₂ : RLoc p TH TT i (nOf p c) l₂ := hC.w.r.of_eq fun j hj => hl₂b j (by omega)
  obtain ⟨hsplit, -, -, -, -⟩ := tile_facts hp hl.hy hl.hz hl.hsg
  have hrst := exec_rSt C (ctx := ctx) (sh := sh₁) hp.k.2 hR₂
  generalize hl₄ : setLocal (setLocal l₂ 42 (u32 (2176 * (tileOf p.s p.mt y z sg).split + 8 * (nOf p c + 1)))) 41
    (.ptr ⟨2, ((4 * rowBase p TT i (nOf p c + 1) : Nat) : Int), .scalar .u32⟩) = l₄ at hrst
  have hR₄ : RLoc p TH TT i (nOf p c + 1) l₄ := by
    rw [← hl₄]
    exact ⟨hR₂.g.of_eq fun j hj => by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)],
      setLocal_same _ _ _, by rw [setLocal_other _ _ (by omega), setLocal_same]⟩
  have hcndR : (eval C ctx l₄ DownMmaWide.rC).run sh₁ = some (.bool true, sh₁) := by
    have := eval_bin_u32 C (ctx := ctx) (l := l₄) (sh := sh₁) (op := .lt) (site := 0) (a := .local 42) (b := .local 34)
      (eval_local' C hR₄.l42 sh₁) (eval_local' C hR₄.g.s.l34 sh₁) (binary_lt_u32 C _ _ (by omega) (by omega))
    rwa [decide_eq_true (by omega)] at this
  obtain ⟨l₅, sh₅, xrow, hC₅, hm₅, hoth₅, hw₅, hv₅, ha₅, hb₅⟩ := row_body C hS hp hl (n := nOf p c + 1) (by omega) hge
    (cnt := cntOf p (c + 1)) hR₄ hm₁ (by rw [hoth₁ 0 (by omega)]; exact htm.xm) (by rw [hoth₁ 2 (by omega)]; exact htm.wa)
    hacc₁
  have hcnt := cnt_self hp (c + 1)
  rw [e1, e2, e3] at hcnt
  have hcv : collV C p I TT ⟨i, hl.hi⟩ (nOf p c + 1) 0 0 (cntOf p (c + 1) 0 0) =
      collV C p I TT ⟨i, hl.hi⟩ (nOf p (c + 1)) (stOf p (c + 1)) (bkOf p (c + 1)) (nOf p (c + 1)) := by
    rw [e1, e2, e3, hcnt]
  rw [hcv] at xrow
  have r3 := Exec.resume_loop hrst (.loop_stop hcndR xrow) (ss := DownMmaWide.outPart p.s p.mt) (K := [.scope, .block []]) rfl
  refine ⟨⟨ctx, l₅, Fc p, collSt C p I TT ⟨i, hl.hi⟩ (c + 1)⟩, sh₅, ((r1.trans r2).trans r3).ev_stop rfl,
    ⟨rfl, rfl, by rw [e1, e2, e3]; exact hC₅, rfl⟩, hm₅, fun R hR h4 => ?_, ?_⟩
  · rw [hoth₅ R (by unfold ta at *; omega)]; exact hk₁ R hR h4
  · exact ⟨by rw [hoth₅ _ (by unfold ta; omega), hoth₁ 0 (by omega)]; exact htm.xm,
      by rw [hoth₅ _ (by unfold ta; omega)]; exact hacc₁,
      by rw [hoth₅ _ (by unfold ta; omega), hoth₁ 2 (by omega)]; exact htm.wa,
      by rw [e1]; exact hw₅, by rw [e1]; exact hv₅, by rw [e1]; exact ha₅, by rw [e1, e2]; exact hb₅⟩

/-- A lane resumed after its last collective: the partials, then the end. -/
theorem lane_last (hS : Shape L p I) (hp : p.Ok) (hl : Lane p ctx y z sg i) {t : Thread}
    {sh : Shared} (ht : AtColl C p I ctx TH TT ⟨i, hl.hi⟩ (p.T - 1) t)
    (hm : Mem C p L I ge (fun _ => True) (fun E => eThread p.s p.mt E < TH) sh)
    (htm : TMem C p I TH TT ⟨i, hl.hi⟩ (p.T - 1) sh) :
    ∃ t' sh', (Ev fun m => (runThread C m ({ t with status := .running }.set 71
        (resV C p I TT ⟨i, hl.hi⟩ (p.T - 1)))).run sh = some (t', sh')) ∧ t'.status = .done ∧
      Mem C p L I ge (fun _ => True) (fun E => eThread p.s p.mt E < TH + 1) sh' ∧ Keep TH sh sh' := by
  have hT1 : 1 ≤ p.T := by unfold Par.T; rcases hp.sm with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> rw [h1, h2] <;> decide
  obtain ⟨tc, tl, tf, ts⟩ := t
  obtain ⟨htc, htf, hC, -⟩ := ht
  simp only at htc htf hC
  subst tc tf
  rw [resumed]
  obtain ⟨hn, hst, hbk⟩ := stage_last hp
  obtain ⟨hstore, hinc, hm₁, hk₁, hacc₁, hoth₁⟩ := after_coll C hS hp hl (show p.T - 1 < p.T by omega) hC hm htm
  generalize hl₀ : setLocal tl 71 (resV C p I TT ⟨i, hl.hi⟩ (p.T - 1)) = l₀ at hstore hinc
  generalize hsh₁ : tput sh (ta TH 1) (8 * (stOf p (p.T - 1) * p.mt + bkOf p (p.T - 1))) (pairBytes
    (accReg C p.k p.il p.s p.M I.X I.Cd I.S TT (stOf p (p.T - 1)) (bkOf p (p.T - 1)) (nOf p (p.T - 1) + 1) ⟨i, hl.hi⟩ 0)
    (accReg C p.k p.il p.s p.M I.X I.Cd I.S TT (stOf p (p.T - 1)) (bkOf p (p.T - 1)) (nOf p (p.T - 1) + 1) ⟨i, hl.hi⟩ 1))
    = sh₁ at hstore hinc hm₁ hk₁ hacc₁ hoth₁
  have hl₀b : ∀ j, j ≠ 71 → l₀ j = tl j := fun j hj => by rw [← hl₀, setLocal_other _ _ hj]
  have r1 := to_Ks C (ctx := ctx) hp hbk hstore hinc
  generalize hl₁ : setLocal l₀ 70 (u32 (bkOf p (p.T - 1) + 1)) = l₁ at r1
  have hl₁b : ∀ j, j ≠ 70 → j ≠ 71 → l₁ j = tl j := fun j h1 h2 => by rw [← hl₁, setLocal_other _ _ h1, hl₀b j h2]
  have hinc54 : Exec C ctx (DownMmaWide.inc 54) l₁ sh₁ .normal (setLocal l₁ 54 (u32 (stOf p (p.T - 1) + 1))) sh₁ :=
    .set (eval_bin_u32 C (eval_local' C (by rw [hl₁b 54 (by omega) (by omega)]; exact hC.l54) _)
      (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C _ 1)) (.nil _ _)
  generalize hl₂ : setLocal l₁ 54 (u32 (stOf p (p.T - 1) + 1)) = l₂ at hinc54
  have hl₂b : ∀ j, j < 54 → l₂ j = tl j := fun j hj => by
    rw [← hl₂, setLocal_other _ _ (by omega), hl₁b j (by omega) (by omega)]
  have h54 : l₂ 54 = some (u32 (stOf p (p.T - 1) + 1)) := by rw [← hl₂, setLocal_same]
  have hs16 : p.s ≤ 16 := by rcases hp.sm with ⟨h, -⟩ | ⟨h, -⟩ | ⟨h, -⟩ <;> rw [h] <;> decide
  have hcndS : (eval C ctx l₂ (DownMmaWide.sC p.s)).run sh₁ = some (.bool false, sh₁) := by
    have := eval_lt_u32 C (ctx := ctx) (sh := sh₁) (b := p.s) h54 (by omega) (by omega)
    rwa [decide_eq_false (by omega)] at this
  have r2 := Exec.resume_loop hinc54 (.loop_exit hcndS (.nil _ _)) (b := DownMmaWide.subTile p.k p.s p.mt) (K := Kr p) rfl
  have hR₂ : RLoc p TH TT i (nOf p (p.T - 1)) l₂ := hC.w.r.of_eq fun j hj => hl₂b j (by omega)
  rw [hn] at hR₂
  obtain ⟨hsplit, -, -, -, -⟩ := tile_facts hp hl.hy hl.hz hl.hsg
  have hrst := exec_rSt C (ctx := ctx) (sh := sh₁) hp.k.2 hR₂
  generalize hl₄ : setLocal (setLocal l₂ 42 (u32 (2176 * (tileOf p.s p.mt y z sg).split + 8 * (271 + 1)))) 41
    (.ptr ⟨2, ((4 * rowBase p TT i (271 + 1) : Nat) : Int), .scalar .u32⟩) = l₄ at hrst
  have hG₄ : GLoc p TH TT i l₄ := by
    rw [← hl₄]; exact hR₂.g.of_eq fun j hj => by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
  have hcndR : (eval C ctx l₄ DownMmaWide.rC).run sh₁ = some (.bool false, sh₁) := by
    have := eval_bin_u32 C (ctx := ctx) (l := l₄) (sh := sh₁) (op := .lt) (site := 0) (a := .local 42) (b := .local 34)
      (eval_local' C (by rw [← hl₄, setLocal_other _ _ (by omega), setLocal_same]) sh₁) (eval_local' C hG₄.s.l34 sh₁)
      (binary_lt_u32 C _ _ (by omega) (by omega))
    rwa [decide_eq_false (by omega)] at this
  have hacc₂ : AccArr C p I TT ⟨i, hl.hi⟩ (fun _ _ => 272) (sh₁.bytes (ta TH 1)) := by
    intro s' hs' b hb e
    rw [hacc₁ s' hs' b hb e, show p.T - 1 + 1 = p.T by omega, cnt_T hp hs' hb]
  obtain ⟨l₅, sh₅, xout, hm₅, hk₅⟩ := lane_out C hS hp hl hG₄ hm₁ hacc₂
  have r3 := Exec.resume_loop hrst (.loop_exit hcndR xout) (b := DownMmaWide.rowBody p.k p.s p.mt p.nw) (K := [.scope, .block []]) rfl
  have r4 : Reaches C ⟨ctx, l₅, [.scope, .block []], .running⟩ sh₅ ⟨ctx, l₅, [], .done⟩ sh₅ :=
    .cons rfl (step_scope_pop C) (.cons rfl (step_pop C) (.single rfl (step_done C)))
  exact ⟨⟨ctx, l₅, [], .done⟩, sh₅, (((r1.trans r2).trans r3).trans r4).ev_stop rfl, rfl, hm₅, hk₁.trans hk₅⟩

end Lane2

end Metal.Kernels.DownWideRun

namespace Metal.Kernels.DownWideRun
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis
open Metal.Kernels.DownMmaWide (Tile p0Of fmOf fnOf laneOf eTile ePos eBk eSt eLane eReg outVal expected aReg bReg accReg
  cbHalf xval sval zero rcp Geo nGOf gyOf codesBytes In bufs)

/-! ## The SIMD-groups -/

section Simd
variable (C : M1Max.Contract) {p : Par} {L : Launch} {I : In} {y z sg : Nat}

theorem thOf_disj {s y z sg i j : Nat} (hij : i ≠ j) (k : Nat) (hk : k < 8) :
    ta (thOf s y z sg j) k < ta (thOf s y z sg i) 0 ∨ ta (thOf s y z sg i) 8 ≤ ta (thOf s y z sg j) k := by
  unfold ta thOf
  omega

/-- Another lane's run keeps a lane's thread memory. -/
theorem TMem.keep {C : M1Max.Contract} {p : Par} {I : In} {T : Tile} {i : Fin 32} {c : Nat} {sh sh' : Shared}
    {y z sg j : Nat} (h : TMem C p I (thOf p.s y z sg i) T i c sh) (hij : i.val ≠ j)
    (hk : Keep (thOf p.s y z sg j) sh sh') : TMem C p I (thOf p.s y z sg i) T i c sh' :=
  h.congr fun k hk8 => hk _ (thOf_disj (s := p.s) (y := y) (z := z) (sg := sg) (Ne.symm hij) k hk8)
    (by unfold ta; omega)

/-- The lanes' memory during the round to collective `c`: lanes before `idx` at `c`, the others at `c - 1`. -/
def RndM (C : M1Max.Contract) (p : Par) (I : In) (y z sg : Nat) (c idx : Nat) (sh : Shared) : Prop :=
  ∀ j : Fin 32, (j.val < idx → TMem C p I (thOf p.s y z sg j) (tileOf p.s p.mt y z sg) j c sh) ∧
    (idx ≤ j.val → 1 ≤ c → TMem C p I (thOf p.s y z sg j) (tileOf p.s p.mt y z sg) j (c - 1) sh)

/-- After collective `c`: every lane runs to its next collective, or (after the last) to its end; the SIMD-group's
remaining rounds. -/
theorem simd_tail (hS : Shape L p I) (hp : p.Ok) (ctxs : Fin 32 → Ctx) (hL : ∀ i : Fin 32, Lane p (ctxs i) y z sg i)
    {ge : Nat} (hge : ∀ i, ge ≠ (ctxs i).group) :
    ∀ d c, c + d + 1 = p.T → ∀ (U : Fin 32 → Thread) (sh : Shared),
      (∀ i : Fin 32, AtColl C p I (ctxs i) (thOf p.s y z sg i) (tileOf p.s p.mt y z sg) i c (U i)) →
      RndM C p I y z sg (c + 1) 0 sh →
      Mem C p L I ge (fun _ => True) (fun E => eThread p.s p.mt E < thOf p.s y z sg 0) sh →
      ∃ (V : Fin 32 → Thread) (sh' : Shared),
        (Ev fun m => (runSimd C m (d + 1) (List.ofFn fun i =>
          { U i with status := .running }.set 71 (resV C p I (tileOf p.s p.mt y z sg) i c))).run sh =
            some (List.ofFn V, sh')) ∧
        Mem C p L I ge (fun _ => True) (fun E => eThread p.s p.mt E < thOf p.s y z sg 0 + 32) sh' ∧
        ∀ i, (V i).status = .done := by
  intro d
  induction d with
  | zero =>
    intro c hc U sh hU hR hm
    have hcT : c = p.T - 1 := by omega
    subst hcT
    obtain ⟨V, sh', hr, hI, hV⟩ := runSimd_blocked_ev C 0
      (fun i => { U i with status := .running }.set 71 (resV C p I (tileOf p.s p.mt y z sg) i (p.T - 1)))
      (fun idx sh => Mem C p L I ge (fun _ => True) (fun E => eThread p.s p.mt E < thOf p.s y z sg 0 + idx) sh ∧
        ∀ j : Fin 32, idx ≤ j.val → TMem C p I (thOf p.s y z sg j) (tileOf p.s p.mt y z sg) j (p.T - 1) sh)
      (fun i t => t.status = .done)
      (fun i sh hI => by
        have hl := hL i
        obtain ⟨t', sh', he, hdone, hm', hk⟩ := lane_last C hS hp hl (hU i)
          (hI.1.mono (fun _ _ h => h) (fun E _ h => by unfold thOf at h ⊢; omega)) ((hI.2 i le_rfl))
        refine ⟨t', sh', he, ⟨hm'.mono (fun _ _ h => h) (fun E _ h => by unfold thOf at h ⊢; omega), fun j hj => ?_⟩,
          by rw [hdone]; rfl, hdone⟩
        exact (hI.2 j (by omega)).keep (by omega) hk)
      sh ⟨by simpa using hm, fun j _ => by have := (hR j).2 (by omega) (by omega); simpa using this⟩
    exact ⟨V, sh', hr, hI.1, hV⟩
  | succ d ih =>
    intro c hc U sh hU hR hm
    have hc1 : c + 1 < p.T := by omega
    obtain ⟨V, sh', hr, hJ, hV⟩ := runSimd_collective_ev C (d + 1)
      (fun i => { U i with status := .running }.set 71 (resV C p I (tileOf p.s p.mt y z sg) i c)) 2 71 (.mma .f32 .f16)
      .f32 0 (fun i => collV C p I (tileOf p.s p.mt y z sg) i (nOf p (c + 1)) (stOf p (c + 1)) (bkOf p (c + 1))
        (nOf p (c + 1))) (fun i => resV C p I (tileOf p.s p.mt y z sg) i (c + 1))
      (resolve_coll C p I (tileOf p.s p.mt y z sg) (c + 1))
      (fun idx sh => Mem C p L I ge (fun _ => True) (fun E => eThread p.s p.mt E < thOf p.s y z sg 0) sh ∧
        RndM C p I y z sg (c + 1) idx sh)
      (fun i t => AtColl C p I (ctxs i) (thOf p.s y z sg i) (tileOf p.s p.mt y z sg) i (c + 1) t)
      (fun sh => Mem C p L I ge (fun _ => True) (fun E => eThread p.s p.mt E < thOf p.s y z sg 0 + 32) sh)
      (fun i t => t.status = .done)
      (fun i sh hI => by
        have hl := hL i
        obtain ⟨t', sh', he, hat, hm', hk, htm⟩ := lane_next C hS hp hl (hge i) hc1 (hU i) hI.1
          (by have := ((hI.2 i).2 le_rfl (by omega)); simpa using this)
        refine ⟨t', sh', he, ⟨hm', fun j => ⟨fun hj => ?_, fun hj _ => ?_⟩⟩, hat.2.2.2, hat⟩
        · by_cases hji : j = i
          · subst hji; exact htm
          · exact ((hI.2 j).1 (by have : j.val ≠ i.val := fun h => hji (Fin.ext h); omega)).keep
              (fun h => hji (Fin.ext h)) hk
        · exact ((hI.2 j).2 (by omega) (by omega)).keep (by omega) hk)
      (fun U' sh' hU' hI => ih (c + 1) (by omega) U' sh' hU' (fun j => ⟨fun hj => absurd hj (by omega),
        fun _ _ => by have := (hI.2 j).1 j.isLt; simpa using this⟩) hI.1)
      sh ⟨hm, fun j => ⟨fun hj => absurd hj (by omega), fun _ _ => ((hR j).2 (by omega) (by omega))⟩⟩
    exact ⟨V, sh', hr, hJ, hV⟩

theorem T_pos {p : Par} (hp : p.Ok) : 1 ≤ p.T := by
  unfold Par.T; rcases hp.sm with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> rw [h1, h2] <;> decide

/-- After the barrier: the SIMD-group's lanes, each from its declarations through its `272·S·MT` multiply-accumulates
to its partials. -/
theorem simd_phase2 (hS : Shape L p I) (hp : p.Ok) (ctxs : Fin 32 → Ctx) (hL : ∀ i : Fin 32, Lane p (ctxs i) y z sg i)
    {ge : Nat} (hge : ∀ i, ge ≠ (ctxs i).group) (U : Fin 32 → Thread)
    (hU : ∀ i, (U i).ctx = ctxs i ∧ (U i).frames = [.block p.rest2, .scope, .block []] ∧ Fix1 p i (U i).locals)
    {sh : Shared} (hm : Mem C p L I ge (fun _ => True) (fun E => eThread p.s p.mt E < thOf p.s y z sg 0) sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m (p.T + 1) (List.ofFn fun i => { U i with status := .running })).run sh =
        some (List.ofFn V, sh')) ∧
      Mem C p L I ge (fun _ => True) (fun E => eThread p.s p.mt E < thOf p.s y z sg 0 + 32) sh' ∧
      ∀ i, (V i).status = .done := by
  have hT := T_pos hp
  obtain ⟨V, sh', hr, hJ, hV⟩ := runSimd_collective_ev C p.T (fun i => { U i with status := .running }) 2 71
    (.mma .f32 .f16) .f32 0
    (fun i => collV C p I (tileOf p.s p.mt y z sg) i (nOf p 0) (stOf p 0) (bkOf p 0) (nOf p 0))
    (fun i => resV C p I (tileOf p.s p.mt y z sg) i 0) (resolve_coll C p I (tileOf p.s p.mt y z sg) 0)
    (fun idx sh => Mem C p L I ge (fun _ => True) (fun E => eThread p.s p.mt E < thOf p.s y z sg 0) sh ∧
      RndM C p I y z sg 0 idx sh)
    (fun i t => AtColl C p I (ctxs i) (thOf p.s y z sg i) (tileOf p.s p.mt y z sg) i 0 t)
    (fun sh => Mem C p L I ge (fun _ => True) (fun E => eThread p.s p.mt E < thOf p.s y z sg 0 + 32) sh)
    (fun i t => t.status = .done)
    (fun i sh hI => by
      have hl := hL i
      obtain ⟨hc, hf, hF⟩ := hU i
      generalize U i = t at hc hf hF ⊢
      obtain ⟨tc, tl, tf, ts⟩ := t
      simp only at hc hf hF
      subst hc hf
      obtain ⟨t', sh', he, hat, hm', hk, htm⟩ := lane_first C hS hp hl (hge i) hF hI.1
      refine ⟨t', sh', he, ⟨hm', fun j => ⟨fun hj => ?_, fun _ h1 => absurd h1 (by omega)⟩⟩, hat.2.2.2, hat⟩
      by_cases hji : j = i
      · subst hji; exact htm
      · exact ((hI.2 j).1 (by have : j.val ≠ i.val := fun h => hji (Fin.ext h); omega)).keep
          (fun h => hji (Fin.ext h)) hk)
    (fun U' sh' hU' hI => by
      have := simd_tail C hS hp ctxs hL hge (p.T - 1) 0 (by omega) U' sh' hU'
        (fun j => ⟨fun hj => absurd hj (by omega), fun _ _ => by have := (hI.2 j).1 j.isLt; simpa using this⟩) hI.1
      rwa [show p.T - 1 + 1 = p.T by omega] at this)
    sh ⟨hm, fun j => ⟨fun hj => absurd hj (by omega), fun _ h => absurd h (by omega)⟩⟩
  exact ⟨V, sh', hr, hJ, hV⟩

/-- Before the barrier: the SIMD-group's lanes write their codebook entries. -/
theorem simd_phase1 (hS : Shape L p I) (hp : p.Ok) (hM : word32 I.Xs 0 = p.M) (ctxs : Fin 32 → Ctx)
    (hL : ∀ i : Fin 32, Lane p (ctxs i) y z sg i) {g : Nat} (hg : g = y + z * gyOf p.s) {outOk : Nat → Prop} {sh : Shared}
    (hm : Mem C p L I g (fun e => e % 128 < 32 * sg) outOk sh) (r : Nat) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m (r + 1) (List.ofFn fun i =>
        (⟨ctxs i, fun _ => none, [.block p.body], .running⟩ : Thread))).run sh = some (List.ofFn V, sh')) ∧
      Mem C p L I g (fun e => e % 128 < 32 * (sg + 1)) outOk sh' ∧
      ∀ i, (V i).status = .barrier 1 false true ∧ (V i).ctx = ctxs i ∧
        (V i).frames = [.block p.rest2, .scope, .block []] ∧ Fix1 p i (V i).locals := by
  obtain ⟨V, sh', hr, hI, hR⟩ := runSimd_blocked_ev C r _
    (fun idx sh => Mem C p L I g (fun e => e % 128 < 32 * sg + idx) outOk sh)
    (fun i t => t.status = .barrier 1 false true ∧ t.ctx = ctxs i ∧ t.frames = [.block p.rest2, .scope, .block []] ∧
      Fix1 p i t.locals) (fun i sh hI => by
      obtain ⟨t, sh', he, hm', hst, hc, hf, hF⟩ := lane_phase1 C hS hp (hL i) hg hM hI
      exact ⟨t, sh', he, hm', by rw [hst]; rfl, hst, hc, hf, hF⟩) sh (by simpa using hm)
  exact ⟨V, sh', hr, by simpa [Nat.mul_add] using hI, hR⟩

end Simd

end Metal.Kernels.DownWideRun

namespace Metal.Kernels.DownWideRun
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis
open Metal.Kernels.DownMmaWide (Tile p0Of fmOf fnOf laneOf eTile ePos eBk eSt eLane eReg outVal expected aReg bReg accReg
  cbHalf xval sval zero rcp Geo nGOf gyOf codesBytes In bufs)

/-! ## The threadgroups, the launch -/

section Group
variable (C : M1Max.Contract) {p : Par} {L : Launch} {I : In}

/-- A threadgroup: the codebook, the barrier, then each SIMD-group's multiply-accumulates and partials. -/
theorem group_run (hS : Shape L p I) (hp : p.Ok) (hM : word32 I.Xs 0 = p.M) {y z : Nat}
    (ctxOf : Fin 4 → Fin 32 → Ctx) (hL : ∀ (sg : Fin 4) (i : Fin 32), Lane p (ctxOf sg i) y z sg i) {sh : Shared}
    (hm : Mem C p L I (y + z * gyOf p.s) (fun _ => False)
      (fun E => eThread p.s p.mt E < (y + z * gyOf p.s) * 128) sh) :
    ∃ sh', (Ev fun m => (runGroup C m (p.T + 1) 2 (List.ofFn fun sg : Fin 4 => List.ofFn fun i =>
        (⟨ctxOf sg i, fun _ => none, [.block p.body], .running⟩ : Thread))).run sh = some ((), sh')) ∧
      Mem C p L I (y + z * gyOf p.s + 1) (fun _ => True)
        (fun E => eThread p.s p.mt E < (y + z * gyOf p.s + 1) * 128) sh' := by
  refine runGroup_barrier_ev C (by decide) (p.T + 1) 1 _ 1 false true
    (fun j sh => Mem C p L I (y + z * gyOf p.s) (fun e => e % 128 < 32 * j)
      (fun E => eThread p.s p.mt E < (y + z * gyOf p.s) * 128) sh)
    (fun j i t => t.ctx = ctxOf j i ∧ t.frames = [.block p.rest2, .scope, .block []] ∧ Fix1 p i t.locals) _
    (fun j sh hj => ?_) (fun U sh hU hI => ?_) sh (hm.mono (fun e _ h => by omega) (fun _ _ h => h))
  · obtain ⟨V, sh', hr, hm', hV⟩ := simd_phase1 C hS hp hM (ctxOf j) (hL j) rfl hj p.T
    exact ⟨V, sh', hr, hm', fun i => ⟨(hV i).1, (hV i).2⟩⟩
  have hp' : Mem C p L I (y + z * gyOf p.s + 1) (fun _ => True)
      (fun E => eThread p.s p.mt E < (y + z * gyOf p.s) * 128 + 32 * 0) (pass false true sh) :=
    hI.pass.mono (fun e he _ => by omega) (fun _ _ h => by omega)
  obtain ⟨sh₄, hr₄, hm₄⟩ := runGroup_done_ev C (p.T + 1) 0 (fun j i => { U j i with status := .running })
    (fun j sh => Mem C p L I (y + z * gyOf p.s + 1) (fun _ => True)
      (fun E => eThread p.s p.mt E < (y + z * gyOf p.s) * 128 + 32 * j) sh)
    (fun j sh hj => by
      have hge : ∀ i, y + z * gyOf p.s + 1 ≠ (ctxOf j i).group := fun i => by rw [(hL j i).group]; omega
      obtain ⟨V, sh', hr, hm', hV⟩ := simd_phase2 C hS hp (ctxOf j) (hL j) hge (U j) (hU j)
        (hj.mono (fun _ _ h => h) (fun E _ h => by unfold thOf at h; omega))
      exact ⟨V, sh', hr, hm'.mono (fun _ _ h => h) (fun E _ h => by unfold thOf; omega), hV⟩) _ hp'
  exact ⟨sh₄, hr₄, hm₄.mono (fun _ _ h => h) (fun E _ h => by omega)⟩

/-- Every element of `partial` has a writer in the grid. -/
theorem writer_lt {s mt : Nat} (hsm : (s = 16 ∧ mt = 1) ∨ (s = 8 ∧ mt = 2) ∨ (s = 8 ∧ mt = 3)) {M E : Nat}
    (hE : E < 40960 * M) : eThread s mt E < gyOf s * ceilDiv M (8 * mt) * 128 := by
  have hl := (eLane s E).isLt
  unfold eThread eGroup eId eZ gyOf nGOf ceilDiv
  rcases hsm with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> omega

/-- The launch: the threadgroups in order. -/
theorem launch_run (hp : p.Ok) (hM : word32 I.Xs 0 = p.M) {initial : Nat → ByteMemory.Bytes}
    (hS : Shape (p.launch I initial) p I) (fuse : Nat → Bool) (garbage : Garbage) :
    ∃ sh, (∃ (ge : Nat) (cbOk : Nat → Prop), Mem C p (p.launch I initial) I ge cbOk
        (fun E => eThread p.s p.mt E < gyOf p.s * p.gz * 128) sh) ∧
      Ev fun m => runLaunch C fuse (p.launch I initial) garbage m (p.T + 1) 2 = some ⟨sh.bytes, sh.log⟩ := by
  have hb := launch_buffers p I initial
  obtain ⟨sh, ⟨cbOk, hI⟩, hr⟩ := (launch_tiles hp (I := I) (initial := initial)).launch_run_ev C fuse garbage (p.T + 1) 2
    (fun G sh => ∃ cbOk : Nat → Prop, Mem C p (p.launch I initial) I G cbOk (fun E => eThread p.s p.mt E < G * 128) sh)
    ⟨fun _ => False, rfl, initial_input hb garbage 0 (by simp [bufs]), initial_input hb garbage 1 (by simp [bufs]),
      initial_input hb garbage 2 (by simp [bufs]), initial_input hb garbage 3 (by simp [bufs]), rfl, rfl,
      fun _ _ h => h.elim, fun E _ h => absurd h (by omega), fun a ha => by simp [Launch.initial] at ha⟩
    (fun bx byy bz hx hy hz sh hI => by
      obtain rfl : bx = 0 := by omega
      obtain ⟨cbOk, hm⟩ := hI
      have hm' := hm.reset (by rw [hb, buffers_length]; simp [bufs]) garbage (0 + byy * 1 + bz * 1 * gyOf p.s)
      rw [show 0 + byy * 1 + bz * 1 * gyOf p.s = byy + bz * gyOf p.s by ring] at hm' ⊢
      obtain ⟨sh', hr, hm''⟩ := group_run C hS hp hM
        (fun sg i => (p.launch I initial).ctxAt fuse 0 byy bz (32 * sg + i)) (fun sg i => lane_of hp fuse hy hz sg i) hm'
      exact ⟨sh', hr, _, hm''⟩)
  exact ⟨sh, ⟨_, cbOk, by simpa using hI⟩, hr⟩

end Group

end Metal.Kernels.DownWideRun

namespace Metal.Kernels.DownMmaWide
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis Metal.Kernels.DownWideRun

variable (C : M1Max.Contract)

/-- **The GPU runs `mlx_bun_trellis_down_mma_wide` (and the `_k3i` kernel) as their source says**, for each route
instance (`Geo`) and every row count `1 ≤ M < 2^24`, given that the text compiles to `core k s mt nw il`. Under the
GPU assumption, MLX's launch on any `x` (bfloat16 `[M, 17408]`, 2-byte aligned), its `x_shape` (whose first `int`
is `M`, 4-byte aligned), codes (4-byte aligned) and scales (half, 2-byte aligned) writes to `partial`
`[M, 8, 5120]` `expected`: each element a register of its SIMD-group's `simdgroup_multiply_accumulate` chain over
its split's 272 row steps. -/
theorem gpu_output_of (k s mt nw : Nat) (il : Bool) (hG : Geo k s mt nw il) (text : List Char)
    (hc : (frontend text).bind elaborate = some (core k s mt nw il)) (G : Gpu C) (hmax : 128 ≤ G.maxThreads text)
    (M : Nat) (hM1 : 1 ≤ M) (hM2 : M < 2 ^ 24) (X Xs Cd S : ByteMemory.Bytes) (ax ash ac as : Nat)
    (hax : 2 ∣ ax) (hash : 4 ∣ ash) (hac : 4 ∣ ac) (has : 2 ∣ as) (hXs : word32 Xs 0 = M) :
    G.execute text (128, gyOf s, ceilDiv M (8 * mt)) (128, 1, 1)
      [⟨.device, 34816 * M, ax, X⟩, ⟨.constant, 8, ash, Xs⟩, ⟨.device, codesBytes k, ac, Cd⟩, ⟨.device, 34816, as, S⟩]
      [163840 * M] = some [expected C k il s mt M X Cd S] := by
  have hp : Par.Ok ⟨k, s, mt, nw, il, M⟩ := ⟨hG, hM1, hM2⟩
  have h := gpu_owned C G (text := text) (grid := (128, gyOf s, ceilDiv M (8 * mt))) (tg := (128, 1, 1))
    (inputs := [⟨.device, 34816 * M, ax, X⟩, ⟨.constant, 8, ash, Xs⟩, ⟨.device, codesBytes k, ac, Cd⟩,
      ⟨.device, 34816, as, S⟩]) (sizes := [163840 * M])
    (fun _ => expected C k il s mt M X Cd S) hc (by simpa using hmax) (fun initial garbage => by
      have hS := launch_shape (p := ⟨k, s, mt, nw, il, M⟩) (I := ⟨X, Xs, Cd, S, ax, ash, ac, as⟩) (initial := initial)
        (Nat.mod_eq_zero_of_dvd hax) (Nat.mod_eq_zero_of_dvd hash) (Nat.mod_eq_zero_of_dvd hac)
        (Nat.mod_eq_zero_of_dvd has)
      obtain ⟨sh, ⟨ge, cbOk, hm⟩, n, hn⟩ := launch_run C hp (I := ⟨X, Xs, Cd, S, ax, ash, ac, as⟩) hXs hS
        (G.fusion text) garbage
      refine ⟨n, _, 2, sh, dev s mt, tgo, hn n le_rfl, hm.log, ?_⟩
      intro i hi b hb
      obtain rfl : i = 0 := by simp at hi; omega
      have hb' : b < 163840 * M := by simpa using hb
      show sh.bytes 4 b = expected C k il s mt M X Cd S b
      have : cells (sh.bytes 4) (4 * (b / 4)) 4 =
          wordBytes 4 (Val.f32Bits (outVal C k il s mt M X Cd S (b / 4))) :=
        hm.out (b / 4) (by show b / 4 < 40960 * M; omega) (writer_lt hp.sm (by show b / 4 < 40960 * M; omega))
      rw [expected, ite_eq_left hb', ← this, cells_getD _ _ _ _ (by omega), show 4 * (b / 4) + b % 4 = b by omega])
  rw [h]
  show some [fun b => if b < 163840 * M then expected C k il s mt M X Cd S b else 0] = _
  congr 2
  funext b
  unfold expected
  split <;> simp_all

end Metal.Kernels.DownMmaWide

namespace Metal.Kernels.DownMmaWide
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis

/-! ## The route's instances

The row-major down projections at (S, MT, NW) = (16, 1, ⌈(32K + 11)/32⌉ + 1), (8, 2, …), (8, 3, …) for 2- and 4-bit
codes; rows `2 ≤ M ≤ 223` (the tails 2–223 and the chunks 16–128 of prefill-map §1–2). The plan picks the instance
from `M` (down-mma-wide.ts:40-53); each holds at every route `M`. Grid `[128, 2·nGroups, ⌈M / (8·MT)⌉]`: y = 80 at
S = 16, 160 at S = 8. Codes are `17408·640·K` bytes: 22282240 (2-bit), 44564480 (4-bit). -/

variable (C : M1Max.Contract) {X Xs Cd S : ByteMemory.Bytes} {ax ash ac as : Nat}

theorem gpu_output_2_16_1 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 2 16 1 4)) (M : Nat) (hM : 2 ≤ M ∧ M ≤ 223)
    (hax : 2 ∣ ax) (hash : 4 ∣ ash) (hac : 4 ∣ ac) (has : 2 ∣ as) (hXs : word32 Xs 0 = M) :
    G.execute (text 2 16 1 4) (128, 80, ceilDiv M 8) (128, 1, 1)
      [⟨.device, 34816 * M, ax, X⟩, ⟨.constant, 8, ash, Xs⟩, ⟨.device, 22282240, ac, Cd⟩, ⟨.device, 34816, as, S⟩]
      [163840 * M] = some [expected C 2 false 16 1 M X Cd S] :=
  gpu_output_of C 2 16 1 4 false (.inl ⟨rfl, rfl, rfl, rfl, rfl⟩) _ compile_2_16_1 G hmax M (by omega) (by omega)
    X Xs Cd S ax ash ac as hax hash hac has hXs

theorem gpu_output_4_16_1 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 4 16 1 6)) (M : Nat) (hM : 2 ≤ M ∧ M ≤ 223)
    (hax : 2 ∣ ax) (hash : 4 ∣ ash) (hac : 4 ∣ ac) (has : 2 ∣ as) (hXs : word32 Xs 0 = M) :
    G.execute (text 4 16 1 6) (128, 80, ceilDiv M 8) (128, 1, 1)
      [⟨.device, 34816 * M, ax, X⟩, ⟨.constant, 8, ash, Xs⟩, ⟨.device, 44564480, ac, Cd⟩, ⟨.device, 34816, as, S⟩]
      [163840 * M] = some [expected C 4 false 16 1 M X Cd S] :=
  gpu_output_of C 4 16 1 6 false (.inr (.inl ⟨rfl, rfl, rfl, rfl, rfl⟩)) _ compile_4_16_1 G hmax M (by omega)
    (by omega) X Xs Cd S ax ash ac as hax hash hac has hXs

theorem gpu_output_2_8_2 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 2 8 2 3)) (M : Nat) (hM : 2 ≤ M ∧ M ≤ 223)
    (hax : 2 ∣ ax) (hash : 4 ∣ ash) (hac : 4 ∣ ac) (has : 2 ∣ as) (hXs : word32 Xs 0 = M) :
    G.execute (text 2 8 2 3) (128, 160, ceilDiv M 16) (128, 1, 1)
      [⟨.device, 34816 * M, ax, X⟩, ⟨.constant, 8, ash, Xs⟩, ⟨.device, 22282240, ac, Cd⟩, ⟨.device, 34816, as, S⟩]
      [163840 * M] = some [expected C 2 false 8 2 M X Cd S] :=
  gpu_output_of C 2 8 2 3 false (.inr (.inr (.inl ⟨rfl, rfl, rfl, rfl, rfl⟩))) _ compile_2_8_2 G hmax M (by omega)
    (by omega) X Xs Cd S ax ash ac as hax hash hac has hXs

theorem gpu_output_4_8_2 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 4 8 2 4)) (M : Nat) (hM : 2 ≤ M ∧ M ≤ 223)
    (hax : 2 ∣ ax) (hash : 4 ∣ ash) (hac : 4 ∣ ac) (has : 2 ∣ as) (hXs : word32 Xs 0 = M) :
    G.execute (text 4 8 2 4) (128, 160, ceilDiv M 16) (128, 1, 1)
      [⟨.device, 34816 * M, ax, X⟩, ⟨.constant, 8, ash, Xs⟩, ⟨.device, 44564480, ac, Cd⟩, ⟨.device, 34816, as, S⟩]
      [163840 * M] = some [expected C 4 false 8 2 M X Cd S] :=
  gpu_output_of C 4 8 2 4 false (.inr (.inr (.inr (.inl ⟨rfl, rfl, rfl, rfl, rfl⟩)))) _ compile_4_8_2 G hmax M
    (by omega) (by omega) X Xs Cd S ax ash ac as hax hash hac has hXs

theorem gpu_output_2_8_3 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 2 8 3 3)) (M : Nat) (hM : 2 ≤ M ∧ M ≤ 223)
    (hax : 2 ∣ ax) (hash : 4 ∣ ash) (hac : 4 ∣ ac) (has : 2 ∣ as) (hXs : word32 Xs 0 = M) :
    G.execute (text 2 8 3 3) (128, 160, ceilDiv M 24) (128, 1, 1)
      [⟨.device, 34816 * M, ax, X⟩, ⟨.constant, 8, ash, Xs⟩, ⟨.device, 22282240, ac, Cd⟩, ⟨.device, 34816, as, S⟩]
      [163840 * M] = some [expected C 2 false 8 3 M X Cd S] :=
  gpu_output_of C 2 8 3 3 false (.inr (.inr (.inr (.inr (.inl ⟨rfl, rfl, rfl, rfl, rfl⟩))))) _ compile_2_8_3 G hmax M
    (by omega) (by omega) X Xs Cd S ax ash ac as hax hash hac has hXs

theorem gpu_output_4_8_3 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 4 8 3 4)) (M : Nat) (hM : 2 ≤ M ∧ M ≤ 223)
    (hax : 2 ∣ ax) (hash : 4 ∣ ash) (hac : 4 ∣ ac) (has : 2 ∣ as) (hXs : word32 Xs 0 = M) :
    G.execute (text 4 8 3 4) (128, 160, ceilDiv M 24) (128, 1, 1)
      [⟨.device, 34816 * M, ax, X⟩, ⟨.constant, 8, ash, Xs⟩, ⟨.device, 44564480, ac, Cd⟩, ⟨.device, 34816, as, S⟩]
      [163840 * M] = some [expected C 4 false 8 3 M X Cd S] :=
  gpu_output_of C 4 8 3 4 false (.inr (.inr (.inr (.inr (.inr (.inl ⟨rfl, rfl, rfl, rfl, rfl⟩)))))) _ compile_4_8_3 G
    hmax M (by omega) (by omega) X Xs Cd S ax ash ac as hax hash hac has hXs

end Metal.Kernels.DownMmaWide
