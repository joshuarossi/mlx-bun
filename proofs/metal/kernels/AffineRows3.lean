import metal.Elab
import metal.Frontend
import metal.Assemble
import host.mlx.PrefillKernelSources
import metal.Steps
import metal.Group
import metal.Memory
import metal.Fuel

namespace Metal.Kernels.AffineRows3
open Metal Metal.Core

/-! # affine3-rows.ts: `mlx_bun_affine3_rows`

No header. The body:

```
const uint lane = thread_index_in_simdgroup;
const uint sg = simdgroup_index_in_threadgroup;
const uint n0 = (threadgroup_position_in_grid.y * (uint)SGS + sg) * (uint)NR;
if (n0 >= (uint)N) return;
const ulong rowBytes = (ulong)K * 3u / 8u;
const uint groups = (uint)K / 64u;
const device uint8_t* wb = (const device uint8_t*)w;
float acc[NR][M];
#pragma clang loop unroll(full)
for (uint r = 0; r < (uint)NR; ++r)
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) acc[r][m] = 0.0f;
for (uint k0 = lane * (uint)VPT; k0 < (uint)K; k0 += 32u * (uint)VPT) {
  float xr[M][VPT];
  float xs[M];
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) {
    const device metal::vec<T, 4>* xp = (const device metal::vec<T, 4>*)(x + (ulong)m * (ulong)K + k0);
    float sum = 0.0f;
    #pragma clang loop unroll(full)
    for (uint v = 0; v < (uint)VPT / 4u; ++v) {
      const float4 f = float4(xp[v]);
      xr[m][4 * v] = f.x; xr[m][4 * v + 1] = f.y; xr[m][4 * v + 2] = f.z; xr[m][4 * v + 3] = f.w;
      sum += (f.x + f.y) + (f.z + f.w);
    }
    xs[m] = sum;
  }
  const uint g = k0 / 64u;
  #pragma clang loop unroll(full)
  for (uint r = 0; r < (uint)NR; ++r) {
    const uint n = n0 + r;
    const device uint8_t* p = wb + (ulong)n * rowBytes + (ulong)k0 * 3u / 8u;
    float q[VPT];
    #pragma clang loop unroll(full)
    for (uint c = 0; c < (uint)VPT / 8u; ++c) {
      const uint packed = uint(p[3 * c]) | (uint(p[3 * c + 1]) << 8) | (uint(p[3 * c + 2]) << 16);
      #pragma clang loop unroll(full)
      for (uint j = 0; j < 8u; ++j)
        q[8 * c + j] = as_type<float>(0x4b000000u | ((packed >> (3u * j)) & 7u)) - 8388608.0f;
    }
    const float s = float(scales[(ulong)n * groups + g]);
    const float b = float(biases[(ulong)n * groups + g]);
    #pragma clang loop unroll(full)
    for (uint m = 0; m < (uint)M; ++m) {
      float dot = 0.0f;
      #pragma clang loop unroll(full)
      for (uint j = 0; j < (uint)VPT; ++j) dot = metal::fma(q[j], xr[m][j], dot);
      acc[r][m] = metal::fma(s, dot, metal::fma(b, xs[m], acc[r][m]));
    }
  }
}
#pragma clang loop unroll(full)
for (uint r = 0; r < (uint)NR; ++r)
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) {
    const float v = metal::simd_sum(acc[r][m]);
    if (lane == 0u) y[(ulong)m * (ulong)N + n0 + r] = T(v);
  }
```
Launch (affine3-rows.ts:88-98): inputs `x` bfloat16 `[M, K]`, `w` uint32 `[N, K·3/32]`, `scales` and
`biases` bfloat16 `[N, K/64]`, output `y` bfloat16 `[M, N]`; grid `[64, ⌈N/8⌉, 1]`, threadgroup
`[64, 1, 1]`; `T` = bfloat16, template ints M, N, K, NR = 4, SGS = 2, VPT = 16 (:15). The route's
instances are the 3-bit projections of the verify-width forward (2 or 3 rows, `#rows`,
qwen38-27b-trellis-m1max.ts `Affine3`): M ∈ {2, 3} at in_proj_qkv (K 5120, N 10240), in_proj_z
(K 5120, N 6144) and out_proj (K 6144, N 5120). The core is `core M N K` (NR, SGS, VPT the
kernel's constants); the elaborator folds rowBytes = 3K/8, groups = K/64, the bounds N and K and
the strides M (of `acc`) and 16 (of `xr`). -/

def u32l (n : Nat) : CExpr := .lit (.int .u32 n)
def u64l (n : Nat) : CExpr := .lit (.int .u64 n)
def u16l (n : Nat) : CExpr := .lit (.int .u16 n)
def f32l (bits : Nat) : CExpr := .lit (.f32 (Val.ofF32Bits bits))

def u32 (op : Core.BinOp) (a b : CExpr) : CExpr := .bin op .u32 0 a b
def u64 (op : Core.BinOp) (a b : CExpr) : CExpr := .bin op .u64 0 a b
def toU64 (e : CExpr) : CExpr := .conv .u64 e
def fadd (a b : CExpr) : CExpr := .bin .add .f32 0 a b

/-- `i = 0; i < n; ++i` over slot `i`. -/
def forU (i n : Nat) (body : List CStmt) : List CStmt :=
  [.set i (u32l 0), .loop (u32 .lt (.local i) (u32l n)) [.set i (u32 .add (.local i) (u32l 1))] body]

/-- Element `[u][i]` of the 2-D thread array in slot `a` with rows of `stride`. -/
def at2 (a : Nat) (u : CExpr) (stride : Nat) (i : CExpr) : CExpr :=
  .offset (.offset (.local a) (u64 .mul (toU64 u) (u64l stride))) i

/-- Component `i` of the vector in slot `k`. -/
def comp (k i : Nat) : CExpr := .component (.local k) (u32l i)

/-! ## The K step -/

/-- `xr[m][4·v + k] = f.k` (no `+ 0` for the first). -/
def xrStore (k : Nat) : CStmt :=
  .store (.scalar .f32)
    (at2 15 (.local 17) 16 (if k = 0 then u32 .mul (u32l 4) (.local 20) else u32 .add (u32 .mul (u32l 4) (.local 20)) (u32l k)))
    (comp 21 k)

/-- One 4-value chunk `v` (slot 20) of row `m`: `f`, its values into `xr`, `sum += (f.x + f.y) + (f.z + f.w)`. -/
def chunkBody : List CStmt :=
  [.set 21 (.conv .f32 (.load (.vec .bf16 4) (.offset (.local 18) (.local 20)))),
   xrStore 0, xrStore 1, xrStore 2, xrStore 3,
   .set 19 (fadd (.local 19) (fadd (fadd (comp 21 0) (comp 21 1)) (fadd (comp 21 2) (comp 21 3))))]

/-- Row `m` (slot 17) of `x`: `xp`, `sum`, the chunks, `xs[m] = sum`. -/
def xRow (K : Nat) : List CStmt :=
  [.set 18 (.ptrCast (.vec .bf16 4) (.offset (.offset (.local 0) (u64 .mul (toU64 (.local 17)) (u64l K))) (.local 14))),
   .set 19 (f32l 0x0)] ++
  forU 20 4 chunkBody ++
  [.store (.scalar .f32) (.offset (.local 16) (.local 17)) (.local 19)]

/-- Byte `3c + k` of the row's packed words. -/
def byte (k : Nat) : CExpr :=
  .conv .u32 (.load (.scalar .u8) (.offset (.local 25)
    (if k = 0 then u32 .mul (u32l 3) (.local 27) else u32 .add (u32 .mul (u32l 3) (.local 27)) (u32l k))))

/-- `packed`: three bytes, little-endian. -/
def packed : CExpr := u32 .bitOr (u32 .bitOr (byte 0) (u32 .shl (byte 1) (u32l 8))) (u32 .shl (byte 2) (u32l 16))

/-- `q[8c + j]`: the 3-bit field `j` of `packed` in the mantissa of 2^23, minus 2^23. -/
def field : CExpr :=
  .bin .sub .f32 0
    (.bitcast .f32 (u32 .bitOr (u32l 0x4B000000) (u32 .bitAnd (u32 .shr (.local 28) (u32 .mul (u32l 3) (.local 29))) (u32l 7))))
    (f32l 0x4B000000)

/-- `acc[r][m]` for `r` in slot `r`. -/
def accAt (M r : Nat) : CExpr := at2 11 (.local r) M (.local 32)

/-- Output row `r` (slot 23) of the K step: `n`, `p`, `q`, `s`, `b`, then for each `m` the dot product and
`acc[r][m] = fma(s, dot, fma(b, xs[m], acc[r][m]))`. -/
def outRow (M : Nat) : List CStmt :=
  [.set 24 (u32 .add (.local 7) (.local 23)),
   .set 25 (.offset (.offset (.local 10) (u64 .mul (toU64 (.local 24)) (.local 8)))
     (u64 .div (u64 .mul (toU64 (.local 14)) (u64l 3)) (u64l 8))),
   .array 26 false 3 (.scalar .f32)] ++
  forU 27 2 ([.set 28 packed] ++
    forU 29 8 [.store (.scalar .f32) (.offset (.local 26) (u32 .add (u32 .mul (u32l 8) (.local 27)) (.local 29))) field]) ++
  [.set 30 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 2)
     (u64 .add (u64 .mul (toU64 (.local 24)) (toU64 (.local 9))) (toU64 (.local 22)))))),
   .set 31 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 3)
     (u64 .add (u64 .mul (toU64 (.local 24)) (toU64 (.local 9))) (toU64 (.local 22))))))] ++
  forU 32 M
    ([.set 33 (f32l 0x0)] ++
     forU 34 16 [.set 33 (.fma (.load (.scalar .f32) (.offset (.local 26) (.local 34)))
       (.load (.scalar .f32) (at2 15 (.local 32) 16 (.local 34))) (.local 33))] ++
     [.store (.scalar .f32) (accAt M 23)
       (.fma (.local 30) (.local 33) (.fma (.local 31) (.load (.scalar .f32) (.offset (.local 16) (.local 32)))
         (.load (.scalar .f32) (accAt M 23))))])

/-- One K step `k0` (slot 14): `xr`, `xs`, the rows of `x`, `g`, the output rows. -/
def kStep (M K : Nat) : List CStmt :=
  [.array 15 false 1 (.scalar .f32), .array 16 false 2 (.scalar .f32)] ++
  forU 17 M (xRow K) ++
  [.set 22 (u32 .div (.local 14) (u32l 64))] ++
  forU 23 4 (outRow M)

/-- Output `(r, m)` (slots 35, 36): `simd_sum` into slot 37, `v`, lane 0 stores `y[m·N + n0 + r]`. -/
def outBody (M N : Nat) : List CStmt :=
  [.collective 1 37 .sum .f32 (.load (.scalar .f32) (at2 11 (.local 35) M (.local 36))) (u16l 0),
   .set 38 (.local 37),
   .ite (u32 .eq (.local 5) (u32l 0))
     [.store (.scalar .bf16)
       (.offset (.local 4) (u64 .add (u64 .add (u64 .mul (toU64 (.local 36)) (u64l N)) (toU64 (.local 7))) (toU64 (.local 35))))
       (.conv .bf16 (.local 38))] []]

/-- Slots: 0 x, 1 w, 2 scales, 3 biases, 4 y, 5 lane, 6 sg, 7 n0, 8 rowBytes, 9 groups, 10 wb, 11 acc (thread
array 0), 12 r, 13 m, 14 k0, 15 xr (thread array 1), 16 xs (thread array 2), 17 m, 18 xp, 19 sum, 20 v, 21 f,
22 g, 23 r, 24 n, 25 p, 26 q (thread array 3), 27 c, 28 packed, 29 j, 30 s, 31 b, 32 m, 33 dot, 34 j, 35 r,
36 m, 37 the `simd_sum` result, 38 v. The body after the parameters is a scope (the kernel's `return`). -/
def body (M N K : Nat) : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .bf16⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .u32⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .bf16⟩)),
   .set 3 (.lit (.ptr ⟨3, 0, .scalar .bf16⟩)),
   .set 4 (.lit (.ptr ⟨4, 0, .scalar .bf16⟩)),
   .scope
     ([.set 5 (.coord .threadIndexInSimdgroup),
       .set 6 (.coord .simdgroupIndexInThreadgroup),
       .set 7 (u32 .mul (u32 .add (u32 .mul (.component (.coord .threadgroupPositionInGrid) (u32l 1)) (u32l 2)) (.local 6))
         (u32l 4)),
       .ite (u32 .ge (.local 7) (u32l N)) [.leave] [],
       .set 8 (u64l (K * 3 / 8)),
       .set 9 (u32l (K / 64)),
       .set 10 (.ptrCast (.scalar .u8) (.local 1)),
       .array 11 false 0 (.scalar .f32)] ++
      forU 12 4 (forU 13 M [.store (.scalar .f32) (at2 11 (.local 12) M (.local 13)) (f32l 0x0)]) ++
      [.set 14 (u32 .mul (.local 5) (u32l 16)),
       .loop (u32 .lt (.local 14) (u32l K)) [.set 14 (u32 .add (.local 14) (u32l 512))] (kStep M K)] ++
      forU 35 4 (forU 36 M (outBody M N)))]

/-- Thread arrays `acc[4][M]`, `xr[M][16]`, `xs[M]`, `q[16]`. -/
def core (M N K : Nat) : Kernel :=
  ⟨5, [], [(.scalar .f32, 4 * M), (.scalar .f32, 16 * M), (.scalar .f32, M), (.scalar .f32, 16)], body M N K⟩

section Texts
open Host.Mlx
/-! ## The texts MLX compiles -/

def inputs (M N K : Nat) : List Assemble.Input :=
  [⟨chars!"x", .bfloat16, [M, K]⟩, ⟨chars!"w", .uint32, [N, K * 3 / 32]⟩, ⟨chars!"scales", .bfloat16, [N, K / 64]⟩,
    ⟨chars!"biases", .bfloat16, [N, K / 64]⟩]

def args (M N K : Nat) : List Assemble.TemplateArg :=
  [.dtype chars!"T" .bfloat16, .int chars!"M" M, .int chars!"N" N, .int chars!"K" K, .int chars!"NR" 4,
    .int chars!"SGS" 2, .int chars!"VPT" 16]

def assembled (M N K : Nat) : Option (List Char) :=
  Assemble.assemble (PrefillSources.name .affine3Rows) (inputs M N K) [chars!"y"] [.bfloat16]
    (PrefillSources.source .affine3Rows) (PrefillSources.header .affine3Rows) (args M N K) false

def text (M N K : Nat) : List Char := (assembled M N K).getD []

/-- Every route instance assembles. -/
theorem assembled_route :
    (assembled 2 10240 5120).isSome ∧ (assembled 2 6144 5120).isSome ∧ (assembled 2 5120 6144).isSome ∧
    (assembled 3 10240 5120).isSome ∧ (assembled 3 6144 5120).isSome ∧ (assembled 3 5120 6144).isSome := by
  decide +kernel

kernel_rfl compile_2_10240_5120 : (frontend (text 2 10240 5120)).bind elaborate = some (core 2 10240 5120)
kernel_rfl compile_2_6144_5120 : (frontend (text 2 6144 5120)).bind elaborate = some (core 2 6144 5120)
kernel_rfl compile_2_5120_6144 : (frontend (text 2 5120 6144)).bind elaborate = some (core 2 5120 6144)
kernel_rfl compile_3_10240_5120 : (frontend (text 3 10240 5120)).bind elaborate = some (core 3 10240 5120)
kernel_rfl compile_3_6144_5120 : (frontend (text 3 6144 5120)).bind elaborate = some (core 3 6144 5120)
kernel_rfl compile_3_5120_6144 : (frontend (text 3 5120 6144)).bind elaborate = some (core 3 5120 6144)

end Texts
end Metal.Kernels.AffineRows3

/-! # The proof

The 3-bit and 4-bit kernels share one core (`AffineRows.coreG`): they differ in the row length, the offset `pOff` of
`k0` in a row and the weight decode `qfill`. `AffineRows.gpu_output_of` proves the common core for any bit width meeting
`PSpec` and `QSpec`; the 3-bit width follows, the 4-bit one is in AffineRows4.lean. Lane `L` of the SIMD-group owning
output rows `n0 … n0 + 3` (`n0 = 4 (2 g + s)`) runs the K/512 steps from `k0 = 16 L`, then the `4 M` `simd_sum`s; lane
0 stores each `y[m][n0 + r]`. Thread memory (`acc`, `xr`, `xs`, `q`) is private; the only device writes are those
stores, one owner per element. -/

namespace Metal.Kernels.AffineRows
open Metal Metal.Core Inference.Contracts.Mlx
open Metal.Kernels.AffineRows3 (u32l u64l u16l f32l forU at2 comp fadd toU64)

section Lits
variable (C : M1Max.Contract)

/-- A `uint` literal below 2^32. -/
theorem eval_u32l {ctx : Ctx} {l : Locals} {n : Nat} (h : n < 2 ^ 32) (sh : Shared) :
    (eval C ctx l (u32l n)).run sh = some (u32 n, sh) := by
  rw [← u32_lit h]; rfl

end Lits

/-! ## Counted loops -/

section Loops
variable (C : M1Max.Contract) {ctx : Ctx}

/-- `for (uint i = 0; i < n; ++i) body` by an invariant at each test; the body keeps the counter. -/
theorem forU_exec {i n : Nat} {body : List CStmt} (hn : n < 2 ^ 32) (I : Nat → Locals → Shared → Prop)
    (hbody : ∀ k < n, ∀ l sh, I k l sh → l i = some (u32 k) →
      ∃ l' sh', Exec C ctx body l sh .normal l' sh' ∧ l' i = some (u32 k) ∧ I (k + 1) (setLocal l' i (u32 (k + 1))) sh')
    {l : Locals} {sh : Shared} (h0 : I 0 (setLocal l i (u32 0)) sh) :
    ∃ l' sh', Exec C ctx (forU i n body) l sh .normal l' sh' ∧ I n l' sh' := by
  obtain ⟨l', sh', hex, hI, -⟩ := Exec.loop_count (C := C) (ctx := ctx)
    (c := AffineRows3.u32 .lt (.local i) (u32l n)) (st := [.set i (AffineRows3.u32 .add (.local i) (u32l 1))]) (b := body) n
    (fun k l sh => I k l sh ∧ l i = some (u32 k)) (fun k l sh => I k l sh ∧ l i = some (u32 k))
    (fun k hk l sh h => ⟨sh, eval_int C (by decide) (eval_local' C h.2 sh) (eval_u32l C hn sh)
      (binary_lt_u32 C k n (by omega) hn), h⟩)
    (fun k hk l sh h => by
      obtain ⟨l', sh', hb, hi, hI⟩ := hbody k hk l sh h.1 h.2
      exact ⟨.normal, l', sh', _, sh', .inl rfl, hb, .set (eval_int C (by decide) (eval_local' C hi sh')
        (eval_u32l C (by norm_num) sh') (binary_add_u32 C k 1)) (.nil _ _), hI, setLocal_same _ _ _⟩)
    (l := setLocal l i (u32 0)) (sh := sh) ⟨h0, setLocal_same _ _ _⟩
  exact ⟨l', sh', .set (eval_u32l C (by norm_num) sh) hex, hI⟩

end Loops

/-! ## The two bit widths' common core

The cores of affine3-rows.ts and affine4-rows.ts differ only in the row length `rowBytes` (slot 8), the byte
offset `pOff` of `k0` within a row (in `p`, slot 25), and the statements `qfill` that decode the lane's 16 weights
into `q` (slots 27–29). -/

/-- `s`, `b`, and for each `m`: `dot`, then `acc[r][m] = fma(s, dot, fma(b, xs[m], acc[r][m]))`. -/
def dotBody : List CStmt :=
  [.set 33 (.fma (.load (.scalar .f32) (.offset (.local 26) (.local 34)))
    (.load (.scalar .f32) (at2 15 (.local 32) 16 (.local 34))) (.local 33))]

def accStore (M : Nat) : CStmt :=
  .store (.scalar .f32) (AffineRows3.accAt M 23)
    (.fma (.local 30) (.local 33) (.fma (.local 31) (.load (.scalar .f32) (.offset (.local 16) (.local 32)))
      (.load (.scalar .f32) (AffineRows3.accAt M 23))))

def mBody (M : Nat) : List CStmt := [.set 33 (f32l 0x0)] ++ forU 34 16 dotBody ++ [accStore M]

def sbIndex : CExpr :=
  AffineRows3.u64 .add (AffineRows3.u64 .mul (toU64 (.local 24)) (toU64 (.local 9))) (toU64 (.local 22))

def rowTail (M : Nat) : List CStmt :=
  [.set 30 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 2) sbIndex))),
   .set 31 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 3) sbIndex)))] ++
  forU 32 M (mBody M)

def rowHead (pOff : CExpr) : List CStmt :=
  [.set 24 (AffineRows3.u32 .add (.local 7) (.local 23)),
   .set 25 (.offset (.offset (.local 10) (AffineRows3.u64 .mul (toU64 (.local 24)) (.local 8))) pOff),
   .array 26 false 3 (.scalar .f32)]

/-- Output row `r` (slot 23) of a K step. -/
def outRowG (M : Nat) (pOff : CExpr) (qfill : List CStmt) : List CStmt := rowHead pOff ++ qfill ++ rowTail M

/-- One K step `k0` (slot 14). -/
def kStepG (M K : Nat) (pOff : CExpr) (qfill : List CStmt) : List CStmt :=
  [.array 15 false 1 (.scalar .f32), .array 16 false 2 (.scalar .f32)] ++
  forU 17 M (AffineRows3.xRow K) ++
  [.set 22 (AffineRows3.u32 .div (.local 14) (u32l 64))] ++
  forU 23 4 (outRowG M pOff qfill)

def n0Expr : CExpr :=
  AffineRows3.u32 .mul (AffineRows3.u32 .add (AffineRows3.u32 .mul (.component (.coord .threadgroupPositionInGrid) (u32l 1))
    (u32l 2)) (.local 6)) (u32l 4)

def prologue (N K rb : Nat) : List CStmt :=
  [.set 5 (.coord .threadIndexInSimdgroup),
   .set 6 (.coord .simdgroupIndexInThreadgroup),
   .set 7 n0Expr,
   .ite (AffineRows3.u32 .ge (.local 7) (u32l N)) [.leave] [],
   .set 8 (u64l rb),
   .set 9 (u32l (K / 64)),
   .set 10 (.ptrCast (.scalar .u8) (.local 1)),
   .array 11 false 0 (.scalar .f32)]

def zeroLoop (M : Nat) : List CStmt :=
  forU 12 4 (forU 13 M [.store (.scalar .f32) (at2 11 (.local 12) M (.local 13)) (f32l 0x0)])

def kCond (K : Nat) : CExpr := AffineRows3.u32 .lt (.local 14) (u32l K)
def kStep : List CStmt := [.set 14 (AffineRows3.u32 .add (.local 14) (u32l 512))]

def kLoop (M K : Nat) (pOff : CExpr) (qfill : List CStmt) : CStmt := .loop (kCond K) kStep (kStepG M K pOff qfill)

def k0Init : CStmt := .set 14 (AffineRows3.u32 .mul (.local 5) (u32l 16))

def outLoops (M N : Nat) : List CStmt := forU 35 4 (forU 36 M (AffineRows3.outBody M N))

def ptrSets : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .bf16⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .u32⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .bf16⟩)),
   .set 3 (.lit (.ptr ⟨3, 0, .scalar .bf16⟩)),
   .set 4 (.lit (.ptr ⟨4, 0, .scalar .bf16⟩))]

def bodyG (M N K rb : Nat) (pOff : CExpr) (qfill : List CStmt) : List CStmt :=
  ptrSets ++ [.scope (prologue N K rb ++ zeroLoop M ++ [k0Init, kLoop M K pOff qfill] ++ outLoops M N)]

/-- A bit width: the row length, the lane's byte offset `off k0` within a row and the `pOff` that computes it, the
`span` of bytes its 16 weights occupy and the alignment `wAlign` their loads need, the `qfill` statements, and the
weights `q W o j` they decode from the bytes of `W` at `o`. -/
structure Variant where
  rowBytes : Nat → Nat
  off : Nat → Nat
  span : Nat
  wAlign : Nat
  pOff : CExpr
  qfill : List CStmt
  q : ByteMemory.Bytes → Nat → Nat → Float32

def coreG (V : Variant) (M N K : Nat) : Kernel :=
  ⟨5, [], [(.scalar .f32, 4 * M), (.scalar .f32, 16 * M), (.scalar .f32, M), (.scalar .f32, 16)],
    bodyG M N K (V.rowBytes K) V.pOff V.qfill⟩


/-- `pOff` gives the lane's byte offset `off k0` within a row for `k0` in slot 14. -/
def PSpec (C : M1Max.Contract) (V : Variant) : Prop :=
  ∀ (ctx : Ctx) (l : Locals) (sh : Shared) (k0 : Nat), l 14 = some (u32 k0) → k0 < 2 ^ 31 →
    (eval C ctx l V.pOff).run sh = some (u64 (V.off k0), sh)

