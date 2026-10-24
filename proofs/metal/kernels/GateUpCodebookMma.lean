import metal.Elab
import metal.Frontend
import metal.Assemble
import host.mlx.PrefillKernelSources
import metal.kernels.GateUp

namespace Metal.Kernels.GateUpCodebookMma
open Metal Metal.Core

/-! # gate-up-codebook-mma.ts: `mlx_bun_trellis_gateup_codebook_mma`

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
inline void codebook_mma_run(const device uint32_t* rowCodes, uint run, thread uint* w, thread uint* v) {
  const uint wpb = (uint)(BT_ * K / 32);
  const uint runsPerBlock = (uint)BT_ / 32u;
  const uint blk = run / runsPerBlock;
  const uint t0 = (run - blk * runsPerBlock) * 32u;
  const device uint32_t* bw = rowCodes + blk * wpb;
  const uint w0 = ((uint)BT_ - 32u - t0) * (uint)K / 32u;
  #pragma clang loop unroll(full)
  for (uint i = 0; i < (uint)K; ++i) w[i] = bw[w0 + i];
  w[K] = bw[t0 == 0u ? 0u : w0 + (uint)K];
  #pragma clang loop unroll(full)
  for (uint i = 1; i <= (uint)K; ++i) v[i] = (w[i - 1] >> 16) | (w[i] << 16);
}
template <int K, int L_>
inline uint codebook_mma_state(thread const uint* w, thread const uint* v, uint j) {
  const uint b = (31u - j) * (uint)K;
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
const uint sg = simdgroup_index_in_threadgroup;
threadgroup half codebook[1 << L];
for (uint i = sg * 32u + lane; i < (1u << (uint)L); i += 32u * (uint)SG_TG) codebook[i] = half(trellis_y_f32(i));
threadgroup_barrier(metal::mem_flags::mem_threadgroup);
const uint n0 = (threadgroup_position_in_grid.y * (uint)SG_TG + sg) * 8u;
if (n0 >= (uint)R) return;
const uint fm = ((lane / 4u) & 4u) + ((lane / 2u) % 4u);
const uint fn = ((lane / 4u) & 2u) * 2u + (lane % 2u) * 2u;
const uint row = n0 + fm;
const device uint32_t* gRow = gcodes + (ulong)row * (ulong)((C / BT) * (BT * KG / 32));
const device uint32_t* uRow = ucodes + (ulong)row * (ulong)((C / BT) * (BT * KU / 32));
const device uint4* x0 = (const device uint4*)(x + (ulong)metal::min(fn, M - 1u) * (ulong)C + fm * 32u);
const device uint4* x1 = (const device uint4*)(x + (ulong)metal::min(fn + 1u, M - 1u) * (ulong)C + fm * 32u);
metal::simdgroup_float8x8 accG = metal::make_filled_simdgroup_matrix<float, 8, 8>(0.0f);
metal::simdgroup_float8x8 accU = metal::make_filled_simdgroup_matrix<float, 8, 8>(0.0f);
for (uint base = 0; base < (uint)C; base += 256u) {
  const uint runA = base / 32u + fn;
  uint ga[KG + 1], gav[KG + 1], gb[KG + 1], gbv[KG + 1];
  uint ua[KU + 1], uav[KU + 1], ub[KU + 1], ubv[KU + 1];
  codebook_mma_run<KG, BT>(gRow, runA, ga, gav);
  codebook_mma_run<KG, BT>(gRow, runA + 1u, gb, gbv);
  codebook_mma_run<KU, BT>(uRow, runA, ua, uav);
  codebook_mma_run<KU, BT>(uRow, runA + 1u, ub, ubv);
  #pragma clang loop unroll(full)
  for (uint s8 = 0; s8 < 4u; ++s8) {
    const uint4 xa = x0[base / 8u + s8], xb = x1[base / 8u + s8];
    #pragma clang loop unroll(full)
    for (uint q = 0; q < 8u; ++q) {
      const uint j = s8 * 8u + q;
      metal::simdgroup_half8x8 aG, aU;
      aG.thread_elements()[0] = codebook[codebook_mma_state<KG, L>(ga, gav, j)];
      aG.thread_elements()[1] = codebook[codebook_mma_state<KG, L>(gb, gbv, j)];
      aU.thread_elements()[0] = codebook[codebook_mma_state<KU, L>(ua, uav, j)];
      aU.thread_elements()[1] = codebook[codebook_mma_state<KU, L>(ub, ubv, j)];
      metal::simdgroup_float8x8 b;
      b.thread_elements()[0] = float(as_type<T>(ushort((q & 1u) ? xa[q / 2u] >> 16 : xa[q / 2u] & 0xFFFFu)));
      b.thread_elements()[1] = float(as_type<T>(ushort((q & 1u) ? xb[q / 2u] >> 16 : xb[q / 2u] & 0xFFFFu)));
      metal::simdgroup_multiply_accumulate(accG, aG, b, accG);
      metal::simdgroup_multiply_accumulate(accU, aU, b, accU);
    }
  }
}
const float gs = float(gscales[row]) * TRELLIS_RCP;
const float us = float(uscales[row]) * TRELLIS_RCP;
#pragma clang loop unroll(full)
for (uint j = 0; j < 2u; ++j) {
  const uint m = fn + j;
  if (m >= M) continue;
  const T gateT = T(accG.thread_elements()[j] * gs);
  const T upT = T(accU.thread_elements()[j] * us);
  const T sigmoidT = T(1.0f / (1.0f + metal::precise::exp(-float(gateT))));
  const T siluT = T(float(gateT) * float(sigmoidT));
  mid[(ulong)m * (ulong)R + row] = T(float(siluT) * float(upT));
}
```
Launch (gate-up-codebook-mma.ts:117-139): inputs `x` bfloat16 `[M, C]` (1 ≤ M ≤ 8, its shape buffer
`x_shape` follows it), `gcodes` and `ucodes` uint32 (row-major words), `gscales` and `uscales`
float16; output `mid` bfloat16 `[M, R]`; `T` = bfloat16, template ints R, C, BT, KG, KU, L, SG_TG = 4;
grid `[128, R/32, 1]`, threadgroup `[128, 1, 1]`. The route reaches it in the codebook MMA forwards
(2 to 8 prompt rows) at R = 17408, C = 5120, BT = 256, L = 12 for every layer's gate and up bit widths:
(KG, KU) ∈ {(2,2), (3,3), (3,2), (2,3), (4,3), (4,4), (3,4)} (host/load/Data.lean). The core depends
on KG and KU only through constants: `core kg ku`.

`aG`, `aU` and `b` are declared without initializer, so each is a one-element thread array (its
elements are undefined until written); `accG`, `accU` are slots holding the lane's two elements.
Each `simdgroup_multiply_accumulate` is a SIMD-group collective over the lanes' `[A, B, C]`. -/

def u32l (n : Nat) : CExpr := .lit (.int .u32 n)
def u64l (n : Nat) : CExpr := .lit (.int .u64 n)
def u16l (n : Nat) : CExpr := .lit (.int .u16 n)
def i32l (n : Nat) : CExpr := .lit (.int .i32 n)
def f32l (bits : Nat) : CExpr := .lit (.f32 (Val.ofF32Bits bits))

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

/-- `codebook_mma_run<K, 256>(rowCodes, run, w, v)` with its arguments set into slots `b` … `b + 3`:
slots `b` rowCodes, `b + 1` run, `b + 2` w, `b + 3` v, (`b + 4` the void result), `b + 5` wpb,
`b + 6` runsPerBlock, `b + 7` blk, `b + 8` t0, `b + 9` bw, `b + 10` w0, `b + 11` and `b + 12` the
loops' i. -/
def run (k b : Nat) (rowCodes runE w v : CExpr) : List CStmt :=
  [.set b rowCodes, .set (b + 1) runE, .set (b + 2) w, .set (b + 3) v,
   .scope
     [.set (b + 5) (u32l (8 * k)),
      .set (b + 6) (u32l 8),
      .set (b + 7) (u32 .div (.local (b + 1)) (.local (b + 6))),
      .set (b + 8) (u32 .mul (u32 .sub (.local (b + 1)) (u32 .mul (.local (b + 7)) (.local (b + 6)))) (u32l 32)),
      .set (b + 9) (.offset (.local b) (u32 .mul (.local (b + 7)) (.local (b + 5)))),
      .set (b + 10) (u32 .div (u32 .mul (u32 .sub (u32l 224) (.local (b + 8))) (u32l k)) (u32l 32)),
      .set (b + 11) (u32l 0),
      .loop (lt (b + 11) k) (incr (b + 11))
        [.store (.scalar .u32) (.offset (.local (b + 2)) (.local (b + 11)))
          (ld (.offset (.local (b + 9)) (u32 .add (.local (b + 10)) (.local (b + 11)))))],
      .store (.scalar .u32) (.offset (.local (b + 2)) (i32l k))
        (ld (.offset (.local (b + 9))
          (.cond (u32 .eq (.local (b + 8)) (u32l 0)) (u32l 0) (u32 .add (.local (b + 10)) (u32l k))))),
      .set (b + 12) (u32l 1),
      .loop (le (b + 12) k) (incr (b + 12))
        [.store (.scalar .u32) (.offset (.local (b + 3)) (.local (b + 12)))
          (u32 .bitOr (u32 .shr (ld (.offset (.local (b + 2)) (u32 .sub (.local (b + 12)) (u32l 1)))) (u32l 16))
            (u32 .shl (ld (.offset (.local (b + 2)) (.local (b + 12)))) (u32l 16)))]]]

/-- `codebook_mma_state<K, 12>(w, v, j)` with its arguments set into slots `b` … `b + 2`: slots `b` w,
`b + 1` v, `b + 2` j, `b + 3` the result, `b + 4` b, `b + 5` off, `b + 6` vi. -/
def state (k b : Nat) (w v j : CExpr) : List CStmt :=
  [.set b w, .set (b + 1) v, .set (b + 2) j,
   .scope
     [.set (b + 4) (u32 .mul (u32 .sub (u32l 31) (.local (b + 2))) (u32l k)),
      .set (b + 5) (u32 .bitAnd (.local (b + 4)) (u32l 31)),
      .ite (u32 .le (u32 .add (.local (b + 5)) (u32l 12)) (u32l 32))
        [.set (b + 3) (u32 .bitAnd (u32 .shr (ld (.offset (.local b) (u32 .shr (.local (b + 4)) (u32l 5)))) (.local (b + 5)))
           (u32l 4095)),
         .leave] [],
      .set (b + 6) (u32 .shr (u32 .add (.local (b + 4)) (u32l 16)) (u32l 5)),
      .set (b + 3) (u32 .bitAnd
        (u32 .shr (ld (.offset (.local (b + 1)) (.local (b + 6))))
          (u32 .sub (u32 .add (.local (b + 4)) (u32l 16)) (u32 .mul (u32l 32) (.local (b + 6)))))
        (u32l 4095)),
      .leave]]

/-! ## The body -/

/-- `codebook[…]` stored to element `e` of the half matrix at slot `m`, the state in slot `r`. -/
def aElem (m e r : Nat) : CStmt :=
  .store (.scalar .f16) (.offset (.ptrCast (.scalar .f16) (.local m)) (i32l e))
    (.load (.scalar .f16) (.offset (.local 10) (.local r)))

/-- `float(as_type<T>(ushort((q & 1u) ? x[q / 2u] >> 16 : x[q / 2u] & 0xFFFFu)))` for the uint4 in slot `x`. -/
def bValue (x : Nat) : CExpr :=
  .conv .f32 (.bitcast .bf16 (.conv .u16
    (.cond (.conv .bool (u32 .bitAnd (.local 93) (u32l 1)))
      (u32 .shr (.component (.local x) (u32 .div (.local 93) (u32l 2))) (u32l 16))
      (u32 .bitAnd (.component (.local x) (u32 .div (.local 93) (u32l 2))) (u32l 0xFFFF)))))

/-- One position `j` (slot 94) of the run: `aG` (slot 95), `aU` (96), `b` (125), the two collectives
(results in 126, 127). -/
def positionBody (kg ku : Nat) : List CStmt :=
  [.set 94 (u32 .add (u32 .mul (.local 90) (u32l 8)) (.local 93)),
   .array 95 false 8 (.vec .f16 2),
   .array 96 false 9 (.vec .f16 2)] ++
  state kg 97 (.local 30) (.local 31) (.local 94) ++ [aElem 95 0 100] ++
  state kg 104 (.local 32) (.local 33) (.local 94) ++ [aElem 95 1 107] ++
  state ku 111 (.local 34) (.local 35) (.local 94) ++ [aElem 96 0 114] ++
  state ku 118 (.local 36) (.local 37) (.local 94) ++ [aElem 96 1 121] ++
  [.array 125 false 10 (.vec .f32 2),
   .store (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (.local 125)) (i32l 0)) (bValue 91),
   .store (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (.local 125)) (i32l 1)) (bValue 92),
   .collective 2 126 (.mma .f16 .f32) .f32
     (.vector .f32 [.load (.vec .f16 2) (.local 95), .load (.vec .f32 2) (.local 125), .local 26]) (u16l 0),
   .set 26 (.local 126),
   .collective 3 127 (.mma .f16 .f32) .f32
     (.vector .f32 [.load (.vec .f16 2) (.local 96), .load (.vec .f32 2) (.local 125), .local 27]) (u16l 0),
   .set 27 (.local 127)]

/-- One 8-position chunk `s8` (slot 90): `xa`, `xb` (91, 92), then each position `q` (93). -/
def chunkBody (kg ku : Nat) : List CStmt :=
  [.set 91 (.load (.vec .u32 4) (.offset (.local 24) (u32 .add (u32 .div (.local 28) (u32l 8)) (.local 90)))),
   .set 92 (.load (.vec .u32 4) (.offset (.local 25) (u32 .add (u32 .div (.local 28) (u32l 8)) (.local 90)))),
   .set 93 (u32l 0),
   .loop (lt 93 8) (incr 93) (positionBody kg ku)]

/-- One 256-position step `base` (slot 28): `runA` (29), the run arrays (30 … 37: ga, gav, gb, gbv,
ua, uav, ub, ubv), the four runs (at slots 38, 51, 64, 77), the chunks. -/
def stepBody (kg ku : Nat) : List CStmt :=
  [.set 29 (u32 .add (u32 .div (.local 28) (u32l 32)) (.local 20)),
   .array 30 false 0 (.scalar .u32), .array 31 false 1 (.scalar .u32),
   .array 32 false 2 (.scalar .u32), .array 33 false 3 (.scalar .u32),
   .array 34 false 4 (.scalar .u32), .array 35 false 5 (.scalar .u32),
   .array 36 false 6 (.scalar .u32), .array 37 false 7 (.scalar .u32)] ++
  run kg 38 (.local 22) (.local 29) (.local 30) (.local 31) ++
  run kg 51 (.local 22) (u32 .add (.local 29) (u32l 1)) (.local 32) (.local 33) ++
  run ku 64 (.local 23) (.local 29) (.local 34) (.local 35) ++
  run ku 77 (.local 23) (u32 .add (.local 29) (u32l 1)) (.local 36) (.local 37) ++
  [.set 90 (u32l 0),
   .loop (lt 90 4) (incr 90) (chunkBody kg ku)]

/-- The codebook fill: `codebook[i] = half(trellis_y_f32(i))` (i in slot 11, `trellis_y_f32` at 12). -/
def fillLoop : CStmt :=
  .loop (lt 11 4096) [.set 11 (u32 .add (.local 11) (u32l 128))]
    [.set 12 (.local 11),
     yF32 12,
     .store (.scalar .f16) (.offset (.local 10) (.local 11)) (.conv .f16 (.local 13))]

/-- `x0` or `x1`: rows `min(fn + k, M - 1)` of `x` from position `32·fm`, as `uint4`s. -/
def xRow (fn : CExpr) : CExpr :=
  .ptrCast (.vec .u32 4)
    (.offset (.offset (.local 0) (u64 .mul (toU64 (u32 .min fn (u32 .sub (.local 7) (u32l 1)))) (u64l 5120)))
      (u32 .mul (.local 19) (u32l 32)))

/-- The outputs: `j` (slot 130), `m` (131), gateT, upT, sigmoidT, siluT (132 … 135). -/
def outBody : List CStmt :=
  [.set 131 (u32 .add (.local 20) (.local 130)),
   .ite (u32 .ge (.local 131) (.local 7)) [.continue_] [],
   .set 132 (.conv .bf16 (.bin .mul .f32 0 (.component (.local 26) (.local 130)) (.local 128))),
   .set 133 (.conv .bf16 (.bin .mul .f32 0 (.component (.local 27) (.local 130)) (.local 129))),
   .set 134 (.conv .bf16 (.bin .div .f32 0 (f32l 0x3F800000)
     (.bin .add .f32 0 (f32l 0x3F800000) (.un .exp .f32 (.un .neg .f32 (.conv .f32 (.local 132))))))),
   .set 135 (.bin .mul .bf16 0 (.local 132) (.local 134)),
   .store (.scalar .bf16)
     (.offset (.local 6) (u64 .add (u64 .mul (toU64 (.local 131)) (u64l 17408)) (toU64 (.local 21))))
     (.bin .mul .bf16 0 (.local 135) (.local 133))]

/-- Slots: 0 x, 1 x_shape, 2 gcodes, 3 gscales, 4 ucodes, 5 uscales, 6 mid, 7 M, 8 lane, 9 sg,
10 codebook (threadgroup array 0), 11 i, 12 … 17 `trellis_y_f32`'s (`yF32`), 18 n0, 19 fm, 20 fn,
21 row, 22 gRow, 23 uRow, 24 x0, 25 x1, 26 accG, 27 accU, 28 base, 29 runA, 30 … 37 the run arrays
(thread arrays 0 … 7), 38 … 89 the four `codebook_mma_run`s (`run`), 90 s8, 91 xa, 92 xb, 93 q,
94 j, 95 aG, 96 aU (thread arrays 8, 9), 97 … 124 the four `codebook_mma_state`s (`state`),
125 b (thread array 10), 126, 127 the collectives' results, 128 gs, 129 us, 130 j, 131 m,
132 gateT, 133 upT, 134 sigmoidT, 135 siluT. -/
def body (kg ku : Nat) : List CStmt :=
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
      .array 10 true 0 (.scalar .f16),
      .set 11 (u32 .add (u32 .mul (.local 9) (u32l 32)) (.local 8)),
      fillLoop,
      .barrier 1 false true,
      .set 18 (u32 .mul (u32 .add (u32 .mul (.component (.coord .threadgroupPositionInGrid) (u32l 1)) (u32l 4)) (.local 9))
        (u32l 8)),
      .ite (u32 .ge (.local 18) (u32l 17408)) [.leave] [],
      .set 19 (u32 .add (u32 .bitAnd (u32 .div (.local 8) (u32l 4)) (u32l 4)) (u32 .rem (u32 .div (.local 8) (u32l 2)) (u32l 4))),
      .set 20 (u32 .add (u32 .mul (u32 .bitAnd (u32 .div (.local 8) (u32l 4)) (u32l 2)) (u32l 2))
        (u32 .mul (u32 .rem (.local 8) (u32l 2)) (u32l 2))),
      .set 21 (u32 .add (.local 18) (.local 19)),
      .set 22 (.offset (.local 2) (u64 .mul (toU64 (.local 21)) (u64l (160 * kg)))),
      .set 23 (.offset (.local 4) (u64 .mul (toU64 (.local 21)) (u64l (160 * ku)))),
      .set 24 (xRow (.local 20)),
      .set 25 (xRow (u32 .add (.local 20) (u32l 1))),
      .set 26 (.vector .f32 [f32l 0x0, f32l 0x0]),
      .set 27 (.vector .f32 [f32l 0x0, f32l 0x0]),
      .set 28 (u32l 0),
      .loop (lt 28 5120) [.set 28 (u32 .add (.local 28) (u32l 256))] (stepBody kg ku),
      .set 128 (.bin .mul .f32 0 (.conv .f32 (.load (.scalar .f16) (.offset (.local 3) (.local 21)))) (f32l 0x3BDDB447)),
      .set 129 (.bin .mul .f32 0 (.conv .f32 (.load (.scalar .f16) (.offset (.local 5) (.local 21)))) (f32l 0x3BDDB447)),
      .set 130 (u32l 0),
      .loop (lt 130 2) (incr 130) outBody]]

/-- The codebook `half codebook[4096]`; thread arrays the run words (`KG + 1` and `KU + 1` each),
`aG`, `aU` and `b`. -/
def core (kg ku : Nat) : Kernel :=
  ⟨7, [(.scalar .f16, 4096)],
    [(.scalar .u32, kg + 1), (.scalar .u32, kg + 1), (.scalar .u32, kg + 1), (.scalar .u32, kg + 1),
     (.scalar .u32, ku + 1), (.scalar .u32, ku + 1), (.scalar .u32, ku + 1), (.scalar .u32, ku + 1),
     (.vec .f16 2, 1), (.vec .f16 2, 1), (.vec .f32 2, 1)],
    body kg ku⟩

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

def args (kg ku : Nat) : List Assemble.TemplateArg :=
  [.dtype chars!"T" .bfloat16, .int chars!"R" 17408, .int chars!"C" 5120, .int chars!"BT" 256, .int chars!"KG" kg,
    .int chars!"KU" ku, .int chars!"L" 12, .int chars!"SG_TG" 4]

def assembled (kg ku : Nat) : Option (List Char) :=
  Assemble.assemble (PrefillSources.name .gateUpCodebookMma) (inputs kg ku) [chars!"mid"] [.bfloat16]
    (PrefillSources.source .gateUpCodebookMma) (PrefillSources.header .gateUpCodebookMma) (args kg ku) false

def text (kg ku : Nat) : List Char := (assembled kg ku).getD []

/-- Every route instance assembles. -/
theorem assembled_route :
    (assembled 2 2).isSome ∧ (assembled 3 3).isSome ∧ (assembled 3 2).isSome ∧ (assembled 2 3).isSome ∧
    (assembled 4 3).isSome ∧ (assembled 4 4).isSome ∧ (assembled 3 4).isSome := by
  decide +kernel

kernel_rfl compile_2_2 : (frontend (text 2 2)).bind elaborate = some (core 2 2)
kernel_rfl compile_3_3 : (frontend (text 3 3)).bind elaborate = some (core 3 3)
kernel_rfl compile_3_2 : (frontend (text 3 2)).bind elaborate = some (core 3 2)
kernel_rfl compile_2_3 : (frontend (text 2 3)).bind elaborate = some (core 2 3)
kernel_rfl compile_4_3 : (frontend (text 4 3)).bind elaborate = some (core 4 3)
kernel_rfl compile_4_4 : (frontend (text 4 4)).bind elaborate = some (core 4 4)
kernel_rfl compile_3_4 : (frontend (text 3 4)).bind elaborate = some (core 3 4)

end Texts
end Metal.Kernels.GateUpCodebookMma

set_option linter.constructorNameAsVariable false

namespace Metal.Kernels.CodebookMma
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis

local notation "cu" => GateUpCodebookMma.u32
local notation "cl" => GateUpCodebookMma.u32l
local notation "ci" => GateUpCodebookMma.i32l

/-! ## Expected outputs

The quantities of the source on the inputs' elements, with the operations the core applies. The core has no
contraction sites, so the compiler's fusion choices do not enter. -/

section Spec
variable (C : M1Max.Contract)

/-- `trellis_y_f32(s)`: the float of word `0x4b000000 | (trellis_y(s) + 510)`, less `8389118.0f`. -/
def yF32v (s : Nat) : Float32 :=
  C.fadd (Val.ofF32Bits (0x4B000000 ||| (trellisYv s + 510).toNat)) (f32Neg (Val.ofF32Bits 0x4B0001FE))

/-- Codebook entry `s`: `half(trellis_y_f32(s))`. -/
def cbEntry (s : Nat) : Float16.Value := C.narrowHalf (yF32v C s)

/-- A lane's fragment row `fm` and first fragment column `fn`. -/
def fm (lane : Nat) : Nat := (lane / 4 &&& 4) + lane / 2 % 4
def fn (lane : Nat) : Nat := (lane / 4 &&& 2) * 2 + lane % 2 * 2

/-- The weight (A) element of row `row` at position `c`: the codebook entry of its 12-bit trellis state in its
block of `K`-bit codes (block `c / 256` of the row, from word `(20·row + c / 256)·8·K`). -/
def weightA (K : Nat) (Codes : ByteMemory.Bytes) (row c : Nat) : Float16.Value :=
  cbEntry C (trellisCode K Codes ((20 * row + c / 256) * (8 * K)) (c % 256))

/-- The activation (B) element of `x` row `m` at position `c`: `float(as_type<T>(…))` of its bf16 bits. -/
def xB (X : ByteMemory.Bytes) (m c : Nat) : Float32 := C.widen (Val.ofBf16Bits (half X (5120 * m + c)))

/-- Lane `l`'s A element `e` at step `t` (`base = 256·(t / 32)`, `j = t % 32`) of tile `T` (rows `8T …`):
`codebook[codebook_mma_state(run base/32 + fn + e, j)]` of row `8T + fm`. -/
def aReg (K : Nat) (Codes : ByteMemory.Bytes) (T t : Nat) (l : Fin 32) (e : Fin 2) : Float16.Value :=
  weightA C K Codes (8 * T + fm l) (256 * (t / 32) + 32 * (fn l + e) + t % 32)

/-- Lane `l`'s B element `e` at step `t`: `x` row `min(fn + e, M - 1)`, position `base + 32·fm + j`. -/
def bReg (X : ByteMemory.Bytes) (M t : Nat) (l : Fin 32) (e : Fin 2) : Float32 :=
  xB C X (min (fn l + e) (M - 1)) (256 * (t / 32) + 32 * fm l + t % 32)

/-- The lanes' accumulator registers of tile `T` after `n` steps: `simdgroup_multiply_accumulate(acc, a, b, acc)`. -/
def acc (K : Nat) (Codes X : ByteMemory.Bytes) (M T : Nat) : Nat → Fin 32 → Fin 2 → Float32
  | 0 => fun _ _ => GateUp.zero
  | n + 1 => C.simdMmaHalfA (aReg C K Codes T n) (bReg C X M n) (acc K Codes X M T n)

/-- `float(scales[row]) * TRELLIS_RCP` (`1.0f / 147.800537109375f`, folded to the word `0x3BDDB447`). -/
def rowScale (S : ByteMemory.Bytes) (row : Nat) : Float32 := C.fmul (scale S row) (Val.ofF32Bits 0x3BDDB447)

/-- The stored value from the gate and up accumulator elements: `gateT`, `upT`, `sigmoidT`, `siluT`, then
`T(float(siluT) * float(upT))`. -/
def silu (gate up : Float32) : BF :=
  let gateT := C.narrow gate
  let upT := C.narrow up
  let sigmoidT := C.narrow (C.fdiv GateUp.one (C.fadd GateUp.one (C.exp (f32Neg (C.widen gateT)))))
  let siluT := C.bfmul gateT sigmoidT
  C.bfmul siluT upT

/-- The lane holding fragment row `i`, columns `m - m % 2`, `m - m % 2 + 1`. -/
def laneOf (i m : Nat) : Nat := 16 * (i / 4) + 8 * (m / 4) + 4 * (i / 2 % 2) + 2 * (i % 2) + m / 2 % 2

def fin32 (n : Nat) : Fin 32 := ⟨n % 32, Nat.mod_lt _ (by decide)⟩
def fin2 (n : Nat) : Fin 2 := ⟨n % 2, Nat.mod_lt _ (by decide)⟩

/-- `mid[m][row]`: lane `laneOf (row % 8) m` of tile `row / 8` stores it from element `m % 2` of its accumulators. -/
def midOut (kg ku : Nat) (X Gc Gs Uc Us : ByteMemory.Bytes) (M m row : Nat) : BF :=
  silu C (C.fmul (acc C kg Gc X M (row / 8) 640 (fin32 (laneOf (row % 8) m)) (fin2 m)) (rowScale C Gs row))
    (C.fmul (acc C ku Uc X M (row / 8) 640 (fin32 (laneOf (row % 8) m)) (fin2 m)) (rowScale C Us row))

/-- Byte `b` of `mid` `[M, 17408]` bf16. -/
def expected (kg ku : Nat) (X Gc Gs Uc Us : ByteMemory.Bytes) (M b : Nat) : BitVec 8 :=
  if b < 34816 * M then
    (wordBytes 2 (Val.bf16Bits (midOut C kg ku X Gc Gs Uc Us M (b / 2 / 17408) (b / 2 % 17408)))).getD (b % 2) 0
  else 0

end Spec

/-! ## Fragment coordinates -/

theorem frag_all : ∀ l, l < 32 → fm l < 8 ∧ fn l + 1 < 8 ∧ fn l % 2 = 0 ∧
    laneOf (fm l) (fn l) = l ∧ laneOf (fm l) (fn l + 1) = l := by decide

theorem laneOf_all : ∀ i, i < 8 → ∀ m, m < 8 → laneOf i m < 32 ∧ fm (laneOf i m) = i ∧
    fn (laneOf i m) + m % 2 = m := by decide

theorem fm_lt {l : Nat} (h : l < 32) : fm l < 8 := (frag_all l h).1
theorem fn_lt {l : Nat} (h : l < 32) : fn l + 1 < 8 := (frag_all l h).2.1

theorem laneOf_frag {l : Nat} (h : l < 32) (e : Nat) (he : e < 2) :
    laneOf (fm l) (fn l + e) = l ∧ (fn l + e) % 2 = e := by
  have := frag_all l h
  rcases (show e = 0 ∨ e = 1 by omega) with rfl | rfl
  · exact ⟨this.2.2.2.1, by omega⟩
  · exact ⟨this.2.2.2.2, by omega⟩

theorem fin32_val (i : Fin 32) : fin32 i.val = i := Fin.ext (Nat.mod_eq_of_lt i.isLt)

/-- The order lanes write `mid`: tile `row / 8`, then lane, then element. -/
def ord (m row : Nat) : Nat := 64 * (row / 8) + 2 * laneOf (row % 8) m + m % 2

theorem ord_inj {m m' row row' : Nat} (hm : m < 8) (hm' : m' < 8) (h : ord m row = ord m' row') :
    m = m' ∧ row = row' := by
  have h1 := laneOf_all (row % 8) (Nat.mod_lt _ (by decide)) m hm
  have h2 := laneOf_all (row' % 8) (Nat.mod_lt _ (by decide)) m' hm'
  unfold ord at h
  have hm2 : m % 2 < 2 := Nat.mod_lt _ (by decide)
  have hm2' : m' % 2 < 2 := Nat.mod_lt _ (by decide)
  have ht : row / 8 = row' / 8 := by omega
  have hl : laneOf (row % 8) m = laneOf (row' % 8) m' := by omega
  have hp : m % 2 = m' % 2 := by omega
  have hi : row % 8 = row' % 8 := by rw [← h1.2.1, ← h2.2.1, hl]
  have hmm : m = m' := by rw [← h1.2.2, ← h2.2.2, hl, hp]
  exact ⟨hmm, by omega⟩

theorem ord_lane {T l e : Nat} (hl : l < 32) (he : e < 2) :
    ord (fn l + e) (8 * T + fm l) = 64 * T + 2 * l + e := by
  have h := laneOf_frag hl e he
  have hf := fm_lt hl
  unfold ord
  rw [show (8 * T + fm l) / 8 = T by omega, show (8 * T + fm l) % 8 = fm l by omega, h.1, h.2]

theorem ord_lt {m row : Nat} (hm : m < 8) (hrow : row < 17408) : ord m row < 64 * 2176 := by
  have h1 := laneOf_all (row % 8) (Nat.mod_lt _ (by decide)) m hm
  unfold ord
  have := Nat.mod_lt m (show 0 < 2 by decide)
  omega

/-! ## The launch -/

/-- The inputs: `x`, its shape buffer, the gate codes and scales, the up codes and scales, and their base
alignments. -/
structure In where
  X : ByteMemory.Bytes
  S : ByteMemory.Bytes
  Gc : ByteMemory.Bytes
  Gs : ByteMemory.Bytes
  Uc : ByteMemory.Bytes
  Us : ByteMemory.Bytes
  ax : Nat
  ash : Nat
  ag : Nat
  as : Nat
  au : Nat
  aus : Nat

def bufs (kg ku M : Nat) (I : In) : List Buffer :=
  [⟨.device, 10240 * M, I.ax, I.X⟩, ⟨.constant, 8, I.ash, I.S⟩, ⟨.device, GateUp.codesBytes kg, I.ag, I.Gc⟩,
    ⟨.device, 34816, I.as, I.Gs⟩, ⟨.device, GateUp.codesBytes ku, I.au, I.Uc⟩, ⟨.device, 34816, I.aus, I.Us⟩]

/-- MLX's launch: grid [128, 544], threadgroup [128], `mid` [M, 17408] bf16. -/
def launch (kg ku M : Nat) (I : In) (initial : Nat → ByteMemory.Bytes) : Launch :=
  ⟨GateUpCodebookMma.core kg ku, (128, 544, 1), (128, 1, 1), buffers (bufs kg ku M I) [34816 * M] 16 initial⟩

/-- The writer of each device byte: `mid[m][row]` by lane `laneOf (row % 8) m` of tile `row / 8`. -/
def dev (region byte : Nat) : Option Writer :=
  if region = 6 then
    some ⟨32 * (byte / 2 % 17408 / 8) + laneOf (byte / 2 % 17408 % 8) (byte / 2 / 17408), byte / 2 % 17408 / 32, 0⟩
  else none

/-- The owner of each threadgroup byte: before threadgroup `g`'s barrier (epoch `g`), `codebook[e]` is thread
`e % 128`'s; after it nothing is written. -/
def tgo (g e region byte : Nat) : Option Nat :=
  if e = g ∧ region = 7 then some (g * 128 + byte / 2 % 128) else none

/-- The regions as the kernel uses them. -/
structure Shape (L : Launch) (kg ku M : Nat) (I : In) : Prop where
  r0 : L.regions 0 = some ⟨.device, 10240 * M, I.ax⟩
  r1 : L.regions 1 = some ⟨.constant, 8, I.ash⟩
  r2 : L.regions 2 = some ⟨.device, GateUp.codesBytes kg, I.ag⟩
  r3 : L.regions 3 = some ⟨.device, 34816, I.as⟩
  r4 : L.regions 4 = some ⟨.device, GateUp.codesBytes ku, I.au⟩
  r5 : L.regions 5 = some ⟨.device, 34816, I.aus⟩
  r6 : L.regions 6 = some ⟨.device, 34816 * M, 16⟩
  r7 : L.regions 7 = some ⟨.threadgroup, 8192, 2⟩
  rg : ∀ th j, j < 4 → L.regions (8 + th * 11 + j) = some ⟨.thread, 4 * (kg + 1), 4⟩
  ru : ∀ th j, 4 ≤ j → j < 8 → L.regions (8 + th * 11 + j) = some ⟨.thread, 4 * (ku + 1), 4⟩
  ra : ∀ th j, 8 ≤ j → j < 10 → L.regions (8 + th * 11 + j) = some ⟨.thread, 4, 4⟩
  rb : ∀ th, L.regions (8 + th * 11 + 10) = some ⟨.thread, 8, 8⟩
  ax : I.ax % 16 = 0
  ash : I.ash % 4 = 0
  ag : I.ag % 4 = 0
  as : I.as % 2 = 0
  au : I.au % 4 = 0
  aus : I.aus % 2 = 0

theorem launch_shape {kg ku M : Nat} {I : In} {initial : Nat → ByteMemory.Bytes}
    (hax : I.ax % 16 = 0) (hash : I.ash % 4 = 0) (hag : I.ag % 4 = 0) (has : I.as % 2 = 0) (hau : I.au % 4 = 0)
    (haus : I.aus % 2 = 0) : Shape (launch kg ku M I initial) kg ku M I := by
  have hb : (launch kg ku M I initial).buffers = buffers (bufs kg ku M I) [34816 * M] 16 initial := rfl
  have ht : ∀ th j t n, (launch kg ku M I initial).kernel.threadArrays[j]? = some (t, n) →
      (launch kg ku M I initial).regions (8 + th * 11 + j) = some ⟨.thread, t.bytes * n, alignment t⟩ :=
    fun th j t n h => Launch.regions_threadArray _ th j t n h
  refine ⟨regions_input hb 0 (by simp [bufs]), regions_input hb 1 (by simp [bufs]),
    regions_input hb 2 (by simp [bufs]), regions_input hb 3 (by simp [bufs]), regions_input hb 4 (by simp [bufs]),
    regions_input hb 5 (by simp [bufs]), regions_output hb 0 (by simp),
    Launch.regions_groupArray _ 0 (.scalar .f16) 4096 rfl, fun th j hj => ?_, fun th j hj1 hj2 => ?_,
    fun th j hj1 hj2 => ?_, fun th => ?_, hax, hash, hag, has, hau, haus⟩
  · have hj' : (launch kg ku M I initial).kernel.threadArrays[j]? = some (.scalar .u32, kg + 1) := by
      rcases (by omega : j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3) with rfl | rfl | rfl | rfl <;> rfl
    simpa [Ty.bytes, Scalar.bytes, alignment, Nat.mul_comm] using ht th j _ _ hj'
  · have hj' : (launch kg ku M I initial).kernel.threadArrays[j]? = some (.scalar .u32, ku + 1) := by
      rcases (by omega : j = 4 ∨ j = 5 ∨ j = 6 ∨ j = 7) with rfl | rfl | rfl | rfl <;> rfl
    simpa [Ty.bytes, Scalar.bytes, alignment, Nat.mul_comm] using ht th j _ _ hj'
  · have hj' : (launch kg ku M I initial).kernel.threadArrays[j]? = some (.vec .f16 2, 1) := by
      rcases (by omega : j = 8 ∨ j = 9) with rfl | rfl <;> rfl
    simpa [Ty.bytes, Scalar.bytes, alignment] using ht th j _ _ hj'
  · simpa [Ty.bytes, Scalar.bytes, alignment] using ht th 10 (.vec .f32 2) 1 rfl

/-! ## Memory -/

section Memory
variable (C : M1Max.Contract)

/-- Memory during the launch: inputs intact, the epochs (`ge` the threadgroup epoch), the codebook entries with
`cbOk` written, the elements of `mid` before position `P` in write order as `out`, and every access so far keeping
the ownership discipline. -/
structure Mem (L : Launch) (I : In) (M : Nat) (out : Nat → Nat → BF) (P ge : Nat) (cbOk : Nat → Prop) (sh : Shared) :
    Prop where
  regions : sh.regions = L.regions
  x : sh.bytes 0 = I.X
  s : sh.bytes 1 = I.S
  gc : sh.bytes 2 = I.Gc
  gs : sh.bytes 3 = I.Gs
  uc : sh.bytes 4 = I.Uc
  us : sh.bytes 5 = I.Us
  deve : sh.deviceEpoch = 0
  grpe : sh.groupEpoch = ge
  cb : ∀ e < 4096, cbOk e → cells (sh.bytes 7) (2 * e) 2 = wordBytes 2 (Val.f16Bits (cbEntry C e))
  mid : ∀ m < M, ∀ row < 17408, ord m row < P →
    cells (sh.bytes 6) (2 * (17408 * m + row)) 2 = wordBytes 2 (Val.bf16Bits (out m row))
  log : ∀ a ∈ sh.log, Owned L dev tgo a

variable {C} {L : Launch} {I : In} {M : Nat} {out : Nat → Nat → BF} {P ge : Nat} {cbOk : Nat → Prop} {sh : Shared}
  {kg ku : Nat}

theorem Mem.mono (h : Mem C L I M out P ge cbOk sh) {cbOk' : Nat → Prop} (hc : ∀ e < 4096, cbOk' e → cbOk e) :
    Mem C L I M out P ge cbOk' sh :=
  ⟨h.regions, h.x, h.s, h.gc, h.gs, h.uc, h.us, h.deve, h.grpe, fun e he hc' => h.cb e he (hc e he hc'), h.mid, h.log⟩

/-- A read of an input, or of the codebook after its threadgroup's writes. -/
theorem Mem.rd (h : Mem C L I M out P ge cbOk sh) (ctx : Ctx) (reg o n : Nat)
    (hreg : reg < 6 ∨ (reg = 7 ∧ ge ≠ ctx.group)) (hS : Shape L kg ku M I) :
    Mem C L I M out P ge cbOk (rdn ctx sh reg o n) :=
  ⟨h.regions, h.x, h.s, h.gc, h.gs, h.uc, h.us, h.deve, h.grpe, h.cb, h.mid, forall_log _ n _ (fun j _ => by
    rcases hreg with hreg | ⟨rfl, hne⟩
    · obtain ⟨r, hr, hs⟩ : ∃ r, L.regions reg = some r ∧ r.space ≠ .threadgroup := by
        rcases (show reg = 0 ∨ reg = 1 ∨ reg = 2 ∨ reg = 3 ∨ reg = 4 ∨ reg = 5 by omega) with
          rfl | rfl | rfl | rfl | rfl | rfl
        exacts [⟨_, hS.r0, by simp⟩, ⟨_, hS.r1, by simp⟩, ⟨_, hS.r2, by simp⟩, ⟨_, hS.r3, by simp⟩,
          ⟨_, hS.r4, by simp⟩, ⟨_, hS.r5, by simp⟩]
      exact owned_device_read L dev tgo ctx sh reg (o + j) r hr hs (by simp [dev]; omega)
    · exact owned_group_read L dev tgo ctx sh 7 (o + j) _ hS.r7 rfl (by simp [tgo, h.grpe, hne])) h.log⟩

/-- A write to thread memory. -/
theorem Mem.tput (h : Mem C L I M out P ge cbOk sh) {reg : Nat} (o : Nat) (bs : List (BitVec 8)) (hreg : 8 ≤ reg) :
    Mem C L I M out P ge cbOk (tput sh reg o bs) :=
  ⟨h.regions, by rw [tput_other _ _ _ (by omega)]; exact h.x, by rw [tput_other _ _ _ (by omega)]; exact h.s,
    by rw [tput_other _ _ _ (by omega)]; exact h.gc, by rw [tput_other _ _ _ (by omega)]; exact h.gs,
    by rw [tput_other _ _ _ (by omega)]; exact h.uc, by rw [tput_other _ _ _ (by omega)]; exact h.us, h.deve, h.grpe,
    fun e he hc => by rw [tput_other _ _ _ (by omega)]; exact h.cb e he hc,
    fun m hm row hrow hp => by rw [tput_other _ _ _ (by omega)]; exact h.mid m hm row hrow hp, h.log⟩

/-- Thread `e % 128` of threadgroup `g` writes `codebook[e]` before the barrier. -/
theorem Mem.wcb (h : Mem C L I M out P g cbOk sh) (hS : Shape L kg ku M I) (ctx : Ctx) (e : Nat) (he : e < 4096)
    (ht : ctx.thread = g * 128 + e % 128) (hg : ctx.group = g) :
    Mem C L I M out P g (fun e' => cbOk e' ∨ e' = e)
      (wrn ctx sh 7 (2 * e) 2 (wordBytes 2 (Val.f16Bits (cbEntry C e)))) := by
  have hl : (wordBytes 2 (Val.f16Bits (cbEntry C e))).length = 2 := wordBytes_length 2 _
  refine ⟨h.regions, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.x, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.s,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.gc, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.gs,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.uc, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.us, h.deve,
    h.grpe, fun e' he' hc => ?_, fun m hm row hrow hp => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.mid m hm row hrow hp,
    forall_log _ 2 _ (fun j hj => owned_group L dev tgo ctx sh 7 (2 * e + j) _ hS.r7 true rfl
      (by simp only [tgo, h.grpe, hg, and_self, ite_true]; rw [ht]; congr 2; omega)) h.log⟩
  rw [wrn_same]
  by_cases hee : e' = e
  · subst hee
    have := cells_writeBytes_same (sh.bytes 7) (2 * e') (wordBytes 2 (Val.f16Bits (cbEntry C e')))
    rwa [hl] at this
  · rw [cells_writeBytes_other _ _ _ _ _ (by rw [hl]; omega)]
    exact h.cb e' he' (hc.resolve_right hee)

theorem ord_ne {m m' row row' : Nat} (hm : m < 8) (hm' : m' < 8) (hne : ¬ (m' = m ∧ row' = row)) :
    ord m' row' ≠ ord m row := fun h => hne (ord_inj hm' hm h)

/-- Lane `l` of tile `T` writes `mid[fn l + e][8T + fm l]`, the next element in order. -/
theorem Mem.wmid (h : Mem C L I M out P ge cbOk sh) (hS : Shape L kg ku M I) (ctx : Ctx) {T l e : Nat} (hT : T < 2176)
    (hl : l < 32) (he : e < 2) (hm : fn l + e < M) (hM : M ≤ 8) (hP : P = 64 * T + 2 * l + e)
    (ht : ctx.thread = 32 * T + l) (hg : ctx.group = T / 4) :
    Mem C L I M out (P + 1) ge cbOk (wrn ctx sh 6 (2 * (17408 * (fn l + e) + (8 * T + fm l))) 2
      (wordBytes 2 (Val.bf16Bits (out (fn l + e) (8 * T + fm l))))) := by
  have hf := fm_lt hl
  have hfr := laneOf_frag hl e he
  have hwl : (wordBytes 2 (Val.bf16Bits (out (fn l + e) (8 * T + fm l)))).length = 2 := wordBytes_length 2 _
  have hrow : 8 * T + fm l < 17408 := by omega
  refine ⟨h.regions, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.x, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.s,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.gc, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.gs,
    by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.uc, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.us, h.deve,
    h.grpe, fun e' he' hc => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.cb e' he' hc, fun m' hm' row' hrow' hp => ?_,
    forall_log _ 2 _ (fun j hj => owned_device L dev tgo ctx sh 6 _ _ hS.r6 true (by simp)
      ⟨32 * T + l, T / 4, 0⟩ ?_ ht hg (by rw [h.deve])) h.log⟩
  · rw [wrn_same]
    by_cases hrr : m' = fn l + e ∧ row' = 8 * T + fm l
    · obtain ⟨rfl, rfl⟩ := hrr
      have := cells_writeBytes_same (sh.bytes 6) (2 * (17408 * (fn l + e) + (8 * T + fm l)))
        (wordBytes 2 (Val.bf16Bits (out (fn l + e) (8 * T + fm l))))
      rwa [hwl] at this
    · have hne := ord_ne (show fn l + e < 8 by omega) (show m' < 8 by omega) hrr
      rw [ord_lane hl he, ← hP] at hne
      rw [cells_writeBytes_other _ _ _ _ _ (by
        rw [hwl]
        rcases Nat.lt_or_ge m' (fn l + e) with h1 | h1
        · omega
        · rcases Nat.lt_or_ge (fn l + e) m' with h2 | h2
          · omega
          · have : m' = fn l + e := by omega
            subst this
            have : row' ≠ 8 * T + fm l := fun h' => hrr ⟨rfl, h'⟩
            omega)]
      exact h.mid m' hm' row' hrow' (by omega)
  · simp only [dev, ite_true]
    have e1 : (2 * (17408 * (fn l + e) + (8 * T + fm l)) + j) / 2 = 17408 * (fn l + e) + (8 * T + fm l) := by omega
    rw [e1, show (17408 * (fn l + e) + (8 * T + fm l)) % 17408 = 8 * T + fm l by omega,
      show (17408 * (fn l + e) + (8 * T + fm l)) / 17408 = fn l + e by omega,
      show (8 * T + fm l) / 8 = T by omega, show (8 * T + fm l) % 8 = fm l by omega, hfr.1,
      show (8 * T + fm l) / 32 = T / 4 by omega]

/-- A position without an element of `mid` (past the row count). -/
theorem Mem.bump (h : Mem C L I M out P ge cbOk sh) {T l e : Nat} (hl : l < 32) (he : e < 2) (hm : M ≤ fn l + e)
    (hM : M ≤ 8) (hP : P = 64 * T + 2 * l + e) : Mem C L I M out (P + 1) ge cbOk sh :=
  ⟨h.regions, h.x, h.s, h.gc, h.gs, h.uc, h.us, h.deve, h.grpe, h.cb, fun m hm row hrow hp => h.mid m hm row hrow (by
    have hne := ord_ne (m := fn l + e) (m' := m) (row := 8 * T + fm l) (row' := row) (by have := fn_lt hl; omega)
      (by omega) (fun h' => by omega)
    rw [ord_lane hl he, ← hP] at hne
    omega), h.log⟩

/-- The barrier (threadgroup memory only). -/
theorem Mem.pass (h : Mem C L I M out P ge cbOk sh) : Mem C L I M out P (ge + 1) cbOk (pass false true sh) :=
  ⟨h.regions, h.x, h.s, h.gc, h.gs, h.uc, h.us, by simp [Metal.pass, h.deve], by simp [Metal.pass, h.grpe], h.cb,
    h.mid, h.log⟩

/-- A threadgroup starts: its codebook holds garbage. -/
theorem Mem.reset (h : Mem C L I M out P ge cbOk sh) (hb : L.buffers.length = 7) (garbage : Garbage) (g : Nat) :
    Mem C L I M out P ge (fun _ => False) { sh with bytes := L.resetGroup garbage g sh.bytes } :=
  ⟨h.regions,
    by show L.resetGroup garbage g sh.bytes 0 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.x,
    by show L.resetGroup garbage g sh.bytes 1 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.s,
    by show L.resetGroup garbage g sh.bytes 2 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.gc,
    by show L.resetGroup garbage g sh.bytes 3 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.gs,
    by show L.resetGroup garbage g sh.bytes 4 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.uc,
    by show L.resetGroup garbage g sh.bytes 5 = _; rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.us,
    h.deve, h.grpe, fun _ _ hf => hf.elim,
    fun m hm row hrow hp => by
      show cells (L.resetGroup garbage g sh.bytes 6) _ 2 = _
      rw [Launch.resetGroup_buffer _ _ _ _ _ (by omega)]; exact h.mid m hm row hrow hp,
    h.log⟩

end Memory

/-! ## A thread -/

/-- Lane `i` of SIMD-group `s` of threadgroup `g`. -/
structure Lane (ctx : Ctx) (g s i : Nat) : Prop where
  lane : ctx.coord .threadIndexInSimdgroup = u32 i
  sg : ctx.coord .simdgroupIndexInThreadgroup = u32 s
  tgpos : ctx.coord .threadgroupPositionInGrid = u32x3 0 g 0
  thread : ctx.thread = g * 128 + (32 * s + i)
  group : ctx.group = g
  ga0 : ctx.groupArray 0 = 7
  ta : ∀ j, ctx.threadArray j = 8 + (g * 128 + (32 * s + i)) * 11 + j
  hg : g < 544
  hs : s < 4
  hi : i < 32

theorem launch_tiles {kg ku M : Nat} {I : In} {initial : Nat → ByteMemory.Bytes} :
    (launch kg ku M I initial).Tiles 128 1 1 1 544 1 4 := ⟨rfl, rfl, rfl, by decide⟩

theorem lane_of {kg ku M : Nat} {I : In} {initial : Nat → ByteMemory.Bytes} (fuse : Nat → Bool) {g : Nat}
    (hg : g < 544) (s : Fin 4) (i : Fin 32) :
    Lane ((launch kg ku M I initial).ctxAt fuse 0 g 0 (32 * s + i)) g s i := by
  have hs := s.isLt; have hi := i.isLt
  refine ⟨Launch.ctxAt_lane _ _ _ _ _ _ _, Launch.ctxAt_simd _ _ _ _ _ _ _, Launch.ctxAt_threadgroupPositionInGrid _ _ _ _ _ _,
    ?_, ?_, rfl, fun j => ?_, hg, hs, hi⟩
  · rw [launch_tiles.thread]; omega
  · rw [launch_tiles.group_id]; omega
  · rw [launch_tiles.threadArray, show (launch kg ku M I initial).buffers.length = 7 from rfl,
      show (launch kg ku M I initial).groupArrays = 1 from rfl, show (launch kg ku M I initial).threadArrays = 11 from rfl]
    omega

/-! ## Before the barrier: the codebook -/

/-- The buffer pointers. -/
structure Fix0 (l : Locals) : Prop where
  l0 : l 0 = some (.ptr ⟨0, 0, .scalar .bf16⟩)
  l1 : l 1 = some (.ptr ⟨1, 0, .scalar .i32⟩)
  l2 : l 2 = some (.ptr ⟨2, 0, .scalar .u32⟩)
  l3 : l 3 = some (.ptr ⟨3, 0, .scalar .f16⟩)
  l4 : l 4 = some (.ptr ⟨4, 0, .scalar .u32⟩)
  l5 : l 5 = some (.ptr ⟨5, 0, .scalar .f16⟩)
  l6 : l 6 = some (.ptr ⟨6, 0, .scalar .bf16⟩)

theorem Fix0.of_eq {l l' : Locals} (h : Fix0 l) (h' : ∀ j, j ≤ 6 → l' j = l j) : Fix0 l' :=
  ⟨(h' 0 (by omega)).trans h.l0, (h' 1 (by omega)).trans h.l1, (h' 2 (by omega)).trans h.l2,
    (h' 3 (by omega)).trans h.l3, (h' 4 (by omega)).trans h.l4, (h' 5 (by omega)).trans h.l5,
    (h' 6 (by omega)).trans h.l6⟩

/-- Also `M`, `lane`, `sg` and the codebook. -/
structure Fix1 (M s i : Nat) (l : Locals) : Prop where
  fix0 : Fix0 l
  l7 : l 7 = some (u32 M)
  l8 : l 8 = some (u32 i)
  l9 : l 9 = some (u32 s)
  l10 : l 10 = some (.ptr ⟨7, 0, .scalar .f16⟩)

theorem Fix1.of_eq {M s i : Nat} {l l' : Locals} (h : Fix1 M s i l) (h' : ∀ j, j ≤ 10 → l' j = l j) :
    Fix1 M s i l' :=
  ⟨h.fix0.of_eq fun j hj => h' j (by omega), (h' 7 (by omega)).trans h.l7, (h' 8 (by omega)).trans h.l8,
    (h' 9 (by omega)).trans h.l9, (h' 10 (by omega)).trans h.l10⟩

/-- The statements before the scope. -/
def bodyPre : List CStmt := (GateUpCodebookMma.body 0 0).take 7

/-- The scope's statements before the codebook loop. -/
def scopePre : List CStmt :=
  match GateUpCodebookMma.body 0 0 with
  | [_, _, _, _, _, _, _, .scope (a :: b :: c :: d :: e :: _)] => [a, b, c, d, e]
  | _ => []

/-- The scope's statements after the barrier. -/
def rest (kg ku : Nat) : List CStmt :=
  match GateUpCodebookMma.body kg ku with
  | [_, _, _, _, _, _, _, .scope (_ :: _ :: _ :: _ :: _ :: _ :: _ :: r)] => r
  | _ => []

theorem body_eq (kg ku : Nat) : GateUpCodebookMma.body kg ku =
    bodyPre ++ [.scope ((scopePre ++ [GateUpCodebookMma.fillLoop]) ++ .barrier 1 false true :: rest kg ku)] := rfl

/-- `trellis_y_f32`'s last statement. -/
def yTail : CExpr :=
  .bin .sub .f32 0 (.bitcast .f32 (.bin .bitOr .u32 0 (.lit (.int .u32 0x4B000000))
    (.conv .u32 (.bin .add .i32 0 (.local 15) (.lit (.int .i32 510)))))) (.lit (.f32 (Val.ofF32Bits 0x4B0001FE)))

theorem yF32_eq : GateUpCodebookMma.yF32 12 = .scope [.set 14 (.local 12), trellisYAt 14, .set 13 yTail, .leave] := rfl

section Phase1
variable (C : M1Max.Contract) {ctx : Ctx}

/-- The arithmetic of `trellis_y(s)`: `x`, `p` and the result. -/
theorem trellisY_facts (s : Nat) :
    (s * 34038481 + 76625530) % 2 ^ 32 < 2 ^ 32 ∧
    trellisP s = ((s * 34038481 + 76625530) % 2 ^ 32 &&& 16711935) +
      ((s * 34038481 + 76625530) % 2 ^ 32 / 2 ^ 8 &&& 16711935) ∧
    trellisP s < 2 ^ 25 ∧ (trellisP s &&& 65535) + trellisP s / 2 ^ 16 < 2 ^ 31 ∧
    trellisYv s = (((trellisP s &&& 65535) + trellisP s / 2 ^ 16 : Nat) : Int) - 510 := by
  refine ⟨Nat.mod_lt _ (by decide), rfl, trellisP_lt s, ?_, by unfold trellisYv; rfl⟩
  have := Nat.and_le_right (n := trellisP s) (m := 65535); have := trellisP_lt s; omega

/-- The inlined `trellis_y_f32(s)` (`s` in slot 12): its value in slot 13. -/
theorem exec_yF32 {l : Locals} {sh : Shared} {s : Nat} (h : l 12 = some (u32 s)) :
    ∃ l', Exec C ctx [GateUpCodebookMma.yF32 12] l sh .normal l' sh ∧ l' 13 = some (.f32 (yF32v C s)) ∧
      ∀ j, j ≤ 12 ∨ 17 < j → l' j = l j := by
  obtain ⟨l₁, x1, h15, hag⟩ := exec_trellisY C (ctx := ctx) 14 (l := setLocal l 14 (u32 s)) (sh := sh) (s := s)
    (setLocal_same _ _ _)
  obtain ⟨-, -, -, hYl, hty⟩ := trellisY_facts s
  generalize hYd : (trellisP s &&& 65535) + trellisP s / 2 ^ 16 = Y at hYl hty
  clear hYd
  rw [hty] at h15
  have hY32 : Y < 2 ^ 32 := lt_trans hYl (by decide)
  have hor : 1258291200 ||| Y < 2 ^ 32 := Nat.or_lt_two_pow (by decide) hY32
  have hv : yF32v C s = C.fadd (Val.ofF32Bits (1258291200 ||| Y)) (f32Neg (Val.ofF32Bits 0x4B0001FE)) := by
    unfold yF32v; rw [hty, show ((Y : Int) - 510 + 510).toNat = Y by omega]
  have e4 : (eval C ctx l₁ yTail).run sh = some (.f32 (yF32v C s), sh) := by
    have hz : binary C .add .i32 (i32 ((Y : Int) - 510)) (.int .i32 510) = some (.int .i32 Y) := by
      rw [show Val.int .i32 510 = i32 510 from rfl, binary_add_i32v C (by omega) (by omega) (by omega) (by omega)
        (by omega) (by omega), i32_of_nat (n := Y) (by omega) hY32]
    have hb : (eval C ctx l₁ (.bitcast .f32 (.bin .bitOr .u32 0 (.lit (.int .u32 0x4B000000))
        (.conv .u32 (.bin .add .i32 0 (.local 15) (.lit (.int .i32 510))))))).run sh =
        some (.f32 (Val.ofF32Bits (1258291200 ||| Y)), sh) :=
      eval_bitcast C (eval_bin_u32 C (eval_u32lit C _ _ _ (by decide))
        (eval_conv C (t := .u32) (eval_int C (by decide) (eval_local' C h15 sh) (eval_lit C _ _ _ _) hz)
          (convert_u32_i32 C _ hYl))
        (binary_bitOr_u32 C 1258291200 _ (by decide) hY32)) (bitcast_f32_u32 _ hor)
    rw [hv]
    exact eval_f32 C (.inr ⟨rfl, rfl⟩) hb (eval_lit C _ _ _ _) rfl
  refine ⟨setLocal l₁ 13 (.f32 (yF32v C s)), ?_, setLocal_same _ _ _, fun j hj => ?_⟩
  · rw [yF32_eq]
    exact .scope (.set (eval_local' C h sh) (x1.append (.set e4 .leave))) (.inr rfl) (.nil _ _)
  · rw [setLocal_other _ _ (by omega), hag j (by omega), setLocal_other _ _ (by omega)]
variable {L : Launch} {kg ku M : Nat} {I : In} {out : Nat → Nat → BF} {P g s i : Nat}

theorem fix0_pre (ctx : Ctx) (sh : Shared) : ∃ l, Exec C ctx bodyPre (fun _ => none) sh .normal l sh ∧ Fix0 l :=
  ⟨_, .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <|
    .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <|
      .nil _ _,
    ⟨by simp [setLocal], by simp [setLocal], by simp [setLocal], by simp [setLocal], by simp [setLocal],
      by simp [setLocal], by simp [setLocal]⟩⟩

/-- `M = x_shape[0]`, `lane`, `sg`, the codebook and the loop's start. -/
theorem fix1_pre (hS : Shape L kg ku M I) (hl : Lane ctx g s i) (hM : bytesWord (cells I.S 0 4) = M) (hM8 : M ≤ 8)
    {l : Locals} (hF : Fix0 l) {cbOk : Nat → Prop} {sh : Shared} (hm : Mem C L I M out P g cbOk sh) :
    ∃ l', Exec C ctx scopePre l sh .normal l' (rdn ctx sh 1 0 4) ∧ Fix1 M s i l' ∧
      l' 11 = some (u32 (32 * s + i)) := by
  have hp : (eval C ctx l (.offset (.local 1) (GateUpCodebookMma.i32l 0))).run sh =
      some (.ptr ⟨1, ((0 : Nat) : Int), .scalar .i32⟩, sh) :=
    eval_offset_i32 C (o := 0) (n := 0) (eval_local' C hF.l1 sh) (eval_lit C _ _ _ _) (by decide)
  have hld := load_shared ctx .i32 sh 1 0 _ (by rw [hm.regions]; exact hS.r1) (by simp) (by simpa [Scalar.bytes] using hS.ash)
    (by simp [Scalar.bytes]) (by simp [Scalar.bytes]) (by simp [loadOffset])
  rw [hm.s, show Scalar.i32.bytes = 4 from rfl, hM] at hld
  have hv : Val.ofWord .i32 M = .int .i32 M := by
    show Val.int .i32 (M % 2 ^ 32) = _; rw [Nat.mod_eq_of_lt (by omega)]
  rw [hv] at hld
  have e7 : (eval C ctx l (.conv .u32 (.load (.scalar .i32) (.offset (.local 1) (GateUpCodebookMma.i32l 0))))).run sh =
      some (u32 M, rdn ctx sh 1 0 4) :=
    eval_conv C ((eval_load C _ _ _ _ _ _ _ hp).trans hld) (convert_u32_i32 C (a := M) (by omega))
  have hs := hl.hs; have hi := hl.hi
  refine ⟨_, .set e7 <| .set (eval_coord C _ _ _ _) <| .set (eval_coord C _ _ _ _) <| .array <|
    .set (eval_bin_u32 C (eval_bin_u32 C (eval_local' C (by simp [setLocal, hl.sg]) _) (eval_u32lit C _ _ 32 (by decide))
      (binary_mul_u32 C s 32)) (eval_local' C (by simp [setLocal, hl.lane]) _) (binary_add_u32 C _ i)) <| .nil _ _,
    ⟨hF.of_eq fun j hj => by simp (disch := omega) only [setLocal_lt], by simp [setLocal], by simp [setLocal, hl.lane],
      by simp [setLocal, hl.sg], by simp [setLocal, hl.ga0]⟩, by simp [setLocal]; ring_nf⟩

end Phase1

/-! ## `codebook_mma_state` -/

theorem state_arith {K j : Nat} (hK : GateUp.Width K) (hj : j < 32) :
    (31 - j) * K < 2 ^ 30 ∧ (31 - j) * K + 12 ≤ 32 * (K + 1) ∧
    ((31 - j) * K % 32 + 12 ≤ 32 → (31 - j) * K / 32 ≤ K) ∧
    (¬ ((31 - j) * K % 32 + 12 ≤ 32) → 1 ≤ ((31 - j) * K + 16) / 32 ∧ ((31 - j) * K + 16) / 32 ≤ K ∧
      ((31 - j) * K + 16) % 32 + 12 ≤ 32 ∧ 32 * (((31 - j) * K + 16) / 32) ≤ (31 - j) * K + 16) := by
  have hk := GateUp.width_le hK
  have hb : (31 - j) * K ≤ 31 * 4 := by rcases hK with rfl | rfl | rfl | rfl <;> omega
  have hbk : (31 - j) * K + 12 ≤ 32 * (K + 1) := by rcases hK with rfl | rfl | rfl | rfl <;> omega
  generalize (31 - j) * K = bb at hb hbk ⊢
  exact ⟨by omega, hbk, fun h => by omega, fun h => ⟨by omega, by omega, by omega, by omega⟩⟩

section State
variable (C : M1Max.Contract) {ctx : Ctx}

/-- **`codebook_mma_state<K, 12>(w, v, j)`**, with `w`, `v`, `j` in slots `sw`, `sv`, `sj` (`sv`, `sj` below `b`), words `W` in
`w` and virtual words (the words' value moved up 16 bits) at `1 … K` in `v`: bits `(31 - j)·K …` of the words'
value, in slot `b + 3`. -/
theorem exec_state (K b : Nat) {sw sv sj : Nat} (hsv : sv < b) (hsj : sj < b) (hK : GateUp.Width K)
    {l : Locals} {sh : Shared} {rw rv : Nat} {W : Nat → Nat} {j : Nat} (hj : j < 32)
    (hlw : l sw = some (.ptr ⟨rw, 0, .scalar .u32⟩)) (hlv : l sv = some (.ptr ⟨rv, 0, .scalar .u32⟩))
    (hlj : l sj = some (u32 j))
    (hW : ∀ i ≤ K, (loadAt ctx (.scalar .u32) ⟨rw, ((4 * i : Nat) : Int), .scalar .u32⟩).run sh = some (u32 (W i), sh))
    (hV : ∀ i, 1 ≤ i → i ≤ K → (loadAt ctx (.scalar .u32) ⟨rv, ((4 * i : Nat) : Int), .scalar .u32⟩).run sh =
      some (u32 (GateUp.virt W (K + 1) i), sh))
    (hWl : ∀ i, W i < 2 ^ 32) :
    ∃ l', Exec C ctx (GateUpCodebookMma.state K b (.local sw) (.local sv) (.local sj)) l sh .normal l' sh ∧
      l' (b + 3) = some (u32 (runBits W (K + 1) / 2 ^ ((31 - j) * K) % 2 ^ 12)) ∧ ∀ x, x < b → l' x = l x := by
  have ha := state_arith hK hj
  have hKl := GateUp.lt32_of_width hK
  generalize hbb : (31 - j) * K = bb at ha ⊢
  have hWw : ∀ i < K + 1, W i < 2 ^ 32 := fun i _ => hWl i
  generalize hl₃ : setLocal (setLocal (setLocal l b (.ptr ⟨rw, 0, .scalar .u32⟩)) (b + 1) (.ptr ⟨rv, 0, .scalar .u32⟩))
    (b + 2) (u32 j) = l₃
  have hl₃b : ∀ x, x < b → l₃ x = l x := fun x hx => by
    rw [← hl₃, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
  have h3b : l₃ b = some (.ptr ⟨rw, 0, .scalar .u32⟩) := by
    rw [← hl₃, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_same]
  have h3b1 : l₃ (b + 1) = some (.ptr ⟨rv, 0, .scalar .u32⟩) := by
    rw [← hl₃, setLocal_other _ _ (by omega), setLocal_same]
  have h3b2 : l₃ (b + 2) = some (u32 j) := by rw [← hl₃, setLocal_same]
  have hpre : Exec C ctx [.set b (.local sw), .set (b + 1) (.local sv), .set (b + 2) (.local sj)] l sh .normal l₃ sh := by
    rw [← hl₃]
    exact .set (eval_local' C hlw sh) <| .set (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact hlv) sh) <|
      .set (eval_local' C (by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact hlj) sh) <| .nil _ _
  have e4 : (eval C ctx l₃ (cu .mul (cu .sub (cl 31) (.local (b + 2))) (cl K))).run sh = some (u32 bb, sh) := by
    rw [← hbb]
    exact eval_bin_u32 C (eval_bin_u32 C (eval_u32lit C _ _ 31 (by decide)) (eval_local' C h3b2 sh)
      (binary_sub_u32 C 31 j (by omega))) (eval_u32lit C _ _ K hKl) (binary_mul_u32 C _ K)
  generalize hl₄ : setLocal l₃ (b + 4) (u32 bb) = l₄
  have h44 : l₄ (b + 4) = some (u32 bb) := by rw [← hl₄, setLocal_same]
  have e5 : (eval C ctx l₄ (cu .bitAnd (.local (b + 4)) (cl 31))).run sh = some (u32 (bb % 32), sh) := by
    rw [← and31]
    exact eval_bin_u32 C (eval_local' C h44 sh) (eval_u32lit C _ _ 31 (by decide))
      (binary_bitAnd_u32 C bb 31 (by omega) (by decide))
  generalize hl₅ : setLocal l₄ (b + 5) (u32 (bb % 32)) = l₅
  have h55 : l₅ (b + 5) = some (u32 (bb % 32)) := by rw [← hl₅, setLocal_same]
  have h54 : l₅ (b + 4) = some (u32 bb) := by rw [← hl₅, setLocal_other _ _ (by omega)]; exact h44
  have h5b : ∀ x, x < b + 4 → l₅ x = l₃ x := fun x hx => by
    rw [← hl₅, setLocal_other _ _ (by omega), ← hl₄, setLocal_other _ _ (by omega)]
  have ec : (eval C ctx l₅ (cu .le (cu .add (.local (b + 5)) (cl 12)) (cl 32))).run sh =
      some (.bool (decide (bb % 32 + 12 ≤ 32)), sh) :=
    eval_bin_u32 C (eval_bin_u32 C (eval_local' C h55 sh) (eval_u32lit C _ _ 12 (by decide))
      (binary_add_u32 C _ 12)) (eval_u32lit C _ _ 32 (by decide)) (binary_le_u32 C _ 32 (by omega) (by decide))
  have hdone : ∀ (lx : Locals) (v : Nat), (∀ x, x < b + 4 → lx x = l₃ x) →
      v = runBits W (K + 1) / 2 ^ bb % 2 ^ 12 → ∃ l', l' = setLocal lx (b + 3) (u32 v) ∧
        l' (b + 3) = some (u32 (runBits W (K + 1) / 2 ^ bb % 2 ^ 12)) ∧ ∀ x, x < b → l' x = l x :=
    fun lx v hx hv => ⟨_, rfl, by rw [setLocal_same, hv], fun x hxb => by
      rw [setLocal_other _ _ (by omega), hx x (by omega), hl₃b x hxb]⟩
  by_cases hin : bb % 32 + 12 ≤ 32
  · rw [decide_eq_true hin] at ec
    have hab := ha.2.2.1 hin
    have hsh : (eval C ctx l₅ (cu .shr (.local (b + 4)) (cl 5))).run sh = some (u32 (bb / 2 ^ 5), sh) :=
      eval_bin_u32 C (eval_local' C h54 sh) (eval_u32lit C _ _ 5 (by decide)) (binary_shr_u32 C bb 5 (by omega) (by decide))
    have hp := eval_ptr_u32 C (ctx := ctx) (eval_local' C (by rw [h5b b (by omega)]; exact h3b) sh) hsh (by omega)
    rw [show bb / 2 ^ 5 * (Ty.scalar .u32).bytes = 4 * (bb / 32) by
      simp only [Ty.bytes, Scalar.bytes]; rw [show (2 : Nat) ^ 5 = 32 by norm_num]; omega] at hp
    have hld := (eval_load C _ _ _ _ _ _ _ hp).trans (hW (bb / 32) hab)
    have hWa := hWl (bb / 32)
    have ev : (eval C ctx l₅ (cu .bitAnd (cu .shr (GateUpCodebookMma.ld (.offset (.local b) (cu .shr (.local (b + 4)) (cl 5))))
        (.local (b + 5))) (cl 4095))).run sh = some (u32 (W (bb / 32) / 2 ^ (bb % 32) % 2 ^ 12), sh) := by
      rw [← and4095]
      exact eval_bin_u32 C (eval_bin_u32 C hld (eval_local' C h55 sh) (binary_shr_u32 C _ _ hWa (by omega)))
        (eval_u32lit C _ _ 4095 (by decide))
        (binary_bitAnd_u32 C _ 4095 (lt_of_le_of_lt (Nat.div_le_self _ _) hWa) (by decide))
    have hv : W (bb / 32) / 2 ^ (bb % 32) % 2 ^ 12 = runBits W (K + 1) / 2 ^ bb % 2 ^ 12 := by
      rw [← runBits_word hWw (bb / 32) (by omega), field_inword _ _ _ hin, Nat.div_add_mod]
    obtain ⟨l', rfl, h3, hag⟩ := hdone l₅ _ h5b hv
    refine ⟨_, ?_, h3, hag⟩
    refine hpre.append (.scope ?_ (.inr rfl) (.nil _ _))
    exact .set e4 (by rw [hl₄]; exact .set e5 (by rw [hl₅]; exact .ite_exit ec (.set ev .leave) (.inr (.inr rfl))))
  · rw [decide_eq_false hin] at ec
    obtain ⟨hv1, hvK, hsft, hvle⟩ := ha.2.2.2 hin
    have e6 : (eval C ctx l₅ (cu .shr (cu .add (.local (b + 4)) (cl 16)) (cl 5))).run sh =
        some (u32 ((bb + 16) / 32), sh) := by
      rw [show (bb + 16) / 32 = (bb + 16) / 2 ^ 5 by norm_num]
      exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C h54 sh) (eval_u32lit C _ _ 16 (by decide))
        (binary_add_u32 C bb 16)) (eval_u32lit C _ _ 5 (by decide)) (binary_shr_u32 C _ 5 (by omega) (by decide))
    generalize hvi : (bb + 16) / 32 = vi at hv1 hvK hvle e6
    generalize hl₆ : setLocal l₅ (b + 6) (u32 vi) = l₆
    have h66 : l₆ (b + 6) = some (u32 vi) := by rw [← hl₆, setLocal_same]
    have h6b : ∀ x, x < b + 6 → l₆ x = l₅ x := fun x hx => by rw [← hl₆, setLocal_other _ _ (by omega)]
    have hp := eval_ptr_u32 C (ctx := ctx) (sh := sh)
      (eval_local' C (by rw [h6b (b + 1) (by omega), h5b (b + 1) (by omega)]; exact h3b1) sh) (eval_local' C h66 sh)
      (by omega)
    rw [show vi * (Ty.scalar .u32).bytes = 4 * vi by simp only [Ty.bytes, Scalar.bytes]; omega] at hp
    have hld := (eval_load C _ _ _ _ _ _ _ hp).trans (hV vi hv1 hvK)
    have hVl : GateUp.virt W (K + 1) vi < 2 ^ 32 := Nat.mod_lt _ (by decide)
    have hshift : (eval C ctx l₆ (cu .sub (cu .add (.local (b + 4)) (cl 16)) (cu .mul (cl 32) (.local (b + 6))))).run sh =
        some (u32 ((bb + 16) % 32), sh) := by
      rw [show (bb + 16) % 32 = bb + 16 - 32 * vi by omega]
      exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C (by rw [h6b (b + 4) (by omega)]; exact h54) sh)
        (eval_u32lit C _ _ 16 (by decide)) (binary_add_u32 C bb 16))
        (eval_bin_u32 C (eval_u32lit C _ _ 32 (by decide)) (eval_local' C h66 sh) (binary_mul_u32 C 32 vi))
        (binary_sub_u32 C _ _ hvle)
    have ev : (eval C ctx l₆ (cu .bitAnd (cu .shr (GateUpCodebookMma.ld (.offset (.local (b + 1)) (.local (b + 6))))
        (cu .sub (cu .add (.local (b + 4)) (cl 16)) (cu .mul (cl 32) (.local (b + 6))))) (cl 4095))).run sh =
        some (u32 (GateUp.virt W (K + 1) vi / 2 ^ ((bb + 16) % 32) % 2 ^ 12), sh) := by
      rw [← and4095]
      exact eval_bin_u32 C (eval_bin_u32 C hld hshift (binary_shr_u32 C _ _ hVl (by omega)))
        (eval_u32lit C _ _ 4095 (by decide))
        (binary_bitAnd_u32 C _ 4095 (lt_of_le_of_lt (Nat.div_le_self _ _) hVl) (by decide))
    have hv : GateUp.virt W (K + 1) vi / 2 ^ ((bb + 16) % 32) % 2 ^ 12 = runBits W (K + 1) / 2 ^ bb % 2 ^ 12 := by
      unfold GateUp.virt; exact field_virtual _ bb vi _ hsft (by omega)
    obtain ⟨l', rfl, h3, hag⟩ := hdone l₆ _ (fun x hx => by rw [h6b x (by omega), h5b x hx]) hv
    refine ⟨_, ?_, h3, hag⟩
    refine hpre.append (.scope ?_ (.inr rfl) (.nil _ _))
    have x6 : Exec C ctx [.set (b + 6) (cu .shr (cu .add (.local (b + 4)) (cl 16)) (cl 5)),
        .set (b + 3) (cu .bitAnd (cu .shr (GateUpCodebookMma.ld (.offset (.local (b + 1)) (.local (b + 6))))
          (cu .sub (cu .add (.local (b + 4)) (cl 16)) (cu .mul (cl 32) (.local (b + 6))))) (cl 4095)), .leave]
        l₅ sh .leave (setLocal l₆ (b + 3) (u32 (GateUp.virt W (K + 1) vi / 2 ^ ((bb + 16) % 32) % 2 ^ 12))) sh :=
      .set e6 (by rw [hl₆]; exact .set ev .leave)
    exact .set e4 (by rw [hl₄]; exact .set e5 (by rw [hl₅]; exact .ite ec (.nil _ _) x6))

end State

section Elems
variable (C : M1Max.Contract) {ctx : Ctx}

/-- `aG.thread_elements()[e] = codebook[state]`: the half codebook entry `x` at the state in slot `r`, into
element `e` of the `half2` thread array `ra`. -/
theorem exec_aElem (m e r : Nat) {l : Locals} {sh : Shared} {ra st : Nat} {x : Float16.Value} (he : e < 2)
    (hm : l m = some (.ptr ⟨ra, 0, .vec .f16 2⟩)) (h10 : l 10 = some (.ptr ⟨7, 0, .scalar .f16⟩))
    (hr : l r = some (u32 st)) (hst : st < 4096)
    (hra : sh.regions ra = some ⟨.thread, 4, 4⟩) (h7 : sh.regions 7 = some ⟨.threadgroup, 8192, 2⟩)
    (hcb : cells (sh.bytes 7) (2 * st) 2 = wordBytes 2 (Val.f16Bits x)) :
    Exec C ctx [GateUpCodebookMma.aElem m e r] l sh .normal l
      (tput (rdn ctx sh 7 (2 * st) 2) ra (2 * e) (wordBytes 2 (Val.f16Bits x))) := by
  have hp : (eval C ctx l (.offset (.ptrCast (.scalar .f16) (.local m)) (ci e))).run sh =
      some (.ptr ⟨ra, ((2 * e : Nat) : Int), .scalar .f16⟩, sh) := by
    have := eval_offset_i32 C (ctx := ctx) (o := 0) (n := e) (eval_ptrCast C (t := .scalar .f16) (eval_local' C hm sh))
      (eval_lit C _ _ _ _) (by omega)
    rwa [show 0 + e * (Ty.scalar .f16).bytes = 2 * e by simp [Ty.bytes, Scalar.bytes]; omega] at this
  have hp2 := eval_ptr_u32 C (ctx := ctx) (eval_local' C h10 sh) (eval_local' C hr sh) (by omega)
  rw [show st * (Ty.scalar .f16).bytes = 2 * st by simp [Ty.bytes, Scalar.bytes]; omega] at hp2
  have hld := load_shared ctx .f16 sh 7 (2 * st) _ h7 (by simp) (by simp [Scalar.bytes])
    (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset, Ty.bytes, Scalar.bytes])
  rw [show Scalar.f16.bytes = 2 from rfl, hcb, ofWord_f16] at hld
  have hstv := store_thread ctx .f16 (rdn ctx sh 7 (2 * st) 2) ra (2 * e) 4 4 (.f16 x) (wordBytes 2 (Val.f16Bits x))
    (by rw [rdn_regions]; exact hra) (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (encode_f16 x)
  exact .store hp ((eval_load C _ _ _ _ _ _ _ hp2).trans hld) hstv (.nil _ _)

/-- `float(as_type<T>(ushort((q & 1u) ? x[q / 2u] >> 16 : x[q / 2u] & 0xFFFFu)))` for the `uint4` in slot `x` holding
bytes `16·c4 …` of `X`: element `8·c4 + q` of `X`. -/
theorem eval_bValue (x : Nat) {l : Locals} {sh : Shared} {X : ByteMemory.Bytes} {c4 q : Nat}
    (hx : l x = some (vec4 (cells X (16 * c4) 16))) (h93 : l 93 = some (u32 q)) (hq : q < 8) :
    (eval C ctx l (GateUpCodebookMma.bValue x)).run sh =
      some (.f32 (C.widen (Val.ofBf16Bits (half X (8 * c4 + q)))), sh) := by
  have hw : (eval C ctx l (.component (.local x) (cu .div (.local 93) (cl 2)))).run sh =
      some (u32 (word32 X (4 * c4 + q / 2)), sh) := by
    have hidx : (eval C ctx l (cu .div (.local 93) (cl 2))).run sh = some (u32 (q / 2), sh) :=
      eval_bin_u32 C (eval_local' C h93 sh) (eval_u32lit C _ _ 2 (by decide))
        (binary_div_u32 C q 2 (by omega) (by decide) (by decide))
    refine eval_component C (eval_local' C (hx.trans (congrArg some (GateUp.vec4_cells X c4))) sh) hidx (natOf_u32 _) ?_
    rw [Nat.mod_eq_of_lt (show q / 2 < 2 ^ 32 by omega), List.getElem?_map,
      List.getElem?_range (show q / 2 < 4 by omega), Option.map_some]
  have hlt := word32_lt X (4 * c4 + q / 2)
  have hh := GateUp.word_halves X (4 * c4 + q / 2)
  have hcond : (eval C ctx l (.conv .bool (cu .bitAnd (.local 93) (cl 1)))).run sh =
      some (.bool (decide ((q &&& 1) % 2 ^ 32 ≠ 0)), sh) :=
    eval_conv C (t := .bool) (eval_bin_u32 C (eval_local' C h93 sh) (eval_u32lit C _ _ 1 (by decide))
      (binary_bitAnd_u32 C q 1 (by omega) (by decide))) rfl
  have hpm : (q &&& 1) % 2 ^ 32 = q % 2 := by
    rw [show (1 : Nat) = 2 ^ 1 - 1 from rfl, Nat.and_two_pow_sub_one_eq_mod]; omega
  rw [hpm] at hcond
  have hval : (eval C ctx l (.cond (.conv .bool (cu .bitAnd (.local 93) (cl 1)))
      (cu .shr (.component (.local x) (cu .div (.local 93) (cl 2))) (cl 16))
      (cu .bitAnd (.component (.local x) (cu .div (.local 93) (cl 2))) (cl 0xFFFF)))).run sh =
      some (u32 (half X (8 * c4 + q)), sh) := by
    refine eval_cond C hcond ?_
    by_cases hqo : q % 2 = 0
    · rw [decide_eq_false (show ¬ q % 2 ≠ 0 from fun h => h hqo)]
      have e : half X (8 * c4 + q) = word32 X (4 * c4 + q / 2) &&& 65535 := by
        rw [show (65535 : Nat) = 2 ^ 16 - 1 from rfl, Nat.and_two_pow_sub_one_eq_mod, hh.1,
          show 2 * (4 * c4 + q / 2) = 8 * c4 + q by omega]
      rw [e]
      exact eval_bin_u32 C hw (eval_u32lit C _ _ _ (by decide)) (binary_bitAnd_u32 C _ _ hlt (by decide))
    · rw [decide_eq_true hqo]
      have e : half X (8 * c4 + q) = word32 X (4 * c4 + q / 2) / 2 ^ 16 := by
        rw [hh.2, show 2 * (4 * c4 + q / 2) + 1 = 8 * c4 + q by omega]
      rw [e]
      exact eval_bin_u32 C hw (eval_u32lit C _ _ 16 (by decide)) (binary_shr_u32 C _ 16 hlt (by decide))
  exact eval_conv C (t := .f32) (eval_bitcast C (eval_conv C (t := .u16) hval (convert_u16_u32 C _ (half_lt X _))) rfl)
    rfl

end Elems

/-! ## `codebook_mma_run` -/

/-- A run's words `w[0 … K]` and virtual words `v[1 … K]` in thread arrays `Bw`, `Bv`. -/
structure RunW (K : Nat) (Codes : ByteMemory.Bytes) (row run : Nat) (Bw Bv : ByteMemory.Bytes) : Prop where
  w : GateUp.Words Bw (K + 1) (GateUp.runWord K Codes row run)
  v : ∀ i, 1 ≤ i → i ≤ K → cells Bv (4 * i) 4 = wordBytes 4 (GateUp.virt (GateUp.runWord K Codes row run) (K + 1) i)

/-- The parts of `codebook_mma_run<K, 256>`'s scope: the block, `t0`, `bw` and `w0`; the words `w[0 … K - 1]`;
`w[K]`; the virtual words. -/
def runA (k b : Nat) : List CStmt :=
  [.set (b + 5) (cl (8 * k)), .set (b + 6) (cl 8),
   .set (b + 7) (cu .div (.local (b + 1)) (.local (b + 6))),
   .set (b + 8) (cu .mul (cu .sub (.local (b + 1)) (cu .mul (.local (b + 7)) (.local (b + 6)))) (cl 32)),
   .set (b + 9) (.offset (.local b) (cu .mul (.local (b + 7)) (.local (b + 5)))),
   .set (b + 10) (cu .div (cu .mul (cu .sub (cl 224) (.local (b + 8))) (cl k)) (cl 32))]
def runW (k b : Nat) : List CStmt :=
  [.set (b + 11) (cl 0), .loop (GateUpCodebookMma.lt (b + 11) k) (GateUpCodebookMma.incr (b + 11))
    [.store (.scalar .u32) (.offset (.local (b + 2)) (.local (b + 11)))
      (GateUpCodebookMma.ld (.offset (.local (b + 9)) (cu .add (.local (b + 10)) (.local (b + 11)))))]]
def runX (k b : Nat) : List CStmt :=
  [.store (.scalar .u32) (.offset (.local (b + 2)) (ci k))
    (GateUpCodebookMma.ld (.offset (.local (b + 9))
      (.cond (cu .eq (.local (b + 8)) (cl 0)) (cl 0) (cu .add (.local (b + 10)) (cl k)))))]
def runV (k b : Nat) : List CStmt :=
  [.set (b + 12) (GateUp.u32l 1), .loop (GateUp.leU (b + 12) k) (GateUp.stepU (b + 12) 1)
    [.store (.scalar .u32) (.offset (.local (b + 3)) (.local (b + 12)))
      (.bin .bitOr .u32 0
        (.bin .shr .u32 0 (.load (.scalar .u32) (.offset (.local (b + 2)) (.bin .sub .u32 0 (.local (b + 12))
          (GateUp.u32l 1)))) (GateUp.u32l 16))
        (.bin .shl .u32 0 (.load (.scalar .u32) (.offset (.local (b + 2)) (.local (b + 12)))) (GateUp.u32l 16)))]]

theorem run_eq (k b : Nat) (r e w v : CExpr) : GateUpCodebookMma.run k b r e w v =
    [.set b r, .set (b + 1) e, .set (b + 2) w, .set (b + 3) v, .scope (runA k b ++ (runW k b ++ (runX k b ++ runV k b)))] :=
  rfl

section Run
variable (C : M1Max.Contract) {ctx : Ctx}

/-- `for (i = 0; i < K; ++i) w[i] = bw[w0 + i]` (counter slot `i`, array slot `w`, block pointer slot `bw`). -/
theorem exec_words {Inv : Shared → Prop} {rc sizeC alC : Nat} {B : ByteMemory.Bytes}
    (hI : GateUp.WordInv ctx Inv rc B sizeC alC) (K i w bw w0 : Nat) {l : Locals} {sh : Shared}
    {rw sizeW bwv w0v : Nat} (hrw : sh.regions rw = some ⟨.thread, sizeW, 4⟩) (hrw8 : 8 ≤ rw)
    (hw : l w = some (.ptr ⟨rw, 0, .scalar .u32⟩)) (hbw : l bw = some (.ptr ⟨rc, ((4 * bwv : Nat) : Int), .scalar .u32⟩))
    (hw0 : l w0 = some (u32 w0v)) (hiw : i ≠ w) (hibw : i ≠ bw) (hiw0 : i ≠ w0)
    (hsize : 4 * K ≤ sizeW) (hidx : 4 * (bwv + w0v + K) ≤ sizeC) (h32 : w0v + K < 2 ^ 32) (h0 : Inv sh) :
    ∃ l' sh', Exec C ctx [.set i (cl 0), .loop (GateUpCodebookMma.lt i K) (GateUpCodebookMma.incr i)
        [.store (.scalar .u32) (.offset (.local w) (.local i))
          (GateUpCodebookMma.ld (.offset (.local bw) (cu .add (.local w0) (.local i))))]] l sh .normal l' sh' ∧
      Inv sh' ∧ (∀ j, j ≠ i → l' j = l j) ∧ l' i = some (u32 K) ∧ sh'.regions = sh.regions ∧
      (∀ r, r ≠ rw → sh'.bytes r = sh.bytes r) ∧
      ∀ j < K, cells (sh'.bytes rw) (4 * j) 4 = wordBytes 4 (word32 B (bwv + w0v + j)) := by
  let J : Nat → Locals → Shared → Prop := fun k l' sh' => Inv sh' ∧ (∀ j, j ≠ i → l' j = l j) ∧ l' i = some (u32 k) ∧
    sh'.regions = sh.regions ∧ (∀ r, r ≠ rw → sh'.bytes r = sh.bytes r) ∧
    ∀ j < k, cells (sh'.bytes rw) (4 * j) 4 = wordBytes 4 (word32 B (bwv + w0v + j))
  obtain ⟨l', sh', hex, hJ⟩ := Exec.loop_count (c := GateUpCodebookMma.lt i K) (st := GateUpCodebookMma.incr i)
    (ctx := ctx) (C := C) K J J
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
      have hidx' : (eval C ctx l' (cu .add (.local w0) (.local i))).run sh' = some (u32 (w0v + k), sh') :=
        eval_bin_u32 C (eval_local' C (by rw [hagree w0 hiw0.symm]; exact hw0) sh') (eval_local' C hi sh')
          (binary_add_u32 C _ k)
      have hsrc : (eval C ctx l' (.offset (.local bw) (cu .add (.local w0) (.local i)))).run sh' =
          some (.ptr ⟨rc, ((4 * (bwv + w0v + k) : Nat) : Int), .scalar .u32⟩, sh') := by
        have := eval_offset_u32 C (o := 4 * bwv) (eval_local' C (by rw [hagree bw hibw.symm]; exact hbw) sh') hidx'
          (by omega)
        rwa [show 4 * bwv + (w0v + k) * (Ty.scalar .u32).bytes = 4 * (bwv + w0v + k) by
          simp [Ty.bytes, Scalar.bytes]; ring] at this
      have hload := load_shared ctx .u32 sh' rc (4 * (bwv + w0v + k)) _ hc'.1 (by simp) (by simpa [Scalar.bytes] using hI.al)
        (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset])
      rw [hc'.2] at hload
      have hv : Val.ofWord .u32 (bytesWord (cells B (4 * (bwv + w0v + k)) Scalar.u32.bytes)) =
          u32 (word32 B (bwv + w0v + k)) := rfl
      rw [hv] at hload
      have hst := store_thread ctx .u32 (rdn ctx sh' rc (4 * (bwv + w0v + k)) Scalar.u32.bytes) rw (4 * k) sizeW 4
        (u32 (word32 B (bwv + w0v + k))) (wordBytes 4 (word32 B (bwv + w0v + k)))
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

/-- `w[K] = bw[t0 == 0u ? 0u : w0 + K]`. -/
theorem exec_wrap {Inv : Shared → Prop} {rc sizeC alC : Nat} {B : ByteMemory.Bytes}
    (hI : GateUp.WordInv ctx Inv rc B sizeC alC) (K w bw w0 t0 : Nat) {l : Locals} {sh : Shared}
    {rw sizeW bwv w0v t0v : Nat} (hrw : sh.regions rw = some ⟨.thread, sizeW, 4⟩) (hrw8 : 8 ≤ rw)
    (hw : l w = some (.ptr ⟨rw, 0, .scalar .u32⟩)) (hbw : l bw = some (.ptr ⟨rc, ((4 * bwv : Nat) : Int), .scalar .u32⟩))
    (hw0 : l w0 = some (u32 w0v)) (ht0 : l t0 = some (u32 t0v)) (ht0l : t0v < 2 ^ 32)
    (hsize : 4 * (K + 1) ≤ sizeW) (hK : K < 2 ^ 31) (hidx : 4 * (bwv + (if t0v = 0 then 0 else w0v + K) + 1) ≤ sizeC)
    (h32 : w0v + K < 2 ^ 32) (h0 : Inv sh) :
    ∃ sh', Exec C ctx [.store (.scalar .u32) (.offset (.local w) (ci K))
        (GateUpCodebookMma.ld (.offset (.local bw) (.cond (cu .eq (.local t0) (cl 0)) (cl 0) (cu .add (.local w0) (cl K)))))]
        l sh .normal l sh' ∧ Inv sh' ∧ sh'.regions = sh.regions ∧ (∀ r, r ≠ rw → sh'.bytes r = sh.bytes r) ∧
      (∀ j < K, cells (sh'.bytes rw) (4 * j) 4 = cells (sh.bytes rw) (4 * j) 4) ∧
      cells (sh'.bytes rw) (4 * K) 4 = wordBytes 4 (word32 B (bwv + if t0v = 0 then 0 else w0v + K)) := by
  have hc' := hI.codes sh h0
  have hp : (eval C ctx l (.offset (.local w) (ci K))).run sh = some (.ptr ⟨rw, ((4 * K : Nat) : Int), .scalar .u32⟩, sh) := by
    have := eval_offset_i32 C (ctx := ctx) (o := 0) (n := K) (eval_local' C hw sh) (eval_lit C _ _ _ _) hK
    rwa [show 0 + K * (Ty.scalar .u32).bytes = 4 * K by simp [Ty.bytes, Scalar.bytes]; ring] at this
  have hcond : (eval C ctx l (.cond (cu .eq (.local t0) (cl 0)) (cl 0) (cu .add (.local w0) (cl K)))).run sh =
      some (u32 (if t0v = 0 then 0 else w0v + K), sh) := by
    refine eval_cond C (eval_eq_u32 C (b := 0) ht0 ht0l (by decide)) ?_
    by_cases h : t0v = 0
    · simp only [h, decide_true, ite_true]; exact eval_u32lit C _ _ 0 (by decide)
    · simp only [h, decide_false, Bool.false_eq_true, ite_false]
      exact eval_bin_u32 C (eval_local' C hw0 sh) (eval_u32lit C _ _ K (by omega)) (binary_add_u32 C w0v K)
  generalize hn : (if t0v = 0 then 0 else w0v + K) = n at hcond
  have hnl : n < w0v + K + 1 := by rw [← hn]; split <;> omega
  have hnc : 4 * (bwv + n + 1) ≤ sizeC := by rw [← hn]; exact hidx
  have hsrc : (eval C ctx l (.offset (.local bw) (.cond (cu .eq (.local t0) (cl 0)) (cl 0) (cu .add (.local w0) (cl K))))).run sh =
      some (.ptr ⟨rc, ((4 * (bwv + n) : Nat) : Int), .scalar .u32⟩, sh) := by
    have := eval_offset_u32 C (o := 4 * bwv) (eval_local' C hbw sh) hcond (by omega)
    rwa [show 4 * bwv + n * (Ty.scalar .u32).bytes = 4 * (bwv + n) by simp [Ty.bytes, Scalar.bytes]; ring] at this
  have hload := load_shared ctx .u32 sh rc (4 * (bwv + n)) _ hc'.1 (by simp) (by simpa [Scalar.bytes] using hI.al)
    (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset])
  rw [hc'.2] at hload
  have hst := store_thread ctx .u32 (rdn ctx sh rc (4 * (bwv + n)) Scalar.u32.bytes) rw (4 * K) sizeW 4
    (u32 (word32 B (bwv + n))) (wordBytes 4 (word32 B (bwv + n))) (by rw [rdn_regions]; exact hrw) (by decide)
    (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (encode_u32 _ (word32_lt B _))
  refine ⟨_, .store hp ((eval_load C _ _ _ _ _ _ _ hsrc).trans hload) hst (.nil _ _), hI.put _ rw _ _ (hI.rd _ _ h0) hrw8,
    by rw [tput_regions, rdn_regions], fun r hr => by rw [tput_other _ _ _ hr, rdn_bytes], fun j hj => ?_, ?_⟩
  · rw [tput_same, rdn_bytes, cells_writeBytes_other _ _ _ _ _ (by rw [wordBytes_length]; omega)]
  · rw [tput_same, rdn_bytes]
    have := cells_writeBytes_same (sh.bytes rw) (4 * K) (wordBytes 4 (word32 B (bwv + n)))
    rwa [wordBytes_length] at this

theorem run_arith {K run : Nat} (hK : GateUp.Width K) (hrun : run < 160) :
    8 * K < 2 ^ 32 ∧ run / 8 * (8 * K) < 2 ^ 32 ∧ (224 - run % 8 * 32) * K < 2 ^ 32 ∧ run % 8 * 32 ≤ 224 ∧
      run - run / 8 * 8 = run % 8 ∧ GateUp.w0 K run + K < 2 ^ 32 := by
  have h := GateUp.ar_w0 (run := run) hK
  rcases hK with rfl | rfl | rfl | rfl <;> refine ⟨by omega, by omega, by omega, by omega, by omega, by omega⟩

/-- **`codebook_mma_run<K, 256>(rowCodes, run, w, v)`** (slots from `b`): run `run` of row `row`'s codes into `w`
and `v`. The arguments evaluate as given in any locals agreeing below `b`. -/
theorem exec_run {Inv : Shared → Prop} {rc sizeC alC : Nat} {B : ByteMemory.Bytes}
    (hI : GateUp.WordInv ctx Inv rc B sizeC alC) (hput : ∀ sh reg o bs, Inv sh → 8 ≤ reg → Inv (tput sh reg o bs))
    (K b : Nat) (hK : GateUp.Width K) {rowE runE wE vE : CExpr} {l : Locals} {sh : Shared} {row run rw rv : Nat}
    (hrow : row < 17408) (hrun : run < 160)
    (hrowE : ∀ l', (∀ j, j < b → l' j = l j) →
      (eval C ctx l' rowE).run sh = some (.ptr ⟨rc, ((4 * (row * (160 * K)) : Nat) : Int), .scalar .u32⟩, sh))
    (hrunE : ∀ l', (∀ j, j < b → l' j = l j) → (eval C ctx l' runE).run sh = some (u32 run, sh))
    (hwE : ∀ l', (∀ j, j < b → l' j = l j) → (eval C ctx l' wE).run sh = some (.ptr ⟨rw, 0, .scalar .u32⟩, sh))
    (hvE : ∀ l', (∀ j, j < b → l' j = l j) → (eval C ctx l' vE).run sh = some (.ptr ⟨rv, 0, .scalar .u32⟩, sh))
    (hrw : sh.regions rw = some ⟨.thread, 4 * (K + 1), 4⟩) (hrv : sh.regions rv = some ⟨.thread, 4 * (K + 1), 4⟩)
    (hrw8 : 8 ≤ rw) (hrv8 : 8 ≤ rv) (hwv : rw ≠ rv) (hsizeC : GateUp.codesBytes K ≤ sizeC) (h0 : Inv sh) :
    ∃ l' sh', Exec C ctx (GateUpCodebookMma.run K b rowE runE wE vE) l sh .normal l' sh' ∧ Inv sh' ∧
      (∀ j, j < b → l' j = l j) ∧ sh'.regions = sh.regions ∧ (∀ r, r ≠ rw → r ≠ rv → sh'.bytes r = sh.bytes r) ∧
      RunW K B row run (sh'.bytes rw) (sh'.bytes rv) := by
  have hk := GateUp.width_le hK
  have ha := run_arith hK hrun
  have ig := GateUp.ar_idx hK hrow hrun
  -- the arguments
  generalize hl₄ : setLocal (setLocal (setLocal (setLocal l b (.ptr ⟨rc, ((4 * (row * (160 * K)) : Nat) : Int), .scalar .u32⟩))
    (b + 1) (u32 run)) (b + 2) (.ptr ⟨rw, 0, .scalar .u32⟩)) (b + 3) (.ptr ⟨rv, 0, .scalar .u32⟩) = l₄
  have hargs : Exec C ctx [.set b rowE, .set (b + 1) runE, .set (b + 2) wE, .set (b + 3) vE] l sh .normal l₄ sh := by
    rw [← hl₄]
    exact .set (hrowE l fun _ _ => rfl) <| .set (hrunE _ fun j hj => by rw [setLocal_other _ _ (by omega)]) <|
      .set (hwE _ fun j hj => by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]) <|
      .set (hvE _ fun j hj => by rw [setLocal_other _ _ (by omega), setLocal_other _ _ (by omega),
        setLocal_other _ _ (by omega)]) <| .nil _ _
  have h4 : ∀ j, j < b → l₄ j = l j := fun j hj => by
    rw [← hl₄, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_other _ _ (by omega),
      setLocal_other _ _ (by omega)]
  have h4b : l₄ b = some (.ptr ⟨rc, ((4 * (row * (160 * K)) : Nat) : Int), .scalar .u32⟩) := by
    rw [← hl₄, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_same]
  have h41 : l₄ (b + 1) = some (u32 run) := by
    rw [← hl₄, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_same]
  have h42 : l₄ (b + 2) = some (.ptr ⟨rw, 0, .scalar .u32⟩) := by
    rw [← hl₄, setLocal_other _ _ (by omega), setLocal_same]
  have h43 : l₄ (b + 3) = some (.ptr ⟨rv, 0, .scalar .u32⟩) := by rw [← hl₄, setLocal_same]
  -- the block, `t0`, `bw`, `w0`
  generalize hl₆ : setLocal (setLocal l₄ (b + 5) (u32 (8 * K))) (b + 6) (u32 8) = l₆
  have h65 : l₆ (b + 5) = some (u32 (8 * K)) := by rw [← hl₆, setLocal_other _ _ (by omega), setLocal_same]
  have h66 : l₆ (b + 6) = some (u32 8) := by rw [← hl₆, setLocal_same]
  have h6 : ∀ j, j < b + 5 → l₆ j = l₄ j := fun j hj => by
    rw [← hl₆, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
  have e7 : (eval C ctx l₆ (cu .div (.local (b + 1)) (.local (b + 6)))).run sh = some (u32 (run / 8), sh) :=
    eval_bin_u32 C (eval_local' C (by rw [h6 _ (by omega)]; exact h41) sh) (eval_local' C h66 sh)
      (binary_div_u32 C run 8 (by omega) (by decide) (by decide))
  generalize hl₇ : setLocal l₆ (b + 7) (u32 (run / 8)) = l₇
  have h77 : l₇ (b + 7) = some (u32 (run / 8)) := by rw [← hl₇, setLocal_same]
  have h7 : ∀ j, j < b + 7 → l₇ j = l₆ j := fun j hj => by rw [← hl₇, setLocal_other _ _ (by omega)]
  have e8 : (eval C ctx l₇ (cu .mul (cu .sub (.local (b + 1)) (cu .mul (.local (b + 7)) (.local (b + 6)))) (cl 32))).run sh =
      some (u32 (run % 8 * 32), sh) := by
    rw [← ha.2.2.2.2.1]
    exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C (by rw [h7 _ (by omega), h6 _ (by omega)]; exact h41) sh)
      (eval_bin_u32 C (eval_local' C h77 sh) (eval_local' C (by rw [h7 _ (by omega)]; exact h66) sh)
        (binary_mul_u32 C _ 8)) (binary_sub_u32 C run _ (by omega))) (eval_u32lit C _ _ 32 (by decide))
      (binary_mul_u32 C _ 32)
  generalize hl₈ : setLocal l₇ (b + 8) (u32 (run % 8 * 32)) = l₈
  have h88 : l₈ (b + 8) = some (u32 (run % 8 * 32)) := by rw [← hl₈, setLocal_same]
  have h8 : ∀ j, j < b + 8 → l₈ j = l₇ j := fun j hj => by rw [← hl₈, setLocal_other _ _ (by omega)]
  have e9 : (eval C ctx l₈ (.offset (.local b) (cu .mul (.local (b + 7)) (.local (b + 5))))).run sh =
      some (.ptr ⟨rc, ((4 * GateUp.gbase K row run : Nat) : Int), .scalar .u32⟩, sh) := by
    have h8b : l₈ b = some (.ptr ⟨rc, ((4 * (row * (160 * K)) : Nat) : Int), .scalar .u32⟩) := by
      rw [h8 _ (by omega), h7 _ (by omega), h6 _ (by omega)]; exact h4b
    have h87 : l₈ (b + 7) = some (u32 (run / 8)) := by rw [h8 _ (by omega)]; exact h77
    have h85 : l₈ (b + 5) = some (u32 (8 * K)) := by rw [h8 _ (by omega), h7 _ (by omega)]; exact h65
    have := eval_offset_u32 C (ctx := ctx) (o := 4 * (row * (160 * K))) (eval_local' C h8b sh)
      (eval_bin_u32 C (op := .mul) (site := 0) (eval_local' C h87 sh) (eval_local' C h85 sh) (binary_mul_u32 C _ _))
      ha.2.1
    rwa [show 4 * (row * (160 * K)) + run / 8 * (8 * K) * (Ty.scalar .u32).bytes = 4 * GateUp.gbase K row run by
      simp only [Ty.bytes, Scalar.bytes, GateUp.gbase]; ring] at this
  generalize hl₉ : setLocal l₈ (b + 9) (.ptr ⟨rc, ((4 * GateUp.gbase K row run : Nat) : Int), .scalar .u32⟩) = l₉
  have h99 : l₉ (b + 9) = some (.ptr ⟨rc, ((4 * GateUp.gbase K row run : Nat) : Int), .scalar .u32⟩) := by
    rw [← hl₉, setLocal_same]
  have h9 : ∀ j, j < b + 9 → l₉ j = l₈ j := fun j hj => by rw [← hl₉, setLocal_other _ _ (by omega)]
  have e10 : (eval C ctx l₉ (cu .div (cu .mul (cu .sub (cl 224) (.local (b + 8))) (cl K)) (cl 32))).run sh =
      some (u32 (GateUp.w0 K run), sh) :=
    eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_u32lit C _ _ 224 (by decide))
      (eval_local' C (by rw [h9 _ (by omega)]; exact h88) sh) (binary_sub_u32 C 224 _ ha.2.2.2.1))
      (eval_u32lit C _ _ K (by omega)) (binary_mul_u32 C _ K)) (eval_u32lit C _ _ 32 (by decide))
      (binary_div_u32 C _ 32 ha.2.2.1 (by decide) (by decide))
  generalize hl₁₀ : setLocal l₉ (b + 10) (u32 (GateUp.w0 K run)) = l₁₀
  have h1010 : l₁₀ (b + 10) = some (u32 (GateUp.w0 K run)) := by rw [← hl₁₀, setLocal_same]
  have h10 : ∀ j, j < b + 10 → l₁₀ j = l₉ j := fun j hj => by rw [← hl₁₀, setLocal_other _ _ (by omega)]
  have hA : Exec C ctx (runA K b) l₄ sh .normal l₁₀ sh :=
    .set (eval_u32lit C _ _ _ ha.1) (Exec.set_eq C (eval_u32lit C _ _ 8 (by decide)) hl₆ (Exec.set_eq C e7 hl₇
      (Exec.set_eq C e8 hl₈ (Exec.set_eq C e9 hl₉ (Exec.set_eq C e10 hl₁₀ (.nil _ _))))))
  have h10b : ∀ j, j < b + 5 → l₁₀ j = l₄ j := fun j hj => by
    rw [h10 _ (by omega), h9 _ (by omega), h8 _ (by omega), h7 _ (by omega), h6 _ hj]
  have hrg : ∀ sh' : Shared, sh'.regions = sh.regions → sh'.regions rw = some ⟨.thread, 4 * (K + 1), 4⟩ :=
    fun sh' h => by rw [h]; exact hrw
  -- the words
  obtain ⟨l₁, sh₁, xW, hm₁, hag₁, -, hreg₁, hoth₁, hw₁⟩ := exec_words C hI K (b + 11) (b + 2) (b + 9) (b + 10)
    (l := l₁₀) (sh := sh) (rw := rw) (sizeW := 4 * (K + 1)) hrw hrw8
    (by rw [h10b _ (by omega)]; exact h42) (by rw [h10 _ (by omega)]; exact h99) h1010 (by omega) (by omega) (by omega)
    (by omega) (by omega) (by omega) h0
  obtain ⟨sh₂, xX, hm₂, hreg₂, hoth₂, hkeep₂, hw₂⟩ := exec_wrap C hI K (b + 2) (b + 9) (b + 10) (b + 8) (l := l₁)
    (sh := sh₁) (rw := rw) (sizeW := 4 * (K + 1)) (t0v := run % 8 * 32) (hrg sh₁ hreg₁) hrw8
    (by rw [hag₁ _ (by omega), h10b _ (by omega)]; exact h42) (by rw [hag₁ _ (by omega), h10 _ (by omega)]; exact h99)
    (by rw [hag₁ _ (by omega)]; exact h1010)
    (by rw [hag₁ _ (by omega), h10 _ (by omega), h9 _ (by omega)]; exact h88) (by omega) (by omega) (by omega)
    (by have := ig.2.2; generalize (if run % 8 * 32 = 0 then 0 else GateUp.w0 K run + K) = q at this ⊢; omega)
    (by omega) hm₁
  have hWw : GateUp.Words (sh₂.bytes rw) (K + 1) (GateUp.runWord K B row run) := by
    intro j hj
    rw [GateUp.runWord]
    by_cases hjk : j < K
    · rw [hkeep₂ j hjk, hw₁ j hjk, ite_eq_left hjk, Nat.add_assoc]
    · rw [show j = K by omega, hw₂, ite_eq_right (Nat.lt_irrefl K)]
  -- the virtual words
  have hc : ∀ (l' : Locals) (sh' : Shared) (k : Nat), k ≤ K → l' (b + 12) = some (u32 (k + 1)) →
      (eval C ctx l' (GateUp.leU (b + 12) K)).run sh' = some (.bool (decide (k < K)), sh') := by
    intro l' sh' k hk' h
    have := eval_bin_u32 C (ctx := ctx) (op := .le) (site := 0) (eval_local' C h sh')
      (eval_u32lit C _ _ K (GateUp.lt32_of_width hK)) (binary_le_u32 C (k + 1) K (by omega) (GateUp.lt32_of_width hK))
    rwa [show decide (k + 1 ≤ K) = decide (k < K) from decide_eq_decide.mpr (by omega)] at this
  obtain ⟨l₃, sh₃, xV, hm₃, hag₃, -, hreg₃, hoth₃, -, hv₃⟩ := GateUp.exec_virtualWords C hput K (b + 12) (b + 2) (b + 3)
    (GateUp.leU (b + 12) K) hc (l := l₁) (sh := sh₂) (rw := rw) (rv := rv) (sizeW := 4 * (K + 1)) (sizeV := 4 * (K + 1))
    (W := GateUp.runWord K B row run) (hrg sh₂ (hreg₂.trans hreg₁)) (by rw [hreg₂, hreg₁]; exact hrv) hrv8 hwv
    (by rw [hag₁ _ (by omega), h10b _ (by omega)]; exact h42) (by rw [hag₁ _ (by omega), h10b _ (by omega)]; exact h43)
    (by omega) (by omega) (fun j hj => hWw j (by omega)) (fun j _ => GateUp.runWord_lt _ _ _ _ _) (by omega) (by omega)
    (by omega) hm₂
  refine ⟨l₃, sh₃, ?_, hm₃, fun j hj => ?_, by rw [hreg₃, hreg₂, hreg₁], fun r h1 h2 => ?_, ⟨?_, fun j h1 h2 => ?_⟩⟩
  · rw [run_eq]
    exact hargs.append (.scope (hA.append (xW.append (xX.append xV))) (.inl rfl) (.nil _ _))
  · rw [hag₃ _ (by omega), hag₁ _ (by omega), h10b _ (by omega), h4 _ hj]
  · rw [hoth₃ _ h2, hoth₂ _ h1, hoth₁ _ h1]
  · intro j hj; rw [hoth₃ _ hwv]; exact hWw j hj
  · rw [hv₃ j h1 h2]
    obtain ⟨k, rfl⟩ : ∃ k, j = k + 1 := ⟨j - 1, by omega⟩
    rw [Nat.add_sub_cancel, shifted_word (W := GateUp.runWord K B row run) (n := K + 1)
      (fun i _ => GateUp.runWord_lt _ _ _ _ _) (i := k) (by omega)]
    rfl

end Run

/-! ## After the barrier: the lane's locals -/

/-- Lane `i` of SIMD-group `s` of threadgroup `g`: its thread, its first thread array's region, its row. -/
def thr (g s i : Nat) : Nat := g * 128 + (32 * s + i)
def rb (g s i : Nat) : Nat := 8 + thr g s i * 11
def rowOf (g s i : Nat) : Nat := 8 * (4 * g + s) + fm i
/-- `x0` (`e = 0`) and `x1` (`e = 1`) in `uint4`s: `x` row `min(fn + e, M - 1)`, position `32·fm`. -/
def xoff (M e i : Nat) : Nat := 640 * min (fn i + e) (M - 1) + 4 * fm i

/-- After the declarations that follow the barrier. -/
structure Fix2 (kg ku M g s i : Nat) (l : Locals) : Prop where
  fix : Fix1 M s i l
  l18 : l 18 = some (u32 (8 * (4 * g + s)))
  l19 : l 19 = some (u32 (fm i))
  l20 : l 20 = some (u32 (fn i))
  l21 : l 21 = some (u32 (rowOf g s i))
  l22 : l 22 = some (.ptr ⟨2, ((4 * (rowOf g s i * (160 * kg)) : Nat) : Int), .scalar .u32⟩)
  l23 : l 23 = some (.ptr ⟨4, ((4 * (rowOf g s i * (160 * ku)) : Nat) : Int), .scalar .u32⟩)
  l24 : l 24 = some (.ptr ⟨0, ((16 * xoff M 0 i : Nat) : Int), .vec .u32 4⟩)
  l25 : l 25 = some (.ptr ⟨0, ((16 * xoff M 1 i : Nat) : Int), .vec .u32 4⟩)

theorem Fix2.of_eq {kg ku M g s i : Nat} {l l' : Locals} (h : Fix2 kg ku M g s i l) (h' : ∀ j, j ≤ 25 → l' j = l j) :
    Fix2 kg ku M g s i l' :=
  ⟨h.fix.of_eq fun j hj => h' j (by omega), (h' 18 (by omega)).trans h.l18, (h' 19 (by omega)).trans h.l19,
    (h' 20 (by omega)).trans h.l20, (h' 21 (by omega)).trans h.l21, (h' 22 (by omega)).trans h.l22,
    (h' 23 (by omega)).trans h.l23, (h' 24 (by omega)).trans h.l24, (h' 25 (by omega)).trans h.l25⟩

/-- In base step `b`: `base`, `runA`, and the run arrays. -/
structure StepLoc (kg ku M g s i b : Nat) (l : Locals) : Prop where
  fix : Fix2 kg ku M g s i l
  l28 : l 28 = some (u32 (256 * b))
  l29 : l 29 = some (u32 (8 * b + fn i))
  l30 : l 30 = some (.ptr ⟨rb g s i, 0, .scalar .u32⟩)
  l31 : l 31 = some (.ptr ⟨rb g s i + 1, 0, .scalar .u32⟩)
  l32 : l 32 = some (.ptr ⟨rb g s i + 2, 0, .scalar .u32⟩)
  l33 : l 33 = some (.ptr ⟨rb g s i + 3, 0, .scalar .u32⟩)
  l34 : l 34 = some (.ptr ⟨rb g s i + 4, 0, .scalar .u32⟩)
  l35 : l 35 = some (.ptr ⟨rb g s i + 5, 0, .scalar .u32⟩)
  l36 : l 36 = some (.ptr ⟨rb g s i + 6, 0, .scalar .u32⟩)
  l37 : l 37 = some (.ptr ⟨rb g s i + 7, 0, .scalar .u32⟩)

theorem StepLoc.of_eq {kg ku M g s i b : Nat} {l l' : Locals} (h : StepLoc kg ku M g s i b l)
    (h' : ∀ j, j ≤ 37 → (j < 26 ∨ 27 < j) → l' j = l j) : StepLoc kg ku M g s i b l' :=
  ⟨h.fix.of_eq fun j hj => h' j (by omega) (by omega), (h' 28 (by omega) (by omega)).trans h.l28,
    (h' 29 (by omega) (by omega)).trans h.l29, (h' 30 (by omega) (by omega)).trans h.l30,
    (h' 31 (by omega) (by omega)).trans h.l31, (h' 32 (by omega) (by omega)).trans h.l32,
    (h' 33 (by omega) (by omega)).trans h.l33, (h' 34 (by omega) (by omega)).trans h.l34,
    (h' 35 (by omega) (by omega)).trans h.l35, (h' 36 (by omega) (by omega)).trans h.l36,
    (h' 37 (by omega) (by omega)).trans h.l37⟩

/-- In chunk `s8` of base step `b`: also `xa`, `xb`. -/
structure ChunkLoc (kg ku M : Nat) (I : In) (g s i b s8 : Nat) (l : Locals) : Prop where
  step : StepLoc kg ku M g s i b l
  l90 : l 90 = some (u32 s8)
  l91 : l 91 = some (vec4 (cells I.X (16 * (xoff M 0 i + 32 * b + s8)) 16))
  l92 : l 92 = some (vec4 (cells I.X (16 * (xoff M 1 i + 32 * b + s8)) 16))

theorem ChunkLoc.of_eq {kg ku M : Nat} {I : In} {g s i b s8 : Nat} {l l' : Locals} (h : ChunkLoc kg ku M I g s i b s8 l)
    (h' : ∀ j, j ≤ 92 → (j < 26 ∨ 27 < j) → l' j = l j) : ChunkLoc kg ku M I g s i b s8 l' :=
  ⟨h.step.of_eq fun j hj h2 => h' j (by omega) h2, (h' 90 (by omega) (by omega)).trans h.l90,
    (h' 91 (by omega) (by omega)).trans h.l91, (h' 92 (by omega) (by omega)).trans h.l92⟩

/-- At step `t` (base step `t / 32`, chunk `t % 32 / 8`, position `t % 8`). -/
structure PosLoc (kg ku M : Nat) (I : In) (g s i t : Nat) (l : Locals) : Prop where
  chunk : ChunkLoc kg ku M I g s i (t / 32) (t % 32 / 8) l
  l93 : l 93 = some (u32 (t % 8))

theorem PosLoc.of_eq {kg ku M : Nat} {I : In} {g s i t : Nat} {l l' : Locals} (h : PosLoc kg ku M I g s i t l)
    (h' : ∀ j, j ≤ 93 → (j < 26 ∨ 27 < j) → l' j = l j) : PosLoc kg ku M I g s i t l' :=
  ⟨h.chunk.of_eq fun j hj h2 => h' j (by omega) h2, (h' 93 (by omega) (by omega)).trans h.l93⟩

/-- A lane's two accumulator elements. -/
def accVal (D : Fin 32 → Fin 2 → Float32) (i : Fin 32) : Val := .vec .f32 [.f32 (D i 0), .f32 (D i 1)]

section Accs
variable (C : M1Max.Contract)

/-- `accG` after `nG` steps and `accU` after `nU`. -/
structure Accs (kg ku M : Nat) (I : In) (g s : Nat) (i : Fin 32) (nG nU : Nat) (l : Locals) : Prop where
  gate : l 26 = some (accVal (acc C kg I.Gc I.X M (4 * g + s) nG) i)
  up : l 27 = some (accVal (acc C ku I.Uc I.X M (4 * g + s) nU) i)

/-- Lane `i`'s `simdgroup_multiply_accumulate` operands at step `t` for the codes `Codes` of width `K`, with the
accumulator after `n` steps. -/
def mmaVal (K M : Nat) (Codes X : ByteMemory.Bytes) (T : Nat) (i : Fin 32) (t : Nat) : Val :=
  mmaArg .f16 .f32 (.f16 (aReg C K Codes T t i 0), .f16 (aReg C K Codes T t i 1))
    (.f32 (bReg C X M t i 0), .f32 (bReg C X M t i 1))
    (.f32 (acc C K Codes X M T t i 0), .f32 (acc C K Codes X M T t i 1))

end Accs

/-! ### Thread memory -/

/-- Lane `i`'s four runs at base step `b` in its thread arrays 0 … 7. -/
structure LaneArr (kg ku : Nat) (I : In) (g s i b : Nat) (B : Nat → ByteMemory.Bytes) : Prop where
  ga : RunW kg I.Gc (rowOf g s i) (8 * b + fn i) (B (rb g s i)) (B (rb g s i + 1))
  gb : RunW kg I.Gc (rowOf g s i) (8 * b + fn i + 1) (B (rb g s i + 2)) (B (rb g s i + 3))
  ua : RunW ku I.Uc (rowOf g s i) (8 * b + fn i) (B (rb g s i + 4)) (B (rb g s i + 5))
  ub : RunW ku I.Uc (rowOf g s i) (8 * b + fn i + 1) (B (rb g s i + 6)) (B (rb g s i + 7))

/-- Lane `i`'s `aU` and `b` elements at step `t` in its thread arrays 9 and 10. -/
structure LaneAB (C : M1Max.Contract) (ku M : Nat) (I : In) (g s : Nat) (i : Fin 32) (t : Nat)
    (B : Nat → ByteMemory.Bytes) : Prop where
  u0 : cells (B (rb g s i + 9)) 0 2 = wordBytes 2 (Val.f16Bits (aReg C ku I.Uc (4 * g + s) t i 0))
  u1 : cells (B (rb g s i + 9)) 2 2 = wordBytes 2 (Val.f16Bits (aReg C ku I.Uc (4 * g + s) t i 1))
  b0 : cells (B (rb g s i + 10)) 0 4 = wordBytes 4 (Val.f32Bits (bReg C I.X M t i 0))
  b1 : cells (B (rb g s i + 10)) 4 4 = wordBytes 4 (Val.f32Bits (bReg C I.X M t i 1))

/-- `sh'` keeps every thread region of the threads other than `th`. -/
def Keeps (th : Nat) (sh sh' : Shared) : Prop := ∀ reg, 8 ≤ reg → (reg - 8) / 11 ≠ th → sh'.bytes reg = sh.bytes reg

theorem Keeps.trans {th : Nat} {sh₁ sh₂ sh₃ : Shared} (h₁ : Keeps th sh₁ sh₂) (h₂ : Keeps th sh₂ sh₃) :
    Keeps th sh₁ sh₃ := fun reg h8 hne => (h₂ reg h8 hne).trans (h₁ reg h8 hne)

theorem rb_thr (g s i j : Nat) (hj : j < 11) : (rb g s i + j - 8) / 11 = thr g s i := by unfold rb; omega

theorem LaneArr.frame {kg ku : Nat} {I : In} {g s i b : Nat} {sh sh' : Shared} (h : LaneArr kg ku I g s i b sh.bytes)
    {th : Nat} (hf : Keeps th sh sh') (hth : thr g s i ≠ th) : LaneArr kg ku I g s i b sh'.bytes := by
  have e : ∀ j, j < 11 → sh'.bytes (rb g s i + j) = sh.bytes (rb g s i + j) := fun j hj =>
    hf _ (by unfold rb; omega) (by rw [rb_thr g s i j hj]; exact hth)
  have e0 := e 0 (by omega)
  rw [Nat.add_zero] at e0
  exact ⟨by rw [e0, e 1 (by omega)]; exact h.ga, by rw [e 2 (by omega), e 3 (by omega)]; exact h.gb,
    by rw [e 4 (by omega), e 5 (by omega)]; exact h.ua, by rw [e 6 (by omega), e 7 (by omega)]; exact h.ub⟩

theorem LaneAB.frame {C : M1Max.Contract} {ku M : Nat} {I : In} {g s : Nat} {i : Fin 32} {t : Nat} {sh sh' : Shared}
    (h : LaneAB C ku M I g s i t sh.bytes) {th : Nat} (hf : Keeps th sh sh') (hth : thr g s i ≠ th) :
    LaneAB C ku M I g s i t sh'.bytes := by
  have e : ∀ j, j < 11 → sh'.bytes (rb g s i + j) = sh.bytes (rb g s i + j) := fun j hj =>
    hf _ (by unfold rb; omega) (by rw [rb_thr g s i j hj]; exact hth)
  exact ⟨by rw [e 9 (by omega)]; exact h.u0, by rw [e 9 (by omega)]; exact h.u1, by rw [e 10 (by omega)]; exact h.b0,
    by rw [e 10 (by omega)]; exact h.b1⟩

/-! ### The position body -/

/-- The position body before the gate collective, the collective, and what follows it. -/
def posPre (kg ku : Nat) : List CStmt :=
  [.set 94 (cu .add (cu .mul (.local 90) (cl 8)) (.local 93)), .array 95 false 8 (.vec .f16 2),
    .array 96 false 9 (.vec .f16 2)] ++
  (GateUpCodebookMma.state kg 97 (.local 30) (.local 31) (.local 94) ++ [GateUpCodebookMma.aElem 95 0 100]) ++
  (GateUpCodebookMma.state kg 104 (.local 32) (.local 33) (.local 94) ++ [GateUpCodebookMma.aElem 95 1 107]) ++
  (GateUpCodebookMma.state ku 111 (.local 34) (.local 35) (.local 94) ++ [GateUpCodebookMma.aElem 96 0 114]) ++
  (GateUpCodebookMma.state ku 118 (.local 36) (.local 37) (.local 94) ++ [GateUpCodebookMma.aElem 96 1 121]) ++
  [.array 125 false 10 (.vec .f32 2),
   .store (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (.local 125)) (ci 0)) (GateUpCodebookMma.bValue 91),
   .store (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (.local 125)) (ci 1)) (GateUpCodebookMma.bValue 92)]

def collG : CStmt :=
  .collective 2 126 (.mma .f16 .f32) .f32
    (.vector .f32 [.load (.vec .f16 2) (.local 95), .load (.vec .f32 2) (.local 125), .local 26]) (GateUpCodebookMma.u16l 0)
def collU : CStmt :=
  .collective 3 127 (.mma .f16 .f32) .f32
    (.vector .f32 [.load (.vec .f16 2) (.local 96), .load (.vec .f32 2) (.local 125), .local 27]) (GateUpCodebookMma.u16l 0)
def posRestG : List CStmt := [.set 26 (.local 126), collU, .set 27 (.local 127)]

theorem positionBody_eq (kg ku : Nat) : GateUpCodebookMma.positionBody kg ku = posPre kg ku ++ collG :: posRestG := rfl

theorem aReg_eq (C : M1Max.Contract) (K : Nat) (Codes : ByteMemory.Bytes) (g s : Nat) (i : Fin 32) (e : Fin 2) (t : Nat) :
    aReg C K Codes (4 * g + s) t i e = cbEntry C (trellisCode K Codes (GateUp.gbase K (rowOf g s i) (8 * (t / 32) + fn i + e))
      ((8 * (t / 32) + fn i + e) % 8 * 32 + t % 32)) := by
  have hf := fn_lt i.isLt
  have he := e.isLt
  have ht := Nat.mod_lt t (show 0 < 32 by decide)
  have h1 : (256 * (t / 32) + 32 * (fn i + e) + t % 32) / 256 = (8 * (t / 32) + fn i + e) / 8 := by omega
  have h2 : (256 * (t / 32) + 32 * (fn i + e) + t % 32) % 256 = (8 * (t / 32) + fn i + e) % 8 * 32 + t % 32 := by
    omega
  unfold aReg weightA GateUp.gbase rowOf
  rw [h1, h2]

theorem bReg_eq (C : M1Max.Contract) (X : ByteMemory.Bytes) (M : Nat) (i : Fin 32) (e : Fin 2) (t : Nat) :
    bReg C X M t i e = C.widen (Val.ofBf16Bits (half X (8 * (xoff M e i + 32 * (t / 32) + t % 32 / 8) + t % 8))) := by
  have := Nat.mod_lt t (show 0 < 32 by decide)
  unfold bReg xB xoff
  generalize min (fn i + e) (M - 1) = mn
  rw [show 5120 * mn + (256 * (t / 32) + 32 * fm i + t % 32) =
      8 * (640 * mn + 4 * fm i + 32 * (t / 32) + t % 32 / 8) + t % 8 by omega]

section Pos
variable (C : M1Max.Contract) {L : Launch} {kg ku M : Nat} {I : In} {out : Nat → Nat → BF} {P g s : Nat} {ctx : Ctx}

/-- One `codebook_mma_state` and its `codebook` element, for a run in arrays `rw`, `rv`, into `half2` array `ra`. -/
theorem exec_stateElem (hS : Shape L kg ku M I) (hgrp : ctx.group = g) (K b m e sw sv : Nat) (hb : 94 < b)
    (hsv : sv < b) (hmb : m < b) (he : e < 2) (hK : GateUp.Width K) {Codes : ByteMemory.Bytes}
    {row run : Nat} {l : Locals} {sh : Shared} {rw rv ra : Nat} {j : Nat} (hj : j < 32) (hra8 : 8 ≤ ra)
    (hlw : l sw = some (.ptr ⟨rw, 0, .scalar .u32⟩)) (hlv : l sv = some (.ptr ⟨rv, 0, .scalar .u32⟩))
    (h94 : l 94 = some (u32 j)) (hlm : l m = some (.ptr ⟨ra, 0, .vec .f16 2⟩))
    (h10 : l 10 = some (.ptr ⟨7, 0, .scalar .f16⟩))
    (hrw : sh.regions rw = some ⟨.thread, 4 * (K + 1), 4⟩) (hrv : sh.regions rv = some ⟨.thread, 4 * (K + 1), 4⟩)
    (hra : sh.regions ra = some ⟨.thread, 4, 4⟩) (hm : Mem C L I M out P (g + 1) (fun _ => True) sh)
    (hR : RunW K Codes row run (sh.bytes rw) (sh.bytes rv)) :
    ∃ l' sh', Exec C ctx (GateUpCodebookMma.state K b (.local sw) (.local sv) (.local 94) ++
        [GateUpCodebookMma.aElem m e (b + 3)]) l sh .normal l' sh' ∧ (∀ x, x < b → l' x = l x) ∧
      Mem C L I M out P (g + 1) (fun _ => True) sh' ∧ (∀ r, r ≠ ra → sh'.bytes r = sh.bytes r) ∧
      sh'.bytes ra = writeBytes (sh.bytes ra) (2 * e)
        (wordBytes 2 (Val.f16Bits (cbEntry C (trellisCode K Codes (GateUp.gbase K row run) (run % 8 * 32 + j))))) := by
  have hWl : ∀ i, GateUp.runWord K Codes row run i < 2 ^ 32 := fun i => GateUp.runWord_lt _ _ _ _ _
  have hW : ∀ i ≤ K, (loadAt ctx (.scalar .u32) ⟨rw, ((4 * i : Nat) : Int), .scalar .u32⟩).run sh =
      some (u32 (GateUp.runWord K Codes row run i), sh) :=
    fun i hi => GateUp.Words.load hrw hR.w (by omega) i (by omega)
  have hV : ∀ i, 1 ≤ i → i ≤ K → (loadAt ctx (.scalar .u32) ⟨rv, ((4 * i : Nat) : Int), .scalar .u32⟩).run sh =
      some (u32 (GateUp.virt (GateUp.runWord K Codes row run) (K + 1) i), sh) := by
    intro i h1 h2
    rw [load_thread ctx .u32 sh rv (4 * i) _ 4 hrv (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega)]
    simp only [Scalar.bytes]
    rw [hR.v i h1 h2, ofWord_u32]
  obtain ⟨l₁, x1, h3, hag⟩ := exec_state C (ctx := ctx) K b hsv (by omega) hK hj hlw hlv h94 hW hV hWl
  rw [GateUp.code_run hK Codes row run j hj] at h3
  generalize hst' : trellisCode K Codes (GateUp.gbase K row run) (run % 8 * 32 + j) = st at h3 ⊢
  have hst : st < 4096 := by
    rw [← hst']; exact Nat.mod_lt _ (by decide)
  have x2 := exec_aElem C (ctx := ctx) m e (b + 3) (l := l₁) (sh := sh) (ra := ra) (st := st) (x := cbEntry C st) he
    (by rw [hag m hmb]; exact hlm) (by rw [hag 10 (by omega)]; exact h10) h3 hst hra
    (by rw [hm.regions]; exact hS.r7) (hm.cb _ hst trivial)
  refine ⟨l₁, _, x1.append x2, hag, (hm.rd ctx 7 _ 2 (.inr ⟨rfl, by rw [hgrp]; omega⟩) hS).tput _ _ hra8,
    fun r hr => by rw [tput_other _ _ _ hr, rdn_bytes], by rw [tput_same, rdn_bytes]⟩

end Pos

section Pos
variable (C : M1Max.Contract) {L : Launch} {kg ku M : Nat} {I : In} {out : Nat → Nat → BF} {P g s : Nat} {ctx : Ctx}

/-- **A position, to the gate collective.** `j`, the four A elements, the two B elements, then
`simdgroup_multiply_accumulate(accG, aG, b, accG)` with the lane's operands at step `t`. -/
theorem exec_pos (hS : Shape L kg ku M I) {i : Fin 32} (hl : Lane ctx g s i) (hKg : GateUp.Width kg)
    (hKu : GateUp.Width ku) {t : Nat} (ht : t < 640) {l : Locals} {sh : Shared}
    (hP : PosLoc kg ku M I g s i t l) (hacc : Accs C kg ku M I g s i t t l)
    (hm : Mem C L I M out P (g + 1) (fun _ => True) sh) (harr : LaneArr kg ku I g s i (t / 32) sh.bytes) :
    ∃ l' sh', Exec C ctx (GateUpCodebookMma.positionBody kg ku) l sh
        (.stop (.collective 2 126 (.mma .f16 .f32) .f32 (mmaVal C kg M I.Gc I.X (4 * g + s) i t) 0) [.block posRestG])
        l' sh' ∧
      Mem C L I M out P (g + 1) (fun _ => True) sh' ∧ LaneArr kg ku I g s i (t / 32) sh'.bytes ∧
      LaneAB C ku M I g s i t sh'.bytes ∧ Keeps (thr g s i) sh sh' ∧
      (∀ j, j ≤ 93 → l' j = l j) ∧ l' 96 = some (.ptr ⟨rb g s i + 9, 0, .vec .f16 2⟩) ∧
      l' 125 = some (.ptr ⟨rb g s i + 10, 0, .vec .f32 2⟩) := by
  have hi := i.isLt
  have hgrp := hl.group
  obtain ⟨⟨⟨hF, h28, h29, h30, h31, h32, h33, h34, h35, h36, h37⟩, h90, h91, h92⟩, h93⟩ := hP
  have hta : ∀ j, ctx.threadArray j = rb g s i + j := fun j => by rw [hl.ta]; rfl
  have hreg := hm.regions
  have rA : L.regions (rb g s i + 8) = some ⟨.thread, 4, 4⟩ := hS.ra _ 8 (by omega) (by omega)
  have rU : L.regions (rb g s i + 9) = some ⟨.thread, 4, 4⟩ := hS.ra _ 9 (by omega) (by omega)
  have rB : L.regions (rb g s i + 10) = some ⟨.thread, 8, 8⟩ := hS.rb _
  have rG : ∀ j, j < 4 → L.regions (rb g s i + j) = some ⟨.thread, 4 * (kg + 1), 4⟩ := fun j hj => hS.rg _ j hj
  have rUw : ∀ j, 4 ≤ j → j < 8 → L.regions (rb g s i + j) = some ⟨.thread, 4 * (ku + 1), 4⟩ :=
    fun j h1 h2 => hS.ru _ j h1 h2
  -- `j`, `aG`, `aU`
  have e94 : (eval C ctx l (cu .add (cu .mul (.local 90) (cl 8)) (.local 93))).run sh = some (u32 (t % 32), sh) := by
    rw [show t % 32 = t % 32 / 8 * 8 + t % 8 by omega]
    exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C h90 sh) (eval_u32lit C _ _ 8 (by decide))
      (binary_mul_u32 C _ 8)) (eval_local' C h93 sh) (binary_add_u32 C _ _)
  generalize hl₀ : setLocal (setLocal (setLocal l 94 (u32 (t % 32))) 95 (.ptr ⟨rb g s i + 8, 0, .vec .f16 2⟩)) 96
    (.ptr ⟨rb g s i + 9, 0, .vec .f16 2⟩) = l₀
  have x0 : Exec C ctx [.set 94 (cu .add (cu .mul (.local 90) (cl 8)) (.local 93)), .array 95 false 8 (.vec .f16 2),
      .array 96 false 9 (.vec .f16 2)] l sh .normal l₀ sh := by
    rw [← hl₀]; exact .set e94 (exec_tarray C (hta 8) (exec_tarray C (hta 9) (.nil _ _)))
  have h0b : ∀ x, x < 94 → l₀ x = l x := fun x hx => by
    rw [← hl₀, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
  have h094 : l₀ 94 = some (u32 (t % 32)) := by
    rw [← hl₀, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_same]
  have h095 : l₀ 95 = some (.ptr ⟨rb g s i + 8, 0, .vec .f16 2⟩) := by
    rw [← hl₀, setLocal_other _ _ (by omega), setLocal_same]
  have h096 : l₀ 96 = some (.ptr ⟨rb g s i + 9, 0, .vec .f16 2⟩) := by rw [← hl₀, setLocal_same]
  have hj : t % 32 < 32 := Nat.mod_lt _ (by decide)
  have hb32 : t / 32 < 20 := by omega
  have hrow : rowOf g s i < 17408 := by have := hl.hg; have := hl.hs; have := fm_lt hi; unfold rowOf; omega
  have hfn := fn_lt hi
  -- gate element 0
  obtain ⟨l₁, sh₁, x1, hl₁, hm₁, hb₁, hA₁⟩ := exec_stateElem C hS hgrp kg 97 95 0 30 31 (by omega) (by omega)
    (by omega) (by omega) hKg (Codes := I.Gc) (row := rowOf g s i) (run := 8 * (t / 32) + fn i + ((0 : Fin 2) : Nat))
    (l := l₀) (sh := sh) (rw := rb g s i) (rv := rb g s i + 1) (ra := rb g s i + 8) hj (by unfold rb; omega)
    (by rw [h0b 30 (by omega)]; exact h30) (by rw [h0b 31 (by omega)]; exact h31) h094 h095
    (by rw [h0b 10 (by omega)]; exact hF.fix.l10) (by rw [hreg]; exact rG 0 (by omega))
    (by rw [hreg]; exact rG 1 (by omega)) (by rw [hreg]; exact rA) hm harr.ga
  rw [← aReg_eq] at hA₁
  -- gate element 1
  obtain ⟨l₂, sh₂, x2, hl₂, hm₂, hb₂, hA₂⟩ := exec_stateElem C hS hgrp kg 104 95 1 32 33 (by omega)
    (by omega) (by omega) (by omega) hKg (Codes := I.Gc) (row := rowOf g s i) (run := 8 * (t / 32) + fn i + ((1 : Fin 2) : Nat))
    (l := l₁) (sh := sh₁) (rw := rb g s i + 2) (rv := rb g s i + 3) (ra := rb g s i + 8) hj (by unfold rb; omega)
    (by rw [hl₁ 32 (by omega), h0b 32 (by omega)]; exact h32) (by rw [hl₁ 33 (by omega), h0b 33 (by omega)]; exact h33)
    (by rw [hl₁ 94 (by omega)]; exact h094) (by rw [hl₁ 95 (by omega)]; exact h095)
    (by rw [hl₁ 10 (by omega), h0b 10 (by omega)]; exact hF.fix.l10) (by rw [hm₁.regions]; exact rG 2 (by omega))
    (by rw [hm₁.regions]; exact rG 3 (by omega)) (by rw [hm₁.regions]; exact rA) hm₁
    (by rw [hb₁ _ (by omega), hb₁ _ (by omega)]; exact harr.gb)
  rw [← aReg_eq] at hA₂
  -- up element 0
  obtain ⟨l₃, sh₃, x3, hl₃, hm₃, hb₃, hA₃⟩ := exec_stateElem C hS hgrp ku 111 96 0 34 35 (by omega)
    (by omega) (by omega) (by omega) hKu (Codes := I.Uc) (row := rowOf g s i) (run := 8 * (t / 32) + fn i + ((0 : Fin 2) : Nat))
    (l := l₂) (sh := sh₂) (rw := rb g s i + 4) (rv := rb g s i + 5) (ra := rb g s i + 9) hj (by unfold rb; omega)
    (by rw [hl₂ 34 (by omega), hl₁ 34 (by omega), h0b 34 (by omega)]; exact h34)
    (by rw [hl₂ 35 (by omega), hl₁ 35 (by omega), h0b 35 (by omega)]; exact h35)
    (by rw [hl₂ 94 (by omega), hl₁ 94 (by omega)]; exact h094) (by rw [hl₂ 96 (by omega), hl₁ 96 (by omega)]; exact h096)
    (by rw [hl₂ 10 (by omega), hl₁ 10 (by omega), h0b 10 (by omega)]; exact hF.fix.l10)
    (by rw [hm₂.regions]; exact rUw 4 (by omega) (by omega)) (by rw [hm₂.regions]; exact rUw 5 (by omega) (by omega))
    (by rw [hm₂.regions]; exact rU) hm₂
    (by rw [hb₂ _ (by omega), hb₁ _ (by omega), hb₂ _ (by omega), hb₁ _ (by omega)]; exact harr.ua)
  rw [← aReg_eq] at hA₃
  -- up element 1
  obtain ⟨l₄, sh₄, x4, hl₄, hm₄, hb₄, hA₄⟩ := exec_stateElem C hS hgrp ku 118 96 1 36 37 (by omega)
    (by omega) (by omega) (by omega) hKu (Codes := I.Uc) (row := rowOf g s i) (run := 8 * (t / 32) + fn i + ((1 : Fin 2) : Nat))
    (l := l₃) (sh := sh₃) (rw := rb g s i + 6) (rv := rb g s i + 7) (ra := rb g s i + 9) hj (by unfold rb; omega)
    (by rw [hl₃ 36 (by omega), hl₂ 36 (by omega), hl₁ 36 (by omega), h0b 36 (by omega)]; exact h36)
    (by rw [hl₃ 37 (by omega), hl₂ 37 (by omega), hl₁ 37 (by omega), h0b 37 (by omega)]; exact h37)
    (by rw [hl₃ 94 (by omega), hl₂ 94 (by omega), hl₁ 94 (by omega)]; exact h094)
    (by rw [hl₃ 96 (by omega), hl₂ 96 (by omega), hl₁ 96 (by omega)]; exact h096)
    (by rw [hl₃ 10 (by omega), hl₂ 10 (by omega), hl₁ 10 (by omega), h0b 10 (by omega)]; exact hF.fix.l10)
    (by rw [hm₃.regions]; exact rUw 6 (by omega) (by omega)) (by rw [hm₃.regions]; exact rUw 7 (by omega) (by omega))
    (by rw [hm₃.regions]; exact rU) hm₃
    (by rw [hb₃ _ (by omega), hb₂ _ (by omega), hb₁ _ (by omega), hb₃ _ (by omega), hb₂ _ (by omega),
      hb₁ _ (by omega)]; exact harr.ub)
  rw [← aReg_eq] at hA₄
  have h4b : ∀ x, x < 97 → l₄ x = l₀ x := fun x hx => by
    rw [hl₄ x (by omega), hl₃ x (by omega), hl₂ x (by omega), hl₁ x hx]
  -- `b`
  generalize hl₅ : setLocal l₄ 125 (.ptr ⟨rb g s i + 10, 0, .vec .f32 2⟩) = l₅
  have h5b : ∀ x, x < 97 → l₅ x = l₀ x := fun x hx => by rw [← hl₅, setLocal_other _ _ (by omega), h4b x hx]
  have h5125 : l₅ 125 = some (.ptr ⟨rb g s i + 10, 0, .vec .f32 2⟩) := by rw [← hl₅, setLocal_same]
  have hpb : ∀ (e : Nat) (shx : Shared), e < 2 → (eval C ctx l₅ (.offset (.ptrCast (.scalar .f32) (.local 125)) (ci e))).run shx =
      some (.ptr ⟨rb g s i + 10, ((4 * e : Nat) : Int), .scalar .f32⟩, shx) := fun e shx he => by
    have := eval_offset_i32 C (ctx := ctx) (o := 0) (n := e) (eval_ptrCast C (t := .scalar .f32) (eval_local' C h5125 shx))
      (eval_lit C _ _ _ _) (by omega)
    rwa [show 0 + e * (Ty.scalar .f32).bytes = 4 * e by simp only [Ty.bytes, Scalar.bytes]; omega] at this
  have hv0 := eval_bValue C (ctx := ctx) 91 (l := l₅) (sh := sh₄) (X := I.X)
    (c4 := xoff M ((0 : Fin 2) : Nat) i + 32 * (t / 32) + t % 32 / 8) (q := t % 8)
    (by rw [h5b 91 (by omega), h0b 91 (by omega)]; exact h91) (by rw [h5b 93 (by omega), h0b 93 (by omega)]; exact h93)
    (Nat.mod_lt _ (by decide))
  have hv1 := eval_bValue C (ctx := ctx) 92 (l := l₅) (sh := tput sh₄ (rb g s i + 10) (4 * 0) (wordBytes 4 (Val.f32Bits (bReg C I.X M t i 0)))) (X := I.X)
    (c4 := xoff M ((1 : Fin 2) : Nat) i + 32 * (t / 32) + t % 32 / 8) (q := t % 8)
    (by rw [h5b 92 (by omega), h0b 92 (by omega)]; exact h92) (by rw [h5b 93 (by omega), h0b 93 (by omega)]; exact h93)
    (Nat.mod_lt _ (by decide))
  rw [← bReg_eq C I.X M i 0 t] at hv0
  rw [← bReg_eq C I.X M i 1 t] at hv1
  have hst0 := store_thread ctx .f32 sh₄ (rb g s i + 10) (4 * 0) 8 8 (.f32 (bReg C I.X M t i 0))
    (wordBytes 4 (Val.f32Bits (bReg C I.X M t i 0))) (by rw [hm₄.regions]; exact rB) (by decide)
    (by simp [Scalar.bytes]) (by simp [Scalar.bytes]) (encode_f32 _)
  have hst1 := store_thread ctx .f32 (tput sh₄ (rb g s i + 10) (4 * 0) (wordBytes 4 (Val.f32Bits (bReg C I.X M t i 0))))
    (rb g s i + 10) (4 * 1) 8 8 (.f32 (bReg C I.X M t i 1))
    (wordBytes 4 (Val.f32Bits (bReg C I.X M t i 1))) (by rw [tput_regions, hm₄.regions]; exact rB) (by decide)
    (by simp [Scalar.bytes]) (by simp [Scalar.bytes]) (encode_f32 _)
  generalize hsh₆ : tput (tput sh₄ (rb g s i + 10) (4 * 0) (wordBytes 4 (Val.f32Bits (bReg C I.X M t i 0))))
    (rb g s i + 10) (4 * 1) (wordBytes 4 (Val.f32Bits (bReg C I.X M t i 1))) = sh₆ at hst1
  have x5 : Exec C ctx [.array 125 false 10 (.vec .f32 2),
      .store (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (.local 125)) (ci 0)) (GateUpCodebookMma.bValue 91),
      .store (.scalar .f32) (.offset (.ptrCast (.scalar .f32) (.local 125)) (ci 1)) (GateUpCodebookMma.bValue 92)]
      l₄ sh₄ .normal l₅ sh₆ := by
    rw [← hl₅]
    exact exec_tarray C (hta 10) (.store (by rw [hl₅]; exact hpb 0 _ (by omega)) (by rw [hl₅]; exact hv0) hst0
      (.store (by rw [hl₅]; exact hpb 1 _ (by omega)) (by rw [hl₅]; exact hv1) hst1 (.nil _ _)))
  -- the memory
  have hm₆ : Mem C L I M out P (g + 1) (fun _ => True) sh₆ := by
    rw [← hsh₆]; exact (hm₄.tput _ _ (by unfold rb; omega)).tput _ _ (by unfold rb; omega)
  have hB6 : ∀ r, r ≠ rb g s i + 10 → sh₆.bytes r = sh₄.bytes r := fun r hr => by
    rw [← hsh₆, tput_other _ _ _ hr, tput_other _ _ _ hr]
  have hB6s : sh₆.bytes (rb g s i + 10) = writeBytes (writeBytes (sh₄.bytes (rb g s i + 10)) (4 * 0)
      (wordBytes 4 (Val.f32Bits (bReg C I.X M t i 0)))) (4 * 1) (wordBytes 4 (Val.f32Bits (bReg C I.X M t i 1))) := by
    rw [← hsh₆, tput_same, tput_same]
  have hrest : ∀ r, r ≠ rb g s i + 8 → r ≠ rb g s i + 9 → r ≠ rb g s i + 10 → sh₆.bytes r = sh.bytes r :=
    fun r h8 h9 h10 => by rw [hB6 r h10, hb₄ r h9, hb₃ r h9, hb₂ r h8, hb₁ r h8]
  have hAG : sh₆.bytes (rb g s i + 8) = writeBytes (writeBytes (sh.bytes (rb g s i + 8)) (2 * 0)
      (wordBytes 2 (Val.f16Bits (aReg C kg I.Gc (4 * g + s) t i 0)))) (2 * 1)
      (wordBytes 2 (Val.f16Bits (aReg C kg I.Gc (4 * g + s) t i 1))) := by
    rw [hB6 _ (by omega), hb₄ _ (by omega), hb₃ _ (by omega), hA₂, hA₁]
  have hAU : sh₆.bytes (rb g s i + 9) = writeBytes (writeBytes (sh₂.bytes (rb g s i + 9)) (2 * 0)
      (wordBytes 2 (Val.f16Bits (aReg C ku I.Uc (4 * g + s) t i 0)))) (2 * 1)
      (wordBytes 2 (Val.f16Bits (aReg C ku I.Uc (4 * g + s) t i 1))) := by
    rw [hB6 _ (by omega), hA₄, hA₃]
  have wl2 : ∀ x : Float16.Value, (wordBytes 2 (Val.f16Bits x)).length = 2 := fun x => wordBytes_length 2 _
  have wl4 : ∀ x : Float32, (wordBytes 4 (Val.f32Bits x)).length = 4 := fun x => wordBytes_length 4 _
  have cA0 : cells (sh₆.bytes (rb g s i + 8)) 0 2 = wordBytes 2 (Val.f16Bits (aReg C kg I.Gc (4 * g + s) t i 0)) := by
    rw [hAG, cells_writeBytes_other _ _ _ _ _ (.inl (by omega)), cells_writeBytes_of_length _ _ _ _ (wl2 _)]
  have cA1 : cells (sh₆.bytes (rb g s i + 8)) 2 2 = wordBytes 2 (Val.f16Bits (aReg C kg I.Gc (4 * g + s) t i 1)) := by
    rw [hAG, cells_writeBytes_of_length _ _ _ _ (wl2 _)]
  have cU0 : cells (sh₆.bytes (rb g s i + 9)) 0 2 = wordBytes 2 (Val.f16Bits (aReg C ku I.Uc (4 * g + s) t i 0)) := by
    rw [hAU, cells_writeBytes_other _ _ _ _ _ (.inl (by omega)), cells_writeBytes_of_length _ _ _ _ (wl2 _)]
  have cU1 : cells (sh₆.bytes (rb g s i + 9)) 2 2 = wordBytes 2 (Val.f16Bits (aReg C ku I.Uc (4 * g + s) t i 1)) := by
    rw [hAU, cells_writeBytes_of_length _ _ _ _ (wl2 _)]
  have cB0 : cells (sh₆.bytes (rb g s i + 10)) 0 4 = wordBytes 4 (Val.f32Bits (bReg C I.X M t i 0)) := by
    rw [hB6s, cells_writeBytes_other _ _ _ _ _ (.inl (by omega)), cells_writeBytes_of_length _ _ _ _ (wl4 _)]
  have cB1 : cells (sh₆.bytes (rb g s i + 10)) 4 4 = wordBytes 4 (Val.f32Bits (bReg C I.X M t i 1)) := by
    rw [hB6s, cells_writeBytes_of_length _ _ _ _ (wl4 _)]
  -- the collective
  have hcoll : (eval C ctx l₅ (.vector .f32 [.load (.vec .f16 2) (.local 95), .load (.vec .f32 2) (.local 125),
      .local 26])).run sh₆ = some (mmaVal C kg M I.Gc I.X (4 * g + s) i t, sh₆) := by
    have h595 : l₅ 95 = some (.ptr ⟨rb g s i + 8, 0, .vec .f16 2⟩) := by rw [h5b 95 (by omega)]; exact h095
    have h526 : l₅ 26 = some (accVal (acc C kg I.Gc I.X M (4 * g + s) t) i) := by
      rw [h5b 26 (by omega), h0b 26 (by omega)]; exact hacc.gate
    have hA := (eval_load C _ _ _ _ _ _ _ (eval_local' C h595 sh₆)).trans
      (load_vec_f16 ctx sh₆ _ (by rw [hm₆.regions]; exact rA) _ _ cA0 cA1)
    have hB := (eval_load C _ _ _ _ _ _ _ (eval_local' C h5125 sh₆)).trans
      (load_vec_f32 ctx sh₆ _ (by rw [hm₆.regions]; exact rB) _ _ cB0 cB1)
    have hc := eval_local' C (ctx := ctx) h526 sh₆
    exact eval_vector C (evalList_cons C hA (evalList_cons C hB (evalList_cons C hc (evalList_nil C))))
  have h596 : l₅ 96 = some (.ptr ⟨rb g s i + 9, 0, .vec .f16 2⟩) := by
    rw [← hl₅, setLocal_other _ _ (by omega), hl₄ _ (by omega), hl₃ _ (by omega), hl₂ _ (by omega), hl₁ _ (by omega)]
    exact h096
  refine ⟨l₅, sh₆, ?_, hm₆, ⟨?_, ?_, ?_, ?_⟩, ⟨cU0, cU1, cB0, cB1⟩, fun r h8 hne => ?_, fun x hx => ?_, h596, h5125⟩
  · rw [positionBody_eq]
    have xpre : Exec C ctx (posPre kg ku) l sh .normal l₅ sh₆ :=
      x0.append (((x1.append x2).append x3).append x4 |>.append x5)
    exact xpre.append (.collective hcoll (eval_lit C _ _ _ _) (natOf_unsigned 0 rfl))
  · rw [hrest (rb g s i) (by omega) (by omega) (by omega), hrest (rb g s i + 1) (by omega) (by omega) (by omega)]
    exact harr.ga
  · rw [hrest (rb g s i + 2) (by omega) (by omega) (by omega), hrest (rb g s i + 3) (by omega) (by omega) (by omega)]
    exact harr.gb
  · rw [hrest (rb g s i + 4) (by omega) (by omega) (by omega), hrest (rb g s i + 5) (by omega) (by omega) (by omega)]
    exact harr.ua
  · rw [hrest (rb g s i + 6) (by omega) (by omega) (by omega), hrest (rb g s i + 7) (by omega) (by omega) (by omega)]
    exact harr.ub
  · exact hrest r (fun h => hne (by rw [h]; exact rb_thr g s i 8 (by omega)))
      (fun h => hne (by rw [h]; exact rb_thr g s i 9 (by omega))) (fun h => hne (by rw [h]; exact rb_thr g s i 10 (by omega)))
  · rw [h5b x (by omega), h0b x (by omega)]

end Pos

/-- The frames of the loops a lane is in at a position: the position loop, the chunk loop, the base loop, and the
scope's rest. -/
def qLoopF (kg ku : Nat) : Frame :=
  .loop (GateUpCodebookMma.lt 93 8) (GateUpCodebookMma.incr 93) (GateUpCodebookMma.positionBody kg ku)
def s8LoopF (kg ku : Nat) : Frame :=
  .loop (GateUpCodebookMma.lt 90 4) (GateUpCodebookMma.incr 90) (GateUpCodebookMma.chunkBody kg ku)

theorem xoff_bound {M e i b s8 : Nat} (hM : 1 ≤ M) (hi : i < 32) (hb : b < 20) (hs8 : s8 < 4) :
    16 * (xoff M e i + 32 * b + s8) + 16 ≤ 10240 * M := by
  have hf := fm_lt hi
  have hmn : min (fn i + e) (M - 1) ≤ M - 1 := Nat.min_le_right _ _
  unfold xoff
  generalize min (fn i + e) (M - 1) = mn at hmn
  omega

section Chunk
variable (C : M1Max.Contract) {L : Launch} {kg ku M : Nat} {I : In} {out : Nat → Nat → BF} {P g s : Nat} {ctx : Ctx}

/-- `xa = x0[base / 8u + s8]` (or `xb` from `x1`): 16 bytes of `x` read. -/
theorem eval_xload (hS : Shape L kg ku M I) {i : Fin 32} (hM : 1 ≤ M) (e : Nat) (xs : Nat) {b s8 : Nat} (hb : b < 20)
    (hs8 : s8 < 4) {l : Locals} {sh : Shared} {cbOk : Nat → Prop} {ge : Nat}
    (hx : l xs = some (.ptr ⟨0, ((16 * xoff M e i : Nat) : Int), .vec .u32 4⟩)) (h28 : l 28 = some (u32 (256 * b)))
    (h90 : l 90 = some (u32 s8)) (hm : Mem C L I M out P ge cbOk sh) :
    (eval C ctx l (.load (.vec .u32 4) (.offset (.local xs) (cu .add (cu .div (.local 28) (cl 8)) (.local 90))))).run sh =
      some (vec4 (cells I.X (16 * (xoff M e i + 32 * b + s8)) 16), rdn ctx sh 0 (16 * (xoff M e i + 32 * b + s8)) 16) := by
  have hidx : (eval C ctx l (cu .add (cu .div (.local 28) (cl 8)) (.local 90))).run sh = some (u32 (32 * b + s8), sh) := by
    rw [show 32 * b + s8 = 256 * b / 8 + s8 by omega]
    exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C h28 sh) (eval_u32lit C _ _ 8 (by decide))
      (binary_div_u32 C _ 8 (by omega) (by decide) (by decide))) (eval_local' C h90 sh) (binary_add_u32 C _ _)
  have hp := eval_offset_u32 C (o := 16 * xoff M e i) (eval_local' C hx sh) hidx (by omega)
  rw [show 16 * xoff M e i + (32 * b + s8) * (Ty.vec .u32 4).bytes = 16 * (xoff M e i + 32 * b + s8) by
    rw [show (Ty.vec .u32 4).bytes = 16 from rfl]; omega] at hp
  have hld := load_vec4 ctx sh 0 (16 * (xoff M e i + 32 * b + s8)) _ (by rw [hm.regions]; exact hS.r0) (by simp)
    hS.ax (by omega) (by simpa using xoff_bound hM i.isLt hb hs8)
  rw [hm.x] at hld
  exact (eval_load C _ _ _ _ _ _ _ hp).trans hld

/-- **A chunk, to its first position's gate collective.** -/
theorem exec_chunk (hS : Shape L kg ku M I) {i : Fin 32} (hl : Lane ctx g s i) (hKg : GateUp.Width kg)
    (hKu : GateUp.Width ku) (hM : 1 ≤ M) {b s8 : Nat} (hb : b < 20) (hs8 : s8 < 4) {l : Locals} {sh : Shared}
    (hst : StepLoc kg ku M g s i b l) (h90 : l 90 = some (u32 s8))
    (hacc : Accs C kg ku M I g s i (32 * b + 8 * s8) (32 * b + 8 * s8) l)
    (hm : Mem C L I M out P (g + 1) (fun _ => True) sh) (harr : LaneArr kg ku I g s i b sh.bytes) :
    ∃ l' sh', Exec C ctx (GateUpCodebookMma.chunkBody kg ku) l sh
        (.stop (.collective 2 126 (.mma .f16 .f32) .f32 (mmaVal C kg M I.Gc I.X (4 * g + s) i (32 * b + 8 * s8)) 0)
          [.block posRestG, qLoopF kg ku, .block []]) l' sh' ∧
      Mem C L I M out P (g + 1) (fun _ => True) sh' ∧ LaneArr kg ku I g s i b sh'.bytes ∧
      LaneAB C ku M I g s i (32 * b + 8 * s8) sh'.bytes ∧ Keeps (thr g s i) sh sh' ∧
      PosLoc kg ku M I g s i (32 * b + 8 * s8) l' ∧ Accs C kg ku M I g s i (32 * b + 8 * s8) (32 * b + 8 * s8) l' ∧
      l' 96 = some (.ptr ⟨rb g s i + 9, 0, .vec .f16 2⟩) ∧ l' 125 = some (.ptr ⟨rb g s i + 10, 0, .vec .f32 2⟩) := by
  have hi := i.isLt
  have e91 := eval_xload C (ctx := ctx) hS (i := i) hM 0 24 hb hs8 hst.fix.l24 hst.l28 h90 hm
  have hm₁ := hm.rd ctx 0 (16 * (xoff M 0 i + 32 * b + s8)) 16 (.inl (by decide)) hS
  generalize hl₁ : setLocal l 91 (vec4 (cells I.X (16 * (xoff M 0 i + 32 * b + s8)) 16)) = l₁
  have h1b : ∀ x, x < 91 → l₁ x = l x := fun x hx => by rw [← hl₁, setLocal_other _ _ (by omega)]
  have e92 := eval_xload C (ctx := ctx) (l := l₁) hS (i := i) hM 1 25 hb hs8 (by rw [h1b 25 (by omega)]; exact hst.fix.l25)
    (by rw [h1b 28 (by omega)]; exact hst.l28) (by rw [h1b 90 (by omega)]; exact h90) hm₁
  have hm₂ := hm₁.rd ctx 0 (16 * (xoff M 1 i + 32 * b + s8)) 16 (.inl (by decide)) hS
  generalize hsh₂ : rdn ctx (rdn ctx sh 0 (16 * (xoff M 0 i + 32 * b + s8)) 16) 0 (16 * (xoff M 1 i + 32 * b + s8)) 16 = sh₂
    at e92 hm₂
  have hb₂ : sh₂.bytes = sh.bytes := by rw [← hsh₂]; rfl
  generalize hl₃ : setLocal (setLocal l₁ 92 (vec4 (cells I.X (16 * (xoff M 1 i + 32 * b + s8)) 16))) 93 (u32 0) = l₃
  have h3b : ∀ x, x < 91 → l₃ x = l x := fun x hx => by
    rw [← hl₃, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), h1b x hx]
  have h393 : l₃ 93 = some (u32 0) := by rw [← hl₃, setLocal_same]
  have hC : ChunkLoc kg ku M I g s i b s8 l₃ :=
    ⟨hst.of_eq fun j hj _ => h3b j (by omega), by rw [h3b 90 (by omega)]; exact h90,
      by rw [← hl₃, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), ← hl₁, setLocal_same],
      by rw [← hl₃, setLocal_other _ _ (by omega), setLocal_same]⟩
  have hP : PosLoc kg ku M I g s i (32 * b + 8 * s8) l₃ :=
    ⟨by rw [show (32 * b + 8 * s8) / 32 = b by omega, show (32 * b + 8 * s8) % 32 / 8 = s8 by omega]; exact hC,
      by rw [show (32 * b + 8 * s8) % 8 = 0 by omega]; exact h393⟩
  have hacc₃ : Accs C kg ku M I g s i (32 * b + 8 * s8) (32 * b + 8 * s8) l₃ :=
    ⟨by rw [h3b 26 (by omega)]; exact hacc.gate, by rw [h3b 27 (by omega)]; exact hacc.up⟩
  have hc : (eval C ctx l₃ (GateUpCodebookMma.lt 93 8)).run sh₂ = some (.bool true, sh₂) :=
    eval_lt_u32 C (ctx := ctx) (sh := sh₂) (b := 8) h393 (by decide) (by decide)
  obtain ⟨l', sh', xp, hm', harr', hab', hfr', hag', h96, h125⟩ := exec_pos C hS hl hKg hKu (t := 32 * b + 8 * s8)
    (by omega) hP hacc₃ hm₂ (by rw [show (32 * b + 8 * s8) / 32 = b by omega, hb₂]; exact harr)
  rw [show (32 * b + 8 * s8) / 32 = b by omega] at harr'
  refine ⟨l', sh', ?_, hm', harr', hab', fun r h8 hne => (hfr' r h8 hne).trans (by rw [hb₂]), hP.of_eq fun j hj _ => hag' j hj,
    ⟨by rw [hag' 26 (by omega)]; exact hacc₃.gate, by rw [hag' 27 (by omega)]; exact hacc₃.up⟩, h96, h125⟩
  exact .set e91 (by rw [hl₁]; exact .set e92 (.set (eval_u32lit C _ _ 0 (by decide)) (by rw [hl₃]; exact .loop_stop hc xp)))

/-- `mem` for the gate and up codes. -/
theorem mem_wordInvG (hS : Shape L kg ku M I) {ge : Nat} {cbOk : Nat → Prop} :
    GateUp.WordInv ctx (Mem C L I M out P ge cbOk) 2 I.Gc (GateUp.codesBytes kg) I.ag :=
  ⟨fun sh o h => h.rd ctx 2 o 4 (.inl (by decide)) hS, fun sh reg o bs h hr => h.tput o bs hr,
    fun sh h => ⟨by rw [h.regions]; exact hS.r2, h.gc⟩, hS.ag, by decide⟩

theorem mem_wordInvU (hS : Shape L kg ku M I) {ge : Nat} {cbOk : Nat → Prop} :
    GateUp.WordInv ctx (Mem C L I M out P ge cbOk) 4 I.Uc (GateUp.codesBytes ku) I.au :=
  ⟨fun sh o h => h.rd ctx 4 o 4 (.inl (by decide)) hS, fun sh reg o bs h hr => h.tput o bs hr,
    fun sh h => ⟨by rw [h.regions]; exact hS.r4, h.uc⟩, hS.au, by decide⟩

/-- The base step's statements before the chunk loop. -/
def stepPre : List CStmt :=
  [.set 29 (cu .add (cu .div (.local 28) (cl 32)) (.local 20)),
   .array 30 false 0 (.scalar .u32), .array 31 false 1 (.scalar .u32),
   .array 32 false 2 (.scalar .u32), .array 33 false 3 (.scalar .u32),
   .array 34 false 4 (.scalar .u32), .array 35 false 5 (.scalar .u32),
   .array 36 false 6 (.scalar .u32), .array 37 false 7 (.scalar .u32)]

theorem stepBody_eq (kg ku : Nat) : GateUpCodebookMma.stepBody kg ku =
    stepPre ++ (GateUpCodebookMma.run kg 38 (.local 22) (.local 29) (.local 30) (.local 31) ++
      (GateUpCodebookMma.run kg 51 (.local 22) (cu .add (.local 29) (cl 1)) (.local 32) (.local 33) ++
      (GateUpCodebookMma.run ku 64 (.local 23) (.local 29) (.local 34) (.local 35) ++
      (GateUpCodebookMma.run ku 77 (.local 23) (cu .add (.local 29) (cl 1)) (.local 36) (.local 37) ++
      [.set 90 (cl 0), .loop (GateUpCodebookMma.lt 90 4) (GateUpCodebookMma.incr 90) (GateUpCodebookMma.chunkBody kg ku)])))) :=
  rfl

/-- **A base step, to its first position's gate collective**: `runA`, the four runs, the first chunk. -/
theorem exec_step (hS : Shape L kg ku M I) {i : Fin 32} (hl : Lane ctx g s i) (hKg : GateUp.Width kg)
    (hKu : GateUp.Width ku) (hM : 1 ≤ M) {b : Nat} (hb : b < 20) {l : Locals} {sh : Shared}
    (hF : Fix2 kg ku M g s i l) (h28 : l 28 = some (u32 (256 * b))) (hacc : Accs C kg ku M I g s i (32 * b) (32 * b) l)
    (hm : Mem C L I M out P (g + 1) (fun _ => True) sh) :
    ∃ l' sh', Exec C ctx (GateUpCodebookMma.stepBody kg ku) l sh
        (.stop (.collective 2 126 (.mma .f16 .f32) .f32 (mmaVal C kg M I.Gc I.X (4 * g + s) i (32 * b)) 0)
          [.block posRestG, qLoopF kg ku, .block [], s8LoopF kg ku, .block []]) l' sh' ∧
      Mem C L I M out P (g + 1) (fun _ => True) sh' ∧ LaneArr kg ku I g s i b sh'.bytes ∧
      LaneAB C ku M I g s i (32 * b) sh'.bytes ∧ Keeps (thr g s i) sh sh' ∧
      PosLoc kg ku M I g s i (32 * b) l' ∧ Accs C kg ku M I g s i (32 * b) (32 * b) l' ∧
      l' 96 = some (.ptr ⟨rb g s i + 9, 0, .vec .f16 2⟩) ∧ l' 125 = some (.ptr ⟨rb g s i + 10, 0, .vec .f32 2⟩) := by
  have hi := i.isLt
  have hfn := fn_lt hi
  have hrow : rowOf g s i < 17408 := by have := hl.hg; have := hl.hs; have := fm_lt hi; unfold rowOf; omega
  have hta : ∀ j, ctx.threadArray j = rb g s i + j := fun j => by rw [hl.ta]; rfl
  have hreg := hm.regions
  -- `runA` and the arrays
  have e29 : (eval C ctx l (cu .add (cu .div (.local 28) (cl 32)) (.local 20))).run sh = some (u32 (8 * b + fn i), sh) := by
    rw [show 8 * b + fn i = 256 * b / 32 + fn i by omega]
    exact eval_bin_u32 C (eval_bin_u32 C (eval_local' C h28 sh) (eval_u32lit C _ _ 32 (by decide))
      (binary_div_u32 C _ 32 (by omega) (by decide) (by decide))) (eval_local' C hF.l20 sh) (binary_add_u32 C _ _)
  generalize hl₀ : setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal l 29
    (u32 (8 * b + fn i))) 30 (.ptr ⟨rb g s i + 0, 0, .scalar .u32⟩)) 31 (.ptr ⟨rb g s i + 1, 0, .scalar .u32⟩))
    32 (.ptr ⟨rb g s i + 2, 0, .scalar .u32⟩)) 33 (.ptr ⟨rb g s i + 3, 0, .scalar .u32⟩))
    34 (.ptr ⟨rb g s i + 4, 0, .scalar .u32⟩)) 35 (.ptr ⟨rb g s i + 5, 0, .scalar .u32⟩))
    36 (.ptr ⟨rb g s i + 6, 0, .scalar .u32⟩)) 37 (.ptr ⟨rb g s i + 7, 0, .scalar .u32⟩) = l₀
  have x0 : Exec C ctx stepPre l sh .normal l₀ sh := by
    rw [← hl₀]
    exact .set e29 <| exec_tarray C (hta 0) <| exec_tarray C (hta 1) <| exec_tarray C (hta 2) <| exec_tarray C (hta 3) <|
      exec_tarray C (hta 4) <| exec_tarray C (hta 5) <| exec_tarray C (hta 6) <| exec_tarray C (hta 7) <| .nil _ _
  have h0b : ∀ x, x < 29 → l₀ x = l x := fun x hx => by rw [← hl₀]; simp (disch := omega) only [setLocal_lt]
  have h0a : ∀ j, j < 8 → l₀ (30 + j) = some (.ptr ⟨rb g s i + j, 0, .scalar .u32⟩) := by
    intro j hj
    rcases (by omega : j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3 ∨ j = 4 ∨ j = 5 ∨ j = 6 ∨ j = 7) with
      rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> (rw [← hl₀]; simp [setLocal])
  have h029 : l₀ 29 = some (u32 (8 * b + fn i)) := by rw [← hl₀]; simp [setLocal]
  have hput : ∀ sh reg o bs, Mem C L I M out P (g + 1) (fun _ => True) sh → 8 ≤ reg →
      Mem C L I M out P (g + 1) (fun _ => True) (tput sh reg o bs) := fun sh reg o bs h hr => h.tput o bs hr
  have hrG : ∀ (sh' : Shared) j, sh'.regions = L.regions → j < 4 →
      sh'.regions (rb g s i + j) = some ⟨.thread, 4 * (kg + 1), 4⟩ := fun sh' j h hj => by rw [h]; exact hS.rg _ j hj
  have hrU : ∀ (sh' : Shared) j, sh'.regions = L.regions → 4 ≤ j → j < 8 →
      sh'.regions (rb g s i + j) = some ⟨.thread, 4 * (ku + 1), 4⟩ := fun sh' j h h1 h2 => by rw [h]; exact hS.ru _ j h1 h2
  have h8 : ∀ j, 8 ≤ rb g s i + j := fun j => by unfold rb; omega
  -- the four runs
  obtain ⟨l₁, sh₁, x1, hm₁, hag₁, -, hoth₁, hR₁⟩ := exec_run C (mem_wordInvG C hS) hput kg 38 hKg
    (rowE := .local 22) (runE := .local 29) (wE := .local 30) (vE := .local 31) (l := l₀) (sh := sh)
    (row := rowOf g s i) (run := 8 * b + fn i) (rw := rb g s i) (rv := rb g s i + 1) hrow (by omega)
    (fun l' h => eval_local' C (by rw [h 22 (by omega), h0b 22 (by omega)]; exact hF.l22) sh)
    (fun l' h => eval_local' C (by rw [h 29 (by omega)]; exact h029) sh)
    (fun l' h => eval_local' C (by rw [h 30 (by omega)]; exact h0a 0 (by omega)) sh)
    (fun l' h => eval_local' C (by rw [h 31 (by omega)]; exact h0a 1 (by omega)) sh)
    (hrG sh 0 hreg (by omega)) (hrG sh 1 hreg (by omega)) (h8 0) (h8 1) (by omega) le_rfl hm
  obtain ⟨l₂, sh₂, x2, hm₂, hag₂, -, hoth₂, hR₂⟩ := exec_run C (mem_wordInvG C hS) hput kg 51 hKg
    (rowE := .local 22) (runE := cu .add (.local 29) (cl 1)) (wE := .local 32) (vE := .local 33) (l := l₁) (sh := sh₁)
    (row := rowOf g s i) (run := 8 * b + fn i + 1) (rw := rb g s i + 2) (rv := rb g s i + 3) hrow (by omega)
    (fun l' h => eval_local' C (by rw [h 22 (by omega), hag₁ 22 (by omega), h0b 22 (by omega)]; exact hF.l22) sh₁)
    (fun l' h => eval_bin_u32 C (eval_local' C (by rw [h 29 (by omega), hag₁ 29 (by omega)]; exact h029) sh₁)
      (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C _ 1))
    (fun l' h => eval_local' C (by rw [h 32 (by omega), hag₁ 32 (by omega)]; exact h0a 2 (by omega)) sh₁)
    (fun l' h => eval_local' C (by rw [h 33 (by omega), hag₁ 33 (by omega)]; exact h0a 3 (by omega)) sh₁)
    (hrG sh₁ 2 hm₁.regions (by omega)) (hrG sh₁ 3 hm₁.regions (by omega)) (h8 2) (h8 3) (by omega) le_rfl hm₁
  obtain ⟨l₃, sh₃, x3, hm₃, hag₃, -, hoth₃, hR₃⟩ := exec_run C (mem_wordInvU C hS) hput ku 64 hKu
    (rowE := .local 23) (runE := .local 29) (wE := .local 34) (vE := .local 35) (l := l₂) (sh := sh₂)
    (row := rowOf g s i) (run := 8 * b + fn i) (rw := rb g s i + 4) (rv := rb g s i + 5) hrow (by omega)
    (fun l' h => eval_local' C ((h 23 (by omega)).trans ((hag₂ 23 (by omega)).trans ((hag₁ 23 (by omega)).trans
      ((h0b 23 (by omega)).trans hF.l23)))) sh₂)
    (fun l' h => eval_local' C (by rw [h 29 (by omega), hag₂ 29 (by omega), hag₁ 29 (by omega)]; exact h029) sh₂)
    (fun l' h => eval_local' C (by rw [h 34 (by omega), hag₂ 34 (by omega), hag₁ 34 (by omega)]; exact h0a 4 (by omega)) sh₂)
    (fun l' h => eval_local' C (by rw [h 35 (by omega), hag₂ 35 (by omega), hag₁ 35 (by omega)]; exact h0a 5 (by omega)) sh₂)
    (hrU sh₂ 4 hm₂.regions (by omega) (by omega)) (hrU sh₂ 5 hm₂.regions (by omega) (by omega)) (h8 4) (h8 5) (by omega)
    le_rfl hm₂
  obtain ⟨l₄, sh₄, x4, hm₄, hag₄, -, hoth₄, hR₄⟩ := exec_run C (mem_wordInvU C hS) hput ku 77 hKu
    (rowE := .local 23) (runE := cu .add (.local 29) (cl 1)) (wE := .local 36) (vE := .local 37) (l := l₃) (sh := sh₃)
    (row := rowOf g s i) (run := 8 * b + fn i + 1) (rw := rb g s i + 6) (rv := rb g s i + 7) hrow (by omega)
    (fun l' h => eval_local' C ((h 23 (by omega)).trans ((hag₃ 23 (by omega)).trans ((hag₂ 23 (by omega)).trans
      ((hag₁ 23 (by omega)).trans ((h0b 23 (by omega)).trans hF.l23))))) sh₃)
    (fun l' h => eval_bin_u32 C (eval_local' C ((h 29 (by omega)).trans ((hag₃ 29 (by omega)).trans
      ((hag₂ 29 (by omega)).trans ((hag₁ 29 (by omega)).trans h029)))) sh₃) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C _ 1))
    (fun l' h => eval_local' C ((h 36 (by omega)).trans ((hag₃ 36 (by omega)).trans ((hag₂ 36 (by omega)).trans
      ((hag₁ 36 (by omega)).trans (h0a 6 (by omega)))))) sh₃)
    (fun l' h => eval_local' C ((h 37 (by omega)).trans ((hag₃ 37 (by omega)).trans ((hag₂ 37 (by omega)).trans
      ((hag₁ 37 (by omega)).trans (h0a 7 (by omega)))))) sh₃)
    (hrU sh₃ 6 hm₃.regions (by omega) (by omega)) (hrU sh₃ 7 hm₃.regions (by omega) (by omega)) (h8 6) (h8 7) (by omega)
    le_rfl hm₃
  have h4b : ∀ x, x < 38 → l₄ x = l₀ x := fun x hx => by
    rw [hag₄ x (by omega), hag₃ x (by omega), hag₂ x (by omega), hag₁ x hx]
  -- the run arrays in place
  have harr : LaneArr kg ku I g s i b sh₄.bytes := by
    refine ⟨?_, ?_, ?_, ?_⟩
    · rw [hoth₄ (rb g s i) (by omega) (by omega), hoth₃ (rb g s i) (by omega) (by omega),
        hoth₂ (rb g s i) (by omega) (by omega), hoth₄ (rb g s i + 1) (by omega) (by omega),
        hoth₃ (rb g s i + 1) (by omega) (by omega), hoth₂ (rb g s i + 1) (by omega) (by omega)]
      exact hR₁
    · rw [hoth₄ (rb g s i + 2) (by omega) (by omega), hoth₃ (rb g s i + 2) (by omega) (by omega),
        hoth₄ (rb g s i + 3) (by omega) (by omega), hoth₃ (rb g s i + 3) (by omega) (by omega)]
      exact hR₂
    · rw [hoth₄ (rb g s i + 4) (by omega) (by omega), hoth₄ (rb g s i + 5) (by omega) (by omega)]
      exact hR₃
    · exact hR₄
  have hfr₄ : Keeps (thr g s i) sh sh₄ := by
    intro r hr8 hne
    have hne' : ∀ j, j < 8 → r ≠ rb g s i + j := fun j hj h => hne (by rw [h]; exact rb_thr g s i j (by omega))
    rw [hoth₄ _ (hne' 6 (by omega)) (hne' 7 (by omega)), hoth₃ _ (hne' 4 (by omega)) (hne' 5 (by omega)),
      hoth₂ _ (hne' 2 (by omega)) (hne' 3 (by omega)), hoth₁ _ (hne' 0 (by omega)) (hne' 1 (by omega))]
  -- the first chunk
  generalize hl₅ : setLocal l₄ 90 (u32 0) = l₅
  have h5b : ∀ x, x < 38 → l₅ x = l₀ x := fun x hx => by rw [← hl₅, setLocal_other _ _ (by omega), h4b x hx]
  have hst : StepLoc kg ku M g s i b l₅ :=
    ⟨hF.of_eq fun j hj => by rw [h5b j (by omega), h0b j (by omega)], by rw [h5b 28 (by omega), h0b 28 (by omega)]; exact h28,
      by rw [h5b 29 (by omega)]; exact h029, by rw [h5b 30 (by omega)]; exact h0a 0 (by omega),
      by rw [h5b 31 (by omega)]; exact h0a 1 (by omega), by rw [h5b 32 (by omega)]; exact h0a 2 (by omega),
      by rw [h5b 33 (by omega)]; exact h0a 3 (by omega), by rw [h5b 34 (by omega)]; exact h0a 4 (by omega),
      by rw [h5b 35 (by omega)]; exact h0a 5 (by omega), by rw [h5b 36 (by omega)]; exact h0a 6 (by omega),
      by rw [h5b 37 (by omega)]; exact h0a 7 (by omega)⟩
  have h590 : l₅ 90 = some (u32 0) := by rw [← hl₅, setLocal_same]
  have hacc₅ : Accs C kg ku M I g s i (32 * b + 8 * 0) (32 * b + 8 * 0) l₅ :=
    ⟨by rw [h5b 26 (by omega), h0b 26 (by omega)]; exact hacc.gate,
      by rw [h5b 27 (by omega), h0b 27 (by omega)]; exact hacc.up⟩
  have hc : (eval C ctx l₅ (GateUpCodebookMma.lt 90 4)).run sh₄ = some (.bool true, sh₄) :=
    eval_lt_u32 C (ctx := ctx) (sh := sh₄) (b := 4) h590 (by decide) (by decide)
  obtain ⟨l', sh', xc, hm', harr', hab', hfr', hP', hacc', h96, h125⟩ :=
    exec_chunk C hS hl hKg hKu hM hb (show 0 < 4 by decide) hst h590 hacc₅ hm₄ harr
  rw [show 32 * b + 8 * 0 = 32 * b by omega] at xc hab' hP' hacc'
  refine ⟨l', sh', ?_, hm', harr', hab', hfr₄.trans hfr', hP', hacc', h96, h125⟩
  rw [stepBody_eq]
  exact x0.append (x1.append (x2.append (x3.append (x4.append
    (.set (eval_u32lit C _ _ 0 (by decide)) (by rw [hl₅]; exact .loop_stop hc xc))))))

end Chunk

/-! ### After the barrier -/

/-- The statements after the barrier before the base loop, the base loop's test and step, and what follows it. -/
def restPre (kg ku : Nat) : List CStmt :=
  [.set 18 (cu .mul (cu .add (cu .mul (.component (.coord .threadgroupPositionInGrid) (cl 1)) (cl 4)) (.local 9)) (cl 8)),
   .ite (cu .ge (.local 18) (cl 17408)) [.leave] [],
   .set 19 (cu .add (cu .bitAnd (cu .div (.local 8) (cl 4)) (cl 4)) (cu .rem (cu .div (.local 8) (cl 2)) (cl 4))),
   .set 20 (cu .add (cu .mul (cu .bitAnd (cu .div (.local 8) (cl 4)) (cl 2)) (cl 2)) (cu .mul (cu .rem (.local 8) (cl 2)) (cl 2))),
   .set 21 (cu .add (.local 18) (.local 19)),
   .set 22 (.offset (.local 2) (GateUpCodebookMma.u64 .mul (GateUpCodebookMma.toU64 (.local 21))
     (GateUpCodebookMma.u64l (160 * kg)))),
   .set 23 (.offset (.local 4) (GateUpCodebookMma.u64 .mul (GateUpCodebookMma.toU64 (.local 21))
     (GateUpCodebookMma.u64l (160 * ku)))),
   .set 24 (GateUpCodebookMma.xRow (.local 20)),
   .set 25 (GateUpCodebookMma.xRow (cu .add (.local 20) (cl 1))),
   .set 26 (.vector .f32 [GateUpCodebookMma.f32l 0x0, GateUpCodebookMma.f32l 0x0]),
   .set 27 (.vector .f32 [GateUpCodebookMma.f32l 0x0, GateUpCodebookMma.f32l 0x0]),
   .set 28 (cl 0)]

def baseCond : CExpr := GateUpCodebookMma.lt 28 5120
def baseStep : List CStmt := [.set 28 (cu .add (.local 28) (cl 256))]

def afterBase : List CStmt :=
  [.set 128 (.bin .mul .f32 0 (.conv .f32 (.load (.scalar .f16) (.offset (.local 3) (.local 21))))
     (GateUpCodebookMma.f32l 0x3BDDB447)),
   .set 129 (.bin .mul .f32 0 (.conv .f32 (.load (.scalar .f16) (.offset (.local 5) (.local 21))))
     (GateUpCodebookMma.f32l 0x3BDDB447)),
   .set 130 (cl 0),
   .loop (GateUpCodebookMma.lt 130 2) (GateUpCodebookMma.incr 130) GateUpCodebookMma.outBody]

theorem rest_eq (kg ku : Nat) :
    rest kg ku = restPre kg ku ++ .loop baseCond baseStep (GateUpCodebookMma.stepBody kg ku) :: afterBase := rfl

def baseLoopF (kg ku : Nat) : Frame := .loop baseCond baseStep (GateUpCodebookMma.stepBody kg ku)

section Rest
variable (C : M1Max.Contract) {L : Launch} {kg ku M : Nat} {I : In} {out : Nat → Nat → BF} {P g s : Nat} {ctx : Ctx}

/-- `x0`, `x1`: `x` row `min(fn + e, M - 1)` from position `32·fm`, as a `uint4` pointer. -/
theorem eval_xRow (hM : 1 ≤ M) {fnE : CExpr} {i e : Nat} (hi : i < 32) {l : Locals} {sh : Shared}
    (h0 : l 0 = some (.ptr ⟨0, 0, .scalar .bf16⟩)) (h7 : l 7 = some (u32 M)) (h19 : l 19 = some (u32 (fm i)))
    (hfn : (eval C ctx l fnE).run sh = some (u32 (fn i + e), sh)) (he : e < 2) (hM8 : M ≤ 8) :
    (eval C ctx l (GateUpCodebookMma.xRow fnE)).run sh =
      some (.ptr ⟨0, ((16 * xoff M e i : Nat) : Int), .vec .u32 4⟩, sh) := by
  have hf := fm_lt hi; have hfn' := fn_lt hi
  have hmin : (eval C ctx l (cu .min fnE (cu .sub (.local 7) (cl 1)))).run sh = some (u32 (min (fn i + e) (M - 1)), sh) :=
    eval_bin_u32 C hfn (eval_bin_u32 C (eval_local' C h7 sh) (eval_u32lit C _ _ 1 (by decide)) (binary_sub_u32 C M 1 hM))
      (binary_min_u32 C _ _ (by omega) (by omega))
  have hmn : min (fn i + e) (M - 1) < 8 := by have := Nat.min_le_right (fn i + e) (M - 1); omega
  have h64 : (eval C ctx l (GateUpCodebookMma.u64 .mul (GateUpCodebookMma.toU64 (cu .min fnE (cu .sub (.local 7) (cl 1))))
      (GateUpCodebookMma.u64l 5120))).run sh = some (u64 (min (fn i + e) (M - 1) * 5120), sh) :=
    eval_int C (by decide) (eval_conv C (t := .u64) hmin (convert_u64_u32 C _ (by omega)))
      (by rw [← u64_lit (show 5120 < 2 ^ 64 by decide)]; exact eval_lit C _ _ _ _) (binary_mul_u64 C _ 5120)
  have hp1 := eval_offset_u64 C (o := 0) (eval_local' C h0 sh) h64 (by omega)
  have hp2 := eval_offset_u32 C (o := 0 + min (fn i + e) (M - 1) * 5120 * (Ty.scalar .bf16).bytes) hp1
    (eval_bin_u32 C (op := .mul) (site := 0) (eval_local' C h19 sh) (eval_u32lit C _ _ 32 (by decide))
      (binary_mul_u32 C (fm i) 32)) (by omega)
  have hp3 := eval_ptrCast C (t := .vec .u32 4) hp2
  rw [show 0 + min (fn i + e) (M - 1) * 5120 * (Ty.scalar .bf16).bytes + fm i * 32 * (Ty.scalar .bf16).bytes =
    16 * xoff M e i by unfold xoff; simp only [Ty.bytes, Scalar.bytes]; generalize min (fn i + e) (M - 1) = mn; omega] at hp3
  exact hp3

/-- A `u64` pointer offset into a codes buffer: row `row`'s words. -/
theorem eval_rowPtr (K reg : Nat) (hK : GateUp.Width K) {row : Nat} (hrow : row < 17408) {l : Locals} {sh : Shared}
    (hp : l reg = some (.ptr ⟨reg, 0, .scalar .u32⟩)) (h21 : l 21 = some (u32 row)) :
    (eval C ctx l (.offset (.local reg) (GateUpCodebookMma.u64 .mul (GateUpCodebookMma.toU64 (.local 21))
      (GateUpCodebookMma.u64l (160 * K))))).run sh =
      some (.ptr ⟨reg, ((4 * (row * (160 * K)) : Nat) : Int), .scalar .u32⟩, sh) := by
  have hk := GateUp.width_le hK
  have h64 : (eval C ctx l (GateUpCodebookMma.u64 .mul (GateUpCodebookMma.toU64 (.local 21))
      (GateUpCodebookMma.u64l (160 * K)))).run sh = some (u64 (row * (160 * K)), sh) :=
    eval_int C (by decide) (eval_conv C (t := .u64) (eval_local' C h21 sh) (convert_u64_u32 C _ (by omega)))
      (by rw [← u64_lit (show 160 * K < 2 ^ 64 by omega)]; exact eval_lit C _ _ _ _) (binary_mul_u64 C _ _)
  have hb64 : row * (160 * K) < 2 ^ 64 := by
    have := Nat.mul_le_mul (le_of_lt hrow) (show 160 * K ≤ 640 by omega); omega
  have := eval_offset_u64 C (o := 0) (eval_local' C hp sh) h64 hb64
  rwa [show 0 + row * (160 * K) * (Ty.scalar .u32).bytes = 4 * (row * (160 * K)) by
    simp only [Ty.bytes, Scalar.bytes]; ring] at this

/-- **After the barrier, to the first gate collective**: the lane's declarations, then base step 0. -/
theorem exec_rest (hS : Shape L kg ku M I) {i : Fin 32} (hl : Lane ctx g s i) (hKg : GateUp.Width kg)
    (hKu : GateUp.Width ku) (hM : 1 ≤ M) (hM8 : M ≤ 8) {l : Locals} {sh : Shared} (hF : Fix1 M s i l)
    (hm : Mem C L I M out P (g + 1) (fun _ => True) sh) :
    ∃ l' sh', Exec C ctx (rest kg ku) l sh
        (.stop (.collective 2 126 (.mma .f16 .f32) .f32 (mmaVal C kg M I.Gc I.X (4 * g + s) i 0) 0)
          [.block posRestG, qLoopF kg ku, .block [], s8LoopF kg ku, .block [], baseLoopF kg ku, .block afterBase]) l' sh' ∧
      Mem C L I M out P (g + 1) (fun _ => True) sh' ∧ LaneArr kg ku I g s i 0 sh'.bytes ∧
      LaneAB C ku M I g s i 0 sh'.bytes ∧ Keeps (thr g s i) sh sh' ∧
      PosLoc kg ku M I g s i 0 l' ∧ Accs C kg ku M I g s i 0 0 l' ∧
      l' 96 = some (.ptr ⟨rb g s i + 9, 0, .vec .f16 2⟩) ∧ l' 125 = some (.ptr ⟨rb g s i + 10, 0, .vec .f32 2⟩) := by
  have hi := i.isLt; have hg := hl.hg; have hs := hl.hs
  have hf := fm_lt hi; have hfn := fn_lt hi
  have hrow : rowOf g s i < 17408 := by unfold rowOf; omega
  -- `n0`, its test, `fm`, `fn`, `row`
  have e18 : (eval C ctx l (cu .mul (cu .add (cu .mul (.component (.coord .threadgroupPositionInGrid) (cl 1)) (cl 4))
      (.local 9)) (cl 8))).run sh = some (u32 (8 * (4 * g + s)), sh) := by
    rw [show 8 * (4 * g + s) = (g * 4 + s) * 8 by ring]
    exact eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_coord1 C hl.tgpos) (eval_u32lit C _ _ 4 (by decide))
      (binary_mul_u32 C g 4)) (eval_local' C hF.l9 sh) (binary_add_u32 C _ s)) (eval_u32lit C _ _ 8 (by decide))
      (binary_mul_u32 C _ 8)
  generalize hl₁ : setLocal l 18 (u32 (8 * (4 * g + s))) = l₁
  have h118 : l₁ 18 = some (u32 (8 * (4 * g + s))) := by rw [← hl₁, setLocal_same]
  have hc : (eval C ctx l₁ (cu .ge (.local 18) (cl 17408))).run sh = some (.bool false, sh) := by
    have := eval_bin_u32 C (ctx := ctx) (sh := sh) (op := .ge) (site := 0) (a := .local 18) (b := cl 17408)
      (eval_local' C h118 sh) (eval_u32lit C _ _ 17408 (by decide)) (binary_ge_u32 C _ 17408 (by omega) (by decide))
    rwa [decide_eq_false (show ¬ 17408 ≤ 8 * (4 * g + s) by omega)] at this
  have h1b : ∀ x, x < 18 → l₁ x = l x := fun x hx => by rw [← hl₁, setLocal_other _ _ (by omega)]
  have h18 : l₁ 8 = some (u32 i) := by rw [h1b 8 (by omega)]; exact hF.l8
  have e19 : (eval C ctx l₁ (cu .add (cu .bitAnd (cu .div (.local 8) (cl 4)) (cl 4)) (cu .rem (cu .div (.local 8) (cl 2))
      (cl 4)))).run sh = some (u32 (fm i), sh) :=
    eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h18 sh) (eval_u32lit C _ _ 4 (by decide))
      (binary_div_u32 C i 4 (by omega) (by decide) (by decide))) (eval_u32lit C _ _ 4 (by decide))
      (binary_bitAnd_u32 C _ 4 (by omega) (by decide)))
      (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h18 sh) (eval_u32lit C _ _ 2 (by decide))
        (binary_div_u32 C i 2 (by omega) (by decide) (by decide))) (eval_u32lit C _ _ 4 (by decide))
        (binary_rem_u32 C _ 4 (by omega) (by decide) (by decide))) (binary_add_u32 C _ _)
  generalize hl₂ : setLocal l₁ 19 (u32 (fm i)) = l₂
  have h28 : l₂ 8 = some (u32 i) := by rw [← hl₂, setLocal_other _ _ (by omega)]; exact h18
  have e20 : (eval C ctx l₂ (cu .add (cu .mul (cu .bitAnd (cu .div (.local 8) (cl 4)) (cl 2)) (cl 2))
      (cu .mul (cu .rem (.local 8) (cl 2)) (cl 2)))).run sh = some (u32 (fn i), sh) :=
    eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h28 sh) (eval_u32lit C _ _ 4 (by decide))
      (binary_div_u32 C i 4 (by omega) (by decide) (by decide))) (eval_u32lit C _ _ 2 (by decide))
      (binary_bitAnd_u32 C _ 2 (by omega) (by decide))) (eval_u32lit C _ _ 2 (by decide)) (binary_mul_u32 C _ 2))
      (eval_bin_u32 C (eval_bin_u32 C (eval_local' C h28 sh) (eval_u32lit C _ _ 2 (by decide))
        (binary_rem_u32 C i 2 (by omega) (by decide) (by decide))) (eval_u32lit C _ _ 2 (by decide))
        (binary_mul_u32 C _ 2)) (binary_add_u32 C _ _)
  generalize hl₃ : setLocal l₂ 20 (u32 (fn i)) = l₃
  have e21 : (eval C ctx l₃ (cu .add (.local 18) (.local 19))).run sh = some (u32 (rowOf g s i), sh) :=
    eval_bin_u32 C (eval_local' C (by rw [← hl₃, setLocal_other _ _ (by omega), ← hl₂, setLocal_other _ _ (by omega)]; exact h118) sh)
      (eval_local' C (by rw [← hl₃, setLocal_other _ _ (by omega), ← hl₂, setLocal_same]) sh) (binary_add_u32 C _ _)
  generalize hl₄ : setLocal l₃ 21 (u32 (rowOf g s i)) = l₄
  have h4b : ∀ x, x < 18 → l₄ x = l x := fun x hx => by
    rw [← hl₄, setLocal_other _ _ (by omega), ← hl₃, setLocal_other _ _ (by omega), ← hl₂, setLocal_other _ _ (by omega),
      h1b x hx]
  have h421 : l₄ 21 = some (u32 (rowOf g s i)) := by rw [← hl₄, setLocal_same]
  have h419 : l₄ 19 = some (u32 (fm i)) := by
    rw [← hl₄, setLocal_other _ _ (by omega), ← hl₃, setLocal_other _ _ (by omega), ← hl₂, setLocal_same]
  have h420 : l₄ 20 = some (u32 (fn i)) := by rw [← hl₄, setLocal_other _ _ (by omega), ← hl₃, setLocal_same]
  have h418 : l₄ 18 = some (u32 (8 * (4 * g + s))) := by
    rw [← hl₄, setLocal_other _ _ (by omega), ← hl₃, setLocal_other _ _ (by omega), ← hl₂, setLocal_other _ _ (by omega)]
    exact h118
  -- the row pointers and `x0`, `x1`
  have e22 := eval_rowPtr C (ctx := ctx) (sh := sh) kg 2 hKg hrow (by rw [h4b 2 (by omega)]; exact hF.fix0.l2) h421
  generalize hl₅ : setLocal l₄ 22 (.ptr ⟨2, ((4 * (rowOf g s i * (160 * kg)) : Nat) : Int), .scalar .u32⟩) = l₅
  have h5b : ∀ x, x < 22 → l₅ x = l₄ x := fun x hx => by rw [← hl₅, setLocal_other _ _ (by omega)]
  have e23 := eval_rowPtr C (ctx := ctx) (sh := sh) (l := l₅) ku 4 hKu hrow
    (by rw [h5b 4 (by omega), h4b 4 (by omega)]; exact hF.fix0.l4) (by rw [h5b 21 (by omega)]; exact h421)
  generalize hl₆ : setLocal l₅ 23 (.ptr ⟨4, ((4 * (rowOf g s i * (160 * ku)) : Nat) : Int), .scalar .u32⟩) = l₆
  have h6b : ∀ x, x < 22 → l₆ x = l₄ x := fun x hx => by rw [← hl₆, setLocal_other _ _ (by omega), h5b x hx]
  have e24 := eval_xRow C (ctx := ctx) (sh := sh) (l := l₆) (fnE := .local 20) (e := 0) hM hi
    (by rw [h6b 0 (by omega), h4b 0 (by omega)]; exact hF.fix0.l0) (by rw [h6b 7 (by omega), h4b 7 (by omega)]; exact hF.l7)
    (by rw [h6b 19 (by omega)]; exact h419) (eval_local' C (by rw [h6b 20 (by omega)]; exact h420) sh) (by omega) hM8
  generalize hl₇ : setLocal l₆ 24 (.ptr ⟨0, ((16 * xoff M 0 i : Nat) : Int), .vec .u32 4⟩) = l₇
  have h7b : ∀ x, x < 22 → l₇ x = l₄ x := fun x hx => by rw [← hl₇, setLocal_other _ _ (by omega), h6b x hx]
  have e25 := eval_xRow C (ctx := ctx) (sh := sh) (l := l₇) (fnE := cu .add (.local 20) (cl 1)) (e := 1) hM hi
    (by rw [h7b 0 (by omega), h4b 0 (by omega)]; exact hF.fix0.l0) (by rw [h7b 7 (by omega), h4b 7 (by omega)]; exact hF.l7)
    (by rw [h7b 19 (by omega)]; exact h419)
    (eval_bin_u32 C (eval_local' C (by rw [h7b 20 (by omega)]; exact h420) sh) (eval_u32lit C _ _ 1 (by decide))
      (binary_add_u32 C _ 1)) (by omega) hM8
  generalize hl₈ : setLocal l₇ 25 (.ptr ⟨0, ((16 * xoff M 1 i : Nat) : Int), .vec .u32 4⟩) = l₈
  have hzero : ∀ lx : Locals, (eval C ctx lx (.vector .f32 [GateUpCodebookMma.f32l 0x0, GateUpCodebookMma.f32l 0x0])).run sh =
      some (.vec .f32 [.f32 (Val.ofF32Bits 0), .f32 (Val.ofF32Bits 0)], sh) := fun lx =>
    eval_vector C (evalList_cons C (eval_lit C _ _ _ _) (evalList_cons C (eval_lit C _ _ _ _) (evalList_nil C)))
  generalize hl₁₁ : setLocal (setLocal (setLocal l₈ 26 (.vec .f32 [.f32 (Val.ofF32Bits 0), .f32 (Val.ofF32Bits 0)])) 27
    (.vec .f32 [.f32 (Val.ofF32Bits 0), .f32 (Val.ofF32Bits 0)])) 28 (u32 0) = l₁₁
  have hpre : Exec C ctx (restPre kg ku) l sh .normal l₁₁ sh :=
    Exec.set_eq C e18 hl₁ (.ite hc (.nil _ _) (Exec.set_eq C e19 hl₂ (Exec.set_eq C e20 hl₃ (Exec.set_eq C e21 hl₄
      (Exec.set_eq C e22 hl₅ (Exec.set_eq C e23 hl₆ (Exec.set_eq C e24 hl₇ (Exec.set_eq C e25 hl₈
        (.set (hzero _) (.set (hzero _) (Exec.set_eq C (eval_u32lit C _ _ 0 (by decide)) hl₁₁ (.nil _ _))))))))))))
  -- the locals
  have hl₁₁8 : ∀ x, x ≤ 25 → l₁₁ x = l₈ x := fun x hx => by
    rw [← hl₁₁, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
  have h8b : ∀ x, x < 22 → l₈ x = l₄ x := fun x hx => by rw [← hl₈, setLocal_other _ _ (by omega), h7b x hx]
  have hF2 : Fix2 kg ku M g s i l₁₁ := by
    refine ⟨hF.of_eq fun j hj => by rw [hl₁₁8 j (by omega), h8b j (by omega), h4b j (by omega)], ?_, ?_, ?_, ?_, ?_, ?_, ?_,
      ?_⟩
    · rw [hl₁₁8 18 (by omega), h8b 18 (by omega)]; exact h418
    · rw [hl₁₁8 19 (by omega), h8b 19 (by omega)]; exact h419
    · rw [hl₁₁8 20 (by omega), h8b 20 (by omega)]; exact h420
    · rw [hl₁₁8 21 (by omega), h8b 21 (by omega)]; exact h421
    · rw [hl₁₁8 22 (by omega), ← hl₈, setLocal_other _ _ (by omega), ← hl₇, setLocal_other _ _ (by omega), ← hl₆,
        setLocal_other _ _ (by omega), ← hl₅, setLocal_same]
    · rw [hl₁₁8 23 (by omega), ← hl₈, setLocal_other _ _ (by omega), ← hl₇, setLocal_other _ _ (by omega), ← hl₆,
        setLocal_same]
    · rw [hl₁₁8 24 (by omega), ← hl₈, setLocal_other _ _ (by omega), ← hl₇, setLocal_same]
    · rw [hl₁₁8 25 (by omega), ← hl₈, setLocal_same]
  have h1128 : l₁₁ 28 = some (u32 (256 * 0)) := by rw [← hl₁₁, setLocal_same]
  have hacc : Accs C kg ku M I g s i (32 * 0) (32 * 0) l₁₁ :=
    ⟨by rw [← hl₁₁, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_same]; rfl,
      by rw [← hl₁₁, setLocal_other _ _ (by omega), setLocal_same]; rfl⟩
  have hcb : (eval C ctx l₁₁ baseCond).run sh = some (.bool true, sh) :=
    eval_lt_u32 C (ctx := ctx) (sh := sh) (b := 5120) h1128 (by decide) (by decide)
  obtain ⟨l', sh', xs, hm', harr', hab', hfr', hP', hacc', h96, h125⟩ :=
    exec_step C hS hl hKg hKu hM (show 0 < 20 by decide) hF2 h1128 hacc hm
  refine ⟨l', sh', ?_, hm', harr', hab', hfr', hP', hacc', h96, h125⟩
  rw [rest_eq]
  exact hpre.append (.loop_stop hcb xs)

end Rest

section Fill
variable (C : M1Max.Contract) {L : Launch} {kg ku M : Nat} {I : In} {out : Nat → Nat → BF} {P g s i : Nat} {ctx : Ctx}

/-- At the `k`-th test of the codebook loop of thread `32·s + i`. -/
def FillI (L : Launch) (I : In) (M : Nat) (out : Nat → Nat → BF) (P g s i : Nat) (k : Nat) (l : Locals)
    (sh : Shared) : Prop :=
  Fix1 M s i l ∧ l 11 = some (u32 (32 * s + i + 128 * k)) ∧
    Mem C L I M out P g (fun e => e % 128 < 32 * s + i ∨ (e % 128 = 32 * s + i ∧ e / 128 < k)) sh

/-- The codebook loop: `codebook[e] = half(trellis_y_f32(e))` for the lane's entries `e ≡ 32·s + i (mod 128)`. -/
theorem fill_loop (hS : Shape L kg ku M I) (hl : Lane ctx g s i) {l : Locals} {sh : Shared}
    (h0 : FillI C L I M out P g s i 0 l sh) :
    ∃ l' sh', Exec C ctx [GateUpCodebookMma.fillLoop] l sh .normal l' sh' ∧ FillI C L I M out P g s i 32 l' sh' := by
  have hs := hl.hs; have hi := hl.hi
  refine Exec.loop_count 32 (FillI C L I M out P g s i) (FillI C L I M out P g s i)
    (fun k hk l sh hI => ⟨sh, ?_, hI⟩) (fun k hk l sh hI => ?_) h0
  · have h := eval_lt_u32 C (ctx := ctx) (sh := sh) (b := 4096) hI.2.1 (by omega) (by decide)
    rwa [show decide (32 * s + i + 128 * k < 4096) = decide (k < 32) from decide_eq_decide.mpr (by omega)] at h
  · obtain ⟨hF, h11, hm⟩ := hI
    have he : 32 * s + i + 128 * k < 4096 := by omega
    obtain ⟨l₂, hy, h13, hag⟩ := exec_yF32 C (ctx := ctx) (l := setLocal l 12 (u32 (32 * s + i + 128 * k))) (sh := sh)
      (s := 32 * s + i + 128 * k) (setLocal_same _ _ _)
    have h10 : l₂ 10 = some (.ptr ⟨7, 0, .scalar .f16⟩) := by
      rw [hag 10 (by omega), setLocal_other _ _ (by omega)]; exact hF.l10
    have h11' : l₂ 11 = some (u32 (32 * s + i + 128 * k)) := by rw [hag 11 (by omega), setLocal_other _ _ (by omega)]; exact h11
    have hp := eval_ptr_u32 C (ctx := ctx) (eval_local' C h10 sh) (eval_local' C h11' sh) (by omega)
    rw [show (32 * s + i + 128 * k) * (Ty.scalar .f16).bytes = 2 * (32 * s + i + 128 * k) by
      simp only [Ty.bytes, Scalar.bytes]; ring] at hp
    have hst := store_shared ctx .f16 sh 7 (2 * (32 * s + i + 128 * k)) _ _ _ (by rw [hm.regions]; exact hS.r7)
      (by simp) (by simp) (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega)
      (encode_f16 (cbEntry C (32 * s + i + 128 * k)))
    have hm' := hm.wcb hS ctx (32 * s + i + 128 * k) he (by rw [hl.thread]; omega) hl.group
    rw [show Scalar.f16.bytes = 2 from rfl] at hst
    generalize wrn ctx sh 7 (2 * (32 * s + i + 128 * k)) 2
      (wordBytes 2 (Val.f16Bits (cbEntry C (32 * s + i + 128 * k)))) = sh₁ at hst hm'
    refine ⟨.normal, l₂, sh₁, setLocal l₂ 11 (u32 (32 * s + i + 128 * k + 128)), sh₁, .inl rfl, ?_,
      .set (eval_bin_u32 C (eval_local' C h11' _) (eval_u32lit C _ _ 128 (by decide)) (binary_add_u32 C _ 128)) (.nil _ _),
      ⟨?_, by rw [setLocal_same, show 32 * s + i + 128 * k + 128 = 32 * s + i + 128 * (k + 1) by ring], ?_⟩⟩
    · show Exec C ctx (.set 12 (.local 11) :: ([GateUpCodebookMma.yF32 12] ++
        [.store (.scalar .f16) (.offset (.local 10) (.local 11)) (.conv .f16 (.local 13))])) l sh .normal l₂ _
      exact .set (eval_local' C h11 sh) (hy.append (.store hp (eval_conv C (t := .f16) (eval_local' C h13 sh) rfl) hst
        (.nil _ _)))
    · exact (hF.of_eq fun j hj => by rw [hag j (by omega), setLocal_other _ _ (by omega)]).of_eq
        fun j hj => setLocal_other _ _ (by omega)
    · refine hm'.mono (cbOk' := fun e => e % 128 < 32 * s + i ∨ (e % 128 = 32 * s + i ∧ e / 128 < k + 1))
        (fun e _ h => ?_)
      rcases h with h | ⟨h1, h2⟩
      · exact .inl (.inl h)
      · by_cases hk' : e / 128 < k
        · exact .inl (.inr ⟨h1, hk'⟩)
        · exact .inr (by omega)

/-- **A lane to the barrier**: the buffer pointers, `M`, `lane`, `sg`, its codebook entries. -/
theorem lane_phase1 (hS : Shape L kg ku M I) (hl : Lane ctx g s i) (hM : bytesWord (cells I.S 0 4) = M) (hM8 : M ≤ 8)
    {sh : Shared} (hm : Mem C L I M out P g (fun e => e % 128 < 32 * s + i) sh) :
    ∃ t sh', (Ev fun m => (runThread C m ⟨ctx, fun _ => none, [.block (GateUpCodebookMma.body kg ku)], .running⟩).run sh =
        some (t, sh')) ∧
      Mem C L I M out P g (fun e => e % 128 < 32 * s + i + 1) sh' ∧
      t.status = .barrier 1 false true ∧ t.ctx = ctx ∧ t.frames = [.block (rest kg ku), .scope, .block []] ∧
      Fix1 M s i t.locals := by
  have hs := hl.hs; have hi := hl.hi
  obtain ⟨l₀, x0, hF₀⟩ := fix0_pre C ctx sh
  obtain ⟨l₁, x1, hF₁, h11⟩ := fix1_pre C hS hl hM hM8 hF₀ hm
  have hm₁ := hm.rd ctx 1 0 4 (.inl (by decide)) hS
  obtain ⟨l₂, sh₂, x2, hF₂, -, hm₂⟩ := fill_loop C hS hl (l := l₁) (sh := rdn ctx sh 1 0 4)
    ⟨hF₁, by rw [h11, Nat.mul_zero, Nat.add_zero],
      hm₁.mono fun e _ h => by rcases h with h | ⟨-, h⟩ <;> omega⟩
  have hbody : Exec C ctx ((scopePre ++ [GateUpCodebookMma.fillLoop]) ++ .barrier 1 false true :: rest kg ku) l₀ sh
      (.stop (.barrier 1 false true) [.block (rest kg ku)]) l₂ sh₂ :=
    (x1.append x2).append .barrier
  have hex : Exec C ctx (GateUpCodebookMma.body kg ku) (fun _ => none) sh
      (.stop (.barrier 1 false true) [.block (rest kg ku), .scope, .block []]) l₂ sh₂ := by
    rw [body_eq]; exact x0.append (.scope_stop hbody)
  refine ⟨⟨ctx, l₂, [.block (rest kg ku), .scope, .block []], .barrier 1 false true⟩, sh₂,
    (hex.reaches_stop (K := [])).ev_stop rfl, hm₂.mono fun e he h => ?_, rfl, rfl, rfl, hF₂⟩
  omega

end Fill

/-- The frames below a position's statements: the position, chunk and base loops, the scope's rest. -/
def framesQ (kg ku : Nat) : List Frame :=
  [qLoopF kg ku, .block [], s8LoopF kg ku, .block [], baseLoopF kg ku, .block afterBase, .scope, .block []]

theorem midOut_lane (C : M1Max.Contract) (kg ku : Nat) (X Gc Gs Uc Us : ByteMemory.Bytes) (M g s : Nat) (i : Fin 32)
    (j : Fin 2) :
    midOut C kg ku X Gc Gs Uc Us M (fn i + j) (rowOf g s i) =
      silu C (C.fmul (acc C kg Gc X M (4 * g + s) 640 i j) (rowScale C Gs (rowOf g s i)))
        (C.fmul (acc C ku Uc X M (4 * g + s) 640 i j) (rowScale C Us (rowOf g s i))) := by
  have hf := fm_lt i.isLt
  have hl := laneOf_frag i.isLt j j.isLt
  unfold midOut
  rw [show rowOf g s i / 8 = 4 * g + s by unfold rowOf; omega, show rowOf g s i % 8 = fm i by unfold rowOf; omega, hl.1,
    fin32_val, show fin2 (fn i + j) = j from Fin.ext hl.2]

section Lane2
variable (C : M1Max.Contract) {L : Launch} {kg ku M : Nat} {I : In} {out : Nat → Nat → BF} {P g s : Nat} {ctx : Ctx}

/-- Lane `i` stopped at step `t`'s gate collective. -/
structure AtG (kg ku M : Nat) (I : In) (g s : Nat) (i : Fin 32) (t : Nat) (ctx : Ctx) (th : Thread) : Prop where
  hctx : th.ctx = ctx
  hfr : th.frames = .block posRestG :: framesQ kg ku
  pos : PosLoc kg ku M I g s i t th.locals
  accs : Accs C kg ku M I g s i t t th.locals
  l96 : th.locals 96 = some (.ptr ⟨rb g s i + 9, 0, .vec .f16 2⟩)
  l125 : th.locals 125 = some (.ptr ⟨rb g s i + 10, 0, .vec .f32 2⟩)

/-- Lane `i` stopped at step `t`'s up collective, `accG` after step `t`. -/
structure AtU (kg ku M : Nat) (I : In) (g s : Nat) (i : Fin 32) (t : Nat) (ctx : Ctx) (th : Thread) : Prop where
  hctx : th.ctx = ctx
  hfr : th.frames = .block [.set 27 (.local 127)] :: framesQ kg ku
  pos : PosLoc kg ku M I g s i t th.locals
  accs : Accs C kg ku M I g s i (t + 1) t th.locals

/-- After the barrier: to step 0's gate collective. -/
theorem lane_first (hS : Shape L kg ku M I) {i : Fin 32} (hl : Lane ctx g s i) (hKg : GateUp.Width kg)
    (hKu : GateUp.Width ku) (hM : 1 ≤ M) (hM8 : M ≤ 8) {l : Locals} (hF : Fix1 M s i l) {sh : Shared}
    (hm : Mem C L I M out P (g + 1) (fun _ => True) sh) :
    ∃ th sh', (Ev fun m => (runThread C m ⟨ctx, l, [.block (rest kg ku), .scope, .block []], .running⟩).run sh =
        some (th, sh')) ∧
      Mem C L I M out P (g + 1) (fun _ => True) sh' ∧ LaneArr kg ku I g s i 0 sh'.bytes ∧
      LaneAB C ku M I g s i 0 sh'.bytes ∧ Keeps (thr g s i) sh sh' ∧
      th.status = .collective 2 126 (.mma .f16 .f32) .f32 (mmaVal C kg M I.Gc I.X (4 * g + s) i 0) 0 ∧
      AtG C kg ku M I g s i 0 ctx th := by
  obtain ⟨l', sh', x, hm', harr, hab, hfr, hP, hacc, h96, h125⟩ := exec_rest C hS hl hKg hKu hM hM8 hF hm
  exact ⟨_, sh', (x.reaches_stop (K := [.scope, .block []])).ev_stop rfl, hm', harr, hab, hfr, rfl,
    ⟨rfl, rfl, hP, hacc, h96, h125⟩⟩

/-- Resumed with `accG` after step `t`: to step `t`'s up collective (memory untouched). -/
theorem lane_gate (hS : Shape L kg ku M I) {i : Fin 32} {t : Nat} {th : Thread} (hA : AtG C kg ku M I g s i t ctx th)
    {sh : Shared} (hreg : sh.regions = L.regions) (hab : LaneAB C ku M I g s i t sh.bytes) :
    ∃ th', (Ev fun m => (runThread C m ({ th with status := .running }.set 126
        (accVal (acc C kg I.Gc I.X M (4 * g + s) (t + 1)) i))).run sh = some (th', sh)) ∧
      th'.status = .collective 3 127 (.mma .f16 .f32) .f32 (mmaVal C ku M I.Uc I.X (4 * g + s) i t) 0 ∧
      AtU C kg ku M I g s i t ctx th' := by
  obtain ⟨tc, tl, tf, ts⟩ := th
  obtain ⟨hc, hf, hP, hacc, h96, h125⟩ := hA
  dsimp only at hc hf hP hacc h96 h125
  subst hc hf
  rw [resumed]
  generalize hv : accVal (acc C kg I.Gc I.X M (4 * g + s) (t + 1)) i = v
  generalize hl₁ : setLocal (setLocal tl 126 v) 26 v = l₁
  have h1 : ∀ x, x ≠ 26 → x ≠ 126 → l₁ x = tl x := fun x h26 h126 => by
    rw [← hl₁, setLocal_other _ _ h26, setLocal_other _ _ h126]
  have h96' : l₁ 96 = some (.ptr ⟨rb g s i + 9, 0, .vec .f16 2⟩) := by rw [h1 96 (by omega) (by omega)]; exact h96
  have h125' : l₁ 125 = some (.ptr ⟨rb g s i + 10, 0, .vec .f32 2⟩) := by rw [h1 125 (by omega) (by omega)]; exact h125
  have h27' : l₁ 27 = some (accVal (acc C ku I.Uc I.X M (4 * g + s) t) i) := by
    rw [h1 27 (by omega) (by omega)]; exact hacc.up
  have hcoll : (eval C tc l₁ (.vector .f32 [.load (.vec .f16 2) (.local 96), .load (.vec .f32 2) (.local 125),
      .local 27])).run sh = some (mmaVal C ku M I.Uc I.X (4 * g + s) i t, sh) := by
    have hA := (eval_load C _ _ _ _ _ _ _ (eval_local' C h96' sh)).trans
      (load_vec_f16 tc sh _ (by rw [hreg]; exact hS.ra _ 9 (by omega) (by omega)) _ _ hab.u0 hab.u1)
    have hB := (eval_load C _ _ _ _ _ _ _ (eval_local' C h125' sh)).trans
      (load_vec_f32 tc sh _ (by rw [hreg]; exact hS.rb _) _ _ hab.b0 hab.b1)
    exact eval_vector C (evalList_cons C hA (evalList_cons C hB (evalList_cons C (eval_local' C h27' sh)
      (evalList_nil C))))
  have hex : Exec C tc posRestG (setLocal tl 126 v) sh
      (.stop (.collective 3 127 (.mma .f16 .f32) .f32 (mmaVal C ku M I.Uc I.X (4 * g + s) i t) 0)
        [.block [.set 27 (.local 127)]]) l₁ sh :=
    Exec.set_eq C (eval_local' C (setLocal_same _ _ _) sh) hl₁
      (.collective hcoll (eval_lit C _ _ _ _) (natOf_unsigned 0 rfl))
  have hacc' : Accs C kg ku M I g s i (t + 1) t l₁ := ⟨by rw [← hl₁, setLocal_same, hv], h27'⟩
  exact ⟨_, (hex.reaches_stop (K := framesQ kg ku)).ev_stop rfl, rfl,
    ⟨rfl, rfl, hP.of_eq fun j hj h2 => h1 j (by omega) (by omega), hacc'⟩⟩

/-- Resumed with `accU` after step `t` (not the last): to step `t + 1`'s gate collective — the next position,
or the next chunk, or the next base step with its runs. -/
theorem lane_next (hS : Shape L kg ku M I) {i : Fin 32} (hl : Lane ctx g s i) (hKg : GateUp.Width kg)
    (hKu : GateUp.Width ku) (hM : 1 ≤ M) {t : Nat} (ht : t + 1 < 640) {th : Thread}
    (hU : AtU C kg ku M I g s i t ctx th) {sh : Shared} (hm : Mem C L I M out P (g + 1) (fun _ => True) sh)
    (harr : LaneArr kg ku I g s i (t / 32) sh.bytes) :
    ∃ th' sh', (Ev fun m => (runThread C m ({ th with status := .running }.set 127
        (accVal (acc C ku I.Uc I.X M (4 * g + s) (t + 1)) i))).run sh = some (th', sh')) ∧
      Mem C L I M out P (g + 1) (fun _ => True) sh' ∧ LaneArr kg ku I g s i ((t + 1) / 32) sh'.bytes ∧
      LaneAB C ku M I g s i (t + 1) sh'.bytes ∧ Keeps (thr g s i) sh sh' ∧
      th'.status = .collective 2 126 (.mma .f16 .f32) .f32 (mmaVal C kg M I.Gc I.X (4 * g + s) i (t + 1)) 0 ∧
      AtG C kg ku M I g s i (t + 1) ctx th' := by
  obtain ⟨tc, tl, tf, ts⟩ := th
  obtain ⟨hc, hf, hP, hacc⟩ := hU
  dsimp only at hc hf hP hacc
  subst hc hf
  rw [resumed]
  obtain ⟨hC, h93⟩ := hP
  generalize hv : accVal (acc C ku I.Uc I.X M (4 * g + s) (t + 1)) i = v
  generalize hl₁ : setLocal (setLocal tl 127 v) 27 v = l₁
  have h1 : ∀ x, x ≠ 27 → x ≠ 127 → l₁ x = tl x := fun x h27 h127 => by
    rw [← hl₁, setLocal_other _ _ h27, setLocal_other _ _ h127]
  have hrest : Exec C tc [.set 27 (.local 127)] (setLocal tl 127 v) sh .normal l₁ sh :=
    Exec.set_eq C (eval_local' C (setLocal_same _ _ _) sh) hl₁ (.nil _ _)
  have hacc₁ : Accs C kg ku M I g s i (t + 1) (t + 1) l₁ :=
    ⟨by rw [h1 26 (by omega) (by omega)]; exact hacc.gate, by rw [← hl₁, setLocal_same, hv]⟩
  have h193 : l₁ 93 = some (u32 (t % 8)) := by rw [h1 93 (by omega) (by omega)]; exact h93
  have hq : (eval C tc l₁ (cu .add (.local 93) (cl 1))).run sh = some (u32 (t % 8 + 1), sh) :=
    eval_bin_u32 C (eval_local' C h193 sh) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C _ 1)
  generalize hl₂ : setLocal l₁ 93 (u32 (t % 8 + 1)) = l₂
  have hstq : Exec C tc (GateUpCodebookMma.incr 93) l₁ sh .normal l₂ sh := Exec.set_eq C hq hl₂ (.nil _ _)
  have h293 : l₂ 93 = some (u32 (t % 8 + 1)) := by rw [← hl₂, setLocal_same]
  have h2 : ∀ x, x ≠ 93 → l₂ x = l₁ x := fun x hx => by rw [← hl₂, setLocal_other _ _ hx]
  have hcq : (eval C tc l₂ (GateUpCodebookMma.lt 93 8)).run sh = some (.bool (decide (t % 8 + 1 < 8)), sh) :=
    eval_lt_u32 C (ctx := tc) (sh := sh) (b := 8) h293 (by omega) (by decide)
  have hC₂ : ChunkLoc kg ku M I g s i (t / 32) (t % 32 / 8) l₂ :=
    hC.of_eq fun j hj h => by rw [h2 j (by omega), h1 j (by omega) (by omega)]
  have hacc₂ : Accs C kg ku M I g s i (t + 1) (t + 1) l₂ :=
    ⟨by rw [h2 26 (by omega)]; exact hacc₁.gate, by rw [h2 27 (by omega)]; exact hacc₁.up⟩
  by_cases h8 : t % 8 + 1 < 8
  · -- the next position
    rw [decide_eq_true h8] at hcq
    have hP' : PosLoc kg ku M I g s i (t + 1) l₂ :=
      ⟨by rw [show (t + 1) / 32 = t / 32 by omega, show (t + 1) % 32 / 8 = t % 32 / 8 by omega]; exact hC₂,
        by rw [show (t + 1) % 8 = t % 8 + 1 by omega]; exact h293⟩
    obtain ⟨l', sh', xp, hm', harr', hab', hfr', hag', h96, h125⟩ := exec_pos C hS hl hKg hKu ht hP' hacc₂ hm
      (by rw [show (t + 1) / 32 = t / 32 by omega]; exact harr)
    have hacc' : Accs C kg ku M I g s i (t + 1) (t + 1) l' :=
      ⟨by rw [hag' 26 (by omega)]; exact hacc₂.gate, by rw [hag' 27 (by omega)]; exact hacc₂.up⟩
    exact ⟨_, sh', (Exec.resume_stop (c := GateUpCodebookMma.lt 93 8) (st := GateUpCodebookMma.incr 93)
      (b := GateUpCodebookMma.positionBody kg ku) (ss := [])
      (K := [s8LoopF kg ku, .block [], baseLoopF kg ku, .block afterBase, .scope, .block []])
      hrest (.inl rfl) hstq hcq xp).ev_stop rfl, hm', harr', hab', hfr', rfl,
      ⟨rfl, rfl, hP'.of_eq fun j hj _ => hag' j hj, hacc', h96, h125⟩⟩
  · rw [decide_eq_false h8] at hcq
    have hrq := Exec.resume_exit (c := GateUpCodebookMma.lt 93 8) (st := GateUpCodebookMma.incr 93)
      (b := GateUpCodebookMma.positionBody kg ku) (ss := [])
      (K := [s8LoopF kg ku, .block [], baseLoopF kg ku, .block afterBase, .scope, .block []]) hrest (.inl rfl) hstq hcq
    have h290 : l₂ 90 = some (u32 (t % 32 / 8)) := hC₂.l90
    have h8e : (eval C tc l₂ (cu .add (.local 90) (cl 1))).run sh = some (u32 (t % 32 / 8 + 1), sh) :=
      eval_bin_u32 C (eval_local' C h290 sh) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C _ 1)
    generalize hl₃ : setLocal l₂ 90 (u32 (t % 32 / 8 + 1)) = l₃
    have hst8 : Exec C tc (GateUpCodebookMma.incr 90) l₂ sh .normal l₃ sh := Exec.set_eq C h8e hl₃ (.nil _ _)
    have h390 : l₃ 90 = some (u32 (t % 32 / 8 + 1)) := by rw [← hl₃, setLocal_same]
    have h3 : ∀ x, x ≠ 90 → l₃ x = l₂ x := fun x hx => by rw [← hl₃, setLocal_other _ _ hx]
    have hc8 : (eval C tc l₃ (GateUpCodebookMma.lt 90 4)).run sh =
        some (.bool (decide (t % 32 / 8 + 1 < 4)), sh) :=
      eval_lt_u32 C (ctx := tc) (sh := sh) (b := 4) h390 (by omega) (by decide)
    by_cases h32 : t % 32 / 8 + 1 < 4
    · -- the next chunk
      rw [decide_eq_true h32] at hc8
      have hst : StepLoc kg ku M g s i (t / 32) l₃ := hC₂.step.of_eq fun j hj h => by rw [h3 j (by omega)]
      have hacc₃ : Accs C kg ku M I g s i (32 * (t / 32) + 8 * (t % 32 / 8 + 1)) (32 * (t / 32) + 8 * (t % 32 / 8 + 1))
          l₃ := by
        rw [show 32 * (t / 32) + 8 * (t % 32 / 8 + 1) = t + 1 by omega]
        exact ⟨by rw [h3 26 (by omega)]; exact hacc₂.gate, by rw [h3 27 (by omega)]; exact hacc₂.up⟩
      obtain ⟨l', sh', xc, hm', harr', hab', hfr', hP', hacc', h96, h125⟩ :=
        exec_chunk C hS hl hKg hKu hM (b := t / 32) (s8 := t % 32 / 8 + 1) (by omega) h32 hst h390 hacc₃ hm harr
      rw [show 32 * (t / 32) + 8 * (t % 32 / 8 + 1) = t + 1 by omega] at xc hab' hP' hacc'
      refine ⟨_, sh', (hrq.trans (Exec.resume_stop (rest := []) (c := GateUpCodebookMma.lt 90 4)
        (st := GateUpCodebookMma.incr 90) (b := GateUpCodebookMma.chunkBody kg ku) (ss := [])
        (K := [baseLoopF kg ku, .block afterBase, .scope, .block []]) (.nil _ _) (.inl rfl) hst8 hc8 xc)).ev_stop rfl,
        hm', by rw [show (t + 1) / 32 = t / 32 by omega]; exact harr', hab', hfr', rfl, ⟨rfl, rfl, hP', hacc', h96, h125⟩⟩
    · -- the next base step
      rw [decide_eq_false h32] at hc8
      have hrs := Exec.resume_exit (rest := []) (c := GateUpCodebookMma.lt 90 4) (st := GateUpCodebookMma.incr 90)
        (b := GateUpCodebookMma.chunkBody kg ku) (ss := []) (K := [baseLoopF kg ku, .block afterBase, .scope, .block []])
        (.nil _ _) (.inl rfl) hst8 hc8
      have h328 : l₃ 28 = some (u32 (256 * (t / 32))) := by rw [h3 28 (by omega)]; exact hC₂.step.l28
      have hbe : (eval C tc l₃ (cu .add (.local 28) (cl 256))).run sh = some (u32 (256 * (t / 32 + 1)), sh) := by
        rw [show 256 * (t / 32 + 1) = 256 * (t / 32) + 256 by ring]
        exact eval_bin_u32 C (eval_local' C h328 sh) (eval_u32lit C _ _ 256 (by decide)) (binary_add_u32 C _ 256)
      generalize hl₄ : setLocal l₃ 28 (u32 (256 * (t / 32 + 1))) = l₄
      have hstB : Exec C tc baseStep l₃ sh .normal l₄ sh := Exec.set_eq C hbe hl₄ (.nil _ _)
      have h428 : l₄ 28 = some (u32 (256 * (t / 32 + 1))) := by rw [← hl₄, setLocal_same]
      have h4 : ∀ x, x ≠ 28 → l₄ x = l₃ x := fun x hx => by rw [← hl₄, setLocal_other _ _ hx]
      have hcB : (eval C tc l₄ baseCond).run sh = some (.bool true, sh) := by
        have := eval_lt_u32 C (ctx := tc) (sh := sh) (b := 5120) h428 (by omega) (by decide)
        rwa [decide_eq_true (show 256 * (t / 32 + 1) < 5120 by omega)] at this
      have hF₄ : Fix2 kg ku M g s i l₄ :=
        hC₂.step.fix.of_eq fun j hj => by rw [h4 j (by omega), h3 j (by omega)]
      have hacc₄ : Accs C kg ku M I g s i (32 * (t / 32 + 1)) (32 * (t / 32 + 1)) l₄ := by
        rw [show 32 * (t / 32 + 1) = t + 1 by omega]
        exact ⟨by rw [h4 26 (by omega), h3 26 (by omega)]; exact hacc₂.gate,
          by rw [h4 27 (by omega), h3 27 (by omega)]; exact hacc₂.up⟩
      obtain ⟨l', sh', xs, hm', harr', hab', hfr', hP', hacc', h96, h125⟩ :=
        exec_step C hS hl hKg hKu hM (b := t / 32 + 1) (by omega) hF₄ h428 hacc₄ hm
      rw [show 32 * (t / 32 + 1) = t + 1 by omega] at xs hab' hP' hacc'
      refine ⟨_, sh', (hrq.trans (hrs.trans (Exec.resume_stop (rest := []) (c := baseCond) (st := baseStep)
        (b := GateUpCodebookMma.stepBody kg ku) (ss := afterBase) (K := [.scope, .block []]) (.nil _ _) (.inl rfl) hstB hcB
        xs))).ev_stop rfl, hm', by rw [show (t + 1) / 32 = t / 32 + 1 by omega]; exact harr', hab', hfr', rfl,
        ⟨rfl, rfl, hP', hacc', h96, h125⟩⟩

end Lane2

/-! ### The outputs -/

theorem pair_get (D : Fin 32 → Fin 2 → Float32) (i : Fin 32) (j : Fin 2) :
    [Val.f32 (D i 0), Val.f32 (D i 1)][j.val % 2 ^ 32]? = some (.f32 (D i j)) := by
  rcases j with ⟨_ | _ | n, hj⟩
  · rfl
  · rfl
  · exact absurd hj (by omega)

section Out
variable (C : M1Max.Contract) {L : Launch} {kg ku M : Nat} {I : In} {out : Nat → Nat → BF} {g s : Nat} {ctx : Ctx}

/-- **One output element**: `m = fn + j`; past `M` the `continue`, else `gateT`, `upT`, `sigmoidT`, `siluT` and the
store of `mid[m][row]`. -/
theorem exec_outBody (hS : Shape L kg ku M I) {i : Fin 32} (hl : Lane ctx g s i) (hM8 : M ≤ 8) (j : Fin 2)
    {l : Locals} {sh : Shared} {ge : Nat} {cbOk : Nat → Prop} (hF : Fix2 kg ku M g s i l)
    (hacc : Accs C kg ku M I g s i 640 640 l) (h128 : l 128 = some (.f32 (rowScale C I.Gs (rowOf g s i))))
    (h129 : l 129 = some (.f32 (rowScale C I.Us (rowOf g s i)))) (h130 : l 130 = some (u32 j))
    (hout : ∀ m row, out m row = midOut C kg ku I.X I.Gc I.Gs I.Uc I.Us M m row)
    (hm : Mem C L I M out (64 * (4 * g + s) + 2 * i + j) ge cbOk sh) :
    ∃ o l' sh', (o = .normal ∨ o = .continue_) ∧ Exec C ctx GateUpCodebookMma.outBody l sh o l' sh' ∧
      Mem C L I M out (64 * (4 * g + s) + 2 * i + j + 1) ge cbOk sh' ∧ ∀ x, x ≤ 130 → l' x = l x := by
  have hi := i.isLt; have hj := j.isLt; have hg := hl.hg; have hs := hl.hs
  have hfn := fn_lt hi; have hf := fm_lt hi
  have hrow : rowOf g s i < 17408 := by unfold rowOf; omega
  have e131 : (eval C ctx l (cu .add (.local 20) (.local 130))).run sh = some (u32 (fn i + j), sh) :=
    eval_bin_u32 C (eval_local' C hF.l20 sh) (eval_local' C h130 sh) (binary_add_u32 C _ _)
  generalize hl₁ : setLocal l 131 (u32 (fn i + j)) = l₁
  have h1 : ∀ x, x ≠ 131 → l₁ x = l x := fun x hx => by rw [← hl₁, setLocal_other _ _ hx]
  have h1131 : l₁ 131 = some (u32 (fn i + j)) := by rw [← hl₁, setLocal_same]
  have h17 : l₁ 7 = some (u32 M) := by rw [h1 7 (by omega)]; exact hF.fix.l7
  have hc : (eval C ctx l₁ (cu .ge (.local 131) (.local 7))).run sh = some (.bool (decide (M ≤ fn i + j)), sh) :=
    eval_bin_u32 C (eval_local' C h1131 sh) (eval_local' C h17 sh) (binary_ge_u32 C _ M (by omega) (by omega))
  by_cases hmM : M ≤ fn i + j
  · rw [decide_eq_true hmM] at hc
    exact ⟨.continue_, l₁, sh, .inr rfl, Exec.set_eq C e131 hl₁ (.ite_exit hc .continue_ (.inl rfl)),
      hm.bump (T := 4 * g + s) hi hj hmM hM8 rfl, fun x hx => h1 x (by omega)⟩
  · rw [decide_eq_false hmM] at hc
    have h126 : l₁ 26 = some (accVal (acc C kg I.Gc I.X M (4 * g + s) 640) i) := by
      rw [h1 26 (by omega)]; exact hacc.gate
    have h127 : l₁ 27 = some (accVal (acc C ku I.Uc I.X M (4 * g + s) 640) i) := by
      rw [h1 27 (by omega)]; exact hacc.up
    have h1130 : l₁ 130 = some (u32 j) := by rw [h1 130 (by omega)]; exact h130
    have h1128 : l₁ 128 = some (.f32 (rowScale C I.Gs (rowOf g s i))) := by rw [h1 128 (by omega)]; exact h128
    have h1129 : l₁ 129 = some (.f32 (rowScale C I.Us (rowOf g s i))) := by rw [h1 129 (by omega)]; exact h129
    generalize hG : C.narrow (C.fmul (acc C kg I.Gc I.X M (4 * g + s) 640 i j) (rowScale C I.Gs (rowOf g s i))) = gT
    generalize hU : C.narrow (C.fmul (acc C ku I.Uc I.X M (4 * g + s) 640 i j) (rowScale C I.Us (rowOf g s i))) = uT
    have e132 : (eval C ctx l₁ (.conv .bf16 (.bin .mul .f32 0 (.component (.local 26) (.local 130)) (.local 128)))).run sh =
        some (.bf16 gT, sh) := by
      rw [← hG]
      exact eval_conv C (t := .bf16) (eval_f32 C (.inl ⟨by decide, by decide⟩)
        (eval_component C (eval_local' C h126 sh) (eval_local' C h1130 sh) (natOf_u32 j) (pair_get _ i j))
        (eval_local' C h1128 sh) rfl) rfl
    generalize hl₂ : setLocal l₁ 132 (.bf16 gT) = l₂
    have h2 : ∀ x, x ≠ 132 → l₂ x = l₁ x := fun x hx => by rw [← hl₂, setLocal_other _ _ hx]
    have e133 : (eval C ctx l₂ (.conv .bf16 (.bin .mul .f32 0 (.component (.local 27) (.local 130)) (.local 129)))).run sh =
        some (.bf16 uT, sh) := by
      rw [← hU]
      exact eval_conv C (t := .bf16) (eval_f32 C (.inl ⟨by decide, by decide⟩)
        (eval_component C (eval_local' C (by rw [h2 27 (by omega)]; exact h127) sh)
          (eval_local' C (by rw [h2 130 (by omega)]; exact h1130) sh) (natOf_u32 j) (pair_get _ i j))
        (eval_local' C (by rw [h2 129 (by omega)]; exact h1129) sh) rfl) rfl
    generalize hl₃ : setLocal l₂ 133 (.bf16 uT) = l₃
    have h3 : ∀ x, x ≠ 133 → l₃ x = l₂ x := fun x hx => by rw [← hl₃, setLocal_other _ _ hx]
    have h3132 : l₃ 132 = some (.bf16 gT) := by rw [h3 132 (by omega), ← hl₂, setLocal_same]
    generalize hσ : C.narrow (C.fdiv GateUp.one (C.fadd GateUp.one (C.exp (f32Neg (C.widen gT))))) = sg
    have e134 : (eval C ctx l₃ (.conv .bf16 (.bin .div .f32 0 (GateUpCodebookMma.f32l 0x3F800000)
        (.bin .add .f32 0 (GateUpCodebookMma.f32l 0x3F800000)
          (.un .exp .f32 (.un .neg .f32 (.conv .f32 (.local 132)))))))).run sh = some (.bf16 sg, sh) := by
      rw [← hσ]
      exact eval_conv C (t := .bf16) (eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_lit C _ _ _ _)
        (eval_f32 C (.inr ⟨rfl, rfl⟩) (eval_lit C _ _ _ _) (eval_un C (eval_un C (eval_conv C (t := .f32)
          (eval_local' C h3132 sh) rfl) rfl) rfl) rfl) rfl) rfl
    generalize hl₄ : setLocal l₃ 134 (.bf16 sg) = l₄
    have h4 : ∀ x, x ≠ 134 → l₄ x = l₃ x := fun x hx => by rw [← hl₄, setLocal_other _ _ hx]
    have e135 : (eval C ctx l₄ (.bin .mul .bf16 0 (.local 132) (.local 134))).run sh = some (.bf16 (C.bfmul gT sg), sh) :=
      eval_bin_plain C (.inl ⟨by decide, by decide⟩) (eval_local' C (by rw [h4 132 (by omega)]; exact h3132) sh)
        (eval_local' C (by rw [← hl₄, setLocal_same]) sh) rfl
    generalize hl₅ : setLocal l₄ 135 (.bf16 (C.bfmul gT sg)) = l₅
    have h5 : ∀ x, x < 131 → l₅ x = l x := fun x hx => by
      rw [← hl₅, setLocal_other _ _ (by omega), h4 x (by omega), h3 x (by omega), h2 x (by omega), h1 x (by omega)]
    have hval : (eval C ctx l₅ (.bin .mul .bf16 0 (.local 135) (.local 133))).run sh =
        some (.bf16 (out (fn i + j) (rowOf g s i)), sh) := by
      rw [hout, midOut_lane]
      simp only [silu]
      rw [hG, hU, hσ]
      exact eval_bin_plain C (.inl ⟨by decide, by decide⟩) (eval_local' C (by rw [← hl₅, setLocal_same]) sh)
        (eval_local' C (by rw [← hl₅, setLocal_other _ _ (by omega), h4 133 (by omega), ← hl₃, setLocal_same]) sh) rfl
    -- the address
    have h5131 : l₅ 131 = some (u32 (fn i + j)) := by
      rw [← hl₅, setLocal_other _ _ (by omega), h4 131 (by omega), h3 131 (by omega), h2 131 (by omega)]; exact h1131
    have h521 : l₅ 21 = some (u32 (rowOf g s i)) := by rw [h5 21 (by omega)]; exact hF.l21
    have hidx : (eval C ctx l₅ (GateUpCodebookMma.u64 .add (GateUpCodebookMma.u64 .mul (GateUpCodebookMma.toU64 (.local 131))
        (GateUpCodebookMma.u64l 17408)) (GateUpCodebookMma.toU64 (.local 21)))).run sh =
        some (u64 ((fn i + j) * 17408 + rowOf g s i), sh) :=
      eval_int C (by decide) (eval_int C (by decide) (eval_conv C (t := .u64) (eval_local' C h5131 sh)
        (convert_u64_u32 C _ (by omega))) (by rw [← u64_lit (show 17408 < 2 ^ 64 by decide)]; exact eval_lit C _ _ _ _)
        (binary_mul_u64 C _ _))
        (eval_conv C (t := .u64) (eval_local' C h521 sh) (convert_u64_u32 C (rowOf g s i) (by unfold rowOf; omega))) (binary_add_u64 C _ _)
    have h56 : l₅ 6 = some (.ptr ⟨6, 0, .scalar .bf16⟩) := by rw [h5 6 (by omega)]; exact hF.fix.fix0.l6
    have hp := eval_offset_u64 C (o := 0) (eval_local' C h56 sh) hidx (by omega)
    rw [show 0 + ((fn i + j) * 17408 + rowOf g s i) * (Ty.scalar .bf16).bytes = 2 * (17408 * (fn i + j) + rowOf g s i) by
      simp only [Ty.bytes, Scalar.bytes]; ring] at hp
    have hst := store_shared ctx .bf16 sh 6 (2 * (17408 * (fn i + j) + rowOf g s i)) _ _ _ (by rw [hm.regions]; exact hS.r6)
      (by simp) (by simp) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega)
      (encode_bf16 (out (fn i + j) (rowOf g s i)))
    rw [show Scalar.bf16.bytes = 2 from rfl] at hst
    have hm' := hm.wmid hS ctx (T := 4 * g + s) (l := i) (e := j) (by omega) hi hj (by omega) hM8 rfl
      (by rw [hl.thread]; ring) (by rw [hl.group]; omega)
    refine ⟨.normal, l₅, _, .inl rfl, Exec.set_eq C e131 hl₁ (.ite hc (.nil _ _) (Exec.set_eq C e132 hl₂
      (Exec.set_eq C e133 hl₃ (Exec.set_eq C e134 hl₄ (Exec.set_eq C e135 hl₅ (.store hp hval hst (.nil _ _))))))),
      hm', fun x hx => ?_⟩
    by_cases hx' : x < 131
    · exact h5 x hx'
    · omega

end Out

section Last
variable (C : M1Max.Contract) {L : Launch} {kg ku M : Nat} {I : In} {out : Nat → Nat → BF} {g s : Nat} {ctx : Ctx}

/-- `float(scales[row]) * TRELLIS_RCP` from scales buffer `reg`. -/
theorem eval_rowScale (reg : Nat) (S : ByteMemory.Bytes) (al : Nat)
    (hr : L.regions reg = some ⟨.device, 34816, al⟩) (hal : al % 2 = 0) {row : Nat} (hrow : row < 17408)
    {l : Locals} {sh : Shared} {P ge : Nat} {cbOk : Nat → Prop} (hm : Mem C L I M out P ge cbOk sh)
    (hb : sh.bytes reg = S) (hp : l reg = some (.ptr ⟨reg, 0, .scalar .f16⟩)) (h21 : l 21 = some (u32 row)) :
    (eval C ctx l (.bin .mul .f32 0 (.conv .f32 (.load (.scalar .f16) (.offset (.local reg) (.local 21))))
      (GateUpCodebookMma.f32l 0x3BDDB447))).run sh = some (.f32 (rowScale C S row), rdn ctx sh reg (2 * row) 2) := by
  have hp' := eval_ptr_u32 C (ctx := ctx) (eval_local' C hp sh) (eval_local' C h21 sh) (by omega)
  rw [show row * (Ty.scalar .f16).bytes = 2 * row by simp only [Ty.bytes, Scalar.bytes]; ring] at hp'
  have hld := load_shared ctx .f16 sh reg (2 * row) _ (by rw [hm.regions]; exact hr) (by simp)
    (by simpa [Scalar.bytes] using hal) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (by simp [loadOffset])
  rw [hb] at hld
  exact eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_conv C (t := .f32) ((eval_load C _ _ _ _ _ _ _ hp').trans hld) rfl)
    (eval_lit C _ _ _ _) rfl

/-- At the `k`-th test of the output loop. -/
def OutI (L : Launch) (kg ku M : Nat) (I : In) (out : Nat → Nat → BF) (g s : Nat) (i : Fin 32) (k : Nat) (l : Locals)
    (sh : Shared) : Prop :=
  Fix2 kg ku M g s i l ∧ Accs C kg ku M I g s i 640 640 l ∧
    l 128 = some (.f32 (rowScale C I.Gs (rowOf g s i))) ∧ l 129 = some (.f32 (rowScale C I.Us (rowOf g s i))) ∧
    l 130 = some (u32 k) ∧ Mem C L I M out (64 * (4 * g + s) + 2 * i + k) (g + 1) (fun _ => True) sh

/-- **After the last step**: the scales, then `mid[fn + j][row]` for `j < 2` (those below `M`). -/
theorem exec_after (hS : Shape L kg ku M I) {i : Fin 32} (hl : Lane ctx g s i) (hM8 : M ≤ 8) {l : Locals}
    {sh : Shared} (hF : Fix2 kg ku M g s i l) (hacc : Accs C kg ku M I g s i 640 640 l)
    (hout : ∀ m row, out m row = midOut C kg ku I.X I.Gc I.Gs I.Uc I.Us M m row)
    (hm : Mem C L I M out (64 * (4 * g + s) + 2 * i) (g + 1) (fun _ => True) sh) :
    ∃ l' sh', Exec C ctx afterBase l sh .normal l' sh' ∧
      Mem C L I M out (64 * (4 * g + s) + 2 * i + 2) (g + 1) (fun _ => True) sh' := by
  have hi := i.isLt; have hg := hl.hg; have hs := hl.hs; have hf := fm_lt hi
  have hrow : rowOf g s i < 17408 := by unfold rowOf; omega
  have e128 := eval_rowScale C (ctx := ctx) 3 I.Gs I.as hS.r3 hS.as hrow hm hm.gs hF.fix.fix0.l3 hF.l21
  have hm₁ := hm.rd ctx 3 (2 * rowOf g s i) 2 (.inl (by decide)) hS
  generalize hl₁ : setLocal l 128 (.f32 (rowScale C I.Gs (rowOf g s i))) = l₁
  have h1 : ∀ x, x ≠ 128 → l₁ x = l x := fun x hx => by rw [← hl₁, setLocal_other _ _ hx]
  have e129 := eval_rowScale C (ctx := ctx) (l := l₁) 5 I.Us I.aus hS.r5 hS.aus hrow hm₁ hm₁.us
    (by rw [h1 5 (by omega)]; exact hF.fix.fix0.l5) (by rw [h1 21 (by omega)]; exact hF.l21)
  have hm₂ := hm₁.rd ctx 5 (2 * rowOf g s i) 2 (.inl (by decide)) hS
  generalize hl₂ : setLocal l₁ 129 (.f32 (rowScale C I.Us (rowOf g s i))) = l₂
  generalize hl₃ : setLocal l₂ 130 (u32 0) = l₃
  have h3 : ∀ x, x < 128 → l₃ x = l x := fun x hx => by
    rw [← hl₃, setLocal_other _ _ (by omega), ← hl₂, setLocal_other _ _ (by omega), h1 x (by omega)]
  have h0 : OutI C L kg ku M I out g s i 0 l₃ (rdn ctx (rdn ctx sh 3 (2 * rowOf g s i) 2) 5 (2 * rowOf g s i) 2) :=
    ⟨hF.of_eq fun j hj => h3 j (by omega), ⟨by rw [h3 26 (by omega)]; exact hacc.gate, by rw [h3 27 (by omega)]; exact hacc.up⟩,
      by rw [← hl₃, setLocal_other _ _ (by omega), ← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_same],
      by rw [← hl₃, setLocal_other _ _ (by omega), ← hl₂, setLocal_same], by rw [← hl₃, setLocal_same],
      by rw [Nat.add_zero]; exact hm₂⟩
  obtain ⟨l', sh', xl, hI⟩ := Exec.loop_count (c := GateUpCodebookMma.lt 130 2) (st := GateUpCodebookMma.incr 130)
    (b := GateUpCodebookMma.outBody) (ctx := ctx) (C := C) 2 (OutI C L kg ku M I out g s i) (OutI C L kg ku M I out g s i)
    (fun k hk l sh hI => ⟨sh, by
      have := eval_lt_u32 C (ctx := ctx) (sh := sh) (b := 2) hI.2.2.2.2.1 (by omega) (by decide)
      exact this, hI⟩)
    (fun k hk l sh hI => by
      obtain ⟨hF', hacc', h128, h129, h130, hm'⟩ := hI
      obtain ⟨o, l₁, sh₁, ho, xb, hm₁', hag⟩ := exec_outBody C hS hl hM8 ⟨k, hk⟩ hF' hacc' h128 h129 h130 hout hm'
      have h130' : l₁ 130 = some (u32 k) := by rw [hag 130 (by omega)]; exact h130
      refine ⟨o, l₁, sh₁, setLocal l₁ 130 (u32 (k + 1)), sh₁, ho, xb,
        .set (eval_bin_u32 C (eval_local' C h130' _) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C k 1)) (.nil _ _),
        hF'.of_eq fun j hj => by rw [setLocal_other _ _ (by omega), hag j (by omega)], ?_, ?_, ?_, setLocal_same _ _ _, ?_⟩
      · exact ⟨by rw [setLocal_other _ _ (by omega), hag 26 (by omega)]; exact hacc'.gate,
          by rw [setLocal_other _ _ (by omega), hag 27 (by omega)]; exact hacc'.up⟩
      · rw [setLocal_other _ _ (by omega), hag 128 (by omega)]; exact h128
      · rw [setLocal_other _ _ (by omega), hag 129 (by omega)]; exact h129
      · rw [← Nat.add_assoc]; exact hm₁')
    h0
  refine ⟨l', sh', ?_, hI.2.2.2.2.2⟩
  exact Exec.set_eq C e128 hl₁ (Exec.set_eq C e129 hl₂ (Exec.set_eq C (eval_u32lit C _ _ 0 (by decide)) hl₃ xl))

/-- Resumed with `accU` after the last step: the loops end, the lane writes its elements of `mid` and is done. -/
theorem lane_last (hS : Shape L kg ku M I) {i : Fin 32} (hl : Lane ctx g s i) (hM8 : M ≤ 8) {th : Thread}
    (hU : AtU C kg ku M I g s i 639 ctx th) (hout : ∀ m row, out m row = midOut C kg ku I.X I.Gc I.Gs I.Uc I.Us M m row)
    {sh : Shared} (hm : Mem C L I M out (64 * (4 * g + s) + 2 * i) (g + 1) (fun _ => True) sh) :
    ∃ th' sh', (Ev fun m => (runThread C m ({ th with status := .running }.set 127
        (accVal (acc C ku I.Uc I.X M (4 * g + s) 640) i))).run sh = some (th', sh')) ∧
      Mem C L I M out (64 * (4 * g + s) + 2 * i + 2) (g + 1) (fun _ => True) sh' ∧ th'.status = .done := by
  obtain ⟨tc, tl, tf, ts⟩ := th
  obtain ⟨hc, hf, hP, hacc⟩ := hU
  dsimp only at hc hf hP hacc
  subst hc hf
  rw [resumed]
  obtain ⟨hC, h93⟩ := hP
  generalize hv : accVal (acc C ku I.Uc I.X M (4 * g + s) 640) i = v
  generalize hl₁ : setLocal (setLocal tl 127 v) 27 v = l₁
  have h1 : ∀ x, x ≠ 27 → x ≠ 127 → l₁ x = tl x := fun x h27 h127 => by
    rw [← hl₁, setLocal_other _ _ h27, setLocal_other _ _ h127]
  have hrest : Exec C tc [.set 27 (.local 127)] (setLocal tl 127 v) sh .normal l₁ sh :=
    Exec.set_eq C (eval_local' C (setLocal_same _ _ _) sh) hl₁ (.nil _ _)
  have h193 : l₁ 93 = some (u32 (639 % 8)) := by rw [h1 93 (by omega) (by omega)]; exact h93
  generalize hl₂ : setLocal l₁ 93 (u32 (639 % 8 + 1)) = l₂
  have hstq : Exec C tc (GateUpCodebookMma.incr 93) l₁ sh .normal l₂ sh :=
    Exec.set_eq C (eval_bin_u32 C (eval_local' C h193 sh) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C _ 1)) hl₂
      (.nil _ _)
  have h2 : ∀ x, x ≠ 93 → l₂ x = l₁ x := fun x hx => by rw [← hl₂, setLocal_other _ _ hx]
  have hcq : (eval C tc l₂ (GateUpCodebookMma.lt 93 8)).run sh = some (.bool false, sh) :=
    eval_lt_u32 C (ctx := tc) (sh := sh) (a := 639 % 8 + 1) (b := 8) (by rw [← hl₂, setLocal_same]) (by decide) (by decide)
  have hrq := Exec.resume_exit (c := GateUpCodebookMma.lt 93 8) (st := GateUpCodebookMma.incr 93)
    (b := GateUpCodebookMma.positionBody kg ku) (ss := [])
    (K := [s8LoopF kg ku, .block [], baseLoopF kg ku, .block afterBase, .scope, .block []]) hrest (.inl rfl) hstq hcq
  have h290 : l₂ 90 = some (u32 (639 % 32 / 8)) := by rw [h2 90 (by omega), h1 90 (by omega) (by omega)]; exact hC.l90
  generalize hl₃ : setLocal l₂ 90 (u32 (639 % 32 / 8 + 1)) = l₃
  have hst8 : Exec C tc (GateUpCodebookMma.incr 90) l₂ sh .normal l₃ sh :=
    Exec.set_eq C (eval_bin_u32 C (eval_local' C h290 sh) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C _ 1)) hl₃
      (.nil _ _)
  have h3 : ∀ x, x ≠ 90 → l₃ x = l₂ x := fun x hx => by rw [← hl₃, setLocal_other _ _ hx]
  have hc8 : (eval C tc l₃ (GateUpCodebookMma.lt 90 4)).run sh = some (.bool false, sh) :=
    eval_lt_u32 C (ctx := tc) (sh := sh) (a := 639 % 32 / 8 + 1) (b := 4) (by rw [← hl₃, setLocal_same]) (by decide) (by decide)
  have hrs := Exec.resume_exit (rest := []) (c := GateUpCodebookMma.lt 90 4) (st := GateUpCodebookMma.incr 90)
    (b := GateUpCodebookMma.chunkBody kg ku) (ss := []) (K := [baseLoopF kg ku, .block afterBase, .scope, .block []])
    (.nil _ _) (.inl rfl) hst8 hc8
  have h328 : l₃ 28 = some (u32 (256 * (639 / 32))) := by
    rw [h3 28 (by omega), h2 28 (by omega), h1 28 (by omega) (by omega)]; exact hC.step.l28
  generalize hl₄ : setLocal l₃ 28 (u32 (256 * (639 / 32) + 256)) = l₄
  have hstB : Exec C tc baseStep l₃ sh .normal l₄ sh :=
    Exec.set_eq C (eval_bin_u32 C (eval_local' C h328 sh) (eval_u32lit C _ _ 256 (by decide)) (binary_add_u32 C _ 256)) hl₄
      (.nil _ _)
  have h4 : ∀ x, x ≠ 28 → l₄ x = l₃ x := fun x hx => by rw [← hl₄, setLocal_other _ _ hx]
  have hcB : (eval C tc l₄ baseCond).run sh = some (.bool false, sh) :=
    eval_lt_u32 C (ctx := tc) (sh := sh) (a := 256 * (639 / 32) + 256) (b := 5120) (by rw [← hl₄, setLocal_same]) (by decide) (by decide)
  have hrb := Exec.resume_exit (rest := []) (c := baseCond) (st := baseStep) (b := GateUpCodebookMma.stepBody kg ku)
    (ss := afterBase) (K := [.scope, .block []]) (.nil _ _) (.inl rfl) hstB hcB
  have h4b : ∀ x, x ≤ 26 → l₄ x = tl x := fun x hx => by
    rw [h4 x (by omega), h3 x (by omega), h2 x (by omega), h1 x (by omega) (by omega)]
  have hF₄ : Fix2 kg ku M g s i l₄ := hC.step.fix.of_eq fun j hj => h4b j (by omega)
  have hacc₄ : Accs C kg ku M I g s i 640 640 l₄ :=
    ⟨by rw [h4 26 (by omega), h3 26 (by omega), h2 26 (by omega), h1 26 (by omega) (by omega)]; exact hacc.gate,
      by rw [h4 27 (by omega), h3 27 (by omega), h2 27 (by omega), ← hl₁, setLocal_same, ← hv]⟩
  obtain ⟨l', sh', xa, hm'⟩ := exec_after C hS hl hM8 hF₄ hacc₄ hout hm
  refine ⟨⟨tc, l', [], .done⟩, sh', (hrq.trans (hrs.trans (hrb.trans (xa.reaches_normal.trans
    (.cons rfl (step_scope_pop C) (.cons rfl (step_pop C) (.single rfl (step_done C)))))))).ev_stop rfl, hm', rfl⟩

end Last

/-! ## SIMD-groups, threadgroups, the launch -/

section Simd
variable (C : M1Max.Contract) {L : Launch} {kg ku M : Nat} {I : In} {out : Nat → Nat → BF} {g s : Nat}

theorem thr_ne {g s : Nat} {i j : Fin 32} (h : j ≠ i) : thr g s j ≠ thr g s i := by
  intro e; apply h; apply Fin.ext; unfold thr at e; omega

/-- The gate round of step `t + 1`'s lanes: lanes before `idx` have run to it, the others still hold step `t`'s runs. -/
def GateI (kg ku M : Nat) (I : In) (out : Nat → Nat → BF) (L : Launch) (g s t : Nat) (idx : Nat) (sh : Shared) : Prop :=
  Mem C L I M out (64 * (4 * g + s)) (g + 1) (fun _ => True) sh ∧
    ∀ j : Fin 32, (j.val < idx → LaneArr kg ku I g s j ((t + 1) / 32) sh.bytes ∧ LaneAB C ku M I g s j (t + 1) sh.bytes) ∧
      (idx ≤ j.val → LaneArr kg ku I g s j (t / 32) sh.bytes)

/-- **The steps after step `t`'s up collective**: from the lanes stopped there, the rest of the SIMD-group's run. -/
theorem simd_steps (hS : Shape L kg ku M I) (hKg : GateUp.Width kg) (hKu : GateUp.Width ku) (hM : 1 ≤ M) (hM8 : M ≤ 8)
    (ctxs : Fin 32 → Ctx) (hL : ∀ i : Fin 32, Lane (ctxs i) g s i)
    (hout : ∀ m row, out m row = midOut C kg ku I.X I.Gc I.Gs I.Uc I.Us M m row) :
    ∀ n t, t + n = 639 → ∀ (U : Fin 32 → Thread), (∀ i, AtU C kg ku M I g s i t (ctxs i) (U i)) →
      ∀ sh, Mem C L I M out (64 * (4 * g + s)) (g + 1) (fun _ => True) sh →
        (∀ i : Fin 32, LaneArr kg ku I g s i (t / 32) sh.bytes) →
      ∃ (V : Fin 32 → Thread) (sh' : Shared),
        (Ev fun m => (runSimd C m (2 * n + 1) (List.ofFn fun i => { U i with status := .running }.set 127
          (accVal (acc C ku I.Uc I.X M (4 * g + s) (t + 1)) i))).run sh = some (List.ofFn V, sh')) ∧
        Mem C L I M out (64 * (4 * g + s) + 64) (g + 1) (fun _ => True) sh' ∧ ∀ i, (V i).status = .done := by
  intro n
  induction n with
  | zero =>
    intro t ht U hU sh hm _
    obtain rfl : t = 639 := by omega
    obtain ⟨V, sh', hr, hI, hR⟩ := runSimd_blocked_ev C 0 _
      (fun idx sh => Mem C L I M out (64 * (4 * g + s) + 2 * idx) (g + 1) (fun _ => True) sh)
      (fun _ t => t.status = .done) (fun i sh hI => by
        obtain ⟨t', sh', he, hm', hst⟩ := lane_last C hS (hL i) hM8 (hU i) hout hI
        exact ⟨t', sh', he, by rw [show 64 * (4 * g + s) + 2 * (i.val + 1) = 64 * (4 * g + s) + 2 * i + 2 by ring]; exact hm',
          by rw [hst]; rfl, hst⟩) sh (by rw [Nat.mul_zero, Nat.add_zero]; exact hm)
    exact ⟨V, sh', hr, by rw [show 64 * (4 * g + s) + 64 = 64 * (4 * g + s) + 2 * 32 by ring]; exact hI, hR⟩
  | succ n ih =>
    intro t ht U hU sh hm harr
    show ∃ V sh', (Ev fun m => (runSimd C m (2 * n + 2 + 1) _).run sh = some (List.ofFn V, sh')) ∧ _
    refine runSimd_collective_ev C (2 * n + 2) _ 2 126 (.mma .f16 .f32) .f32 0
      (fun i => mmaVal C kg M I.Gc I.X (4 * g + s) i (t + 1))
      (fun i => accVal (acc C kg I.Gc I.X M (4 * g + s) (t + 1 + 1)) i)
      (resolve_mma_halfA C 0 (aReg C kg I.Gc (4 * g + s) (t + 1)) (bReg C I.X M (t + 1))
        (acc C kg I.Gc I.X M (4 * g + s) (t + 1)))
      (GateI C kg ku M I out L g s t) (fun i th => AtG C kg ku M I g s i (t + 1) (ctxs i) th)
      (Mem C L I M out (64 * (4 * g + s) + 64) (g + 1) (fun _ => True)) (fun _ th => th.status = .done)
      (fun i sh hI => ?_) (fun U' sh₁ hU' hI₁ => ?_) sh ⟨hm, fun j => ⟨fun h => absurd h (by omega), fun _ => harr j⟩⟩
    · obtain ⟨hmI, hlanes⟩ := hI
      obtain ⟨t', sh', he, hm', harr', hab', hfr, hst, hat⟩ :=
        lane_next C hS (hL i) hKg hKu hM (by omega) (hU i) hmI ((hlanes i).2 le_rfl)
      refine ⟨t', sh', he, ⟨hm', fun j => ⟨fun hj => ?_, fun hj => ?_⟩⟩, hst, hat⟩
      · by_cases hji : j = i
        · subst hji; exact ⟨harr', hab'⟩
        · have hj' : j.val < i.val := by
            have : j.val ≠ i.val := fun h => hji (Fin.ext h)
            omega
          obtain ⟨ha, hb⟩ := (hlanes j).1 hj'
          exact ⟨ha.frame hfr (thr_ne hji), hb.frame hfr (thr_ne hji)⟩
      · have hji : j ≠ i := fun h => by rw [h] at hj; omega
        exact ((hlanes j).2 (by omega)).frame hfr (thr_ne hji)
    · obtain ⟨hm₁, hl₁⟩ := hI₁
      refine runSimd_collective_ev C (2 * n + 1) _ 3 127 (.mma .f16 .f32) .f32 0
        (fun i => mmaVal C ku M I.Uc I.X (4 * g + s) i (t + 1))
        (fun i => accVal (acc C ku I.Uc I.X M (4 * g + s) (t + 1 + 1)) i)
        (resolve_mma_halfA C 0 (aReg C ku I.Uc (4 * g + s) (t + 1)) (bReg C I.X M (t + 1))
          (acc C ku I.Uc I.X M (4 * g + s) (t + 1)))
        (fun _ sh => sh = sh₁) (fun i th => AtU C kg ku M I g s i (t + 1) (ctxs i) th)
        (Mem C L I M out (64 * (4 * g + s) + 64) (g + 1) (fun _ => True)) (fun _ th => th.status = .done)
        (fun i sh hI => ?_) (fun U'' sh₂ hU'' hI₂ => ?_) sh₁ rfl
      · subst hI
        obtain ⟨t', he, hst, hat⟩ := lane_gate C hS (hU' i) hm₁.regions ((hl₁ i).1 i.isLt).2
        exact ⟨t', sh, he, rfl, hst, hat⟩
      · subst hI₂
        exact ih (t + 1) (by omega) U'' hU'' sh₂ hm₁ fun j => ((hl₁ j).1 j.isLt).1

/-- A lane at the barrier. -/
def AtBar (kg ku M s : Nat) (i : Fin 32) (ctx : Ctx) (t : Thread) : Prop :=
  t.status = .barrier 1 false true ∧ t.ctx = ctx ∧ t.frames = [.block (rest kg ku), .scope, .block []] ∧
    Fix1 M s i t.locals

/-- SIMD-group `s` to the barrier: its lanes' codebook entries. -/
theorem simd_phase1 (hS : Shape L kg ku M I) (hM : bytesWord (cells I.S 0 4) = M) (hM8 : M ≤ 8) (ctxs : Fin 32 → Ctx)
    (hL : ∀ i : Fin 32, Lane (ctxs i) g s i) {P : Nat} {sh : Shared}
    (hm : Mem C L I M out P g (fun e => e % 128 < 32 * s) sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m 1281 (List.ofFn fun i =>
        (⟨ctxs i, fun _ => none, [.block (GateUpCodebookMma.body kg ku)], .running⟩ : Thread))).run sh =
          some (List.ofFn V, sh')) ∧
      Mem C L I M out P g (fun e => e % 128 < 32 * (s + 1)) sh' ∧
      ∀ i, (V i).status = .barrier 1 false true ∧ AtBar kg ku M s i (ctxs i) (V i) := by
  obtain ⟨V, sh', hr, hI, hR⟩ := runSimd_blocked_ev C 1280 _
    (fun idx sh => Mem C L I M out P g (fun e => e % 128 < 32 * s + idx) sh)
    (fun i t => t.status = .barrier 1 false true ∧ AtBar kg ku M s i (ctxs i) t) (fun i sh hI => by
      obtain ⟨t, sh', he, hm', hst, hc, hf, hF⟩ := lane_phase1 C hS (hL i) hM hM8 hI
      exact ⟨t, sh', he, hm', by rw [hst]; rfl, hst, hst, hc, hf, hF⟩) sh (by simpa using hm)
  exact ⟨V, sh', hr, by simpa [Nat.mul_add] using hI, hR⟩

/-- SIMD-group `s` after the barrier: its 640 steps and its elements of `mid`. -/
theorem simd_phase2 (hS : Shape L kg ku M I) (hKg : GateUp.Width kg) (hKu : GateUp.Width ku) (hM : 1 ≤ M) (hM8 : M ≤ 8)
    (ctxs : Fin 32 → Ctx) (hL : ∀ i : Fin 32, Lane (ctxs i) g s i)
    (hout : ∀ m row, out m row = midOut C kg ku I.X I.Gc I.Gs I.Uc I.Us M m row)
    (U : Fin 32 → Thread) (hU : ∀ i, AtBar kg ku M s i (ctxs i) (U i)) {sh : Shared}
    (hm : Mem C L I M out (64 * (4 * g + s)) (g + 1) (fun _ => True) sh) :
    ∃ (V : Fin 32 → Thread) (sh' : Shared),
      (Ev fun m => (runSimd C m 1281 (List.ofFn fun i => { U i with status := .running })).run sh =
        some (List.ofFn V, sh')) ∧
      Mem C L I M out (64 * (4 * g + s) + 64) (g + 1) (fun _ => True) sh' ∧ ∀ i, (V i).status = .done := by
  refine runSimd_collective_ev C 1280 _ 2 126 (.mma .f16 .f32) .f32 0
    (fun i => mmaVal C kg M I.Gc I.X (4 * g + s) i 0)
    (fun i => accVal (acc C kg I.Gc I.X M (4 * g + s) (0 + 1)) i)
    (resolve_mma_halfA C 0 (aReg C kg I.Gc (4 * g + s) 0) (bReg C I.X M 0) (acc C kg I.Gc I.X M (4 * g + s) 0))
    (fun idx sh => Mem C L I M out (64 * (4 * g + s)) (g + 1) (fun _ => True) sh ∧
      ∀ j : Fin 32, j.val < idx → LaneArr kg ku I g s j 0 sh.bytes ∧ LaneAB C ku M I g s j 0 sh.bytes)
    (fun i th => AtG C kg ku M I g s i 0 (ctxs i) th)
    (Mem C L I M out (64 * (4 * g + s) + 64) (g + 1) (fun _ => True)) (fun _ th => th.status = .done)
    (fun i sh hI => ?_) (fun U' sh₁ hU' hI₁ => ?_) sh ⟨hm, fun j h => absurd h (by omega)⟩
  · obtain ⟨hst, hc, hf, hF⟩ := hU i
    generalize U i = th at hst hc hf hF ⊢
    obtain ⟨tc, tl, tf, ts⟩ := th
    dsimp only at hst hc hf hF
    subst hc hf
    obtain ⟨hmI, hlanes⟩ := hI
    obtain ⟨t, sh', he, hm', harr, hab, hfr, hst', hat⟩ := lane_first C hS (hL i) hKg hKu hM hM8 hF hmI
    refine ⟨t, sh', he, ⟨hm', fun j hj => ?_⟩, hst', hat⟩
    by_cases hji : j = i
    · subst hji; exact ⟨harr, hab⟩
    · have hj' : j.val < i.val := by
        have : j.val ≠ i.val := fun h => hji (Fin.ext h)
        omega
      obtain ⟨ha, hb⟩ := hlanes j hj'
      exact ⟨ha.frame hfr (thr_ne hji), hb.frame hfr (thr_ne hji)⟩
  · obtain ⟨hm₁, hl₁⟩ := hI₁
    refine runSimd_collective_ev C 1279 _ 3 127 (.mma .f16 .f32) .f32 0
      (fun i => mmaVal C ku M I.Uc I.X (4 * g + s) i 0)
      (fun i => accVal (acc C ku I.Uc I.X M (4 * g + s) (0 + 1)) i)
      (resolve_mma_halfA C 0 (aReg C ku I.Uc (4 * g + s) 0) (bReg C I.X M 0) (acc C ku I.Uc I.X M (4 * g + s) 0))
      (fun _ sh => sh = sh₁) (fun i th => AtU C kg ku M I g s i 0 (ctxs i) th)
      (Mem C L I M out (64 * (4 * g + s) + 64) (g + 1) (fun _ => True)) (fun _ th => th.status = .done)
      (fun i sh hI => ?_) (fun U'' sh₂ hU'' hI₂ => ?_) sh₁ rfl
    · subst hI
      obtain ⟨t', he, hst, hat⟩ := lane_gate C hS (hU' i) hm₁.regions (hl₁ i i.isLt).2
      exact ⟨t', sh, he, rfl, hst, hat⟩
    · subst hI₂
      exact simd_steps C hS hKg hKu hM hM8 ctxs hL hout 639 0 rfl U'' hU'' sh₂ hm₁ fun j => (hl₁ j j.isLt).1

/-- A threadgroup: the barrier, then its 4 SIMD-groups' 8-row tiles. -/
theorem group_run (hS : Shape L kg ku M I) (hKg : GateUp.Width kg) (hKu : GateUp.Width ku) (hM : 1 ≤ M) (hM8 : M ≤ 8)
    (hMS : bytesWord (cells I.S 0 4) = M) (ctxOf : Fin 4 → Fin 32 → Ctx) (hL : ∀ (s : Fin 4) (i : Fin 32), Lane (ctxOf s i) g s i)
    (hout : ∀ m row, out m row = midOut C kg ku I.X I.Gc I.Gs I.Uc I.Us M m row) {sh : Shared}
    (hm : Mem C L I M out (256 * g) g (fun _ => False) sh) :
    ∃ sh', (Ev fun m => (runGroup C m 1281 2 (List.ofFn fun s : Fin 4 => List.ofFn fun i =>
        (⟨ctxOf s i, fun _ => none, [.block (GateUpCodebookMma.body kg ku)], .running⟩ : Thread))).run sh = some ((), sh')) ∧
      Mem C L I M out (256 * g + 256) (g + 1) (fun _ => True) sh' := by
  refine runGroup_barrier_ev C (by decide) 1281 1 _ 1 false true
    (fun j sh => Mem C L I M out (256 * g) g (fun e => e % 128 < 32 * j) sh)
    (fun j i t => AtBar kg ku M j i (ctxOf j i) t)
    (Mem C L I M out (256 * g + 256) (g + 1) (fun _ => True))
    (fun j sh hj => ?_) (fun U sh hU hI => ?_) sh (hm.mono fun e _ h => by omega)
  · obtain ⟨V, sh', hr, hm', hV⟩ := simd_phase1 C hS hMS hM8 (ctxOf j) (hL j) hj
    exact ⟨V, sh', hr, hm', fun i => ⟨(hV i).1, (hV i).2⟩⟩
  · have hp : Mem C L I M out (256 * g + 64 * 0) (g + 1) (fun _ => True) (pass false true sh) :=
      hI.pass.mono fun e he _ => by omega
    exact runGroup_done_ev C 1281 0 _ (fun j sh => Mem C L I M out (256 * g + 64 * j) (g + 1) (fun _ => True) sh)
      (fun j sh hj => by
        obtain ⟨V, sh', hr, hm', hd⟩ := simd_phase2 C hS hKg hKu hM hM8 (ctxOf j) (hL j) hout (U j) (hU j)
          (by rw [show 64 * (4 * g + j) = 256 * g + 64 * j by ring]; exact hj)
        exact ⟨V, sh', hr, by rw [show 256 * g + 64 * (j.val + 1) = 64 * (4 * g + j) + 64 by ring]; exact hm', hd⟩)
      _ hp

end Simd

section Launch
variable (C : M1Max.Contract) {kg ku M : Nat} {I : In}

/-- **The launch**: the 544 threadgroups in order. -/
theorem launch_run {initial : Nat → ByteMemory.Bytes} (hS : Shape (launch kg ku M I initial) kg ku M I)
    (hKg : GateUp.Width kg) (hKu : GateUp.Width ku) (hM : 1 ≤ M) (hM8 : M ≤ 8) (hMS : bytesWord (cells I.S 0 4) = M)
    (fuse : Nat → Bool) (garbage : Garbage) :
    ∃ sh, (∃ cbOk, Mem C (launch kg ku M I initial) I M (midOut C kg ku I.X I.Gc I.Gs I.Uc I.Us M) (256 * 544) 544 cbOk sh) ∧
      Ev fun m => runLaunch C fuse (launch kg ku M I initial) garbage m 1281 2 = some ⟨sh.bytes, sh.log⟩ := by
  have hb : (launch kg ku M I initial).buffers = buffers (bufs kg ku M I) [34816 * M] 16 initial := rfl
  obtain ⟨sh, hI, hr⟩ := launch_tiles.launch_run_ev C fuse garbage 1281 2
    (fun G sh => ∃ cbOk, Mem C (launch kg ku M I initial) I M (midOut C kg ku I.X I.Gc I.Gs I.Uc I.Us M) (256 * G) G cbOk sh)
    ⟨fun _ => False, rfl, initial_input hb garbage 0 (by simp [bufs]), initial_input hb garbage 1 (by simp [bufs]),
      initial_input hb garbage 2 (by simp [bufs]), initial_input hb garbage 3 (by simp [bufs]),
      initial_input hb garbage 4 (by simp [bufs]), initial_input hb garbage 5 (by simp [bufs]), rfl, rfl,
      fun _ _ h => h.elim, fun m _ row _ h => absurd h (by omega), fun a ha => by simp [Launch.initial] at ha⟩
    (fun bx byy bz hx hy hz sh hI => by
      obtain rfl : bx = 0 := by omega
      obtain rfl : bz = 0 := by omega
      obtain ⟨cbOk, hm⟩ := hI
      have hm' := hm.reset rfl garbage (0 + byy * 1 + 0 * 1 * 544)
      rw [show 0 + byy * 1 + 0 * 1 * 544 = byy by ring] at hm' ⊢
      obtain ⟨sh', hr, hm''⟩ := group_run C hS hKg hKu hM hM8 hMS
        (fun s i => (launch kg ku M I initial).ctxAt fuse 0 byy 0 (32 * s + i)) (fun s i => lane_of fuse hy s i)
        (fun _ _ => rfl) hm'
      exact ⟨sh', hr, _, by rw [show 256 * (byy + 1) = 256 * byy + 256 by ring]; exact hm''⟩)
  exact ⟨sh, hI, hr⟩

theorem shape_word {S : ByteMemory.Bytes} {M : Nat} (hM8 : M ≤ 8)
    (hS : S 0 = BitVec.ofNat 8 M ∧ S 1 = BitVec.ofNat 8 (M / 2 ^ 8) ∧ S 2 = BitVec.ofNat 8 (M / 2 ^ 16) ∧
      S 3 = BitVec.ofNat 8 (M / 2 ^ 24)) : bytesWord (cells S 0 4) = M := by
  obtain ⟨h0, h1, h2, h3⟩ := hS
  show (S (0 + 0)).toNat + 256 * ((S (0 + 1)).toNat + 256 * ((S (0 + 2)).toNat + 256 * ((S (0 + 3)).toNat + 256 * 0))) = M
  rw [show (0 : Nat) + 0 = 0 from rfl, show (0 : Nat) + 1 = 1 from rfl, show (0 : Nat) + 2 = 2 from rfl,
    show (0 : Nat) + 3 = 3 from rfl, h0, h1, h2, h3]
  simp only [BitVec.toNat_ofNat, Nat.reducePow]
  omega

end Launch

variable (C : M1Max.Contract)

/-- **The GPU runs the codebook gate-up MMA kernel as its source says**, for gate and up widths `kg`, `ku` in
1 … 4 and `M` (`x_shape[0]`) rows in 1 … 8, given that the text compiles to `core kg ku`. Under the GPU assumption,
MLX's launch on any `x` `[M, 5120]` (16-byte aligned: the kernel reads it as `uint4`), its shape buffer holding the
`int` `M` (4-aligned), codes (4-aligned) and scales (2-aligned) writes to `mid` `[M, 17408]` every element's
`silu` of its lane's 640-step `simdgroup_multiply_accumulate` accumulations of the codebook-decoded weights and
`x`, times the row scales. -/
theorem gpu_output_of (kg ku : Nat) (hKg : GateUp.Width kg) (hKu : GateUp.Width ku) (text : List Char)
    (hc : (frontend text).bind elaborate = some (GateUpCodebookMma.core kg ku)) (G : Gpu C)
    (hmax : 128 ≤ G.maxThreads text) (M : Nat) (hM : 1 ≤ M) (hM8 : M ≤ 8)
    (X S Gc Gs Uc Us : ByteMemory.Bytes) (ax ash ag as au aus : Nat) (hax : 16 ∣ ax) (hash : 4 ∣ ash) (hag : 4 ∣ ag)
    (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus)
    (hS : S 0 = BitVec.ofNat 8 M ∧ S 1 = BitVec.ofNat 8 (M / 2 ^ 8) ∧ S 2 = BitVec.ofNat 8 (M / 2 ^ 16) ∧
      S 3 = BitVec.ofNat 8 (M / 2 ^ 24)) :
    G.execute text (128, 544, 1) (128, 1, 1)
      [⟨.device, 10240 * M, ax, X⟩, ⟨.constant, 8, ash, S⟩, ⟨.device, GateUp.codesBytes kg, ag, Gc⟩,
        ⟨.device, 34816, as, Gs⟩, ⟨.device, GateUp.codesBytes ku, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816 * M] =
      some [expected C kg ku X Gc Gs Uc Us M] := by
  have h := gpu_owned C G (text := text) (grid := (128, 544, 1)) (tg := (128, 1, 1))
    (inputs := [⟨.device, 10240 * M, ax, X⟩, ⟨.constant, 8, ash, S⟩, ⟨.device, GateUp.codesBytes kg, ag, Gc⟩,
        ⟨.device, 34816, as, Gs⟩, ⟨.device, GateUp.codesBytes ku, au, Uc⟩, ⟨.device, 34816, aus, Us⟩])
    (sizes := [34816 * M]) (fun _ => expected C kg ku X Gc Gs Uc Us M) hc (by simpa using hmax)
    (fun initial garbage => by
      have hSh := launch_shape (kg := kg) (ku := ku) (M := M) (I := ⟨X, S, Gc, Gs, Uc, Us, ax, ash, ag, as, au, aus⟩)
        (initial := initial) (Nat.mod_eq_zero_of_dvd hax) (Nat.mod_eq_zero_of_dvd hash) (Nat.mod_eq_zero_of_dvd hag)
        (Nat.mod_eq_zero_of_dvd has) (Nat.mod_eq_zero_of_dvd hau) (Nat.mod_eq_zero_of_dvd haus)
      obtain ⟨sh, ⟨cbOk, hm⟩, n, hn⟩ := launch_run C hSh hKg hKu hM hM8 (shape_word hM8 hS) (G.fusion text) garbage
      refine ⟨n, 1281, 2, sh, dev, tgo, hn n le_rfl, hm.log, ?_⟩
      intro i hi b hb
      obtain rfl : i = 0 := by simp at hi; omega
      have hb' : b < 34816 * M := by simpa using hb
      show sh.bytes 6 b = expected C kg ku X Gc Gs Uc Us M b
      have hm' := hm.mid (b / 2 / 17408) (by omega) (b / 2 % 17408) (by omega)
        (ord_lt (by omega) (by omega))
      rw [expected, ite_eq_left hb', ← hm', cells_getD _ _ _ _ (by omega),
        show 2 * (17408 * (b / 2 / 17408) + b / 2 % 17408) + b % 2 = b by omega])
  rw [h]
  show some [fun b => if b < 34816 * M then expected C kg ku X Gc Gs Uc Us M b else 0] = _
  congr 2
  funext b
  unfold expected
  split <;> simp_all

end Metal.Kernels.CodebookMma

namespace Metal.Kernels.GateUpCodebookMma
open Metal Metal.Core Inference.Contracts.Mlx

/-! ## The route's instances

The codebook MMA forwards (2 to 8 prompt rows) reach the kernel at every layer's gate and up widths
(KG, KU) ∈ {(2,2), (3,3), (3,2), (2,3), (4,3), (4,4), (3,4)} (host/load/Data.lean). Codes of width `K` are
`17408·640·K` bytes: 22282240 (2-bit), 33423360 (3-bit), 44564480 (4-bit). -/

section Route
variable (C : M1Max.Contract) {M : Nat} {X S Gc Gs Uc Us : ByteMemory.Bytes} {ax ash ag as au aus : Nat}

theorem gpu_output_2_2 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 2 2)) (hM : 2 ≤ M) (hM8 : M ≤ 8)
    (hax : 16 ∣ ax) (hash : 4 ∣ ash) (hag : 4 ∣ ag) (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus)
    (hS : S 0 = BitVec.ofNat 8 M ∧ S 1 = BitVec.ofNat 8 (M / 2 ^ 8) ∧ S 2 = BitVec.ofNat 8 (M / 2 ^ 16) ∧
      S 3 = BitVec.ofNat 8 (M / 2 ^ 24)) :
    G.execute (text 2 2) (128, 544, 1) (128, 1, 1)
      [⟨.device, 10240 * M, ax, X⟩, ⟨.constant, 8, ash, S⟩, ⟨.device, 22282240, ag, Gc⟩, ⟨.device, 34816, as, Gs⟩,
        ⟨.device, 22282240, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816 * M] =
      some [CodebookMma.expected C 2 2 X Gc Gs Uc Us M] :=
  CodebookMma.gpu_output_of C 2 2 GateUp.width_2 GateUp.width_2 _ compile_2_2 G hmax M (by omega) hM8 X S Gc Gs
    Uc Us ax ash ag as au aus hax hash hag has hau haus hS

theorem gpu_output_3_3 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 3 3)) (hM : 2 ≤ M) (hM8 : M ≤ 8)
    (hax : 16 ∣ ax) (hash : 4 ∣ ash) (hag : 4 ∣ ag) (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus)
    (hS : S 0 = BitVec.ofNat 8 M ∧ S 1 = BitVec.ofNat 8 (M / 2 ^ 8) ∧ S 2 = BitVec.ofNat 8 (M / 2 ^ 16) ∧
      S 3 = BitVec.ofNat 8 (M / 2 ^ 24)) :
    G.execute (text 3 3) (128, 544, 1) (128, 1, 1)
      [⟨.device, 10240 * M, ax, X⟩, ⟨.constant, 8, ash, S⟩, ⟨.device, 33423360, ag, Gc⟩, ⟨.device, 34816, as, Gs⟩,
        ⟨.device, 33423360, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816 * M] =
      some [CodebookMma.expected C 3 3 X Gc Gs Uc Us M] :=
  CodebookMma.gpu_output_of C 3 3 GateUp.width_3 GateUp.width_3 _ compile_3_3 G hmax M (by omega) hM8 X S Gc Gs
    Uc Us ax ash ag as au aus hax hash hag has hau haus hS

theorem gpu_output_3_2 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 3 2)) (hM : 2 ≤ M) (hM8 : M ≤ 8)
    (hax : 16 ∣ ax) (hash : 4 ∣ ash) (hag : 4 ∣ ag) (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus)
    (hS : S 0 = BitVec.ofNat 8 M ∧ S 1 = BitVec.ofNat 8 (M / 2 ^ 8) ∧ S 2 = BitVec.ofNat 8 (M / 2 ^ 16) ∧
      S 3 = BitVec.ofNat 8 (M / 2 ^ 24)) :
    G.execute (text 3 2) (128, 544, 1) (128, 1, 1)
      [⟨.device, 10240 * M, ax, X⟩, ⟨.constant, 8, ash, S⟩, ⟨.device, 33423360, ag, Gc⟩, ⟨.device, 34816, as, Gs⟩,
        ⟨.device, 22282240, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816 * M] =
      some [CodebookMma.expected C 3 2 X Gc Gs Uc Us M] :=
  CodebookMma.gpu_output_of C 3 2 GateUp.width_3 GateUp.width_2 _ compile_3_2 G hmax M (by omega) hM8 X S Gc Gs
    Uc Us ax ash ag as au aus hax hash hag has hau haus hS

theorem gpu_output_2_3 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 2 3)) (hM : 2 ≤ M) (hM8 : M ≤ 8)
    (hax : 16 ∣ ax) (hash : 4 ∣ ash) (hag : 4 ∣ ag) (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus)
    (hS : S 0 = BitVec.ofNat 8 M ∧ S 1 = BitVec.ofNat 8 (M / 2 ^ 8) ∧ S 2 = BitVec.ofNat 8 (M / 2 ^ 16) ∧
      S 3 = BitVec.ofNat 8 (M / 2 ^ 24)) :
    G.execute (text 2 3) (128, 544, 1) (128, 1, 1)
      [⟨.device, 10240 * M, ax, X⟩, ⟨.constant, 8, ash, S⟩, ⟨.device, 22282240, ag, Gc⟩, ⟨.device, 34816, as, Gs⟩,
        ⟨.device, 33423360, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816 * M] =
      some [CodebookMma.expected C 2 3 X Gc Gs Uc Us M] :=
  CodebookMma.gpu_output_of C 2 3 GateUp.width_2 GateUp.width_3 _ compile_2_3 G hmax M (by omega) hM8 X S Gc Gs
    Uc Us ax ash ag as au aus hax hash hag has hau haus hS

theorem gpu_output_4_3 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 4 3)) (hM : 2 ≤ M) (hM8 : M ≤ 8)
    (hax : 16 ∣ ax) (hash : 4 ∣ ash) (hag : 4 ∣ ag) (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus)
    (hS : S 0 = BitVec.ofNat 8 M ∧ S 1 = BitVec.ofNat 8 (M / 2 ^ 8) ∧ S 2 = BitVec.ofNat 8 (M / 2 ^ 16) ∧
      S 3 = BitVec.ofNat 8 (M / 2 ^ 24)) :
    G.execute (text 4 3) (128, 544, 1) (128, 1, 1)
      [⟨.device, 10240 * M, ax, X⟩, ⟨.constant, 8, ash, S⟩, ⟨.device, 44564480, ag, Gc⟩, ⟨.device, 34816, as, Gs⟩,
        ⟨.device, 33423360, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816 * M] =
      some [CodebookMma.expected C 4 3 X Gc Gs Uc Us M] :=
  CodebookMma.gpu_output_of C 4 3 GateUp.width_4 GateUp.width_3 _ compile_4_3 G hmax M (by omega) hM8 X S Gc Gs
    Uc Us ax ash ag as au aus hax hash hag has hau haus hS

theorem gpu_output_4_4 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 4 4)) (hM : 2 ≤ M) (hM8 : M ≤ 8)
    (hax : 16 ∣ ax) (hash : 4 ∣ ash) (hag : 4 ∣ ag) (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus)
    (hS : S 0 = BitVec.ofNat 8 M ∧ S 1 = BitVec.ofNat 8 (M / 2 ^ 8) ∧ S 2 = BitVec.ofNat 8 (M / 2 ^ 16) ∧
      S 3 = BitVec.ofNat 8 (M / 2 ^ 24)) :
    G.execute (text 4 4) (128, 544, 1) (128, 1, 1)
      [⟨.device, 10240 * M, ax, X⟩, ⟨.constant, 8, ash, S⟩, ⟨.device, 44564480, ag, Gc⟩, ⟨.device, 34816, as, Gs⟩,
        ⟨.device, 44564480, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816 * M] =
      some [CodebookMma.expected C 4 4 X Gc Gs Uc Us M] :=
  CodebookMma.gpu_output_of C 4 4 GateUp.width_4 GateUp.width_4 _ compile_4_4 G hmax M (by omega) hM8 X S Gc Gs
    Uc Us ax ash ag as au aus hax hash hag has hau haus hS

theorem gpu_output_3_4 (G : Gpu C) (hmax : 128 ≤ G.maxThreads (text 3 4)) (hM : 2 ≤ M) (hM8 : M ≤ 8)
    (hax : 16 ∣ ax) (hash : 4 ∣ ash) (hag : 4 ∣ ag) (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus)
    (hS : S 0 = BitVec.ofNat 8 M ∧ S 1 = BitVec.ofNat 8 (M / 2 ^ 8) ∧ S 2 = BitVec.ofNat 8 (M / 2 ^ 16) ∧
      S 3 = BitVec.ofNat 8 (M / 2 ^ 24)) :
    G.execute (text 3 4) (128, 544, 1) (128, 1, 1)
      [⟨.device, 10240 * M, ax, X⟩, ⟨.constant, 8, ash, S⟩, ⟨.device, 33423360, ag, Gc⟩, ⟨.device, 34816, as, Gs⟩,
        ⟨.device, 44564480, au, Uc⟩, ⟨.device, 34816, aus, Us⟩] [34816 * M] =
      some [CodebookMma.expected C 3 4 X Gc Gs Uc Us M] :=
  CodebookMma.gpu_output_of C 3 4 GateUp.width_3 GateUp.width_4 _ compile_3_4 G hmax M (by omega) hM8 X S Gc Gs
    Uc Us ax ash ag as au aus hax hash hag has hau haus hS

end Route

end Metal.Kernels.GateUpCodebookMma
