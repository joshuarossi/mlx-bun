import metal.Logic
import metal.Launch
import metal.tests.Elab
import metal.Gpu
import metal.kernels.GateUp

set_option linter.constructorNameAsVariable false

namespace Metal.Kernels.DownPartial
open Metal Metal.Core Inference.Contracts.Mlx

/-! # down-codebook.ts partial

The header functions the body calls (inlined below; their slots are listed under `body`):

```
static inline int trellis_y(uint s) {
  const uint x = s * 34038481u + 76625530u;
  const uint p = (x & 0x00FF00FFu) + ((x >> 8) & 0x00FF00FFu);
  return (int)((p & 0xFFFFu) + (p >> 16)) - 510;
}
static inline float trellis_unrefined_bits_y(int y) {
  const float lifted = as_type<float>(0x4b000000u | uint(y + 510));
  return (lifted - 8389118.0f) * (1.0f / 147.800537109375f);
}
static inline float trellis_codebook_window(const threadgroup uchar* table, thread const uint* w, thread const uint* v,
                                            uint off, uint l) {
  const int f = int(off) - 2;
  const uint mask = (1u << (l + 2u)) - 1u;
  uint bits;
  if (f >= 0 && uint(f & 31) + l + 2u <= 32u) bits = (w[f >> 5] >> uint(f & 31)) & mask;
  else { const uint vi = uint(f + 16) >> 5; bits = (v[vi] >> uint(f + 16 - 32 * int(vi))) & mask; }
  return *(const threadgroup float*)(table + bits);
}
```
The body:

```
threadgroup float codebook[4096];  // 2^L codes, then the eight SIMD groups' partials
for (uint i = thread_position_in_threadgroup.x; i < (1u << (uint)L); i += (uint)THREADS)
  codebook[i] = trellis_unrefined_bits_y(trellis_y(i));
threadgroup_barrier(metal::mem_flags::mem_threadgroup);
constexpr uint BITS = (uint)(P * K);               // a lane's bits
constexpr uint SHIFT = BITS % 32u;                 // 0, or 16: odd lanes start at bit 16 of a word
constexpr bool ALIGNED = SHIFT == 0u;
constexpr uint NA = (BITS + (uint)L - (uint)K + 31u) / 32u;  // words its windows span from its first bit
constexpr uint NL = ALIGNED ? NA : NA + 1u;        // words it loads
constexpr uint LB = 256u / (uint)P;                // lanes per block
constexpr uint WPB = 8u * (uint)K;                 // words per block
constexpr uint NB = (uint)(C / 256);               // blocks
constexpr uint SGS = (NB + 32u / LB - 1u) / (32u / LB); // SIMD groups per split
constexpr ulong ROWW = INTERLEAVE ? 2ul * WPB : (ulong)NB * WPB;
constexpr uint ROWS_PER = ((uint)R + (uint)SPLITS - 1u) / (uint)SPLITS;
constexpr uint SG_COLS = 32u * (uint)P;            // a SIMD group's columns
// Threadgroup t: row group y = t % 32 and SIMD groups (k, c) = (s % 4, s / 4) take split y + 32k of column group
// 2·(t / 32) + c, so the threadgroup holds the four splits MLX's column sum adds first for 2·SG_COLS columns.
const uint lane = thread_index_in_simdgroup;
const uint sg = simdgroup_index_in_threadgroup;
const uint ty = threadgroup_position_in_grid.y;
const uint y = ty % 32u;
const uint split = y + 32u * (sg % 4u);
const uint colGroup = 2u * (ty / 32u) + sg / 4u;
const uint li = lane % LB;
const uint blk = colGroup * (32u / LB) + lane / LB;
const bool active = colGroup < SGS && blk < NB;
const device uint32_t* blockWords = codes + (!active ? 0ul : INTERLEAVE
  ? (ulong)(blk / 2u) * (ulong)R * 2ul * WPB + (blk % 2u) * WPB : (ulong)blk * WPB);
const uint first = (li * BITS) >> 5;
const bool shifted = !ALIGNED && (li & 1u);
uint idx[NL];
#pragma clang loop unroll(full)
for (uint i = 0; i < NL; ++i) idx[i] = (first + i) % WPB;
const uint r0 = split * ROWS_PER;
const uint rows = !active ? 0u : (uint)R % (uint)SPLITS == 0u ? ROWS_PER : r0 >= (uint)R ? 0u : metal::min(ROWS_PER, (uint)R - r0);
const threadgroup uchar* table = (const threadgroup uchar*)codebook;
float acc[P];
#pragma clang loop unroll(full)
for (uint i = 0; i < (uint)P; ++i) acc[i] = 0.0f;
uint r = 0;
for (; r + (uint)U <= rows; r += (uint)U) {
  uint ld[U][NL];
  float xr[U], sr[U];
  #pragma clang loop unroll(full)
  for (uint u = 0; u < (uint)U; ++u) {
    const device uint32_t* rowWords = blockWords + (ulong)(r0 + r + u) * ROWW;
    #pragma clang loop unroll(full)
    for (uint i = 0; i < NL; ++i) ld[u][i] = rowWords[idx[i]];
    xr[u] = float(x[r0 + r + u]);
    sr[u] = float(scales[r0 + r + u]);
  }
  #pragma clang loop unroll(full)
  for (uint u = 0; u < (uint)U; ++u) {
    uint w[NA], v[NA];
    #pragma clang loop unroll(full)
    for (uint i = 0; i < NA; ++i) w[i] = shifted ? (ld[u][i] >> SHIFT) | (ld[u][i + 1] << (32u - SHIFT)) : ld[u][i];
    v[0] = w[0] << 16;
    #pragma clang loop unroll(full)
    for (uint i = 1; i < NA; ++i) v[i] = (w[i - 1] >> 16) | (w[i] << 16);
    #pragma clang loop unroll(full)
    for (uint i = 0; i < (uint)P; ++i) {
      const float code = trellis_codebook_window(table, w, v, i * (uint)K, (uint)L);
      acc[i] = metal::fma(code * sr[u], xr[u], acc[i]);
    }
  }
}
for (; r < rows; ++r) {
  const device uint32_t* rowWords = blockWords + (ulong)(r0 + r) * ROWW;
  uint ld[NL];
  #pragma clang loop unroll(full)
  for (uint i = 0; i < NL; ++i) ld[i] = rowWords[idx[i]];
  const float xr = float(x[r0 + r]);
  const float sr = float(scales[r0 + r]);
  uint w[NA], v[NA];
  #pragma clang loop unroll(full)
  for (uint i = 0; i < NA; ++i) w[i] = shifted ? (ld[i] >> SHIFT) | (ld[i + 1] << (32u - SHIFT)) : ld[i];
  v[0] = w[0] << 16;
  #pragma clang loop unroll(full)
  for (uint i = 1; i < NA; ++i) v[i] = (w[i - 1] >> 16) | (w[i] << 16);
  #pragma clang loop unroll(full)
  for (uint i = 0; i < (uint)P; ++i) {
    const float code = trellis_codebook_window(table, w, v, i * (uint)K, (uint)L);
    acc[i] = metal::fma(code * sr, xr, acc[i]);
  }
}
// The four splits' partials meet in the codebook's memory; each column's first sum stage, ((0 + p[y]) + p[y + 32])
// + ..., in MLX's order, goes out as row y of the 32 the fold sums.
threadgroup_barrier(metal::mem_flags::mem_threadgroup);
threadgroup float* sums = codebook;
const uint local = (lane / LB) * 256u + 255u - li * (uint)P;
#pragma clang loop unroll(full)
for (uint i = 0; i < (uint)P; ++i) sums[sg * SG_COLS + local - i] = acc[i];
threadgroup_barrier(metal::mem_flags::mem_threadgroup);
for (uint c = thread_position_in_threadgroup.x; c < 2u * SG_COLS; c += (uint)THREADS) {
  const uint group2 = c / SG_COLS, col = (2u * (ty / 32u) + group2) * SG_COLS + c % SG_COLS;
  if (col >= (uint)C) continue;
  float t = 0.0f;
  #pragma clang loop unroll(full)
  for (uint k = 0; k < 4u; ++k) t = sums[(group2 * 4u + k) * SG_COLS + c % SG_COLS] + t;
  partial[(ulong)y * (ulong)C + col] = t;
}
```
at `downConfig K` (the route's down widths): grid [256, 160, 1], threadgroup [256, 1, 1], so 160 threadgroups of
8 SIMD-groups, with T = bfloat, R = 17408, C = 5120, L = 12, P = 16, U = 2, SPLITS = 128, THREADS = 256 and
INTERLEAVE = 1 exactly when K = 3. The `constexpr` values fold to BITS = 16·K, SHIFT = BITS % 32 (16 for odd K,
else 0: ALIGNED), NA = (15·K + 43)/32, NL = NA or NA + 1, LB = 16, WPB = 8·K, NB = 20, SGS = 10,
ROWW = 2·WPB (interleaved) or 20·WPB, ROWS_PER = 136, SG_COLS = 512. `core K shifted interleaved` is the
elaborated kernel, `shifted` standing for `!ALIGNED`. -/

def u32l (n : Nat) : CExpr := .lit (.int .u32 n)
def u64l (n : Nat) : CExpr := .lit (.int .u64 n)
def i32l (n : Nat) : CExpr := .lit (.int .i32 n)
def f32l (bits : Nat) : CExpr := .lit (.f32 (Val.ofF32Bits bits))

/-- `i < n` and `i += d` for the `uint` counter in slot `i`. -/
def ltU (i n : Nat) : CExpr := .bin .lt .u32 0 (.local i) (u32l n)
def stepU (i d : Nat) : List CStmt := [.set i (.bin .add .u32 0 (.local i) (u32l d))]

/-! ## The folded constants -/

/-- `NA`: the words a lane's windows span from its first bit. -/
def na (k : Nat) : Nat := (15 * k + 43) / 32
/-- `NL`: the words a lane loads. -/
def nl (k : Nat) (sf : Bool) : Nat := if sf then na k + 1 else na k
/-- `SHIFT`. -/
def shift (sf : Bool) : Nat := if sf then 16 else 0
/-- `WPB`: words per block. -/
def wpb (k : Nat) : Nat := 8 * k
/-- `ROWW`: words between rows. -/
def roww (k : Nat) (il : Bool) : Nat := if il then 2 * wpb k else 20 * wpb k

/-! ## The codebook -/

/-- `trellis_y(s)` (slots `b` s, `b + 1` result, `b + 2` x, `b + 3` p). -/
def trellisY (b : Nat) : CStmt :=
  .scope
    [.set (b + 2) (.bin .add .u32 0 (.bin .mul .u32 0 (.local b) (u32l 34038481)) (u32l 76625530)),
     .set (b + 3)
       (.bin .add .u32 0 (.bin .bitAnd .u32 0 (.local (b + 2)) (u32l 16711935))
         (.bin .bitAnd .u32 0 (.bin .shr .u32 0 (.local (b + 2)) (u32l 8)) (u32l 16711935))),
     .set (b + 1)
       (.bin .sub .i32 0
         (.conv .i32
           (.bin .add .u32 0 (.bin .bitAnd .u32 0 (.local (b + 3)) (u32l 65535))
             (.bin .shr .u32 0 (.local (b + 3)) (u32l 16))))
         (i32l 510)),
     .leave]
/-- `trellis_unrefined_bits_y(y)` (slots `b` y, `b + 1` result, `b + 2` lifted). -/
def unrefinedY (b : Nat) : CStmt :=
  .scope
    [.set (b + 2)
       (.bitcast .f32 (.bin .bitOr .u32 0 (u32l 1258291200) (.conv .u32 (.bin .add .i32 0 (.local b) (i32l 510))))),
     .set (b + 1) (.bin .mul .f32 0 (.bin .sub .f32 0 (.local (b + 2)) (f32l 0x4B0001FE)) (f32l 0x3BDDB447)),
     .leave]
def fillBody : List CStmt :=
  [.set 6 (.local 5), trellisY 6, .set 10 (.local 7), unrefinedY 10,
   .store (.scalar .f32) (.offset (.local 4) (.local 5)) (.local 11)]
def fillLoop : CStmt := .loop (ltU 5 4096) (stepU 5 256) fillBody

/-! ## `trellis_codebook_window` -/

/-- `f >= 0 && uint(f & 31) + l + 2u <= 32u`, with `f` in slot `b + 6` and `l` in slot `b + 4`. -/
def inWord (b : Nat) : CExpr :=
  .and (.bin .ge .i32 0 (.local (b + 6)) (i32l 0))
    (.bin .le .u32 0
      (.bin .add .u32 0 (.bin .add .u32 0 (.conv .u32 (.bin .bitAnd .i32 0 (.local (b + 6)) (i32l 31))) (.local (b + 4)))
        (u32l 2))
      (u32l 32))
/-- `bits = (w[f >> 5] >> uint(f & 31)) & mask`. -/
def bitsInWord (b : Nat) : List CStmt :=
  [.set (b + 8)
    (.bin .bitAnd .u32 0
      (.bin .shr .u32 0
        (.load (.scalar .u32) (.offset (.local (b + 1)) (.bin .shr .i32 0 (.local (b + 6)) (i32l 5))))
        (.conv .u32 (.bin .bitAnd .i32 0 (.local (b + 6)) (i32l 31))))
      (.local (b + 7)))]
/-- `vi = uint(f + 16) >> 5; bits = (v[vi] >> uint(f + 16 - 32 * int(vi))) & mask`. -/
def bitsInVirtual (b : Nat) : List CStmt :=
  [.set (b + 9) (.bin .shr .u32 0 (.conv .u32 (.bin .add .i32 0 (.local (b + 6)) (i32l 16))) (u32l 5)),
   .set (b + 8)
     (.bin .bitAnd .u32 0
       (.bin .shr .u32 0 (.load (.scalar .u32) (.offset (.local (b + 2)) (.local (b + 9))))
         (.conv .u32
           (.bin .sub .i32 0 (.bin .add .i32 0 (.local (b + 6)) (i32l 16))
             (.bin .mul .i32 0 (i32l 32) (.conv .i32 (.local (b + 9)))))))
       (.local (b + 7)))]
/-- The inlined `trellis_codebook_window(table, w, v, off, l)`: parameters in slots `b … b + 4`, result in
`b + 5`, then `f`, `mask`, `bits`, `vi` in `b + 6 … b + 9`. -/
def window (b : Nat) : CStmt :=
  .scope
    [.set (b + 6) (.bin .sub .i32 0 (.conv .i32 (.local (b + 3))) (i32l 2)),
     .set (b + 7) (.bin .sub .u32 0 (.bin .shl .u32 0 (u32l 1) (.bin .add .u32 0 (.local (b + 4)) (u32l 2))) (u32l 1)),
     .ite (inWord b) (bitsInWord b) (bitsInVirtual b),
     .set (b + 5) (.load (.scalar .f32) (.ptrCast (.scalar .f32) (.offset (.local b) (.local (b + 8))))),
     .leave]
/-- Call `trellis_codebook_window(table, w, v, i * K, L)`: parameters in slots `b … b + 4`. -/
def lookup (k b w v i : Nat) : List CStmt :=
  [.set b (.local 29), .set (b + 1) (.local w), .set (b + 2) (.local v),
   .set (b + 3) (.bin .mul .u32 0 (.local i) (u32l k)), .set (b + 4) (u32l 12), window b]

/-! ## A lane's rows -/

/-- `acc[i]`. -/
def accAt (i : Nat) : CExpr := .load (.scalar .f32) (.offset (.local 30) (.local i))
/-- `dst[i] = rowWords[idx[i]]` for `i < NL`: counter slot `i`, `rowWords` slot `rw`. -/
def loadWords (n i rw : Nat) (dst : CExpr) : CStmt :=
  .loop (ltU i n) (stepU i 1)
    [.store (.scalar .u32) (.offset dst (.local i))
      (.load (.scalar .u32) (.offset (.local rw) (.load (.scalar .u32) (.offset (.local 25) (.local i)))))]
/-- `w[i] = shifted ? (ld[i] >> SHIFT) | (ld[i + 1] << (32u - SHIFT)) : ld[i]` for `i < NA`. -/
def alignWords (n s i w : Nat) (ld : CExpr) : CStmt :=
  .loop (ltU i n) (stepU i 1)
    [.store (.scalar .u32) (.offset (.local w) (.local i))
      (.cond (.local 24)
        (.bin .bitOr .u32 0 (.bin .shr .u32 0 (.load (.scalar .u32) (.offset ld (.local i))) (u32l s))
          (.bin .shl .u32 0 (.load (.scalar .u32) (.offset ld (.bin .add .u32 0 (.local i) (u32l 1)))) (u32l (32 - s))))
        (.load (.scalar .u32) (.offset ld (.local i))))]
/-- `v[0] = w[0] << 16`. -/
def firstVirtual (w v : Nat) : CStmt :=
  .store (.scalar .u32) (.offset (.local v) (i32l 0))
    (.bin .shl .u32 0 (.load (.scalar .u32) (.offset (.local w) (i32l 0))) (u32l 16))
/-- `for (i = 1; i < NA; ++i) v[i] = (w[i - 1] >> 16) | (w[i] << 16)`. -/
def virtualWords (n i w v : Nat) : CStmt :=
  .loop (ltU i n) (stepU i 1)
    [.store (.scalar .u32) (.offset (.local v) (.local i))
      (.bin .bitOr .u32 0
        (.bin .shr .u32 0 (.load (.scalar .u32) (.offset (.local w) (.bin .sub .u32 0 (.local i) (u32l 1)))) (u32l 16))
        (.bin .shl .u32 0 (.load (.scalar .u32) (.offset (.local w) (.local i))) (u32l 16)))]

/-- `r0 + r + u` for the row-pair loop (`r` in slot 32, `u` in slot `u`). -/
def pairRow (u : Nat) : CExpr := .bin .add .u32 0 (.bin .add .u32 0 (.local 27) (.local 32)) (.local u)
/-- `ld[u]`: the `NL` words of row `u` of the pair. -/
def ldRow (n u : Nat) : CExpr := .offset (.local 33) (.bin .mul .u64 0 (.conv .u64 (.local u)) (u64l n))

/-- Row `u` of the pair: `rowWords`, its words `ld[u]`, `xr[u]` and `sr[u]`. -/
def loadRowBody (k : Nat) (sf il : Bool) : List CStmt :=
  [.set 37 (.offset (.local 22) (.bin .mul .u64 0 (.conv .u64 (pairRow 36)) (u64l (roww k il)))),
   .set 38 (u32l 0),
   loadWords (nl k sf) 38 37 (ldRow (nl k sf) 36),
   .store (.scalar .f32) (.offset (.local 34) (.local 36)) (.conv .f32 (.load (.scalar .bf16) (.offset (.local 0) (pairRow 36)))),
   .store (.scalar .f32) (.offset (.local 35) (.local 36)) (.conv .f32 (.load (.scalar .f16) (.offset (.local 2) (pairRow 36))))]
def loadRowLoop (k : Nat) (sf il : Bool) : CStmt := .loop (ltU 36 2) (stepU 36 1) (loadRowBody k sf il)

/-- `acc[i] = fma(code * sr[u], xr[u], acc[i])` for the codes of row `u` of the pair. -/
def pairCodeBody (k : Nat) : List CStmt :=
  lookup k 45 40 41 44 ++
  [.set 55 (.local 50),
   .store (.scalar .f32) (.offset (.local 30) (.local 44))
     (.fma (.bin .mul .f32 0 (.local 55) (.load (.scalar .f32) (.offset (.local 35) (.local 39))))
       (.load (.scalar .f32) (.offset (.local 34) (.local 39))) (accAt 44))]
def pairRowBody (k : Nat) (sf : Bool) : List CStmt :=
  [.array 40 false 5 (.scalar .u32),
   .array 41 false 6 (.scalar .u32),
   .set 42 (u32l 0),
   alignWords (na k) (shift sf) 42 40 (ldRow (nl k sf) 39),
   firstVirtual 40 41,
   .set 43 (u32l 1),
   virtualWords (na k) 43 40 41,
   .set 44 (u32l 0),
   .loop (ltU 44 16) (stepU 44 1) (pairCodeBody k)]
def pairBody (k : Nat) (sf il : Bool) : List CStmt :=
  [.array 33 false 2 (.scalar .u32),
   .array 34 false 3 (.scalar .f32),
   .array 35 false 4 (.scalar .f32),
   .set 36 (u32l 0),
   loadRowLoop k sf il,
   .set 39 (u32l 0),
   .loop (ltU 39 2) (stepU 39 1) (pairRowBody k sf)]
/-- `for (; r + U <= rows; r += U)`. -/
def pairLoop (k : Nat) (sf il : Bool) : CStmt :=
  .loop (.bin .le .u32 0 (.bin .add .u32 0 (.local 32) (u32l 2)) (.local 28)) (stepU 32 2) (pairBody k sf il)

/-- `r0 + r` for the single-row loop. -/
def tailRow : CExpr := .bin .add .u32 0 (.local 27) (.local 32)
def tailCodeBody (k : Nat) : List CStmt :=
  lookup k 66 61 62 65 ++
  [.set 76 (.local 71),
   .store (.scalar .f32) (.offset (.local 30) (.local 65))
     (.fma (.bin .mul .f32 0 (.local 76) (.local 60)) (.local 59) (accAt 65))]
def tailBody (k : Nat) (sf il : Bool) : List CStmt :=
  [.set 56 (.offset (.local 22) (.bin .mul .u64 0 (.conv .u64 tailRow) (u64l (roww k il)))),
   .array 57 false 7 (.scalar .u32),
   .set 58 (u32l 0),
   loadWords (nl k sf) 58 56 (.local 57),
   .set 59 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 0) tailRow))),
   .set 60 (.conv .f32 (.load (.scalar .f16) (.offset (.local 2) tailRow))),
   .array 61 false 8 (.scalar .u32),
   .array 62 false 9 (.scalar .u32),
   .set 63 (u32l 0),
   alignWords (na k) (shift sf) 63 61 (.local 57),
   firstVirtual 61 62,
   .set 64 (u32l 1),
   virtualWords (na k) 64 61 62,
   .set 65 (u32l 0),
   .loop (ltU 65 16) (stepU 65 1) (tailCodeBody k)]
/-- `for (; r < rows; ++r)`. -/
def tailLoop (k : Nat) (sf il : Bool) : CStmt := .loop (.bin .lt .u32 0 (.local 32) (.local 28)) (stepU 32 1) (tailBody k sf il)

/-! ## Setup and the column sums -/

/-- `2u * (ty / 32u)`. -/
def groupBase : CExpr := .bin .mul .u32 0 (u32l 2) (.bin .div .u32 0 (.local 15) (u32l 32))
/-- `blockWords`' offset for an active lane: `(blk / 2) * R * 2 * WPB + (blk % 2) * WPB` (interleaved) or
`blk * WPB`. -/
def blockOffset (k : Nat) (il : Bool) : CExpr :=
  if il then
    .bin .add .u64 0
      (.bin .mul .u64 0
        (.bin .mul .u64 0 (.bin .mul .u64 0 (.conv .u64 (.bin .div .u32 0 (.local 20) (u32l 2))) (u64l 17408)) (u64l 2))
        (u64l (wpb k)))
      (.conv .u64 (.bin .mul .u32 0 (.bin .rem .u32 0 (.local 20) (u32l 2)) (u32l (wpb k))))
  else .bin .mul .u64 0 (.conv .u64 (.local 20)) (u64l (wpb k))
/-- `shifted = !ALIGNED && (li & 1u)`. -/
def shiftedExpr (sf : Bool) : CExpr :=
  if sf then .conv .bool (.bin .bitAnd .u32 0 (.local 19) (u32l 1)) else .lit (.bool false)
def idxLoop (k : Nat) (sf : Bool) : CStmt :=
  .loop (ltU 26 (nl k sf)) (stepU 26 1)
    [.store (.scalar .u32) (.offset (.local 25) (.local 26))
      (.bin .rem .u32 0 (.bin .add .u32 0 (.local 23) (.local 26)) (u32l (wpb k)))]
def zeroLoop : CStmt :=
  .loop (ltU 31 16) (stepU 31 1) [.store (.scalar .f32) (.offset (.local 30) (.local 31)) (f32l 0x0)]

/-- `sums[sg * SG_COLS + local - i] = acc[i]`. -/
def scatterLoop : CStmt :=
  .loop (ltU 79 16) (stepU 79 1)
    [.store (.scalar .f32)
      (.offset (.local 77)
        (.bin .sub .u32 0 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 14) (u32l 512)) (.local 78)) (.local 79)))
      (accAt 79)]
/-- `t = sums[(group2 * 4 + k) * SG_COLS + c % SG_COLS] + t`. -/
def foldLoop : CStmt :=
  .loop (ltU 84 4) (stepU 84 1)
    [.set 83
      (.bin .add .f32 0
        (.load (.scalar .f32)
          (.offset (.local 77)
            (.bin .add .u32 0
              (.bin .mul .u32 0 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 81) (u32l 4)) (.local 84)) (u32l 512))
              (.bin .rem .u32 0 (.local 80) (u32l 512)))))
        (.local 83))]
def padStmt : CStmt := .ite (.bin .ge .u32 0 (.local 82) (u32l 5120)) [.continue_] []
def columnBody : List CStmt :=
  [.set 81 (.bin .div .u32 0 (.local 80) (u32l 512)),
   .set 82
     (.bin .add .u32 0 (.bin .mul .u32 0 (.bin .add .u32 0 groupBase (.local 81)) (u32l 512))
       (.bin .rem .u32 0 (.local 80) (u32l 512))),
   padStmt,
   .set 83 (f32l 0x0),
   .set 84 (u32l 0),
   foldLoop,
   .store (.scalar .f32)
     (.offset (.local 3) (.bin .add .u64 0 (.bin .mul .u64 0 (.conv .u64 (.local 16)) (u64l 5120)) (.conv .u64 (.local 82))))
     (.local 83)]

/-- Slots: 0 x, 1 codes, 2 scales, 3 partial, 4 codebook (threadgroup array 0), 5 i, 6 … 9 `trellis_y`'s
`s result x p`, 10 … 12 `trellis_unrefined_bits_y`'s `y result lifted`, 13 lane, 14 sg, 15 ty, 16 y, 17 split,
18 colGroup, 19 li, 20 blk, 21 active, 22 blockWords, 23 first, 24 shifted, 25 idx (thread array 0), 26 i,
27 r0, 28 rows, 29 table, 30 acc (thread array 1), 31 i, 32 r;
the row-pair loop: 33 ld (thread array 2), 34 xr (array 3), 35 sr (array 4), 36 u, 37 rowWords, 38 i, 39 u,
40 w (array 5), 41 v (array 6), 42 i, 43 i, 44 i, 45 … 54 `trellis_codebook_window` (`table w v off l`,
result 50, `f mask bits vi`), 55 code;
the single-row loop: 56 rowWords, 57 ld (array 7), 58 i, 59 xr, 60 sr, 61 w (array 8), 62 v (array 9), 63 i,
64 i, 65 i, 66 … 75 `trellis_codebook_window` (result 71), 76 code;
77 sums, 78 local, 79 i, 80 c, 81 group2, 82 col, 83 t, 84 k. -/
def body (k : Nat) (sf il : Bool) : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .bf16⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .u32⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .f16⟩)),
   .set 3 (.lit (.ptr ⟨3, 0, .scalar .f32⟩)),
   .array 4 true 0 (.scalar .f32),
   .set 5 (.component (.coord .threadPositionInThreadgroup) (u32l 0)),
   fillLoop,
   .barrier 1 false true,
   .set 13 (.coord .threadIndexInSimdgroup),
   .set 14 (.coord .simdgroupIndexInThreadgroup),
   .set 15 (.component (.coord .threadgroupPositionInGrid) (u32l 1)),
   .set 16 (.bin .rem .u32 0 (.local 15) (u32l 32)),
   .set 17 (.bin .add .u32 0 (.local 16) (.bin .mul .u32 0 (u32l 32) (.bin .rem .u32 0 (.local 14) (u32l 4)))),
   .set 18 (.bin .add .u32 0 groupBase (.bin .div .u32 0 (.local 14) (u32l 4))),
   .set 19 (.bin .rem .u32 0 (.local 13) (u32l 16)),
   .set 20 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 18) (u32l 2)) (.bin .div .u32 0 (.local 13) (u32l 16))),
   .set 21 (.and (.bin .lt .u32 0 (.local 18) (u32l 10)) (.bin .lt .u32 0 (.local 20) (u32l 20))),
   .set 22 (.offset (.local 1) (.cond (.un .not .bool (.local 21)) (u64l 0) (blockOffset k il))),
   .set 23 (.bin .shr .u32 0 (.bin .mul .u32 0 (.local 19) (u32l (16 * k))) (u32l 5)),
   .set 24 (shiftedExpr sf),
   .array 25 false 0 (.scalar .u32),
   .set 26 (u32l 0),
   idxLoop k sf,
   .set 27 (.bin .mul .u32 0 (.local 17) (u32l 136)),
   .set 28 (.cond (.un .not .bool (.local 21)) (u32l 0) (u32l 136)),
   .set 29 (.ptrCast (.scalar .u8) (.local 4)),
   .array 30 false 1 (.scalar .f32),
   .set 31 (u32l 0),
   zeroLoop,
   .set 32 (u32l 0),
   pairLoop k sf il,
   tailLoop k sf il,
   .barrier 2 false true,
   .set 77 (.local 4),
   .set 78
     (.bin .sub .u32 0
       (.bin .add .u32 0 (.bin .mul .u32 0 (.bin .div .u32 0 (.local 13) (u32l 16)) (u32l 256)) (u32l 255))
       (.bin .mul .u32 0 (.local 19) (u32l 16))),
   .set 79 (u32l 0),
   scatterLoop,
   .barrier 3 false true,
   .set 80 (.component (.coord .threadPositionInThreadgroup) (u32l 0)),
   .loop (ltU 80 1024) (stepU 80 256) columnBody]

def core (k : Nat) (sf il : Bool) : Kernel :=
  ⟨4, [(.scalar .f32, 4096)],
    [(.scalar .u32, nl k sf), (.scalar .f32, 16), (.scalar .u32, 2 * nl k sf), (.scalar .f32, 2), (.scalar .f32, 2),
      (.scalar .u32, na k), (.scalar .u32, na k), (.scalar .u32, nl k sf), (.scalar .u32, na k), (.scalar .u32, na k)],
    body k sf il⟩

/-! ## The texts MLX compiles