/-- `qfill` reads the `span` weight bytes of `w` at `o` (through `p`, slot 25) and writes `q` (slot 26, thread memory
`qr`) with the decoded weights, changing only slots 27–29. -/
def QSpec (C : M1Max.Contract) (V : Variant) : Prop :=
  ∀ (ctx : Ctx) (l : Locals) (sh : Shared) (o wsize aw qr : Nat),
    sh.regions 1 = some ⟨.device, wsize, aw⟩ → aw % V.wAlign = 0 → o % V.wAlign = 0 → o + V.span ≤ wsize →
    sh.regions qr = some ⟨.thread, 64, 4⟩ →
    l 25 = some (.ptr ⟨1, ((o : Nat) : Int), .scalar .u8⟩) → l 26 = some (.ptr ⟨qr, 0, .scalar .f32⟩) →
    ∃ l' sh', Exec C ctx V.qfill l sh .normal l' sh' ∧ Footprint ctx (isR 1) (isR qr) sh sh' ∧
      (∀ j, j < 27 ∨ 29 < j → l' j = l j) ∧ ∀ j < 16, f32At (sh'.bytes qr) j = V.q (sh.bytes 1) o j

/-- The arithmetic a bit width's offsets meet: a lane's weights lie in its row, aligned. -/
structure Variant.Ok (V : Variant) : Prop where
  bound : ∀ K k0, K % 512 = 0 → k0 % 16 = 0 → k0 + 16 ≤ K → V.off k0 + V.span ≤ V.rowBytes K
  align : ∀ K k0 n, K % 512 = 0 → k0 % 16 = 0 → (n * V.rowBytes K + V.off k0) % V.wAlign = 0
  rb : ∀ K, K < 2 ^ 31 → V.rowBytes K < 2 ^ 31

/-! ## Expected outputs

