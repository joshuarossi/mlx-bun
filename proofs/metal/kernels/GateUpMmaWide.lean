import metal.Elab
import metal.Frontend
import metal.Assemble
import host.mlx.PrefillKernelSources
import metal.kernels.GateUp

namespace Metal.Kernels.GateUpMmaWide
open Metal Metal.Core

/-! # gate-up-mma-wide.ts: `mlx_bun_trellis_gateup_mma_wide`

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
template <int K, int BT_>
inline void load_run(const device uint32_t* rowCodes, uint run, thread uint* w) {
  const uint wpb = (uint)(BT_ * K / 32);
  const uint runsPerBlock = (uint)BT_ / 32u;
  const uint blk = run / runsPerBlock;
  const uint t0 = (run - blk * runsPerBlock) * 32u;
  const device uint32_t* bw = rowCodes + blk * wpb;
  const uint w0 = ((uint)BT_ - 32u - t0) * (uint)K / 32u;
  #pragma clang loop unroll(full)
  for (uint i = 0; i <= (uint)K; ++i) {
    const uint wi = w0 + i;
    w[i] = bw[wi >= wpb ? wi - wpb : wi];
  }
}
template <int K, int L_>
inline uint run_state(thread const uint* w, uint j) {
  const uint b = (31u - j) * (uint)K;
  const uint wi = b >> 5;
  const uint off = b & 31u;
  uint win = w[wi] >> off;
  if (off + (uint)L_ > 32u) win |= w[wi + 1] << (32u - off);
  return win & ((1u << (uint)L_) - 1u);
}
```
The body:

```
const uint M = (uint)x_shape[0];
const uint lane = thread_index_in_simdgroup;
const uint sg = simdgroup_index_in_threadgroup;
const uint tid = sg * 32u + lane;
threadgroup half codebook[1 << L];
threadgroup T xs[8 * MT][256];
for (uint i = tid; i < (1u << (uint)L); i += 32u * (uint)SG_TG) codebook[i] = half(trellis_y_f32(i));
const uint n0 = (threadgroup_position_in_grid.y * (uint)SG_TG + sg) * 8u;
const uint fm = ((lane / 4u) & 4u) + ((lane / 2u) % 4u);
const uint fn = ((lane / 4u) & 2u) * 2u + (lane % 2u) * 2u;
const uint row = metal::min(n0 + fm, (uint)R - 1u);
const device uint32_t* gRow = gcodes + (ulong)row * (ulong)((C / BT) * (BT * KG / 32));
const device uint32_t* uRow = ucodes + (ulong)row * (ulong)((C / BT) * (BT * KU / 32));
const uint mBase = threadgroup_position_in_grid.z * 8u * (uint)MT;
metal::simdgroup_float8x8 accG[MT], accU[MT];
#pragma clang loop unroll(full)
for (uint bk = 0; bk < (uint)MT; ++bk) {
  accG[bk] = metal::make_filled_simdgroup_matrix<float, 8, 8>(0.0f);
  accU[bk] = metal::make_filled_simdgroup_matrix<float, 8, 8>(0.0f);
}
for (uint base = 0; base < (uint)C; base += 256u) {
  threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  for (uint e = tid; e < 8u * (uint)MT * 64u; e += 32u * (uint)SG_TG) {
    const uint r = e / 64u, c4 = e % 64u, m = mBase + r;
    const metal::vec<T, 4> v = m < M ? ((const device metal::vec<T, 4>*)(x + (ulong)m * (ulong)C + base))[c4]
      : metal::vec<T, 4>(0);
    *((threadgroup metal::vec<T, 4>*)(&xs[r][c4 * 4u])) = v;
  }
  threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  const uint runA = base / 32u + fn;
  uint ga[KG + 1], gb[KG + 1], ua[KU + 1], ub[KU + 1];
  load_run<KG, BT>(gRow, runA, ga);
  load_run<KG, BT>(gRow, runA + 1u, gb);
  load_run<KU, BT>(uRow, runA, ua);
  load_run<KU, BT>(uRow, runA + 1u, ub);
  #pragma clang loop unroll(full)
  for (uint j = 0; j < 32u; ++j) {
    metal::simdgroup_float8x8 aG, aU;
    aG.thread_elements()[0] = float(codebook[run_state<KG, L>(ga, j)]);
    aG.thread_elements()[1] = float(codebook[run_state<KG, L>(gb, j)]);
    aU.thread_elements()[0] = float(codebook[run_state<KU, L>(ua, j)]);
    aU.thread_elements()[1] = float(codebook[run_state<KU, L>(ub, j)]);
    #pragma clang loop unroll(full)
    for (uint bk = 0; bk < (uint)MT; ++bk) {
      metal::simdgroup_float8x8 b;
      b.thread_elements()[0] = float(xs[8u * bk + fn][fm * 32u + j]);
      b.thread_elements()[1] = float(xs[8u * bk + fn + 1u][fm * 32u + j]);
      metal::simdgroup_multiply_accumulate(accG[bk], aG, b, accG[bk]);
      metal::simdgroup_multiply_accumulate(accU[bk], aU, b, accU[bk]);
    }
  }
}
if (n0 >= (uint)R) return;
const float gs = float(gscales[row]) * TRELLIS_RCP;
const float us = float(uscales[row]) * TRELLIS_RCP;
#pragma clang loop unroll(full)
for (uint bk = 0; bk < (uint)MT; ++bk)
  #pragma clang loop unroll(full)
  for (uint j = 0; j < 2u; ++j) {
    const uint m = mBase + 8u * bk + fn + j;
    if (m >= M) continue;
    const T gateT = T(accG[bk].thread_elements()[j] * gs);
    const T upT = T(accU[bk].thread_elements()[j] * us);
    const T sigmoidT = T(1.0f / (1.0f + metal::precise::exp(-float(gateT))));
    const T siluT = T(float(gateT) * float(sigmoidT));
    mid[(ulong)m * (ulong)R + row] = T(float(siluT) * float(upT));
  }
```
Launch (gate-up-mma-wide.ts:121-144): inputs `x` bfloat16 `[M, C]` (its shape buffer `x_shape` follows
it), `gcodes` and `ucodes` uint32 (row-major words), `gscales` and `uscales` float16; output `mid`
bfloat16 `[M, R]`; `T` = bfloat16, template ints R, C, BT, KG, KU, L, SG_TG = 8, MT; grid
`[256, R/64, ⌈M/(8·MT)⌉]`, threadgroup `[256, 1, 1]`; MT = 3 when ⌈M/8⌉ = 3, else 2 (`rowBlocks`). The
route reaches it in the wide forwards (9 to 223 prompt rows, and chunks of 16 to 128) at R = 17408,
C = 5120, BT = 256, L = 12 for every layer's gate and up bit widths: (KG, KU) ∈ {(2,2), (3,3), (3,2),
(2,3), (4,3), (4,4), (3,4)} (host/load/Data.lean), each at MT 2 and 3. The core depends on KG, KU and
MT only through constants and array sizes: `core kg ku mt`.

`aG`, `aU` and `b` are declared without initializer, so each is a one-element thread array;
`accG`, `accU` are thread arrays of MT matrices. The staging store through
`(threadgroup vec<T, 4>*)(&xs[r][c4 * 4u])` keeps the declared array element's 2-byte alignment
(clang's `align 2` store), so it is four `bfloat` stores. -/

def u32l (n : Nat) : CExpr := .lit (.int .u32 n)
def u64l (n : Nat) : CExpr := .lit (.int .u64 n)
def u16l (n : Nat) : CExpr := .lit (.int .u16 n)
def i32l (n : Nat) : CExpr := .lit (.int .i32 n)
def f32l (bits : Nat) : CExpr := .lit (.f32 (Val.ofF32Bits bits))
def bf16l (bits : Nat) : CExpr := .lit (.bf16 (Val.ofBf16Bits bits))

def u32 (op : Core.BinOp) (a b : CExpr) : CExpr := .bin op .u32 0 a b
def u64 (op : Core.BinOp) (a b : CExpr) : CExpr := .bin op .u64 0 a b
def toU64 (e : CExpr) : CExpr := .conv .u64 e
def ld (p : CExpr) : CExpr := .load (.scalar .u32) p
/-- `i < n` (or `≤`) and `++i` for the counter in slot `i`. -/
def lt (i n : Nat) : CExpr := u32 .lt (.local i) (u32l n)
def le (i n : Nat) : CExpr := u32 .le (.local i) (u32l n)
def incr (i : Nat) : List CStmt := [.set i (u32 .add (.local i) (u32l 1))]

/-! ## The header functions -/

/-- `trellis_y_f32(s)` with `s` in slot `b`: slots `b` s, `b + 1` the result, then `trellis_y`'s
`b + 2` s, `b + 3` result, `b + 4` x, `b + 5` p. -/
def yF32 (b : Nat) : CStmt :=
  .scope
    [.set (b + 2) (.local b),
     .scope
       [.set (b + 4) (u32 .add (u32 .mul (.local (b + 2)) (u32l 34038481)) (u32l 76625530)),
        .set (b + 5) (u32 .add (u32 .bitAnd (.local (b + 4)) (u32l 0x00FF00FF))
          (u32 .bitAnd (u32 .shr (.local (b + 4)) (u32l 8)) (u32l 0x00FF00FF))),
        .set (b + 3) (.bin .sub .i32 0
          (.conv .i32 (u32 .add (u32 .bitAnd (.local (b + 5)) (u32l 0xFFFF)) (u32 .shr (.local (b + 5)) (u32l 16))))
          (i32l 510)),
        .leave],
     .set (b + 1) (.bin .sub .f32 0
       (.bitcast .f32 (u32 .bitOr (u32l 0x4B000000) (.conv .u32 (.bin .add .i32 0 (.local (b + 3)) (i32l 510)))))
       (f32l 0x4B0001FE)),
     .leave]

/-- `load_run<K, 256>(rowCodes, run, w)` with its arguments set into slots `b` … `b + 2`: slots `b`
rowCodes, `b + 1` run, `b + 2` w, (`b + 3` the void result), `b + 4` wpb, `b + 5` runsPerBlock,
`b + 6` blk, `b + 7` t0, `b + 8` bw, `b + 9` w0, `b + 10` i, `b + 11` wi. -/
def run (k b : Nat) (rowCodes runE w : CExpr) : List CStmt :=
  [.set b rowCodes, .set (b + 1) runE, .set (b + 2) w,
   .scope
     [.set (b + 4) (u32l (8 * k)),
      .set (b + 5) (u32l 8),
      .set (b + 6) (u32 .div (.local (b + 1)) (.local (b + 5))),
      .set (b + 7) (u32 .mul (u32 .sub (.local (b + 1)) (u32 .mul (.local (b + 6)) (.local (b + 5)))) (u32l 32)),
      .set (b + 8) (.offset (.local b) (u32 .mul (.local (b + 6)) (.local (b + 4)))),
      .set (b + 9) (u32 .div (u32 .mul (u32 .sub (u32l 224) (.local (b + 7))) (u32l k)) (u32l 32)),
      .set (b + 10) (u32l 0),
      .loop (le (b + 10) k) (incr (b + 10))
        [.set (b + 11) (u32 .add (.local (b + 9)) (.local (b + 10))),
         .store (.scalar .u32) (.offset (.local (b + 2)) (.local (b + 10)))
           (ld (.offset (.local (b + 8))
             (.cond (u32 .ge (.local (b + 11)) (.local (b + 4))) (u32 .sub (.local (b + 11)) (.local (b + 4)))
               (.local (b + 11)))))]]]

/-- `run_state<K, 12>(w, j)` with its arguments set into slots `b`, `b + 1`: slots `b` w, `b + 1` j,
`b + 2` the result, `b + 3` b, `b + 4` wi, `b + 5` off, `b + 6` win. -/
def state (k b : Nat) (w j : CExpr) : List CStmt :=
  [.set b w, .set (b + 1) j,
   .scope
     [.set (b + 3) (u32 .mul (u32 .sub (u32l 31) (.local (b + 1))) (u32l k)),
      .set (b + 4) (u32 .shr (.local (b + 3)) (u32l 5)),
      .set (b + 5) (u32 .bitAnd (.local (b + 3)) (u32l 31)),
      .set (b + 6) (u32 .shr (ld (.offset (.local b) (.local (b + 4)))) (.local (b + 5))),
      .ite (u32 .gt (u32 .add (.local (b + 5)) (u32l 12)) (u32l 32))
        [.set (b + 6) (u32 .bitOr (.local (b + 6))
          (u32 .shl (ld (.offset (.local b) (u32 .add (.local (b + 4)) (u32l 1)))) (u32 .sub (u32l 32) (.local (b + 5)))))]
        [],
      .set (b + 2) (u32 .bitAnd (.local (b + 6)) (u32l 4095)),
      .leave]]

/-! ## The body -/

/-- `float(codebook[…])` stored to element `e` of the matrix at slot `m`, the state in slot `r`. -/
def aElem (m e r : Nat) : CStmt :=
  .store (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (.local m)) (i32l e))
    (.conv .f32 (.load (.scalar .f16) (.offset (.local 11) (.local r))))

/-- `float(xs[8u * bk + fn + d][fm * 32u + j])`. -/
def xsElem (d : Nat) : CExpr :=
  let r := u32 .add (u32 .mul (u32l 8) (.local 120)) (.local 22)
  .conv .f32 (.load (.scalar .bf16)
    (.offset (.offset (.local 12) (u64 .mul (toU64 (if d = 0 then r else u32 .add r (u32l 1))) (u64l 256)))
      (u32 .add (u32 .mul (.local 21) (u32l 32)) (.local 89))))

/-- One row block `bk` (slot 120) of position `j`: `b` (slot 121), the two collectives (results in
122, 123) stored back to `accG[bk]`, `accU[bk]`. -/
def blockBody : List CStmt :=
  [.array 121 false 8 (.vec .f32 2),
   .store (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (.local 121)) (i32l 0)) (xsElem 0),
   .store (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (.local 121)) (i32l 1)) (xsElem 1),
   .collective 3 122 (.mma .f32 .f32) .f32
     (.vector .f32 [.load (.vec .f32 2) (.local 90), .load (.vec .f32 2) (.local 121),
       .load (.vec .f32 2) (.offset (.local 27) (.local 120))]) (u16l 0),
   .store (.vec .f32 2) (.offset (.local 27) (.local 120)) (.local 122),
   .collective 4 123 (.mma .f32 .f32) .f32
     (.vector .f32 [.load (.vec .f32 2) (.local 91), .load (.vec .f32 2) (.local 121),
       .load (.vec .f32 2) (.offset (.local 28) (.local 120))]) (u16l 0),
   .store (.vec .f32 2) (.offset (.local 28) (.local 120)) (.local 123)]

/-- One position `j` (slot 89): `aG` (slot 90), `aU` (91), their four states, the row blocks. -/
def positionBody (kg ku mt : Nat) : List CStmt :=
  [.array 90 false 6 (.vec .f32 2),
   .array 91 false 7 (.vec .f32 2)] ++
  state kg 92 (.local 37) (.local 89) ++ [aElem 90 0 94] ++
  state kg 99 (.local 38) (.local 89) ++ [aElem 90 1 101] ++
  state ku 106 (.local 39) (.local 89) ++ [aElem 91 0 108] ++
  state ku 113 (.local 40) (.local 89) ++ [aElem 91 1 115] ++
  [.set 120 (u32l 0),
   .loop (lt 120 mt) (incr 120) blockBody]

/-- The staging store of `v` (slot 35) to `xs[r][c4 * 4u]`, component `i`. -/
def stageStore (i : Nat) : CStmt :=
  .store (.scalar .bf16)
    (.offset (.ptrCast (.scalar .bf16) (.ptrCast (.vec .bf16 4)
      (.offset (.offset (.local 12) (u64 .mul (toU64 (.local 32)) (u64l 256))) (u32 .mul (.local 33) (u32l 4)))))
      (i32l i))
    (.component (.local 35) (u32l i))

/-- One staged element `e` (slot 31): `r`, `c4`, `m` (32 … 34), `v` (35). -/
def stageBody : List CStmt :=
  [.set 32 (u32 .div (.local 31) (u32l 64)),
   .set 33 (u32 .rem (.local 31) (u32l 64)),
   .set 34 (u32 .add (.local 26) (.local 32)),
   .set 35 (.cond (u32 .lt (.local 34) (.local 7))
     (.load (.vec .bf16 4) (.offset (.ptrCast (.vec .bf16 4)
       (.offset (.offset (.local 0) (u64 .mul (toU64 (.local 34)) (u64l 5120))) (.local 30))) (.local 33)))
     (.vector .bf16 [bf16l 0x0, bf16l 0x0, bf16l 0x0, bf16l 0x0])),
   stageStore 0, stageStore 1, stageStore 2, stageStore 3]

/-- One 256-position step `base` (slot 30): stage the activations, `runA` (36), the run arrays
(37 … 40: ga, gb, ua, ub), the four runs (at slots 41, 53, 65, 77), the positions. -/
def stepBody (kg ku mt : Nat) : List CStmt :=
  [.barrier 1 false true,
   .set 31 (.local 10),
   .loop (lt 31 (512 * mt)) [.set 31 (u32 .add (.local 31) (u32l 256))] stageBody,
   .barrier 2 false true,
   .set 36 (u32 .add (u32 .div (.local 30) (u32l 32)) (.local 22)),
   .array 37 false 2 (.scalar .u32), .array 38 false 3 (.scalar .u32),
   .array 39 false 4 (.scalar .u32), .array 40 false 5 (.scalar .u32)] ++
  run kg 41 (.local 24) (.local 36) (.local 37) ++
  run kg 53 (.local 24) (u32 .add (.local 36) (u32l 1)) (.local 38) ++
  run ku 65 (.local 25) (.local 36) (.local 39) ++
  run ku 77 (.local 25) (u32 .add (.local 36) (u32l 1)) (.local 40) ++
  [.set 89 (u32l 0),
   .loop (lt 89 32) (incr 89) (positionBody kg ku mt)]

/-- The codebook fill: `codebook[i] = half(trellis_y_f32(i))` (i in slot 13, `trellis_y_f32` at 14). -/
def fillLoop : CStmt :=
  .loop (lt 13 4096) [.set 13 (u32 .add (.local 13) (u32l 256))]
    [.set 14 (.local 13),
     yF32 14,
     .store (.scalar .f16) (.offset (.local 11) (.local 13)) (.conv .f16 (.local 15))]

/-- The outputs of row block `bk` (slot 126): `j` (127), `m` (128), gateT, upT, sigmoidT, siluT
(129 … 132). -/
def outBody : List CStmt :=
  [.set 128 (u32 .add (u32 .add (u32 .add (.local 26) (u32 .mul (u32l 8) (.local 126))) (.local 22)) (.local 127)),
   .ite (u32 .ge (.local 128) (.local 7)) [.continue_] [],
   .set 129 (.conv .bf16 (.bin .mul .f32 0
     (.component (.load (.vec .f32 2) (.offset (.local 27) (.local 126))) (.local 127)) (.local 124))),
   .set 130 (.conv .bf16 (.bin .mul .f32 0
     (.component (.load (.vec .f32 2) (.offset (.local 28) (.local 126))) (.local 127)) (.local 125))),
   .set 131 (.conv .bf16 (.bin .div .f32 0 (f32l 0x3F800000)
     (.bin .add .f32 0 (f32l 0x3F800000) (.un .exp .f32 (.un .neg .f32 (.conv .f32 (.local 129))))))),
   .set 132 (.bin .mul .bf16 0 (.local 129) (.local 131)),
   .store (.scalar .bf16)
     (.offset (.local 6) (u64 .add (u64 .mul (toU64 (.local 128)) (u64l 17408)) (toU64 (.local 23))))
     (.bin .mul .bf16 0 (.local 132) (.local 130))]

/-- Slots: 0 x, 1 x_shape, 2 gcodes, 3 gscales, 4 ucodes, 5 uscales, 6 mid, 7 M, 8 lane, 9 sg, 10 tid,
11 codebook, 12 xs (threadgroup arrays 0, 1), 13 i, 14 … 19 `trellis_y_f32`'s (`yF32`), 20 n0, 21 fm,
22 fn, 23 row, 24 gRow, 25 uRow, 26 mBase, 27 accG, 28 accU (thread arrays 0, 1), 29 bk, 30 base,
31 e, 32 r, 33 c4, 34 m, 35 v, 36 runA, 37 … 40 ga, gb, ua, ub (thread arrays 2 … 5), 41 … 88 the four
`load_run`s (`run`), 89 j, 90 aG, 91 aU (thread arrays 6, 7), 92 … 119 the four `run_state`s
(`state`), 120 bk, 121 b (thread array 8), 122, 123 the collectives' results, 124 gs, 125 us,
126 bk, 127 j, 128 m, 129 gateT, 130 upT, 131 sigmoidT, 132 siluT. -/
def body (kg ku mt : Nat) : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .bf16⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .i32⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .u32⟩)),
   .set 3 (.lit (.ptr ⟨3, 0, .scalar .f16⟩)),
   .set 4 (.lit (.ptr ⟨4, 0, .scalar .u32⟩)),
   .set 5 (.lit (.ptr ⟨5, 0, .scalar .f16⟩)),
   .set 6 (.lit (.ptr ⟨6, 0, .scalar .bf16⟩)),
   .scope
     [.set 7 (.conv .u32 (.load (.scalar .i32) (.offset (.local 1) (i32l 0)))),
      .set 8 (.coord .threadIndexInSimdgroup),
      .set 9 (.coord .simdgroupIndexInThreadgroup),
      .set 10 (u32 .add (u32 .mul (.local 9) (u32l 32)) (.local 8)),
      .array 11 true 0 (.scalar .f16),
      .array 12 true 1 (.scalar .bf16),
      .set 13 (.local 10),
      fillLoop,
      .set 20 (u32 .mul (u32 .add (u32 .mul (.component (.coord .threadgroupPositionInGrid) (u32l 1)) (u32l 8)) (.local 9))
        (u32l 8)),
      .set 21 (u32 .add (u32 .bitAnd (u32 .div (.local 8) (u32l 4)) (u32l 4)) (u32 .rem (u32 .div (.local 8) (u32l 2)) (u32l 4))),
      .set 22 (u32 .add (u32 .mul (u32 .bitAnd (u32 .div (.local 8) (u32l 4)) (u32l 2)) (u32l 2))
        (u32 .mul (u32 .rem (.local 8) (u32l 2)) (u32l 2))),
      .set 23 (u32 .min (u32 .add (.local 20) (.local 21)) (u32l 17407)),
      .set 24 (.offset (.local 2) (u64 .mul (toU64 (.local 23)) (u64l (160 * kg)))),
      .set 25 (.offset (.local 4) (u64 .mul (toU64 (.local 23)) (u64l (160 * ku)))),
      .set 26 (u32 .mul (u32 .mul (.component (.coord .threadgroupPositionInGrid) (u32l 2)) (u32l 8)) (u32l mt)),
      .array 27 false 0 (.vec .f32 2),
      .array 28 false 1 (.vec .f32 2),
      .set 29 (u32l 0),
      .loop (lt 29 mt) (incr 29)
        [.store (.vec .f32 2) (.offset (.local 27) (.local 29)) (.vector .f32 [f32l 0x0, f32l 0x0]),
         .store (.vec .f32 2) (.offset (.local 28) (.local 29)) (.vector .f32 [f32l 0x0, f32l 0x0])],
      .set 30 (u32l 0),
      .loop (lt 30 5120) [.set 30 (u32 .add (.local 30) (u32l 256))] (stepBody kg ku mt),
      .ite (u32 .ge (.local 20) (u32l 17408)) [.leave] [],
      .set 124 (.bin .mul .f32 0 (.conv .f32 (.load (.scalar .f16) (.offset (.local 3) (.local 23)))) (f32l 0x3BDDB447)),
      .set 125 (.bin .mul .f32 0 (.conv .f32 (.load (.scalar .f16) (.offset (.local 5) (.local 23)))) (f32l 0x3BDDB447)),
      .set 126 (u32l 0),
      .loop (lt 126 mt) (incr 126)
        [.set 127 (u32l 0),
         .loop (lt 127 2) (incr 127) outBody]]]

/-- Threadgroup arrays `half codebook[4096]` and `T xs[8·MT][256]`; thread arrays `accG[MT]`,
`accU[MT]`, the run words (`KG + 1` and `KU + 1` each), `aG`, `aU` and `b`. -/
def core (kg ku mt : Nat) : Kernel :=
  ⟨7, [(.scalar .f16, 4096), (.scalar .bf16, 2048 * mt)],
    [(.vec .f32 2, mt), (.vec .f32 2, mt), (.scalar .u32, kg + 1), (.scalar .u32, kg + 1),
     (.scalar .u32, ku + 1), (.scalar .u32, ku + 1), (.vec .f32 2, 1), (.vec .f32 2, 1), (.vec .f32 2, 1)],
    body kg ku mt⟩

section Texts
open Host.Mlx
/-! ## The texts MLX compiles

`x` `bfloat16 [M, 5120]` (any M: its shape is read at run time), `gcodes` `uint32 [17408, 160·KG]`,
`gscales` `float16 [17408]`, `ucodes` `uint32 [17408, 160·KU]`, `uscales` `float16 [17408]`; any
shapes of at least 8 elements give the same text. -/

def inputs (kg ku : Nat) : List Assemble.Input :=
  [⟨chars!"x", .bfloat16, [9, 5120]⟩, ⟨chars!"gcodes", .uint32, [17408, 160 * kg]⟩,
    ⟨chars!"gscales", .float16, [17408]⟩, ⟨chars!"ucodes", .uint32, [17408, 160 * ku]⟩,
    ⟨chars!"uscales", .float16, [17408]⟩]

def args (kg ku mt : Nat) : List Assemble.TemplateArg :=
  [.dtype chars!"T" .bfloat16, .int chars!"R" 17408, .int chars!"C" 5120, .int chars!"BT" 256, .int chars!"KG" kg,
    .int chars!"KU" ku, .int chars!"L" 12, .int chars!"SG_TG" 8, .int chars!"MT" mt]

def assembled (kg ku mt : Nat) : Option (List Char) :=
  Assemble.assemble (PrefillSources.name .gateUpMmaWide) (inputs kg ku) [chars!"mid"] [.bfloat16]
    (PrefillSources.source .gateUpMmaWide) (PrefillSources.header .gateUpMmaWide) (args kg ku mt) false

def text (kg ku mt : Nat) : List Char := (assembled kg ku mt).getD []

/-- Every route instance assembles. -/
theorem assembled_route :
    (assembled 2 2 2).isSome ∧ (assembled 3 3 2).isSome ∧ (assembled 3 2 2).isSome ∧ (assembled 2 3 2).isSome ∧
    (assembled 4 3 2).isSome ∧ (assembled 4 4 2).isSome ∧ (assembled 3 4 2).isSome ∧
    (assembled 2 2 3).isSome ∧ (assembled 3 3 3).isSome ∧ (assembled 3 2 3).isSome ∧ (assembled 2 3 3).isSome ∧
    (assembled 4 3 3).isSome ∧ (assembled 4 4 3).isSome ∧ (assembled 3 4 3).isSome := by
  decide +kernel

kernel_rfl compile_2_2_2 : (frontend (text 2 2 2)).bind elaborate = some (core 2 2 2)
kernel_rfl compile_3_3_2 : (frontend (text 3 3 2)).bind elaborate = some (core 3 3 2)
kernel_rfl compile_3_2_2 : (frontend (text 3 2 2)).bind elaborate = some (core 3 2 2)
kernel_rfl compile_2_3_2 : (frontend (text 2 3 2)).bind elaborate = some (core 2 3 2)
kernel_rfl compile_4_3_2 : (frontend (text 4 3 2)).bind elaborate = some (core 4 3 2)
kernel_rfl compile_4_4_2 : (frontend (text 4 4 2)).bind elaborate = some (core 4 4 2)
kernel_rfl compile_3_4_2 : (frontend (text 3 4 2)).bind elaborate = some (core 3 4 2)
kernel_rfl compile_2_2_3 : (frontend (text 2 2 3)).bind elaborate = some (core 2 2 3)
kernel_rfl compile_3_3_3 : (frontend (text 3 3 3)).bind elaborate = some (core 3 3 3)
kernel_rfl compile_3_2_3 : (frontend (text 3 2 3)).bind elaborate = some (core 3 2 3)
kernel_rfl compile_2_3_3 : (frontend (text 2 3 3)).bind elaborate = some (core 2 3 3)
kernel_rfl compile_4_3_3 : (frontend (text 4 3 3)).bind elaborate = some (core 4 3 3)
kernel_rfl compile_4_4_3 : (frontend (text 4 4 3)).bind elaborate = some (core 4 4 3)
kernel_rfl compile_3_4_3 : (frontend (text 3 4 3)).bind elaborate = some (core 3 4 3)

end Texts
end Metal.Kernels.GateUpMmaWide

set_option linter.constructorNameAsVariable false

namespace Metal.Kernels.MmaWide
open Metal Metal.Core Inference.Contracts.Mlx

/-! ### Thread memory of one thread -/

/-- Thread `th`'s thread array `j` (of 9) at launch-region `9 + th·9 + j`. -/
def ta (th j : Nat) : Nat := 9 + th * 9 + j

/-- Thread `th`'s arrays. -/
def tm (th : Nat) (sh : Shared) (j : Nat) : ByteMemory.Bytes := if j < 9 then sh.bytes (ta th j) else fun _ => 0

theorem tm_lt {th j : Nat} (sh : Shared) (h : j < 9) : tm th sh j = sh.bytes (ta th j) := by simp only [tm, h, ite_true]

/-- Only thread `th`'s arrays may differ. -/
def TFrame (th : Nat) (sh sh' : Shared) : Prop := ∀ ρ, 9 ≤ ρ → (ρ - 9) / 9 ≠ th → sh'.bytes ρ = sh.bytes ρ

/-- Only the arrays of threads `lo … hi - 1` may differ. -/
def SFrame (lo hi : Nat) (sh sh' : Shared) : Prop :=
  ∀ ρ, 9 ≤ ρ → ((ρ - 9) / 9 < lo ∨ hi ≤ (ρ - 9) / 9) → sh'.bytes ρ = sh.bytes ρ

theorem SFrame.refl (lo hi : Nat) (sh : Shared) : SFrame lo hi sh sh := fun _ _ _ => rfl

theorem SFrame.trans_t {lo hi th : Nat} {sh sh' sh'' : Shared} (h : SFrame lo hi sh sh') (ht : TFrame th sh' sh'')
    (hth : lo ≤ th ∧ th < hi) : SFrame lo hi sh sh'' := fun ρ h9 hρ => by
  rw [ht ρ h9 (by omega), h ρ h9 hρ]

theorem SFrame.trans {lo hi lo' hi' : Nat} {sh sh' sh'' : Shared} (h : SFrame lo hi sh sh') (h' : SFrame lo' hi' sh' sh'')
    (hl : lo ≤ lo') (hh : hi' ≤ hi) : SFrame lo hi sh sh'' := fun ρ h9 hρ => by
  rw [h' ρ h9 (by omega), h ρ h9 hρ]

theorem TFrame.refl (th : Nat) (sh : Shared) : TFrame th sh sh := fun _ _ _ => rfl

theorem TFrame.trans {th : Nat} {sh sh' sh'' : Shared} (h : TFrame th sh sh') (h' : TFrame th sh' sh'') :
    TFrame th sh sh'' := fun ρ h9 hρ => by rw [h' ρ h9 hρ, h ρ h9 hρ]

theorem TFrame.tm {th th' : Nat} {sh sh' : Shared} (h : TFrame th sh sh') (hne : th' ≠ th) :
    Metal.Kernels.MmaWide.tm th' sh' = Metal.Kernels.MmaWide.tm th' sh := by
  funext j
  unfold Metal.Kernels.MmaWide.tm
  split
  · exact h _ (by unfold ta; omega) (by unfold ta; rw [show 9 + th' * 9 + j - 9 = j + th' * 9 by omega,
      Nat.add_mul_div_right _ _ (by decide), Nat.div_eq_of_lt (by omega)]; omega)
  · rfl

theorem SFrame.tm {lo hi th : Nat} {sh sh' : Shared} (h : SFrame lo hi sh sh') (hth : th < lo ∨ hi ≤ th) :
    Metal.Kernels.MmaWide.tm th sh' = Metal.Kernels.MmaWide.tm th sh := by
  funext j
  unfold Metal.Kernels.MmaWide.tm
  split
  · exact h _ (by unfold ta; omega) (by unfold ta; rw [show 9 + th * 9 + j - 9 = j + th * 9 by omega,
      Nat.add_mul_div_right _ _ (by decide), Nat.div_eq_of_lt (by omega)]; omega)
  · rfl

/-- A read changes no bytes. -/
theorem TFrame.rdn (th : Nat) (ctx : Ctx) (sh : Shared) (reg o n : Nat) : TFrame th sh (rdn ctx sh reg o n) :=
  fun _ _ _ => rfl

/-- A write below the thread arrays. -/
theorem TFrame.wrn (th : Nat) (ctx : Ctx) (sh : Shared) {reg : Nat} (o n : Nat) (bs : List (BitVec 8)) (h : reg < 9) :
    TFrame th sh (wrn ctx sh reg o n bs) := fun ρ h9 _ => wrn_other _ _ _ _ _ (by omega)

/-- A write to one of thread `th`'s arrays. -/
theorem TFrame.tput (th j : Nat) (sh : Shared) (o : Nat) (bs : List (BitVec 8)) (hj : j < 9) :
    TFrame th sh (Metal.tput sh (ta th j) o bs) := fun ρ _ hρ => tput_other _ _ _ (by
  intro h; apply hρ; rw [h]; unfold ta
  rw [show 9 + th * 9 + j - 9 = j + th * 9 by omega, Nat.add_mul_div_right _ _ (by decide), Nat.div_eq_of_lt hj]; omega)

/-! ### SIMD-group sweeps -/

section Sweep
variable (C : M1Max.Contract)

/-- A SIMD-group's lanes `T0 + i` run in order to a collective, each changing only its own thread arrays: an
invariant `M` at the lane index, each lane's own facts before (`O`) and after (`O'`), the arrays of the other
threads unchanged. -/
theorem sweep_collective_ev (r : Nat) (T : Fin 32 → Thread) (site slot : Nat) (op : Collective) (s : Scalar) (d : Nat)
    (x y : Fin 32 → Val) (hres : resolve C op s d (List.ofFn x) = some (List.ofFn y)) (T0 : Nat) (sh₀ : Shared)
    (M : Nat → Shared → Prop) (O O' : Fin 32 → (Nat → ByteMemory.Bytes) → Prop) (P : Fin 32 → Thread → Prop)
    (J : Shared → Prop) (R : Fin 32 → Thread → Prop)
    (hlane : ∀ (i : Fin 32) sh, M i sh → O i (tm (T0 + i) sh) → ∃ t sh',
      (Ev fun m => (runThread C m (T i)).run sh = some (t, sh')) ∧ M (i + 1) sh' ∧ TFrame (T0 + i) sh sh' ∧
      O' i (tm (T0 + i) sh') ∧ t.status = .collective site slot op s (x i) d ∧ P i t)
    (hnext : ∀ (U : Fin 32 → Thread) sh, (∀ i, P i (U i)) → M 32 sh → (∀ i, O' i (tm (T0 + i) sh)) →
      SFrame T0 (T0 + 32) sh₀ sh → ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m r (List.ofFn fun i => { U i with status := .running }.set slot (y i))).run sh =
        some (List.ofFn V, sh')) ∧ J sh' ∧ ∀ i, R i (V i))
    (sh : Shared) (hM : M 0 sh) (hO : ∀ i, O i (tm (T0 + i) sh)) (hF : SFrame T0 (T0 + 32) sh₀ sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared), (Ev fun m => (runSimd C m (r + 1) (List.ofFn T)).run sh = some (List.ofFn V, sh')) ∧
      J sh' ∧ ∀ i, R i (V i) := by
  refine runSimd_collective_ev C r T site slot op s d x y hres
    (fun idx sh => M idx sh ∧ SFrame T0 (T0 + 32) sh₀ sh ∧ (∀ i : Fin 32, i.val < idx → O' i (tm (T0 + i) sh)) ∧
      (∀ i : Fin 32, idx ≤ i.val → O i (tm (T0 + i) sh)))
    P J R (fun i sh hI => ?_) (fun U sh hU hI => hnext U sh hU hI.1 (fun i => hI.2.2.1 i i.isLt) hI.2.1) sh
    ⟨hM, hF, fun i h => absurd h (by omega), fun i _ => hO i⟩
  obtain ⟨hMi, hFi, hO'i, hOi⟩ := hI
  obtain ⟨t, sh', hev, hM', hTF, hO', hst, hP⟩ := hlane i sh hMi (hOi i (le_refl _))
  refine ⟨t, sh', hev, ⟨hM', hFi.trans_t hTF ⟨by omega, by omega⟩, fun i' hi' => ?_, fun i' hi' => ?_⟩, hst, hP⟩
  · by_cases hii : i' = i
    · subst hii; exact hO'
    · rw [hTF.tm (by intro h; apply hii; ext; omega)]
      exact hO'i i' (by have := Fin.val_ne_of_ne hii; omega)
  · rw [hTF.tm (by omega)]; exact hOi i' (by omega)

/-- `sweep_collective_ev` for a last round: every lane to a barrier or the end. -/
theorem sweep_blocked_ev (r : Nat) (T : Fin 32 → Thread) (T0 : Nat) (sh₀ : Shared) (M : Nat → Shared → Prop)
    (O O' : Fin 32 → (Nat → ByteMemory.Bytes) → Prop) (R : Fin 32 → Thread → Prop)
    (hlane : ∀ (i : Fin 32) sh, M i sh → O i (tm (T0 + i) sh) → ∃ t sh',
      (Ev fun m => (runThread C m (T i)).run sh = some (t, sh')) ∧ M (i + 1) sh' ∧ TFrame (T0 + i) sh sh' ∧
      O' i (tm (T0 + i) sh') ∧ blocked t.status = true ∧ R i t)
    (sh : Shared) (hM : M 0 sh) (hO : ∀ i, O i (tm (T0 + i) sh)) (hF : SFrame T0 (T0 + 32) sh₀ sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared), (Ev fun m => (runSimd C m (r + 1) (List.ofFn T)).run sh = some (List.ofFn V, sh')) ∧
      M 32 sh' ∧ (∀ i, O' i (tm (T0 + i) sh')) ∧ SFrame T0 (T0 + 32) sh₀ sh' ∧ ∀ i, R i (V i) := by
  obtain ⟨V, sh', hr, hI, hR⟩ := runSimd_blocked_ev C r T
    (fun idx sh => M idx sh ∧ SFrame T0 (T0 + 32) sh₀ sh ∧ (∀ i : Fin 32, i.val < idx → O' i (tm (T0 + i) sh)) ∧
      (∀ i : Fin 32, idx ≤ i.val → O i (tm (T0 + i) sh))) R (fun i sh hI => by
      obtain ⟨hMi, hFi, hO'i, hOi⟩ := hI
      obtain ⟨t, sh', hev, hM', hTF, hO', hst, hP⟩ := hlane i sh hMi (hOi i (le_refl _))
      refine ⟨t, sh', hev, ⟨hM', hFi.trans_t hTF ⟨by omega, by omega⟩, fun i' hi' => ?_, fun i' hi' => ?_⟩, hst, hP⟩
      · by_cases hii : i' = i
        · subst hii; exact hO'
        · rw [hTF.tm (by intro h; apply hii; ext; omega)]
          exact hO'i i' (by have := Fin.val_ne_of_ne hii; omega)
      · rw [hTF.tm (by omega)]; exact hOi i' (by omega)) sh
    ⟨hM, hF, fun i h => absurd h (by omega), fun i _ => hO i⟩
  exact ⟨V, sh', hr, hI.1, fun i => hI.2.2.1 i i.isLt, hI.2.1, hR⟩

end Sweep

end Metal.Kernels.MmaWide

namespace Metal.Kernels.GateUpMmaWide
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis

/-! ## Expected outputs

The source's quantities on the inputs' elements, with the operations the core applies. The core has no
contraction site. `simdgroup_multiply_accumulate` is the contract's `simdMma` on the lanes' registers
(`thread_elements()`), with no layout assumed: the accumulators are stated lane by lane, as the code
moves them. -/

section Spec
variable (C : M1Max.Contract)

def zero : Float32 := Val.ofF32Bits 0
def one : Float32 := Val.ofF32Bits 0x3F800000
def bzero : BF := Val.ofBf16Bits 0
/-- `TRELLIS_RCP`, `1.0f / 147.800537109375f` (folded to the word `0x3BDDB447`). -/
def rcp : Float32 := Val.ofF32Bits 0x3BDDB447

/-- `trellis_y_f32(s)`: the float of word `0x4b000000 | (trellis_y(s) + 510)`, less `8389118.0f`. -/
def trellisF32 (s : Nat) : Float32 :=
  C.fadd (Val.ofF32Bits (0x4B000000 ||| (trellisYv s + 510).toNat)) (f32Neg (Val.ofF32Bits 0x4B0001FE))

/-- `codebook[s] = half(trellis_y_f32(s))`. -/
def cbv (s : Nat) : Float16.Value := C.narrowHalf (trellisF32 C s)

/-- A lane's `fm` and `fn`. -/
def fmOf (lane : Nat) : Nat := (lane / 4 &&& 4) + lane / 2 % 4
def fnOf (lane : Nat) : Nat := (lane / 4 &&& 2) * 2 + lane % 2 * 2

/-- `float(codebook[…])` for row `row`, column `col` of `K`-bit codes: the codebook entry of the column's
12-bit trellis state in its block (block `col / 256` of the row, from word `(20·row + col / 256)·8·K`). -/
def weight (K : Nat) (Codes : ByteMemory.Bytes) (row col : Nat) : Float32 :=
  Float16.widen (cbv C (trellisCode K Codes ((20 * row + col / 256) * (8 * K)) (col % 256)))

/-- `aG`/`aU`'s `thread_elements()[e]` of lane `i` at position `n` (256-step `n / 32`, `j = n % 32`) of the
SIMD-group of output rows `8·g8 …`: row `8·g8 + fm`, run `8·(n / 32) + fn + e`, column `32·run + j`. -/
def aReg (K : Nat) (Codes : ByteMemory.Bytes) (g8 n : Nat) (i : Fin 32) (e : Fin 2) : Float32 :=
  weight C K Codes (8 * g8 + fmOf i) (256 * (n / 32) + 32 * (fnOf i + e) + n % 32)

/-- `x[m][c]`, and the staged `xs` (rows from `M` on zero). -/
def xel (X : ByteMemory.Bytes) (m c : Nat) : BF := Val.ofBf16Bits (half X (5120 * m + c))
def xsv (r : Nat) (X : ByteMemory.Bytes) (m c : Nat) : BF := if m < r then xel X m c else bzero

/-- `b`'s `thread_elements()[e]` of lane `i` at position `n` for the 8 rows `8·β …`:
`float(xs[8·bk + fn + e][32·fm + j])`, row `8·β + fn + e` of `x`, column `256·(n / 32) + 32·fm + j`. -/
def bReg (r : Nat) (X : ByteMemory.Bytes) (β n : Nat) (i : Fin 32) (e : Fin 2) : Float32 :=
  C.widen (xsv r X (8 * β + fnOf i + e) (256 * (n / 32) + 32 * fmOf i + n % 32))

/-- An accumulator after `n` positions: `simdgroup_multiply_accumulate(acc, a, b, acc)` from zero. -/
def acc (A B : Nat → Fin 32 → Fin 2 → Float32) : Nat → Fin 32 → Fin 2 → Float32
  | 0 => fun _ _ => zero
  | n + 1 => C.simdMma (A n) (B n) (acc A B n)

/-- `gs`, `us`: `float(scales[row]) * TRELLIS_RCP`. -/
def sc (S : ByteMemory.Bytes) (row : Nat) : Float32 := C.fmul (scale S row) rcp

/-- `mid` from a lane's accumulator elements: `gateT`, `upT`, `sigmoidT`, `siluT`, their product. -/
def act (gate up gs us : Float32) : BF :=
  let gateT := C.narrow (C.fmul gate gs)
  let upT := C.narrow (C.fmul up us)
  let sigmoidT := C.narrow (C.fdiv one (C.fadd one (C.exp (f32Neg (C.widen gateT)))))
  C.bfmul (C.bfmul gateT sigmoidT) upT

/-- The lane with `fm = a` and `fn = c - c % 2` (`a, c < 8`). -/
def laneOf (a c : Nat) : Nat := c / 2 % 2 + 2 * (a % 2) + 4 * (a / 2 % 2) + 8 * (c / 4) + 16 * (a / 4)

/-- Lane `n % 32`, element `n % 2`. -/
def lane32 (n : Nat) : Fin 32 := ⟨n % 32, Nat.mod_lt _ (by decide)⟩
def el2 (n : Nat) : Fin 2 := ⟨n % 2, Nat.mod_lt _ (by decide)⟩

/-- `mid[m][row]`: written by the lane with `fm = row % 8`, `fn + j = m % 8` of the SIMD-group of rows
`8·(row / 8) …`, from its elements `j = m % 2` of the gate and up accumulators of the 8 rows `8·(m / 8) …`
after the 640 positions (20 steps of 256 columns, 32 positions each). -/
def midv (kg ku r : Nat) (X Gc Gs Uc Us : ByteMemory.Bytes) (m row : Nat) : BF :=
  act C (acc C (aReg C kg Gc (row / 8)) (bReg C r X (m / 8)) 640 (lane32 (laneOf (row % 8) (m % 8))) (el2 m))
    (acc C (aReg C ku Uc (row / 8)) (bReg C r X (m / 8)) 640 (lane32 (laneOf (row % 8) (m % 8))) (el2 m))
    (sc C Gs row) (sc C Us row)

/-- Byte `b` of `mid` `[r, 17408]` bf16. -/
def expected (kg ku r : Nat) (X Gc Gs Uc Us : ByteMemory.Bytes) (b : Nat) : BitVec 8 :=
  if b < 34816 * r then
    (wordBytes 2 (Val.bf16Bits (midv C kg ku r X Gc Gs Uc Us (b / 2 / 17408) (b / 2 % 17408)))).getD (b % 2) 0
  else 0

end Spec

/-- `x_shape`: the int32 words of `x`'s shape `[r, 5120]`. -/
def shapeBytes (r : Nat) : ByteMemory.Bytes := fun b => (wordBytes 4 r ++ wordBytes 4 5120).getD b 0

/-- `rowBlocks` (gate-up-mma-wide.ts:123): `MT = 3` iff `⌈r/8⌉ = 3`, else 2. -/
def rowBlocks (r : Nat) : Nat := if ceilDiv r 8 = 3 then 3 else 2

end Metal.Kernels.GateUpMmaWide

namespace Metal.Kernels.MmaWide
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis Metal.Kernels.GateUpMmaWide

/-! ## The launch -/

/-- The inputs: `x`, the gate codes and scales, the up codes and scales, the row count, the base alignments. -/
structure In where
  X : ByteMemory.Bytes
  Gc : ByteMemory.Bytes
  Gs : ByteMemory.Bytes
  Uc : ByteMemory.Bytes
  Us : ByteMemory.Bytes
  r : Nat
  ax : Nat
  ash : Nat
  ag : Nat
  as : Nat
  au : Nat
  aus : Nat

/-- Threadgroups along z: `⌈r / (8·MT)⌉`. -/
def gz (r mt : Nat) : Nat := ceilDiv r (8 * mt)

def bufs (kg ku : Nat) (I : In) : List Buffer :=
  [⟨.device, 10240 * I.r, I.ax, I.X⟩, ⟨.constant, 8, I.ash, shapeBytes I.r⟩, ⟨.device, GateUp.codesBytes kg, I.ag, I.Gc⟩,
    ⟨.device, 34816, I.as, I.Gs⟩, ⟨.device, GateUp.codesBytes ku, I.au, I.Uc⟩, ⟨.device, 34816, I.aus, I.Us⟩]

def launch (kg ku mt : Nat) (I : In) (initial : Nat → ByteMemory.Bytes) : Launch :=
  ⟨core kg ku mt, (256, 272, gz I.r mt), (256, 1, 1), buffers (bufs kg ku I) [34816 * I.r] 16 initial⟩

/-- `mid[idx]`'s writer: threadgroup `(row / 64, m / (8·MT))`, SIMD-group `row / 8 % 8`, lane `laneOf`. -/
def wGroup (mt idx : Nat) : Nat := idx % 17408 / 64 + 272 * (idx / 17408 / 8 / mt)
def wThread (mt idx : Nat) : Nat :=
  wGroup mt idx * 256 + (32 * (idx % 17408 / 8 % 8) + laneOf (idx % 17408 % 8) (idx / 17408 % 8))

def dev (mt : Nat) (region byte : Nat) : Option Writer :=
  if region = 6 then some ⟨wThread mt (byte / 2), wGroup mt (byte / 2), 0⟩ else none

/-- Threadgroup `g` passes 40 barriers, so it starts at epoch `40·g`: `codebook[e]` is thread `e % 256`'s in its
first epoch, `xs` element `q` thread `q / 4 % 256`'s in each staging epoch (odd), nothing written otherwise. -/
def tgo (g e region byte : Nat) : Option Nat :=
  if region = 7 then (if e = 40 * g then some (g * 256 + byte / 2 % 256) else none)
  else if region = 8 then (if 40 * g < e ∧ (e - 40 * g) % 2 = 1 then some (g * 256 + byte / 8 % 256) else none)
  else none

/-- The regions as the kernel uses them. -/
structure Shape (L : Launch) (kg ku mt : Nat) (I : In) : Prop where
  r0 : L.regions 0 = some ⟨.device, 10240 * I.r, I.ax⟩
  r1 : L.regions 1 = some ⟨.constant, 8, I.ash⟩
  r2 : L.regions 2 = some ⟨.device, GateUp.codesBytes kg, I.ag⟩
  r3 : L.regions 3 = some ⟨.device, 34816, I.as⟩
  r4 : L.regions 4 = some ⟨.device, GateUp.codesBytes ku, I.au⟩
  r5 : L.regions 5 = some ⟨.device, 34816, I.aus⟩
  r6 : L.regions 6 = some ⟨.device, 34816 * I.r, 16⟩
  r7 : L.regions 7 = some ⟨.threadgroup, 8192, 2⟩
  r8 : L.regions 8 = some ⟨.threadgroup, 4096 * mt, 2⟩
  t0 : ∀ th, L.regions (ta th 0) = some ⟨.thread, 8 * mt, 8⟩
  t1 : ∀ th, L.regions (ta th 1) = some ⟨.thread, 8 * mt, 8⟩
  t2 : ∀ th, L.regions (ta th 2) = some ⟨.thread, 4 * (kg + 1), 4⟩
  t3 : ∀ th, L.regions (ta th 3) = some ⟨.thread, 4 * (kg + 1), 4⟩
  t4 : ∀ th, L.regions (ta th 4) = some ⟨.thread, 4 * (ku + 1), 4⟩
  t5 : ∀ th, L.regions (ta th 5) = some ⟨.thread, 4 * (ku + 1), 4⟩
  t6 : ∀ th, L.regions (ta th 6) = some ⟨.thread, 8, 8⟩
  t7 : ∀ th, L.regions (ta th 7) = some ⟨.thread, 8, 8⟩
  t8 : ∀ th, L.regions (ta th 8) = some ⟨.thread, 8, 8⟩
  ax : I.ax % 8 = 0
  ash : I.ash % 4 = 0
  ag : I.ag % 4 = 0
  as : I.as % 2 = 0
  au : I.au % 4 = 0
  aus : I.aus % 2 = 0

theorem launch_shape {kg ku mt : Nat} {I : In} {initial : Nat → ByteMemory.Bytes} (hax : I.ax % 8 = 0)
    (hash : I.ash % 4 = 0) (hag : I.ag % 4 = 0) (has : I.as % 2 = 0) (hau : I.au % 4 = 0) (haus : I.aus % 2 = 0) :
    Shape (launch kg ku mt I initial) kg ku mt I := by
  have hb : (launch kg ku mt I initial).buffers = buffers (bufs kg ku I) [34816 * I.r] 16 initial := rfl
  have ht : ∀ th j t n, (launch kg ku mt I initial).kernel.threadArrays[j]? = some (t, n) →
      (launch kg ku mt I initial).regions (ta th j) = some ⟨.thread, t.bytes * n, alignment t⟩ :=
    fun th j t n h => Launch.regions_threadArray _ th j t n h
  refine ⟨regions_input hb 0 (by simp [bufs]), regions_input hb 1 (by simp [bufs]),
    regions_input hb 2 (by simp [bufs]), regions_input hb 3 (by simp [bufs]), regions_input hb 4 (by simp [bufs]),
    regions_input hb 5 (by simp [bufs]), regions_output hb 0 (by simp),
    Launch.regions_groupArray _ 0 (.scalar .f16) 4096 rfl, ?_, fun th => ?_, fun th => ?_, fun th => ?_,
    fun th => ?_, fun th => ?_, fun th => ?_, fun th => ?_, fun th => ?_, fun th => ?_, hax, hash, hag, has, hau, haus⟩
  · have := Launch.regions_groupArray (launch kg ku mt I initial) 1 (.scalar .bf16) (2048 * mt) rfl
    rw [show (launch kg ku mt I initial).buffers.length = 7 from rfl] at this
    rw [this, show (Ty.scalar .bf16).bytes * (2048 * mt) = 4096 * mt by simp only [Ty.bytes, Scalar.bytes]; ring]; rfl
  · have := ht th 0 (.vec .f32 2) mt rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 1 (.vec .f32 2) mt rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 2 (.scalar .u32) (kg + 1) rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 3 (.scalar .u32) (kg + 1) rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 4 (.scalar .u32) (ku + 1) rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 5 (.scalar .u32) (ku + 1) rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 6 (.vec .f32 2) 1 rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 7 (.vec .f32 2) 1 rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this
  · have := ht th 8 (.vec .f32 2) 1 rfl; simpa [Ty.bytes, Scalar.bytes, alignment] using this

/-! ## Memory -/

/-- The staged bytes of `xs` element `q` (row `q / 256`, column `q % 256`) for rows from `mb`, columns from
`base`: `x`'s bytes, or zero past row `r`. -/
def stg (X : ByteMemory.Bytes) (r mb base q : Nat) : List (BitVec 8) :=
  if mb + q / 256 < r then cells X (2 * (5120 * (mb + q / 256) + base + q % 256)) 2 else [0, 0]

section Memory
variable (C : M1Max.Contract)

/-- Memory during the launch: inputs intact, the epochs (`ge` the threadgroup epoch), the codebook entries
with `cbOk`, the `xs` elements with `xsOk` staged for rows from `mb` and columns from `base`, the `mid`
elements with `W` written as `out`, and every access so far keeping the ownership discipline. -/
structure Mem (L : Launch) (I : In) (mt : Nat) (out : Nat → BF) (W : Nat → Prop) (ge : Nat) (cbOk : Nat → Prop)
    (mb base : Nat) (xsOk : Nat → Prop) (sh : Shared) : Prop where
  regions : sh.regions = L.regions
  x : sh.bytes 0 = I.X
  xsh : sh.bytes 1 = shapeBytes I.r
  gc : sh.bytes 2 = I.Gc
  gs : sh.bytes 3 = I.Gs
  uc : sh.bytes 4 = I.Uc
  us : sh.bytes 5 = I.Us
  deve : sh.deviceEpoch = 0
  grpe : sh.groupEpoch = ge
  cb : ∀ e < 4096, cbOk e → cells (sh.bytes 7) (2 * e) 2 = wordBytes 2 (Val.f16Bits (cbv C e))
  xs : ∀ q < 2048 * mt, xsOk q → cells (sh.bytes 8) (2 * q) 2 = stg I.X I.r mb base q
  mid : ∀ idx < 17408 * I.r, W idx → cells (sh.bytes 6) (2 * idx) 2 = wordBytes 2 (Val.bf16Bits (out idx))
  log : ∀ a ∈ sh.log, Owned L (dev mt) tgo a

variable {C} {L : Launch} {I : In} {mt : Nat} {out : Nat → BF} {W : Nat → Prop} {ge : Nat} {cbOk : Nat → Prop}
  {mb base : Nat} {xsOk : Nat → Prop} {sh : Shared}

theorem Mem.mono (h : Mem C L I mt out W ge cbOk mb base xsOk sh) {W' cbOk' xsOk' : Nat → Prop}
    (hw : ∀ idx < 17408 * I.r, W' idx → W idx) (hc : ∀ e < 4096, cbOk' e → cbOk e)
    (hx : ∀ q < 2048 * mt, xsOk' q → xsOk q) : Mem C L I mt out W' ge cbOk' mb base xsOk' sh :=
  ⟨h.regions, h.x, h.xsh, h.gc, h.gs, h.uc, h.us, h.deve, h.grpe, fun e he hc' => h.cb e he (hc e he hc'),
    fun q hq hx' => h.xs q hq (hx q hq hx'), fun idx hi hw' => h.mid idx hi (hw idx hi hw'), h.log⟩

/-- A new staging: nothing staged yet. -/
theorem Mem.restage (h : Mem C L I mt out W ge cbOk mb base xsOk sh) (mb' base' : Nat) :
    Mem C L I mt out W ge cbOk mb' base' (fun _ => False) sh :=
  ⟨h.regions, h.x, h.xsh, h.gc, h.gs, h.uc, h.us, h.deve, h.grpe, h.cb, fun _ _ hf => hf.elim, h.mid, h.log⟩

/-- A read of an input. -/
theorem Mem.rd (h : Mem C L I mt out W ge cbOk mb base xsOk sh) (hS : Shape L kg ku mt I) (ctx : Ctx) (reg o n : Nat)
    (hreg : reg ≤ 5) : Mem C L I mt out W ge cbOk mb base xsOk (rdn ctx sh reg o n) :=
  ⟨h.regions, h.x, h.xsh, h.gc, h.gs, h.uc, h.us, h.deve, h.grpe, h.cb, h.xs, h.mid, forall_log _ n _ (fun j _ => by
    obtain ⟨r, hr, hs⟩ : ∃ r, L.regions reg = some r ∧ r.space ≠ .threadgroup := by
      rcases (show reg = 0 ∨ reg = 1 ∨ reg = 2 ∨ reg = 3 ∨ reg = 4 ∨ reg = 5 by omega) with
        rfl | rfl | rfl | rfl | rfl | rfl
      exacts [⟨_, hS.r0, by simp⟩, ⟨_, hS.r1, by simp⟩, ⟨_, hS.r2, by simp⟩, ⟨_, hS.r3, by simp⟩,
        ⟨_, hS.r4, by simp⟩, ⟨_, hS.r5, by simp⟩]
    exact owned_device_read L (dev mt) tgo ctx sh reg (o + j) r hr hs (by simp [dev]; omega)) h.log⟩

/-- A read of threadgroup memory nobody owns in the current epoch. -/
theorem Mem.rdg (h : Mem C L I mt out W ge cbOk mb base xsOk sh) (hS : Shape L kg ku mt I) (ctx : Ctx) (reg o n : Nat)
    (hreg : reg = 7 ∨ reg = 8) (hno : ∀ j < n, tgo ctx.group ge reg (o + j) = none) :
    Mem C L I mt out W ge cbOk mb base xsOk (rdn ctx sh reg o n) :=
  ⟨h.regions, h.x, h.xsh, h.gc, h.gs, h.uc, h.us, h.deve, h.grpe, h.cb, h.xs, h.mid, forall_log _ n _ (fun j hj => by
    rcases hreg with rfl | rfl
    · exact owned_group_read L (dev mt) tgo ctx sh 7 (o + j) _ hS.r7 rfl (by rw [h.grpe]; exact hno j hj)
    · exact owned_group_read L (dev mt) tgo ctx sh 8 (o + j) _ hS.r8 rfl (by rw [h.grpe]; exact hno j hj)) h.log⟩

/-- A write to thread memory. -/
theorem Mem.tput (h : Mem C L I mt out W ge cbOk mb base xsOk sh) {reg : Nat} (o : Nat) (bs : List (BitVec 8))
    (hreg : 9 ≤ reg) : Mem C L I mt out W ge cbOk mb base xsOk (Metal.tput sh reg o bs) :=
  ⟨h.regions, by rw [tput_other _ _ _ (by omega)]; exact h.x, by rw [tput_other _ _ _ (by omega)]; exact h.xsh,
    by rw [tput_other _ _ _ (by omega)]; exact h.gc, by rw [tput_other _ _ _ (by omega)]; exact h.gs,
    by rw [tput_other _ _ _ (by omega)]; exact h.uc, by rw [tput_other _ _ _ (by omega)]; exact h.us, h.deve, h.grpe,
    fun e he hc => by rw [tput_other _ _ _ (by omega)]; exact h.cb e he hc,
    fun q hq hx => by rw [tput_other _ _ _ (by omega)]; exact h.xs q hq hx,
    fun idx hi hw => by rw [tput_other _ _ _ (by omega)]; exact h.mid idx hi hw, h.log⟩

/-- Thread `e % 256` of threadgroup `g` writes `codebook[e]` in the threadgroup's first epoch. -/
theorem Mem.wcb {g : Nat} (h : Mem C L I mt out W (40 * g) cbOk mb base xsOk sh) (hS : Shape L kg ku mt I) (ctx : Ctx)
    (e : Nat) (he : e < 4096) (ht : ctx.thread = g * 256 + e % 256) (hg : ctx.group = g) :
    Mem C L I mt out W (40 * g) (fun e' => cbOk e' ∨ e' = e) mb base xsOk
      (wrn ctx sh 7 (2 * e) 2 (wordBytes 2 (Val.f16Bits (cbv C e)))) := by
  have hl : (wordBytes 2 (Val.f16Bits (cbv C e))).length = 2 := wordBytes_length 2 _
  refine ⟨h.regions, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.x, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.xsh,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.gc, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.gs,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.uc, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.us, h.deve,
    h.grpe, fun e' he' hc => ?_, fun q hq hx => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.xs q hq hx,
    fun idx hi hw => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.mid idx hi hw,
    forall_log _ 2 _ (fun j hj => owned_group L (dev mt) tgo ctx sh 7 (2 * e + j) _ hS.r7 true rfl
      (by simp only [tgo, h.grpe, hg, ite_true]; rw [ht]; congr 2; omega)) h.log⟩
  rw [wrn_same]
  by_cases hee : e' = e
  · subst hee
    have := cells_writeBytes_same (sh.bytes 7) (2 * e') (wordBytes 2 (Val.f16Bits (cbv C e')))
    rwa [hl] at this
  · rw [cells_writeBytes_other _ _ _ _ _ (by rw [hl]; omega)]
    exact h.cb e' he' (hc.resolve_right hee)

/-- Thread `q / 4 % 256` of threadgroup `g` writes `xs` element `q` in a staging epoch. -/
theorem Mem.wxs {g : Nat} (h : Mem C L I mt out W ge cbOk mb base xsOk sh) (hS : Shape L kg ku mt I) (ctx : Ctx)
    (q : Nat) (hq : q < 2048 * mt) (hge : 40 * g < ge ∧ (ge - 40 * g) % 2 = 1)
    (ht : ctx.thread = g * 256 + q / 4 % 256) (hg : ctx.group = g) :
    Mem C L I mt out W ge cbOk mb base (fun q' => xsOk q' ∨ q' = q)
      (wrn ctx sh 8 (2 * q) 2 (stg I.X I.r mb base q)) := by
  have hl : (stg I.X I.r mb base q).length = 2 := by unfold stg; split <;> simp [cells_length]
  refine ⟨h.regions, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.x, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.xsh,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.gc, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.gs,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.uc, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.us, h.deve,
    h.grpe, fun e he hc => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.cb e he hc, fun q' hq' hx => ?_,
    fun idx hi hw => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.mid idx hi hw,
    forall_log _ 2 _ (fun j hj => owned_group L (dev mt) tgo ctx sh 8 (2 * q + j) _ hS.r8 true rfl
      (by
        simp only [tgo, h.grpe, hg, show (8 : Nat) ≠ 7 by decide, ite_false, ite_true, hge.1, hge.2, and_self]
        rw [ht]; congr 2; omega)) h.log⟩
  rw [wrn_same]
  by_cases hqq : q' = q
  · subst hqq
    have := cells_writeBytes_same (sh.bytes 8) (2 * q') (stg I.X I.r mb base q')
    rwa [hl] at this
  · rw [cells_writeBytes_other _ _ _ _ _ (by rw [hl]; omega)]
    exact h.xs q' hq' (hx.resolve_right hqq)

/-- `mid[idx]`'s writer writes it. -/
theorem Mem.wmid (h : Mem C L I mt out W ge cbOk mb base xsOk sh) (hS : Shape L kg ku mt I) (ctx : Ctx) (idx : Nat)
    (hi : idx < 17408 * I.r) (ht : ctx.thread = wThread mt idx) (hg : ctx.group = wGroup mt idx) :
    Mem C L I mt out (fun idx' => W idx' ∨ idx' = idx) ge cbOk mb base xsOk
      (wrn ctx sh 6 (2 * idx) 2 (wordBytes 2 (Val.bf16Bits (out idx)))) := by
  have hl : (wordBytes 2 (Val.bf16Bits (out idx))).length = 2 := wordBytes_length 2 _
  refine ⟨h.regions, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.x, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.xsh,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.gc, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.gs,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.uc, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.us, h.deve,
    h.grpe, fun e he hc => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.cb e he hc,
    fun q hq hx => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.xs q hq hx, fun idx' hi' hw => ?_,
    forall_log _ 2 _ (fun j hj => owned_device L (dev mt) tgo ctx sh 6 (2 * idx + j) _ hS.r6 true (by simp)
      ⟨wThread mt ((2 * idx + j) / 2), wGroup mt ((2 * idx + j) / 2), 0⟩ (by simp [dev])
      (by rw [ht, show (2 * idx + j) / 2 = idx by omega]) (by rw [hg, show (2 * idx + j) / 2 = idx by omega])
      (by rw [h.deve])) h.log⟩
  rw [wrn_same]
  by_cases hii : idx' = idx
  · subst hii
    have := cells_writeBytes_same (sh.bytes 6) (2 * idx') (wordBytes 2 (Val.bf16Bits (out idx')))
    rwa [hl] at this
  · rw [cells_writeBytes_other _ _ _ _ _ (by rw [hl]; omega)]
    exact h.mid idx' hi' (hw.resolve_right hii)

/-- A barrier (threadgroup memory only). -/
theorem Mem.pass (h : Mem C L I mt out W ge cbOk mb base xsOk sh) :
    Mem C L I mt out W (ge + 1) cbOk mb base xsOk (pass false true sh) :=
  ⟨h.regions, h.x, h.xsh, h.gc, h.gs, h.uc, h.us, by simp [Metal.pass, h.deve], by simp [Metal.pass, h.grpe], h.cb,
    h.xs, h.mid, h.log⟩

/-- A threadgroup starts: its threadgroup arrays hold garbage. -/
theorem Mem.reset (h : Mem C L I mt out W ge cbOk mb base xsOk sh) (hb : L.buffers.length = 7) (garbage : Garbage)
    (g : Nat) : Mem C L I mt out W ge (fun _ => False) mb base (fun _ => False)
      { sh with bytes := L.resetGroup garbage g sh.bytes } :=
  ⟨h.regions,
    by show L.resetGroup garbage g sh.bytes 0 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.x,
    by show L.resetGroup garbage g sh.bytes 1 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.xsh,
    by show L.resetGroup garbage g sh.bytes 2 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.gc,
    by show L.resetGroup garbage g sh.bytes 3 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.gs,
    by show L.resetGroup garbage g sh.bytes 4 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.uc,
    by show L.resetGroup garbage g sh.bytes 5 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.us,
    h.deve, h.grpe, fun _ _ hf => hf.elim, fun _ _ hf => hf.elim,
    fun idx hi hw => by
      show cells (L.resetGroup garbage g sh.bytes 6) (2 * idx) 2 = _
      rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.mid idx hi hw,
    h.log⟩

end Memory

/-! ## Running the header functions -/

/-- Disjoint bits: a value below `2^t` or'ed with a multiple of `2^t`. -/
theorem or_split {x c t : Nat} (hx : x < 2 ^ t) : x ||| c * 2 ^ t = x + c * 2 ^ t := by
  rw [Nat.lor_comm, ← Nat.shiftLeft_eq, ← Nat.shiftLeft_add_eq_or_of_lt hx, Nat.shiftLeft_eq, Nat.add_comm]

/-- `run_state`'s window: bits `bb … bb + 11` of the words, from word `bb / 32` (and the next one when the
window crosses it). -/
theorem state_bits {W : Nat → Nat} {n bb : Nat} (hW : ∀ i < n, W i < 2 ^ 32) (hwi : bb / 32 < n)
    (hwi1 : 32 < bb % 32 + 12 → bb / 32 + 1 < n) :
    (if 32 < bb % 32 + 12 then W (bb / 32) / 2 ^ (bb % 32) ||| W (bb / 32 + 1) * 2 ^ (32 - bb % 32) % 2 ^ 32
      else W (bb / 32) / 2 ^ (bb % 32)) % 2 ^ 12 = runBits W n / 2 ^ bb % 2 ^ 12 := by
  have hoff : bb % 32 < 32 := Nat.mod_lt _ (by decide)
  have hbb : bb = 32 * (bb / 32) + bb % 32 := (Nat.div_add_mod bb 32).symm
  have hsplit := runBits_split hW hwi
  have hword := fun (h : bb / 32 + 1 < n) => runBits_word hW (bb / 32 + 1) h
  generalize hH : runBits W n / 2 ^ (32 * (bb / 32 + 1)) = H at hsplit hword
  have ha := hW (bb / 32) hwi
  generalize bb / 32 = wi at hsplit hword ha hwi hwi1 hbb ⊢
  generalize bb % 32 = off at hoff hbb hwi1 ⊢
  subst hbb
  have hpq : 2 ^ off * 2 ^ (32 - off) = 2 ^ 32 := by rw [← Nat.pow_add]; congr 1; omega
  have hR : runBits W n / 2 ^ (32 * wi + off) = W wi / 2 ^ off + 2 ^ (32 - off) * H := by
    rw [Nat.pow_add, ← Nat.div_div_eq_div_mul, hsplit, ← hpq, Nat.mul_assoc,
      Nat.add_mul_div_left _ _ (Nat.two_pow_pos _)]
  rw [hR]
  split
  · rename_i hgt
    have hw1 : W (wi + 1) = H % 2 ^ 32 := (hword (hwi1 hgt)).symm
    have hy : W (wi + 1) * 2 ^ (32 - off) % 2 ^ 32 = H % 2 ^ off * 2 ^ (32 - off) := by
      rw [hw1, ← hpq, Nat.mul_mod_mul_right, Nat.mod_mod_of_dvd _ (Dvd.intro _ rfl)]
    have hx : W wi / 2 ^ off < 2 ^ (32 - off) := by
      rw [Nat.div_lt_iff_lt_mul (Nat.two_pow_pos _), Nat.mul_comm, hpq]; exact ha
    rw [hy, or_split hx]
    have e : 2 ^ (32 - off) * H = H % 2 ^ off * 2 ^ (32 - off) + 2 ^ 32 * (H / 2 ^ off) := by
      conv_lhs => rw [← Nat.mod_add_div H (2 ^ off)]
      rw [← hpq]; ring
    rw [e, ← Nat.add_assoc]
    generalize W wi / 2 ^ off + H % 2 ^ off * 2 ^ (32 - off) = A
    generalize H / 2 ^ off = M
    omega
  · rename_i hle
    have e : 2 ^ (32 - off) = 2 ^ 12 * 2 ^ (20 - off) := by rw [← Nat.pow_add]; congr 1; omega
    rw [e, Nat.mul_assoc]
    generalize W wi / 2 ^ off = A
    generalize 2 ^ (20 - off) * H = M
    omega

section Header
variable (C : M1Max.Contract) {ctx : Ctx}

/-- `trellis_y(s)` (GateUp.lean's `trellisYAt`): `p` and the `int` result in slots `b + 3`, `b + 1`. -/
theorem exec_trellisY (b : Nat) {l : Locals} {sh : Shared} {s : Nat} (h : l b = some (u32 s)) :
    ∃ l', Exec C ctx [trellisYAt b] l sh .normal l' sh ∧
      l' (b + 1) = some (i32 ((((trellisP s &&& 0xFFFF) + trellisP s / 2 ^ 16 : Nat) : Int) - 510)) ∧
      ((trellisP s &&& 0xFFFF) + trellisP s / 2 ^ 16 < 2 ^ 31) ∧ ∀ j, j ≤ b ∨ b + 3 < j → l' j = l j := by
  generalize hx : (s * 34038481 + 76625530) % 2 ^ 32 = x
  have hxl : x < 2 ^ 32 := by rw [← hx]; exact Nat.mod_lt _ (by decide)
  obtain ⟨P, hP, hPl⟩ : ∃ P, trellisP s = P ∧ P < 2 ^ 25 := ⟨_, rfl, trellisP_lt s⟩
  have hp : P = (x &&& 16711935) + (x / 2 ^ 8 &&& 16711935) := by rw [← hP, trellisP, hx]
  rw [hP]
  obtain ⟨Y, hY, hYl⟩ : ∃ Y, (P &&& 65535) + P / 2 ^ 16 = Y ∧ Y < 2 ^ 31 :=
    ⟨_, rfl, by have := Nat.and_le_right (n := P) (m := 65535); omega⟩
  rw [show (P &&& 0xFFFF) = (P &&& 65535) from rfl, hY]
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
    have hz : binary C .sub .i32 (.int .i32 Y) (.int .i32 510) = some (i32 ((Y : Int) - 510)) :=
      binary_sub_i32_nat C _ _ hYl (by decide)
    have hadd : (eval C ctx l₂ (.bin .add .u32 0 (.bin .bitAnd .u32 0 (.local (b + 3)) (GateUp.u32l 65535))
        (.bin .shr .u32 0 (.local (b + 3)) (GateUp.u32l 16)))).run sh = some (u32 Y, sh) := by
      rw [← hY]
      exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C h3 sh) (eval_u32lit C _ _ _ (by decide))
        (binary_bitAnd_u32 C _ 65535 (by omega) (by decide)))
        (eval_bin_u32 C (eval_local' C h3 sh) (eval_u32lit C _ _ _ (by decide))
          (binary_shr_u32 C _ 16 (by omega) (by decide))) (binary_add_u32 C _ _)
    exact eval_int C (by decide) (eval_conv C (t := .i32) hadd (convert_i32_u32 C _ hYl)) (eval_lit C _ _ _ _) hz
  refine ⟨setLocal l₂ (b + 1) (i32 ((Y : Int) - 510)), ?_, setLocal_same _ _ _, hYl, fun j hj => ?_⟩
  · exact .scope (.set e1 (by rw [hl₁]; exact .set e2 (by rw [hl₂]; exact .set e3 .leave))) (.inr rfl) (.nil _ _)
  · rw [setLocal_other _ _ (by omega), ← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_other _ _ (by omega)]

/-- The inlined `trellis_y_f32(s)`, `s` in slot `b`: its value in slot `b + 1`. -/
theorem exec_yF32 (b : Nat) {l : Locals} {sh : Shared} {s : Nat} (h : l b = some (u32 s)) :
    ∃ l', Exec C ctx [yF32 b] l sh .normal l' sh ∧ l' (b + 1) = some (.f32 (trellisF32 C s)) ∧
      ∀ j, j < b ∨ b + 5 < j → l' j = l j := by
  have hy : yF32 b = .scope [.set (b + 2) (.local b), trellisYAt (b + 2),
      .set (b + 1) (.bin .sub .f32 0 (.bitcast .f32 (GateUpMmaWide.u32 .bitOr (u32l 0x4B000000)
        (.conv .u32 (.bin .add .i32 0 (.local (b + 3)) (i32l 510))))) (f32l 0x4B0001FE)), .leave] := rfl
  rw [hy]
  have h2 : setLocal l (b + 2) (u32 s) (b + 2) = some (u32 s) := setLocal_same _ _ _
  obtain ⟨l₃, hex, h3, hYl, hag⟩ := exec_trellisY C (ctx := ctx) (sh := sh) (b + 2) h2
  generalize hY : (trellisP s &&& 0xFFFF) + trellisP s / 2 ^ 16 = Y at h3 hYl
  have hcb : trellisF32 C s = C.fadd (Val.ofF32Bits (0x4B000000 ||| Y)) (f32Neg (Val.ofF32Bits 0x4B0001FE)) := by
    unfold trellisF32 trellisYv
    rw [hY, show ((Y : Int) - 510 + 510).toNat = Y by omega]
  rw [hcb]
  have hor : 1258291200 ||| Y < 2 ^ 32 := Nat.or_lt_two_pow (by decide) (by omega)
  have e4 : (eval C ctx l₃ (.bitcast .f32 (GateUpMmaWide.u32 .bitOr (u32l 0x4B000000)
      (.conv .u32 (.bin .add .i32 0 (.local (b + 2 + 1)) (i32l 510)))))).run sh =
      some (.f32 (Val.ofF32Bits (0x4B000000 ||| Y)), sh) := by
    have hz : binary C .add .i32 (i32 ((Y : Int) - 510)) (.int .i32 510) = some (.int .i32 Y) := by
      rw [show Val.int .i32 510 = i32 510 from rfl, binary_add_i32v C (by omega) (by omega) (by omega) (by omega)
        (by omega) (by omega), i32_of_nat (n := Y) (by omega) (by omega)]
    exact eval_bitcast C (eval_bin_u32 C (eval_u32lit C _ _ _ (by decide))
      (eval_conv C (t := .u32) (eval_int C (by decide) (eval_local' C h3 sh) (eval_lit C _ _ _ _) hz)
        (convert_u32_i32 C _ hYl))
      (binary_bitOr_u32 C 1258291200 _ (by decide) (by omega))) (bitcast_f32_u32 _ hor)
  have e5 : (eval C ctx l₃ (.bin .sub .f32 0 (.bitcast .f32 (GateUpMmaWide.u32 .bitOr (u32l 0x4B000000)
      (.conv .u32 (.bin .add .i32 0 (.local (b + 2 + 1)) (i32l 510))))) (f32l 0x4B0001FE))).run sh =
      some (.f32 (C.fadd (Val.ofF32Bits (0x4B000000 ||| Y)) (f32Neg (Val.ofF32Bits 0x4B0001FE))), sh) :=
    eval_f32 C (.inr ⟨rfl, rfl⟩) e4 (eval_lit C _ _ _ _) rfl
  refine ⟨setLocal l₃ (b + 1) (.f32 _), .scope (.set (eval_local' C h sh) (hex.append (.set e5 .leave)))
    (.inr rfl) (.nil _ _), setLocal_same _ _ _, fun j hj => ?_⟩
  rw [setLocal_other _ _ (by omega), hag j (by omega), setLocal_other _ _ (by omega)]

end Header


section Header2
variable (C : M1Max.Contract) {ctx : Ctx}

/-- The inlined `run_state<K, 12>(w, j)` (slots `b … b + 6`): bits `(31 - j)·K …` of the words `W` of the
thread array `w` in slot `b + 2`. Thread-memory loads leave memory as it is. -/
theorem exec_state (K b : Nat) (hK : K ≤ 4) {wE jE : CExpr} {l : Locals} {sh : Shared} {rw j : Nat}
    {W : Nat → Nat} (hw : (eval C ctx l wE).run sh = some (.ptr ⟨rw, 0, .scalar .u32⟩, sh))
    (hj : (eval C ctx (setLocal l b (.ptr ⟨rw, 0, .scalar .u32⟩)) jE).run sh = some (u32 j, sh)) (hj32 : j < 32)
    (hr : sh.regions rw = some ⟨.thread, 4 * (K + 1), 4⟩) (hW : GateUp.Words (sh.bytes rw) (K + 1) W)
    (hWl : ∀ i < K + 1, W i < 2 ^ 32) :
    ∃ l', Exec C ctx (state K b wE jE) l sh .normal l' sh ∧
      l' (b + 2) = some (u32 (runBits W (K + 1) / 2 ^ ((31 - j) * K) % 2 ^ 12)) ∧
      ∀ i, (i < b ∨ b + 6 < i) → l' i = l i := by
  have hld := GateUp.Words.load (ctx := ctx) hr hW (by omega)
  have hbb1 : (31 - j) * K ≤ 31 * K := Nat.mul_le_mul_right _ (by omega)
  generalize hbb : (31 - j) * K = bb at hbb1
  generalize hl₁ : setLocal l b (.ptr ⟨rw, 0, .scalar .u32⟩) = l₁ at hj
  generalize hl₂ : setLocal l₁ (b + 1) (u32 j) = l₂
  have hb0 : l₂ b = some (.ptr ⟨rw, 0, .scalar .u32⟩) := by
    rw [← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_same]
  have hb1 : l₂ (b + 1) = some (u32 j) := by rw [← hl₂, setLocal_same]
  have e3 : (eval C ctx l₂ (GateUpMmaWide.u32 .mul (GateUpMmaWide.u32 .sub (u32l 31) (.local (b + 1)))
      (u32l K))).run sh = some (u32 bb, sh) := by
    rw [← hbb]
    exact eval_bin_u32 C (eval_bin_u32 C (eval_u32lit C _ _ 31 (by decide)) (eval_local' C hb1 sh)
      (binary_sub_u32 C 31 j (by omega))) (eval_u32lit C _ _ K (by omega)) (binary_mul_u32 C _ K)
  generalize hl₃ : setLocal l₂ (b + 3) (u32 bb) = l₃
  have hb3 : l₃ (b + 3) = some (u32 bb) := by rw [← hl₃, setLocal_same]
  have e4 : (eval C ctx l₃ (GateUpMmaWide.u32 .shr (.local (b + 3)) (u32l 5))).run sh = some (u32 (bb / 32), sh) :=
    eval_bin_u32 C (eval_local' C hb3 sh) (eval_u32lit C _ _ 5 (by decide)) (binary_shr_u32 C bb 5 (by omega) (by decide))
  generalize hl₄ : setLocal l₃ (b + 4) (u32 (bb / 32)) = l₄
  have hb4 : l₄ (b + 4) = some (u32 (bb / 32)) := by rw [← hl₄, setLocal_same]
  have hb43 : l₄ (b + 3) = some (u32 bb) := by rw [← hl₄, setLocal_other _ _ (by omega), hb3]
  have e5 : (eval C ctx l₄ (GateUpMmaWide.u32 .bitAnd (.local (b + 3)) (u32l 31))).run sh =
      some (u32 (bb % 32), sh) := by
    have := eval_bin_u32 C (ctx := ctx) (op := .bitAnd) (site := 0) (eval_local' C hb43 sh)
      (eval_u32lit C _ _ 31 (by decide)) (binary_bitAnd_u32 C bb 31 (by omega) (by decide))
    rwa [show bb &&& 31 = bb % 32 from Nat.and_two_pow_sub_one_eq_mod bb 5] at this
  generalize hl₅ : setLocal l₄ (b + 5) (u32 (bb % 32)) = l₅
  have hoff : bb % 32 < 32 := Nat.mod_lt _ (by decide)
  have hwi : bb / 32 < K + 1 := by omega
  have hb5 : l₅ (b + 5) = some (u32 (bb % 32)) := by rw [← hl₅, setLocal_same]
  have hb50 : l₅ b = some (.ptr ⟨rw, 0, .scalar .u32⟩) := by
    rw [← hl₅, setLocal_other _ _ (by omega), ← hl₄, setLocal_other _ _ (by omega), ← hl₃,
      setLocal_other _ _ (by omega), hb0]
  have hb54 : l₅ (b + 4) = some (u32 (bb / 32)) := by rw [← hl₅, setLocal_other _ _ (by omega), hb4]
  have hword : ∀ (L : Locals) (iE : CExpr) (i : Nat), i < K + 1 → L b = some (.ptr ⟨rw, 0, .scalar .u32⟩) →
      (eval C ctx L iE).run sh = some (u32 i, sh) →
      (eval C ctx L (ld (.offset (.local b) iE))).run sh = some (u32 (W i), sh) := by
    intro L iE i hi hL hiE
    have hp := eval_offset_u32 C (o := 0) (eval_local' C hL sh) hiE (by omega)
    rw [show 0 + i * (Ty.scalar .u32).bytes = 4 * i by simp [Ty.bytes, Scalar.bytes]; ring] at hp
    exact (eval_load C _ _ _ _ _ _ _ hp).trans (hld i hi)
  have e6 : (eval C ctx l₅ (GateUpMmaWide.u32 .shr (ld (.offset (.local b) (.local (b + 4)))) (.local (b + 5)))).run sh =
      some (u32 (W (bb / 32) / 2 ^ (bb % 32)), sh) :=
    eval_bin_u32 C (hword l₅ _ _ hwi hb50 (eval_local' C hb54 sh)) (eval_local' C hb5 sh)
      (binary_shr_u32 C _ _ (hWl _ hwi) hoff)
  generalize hl₆ : setLocal l₅ (b + 6) (u32 (W (bb / 32) / 2 ^ (bb % 32))) = l₆
  have hb6 : l₆ (b + 6) = some (u32 (W (bb / 32) / 2 ^ (bb % 32))) := by rw [← hl₆, setLocal_same]
  have hb65 : l₆ (b + 5) = some (u32 (bb % 32)) := by rw [← hl₆, setLocal_other _ _ (by omega), hb5]
  have hb64 : l₆ (b + 4) = some (u32 (bb / 32)) := by rw [← hl₆, setLocal_other _ _ (by omega), hb54]
  have hb60 : l₆ b = some (.ptr ⟨rw, 0, .scalar .u32⟩) := by rw [← hl₆, setLocal_other _ _ (by omega), hb50]
  have hc : (eval C ctx l₆ (GateUpMmaWide.u32 .gt (GateUpMmaWide.u32 .add (.local (b + 5)) (u32l 12)) (u32l 32))).run sh =
      some (.bool (decide (32 < bb % 32 + 12)), sh) :=
    eval_bin_u32 C (eval_bin_u32 C (eval_local' C hb65 sh) (eval_u32lit C _ _ 12 (by decide)) (binary_add_u32 C _ 12))
      (eval_u32lit C _ _ 32 (by decide)) (binary_gt_u32 C _ 32 (by omega) (by decide))
  have hx : W (bb / 32) / 2 ^ (bb % 32) < 2 ^ 32 := lt_of_le_of_lt (Nat.div_le_self _ _) (hWl _ hwi)
  -- The window value, as `state_bits` states it.
  obtain ⟨l₇, v, hbr, hb7, hv, hveq, hag7⟩ : ∃ l₇ v,
      Exec C ctx (if decide (32 < bb % 32 + 12) then
        [.set (b + 6) (GateUpMmaWide.u32 .bitOr (.local (b + 6)) (GateUpMmaWide.u32 .shl
          (ld (.offset (.local b) (GateUpMmaWide.u32 .add (.local (b + 4)) (u32l 1))))
          (GateUpMmaWide.u32 .sub (u32l 32) (.local (b + 5)))))] else []) l₆ sh .normal l₇ sh ∧
      l₇ (b + 6) = some (u32 v) ∧ v < 2 ^ 32 ∧
      v = (if 32 < bb % 32 + 12 then W (bb / 32) / 2 ^ (bb % 32) ||| W (bb / 32 + 1) * 2 ^ (32 - bb % 32) % 2 ^ 32
        else W (bb / 32) / 2 ^ (bb % 32)) ∧ ∀ i, i ≠ b + 6 → l₇ i = l₆ i := by
    by_cases hgt : 32 < bb % 32 + 12
    · have hwi1 : bb / 32 + 1 < K + 1 := by omega
      have hy : W (bb / 32 + 1) * 2 ^ (32 - bb % 32) % 2 ^ 32 < 2 ^ 32 := Nat.mod_lt _ (by decide)
      have hshl : (eval C ctx l₆ (GateUpMmaWide.u32 .shl
          (ld (.offset (.local b) (GateUpMmaWide.u32 .add (.local (b + 4)) (u32l 1))))
          (GateUpMmaWide.u32 .sub (u32l 32) (.local (b + 5))))).run sh =
          some (u32 (W (bb / 32 + 1) * 2 ^ (32 - bb % 32) % 2 ^ 32), sh) := by
        rw [u32_mod]
        exact eval_bin_u32 C (hword l₆ _ _ hwi1 hb60 (eval_bin_u32 C (eval_local' C hb64 sh)
          (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C _ 1)))
          (eval_bin_u32 C (eval_u32lit C _ _ 32 (by decide)) (eval_local' C hb65 sh) (binary_sub_u32 C 32 _ (by omega)))
          (binary_shl_u32 C _ _ (by omega))
      refine ⟨setLocal l₆ (b + 6) (u32 _), _, ?_, setLocal_same _ _ _, Nat.or_lt_two_pow hx hy, by rw [ite_eq_left hgt],
        fun i hi => setLocal_other _ _ hi⟩
      rw [decide_eq_true hgt, ite_eq_left rfl]
      exact .set (eval_bin_u32 C (eval_local' C hb6 sh) hshl (binary_bitOr_u32 C _ _ hx hy)) (.nil _ _)
    · refine ⟨l₆, _, ?_, hb6, hx, by rw [ite_eq_right hgt], fun _ _ => rfl⟩
      rw [decide_eq_false hgt, ite_eq_right (by decide)]
      exact .nil _ _
  have e2 : (eval C ctx l₇ (GateUpMmaWide.u32 .bitAnd (.local (b + 6)) (u32l 4095))).run sh =
      some (u32 (runBits W (K + 1) / 2 ^ bb % 2 ^ 12), sh) := by
    have := eval_bin_u32 C (ctx := ctx) (op := .bitAnd) (site := 0) (eval_local' C hb7 sh)
      (eval_u32lit C _ _ 4095 (by decide)) (binary_bitAnd_u32 C v 4095 hv (by decide))
    rwa [show v &&& 4095 = v % 2 ^ 12 from Nat.and_two_pow_sub_one_eq_mod v 12, hveq, state_bits hWl hwi
      (fun h => by omega)] at this
  refine ⟨setLocal l₇ (b + 2) (u32 _), ?_, setLocal_same _ _ _, fun i hi => ?_⟩
  · exact .set hw (by rw [hl₁]; exact .set hj (by
      rw [hl₂]
      exact .scope (.set e3 (by rw [hl₃]; exact .set e4 (by rw [hl₄]; exact .set e5 (by rw [hl₅]; exact .set e6 (by
        rw [hl₆]; exact .ite hc hbr (.set e2 .leave)))))) (.inr rfl) (.nil _ _)))
  · rw [setLocal_other _ _ (by omega), hag7 i (by omega), ← hl₆, setLocal_other _ _ (by omega), ← hl₅,
      setLocal_other _ _ (by omega), ← hl₄, setLocal_other _ _ (by omega), ← hl₃, setLocal_other _ _ (by omega),
      ← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_other _ _ (by omega)]

/-- `load_run`'s loop body. -/
def runLoopBody (b : Nat) : List CStmt :=
  [.set (b + 11) (GateUpMmaWide.u32 .add (.local (b + 9)) (.local (b + 10))),
   .store (.scalar .u32) (.offset (.local (b + 2)) (.local (b + 10)))
     (ld (.offset (.local (b + 8))
       (.cond (GateUpMmaWide.u32 .ge (.local (b + 11)) (.local (b + 4)))
         (GateUpMmaWide.u32 .sub (.local (b + 11)) (.local (b + 4))) (.local (b + 11)))))]

/-- The inlined `load_run<K, 256>(rowCodes, run, w)` (slots `b … b + 11`): the run's `K + 1` words of row `row`
(GateUp.lean's `runWord`) in the thread array `w` (region `rwr`). -/
theorem exec_run (K b : Nat) (hK : GateUp.Width K) {rcE runE wE : CExpr} {l : Locals} {sh : Shared}
    {rc rwr row run sizeC alC : Nat} {B : ByteMemory.Bytes} (Inv : Shared → Prop)
    (hrd : ∀ sh o, Inv sh → Inv (rdn ctx sh rc o 4)) (hput : ∀ sh o bs, Inv sh → Inv (Metal.tput sh rwr o bs))
    (hcodes : ∀ sh, Inv sh → sh.regions rc = some ⟨.device, sizeC, alC⟩ ∧ sh.bytes rc = B) (hal : alC % 4 = 0)
    (hrw : ∀ sh, Inv sh → sh.regions rwr = some ⟨.thread, 4 * (K + 1), 4⟩)
    (hrc : (eval C ctx l rcE).run sh =
      some (.ptr ⟨rc, ((4 * (row * (20 * (8 * K))) : Nat) : Int), .scalar .u32⟩, sh))
    (hrun : ∀ l', (∀ j < b, l' j = l j) → (eval C ctx l' runE).run sh = some (u32 run, sh))
    (hwE : ∀ l', (∀ j < b, l' j = l j) → (eval C ctx l' wE).run sh = some (.ptr ⟨rwr, 0, .scalar .u32⟩, sh))
    (hrun160 : run < 160) (hrow : row < 17408) (hsize : 4 * (17408 * 160 * K) ≤ sizeC) (h0 : Inv sh) :
    ∃ l' sh', Exec C ctx (GateUpMmaWide.run K b rcE runE wE) l sh .normal l' sh' ∧ Inv sh' ∧
      sh'.regions = sh.regions ∧ (∀ ρ, ρ ≠ rwr → sh'.bytes ρ = sh.bytes ρ) ∧
      GateUp.Words (sh'.bytes rwr) (K + 1) (GateUp.runWord K B row run) ∧
      ∀ j, (j < b ∨ b + 11 < j) → l' j = l j := by
  have hK4 := GateUp.width_le hK
  have hw0K := GateUp.ar_w0K (run := run) hK
  have hbnd := GateUp.ar_bound hK hrow hrun160
  have hw0 : (224 - (run - run / 8 * 8) * 32) * K / 32 = GateUp.w0 K run := by
    unfold GateUp.w0; rw [show run - run / 8 * 8 = run % 8 by omega]
  have hw0l : (224 - (run - run / 8 * 8) * 32) * K < 2 ^ 32 := by
    have : (224 - (run - run / 8 * 8) * 32) * K ≤ 224 * 4 := Nat.mul_le_mul (by omega) hK4.2
    omega
  have hblk : run / 8 * (8 * K) < 2 ^ 32 := by rcases hK with rfl | rfl | rfl | rfl <;> omega
  let L₁₀ : Locals := setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal
    (setLocal l b (.ptr ⟨rc, ((4 * (row * (20 * (8 * K))) : Nat) : Int), .scalar .u32⟩)) (b + 1) (u32 run))
    (b + 2) (.ptr ⟨rwr, 0, .scalar .u32⟩)) (b + 4) (u32 (8 * K))) (b + 5) (u32 8)) (b + 6) (u32 (run / 8)))
    (b + 7) (u32 ((run - run / 8 * 8) * 32)))
    (b + 8) (.ptr ⟨rc, ((4 * (row * (20 * (8 * K))) + run / 8 * (8 * K) * 4 : Nat) : Int), .scalar .u32⟩))
    (b + 9) (u32 ((224 - (run - run / 8 * 8) * 32) * K / 32))) (b + 10) (u32 0)
  have hL : ∀ j, (j < b ∨ b + 10 < j) → L₁₀ j = l j := fun j hj => by
    simp (disch := omega) only [L₁₀, setLocal_other]
  have h2 : L₁₀ (b + 2) = some (.ptr ⟨rwr, 0, .scalar .u32⟩) := by
    simp (disch := omega) only [L₁₀, setLocal_other, setLocal_same]
  have h4 : L₁₀ (b + 4) = some (u32 (8 * K)) := by simp (disch := omega) only [L₁₀, setLocal_other, setLocal_same]
  have h8 : L₁₀ (b + 8) =
      some (.ptr ⟨rc, ((4 * (row * (20 * (8 * K))) + run / 8 * (8 * K) * 4 : Nat) : Int), .scalar .u32⟩) := by
    simp (disch := omega) only [L₁₀, setLocal_other, setLocal_same]
  have h9 : L₁₀ (b + 9) = some (u32 (GateUp.w0 K run)) := by
    rw [← hw0]; simp (disch := omega) only [L₁₀, setLocal_other, setLocal_same]
  have h10 : L₁₀ (b + 10) = some (u32 0) := by simp only [L₁₀, setLocal_same]
  let J : Nat → Locals → Shared → Prop := fun k L S => Inv S ∧ S.regions = sh.regions ∧
    (∀ ρ, ρ ≠ rwr → S.bytes ρ = sh.bytes ρ) ∧ (∀ j, j ≠ b + 10 → j ≠ b + 11 → L j = L₁₀ j) ∧
    L (b + 10) = some (u32 k) ∧ ∀ i < k, cells (S.bytes rwr) (4 * i) 4 = wordBytes 4 (GateUp.runWord K B row run i)
  obtain ⟨l', sh', hloop, hJ⟩ := Exec.loop_count (C := C) (ctx := ctx) (c := le (b + 10) K) (st := incr (b + 10))
    (b := runLoopBody b) (K + 1) J J
    (fun k hk L S hJk => ⟨S, by
      have := eval_bin_u32 C (ctx := ctx) (op := .le) (site := 0) (eval_local' C hJk.2.2.2.2.1 S)
        (eval_u32lit C _ _ K (by omega)) (binary_le_u32 C k K (by omega) (by omega))
      rwa [show decide (k ≤ K) = decide (k < K + 1) from decide_eq_decide.mpr (by omega)] at this, hJk⟩)
    (fun k hk L S hJk => by
      obtain ⟨hinv, hreg, hoth, hag, h10k, hwords⟩ := hJk
      have hc := hcodes S hinv
      have hrwS := hrw S hinv
      have h9L : L (b + 9) = some (u32 (GateUp.w0 K run)) := by rw [hag _ (by omega) (by omega)]; exact h9
      have e11 : (eval C ctx L (GateUpMmaWide.u32 .add (.local (b + 9)) (.local (b + 10)))).run S =
          some (u32 (GateUp.w0 K run + k), S) :=
        eval_bin_u32 C (eval_local' C h9L S) (eval_local' C h10k S) (binary_add_u32 C _ k)
      have h11 : setLocal L (b + 11) (u32 (GateUp.w0 K run + k)) (b + 11) = some (u32 (GateUp.w0 K run + k)) :=
        setLocal_same _ _ _
      have h4' : setLocal L (b + 11) (u32 (GateUp.w0 K run + k)) (b + 4) = some (u32 (8 * K)) := by
        rw [setLocal_other _ _ (by omega), hag _ (by omega) (by omega)]; exact h4
      have h8' : setLocal L (b + 11) (u32 (GateUp.w0 K run + k)) (b + 8) =
          some (.ptr ⟨rc, ((4 * (row * (20 * (8 * K))) + run / 8 * (8 * K) * 4 : Nat) : Int), .scalar .u32⟩) := by
        rw [setLocal_other _ _ (by omega), hag _ (by omega) (by omega)]; exact h8
      have h2' : setLocal L (b + 11) (u32 (GateUp.w0 K run + k)) (b + 2) = some (.ptr ⟨rwr, 0, .scalar .u32⟩) := by
        rw [setLocal_other _ _ (by omega), hag _ (by omega) (by omega)]; exact h2
      have h10' : setLocal L (b + 11) (u32 (GateUp.w0 K run + k)) (b + 10) = some (u32 k) := by
        rw [setLocal_other _ _ (by omega)]; exact h10k
      have hidx : (eval C ctx (setLocal L (b + 11) (u32 (GateUp.w0 K run + k)))
          (.cond (GateUpMmaWide.u32 .ge (.local (b + 11)) (.local (b + 4)))
            (GateUpMmaWide.u32 .sub (.local (b + 11)) (.local (b + 4))) (.local (b + 11)))).run S =
          some (u32 ((GateUp.w0 K run + k) % (8 * K)), S) := by
        have hge := eval_bin_u32 C (ctx := ctx) (op := .ge) (site := 0) (eval_local' C h11 S) (eval_local' C h4' S)
          (binary_ge_u32 C _ _ (by omega) (by omega))
        by_cases hw : 8 * K ≤ GateUp.w0 K run + k
        · rw [decide_eq_true hw] at hge
          refine eval_cond C hge ?_
          rw [ite_eq_left rfl, Nat.mod_eq_sub_mod hw, Nat.mod_eq_of_lt (by omega)]
          exact eval_bin_u32 C (eval_local' C h11 S) (eval_local' C h4' S) (binary_sub_u32 C _ _ hw)
        · rw [decide_eq_false hw] at hge
          refine eval_cond C hge ?_
          rw [ite_eq_right (by decide), Nat.mod_eq_of_lt (by omega)]
          exact eval_local' C h11 S
      have hidxl : (GateUp.w0 K run + k) % (8 * K) < 8 * K := Nat.mod_lt _ (by omega)
      have hsrc := eval_offset_u32 C (eval_local' C h8' S) hidx (by omega)
      rw [show 4 * (row * (20 * (8 * K))) + run / 8 * (8 * K) * 4 + (GateUp.w0 K run + k) % (8 * K) *
          (Ty.scalar .u32).bytes = 4 * (GateUp.gbase K row run + (GateUp.w0 K run + k) % (8 * K)) by
        rw [← GateUp.ar_gw]; simp only [Ty.bytes, Scalar.bytes]; ring] at hsrc
      have hload := load_shared ctx .u32 S rc (4 * (GateUp.gbase K row run + (GateUp.w0 K run + k) % (8 * K))) _
        hc.1 (by simp) (by simpa [Scalar.bytes] using hal) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega)
        (by simp [loadOffset])
      rw [hc.2] at hload
      have hdst := eval_ptr_u32 C (ctx := ctx) (eval_local' C h2' S) (eval_local' C h10' S) (by omega)
      rw [show k * (Ty.scalar .u32).bytes = 4 * k by simp only [Ty.bytes, Scalar.bytes]; ring] at hdst
      have hst := store_thread ctx .u32 (rdn ctx S rc (4 * (GateUp.gbase K row run + (GateUp.w0 K run + k) % (8 * K)))
        Scalar.u32.bytes) rwr (4 * k) (4 * (K + 1)) 4
        (u32 (word32 B (GateUp.gbase K row run + (GateUp.w0 K run + k) % (8 * K))))
        (wordBytes 4 (word32 B (GateUp.gbase K row run + (GateUp.w0 K run + k) % (8 * K))))
        (by rw [rdn_regions]; exact hrwS) (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega)
        (encode_u32 _ (word32_lt B _))
      have hrw' : GateUp.runWord K B row run k = word32 B (GateUp.gbase K row run + (GateUp.w0 K run + k) % (8 * K)) := by
        rw [GateUp.runWord, ← GateUp.ar_wrap hK (by omega)]
      refine ⟨.normal, _, _, setLocal (setLocal L (b + 11) (u32 (GateUp.w0 K run + k))) (b + 10) (u32 (k + 1)), _,
        .inl rfl, .set e11 (.store hdst ((eval_load C _ _ _ _ _ _ _ hsrc).trans hload) hst (.nil _ _)),
        .set (eval_bin_u32 C (eval_local' C h10' _) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C k 1)) (.nil _ _),
        hput _ _ _ (hrd _ _ hinv), by rw [tput_regions, rdn_regions, hreg],
        fun ρ hρ => by rw [tput_other _ _ _ hρ, rdn_bytes, hoth ρ hρ],
        fun j hj1 hj2 => by rw [setLocal_other _ _ hj1, setLocal_other _ _ hj2, hag j hj1 hj2], setLocal_same _ _ _,
        fun i hi => ?_⟩
      rw [tput_same, rdn_bytes]
      by_cases hik : i = k
      · subst hik
        rw [hrw']
        have := cells_writeBytes_same (S.bytes rwr) (4 * i)
          (wordBytes 4 (word32 B (GateUp.gbase K row run + (GateUp.w0 K run + i) % (8 * K))))
        rwa [wordBytes_length] at this
      · rw [cells_writeBytes_other _ _ _ _ _ (by rw [wordBytes_length]; omega)]
        exact hwords i (by omega))
    (l := L₁₀) (sh := sh) ⟨h0, rfl, fun _ _ => rfl, fun _ _ _ => rfl, h10, fun i hi => absurd hi (by omega)⟩
  obtain ⟨hinv, hreg, hoth, hag, -, hwords⟩ := hJ
  refine ⟨l', sh', ?_, hinv, hreg, hoth, hwords, fun j hj => by rw [hag j (by omega) (by omega), hL j (by omega)]⟩
  exact .set hrc (.set (hrun _ fun j hj => setLocal_other _ _ (by omega))
    (.set (hwE _ fun j hj => by simp (disch := omega) only [setLocal_other])
    (.scope (.set (eval_u32lit C _ _ (8 * K) (by omega)) (.set (eval_u32lit C _ _ 8 (by decide))
      (.set (eval_bin_u32 C (eval_local' C (by simp (disch := omega) only [setLocal_other, setLocal_same]) _)
        (eval_local' C (by simp (disch := omega) only [setLocal_same]) _)
        (binary_div_u32 C run 8 (by omega) (by decide) (by decide)))
      (.set (eval_bin_u32 C (eval_bin_u32 C (eval_local' C (by simp (disch := omega) only [setLocal_other, setLocal_same]) _)
          (eval_bin_u32 C (eval_local' C (by simp (disch := omega) only [setLocal_same]) _)
            (eval_local' C (by simp (disch := omega) only [setLocal_other, setLocal_same]) _)
            (binary_mul_u32 C (run / 8) 8)) (binary_sub_u32 C run (run / 8 * 8) (by omega)))
        (eval_u32lit C _ _ 32 (by decide)) (binary_mul_u32 C _ 32))
      (.set (eval_offset_u32 C (eval_local' C (v := .ptr ⟨rc, ((4 * (row * (20 * (8 * K))) : Nat) : Int), .scalar .u32⟩) (by simp (disch := omega) only [setLocal_other, setLocal_same]) _)
          (eval_bin_u32 C (eval_local' C (by simp (disch := omega) only [setLocal_other, setLocal_same]) _)
            (eval_local' C (by simp (disch := omega) only [setLocal_other, setLocal_same]) _)
            (binary_mul_u32 C (run / 8) (8 * K))) hblk)
      (.set (eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_u32lit C _ _ 224 (by decide))
          (eval_local' C (by simp (disch := omega) only [setLocal_other, setLocal_same]) _)
          (binary_sub_u32 C 224 _ (by omega))) (eval_u32lit C _ _ K (by omega)) (binary_mul_u32 C _ K))
          (eval_u32lit C _ _ 32 (by decide)) (binary_div_u32 C _ 32 hw0l (by decide) (by decide)))
      (.set (eval_u32lit C _ _ 0 (by decide)) hloop))))))) (.inl rfl) (.nil _ _))))


end Header2


/-! ## The code's parts -/

/-- The scope's statements (the body after its buffer pointers). -/
def S0 (kg ku mt : Nat) : List CStmt :=
  match body kg ku mt with
  | [_, _, _, _, _, _, _, .scope s] => s
  | _ => []

theorem body_eq (kg ku mt : Nat) : body kg ku mt = (body kg ku mt).take 7 ++ [.scope (S0 kg ku mt)] := rfl

/-- `n0 … mBase`, `accG`, `accU`, `bk = 0`. -/
def setup (kg ku mt : Nat) : List CStmt := ((S0 kg ku mt).drop 8).take 10
def accLoop (mt : Nat) : CStmt :=
  .loop (lt 29 mt) (incr 29)
    [.store (.vec .f32 2) (.offset (.local 27) (.local 29)) (.vector .f32 [f32l 0x0, f32l 0x0]),
     .store (.vec .f32 2) (.offset (.local 28) (.local 29)) (.vector .f32 [f32l 0x0, f32l 0x0])]
def baseCond : CExpr := lt 30 5120
def baseStep : List CStmt := [.set 30 (GateUpMmaWide.u32 .add (.local 30) (u32l 256))]
/-- After the 256-position steps: `if (n0 >= R) return`, the scales, the outputs. -/
def afterBase (kg ku mt : Nat) : List CStmt := (S0 kg ku mt).drop 21

theorem S0_eq (kg ku mt : Nat) : S0 kg ku mt = (S0 kg ku mt).take 7 ++ fillLoop :: setup kg ku mt ++
    accLoop mt :: .set 30 (u32l 0) :: .loop baseCond baseStep (stepBody kg ku mt) :: afterBase kg ku mt := rfl

def stageCond (mt : Nat) : CExpr := lt 31 (512 * mt)
def stageStep : List CStmt := [.set 31 (GateUpMmaWide.u32 .add (.local 31) (u32l 256))]
def stepRest1 (kg ku mt : Nat) : List CStmt := (stepBody kg ku mt).drop 1
def stepRest2 (kg ku mt : Nat) : List CStmt := (stepBody kg ku mt).drop 4
/-- `runA` and the run arrays. -/
def decl2 : List CStmt := (stepRest2 0 0 0).take 5
def runs (kg ku : Nat) : List CStmt :=
  run kg 41 (.local 24) (.local 36) (.local 37) ++ run kg 53 (.local 24) (GateUpMmaWide.u32 .add (.local 36) (u32l 1)) (.local 38) ++
  run ku 65 (.local 25) (.local 36) (.local 39) ++ run ku 77 (.local 25) (GateUpMmaWide.u32 .add (.local 36) (u32l 1)) (.local 40)
def jCond : CExpr := lt 89 32
def bkCond (mt : Nat) : CExpr := lt 120 mt
/-- A position's statements before its row blocks. -/
def posPre (kg ku : Nat) : List CStmt := (positionBody kg ku 0).take 19

theorem stepBody_eq (kg ku mt : Nat) : stepBody kg ku mt = .barrier 1 false true :: stepRest1 kg ku mt := rfl
theorem stepRest1_eq (kg ku mt : Nat) : stepRest1 kg ku mt =
    [.set 31 (.local 10), .loop (stageCond mt) stageStep stageBody] ++ .barrier 2 false true :: stepRest2 kg ku mt := rfl
theorem stepRest2_eq (kg ku mt : Nat) : stepRest2 kg ku mt =
    (decl2 ++ runs kg ku ++ [.set 89 (u32l 0)]) ++ [.loop jCond (incr 89) (positionBody kg ku mt)] := rfl
theorem positionBody_eq (kg ku mt : Nat) : positionBody kg ku mt =
    posPre kg ku ++ [.loop (bkCond mt) (incr 120) blockBody] := rfl
theorem posPre_eq (kg ku : Nat) : posPre kg ku =
    [.array 90 false 6 (.vec .f32 2), .array 91 false 7 (.vec .f32 2)] ++
      (state kg 92 (.local 37) (.local 89) ++ (aElem 90 0 94 :: (state kg 99 (.local 38) (.local 89) ++
      (aElem 90 1 101 :: (state ku 106 (.local 39) (.local 89) ++ (aElem 91 0 108 ::
      (state ku 113 (.local 40) (.local 89) ++ [aElem 91 1 115, .set 120 (u32l 0)]))))))) := rfl

def blockRest3 : List CStmt := blockBody.drop 4
def blockRest4 : List CStmt := blockBody.drop 6

/-- The frames below a 256-position step's body, a position's body and a row block's body. -/
def K1 (kg ku mt : Nat) : List Frame :=
  [.loop baseCond baseStep (stepBody kg ku mt), .block (afterBase kg ku mt), .scope, .block []]
def Kb (kg ku mt : Nat) : List Frame :=
  [.loop (bkCond mt) (incr 120) blockBody, .block [], .loop jCond (incr 89) (positionBody kg ku mt), .block []] ++
    K1 kg ku mt

/-! ## A lane -/

/-- Thread `(y + 272·z)·256 + 32·s + i`. -/
def thOf (y z s i : Nat) : Nat := (y + 272 * z) * 256 + (32 * s + i)

/-- Lane `i` of SIMD-group `s` of threadgroup `(0, y, z)`. -/
structure Lane (ctx : Ctx) (y z s i : Nat) : Prop where
  tgpos : ctx.coord .threadgroupPositionInGrid = u32x3 0 y z
  lane : ctx.coord .threadIndexInSimdgroup = u32 i
  sg : ctx.coord .simdgroupIndexInThreadgroup = u32 s
  thread : ctx.thread = thOf y z s i
  group : ctx.group = y + 272 * z
  ga0 : ctx.groupArray 0 = 7
  ga1 : ctx.groupArray 1 = 8
  ta : ∀ j, ctx.threadArray j = ta (thOf y z s i) j
  hy : y < 272
  hs : s < 8
  hi : i < 32

theorem launch_tiles {kg ku mt : Nat} {I : In} {initial : Nat → ByteMemory.Bytes} (hgz : 0 < gz I.r mt) :
    (launch kg ku mt I initial).Tiles 256 1 1 1 272 (gz I.r mt) 8 :=
  ⟨rfl, by simp [launch], rfl, ⟨by decide, by decide, by decide, hgz⟩⟩

theorem lane_of {kg ku mt : Nat} {I : In} {initial : Nat → ByteMemory.Bytes} (hgz : 0 < gz I.r mt) (fuse : Nat → Bool)
    {y z : Nat} (hy : y < 272) (s : Fin 8) (i : Fin 32) :
    Lane ((launch kg ku mt I initial).ctxAt fuse 0 y z (32 * s + i)) y z s i := by
  have hs := s.isLt; have hi := i.isLt
  have hT := launch_tiles (kg := kg) (ku := ku) (initial := initial) hgz
  refine ⟨Launch.ctxAt_threadgroupPositionInGrid _ _ _ _ _ _, Launch.ctxAt_lane _ _ _ _ _ _ _,
    Launch.ctxAt_simd _ _ _ _ _ _ _, ?_, ?_, rfl, rfl, fun j => ?_, hy, hs, hi⟩
  · rw [hT.thread]; unfold thOf; omega
  · rw [hT.group_id]; omega
  · rw [hT.threadArray, show (launch kg ku mt I initial).buffers.length = 7 from rfl,
      show (launch kg ku mt I initial).groupArrays = 2 from rfl,
      show (launch kg ku mt I initial).threadArrays = 9 from rfl]
    unfold ta thOf; omega

/-- The locals every later statement reads. -/
structure Fix (kg ku mt r y z s i : Nat) (l : Locals) : Prop where
  l0 : l 0 = some (.ptr ⟨0, 0, .scalar .bf16⟩)
  l3 : l 3 = some (.ptr ⟨3, 0, .scalar .f16⟩)
  l5 : l 5 = some (.ptr ⟨5, 0, .scalar .f16⟩)
  l6 : l 6 = some (.ptr ⟨6, 0, .scalar .bf16⟩)
  l7 : l 7 = some (u32 r)
  l10 : l 10 = some (u32 (32 * s + i))
  l11 : l 11 = some (.ptr ⟨7, 0, .scalar .f16⟩)
  l12 : l 12 = some (.ptr ⟨8, 0, .scalar .bf16⟩)
  l20 : l 20 = some (u32 (8 * (8 * y + s)))
  l21 : l 21 = some (u32 (fmOf i))
  l22 : l 22 = some (u32 (fnOf i))
  l23 : l 23 = some (u32 (8 * (8 * y + s) + fmOf i))
  l24 : l 24 = some (.ptr ⟨2, ((4 * ((8 * (8 * y + s) + fmOf i) * (20 * (8 * kg))) : Nat) : Int), .scalar .u32⟩)
  l25 : l 25 = some (.ptr ⟨4, ((4 * ((8 * (8 * y + s) + fmOf i) * (20 * (8 * ku))) : Nat) : Int), .scalar .u32⟩)
  l26 : l 26 = some (u32 (z * 8 * mt))
  l27 : l 27 = some (.ptr ⟨ta (thOf y z s i) 0, 0, .vec .f32 2⟩)
  l28 : l 28 = some (.ptr ⟨ta (thOf y z s i) 1, 0, .vec .f32 2⟩)

theorem Fix.of_eq {kg ku mt r y z s i : Nat} {l l' : Locals} (h : Fix kg ku mt r y z s i l)
    (h' : ∀ j, j ≤ 28 → l' j = l j) : Fix kg ku mt r y z s i l' :=
  ⟨(h' 0 (by omega)).trans h.l0, (h' 3 (by omega)).trans h.l3, (h' 5 (by omega)).trans h.l5,
    (h' 6 (by omega)).trans h.l6, (h' 7 (by omega)).trans h.l7, (h' 10 (by omega)).trans h.l10,
    (h' 11 (by omega)).trans h.l11, (h' 12 (by omega)).trans h.l12, (h' 20 (by omega)).trans h.l20,
    (h' 21 (by omega)).trans h.l21, (h' 22 (by omega)).trans h.l22, (h' 23 (by omega)).trans h.l23,
    (h' 24 (by omega)).trans h.l24, (h' 25 (by omega)).trans h.l25, (h' 26 (by omega)).trans h.l26,
    (h' 27 (by omega)).trans h.l27, (h' 28 (by omega)).trans h.l28⟩

/-- In a row block of position `j` of 256-position step `k`: also `base`, the run arrays, `j`, `aG`, `aU`,
`bk`, `b`. -/
structure Loc (kg ku mt r y z s i k j bk : Nat) (l : Locals) : Prop where
  fix : Fix kg ku mt r y z s i l
  l30 : l 30 = some (u32 (256 * k))
  l37 : l 37 = some (.ptr ⟨ta (thOf y z s i) 2, 0, .scalar .u32⟩)
  l38 : l 38 = some (.ptr ⟨ta (thOf y z s i) 3, 0, .scalar .u32⟩)
  l39 : l 39 = some (.ptr ⟨ta (thOf y z s i) 4, 0, .scalar .u32⟩)
  l40 : l 40 = some (.ptr ⟨ta (thOf y z s i) 5, 0, .scalar .u32⟩)
  l89 : l 89 = some (u32 j)
  l90 : l 90 = some (.ptr ⟨ta (thOf y z s i) 6, 0, .vec .f32 2⟩)
  l91 : l 91 = some (.ptr ⟨ta (thOf y z s i) 7, 0, .vec .f32 2⟩)
  l120 : l 120 = some (u32 bk)
  l121 : l 121 = some (.ptr ⟨ta (thOf y z s i) 8, 0, .vec .f32 2⟩)

/-! ## Thread memory facts -/

/-- Four bytes of `B` from `o` are `x`'s. -/
def F32At (B : ByteMemory.Bytes) (o : Nat) (x : Float32) : Prop := cells B o 4 = wordBytes 4 (Val.f32Bits x)

/-- `accG` (array 0) and `accU` (array 1) hold row block `bk`'s accumulators `G bk`, `U bk` (lane `i`'s). -/
def AccOk (mt : Nat) (i : Fin 32) (G U : Nat → Fin 32 → Fin 2 → Float32) (B : Nat → ByteMemory.Bytes) : Prop :=
  ∀ bk < mt, F32At (B 0) (8 * bk) (G bk i 0) ∧ F32At (B 0) (8 * bk + 4) (G bk i 1) ∧
    F32At (B 1) (8 * bk) (U bk i 0) ∧ F32At (B 1) (8 * bk + 4) (U bk i 1)

section Facts
variable (C : M1Max.Contract) (kg ku mt : Nat) (I : In) (y z s : Nat) (i : Fin 32)

/-- Row block `bk`'s gate and up accumulators after `n` positions. -/
def AG (bk n : Nat) : Fin 32 → Fin 2 → Float32 := acc C (aReg C kg I.Gc (8 * y + s)) (bReg C I.r I.X (mt * z + bk)) n
def AU (bk n : Nat) : Fin 32 → Fin 2 → Float32 := acc C (aReg C ku I.Uc (8 * y + s)) (bReg C I.r I.X (mt * z + bk)) n

/-- Progress: blocks before `bk` one position further. -/
def pg (bk b n : Nat) : Nat := if b < bk then n + 1 else n

/-- The run arrays of step `k`: `ga`, `gb`, `ua`, `ub` (arrays 2 … 5). -/
def WordsOk (k : Nat) (B : Nat → ByteMemory.Bytes) : Prop :=
  GateUp.Words (B 2) (kg + 1) (GateUp.runWord kg I.Gc (8 * (8 * y + s) + fmOf i) (8 * k + fnOf i)) ∧
  GateUp.Words (B 3) (kg + 1) (GateUp.runWord kg I.Gc (8 * (8 * y + s) + fmOf i) (8 * k + fnOf i + 1)) ∧
  GateUp.Words (B 4) (ku + 1) (GateUp.runWord ku I.Uc (8 * (8 * y + s) + fmOf i) (8 * k + fnOf i)) ∧
  GateUp.Words (B 5) (ku + 1) (GateUp.runWord ku I.Uc (8 * (8 * y + s) + fmOf i) (8 * k + fnOf i + 1))

/-- `aG` and `aU` (arrays 6, 7) at position `n`. -/
def AOk (n : Nat) (B : Nat → ByteMemory.Bytes) : Prop :=
  F32At (B 6) 0 (aReg C kg I.Gc (8 * y + s) n i 0) ∧ F32At (B 6) 4 (aReg C kg I.Gc (8 * y + s) n i 1) ∧
  F32At (B 7) 0 (aReg C ku I.Uc (8 * y + s) n i 0) ∧ F32At (B 7) 4 (aReg C ku I.Uc (8 * y + s) n i 1)

/-- `b` (array 8) at position `n` of row block `bk`. -/
def BOk (n bk : Nat) (B : Nat → ByteMemory.Bytes) : Prop :=
  F32At (B 8) 0 (bReg C I.r I.X (mt * z + bk) n i 0) ∧ F32At (B 8) 4 (bReg C I.r I.X (mt * z + bk) n i 1)

/-- At a barrier of step `k`: the accumulators after `32·k` positions. -/
def OwnB (k : Nat) (B : Nat → ByteMemory.Bytes) : Prop :=
  AccOk mt i (fun b => AG C kg mt I y z s b (32 * k)) (fun b => AU C ku mt I y z s b (32 * k)) B

/-- At the gate (`ph = 0`) or up (`ph = 1`) multiply of position `32·k + j`, row block `bk`. -/
def OwnC (k j bk ph : Nat) (B : Nat → ByteMemory.Bytes) : Prop :=
  AccOk mt i (fun b => AG C kg mt I y z s b (pg (bk + ph) b (32 * k + j)))
    (fun b => AU C ku mt I y z s b (pg bk b (32 * k + j))) B ∧
  WordsOk kg ku I y s i k B ∧ AOk C kg ku I y s i (32 * k + j) B ∧ BOk C mt I z i (32 * k + j) bk B

end Facts


/-! ## Lane arithmetic -/

theorem fmOf_lt (i : Nat) : fmOf i < 8 := by
  unfold fmOf; have := Nat.and_le_right (n := i / 4) (m := 4); omega

theorem fnOf_le (i : Nat) : fnOf i ≤ 6 := by
  unfold fnOf; have := Nat.and_le_right (n := i / 4) (m := 2); omega

theorem fnOf_even (i : Nat) : fnOf i % 2 = 0 := by unfold fnOf; omega

/-- Each lane holds its own fragment element: `laneOf` inverts `fm`, `fn`. -/
theorem laneOf_fm_fn : ∀ i < 32, ∀ e < 2, laneOf (fmOf i) (fnOf i + e) = i := by decide

theorem fm_laneOf : ∀ a < 8, ∀ c < 8, fmOf (laneOf a c) = a ∧ fnOf (laneOf a c) + c % 2 = c ∧ laneOf a c < 32 := by
  decide

theorem tgo_cb {g ge byte : Nat} (h : ge ≠ 40 * g) : tgo g ge 7 byte = none := by
  unfold tgo; rw [ite_eq_left rfl, ite_eq_right h]

theorem tgo_xs {g ge byte : Nat} (h : (ge - 40 * g) % 2 = 0) : tgo g ge 8 byte = none := by
  unfold tgo; rw [ite_eq_right (by decide), ite_eq_left rfl, ite_eq_right (by omega)]

theorem stg_val (X : ByteMemory.Bytes) (r mb base q : Nat) :
    Val.ofWord .bf16 (bytesWord (stg X r mb base q)) = .bf16 (xsv r X (mb + q / 256) (base + q % 256)) := by
  unfold stg xsv xel
  by_cases h : mb + q / 256 < r
  · rw [ite_eq_left h, ite_eq_left h]
    show Val.bf16 _ = _
    congr 1; unfold half; congr 3; ring
  · rw [ite_eq_right h, ite_eq_right h]; rfl

section Vals
variable (C : M1Max.Contract)

/-- `aG`/`aU`'s element as the code computes it: the codebook entry of run `8·k + fn + e`'s state at `j`. -/
theorem aReg_eq (K : Nat) (Codes : ByteMemory.Bytes) (g8 k j : Nat) (hj : j < 32) (i : Fin 32) (e : Fin 2) :
    aReg C K Codes g8 (32 * k + j) i e = Float16.widen (cbv C (trellisCode K Codes
      (GateUp.gbase K (8 * g8 + fmOf i) (8 * k + fnOf i + e)) ((8 * k + fnOf i + e) % 8 * 32 + j))) := by
  have h6 := fnOf_le i
  have he := e.isLt
  unfold aReg weight GateUp.gbase
  rw [show (32 * k + j) / 32 = k by omega, show (32 * k + j) % 32 = j by omega,
    show (256 * k + 32 * (fnOf i + e) + j) / 256 = k by omega,
    show (256 * k + 32 * (fnOf i + e) + j) % 256 = (8 * k + fnOf i + e) % 8 * 32 + j by omega,
    show (8 * k + fnOf i + e) / 8 = k by omega]

/-- `b`'s element: `xs[8·bk + fn + e][32·fm + j]` staged from rows `mb = 8·MT·z` and columns `256·k`. -/
theorem bReg_eq (r : Nat) (X : ByteMemory.Bytes) (mt z bk k j : Nat) (hj : j < 32) (i : Fin 32) (e : Fin 2) :
    bReg C r X (mt * z + bk) (32 * k + j) i e =
      C.widen (xsv r X (z * 8 * mt + (8 * bk + fnOf i + e)) (256 * k + (32 * fmOf i + j))) := by
  unfold bReg
  rw [show (32 * k + j) / 32 = k by omega, show (32 * k + j) % 32 = j by omega]
  congr 2
  · ring
  · ring

end Vals

/-! ## Thread memory lemmas -/

theorem tm_eq {th : Nat} {sh sh' : Shared} (h : ∀ q < 9, sh'.bytes (ta th q) = sh.bytes (ta th q)) :
    tm th sh' = tm th sh := by
  funext q; unfold tm; split
  · exact h q (by omega)
  · rfl

theorem ta_ne {th q q' : Nat} (h : q ≠ q') : ta th q ≠ ta th q' := by unfold ta; omega

theorem ta_ge (th q : Nat) : 9 ≤ ta th q := by unfold ta; omega

theorem f32At_put (B : ByteMemory.Bytes) (o : Nat) (x : Float32) : F32At (writeBytes B o (wordBytes 4 (Val.f32Bits x))) o x := by
  unfold F32At
  have := cells_writeBytes_same B o (wordBytes 4 (Val.f32Bits x))
  rwa [wordBytes_length] at this

theorem f32At_keep {B : ByteMemory.Bytes} {o o' : Nat} {x : Float32} (bs : List (BitVec 8))
    (h : o' + 4 ≤ o ∨ o + bs.length ≤ o') (hx : F32At B o' x) : F32At (writeBytes B o bs) o' x := by
  unfold F32At at hx ⊢; rw [cells_writeBytes_other _ _ _ _ _ h, hx]

theorem f32At_put2 (B : ByteMemory.Bytes) (o : Nat) (x y : Float32) :
    F32At (writeBytes B o (wordBytes 4 (Val.f32Bits x) ++ wordBytes 4 (Val.f32Bits y))) o x ∧
      F32At (writeBytes B o (wordBytes 4 (Val.f32Bits x) ++ wordBytes 4 (Val.f32Bits y))) (o + 4) y := by
  unfold F32At
  have h0 := cells_writeBytes_sub B o 0 4 (wordBytes 4 (Val.f32Bits x) ++ wordBytes 4 (Val.f32Bits y))
    (by simp [wordBytes_length])
  have h1 := cells_writeBytes_sub B o 4 4 (wordBytes 4 (Val.f32Bits x) ++ wordBytes 4 (Val.f32Bits y))
    (by simp [wordBytes_length])
  rw [Nat.add_zero] at h0
  refine ⟨h0.trans ?_, h1.trans ?_⟩
  · rw [List.drop_zero, List.take_left' (wordBytes_length 4 _)]
  · rw [List.drop_left' (wordBytes_length 4 _), List.take_of_length_le (by rw [wordBytes_length])]

section Block
variable (C : M1Max.Contract) {L : Launch} {kg ku mt : Nat} {I : In} {out : Nat → BF} {W : Nat → Prop}
  {ge mb base : Nat} {ctx : Ctx}

/-- `aG.thread_elements()[e] = float(codebook[st])` (state in slot `rs`). -/
theorem exec_aElem (hS : Shape L kg ku mt I) {sh : Shared}
    (hm : Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True) sh) (hge : ge ≠ 40 * ctx.group)
    (m e rs : Nat) (he : e < 2) {l : Locals} {reg st : Nat} (hlm : l m = some (.ptr ⟨reg, 0, .vec .f32 2⟩))
    (h11 : l 11 = some (.ptr ⟨7, 0, .scalar .f16⟩)) (hr : l rs = some (u32 st)) (hst : st < 4096)
    (hreg : L.regions reg = some ⟨.thread, 8, 8⟩) (hreg9 : 9 ≤ reg) :
    Exec C ctx [aElem m e rs] l sh .normal l
      (Metal.tput (rdn ctx sh 7 (2 * st) 2) reg (4 * e) (wordBytes 4 (Val.f32Bits (Float16.widen (cbv C st))))) ∧
    Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True)
      (Metal.tput (rdn ctx sh 7 (2 * st) 2) reg (4 * e) (wordBytes 4 (Val.f32Bits (Float16.widen (cbv C st))))) := by
  have hcb := hm.cb st hst trivial
  have hp : (eval C ctx l (.offset (.ptrCast (.scalar .f32) (.local m)) (i32l e))).run sh =
      some (.ptr ⟨reg, ((4 * e : Nat) : Int), .scalar .f32⟩, sh) := by
    have := eval_offset_i32 C (ctx := ctx) (o := 0) (n := e) (eval_ptrCast C (t := .scalar .f32) (eval_local' C hlm sh))
      (eval_lit C _ _ _ _) (by omega)
    rwa [show 0 + e * (Ty.scalar .f32).bytes = 4 * e by simp only [Ty.bytes, Scalar.bytes]; ring] at this
  have hq := eval_ptr_u32 C (ctx := ctx) (eval_local' C h11 sh) (eval_local' C hr sh) (by omega)
  rw [show st * (Ty.scalar .f16).bytes = 2 * st by simp only [Ty.bytes, Scalar.bytes]; ring] at hq
  have hl := load_shared ctx .f16 sh 7 (2 * st) _ (by rw [hm.regions]; exact hS.r7) (by simp) (by decide)
    (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset, Ty.bytes, Scalar.bytes])
  rw [show Scalar.f16.bytes = 2 from rfl, hcb, ofWord_f16] at hl
  have hv : (eval C ctx l (.conv .f32 (.load (.scalar .f16) (.offset (.local 11) (.local rs))))).run sh =
      some (.f32 (Float16.widen (cbv C st)), rdn ctx sh 7 (2 * st) 2) :=
    eval_conv C ((eval_load C _ _ _ _ _ _ _ hq).trans hl) rfl
  have hst' := store_thread ctx .f32 (rdn ctx sh 7 (2 * st) 2) reg (4 * e) 8 8 (.f32 (Float16.widen (cbv C st)))
    _ (by rw [rdn_regions, hm.regions]; exact hreg) (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega)
    (encode_f32 _)
  exact ⟨.store hp hv hst' (.nil _ _),
    (hm.rdg hS ctx 7 (2 * st) 2 (.inl rfl) (fun j _ => tgo_cb hge)).tput _ _ hreg9⟩

/-- `run_state` then `aG.thread_elements()[e] = float(codebook[…])`: the element is the codebook entry of the
run's trellis state at position `j`. -/
theorem exec_stateA (hS : Shape L kg ku mt I) {sh : Shared}
    (hm : Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True) sh) (hge : ge ≠ 40 * ctx.group)
    (K b ws m e : Nat) (hK : GateUp.Width K) (he : e < 2) (hb : 89 < b ∧ ws < b ∧ m < b ∧ 11 < b)
    {l : Locals} {rw ra row run j : Nat} {Codes : ByteMemory.Bytes}
    (hw : l ws = some (.ptr ⟨rw, 0, .scalar .u32⟩)) (hj : l 89 = some (u32 j)) (hj32 : j < 32)
    (hrw : L.regions rw = some ⟨.thread, 4 * (K + 1), 4⟩)
    (hW : GateUp.Words (sh.bytes rw) (K + 1) (GateUp.runWord K Codes row run))
    (hlm : l m = some (.ptr ⟨ra, 0, .vec .f32 2⟩)) (h11 : l 11 = some (.ptr ⟨7, 0, .scalar .f16⟩))
    (hra : L.regions ra = some ⟨.thread, 8, 8⟩) (hra9 : 9 ≤ ra) :
    ∃ l' sh', Exec C ctx (state K b (.local ws) (.local 89) ++ [aElem m e (b + 2)]) l sh .normal l' sh' ∧
      Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True) sh' ∧ (∀ q, (q < b ∨ b + 6 < q) → l' q = l q) ∧
      (∀ ρ, ρ ≠ ra → sh'.bytes ρ = sh.bytes ρ) ∧
      (∀ o, (o + 4 ≤ 4 * e ∨ 4 * e + 4 ≤ o) → cells (sh'.bytes ra) o 4 = cells (sh.bytes ra) o 4) ∧
      F32At (sh'.bytes ra) (4 * e)
        (Float16.widen (cbv C (trellisCode K Codes (GateUp.gbase K row run) (run % 8 * 32 + j)))) := by
  have hK4 := GateUp.width_le hK
  obtain ⟨l₁, hex, h2, hag⟩ := exec_state C (ctx := ctx) K b (by omega) (wE := .local ws) (jE := .local 89) (l := l)
    (sh := sh) (rw := rw) (j := j) (W := GateUp.runWord K Codes row run) (eval_local' C hw sh)
    (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact hj) sh) hj32 (by rw [hm.regions]; exact hrw) hW
    (fun i _ => GateUp.runWord_lt K Codes row run i)
  rw [GateUp.code_run hK Codes row run j hj32] at h2
  generalize hst : trellisCode K Codes (GateUp.gbase K row run) (run % 8 * 32 + j) = st at h2
  have hstl : st < 4096 := by rw [← hst]; exact Nat.mod_lt _ (by decide)
  obtain ⟨hA, hmA⟩ := exec_aElem C hS hm hge m e (b + 2) he (l := l₁) (reg := ra) (st := st)
    (by rw [hag m (by omega)]; exact hlm) (by rw [hag 11 (by omega)]; exact h11) h2 hstl hra hra9
  refine ⟨l₁, _, hex.append hA, hmA, hag, fun ρ hρ => by rw [tput_other _ _ _ hρ, rdn_bytes], fun o ho => ?_, ?_⟩
  · rw [tput_same, rdn_bytes, cells_writeBytes_other _ _ _ _ _ (by rw [wordBytes_length]; omega)]
  · rw [tput_same, rdn_bytes]; exact f32At_put _ _ _

end Block


theorem posPre_eq' (kg ku : Nat) : posPre kg ku =
    [.array 90 false 6 (.vec .f32 2), .array 91 false 7 (.vec .f32 2)] ++
      ((state kg 92 (.local 37) (.local 89) ++ [aElem 90 0 94]) ++
      ((state kg 99 (.local 38) (.local 89) ++ [aElem 90 1 101]) ++
      ((state ku 106 (.local 39) (.local 89) ++ [aElem 91 0 108]) ++
      ((state ku 113 (.local 40) (.local 89) ++ [aElem 91 1 115]) ++ [.set 120 (u32l 0)])))) := rfl

theorem blockBody_eq : blockBody = [.array 121 false 8 (.vec .f32 2),
    .store (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (.local 121)) (i32l 0)) (xsElem 0),
    .store (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (.local 121)) (i32l 1)) (xsElem 1),
    .collective 3 122 (.mma .f32 .f32) .f32
      (.vector .f32 [.load (.vec .f32 2) (.local 90), .load (.vec .f32 2) (.local 121),
        .load (.vec .f32 2) (.offset (.local 27) (.local 120))]) (u16l 0)] ++ blockRest3 := rfl

theorem blockRest3_eq : blockRest3 = .store (.vec .f32 2) (.offset (.local 27) (.local 120)) (.local 122) ::
    .collective 4 123 (.mma .f32 .f32) .f32
      (.vector .f32 [.load (.vec .f32 2) (.local 91), .load (.vec .f32 2) (.local 121),
        .load (.vec .f32 2) (.offset (.local 28) (.local 120))]) (u16l 0) :: blockRest4 := rfl

theorem blockRest4_eq : blockRest4 = [.store (.vec .f32 2) (.offset (.local 28) (.local 120)) (.local 123)] := rfl

theorem xsElem_eq (d : Nat) : xsElem d = .conv .f32 (.load (.scalar .bf16)
    (.offset (.offset (.local 12) (GateUpMmaWide.u64 .mul (toU64 (if d = 0 then
      GateUpMmaWide.u32 .add (GateUpMmaWide.u32 .mul (u32l 8) (.local 120)) (.local 22) else
      GateUpMmaWide.u32 .add (GateUpMmaWide.u32 .add (GateUpMmaWide.u32 .mul (u32l 8) (.local 120)) (.local 22))
        (u32l 1))) (u64l 256)))
      (GateUpMmaWide.u32 .add (GateUpMmaWide.u32 .mul (.local 21) (u32l 32)) (.local 89)))) := rfl

theorem ne_ta {ρ th q : Nat} (h : (ρ - 9) / 9 ≠ th) (hq : q < 9) : ρ ≠ ta th q := by
  intro e; subst e; unfold ta at h; apply h; omega

section Block2
variable (C : M1Max.Contract) {L : Launch} {kg ku mt : Nat} {I : In} {out : Nat → BF} {W : Nat → Prop}
  {ge mb base : Nat} {ctx : Ctx}

/-- A position's statements before its row blocks: `aG`, `aU` from the four runs' states. -/
theorem exec_pos (hS : Shape L kg ku mt I) (hKg : GateUp.Width kg) (hKu : GateUp.Width ku) {sh : Shared}
    (hm : Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True) sh) (hge : ge ≠ 40 * ctx.group)
    {y z s k j : Nat} {i : Fin 32} (hl : Lane ctx y z s i) {l : Locals} (hj32 : j < 32)
    (h11 : l 11 = some (.ptr ⟨7, 0, .scalar .f16⟩))
    (h37 : l 37 = some (.ptr ⟨ta (thOf y z s i) 2, 0, .scalar .u32⟩))
    (h38 : l 38 = some (.ptr ⟨ta (thOf y z s i) 3, 0, .scalar .u32⟩))
    (h39 : l 39 = some (.ptr ⟨ta (thOf y z s i) 4, 0, .scalar .u32⟩))
    (h40 : l 40 = some (.ptr ⟨ta (thOf y z s i) 5, 0, .scalar .u32⟩)) (h89 : l 89 = some (u32 j))
    (hW : WordsOk kg ku I y s i k (tm (thOf y z s i) sh)) :
    ∃ l' sh', Exec C ctx (posPre kg ku) l sh .normal l' sh' ∧
      Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True) sh' ∧
      (∀ q, (q < 90 ∨ 120 < q) → l' q = l q) ∧
      l' 90 = some (.ptr ⟨ta (thOf y z s i) 6, 0, .vec .f32 2⟩) ∧
      l' 91 = some (.ptr ⟨ta (thOf y z s i) 7, 0, .vec .f32 2⟩) ∧ l' 120 = some (u32 0) ∧
      TFrame (thOf y z s i) sh sh' ∧
      (∀ q < 9, q ≠ 6 → q ≠ 7 → sh'.bytes (ta (thOf y z s i) q) = sh.bytes (ta (thOf y z s i) q)) ∧
      AOk C kg ku I y s i (32 * k + j) (tm (thOf y z s i) sh') := by
  obtain ⟨hw2, hw3, hw4, hw5⟩ := hW
  rw [tm_lt _ (by decide)] at hw2 hw3 hw4 hw5
  have e6 := hl.ta 6
  have e7 := hl.ta 7
  have hr6 : L.regions (ctx.threadArray 6) = some ⟨.thread, 8, 8⟩ := by rw [e6]; exact hS.t6 _
  have hr7 : L.regions (ctx.threadArray 7) = some ⟨.thread, 8, 8⟩ := by rw [e7]; exact hS.t7 _
  have n6 : ∀ q, q < 9 → q ≠ 6 → ta (thOf y z s i) q ≠ ctx.threadArray 6 := fun q _ h => by rw [e6]; exact ta_ne h
  have n7 : ∀ q, q < 9 → q ≠ 7 → ta (thOf y z s i) q ≠ ctx.threadArray 7 := fun q _ h => by rw [e7]; exact ta_ne h
  have n67 : ctx.threadArray 6 ≠ ctx.threadArray 7 := by rw [e6, e7]; exact ta_ne (by decide)
  rw [posPre_eq']
  obtain ⟨l₃, sh₃, x₁, hm₃, ag₃, ot₃, kp₃, v₃⟩ := exec_stateA C hS hm hge kg 92 37 90 0 hKg (by decide) (by omega)
    (l := setLocal (setLocal l 90 (.ptr ⟨ctx.threadArray 6, 0, .vec .f32 2⟩)) 91 (.ptr ⟨ctx.threadArray 7, 0, .vec .f32 2⟩))
    (rw := ta (thOf y z s i) 2) (ra := ctx.threadArray 6) (row := 8 * (8 * y + s) + fmOf i) (run := 8 * k + fnOf i)
    (j := j) (Codes := I.Gc) (by simp (disch := omega) only [setLocal_other, h37])
    (by simp (disch := omega) only [setLocal_other, h89]) hj32 (hS.t2 _) hw2
    (by simp (disch := omega) only [setLocal_other, setLocal_same]) (by simp (disch := omega) only [setLocal_other, h11])
    hr6 (by rw [e6]; exact ta_ge _ _)
  obtain ⟨l₄, sh₄, x₂, hm₄, ag₄, ot₄, kp₄, v₄⟩ := exec_stateA C hS hm₃ hge kg 99 38 90 1 hKg (by decide) (by omega)
    (l := l₃) (rw := ta (thOf y z s i) 3) (ra := ctx.threadArray 6) (row := 8 * (8 * y + s) + fmOf i)
    (run := 8 * k + fnOf i + 1) (j := j) (Codes := I.Gc)
    (by rw [ag₃ 38 (by omega)]; simp (disch := omega) only [setLocal_other, h38])
    (by rw [ag₃ 89 (by omega)]; simp (disch := omega) only [setLocal_other, h89]) hj32 (hS.t3 _)
    (by rw [ot₃ _ (n6 3 (by decide) (by decide))]; exact hw3)
    (by rw [ag₃ 90 (by omega)]; simp (disch := omega) only [setLocal_other, setLocal_same])
    (by rw [ag₃ 11 (by omega)]; simp (disch := omega) only [setLocal_other, h11]) hr6 (by rw [e6]; exact ta_ge _ _)
  obtain ⟨l₅, sh₅, x₃, hm₅, ag₅, ot₅, kp₅, v₅⟩ := exec_stateA C hS hm₄ hge ku 106 39 91 0 hKu (by decide) (by omega)
    (l := l₄) (rw := ta (thOf y z s i) 4) (ra := ctx.threadArray 7) (row := 8 * (8 * y + s) + fmOf i)
    (run := 8 * k + fnOf i) (j := j) (Codes := I.Uc)
    (by rw [ag₄ 39 (by omega), ag₃ 39 (by omega)]; simp (disch := omega) only [setLocal_other, h39])
    (by rw [ag₄ 89 (by omega), ag₃ 89 (by omega)]; simp (disch := omega) only [setLocal_other, h89]) hj32 (hS.t4 _)
    (by rw [ot₄ _ (n6 4 (by decide) (by decide)), ot₃ _ (n6 4 (by decide) (by decide))]; exact hw4)
    (by rw [ag₄ 91 (by omega), ag₃ 91 (by omega)]; simp (disch := omega) only [setLocal_same])
    (by rw [ag₄ 11 (by omega), ag₃ 11 (by omega)]; simp (disch := omega) only [setLocal_other, h11]) hr7
    (by rw [e7]; exact ta_ge _ _)
  obtain ⟨l₆, sh₆, x₄, hm₆, ag₆, ot₆, kp₆, v₆⟩ := exec_stateA C hS hm₅ hge ku 113 40 91 1 hKu (by decide) (by omega)
    (l := l₅) (rw := ta (thOf y z s i) 5) (ra := ctx.threadArray 7) (row := 8 * (8 * y + s) + fmOf i)
    (run := 8 * k + fnOf i + 1) (j := j) (Codes := I.Uc)
    (by rw [ag₅ 40 (by omega), ag₄ 40 (by omega), ag₃ 40 (by omega)]; simp (disch := omega) only [setLocal_other, h40])
    (by rw [ag₅ 89 (by omega), ag₄ 89 (by omega), ag₃ 89 (by omega)]; simp (disch := omega) only [setLocal_other, h89])
    hj32 (hS.t5 _)
    (by rw [ot₅ _ (n7 5 (by decide) (by decide)), ot₄ _ (n6 5 (by decide) (by decide)),
      ot₃ _ (n6 5 (by decide) (by decide))]; exact hw5)
    (by rw [ag₅ 91 (by omega), ag₄ 91 (by omega), ag₃ 91 (by omega)]; simp (disch := omega) only [setLocal_same])
    (by rw [ag₅ 11 (by omega), ag₄ 11 (by omega), ag₃ 11 (by omega)]; simp (disch := omega) only [setLocal_other, h11])
    hr7 (by rw [e7]; exact ta_ge _ _)
  have hag : ∀ q, (q < 90 ∨ 120 < q) → l₆ q = l q := fun q hq => by
    rw [ag₆ q (by omega), ag₅ q (by omega), ag₄ q (by omega), ag₃ q (by omega)]
    simp (disch := omega) only [setLocal_other]
  have hoth : ∀ ρ, ρ ≠ ctx.threadArray 6 → ρ ≠ ctx.threadArray 7 → sh₆.bytes ρ = sh.bytes ρ := fun ρ h6 h7 => by
    rw [ot₆ ρ h7, ot₅ ρ h7, ot₄ ρ h6, ot₃ ρ h6]
  refine ⟨setLocal l₆ 120 (u32 0), sh₆, .array (.array (x₁.append (x₂.append (x₃.append (x₄.append
    (.set (eval_u32lit C _ _ 0 (by decide)) (.nil _ _))))))), hm₆,
    fun q hq => by rw [setLocal_other _ _ (by omega), hag q hq],
    by rw [setLocal_other _ _ (by omega), ag₆ 90 (by omega), ag₅ 90 (by omega), ag₄ 90 (by omega),
      ag₃ 90 (by omega), ← e6]; simp (disch := omega) only [setLocal_other, setLocal_same],
    by rw [setLocal_other _ _ (by omega), ag₆ 91 (by omega), ag₅ 91 (by omega), ag₄ 91 (by omega),
      ag₃ 91 (by omega), ← e7]; simp (disch := omega) only [setLocal_same],
    setLocal_same _ _ _, fun ρ _ hρ => hoth ρ (by rw [e6]; exact ne_ta hρ (by decide)) (by rw [e7]; exact ne_ta hρ (by decide)),
    fun q hq h6 h7 => hoth _ (n6 q hq h6) (n7 q hq h7), ?_⟩
  -- The four elements.
  rw [Nat.mul_zero] at v₃ v₅
  rw [Nat.mul_one] at v₄ v₆
  have a0 : F32At (sh₆.bytes (ctx.threadArray 6)) 0 (aReg C kg I.Gc (8 * y + s) (32 * k + j) i 0) := by
    rw [aReg_eq C kg I.Gc _ k j hj32 i 0, show ((0 : Fin 2) : Nat) = 0 from rfl, Nat.add_zero]
    unfold F32At at v₃ ⊢
    rw [ot₆ _ n67, ot₅ _ n67, kp₄ 0 (by omega)]; exact v₃
  have a1 : F32At (sh₆.bytes (ctx.threadArray 6)) 4 (aReg C kg I.Gc (8 * y + s) (32 * k + j) i 1) := by
    rw [aReg_eq C kg I.Gc _ k j hj32 i 1, show ((1 : Fin 2) : Nat) = 1 from rfl]
    unfold F32At at v₄ ⊢
    rw [ot₆ _ n67, ot₅ _ n67]; exact v₄
  have a2 : F32At (sh₆.bytes (ctx.threadArray 7)) 0 (aReg C ku I.Uc (8 * y + s) (32 * k + j) i 0) := by
    rw [aReg_eq C ku I.Uc _ k j hj32 i 0, show ((0 : Fin 2) : Nat) = 0 from rfl, Nat.add_zero]
    unfold F32At at v₅ ⊢
    rw [kp₆ 0 (by omega)]; exact v₅
  have a3 : F32At (sh₆.bytes (ctx.threadArray 7)) 4 (aReg C ku I.Uc (8 * y + s) (32 * k + j) i 1) := by
    rw [aReg_eq C ku I.Uc _ k j hj32 i 1, show ((1 : Fin 2) : Nat) = 1 from rfl]
    exact v₆
  rw [e6] at a0 a1; rw [e7] at a2 a3
  refine ⟨?_, ?_, ?_, ?_⟩ <;> rw [tm_lt _ (by decide)]
  exacts [a0, a1, a2, a3]

/-- `float(xs[ρ][32·fm + j])` (`xsElem`'s load): the staged element. -/
theorem eval_xsAt (hS : Shape L kg ku mt I) {sh : Shared}
    (hm : Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True) sh) {l : Locals} (rE : CExpr) {ρ fm j : Nat}
    (hr : (eval C ctx l rE).run sh = some (u32 ρ, sh)) (h12 : l 12 = some (.ptr ⟨8, 0, .scalar .bf16⟩))
    (h21 : l 21 = some (u32 fm)) (h89 : l 89 = some (u32 j)) (hq : 256 * ρ + (32 * fm + j) < 2048 * mt)
    (hfm : 32 * fm + j < 256) (hmt : mt ≤ 3) :
    (eval C ctx l (.conv .f32 (.load (.scalar .bf16) (.offset (.offset (.local 12)
      (GateUpMmaWide.u64 .mul (toU64 rE) (u64l 256)))
      (GateUpMmaWide.u32 .add (GateUpMmaWide.u32 .mul (.local 21) (u32l 32)) (.local 89)))))).run sh =
      some (.f32 (C.widen (xsv I.r I.X (mb + ρ) (base + (32 * fm + j)))),
        rdn ctx sh 8 (2 * (256 * ρ + (32 * fm + j))) 2) := by
  have hρ : ρ < 2 ^ 32 := by omega
  have hidx : (eval C ctx l (GateUpMmaWide.u64 .mul (toU64 rE) (u64l 256))).run sh = some (u64 (ρ * 256), sh) :=
    eval_int C (by decide) (eval_conv C hr (convert_u64_u32 C ρ hρ)) (eval_lit C _ _ _ _) (binary_mul_u64 C ρ 256)
  have hp1 := eval_offset_u64 C (o := 0) (eval_local' C h12 sh) hidx (by omega)
  have hidx2 : (eval C ctx l (GateUpMmaWide.u32 .add (GateUpMmaWide.u32 .mul (.local 21) (u32l 32)) (.local 89))).run sh =
      some (u32 (fm * 32 + j), sh) :=
    eval_bin_u32 C (eval_bin_u32 C (eval_local' C h21 sh) (eval_u32lit C _ _ 32 (by decide)) (binary_mul_u32 C fm 32))
      (eval_local' C h89 sh) (binary_add_u32 C _ j)
  have hp2 := eval_offset_u32 C hp1 hidx2 (by omega)
  rw [show 0 + ρ * 256 * (Ty.scalar .bf16).bytes + (fm * 32 + j) * (Ty.scalar .bf16).bytes =
    2 * (256 * ρ + (32 * fm + j)) by simp only [Ty.bytes, Scalar.bytes]; ring] at hp2
  have hl := load_shared ctx .bf16 sh 8 (2 * (256 * ρ + (32 * fm + j))) _ (by rw [hm.regions]; exact hS.r8) (by simp)
    (by simp [Scalar.bytes]) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset, Ty.bytes, Scalar.bytes])
  rw [show Scalar.bf16.bytes = 2 from rfl, hm.xs _ hq trivial, stg_val,
    show (256 * ρ + (32 * fm + j)) / 256 = ρ by omega, show (256 * ρ + (32 * fm + j)) % 256 = 32 * fm + j by omega] at hl
  exact eval_conv C ((eval_load C _ _ _ _ _ _ _ hp2).trans hl) rfl

/-- `simdgroup_multiply_accumulate`'s operands `[a, b, acc[bk]]`, loaded from thread memory. -/
theorem eval_mmaArgs {l : Locals} {sh : Shared} (aS accS : Nat) {ra rb racc bk : Nat}
    {a0 a1 b0 b1 c0 c1 : Float32} (hmt : mt ≤ 3)
    (ha : l aS = some (.ptr ⟨ra, 0, .vec .f32 2⟩)) (hb : l 121 = some (.ptr ⟨rb, 0, .vec .f32 2⟩))
    (hc : l accS = some (.ptr ⟨racc, 0, .vec .f32 2⟩)) (h120 : l 120 = some (u32 bk))
    (hra : sh.regions ra = some ⟨.thread, 8, 8⟩) (hrb : sh.regions rb = some ⟨.thread, 8, 8⟩)
    (hracc : sh.regions racc = some ⟨.thread, 8 * mt, 8⟩) (hbk : bk < mt)
    (hA0 : F32At (sh.bytes ra) 0 a0) (hA1 : F32At (sh.bytes ra) 4 a1) (hB0 : F32At (sh.bytes rb) 0 b0)
    (hB1 : F32At (sh.bytes rb) 4 b1) (hC0 : F32At (sh.bytes racc) (8 * bk) c0)
    (hC1 : F32At (sh.bytes racc) (8 * bk + 4) c1) :
    (eval C ctx l (.vector .f32 [.load (.vec .f32 2) (.local aS), .load (.vec .f32 2) (.local 121),
      .load (.vec .f32 2) (.offset (.local accS) (.local 120))])).run sh =
      some (mmaArg .f32 .f32 (.f32 a0, .f32 a1) (.f32 b0, .f32 b1) (.f32 c0, .f32 c1), sh) := by
  have hpc := eval_ptr_u32 C (ctx := ctx) (eval_local' C hc sh) (eval_local' C h120 sh) (by omega)
  rw [show bk * (Ty.vec .f32 2).bytes = 8 * bk by rw [show (Ty.vec .f32 2).bytes = 8 from rfl]; ring] at hpc
  exact eval_vector C (evalList_cons C ((eval_load C _ _ _ _ _ _ _ (eval_local' C ha sh)).trans
      (load_thread_f32x2 ctx sh ra 0 8 8 hra (by decide) (by decide) (by decide) hA0 hA1))
    (evalList_cons C ((eval_load C _ _ _ _ _ _ _ (eval_local' C hb sh)).trans
      (load_thread_f32x2 ctx sh rb 0 8 8 hrb (by decide) (by decide) (by decide) hB0 hB1))
    (evalList_cons C ((eval_load C _ _ _ _ _ _ _ hpc).trans
      (load_thread_f32x2 ctx sh racc (8 * bk) (8 * mt) 8 hracc (by decide) (by omega) (by omega) hC0 hC1))
    (evalList_nil C))))

/-- `accG[bk]` / `accU[bk]` = the collective's result. -/
theorem exec_accStore (accS dS : Nat) {l : Locals} {sh : Shared} {reg bk : Nat} {d0 d1 : Float32} (hmt : mt ≤ 3)
    (hacc : l accS = some (.ptr ⟨reg, 0, .vec .f32 2⟩)) (h120 : l 120 = some (u32 bk))
    (hd : l dS = some (.vec .f32 [.f32 d0, .f32 d1])) (hreg : sh.regions reg = some ⟨.thread, 8 * mt, 8⟩)
    (hbk : bk < mt) :
    Exec C ctx [.store (.vec .f32 2) (.offset (.local accS) (.local 120)) (.local dS)] l sh .normal l
      (Metal.tput sh reg (8 * bk) (wordBytes 4 (Val.f32Bits d0) ++ wordBytes 4 (Val.f32Bits d1))) := by
  have hp := eval_ptr_u32 C (ctx := ctx) (eval_local' C hacc sh) (eval_local' C h120 sh) (by omega)
  rw [show bk * (Ty.vec .f32 2).bytes = 8 * bk by rw [show (Ty.vec .f32 2).bytes = 8 from rfl]; ring] at hp
  exact .store hp (eval_local' C hd sh)
    (store_thread_f32x2 ctx sh reg (8 * bk) (8 * mt) 8 hreg (by decide) (by omega) (by omega) d0 d1) (.nil _ _)

/-- A row block's statements to the gate multiply: `b` from `xs`, then the collective's operands. -/
theorem exec_block (hS : Shape L kg ku mt I) {sh : Shared}
    (hm : Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True) sh) (hge : (ge - 40 * ctx.group) % 2 = 0)
    {y z s k j bk : Nat} {i : Fin 32} (hl : Lane ctx y z s i) {l : Locals} (hj32 : j < 32) (hbk : bk < mt)
    (hmt : mt ≤ 3) (hmb : mb = z * 8 * mt) (hbase : base = 256 * k)
    (h12 : l 12 = some (.ptr ⟨8, 0, .scalar .bf16⟩)) (h21 : l 21 = some (u32 (fmOf i)))
    (h22 : l 22 = some (u32 (fnOf i))) (h27 : l 27 = some (.ptr ⟨ta (thOf y z s i) 0, 0, .vec .f32 2⟩))
    (h89 : l 89 = some (u32 j)) (h90 : l 90 = some (.ptr ⟨ta (thOf y z s i) 6, 0, .vec .f32 2⟩))
    (h120 : l 120 = some (u32 bk)) {a0 a1 c0 c1 : Float32}
    (ha0 : F32At (sh.bytes (ta (thOf y z s i) 6)) 0 a0) (ha1 : F32At (sh.bytes (ta (thOf y z s i) 6)) 4 a1)
    (hc0 : F32At (sh.bytes (ta (thOf y z s i) 0)) (8 * bk) c0)
    (hc1 : F32At (sh.bytes (ta (thOf y z s i) 0)) (8 * bk + 4) c1) :
    ∃ sh', Exec C ctx blockBody l sh (.stop (.collective 3 122 (.mma .f32 .f32) .f32
        (mmaArg .f32 .f32 (.f32 a0, .f32 a1) (.f32 (bReg C I.r I.X (mt * z + bk) (32 * k + j) i 0),
          .f32 (bReg C I.r I.X (mt * z + bk) (32 * k + j) i 1)) (.f32 c0, .f32 c1)) 0) [.block blockRest3])
        (setLocal l 121 (.ptr ⟨ta (thOf y z s i) 8, 0, .vec .f32 2⟩)) sh' ∧
      Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True) sh' ∧ TFrame (thOf y z s i) sh sh' ∧
      (∀ q < 9, q ≠ 8 → sh'.bytes (ta (thOf y z s i) q) = sh.bytes (ta (thOf y z s i) q)) ∧
      BOk C mt I z i (32 * k + j) bk (tm (thOf y z s i) sh') := by
  have e8 := hl.ta 8
  have hfm := fmOf_lt i
  have hfn := fnOf_le i
  have hr8 : L.regions (ctx.threadArray 8) = some ⟨.thread, 8, 8⟩ := by rw [e8]; exact hS.t8 _
  have n8 : ∀ q, q < 9 → q ≠ 8 → ta (thOf y z s i) q ≠ ctx.threadArray 8 := fun q _ h => by rw [e8]; exact ta_ne h
  have hl12 : setLocal l 121 (.ptr ⟨ctx.threadArray 8, 0, .vec .f32 2⟩) 12 = some (.ptr ⟨8, 0, .scalar .bf16⟩) := by
    rw [setLocal_other _ _ (by omega)]; exact h12
  have hl21 : setLocal l 121 (.ptr ⟨ctx.threadArray 8, 0, .vec .f32 2⟩) 21 = some (u32 (fmOf i)) := by
    rw [setLocal_other _ _ (by omega)]; exact h21
  have hl22 : setLocal l 121 (.ptr ⟨ctx.threadArray 8, 0, .vec .f32 2⟩) 22 = some (u32 (fnOf i)) := by
    rw [setLocal_other _ _ (by omega)]; exact h22
  have hl89 : setLocal l 121 (.ptr ⟨ctx.threadArray 8, 0, .vec .f32 2⟩) 89 = some (u32 j) := by
    rw [setLocal_other _ _ (by omega)]; exact h89
  have hl120 : setLocal l 121 (.ptr ⟨ctx.threadArray 8, 0, .vec .f32 2⟩) 120 = some (u32 bk) := by
    rw [setLocal_other _ _ (by omega)]; exact h120
  have hl121 : setLocal l 121 (.ptr ⟨ctx.threadArray 8, 0, .vec .f32 2⟩) 121 =
      some (.ptr ⟨ctx.threadArray 8, 0, .vec .f32 2⟩) := setLocal_same _ _ _
  have hρ0 : (eval C ctx (setLocal l 121 (.ptr ⟨ctx.threadArray 8, 0, .vec .f32 2⟩))
      (GateUpMmaWide.u32 .add (GateUpMmaWide.u32 .mul (u32l 8) (.local 120)) (.local 22))).run sh =
      some (u32 (8 * bk + fnOf i), sh) :=
    eval_bin_u32 C (eval_bin_u32 C (eval_u32lit C _ _ 8 (by decide)) (eval_local' C hl120 sh) (binary_mul_u32 C 8 bk))
      (eval_local' C hl22 sh) (binary_add_u32 C _ _)
  have hx0 := eval_xsAt C hS hm _ hρ0 hl12 hl21 hl89 (by omega) (by omega) hmt
  have hp0 : (eval C ctx (setLocal l 121 (.ptr ⟨ctx.threadArray 8, 0, .vec .f32 2⟩))
      (.offset (.ptrCast (.scalar .f32) (.local 121)) (i32l 0))).run sh =
      some (.ptr ⟨ctx.threadArray 8, ((0 : Nat) : Int), .scalar .f32⟩, sh) :=
    eval_offset_i32 C (o := 0) (n := 0) (eval_ptrCast C (t := .scalar .f32) (eval_local' C hl121 sh))
      (eval_lit C _ _ _ _) (by decide)
  have hm0 := hm.rdg hS ctx 8 (2 * (256 * (8 * bk + fnOf i) + (32 * fmOf i + j))) 2 (.inr rfl)
    (fun _ _ => tgo_xs hge)
  have hs0 := store_thread ctx .f32 (rdn ctx sh 8 (2 * (256 * (8 * bk + fnOf i) + (32 * fmOf i + j))) 2)
    (ctx.threadArray 8) 0 8 8 (.f32 (C.widen (xsv I.r I.X (mb + (8 * bk + fnOf i)) (base + (32 * fmOf i + j))))) _ (by rw [rdn_regions, hm.regions]; exact hr8) (by decide) (by decide) (by decide)
    (encode_f32 (C.widen (xsv I.r I.X (mb + (8 * bk + fnOf i)) (base + (32 * fmOf i + j)))))
  generalize hsh₁ : Metal.tput (rdn ctx sh 8 (2 * (256 * (8 * bk + fnOf i) + (32 * fmOf i + j))) 2) (ctx.threadArray 8) 0
    (wordBytes 4 (Val.f32Bits (C.widen (xsv I.r I.X (mb + (8 * bk + fnOf i)) (base + (32 * fmOf i + j)))))) = sh₁ at hs0
  have hm₁ : Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True) sh₁ := by
    rw [← hsh₁]; exact hm0.tput _ _ (by rw [e8]; exact ta_ge _ _)
  have hρ1 : (eval C ctx (setLocal l 121 (.ptr ⟨ctx.threadArray 8, 0, .vec .f32 2⟩))
      (GateUpMmaWide.u32 .add (GateUpMmaWide.u32 .add (GateUpMmaWide.u32 .mul (u32l 8) (.local 120)) (.local 22))
        (u32l 1))).run sh₁ = some (u32 (8 * bk + fnOf i + 1), sh₁) :=
    eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_u32lit C _ _ 8 (by decide)) (eval_local' C hl120 sh₁)
      (binary_mul_u32 C 8 bk)) (eval_local' C hl22 sh₁) (binary_add_u32 C _ _)) (eval_u32lit C _ _ 1 (by decide))
      (binary_add_u32 C _ 1)
  have hx1 := eval_xsAt C hS hm₁ _ hρ1 hl12 hl21 hl89 (by omega) (by omega) hmt
  have hp1 : (eval C ctx (setLocal l 121 (.ptr ⟨ctx.threadArray 8, 0, .vec .f32 2⟩))
      (.offset (.ptrCast (.scalar .f32) (.local 121)) (i32l 1))).run sh₁ =
      some (.ptr ⟨ctx.threadArray 8, ((4 : Nat) : Int), .scalar .f32⟩, sh₁) :=
    eval_offset_i32 C (o := 0) (n := 1) (eval_ptrCast C (t := .scalar .f32) (eval_local' C hl121 sh₁))
      (eval_lit C _ _ _ _) (by decide)
  have hm1 := hm₁.rdg hS ctx 8 (2 * (256 * (8 * bk + fnOf i + 1) + (32 * fmOf i + j))) 2 (.inr rfl)
    (fun _ _ => tgo_xs hge)
  have hs1 := store_thread ctx .f32 (rdn ctx sh₁ 8 (2 * (256 * (8 * bk + fnOf i + 1) + (32 * fmOf i + j))) 2)
    (ctx.threadArray 8) 4 8 8 (.f32 (C.widen (xsv I.r I.X (mb + (8 * bk + fnOf i + 1)) (base + (32 * fmOf i + j))))) _ (by rw [rdn_regions, hm₁.regions]; exact hr8) (by decide) (by decide) (by decide)
    (encode_f32 (C.widen (xsv I.r I.X (mb + (8 * bk + fnOf i + 1)) (base + (32 * fmOf i + j)))))
  generalize hsh₂ : Metal.tput (rdn ctx sh₁ 8 (2 * (256 * (8 * bk + fnOf i + 1) + (32 * fmOf i + j))) 2)
    (ctx.threadArray 8) 4
    (wordBytes 4 (Val.f32Bits (C.widen (xsv I.r I.X (mb + (8 * bk + fnOf i + 1)) (base + (32 * fmOf i + j)))))) = sh₂
    at hs1
  have hm₂ : Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True) sh₂ := by
    rw [← hsh₂]; exact hm1.tput _ _ (by rw [e8]; exact ta_ge _ _)
  have hoth : ∀ ρ, ρ ≠ ctx.threadArray 8 → sh₂.bytes ρ = sh.bytes ρ := fun ρ h => by
    rw [← hsh₂, tput_other _ _ _ h, rdn_bytes, ← hsh₁, tput_other _ _ _ h, rdn_bytes]
  have hb0 : F32At (sh₂.bytes (ctx.threadArray 8)) 0 (bReg C I.r I.X (mt * z + bk) (32 * k + j) i 0) := by
    rw [bReg_eq C I.r I.X mt z bk k j hj32 i 0, show ((0 : Fin 2) : Nat) = 0 from rfl, Nat.add_zero, ← hmb, ← hbase,
      ← hsh₂, tput_same, rdn_bytes]
    refine f32At_keep _ (by rw [wordBytes_length]; omega) ?_
    rw [← hsh₁, tput_same, rdn_bytes]; exact f32At_put _ _ _
  have hb1 : F32At (sh₂.bytes (ctx.threadArray 8)) 4 (bReg C I.r I.X (mt * z + bk) (32 * k + j) i 1) := by
    rw [bReg_eq C I.r I.X mt z bk k j hj32 i 1, show ((1 : Fin 2) : Nat) = 1 from rfl, ← hmb, ← hbase,
      ← hsh₂, tput_same, rdn_bytes]
    exact f32At_put _ _ _
  have hcoll := eval_mmaArgs C (ctx := ctx) (l := setLocal l 121 (.ptr ⟨ctx.threadArray 8, 0, .vec .f32 2⟩))
    (sh := sh₂) 90 27 hmt (by rw [setLocal_other _ _ (by omega)]; exact h90) hl121
    (by rw [setLocal_other _ _ (by omega)]; exact h27) hl120 (by rw [hm₂.regions]; exact hS.t6 _)
    (by rw [hm₂.regions]; exact hr8) (by rw [hm₂.regions]; exact hS.t0 _) hbk
    (by rw [hoth _ (n8 6 (by decide) (by decide))]; exact ha0) (by rw [hoth _ (n8 6 (by decide) (by decide))]; exact ha1)
    hb0 hb1 (by rw [hoth _ (n8 0 (by decide) (by decide))]; exact hc0)
    (by rw [hoth _ (n8 0 (by decide) (by decide))]; exact hc1)
  have hex : Exec C ctx blockBody l sh (.stop (.collective 3 122 (.mma .f32 .f32) .f32
        (mmaArg .f32 .f32 (.f32 a0, .f32 a1) (.f32 (bReg C I.r I.X (mt * z + bk) (32 * k + j) i 0),
          .f32 (bReg C I.r I.X (mt * z + bk) (32 * k + j) i 1)) (.f32 c0, .f32 c1)) 0) [.block blockRest3])
        (setLocal l 121 (.ptr ⟨ctx.threadArray 8, 0, .vec .f32 2⟩)) sh₂ := by
    rw [blockBody_eq]
    refine .array (.store hp0 (by rw [xsElem_eq 0]; exact hx0) hs0
      (.store hp1 (by rw [xsElem_eq 1]; exact hx1) hs1 (.collective hcoll (eval_lit C _ _ _ _) rfl)))
  rw [e8] at hex
  refine ⟨sh₂, hex, hm₂, fun ρ _ hρ => hoth ρ (by rw [e8]; exact ne_ta hρ (by decide)),
    fun q hq h8 => hoth _ (n8 q hq h8), ⟨?_, ?_⟩⟩ <;> rw [tm_lt _ (by decide), ← e8]
  exacts [hb0, hb1]

end Block2


section Ops
variable (C : M1Max.Contract) (kg ku mt : Nat) (I : In) (y z s : Nat)

/-- Lane `i`'s operands `[a, b, acc[bk]]` of the gate and up multiplies of row block `bk` at position `n`. -/
def opsG (n bk : Nat) (i : Fin 32) : Val :=
  mmaArg .f32 .f32 (.f32 (aReg C kg I.Gc (8 * y + s) n i 0), .f32 (aReg C kg I.Gc (8 * y + s) n i 1))
    (.f32 (bReg C I.r I.X (mt * z + bk) n i 0), .f32 (bReg C I.r I.X (mt * z + bk) n i 1))
    (.f32 (AG C kg mt I y z s bk n i 0), .f32 (AG C kg mt I y z s bk n i 1))
def opsU (n bk : Nat) (i : Fin 32) : Val :=
  mmaArg .f32 .f32 (.f32 (aReg C ku I.Uc (8 * y + s) n i 0), .f32 (aReg C ku I.Uc (8 * y + s) n i 1))
    (.f32 (bReg C I.r I.X (mt * z + bk) n i 0), .f32 (bReg C I.r I.X (mt * z + bk) n i 1))
    (.f32 (AU C ku mt I y z s bk n i 0), .f32 (AU C ku mt I y z s bk n i 1))

end Ops

/-- Lane `i` at the first barrier of step `k` (resumed: the staging). -/
def AtB1 (kg ku mt r y z s : Nat) (i : Fin 32) (k : Nat) (ctx : Ctx) (t : Thread) : Prop :=
  t.ctx = ctx ∧ t.frames = .block (stepRest1 kg ku mt) :: K1 kg ku mt ∧ Fix kg ku mt r y z s i t.locals ∧
    t.locals 30 = some (u32 (256 * k))
/-- At the second barrier (resumed: the positions). -/
def AtB2 (kg ku mt r y z s : Nat) (i : Fin 32) (k : Nat) (ctx : Ctx) (t : Thread) : Prop :=
  t.ctx = ctx ∧ t.frames = .block (stepRest2 kg ku mt) :: K1 kg ku mt ∧ Fix kg ku mt r y z s i t.locals ∧
    t.locals 30 = some (u32 (256 * k))
/-- At the gate (`ph = 0`) or up (`ph = 1`) multiply of row block `bk`, position `j` of step `k`. -/
def AtC (kg ku mt r y z s : Nat) (i : Fin 32) (k j bk ph : Nat) (ctx : Ctx) (t : Thread) : Prop :=
  t.ctx = ctx ∧ t.frames = .block (if ph = 0 then blockRest3 else blockRest4) :: Kb kg ku mt ∧
    Loc kg ku mt r y z s i k j bk t.locals

section Lane2
variable (C : M1Max.Contract) {L : Launch} {kg ku mt : Nat} {I : In} {out : Nat → BF} {W : Nat → Prop} {ctx : Ctx}

/-- After the second barrier, before the positions: `runA`, the run arrays, the four runs, `j = 0`. -/
theorem exec_pre2 (hS : Shape L kg ku mt I) (hKg : GateUp.Width kg) (hKu : GateUp.Width ku) {ge mb base : Nat}
    {sh : Shared} (hm : Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True) sh)
    {y z s k : Nat} {i : Fin 32} (hl : Lane ctx y z s i) (hk : k < 20) {l : Locals}
    (hF : Fix kg ku mt I.r y z s i l) (h30 : l 30 = some (u32 (256 * k))) :
    ∃ l' sh', Exec C ctx (decl2 ++ runs kg ku ++ [.set 89 (u32l 0)]) l sh .normal l' sh' ∧
      Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True) sh' ∧ (∀ q, (q < 36 ∨ 89 < q) → l' q = l q) ∧
      l' 37 = some (.ptr ⟨ta (thOf y z s i) 2, 0, .scalar .u32⟩) ∧
      l' 38 = some (.ptr ⟨ta (thOf y z s i) 3, 0, .scalar .u32⟩) ∧
      l' 39 = some (.ptr ⟨ta (thOf y z s i) 4, 0, .scalar .u32⟩) ∧
      l' 40 = some (.ptr ⟨ta (thOf y z s i) 5, 0, .scalar .u32⟩) ∧ l' 89 = some (u32 0) ∧
      TFrame (thOf y z s i) sh sh' ∧
      (∀ q < 9, (q < 2 ∨ 5 < q) → sh'.bytes (ta (thOf y z s i) q) = sh.bytes (ta (thOf y z s i) q)) ∧
      WordsOk kg ku I y s i k (tm (thOf y z s i) sh') := by
  have hfn := fnOf_le i
  have hfm := fmOf_lt i
  have hy := hl.hy; have hs := hl.hs
  have hrow : 8 * (8 * y + s) + fmOf i < 17408 := by omega
  have e2 := hl.ta 2; have e3 := hl.ta 3; have e4 := hl.ta 4; have e5 := hl.ta 5
  have h36 : (eval C ctx l (GateUpMmaWide.u32 .add (GateUpMmaWide.u32 .div (.local 30) (u32l 32)) (.local 22))).run sh =
      some (u32 (8 * k + fnOf i), sh) := by
    have := eval_bin_u32 C (ctx := ctx) (op := .add) (site := 0) (eval_bin_u32 C (op := .div) (site := 0)
      (eval_local' C h30 sh) (eval_u32lit C _ _ 32 (by decide)) (binary_div_u32 C (256 * k) 32 (by omega) (by decide)
        (by decide))) (eval_local' C hF.l22 sh) (binary_add_u32 C _ _)
    rwa [show 256 * k / 32 + fnOf i = 8 * k + fnOf i by omega] at this
  let L₅ : Locals := setLocal (setLocal (setLocal (setLocal (setLocal l 36 (u32 (8 * k + fnOf i)))
      37 (.ptr ⟨ctx.threadArray 2, 0, .scalar .u32⟩)) 38 (.ptr ⟨ctx.threadArray 3, 0, .scalar .u32⟩))
      39 (.ptr ⟨ctx.threadArray 4, 0, .scalar .u32⟩)) 40 (.ptr ⟨ctx.threadArray 5, 0, .scalar .u32⟩)
  have hd : Exec C ctx decl2 l sh .normal L₅ sh :=
    .set h36 (.array (.array (.array (.array (.nil _ _)))))
  obtain ⟨l₆, sh₆, x₁, hm₆, -, ot₆, w₆, ag₆⟩ := exec_run C (ctx := ctx) kg 41 hKg (rcE := .local 24)
    (runE := .local 36) (wE := .local 37) (l := L₅) (sh := sh) (rc := 2) (rwr := ctx.threadArray 2)
    (row := 8 * (8 * y + s) + fmOf i) (run := 8 * k + fnOf i) (sizeC := GateUp.codesBytes kg) (alC := I.ag) (B := I.Gc)
    (Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True))
    (fun sh o h => h.rd hS ctx 2 o 4 (by decide)) (fun sh o bs h => h.tput o bs (by rw [e2]; exact ta_ge _ _))
    (fun sh h => ⟨by rw [h.regions]; exact hS.r2, h.gc⟩) hS.ag (fun sh h => by rw [h.regions, e2]; exact hS.t2 _)
    (eval_local' C (by simp (disch := omega) only [L₅, setLocal_other, hF.l24]) sh)
    (fun l' hl' => eval_local' C (by rw [hl' 36 (by omega)]; simp (disch := omega) only [L₅, setLocal_other, setLocal_same]) sh)
    (fun l' hl' => eval_local' C (by rw [hl' 37 (by omega)]; simp (disch := omega) only [L₅, setLocal_other, setLocal_same]) sh)
    (by omega) hrow (by unfold GateUp.codesBytes; omega) hm
  obtain ⟨l₇, sh₇, x₂, hm₇, -, ot₇, w₇, ag₇⟩ := exec_run C (ctx := ctx) kg 53 hKg (rcE := .local 24)
    (runE := GateUpMmaWide.u32 .add (.local 36) (u32l 1)) (wE := .local 38) (l := l₆) (sh := sh₆) (rc := 2)
    (rwr := ctx.threadArray 3) (row := 8 * (8 * y + s) + fmOf i) (run := 8 * k + fnOf i + 1)
    (sizeC := GateUp.codesBytes kg) (alC := I.ag) (B := I.Gc)
    (Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True))
    (fun sh o h => h.rd hS ctx 2 o 4 (by decide)) (fun sh o bs h => h.tput o bs (by rw [e3]; exact ta_ge _ _))
    (fun sh h => ⟨by rw [h.regions]; exact hS.r2, h.gc⟩) hS.ag (fun sh h => by rw [h.regions, e3]; exact hS.t3 _)
    (eval_local' C (by rw [ag₆ 24 (by omega)]; simp (disch := omega) only [L₅, setLocal_other, hF.l24]) sh₆)
    (fun l' hl' => eval_bin_u32 C (eval_local' C (by rw [hl' 36 (by omega), ag₆ 36 (by omega)]; simp (disch := omega) only [L₅, setLocal_other, setLocal_same]) sh₆) (eval_u32lit C _ _ 1 (by decide))
      (binary_add_u32 C _ 1))
    (fun l' hl' => eval_local' C (by rw [hl' 38 (by omega), ag₆ 38 (by omega)]; simp (disch := omega) only [L₅, setLocal_other, setLocal_same]) sh₆)
    (by omega) hrow (by unfold GateUp.codesBytes; omega) hm₆
  obtain ⟨l₈, sh₈, x₃, hm₈, -, ot₈, w₈, ag₈⟩ := exec_run C (ctx := ctx) ku 65 hKu (rcE := .local 25)
    (runE := .local 36) (wE := .local 39) (l := l₇) (sh := sh₇) (rc := 4) (rwr := ctx.threadArray 4)
    (row := 8 * (8 * y + s) + fmOf i) (run := 8 * k + fnOf i) (sizeC := GateUp.codesBytes ku) (alC := I.au) (B := I.Uc)
    (Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True))
    (fun sh o h => h.rd hS ctx 4 o 4 (by decide)) (fun sh o bs h => h.tput o bs (by rw [e4]; exact ta_ge _ _))
    (fun sh h => ⟨by rw [h.regions]; exact hS.r4, h.uc⟩) hS.au (fun sh h => by rw [h.regions, e4]; exact hS.t4 _)
    (eval_local' C (by rw [ag₇ 25 (by omega), ag₆ 25 (by omega)]; simp (disch := omega) only [L₅, setLocal_other, hF.l25]) sh₇)
    (fun l' hl' => eval_local' C (by rw [hl' 36 (by omega), ag₇ 36 (by omega), ag₆ 36 (by omega)]; simp (disch := omega) only [L₅, setLocal_other, setLocal_same]) sh₇)
    (fun l' hl' => eval_local' C (by rw [hl' 39 (by omega), ag₇ 39 (by omega), ag₆ 39 (by omega)]; simp (disch := omega) only [L₅, setLocal_other, setLocal_same]) sh₇)
    (by omega) hrow (by unfold GateUp.codesBytes; omega) hm₇
  obtain ⟨l₉, sh₉, x₄, hm₉, -, ot₉, w₉, ag₉⟩ := exec_run C (ctx := ctx) ku 77 hKu (rcE := .local 25)
    (runE := GateUpMmaWide.u32 .add (.local 36) (u32l 1)) (wE := .local 40) (l := l₈) (sh := sh₈) (rc := 4)
    (rwr := ctx.threadArray 5) (row := 8 * (8 * y + s) + fmOf i) (run := 8 * k + fnOf i + 1)
    (sizeC := GateUp.codesBytes ku) (alC := I.au) (B := I.Uc)
    (Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True))
    (fun sh o h => h.rd hS ctx 4 o 4 (by decide)) (fun sh o bs h => h.tput o bs (by rw [e5]; exact ta_ge _ _))
    (fun sh h => ⟨by rw [h.regions]; exact hS.r4, h.uc⟩) hS.au (fun sh h => by rw [h.regions, e5]; exact hS.t5 _)
    (eval_local' C (by rw [ag₈ 25 (by omega), ag₇ 25 (by omega), ag₆ 25 (by omega)]; simp (disch := omega) only [L₅, setLocal_other, hF.l25]) sh₈)
    (fun l' hl' => eval_bin_u32 C (eval_local' C (by rw [hl' 36 (by omega), ag₈ 36 (by omega), ag₇ 36 (by omega), ag₆ 36 (by omega)]; simp (disch := omega) only [L₅, setLocal_other, setLocal_same]) sh₈)
      (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C _ 1))
    (fun l' hl' => eval_local' C (by rw [hl' 40 (by omega), ag₈ 40 (by omega), ag₇ 40 (by omega), ag₆ 40 (by omega)]; simp (disch := omega) only [L₅, setLocal_same]) sh₈)
    (by omega) hrow (by unfold GateUp.codesBytes; omega) hm₈
  have hag : ∀ q, (q < 36 ∨ 88 < q) → l₉ q = l q := fun q hq => by
    rw [ag₉ q (by omega), ag₈ q (by omega), ag₇ q (by omega), ag₆ q (by omega)]
    simp (disch := omega) only [L₅, setLocal_other]
  have hp : ∀ q, 37 ≤ q → q ≤ 40 → l₉ q = L₅ q := fun q h1 h2 => by
    rw [ag₉ q (by omega), ag₈ q (by omega), ag₇ q (by omega), ag₆ q (by omega)]
  have n : ∀ {q q' : Nat}, q < 9 → q' < 9 → q ≠ q' → ta (thOf y z s i) q ≠ ctx.threadArray q' :=
    fun _ _ hne => by rw [hl.ta]; exact ta_ne hne
  have hoth : ∀ ρ, (∀ q, 2 ≤ q → q ≤ 5 → ρ ≠ ctx.threadArray q) → sh₉.bytes ρ = sh.bytes ρ := fun ρ h => by
    rw [ot₉ ρ (h 5 (by decide) (by decide)), ot₈ ρ (h 4 (by decide) (by decide)), ot₇ ρ (h 3 (by decide) (by decide)),
      ot₆ ρ (h 2 (by decide) (by decide))]
  refine ⟨setLocal l₉ 89 (u32 0), sh₉,
    (hd.append (((x₁.append x₂).append x₃).append x₄)).append (.set (eval_u32lit C _ _ 0 (by decide)) (.nil _ _)), hm₉,
    fun q hq => by rw [setLocal_other _ _ (by omega), hag q (by omega)],
    by rw [setLocal_other _ _ (by omega), hp 37 (by omega) (by omega), ← e2]; simp (disch := omega) only [L₅, setLocal_other, setLocal_same],
    by rw [setLocal_other _ _ (by omega), hp 38 (by omega) (by omega), ← e3]; simp (disch := omega) only [L₅, setLocal_other, setLocal_same],
    by rw [setLocal_other _ _ (by omega), hp 39 (by omega) (by omega), ← e4]; simp (disch := omega) only [L₅, setLocal_other, setLocal_same],
    by rw [setLocal_other _ _ (by omega), hp 40 (by omega) (by omega), ← e5]; simp (disch := omega) only [L₅, setLocal_same], setLocal_same _ _ _,
    fun ρ _ hρ => hoth ρ (fun q h1 h2 => by rw [hl.ta]; exact ne_ta hρ (by omega)),
    fun q hq hq' => hoth _ (fun q' h1 h2 => n hq (by omega) (by omega)), ?_, ?_, ?_, ?_⟩
  · rw [tm_lt _ (by decide), ← e2, ot₉ _ (by rw [e2, e5]; exact ta_ne (by decide)), ot₈ _ (by rw [e2, e4]; exact ta_ne (by decide)),
      ot₇ _ (by rw [e2, e3]; exact ta_ne (by decide))]; exact w₆
  · rw [tm_lt _ (by decide), ← e3, ot₉ _ (by rw [e3, e5]; exact ta_ne (by decide)), ot₈ _ (by rw [e3, e4]; exact ta_ne (by decide))]
    exact w₇
  · rw [tm_lt _ (by decide), ← e4, ot₉ _ (by rw [e4, e5]; exact ta_ne (by decide))]; exact w₈
  · rw [tm_lt _ (by decide), ← e5]; exact w₉

end Lane2


section Lane3
variable (C : M1Max.Contract) {L : Launch} {kg ku mt : Nat} {I : In} {out : Nat → BF} {W : Nat → Prop} {ctx : Ctx}

theorem pg_zero (b n : Nat) : pg 0 b n = n := by simp [pg]

/-- A position's body to its first row block's gate multiply: `aG`, `aU`, `bk = 0`, `b`. -/
theorem exec_position (hS : Shape L kg ku mt I) (hKg : GateUp.Width kg) (hKu : GateUp.Width ku)
    (hmt : 1 ≤ mt ∧ mt ≤ 3) {y z s k j : Nat} {i : Fin 32} (hl : Lane ctx y z s i) (hk : k < 20) (hj32 : j < 32)
    {sh : Shared}
    (hm : Mem C L I mt out W (40 * (y + 272 * z) + 2 * k + 2) (fun _ => True) (z * 8 * mt) (256 * k) (fun _ => True) sh)
    {l : Locals} (hF : Fix kg ku mt I.r y z s i l) (h30 : l 30 = some (u32 (256 * k)))
    (h37 : l 37 = some (.ptr ⟨ta (thOf y z s i) 2, 0, .scalar .u32⟩))
    (h38 : l 38 = some (.ptr ⟨ta (thOf y z s i) 3, 0, .scalar .u32⟩))
    (h39 : l 39 = some (.ptr ⟨ta (thOf y z s i) 4, 0, .scalar .u32⟩))
    (h40 : l 40 = some (.ptr ⟨ta (thOf y z s i) 5, 0, .scalar .u32⟩)) (h89 : l 89 = some (u32 j))
    (hW : WordsOk kg ku I y s i k (tm (thOf y z s i) sh))
    (hacc : AccOk mt i (fun b => AG C kg mt I y z s b (32 * k + j)) (fun b => AU C ku mt I y z s b (32 * k + j))
      (tm (thOf y z s i) sh)) :
    ∃ l' sh', Exec C ctx (positionBody kg ku mt) l sh
        (.stop (.collective 3 122 (.mma .f32 .f32) .f32 (opsG C kg mt I y z s (32 * k + j) 0 i) 0)
          ([.block blockRest3] ++ [.loop (bkCond mt) (incr 120) blockBody, .block []])) l' sh' ∧
      Mem C L I mt out W (40 * (y + 272 * z) + 2 * k + 2) (fun _ => True) (z * 8 * mt) (256 * k) (fun _ => True) sh' ∧
      TFrame (thOf y z s i) sh sh' ∧ OwnC C kg ku mt I y z s i k j 0 0 (tm (thOf y z s i) sh') ∧
      Loc kg ku mt I.r y z s i k j 0 l' ∧ ∀ q, (q < 90 ∨ 121 < q) → l' q = l q := by
  have hgrp := hl.group
  have hge2 : 40 * (y + 272 * z) + 2 * k + 2 ≠ 40 * ctx.group := by rw [hgrp]; omega
  have hge3 : (40 * (y + 272 * z) + 2 * k + 2 - 40 * ctx.group) % 2 = 0 := by rw [hgrp]; omega
  obtain ⟨l₂, sh₂, x₂, hm₂, ag₂, h90, h91, h120, tf₂, kp₂, hA₂⟩ := exec_pos C hS hKg hKu hm hge2 hl (k := k) (l := l)
    hj32 hF.l11 h37 h38 h39 h40 h89 hW
  obtain ⟨hA0, hA1, hA2, hA3⟩ := hA₂
  rw [tm_lt _ (by decide)] at hA0 hA1 hA2 hA3
  obtain ⟨hc0, hc1, -, -⟩ := hacc 0 hmt.1
  rw [tm_lt _ (by decide)] at hc0 hc1
  rw [← kp₂ 0 (by decide) (by decide) (by decide)] at hc0 hc1
  obtain ⟨sh₃, x₃, hm₃, tf₃, kp₃, hB₃⟩ := exec_block C hS hm₂ hge3 hl (k := k) (j := j) (bk := 0) (l := l₂) hj32
    hmt.1 hmt.2 rfl rfl (by rw [ag₂ 12 (by omega)]; exact hF.l12) (by rw [ag₂ 21 (by omega)]; exact hF.l21)
    (by rw [ag₂ 22 (by omega)]; exact hF.l22) (by rw [ag₂ 27 (by omega)]; exact hF.l27)
    (by rw [ag₂ 89 (by omega)]; exact h89) h90 h120 hA0 hA1 hc0 hc1
  have hcb : (eval C ctx l₂ (bkCond mt)).run sh₂ = some (.bool true, sh₂) := by
    have := eval_lt_u32 C (ctx := ctx) (sh := sh₂) (b := mt) h120 (by decide) (by omega)
    rwa [decide_eq_true (show 0 < mt by omega)] at this
  have hex : Exec C ctx (positionBody kg ku mt) l sh
      (.stop (.collective 3 122 (.mma .f32 .f32) .f32 (opsG C kg mt I y z s (32 * k + j) 0 i) 0)
        ([.block blockRest3] ++ [.loop (bkCond mt) (incr 120) blockBody, .block []]))
      (setLocal l₂ 121 (.ptr ⟨ta (thOf y z s i) 8, 0, .vec .f32 2⟩)) sh₃ := by
    rw [positionBody_eq]
    exact x₂.append (.loop_stop hcb x₃)
  have hag : ∀ q, (q < 90 ∨ 121 < q) → setLocal l₂ 121 (.ptr ⟨ta (thOf y z s i) 8, 0, .vec .f32 2⟩) q = l q :=
    fun q hq => by rw [setLocal_other _ _ (by omega), ag₂ q (by omega)]
  have kp : ∀ q, q < 9 → q < 6 → sh₃.bytes (ta (thOf y z s i) q) = sh.bytes (ta (thOf y z s i) q) := fun q h1 h2 => by
    rw [kp₃ q h1 (by omega), kp₂ q h1 (by omega) (by omega)]
  refine ⟨_, sh₃, hex, hm₃, fun ρ h9 hρ => by rw [tf₃ ρ h9 hρ, tf₂ ρ h9 hρ], ⟨fun b hb => ?_, ?_, ?_, hB₃⟩, ?_, hag⟩
  · obtain ⟨g0, g1, u0, u1⟩ := hacc b hb
    simp only [pg_zero]
    rw [tm_lt _ (by decide)] at g0 g1 u0 u1; rw [tm_lt _ (by decide), tm_lt _ (by decide)]
    rw [kp 0 (by decide) (by decide), kp 1 (by decide) (by decide)]
    exact ⟨g0, g1, u0, u1⟩
  · obtain ⟨w2, w3, w4, w5⟩ := hW
    rw [tm_lt _ (by decide)] at w2 w3 w4 w5
    refine ⟨?_, ?_, ?_, ?_⟩ <;> rw [tm_lt _ (by decide), kp _ (by decide) (by decide)]
    exacts [w2, w3, w4, w5]
  · refine ⟨?_, ?_, ?_, ?_⟩ <;> rw [tm_lt _ (by decide), kp₃ _ (by decide) (by decide)]
    exacts [hA0, hA1, hA2, hA3]
  · exact ⟨hF.of_eq fun q hq => hag q (by omega), by rw [hag 30 (by omega)]; exact h30,
      by rw [hag 37 (by omega)]; exact h37, by rw [hag 38 (by omega)]; exact h38, by rw [hag 39 (by omega)]; exact h39,
      by rw [hag 40 (by omega)]; exact h40, by rw [setLocal_other _ _ (by omega), ag₂ 89 (by omega)]; exact h89,
      by rw [setLocal_other _ _ (by omega)]; exact h90, by rw [setLocal_other _ _ (by omega)]; exact h91,
      by rw [setLocal_other _ _ (by omega)]; exact h120, setLocal_same _ _ _⟩

/-- Resumed after the second barrier of step `k`: to the first gate multiply. -/
theorem lane_B2 (hS : Shape L kg ku mt I) (hKg : GateUp.Width kg) (hKu : GateUp.Width ku) (hmt : 1 ≤ mt ∧ mt ≤ 3)
    {y z s k : Nat} {i : Fin 32} (hl : Lane ctx y z s i) (hk : k < 20) {t : Thread}
    (ht : AtB2 kg ku mt I.r y z s i k ctx t) {sh : Shared}
    (hm : Mem C L I mt out W (40 * (y + 272 * z) + 2 * k + 2) (fun _ => True) (z * 8 * mt) (256 * k) (fun _ => True) sh)
    (ho : OwnB C kg ku mt I y z s i k (tm (thOf y z s i) sh)) :
    ∃ t' sh', (Ev fun m => (runThread C m { t with status := .running }).run sh = some (t', sh')) ∧
      Mem C L I mt out W (40 * (y + 272 * z) + 2 * k + 2) (fun _ => True) (z * 8 * mt) (256 * k) (fun _ => True) sh' ∧
      TFrame (thOf y z s i) sh sh' ∧ OwnC C kg ku mt I y z s i k 0 0 0 (tm (thOf y z s i) sh') ∧
      t'.status = .collective 3 122 (.mma .f32 .f32) .f32 (opsG C kg mt I y z s (32 * k + 0) 0 i) 0 ∧
      AtC kg ku mt I.r y z s i k 0 0 0 ctx t' := by
  obtain ⟨tc, tl, tf, ts⟩ := t
  obtain ⟨hc, hf, hF, h30⟩ := ht
  dsimp only at hc hf hF h30
  subst tc; subst hf
  obtain ⟨l₁, sh₁, x₁, hm₁, ag₁, h37, h38, h39, h40, h89, tf₁, kp₁, hW₁⟩ := exec_pre2 C hS hKg hKu hm hl hk hF h30
  have hacc : AccOk mt i (fun b => AG C kg mt I y z s b (32 * k + 0)) (fun b => AU C ku mt I y z s b (32 * k + 0))
      (tm (thOf y z s i) sh₁) := fun b hb => by
    obtain ⟨g0, g1, u0, u1⟩ := ho b hb
    rw [tm_lt _ (by decide)] at g0 g1 u0 u1; rw [tm_lt _ (by decide), tm_lt _ (by decide)]
    rw [kp₁ 0 (by decide) (.inl (by decide)), kp₁ 1 (by decide) (.inl (by decide))]
    exact ⟨g0, g1, u0, u1⟩
  have hF₁ : Fix kg ku mt I.r y z s i l₁ := hF.of_eq fun q hq => ag₁ q (by omega)
  obtain ⟨l₂, sh₂, x₂, hm₂, tf₂, ho₂, hloc, -⟩ := exec_position C hS hKg hKu hmt hl hk (j := 0) (by decide) hm₁ hF₁
    (by rw [ag₁ 30 (by omega)]; exact h30) h37 h38 h39 h40 h89 hW₁ hacc
  have hcj : (eval C ctx l₁ jCond).run sh₁ = some (.bool true, sh₁) := eval_lt_u32 C h89 (by decide) (by decide)
  have hex : Exec C ctx (stepRest2 kg ku mt) tl sh (.stop (.collective 3 122 (.mma .f32 .f32) .f32
      (opsG C kg mt I y z s (32 * k + 0) 0 i) 0) (([.block blockRest3] ++ [.loop (bkCond mt) (incr 120) blockBody, .block []]) ++
        [.loop jCond (incr 89) (positionBody kg ku mt), .block []])) l₂ sh₂ := by
    rw [stepRest2_eq]; exact x₁.append (.loop_stop hcj x₂)
  exact ⟨_, sh₂, (hex.reaches_stop (K := K1 kg ku mt)).ev_stop rfl, hm₂,
    fun ρ h9 hρ => by rw [tf₂ ρ h9 hρ, tf₁ ρ h9 hρ], ho₂, rfl, rfl, rfl, hloc⟩

end Lane3


theorem Loc.of_eq {kg ku mt r y z s : Nat} {i : Fin 32} {k j bk : Nat} {l l' : Locals}
    (h : Loc kg ku mt r y z s i k j bk l)
    (h' : ∀ q, (q ≤ 40 ∨ (89 ≤ q ∧ q ≤ 91) ∨ q = 120 ∨ q = 121) → l' q = l q) : Loc kg ku mt r y z s i k j bk l' :=
  ⟨h.fix.of_eq fun q hq => h' q (by omega), (h' 30 (by omega)).trans h.l30, (h' 37 (by omega)).trans h.l37,
    (h' 38 (by omega)).trans h.l38, (h' 39 (by omega)).trans h.l39, (h' 40 (by omega)).trans h.l40,
    (h' 89 (by omega)).trans h.l89, (h' 90 (by omega)).trans h.l90, (h' 91 (by omega)).trans h.l91,
    (h' 120 (by omega)).trans h.l120, (h' 121 (by omega)).trans h.l121⟩

theorem pg_self (b n : Nat) : pg b b n = n := by simp [pg]
theorem pg_succ_ne {bk b n : Nat} (h : b ≠ bk) : pg (bk + 1) b n = pg bk b n := by
  unfold pg; by_cases h1 : b < bk
  · rw [ite_eq_left h1, ite_eq_left (by omega)]
  · rw [ite_eq_right h1, ite_eq_right (by omega)]
theorem pg_succ_self (bk n : Nat) : pg (bk + 1) bk n = n + 1 := by simp [pg]
theorem pg_all {mt b n : Nat} (h : b < mt) : pg mt b n = n + 1 := by simp [pg, h]

section Steps2
variable (C : M1Max.Contract) {ctx : Ctx}

/-- `++slot`. -/
theorem exec_incr (slot : Nat) {l : Locals} {sh : Shared} {v : Nat} (h : l slot = some (u32 v)) :
    Exec C ctx (incr slot) l sh .normal (setLocal l slot (u32 (v + 1))) sh :=
  .set (eval_bin_u32 C (eval_local' C h sh) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C v 1)) (.nil _ _)

/-- `slot < n`. -/
theorem eval_lt (slot n : Nat) {l : Locals} {sh : Shared} {v : Nat} (h : l slot = some (u32 v)) (hv : v < 2 ^ 32)
    (hn : n < 2 ^ 32) : (eval C ctx l (lt slot n)).run sh = some (.bool (decide (v < n)), sh) :=
  eval_lt_u32 C h hv hn

end Steps2

section Lane4
variable (C : M1Max.Contract) {L : Launch} {kg ku mt : Nat} {I : In} {out : Nat → BF} {W : Nat → Prop} {ctx : Ctx}

/-- The accumulator stored at row block `bk`: its 8 bytes hold `D`, the other blocks keep theirs. -/
theorem acc_store {B : ByteMemory.Bytes} {bk b : Nat} {x y : Float32} {G : Fin 32 → Fin 2 → Float32} {i : Fin 32}
    (hb : b ≠ bk) (h0 : F32At B (8 * b) (G i 0)) (h1 : F32At B (8 * b + 4) (G i 1)) :
    F32At (writeBytes B (8 * bk) (wordBytes 4 (Val.f32Bits x) ++ wordBytes 4 (Val.f32Bits y))) (8 * b) (G i 0) ∧
      F32At (writeBytes B (8 * bk) (wordBytes 4 (Val.f32Bits x) ++ wordBytes 4 (Val.f32Bits y))) (8 * b + 4) (G i 1) := by
  have hl : (wordBytes 4 (Val.f32Bits x) ++ wordBytes 4 (Val.f32Bits y)).length = 8 := by simp [wordBytes_length]
  exact ⟨f32At_keep _ (by rw [hl]; omega) h0, f32At_keep _ (by rw [hl]; omega) h1⟩

/-- Resumed with the gate multiply's result: `accG[bk]`, then the up multiply. -/
theorem lane_G (hS : Shape L kg ku mt I) (hmt : 1 ≤ mt ∧ mt ≤ 3) {y z s k j bk : Nat} {i : Fin 32}
    (hbk : bk < mt) {t : Thread} (ht : AtC kg ku mt I.r y z s i k j bk 0 ctx t) {ge mb base : Nat}
    {sh : Shared} (hm : Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True) sh)
    (ho : OwnC C kg ku mt I y z s i k j bk 0 (tm (thOf y z s i) sh)) :
    ∃ t' sh', (Ev fun m => (runThread C m ({ t with status := .running }.set 122
        (.vec .f32 [.f32 (AG C kg mt I y z s bk (32 * k + j + 1) i 0), .f32 (AG C kg mt I y z s bk (32 * k + j + 1) i 1)]))).run sh =
        some (t', sh')) ∧
      Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True) sh' ∧ TFrame (thOf y z s i) sh sh' ∧
      OwnC C kg ku mt I y z s i k j bk 1 (tm (thOf y z s i) sh') ∧
      t'.status = .collective 4 123 (.mma .f32 .f32) .f32 (opsU C ku mt I y z s (32 * k + j) bk i) 0 ∧
      AtC kg ku mt I.r y z s i k j bk 1 ctx t' := by
  obtain ⟨tc, tl, tf, ts⟩ := t
  obtain ⟨hc, hf, hL⟩ := ht
  dsimp only at hc hf hL
  subst tc; subst hf
  rw [resumed]
  obtain ⟨hacc, hW, hA, hB⟩ := ho
  have hL' := hL.of_eq (l' := setLocal tl 122 (.vec .f32 [.f32 (AG C kg mt I y z s bk (32 * k + j + 1) i 0),
    .f32 (AG C kg mt I y z s bk (32 * k + j + 1) i 1)])) fun q hq => setLocal_other _ _ (by omega)
  have hst := exec_accStore C (ctx := ctx) (sh := sh) 27 122 hmt.2 hL'.fix.l27 hL'.l120 (setLocal_same _ _ _)
    (by rw [hm.regions]; exact hS.t0 _) hbk
  generalize hsh₁ : Metal.tput sh (ta (thOf y z s i) 0) (8 * bk)
    (wordBytes 4 (Val.f32Bits (AG C kg mt I y z s bk (32 * k + j + 1) i 0)) ++
      wordBytes 4 (Val.f32Bits (AG C kg mt I y z s bk (32 * k + j + 1) i 1))) = sh₁ at hst
  have hm₁ : Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True) sh₁ := by
    rw [← hsh₁]; exact hm.tput _ _ (ta_ge _ _)
  have kp : ∀ q, q < 9 → q ≠ 0 → sh₁.bytes (ta (thOf y z s i) q) = sh.bytes (ta (thOf y z s i) q) := fun q _ h => by
    rw [← hsh₁, tput_other _ _ _ (ta_ne h)]
  obtain ⟨-, -, u0, u1⟩ := hacc bk hbk
  obtain ⟨a0, a1, a2, a3⟩ := hA
  obtain ⟨b0, b1⟩ := hB
  rw [tm_lt _ (by decide)] at u0 u1 a2 a3 b0 b1
  dsimp only at u0 u1; rw [pg_self] at u0 u1
  have hev := eval_mmaArgs C (ctx := ctx) (sh := sh₁) 91 28 hmt.2 hL'.l91 hL'.l121 hL'.fix.l28 hL'.l120
    (by rw [hm₁.regions]; exact hS.t7 _) (by rw [hm₁.regions]; exact hS.t8 _) (by rw [hm₁.regions]; exact hS.t1 _) hbk
    (by rw [kp 7 (by decide) (by decide)]; exact a2) (by rw [kp 7 (by decide) (by decide)]; exact a3)
    (by rw [kp 8 (by decide) (by decide)]; exact b0) (by rw [kp 8 (by decide) (by decide)]; exact b1)
    (by rw [kp 1 (by decide) (by decide)]; exact u0) (by rw [kp 1 (by decide) (by decide)]; exact u1)
  have hex : Exec C ctx blockRest3 (setLocal tl 122 (.vec .f32 [.f32 (AG C kg mt I y z s bk (32 * k + j + 1) i 0),
      .f32 (AG C kg mt I y z s bk (32 * k + j + 1) i 1)])) sh
      (.stop (.collective 4 123 (.mma .f32 .f32) .f32 (opsU C ku mt I y z s (32 * k + j) bk i) 0) [.block blockRest4])
      (setLocal tl 122 (.vec .f32 [.f32 (AG C kg mt I y z s bk (32 * k + j + 1) i 0),
        .f32 (AG C kg mt I y z s bk (32 * k + j + 1) i 1)])) sh₁ := by
    rw [blockRest3_eq]; exact hst.append (.collective hev (eval_lit C _ _ _ _) rfl)
  refine ⟨_, sh₁, (hex.reaches_stop (K := Kb kg ku mt)).ev_stop rfl, hm₁,
    fun ρ _ hρ => by rw [← hsh₁, tput_other _ _ _ (ne_ta hρ (by decide))], ⟨fun b hb => ?_, ?_, ?_, ?_⟩, rfl, rfl, rfl, hL'⟩
  · obtain ⟨g0, g1, u0', u1'⟩ := hacc b hb
    rw [tm_lt _ (by decide)] at g0 g1 u0' u1'; rw [tm_lt _ (by decide), tm_lt _ (by decide)]
    rw [kp 1 (by decide) (by decide)]
    refine ⟨?_, ?_, u0', u1'⟩
    · by_cases hbb : b = bk
      · subst hbb; dsimp only; rw [pg_succ_self, ← hsh₁, tput_same]; exact (f32At_put2 _ _ _ _).1
      · dsimp only; rw [pg_succ_ne hbb, ← hsh₁, tput_same]; exact (acc_store hbb g0 g1).1
    · by_cases hbb : b = bk
      · subst hbb; dsimp only; rw [pg_succ_self, ← hsh₁, tput_same]; exact (f32At_put2 _ _ _ _).2
      · dsimp only; rw [pg_succ_ne hbb, ← hsh₁, tput_same]; exact (acc_store hbb g0 g1).2
  · obtain ⟨w2, w3, w4, w5⟩ := hW
    rw [tm_lt _ (by decide)] at w2 w3 w4 w5
    refine ⟨?_, ?_, ?_, ?_⟩ <;> rw [tm_lt _ (by decide), kp _ (by decide) (by decide)]
    exacts [w2, w3, w4, w5]
  · refine ⟨?_, ?_, ?_, ?_⟩ <;> rw [tm_lt _ (by decide), kp _ (by decide) (by decide)]
    exacts [a0, a1, a2, a3]
  · refine ⟨?_, ?_⟩ <;> rw [tm_lt _ (by decide), kp _ (by decide) (by decide)]
    exacts [b0, b1]

/-- Resumed with the up multiply's result: `accU[bk]` stored; the state after row block `bk`. -/
theorem rest4 (hS : Shape L kg ku mt I) (hmt : 1 ≤ mt ∧ mt ≤ 3) {y z s k j bk : Nat} {i : Fin 32}
    (hbk : bk < mt) {l : Locals} (hL : Loc kg ku mt I.r y z s i k j bk l) {ge mb base : Nat}
    {sh : Shared} (hm : Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True) sh)
    (ho : OwnC C kg ku mt I y z s i k j bk 1 (tm (thOf y z s i) sh)) :
    ∃ sh', Exec C ctx blockRest4 (setLocal l 123 (.vec .f32 [.f32 (AU C ku mt I y z s bk (32 * k + j + 1) i 0),
        .f32 (AU C ku mt I y z s bk (32 * k + j + 1) i 1)])) sh .normal
        (setLocal l 123 (.vec .f32 [.f32 (AU C ku mt I y z s bk (32 * k + j + 1) i 0),
          .f32 (AU C ku mt I y z s bk (32 * k + j + 1) i 1)])) sh' ∧
      Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True) sh' ∧ TFrame (thOf y z s i) sh sh' ∧
      AccOk mt i (fun b => AG C kg mt I y z s b (pg (bk + 1) b (32 * k + j)))
        (fun b => AU C ku mt I y z s b (pg (bk + 1) b (32 * k + j))) (tm (thOf y z s i) sh') ∧
      (∀ q, q < 9 → q ≠ 1 → sh'.bytes (ta (thOf y z s i) q) = sh.bytes (ta (thOf y z s i) q)) := by
  obtain ⟨hacc, -, -, -⟩ := ho
  have hL' := hL.of_eq (l' := setLocal l 123 (.vec .f32 [.f32 (AU C ku mt I y z s bk (32 * k + j + 1) i 0),
    .f32 (AU C ku mt I y z s bk (32 * k + j + 1) i 1)])) fun q hq => setLocal_other _ _ (by omega)
  have hst := exec_accStore C (ctx := ctx) (sh := sh) 28 123 hmt.2 hL'.fix.l28 hL'.l120 (setLocal_same _ _ _)
    (by rw [hm.regions]; exact hS.t1 _) hbk
  refine ⟨_, by rw [blockRest4_eq]; exact hst, hm.tput _ _ (ta_ge _ _),
    fun ρ _ hρ => tput_other _ _ _ (ne_ta hρ (by decide)), fun b hb => ?_,
    fun q _ h => tput_other _ _ _ (ta_ne h)⟩
  obtain ⟨g0, g1, u0, u1⟩ := hacc b hb
  rw [tm_lt _ (by decide)] at g0 g1 u0 u1; rw [tm_lt _ (by decide), tm_lt _ (by decide)]
  rw [tput_other _ _ _ (ta_ne (by decide)), tput_same]
  refine ⟨g0, g1, ?_, ?_⟩
  · by_cases hbb : b = bk
    · subst hbb; dsimp only; rw [pg_succ_self]; exact (f32At_put2 _ _ _ _).1
    · dsimp only; rw [pg_succ_ne hbb]; exact (acc_store hbb u0 u1).1
  · by_cases hbb : b = bk
    · subst hbb; dsimp only; rw [pg_succ_self]; exact (f32At_put2 _ _ _ _).2
    · dsimp only; rw [pg_succ_ne hbb]; exact (acc_store hbb u0 u1).2

end Lane4


theorem Loc.setBk {kg ku mt r y z s : Nat} {i : Fin 32} {k j bk bk' : Nat} {l l' : Locals}
    (h : Loc kg ku mt r y z s i k j bk l) (h' : ∀ q, (q ≤ 40 ∨ (89 ≤ q ∧ q ≤ 91) ∨ q = 121) → l' q = l q)
    (h120 : l' 120 = some (u32 bk')) : Loc kg ku mt r y z s i k j bk' l' :=
  ⟨h.fix.of_eq fun q hq => h' q (by omega), (h' 30 (by omega)).trans h.l30, (h' 37 (by omega)).trans h.l37,
    (h' 38 (by omega)).trans h.l38, (h' 39 (by omega)).trans h.l39, (h' 40 (by omega)).trans h.l40,
    (h' 89 (by omega)).trans h.l89, (h' 90 (by omega)).trans h.l90, (h' 91 (by omega)).trans h.l91,
    h120, (h' 121 (by omega)).trans h.l121⟩

theorem Loc.set121 {kg ku mt r y z s : Nat} {i : Fin 32} {k j bk : Nat} {l : Locals}
    (h : Loc kg ku mt r y z s i k j bk l) :
    Loc kg ku mt r y z s i k j bk (setLocal l 121 (.ptr ⟨ta (thOf y z s i) 8, 0, .vec .f32 2⟩)) :=
  ⟨h.fix.of_eq fun q hq => setLocal_other _ _ (by omega), (setLocal_other _ _ (by omega)).trans h.l30,
    (setLocal_other _ _ (by omega)).trans h.l37, (setLocal_other _ _ (by omega)).trans h.l38,
    (setLocal_other _ _ (by omega)).trans h.l39, (setLocal_other _ _ (by omega)).trans h.l40,
    (setLocal_other _ _ (by omega)).trans h.l89, (setLocal_other _ _ (by omega)).trans h.l90,
    (setLocal_other _ _ (by omega)).trans h.l91, (setLocal_other _ _ (by omega)).trans h.l120, setLocal_same _ _ _⟩

section Lane5
variable (C : M1Max.Contract) {L : Launch} {kg ku mt : Nat} {I : In} {out : Nat → BF} {W : Nat → Prop} {ctx : Ctx}

/-- The result an up multiply resumes a lane with. -/
def resU (C : M1Max.Contract) (ku mt : Nat) (I : In) (y z s k j bk : Nat) (i : Fin 32) : Val :=
  .vec .f32 [.f32 (AU C ku mt I y z s bk (32 * k + j + 1) i 0), .f32 (AU C ku mt I y z s bk (32 * k + j + 1) i 1)]

/-- After the up multiply of row block `bk < MT - 1`: the next row block's gate multiply. -/
theorem lane_Ub (hS : Shape L kg ku mt I) (hmt : 1 ≤ mt ∧ mt ≤ 3) {y z s k j bk : Nat} {i : Fin 32}
    (hl : Lane ctx y z s i) (hj : j < 32) (hbk : bk + 1 < mt) {t : Thread}
    (ht : AtC kg ku mt I.r y z s i k j bk 1 ctx t) {sh : Shared}
    (hm : Mem C L I mt out W (40 * (y + 272 * z) + 2 * k + 2) (fun _ => True) (z * 8 * mt) (256 * k) (fun _ => True) sh)
    (ho : OwnC C kg ku mt I y z s i k j bk 1 (tm (thOf y z s i) sh)) :
    ∃ t' sh', (Ev fun m => (runThread C m ({ t with status := .running }.set 123
        (resU C ku mt I y z s k j bk i))).run sh = some (t', sh')) ∧
      Mem C L I mt out W (40 * (y + 272 * z) + 2 * k + 2) (fun _ => True) (z * 8 * mt) (256 * k) (fun _ => True) sh' ∧
      TFrame (thOf y z s i) sh sh' ∧ OwnC C kg ku mt I y z s i k j (bk + 1) 0 (tm (thOf y z s i) sh') ∧
      t'.status = .collective 3 122 (.mma .f32 .f32) .f32 (opsG C kg mt I y z s (32 * k + j) (bk + 1) i) 0 ∧
      AtC kg ku mt I.r y z s i k j (bk + 1) 0 ctx t' := by
  obtain ⟨tc, tl, tf, ts⟩ := t
  obtain ⟨hc, hf, hL⟩ := ht
  dsimp only at hc hf hL
  subst tc; subst hf
  rw [resumed]
  have hgrp := hl.group
  have hge3 : (40 * (y + 272 * z) + 2 * k + 2 - 40 * ctx.group) % 2 = 0 := by rw [hgrp]; omega
  obtain ⟨sh₁, x₁, hm₁, tf₁, hacc₁, kp₁⟩ := rest4 C (ctx := ctx) hS hmt (by omega) hL hm ho
  obtain ⟨-, hW, hA, -⟩ := ho
  have hL₁ := hL.of_eq (l' := setLocal tl 123 (resU C ku mt I y z s k j bk i)) fun q hq => setLocal_other _ _ (by omega)
  have hst := exec_incr C (ctx := ctx) (sh := sh₁) 120 hL₁.l120
  have hc := eval_lt C (ctx := ctx) (sh := sh₁) 120 mt (setLocal_same (setLocal tl 123 (resU C ku mt I y z s k j bk i))
    120 (u32 (bk + 1))) (by omega) (by omega)
  rw [decide_eq_true hbk] at hc
  obtain ⟨a0, a1, -, -⟩ := id hA
  rw [tm_lt _ (by decide)] at a0 a1
  rw [← kp₁ 6 (by decide) (by decide)] at a0 a1
  obtain ⟨g0, g1, -, -⟩ := hacc₁ (bk + 1) hbk
  rw [tm_lt _ (by decide)] at g0 g1
  dsimp only at g0 g1; rw [pg_self] at g0 g1
  have hL₂ := hL₁.setBk (bk' := bk + 1) (l' := setLocal (setLocal tl 123 (resU C ku mt I y z s k j bk i)) 120
    (u32 (bk + 1))) (fun q hq => setLocal_other _ _ (by omega)) (setLocal_same _ _ _)
  obtain ⟨sh₂, x₂, hm₂, tf₂, kp₂, hB₂⟩ := exec_block C hS hm₁ hge3 hl (k := k) (j := j) (bk := bk + 1) hj hbk hmt.2 rfl rfl
    hL₂.fix.l12 hL₂.fix.l21 hL₂.fix.l22 hL₂.fix.l27 hL₂.l89 hL₂.l90 hL₂.l120 a0 a1 g0 g1
  have hreach := Exec.resume_stop (c := bkCond mt) (st := incr 120) (b := blockBody) (ss := [])
    (K := [.loop jCond (incr 89) (positionBody kg ku mt), .block []] ++ K1 kg ku mt) x₁ (.inl rfl) hst hc x₂
  refine ⟨_, sh₂, hreach.ev_stop rfl, hm₂, fun ρ h9 hρ => by rw [tf₂ ρ h9 hρ, tf₁ ρ h9 hρ],
    ⟨fun b hb => ?_, ?_, ?_, hB₂⟩, rfl, rfl, rfl, hL₂.set121⟩
  · obtain ⟨g0', g1', u0', u1'⟩ := hacc₁ b hb
    rw [tm_lt _ (by decide)] at g0' g1' u0' u1'; rw [tm_lt _ (by decide), tm_lt _ (by decide)]
    rw [kp₂ 0 (by decide) (by decide), kp₂ 1 (by decide) (by decide)]
    exact ⟨g0', g1', u0', u1'⟩
  · obtain ⟨w2, w3, w4, w5⟩ := hW
    rw [tm_lt _ (by decide)] at w2 w3 w4 w5
    refine ⟨?_, ?_, ?_, ?_⟩ <;> rw [tm_lt _ (by decide), kp₂ _ (by decide) (by decide), kp₁ _ (by decide) (by decide)]
    exacts [w2, w3, w4, w5]
  · obtain ⟨a0', a1', a2', a3'⟩ := hA
    rw [tm_lt _ (by decide)] at a0' a1' a2' a3'
    refine ⟨?_, ?_, ?_, ?_⟩ <;> rw [tm_lt _ (by decide), kp₂ _ (by decide) (by decide), kp₁ _ (by decide) (by decide)]
    exacts [a0', a1', a2', a3']

/-- After the last row block's up multiply at position `j < 31`: the next position's first gate multiply. -/
theorem lane_Uj (hS : Shape L kg ku mt I) (hKg : GateUp.Width kg) (hKu : GateUp.Width ku) (hmt : 1 ≤ mt ∧ mt ≤ 3)
    {y z s k j bk : Nat} {i : Fin 32} (hl : Lane ctx y z s i) (hk : k < 20) (hj : j + 1 < 32) (hbk : bk + 1 = mt)
    {t : Thread} (ht : AtC kg ku mt I.r y z s i k j bk 1 ctx t) {sh : Shared}
    (hm : Mem C L I mt out W (40 * (y + 272 * z) + 2 * k + 2) (fun _ => True) (z * 8 * mt) (256 * k) (fun _ => True) sh)
    (ho : OwnC C kg ku mt I y z s i k j bk 1 (tm (thOf y z s i) sh)) :
    ∃ t' sh', (Ev fun m => (runThread C m ({ t with status := .running }.set 123
        (resU C ku mt I y z s k j bk i))).run sh = some (t', sh')) ∧
      Mem C L I mt out W (40 * (y + 272 * z) + 2 * k + 2) (fun _ => True) (z * 8 * mt) (256 * k) (fun _ => True) sh' ∧
      TFrame (thOf y z s i) sh sh' ∧ OwnC C kg ku mt I y z s i k (j + 1) 0 0 (tm (thOf y z s i) sh') ∧
      t'.status = .collective 3 122 (.mma .f32 .f32) .f32 (opsG C kg mt I y z s (32 * k + (j + 1)) 0 i) 0 ∧
      AtC kg ku mt I.r y z s i k (j + 1) 0 0 ctx t' := by
  obtain ⟨tc, tl, tf, ts⟩ := t
  obtain ⟨hc, hf, hL⟩ := ht
  dsimp only at hc hf hL
  subst tc; subst hf
  rw [resumed]
  obtain ⟨sh₁, x₁, hm₁, tf₁, hacc₁, kp₁⟩ := rest4 C (ctx := ctx) hS hmt (by omega) hL hm ho
  obtain ⟨-, hW, -, -⟩ := ho
  have hL₁ := hL.of_eq (l' := setLocal tl 123 (resU C ku mt I y z s k j bk i)) fun q hq => setLocal_other _ _ (by omega)
  have hst := exec_incr C (ctx := ctx) (sh := sh₁) 120 hL₁.l120
  have hc := eval_lt C (ctx := ctx) (sh := sh₁) 120 mt (setLocal_same (setLocal tl 123 (resU C ku mt I y z s k j bk i))
    120 (u32 (bk + 1))) (by omega) (by omega)
  rw [decide_eq_false (by omega)] at hc
  have r1 := Exec.resume_exit (c := bkCond mt) (st := incr 120) (b := blockBody) (ss := [])
    (K := [.loop jCond (incr 89) (positionBody kg ku mt), .block []] ++ K1 kg ku mt) x₁ (.inl rfl) hst hc
  generalize hl₂ : setLocal (setLocal tl 123 (resU C ku mt I y z s k j bk i)) 120 (u32 (bk + 1)) = l₂ at r1
  have h89 : l₂ 89 = some (u32 j) := by rw [← hl₂, setLocal_other _ _ (by omega)]; exact hL₁.l89
  have hst89 := exec_incr C (ctx := ctx) (sh := sh₁) 89 h89
  have hcj := eval_lt C (ctx := ctx) (sh := sh₁) 89 32 (setLocal_same l₂ 89 (u32 (j + 1))) (by omega) (by decide)
  rw [decide_eq_true hj] at hcj
  have hag : ∀ q, (q < 89 ∨ 89 < q ∧ q < 120) → setLocal l₂ 89 (u32 (j + 1)) q = tl q := fun q hq => by
    rw [setLocal_other _ _ (by omega), ← hl₂, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
  have hacc : AccOk mt i (fun b => AG C kg mt I y z s b (32 * k + (j + 1))) (fun b => AU C ku mt I y z s b (32 * k + (j + 1)))
      (tm (thOf y z s i) sh₁) := fun b hb => by
    have := hacc₁ b hb
    dsimp only at this
    rw [hbk, pg_all hb] at this
    exact this
  have hW₁ : WordsOk kg ku I y s i k (tm (thOf y z s i) sh₁) := by
    obtain ⟨w2, w3, w4, w5⟩ := hW
    rw [tm_lt _ (by decide)] at w2 w3 w4 w5
    refine ⟨?_, ?_, ?_, ?_⟩ <;> rw [tm_lt _ (by decide), kp₁ _ (by decide) (by decide)]
    exacts [w2, w3, w4, w5]
  obtain ⟨l₄, sh₄, x₄, hm₄, tf₄, ho₄, hloc₄, -⟩ := exec_position C hS hKg hKu hmt hl hk (j := j + 1) hj hm₁
    (hL.fix.of_eq fun q hq => hag q (by omega)) (by rw [hag 30 (by omega)]; exact hL.l30)
    (by rw [hag 37 (by omega)]; exact hL.l37) (by rw [hag 38 (by omega)]; exact hL.l38)
    (by rw [hag 39 (by omega)]; exact hL.l39) (by rw [hag 40 (by omega)]; exact hL.l40) (setLocal_same _ _ _) hW₁ hacc
  have r3 := Exec.resume_loop (c := jCond) (st := incr 89) (b := positionBody kg ku mt) (ss := []) (K := K1 kg ku mt)
    hst89 (Exec.loop_stop hcj x₄) rfl
  exact ⟨_, sh₄, (r1.trans (.cons rfl (step_pop C) r3)).ev_stop rfl, hm₄,
    fun ρ h9 hρ => by rw [tf₄ ρ h9 hρ, tf₁ ρ h9 hρ], ho₄, rfl, rfl, rfl, hloc₄⟩

/-- After the last row block's up multiply at the step's last position: the next step's first barrier. -/
theorem lane_Uk (hS : Shape L kg ku mt I) (hmt : 1 ≤ mt ∧ mt ≤ 3)
    {y z s k bk : Nat} {i : Fin 32} (hk : k + 1 < 20) (hbk : bk + 1 = mt)
    {t : Thread} (ht : AtC kg ku mt I.r y z s i k 31 bk 1 ctx t) {ge mb base : Nat} {sh : Shared}
    (hm : Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True) sh)
    (ho : OwnC C kg ku mt I y z s i k 31 bk 1 (tm (thOf y z s i) sh)) :
    ∃ t' sh', (Ev fun m => (runThread C m ({ t with status := .running }.set 123
        (resU C ku mt I y z s k 31 bk i))).run sh = some (t', sh')) ∧
      Mem C L I mt out W ge (fun _ => True) mb base (fun _ => True) sh' ∧
      TFrame (thOf y z s i) sh sh' ∧ OwnB C kg ku mt I y z s i (k + 1) (tm (thOf y z s i) sh') ∧
      t'.status = .barrier 1 false true ∧ AtB1 kg ku mt I.r y z s i (k + 1) ctx t' := by
  obtain ⟨tc, tl, tf, ts⟩ := t
  obtain ⟨hc, hf, hL⟩ := ht
  dsimp only at hc hf hL
  subst tc; subst hf
  rw [resumed]
  obtain ⟨sh₁, x₁, hm₁, tf₁, hacc₁, -⟩ := rest4 C (ctx := ctx) hS hmt (by omega) hL hm ho
  have hL₁ := hL.of_eq (l' := setLocal tl 123 (resU C ku mt I y z s k 31 bk i)) fun q hq => setLocal_other _ _ (by omega)
  have hst := exec_incr C (ctx := ctx) (sh := sh₁) 120 hL₁.l120
  have hc := eval_lt C (ctx := ctx) (sh := sh₁) 120 mt (setLocal_same (setLocal tl 123 (resU C ku mt I y z s k 31 bk i))
    120 (u32 (bk + 1))) (by omega) (by omega)
  rw [decide_eq_false (by omega)] at hc
  have r1 := Exec.resume_exit (c := bkCond mt) (st := incr 120) (b := blockBody) (ss := [])
    (K := [.loop jCond (incr 89) (positionBody kg ku mt), .block []] ++ K1 kg ku mt) x₁ (.inl rfl) hst hc
  generalize hl₂ : setLocal (setLocal tl 123 (resU C ku mt I y z s k 31 bk i)) 120 (u32 (bk + 1)) = l₂ at r1
  have h89 : l₂ 89 = some (u32 31) := by rw [← hl₂, setLocal_other _ _ (by omega)]; exact hL₁.l89
  have hst89 := exec_incr C (ctx := ctx) (sh := sh₁) 89 h89
  have hcj := eval_lt C (ctx := ctx) (sh := sh₁) 89 32 (setLocal_same l₂ 89 (u32 (31 + 1))) (by decide) (by decide)
  have r3 := Exec.resume_loop (c := jCond) (st := incr 89) (b := positionBody kg ku mt) (ss := []) (K := K1 kg ku mt)
    hst89 (Exec.loop_exit hcj (.nil _ _)) rfl
  have hag : ∀ q, (q < 89 ∨ 89 < q ∧ q < 120) → setLocal l₂ 89 (u32 (31 + 1)) q = tl q := fun q hq => by
    rw [setLocal_other _ _ (by omega), ← hl₂, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
  have h30 : setLocal l₂ 89 (u32 (31 + 1)) 30 = some (u32 (256 * k)) := by rw [hag 30 (by omega)]; exact hL.l30
  have hst30 : Exec C ctx baseStep (setLocal l₂ 89 (u32 (31 + 1))) sh₁ .normal
      (setLocal (setLocal l₂ 89 (u32 (31 + 1))) 30 (u32 (256 * k + 256))) sh₁ :=
    .set (eval_bin_u32 C (eval_local' C h30 sh₁) (eval_u32lit C _ _ 256 (by decide)) (binary_add_u32 C _ 256)) (.nil _ _)
  have hc30 := eval_lt C (ctx := ctx) (sh := sh₁) 30 5120
    (setLocal_same (setLocal l₂ 89 (u32 (31 + 1))) 30 (u32 (256 * k + 256))) (by omega) (by decide)
  rw [decide_eq_true (by omega)] at hc30
  have hb1 : Exec C ctx (stepBody kg ku mt) (setLocal (setLocal l₂ 89 (u32 (31 + 1))) 30 (u32 (256 * k + 256))) sh₁
      (.stop (.barrier 1 false true) [.block (stepRest1 kg ku mt)])
      (setLocal (setLocal l₂ 89 (u32 (31 + 1))) 30 (u32 (256 * k + 256))) sh₁ := by
    rw [stepBody_eq]; exact .barrier
  have r4 := Exec.resume_loop (c := baseCond) (st := baseStep) (b := stepBody kg ku mt) (ss := afterBase kg ku mt)
    (K := [.scope, .block []]) hst30 (Exec.loop_stop hc30 hb1) rfl
  refine ⟨_, sh₁, (r1.trans (.cons rfl (step_pop C) (r3.trans r4))).ev_stop rfl, hm₁, tf₁, fun b hb => ?_, rfl, rfl, rfl,
    hL.fix.of_eq fun q hq => by dsimp only; rw [setLocal_other _ _ (by omega), hag q (by omega)], ?_⟩
  · have := hacc₁ b hb
    dsimp only at this
    rw [hbk, pg_all hb, show 32 * k + 31 + 1 = 32 * (k + 1) by ring] at this
    exact this
  · show setLocal (setLocal l₂ 89 (u32 (31 + 1))) 30 (u32 (256 * k + 256)) 30 = some (u32 (256 * (k + 1)))
    rw [setLocal_same, show 256 * k + 256 = 256 * (k + 1) by ring]

end Lane5


/-! ## The outputs -/

/-- The expected `mid` element `idx`. -/
def outF (C : M1Max.Contract) (kg ku : Nat) (I : In) (idx : Nat) : BF :=
  midv C kg ku I.r I.X I.Gc I.Gs I.Uc I.Us (idx / 17408) (idx % 17408)

/-- Lane `i`'s `mid` elements before row block `nb`'s element `ne` (rows from `M` on skipped). -/
def Mine (mt r y z s : Nat) (i : Fin 32) (nb ne idx : Nat) : Prop :=
  ∃ bk e, (bk < nb ∨ (bk = nb ∧ e < ne)) ∧ bk < mt ∧ e < 2 ∧ z * 8 * mt + 8 * bk + fnOf i + e < r ∧
    idx = 17408 * (z * 8 * mt + 8 * bk + fnOf i + e) + (8 * (8 * y + s) + fmOf i)

theorem midv_eq (C : M1Max.Contract) (kg ku r : Nat) (X Gc Gs Uc Us : ByteMemory.Bytes) {mt y z s bk e : Nat}
    {i : Fin 32} (he : e < 2) :
    midv C kg ku r X Gc Gs Uc Us (z * 8 * mt + 8 * bk + fnOf i + e) (8 * (8 * y + s) + fmOf i) =
      act C (acc C (aReg C kg Gc (8 * y + s)) (bReg C r X (mt * z + bk)) 640 i ⟨e, he⟩)
        (acc C (aReg C ku Uc (8 * y + s)) (bReg C r X (mt * z + bk)) 640 i ⟨e, he⟩)
        (sc C Gs (8 * (8 * y + s) + fmOf i)) (sc C Us (8 * (8 * y + s) + fmOf i)) := by
  have hfm := fmOf_lt i; have hfn := fnOf_le i; have hev := fnOf_even i
  have hz : z * 8 * mt = 8 * (mt * z) := by ring
  unfold midv
  have h1 : (8 * (8 * y + s) + fmOf i) / 8 = 8 * y + s := by omega
  have h2 : (8 * (8 * y + s) + fmOf i) % 8 = fmOf i := by omega
  have h3 : (z * 8 * mt + 8 * bk + fnOf i + e) / 8 = mt * z + bk := by rw [hz]; omega
  have h4 : (z * 8 * mt + 8 * bk + fnOf i + e) % 8 = fnOf i + e := by rw [hz]; omega
  have h5 : lane32 (laneOf (fmOf i) (fnOf i + e)) = i := Fin.ext (by
    show laneOf (fmOf i) (fnOf i + e) % 32 = i.val
    rw [laneOf_fm_fn _ i.isLt _ he]; exact Nat.mod_eq_of_lt i.isLt)
  have h6 : el2 (z * 8 * mt + 8 * bk + fnOf i + e) = ⟨e, he⟩ := Fin.ext (by
    show (z * 8 * mt + 8 * bk + fnOf i + e) % 2 = e
    rw [hz]; omega)
  rw [h1, h2, h3, h4, h5, h6]

theorem writer_eq {mt y z s bk e : Nat} {i : Fin 32} (hmt : 0 < mt) (hy : y < 272) (hs : s < 8) (hbk : bk < mt)
    (he : e < 2) :
    wThread mt (17408 * (z * 8 * mt + 8 * bk + fnOf i + e) + (8 * (8 * y + s) + fmOf i)) = thOf y z s i ∧
      wGroup mt (17408 * (z * 8 * mt + 8 * bk + fnOf i + e) + (8 * (8 * y + s) + fmOf i)) = y + 272 * z := by
  have hfm := fmOf_lt i; have hfn := fnOf_le i
  have hz : z * 8 * mt = 8 * (mt * z) := by ring
  generalize hm : z * 8 * mt + 8 * bk + fnOf i + e = m
  have hrow : 8 * (8 * y + s) + fmOf i < 17408 := by omega
  have hd : (17408 * m + (8 * (8 * y + s) + fmOf i)) / 17408 = m := by omega
  have hmod : (17408 * m + (8 * (8 * y + s) + fmOf i)) % 17408 = 8 * (8 * y + s) + fmOf i := by omega
  have h8 : m / 8 = mt * z + bk := by omega
  have hmz : (mt * z + bk) / mt = z := by
    rw [Nat.add_comm, Nat.add_mul_div_left _ _ hmt, Nat.div_eq_of_lt hbk, Nat.zero_add]
  have hm8 : m % 8 = fnOf i + e := by omega
  unfold wThread wGroup
  rw [hd, hmod, h8, hmz, hm8, show (8 * (8 * y + s) + fmOf i) % 8 = fmOf i by omega,
    show (8 * (8 * y + s) + fmOf i) / 8 % 8 = s by omega, show (8 * (8 * y + s) + fmOf i) / 64 = y by omega,
    laneOf_fm_fn _ i.isLt _ he]
  exact ⟨rfl, rfl⟩

/-- Every element whose writer is lane `i`'s thread is one of its elements. -/
theorem mine_cover {mt r y z s : Nat} {i : Fin 32} (hmt : 0 < mt) (hy : y < 272) (hs : s < 8) {idx : Nat}
    (hidx : idx < 17408 * r) (hw : wThread mt idx = thOf y z s i) : Mine mt r y z s i mt 0 idx := by
  unfold wThread wGroup thOf at hw
  generalize hm : idx / 17408 = m at hw
  generalize hrw : idx % 17408 = row at hw
  have hidx' : idx = 17408 * m + row := by omega
  have hrow : row < 17408 := by omega
  have hmr : m < r := by
    have := Nat.div_lt_iff_lt_mul (show 0 < 17408 by decide) |>.mpr (show idx < r * 17408 by omega)
    omega
  obtain ⟨hfa, hfn, hl32⟩ := fm_laneOf (row % 8) (by omega) (m % 8) (by omega)
  have hi := i.isLt
  have e1 : row / 64 + 272 * (m / 8 / mt) = y + 272 * z ∧ 32 * (row / 8 % 8) + laneOf (row % 8) (m % 8) = 32 * s + i := by
    generalize row / 64 + 272 * (m / 8 / mt) = A at hw
    generalize laneOf (row % 8) (m % 8) = a at hw hl32
    constructor <;> omega
  obtain ⟨e1, e2⟩ := e1
  have hry : row / 64 = y := by
    have : row / 64 < 272 := by omega
    generalize m / 8 / mt = Z at e1; omega
  have hmz : m / 8 / mt = z := by rw [hry] at e1; omega
  have hrs : row / 8 % 8 = s := by
    generalize laneOf (row % 8) (m % 8) = a at e2 hl32; omega
  have hli : laneOf (row % 8) (m % 8) = i := by
    generalize laneOf (row % 8) (m % 8) = a at e2 hl32 ⊢; omega
  rw [hli] at hfa hfn
  have hm8 := Nat.div_add_mod (m / 8) mt
  rw [hmz] at hm8
  refine ⟨m / 8 % mt, m % 2, .inl (Nat.mod_lt _ hmt), Nat.mod_lt _ hmt, Nat.mod_lt _ (by decide), ?_, ?_⟩
  · have : z * 8 * mt + 8 * (m / 8 % mt) + fnOf i + m % 2 = m := by
      have hz : z * 8 * mt = 8 * (mt * z) := by ring
      rw [hz]; omega
    rw [this]; exact hmr
  · have : z * 8 * mt + 8 * (m / 8 % mt) + fnOf i + m % 2 = m := by
      have hz : z * 8 * mt = 8 * (mt * z) := by ring
      rw [hz]; omega
    rw [this, hidx']
    congr 1
    omega

theorem afterBase_eq (kg ku mt : Nat) : afterBase kg ku mt =
    [.ite (GateUpMmaWide.u32 .ge (.local 20) (u32l 17408)) [.leave] [],
     .set 124 (.bin .mul .f32 0 (.conv .f32 (.load (.scalar .f16) (.offset (.local 3) (.local 23)))) (f32l 0x3BDDB447)),
     .set 125 (.bin .mul .f32 0 (.conv .f32 (.load (.scalar .f16) (.offset (.local 5) (.local 23)))) (f32l 0x3BDDB447)),
     .set 126 (u32l 0),
     .loop (lt 126 mt) (incr 126) [.set 127 (u32l 0), .loop (lt 127 2) (incr 127) outBody]] := rfl

theorem outBody_eq : outBody =
    [.set 128 (GateUpMmaWide.u32 .add (GateUpMmaWide.u32 .add (GateUpMmaWide.u32 .add (.local 26)
      (GateUpMmaWide.u32 .mul (u32l 8) (.local 126))) (.local 22)) (.local 127)),
     .ite (GateUpMmaWide.u32 .ge (.local 128) (.local 7)) [.continue_] []] ++ outBody.drop 2 := rfl

theorem pair_get (x : Fin 2 → Float32) (j : Nat) (hj : j < 2) :
    [Val.f32 (x 0), Val.f32 (x 1)][j]? = some (.f32 (x ⟨j, hj⟩)) := by
  rcases j with _ | _ | j
  · rfl
  · rfl
  · omega

section Out
variable (C : M1Max.Contract) {L : Launch} {kg ku mt : Nat} {I : In} {W : Nat → Prop} {ctx : Ctx}

/-- `float(scales[row]) * TRELLIS_RCP`. -/
theorem eval_scale (preg : Nat) {reg al : Nat} {S : ByteMemory.Bytes} {l : Locals} {sh : Shared} {row : Nat}
    (hp : l preg = some (.ptr ⟨reg, 0, .scalar .f16⟩)) (h23 : l 23 = some (u32 row))
    (hreg : sh.regions reg = some ⟨.device, 34816, al⟩) (hal : al % 2 = 0) (hrow : row < 17408) (hb : sh.bytes reg = S) :
    (eval C ctx l (.bin .mul .f32 0 (.conv .f32 (.load (.scalar .f16) (.offset (.local preg) (.local 23))))
      (f32l 0x3BDDB447))).run sh = some (.f32 (sc C S row), rdn ctx sh reg (2 * row) 2) := by
  have hq := eval_ptr_u32 C (ctx := ctx) (eval_local' C hp sh) (eval_local' C h23 sh) (by omega)
  rw [show row * (Ty.scalar .f16).bytes = 2 * row by simp only [Ty.bytes, Scalar.bytes]; ring] at hq
  have hl := load_shared ctx .f16 sh reg (2 * row) _ hreg (by simp) (by simpa [Scalar.bytes] using hal)
    (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset, Ty.bytes, Scalar.bytes])
  rw [show Scalar.f16.bytes = 2 from rfl, hb] at hl
  exact eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_conv C ((eval_load C _ _ _ _ _ _ _ hq).trans hl) rfl)
    (eval_lit C _ _ _ _) rfl

/-- One output element `(bk, j)`: skipped past row `M`, else `mid[m][row]` from the accumulators. -/
theorem exec_out (hS : Shape L kg ku mt I) (hmt : 1 ≤ mt ∧ mt ≤ 3) (hr : I.r < 2 ^ 16) {y z s : Nat} {i : Fin 32}
    (hl : Lane ctx y z s i) (hz : z * 8 * mt < I.r + 8 * mt) {bk j : Nat} (hbk : bk < mt) (hj : j < 2) {l : Locals}
    (hF : Fix kg ku mt I.r y z s i l) (h124 : l 124 = some (.f32 (sc C I.Gs (8 * (8 * y + s) + fmOf i))))
    (h125 : l 125 = some (.f32 (sc C I.Us (8 * (8 * y + s) + fmOf i)))) (h126 : l 126 = some (u32 bk))
    (h127 : l 127 = some (u32 j)) {ge mb base : Nat} {cbOk xsOk P : Nat → Prop} {sh : Shared}
    (hm : Mem C L I mt (outF C kg ku I) P ge cbOk mb base xsOk sh)
    (hacc : AccOk mt i (fun b => AG C kg mt I y z s b 640) (fun b => AU C ku mt I y z s b 640) (tm (thOf y z s i) sh)) :
    ∃ o l' sh', (o = .normal ∨ o = .continue_) ∧ Exec C ctx outBody l sh o l' sh' ∧
      Mem C L I mt (outF C kg ku I) (fun idx => P idx ∨ (z * 8 * mt + 8 * bk + fnOf i + j < I.r ∧
        idx = 17408 * (z * 8 * mt + 8 * bk + fnOf i + j) + (8 * (8 * y + s) + fmOf i))) ge cbOk mb base xsOk sh' ∧
      (∀ q, q < 128 → l' q = l q) ∧ (∀ ρ, 9 ≤ ρ → sh'.bytes ρ = sh.bytes ρ) := by
  have hfm := fmOf_lt i; have hfn := fnOf_le i
  have hy := hl.hy; have hs := hl.hs
  generalize hmv : z * 8 * mt + 8 * bk + fnOf i + j = m
  have hml : m < 2 ^ 20 := by omega
  have e128 : (eval C ctx l (GateUpMmaWide.u32 .add (GateUpMmaWide.u32 .add (GateUpMmaWide.u32 .add (.local 26)
      (GateUpMmaWide.u32 .mul (u32l 8) (.local 126))) (.local 22)) (.local 127))).run sh = some (u32 m, sh) := by
    rw [← hmv]
    exact eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_local' C hF.l26 sh) (eval_bin_u32 C
      (eval_u32lit C _ _ 8 (by decide)) (eval_local' C h126 sh) (binary_mul_u32 C 8 bk)) (binary_add_u32 C _ _))
      (eval_local' C hF.l22 sh) (binary_add_u32 C _ _)) (eval_local' C h127 sh) (binary_add_u32 C _ _)
  have hL : setLocal l 128 (u32 m) 128 = some (u32 m) := setLocal_same _ _ _
  have hL7 : setLocal l 128 (u32 m) 7 = some (u32 I.r) := by rw [setLocal_other _ _ (by omega)]; exact hF.l7
  have hc := eval_bin_u32 C (ctx := ctx) (op := .ge) (site := 0) (eval_local' C hL sh) (eval_local' C hL7 sh)
    (binary_ge_u32 C m I.r (by omega) (by omega))
  rw [outBody_eq]
  by_cases hmr : I.r ≤ m
  · rw [decide_eq_true hmr] at hc
    refine ⟨.continue_, _, sh, .inr rfl, Exec.append_jump (.set e128 (.ite_exit hc .continue_ (.inl rfl))) (.inl rfl),
      hm.mono (fun idx _ h => ?_) (fun e _ h => h) (fun q _ h => h), fun q hq => setLocal_other _ _ (by omega),
      fun _ _ => rfl⟩
    rcases h with h | ⟨h, -⟩
    · exact h
    · omega
  · rw [decide_eq_false hmr] at hc
    have hmr' : m < I.r := by omega
    have th := hl.thread
    have hrowl : 8 * (8 * y + s) + fmOf i < 17408 := by omega
    obtain ⟨g0, g1, u0, u1⟩ := hacc bk hbk
    dsimp only at g0 g1 u0 u1
    rw [tm_lt _ (by decide)] at g0 g1 u0 u1
    have hpG := eval_ptr_u32 C (ctx := ctx) (sh := sh) (l := setLocal l 128 (u32 m))
      (eval_local' C (i := 27) (by rw [setLocal_other _ _ (by omega)]; exact hF.l27) sh)
      (eval_local' C (i := 126) (by rw [setLocal_other _ _ (by omega)]; exact h126) sh) (by omega)
    rw [show bk * (Ty.vec .f32 2).bytes = 8 * bk by rw [show (Ty.vec .f32 2).bytes = 8 from rfl]; ring] at hpG
    have hlG := load_thread_f32x2 ctx sh (ta (thOf y z s i) 0) (8 * bk) (8 * mt) 8 (by rw [hm.regions]; exact hS.t0 _)
      (by decide) (by omega) (by omega) g0 g1
    have hpU := eval_ptr_u32 C (ctx := ctx) (sh := sh) (l := setLocal (setLocal l 128 (u32 m)) 129
      (.bf16 (C.narrow (C.fmul (AG C kg mt I y z s bk 640 i ⟨j, hj⟩) (sc C I.Gs (8 * (8 * y + s) + fmOf i))))))
      (eval_local' C (i := 28) (by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact hF.l28) sh)
      (eval_local' C (i := 126) (by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact h126) sh) (by omega)
    rw [show bk * (Ty.vec .f32 2).bytes = 8 * bk by rw [show (Ty.vec .f32 2).bytes = 8 from rfl]; ring] at hpU
    have hlU := load_thread_f32x2 ctx sh (ta (thOf y z s i) 1) (8 * bk) (8 * mt) 8 (by rw [hm.regions]; exact hS.t1 _)
      (by decide) (by omega) (by omega) u0 u1
    have hnat : natOf (u32 j) = some j := by rw [natOf_u32, Nat.mod_eq_of_lt (by omega)]
    generalize hgT : C.narrow (C.fmul (AG C kg mt I y z s bk 640 i ⟨j, hj⟩) (sc C I.Gs (8 * (8 * y + s) + fmOf i))) = gT
      at hpU
    generalize huT : C.narrow (C.fmul (AU C ku mt I y z s bk 640 i ⟨j, hj⟩) (sc C I.Us (8 * (8 * y + s) + fmOf i))) = uT
    generalize hsT : C.narrow (C.fdiv one (C.fadd one (C.exp (f32Neg (C.widen gT))))) = sT
    have e129 : (eval C ctx (setLocal l 128 (u32 m)) (.conv .bf16 (.bin .mul .f32 0 (.component (.load (.vec .f32 2)
        (.offset (.local 27) (.local 126))) (.local 127)) (.local 124)))).run sh = some (.bf16 gT, sh) := by
      rw [← hgT]
      exact eval_conv C (eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_component C ((eval_load C _ _ _ _ _ _ _ hpG).trans hlG)
        (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact h127) sh) hnat (pair_get _ j hj))
        (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact h124) sh) rfl) rfl
    have e130 : (eval C ctx (setLocal (setLocal l 128 (u32 m)) 129 (.bf16 gT)) (.conv .bf16 (.bin .mul .f32 0
        (.component (.load (.vec .f32 2) (.offset (.local 28) (.local 126))) (.local 127)) (.local 125)))).run sh =
        some (.bf16 uT, sh) := by
      rw [← huT]
      exact eval_conv C (eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_component C ((eval_load C _ _ _ _ _ _ _ hpU).trans hlU)
        (eval_local' C (by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact h127) sh) hnat
        (pair_get _ j hj))
        (eval_local' C (by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact h125) sh) rfl) rfl
    have e131 : (eval C ctx (setLocal (setLocal (setLocal l 128 (u32 m)) 129 (.bf16 gT)) 130 (.bf16 uT))
        (.conv .bf16 (.bin .div .f32 0 (f32l 0x3F800000) (.bin .add .f32 0 (f32l 0x3F800000)
          (.un .exp .f32 (.un .neg .f32 (.conv .f32 (.local 129)))))))).run sh = some (.bf16 sT, sh) := by
      rw [← hsT]
      exact eval_conv C (eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_lit C _ _ _ _) (eval_f32 C (.inr ⟨rfl, rfl⟩)
        (eval_lit C _ _ _ _) (eval_un C (eval_un C (eval_conv C (eval_local' C (by
          rw [setLocal_other _ _ (by omega), setLocal_same]) sh) rfl) rfl) rfl) rfl) rfl) rfl
    have e132 : (eval C ctx (setLocal (setLocal (setLocal (setLocal l 128 (u32 m)) 129 (.bf16 gT)) 130 (.bf16 uT)) 131
        (.bf16 sT)) (.bin .mul .bf16 0 (.local 129) (.local 131))).run sh = some (.bf16 (C.bfmul gT sT), sh) :=
      eval_bin_plain C (.inl ⟨by decide, by decide⟩)
        (eval_local' C (by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_same]) sh)
        (eval_local' C (setLocal_same _ _ _) sh) rfl
    generalize hL₅ : setLocal (setLocal (setLocal (setLocal (setLocal l 128 (u32 m)) 129 (.bf16 gT)) 130 (.bf16 uT)) 131
      (.bf16 sT)) 132 (.bf16 (C.bfmul gT sT)) = L₅
    have h128 : L₅ 128 = some (u32 m) := by
      rw [← hL₅]; simp (disch := omega) only [setLocal_other, setLocal_same]
    have h23 : L₅ 23 = some (u32 (8 * (8 * y + s) + fmOf i)) := by
      rw [← hL₅]; simp (disch := omega) only [setLocal_other, hF.l23]
    have h6 : L₅ 6 = some (.ptr ⟨6, 0, .scalar .bf16⟩) := by
      rw [← hL₅]; simp (disch := omega) only [setLocal_other, hF.l6]
    have hidx : (eval C ctx L₅ (GateUpMmaWide.u64 .add (GateUpMmaWide.u64 .mul (toU64 (.local 128)) (u64l 17408))
        (toU64 (.local 23)))).run sh = some (u64 (m * 17408 + (8 * (8 * y + s) + fmOf i)), sh) :=
      eval_int C (by decide) (eval_int C (by decide) (eval_conv C (eval_local' C h128 sh) (convert_u64_u32 C m (by omega)))
        (eval_lit C _ _ _ _) (binary_mul_u64 C m 17408))
        (eval_conv C (eval_local' C h23 sh) (convert_u64_u32 C _ (by omega))) (binary_add_u64 C _ _)
    have hp := eval_offset_u64 C (o := 0) (eval_local' C h6 sh) hidx (by omega)
    rw [show 0 + (m * 17408 + (8 * (8 * y + s) + fmOf i)) * (Ty.scalar .bf16).bytes =
      2 * (17408 * m + (8 * (8 * y + s) + fmOf i)) by simp only [Ty.bytes, Scalar.bytes]; ring] at hp
    have hv : (eval C ctx L₅ (.bin .mul .bf16 0 (.local 132) (.local 130))).run sh =
        some (.bf16 (outF C kg ku I (17408 * m + (8 * (8 * y + s) + fmOf i))), sh) := by
      have hout : outF C kg ku I (17408 * m + (8 * (8 * y + s) + fmOf i)) = C.bfmul (C.bfmul gT sT) uT := by
        unfold outF
        rw [show (17408 * m + (8 * (8 * y + s) + fmOf i)) / 17408 = m by omega,
          show (17408 * m + (8 * (8 * y + s) + fmOf i)) % 17408 = 8 * (8 * y + s) + fmOf i by omega, ← hmv,
          midv_eq C kg ku I.r I.X I.Gc I.Gs I.Uc I.Us hj, ← hsT, ← hgT, ← huT]
        rfl
      rw [hout]
      exact eval_bin_plain C (.inl ⟨by decide, by decide⟩)
        (eval_local' C (v := .bf16 (C.bfmul gT sT)) (by rw [← hL₅, setLocal_same]) sh)
        (eval_local' C (v := .bf16 uT) (by rw [← hL₅]; simp (disch := omega) only [setLocal_other, setLocal_same]) sh) rfl
    have hidxl : 17408 * m + (8 * (8 * y + s) + fmOf i) < 17408 * I.r := by omega
    have hst := store_shared ctx .bf16 sh 6 (2 * (17408 * m + (8 * (8 * y + s) + fmOf i))) _
      (.bf16 (outF C kg ku I (17408 * m + (8 * (8 * y + s) + fmOf i))))
      (wordBytes 2 (Val.bf16Bits (outF C kg ku I (17408 * m + (8 * (8 * y + s) + fmOf i)))))
      (by rw [hm.regions]; exact hS.r6) (by simp) (by simp) (by simp [Scalar.bytes]) (by simp [Scalar.bytes])
      (by simp [Scalar.bytes]; omega) rfl
    obtain ⟨hw1, hw2⟩ := writer_eq (z := z) (i := i) (show 0 < mt by omega) hy hs hbk hj
    rw [hmv] at hw1 hw2
    have hm' := hm.wmid hS ctx (17408 * m + (8 * (8 * y + s) + fmOf i)) hidxl (by rw [hw1]; exact th)
      (by rw [hw2]; exact hl.group)
    refine ⟨.normal, L₅, _, .inl rfl, ?_, hm'.mono (fun idx _ h => ?_) (fun e _ h => h) (fun q _ h => h),
      fun q hq => by rw [← hL₅]; simp (disch := omega) only [setLocal_other],
      fun ρ hρ => wrn_other _ _ _ _ _ (by omega)⟩
    · rw [← hL₅]
      exact .set e128 (.ite hc (.nil _ _) (.set e129 (.set e130 (.set e131 (.set e132 (by
        rw [hL₅]; exact .store hp hv hst (.nil _ _)))))))
    · rcases h with h | ⟨-, rfl⟩
      · exact .inl h
      · exact .inr rfl

end Out


section Out2
variable (C : M1Max.Contract) {L : Launch} {kg ku mt : Nat} {I : In} {W : Nat → Prop} {ctx : Ctx}

/-- After the steps: the scales, then every output element of the lane. -/
theorem exec_after (hS : Shape L kg ku mt I) (hmt : 1 ≤ mt ∧ mt ≤ 3) (hr : I.r < 2 ^ 16) {y z s : Nat} {i : Fin 32}
    (hl : Lane ctx y z s i) (hz : z * 8 * mt < I.r + 8 * mt) {l : Locals} (hF : Fix kg ku mt I.r y z s i l)
    {ge mb base : Nat} {cbOk xsOk : Nat → Prop} {sh : Shared}
    (hm : Mem C L I mt (outF C kg ku I) W ge cbOk mb base xsOk sh)
    (hacc : AccOk mt i (fun b => AG C kg mt I y z s b 640) (fun b => AU C ku mt I y z s b 640) (tm (thOf y z s i) sh)) :
    ∃ l' sh', Exec C ctx (afterBase kg ku mt) l sh .normal l' sh' ∧
      Mem C L I mt (outF C kg ku I) (fun idx => W idx ∨ Mine mt I.r y z s i mt 0 idx) ge cbOk mb base xsOk sh' ∧
      ∀ ρ, 9 ≤ ρ → sh'.bytes ρ = sh.bytes ρ := by
  have hy := hl.hy; have hs := hl.hs; have hfm := fmOf_lt i
  have hrow : 8 * (8 * y + s) + fmOf i < 17408 := by omega
  rw [afterBase_eq]
  have hc0 : (eval C ctx l (GateUpMmaWide.u32 .ge (.local 20) (u32l 17408))).run sh = some (.bool false, sh) := by
    have := eval_bin_u32 C (ctx := ctx) (op := .ge) (site := 0) (eval_local' C hF.l20 sh)
      (eval_u32lit C _ _ 17408 (by decide)) (binary_ge_u32 C _ 17408 (by omega) (by decide))
    rwa [decide_eq_false (by omega)] at this
  have e124 := eval_scale C (ctx := ctx) 3 (l := l) (sh := sh) hF.l3 hF.l23 (by rw [hm.regions]; exact hS.r3) hS.as
    hrow hm.gs
  have hm1 := hm.rd hS ctx 3 (2 * (8 * (8 * y + s) + fmOf i)) 2 (by decide)
  have e125 := eval_scale C (ctx := ctx) 5 (S := I.Us) (l := setLocal l 124 (.f32 (sc C I.Gs (8 * (8 * y + s) + fmOf i))))
    (sh := rdn ctx sh 3 (2 * (8 * (8 * y + s) + fmOf i)) 2) (by rw [setLocal_other _ _ (by omega)]; exact hF.l5)
    (by rw [setLocal_other _ _ (by omega)]; exact hF.l23) (by rw [rdn_regions, hm.regions]; exact hS.r5) hS.aus hrow
    (by rw [rdn_bytes]; exact hm.us)
  have hm2 := hm1.rd hS ctx 5 (2 * (8 * (8 * y + s) + fmOf i)) 2 (by decide)
  generalize hsh₂ : rdn ctx (rdn ctx sh 3 (2 * (8 * (8 * y + s) + fmOf i)) 2) 5 (2 * (8 * (8 * y + s) + fmOf i)) 2 = sh₂
    at e125 hm2
  have hb₂ : ∀ ρ, 9 ≤ ρ → sh₂.bytes ρ = sh.bytes ρ := fun ρ _ => by rw [← hsh₂]; rfl
  let L₀ : Locals := setLocal (setLocal (setLocal l 124 (.f32 (sc C I.Gs (8 * (8 * y + s) + fmOf i)))) 125
    (.f32 (sc C I.Us (8 * (8 * y + s) + fmOf i)))) 126 (u32 0)
  let OI : Nat → Locals → Shared → Prop := fun b L' S => Mem C L I mt (outF C kg ku I)
    (fun idx => W idx ∨ Mine mt I.r y z s i b 0 idx) ge cbOk mb base xsOk S ∧ (∀ q, q < 126 → L' q = L₀ q) ∧
    L' 126 = some (u32 b) ∧ (∀ ρ, 9 ≤ ρ → S.bytes ρ = sh.bytes ρ)
  obtain ⟨l', sh', hloop, hOI⟩ := Exec.loop_count (C := C) (ctx := ctx) (c := lt 126 mt) (st := incr 126)
    (b := [.set 127 (u32l 0), .loop (lt 127 2) (incr 127) outBody]) mt OI OI
    (fun b hb L' S hI => ⟨S, eval_lt C 126 mt hI.2.2.1 (by omega) (by omega), hI⟩)
    (fun b hb L' S hI => by
      obtain ⟨hmS, hagS, h126, hbS⟩ := hI
      let II : Nat → Locals → Shared → Prop := fun e L'' S' => Mem C L I mt (outF C kg ku I)
        (fun idx => W idx ∨ Mine mt I.r y z s i b e idx) ge cbOk mb base xsOk S' ∧ (∀ q, q < 127 → L'' q = L' q) ∧
        L'' 127 = some (u32 e) ∧ (∀ ρ, 9 ≤ ρ → S'.bytes ρ = sh.bytes ρ)
      have hagL : ∀ q, q < 124 → L' q = l q := fun q hq => by
        rw [hagS q (by omega)]; simp (disch := omega) only [L₀, setLocal_other]
      obtain ⟨l₂, sh₃, hin, hII⟩ := Exec.loop_count (C := C) (ctx := ctx) (c := lt 127 2) (st := incr 127)
        (b := outBody) 2 II II
        (fun e he L'' S' hJ => ⟨S', eval_lt C 127 2 hJ.2.2.1 (by omega) (by decide), hJ⟩)
        (fun e he L'' S' hJ => by
          obtain ⟨hmJ, hagJ, h127, hbJ⟩ := hJ
          have hacc' : AccOk mt i (fun b => AG C kg mt I y z s b 640) (fun b => AU C ku mt I y z s b 640)
              (tm (thOf y z s i) S') := by
            rw [tm_eq fun q _ => hbJ _ (ta_ge _ _)]; exact hacc
          have hag'' : ∀ q, q < 124 → L'' q = l q := fun q hq => by rw [hagJ q (by omega), hagL q hq]
          obtain ⟨o, l₃, sh₄, ho, hx, hm₄, hag₄, hb₄⟩ := exec_out C hS hmt hr hl hz hb he (l := L'')
            (hF.of_eq fun q hq => hag'' q (by omega))
            (by rw [hagJ 124 (by omega), hagS 124 (by omega)]; simp (disch := omega) only [L₀, setLocal_other, setLocal_same])
            (by rw [hagJ 125 (by omega), hagS 125 (by omega)]; simp (disch := omega) only [L₀, setLocal_other, setLocal_same])
            (by rw [hagJ 126 (by omega)]; exact h126) h127 hmJ hacc'
          refine ⟨o, l₃, sh₄, setLocal l₃ 127 (u32 (e + 1)), sh₄, ho, hx,
            exec_incr C 127 (by rw [hag₄ 127 (by omega)]; exact h127), hm₄.mono (fun idx _ h => ?_) (fun e _ h => h)
            (fun q _ h => h), fun q hq => by rw [setLocal_other _ _ (by omega), hag₄ q (by omega), hagJ q hq],
            setLocal_same _ _ _, fun ρ hρ => (hb₄ ρ hρ).trans (hbJ ρ hρ)⟩
          rcases h with h | ⟨bk', e', hlt, hbk', he', hm', rfl⟩
          · exact .inl (.inl h)
          · by_cases hcase : bk' < b ∨ (bk' = b ∧ e' < e)
            · exact .inl (.inr ⟨bk', e', hcase, hbk', he', hm', rfl⟩)
            · have h1 : bk' = b := by omega
              have h2 : e' = e := by omega
              subst h1 h2
              exact .inr ⟨hm', rfl⟩)
        (l := setLocal L' 127 (u32 0)) (sh := S) ⟨hmS.mono (fun idx _ h => h) (fun e _ h => h) (fun q _ h => h),
          fun q hq => setLocal_other _ _ (by omega), setLocal_same _ _ _, hbS⟩
      obtain ⟨hmI, hagI, -, hbI⟩ := hII
      refine ⟨.normal, l₂, sh₃, setLocal l₂ 126 (u32 (b + 1)), sh₃, .inl rfl,
        .set (eval_u32lit C _ _ 0 (by decide)) hin, exec_incr C 126 (by rw [hagI 126 (by omega)]; exact h126),
        hmI.mono (fun idx _ h => ?_) (fun e _ h => h) (fun q _ h => h),
        fun q hq => by rw [setLocal_other _ _ (by omega), hagI q (by omega), hagS q hq], setLocal_same _ _ _, hbI⟩
      rcases h with h | ⟨bk', e', hlt, hbk', he', hm', rfl⟩
      · exact .inl h
      · exact .inr ⟨bk', e', by omega, hbk', he', hm', rfl⟩)
    (l := L₀) (sh := sh₂) ⟨hm2.mono (fun idx _ h => h.elim id (fun ⟨_, _, hlt, _⟩ => by omega)) (fun e _ h => h) (fun q _ h => h), fun q _ => rfl,
      by simp only [L₀, setLocal_same], hb₂⟩
  exact ⟨l', sh', .ite hc0 (.nil _ _) (.set e124 (.set e125 (.set (eval_u32lit C _ _ 0 (by decide)) hloop))), hOI.1,
    hOI.2.2.2⟩

end Out2

section Lane6
variable (C : M1Max.Contract) {L : Launch} {kg ku mt : Nat} {I : In} {W : Nat → Prop} {ctx : Ctx}

/-- After the last up multiply: out of the loops, the outputs, the end. -/
theorem lane_Ulast (hS : Shape L kg ku mt I) (hmt : 1 ≤ mt ∧ mt ≤ 3) (hr : I.r < 2 ^ 16)
    {y z s bk : Nat} {i : Fin 32} (hl : Lane ctx y z s i) (hbk : bk + 1 = mt) (hz : z * 8 * mt < I.r + 8 * mt)
    {t : Thread} (ht : AtC kg ku mt I.r y z s i 19 31 bk 1 ctx t) {ge mb base : Nat} {sh : Shared}
    (hm : Mem C L I mt (outF C kg ku I) W ge (fun _ => True) mb base (fun _ => True) sh)
    (ho : OwnC C kg ku mt I y z s i 19 31 bk 1 (tm (thOf y z s i) sh)) :
    ∃ t' sh', (Ev fun m => (runThread C m ({ t with status := .running }.set 123
        (resU C ku mt I y z s 19 31 bk i))).run sh = some (t', sh')) ∧
      Mem C L I mt (outF C kg ku I) (fun idx => W idx ∨ Mine mt I.r y z s i mt 0 idx) ge (fun _ => True) mb base
        (fun _ => True) sh' ∧
      TFrame (thOf y z s i) sh sh' ∧ t'.status = .done := by
  obtain ⟨tc, tl, tf, ts⟩ := t
  obtain ⟨hc, hf, hL⟩ := ht
  dsimp only at hc hf hL
  subst tc; subst hf
  rw [resumed]
  obtain ⟨sh₁, x₁, hm₁, tf₁, hacc₁, -⟩ := rest4 C (ctx := ctx) hS hmt (by omega) hL hm ho
  have hL₁ := hL.of_eq (l' := setLocal tl 123 (resU C ku mt I y z s 19 31 bk i)) fun q hq => setLocal_other _ _ (by omega)
  have hst := exec_incr C (ctx := ctx) (sh := sh₁) 120 hL₁.l120
  have hc := eval_lt C (ctx := ctx) (sh := sh₁) 120 mt (setLocal_same (setLocal tl 123 (resU C ku mt I y z s 19 31 bk i))
    120 (u32 (bk + 1))) (by omega) (by omega)
  rw [decide_eq_false (by omega)] at hc
  have r1 := Exec.resume_exit (c := bkCond mt) (st := incr 120) (b := blockBody) (ss := [])
    (K := [.loop jCond (incr 89) (positionBody kg ku mt), .block []] ++ K1 kg ku mt) x₁ (.inl rfl) hst hc
  generalize hl₂ : setLocal (setLocal tl 123 (resU C ku mt I y z s 19 31 bk i)) 120 (u32 (bk + 1)) = l₂ at r1
  have h89 : l₂ 89 = some (u32 31) := by rw [← hl₂, setLocal_other _ _ (by omega)]; exact hL₁.l89
  have hst89 := exec_incr C (ctx := ctx) (sh := sh₁) 89 h89
  have hcj := eval_lt C (ctx := ctx) (sh := sh₁) 89 32 (setLocal_same l₂ 89 (u32 (31 + 1))) (by decide) (by decide)
  have r3 := Exec.resume_loop (c := jCond) (st := incr 89) (b := positionBody kg ku mt) (ss := []) (K := K1 kg ku mt)
    hst89 (Exec.loop_exit hcj (.nil _ _)) rfl
  have hag : ∀ q, (q < 89 ∨ 89 < q ∧ q < 120) → setLocal l₂ 89 (u32 (31 + 1)) q = tl q := fun q hq => by
    rw [setLocal_other _ _ (by omega), ← hl₂, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
  have h30 : setLocal l₂ 89 (u32 (31 + 1)) 30 = some (u32 (256 * 19)) := by rw [hag 30 (by omega)]; exact hL.l30
  have hst30 : Exec C ctx baseStep (setLocal l₂ 89 (u32 (31 + 1))) sh₁ .normal
      (setLocal (setLocal l₂ 89 (u32 (31 + 1))) 30 (u32 (256 * 19 + 256))) sh₁ :=
    .set (eval_bin_u32 C (eval_local' C h30 sh₁) (eval_u32lit C _ _ 256 (by decide)) (binary_add_u32 C _ 256)) (.nil _ _)
  have hc30 := eval_lt C (ctx := ctx) (sh := sh₁) 30 5120
    (setLocal_same (setLocal l₂ 89 (u32 (31 + 1))) 30 (u32 (256 * 19 + 256))) (by decide) (by decide)
  have hacc : AccOk mt i (fun b => AG C kg mt I y z s b 640) (fun b => AU C ku mt I y z s b 640)
      (tm (thOf y z s i) sh₁) := fun b hb => by
    have := hacc₁ b hb
    dsimp only at this
    rw [hbk, pg_all hb] at this
    exact this
  obtain ⟨l₅, sh₅, x₅, hm₅, hb₅⟩ := exec_after C hS hmt hr hl hz
    (l := setLocal (setLocal l₂ 89 (u32 (31 + 1))) 30 (u32 (256 * 19 + 256)))
    (hL.fix.of_eq fun q hq => by rw [setLocal_other _ _ (by omega), hag q (by omega)]) hm₁ hacc
  have r4 := Exec.resume_loop (c := baseCond) (st := baseStep) (b := stepBody kg ku mt) (ss := afterBase kg ku mt)
    (K := [.scope, .block []]) hst30 (Exec.loop_exit hc30 x₅) rfl
  refine ⟨_, sh₅, (r1.trans (.cons rfl (step_pop C) (r3.trans (r4.trans (.cons rfl (step_scope_pop C)
    (.cons rfl (step_pop C) (.single rfl (step_done C)))))))).ev_stop rfl, hm₅,
    fun ρ h9 hρ => by rw [hb₅ ρ h9, tf₁ ρ h9 hρ], rfl⟩

end Lane6


/-! ## Before the first barrier, and the staging -/

theorem shape_cells (r : Nat) : cells (shapeBytes r) 0 4 = wordBytes 4 r := rfl

section Lane0
variable (C : M1Max.Contract) {L : Launch} {kg ku mt : Nat} {I : In} {out : Nat → BF} {W : Nat → Prop} {ctx : Ctx}

/-- `codebook[i] = half(trellis_y_f32(i))` for `i = tid, tid + 256, …`. -/
theorem exec_fill (hS : Shape L kg ku mt I) {y z s : Nat} {i : Fin 32} (hl : Lane ctx y z s i) {l : Locals}
    {mb base : Nat} {xsOk : Nat → Prop} {sh : Shared}
    (h11 : l 11 = some (.ptr ⟨7, 0, .scalar .f16⟩)) (h13 : l 13 = some (u32 (32 * s + i)))
    (hm : Mem C L I mt out W (40 * (y + 272 * z)) (fun e => e % 256 < 32 * s + i) mb base xsOk sh) :
    ∃ l' sh', Exec C ctx [fillLoop] l sh .normal l' sh' ∧
      Mem C L I mt out W (40 * (y + 272 * z)) (fun e => e % 256 < 32 * s + i + 1) mb base xsOk sh' ∧
      (∀ q, (q < 13 ∨ 19 < q) → l' q = l q) ∧ (∀ ρ, 9 ≤ ρ → sh'.bytes ρ = sh.bytes ρ) := by
  have hs := hl.hs; have hi := i.isLt
  let FI : Nat → Locals → Shared → Prop := fun k L' S =>
    Mem C L I mt out W (40 * (y + 272 * z)) (fun e => e % 256 < 32 * s + i ∨ (e % 256 = 32 * s + i ∧ e / 256 < k))
      mb base xsOk S ∧ L' 13 = some (u32 (32 * s + i + 256 * k)) ∧ (∀ q, (q < 13 ∨ 19 < q) → L' q = l q) ∧
      (∀ ρ, 9 ≤ ρ → S.bytes ρ = sh.bytes ρ)
  obtain ⟨l', sh', hex, hI⟩ := Exec.loop_count (C := C) (ctx := ctx) (c := lt 13 4096)
    (st := [.set 13 (GateUpMmaWide.u32 .add (.local 13) (u32l 256))])
    (b := [.set 14 (.local 13), yF32 14, .store (.scalar .f16) (.offset (.local 11) (.local 13)) (.conv .f16 (.local 15))])
    16 FI FI
    (fun k hk L' S hJ => ⟨S, by
      have := eval_lt C (ctx := ctx) (sh := S) 13 4096 hJ.2.1 (by omega) (by decide)
      rwa [show decide (32 * s + i + 256 * k < 4096) = decide (k < 16) from decide_eq_decide.mpr (by omega)] at this,
      hJ⟩)
    (fun k hk L' S hJ => by
      obtain ⟨hmS, h13S, hagS, hbS⟩ := hJ
      have he : 32 * s + i + 256 * k < 4096 := by omega
      obtain ⟨L₂, hy, h15, hag⟩ := exec_yF32 C (ctx := ctx) (sh := S) 14 (l := setLocal L' 14 (u32 (32 * s + i + 256 * k)))
        (setLocal_same _ _ _)
      have h11' : L₂ 11 = some (.ptr ⟨7, 0, .scalar .f16⟩) := by
        rw [hag 11 (by omega), setLocal_other _ _ (by omega), hagS 11 (by omega)]; exact h11
      have h13' : L₂ 13 = some (u32 (32 * s + i + 256 * k)) := by
        rw [hag 13 (by omega), setLocal_other _ _ (by omega)]; exact h13S
      have hp := eval_ptr_u32 C (ctx := ctx) (eval_local' C h11' S) (eval_local' C h13' S) (by omega)
      rw [show (32 * s + i + 256 * k) * (Ty.scalar .f16).bytes = 2 * (32 * s + i + 256 * k) by
        simp only [Ty.bytes, Scalar.bytes]; ring] at hp
      have hst := store_shared ctx .f16 S 7 (2 * (32 * s + i + 256 * k)) _ (.f16 (cbv C (32 * s + i + 256 * k)))
        (wordBytes 2 (Val.f16Bits (cbv C (32 * s + i + 256 * k)))) (by rw [hmS.regions]; exact hS.r7) (by simp) (by simp)
        (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) rfl
      have hm' := hmS.wcb hS ctx (32 * s + i + 256 * k) he (by rw [hl.thread]; unfold thOf; omega) hl.group
      refine ⟨.normal, L₂, _, setLocal L₂ 13 (u32 (32 * s + i + 256 * k + 256)), _, .inl rfl,
        .set (eval_local' C h13S S) (hy.append (.store hp (eval_conv C (eval_local' C h15 S) rfl) hst (.nil _ _))),
        .set (eval_bin_u32 C (eval_local' C h13' _) (eval_u32lit C _ _ 256 (by decide)) (binary_add_u32 C _ 256)) (.nil _ _),
        hm'.mono (fun idx _ h => h) (fun e _ h => ?_) (fun q _ h => h),
        by rw [setLocal_same, show 32 * s + i + 256 * k + 256 = 32 * s + i + 256 * (k + 1) by ring],
        fun q hq => by rw [setLocal_other _ _ (by omega), hag q (by omega), setLocal_other _ _ (by omega), hagS q hq],
        fun ρ hρ => by rw [wrn_other _ _ _ _ _ (by omega), hbS ρ hρ]⟩
      rcases h with h | ⟨h1, h2⟩
      · exact .inl (.inl h)
      · by_cases h3 : e / 256 < k
        · exact .inl (.inr ⟨h1, h3⟩)
        · exact .inr (by omega))
    (l := l) (sh := sh) ⟨hm.mono (fun idx _ h => h) (fun e _ h => by rcases h with h | ⟨-, h⟩ <;> omega)
      (fun q _ h => h), by rw [Nat.mul_zero, Nat.add_zero]; exact h13, fun _ _ => rfl, fun _ _ => rfl⟩
  exact ⟨l', sh', hex, hI.1.mono (fun idx _ h => h) (fun e he h => by omega) (fun q _ h => h), hI.2.2.1, hI.2.2.2⟩

/-- A lane from the start: the pointers, `M`, the codebook entries, the row and the accumulators, to the first
barrier. -/
theorem lane_start (hS : Shape L kg ku mt I) (hKg : GateUp.Width kg) (hKu : GateUp.Width ku) (hmt : 1 ≤ mt ∧ mt ≤ 3) (hr : 0 < I.r ∧ I.r < 2 ^ 16)
    {y z s : Nat} {i : Fin 32} (hl : Lane ctx y z s i) {mb base : Nat} {xsOk : Nat → Prop} {sh : Shared}
    (hm : Mem C L I mt out W (40 * (y + 272 * z)) (fun e => e % 256 < 32 * s + i) mb base xsOk sh) :
    ∃ t sh', (Ev fun m => (runThread C m ⟨ctx, fun _ => none, [.block (body kg ku mt)], .running⟩).run sh =
        some (t, sh')) ∧
      Mem C L I mt out W (40 * (y + 272 * z)) (fun e => e % 256 < 32 * s + i + 1) mb base xsOk sh' ∧
      TFrame (thOf y z s i) sh sh' ∧ OwnB C kg ku mt I y z s i 0 (tm (thOf y z s i) sh') ∧
      t.status = .barrier 1 false true ∧ AtB1 kg ku mt I.r y z s i 0 ctx t := by
  have hs := hl.hs; have hy := hl.hy; have hi := i.isLt
  have hfm := fmOf_lt i; have hfn := fnOf_le i
  have hgrp := hl.group
  have e0 := hl.ta 0; have e1 := hl.ta 1
  have hga0 := hl.ga0; have hga1 := hl.ga1
  have hrow : 8 * (8 * y + s) + fmOf i < 17408 := by omega
  -- The buffer pointers.
  let L₇ : Locals := setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (fun _ => none)
    0 (.ptr ⟨0, 0, .scalar .bf16⟩)) 1 (.ptr ⟨1, 0, .scalar .i32⟩)) 2 (.ptr ⟨2, 0, .scalar .u32⟩))
    3 (.ptr ⟨3, 0, .scalar .f16⟩)) 4 (.ptr ⟨4, 0, .scalar .u32⟩)) 5 (.ptr ⟨5, 0, .scalar .f16⟩))
    6 (.ptr ⟨6, 0, .scalar .bf16⟩)
  have hpre : Exec C ctx ((body kg ku mt).take 7) (fun _ => none) sh .normal L₇ sh :=
    .set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _)
      (.set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _) (.nil _ _)))))))
  -- `M = x_shape[0]`.
  have hM : (eval C ctx L₇ (.conv .u32 (.load (.scalar .i32) (.offset (.local 1) (i32l 0))))).run sh =
      some (u32 I.r, rdn ctx sh 1 0 4) := by
    have hp := eval_offset_i32 C (ctx := ctx) (o := 0) (n := 0) (eval_local' C (l := L₇) (i := 1)
      (v := .ptr ⟨1, 0, .scalar .i32⟩) (by simp (disch := omega) only [L₇, setLocal_other, setLocal_same]) sh)
      (eval_lit C _ _ _ _) (by decide)
    have hl1 := load_shared ctx .i32 sh 1 0 _ (by rw [hm.regions]; exact hS.r1) (by simp)
      (by simpa [Scalar.bytes] using hS.ash) (by decide) (by simp [Scalar.bytes]) (by simp [loadOffset])
    have hw : Val.ofWord .i32 (bytesWord (cells (sh.bytes 1) 0 Scalar.i32.bytes)) = .int .i32 I.r := by
      rw [hm.xsh, show Scalar.i32.bytes = 4 from rfl, shape_cells, bytesWord_wordBytes]
      show Val.int .i32 (I.r % 256 ^ 4 % 2 ^ 32) = _
      rw [Nat.mod_eq_of_lt (by omega), Nat.mod_eq_of_lt (by omega)]
    rw [hw] at hl1
    exact eval_conv C ((eval_load C _ _ _ _ _ _ _ hp).trans hl1) (convert_u32_i32 C _ (by omega))
  have hm₁ := hm.rd hS ctx 1 0 4 (by decide)
  -- `lane`, `sg`, `tid`, the threadgroup arrays, `i = tid`.
  let L₁₃ : Locals := setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal L₇ 7 (u32 I.r))
    8 (u32 i)) 9 (u32 s)) 10 (u32 (32 * s + i))) 11 (.ptr ⟨ctx.groupArray 0, 0, .scalar .f16⟩))
    12 (.ptr ⟨ctx.groupArray 1, 0, .scalar .bf16⟩)) 13 (u32 (32 * s + i))
  have htid : (eval C ctx (setLocal (setLocal (setLocal L₇ 7 (u32 I.r)) 8 (u32 i)) 9 (u32 s))
      (GateUpMmaWide.u32 .add (GateUpMmaWide.u32 .mul (.local 9) (u32l 32)) (.local 8))).run (rdn ctx sh 1 0 4) =
      some (u32 (32 * s + i), rdn ctx sh 1 0 4) := by
    have := eval_bin_u32 C (ctx := ctx) (l := setLocal (setLocal (setLocal L₇ 7 (u32 I.r)) 8 (u32 i)) 9 (u32 s))
      (op := .add) (site := 0) (eval_bin_u32 C (op := .mul) (site := 0)
      (eval_local' C (setLocal_same _ 9 (u32 s)) (rdn ctx sh 1 0 4)) (eval_u32lit C _ _ 32 (by decide))
      (binary_mul_u32 C s 32)) (eval_local' C (i := 8) (v := u32 i) (by rw [setLocal_other _ _ (by omega), setLocal_same]) _)
      (binary_add_u32 C _ i)
    rwa [show s * 32 + (i : Nat) = 32 * s + i by ring] at this
  have hsA : Exec C ctx ((S0 kg ku mt).take 7) L₇ sh .normal L₁₃ (rdn ctx sh 1 0 4) :=
    .set hM (.set ((eval_coord C _ _ _ _).trans (by rw [hl.lane])) (.set ((eval_coord C _ _ _ _).trans (by rw [hl.sg]))
      (.set htid (.array (.array (.set (eval_local' C (by simp (disch := omega) only [setLocal_other, setLocal_same]) _)
        (.nil _ _)))))))
  obtain ⟨l₁, sh₁, hfill, hmf, agf, hbf⟩ := exec_fill C hS hl (l := L₁₃) (sh := rdn ctx sh 1 0 4)
    (by simp (disch := omega) only [L₁₃, setLocal_other, setLocal_same, hga0])
    (by simp (disch := omega) only [L₁₃, setLocal_same]) hm₁
  have k : ∀ q, q < 13 → l₁ q = L₁₃ q := fun q hq => agf q (.inl hq)
  have h8 : l₁ 8 = some (u32 i) := by rw [k 8 (by omega)]; simp (disch := omega) only [L₁₃, setLocal_other, setLocal_same]
  have h9 : l₁ 9 = some (u32 s) := by rw [k 9 (by omega)]; simp (disch := omega) only [L₁₃, setLocal_other, setLocal_same]
  have h2 : l₁ 2 = some (.ptr ⟨2, 0, .scalar .u32⟩) := by
    rw [k 2 (by omega)]; simp (disch := omega) only [L₁₃, L₇, setLocal_other, setLocal_same]
  have h4 : l₁ 4 = some (.ptr ⟨4, 0, .scalar .u32⟩) := by
    rw [k 4 (by omega)]; simp (disch := omega) only [L₁₃, L₇, setLocal_other, setLocal_same]
  -- `n0 … mBase`, `accG`, `accU`, `bk = 0`.
  let L₂₉ : Locals := setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal l₁
    20 (u32 (8 * (8 * y + s)))) 21 (u32 (fmOf i))) 22 (u32 (fnOf i))) 23 (u32 (8 * (8 * y + s) + fmOf i)))
    24 (.ptr ⟨2, ((4 * ((8 * (8 * y + s) + fmOf i) * (20 * (8 * kg))) : Nat) : Int), .scalar .u32⟩))
    25 (.ptr ⟨4, ((4 * ((8 * (8 * y + s) + fmOf i) * (20 * (8 * ku))) : Nat) : Int), .scalar .u32⟩))
    26 (u32 (z * 8 * mt))) 27 (.ptr ⟨ctx.threadArray 0, 0, .vec .f32 2⟩)) 28 (.ptr ⟨ctx.threadArray 1, 0, .vec .f32 2⟩))
    29 (u32 0)
  have hK : kg ≤ 4 ∧ ku ≤ 4 := ⟨(GateUp.width_le hKg).2, (GateUp.width_le hKu).2⟩
  have hsetup : Exec C ctx (setup kg ku mt) l₁ sh₁ .normal L₂₉ sh₁ := by
    refine .set (sh₁ := sh₁) ?_ (.set (sh₁ := sh₁) ?_ (.set (sh₁ := sh₁) ?_ (.set (sh₁ := sh₁) ?_ (.set (sh₁ := sh₁) ?_
      (.set (sh₁ := sh₁) ?_ (.set (sh₁ := sh₁) ?_ (.array (.array (.set (eval_u32lit C _ _ 0 (by decide)) (.nil _ _))))))))))
    · have := eval_bin_u32 C (ctx := ctx) (sh := sh₁) (op := .mul) (site := 0) (eval_bin_u32 C (op := .add) (site := 0)
        (eval_bin_u32 C (op := .mul) (site := 0) (eval_coord1 C (l := l₁) hl.tgpos) (eval_u32lit C _ _ 8 (by decide))
          (binary_mul_u32 C y 8)) (eval_local' C h9 _) (binary_add_u32 C _ s)) (eval_u32lit C _ _ 8 (by decide))
        (binary_mul_u32 C _ 8)
      rwa [show (y * 8 + s) * 8 = 8 * (8 * y + s) by ring] at this
    · exact eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact h8) _)
        (eval_u32lit C _ _ 4 (by decide)) (binary_div_u32 C i 4 (by omega) (by decide) (by decide)))
        (eval_u32lit C _ _ 4 (by decide)) (binary_bitAnd_u32 C (i / 4) 4 (by omega) (by decide)))
        (eval_bin_u32 C (eval_bin_u32 C (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact h8) _)
          (eval_u32lit C _ _ 2 (by decide)) (binary_div_u32 C i 2 (by omega) (by decide) (by decide)))
          (eval_u32lit C _ _ 4 (by decide)) (binary_rem_u32 C (i / 2) 4 (by omega) (by decide) (by decide)))
        (binary_add_u32 C _ _)
    · exact eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C
        (eval_local' C (by simp (disch := omega) only [setLocal_other, h8]) _) (eval_u32lit C _ _ 4 (by decide))
        (binary_div_u32 C i 4 (by omega) (by decide) (by decide))) (eval_u32lit C _ _ 2 (by decide))
        (binary_bitAnd_u32 C (i / 4) 2 (by omega) (by decide))) (eval_u32lit C _ _ 2 (by decide)) (binary_mul_u32 C _ 2))
        (eval_bin_u32 C (eval_bin_u32 C (eval_local' C (by simp (disch := omega) only [setLocal_other, h8]) _)
          (eval_u32lit C _ _ 2 (by decide)) (binary_rem_u32 C i 2 (by omega) (by decide) (by decide)))
          (eval_u32lit C _ _ 2 (by decide)) (binary_mul_u32 C _ 2)) (binary_add_u32 C _ _)
    · rw [show 8 * (8 * y + s) + fmOf i = min (8 * (8 * y + s) + fmOf i) 17407 from (Nat.min_eq_left (by omega)).symm]
      exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C (v := u32 (8 * (8 * y + s)))
        (by simp (disch := omega) only [setLocal_other, setLocal_same]) _) (eval_local' C (v := u32 (fmOf i))
        (by simp (disch := omega) only [setLocal_other, setLocal_same]) _) (binary_add_u32 C _ _))
        (eval_u32lit C _ _ 17407 (by decide)) (binary_min_u32 C _ 17407 (by omega) (by decide))
    · rw [show 4 * ((8 * (8 * y + s) + fmOf i) * (20 * (8 * kg))) =
        0 + (8 * (8 * y + s) + fmOf i) * (160 * kg) * (Ty.scalar .u32).bytes by simp only [Ty.bytes, Scalar.bytes]; ring]
      exact eval_offset_u64 C (o := 0) (eval_local' C (v := .ptr ⟨2, 0, .scalar .u32⟩)
        (by simp (disch := omega) only [setLocal_other, h2]) sh₁)
        (eval_int C (by decide) (eval_conv C (eval_local' C (v := u32 (8 * (8 * y + s) + fmOf i))
          (by simp (disch := omega) only [setLocal_same]) _) (convert_u64_u32 C _ (by omega)))
          (by rw [← u64_lit (show 160 * kg < 2 ^ 64 by omega)]; exact eval_lit C _ _ _ _)
          (binary_mul_u64 C (8 * (8 * y + s) + fmOf i) (160 * kg)))
          (lt_of_le_of_lt (Nat.mul_le_mul (show 8 * (8 * y + s) + fmOf i ≤ 17408 by omega) (show 160 * kg ≤ 640 by omega)) (by norm_num))
    · rw [show 4 * ((8 * (8 * y + s) + fmOf i) * (20 * (8 * ku))) =
        0 + (8 * (8 * y + s) + fmOf i) * (160 * ku) * (Ty.scalar .u32).bytes by simp only [Ty.bytes, Scalar.bytes]; ring]
      exact eval_offset_u64 C (o := 0) (eval_local' C (v := .ptr ⟨4, 0, .scalar .u32⟩)
        (by simp (disch := omega) only [setLocal_other, h4]) sh₁)
        (eval_int C (by decide) (eval_conv C (eval_local' C (v := u32 (8 * (8 * y + s) + fmOf i))
          (by simp (disch := omega) only [setLocal_other, setLocal_same]) _) (convert_u64_u32 C _ (by omega)))
          (by rw [← u64_lit (show 160 * ku < 2 ^ 64 by omega)]; exact eval_lit C _ _ _ _)
          (binary_mul_u64 C (8 * (8 * y + s) + fmOf i) (160 * ku)))
          (lt_of_le_of_lt (Nat.mul_le_mul (show 8 * (8 * y + s) + fmOf i ≤ 17408 by omega) (show 160 * ku ≤ 640 by omega)) (by norm_num))
    · exact eval_bin_u32 C (eval_bin_u32 C (eval_coord2 C hl.tgpos) (eval_u32lit C _ _ 8 (by decide)) (binary_mul_u32 C z 8))
        (eval_u32lit C _ _ mt (by omega)) (binary_mul_u32 C _ mt)
  -- The accumulators' zeros.
  have hr0 : L.regions (ctx.threadArray 0) = some ⟨.thread, 8 * mt, 8⟩ := by rw [e0]; exact hS.t0 _
  have hr1 : L.regions (ctx.threadArray 1) = some ⟨.thread, 8 * mt, 8⟩ := by rw [e1]; exact hS.t1 _
  let AI : Nat → Locals → Shared → Prop := fun b L' S => (∀ q, q ≠ 29 → L' q = L₂₉ q) ∧ L' 29 = some (u32 b) ∧
    Mem C L I mt out W (40 * (y + 272 * z)) (fun e => e % 256 < 32 * s + i + 1) mb base xsOk S ∧
    TFrame (thOf y z s i) sh₁ S ∧ ∀ bk < b, F32At (S.bytes (ctx.threadArray 0)) (8 * bk) zero ∧
      F32At (S.bytes (ctx.threadArray 0)) (8 * bk + 4) zero ∧ F32At (S.bytes (ctx.threadArray 1)) (8 * bk) zero ∧
      F32At (S.bytes (ctx.threadArray 1)) (8 * bk + 4) zero
  obtain ⟨l₂, sh₂, hacc, hA⟩ := Exec.loop_count (C := C) (ctx := ctx) (c := lt 29 mt) (st := incr 29)
    (b := [.store (.vec .f32 2) (.offset (.local 27) (.local 29)) (.vector .f32 [f32l 0x0, f32l 0x0]),
      .store (.vec .f32 2) (.offset (.local 28) (.local 29)) (.vector .f32 [f32l 0x0, f32l 0x0])]) mt AI AI
    (fun b hb L' S hJ => ⟨S, eval_lt C 29 mt hJ.2.1 (by omega) (by omega), hJ⟩)
    (fun b hb L' S hJ => by
      obtain ⟨hag, h29, hmS, tfS, hz0⟩ := hJ
      have h27 : L' 27 = some (.ptr ⟨ctx.threadArray 0, 0, .vec .f32 2⟩) := by
        rw [hag 27 (by omega)]; simp (disch := omega) only [L₂₉, setLocal_other, setLocal_same]
      have h28 : L' 28 = some (.ptr ⟨ctx.threadArray 1, 0, .vec .f32 2⟩) := by
        rw [hag 28 (by omega)]; simp (disch := omega) only [L₂₉, setLocal_other, setLocal_same]
      have hp0 := eval_ptr_u32 C (ctx := ctx) (sh := S) (eval_local' C h27 S) (eval_local' C h29 S) (by omega)
      rw [show b * (Ty.vec .f32 2).bytes = 8 * b by rw [show (Ty.vec .f32 2).bytes = 8 from rfl]; ring] at hp0
      have hs0 := store_thread_f32x2 ctx S (ctx.threadArray 0) (8 * b) (8 * mt) 8 (by rw [hmS.regions]; exact hr0)
        (by decide) (by omega) (by omega) zero zero
      generalize hS₁ : Metal.tput S (ctx.threadArray 0) (8 * b)
        (wordBytes 4 (Val.f32Bits zero) ++ wordBytes 4 (Val.f32Bits zero)) = S₁ at hs0
      have hp1 := eval_ptr_u32 C (ctx := ctx) (sh := S₁) (eval_local' C h28 S₁) (eval_local' C h29 S₁) (by omega)
      rw [show b * (Ty.vec .f32 2).bytes = 8 * b by rw [show (Ty.vec .f32 2).bytes = 8 from rfl]; ring] at hp1
      have hs1 := store_thread_f32x2 ctx S₁ (ctx.threadArray 1) (8 * b) (8 * mt) 8
        (by rw [← hS₁, tput_regions, hmS.regions]; exact hr1) (by decide) (by omega) (by omega) zero zero
      have hv : ∀ (S' : Shared), (eval C ctx L' (.vector .f32 [f32l 0x0, f32l 0x0])).run S' =
          some (.vec .f32 [.f32 zero, .f32 zero], S') := fun S' =>
        eval_vector C (evalList_cons C (eval_lit C _ _ _ _) (evalList_cons C (eval_lit C _ _ _ _) (evalList_nil C)))
      have n01 : ctx.threadArray 0 ≠ ctx.threadArray 1 := by rw [e0, e1]; exact ta_ne (by decide)
      refine ⟨.normal, L', _, setLocal L' 29 (u32 (b + 1)), _, .inl rfl,
        .store hp0 (hv S) hs0 (.store hp1 (hv S₁) hs1 (.nil _ _)), exec_incr C 29 h29,
        fun q hq => by rw [setLocal_other _ _ hq, hag q hq], setLocal_same _ _ _,
        (show Mem C L I mt out W (40 * (y + 272 * z)) (fun e => e % 256 < 32 * s + i + 1) mb base xsOk S₁ by
          rw [← hS₁]; exact hmS.tput _ _ (by rw [e0]; exact ta_ge _ _)).tput _ _ (by rw [e1]; exact ta_ge _ _),
        fun ρ h9 hρ => by
          rw [tput_other _ _ _ (by rw [e1]; exact ne_ta hρ (by decide)), ← hS₁,
            tput_other _ _ _ (by rw [e0]; exact ne_ta hρ (by decide)), tfS ρ h9 hρ],
        fun bk hbk => ?_⟩
      rw [tput_other _ _ _ n01, tput_same, ← hS₁, tput_same, tput_other _ _ _ n01.symm]
      by_cases hbb : bk = b
      · subst hbb
        exact ⟨(f32At_put2 _ _ _ _).1, (f32At_put2 _ _ _ _).2, (f32At_put2 _ _ _ _).1, (f32At_put2 _ _ _ _).2⟩
      · obtain ⟨a, b', c, d⟩ := hz0 bk (by omega)
        have hl8 : (wordBytes 4 (Val.f32Bits zero) ++ wordBytes 4 (Val.f32Bits zero)).length = 8 := by
          simp [wordBytes_length]
        refine ⟨f32At_keep _ (by rw [hl8]; omega) a, f32At_keep _ (by rw [hl8]; omega) b', ?_, ?_⟩
        · exact f32At_keep _ (by rw [hl8]; omega) c
        · exact f32At_keep _ (by rw [hl8]; omega) d)
    (l := L₂₉) (sh := sh₁) ⟨fun _ _ => rfl, by simp only [L₂₉, setLocal_same], hmf, TFrame.refl _ _,
      fun _ h => absurd h (by omega)⟩
  obtain ⟨hag₂, -, hm₂, tf₂, hz₂⟩ := hA
  -- `base = 0`, into the first step: the first barrier.
  have hc30 := eval_lt C (ctx := ctx) (sh := sh₂) 30 5120 (setLocal_same l₂ 30 (u32 0)) (by decide) (by decide)
  have hb1 : Exec C ctx (stepBody kg ku mt) (setLocal l₂ 30 (u32 0)) sh₂
      (.stop (.barrier 1 false true) [.block (stepRest1 kg ku mt)]) (setLocal l₂ 30 (u32 0)) sh₂ := by
    rw [stepBody_eq]; exact .barrier
  have hS0 : Exec C ctx (S0 kg ku mt) L₇ sh (.stop (.barrier 1 false true)
      ([.block (stepRest1 kg ku mt)] ++ [.loop baseCond baseStep (stepBody kg ku mt), .block (afterBase kg ku mt)]))
      (setLocal l₂ 30 (u32 0)) sh₂ := by
    rw [S0_eq]
    exact (hsA.append (hfill.append hsetup)).append (hacc.append (.set (eval_u32lit C _ _ 0 (by decide))
      (.loop_stop hc30 hb1)))
  have hex : Exec C ctx (body kg ku mt) (fun _ => none) sh (.stop (.barrier 1 false true)
      (([.block (stepRest1 kg ku mt)] ++ [.loop baseCond baseStep (stepBody kg ku mt), .block (afterBase kg ku mt)]) ++
        [.scope, .block []])) (setLocal l₂ 30 (u32 0)) sh₂ := by
    rw [body_eq]; exact hpre.append (.scope_stop hS0)
  have hL : ∀ q, q ≤ 28 → setLocal l₂ 30 (u32 0) q = L₂₉ q := fun q hq => by
    rw [setLocal_other _ _ (by omega), hag₂ q (by omega)]
  have hL₁₃ : ∀ q, q < 13 → L₂₉ q = L₁₃ q := fun q hq => by
    simp (disch := omega) only [L₂₉, setLocal_other]; exact k q hq
  refine ⟨_, sh₂, (hex.reaches_stop (K := [])).ev_stop rfl, hm₂,
    fun ρ h9 hρ => by rw [tf₂ ρ h9 hρ, hbf ρ h9, show (rdn ctx sh 1 0 4).bytes ρ = sh.bytes ρ from rfl],
    fun b hb => ?_, rfl, rfl, rfl, ?_, (setLocal_same l₂ 30 (u32 0) : setLocal l₂ 30 (u32 0) 30 = some (u32 (256 * 0)))⟩
  · obtain ⟨a, b', c, d⟩ := hz₂ b hb
    rw [tm_lt _ (by decide)]; rw [tm_lt _ (by decide), ← e0, ← e1]
    exact ⟨a, b', c, d⟩
  · have g : ∀ q, q < 13 → setLocal l₂ 30 (u32 0) q = L₁₃ q := fun q hq => by rw [hL q (by omega), hL₁₃ q hq]
    show Fix kg ku mt I.r y z s i (setLocal l₂ 30 (u32 0))
    refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · rw [g 0 (by omega)]; simp (disch := omega) only [L₁₃, L₇, setLocal_other, setLocal_same]
    · rw [g 3 (by omega)]; simp (disch := omega) only [L₁₃, L₇, setLocal_other, setLocal_same]
    · rw [g 5 (by omega)]; simp (disch := omega) only [L₁₃, L₇, setLocal_other, setLocal_same]
    · rw [g 6 (by omega)]; simp (disch := omega) only [L₁₃, L₇, setLocal_other, setLocal_same]
    · rw [g 7 (by omega)]; simp (disch := omega) only [L₁₃, setLocal_other, setLocal_same]
    · rw [g 10 (by omega)]; simp (disch := omega) only [L₁₃, setLocal_other, setLocal_same]
    · rw [g 11 (by omega)]; simp (disch := omega) only [L₁₃, setLocal_other, setLocal_same, hga0]
    · rw [g 12 (by omega)]; simp (disch := omega) only [L₁₃, setLocal_other, setLocal_same, hga1]
    all_goals (rw [hL _ (by omega)]; simp (disch := omega) only [L₂₉, setLocal_other, setLocal_same, e0, e1])

end Lane0


theorem stageBody_eq : stageBody = [.set 32 (GateUpMmaWide.u32 .div (.local 31) (u32l 64)),
    .set 33 (GateUpMmaWide.u32 .rem (.local 31) (u32l 64)),
    .set 34 (GateUpMmaWide.u32 .add (.local 26) (.local 32)),
    .set 35 (.cond (GateUpMmaWide.u32 .lt (.local 34) (.local 7))
      (.load (.vec .bf16 4) (.offset (.ptrCast (.vec .bf16 4)
        (.offset (.offset (.local 0) (GateUpMmaWide.u64 .mul (toU64 (.local 34)) (u64l 5120))) (.local 30))) (.local 33)))
      (.vector .bf16 [bf16l 0x0, bf16l 0x0, bf16l 0x0, bf16l 0x0]))] ++
    [stageStore 0, stageStore 1, stageStore 2, stageStore 3] := rfl

theorem zero_bytes : wordBytes 2 (Val.bf16Bits (Val.ofBf16Bits 0)) = [0, 0] := rfl

section Stage
variable (C : M1Max.Contract) {L : Launch} {kg ku mt : Nat} {I : In} {out : Nat → BF} {W : Nat → Prop} {ctx : Ctx}

/-- One staging store `xs[r][4·c4 + ii] = v[ii]`: element `4·e + ii` of `xs`. -/
theorem exec_stageStore (hS : Shape L kg ku mt I) (hmt : mt ≤ 3) {y z s k e ii : Nat} {i : Fin 32}
    (hl : Lane ctx y z s i) (hii : ii < 4) (he : e < 512 * mt) (hee : e % 256 = 32 * s + i) {l : Locals}
    (h12 : l 12 = some (.ptr ⟨8, 0, .scalar .bf16⟩)) (h32 : l 32 = some (u32 (e / 64)))
    (h33 : l 33 = some (u32 (e % 64))) {vs : List Val} {x : Val} (h35 : l 35 = some (.vec .bf16 vs))
    (hx : vs[ii]? = some x) (henc : encode (.scalar .bf16) x = some (stg I.X I.r (z * 8 * mt) (256 * k) (4 * e + ii)))
    {P : Nat → Prop} {sh : Shared}
    (hm : Mem C L I mt out W (40 * (y + 272 * z) + 2 * k + 1) (fun _ => True) (z * 8 * mt) (256 * k) P sh) :
    Exec C ctx [stageStore ii] l sh .normal l
      (wrn ctx sh 8 (2 * (4 * e + ii)) 2 (stg I.X I.r (z * 8 * mt) (256 * k) (4 * e + ii))) ∧
    Mem C L I mt out W (40 * (y + 272 * z) + 2 * k + 1) (fun _ => True) (z * 8 * mt) (256 * k)
      (fun q => P q ∨ q = 4 * e + ii) (wrn ctx sh 8 (2 * (4 * e + ii)) 2 (stg I.X I.r (z * 8 * mt) (256 * k) (4 * e + ii))) := by
  have hidx : (eval C ctx l (GateUpMmaWide.u64 .mul (toU64 (.local 32)) (u64l 256))).run sh = some (u64 (e / 64 * 256), sh) :=
    eval_int C (by decide) (eval_conv C (eval_local' C h32 sh) (convert_u64_u32 C _ (by omega))) (eval_lit C _ _ _ _)
      (binary_mul_u64 C _ 256)
  have hp1 := eval_offset_u64 C (o := 0) (eval_local' C h12 sh) hidx (by omega)
  have hc4 : (eval C ctx l (GateUpMmaWide.u32 .mul (.local 33) (u32l 4))).run sh = some (u32 (e % 64 * 4), sh) :=
    eval_bin_u32 C (eval_local' C h33 sh) (eval_u32lit C _ _ 4 (by decide)) (binary_mul_u32 C _ 4)
  have hp2 := eval_offset_u32 C hp1 hc4 (by omega)
  have hp3 := eval_ptrCast C (t := .scalar .bf16) (eval_ptrCast C (t := .vec .bf16 4) hp2)
  have hp4 := eval_offset_i32 C (o := 0 + e / 64 * 256 * (Ty.scalar .bf16).bytes + e % 64 * 4 * (Ty.scalar .bf16).bytes)
    (n := ii) hp3 (eval_lit C _ _ _ _) (by omega)
  rw [show 0 + e / 64 * 256 * (Ty.scalar .bf16).bytes + e % 64 * 4 * (Ty.scalar .bf16).bytes + ii * (Ty.scalar .bf16).bytes =
    2 * (4 * e + ii) by simp only [Ty.bytes, Scalar.bytes]; omega] at hp4
  have hv : (eval C ctx l (.component (.local 35) (u32l ii))).run sh = some (x, sh) :=
    eval_component C (eval_local' C h35 sh) (eval_u32lit C _ _ ii (by omega)) (by rw [natOf_u32, Nat.mod_eq_of_lt (by omega)]) hx
  have hst := store_shared ctx .bf16 sh 8 (2 * (4 * e + ii)) _ x _ (by rw [hm.regions]; exact hS.r8) (by simp) (by simp)
    (by simp [Scalar.bytes]) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) henc
  refine ⟨.store hp4 hv hst (.nil _ _), hm.wxs hS ctx (4 * e + ii) (by omega) ⟨by omega, by omega⟩ ?_ hl.group⟩
  rw [hl.thread]; unfold thOf; omega

/-- One staged chunk `e`: four elements of row `e / 64`, from `x` or zero past row `M`. -/
theorem exec_stage (hS : Shape L kg ku mt I) (hmt : 1 ≤ mt ∧ mt ≤ 3) (hr : I.r < 2 ^ 16) {y z s k e : Nat} {i : Fin 32}
    (hl : Lane ctx y z s i) (hk : k < 20) (hz : z * 8 * mt < I.r + 8 * mt) (he : e < 512 * mt)
    (hee : e % 256 = 32 * s + i) {l : Locals} (hF : Fix kg ku mt I.r y z s i l) (h30 : l 30 = some (u32 (256 * k)))
    (h31 : l 31 = some (u32 e)) {P : Nat → Prop} {sh : Shared}
    (hm : Mem C L I mt out W (40 * (y + 272 * z) + 2 * k + 1) (fun _ => True) (z * 8 * mt) (256 * k) P sh) :
    ∃ l' sh', Exec C ctx stageBody l sh .normal l' sh' ∧
      Mem C L I mt out W (40 * (y + 272 * z) + 2 * k + 1) (fun _ => True) (z * 8 * mt) (256 * k)
        (fun q => P q ∨ q / 4 = e) sh' ∧ (∀ q, (q < 32 ∨ 35 < q) → l' q = l q) ∧ (∀ ρ, 9 ≤ ρ → sh'.bytes ρ = sh.bytes ρ) := by
  have e32 : (eval C ctx l (GateUpMmaWide.u32 .div (.local 31) (u32l 64))).run sh = some (u32 (e / 64), sh) :=
    eval_bin_u32 C (eval_local' C h31 sh) (eval_u32lit C _ _ 64 (by decide)) (binary_div_u32 C e 64 (by omega) (by decide) (by decide))
  have e33 : (eval C ctx (setLocal l 32 (u32 (e / 64))) (GateUpMmaWide.u32 .rem (.local 31) (u32l 64))).run sh =
      some (u32 (e % 64), sh) :=
    eval_bin_u32 C (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact h31) sh) (eval_u32lit C _ _ 64 (by decide))
      (binary_rem_u32 C e 64 (by omega) (by decide) (by decide))
  have e34 : (eval C ctx (setLocal (setLocal l 32 (u32 (e / 64))) 33 (u32 (e % 64)))
      (GateUpMmaWide.u32 .add (.local 26) (.local 32))).run sh = some (u32 (z * 8 * mt + e / 64), sh) :=
    eval_bin_u32 C (eval_local' C (by simp (disch := omega) only [setLocal_other, hF.l26]) sh)
      (eval_local' C (by simp (disch := omega) only [setLocal_other, setLocal_same]) sh) (binary_add_u32 C _ _)
  generalize hL₃ : setLocal (setLocal (setLocal l 32 (u32 (e / 64))) 33 (u32 (e % 64))) 34 (u32 (z * 8 * mt + e / 64)) = L₃
  have h34 : L₃ 34 = some (u32 (z * 8 * mt + e / 64)) := by rw [← hL₃, setLocal_same]
  have h33 : L₃ 33 = some (u32 (e % 64)) := by rw [← hL₃]; simp (disch := omega) only [setLocal_other, setLocal_same]
  have hc := eval_bin_u32 C (ctx := ctx) (sh := sh) (op := .lt) (site := 0) (eval_local' C h34 sh)
    (eval_local' C (i := 7) (v := u32 I.r) (by rw [← hL₃]; simp (disch := omega) only [setLocal_other, hF.l7]) sh)
    (binary_lt_u32 C (z * 8 * mt + e / 64) I.r (by omega) (by omega))
  -- `v`: the four elements, as their stored bytes.
  obtain ⟨vs, sh₁, e35, hvs, hm₁, hb₁⟩ : ∃ vs sh₁, (eval C ctx L₃ (.cond (GateUpMmaWide.u32 .lt (.local 34) (.local 7))
      (.load (.vec .bf16 4) (.offset (.ptrCast (.vec .bf16 4)
        (.offset (.offset (.local 0) (GateUpMmaWide.u64 .mul (toU64 (.local 34)) (u64l 5120))) (.local 30))) (.local 33)))
      (.vector .bf16 [bf16l 0x0, bf16l 0x0, bf16l 0x0, bf16l 0x0]))).run sh = some (.vec .bf16 vs, sh₁) ∧
      (∀ ii < 4, ∃ x, vs[ii]? = some x ∧
        encode (.scalar .bf16) x = some (stg I.X I.r (z * 8 * mt) (256 * k) (4 * e + ii))) ∧
      Mem C L I mt out W (40 * (y + 272 * z) + 2 * k + 1) (fun _ => True) (z * 8 * mt) (256 * k) P sh₁ ∧
      (∀ ρ, 9 ≤ ρ → sh₁.bytes ρ = sh.bytes ρ) := by
    by_cases hmr : z * 8 * mt + e / 64 < I.r
    · rw [decide_eq_true hmr] at hc
      have hidx : (eval C ctx L₃ (GateUpMmaWide.u64 .mul (toU64 (.local 34)) (u64l 5120))).run sh =
          some (u64 ((z * 8 * mt + e / 64) * 5120), sh) :=
        eval_int C (by decide) (eval_conv C (eval_local' C h34 sh) (convert_u64_u32 C _ (by omega))) (eval_lit C _ _ _ _)
          (binary_mul_u64 C _ 5120)
      have hp1 := eval_offset_u64 C (o := 0)
        (eval_local' C (i := 0) (v := .ptr ⟨0, 0, .scalar .bf16⟩) (by rw [← hL₃]; simp (disch := omega) only [setLocal_other, hF.l0]) sh) hidx (by omega)
      have hp2 := eval_offset_u32 C hp1
        (eval_local' C (i := 30) (v := u32 (256 * k)) (by rw [← hL₃]; simp (disch := omega) only [setLocal_other, h30]) sh) (by omega)
      have hp3 := eval_offset_u32 C (eval_ptrCast C (t := .vec .bf16 4) hp2) (eval_local' C h33 sh) (by omega)
      rw [show 0 + (z * 8 * mt + e / 64) * 5120 * (Ty.scalar .bf16).bytes + 256 * k * (Ty.scalar .bf16).bytes +
        e % 64 * (Ty.vec .bf16 4).bytes = 2 * (5120 * (z * 8 * mt + e / 64) + 256 * k + 4 * (e % 64)) by
          rw [show (Ty.vec .bf16 4).bytes = 8 from rfl, show (Ty.scalar .bf16).bytes = 2 from rfl]; ring] at hp3
      have hl4 := load_bf16x4 ctx sh 0 (2 * (5120 * (z * 8 * mt + e / 64) + 256 * k + 4 * (e % 64))) _
        (by rw [hm.regions]; exact hS.r0) (by simp) hS.ax (by omega) (by simp; omega)
      rw [hm.x] at hl4
      refine ⟨_, _, eval_cond C hc (by rw [ite_eq_left rfl]; exact (eval_load C _ _ _ _ _ _ _ hp3).trans hl4),
        fun ii hii => ?_, hm.rd hS ctx 0 _ 8 (by decide), fun _ _ => rfl⟩
      have hst : stg I.X I.r (z * 8 * mt) (256 * k) (4 * e + ii) =
          cells I.X (2 * (5120 * (z * 8 * mt + e / 64) + 256 * k + 4 * (e % 64)) + 2 * ii) 2 := by
        unfold stg
        rw [show (4 * e + ii) / 256 = e / 64 by omega, ite_eq_left hmr, show (4 * e + ii) % 256 = 4 * (e % 64) + ii by omega]
        congr 1; ring
      rcases (show ii = 0 ∨ ii = 1 ∨ ii = 2 ∨ ii = 3 by omega) with rfl | rfl | rfl | rfl
      · exact ⟨_, rfl, by rw [hst]; exact encode_bfVal _ _⟩
      · exact ⟨_, rfl, by rw [hst]; exact encode_bfVal _ _⟩
      · exact ⟨_, rfl, by rw [hst]; exact encode_bfVal _ _⟩
      · exact ⟨_, rfl, by rw [hst]; exact encode_bfVal _ _⟩
    · rw [decide_eq_false hmr] at hc
      refine ⟨_, _, eval_cond C hc (by rw [ite_eq_right Bool.false_ne_true]; exact eval_vector C (evalList_cons C (eval_lit C _ _ _ _)
        (evalList_cons C (eval_lit C _ _ _ _) (evalList_cons C (eval_lit C _ _ _ _) (evalList_cons C (eval_lit C _ _ _ _)
          (evalList_nil C)))))), fun ii hii => ?_, hm, fun _ _ => rfl⟩
      have hst : stg I.X I.r (z * 8 * mt) (256 * k) (4 * e + ii) = [0, 0] := by
        unfold stg; rw [show (4 * e + ii) / 256 = e / 64 by omega, ite_eq_right hmr]
      rcases (show ii = 0 ∨ ii = 1 ∨ ii = 2 ∨ ii = 3 by omega) with rfl | rfl | rfl | rfl <;>
        exact ⟨_, rfl, by rw [hst]; exact congrArg some zero_bytes⟩
  generalize hL₄ : setLocal L₃ 35 (.vec .bf16 vs) = L₄
  have h12 : L₄ 12 = some (.ptr ⟨8, 0, .scalar .bf16⟩) := by
    rw [← hL₄, ← hL₃]; simp (disch := omega) only [setLocal_other, hF.l12]
  have h32 : L₄ 32 = some (u32 (e / 64)) := by rw [← hL₄, ← hL₃]; simp (disch := omega) only [setLocal_other, setLocal_same]
  have h33' : L₄ 33 = some (u32 (e % 64)) := by rw [← hL₄, setLocal_other _ _ (by omega)]; exact h33
  have h35 : L₄ 35 = some (.vec .bf16 vs) := by rw [← hL₄, setLocal_same]
  obtain ⟨x0, hx0, he0⟩ := hvs 0 (by decide)
  obtain ⟨x1, hx1, he1⟩ := hvs 1 (by decide)
  obtain ⟨x2, hx2, he2⟩ := hvs 2 (by decide)
  obtain ⟨x3, hx3, he3⟩ := hvs 3 (by decide)
  obtain ⟨s0, m0⟩ := exec_stageStore C hS hmt.2 hl (ii := 0) (by decide) he hee h12 h32 h33' h35 hx0 he0 hm₁
  obtain ⟨s1, m1⟩ := exec_stageStore C hS hmt.2 hl (ii := 1) (by decide) he hee h12 h32 h33' h35 hx1 he1 m0
  obtain ⟨s2, m2⟩ := exec_stageStore C hS hmt.2 hl (ii := 2) (by decide) he hee h12 h32 h33' h35 hx2 he2 m1
  obtain ⟨s3, m3⟩ := exec_stageStore C hS hmt.2 hl (ii := 3) (by decide) he hee h12 h32 h33' h35 hx3 he3 m2
  refine ⟨L₄, _, ?_, m3.mono (fun idx _ h => h) (fun e _ h => h) (fun q _ h => ?_), fun q hq => ?_, fun ρ hρ => ?_⟩
  · rw [stageBody_eq, ← hL₄, ← hL₃]
    exact .set e32 (.set e33 (.set e34 (by rw [hL₃]; exact .set e35 (by
      rw [hL₄]; exact s0.append (s1.append (s2.append s3))))))
  · rcases h with h | h
    · exact .inl (.inl (.inl (.inl h)))
    · by_cases h0 : q = 4 * e
      · exact .inl (.inl (.inl (.inr h0)))
      · by_cases h1 : q = 4 * e + 1
        · exact .inl (.inl (.inr h1))
        · by_cases h2 : q = 4 * e + 2
          · exact .inl (.inr h2)
          · exact .inr (by omega)
  · rw [← hL₄, ← hL₃]; simp (disch := omega) only [setLocal_other]
  · rw [wrn_other _ _ _ _ _ (by omega), wrn_other _ _ _ _ _ (by omega), wrn_other _ _ _ _ _ (by omega),
      wrn_other _ _ _ _ _ (by omega), hb₁ ρ hρ]

/-- Resumed after the first barrier of step `k`: the staging, to the second barrier. -/
theorem lane_B1 (hS : Shape L kg ku mt I) (hmt : 1 ≤ mt ∧ mt ≤ 3) (hr : I.r < 2 ^ 16) {y z s k : Nat} {i : Fin 32}
    (hl : Lane ctx y z s i) (hk : k < 20) (hz : z * 8 * mt < I.r + 8 * mt) {t : Thread}
    (ht : AtB1 kg ku mt I.r y z s i k ctx t) {sh : Shared}
    (hm : Mem C L I mt out W (40 * (y + 272 * z) + 2 * k + 1) (fun _ => True) (z * 8 * mt) (256 * k)
      (fun q => q / 4 % 256 < 32 * s + i) sh) :
    ∃ t' sh', (Ev fun m => (runThread C m { t with status := .running }).run sh = some (t', sh')) ∧
      Mem C L I mt out W (40 * (y + 272 * z) + 2 * k + 1) (fun _ => True) (z * 8 * mt) (256 * k)
        (fun q => q / 4 % 256 < 32 * s + i + 1) sh' ∧ (∀ ρ, 9 ≤ ρ → sh'.bytes ρ = sh.bytes ρ) ∧
      t'.status = .barrier 2 false true ∧ AtB2 kg ku mt I.r y z s i k ctx t' := by
  obtain ⟨tc, tl, tf, ts⟩ := t
  obtain ⟨hc, hf, hF, h30⟩ := ht
  dsimp only at hc hf hF h30
  subst tc; subst hf
  have hs := hl.hs; have hi := i.isLt
  let SI : Nat → Locals → Shared → Prop := fun k' L' S =>
    Mem C L I mt out W (40 * (y + 272 * z) + 2 * k + 1) (fun _ => True) (z * 8 * mt) (256 * k)
      (fun q => q / 4 % 256 < 32 * s + i ∨ (q / 4 % 256 = 32 * s + i ∧ q / 4 / 256 < k')) S ∧
    L' 31 = some (u32 (32 * s + i + 256 * k')) ∧ (∀ q, (q < 31 ∨ 35 < q) → L' q = tl q) ∧
    (∀ ρ, 9 ≤ ρ → S.bytes ρ = sh.bytes ρ)
  obtain ⟨l', sh', hloop, hI⟩ := Exec.loop_count (C := C) (ctx := ctx) (c := stageCond mt) (st := stageStep)
    (b := stageBody) (2 * mt) SI SI
    (fun k' hk' L' S hJ => ⟨S, by
      have := eval_lt C (ctx := ctx) (sh := S) 31 (512 * mt) hJ.2.1 (by omega) (by omega)
      rwa [show decide (32 * s + i + 256 * k' < 512 * mt) = decide (k' < 2 * mt) from
        decide_eq_decide.mpr (by omega)] at this, hJ⟩)
    (fun k' hk' L' S hJ => by
      obtain ⟨hmS, h31, hag, hbS⟩ := hJ
      obtain ⟨l₁, sh₁, hx, hm₁, hag₁, hb₁⟩ := exec_stage C hS hmt hr hl hk hz (e := 32 * s + i + 256 * k') (by omega)
        (by omega) (hF.of_eq fun q hq => hag q (by omega)) (by rw [hag 30 (by omega)]; exact h30) h31 hmS
      refine ⟨.normal, l₁, sh₁, setLocal l₁ 31 (u32 (32 * s + i + 256 * k' + 256)), sh₁, .inl rfl, hx,
        .set (eval_bin_u32 C (eval_local' C (by rw [hag₁ 31 (by omega)]; exact h31) _) (eval_u32lit C _ _ 256 (by decide))
          (binary_add_u32 C _ 256)) (.nil _ _), hm₁.mono (fun idx _ h => h) (fun e _ h => h) (fun q _ h => ?_),
        by rw [setLocal_same, show 32 * s + i + 256 * k' + 256 = 32 * s + i + 256 * (k' + 1) by ring],
        fun q hq => by rw [setLocal_other _ _ (by omega), hag₁ q (by omega), hag q hq],
        fun ρ hρ => (hb₁ ρ hρ).trans (hbS ρ hρ)⟩
      rcases h with h | ⟨h1, h2⟩
      · exact .inl (.inl h)
      · by_cases h3 : q / 4 / 256 < k'
        · exact .inl (.inr ⟨h1, h3⟩)
        · exact .inr (by omega))
    (l := setLocal tl 31 (u32 (32 * s + i))) (sh := sh)
    ⟨hm.mono (fun idx _ h => h) (fun e _ h => h) (fun q _ h => by rcases h with h | ⟨-, h⟩ <;> omega),
      by rw [setLocal_same, Nat.mul_zero, Nat.add_zero], fun q hq => setLocal_other _ _ (by omega), fun _ _ => rfl⟩
  obtain ⟨hm', -, hag', hb'⟩ := hI
  have hex : Exec C ctx (stepRest1 kg ku mt) tl sh (.stop (.barrier 2 false true) [.block (stepRest2 kg ku mt)]) l' sh' := by
    rw [stepRest1_eq]
    exact (Exec.set (eval_local' C hF.l10 sh) hloop).append .barrier
  refine ⟨_, sh', (hex.reaches_stop (K := K1 kg ku mt)).ev_stop rfl,
    hm'.mono (fun idx _ h => h) (fun e _ h => h) (fun q hq h => ?_), hb', rfl, rfl, rfl,
    hF.of_eq fun q hq => hag' q (by omega), show l' 30 = _ by rw [hag' 30 (by omega)]; exact h30⟩
  omega

end Stage


/-! ## SIMD-groups -/

/-- The first thread of SIMD-group `s` of threadgroup `(y, z)`. -/
def t0 (y z s : Nat) : Nat := (y + 272 * z) * 256 + 32 * s

theorem thOf_eq (y z s : Nat) (i : Fin 32) : thOf y z s i = t0 y z s + i := by unfold thOf t0; omega

section Simd
variable (C : M1Max.Contract) {L : Launch} {kg ku mt : Nat} {I : In}

/-- A compute segment's end for SIMD-group `s` (memory part): for `k < 19` the accumulators after the step; for the last
step the lanes' outputs. -/
def EndSh (C : M1Max.Contract) (L : Launch) (kg ku mt : Nat) (I : In) (W : Nat → Prop) (y z s k : Nat) (sh₀ sh : Shared) :
    Prop :=
  SFrame (t0 y z s) (t0 y z s + 32) sh₀ sh ∧
  (k + 1 < 20 → Mem C L I mt (outF C kg ku I) W (40 * (y + 272 * z) + 2 * k + 2) (fun _ => True) (z * 8 * mt) (256 * k)
      (fun _ => True) sh ∧ ∀ i : Fin 32, OwnB C kg ku mt I y z s i (k + 1) (tm (t0 y z s + i) sh)) ∧
  (k = 19 → Mem C L I mt (outF C kg ku I) (fun idx => W idx ∨ ∃ i : Fin 32, Mine mt I.r y z s i mt 0 idx)
      (40 * (y + 272 * z) + 2 * k + 2) (fun _ => True) (z * 8 * mt) (256 * k) (fun _ => True) sh)

/-- A compute segment's end for a lane: the next step's first barrier, or the end. -/
def EndT (kg ku mt r y z s k : Nat) (ctx : Ctx) (i : Fin 32) (t : Thread) : Prop :=
  (k + 1 < 20 → t.status = .barrier 1 false true ∧ AtB1 kg ku mt r y z s i (k + 1) ctx t) ∧ (k = 19 → t.status = .done)

variable (hS : Shape L kg ku mt I) (hmt : 1 ≤ mt ∧ mt ≤ 3) {y z s : Nat} (ctxs : Fin 32 → Ctx) (hL : ∀ i : Fin 32, Lane (ctxs i) y z s i)
include hS hmt hL

/-- The lanes from the start to the first barrier. -/
theorem simd_A (r : Nat) {W : Nat → Prop} {out : Nat → BF} {mb base : Nat} {xsOk : Nat → Prop} {sh : Shared}
    (hKg : GateUp.Width kg) (hKu : GateUp.Width ku) (hr : 0 < I.r ∧ I.r < 2 ^ 16)
    (hm : Mem C L I mt out W (40 * (y + 272 * z)) (fun e => e % 256 < 32 * s) mb base xsOk sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared), (Ev fun m => (runSimd C m (r + 1) (List.ofFn fun i =>
        (⟨ctxs i, fun _ => none, [.block (body kg ku mt)], .running⟩ : Thread))).run sh = some (List.ofFn V, sh')) ∧
      Mem C L I mt out W (40 * (y + 272 * z)) (fun e => e % 256 < 32 * s + 32) mb base xsOk sh' ∧
      SFrame (t0 y z s) (t0 y z s + 32) sh sh' ∧ (∀ i, OwnB C kg ku mt I y z s i 0 (tm (t0 y z s + i) sh')) ∧
      ∀ i, (V i).status = .barrier 1 false true ∧ AtB1 kg ku mt I.r y z s i 0 (ctxs i) (V i) := by
  obtain ⟨V, sh', hev, hM, hO, hF, hR⟩ := sweep_blocked_ev C r _ (t0 y z s) sh
    (fun idx sh => Mem C L I mt out W (40 * (y + 272 * z)) (fun e => e % 256 < 32 * s + idx) mb base xsOk sh)
    (fun _ _ => True) (fun i B => OwnB C kg ku mt I y z s i 0 B)
    (fun i t => t.status = .barrier 1 false true ∧ AtB1 kg ku mt I.r y z s i 0 (ctxs i) t)
    (fun i sh hM _ => by
      obtain ⟨t, sh', hev, hm', tf, ho, hst, hat⟩ := lane_start C hS hKg hKu hmt hr (hL i) hM
      rw [thOf_eq] at tf ho
      exact ⟨t, sh', hev, hm'.mono (fun _ _ h => h) (fun e _ h => by omega) (fun _ _ h => h), tf, ho,
        by rw [hst]; rfl, hst, hat⟩)
    sh (by simpa using hm) (fun _ => trivial) (SFrame.refl _ _ _)
  exact ⟨V, sh', hev, hM, hF, hO, hR⟩

/-- The staging of step `k`: from the first barrier to the second. -/
theorem simd_B (r : Nat) {W : Nat → Prop} {out : Nat → BF} {k : Nat} (hk : k < 20) (hr : 0 < I.r ∧ I.r < 2 ^ 16)
    (hz : z * 8 * mt < I.r + 8 * mt) (U : Fin 32 → Thread) (hU : ∀ i, AtB1 kg ku mt I.r y z s i k (ctxs i) (U i))
    {sh : Shared} (hm : Mem C L I mt out W (40 * (y + 272 * z) + 2 * k + 1) (fun _ => True) (z * 8 * mt) (256 * k)
      (fun q => q / 4 % 256 < 32 * s) sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared), (Ev fun m => (runSimd C m (r + 1) (List.ofFn fun i =>
        { U i with status := .running })).run sh = some (List.ofFn V, sh')) ∧
      Mem C L I mt out W (40 * (y + 272 * z) + 2 * k + 1) (fun _ => True) (z * 8 * mt) (256 * k)
        (fun q => q / 4 % 256 < 32 * s + 32) sh' ∧ (∀ ρ, 9 ≤ ρ → sh'.bytes ρ = sh.bytes ρ) ∧
      ∀ i, (V i).status = .barrier 2 false true ∧ AtB2 kg ku mt I.r y z s i k (ctxs i) (V i) := by
  obtain ⟨V, sh', hev, hM, -, -, hR⟩ := sweep_blocked_ev C r _ (t0 y z s) sh
    (fun idx sh' => Mem C L I mt out W (40 * (y + 272 * z) + 2 * k + 1) (fun _ => True) (z * 8 * mt) (256 * k)
      (fun q => q / 4 % 256 < 32 * s + idx) sh' ∧ ∀ ρ, 9 ≤ ρ → sh'.bytes ρ = sh.bytes ρ)
    (fun _ _ => True) (fun _ _ => True)
    (fun i t => t.status = .barrier 2 false true ∧ AtB2 kg ku mt I.r y z s i k (ctxs i) t)
    (fun i sh₁ hM _ => by
      obtain ⟨t, sh', hev, hm', hb, hst, hat⟩ := lane_B1 C hS hmt hr.2 (hL i) hk hz (hU i) hM.1
      exact ⟨t, sh', hev, ⟨hm'.mono (fun _ _ h => h) (fun _ _ h => h) (fun q _ h => by omega),
        fun ρ hρ => (hb ρ hρ).trans (hM.2 ρ hρ)⟩, fun ρ h9 _ => hb ρ h9, trivial, by rw [hst]; rfl, hst, hat⟩)
    sh ⟨by simpa using hm, fun _ _ => rfl⟩ (fun _ => trivial) (SFrame.refl _ _ _)
  exact ⟨V, sh', hev, hM.1, hM.2, hR⟩

omit hL in
/-- Lanes at the gate multiply of position `j`, row block `bk`: resumed with its result, to the up multiply, then on
as `hcont` says. -/
theorem simd_G {W : Nat → Prop} {k j bk : Nat} (hbk : bk < mt) (sh₀ : Shared) (rr : Nat) (J : Shared → Prop)
    (R : Fin 32 → Thread → Prop)
    (hcont : ∀ (U : Fin 32 → Thread) sh, (∀ i, AtC kg ku mt I.r y z s i k j bk 1 (ctxs i) (U i)) →
      Mem C L I mt (outF C kg ku I) W (40 * (y + 272 * z) + 2 * k + 2) (fun _ => True) (z * 8 * mt) (256 * k)
        (fun _ => True) sh →
      (∀ i, OwnC C kg ku mt I y z s i k j bk 1 (tm (t0 y z s + i) sh)) → SFrame (t0 y z s) (t0 y z s + 32) sh₀ sh →
      ∃ (V : Fin 32 → Thread) (sh' : Shared), (Ev fun m => (runSimd C m rr (List.ofFn fun i =>
        { U i with status := .running }.set 123 (resU C ku mt I y z s k j bk i))).run sh = some (List.ofFn V, sh')) ∧
        J sh' ∧ ∀ i, R i (V i))
    (U : Fin 32 → Thread) (hU : ∀ i, AtC kg ku mt I.r y z s i k j bk 0 (ctxs i) (U i)) (sh : Shared)
    (hm : Mem C L I mt (outF C kg ku I) W (40 * (y + 272 * z) + 2 * k + 2) (fun _ => True) (z * 8 * mt) (256 * k)
      (fun _ => True) sh)
    (ho : ∀ i, OwnC C kg ku mt I y z s i k j bk 0 (tm (t0 y z s + i) sh)) (hF : SFrame (t0 y z s) (t0 y z s + 32) sh₀ sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared), (Ev fun m => (runSimd C m (rr + 1) (List.ofFn fun i =>
        { U i with status := .running }.set 122 (.vec .f32 [.f32 (AG C kg mt I y z s bk (32 * k + j + 1) i 0),
          .f32 (AG C kg mt I y z s bk (32 * k + j + 1) i 1)]))).run sh = some (List.ofFn V, sh')) ∧
      J sh' ∧ ∀ i, R i (V i) :=
  sweep_collective_ev C rr _ 4 123 (.mma .f32 .f32) .f32 0 (fun i => opsU C ku mt I y z s (32 * k + j) bk i)
    (fun i => resU C ku mt I y z s k j bk i)
    (resolve_mma C 0 (aReg C ku I.Uc (8 * y + s) (32 * k + j)) (bReg C I.r I.X (mt * z + bk) (32 * k + j))
      (AU C ku mt I y z s bk (32 * k + j))) (t0 y z s) sh₀
    (fun _ sh => Mem C L I mt (outF C kg ku I) W (40 * (y + 272 * z) + 2 * k + 2) (fun _ => True) (z * 8 * mt) (256 * k)
      (fun _ => True) sh)
    (fun i B => OwnC C kg ku mt I y z s i k j bk 0 B) (fun i B => OwnC C kg ku mt I y z s i k j bk 1 B)
    (fun i t => AtC kg ku mt I.r y z s i k j bk 1 (ctxs i) t) J R
    (fun i sh hM hO => by
      obtain ⟨t, sh', hev, hm', tf, ho', hst, hat⟩ := lane_G C hS hmt hbk (hU i) hM (by rw [thOf_eq]; exact hO)
      rw [thOf_eq] at tf ho'
      exact ⟨t, sh', hev, hm', tf, ho', hst, hat⟩)
    (fun U' sh hU' hM hO hF => hcont U' sh hU' hM hO hF) sh hm ho hF

end Simd


section Simd2
variable (C : M1Max.Contract) {L : Launch} {kg ku mt : Nat} {I : In}
variable (hS : Shape L kg ku mt I) (hKg : GateUp.Width kg) (hKu : GateUp.Width ku) (hmt : 1 ≤ mt ∧ mt ≤ 3)
  (hr : 0 < I.r ∧ I.r < 2 ^ 16) {y z s : Nat} (ctxs : Fin 32 → Ctx) (hL : ∀ i : Fin 32, Lane (ctxs i) y z s i)
include hS hKg hKu hmt hr hL

/-- Lanes resumed with the up multiply's result at position `j`, row block `bk` of step `k`: the rest of the step's
collectives (`N` positions after this one), to its end. -/
theorem simd_U {W : Nat → Prop} {k : Nat} (hk : k < 20) (hz : z * 8 * mt < I.r + 8 * mt) (sh₀ : Shared) :
    ∀ N j bk, (31 - j) * mt + (mt - 1 - bk) = N → j < 32 → bk < mt → ∀ (U : Fin 32 → Thread) (sh : Shared) (rr : Nat),
      2 * N + 1 ≤ rr → (∀ i, AtC kg ku mt I.r y z s i k j bk 1 (ctxs i) (U i)) →
      Mem C L I mt (outF C kg ku I) W (40 * (y + 272 * z) + 2 * k + 2) (fun _ => True) (z * 8 * mt) (256 * k)
        (fun _ => True) sh →
      (∀ i, OwnC C kg ku mt I y z s i k j bk 1 (tm (t0 y z s + i) sh)) → SFrame (t0 y z s) (t0 y z s + 32) sh₀ sh →
      ∃ (V : Fin 32 → Thread) (sh' : Shared), (Ev fun m => (runSimd C m rr (List.ofFn fun i =>
        { U i with status := .running }.set 123 (resU C ku mt I y z s k j bk i))).run sh = some (List.ofFn V, sh')) ∧
        EndSh C L kg ku mt I W y z s k sh₀ sh' ∧ ∀ i, EndT kg ku mt I.r y z s k (ctxs i) i (V i) := by
  intro N
  induction N with
  | zero =>
    intro j bk hN hj hbk U sh rr hrr hU hm ho hF
    have hj31 : j = 31 := by
      have h0 : (31 - j) * mt = 0 := by omega
      rcases Nat.mul_eq_zero.mp h0 with h | h <;> omega
    subst hj31
    have hbk' : bk + 1 = mt := by omega
    obtain ⟨rr', rfl⟩ : ∃ rr', rr = rr' + 1 := ⟨rr - 1, by omega⟩
    by_cases hk19 : k + 1 < 20
    · obtain ⟨V, sh', hev, hM, hO, hF', hR⟩ := sweep_blocked_ev C rr' _ (t0 y z s) sh₀
        (fun _ sh => Mem C L I mt (outF C kg ku I) W (40 * (y + 272 * z) + 2 * k + 2) (fun _ => True) (z * 8 * mt)
          (256 * k) (fun _ => True) sh)
        (fun i B => OwnC C kg ku mt I y z s i k 31 bk 1 B) (fun i B => OwnB C kg ku mt I y z s i (k + 1) B)
        (fun i t => t.status = .barrier 1 false true ∧ AtB1 kg ku mt I.r y z s i (k + 1) (ctxs i) t)
        (fun i sh hM hO => by
          obtain ⟨t, sh', hev, hm', tf, ho', hst, hat⟩ := lane_Uk C hS hmt hk19 hbk' (hU i) hM
            (by rw [thOf_eq]; exact hO)
          rw [thOf_eq] at tf ho'
          exact ⟨t, sh', hev, hm', tf, ho', by rw [hst]; rfl, hst, hat⟩)
        sh hm ho hF
      exact ⟨V, sh', hev, ⟨hF', fun _ => ⟨hM, hO⟩, fun h => absurd h (by omega)⟩,
        fun i => ⟨fun _ => hR i, fun h => absurd h (by omega)⟩⟩
    · have hk' : k = 19 := by omega
      subst hk'
      obtain ⟨V, sh', hev, hM, -, hF', hR⟩ := sweep_blocked_ev C rr' _ (t0 y z s) sh₀
        (fun idx sh => Mem C L I mt (outF C kg ku I)
          (fun idx' => W idx' ∨ ∃ i : Fin 32, i.val < idx ∧ Mine mt I.r y z s i mt 0 idx')
          (40 * (y + 272 * z) + 2 * 19 + 2) (fun _ => True) (z * 8 * mt) (256 * 19) (fun _ => True) sh)
        (fun i B => OwnC C kg ku mt I y z s i 19 31 bk 1 B) (fun _ _ => True) (fun _ t => t.status = .done)
        (fun i sh hM hO => by
          obtain ⟨t, sh', hev, hm', tf, hst⟩ := lane_Ulast C hS hmt hr.2 (hL i) hbk' hz (hU i) hM
            (by rw [thOf_eq]; exact hO)
          rw [thOf_eq] at tf
          refine ⟨t, sh', hev, hm'.mono (fun idx _ h => ?_) (fun _ _ h => h) (fun _ _ h => h), tf, trivial,
            by rw [hst]; rfl, hst⟩
          rcases h with h | ⟨i', hi', hmi⟩
          · exact .inl (.inl h)
          · by_cases hii : i' = i
            · subst hii; exact .inr hmi
            · exact .inl (.inr ⟨i', by have := Fin.val_ne_of_ne hii; omega, hmi⟩))
        sh (hm.mono (fun idx _ h => h.elim id (fun ⟨_, h, _⟩ => absurd h (by omega))) (fun _ _ h => h) (fun _ _ h => h))
        ho hF
      exact ⟨V, sh', hev, ⟨hF', fun h => absurd h (by omega), fun _ => hM.mono
        (fun idx _ h => h.elim .inl (fun ⟨i, hi⟩ => .inr ⟨i, i.isLt, hi⟩)) (fun _ _ h => h) (fun _ _ h => h)⟩,
        fun i => ⟨fun h => absurd h (by omega), fun _ => hR i⟩⟩
  | succ N ih =>
    intro j bk hN hj hbk U sh rr hrr hU hm ho hF
    obtain ⟨rr', rfl⟩ : ∃ rr', rr = rr' + 1 := ⟨rr - 1, by omega⟩
    obtain ⟨rr'', rfl⟩ : ∃ rr'', rr' = rr'' + 1 := ⟨rr' - 1, by omega⟩
    by_cases hb : bk + 1 < mt
    · exact sweep_collective_ev C (rr'' + 1) _ 3 122 (.mma .f32 .f32) .f32 0
        (fun i => opsG C kg mt I y z s (32 * k + j) (bk + 1) i)
        (fun i => .vec .f32 [.f32 (AG C kg mt I y z s (bk + 1) (32 * k + j + 1) i 0),
          .f32 (AG C kg mt I y z s (bk + 1) (32 * k + j + 1) i 1)])
        (resolve_mma C 0 (aReg C kg I.Gc (8 * y + s) (32 * k + j)) (bReg C I.r I.X (mt * z + (bk + 1)) (32 * k + j))
          (AG C kg mt I y z s (bk + 1) (32 * k + j))) (t0 y z s) sh₀
        (fun _ sh => Mem C L I mt (outF C kg ku I) W (40 * (y + 272 * z) + 2 * k + 2) (fun _ => True) (z * 8 * mt)
          (256 * k) (fun _ => True) sh)
        (fun i B => OwnC C kg ku mt I y z s i k j bk 1 B) (fun i B => OwnC C kg ku mt I y z s i k j (bk + 1) 0 B)
        (fun i t => AtC kg ku mt I.r y z s i k j (bk + 1) 0 (ctxs i) t) _ _
        (fun i sh hM hO => by
          obtain ⟨t, sh', hev, hm', tf, ho', hst, hat⟩ := lane_Ub C hS hmt (hL i) hj hb (hU i) hM
            (by rw [thOf_eq]; exact hO)
          rw [thOf_eq] at tf ho'
          exact ⟨t, sh', hev, hm', tf, ho', hst, hat⟩)
        (fun U' sh' hU' hM hO hF' => simd_G C hS hmt ctxs hb sh₀ rr'' _ _
          (fun U'' sh'' hU'' hM' hO' hF'' => ih j (bk + 1) (by omega) hj hb U'' sh'' rr'' (by omega) hU'' hM' hO' hF'')
          U' hU' sh' hM hO hF') sh hm ho hF
    · have hbk' : bk + 1 = mt := by omega
      have hj' : j + 1 < 32 := by
        by_contra hc
        have h31 : j = 31 := by omega
        subst h31; omega
      have hN' : (31 - (j + 1)) * mt + (mt - 1 - 0) = N := by
        have e : (31 - j) * mt = (31 - (j + 1)) * mt + mt := by
          rw [show 31 - j = (31 - (j + 1)) + 1 by omega, Nat.succ_mul]
        omega
      exact sweep_collective_ev C (rr'' + 1) _ 3 122 (.mma .f32 .f32) .f32 0
        (fun i => opsG C kg mt I y z s (32 * k + (j + 1)) 0 i)
        (fun i => .vec .f32 [.f32 (AG C kg mt I y z s 0 (32 * k + (j + 1) + 1) i 0),
          .f32 (AG C kg mt I y z s 0 (32 * k + (j + 1) + 1) i 1)])
        (resolve_mma C 0 (aReg C kg I.Gc (8 * y + s) (32 * k + (j + 1)))
          (bReg C I.r I.X (mt * z + 0) (32 * k + (j + 1))) (AG C kg mt I y z s 0 (32 * k + (j + 1)))) (t0 y z s) sh₀
        (fun _ sh => Mem C L I mt (outF C kg ku I) W (40 * (y + 272 * z) + 2 * k + 2) (fun _ => True) (z * 8 * mt)
          (256 * k) (fun _ => True) sh)
        (fun i B => OwnC C kg ku mt I y z s i k j bk 1 B) (fun i B => OwnC C kg ku mt I y z s i k (j + 1) 0 0 B)
        (fun i t => AtC kg ku mt I.r y z s i k (j + 1) 0 0 (ctxs i) t) _ _
        (fun i sh hM hO => by
          obtain ⟨t, sh', hev, hm', tf, ho', hst, hat⟩ := lane_Uj C hS hKg hKu hmt (hL i) hk hj' hbk' (hU i) hM
            (by rw [thOf_eq]; exact hO)
          rw [thOf_eq] at tf ho'
          exact ⟨t, sh', hev, hm', tf, ho', hst, hat⟩)
        (fun U' sh' hU' hM hO hF' => simd_G C hS hmt ctxs hmt.1 sh₀ rr'' _ _
          (fun U'' sh'' hU'' hM' hO' hF'' => ih (j + 1) 0 hN' hj' hmt.1 U'' sh'' rr'' (by omega) hU'' hM' hO' hF'')
          U' hU' sh' hM hO hF') sh hm ho hF

/-- Step `k`'s compute segment: after the second barrier, the `64·MT` collectives, to the next step's first barrier
or the end. -/
theorem simd_C {W : Nat → Prop} {k : Nat} (hk : k < 20) (hz : z * 8 * mt < I.r + 8 * mt) (U : Fin 32 → Thread)
    (hU : ∀ i, AtB2 kg ku mt I.r y z s i k (ctxs i) (U i)) {sh : Shared}
    (hm : Mem C L I mt (outF C kg ku I) W (40 * (y + 272 * z) + 2 * k + 2) (fun _ => True) (z * 8 * mt) (256 * k)
      (fun _ => True) sh)
    (ho : ∀ i, OwnB C kg ku mt I y z s i k (tm (t0 y z s + i) sh)) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared), (Ev fun m => (runSimd C m (64 * mt + 1) (List.ofFn fun i =>
        { U i with status := .running })).run sh = some (List.ofFn V, sh')) ∧
      EndSh C L kg ku mt I W y z s k sh sh' ∧ ∀ i, EndT kg ku mt I.r y z s k (ctxs i) i (V i) := by
  have h64 : 64 * mt = (64 * mt - 1) + 1 := by omega
  refine sweep_collective_ev C (64 * mt) _ 3 122 (.mma .f32 .f32) .f32 0
    (fun i => opsG C kg mt I y z s (32 * k + 0) 0 i)
    (fun i => .vec .f32 [.f32 (AG C kg mt I y z s 0 (32 * k + 0 + 1) i 0), .f32 (AG C kg mt I y z s 0 (32 * k + 0 + 1) i 1)])
    (resolve_mma C 0 (aReg C kg I.Gc (8 * y + s) (32 * k + 0)) (bReg C I.r I.X (mt * z + 0) (32 * k + 0))
      (AG C kg mt I y z s 0 (32 * k + 0))) (t0 y z s) sh
    (fun _ sh => Mem C L I mt (outF C kg ku I) W (40 * (y + 272 * z) + 2 * k + 2) (fun _ => True) (z * 8 * mt)
      (256 * k) (fun _ => True) sh)
    (fun i B => OwnB C kg ku mt I y z s i k B) (fun i B => OwnC C kg ku mt I y z s i k 0 0 0 B)
    (fun i t => AtC kg ku mt I.r y z s i k 0 0 0 (ctxs i) t) _ _
    (fun i sh hM hO => by
      obtain ⟨t, sh', hev, hm', tf, ho', hst, hat⟩ := lane_B2 C hS hKg hKu hmt (hL i) hk (hU i) hM
        (by rw [thOf_eq]; exact hO)
      rw [thOf_eq] at tf ho'
      exact ⟨t, sh', hev, hm', tf, ho', hst, hat⟩)
    (fun U' sh' hU' hM hO hF => by
      rw [h64]
      exact simd_G C hS hmt ctxs hmt.1 sh (64 * mt - 1) _ _
        (fun U'' sh'' hU'' hM' hO' hF' => simd_U C hS hKg hKu hmt hr ctxs hL hk hz sh (31 * mt + (mt - 1)) 0 0
          (by omega) (by decide) hmt.1 U'' sh'' (64 * mt - 1) (by omega) hU'' hM' hO' hF') U' hU' sh' hM hO hF)
    sh hm ho (SFrame.refl _ _ _)

end Simd2


/-! ## Threadgroups -/

theorem t0_lt {y z : Nat} {s s' : Fin 8} (i : Fin 32) (h : s ≠ s') :
    t0 y z s' + i < t0 y z s ∨ t0 y z s + 32 ≤ t0 y z s' + i := by
  have := Fin.val_ne_of_ne h; have := i.isLt; unfold t0; omega

/-- Every element whose writer is one of threadgroup `(y, z)`'s threads is one of its lanes' elements. -/
theorem group_cover {mt r y z : Nat} (hmt : 0 < mt) (hy : y < 272) {idx : Nat} (hidx : idx < 17408 * r)
    (hw : wThread mt idx < (y + 272 * z + 1) * 256) :
    wThread mt idx < (y + 272 * z) * 256 ∨ ∃ s : Fin 8, s.val < 8 ∧ ∃ i : Fin 32, Mine mt r y z s i mt 0 idx := by
  by_cases h : wThread mt idx < (y + 272 * z) * 256
  · exact .inl h
  · right
    have hl : wThread mt idx - (y + 272 * z) * 256 < 256 := by omega
    refine ⟨⟨(wThread mt idx - (y + 272 * z) * 256) / 32, by omega⟩, Fin.isLt _,
      ⟨(wThread mt idx - (y + 272 * z) * 256) % 32, by omega⟩, mine_cover hmt hy (Fin.isLt _) hidx ?_⟩
    unfold thOf
    show _ = _ + (32 * ((wThread mt idx - (y + 272 * z) * 256) / 32) + (wThread mt idx - (y + 272 * z) * 256) % 32)
    omega

section Group
variable (C : M1Max.Contract) {L : Launch} {kg ku mt : Nat} {I : In}
variable (hS : Shape L kg ku mt I) (hKg : GateUp.Width kg) (hKu : GateUp.Width ku) (hmt : 1 ≤ mt ∧ mt ≤ 3)
  (hr : 0 < I.r ∧ I.r < 2 ^ 16) {y z : Nat} (hy : y < 272) (hz : z * 8 * mt < I.r + 8 * mt)
  (ctxOf : Fin 8 → Fin 32 → Ctx) (hL : ∀ (s : Fin 8) (i : Fin 32), Lane (ctxOf s i) y z s i)
include hS hKg hKu hmt hr hy hz hL

omit hKg hKu hy in
/-- The threadgroup from the first barrier of step `k = 19 - n` (resumed: the staging), given its run from the
second barrier. -/
theorem group_B1 (n k : Nat) (hkn : k + n = 19)
    (hB2 : ∀ (U : Fin 8 → Fin 32 → Thread) (sh : Shared),
      (∀ (s : Fin 8) (i : Fin 32), AtB2 kg ku mt I.r y z s i k (ctxOf s i) (U s i)) →
      Mem C L I mt (outF C kg ku I) (fun idx => wThread mt idx < (y + 272 * z) * 256) (40 * (y + 272 * z) + 2 * k + 1)
        (fun _ => True) (z * 8 * mt) (256 * k) (fun _ => True) sh →
      (∀ (s : Fin 8) (i : Fin 32), OwnB C kg ku mt I y z s i k (tm (t0 y z s + i) sh)) →
      ∃ sh', (Ev fun m => (runGroup C m (64 * mt + 1) (2 * n + 1) (List.ofFn fun s : Fin 8 => List.ofFn fun i =>
          { U s i with status := .running })).run (pass false true sh) = some ((), sh')) ∧
        ∃ cbOk mb base xsOk, Mem C L I mt (outF C kg ku I) (fun idx => wThread mt idx < (y + 272 * z + 1) * 256)
          (40 * (y + 272 * z + 1)) cbOk mb base xsOk sh')
    (U : Fin 8 → Fin 32 → Thread) (sh : Shared)
    (hU : ∀ (s : Fin 8) (i : Fin 32), AtB1 kg ku mt I.r y z s i k (ctxOf s i) (U s i))
    (hm : ∃ mb base xsOk, Mem C L I mt (outF C kg ku I) (fun idx => wThread mt idx < (y + 272 * z) * 256)
      (40 * (y + 272 * z) + 2 * k) (fun _ => True) mb base xsOk sh)
    (ho : ∀ (s : Fin 8) (i : Fin 32), OwnB C kg ku mt I y z s i k (tm (t0 y z s + i) sh)) :
    ∃ sh', (Ev fun m => (runGroup C m (64 * mt + 1) (2 * n + 1 + 1) (List.ofFn fun s : Fin 8 => List.ofFn fun i =>
        { U s i with status := .running })).run (pass false true sh) = some ((), sh')) ∧
      ∃ cbOk mb base xsOk, Mem C L I mt (outF C kg ku I) (fun idx => wThread mt idx < (y + 272 * z + 1) * 256)
        (40 * (y + 272 * z + 1)) cbOk mb base xsOk sh' := by
  obtain ⟨mb, base, xsOk, hm⟩ := hm
  have hk : k < 20 := by omega
  refine runGroup_barrier_ev C (by decide) (64 * mt + 1) (2 * n + 1) (fun s i => { U s i with status := .running })
    2 false true
    (fun j sh' => Mem C L I mt (outF C kg ku I) (fun idx => wThread mt idx < (y + 272 * z) * 256)
      (40 * (y + 272 * z) + 2 * k + 1) (fun _ => True) (z * 8 * mt) (256 * k) (fun q => q / 4 % 256 < 32 * j) sh' ∧
      ∀ ρ, 9 ≤ ρ → sh'.bytes ρ = sh.bytes ρ)
    (fun s i t => AtB2 kg ku mt I.r y z s i k (ctxOf s i) t)
    (fun sh' => ∃ cbOk mb base xsOk, Mem C L I mt (outF C kg ku I)
      (fun idx => wThread mt idx < (y + 272 * z + 1) * 256) (40 * (y + 272 * z + 1)) cbOk mb base xsOk sh')
    (fun j sh' hj => ?_) (fun U' sh' hU' hI => ?_) (pass false true sh)
    ⟨((Mem.pass hm).restage (z * 8 * mt) (256 * k)).mono (fun _ _ h => h) (fun _ _ h => h)
      (fun q _ h => by omega), fun _ _ => rfl⟩
  · obtain ⟨V, sh'', hev, hM, hb, hT⟩ := simd_B C hS hmt (ctxOf j) (hL j) (64 * mt) hk hr hz (fun i => U j i)
      (hU j) hj.1
    exact ⟨V, sh'', hev, ⟨hM.mono (fun _ _ h => h) (fun _ _ h => h) (fun q _ h => by omega),
      fun ρ hρ => (hb ρ hρ).trans (hj.2 ρ hρ)⟩, hT⟩
  · have hO : ∀ (s : Fin 8) (i : Fin 32), OwnB C kg ku mt I y z s i k (tm (t0 y z s + i) sh') := fun s i => by
      rw [tm_eq (th := t0 y z s + i) fun q _ => hI.2 _ (ta_ge _ _)]; exact ho s i
    exact hB2 U' sh' hU' (hI.1.mono (fun _ _ h => h) (fun _ _ h => h) (fun q hq _ => by omega)) hO

/-- The threadgroup from the second barrier of step `k = 19 - n` (resumed: the step's positions) to its end. -/
theorem group_B2 : ∀ n k, k + n = 19 → ∀ (U : Fin 8 → Fin 32 → Thread) (sh : Shared),
    (∀ (s : Fin 8) (i : Fin 32), AtB2 kg ku mt I.r y z s i k (ctxOf s i) (U s i)) →
    Mem C L I mt (outF C kg ku I) (fun idx => wThread mt idx < (y + 272 * z) * 256) (40 * (y + 272 * z) + 2 * k + 1)
      (fun _ => True) (z * 8 * mt) (256 * k) (fun _ => True) sh →
    (∀ (s : Fin 8) (i : Fin 32), OwnB C kg ku mt I y z s i k (tm (t0 y z s + i) sh)) →
    ∃ sh', (Ev fun m => (runGroup C m (64 * mt + 1) (2 * n + 1) (List.ofFn fun s : Fin 8 => List.ofFn fun i =>
        { U s i with status := .running })).run (pass false true sh) = some ((), sh')) ∧
      ∃ cbOk mb base xsOk, Mem C L I mt (outF C kg ku I) (fun idx => wThread mt idx < (y + 272 * z + 1) * 256)
        (40 * (y + 272 * z + 1)) cbOk mb base xsOk sh' := by
  intro n
  induction n with
  | zero =>
    intro k hk U sh hU hm ho
    obtain rfl : k = 19 := by omega
    obtain ⟨sh', hev, hI⟩ := runGroup_done_ev C (64 * mt + 1) 0 (fun s i => { U s i with status := .running })
      (fun j sh' => Mem C L I mt (outF C kg ku I)
        (fun idx => wThread mt idx < (y + 272 * z) * 256 ∨ ∃ s : Fin 8, s.val < j ∧ ∃ i : Fin 32, Mine mt I.r y z s i mt 0 idx)
        (40 * (y + 272 * z) + 2 * 19 + 2) (fun _ => True) (z * 8 * mt) (256 * 19) (fun _ => True) sh' ∧
        ∀ s : Fin 8, j ≤ s.val → ∀ i : Fin 32, OwnB C kg ku mt I y z s i 19 (tm (t0 y z s + i) sh'))
      (fun j sh' hj => by
        obtain ⟨V, sh'', hev, ⟨hF, -, hM⟩, hT⟩ := simd_C C hS hKg hKu hmt hr (ctxOf j) (hL j) (by decide : 19 < 20) hz
          (fun i => U j i) (hU j) hj.1 (hj.2 j le_rfl)
        refine ⟨V, sh'', hev, ⟨(hM rfl).mono (fun idx _ h => ?_) (fun _ _ h => h) (fun _ _ h => h), fun s' hs' i => ?_⟩,
          fun i => (hT i).2 rfl⟩
        · rcases h with h | ⟨s', hs', i, hi⟩
          · exact .inl (.inl h)
          · by_cases hss : s' = j
            · subst hss; exact .inr ⟨i, hi⟩
            · exact .inl (.inr ⟨s', by have := Fin.val_ne_of_ne hss; omega, i, hi⟩)
        · have hne : j ≠ s' := fun h => by subst h; omega
          rw [hF.tm (t0_lt i hne)]; exact hj.2 s' (by omega) i)
      (pass false true sh) ⟨(Mem.pass hm).mono (fun idx _ h => h.elim id (fun ⟨_, h, _⟩ => absurd h (by omega)))
        (fun _ _ h => h) (fun _ _ h => h), fun s _ i => ho s i⟩
    refine ⟨sh', hev, fun _ => True, z * 8 * mt, 256 * 19, fun _ => True, ?_⟩
    rw [show 40 * (y + 272 * z + 1) = 40 * (y + 272 * z) + 2 * 19 + 2 by ring]
    exact hI.1.mono (fun idx hidx h => group_cover hmt.1 hy hidx h) (fun _ _ h => h) (fun _ _ h => h)
  | succ n ih =>
    intro k hk U sh hU hm ho
    have hk' : k + 1 < 20 := by omega
    rw [show 2 * (n + 1) + 1 = 2 * n + 1 + 1 + 1 by ring]
    refine runGroup_barrier_ev C (by decide) (64 * mt + 1) (2 * n + 1 + 1) (fun s i => { U s i with status := .running })
      1 false true
      (fun j sh' => Mem C L I mt (outF C kg ku I) (fun idx => wThread mt idx < (y + 272 * z) * 256)
        (40 * (y + 272 * z) + 2 * k + 2) (fun _ => True) (z * 8 * mt) (256 * k) (fun _ => True) sh' ∧
        (∀ s : Fin 8, j ≤ s.val → ∀ i : Fin 32, OwnB C kg ku mt I y z s i k (tm (t0 y z s + i) sh')) ∧
        (∀ s : Fin 8, s.val < j → ∀ i : Fin 32, OwnB C kg ku mt I y z s i (k + 1) (tm (t0 y z s + i) sh')))
      (fun s i t => AtB1 kg ku mt I.r y z s i (k + 1) (ctxOf s i) t)
      (fun sh' => ∃ cbOk mb base xsOk, Mem C L I mt (outF C kg ku I)
        (fun idx => wThread mt idx < (y + 272 * z + 1) * 256) (40 * (y + 272 * z + 1)) cbOk mb base xsOk sh')
      (fun j sh' hj => ?_) (fun U' sh' hU' hI => ?_) (pass false true sh)
      ⟨Mem.pass hm, fun s _ i => ho s i, fun s h => absurd h (by omega)⟩
    · obtain ⟨V, sh'', hev, ⟨hF, hM, -⟩, hT⟩ := simd_C C hS hKg hKu hmt hr (ctxOf j) (hL j) (by omega) hz
        (fun i => U j i) (hU j) hj.1 (hj.2.1 j le_rfl)
      obtain ⟨hM', hO'⟩ := hM hk'
      refine ⟨V, sh'', hev, ⟨hM', fun s' hs' i => ?_, fun s' hs' i => ?_⟩, fun i => (hT i).1 hk'⟩
      · have hne : j ≠ s' := fun h => by subst h; omega
        rw [hF.tm (t0_lt i hne)]; exact hj.2.1 s' (by omega) i
      · by_cases hss : s' = j
        · subst hss; exact hO' i
        · rw [hF.tm (t0_lt i (Ne.symm hss))]; exact hj.2.2 s' (by have := Fin.val_ne_of_ne hss; omega) i
    · exact group_B1 C hS hmt hr hz ctxOf hL n (k + 1) (by omega) (ih (k + 1) (by omega)) U' sh' hU'
        ⟨z * 8 * mt, 256 * k, fun _ => True, by
          rw [show 40 * (y + 272 * z) + 2 * (k + 1) = 40 * (y + 272 * z) + 2 * k + 2 by ring]; exact hI.1⟩
        (fun s i => hI.2.2 s s.isLt i)

/-- A threadgroup's whole run: the start, then the 20 steps. -/
theorem group_run {mb base : Nat} {xsOk : Nat → Prop} {sh : Shared}
    (hm : Mem C L I mt (outF C kg ku I) (fun idx => wThread mt idx < (y + 272 * z) * 256) (40 * (y + 272 * z))
      (fun _ => False) mb base xsOk sh) :
    ∃ sh', (Ev fun m => (runGroup C m (64 * mt + 1) 41 (List.ofFn fun s : Fin 8 => List.ofFn fun i =>
        (⟨ctxOf s i, fun _ => none, [.block (body kg ku mt)], .running⟩ : Thread))).run sh = some ((), sh')) ∧
      ∃ cbOk mb base xsOk, Mem C L I mt (outF C kg ku I) (fun idx => wThread mt idx < (y + 272 * z + 1) * 256)
        (40 * (y + 272 * z + 1)) cbOk mb base xsOk sh' := by
  refine runGroup_barrier_ev C (by decide) (64 * mt + 1) 40 (fun s i =>
      (⟨ctxOf s i, fun _ => none, [.block (body kg ku mt)], .running⟩ : Thread)) 1 false true
    (fun j sh' => Mem C L I mt (outF C kg ku I) (fun idx => wThread mt idx < (y + 272 * z) * 256) (40 * (y + 272 * z))
      (fun e => e % 256 < 32 * j) mb base xsOk sh' ∧
      ∀ s : Fin 8, s.val < j → ∀ i : Fin 32, OwnB C kg ku mt I y z s i 0 (tm (t0 y z s + i) sh'))
    (fun s i t => AtB1 kg ku mt I.r y z s i 0 (ctxOf s i) t)
    (fun sh' => ∃ cbOk mb base xsOk, Mem C L I mt (outF C kg ku I)
      (fun idx => wThread mt idx < (y + 272 * z + 1) * 256) (40 * (y + 272 * z + 1)) cbOk mb base xsOk sh')
    (fun j sh' hj => ?_) (fun U sh' hU hI => ?_) sh
    ⟨hm.mono (fun _ _ h => h) (fun e _ h => by omega) (fun _ _ h => h), fun s h => absurd h (by omega)⟩
  · obtain ⟨V, sh'', hev, hM, hF, hO, hT⟩ := simd_A C hS hmt (ctxOf j) (hL j) (64 * mt) hKg hKu hr hj.1
    refine ⟨V, sh'', hev, ⟨hM.mono (fun _ _ h => h) (fun e _ h => by omega) (fun _ _ h => h), fun s' hs' i => ?_⟩, hT⟩
    by_cases hss : s' = j
    · subst hss; exact hO i
    · rw [hF.tm (t0_lt i (Ne.symm hss))]; exact hj.2 s' (by have := Fin.val_ne_of_ne hss; omega) i
  · have hm0 : Mem C L I mt (outF C kg ku I) (fun idx => wThread mt idx < (y + 272 * z) * 256)
        (40 * (y + 272 * z) + 2 * 0) (fun _ => True) mb base xsOk sh' := by
      rw [Nat.mul_zero, Nat.add_zero]
      exact hI.1.mono (fun _ _ h => h) (fun e _ _ => by omega) (fun _ _ h => h)
    exact group_B1 C hS hmt hr hz ctxOf hL 19 0 rfl
      (group_B2 C hS hKg hKu hmt hr hy hz ctxOf hL 19 0 rfl) U sh' hU
      ⟨mb, base, xsOk, hm0⟩ (fun s i => hI.2 s s.isLt i)

end Group


/-! ## The grid -/

theorem z_bound {r mt z : Nat} (hmt : 0 < mt) (hz : z < gz r mt) : z * 8 * mt < r + 8 * mt := by
  unfold gz ceilDiv at hz
  have h : (z + 1) * (8 * mt) ≤ r + 8 * mt - 1 := (Nat.le_div_iff_mul_le (show 0 < 8 * mt by omega)).mp hz
  have e : (z + 1) * (8 * mt) = z * 8 * mt + 8 * mt := by ring
  omega

theorem m_bound {r mt m : Nat} (hmt : 0 < mt) (hm : m < r) : m / 8 / mt < gz r mt := by
  have hk : 0 < 8 * mt := by omega
  unfold gz ceilDiv
  calc m / 8 / mt = m / (8 * mt) := Nat.div_div_eq_div_mul _ _ _
    _ ≤ (r - 1) / (8 * mt) := Nat.div_le_div_right (by omega)
    _ < (r - 1) / (8 * mt) + 1 := Nat.lt_succ_self _
    _ = (r + 8 * mt - 1) / (8 * mt) := by
      rw [show r + 8 * mt - 1 = r - 1 + 8 * mt by omega, Nat.add_div_right _ hk]

/-- Every `mid` element's writer is a thread of the grid. -/
theorem wThread_lt {mt r idx : Nat} (hmt : 0 < mt) (hidx : idx < 17408 * r) :
    wThread mt idx < 256 * (1 * 272 * gz r mt) := by
  have hq := m_bound hmt (show idx / 17408 < r by omega)
  have hl := (fm_laneOf (idx % 17408 % 8) (by omega) (idx / 17408 % 8) (by omega)).2.2
  unfold wThread wGroup
  generalize idx / 17408 / 8 / mt = q at hq ⊢
  generalize gz r mt = G at hq ⊢
  generalize laneOf (idx % 17408 % 8) (idx / 17408 % 8) = l at hl ⊢
  omega

section Launch
variable (C : M1Max.Contract) {kg ku mt : Nat} {I : In} {initial : Nat → ByteMemory.Bytes}

/-- The launch: the `272·⌈r / (8·MT)⌉` threadgroups in order. -/
theorem launch_run (hS : Shape (launch kg ku mt I initial) kg ku mt I) (hKg : GateUp.Width kg)
    (hKu : GateUp.Width ku) (hmt : 1 ≤ mt ∧ mt ≤ 3) (hr : 0 < I.r ∧ I.r < 2 ^ 16) (fuse : Nat → Bool)
    (garbage : Garbage) :
    ∃ sh, (∃ cbOk mb base xsOk, Mem C (launch kg ku mt I initial) I mt (outF C kg ku I)
        (fun idx => wThread mt idx < 256 * (1 * 272 * gz I.r mt)) (40 * (1 * 272 * gz I.r mt)) cbOk mb base xsOk sh) ∧
      Ev fun m => runLaunch C fuse (launch kg ku mt I initial) garbage m (64 * mt + 1) 41 = some ⟨sh.bytes, sh.log⟩ := by
  have hgz : 0 < gz I.r mt := by unfold gz ceilDiv; exact Nat.div_pos (by omega) (by omega)
  have hb : (launch kg ku mt I initial).buffers = buffers (bufs kg ku I) [34816 * I.r] 16 initial := rfl
  obtain ⟨sh, hI, hr'⟩ := (launch_tiles (kg := kg) (ku := ku) (initial := initial) hgz).launch_run_ev C fuse garbage
    (64 * mt + 1) 41
    (fun G sh => ∃ cbOk mb base xsOk, Mem C (launch kg ku mt I initial) I mt (outF C kg ku I)
      (fun idx => wThread mt idx < 256 * G) (40 * G) cbOk mb base xsOk sh)
    ⟨fun _ => False, 0, 0, fun _ => False, rfl, initial_input hb garbage 0 (by simp [bufs]),
      initial_input hb garbage 1 (by simp [bufs]), initial_input hb garbage 2 (by simp [bufs]),
      initial_input hb garbage 3 (by simp [bufs]), initial_input hb garbage 4 (by simp [bufs]),
      initial_input hb garbage 5 (by simp [bufs]), rfl, rfl, fun _ _ h => h.elim, fun _ _ h => h.elim,
      fun _ _ h => absurd h (by omega), fun a ha => by simp [Launch.initial] at ha⟩
    (fun bx byy bz hx hy hz sh hI => by
      obtain rfl : bx = 0 := by omega
      obtain ⟨cbOk, mb, base, xsOk, hm⟩ := hI
      have hm' := hm.reset rfl garbage (0 + byy * 1 + bz * 1 * 272)
      rw [show 0 + byy * 1 + bz * 1 * 272 = byy + 272 * bz by ring] at hm' ⊢
      obtain ⟨sh', hr'', cbOk', mb', base', xsOk', hm''⟩ := group_run C hS hKg hKu hmt hr hy (z_bound hmt.1 hz)
        (fun s i => (launch kg ku mt I initial).ctxAt fuse 0 byy bz (32 * s + i)) (fun s i => lane_of hgz fuse hy s i)
        (hm'.mono (fun _ _ h => by omega) (fun _ _ h => h) (fun _ _ h => h))
      exact ⟨sh', hr'', cbOk', mb', base', xsOk', hm''.mono (fun _ _ h => by omega) (fun _ _ h => h) (fun _ _ h => h)⟩)
  exact ⟨sh, hI, hr'⟩

end Launch

end Metal.Kernels.MmaWide

namespace Metal.Kernels.GateUpMmaWide
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.MmaWide

variable (C : M1Max.Contract)

/-- **The GPU runs the wide gate-up MMA kernel as its source says**, for gate and up widths `kg`, `ku` in 1 … 4,
`MT` in 1 … 3 and `r` rows of `x` (`0 < r < 2¹⁶`), given that the text compiles to `core kg ku mt`. Under the GPU
assumption, MLX's launch on any `x` (8-aligned: the kernel stages it as `vec<bfloat, 4>`), `x_shape` (4-aligned: an
`int`), codes (4-aligned: `uint` words) and scales (2-aligned: `half`) writes to `mid` row `m`, column `row` the
SiLU-gated product of the scaled `simdgroup_multiply_accumulate` chains of the trellis-decoded weights times `x`. -/
theorem gpu_output_of (kg ku mt : Nat) (hKg : GateUp.Width kg) (hKu : GateUp.Width ku) (hmt : 1 ≤ mt ∧ mt ≤ 3)
    (text : List Char) (hc : (frontend text).bind elaborate = some (core kg ku mt)) (G : Gpu C)
    (hmax : 256 ≤ G.maxThreads text) (r : Nat) (hr : 0 < r ∧ r < 2 ^ 16) (X Gc Gs Uc Us : ByteMemory.Bytes)
    (ax ash ag as au aus : Nat) (hax : 8 ∣ ax) (hash : 4 ∣ ash) (hag : 4 ∣ ag) (has : 2 ∣ as) (hau : 4 ∣ au)
    (haus : 2 ∣ aus) :
    G.execute text (256, 272, ceilDiv r (8 * mt)) (256, 1, 1)
      [⟨.device, 10240 * r, ax, X⟩, ⟨.constant, 8, ash, shapeBytes r⟩, ⟨.device, GateUp.codesBytes kg, ag, Gc⟩,
        ⟨.device, 34816, as, Gs⟩, ⟨.device, GateUp.codesBytes ku, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816 * r] =
      some [expected C kg ku r X Gc Gs Uc Us] := by
  have h := gpu_owned C G (text := text) (grid := (256, 272, ceilDiv r (8 * mt))) (tg := (256, 1, 1))
    (inputs := [⟨.device, 10240 * r, ax, X⟩, ⟨.constant, 8, ash, shapeBytes r⟩, ⟨.device, GateUp.codesBytes kg, ag, Gc⟩,
        ⟨.device, 34816, as, Gs⟩, ⟨.device, GateUp.codesBytes ku, au, Uc⟩, ⟨.device, 34816, aus, Us⟩])
    (sizes := [34816 * r]) (fun _ => expected C kg ku r X Gc Gs Uc Us) hc (by simpa using hmax)
    (fun initial garbage => by
      have hS := launch_shape (kg := kg) (ku := ku) (mt := mt) (I := ⟨X, Gc, Gs, Uc, Us, r, ax, ash, ag, as, au, aus⟩)
        (initial := initial) (Nat.mod_eq_zero_of_dvd hax) (Nat.mod_eq_zero_of_dvd hash) (Nat.mod_eq_zero_of_dvd hag)
        (Nat.mod_eq_zero_of_dvd has) (Nat.mod_eq_zero_of_dvd hau) (Nat.mod_eq_zero_of_dvd haus)
      obtain ⟨sh, ⟨cbOk, mb, base, xsOk, hm⟩, n, hn⟩ := launch_run C hS hKg hKu hmt hr (G.fusion text) garbage
      refine ⟨n, 64 * mt + 1, 41, sh, dev mt, tgo, hn n le_rfl, hm.log, ?_⟩
      intro i hi b hb
      obtain rfl : i = 0 := by simp at hi; omega
      have hb' : b < 34816 * r := by simpa using hb
      show sh.bytes 6 b = expected C kg ku r X Gc Gs Uc Us b
      have hcell : cells (sh.bytes 6) (2 * (b / 2)) 2 =
          wordBytes 2 (Val.bf16Bits (midv C kg ku r X Gc Gs Uc Us (b / 2 / 17408) (b / 2 % 17408))) :=
        hm.mid (b / 2) (show b / 2 < 17408 * r by omega) (wThread_lt hmt.1 (show b / 2 < 17408 * r by omega))
      rw [expected, ite_eq_left hb', ← hcell, cells_getD _ _ _ _ (by omega), show 2 * (b / 2) + b % 2 = b by omega])
  rw [h]
  show some [fun b => if b < 34816 * r then expected C kg ku r X Gc Gs Uc Us b else 0] = _
  congr 2
  funext b
  unfold expected
  split <;> simp_all

/-! ## The route

The route's gate and up widths are (2, 2), (3, 3), (3, 2), (2, 3), (4, 3), (4, 4), (3, 4); its prompt chunks have
9 … 223 rows, `MT = rowBlocks r` (3 when `⌈r / 8⌉ = 3`, else 2) and `⌈r / (8·MT)⌉` threadgroups along z. Codes of
width `K` are `17408·640·K` bytes: 22282240 (2-bit), 33423360 (3-bit), 44564480 (4-bit). -/

section Route
variable {X Gc Gs Uc Us : ByteMemory.Bytes} {ax ash ag as au aus : Nat}

theorem rowBlocks_range (r : Nat) : 1 ≤ rowBlocks r ∧ rowBlocks r ≤ 3 := by unfold rowBlocks; split <;> omega

theorem compile_rowBlocks {kg ku : Nat} (r : Nat) (h2 : (frontend (text kg ku 2)).bind elaborate = some (core kg ku 2))
    (h3 : (frontend (text kg ku 3)).bind elaborate = some (core kg ku 3)) :
    (frontend (text kg ku (rowBlocks r))).bind elaborate = some (core kg ku (rowBlocks r)) := by
  unfold rowBlocks; split
  · exact h3
  · exact h2

theorem gpu_output_2_2 (G : Gpu C) (r : Nat) (hr : 9 ≤ r ∧ r ≤ 223)
    (hmax : 256 ≤ G.maxThreads (text 2 2 (rowBlocks r))) (hax : 8 ∣ ax) (hash : 4 ∣ ash) (hag : 4 ∣ ag)
    (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus) :
    G.execute (text 2 2 (rowBlocks r)) (256, 272, ceilDiv r (8 * rowBlocks r)) (256, 1, 1)
      [⟨.device, 10240 * r, ax, X⟩, ⟨.constant, 8, ash, shapeBytes r⟩, ⟨.device, 22282240, ag, Gc⟩,
        ⟨.device, 34816, as, Gs⟩, ⟨.device, 22282240, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816 * r] =
      some [expected C 2 2 r X Gc Gs Uc Us] :=
  gpu_output_of C 2 2 (rowBlocks r) GateUp.width_2 GateUp.width_2 (rowBlocks_range r) _
    (compile_rowBlocks r compile_2_2_2 compile_2_2_3) G hmax r ⟨by omega, by omega⟩ X Gc Gs Uc Us ax ash ag as au aus
    hax hash hag has hau haus

theorem gpu_output_3_3 (G : Gpu C) (r : Nat) (hr : 9 ≤ r ∧ r ≤ 223)
    (hmax : 256 ≤ G.maxThreads (text 3 3 (rowBlocks r))) (hax : 8 ∣ ax) (hash : 4 ∣ ash) (hag : 4 ∣ ag)
    (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus) :
    G.execute (text 3 3 (rowBlocks r)) (256, 272, ceilDiv r (8 * rowBlocks r)) (256, 1, 1)
      [⟨.device, 10240 * r, ax, X⟩, ⟨.constant, 8, ash, shapeBytes r⟩, ⟨.device, 33423360, ag, Gc⟩,
        ⟨.device, 34816, as, Gs⟩, ⟨.device, 33423360, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816 * r] =
      some [expected C 3 3 r X Gc Gs Uc Us] :=
  gpu_output_of C 3 3 (rowBlocks r) GateUp.width_3 GateUp.width_3 (rowBlocks_range r) _
    (compile_rowBlocks r compile_3_3_2 compile_3_3_3) G hmax r ⟨by omega, by omega⟩ X Gc Gs Uc Us ax ash ag as au aus
    hax hash hag has hau haus

theorem gpu_output_3_2 (G : Gpu C) (r : Nat) (hr : 9 ≤ r ∧ r ≤ 223)
    (hmax : 256 ≤ G.maxThreads (text 3 2 (rowBlocks r))) (hax : 8 ∣ ax) (hash : 4 ∣ ash) (hag : 4 ∣ ag)
    (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus) :
    G.execute (text 3 2 (rowBlocks r)) (256, 272, ceilDiv r (8 * rowBlocks r)) (256, 1, 1)
      [⟨.device, 10240 * r, ax, X⟩, ⟨.constant, 8, ash, shapeBytes r⟩, ⟨.device, 33423360, ag, Gc⟩,
        ⟨.device, 34816, as, Gs⟩, ⟨.device, 22282240, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816 * r] =
      some [expected C 3 2 r X Gc Gs Uc Us] :=
  gpu_output_of C 3 2 (rowBlocks r) GateUp.width_3 GateUp.width_2 (rowBlocks_range r) _
    (compile_rowBlocks r compile_3_2_2 compile_3_2_3) G hmax r ⟨by omega, by omega⟩ X Gc Gs Uc Us ax ash ag as au aus
    hax hash hag has hau haus

theorem gpu_output_2_3 (G : Gpu C) (r : Nat) (hr : 9 ≤ r ∧ r ≤ 223)
    (hmax : 256 ≤ G.maxThreads (text 2 3 (rowBlocks r))) (hax : 8 ∣ ax) (hash : 4 ∣ ash) (hag : 4 ∣ ag)
    (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus) :
    G.execute (text 2 3 (rowBlocks r)) (256, 272, ceilDiv r (8 * rowBlocks r)) (256, 1, 1)
      [⟨.device, 10240 * r, ax, X⟩, ⟨.constant, 8, ash, shapeBytes r⟩, ⟨.device, 22282240, ag, Gc⟩,
        ⟨.device, 34816, as, Gs⟩, ⟨.device, 33423360, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816 * r] =
      some [expected C 2 3 r X Gc Gs Uc Us] :=
  gpu_output_of C 2 3 (rowBlocks r) GateUp.width_2 GateUp.width_3 (rowBlocks_range r) _
    (compile_rowBlocks r compile_2_3_2 compile_2_3_3) G hmax r ⟨by omega, by omega⟩ X Gc Gs Uc Us ax ash ag as au aus
    hax hash hag has hau haus

theorem gpu_output_4_3 (G : Gpu C) (r : Nat) (hr : 9 ≤ r ∧ r ≤ 223)
    (hmax : 256 ≤ G.maxThreads (text 4 3 (rowBlocks r))) (hax : 8 ∣ ax) (hash : 4 ∣ ash) (hag : 4 ∣ ag)
    (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus) :
    G.execute (text 4 3 (rowBlocks r)) (256, 272, ceilDiv r (8 * rowBlocks r)) (256, 1, 1)
      [⟨.device, 10240 * r, ax, X⟩, ⟨.constant, 8, ash, shapeBytes r⟩, ⟨.device, 44564480, ag, Gc⟩,
        ⟨.device, 34816, as, Gs⟩, ⟨.device, 33423360, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816 * r] =
      some [expected C 4 3 r X Gc Gs Uc Us] :=
  gpu_output_of C 4 3 (rowBlocks r) GateUp.width_4 GateUp.width_3 (rowBlocks_range r) _
    (compile_rowBlocks r compile_4_3_2 compile_4_3_3) G hmax r ⟨by omega, by omega⟩ X Gc Gs Uc Us ax ash ag as au aus
    hax hash hag has hau haus

theorem gpu_output_4_4 (G : Gpu C) (r : Nat) (hr : 9 ≤ r ∧ r ≤ 223)
    (hmax : 256 ≤ G.maxThreads (text 4 4 (rowBlocks r))) (hax : 8 ∣ ax) (hash : 4 ∣ ash) (hag : 4 ∣ ag)
    (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus) :
    G.execute (text 4 4 (rowBlocks r)) (256, 272, ceilDiv r (8 * rowBlocks r)) (256, 1, 1)
      [⟨.device, 10240 * r, ax, X⟩, ⟨.constant, 8, ash, shapeBytes r⟩, ⟨.device, 44564480, ag, Gc⟩,
        ⟨.device, 34816, as, Gs⟩, ⟨.device, 44564480, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816 * r] =
      some [expected C 4 4 r X Gc Gs Uc Us] :=
  gpu_output_of C 4 4 (rowBlocks r) GateUp.width_4 GateUp.width_4 (rowBlocks_range r) _
    (compile_rowBlocks r compile_4_4_2 compile_4_4_3) G hmax r ⟨by omega, by omega⟩ X Gc Gs Uc Us ax ash ag as au aus
    hax hash hag has hau haus

theorem gpu_output_3_4 (G : Gpu C) (r : Nat) (hr : 9 ≤ r ∧ r ≤ 223)
    (hmax : 256 ≤ G.maxThreads (text 3 4 (rowBlocks r))) (hax : 8 ∣ ax) (hash : 4 ∣ ash) (hag : 4 ∣ ag)
    (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus) :
    G.execute (text 3 4 (rowBlocks r)) (256, 272, ceilDiv r (8 * rowBlocks r)) (256, 1, 1)
      [⟨.device, 10240 * r, ax, X⟩, ⟨.constant, 8, ash, shapeBytes r⟩, ⟨.device, 33423360, ag, Gc⟩,
        ⟨.device, 34816, as, Gs⟩, ⟨.device, 44564480, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816 * r] =
      some [expected C 3 4 r X Gc Gs Uc Us] :=
  gpu_output_of C 3 4 (rowBlocks r) GateUp.width_3 GateUp.width_4 (rowBlocks_range r) _
    (compile_rowBlocks r compile_3_4_2 compile_3_4_3) G hmax r ⟨by omega, by omega⟩ X Gc Gs Uc Us ax ash ag as au aus
    hax hash hag has hau haus

end Route

end Metal.Kernels.GateUpMmaWide