As tests/Assemble.lean builds `downPartialText`: x (gate-up's output) `[1,17408]` bf16, codes `uint32
[17408, 5120·K/32]` or, interleaved, `[5120/512, 17408, 48]` (trellisGeometry), scales `float16 [17408]`, at
`downConfig K`. -/

def inputs (k : Nat) : List Assemble.Input :=
  [⟨chars!"x", .bfloat16, [1, 17408]⟩,
   (if k = 3 then ⟨chars!"codes", .uint32, [10, 17408, 48]⟩ else ⟨chars!"codes", .uint32, [17408, 160 * k]⟩),
   ⟨chars!"scales", .float16, [17408]⟩]

def text (k : Nat) : List Char :=
  (Assemble.Tests.launch .downPartial chars!"mlx_bun_trellis_down_codebook_row" (inputs k) [chars!"partial"]
    (Host.Mlx.downConfig k)).getD []

/-- At down 3-bit the text is tests/Elab.lean's `downPartialText`. -/
theorem text_three : text 3 = Metal.Elab.Tests.downPartialText := by decide +kernel

-- The elaborated text MLX compiles at each of the route's down widths is `core`.
kernel_rfl compile_2 : (frontend (text 2)).bind elaborate = some (core 2 false false)
kernel_rfl compile_3 : (frontend (text 3)).bind elaborate = some (core 3 true true)
kernel_rfl compile_4 : (frontend (text 4)).bind elaborate = some (core 4 false false)

open Metal.Kernels.Trellis

/-! ## Counted fills of thread arrays -/

section Fill
variable (C : M1Max.Contract) {ctx : Ctx}

/-- A counted loop storing `F m` at element `q + m` of thread array `reg` for `m < n` (counter slot `c`; `dst` the
array at element `q`; `e` may read memory). -/
theorem exec_fillAt {Inv : Shared → Prop} {reg : Nat} {l : Locals} {sh : Shared} {size q : Nat}
    (hput : ∀ sh o bs, Inv sh → Inv (tput sh reg o bs)) (s : Scalar) (hs : s.bytes = 4) (n c : Nat) (dst e : CExpr)
    (F : Nat → Val) (enc : Nat → List (BitVec 8))
    (hdst : ∀ (l' : Locals) (sh' : Shared), (∀ j, j ≠ c → l' j = l j) → Inv sh' →
      (eval C ctx l' dst).run sh' = some (.ptr ⟨reg, ((4 * q : Nat) : Int), .scalar s⟩, sh'))
    (he : ∀ (l' : Locals) (sh' : Shared) (m : Nat), m < n → l' c = some (u32 m) → (∀ j, j ≠ c → l' j = l j) →
      Inv sh' → ∃ sh'', (eval C ctx l' e).run sh' = some (F m, sh'') ∧ Inv sh'' ∧ sh''.bytes = sh'.bytes)
    (henc : ∀ m, encode (.scalar s) (F m) = some (enc m)) (hlen : ∀ m, (enc m).length = 4)
    (hr : ∀ sh', Inv sh' → sh'.regions reg = some ⟨.thread, size, 4⟩) (hsize : 4 * (q + n) ≤ size) (hn : n < 2 ^ 30)
    (h0 : Inv sh) :
    ∃ l' sh', Exec C ctx [.set c (u32l 0), .loop (ltU c n) (stepU c 1)
        [.store (.scalar s) (.offset dst (.local c)) e]] l sh .normal l' sh' ∧ Inv sh' ∧
      (∀ j, j ≠ c → l' j = l j) ∧ (∀ r, r ≠ reg → sh'.bytes r = sh.bytes r) ∧
      (∀ o, o + 4 ≤ 4 * q ∨ 4 * (q + n) ≤ o → cells (sh'.bytes reg) o 4 = cells (sh.bytes reg) o 4) ∧
      ∀ m < n, cells (sh'.bytes reg) (4 * (q + m)) 4 = enc m := by
  let J : Nat → Locals → Shared → Prop := fun k l' sh' => Inv sh' ∧ (∀ j, j ≠ c → l' j = l j) ∧ l' c = some (u32 k) ∧
    (∀ r, r ≠ reg → sh'.bytes r = sh.bytes r) ∧
    (∀ o, o + 4 ≤ 4 * q ∨ 4 * (q + n) ≤ o → cells (sh'.bytes reg) o 4 = cells (sh.bytes reg) o 4) ∧
    ∀ m < k, cells (sh'.bytes reg) (4 * (q + m)) 4 = enc m
  obtain ⟨l', sh', hex, hJ⟩ := Exec.loop_count (c := ltU c n) (st := stepU c 1) (ctx := ctx) (C := C) n J J
    (fun k hk l' sh' hJ => ⟨sh', eval_lt_u32 C (ctx := ctx) (sh := sh') (b := n) hJ.2.2.1 (by omega) (by omega), hJ⟩)
    (fun k hk l' sh' hJ => by
      obtain ⟨hinv, hag, hc, hoth, hkeep, hw⟩ := hJ
      have hptr : (eval C ctx l' (.offset dst (.local c))).run sh' =
          some (.ptr ⟨reg, ((4 * (q + k) : Nat) : Int), .scalar s⟩, sh') := by
        have := eval_offset_u32 C (ctx := ctx) (hdst l' sh' hag hinv) (eval_local' C hc sh') (by omega)
        rwa [show 4 * q + k * (Ty.scalar s).bytes = 4 * (q + k) by simp [Ty.bytes, hs]; ring] at this
      obtain ⟨sh'', hev, hinv'', hb''⟩ := he l' sh' k hk hc hag hinv
      have hst := store_thread ctx s sh'' reg (4 * (q + k)) size 4 (F k) (enc k) (hr sh'' hinv'') (by rw [hs])
        (by rw [hs]; omega) (by rw [hs]; omega) (henc k)
      refine ⟨.normal, l', _, setLocal l' c (u32 (k + 1)), _, .inl rfl, .store hptr hev hst (.nil _ _),
        .set (eval_bin_u32 C (eval_local' C hc _) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C k 1)) (.nil _ _),
        hput _ _ _ hinv'', fun j hj => by rw [setLocal_other _ _ hj]; exact hag j hj, setLocal_same _ _ _,
        fun r hr' => by rw [tput_other _ _ _ hr', hb'', hoth r hr'], fun o ho => ?_, fun m hm => ?_⟩
      · rw [tput_same, hb'', cells_writeBytes_other _ _ _ _ _ (by rw [hlen]; omega), hkeep o ho]
      rw [tput_same, hb'']
      by_cases hmk : m = k
      · subst hmk
        have := cells_writeBytes_same (sh'.bytes reg) (4 * (q + m)) (enc m)
        rwa [hlen] at this
      · rw [cells_writeBytes_other _ _ _ _ _ (by rw [hlen]; omega)]
        exact hw m (by omega))
    (l := setLocal l c (u32 0)) (sh := sh)
    ⟨h0, fun j hj => setLocal_other _ _ hj, setLocal_same _ _ _, fun _ _ => rfl, fun _ _ => rfl,
      fun m hm => absurd hm (by omega)⟩
  exact ⟨l', sh', .set (eval_u32lit C _ _ 0 (by decide)) hex, hJ.1, hJ.2.1, hJ.2.2.2.1, hJ.2.2.2.2.1, hJ.2.2.2.2.2⟩

/-- A counted loop storing `F m` into thread array `p` at `m` for `m < n` (counter slot `c`). -/
theorem exec_fillArray {Inv : Shared → Prop} {reg : Nat} {l : Locals} {sh : Shared} {size : Nat}
    (hput : ∀ sh o bs, Inv sh → Inv (tput sh reg o bs)) (s : Scalar)
    (hs : s.bytes = 4) (n c p : Nat) (e : CExpr) (F : Nat → Val) (enc : Nat → List (BitVec 8))
    (he : ∀ (l' : Locals) (sh' : Shared) (m : Nat), m < n → l' c = some (u32 m) → (∀ j, j ≠ c → l' j = l j) →
      Inv sh' → (eval C ctx l' e).run sh' = some (F m, sh'))
    (henc : ∀ m, encode (.scalar s) (F m) = some (enc m)) (hlen : ∀ m, (enc m).length = 4)
    (hp : l p = some (.ptr ⟨reg, 0, .scalar s⟩)) (hcp : c ≠ p)
    (hr : ∀ sh', Inv sh' → sh'.regions reg = some ⟨.thread, size, 4⟩) (hsize : 4 * n ≤ size) (hn : n < 2 ^ 30)
    (h0 : Inv sh) :
    ∃ l' sh', Exec C ctx [.set c (u32l 0), .loop (ltU c n) (stepU c 1)
        [.store (.scalar s) (.offset (.local p) (.local c)) e]] l sh .normal l' sh' ∧ Inv sh' ∧
      (∀ j, j ≠ c → l' j = l j) ∧ (∀ r, r ≠ reg → sh'.bytes r = sh.bytes r) ∧
      ∀ m < n, cells (sh'.bytes reg) (4 * m) 4 = enc m := by
  obtain ⟨l', sh', hex, h1, h2, h3, -, h4⟩ := exec_fillAt C (ctx := ctx) (q := 0) hput s hs n c (.local p) e F enc
    (fun l' sh' hag _ => eval_local' C (by rw [hag p hcp.symm]; exact hp) sh')
    (fun l' sh' m hm hc hag hi => ⟨sh', he l' sh' m hm hc hag hi, hi, rfl⟩) henc hlen hr (by omega) hn h0
  exact ⟨l', sh', hex, h1, h2, h3, fun m hm => by have := h4 m hm; rwa [Nat.zero_add] at this⟩

end Fill

/-! ## Expected outputs

The quantities of the source on the inputs' elements, with the operations the core applies. The core has no
contraction sites (its products feed `fma`s, its sums add loads), so the compiler's fusion choices do not enter. -/

section Spec
variable (C : M1Max.Contract)

def zero : Float32 := Val.ofF32Bits 0

/-- `float(x[r])`: element `r` of `x` (bf16), widened. -/
def xr (X : ByteMemory.Bytes) (r : Nat) : Float32 := C.widen (Val.ofBf16Bits (half X r))

/-- The first word of row `r`'s block `blk` of `K`-bit codes, `blockWords + r·ROWW`: block pairs `[blk / 2]`
of 17408 rows of two blocks (interleaved), or 20 blocks per row. -/
def dbase (K : Nat) (il : Bool) (r blk : Nat) : Nat :=
  if il then blk / 2 * 17408 * 2 * wpb K + blk % 2 * wpb K + r * roww K il else blk * wpb K + r * roww K il

/-- The code of row `r` (input feature) and column `col` (output feature): the codebook entry of the column's
12-bit trellis state in block `col / 256` of the row. -/
def code (K : Nat) (il : Bool) (Codes : ByteMemory.Bytes) (r col : Nat) : Float32 :=
  codebook C (trellisCode K Codes (dbase K il r (col / 256)) (col % 256))

/-- Split `split`'s accumulator of column `col` after its first `n` rows `136·split + m`:
`acc = fma(code * scale, x, acc)`. -/
def accSplit (K : Nat) (il : Bool) (Codes S X : ByteMemory.Bytes) (split col : Nat) : Nat → Float32
  | 0 => zero
  | n + 1 => C.fma (C.fmul (code C K il Codes (136 * split + n) col) (scale S (136 * split + n)))
      (xr C X (136 * split + n)) (accSplit K il Codes S X split col n)

/-- `partial[y][col]`: the column's four splits `y + 32·k` after their 136 rows, summed from `k = 0` as
`t = sums[…] + t`. -/
def partialVal (K : Nat) (il : Bool) (Codes S X : ByteMemory.Bytes) (y col : Nat) : Float32 :=
  C.fadd (accSplit C K il Codes S X (y + 96) col 136) (C.fadd (accSplit C K il Codes S X (y + 64) col 136)
    (C.fadd (accSplit C K il Codes S X (y + 32) col 136) (C.fadd (accSplit C K il Codes S X y col 136) zero)))

/-- Byte `b` of `partial` [1, 32, 5120] f32. -/
def expected (K : Nat) (il : Bool) (X Codes S : ByteMemory.Bytes) (b : Nat) : BitVec 8 :=
  if b < 655360 then (wordBytes 4 (Val.f32Bits (partialVal C K il Codes S X (b / 4 / 5120) (b / 4 % 5120)))).getD (b % 4) 0
  else 0

end Spec

/-! ## The launch -/

/-- The route's down geometries: 2- and 4-bit codes aligned and row-major, 3-bit shifted and interleaved. -/
def Geo (K : Nat) (sf il : Bool) : Prop :=
  (K = 2 ∧ sf = false ∧ il = false) ∨ (K = 4 ∧ sf = false ∧ il = false) ∨ (K = 3 ∧ sf = true ∧ il = true)

/-- Bytes of `K`-bit codes: `uint32 [17408, 160·K]`, or `[10, 17408, 48]` at `K = 3`. -/
def codesBytes (k : Nat) : Nat := 17408 * 640 * k

/-- The inputs: x (gate-up's output), the codes and scales, and their base alignments. -/
structure In where
  X : ByteMemory.Bytes
  Cd : ByteMemory.Bytes
  S : ByteMemory.Bytes
  ax : Nat
  ac : Nat
  as : Nat

def bufs (k : Nat) (I : In) : List Buffer :=
  [⟨.device, 34816, I.ax, I.X⟩, ⟨.device, codesBytes k, I.ac, I.Cd⟩, ⟨.device, 34816, I.as, I.S⟩]

/-- MLX's launch at `downConfig`: grid [256, 160], threadgroup [256], `partial` [1, 32, 5120] f32. -/
def launch (k : Nat) (sf il : Bool) (I : In) (initial : Nat → ByteMemory.Bytes) : Launch :=
  ⟨core k sf il, (256, 160, 1), (256, 1, 1), buffers (bufs k I) [655360] 16 initial⟩

/-! ### Who writes what -/

/-- Threadgroup `g`'s SIMD-group `sg`'s split and column group, its lane's block and position in it. -/
def splitOf (g sg : Nat) : Nat := g % 32 + 32 * (sg % 4)
def colGroupOf (g sg : Nat) : Nat := 2 * (g / 32) + sg / 4
def blkOf (g sg lane : Nat) : Nat := colGroupOf g sg * 2 + lane / 16
/-- Column of a lane's `acc[i]`: `blk·256 + 255 - (16·li + i)`. -/
def colOf (g sg lane i : Nat) : Nat := blkOf g sg lane * 256 + 255 - (16 * (lane % 16) + i)

/-- The sums element thread `32·sg + lane` writes for `acc[i]`, and the thread that writes sums element `e`. -/
def sumsIdx (sg lane i : Nat) : Nat := sg * 512 + (lane / 16 * 256 + 255 - lane % 16 * 16) - i
def sumsOwner (e : Nat) : Nat := 32 * (e / 512) + 16 * (e % 512 / 256) + (255 - e % 256) / 16

/-- `partial` element `E = y·5120 + col`: threadgroup `32·(col / 1024) + y`, thread `col % 256`. -/
def outGroup (E : Nat) : Nat := 32 * (E % 5120 / 1024) + E / 5120
def outThread (E : Nat) : Nat := E % 5120 % 256

/-- The writer of each device byte: `partial` elements by their thread, in device epoch 0. -/
def dev (region byte : Nat) : Option Writer :=
  if region = 3 then some ⟨outGroup (byte / 4) * 256 + outThread (byte / 4), outGroup (byte / 4), 0⟩ else none

/-- The owner of each threadgroup byte: in threadgroup `g`'s first epoch (`3·g`) codebook entry `e` is thread
`e % 256`'s, in its third (`3·g + 2`) sums element `e` is `sumsOwner e`'s; in the others nothing is written. -/
def tgo (g e region byte : Nat) : Option Nat :=
  if region = 4 then
    (if e = 3 * g then some (g * 256 + byte / 4 % 256) else if e = 3 * g + 2 then some (g * 256 + sumsOwner (byte / 4))
      else none)
  else none

/-- The regions as the kernel uses them. -/
structure Shape (L : Launch) (k : Nat) (sf : Bool) (I : In) : Prop where
  r0 : L.regions 0 = some ⟨.device, 34816, I.ax⟩
  r1 : L.regions 1 = some ⟨.device, codesBytes k, I.ac⟩
  r2 : L.regions 2 = some ⟨.device, 34816, I.as⟩
  r3 : L.regions 3 = some ⟨.device, 655360, 16⟩
  r4 : L.regions 4 = some ⟨.threadgroup, 16384, 4⟩
  ridx : ∀ th, L.regions (5 + th * 10) = some ⟨.thread, 4 * nl k sf, 4⟩
  racc : ∀ th, L.regions (5 + th * 10 + 1) = some ⟨.thread, 64, 4⟩
  rld : ∀ th, L.regions (5 + th * 10 + 2) = some ⟨.thread, 4 * (2 * nl k sf), 4⟩
  rxr : ∀ th, L.regions (5 + th * 10 + 3) = some ⟨.thread, 8, 4⟩
  rsr : ∀ th, L.regions (5 + th * 10 + 4) = some ⟨.thread, 8, 4⟩
  rw : ∀ th, L.regions (5 + th * 10 + 5) = some ⟨.thread, 4 * na k, 4⟩
  rv : ∀ th, L.regions (5 + th * 10 + 6) = some ⟨.thread, 4 * na k, 4⟩
  ax : I.ax % 2 = 0
  ac : I.ac % 4 = 0
  as : I.as % 2 = 0

theorem launch_shape {k : Nat} {sf il : Bool} {I : In} {initial : Nat → ByteMemory.Bytes}
    (hax : I.ax % 2 = 0) (hac : I.ac % 4 = 0) (has : I.as % 2 = 0) : Shape (launch k sf il I initial) k sf I := by
  have hb : (launch k sf il I initial).buffers = buffers (bufs k I) [655360] 16 initial := rfl
  have ht : ∀ th j t n, (launch k sf il I initial).kernel.threadArrays[j]? = some (t, n) →
      (launch k sf il I initial).regions (5 + th * 10 + j) = some ⟨.thread, t.bytes * n, alignment t⟩ :=
    fun th j t n h => Launch.regions_threadArray _ th j t n h
  refine ⟨regions_input hb 0 (by simp [bufs]), regions_input hb 1 (by simp [bufs]), regions_input hb 2 (by simp [bufs]),
    regions_output hb 0 (by simp), Launch.regions_groupArray _ 0 (.scalar .f32) 4096 rfl, fun th => ?_, fun th => ?_,
    fun th => ?_, fun th => ?_, fun th => ?_, fun th => ?_, fun th => ?_, hax, hac, has⟩
  · have := ht th 0 (.scalar .u32) (nl k sf) rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 1 (.scalar .f32) 16 rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 2 (.scalar .u32) (2 * nl k sf) rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 3 (.scalar .f32) 2 rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 4 (.scalar .f32) 2 rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 5 (.scalar .u32) (na k) rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 6 (.scalar .u32) (na k) rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this

/-! ## Memory -/

section Memory
variable (C : M1Max.Contract)

/-- Memory during the launch: inputs intact, the epochs, codebook entries `cbOk` or sums elements `sumsOk` (values
`sumsV`) in the threadgroup array, the threads `accOk`'s accumulators (`accV`), the `partial` elements `outOk`
(values `outV`), and every access so far keeping the ownership discipline. -/
structure Mem (L : Launch) (I : In) (accV : Nat → Nat → Float32) (sumsV outV : Nat → Float32) (ge : Nat)
    (cbOk sumsOk accOk outOk : Nat → Prop) (sh : Shared) : Prop where
  regions : sh.regions = L.regions
  x : sh.bytes 0 = I.X
  cd : sh.bytes 1 = I.Cd
  sc : sh.bytes 2 = I.S
  deve : sh.deviceEpoch = 0
  grpe : sh.groupEpoch = ge
  cb : ∀ e < 4096, cbOk e → cells (sh.bytes 4) (4 * e) 4 = wordBytes 4 (Val.f32Bits (codebook C e))
  sums : ∀ e < 4096, sumsOk e → cells (sh.bytes 4) (4 * e) 4 = wordBytes 4 (Val.f32Bits (sumsV e))
  acc : ∀ th, accOk th → ∀ i < 16, cells (sh.bytes (5 + th * 10 + 1)) (4 * i) 4 = wordBytes 4 (Val.f32Bits (accV th i))
  out : ∀ E < 163840, outOk E → cells (sh.bytes 3) (4 * E) 4 = wordBytes 4 (Val.f32Bits (outV E))
  log : ∀ a ∈ sh.log, Owned L dev tgo a

variable {C} {L : Launch} {k : Nat} {sf : Bool} {I : In} {accV : Nat → Nat → Float32} {sumsV outV : Nat → Float32}
  {ge : Nat} {cbOk sumsOk accOk outOk : Nat → Prop} {sh : Shared}

theorem Mem.mono (h : Mem C L I accV sumsV outV ge cbOk sumsOk accOk outOk sh) {cbOk' sumsOk' accOk' outOk' : Nat → Prop}
    (hc : ∀ e < 4096, cbOk' e → cbOk e) (hs : ∀ e < 4096, sumsOk' e → sumsOk e) (ha : ∀ th, accOk' th → accOk th)
    (ho : ∀ E < 163840, outOk' E → outOk E) : Mem C L I accV sumsV outV ge cbOk' sumsOk' accOk' outOk' sh :=
  ⟨h.regions, h.x, h.cd, h.sc, h.deve, h.grpe, fun e he h' => h.cb e he (hc e he h'),
    fun e he h' => h.sums e he (hs e he h'), fun th h' => h.acc th (ha th h'), fun E hE h' => h.out E hE (ho E hE h'), h.log⟩

/-- A read of an input, or of threadgroup memory in an epoch its threadgroup does not write it. -/
theorem Mem.rd (h : Mem C L I accV sumsV outV ge cbOk sumsOk accOk outOk sh) (hS : Shape L k sf I) (ctx : Ctx)
    (reg o n : Nat) (hreg : reg < 3 ∨ (reg = 4 ∧ ge ≠ 3 * ctx.group ∧ ge ≠ 3 * ctx.group + 2)) :
    Mem C L I accV sumsV outV ge cbOk sumsOk accOk outOk (rdn ctx sh reg o n) :=
  ⟨h.regions, h.x, h.cd, h.sc, h.deve, h.grpe, h.cb, h.sums, h.acc, h.out, forall_log _ n _ (fun j _ => by
    rcases hreg with hreg | ⟨rfl, h1, h2⟩
    · obtain ⟨r, hr, hs⟩ : ∃ r, L.regions reg = some r ∧ r.space ≠ .threadgroup := by
        rcases (show reg = 0 ∨ reg = 1 ∨ reg = 2 by omega) with rfl | rfl | rfl
        exacts [⟨_, hS.r0, by simp⟩, ⟨_, hS.r1, by simp⟩, ⟨_, hS.r2, by simp⟩]
      exact owned_device_read L dev tgo ctx sh reg (o + j) r hr hs (by simp [dev]; omega)
    · exact owned_group_read L dev tgo ctx sh 4 (o + j) _ hS.r4 rfl (by simp [tgo, h.grpe, h1, h2])) h.log⟩

/-- A write to thread memory other than the accumulators of the threads `accOk`. -/
theorem Mem.tput (h : Mem C L I accV sumsV outV ge cbOk sumsOk accOk outOk sh) {reg : Nat} (o : Nat)
    (bs : List (BitVec 8)) (hreg : 5 ≤ reg) (hacc : ∀ th, accOk th → reg ≠ 5 + th * 10 + 1) :
    Mem C L I accV sumsV outV ge cbOk sumsOk accOk outOk (tput sh reg o bs) :=
  ⟨h.regions, by rw [tput_other _ _ _ (by omega)]; exact h.x, by rw [tput_other _ _ _ (by omega)]; exact h.cd,
    by rw [tput_other _ _ _ (by omega)]; exact h.sc, h.deve, h.grpe,
    fun e he hc => by rw [tput_other _ _ _ (by omega)]; exact h.cb e he hc,
    fun e he hc => by rw [tput_other _ _ _ (by omega)]; exact h.sums e he hc,
    fun th hth i hi => by rw [tput_other _ _ _ (hacc th hth).symm]; exact h.acc th hth i hi,
    fun E hE hc => by rw [tput_other _ _ _ (by omega)]; exact h.out E hE hc, h.log⟩

/-- Thread `e % 256` of threadgroup `g` writes `codebook[e]` in its first epoch. -/
theorem Mem.wcb (h : Mem C L I accV sumsV outV (3 * g) cbOk sumsOk accOk outOk sh) (hS : Shape L k sf I) (ctx : Ctx)
    (e : Nat) (he : e < 4096) (ht : ctx.thread = g * 256 + e % 256) (hg : ctx.group = g) :
    Mem C L I accV sumsV outV (3 * g) (fun e' => cbOk e' ∨ e' = e) (fun _ => False) accOk outOk
      (wrn ctx sh 4 (4 * e) 4 (wordBytes 4 (Val.f32Bits (codebook C e)))) := by
  have hl : (wordBytes 4 (Val.f32Bits (codebook C e))).length = 4 := wordBytes_length 4 _
  refine ⟨h.regions, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.x, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.cd,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.sc, h.deve, h.grpe, fun e' he' hc => ?_, fun _ _ hf => hf.elim,
    fun th hth i hi => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.acc th hth i hi,
    fun E hE hc => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.out E hE hc,
    forall_log _ 4 _ (fun j hj => owned_group L dev tgo ctx sh 4 (4 * e + j) _ hS.r4 true rfl
      (by simp only [tgo, h.grpe, hg, ite_true]; rw [ht]; congr 2; omega)) h.log⟩
  rw [wrn_same]
  by_cases hee : e' = e
  · subst hee
    have := cells_writeBytes_same (sh.bytes 4) (4 * e') (wordBytes 4 (Val.f32Bits (codebook C e')))
    rwa [hl] at this
  · rw [cells_writeBytes_other _ _ _ _ _ (by rw [hl]; omega)]
    exact h.cb e' he' (hc.resolve_right hee)

/-- The barrier (threadgroup memory only). -/
theorem Mem.pass (h : Mem C L I accV sumsV outV ge cbOk sumsOk accOk outOk sh) :
    Mem C L I accV sumsV outV (ge + 1) cbOk sumsOk accOk outOk (pass false true sh) :=
  ⟨h.regions, h.x, h.cd, h.sc, by simp [Metal.pass, h.deve], by simp [Metal.pass, h.grpe], h.cb, h.sums, h.acc, h.out,
    h.log⟩

/-- A threadgroup starts: its threadgroup array holds garbage. -/
theorem Mem.reset (h : Mem C L I accV sumsV outV ge cbOk sumsOk accOk outOk sh) (hb : L.buffers.length = 4)
    (hga : L.groupArrays = 1) (garbage : Garbage) (g : Nat) :
    Mem C L I accV sumsV outV ge (fun _ => False) (fun _ => False) accOk outOk
      { sh with bytes := L.resetGroup garbage g sh.bytes } :=
  ⟨h.regions, by show L.resetGroup garbage g sh.bytes 0 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.x,
    by show L.resetGroup garbage g sh.bytes 1 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.cd,
    by show L.resetGroup garbage g sh.bytes 2 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.sc,
    h.deve, h.grpe, fun _ _ hf => hf.elim, fun _ _ hf => hf.elim,
    fun th hth i hi => by
      show cells (L.resetGroup garbage g sh.bytes (5 + th * 10 + 1)) (4 * i) 4 = _
      unfold Launch.resetGroup
      rw [ite_eq_right (by intro hc; omega)]; exact h.acc th hth i hi,
    fun E hE hc => by
      show cells (L.resetGroup garbage g sh.bytes 3) (4 * E) 4 = _
      rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.out E hE hc, h.log⟩

end Memory

/-! ## A thread -/

/-- Lane `i` of SIMD-group `s` of threadgroup `g`. -/
structure Lane (ctx : Ctx) (g s i : Nat) : Prop where
  tpos : ctx.coord .threadPositionInThreadgroup = u32x3 (32 * s + i) 0 0
  gpos : ctx.coord .threadgroupPositionInGrid = u32x3 0 g 0
  lane : ctx.coord .threadIndexInSimdgroup = u32 i
  sg : ctx.coord .simdgroupIndexInThreadgroup = u32 s
  thread : ctx.thread = g * 256 + (32 * s + i)
  group : ctx.group = g
  ga0 : ctx.groupArray 0 = 4
  ta : ∀ j, ctx.threadArray j = 5 + (g * 256 + (32 * s + i)) * 10 + j
  hg : g < 160
  hs : s < 8
  hi : i < 32

theorem launch_tiles {k : Nat} {sf il : Bool} {I : In} {initial : Nat → ByteMemory.Bytes} :
    (launch k sf il I initial).Tiles 256 1 1 1 160 1 8 := ⟨rfl, rfl, rfl, by decide⟩

theorem lane_of {k : Nat} {sf il : Bool} {I : In} {initial : Nat → ByteMemory.Bytes} (fuse : Nat → Bool) {g : Nat}
    (hg : g < 160) (s : Fin 8) (i : Fin 32) :
    Lane ((launch k sf il I initial).ctxAt fuse 0 g 0 (32 * s + i)) g s i := by
  have hs := s.isLt; have hi := i.isLt
  refine ⟨?_, Launch.ctxAt_threadgroupPositionInGrid _ _ _ _ _ _, Launch.ctxAt_lane _ _ _ _ _ _ _,
    Launch.ctxAt_simd _ _ _ _ _ _ _, ?_, ?_, rfl, fun j => ?_, hg, hs, hi⟩
  · rw [launch_tiles.threadPositionInThreadgroup, show (32 * s.val + i.val) % 256 = 32 * s + i by omega,
      show (32 * s.val + i.val) / 256 % 1 = 0 by omega, show (32 * s.val + i.val) / (256 * 1) = 0 by omega]
  · rw [launch_tiles.thread]; omega
  · rw [launch_tiles.group_id]; omega
  · rw [launch_tiles.threadArray, show (launch k sf il I initial).buffers.length = 4 from rfl,
      show (launch k sf il I initial).groupArrays = 1 from rfl, show (launch k sf il I initial).threadArrays = 10 from rfl]
    omega

/-- The buffer and threadgroup-array pointers. -/
structure Fix1 (l : Locals) : Prop where
  l0 : l 0 = some (.ptr ⟨0, 0, .scalar .bf16⟩)
  l1 : l 1 = some (.ptr ⟨1, 0, .scalar .u32⟩)
  l2 : l 2 = some (.ptr ⟨2, 0, .scalar .f16⟩)
  l3 : l 3 = some (.ptr ⟨3, 0, .scalar .f32⟩)
  l4 : l 4 = some (.ptr ⟨4, 0, .scalar .f32⟩)

theorem Fix1.of_eq {l l' : Locals} (h : Fix1 l) (h' : ∀ j, j ≤ 4 → l' j = l j) : Fix1 l' :=
  ⟨(h' 0 (by omega)).trans h.l0, (h' 1 (by omega)).trans h.l1, (h' 2 (by omega)).trans h.l2,
    (h' 3 (by omega)).trans h.l3, (h' 4 (by omega)).trans h.l4⟩

/-! ### Before the first barrier: the codebook -/

section Phase1
variable (C : M1Max.Contract) {L : Launch} {k : Nat} {sf il : Bool} {I : In} {accV : Nat → Nat → Float32}
  {sumsV outV : Nat → Float32} {accOk outOk : Nat → Prop} {g s i : Nat} {ctx : Ctx}

/-- The code after the first barrier. -/
def rest1 (k : Nat) (sf il : Bool) : List CStmt := (body k sf il).drop 8

theorem body_split (k : Nat) (sf il : Bool) : body k sf il =
    ((body k sf il).take 5 ++ [.set 5 (.component (.coord .threadPositionInThreadgroup) (u32l 0)), fillLoop]) ++
      .barrier 1 false true :: rest1 k sf il := rfl

theorem fillBody_eq : fillBody = .set 6 (.local 5) :: ([trellisYAt 6, .set (6 + 4) (.local (6 + 1)), unrefinedYAt (6 + 4)] ++
    [.store (.scalar .f32) (.offset (.local 4) (.local 5)) (.local 11)]) := rfl

/-- At the `k`-th test of the codebook loop of thread `t`. -/
def FillI (L : Launch) (I : In) (accV : Nat → Nat → Float32) (sumsV outV : Nat → Float32) (accOk outOk : Nat → Prop)
    (g t : Nat) (n : Nat) (l : Locals) (sh : Shared) : Prop :=
  Fix1 l ∧ l 5 = some (u32 (t + 256 * n)) ∧
    Mem C L I accV sumsV outV (3 * g) (fun e => e % 256 < t ∨ (e % 256 = t ∧ e / 256 < n)) (fun _ => False) accOk outOk sh

theorem fill_loop (hS : Shape L k sf I) (hl : Lane ctx g s i) {l : Locals} {sh : Shared}
    (h0 : FillI C L I accV sumsV outV accOk outOk g (32 * s + i) 0 l sh) :
    ∃ l' sh', Exec C ctx [fillLoop] l sh .normal l' sh' ∧
      FillI C L I accV sumsV outV accOk outOk g (32 * s + i) 16 l' sh' := by
  have hs := hl.hs; have hi := hl.hi
  refine Exec.loop_count 16 (FillI C L I accV sumsV outV accOk outOk g (32 * s + i))
    (FillI C L I accV sumsV outV accOk outOk g (32 * s + i)) (fun n hn l sh hI => ⟨sh, ?_, hI⟩) (fun n hn l sh hI => ?_) h0
  · have h := eval_lt_u32 C (ctx := ctx) (sh := sh) (b := 4096) hI.2.1 (by omega) (by decide)
    rwa [show decide (32 * s + i + 256 * n < 4096) = decide (n < 16) from decide_eq_decide.mpr (by omega)] at h
  · obtain ⟨hF, h5, hm⟩ := hI
    have he : 32 * s + i + 256 * n < 4096 := by omega
    obtain ⟨l₂, hcb, h11, hag⟩ := exec_codebook C (ctx := ctx) 6 (l := setLocal l 6 (u32 (32 * s + i + 256 * n)))
      (sh := sh) (s := 32 * s + i + 256 * n) (setLocal_same _ _ _)
    have h4 : l₂ 4 = some (.ptr ⟨4, 0, .scalar .f32⟩) := by rw [hag 4 (by omega), setLocal_other _ _ (by omega)]; exact hF.l4
    have h5' : l₂ 5 = some (u32 (32 * s + i + 256 * n)) := by rw [hag 5 (by omega), setLocal_other _ _ (by omega)]; exact h5
    have hp := eval_ptr_u32 C (ctx := ctx) (eval_local' C h4 sh) (eval_local' C h5' sh) (by omega)
    rw [show (32 * s + i + 256 * n) * (Ty.scalar .f32).bytes = 4 * (32 * s + i + 256 * n) by
      simp [Ty.bytes, Scalar.bytes]; ring] at hp
    have hst := store_shared ctx .f32 sh 4 (4 * (32 * s + i + 256 * n)) _ _ _ (by rw [hm.regions]; exact hS.r4)
      (by simp) (by simp) (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega)
      (encode_f32 (codebook C (32 * s + i + 256 * n)))
    have hm' := hm.wcb hS ctx (32 * s + i + 256 * n) he (by rw [hl.thread]; omega) hl.group
    rw [show Scalar.f32.bytes = 4 from rfl] at hst
    generalize wrn ctx sh 4 (4 * (32 * s + i + 256 * n)) 4
      (wordBytes 4 (Val.f32Bits (codebook C (32 * s + i + 256 * n)))) = sh₁ at hst hm'
    refine ⟨.normal, l₂, sh₁, setLocal l₂ 5 (u32 (32 * s + i + 256 * n + 256)), sh₁, .inl rfl, ?_,
      .set (eval_bin_u32 C (eval_local' C h5' _) (eval_u32lit C _ _ 256 (by decide)) (binary_add_u32 C _ 256)) (.nil _ _),
      ⟨?_, by rw [setLocal_same, show 32 * s + i + 256 * n + 256 = 32 * s + i + 256 * (n + 1) by ring], ?_⟩⟩
    · rw [fillBody_eq]
      exact .set (eval_local' C h5 sh) (hcb.append (.store hp (eval_local' C h11 sh) hst (.nil _ _)))
    · exact hF.of_eq fun j hj => by rw [setLocal_other _ _ (by omega), hag j (by omega), setLocal_other _ _ (by omega)]
    · refine hm'.mono (cbOk' := fun e => e % 256 < 32 * s + i ∨ (e % 256 = 32 * s + i ∧ e / 256 < n + 1))
        (fun e _ h => ?_) (fun _ _ h => h) (fun _ h => h) (fun _ _ h => h)
      rcases h with h | ⟨h1, h2⟩
      · exact .inl (.inl h)
      · by_cases hn' : e / 256 < n
        · exact .inl (.inr ⟨h1, hn'⟩)
        · exact .inr (by omega)

/-- A lane runs the codebook loop to the first barrier. -/
theorem lane_phase1 (hS : Shape L k sf I) (hl : Lane ctx g s i) {sh : Shared}
    (hm : Mem C L I accV sumsV outV (3 * g) (fun e => e % 256 < 32 * s + i) (fun _ => False) accOk outOk sh) :
    ∃ t sh', (Ev fun m => (runThread C m ⟨ctx, fun _ => none, [.block (body k sf il)], .running⟩).run sh =
        some (t, sh')) ∧
      Mem C L I accV sumsV outV (3 * g) (fun e => e % 256 < 32 * s + i + 1) (fun _ => False) accOk outOk sh' ∧
      t.status = .barrier 1 false true ∧ t.ctx = ctx ∧ t.frames = [.block (rest1 k sf il)] ∧ Fix1 t.locals := by
  have hs := hl.hs; have hi := hl.hi
  have hpre : Exec C ctx ((body k sf il).take 5) (fun _ => none) sh .normal
      (setLocal (setLocal (setLocal (setLocal (setLocal (fun _ => none) 0 (.ptr ⟨0, 0, .scalar .bf16⟩)) 1
        (.ptr ⟨1, 0, .scalar .u32⟩)) 2 (.ptr ⟨2, 0, .scalar .f16⟩)) 3 (.ptr ⟨3, 0, .scalar .f32⟩)) 4
        (.ptr ⟨ctx.groupArray 0, 0, .scalar .f32⟩)) sh :=
    .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <|
      .array (.nil _ _)
  generalize hl₀ : setLocal (setLocal (setLocal (setLocal (setLocal (fun _ => none) 0 (.ptr ⟨0, 0, .scalar .bf16⟩)) 1
    (.ptr ⟨1, 0, .scalar .u32⟩)) 2 (.ptr ⟨2, 0, .scalar .f16⟩)) 3 (.ptr ⟨3, 0, .scalar .f32⟩)) 4
    (.ptr ⟨ctx.groupArray 0, 0, .scalar .f32⟩) = l₀ at hpre
  have hF₀ : Fix1 l₀ := by
    rw [← hl₀]; exact ⟨by simp [setLocal], by simp [setLocal], by simp [setLocal], by simp [setLocal], by simp [setLocal, hl.ga0]⟩
  obtain ⟨l₁, sh₁, hfill, hF₁, -, hm₁⟩ := fill_loop C hS hl (l := setLocal l₀ 5 (u32 (32 * s + i))) (sh := sh)
    ⟨hF₀.of_eq fun j hj => setLocal_other _ _ (by omega), by rw [setLocal_same, Nat.mul_zero, Nat.add_zero],
      hm.mono (fun e _ h => by rcases h with h | ⟨-, h⟩ <;> omega) (fun _ _ h => h) (fun _ h => h) (fun _ _ h => h)⟩
  have hex : Exec C ctx ((body k sf il).take 5 ++ [.set 5 (.component (.coord .threadPositionInThreadgroup) (u32l 0)),
      fillLoop]) (fun _ => none) sh .normal l₁ sh₁ :=
    hpre.append (.set (eval_coord0 C hl.tpos) hfill)
  refine ⟨⟨ctx, l₁, [.block (rest1 k sf il)], .barrier 1 false true⟩, sh₁, ?_,
    hm₁.mono (fun e he h => ?_) (fun _ _ h => h) (fun _ h => h) (fun _ _ h => h), rfl, rfl, rfl, hF₁⟩
  · rw [body_split]
    exact (Exec.reaches_barrier (K := []) (rest := rest1 k sf il) (site := 1) (d := false) (g := true) hex).ev_stop rfl
  · by_cases h' : e % 256 < 32 * s + i
    · exact .inl h'
    · exact .inr ⟨by omega, by omega⟩

end Phase1

/-! ### After the first barrier: a lane's geometry -/

/-- `first`, `shifted` and `blockWords`' offset of a lane. -/
def firstOf (K li : Nat) : Nat := li * (16 * K) / 2 ^ 5
def shiftedOf (sf : Bool) (li : Nat) : Bool := sf && decide (li % 2 ≠ 0)
def blockOff (K : Nat) (il : Bool) (blk : Nat) : Nat :=
  if il then blk / 2 * 17408 * 2 * wpb K + blk % 2 * wpb K else blk * wpb K

theorem dbase_eq (K : Nat) (il : Bool) (r blk : Nat) : dbase K il r blk = blockOff K il blk + r * roww K il := by
  unfold dbase blockOff; split <;> rfl

/-- The lane's geometry after the declarations before `idx`. -/
structure Geom (K : Nat) (sf il : Bool) (g s i : Nat) (l : Locals) : Prop where
  fix1 : Fix1 l
  l13 : l 13 = some (u32 i)
  l14 : l 14 = some (u32 s)
  l15 : l 15 = some (u32 g)
  l16 : l 16 = some (u32 (g % 32))
  l17 : l 17 = some (u32 (splitOf g s))
  l18 : l 18 = some (u32 (colGroupOf g s))
  l19 : l 19 = some (u32 (i % 16))
  l20 : l 20 = some (u32 (blkOf g s i))
  l21 : l 21 = some (.bool true)
  l22 : l 22 = some (.ptr ⟨1, ((blockOff K il (blkOf g s i) * 4 : Nat) : Int), .scalar .u32⟩)
  l23 : l 23 = some (u32 (firstOf K (i % 16)))
  l24 : l 24 = some (.bool (shiftedOf sf (i % 16)))

theorem Geom.of_eq {K : Nat} {sf il : Bool} {g s i : Nat} {l l' : Locals} (h : Geom K sf il g s i l)
    (h' : ∀ j, j ≤ 24 → l' j = l j) : Geom K sf il g s i l' :=
  ⟨h.fix1.of_eq fun j hj => h' j (by omega), (h' 13 (by omega)).trans h.l13, (h' 14 (by omega)).trans h.l14,
    (h' 15 (by omega)).trans h.l15, (h' 16 (by omega)).trans h.l16, (h' 17 (by omega)).trans h.l17,
    (h' 18 (by omega)).trans h.l18, (h' 19 (by omega)).trans h.l19, (h' 20 (by omega)).trans h.l20,
    (h' 21 (by omega)).trans h.l21, (h' 22 (by omega)).trans h.l22, (h' 23 (by omega)).trans h.l23,
    (h' 24 (by omega)).trans h.l24⟩

section Setup
variable (C : M1Max.Contract) {ctx : Ctx} {g s i : Nat}

theorem geo_bounds {K : Nat} {sf il : Bool} (hG : Geo K sf il) : 2 ≤ K ∧ K ≤ 4 ∧ wpb K = 8 * K := by
  unfold wpb; rcases hG with ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ <;> omega

/-- `blockWords`' offset. -/
theorem eval_blockOffset {K : Nat} {sf il : Bool} (hG : Geo K sf il) (hl : Lane ctx g s i) {l : Locals} {sh : Shared}
    (h20 : l 20 = some (u32 (blkOf g s i))) :
    (eval C ctx l (blockOffset K il)).run sh = some (u64 (blockOff K il (blkOf g s i)), sh) := by
  have hb := geo_bounds hG
  have hblk : blkOf g s i < 20 := by have := hl.hg; have := hl.hs; have := hl.hi; unfold blkOf colGroupOf; omega
  unfold blockOffset blockOff
  cases il with
  | true =>
    simp only [ite_true]
    refine eval_int C (by decide) (eval_int C (by decide) (eval_int C (by decide) (eval_int C (by decide)
      (eval_conv C (t := .u64) (eval_bin_u32 C (eval_local' C h20 sh) (eval_u32lit C _ _ 2 (by decide))
        (binary_div_u32 C _ 2 (by omega) (by decide) (by decide))) (convert_u64_u32 C _ (by omega)))
      (eval_u64lit C _ _ 17408 (by decide)) (binary_mul_u64 C _ _)) (eval_u64lit C _ _ 2 (by decide))
      (binary_mul_u64 C _ _)) (eval_u64lit C _ _ (wpb K) (by omega)) (binary_mul_u64 C _ _))
      (eval_conv C (t := .u64) (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h20 sh) (eval_u32lit C _ _ 2 (by decide))
        (binary_rem_u32 C _ 2 (by omega) (by decide) (by decide))) (eval_u32lit C _ _ (wpb K) (by omega))
        (binary_mul_u32 C _ _)) (convert_u64_u32 C _ ?_)) ?_
    · have := Nat.mod_lt (blkOf g s i) (show 0 < 2 by decide); rw [hb.2.2]; nlinarith
    · exact binary_add_u64 C _ _
  | false =>
    simp only [Bool.false_eq_true, ite_false]
    exact eval_int C (by decide) (eval_conv C (t := .u64) (eval_local' C h20 sh) (convert_u64_u32 C _ (by omega)))
      (eval_u64lit C _ _ (wpb K) (by omega)) (binary_mul_u64 C _ _)

/-- `lane`, `sg`, `ty`, `y`, `split`, `colGroup`, `li`, `blk`, `active`, `blockWords`, `first`, `shifted`. -/
theorem lane_geom {K : Nat} {sf il : Bool} (hG : Geo K sf il) (hl : Lane ctx g s i) {l : Locals} {sh : Shared}
    (hF : Fix1 l) :
    ∃ l', Exec C ctx ((rest1 K sf il).take 12) l sh .normal l' sh ∧ Geom K sf il g s i l' := by
  have hg := hl.hg; have hs := hl.hs; have hi := hl.hi
  have hb := geo_bounds hG
  -- 13 … 16
  generalize hl₁ : setLocal (setLocal (setLocal (setLocal l 13 (u32 i)) 14 (u32 s)) 15 (u32 g)) 16 (u32 (g % 32)) = l₁
  have x1 : Exec C ctx [.set 13 (.coord .threadIndexInSimdgroup), .set 14 (.coord .simdgroupIndexInThreadgroup),
      .set 15 (.component (.coord .threadgroupPositionInGrid) (u32l 1)),
      .set 16 (.bin .rem .u32 0 (.local 15) (u32l 32))] l sh .normal l₁ sh := by
    rw [← hl₁]
    exact .set (by rw [eval_coord, hl.lane]) <| .set (by rw [eval_coord, hl.sg]) <| .set (eval_coord1 C hl.gpos) <|
      .set (eval_bin_u32 C (eval_local' C (setLocal_same _ _ _) sh) (eval_u32lit C _ _ 32 (by decide))
        (binary_rem_u32 C g 32 (by omega) (by decide) (by decide))) (.nil _ _)
  have h13 : l₁ 13 = some (u32 i) := by rw [← hl₁]; simp [setLocal]
  have h14 : l₁ 14 = some (u32 s) := by rw [← hl₁]; simp [setLocal]
  have h15 : l₁ 15 = some (u32 g) := by rw [← hl₁]; simp [setLocal]
  have h16 : l₁ 16 = some (u32 (g % 32)) := by rw [← hl₁]; simp [setLocal]
  have hb₁ : ∀ j, j < 13 → l₁ j = l j := fun j hj => by rw [← hl₁]; simp (disch := omega) only [setLocal_lt]
  -- 17
  have e17 : (eval C ctx l₁ (.bin .add .u32 0 (.local 16) (.bin .mul .u32 0 (u32l 32) (.bin .rem .u32 0 (.local 14)
      (u32l 4))))).run sh = some (u32 (splitOf g s), sh) :=
    eval_bin_u32 C (eval_local' C h16 sh) (eval_bin_u32 C (eval_u32lit C _ _ 32 (by decide)) (eval_bin_u32 C
      (eval_local' C h14 sh) (eval_u32lit C _ _ 4 (by decide)) (binary_rem_u32 C s 4 (by omega) (by decide) (by decide)))
      (binary_mul_u32 C 32 _)) (binary_add_u32 C _ _)
  generalize hl₂ : setLocal l₁ 17 (u32 (splitOf g s)) = l₂
  have hb₂ : ∀ j, j < 17 → l₂ j = l₁ j := fun j hj => by rw [← hl₂, setLocal_other _ _ (by omega)]
  -- 18
  have e18 : (eval C ctx l₂ (.bin .add .u32 0 groupBase (.bin .div .u32 0 (.local 14) (u32l 4)))).run sh =
      some (u32 (colGroupOf g s), sh) :=
    eval_bin_u32 C (eval_bin_u32 C (eval_u32lit C _ _ 2 (by decide)) (eval_bin_u32 C
      (eval_local' C (by rw [hb₂ 15 (by omega)]; exact h15) sh)
      (eval_u32lit C _ _ 32 (by decide)) (binary_div_u32 C g 32 (by omega) (by decide) (by decide))) (binary_mul_u32 C 2 _))
      (eval_bin_u32 C (eval_local' C (by rw [hb₂ 14 (by omega)]; exact h14) sh) (eval_u32lit C _ _ 4 (by decide))
        (binary_div_u32 C s 4 (by omega) (by decide) (by decide))) (binary_add_u32 C _ _)
  generalize hl₃ : setLocal l₂ 18 (u32 (colGroupOf g s)) = l₃
  have hb₃ : ∀ j, j < 17 → l₃ j = l₁ j := fun j hj => by rw [← hl₃, setLocal_other _ _ (by omega), hb₂ j hj]
  -- 19
  have e19 : (eval C ctx l₃ (.bin .rem .u32 0 (.local 13) (u32l 16))).run sh = some (u32 (i % 16), sh) :=
    eval_bin_u32 C (eval_local' C (by rw [hb₃ 13 (by omega)]; exact h13) sh) (eval_u32lit C _ _ 16 (by decide))
      (binary_rem_u32 C i 16 (by omega) (by decide) (by decide))
  generalize hl₄ : setLocal l₃ 19 (u32 (i % 16)) = l₄
  have h18₄ : l₄ 18 = some (u32 (colGroupOf g s)) := by rw [← hl₄, setLocal_other _ _ (by omega), ← hl₃, setLocal_same]
  have hb₄ : ∀ j, j < 17 → l₄ j = l₁ j := fun j hj => by rw [← hl₄, setLocal_other _ _ (by omega), hb₃ j hj]
  -- 20
  have hcg : colGroupOf g s < 10 := by unfold colGroupOf; omega
  have e20 : (eval C ctx l₄ (.bin .add .u32 0 (.bin .mul .u32 0 (.local 18) (u32l 2))
      (.bin .div .u32 0 (.local 13) (u32l 16)))).run sh = some (u32 (blkOf g s i), sh) :=
    eval_bin_u32 C (eval_bin_u32 C (eval_local' C h18₄ sh) (eval_u32lit C _ _ 2 (by decide)) (binary_mul_u32 C _ 2))
      (eval_bin_u32 C (eval_local' C (by rw [hb₄ 13 (by omega)]; exact h13) sh) (eval_u32lit C _ _ 16 (by decide))
        (binary_div_u32 C i 16 (by omega) (by decide) (by decide))) (binary_add_u32 C _ _)
  generalize hl₅ : setLocal l₄ 20 (u32 (blkOf g s i)) = l₅
  have h18₅ : l₅ 18 = some (u32 (colGroupOf g s)) := by rw [← hl₅, setLocal_other _ _ (by omega)]; exact h18₄
  have h20₅ : l₅ 20 = some (u32 (blkOf g s i)) := by rw [← hl₅, setLocal_same]
  have hblk : blkOf g s i < 20 := by unfold blkOf; omega
  -- 21
  have e21 : (eval C ctx l₅ (.and (.bin .lt .u32 0 (.local 18) (u32l 10)) (.bin .lt .u32 0 (.local 20) (u32l 20)))).run sh =
      some (.bool true, sh) := by
    have h1 := eval_lt_u32 C (ctx := ctx) (sh := sh) (b := 10) h18₅ (by omega) (by decide)
    have h2 := eval_lt_u32 C (ctx := ctx) (sh := sh) (b := 20) h20₅ (by omega) (by decide)
    rw [decide_eq_true hcg] at h1; rw [decide_eq_true hblk] at h2
    exact eval_and_true C h1 h2
  generalize hl₆ : setLocal l₅ 21 (.bool true) = l₆
  have hb₆ : ∀ j, j < 21 → l₆ j = l₅ j := fun j hj => by rw [← hl₆, setLocal_other _ _ (by omega)]
  -- 22
  have e22 : (eval C ctx l₆ (.offset (.local 1) (.cond (.un .not .bool (.local 21)) (u64l 0) (blockOffset K il)))).run sh =
      some (.ptr ⟨1, ((blockOff K il (blkOf g s i) * 4 : Nat) : Int), .scalar .u32⟩, sh) := by
    have h1 : l₆ 1 = some (.ptr ⟨1, 0, .scalar .u32⟩) := by
      rw [hb₆ 1 (by omega), ← hl₅, setLocal_other _ _ (by omega), ← hl₄, setLocal_other _ _ (by omega), hb₃ 1 (by omega),
        hb₁ 1 (by omega)]; exact hF.l1
    have hnot : (eval C ctx l₆ (.un .not .bool (.local 21))).run sh = some (.bool false, sh) :=
      eval_un C (eval_local' C (by rw [← hl₆, setLocal_same]) sh) rfl
    have hc : (eval C ctx l₆ (.cond (.un .not .bool (.local 21)) (u64l 0) (blockOffset K il))).run sh =
        some (u64 (blockOff K il (blkOf g s i)), sh) :=
      eval_cond C hnot (eval_blockOffset C hG hl (l := l₆) (by rw [hb₆ 20 (by omega)]; exact h20₅))
    have hlt : blockOff K il (blkOf g s i) < 2 ^ 64 := by
      clear hc h1; rcases hG with ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ <;> unfold blockOff wpb <;> split <;> omega
    have := eval_offset_u64 C (o := 0) (eval_local' C h1 sh) hc hlt
    rwa [show 0 + blockOff K il (blkOf g s i) * (Ty.scalar .u32).bytes = blockOff K il (blkOf g s i) * 4 by
      simp [Ty.bytes, Scalar.bytes]] at this
  generalize hl₇ : setLocal l₆ 22 (.ptr ⟨1, ((blockOff K il (blkOf g s i) * 4 : Nat) : Int), .scalar .u32⟩) = l₇
  have h19₇ : l₇ 19 = some (u32 (i % 16)) := by
    rw [← hl₇, setLocal_other _ _ (by omega), hb₆ 19 (by omega), ← hl₅, setLocal_other _ _ (by omega), ← hl₄, setLocal_same]
  -- 23
  have e23 : (eval C ctx l₇ (.bin .shr .u32 0 (.bin .mul .u32 0 (.local 19) (u32l (16 * K))) (u32l 5))).run sh =
      some (u32 (firstOf K (i % 16)), sh) :=
    eval_bin_u32 C (eval_bin_u32 C (eval_local' C h19₇ sh) (eval_u32lit C _ _ (16 * K) (by omega)) (binary_mul_u32 C _ _))
      (eval_u32lit C _ _ 5 (by decide)) (binary_shr_u32 C _ 5 (by rcases hG with ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ <;> omega) (by decide))
  generalize hl₈ : setLocal l₇ 23 (u32 (firstOf K (i % 16))) = l₈
  -- 24
  have e24 : (eval C ctx l₈ (shiftedExpr sf)).run sh = some (.bool (shiftedOf sf (i % 16)), sh) := by
    cases sf with
    | false => rfl
    | true =>
      have h19₈ : l₈ 19 = some (u32 (i % 16)) := by rw [← hl₈, setLocal_other _ _ (by omega)]; exact h19₇
      have hc : (eval C ctx l₈ (.conv .bool (.bin .bitAnd .u32 0 (.local 19) (u32l 1)))).run sh =
          some (.bool (decide ((i % 16 &&& 1) % 2 ^ 32 ≠ 0)), sh) :=
        eval_conv C (t := .bool) (eval_bin_u32 C (eval_local' C h19₈ sh) (eval_u32lit C _ _ 1 (by decide))
          (binary_bitAnd_u32 C (i % 16) 1 (by omega) (by decide))) rfl
      have hpm : (i % 16 &&& 1) % 2 ^ 32 = i % 16 % 2 := by
        rw [show (1 : Nat) = 2 ^ 1 - 1 from rfl, Nat.and_two_pow_sub_one_eq_mod]; omega
      rw [hpm] at hc
      exact hc
  generalize hl₉ : setLocal l₈ 24 (.bool (shiftedOf sf (i % 16))) = l₉
  refine ⟨l₉, ?_, ?_⟩
  · show Exec C ctx ([.set 13 _, .set 14 _, .set 15 _, .set 16 _] ++ (.set 17 _ :: .set 18 _ :: .set 19 _ :: .set 20 _ ::
      .set 21 _ :: .set 22 _ :: .set 23 _ :: .set 24 (shiftedExpr sf) :: [])) l sh .normal l₉ sh
    have y5 : Exec C ctx [.set 21 _, .set 22 _, .set 23 _, .set 24 (shiftedExpr sf)] l₅ sh .normal l₉ sh :=
      .set e21 (by rw [hl₆]; exact .set e22 (by rw [hl₇]; exact .set e23 (by rw [hl₈]; exact .set e24 (by
        rw [hl₉]; exact .nil _ _))))
    have y4 : Exec C ctx [.set 20 _, .set 21 _, .set 22 _, .set 23 _, .set 24 (shiftedExpr sf)] l₄ sh .normal l₉ sh :=
      .set e20 (by rw [hl₅]; exact y5)
    exact x1.append (.set e17 (by rw [hl₂]; exact .set e18 (by rw [hl₃]; exact .set e19 (by rw [hl₄]; exact y4))))
  · subst hl₂ hl₃ hl₄ hl₅ hl₆ hl₇ hl₈ hl₉
    exact ⟨hF.of_eq fun j hj => by simp (disch := omega) only [setLocal_lt]; exact hb₁ j (by omega),
      by simp [setLocal, h13], by simp [setLocal, h14], by simp [setLocal, h15], by simp [setLocal, h16],
      by simp [setLocal], by simp [setLocal], by simp [setLocal], by simp [setLocal], by simp [setLocal],
      by simp [setLocal], by simp [setLocal], by simp [setLocal]⟩

end Setup

/-- Thread `32·s + i` of threadgroup `g`'s index. -/
def thOf (g s i : Nat) : Nat := g * 256 + (32 * s + i)

/-- In the row loops: the geometry, `idx`, `r0`, `rows`, `table`, `acc`. -/
structure PLoc (K : Nat) (sf il : Bool) (g s i : Nat) (l : Locals) : Prop where
  geom : Geom K sf il g s i l
  l25 : l 25 = some (.ptr ⟨5 + thOf g s i * 10, 0, .scalar .u32⟩)
  l27 : l 27 = some (u32 (splitOf g s * 136))
  l28 : l 28 = some (u32 136)
  l29 : l 29 = some (.ptr ⟨4, 0, .scalar .u8⟩)
  l30 : l 30 = some (.ptr ⟨5 + thOf g s i * 10 + 1, 0, .scalar .f32⟩)

theorem PLoc.of_eq {K : Nat} {sf il : Bool} {g s i : Nat} {l l' : Locals} (h : PLoc K sf il g s i l)
    (h' : ∀ j, j ≤ 30 → l' j = l j) : PLoc K sf il g s i l' :=
  ⟨h.geom.of_eq fun j hj => h' j (by omega), (h' 25 (by omega)).trans h.l25, (h' 27 (by omega)).trans h.l27,
    (h' 28 (by omega)).trans h.l28, (h' 29 (by omega)).trans h.l29, (h' 30 (by omega)).trans h.l30⟩

/-- The lane's accumulators after `n` rows of its split. -/
def AccArr (C : M1Max.Contract) (K : Nat) (il : Bool) (I : In) (g s i n : Nat) (B : ByteMemory.Bytes) : Prop :=
  ∀ m < 16, cells B (4 * m) 4 =
    wordBytes 4 (Val.f32Bits (accSplit C K il I.Cd I.S I.X (splitOf g s) (colOf g s i m) n))

section Setup2
variable (C : M1Max.Contract) {ctx : Ctx} {L : Launch} {k : Nat} {sf il : Bool} {I : In}
  {accV : Nat → Nat → Float32} {sumsV outV : Nat → Float32} {ge : Nat} {accOk outOk : Nat → Prop} {g s i : Nat}

def setupRest (K : Nat) (sf : Bool) : List CStmt := ((rest1 K sf false).drop 12).take 10

theorem setupRest_eq (K : Nat) (sf : Bool) : setupRest K sf =
    [.array 25 false 0 (.scalar .u32)] ++ ([.set 26 (u32l 0), idxLoop K sf] ++
      ([.set 27 (.bin .mul .u32 0 (.local 17) (u32l 136)), .set 28 (.cond (.un .not .bool (.local 21)) (u32l 0) (u32l 136)),
        .set 29 (.ptrCast (.scalar .u8) (.local 4)), .array 30 false 1 (.scalar .f32)] ++
      ([.set 31 (u32l 0), zeroLoop] ++ [.set 32 (u32l 0)]))) := rfl

/-- `idx`, `r0`, `rows`, `table`, `acc` zeroed, `r = 0`. -/
theorem lane_setupRest (hS : Shape L k sf I) (hG : Geo k sf il) (hl : Lane ctx g s i) {l : Locals} {sh : Shared}
    (hgeo : Geom k sf il g s i l)
    (hm : Mem C L I accV sumsV outV ge (fun _ => True) (fun _ => False) accOk outOk sh)
    (hacc : ∀ th, accOk th → th ≠ thOf g s i) :
    ∃ l' sh', Exec C ctx (setupRest k sf) l sh .normal l' sh' ∧ PLoc k sf il g s i l' ∧ l' 32 = some (u32 0) ∧
      Mem C L I accV sumsV outV ge (fun _ => True) (fun _ => False) accOk outOk sh' ∧
      GateUp.Words (sh'.bytes (5 + thOf g s i * 10)) (nl k sf) (fun m => (firstOf k (i % 16) + m) % wpb k) ∧
      AccArr C k il I g s i 0 (sh'.bytes (5 + thOf g s i * 10 + 1)) := by
  have hg := hl.hg; have hs := hl.hs; have hi := hl.hi
  have hb := geo_bounds hG
  have hnl : nl k sf ≤ 4 := by unfold nl na; rcases hG with ⟨rfl, rfl, -⟩ | ⟨rfl, rfl, -⟩ | ⟨rfl, rfl, -⟩ <;> decide
  have hput : ∀ (reg : Nat), 5 ≤ reg → (∀ th, accOk th → reg ≠ 5 + th * 10 + 1) → ∀ sh o bs,
      Mem C L I accV sumsV outV ge (fun _ => True) (fun _ => False) accOk outOk sh →
      Mem C L I accV sumsV outV ge (fun _ => True) (fun _ => False) accOk outOk (tput sh reg o bs) :=
    fun reg h5 hne sh o bs h => h.tput o bs h5 hne
  -- idx
  generalize hl₁ : setLocal l 25 (.ptr ⟨ctx.threadArray 0, 0, .scalar .u32⟩) = l₁
  have h25 : l₁ 25 = some (.ptr ⟨5 + thOf g s i * 10, 0, .scalar .u32⟩) := by
    rw [← hl₁, setLocal_same, hl.ta]; rfl
  have hb₁ : ∀ j, j < 25 → l₁ j = l j := fun j hj => by rw [← hl₁, setLocal_other _ _ (by omega)]
  have h23 := (hb₁ 23 (by omega)).trans hgeo.l23
  obtain ⟨l₂, sh₂, x2, hm₂, hag₂, hoth₂, hw₂⟩ := exec_fillArray C (ctx := ctx) (Inv := fun sh =>
      Mem C L I accV sumsV outV ge (fun _ => True) (fun _ => False) accOk outOk sh) (reg := 5 + thOf g s i * 10)
    (l := l₁) (sh := sh) (size := 4 * nl k sf)
    (hput _ (by omega) (fun th _ => by omega)) .u32 rfl (nl k sf) 26 25
    (.bin .rem .u32 0 (.bin .add .u32 0 (.local 23) (.local 26)) (u32l (wpb k)))
    (fun m => u32 ((firstOf k (i % 16) + m) % wpb k)) (fun m => wordBytes 4 ((firstOf k (i % 16) + m) % wpb k))
    (fun l' sh' m hm hc hag _ => eval_bin_u32 C (eval_bin_u32 C (eval_local' C (by rw [hag 23 (by omega)]; exact h23) sh')
      (eval_local' C hc sh') (binary_add_u32 C _ m)) (eval_u32lit C _ _ (wpb k) (by omega))
      (binary_rem_u32 C _ _ (by unfold firstOf; rcases hG with ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ <;> omega)
        (by omega) (by omega)))
    (fun m => encode_u32 _ (by have := Nat.mod_lt (firstOf k (i % 16) + m) (show 0 < wpb k by omega); omega))
    (fun m => wordBytes_length 4 _) h25 (by decide) (fun sh' h => by rw [h.regions]; exact hS.ridx _) le_rfl
    (by omega) hm
  have hb₂ : ∀ j, j ≠ 26 → l₂ j = l₁ j := hag₂
  have h17 := (hb₂ 17 (by omega)).trans ((hb₁ 17 (by omega)).trans hgeo.l17)
  have h21 := (hb₂ 21 (by omega)).trans ((hb₁ 21 (by omega)).trans hgeo.l21)
  have h4 := (hb₂ 4 (by omega)).trans ((hb₁ 4 (by omega)).trans hgeo.fix1.l4)
  have e27 : (eval C ctx l₂ (.bin .mul .u32 0 (.local 17) (u32l 136))).run sh₂ = some (u32 (splitOf g s * 136), sh₂) :=
    eval_bin_u32 C (eval_local' C h17 sh₂) (eval_u32lit C _ _ 136 (by decide)) (binary_mul_u32 C _ 136)
  have e28 : ∀ lx : Locals, lx 21 = some (.bool true) →
      (eval C ctx lx (.cond (.un .not .bool (.local 21)) (u32l 0) (u32l 136))).run sh₂ = some (u32 136, sh₂) :=
    fun lx h => eval_cond C (v := false) (eval_un C (eval_local' C h sh₂) rfl) (eval_u32lit C _ _ 136 (by decide))
  generalize hl₃ : setLocal (setLocal (setLocal (setLocal l₂ 27 (u32 (splitOf g s * 136))) 28 (u32 136)) 29
    (.ptr ⟨4, 0, .scalar .u8⟩)) 30 (.ptr ⟨ctx.threadArray 1, 0, .scalar .f32⟩) = l₃
  have x3 : Exec C ctx [.set 27 (.bin .mul .u32 0 (.local 17) (u32l 136)),
      .set 28 (.cond (.un .not .bool (.local 21)) (u32l 0) (u32l 136)), .set 29 (.ptrCast (.scalar .u8) (.local 4)),
      .array 30 false 1 (.scalar .f32)] l₂ sh₂ .normal l₃ sh₂ := by
    rw [← hl₃]
    exact .set e27 (.set (e28 _ (by rw [setLocal_other _ _ (by omega)]; exact h21))
      (.set (eval_ptrCast C (eval_local' C (by simp (disch := omega) only [setLocal_lt]; exact h4) sh₂)) (.array (.nil _ _))))
  have h30 : l₃ 30 = some (.ptr ⟨5 + thOf g s i * 10 + 1, 0, .scalar .f32⟩) := by
    rw [← hl₃, setLocal_same, hl.ta]; rfl
  obtain ⟨l₄, sh₄, x4, hm₄, hag₄, hoth₄, hw₄⟩ := exec_fillArray C (ctx := ctx) (Inv := fun sh =>
      Mem C L I accV sumsV outV ge (fun _ => True) (fun _ => False) accOk outOk sh) (reg := 5 + thOf g s i * 10 + 1)
    (l := l₃) (sh := sh₂) (size := 64)
    (hput _ (by omega) (fun th h => by have := hacc th h; omega)) .f32 rfl 16 31 30 (f32l 0x0)
    (fun _ => .f32 zero) (fun _ => wordBytes 4 (Val.f32Bits zero)) (fun l' sh' m _ _ _ _ => rfl) (fun _ => rfl)
    (fun m => wordBytes_length 4 _) h30 (by decide) (fun sh' h => by rw [h.regions]; exact hS.racc _) le_rfl
    (by decide) hm₂
  refine ⟨setLocal l₄ 32 (u32 0), _, ?_, ?_, setLocal_same _ _ _, hm₄, ?_, ?_⟩
  · rw [setupRest_eq]
    exact Exec.append (.array (by simp only [Bool.false_eq_true, ↓reduceIte]; rw [hl₁]; exact .nil _ _)) (x2.append (x3.append (x4.append
      (.set (eval_u32lit C _ _ 0 (by decide)) (.nil _ _)))))
  · have hl4 : ∀ j, j ≤ 30 → j ≠ 26 → setLocal l₄ 32 (u32 0) j = l₃ j := fun j hj hj' => by
      rw [setLocal_other _ _ (by omega), hag₄ j (by omega)]
    refine ⟨hgeo.of_eq fun j hj => ?_, ?_, ?_, ?_, ?_, ?_⟩
    · rw [hl4 j (by omega) (by omega), ← hl₃]; simp (disch := omega) only [setLocal_lt]
      rw [hb₂ j (by omega), hb₁ j (by omega)]
    · rw [hl4 25 (by omega) (by omega), ← hl₃]; simp (disch := omega) only [setLocal_lt]
      rw [hb₂ 25 (by omega)]; exact h25
    · rw [hl4 27 (by omega) (by omega), ← hl₃]; simp [setLocal]
    · rw [hl4 28 (by omega) (by omega), ← hl₃]; simp [setLocal]
    · rw [hl4 29 (by omega) (by omega), ← hl₃]; simp [setLocal]
    · rw [hl4 30 (by omega) (by omega)]; exact h30
  · intro m hm
    rw [hoth₄ _ (by omega)]; exact hw₂ m hm
  · intro m hm
    rw [hw₄ m hm]; rfl

end Setup2

/-! ### A lane's windows -/

/-- Word `m` a lane loads of a row's block (`ld[m] = rowWords[idx[m]]`). -/
def ldWord (K : Nat) (B : ByteMemory.Bytes) (base li m : Nat) : Nat := word32 B (base + (firstOf K li + m) % wpb K)

/-- Word `m` of a lane's window words (`w[m]`). -/
def wWord (K : Nat) (sf : Bool) (B : ByteMemory.Bytes) (base li m : Nat) : Nat :=
  if shiftedOf sf li then ldWord K B base li m / 2 ^ 16 ||| ldWord K B base li (m + 1) * 2 ^ 16 % 2 ^ 32
  else ldWord K B base li m

theorem ldWord_lt (K : Nat) (B : ByteMemory.Bytes) (base li m : Nat) : ldWord K B base li m < 2 ^ 32 := word32_lt B _

theorem wWord_lt (K : Nat) (sf : Bool) (B : ByteMemory.Bytes) (base li m : Nat) : wWord K sf B base li m < 2 ^ 32 := by
  unfold wWord; split
  · exact Nat.or_lt_two_pow (lt_of_le_of_lt (Nat.div_le_self _ _) (ldWord_lt _ _ _ _ _)) (Nat.mod_lt _ (by decide))
  · exact ldWord_lt _ _ _ _ _

/-- A lane's window `i·K` is the trellis state of block column `255 - (16·li + i)`. -/
theorem code_lane {K : Nat} {sf il : Bool} (hG : Geo K sf il) (B : ByteMemory.Bytes) (base li m : Nat) (hli : li < 16)
    (hm : m < 16) :
    runBits (wWord K sf B base li) (na K) / 2 ^ (m * K) % 2 ^ 12 =
      blockBits K B base / 2 ^ (K * (16 * li + m)) % 2 ^ 12 := by
  have hwpb : wpb K = 8 * K := rfl
  have hL : ∀ n, firstOf K li + n ≤ 8 * K + 1 → ∀ off, off + 12 ≤ 32 * n →
      runBits (ldWord K B base li) n / 2 ^ off % 2 ^ 12 = blockBits K B base / 2 ^ (32 * firstOf K li + off) % 2 ^ 12 :=
    fun n hn off hoff => by
      have := window_block (K := K) B base (firstOf K li) n off hn hoff
      rw [← this]; rfl
  by_cases hsh : shiftedOf sf li = true
  · -- 3-bit, odd lane: the words are the loaded words moved down 16 bits
    have h3 : K = 3 ∧ sf = true ∧ il = true := by
      rcases hG with ⟨rfl, rfl, -⟩ | ⟨rfl, rfl, -⟩ | h
      · simp [shiftedOf] at hsh
      · simp [shiftedOf] at hsh
      · exact h
    obtain ⟨rfl, rfl, rfl⟩ := h3
    have hodd : li % 2 = 1 := by simp [shiftedOf] at hsh; omega
    have hna : na 3 = 2 := rfl
    have hw : ∀ j < na 3, wWord 3 true B base li j =
        runBits (ldWord 3 B base li) 3 / 2 ^ 16 / 2 ^ (32 * j) % 2 ^ 32 := by
      intro j hj
      have e : runBits (ldWord 3 B base li) 3 * 2 ^ 16 / 2 ^ (32 * (j + 1)) =
          runBits (ldWord 3 B base li) 3 / 2 ^ 16 / 2 ^ (32 * j) := by
        rw [Nat.div_div_eq_div_mul, show (2 : Nat) ^ (32 * (j + 1)) = 2 ^ 16 * 2 ^ (32 * j) * 2 ^ 16 by
          rw [← Nat.pow_add, ← Nat.pow_add]; congr 1; ring, Nat.mul_div_mul_right _ _ (Nat.two_pow_pos 16)]
      rw [wWord, ite_eq_left hsh, shifted_word (fun i _ => ldWord_lt 3 B base li i) (show j + 1 < 3 by omega), e]
    have hf : firstOf 3 li ≤ 22 ∧ 32 * firstOf 3 li + 16 = 48 * li := by
      unfold firstOf; rw [show (2 : Nat) ^ 5 = 32 from rfl]; omega
    rw [runBits_congr hw, runBits_words, hna, window_mod _ _ _ (by omega), Nat.div_div_eq_div_mul, ← Nat.pow_add,
      hL 3 (by omega) _ (by omega), show 32 * firstOf 3 li + (16 + m * 3) = 3 * (16 * li + m) by omega]
  · have hw : ∀ j < na K, wWord K sf B base li j = ldWord K B base li j := fun j _ => by
      rw [wWord, ite_eq_right hsh]
    rw [runBits_congr hw]
    have key : firstOf K li + na K ≤ 8 * K + 1 ∧ m * K + 12 ≤ 32 * na K ∧ 32 * firstOf K li + m * K = K * (16 * li + m) := by
      unfold firstOf na
      rcases hG with ⟨rfl, rfl, -⟩ | ⟨rfl, rfl, -⟩ | ⟨rfl, rfl, -⟩
      · omega
      · omega
      · simp [shiftedOf] at hsh; omega
    rw [hL (na K) key.1 _ key.2.1, key.2.2]

section Lookup
variable (C : M1Max.Contract) {ctx : Ctx} {L : Launch} {k : Nat} {sf il : Bool} {I : In}
  {accV : Nat → Nat → Float32} {sumsV outV : Nat → Float32} {ge : Nat} {sumsOk accOk outOk : Nat → Prop}

/-- Codebook loads after the first barrier. -/
theorem cb_load (hS : Shape L k sf I) {sh : Shared}
    (hm : Mem C L I accV sumsV outV ge (fun _ => True) sumsOk accOk outOk sh) :
    ∀ o : Nat, o < 2 ^ 14 → (loadAt ctx (.scalar .f32) ⟨4, (o : Int), .scalar .f32⟩).run sh =
      some (.f32 (codebook C (o / 4)), rdn ctx sh 4 (4 * (o / 4)) 4) := by
  intro o ho
  rw [load_group4 ctx sh 4 o 16384 (by rw [hm.regions]; exact hS.r4) (by omega), hm.cb (o / 4) (by omega) trivial,
    ofWord_f32]

theorem window_eq (b : Nat) : window b = GateUp.window b := rfl

/-- `trellis_codebook_window(table, w, v, i * K, L)` (counter in slot `ic`). -/
theorem exec_lookup (K b w v ic : Nat) {l : Locals} {sh : Shared} {rw rv n : Nat} {W : Nat → Nat} {m : Nat}
    (_h29b : 29 < b) (hw : w < b) (hv : v < b) (hic : ic < b) (hK : K ≤ 4)
    (h29 : l 29 = some (.ptr ⟨4, 0, .scalar .u8⟩)) (hlw : l w = some (.ptr ⟨rw, 0, .scalar .u32⟩))
    (hlv : l v = some (.ptr ⟨rv, 0, .scalar .u32⟩)) (hlic : l ic = some (u32 m)) (hm : m < 16)
    (hrw : sh.regions rw = some ⟨.thread, 4 * n, 4⟩) (hrv : sh.regions rv = some ⟨.thread, 4 * n, 4⟩)
    (hW : GateUp.Words (sh.bytes rw) n W) (hWl : ∀ i, W i < 2 ^ 32)
    (hV : GateUp.Words (sh.bytes rv) n (GateUp.virt W n))
    (hT : ∀ o : Nat, o < 2 ^ 14 → (loadAt ctx (.scalar .f32) ⟨4, (o : Int), .scalar .f32⟩).run sh =
      some (.f32 (codebook C (o / 4)), rdn ctx sh 4 (4 * (o / 4)) 4))
    (hoff : m * K + 12 ≤ 32 * n) :
    ∃ l', Exec C ctx (lookup K b w v ic) l sh .normal l' (rdn ctx sh 4 (4 * (runBits W n / 2 ^ (m * K) % 2 ^ 12)) 4) ∧
      l' (b + 5) = some (.f32 (codebook C (runBits W n / 2 ^ (m * K) % 2 ^ 12))) ∧ ∀ j', j' < b → l' j' = l j' := by
  have hoffv : (eval C ctx (setLocal (setLocal (setLocal l b (.ptr ⟨4, 0, .scalar .u8⟩)) (b + 1)
      (.ptr ⟨rw, 0, .scalar .u32⟩)) (b + 2) (.ptr ⟨rv, 0, .scalar .u32⟩)) (.bin .mul .u32 0 (.local ic) (u32l K))).run sh =
      some (u32 (m * K), sh) := by
    have h' : setLocal (setLocal (setLocal l b (.ptr ⟨4, 0, .scalar .u8⟩)) (b + 1) (.ptr ⟨rw, 0, .scalar .u32⟩)) (b + 2)
        (.ptr ⟨rv, 0, .scalar .u32⟩) ic = some (u32 m) := by
      rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact hlic
    exact eval_bin_u32 C (eval_local' C h' sh) (eval_u32lit C _ _ K (by omega)) (binary_mul_u32 C m K)
  generalize hl₅ : setLocal (setLocal (setLocal (setLocal (setLocal l b (.ptr ⟨4, 0, .scalar .u8⟩)) (b + 1)
      (.ptr ⟨rw, 0, .scalar .u32⟩)) (b + 2) (.ptr ⟨rv, 0, .scalar .u32⟩)) (b + 3) (u32 (m * K))) (b + 4)
      (u32 12) = l₅
  have hl₅b : ∀ j', j' < b → l₅ j' = l j' := fun j' hj' => by
    rw [← hl₅]; simp (disch := omega) only [setLocal_lt]
  obtain ⟨l', hex, h5, hag⟩ := exec_window C (ctx := ctx) b (l := l₅) (sh := sh) (cb := 4) (rw := rw) (rv := rv)
    (n := n) (off := m * K) (W := W) (codebook C) (fun e => rdn ctx sh 4 (4 * e) 4)
    (by rw [← hl₅]; simp [setLocal]) (by rw [← hl₅]; simp [setLocal]) (by rw [← hl₅]; simp [setLocal])
    (by rw [← hl₅]; simp [setLocal]) (by rw [← hl₅]; simp [setLocal]) (fun i _ => hWl i)
    (GateUp.Words.load hrw hW (by omega)) (fun i hi => by
      rw [GateUp.Words.load (W := GateUp.virt W n) hrv hV (by omega) i hi]; rfl) hT hoff
    (lt_of_le_of_lt (Nat.mul_le_mul (le_of_lt hm) hK) (by decide))
  refine ⟨l', ?_, h5, fun j' hj' => by rw [hag j' (.inl (by omega)), hl₅b j' hj']⟩
  have hpre : Exec C ctx [.set b (.local 29), .set (b + 1) (.local w), .set (b + 2) (.local v),
      .set (b + 3) (.bin .mul .u32 0 (.local ic) (u32l K)), .set (b + 4) (u32l 12)] l sh .normal l₅ sh := by
    rw [← hl₅]
    exact .set (eval_local' C h29 sh) <| .set (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact hlw) sh) <|
      .set (eval_local' C (by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact hlv) sh) <|
      .set hoffv <| .set (eval_u32lit C _ _ 12 (by decide)) (.nil _ _)
  have hwin : Exec C ctx [window b] l₅ sh .normal l' (rdn ctx sh 4 (4 * (runBits W n / 2 ^ (m * K) % 2 ^ 12)) 4) := by
    rw [window_eq]; exact hex
  exact hpre.append hwin

end Lookup

/-! ### The rows of a lane's split -/

/-- In row `u` of pair `p`: the setup, `r = 2·p`, the arrays `ld`, `xr`, `sr`, `u`, and `w`, `v`. -/
structure RowLoc (K : Nat) (sf il : Bool) (g s i p u : Nat) (l : Locals) : Prop where
  ploc : PLoc K sf il g s i l
  l32 : l 32 = some (u32 (2 * p))
  l33 : l 33 = some (.ptr ⟨5 + thOf g s i * 10 + 2, 0, .scalar .u32⟩)
  l34 : l 34 = some (.ptr ⟨5 + thOf g s i * 10 + 3, 0, .scalar .f32⟩)
  l35 : l 35 = some (.ptr ⟨5 + thOf g s i * 10 + 4, 0, .scalar .f32⟩)
  l39 : l 39 = some (u32 u)
  l40 : l 40 = some (.ptr ⟨5 + thOf g s i * 10 + 5, 0, .scalar .u32⟩)
  l41 : l 41 = some (.ptr ⟨5 + thOf g s i * 10 + 6, 0, .scalar .u32⟩)

theorem RowLoc.of_eq {K : Nat} {sf il : Bool} {g s i p u : Nat} {l l' : Locals} (h : RowLoc K sf il g s i p u l)
    (h' : ∀ j, j ≤ 43 → l' j = l j) : RowLoc K sf il g s i p u l' :=
  ⟨h.ploc.of_eq fun j hj => h' j (by omega), (h' 32 (by omega)).trans h.l32, (h' 33 (by omega)).trans h.l33,
    (h' 34 (by omega)).trans h.l34, (h' 35 (by omega)).trans h.l35, (h' 39 (by omega)).trans h.l39,
    (h' 40 (by omega)).trans h.l40, (h' 41 (by omega)).trans h.l41⟩

/-- The column of a lane's `acc[m]` is in its block, at block column `255 - (16·li + m)`. -/
theorem colOf_div {g s i m : Nat} (hm : m < 16) : colOf g s i m / 256 = blkOf g s i ∧
    colOf g s i m % 256 = 255 - (16 * (i % 16) + m) := by
  unfold colOf; constructor <;> omega

theorem code_lane_col (C : M1Max.Contract) {K : Nat} {sf il : Bool} (hG : Geo K sf il) (B : ByteMemory.Bytes) (g s i R m : Nat)
    (hm : m < 16) :
    codebook C (runBits (wWord K sf B (dbase K il R (blkOf g s i)) (i % 16)) (na K) / 2 ^ (m * K) % 2 ^ 12) =
      code C K il B R (colOf g s i m) := by
  obtain ⟨h1, h2⟩ := colOf_div (g := g) (s := s) (i := i) hm
  rw [code_lane hG B _ (i % 16) m (by omega) hm, code, trellisCode, h1, h2,
    show 255 - (255 - (16 * (i % 16) + m)) = 16 * (i % 16) + m by omega]

section Codes
variable (C : M1Max.Contract) {ctx : Ctx} {L : Launch} {k : Nat} {sf il : Bool} {I : In}
  {accV : Nat → Nat → Float32} {sumsV outV : Nat → Float32} {g s i : Nat} {accOk outOk : Nat → Prop}

/-- The memory a row's code loop keeps: the codes' word arrays and `xr`, `sr` (bytes `B`). -/
structure RowArr (K : Nat) (sf il : Bool) (I : In) (g s i u R : Nat) (B : Nat → ByteMemory.Bytes) : Prop where
  w : GateUp.Words (B (5 + thOf g s i * 10 + 5)) (na K) (wWord K sf I.Cd (dbase K il R (blkOf g s i)) (i % 16))
  v : GateUp.Words (B (5 + thOf g s i * 10 + 6)) (na K)
    (GateUp.virt (wWord K sf I.Cd (dbase K il R (blkOf g s i)) (i % 16)) (na K))
  xr : cells (B (5 + thOf g s i * 10 + 3)) (4 * u) 4 = wordBytes 4 (Val.f32Bits (xr C I.X R))
  sr : cells (B (5 + thOf g s i * 10 + 4)) (4 * u) 4 = wordBytes 4 (Val.f32Bits (scale I.S R))

/-- At the `m`-th test of the code loop of local row `n` (row `R = 136·split + n`). -/
def CodeI (L : Launch) (K : Nat) (sf il : Bool) (I : In) (accV : Nat → Nat → Float32) (sumsV outV : Nat → Float32)
    (accOk outOk : Nat → Prop) (g s i p u n : Nat) (B0 : Nat → ByteMemory.Bytes) (m : Nat) (l : Locals) (sh : Shared) :
    Prop :=
  RowLoc K sf il g s i p u l ∧ l 44 = some (u32 m) ∧
    Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh ∧
    (∀ r, r ≠ 5 + thOf g s i * 10 + 1 → sh.bytes r = B0 r) ∧
    ∀ m' < 16, cells (sh.bytes (5 + thOf g s i * 10 + 1)) (4 * m') 4 = wordBytes 4 (Val.f32Bits
      (accSplit C K il I.Cd I.S I.X (splitOf g s) (colOf g s i m') (if m' < m then n + 1 else n)))

theorem code_loop (hS : Shape L k sf I) (hG : Geo k sf il) (hl : Lane ctx g s i) {p u n : Nat} (hu : u < 2)
    {B0 : Nat → ByteMemory.Bytes} (harr : RowArr C k sf il I g s i u (136 * splitOf g s + n) B0)
    (hacc : ∀ th, accOk th → th ≠ thOf g s i) {l : Locals} {sh : Shared}
    (h0 : CodeI C L k sf il I accV sumsV outV accOk outOk g s i p u n B0 0 l sh) :
    ∃ l' sh', Exec C ctx [.loop (ltU 44 16) (stepU 44 1) (pairCodeBody k)] l sh .normal l' sh' ∧
      CodeI C L k sf il I accV sumsV outV accOk outOk g s i p u n B0 16 l' sh' := by
  have hb := geo_bounds hG
  have hna : 1 ≤ na k ∧ 15 * k + 12 ≤ 32 * na k := by
    unfold na; rcases hG with ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ <;> omega
  refine Exec.loop_count 16 (CodeI C L k sf il I accV sumsV outV accOk outOk g s i p u n B0)
    (CodeI C L k sf il I accV sumsV outV accOk outOk g s i p u n B0) (fun m hm l sh hI => ⟨sh, ?_, hI⟩)
    (fun m hm l sh hI => ?_) h0
  · exact eval_lt_u32 C (ctx := ctx) (sh := sh) (b := 16) hI.2.1 (by omega) (by decide)
  · obtain ⟨hR, h44, hm', hoth, hacc'⟩ := hI
    have hreg := hm'.regions
    obtain ⟨l₁, xl, h50, hag₁⟩ := exec_lookup C (ctx := ctx) k 45 40 41 44 (l := l) (sh := sh)
      (rw := 5 + thOf g s i * 10 + 5) (rv := 5 + thOf g s i * 10 + 6) (n := na k)
      (W := wWord k sf I.Cd (dbase k il (136 * splitOf g s + n) (blkOf g s i)) (i % 16)) (m := m)
      (by omega) (by omega) (by omega) (by omega) hb.2.1 hR.ploc.l29 hR.l40 hR.l41 h44 hm
      (by rw [hreg]; exact hS.rw _) (by rw [hreg]; exact hS.rv _)
      (by rw [hoth _ (by omega)]; exact harr.w) (fun _ => wWord_lt _ _ _ _ _ _)
      (by rw [hoth _ (by omega)]; exact harr.v) (cb_load C hS hm')
      (by have := hna.2; nlinarith)
    rw [code_lane_col C hG I.Cd g s i _ m hm] at h50
    generalize runBits (wWord k sf I.Cd (dbase k il (136 * splitOf g s + n) (blkOf g s i)) (i % 16)) (na k) / 2 ^ (m * k)
      % 2 ^ 12 = idx at xl
    have hm₁ := hm'.rd hS ctx 4 (4 * idx) 4 (.inr ⟨rfl, by rw [hl.group]; omega, by rw [hl.group]; omega⟩)
    have hb₁ : (rdn ctx sh 4 (4 * idx) 4).bytes = sh.bytes := rfl
    generalize rdn ctx sh 4 (4 * idx) 4 = sh₁ at xl hm₁ hb₁
    have hl₁ : ∀ j, j < 45 → l₁ j = l j := hag₁
    generalize hcd : code C k il I.Cd (136 * splitOf g s + n) (colOf g s i m) = cd at h50
    have hreg₁ := hm₁.regions
    have hsr : (eval C ctx (setLocal l₁ 55 (.f32 cd)) (.load (.scalar .f32) (.offset (.local 35) (.local 39)))).run sh₁ =
        some (.f32 (scale I.S (136 * splitOf g s + n)), sh₁) := by
      have hp := eval_ptr_u32 C (ctx := ctx) (l := setLocal l₁ 55 (.f32 cd)) (sh := sh₁)
        (eval_local' C (i := 35) (by rw [setLocal_other _ _ (by omega), hl₁ 35 (by omega)]; exact hR.l35) sh₁)
        (eval_local' C (i := 39) (by rw [setLocal_other _ _ (by omega), hl₁ 39 (by omega)]; exact hR.l39) sh₁) (by omega)
      rw [show u * (Ty.scalar .f32).bytes = 4 * u by simp [Ty.bytes, Scalar.bytes]; ring] at hp
      rw [eval_load C _ _ _ _ _ _ _ hp]
      exact load_f32_thread_cells (by rw [hreg₁]; exact hS.rsr _) (by omega) (by rw [hb₁, hoth _ (by omega)]; exact harr.sr)
    have hxr : (eval C ctx (setLocal l₁ 55 (.f32 cd)) (.load (.scalar .f32) (.offset (.local 34) (.local 39)))).run sh₁ =
        some (.f32 (xr C I.X (136 * splitOf g s + n)), sh₁) := by
      have hp := eval_ptr_u32 C (ctx := ctx) (l := setLocal l₁ 55 (.f32 cd)) (sh := sh₁)
        (eval_local' C (i := 34) (by rw [setLocal_other _ _ (by omega), hl₁ 34 (by omega)]; exact hR.l34) sh₁)
        (eval_local' C (i := 39) (by rw [setLocal_other _ _ (by omega), hl₁ 39 (by omega)]; exact hR.l39) sh₁) (by omega)
      rw [show u * (Ty.scalar .f32).bytes = 4 * u by simp [Ty.bytes, Scalar.bytes]; ring] at hp
      rw [eval_load C _ _ _ _ _ _ _ hp]
      exact load_f32_thread_cells (by rw [hreg₁]; exact hS.rxr _) (by omega) (by rw [hb₁, hoth _ (by omega)]; exact harr.xr)
    have hap : (eval C ctx (setLocal l₁ 55 (.f32 cd)) (.offset (.local 30) (.local 44))).run sh₁ =
        some (.ptr ⟨5 + thOf g s i * 10 + 1, ((4 * m : Nat) : Int), .scalar .f32⟩, sh₁) := by
      have hp := eval_ptr_u32 C (ctx := ctx) (l := setLocal l₁ 55 (.f32 cd)) (sh := sh₁)
        (eval_local' C (i := 30) (by rw [setLocal_other _ _ (by omega), hl₁ 30 (by omega)]; exact hR.ploc.l30) sh₁)
        (eval_local' C (i := 44) (by rw [setLocal_other _ _ (by omega), hl₁ 44 (by omega)]; exact h44) sh₁) (by omega)
      rwa [show m * (Ty.scalar .f32).bytes = 4 * m by simp [Ty.bytes, Scalar.bytes]; ring] at hp
    have hacc0 : (eval C ctx (setLocal l₁ 55 (.f32 cd)) (accAt 44)).run sh₁ = some (.f32 (accSplit C k il I.Cd I.S I.X
        (splitOf g s) (colOf g s i m) n), sh₁) := by
      rw [accAt, eval_load C _ _ _ _ _ _ _ hap]
      have := hacc' m hm
      rw [ite_eq_right (Nat.lt_irrefl m)] at this
      exact load_f32_thread_cells (by rw [hreg₁]; exact hS.racc _) (by omega) (by rw [hb₁]; exact this)
    have hval : (eval C ctx (setLocal l₁ 55 (.f32 cd)) (.fma (.bin .mul .f32 0 (.local 55)
        (.load (.scalar .f32) (.offset (.local 35) (.local 39)))) (.load (.scalar .f32) (.offset (.local 34) (.local 39)))
        (accAt 44))).run sh₁ = some (.f32 (accSplit C k il I.Cd I.S I.X (splitOf g s) (colOf g s i m) (n + 1)), sh₁) := by
      rw [accSplit, hcd]
      exact eval_fma C (eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_local' C (setLocal_same _ _ _) sh₁) hsr rfl) hxr hacc0
    have hst := store_thread ctx .f32 sh₁ (5 + thOf g s i * 10 + 1) (4 * m) 64 4
      (.f32 (accSplit C k il I.Cd I.S I.X (splitOf g s) (colOf g s i m) (n + 1)))
      (wordBytes 4 (Val.f32Bits (accSplit C k il I.Cd I.S I.X (splitOf g s) (colOf g s i m) (n + 1))))
      (by rw [hreg₁]; exact hS.racc _) (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (encode_f32 _)
    refine ⟨.normal, setLocal l₁ 55 (.f32 cd), _, setLocal (setLocal l₁ 55 (.f32 cd)) 44 (u32 (m + 1)), _, .inl rfl,
      xl.append (.set (eval_local' C h50 sh₁) (.store hap hval hst (.nil _ _))),
      .set (eval_bin_u32 C (eval_local' C (by rw [setLocal_other _ _ (by omega), hl₁ 44 (by omega)]; exact h44) _)
        (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C m 1)) (.nil _ _), ?_, setLocal_same _ _ _,
      hm₁.tput _ _ (by omega) (fun th h => by have := hacc th h; unfold thOf at this ⊢; omega),
      fun r hr => by rw [tput_other _ _ _ hr, hb₁, hoth r hr], fun m' hm' => ?_⟩
    · exact hR.of_eq fun j hj => by
        rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), hl₁ j (by omega)]
    · rw [tput_same]
      by_cases hmm : m' = m
      · subst hmm
        have := cells_writeBytes_same (sh₁.bytes (5 + thOf g s i * 10 + 1)) (4 * m')
          (wordBytes 4 (Val.f32Bits (accSplit C k il I.Cd I.S I.X (splitOf g s) (colOf g s i m') (n + 1))))
        rw [wordBytes_length] at this
        rw [this, ite_eq_left (Nat.lt_succ_self m')]
      · have e : (if m' < m then n + 1 else n) = (if m' < m + 1 then n + 1 else n) := by
          by_cases h1 : m' < m
          · rw [ite_eq_left h1, ite_eq_left (by omega)]
          · rw [ite_eq_right h1, ite_eq_right (by omega)]
        rw [cells_writeBytes_other _ _ _ _ _ (by rw [wordBytes_length]; omega), hb₁, hacc' m' hm', e]

end Codes

section Restore
variable {C : M1Max.Contract} {L : Launch} {I : In} {accV : Nat → Nat → Float32} {sumsV outV : Nat → Float32}
  {ge : Nat} {cbOk sumsOk accOk outOk : Nat → Prop}

/-- The accumulators of the threads `accOk` back, their bytes untouched. -/
theorem Mem.restore {sh sh' : Shared} (h : Mem C L I accV sumsV outV ge cbOk sumsOk (fun _ => False) outOk sh')
    (h0 : Mem C L I accV sumsV outV ge cbOk sumsOk accOk outOk sh)
    (hb : ∀ th, accOk th → sh'.bytes (5 + th * 10 + 1) = sh.bytes (5 + th * 10 + 1)) :
    Mem C L I accV sumsV outV ge cbOk sumsOk accOk outOk sh' :=
  ⟨h.regions, h.x, h.cd, h.sc, h.deve, h.grpe, h.cb, h.sums, fun th ha j hj => by rw [hb th ha]; exact h0.acc th ha j hj,
    h.out, h.log⟩

end Restore

/-- In the row-pair loop: the setup, `r = 2·p`, the arrays `ld`, `xr`, `sr`. -/
structure PairLoc (K : Nat) (sf il : Bool) (g s i p : Nat) (l : Locals) : Prop where
  ploc : PLoc K sf il g s i l
  l32 : l 32 = some (u32 (2 * p))
  l33 : l 33 = some (.ptr ⟨5 + thOf g s i * 10 + 2, 0, .scalar .u32⟩)
  l34 : l 34 = some (.ptr ⟨5 + thOf g s i * 10 + 3, 0, .scalar .f32⟩)
  l35 : l 35 = some (.ptr ⟨5 + thOf g s i * 10 + 4, 0, .scalar .f32⟩)

theorem PairLoc.of_eq {K : Nat} {sf il : Bool} {g s i p : Nat} {l l' : Locals} (h : PairLoc K sf il g s i p l)
    (h' : ∀ j, j ≤ 35 → l' j = l j) : PairLoc K sf il g s i p l' :=
  ⟨h.ploc.of_eq fun j hj => h' j (by omega), (h' 32 (by omega)).trans h.l32, (h' 33 (by omega)).trans h.l33,
    (h' 34 (by omega)).trans h.l34, (h' 35 (by omega)).trans h.l35⟩

theorem RowLoc.pair {K : Nat} {sf il : Bool} {g s i p u : Nat} {l : Locals} (h : RowLoc K sf il g s i p u l) :
    PairLoc K sf il g s i p l :=
  ⟨h.ploc, h.l32, h.l33, h.l34, h.l35⟩

section Rows
variable (C : M1Max.Contract) {ctx : Ctx} {L : Launch} {k : Nat} {sf il : Bool} {I : In}
  {accV : Nat → Nat → Float32} {sumsV outV : Nat → Float32} {g s i : Nat} {accOk outOk : Nat → Prop}

/-- `ld[u]`. -/
theorem eval_ldRow {l : Locals} {sh : Shared} {reg n us u : Nat} (h33 : l 33 = some (.ptr ⟨reg, 0, .scalar .u32⟩))
    (hu : l us = some (u32 u)) (hul : u < 2 ^ 32) (hn : n < 2 ^ 32) :
    (eval C ctx l (ldRow n us)).run sh = some (.ptr ⟨reg, ((4 * (u * n) : Nat) : Int), .scalar .u32⟩, sh) := by
  have hlt : u * n < 2 ^ 64 := by have := Nat.mul_lt_mul'' hul hn; omega
  have := eval_offset_u64 C (ctx := ctx) (o := 0) (i := .bin .mul .u64 0 (.conv .u64 (.local us)) (u64l n))
    (eval_local' C h33 sh)
    (eval_int C (by decide) (eval_conv C (t := .u64) (eval_local' C hu sh) (convert_u64_u32 C _ hul))
      (eval_u64lit C _ _ n (by omega)) (binary_mul_u64 C _ _)) hlt
  rwa [show 0 + u * n * (Ty.scalar .u32).bytes = 4 * (u * n) by simp [Ty.bytes, Scalar.bytes]; ring] at this

/-- `w[i] = shifted ? (ld[u][i] >> SHIFT) | (ld[u][i + 1] << (32u - SHIFT)) : ld[u][i]`. -/
theorem exec_alignWords (hS : Shape L k sf I) (hG : Geo k sf il) {ge : Nat} {cbOk sumsOk : Nat → Prop} {u base : Nat}
    (hu : u < 2) {l : Locals} {sh : Shared} (h24 : l 24 = some (.bool (shiftedOf sf (i % 16))))
    (h33 : l 33 = some (.ptr ⟨5 + thOf g s i * 10 + 2, 0, .scalar .u32⟩)) (h39 : l 39 = some (u32 u))
    (h40 : l 40 = some (.ptr ⟨5 + thOf g s i * 10 + 5, 0, .scalar .u32⟩))
    (hld : ∀ m < nl k sf, cells (sh.bytes (5 + thOf g s i * 10 + 2)) (4 * (u * nl k sf + m)) 4 =
      wordBytes 4 (ldWord k I.Cd base (i % 16) m))
    (hm : Mem C L I accV sumsV outV ge cbOk sumsOk accOk outOk sh) (hacc : ∀ th, accOk th → th ≠ thOf g s i) :
    ∃ l' sh', Exec C ctx [.set 42 (u32l 0), alignWords (na k) (shift sf) 42 40 (ldRow (nl k sf) 39)] l sh .normal l' sh' ∧
      Mem C L I accV sumsV outV ge cbOk sumsOk accOk outOk sh' ∧ (∀ j, j ≠ 42 → l' j = l j) ∧
      (∀ r, r ≠ 5 + thOf g s i * 10 + 5 → sh'.bytes r = sh.bytes r) ∧
      GateUp.Words (sh'.bytes (5 + thOf g s i * 10 + 5)) (na k) (wWord k sf I.Cd base (i % 16)) := by
  have hnl : nl k sf ≤ 4 ∧ na k ≤ nl k sf ∧ (sf = true → nl k sf = na k + 1) := by
    unfold nl na; rcases hG with ⟨rfl, rfl, -⟩ | ⟨rfl, rfl, -⟩ | ⟨rfl, rfl, -⟩ <;> decide
  have hun : u * nl k sf + nl k sf ≤ 2 * nl k sf := by rcases (show u = 0 ∨ u = 1 by omega) with rfl | rfl <;> omega
  generalize hB2 : sh.bytes (5 + thOf g s i * 10 + 2) = B2 at hld
  have he : ∀ (l' : Locals) (sh' : Shared) (m : Nat), m < na k → l' 42 = some (u32 m) → (∀ j, j ≠ 42 → l' j = l j) →
      (Mem C L I accV sumsV outV ge cbOk sumsOk accOk outOk sh' ∧ sh'.bytes (5 + thOf g s i * 10 + 2) = B2) →
      (eval C ctx l' (.cond (.local 24)
        (.bin .bitOr .u32 0 (.bin .shr .u32 0 (.load (.scalar .u32) (.offset (ldRow (nl k sf) 39) (.local 42))) (u32l (shift sf)))
          (.bin .shl .u32 0 (.load (.scalar .u32) (.offset (ldRow (nl k sf) 39) (.bin .add .u32 0 (.local 42) (u32l 1))))
            (u32l (32 - shift sf))))
        (.load (.scalar .u32) (.offset (ldRow (nl k sf) 39) (.local 42))))).run sh' =
        some (u32 (wWord k sf I.Cd base (i % 16) m), sh') := by
    intro l' sh' m hm' hc hag hI
    have hreg := hI.1.regions
    have hldm : ∀ (j : Nat) (e : CExpr), j < nl k sf → (eval C ctx l' e).run sh' = some (u32 j, sh') →
        (eval C ctx l' (.load (.scalar .u32) (.offset (ldRow (nl k sf) 39) e))).run sh' =
          some (u32 (ldWord k I.Cd base (i % 16) j), sh') := by
      intro j e hj hev
      have hp := eval_offset_u32 C (ctx := ctx)
        (eval_ldRow C (ctx := ctx) (sh := sh') (n := nl k sf) (us := 39) (u := u) (by rw [hag 33 (by decide)]; exact h33) (by rw [hag 39 (by decide)]; exact h39)
          (by omega) (by omega)) hev (by omega)
      rw [show 4 * (u * nl k sf) + j * (Ty.scalar .u32).bytes = 4 * (u * nl k sf + j) by
        simp [Ty.bytes, Scalar.bytes]; ring] at hp
      rw [eval_load C _ _ _ _ _ _ _ hp, load_thread ctx .u32 sh' _ (4 * (u * nl k sf + j)) (4 * (2 * nl k sf)) 4
        (by rw [hreg]; exact hS.rld _) (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega)]
      simp only [Scalar.bytes]
      rw [hI.2, hld j hj, ofWord_u32]
    have h24' : l' 24 = some (.bool (shiftedOf sf (i % 16))) := by rw [hag 24 (by decide)]; exact h24
    refine eval_cond C (eval_local' C h24' sh') ?_
    by_cases hsh : shiftedOf sf (i % 16) = true
    · have hsf : sf = true := by simp [shiftedOf] at hsh; exact hsh.1
      rw [ite_eq_left hsh, wWord, ite_eq_left hsh]
      subst hsf
      have e1 : u32l (shift true) = u32l 16 := rfl
      have e2 : u32l (32 - shift true) = u32l 16 := rfl
      rw [e1, e2]
      have hw0 := ldWord_lt k I.Cd base (i % 16) m
      exact eval_bin_u32 C (eval_bin_u32 C (hldm m (.local 42) (by omega) (eval_local' C hc sh'))
          (eval_u32lit C _ _ 16 (by decide)) (binary_shr_u32 C _ 16 hw0 (by decide)))
        (by
          rw [u32_mod]
          exact eval_bin_u32 C (hldm (m + 1) _ (by have := hnl.2.2 rfl; omega)
              (eval_bin_u32 C (eval_local' C hc sh') (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C m 1)))
            (eval_u32lit C _ _ 16 (by decide)) (binary_shl_u32 C _ 16 (by decide)))
        (binary_bitOr_u32 C _ _ (lt_of_le_of_lt (Nat.div_le_self _ _) hw0) (Nat.mod_lt _ (by decide)))
    · rw [ite_eq_right hsh, wWord, ite_eq_right hsh]
      exact hldm m (.local 42) (by omega) (eval_local' C hc sh')
  obtain ⟨l', sh', hex, ⟨hm', -⟩, hag, hoth, hw⟩ := exec_fillArray C (ctx := ctx)
    (Inv := fun sh' => Mem C L I accV sumsV outV ge cbOk sumsOk accOk outOk sh' ∧ sh'.bytes (5 + thOf g s i * 10 + 2) = B2)
    (reg := 5 + thOf g s i * 10 + 5) (l := l) (sh := sh) (size := 4 * na k)
    (fun sh o bs h => ⟨h.1.tput o bs (by omega) (fun th h' => by have := hacc th h'; unfold thOf at this ⊢; omega),
      by rw [tput_other _ _ _ (by omega)]; exact h.2⟩) .u32 rfl (na k) 42 40 _
    (fun m => u32 (wWord k sf I.Cd base (i % 16) m)) (fun m => wordBytes 4 (wWord k sf I.Cd base (i % 16) m))
    he (fun m => encode_u32 _ (wWord_lt _ _ _ _ _ _)) (fun m => wordBytes_length 4 _)
    h40 (by decide) (fun sh' h => by rw [h.1.regions]; exact hS.rw _) le_rfl (by omega) ⟨hm, hB2⟩
  exact ⟨l', sh', hex, hm', hag, hoth, hw⟩

theorem pairRowBody_eq (k : Nat) (sf : Bool) : pairRowBody k sf =
    [.array 40 false 5 (.scalar .u32), .array 41 false 6 (.scalar .u32)] ++
      ([.set 42 (u32l 0), alignWords (na k) (shift sf) 42 40 (ldRow (nl k sf) 39)] ++
      ([firstVirtual 40 41] ++ ([.set 43 (u32l 1), virtualWords (na k) 43 40 41] ++
      [.set 44 (u32l 0), .loop (ltU 44 16) (stepU 44 1) (pairCodeBody k)]))) := rfl

/-- Row `u` of pair `p`: its window words and virtual words, then its 16 codes into `acc`. -/
theorem pair_row (hS : Shape L k sf I) (hG : Geo k sf il) (hl : Lane ctx g s i) {p u : Nat} (hu : u < 2)
    {l : Locals} {sh : Shared} (hP : PairLoc k sf il g s i p l) (h39 : l 39 = some (u32 u))
    (hld : ∀ m < nl k sf, cells (sh.bytes (5 + thOf g s i * 10 + 2)) (4 * (u * nl k sf + m)) 4 =
      wordBytes 4 (ldWord k I.Cd (dbase k il (136 * splitOf g s + (2 * p + u)) (blkOf g s i)) (i % 16) m))
    (hxr : cells (sh.bytes (5 + thOf g s i * 10 + 3)) (4 * u) 4 =
      wordBytes 4 (Val.f32Bits (xr C I.X (136 * splitOf g s + (2 * p + u)))))
    (hsr : cells (sh.bytes (5 + thOf g s i * 10 + 4)) (4 * u) 4 =
      wordBytes 4 (Val.f32Bits (scale I.S (136 * splitOf g s + (2 * p + u)))))
    (hm : Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh)
    (hacc : ∀ th, accOk th → th ≠ thOf g s i)
    (hA : AccArr C k il I g s i (2 * p + u) (sh.bytes (5 + thOf g s i * 10 + 1))) :
    ∃ l' sh', Exec C ctx (pairRowBody k sf) l sh .normal l' sh' ∧ PairLoc k sf il g s i p l' ∧ l' 39 = some (u32 u) ∧
      Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh' ∧
      (∀ r, r ≠ 5 + thOf g s i * 10 + 1 → r ≠ 5 + thOf g s i * 10 + 5 → r ≠ 5 + thOf g s i * 10 + 6 →
        sh'.bytes r = sh.bytes r) ∧
      AccArr C k il I g s i (2 * p + u + 1) (sh'.bytes (5 + thOf g s i * 10 + 1)) := by
  have hna : 1 ≤ na k ∧ na k ≤ 3 := by unfold na; rcases hG with ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ <;> omega
  generalize hW : wWord k sf I.Cd (dbase k il (136 * splitOf g s + (2 * p + u)) (blkOf g s i)) (i % 16) = W
  have hWl : ∀ j, W j < 2 ^ 32 := fun j => by rw [← hW]; exact wWord_lt _ _ _ _ _ _
  -- the arrays
  generalize hl₁ : setLocal (setLocal l 40 (.ptr ⟨5 + thOf g s i * 10 + 5, 0, .scalar .u32⟩)) 41
    (.ptr ⟨5 + thOf g s i * 10 + 6, 0, .scalar .u32⟩) = l₁
  have x1 : Exec C ctx [.array 40 false 5 (.scalar .u32), .array 41 false 6 (.scalar .u32)] l sh .normal l₁ sh := by
    rw [← hl₁]
    refine .array ?_
    simp only [Bool.false_eq_true, ↓reduceIte]
    refine .array ?_
    simp only [Bool.false_eq_true, ↓reduceIte]
    rw [hl.ta, hl.ta]
    exact .nil _ _
  have hb₁ : ∀ j, j < 40 → l₁ j = l j := fun j hj => by
    rw [← hl₁, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
  have h40 : l₁ 40 = some (.ptr ⟨5 + thOf g s i * 10 + 5, 0, .scalar .u32⟩) := by
    rw [← hl₁, setLocal_other _ _ (by omega), setLocal_same]
  have h41 : l₁ 41 = some (.ptr ⟨5 + thOf g s i * 10 + 6, 0, .scalar .u32⟩) := by rw [← hl₁, setLocal_same]
  -- the window words
  obtain ⟨l₂, sh₂, x2, hm₂, hag₂, hoth₂, hw₂⟩ := exec_alignWords C (ctx := ctx) hS hG (u := u)
    (base := dbase k il (136 * splitOf g s + (2 * p + u)) (blkOf g s i)) hu (l := l₁) (sh := sh)
    (by rw [hb₁ 24 (by omega)]; exact hP.ploc.geom.l24) (by rw [hb₁ 33 (by omega)]; exact hP.l33)
    (by rw [hb₁ 39 (by omega)]; exact h39) h40 hld hm hacc
  rw [hW] at hw₂
  -- the virtual words, with the other accumulators set aside
  have hm₂' := hm₂.mono (accOk' := fun _ => False) (fun _ _ h => h) (fun _ _ h => h) (fun _ h => h.elim) (fun _ _ h => h)
  have hput : ∀ sh reg o bs, Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) (fun _ => False)
      outOk sh → 8 ≤ reg → Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) (fun _ => False)
      outOk (tput sh reg o bs) := fun sh reg o bs h hr => h.tput o bs (by omega) (fun _ h => h.elim)
  have hrw : ∀ sh' : Shared, sh'.regions = L.regions → sh'.regions (5 + thOf g s i * 10 + 5) = some ⟨.thread, 4 * na k, 4⟩ :=
    fun sh' h => by rw [h]; exact hS.rw _
  have hrv : ∀ sh' : Shared, sh'.regions = L.regions → sh'.regions (5 + thOf g s i * 10 + 6) = some ⟨.thread, 4 * na k, 4⟩ :=
    fun sh' h => by rw [h]; exact hS.rv _
  obtain ⟨sh₃, x3, hm₃, hreg₃, hoth₃, -, hv₃⟩ := GateUp.exec_firstVirtual C (ctx := ctx) hput 40 41 (l := l₂) (sh := sh₂)
    (rw := 5 + thOf g s i * 10 + 5) (rv := 5 + thOf g s i * 10 + 6) (sizeW := 4 * na k) (sizeV := 4 * na k) (W := W)
    (hrw _ hm₂.regions) (hrv _ hm₂.regions) (by omega)
    (by rw [hag₂ 40 (by decide)]; exact h40) (by rw [hag₂ 41 (by decide)]; exact h41)
    (by simpa using hw₂ 0 (by omega)) (by omega) (by omega) hm₂'
  have hcond : ∀ (l' : Locals) (sh' : Shared) (m : Nat), m ≤ na k - 1 → l' 43 = some (u32 (m + 1)) →
      (eval C ctx l' (ltU 43 (na k))).run sh' = some (.bool (decide (m < na k - 1)), sh') := by
    intro l' sh' m hm' h
    have := eval_lt_u32 C (ctx := ctx) (sh := sh') (b := na k) h (by omega) (by omega)
    rwa [show decide (m + 1 < na k) = decide (m < na k - 1) from decide_eq_decide.mpr (by omega)] at this
  obtain ⟨l₄, sh₄, x4, hm₄, hag₄, -, hreg₄, hoth₄, h0₄, hv₄⟩ := GateUp.exec_virtualWords C (ctx := ctx) hput (na k - 1)
    43 40 41 (ltU 43 (na k)) hcond (l := l₂) (sh := sh₃) (rw := 5 + thOf g s i * 10 + 5)
    (rv := 5 + thOf g s i * 10 + 6) (sizeW := 4 * na k) (sizeV := 4 * na k) (W := W)
    (hrw _ (hreg₃.trans hm₂.regions)) (hrv _ (hreg₃.trans hm₂.regions)) (by omega) (by omega)
    (by rw [hag₂ 40 (by decide)]; exact h40) (by rw [hag₂ 41 (by decide)]; exact h41) (by decide) (by decide)
    (fun j hj => by rw [hoth₃ _ (by omega)]; exact hw₂ j (by omega)) (fun j _ => hWl j)
    (by omega) (by omega) (by omega) hm₃
  have hV : GateUp.Words (sh₄.bytes (5 + thOf g s i * 10 + 6)) (na k) (GateUp.virt W (na k)) := by
    have := GateUp.words_virt (K := na k - 1) (B' := sh₄.bytes (5 + thOf g s i * 10 + 6)) (W := W) hWl
      (by rw [h0₄]; exact hv₃) hv₄
    rwa [Nat.sub_add_cancel hna.1] at this
  have hb₄ : ∀ r, r ≠ 5 + thOf g s i * 10 + 5 → r ≠ 5 + thOf g s i * 10 + 6 → sh₄.bytes r = sh.bytes r :=
    fun r h5 h6 => by rw [hoth₄ r h6, hoth₃ r h6, hoth₂ r h5]
  have hm₄' : Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh₄ :=
    Mem.restore hm₄ hm₂ (fun th h => by
      rw [hoth₄ _ (by unfold thOf; omega), hoth₃ _ (by unfold thOf; omega)])
  -- the codes
  have hl₄ : ∀ j, j ≤ 41 → j ≠ 42 → j ≠ 43 → setLocal l₄ 44 (u32 0) j = l₁ j := fun j hj h2 h3 => by
    rw [setLocal_other _ _ (by omega), hag₄ j h3, hag₂ j h2]
  have hRL : RowLoc k sf il g s i p u (setLocal l₄ 44 (u32 0)) :=
    ⟨hP.ploc.of_eq fun j hj => by rw [hl₄ j (by omega) (by omega) (by omega), hb₁ j (by omega)],
      by rw [hl₄ 32 (by omega) (by omega) (by omega), hb₁ 32 (by omega)]; exact hP.l32,
      by rw [hl₄ 33 (by omega) (by omega) (by omega), hb₁ 33 (by omega)]; exact hP.l33,
      by rw [hl₄ 34 (by omega) (by omega) (by omega), hb₁ 34 (by omega)]; exact hP.l34,
      by rw [hl₄ 35 (by omega) (by omega) (by omega), hb₁ 35 (by omega)]; exact hP.l35,
      by rw [hl₄ 39 (by omega) (by omega) (by omega), hb₁ 39 (by omega)]; exact h39,
      by rw [hl₄ 40 (by omega) (by omega) (by omega)]; exact h40,
      by rw [hl₄ 41 (by omega) (by omega) (by omega)]; exact h41⟩
  have harr : RowArr C k sf il I g s i u (136 * splitOf g s + (2 * p + u)) sh₄.bytes :=
    ⟨by rw [hW, hoth₄ _ (by omega)]; exact fun j hj => by rw [hoth₃ _ (by omega)]; exact hw₂ j hj,
      by rw [hW]; exact hV,
      by rw [hb₄ _ (by omega) (by omega)]; exact hxr,
      by rw [hb₄ _ (by omega) (by omega)]; exact hsr⟩
  obtain ⟨l₆, sh₆, x6, hR₆, -, hm₆, hoth₆, hacc₆⟩ := code_loop C (ctx := ctx) hS hG hl (p := p) (u := u) (n := 2 * p + u) hu
    (B0 := sh₄.bytes) harr hacc (l := setLocal l₄ 44 (u32 0)) (sh := sh₄)
    ⟨hRL, setLocal_same _ _ _, hm₄', fun r _ => rfl, fun m' hm' => by
      rw [ite_eq_right (Nat.not_lt_zero m'), hb₄ _ (by omega) (by omega)]; exact hA m' hm'⟩
  refine ⟨l₆, sh₆, ?_, hR₆.pair, hR₆.l39, hm₆, fun r h1 h5 h6 => by rw [hoth₆ r h1, hb₄ r h5 h6], fun m' hm' => ?_⟩
  · rw [pairRowBody_eq]
    exact x1.append (x2.append (x3.append (x4.append (.set (eval_u32lit C _ _ 0 (by decide)) x6))))
  · have := hacc₆ m' hm'
    rwa [ite_eq_left hm'] at this

/-- Both rows of pair `p`. -/
theorem pair_rows (hS : Shape L k sf I) (hG : Geo k sf il) (hl : Lane ctx g s i) {p : Nat}
    {l : Locals} {sh : Shared} (hP : PairLoc k sf il g s i p l)
    (hld : ∀ u < 2, ∀ m < nl k sf, cells (sh.bytes (5 + thOf g s i * 10 + 2)) (4 * (u * nl k sf + m)) 4 =
      wordBytes 4 (ldWord k I.Cd (dbase k il (136 * splitOf g s + (2 * p + u)) (blkOf g s i)) (i % 16) m))
    (hxr : ∀ u < 2, cells (sh.bytes (5 + thOf g s i * 10 + 3)) (4 * u) 4 =
      wordBytes 4 (Val.f32Bits (xr C I.X (136 * splitOf g s + (2 * p + u)))))
    (hsr : ∀ u < 2, cells (sh.bytes (5 + thOf g s i * 10 + 4)) (4 * u) 4 =
      wordBytes 4 (Val.f32Bits (scale I.S (136 * splitOf g s + (2 * p + u)))))
    (hm : Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh)
    (hacc : ∀ th, accOk th → th ≠ thOf g s i)
    (hA : AccArr C k il I g s i (2 * p) (sh.bytes (5 + thOf g s i * 10 + 1))) :
    ∃ l' sh', Exec C ctx [.set 39 (u32l 0), .loop (ltU 39 2) (stepU 39 1) (pairRowBody k sf)] l sh .normal l' sh' ∧
      PairLoc k sf il g s i p l' ∧ Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh' ∧
      (∀ r, r ≠ 5 + thOf g s i * 10 + 1 → r ≠ 5 + thOf g s i * 10 + 5 → r ≠ 5 + thOf g s i * 10 + 6 →
        sh'.bytes r = sh.bytes r) ∧
      AccArr C k il I g s i (2 * p + 2) (sh'.bytes (5 + thOf g s i * 10 + 1)) := by
  let J : Nat → Locals → Shared → Prop := fun u l' sh' => PairLoc k sf il g s i p l' ∧ l' 39 = some (u32 u) ∧
    Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh' ∧
    (∀ r, r ≠ 5 + thOf g s i * 10 + 1 → r ≠ 5 + thOf g s i * 10 + 5 → r ≠ 5 + thOf g s i * 10 + 6 →
      sh'.bytes r = sh.bytes r) ∧
    AccArr C k il I g s i (2 * p + u) (sh'.bytes (5 + thOf g s i * 10 + 1))
  obtain ⟨l', sh', hex, hJ⟩ := Exec.loop_count (c := ltU 39 2) (st := stepU 39 1) (b := pairRowBody k sf) (ctx := ctx)
    (C := C) 2 J J
    (fun u hu l' sh' hJ => ⟨sh', eval_lt_u32 C (ctx := ctx) (sh := sh') (b := 2) hJ.2.1 (by omega) (by decide), hJ⟩)
    (fun u hu l' sh' hJ => by
      obtain ⟨hP', h39, hm', hoth, hA'⟩ := hJ
      obtain ⟨l₁, sh₁, x1, hP₁, h39₁, hm₁, hoth₁, hA₁⟩ := pair_row C hS hG hl hu hP' h39
        (fun m hm => by rw [hoth _ (by omega) (by omega) (by omega)]; exact hld u hu m hm)
        (by rw [hoth _ (by omega) (by omega) (by omega)]; exact hxr u hu)
        (by rw [hoth _ (by omega) (by omega) (by omega)]; exact hsr u hu) hm' hacc hA'
      refine ⟨.normal, l₁, sh₁, setLocal l₁ 39 (u32 (u + 1)), sh₁, .inl rfl, x1,
        .set (eval_bin_u32 C (eval_local' C h39₁ _) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C u 1)) (.nil _ _),
        hP₁.of_eq fun j hj => setLocal_other _ _ (by omega), setLocal_same _ _ _, hm₁,
        fun r h1 h5 h6 => by rw [hoth₁ r h1 h5 h6, hoth r h1 h5 h6], by rw [← Nat.add_assoc]; exact hA₁⟩)
    (l := setLocal l 39 (u32 0)) (sh := sh)
    ⟨hP.of_eq fun j hj => setLocal_other _ _ (by omega), setLocal_same _ _ _, hm, fun _ _ _ _ => rfl,
      by rw [Nat.add_zero]; exact hA⟩
  exact ⟨l', sh', .set (eval_u32lit C _ _ 0 (by decide)) hex, hJ.1, hJ.2.2.1, hJ.2.2.2.1, hJ.2.2.2.2⟩

end Rows

/-! ### The pair loop -/

/-- The first `n` rows of pair `p` loaded: `ld[u]`, `xr[u]`, `sr[u]`. -/
structure LdArr (C : M1Max.Contract) (K : Nat) (sf il : Bool) (I : In) (g s i p n : Nat) (B : Nat → ByteMemory.Bytes) :
    Prop where
  words : ∀ u < n, ∀ m < nl K sf, cells (B (5 + thOf g s i * 10 + 2)) (4 * (u * nl K sf + m)) 4 =
    wordBytes 4 (ldWord K I.Cd (dbase K il (136 * splitOf g s + (2 * p + u)) (blkOf g s i)) (i % 16) m)
  xs : ∀ u < n, cells (B (5 + thOf g s i * 10 + 3)) (4 * u) 4 =
    wordBytes 4 (Val.f32Bits (xr C I.X (136 * splitOf g s + (2 * p + u))))
  ss : ∀ u < n, cells (B (5 + thOf g s i * 10 + 4)) (4 * u) 4 =
    wordBytes 4 (Val.f32Bits (scale I.S (136 * splitOf g s + (2 * p + u))))

theorem dbase_lt {k : Nat} {sf il : Bool} (hG : Geo k sf il) {R blk j : Nat} (hR : R < 17408) (hblk : blk < 20)
    (hj : j < wpb k) : dbase k il R blk + j < 17408 * 160 * k := by
  rw [dbase_eq]; unfold blockOff roww wpb at *
  rcases hG with ⟨rfl, -, rfl⟩ | ⟨rfl, -, rfl⟩ | ⟨rfl, -, rfl⟩ <;> simp only [ite_true, Bool.false_eq_true, ite_false] <;>
    omega

section Pairs
variable (C : M1Max.Contract) {ctx : Ctx} {L : Launch} {k : Nat} {sf il : Bool} {I : In}
  {accV : Nat → Nat → Float32} {sumsV outV : Nat → Float32} {g s i : Nat} {accOk outOk : Nat → Prop}

/-- Row `u` of pair `p` loaded. -/
theorem row_load (hS : Shape L k sf I) (hG : Geo k sf il) (hl : Lane ctx g s i) {p u : Nat} (hp : p < 68) (hu : u < 2)
    {l : Locals} {sh : Shared} (hP : PairLoc k sf il g s i p l) (h36 : l 36 = some (u32 u))
    (hidx : GateUp.Words (sh.bytes (5 + thOf g s i * 10)) (nl k sf) (fun m => (firstOf k (i % 16) + m) % wpb k))
    (hm : Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh)
    (hacc : ∀ th, accOk th → th ≠ thOf g s i) (hA : LdArr C k sf il I g s i p u sh.bytes) :
    ∃ l' sh', Exec C ctx (loadRowBody k sf il) l sh .normal l' sh' ∧ (∀ j, j ≤ 36 → l' j = l j) ∧
      Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh' ∧
      (∀ r, r ≠ 5 + thOf g s i * 10 + 2 → r ≠ 5 + thOf g s i * 10 + 3 → r ≠ 5 + thOf g s i * 10 + 4 →
        sh'.bytes r = sh.bytes r) ∧
      LdArr C k sf il I g s i p (u + 1) sh'.bytes := by
  have hb := geo_bounds hG
  have hg := hl.hg; have hs := hl.hs; have hi := hl.hi
  have hnl : nl k sf ≤ 4 ∧ 1 ≤ nl k sf := by
    unfold nl na; rcases hG with ⟨rfl, rfl, -⟩ | ⟨rfl, rfl, -⟩ | ⟨rfl, rfl, -⟩ <;> decide
  have hun : u * nl k sf + nl k sf ≤ 2 * nl k sf := by rcases (show u = 0 ∨ u = 1 by omega) with rfl | rfl <;> omega
  have hsplit : splitOf g s < 128 := by unfold splitOf; omega
  have hblk : blkOf g s i < 20 := by unfold blkOf colGroupOf; omega
  obtain ⟨R, hRdef⟩ : ∃ R, R = 136 * splitOf g s + (2 * p + u) := ⟨_, rfl⟩
  have hR : R < 17408 := by omega
  have hrw : roww k il ≤ 640 := by
    unfold roww wpb; rcases hG with ⟨rfl, -, rfl⟩ | ⟨rfl, -, rfl⟩ | ⟨rfl, -, rfl⟩ <;> decide
  have hrow : ∀ (lx : Locals) (shx : Shared), lx 27 = l 27 → lx 32 = l 32 → lx 36 = l 36 →
      (eval C ctx lx (pairRow 36)).run shx = some (u32 R, shx) := by
    intro lx shx h27 h32 h36'
    have := eval_bin_u32 C (ctx := ctx) (sh := shx) (op := .add) (site := 0)
      (eval_bin_u32 C (op := .add) (site := 0) (eval_local' C (h27.trans hP.ploc.l27) shx)
        (eval_local' C (h32.trans hP.l32) shx) (binary_add_u32 C _ _)) (eval_local' C (h36'.trans h36) shx)
      (binary_add_u32 C _ u)
    rwa [show splitOf g s * 136 + 2 * p + u = R by omega] at this
  -- rowWords
  have e37 : (eval C ctx l (.offset (.local 22) (.bin .mul .u64 0 (.conv .u64 (pairRow 36)) (u64l (roww k il))))).run sh =
      some (.ptr ⟨1, ((4 * dbase k il R (blkOf g s i) : Nat) : Int), .scalar .u32⟩, sh) := by
    have hlt : R * roww k il < 2 ^ 64 := by have := Nat.mul_le_mul (le_of_lt hR) hrw; omega
    have := eval_offset_u64 C (ctx := ctx) (o := blockOff k il (blkOf g s i) * 4)
      (i := .bin .mul .u64 0 (.conv .u64 (pairRow 36)) (u64l (roww k il))) (eval_local' C hP.ploc.geom.l22 sh)
      (eval_int C (by decide) (eval_conv C (t := .u64) (hrow l sh rfl rfl rfl) (convert_u64_u32 C _ (by omega)))
        (eval_u64lit C _ _ _ (by omega)) (binary_mul_u64 C _ _)) hlt
    rwa [show blockOff k il (blkOf g s i) * 4 + R * roww k il * (Ty.scalar .u32).bytes = 4 * dbase k il R (blkOf g s i) by
      rw [dbase_eq]; simp [Ty.bytes, Scalar.bytes]; ring] at this
  generalize hl₁ : setLocal l 37 (.ptr ⟨1, ((4 * dbase k il R (blkOf g s i) : Nat) : Int), .scalar .u32⟩) = l₁
  have hb₁ : ∀ j, j ≠ 37 → l₁ j = l j := fun j hj => by rw [← hl₁, setLocal_other _ _ hj]
  -- ld[u]
  have he : ∀ (l' : Locals) (sh' : Shared) (m : Nat), m < nl k sf → l' 38 = some (u32 m) → (∀ j, j ≠ 38 → l' j = l₁ j) →
      (Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh' ∧
        sh'.bytes (5 + thOf g s i * 10) = sh.bytes (5 + thOf g s i * 10)) →
      ∃ sh'', (eval C ctx l' (.load (.scalar .u32) (.offset (.local 37)
          (.load (.scalar .u32) (.offset (.local 25) (.local 38)))))).run sh' =
          some (u32 (ldWord k I.Cd (dbase k il R (blkOf g s i)) (i % 16) m), sh'') ∧
        (Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh'' ∧
          sh''.bytes (5 + thOf g s i * 10) = sh.bytes (5 + thOf g s i * 10)) ∧ sh''.bytes = sh'.bytes := by
    intro l' sh' m hm' hc hag hI
    have hreg := hI.1.regions
    obtain ⟨j, hj⟩ : ∃ j, j = (firstOf k (i % 16) + m) % wpb k := ⟨_, rfl⟩
    have hjl : j < wpb k := by rw [hj]; exact Nat.mod_lt _ (by omega)
    have hix : (eval C ctx l' (.load (.scalar .u32) (.offset (.local 25) (.local 38)))).run sh' = some (u32 j, sh') := by
      have hp := eval_ptr_u32 C (ctx := ctx)
        (eval_local' C (by rw [hag 25 (by decide), hb₁ 25 (by decide)]; exact hP.ploc.l25) sh') (eval_local' C hc sh')
        (by omega)
      rw [show m * (Ty.scalar .u32).bytes = 4 * m by simp [Ty.bytes, Scalar.bytes]; ring] at hp
      rw [eval_load C _ _ _ _ _ _ _ hp, hj]
      exact GateUp.Words.load (ctx := ctx) (reg := 5 + thOf g s i * 10) (by rw [hreg]; exact hS.ridx _) (by rw [hI.2]; exact hidx) le_rfl m hm'
    have hd := dbase_lt hG (R := R) (blk := blkOf g s i) hR hblk hjl
    have hp := eval_offset_u32 C (ctx := ctx) (eval_local' C (by rw [hag 37 (by decide), ← hl₁, setLocal_same]) sh') hix
      (by omega)
    rw [show 4 * dbase k il R (blkOf g s i) + j * (Ty.scalar .u32).bytes = 4 * (dbase k il R (blkOf g s i) + j) by
      simp [Ty.bytes, Scalar.bytes]; ring] at hp
    have hload := load_shared ctx .u32 sh' 1 (4 * (dbase k il R (blkOf g s i) + j)) _ (by rw [hreg]; exact hS.r1) (by simp)
      (by simpa [Scalar.bytes] using hS.ac) (by simp [Scalar.bytes]) (by simp [Scalar.bytes, codesBytes]; omega)
      (by simp [loadOffset])
    rw [hI.1.cd] at hload
    have hv : Val.ofWord .u32 (bytesWord (cells I.Cd (4 * (dbase k il R (blkOf g s i) + j)) Scalar.u32.bytes)) =
        u32 (ldWord k I.Cd (dbase k il R (blkOf g s i)) (i % 16) m) := by rw [hj]; rfl
    rw [hv] at hload
    exact ⟨_, (eval_load C _ _ _ _ _ _ _ hp).trans hload,
      ⟨hI.1.rd hS ctx 1 _ _ (.inl (by decide)), by rw [rdn_bytes]; exact hI.2⟩, rdn_bytes _ _ _ _ _⟩
  obtain ⟨l₃, sh₃, x3, ⟨hm₃, -⟩, hag₃, hoth₃, hkeep₃, hw₃⟩ := exec_fillAt C (ctx := ctx)
    (Inv := fun sh' => Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh' ∧
      sh'.bytes (5 + thOf g s i * 10) = sh.bytes (5 + thOf g s i * 10))
    (reg := 5 + thOf g s i * 10 + 2) (l := l₁) (sh := sh) (size := 4 * (2 * nl k sf)) (q := u * nl k sf)
    (fun sh o bs h => ⟨h.1.tput o bs (by omega) (fun th h' => by have := hacc th h'; unfold thOf at this ⊢; omega),
      by rw [tput_other _ _ _ (by omega)]; exact h.2⟩)
    .u32 rfl (nl k sf) 38 (ldRow (nl k sf) 36)
    (.load (.scalar .u32) (.offset (.local 37) (.load (.scalar .u32) (.offset (.local 25) (.local 38)))))
    (fun m => u32 (ldWord k I.Cd (dbase k il R (blkOf g s i)) (i % 16) m))
    (fun m => wordBytes 4 (ldWord k I.Cd (dbase k il R (blkOf g s i)) (i % 16) m))
    (fun l' sh' hag _ => eval_ldRow C (ctx := ctx) (n := nl k sf) (us := 36) (u := u)
      (by rw [hag 33 (by decide), hb₁ 33 (by decide)]; exact hP.l33)
      (by rw [hag 36 (by decide), hb₁ 36 (by decide)]; exact h36) (by omega) (by omega))
    he (fun m => encode_u32 _ (ldWord_lt _ _ _ _ _)) (fun m => wordBytes_length 4 _)
    (fun sh' h => by rw [h.1.regions]; exact hS.rld _) (by omega) (by omega) ⟨hm, rfl⟩
  have hl₃ : ∀ j, j ≠ 37 → j ≠ 38 → l₃ j = l j := fun j h7 h8 => by rw [hag₃ j h8, hb₁ j h7]
  -- xr[u]
  have hreg₃ := hm₃.regions
  have hp34 := eval_ptr_u32 C (ctx := ctx) (l := l₃) (sh := sh₃)
    (eval_local' C (i := 34) (by rw [hl₃ 34 (by decide) (by decide)]; exact hP.l34) sh₃)
    (eval_local' C (i := 36) (by rw [hl₃ 36 (by decide) (by decide)]; exact h36) sh₃) (by omega)
  rw [show u * (Ty.scalar .f32).bytes = 4 * u by simp [Ty.bytes, Scalar.bytes]; ring] at hp34
  have hx : (eval C ctx l₃ (.conv .f32 (.load (.scalar .bf16) (.offset (.local 0) (pairRow 36))))).run sh₃ =
      some (.f32 (xr C I.X R), rdn ctx sh₃ 0 (2 * R) 2) := by
    have hp0 := eval_ptr_u32 C (ctx := ctx) (l := l₃) (sh := sh₃)
      (eval_local' C (i := 0) (by rw [hl₃ 0 (by decide) (by decide)]; exact hP.ploc.geom.fix1.l0) sh₃)
      (hrow l₃ sh₃ (hl₃ 27 (by decide) (by decide)) (hl₃ 32 (by decide) (by decide)) (hl₃ 36 (by decide) (by decide)))
      (by omega)
    rw [show R * (Ty.scalar .bf16).bytes = 2 * R by simp [Ty.bytes, Scalar.bytes]; ring] at hp0
    have hld := load_shared ctx .bf16 sh₃ 0 (2 * R) _ (by rw [hreg₃]; exact hS.r0) (by simp)
      (by simpa [Scalar.bytes] using hS.ax) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset])
    rw [hm₃.x] at hld
    exact eval_conv C (t := .f32) ((eval_load C _ _ _ _ _ _ _ hp0).trans hld) rfl
  have hm₄ := hm₃.rd hS ctx 0 (2 * R) 2 (.inl (by decide))
  have hst4 := store_thread ctx .f32 (rdn ctx sh₃ 0 (2 * R) 2) (5 + thOf g s i * 10 + 3) (4 * u) 8 4 (.f32 (xr C I.X R))
    (wordBytes 4 (Val.f32Bits (xr C I.X R))) (by rw [rdn_regions, hreg₃]; exact hS.rxr _) (by decide)
    (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (encode_f32 _)
  generalize hsh₅ : tput (rdn ctx sh₃ 0 (2 * R) 2) (5 + thOf g s i * 10 + 3) (4 * u) (wordBytes 4 (Val.f32Bits (xr C I.X R))) =
    sh₅ at hst4
  have hm₅ : Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh₅ := by
    rw [← hsh₅]; exact hm₄.tput _ _ (by omega) (fun th h => by have := hacc th h; unfold thOf at this ⊢; omega)
  -- sr[u]
  have hreg₅ := hm₅.regions
  have hp35 := eval_ptr_u32 C (ctx := ctx) (l := l₃) (sh := sh₅)
    (eval_local' C (i := 35) (by rw [hl₃ 35 (by decide) (by decide)]; exact hP.l35) sh₅)
    (eval_local' C (i := 36) (by rw [hl₃ 36 (by decide) (by decide)]; exact h36) sh₅) (by omega)
  rw [show u * (Ty.scalar .f32).bytes = 4 * u by simp [Ty.bytes, Scalar.bytes]; ring] at hp35
  have hsc : (eval C ctx l₃ (.conv .f32 (.load (.scalar .f16) (.offset (.local 2) (pairRow 36))))).run sh₅ =
      some (.f32 (scale I.S R), rdn ctx sh₅ 2 (2 * R) 2) := by
    have hp2 := eval_ptr_u32 C (ctx := ctx) (l := l₃) (sh := sh₅)
      (eval_local' C (i := 2) (by rw [hl₃ 2 (by decide) (by decide)]; exact hP.ploc.geom.fix1.l2) sh₅)
      (hrow l₃ sh₅ (hl₃ 27 (by decide) (by decide)) (hl₃ 32 (by decide) (by decide)) (hl₃ 36 (by decide) (by decide)))
      (by omega)
    rw [show R * (Ty.scalar .f16).bytes = 2 * R by simp [Ty.bytes, Scalar.bytes]; ring] at hp2
    have hld := load_shared ctx .f16 sh₅ 2 (2 * R) _ (by rw [hreg₅]; exact hS.r2) (by simp)
      (by simpa [Scalar.bytes] using hS.as) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset])
    rw [hm₅.sc] at hld
    exact eval_conv C (t := .f32) ((eval_load C _ _ _ _ _ _ _ hp2).trans hld) rfl
  have hm₆ := hm₅.rd hS ctx 2 (2 * R) 2 (.inl (by decide))
  have hst6 := store_thread ctx .f32 (rdn ctx sh₅ 2 (2 * R) 2) (5 + thOf g s i * 10 + 4) (4 * u) 8 4 (.f32 (scale I.S R))
    (wordBytes 4 (Val.f32Bits (scale I.S R))) (by rw [rdn_regions, hreg₅]; exact hS.rsr _) (by decide)
    (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (encode_f32 _)
  have hm₇ := hm₆.tput (4 * u) (wordBytes 4 (Val.f32Bits (scale I.S R))) (show 5 ≤ 5 + thOf g s i * 10 + 4 by omega)
    (fun th h => by have := hacc th h; unfold thOf at this ⊢; omega)
  have hb₅ : ∀ r, r ≠ 5 + thOf g s i * 10 + 3 → sh₅.bytes r = sh₃.bytes r := fun r h => by
    rw [← hsh₅, tput_other _ _ _ h, rdn_bytes]
  refine ⟨l₃, _, ?_, fun j hj => hl₃ j (by omega) (by omega), hm₇, fun r h2 h3 h4 => ?_, ?_⟩
  · exact .set e37 (by rw [hl₁]; exact x3.append (.store hp34 hx hst4 (.store hp35 hsc hst6 (.nil _ _))))
  · rw [tput_other _ _ _ h4, rdn_bytes, hb₅ r h3, hoth₃ r h2]
  · refine ⟨fun u' hu' m hm' => ?_, fun u' hu' => ?_, fun u' hu' => ?_⟩
    · rw [tput_other _ _ _ (by omega), rdn_bytes, hb₅ _ (by omega)]
      by_cases hue : u' = u
      · subst hue; rw [hw₃ m hm', ← hRdef]
      · have hlt : u' < u := by omega
        have : u' * nl k sf + m + 1 ≤ u * nl k sf := by
          rcases (show u = 1 by omega) with rfl; rcases (show u' = 0 by omega) with rfl; omega
        rw [hkeep₃ _ (.inl (by omega))]; exact hA.words u' hlt m hm'
    · rw [tput_other _ _ _ (by omega), rdn_bytes, ← hsh₅, tput_same, rdn_bytes]
      by_cases hue : u' = u
      · subst hue
        have := cells_writeBytes_same (sh₃.bytes (5 + thOf g s i * 10 + 3)) (4 * u') (wordBytes 4 (Val.f32Bits (xr C I.X R)))
        rw [wordBytes_length] at this; rw [this, hRdef]
      · rw [cells_writeBytes_other _ _ _ _ _ (by rw [wordBytes_length]; omega), hoth₃ _ (by omega)]
        exact hA.xs u' (by omega)
    · rw [tput_same, rdn_bytes]
      by_cases hue : u' = u
      · subst hue
        have := cells_writeBytes_same (sh₅.bytes (5 + thOf g s i * 10 + 4)) (4 * u') (wordBytes 4 (Val.f32Bits (scale I.S R)))
        rw [wordBytes_length] at this; rw [this, hRdef]
      · rw [cells_writeBytes_other _ _ _ _ _ (by rw [wordBytes_length]; omega), hb₅ _ (by omega), hoth₃ _ (by omega)]
        exact hA.ss u' (by omega)

end Pairs

section AddAcc
variable {C : M1Max.Contract} {L : Launch} {I : In} {accV : Nat → Nat → Float32} {sumsV outV : Nat → Float32}
  {ge : Nat} {cbOk sumsOk accOk outOk : Nat → Prop}

/-- Thread `th`'s accumulators, `accV th`, join the kept ones. -/
theorem Mem.addAcc {sh : Shared} (h : Mem C L I accV sumsV outV ge cbOk sumsOk accOk outOk sh) (th : Nat)
    (hA : ∀ m < 16, cells (sh.bytes (5 + th * 10 + 1)) (4 * m) 4 = wordBytes 4 (Val.f32Bits (accV th m))) :
    Mem C L I accV sumsV outV ge cbOk sumsOk (fun t => accOk t ∨ t = th) outOk sh :=
  ⟨h.regions, h.x, h.cd, h.sc, h.deve, h.grpe, h.cb, h.sums, fun t ht j hj => by
    rcases ht with ht | rfl
    · exact h.acc t ht j hj
    · exact hA j hj, h.out, h.log⟩

end AddAcc

section Loop
variable (C : M1Max.Contract) {ctx : Ctx} {L : Launch} {k : Nat} {sf il : Bool} {I : In}
  {accV : Nat → Nat → Float32} {sumsV outV : Nat → Float32} {g s i : Nat} {accOk outOk : Nat → Prop}

/-- Both rows of pair `p` loaded. -/
theorem load_rows (hS : Shape L k sf I) (hG : Geo k sf il) (hl : Lane ctx g s i) {p : Nat} (hp : p < 68)
    {l : Locals} {sh : Shared} (hP : PairLoc k sf il g s i p l)
    (hidx : GateUp.Words (sh.bytes (5 + thOf g s i * 10)) (nl k sf) (fun m => (firstOf k (i % 16) + m) % wpb k))
    (hm : Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh)
    (hacc : ∀ th, accOk th → th ≠ thOf g s i) :
    ∃ l' sh', Exec C ctx [.set 36 (u32l 0), loadRowLoop k sf il] l sh .normal l' sh' ∧ (∀ j, j ≤ 35 → l' j = l j) ∧
      Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh' ∧
      (∀ r, r ≠ 5 + thOf g s i * 10 + 2 → r ≠ 5 + thOf g s i * 10 + 3 → r ≠ 5 + thOf g s i * 10 + 4 →
        sh'.bytes r = sh.bytes r) ∧
      LdArr C k sf il I g s i p 2 sh'.bytes := by
  let J : Nat → Locals → Shared → Prop := fun u l' sh' => (∀ j, j ≤ 35 → l' j = l j) ∧ l' 36 = some (u32 u) ∧
    Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh' ∧
    (∀ r, r ≠ 5 + thOf g s i * 10 + 2 → r ≠ 5 + thOf g s i * 10 + 3 → r ≠ 5 + thOf g s i * 10 + 4 →
      sh'.bytes r = sh.bytes r) ∧
    LdArr C k sf il I g s i p u sh'.bytes
  obtain ⟨l', sh', hex, hJ⟩ := Exec.loop_count (c := ltU 36 2) (st := stepU 36 1) (b := loadRowBody k sf il)
    (ctx := ctx) (C := C) 2 J J
    (fun u hu l' sh' hJ => ⟨sh', eval_lt_u32 C (ctx := ctx) (sh := sh') (b := 2) hJ.2.1 (by omega) (by decide), hJ⟩)
    (fun u hu l' sh' hJ => by
      obtain ⟨hag, h36, hm', hoth, hA⟩ := hJ
      obtain ⟨l₁, sh₁, x1, hag₁, hm₁, hoth₁, hA₁⟩ := row_load C hS hG hl hp hu (hP.of_eq hag) h36
        (by rw [hoth _ (by omega) (by omega) (by omega)]; exact hidx) hm' hacc hA
      refine ⟨.normal, l₁, sh₁, setLocal l₁ 36 (u32 (u + 1)), sh₁, .inl rfl, x1,
        .set (eval_bin_u32 C (eval_local' C ((hag₁ 36 (by omega)).trans h36) _) (eval_u32lit C _ _ 1 (by decide))
          (binary_add_u32 C u 1)) (.nil _ _),
        fun j hj => by rw [setLocal_other _ _ (by omega), hag₁ j (by omega), hag j hj], setLocal_same _ _ _, hm₁,
        fun r h2 h3 h4 => by rw [hoth₁ r h2 h3 h4, hoth r h2 h3 h4], hA₁⟩)
    (l := setLocal l 36 (u32 0)) (sh := sh)
    ⟨fun j hj => setLocal_other _ _ (by omega), setLocal_same _ _ _, hm, fun _ _ _ _ => rfl,
      ⟨fun u h => absurd h (by omega), fun u h => absurd h (by omega), fun u h => absurd h (by omega)⟩⟩
  exact ⟨l', sh', .set (eval_u32lit C _ _ 0 (by decide)) hex, hJ.1, hJ.2.2.1, hJ.2.2.2.1, hJ.2.2.2.2⟩

theorem pairBody_eq (k : Nat) (sf il : Bool) : pairBody k sf il =
    [.array 33 false 2 (.scalar .u32), .array 34 false 3 (.scalar .f32), .array 35 false 4 (.scalar .f32)] ++
      ([.set 36 (u32l 0), loadRowLoop k sf il] ++ [.set 39 (u32l 0), .loop (ltU 39 2) (stepU 39 1) (pairRowBody k sf)]) :=
  rfl

/-- The lane's own thread arrays: `ld`, `xr`, `sr`, `w`, `v` and `acc`. -/
def Own (g s i r : Nat) : Prop := 5 + thOf g s i * 10 + 1 ≤ r ∧ r ≤ 5 + thOf g s i * 10 + 6

/-- Pair `p`: its rows loaded, then accumulated. -/
theorem pair_body (hS : Shape L k sf I) (hG : Geo k sf il) (hl : Lane ctx g s i) {p : Nat} (hp : p < 68)
    {l : Locals} {sh : Shared} (hP : PLoc k sf il g s i l) (h32 : l 32 = some (u32 (2 * p)))
    (hidx : GateUp.Words (sh.bytes (5 + thOf g s i * 10)) (nl k sf) (fun m => (firstOf k (i % 16) + m) % wpb k))
    (hm : Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh)
    (hacc : ∀ th, accOk th → th ≠ thOf g s i)
    (hA : AccArr C k il I g s i (2 * p) (sh.bytes (5 + thOf g s i * 10 + 1))) :
    ∃ l' sh', Exec C ctx (pairBody k sf il) l sh .normal l' sh' ∧ PLoc k sf il g s i l' ∧ l' 32 = some (u32 (2 * p)) ∧
      Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh' ∧
      (∀ r, ¬ Own g s i r → sh'.bytes r = sh.bytes r) ∧
      AccArr C k il I g s i (2 * p + 2) (sh'.bytes (5 + thOf g s i * 10 + 1)) := by
  generalize hl₁ : setLocal (setLocal (setLocal l 33 (.ptr ⟨5 + thOf g s i * 10 + 2, 0, .scalar .u32⟩)) 34
    (.ptr ⟨5 + thOf g s i * 10 + 3, 0, .scalar .f32⟩)) 35 (.ptr ⟨5 + thOf g s i * 10 + 4, 0, .scalar .f32⟩) = l₁
  have x1 : Exec C ctx [.array 33 false 2 (.scalar .u32), .array 34 false 3 (.scalar .f32),
      .array 35 false 4 (.scalar .f32)] l sh .normal l₁ sh := by
    rw [← hl₁]
    refine .array ?_
    simp only [Bool.false_eq_true, ↓reduceIte]
    refine .array ?_
    simp only [Bool.false_eq_true, ↓reduceIte]
    refine .array ?_
    simp only [Bool.false_eq_true, ↓reduceIte]
    rw [hl.ta, hl.ta, hl.ta]
    exact .nil _ _
  have hP₁ : PairLoc k sf il g s i p l₁ := by
    rw [← hl₁]
    exact ⟨hP.of_eq fun j hj => by simp (disch := omega) only [setLocal_lt],
      by simp (disch := omega) only [setLocal_lt]; exact h32, by simp [setLocal], by simp [setLocal], by simp [setLocal]⟩
  obtain ⟨l₂, sh₂, x2, hag₂, hm₂, hoth₂, hld₂⟩ := load_rows C hS hG hl hp hP₁ hidx hm hacc
  obtain ⟨l₃, sh₃, x3, hP₃, hm₃, hoth₃, hA₃⟩ := pair_rows C hS hG hl (p := p) (hP₁.of_eq hag₂) hld₂.words hld₂.xs
    hld₂.ss hm₂ hacc (by rw [hoth₂ _ (by omega) (by omega) (by omega)]; exact hA)
  refine ⟨l₃, sh₃, ?_, hP₃.ploc, hP₃.l32, hm₃, fun r hr => ?_, hA₃⟩
  · rw [pairBody_eq]; exact x1.append (x2.append x3)
  · unfold Own at hr
    rw [hoth₃ r (by omega) (by omega) (by omega), hoth₂ r (by omega) (by omega) (by omega)]

/-- `for (; r + 2 <= rows; r += 2)`: the 68 pairs of the split's 136 rows. -/
theorem pair_loop (hS : Shape L k sf I) (hG : Geo k sf il) (hl : Lane ctx g s i)
    {l : Locals} {sh : Shared} (hP : PLoc k sf il g s i l) (h32 : l 32 = some (u32 0))
    (hidx : GateUp.Words (sh.bytes (5 + thOf g s i * 10)) (nl k sf) (fun m => (firstOf k (i % 16) + m) % wpb k))
    (hm : Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh)
    (hacc : ∀ th, accOk th → th ≠ thOf g s i)
    (hA : AccArr C k il I g s i 0 (sh.bytes (5 + thOf g s i * 10 + 1))) :
    ∃ l' sh', Exec C ctx [pairLoop k sf il] l sh .normal l' sh' ∧ PLoc k sf il g s i l' ∧ l' 32 = some (u32 136) ∧
      Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh' ∧
      (∀ r, ¬ Own g s i r → sh'.bytes r = sh.bytes r) ∧
      AccArr C k il I g s i 136 (sh'.bytes (5 + thOf g s i * 10 + 1)) := by
  let J : Nat → Locals → Shared → Prop := fun p l' sh' => PLoc k sf il g s i l' ∧ l' 32 = some (u32 (2 * p)) ∧
    Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh' ∧
    (∀ r, ¬ Own g s i r → sh'.bytes r = sh.bytes r) ∧
    AccArr C k il I g s i (2 * p) (sh'.bytes (5 + thOf g s i * 10 + 1))
  obtain ⟨l', sh', hex, hJ⟩ := Exec.loop_count (c := .bin .le .u32 0 (.bin .add .u32 0 (.local 32) (u32l 2)) (.local 28))
    (st := stepU 32 2) (b := pairBody k sf il) (ctx := ctx) (C := C) 68 J J
    (fun p hp l' sh' hJ => ⟨sh', by
      have := eval_bin_u32 C (ctx := ctx) (l := l') (sh := sh') (op := .le) (site := 0)
        (eval_bin_u32 C (op := .add) (site := 0) (eval_local' C hJ.2.1 sh') (eval_u32lit C _ _ 2 (by decide))
          (binary_add_u32 C _ 2)) (eval_local' C hJ.1.l28 sh') (binary_le_u32 C (2 * p + 2) 136 (by omega) (by decide))
      rwa [show decide (2 * p + 2 ≤ 136) = decide (p < 68) from decide_eq_decide.mpr (by omega)] at this, hJ⟩)
    (fun p hp l' sh' hJ => by
      obtain ⟨hP', h32', hm', hoth, hA'⟩ := hJ
      obtain ⟨l₁, sh₁, x1, hP₁, h32₁, hm₁, hoth₁, hA₁⟩ := pair_body C hS hG hl hp hP' h32'
        (by rw [hoth _ (by unfold Own; omega)]; exact hidx) hm' hacc hA'
      refine ⟨.normal, l₁, sh₁, setLocal l₁ 32 (u32 (2 * (p + 1))), sh₁, .inl rfl, x1,
        .set (by
          have := eval_bin_u32 C (ctx := ctx) (sh := sh₁) (op := .add) (site := 0) (eval_local' C h32₁ _)
            (eval_u32lit C _ _ 2 (by decide)) (binary_add_u32 C (2 * p) 2)
          rwa [show 2 * p + 2 = 2 * (p + 1) by ring] at this) (.nil _ _),
        hP₁.of_eq fun j hj => setLocal_other _ _ (by omega), setLocal_same _ _ _, hm₁,
        fun r hr => by rw [hoth₁ r hr, hoth r hr], by rw [show 2 * (p + 1) = 2 * p + 2 by ring]; exact hA₁⟩)
    (l := l) (sh := sh) ⟨hP, h32, hm, fun _ _ => rfl, hA⟩
  exact ⟨l', sh', hex, hJ.1, hJ.2.1, hJ.2.2.1, hJ.2.2.2.1, hJ.2.2.2.2⟩

/-- The code after the second barrier. -/
def rest2 (k : Nat) (sf il : Bool) : List CStmt := (body k sf il).drop 33

theorem rest1_split (k : Nat) (sf il : Bool) : rest1 k sf il =
    ((rest1 k sf il).take 12 ++ (setupRest k sf ++ [pairLoop k sf il, tailLoop k sf il])) ++
      .barrier 2 false true :: rest2 k sf il := rfl

/-- A lane accumulates its split's 136 rows and stops at the second barrier. -/
theorem lane_phase2 (hS : Shape L k sf I) (hG : Geo k sf il) (hl : Lane ctx g s i) {l : Locals} (hF : Fix1 l)
    {sh : Shared} (hm : Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) accOk outOk sh)
    (hacc : ∀ th, accOk th → th ≠ thOf g s i)
    (hV : ∀ m < 16, accV (thOf g s i) m = accSplit C k il I.Cd I.S I.X (splitOf g s) (colOf g s i m) 136) :
    ∃ t sh', (Ev fun n => (runThread C n ⟨ctx, l, [.block (rest1 k sf il)], .running⟩).run sh = some (t, sh')) ∧
      Mem C L I accV sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False) (fun th => accOk th ∨ th = thOf g s i)
        outOk sh' ∧
      t.status = .barrier 2 false true ∧ t.ctx = ctx ∧ t.frames = [.block (rest2 k sf il)] ∧
      PLoc k sf il g s i t.locals := by
  obtain ⟨l₁, x1, hgeo⟩ := lane_geom C hG hl (sh := sh) hF
  obtain ⟨l₂, sh₂, x2, hP₂, h32₂, hm₂, hidx₂, hA₂⟩ := lane_setupRest C hS hG hl (il := il) hgeo hm hacc
  obtain ⟨l₃, sh₃, x3, hP₃, h32₃, hm₃, -, hA₃⟩ := pair_loop C hS hG hl hP₂ h32₂ hidx₂ hm₂ hacc hA₂
  have x4 : Exec C ctx [tailLoop k sf il] l₃ sh₃ .normal l₃ sh₃ :=
    .loop_exit (eval_bin_u32 C (eval_local' C h32₃ sh₃) (eval_local' C hP₃.l28 sh₃)
      (binary_lt_u32 C 136 136 (by decide) (by decide))) (.nil _ _)
  have hex : Exec C ctx ((rest1 k sf il).take 12 ++ (setupRest k sf ++ [pairLoop k sf il, tailLoop k sf il])) l sh
      .normal l₃ sh₃ := x1.append (x2.append (x3.append x4))
  refine ⟨⟨ctx, l₃, [.block (rest2 k sf il)], .barrier 2 false true⟩, sh₃, ?_,
    hm₃.addAcc (thOf g s i) (fun m hm => by rw [hA₃ m hm, hV m hm]), rfl, rfl, rfl, hP₃⟩
  rw [rest1_split]
  exact (Exec.reaches_barrier (K := []) (rest := rest2 k sf il) (site := 2) (d := false) (g := true) hex).ev_stop rfl

end Loop

/-! ### After the second barrier: the sums -/

theorem sums_owner {s i m : Nat} (_hs : s < 8) (hi : i < 32) (hm : m < 16) :
    sumsIdx s i m < 4096 ∧ sumsOwner (sumsIdx s i m) = 32 * s + i ∧ (255 - sumsIdx s i m % 256) % 16 = m := by
  unfold sumsIdx sumsOwner; omega

theorem owner_sums {e s i : Nat} (he : e < 4096) (_hs : s < 8) (hi : i < 32) (ho : sumsOwner e = 32 * s + i) :
    e = sumsIdx s i ((255 - e % 256) % 16) := by
  unfold sumsIdx sumsOwner at *; omega

section Memory
variable {C : M1Max.Contract} {L : Launch} {k : Nat} {sf : Bool} {I : In} {accV : Nat → Nat → Float32}
  {sumsV outV : Nat → Float32} {g : Nat} {cbOk sumsOk accOk outOk : Nat → Prop} {sh : Shared}

/-- Thread `sumsOwner e` of threadgroup `g` writes `sums[e]` in its third epoch. -/
theorem Mem.wsum (h : Mem C L I accV sumsV outV (3 * g + 2) cbOk sumsOk accOk outOk sh) (hS : Shape L k sf I) (ctx : Ctx)
    (e : Nat) (he : e < 4096) (ht : ctx.thread = g * 256 + sumsOwner e) (hg : ctx.group = g) :
    Mem C L I accV sumsV outV (3 * g + 2) (fun _ => False) (fun e' => sumsOk e' ∨ e' = e) accOk outOk
      (wrn ctx sh 4 (4 * e) 4 (wordBytes 4 (Val.f32Bits (sumsV e)))) := by
  have hl : (wordBytes 4 (Val.f32Bits (sumsV e))).length = 4 := wordBytes_length 4 _
  refine ⟨h.regions, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.x, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.cd,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.sc, h.deve, h.grpe, fun _ _ hf => hf.elim, fun e' he' hc => ?_,
    fun th hth i hi => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.acc th hth i hi,
    fun E hE hc => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.out E hE hc,
    forall_log _ 4 _ (fun j hj => owned_group L dev tgo ctx sh 4 (4 * e + j) _ hS.r4 true rfl (by
      rw [h.grpe, hg, ht]; unfold tgo
      rw [ite_eq_left rfl, ite_eq_right (by omega), ite_eq_left rfl, show (4 * e + j) / 4 = e by omega])) h.log⟩
  rw [wrn_same]
  by_cases hee : e' = e
  · subst hee
    have := cells_writeBytes_same (sh.bytes 4) (4 * e') (wordBytes 4 (Val.f32Bits (sumsV e')))
    rwa [hl] at this
  · rw [cells_writeBytes_other _ _ _ _ _ (by rw [hl]; omega)]
    exact h.sums e' he' (hc.resolve_right hee)

end Memory

/-- The code after the third barrier. -/
def rest3 (k : Nat) (sf il : Bool) : List CStmt := (body k sf il).drop 38

/-- `local = (lane / LB) * 256u + 255u - li * P`. -/
def localExpr : CExpr :=
  .bin .sub .u32 0
    (.bin .add .u32 0 (.bin .mul .u32 0 (.bin .div .u32 0 (.local 13) (u32l 16)) (u32l 256)) (u32l 255))
    (.bin .mul .u32 0 (.local 19) (u32l 16))

theorem rest2_split (k : Nat) (sf il : Bool) : rest2 k sf il =
    ([.set 77 (.local 4), .set 78 localExpr] ++ [.set 79 (u32l 0), scatterLoop]) ++ .barrier 3 false true :: rest3 k sf il :=
  rfl

/-- After the sums: the geometry and `sums`. -/
structure Loc3 (K : Nat) (sf il : Bool) (g s i : Nat) (l : Locals) : Prop where
  geom : Geom K sf il g s i l
  l77 : l 77 = some (.ptr ⟨4, 0, .scalar .f32⟩)

theorem Loc3.of_eq {K : Nat} {sf il : Bool} {g s i : Nat} {l l' : Locals} (h : Loc3 K sf il g s i l)
    (h' : ∀ j, j ≤ 77 → l' j = l j) : Loc3 K sf il g s i l' :=
  ⟨h.geom.of_eq fun j hj => h' j (by omega), (h' 77 (by omega)).trans h.l77⟩

section Phase3
variable (C : M1Max.Contract) {ctx : Ctx} {L : Launch} {k : Nat} {sf il : Bool} {I : In}
  {accV : Nat → Nat → Float32} {sumsV outV : Nat → Float32} {g s i : Nat} {accOk outOk : Nat → Prop}

/-- Resumed at the second barrier, a lane scatters its accumulators into `sums` and stops at the third. -/
theorem lane_phase3 (hS : Shape L k sf I) (hl : Lane ctx g s i) {t : Thread}
    (ht : t.ctx = ctx ∧ t.frames = [.block (rest2 k sf il)] ∧ PLoc k sf il g s i t.locals) {sh : Shared}
    (hm : Mem C L I accV sumsV outV (3 * g + 2) (fun _ => False) (fun e => sumsOwner e < 32 * s + i) accOk outOk sh)
    (hown : accOk (thOf g s i)) (hsV : ∀ m < 16, sumsV (sumsIdx s i m) = accV (thOf g s i) m) :
    ∃ t' sh', (Ev fun n => (runThread C n { t with status := .running }).run sh = some (t', sh')) ∧
      Mem C L I accV sumsV outV (3 * g + 2) (fun _ => False) (fun e => sumsOwner e < 32 * s + i + 1) accOk outOk sh' ∧
      t'.status = .barrier 3 false true ∧ t'.ctx = ctx ∧ t'.frames = [.block (rest3 k sf il)] ∧
      Loc3 k sf il g s i t'.locals := by
  obtain ⟨tc, tl, tf, ts⟩ := t
  obtain ⟨hc, hf, hP⟩ := ht
  dsimp only at hc hf hP
  subst hc hf
  have hi := hl.hi; have hs := hl.hs; have hg := hl.hg
  have hgeo := hP.geom
  generalize hl₁ : setLocal (setLocal tl 77 (.ptr ⟨4, 0, .scalar .f32⟩)) 78 (u32 (i / 16 * 256 + 255 - i % 16 * 16)) = l₁
  have x1 : Exec C tc [.set 77 (.local 4), .set 78 localExpr] tl sh .normal l₁ sh := by
    rw [← hl₁]
    have h13 : setLocal tl 77 (.ptr ⟨4, 0, .scalar .f32⟩) 13 = some (u32 i) := by
      rw [setLocal_other _ _ (by omega)]; exact hgeo.l13
    have h19 : setLocal tl 77 (.ptr ⟨4, 0, .scalar .f32⟩) 19 = some (u32 (i % 16)) := by
      rw [setLocal_other _ _ (by omega)]; exact hgeo.l19
    exact .set (eval_local' C hgeo.fix1.l4 sh) (.set (eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C
      (eval_bin_u32 C (eval_local' C h13 sh) (eval_u32lit C _ _ 16 (by decide)) (binary_div_u32 C i 16 (by omega)
        (by decide) (by decide))) (eval_u32lit C _ _ 256 (by decide)) (binary_mul_u32 C _ 256))
      (eval_u32lit C _ _ 255 (by decide)) (binary_add_u32 C _ 255))
      (eval_bin_u32 C (eval_local' C h19 sh) (eval_u32lit C _ _ 16 (by decide)) (binary_mul_u32 C _ 16))
      (binary_sub_u32 C _ _ (by omega))) (.nil _ _))
  have hb₁ : ∀ j, j ≠ 77 → j ≠ 78 → l₁ j = tl j := fun j h7 h8 => by
    rw [← hl₁, setLocal_other _ _ h8, setLocal_other _ _ h7]
  have h77 : l₁ 77 = some (.ptr ⟨4, 0, .scalar .f32⟩) := by rw [← hl₁, setLocal_other _ _ (by omega), setLocal_same]
  have h78 : l₁ 78 = some (u32 (i / 16 * 256 + 255 - i % 16 * 16)) := by rw [← hl₁, setLocal_same]
  let J : Nat → Locals → Shared → Prop := fun m l' sh' => (∀ j, j ≠ 79 → l' j = l₁ j) ∧ l' 79 = some (u32 m) ∧
    Mem C L I accV sumsV outV (3 * g + 2) (fun _ => False)
      (fun e => sumsOwner e < 32 * s + i ∨ (sumsOwner e = 32 * s + i ∧ (255 - e % 256) % 16 < m)) accOk outOk sh'
  obtain ⟨l', sh', hex, hJ⟩ := Exec.loop_count (c := ltU 79 16) (st := stepU 79 1)
    (b := [.store (.scalar .f32)
      (.offset (.local 77)
        (.bin .sub .u32 0 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 14) (u32l 512)) (.local 78)) (.local 79)))
      (accAt 79)]) (ctx := tc) (C := C) 16 J J
    (fun m hm l' sh' hJ => ⟨sh', eval_lt_u32 C (ctx := tc) (sh := sh') (b := 16) hJ.2.1 (by omega) (by decide), hJ⟩)
    (fun m hm l' sh' hJ => by
      obtain ⟨hag, h79, hm'⟩ := hJ
      obtain ⟨he, hown', hmm⟩ := sums_owner hs hi hm
      have hreg := hm'.regions
      have h14 : l' 14 = some (u32 s) := by rw [hag 14 (by decide), hb₁ 14 (by decide) (by decide)]; exact hgeo.l14
      have hidx : (eval C tc l' (.bin .sub .u32 0 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 14) (u32l 512)) (.local 78))
          (.local 79))).run sh' = some (u32 (sumsIdx s i m), sh') :=
        eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h14 sh') (eval_u32lit C _ _ 512 (by decide)) (binary_mul_u32 C s 512))
          (eval_local' C (by rw [hag 78 (by decide)]; exact h78) sh') (binary_add_u32 C _ _))
          (eval_local' C h79 sh') (binary_sub_u32 C _ _ (by omega))
      have hp := eval_ptr_u32 C (ctx := tc) (eval_local' C (by rw [hag 77 (by decide)]; exact h77) sh') hidx (by omega)
      rw [show sumsIdx s i m * (Ty.scalar .f32).bytes = 4 * sumsIdx s i m by simp [Ty.bytes, Scalar.bytes]; ring] at hp
      have hpa := eval_ptr_u32 C (ctx := tc) (l := l') (sh := sh')
        (eval_local' C (i := 30) (by rw [hag 30 (by decide), hb₁ 30 (by decide) (by decide)]; exact hP.l30) sh')
        (eval_local' C h79 sh') (by omega)
      rw [show m * (Ty.scalar .f32).bytes = 4 * m by simp [Ty.bytes, Scalar.bytes]; ring] at hpa
      have hval : (eval C tc l' (accAt 79)).run sh' = some (.f32 (accV (thOf g s i) m), sh') := by
        rw [accAt, eval_load C _ _ _ _ _ _ _ hpa]
        exact load_f32_thread_cells (by rw [hreg]; exact hS.racc _) (by omega) (hm'.acc _ hown m hm)
      have hst := store_shared tc .f32 sh' 4 (4 * sumsIdx s i m) _ (.f32 (accV (thOf g s i) m))
        (wordBytes 4 (Val.f32Bits (accV (thOf g s i) m))) (by rw [hreg]; exact hS.r4) (by simp) (by simp)
        (by simp [Scalar.bytes]) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (encode_f32 _)
      simp only [Scalar.bytes] at hst
      have hm₁ := hm'.wsum hS tc (sumsIdx s i m) he (by rw [hl.thread, hown']) hl.group
      rw [hsV m hm] at hm₁
      refine ⟨.normal, l', _, setLocal l' 79 (u32 (m + 1)), _, .inl rfl, .store hp hval hst (.nil _ _),
        .set (eval_bin_u32 C (eval_local' C h79 _) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C m 1)) (.nil _ _),
        fun j hj => by rw [setLocal_other _ _ hj]; exact hag j hj, setLocal_same _ _ _,
        hm₁.mono (fun _ _ h => h) (fun e he' h => ?_) (fun _ h => h) (fun _ _ h => h)⟩
      rcases h with h | ⟨h1, h2⟩
      · exact .inl (.inl h)
      · by_cases hlt : (255 - e % 256) % 16 < m
        · exact .inl (.inr ⟨h1, hlt⟩)
        · have := owner_sums he' hs hi h1
          rw [show (255 - e % 256) % 16 = m by omega] at this
          exact .inr this)
    (l := setLocal l₁ 79 (u32 0)) (sh := sh)
    ⟨fun j hj => setLocal_other _ _ hj, setLocal_same _ _ _,
      hm.mono (fun _ _ h => h) (fun e _ h => by rcases h with h | ⟨-, h⟩ <;> omega) (fun _ h => h) (fun _ _ h => h)⟩
  obtain ⟨hag', -, hm'⟩ := hJ
  have hLoc : Loc3 k sf il g s i l' :=
    ⟨hgeo.of_eq fun j hj => by rw [hag' j (by omega), hb₁ j (by omega) (by omega)], by rw [hag' 77 (by omega)]; exact h77⟩
  refine ⟨⟨tc, l', [.block (rest3 k sf il)], .barrier 3 false true⟩, sh', ?_,
    hm'.mono (fun _ _ h => h) (fun e he h => ?_) (fun _ h => h) (fun _ _ h => h), rfl, rfl, rfl, hLoc⟩
  · show Ev fun n => (runThread C n ⟨tc, tl, [.block (rest2 k sf il)], .running⟩).run sh = _
    rw [rest2_split]
    exact (Exec.reaches_barrier (K := []) (rest := rest3 k sf il) (site := 3) (d := false) (g := true)
      (x1.append (.set (eval_u32lit C _ _ 0 (by decide)) hex))).ev_stop rfl
  · by_cases h' : sumsOwner e < 32 * s + i
    · exact .inl h'
    · exact .inr ⟨by omega, by omega⟩

end Phase3

/-! ### After the third barrier: the column sums -/

/-- `partial[y·5120 + col]` for column `c` of threadgroup `g`'s 1024. -/
def outIdx (g c : Nat) : Nat := g % 32 * 5120 + ((2 * (g / 32) + c / 512) * 512 + c % 512)

/-- `t` after `n` steps of the fold of column `c`: `t = sums[(group2 * 4 + k) * 512 + c % 512] + t`. -/
def colFold (C : M1Max.Contract) (sumsV : Nat → Float32) (c : Nat) : Nat → Float32
  | 0 => zero
  | n + 1 => C.fadd (sumsV ((c / 512 * 4 + n) * 512 + c % 512)) (colFold C sumsV c n)

theorem out_idx {g t m : Nat} (hg : g < 160) (ht : t < 256) (hm : m < 4) :
    outIdx g (t + 256 * m) < 163840 ∧ outGroup (outIdx g (t + 256 * m)) = g ∧
      outThread (outIdx g (t + 256 * m)) = t ∧ outIdx g (t + 256 * m) % 5120 % 1024 / 256 = m := by
  unfold outIdx outGroup outThread; omega

theorem idx_out {E g t : Nat} (hE : E < 163840) (hg : outGroup E = g) (ht : outThread E = t) :
    E = outIdx g (t + 256 * (E % 5120 % 1024 / 256)) := by
  unfold outIdx outGroup outThread at *; omega

section Memory
variable {C : M1Max.Contract} {L : Launch} {k : Nat} {sf : Bool} {I : In} {accV : Nat → Nat → Float32}
  {sumsV outV : Nat → Float32} {ge : Nat} {cbOk sumsOk accOk outOk : Nat → Prop} {sh : Shared}

/-- Thread `outThread E` of threadgroup `outGroup E` writes `partial` element `E`. -/
theorem Mem.wout (h : Mem C L I accV sumsV outV ge cbOk sumsOk accOk outOk sh) (hS : Shape L k sf I) (ctx : Ctx)
    (E : Nat) (hE : E < 163840) (ht : ctx.thread = outGroup E * 256 + outThread E) (hg : ctx.group = outGroup E) :
    Mem C L I accV sumsV outV ge cbOk sumsOk accOk (fun E' => outOk E' ∨ E' = E)
      (wrn ctx sh 3 (4 * E) 4 (wordBytes 4 (Val.f32Bits (outV E)))) := by
  have hl : (wordBytes 4 (Val.f32Bits (outV E))).length = 4 := wordBytes_length 4 _
  refine ⟨h.regions, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.x, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.cd,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.sc, h.deve, h.grpe,
    fun e he hc => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.cb e he hc,
    fun e he hc => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.sums e he hc,
    fun th hth i hi => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.acc th hth i hi, fun E' hE' hc => ?_,
    forall_log _ 4 _ (fun j hj => owned_device L dev tgo ctx sh 3 (4 * E + j) _ hS.r3 true (by simp)
      ⟨outGroup ((4 * E + j) / 4) * 256 + outThread ((4 * E + j) / 4), outGroup ((4 * E + j) / 4), 0⟩
      (by simp [dev]) (by rw [ht]; dsimp only; rw [show (4 * E + j) / 4 = E by omega])
      (by rw [hg]; dsimp only; rw [show (4 * E + j) / 4 = E by omega]) (by rw [h.deve])) h.log⟩
  rw [wrn_same]
  by_cases hEE : E' = E
  · subst hEE
    have := cells_writeBytes_same (sh.bytes 3) (4 * E') (wordBytes 4 (Val.f32Bits (outV E')))
    rwa [hl] at this
  · rw [cells_writeBytes_other _ _ _ _ _ (by rw [hl]; omega)]
    exact h.out E' hE' (hc.resolve_right hEE)

end Memory

section Phase4
variable (C : M1Max.Contract) {ctx : Ctx} {L : Launch} {k : Nat} {sf il : Bool} {I : In}
  {accV : Nat → Nat → Float32} {sumsV outV : Nat → Float32} {g s i : Nat} {cbOk accOk outOk : Nat → Prop}

theorem columnBody_eq : columnBody =
    [.set 81 (.bin .div .u32 0 (.local 80) (u32l 512)),
     .set 82 (.bin .add .u32 0 (.bin .mul .u32 0 (.bin .add .u32 0 groupBase (.local 81)) (u32l 512))
       (.bin .rem .u32 0 (.local 80) (u32l 512))), padStmt] ++
    ([.set 83 (f32l 0x0), .set 84 (u32l 0), foldLoop] ++
    [.store (.scalar .f32)
      (.offset (.local 3) (.bin .add .u64 0 (.bin .mul .u64 0 (.conv .u64 (.local 16)) (u64l 5120)) (.conv .u64 (.local 82))))
      (.local 83)]) := rfl

/-- Column `c`: its four sums folded, stored at `partial[y·5120 + col]`. -/
theorem column_body (hS : Shape L k sf I) (hl : Lane ctx g s i) {m : Nat} (hm4 : m < 4) {l : Locals} {sh : Shared}
    (hL : Loc3 k sf il g s i l) (h80 : l 80 = some (u32 (32 * s + i + 256 * m)))
    (hm : Mem C L I accV sumsV outV (3 * g + 3) cbOk (fun _ => True) accOk outOk sh)
    (hout : outV (outIdx g (32 * s + i + 256 * m)) = colFold C sumsV (32 * s + i + 256 * m) 4) :
    ∃ l' sh', Exec C ctx columnBody l sh .normal l' sh' ∧ (∀ j, j ≤ 80 → l' j = l j) ∧
      Mem C L I accV sumsV outV (3 * g + 3) cbOk (fun _ => True) accOk
        (fun E => outOk E ∨ E = outIdx g (32 * s + i + 256 * m)) sh' := by
  have hi := hl.hi; have hs := hl.hs; have hg := hl.hg
  have hgeo := hL.geom
  generalize hc : 32 * s + i + 256 * m = c at h80 hout ⊢
  have hcl : c < 1024 := by omega
  have hE := out_idx hg (show 32 * s + i < 256 by omega) hm4
  rw [hc] at hE
  -- group2, col, the padding test
  generalize hcol : (2 * (g / 32) + c / 512) * 512 + c % 512 = col
  have hcol5 : col < 5120 := by omega
  generalize hl₂ : setLocal (setLocal l 81 (u32 (c / 512))) 82 (u32 col) = l₂
  have x1 : Exec C ctx [.set 81 (.bin .div .u32 0 (.local 80) (u32l 512)),
      .set 82 (.bin .add .u32 0 (.bin .mul .u32 0 (.bin .add .u32 0 groupBase (.local 81)) (u32l 512))
        (.bin .rem .u32 0 (.local 80) (u32l 512))), padStmt] l sh .normal l₂ sh := by
    have e81 := eval_bin_u32 C (ctx := ctx) (l := l) (sh := sh) (op := .div) (site := 0) (eval_local' C h80 sh)
      (eval_u32lit C _ _ 512 (by decide)) (binary_div_u32 C c 512 (by omega) (by decide) (by decide))
    have h15 : setLocal l 81 (u32 (c / 512)) 15 = some (u32 g) := by rw [setLocal_other _ _ (by omega)]; exact hgeo.l15
    have h80' : setLocal l 81 (u32 (c / 512)) 80 = some (u32 c) := by rw [setLocal_other _ _ (by omega)]; exact h80
    have e82 : (eval C ctx (setLocal l 81 (u32 (c / 512))) (.bin .add .u32 0 (.bin .mul .u32 0
        (.bin .add .u32 0 groupBase (.local 81)) (u32l 512)) (.bin .rem .u32 0 (.local 80) (u32l 512)))).run sh =
        some (u32 col, sh) := by
      rw [← hcol]
      exact eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_u32lit C _ _ 2 (by decide))
        (eval_bin_u32 C (eval_local' C h15 sh) (eval_u32lit C _ _ 32 (by decide)) (binary_div_u32 C g 32 (by omega)
          (by decide) (by decide))) (binary_mul_u32 C 2 _)) (eval_local' C (setLocal_same _ _ _) sh) (binary_add_u32 C _ _))
        (eval_u32lit C _ _ 512 (by decide)) (binary_mul_u32 C _ 512))
        (eval_bin_u32 C (eval_local' C h80' sh) (eval_u32lit C _ _ 512 (by decide)) (binary_rem_u32 C c 512 (by omega)
          (by decide) (by decide))) (binary_add_u32 C _ _)
    have epad := eval_bin_u32 C (ctx := ctx) (l := l₂) (sh := sh) (op := .ge) (site := 0) (a := .local 82)
      (eval_local' C (by rw [← hl₂, setLocal_same]) sh) (eval_u32lit C _ _ 5120 (by decide))
      (binary_ge_u32 C col 5120 (by omega) (by decide))
    rw [decide_eq_false (by omega)] at epad
    rw [← hl₂] at epad ⊢
    exact .set e81 (.set e82 (.ite epad (by simp only [Bool.false_eq_true, ↓reduceIte]; exact .nil _ _) (.nil _ _)))
  have hb₂ : ∀ j, j ≤ 80 → l₂ j = l j := fun j hj => by
    rw [← hl₂, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
  have h81 : l₂ 81 = some (u32 (c / 512)) := by rw [← hl₂, setLocal_other _ _ (by omega), setLocal_same]
  have h82 : l₂ 82 = some (u32 col) := by rw [← hl₂, setLocal_same]
  -- the fold
  let J : Nat → Locals → Shared → Prop := fun n l' sh' => (∀ j, j ≤ 82 → l' j = l₂ j) ∧ l' 84 = some (u32 n) ∧
    l' 83 = some (.f32 (colFold C sumsV c n)) ∧
    Mem C L I accV sumsV outV (3 * g + 3) cbOk (fun _ => True) accOk outOk sh'
  obtain ⟨l₃, sh₃, x3, hJ⟩ := Exec.loop_count (c := ltU 84 4) (st := stepU 84 1)
    (b := [.set 83
      (.bin .add .f32 0
        (.load (.scalar .f32)
          (.offset (.local 77)
            (.bin .add .u32 0
              (.bin .mul .u32 0 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 81) (u32l 4)) (.local 84)) (u32l 512))
              (.bin .rem .u32 0 (.local 80) (u32l 512)))))
        (.local 83))]) (ctx := ctx) (C := C) 4 J J
    (fun n hn l' sh' hJ => ⟨sh', eval_lt_u32 C (ctx := ctx) (sh := sh') (b := 4) hJ.2.1 (by omega) (by decide), hJ⟩)
    (fun n hn l' sh' hJ => by
      obtain ⟨hag, h84, h83, hm'⟩ := hJ
      have hreg := hm'.regions
      generalize he : (c / 512 * 4 + n) * 512 + c % 512 = e
      have he4 : e < 4096 := by omega
      have hidx : (eval C ctx l' (.bin .add .u32 0
          (.bin .mul .u32 0 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 81) (u32l 4)) (.local 84)) (u32l 512))
          (.bin .rem .u32 0 (.local 80) (u32l 512)))).run sh' = some (u32 e, sh') := by
        rw [← he]
        exact eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C
          (eval_local' C ((hag 81 (by omega)).trans h81) sh') (eval_u32lit C _ _ 4 (by decide)) (binary_mul_u32 C _ 4))
          (eval_local' C h84 sh') (binary_add_u32 C _ _)) (eval_u32lit C _ _ 512 (by decide)) (binary_mul_u32 C _ 512))
          (eval_bin_u32 C (eval_local' C ((hag 80 (by omega)).trans ((hb₂ 80 le_rfl).trans h80)) sh')
            (eval_u32lit C _ _ 512 (by decide)) (binary_rem_u32 C c 512 (by omega) (by decide) (by decide)))
          (binary_add_u32 C _ _)
      have hp := eval_ptr_u32 C (ctx := ctx)
        (eval_local' C ((hag 77 (by omega)).trans ((hb₂ 77 (by omega)).trans hL.l77)) sh') hidx (by omega)
      rw [show e * (Ty.scalar .f32).bytes = 4 * e by simp [Ty.bytes, Scalar.bytes]; ring] at hp
      have hld := load_shared ctx .f32 sh' 4 (4 * e) _ (by rw [hreg]; exact hS.r4) (by simp) (by simp [Scalar.bytes])
        (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset])
      simp only [Scalar.bytes] at hld
      rw [hm'.sums e he4 trivial, ofWord_f32] at hld
      have hval : (eval C ctx l' (.bin .add .f32 0 (.load (.scalar .f32) (.offset (.local 77) (.bin .add .u32 0
          (.bin .mul .u32 0 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 81) (u32l 4)) (.local 84)) (u32l 512))
          (.bin .rem .u32 0 (.local 80) (u32l 512))))) (.local 83))).run sh' =
          some (.f32 (colFold C sumsV c (n + 1)), rdn ctx sh' 4 (4 * e) 4) := by
        rw [colFold, he]
        exact eval_f32 C (.inr ⟨rfl, rfl⟩) ((eval_load C _ _ _ _ _ _ _ hp).trans hld) (eval_local' C h83 _) rfl
      refine ⟨.normal, setLocal l' 83 (.f32 (colFold C sumsV c (n + 1))), _,
        setLocal (setLocal l' 83 (.f32 (colFold C sumsV c (n + 1)))) 84 (u32 (n + 1)), _, .inl rfl,
        .set hval (.nil _ _),
        .set (eval_bin_u32 C (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact h84) _)
          (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C n 1)) (.nil _ _),
        fun j hj => by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact hag j hj,
        setLocal_same _ _ _, by rw [setLocal_other _ _ (by omega), setLocal_same],
        hm'.rd hS ctx 4 (4 * e) 4 (.inr ⟨rfl, by rw [hl.group]; omega, by rw [hl.group]; omega⟩)⟩)
    (l := setLocal (setLocal l₂ 83 (.f32 zero)) 84 (u32 0)) (sh := sh)
    ⟨fun j hj => by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)], setLocal_same _ _ _,
      by rw [setLocal_other _ _ (by omega), setLocal_same]; rfl, hm⟩
  obtain ⟨hag₃, -, h83₃, hm₃⟩ := hJ
  -- the store
  have hreg₃ := hm₃.regions
  have hix : (eval C ctx l₃ (.bin .add .u64 0 (.bin .mul .u64 0 (.conv .u64 (.local 16)) (u64l 5120))
      (.conv .u64 (.local 82)))).run sh₃ = some (u64 (outIdx g c), sh₃) := by
    have h16 : l₃ 16 = some (u32 (g % 32)) := by rw [hag₃ 16 (by omega), hb₂ 16 (by omega)]; exact hgeo.l16
    have h82' : l₃ 82 = some (u32 col) := by rw [hag₃ 82 le_rfl]; exact h82
    have := eval_int C (ctx := ctx) (l := l₃) (sh := sh₃) (op := .add) (site := 0) (by decide)
      (eval_int C (op := .mul) (site := 0) (by decide) (eval_conv C (t := .u64) (eval_local' C h16 sh₃)
        (convert_u64_u32 C _ (by omega))) (eval_u64lit C _ _ 5120 (by decide)) (binary_mul_u64 C _ _))
      (eval_conv C (t := .u64) (eval_local' C h82' sh₃) (convert_u64_u32 C _ (by omega))) (binary_add_u64 C _ _)
    rwa [show g % 32 * 5120 + col = outIdx g c by rw [← hcol]; rfl] at this
  have hp3 := eval_offset_u64 C (ctx := ctx) (o := 0)
    (eval_local' C (by rw [hag₃ 3 (by omega), hb₂ 3 (by omega)]; exact hgeo.fix1.l3) sh₃) hix (by omega)
  rw [show 0 + outIdx g c * (Ty.scalar .f32).bytes = 4 * outIdx g c by simp [Ty.bytes, Scalar.bytes]; ring] at hp3
  have hst := store_shared ctx .f32 sh₃ 3 (4 * outIdx g c) _ (.f32 (colFold C sumsV c 4))
    (wordBytes 4 (Val.f32Bits (colFold C sumsV c 4))) (by rw [hreg₃]; exact hS.r3) (by simp) (by simp)
    (by simp [Scalar.bytes]) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (encode_f32 _)
  simp only [Scalar.bytes] at hst
  have hm₄ := hm₃.wout hS ctx (outIdx g c) hE.1 (by rw [hl.thread, hE.2.1, hE.2.2.1]) (by rw [hl.group, hE.2.1])
  rw [hout] at hm₄
  refine ⟨l₃, _, ?_, fun j hj => by rw [hag₃ j (by omega), hb₂ j hj], hm₄⟩
  rw [columnBody_eq]
  have x2 : Exec C ctx [.set 83 (f32l 0x0), .set 84 (u32l 0), foldLoop] l₂ sh .normal l₃ sh₃ :=
    .set (eval_lit C _ _ _ _) (.set (eval_u32lit C _ _ 0 (by decide)) x3)
  exact x1.append (x2.append (.store hp3 (eval_local' C h83₃ _) hst (.nil _ _)))

theorem rest3_eq (k : Nat) (sf il : Bool) : rest3 k sf il =
    [.set 80 (.component (.coord .threadPositionInThreadgroup) (u32l 0)), .loop (ltU 80 1024) (stepU 80 256) columnBody] :=
  rfl

/-- Resumed at the third barrier, a lane stores its four columns of `partial` and is done. -/
theorem lane_phase4 (hS : Shape L k sf I) (hl : Lane ctx g s i) {t : Thread}
    (ht : t.ctx = ctx ∧ t.frames = [.block (rest3 k sf il)] ∧ Loc3 k sf il g s i t.locals) {sh : Shared}
    (hm : Mem C L I accV sumsV outV (3 * g + 3) cbOk (fun _ => True) accOk
      (fun E => outGroup E < g ∨ (outGroup E = g ∧ outThread E < 32 * s + i)) sh)
    (hout : ∀ m < 4, outV (outIdx g (32 * s + i + 256 * m)) = colFold C sumsV (32 * s + i + 256 * m) 4) :
    ∃ t' sh', (Ev fun n => (runThread C n { t with status := .running }).run sh = some (t', sh')) ∧
      Mem C L I accV sumsV outV (3 * g + 3) cbOk (fun _ => True) accOk
        (fun E => outGroup E < g ∨ (outGroup E = g ∧ outThread E < 32 * s + i + 1)) sh' ∧ t'.status = .done := by
  obtain ⟨tc, tl, tf, ts⟩ := t
  obtain ⟨hc, hf, hL⟩ := ht
  dsimp only at hc hf hL
  subst hc hf
  have hi := hl.hi; have hs := hl.hs; have hg := hl.hg
  let J : Nat → Locals → Shared → Prop := fun m l' sh' => Loc3 k sf il g s i l' ∧
    l' 80 = some (u32 (32 * s + i + 256 * m)) ∧
    Mem C L I accV sumsV outV (3 * g + 3) cbOk (fun _ => True) accOk (fun E => outGroup E < g ∨ (outGroup E = g ∧
      (outThread E < 32 * s + i ∨ (outThread E = 32 * s + i ∧ E % 5120 % 1024 / 256 < m)))) sh'
  obtain ⟨l', sh', hex, hJ⟩ := Exec.loop_count (c := ltU 80 1024) (st := stepU 80 256) (b := columnBody) (ctx := tc)
    (C := C) 4 J J
    (fun m hm l' sh' hJ => ⟨sh', by
      have := eval_lt_u32 C (ctx := tc) (sh := sh') (b := 1024) hJ.2.1 (by omega) (by decide)
      rwa [show decide (32 * s + i + 256 * m < 1024) = decide (m < 4) from decide_eq_decide.mpr (by omega)] at this, hJ⟩)
    (fun m hm l' sh' hJ => by
      obtain ⟨hL', h80, hm'⟩ := hJ
      obtain ⟨l₁, sh₁, x1, hag₁, hm₁⟩ := column_body C hS hl hm hL' h80 hm' (hout m hm)
      have h80₁ : l₁ 80 = some (u32 (32 * s + i + 256 * m)) := (hag₁ 80 le_rfl).trans h80
      refine ⟨.normal, l₁, sh₁, setLocal l₁ 80 (u32 (32 * s + i + 256 * (m + 1))), sh₁, .inl rfl, x1,
        .set (by
          have := eval_bin_u32 C (ctx := tc) (sh := sh₁) (op := .add) (site := 0) (eval_local' C h80₁ _)
            (eval_u32lit C _ _ 256 (by decide)) (binary_add_u32 C _ 256)
          rwa [show 32 * s + i + 256 * m + 256 = 32 * s + i + 256 * (m + 1) by ring] at this) (.nil _ _),
        hL'.of_eq fun j hj => by rw [setLocal_other _ _ (by omega), hag₁ j (by omega)], setLocal_same _ _ _,
        hm₁.mono (fun _ _ h => h) (fun _ _ h => h) (fun _ h => h) (fun E hE h => ?_)⟩
      rcases h with h | ⟨h1, h | ⟨h2, h3⟩⟩
      · exact .inl (.inl h)
      · exact .inl (.inr ⟨h1, .inl h⟩)
      · by_cases hlt : E % 5120 % 1024 / 256 < m
        · exact .inl (.inr ⟨h1, .inr ⟨h2, hlt⟩⟩)
        · have := idx_out hE h1 h2
          rw [show E % 5120 % 1024 / 256 = m by omega] at this
          exact .inr this)
    (l := setLocal tl 80 (u32 (32 * s + i))) (sh := sh)
    ⟨hL.of_eq fun j hj => setLocal_other _ _ (by omega), by rw [setLocal_same, Nat.mul_zero, Nat.add_zero],
      hm.mono (fun _ _ h => h) (fun _ _ h => h) (fun _ h => h) (fun E _ h => by
        rcases h with h | ⟨h1, h | ⟨-, h⟩⟩
        · exact .inl h
        · exact .inr ⟨h1, h⟩
        · omega)⟩
  refine ⟨⟨tc, l', [], .done⟩, sh', ?_, hJ.2.2.mono (fun _ _ h => h) (fun _ _ h => h) (fun _ h => h) (fun E _ h => ?_), rfl⟩
  · show Ev fun n => (runThread C n ⟨tc, tl, [.block (rest3 k sf il)], .running⟩).run sh = _
    rw [rest3_eq]
    exact (Exec.set (eval_coord0 C hl.tpos) hex).reaches_done.ev_stop rfl
  · rcases h with h | ⟨h1, h⟩
    · exact .inl h
    · by_cases h' : outThread E < 32 * s + i
      · exact .inr ⟨h1, .inl h'⟩
      · exact .inr ⟨h1, .inr ⟨by omega, by omega⟩⟩
end Phase4

/-! ## The SIMD-groups, the threadgroups, the launch -/

section Values
variable (C : M1Max.Contract)

/-- Thread `th`'s `acc[m]` after its split's 136 rows. -/
def accVal (K : Nat) (il : Bool) (I : In) (th m : Nat) : Float32 :=
  accSplit C K il I.Cd I.S I.X (splitOf (th / 256) (th % 256 / 32)) (colOf (th / 256) (th % 256 / 32) (th % 32) m) 136

/-- Threadgroup `g`'s `sums[e]`: its owner's accumulator. -/
def sumsVal (K : Nat) (il : Bool) (I : In) (g e : Nat) : Float32 :=
  accVal C K il I (g * 256 + sumsOwner e) ((255 - e % 256) % 16)

/-- `partial` element `E`. -/
def outVal (K : Nat) (il : Bool) (I : In) (E : Nat) : Float32 :=
  partialVal C K il I.Cd I.S I.X (E / 5120) (E % 5120)

theorem thOf_parts {g s i : Nat} (hs : s < 8) (hi : i < 32) :
    thOf g s i / 256 = g ∧ thOf g s i % 256 / 32 = s ∧ thOf g s i % 32 = i := by
  unfold thOf; omega

theorem accVal_thOf {K : Nat} {il : Bool} {I : In} {g s i : Nat} (hs : s < 8) (hi : i < 32) (m : Nat) :
    accVal C K il I (thOf g s i) m = accSplit C K il I.Cd I.S I.X (splitOf g s) (colOf g s i m) 136 := by
  obtain ⟨h1, h2, h3⟩ := thOf_parts (g := g) hs hi
  rw [accVal, h1, h2, h3]

theorem sumsVal_idx {K : Nat} {il : Bool} {I : In} {g s i m : Nat} (hs : s < 8) (hi : i < 32) (hm : m < 16) :
    sumsVal C K il I g (sumsIdx s i m) = accVal C K il I (thOf g s i) m := by
  obtain ⟨-, h1, h2⟩ := sums_owner hs hi hm
  rw [sumsVal, h1, h2]; rfl

theorem sums_col {g c kk : Nat} (hc : c < 1024) (hk : kk < 4) :
    (g * 256 + sumsOwner ((c / 512 * 4 + kk) * 512 + c % 512)) / 256 = g ∧
    (g * 256 + sumsOwner ((c / 512 * 4 + kk) * 512 + c % 512)) % 256 / 32 = c / 512 * 4 + kk ∧
    colOf g (c / 512 * 4 + kk) ((g * 256 + sumsOwner ((c / 512 * 4 + kk) * 512 + c % 512)) % 32)
      ((255 - ((c / 512 * 4 + kk) * 512 + c % 512) % 256) % 16) = (2 * (g / 32) + c / 512) * 512 + c % 512 := by
  obtain ⟨a, b, d, ha, hb, hd, rfl⟩ : ∃ a b d, a < 2 ∧ b < 2 ∧ d < 256 ∧ c = 512 * a + 256 * b + d :=
    ⟨c / 512, c % 512 / 256, c % 256, by omega, by omega, by omega, by omega⟩
  have e1 : (512 * a + 256 * b + d) / 512 = a := by omega
  have e2 : (512 * a + 256 * b + d) % 512 = 256 * b + d := by omega
  rw [e1, e2]
  have e3 : sumsOwner ((a * 4 + kk) * 512 + (256 * b + d)) = 32 * (a * 4 + kk) + 16 * b + (255 - d) / 16 := by
    unfold sumsOwner; omega
  have e4 : ((a * 4 + kk) * 512 + (256 * b + d)) % 256 = d := by omega
  rw [e3, e4]
  unfold colOf blkOf colGroupOf
  omega

theorem sumsVal_col {K : Nat} {il : Bool} {I : In} {g c kk : Nat} (hc : c < 1024) (hk : kk < 4) :
    sumsVal C K il I g ((c / 512 * 4 + kk) * 512 + c % 512) =
      accSplit C K il I.Cd I.S I.X (g % 32 + 32 * kk) ((2 * (g / 32) + c / 512) * 512 + c % 512) 136 := by
  obtain ⟨h1, h2, h3⟩ := sums_col (g := g) hc hk
  unfold sumsVal accVal
  rw [h1, h2, h3, splitOf, show (c / 512 * 4 + kk) % 4 = kk by omega]

/-- The column sums are `partial`'s elements. -/
theorem col_identity {K : Nat} {il : Bool} {I : In} {g c : Nat} (hg : g < 160) (hc : c < 1024) :
    outVal C K il I (outIdx g c) = colFold C (sumsVal C K il I g) c 4 := by
  have hy : outIdx g c / 5120 = g % 32 := by unfold outIdx; omega
  have hcol : outIdx g c % 5120 = (2 * (g / 32) + c / 512) * 512 + c % 512 := by unfold outIdx; omega
  have e : colFold C (sumsVal C K il I g) c 4 =
      C.fadd (sumsVal C K il I g ((c / 512 * 4 + 3) * 512 + c % 512))
        (C.fadd (sumsVal C K il I g ((c / 512 * 4 + 2) * 512 + c % 512))
          (C.fadd (sumsVal C K il I g ((c / 512 * 4 + 1) * 512 + c % 512))
            (C.fadd (sumsVal C K il I g ((c / 512 * 4 + 0) * 512 + c % 512)) zero))) := rfl
  rw [e, sumsVal_col C hc (by decide : 3 < 4), sumsVal_col C hc (by decide : 2 < 4), sumsVal_col C hc (by decide : 1 < 4),
    sumsVal_col C hc (by decide : 0 < 4), outVal, hy, hcol]
  rfl

end Values

section Simd
variable (C : M1Max.Contract) {L : Launch} {k : Nat} {sf il : Bool} {I : In} {g s : Nat}

/-- A lane at the first barrier. -/
def AtBar1 (k : Nat) (sf il : Bool) (ctx : Ctx) (t : Thread) : Prop :=
  t.ctx = ctx ∧ t.frames = [.block (rest1 k sf il)] ∧ Fix1 t.locals
/-- A lane at the second barrier. -/
def AtBar2 (k : Nat) (sf il : Bool) (g s i : Nat) (ctx : Ctx) (t : Thread) : Prop :=
  t.ctx = ctx ∧ t.frames = [.block (rest2 k sf il)] ∧ PLoc k sf il g s i t.locals
/-- A lane at the third barrier. -/
def AtBar3 (k : Nat) (sf il : Bool) (g s i : Nat) (ctx : Ctx) (t : Thread) : Prop :=
  t.ctx = ctx ∧ t.frames = [.block (rest3 k sf il)] ∧ Loc3 k sf il g s i t.locals

/-- SIMD-group `s` to the first barrier: its lanes' codebook entries. -/
theorem simd_phase1 (hS : Shape L k sf I) (ctxs : Fin 32 → Ctx) (hL : ∀ i : Fin 32, Lane (ctxs i) g s i)
    {sumsV outV : Nat → Float32} {accV : Nat → Nat → Float32} {accOk outOk : Nat → Prop} {sh : Shared}
    (hm : Mem C L I accV sumsV outV (3 * g) (fun e => e % 256 < 32 * s) (fun _ => False) accOk outOk sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m 1 (List.ofFn fun i =>
        (⟨ctxs i, fun _ => none, [.block (body k sf il)], .running⟩ : Thread))).run sh = some (List.ofFn V, sh')) ∧
      Mem C L I accV sumsV outV (3 * g) (fun e => e % 256 < 32 * (s + 1)) (fun _ => False) accOk outOk sh' ∧
      ∀ i, (V i).status = .barrier 1 false true ∧ AtBar1 k sf il (ctxs i) (V i) := by
  obtain ⟨V, sh', hr, hI, hR⟩ := runSimd_blocked_ev C 0 _
    (fun idx sh => Mem C L I accV sumsV outV (3 * g) (fun e => e % 256 < 32 * s + idx) (fun _ => False) accOk outOk sh)
    (fun i t => t.status = .barrier 1 false true ∧ AtBar1 k sf il (ctxs i) t) (fun i sh hI => by
      obtain ⟨t, sh', he, hm', hst, hc, hf, hF⟩ := lane_phase1 C (il := il) hS (hL i) hI
      exact ⟨t, sh', he, hm', by rw [hst]; rfl, hst, hc, hf, hF⟩) sh (by simpa using hm)
  exact ⟨V, sh', hr, by simpa [Nat.mul_add] using hI, hR⟩

/-- SIMD-group `s` to the second barrier: its lanes' accumulators. -/
theorem simd_phase2 (hS : Shape L k sf I) (hG : Geo k sf il) (ctxs : Fin 32 → Ctx) (hL : ∀ i : Fin 32, Lane (ctxs i) g s i)
    (U : Fin 32 → Thread) (hU : ∀ i, AtBar1 k sf il (ctxs i) (U i)) {sumsV outV : Nat → Float32} {outOk : Nat → Prop}
    {sh : Shared}
    (hm : Mem C L I (accVal C k il I) sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False)
      (fun th => g * 256 ≤ th ∧ th < g * 256 + 32 * s) outOk sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m 1 (List.ofFn fun i => { U i with status := .running })).run sh =
        some (List.ofFn V, sh')) ∧
      Mem C L I (accVal C k il I) sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False)
        (fun th => g * 256 ≤ th ∧ th < g * 256 + 32 * (s + 1)) outOk sh' ∧
      ∀ i : Fin 32, (V i).status = .barrier 2 false true ∧ AtBar2 k sf il g s i (ctxs i) (V i) := by
  obtain ⟨V, sh', hr, hI, hR⟩ := runSimd_blocked_ev C 0 (fun i => { U i with status := .running })
    (fun idx sh => Mem C L I (accVal C k il I) sumsV outV (3 * g + 1) (fun _ => True) (fun _ => False)
      (fun th => g * 256 ≤ th ∧ th < g * 256 + 32 * s + idx) outOk sh)
    (fun i t => t.status = .barrier 2 false true ∧ AtBar2 k sf il g s i (ctxs i) t) (fun i sh hI => by
      obtain ⟨hc, hf, hF⟩ := hU i
      generalize U i = t at hc hf hF ⊢
      obtain ⟨tc, tl, tf, ts⟩ := t
      dsimp only at hc hf hF
      subst hc hf
      have hl := hL i
      obtain ⟨t, sh', he, hm', hst, hc', hf', hP⟩ := lane_phase2 C hS hG hl hF hI
        (fun th h => by unfold thOf; omega) (fun m _ => accVal_thOf C hl.hs hl.hi m)
      exact ⟨t, sh', he, hm'.mono (fun _ _ h => h) (fun _ _ h => h) (fun th h => by
        by_cases h' : th < g * 256 + 32 * s + ↑i
        · exact .inl ⟨h.1, h'⟩
        · exact .inr (by unfold thOf; omega)) (fun _ _ h => h), by rw [hst]; rfl, hst, hc', hf', hP⟩) sh (by simpa using hm)
  exact ⟨V, sh', hr, by simpa [Nat.mul_add, Nat.add_assoc] using hI, hR⟩

/-- SIMD-group `s` to the third barrier: its lanes' sums. -/
theorem simd_phase3 (hS : Shape L k sf I) (ctxs : Fin 32 → Ctx) (hL : ∀ i : Fin 32, Lane (ctxs i) g s i)
    (U : Fin 32 → Thread) (hU : ∀ i : Fin 32, AtBar2 k sf il g s i (ctxs i) (U i)) {outV : Nat → Float32} {outOk : Nat → Prop}
    {sh : Shared}
    (hm : Mem C L I (accVal C k il I) (sumsVal C k il I g) outV (3 * g + 2) (fun _ => False)
      (fun e => sumsOwner e < 32 * s) (fun th => g * 256 ≤ th ∧ th < g * 256 + 256) outOk sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m 1 (List.ofFn fun i => { U i with status := .running })).run sh =
        some (List.ofFn V, sh')) ∧
      Mem C L I (accVal C k il I) (sumsVal C k il I g) outV (3 * g + 2) (fun _ => False)
        (fun e => sumsOwner e < 32 * (s + 1)) (fun th => g * 256 ≤ th ∧ th < g * 256 + 256) outOk sh' ∧
      ∀ i : Fin 32, (V i).status = .barrier 3 false true ∧ AtBar3 k sf il g s i (ctxs i) (V i) := by
  obtain ⟨V, sh', hr, hI, hR⟩ := runSimd_blocked_ev C 0 (fun i => { U i with status := .running })
    (fun idx sh => Mem C L I (accVal C k il I) (sumsVal C k il I g) outV (3 * g + 2) (fun _ => False)
      (fun e => sumsOwner e < 32 * s + idx) (fun th => g * 256 ≤ th ∧ th < g * 256 + 256) outOk sh)
    (fun i t => t.status = .barrier 3 false true ∧ AtBar3 k sf il g s i (ctxs i) t) (fun i sh hI => by
      have hl := hL i
      obtain ⟨t, sh', he, hm', hst, hc', hf', hP⟩ := lane_phase3 C hS hl (hU i) hI
        (by have := hl.hs; have := hl.hi; unfold thOf; omega)
        (fun m hm => sumsVal_idx C hl.hs hl.hi hm)
      exact ⟨t, sh', he, hm', by rw [hst]; rfl, hst, hc', hf', hP⟩) sh (by simpa using hm)
  exact ⟨V, sh', hr, by simpa [Nat.mul_add] using hI, hR⟩

/-- SIMD-group `s` to the end: its lanes' columns of `partial`. -/
theorem simd_phase4 (hS : Shape L k sf I) (hg : g < 160) (ctxs : Fin 32 → Ctx) (hL : ∀ i : Fin 32, Lane (ctxs i) g s i)
    (U : Fin 32 → Thread) (hU : ∀ i : Fin 32, AtBar3 k sf il g s i (ctxs i) (U i)) {accV : Nat → Nat → Float32}
    {cbOk accOk : Nat → Prop} {sh : Shared}
    (hm : Mem C L I accV (sumsVal C k il I g) (outVal C k il I) (3 * g + 3) cbOk (fun _ => True) accOk
      (fun E => outGroup E < g ∨ (outGroup E = g ∧ outThread E < 32 * s)) sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m 1 (List.ofFn fun i => { U i with status := .running })).run sh =
        some (List.ofFn V, sh')) ∧
      Mem C L I accV (sumsVal C k il I g) (outVal C k il I) (3 * g + 3) cbOk (fun _ => True) accOk
        (fun E => outGroup E < g ∨ (outGroup E = g ∧ outThread E < 32 * (s + 1))) sh' ∧ ∀ i, (V i).status = .done := by
  obtain ⟨V, sh', hr, hI, hR⟩ := runSimd_blocked_ev C 0 (fun i => { U i with status := .running })
    (fun idx sh => Mem C L I accV (sumsVal C k il I g) (outVal C k il I) (3 * g + 3) cbOk (fun _ => True) accOk
      (fun E => outGroup E < g ∨ (outGroup E = g ∧ outThread E < 32 * s + idx)) sh)
    (fun i t => t.status = .done) (fun i sh hI => by
      have hl := hL i
      obtain ⟨t, sh', he, hm', hst⟩ := lane_phase4 C hS hl (hU i) hI
        (fun m hm => col_identity C hg (by have := hl.hs; have := hl.hi; omega))
      exact ⟨t, sh', he, hm', by rw [hst]; rfl, hst⟩) sh (by simpa using hm)
  exact ⟨V, sh', hr, by simpa [Nat.mul_add] using hI, hR⟩

end Simd

section Group
variable (C : M1Max.Contract) {L : Launch} {k : Nat} {sf il : Bool} {I : In} {g : Nat}

/-- Any `sums` values while no element is kept. -/
theorem Mem.sumsV {accV : Nat → Nat → Float32} {sumsV outV : Nat → Float32} {ge : Nat} {cbOk sumsOk accOk outOk : Nat → Prop}
    {sh : Shared} (h : Mem C L I accV sumsV outV ge cbOk sumsOk accOk outOk sh) (sumsV' : Nat → Float32) :
    Mem C L I accV sumsV' outV ge cbOk (fun _ => False) accOk outOk sh :=
  ⟨h.regions, h.x, h.cd, h.sc, h.deve, h.grpe, h.cb, fun _ _ hf => hf.elim, h.acc, h.out, h.log⟩

/-- A threadgroup: the codebook, the barrier, the rows, the barrier, the sums, the barrier, the columns. -/
theorem group_run (hS : Shape L k sf I) (hG : Geo k sf il) (hg : g < 160) (ctxOf : Fin 8 → Fin 32 → Ctx)
    (hL : ∀ (s : Fin 8) (i : Fin 32), Lane (ctxOf s i) g s i) {sh : Shared}
    (hm : Mem C L I (accVal C k il I) (sumsVal C k il I g) (outVal C k il I) (3 * g) (fun _ => False) (fun _ => False)
      (fun _ => False) (fun E => outGroup E < g) sh) :
    ∃ sh', (Ev fun m => (runGroup C m 1 4 (List.ofFn fun s : Fin 8 => List.ofFn fun i =>
        (⟨ctxOf s i, fun _ => none, [.block (body k sf il)], .running⟩ : Thread))).run sh = some ((), sh')) ∧
      Mem C L I (accVal C k il I) (sumsVal C k il I g) (outVal C k il I) (3 * g + 3) (fun _ => False) (fun _ => True)
        (fun th => g * 256 ≤ th ∧ th < g * 256 + 256) (fun E => outGroup E < g + 1) sh' := by
  refine runGroup_barrier_ev C (by decide) 1 3 _ 1 false true
    (fun j sh => Mem C L I (accVal C k il I) (sumsVal C k il I g) (outVal C k il I) (3 * g) (fun e => e % 256 < 32 * j)
      (fun _ => False) (fun _ => False) (fun E => outGroup E < g) sh)
    (fun j i t => AtBar1 k sf il (ctxOf j i) t) _ (fun j sh hj => ?_) (fun U sh hU hI => ?_) sh
    (hm.mono (fun e _ h => by omega) (fun _ _ h => h) (fun _ h => h) (fun _ _ h => h))
  · obtain ⟨V, sh', hr, hm', hV⟩ := simd_phase1 C (il := il) hS (ctxOf j) (hL j) hj
    exact ⟨V, sh', hr, hm', fun i => ⟨(hV i).1, (hV i).2⟩⟩
  have hp : Mem C L I (accVal C k il I) (sumsVal C k il I g) (outVal C k il I) (3 * g + 1) (fun _ => True)
      (fun _ => False) (fun th => g * 256 ≤ th ∧ th < g * 256 + 32 * 0) (fun E => outGroup E < g) (pass false true sh) :=
    hI.pass.mono (fun e _ _ => by omega) (fun _ _ h => h) (fun th h => by omega) (fun _ _ h => h)
  refine runGroup_barrier_ev C (by decide) 1 2 (fun j i => { U j i with status := .running }) 2 false true
    (fun j sh => Mem C L I (accVal C k il I) (sumsVal C k il I g) (outVal C k il I) (3 * g + 1) (fun _ => True)
      (fun _ => False) (fun th => g * 256 ≤ th ∧ th < g * 256 + 32 * j) (fun E => outGroup E < g) sh)
    (fun j i t => AtBar2 k sf il g j i (ctxOf j i) t) _ (fun j sh hj => ?_) (fun U' sh' hU' hI' => ?_) _ hp
  · obtain ⟨V, sh', hr, hm', hV⟩ := simd_phase2 C hS hG (ctxOf j) (hL j) (U j) (hU j) hj
    exact ⟨V, sh', hr, hm', fun i => ⟨(hV i).1, (hV i).2⟩⟩
  have hp' : Mem C L I (accVal C k il I) (sumsVal C k il I g) (outVal C k il I) (3 * g + 2) (fun _ => False)
      (fun e => sumsOwner e < 32 * 0) (fun th => g * 256 ≤ th ∧ th < g * 256 + 256) (fun E => outGroup E < g)
      (pass false true sh') :=
    hI'.pass.mono (fun _ _ h => h.elim) (fun e _ h => by omega) (fun th h => by omega) (fun _ _ h => h)
  refine runGroup_barrier_ev C (by decide) 1 1 (fun j i => { U' j i with status := .running }) 3 false true
    (fun j sh => Mem C L I (accVal C k il I) (sumsVal C k il I g) (outVal C k il I) (3 * g + 2) (fun _ => False)
      (fun e => sumsOwner e < 32 * j) (fun th => g * 256 ≤ th ∧ th < g * 256 + 256) (fun E => outGroup E < g) sh)
    (fun j i t => AtBar3 k sf il g j i (ctxOf j i) t) _ (fun j sh hj => ?_) (fun U'' sh'' hU'' hI'' => ?_) _ hp'
  · obtain ⟨V, sh', hr, hm', hV⟩ := simd_phase3 C hS (ctxOf j) (hL j) (U' j) (hU' j) hj
    exact ⟨V, sh', hr, hm', fun i => ⟨(hV i).1, (hV i).2⟩⟩
  have hp'' : Mem C L I (accVal C k il I) (sumsVal C k il I g) (outVal C k il I) (3 * g + 3) (fun _ => False)
      (fun _ => True) (fun th => g * 256 ≤ th ∧ th < g * 256 + 256)
      (fun E => outGroup E < g ∨ (outGroup E = g ∧ outThread E < 32 * 0)) (pass false true sh'') :=
    hI''.pass.mono (fun _ _ h => h) (fun e he _ => by unfold sumsOwner; omega) (fun _ h => h)
      (fun E _ h => by omega)
  obtain ⟨sh₄, hr₄, hm₄⟩ := runGroup_done_ev C 1 0 (fun j i => { U'' j i with status := .running })
    (fun j sh => Mem C L I (accVal C k il I) (sumsVal C k il I g) (outVal C k il I) (3 * g + 3) (fun _ => False)
      (fun _ => True) (fun th => g * 256 ≤ th ∧ th < g * 256 + 256)
      (fun E => outGroup E < g ∨ (outGroup E = g ∧ outThread E < 32 * j)) sh)
    (fun j sh hj => simd_phase4 C hS hg (ctxOf j) (hL j) (U'' j) (hU'' j) hj) _ hp''
  exact ⟨sh₄, hr₄, hm₄.mono (fun _ _ h => h) (fun _ _ h => h) (fun _ h => h) (fun E _ h => by
    unfold outThread; omega)⟩

/-- The launch: the 160 threadgroups in order. -/
theorem launch_run {initial : Nat → ByteMemory.Bytes} (hS : Shape (launch k sf il I initial) k sf I) (hG : Geo k sf il)
    (fuse : Nat → Bool) (garbage : Garbage) :
    ∃ sh, (∃ (sumsV : Nat → Float32) (cbOk sumsOk accOk : Nat → Prop), Mem C (launch k sf il I initial) I
        (accVal C k il I) sumsV (outVal C k il I) (3 * 160) cbOk sumsOk accOk (fun E => outGroup E < 160) sh) ∧
      Ev fun m => runLaunch C fuse (launch k sf il I initial) garbage m 1 4 = some ⟨sh.bytes, sh.log⟩ := by
  have hb : (launch k sf il I initial).buffers = buffers (bufs k I) [655360] 16 initial := rfl
  obtain ⟨sh, hI, hr⟩ := launch_tiles.launch_run_ev C fuse garbage 1 4
    (fun G sh => ∃ (sumsV : Nat → Float32) (cbOk sumsOk accOk : Nat → Prop), Mem C (launch k sf il I initial) I
      (accVal C k il I) sumsV (outVal C k il I) (3 * G) cbOk sumsOk accOk (fun E => outGroup E < G) sh)
    ⟨fun _ => zero, fun _ => False, fun _ => False, fun _ => False, rfl, initial_input hb garbage 0 (by simp [bufs]),
      initial_input hb garbage 1 (by simp [bufs]), initial_input hb garbage 2 (by simp [bufs]), rfl, rfl,
      fun _ _ h => h.elim, fun _ _ h => h.elim, fun _ h => h.elim, fun E _ h => absurd h (by omega),
      fun a ha => by simp [Launch.initial] at ha⟩
    (fun bx byy bz hx hy hz sh hI => by
      obtain rfl : bx = 0 := by omega
      obtain rfl : bz = 0 := by omega
      obtain ⟨sumsV, cbOk, sumsOk, accOk, hm⟩ := hI
      have hm' := Mem.sumsV C (hm.reset rfl rfl garbage (0 + byy * 1 + 0 * 1 * 160)) (sumsVal C k il I byy)
      rw [show 0 + byy * 1 + 0 * 1 * 160 = byy by ring] at hm' ⊢
      obtain ⟨sh', hr, hm''⟩ := group_run C hS hG hy
        (fun s i => (launch k sf il I initial).ctxAt fuse 0 byy 0 (32 * s + i)) (fun s i => lane_of fuse hy s i)
        (hm'.mono (fun _ _ h => h) (fun _ _ h => h) (fun _ h => h.elim) (fun _ _ h => h))
      exact ⟨sh', hr, _, _, _, _, by rw [show 3 * (byy + 1) = 3 * byy + 3 by ring]; exact hm''⟩)
  exact ⟨sh, hI, hr⟩

end Group

variable (C : M1Max.Contract)

/-- **The GPU runs the down partial kernel as its source says**, for each of the route's down geometries (`Geo`:
2- and 4-bit row-major, 3-bit shifted and interleaved), given that the text compiles to `core K sf il`. Under the
GPU assumption, MLX's launch on any `x` and scales (2-byte aligned, `bfloat` and `half`) and codes (4-aligned,
`uint32`) writes to `partial` each column's first sum stage, `expected`: the four splits' `fma` accumulations of
the trellis-decoded codes times scale times `x`, added from zero in MLX's order. -/
theorem gpu_output_of (K : Nat) (sf il : Bool) (hG : Geo K sf il) (text : List Char)
    (hc : (frontend text).bind elaborate = some (core K sf il)) (G : Gpu C) (hmax : 256 ≤ G.maxThreads text)
    (X Cd S : ByteMemory.Bytes) (ax ac as : Nat) (hax : 2 ∣ ax) (hac : 4 ∣ ac) (has : 2 ∣ as) :
    G.execute text (256, 160, 1) (256, 1, 1)
      [⟨.device, 34816, ax, X⟩, ⟨.device, codesBytes K, ac, Cd⟩, ⟨.device, 34816, as, S⟩] [655360] =
      some [expected C K il X Cd S] := by
  have h := gpu_owned C G (text := text) (grid := (256, 160, 1)) (tg := (256, 1, 1))
    (inputs := [⟨.device, 34816, ax, X⟩, ⟨.device, codesBytes K, ac, Cd⟩, ⟨.device, 34816, as, S⟩]) (sizes := [655360])
    (fun _ => expected C K il X Cd S) hc (by simpa using hmax) (fun initial garbage => by
      have hS := launch_shape (k := K) (sf := sf) (il := il) (I := ⟨X, Cd, S, ax, ac, as⟩) (initial := initial)
        (Nat.mod_eq_zero_of_dvd hax) (Nat.mod_eq_zero_of_dvd hac) (Nat.mod_eq_zero_of_dvd has)
      obtain ⟨sh, ⟨sumsV, cbOk, sumsOk, accOk, hm⟩, n, hn⟩ := launch_run C hS hG (G.fusion text) garbage
      refine ⟨n, 1, 4, sh, dev, tgo, hn n le_rfl, hm.log, ?_⟩
      intro i hi b hb
      obtain rfl : i = 0 := by simp at hi; omega
      have hb' : b < 655360 := by simpa using hb
      show sh.bytes 3 b = expected C K il X Cd S b
      have : cells (sh.bytes 3) (4 * (b / 4)) 4 =
          wordBytes 4 (Val.f32Bits (partialVal C K il Cd S X (b / 4 / 5120) (b / 4 % 5120))) :=
        hm.out (b / 4) (by omega) (by unfold outGroup; omega)
      rw [expected, ite_eq_left hb', ← this, cells_getD _ _ _ _ (by omega), show 4 * (b / 4) + b % 4 = b by omega])
  rw [h]
  show some [fun b => if b < 655360 then expected C K il X Cd S b else 0] = _
  congr 2
  funext b
  unfold expected
  split <;> simp_all

/-! ## The route's down widths

The MLP layouts of the route's stages (`Host.Load.Run.Full.Expected.stages`) have down widths 2, 3 and 4: at 3
the codes are interleaved and odd lanes shifted (`downConfig 3`), at 2 and 4 neither. Codes of width `K` are
`17408·640·K` bytes: 22282240 (2-bit), 33423360 (3-bit), 44564480 (4-bit). -/

section Route
variable {X Cd S : ByteMemory.Bytes} {ax ac as : Nat}

theorem geo_2 : Geo 2 false false := .inl ⟨rfl, rfl, rfl⟩
theorem geo_3 : Geo 3 true true := .inr (.inr ⟨rfl, rfl, rfl⟩)
theorem geo_4 : Geo 4 false false := .inr (.inl ⟨rfl, rfl, rfl⟩)

theorem gpu_output_2 (G : Gpu C) (hmax : 256 ≤ G.maxThreads (text 2)) (hax : 2 ∣ ax) (hac : 4 ∣ ac) (has : 2 ∣ as) :
    G.execute (text 2) (256, 160, 1) (256, 1, 1)
      [⟨.device, 34816, ax, X⟩, ⟨.device, 22282240, ac, Cd⟩, ⟨.device, 34816, as, S⟩] [655360] =
      some [expected C 2 false X Cd S] :=
  gpu_output_of C 2 false false geo_2 _ compile_2 G hmax X Cd S ax ac as hax hac has

theorem gpu_output_3 (G : Gpu C) (hmax : 256 ≤ G.maxThreads (text 3)) (hax : 2 ∣ ax) (hac : 4 ∣ ac) (has : 2 ∣ as) :
    G.execute (text 3) (256, 160, 1) (256, 1, 1)
      [⟨.device, 34816, ax, X⟩, ⟨.device, 33423360, ac, Cd⟩, ⟨.device, 34816, as, S⟩] [655360] =
      some [expected C 3 true X Cd S] :=
  gpu_output_of C 3 true true geo_3 _ compile_3 G hmax X Cd S ax ac as hax hac has

theorem gpu_output_4 (G : Gpu C) (hmax : 256 ≤ G.maxThreads (text 4)) (hax : 2 ∣ ax) (hac : 4 ∣ ac) (has : 2 ∣ as) :
    G.execute (text 4) (256, 160, 1) (256, 1, 1)
      [⟨.device, 34816, ax, X⟩, ⟨.device, 44564480, ac, Cd⟩, ⟨.device, 34816, as, S⟩] [655360] =
      some [expected C 4 false X Cd S] :=
  gpu_output_of C 4 false false geo_4 _ compile_4 G hmax X Cd S ax ac as hax hac has

/-- At down 3-bit, the text is tests/Elab.lean's `downPartialText`. -/
theorem gpu_output (G : Gpu C) (hmax : 256 ≤ G.maxThreads Metal.Elab.Tests.downPartialText) (hax : 2 ∣ ax)
    (hac : 4 ∣ ac) (has : 2 ∣ as) :
    G.execute Metal.Elab.Tests.downPartialText (256, 160, 1) (256, 1, 1)
      [⟨.device, 34816, ax, X⟩, ⟨.device, 33423360, ac, Cd⟩, ⟨.device, 34816, as, S⟩] [655360] =
      some [expected C 3 true X Cd S] := by
  rw [← text_three] at hmax ⊢
  exact gpu_output_3 C G hmax hax hac has

end Route

end Metal.Kernels.DownPartial
