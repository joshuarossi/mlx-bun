import metal.Steps
import metal.Group
import metal.tests.Elab
import metal.Gpu
import metal.kernels.ArgmaxFinish

set_option linter.constructorNameAsVariable false

namespace Metal.Kernels.GateUp
open Metal Metal.Core Inference.Contracts.Mlx

/-! # gate-up-codebook.ts

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
threadgroup float codebook[1 << L];
threadgroup uint4 xs[C / 8];
constexpr uint N_RUNS = (uint)C / 32u;
for (uint i = thread_position_in_threadgroup.x; i < (1u << (uint)L); i += (uint)THREADS)
  codebook[i] = trellis_unrefined_bits_y(trellis_y(i));
// Chunk q (positions 8q..8q+7) of run r at q·N_RUNS + r.
for (uint c = thread_position_in_threadgroup.x; c < (uint)C / 8u; c += (uint)THREADS)
  xs[c] = ((const device uint4*)x)[(c % N_RUNS) * 4u + c / N_RUNS];
threadgroup_barrier(metal::mem_flags::mem_threadgroup);
const threadgroup uchar* table = (const threadgroup uchar*)codebook;
const uint lane = thread_index_in_simdgroup;
const uint gWpb = (uint)(BT * KG / 32);
const uint uWpb = (uint)(BT * KU / 32);
const uint runsPerBlock = (uint)BT / 32u;
const uint rowStep = threadgroups_per_grid.y * (uint)ROWS_TG;
for (uint row = thread_position_in_grid.y * (uint)ROWS_TG + simdgroup_index_in_threadgroup; row < (uint)R; row += rowStep) {
  const uint gRow = row * (uint)((C / BT) * gWpb);
  const uint uRow = row * (uint)((C / BT) * uWpb);
  const float gScale = float(gscales[row]);
  const float uScale = float(uscales[row]);
  float gAcc = 0.0f, gAcc2 = 0.0f, uAcc = 0.0f, uAcc2 = 0.0f;
  for (uint run = lane; run < N_RUNS; run += 32u) {
    const uint blk = run / runsPerBlock;
    const uint t0 = (run - blk * runsPerBlock) * 32u;
    const uint gw = gRow + blk * gWpb, uw = uRow + blk * uWpb;
    const uint gW0 = ((uint)BT - 32u - t0) * (uint)KG / 32u;
    const uint uW0 = ((uint)BT - 32u - t0) * (uint)KU / 32u;
    uint g[KG + 1], gv[KG + 1];
    uint u[KU + 1], uv[KU + 1];
    // Words W0 .. W0 + K - 1 stay in the block; the next word wraps to the block's first for its last run.
    #pragma clang loop unroll(full)
    for (uint i = 0; i < (uint)KG; ++i) g[i] = gcodes[gw + gW0 + i];
    g[KG] = gcodes[gw + (t0 == 0u ? 0u : gW0 + (uint)KG)];
    #pragma clang loop unroll(full)
    for (uint i = 0; i < (uint)KU; ++i) u[i] = ucodes[uw + uW0 + i];
    u[KU] = ucodes[uw + (t0 == 0u ? 0u : uW0 + (uint)KU)];
    // Virtual words: bits [32i - 16, 32i + 16) of the run's words (only the ignored bits below word 0 are absent).
    gv[0] = g[0] << 16;
    uv[0] = u[0] << 16;
    #pragma clang loop unroll(full)
    for (uint i = 1; i <= (uint)KG; ++i) gv[i] = (g[i - 1] >> 16) | (g[i] << 16);
    #pragma clang loop unroll(full)
    for (uint i = 1; i <= (uint)KU; ++i) uv[i] = (u[i - 1] >> 16) | (u[i] << 16);
    #pragma clang loop unroll(full)
    for (uint q = 0; q < 4u; ++q) {
      const uint4 chunk = xs[q * N_RUNS + run];
      #pragma clang loop unroll(full)
      for (uint p = 0; p < 8u; ++p) {
        const uint j = q * 8u + p;
        // The bf16 in either half of a word, as the float of its bits.
        const float xv = as_type<float>((p & 1u) ? chunk[p >> 1] & 0xFFFF0000u : chunk[p >> 1] << 16);
        const float gWeight = trellis_codebook_window(table, g, gv, (31u - j) * (uint)KG, (uint)L) * gScale;
        const float uWeight = trellis_codebook_window(table, u, uv, (31u - j) * (uint)KU, (uint)L) * uScale;
        if (j & 1u) { gAcc2 = metal::fma(gWeight, xv, gAcc2); uAcc2 = metal::fma(uWeight, xv, uAcc2); }
        else { gAcc = metal::fma(gWeight, xv, gAcc); uAcc = metal::fma(uWeight, xv, uAcc); }
      }
    }
  }
  const float gate = metal::simd_sum(gAcc + gAcc2);
  const float up = metal::simd_sum(uAcc + uAcc2);
  if (lane == 0u) {
    const T gateT = T(gate);
    const T upT = T(up);
    if ((TAIL) == 1) {
      const T sigY = 1 / (1 + metal::exp(metal::abs(gateT)));
      const T sigmoidT = (gateT < 0) ? sigY : 1 - sigY;
      const T siluT = gateT * sigmoidT;
      mid[row] = siluT * upT;
    } else {
      const T sigmoidT = T(1.0f / (1.0f + metal::precise::exp(-float(gateT))));
      const T siluT = T(float(gateT) * float(sigmoidT));
      mid[row] = T(float(siluT) * float(upT));
    }
  }
}
```
at `gateUpConfig KG KU` (the route's gate and up widths): grid [1024, 160, 1], threadgroup [1024, 1, 1], so 160
threadgroups of 32 SIMD-groups, with T = bfloat, R = 17408, C = 5120, BT = 256, L = 12, ROWS_TG = 32, THREADS = 1024
and TAIL = 1 exactly when KG ≠ KU. `core KG KU tail` is the elaborated kernel; the constants that vary are the
words per block `8·K`, the run's first word `(224 - t0)·K/32`, the word arrays' length `K + 1`, the window offset
`(31 - j)·K`, and which branch of `TAIL` stays. -/

def u32l (n : Nat) : CExpr := .lit (.int .u32 n)
def u16l (n : Nat) : CExpr := .lit (.int .u16 n)
def i32l (n : Nat) : CExpr := .lit (.int .i32 n)
def f32l (bits : Nat) : CExpr := .lit (.f32 (Val.ofF32Bits bits))
def bf16l (bits : Nat) : CExpr := .lit (.bf16 (Val.ofBf16Bits bits))

/-- `i < n`, `i <= n` and `i += d` for the `uint` counter in slot `i`. -/
def ltU (i n : Nat) : CExpr := .bin .lt .u32 0 (.local i) (u32l n)
def leU (i n : Nat) : CExpr := .bin .le .u32 0 (.local i) (u32l n)
def stepU (i d : Nat) : List CStmt := [.set i (.bin .add .u32 0 (.local i) (u32l d))]

/-! ## The codebook and `xs` -/

/-- `trellis_y(s)` (slots 9 s, 10 result, 11 x, 12 p). -/
def trellisY : CStmt :=
  .scope
    [.set 11 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 9) (u32l 34038481)) (u32l 76625530)),
     .set 12
       (.bin .add .u32 0 (.bin .bitAnd .u32 0 (.local 11) (u32l 16711935))
         (.bin .bitAnd .u32 0 (.bin .shr .u32 0 (.local 11) (u32l 8)) (u32l 16711935))),
     .set 10
       (.bin .sub .i32 0
         (.conv .i32 (.bin .add .u32 0 (.bin .bitAnd .u32 0 (.local 12) (u32l 65535)) (.bin .shr .u32 0 (.local 12) (u32l 16))))
         (i32l 510)),
     .leave]
/-- `trellis_unrefined_bits_y(y)` (slots 13 y, 14 result, 15 lifted). -/
def unrefinedY : CStmt :=
  .scope
    [.set 15 (.bitcast .f32 (.bin .bitOr .u32 0 (u32l 1258291200) (.conv .u32 (.bin .add .i32 0 (.local 13) (i32l 510))))),
     .set 14 (.bin .mul .f32 0 (.bin .sub .f32 0 (.local 15) (f32l 0x4B0001FE)) (f32l 0x3BDDB447)),
     .leave]
def fillBody : List CStmt :=
  [.set 9 (.local 8), trellisY, .set 13 (.local 10), unrefinedY,
   .store (.scalar .f32) (.offset (.local 6) (.local 8)) (.local 14)]
def fillLoop : CStmt := .loop (ltU 8 4096) (stepU 8 1024) fillBody

/-- `xs[c] = ((const device uint4*)x)[(c % N_RUNS) * 4u + c / N_RUNS]`. -/
def xsIndex : CExpr :=
  .bin .add .u32 0 (.bin .mul .u32 0 (.bin .rem .u32 0 (.local 16) (u32l 160)) (u32l 4))
    (.bin .div .u32 0 (.local 16) (u32l 160))
def xsBody : List CStmt :=
  [.store (.vec .u32 4) (.offset (.local 7) (.local 16))
    (.load (.vec .u32 4) (.offset (.ptrCast (.vec .u32 4) (.local 0)) xsIndex))]
def xsLoop : CStmt := .loop (ltU 16 640) (stepU 16 1024) xsBody

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

/-! ## One run of one row -/

/-- `(BT - 32 - t0) * K / 32`, the first word of the run (`gW0` and `uW0`). -/
def firstWord (k : Nat) : CExpr :=
  .bin .div .u32 0 (.bin .mul .u32 0 (.bin .sub .u32 0 (u32l 224) (.local 34)) (u32l k)) (u32l 32)
/-- `for (i < K) w[i] = codes[bw + w0 + i]` (counter slot `i`, array slot `w`, `codes` slot `c`). -/
def loadWords (k i w c bw w0 : Nat) : CStmt :=
  .loop (ltU i k) (stepU i 1)
    [.store (.scalar .u32) (.offset (.local w) (.local i))
      (.load (.scalar .u32) (.offset (.local c) (.bin .add .u32 0 (.bin .add .u32 0 (.local bw) (.local w0)) (.local i))))]
/-- `w[K] = codes[bw + (t0 == 0u ? 0u : w0 + K)]`. -/
def loadWrap (k w c bw w0 : Nat) : CStmt :=
  .store (.scalar .u32) (.offset (.local w) (i32l k))
    (.load (.scalar .u32)
      (.offset (.local c)
        (.bin .add .u32 0 (.local bw)
          (.cond (.bin .eq .u32 0 (.local 34) (u32l 0)) (u32l 0) (.bin .add .u32 0 (.local w0) (u32l k))))))
/-- `v[0] = w[0] << 16`. -/
def firstVirtual (w v : Nat) : CStmt :=
  .store (.scalar .u32) (.offset (.local v) (i32l 0))
    (.bin .shl .u32 0 (.load (.scalar .u32) (.offset (.local w) (i32l 0))) (u32l 16))
/-- `for (i = 1; i <= K; ++i) v[i] = (w[i - 1] >> 16) | (w[i] << 16)`. -/
def virtualWords (k i w v : Nat) : CStmt :=
  .loop (leU i k) (stepU i 1)
    [.store (.scalar .u32) (.offset (.local v) (.local i))
      (.bin .bitOr .u32 0
        (.bin .shr .u32 0 (.load (.scalar .u32) (.offset (.local w) (.bin .sub .u32 0 (.local i) (u32l 1)))) (u32l 16))
        (.bin .shl .u32 0 (.load (.scalar .u32) (.offset (.local w) (.local i))) (u32l 16)))]

/-- `chunk[p >> 1]`, the float `xv` of its half, and `(31u - j) * K`. -/
def chunkWord : CExpr := .component (.local 48) (.bin .shr .u32 0 (.local 49) (u32l 1))
def xvExpr : CExpr :=
  .bitcast .f32
    (.cond (.conv .bool (.bin .bitAnd .u32 0 (.local 49) (u32l 1)))
      (.bin .bitAnd .u32 0 chunkWord (u32l 4294901760))
      (.bin .shl .u32 0 chunkWord (u32l 16)))
def windowOff (k : Nat) : CExpr := .bin .mul .u32 0 (.bin .sub .u32 0 (u32l 31) (.local 50)) (u32l k)
/-- Call `trellis_codebook_window(table, w, v, (31u - j) * K, L)`: parameters in slots `b … b + 4`. -/
def lookup (k b w v : Nat) : List CStmt :=
  [.set b (.local 17), .set (b + 1) (.local w), .set (b + 2) (.local v), .set (b + 3) (windowOff k),
   .set (b + 4) (u32l 12), window b]

def accOdd : List CStmt :=
  [.set 29 (.fma (.local 62) (.local 51) (.local 29)), .set 31 (.fma (.local 73) (.local 51) (.local 31))]
def accEven : List CStmt :=
  [.set 28 (.fma (.local 62) (.local 51) (.local 28)), .set 30 (.fma (.local 73) (.local 51) (.local 30))]
/-- One value `p` of chunk `q`: `j = q * 8 + p`, the gate and up weights, and their `fma`s. -/
def pBody (kg ku : Nat) : List CStmt :=
  [.set 50 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 47) (u32l 8)) (.local 49)),
   .set 51 xvExpr] ++
  lookup kg 52 39 40 ++
  [.set 62 (.bin .mul .f32 0 (.local 57) (.local 26))] ++
  lookup ku 63 41 42 ++
  [.set 73 (.bin .mul .f32 0 (.local 68) (.local 27)),
   .ite (.conv .bool (.bin .bitAnd .u32 0 (.local 50) (u32l 1))) accOdd accEven]
def pLoop (kg ku : Nat) : CStmt := .loop (ltU 49 8) (stepU 49 1) (pBody kg ku)
/-- One chunk `q`: `chunk = xs[q * N_RUNS + run]`, then its eight values. -/
def qBody (kg ku : Nat) : List CStmt :=
  [.set 48 (.load (.vec .u32 4) (.offset (.local 7) (.bin .add .u32 0 (.bin .mul .u32 0 (.local 47) (u32l 160)) (.local 32)))),
   .set 49 (u32l 0),
   pLoop kg ku]
def qLoop (kg ku : Nat) : CStmt := .loop (ltU 47 4) (stepU 47 1) (qBody kg ku)

/-- One run: `blk`, `t0`, the block words, the words `g`/`u` and virtual words `gv`/`uv` (thread arrays 0 … 3). -/
def runBody (kg ku : Nat) : List CStmt :=
  [.set 33 (.bin .div .u32 0 (.local 32) (.local 21)),
   .set 34 (.bin .mul .u32 0 (.bin .sub .u32 0 (.local 32) (.bin .mul .u32 0 (.local 33) (.local 21))) (u32l 32)),
   .set 35 (.bin .add .u32 0 (.local 24) (.bin .mul .u32 0 (.local 33) (.local 19))),
   .set 36 (.bin .add .u32 0 (.local 25) (.bin .mul .u32 0 (.local 33) (.local 20))),
   .set 37 (firstWord kg),
   .set 38 (firstWord ku),
   .array 39 false 0 (.scalar .u32),
   .array 40 false 1 (.scalar .u32),
   .array 41 false 2 (.scalar .u32),
   .array 42 false 3 (.scalar .u32),
   .set 43 (u32l 0), loadWords kg 43 39 1 35 37, loadWrap kg 39 1 35 37,
   .set 44 (u32l 0), loadWords ku 44 41 3 36 38, loadWrap ku 41 3 36 38,
   firstVirtual 39 40,
   firstVirtual 41 42,
   .set 45 (u32l 1), virtualWords kg 45 39 40,
   .set 46 (u32l 1), virtualWords ku 46 41 42,
   .set 47 (u32l 0),
   qLoop kg ku]
def runLoop (kg ku : Nat) : CStmt := .loop (ltU 32 160) (stepU 32 32) (runBody kg ku)

/-! ## The tail -/

/-- `TAIL == 0`: `sigmoidT = T(1 / (1 + exp(-float(gateT))))` (precise `exp`). -/
def sigmoidExpr : CExpr :=
  .conv .bf16
    (.bin .div .f32 0 (f32l 0x3F800000)
      (.bin .add .f32 0 (f32l 0x3F800000) (.un .exp .f32 (.un .neg .f32 (.conv .f32 (.local 78))))))
/-- `TAIL == 1`: `sigY = 1 / (1 + exp(abs(gateT)))` in bfloat (MLX's bfloat `exp` and `abs` overloads). -/
def sigYExpr : CExpr :=
  .bin .div .bf16 0 (bf16l 0x3F80)
    (.bin .add .bf16 0 (bf16l 0x3F80)
      (.conv .bf16 (.un .fastExp .f32 (.conv .f32 (.conv .bf16 (.un .fastFabs .f32 (.conv .f32 (.local 78))))))))
/-- `TAIL == 1`: `sigmoidT = (gateT < 0) ? sigY : 1 - sigY`. -/
def sigmoidTailExpr : CExpr :=
  .cond (.bin .lt .bf16 0 (.local 78) (bf16l 0x0)) (.local 80) (.bin .sub .bf16 0 (bf16l 0x3F80) (.local 80))
/-- After `gateT`, `upT`: the activation and `mid[row]` (the branch of `TAIL` that stays). -/
def tailStmts : Bool → List CStmt
  | true =>
    [.set 80 sigYExpr,
     .set 81 sigmoidTailExpr,
     .set 82 (.bin .mul .bf16 0 (.local 78) (.local 81)),
     .store (.scalar .bf16) (.offset (.local 5) (.local 23)) (.bin .mul .bf16 0 (.local 82) (.local 79))]
  | false =>
    [.set 83 sigmoidExpr,
     .set 84 (.bin .mul .bf16 0 (.local 78) (.local 83)),
     .store (.scalar .bf16) (.offset (.local 5) (.local 23)) (.bin .mul .bf16 0 (.local 84) (.local 79))]
/-- `if (lane == 0u)`: `T(gate)`, `T(up)`, then the tail. -/
def midStore (tail : Bool) : CStmt :=
  .ite (.bin .eq .u32 0 (.local 18) (u32l 0))
    (.set 78 (.conv .bf16 (.local 75)) :: .set 79 (.conv .bf16 (.local 77)) :: tailStmts tail) []

/-- One row: `gRow`, `uRow`, the scales, the four accumulators, the runs, the two sums, the tail. -/
def rowBody (kg ku : Nat) (tail : Bool) : List CStmt :=
  [.set 24 (.bin .mul .u32 0 (.local 23) (.bin .mul .u32 0 (u32l 20) (.local 19))),
   .set 25 (.bin .mul .u32 0 (.local 23) (.bin .mul .u32 0 (u32l 20) (.local 20))),
   .set 26 (.conv .f32 (.load (.scalar .f16) (.offset (.local 2) (.local 23)))),
   .set 27 (.conv .f32 (.load (.scalar .f16) (.offset (.local 4) (.local 23)))),
   .set 28 (f32l 0x0),
   .set 29 (f32l 0x0),
   .set 30 (f32l 0x0),
   .set 31 (f32l 0x0),
   .set 32 (.local 18),
   runLoop kg ku,
   .collective 2 74 .sum .f32 (.bin .add .f32 0 (.local 28) (.local 29)) (u16l 0),
   .set 75 (.local 74),
   .collective 3 76 .sum .f32 (.bin .add .f32 0 (.local 30) (.local 31)) (u16l 0),
   .set 77 (.local 76),
   midStore tail]
def rowCond : CExpr := ltU 23 17408
def rowStep : List CStmt := [.set 23 (.bin .add .u32 0 (.local 23) (.local 22))]
def rowLoop (kg ku : Nat) (tail : Bool) : CStmt := .loop rowCond rowStep (rowBody kg ku tail)

/-- Slots: 0 x, 1 gcodes, 2 gscales, 3 ucodes, 4 uscales, 5 mid, 6 codebook (threadgroup array 0),
7 xs (threadgroup array 1), 8 i, 9 … 12 `trellis_y`'s `s result x p`, 13 … 15 `trellis_unrefined_bits_y`'s
`y result lifted`, 16 c, 17 table, 18 lane, 19 gWpb, 20 uWpb, 21 runsPerBlock, 22 rowStep, 23 row, 24 gRow,
25 uRow, 26 gScale, 27 uScale, 28 gAcc, 29 gAcc2, 30 uAcc, 31 uAcc2, 32 run, 33 blk, 34 t0, 35 gw, 36 uw,
37 gW0, 38 uW0, 39 g, 40 gv, 41 u, 42 uv (thread arrays 0 … 3), 43 i (loading g), 44 i (loading u),
45 i (gv), 46 i (uv), 47 q, 48 chunk, 49 p, 50 j, 51 xv, 52 … 61 the gate `trellis_codebook_window`
(`table w v off l`, result 57, `f mask bits vi`), 62 gWeight, 63 … 72 the up window (result 68), 73 uWeight,
74 the first `simd_sum` result, 75 gate, 76 the second `simd_sum` result, 77 up, 78 gateT, 79 upT,
80 … 82 the `TAIL == 1` branch's `sigY sigmoidT siluT`, 83 and 84 the `TAIL == 0` branch's `sigmoidT siluT`. -/
def body (kg ku : Nat) (tail : Bool) : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .bf16⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .u32⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .f16⟩)),
   .set 3 (.lit (.ptr ⟨3, 0, .scalar .u32⟩)),
   .set 4 (.lit (.ptr ⟨4, 0, .scalar .f16⟩)),
   .set 5 (.lit (.ptr ⟨5, 0, .scalar .bf16⟩)),
   .array 6 true 0 (.scalar .f32),
   .array 7 true 1 (.vec .u32 4),
   .set 8 (.component (.coord .threadPositionInThreadgroup) (u32l 0)),
   fillLoop,
   .set 16 (.component (.coord .threadPositionInThreadgroup) (u32l 0)),
   xsLoop,
   .barrier 1 false true,
   .set 17 (.ptrCast (.scalar .u8) (.local 6)),
   .set 18 (.coord .threadIndexInSimdgroup),
   .set 19 (u32l (8 * kg)),
   .set 20 (u32l (8 * ku)),
   .set 21 (u32l 8),
   .set 22 (.bin .mul .u32 0 (.component (.coord .threadgroupsPerGrid) (u32l 1)) (u32l 32)),
   .set 23
     (.bin .add .u32 0
       (.bin .mul .u32 0 (.component (.coord .threadPositionInGrid) (u32l 1)) (u32l 32))
       (.coord .simdgroupIndexInThreadgroup)),
   rowLoop kg ku tail]

def core (kg ku : Nat) (tail : Bool) : Kernel :=
  ⟨6, [(.scalar .f32, 4096), (.vec .u32 4, 640)],
    [(.scalar .u32, kg + 1), (.scalar .u32, kg + 1), (.scalar .u32, ku + 1), (.scalar .u32, ku + 1)], body kg ku tail⟩

/-! ## The texts MLX compiles

As tests/Assemble.lean builds `gateUpText`: x `[1,5120]` bf16, codes `uint32 [17408, 5120·K/32]` (trellisGeometry's
row-major words), scales `float16 [17408]`, at `gateUpConfig KG KU`. -/

def inputs (kg ku : Nat) : List Assemble.Input :=
  [⟨chars!"x", .bfloat16, [1, 5120]⟩, ⟨chars!"gcodes", .uint32, [17408, 160 * kg]⟩,
    ⟨chars!"gscales", .float16, [17408]⟩, ⟨chars!"ucodes", .uint32, [17408, 160 * ku]⟩,
    ⟨chars!"uscales", .float16, [17408]⟩]

def text (kg ku : Nat) : List Char :=
  (Assemble.Tests.launch .gateUp chars!"mlx_bun_trellis_gateup_codebook_row" (inputs kg ku) [chars!"mid"]
    (Host.Mlx.gateUpConfig kg ku)).getD []

/-- At gate and up 2-bit the text is tests/Elab.lean's `gateUpText`. -/
theorem text_two : text 2 2 = Metal.Elab.Tests.gateUpText := by decide +kernel

-- The elaborated text MLX compiles at each of the route's gate and up widths is `core`.
kernel_rfl compile_2_2 : (frontend (text 2 2)).bind elaborate = some (core 2 2 false)
kernel_rfl compile_3_3 : (frontend (text 3 3)).bind elaborate = some (core 3 3 false)
kernel_rfl compile_4_4 : (frontend (text 4 4)).bind elaborate = some (core 4 4 false)
kernel_rfl compile_3_2 : (frontend (text 3 2)).bind elaborate = some (core 3 2 true)
kernel_rfl compile_2_3 : (frontend (text 2 3)).bind elaborate = some (core 2 3 true)
kernel_rfl compile_4_3 : (frontend (text 4 3)).bind elaborate = some (core 4 3 true)
kernel_rfl compile_3_4 : (frontend (text 3 4)).bind elaborate = some (core 3 4 true)

end Metal.Kernels.GateUp
/-! ## The trellis header functions

`trellis_y`, `trellis_unrefined_bits_y` and `trellis_codebook_window`, shared with down-codebook.ts
(DownPartial.lean); the decode of a block's code bits into 12-bit trellis states. -/

namespace Metal.Kernels.Trellis
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.GateUp

/-- The parts of `trellis_codebook_window`. -/
def fE (b : Nat) : CExpr := .bin .sub .i32 0 (.conv .i32 (.local (b + 3))) (i32l 2)
def maskE (b : Nat) : CExpr :=
  .bin .sub .u32 0 (.bin .shl .u32 0 (u32l 1) (.bin .add .u32 0 (.local (b + 4)) (u32l 2))) (u32l 1)
def andE (b : Nat) : CExpr := .bin .bitAnd .i32 0 (.local (b + 6)) (i32l 31)
def geE (b : Nat) : CExpr := .bin .ge .i32 0 (.local (b + 6)) (i32l 0)
def leE (b : Nat) : CExpr :=
  .bin .le .u32 0 (.bin .add .u32 0 (.bin .add .u32 0 (.conv .u32 (andE b)) (.local (b + 4))) (u32l 2)) (u32l 32)
def wordPtrE (b : Nat) : CExpr := .offset (.local (b + 1)) (.bin .shr .i32 0 (.local (b + 6)) (i32l 5))
def wordFieldE (b : Nat) : CExpr :=
  .bin .bitAnd .u32 0 (.bin .shr .u32 0 (.load (.scalar .u32) (wordPtrE b)) (.conv .u32 (andE b))) (.local (b + 7))
def f16E (b : Nat) : CExpr := .bin .add .i32 0 (.local (b + 6)) (i32l 16)
def viE (b : Nat) : CExpr := .bin .shr .u32 0 (.conv .u32 (f16E b)) (u32l 5)
def shiftE (b : Nat) : CExpr := .bin .sub .i32 0 (f16E b) (.bin .mul .i32 0 (i32l 32) (.conv .i32 (.local (b + 9))))
def virtFieldE (b : Nat) : CExpr :=
  .bin .bitAnd .u32 0
    (.bin .shr .u32 0 (.load (.scalar .u32) (.offset (.local (b + 2)) (.local (b + 9)))) (.conv .u32 (shiftE b)))
    (.local (b + 7))
def entryE (b : Nat) : CExpr := .load (.scalar .f32) (.ptrCast (.scalar .f32) (.offset (.local b) (.local (b + 8))))

theorem window_eq (b : Nat) : window b =
    .scope [.set (b + 6) (fE b), .set (b + 7) (maskE b), .ite (.and (geE b) (leE b)) [.set (b + 8) (wordFieldE b)]
      [.set (b + 9) (viE b), .set (b + 8) (virtFieldE b)], .set (b + 5) (entryE b), .leave] := rfl

variable (C : M1Max.Contract) {ctx : Ctx}

theorem i32_of_nat {v : Int} {n : Nat} (h : v = n) (hn : n < 2 ^ 32) : i32 v = .int .i32 n := by
  rw [h]; exact i32_nat n hn

/-- The window's arithmetic, in-word case. -/
theorem window_in_word {R off : Nat} (h2 : 2 ≤ off) (hr : (off - 2) % 32 + 14 ≤ 32) :
    R / 2 ^ (32 * ((off - 2) / 32)) % 2 ^ 32 / 2 ^ ((off - 2) % 32) % 2 ^ 14 / 4 = R / 2 ^ off % 2 ^ 12 := by
  rw [field_word _ _ hr, Nat.div_div_eq_div_mul, ← Nat.pow_add]
  congr 3
  omega

/-- The window's arithmetic, virtual-word case. -/
theorem window_virtual {R off : Nat} (hs : (off + 14) % 32 + 14 ≤ 32) :
    R * 2 ^ 16 / 2 ^ (32 * ((off + 14) / 32)) % 2 ^ 32 / 2 ^ ((off + 14) % 32) % 2 ^ 14 / 4 = R / 2 ^ off % 2 ^ 12 := by
  rw [field_word _ _ hs, Nat.div_div_eq_div_mul, ← Nat.pow_add,
    show 32 * ((off + 14) / 32) + ((off + 14) % 32 + 2) = off + 16 by omega, Nat.pow_add,
    Nat.mul_div_mul_right _ _ (Nat.two_pow_pos 16)]

theorem mask_eq (x : Nat) : x &&& 16383 = x % 2 ^ 14 := Nat.and_two_pow_sub_one_eq_mod x 14

/-- **`trellis_codebook_window`.** With the table pointer, the word arrays `w` (words `W`) and `v` (the virtual
words: the words' value moved up 16 bits), `off` and `l = 12` in slots `b … b + 4`, the window reads table entry
`(value of W) >> off & 0xFFF` (the table load ignores the field's low two bits) into slot `b + 5`. -/
theorem exec_window (b : Nat) {l : Locals} {sh : Shared} {cb rw rv n off : Nat} {W : Nat → Nat}
    (T : Nat → Float32) (S : Nat → Shared)
    (hb : l b = some (.ptr ⟨cb, 0, .scalar .u8⟩)) (hw : l (b + 1) = some (.ptr ⟨rw, 0, .scalar .u32⟩))
    (hv : l (b + 2) = some (.ptr ⟨rv, 0, .scalar .u32⟩)) (ho : l (b + 3) = some (u32 off))
    (hl : l (b + 4) = some (u32 12)) (hW : ∀ i < n, W i < 2 ^ 32)
    (hlw : ∀ i < n, (loadAt ctx (.scalar .u32) ⟨rw, ((4 * i : Nat) : Int), .scalar .u32⟩).run sh = some (u32 (W i), sh))
    (hlv : ∀ i < n, (loadAt ctx (.scalar .u32) ⟨rv, ((4 * i : Nat) : Int), .scalar .u32⟩).run sh =
      some (u32 (runBits W n * 2 ^ 16 / 2 ^ (32 * i) % 2 ^ 32), sh))
    (hT : ∀ o : Nat, o < 2 ^ 14 → (loadAt ctx (.scalar .f32) ⟨cb, (o : Int), .scalar .f32⟩).run sh =
      some (.f32 (T (o / 4)), S (o / 4)))
    (hoff : off + 12 ≤ 32 * n) (hoff' : off < 2 ^ 30) :
    ∃ l', Exec C ctx [window b] l sh .normal l' (S (runBits W n / 2 ^ off % 2 ^ 12)) ∧
      l' (b + 5) = some (.f32 (T (runBits W n / 2 ^ off % 2 ^ 12))) ∧ ∀ j, j < b + 5 ∨ b + 9 < j → l' j = l j := by
  generalize hR : runBits W n = R at hlv ⊢
  have hf : (eval C ctx l (fE b)).run sh = some (i32 ((off : Int) - 2), sh) := by
    have hz : binary C .sub .i32 (.int .i32 off) (.int .i32 2) = some (i32 ((off : Int) - 2)) := by
      rw [← i32_nat off (by omega), show Val.int .i32 2 = i32 2 from rfl]
      exact binary_sub_i32v C (by omega) (by omega) (by omega) (by omega) (by omega) (by omega)
    exact eval_int C (by decide) (eval_conv C (t := .i32) (eval_local' C ho sh) (convert_i32_u32 C (a := off) (by omega)))
      (eval_lit C _ _ _ _) hz
  generalize hl₀ : setLocal l (b + 6) (i32 ((off : Int) - 2)) = l₀
  have hmask : (eval C ctx l₀ (maskE b)).run sh = some (u32 16383, sh) := by
    have h4 : l₀ (b + 4) = some (u32 12) := by rw [← hl₀, setLocal_other _ _ (by omega)]; exact hl
    exact eval_bin_u32 C (eval_bin_u32 C (eval_u32lit C _ _ 1 (by decide))
      (eval_bin_u32 C (eval_local' C h4 sh) (eval_u32lit C _ _ 2 (by decide)) (binary_add_u32 C 12 2))
      (binary_shl_u32 C 1 (12 + 2) (by decide))) (eval_u32lit C _ _ 1 (by decide))
      (binary_sub_u32 C _ 1 (by decide))
  generalize hl₁ : setLocal l₀ (b + 7) (u32 16383) = l₁
  have h6 : l₁ (b + 6) = some (i32 ((off : Int) - 2)) := by
    rw [← hl₁, setLocal_other _ _ (by omega), ← hl₀, setLocal_same]
  have h7 : l₁ (b + 7) = some (u32 16383) := by rw [← hl₁, setLocal_same]
  have hl₁b : ∀ j, j < b + 6 → l₁ j = l j := by
    intro j hj; rw [← hl₁, setLocal_other _ _ (by omega), ← hl₀, setLocal_other _ _ (by omega)]
  have h4 : l₁ (b + 4) = some (u32 12) := by rw [hl₁b _ (by omega)]; exact hl
  -- the branch: the field, in a word or in a virtual word
  have hbr : ∃ bits l₂, bits < 2 ^ 14 ∧ bits / 4 = R / 2 ^ off % 2 ^ 12 ∧
      Exec C ctx [.ite (.and (geE b) (leE b)) [.set (b + 8) (wordFieldE b)]
        [.set (b + 9) (viE b), .set (b + 8) (virtFieldE b)]] l₁ sh .normal l₂ sh ∧
      l₂ (b + 8) = some (u32 bits) ∧ ∀ j, j ≠ b + 8 → j ≠ b + 9 → l₂ j = l₁ j := by
    by_cases hin : 2 ≤ off ∧ (off - 2) % 32 + 14 ≤ 32
    · obtain ⟨h2, hr⟩ := hin
      rw [i32_of_nat (show (off : Int) - 2 = ((off - 2 : Nat) : Int) by omega) (by omega)] at h6
      have hand : (eval C ctx l₁ (andE b)).run sh = some (.int .i32 ((off - 2) % 32), sh) := by
        have e : (off - 2) &&& 31 = (off - 2) % 32 := Nat.and_two_pow_sub_one_eq_mod (off - 2) 5
        exact eval_int C (by decide) (eval_local' C h6 sh) (eval_lit C _ _ _ _) (by rw [binary_bitAnd_i32, e])
      have hand' : (eval C ctx l₁ (.conv .u32 (andE b))).run sh = some (u32 ((off - 2) % 32), sh) :=
        eval_conv C (t := .u32) hand (convert_u32_i32 C (a := (off - 2) % 32) (by omega))
      have hge : (eval C ctx l₁ (geE b)).run sh = some (.bool true, sh) :=
        eval_int C (by decide) (eval_local' C h6 sh) (eval_lit C _ _ _ _)
          (by rw [binary_ge_i32 C (a := off - 2) (b := 0) (by omega) (by decide), decide_eq_true (by omega)])
      have hle : (eval C ctx l₁ (leE b)).run sh = some (.bool true, sh) := by
        have := eval_bin_u32 C (op := .le) (site := 0) (a := .bin .add .u32 0 (.bin .add .u32 0 (.conv .u32 (andE b))
            (.local (b + 4))) (u32l 2)) (b := u32l 32)
          (eval_bin_u32 C (eval_bin_u32 C hand' (eval_local' C h4 sh) (binary_add_u32 C _ 12))
            (eval_u32lit C _ _ 2 (by decide)) (binary_add_u32 C _ 2))
          (eval_u32lit C _ _ 32 (by decide)) (binary_le_u32 C ((off - 2) % 32 + 12 + 2) 32 (by omega) (by decide))
        rwa [decide_eq_true (show (off - 2) % 32 + 12 + 2 ≤ 32 by omega)] at this
      have ha : (off - 2) / 32 < n := by omega
      have hWa := hW _ ha
      have hp : (eval C ctx l₁ (wordPtrE b)).run sh =
          some (.ptr ⟨rw, ((4 * ((off - 2) / 32) : Nat) : Int), .scalar .u32⟩, sh) := by
        have h1 : l₁ (b + 1) = some (.ptr ⟨rw, 0, .scalar .u32⟩) := by rw [hl₁b _ (by omega)]; exact hw
        have : (eval C ctx l₁ (wordPtrE b)).run sh = some (.ptr ⟨rw, ((0 + (off - 2) / 2 ^ 5 * (Ty.scalar .u32).bytes : Nat) : Int), .scalar .u32⟩, sh) :=
          eval_offset_i32 C (o := 0) (n := (off - 2) / 2 ^ 5) (eval_local' C h1 sh)
          (eval_int C (by decide) (eval_local' C h6 sh) (eval_lit C _ _ _ _)
            (binary_shr_i32 C (a := off - 2) (b := 5) (by omega) (by decide))) (by omega)
        rwa [show 0 + (off - 2) / 2 ^ 5 * (Ty.scalar .u32).bytes = 4 * ((off - 2) / 32) by
          simp only [Ty.bytes, Scalar.bytes]; omega] at this
      have hval : (eval C ctx l₁ (wordFieldE b)).run sh =
          some (u32 (W ((off - 2) / 32) / 2 ^ ((off - 2) % 32) % 2 ^ 14), sh) := by
        rw [← mask_eq]
        exact eval_bin_u32 C (eval_bin_u32 C ((eval_load C _ _ _ _ _ _ _ hp).trans (hlw _ ha)) hand'
          (binary_shr_u32 C _ _ hWa (by omega))) (eval_local' C h7 sh)
          (binary_bitAnd_u32 C _ 16383 (lt_of_le_of_lt (Nat.div_le_self _ _) hWa) (by decide))
      refine ⟨_, _, Nat.mod_lt _ (by decide), ?_, .ite (eval_and_true C hge hle) (.set hval (.nil _ _)) (.nil _ _),
        setLocal_same _ _ _, fun j h8 _ => setLocal_other _ _ h8⟩
      rw [← window_in_word (R := R) h2 hr, ← hR, runBits_word hW _ ha]
    · have hs : (off + 14) % 32 + 14 ≤ 32 := by omega
      have hvi : (off + 14) / 32 < n := by omega
      have hc : (eval C ctx l₁ (.and (geE b) (leE b))).run sh = some (.bool false, sh) := by
        by_cases h2 : 2 ≤ off
        · rw [i32_of_nat (show (off : Int) - 2 = ((off - 2 : Nat) : Int) by omega) (by omega)] at h6
          have hand : (eval C ctx l₁ (andE b)).run sh = some (.int .i32 ((off - 2) % 32), sh) := by
            have e : (off - 2) &&& 31 = (off - 2) % 32 := Nat.and_two_pow_sub_one_eq_mod (off - 2) 5
            exact eval_int C (by decide) (eval_local' C h6 sh) (eval_lit C _ _ _ _) (by rw [binary_bitAnd_i32, e])
          have hand' : (eval C ctx l₁ (.conv .u32 (andE b))).run sh = some (u32 ((off - 2) % 32), sh) :=
            eval_conv C (t := .u32) hand (convert_u32_i32 C (a := (off - 2) % 32) (by omega))
          have hge : (eval C ctx l₁ (geE b)).run sh = some (.bool true, sh) :=
            eval_int C (by decide) (eval_local' C h6 sh) (eval_lit C _ _ _ _)
              (by rw [binary_ge_i32 C (a := off - 2) (b := 0) (by omega) (by decide), decide_eq_true (by omega)])
          have hle : (eval C ctx l₁ (leE b)).run sh = some (.bool false, sh) := by
            have := eval_bin_u32 C (op := .le) (site := 0) (a := .bin .add .u32 0 (.bin .add .u32 0 (.conv .u32 (andE b))
                (.local (b + 4))) (u32l 2)) (b := u32l 32)
              (eval_bin_u32 C (eval_bin_u32 C hand' (eval_local' C h4 sh) (binary_add_u32 C _ 12))
                (eval_u32lit C _ _ 2 (by decide)) (binary_add_u32 C _ 2))
              (eval_u32lit C _ _ 32 (by decide)) (binary_le_u32 C ((off - 2) % 32 + 12 + 2) 32 (by omega) (by decide))
            rwa [decide_eq_false (show ¬ (off - 2) % 32 + 12 + 2 ≤ 32 by omega)] at this
          exact eval_and_true C hge hle
        · have hge : (eval C ctx l₁ (geE b)).run sh = some (.bool false, sh) :=
            eval_int C (by decide) (eval_local' C h6 sh) (eval_lit C _ _ _ _)
              (by show binary C .ge .i32 (i32 ((off : Int) - 2)) (i32 0) = some (.bool false)
                  rw [binary_ge_i32v C (by omega) (by omega) (by omega) (by omega), decide_eq_false (by omega)])
          exact eval_and_false C hge
      have hadd : (eval C ctx l₁ (f16E b)).run sh = some (.int .i32 (off + 14), sh) := by
        have hz : binary C .add .i32 (i32 ((off : Int) - 2)) (.int .i32 16) = some (.int .i32 (off + 14)) := by
          rw [show Val.int .i32 16 = i32 16 from rfl, binary_add_i32v C (by omega) (by omega) (by omega) (by omega)
            (by omega) (by omega), i32_of_nat (n := off + 14) (by omega) (by omega)]
        exact eval_int C (by decide) (eval_local' C h6 sh) (eval_lit C _ _ _ _) hz
      have hviv : (eval C ctx l₁ (viE b)).run sh = some (u32 ((off + 14) / 2 ^ 5), sh) :=
        eval_bin_u32 C (eval_conv C (t := .u32) hadd (convert_u32_i32 C (a := off + 14) (by omega)))
          (eval_u32lit C _ _ 5 (by decide)) (binary_shr_u32 C _ 5 (by omega) (by decide))
      rw [show (off + 14) / 2 ^ 5 = (off + 14) / 32 by norm_num] at hviv
      generalize hl₂ : setLocal l₁ (b + 9) (u32 ((off + 14) / 32)) = l₂
      have h9 : l₂ (b + 9) = some (u32 ((off + 14) / 32)) := by rw [← hl₂, setLocal_same]
      have hl₂b : ∀ j, j ≠ b + 9 → l₂ j = l₁ j := fun j h => by rw [← hl₂, setLocal_other _ _ h]
      have hadd₂ : (eval C ctx l₂ (f16E b)).run sh = some (.int .i32 (off + 14), sh) := by
        have hz : binary C .add .i32 (i32 ((off : Int) - 2)) (.int .i32 16) = some (.int .i32 (off + 14)) := by
          rw [show Val.int .i32 16 = i32 16 from rfl, binary_add_i32v C (by omega) (by omega) (by omega) (by omega)
            (by omega) (by omega), i32_of_nat (n := off + 14) (by omega) (by omega)]
        exact eval_int C (by decide) (eval_local' C (by rw [hl₂b _ (by omega)]; exact h6) sh) (eval_lit C _ _ _ _) hz
      have hsh : (eval C ctx l₂ (.conv .u32 (shiftE b))).run sh = some (u32 ((off + 14) % 32), sh) := by
        have hm : (eval C ctx l₂ (.bin .mul .i32 0 (i32l 32) (.conv .i32 (.local (b + 9))))).run sh =
            some (.int .i32 (32 * ((off + 14) / 32)), sh) :=
          eval_int C (by decide) (eval_lit C _ _ _ _)
            (eval_conv C (t := .i32) (eval_local' C h9 sh) (convert_i32_u32 C (a := (off + 14) / 32) (by omega)))
            (binary_mul_i32 C 32 ((off + 14) / 32) (by omega) (by decide) (by omega))
        refine eval_conv C (t := .u32) (eval_int C (by decide) hadd₂ hm (binary_sub_i32 C (off + 14) (32 * ((off + 14) / 32)) (by omega) (by omega))) ?_
        rw [show off + 14 - 32 * ((off + 14) / 32) = (off + 14) % 32 by omega]
        exact convert_u32_i32 C _ (by omega)
      have hp : (eval C ctx l₂ (.offset (.local (b + 2)) (.local (b + 9)))).run sh =
          some (.ptr ⟨rv, ((4 * ((off + 14) / 32) : Nat) : Int), .scalar .u32⟩, sh) := by
        have h2' : l₂ (b + 2) = some (.ptr ⟨rv, 0, .scalar .u32⟩) := by
          rw [hl₂b _ (by omega), hl₁b _ (by omega)]; exact hv
        have : (eval C ctx l₂ (.offset (.local (b + 2)) (.local (b + 9)))).run sh =
            some (.ptr ⟨rv, ((0 + (off + 14) / 32 * (Ty.scalar .u32).bytes : Nat) : Int), .scalar .u32⟩, sh) :=
          eval_offset_u32 C (o := 0) (eval_local' C h2' sh) (eval_local' C h9 sh) (by omega)
        rwa [show 0 + (off + 14) / 32 * (Ty.scalar .u32).bytes = 4 * ((off + 14) / 32) by
          simp only [Ty.bytes, Scalar.bytes]; omega] at this
      have hV := Nat.mod_lt (R * 2 ^ 16 / 2 ^ (32 * ((off + 14) / 32))) (show 0 < 2 ^ 32 by decide)
      have hval : (eval C ctx l₂ (virtFieldE b)).run sh =
          some (u32 (R * 2 ^ 16 / 2 ^ (32 * ((off + 14) / 32)) % 2 ^ 32 / 2 ^ ((off + 14) % 32) % 2 ^ 14), sh) := by
        rw [← mask_eq]
        exact eval_bin_u32 C (eval_bin_u32 C ((eval_load C _ _ _ _ _ _ _ hp).trans (hlv _ hvi)) hsh
          (binary_shr_u32 C _ _ hV (by omega))) (eval_local' C (by rw [hl₂b _ (by omega)]; exact h7) sh)
          (binary_bitAnd_u32 C _ 16383 (lt_of_le_of_lt (Nat.div_le_self _ _) hV) (by decide))
      refine ⟨_, _, Nat.mod_lt _ (by decide), window_virtual hs,
        .ite hc (.set hviv (by rw [hl₂]; exact .set hval (.nil _ _))) (.nil _ _), setLocal_same _ _ _,
        fun j h8 h9' => ?_⟩
      rw [setLocal_other _ _ h8, hl₂b _ h9']
  obtain ⟨bits, l₂, hbits, hdiv, hex, h8, hl₂⟩ := hbr
  have hb₂ : l₂ b = some (.ptr ⟨cb, 0, .scalar .u8⟩) := by rw [hl₂ _ (by omega) (by omega), hl₁b _ (by omega)]; exact hb
  have hentry : (eval C ctx l₂ (entryE b)).run sh = some (.f32 (T (R / 2 ^ off % 2 ^ 12)), S (R / 2 ^ off % 2 ^ 12)) := by
    have hp : (eval C ctx l₂ (.ptrCast (.scalar .f32) (.offset (.local b) (.local (b + 8))))).run sh =
        some (.ptr ⟨cb, ((0 + bits * (Ty.scalar .u8).bytes : Nat) : Int), .scalar .f32⟩, sh) :=
      eval_ptrCast C (eval_offset_u32 C (o := 0) (eval_local' C hb₂ sh) (eval_local' C h8 sh) (by omega))
    rw [show 0 + bits * (Ty.scalar .u8).bytes = bits by simp [Ty.bytes, Scalar.bytes]] at hp
    rw [entryE, eval_load C _ _ _ _ _ _ _ hp, hT bits hbits, hdiv]
  have hfull : Exec C ctx [.set (b + 6) (fE b), .set (b + 7) (maskE b), .ite (.and (geE b) (leE b))
      [.set (b + 8) (wordFieldE b)] [.set (b + 9) (viE b), .set (b + 8) (virtFieldE b)], .set (b + 5) (entryE b), .leave]
      l sh .leave (setLocal l₂ (b + 5) (.f32 (T (R / 2 ^ off % 2 ^ 12)))) (S (R / 2 ^ off % 2 ^ 12)) := by
    have hpre : Exec C ctx [.set (b + 6) (fE b), .set (b + 7) (maskE b)] l sh .normal l₁ sh :=
      .set hf (by rw [hl₀]; exact .set hmask (by rw [hl₁]; exact .nil _ _))
    exact (hpre.append hex).append (.set hentry .leave)
  refine ⟨setLocal l₂ (b + 5) (.f32 (T (R / 2 ^ off % 2 ^ 12))), ?_, setLocal_same _ _ _, fun j hj => ?_⟩
  · rw [window_eq]
    exact .scope hfull (.inr rfl) (.nil _ _)
  · rw [setLocal_other _ _ (by omega), hl₂ _ (by omega) (by omega)]
    rcases hj with hj | hj
    · exact hl₁b _ (by omega)
    · rw [← hl₁, setLocal_other _ _ (by omega), ← hl₀, setLocal_other _ _ (by omega)]

/-! ### The codebook: `trellis_y` and `trellis_unrefined_bits_y` -/

/-- `trellis_y(s)` with slots `b` s, `b + 1` result, `b + 2` x, `b + 3` p. -/
def trellisYAt (b : Nat) : CStmt :=
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
/-- `trellis_unrefined_bits_y(y)` with slots `b` y, `b + 1` result, `b + 2` lifted. -/
def unrefinedYAt (b : Nat) : CStmt :=
  .scope
    [.set (b + 2)
       (.bitcast .f32 (.bin .bitOr .u32 0 (u32l 1258291200) (.conv .u32 (.bin .add .i32 0 (.local b) (i32l 510))))),
     .set (b + 1) (.bin .mul .f32 0 (.bin .sub .f32 0 (.local (b + 2)) (f32l 0x4B0001FE)) (f32l 0x3BDDB447)),
     .leave]

theorem trellisY_eq : GateUp.trellisY = trellisYAt 9 := rfl
theorem unrefinedY_eq : GateUp.unrefinedY = unrefinedYAt 13 := rfl

/-- `p` of `trellis_y(s)`: the sums of bytes 0 and 1 and of bytes 2 and 3 of `x = s·34038481 + 76625530`. -/
def trellisP (s : Nat) : Nat :=
  let x := (s * 34038481 + 76625530) % 2 ^ 32
  (x &&& 0xFF00FF) + (x / 2 ^ 8 &&& 0xFF00FF)

/-- `trellis_y(s)`: `(p & 0xFFFF) + (p >> 16) - 510`. -/
def trellisYv (s : Nat) : Int := ((trellisP s &&& 0xFFFF) + trellisP s / 2 ^ 16 : Nat) - 510

/-- `trellis_unrefined_bits_y(y)`: the float of word `0x4b000000 | (y + 510)`, less `8389118.0f`, times
`1.0f / 147.800537109375f` (folded to the word `0x3BDDB447`). -/
def unrefinedBits (C : M1Max.Contract) (y : Int) : Float32 :=
  C.fmul (C.fadd (Val.ofF32Bits (0x4B000000 ||| (y + 510).toNat)) (f32Neg (Val.ofF32Bits 0x4B0001FE)))
    (Val.ofF32Bits 0x3BDDB447)

/-- Codebook entry `e`: `trellis_unrefined_bits_y(trellis_y(e))`. -/
def codebook (C : M1Max.Contract) (e : Nat) : Float32 := unrefinedBits C (trellisYv e)

theorem trellisP_lt (s : Nat) : trellisP s < 2 ^ 25 := by
  dsimp only [trellisP]
  have h1 := Nat.and_le_right (n := (s * 34038481 + 76625530) % 2 ^ 32) (m := 0xFF00FF)
  have h2 := Nat.and_le_right (n := (s * 34038481 + 76625530) % 2 ^ 32 / 2 ^ 8) (m := 0xFF00FF)
  omega

/-- The inlined `trellis_y(s)`: `trellis_y` in slot `b + 1`. -/
theorem exec_trellisY (b : Nat) {l : Locals} {sh : Shared} {s : Nat} (h : l b = some (u32 s)) :
    ∃ l', Exec C ctx [trellisYAt b] l sh .normal l' sh ∧ l' (b + 1) = some (i32 (trellisYv s)) ∧
      ∀ j, j ≤ b ∨ b + 3 < j → l' j = l j := by
  generalize hx : (s * 34038481 + 76625530) % 2 ^ 32 = x
  have hxl : x < 2 ^ 32 := by rw [← hx]; exact Nat.mod_lt _ (by decide)
  obtain ⟨P, hP, hPl⟩ : ∃ P, trellisP s = P ∧ P < 2 ^ 25 := ⟨_, rfl, trellisP_lt s⟩
  have hp : P = (x &&& 16711935) + (x / 2 ^ 8 &&& 16711935) := by rw [← hP, trellisP, hx]
  obtain ⟨Y, hY, hYl⟩ : ∃ Y, (P &&& 65535) + P / 2 ^ 16 = Y ∧ Y < 2 ^ 31 :=
    ⟨_, rfl, by have := Nat.and_le_right (n := P) (m := 65535); omega⟩
  have e1 : (eval C ctx l (.bin .add .u32 0 (.bin .mul .u32 0 (.local b) (GateUp.u32l 34038481))
      (GateUp.u32l 76625530))).run sh = some (u32 x, sh) := by
    rw [← hx, u32_mod]
    exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C h sh) (eval_u32lit C _ _ _ (by decide))
      (binary_mul_u32 C s 34038481)) (eval_u32lit C _ _ _ (by decide)) (binary_add_u32 C _ 76625530)
  generalize hl₁ : setLocal l (b + 2) (u32 x) = l₁
  have h2 : l₁ (b + 2) = some (u32 x) := by rw [← hl₁, setLocal_same]
  have e2 : (eval C ctx l₁ (.bin .add .u32 0 (.bin .bitAnd .u32 0 (.local (b + 2)) (GateUp.u32l 16711935))
      (.bin .bitAnd .u32 0 (.bin .shr .u32 0 (.local (b + 2)) (GateUp.u32l 8)) (GateUp.u32l 16711935)))).run sh =
      some (u32 P, sh) := by
    rw [hp]
    exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C h2 sh) (eval_u32lit C _ _ _ (by decide))
      (binary_bitAnd_u32 C x 16711935 hxl (by decide)))
      (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h2 sh) (eval_u32lit C _ _ _ (by decide))
        (binary_shr_u32 C x 8 hxl (by decide))) (eval_u32lit C _ _ _ (by decide))
        (binary_bitAnd_u32 C (x / 2 ^ 8) 16711935 (lt_of_le_of_lt (Nat.div_le_self _ _) hxl) (by decide)))
      (binary_add_u32 C _ _)
  generalize hl₂ : setLocal l₁ (b + 3) (u32 P) = l₂
  have h3 : l₂ (b + 3) = some (u32 P) := by rw [← hl₂, setLocal_same]
  have e3 : (eval C ctx l₂ (.bin .sub .i32 0
      (.conv .i32 (.bin .add .u32 0 (.bin .bitAnd .u32 0 (.local (b + 3)) (GateUp.u32l 65535))
        (.bin .shr .u32 0 (.local (b + 3)) (GateUp.u32l 16)))) (GateUp.i32l 510))).run sh =
        some (i32 ((Y : Int) - 510), sh) := by
    have hz := binary_sub_i32_nat C Y 510 hYl (by decide)
    have hadd : (eval C ctx l₂ (.bin .add .u32 0 (.bin .bitAnd .u32 0 (.local (b + 3)) (GateUp.u32l 65535))
        (.bin .shr .u32 0 (.local (b + 3)) (GateUp.u32l 16)))).run sh = some (u32 Y, sh) := by
      rw [← hY]
      exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C h3 sh) (eval_u32lit C _ _ _ (by decide))
        (binary_bitAnd_u32 C _ 65535 (by omega) (by decide)))
        (eval_bin_u32 C (eval_local' C h3 sh) (eval_u32lit C _ _ _ (by decide))
          (binary_shr_u32 C _ 16 (by omega) (by decide))) (binary_add_u32 C _ _)
    exact eval_int C (by decide) (eval_conv C (t := .i32) hadd (convert_i32_u32 C _ hYl)) (eval_lit C _ _ _ _) hz
  have hyv : trellisYv s = (Y : Int) - 510 := by
    unfold trellisYv; rw [hP, show (P &&& 0xFFFF) = (P &&& 65535) from rfl, hY]
  rw [hyv]
  subst hl₂ hl₁
  refine ⟨_, .scope (.set e1 (.set e2 (.set e3 .leave))) (.inr rfl) (.nil _ _), setLocal_same _ _ _, fun j hj => ?_⟩
  rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]

/-- The inlined `trellis_y(s)` then `trellis_unrefined_bits_y`: codebook entry `s` in slot `b + 5`. -/
theorem exec_codebook (b : Nat) {l : Locals} {sh : Shared} {s : Nat} (h : l b = some (u32 s)) :
    ∃ l', Exec C ctx [trellisYAt b, .set (b + 4) (.local (b + 1)), unrefinedYAt (b + 4)] l sh .normal l' sh ∧
      l' (b + 5) = some (.f32 (codebook C s)) ∧ ∀ j, j ≤ b ∨ b + 6 < j → l' j = l j := by
  generalize hx : (s * 34038481 + 76625530) % 2 ^ 32 = x
  have hxl : x < 2 ^ 32 := by rw [← hx]; exact Nat.mod_lt _ (by decide)
  obtain ⟨P, hP, hPl⟩ : ∃ P, trellisP s = P ∧ P < 2 ^ 25 := ⟨_, rfl, trellisP_lt s⟩
  have hp : P = (x &&& 16711935) + (x / 2 ^ 8 &&& 16711935) := by rw [← hP, trellisP, hx]
  obtain ⟨Y, hY, hYl⟩ : ∃ Y, (P &&& 65535) + P / 2 ^ 16 = Y ∧ Y < 2 ^ 31 :=
    ⟨_, rfl, by have := Nat.and_le_right (n := P) (m := 65535); omega⟩
  have hcb : codebook C s = C.fmul (C.fadd (Val.ofF32Bits (0x4B000000 ||| Y)) (f32Neg (Val.ofF32Bits 0x4B0001FE)))
      (Val.ofF32Bits 0x3BDDB447) := by
    unfold codebook unrefinedBits trellisYv
    rw [hP, show (P &&& 0xFFFF) = (P &&& 65535) from rfl, hY, show ((Y : Int) - 510 + 510).toNat = Y by omega]
  rw [hcb]
  have e1 : (eval C ctx l (.bin .add .u32 0 (.bin .mul .u32 0 (.local b) (u32l 34038481)) (u32l 76625530))).run sh =
      some (u32 x, sh) := by
    rw [← hx, u32_mod]
    exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C h sh) (eval_u32lit C _ _ _ (by decide))
      (binary_mul_u32 C s 34038481)) (eval_u32lit C _ _ _ (by decide)) (binary_add_u32 C _ 76625530)
  generalize hl₁ : setLocal l (b + 2) (u32 x) = l₁
  have h2 : l₁ (b + 2) = some (u32 x) := by rw [← hl₁, setLocal_same]
  have e2 : (eval C ctx l₁ (.bin .add .u32 0 (.bin .bitAnd .u32 0 (.local (b + 2)) (u32l 16711935))
      (.bin .bitAnd .u32 0 (.bin .shr .u32 0 (.local (b + 2)) (u32l 8)) (u32l 16711935)))).run sh =
      some (u32 P, sh) := by
    rw [hp]
    exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C h2 sh) (eval_u32lit C _ _ _ (by decide))
      (binary_bitAnd_u32 C x 16711935 hxl (by decide)))
      (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h2 sh) (eval_u32lit C _ _ _ (by decide))
        (binary_shr_u32 C x 8 hxl (by decide))) (eval_u32lit C _ _ _ (by decide))
        (binary_bitAnd_u32 C (x / 2 ^ 8) 16711935 (lt_of_le_of_lt (Nat.div_le_self _ _) hxl) (by decide)))
      (binary_add_u32 C _ _)
  generalize hl₂ : setLocal l₁ (b + 3) (u32 P) = l₂
  have h3 : l₂ (b + 3) = some (u32 P) := by rw [← hl₂, setLocal_same]
  have e3 : (eval C ctx l₂ (.bin .sub .i32 0
      (.conv .i32 (.bin .add .u32 0 (.bin .bitAnd .u32 0 (.local (b + 3)) (u32l 65535))
        (.bin .shr .u32 0 (.local (b + 3)) (u32l 16)))) (i32l 510))).run sh = some (i32 ((Y : Int) - 510), sh) := by
    have hz : binary C .sub .i32 (.int .i32 Y) (.int .i32 510) = some (i32 ((Y : Int) - 510)) := by
      rw [← i32_nat _ (by omega), show Val.int .i32 510 = i32 510 from rfl]
      exact binary_sub_i32v C (by omega) (by omega) (by omega) (by omega) (by omega) (by omega)
    have hadd : (eval C ctx l₂ (.bin .add .u32 0 (.bin .bitAnd .u32 0 (.local (b + 3)) (u32l 65535))
        (.bin .shr .u32 0 (.local (b + 3)) (u32l 16)))).run sh = some (u32 Y, sh) := by
      rw [← hY]
      exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C h3 sh) (eval_u32lit C _ _ _ (by decide))
        (binary_bitAnd_u32 C _ 65535 (by omega) (by decide)))
        (eval_bin_u32 C (eval_local' C h3 sh) (eval_u32lit C _ _ _ (by decide))
          (binary_shr_u32 C _ 16 (by omega) (by decide))) (binary_add_u32 C _ _)
    exact eval_int C (by decide) (eval_conv C (t := .i32) hadd (convert_i32_u32 C _ hYl)) (eval_lit C _ _ _ _) hz
  generalize hl₃ : setLocal l₂ (b + 1) (i32 ((Y : Int) - 510)) = l₃
  have h1 : l₃ (b + 1) = some (i32 ((Y : Int) - 510)) := by rw [← hl₃, setLocal_same]
  generalize hl₄ : setLocal l₃ (b + 4) (i32 ((Y : Int) - 510)) = l₄
  have h4 : l₄ (b + 4) = some (i32 ((Y : Int) - 510)) := by rw [← hl₄, setLocal_same]
  have hor : 1258291200 ||| Y < 2 ^ 32 := Nat.or_lt_two_pow (by decide) (by omega)
  have e4 : (eval C ctx l₄ (.bitcast .f32 (.bin .bitOr .u32 0 (u32l 1258291200)
      (.conv .u32 (.bin .add .i32 0 (.local (b + 4)) (i32l 510)))))).run sh =
      some (.f32 (Val.ofF32Bits (0x4B000000 ||| Y)), sh) := by
    have hz : binary C .add .i32 (i32 ((Y : Int) - 510)) (.int .i32 510) = some (.int .i32 Y) := by
      rw [show Val.int .i32 510 = i32 510 from rfl, binary_add_i32v C (by omega) (by omega) (by omega) (by omega)
        (by omega) (by omega), i32_of_nat (n := Y) (by omega) (by omega)]
    exact eval_bitcast C (eval_bin_u32 C (eval_u32lit C _ _ _ (by decide))
      (eval_conv C (t := .u32) (eval_int C (by decide) (eval_local' C h4 sh) (eval_lit C _ _ _ _) hz)
        (convert_u32_i32 C _ hYl))
      (binary_bitOr_u32 C 1258291200 _ (by decide) (by omega))) (bitcast_f32_u32 _ hor)
  generalize hl₅ : setLocal l₄ (b + 6) (.f32 (Val.ofF32Bits (0x4B000000 ||| Y))) = l₅
  have h6 : l₅ (b + 6) = some (.f32 (Val.ofF32Bits (0x4B000000 ||| Y))) := by rw [← hl₅, setLocal_same]
  generalize hv : C.fmul (C.fadd (Val.ofF32Bits (0x4B000000 ||| Y)) (f32Neg (Val.ofF32Bits 0x4B0001FE)))
    (Val.ofF32Bits 0x3BDDB447) = v
  have e5 : (eval C ctx l₅ (.bin .mul .f32 0 (.bin .sub .f32 0 (.local (b + 6)) (f32l 0x4B0001FE))
      (f32l 0x3BDDB447))).run sh = some (.f32 v, sh) := by
    rw [← hv]
    exact eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_f32 C (.inr ⟨rfl, rfl⟩) (eval_local' C h6 sh)
      (eval_lit C _ _ _ _) rfl) (eval_lit C _ _ _ _) rfl
  refine ⟨setLocal l₅ (b + 5) (.f32 v), ?_, setLocal_same _ _ _, fun j hj => ?_⟩
  · have hy : Exec C ctx [trellisYAt b] l sh .normal l₃ sh :=
      .scope (.set e1 (by rw [hl₁]; exact .set e2 (by rw [hl₂]; exact .set e3 (by rw [hl₃]; exact .leave))))
        (.inr rfl) (.nil _ _)
    have hu : Exec C ctx [unrefinedYAt (b + 4)] l₄ sh .normal (setLocal l₅ (b + 5) (.f32 v)) sh :=
      .scope (.set e4 (by rw [hl₅]; exact .set e5 .leave)) (.inr rfl) (.nil _ _)
    exact hy.append (.set (eval_local' C h1 sh) (by rw [hl₄]; exact hu))
  · rw [setLocal_other _ _ (by omega), ← hl₅, setLocal_other _ _ (by omega), ← hl₄, setLocal_other _ _ (by omega),
      ← hl₃, setLocal_other _ _ (by omega), ← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_other _ _ (by omega)]

end Metal.Kernels.Trellis

namespace Metal.Kernels.Trellis
open Metal Metal.Core Inference.Contracts.Mlx

/-! ## The trellis decode on code words -/

/-- Little-endian `uint` word `n` of a buffer. -/
def word32 (B : ByteMemory.Bytes) (n : Nat) : Nat := bytesWord (cells B (4 * n) 4)
/-- Little-endian half word `n` of a buffer (a bf16 or half's bits). -/
def half (B : ByteMemory.Bytes) (n : Nat) : Nat := bytesWord (cells B (2 * n) 2)

theorem word32_lt (B : ByteMemory.Bytes) (n : Nat) : word32 B n < 2 ^ 32 := bytesWord_cells_lt B (4 * n)

theorem half_lt (X : ByteMemory.Bytes) (n : Nat) : half X n < 2 ^ 16 := by
  have := bytesWord_lt (cells X (2 * n) 2); rw [cells_length] at this; unfold half; omega

/-- The bits of a Trellis block of `K`-bit codes: its `8·K` words from word `base`, then its first word again
(the trellis is tail-biting: the last columns' 12-bit states wrap to the block's start). -/
def blockBits (K : Nat) (B : ByteMemory.Bytes) (base : Nat) : Nat :=
  runBits (fun i => word32 B (base + i % (8 * K))) (8 * K + 1)

/-- The 12-bit state of column `c` (of 256) of a block: its bits `K·(255 - c) …`. -/
def trellisCode (K : Nat) (B : ByteMemory.Bytes) (base c : Nat) : Nat :=
  blockBits K B base / 2 ^ (K * (255 - c)) % 2 ^ 12

/-- A half-precision scale. -/
def scale (S : ByteMemory.Bytes) (r : Nat) : Float32 := Float16.widen (Val.ofF16Bits (half S r))

/-- A run's words read from a block, from word `w0` on (`w0 + n ≤ 8·K + 1`): the block's state window. -/
theorem window_block {K : Nat} (B : ByteMemory.Bytes) (base w0 n off : Nat) (hn : w0 + n ≤ 8 * K + 1)
    (hoff : off + 12 ≤ 32 * n) :
    runBits (fun i => word32 B (base + (w0 + i) % (8 * K))) n / 2 ^ off % 2 ^ 12 =
      blockBits K B base / 2 ^ (32 * w0 + off) % 2 ^ 12 := by
  have h := runBits_slice (W := fun i => word32 B (base + i % (8 * K))) (fun i _ => word32_lt B _) w0 n hn
  rw [← h, window_mod _ _ _ hoff, Nat.div_div_eq_div_mul, ← Nat.pow_add]
  rfl

end Metal.Kernels.Trellis

namespace Metal.Kernels.GateUp
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis

/-! ## Expected outputs

The quantities of the source on the inputs' elements, with the operations the core applies. The core has no
contraction sites (its products feed `fma`s or are not added), so the compiler's fusion choices do not enter. -/

section Spec
variable (C : M1Max.Contract)

def zero : Float32 := Val.ofF32Bits 0
def one : Float32 := Val.ofF32Bits 0x3F800000
def bone : BF := Val.ofBf16Bits 0x3F80
def bzero : BF := Val.ofBf16Bits 0

/-- `xv` of column `c`: `x[c]` (bf16) as the float of its bits moved up 16 (`as_type<float>` of its half of the
`uint4` chunk). -/
def xval (X : ByteMemory.Bytes) (c : Nat) : Float32 := Val.ofF32Bits (half X c * 2 ^ 16)

/-- The weight of row `r`, column `c` (`gWeight`, `uWeight`): the codebook entry of the column's 12-bit trellis
state in its block of `K`-bit codes (block `c / 256` of the row, from word `(20·r + c / 256)·8·K`), times the
row's scale. -/
def weight (K : Nat) (Codes S : ByteMemory.Bytes) (r c : Nat) : Float32 :=
  C.fmul (codebook C (trellisCode K Codes ((20 * r + c / 256) * (8 * K)) (c % 256))) (scale S r)

/-- The `n`-th column a lane accumulates: run `lane + 32·(n / 32)` (`run += 32u`), its position `n % 32`
(`j = 8q + p`). -/
def laneCol (lane n : Nat) : Nat := 32 * (lane + 32 * (n / 32)) + n % 32

/-- A lane's accumulator of parity `par` after its first `n` columns: `gAcc`/`uAcc` (`par = 0`) take the even
positions, `gAcc2`/`uAcc2` the odd ones, each `fma(weight, xv, acc)`. -/
def laneAcc (w x : Nat → Float32) (lane par : Nat) : Nat → Float32
  | 0 => zero
  | n + 1 => if n % 2 = par then C.fma (w (laneCol lane n)) (x (laneCol lane n)) (laneAcc w x lane par n)
    else laneAcc w x lane par n

/-- `simd_sum(acc + acc2)` for row `r`: over the 32 lanes, each lane's two accumulators after its 160 columns. -/
def rowSum (K : Nat) (Codes S X : ByteMemory.Bytes) (r : Nat) : Float32 :=
  C.simdSum fun i =>
    C.fadd (laneAcc C (weight C K Codes S r) (xval X) i 0 160) (laneAcc C (weight C K Codes S r) (xval X) i 1 160)

/-- `TAIL == 1`'s `sigY = 1 / (1 + exp(abs(gateT)))` (bfloat, through MLX's float overloads). -/
def sigY (gateT : BF) : BF :=
  C.bfdiv bone (C.bfadd bone (C.narrow (C.fastExp (C.widen (C.narrow (C.fastFabs (C.widen gateT)))))))

/-- `mid[r]` from `gate` and `up`: `T(gate)` and `T(up)`, then the branch of `TAIL` that stays. -/
def tailOut (tail : Bool) (gate up : Float32) : BF :=
  match tail with
  | true =>
    let sigmoidT := if f32Compare (C.widen (C.narrow gate)) (C.widen bzero) = some .lt then sigY C (C.narrow gate)
      else C.bfsub bone (sigY C (C.narrow gate))
    C.bfmul (C.bfmul (C.narrow gate) sigmoidT) (C.narrow up)
  | false =>
    let sigmoidT := C.narrow (C.fdiv one (C.fadd one (C.exp (f32Neg (C.widen (C.narrow gate))))))
    C.bfmul (C.bfmul (C.narrow gate) sigmoidT) (C.narrow up)

/-- The inputs: x, the gate codes and scales, the up codes and scales, and their base alignments. -/
structure In where
  X : ByteMemory.Bytes
  Gc : ByteMemory.Bytes
  Gs : ByteMemory.Bytes
  Uc : ByteMemory.Bytes
  Us : ByteMemory.Bytes
  ax : Nat
  ag : Nat
  as : Nat
  au : Nat
  aus : Nat

/-- `mid[r]`. -/
def midOut (kg ku : Nat) (tail : Bool) (X Gc Gs Uc Us : ByteMemory.Bytes) (r : Nat) : BF :=
  tailOut C tail (rowSum C kg Gc Gs X r) (rowSum C ku Uc Us X r)

/-- Byte `b` of `mid` [1, 17408] bf16. -/
def expected (kg ku : Nat) (tail : Bool) (X Gc Gs Uc Us : ByteMemory.Bytes) (b : Nat) : BitVec 8 :=
  if b < 34816 then (wordBytes 2 (Val.bf16Bits (midOut C kg ku tail X Gc Gs Uc Us (b / 2)))).getD (b % 2) 0 else 0

end Spec

/-! ## The launch -/

/-- Bytes of `K`-bit codes `uint32 [17408, 160·K]`. -/
def codesBytes (k : Nat) : Nat := 17408 * 640 * k

def bufs (kg ku : Nat) (I : In) : List Buffer :=
  [⟨.device, 10240, I.ax, I.X⟩, ⟨.device, codesBytes kg, I.ag, I.Gc⟩, ⟨.device, 34816, I.as, I.Gs⟩,
    ⟨.device, codesBytes ku, I.au, I.Uc⟩, ⟨.device, 34816, I.aus, I.Us⟩]

/-- MLX's launch at `gateUpConfig`: grid [1024, 160], threadgroup [1024], `mid` [1, 17408] bf16. -/
def launch (kg ku : Nat) (tail : Bool) (I : In) (initial : Nat → ByteMemory.Bytes) : Launch :=
  ⟨core kg ku tail, (1024, 160, 1), (1024, 1, 1), buffers (bufs kg ku I) [34816] 16 initial⟩

/-- `xs[c]`'s chunk of `x`: chunk `c / 160` of run `c % 160`. -/
def xsIdx (c : Nat) : Nat := c % 160 * 4 + c / 160

/-- The order rows are written in: threadgroup `(r % 5120) / 32`, SIMD-group `r % 32`, its `(r / 5120)`-th row. -/
def ord (r : Nat) : Nat := r % 5120 * 4 + r / 5120

/-- The writer of each device byte: `mid[r]` by lane 0 of SIMD-group `r % 32` of threadgroup `(r % 5120) / 32`. -/
def dev (region byte : Nat) : Option Writer :=
  if region = 5 then some ⟨byte / 2 % 5120 / 32 * 1024 + byte / 2 % 32 * 32, byte / 2 % 5120 / 32, 0⟩ else none

/-- The owner of each threadgroup byte: before threadgroup `g`'s barrier (epoch `g`), `codebook[e]` is thread
`e % 1024`'s and `xs[c]` thread `c`'s; after it nothing is written. -/
def tgo (g e region byte : Nat) : Option Nat :=
  if e = g then (if region = 6 then some (g * 1024 + byte / 4 % 1024)
    else if region = 7 then some (g * 1024 + byte / 16) else none) else none

/-- The regions as the kernel uses them. -/
structure Shape (L : Launch) (kg ku : Nat) (I : In) : Prop where
  r0 : L.regions 0 = some ⟨.device, 10240, I.ax⟩
  r1 : L.regions 1 = some ⟨.device, codesBytes kg, I.ag⟩
  r2 : L.regions 2 = some ⟨.device, 34816, I.as⟩
  r3 : L.regions 3 = some ⟨.device, codesBytes ku, I.au⟩
  r4 : L.regions 4 = some ⟨.device, 34816, I.aus⟩
  r5 : L.regions 5 = some ⟨.device, 34816, 16⟩
  r6 : L.regions 6 = some ⟨.threadgroup, 16384, 4⟩
  r7 : L.regions 7 = some ⟨.threadgroup, 10240, 16⟩
  rg : ∀ th, L.regions (8 + th * 4) = some ⟨.thread, 4 * (kg + 1), 4⟩
  rgv : ∀ th, L.regions (8 + th * 4 + 1) = some ⟨.thread, 4 * (kg + 1), 4⟩
  ru : ∀ th, L.regions (8 + th * 4 + 2) = some ⟨.thread, 4 * (ku + 1), 4⟩
  ruv : ∀ th, L.regions (8 + th * 4 + 3) = some ⟨.thread, 4 * (ku + 1), 4⟩
  ax : I.ax % 16 = 0
  ag : I.ag % 4 = 0
  as : I.as % 2 = 0
  au : I.au % 4 = 0
  aus : I.aus % 2 = 0

theorem launch_shape {kg ku : Nat} {tail : Bool} {I : In} {initial : Nat → ByteMemory.Bytes}
    (hax : I.ax % 16 = 0) (hag : I.ag % 4 = 0) (has : I.as % 2 = 0) (hau : I.au % 4 = 0) (haus : I.aus % 2 = 0) :
    Shape (launch kg ku tail I initial) kg ku I := by
  have hb : (launch kg ku tail I initial).buffers = buffers (bufs kg ku I) [34816] 16 initial := rfl
  have ht : ∀ th j t n, (launch kg ku tail I initial).kernel.threadArrays[j]? = some (t, n) →
      (launch kg ku tail I initial).regions (8 + th * 4 + j) = some ⟨.thread, t.bytes * n, alignment t⟩ :=
    fun th j t n h => Launch.regions_threadArray _ th j t n h
  refine ⟨regions_input hb 0 (by simp [bufs]), regions_input hb 1 (by simp [bufs]),
    regions_input hb 2 (by simp [bufs]), regions_input hb 3 (by simp [bufs]), regions_input hb 4 (by simp [bufs]),
    regions_output hb 0 (by simp), Launch.regions_groupArray _ 0 (.scalar .f32) 4096 rfl,
    Launch.regions_groupArray _ 1 (.vec .u32 4) 640 rfl, fun th => ?_, fun th => ?_, fun th => ?_, fun th => ?_,
    hax, hag, has, hau, haus⟩
  · have := ht th 0 (.scalar .u32) (kg + 1) rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 1 (.scalar .u32) (kg + 1) rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 2 (.scalar .u32) (ku + 1) rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 3 (.scalar .u32) (ku + 1) rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this

/-! ## Memory -/

section Memory
variable (C : M1Max.Contract)

/-- Memory during the launch: inputs intact, the epochs (`ge` the threadgroup epoch), the codebook entries with
`cbOk` and `xs` entries with `xsOk` written, the rows of `mid` before position `P` as `out`, and every access so
far keeping the ownership discipline. -/
structure Mem (L : Launch) (I : In) (out : Nat → BF) (P ge : Nat) (cbOk xsOk : Nat → Prop) (sh : Shared) : Prop where
  regions : sh.regions = L.regions
  x : sh.bytes 0 = I.X
  gc : sh.bytes 1 = I.Gc
  gs : sh.bytes 2 = I.Gs
  uc : sh.bytes 3 = I.Uc
  us : sh.bytes 4 = I.Us
  deve : sh.deviceEpoch = 0
  grpe : sh.groupEpoch = ge
  cb : ∀ e < 4096, cbOk e → cells (sh.bytes 6) (4 * e) 4 = wordBytes 4 (Val.f32Bits (codebook C e))
  xs : ∀ c < 640, xsOk c → cells (sh.bytes 7) (16 * c) 16 = cells I.X (16 * xsIdx c) 16
  mid : ∀ r < 17408, ord r < P → cells (sh.bytes 5) (2 * r) 2 = wordBytes 2 (Val.bf16Bits (out r))
  log : ∀ a ∈ sh.log, Owned L dev tgo a

variable {C} {L : Launch} {I : In} {out : Nat → BF} {P ge : Nat} {cbOk xsOk : Nat → Prop} {sh : Shared}

theorem Mem.mono (h : Mem C L I out P ge cbOk xsOk sh) {cbOk' xsOk' : Nat → Prop} (hc : ∀ e < 4096, cbOk' e → cbOk e)
    (hx : ∀ c < 640, xsOk' c → xsOk c) : Mem C L I out P ge cbOk' xsOk' sh :=
  ⟨h.regions, h.x, h.gc, h.gs, h.uc, h.us, h.deve, h.grpe, fun e he hc' => h.cb e he (hc e he hc'),
    fun c hc' hx' => h.xs c hc' (hx c hc' hx'), h.mid, h.log⟩

/-- A read of an input, or of threadgroup memory after its threadgroup's writes. -/
theorem Mem.rd (h : Mem C L I out P ge cbOk xsOk sh) (ctx : Ctx) (reg o n : Nat)
    (hreg : reg < 5 ∨ ((reg = 6 ∨ reg = 7) ∧ ge ≠ ctx.group)) (hS : Shape L kg ku I) :
    Mem C L I out P ge cbOk xsOk (rdn ctx sh reg o n) :=
  ⟨h.regions, h.x, h.gc, h.gs, h.uc, h.us, h.deve, h.grpe, h.cb, h.xs, h.mid, forall_log _ n _ (fun j _ => by
    rcases hreg with hreg | ⟨h67, hne⟩
    · obtain ⟨r, hr, hs⟩ : ∃ r, L.regions reg = some r ∧ r.space ≠ .threadgroup := by
        rcases (show reg = 0 ∨ reg = 1 ∨ reg = 2 ∨ reg = 3 ∨ reg = 4 by omega) with rfl | rfl | rfl | rfl | rfl
        exacts [⟨_, hS.r0, by simp⟩, ⟨_, hS.r1, by simp⟩, ⟨_, hS.r2, by simp⟩, ⟨_, hS.r3, by simp⟩,
          ⟨_, hS.r4, by simp⟩]
      exact owned_device_read L dev tgo ctx sh reg (o + j) r hr hs (by simp [dev]; omega)
    · rcases h67 with rfl | rfl
      · exact owned_group_read L dev tgo ctx sh 6 (o + j) _ hS.r6 rfl (by simp [tgo, h.grpe, hne])
      · exact owned_group_read L dev tgo ctx sh 7 (o + j) _ hS.r7 rfl (by simp [tgo, h.grpe, hne])) h.log⟩

/-- A write to thread memory. -/
theorem Mem.tput (h : Mem C L I out P ge cbOk xsOk sh) {reg : Nat} (o : Nat) (bs : List (BitVec 8)) (hreg : 8 ≤ reg) :
    Mem C L I out P ge cbOk xsOk (tput sh reg o bs) :=
  ⟨h.regions, by rw [tput_other _ _ _ (by omega)]; exact h.x, by rw [tput_other _ _ _ (by omega)]; exact h.gc,
    by rw [tput_other _ _ _ (by omega)]; exact h.gs, by rw [tput_other _ _ _ (by omega)]; exact h.uc,
    by rw [tput_other _ _ _ (by omega)]; exact h.us, h.deve, h.grpe,
    fun e he hc => by rw [tput_other _ _ _ (by omega)]; exact h.cb e he hc,
    fun c hc hx => by rw [tput_other _ _ _ (by omega)]; exact h.xs c hc hx,
    fun r hr hp => by rw [tput_other _ _ _ (by omega)]; exact h.mid r hr hp, h.log⟩

/-- Thread `e % 1024` of threadgroup `g` writes `codebook[e]` before the barrier. -/
theorem Mem.wcb (h : Mem C L I out P g cbOk xsOk sh) (hS : Shape L kg ku I) (ctx : Ctx) (e : Nat) (he : e < 4096)
    (ht : ctx.thread = g * 1024 + e % 1024) (hg : ctx.group = g) :
    Mem C L I out P g (fun e' => cbOk e' ∨ e' = e) xsOk
      (wrn ctx sh 6 (4 * e) 4 (wordBytes 4 (Val.f32Bits (codebook C e)))) := by
  have hl : (wordBytes 4 (Val.f32Bits (codebook C e))).length = 4 := wordBytes_length 4 _
  refine ⟨h.regions, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.x, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.gc,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.gs, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.uc,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.us, h.deve, h.grpe, fun e' he' hc => ?_,
    fun c hc hx => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.xs c hc hx,
    fun r hr hp => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.mid r hr hp,
    forall_log _ 4 _ (fun j hj => owned_group L dev tgo ctx sh 6 (4 * e + j) _ hS.r6 true rfl
      (by simp only [tgo, h.grpe, hg, ite_true]; rw [ht]; congr 2; omega)) h.log⟩
  rw [wrn_same]
  by_cases hee : e' = e
  · subst hee
    have := cells_writeBytes_same (sh.bytes 6) (4 * e') (wordBytes 4 (Val.f32Bits (codebook C e')))
    rwa [hl] at this
  · rw [cells_writeBytes_other _ _ _ _ _ (by rw [hl]; omega)]
    exact h.cb e' he' (hc.resolve_right hee)

/-- Thread `c` of threadgroup `g` writes `xs[c]` before the barrier. -/
theorem Mem.wxs (h : Mem C L I out P g cbOk xsOk sh) (hS : Shape L kg ku I) (ctx : Ctx) (c : Nat) (hc : c < 640)
    (ht : ctx.thread = g * 1024 + c) (hg : ctx.group = g) :
    Mem C L I out P g cbOk (fun c' => xsOk c' ∨ c' = c)
      (wrn ctx sh 7 (16 * c) 16 (cells I.X (16 * xsIdx c) 16)) := by
  have hl : (cells I.X (16 * xsIdx c) 16).length = 16 := cells_length _ _ _
  refine ⟨h.regions, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.x, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.gc,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.gs, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.uc,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.us, h.deve, h.grpe,
    fun e he hc => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.cb e he hc, fun c' hc' hx => ?_,
    fun r hr hp => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.mid r hr hp,
    forall_log _ 16 _ (fun j hj => owned_group L dev tgo ctx sh 7 (16 * c + j) _ hS.r7 true rfl
      (by simp only [tgo, h.grpe, hg, ite_true]; rw [ht]; simp; omega)) h.log⟩
  rw [wrn_same]
  by_cases hcc : c' = c
  · subst hcc
    have := cells_writeBytes_same (sh.bytes 7) (16 * c') (cells I.X (16 * xsIdx c') 16)
    rwa [hl] at this
  · rw [cells_writeBytes_other _ _ _ _ _ (by rw [hl]; omega)]
    exact h.xs c' hc' (hx.resolve_right hcc)

theorem ord_inj {r' r : Nat} (hr' : r' < 17408) (hr : r < 17408) (h : ord r' = ord r) : r' = r := by
  unfold ord at h
  have h1 : r' / 5120 < 4 := by clear h; omega
  have h2 : r / 5120 < 4 := by clear h; omega
  have h' : r' / 5120 + r' % 5120 * 4 = r / 5120 + r % 5120 * 4 := by rw [Nat.add_comm, h, Nat.add_comm]
  have e : r' / 5120 = r / 5120 := by
    have := congrArg (· % 4) h'
    simp only [Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt h1, Nat.mod_eq_of_lt h2] at this
    exact this
  rw [e] at h'
  have e2 : r' % 5120 = r % 5120 := Nat.eq_of_mul_eq_mul_right (by decide) (Nat.add_left_cancel h')
  clear h h'
  omega

theorem ord_lt_of_ne {r' r P : Nat} (hr' : r' < 17408) (hr : r < 17408) (hP : ord r = P) (hp : ord r' < P + 1)
    (hne : r' ≠ r) : ord r' < P := by
  have h1 : ord r' ≠ ord r := fun h => hne (ord_inj hr' hr h)
  rw [hP] at h1
  omega

/-- Lane 0 of SIMD-group `r % 32` of threadgroup `(r % 5120) / 32` writes `mid[r]`, the next row in order. -/
theorem Mem.wmid (h : Mem C L I out P ge cbOk xsOk sh) (hS : Shape L kg ku I) (ctx : Ctx) (r : Nat) (hr : r < 17408)
    (hP : ord r = P) (ht : ctx.thread = r % 5120 / 32 * 1024 + r % 32 * 32) (hg : ctx.group = r % 5120 / 32) :
    Mem C L I out (P + 1) ge cbOk xsOk (wrn ctx sh 5 (2 * r) 2 (wordBytes 2 (Val.bf16Bits (out r)))) := by
  have hl : (wordBytes 2 (Val.bf16Bits (out r))).length = 2 := wordBytes_length 2 _
  refine ⟨h.regions, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.x, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.gc,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.gs, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.uc,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.us, h.deve, h.grpe,
    fun e he hc => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.cb e he hc,
    fun c hc hx => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.xs c hc hx, fun r' hr' hp => ?_,
    forall_log _ 2 _ (fun j hj => owned_device L dev tgo ctx sh 5 (2 * r + j) _ hS.r5 true (by simp)
      ⟨(2 * r + j) / 2 % 5120 / 32 * 1024 + (2 * r + j) / 2 % 32 * 32, (2 * r + j) / 2 % 5120 / 32, 0⟩
      (by simp [dev]) (by rw [ht]; dsimp only; rw [show (2 * r + j) / 2 = r by omega])
      (by rw [hg]; dsimp only; rw [show (2 * r + j) / 2 = r by omega]) (by rw [h.deve])) h.log⟩
  rw [wrn_same]
  by_cases hrr : r' = r
  · subst hrr
    have := cells_writeBytes_same (sh.bytes 5) (2 * r') (wordBytes 2 (Val.bf16Bits (out r')))
    rwa [hl] at this
  · rw [cells_writeBytes_other _ _ _ _ _ (by rw [hl]; omega)]
    exact h.mid r' hr' (ord_lt_of_ne hr' hr hP hp hrr)

/-- A position no row has. -/
theorem Mem.bump (h : Mem C L I out P ge cbOk xsOk sh) (hno : ∀ r < 17408, ord r ≠ P) :
    Mem C L I out (P + 1) ge cbOk xsOk sh :=
  ⟨h.regions, h.x, h.gc, h.gs, h.uc, h.us, h.deve, h.grpe, h.cb, h.xs,
    fun r hr hp => h.mid r hr (by have := hno r hr; omega), h.log⟩

/-- The barrier (threadgroup memory only). -/
theorem Mem.pass (h : Mem C L I out P ge cbOk xsOk sh) : Mem C L I out P (ge + 1) cbOk xsOk (pass false true sh) :=
  ⟨h.regions, h.x, h.gc, h.gs, h.uc, h.us, by simp [Metal.pass, h.deve], by simp [Metal.pass, h.grpe], h.cb, h.xs,
    h.mid, h.log⟩

/-- A threadgroup starts: its threadgroup arrays hold garbage. -/
theorem Mem.reset (h : Mem C L I out P ge cbOk xsOk sh) (hb : L.buffers.length = 6) (garbage : Garbage) (g : Nat) :
    Mem C L I out P ge (fun _ => False) (fun _ => False) { sh with bytes := L.resetGroup garbage g sh.bytes } :=
  ⟨h.regions, by show L.resetGroup garbage g sh.bytes 0 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.x,
    by show L.resetGroup garbage g sh.bytes 1 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.gc,
    by show L.resetGroup garbage g sh.bytes 2 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.gs,
    by show L.resetGroup garbage g sh.bytes 3 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.uc,
    by show L.resetGroup garbage g sh.bytes 4 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.us,
    h.deve, h.grpe, fun _ _ hf => hf.elim, fun _ _ hf => hf.elim,
    fun r hr hp => by show cells (L.resetGroup garbage g sh.bytes 5) (2 * r) 2 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.mid r hr hp,
    h.log⟩

end Memory

end Metal.Kernels.GateUp

namespace Metal.Kernels.GateUp
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis

/-! ## A thread -/

/-- Lane `i` of SIMD-group `s` of threadgroup `g`. -/
structure Lane (ctx : Ctx) (g s i : Nat) : Prop where
  tpos : ctx.coord .threadPositionInThreadgroup = u32x3 (32 * s + i) 0 0
  gpos : ctx.coord .threadPositionInGrid = u32x3 (32 * s + i) g 0
  ngroups : ctx.coord .threadgroupsPerGrid = u32x3 1 160 1
  lane : ctx.coord .threadIndexInSimdgroup = u32 i
  sg : ctx.coord .simdgroupIndexInThreadgroup = u32 s
  thread : ctx.thread = g * 1024 + (32 * s + i)
  group : ctx.group = g
  ga0 : ctx.groupArray 0 = 6
  ga1 : ctx.groupArray 1 = 7
  ta : ∀ j, ctx.threadArray j = 8 + (g * 1024 + (32 * s + i)) * 4 + j
  hg : g < 160
  hs : s < 32
  hi : i < 32

theorem launch_tiles {kg ku : Nat} {tail : Bool} {I : In} {initial : Nat → ByteMemory.Bytes} :
    (launch kg ku tail I initial).Tiles 1024 1 1 1 160 1 32 := ⟨rfl, rfl, rfl, by decide⟩

theorem lane_of {kg ku : Nat} {tail : Bool} {I : In} {initial : Nat → ByteMemory.Bytes} (fuse : Nat → Bool) {g : Nat}
    (hg : g < 160) (s : Fin 32) (i : Fin 32) :
    Lane ((launch kg ku tail I initial).ctxAt fuse 0 g 0 (32 * s + i)) g s i := by
  have hs := s.isLt; have hi := i.isLt
  refine ⟨?_, ?_, ?_, Launch.ctxAt_lane _ _ _ _ _ _ _, Launch.ctxAt_simd _ _ _ _ _ _ _, ?_, ?_, rfl, rfl, fun j => ?_,
    hg, hs, hi⟩
  · rw [launch_tiles.threadPositionInThreadgroup, show (32 * s.val + i.val) % 1024 = 32 * s + i by omega,
      show (32 * s.val + i.val) / 1024 % 1 = 0 by omega, show (32 * s.val + i.val) / (1024 * 1) = 0 by omega]
  · rw [launch_tiles.threadPositionInGrid, show 0 * 1024 + (32 * s.val + i.val) % 1024 = 32 * s + i by omega,
      show g * 1 + (32 * s.val + i.val) / 1024 % 1 = g by omega, show 0 * 1 + (32 * s.val + i.val) / (1024 * 1) = 0 by omega]
  · rw [launch_tiles.threadgroupsPerGrid]
  · rw [launch_tiles.thread]; omega
  · rw [launch_tiles.group_id]; omega
  · rw [launch_tiles.threadArray, show (launch kg ku tail I initial).buffers.length = 6 from rfl,
      show (launch kg ku tail I initial).groupArrays = 2 from rfl, show (launch kg ku tail I initial).threadArrays = 4 from rfl]
    omega

/-- The buffer and threadgroup-array pointers. -/
structure Fix1 (l : Locals) : Prop where
  l0 : l 0 = some (.ptr ⟨0, 0, .scalar .bf16⟩)
  l1 : l 1 = some (.ptr ⟨1, 0, .scalar .u32⟩)
  l2 : l 2 = some (.ptr ⟨2, 0, .scalar .f16⟩)
  l3 : l 3 = some (.ptr ⟨3, 0, .scalar .u32⟩)
  l4 : l 4 = some (.ptr ⟨4, 0, .scalar .f16⟩)
  l5 : l 5 = some (.ptr ⟨5, 0, .scalar .bf16⟩)
  l6 : l 6 = some (.ptr ⟨6, 0, .scalar .f32⟩)
  l7 : l 7 = some (.ptr ⟨7, 0, .vec .u32 4⟩)

theorem Fix1.of_eq {l l' : Locals} (h : Fix1 l) (h' : ∀ j, j ≤ 7 → l' j = l j) : Fix1 l' :=
  ⟨(h' 0 (by omega)).trans h.l0, (h' 1 (by omega)).trans h.l1, (h' 2 (by omega)).trans h.l2,
    (h' 3 (by omega)).trans h.l3, (h' 4 (by omega)).trans h.l4, (h' 5 (by omega)).trans h.l5,
    (h' 6 (by omega)).trans h.l6, (h' 7 (by omega)).trans h.l7⟩

theorem Fix1.set {l : Locals} (h : Fix1 l) {j : Nat} (v : Val) (hj : 7 < j) : Fix1 (setLocal l j v) :=
  h.of_eq fun k hk => setLocal_other _ _ (by omega)

/-! ### Before the barrier: the codebook and `xs` -/

section Phase1
variable (C : M1Max.Contract) {L : Launch} {kg ku : Nat} {I : In} {out : Nat → BF} {P g : Nat} {ctx : Ctx}

/-- The declarations before the loops. -/
def pre : List CStmt := (body 0 0 false).take 8

theorem fix1_pre (ctx : Ctx) (hga0 : ctx.groupArray 0 = 6) (hga1 : ctx.groupArray 1 = 7) (sh : Shared) :
    ∃ l, Exec C ctx pre (fun _ => none) sh .normal l sh ∧ Fix1 l := by
  refine ⟨_, .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <|
    .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .array <| .array <| .nil _ _,
    ⟨by simp [setLocal], by simp [setLocal], by simp [setLocal], by simp [setLocal], by simp [setLocal],
      by simp [setLocal], by simp [setLocal, hga0], by simp [setLocal, hga1]⟩⟩

/-- At the `k`-th test of the codebook loop of thread `t`. -/
def FillI (L : Launch) (I : In) (out : Nat → BF) (P g t : Nat) (k : Nat) (l : Locals) (sh : Shared) : Prop :=
  Fix1 l ∧ l 8 = some (u32 (t + 1024 * k)) ∧
    Mem C L I out P g (fun e => e % 1024 < t ∨ (e % 1024 = t ∧ e / 1024 < k)) (fun c => c < t) sh

theorem fill_loop (hS : Shape L kg ku I) (hl : Lane ctx g s i) {l : Locals} {sh : Shared}
    (h0 : FillI C L I out P g (32 * s + i) 0 l sh) :
    ∃ l' sh', Exec C ctx [fillLoop] l sh .normal l' sh' ∧ FillI C L I out P g (32 * s + i) 4 l' sh' := by
  have hs := hl.hs; have hi := hl.hi
  refine Exec.loop_count 4 (FillI C L I out P g (32 * s + i)) (FillI C L I out P g (32 * s + i))
    (fun k hk l sh hI => ⟨sh, ?_, hI⟩) (fun k hk l sh hI => ?_) h0
  · have h := eval_lt_u32 C (ctx := ctx) (sh := sh) (b := 4096) hI.2.1 (by omega) (by decide)
    rwa [show decide (32 * s + i + 1024 * k < 4096) = decide (k < 4) from decide_eq_decide.mpr (by omega)] at h
  · obtain ⟨hF, h8, hm⟩ := hI
    have he : 32 * s + i + 1024 * k < 4096 := by omega
    obtain ⟨l₂, hcb, h14, hag⟩ := exec_codebook C (ctx := ctx) 9 (l := setLocal l 9 (u32 (32 * s + i + 1024 * k)))
      (sh := sh) (s := 32 * s + i + 1024 * k) (setLocal_same _ _ _)
    have h6 : l₂ 6 = some (.ptr ⟨6, 0, .scalar .f32⟩) := by rw [hag 6 (by omega), setLocal_other _ _ (by omega)]; exact hF.l6
    have h8' : l₂ 8 = some (u32 (32 * s + i + 1024 * k)) := by rw [hag 8 (by omega), setLocal_other _ _ (by omega)]; exact h8
    have hp := eval_ptr_u32 C (ctx := ctx) (eval_local' C h6 sh) (eval_local' C h8' sh) (by omega)
    rw [show (32 * s + i + 1024 * k) * (Ty.scalar .f32).bytes = 4 * (32 * s + i + 1024 * k) by
      simp [Ty.bytes, Scalar.bytes]; ring] at hp
    have hst := store_shared ctx .f32 sh 6 (4 * (32 * s + i + 1024 * k)) _ _ _ (by rw [hm.regions]; exact hS.r6)
      (by simp) (by simp) (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega)
      (encode_f32 (codebook C (32 * s + i + 1024 * k)))
    have hm' := hm.wcb hS ctx (32 * s + i + 1024 * k) he (by rw [hl.thread]; omega) hl.group
    rw [show Scalar.f32.bytes = 4 from rfl] at hst
    generalize wrn ctx sh 6 (4 * (32 * s + i + 1024 * k)) 4
      (wordBytes 4 (Val.f32Bits (codebook C (32 * s + i + 1024 * k)))) = sh₁ at hst hm'
    refine ⟨.normal, l₂, sh₁, setLocal l₂ 8 (u32 (32 * s + i + 1024 * k + 1024)), sh₁, .inl rfl, ?_, .set (eval_bin_u32 C (eval_local' C h8' _) (eval_u32lit C _ _ 1024 (by decide))
      (binary_add_u32 C _ 1024)) (.nil _ _), ⟨?_, by rw [setLocal_same, show 32 * s + i + 1024 * k + 1024 = 32 * s + i + 1024 * (k + 1) by ring], ?_⟩⟩
    · show Exec C ctx (.set 9 (.local 8) :: ([trellisYAt 9, .set (9 + 4) (.local (9 + 1)), unrefinedYAt (9 + 4)] ++
        [.store (.scalar .f32) (.offset (.local 6) (.local 8)) (.local 14)])) l sh .normal l₂ _
      exact .set (eval_local' C h8 sh) (hcb.append (.store hp (eval_local' C h14 sh) hst (.nil _ _)))
    · exact (hF.of_eq fun j hj => by rw [hag j (by omega), setLocal_other _ _ (by omega)]).set _ (by omega)
    · refine hm'.mono (cbOk' := fun e => e % 1024 < 32 * s + i ∨ (e % 1024 = 32 * s + i ∧ e / 1024 < k + 1))
        (xsOk' := fun c => c < 32 * s + i) (fun e _ h => ?_) (fun c _ h => h)
      rcases h with h | ⟨h1, h2⟩
      · exact .inl (.inl h)
      · by_cases hk : e / 1024 < k
        · exact .inl (.inr ⟨h1, hk⟩)
        · exact .inr (by omega)

/-- At the `k`-th test of the `xs` loop of thread `t`. -/
def XsI (L : Launch) (I : In) (out : Nat → BF) (P g t : Nat) (k : Nat) (l : Locals) (sh : Shared) : Prop :=
  Fix1 l ∧ l 16 = some (u32 (t + 1024 * k)) ∧
    Mem C L I out P g (fun e => e % 1024 < t + 1) (fun c => c < t ∨ (c = t ∧ 0 < k)) sh

theorem xs_loop (hS : Shape L kg ku I) (hl : Lane ctx g s i) {l : Locals} {sh : Shared}
    (h0 : XsI C L I out P g (32 * s + i) 0 l sh) :
    ∃ l' sh', Exec C ctx [xsLoop] l sh .normal l' sh' ∧
      XsI C L I out P g (32 * s + i) (if 32 * s + i < 640 then 1 else 0) l' sh' := by
  have hs := hl.hs; have hi := hl.hi
  refine Exec.loop_count (if 32 * s + i < 640 then 1 else 0) (XsI C L I out P g (32 * s + i))
    (XsI C L I out P g (32 * s + i)) (fun k hk l sh hI => ⟨sh, ?_, hI⟩) (fun k hk l sh hI => ?_) h0
  · have h := eval_lt_u32 C (ctx := ctx) (sh := sh) (b := 640) hI.2.1 (by split at hk <;> omega) (by decide)
    rwa [show decide (32 * s + i + 1024 * k < 640) = decide (k < if 32 * s + i < 640 then 1 else 0) from
      decide_eq_decide.mpr (by split at hk <;> split <;> omega)] at h
  · obtain ⟨hF, h16, hm⟩ := hI
    have ht : 32 * s + i < 640 := by split at hk <;> omega
    have hk0 : k = 0 := by split at hk <;> omega
    subst hk0
    rw [Nat.mul_zero, Nat.add_zero] at h16
    have hp := eval_ptr_u32 C (ctx := ctx) (eval_local' C hF.l7 sh) (eval_local' C h16 sh) (by omega)
    rw [show (32 * s + i) * (Ty.vec .u32 4).bytes = 16 * (32 * s + i) by simp [Ty.bytes, Scalar.bytes]; ring] at hp
    have hidx : (eval C ctx l xsIndex).run sh = some (u32 (xsIdx (32 * s + i)), sh) :=
      eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h16 sh) (eval_u32lit C _ _ 160 (by decide))
        (binary_rem_u32 C _ 160 (by omega) (by decide) (by decide))) (eval_u32lit C _ _ 4 (by decide))
        (binary_mul_u32 C _ 4)) (eval_bin_u32 C (eval_local' C h16 sh) (eval_u32lit C _ _ 160 (by decide))
        (binary_div_u32 C _ 160 (by omega) (by decide) (by decide))) (binary_add_u32 C _ _)
    have hxi : xsIdx (32 * s + i) < 640 := by unfold xsIdx; omega
    have hsrc : (eval C ctx l (.offset (.ptrCast (.vec .u32 4) (.local 0)) xsIndex)).run sh =
        some (.ptr ⟨0, ((16 * xsIdx (32 * s + i) : Nat) : Int), .vec .u32 4⟩, sh) := by
      have := eval_ptr_u32 C (ctx := ctx) (eval_ptrCast C (t := .vec .u32 4) (eval_local' C hF.l0 sh)) hidx (by omega)
      rwa [show xsIdx (32 * s + i) * (Ty.vec .u32 4).bytes = 16 * xsIdx (32 * s + i) by
        simp [Ty.bytes, Scalar.bytes]; ring] at this
    have hload := load_vec4 ctx sh 0 (16 * xsIdx (32 * s + i)) _ (by rw [hm.regions]; exact hS.r0) (by simp)
      hS.ax (by omega) (by simp; omega)
    rw [hm.x] at hload
    have hm1 := hm.rd ctx 0 (16 * xsIdx (32 * s + i)) 16 (.inl (by decide)) hS
    have hst := store_vec4 ctx (rdn ctx sh 0 (16 * xsIdx (32 * s + i)) 16) 7 (16 * (32 * s + i)) _ I.X
      (16 * xsIdx (32 * s + i)) (by rw [rdn_regions, hm.regions]; exact hS.r7) (by simp) (by simp) (by decide)
      (by omega) (by simp; omega)
    have hm2 := hm1.wxs hS ctx (32 * s + i) ht (by rw [hl.thread]) hl.group
    generalize wrn ctx (rdn ctx sh 0 (16 * xsIdx (32 * s + i)) 16) 7 (16 * (32 * s + i)) 16
      (cells I.X (16 * xsIdx (32 * s + i)) 16) = sh₂ at hst hm2
    refine ⟨.normal, l, sh₂, setLocal l 16 (u32 (32 * s + i + 1024)), sh₂, .inl rfl,
      .store hp ((eval_load C _ _ _ _ _ _ _ hsrc).trans hload) hst (.nil _ _),
      .set (eval_bin_u32 C (eval_local' C h16 _) (eval_u32lit C _ _ 1024 (by decide)) (binary_add_u32 C _ 1024)) (.nil _ _),
      hF.set _ (by omega), by rw [setLocal_same, Nat.zero_add, Nat.mul_one], ?_⟩
    exact hm2.mono (fun e _ h => h) (fun c _ h => by rcases h with h | ⟨h, -⟩ <;> omega)

/-- The code after the barrier. -/
def rest1 (kg ku : Nat) (tail : Bool) : List CStmt := (body kg ku tail).drop 13

theorem body_split (kg ku : Nat) (tail : Bool) : body kg ku tail =
    (pre ++ [.set 8 (.component (.coord .threadPositionInThreadgroup) (u32l 0)), fillLoop,
      .set 16 (.component (.coord .threadPositionInThreadgroup) (u32l 0)), xsLoop]) ++
      .barrier 1 false true :: rest1 kg ku tail := rfl

/-- A lane runs the codebook and `xs` loops to the barrier. -/
theorem lane_phase1 (hS : Shape L kg ku I) (hl : Lane ctx g s i) (tail : Bool) {sh : Shared}
    (hm : Mem C L I out P g (fun e => e % 1024 < 32 * s + i) (fun c => c < 32 * s + i) sh) :
    ∃ t sh', (Ev fun m => (runThread C m ⟨ctx, fun _ => none, [.block (body kg ku tail)], .running⟩).run sh =
        some (t, sh')) ∧
      Mem C L I out P g (fun e => e % 1024 < 32 * s + i + 1) (fun c => c < 32 * s + i + 1) sh' ∧
      t.status = .barrier 1 false true ∧ t.ctx = ctx ∧ t.frames = [.block (rest1 kg ku tail)] ∧ Fix1 t.locals := by
  have hs := hl.hs; have hi := hl.hi
  obtain ⟨l₀, hpre, hF₀⟩ := fix1_pre C ctx hl.ga0 hl.ga1 sh
  obtain ⟨l₁, sh₁, hfill, hF₁, h8, hm₁⟩ := fill_loop C hS hl (l := setLocal l₀ 8 (u32 (32 * s + i))) (sh := sh)
    ⟨hF₀.set _ (by omega), by rw [setLocal_same, Nat.mul_zero, Nat.add_zero],
      hm.mono (fun e _ h => by rcases h with h | ⟨-, h⟩ <;> omega) (fun c _ h => h)⟩
  have hc1 : ∀ e < 4096, e % 1024 < 32 * s + i + 1 →
      e % 1024 < 32 * s + i ∨ (e % 1024 = 32 * s + i ∧ e / 1024 < 4) := fun e he h => by omega
  have hx1 : ∀ c < 640, (c < 32 * s + i ∨ (c = 32 * s + i ∧ 0 < 0)) → c < 32 * s + i := fun c _ h => by omega
  obtain ⟨l₂, sh₂, hxs, hF₂, -, hm₂⟩ := xs_loop C hS hl (l := setLocal l₁ 16 (u32 (32 * s + i))) (sh := sh₁)
    ⟨hF₁.set _ (by omega), by rw [setLocal_same, Nat.mul_zero, Nat.add_zero], hm₁.mono hc1 hx1⟩
  have hex : Exec C ctx (pre ++ [.set 8 (.component (.coord .threadPositionInThreadgroup) (u32l 0)), fillLoop,
      .set 16 (.component (.coord .threadPositionInThreadgroup) (u32l 0)), xsLoop]) (fun _ => none) sh .normal l₂ sh₂ :=
    hpre.append (.set (eval_coord0 C hl.tpos) (hfill.append (.set (eval_coord0 C hl.tpos) hxs)))
  refine ⟨⟨ctx, l₂, [.block (rest1 kg ku tail)], .barrier 1 false true⟩, sh₂, ?_,
    hm₂.mono (fun e _ h => h) (fun c hc h => ?_), rfl, rfl, rfl, hF₂⟩
  · rw [body_split]
    exact (Exec.reaches_barrier (K := []) (rest := rest1 kg ku tail) (site := 1) (d := false) (g := true) hex).ev_stop rfl
  · by_cases ht : 32 * s + i < 640
    · simp only [ht, ↓reduceIte] at *; omega
    · omega

end Phase1

end Metal.Kernels.GateUp

namespace Metal.Kernels.GateUp
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis

/-! ## A run's words -/

/-- `K` among the widths 1 … 4. -/
def Width (K : Nat) : Prop := K = 1 ∨ K = 2 ∨ K = 3 ∨ K = 4

/-- Word `gw` of a run: the first word of its block, `(20·r + blk)·8·K`. -/
def gbase (K r run : Nat) : Nat := (20 * r + run / 8) * (8 * K)
/-- `gW0 = (BT - 32 - t0)·K / 32`: the run's first word in its block (`t0 = (run % 8)·32`). -/
def w0 (K run : Nat) : Nat := (224 - run % 8 * 32) * K / 32

theorem ar_gw {K r run : Nat} : r * (20 * (8 * K)) + run / 8 * (8 * K) = gbase K r run := by
  unfold gbase; ring

theorem ar_w0 {K run : Nat} (hK : Width K) : w0 K run = (7 - run % 8) * K := by
  unfold w0; rcases hK with rfl | rfl | rfl | rfl <;> omega

theorem ar_bound {K r run : Nat} (hK : Width K) (hr : r < 17408) (hrun : run < 160) :
    gbase K r run + 8 * K ≤ 17408 * 160 * K := by
  unfold gbase; rcases hK with rfl | rfl | rfl | rfl <;> omega

theorem ar_wrap {K run i : Nat} (hK : Width K) (hi : i ≤ K) :
    (w0 K run + i) % (8 * K) = if i < K then w0 K run + i else if run % 8 * 32 = 0 then 0 else w0 K run + K := by
  unfold w0; rcases hK with rfl | rfl | rfl | rfl <;> split <;> (try split) <;> omega

theorem ar_off {K j : Nat} (hK : Width K) (hj : j < 32) : (31 - j) * K + 12 ≤ 32 * (K + 1) ∧ (31 - j) * K < 2 ^ 30 := by
  rcases hK with rfl | rfl | rfl | rfl <;> omega

theorem ar_bit {K run j : Nat} (hK : Width K) (hj : j < 32) :
    32 * w0 K run + (31 - j) * K = K * (255 - (run % 8 * 32 + j)) := by
  unfold w0; rcases hK with rfl | rfl | rfl | rfl <;> omega

theorem ar_w0K {K run : Nat} (hK : Width K) : w0 K run + K ≤ 8 * K := by
  unfold w0; rcases hK with rfl | rfl | rfl | rfl <;> omega

/-- `w[i]` of a run: `codes[gw + gW0 + i]` for `i < K`, then `codes[gw + (t0 == 0u ? 0u : gW0 + K)]`. -/
def runWord (K : Nat) (B : ByteMemory.Bytes) (r run i : Nat) : Nat :=
  word32 B (gbase K r run + if i < K then w0 K run + i else if run % 8 * 32 = 0 then 0 else w0 K run + K)

/-- The run's window at position `j` is the trellis state of block column `t0 + j`. -/
theorem code_run {K : Nat} (hK : Width K) (B : ByteMemory.Bytes) (r run j : Nat) (hj : j < 32) :
    runBits (runWord K B r run) (K + 1) / 2 ^ ((31 - j) * K) % 2 ^ 12 =
      trellisCode K B (gbase K r run) (run % 8 * 32 + j) := by
  have e : runBits (runWord K B r run) (K + 1) =
      runBits (fun i => word32 B (gbase K r run + (w0 K run + i) % (8 * K))) (K + 1) :=
    runBits_congr fun i hi => by rw [runWord, ar_wrap hK (by omega)]
  rw [e, window_block B _ _ _ _ (by have := ar_w0K (run := run) hK; omega) (ar_off hK hj).1, ar_bit hK hj]
  rfl

theorem weight_run (C : M1Max.Contract) {K : Nat} (hK : Width K) (B S : ByteMemory.Bytes) (r run j : Nat) (hj : j < 32) :
    weight C K B S r (32 * run + j) =
      C.fmul (codebook C (runBits (runWord K B r run) (K + 1) / 2 ^ ((31 - j) * K) % 2 ^ 12)) (scale S r) := by
  rw [code_run hK B r run j hj, weight, gbase, show (32 * run + j) / 256 = run / 8 by omega,
    show (32 * run + j) % 256 = run % 8 * 32 + j by omega]

/-! ### Filling the word arrays -/

section Words
variable (C : M1Max.Contract) {ctx : Ctx}

/-- Thread array bytes `B` hold the words `W 0 … W (n - 1)`. -/
def Words (B : ByteMemory.Bytes) (n : Nat) (W : Nat → Nat) : Prop := ∀ i < n, cells B (4 * i) 4 = wordBytes 4 (W i)

theorem Words.load {sh : Shared} {reg size n : Nat} {W : Nat → Nat} (hr : sh.regions reg = some ⟨.thread, size, 4⟩)
    (hW : Words (sh.bytes reg) n W) (hs : 4 * n ≤ size) :
    ∀ i < n, (loadAt ctx (.scalar .u32) ⟨reg, ((4 * i : Nat) : Int), .scalar .u32⟩).run sh = some (u32 (W i), sh) := by
  intro i hi
  rw [load_thread ctx .u32 sh reg (4 * i) size 4 hr (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega)]
  simp only [Scalar.bytes]
  rw [hW i hi, ofWord_u32]

/-- The invariant the word loops keep: reads of the codes, writes to the thread arrays. -/
structure WordInv (ctx : Ctx) (Inv : Shared → Prop) (rc : Nat) (B : ByteMemory.Bytes) (sizeC alC : Nat) : Prop where
  rd : ∀ sh o, Inv sh → Inv (rdn ctx sh rc o 4)
  put : ∀ sh reg o bs, Inv sh → 8 ≤ reg → Inv (tput sh reg o bs)
  codes : ∀ sh, Inv sh → sh.regions rc = some ⟨.device, sizeC, alC⟩ ∧ sh.bytes rc = B
  al : alC % 4 = 0
  rc8 : rc < 8

theorem eval_slot_add {l : Locals} {sh : Shared} {a b : Nat} {x y : Nat} (ha : l a = some (u32 x)) (hb : l b = some (u32 y)) :
    (eval C ctx l (.bin .add .u32 0 (.local a) (.local b))).run sh = some (u32 (x + y), sh) :=
  eval_bin_u32 C (eval_local' C ha sh) (eval_local' C hb sh) (binary_add_u32 C x y)

/-- `for (i = 0; i < K; ++i) w[i] = codes[bw + w0 + i]`. -/
theorem exec_loadWords {Inv : Shared → Prop} {rc sizeC alC : Nat} {B : ByteMemory.Bytes}
    (hI : WordInv ctx Inv rc B sizeC alC) (K i w c bw w0 : Nat) {l : Locals} {sh : Shared}
    {rw sizeW bwv w0v : Nat} (hrw : sh.regions rw = some ⟨.thread, sizeW, 4⟩) (hrw8 : 8 ≤ rw)
    (hw : l w = some (.ptr ⟨rw, 0, .scalar .u32⟩)) (hc : l c = some (.ptr ⟨rc, 0, .scalar .u32⟩))
    (hbw : l bw = some (u32 bwv)) (hw0 : l w0 = some (u32 w0v))
    (hiw : i ≠ w) (hic : i ≠ c) (hibw : i ≠ bw) (hiw0 : i ≠ w0)
    (hsize : 4 * K ≤ sizeW) (hidx : 4 * (bwv + w0v + K) ≤ sizeC) (h32 : bwv + w0v + K < 2 ^ 32) (h0 : Inv sh) :
    ∃ l' sh', Exec C ctx [.set i (u32l 0), loadWords K i w c bw w0] l sh .normal l' sh' ∧ Inv sh' ∧
      (∀ j, j ≠ i → l' j = l j) ∧ l' i = some (u32 K) ∧ sh'.regions = sh.regions ∧
      (∀ r, r ≠ rw → sh'.bytes r = sh.bytes r) ∧
      ∀ j < K, cells (sh'.bytes rw) (4 * j) 4 = wordBytes 4 (word32 B (bwv + w0v + j)) := by
  let J : Nat → Locals → Shared → Prop := fun k l' sh' => Inv sh' ∧ (∀ j, j ≠ i → l' j = l j) ∧ l' i = some (u32 k) ∧
    sh'.regions = sh.regions ∧ (∀ r, r ≠ rw → sh'.bytes r = sh.bytes r) ∧
    ∀ j < k, cells (sh'.bytes rw) (4 * j) 4 = wordBytes 4 (word32 B (bwv + w0v + j))
  obtain ⟨l', sh', hex, hJ⟩ := Exec.loop_count (c := ltU i K) (st := stepU i 1) (ctx := ctx) (C := C) K J J
    (fun k hk l' sh' hJ => ⟨sh', by
      have := eval_lt_u32 C (ctx := ctx) (sh := sh') (b := K) hJ.2.2.1 (by omega) (by omega)
      exact this, hJ⟩)
    (fun k hk l' sh' hJ => by
      obtain ⟨hinv, hagree, hi, hreg, hother, hwords⟩ := hJ
      have hc' := (hI.codes sh' hinv)
      have hp : (eval C ctx l' (.offset (.local w) (.local i))).run sh' =
          some (.ptr ⟨rw, ((4 * k : Nat) : Int), .scalar .u32⟩, sh') := by
        have := eval_ptr_u32 C (ctx := ctx) (eval_local' C (by rw [hagree w hiw.symm]; exact hw) sh') (eval_local' C hi sh')
          (by omega)
        rwa [show k * (Ty.scalar .u32).bytes = 4 * k by simp [Ty.bytes, Scalar.bytes]; ring] at this
      have hidx' : (eval C ctx l' (.bin .add .u32 0 (.bin .add .u32 0 (.local bw) (.local w0)) (.local i))).run sh' =
          some (u32 (bwv + w0v + k), sh') :=
        eval_bin_u32 C (eval_slot_add C (by rw [hagree bw hibw.symm]; exact hbw) (by rw [hagree w0 hiw0.symm]; exact hw0))
          (eval_local' C hi sh') (binary_add_u32 C _ k)
      have hsrc : (eval C ctx l' (.offset (.local c) (.bin .add .u32 0 (.bin .add .u32 0 (.local bw) (.local w0)) (.local i)))).run sh' =
          some (.ptr ⟨rc, ((4 * (bwv + w0v + k) : Nat) : Int), .scalar .u32⟩, sh') := by
        have := eval_ptr_u32 C (ctx := ctx) (eval_local' C (by rw [hagree c hic.symm]; exact hc) sh') hidx' (by omega)
        rwa [show (bwv + w0v + k) * (Ty.scalar .u32).bytes = 4 * (bwv + w0v + k) by simp [Ty.bytes, Scalar.bytes]; ring]
          at this
      have hload := load_shared ctx .u32 sh' rc (4 * (bwv + w0v + k)) _ hc'.1 (by simp) (by simpa [Scalar.bytes] using hI.al)
        (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset])
      rw [hc'.2] at hload
      have hv : Val.ofWord .u32 (bytesWord (cells B (4 * (bwv + w0v + k)) Scalar.u32.bytes)) = u32 (word32 B (bwv + w0v + k)) := rfl
      rw [hv] at hload
      have hst := store_thread ctx .u32 (rdn ctx sh' rc (4 * (bwv + w0v + k)) Scalar.u32.bytes) rw (4 * k) sizeW 4 (u32 (word32 B (bwv + w0v + k))) (wordBytes 4 (word32 B (bwv + w0v + k)))
        (by rw [rdn_regions, hreg]; exact hrw) (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega)
        (encode_u32 _ (word32_lt B _))
      refine ⟨.normal, l', _, setLocal l' i (u32 (k + 1)), _, .inl rfl,
        .store hp ((eval_load C _ _ _ _ _ _ _ hsrc).trans hload) hst (.nil _ _),
        .set (eval_bin_u32 C (eval_local' C hi _) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C k 1)) (.nil _ _),
        hI.put _ rw _ _ (hI.rd _ _ hinv) hrw8, fun j hj => by rw [setLocal_other _ _ hj]; exact hagree j hj,
        setLocal_same _ _ _, by rw [tput_regions, rdn_regions, hreg], fun r hr => by
          rw [tput_other _ _ _ hr, rdn_bytes, hother r hr], fun j hj => ?_⟩
      rw [tput_same, rdn_bytes]
      by_cases hjk : j = k
      · subst hjk
        have := cells_writeBytes_same (sh'.bytes rw) (4 * j) (wordBytes 4 (word32 B (bwv + w0v + j)))
        rwa [wordBytes_length] at this
      · rw [cells_writeBytes_other _ _ _ _ _ (by rw [wordBytes_length]; omega)]
        exact hwords j (by omega))
    (l := setLocal l i (u32 0)) (sh := sh)
    ⟨h0, fun j hj => setLocal_other _ _ hj, setLocal_same _ _ _, rfl, fun _ _ => rfl, fun j hj => absurd hj (by omega)⟩
  exact ⟨l', sh', .set (eval_u32lit C _ _ 0 (by decide)) hex, hJ.1,
    hJ.2.1, hJ.2.2.1, hJ.2.2.2.1, hJ.2.2.2.2.1, hJ.2.2.2.2.2⟩

/-- `w[K] = codes[bw + (t0 == 0u ? 0u : w0 + K)]`. -/
theorem exec_loadWrap {Inv : Shared → Prop} {rc sizeC alC : Nat} {B : ByteMemory.Bytes}
    (hI : WordInv ctx Inv rc B sizeC alC) (K w c bw w0 : Nat) {l : Locals} {sh : Shared}
    {rw sizeW bwv w0v t0v : Nat} (hrw : sh.regions rw = some ⟨.thread, sizeW, 4⟩) (hrw8 : 8 ≤ rw)
    (hw : l w = some (.ptr ⟨rw, 0, .scalar .u32⟩)) (hc : l c = some (.ptr ⟨rc, 0, .scalar .u32⟩))
    (hbw : l bw = some (u32 bwv)) (hw0 : l w0 = some (u32 w0v)) (ht0 : l 34 = some (u32 t0v)) (ht0l : t0v < 2 ^ 32)
    (hsize : 4 * (K + 1) ≤ sizeW) (hK : K < 2 ^ 31) (hidx : 4 * (bwv + (if t0v = 0 then 0 else w0v + K) + 1) ≤ sizeC)
    (h32 : bwv + w0v + K < 2 ^ 32) (h0 : Inv sh) :
    ∃ sh', Exec C ctx [loadWrap K w c bw w0] l sh .normal l sh' ∧ Inv sh' ∧ sh'.regions = sh.regions ∧
      (∀ r, r ≠ rw → sh'.bytes r = sh.bytes r) ∧ (∀ j < K, cells (sh'.bytes rw) (4 * j) 4 = cells (sh.bytes rw) (4 * j) 4) ∧
      cells (sh'.bytes rw) (4 * K) 4 = wordBytes 4 (word32 B (bwv + if t0v = 0 then 0 else w0v + K)) := by
  have hc' := hI.codes sh h0
  have hp : (eval C ctx l (.offset (.local w) (i32l K))).run sh = some (.ptr ⟨rw, ((4 * K : Nat) : Int), .scalar .u32⟩, sh) := by
    have := eval_offset_i32 C (ctx := ctx) (o := 0) (n := K) (eval_local' C hw sh) (eval_lit C _ _ _ _) hK
    rwa [show 0 + K * (Ty.scalar .u32).bytes = 4 * K by simp [Ty.bytes, Scalar.bytes]; ring] at this
  have hcond : (eval C ctx l (.cond (.bin .eq .u32 0 (.local 34) (u32l 0)) (u32l 0) (.bin .add .u32 0 (.local w0) (u32l K)))).run sh =
      some (u32 (if t0v = 0 then 0 else w0v + K), sh) := by
    refine eval_cond C (eval_eq_u32 C (b := 0) ht0 ht0l (by decide)) ?_
    by_cases h : t0v = 0
    · simp only [h, decide_true, ite_true]; exact eval_u32lit C _ _ 0 (by decide)
    · simp only [h, decide_false, Bool.false_eq_true, ite_false]
      exact eval_bin_u32 C (eval_local' C hw0 sh) (eval_u32lit C _ _ K (by omega)) (binary_add_u32 C w0v K)
  have hadd := eval_bin_u32 C (ctx := ctx) (op := .add) (site := 0) (a := .local bw) (eval_local' C hbw sh) hcond
    (binary_add_u32 C bwv (if t0v = 0 then 0 else w0v + K))
  generalize hn : bwv + (if t0v = 0 then 0 else w0v + K) = n at hadd
  have hnl : n < bwv + w0v + K + 1 := by rw [← hn]; split <;> omega
  have hnc : 4 * (n + 1) ≤ sizeC := by rw [← hn]; exact hidx
  have hsrc : (eval C ctx l (.offset (.local c) (.bin .add .u32 0 (.local bw)
      (.cond (.bin .eq .u32 0 (.local 34) (u32l 0)) (u32l 0) (.bin .add .u32 0 (.local w0) (u32l K)))))).run sh =
      some (.ptr ⟨rc, ((4 * n : Nat) : Int), .scalar .u32⟩, sh) := by
    have := eval_ptr_u32 C (ctx := ctx) (eval_local' C hc sh)
      hadd (by omega)
    rwa [show n * (Ty.scalar .u32).bytes = 4 * n by simp [Ty.bytes, Scalar.bytes]; ring] at this
  have hload := load_shared ctx .u32 sh rc (4 * n) _ hc'.1 (by simp) (by simpa [Scalar.bytes] using hI.al)
    (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset])
  rw [hc'.2] at hload
  have hst := store_thread ctx .u32 (rdn ctx sh rc (4 * n) Scalar.u32.bytes) rw (4 * K) sizeW 4 (u32 (word32 B n))
    (wordBytes 4 (word32 B n)) (by rw [rdn_regions]; exact hrw) (by decide) (by simp [Scalar.bytes])
    (by simp [Scalar.bytes]; omega) (encode_u32 _ (word32_lt B _))
  refine ⟨_, .store hp ((eval_load C _ _ _ _ _ _ _ hsrc).trans hload) hst (.nil _ _), hI.put _ rw _ _ (hI.rd _ _ h0) hrw8,
    by rw [tput_regions, rdn_regions], fun r hr => by rw [tput_other _ _ _ hr, rdn_bytes], fun j hj => ?_, ?_⟩
  · rw [tput_same, rdn_bytes, cells_writeBytes_other _ _ _ _ _ (by rw [wordBytes_length]; omega)]
  · rw [tput_same, rdn_bytes, ← hn]
    have := cells_writeBytes_same (sh.bytes rw) (4 * K) (wordBytes 4 (word32 B (bwv + if t0v = 0 then 0 else w0v + K)))
    rwa [wordBytes_length] at this

/-- `v[0] = w[0] << 16`. -/
theorem exec_firstVirtual {Inv : Shared → Prop} (hput : ∀ sh reg o bs, Inv sh → 8 ≤ reg → Inv (tput sh reg o bs))
    (w v : Nat) {l : Locals} {sh : Shared} {rw rv sizeW sizeV : Nat} {W : Nat → Nat}
    (hrw : sh.regions rw = some ⟨.thread, sizeW, 4⟩) (hrv : sh.regions rv = some ⟨.thread, sizeV, 4⟩) (hrv8 : 8 ≤ rv)
    (hw : l w = some (.ptr ⟨rw, 0, .scalar .u32⟩)) (hv : l v = some (.ptr ⟨rv, 0, .scalar .u32⟩))
    (hW : cells (sh.bytes rw) 0 4 = wordBytes 4 (W 0)) (hsw : 4 ≤ sizeW) (hsv : 4 ≤ sizeV)
    (h0 : Inv sh) :
    ∃ sh', Exec C ctx [firstVirtual w v] l sh .normal l sh' ∧ Inv sh' ∧ sh'.regions = sh.regions ∧
      (∀ r, r ≠ rv → sh'.bytes r = sh.bytes r) ∧ (∀ j, 0 < j → cells (sh'.bytes rv) (4 * j) 4 = cells (sh.bytes rv) (4 * j) 4) ∧
      cells (sh'.bytes rv) 0 4 = wordBytes 4 (W 0 * 2 ^ 16 % 2 ^ 32) := by
  have hp : (eval C ctx l (.offset (.local v) (i32l 0))).run sh = some (.ptr ⟨rv, ((0 : Nat) : Int), .scalar .u32⟩, sh) :=
    eval_offset_i32 C (o := 0) (n := 0) (eval_local' C hv sh) (eval_lit C _ _ _ _) (by decide)
  have hpw : (eval C ctx l (.offset (.local w) (i32l 0))).run sh = some (.ptr ⟨rw, ((0 : Nat) : Int), .scalar .u32⟩, sh) :=
    eval_offset_i32 C (o := 0) (n := 0) (eval_local' C hw sh) (eval_lit C _ _ _ _) (by decide)
  have hload := load_thread ctx .u32 sh rw 0 sizeW 4 hrw (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega)
  simp only [Scalar.bytes] at hload
  rw [hW, ofWord_u32] at hload
  have hval : (eval C ctx l (.bin .shl .u32 0 (.load (.scalar .u32) (.offset (.local w) (i32l 0))) (u32l 16))).run sh =
      some (u32 (W 0 * 2 ^ 16 % 2 ^ 32), sh) := by
    rw [u32_mod]
    exact eval_bin_u32 C ((eval_load C _ _ _ _ _ _ _ hpw).trans hload) (eval_u32lit C _ _ 16 (by decide))
      (binary_shl_u32 C _ 16 (by decide))
  have hst := store_thread ctx .u32 sh rv 0 sizeV 4 (u32 (W 0 * 2 ^ 16 % 2 ^ 32)) (wordBytes 4 (W 0 * 2 ^ 16 % 2 ^ 32))
    hrv (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (encode_u32 _ (Nat.mod_lt _ (by decide)))
  refine ⟨_, .store hp hval hst (.nil _ _), hput _ rv _ _ h0 hrv8, by rw [tput_regions], fun r hr => by
    rw [tput_other _ _ _ hr], fun j hj => ?_, ?_⟩
  · rw [tput_same, cells_writeBytes_other _ _ _ _ _ (by rw [wordBytes_length]; omega)]
  · rw [tput_same]
    have := cells_writeBytes_same (sh.bytes rv) 0 (wordBytes 4 (W 0 * 2 ^ 16 % 2 ^ 32))
    rwa [wordBytes_length] at this

/-- `for (i = 1; i <= n; ++i) v[i] = (w[i - 1] >> 16) | (w[i] << 16)` (`n + 1` words; `lt` for `i < n`). -/
theorem exec_virtualWords {Inv : Shared → Prop} (hput : ∀ sh reg o bs, Inv sh → 8 ≤ reg → Inv (tput sh reg o bs))
    (n i w v : Nat) (cond : CExpr) (hcond : ∀ (l' : Locals) (sh' : Shared) (k : Nat), k ≤ n → l' i = some (u32 (k + 1)) →
      (eval C ctx l' cond).run sh' = some (.bool (decide (k < n)), sh'))
    {l : Locals} {sh : Shared} {rw rv sizeW sizeV : Nat} {W : Nat → Nat}
    (hrw : sh.regions rw = some ⟨.thread, sizeW, 4⟩) (hrv : sh.regions rv = some ⟨.thread, sizeV, 4⟩) (hrv8 : 8 ≤ rv)
    (hwv : rw ≠ rv) (hw : l w = some (.ptr ⟨rw, 0, .scalar .u32⟩)) (hv : l v = some (.ptr ⟨rv, 0, .scalar .u32⟩))
    (hiw : i ≠ w) (hiv : i ≠ v)
    (hW : ∀ j ≤ n, cells (sh.bytes rw) (4 * j) 4 = wordBytes 4 (W j)) (hWl : ∀ j ≤ n, W j < 2 ^ 32)
    (hsw : 4 * (n + 1) ≤ sizeW) (hsv : 4 * (n + 1) ≤ sizeV) (hn : n < 2 ^ 30) (h0 : Inv sh) :
    ∃ l' sh', Exec C ctx [.set i (u32l 1), .loop cond (stepU i 1)
        [.store (.scalar .u32) (.offset (.local v) (.local i))
          (.bin .bitOr .u32 0
            (.bin .shr .u32 0 (.load (.scalar .u32) (.offset (.local w) (.bin .sub .u32 0 (.local i) (u32l 1)))) (u32l 16))
            (.bin .shl .u32 0 (.load (.scalar .u32) (.offset (.local w) (.local i))) (u32l 16)))]] l sh .normal l' sh' ∧
      Inv sh' ∧ (∀ j, j ≠ i → l' j = l j) ∧ l' i = some (u32 (n + 1)) ∧ sh'.regions = sh.regions ∧
      (∀ r, r ≠ rv → sh'.bytes r = sh.bytes r) ∧ cells (sh'.bytes rv) 0 4 = cells (sh.bytes rv) 0 4 ∧
      ∀ j, 1 ≤ j → j ≤ n → cells (sh'.bytes rv) (4 * j) 4 = wordBytes 4 (W (j - 1) / 2 ^ 16 ||| W j * 2 ^ 16 % 2 ^ 32) := by
  let J : Nat → Locals → Shared → Prop := fun k l' sh' => Inv sh' ∧ (∀ j, j ≠ i → l' j = l j) ∧ l' i = some (u32 (k + 1)) ∧
    sh'.regions = sh.regions ∧ (∀ r, r ≠ rv → sh'.bytes r = sh.bytes r) ∧ cells (sh'.bytes rv) 0 4 = cells (sh.bytes rv) 0 4 ∧
    ∀ j, 1 ≤ j → j ≤ k → cells (sh'.bytes rv) (4 * j) 4 = wordBytes 4 (W (j - 1) / 2 ^ 16 ||| W j * 2 ^ 16 % 2 ^ 32)
  obtain ⟨l', sh', hex, hJ⟩ := Exec.loop_count (c := cond) (st := stepU i 1) (ctx := ctx) (C := C) n J J
    (fun k hk l' sh' hJ => ⟨sh', hcond l' sh' k hk hJ.2.2.1, hJ⟩)
    (fun k hk l' sh' hJ => by
      obtain ⟨hinv, hagree, hi, hreg, hother, hzero, hwords⟩ := hJ
      have hw' : l' w = some (.ptr ⟨rw, 0, .scalar .u32⟩) := by rw [hagree w hiw.symm]; exact hw
      have hv' : l' v = some (.ptr ⟨rv, 0, .scalar .u32⟩) := by rw [hagree v hiv.symm]; exact hv
      have hrw' : sh'.regions rw = some ⟨.thread, sizeW, 4⟩ := by rw [hreg]; exact hrw
      have hbytes : sh'.bytes rw = sh.bytes rw := hother rw hwv
      have hl1 : (eval C ctx l' (.load (.scalar .u32) (.offset (.local w) (.bin .sub .u32 0 (.local i) (u32l 1))))).run sh' =
          some (u32 (W k), sh') := by
        have hp := eval_ptr_u32 C (ctx := ctx) (eval_local' C hw' sh')
          (eval_bin_u32 C (op := .sub) (site := 0) (a := .local i) (b := u32l 1) (eval_local' C hi sh')
            (eval_u32lit C _ _ 1 (by decide)) (binary_sub_u32 C (k + 1) 1 (by omega)))
          (by omega)
        rw [show (k + 1 - 1) * (Ty.scalar .u32).bytes = 4 * k by simp [Ty.bytes, Scalar.bytes]; ring] at hp
        rw [eval_load C _ _ _ _ _ _ _ hp, load_thread ctx .u32 sh' rw (4 * k) sizeW 4 hrw' (by decide)
          (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega)]
        simp only [Scalar.bytes]
        rw [hbytes, hW k (by omega), ofWord_u32]
      have hl2 : (eval C ctx l' (.load (.scalar .u32) (.offset (.local w) (.local i)))).run sh' = some (u32 (W (k + 1)), sh') := by
        have hp := eval_ptr_u32 C (ctx := ctx) (eval_local' C hw' sh') (eval_local' C hi sh') (by omega)
        rw [show (k + 1) * (Ty.scalar .u32).bytes = 4 * (k + 1) by simp [Ty.bytes, Scalar.bytes]; ring] at hp
        rw [eval_load C _ _ _ _ _ _ _ hp, load_thread ctx .u32 sh' rw (4 * (k + 1)) sizeW 4 hrw' (by decide)
          (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega)]
        simp only [Scalar.bytes]
        rw [hbytes, hW (k + 1) (by omega), ofWord_u32]
      have hWk := hWl k (by omega)
      have hval : (eval C ctx l' (.bin .bitOr .u32 0
          (.bin .shr .u32 0 (.load (.scalar .u32) (.offset (.local w) (.bin .sub .u32 0 (.local i) (u32l 1)))) (u32l 16))
          (.bin .shl .u32 0 (.load (.scalar .u32) (.offset (.local w) (.local i))) (u32l 16)))).run sh' =
          some (u32 (W k / 2 ^ 16 ||| W (k + 1) * 2 ^ 16 % 2 ^ 32), sh') :=
        eval_bin_u32 C (eval_bin_u32 C hl1 (eval_u32lit C _ _ 16 (by decide)) (binary_shr_u32 C _ 16 hWk (by decide)))
          (by rw [u32_mod]; exact eval_bin_u32 C hl2 (eval_u32lit C _ _ 16 (by decide)) (binary_shl_u32 C _ 16 (by decide)))
          (binary_bitOr_u32 C _ _ (lt_of_le_of_lt (Nat.div_le_self _ _) hWk) (Nat.mod_lt _ (by decide)))
      have hvl : W k / 2 ^ 16 ||| W (k + 1) * 2 ^ 16 % 2 ^ 32 < 2 ^ 32 :=
        Nat.or_lt_two_pow (lt_of_le_of_lt (Nat.div_le_self _ _) hWk) (Nat.mod_lt _ (by decide))
      have hp : (eval C ctx l' (.offset (.local v) (.local i))).run sh' =
          some (.ptr ⟨rv, ((4 * (k + 1) : Nat) : Int), .scalar .u32⟩, sh') := by
        have := eval_ptr_u32 C (ctx := ctx) (eval_local' C hv' sh') (eval_local' C hi sh') (by omega)
        rwa [show (k + 1) * (Ty.scalar .u32).bytes = 4 * (k + 1) by simp [Ty.bytes, Scalar.bytes]; ring] at this
      have hst := store_thread ctx .u32 sh' rv (4 * (k + 1)) sizeV 4 _ _ (by rw [hreg]; exact hrv) (by decide)
        (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (encode_u32 _ hvl)
      refine ⟨.normal, l', _, setLocal l' i (u32 (k + 1 + 1)), _, .inl rfl, .store hp hval hst (.nil _ _),
        .set (eval_bin_u32 C (eval_local' C hi _) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C (k + 1) 1)) (.nil _ _),
        hput _ rv _ _ hinv hrv8, fun j hj => by rw [setLocal_other _ _ hj]; exact hagree j hj, setLocal_same _ _ _,
        by rw [tput_regions, hreg], fun r hr => by rw [tput_other _ _ _ hr, hother r hr], ?_, fun j hj1 hj2 => ?_⟩
      · rw [tput_same, cells_writeBytes_other _ _ _ _ _ (by rw [wordBytes_length]; omega), hzero]
      · rw [tput_same]
        by_cases hjk : j = k + 1
        · subst hjk
          have := cells_writeBytes_same (sh'.bytes rv) (4 * (k + 1)) (wordBytes 4 (W k / 2 ^ 16 ||| W (k + 1) * 2 ^ 16 % 2 ^ 32))
          rwa [wordBytes_length] at this
        · rw [cells_writeBytes_other _ _ _ _ _ (by rw [wordBytes_length]; omega)]
          exact hwords j hj1 (by omega))
    (l := setLocal l i (u32 1)) (sh := sh)
    ⟨h0, fun j hj => setLocal_other _ _ hj, setLocal_same _ _ _, rfl, fun _ _ => rfl, rfl, fun j hj1 hj2 => absurd hj2 (by omega)⟩
  exact ⟨l', sh', .set (eval_u32lit C _ _ 1 (by decide)) hex, hJ.1, hJ.2.1, hJ.2.2.1, hJ.2.2.2.1, hJ.2.2.2.2.1,
    hJ.2.2.2.2.2.1, hJ.2.2.2.2.2.2⟩


/-! ### `xv` -/

theorem word_halves (X : ByteMemory.Bytes) (n : Nat) :
    word32 X n % 2 ^ 16 = half X (2 * n) ∧ word32 X n / 2 ^ 16 = half X (2 * n + 1) := by
  have e1 : word32 X n = (X (4 * n + 0)).toNat + 256 * ((X (4 * n + 1)).toNat + 256 * ((X (4 * n + 2)).toNat +
      256 * ((X (4 * n + 3)).toNat + 256 * 0))) := rfl
  have e2 : half X (2 * n) = (X (2 * (2 * n) + 0)).toNat + 256 * ((X (2 * (2 * n) + 1)).toNat + 256 * 0) := rfl
  have e3 : half X (2 * n + 1) = (X (2 * (2 * n + 1) + 0)).toNat + 256 * ((X (2 * (2 * n + 1) + 1)).toNat + 256 * 0) :=
    rfl
  rw [show 2 * (2 * n) + 0 = 4 * n + 0 by ring, show 2 * (2 * n) + 1 = 4 * n + 1 by ring] at e2
  rw [show 2 * (2 * n + 1) + 0 = 4 * n + 2 by ring, show 2 * (2 * n + 1) + 1 = 4 * n + 3 by ring] at e3
  have h0 := (X (4 * n + 0)).isLt; have h1 := (X (4 * n + 1)).isLt; have h2 := (X (4 * n + 2)).isLt
  have h3 := (X (4 * n + 3)).isLt
  rw [e1, e2, e3]
  generalize (X (4 * n + 0)).toNat = a at *
  generalize (X (4 * n + 1)).toNat = b at *
  generalize (X (4 * n + 2)).toNat = c at *
  generalize (X (4 * n + 3)).toNat = d at *
  omega

theorem vec4_cells (X : ByteMemory.Bytes) (c4 : Nat) :
    vec4 (cells X (16 * c4) 16) = .vec .u32 ((List.range 4).map fun m => u32 (word32 X (4 * c4 + m))) := by
  unfold vec4
  congr 1
  apply List.map_congr_left
  intro m hm
  simp only [List.mem_range] at hm
  rw [cells_drop_take _ _ _ _ _ (by simp [Scalar.bytes]; omega)]
  simp only [Scalar.bytes, word32]
  rw [show 16 * c4 + 4 * m = 4 * (4 * c4 + m) by ring]
  rfl

theorem eval_xv {l : Locals} {sh : Shared} {X : ByteMemory.Bytes} {c4 p : Nat}
    (h48 : l 48 = some (vec4 (cells X (16 * c4) 16))) (h49 : l 49 = some (u32 p)) (hp : p < 8) :
    (eval C ctx l xvExpr).run sh = some (.f32 (xval X (8 * c4 + p)), sh) := by
  have hw : (eval C ctx l chunkWord).run sh = some (u32 (word32 X (4 * c4 + p / 2)), sh) := by
    have hidx : (eval C ctx l (.bin .shr .u32 0 (.local 49) (u32l 1))).run sh = some (u32 (p / 2 ^ 1), sh) :=
      eval_bin_u32 C (eval_local' C h49 sh) (eval_u32lit C _ _ 1 (by decide)) (binary_shr_u32 C p 1 (by omega) (by decide))
    refine eval_component C (eval_local' C (h48.trans (congrArg some (vec4_cells X c4))) sh) hidx (natOf_u32 _) ?_
    rw [Nat.mod_eq_of_lt (show p / 2 ^ 1 < 2 ^ 32 by omega), List.getElem?_map,
      List.getElem?_range (show p / 2 ^ 1 < 4 by omega), Option.map_some, show p / 2 ^ 1 = p / 2 by norm_num]
  have hlt := word32_lt X (4 * c4 + p / 2)
  have hh := word_halves X (4 * c4 + p / 2)
  have hcond : (eval C ctx l (.conv .bool (.bin .bitAnd .u32 0 (.local 49) (u32l 1)))).run sh =
      some (.bool (decide ((p &&& 1) % 2 ^ 32 ≠ 0)), sh) :=
    eval_conv C (t := .bool) (eval_bin_u32 C (eval_local' C h49 sh) (eval_u32lit C _ _ 1 (by decide))
      (binary_bitAnd_u32 C p 1 (by omega) (by decide))) rfl
  have hpm : (p &&& 1) % 2 ^ 32 = p % 2 := by
    rw [show (1 : Nat) = 2 ^ 1 - 1 from rfl, Nat.and_two_pow_sub_one_eq_mod]; omega
  rw [hpm] at hcond
  have hval : (eval C ctx l (.cond (.conv .bool (.bin .bitAnd .u32 0 (.local 49) (u32l 1)))
      (.bin .bitAnd .u32 0 chunkWord (u32l 4294901760)) (.bin .shl .u32 0 chunkWord (u32l 16)))).run sh =
      some (u32 (half X (8 * c4 + p) * 2 ^ 16), sh) := by
    refine eval_cond C hcond ?_
    by_cases hpo : p % 2 = 0
    · rw [decide_eq_false (show ¬ p % 2 ≠ 0 from fun h => h hpo)]
      have e : half X (8 * c4 + p) * 2 ^ 16 = word32 X (4 * c4 + p / 2) * 2 ^ 16 % 2 ^ 32 := by
        rw [show (2 : Nat) ^ 32 = 2 ^ 16 * 2 ^ 16 by norm_num, Nat.mul_mod_mul_right, hh.1,
          show 2 * (4 * c4 + p / 2) = 8 * c4 + p by omega]
      rw [e, u32_mod]
      exact eval_bin_u32 C hw (eval_u32lit C _ _ 16 (by decide)) (binary_shl_u32 C _ 16 (by decide))
    · rw [decide_eq_true hpo]
      have e : half X (8 * c4 + p) * 2 ^ 16 = word32 X (4 * c4 + p / 2) &&& 4294901760 := by
        rw [and_hi _ hlt, hh.2, show 2 * (4 * c4 + p / 2) + 1 = 8 * c4 + p by omega]
      rw [e]
      exact eval_bin_u32 C hw (eval_u32lit C _ _ _ (by decide)) (binary_bitAnd_u32 C _ _ hlt (by decide))
  have hlt' : half X (8 * c4 + p) * 2 ^ 16 < 2 ^ 32 := by
    have := bytesWord_lt (cells X (2 * (8 * c4 + p)) 2)
    rw [cells_length] at this
    unfold half; omega
  exact eval_bitcast C hval (bitcast_f32_u32 _ hlt')

end Words

end Metal.Kernels.GateUp

namespace Metal.Kernels.GateUp
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis

/-! ### Rows and runs: the locals -/

/-- After the barrier's declarations: also the table, lane, word counts, runs per block and row step. -/
structure Fix2 (kg ku i : Nat) (l : Locals) : Prop where
  fix1 : Fix1 l
  l17 : l 17 = some (.ptr ⟨6, 0, .scalar .u8⟩)
  l18 : l 18 = some (u32 i)
  l19 : l 19 = some (u32 (8 * kg))
  l20 : l 20 = some (u32 (8 * ku))
  l21 : l 21 = some (u32 8)
  l22 : l 22 = some (u32 5120)

theorem Fix2.of_eq {kg ku i : Nat} {l l' : Locals} (h : Fix2 kg ku i l) (h' : ∀ j, j ≤ 22 → l' j = l j) :
    Fix2 kg ku i l' :=
  ⟨h.fix1.of_eq fun j hj => h' j (by omega), (h' 17 (by omega)).trans h.l17, (h' 18 (by omega)).trans h.l18,
    (h' 19 (by omega)).trans h.l19, (h' 20 (by omega)).trans h.l20, (h' 21 (by omega)).trans h.l21,
    (h' 22 (by omega)).trans h.l22⟩

/-- In row `r`'s body: the row, its first words and its scales. -/
structure RowLoc (kg ku i r : Nat) (I : In) (l : Locals) : Prop where
  fix : Fix2 kg ku i l
  l23 : l 23 = some (u32 r)
  l24 : l 24 = some (u32 (r * (20 * (8 * kg))))
  l25 : l 25 = some (u32 (r * (20 * (8 * ku))))
  l26 : l 26 = some (.f32 (scale I.Gs r))
  l27 : l 27 = some (.f32 (scale I.Us r))

theorem RowLoc.of_eq {kg ku i r : Nat} {I : In} {l l' : Locals} (h : RowLoc kg ku i r I l)
    (h' : ∀ j, j ≤ 27 → l' j = l j) : RowLoc kg ku i r I l' :=
  ⟨h.fix.of_eq fun j hj => h' j (by omega), (h' 23 (by omega)).trans h.l23, (h' 24 (by omega)).trans h.l24,
    (h' 25 (by omega)).trans h.l25, (h' 26 (by omega)).trans h.l26, (h' 27 (by omega)).trans h.l27⟩

/-- In a run's chunks: also the run and the word arrays of thread `th`. -/
structure RunLoc (kg ku i r run th : Nat) (I : In) (l : Locals) : Prop where
  row : RowLoc kg ku i r I l
  l32 : l 32 = some (u32 run)
  l39 : l 39 = some (.ptr ⟨8 + th * 4, 0, .scalar .u32⟩)
  l40 : l 40 = some (.ptr ⟨8 + th * 4 + 1, 0, .scalar .u32⟩)
  l41 : l 41 = some (.ptr ⟨8 + th * 4 + 2, 0, .scalar .u32⟩)
  l42 : l 42 = some (.ptr ⟨8 + th * 4 + 3, 0, .scalar .u32⟩)

theorem RunLoc.of_eq {kg ku i r run th : Nat} {I : In} {l l' : Locals} (h : RunLoc kg ku i r run th I l)
    (h' : ∀ j, j ≤ 27 ∨ j = 32 ∨ (39 ≤ j ∧ j ≤ 42) → l' j = l j) : RunLoc kg ku i r run th I l' :=
  ⟨h.row.of_eq fun j hj => h' j (.inl hj), (h' 32 (by omega)).trans h.l32, (h' 39 (by omega)).trans h.l39,
    (h' 40 (by omega)).trans h.l40, (h' 41 (by omega)).trans h.l41, (h' 42 (by omega)).trans h.l42⟩

/-- The virtual words of `n` words: their value moved up 16 bits, word by word. -/
def virt (W : Nat → Nat) (n i : Nat) : Nat := runBits W n * 2 ^ 16 / 2 ^ (32 * i) % 2 ^ 32

/-- A run's word arrays: `g`, `gv`, `u`, `uv` of thread `th`. -/
structure RunArr (kg ku r run th : Nat) (I : In) (B : Nat → ByteMemory.Bytes) : Prop where
  g : Words (B (8 + th * 4)) (kg + 1) (runWord kg I.Gc r run)
  gv : Words (B (8 + th * 4 + 1)) (kg + 1) (virt (runWord kg I.Gc r run) (kg + 1))
  u : Words (B (8 + th * 4 + 2)) (ku + 1) (runWord ku I.Uc r run)
  uv : Words (B (8 + th * 4 + 3)) (ku + 1) (virt (runWord ku I.Uc r run) (ku + 1))

section Step
variable (C : M1Max.Contract) {L : Launch} {kg ku : Nat} {I : In} {out : Nat → BF} {P g s i : Nat} {ctx : Ctx}

/-- The four accumulators after the lane's first `n` columns of row `r`. -/
def Acc (kg ku : Nat) (I : In) (r i n : Nat) (l : Locals) : Prop :=
  l 28 = some (.f32 (laneAcc C (weight C kg I.Gc I.Gs r) (xval I.X) i 0 n)) ∧
  l 29 = some (.f32 (laneAcc C (weight C kg I.Gc I.Gs r) (xval I.X) i 1 n)) ∧
  l 30 = some (.f32 (laneAcc C (weight C ku I.Uc I.Us r) (xval I.X) i 0 n)) ∧
  l 31 = some (.f32 (laneAcc C (weight C ku I.Uc I.Us r) (xval I.X) i 1 n))

theorem laneAcc_succ (w x : Nat → Float32) (i par m q p : Nat) (hq : q < 4) (hp : p < 8) :
    laneAcc C w x i par (32 * m + 8 * q + p + 1) =
      if p % 2 = par then C.fma (w (32 * (i + 32 * m) + (8 * q + p))) (x (32 * (i + 32 * m) + (8 * q + p)))
        (laneAcc C w x i par (32 * m + 8 * q + p))
      else laneAcc C w x i par (32 * m + 8 * q + p) := by
  rw [laneAcc, laneCol, show (32 * m + 8 * q + p) / 32 = m by omega, show (32 * m + 8 * q + p) % 32 = 8 * q + p by omega,
    show (32 * m + 8 * q + p) % 2 = p % 2 by omega]

/-- Codebook loads in the run's threadgroup after the barrier. -/
theorem cb_load (hS : Shape L kg ku I) {sh : Shared} (hm : Mem C L I out P (g + 1) (fun _ => True) (fun _ => True) sh) :
    ∀ o : Nat, o < 2 ^ 14 → (loadAt ctx (.scalar .f32) ⟨6, (o : Int), .scalar .f32⟩).run sh =
      some (.f32 (codebook C (o / 4)), rdn ctx sh 6 (4 * (o / 4)) 4) := by
  intro o ho
  rw [load_group4 ctx sh 6 o 16384 (by rw [hm.regions]; exact hS.r6) (by omega), hm.cb (o / 4) (by omega) trivial,
    ofWord_f32]

/-- `trellis_codebook_window(table, w, v, (31u - j) * K, L)`: the codebook entry of the run's state at `j`. -/
theorem exec_lookup (K b w v : Nat) {l : Locals} {sh : Shared} {rw rv : Nat} {W : Nat → Nat} {j : Nat}
    (hb : 50 < b) (hw : w < b) (hv : v < b) (hK : Width K)
    (h17 : l 17 = some (.ptr ⟨6, 0, .scalar .u8⟩)) (hlw : l w = some (.ptr ⟨rw, 0, .scalar .u32⟩))
    (hlv : l v = some (.ptr ⟨rv, 0, .scalar .u32⟩)) (h50 : l 50 = some (u32 j)) (hj : j < 32)
    (hrw : sh.regions rw = some ⟨.thread, 4 * (K + 1), 4⟩) (hrv : sh.regions rv = some ⟨.thread, 4 * (K + 1), 4⟩)
    (hW : Words (sh.bytes rw) (K + 1) W) (hWl : ∀ i, W i < 2 ^ 32) (hV : Words (sh.bytes rv) (K + 1) (virt W (K + 1)))
    (hT : ∀ o : Nat, o < 2 ^ 14 → (loadAt ctx (.scalar .f32) ⟨6, (o : Int), .scalar .f32⟩).run sh =
      some (.f32 (codebook C (o / 4)), rdn ctx sh 6 (4 * (o / 4)) 4)) :
    ∃ l', Exec C ctx (lookup K b w v) l sh .normal l'
        (rdn ctx sh 6 (4 * (runBits W (K + 1) / 2 ^ ((31 - j) * K) % 2 ^ 12)) 4) ∧
      l' (b + 5) = some (.f32 (codebook C (runBits W (K + 1) / 2 ^ ((31 - j) * K) % 2 ^ 12))) ∧
      ∀ j', j' < b → l' j' = l j' := by
  have hoff := ar_off hK hj
  have hKl : K < 2 ^ 32 := by rcases hK with rfl | rfl | rfl | rfl <;> decide
  have hoffv : (eval C ctx (setLocal (setLocal (setLocal l b (.ptr ⟨6, 0, .scalar .u8⟩)) (b + 1)
      (.ptr ⟨rw, 0, .scalar .u32⟩)) (b + 2) (.ptr ⟨rv, 0, .scalar .u32⟩)) (windowOff K)).run sh =
      some (u32 ((31 - j) * K), sh) := by
    have h50' : setLocal (setLocal (setLocal l b (.ptr ⟨6, 0, .scalar .u8⟩)) (b + 1) (.ptr ⟨rw, 0, .scalar .u32⟩)) (b + 2)
        (.ptr ⟨rv, 0, .scalar .u32⟩) 50 = some (u32 j) := by
      rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact h50
    exact eval_bin_u32 C (eval_bin_u32 C (eval_u32lit C _ _ 31 (by decide)) (eval_local' C h50' sh)
      (binary_sub_u32 C 31 j (by omega))) (eval_u32lit C _ _ K hKl) (binary_mul_u32 C _ K)
  generalize hl₅ : setLocal (setLocal (setLocal (setLocal (setLocal l b (.ptr ⟨6, 0, .scalar .u8⟩)) (b + 1)
      (.ptr ⟨rw, 0, .scalar .u32⟩)) (b + 2) (.ptr ⟨rv, 0, .scalar .u32⟩)) (b + 3) (u32 ((31 - j) * K))) (b + 4)
      (u32 12) = l₅
  have hl₅b : ∀ j', j' < b → l₅ j' = l j' := fun j' hj' => by
    rw [← hl₅]; simp only [setLocal_other _ _ (show j' ≠ b + 4 by omega), setLocal_other _ _ (show j' ≠ b + 3 by omega),
      setLocal_other _ _ (show j' ≠ b + 2 by omega), setLocal_other _ _ (show j' ≠ b + 1 by omega),
      setLocal_other _ _ (show j' ≠ b by omega)]
  obtain ⟨l', hex, h5, hag⟩ := exec_window C (ctx := ctx) b (l := l₅) (sh := sh) (cb := 6) (rw := rw) (rv := rv)
    (n := K + 1) (off := (31 - j) * K) (W := W) (codebook C) (fun e => rdn ctx sh 6 (4 * e) 4)
    (by rw [← hl₅]; simp [setLocal]) (by rw [← hl₅]; simp [setLocal]) (by rw [← hl₅]; simp [setLocal])
    (by rw [← hl₅]; simp [setLocal]) (by rw [← hl₅]; simp [setLocal]) (fun i _ => hWl i)
    (Words.load hrw hW (by omega)) (fun i hi => by
      rw [Words.load (W := virt W (K + 1)) hrv hV (by omega) i hi]; rfl) hT hoff.1 hoff.2
  refine ⟨l', ?_, h5, fun j' hj' => by rw [hag j' (.inl (by omega)), hl₅b j' hj']⟩
  have hpre : Exec C ctx [.set b (.local 17), .set (b + 1) (.local w), .set (b + 2) (.local v),
      .set (b + 3) (windowOff K), .set (b + 4) (u32l 12)] l sh .normal l₅ sh := by
    rw [← hl₅]
    exact .set (eval_local' C h17 sh) <| .set (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact hlw) sh) <|
      .set (eval_local' C (by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact hlv) sh) <|
      .set hoffv <| .set (eval_u32lit C _ _ 12 (by decide)) (.nil _ _)
  exact hpre.append hex

theorem lt32_of_width {K : Nat} (hK : Width K) : K < 2 ^ 32 := by rcases hK with rfl | rfl | rfl | rfl <;> decide

theorem runWord_lt (K : Nat) (B : ByteMemory.Bytes) (r run i : Nat) : runWord K B r run i < 2 ^ 32 := word32_lt B _

/-- One position `p` of chunk `q` of run `i + 32·m`: `j`, `xv`, the gate and up weights, and their `fma`s. -/
theorem p_step (hS : Shape L kg ku I) (hl : Lane ctx g s i) (hKg : Width kg) (hKu : Width ku)
    {l : Locals} {sh : Shared} {r m q p : Nat} (hm5 : m < 5) (hq : q < 4) (hp : p < 8)
    (hR : RunLoc kg ku i r (i + 32 * m) (g * 1024 + (32 * s + i)) I l)
    (h47 : l 47 = some (u32 q)) (h48 : l 48 = some (vec4 (cells I.X (16 * ((i + 32 * m) * 4 + q)) 16)))
    (h49 : l 49 = some (u32 p)) (hacc : Acc C kg ku I r i (32 * m + 8 * q + p) l)
    (hm : Mem C L I out P (g + 1) (fun _ => True) (fun _ => True) sh)
    (harr : RunArr kg ku r (i + 32 * m) (g * 1024 + (32 * s + i)) I sh.bytes) :
    ∃ l' sh', Exec C ctx (pBody kg ku) l sh .normal l' sh' ∧ Mem C L I out P (g + 1) (fun _ => True) (fun _ => True) sh' ∧
      sh'.bytes = sh.bytes ∧ (∀ j, j ≤ 49 → (j < 28 ∨ 31 < j) → l' j = l j) ∧
      Acc C kg ku I r i (32 * m + 8 * q + p + 1) l' := by
  have hi := hl.hi
  generalize hth : g * 1024 + (32 * s + i) = th at hR harr
  generalize hrun : i + 32 * m = run at hR h48 harr
  have hrunl : run < 160 := by omega
  -- `j` and `xv`
  have hj : (eval C ctx l (.bin .add .u32 0 (.bin .mul .u32 0 (.local 47) (u32l 8)) (.local 49))).run sh =
      some (u32 (q * 8 + p), sh) :=
    eval_bin_u32 C (eval_bin_u32 C (eval_local' C h47 sh) (eval_u32lit C _ _ 8 (by decide)) (binary_mul_u32 C q 8))
      (eval_local' C h49 sh) (binary_add_u32 C _ p)
  generalize hl₁ : setLocal l 50 (u32 (q * 8 + p)) = l₁
  have hx := eval_xv C (ctx := ctx) (l := l₁) (sh := sh) (X := I.X) (c4 := run * 4 + q) (p := p)
    (by rw [← hl₁, setLocal_other _ _ (by omega)]; exact h48) (by rw [← hl₁, setLocal_other _ _ (by omega)]; exact h49) hp
  rw [show 8 * (run * 4 + q) + p = 32 * run + (8 * q + p) by ring] at hx
  generalize hl₂ : setLocal l₁ 51 (.f32 (xval I.X (32 * run + (8 * q + p)))) = l₂
  have hl₂b : ∀ j, j < 50 → l₂ j = l j := fun j hj => by
    rw [← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_other _ _ (by omega)]
  have h50 : l₂ 50 = some (u32 (q * 8 + p)) := by rw [← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_same]
  -- the gate window and weight
  have hT := cb_load C (ctx := ctx) hS hm
  obtain ⟨l₃, hlg, h57, hl₃b⟩ := exec_lookup C (ctx := ctx) kg 52 39 40 (l := l₂) (sh := sh) (rw := 8 + th * 4)
    (rv := 8 + th * 4 + 1) (W := runWord kg I.Gc r run) (j := q * 8 + p) (by omega) (by omega) (by omega) hKg
    (by rw [hl₂b 17 (by omega)]; exact hR.row.fix.l17) (by rw [hl₂b 39 (by omega)]; exact hR.l39)
    (by rw [hl₂b 40 (by omega)]; exact hR.l40) h50 (by omega) (by rw [hm.regions]; exact hS.rg th)
    (by rw [hm.regions]; exact hS.rgv th) harr.g (runWord_lt _ _ _ _) harr.gv hT
  rw [show q * 8 + p = 8 * q + p by ring] at hlg h57
  generalize hsh₁ : rdn ctx sh 6 (4 * (runBits (runWord kg I.Gc r run) (kg + 1) / 2 ^ ((31 - (8 * q + p)) * kg) % 2 ^ 12)) 4
    = sh₁ at hlg
  have hm₁ : Mem C L I out P (g + 1) (fun _ => True) (fun _ => True) sh₁ := by
    rw [← hsh₁]; exact hm.rd ctx 6 _ 4 (.inr ⟨.inl rfl, by rw [hl.group]; omega⟩) hS
  have hb₁ : sh₁.bytes = sh.bytes := by rw [← hsh₁]; rfl
  have hwg : (eval C ctx l₃ (.bin .mul .f32 0 (.local 57) (.local 26))).run sh₁ =
      some (.f32 (weight C kg I.Gc I.Gs r (32 * run + (8 * q + p))), sh₁) := by
    rw [weight_run C hKg I.Gc I.Gs r run (8 * q + p) (by omega)]
    exact eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_local' C h57 sh₁)
      (eval_local' C (by rw [hl₃b 26 (by omega), hl₂b 26 (by omega)]; exact hR.row.l26) sh₁) rfl
  generalize hl₄ : setLocal l₃ 62 (.f32 (weight C kg I.Gc I.Gs r (32 * run + (8 * q + p)))) = l₄
  have hl₄b : ∀ j, j < 52 → l₄ j = l₂ j := fun j hj => by rw [← hl₄, setLocal_other _ _ (by omega), hl₃b j hj]
  -- the up window and weight
  obtain ⟨l₅, hlu, h68, hl₅b⟩ := exec_lookup C (ctx := ctx) ku 63 41 42 (l := l₄) (sh := sh₁) (rw := 8 + th * 4 + 2)
    (rv := 8 + th * 4 + 3) (W := runWord ku I.Uc r run) (j := q * 8 + p) (by omega) (by omega) (by omega) hKu
    (by rw [hl₄b 17 (by omega), hl₂b 17 (by omega)]; exact hR.row.fix.l17)
    (by rw [hl₄b 41 (by omega), hl₂b 41 (by omega)]; exact hR.l41)
    (by rw [hl₄b 42 (by omega), hl₂b 42 (by omega)]; exact hR.l42) (by rw [hl₄b 50 (by omega)]; exact h50) (by omega)
    (by rw [hm₁.regions]; exact hS.ru th) (by rw [hm₁.regions]; exact hS.ruv th) (by rw [hb₁]; exact harr.u)
    (runWord_lt _ _ _ _) (by rw [hb₁]; exact harr.uv) (cb_load C (ctx := ctx) hS hm₁)
  rw [show q * 8 + p = 8 * q + p by ring] at hlu h68
  generalize hsh₂ : rdn ctx sh₁ 6 (4 * (runBits (runWord ku I.Uc r run) (ku + 1) / 2 ^ ((31 - (8 * q + p)) * ku) % 2 ^ 12)) 4
    = sh₂ at hlu
  have hm₂ : Mem C L I out P (g + 1) (fun _ => True) (fun _ => True) sh₂ := by
    rw [← hsh₂]; exact hm₁.rd ctx 6 _ 4 (.inr ⟨.inl rfl, by rw [hl.group]; omega⟩) hS
  have hb₂ : sh₂.bytes = sh.bytes := by rw [← hsh₂]; exact hb₁
  have hwu : (eval C ctx l₅ (.bin .mul .f32 0 (.local 68) (.local 27))).run sh₂ =
      some (.f32 (weight C ku I.Uc I.Us r (32 * run + (8 * q + p))), sh₂) := by
    rw [weight_run C hKu I.Uc I.Us r run (8 * q + p) (by omega)]
    exact eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_local' C h68 sh₂)
      (eval_local' C (by rw [hl₅b 27 (by omega), hl₄b 27 (by omega), hl₂b 27 (by omega)]; exact hR.row.l27) sh₂) rfl
  generalize hl₆ : setLocal l₅ 73 (.f32 (weight C ku I.Uc I.Us r (32 * run + (8 * q + p)))) = l₆
  have hl₆b : ∀ j, j < 52 → l₆ j = l₂ j := fun j hj => by
    rw [← hl₆, setLocal_other _ _ (by omega), hl₅b j (by omega), hl₄b j hj]
  have h51 : l₆ 51 = some (.f32 (xval I.X (32 * run + (8 * q + p)))) := by
    rw [hl₆b 51 (by omega), ← hl₂, setLocal_same]
  have h62 : l₆ 62 = some (.f32 (weight C kg I.Gc I.Gs r (32 * run + (8 * q + p)))) := by
    rw [← hl₆, setLocal_other _ _ (by omega), hl₅b 62 (by omega), ← hl₄, setLocal_same]
  have h73 : l₆ 73 = some (.f32 (weight C ku I.Uc I.Us r (32 * run + (8 * q + p)))) := by rw [← hl₆, setLocal_same]
  obtain ⟨h28, h29, h30, h31⟩ := hacc
  have e28 : l₆ 28 = l 28 := by rw [hl₆b 28 (by omega), hl₂b 28 (by omega)]
  have e29 : l₆ 29 = l 29 := by rw [hl₆b 29 (by omega), hl₂b 29 (by omega)]
  have e30 : l₆ 30 = l 30 := by rw [hl₆b 30 (by omega), hl₂b 30 (by omega)]
  have e31 : l₆ 31 = l 31 := by rw [hl₆b 31 (by omega), hl₂b 31 (by omega)]
  have hc : (eval C ctx l₆ (.conv .bool (.bin .bitAnd .u32 0 (.local 50) (u32l 1)))).run sh₂ =
      some (.bool (decide (((q * 8 + p) &&& 1) % 2 ^ 32 ≠ 0)), sh₂) :=
    eval_conv C (t := .bool) (eval_bin_u32 C (eval_local' C (by rw [hl₆b 50 (by omega)]; exact h50) sh₂)
      (eval_u32lit C _ _ 1 (by decide)) (binary_bitAnd_u32 C (q * 8 + p) 1 (by omega) (by decide))) rfl
  have hpm : ((q * 8 + p) &&& 1) % 2 ^ 32 = p % 2 := by
    rw [show (1 : Nat) = 2 ^ 1 - 1 from rfl, Nat.and_two_pow_sub_one_eq_mod]; omega
  rw [hpm] at hc
  have hs0 := laneAcc_succ C (weight C kg I.Gc I.Gs r) (xval I.X) i 0 m q p hq hp
  have hs1 := laneAcc_succ C (weight C kg I.Gc I.Gs r) (xval I.X) i 1 m q p hq hp
  have hs2 := laneAcc_succ C (weight C ku I.Uc I.Us r) (xval I.X) i 0 m q p hq hp
  have hs3 := laneAcc_succ C (weight C ku I.Uc I.Us r) (xval I.X) i 1 m q p hq hp
  rw [hrun] at hs0 hs1 hs2 hs3
  have hpre : Exec C ctx [.set 50 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 47) (u32l 8)) (.local 49)), .set 51 xvExpr]
      l sh .normal l₂ sh := .set hj (by rw [hl₁]; exact .set hx (by rw [hl₂]; exact .nil _ _))
  by_cases hpo : p % 2 = 0
  · have hite : Exec C ctx [.set 73 (.bin .mul .f32 0 (.local 68) (.local 27)),
        .ite (.conv .bool (.bin .bitAnd .u32 0 (.local 50) (u32l 1))) accOdd accEven] l₅ sh₂ .normal
        (setLocal (setLocal l₆ 28 (.f32 (C.fma (weight C kg I.Gc I.Gs r (32 * run + (8 * q + p)))
          (xval I.X (32 * run + (8 * q + p))) (laneAcc C (weight C kg I.Gc I.Gs r) (xval I.X) i 0 (32 * m + 8 * q + p)))))
          30 (.f32 (C.fma (weight C ku I.Uc I.Us r (32 * run + (8 * q + p))) (xval I.X (32 * run + (8 * q + p)))
            (laneAcc C (weight C ku I.Uc I.Us r) (xval I.X) i 0 (32 * m + 8 * q + p))))) sh₂ := by
      have hbr : Exec C ctx (if decide (p % 2 ≠ 0) = true then accOdd else accEven) l₆ sh₂ .normal
          (setLocal (setLocal l₆ 28 (.f32 (C.fma (weight C kg I.Gc I.Gs r (32 * run + (8 * q + p)))
          (xval I.X (32 * run + (8 * q + p))) (laneAcc C (weight C kg I.Gc I.Gs r) (xval I.X) i 0 (32 * m + 8 * q + p)))))
          30 (.f32 (C.fma (weight C ku I.Uc I.Us r (32 * run + (8 * q + p))) (xval I.X (32 * run + (8 * q + p)))
            (laneAcc C (weight C ku I.Uc I.Us r) (xval I.X) i 0 (32 * m + 8 * q + p))))) sh₂ := by
        rw [decide_eq_false (show ¬ p % 2 ≠ 0 from fun h => h hpo)]
        exact .set (eval_fma C (eval_local' C h62 _) (eval_local' C h51 _) (eval_local' C (e28.trans h28) _))
          (.set (eval_fma C (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact h73) _)
            (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact h51) _)
            (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact e30.trans h30) _)) (.nil _ _))
      exact .set hwu (by rw [hl₆]; exact .ite hc hbr (.nil _ _))
    refine ⟨_, sh₂, hpre.append (hlg.append (.set hwg (by rw [hl₄]; exact hlu.append hite))), hm₂, hb₂, fun j hj1 hj2 => ?_, ?_⟩
    · rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), hl₆b j (by omega), hl₂b j (by omega)]
    · refine ⟨?_, ?_, ?_, ?_⟩
      · rw [setLocal_other _ _ (by omega), setLocal_same, hs0]; simp only [hpo, ↓reduceIte]
      · rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), e29, h29, hs1]; simp only [show ¬ p % 2 = 1 by omega, ↓reduceIte]
      · rw [setLocal_same, hs2]; simp only [hpo, ↓reduceIte]
      · rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), e31, h31, hs3]; simp only [show ¬ p % 2 = 1 by omega, ↓reduceIte]
  · have hite : Exec C ctx [.set 73 (.bin .mul .f32 0 (.local 68) (.local 27)),
        .ite (.conv .bool (.bin .bitAnd .u32 0 (.local 50) (u32l 1))) accOdd accEven] l₅ sh₂ .normal
        (setLocal (setLocal l₆ 29 (.f32 (C.fma (weight C kg I.Gc I.Gs r (32 * run + (8 * q + p)))
          (xval I.X (32 * run + (8 * q + p))) (laneAcc C (weight C kg I.Gc I.Gs r) (xval I.X) i 1 (32 * m + 8 * q + p)))))
          31 (.f32 (C.fma (weight C ku I.Uc I.Us r (32 * run + (8 * q + p))) (xval I.X (32 * run + (8 * q + p)))
            (laneAcc C (weight C ku I.Uc I.Us r) (xval I.X) i 1 (32 * m + 8 * q + p))))) sh₂ := by
      have hbr : Exec C ctx (if decide (p % 2 ≠ 0) = true then accOdd else accEven) l₆ sh₂ .normal
          (setLocal (setLocal l₆ 29 (.f32 (C.fma (weight C kg I.Gc I.Gs r (32 * run + (8 * q + p)))
          (xval I.X (32 * run + (8 * q + p))) (laneAcc C (weight C kg I.Gc I.Gs r) (xval I.X) i 1 (32 * m + 8 * q + p)))))
          31 (.f32 (C.fma (weight C ku I.Uc I.Us r (32 * run + (8 * q + p))) (xval I.X (32 * run + (8 * q + p)))
            (laneAcc C (weight C ku I.Uc I.Us r) (xval I.X) i 1 (32 * m + 8 * q + p))))) sh₂ := by
        rw [decide_eq_true hpo]
        exact .set (eval_fma C (eval_local' C h62 _) (eval_local' C h51 _) (eval_local' C (e29.trans h29) _))
          (.set (eval_fma C (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact h73) _)
            (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact h51) _)
            (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact e31.trans h31) _)) (.nil _ _))
      exact .set hwu (by rw [hl₆]; exact .ite hc hbr (.nil _ _))
    refine ⟨_, sh₂, hpre.append (hlg.append (.set hwg (by rw [hl₄]; exact hlu.append hite))), hm₂, hb₂, fun j hj1 hj2 => ?_, ?_⟩
    · rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), hl₆b j (by omega), hl₂b j (by omega)]
    · refine ⟨?_, ?_, ?_, ?_⟩
      · rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), e28, h28, hs0]; simp only [show ¬ p % 2 = 0 from hpo, ↓reduceIte]
      · rw [setLocal_other _ _ (by omega), setLocal_same, hs1]; simp only [show p % 2 = 1 by omega, ↓reduceIte]
      · rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), e30, h30, hs2]; simp only [show ¬ p % 2 = 0 from hpo, ↓reduceIte]
      · rw [setLocal_same, hs3]; simp only [show p % 2 = 1 by omega, ↓reduceIte]

/-- At the `p`-th test of chunk `q`'s loop of run `i + 32·m`. -/
def PI (L : Launch) (kg ku : Nat) (I : In) (out : Nat → BF) (P g s i r m q : Nat) (B : Nat → ByteMemory.Bytes)
    (p : Nat) (l : Locals) (sh : Shared) : Prop :=
  RunLoc kg ku i r (i + 32 * m) (g * 1024 + (32 * s + i)) I l ∧ l 47 = some (u32 q) ∧
    l 48 = some (vec4 (cells I.X (16 * ((i + 32 * m) * 4 + q)) 16)) ∧ l 49 = some (u32 p) ∧
    Acc C kg ku I r i (32 * m + 8 * q + p) l ∧ Mem C L I out P (g + 1) (fun _ => True) (fun _ => True) sh ∧
    sh.bytes = B ∧ RunArr kg ku r (i + 32 * m) (g * 1024 + (32 * s + i)) I B

theorem p_loop (hS : Shape L kg ku I) (hl : Lane ctx g s i) (hKg : Width kg) (hKu : Width ku) {r m q : Nat}
    {B : Nat → ByteMemory.Bytes} (hm5 : m < 5) (hq : q < 4) {l : Locals} {sh : Shared}
    (h0 : PI C L kg ku I out P g s i r m q B 0 l sh) :
    ∃ l' sh', Exec C ctx [pLoop kg ku] l sh .normal l' sh' ∧ PI C L kg ku I out P g s i r m q B 8 l' sh' := by
  refine Exec.loop_count 8 (PI C L kg ku I out P g s i r m q B) (PI C L kg ku I out P g s i r m q B)
    (fun p hp l sh hI => ⟨sh, ?_, hI⟩) (fun p hp l sh hI => ?_) h0
  · exact eval_lt_u32 C (ctx := ctx) (sh := sh) (b := 8) hI.2.2.2.1 (by omega) (by decide)
  · obtain ⟨hR, h47, h48, h49, hacc, hm, hB, harr⟩ := hI
    obtain ⟨l', sh', hex, hm', hB', hag, hacc'⟩ := p_step C hS hl hKg hKu hm5 hq hp hR h47 h48 h49 hacc hm
      (by rw [hB]; exact harr)
    refine ⟨.normal, l', sh', setLocal l' 49 (u32 (p + 1)), sh', .inl rfl, hex,
      .set (eval_bin_u32 C (eval_local' C (by rw [hag 49 (by omega) (by omega)]; exact h49) _) (eval_u32lit C _ _ 1 (by decide))
        (binary_add_u32 C p 1)) (.nil _ _), ?_, ?_, ?_, setLocal_same _ _ _, ?_, hm', by rw [hB', hB], harr⟩
    · exact hR.of_eq fun j hj => by
        rw [setLocal_other _ _ (by omega)]; exact hag j (by omega) (by omega)
    · rw [setLocal_other _ _ (by omega), hag 47 (by omega) (by omega)]; exact h47
    · rw [setLocal_other _ _ (by omega), hag 48 (by omega) (by omega)]; exact h48
    · obtain ⟨a0, a1, a2, a3⟩ := hacc'
      exact ⟨by rw [setLocal_other _ _ (by omega)]; exact a0, by rw [setLocal_other _ _ (by omega)]; exact a1,
        by rw [setLocal_other _ _ (by omega)]; exact a2, by rw [setLocal_other _ _ (by omega)]; exact a3⟩

/-- At the `q`-th test of run `i + 32·m`'s chunk loop. -/
def QI (L : Launch) (kg ku : Nat) (I : In) (out : Nat → BF) (P g s i r m : Nat) (B : Nat → ByteMemory.Bytes)
    (q : Nat) (l : Locals) (sh : Shared) : Prop :=
  RunLoc kg ku i r (i + 32 * m) (g * 1024 + (32 * s + i)) I l ∧ l 47 = some (u32 q) ∧
    Acc C kg ku I r i (32 * m + 8 * q) l ∧ Mem C L I out P (g + 1) (fun _ => True) (fun _ => True) sh ∧
    sh.bytes = B ∧ RunArr kg ku r (i + 32 * m) (g * 1024 + (32 * s + i)) I B

theorem q_loop (hS : Shape L kg ku I) (hl : Lane ctx g s i) (hKg : Width kg) (hKu : Width ku) {r m : Nat}
    {B : Nat → ByteMemory.Bytes} (hm5 : m < 5) {l : Locals} {sh : Shared}
    (h0 : QI C L kg ku I out P g s i r m B 0 l sh) :
    ∃ l' sh', Exec C ctx [qLoop kg ku] l sh .normal l' sh' ∧ QI C L kg ku I out P g s i r m B 4 l' sh' := by
  have hi := hl.hi
  refine Exec.loop_count 4 (QI C L kg ku I out P g s i r m B) (QI C L kg ku I out P g s i r m B)
    (fun q hq l sh hI => ⟨sh, ?_, hI⟩) (fun q hq l sh hI => ?_) h0
  · exact eval_lt_u32 C (ctx := ctx) (sh := sh) (b := 4) hI.2.1 (by omega) (by decide)
  · obtain ⟨hR, h47, hacc, hm, hB, harr⟩ := hI
    have hc : (eval C ctx l (.bin .add .u32 0 (.bin .mul .u32 0 (.local 47) (u32l 160)) (.local 32))).run sh =
        some (u32 (q * 160 + (i + 32 * m)), sh) :=
      eval_bin_u32 C (eval_bin_u32 C (eval_local' C h47 sh) (eval_u32lit C _ _ 160 (by decide)) (binary_mul_u32 C q 160))
        (eval_local' C hR.l32 sh) (binary_add_u32 C _ _)
    have hp := eval_ptr_u32 C (ctx := ctx) (eval_local' C hR.row.fix.fix1.l7 sh) hc (by omega)
    rw [show (q * 160 + (i + 32 * m)) * (Ty.vec .u32 4).bytes = 16 * (q * 160 + (i + 32 * m)) by
      simp [Ty.bytes, Scalar.bytes]; ring] at hp
    have hload := load_vec4 ctx sh 7 (16 * (q * 160 + (i + 32 * m))) _ (by rw [hm.regions]; exact hS.r7) (by simp)
      (by decide) (by omega) (by simp; omega)
    rw [hm.xs _ (by omega) trivial, show xsIdx (q * 160 + (i + 32 * m)) = (i + 32 * m) * 4 + q by
      unfold xsIdx; omega] at hload
    have hm' := hm.rd ctx 7 (16 * (q * 160 + (i + 32 * m))) 16 (.inr ⟨.inr rfl, by rw [hl.group]; omega⟩) hS
    have hB₁ : (rdn ctx sh 7 (16 * (q * 160 + (i + 32 * m))) 16).bytes = B := by rw [rdn_bytes, hB]
    generalize rdn ctx sh 7 (16 * (q * 160 + (i + 32 * m))) 16 = sh₁ at hload hm' hB₁
    generalize hl₁ : setLocal (setLocal l 48 (vec4 (cells I.X (16 * ((i + 32 * m) * 4 + q)) 16))) 49 (.int .u32 0) = l₁
    have h0 : PI C L kg ku I out P g s i r m q B 0 l₁ sh₁ := by
      rw [← hl₁]
      exact ⟨hR.of_eq fun j hj => by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)],
        by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact h47,
        by rw [setLocal_other _ _ (by omega), setLocal_same], by rw [setLocal_same]; rfl,
        by obtain ⟨a0, a1, a2, a3⟩ := hacc
           exact ⟨by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact a0,
             by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact a1,
             by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact a2,
             by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact a3⟩,
        hm', hB₁, harr⟩
    obtain ⟨l', sh', hex, hR', h47', -, -, hacc', hm'', hB', -⟩ := p_loop C hS hl hKg hKu hm5 hq h0
    refine ⟨.normal, l', sh', setLocal l' 47 (u32 (q + 1)), sh', .inl rfl,
      .set ((eval_load C _ _ _ _ _ _ _ hp).trans hload) (.set (eval_lit C _ _ _ _) (by rw [hl₁]; exact hex)),
      .set (eval_bin_u32 C (eval_local' C h47' _) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C q 1)) (.nil _ _),
      hR'.of_eq fun j hj => by rw [setLocal_other _ _ (by omega)], setLocal_same _ _ _, ?_, hm'', hB', harr⟩
    obtain ⟨a0, a1, a2, a3⟩ := hacc'
    rw [show 32 * m + 8 * q + 8 = 32 * m + 8 * (q + 1) by ring] at a0 a1 a2 a3
    exact ⟨by rw [setLocal_other _ _ (by omega)]; exact a0, by rw [setLocal_other _ _ (by omega)]; exact a1,
      by rw [setLocal_other _ _ (by omega)]; exact a2, by rw [setLocal_other _ _ (by omega)]; exact a3⟩

end Step

end Metal.Kernels.GateUp

namespace Metal.Kernels.GateUp
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis

/-! ### A run -/

/-- In a run after its declarations: `t0`, the block words and the first words. -/
structure RunPre (kg ku i r run th : Nat) (I : In) (l : Locals) : Prop where
  base : RunLoc kg ku i r run th I l
  l34 : l 34 = some (u32 (run % 8 * 32))
  l35 : l 35 = some (u32 (gbase kg r run))
  l36 : l 36 = some (u32 (gbase ku r run))
  l37 : l 37 = some (u32 (w0 kg run))
  l38 : l 38 = some (u32 (w0 ku run))

theorem RunPre.of_eq {kg ku i r run th : Nat} {I : In} {l l' : Locals} (h : RunPre kg ku i r run th I l)
    (h' : ∀ j, j ≤ 42 → l' j = l j) : RunPre kg ku i r run th I l' :=
  ⟨h.base.of_eq fun j hj => h' j (by omega), (h' 34 (by omega)).trans h.l34, (h' 35 (by omega)).trans h.l35,
    (h' 36 (by omega)).trans h.l36, (h' 37 (by omega)).trans h.l37, (h' 38 (by omega)).trans h.l38⟩

theorem Acc.of_eq {C : M1Max.Contract} {kg ku : Nat} {I : In} {r i n : Nat} {l l' : Locals} (h : Acc C kg ku I r i n l)
    (h' : ∀ j, 28 ≤ j → j ≤ 31 → l' j = l j) : Acc C kg ku I r i n l' :=
  ⟨(h' 28 (by omega) (by omega)).trans h.1, (h' 29 (by omega) (by omega)).trans h.2.1,
    (h' 30 (by omega) (by omega)).trans h.2.2.1, (h' 31 (by omega) (by omega)).trans h.2.2.2⟩

section Run
variable (C : M1Max.Contract) {L : Launch} {kg ku : Nat} {I : In} {out : Nat → BF} {P g s i : Nat} {ctx : Ctx}

def runPre (kg ku : Nat) : List CStmt := (runBody kg ku).take 10

theorem width_le {K : Nat} (hK : Width K) : 1 ≤ K ∧ K ≤ 4 := by rcases hK with rfl | rfl | rfl | rfl <;> omega

/-- `blk`, `t0`, `gw`, `uw`, `gW0`, `uW0` and the four arrays. -/
theorem run_pre (hl : Lane ctx g s i) (hKg : Width kg) (hKu : Width ku) {r run : Nat} (_hr : r < 17408)
    (hrun : run < 160) {l : Locals} {sh : Shared} (hrow : RowLoc kg ku i r I l) (h32 : l 32 = some (u32 run)) :
    ∃ l', Exec C ctx (runPre kg ku) l sh .normal l' sh ∧ RunPre kg ku i r run (g * 1024 + (32 * s + i)) I l' ∧
      ∀ j, j < 33 → l' j = l j := by
  have hg := width_le hKg; have hu := width_le hKu
  have h21 := hrow.fix.l21; have h19 := hrow.fix.l19; have h20 := hrow.fix.l20
  have e33 : (eval C ctx l (.bin .div .u32 0 (.local 32) (.local 21))).run sh = some (u32 (run / 8), sh) :=
    eval_bin_u32 C (eval_local' C h32 sh) (eval_local' C h21 sh) (binary_div_u32 C run 8 (by omega) (by decide) (by decide))
  generalize hl₁ : setLocal l 33 (u32 (run / 8)) = l₁
  have h33 : l₁ 33 = some (u32 (run / 8)) := by rw [← hl₁, setLocal_same]
  have hb₁ : ∀ j, j < 33 → l₁ j = l j := fun j hj => by rw [← hl₁, setLocal_other _ _ (by omega)]
  have e34 : (eval C ctx l₁ (.bin .mul .u32 0 (.bin .sub .u32 0 (.local 32) (.bin .mul .u32 0 (.local 33) (.local 21)))
      (u32l 32))).run sh = some (u32 (run % 8 * 32), sh) := by
    rw [show run % 8 * 32 = (run - run / 8 * 8) * 32 by omega]
    exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C (by rw [hb₁ 32 (by omega)]; exact h32) sh)
      (eval_bin_u32 C (eval_local' C h33 sh) (eval_local' C (by rw [hb₁ 21 (by omega)]; exact h21) sh)
        (binary_mul_u32 C _ 8)) (binary_sub_u32 C run _ (by omega))) (eval_u32lit C _ _ 32 (by decide))
      (binary_mul_u32 C _ 32)
  generalize hl₂ : setLocal l₁ 34 (u32 (run % 8 * 32)) = l₂
  have hb₂ : ∀ j, j < 34 → l₂ j = l₁ j := fun j hj => by rw [← hl₂, setLocal_other _ _ (by omega)]
  have e35 : (eval C ctx l₂ (.bin .add .u32 0 (.local 24) (.bin .mul .u32 0 (.local 33) (.local 19)))).run sh =
      some (u32 (gbase kg r run), sh) := by
    rw [← ar_gw]
    exact eval_bin_u32 C (eval_local' C (by rw [hb₂ 24 (by omega), hb₁ 24 (by omega)]; exact hrow.l24) sh)
      (eval_bin_u32 C (eval_local' C (by rw [hb₂ 33 (by omega)]; exact h33) sh)
        (eval_local' C (by rw [hb₂ 19 (by omega), hb₁ 19 (by omega)]; exact h19) sh) (binary_mul_u32 C _ _))
      (binary_add_u32 C _ _)
  generalize hl₃ : setLocal l₂ 35 (u32 (gbase kg r run)) = l₃
  have hb₃ : ∀ j, j < 35 → l₃ j = l₂ j := fun j hj => by rw [← hl₃, setLocal_other _ _ (by omega)]
  have e36 : (eval C ctx l₃ (.bin .add .u32 0 (.local 25) (.bin .mul .u32 0 (.local 33) (.local 20)))).run sh =
      some (u32 (gbase ku r run), sh) := by
    rw [← ar_gw]
    exact eval_bin_u32 C (eval_local' C (by rw [hb₃ 25 (by omega), hb₂ 25 (by omega), hb₁ 25 (by omega)]; exact hrow.l25) sh)
      (eval_bin_u32 C (eval_local' C (by rw [hb₃ 33 (by omega), hb₂ 33 (by omega)]; exact h33) sh)
        (eval_local' C (by rw [hb₃ 20 (by omega), hb₂ 20 (by omega), hb₁ 20 (by omega)]; exact h20) sh) (binary_mul_u32 C _ _))
      (binary_add_u32 C _ _)
  generalize hl₄ : setLocal l₃ 36 (u32 (gbase ku r run)) = l₄
  have hb₄ : ∀ j, j < 36 → l₄ j = l₃ j := fun j hj => by rw [← hl₄, setLocal_other _ _ (by omega)]
  have h34₄ : l₄ 34 = some (u32 (run % 8 * 32)) := by rw [hb₄ 34 (by omega), hb₃ 34 (by omega), ← hl₂, setLocal_same]
  have hfw : ∀ (K : Nat) (lx : Locals), Width K → lx 34 = some (u32 (run % 8 * 32)) →
      (eval C ctx lx (firstWord K)).run sh = some (u32 (w0 K run), sh) := by
    intro K lx hK h34
    have hk := width_le hK
    exact eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_u32lit C _ _ 224 (by decide)) (eval_local' C h34 sh)
      (binary_sub_u32 C 224 _ (by omega))) (eval_u32lit C _ _ K (by omega)) (binary_mul_u32 C _ K))
      (eval_u32lit C _ _ 32 (by decide)) (binary_div_u32 C _ 32
        (lt_of_le_of_lt (Nat.mul_le_mul (Nat.sub_le 224 _) hk.2) (by decide)) (by decide) (by decide))
  generalize hl₅ : setLocal l₄ 37 (u32 (w0 kg run)) = l₅
  have hb₅ : ∀ j, j < 37 → l₅ j = l₄ j := fun j hj => by rw [← hl₅, setLocal_other _ _ (by omega)]
  generalize hl₆ : setLocal l₅ 38 (u32 (w0 ku run)) = l₆
  have hb₆ : ∀ j, j < 38 → l₆ j = l₅ j := fun j hj => by rw [← hl₆, setLocal_other _ _ (by omega)]
  have ha : ∀ j : Nat, ctx.threadArray j = 8 + (g * 1024 + (32 * s + i)) * 4 + j := hl.ta
  refine ⟨setLocal (setLocal (setLocal (setLocal l₆ 39 (.ptr ⟨ctx.threadArray 0, 0, .scalar .u32⟩)) 40
    (.ptr ⟨ctx.threadArray 1, 0, .scalar .u32⟩)) 41 (.ptr ⟨ctx.threadArray 2, 0, .scalar .u32⟩)) 42
    (.ptr ⟨ctx.threadArray 3, 0, .scalar .u32⟩), ?_, ?_, fun j hj => ?_⟩
  · have h34₅ : l₅ 34 = some (u32 (run % 8 * 32)) := by rw [hb₅ 34 (by omega)]; exact h34₄
    have x6 : Exec C ctx [.set 38 (firstWord ku), .array 39 false 0 (.scalar .u32), .array 40 false 1 (.scalar .u32),
        .array 41 false 2 (.scalar .u32), .array 42 false 3 (.scalar .u32)] l₅ sh .normal _ sh :=
      .set (hfw ku l₅ hKu h34₅) (by rw [hl₆]; exact .array (.array (.array (.array (.nil _ _)))))
    have x5 : Exec C ctx (.set 37 (firstWord kg) :: [.set 38 (firstWord ku), .array 39 false 0 (.scalar .u32),
        .array 40 false 1 (.scalar .u32), .array 41 false 2 (.scalar .u32), .array 42 false 3 (.scalar .u32)]) l₄ sh .normal _ sh :=
      .set (hfw kg l₄ hKg h34₄) (by rw [hl₅]; exact x6)
    exact .set e33 (by rw [hl₁]; exact .set e34 (by rw [hl₂]; exact .set e35 (by rw [hl₃]; exact .set e36 (by rw [hl₄]; exact x5))))
  · have hl6 : ∀ j, j < 33 → l₆ j = l j := fun j hj => by
      rw [hb₆ j (by omega), hb₅ j (by omega), hb₄ j (by omega), hb₃ j (by omega), hb₂ j (by omega), hb₁ j hj]
    refine ⟨⟨hrow.of_eq fun j hj => ?_, ?_, ?_, ?_, ?_, ?_⟩, ?_, ?_, ?_, ?_, ?_⟩
    · simp only [setLocal_other _ _ (show j ≠ 42 by omega), setLocal_other _ _ (show j ≠ 41 by omega),
        setLocal_other _ _ (show j ≠ 40 by omega), setLocal_other _ _ (show j ≠ 39 by omega)]
      exact hl6 j (by omega)
    · simp only [setLocal_other _ _ (show (32 : Nat) ≠ 42 by omega), setLocal_other _ _ (show (32 : Nat) ≠ 41 by omega),
        setLocal_other _ _ (show (32 : Nat) ≠ 40 by omega), setLocal_other _ _ (show (32 : Nat) ≠ 39 by omega)]
      rw [hl6 32 (by omega)]; exact h32
    · simp [setLocal, ha]
    · simp [setLocal, ha]
    · simp [setLocal, ha]
    · simp [setLocal, ha]
    · simp only [setLocal_other _ _ (show (34 : Nat) ≠ 42 by omega), setLocal_other _ _ (show (34 : Nat) ≠ 41 by omega),
        setLocal_other _ _ (show (34 : Nat) ≠ 40 by omega), setLocal_other _ _ (show (34 : Nat) ≠ 39 by omega)]
      rw [hb₆ 34 (by omega), hb₅ 34 (by omega)]; exact h34₄
    · simp only [setLocal_other _ _ (show (35 : Nat) ≠ 42 by omega), setLocal_other _ _ (show (35 : Nat) ≠ 41 by omega),
        setLocal_other _ _ (show (35 : Nat) ≠ 40 by omega), setLocal_other _ _ (show (35 : Nat) ≠ 39 by omega)]
      rw [hb₆ 35 (by omega), hb₅ 35 (by omega), hb₄ 35 (by omega), ← hl₃, setLocal_same]
    · simp only [setLocal_other _ _ (show (36 : Nat) ≠ 42 by omega), setLocal_other _ _ (show (36 : Nat) ≠ 41 by omega),
        setLocal_other _ _ (show (36 : Nat) ≠ 40 by omega), setLocal_other _ _ (show (36 : Nat) ≠ 39 by omega)]
      rw [hb₆ 36 (by omega), hb₅ 36 (by omega), ← hl₄, setLocal_same]
    · simp only [setLocal_other _ _ (show (37 : Nat) ≠ 42 by omega), setLocal_other _ _ (show (37 : Nat) ≠ 41 by omega),
        setLocal_other _ _ (show (37 : Nat) ≠ 40 by omega), setLocal_other _ _ (show (37 : Nat) ≠ 39 by omega)]
      rw [hb₆ 37 (by omega), ← hl₅, setLocal_same]
    · simp only [setLocal_other _ _ (show (38 : Nat) ≠ 42 by omega), setLocal_other _ _ (show (38 : Nat) ≠ 41 by omega),
        setLocal_other _ _ (show (38 : Nat) ≠ 40 by omega), setLocal_other _ _ (show (38 : Nat) ≠ 39 by omega)]
      rw [← hl₆, setLocal_same]
  · simp only [setLocal_other _ _ (show j ≠ 42 by omega), setLocal_other _ _ (show j ≠ 41 by omega),
      setLocal_other _ _ (show j ≠ 40 by omega), setLocal_other _ _ (show j ≠ 39 by omega)]
    rw [hb₆ j (by omega), hb₅ j (by omega), hb₄ j (by omega), hb₃ j (by omega), hb₂ j (by omega), hb₁ j hj]

theorem mem_wordInv1 (hS : Shape L kg ku I) {P ge : Nat} {cbOk xsOk : Nat → Prop} :
    WordInv ctx (Mem C L I out P ge cbOk xsOk) 1 I.Gc (codesBytes kg) I.ag :=
  ⟨fun sh o h => h.rd ctx 1 o 4 (.inl (by decide)) hS, fun sh reg o bs h hr => h.tput o bs hr,
    fun sh h => ⟨by rw [h.regions]; exact hS.r1, h.gc⟩, hS.ag, by decide⟩

theorem mem_wordInv3 (hS : Shape L kg ku I) {P ge : Nat} {cbOk xsOk : Nat → Prop} :
    WordInv ctx (Mem C L I out P ge cbOk xsOk) 3 I.Uc (codesBytes ku) I.au :=
  ⟨fun sh o h => h.rd ctx 3 o 4 (.inl (by decide)) hS, fun sh reg o bs h hr => h.tput o bs hr,
    fun sh h => ⟨by rw [h.regions]; exact hS.r3, h.uc⟩, hS.au, by decide⟩

theorem ar_idx {K r run : Nat} (hK : Width K) (hr : r < 17408) (hrun : run < 160) :
    4 * (gbase K r run + w0 K run + K) ≤ codesBytes K ∧ gbase K r run + w0 K run + K < 2 ^ 32 ∧
      4 * (gbase K r run + (if run % 8 * 32 = 0 then 0 else w0 K run + K) + 1) ≤ codesBytes K := by
  have hb := ar_bound hK hr hrun
  have hw := ar_w0K (run := run) hK
  have hw0 := ar_w0 (run := run) hK
  unfold codesBytes
  rcases hK with rfl | rfl | rfl | rfl <;> refine ⟨by omega, by omega, ?_⟩ <;> split <;> omega

/-- The words `g`, `u` and virtual words `gv`, `uv` of a run. -/
def runWords (kg ku : Nat) : List CStmt := ((runBody kg ku).drop 10).take 12

theorem runWords_eq (kg ku : Nat) : runWords kg ku =
    ([.set 43 (u32l 0), loadWords kg 43 39 1 35 37] ++ [loadWrap kg 39 1 35 37]) ++
    (([.set 44 (u32l 0), loadWords ku 44 41 3 36 38] ++ [loadWrap ku 41 3 36 38]) ++
    ([firstVirtual 39 40] ++ ([firstVirtual 41 42] ++
    ([.set 45 (u32l 1), virtualWords kg 45 39 40] ++ [.set 46 (u32l 1), virtualWords ku 46 41 42])))) := rfl

/-- Words of a run to virtual words. -/
theorem words_virt {K : Nat} {B' : ByteMemory.Bytes} {W : Nat → Nat} (hW : ∀ j, W j < 2 ^ 32)
    (h0 : cells B' 0 4 = wordBytes 4 (W 0 * 2 ^ 16 % 2 ^ 32))
    (hj : ∀ j, 1 ≤ j → j ≤ K → cells B' (4 * j) 4 = wordBytes 4 (W (j - 1) / 2 ^ 16 ||| W j * 2 ^ 16 % 2 ^ 32)) :
    Words B' (K + 1) (virt W (K + 1)) := by
  intro j hjK
  rcases Nat.eq_zero_or_pos j with rfl | hpos
  · rw [Nat.mul_zero, h0, virt, shifted_word0 (fun i _ => hW i) (by omega), Nat.mul_zero, Nat.pow_zero, Nat.div_one]
  · rw [hj j hpos (by omega), virt]
    obtain ⟨k, rfl⟩ : ∃ k, j = k + 1 := ⟨j - 1, by omega⟩
    rw [Nat.add_sub_cancel, shifted_word (fun i _ => hW i) (by omega)]

theorem run_words (hS : Shape L kg ku I) (_hl : Lane ctx g s i) (hKg : Width kg) (hKu : Width ku) {r run : Nat}
    (hr : r < 17408) (hrun : run < 160) {l : Locals} {sh : Shared}
    (hpre : RunPre kg ku i r run (g * 1024 + (32 * s + i)) I l) {P ge : Nat}
    (hm : Mem C L I out P ge (fun _ => True) (fun _ => True) sh) :
    ∃ l' sh', Exec C ctx (runWords kg ku) l sh .normal l' sh' ∧ (∀ j, j ≤ 42 → l' j = l j) ∧
      Mem C L I out P ge (fun _ => True) (fun _ => True) sh' ∧
      RunArr kg ku r run (g * 1024 + (32 * s + i)) I sh'.bytes := by
  generalize hth : g * 1024 + (32 * s + i) = th at hpre ⊢
  have hg := width_le hKg; have hu := width_le hKu
  have hR := hpre.base
  have ig := ar_idx hKg hr hrun; have iu := ar_idx hKu hr hrun
  have hrg : ∀ sh' : Shared, sh'.regions = L.regions → sh'.regions (8 + th * 4) = some ⟨.thread, 4 * (kg + 1), 4⟩ :=
    fun sh' h => by rw [h]; exact hS.rg th
  have hrgv : ∀ sh' : Shared, sh'.regions = L.regions → sh'.regions (8 + th * 4 + 1) = some ⟨.thread, 4 * (kg + 1), 4⟩ :=
    fun sh' h => by rw [h]; exact hS.rgv th
  have hru : ∀ sh' : Shared, sh'.regions = L.regions → sh'.regions (8 + th * 4 + 2) = some ⟨.thread, 4 * (ku + 1), 4⟩ :=
    fun sh' h => by rw [h]; exact hS.ru th
  have hruv : ∀ sh' : Shared, sh'.regions = L.regions → sh'.regions (8 + th * 4 + 3) = some ⟨.thread, 4 * (ku + 1), 4⟩ :=
    fun sh' h => by rw [h]; exact hS.ruv th
  -- g
  obtain ⟨l₁, sh₁, x1, hm₁, hag₁, -, hreg₁, hoth₁, hw₁⟩ := exec_loadWords C (mem_wordInv1 C hS) kg 43 39 1 35 37
    (l := l) (sh := sh) (rw := 8 + th * 4) (sizeW := 4 * (kg + 1)) (hrg sh hm.regions) (by omega) hR.l39
    hR.row.fix.fix1.l1 hpre.l35 hpre.l37 (by decide) (by decide) (by decide) (by decide) (by omega) ig.1 ig.2.1 hm
  obtain ⟨sh₂, x2, hm₂, hreg₂, hoth₂, hkeep₂, hw₂⟩ := exec_loadWrap C (mem_wordInv1 C hS) kg 39 1 35 37 (l := l₁)
    (sh := sh₁) (rw := 8 + th * 4) (sizeW := 4 * (kg + 1)) (t0v := run % 8 * 32) (hrg sh₁ hm₁.regions) (by omega)
    (by rw [hag₁ 39 (by decide)]; exact hR.l39) (by rw [hag₁ 1 (by decide)]; exact hR.row.fix.fix1.l1)
    (by rw [hag₁ 35 (by decide)]; exact hpre.l35) (by rw [hag₁ 37 (by decide)]; exact hpre.l37)
    (by rw [hag₁ 34 (by decide)]; exact hpre.l34) (by omega) (by omega) (by omega) ig.2.2 ig.2.1 hm₁
  -- u
  obtain ⟨l₃, sh₃, x3, hm₃, hag₃, -, hreg₃, hoth₃, hw₃⟩ := exec_loadWords C (mem_wordInv3 C hS) ku 44 41 3 36 38
    (l := l₁) (sh := sh₂) (rw := 8 + th * 4 + 2) (sizeW := 4 * (ku + 1)) (hru sh₂ hm₂.regions) (by omega)
    (by rw [hag₁ 41 (by decide)]; exact hR.l41) (by rw [hag₁ 3 (by decide)]; exact hR.row.fix.fix1.l3)
    (by rw [hag₁ 36 (by decide)]; exact hpre.l36) (by rw [hag₁ 38 (by decide)]; exact hpre.l38)
    (by decide) (by decide) (by decide) (by decide) (by omega) iu.1 iu.2.1 hm₂
  obtain ⟨sh₄, x4, hm₄, hreg₄, hoth₄, hkeep₄, hw₄⟩ := exec_loadWrap C (mem_wordInv3 C hS) ku 41 3 36 38 (l := l₃)
    (sh := sh₃) (rw := 8 + th * 4 + 2) (sizeW := 4 * (ku + 1)) (t0v := run % 8 * 32) (hru sh₃ hm₃.regions) (by omega)
    (by rw [hag₃ 41 (by decide), hag₁ 41 (by decide)]; exact hR.l41)
    (by rw [hag₃ 3 (by decide), hag₁ 3 (by decide)]; exact hR.row.fix.fix1.l3)
    (by rw [hag₃ 36 (by decide), hag₁ 36 (by decide)]; exact hpre.l36)
    (by rw [hag₃ 38 (by decide), hag₁ 38 (by decide)]; exact hpre.l38)
    (by rw [hag₃ 34 (by decide), hag₁ 34 (by decide)]; exact hpre.l34) (by omega) (by omega) (by omega) iu.2.2 iu.2.1 hm₃
  -- the words in place
  have hWg : Words (sh₄.bytes (8 + th * 4)) (kg + 1) (runWord kg I.Gc r run) := by
    intro j hj
    rw [hoth₄ _ (by omega), hoth₃ _ (by omega), runWord]
    by_cases hjk : j < kg
    · rw [hkeep₂ j hjk, hw₁ j hjk, ite_eq_left hjk, Nat.add_assoc]
    · rw [show j = kg by omega, hw₂, ite_eq_right (Nat.lt_irrefl kg)]
  have hWu : Words (sh₄.bytes (8 + th * 4 + 2)) (ku + 1) (runWord ku I.Uc r run) := by
    intro j hj
    rw [runWord]
    by_cases hjk : j < ku
    · rw [hkeep₄ j hjk, hw₃ j hjk, ite_eq_left hjk, Nat.add_assoc]
    · rw [show j = ku by omega, hw₄, ite_eq_right (Nat.lt_irrefl ku)]
  have hput := fun sh reg o bs (h : Mem C L I out P ge (fun _ => True) (fun _ => True) sh) (hr : 8 ≤ reg) => h.tput o bs hr
  have hl₃ : ∀ j, j ≤ 42 → l₃ j = l j := fun j hj => by rw [hag₃ j (by omega), hag₁ j (by omega)]
  -- the first virtual words
  obtain ⟨sh₅, x5, hm₅, hreg₅, hoth₅, -, hv₅⟩ := exec_firstVirtual C hput 39 40 (l := l₃) (sh := sh₄)
    (rw := 8 + th * 4) (rv := 8 + th * 4 + 1) (sizeW := 4 * (kg + 1)) (sizeV := 4 * (kg + 1))
    (W := runWord kg I.Gc r run) (hrg sh₄ hm₄.regions) (hrgv sh₄ hm₄.regions) (by omega)
    (by rw [hl₃ 39 (by decide)]; exact hR.l39) (by rw [hl₃ 40 (by decide)]; exact hR.l40)
    (by simpa using hWg 0 (by omega)) (by omega) (by omega) hm₄
  obtain ⟨sh₆, x6, hm₆, hreg₆, hoth₆, -, hv₆⟩ := exec_firstVirtual C hput 41 42 (l := l₃) (sh := sh₅)
    (rw := 8 + th * 4 + 2) (rv := 8 + th * 4 + 3) (sizeW := 4 * (ku + 1)) (sizeV := 4 * (ku + 1))
    (W := runWord ku I.Uc r run) (hru sh₅ hm₅.regions) (hruv sh₅ hm₅.regions) (by omega)
    (by rw [hl₃ 41 (by decide)]; exact hR.l41) (by rw [hl₃ 42 (by decide)]; exact hR.l42)
    (by rw [hoth₅ _ (by omega)]; simpa using hWu 0 (by omega)) (by omega) (by omega) hm₅
  -- the other virtual words
  have hc : ∀ (K i' : Nat), Width K → ∀ (l' : Locals) (sh' : Shared) (k : Nat), k ≤ K → l' i' = some (u32 (k + 1)) →
      (eval C ctx l' (leU i' K)).run sh' = some (.bool (decide (k < K)), sh') := by
    intro K i' hK l' sh' k hk h
    have := eval_bin_u32 C (ctx := ctx) (op := .le) (site := 0) (eval_local' C h sh') (eval_u32lit C _ _ K (lt32_of_width hK))
      (binary_le_u32 C (k + 1) K (by have := width_le hK; omega) (lt32_of_width hK))
    rwa [show decide (k + 1 ≤ K) = decide (k < K) from decide_eq_decide.mpr (by omega)] at this
  obtain ⟨l₇, sh₇, x7, hm₇, hag₇, -, hreg₇, hoth₇, h0₇, hv₇⟩ := exec_virtualWords C hput kg 45 39 40 (leU 45 kg) (hc kg 45 hKg)
    (l := l₃) (sh := sh₆) (rw := 8 + th * 4) (rv := 8 + th * 4 + 1) (sizeW := 4 * (kg + 1)) (sizeV := 4 * (kg + 1))
    (W := runWord kg I.Gc r run) (hrg sh₆ hm₆.regions) (hrgv sh₆ hm₆.regions) (by omega) (by omega)
    (by rw [hl₃ 39 (by decide)]; exact hR.l39) (by rw [hl₃ 40 (by decide)]; exact hR.l40) (by decide) (by decide)
    (fun j hj => by rw [hoth₆ _ (by omega), hoth₅ _ (by omega)]; exact hWg j (by omega)) (fun j _ => runWord_lt _ _ _ _ _)
    (by omega) (by omega) (by omega) hm₆
  have hl₇ : ∀ j, j ≤ 42 → l₇ j = l j := fun j hj => by rw [hag₇ j (by omega), hl₃ j hj]
  obtain ⟨l₈, sh₈, x8, hm₈, hag₈, -, hreg₈, hoth₈, h0₈, hv₈⟩ := exec_virtualWords C hput ku 46 41 42 (leU 46 ku) (hc ku 46 hKu)
    (l := l₇) (sh := sh₇) (rw := 8 + th * 4 + 2) (rv := 8 + th * 4 + 3) (sizeW := 4 * (ku + 1)) (sizeV := 4 * (ku + 1))
    (W := runWord ku I.Uc r run) (hru sh₇ hm₇.regions) (hruv sh₇ hm₇.regions) (by omega) (by omega)
    (by rw [hl₇ 41 (by decide)]; exact hR.l41) (by rw [hl₇ 42 (by decide)]; exact hR.l42) (by decide) (by decide)
    (fun j hj => by rw [hoth₇ _ (by omega), hoth₆ _ (by omega), hoth₅ _ (by omega)]; exact hWu j (by omega))
    (fun j _ => runWord_lt _ _ _ _ _) (by omega) (by omega) (by omega) hm₇
  refine ⟨l₈, sh₈, ?_, fun j hj => by rw [hag₈ j (by omega), hl₇ j hj], hm₈, ⟨?_, ?_, ?_, ?_⟩⟩
  · rw [runWords_eq]
    exact (x1.append x2).append ((x3.append x4).append (x5.append (x6.append (x7.append x8))))
  · intro j hj
    rw [hoth₈ _ (by omega), hoth₇ _ (by omega), hoth₆ _ (by omega), hoth₅ _ (by omega)]; exact hWg j hj
  · refine words_virt (fun j => runWord_lt _ _ _ _ _) ?_ (fun j h1 h2 => by rw [hoth₈ _ (by omega)]; exact hv₇ j h1 h2)
    rw [hoth₈ _ (by omega), h0₇, hoth₆ _ (by omega)]; exact hv₅
  · intro j hj
    rw [hoth₈ _ (by omega), hoth₇ _ (by omega), hoth₆ _ (by omega), hoth₅ _ (by omega)]; exact hWu j hj
  · refine words_virt (fun j => runWord_lt _ _ _ _ _) ?_ hv₈
    rw [h0₈, hoth₇ _ (by omega)]; exact hv₆

theorem runBody_eq (kg ku : Nat) : runBody kg ku = runPre kg ku ++ (runWords kg ku ++ [.set 47 (u32l 0), qLoop kg ku]) := rfl

/-- One run: its words, then its four chunks. -/
theorem run_body (hS : Shape L kg ku I) (hl : Lane ctx g s i) (hKg : Width kg) (hKu : Width ku) {r m : Nat}
    (hr : r < 17408) (hm5 : m < 5) {l : Locals} {sh : Shared} (hrow : RowLoc kg ku i r I l)
    (h32 : l 32 = some (u32 (i + 32 * m))) (hacc : Acc C kg ku I r i (32 * m) l)
    (hm : Mem C L I out P (g + 1) (fun _ => True) (fun _ => True) sh) :
    ∃ l' sh', Exec C ctx (runBody kg ku) l sh .normal l' sh' ∧ RowLoc kg ku i r I l' ∧ l' 32 = some (u32 (i + 32 * m)) ∧
      Acc C kg ku I r i (32 * m + 32) l' ∧ Mem C L I out P (g + 1) (fun _ => True) (fun _ => True) sh' := by
  have hi := hl.hi
  obtain ⟨lP, xP, hpre, hagP⟩ := run_pre C (sh := sh) hl hKg hKu hr (show i + 32 * m < 160 by omega) hrow h32
  obtain ⟨lW, shW, xW, hagW, hmW, harr⟩ := run_words C hS hl hKg hKu hr (show i + 32 * m < 160 by omega) hpre hm
  have hQ0 : QI C L kg ku I out P g s i r m shW.bytes 0 (setLocal lW 47 (u32 0)) shW :=
    ⟨hpre.base.of_eq fun j hj => by rw [setLocal_other _ _ (by omega), hagW j (by omega)], setLocal_same _ _ _,
      by rw [Nat.mul_zero, Nat.add_zero]
         exact hacc.of_eq fun j h1 h2 => by rw [setLocal_other _ _ (by omega), hagW j (by omega), hagP j (by omega)],
      hmW, rfl, harr⟩
  obtain ⟨lQ, shQ, xQ, hRQ, -, haccQ, hmQ, -, -⟩ := q_loop C hS hl hKg hKu hm5 hQ0
  refine ⟨lQ, shQ, ?_, hRQ.row, hRQ.l32, by rw [show 32 * m + 32 = 32 * m + 8 * 4 by ring]; exact haccQ, hmQ⟩
  rw [runBody_eq]
  exact xP.append (xW.append (.set (eval_u32lit C _ _ 0 (by decide)) xQ))

/-- At the `m`-th test of the run loop. -/
def RI (L : Launch) (kg ku : Nat) (I : In) (out : Nat → BF) (P g i r : Nat) (m : Nat) (l : Locals) (sh : Shared) : Prop :=
  RowLoc kg ku i r I l ∧ l 32 = some (u32 (i + 32 * m)) ∧ Acc C kg ku I r i (32 * m) l ∧
    Mem C L I out P (g + 1) (fun _ => True) (fun _ => True) sh

theorem run_loop (hS : Shape L kg ku I) (hl : Lane ctx g s i) (hKg : Width kg) (hKu : Width ku) {r : Nat}
    (hr : r < 17408) {l : Locals} {sh : Shared} (h0 : RI C L kg ku I out P g i r 0 l sh) :
    ∃ l' sh', Exec C ctx [runLoop kg ku] l sh .normal l' sh' ∧ RI C L kg ku I out P g i r 5 l' sh' := by
  have hi := hl.hi
  refine Exec.loop_count 5 (RI C L kg ku I out P g i r) (RI C L kg ku I out P g i r)
    (fun m hm l sh hI => ⟨sh, ?_, hI⟩) (fun m hm l sh hI => ?_) h0
  · have := eval_lt_u32 C (ctx := ctx) (sh := sh) (b := 160) hI.2.1 (by omega) (by decide)
    rwa [show decide (i + 32 * m < 160) = decide (m < 5) from decide_eq_decide.mpr (by omega)] at this
  · obtain ⟨hrow, h32, hacc, hm'⟩ := hI
    obtain ⟨l', sh', x, hrow', h32', hacc', hm''⟩ := run_body C hS hl hKg hKu hr hm hrow h32 hacc hm'
    refine ⟨.normal, l', sh', setLocal l' 32 (u32 (i + 32 * m + 32)), sh', .inl rfl, x,
      .set (eval_bin_u32 C (eval_local' C h32' _) (eval_u32lit C _ _ 32 (by decide)) (binary_add_u32 C _ 32)) (.nil _ _),
      hrow'.of_eq fun j hj => setLocal_other _ _ (by omega), by rw [setLocal_same, show i + 32 * m + 32 = i + 32 * (m + 1) by ring],
      ?_, hm''⟩
    rw [show 32 * (m + 1) = 32 * m + 32 by ring]
    exact hacc'.of_eq fun j h1 h2 => setLocal_other _ _ (by omega)

end Run

end Metal.Kernels.GateUp

namespace Metal.Kernels.GateUp
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis

/-! ### A row -/

section Row
variable (C : M1Max.Contract) {L : Launch} {kg ku : Nat} {I : In} {out : Nat → BF} {P g s i : Nat} {ctx : Ctx}

/-- A lane's `gAcc + gAcc2` (the first `simd_sum`'s operand) and `uAcc + uAcc2` for row `r`. -/
def gpart (K : Nat) (Codes S X : ByteMemory.Bytes) (r i : Nat) : Float32 :=
  C.fadd (laneAcc C (weight C K Codes S r) (xval X) i 0 160) (laneAcc C (weight C K Codes S r) (xval X) i 1 160)

theorem rowSum_eq (K : Nat) (Codes S X : ByteMemory.Bytes) (r : Nat) :
    rowSum C K Codes S X r = C.simdSum fun i => gpart C K Codes S X r i := rfl

/-- The row body after the first `simd_sum`, and after the second. -/
def restA (kg ku : Nat) (tail : Bool) : List CStmt := (rowBody kg ku tail).drop 11
def restB (tail : Bool) : List CStmt := [.set 77 (.local 76), midStore tail]

theorem rowBody_eq (kg ku : Nat) (tail : Bool) : rowBody kg ku tail =
    (rowBody kg ku tail).take 10 ++ .collective 2 74 .sum .f32 (.bin .add .f32 0 (.local 28) (.local 29)) (u16l 0) ::
      restA kg ku tail := rfl

theorem restA_eq (kg ku : Nat) (tail : Bool) : restA kg ku tail =
    [.set 75 (.local 74)] ++ .collective 3 76 .sum .f32 (.bin .add .f32 0 (.local 30) (.local 31)) (u16l 0) ::
      restB tail := rfl

/-- The row's declarations and runs, to the first `simd_sum`. -/
theorem row_body (hS : Shape L kg ku I) (hl : Lane ctx g s i) (hKg : Width kg) (hKu : Width ku) (tail : Bool) {r : Nat}
    (hr : r < 17408) {l : Locals} {sh : Shared} (hF : Fix2 kg ku i l) (h23 : l 23 = some (u32 r))
    (hm : Mem C L I out P (g + 1) (fun _ => True) (fun _ => True) sh) :
    ∃ l' sh', Exec C ctx (rowBody kg ku tail) l sh
        (.stop (.collective 2 74 .sum .f32 (.f32 (gpart C kg I.Gc I.Gs I.X r i)) 0) [.block (restA kg ku tail)]) l' sh' ∧
      RowLoc kg ku i r I l' ∧ Acc C kg ku I r i 160 l' ∧ Mem C L I out P (g + 1) (fun _ => True) (fun _ => True) sh' := by
  have hi := hl.hi
  have hg := width_le hKg; have hu := width_le hKu
  have e24 : (eval C ctx l (.bin .mul .u32 0 (.local 23) (.bin .mul .u32 0 (u32l 20) (.local 19)))).run sh =
      some (u32 (r * (20 * (8 * kg))), sh) :=
    eval_bin_u32 C (eval_local' C h23 sh) (eval_bin_u32 C (eval_u32lit C _ _ 20 (by decide)) (eval_local' C hF.l19 sh)
      (binary_mul_u32 C 20 _)) (binary_mul_u32 C r _)
  generalize hl₁ : setLocal l 24 (u32 (r * (20 * (8 * kg)))) = l₁
  have e25 : (eval C ctx l₁ (.bin .mul .u32 0 (.local 23) (.bin .mul .u32 0 (u32l 20) (.local 20)))).run sh =
      some (u32 (r * (20 * (8 * ku))), sh) := by
    rw [← hl₁]
    exact eval_bin_u32 C (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact h23) sh)
      (eval_bin_u32 C (eval_u32lit C _ _ 20 (by decide)) (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact hF.l20) sh)
      (binary_mul_u32 C 20 _)) (binary_mul_u32 C r _)
  generalize hl₂ : setLocal l₁ 25 (u32 (r * (20 * (8 * ku)))) = l₂
  have hb₂ : ∀ j, j < 24 → l₂ j = l j := fun j hj => by
    rw [← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_other _ _ (by omega)]
  have hscale : ∀ (reg : Nat) (S : ByteMemory.Bytes) (al : Nat) (lx : Locals) (shx : Shared),
      shx.regions reg = some ⟨.device, 34816, al⟩ → al % 2 = 0 → shx.bytes reg = S →
      lx reg = some (.ptr ⟨reg, 0, .scalar .f16⟩) → lx 23 = some (u32 r) →
      (eval C ctx lx (.conv .f32 (.load (.scalar .f16) (.offset (.local reg) (.local 23))))).run shx =
        some (.f32 (scale S r), rdn ctx shx reg (2 * r) 2) := by
    intro reg S al lx shx hr' hal hS' hp h23'
    have hp' := eval_ptr_u32 C (ctx := ctx) (eval_local' C hp shx) (eval_local' C h23' shx) (by omega)
    rw [show r * (Ty.scalar .f16).bytes = 2 * r by simp [Ty.bytes, Scalar.bytes]; ring] at hp'
    have hld := load_shared ctx .f16 shx reg (2 * r) _ hr' (by simp) (by simpa [Scalar.bytes] using hal)
      (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset])
    rw [hS'] at hld
    exact eval_conv C (t := .f32) ((eval_load C _ _ _ _ _ _ _ hp').trans hld) rfl
  have e26 := hscale 2 I.Gs I.as l₂ sh (by rw [hm.regions]; exact hS.r2) hS.as hm.gs
    (by rw [hb₂ 2 (by omega)]; exact hF.fix1.l2) (by rw [hb₂ 23 (by omega)]; exact h23)
  have hm₁ := hm.rd ctx 2 (2 * r) 2 (.inl (by decide)) hS
  generalize rdn ctx sh 2 (2 * r) 2 = sh₁ at e26 hm₁
  generalize hl₃ : setLocal l₂ 26 (.f32 (scale I.Gs r)) = l₃
  have e27 := hscale 4 I.Us I.aus l₃ sh₁ (by rw [hm₁.regions]; exact hS.r4) hS.aus hm₁.us
    (by rw [← hl₃, setLocal_other _ _ (by omega), hb₂ 4 (by omega)]; exact hF.fix1.l4)
    (by rw [← hl₃, setLocal_other _ _ (by omega), hb₂ 23 (by omega)]; exact h23)
  have hm₂ := hm₁.rd ctx 4 (2 * r) 2 (.inl (by decide)) hS
  generalize rdn ctx sh₁ 4 (2 * r) 2 = sh₂ at e27 hm₂
  generalize hl₄ : setLocal (setLocal (setLocal (setLocal (setLocal (setLocal l₃ 27 (.f32 (scale I.Us r))) 28
    (.f32 zero)) 29 (.f32 zero)) 30 (.f32 zero)) 31 (.f32 zero)) 32 (u32 i) = l₄
  have hR0 : RI C L kg ku I out P g i r 0 l₄ sh₂ := by
    rw [← hl₄, ← hl₃, ← hl₂, ← hl₁]
    refine ⟨⟨hF.of_eq fun j hj => by simp (disch := omega) only [setLocal_lt], by simp [setLocal, h23], by simp [setLocal], by simp [setLocal],
      by simp [setLocal], by simp [setLocal]⟩, by simp [setLocal], ⟨by simp [setLocal, laneAcc], by simp [setLocal, laneAcc],
      by simp [setLocal, laneAcc], by simp [setLocal, laneAcc]⟩, hm₂⟩
  obtain ⟨l₅, sh₅, x5, hrow, h32, hacc, hm₅⟩ := run_loop C hS hl hKg hKu hr hR0
  have hpre : Exec C ctx ((rowBody kg ku tail).take 10) l sh .normal l₅ sh₅ := by
    show Exec C ctx [.set 24 _, .set 25 _, .set 26 _, .set 27 _, .set 28 (f32l 0x0), .set 29 (f32l 0x0), .set 30 (f32l 0x0),
      .set 31 (f32l 0x0), .set 32 (.local 18), runLoop kg ku] l sh .normal l₅ sh₅
    have h18 : setLocal (setLocal (setLocal (setLocal (setLocal l₃ 27 (.f32 (scale I.Us r))) 28 (.f32 zero)) 29 (.f32 zero))
        30 (.f32 zero)) 31 (.f32 zero) 18 = some (u32 i) := by
      rw [← hl₃]; simp (disch := omega) only [setLocal_lt]; rw [hb₂ 18 (by omega)]; exact hF.l18
    rw [← hl₄] at x5
    have x27 : Exec C ctx [.set 28 (f32l 0x0), .set 29 (f32l 0x0), .set 30 (f32l 0x0), .set 31 (f32l 0x0),
        .set 32 (.local 18), runLoop kg ku] (setLocal l₃ 27 (.f32 (scale I.Us r))) sh₂ .normal l₅ sh₅ :=
      .set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _)
        (.set (eval_local' C h18 _) x5))))
    exact .set e24 (by rw [hl₁]; exact .set e25 (by rw [hl₂]; exact .set e26 (by rw [hl₃]; exact .set e27 x27)))
  rw [show 32 * 5 = 160 from rfl] at hacc
  have hcoll : (eval C ctx l₅ (.bin .add .f32 0 (.local 28) (.local 29))).run sh₅ =
      some (.f32 (gpart C kg I.Gc I.Gs I.X r i), sh₅) :=
    eval_f32 C (.inr ⟨rfl, rfl⟩) (eval_local' C hacc.1 sh₅) (eval_local' C hacc.2.1 sh₅) rfl
  refine ⟨l₅, sh₅, ?_, hrow, hacc, hm₅⟩
  rw [rowBody_eq]
  exact hpre.append (.collective hcoll (eval_lit C _ _ _ _) rfl)

/-- The pointer `mid + row`. -/
theorem eval_midPtr {l : Locals} {sh : Shared} {r : Nat} (h5 : l 5 = some (.ptr ⟨5, 0, .scalar .bf16⟩))
    (h23 : l 23 = some (u32 r)) (hr : r < 17408) :
    (eval C ctx l (.offset (.local 5) (.local 23))).run sh = some (.ptr ⟨5, ((2 * r : Nat) : Int), .scalar .bf16⟩, sh) := by
  have hp := eval_ptr_u32 C (ctx := ctx) (eval_local' C h5 sh) (eval_local' C h23 sh) (by omega)
  rwa [show r * (Ty.scalar .bf16).bytes = 2 * r by simp [Ty.bytes, Scalar.bytes]; ring] at hp

/-- The tail's value for `gateT`, `upT` (slots 78, 79). -/
theorem exec_tail (tail : Bool) {l : Locals} {sh : Shared} {gate up : Float32} {r : Nat}
    (h5 : l 5 = some (.ptr ⟨5, 0, .scalar .bf16⟩)) (h23 : l 23 = some (u32 r)) (hr : r < 17408)
    (h78 : l 78 = some (.bf16 (C.narrow gate))) (h79 : l 79 = some (.bf16 (C.narrow up)))
    (hreg : sh.regions 5 = some ⟨.device, 34816, 16⟩) :
    ∃ l', Exec C ctx (tailStmts tail) l sh .normal l'
      (wrn ctx sh 5 (2 * r) 2 (wordBytes 2 (Val.bf16Bits (tailOut C tail gate up)))) ∧ ∀ j, j < 78 → l' j = l j := by
  have hst := fun (v : BF) => store_shared ctx .bf16 sh 5 (2 * r) _ (.bf16 v) (wordBytes 2 (Val.bf16Bits v)) hreg (by simp)
    (by simp) (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) rfl
  cases tail with
  | false =>
    have e83 : (eval C ctx l sigmoidExpr).run sh =
        some (.bf16 (C.narrow (C.fdiv one (C.fadd one (C.exp (f32Neg (C.widen (C.narrow gate))))))), sh) :=
      eval_conv C (t := .bf16) (eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_lit C _ _ _ _)
        (eval_f32 C (.inr ⟨rfl, rfl⟩) (eval_lit C _ _ _ _) (eval_un C (eval_un C (eval_conv C (t := .f32)
          (eval_local' C h78 sh) rfl) rfl) rfl) rfl) rfl) rfl
    generalize hl₁ : setLocal l 83 (.bf16 (C.narrow (C.fdiv one (C.fadd one (C.exp (f32Neg (C.widen (C.narrow gate)))))))) = l₁
    have hb₁ : ∀ j, j < 83 → l₁ j = l j := fun j hj => by rw [← hl₁, setLocal_other _ _ (by omega)]
    have e84 : (eval C ctx l₁ (.bin .mul .bf16 0 (.local 78) (.local 83))).run sh = some (.bf16 (C.bfmul (C.narrow gate)
        (C.narrow (C.fdiv one (C.fadd one (C.exp (f32Neg (C.widen (C.narrow gate)))))))), sh) :=
      eval_bin_plain C (.inl ⟨by decide, by decide⟩) (eval_local' C (by rw [hb₁ 78 (by omega)]; exact h78) sh)
        (eval_local' C (by rw [← hl₁, setLocal_same]) sh) rfl
    generalize hl₂ : setLocal l₁ 84 (.bf16 (C.bfmul (C.narrow gate)
        (C.narrow (C.fdiv one (C.fadd one (C.exp (f32Neg (C.widen (C.narrow gate))))))))) = l₂
    have hb₂ : ∀ j, j < 83 → l₂ j = l j := fun j hj => by rw [← hl₂, setLocal_other _ _ (by omega), hb₁ j hj]
    have ev : (eval C ctx l₂ (.bin .mul .bf16 0 (.local 84) (.local 79))).run sh =
        some (.bf16 (tailOut C false gate up), sh) :=
      eval_bin_plain C (.inl ⟨by decide, by decide⟩) (eval_local' C (by rw [← hl₂, setLocal_same]) sh)
        (eval_local' C (by rw [hb₂ 79 (by omega)]; exact h79) sh) rfl
    have hp := eval_midPtr C (ctx := ctx) (l := l₂) (sh := sh) (by rw [hb₂ 5 (by omega)]; exact h5) (by rw [hb₂ 23 (by omega)]; exact h23) hr
    have x2 : Exec C ctx [.set 84 (.bin .mul .bf16 0 (.local 78) (.local 83)),
        .store (.scalar .bf16) (.offset (.local 5) (.local 23)) (.bin .mul .bf16 0 (.local 84) (.local 79))] l₁ sh .normal l₂
        (wrn ctx sh 5 (2 * r) 2 (wordBytes 2 (Val.bf16Bits (tailOut C false gate up)))) :=
      .set e84 (by rw [hl₂]; exact .store hp ev (hst _) (.nil _ _))
    exact ⟨l₂, .set e83 (by rw [hl₁]; exact x2), fun j hj => hb₂ j (by omega)⟩
  | true =>
    have e80 : (eval C ctx l sigYExpr).run sh = some (.bf16 (sigY C (C.narrow gate)), sh) :=
      eval_bin_plain C (.inl ⟨by decide, by decide⟩) (eval_lit C _ _ _ _)
        (eval_bin_plain C (.inr ⟨rfl, rfl⟩) (eval_lit C _ _ _ _) (eval_conv C (t := .bf16) (eval_un C (eval_conv C (t := .f32)
          (eval_conv C (t := .bf16) (eval_un C (eval_conv C (t := .f32) (eval_local' C h78 sh) rfl) rfl) rfl) rfl) rfl) rfl)
          rfl) rfl
    generalize hl₁ : setLocal l 80 (.bf16 (sigY C (C.narrow gate))) = l₁
    have hb₁ : ∀ j, j < 80 → l₁ j = l j := fun j hj => by rw [← hl₁, setLocal_other _ _ (by omega)]
    have h80 : l₁ 80 = some (.bf16 (sigY C (C.narrow gate))) := by rw [← hl₁, setLocal_same]
    have e81 : (eval C ctx l₁ sigmoidTailExpr).run sh = some (.bf16 (if f32Compare (C.widen (C.narrow gate)) (C.widen bzero) = some .lt
        then sigY C (C.narrow gate) else C.bfsub bone (sigY C (C.narrow gate))), sh) := by
      refine eval_cond C (eval_bin_plain C (.inl ⟨by decide, by decide⟩)
        (eval_local' C (v := .bf16 (C.narrow gate)) (by rw [hb₁ 78 (by omega)]; exact h78) sh) (eval_lit C _ _ _ _)
        (binary_lt_bf16 C (C.narrow gate) bzero)) ?_
      by_cases hc : f32Compare (C.widen (C.narrow gate)) (C.widen bzero) = some .lt
      · rw [decide_eq_true hc, ite_eq_left hc]; exact eval_local' C h80 sh
      · rw [decide_eq_false hc, ite_eq_right hc]
        exact eval_bin_plain C (.inr ⟨rfl, rfl⟩) (eval_lit C _ _ _ _) (eval_local' C h80 sh) rfl
    generalize hsg : (if f32Compare (C.widen (C.narrow gate)) (C.widen bzero) = some .lt
        then sigY C (C.narrow gate) else C.bfsub bone (sigY C (C.narrow gate))) = sg at e81
    generalize hl₂ : setLocal l₁ 81 (.bf16 sg) = l₂
    have hb₂ : ∀ j, j < 80 → l₂ j = l j := fun j hj => by rw [← hl₂, setLocal_other _ _ (by omega), hb₁ j hj]
    have e82 : (eval C ctx l₂ (.bin .mul .bf16 0 (.local 78) (.local 81))).run sh =
        some (.bf16 (C.bfmul (C.narrow gate) sg), sh) :=
      eval_bin_plain C (.inl ⟨by decide, by decide⟩) (eval_local' C (by rw [hb₂ 78 (by omega)]; exact h78) sh)
        (eval_local' C (by rw [← hl₂, setLocal_same]) sh) rfl
    generalize hl₃ : setLocal l₂ 82 (.bf16 (C.bfmul (C.narrow gate) sg)) = l₃
    have hb₃ : ∀ j, j < 80 → l₃ j = l j := fun j hj => by rw [← hl₃, setLocal_other _ _ (by omega), hb₂ j hj]
    have ev : (eval C ctx l₃ (.bin .mul .bf16 0 (.local 82) (.local 79))).run sh =
        some (.bf16 (tailOut C true gate up), sh) := by
      rw [tailOut, hsg]
      exact eval_bin_plain C (.inl ⟨by decide, by decide⟩) (eval_local' C (by rw [← hl₃, setLocal_same]) sh)
        (eval_local' C (by rw [hb₃ 79 (by omega)]; exact h79) sh) rfl
    have hp := eval_midPtr C (ctx := ctx) (l := l₃) (sh := sh) (by rw [hb₃ 5 (by omega)]; exact h5) (by rw [hb₃ 23 (by omega)]; exact h23) hr
    have x3 : Exec C ctx [.set 82 (.bin .mul .bf16 0 (.local 78) (.local 81)),
        .store (.scalar .bf16) (.offset (.local 5) (.local 23)) (.bin .mul .bf16 0 (.local 82) (.local 79))] l₂ sh .normal l₃
        (wrn ctx sh 5 (2 * r) 2 (wordBytes 2 (Val.bf16Bits (tailOut C true gate up)))) :=
      .set e82 (by rw [hl₃]; exact .store hp ev (hst _) (.nil _ _))
    exact ⟨l₃, .set e80 (by rw [hl₁]; exact .set e81 (by rw [hl₂]; exact x3)), fun j hj => hb₃ j (by omega)⟩

/-- `if (lane == 0u)`: lane 0 writes `mid[r]`. -/
theorem exec_midStore (tail : Bool) {l : Locals} {sh : Shared} {gate up : Float32} {r : Nat}
    (h5 : l 5 = some (.ptr ⟨5, 0, .scalar .bf16⟩)) (h18 : l 18 = some (u32 i)) (hi : i < 32)
    (h23 : l 23 = some (u32 r)) (hr : r < 17408)
    (h75 : l 75 = some (.f32 gate)) (h77 : l 77 = some (.f32 up)) (hreg : sh.regions 5 = some ⟨.device, 34816, 16⟩) :
    ∃ l', Exec C ctx [midStore tail] l sh .normal l'
      (if i = 0 then wrn ctx sh 5 (2 * r) 2 (wordBytes 2 (Val.bf16Bits (tailOut C tail gate up))) else sh) ∧
      ∀ j, j < 78 → l' j = l j := by
  have hc := eval_eq_u32 C (ctx := ctx) (sh := sh) (b := 0) h18 (by omega) (by decide)
  by_cases h0 : i = 0
  · rw [ite_eq_left h0]
    rw [decide_eq_true h0] at hc
    generalize hl₁ : setLocal (setLocal l 78 (.bf16 (C.narrow gate))) 79 (.bf16 (C.narrow up)) = l₁
    have hb₁ : ∀ j, j < 78 → l₁ j = l j := fun j hj => by
      rw [← hl₁, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
    obtain ⟨l', x, hag⟩ := exec_tail C (ctx := ctx) tail (l := l₁) (sh := sh) (gate := gate) (up := up)
      (by rw [hb₁ 5 (by omega)]; exact h5) (by rw [hb₁ 23 (by omega)]; exact h23) hr
      (by rw [← hl₁, setLocal_other _ _ (by omega), setLocal_same]) (by rw [← hl₁, setLocal_same]) hreg
    have x2 : Exec C ctx (.set 78 (.conv .bf16 (.local 75)) :: .set 79 (.conv .bf16 (.local 77)) :: tailStmts tail) l sh
        .normal l' (wrn ctx sh 5 (2 * r) 2 (wordBytes 2 (Val.bf16Bits (tailOut C tail gate up)))) :=
      .set (eval_conv C (t := .bf16) (eval_local' C h75 sh) rfl)
        (.set (eval_conv C (t := .bf16) (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact h77) sh) rfl)
          (by rw [hl₁]; exact x))
    exact ⟨l', .ite hc x2 (.nil _ _), fun j hj => by rw [hag j hj, hb₁ j hj]⟩
  · rw [ite_eq_right h0]
    rw [decide_eq_false h0] at hc
    exact ⟨l, .ite hc (.nil _ _) (.nil _ _), fun _ _ => rfl⟩

end Row

/-! ### A lane after the barrier -/

section Lane2
variable (C : M1Max.Contract) {L : Launch} {kg ku : Nat} {I : In} {out : Nat → BF} {P g s i : Nat} {ctx : Ctx}

/-- Lane `i` stopped at row `r`'s first `simd_sum`. -/
def AtGate (kg ku : Nat) (tail : Bool) (I : In) (i r : Nat) (ctx : Ctx) (t : Thread) : Prop :=
  t.ctx = ctx ∧ t.frames = [.block (restA kg ku tail), .loop rowCond rowStep (rowBody kg ku tail), .block []] ∧
    RowLoc kg ku i r I t.locals ∧ Acc C kg ku I r i 160 t.locals

/-- Lane `i` stopped at row `r`'s second `simd_sum`, `gate` in slot 75. -/
def AtUp (kg ku : Nat) (tail : Bool) (I : In) (i r : Nat) (gate : Float32) (ctx : Ctx) (t : Thread) : Prop :=
  t.ctx = ctx ∧ t.frames = [.block (restB tail), .loop rowCond rowStep (rowBody kg ku tail), .block []] ∧
    RowLoc kg ku i r I t.locals ∧ t.locals 75 = some (.f32 gate)

theorem rest1_eq (kg ku : Nat) (tail : Bool) : rest1 kg ku tail = (rest1 kg ku tail).take 7 ++ [rowLoop kg ku tail] := rfl

/-- After the barrier: the declarations, to row `32·g + s`'s first `simd_sum`. -/
theorem lane_first (hS : Shape L kg ku I) (hl : Lane ctx g s i) (hKg : Width kg) (hKu : Width ku) (tail : Bool)
    {l : Locals} (hF : Fix1 l) {sh : Shared} (hm : Mem C L I out P (g + 1) (fun _ => True) (fun _ => True) sh) :
    ∃ t sh', (Ev fun m => (runThread C m ⟨ctx, l, [.block (rest1 kg ku tail)], .running⟩).run sh = some (t, sh')) ∧
      Mem C L I out P (g + 1) (fun _ => True) (fun _ => True) sh' ∧
      t.status = .collective 2 74 .sum .f32 (.f32 (gpart C kg I.Gc I.Gs I.X (32 * g + s) i)) 0 ∧
      AtGate C kg ku tail I i (32 * g + s) ctx t := by
  have hg := hl.hg; have hs := hl.hs; have hi := hl.hi
  have hk1 := width_le hKg; have hk2 := width_le hKu
  have e22 : (eval C ctx (setLocal (setLocal (setLocal (setLocal (setLocal l 17 (.ptr ⟨6, 0, .scalar .u8⟩)) 18 (u32 i)) 19
      (.int .u32 (8 * kg))) 20 (.int .u32 (8 * ku))) 21 (.int .u32 8))
      (.bin .mul .u32 0 (.component (.coord .threadgroupsPerGrid) (u32l 1)) (u32l 32))).run sh = some (u32 5120, sh) :=
    eval_bin_u32 C (eval_coord1 C hl.ngroups) (eval_u32lit C _ _ 32 (by decide)) (binary_mul_u32 C 160 32)
  have e23 : ∀ lx : Locals, (eval C ctx lx (.bin .add .u32 0 (.bin .mul .u32 0
      (.component (.coord .threadPositionInGrid) (u32l 1)) (u32l 32)) (.coord .simdgroupIndexInThreadgroup))).run sh =
      some (u32 (32 * g + s), sh) := fun lx => by
    have := eval_bin_u32 C (ctx := ctx) (l := lx) (sh := sh) (op := .add) (site := 0)
      (eval_bin_u32 C (op := .mul) (site := 0) (eval_coord1 C hl.gpos) (eval_u32lit C _ _ 32 (by decide)) (binary_mul_u32 C g 32))
      (by rw [eval_coord, hl.sg]) (binary_add_u32 C (g * 32) s)
    rwa [show g * 32 + s = 32 * g + s by ring] at this
  generalize hl₇ : setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal l 17 (.ptr ⟨6, 0, .scalar .u8⟩)) 18
    (u32 i)) 19 (.int .u32 (8 * kg))) 20 (.int .u32 (8 * ku))) 21 (.int .u32 8)) 22 (u32 5120)) 23 (u32 (32 * g + s)) = l₇
  have hpre : Exec C ctx ((rest1 kg ku tail).take 7) l sh .normal l₇ sh := by
    rw [← hl₇]
    exact .set (eval_ptrCast C (eval_local' C hF.l6 sh)) <| .set (eval_coord C _ _ _ _ |>.trans (by rw [hl.lane])) <|
      .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set e22 <| .set (e23 _) <| .nil _ _
  have hF₂ : Fix2 kg ku i l₇ := by
    rw [← hl₇]
    exact ⟨hF.of_eq fun j hj => by simp (disch := omega) only [setLocal_lt], by simp [setLocal], by simp [setLocal],
      by simp [setLocal, u32]; omega, by simp [setLocal, u32]; omega, by simp [setLocal, u32], by simp [setLocal]⟩
  have h23 : l₇ 23 = some (u32 (32 * g + s)) := by rw [← hl₇, setLocal_same]
  have hr : 32 * g + s < 17408 := by omega
  obtain ⟨lA, shA, xA, hrow, hacc, hmA⟩ := row_body C hS hl hKg hKu tail hr hF₂ h23 hm
  have hc := eval_lt_u32 C (ctx := ctx) (sh := sh) (b := 17408) h23 (by omega) (by decide)
  rw [decide_eq_true hr] at hc
  have hex := hpre.append (Exec.loop_stop (c := rowCond) (st := rowStep) (b := rowBody kg ku tail) (ss := []) hc xA)
  have hex' : Exec C ctx (rest1 kg ku tail) l sh _ lA shA := hex
  exact ⟨_, shA, (hex'.reaches_stop (K := [])).ev_stop rfl, hmA, rfl, rfl, rfl, hrow, hacc⟩

/-- Resumed with `gate`: on to the second `simd_sum`. -/
theorem lane_gate (tail : Bool) {r : Nat} {t : Thread} (ht : AtGate C kg ku tail I i r ctx t) (G : Float32) (sh : Shared) :
    ∃ t', (Ev fun m => (runThread C m ({ t with status := .running }.set 74 (.f32 G))).run sh = some (t', sh)) ∧
      t'.status = .collective 3 76 .sum .f32 (.f32 (gpart C ku I.Uc I.Us I.X r i)) 0 ∧ AtUp kg ku tail I i r G ctx t' := by
  obtain ⟨tc, tl, tf, ts⟩ := t
  obtain ⟨hc, hf, hrow, hacc⟩ := ht
  dsimp only at hc hf hrow hacc
  subst hc hf
  rw [resumed]
  have hacc' := hacc.of_eq (l' := setLocal (setLocal tl 74 (.f32 G)) 75 (.f32 G)) fun j h1 h2 => by
    rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
  have hU : (eval C tc (setLocal (setLocal tl 74 (.f32 G)) 75 (.f32 G)) (.bin .add .f32 0 (.local 30) (.local 31))).run sh =
      some (.f32 (gpart C ku I.Uc I.Us I.X r i), sh) :=
    eval_f32 C (.inr ⟨rfl, rfl⟩) (eval_local' C hacc'.2.2.1 sh) (eval_local' C hacc'.2.2.2 sh) rfl
  have hex : Exec C tc (restA kg ku tail) (setLocal tl 74 (.f32 G)) sh
      (.stop (.collective 3 76 .sum .f32 (.f32 (gpart C ku I.Uc I.Us I.X r i)) 0) [.block (restB tail)])
      (setLocal (setLocal tl 74 (.f32 G)) 75 (.f32 G)) sh := by
    rw [restA_eq]
    exact Exec.append (.set (eval_local' C (setLocal_same _ _ _) sh) (.nil _ _)) (.collective hU (eval_lit C _ _ _ _) rfl)
  exact ⟨_, (hex.reaches_stop (K := [.loop rowCond rowStep (rowBody kg ku tail), .block []])).ev_stop rfl, rfl, rfl, rfl,
    hrow.of_eq fun j hj => (setLocal_other _ _ (by omega)).trans (setLocal_other _ _ (by omega)),
    setLocal_same (setLocal tl 74 (.f32 G)) 75 (.f32 G)⟩

/-- Resumed with `up`: lane 0 writes `mid[r]`, then on to the next row's first `simd_sum`, or to the end. -/
theorem lane_next (hS : Shape L kg ku I) (hl : Lane ctx g s i) (hKg : Width kg) (hKu : Width ku) (tail : Bool)
    {G : Nat → Float32} {row : Nat} (hrow : row < 17408) (hr : row % 5120 = 32 * g + s) {t : Thread}
    (ht : AtUp kg ku tail I i row (G row) ctx t) (U : Float32) {sh : Shared}
    (hout : out row = tailOut C tail (G row) U) (hP : ord row = P)
    (hm : Mem C L I out (P + min i 1) (g + 1) (fun _ => True) (fun _ => True) sh) :
    ∃ t' sh', (Ev fun m => (runThread C m ({ t with status := .running }.set 76 (.f32 U))).run sh = some (t', sh')) ∧
      Mem C L I out (P + min (i + 1) 1) (g + 1) (fun _ => True) (fun _ => True) sh' ∧
      if row + 5120 < 17408 then
        t'.status = .collective 2 74 .sum .f32 (.f32 (gpart C kg I.Gc I.Gs I.X (row + 5120) i)) 0 ∧
          AtGate C kg ku tail I i (row + 5120) ctx t'
      else t'.status = .done := by
  have hi := hl.hi
  have hs := hl.hs; have hg := hl.hg
  obtain ⟨tc, tl, tf, ts⟩ := t
  obtain ⟨hc, hf, hrl, h75⟩ := ht
  dsimp only at hc hf hrl h75
  subst hc hf
  rw [resumed]
  generalize hl₁ : setLocal (setLocal tl 76 (.f32 U)) 77 (.f32 U) = l₁
  have hb₁ : ∀ j, j < 76 → l₁ j = tl j := fun j hj => by
    rw [← hl₁, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
  obtain ⟨lC, xC, hagC⟩ := exec_midStore C (ctx := tc) (i := i) tail (l := l₁) (sh := sh) (gate := G row) (up := U) (r := row)
    (by rw [hb₁ 5 (by omega)]; exact hrl.fix.fix1.l5) (by rw [hb₁ 18 (by omega)]; exact hrl.fix.l18) hi
    (by rw [hb₁ 23 (by omega)]; exact hrl.l23) hrow (by rw [hb₁ 75 (by omega)]; exact h75)
    (by rw [← hl₁, setLocal_same]) (by rw [hm.regions]; exact hS.r5)
  have hrest : Exec C tc (restB tail) (setLocal tl 76 (.f32 U)) sh .normal lC
      (if i = 0 then wrn tc sh 5 (2 * row) 2 (wordBytes 2 (Val.bf16Bits (tailOut C tail (G row) U))) else sh) :=
    .set (eval_local' C (setLocal_same _ _ _) sh) (by rw [hl₁]; exact xC)
  have hmC : Mem C L I out (P + min (i + 1) 1) (g + 1) (fun _ => True) (fun _ => True)
      (if i = 0 then wrn tc sh 5 (2 * row) 2 (wordBytes 2 (Val.bf16Bits (tailOut C tail (G row) U))) else sh) := by
    by_cases h0 : i = 0
    · subst h0
      rw [ite_eq_left rfl, ← hout]
      have := hm.wmid hS tc row hrow (by simpa using hP) (by rw [hl.thread]; omega) (by rw [hl.group]; omega)
      simpa using this
    · rw [ite_eq_right h0, show min (i + 1) 1 = min i 1 by omega]; exact hm
  generalize (if i = 0 then wrn tc sh 5 (2 * row) 2 (wordBytes 2 (Val.bf16Bits (tailOut C tail (G row) U))) else sh) = shC
    at hrest hmC
  have hlC : ∀ j, j < 76 → lC j = tl j := fun j hj => by rw [hagC j (by omega), hb₁ j hj]
  have hF := hrl.fix.of_eq fun j hj => hlC j (by omega)
  have hst : Exec C tc rowStep lC shC .normal (setLocal lC 23 (u32 (row + 5120))) shC :=
    .set (eval_bin_u32 C (eval_local' C (by rw [hlC 23 (by omega)]; exact hrl.l23) _)
      (eval_local' C (by rw [hlC 22 (by omega)]; exact hrl.fix.l22) _) (binary_add_u32 C row 5120)) (.nil _ _)
  have hF' : Fix2 kg ku i (setLocal lC 23 (u32 (row + 5120))) := hF.of_eq fun j hj => setLocal_other _ _ (by omega)
  have hc := eval_lt_u32 C (ctx := tc) (sh := shC) (b := 17408) (setLocal_same lC 23 (u32 (row + 5120))) (by omega) (by decide)
  by_cases hnext : row + 5120 < 17408
  · rw [decide_eq_true hnext] at hc
    obtain ⟨lA, shA, xA, hrowA, haccA, hmA⟩ := row_body C hS hl hKg hKu tail hnext hF' (setLocal_same _ _ _) (by
      have := hmC; exact this)
    refine ⟨_, shA, (Exec.resume_stop (c := rowCond) (st := rowStep) (b := rowBody kg ku tail) (ss := []) (K := [])
      hrest (.inl rfl) hst hc xA).ev_stop rfl, hmA, ?_⟩
    rw [ite_eq_left hnext]
    exact ⟨rfl, rfl, rfl, hrowA, haccA⟩
  · rw [decide_eq_false hnext] at hc
    have hre := Exec.resume_exit (c := rowCond) (st := rowStep) (b := rowBody kg ku tail) (ss := []) (K := []) hrest
      (.inl rfl) hst hc
    refine ⟨_, shC, (hre.trans (.cons rfl (step_pop C) (.single rfl (step_done C)))).ev_stop rfl, hmC, ?_⟩
    rw [ite_eq_right hnext]

end Lane2

end Metal.Kernels.GateUp

namespace Metal.Kernels.GateUp
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis

/-! ## SIMD-groups, threadgroups, the launch -/

section Simd
variable (C : M1Max.Contract) {L : Launch} {kg ku : Nat} {I : In} {out : Nat → BF} {P g s : Nat}

/-- Row `k` of SIMD-group `s` of threadgroup `g`. -/
def rowOf (g s k : Nat) : Nat := 32 * g + s + 5120 * k

theorem ord_rowOf {g s k : Nat} (hg : g < 160) (hs : s < 32) (_hk : k < 4) : ord (rowOf g s k) = 128 * g + 4 * s + k := by
  unfold ord rowOf
  rw [show 32 * g + s + 5120 * k = (32 * g + s) + 5120 * k from rfl, Nat.add_mul_mod_self_left,
    Nat.mod_eq_of_lt (show 32 * g + s < 5120 by omega), Nat.add_mul_div_left _ _ (by decide),
    Nat.div_eq_of_lt (show 32 * g + s < 5120 by omega)]
  ring

theorem rowOf_mod {g s k : Nat} (hg : g < 160) (hs : s < 32) : rowOf g s k % 5120 = 32 * g + s := by
  unfold rowOf
  rw [Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt (show 32 * g + s < 5120 by omega)]

theorem ord_inj4 {r' r : Nat} (hr' : r' < 20480) (hr : r < 20480) (h : ord r' = ord r) : r' = r := by
  unfold ord at h
  have h1 : r' / 5120 < 4 := by clear h; omega
  have h2 : r / 5120 < 4 := by clear h; omega
  have h' : r' / 5120 + r' % 5120 * 4 = r / 5120 + r % 5120 * 4 := by rw [Nat.add_comm, h, Nat.add_comm]
  have e : r' / 5120 = r / 5120 := by
    have := congrArg (· % 4) h'
    simp only [Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt h1, Nat.mod_eq_of_lt h2] at this
    exact this
  rw [e] at h'
  have e2 : r' % 5120 = r % 5120 := Nat.eq_of_mul_eq_mul_right (by decide) (Nat.add_left_cancel h')
  clear h h'
  omega

theorem no_row {g s k r : Nat} (hg : g < 160) (hs : s < 32) (hk : k < 4) (hrow : 17408 ≤ rowOf g s k) (hr : r < 17408) :
    ord r ≠ 128 * g + 4 * s + k := by
  intro h
  have := ord_inj4 (r' := r) (r := rowOf g s k) (by omega) (by unfold rowOf; omega) (h.trans (ord_rowOf hg hs hk).symm)
  omega

/-- Positions without a row: past the rows of SIMD-group `s`. -/
theorem Mem.bump_to {I : In} {out : Nat → BF} {ge : Nat} {cbOk xsOk : Nat → Prop} {sh : Shared} (hg : g < 160)
    (hs : s < 32) : ∀ (n k : Nat), k + n ≤ 4 → 17408 ≤ rowOf g s k → Mem C L I out (128 * g + 4 * s + k) ge cbOk xsOk sh →
      Mem C L I out (128 * g + 4 * s + k + n) ge cbOk xsOk sh
  | 0, k, _, _, h => h
  | n + 1, k, hkn, hrow, h => by
    have h1 := h.bump (fun r hr => no_row hg hs (by omega) hrow hr)
    have := Mem.bump_to hg hs n (k + 1) (by omega) (by unfold rowOf at hrow ⊢; omega) h1
    rwa [show 128 * g + 4 * s + (k + 1) + n = 128 * g + 4 * s + k + (n + 1) by ring] at this

/-- The lanes after a row's second `simd_sum` with no row after it: lane 0 writes `mid`, all end. -/
theorem simd_last (hS : Shape L kg ku I) (hKg : Width kg) (hKu : Width ku) (tail : Bool) (hg : g < 160) (hs : s < 32)
    (ctxs : Fin 32 → Ctx) (hL : ∀ i : Fin 32, Lane (ctxs i) g s i)
    (hout : ∀ r, out r = tailOut C tail (rowSum C kg I.Gc I.Gs I.X r) (rowSum C ku I.Uc I.Us I.X r))
    (j k : Nat) (hk : k < 4) (hrow : rowOf g s k < 17408) (hlast : ¬ rowOf g s k + 5120 < 17408) (U : Fin 32 → Thread)
    (hU : ∀ i : Fin 32, AtUp kg ku tail I i (rowOf g s k) (rowSum C kg I.Gc I.Gs I.X (rowOf g s k)) (ctxs i) (U i))
    (sh : Shared) (hm : Mem C L I out (128 * g + 4 * s + k) (g + 1) (fun _ => True) (fun _ => True) sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m (j + 1) (List.ofFn fun i =>
        { U i with status := .running }.set 76 (.f32 (rowSum C ku I.Uc I.Us I.X (rowOf g s k))))).run sh =
          some (List.ofFn V, sh')) ∧
      Mem C L I out (128 * g + 4 * s + 4) (g + 1) (fun _ => True) (fun _ => True) sh' ∧ ∀ i, (V i).status = .done := by
  obtain ⟨V, sh', hr, hI, hR⟩ := runSimd_blocked_ev C j _
    (fun idx sh => Mem C L I out (128 * g + 4 * s + k + min idx 1) (g + 1) (fun _ => True) (fun _ => True) sh)
    (fun _ t => t.status = .done) (fun i sh hI => by
      obtain ⟨t', sh', he, hm', hst⟩ := lane_next C (G := fun r => rowSum C kg I.Gc I.Gs I.X r) hS (hL i) hKg hKu tail hrow
        (rowOf_mod hg hs) (hU i) (rowSum C ku I.Uc I.Us I.X (rowOf g s k)) (hout _) (ord_rowOf hg hs hk) hI
      rw [ite_eq_right hlast] at hst
      exact ⟨t', sh', he, hm', by rw [hst]; rfl, hst⟩) sh (by rw [show min 0 1 = 0 from rfl, Nat.add_zero]; exact hm)
  refine ⟨V, sh', hr, ?_, hR⟩
  have h1 : Mem C L I out (128 * g + 4 * s + (k + 1)) (g + 1) (fun _ => True) (fun _ => True) sh' := by
    rw [show min 32 1 = 1 from rfl, Nat.add_assoc] at hI; exact hI
  have := Mem.bump_to C hg hs (3 - k) (k + 1) (by omega) (by unfold rowOf at hlast ⊢; omega) h1
  rwa [show 128 * g + 4 * s + (k + 1) + (3 - k) = 128 * g + 4 * s + 4 by omega] at this

/-- The lanes after row `k`'s second `simd_sum`: the rows after it, to the end. -/
theorem simd_rows (hS : Shape L kg ku I) (hKg : Width kg) (hKu : Width ku) (tail : Bool) (hg : g < 160) (hs : s < 32)
    (ctxs : Fin 32 → Ctx) (hL : ∀ i : Fin 32, Lane (ctxs i) g s i)
    (hout : ∀ r, out r = tailOut C tail (rowSum C kg I.Gc I.Gs I.X r) (rowSum C ku I.Uc I.Us I.X r)) :
    ∀ j k, k + j = 3 → rowOf g s k < 17408 → ∀ (U : Fin 32 → Thread),
      (∀ i : Fin 32, AtUp kg ku tail I i (rowOf g s k) (rowSum C kg I.Gc I.Gs I.X (rowOf g s k)) (ctxs i) (U i)) →
      ∀ sh, Mem C L I out (128 * g + 4 * s + k) (g + 1) (fun _ => True) (fun _ => True) sh →
      ∃ (V : Fin 32 → Thread) (sh' : Shared),
        (Ev fun m => (runSimd C m (2 * j + 1) (List.ofFn fun i =>
          { U i with status := .running }.set 76 (.f32 (rowSum C ku I.Uc I.Us I.X (rowOf g s k))))).run sh =
            some (List.ofFn V, sh')) ∧
        Mem C L I out (128 * g + 4 * s + 4) (g + 1) (fun _ => True) (fun _ => True) sh' ∧ ∀ i, (V i).status = .done := by
  intro j
  induction j with
  | zero =>
    intro k hk hrow U hU sh hm
    exact simd_last C hS hKg hKu tail hg hs ctxs hL hout 0 k (by omega) hrow (by unfold rowOf; omega) U hU sh hm
  | succ j ih =>
    intro k hk hrow U hU sh hm
    by_cases hnext : rowOf g s k + 5120 < 17408
    · have hrk : rowOf g s (k + 1) = rowOf g s k + 5120 := by unfold rowOf; ring
      show ∃ V sh', (Ev fun m => (runSimd C m (2 * j + 2 + 1) _).run sh = some (List.ofFn V, sh')) ∧ _
      refine runSimd_collective_ev C (2 * j + 2) _ 2 74 .sum .f32 0
        (fun i => .f32 (gpart C kg I.Gc I.Gs I.X (rowOf g s (k + 1)) i))
        (fun _ => .f32 (rowSum C kg I.Gc I.Gs I.X (rowOf g s (k + 1))))
        (resolve_sum C 0 (fun i => gpart C kg I.Gc I.Gs I.X (rowOf g s (k + 1)) i))
        (fun idx sh => Mem C L I out (128 * g + 4 * s + k + min idx 1) (g + 1) (fun _ => True) (fun _ => True) sh)
        (fun i t => AtGate C kg ku tail I i (rowOf g s (k + 1)) (ctxs i) t)
        (Mem C L I out (128 * g + 4 * s + 4) (g + 1) (fun _ => True) (fun _ => True)) (fun _ t => t.status = .done)
        (fun i sh hI => ?_) (fun U' sh₁ hU' hI₁ => ?_) sh (by rw [show min 0 1 = 0 from rfl, Nat.add_zero]; exact hm)
      · obtain ⟨t', sh', he, hm', hst⟩ := lane_next C (G := fun r => rowSum C kg I.Gc I.Gs I.X r) hS (hL i) hKg hKu tail
          hrow (rowOf_mod hg hs) (hU i) (rowSum C ku I.Uc I.Us I.X (rowOf g s k)) (hout _) (ord_rowOf hg hs (by omega)) hI
        rw [ite_eq_left hnext] at hst
        rw [hrk]
        exact ⟨t', sh', he, hm', hst.1, hst.2⟩
      · have hm₁ : Mem C L I out (128 * g + 4 * s + (k + 1)) (g + 1) (fun _ => True) (fun _ => True) sh₁ := by
          rw [show min 32 1 = 1 from rfl, Nat.add_assoc] at hI₁; exact hI₁
        refine runSimd_collective_ev C (2 * j + 1) _ 3 76 .sum .f32 0
          (fun i => .f32 (gpart C ku I.Uc I.Us I.X (rowOf g s (k + 1)) i))
          (fun _ => .f32 (rowSum C ku I.Uc I.Us I.X (rowOf g s (k + 1))))
          (resolve_sum C 0 (fun i => gpart C ku I.Uc I.Us I.X (rowOf g s (k + 1)) i))
          (fun _ sh => sh = sh₁)
          (fun i t => AtUp kg ku tail I i (rowOf g s (k + 1)) (rowSum C kg I.Gc I.Gs I.X (rowOf g s (k + 1))) (ctxs i) t)
          (Mem C L I out (128 * g + 4 * s + 4) (g + 1) (fun _ => True) (fun _ => True)) (fun _ t => t.status = .done)
          (fun i sh hI => ?_) (fun U'' sh₂ hU'' hI₂ => ?_) sh₁ rfl
        · subst hI
          obtain ⟨t', he, hst, hat⟩ := lane_gate C tail (hU' i) (rowSum C kg I.Gc I.Gs I.X (rowOf g s (k + 1))) sh
          exact ⟨t', sh, he, rfl, hst, hat⟩
        · subst hI₂
          exact ih (k + 1) (by omega) (by omega) U'' hU'' sh₂ hm₁
    · obtain ⟨V, sh', hr, hm', hR⟩ := simd_last C hS hKg hKu tail hg hs ctxs hL hout (2 * j + 2) k (by omega) hrow hnext U hU
        sh hm
      exact ⟨V, sh', hr, hm', hR⟩

end Simd

end Metal.Kernels.GateUp

namespace Metal.Kernels.GateUp
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis

section Group
variable (C : M1Max.Contract) {L : Launch} {kg ku : Nat} {I : In} {out : Nat → BF} {P g s : Nat}

/-- A lane at the barrier. -/
def AtBar (kg ku : Nat) (tail : Bool) (ctx : Ctx) (t : Thread) : Prop :=
  t.status = .barrier 1 false true ∧ t.ctx = ctx ∧ t.frames = [.block (rest1 kg ku tail)] ∧ Fix1 t.locals

/-- SIMD-group `s` to the barrier: its lanes' codebook entries and `xs` chunks. -/
theorem simd_phase1 (hS : Shape L kg ku I) (tail : Bool) (_hg : g < 160) (_hs : s < 32) (ctxs : Fin 32 → Ctx)
    (hL : ∀ i : Fin 32, Lane (ctxs i) g s i) {sh : Shared}
    (hm : Mem C L I out P g (fun e => e % 1024 < 32 * s) (fun c => c < 32 * s) sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m 9 (List.ofFn fun i =>
        (⟨ctxs i, fun _ => none, [.block (body kg ku tail)], .running⟩ : Thread))).run sh = some (List.ofFn V, sh')) ∧
      Mem C L I out P g (fun e => e % 1024 < 32 * (s + 1)) (fun c => c < 32 * (s + 1)) sh' ∧
      ∀ i, (V i).status = .barrier 1 false true ∧ AtBar kg ku tail (ctxs i) (V i) := by
  obtain ⟨V, sh', hr, hI, hR⟩ := runSimd_blocked_ev C 8 _
    (fun idx sh => Mem C L I out P g (fun e => e % 1024 < 32 * s + idx) (fun c => c < 32 * s + idx) sh)
    (fun i t => t.status = .barrier 1 false true ∧ AtBar kg ku tail (ctxs i) t) (fun i sh hI => by
      obtain ⟨t, sh', he, hm', hst, hc, hf, hF⟩ := lane_phase1 C hS (hL i) tail hI
      exact ⟨t, sh', he, hm', by rw [hst]; rfl, hst, hst, hc, hf, hF⟩) sh (by simpa using hm)
  exact ⟨V, sh', hr, by simpa [Nat.mul_add] using hI, hR⟩

/-- SIMD-group `s` after the barrier: its rows. -/
theorem simd_phase2 (hS : Shape L kg ku I) (hKg : Width kg) (hKu : Width ku) (tail : Bool) (hg : g < 160) (hs : s < 32)
    (ctxs : Fin 32 → Ctx) (hL : ∀ i : Fin 32, Lane (ctxs i) g s i)
    (hout : ∀ r, out r = tailOut C tail (rowSum C kg I.Gc I.Gs I.X r) (rowSum C ku I.Uc I.Us I.X r))
    (U : Fin 32 → Thread) (hU : ∀ i, AtBar kg ku tail (ctxs i) (U i)) {sh : Shared}
    (hm : Mem C L I out (128 * g + 4 * s) (g + 1) (fun _ => True) (fun _ => True) sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m 9 (List.ofFn fun i => { U i with status := .running })).run sh = some (List.ofFn V, sh')) ∧
      Mem C L I out (128 * g + 4 * s + 4) (g + 1) (fun _ => True) (fun _ => True) sh' ∧ ∀ i, (V i).status = .done := by
  have hr0 : rowOf g s 0 = 32 * g + s := by unfold rowOf; ring
  refine runSimd_collective_ev C 8 _ 2 74 .sum .f32 0
    (fun i => .f32 (gpart C kg I.Gc I.Gs I.X (rowOf g s 0) i))
    (fun _ => .f32 (rowSum C kg I.Gc I.Gs I.X (rowOf g s 0)))
    (resolve_sum C 0 (fun i => gpart C kg I.Gc I.Gs I.X (rowOf g s 0) i))
    (fun _ sh => Mem C L I out (128 * g + 4 * s) (g + 1) (fun _ => True) (fun _ => True) sh)
    (fun i t => AtGate C kg ku tail I i (rowOf g s 0) (ctxs i) t)
    (Mem C L I out (128 * g + 4 * s + 4) (g + 1) (fun _ => True) (fun _ => True)) (fun _ t => t.status = .done)
    (fun i sh hI => ?_) (fun U' sh₁ hU' hI₁ => ?_) sh hm
  · obtain ⟨hst, hc, hf, hF⟩ := hU i
    generalize U i = t at hst hc hf hF ⊢
    obtain ⟨tc, tl, tf, ts⟩ := t
    dsimp only at hst hc hf hF
    subst hc hf
    obtain ⟨t, sh', he, hm', hst', hat⟩ := lane_first C hS (hL i) hKg hKu tail hF hI
    rw [hr0]
    exact ⟨t, sh', he, hm', hst', hat⟩
  · refine runSimd_collective_ev C 7 _ 3 76 .sum .f32 0
      (fun i => .f32 (gpart C ku I.Uc I.Us I.X (rowOf g s 0) i))
      (fun _ => .f32 (rowSum C ku I.Uc I.Us I.X (rowOf g s 0)))
      (resolve_sum C 0 (fun i => gpart C ku I.Uc I.Us I.X (rowOf g s 0) i))
      (fun _ sh => sh = sh₁)
      (fun i t => AtUp kg ku tail I i (rowOf g s 0) (rowSum C kg I.Gc I.Gs I.X (rowOf g s 0)) (ctxs i) t)
      (Mem C L I out (128 * g + 4 * s + 4) (g + 1) (fun _ => True) (fun _ => True)) (fun _ t => t.status = .done)
      (fun i sh hI => ?_) (fun U'' sh₂ hU'' hI₂ => ?_) sh₁ rfl
    · subst hI
      obtain ⟨t', he, hst, hat⟩ := lane_gate C tail (hU' i) (rowSum C kg I.Gc I.Gs I.X (rowOf g s 0)) sh
      exact ⟨t', sh, he, rfl, hst, hat⟩
    · subst hI₂
      exact simd_rows C hS hKg hKu tail hg hs ctxs hL hout 3 0 rfl (by unfold rowOf; omega) U'' hU'' sh₂ (by simpa using hI₁)

/-- A threadgroup: the barrier, then its 32 SIMD-groups' rows. -/
theorem group_run (hS : Shape L kg ku I) (hKg : Width kg) (hKu : Width ku) (tail : Bool) (hg : g < 160)
    (ctxOf : Fin 32 → Fin 32 → Ctx) (hL : ∀ (s : Fin 32) (i : Fin 32), Lane (ctxOf s i) g s i)
    (hout : ∀ r, out r = tailOut C tail (rowSum C kg I.Gc I.Gs I.X r) (rowSum C ku I.Uc I.Us I.X r)) {sh : Shared}
    (hm : Mem C L I out (128 * g) g (fun _ => False) (fun _ => False) sh) :
    ∃ sh', (Ev fun m => (runGroup C m 9 2 (List.ofFn fun s : Fin 32 => List.ofFn fun i =>
        (⟨ctxOf s i, fun _ => none, [.block (body kg ku tail)], .running⟩ : Thread))).run sh = some ((), sh')) ∧
      Mem C L I out (128 * g + 128) (g + 1) (fun _ => True) (fun _ => True) sh' := by
  refine runGroup_barrier_ev C (by decide) 9 1 _ 1 false true
    (fun j sh => Mem C L I out (128 * g) g (fun e => e % 1024 < 32 * j) (fun c => c < 32 * j) sh)
    (fun j i t => AtBar kg ku tail (ctxOf j i) t)
    (Mem C L I out (128 * g + 128) (g + 1) (fun _ => True) (fun _ => True))
    (fun j sh hj => ?_) (fun U sh hU hI => ?_) sh (hm.mono (fun e _ h => by omega) (fun c _ h => by omega))
  · obtain ⟨V, sh', hr, hm', hV⟩ := simd_phase1 C hS tail hg j.isLt (ctxOf j) (hL j) hj
    exact ⟨V, sh', hr, hm', fun i => ⟨(hV i).1, (hV i).2⟩⟩
  · have hp : Mem C L I out (128 * g + 4 * 0) (g + 1) (fun _ => True) (fun _ => True) (pass false true sh) :=
      hI.pass.mono (fun e _ _ => by omega) (fun c hc _ => by omega)
    exact runGroup_done_ev C 9 0 _ (fun j sh => Mem C L I out (128 * g + 4 * j) (g + 1) (fun _ => True) (fun _ => True) sh)
      (fun j sh hj => simd_phase2 C hS hKg hKu tail hg j.isLt (ctxOf j) (hL j) hout (U j) (hU j) hj) _ hp

/-- The launch: the 160 threadgroups in order. -/
theorem launch_run {tail : Bool} {initial : Nat → ByteMemory.Bytes} (hS : Shape (launch kg ku tail I initial) kg ku I)
    (hKg : Width kg) (hKu : Width ku) (fuse : Nat → Bool) (garbage : Garbage) :
    ∃ sh, (∃ cbOk xsOk, Mem C (launch kg ku tail I initial) I (midOut C kg ku tail I.X I.Gc I.Gs I.Uc I.Us) (128 * 160) 160
        cbOk xsOk sh) ∧
      Ev fun m => runLaunch C fuse (launch kg ku tail I initial) garbage m 9 2 = some ⟨sh.bytes, sh.log⟩ := by
  have hb : (launch kg ku tail I initial).buffers = buffers (bufs kg ku I) [34816] 16 initial := rfl
  obtain ⟨sh, hI, hr⟩ := launch_tiles.launch_run_ev C fuse garbage 9 2
    (fun G sh => ∃ cbOk xsOk, Mem C (launch kg ku tail I initial) I (midOut C kg ku tail I.X I.Gc I.Gs I.Uc I.Us) (128 * G)
      G cbOk xsOk sh)
    ⟨fun _ => False, fun _ => False, rfl, initial_input hb garbage 0 (by simp [bufs]),
      initial_input hb garbage 1 (by simp [bufs]), initial_input hb garbage 2 (by simp [bufs]),
      initial_input hb garbage 3 (by simp [bufs]), initial_input hb garbage 4 (by simp [bufs]), rfl, rfl,
      fun _ _ h => h.elim, fun _ _ h => h.elim, fun r _ h => absurd h (by omega), fun a ha => by simp [Launch.initial] at ha⟩
    (fun bx byy bz hx hy hz sh hI => by
      obtain rfl : bx = 0 := by omega
      obtain rfl : bz = 0 := by omega
      obtain ⟨cbOk, xsOk, hm⟩ := hI
      have hm' := hm.reset rfl garbage (0 + byy * 1 + 0 * 1 * 160)
      rw [show 0 + byy * 1 + 0 * 1 * 160 = byy by ring] at hm' ⊢
      obtain ⟨sh', hr, hm''⟩ := group_run C hS hKg hKu tail hy
        (fun s i => (launch kg ku tail I initial).ctxAt fuse 0 byy 0 (32 * s + i)) (fun s i => lane_of fuse hy s i)
        (fun r => rfl) hm'
      exact ⟨sh', hr, _, _, by rw [show 128 * (byy + 1) = 128 * byy + 128 by ring]; exact hm''⟩)
  exact ⟨sh, hI, hr⟩

end Group

theorem ord_lt (r : Nat) (hr : r < 17408) : ord r < 128 * 160 := by unfold ord; omega

variable (C : M1Max.Contract)

/-- **The GPU runs the gate-up kernel as its source says**, for gate and up widths `kg`, `ku` in 1 … 4 and either
tail, given that the text compiles to `core kg ku tail`. Under the GPU assumption, MLX's launch on any `x` (16-byte
aligned: the kernel reads it as `uint4`), codes (4-aligned) and scales (2-aligned) writes to `mid` every row's
`tailOut` of its `simd_sum`s of the lanes' `fma` accumulations of the trellis-decoded weights times `x`. -/
theorem gpu_output_of (kg ku : Nat) (tail : Bool) (hKg : Width kg) (hKu : Width ku) (text : List Char)
    (hc : (frontend text).bind elaborate = some (core kg ku tail)) (G : Gpu C) (hmax : 1024 ≤ G.maxThreads text)
    (X Gc Gs Uc Us : ByteMemory.Bytes) (ax ag as au aus : Nat) (hax : 16 ∣ ax) (hag : 4 ∣ ag) (has : 2 ∣ as)
    (hau : 4 ∣ au) (haus : 2 ∣ aus) :
    G.execute text (1024, 160, 1) (1024, 1, 1)
      [⟨.device, 10240, ax, X⟩, ⟨.device, codesBytes kg, ag, Gc⟩, ⟨.device, 34816, as, Gs⟩,
        ⟨.device, codesBytes ku, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816] =
      some [expected C kg ku tail X Gc Gs Uc Us] := by
  have h := gpu_owned C G (text := text) (grid := (1024, 160, 1)) (tg := (1024, 1, 1))
    (inputs := [⟨.device, 10240, ax, X⟩, ⟨.device, codesBytes kg, ag, Gc⟩, ⟨.device, 34816, as, Gs⟩,
        ⟨.device, codesBytes ku, au, Uc⟩, ⟨.device, 34816, aus, Us⟩]) (sizes := [34816])
    (fun _ => expected C kg ku tail X Gc Gs Uc Us) hc (by simpa using hmax) (fun initial garbage => by
      have hS := launch_shape (kg := kg) (ku := ku) (tail := tail) (I := ⟨X, Gc, Gs, Uc, Us, ax, ag, as, au, aus⟩)
        (initial := initial) (Nat.mod_eq_zero_of_dvd hax) (Nat.mod_eq_zero_of_dvd hag) (Nat.mod_eq_zero_of_dvd has)
        (Nat.mod_eq_zero_of_dvd hau) (Nat.mod_eq_zero_of_dvd haus)
      obtain ⟨sh, ⟨cbOk, xsOk, hm⟩, n, hn⟩ := launch_run C hS hKg hKu (G.fusion text) garbage
      refine ⟨n, 9, 2, sh, dev, tgo, hn n le_rfl, hm.log, ?_⟩
      intro i hi b hb
      obtain rfl : i = 0 := by simp at hi; omega
      have hb' : b < 34816 := by simpa using hb
      show sh.bytes 5 b = expected C kg ku tail X Gc Gs Uc Us b
      have := hm.mid (b / 2) (by omega) (ord_lt _ (by omega))
      rw [expected, ite_eq_left hb', ← this, cells_getD _ _ _ _ (by omega), show 2 * (b / 2) + b % 2 = b by omega])
  rw [h]
  show some [fun b => if b < 34816 then expected C kg ku tail X Gc Gs Uc Us b else 0] = _
  congr 2
  funext b
  unfold expected
  split <;> simp_all

/-! ## The route's gate and up widths

The MLP layouts of the route's stages (`Host.Load.Run.Full.Expected.stages`) have gate and up widths (2, 2), (3, 3),
(4, 4), so TAIL = 0, and (3, 2), (2, 3), (4, 3), (3, 4), so TAIL = 1. Codes of width `K` are `17408·640·K` bytes:
22282240 (2-bit), 33423360 (3-bit), 44564480 (4-bit). -/

section Route
variable {X Gc Gs Uc Us : ByteMemory.Bytes} {ax ag as au aus : Nat}

theorem width_2 : Width 2 := .inr (.inl rfl)
theorem width_3 : Width 3 := .inr (.inr (.inl rfl))
theorem width_4 : Width 4 := .inr (.inr (.inr rfl))

theorem gpu_output_2_2 (G : Gpu C) (hmax : 1024 ≤ G.maxThreads (text 2 2)) (hax : 16 ∣ ax) (hag : 4 ∣ ag)
    (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus) :
    G.execute (text 2 2) (1024, 160, 1) (1024, 1, 1)
      [⟨.device, 10240, ax, X⟩, ⟨.device, 22282240, ag, Gc⟩, ⟨.device, 34816, as, Gs⟩,
        ⟨.device, 22282240, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816] =
      some [expected C 2 2 false X Gc Gs Uc Us] :=
  gpu_output_of C 2 2 false width_2 width_2 _ compile_2_2 G hmax X Gc Gs Uc Us ax ag as au aus hax hag has hau haus

theorem gpu_output_3_3 (G : Gpu C) (hmax : 1024 ≤ G.maxThreads (text 3 3)) (hax : 16 ∣ ax) (hag : 4 ∣ ag)
    (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus) :
    G.execute (text 3 3) (1024, 160, 1) (1024, 1, 1)
      [⟨.device, 10240, ax, X⟩, ⟨.device, 33423360, ag, Gc⟩, ⟨.device, 34816, as, Gs⟩,
        ⟨.device, 33423360, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816] =
      some [expected C 3 3 false X Gc Gs Uc Us] :=
  gpu_output_of C 3 3 false width_3 width_3 _ compile_3_3 G hmax X Gc Gs Uc Us ax ag as au aus hax hag has hau haus

theorem gpu_output_4_4 (G : Gpu C) (hmax : 1024 ≤ G.maxThreads (text 4 4)) (hax : 16 ∣ ax) (hag : 4 ∣ ag)
    (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus) :
    G.execute (text 4 4) (1024, 160, 1) (1024, 1, 1)
      [⟨.device, 10240, ax, X⟩, ⟨.device, 44564480, ag, Gc⟩, ⟨.device, 34816, as, Gs⟩,
        ⟨.device, 44564480, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816] =
      some [expected C 4 4 false X Gc Gs Uc Us] :=
  gpu_output_of C 4 4 false width_4 width_4 _ compile_4_4 G hmax X Gc Gs Uc Us ax ag as au aus hax hag has hau haus

theorem gpu_output_3_2 (G : Gpu C) (hmax : 1024 ≤ G.maxThreads (text 3 2)) (hax : 16 ∣ ax) (hag : 4 ∣ ag)
    (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus) :
    G.execute (text 3 2) (1024, 160, 1) (1024, 1, 1)
      [⟨.device, 10240, ax, X⟩, ⟨.device, 33423360, ag, Gc⟩, ⟨.device, 34816, as, Gs⟩,
        ⟨.device, 22282240, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816] =
      some [expected C 3 2 true X Gc Gs Uc Us] :=
  gpu_output_of C 3 2 true width_3 width_2 _ compile_3_2 G hmax X Gc Gs Uc Us ax ag as au aus hax hag has hau haus

theorem gpu_output_2_3 (G : Gpu C) (hmax : 1024 ≤ G.maxThreads (text 2 3)) (hax : 16 ∣ ax) (hag : 4 ∣ ag)
    (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus) :
    G.execute (text 2 3) (1024, 160, 1) (1024, 1, 1)
      [⟨.device, 10240, ax, X⟩, ⟨.device, 22282240, ag, Gc⟩, ⟨.device, 34816, as, Gs⟩,
        ⟨.device, 33423360, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816] =
      some [expected C 2 3 true X Gc Gs Uc Us] :=
  gpu_output_of C 2 3 true width_2 width_3 _ compile_2_3 G hmax X Gc Gs Uc Us ax ag as au aus hax hag has hau haus

theorem gpu_output_4_3 (G : Gpu C) (hmax : 1024 ≤ G.maxThreads (text 4 3)) (hax : 16 ∣ ax) (hag : 4 ∣ ag)
    (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus) :
    G.execute (text 4 3) (1024, 160, 1) (1024, 1, 1)
      [⟨.device, 10240, ax, X⟩, ⟨.device, 44564480, ag, Gc⟩, ⟨.device, 34816, as, Gs⟩,
        ⟨.device, 33423360, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816] =
      some [expected C 4 3 true X Gc Gs Uc Us] :=
  gpu_output_of C 4 3 true width_4 width_3 _ compile_4_3 G hmax X Gc Gs Uc Us ax ag as au aus hax hag has hau haus

theorem gpu_output_3_4 (G : Gpu C) (hmax : 1024 ≤ G.maxThreads (text 3 4)) (hax : 16 ∣ ax) (hag : 4 ∣ ag)
    (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus) :
    G.execute (text 3 4) (1024, 160, 1) (1024, 1, 1)
      [⟨.device, 10240, ax, X⟩, ⟨.device, 33423360, ag, Gc⟩, ⟨.device, 34816, as, Gs⟩,
        ⟨.device, 44564480, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816] =
      some [expected C 3 4 true X Gc Gs Uc Us] :=
  gpu_output_of C 3 4 true width_3 width_4 _ compile_3_4 G hmax X Gc Gs Uc Us ax ag as au aus hax hag has hau haus

/-- At gate and up 2-bit, the text is tests/Elab.lean's `gateUpText`. -/
theorem gpu_output (G : Gpu C) (hmax : 1024 ≤ G.maxThreads Metal.Elab.Tests.gateUpText) (hax : 16 ∣ ax) (hag : 4 ∣ ag)
    (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus) :
    G.execute Metal.Elab.Tests.gateUpText (1024, 160, 1) (1024, 1, 1)
      [⟨.device, 10240, ax, X⟩, ⟨.device, 22282240, ag, Gc⟩, ⟨.device, 34816, as, Gs⟩,
        ⟨.device, 22282240, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816] =
      some [expected C 2 2 false X Gc Gs Uc Us] := by
  rw [← text_two] at hmax ⊢
  exact gpu_output_2_2 C G hmax hax hag has hau haus

end Route

end Metal.Kernels.GateUp