On the bf16 elements of `x` [M, K], `scales` and `biases` [N, K/64] and the bytes of `w` (decoded by the bit
width's `q`). Lane `L` of the SIMD-group owning output row `n` handles, at K step `t`, the 16 values of each row of `x`
from `k0 = 16 L + 512 t`, row `n`'s 16 weights there and the scale and bias of group `k0 / 64`. -/

section Expected
variable (C : M1Max.Contract)

def zero : Float32 := Val.ofF32Bits 0

/-- `float(x[e])`. -/
def xf (X : ByteMemory.Bytes) (e : Nat) : Float32 := C.widen (bfAt X e)

/-- `(f.x + f.y) + (f.z + f.w)` for `f = float4(x[e … e + 3])`. -/
def quad (X : ByteMemory.Bytes) (e : Nat) : Float32 :=
  C.fadd (C.fadd (xf C X e) (xf C X (e + 1))) (C.fadd (xf C X (e + 2)) (xf C X (e + 3)))

/-- `sum` after the first `v` chunks of four values of `x` from element `o`: `sum += (f.x + f.y) + (f.z + f.w)`. -/
def xsum (X : ByteMemory.Bytes) (o : Nat) : Nat → Float32
  | 0 => zero
  | v + 1 => C.fadd (xsum X o v) (quad C X (o + 4 * v))

/-- `dot` after the first `j` terms: `dot = fma(q[j], xr[m][j], dot)` from 0. -/
def dot (q x : Nat → Float32) : Nat → Float32
  | 0 => zero
  | j + 1 => C.fma (q j) (x j) (dot q x j)

/-- `acc[r][m]` of lane `L` for output row `n` and row `m` of `x` after the first `t` K steps (`k0 = 16 L + 512 t`):
`acc = fma(s, dot, fma(b, xs[m], acc))`. -/
def acc (V : Variant) (K : Nat) (X W S B : ByteMemory.Bytes) (n m L : Nat) : Nat → Float32
  | 0 => zero
  | t + 1 =>
    C.fma (C.widen (bfAt S (n * (K / 64) + (16 * L + 512 * t) / 64)))
      (dot C (V.q W (n * V.rowBytes K + V.off (16 * L + 512 * t))) (fun j => xf C X (m * K + (16 * L + 512 * t) + j)) 16)
      (C.fma (C.widen (bfAt B (n * (K / 64) + (16 * L + 512 * t) / 64))) (xsum C X (m * K + (16 * L + 512 * t)) 4)
        (acc V K X W S B n m L t))

/-- `y[m][n] = T(simd_sum(acc[r][m]))` over the lanes of the SIMD-group owning row `n`, after the K/512 steps. -/
def yv (V : Variant) (K : Nat) (X W S B : ByteMemory.Bytes) (m n : Nat) : BF :=
  C.narrow (C.simdSum fun L => acc C V K X W S B n m L (K / 512))

/-- Byte `b` of `y` [M, N] bf16. -/
def expected (V : Variant) (M N K : Nat) (X W S B : ByteMemory.Bytes) (b : Nat) : BitVec 8 :=
  if b < 2 * (M * N) then (wordBytes 2 (Val.bf16Bits (yv C V K X W S B (b / 2 / N) (b / 2 % N)))).getD (b % 2) 0 else 0

end Expected

/-! ## Ownership and memory -/

/-- Thread `64 g + 32 s + i`, and its thread arrays `acc`, `xr`, `xs`, `q`. -/
def tid (g s i : Nat) : Nat := 64 * g + (32 * s + i)
def accR (T : Nat) : Nat := 4 * T + 5
def xrR (T : Nat) : Nat := 4 * T + 6
def xsR (T : Nat) : Nat := 4 * T + 7
def qR (T : Nat) : Nat := 4 * T + 8
def own (T r : Nat) : Prop := 4 * T + 5 ≤ r ∧ r < 4 * T + 9
/-- The input buffers. -/
def inR (r : Nat) : Prop := r < 4

/-- The launch's regions: x, w, scales, biases, y, and each thread's `acc`, `xr`, `xs`, `q`. -/
structure Shape (L : Launch) (V : Variant) (M N K ax aw as ab : Nat) : Prop where
  r0 : L.regions 0 = some ⟨.device, 2 * (M * K), ax⟩
  r1 : L.regions 1 = some ⟨.device, N * V.rowBytes K, aw⟩
  r2 : L.regions 2 = some ⟨.device, 2 * (N * (K / 64)), as⟩
  r3 : L.regions 3 = some ⟨.device, 2 * (N * (K / 64)), ab⟩
  r4 : L.regions 4 = some ⟨.device, 2 * (M * N), 16⟩
  ra : ∀ T, L.regions (accR T) = some ⟨.thread, 4 * (4 * M), 4⟩
  rx : ∀ T, L.regions (xrR T) = some ⟨.thread, 4 * (16 * M), 4⟩
  rs : ∀ T, L.regions (xsR T) = some ⟨.thread, 4 * M, 4⟩
  rq : ∀ T, L.regions (qR T) = some ⟨.thread, 64, 4⟩
  ax : ax % 8 = 0
  aw : aw % V.wAlign = 0
  as : as % 2 = 0
  ab : ab % 2 = 0

theorem Shape.input {L : Launch} {V : Variant} {M N K ax aw as ab : Nat} (h : Shape L V M N K ax aw as ab)
    (r : Nat) (hr : r < 4) : ∃ R : Region, L.regions r = some R ∧ R.space = .device := by
  rcases (show r = 0 ∨ r = 1 ∨ r = 2 ∨ r = 3 by omega) with rfl | rfl | rfl | rfl
  · exact ⟨_, h.r0, rfl⟩
  · exact ⟨_, h.r1, rfl⟩
  · exact ⟨_, h.r2, rfl⟩
  · exact ⟨_, h.r3, rfl⟩

/-- The template ints the proof covers. -/
structure Dims (M N K : Nat) : Prop where
  m0 : 0 < M
  m1 : M < 2 ^ 31
  n0 : 0 < N
  n8 : N % 8 = 0
  n1 : N < 2 ^ 31
  k0 : 0 < K
  k512 : K % 512 = 0
  k1 : K < 2 ^ 31

structure Env where
  L : Launch
  X : ByteMemory.Bytes
  W : ByteMemory.Bytes
  S : ByteMemory.Bytes
  B : ByteMemory.Bytes

/-- Writers of device bytes: element `m · N + n` of `y` by lane 0 of the SIMD-group owning row `n` (SIMD-group
`n % 8 / 4` of threadgroup `n / 8`), in device epoch 0. -/
def dev (N : Nat) (region byte : Nat) : Option Writer :=
  if region = 4 then some ⟨64 * (byte / 2 % N / 8) + 32 * (byte / 2 % N % 8 / 4), byte / 2 % N / 8, 0⟩ else none

/-- No threadgroup memory. -/
def tgo (_ _ _ _ : Nat) : Option Nat := none

/-- Memory once the elements `(m, n)` of `y` with `P m n` are written: inputs intact, those elements as expected, and
every access so far owned. -/
structure Mem (C : M1Max.Contract) (V : Variant) (M N K : Nat) (E : Env) (P : Nat → Nat → Prop) (sh : Shared) :
    Prop where
  regions : sh.regions = E.L.regions
  x : sh.bytes 0 = E.X
  w : sh.bytes 1 = E.W
  s : sh.bytes 2 = E.S
  b : sh.bytes 3 = E.B
  dEpoch : sh.deviceEpoch = 0
  y : ∀ a n, P a n → a < M ∧ n < N ∧ ∀ j < 2,
    sh.bytes 4 (2 * (a * N + n) + j) = (wordBytes 2 (Val.bf16Bits (yv C V K E.X E.W E.S E.B a n))).getD j 0
  log : ∀ a ∈ sh.log, Owned E.L (dev N) tgo a

section MemLemmas
variable {C : M1Max.Contract} {V : Variant} {M N K ax aw as ab : Nat} {E : Env} {P : Nat → Nat → Prop}
  {sh sh' : Shared}

/-- Reads of the inputs and writes of thread memory keep `Mem`. -/
theorem Mem.frame (h : Mem C V M N K E P sh) (hS : Shape E.L V M N K ax aw as ab) {ctx : Ctx} {R T : Nat → Prop}
    (hf : Footprint ctx R T sh sh') (hR : ∀ r, R r → r < 4) (hT : ∀ r, T r → 5 ≤ r) : Mem C V M N K E P sh' where
  regions := hf.regions.trans h.regions
  x := (hf.bytes 0 (fun h' => by have := hT 0 h'; omega)).trans h.x
  w := (hf.bytes 1 (fun h' => by have := hT 1 h'; omega)).trans h.w
  s := (hf.bytes 2 (fun h' => by have := hT 2 h'; omega)).trans h.s
  b := (hf.bytes 3 (fun h' => by have := hT 3 h'; omega)).trans h.b
  dEpoch := hf.dEpoch.trans h.dEpoch
  y a n hp := by
    obtain ⟨h1, h2, h3⟩ := h.y a n hp
    exact ⟨h1, h2, fun j hj => by rw [hf.bytes 4 (fun h' => by have := hT 4 h'; omega)]; exact h3 j hj⟩
  log a ha := by
    rcases hf.log a ha with ha | ⟨r, b, hr, rfl⟩
    · exact h.log a ha
    · obtain ⟨R', hR', hsp⟩ := hS.input r (hR r hr)
      exact owned_device_read E.L (dev N) tgo ctx sh r b R' hR' (by rw [hsp]; decide)
        (by simp [dev]; have := hR r hr; omega)

theorem Mem.mono (h : Mem C V M N K E P sh) {P' : Nat → Nat → Prop} (hP : ∀ a n, P' a n → P a n) :
    Mem C V M N K E P' sh :=
  { h with y := fun a n hp => h.y a n (hP a n hp) }

end MemLemmas

/-! ## A thread -/

/-- Lane `i` of SIMD-group `s` of threadgroup `g`. -/
structure Lane (ctx : Ctx) (g s i : Nat) : Prop where
  tg : ctx.coord .threadgroupPositionInGrid = u32x3 0 g 0
  lane : ctx.coord .threadIndexInSimdgroup = u32 i
  sg : ctx.coord .simdgroupIndexInThreadgroup = u32 s
  thread : ctx.thread = tid g s i
  group : ctx.group = g
  ta : ∀ j, ctx.threadArray j = 4 * tid g s i + 5 + j
  hs : s < 2
  hi : i < 32

/-- The inputs intact. -/
structure In (E : Env) (sh : Shared) : Prop where
  regions : sh.regions = E.L.regions
  x : sh.bytes 0 = E.X
  w : sh.bytes 1 = E.W
  s : sh.bytes 2 = E.S
  b : sh.bytes 3 = E.B

theorem In.frame {E : Env} {sh sh' : Shared} (h : In E sh) {ctx : Ctx} {R T : Nat → Prop} (hf : Footprint ctx R T sh sh')
    (hT : ∀ r, T r → 5 ≤ r) : In E sh' where
  regions := hf.regions.trans h.regions
  x := (hf.bytes 0 (fun h' => by have := hT 0 h'; omega)).trans h.x
  w := (hf.bytes 1 (fun h' => by have := hT 1 h'; omega)).trans h.w
  s := (hf.bytes 2 (fun h' => by have := hT 2 h'; omega)).trans h.s
  b := (hf.bytes 3 (fun h' => by have := hT 3 h'; omega)).trans h.b

theorem Mem.toIn {C : M1Max.Contract} {V : Variant} {M N K : Nat} {E : Env} {P : Nat → Nat → Prop} {sh : Shared}
    (h : Mem C V M N K E P sh) : In E sh := ⟨h.regions, h.x, h.w, h.s, h.b⟩

/-- The locals every phase keeps (slots 0–11). -/
structure Locs (V : Variant) (K g s i : Nat) (l : Locals) : Prop where
  x : l 0 = some (ptr 0)
  w : l 1 = some (.ptr ⟨1, 0, .scalar .u32⟩)
  sc : l 2 = some (ptr 2)
  bi : l 3 = some (ptr 3)
  y : l 4 = some (ptr 4)
  lane : l 5 = some (u32 i)
  sg : l 6 = some (u32 s)
  n0 : l 7 = some (u32 (4 * (2 * g + s)))
  rb : l 8 = some (u64 (V.rowBytes K))
  gr : l 9 = some (u32 (K / 64))
  wb : l 10 = some (.ptr ⟨1, 0, .scalar .u8⟩)
  acc : l 11 = some (fptr (accR (tid g s i)))

theorem Locs.keep {V : Variant} {K g s i : Nat} {l l' : Locals} (h : Locs V K g s i l) (hk : ∀ j, j < 12 → l' j = l j) :
    Locs V K g s i l' :=
  ⟨by rw [hk 0 (by omega)]; exact h.x, by rw [hk 1 (by omega)]; exact h.w, by rw [hk 2 (by omega)]; exact h.sc,
   by rw [hk 3 (by omega)]; exact h.bi, by rw [hk 4 (by omega)]; exact h.y, by rw [hk 5 (by omega)]; exact h.lane,
   by rw [hk 6 (by omega)]; exact h.sg, by rw [hk 7 (by omega)]; exact h.n0, by rw [hk 8 (by omega)]; exact h.rb,
   by rw [hk 9 (by omega)]; exact h.gr, by rw [hk 10 (by omega)]; exact h.wb, by rw [hk 11 (by omega)]; exact h.acc⟩

/-- Locals kept through `setLocal`s of other slots. -/
macro "keep" : tactic => `(tactic| (simp only [setLocal]; split_ifs <;> first | omega | rfl))

section Eval
variable (C : M1Max.Contract) {ctx : Ctx} {l : Locals} {sh sh₁ : Shared}

theorem eval_u64l {n : Nat} (h : n < 2 ^ 64) (sh : Shared) : (eval C ctx l (u64l n)).run sh = some (u64 n, sh) := by
  rw [← u64_lit h]; rfl

theorem eval_toU64 {e : CExpr} {x : Nat} (he : (eval C ctx l e).run sh = some (u32 x, sh₁)) (hx : x < 2 ^ 32) :
    (eval C ctx l (toU64 e)).run sh = some (u64 x, sh₁) :=
  eval_conv C he (convert_u64_u32 C x hx)

/-- Element `[x][y]` of a 2-D f32 thread array with rows of `stride`. -/
theorem eval_at2 {a : Nat} {u i : CExpr} {R x y stride : Nat} (ha : l a = some (fptr R))
    (hu : (eval C ctx l u).run sh = some (u32 x, sh)) (hx : x < 2 ^ 32)
    (hi : (eval C ctx l i).run sh = some (u32 y, sh)) (hy : y < 2 ^ 32) (hst : stride < 2 ^ 32)
    (hxs : x * stride < 2 ^ 64) :
    (eval C ctx l (at2 a u stride i)).run sh =
      some (.ptr ⟨R, ((4 * (x * stride + y) : Nat) : Int), .scalar .f32⟩, sh) := by
  have h1 : (eval C ctx l (.offset (.local a) (AffineRows3.u64 .mul (toU64 u) (u64l stride)))).run sh =
      some (.ptr ⟨R, ((0 + x * stride * (Ty.scalar .f32).bytes : Nat) : Int), .scalar .f32⟩, sh) :=
    eval_offset_u64 C (o := 0) (eval_local' C (ctx := ctx) ha sh)
    (eval_int C (by decide) (eval_toU64 C hu hx) (eval_u64l C (by omega) sh) (binary_mul_u64 C x stride)) hxs
  have h2 := eval_offset_u32 C h1 hi hy
  rw [show 0 + x * stride * (Ty.scalar .f32).bytes + y * (Ty.scalar .f32).bytes = 4 * (x * stride + y) by
    simp [Ty.bytes, Scalar.bytes]; ring] at h2
  exact h2

/-- Element `y` of a 1-D f32 thread array. -/
theorem eval_at1 {a b : Nat} {R y : Nat} (ha : l a = some (fptr R)) (hb : l b = some (u32 y)) (hy : y < 2 ^ 32)
    (sh : Shared) :
    (eval C ctx l (.offset (.local a) (.local b))).run sh = some (.ptr ⟨R, ((4 * y : Nat) : Int), .scalar .f32⟩, sh) := by
  have := eval_offset_u32 C (o := 0) (eval_local' C (ctx := ctx) ha sh) (eval_local' C hb sh) hy
  rwa [show 0 + y * (Ty.scalar .f32).bytes = 4 * y by simp [Ty.bytes, Scalar.bytes]; ring] at this

theorem eval_load_th {p : CExpr} {R size e : Nat}
    (hp : (eval C ctx l p).run sh = some (.ptr ⟨R, ((4 * e : Nat) : Int), .scalar .f32⟩, sh))
    (hr : sh.regions R = some ⟨.thread, size, 4⟩) (hb : 4 * e + 4 ≤ size) :
    (eval C ctx l (.load (.scalar .f32) p)).run sh = some (.f32 (f32At (sh.bytes R) e), sh) :=
  (eval_load C _ _ _ _ _ _ _ hp).trans (load_f32_thread ctx sh R size e hr hb)

theorem eval_comp {k : Nat} {s : Scalar} {xs : List Val} {x : Val} (hk : l k = some (.vec s xs)) (j : Nat)
    (hx : xs[j]? = some x) (sh : Shared) : (eval C ctx l (comp k j)).run sh = some (x, sh) :=
  eval_component C (eval_local' C hk sh) (eval_lit C _ _ _ _) (natOf_unsigned _ rfl) hx

theorem eval_u32bin {op : Core.BinOp} {a b : CExpr} {x y : Nat} {z : Val}
    (ha : (eval C ctx l a).run sh = some (u32 x, sh)) (hb : (eval C ctx l b).run sh = some (u32 y, sh))
    (hz : binary C op .u32 (u32 x) (u32 y) = some z) : (eval C ctx l (AffineRows3.u32 op a b)).run sh = some (z, sh) :=
  eval_int C (by decide) ha hb hz

theorem eval_u64bin {op : Core.BinOp} {a b : CExpr} {x y : Nat} {z : Val}
    (ha : (eval C ctx l a).run sh = some (u64 x, sh)) (hb : (eval C ctx l b).run sh = some (u64 y, sh))
    (hz : binary C op .u64 (u64 x) (u64 y) = some z) : (eval C ctx l (AffineRows3.u64 op a b)).run sh = some (z, sh) :=
  eval_int C (by decide) ha hb hz

end Eval

section Thread
variable {C : M1Max.Contract} {V : Variant} {M N K ax aw as ab : Nat} {E : Env} {ctx : Ctx} {g s i : Nat}

/-- `xr[m][4 v + k] = f.k`. -/
theorem exec_xrStore (hS : Shape E.L V M N K ax aw as ab) (k : Nat) (hk : k < 4) {m v : Nat} (hv : v < 4) (hm : m < M)
    (hM1 : M < 2 ^ 31) {xs : List Val} {y : Float32} {l : Locals} {sh : Shared} (hreg : sh.regions = E.L.regions)
    (h15 : l 15 = some (fptr (xrR (tid g s i)))) (h17 : l 17 = some (u32 m)) (h20 : l 20 = some (u32 v))
    (h21 : l 21 = some (.vec .bf16 xs)) (hx : xs[k]? = some (.f32 y)) :
    Exec C ctx [AffineRows3.xrStore k] l sh .normal l (wrT sh (xrR (tid g s i)) (4 * (m * 16 + (4 * v + k))) y) := by
  have h4v : (eval C ctx l (AffineRows3.u32 .mul (u32l 4) (.local 20))).run sh = some (u32 (4 * v), sh) :=
    eval_u32bin C (eval_u32l C (by norm_num) sh) (eval_local' C h20 sh) (binary_mul_u32 C 4 v)
  have hidx : (eval C ctx l (if k = 0 then AffineRows3.u32 .mul (u32l 4) (.local 20)
      else AffineRows3.u32 .add (AffineRows3.u32 .mul (u32l 4) (.local 20)) (u32l k))).run sh = some (u32 (4 * v + k), sh) := by
    split
    · subst_vars; exact h4v
    · exact eval_u32bin C h4v (eval_u32l C (by omega) sh) (binary_add_u32 C (4 * v) k)
  have hp := eval_at2 C (stride := 16) h15 (eval_local' C h17 sh) (by omega) hidx (by omega) (by norm_num) (by omega)
  have hst := store_f32_thread ctx sh (xrR (tid g s i)) (4 * (16 * M)) (m * 16 + (4 * v + k)) y
    (by rw [hreg]; exact hS.rx _) (by omega)
  exact .store hp (eval_comp C h21 k hx sh) hst (.nil _ _)

/-- One chunk `v` of four values of row `m` of `x` from element `o`: `f`, its values into `xr[m]`, `sum += …`. -/
theorem exec_chunk (hS : Shape E.L V M N K ax aw as ab) {m v o : Nat} (hv : v < 4) (hm : m < M)
    (ho4 : o % 4 = 0) (hob : o + 16 ≤ M * K) (hM1 : M < 2 ^ 31) {sm : Float32} {l : Locals} {sh : Shared} (hI : In E sh)
    (h15 : l 15 = some (fptr (xrR (tid g s i)))) (h17 : l 17 = some (u32 m))
    (h18 : l 18 = some (.ptr ⟨0, ((2 * o : Nat) : Int), .vec .bf16 4⟩)) (h19 : l 19 = some (.f32 sm))
    (h20 : l 20 = some (u32 v)) :
    ∃ l' sh', Exec C ctx AffineRows3.chunkBody l sh .normal l' sh' ∧ (∀ j, j < 19 ∨ j = 20 → l' j = l j) ∧
      l' 19 = some (.f32 (C.fadd sm (quad C E.X (o + 4 * v)))) ∧
      Footprint ctx inR (isR (xrR (tid g s i))) sh sh' ∧
      ∀ e, f32At (sh'.bytes (xrR (tid g s i))) e =
        if m * 16 + 4 * v ≤ e ∧ e < m * 16 + 4 * v + 4 then xf C E.X (o + 4 * v + (e - (m * 16 + 4 * v)))
        else f32At (sh.bytes (xrR (tid g s i))) e := by
  -- `f = float4(xp[v])`
  have hp := eval_offset_u32 C (eval_local' C (ctx := ctx) h18 sh) (eval_local' C h20 sh) (by omega)
  rw [show 2 * o + v * (Ty.vec .bf16 4).bytes = 2 * (o + 4 * v) by simp [Ty.bytes, Scalar.bytes]; ring] at hp
  have hld := load_vec4_bf16 ctx sh 0 (2 * (M * K)) ax (o + 4 * v) (by rw [hI.regions]; exact hS.r0) hS.ax (by omega)
    (by omega)
  rw [hI.x] at hld
  generalize hxs : [Val.f32 (xf C E.X (o + 4 * v)), .f32 (xf C E.X (o + 4 * v + 1)), .f32 (xf C E.X (o + 4 * v + 2)),
    .f32 (xf C E.X (o + 4 * v + 3))] = xs
  have hf : (eval C ctx l (.conv .f32 (.load (.vec .bf16 4) (.offset (.local 18) (.local 20))))).run sh =
      some (.vec .bf16 xs, rdn ctx sh 0 (2 * (o + 4 * v)) 8) := by
    rw [← hxs]; exact eval_conv C ((eval_load C _ _ _ _ _ _ _ hp).trans hld) rfl
  generalize hsh₁ : rdn ctx sh 0 (2 * (o + 4 * v)) 8 = sh₁ at hf
  have hF₁ : Footprint ctx inR (isR (xrR (tid g s i))) sh sh₁ := by
    rw [← hsh₁]; exact Footprint.rdn _ _ _ _ (show inR 0 by simp [inR])
  have hreg₁ : sh₁.regions = E.L.regions := hF₁.regions.trans hI.regions
  generalize hl₁ : setLocal l 21 (.vec .bf16 xs) = l₁
  have g15 : l₁ 15 = some (fptr (xrR (tid g s i))) := by rw [← hl₁, setLocal_other _ _ (by omega)]; exact h15
  have g17 : l₁ 17 = some (u32 m) := by rw [← hl₁, setLocal_other _ _ (by omega)]; exact h17
  have g20 : l₁ 20 = some (u32 v) := by rw [← hl₁, setLocal_other _ _ (by omega)]; exact h20
  have g21 : l₁ 21 = some (.vec .bf16 xs) := by rw [← hl₁]; exact setLocal_same _ _ _
  -- the four stores
  have hR : ∀ sh : Shared, sh.regions = sh₁.regions → sh.regions = E.L.regions := fun sh h => h.trans hreg₁
  have e0 := exec_xrStore (C := C) (ctx := ctx) hS 0 (by omega) hv hm hM1 hreg₁ g15 g17 g20 g21
    (by rw [← hxs]; rfl)
  generalize hsh₂ : wrT sh₁ (xrR (tid g s i)) (4 * (m * 16 + (4 * v + 0))) (xf C E.X (o + 4 * v)) = sh₂ at e0
  have hF₂ : Footprint ctx inR (isR (xrR (tid g s i))) sh₁ sh₂ := by rw [← hsh₂]; exact Footprint.wrT _ _ _ _ rfl
  have e1 := exec_xrStore (C := C) (ctx := ctx) hS 1 (by omega) hv hm hM1 (hR _ hF₂.regions) g15 g17 g20 g21
    (by rw [← hxs]; rfl)
  generalize hsh₃ : wrT sh₂ (xrR (tid g s i)) (4 * (m * 16 + (4 * v + 1))) (xf C E.X (o + 4 * v + 1)) = sh₃ at e1
  have hF₃ : Footprint ctx inR (isR (xrR (tid g s i))) sh₂ sh₃ := by rw [← hsh₃]; exact Footprint.wrT _ _ _ _ rfl
  have e2 := exec_xrStore (C := C) (ctx := ctx) hS 2 (by omega) hv hm hM1 (hR _ (hF₃.regions.trans hF₂.regions))
    g15 g17 g20 g21 (by rw [← hxs]; rfl)
  generalize hsh₄ : wrT sh₃ (xrR (tid g s i)) (4 * (m * 16 + (4 * v + 2))) (xf C E.X (o + 4 * v + 2)) = sh₄ at e2
  have hF₄ : Footprint ctx inR (isR (xrR (tid g s i))) sh₃ sh₄ := by rw [← hsh₄]; exact Footprint.wrT _ _ _ _ rfl
  have e3 := exec_xrStore (C := C) (ctx := ctx) hS 3 (by omega) hv hm hM1
    (hR _ (hF₄.regions.trans (hF₃.regions.trans hF₂.regions))) g15 g17 g20 g21 (by rw [← hxs]; rfl)
  generalize hsh₅ : wrT sh₄ (xrR (tid g s i)) (4 * (m * 16 + (4 * v + 3))) (xf C E.X (o + 4 * v + 3)) = sh₅ at e3
  have hF₅ : Footprint ctx inR (isR (xrR (tid g s i))) sh₄ sh₅ := by rw [← hsh₅]; exact Footprint.wrT _ _ _ _ rfl
  -- `sum += (f.x + f.y) + (f.z + f.w)`
  have c : ∀ k (hk : k < 4), (eval C ctx l₁ (comp 21 k)).run sh₅ = some (.f32 (xf C E.X (o + 4 * v + k)), sh₅) := by
    intro k hk
    refine eval_comp C g21 k ?_ sh₅
    rw [← hxs]
    rcases (show k = 0 ∨ k = 1 ∨ k = 2 ∨ k = 3 by omega) with rfl | rfl | rfl | rfl <;> rfl
  have hsum : (eval C ctx l₁ (fadd (.local 19) (fadd (fadd (comp 21 0) (comp 21 1)) (fadd (comp 21 2) (comp 21 3))))).run sh₅ =
      some (.f32 (C.fadd sm (quad C E.X (o + 4 * v))), sh₅) :=
    eval_f32 C (.inr ⟨rfl, rfl⟩) (eval_local' C (by rw [← hl₁, setLocal_other _ _ (by omega)]; exact h19) sh₅)
      (eval_f32 C (.inr ⟨rfl, rfl⟩) (eval_f32 C (.inr ⟨rfl, rfl⟩) (c 0 (by omega)) (c 1 (by omega)) rfl)
        (eval_f32 C (.inr ⟨rfl, rfl⟩) (c 2 (by omega)) (c 3 (by omega)) rfl) rfl) rfl
  refine ⟨setLocal l₁ 19 (.f32 (C.fadd sm (quad C E.X (o + 4 * v)))), sh₅, ?_, fun j hj => ?_, setLocal_same _ _ _,
    hF₁.trans (hF₂.trans (hF₃.trans (hF₄.trans hF₅))), fun e => ?_⟩
  · rw [← hl₁] at e0 e1 e2 e3 hsum ⊢
    exact .set hf (Exec.append e0 (Exec.append e1 (Exec.append e2 (Exec.append e3 (.set hsum (.nil _ _))))))
  · rw [← hl₁]; keep
  · rw [← hsh₅, wrT_bytes_same, f32At_write, ← hsh₄, wrT_bytes_same, f32At_write, ← hsh₃, wrT_bytes_same, f32At_write,
      ← hsh₂, wrT_bytes_same, f32At_write]
    have hb₁ : sh₁.bytes = sh.bytes := by rw [← hsh₁]; rfl
    rw [hb₁]
    split_ifs <;> first | omega | (congr 1; omega) | rfl

theorem Dims.mk_lt {M N K : Nat} (h : Dims M N K) : M * K < 2 ^ 62 ∧ N * K < 2 ^ 62 ∧ M * N < 2 ^ 62 := by
  have h1 := h.m1; have h2 := h.n1; have h3 := h.k1
  refine ⟨?_, ?_, ?_⟩ <;> nlinarith

theorem succ_mul_le {a A K : Nat} (h : a < A) : a * K + K ≤ A * K := by
  have := Nat.mul_le_mul_right K h
  rwa [Nat.succ_mul] at this

/-- Row `m` of `x` at `k0`: `xp`, `sum`, the four chunks, `xs[m] = sum`. -/
theorem exec_xrow (hS : Shape E.L V M N K ax aw as ab) (hD : Dims M N K) {k0 m : Nat} (hk0 : k0 % 16 = 0)
    (hk0K : k0 + 16 ≤ K) (hm : m < M) {l : Locals} {sh : Shared} (hI : In E sh) (hloc : Locs V K g s i l)
    (h14 : l 14 = some (u32 k0)) (h15 : l 15 = some (fptr (xrR (tid g s i))))
    (h16 : l 16 = some (fptr (xsR (tid g s i)))) (h17 : l 17 = some (u32 m)) :
    ∃ l' sh', Exec C ctx (AffineRows3.xRow K) l sh .normal l' sh' ∧ (∀ j, j < 18 → l' j = l j) ∧
      Footprint ctx inR (fun r => r = xrR (tid g s i) ∨ r = xsR (tid g s i)) sh sh' ∧
      (∀ e, f32At (sh'.bytes (xrR (tid g s i))) e =
        if m * 16 ≤ e ∧ e < m * 16 + 16 then xf C E.X (m * K + k0 + (e - m * 16))
        else f32At (sh.bytes (xrR (tid g s i))) e) ∧
      (∀ e, f32At (sh'.bytes (xsR (tid g s i))) e =
        if e = m then xsum C E.X (m * K + k0) 4 else f32At (sh.bytes (xsR (tid g s i))) e) := by
  obtain ⟨hMK, -, -⟩ := hD.mk_lt
  have hM1 := hD.m1
  have hmK : m * K + K ≤ M * K := succ_mul_le hm
  have hk : K < 2 ^ 31 := hD.k1
  -- `xp = x + m * K + k0`
  have hx1 : (eval C ctx l (.offset (.local 0) (AffineRows3.u64 .mul (toU64 (.local 17)) (u64l K)))).run sh =
      some (.ptr ⟨0, ((0 + m * K * (Ty.scalar .bf16).bytes : Nat) : Int), .scalar .bf16⟩, sh) :=
    eval_offset_u64 C (o := 0) (eval_local' C (ctx := ctx) hloc.x sh)
      (eval_u64bin C (eval_toU64 C (eval_local' C h17 sh) (by omega)) (eval_u64l C (by omega) sh) (binary_mul_u64 C m K))
      (by omega)
  have hx2 := eval_offset_u32 C hx1 (eval_local' C h14 sh) (by omega)
  have hxp : (eval C ctx l (.ptrCast (.vec .bf16 4) (.offset (.offset (.local 0)
      (AffineRows3.u64 .mul (toU64 (.local 17)) (u64l K))) (.local 14)))).run sh =
      some (.ptr ⟨0, ((2 * (m * K + k0) : Nat) : Int), .vec .bf16 4⟩, sh) := by
    have := eval_ptrCast C (t := .vec .bf16 4) hx2
    rw [show 0 + m * K * (Ty.scalar .bf16).bytes + k0 * (Ty.scalar .bf16).bytes = 2 * (m * K + k0) by
      simp [Ty.bytes, Scalar.bytes]; ring] at this
    exact this
  generalize hl₂ : setLocal (setLocal l 18 (.ptr ⟨0, ((2 * (m * K + k0) : Nat) : Int), .vec .bf16 4⟩)) 19 (.f32 (zero)) = l₂
  -- the chunks
  have ho4 : (m * K + k0) % 4 = 0 := by
    have : 4 ∣ m * K := Dvd.dvd.mul_left (show 4 ∣ K by have := hD.k512; omega) m
    omega
  obtain ⟨l₃, sh₃, hloop, ⟨k₃, h19₃, hF₃, hx₃⟩⟩ := forU_exec C (ctx := ctx) (i := 20) (n := 4) (body := AffineRows3.chunkBody)
    (by norm_num)
    (fun v l' sh' => (∀ j, j < 19 → l' j = l₂ j) ∧ l' 19 = some (.f32 (xsum C E.X (m * K + k0) v)) ∧
      Footprint ctx inR (isR (xrR (tid g s i))) sh sh' ∧
      ∀ e, f32At (sh'.bytes (xrR (tid g s i))) e =
        if m * 16 ≤ e ∧ e < m * 16 + 4 * v then xf C E.X (m * K + k0 + (e - m * 16)) else f32At (sh.bytes (xrR (tid g s i))) e)
    (fun v hv l' sh' ⟨hk, h19', hF, hx⟩ h20 => by
      have hI' := hI.frame hF (fun r hr => by unfold isR xrR at hr; omega)
      obtain ⟨l'', sh'', hb, hk', h19'', hF', hx'⟩ := exec_chunk (C := C) (ctx := ctx) (g := g) (s := s) (i := i) hS hv hm ho4
        (by omega) hD.m1 hI' (by rw [hk 15 (by omega), ← hl₂]; simp [setLocal, h15])
        (by rw [hk 17 (by omega), ← hl₂]; simp [setLocal, h17]) (by rw [hk 18 (by omega), ← hl₂]; simp [setLocal])
        h19' h20
      refine ⟨l'', sh'', hb, by rw [hk' 20 (.inr rfl)]; exact h20, fun j hj => ?_, ?_, hF.trans hF', fun e => ?_⟩
      · rw [setLocal_other _ _ (by omega), hk' j (.inl hj), hk j hj]
      · rw [setLocal_other _ _ (by omega), h19'']; rfl
      · rw [hx' e, hx e]
        split_ifs <;> first | omega | (congr 1; omega) | rfl)
    (⟨fun j hj => by keep, by rw [setLocal_other _ _ (by omega), ← hl₂]; simp [setLocal]; rfl,
      Footprint.refl _ _ _ _, fun e => by rw [ite_eq_right (by omega)]⟩)
  -- `xs[m] = sum`
  have hreg₃ : sh₃.regions = E.L.regions := hF₃.regions.trans hI.regions
  have hp := eval_at1 C (ctx := ctx) (l := l₃) (R := xsR (tid g s i)) (y := m) (by rw [k₃ 16 (by omega), ← hl₂]; simp [setLocal, h16])
    (by rw [k₃ 17 (by omega), ← hl₂]; simp [setLocal, h17]) (by omega) sh₃
  have hst := store_f32_thread ctx sh₃ (xsR (tid g s i)) (4 * M) m (xsum C E.X (m * K + k0) 4)
    (by rw [hreg₃]; exact hS.rs _) (by omega)
  refine ⟨l₃, wrT sh₃ (xsR (tid g s i)) (4 * m) (xsum C E.X (m * K + k0) 4), ?_, fun j hj => ?_, ?_, fun e => ?_,
    fun e => ?_⟩
  · rw [← hl₂] at hloop
    exact Exec.append (.set hxp (.set (eval_lit C _ _ _ _) hloop)) (.store hp (eval_local' C h19₃ _) hst (.nil _ _))
  · rw [k₃ j (by omega), ← hl₂]; keep
  · exact (hF₃.mono (fun _ h => h) (fun r h => .inl h)).trans (Footprint.wrT _ _ _ _ (.inr rfl))
  · rw [wrT_bytes_other _ _ _ (by unfold xrR xsR; omega), hx₃ e]
  · rw [wrT_bytes_same, f32At_write, hF₃.bytes _ (by unfold isR xrR xsR; omega)]

/-- The rows of `x` at `k0`: `xr[m][j] = x[m][k0 + j]` and `xs[m]` their sum, for every `m`. -/
theorem exec_xrows (hS : Shape E.L V M N K ax aw as ab) (hD : Dims M N K) {k0 : Nat} (hk0 : k0 % 16 = 0)
    (hk0K : k0 + 16 ≤ K) {l : Locals} {sh : Shared} (hI : In E sh) (hloc : Locs V K g s i l)
    (h14 : l 14 = some (u32 k0)) (h15 : l 15 = some (fptr (xrR (tid g s i))))
    (h16 : l 16 = some (fptr (xsR (tid g s i)))) :
    ∃ l' sh', Exec C ctx (forU 17 M (AffineRows3.xRow K)) l sh .normal l' sh' ∧ (∀ j, j < 17 → l' j = l j) ∧
      Footprint ctx inR (fun r => r = xrR (tid g s i) ∨ r = xsR (tid g s i)) sh sh' ∧
      (∀ m < M, ∀ j < 16, f32At (sh'.bytes (xrR (tid g s i))) (m * 16 + j) = xf C E.X (m * K + k0 + j)) ∧
      (∀ m < M, f32At (sh'.bytes (xsR (tid g s i))) m = xsum C E.X (m * K + k0) 4) := by
  obtain ⟨l', sh', hex, hk, hF, hx, hs⟩ := forU_exec C (ctx := ctx) (i := 17) (n := M) (body := AffineRows3.xRow K)
    (by have := hD.m1; omega)
    (fun m l' sh' => (∀ j, j < 17 → l' j = l j) ∧
      Footprint ctx inR (fun r => r = xrR (tid g s i) ∨ r = xsR (tid g s i)) sh sh' ∧
      (∀ m' < m, ∀ j < 16, f32At (sh'.bytes (xrR (tid g s i))) (m' * 16 + j) = xf C E.X (m' * K + k0 + j)) ∧
      (∀ m' < m, f32At (sh'.bytes (xsR (tid g s i))) m' = xsum C E.X (m' * K + k0) 4))
    (fun m hm l' sh' ⟨hk, hF, hx, hs⟩ h17 => by
      have hI' := hI.frame hF (fun r hr => by unfold xrR xsR at hr; omega)
      obtain ⟨l'', sh'', hb, hk', hF', hx', hs'⟩ := exec_xrow (C := C) (ctx := ctx) hS hD hk0 hk0K hm hI'
        (hloc.keep fun j hj => hk j (by omega)) (by rw [hk 14 (by omega)]; exact h14)
        (by rw [hk 15 (by omega)]; exact h15) (by rw [hk 16 (by omega)]; exact h16) h17
      refine ⟨l'', sh'', hb, by rw [hk' 17 (by omega)]; exact h17, fun j hj => ?_, hF.trans hF', fun m' hm' j hj => ?_,
        fun m' hm' => ?_⟩
      · rw [setLocal_other _ _ (by omega), hk' j (by omega), hk j hj]
      · rw [hx' _]
        by_cases hmm : m' = m
        · subst hmm; rw [ite_eq_left (by omega)]; congr 1; omega
        · rw [ite_eq_right (by omega)]; exact hx m' (by omega) j hj
      · rw [hs' _]
        by_cases hmm : m' = m
        · subst hmm; rw [ite_eq_left rfl]
        · rw [ite_eq_right hmm]; exact hs m' (by omega))
    (⟨fun j hj => by keep, Footprint.refl _ _ _ _, fun _ h => absurd h (Nat.not_lt_zero _),
      fun _ h => absurd h (Nat.not_lt_zero _)⟩)
  exact ⟨l', sh', hex, hk, hF, hx, hs⟩

/-- `acc` once the entries before `(r0, m0)` of K step `t` are updated: `acc[r][m]` holds `t + 1` steps before,
`t` after. -/
def AccP (C : M1Max.Contract) (V : Variant) (M K : Nat) (E : Env) (n0 i t r0 m0 : Nat) (B : ByteMemory.Bytes) : Prop :=
  ∀ r < 4, ∀ m < M, f32At B (r * M + m) =
    acc C V K E.X E.W E.S E.B (n0 + r) m i (if r < r0 ∨ (r = r0 ∧ m < m0) then t + 1 else t)

/-- `dot` over the 16 weights `q` and values `xr[m]`. -/
theorem exec_dot (hS : Shape E.L V M N K ax aw as ab) (hD : Dims M N K) {m : Nat} (hm : m < M) {l : Locals}
    {sh : Shared} (hreg : sh.regions = E.L.regions)
    (h15 : l 15 = some (fptr (xrR (tid g s i)))) (h26 : l 26 = some (fptr (qR (tid g s i))))
    (h32 : l 32 = some (u32 m)) (qv xv : Nat → Float32) (hq : ∀ j < 16, f32At (sh.bytes (qR (tid g s i))) j = qv j)
    (hx : ∀ j < 16, f32At (sh.bytes (xrR (tid g s i))) (m * 16 + j) = xv j) :
    ∃ l', Exec C ctx (forU 34 16 dotBody) (setLocal l 33 (.f32 zero)) sh .normal l' sh ∧
      (∀ j, j ≠ 33 → j ≠ 34 → l' j = l j) ∧ l' 33 = some (.f32 (dot C qv xv 16)) := by
  have hM1 := hD.m1
  obtain ⟨l', sh', hex, rfl, hk, h33⟩ := forU_exec C (ctx := ctx) (i := 34) (n := 16) (body := dotBody)
    (l := setLocal l 33 (.f32 zero)) (by norm_num)
    (fun j l' sh' => sh' = sh ∧ (∀ x, x ≠ 33 → x ≠ 34 → l' x = l x) ∧ l' 33 = some (.f32 (dot C qv xv j)))
    (fun j hj l' sh' ⟨hsh, hk, h33⟩ h34 => by
      subst hsh
      have ha := eval_load_th C (eval_at1 C (ctx := ctx) (by rw [hk 26 (by omega) (by omega)]; exact h26) h34 (by omega) sh')
        (by rw [hreg]; exact hS.rq _) (by omega)
      have hb := eval_load_th C (eval_at2 C (ctx := ctx) (stride := 16) (by rw [hk 15 (by omega) (by omega)]; exact h15)
        (eval_local' C (by rw [hk 32 (by omega) (by omega)]; exact h32) sh') (by omega) (eval_local' C h34 sh') (by omega)
        (by norm_num) (by omega)) (by rw [hreg]; exact hS.rx _) (by omega)
      rw [hq j hj] at ha
      rw [hx j hj] at hb
      refine ⟨_, sh', .set (eval_fma C ha hb (eval_local' C h33 sh')) (.nil _ _), by rw [setLocal_other _ _ (by omega)]; exact h34,
        rfl, fun x h1 h2 => by rw [setLocal_other _ _ (by omega), setLocal_other _ _ h1]; exact hk x h1 h2, ?_⟩
      rw [setLocal_other _ _ (by omega), setLocal_same]; rfl)
    ⟨rfl, fun x h1 h2 => by keep, by rw [setLocal_other _ _ (by omega), setLocal_same]; rfl⟩
  exact ⟨l', hex, hk, h33⟩

/-- Entry `m` of output row `r`: `dot`, then `acc[r][m] = fma(s, dot, fma(b, xs[m], acc[r][m]))`. -/
theorem exec_mbody (hS : Shape E.L V M N K ax aw as ab) (hD : Dims M N K) {t r m : Nat}
    (hr : r < 4) (hm : m < M) {l : Locals} {sh : Shared} (hreg : sh.regions = E.L.regions) (hloc : Locs V K g s i l)
    (h15 : l 15 = some (fptr (xrR (tid g s i)))) (h16 : l 16 = some (fptr (xsR (tid g s i))))
    (h23 : l 23 = some (u32 r)) (h26 : l 26 = some (fptr (qR (tid g s i))))
    (h30 : l 30 = some (.f32 (C.widen (bfAt E.S ((4 * (2 * g + s) + r) * (K / 64) + (16 * i + 512 * t) / 64)))))
    (h31 : l 31 = some (.f32 (C.widen (bfAt E.B ((4 * (2 * g + s) + r) * (K / 64) + (16 * i + 512 * t) / 64)))))
    (h32 : l 32 = some (u32 m))
    (hq : ∀ j < 16, f32At (sh.bytes (qR (tid g s i))) j =
      V.q E.W ((4 * (2 * g + s) + r) * V.rowBytes K + V.off (16 * i + 512 * t)) j)
    (hx : ∀ m < M, ∀ j < 16, f32At (sh.bytes (xrR (tid g s i))) (m * 16 + j) = xf C E.X (m * K + (16 * i + 512 * t) + j))
    (hs : ∀ m < M, f32At (sh.bytes (xsR (tid g s i))) m = xsum C E.X (m * K + (16 * i + 512 * t)) 4)
    (hacc : AccP C V M K E (4 * (2 * g + s)) i t r m (sh.bytes (accR (tid g s i)))) :
    ∃ l' sh', Exec C ctx (mBody M) l sh .normal l' sh' ∧ (∀ j, j < 33 → l' j = l j) ∧
      Footprint ctx inR (isR (accR (tid g s i))) sh sh' ∧
      AccP C V M K E (4 * (2 * g + s)) i t r (m + 1) (sh'.bytes (accR (tid g s i))) := by
  have hM1 := hD.m1
  obtain ⟨l₁, hdot, hk₁, h33⟩ := exec_dot (C := C) (ctx := ctx) hS hD hm hreg h15 h26 h32 _ _ hq (hx m hm)
  have g11 : l₁ 11 = some (fptr (accR (tid g s i))) := by rw [hk₁ 11 (by omega) (by omega)]; exact hloc.acc
  have g23 : l₁ 23 = some (u32 r) := by rw [hk₁ 23 (by omega) (by omega)]; exact h23
  have g32 : l₁ 32 = some (u32 m) := by rw [hk₁ 32 (by omega) (by omega)]; exact h32
  have hidx := idx_lt (M := M) hr hm
  have hp := eval_at2 C (ctx := ctx) (stride := M) g11 (eval_local' C g23 sh) (by omega) (eval_local' C g32 sh) (by omega)
    (by omega) (by have : r * M ≤ 4 * M := Nat.mul_le_mul_right _ hr.le; omega)
  have hxs := eval_load_th C (eval_at1 C (ctx := ctx) (by rw [hk₁ 16 (by omega) (by omega)]; exact h16) g32 (by omega) sh)
    (by rw [hreg]; exact hS.rs _) (by omega)
  have hold := eval_load_th C hp (by rw [hreg]; exact hS.ra _) (by omega)
  have hv := eval_fma C (eval_local' C (by rw [hk₁ 30 (by omega) (by omega)]; exact h30) sh) (eval_local' C h33 sh)
    (eval_fma C (eval_local' C (by rw [hk₁ 31 (by omega) (by omega)]; exact h31) sh) hxs hold)
  rw [hs m hm, hacc r hr m hm, ite_eq_right (by omega)] at hv
  have hv' : (eval C ctx l₁ (.fma (.local 30) (.local 33) (.fma (.local 31) (.load (.scalar .f32) (.offset (.local 16)
      (.local 32))) (.load (.scalar .f32) (AffineRows3.accAt M 23))))).run sh =
      some (Val.f32 (acc C V K E.X E.W E.S E.B (4 * (2 * g + s) + r) m i (t + 1)), sh) := hv
  have hst := store_f32_thread ctx sh (accR (tid g s i)) (4 * (4 * M)) (r * M + m)
    (acc C V K E.X E.W E.S E.B (4 * (2 * g + s) + r) m i (t + 1)) (by rw [hreg]; exact hS.ra _) (by omega)
  refine ⟨l₁, _, (Exec.append (.set (eval_lit C _ _ _ _) hdot) (.store hp hv' hst (.nil _ _)) :
      Exec C ctx ([_] ++ _ ++ [_]) _ _ _ _ _),
    fun j hj => hk₁ j (by omega) (by omega), Footprint.wrT _ _ _ _ rfl, fun r' hr' m' hm' => ?_⟩
  rw [wrT_bytes_same, f32At_write]
  by_cases he : r' * M + m' = r * M + m
  · obtain ⟨rfl, rfl⟩ := idx_inj hm' hm he
    rw [ite_eq_left rfl, ite_eq_left (by omega)]
  · rw [ite_eq_right he, hacc r' hr' m' hm']
    have hne : ¬ (r' = r ∧ m' = m) := fun ⟨h1, h2⟩ => he (by rw [h1, h2])
    congr 1
    by_cases hc : r' < r ∨ (r' = r ∧ m' < m)
    · rw [ite_eq_left hc, ite_eq_left (by omega)]
    · rw [ite_eq_right hc, ite_eq_right (by omega)]

/-- `float(scales[n · groups + g])` (or `biases`). -/
theorem eval_sb (hD : Dims M N K) {reg n gq a : Nat} {l : Locals} {sh : Shared} (hr : l reg = some (ptr reg))
    (h24 : l 24 = some (u32 n)) (h9 : l 9 = some (u32 (K / 64))) (h22 : l 22 = some (u32 gq)) (hn : n < N)
    (hgq : gq < K / 64) (hreg : sh.regions reg = some ⟨.device, 2 * (N * (K / 64)), a⟩) (ha : a % 2 = 0) :
    (eval C ctx l (.conv .f32 (.load (.scalar .bf16) (.offset (.local reg) sbIndex)))).run sh =
      some (.f32 (C.widen (bfAt (sh.bytes reg) (n * (K / 64) + gq))), rd ctx sh reg (2 * (n * (K / 64) + gq))) := by
  obtain ⟨-, hNK, -⟩ := hD.mk_lt
  have hN1 := hD.n1; have hK1 := hD.k1
  have hle : N * (K / 64) ≤ N * K := Nat.mul_le_mul_left _ (Nat.div_le_self _ _)
  have hnK := succ_mul_le (K := K / 64) hn
  have hidx : (eval C ctx l sbIndex).run sh = some (u64 (n * (K / 64) + gq), sh) :=
    eval_u64bin C (eval_u64bin C (eval_toU64 C (eval_local' C h24 sh) (by omega)) (eval_toU64 C (eval_local' C h9 sh)
      (by omega)) (binary_mul_u64 C n (K / 64))) (eval_toU64 C (eval_local' C h22 sh) (by omega))
      (binary_add_u64 C _ gq)
  have hp := eval_offset_u64 C (o := 0) (eval_local' C (ctx := ctx) hr sh) hidx (by omega)
  rw [show 0 + (n * (K / 64) + gq) * (Ty.scalar .bf16).bytes = 2 * (n * (K / 64) + gq) by
    simp [Ty.bytes, Scalar.bytes]; ring] at hp
  have hld := load_bf16 ctx sh reg _ a (n * (K / 64) + gq) hreg ha (by omega)
  exact eval_conv C ((eval_load C _ _ _ _ _ _ _ hp).trans hld) rfl

/-- Output row `n = n0 + r` at K step `t` after `q`: `s`, `b`, then every `acc[r][m]`. -/
theorem exec_rowTail (hS : Shape E.L V M N K ax aw as ab) (hD : Dims M N K) (hl : Lane ctx g s i) {t r : Nat}
    (hr : r < 4) (hn : 4 * (2 * g + s) + r < N) (ht : 16 * i + 512 * t + 16 ≤ K) {l : Locals} {sh : Shared}
    (hI : In E sh) (hloc : Locs V K g s i l)
    (h15 : l 15 = some (fptr (xrR (tid g s i)))) (h16 : l 16 = some (fptr (xsR (tid g s i))))
    (h22 : l 22 = some (u32 ((16 * i + 512 * t) / 64))) (h23 : l 23 = some (u32 r))
    (h24 : l 24 = some (u32 (4 * (2 * g + s) + r))) (h26 : l 26 = some (fptr (qR (tid g s i))))
    (hq : ∀ j < 16, f32At (sh.bytes (qR (tid g s i))) j =
      V.q E.W ((4 * (2 * g + s) + r) * V.rowBytes K + V.off (16 * i + 512 * t)) j)
    (hx : ∀ m < M, ∀ j < 16, f32At (sh.bytes (xrR (tid g s i))) (m * 16 + j) = xf C E.X (m * K + (16 * i + 512 * t) + j))
    (hs : ∀ m < M, f32At (sh.bytes (xsR (tid g s i))) m = xsum C E.X (m * K + (16 * i + 512 * t)) 4)
    (hacc : AccP C V M K E (4 * (2 * g + s)) i t r 0 (sh.bytes (accR (tid g s i)))) :
    ∃ l' sh', Exec C ctx (rowTail M) l sh .normal l' sh' ∧ (∀ j, j < 30 → l' j = l j) ∧
      Footprint ctx inR (isR (accR (tid g s i))) sh sh' ∧
      AccP C V M K E (4 * (2 * g + s)) i t r M (sh'.bytes (accR (tid g s i))) := by
  have hM1 := hD.m1
  have hK5 := hD.k512; have hsi := hl.hi
  have hgq : (16 * i + 512 * t) / 64 < K / 64 := by omega
  have h30 := eval_sb (C := C) (ctx := ctx) hD (reg := 2) hloc.sc h24 hloc.gr h22 hn hgq (by rw [hI.regions]; exact hS.r2)
    hS.as
  rw [hI.s] at h30
  generalize hsh₁ : rd ctx sh 2 (2 * ((4 * (2 * g + s) + r) * (K / 64) + (16 * i + 512 * t) / 64)) = sh₁ at h30
  have hb₁ : sh₁.bytes = sh.bytes := by rw [← hsh₁]; rfl
  have hr₁ : sh₁.regions = sh.regions := by rw [← hsh₁]; rfl
  generalize hl₁ : setLocal l 30 (.f32 (C.widen (bfAt E.S ((4 * (2 * g + s) + r) * (K / 64) + (16 * i + 512 * t) / 64)))) = l₁
  have k₁ : ∀ j, j ≠ 30 → l₁ j = l j := fun j hj => by rw [← hl₁, setLocal_other _ _ hj]
  have h31 := eval_sb (C := C) (ctx := ctx) (l := l₁) (sh := sh₁) hD (reg := 3) (by rw [k₁ 3 (by omega)]; exact hloc.bi)
    (by rw [k₁ 24 (by omega)]; exact h24) (by rw [k₁ 9 (by omega)]; exact hloc.gr) (by rw [k₁ 22 (by omega)]; exact h22)
    hn hgq (by rw [hr₁, hI.regions]; exact hS.r3) hS.ab
  rw [hb₁, hI.b] at h31
  generalize hsh₂ : rd ctx sh₁ 3 (2 * ((4 * (2 * g + s) + r) * (K / 64) + (16 * i + 512 * t) / 64)) = sh₂ at h31
  have hb₂ : sh₂.bytes = sh.bytes := by rw [← hsh₂, ← hb₁]; rfl
  have hr₂ : sh₂.regions = sh.regions := by rw [← hsh₂, ← hr₁]; rfl
  have hF₂ : Footprint ctx inR (isR (accR (tid g s i))) sh sh₂ := by
    rw [← hsh₂, ← hsh₁]
    exact (Footprint.rdn _ _ _ _ (show inR 2 by simp [inR])).trans
      (Footprint.rdn _ _ _ _ (show inR 3 by simp [inR]))
  generalize hl₂ : setLocal l₁ 31 (.f32 (C.widen (bfAt E.B ((4 * (2 * g + s) + r) * (K / 64) + (16 * i + 512 * t) / 64)))) = l₂
  have k₂ : ∀ j, j ≠ 30 → j ≠ 31 → l₂ j = l j := fun j h1 h2 => by rw [← hl₂, setLocal_other _ _ h2, k₁ j h1]
  obtain ⟨l₃, sh₃, hloop, k₃, hF₃, hacc₃⟩ := forU_exec C (ctx := ctx) (i := 32) (n := M) (body := mBody M) (by omega)
    (fun m l' sh' => (∀ j, j < 32 → l' j = l₂ j) ∧ Footprint ctx inR (isR (accR (tid g s i))) sh₂ sh' ∧
      AccP C V M K E (4 * (2 * g + s)) i t r m (sh'.bytes (accR (tid g s i))))
    (fun m hm l' sh' ⟨hk, hF, hacc'⟩ h32 => by
      have hk' : ∀ j, j < 30 → l' j = l j := fun j hj => by rw [hk j (by omega), k₂ j (by omega) (by omega)]
      have hbq : ∀ q, q ≠ accR (tid g s i) → sh'.bytes q = sh.bytes q := fun q hq => by
        rw [hF.bytes q hq, hb₂]
      obtain ⟨l'', sh'', hb, hk'', hF', hacc''⟩ := exec_mbody (C := C) (ctx := ctx) hS hD hr hm
        (hF.regions.trans (hr₂.trans hI.regions)) (hloc.keep fun j hj => hk' j (by omega))
        (by rw [hk' 15 (by omega)]; exact h15) (by rw [hk' 16 (by omega)]; exact h16) (by rw [hk' 23 (by omega)]; exact h23)
        (by rw [hk' 26 (by omega)]; exact h26)
        (by rw [hk 30 (by omega), ← hl₂, setLocal_other _ _ (by omega), ← hl₁]; exact setLocal_same _ _ _)
        (by rw [hk 31 (by omega), ← hl₂]; exact setLocal_same _ _ _) h32
        (fun j hj => by rw [hbq _ (by unfold qR accR; omega)]; exact hq j hj)
        (fun m hm j hj => by rw [hbq _ (by unfold xrR accR; omega)]; exact hx m hm j hj)
        (fun m hm => by rw [hbq _ (by unfold xsR accR; omega)]; exact hs m hm) hacc'
      exact ⟨l'', sh'', hb, by rw [hk'' 32 (by omega)]; exact h32,
        fun j hj => by rw [setLocal_other _ _ (by omega), hk'' j (by omega), hk j hj], hF.trans hF', hacc''⟩)
    ⟨fun j hj => by keep, Footprint.refl _ _ _ _, by rw [hb₂]; exact hacc⟩
  refine ⟨l₃, sh₃, ?_, fun j hj => by rw [k₃ j (by omega), k₂ j (by omega) (by omega)], hF₂.trans hF₃, hacc₃⟩
  subst hl₂ hl₁
  exact .set h30 (.set h31 hloop)

/-- Output row `r` of K step `t`: `n`, `p`, `q`, then `rowTail`. -/
theorem exec_outRow (hP : PSpec C V) (hQ : QSpec C V) (hV : V.Ok) (hS : Shape E.L V M N K ax aw as ab)
    (hD : Dims M N K) (hl : Lane ctx g s i) (hg : g < N / 8) {t r : Nat} (hr : r < 4) (ht : t < K / 512)
    {l : Locals} {sh : Shared} (hI : In E sh) (hloc : Locs V K g s i l) (h14 : l 14 = some (u32 (16 * i + 512 * t)))
    (h15 : l 15 = some (fptr (xrR (tid g s i)))) (h16 : l 16 = some (fptr (xsR (tid g s i))))
    (h22 : l 22 = some (u32 ((16 * i + 512 * t) / 64))) (h23 : l 23 = some (u32 r))
    (hx : ∀ m < M, ∀ j < 16, f32At (sh.bytes (xrR (tid g s i))) (m * 16 + j) = xf C E.X (m * K + (16 * i + 512 * t) + j))
    (hs : ∀ m < M, f32At (sh.bytes (xsR (tid g s i))) m = xsum C E.X (m * K + (16 * i + 512 * t)) 4)
    (hacc : AccP C V M K E (4 * (2 * g + s)) i t r 0 (sh.bytes (accR (tid g s i)))) :
    ∃ l' sh', Exec C ctx (outRowG M V.pOff V.qfill) l sh .normal l' sh' ∧ (∀ j, j < 24 → l' j = l j) ∧
      Footprint ctx inR (fun q => q = qR (tid g s i) ∨ q = accR (tid g s i)) sh sh' ∧
      AccP C V M K E (4 * (2 * g + s)) i t (r + 1) 0 (sh'.bytes (accR (tid g s i))) := by
  have hsi := hl.hi; have hss := hl.hs
  have hN8 := hD.n8; have hN1 := hD.n1; have hK5 := hD.k512; have hK1 := hD.k1
  obtain ⟨-, hNK, -⟩ := hD.mk_lt
  have hn : 4 * (2 * g + s) + r < N := by omega
  have htK : 16 * i + 512 * t + 16 ≤ K := by omega
  have hrb := hV.rb K hK1
  -- `n = n0 + r`
  have h24 : (eval C ctx l (AffineRows3.u32 .add (.local 7) (.local 23))).run sh = some (u32 (4 * (2 * g + s) + r), sh) :=
    eval_u32bin C (eval_local' C hloc.n0 sh) (eval_local' C h23 sh) (binary_add_u32 C _ r)
  generalize hl₁ : setLocal l 24 (u32 (4 * (2 * g + s) + r)) = l₁
  have k₁ : ∀ j, j ≠ 24 → l₁ j = l j := fun j hj => by rw [← hl₁, setLocal_other _ _ hj]
  have g24 : l₁ 24 = some (u32 (4 * (2 * g + s) + r)) := by rw [← hl₁]; exact setLocal_same _ _ _
  -- `p = wb + n * rowBytes + off(k0)`
  have hnrb := succ_mul_le (K := V.rowBytes K) hn
  have hNrb : N * V.rowBytes K < 2 ^ 62 := by
    have := Nat.mul_le_mul_left N hrb.le; nlinarith
  have hp1 : (eval C ctx l₁ (.offset (.local 10) (AffineRows3.u64 .mul (toU64 (.local 24)) (.local 8)))).run sh =
      some (.ptr ⟨1, ((0 + (4 * (2 * g + s) + r) * V.rowBytes K * (Ty.scalar .u8).bytes : Nat) : Int), .scalar .u8⟩, sh) :=
    eval_offset_u64 C (o := 0) (eval_local' C (by rw [k₁ 10 (by omega)]; exact hloc.wb) sh)
      (eval_u64bin C (eval_toU64 C (eval_local' C g24 sh) (by omega)) (eval_local' C (by rw [k₁ 8 (by omega)]; exact hloc.rb) sh)
        (binary_mul_u64 C _ _)) (by omega)
  have hoff := hP ctx l₁ sh (16 * i + 512 * t) (by rw [k₁ 14 (by omega)]; exact h14) (by omega)
  have hbd := hV.bound K (16 * i + 512 * t) hK5 (by omega) htK
  have hp2 := eval_offset_u64 C hp1 hoff (by omega)
  rw [show 0 + (4 * (2 * g + s) + r) * V.rowBytes K * (Ty.scalar .u8).bytes + V.off (16 * i + 512 * t) * (Ty.scalar .u8).bytes =
    (4 * (2 * g + s) + r) * V.rowBytes K + V.off (16 * i + 512 * t) by simp [Ty.bytes, Scalar.bytes]] at hp2
  generalize hl₂ : setLocal l₁ 25 (.ptr ⟨1, (((4 * (2 * g + s) + r) * V.rowBytes K + V.off (16 * i + 512 * t) : Nat) : Int),
    .scalar .u8⟩) = l₂
  generalize hl₃ : setLocal l₂ 26 (.ptr ⟨qR (tid g s i), 0, .scalar .f32⟩) = l₃
  have k₃ : ∀ j, j ≠ 24 → j ≠ 25 → j ≠ 26 → l₃ j = l j := fun j h1 h2 h3 => by
    rw [← hl₃, setLocal_other _ _ h3, ← hl₂, setLocal_other _ _ h2, k₁ j h1]
  have hta : (if false = true then ctx.groupArray 3 else ctx.threadArray 3) = qR (tid g s i) := by
    show ctx.threadArray 3 = _; rw [hl.ta]; unfold qR; omega
  -- `q`
  obtain ⟨l₄, sh₄, hqf, hFq, k₄, hq⟩ := hQ ctx l₃ sh ((4 * (2 * g + s) + r) * V.rowBytes K + V.off (16 * i + 512 * t))
    (N * V.rowBytes K) aw (qR (tid g s i)) (by rw [hI.regions]; exact hS.r1) hS.aw (hV.align K _ _ hK5 (by omega))
    (by omega) (by rw [hI.regions]; exact hS.rq _) (by rw [← hl₃, setLocal_other _ _ (by omega), ← hl₂]; exact setLocal_same _ _ _)
    (by rw [← hl₃]; exact setLocal_same _ _ _)
  rw [hI.w] at hq
  have hI₄ : In E sh₄ := hI.frame hFq (fun q hq => by unfold isR qR at hq; omega)
  have hb₄ : ∀ q, q ≠ qR (tid g s i) → sh₄.bytes q = sh.bytes q := fun q hq => hFq.bytes q hq
  have k₄' : ∀ j, j < 24 ∨ j = 24 ∨ j = 26 → l₄ j = l₃ j := fun j hj => k₄ j (by omega)
  obtain ⟨l₅, sh₅, htail, k₅, hF₅, hacc₅⟩ := exec_rowTail (C := C) (ctx := ctx) (l := l₄) (sh := sh₄) hS hD hl hr hn htK hI₄
    (hloc.keep fun j hj => by rw [k₄' j (by omega), k₃ j (by omega) (by omega) (by omega)])
    (by rw [k₄' 15 (by omega), k₃ 15 (by omega) (by omega) (by omega)]; exact h15)
    (by rw [k₄' 16 (by omega), k₃ 16 (by omega) (by omega) (by omega)]; exact h16)
    (by rw [k₄' 22 (by omega), k₃ 22 (by omega) (by omega) (by omega)]; exact h22)
    (by rw [k₄' 23 (by omega), k₃ 23 (by omega) (by omega) (by omega)]; exact h23)
    (by rw [k₄' 24 (by omega), ← hl₃, setLocal_other _ _ (by omega), ← hl₂, setLocal_other _ _ (by omega)]; exact g24)
    (by rw [k₄' 26 (by omega), ← hl₃]; exact setLocal_same _ _ _) hq
    (fun m hm j hj => by rw [hb₄ _ (by unfold xrR qR; omega)]; exact hx m hm j hj)
    (fun m hm => by rw [hb₄ _ (by unfold xsR qR; omega)]; exact hs m hm)
    (by rw [hb₄ _ (by unfold accR qR; omega)]; exact hacc)
  refine ⟨l₅, sh₅, ?_, fun j hj => by rw [k₅ j (by omega), k₄' j (by omega), k₃ j (by omega) (by omega) (by omega)],
    (hFq.mono (fun _ h => by unfold isR at h; subst h; simp [inR]) (fun _ h => .inl h)).trans
      (hF₅.mono (fun _ h => h) (fun _ h => .inr h)), fun r' hr' m' hm' => ?_⟩
  · have hhead : Exec C ctx (rowHead V.pOff) l sh .normal l₃ sh := by
      rw [← hl₃, ← hl₂, ← hl₁]
      exact .set h24 (.set (by rw [hl₁]; exact hp2) (.array (by rw [hta]; exact .nil _ _)))
    exact Exec.append (Exec.append hhead hqf) htail
  · rw [hacc₅ r' hr' m' hm']
    congr 1
    by_cases hc : r' < r ∨ (r' = r ∧ m' < M)
    · rw [ite_eq_left hc, ite_eq_left (by omega)]
    · rw [ite_eq_right hc, ite_eq_right (by omega)]

/-- The four output rows of K step `t`. -/
theorem exec_rows (hP : PSpec C V) (hQ : QSpec C V) (hV : V.Ok) (hS : Shape E.L V M N K ax aw as ab)
    (hD : Dims M N K) (hl : Lane ctx g s i) (hg : g < N / 8) {t : Nat} (ht : t < K / 512)
    {l : Locals} {sh : Shared} (hI : In E sh) (hloc : Locs V K g s i l) (h14 : l 14 = some (u32 (16 * i + 512 * t)))
    (h15 : l 15 = some (fptr (xrR (tid g s i)))) (h16 : l 16 = some (fptr (xsR (tid g s i))))
    (h22 : l 22 = some (u32 ((16 * i + 512 * t) / 64)))
    (hx : ∀ m < M, ∀ j < 16, f32At (sh.bytes (xrR (tid g s i))) (m * 16 + j) = xf C E.X (m * K + (16 * i + 512 * t) + j))
    (hs : ∀ m < M, f32At (sh.bytes (xsR (tid g s i))) m = xsum C E.X (m * K + (16 * i + 512 * t)) 4)
    (hacc : AccP C V M K E (4 * (2 * g + s)) i t 0 0 (sh.bytes (accR (tid g s i)))) :
    ∃ l' sh', Exec C ctx (forU 23 4 (outRowG M V.pOff V.qfill)) l sh .normal l' sh' ∧ (∀ j, j < 23 → l' j = l j) ∧
      Footprint ctx inR (fun q => q = qR (tid g s i) ∨ q = accR (tid g s i)) sh sh' ∧
      AccP C V M K E (4 * (2 * g + s)) i t 4 0 (sh'.bytes (accR (tid g s i))) := by
  obtain ⟨l', sh', hex, hk, hF, hacc'⟩ := forU_exec C (ctx := ctx) (i := 23) (n := 4) (body := outRowG M V.pOff V.qfill)
    (by norm_num)
    (fun r l' sh' => (∀ j, j < 23 → l' j = l j) ∧
      Footprint ctx inR (fun q => q = qR (tid g s i) ∨ q = accR (tid g s i)) sh sh' ∧
      AccP C V M K E (4 * (2 * g + s)) i t r 0 (sh'.bytes (accR (tid g s i))))
    (fun r hr l' sh' ⟨hk, hF, hacc'⟩ h23 => by
      have hI' := hI.frame hF (fun q hq => by unfold qR accR at hq; omega)
      have hb : ∀ q, q ≠ qR (tid g s i) → q ≠ accR (tid g s i) → sh'.bytes q = sh.bytes q :=
        fun q h1 h2 => hF.bytes q (by rintro (h | h) <;> contradiction)
      obtain ⟨l'', sh'', hb', hk', hF', hacc''⟩ := exec_outRow (C := C) (ctx := ctx) hP hQ hV hS hD hl hg hr ht hI'
        (hloc.keep fun j hj => hk j (by omega)) (by rw [hk 14 (by omega)]; exact h14) (by rw [hk 15 (by omega)]; exact h15)
        (by rw [hk 16 (by omega)]; exact h16) (by rw [hk 22 (by omega)]; exact h22) h23
        (fun m hm j hj => by rw [hb _ (by unfold xrR qR; omega) (by unfold xrR accR; omega)]; exact hx m hm j hj)
        (fun m hm => by rw [hb _ (by unfold xsR qR; omega) (by unfold xsR accR; omega)]; exact hs m hm) hacc'
      exact ⟨l'', sh'', hb', by rw [hk' 23 (by omega)]; exact h23,
        fun j hj => by rw [setLocal_other _ _ (by omega), hk' j (by omega), hk j hj], hF.trans hF', hacc''⟩)
    ⟨fun j hj => by keep, Footprint.refl _ _ _ _, hacc⟩
  exact ⟨l', sh', hex, hk, hF, hacc'⟩

/-- `acc` after `t` K steps. -/
def AccT (C : M1Max.Contract) (V : Variant) (M K : Nat) (E : Env) (n0 i t : Nat) (B : ByteMemory.Bytes) : Prop :=
  ∀ r < 4, ∀ m < M, f32At B (r * M + m) = acc C V K E.X E.W E.S E.B (n0 + r) m i t

/-- K step `t`: `xr` and `xs`, `g`, the four output rows. -/
theorem exec_kstep (hP : PSpec C V) (hQ : QSpec C V) (hV : V.Ok) (hS : Shape E.L V M N K ax aw as ab)
    (hD : Dims M N K) (hl : Lane ctx g s i) (hg : g < N / 8) {t : Nat} (ht : t < K / 512)
    {l : Locals} {sh : Shared} (hI : In E sh) (hloc : Locs V K g s i l) (h14 : l 14 = some (u32 (16 * i + 512 * t)))
    (hacc : AccT C V M K E (4 * (2 * g + s)) i t (sh.bytes (accR (tid g s i)))) :
    ∃ l' sh', Exec C ctx (kStepG M K V.pOff V.qfill) l sh .normal l' sh' ∧ (∀ j, j < 15 → l' j = l j) ∧
      Footprint ctx inR (own (tid g s i)) sh sh' ∧ AccT C V M K E (4 * (2 * g + s)) i (t + 1) (sh'.bytes (accR (tid g s i))) := by
  have hsi := hl.hi; have hK5 := hD.k512; have hK1 := hD.k1
  have hta1 : (if false = true then ctx.groupArray 1 else ctx.threadArray 1) = xrR (tid g s i) := by
    show ctx.threadArray 1 = _; rw [hl.ta]; unfold xrR; omega
  have hta2 : (if false = true then ctx.groupArray 2 else ctx.threadArray 2) = xsR (tid g s i) := by
    show ctx.threadArray 2 = _; rw [hl.ta]; unfold xsR; omega
  generalize hl₁ : setLocal (setLocal l 15 (fptr (xrR (tid g s i)))) 16 (fptr (xsR (tid g s i))) = l₁
  have k₁ : ∀ j, j < 15 → l₁ j = l j := fun j hj => by rw [← hl₁]; keep
  have ha : Exec C ctx [.array 15 false 1 (.scalar .f32), .array 16 false 2 (.scalar .f32)] l sh .normal l₁ sh := by
    rw [← hl₁]; exact .array (.array (by rw [hta1, hta2]; exact .nil _ _))
  obtain ⟨l₂, sh₂, hxr, k₂, hF₂, hx₂, hs₂⟩ := exec_xrows (C := C) (ctx := ctx) hS hD (k0 := 16 * i + 512 * t) (by omega)
    (by omega) hI (hloc.keep fun j hj => k₁ j (by omega)) (by rw [k₁ 14 (by omega)]; exact h14) (by rw [← hl₁]; simp [setLocal])
    (by rw [← hl₁]; simp [setLocal])
  have g14 : l₂ 14 = some (u32 (16 * i + 512 * t)) := by rw [k₂ 14 (by omega), k₁ 14 (by omega)]; exact h14
  have h22 : (eval C ctx l₂ (AffineRows3.u32 .div (.local 14) (u32l 64))).run sh₂ =
      some (u32 ((16 * i + 512 * t) / 64), sh₂) :=
    eval_u32bin C (eval_local' C g14 sh₂) (eval_u32l C (by norm_num) sh₂)
      (binary_div_u32 C _ 64 (by omega) (by norm_num) (by norm_num))
  generalize hl₃ : setLocal l₂ 22 (u32 ((16 * i + 512 * t) / 64)) = l₃
  have k₃ : ∀ j, j < 17 → l₃ j = l₁ j := fun j hj => by rw [← hl₃, setLocal_other _ _ (by omega), k₂ j (by omega)]
  have hI₂ := hI.frame hF₂ (fun q hq => by unfold xrR xsR at hq; omega)
  have hb₂ : sh₂.bytes (accR (tid g s i)) = sh.bytes (accR (tid g s i)) :=
    hF₂.bytes _ (by unfold xrR xsR accR; omega)
  obtain ⟨l₄, sh₄, hrows, k₄, hF₄, hacc₄⟩ := exec_rows (C := C) (ctx := ctx) (l := l₃) (sh := sh₂) hP hQ hV hS hD hl hg ht hI₂
    (hloc.keep fun j hj => by rw [k₃ j (by omega), k₁ j (by omega)]) (by rw [k₃ 14 (by omega), ← hl₁]; simp [setLocal, h14])
    (by rw [k₃ 15 (by omega), ← hl₁]; simp [setLocal]) (by rw [k₃ 16 (by omega), ← hl₁]; simp [setLocal])
    (by rw [← hl₃]; exact setLocal_same _ _ _) hx₂ hs₂
    (fun r hr m hm => by rw [hb₂, hacc r hr m hm, ite_eq_right (by omega)])
  refine ⟨l₄, sh₄, ?_, fun j hj => by rw [k₄ j (by omega), k₃ j (by omega), k₁ j hj],
    (hF₂.mono (fun _ h => h) (fun q h => by unfold own; unfold xrR xsR at h; omega)).trans
      (hF₄.mono (fun _ h => h) (fun q h => by unfold own; unfold qR accR at h; omega)),
    fun r hr m hm => by rw [hacc₄ r hr m hm, ite_eq_left (by omega)]⟩
  rw [← hl₃] at hrows
  exact Exec.append (Exec.append (Exec.append ha hxr) (.set h22 (.nil _ _))) hrows

/-- The K loop: the lane's K/512 steps. -/
theorem exec_kloop (hP : PSpec C V) (hQ : QSpec C V) (hV : V.Ok) (hS : Shape E.L V M N K ax aw as ab)
    (hD : Dims M N K) (hl : Lane ctx g s i) (hg : g < N / 8) {l : Locals} {sh : Shared} (hI : In E sh)
    (hloc : Locs V K g s i l) (h14 : l 14 = some (u32 (16 * i + 512 * 0)))
    (hacc : AccT C V M K E (4 * (2 * g + s)) i 0 (sh.bytes (accR (tid g s i)))) :
    ∃ l' sh', Exec C ctx [kLoop M K V.pOff V.qfill] l sh .normal l' sh' ∧ Locs V K g s i l' ∧
      Footprint ctx inR (own (tid g s i)) sh sh' ∧ AccT C V M K E (4 * (2 * g + s)) i (K / 512) (sh'.bytes (accR (tid g s i))) := by
  have hsi := hl.hi; have hK5 := hD.k512; have hK1 := hD.k1
  obtain ⟨l', sh', hex, hloc', -, hF, hacc'⟩ := Exec.loop_count (C := C) (ctx := ctx) (c := kCond K) (st := kStep)
    (b := kStepG M K V.pOff V.qfill) (K / 512)
    (fun t l' sh' => Locs V K g s i l' ∧ l' 14 = some (u32 (16 * i + 512 * t)) ∧ Footprint ctx inR (own (tid g s i)) sh sh' ∧
      AccT C V M K E (4 * (2 * g + s)) i t (sh'.bytes (accR (tid g s i))))
    (fun t l' sh' => Locs V K g s i l' ∧ l' 14 = some (u32 (16 * i + 512 * t)) ∧ Footprint ctx inR (own (tid g s i)) sh sh' ∧
      AccT C V M K E (4 * (2 * g + s)) i t (sh'.bytes (accR (tid g s i))))
    (fun t ht l' sh' hJ => ⟨sh', by
      rw [show decide (t < K / 512) = decide (16 * i + 512 * t < K) from decide_eq_decide.mpr (by omega)]
      exact eval_u32bin C (eval_local' C hJ.2.1 sh') (eval_u32l C (by omega) sh') (binary_lt_u32 C _ K (by omega) (by omega)),
      hJ⟩)
    (fun t ht l' sh' ⟨hloc', h14', hF, hacc'⟩ => by
      obtain ⟨l'', sh'', hb, k'', hF', hacc''⟩ := exec_kstep (C := C) (ctx := ctx) hP hQ hV hS hD hl hg ht
        (hI.frame hF (fun q hq => by unfold own at hq; omega)) hloc' h14' hacc'
      have g14 : l'' 14 = some (u32 (16 * i + 512 * t)) := by rw [k'' 14 (by omega)]; exact h14'
      refine ⟨.normal, l'', sh'', _, sh'', .inl rfl, hb,
        .set (eval_u32bin C (eval_local' C g14 sh'') (eval_u32l C (by norm_num) sh'') (binary_add_u32 C _ 512)) (.nil _ _),
        hloc'.keep fun j hj => by rw [setLocal_other _ _ (by omega), k'' j (by omega)], ?_, hF.trans hF', hacc''⟩
      rw [setLocal_same, show 16 * i + 512 * t + 512 = 16 * i + 512 * (t + 1) by ring])
    (l := l) (sh := sh) ⟨hloc, h14, Footprint.refl _ _ _ _, hacc⟩
  exact ⟨l', sh', hex, hloc', hF, hacc'⟩
/-- `lane`, `sg`, `n0`, the test `n0 >= N` (false), `rowBytes`, `groups`, `wb`, `acc`. -/
theorem exec_prologue (hV : V.Ok) (hD : Dims M N K) (hl : Lane ctx g s i) (hg : g < N / 8) {l : Locals} {sh : Shared}
    (h0 : l 0 = some (ptr 0)) (h1 : l 1 = some (.ptr ⟨1, 0, .scalar .u32⟩)) (h2 : l 2 = some (ptr 2))
    (h3 : l 3 = some (ptr 3)) (h4 : l 4 = some (ptr 4)) :
    ∃ l', Exec C ctx (prologue N K (V.rowBytes K)) l sh .normal l' sh ∧ Locs V K g s i l' := by
  have hsi := hl.hi; have hss := hl.hs; have hN8 := hD.n8; have hN1 := hD.n1; have hK1 := hD.k1
  have hrb := hV.rb K hK1
  have hc1 : (eval C ctx (setLocal (setLocal l 5 (u32 i)) 6 (u32 s))
      (.component (.coord .threadgroupPositionInGrid) (u32l 1))).run sh = some (u32 g, sh) := by
    have hv : (eval C ctx (setLocal (setLocal l 5 (u32 i)) 6 (u32 s)) (.coord .threadgroupPositionInGrid)).run sh =
        some (.vec .u32 [u32 0, u32 g, u32 0], sh) := by rw [eval_coord, hl.tg]; rfl
    exact eval_component C hv (eval_lit C _ _ _ _) (natOf_unsigned _ rfl) rfl
  have h7 : (eval C ctx (setLocal (setLocal l 5 (u32 i)) 6 (u32 s)) n0Expr).run sh = some (u32 (4 * (2 * g + s)), sh) := by
    rw [show 4 * (2 * g + s) = (g * 2 + s) * 4 by ring]
    exact eval_u32bin C (eval_u32bin C (eval_u32bin C hc1 (eval_u32l C (by norm_num) sh) (binary_mul_u32 C g 2))
      (eval_local' C (setLocal_same _ _ _) sh) (binary_add_u32 C _ s)) (eval_u32l C (by norm_num) sh) (binary_mul_u32 C _ 4)
  generalize hl₇ : setLocal (setLocal (setLocal l 5 (u32 i)) 6 (u32 s)) 7 (u32 (4 * (2 * g + s))) = l₇
  have hge : (eval C ctx l₇ (AffineRows3.u32 .ge (.local 7) (u32l N))).run sh = some (.bool false, sh) := by
    have := eval_u32bin C (ctx := ctx) (l := l₇) (sh := sh) (op := .ge) (a := .local 7) (b := u32l N)
      (eval_local' C (by rw [← hl₇]; exact setLocal_same _ _ _) sh) (eval_u32l C (by omega) sh)
      (binary_ge_u32 C _ N (by omega) (by omega))
    rwa [decide_eq_false (by omega)] at this
  have hta : (if false = true then ctx.groupArray 0 else ctx.threadArray 0) = accR (tid g s i) := by
    show ctx.threadArray 0 = _; rw [hl.ta]; unfold accR; omega
  refine ⟨setLocal (setLocal (setLocal (setLocal l₇ 8 (u64 (V.rowBytes K))) 9 (u32 (K / 64))) 10
    (.ptr ⟨1, 0, .scalar .u8⟩)) 11 (fptr (accR (tid g s i))), ?_, ?_⟩
  · have g1 : (setLocal (setLocal l₇ 8 (u64 (V.rowBytes K))) 9 (u32 (K / 64))) 1 = some (.ptr ⟨1, 0, .scalar .u32⟩) := by
      rw [← hl₇]; simp [setLocal, h1]
    have h10 := eval_ptrCast C (ctx := ctx) (t := .scalar .u8) (eval_local' C g1 sh)
    have e5 : (eval C ctx l (.coord .threadIndexInSimdgroup)).run sh = some (u32 i, sh) := by rw [eval_coord, hl.lane]
    have e6 : (eval C ctx (setLocal l 5 (u32 i)) (.coord .simdgroupIndexInThreadgroup)).run sh = some (u32 s, sh) := by
      rw [eval_coord, hl.sg]
    have harr : Exec C ctx [.array 11 false 0 (.scalar .f32)] (setLocal (setLocal (setLocal l₇ 8 (u64 (V.rowBytes K))) 9
        (u32 (K / 64))) 10 (.ptr ⟨1, 0, .scalar .u8⟩)) sh .normal (setLocal (setLocal (setLocal (setLocal l₇ 8
        (u64 (V.rowBytes K))) 9 (u32 (K / 64))) 10 (.ptr ⟨1, 0, .scalar .u8⟩)) 11 (fptr (accR (tid g s i)))) sh :=
      .array (by rw [hta]; exact .nil _ _)
    rw [← hl₇] at hge h10 harr ⊢
    exact .set e5 (.set e6 (.set h7 (.ite hge (.nil _ _) (.set (eval_u64l C (by omega) sh) (.set (eval_u32l C (by omega) sh)
      (.set h10 harr))))))
  · rw [← hl₇]
    exact ⟨by simp [setLocal, h0], by simp [setLocal, h1], by simp [setLocal, h2], by simp [setLocal, h3],
      by simp [setLocal, h4], by simp [setLocal], by simp [setLocal], by simp [setLocal], by simp [setLocal],
      by simp [setLocal], by simp [setLocal], by simp [setLocal]⟩

/-- `acc[r][m] = 0` for every entry. -/
theorem exec_zero (hS : Shape E.L V M N K ax aw as ab) (hD : Dims M N K) {l : Locals} {sh : Shared}
    (hreg : sh.regions = E.L.regions) (hloc : Locs V K g s i l) :
    ∃ l' sh', Exec C ctx (zeroLoop M) l sh .normal l' sh' ∧ (∀ j, j < 12 → l' j = l j) ∧
      Footprint ctx inR (isR (accR (tid g s i))) sh sh' ∧
      AccT C V M K E (4 * (2 * g + s)) i 0 (sh'.bytes (accR (tid g s i))) := by
  have hM1 := hD.m1
  obtain ⟨l', sh', hex, hk, hF, hz⟩ := forU_exec C (ctx := ctx) (i := 12) (n := 4)
    (body := forU 13 M [.store (.scalar .f32) (at2 11 (.local 12) M (.local 13)) (f32l 0x0)]) (by norm_num)
    (fun r l' sh' => (∀ j, j < 12 → l' j = l j) ∧ Footprint ctx inR (isR (accR (tid g s i))) sh sh' ∧
      ∀ r' < r, ∀ m < M, f32At (sh'.bytes (accR (tid g s i))) (r' * M + m) = zero)
    (fun r hr l₁ sh₁ ⟨hk₁, hF₁, hz₁⟩ h12 => by
      obtain ⟨l₂, sh₂, hex₂, hk₂, hF₂, hz₂⟩ := forU_exec C (ctx := ctx) (i := 13) (n := M)
        (body := [.store (.scalar .f32) (at2 11 (.local 12) M (.local 13)) (f32l 0x0)]) (by omega)
        (fun m l₂ sh₂ => (∀ j, j < 13 → l₂ j = l₁ j) ∧ Footprint ctx inR (isR (accR (tid g s i))) sh sh₂ ∧
          ∀ r' < 4, ∀ m' < M, (r' < r ∨ (r' = r ∧ m' < m)) → f32At (sh₂.bytes (accR (tid g s i))) (r' * M + m') = zero)
        (fun m hm l₂ sh₂ ⟨hk₂, hF₂, hz₂⟩ h13 => by
          have hidx := idx_lt (M := M) hr hm
          have hp := eval_at2 C (ctx := ctx) (stride := M)
            (by rw [hk₂ 11 (by omega), hk₁ 11 (by omega)]; exact hloc.acc)
            (eval_local' C (by rw [hk₂ 12 (by omega)]; exact h12) sh₂) (by omega) (eval_local' C h13 sh₂) (by omega)
            (by omega) (by have : r * M ≤ 4 * M := Nat.mul_le_mul_right _ hr.le; omega)
          have hst := store_f32_thread ctx sh₂ (accR (tid g s i)) (4 * (4 * M)) (r * M + m) zero
            (by rw [hF₂.regions, hreg]; exact hS.ra _) (by omega)
          refine ⟨l₂, _, .store hp (eval_lit C _ _ _ _) hst (.nil _ _), h13, fun j hj => by
            rw [setLocal_other _ _ (by omega)]; exact hk₂ j hj, hF₂.trans (Footprint.wrT _ _ _ _ rfl),
            fun r' hr' m' hm' hc => ?_⟩
          rw [wrT_bytes_same, f32At_write]
          by_cases he : r' * M + m' = r * M + m
          · rw [ite_eq_left he]
          · rw [ite_eq_right he]
            refine hz₂ r' hr' m' hm' ?_
            rcases hc with hc | ⟨rfl, hc⟩
            · exact .inl hc
            · refine .inr ⟨rfl, ?_⟩
              by_contra hn
              exact he (by rw [show m' = m by omega]))
        ⟨fun j hj => by keep, hF₁, fun r' hr' m' hm' hc => by
          rcases hc with hc | ⟨_, hc⟩
          · exact hz₁ r' hc m' hm'
          · omega⟩
      exact ⟨l₂, sh₂, hex₂, by rw [hk₂ 12 (by omega)]; exact h12, fun j hj => by
        rw [setLocal_other _ _ (by omega), hk₂ j (by omega), hk₁ j hj], hF₂, fun r' hr' m hm =>
          hz₂ r' (by omega) m hm (by omega)⟩)
    ⟨fun j hj => by keep, Footprint.refl _ _ _ _, fun _ h => absurd h (Nat.not_lt_zero _)⟩
  exact ⟨l', sh', hex, hk, hF, fun r hr m hm => hz r hr m hm⟩

/-! ### The outputs -/

/-- The output loops' body after its `simd_sum`. -/
def outRest (N : Nat) : List CStmt :=
  [.set 38 (.local 37),
   .ite (AffineRows3.u32 .eq (.local 5) (u32l 0))
     [.store (.scalar .bf16)
       (.offset (.local 4) (AffineRows3.u64 .add (AffineRows3.u64 .add (AffineRows3.u64 .mul (toU64 (.local 36)) (u64l N))
         (toU64 (.local 7))) (toU64 (.local 35))))
       (.conv .bf16 (.local 38))] []]

theorem outBody_eq (M N : Nat) : AffineRows3.outBody M N =
    .collective 1 37 .sum .f32 (.load (.scalar .f32) (at2 11 (.local 35) M (.local 36))) (u16l 0) :: outRest N := rfl

def c36 (M : Nat) : CExpr := AffineRows3.u32 .lt (.local 36) (u32l M)
def st36 : List CStmt := [.set 36 (AffineRows3.u32 .add (.local 36) (u32l 1))]
def c35 : CExpr := AffineRows3.u32 .lt (.local 35) (u32l 4)
def st35 : List CStmt := [.set 35 (AffineRows3.u32 .add (.local 35) (u32l 1))]

/-- A thread's frames stopped at the `simd_sum`. -/
def outFrames (M N : Nat) : List Frame :=
  [.block (outRest N), .loop (c36 M) st36 (AffineRows3.outBody M N), .block [],
   .loop c35 st35 (forU 36 M (AffineRows3.outBody M N)), .block [], .scope, .block []]

/-- The locals of the output loops at `(r, m)`. -/
structure OutLocs (V : Variant) (K g s i r m : Nat) (l : Locals) : Prop where
  locs : Locs V K g s i l
  r : l 35 = some (u32 r)
  m : l 36 = some (u32 m)

/-- The `simd_sum` of `acc[r][m]`: the thread stops there. -/
theorem out_collective (hS : Shape E.L V M N K ax aw as ab) (hD : Dims M N K) {r m : Nat} (hr : r < 4) (hm : m < M)
    {l : Locals} (hol : OutLocs V K g s i r m l) {sh : Shared} (hreg : sh.regions = E.L.regions) :
    Exec C ctx (AffineRows3.outBody M N) l sh
      (.stop (.collective 1 37 .sum .f32 (.f32 (f32At (sh.bytes (accR (tid g s i))) (r * M + m))) 0) [.block (outRest N)])
      l sh := by
  have hM1 := hD.m1
  have hidx := idx_lt (M := M) hr hm
  have hp := eval_at2 C (ctx := ctx) (stride := M) hol.locs.acc (eval_local' C hol.r sh) (by omega) (eval_local' C hol.m sh)
    (by omega) (by omega) (by have : r * M ≤ 4 * M := Nat.mul_le_mul_right _ hr.le; omega)
  rw [outBody_eq]
  exact .collective (eval_load_th C hp (by rw [hreg]; exact hS.ra _) (by omega)) (eval_lit C _ _ _ _) rfl

/-- After the `simd_sum` of `(r, m)` with result `v`: `v`, and lane 0's store `y[m · N + n0 + r] = T(v)`. -/
theorem out_rest (hS : Shape E.L V M N K ax aw as ab) (hD : Dims M N K) (hl : Lane ctx g s i) (hg : g < N / 8)
    {r m : Nat} (hr : r < 4) (hm : m < M) {l : Locals} (hol : OutLocs V K g s i r m l) (v : Float32) {sh : Shared}
    (hreg : sh.regions = E.L.regions) :
    Exec C ctx (outRest N) (setLocal l 37 (.f32 v)) sh .normal (setLocal (setLocal l 37 (.f32 v)) 38 (.f32 v))
      (if i = 0 then wr ctx sh 4 (2 * (m * N + (4 * (2 * g + s) + r))) (C.narrow v) else sh) := by
  have hsi := hl.hi; have hss := hl.hs; have hN8 := hD.n8; have hN1 := hD.n1; have hM1 := hD.m1
  obtain ⟨-, -, hMN⟩ := hD.mk_lt
  have hn : 4 * (2 * g + s) + r < N := by omega
  have hmN := succ_mul_le (K := N) hm
  generalize hl₁ : setLocal (setLocal l 37 (.f32 v)) 38 (.f32 v) = l₁
  have k₁ : ∀ j, j < 37 → l₁ j = l j := fun j hj => by rw [← hl₁]; keep
  have htest := eval_u32bin C (ctx := ctx) (l := l₁) (sh := sh) (op := .eq) (a := .local 5) (b := u32l 0)
    (eval_local' C (by rw [k₁ 5 (by omega)]; exact hol.locs.lane) sh) (eval_u32l C (by norm_num) sh)
    (binary_eq_u32 C i 0 (by omega) (by norm_num))
  have hset : (eval C ctx (setLocal l 37 (.f32 v)) (.local 37)).run sh = some (.f32 v, sh) :=
    eval_local' C (setLocal_same _ _ _) sh
  by_cases hi0 : i = 0
  · rw [ite_eq_left hi0]
    rw [decide_eq_true hi0] at htest
    have hidx : (eval C ctx l₁ (AffineRows3.u64 .add (AffineRows3.u64 .add (AffineRows3.u64 .mul (toU64 (.local 36)) (u64l N))
        (toU64 (.local 7))) (toU64 (.local 35)))).run sh = some (u64 (m * N + 4 * (2 * g + s) + r), sh) :=
      eval_u64bin C (eval_u64bin C (eval_u64bin C (eval_toU64 C (eval_local' C (by rw [k₁ 36 (by omega)]; exact hol.m) sh)
        (by omega)) (eval_u64l C (by omega) sh) (binary_mul_u64 C m N))
        (eval_toU64 C (eval_local' C (by rw [k₁ 7 (by omega)]; exact hol.locs.n0) sh) (by omega)) (binary_add_u64 C _ _))
        (eval_toU64 C (eval_local' C (by rw [k₁ 35 (by omega)]; exact hol.r) sh) (by omega)) (binary_add_u64 C _ _)
    have hp := eval_offset_u64 C (o := 0) (eval_local' C (ctx := ctx) (by rw [k₁ 4 (by omega)]; exact hol.locs.y) sh) hidx
      (by omega)
    rw [show 0 + (m * N + 4 * (2 * g + s) + r) * (Ty.scalar .bf16).bytes = 2 * (m * N + (4 * (2 * g + s) + r)) by
      simp [Ty.bytes, Scalar.bytes]; ring] at hp
    have hst := store_bf16 ctx sh 4 (2 * (M * N)) 16 (m * N + (4 * (2 * g + s) + r)) (C.narrow v)
      (by rw [hreg]; exact hS.r4) (by norm_num) (by omega)
    subst hl₁
    exact .set hset (.ite htest (.store hp (eval_conv C (eval_local' C (setLocal_same _ _ _) _) rfl) hst (.nil _ _))
      (.nil _ _))
  · rw [ite_eq_right hi0]
    rw [decide_eq_false hi0] at htest
    subst hl₁
    exact .set hset (.ite htest (.nil _ _) (.nil _ _))
/-- From the start: the prologue, `acc = 0`, the K loop, to the first `simd_sum`. -/
theorem lane_first (hP : PSpec C V) (hQ : QSpec C V) (hV : V.Ok) (hS : Shape E.L V M N K ax aw as ab)
    (hD : Dims M N K) (hl : Lane ctx g s i) (hg : g < N / 8) {sh : Shared} (hI : In E sh) :
    ∃ l' sh', (∃ n, ∀ k, n ≤ k → (runThread C k ⟨ctx, fun _ => none, [.block (bodyG M N K (V.rowBytes K) V.pOff V.qfill)],
        .running⟩).run sh =
      some (⟨ctx, l', outFrames M N, .collective 1 37 .sum .f32
        (.f32 (acc C V K E.X E.W E.S E.B (4 * (2 * g + s) + 0) 0 i (K / 512))) 0⟩, sh')) ∧
      OutLocs V K g s i 0 0 l' ∧ Footprint ctx inR (own (tid g s i)) sh sh' ∧
      AccT C V M K E (4 * (2 * g + s)) i (K / 512) (sh'.bytes (accR (tid g s i))) := by
  have hsi := hl.hi; have hM0 := hD.m0; have hM1 := hD.m1
  -- the buffer pointers
  generalize hl₅ : setLocal (setLocal (setLocal (setLocal (setLocal (fun _ => none) 0 (ptr 0)) 1 (.ptr ⟨1, 0, .scalar .u32⟩))
    2 (ptr 2)) 3 (ptr 3)) 4 (ptr 4) = l₅
  have hptr : Exec C ctx ptrSets (fun _ => none) sh .normal l₅ sh := by
    rw [← hl₅]
    exact .set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _)
      (.set (eval_lit C _ _ _ _) (.nil _ _)))))
  obtain ⟨l₆, hpro, hloc₆⟩ := exec_prologue (C := C) (ctx := ctx) (V := V) hV hD hl hg (l := l₅) (sh := sh)
    (by rw [← hl₅]; simp [setLocal]) (by rw [← hl₅]; simp [setLocal]) (by rw [← hl₅]; simp [setLocal])
    (by rw [← hl₅]; simp [setLocal]) (by rw [← hl₅]; simp [setLocal])
  -- `acc = 0`
  obtain ⟨l₇, sh₇, hzero, k₇, hF₇, hacc₇⟩ := exec_zero (C := C) (ctx := ctx) (E := E) hS hD hI.regions hloc₆
  have hloc₇ := hloc₆.keep k₇
  -- `k0 = lane * VPT`, the K loop
  have hk0 : (eval C ctx l₇ (AffineRows3.u32 .mul (.local 5) (u32l 16))).run sh₇ = some (u32 (16 * i + 512 * 0), sh₇) := by
    rw [show 16 * i + 512 * 0 = i * 16 by ring]
    exact eval_u32bin C (eval_local' C hloc₇.lane sh₇) (eval_u32l C (by norm_num) sh₇) (binary_mul_u32 C i 16)
  have hI₇ := hI.frame hF₇ (fun q hq => by unfold isR accR at hq; omega)
  obtain ⟨l₉, sh₉, hkl, hloc₉, hF₉, hacc₉⟩ := exec_kloop (C := C) (ctx := ctx) (l := setLocal l₇ 14 (u32 (16 * i + 512 * 0)))
    (sh := sh₇) hP hQ hV hS hD hl hg hI₇
    (hloc₇.keep fun j hj => by rw [setLocal_other _ _ (by omega)]) (setLocal_same _ _ _) hacc₇
  -- the output loops, to the first `simd_sum`
  have hreg₉ : sh₉.regions = E.L.regions := hF₉.regions.trans hI₇.regions
  have hol : OutLocs V K g s i 0 0 (setLocal (setLocal l₉ 35 (u32 0)) 36 (u32 0)) :=
    ⟨hloc₉.keep fun j hj => by keep, by rw [setLocal_other _ _ (by omega), setLocal_same],
      setLocal_same _ _ _⟩
  have hcol := out_collective (C := C) (ctx := ctx) hS hD (N := N) (by norm_num) hM0 hol hreg₉
  rw [hacc₉ 0 (by norm_num) 0 hM0] at hcol
  have h35 := eval_u32bin C (ctx := ctx) (l := setLocal l₉ 35 (u32 0)) (sh := sh₉) (op := .lt) (a := .local 35) (b := u32l 4)
    (eval_local' C (setLocal_same _ _ _) sh₉) (eval_u32l C (by norm_num) sh₉) (binary_lt_u32 C 0 4 (by norm_num) (by norm_num))
  have h36 := eval_u32bin C (ctx := ctx) (l := setLocal (setLocal l₉ 35 (u32 0)) 36 (u32 0)) (sh := sh₉) (op := .lt)
    (a := .local 36) (b := u32l M) (eval_local' C (setLocal_same _ _ _) sh₉) (eval_u32l C (by omega) sh₉)
    (binary_lt_u32 C 0 M (by norm_num) (by omega))
  rw [decide_eq_true (by norm_num)] at h35
  rw [decide_eq_true hM0] at h36
  have houts : Exec C ctx (outLoops M N) l₉ sh₉ (.stop (.collective 1 37 .sum .f32
      (.f32 (acc C V K E.X E.W E.S E.B (4 * (2 * g + s) + 0) 0 i (K / 512))) 0)
      (([.block (outRest N)] ++ [.loop (c36 M) st36 (AffineRows3.outBody M N), .block []]) ++
        [.loop c35 st35 (forU 36 M (AffineRows3.outBody M N)), .block []]))
      (setLocal (setLocal l₉ 35 (u32 0)) 36 (u32 0)) sh₉ :=
    .set (eval_u32l C (by norm_num) sh₉) (.loop_stop h35 (.set (eval_u32l C (by norm_num) sh₉) (.loop_stop h36 hcol)))
  have hex : Exec C ctx (bodyG M N K (V.rowBytes K) V.pOff V.qfill) (fun _ => none) sh
      (.stop (.collective 1 37 .sum .f32 (.f32 (acc C V K E.X E.W E.S E.B (4 * (2 * g + s) + 0) 0 i (K / 512))) 0)
        ((([.block (outRest N)] ++ [.loop (c36 M) st36 (AffineRows3.outBody M N), .block []]) ++
          [.loop c35 st35 (forU 36 M (AffineRows3.outBody M N)), .block []]) ++ [.scope, .block []]))
      (setLocal (setLocal l₉ 35 (u32 0)) 36 (u32 0)) sh₉ :=
    Exec.append hptr (.scope_stop (Exec.append (Exec.append (Exec.append hpro hzero) (.set hk0 hkl)) houts))
  obtain ⟨n, hn⟩ := (hex.reaches_stop (K := [])).run rfl
  exact ⟨_, sh₉, ⟨n, hn⟩, hol, (hF₇.mono (fun _ h => h) (fun q h => by unfold own; unfold isR accR at h; omega)).trans hF₉,
    hacc₉⟩

/-- Resumed after the `simd_sum` of `(r, m)`, `m + 1 < M`: to the `simd_sum` of `(r, m + 1)`. -/
theorem lane_next_m (hS : Shape E.L V M N K ax aw as ab) (hD : Dims M N K) (hl : Lane ctx g s i) (hg : g < N / 8)
    {r m : Nat} (hr : r < 4) (hm : m + 1 < M) {l : Locals} (hol : OutLocs V K g s i r m l) (v : Float32) {sh : Shared}
    (hreg : sh.regions = E.L.regions) :
    ∃ l', (∃ n, ∀ k, n ≤ k → (runThread C k ⟨ctx, setLocal l 37 (.f32 v), outFrames M N, .running⟩).run sh =
      some (⟨ctx, l', outFrames M N, .collective 1 37 .sum .f32
        (.f32 (f32At (sh.bytes (accR (tid g s i))) (r * M + (m + 1)))) 0⟩,
        if i = 0 then wr ctx sh 4 (2 * (m * N + (4 * (2 * g + s) + r))) (C.narrow v) else sh)) ∧
      OutLocs V K g s i r (m + 1) l' := by
  have hM1 := hD.m1
  have hrest := out_rest (C := C) (ctx := ctx) hS hD hl hg hr (by omega) hol v hreg
  generalize hsh₁ : (if i = 0 then wr ctx sh 4 (2 * (m * N + (4 * (2 * g + s) + r))) (C.narrow v) else sh) = sh₁ at hrest
  have hreg₁ : sh₁.regions = E.L.regions := by rw [← hsh₁]; split <;> exact hreg
  have hb₁ : sh₁.bytes (accR (tid g s i)) = sh.bytes (accR (tid g s i)) := by
    rw [← hsh₁]; split
    · exact wr_bytes_other _ _ _ _ (by unfold accR; omega)
    · rfl
  generalize hl₁ : setLocal (setLocal l 37 (.f32 v)) 38 (.f32 v) = l₁ at hrest
  have k₁ : ∀ j, j < 37 → l₁ j = l j := fun j hj => by rw [← hl₁]; keep
  have hst : Exec C ctx st36 l₁ sh₁ .normal (setLocal l₁ 36 (u32 (m + 1))) sh₁ :=
    .set (eval_u32bin C (eval_local' C (by rw [k₁ 36 (by omega)]; exact hol.m) sh₁) (eval_u32l C (by norm_num) sh₁)
      (binary_add_u32 C m 1)) (.nil _ _)
  have hol₂ : OutLocs V K g s i r (m + 1) (setLocal l₁ 36 (u32 (m + 1))) :=
    ⟨hol.locs.keep fun j hj => by rw [setLocal_other _ _ (by omega), k₁ j (by omega)],
      by rw [setLocal_other _ _ (by omega), k₁ 35 (by omega)]; exact hol.r, setLocal_same _ _ _⟩
  have hc := eval_u32bin C (ctx := ctx) (l := setLocal l₁ 36 (u32 (m + 1))) (sh := sh₁) (op := .lt) (a := .local 36)
    (b := u32l M) (eval_local' C hol₂.m sh₁) (eval_u32l C (by omega) sh₁) (binary_lt_u32 C (m + 1) M (by omega) (by omega))
  rw [decide_eq_true hm] at hc
  have hb := out_collective (C := C) (ctx := ctx) hS hD (N := N) hr hm hol₂ hreg₁
  rw [hb₁] at hb
  refine ⟨_, (Exec.resume_stop (K := [.loop c35 st35 (forU 36 M (AffineRows3.outBody M N)), .block [], .scope, .block []])
    (ss := []) hrest (.inl rfl) hst hc hb).run rfl, hol₂⟩

/-- Resumed after the `simd_sum` of `(r, M - 1)`: the inner loop ends and the outer loop's step and test run. -/
theorem lane_exit_m (hS : Shape E.L V M N K ax aw as ab) (hD : Dims M N K) (hl : Lane ctx g s i) (hg : g < N / 8)
    {r m : Nat} (hr : r < 4) (hm : m + 1 = M) {l : Locals} (hol : OutLocs V K g s i r m l) (v : Float32) {sh : Shared}
    (hreg : sh.regions = E.L.regions) :
    ∃ l₂, Reaches C ⟨ctx, setLocal l 37 (.f32 v), outFrames M N, .running⟩ sh
      ⟨ctx, l₂, [.loop c35 st35 (forU 36 M (AffineRows3.outBody M N)), .block [], .scope, .block []], .running⟩
      (if i = 0 then wr ctx sh 4 (2 * (m * N + (4 * (2 * g + s) + r))) (C.narrow v) else sh) ∧
      Exec C ctx st35 l₂ (if i = 0 then wr ctx sh 4 (2 * (m * N + (4 * (2 * g + s) + r))) (C.narrow v) else sh) .normal
        (setLocal l₂ 35 (u32 (r + 1))) (if i = 0 then wr ctx sh 4 (2 * (m * N + (4 * (2 * g + s) + r))) (C.narrow v) else sh) ∧
      Locs V K g s i l₂ := by
  have hM1 := hD.m1
  have hrest := out_rest (C := C) (ctx := ctx) hS hD hl hg hr (by omega) hol v hreg
  generalize hsh₁ : (if i = 0 then wr ctx sh 4 (2 * (m * N + (4 * (2 * g + s) + r))) (C.narrow v) else sh) = sh₁ at hrest ⊢
  generalize hl₁ : setLocal (setLocal l 37 (.f32 v)) 38 (.f32 v) = l₁ at hrest
  have k₁ : ∀ j, j < 37 → l₁ j = l j := fun j hj => by rw [← hl₁]; keep
  have hst : Exec C ctx st36 l₁ sh₁ .normal (setLocal l₁ 36 (u32 (m + 1))) sh₁ :=
    .set (eval_u32bin C (eval_local' C (by rw [k₁ 36 (by omega)]; exact hol.m) sh₁) (eval_u32l C (by norm_num) sh₁)
      (binary_add_u32 C m 1)) (.nil _ _)
  have hc := eval_u32bin C (ctx := ctx) (l := setLocal l₁ 36 (u32 (m + 1))) (sh := sh₁) (op := .lt) (a := .local 36)
    (b := u32l M) (eval_local' C (setLocal_same _ _ _) sh₁) (eval_u32l C (by omega) sh₁)
    (binary_lt_u32 C (m + 1) M (by omega) (by omega))
  rw [decide_eq_false (by omega)] at hc
  have h1 := Exec.resume_exit (K := [.loop c35 st35 (forU 36 M (AffineRows3.outBody M N)), .block [], .scope, .block []])
    (ss := []) (b := AffineRows3.outBody M N) hrest (.inl rfl) hst hc
  refine ⟨setLocal l₁ 36 (u32 (m + 1)), h1.trans (.single rfl (step_pop C)),
    .set (eval_u32bin C (eval_local' C (by rw [setLocal_other _ _ (by omega), k₁ 35 (by omega)]; exact hol.r) sh₁)
      (eval_u32l C (by norm_num) sh₁) (binary_add_u32 C r 1)) (.nil _ _),
    hol.locs.keep fun j hj => by rw [setLocal_other _ _ (by omega), k₁ j (by omega)]⟩

/-- Resumed after the `simd_sum` of `(r, M - 1)`, `r + 1 < 4`: to the `simd_sum` of `(r + 1, 0)`. -/
theorem lane_next_r (hS : Shape E.L V M N K ax aw as ab) (hD : Dims M N K) (hl : Lane ctx g s i) (hg : g < N / 8)
    {r m : Nat} (hr : r + 1 < 4) (hm : m + 1 = M) {l : Locals} (hol : OutLocs V K g s i r m l) (v : Float32) {sh : Shared}
    (hreg : sh.regions = E.L.regions) :
    ∃ l', (∃ n, ∀ k, n ≤ k → (runThread C k ⟨ctx, setLocal l 37 (.f32 v), outFrames M N, .running⟩).run sh =
      some (⟨ctx, l', outFrames M N, .collective 1 37 .sum .f32
        (.f32 (f32At (sh.bytes (accR (tid g s i))) ((r + 1) * M + 0))) 0⟩,
        if i = 0 then wr ctx sh 4 (2 * (m * N + (4 * (2 * g + s) + r))) (C.narrow v) else sh)) ∧
      OutLocs V K g s i (r + 1) 0 l' := by
  have hM1 := hD.m1; have hM0 := hD.m0
  obtain ⟨l₂, h1, hst, hloc₂⟩ := lane_exit_m (C := C) hS hD hl hg (by omega) hm hol v hreg
  generalize hsh₁ : (if i = 0 then wr ctx sh 4 (2 * (m * N + (4 * (2 * g + s) + r))) (C.narrow v) else sh) = sh₁ at h1 hst ⊢
  have hreg₁ : sh₁.regions = E.L.regions := by rw [← hsh₁]; split <;> exact hreg
  have hb₁ : sh₁.bytes (accR (tid g s i)) = sh.bytes (accR (tid g s i)) := by
    rw [← hsh₁]; split
    · exact wr_bytes_other _ _ _ _ (by unfold accR; omega)
    · rfl
  have hc35 := eval_u32bin C (ctx := ctx) (l := setLocal l₂ 35 (u32 (r + 1))) (sh := sh₁) (op := .lt) (a := .local 35)
    (b := u32l 4) (eval_local' C (setLocal_same _ _ _) sh₁) (eval_u32l C (by norm_num) sh₁)
    (binary_lt_u32 C (r + 1) 4 (by omega) (by norm_num))
  rw [decide_eq_true hr] at hc35
  have hol₃ : OutLocs V K g s i (r + 1) 0 (setLocal (setLocal l₂ 35 (u32 (r + 1))) 36 (u32 0)) :=
    ⟨hloc₂.keep fun j hj => by keep, by rw [setLocal_other _ _ (by omega), setLocal_same], setLocal_same _ _ _⟩
  have hc36 := eval_u32bin C (ctx := ctx) (l := setLocal (setLocal l₂ 35 (u32 (r + 1))) 36 (u32 0)) (sh := sh₁) (op := .lt)
    (a := .local 36) (b := u32l M) (eval_local' C hol₃.m sh₁) (eval_u32l C (by omega) sh₁)
    (binary_lt_u32 C 0 M (by norm_num) (by omega))
  rw [decide_eq_true hM0] at hc36
  have hb := out_collective (C := C) (ctx := ctx) hS hD (N := N) hr hM0 hol₃ hreg₁
  rw [hb₁] at hb
  have h2 : Reaches C ⟨ctx, l₂, [.loop c35 st35 (forU 36 M (AffineRows3.outBody M N)), .block [], .scope, .block []], .running⟩
      sh₁ ⟨ctx, setLocal (setLocal l₂ 35 (u32 (r + 1))) 36 (u32 0), outFrames M N, .collective 1 37 .sum .f32
        (.f32 (f32At (sh.bytes (accR (tid g s i))) ((r + 1) * M + 0))) 0⟩ sh₁ :=
    Exec.resume_loop (K := [.scope, .block []]) (ss := []) hst
      (.loop_stop hc35 (.set (eval_u32l C (by norm_num) sh₁) (.loop_stop hc36 hb))) rfl
  exact ⟨_, (h1.trans h2).run rfl, hol₃⟩

/-- Resumed after the last `simd_sum`: to the end. -/
theorem lane_last (hS : Shape E.L V M N K ax aw as ab) (hD : Dims M N K) (hl : Lane ctx g s i) (hg : g < N / 8)
    {m : Nat} (hm : m + 1 = M) {l : Locals} (hol : OutLocs V K g s i 3 m l) (v : Float32) {sh : Shared}
    (hreg : sh.regions = E.L.regions) :
    ∃ l', (∃ n, ∀ k, n ≤ k → (runThread C k ⟨ctx, setLocal l 37 (.f32 v), outFrames M N, .running⟩).run sh =
      some (⟨ctx, l', [], .done⟩, if i = 0 then wr ctx sh 4 (2 * (m * N + (4 * (2 * g + s) + 3))) (C.narrow v) else sh)) := by
  obtain ⟨l₂, h1, hst, -⟩ := lane_exit_m (C := C) hS hD hl hg (by norm_num) hm hol v hreg
  generalize hsh₁ : (if i = 0 then wr ctx sh 4 (2 * (m * N + (4 * (2 * g + s) + 3))) (C.narrow v) else sh) = sh₁ at h1 hst ⊢
  have hc35 := eval_u32bin C (ctx := ctx) (l := setLocal l₂ 35 (u32 (3 + 1))) (sh := sh₁) (op := .lt) (a := .local 35)
    (b := u32l 4) (eval_local' C (setLocal_same _ _ _) sh₁) (eval_u32l C (by norm_num) sh₁)
    (binary_lt_u32 C (3 + 1) 4 (by norm_num) (by norm_num))
  rw [decide_eq_false (by norm_num)] at hc35
  have h2 := Exec.resume_loop (C := C) (ctx := ctx) (K := [.scope, .block []]) (ss := []) (F := [.scope, .block []])
    (b := forU 36 M (AffineRows3.outBody M N)) hst
    (.loop_exit hc35 (.nil _ _)) rfl
  exact ⟨_, (h1.trans (h2.trans (.cons rfl (step_scope_pop C) (.cons rfl (step_pop C) (.single rfl (step_done C)))))).run rfl⟩

end Thread

/-! ## SIMD-groups, threadgroups and the launch -/

/-- The elements `(a, n)` of `y` written before the store of `(r, m)` by the SIMD-group whose rows start at `nY`:
the earlier SIMD-groups' rows, this one's rows before `nY + r`, and row `nY + r` before `m`. -/
def Wr (M nY r m : Nat) (a n : Nat) : Prop := a < M ∧ (n < nY ∨ (nY ≤ n ∧ n < nY + r) ∨ (n = nY + r ∧ a < m))

section Groups
variable {C : M1Max.Contract} {V : Variant} {M N K ax aw as ab : Nat} {E : Env}

/-- Lane 0 of the SIMD-group owning row `n` writes `y[m][n]`. -/
theorem Mem.wy {P : Nat → Nat → Prop} {sh : Shared} (h : Mem C V M N K E P sh) (hS : Shape E.L V M N K ax aw as ab)
    (ctx : Ctx) {m n : Nat} (hm : m < M) (hn : n < N) (ht : ctx.thread = 64 * (n / 8) + 32 * (n % 8 / 4))
    (hg : ctx.group = n / 8) :
    Mem C V M N K E (fun a b => P a b ∨ (a = m ∧ b = n)) (wr ctx sh 4 (2 * (m * N + n)) (yv C V K E.X E.W E.S E.B m n)) where
  regions := h.regions
  x := (wr_bytes_other ctx sh _ _ (show (0 : Nat) ≠ 4 by decide)).trans h.x
  w := (wr_bytes_other ctx sh _ _ (show (1 : Nat) ≠ 4 by decide)).trans h.w
  s := (wr_bytes_other ctx sh _ _ (show (2 : Nat) ≠ 4 by decide)).trans h.s
  b := (wr_bytes_other ctx sh _ _ (show (3 : Nat) ≠ 4 by decide)).trans h.b
  dEpoch := h.dEpoch
  y a b hp := by
    have hval : ∀ j < 2, (wr ctx sh 4 (2 * (m * N + n)) (yv C V K E.X E.W E.S E.B m n)).bytes 4 (2 * (m * N + n) + j) =
        (wordBytes 2 (Val.bf16Bits (yv C V K E.X E.W E.S E.B m n))).getD j 0 := fun j hj => by
      show writeBytes (sh.bytes 4) (2 * (m * N + n)) (wordBytes 2 (Val.bf16Bits (yv C V K E.X E.W E.S E.B m n))) _ = _
      rw [writeBytes_inside _ _ _ j (by rw [wordBytes_length]; omega)]
    rcases hp with hp | ⟨rfl, rfl⟩
    · obtain ⟨ha, hb, hy⟩ := h.y a b hp
      refine ⟨ha, hb, fun j hj => ?_⟩
      by_cases he : a * N + b = m * N + n
      · obtain ⟨rfl, rfl⟩ := idx_inj hb hn he
        exact hval j hj
      · show writeBytes (sh.bytes 4) (2 * (m * N + n)) (wordBytes 2 (Val.bf16Bits (yv C V K E.X E.W E.S E.B m n))) _ = _
        rw [writeBytes_outside _ _ _ _ (by rw [wordBytes_length]; omega)]
        exact hy j hj
    · exact ⟨hm, hn, hval⟩
  log := forall_log _ 2 _ (fun j hj => owned_device E.L (dev N) tgo ctx sh 4 (2 * (m * N + n) + j) _ hS.r4 true (by simp)
    ⟨64 * ((2 * (m * N + n) + j) / 2 % N / 8) + 32 * ((2 * (m * N + n) + j) / 2 % N % 8 / 4),
      (2 * (m * N + n) + j) / 2 % N / 8, 0⟩ (by simp [dev])
    (by rw [show (2 * (m * N + n) + j) / 2 = m * N + n by omega, idx_mod hn]; exact ht)
    (by rw [show (2 * (m * N + n) + j) / 2 = m * N + n by omega, idx_mod hn]; exact hg) (by rw [h.dEpoch])) h.log

/-- The launch's structure: threadgroups of two SIMD-groups tiling the grid along y, five buffers, no threadgroup
arrays, four thread arrays per thread, and the common core's body. -/
structure Tiled (L : Launch) (V : Variant) (M N K : Nat) : Prop where
  tiles : L.Tiles 64 1 1 1 (N / 8) 1 2
  buffers : L.buffers.length = 5
  groupArrays : L.groupArrays = 0
  threadArrays : L.threadArrays = 4
  body : L.kernel.body = bodyG M N K (V.rowBytes K) V.pOff V.qfill

theorem lane_of {L : Launch} (hT : Tiled L V M N K) (fuse : Nat → Bool) (g : Nat) (s : Fin 2) (i : Fin 32) :
    Lane (L.ctxAt fuse 0 g 0 (32 * s + i)) g s i where
  tg := Launch.ctxAt_threadgroupPositionInGrid _ _ _ _ _ _
  lane := Launch.ctxAt_lane _ _ _ _ _ _ _
  sg := Launch.ctxAt_simd _ _ _ _ _ _ _
  thread := by rw [hT.tiles.thread]; unfold tid; omega
  group := by rw [hT.tiles.group_id]; omega
  ta j := by rw [hT.tiles.threadArray, hT.buffers, hT.groupArrays, hT.threadArrays]; unfold tid; omega
  hs := s.isLt
  hi := i.isLt

/-- The `acc` arrays of the SIMD-group's lanes below `k`, after the K loop. -/
def ResD (C : M1Max.Contract) (V : Variant) (M K : Nat) (E : Env) (g s k : Nat) (sh : Shared) : Prop :=
  ∀ i < k, AccT C V M K E (4 * (2 * g + s)) i (K / 512) (sh.bytes (accR (tid g s i)))

/-- A lane stopped at the `simd_sum` of `(r, m)`. -/
def POut (L : Launch) (fuse : Nat → Bool) (V : Variant) (M N K g s r m : Nat) (i : Fin 32) (t : Thread) : Prop :=
  t.ctx = L.ctxAt fuse 0 g 0 (32 * s + i) ∧ t.frames = outFrames M N ∧ OutLocs V K g s i r m t.locals

/-- `simd_sum(acc[r][m])` of SIMD-group `(g, s)`. -/
def vsum (C : M1Max.Contract) (V : Variant) (K : Nat) (E : Env) (g s r m : Nat) : Float32 :=
  C.simdSum fun L : Fin 32 => acc C V K E.X E.W E.S E.B (4 * (2 * g + s) + r) m L (K / 512)

/-- From the lanes stopped at the `simd_sum` of `(r, m)`, to the end. -/
def Rounds (C : M1Max.Contract) (V : Variant) (M N K : Nat) (E : Env) (fuse : Nat → Bool) (g : Nat) (s : Fin 2)
    (r m : Nat) : Prop :=
  ∀ (U : Fin 32 → Thread) (sh : Shared), (∀ i, POut E.L fuse V M N K g s r m i (U i)) →
    Mem C V M N K E (Wr M (4 * (2 * g + s)) r m) sh → ResD C V M K E g s 32 sh →
    ∃ (f rr : Nat) (W : Fin 32 → Thread) (sh' : Shared),
      (runSimd C f rr (List.ofFn fun i => { U i with status := .running }.set 37 (.f32 (vsum C V K E g s r m)))).run sh =
        some (List.ofFn W, sh') ∧ Mem C V M N K E (Wr M (4 * (2 * g + s) + 4) 0 0) sh' ∧ ∀ i, (W i).status = .done

/-- A lane's round from the `simd_sum` of `(r, m)`: lane 0's store of `y[m][n0 + r]`, the memory it leaves, and the
`acc` arrays kept. -/
theorem round_mem (hS : Shape E.L V M N K ax aw as ab) (hD : Dims M N K) {ctx : Ctx} {g s : Nat} {i : Fin 32}
    (hl : Lane ctx g s i) (hg : g < N / 8) {r m : Nat} (hr : r < 4) (hm : m < M) {sh : Shared}
    (hM : Mem C V M N K E (Wr M (4 * (2 * g + s)) r (m + min (i : Nat) 1)) sh) (hR : ResD C V M K E g s 32 sh) :
    Mem C V M N K E (Wr M (4 * (2 * g + s)) r (m + min ((i : Nat) + 1) 1))
      (if (i : Nat) = 0 then wr ctx sh 4 (2 * (m * N + (4 * (2 * g + s) + r))) (C.narrow (vsum C V K E g s r m)) else sh) ∧
    ResD C V M K E g s 32
      (if (i : Nat) = 0 then wr ctx sh 4 (2 * (m * N + (4 * (2 * g + s) + r))) (C.narrow (vsum C V K E g s r m)) else sh) ∧
    (if (i : Nat) = 0 then wr ctx sh 4 (2 * (m * N + (4 * (2 * g + s) + r))) (C.narrow (vsum C V K E g s r m)) else sh).regions =
      E.L.regions := by
  have hss := hl.hs; have hN8 := hD.n8
  by_cases hi0 : (i : Nat) = 0
  · rw [ite_eq_left hi0]
    have hw := hM.wy hS ctx (n := 4 * (2 * g + s) + r) hm (by omega)
      (by rw [hl.thread]; unfold tid; omega) (by rw [hl.group]; omega)
    refine ⟨hw.mono fun a n ⟨ha, h⟩ => ?_, fun i' hi' r' hr' m' hm' => ?_, hM.regions⟩
    · rw [hi0] at h
      rcases h with h | h | ⟨rfl, h⟩
      · exact .inl ⟨ha, .inl h⟩
      · exact .inl ⟨ha, .inr (.inl h)⟩
      · by_cases ham : a < m
        · exact .inl ⟨ha, .inr (.inr ⟨rfl, by omega⟩)⟩
        · exact .inr ⟨by omega, rfl⟩
    · rw [wr_bytes_other ctx sh _ _ (show accR (tid g s i') ≠ 4 by unfold accR; omega)]; exact hR i' hi' r' hr' m' hm'
  · rw [ite_eq_right hi0]
    exact ⟨by rw [show min ((i : Nat) + 1) 1 = min (i : Nat) 1 by omega]; exact hM, hR, hM.regions⟩

/-- The last round: to the end. -/
theorem rounds_last (hS : Shape E.L V M N K ax aw as ab) (hD : Dims M N K) (hT : Tiled E.L V M N K) (fuse : Nat → Bool)
    (g : Nat) (hg : g < N / 8) (s : Fin 2) {m : Nat} (hm : m + 1 = M) : Rounds C V M N K E fuse g s 3 m := by
  intro U sh hU hM hR
  obtain ⟨f, rr, W, sh', hr, ⟨hI, -⟩, hW⟩ := simd_blocked_bound C (fun i => { U i with status := .running }.set 37
      (.f32 (vsum C V K E g s 3 m)))
    (fun k sh => Mem C V M N K E (Wr M (4 * (2 * g + s)) 3 (m + min k 1)) sh ∧ ResD C V M K E g s 32 sh)
    (fun _ t => t.status = .done)
    (fun i sh ⟨hI, hR⟩ => by
      obtain ⟨hc, hf, hol⟩ := hU i
      rw [resume_eq (U i) _ _ hc hf]
      have hl := lane_of hT fuse g s i
      obtain ⟨hM', hR', -⟩ := round_mem (C := C) hS hD hl hg (by norm_num) (by omega) hI hR
      obtain ⟨l', n, hn⟩ := lane_last (C := C) hS hD hl hg hm hol (vsum C V K E g s 3 m) (hI.regions)
      exact ⟨n, _, _, hn n le_rfl, ⟨hM', hR'⟩, rfl, rfl⟩) sh ⟨by simpa using hM, hR⟩
  exact ⟨f, rr, W, sh', hr, hI.mono fun a n ⟨ha, h⟩ => ⟨ha, by omega⟩, hW⟩

theorem rounds_all (hS : Shape E.L V M N K ax aw as ab) (hD : Dims M N K) (hT : Tiled E.L V M N K) (fuse : Nat → Bool)
    (g : Nat) (hg : g < N / 8) (s : Fin 2) :
    ∀ d r m, r < 4 → m < M → r * M + m + 1 + d = 4 * M → Rounds C V M N K E fuse g s r m := by
  have hM0 := hD.m0
  intro d
  induction d with
  | zero =>
    intro r m hr hm h
    have : r = 3 ∧ m + 1 = M := by
      rcases (show r = 0 ∨ r = 1 ∨ r = 2 ∨ r = 3 by omega) with rfl | rfl | rfl | rfl <;> omega
    obtain ⟨rfl, hm1⟩ := this
    exact rounds_last hS hD hT fuse g hg s hm1
  | succ d ih =>
    intro r m hr hm h U sh hU hM hR
    by_cases hm1 : m + 1 < M
    · -- the next `simd_sum` is `(r, m + 1)`
      refine simd_collective_bound C (fun i => { U i with status := .running }.set 37 (.f32 (vsum C V K E g s r m)))
        1 37 .sum .f32 0 (fun i => .f32 (acc C V K E.X E.W E.S E.B (4 * (2 * g + s) + r) (m + 1) i (K / 512)))
        (fun _ => .f32 (vsum C V K E g s r (m + 1))) (resolve_sum C 0 _)
        (fun k sh => Mem C V M N K E (Wr M (4 * (2 * g + s)) r (m + min k 1)) sh ∧ ResD C V M K E g s 32 sh)
        (POut E.L fuse V M N K g s r (m + 1)) (fun sh => Mem C V M N K E (Wr M (4 * (2 * g + s) + 4) 0 0) sh)
        (fun _ t => t.status = .done) (fun i sh hI => ?_) (fun U' sh' hP hI => ?_) sh ⟨by simpa using hM, hR⟩
      · obtain ⟨hc, hf, hol⟩ := hU i
        rw [resume_eq (U i) _ _ hc hf]
        obtain ⟨hI, hR⟩ := hI
        have hl := lane_of hT fuse g s i
        obtain ⟨hM', hR', -⟩ := round_mem (C := C) hS hD hl hg hr hm hI hR
        obtain ⟨l', ⟨n, hn⟩, hol'⟩ := lane_next_m (C := C) hS hD hl hg hr hm1 hol (vsum C V K E g s r m) hI.regions
        rw [hR i i.isLt r hr (m + 1) hm1] at hn
        exact ⟨n, _, _, hn n le_rfl, ⟨hM', hR'⟩, rfl, rfl, rfl, hol'⟩
      · obtain ⟨hI, hR⟩ := hI
        exact ih r (m + 1) hr hm1 (by omega) U' sh' hP (by simpa using hI) hR
    · -- the next `simd_sum` is `(r + 1, 0)`
      have hm1 : m + 1 = M := by omega
      have hr1 : r + 1 < 4 := by
        by_contra hc
        have : r = 3 := by omega
        subst this
        omega
      refine simd_collective_bound C (fun i => { U i with status := .running }.set 37 (.f32 (vsum C V K E g s r m)))
        1 37 .sum .f32 0 (fun i => .f32 (acc C V K E.X E.W E.S E.B (4 * (2 * g + s) + (r + 1)) 0 i (K / 512)))
        (fun _ => .f32 (vsum C V K E g s (r + 1) 0)) (resolve_sum C 0 _)
        (fun k sh => Mem C V M N K E (Wr M (4 * (2 * g + s)) r (m + min k 1)) sh ∧ ResD C V M K E g s 32 sh)
        (POut E.L fuse V M N K g s (r + 1) 0) (fun sh => Mem C V M N K E (Wr M (4 * (2 * g + s) + 4) 0 0) sh)
        (fun _ t => t.status = .done) (fun i sh hI => ?_) (fun U' sh' hP hI => ?_) sh ⟨by simpa using hM, hR⟩
      · obtain ⟨hc, hf, hol⟩ := hU i
        rw [resume_eq (U i) _ _ hc hf]
        obtain ⟨hI, hR⟩ := hI
        have hl := lane_of hT fuse g s i
        obtain ⟨hM', hR', -⟩ := round_mem (C := C) hS hD hl hg hr hm hI hR
        obtain ⟨l', ⟨n, hn⟩, hol'⟩ := lane_next_r (C := C) hS hD hl hg hr1 hm1 hol (vsum C V K E g s r m) hI.regions
        rw [hR i i.isLt (r + 1) hr1 0 hM0] at hn
        exact ⟨n, _, _, hn n le_rfl, ⟨hM', hR'⟩, rfl, rfl, rfl, hol'⟩
      · obtain ⟨hI, hR⟩ := hI
        exact ih (r + 1) 0 hr1 hM0 (by rw [Nat.succ_mul]; omega) U' sh' hP (hI.mono fun a n ⟨ha, h⟩ => ⟨ha, by omega⟩) hR

/-- SIMD-group `s` of threadgroup `g`: its lanes to the first `simd_sum`, then the `4 M` rounds. -/
theorem simd_run (hP : PSpec C V) (hQ : QSpec C V) (hV : V.Ok) (hS : Shape E.L V M N K ax aw as ab) (hD : Dims M N K)
    (hT : Tiled E.L V M N K) (fuse : Nat → Bool) (g : Nat) (hg : g < N / 8) (s : Fin 2) (sh : Shared)
    (hM : Mem C V M N K E (Wr M (4 * (2 * g + s)) 0 0) sh) :
    ∃ (f r : Nat) (W : Fin 32 → Thread) (sh' : Shared),
      (runSimd C f r (List.ofFn (E.L.lanes fuse 0 g 0 s))).run sh = some (List.ofFn W, sh') ∧
      Mem C V M N K E (Wr M (4 * (2 * g + s) + 4) 0 0) sh' ∧ ∀ i, (W i).status = .done := by
  have hM0 := hD.m0
  refine simd_collective_bound C (E.L.lanes fuse 0 g 0 s) 1 37 .sum .f32 0
    (fun i => .f32 (acc C V K E.X E.W E.S E.B (4 * (2 * g + s) + 0) 0 i (K / 512)))
    (fun _ => .f32 (vsum C V K E g s 0 0)) (resolve_sum C 0 _)
    (fun k sh => Mem C V M N K E (Wr M (4 * (2 * g + s)) 0 0) sh ∧ ResD C V M K E g s k sh)
    (POut E.L fuse V M N K g s 0 0) (fun sh => Mem C V M N K E (Wr M (4 * (2 * g + s) + 4) 0 0) sh)
    (fun _ t => t.status = .done) (fun i sh hI => ?_) (fun U sh hP hI => ?_) sh ⟨hM, fun _ h => absurd h (Nat.not_lt_zero _)⟩
  · obtain ⟨hI, hR⟩ := hI
    have hl := lane_of hT fuse g s i
    obtain ⟨l', sh', ⟨n, hn⟩, hol, hF, hacc⟩ := lane_first (C := C) hP hQ hV hS hD hl hg hI.toIn
    have hrun : (runThread C n (E.L.lanes fuse 0 g 0 s i)).run sh = some (⟨E.L.ctxAt fuse 0 g 0 (32 * s + i), l',
        outFrames M N, .collective 1 37 .sum .f32 (.f32 (acc C V K E.X E.W E.S E.B (4 * (2 * g + s) + 0) 0 i (K / 512))) 0⟩,
        sh') := by
      show (runThread C n ⟨_, fun _ => none, [.block E.L.kernel.body], .running⟩).run sh = _
      rw [hT.body]
      exact hn n le_rfl
    refine ⟨n, _, sh', hrun, ⟨hI.frame hS hF (fun r hr => hr) (fun r hr => by unfold own at hr; omega), fun i' hi' => ?_⟩,
      rfl, rfl, rfl, hol⟩
    · by_cases hii : i' = i
      · subst hii; exact hacc
      · intro r hr m hm
        rw [hF.bytes (accR (tid g s i')) (by unfold own accR tid; omega)]
        exact hR i' (by omega) r hr m hm
  · obtain ⟨hI, hR⟩ := hI
    exact rounds_all hS hD hT fuse g hg s (4 * M - 1) 0 0 (by norm_num) hM0 (by omega) U sh hP
      (hI.mono fun a n h => h) hR

/-- Threadgroup `g`: its two SIMD-groups in order. -/
theorem group_run (hP : PSpec C V) (hQ : QSpec C V) (hV : V.Ok) (hS : Shape E.L V M N K ax aw as ab) (hD : Dims M N K)
    (hT : Tiled E.L V M N K) (fuse : Nat → Bool) (g : Nat) (hg : g < N / 8) (sh : Shared)
    (hM : Mem C V M N K E (Wr M (8 * g) 0 0) sh) :
    ∃ f r b sh', (runGroup C f r b (List.ofFn fun s : Fin 2 => List.ofFn (E.L.lanes fuse 0 g 0 s))).run sh =
      some ((), sh') ∧ Mem C V M N K E (Wr M (8 * (g + 1)) 0 0) sh' := by
  obtain ⟨f, r, b, sh', hr, hI⟩ := group_done_bound C (fun s : Fin 2 => E.L.lanes fuse 0 g 0 s)
    (fun j sh => Mem C V M N K E (Wr M (4 * (2 * g + j)) 0 0) sh)
    (fun j sh hj => by
      obtain ⟨f, r, W, sh', hr, hM', hW⟩ := simd_run hP hQ hV hS hD hT fuse g hg j sh hj
      exact ⟨f, r, W, sh', hr, by rw [show 4 * (2 * g + ((j : Nat) + 1)) = 4 * (2 * g + j) + 4 by ring]; exact hM', hW⟩)
    sh (by rw [show 4 * (2 * g + 0) = 8 * g by ring]; exact hM)
  exact ⟨f, r, b, sh', hr, by rw [show 8 * (g + 1) = 4 * (2 * g + 2) by ring]; exact hI⟩

end Groups

/-! ## The launch -/

/-- The input buffers: x [M, K] bf16, w [N, rowBytes / 4] uint32, scales and biases [N, K/64] bf16. -/
def inputsOf (V : Variant) (M N K : Nat) (X W S B : ByteMemory.Bytes) (ax aw as ab : Nat) : List Buffer :=
  [⟨.device, 2 * (M * K), ax, X⟩, ⟨.device, N * V.rowBytes K, aw, W⟩, ⟨.device, 2 * (N * (K / 64)), as, S⟩,
   ⟨.device, 2 * (N * (K / 64)), ab, B⟩]

/-- MLX's launch: grid [64, N/8, 1], threadgroup [64, 1, 1], y [M, N] bf16. -/
def launchOf (V : Variant) (M N K : Nat) (X W S B : ByteMemory.Bytes) (ax aw as ab : Nat)
    (initial : Nat → ByteMemory.Bytes) : Launch :=
  ⟨coreG V M N K, (64, N / 8, 1), (64, 1, 1), buffers (inputsOf V M N K X W S B ax aw as ab) [2 * (M * N)] 16 initial⟩

def envOf (V : Variant) (M N K : Nat) (X W S B : ByteMemory.Bytes) (ax aw as ab : Nat) (initial : Nat → ByteMemory.Bytes) :
    Env :=
  ⟨launchOf V M N K X W S B ax aw as ab initial, X, W, S, B⟩

section Launch
variable {C : M1Max.Contract} {V : Variant} {M N K : Nat} {X W S B : ByteMemory.Bytes} {ax aw as ab : Nat}
  {initial : Nat → ByteMemory.Bytes}

theorem envOf_tiled (hD : Dims M N K) : Tiled (envOf V M N K X W S B ax aw as ab initial).L V M N K where
  tiles := ⟨rfl, by show (64, N / 8, 1) = (1 * 64, N / 8 * 1, 1 * 1); simp, rfl,
    ⟨by norm_num, by norm_num, by have := hD.n0; have := hD.n8; omega, by norm_num⟩⟩
  buffers := by simp [envOf, launchOf, buffers, inputsOf]
  groupArrays := rfl
  threadArrays := rfl
  body := rfl

theorem envOf_shape (hax : ax % 8 = 0) (haw : aw % V.wAlign = 0) (has : as % 2 = 0) (hab : ab % 2 = 0) :
    Shape (envOf V M N K X W S B ax aw as ab initial).L V M N K ax aw as ab := by
  have hb : (launchOf V M N K X W S B ax aw as ab initial).buffers =
      buffers (inputsOf V M N K X W S B ax aw as ab) [2 * (M * N)] 16 initial := rfl
  have hlen : (launchOf V M N K X W S B ax aw as ab initial).buffers.length = 5 := by
    simp [launchOf, buffers, inputsOf]
  have ht : ∀ T j (t : Ty) (n : Nat), (coreG V M N K).threadArrays[j]? = some (t, n) →
      (launchOf V M N K X W S B ax aw as ab initial).regions (4 * T + 5 + j) = some ⟨.thread, t.bytes * n, alignment t⟩ := by
    intro T j t n h
    have := Launch.regions_threadArray (launchOf V M N K X W S B ax aw as ab initial) T j t n h
    rw [hlen, show Launch.groupArrays _ = 0 from rfl, show Launch.threadArrays _ = 4 from rfl] at this
    rw [show 4 * T + 5 + j = 5 + 0 + T * 4 + j by ring]; exact this
  refine ⟨regions_input hb 0 (by simp [inputsOf]), regions_input hb 1 (by simp [inputsOf]),
    regions_input hb 2 (by simp [inputsOf]), regions_input hb 3 (by simp [inputsOf]), regions_output hb 0 (by simp),
    fun T => ht T 0 _ _ rfl, fun T => ht T 1 _ _ rfl, fun T => ht T 2 _ _ rfl, fun T => ht T 3 _ _ rfl,
    hax, haw, has, hab⟩

/-- The launch: its N/8 threadgroups in order. -/
theorem launch_inv (hP : PSpec C V) (hQ : QSpec C V) (hV : V.Ok) (hD : Dims M N K) (hax : ax % 8 = 0)
    (haw : aw % V.wAlign = 0) (has : as % 2 = 0) (hab : ab % 2 = 0) (fuse : Nat → Bool) (garbage : Garbage) :
    ∃ n sh, Mem C V M N K (envOf V M N K X W S B ax aw as ab initial) (Wr M N 0 0) sh ∧
      runLaunch C fuse (launchOf V M N K X W S B ax aw as ab initial) garbage n n n = some ⟨sh.bytes, sh.log⟩ := by
  have hT := envOf_tiled (V := V) (X := X) (W := W) (S := S) (B := B) (ax := ax) (aw := aw) (as := as) (ab := ab)
    (initial := initial) hD
  have hS := envOf_shape (V := V) (M := M) (N := N) (K := K) (X := X) (W := W) (S := S) (B := B) (initial := initial)
    hax haw has hab
  have hb : (launchOf V M N K X W S B ax aw as ab initial).buffers =
      buffers (inputsOf V M N K X W S B ax aw as ab) [2 * (M * N)] 16 initial := rfl
  have h0 : Mem C V M N K (envOf V M N K X W S B ax aw as ab initial) (Wr M (8 * 0) 0 0)
      ((launchOf V M N K X W S B ax aw as ab initial).initial garbage) :=
    { regions := rfl
      x := initial_input hb garbage 0 (by simp [inputsOf])
      w := initial_input hb garbage 1 (by simp [inputsOf])
      s := initial_input hb garbage 2 (by simp [inputsOf])
      b := initial_input hb garbage 3 (by simp [inputsOf])
      dEpoch := rfl
      y := fun a n ⟨_, h⟩ => absurd h (by omega)
      log := fun a ha => by simp [Launch.initial] at ha }
  obtain ⟨n, sh, hI, hr⟩ := launch_bound C hT.tiles fuse garbage
    (fun G sh => Mem C V M N K (envOf V M N K X W S B ax aw as ab initial) (Wr M (8 * G) 0 0) sh)
    h0 (fun bx byy bz hx hy hz sh hI => by
      obtain rfl : bx = 0 := by omega
      obtain rfl : bz = 0 := by omega
      have hI' : Mem C V M N K (envOf V M N K X W S B ax aw as ab initial) (Wr M (8 * byy) 0 0) sh := by simpa using hI
      rw [Launch.resetGroup_none _ _ _ _ hT.groupArrays]
      obtain ⟨f, r, b, sh', hr, hM'⟩ := group_run hP hQ hV hS hD hT fuse byy hy sh hI'
      exact ⟨f, r, b, sh', hr, by simpa using hM'⟩)
  have hN : 8 * (1 * (N / 8) * 1) = N := by have := hD.n8; omega
  rw [hN] at hI
  exact ⟨n, sh, hI, hr⟩

end Launch

/-- **The GPU runs the affine rows kernel as specified**, at any bit width whose `pOff` and `qfill` meet their
specifications, for any text that compiles to the common core at `(M, N, K)`. -/
theorem gpu_output_of (C : M1Max.Contract) (V : Variant) (hP : PSpec C V) (hQ : QSpec C V) (hV : V.Ok) {M N K : Nat}
    (hD : Dims M N K) (G : Gpu C) (text : List Char) (hc : compile text = some (coreG V M N K))
    (hmax : 64 ≤ G.maxThreads text) (X W S B : ByteMemory.Bytes) (ax aw as ab : Nat) (hax : 8 ∣ ax)
    (haw : V.wAlign ∣ aw) (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute text (64, N / 8, 1) (64, 1, 1) (inputsOf V M N K X W S B ax aw as ab) [2 * (M * N)] =
      some [expected C V M N K X W S B] := by
  have h := gpu_owned C G (grid := (64, N / 8, 1)) (tg := (64, 1, 1))
    (inputs := inputsOf V M N K X W S B ax aw as ab) (sizes := [2 * (M * N)])
    (fun _ => expected C V M N K X W S B) hc (by simpa using hmax) (fun initial garbage => by
      obtain ⟨n, sh, hM, hr⟩ := launch_inv (C := C) (initial := initial) (X := X) (W := W) (S := S) (B := B) hP hQ hV hD
        (Nat.mod_eq_zero_of_dvd hax) (Nat.mod_eq_zero_of_dvd haw) (Nat.mod_eq_zero_of_dvd has) (Nat.mod_eq_zero_of_dvd hab)
        (G.fusion text) garbage
      refine ⟨n, n, n, sh, dev N, tgo, hr, hM.log, ?_⟩
      intro i hi b hb
      obtain rfl : i = 0 := by simp at hi; omega
      have hb' : b < 2 * (M * N) := by simpa using hb
      show sh.bytes 4 b = expected C V M N K X W S B b
      have hN0 := hD.n0
      have hdm := Nat.div_add_mod (b / 2) N
      have hlt : b / 2 / N < M := by
        rw [Nat.div_lt_iff_lt_mul hN0]; omega
      obtain ⟨-, -, hy⟩ := hM.y (b / 2 / N) (b / 2 % N) ⟨hlt, .inl (Nat.mod_lt _ hN0)⟩
      have := hy (b % 2) (by omega)
      rw [show 2 * (b / 2 / N * N + b / 2 % N) + b % 2 = b by rw [Nat.mul_comm (b / 2 / N) N]; omega] at this
      rw [this]
      unfold expected
      rw [ite_eq_left hb']
      rfl)
  rw [h]
  show some [fun b => if b < 2 * (M * N) then expected C V M N K X W S B b else 0] = _
  congr 2
  funext b
  unfold expected
  by_cases hb : b < 2 * (M * N)
  · rw [ite_eq_left hb, ite_eq_left hb]
  · rw [ite_eq_right hb, ite_eq_right hb]
/-! ## The weight decode

Both bit widths fill `q[8c + j]` for `c < 2`, `j < 8` with `as_type<float>(0x4b000000u | ((packed >> (w·j)) & mask)) -
8388608.0f`, `packed` the lane's `c`-th word of codes; they differ in `w`, `mask` and how `packed` is read. -/

section Decode
variable (C : M1Max.Contract)

/-- `as_type<float>(0x4b000000u | f) - 8388608.0f`. -/
def deq (f : Nat) : Float32 := C.fadd (Val.ofF32Bits (0x4B000000 ||| f)) (f32Neg (Val.ofF32Bits 0x4B000000))

def fieldG (w mask : Nat) : CExpr :=
  .bin .sub .f32 0
    (.bitcast .f32 (AffineRows3.u32 .bitOr (u32l 0x4B000000) (AffineRows3.u32 .bitAnd (AffineRows3.u32 .shr (.local 28)
      (AffineRows3.u32 .mul (u32l w) (.local 29))) (u32l mask))))
    (f32l 0x4B000000)

def qStore (w mask : Nat) : CStmt :=
  .store (.scalar .f32) (.offset (.local 26) (AffineRows3.u32 .add (AffineRows3.u32 .mul (u32l 8) (.local 27)) (.local 29)))
    (fieldG w mask)

def qfillG (packedE : CExpr) (w mask : Nat) : List CStmt := forU 27 2 ([.set 28 packedE] ++ forU 29 8 [qStore w mask])

variable {C} {ctx : Ctx}

theorem eval_field {w mask p j : Nat} (hw0 : w < 32) (hw : w * j < 32) (hmask : mask < 2 ^ 32) (hp : p < 2 ^ 32) {l : Locals}
    (h28 : l 28 = some (u32 p)) (h29 : l 29 = some (u32 j)) (sh : Shared) :
    (eval C ctx l (fieldG w mask)).run sh = some (.f32 (deq C ((p >>> (w * j)) &&& mask)), sh) := by
  have hs := eval_u32bin C (eval_local' C (ctx := ctx) h28 sh)
    (eval_u32bin C (eval_u32l C (by omega) sh) (eval_local' C h29 sh) (binary_mul_u32 C w j)) (binary_shr_u32 C p (w * j) hp hw)
  have hlt : p / 2 ^ (w * j) &&& mask < 2 ^ 32 := lt_of_le_of_lt Nat.and_le_right hmask
  have ha := eval_u32bin C hs (eval_u32l C hmask sh) (binary_bitAnd_u32 C _ mask (lt_of_le_of_lt (Nat.div_le_self _ _) hp) hmask)
  have ho := eval_u32bin C (eval_u32l C (by norm_num) sh) ha (binary_bitOr_u32 C 0x4B000000 _ (by norm_num) hlt)
  have hbc := eval_bitcast C (t := .f32) ho (bitcast_f32_u32 _ (Nat.or_lt_two_pow (by norm_num) hlt))
  rw [Nat.shiftRight_eq_div_pow]
  exact eval_f32 C (.inr ⟨rfl, rfl⟩) hbc (eval_lit C _ _ _ _) rfl

/-- `qfill` from a `packed` that reads the codes' word `c` as `P W o c` (bytes of region 1 only). -/
theorem qspec_of {rb off : Nat → Nat} {span wA : Nat} {pOff packedE : CExpr} {w mask : Nat} (hw : 7 * w < 32)
    (hmask : mask < 2 ^ 32) (P : ByteMemory.Bytes → Nat → Nat → Nat) (hP : ∀ W o c, P W o c < 2 ^ 32)
    (hpk : ∀ (ctx : Ctx) (l : Locals) (sh : Shared) (o wsize aw c : Nat), sh.regions 1 = some ⟨.device, wsize, aw⟩ →
      aw % wA = 0 → o % wA = 0 → o + span ≤ wsize → c < 2 → l 25 = some (.ptr ⟨1, ((o : Nat) : Int), .scalar .u8⟩) →
      l 27 = some (u32 c) → ∃ sh', (eval C ctx l packedE).run sh = some (u32 (P (sh.bytes 1) o c), sh') ∧
        Footprint ctx (isR 1) noT sh sh') :
    QSpec C ⟨rb, off, span, wA, pOff, qfillG packedE w mask,
      fun W o e => deq C ((P W o (e / 8) >>> (w * (e % 8))) &&& mask)⟩ := by
  intro ctx l sh o wsize aw qr hr1 haw ho hspan hrq h25 h26
  have hq1 : qr ≠ 1 := by intro h; rw [h, hr1] at hrq; simp at hrq
  obtain ⟨l', sh', hex, hk, hF, hq⟩ := forU_exec C (ctx := ctx) (i := 27) (n := 2)
    (body := [.set 28 packedE] ++ forU 29 8 [qStore w mask]) (by norm_num)
    (fun c l' sh' => (∀ x, x < 27 ∨ 29 < x → l' x = l x) ∧ Footprint ctx (isR 1) (isR qr) sh sh' ∧
      ∀ e < 8 * c, f32At (sh'.bytes qr) e = deq C ((P (sh.bytes 1) o (e / 8) >>> (w * (e % 8))) &&& mask))
    (fun c hc l' sh' ⟨hk, hF, hq⟩ h27 => by
      obtain ⟨sh₁, hev, hF₁⟩ := hpk ctx l' sh' o wsize aw c (by rw [hF.regions]; exact hr1) haw ho hspan hc
        (by rw [hk 25 (.inl (by omega))]; exact h25) h27
      rw [hF.bytes 1 (fun h => hq1 h.symm)] at hev
      have hb₁ : sh₁.bytes = sh'.bytes := hF₁.bytes_eq
      have hr₁ : sh₁.regions = sh.regions := hF₁.regions.trans hF.regions
      generalize hl₁ : setLocal l' 28 (u32 (P (sh.bytes 1) o c)) = l₁
      have k₁ : ∀ x, x ≠ 28 → l₁ x = l' x := fun x hx => by rw [← hl₁, setLocal_other _ _ hx]
      obtain ⟨l₂, sh₂, hin, hk₂, hF₂, hq₂⟩ := forU_exec C (ctx := ctx) (i := 29) (n := 8) (body := [qStore w mask])
        (l := l₁) (by norm_num)
        (fun j l'' sh'' => (∀ x, x ≠ 29 → l'' x = l₁ x) ∧ Footprint ctx (isR 1) (isR qr) sh₁ sh'' ∧
          ∀ e, f32At (sh''.bytes qr) e = if 8 * c ≤ e ∧ e < 8 * c + j then
            deq C ((P (sh.bytes 1) o (e / 8) >>> (w * (e % 8))) &&& mask) else f32At (sh₁.bytes qr) e)
        (fun j hj l'' sh'' ⟨hk'', hF'', hq''⟩ h29 => by
          have hidx := eval_u32bin C (ctx := ctx) (l := l'') (sh := sh'')
            (eval_u32bin C (eval_u32l C (by norm_num) sh'') (eval_local' C (by rw [hk'' 27 (by omega), k₁ 27 (by omega)]; exact h27) sh'')
              (binary_mul_u32 C 8 c)) (eval_local' C h29 sh'') (binary_add_u32 C (8 * c) j)
          have hp := eval_offset_u32 C (o := 0) (eval_local' C (ctx := ctx)
            (by rw [hk'' 26 (by omega), k₁ 26 (by omega), hk 26 (.inl (by omega))]; exact h26) sh'') hidx (by omega)
          rw [show 0 + (8 * c + j) * (Ty.scalar .f32).bytes = 4 * (8 * c + j) by simp [Ty.bytes, Scalar.bytes]; ring] at hp
          have hv := eval_field (C := C) (ctx := ctx) (w := w) (mask := mask) (by omega) (by nlinarith) hmask (hP (sh.bytes 1) o c)
            (by rw [hk'' 28 (by omega), ← hl₁]; exact setLocal_same _ _ _) h29 sh''
          have hst := store_f32_thread ctx sh'' qr 64 (8 * c + j) (deq C ((P (sh.bytes 1) o c >>> (w * j)) &&& mask))
            (by rw [hF''.regions, hr₁]; exact hrq) (by omega)
          refine ⟨l'', _, .store hp hv hst (.nil _ _), h29, fun x hx => by rw [setLocal_other _ _ (by omega)]; exact hk'' x hx,
            hF''.trans (Footprint.wrT _ _ _ _ rfl), fun e => ?_⟩
          rw [wrT_bytes_same, f32At_write, hq'' e]
          by_cases he : e = 8 * c + j
          · subst he
            rw [ite_eq_left rfl, ite_eq_left (by omega), show (8 * c + j) / 8 = c by omega, show (8 * c + j) % 8 = j by omega]
          · rw [ite_eq_right he]
            by_cases hr : 8 * c ≤ e ∧ e < 8 * c + j
            · rw [ite_eq_left hr, ite_eq_left (by omega)]
            · rw [ite_eq_right hr, ite_eq_right (by omega)])
        ⟨fun x hx => by rw [setLocal_other _ _ hx], Footprint.refl _ _ _ _, fun e => by rw [ite_eq_right (by omega)]⟩
      refine ⟨l₂, sh₂, by subst hl₁; exact .set hev hin, by rw [hk₂ 27 (by omega), k₁ 27 (by omega)]; exact h27, fun x hx => ?_,
        hF.trans ((hF₁.mono (fun _ h => h) (fun _ h => h.elim)).trans hF₂), fun e he => ?_⟩
      · rw [setLocal_other _ _ (by omega), hk₂ x (by omega), k₁ x (by omega), hk x hx]
      · rw [hq₂ e]
        by_cases hr : 8 * c ≤ e ∧ e < 8 * c + 8
        · rw [ite_eq_left hr]
        · rw [ite_eq_right hr, hb₁]; exact hq e (by omega))
    ⟨fun x hx => by rw [setLocal_other _ _ (by omega)], Footprint.refl _ _ _ _, fun _ h => absurd h (by omega)⟩
  exact ⟨l', sh', hex, hF, fun x hx => hk x hx, fun e he => hq e (by omega)⟩

end Decode
/-! ## BITS = 3 -/

section Bits3
variable (C : M1Max.Contract)

/-- `packed = uint(p[3c]) | (uint(p[3c + 1]) << 8) | (uint(p[3c + 2]) << 16)`, `p` the lane's weight bytes at `o`. -/
def packed3 (W : ByteMemory.Bytes) (o c : Nat) : Nat :=
  byteAt W (o + 3 * c) ||| (byteAt W (o + 3 * c + 1) <<< 8) ||| (byteAt W (o + 3 * c + 2) <<< 16)

/-- `q[8c + j] = as_type<float>(0x4b000000u | ((packed >> (3j)) & 7u)) - 8388608.0f`. -/
def q3 (W : ByteMemory.Bytes) (o e : Nat) : Float32 := deq C ((packed3 W o (e / 8) >>> (3 * (e % 8))) &&& 7)

/-- affine3-rows.ts: rows of `K · 3/8` bytes, the lane's 16 weights in the 6 bytes at `k0 · 3/8`, read bytewise. -/
def pOff3 : CExpr := AffineRows3.u64 .div (AffineRows3.u64 .mul (toU64 (.local 14)) (u64l 3)) (u64l 8)

def v3 : Variant := ⟨fun K => K * 3 / 8, fun k0 => k0 * 3 / 8, 6, 1, pOff3, qfillG AffineRows3.packed 3 7, q3 C⟩

theorem packed3_lt (W : ByteMemory.Bytes) (o c : Nat) : packed3 W o c < 2 ^ 32 := by
  unfold packed3 byteAt
  have h0 : (W (o + 3 * c)).toNat < 256 := (W _).isLt
  have h1 : (W (o + 3 * c + 1)).toNat < 256 := (W _).isLt
  have h2 : (W (o + 3 * c + 2)).toNat < 256 := (W _).isLt
  rw [Nat.shiftLeft_eq, Nat.shiftLeft_eq]
  exact Nat.or_lt_two_pow (Nat.or_lt_two_pow (by omega) (by omega)) (by omega)

variable {C}

/-- `uint(p[3c + k])`. -/
theorem eval_byte {ctx : Ctx} {k : Nat} (hk : k < 3) {l : Locals} {sh : Shared} {o wsize aw c : Nat}
    (hr1 : sh.regions 1 = some ⟨.device, wsize, aw⟩) (hb : o + 6 ≤ wsize) (hc : c < 2)
    (h25 : l 25 = some (.ptr ⟨1, ((o : Nat) : Int), .scalar .u8⟩)) (h27 : l 27 = some (u32 c)) :
    (eval C ctx l (AffineRows3.byte k)).run sh =
      some (u32 (byteAt (sh.bytes 1) (o + 3 * c + k)), rdn ctx sh 1 (o + 3 * c + k) 1) := by
  have h3c : (eval C ctx l (AffineRows3.u32 .mul (u32l 3) (.local 27))).run sh = some (u32 (3 * c), sh) :=
    eval_u32bin C (eval_u32l C (by norm_num) sh) (eval_local' C h27 sh) (binary_mul_u32 C 3 c)
  have hidx : (eval C ctx l (if k = 0 then AffineRows3.u32 .mul (u32l 3) (.local 27)
      else AffineRows3.u32 .add (AffineRows3.u32 .mul (u32l 3) (.local 27)) (u32l k))).run sh = some (u32 (3 * c + k), sh) := by
    split
    · subst_vars; exact h3c
    · exact eval_u32bin C h3c (eval_u32l C (by omega) sh) (binary_add_u32 C (3 * c) k)
  have hp := eval_offset_u32 C (eval_local' C h25 sh) hidx (by omega)
  rw [show o + (3 * c + k) * (Ty.scalar .u8).bytes = o + 3 * c + k by simp [Ty.bytes, Scalar.bytes]; ring] at hp
  have hld := load_u8 ctx sh 1 wsize aw (o + 3 * c + k) hr1 (by omega)
  exact eval_conv C ((eval_load C _ _ _ _ _ _ _ hp).trans hld) (convert_u32_u8 C (sh.bytes 1 _).isLt)

theorem packed3_spec : ∀ (ctx : Ctx) (l : Locals) (sh : Shared) (o wsize aw c : Nat),
    sh.regions 1 = some ⟨.device, wsize, aw⟩ → aw % 1 = 0 → o % 1 = 0 → o + 6 ≤ wsize → c < 2 →
    l 25 = some (.ptr ⟨1, ((o : Nat) : Int), .scalar .u8⟩) → l 27 = some (u32 c) →
    ∃ sh', (eval C ctx l AffineRows3.packed).run sh = some (u32 (packed3 (sh.bytes 1) o c), sh') ∧
      Footprint ctx (isR 1) noT sh sh' := by
  intro ctx l sh o wsize aw c hr1 _ _ hb hc h25 h27
  have b0 := eval_byte (C := C) (ctx := ctx) (k := 0) (by norm_num) hr1 hb hc h25 h27
  have b1 := eval_byte (C := C) (ctx := ctx) (k := 1) (sh := rdn ctx sh 1 (o + 3 * c + 0) 1) (by norm_num) hr1 hb hc h25 h27
  have b2 := eval_byte (C := C) (ctx := ctx) (k := 2) (sh := rdn ctx (rdn ctx sh 1 (o + 3 * c + 0) 1) 1 (o + 3 * c + 1) 1)
    (by norm_num) hr1 hb hc h25 h27
  generalize hx0 : byteAt (sh.bytes 1) (o + 3 * c + 0) = x0 at b0
  have hx0l : x0 < 256 := by rw [← hx0]; exact (sh.bytes 1 _).isLt
  generalize hx1 : byteAt ((rdn ctx sh 1 (o + 3 * c + 0) 1).bytes 1) (o + 3 * c + 1) = x1 at b1
  have hx1l : x1 < 256 := by rw [← hx1]; exact (sh.bytes 1 _).isLt
  generalize hx2 : byteAt ((rdn ctx (rdn ctx sh 1 (o + 3 * c + 0) 1) 1 (o + 3 * c + 1) 1).bytes 1) (o + 3 * c + 2) = x2 at b2
  have hx2l : x2 < 256 := by rw [← hx2]; exact (sh.bytes 1 _).isLt
  have s1 := eval_int C (s := .u32) (site := 0) (b := u32l 8) (by decide) b1 (eval_u32l C (by norm_num) _)
    (binary_shl_u32 C x1 8 (by norm_num))
  have o1 := eval_int C (s := .u32) (site := 0) (op := .bitOr) (by decide) b0 s1
    (binary_bitOr_u32 C x0 (x1 * 2 ^ 8) (by omega) (by omega))
  have s2 := eval_int C (s := .u32) (site := 0) (b := u32l 16) (by decide) b2 (eval_u32l C (by norm_num) _)
    (binary_shl_u32 C x2 16 (by norm_num))
  have o2 := eval_int C (s := .u32) (site := 0) (op := .bitOr) (by decide) o1 s2
    (binary_bitOr_u32 C (x0 ||| x1 * 2 ^ 8) (x2 * 2 ^ 16) (Nat.or_lt_two_pow (by omega) (by omega)) (by omega))
  have hv : u32 ((x0 ||| x1 * 2 ^ 8) ||| x2 * 2 ^ 16) = u32 (packed3 (sh.bytes 1) o c) := by
    rw [← hx0, ← hx1, ← hx2]
    unfold packed3
    rw [Nat.shiftLeft_eq, Nat.shiftLeft_eq, Nat.add_zero]
    rfl
  rw [hv] at o2
  refine ⟨_, o2, ?_⟩
  · exact ((Footprint.rdn noT sh _ 1 (show isR 1 1 from rfl)).trans
      (Footprint.rdn noT _ _ 1 (show isR 1 1 from rfl))).trans (Footprint.rdn noT _ _ 1 (show isR 1 1 from rfl))

variable (C)

theorem p3_spec : PSpec C (v3 C) := by
  intro ctx l sh k0 h14 hk0
  show (eval C ctx l pOff3).run sh = some (u64 (k0 * 3 / 8), sh)
  exact eval_u64bin C (eval_u64bin C (eval_toU64 C (eval_local' C h14 sh) (by omega)) (eval_u64l C (by norm_num) sh)
    (binary_mul_u64 C k0 3)) (eval_u64l C (by norm_num) sh) (binary_div_u64 C (by omega) (by norm_num) (by norm_num))

theorem q3_spec : QSpec C (v3 C) :=
  qspec_of (C := C) (rb := fun K => K * 3 / 8) (off := fun k0 => k0 * 3 / 8) (span := 6) (wA := 1)
    (pOff := pOff3) (packedE := AffineRows3.packed) (w := 3) (mask := 7) (by norm_num) (by norm_num)
    packed3 packed3_lt packed3_spec

theorem v3_ok : (v3 C).Ok where
  bound K k0 hK hk h := by show k0 * 3 / 8 + 6 ≤ K * 3 / 8; omega
  align K k0 n _ _ := Nat.mod_one _
  rb K hK := by show K * 3 / 8 < 2 ^ 31; omega

end Bits3

end Metal.Kernels.AffineRows

namespace Metal.Kernels.AffineRows3
open Metal Metal.Core Inference.Contracts.Mlx

theorem core_eq (C : M1Max.Contract) (M N K : Nat) : core M N K = AffineRows.coreG (AffineRows.v3 C) M N K := rfl

/-- Byte `b` of `y` [M, N] bf16: element `(b / 2) / N, (b / 2) % N` is `AffineRows.yv`, through `acc` over the K/512
steps with the weights `q3` (`packed3`, `deq`), `xf`, `xsum` and `dot`. -/
def expected (C : M1Max.Contract) (M N K : Nat) (X W S B : ByteMemory.Bytes) : Nat → BitVec 8 :=
  AffineRows.expected C (AffineRows.v3 C) M N K X W S B

/-- **The GPU runs `mlx_bun_affine3_rows` as specified**, for any M rows, N a multiple of 8 and K of 512 (each below
2^31), for any text that elaborates to `core M N K`. `x` must be 8-aligned: the kernel reads it as `vec<bfloat, 4>`. -/
theorem gpu_output_of (C : M1Max.Contract) (G : Gpu C) {M N K : Nat} (hD : AffineRows.Dims M N K) (text : List Char)
    (hc : (frontend text).bind elaborate = some (core M N K)) (hmax : 64 ≤ G.maxThreads text)
    (X W S B : ByteMemory.Bytes) (ax aw as ab : Nat) (hax : 8 ∣ ax) (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute text (64, N / 8, 1) (64, 1, 1)
      [⟨.device, 2 * (M * K), ax, X⟩, ⟨.device, 4 * (N * (K * 3 / 32)), aw, W⟩, ⟨.device, 2 * (N * (K / 64)), as, S⟩,
       ⟨.device, 2 * (N * (K / 64)), ab, B⟩] [2 * (M * N)] =
      some [expected C M N K X W S B] := by
  have hw : 4 * (N * (K * 3 / 32)) = N * (K * 3 / 8) := by
    have := hD.k512; rw [show K * 3 / 8 = 4 * (K * 3 / 32) by omega]; ring
  rw [hw]
  rw [core_eq C] at hc
  exact AffineRows.gpu_output_of C (AffineRows.v3 C) (AffineRows.p3_spec C) (AffineRows.q3_spec C) (AffineRows.v3_ok C) hD G
    text hc hmax X W S B ax aw as ab hax (one_dvd _) has hab

/-! ## The route's instances -/

section Route
variable (C : M1Max.Contract) (G : Gpu C) (X W S B : ByteMemory.Bytes) (ax aw as ab : Nat)

/-- in_proj_qkv: K 5120, N 10240, 2 rows. -/
theorem gpu_output_2_10240_5120 (hmax : 64 ≤ G.maxThreads (text 2 10240 5120)) (hax : 8 ∣ ax) (has : 2 ∣ as)
    (hab : 2 ∣ ab) :
    G.execute (text 2 10240 5120) (64, 1280, 1) (64, 1, 1)
      [⟨.device, 20480, ax, X⟩, ⟨.device, 19660800, aw, W⟩, ⟨.device, 1638400, as, S⟩, ⟨.device, 1638400, ab, B⟩] [40960] =
      some [expected C 2 10240 5120 X W S B] :=
  gpu_output_of C G (by constructor <;> norm_num) _ compile_2_10240_5120 hmax X W S B ax aw as ab hax has hab

/-- in_proj_z: K 5120, N 6144, 2 rows. -/
theorem gpu_output_2_6144_5120 (hmax : 64 ≤ G.maxThreads (text 2 6144 5120)) (hax : 8 ∣ ax) (has : 2 ∣ as)
    (hab : 2 ∣ ab) :
    G.execute (text 2 6144 5120) (64, 768, 1) (64, 1, 1)
      [⟨.device, 20480, ax, X⟩, ⟨.device, 11796480, aw, W⟩, ⟨.device, 983040, as, S⟩, ⟨.device, 983040, ab, B⟩] [24576] =
      some [expected C 2 6144 5120 X W S B] :=
  gpu_output_of C G (by constructor <;> norm_num) _ compile_2_6144_5120 hmax X W S B ax aw as ab hax has hab

/-- out_proj: K 6144, N 5120, 2 rows. -/
theorem gpu_output_2_5120_6144 (hmax : 64 ≤ G.maxThreads (text 2 5120 6144)) (hax : 8 ∣ ax) (has : 2 ∣ as)
    (hab : 2 ∣ ab) :
    G.execute (text 2 5120 6144) (64, 640, 1) (64, 1, 1)
      [⟨.device, 24576, ax, X⟩, ⟨.device, 11796480, aw, W⟩, ⟨.device, 983040, as, S⟩, ⟨.device, 983040, ab, B⟩] [20480] =
      some [expected C 2 5120 6144 X W S B] :=
  gpu_output_of C G (by constructor <;> norm_num) _ compile_2_5120_6144 hmax X W S B ax aw as ab hax has hab

/-- in_proj_qkv: K 5120, N 10240, 3 rows. -/
theorem gpu_output_3_10240_5120 (hmax : 64 ≤ G.maxThreads (text 3 10240 5120)) (hax : 8 ∣ ax) (has : 2 ∣ as)
    (hab : 2 ∣ ab) :
    G.execute (text 3 10240 5120) (64, 1280, 1) (64, 1, 1)
      [⟨.device, 30720, ax, X⟩, ⟨.device, 19660800, aw, W⟩, ⟨.device, 1638400, as, S⟩, ⟨.device, 1638400, ab, B⟩] [61440] =
      some [expected C 3 10240 5120 X W S B] :=
  gpu_output_of C G (by constructor <;> norm_num) _ compile_3_10240_5120 hmax X W S B ax aw as ab hax has hab

/-- in_proj_z: K 5120, N 6144, 3 rows. -/
theorem gpu_output_3_6144_5120 (hmax : 64 ≤ G.maxThreads (text 3 6144 5120)) (hax : 8 ∣ ax) (has : 2 ∣ as)
    (hab : 2 ∣ ab) :
    G.execute (text 3 6144 5120) (64, 768, 1) (64, 1, 1)
      [⟨.device, 30720, ax, X⟩, ⟨.device, 11796480, aw, W⟩, ⟨.device, 983040, as, S⟩, ⟨.device, 983040, ab, B⟩] [36864] =
      some [expected C 3 6144 5120 X W S B] :=
  gpu_output_of C G (by constructor <;> norm_num) _ compile_3_6144_5120 hmax X W S B ax aw as ab hax has hab

/-- out_proj: K 6144, N 5120, 3 rows. -/
theorem gpu_output_3_5120_6144 (hmax : 64 ≤ G.maxThreads (text 3 5120 6144)) (hax : 8 ∣ ax) (has : 2 ∣ as)
    (hab : 2 ∣ ab) :
    G.execute (text 3 5120 6144) (64, 640, 1) (64, 1, 1)
      [⟨.device, 36864, ax, X⟩, ⟨.device, 11796480, aw, W⟩, ⟨.device, 983040, as, S⟩, ⟨.device, 983040, ab, B⟩] [30720] =
      some [expected C 3 5120 6144 X W S B] :=
  gpu_output_of C G (by constructor <;> norm_num) _ compile_3_5120_6144 hmax X W S B ax aw as ab hax has hab

end Route

end Metal.Kernels.AffineRows3

