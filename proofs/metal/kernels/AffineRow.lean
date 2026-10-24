import metal.Logic
import metal.Launch
import metal.tests.Elab
import metal.Gpu
import metal.Steps
import metal.Group
import metal.kernels.GatedRmsNorm
import metal.kernels.ResidualRmsNorm

namespace Metal.Kernels.AffineRow
open Metal Metal.Core Inference.Contracts.Mlx

/-! # affine-row.ts

The header functions are MLX 0.32.2's `load_vector` and `qdot` (quantized.h) at `values_per_thread` 16, bits 3
and 4: `mlxq_load_vector<T, BITS>(x, x_thread)` fills `x_thread` with the 16 values of `x`, scaled for the
packed fields, and returns their sum; `mlxq_qdot<BITS>(w, x_thread, scale, bias, sum)` returns
`scale * accum + sum * bias` over the 16 packed values (the same products and additions in the same order).
At each `BITS` the other branch of each is discarded.

```
constexpr int BPL = 2 * BITS;                   // weight bytes per lane per K step
constexpr int ROWB = K * BITS / 8;
constexpr int GROUPS = K / 64;
const uint sg = simdgroup_index_in_threadgroup, lane = thread_index_in_simdgroup;
// MLX's x_thread for every 16-value chunk of x, and each chunk's sum.
threadgroup float xs[K];
threadgroup float ss[K / 16];
for (int c = (int)(sg * 32 + lane); c < K / 16; c += S * 32) {
  thread float t[16];
  ss[c] = mlxq_load_vector<T, BITS>(x + c * 16, t);
  for (int j = 0; j < 16; j++) xs[c * 16 + j] = t[j];
}
threadgroup_barrier(mem_flags::mem_threadgroup);
const int row0 = (threadgroup_position_in_grid.y * S + sg) * R;
const device uint8_t* ws = (const device uint8_t*)w + row0 * ROWB + lane * BPL;
const device T* sc = scales + row0 * GROUPS + lane / 4;
const device T* bi = biases + row0 * GROUPS + lane / 4;
float result[R] = {0};
#pragma clang loop unroll_count(1)
for (int k = 0; k < K; k += 512) {
  const float sum = ss[(k + lane * 16) / 16];
  const threadgroup float* x_thread = xs + k + lane * 16;
  for (int r = 0; r < R; r++) {
    const float s = sc[r * GROUPS];
    const float b = bi[r * GROUPS];
    result[r] += mlxq_qdot<BITS>(ws + r * ROWB, x_thread, s, b, sum);
  }
  ws += 32 * BPL;
  sc += 8;
  bi += 8;
}
for (int r = 0; r < R; r++) {
  const float v = simd_sum(result[r]);
  if (lane == 0) y[row0 + r] = static_cast<T>(v);
}
```
at `affineConfig K N BITS` with K = 512·steps and N = 64·blocks: grid [32, N/4, 1], threadgroup [32, 16, 1], so
`blocks` threadgroups of 16 SIMD-groups (each SIMD-group four rows), with T = bfloat, R = 4, S = 16. N does not
occur in the body. The elaborated core is `core3 steps` at BITS = 3 and `core4 steps` at BITS = 4: the
elaborator's folded constants are K/16 = 32·steps, K = 512·steps, ROWB = 64·BITS·steps, GROUPS = 8·steps,
BPL = 2·BITS and 32·BPL = 64·BITS. -/

def u32l (n : Nat) : CExpr := .lit (.int .u32 n)
def u16l (n : Nat) : CExpr := .lit (.int .u16 n)
def i32l (n : Nat) : CExpr := .lit (.int .i32 n)
def f32l (bits : Nat) : CExpr := .lit (.f32 (Val.ofF32Bits bits))

/-- `i < n` and `i += n` for the counter in slot `i`. -/
def lt (i n : Nat) : CExpr := .bin .lt .i32 0 (.local i) (i32l n)
def stepBy (i n : Nat) : List CStmt := [.set i (.bin .add .i32 0 (.local i) (i32l n))]

/-! ## `mlxq_load_vector` at BITS = 3 (slots 11 x, 12 x_thread, 13 result, 14 sum, 15 i) -/

/-- `x[i + k]` (`x[i]` for `k = 0`) for the counter in slot `i`. -/
def x0 (i : Nat) : CExpr := .load (.scalar .bf16) (.offset (.local 11) (.local i))
def xAt (i k : Nat) : CExpr := .load (.scalar .bf16) (.offset (.local 11) (.bin .add .i32 0 (.local i) (i32l k)))
/-- `sum += x[i] + x[i + 1] + … + x[i + 7]`, added as bfloats. -/
def chunkSum : CExpr :=
  .conv .f32
    (.bin .add .bf16 0
      (.bin .add .bf16 0
        (.bin .add .bf16 0
          (.bin .add .bf16 0
            (.bin .add .bf16 0 (.bin .add .bf16 0 (.bin .add .bf16 0 (x0 15) (xAt 15 1)) (xAt 15 2)) (xAt 15 3))
            (xAt 15 4))
          (xAt 15 5))
        (xAt 15 6))
      (xAt 15 7))
/-- `x_thread[i + k] = x[i + k] / d`, with the division folded to the multiplication `scale` bits. -/
def scaleStore (i k scale : Nat) : CStmt :=
  .store (.scalar .f32) (.offset (.local 12) (.bin .add .i32 0 (.local i) (i32l k)))
    (.conv .f32 (.bin .mul .f32 0 (.conv .f32 (xAt i k)) (f32l scale)))
def loadVecBody : List CStmt :=
  [.set 14 (.bin .add .f32 0 (.local 14) chunkSum),
   .store (.scalar .f32) (.offset (.local 12) (.local 15)) (.conv .f32 (x0 15)),
   scaleStore 15 1 0x3E000000, scaleStore 15 2 0x3C800000, scaleStore 15 3 0x3F000000, scaleStore 15 4 0x3D800000,
   scaleStore 15 5 0x3C000000, scaleStore 15 6 0x3E800000, scaleStore 15 7 0x3D000000]
def loadVecLoop : CStmt := .loop (lt 15 16) (stepBy 15 8) loadVecBody
def loadVecScope : CStmt := .scope [.set 14 (f32l 0x0), .set 15 (i32l 0), loadVecLoop, .set 13 (.local 14), .leave]

/-! ## `mlxq_load_vector` at BITS = 4 (slot 16 i) -/

/-- `sum += x[i] + x[i + 1] + x[i + 2] + x[i + 3]`, added as bfloats. -/
def chunkSum4 : CExpr :=
  .conv .f32 (.bin .add .bf16 0 (.bin .add .bf16 0 (.bin .add .bf16 0 (x0 16) (xAt 16 1)) (xAt 16 2)) (xAt 16 3))
def loadVecBody4 : List CStmt :=
  [.set 14 (.bin .add .f32 0 (.local 14) chunkSum4),
   .store (.scalar .f32) (.offset (.local 12) (.local 16)) (.conv .f32 (x0 16)),
   scaleStore 16 1 0x3D800000, scaleStore 16 2 0x3B800000, scaleStore 16 3 0x39800000]
def loadVecLoop4 : CStmt := .loop (lt 16 16) (stepBy 16 4) loadVecBody4
def loadVecScope4 : CStmt := .scope [.set 14 (f32l 0x0), .set 16 (i32l 0), loadVecLoop4, .set 13 (.local 14), .leave]

/-! ## The chunk loop -/

def copyLoop : CStmt :=
  .loop (lt 17 16) (stepBy 17 1)
    [.store (.scalar .f32) (.offset (.local 7) (.bin .add .i32 0 (.bin .mul .i32 0 (.local 9) (i32l 16)) (.local 17)))
      (.load (.scalar .f32) (.offset (.local 10) (.local 17)))]

/-- One 16-value chunk `c` (slot 9): `x_thread` into `t` (slot 10) by `load_vector` `lv`, its sum into `ss[c]`,
`t` into `xs`. -/
def chunkBody (lv : CStmt) : List CStmt :=
  [.array 10 false 0 (.scalar .f32),
   .set 11 (.offset (.local 0) (.bin .mul .i32 0 (.local 9) (i32l 16))),
   .set 12 (.local 10),
   lv,
   .store (.scalar .f32) (.offset (.local 8) (.local 9)) (.local 13),
   .set 17 (i32l 0),
   copyLoop]
def chunkLoop (steps : Nat) (lv : CStmt) : CStmt := .loop (lt 9 (32 * steps)) (stepBy 9 512) (chunkBody lv)

/-! ## `mlxq_qdot` at BITS = 3 (slots 29 w, 30 x_thread, 31 scale, 32 bias, 33 sum, 34 result, 35 accum, 36 i) -/

/-- `MLXQ_F(e & mask)`: the masked field `q` in the mantissa of 2^23, minus 2^23. -/
def mlxqF (e : CExpr) (mask : Nat) : CExpr :=
  .bin .sub .f32 0
    (.bitcast .f32 (.bin .bitOr .u32 0 (.conv .u32 (.bin .bitAnd .i32 0 e (i32l mask))) (u32l 1258291200)))
    (f32l 0x4B000000)
/-- `w[b]` as an `int`, and `x_thread[k]`, and `x_thread[k] * 256.0f`. -/
def wByte (b : Nat) : CExpr := .conv .i32 (.load (.scalar .u8) (.offset (.local 29) (i32l b)))
def xThread (k : Nat) : CExpr := .load (.scalar .f32) (.offset (.local 30) (i32l k))
def xThread256 (k : Nat) : CExpr := .bin .mul .f32 0 (xThread k) (f32l 0x43800000)
/-- `accum += MLXQ_F(w[b] & mask) * x`, at contraction site `site`. -/
def term (site b mask : Nat) (x : CExpr) : CStmt :=
  .set 35 (.bin .add .f32 site (.local 35) (.bin .mul .f32 0 (mlxqF (wByte b) mask) x))
def qdotBody : List CStmt :=
  [.set 30 (.offset (.local 30) (.bin .mul .i32 0 (i32l 8) (.local 36))),
   .set 29 (.offset (.local 29) (.bin .mul .i32 0 (i32l 3) (.local 36))),
   term 2 0 7 (xThread 0), term 3 0 56 (xThread 1), term 4 0 192 (xThread 2),
   term 5 1 1 (xThread256 2), term 6 1 14 (xThread 3), term 7 1 112 (xThread 4), term 8 1 128 (xThread 5),
   term 9 2 3 (xThread256 5), term 10 2 28 (xThread 6), term 11 2 224 (xThread 7)]
def qdotLoop : CStmt := .loop (lt 36 2) (stepBy 36 1) qdotBody
/-- `scale * accum + sum * bias`. -/
def qdotResult : CStmt :=
  .set 34 (.bin .add .f32 15 (.bin .mul .f32 0 (.local 31) (.local 35)) (.bin .mul .f32 0 (.local 33) (.local 32)))
def qdotScope : CStmt := .scope [.set 35 (f32l 0x0), .set 36 (i32l 0), qdotLoop, qdotResult, .leave]

/-! ## `mlxq_qdot` at BITS = 4 (slots 37 ws, 38 i) -/

/-- `ws[i]` as an `int`, and `x_thread[4 * i + k] * MLXQ_F(ws[i] & mask)`. -/
def wHalf : CExpr := .conv .i32 (.load (.scalar .u16) (.offset (.local 37) (.local 38)))
def xQuad0 : CExpr := .load (.scalar .f32) (.offset (.local 30) (.bin .mul .i32 0 (i32l 4) (.local 38)))
def xQuad (k : Nat) : CExpr :=
  .load (.scalar .f32) (.offset (.local 30) (.bin .add .i32 0 (.bin .mul .i32 0 (i32l 4) (.local 38)) (i32l k)))
def prod4 (x : CExpr) (mask : Nat) : CExpr := .bin .mul .f32 0 x (mlxqF wHalf mask)
/-- `accum += (p0 + p1 + p2 + p3)`, the inner additions at contraction sites 12, 13, 14. -/
def qdotBody4 : List CStmt :=
  [.set 35 (.bin .add .f32 0 (.local 35)
    (.bin .add .f32 14 (.bin .add .f32 13 (.bin .add .f32 12 (prod4 xQuad0 15) (prod4 (xQuad 1) 240))
      (prod4 (xQuad 2) 3840)) (prod4 (xQuad 3) 61440)))]
def qdotLoop4 : CStmt := .loop (lt 38 4) (stepBy 38 1) qdotBody4
def qdotScope4 : CStmt :=
  .scope [.set 35 (f32l 0x0), .set 37 (.ptrCast (.scalar .u16) (.local 29)), .set 38 (i32l 0), qdotLoop4, qdotResult,
    .leave]

/-! ## The K loop and the output -/

/-- `s = float(sc[r * GROUPS])`, `b = float(bi[r * GROUPS])`, then `result[r] += qdot(…)` by `qd`. -/
def rowBody (bits steps : Nat) (qd : CStmt) : List CStmt :=
  [.set 27 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 20) (.bin .mul .i32 0 (.local 26) (i32l (8 * steps)))))),
   .set 28 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 21) (.bin .mul .i32 0 (.local 26) (i32l (8 * steps)))))),
   .set 29 (.offset (.local 19) (.bin .mul .i32 0 (.local 26) (i32l (64 * bits * steps)))),
   .set 30 (.local 25),
   .set 31 (.local 27),
   .set 32 (.local 28),
   .set 33 (.local 24),
   qd,
   .store (.scalar .f32) (.offset (.local 22) (.local 26))
     (.bin .add .f32 0 (.load (.scalar .f32) (.offset (.local 22) (.local 26))) (.local 34))]
def rowLoop (bits steps : Nat) (qd : CStmt) : CStmt := .loop (lt 26 4) (stepBy 26 1) (rowBody bits steps qd)

/-- One K step `k` (slot 23): `sum = ss[…]`, `x_thread = xs + k + lane * 16`, the four rows, then advance
`ws`, `sc`, `bi`. -/
def stepBody (bits steps : Nat) (qd : CStmt) : List CStmt :=
  [.set 24
     (.load (.scalar .f32)
       (.offset (.local 8)
         (.bin .div .u32 0 (.bin .add .u32 0 (.conv .u32 (.local 23)) (.bin .mul .u32 0 (.local 6) (u32l 16))) (u32l 16)))),
   .set 25 (.offset (.offset (.local 7) (.local 23)) (.bin .mul .u32 0 (.local 6) (u32l 16))),
   .set 26 (i32l 0),
   rowLoop bits steps qd,
   .set 19 (.offset (.local 19) (i32l (64 * bits))),
   .set 20 (.offset (.local 20) (i32l 8)),
   .set 21 (.offset (.local 21) (i32l 8))]
def stepLoop (bits steps : Nat) (qd : CStmt) : CStmt := .loop (lt 23 (512 * steps)) (stepBy 23 512) (stepBody bits steps qd)

def outBody : List CStmt :=
  [.collective 16 40 .sum .f32 (.load (.scalar .f32) (.offset (.local 22) (.local 39))) (u16l 0),
   .set 41 (.local 40),
   .ite (.bin .eq .u32 0 (.local 6) (u32l 0))
     [.store (.scalar .bf16) (.offset (.local 4) (.bin .add .i32 0 (.local 18) (.local 39))) (.conv .bf16 (.local 41))] []]
def outLoop : CStmt := .loop (lt 39 4) (stepBy 39 1) outBody

def row0Expr : CExpr :=
  .conv .i32
    (.bin .mul .u32 0
      (.bin .add .u32 0 (.bin .mul .u32 0 (.component (.coord .threadgroupPositionInGrid) (u32l 1)) (u32l 16)) (.local 5))
      (u32l 4))

/-- Slots: 0 x, 1 w, 2 scales, 3 biases, 4 y, 5 sg, 6 lane, 7 xs (threadgroup array 0), 8 ss (threadgroup array 1),
9 c, 10 t (thread array 0), 11 … 16 `load_vector`'s `x x_thread result sum i i` (15 its `bits == 3` counter, 16
its `bits == 4` counter), 17 j, 18 row0, 19 ws, 20 sc, 21 bi, 22 result (thread array 1), 23 k, 24 sum,
25 x_thread, 26 r, 27 s, 28 b, 29 … 38 `qdot`'s `w x_thread scale bias sum result accum i ws i` (36 its `bits == 3`
counter, 37 and 38 its `bits == 4` pointer and counter), 39 r, 40 the `simd_sum` result, 41 v. `lv` and `qd` are
the inlined `load_vector` and `qdot`. -/
def body (bits steps : Nat) (lv qd : CStmt) : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .bf16⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .u32⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .bf16⟩)),
   .set 3 (.lit (.ptr ⟨3, 0, .scalar .bf16⟩)),
   .set 4 (.lit (.ptr ⟨4, 0, .scalar .bf16⟩)),
   .set 5 (.coord .simdgroupIndexInThreadgroup),
   .set 6 (.coord .threadIndexInSimdgroup),
   .array 7 true 0 (.scalar .f32),
   .array 8 true 1 (.scalar .f32),
   .set 9 (.conv .i32 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 5) (u32l 32)) (.local 6))),
   chunkLoop steps lv,
   .barrier 1 false true,
   .set 18 row0Expr,
   .set 19
     (.offset (.offset (.ptrCast (.scalar .u8) (.local 1)) (.bin .mul .i32 0 (.local 18) (i32l (64 * bits * steps))))
       (.bin .mul .u32 0 (.local 6) (u32l (2 * bits)))),
   .set 20 (.offset (.offset (.local 2) (.bin .mul .i32 0 (.local 18) (i32l (8 * steps)))) (.bin .div .u32 0 (.local 6) (u32l 4))),
   .set 21 (.offset (.offset (.local 3) (.bin .mul .i32 0 (.local 18) (i32l (8 * steps)))) (.bin .div .u32 0 (.local 6) (u32l 4))),
   .array 22 false 1 (.scalar .f32),
   .store (.scalar .f32) (.offset (.local 22) (i32l 0)) (f32l 0x0),
   .store (.scalar .f32) (.offset (.local 22) (i32l 1)) (f32l 0x0),
   .store (.scalar .f32) (.offset (.local 22) (i32l 2)) (f32l 0x0),
   .store (.scalar .f32) (.offset (.local 22) (i32l 3)) (f32l 0x0),
   .set 23 (i32l 0),
   stepLoop bits steps qd,
   .set 39 (i32l 0),
   outLoop]

/-- The kernel at `bits`: threadgroup arrays `xs[K]` and `ss[K / 16]`, thread arrays `t[16]` and `result[4]`. -/
def coreOf (bits steps : Nat) (lv qd : CStmt) : Kernel :=
  ⟨5, [(.scalar .f32, 512 * steps), (.scalar .f32, 32 * steps)], [(.scalar .f32, 16), (.scalar .f32, 4)],
    body bits steps lv qd⟩

def core3 (steps : Nat) : Kernel := coreOf 3 steps loadVecScope qdotScope
def core4 (steps : Nat) : Kernel := coreOf 4 steps loadVecScope4 qdotScope4

/-- The core at `affineConfig 5120 10240 3`. -/
def core : Kernel := core3 10

/-! ## The texts MLX compiles

affine-row.ts's launch for K = 512·steps and N = 64·blocks: x [1, 1, K] bf16, w uint32 [N, K·BITS/32], scales and
biases bf16 [N, K/64], y bf16; built as tests/Assemble.lean builds `affineRowText`. -/

def inputs (bits steps blocks : Nat) : List Metal.Assemble.Input :=
  [⟨chars!"x", .bfloat16, [1, 1, steps * 512]⟩, ⟨chars!"w", .uint32, [blocks * 64, steps * 512 * bits / 32]⟩,
    ⟨chars!"scales", .bfloat16, [blocks * 64, steps * 512 / 64]⟩,
    ⟨chars!"biases", .bfloat16, [blocks * 64, steps * 512 / 64]⟩]

def assembled (bits steps blocks : Nat) : Option (List Char) :=
  Metal.Assemble.Tests.launch .affineRow chars!"mlx_bun_affine_row" (inputs bits steps blocks) [chars!"y"]
    (Host.Mlx.affineConfig (steps * 512) (blocks * 64) bits)

def text (bits steps blocks : Nat) : List Char := (assembled bits steps blocks).getD []

theorem text_affineRow : text 3 10 160 = Metal.Elab.Tests.affineRowText := by decide +kernel

/-- The route's instantiations (`Host.Load.Run.Full.Expected.stages` and `head`, the distinct `LinLayout`s of
kind `.affineRow`): in_proj_qkv (K 5120, N 10240), in_proj_z and attention q/k/v-type projections (K 5120,
N 6144), out_proj (K 6144, N 5120), all 3 bits; the 4-bit head (K 5120, N 248320). -/
theorem assembled_route :
    assembled 3 10 160 = some (text 3 10 160) ∧ assembled 3 10 96 = some (text 3 10 96) ∧
    assembled 3 12 80 = some (text 3 12 80) ∧ assembled 4 10 3880 = some (text 4 10 3880) := by
  decide +kernel

-- The elaborated text MLX compiles (tests/Assemble.lean) is `core`.
kernel_rfl compile_eq : (frontend Metal.Elab.Tests.affineRowText).bind elaborate = some core

kernel_rfl compile_3_10_160 : (frontend (text 3 10 160)).bind elaborate = some (core3 10)
kernel_rfl compile_3_10_96 : (frontend (text 3 10 96)).bind elaborate = some (core3 10)
kernel_rfl compile_3_12_80 : (frontend (text 3 12 80)).bind elaborate = some (core3 12)
kernel_rfl compile_4_10_3880 : (frontend (text 4 10 3880)).bind elaborate = some (core4 10)

section Eval
variable (C : M1Max.Contract) {ctx : Ctx} {l : Locals} {sh sh₁ sh₂ : Shared}

/-- A `uint` literal below 2^32. -/
theorem eval_u32l {n : Nat} (h : n < 2 ^ 32) (sh : Shared) : (eval C ctx l (u32l n)).run sh = some (u32 n, sh) := by
  rw [← u32_lit h]; rfl

/-- `i + k` for an `int` counter. -/
theorem eval_addi {slot a k : Nat} (hl : l slot = some (.int .i32 a)) (h : a + k < 2 ^ 31) (sh : Shared) :
    (eval C ctx l (.bin .add .i32 0 (.local slot) (i32l k))).run sh = some (.int .i32 (a + k), sh) :=
  eval_int C (by decide) (eval_local' C hl sh) (eval_lit C _ _ _ _) (binary_add_i32 C a k h)

/-- `i < n` for an `int` counter. -/
theorem eval_lt {slot a n : Nat} (hl : l slot = some (.int .i32 a)) (ha : a < 2 ^ 31) (hn : n < 2 ^ 31) (sh : Shared) :
    (eval C ctx l (lt slot n)).run sh = some (.bool (decide (a < n)), sh) :=
  eval_int C (by decide) (eval_local' C hl sh) (eval_lit C _ _ _ _) (binary_lt_i32 C a n ha hn)

/-- `MLXQ_F(e & mask)` of an `int` below 2^16. -/
theorem eval_mlxqF {e : CExpr} {a mask : Nat} (ha : a < 65536)
    (he : (eval C ctx l e).run sh = some (.int .i32 a, sh₁)) :
    (eval C ctx l (mlxqF e mask)).run sh =
      some (.f32 (C.fadd (Val.ofF32Bits ((a &&& mask) ||| 0x4B000000)) (f32Neg (Val.ofF32Bits 0x4B000000))), sh₁) := by
  have hm : a &&& mask < 65536 := lt_of_le_of_lt Nat.and_le_left ha
  have hand := eval_int (s := .i32) (site := 0) (b := i32l mask) C (by decide) he (eval_lit C _ _ _ _)
    (binary_bitAnd_i32 C a mask)
  have hconv := eval_conv (t := .u32) C hand (convert_u32_i32 C (a &&& mask) (by omega))
  have hor := eval_int (s := .u32) (site := 0) (b := u32l 1258291200) C (by decide) hconv (eval_lit C _ _ _ _)
    (binary_bitOr_u32 C (a &&& mask) 1258291200 (by omega) (by omega))
  have hor' : (a &&& mask) ||| 1258291200 < 2 ^ 32 := Nat.or_lt_two_pow (by omega) (by omega)
  have hbc := eval_bitcast (t := .f32) C hor (bitcast_f32_u32 _ hor')
  exact eval_f32 C (.inr ⟨rfl, rfl⟩) hbc (eval_lit C _ _ _ _) rfl

end Eval

/-! ## `qdot` at BITS = 3 -/

section Qdot3
variable (C : M1Max.Contract)

def zero : Float32 := Val.ofF32Bits 0
/-- `256.0f`. -/
def c256 : Float32 := Val.ofF32Bits 0x43800000
/-- `MLXQ_F(q) = as_type<float>(q | 0x4B000000) - 8388608.0f`. -/
def deq (q : Nat) : Float32 := C.fadd (Val.ofF32Bits (q ||| 0x4B000000)) (f32Neg (Val.ofF32Bits 0x4B000000))

/-- `accum += MLXQ_F(q) * x` at contraction site `site`. -/
def addTerm (fuse : Nat → Bool) (site : Nat) (a : Float32) (q : Nat) (x : Float32) : Float32 :=
  if fuse site then C.fma (deq C q) x a else C.fadd a (C.fmul (deq C q) x)

/-- The ten lines of `qdot`'s bits-3 loop body, in order: contraction site, byte of `w`, mask, index into
`x_thread`, and whether that value is multiplied by 256 first. -/
def lines3 : List (Nat × Nat × Nat × Nat × Bool) :=
  [(2, 0, 0x07, 0, false), (3, 0, 0x38, 1, false), (4, 0, 0xc0, 2, false), (5, 1, 0x01, 2, true),
   (6, 1, 0x0e, 3, false), (7, 1, 0x70, 4, false), (8, 1, 0x80, 5, false), (9, 2, 0x03, 5, true),
   (10, 2, 0x1c, 6, false), (11, 2, 0xe0, 7, false)]

/-- The `x_thread` operand of a line. -/
def xOperand (x : Nat → Float32) (k : Nat) (scaled : Bool) : Float32 := if scaled then C.fmul (x k) c256 else x k

/-- One iteration of `qdot`'s bits-3 loop from `accum = a`: its ten lines on the three bytes of `W` from `o` and the
eight `x_thread` values `x`. -/
def half3 (fuse : Nat → Bool) (W : ByteMemory.Bytes) (o : Nat) (x : Nat → Float32) (a : Float32) : Float32 :=
  lines3.foldl (fun a (site, b, mask, k, scaled) => addTerm C fuse site a (byteAt W (o + b) &&& mask) (xOperand C x k scaled)) a

/-- `mlxq_qdot<3>(w, x_thread, scale, bias, sum)` on the six bytes of `W` from `o` and the sixteen `x_thread`
values `x`: the two iterations, then `scale * accum + sum * bias` (contraction site 15). -/
def qdot3 (fuse : Nat → Bool) (W : ByteMemory.Bytes) (o : Nat) (x : Nat → Float32) (scale bias sum : Float32) : Float32 :=
  let accum := half3 C fuse W (o + 3) (fun k => x (8 + k)) (half3 C fuse W o x zero)
  if fuse 15 then C.fma scale accum (C.fmul sum bias) else C.fadd (C.fmul scale accum) (C.fmul sum bias)

/-- The `x_thread` operand of a line, as the core writes it. -/
def xExpr (k : Nat) (scaled : Bool) : CExpr := if scaled then xThread256 k else xThread k

def lineStmt (ln : Nat × Nat × Nat × Nat × Bool) : CStmt := term ln.1 ln.2.1 ln.2.2.1 (xExpr ln.2.2.2.1 ln.2.2.2.2)

theorem qdotBody_eq : qdotBody =
    [.set 30 (.offset (.local 30) (.bin .mul .i32 0 (i32l 8) (.local 36))),
     .set 29 (.offset (.local 29) (.bin .mul .i32 0 (i32l 3) (.local 36)))] ++ lines3.map lineStmt := rfl

/-- Reads of `w` and `xs`. -/
def qdR (r : Nat) : Prop := r = 1 ∨ r = 5
variable {C} {ctx : Ctx} {sh0 : Shared} {wsize xsize aw : Nat}

/-- One line, `accum += MLXQ_F(w[b] & mask) * x`, with `w` at byte `wo` and `x_thread` at element `xo`. -/
theorem line_exec (hr1 : sh0.regions 1 = some ⟨.device, wsize, aw⟩) (hr5 : sh0.regions 5 = some ⟨.threadgroup, xsize, 4⟩)
    (site b mask k : Nat) (scaled : Bool) (wo xo : Nat) (hb : wo + b + 1 ≤ wsize) (hk : 4 * (xo + k) + 4 ≤ xsize)
    (hb3 : b < 3) (hk8 : k < 8) (x : Nat → Float32) (hx : f32At (sh0.bytes 5) (xo + k) = x k)
    (l : Locals) (sh : Shared) (a : Float32) (hF : Footprint ctx qdR noT sh0 sh)
    (h29 : l 29 = some (.ptr ⟨1, ((wo : Nat) : Int), .scalar .u8⟩))
    (h30 : l 30 = some (.ptr ⟨5, ((4 * xo : Nat) : Int), .scalar .f32⟩)) (h35 : l 35 = some (.f32 a)) :
    ∃ sh', Exec C ctx [term site b mask (xExpr k scaled)] l sh .normal
      (setLocal l 35 (.f32 (addTerm C ctx.fuse site a (byteAt (sh0.bytes 1) (wo + b) &&& mask)
        (xOperand C x k scaled)))) sh' ∧ Footprint ctx qdR noT sh0 sh' := by
  have hreg := hF.regions
  have hby := hF.bytes_eq
  -- `w[b]`
  have hp : (eval C ctx l (.offset (.local 29) (i32l b))).run sh =
      some (.ptr ⟨1, ((wo + b : Nat) : Int), .scalar .u8⟩, sh) := by
    have := eval_ptr_i32 C (eval_local' C h29 sh) (eval_lit C ctx l (.int .i32 b) sh) (by omega)
    rw [show wo + b * (Ty.scalar .u8).bytes = wo + b by simp [Ty.bytes, Scalar.bytes]] at this
    exact this
  have hld := load_u8 ctx sh 1 wsize aw (wo + b) (by rw [hreg]; exact hr1) hb
  rw [hby] at hld
  have hw : (eval C ctx l (wByte b)).run sh =
      some (.int .i32 (byteAt (sh0.bytes 1) (wo + b)), rdn ctx sh 1 (wo + b) 1) :=
    eval_conv C ((eval_load C _ _ _ _ _ _ _ hp).trans hld) (convert_i32_u8 C (BitVec.isLt _))
  have hF₁ : Footprint ctx qdR noT sh0 (rdn ctx sh 1 (wo + b) 1) := hF.trans (Footprint.rdn _ sh _ _ (.inl rfl))
  have hq := eval_mlxqF (mask := mask) C (lt_of_lt_of_le (BitVec.isLt _) (by norm_num)) hw
  -- `x_thread[k]`
  have hxp : (eval C ctx l (.offset (.local 30) (i32l k))).run (rdn ctx sh 1 (wo + b) 1) =
      some (.ptr ⟨5, ((4 * (xo + k) : Nat) : Int), .scalar .f32⟩, rdn ctx sh 1 (wo + b) 1) := by
    have := eval_ptr_i32 C (eval_local' C h30 (rdn ctx sh 1 (wo + b) 1)) (eval_lit C ctx l (.int .i32 k) (rdn ctx sh 1 (wo + b) 1)) (by omega)
    rw [show 4 * xo + k * (Ty.scalar .f32).bytes = 4 * (xo + k) by simp [Ty.bytes, Scalar.bytes]; ring] at this
    exact this
  have hxl := load_f32_group ctx (rdn ctx sh 1 (wo + b) 1) 5 xsize (xo + k) (by rw [hF₁.regions]; exact hr5) hk
  rw [hF₁.bytes_eq] at hxl
  have hF₂ : Footprint ctx qdR noT sh0 (rd4 ctx (rdn ctx sh 1 (wo + b) 1) 5 (4 * (xo + k))) :=
    hF₁.trans (by rw [rd4_eq]; exact Footprint.rdn _ _ _ _ (.inr rfl))
  have hx : (eval C ctx l (xThread k)).run (rdn ctx sh 1 (wo + b) 1) =
      some (.f32 (x k), rd4 ctx (rdn ctx sh 1 (wo + b) 1) 5 (4 * (xo + k))) := by
    rw [← hx]; exact (eval_load C _ _ _ _ _ _ _ hxp).trans hxl
  have hxe : (eval C ctx l (xExpr k scaled)).run (rdn ctx sh 1 (wo + b) 1) =
      some (.f32 (xOperand C x k scaled),
        rd4 ctx (rdn ctx sh 1 (wo + b) 1) 5 (4 * (xo + k))) := by
    cases scaled
    · exact hx
    · exact eval_f32 C (.inl ⟨by decide, by decide⟩) hx (eval_lit C _ _ _ _) rfl
  exact ⟨_, .set (eval_local_add_mul C h35 hq hxe) (.nil _ _), hF₂⟩

/-- The lines `ts` of `qdot`'s loop body in order. -/
theorem lines_exec (hr1 : sh0.regions 1 = some ⟨.device, wsize, aw⟩) (hr5 : sh0.regions 5 = some ⟨.threadgroup, xsize, 4⟩)
    (wo xo : Nat) (hb : wo + 3 ≤ wsize) (hk : 4 * xo + 32 ≤ xsize) (x : Nat → Float32)
    (hx : ∀ k < 8, f32At (sh0.bytes 5) (xo + k) = x k) :
    ∀ (ts : List (Nat × Nat × Nat × Nat × Bool)), (∀ ln ∈ ts, ln.2.1 < 3 ∧ ln.2.2.2.1 < 8) →
    ∀ (l : Locals) (sh : Shared) (a : Float32), Footprint ctx qdR noT sh0 sh →
      l 29 = some (.ptr ⟨1, ((wo : Nat) : Int), .scalar .u8⟩) →
      l 30 = some (.ptr ⟨5, ((4 * xo : Nat) : Int), .scalar .f32⟩) → l 35 = some (.f32 a) →
      ∃ sh', Exec C ctx (ts.map lineStmt) l sh .normal
        (setLocal l 35 (.f32 (ts.foldl (fun a (site, b, mask, k, scaled) =>
          addTerm C ctx.fuse site a (byteAt (sh0.bytes 1) (wo + b) &&& mask) (xOperand C x k scaled)) a))) sh' ∧
        Footprint ctx qdR noT sh0 sh'
  | [], _, l, sh, a, hF, _, _, h35 => ⟨sh, by rw [List.map_nil, List.foldl_nil, setLocal_self h35]; exact .nil _ _, hF⟩
  | ⟨site, b, mask, k, scaled⟩ :: ts, hts, l, sh, a, hF, h29, h30, h35 => by
    have hts0 := hts _ (List.mem_cons_self ..)
    simp only at hts0
    obtain ⟨hb3, hk8⟩ := hts0
    obtain ⟨sh₁, hex, hF₁⟩ := line_exec hr1 hr5 site b mask k scaled wo xo (by omega) (by omega) hb3 hk8 x (hx k hk8) l sh
      a hF h29 h30 h35
    obtain ⟨sh₂, hex', hF₂⟩ := lines_exec hr1 hr5 wo xo hb hk x hx ts (fun ln h => hts ln (List.mem_cons_of_mem _ h))
      _ sh₁ _ hF₁ (by rw [setLocal_other _ _ (by omega)]; exact h29) (by rw [setLocal_other _ _ (by omega)]; exact h30)
      (setLocal_same _ _ _)
    refine ⟨sh₂, ?_, hF₂⟩
    rw [setLocal_setLocal] at hex'
    exact (Exec.append hex hex' : Exec C ctx ([lineStmt (site, b, mask, k, scaled)] ++ ts.map lineStmt) _ _ _ _ _)

/-- One iteration `i` of `qdot`'s bits-3 loop: `x_thread += 8 * i`, `w += 3 * i`, then the ten lines. -/
theorem qdot_iter (hr1 : sh0.regions 1 = some ⟨.device, wsize, aw⟩) (hr5 : sh0.regions 5 = some ⟨.threadgroup, xsize, 4⟩)
    (i : Nat) (hi : i ≤ 1) (p q p' q' : Nat) (hp' : p' = p + 8 * i) (hq' : q' = q + 3 * i) (hb : q' + 3 ≤ wsize)
    (hk : 4 * p' + 32 ≤ xsize) (x : Nat → Float32) (hx : ∀ k < 8, f32At (sh0.bytes 5) (p' + k) = x k)
    (l : Locals) (sh : Shared) (a : Float32) (hF : Footprint ctx qdR noT sh0 sh)
    (h29 : l 29 = some (.ptr ⟨1, ((q : Nat) : Int), .scalar .u8⟩))
    (h30 : l 30 = some (.ptr ⟨5, ((4 * p : Nat) : Int), .scalar .f32⟩))
    (h35 : l 35 = some (.f32 a)) (h36 : l 36 = some (.int .i32 i)) :
    ∃ sh', Exec C ctx qdotBody l sh .normal
      (setLocal (setLocal (setLocal l 30 (.ptr ⟨5, ((4 * p' : Nat) : Int), .scalar .f32⟩)) 29
        (.ptr ⟨1, ((q' : Nat) : Int), .scalar .u8⟩)) 35 (.f32 (half3 C ctx.fuse (sh0.bytes 1) q' x a))) sh' ∧
      Footprint ctx qdR noT sh0 sh' := by
  subst hp' hq'
  have h8 : (eval C ctx l (.bin .mul .i32 0 (i32l 8) (.local 36))).run sh = some (.int .i32 (8 * i), sh) :=
    eval_int C (by decide) (eval_lit C _ _ _ _) (eval_local' C h36 sh) (binary_mul_i32 C 8 i (by omega) (by omega) (by omega))
  have hp30 : (eval C ctx l (.offset (.local 30) (.bin .mul .i32 0 (i32l 8) (.local 36)))).run sh =
      some (.ptr ⟨5, ((4 * (p + 8 * i) : Nat) : Int), .scalar .f32⟩, sh) := by
    have := eval_ptr_i32 C (eval_local' C h30 sh) h8 (by omega)
    rw [show 4 * p + 8 * i * (Ty.scalar .f32).bytes = 4 * (p + 8 * i) by simp [Ty.bytes, Scalar.bytes]; ring] at this
    exact this
  generalize hl₁ : setLocal l 30 (.ptr ⟨5, ((4 * (p + 8 * i) : Nat) : Int), .scalar .f32⟩) = l₁
  have h36₁ : l₁ 36 = some (.int .i32 i) := by rw [← hl₁, setLocal_other _ _ (by omega)]; exact h36
  have h29₁ : l₁ 29 = some (.ptr ⟨1, ((q : Nat) : Int), .scalar .u8⟩) := by rw [← hl₁, setLocal_other _ _ (by omega)]; exact h29
  have h3 : (eval C ctx l₁ (.bin .mul .i32 0 (i32l 3) (.local 36))).run sh = some (.int .i32 (3 * i), sh) :=
    eval_int C (by decide) (eval_lit C _ _ _ _) (eval_local' C h36₁ sh) (binary_mul_i32 C 3 i (by omega) (by omega) (by omega))
  have hp29 : (eval C ctx l₁ (.offset (.local 29) (.bin .mul .i32 0 (i32l 3) (.local 36)))).run sh =
      some (.ptr ⟨1, ((q + 3 * i : Nat) : Int), .scalar .u8⟩, sh) := by
    have := eval_ptr_i32 C (eval_local' C h29₁ sh) h3 (by omega)
    rw [show q + 3 * i * (Ty.scalar .u8).bytes = q + 3 * i by simp [Ty.bytes, Scalar.bytes]] at this
    exact this
  generalize hl₂ : setLocal l₁ 29 (.ptr ⟨1, ((q + 3 * i : Nat) : Int), .scalar .u8⟩) = l₂
  obtain ⟨sh', hex, hF'⟩ := lines_exec hr1 hr5 (q + 3 * i) (p + 8 * i) hb hk x hx lines3 (by decide) l₂ sh a hF
    (by rw [← hl₂]; exact setLocal_same _ _ _) (by rw [← hl₂, setLocal_other _ _ (by omega), ← hl₁]; exact setLocal_same _ _ _)
    (by rw [← hl₂, setLocal_other _ _ (by omega), ← hl₁, setLocal_other _ _ (by omega)]; exact h35)
  refine ⟨sh', ?_, hF'⟩
  rw [qdotBody_eq]
  subst hl₁ hl₂
  exact .set hp30 (.set hp29 hex)

theorem eval_lt_true {ctx : Ctx} {l : Locals} {slot a n : Nat} (hl : l slot = some (.int .i32 a)) (ha : a < n)
    (hn : n < 2 ^ 31) (sh : Shared) : (eval C ctx l (lt slot n)).run sh = some (.bool true, sh) := by
  rw [eval_lt C hl (by omega) hn, decide_eq_true ha]

theorem eval_lt_false {ctx : Ctx} {l : Locals} {slot a n : Nat} (hl : l slot = some (.int .i32 a)) (ha : ¬ a < n)
    (hla : a < 2 ^ 31) (hn : n < 2 ^ 31) (sh : Shared) : (eval C ctx l (lt slot n)).run sh = some (.bool false, sh) := by
  rw [eval_lt C hl hla hn, decide_eq_false ha]

end Qdot3

/-! ## The variant interface

The two bit widths share the kernel's structure; they differ in the inlined `load_vector` and `qdot`, which
are specified by what they compute. -/

/-- A bit width: its inlined `load_vector` `lv` and `qdot` `qd`, the alignment its weight accesses need, the
`x_thread` values `xt X c j` and sum `cs X c` `load_vector` gives for chunk `c` of `x`, and the value of `qdot`
`qv fuse W o x scale bias sum` on the weight bytes of `W` from `o` and `x_thread` values `x`. -/
structure Variant where
  bits : Nat
  wAlign : Nat
  lv : CStmt
  qd : CStmt
  xt : ByteMemory.Bytes → Nat → Nat → Float32
  cs : ByteMemory.Bytes → Nat → Float32
  qv : (Nat → Bool) → ByteMemory.Bytes → Nat → (Nat → Float32) → Float32 → Float32 → Float32 → Float32

/-- `qd` reads `2 · bits` weight bytes from `w + wo` and sixteen `x_thread` values from `xs + xo`, keeps the
slots before 29 and after 38, and leaves its value in slot 34. -/
def QdSpec (C : M1Max.Contract) (V : Variant) : Prop :=
  ∀ (ctx : Ctx) (l : Locals) (sh : Shared) (wo xo wsize xsize aw : Nat) (x : Nat → Float32) (s b sm : Float32),
    sh.regions 1 = some ⟨.device, wsize, aw⟩ → aw % V.wAlign = 0 → wo % V.wAlign = 0 → wo + 2 * V.bits ≤ wsize →
    sh.regions 5 = some ⟨.threadgroup, xsize, 4⟩ → 4 * xo + 64 ≤ xsize →
    (∀ j < 16, f32At (sh.bytes 5) (xo + j) = x j) →
    l 29 = some (.ptr ⟨1, ((wo : Nat) : Int), .scalar .u8⟩) → l 30 = some (.ptr ⟨5, ((4 * xo : Nat) : Int), .scalar .f32⟩) →
    l 31 = some (.f32 s) → l 32 = some (.f32 b) → l 33 = some (.f32 sm) →
    ∃ l' sh', Exec C ctx [V.qd] l sh .normal l' sh' ∧ Footprint ctx qdR noT sh sh' ∧
      (∀ i, i < 29 ∨ 38 < i → l' i = l i) ∧ l' 34 = some (.f32 (V.qv ctx.fuse (sh.bytes 1) wo x s b sm))

section Qdot3Spec
variable (C : M1Max.Contract)

theorem qdot3_spec (lv : CStmt) (xt : ByteMemory.Bytes → Nat → Nat → Float32) (cs : ByteMemory.Bytes → Nat → Float32) :
    QdSpec C ⟨3, 1, lv, qdotScope, xt, cs, qdot3 C⟩ := by
  intro ctx l sh wo xo wsize xsize aw x s b sm hr1 _ _ hw hr5 hx hxv h29 h30 h31 h32 h33
  simp only at hw ⊢
  have hF0 := Footprint.refl ctx qdR noT sh
  -- `accum = 0`, `i = 0`, the test
  generalize hl₁ : setLocal (setLocal l 35 (.f32 zero)) 36 (.int .i32 0) = l₁
  have g36 : l₁ 36 = some (.int .i32 0) := by rw [← hl₁]; exact setLocal_same _ _ _
  have g35 : l₁ 35 = some (.f32 zero) := by rw [← hl₁, setLocal_other _ _ (by omega)]; exact setLocal_same _ _ _
  have g29 : l₁ 29 = some (.ptr ⟨1, ((wo : Nat) : Int), .scalar .u8⟩) := by
    rw [← hl₁, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact h29
  have g30 : l₁ 30 = some (.ptr ⟨5, ((4 * xo : Nat) : Int), .scalar .f32⟩) := by
    rw [← hl₁, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact h30
  -- iteration 0
  obtain ⟨sh₁, hex₁, hF₁⟩ := qdot_iter (C := C) hr1 hr5 0 (by omega) xo wo xo wo (by omega) (by omega) (by omega) (by omega) x
    (fun k hk => hxv k (by omega)) l₁ sh zero hF0 g29 g30 g35 g36
  generalize hl₂ : setLocal (setLocal (setLocal (setLocal l₁ 30 (.ptr ⟨5, ((4 * xo : Nat) : Int), .scalar .f32⟩)) 29
    (.ptr ⟨1, ((wo : Nat) : Int), .scalar .u8⟩)) 35 (.f32 (half3 C ctx.fuse (sh.bytes 1) wo x zero))) 36 (.int .i32 1) = l₂
  have hst₁ : Exec C ctx (stepBy 36 1) (setLocal (setLocal (setLocal l₁ 30 (.ptr ⟨5, ((4 * xo : Nat) : Int), .scalar .f32⟩)) 29
      (.ptr ⟨1, ((wo : Nat) : Int), .scalar .u8⟩)) 35 (.f32 (half3 C ctx.fuse (sh.bytes 1) wo x zero))) sh₁ .normal l₂ sh₁ := by
    rw [← hl₂]
    exact .set (eval_addi C (by simp [setLocal, g36]) (by omega) _) (.nil _ _)
  have g36₂ : l₂ 36 = some (.int .i32 1) := by rw [← hl₂]; exact setLocal_same _ _ _
  have g35₂ : l₂ 35 = some (.f32 (half3 C ctx.fuse (sh.bytes 1) wo x zero)) := by
    rw [← hl₂, setLocal_other _ _ (by omega)]; exact setLocal_same _ _ _
  have g29₂ : l₂ 29 = some (.ptr ⟨1, ((wo : Nat) : Int), .scalar .u8⟩) := by
    rw [← hl₂, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact setLocal_same _ _ _
  have g30₂ : l₂ 30 = some (.ptr ⟨5, ((4 * xo : Nat) : Int), .scalar .f32⟩) := by
    rw [← hl₂, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]
    exact setLocal_same _ _ _
  -- iteration 1
  obtain ⟨sh₂, hex₂, hF₂⟩ := qdot_iter (C := C) hr1 hr5 1 (by omega) xo wo (xo + 8) (wo + 3) (by omega) (by omega) (by omega)
    (by omega) (fun k => x (8 + k)) (fun k hk => by rw [show xo + 8 + k = xo + (8 + k) by omega]; exact hxv _ (by omega))
    l₂ sh₁ _ (hF0.trans hF₁) g29₂ g30₂ g35₂ g36₂
  generalize hacc : half3 C ctx.fuse (sh.bytes 1) (wo + 3) (fun k => x (8 + k)) (half3 C ctx.fuse (sh.bytes 1) wo x zero) =
    accum at hex₂
  generalize hl₃ : setLocal (setLocal (setLocal (setLocal l₂ 30 (.ptr ⟨5, ((4 * (xo + 8) : Nat) : Int), .scalar .f32⟩)) 29
    (.ptr ⟨1, ((wo + 3 : Nat) : Int), .scalar .u8⟩)) 35 (.f32 accum)) 36 (.int .i32 2) = l₃
  have hst₂ : Exec C ctx (stepBy 36 1) (setLocal (setLocal (setLocal l₂ 30 (.ptr ⟨5, ((4 * (xo + 8) : Nat) : Int), .scalar .f32⟩))
      29 (.ptr ⟨1, ((wo + 3 : Nat) : Int), .scalar .u8⟩)) 35 (.f32 accum)) sh₂ .normal l₃ sh₂ := by
    rw [← hl₃]
    exact .set (eval_addi C (by simp [setLocal, g36₂]) (by omega) _) (.nil _ _)
  have g36₃ : l₃ 36 = some (.int .i32 2) := by rw [← hl₃]; exact setLocal_same _ _ _
  have g35₃ : l₃ 35 = some (.f32 accum) := by rw [← hl₃, setLocal_other _ _ (by omega)]; exact setLocal_same _ _ _
  have keep : ∀ j, j ≠ 29 → j ≠ 30 → j ≠ 35 → j ≠ 36 → l₃ j = l j := by
    intro j h1 h2 h3 h4
    rw [← hl₃, ← hl₂, ← hl₁]
    simp only [setLocal]
    simp [h1, h2, h3, h4]
  -- `scale * accum + sum * bias`
  have hres : (eval C ctx l₃ (.bin .add .f32 15 (.bin .mul .f32 0 (.local 31) (.local 35))
      (.bin .mul .f32 0 (.local 33) (.local 32)))).run sh₂ =
      some (.f32 (if ctx.fuse 15 then C.fma s accum (C.fmul sm b) else C.fadd (C.fmul s accum) (C.fmul sm b)), sh₂) :=
    eval_mul_add C (eval_local' C (by rw [keep 31 (by omega) (by omega) (by omega) (by omega)]; exact h31) _) (eval_local' C g35₃ _)
      (eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_local' C (by rw [keep 33 (by omega) (by omega) (by omega) (by omega)]; exact h33) _)
        (eval_local' C (by rw [keep 32 (by omega) (by omega) (by omega) (by omega)]; exact h32) _) rfl)
  have hbody : Exec C ctx [.set 35 (f32l 0x0), .set 36 (i32l 0), qdotLoop, qdotResult, .leave] l sh .leave
      (setLocal l₃ 34 (.f32 (if ctx.fuse 15 then C.fma s accum (C.fmul sm b) else C.fadd (C.fmul s accum) (C.fmul sm b))))
      sh₂ := by
    refine .set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _) ?_)
    subst hl₁
    exact .loop_next (eval_lt_true (C := C) g36 (by omega) (by omega) _) hex₁ (.inl rfl) hst₁
      (.loop_next (eval_lt_true (C := C) g36₂ (by omega) (by omega) _) hex₂ (.inl rfl) hst₂
        (.loop_exit (eval_lt_false (C := C) g36₃ (by omega) (by omega) (by omega) _) (.set hres .leave)))
  refine ⟨_, sh₂, .scope hbody (.inr rfl) (.nil _ _), hF₂, ?_, ?_⟩
  · intro j hj
    rw [setLocal_other _ _ (by omega)]
    exact keep j (by omega) (by omega) (by omega) (by omega)
  · rw [setLocal_same, ← hacc]
    rfl

end Qdot3Spec

/-! ## `qdot` at BITS = 4 -/

section Qdot4
variable (C : M1Max.Contract)

/-- The halfword `ws[i]` of `W` at byte `o`, little-endian. -/
def word16 (W : ByteMemory.Bytes) (o : Nat) : Nat := byteAt W o + 256 * byteAt W (o + 1)

/-- `x * y + z` and `z + x * y` under the compiler's choice at contraction site `site`. -/
def mulAdd (fuse : Nat → Bool) (site : Nat) (x y z : Float32) : Float32 :=
  if fuse site then C.fma x y z else C.fadd (C.fmul x y) z
def addMul (fuse : Nat → Bool) (site : Nat) (z x y : Float32) : Float32 :=
  if fuse site then C.fma x y z else C.fadd z (C.fmul x y)

/-- One iteration of `qdot`'s bits-4 loop from `accum = a`, on the halfword `q` and the four `x_thread` values `x`:
`accum += (x[0] * MLXQ_F(q & 0x000f) + x[1] * MLXQ_F(q & 0x00f0) + x[2] * MLXQ_F(q & 0x0f00) + x[3] * MLXQ_F(q & 0xf000))`,
the three inner additions at contraction sites 12, 13, 14. -/
def quad4 (fuse : Nat → Bool) (q : Nat) (x : Nat → Float32) (a : Float32) : Float32 :=
  C.fadd a (addMul C fuse 14 (addMul C fuse 13 (mulAdd C fuse 12 (x 0) (deq C (q &&& 0x000f))
    (C.fmul (x 1) (deq C (q &&& 0x00f0)))) (x 2) (deq C (q &&& 0x0f00))) (x 3) (deq C (q &&& 0xf000)))

/-- `accum` after the first `i` iterations, on the halfwords of `W` from byte `o` and the `x_thread` values `x`. -/
def accum4 (fuse : Nat → Bool) (W : ByteMemory.Bytes) (o : Nat) (x : Nat → Float32) : Nat → Float32
  | 0 => zero
  | i + 1 => quad4 C fuse (word16 W (o + 2 * i)) (fun k => x (4 * i + k)) (accum4 fuse W o x i)

/-- `mlxq_qdot<4>(w, x_thread, scale, bias, sum)` on the eight bytes of `W` from `o` and the sixteen `x_thread` values
`x`: the four iterations, then `scale * accum + sum * bias` (contraction site 15). -/
def qdot4 (fuse : Nat → Bool) (W : ByteMemory.Bytes) (o : Nat) (x : Nat → Float32) (scale bias sum : Float32) : Float32 :=
  let accum := accum4 C fuse W o x 4
  if fuse 15 then C.fma scale accum (C.fmul sum bias) else C.fadd (C.fmul scale accum) (C.fmul sum bias)

variable {C} {ctx : Ctx} {l : Locals}

variable {sh0 : Shared} {wsize xsize aw : Nat}

/-- `x_thread[4i + k]`. -/
theorem eval_xQuad (hr5 : sh0.regions 5 = some ⟨.threadgroup, xsize, 4⟩) (xo i k : Nat) (hk : 4 * (xo + 4 * i + k) + 4 ≤ xsize)
    (hik : 4 * i + k < 2 ^ 31) (x : Nat → Float32) (hx : f32At (sh0.bytes 5) (xo + 4 * i + k) = x (4 * i + k))
    (h30 : l 30 = some (.ptr ⟨5, ((4 * xo : Nat) : Int), .scalar .f32⟩)) (h38 : l 38 = some (.int .i32 i)) :
    ∀ sh, Footprint ctx qdR noT sh0 sh → ∃ sh', (eval C ctx l (if k = 0 then xQuad0 else xQuad k)).run sh =
      some (.f32 (x (4 * i + k)), sh') ∧ Footprint ctx qdR noT sh0 sh' := by
  intro sh hF
  have hm : (eval C ctx l (.bin .mul .i32 0 (i32l 4) (.local 38))).run sh = some (.int .i32 (4 * i), sh) :=
    eval_int C (by decide) (eval_lit C _ _ _ _) (eval_local' C h38 sh) (binary_mul_i32 C 4 i (by omega) (by omega) (by omega))
  have hl := load_f32_group ctx sh 5 xsize (xo + 4 * i + k) (by rw [hF.regions]; exact hr5) hk
  rw [hF.bytes_eq, hx] at hl
  refine ⟨rd4 ctx sh 5 (4 * (xo + 4 * i + k)), ?_, hF.trans (by rw [rd4_eq]; exact Footprint.rdn _ _ _ _ (.inr rfl))⟩
  by_cases hk0 : k = 0
  · subst hk0
    rw [ite_eq_left rfl]
    have hp := eval_ptr_i32 C (eval_local' C h30 sh) hm (by omega)
    rw [show 4 * xo + 4 * i * (Ty.scalar .f32).bytes = 4 * (xo + 4 * i + 0) by simp [Ty.bytes, Scalar.bytes]; ring] at hp
    exact (eval_load C _ _ (.scalar .f32) _ _ _ _ hp).trans hl
  · rw [ite_eq_right hk0]
    have hp := eval_ptr_i32 C (eval_local' C h30 sh) (eval_int C (s := .i32) (site := 0) (b := i32l k) (by decide) hm
      (eval_lit C _ _ _ _) (binary_add_i32 C (4 * i) k hik)) hik
    rw [show 4 * xo + (4 * i + k) * (Ty.scalar .f32).bytes = 4 * (xo + 4 * i + k) by simp [Ty.bytes, Scalar.bytes]; ring] at hp
    exact (eval_load C _ _ (.scalar .f32) _ _ _ _ hp).trans hl

/-- `MLXQ_F(ws[i] & mask)`. -/
theorem eval_wHalf (hr1 : sh0.regions 1 = some ⟨.device, wsize, aw⟩) (haw : aw % 2 = 0) (wo i mask : Nat)
    (hwo : wo % 2 = 0) (hb : wo + 2 * i + 2 ≤ wsize) (hi : i < 2 ^ 31)
    (h37 : l 37 = some (.ptr ⟨1, ((wo : Nat) : Int), .scalar .u16⟩)) (h38 : l 38 = some (.int .i32 i)) :
    ∀ sh, Footprint ctx qdR noT sh0 sh → ∃ sh', (eval C ctx l (mlxqF wHalf mask)).run sh =
      some (.f32 (deq C (word16 (sh0.bytes 1) (wo + 2 * i) &&& mask)), sh') ∧ Footprint ctx qdR noT sh0 sh' := by
  intro sh hF
  have hp := eval_ptr_i32 C (eval_local' C (ctx := ctx) h37 sh) (eval_local' C h38 sh) hi
  rw [show wo + i * (Ty.scalar .u16).bytes = wo + 2 * i by simp [Ty.bytes, Scalar.bytes]; ring] at hp
  have hl := load_u16 ctx sh 1 wsize aw (wo + 2 * i) (by rw [hF.regions]; exact hr1) haw (by omega) hb
  rw [hF.bytes_eq] at hl
  have hlt : word16 (sh0.bytes 1) (wo + 2 * i) < 65536 := by
    unfold word16 byteAt; have := (sh0.bytes 1 (wo + 2 * i)).isLt; have := (sh0.bytes 1 (wo + 2 * i + 1)).isLt; omega
  have hw : (eval C ctx l wHalf).run sh = some (.int .i32 (word16 (sh0.bytes 1) (wo + 2 * i)), rdn ctx sh 1 (wo + 2 * i) 2) :=
    eval_conv C ((eval_load C _ _ (.scalar .u16) _ _ _ _ hp).trans hl) (convert_i32_u16 C hlt)
  exact ⟨_, eval_mlxqF (mask := mask) C hlt hw, hF.trans (Footprint.rdn _ _ _ _ (.inl rfl))⟩

/-- One iteration `i` of `qdot`'s bits-4 loop. -/
theorem qdot4_iter (hr1 : sh0.regions 1 = some ⟨.device, wsize, aw⟩) (haw : aw % 2 = 0)
    (hr5 : sh0.regions 5 = some ⟨.threadgroup, xsize, 4⟩) (wo xo i : Nat) (hi : i < 4) (hwo : wo % 2 = 0)
    (hb : wo + 8 ≤ wsize) (hk : 4 * xo + 64 ≤ xsize) (x : Nat → Float32) (hx : ∀ j < 16, f32At (sh0.bytes 5) (xo + j) = x j)
    (l : Locals) (sh : Shared) (a : Float32) (hF : Footprint ctx qdR noT sh0 sh)
    (h30 : l 30 = some (.ptr ⟨5, ((4 * xo : Nat) : Int), .scalar .f32⟩))
    (h37 : l 37 = some (.ptr ⟨1, ((wo : Nat) : Int), .scalar .u16⟩)) (h35 : l 35 = some (.f32 a))
    (h38 : l 38 = some (.int .i32 i)) :
    ∃ sh', Exec C ctx qdotBody4 l sh .normal
      (setLocal l 35 (.f32 (quad4 C ctx.fuse (word16 (sh0.bytes 1) (wo + 2 * i)) (fun k => x (4 * i + k)) a))) sh' ∧
      Footprint ctx qdR noT sh0 sh' := by
  have X : ∀ k, k < 4 → ∀ sh, Footprint ctx qdR noT sh0 sh → ∃ sh', (eval C ctx l (if k = 0 then xQuad0 else xQuad k)).run sh =
      some (.f32 (x (4 * i + k)), sh') ∧ Footprint ctx qdR noT sh0 sh' := fun k hk =>
    eval_xQuad hr5 xo i k (by omega) (by omega) x (by rw [Nat.add_assoc]; exact hx _ (by omega)) h30 h38
  have X0 := X 0 (by omega); rw [ite_eq_left rfl] at X0
  have X1 := X 1 (by omega); rw [ite_eq_right (by omega)] at X1
  have X2 := X 2 (by omega); rw [ite_eq_right (by omega)] at X2
  have X3 := X 3 (by omega); rw [ite_eq_right (by omega)] at X3
  have F := fun mask => eval_wHalf (C := C) (ctx := ctx) hr1 haw wo i mask hwo (by omega) (by omega) h37 h38
  obtain ⟨sh', hin, hF'⟩ := eval_add_mul_P rfl _ X3 (F 61440) (eval_add_mul_P rfl _ X2 (F 3840)
    (eval_mul_add_P _ X0 (F 15) (eval_mul_P _ X1 (F 240)))) sh hF
  exact ⟨sh', .set (eval_f32 C (.inr ⟨rfl, rfl⟩) (eval_local' C h35 sh) hin rfl) (.nil _ _), hF'⟩

end Qdot4

theorem qdot4_spec (C : M1Max.Contract) (lv : CStmt) (xt : ByteMemory.Bytes → Nat → Nat → Float32)
    (cs : ByteMemory.Bytes → Nat → Float32) : QdSpec C ⟨4, 2, lv, qdotScope4, xt, cs, qdot4 C⟩ := by
  intro ctx l sh wo xo wsize xsize aw x s b sm hr1 haw hwo hw hr5 hx hxv h29 h30 h31 h32 h33
  simp only at hw haw hwo ⊢
  generalize hlb : setLocal (setLocal (setLocal l 35 (.f32 zero)) 37 (.ptr ⟨1, ((wo : Nat) : Int), .scalar .u16⟩)) 38
    (.int .i32 0) = lb
  -- the loop
  obtain ⟨l', sh', hloop, h35', h38', hk', hF'⟩ := Exec.loop_count (C := C) (ctx := ctx) (c := lt 38 4) (st := stepBy 38 1)
    (b := qdotBody4) 4
    (fun i l sh' => l 35 = some (.f32 (accum4 C ctx.fuse (sh.bytes 1) wo x i)) ∧ l 38 = some (.int .i32 i) ∧
      (∀ j, j ≠ 35 → j ≠ 38 → l j = lb j) ∧ Footprint ctx qdR noT sh sh')
    (fun i l sh' => l 35 = some (.f32 (accum4 C ctx.fuse (sh.bytes 1) wo x i)) ∧ l 38 = some (.int .i32 i) ∧
      (∀ j, j ≠ 35 → j ≠ 38 → l j = lb j) ∧ Footprint ctx qdR noT sh sh')
    (fun i hi l sh' hI => ⟨sh', eval_lt C hI.2.1 (by omega) (by omega) sh', hI⟩)
    (fun i hi l sh' hI => by
      obtain ⟨h35, h38, hk, hF⟩ := hI
      have g30 : l 30 = some (.ptr ⟨5, ((4 * xo : Nat) : Int), .scalar .f32⟩) := by
        rw [hk 30 (by omega) (by omega), ← hlb]; simp [setLocal, h30]
      have g37 : l 37 = some (.ptr ⟨1, ((wo : Nat) : Int), .scalar .u16⟩) := by
        rw [hk 37 (by omega) (by omega), ← hlb]; simp [setLocal]
      obtain ⟨sh'', hb, hF''⟩ := qdot4_iter hr1 (Nat.mod_eq_zero_of_dvd (Nat.dvd_of_mod_eq_zero haw)) hr5 wo xo i hi hwo hw hx x hxv l sh'
        _ hF g30 g37 h35 h38
      exact ⟨.normal, _, sh'', _, sh'', .inl rfl, hb, .set (eval_addi C (k := 1) (by rw [setLocal_other _ _ (by omega)]; exact h38)
        (by omega) _) (.nil _ _), by simp [setLocal]; rfl, by simp [setLocal],
        fun j h1 h2 => by simp [setLocal, h1, h2, hk j h1 h2], hF''⟩)
    (l := lb) (sh := sh)
    ⟨by rw [← hlb]; simp [setLocal]; rfl, by rw [← hlb]; simp [setLocal], fun j _ _ => rfl, Footprint.refl _ _ _ _⟩
  have k' : ∀ j, j ≠ 35 → j ≠ 38 → j ≠ 37 → l' j = l j := fun j h1 h2 h3 => by
    rw [hk' j h1 h2, ← hlb]; simp [setLocal, h1, h2, h3]
  have hres : (eval C ctx l' (.bin .add .f32 15 (.bin .mul .f32 0 (.local 31) (.local 35))
      (.bin .mul .f32 0 (.local 33) (.local 32)))).run sh' =
      some (.f32 (qdot4 C ctx.fuse (sh.bytes 1) wo x s b sm), sh') :=
    eval_mul_add C (eval_local' C (by rw [k' 31 (by omega) (by omega) (by omega)]; exact h31) _) (eval_local' C h35' _)
      (eval_f32 C (.inl ⟨by decide, by decide⟩) (eval_local' C (by rw [k' 33 (by omega) (by omega) (by omega)]; exact h33) _)
        (eval_local' C (by rw [k' 32 (by omega) (by omega) (by omega)]; exact h32) _) rfl)
  have hbody : Exec C ctx [.set 35 (f32l 0x0), .set 37 (.ptrCast (.scalar .u16) (.local 29)), .set 38 (i32l 0), qdotLoop4,
      qdotResult, .leave] l sh .leave (setLocal l' 34 (.f32 (qdot4 C ctx.fuse (sh.bytes 1) wo x s b sm))) sh' := by
    refine .set (eval_lit C _ _ _ _) (.set (eval_ptrCast C (t := .scalar .u16)
      (eval_local' C (by rw [setLocal_other _ _ (by omega)]; exact h29) _)) (.set (eval_lit C _ _ _ _) ?_))
    rw [show (Val.ofF32Bits 0x0) = zero from rfl, hlb]
    exact Exec.append (ss₁ := [qdotLoop4]) hloop (.set hres .leave)
  refine ⟨_, sh', .scope hbody (.inr rfl) (.nil _ _), hF', fun j hj => ?_, setLocal_same _ _ _⟩
  rw [setLocal_other _ _ (by omega)]
  exact k' j (by omega) (by omega) (by omega)


/-! ## `load_vector` -/

/-- `load_vector` reads the chunk of `x` at `x + 16c` and fills `x_thread` (thread memory `tr`), keeps the slots
before 13 and after 16, and leaves the chunk's sum in slot 13. -/
def LvSpec (C : M1Max.Contract) (V : Variant) : Prop :=
  ∀ (ctx : Ctx) (l : Locals) (sh : Shared) (c tr size ax : Nat),
    sh.regions 0 = some ⟨.device, size, ax⟩ → ax % 2 = 0 → 32 * c + 32 ≤ size →
    sh.regions tr = some ⟨.thread, 64, 4⟩ → tr ≠ 0 →
    l 11 = some (.ptr ⟨0, ((32 * c : Nat) : Int), .scalar .bf16⟩) → l 12 = some (.ptr ⟨tr, 0, .scalar .f32⟩) →
    ∃ l' sh', Exec C ctx [V.lv] l sh .normal l' sh' ∧ Footprint ctx (isR 0) (isR tr) sh sh' ∧
      (∀ i, i < 13 ∨ 16 < i → l' i = l i) ∧ l' 13 = some (.f32 (V.cs (sh.bytes 0) c)) ∧
      ∀ j < 16, f32At (sh'.bytes tr) j = V.xt (sh.bytes 0) c j

section LoadVector
variable (C : M1Max.Contract)

/-- `float(x[e])`. -/
def xf (X : ByteMemory.Bytes) (e : Nat) : Float32 := C.widen (bfAt X e)

/-- `x[e] + x[e + k₁] + x[e + k₂] + …`, added as bfloats from the left. -/
def bsum (X : ByteMemory.Bytes) (e : Nat) (ks : List Nat) : BF := ks.foldl (fun s k => C.bfadd s (bfAt X (e + k))) (bfAt X e)

/-- `acc + x[i + k₁] + x[i + k₂] + …` in the core, `i` in `slot`. -/
def bsumE (slot : Nat) (acc : CExpr) : List Nat → CExpr
  | [] => acc
  | k :: ks => bsumE slot (.bin .add .bf16 0 acc (xAt slot k)) ks

theorem chunkSum_eq : chunkSum = .conv .f32 (bsumE 15 (x0 15) [1, 2, 3, 4, 5, 6, 7]) := rfl
theorem chunkSum4_eq : chunkSum4 = .conv .f32 (bsumE 16 (x0 16) [1, 2, 3]) := rfl

variable {C} {ctx : Ctx} {sh0 : Shared} {size ax tr c : Nat}

/-- `x[i + k]`. -/
theorem eval_xAt (hr0 : sh0.regions 0 = some ⟨.device, size, ax⟩) (hax : ax % 2 = 0) (slot i k : Nat)
    (hb : 2 * (16 * c + i + k) + 2 ≤ size) (hik : i + k < 2 ^ 31) (l : Locals) (sh : Shared)
    (hF : Footprint ctx (isR 0) (isR tr) sh0 sh) (htr : tr ≠ 0)
    (h11 : l 11 = some (.ptr ⟨0, ((32 * c : Nat) : Int), .scalar .bf16⟩)) (hs : l slot = some (.int .i32 i)) :
    (eval C ctx l (xAt slot k)).run sh =
      some (.bf16 (bfAt (sh0.bytes 0) (16 * c + i + k)), rd ctx sh 0 (2 * (16 * c + i + k))) := by
  have hp := eval_ptr_i32 C (ctx := ctx) (eval_local' C h11 sh) (eval_addi C hs hik sh) hik
  rw [show 32 * c + (i + k) * (Ty.scalar .bf16).bytes = 2 * (16 * c + i + k) by simp [Ty.bytes, Scalar.bytes]; ring] at hp
  have hl := load_bf16 ctx sh 0 size ax (16 * c + i + k) (by rw [hF.regions]; exact hr0) hax hb
  rw [hF.bytes 0 (by simp [isR]; omega)] at hl
  exact (eval_load C _ _ _ _ _ _ _ hp).trans hl

/-- `x[i]`. -/
theorem eval_x0 (hr0 : sh0.regions 0 = some ⟨.device, size, ax⟩) (hax : ax % 2 = 0) (slot i : Nat)
    (hb : 2 * (16 * c + i) + 2 ≤ size) (hi : i < 2 ^ 31) (l : Locals) (sh : Shared)
    (hF : Footprint ctx (isR 0) (isR tr) sh0 sh) (htr : tr ≠ 0)
    (h11 : l 11 = some (.ptr ⟨0, ((32 * c : Nat) : Int), .scalar .bf16⟩)) (hs : l slot = some (.int .i32 i)) :
    (eval C ctx l (x0 slot)).run sh = some (.bf16 (bfAt (sh0.bytes 0) (16 * c + i)), rd ctx sh 0 (2 * (16 * c + i))) := by
  have hp := eval_ptr_i32 C (ctx := ctx) (eval_local' C h11 sh) (eval_local' C hs sh) hi
  rw [show 32 * c + i * (Ty.scalar .bf16).bytes = 2 * (16 * c + i) by simp [Ty.bytes, Scalar.bytes]; ring] at hp
  have hl := load_bf16 ctx sh 0 size ax (16 * c + i) (by rw [hF.regions]; exact hr0) hax hb
  rw [hF.bytes 0 (by simp [isR]; omega)] at hl
  exact (eval_load C _ _ _ _ _ _ _ hp).trans hl

/-- The bfloat sum `acc + x[i + k₁] + …`. -/
theorem eval_bsumE (hr0 : sh0.regions 0 = some ⟨.device, size, ax⟩) (hax : ax % 2 = 0) (slot i : Nat) (htr : tr ≠ 0)
    (l : Locals) (h11 : l 11 = some (.ptr ⟨0, ((32 * c : Nat) : Int), .scalar .bf16⟩)) (hs : l slot = some (.int .i32 i)) :
    ∀ (ks : List Nat), (∀ k ∈ ks, 2 * (16 * c + i + k) + 2 ≤ size ∧ i + k < 2 ^ 31) →
    ∀ (acc : CExpr) (a : BF) (sh sh₁ : Shared), (eval C ctx l acc).run sh = some (.bf16 a, sh₁) →
      Footprint ctx (isR 0) (isR tr) sh0 sh → Footprint ctx (isR 0) noT sh sh₁ →
      ∃ sh', (eval C ctx l (bsumE slot acc ks)).run sh =
        some (.bf16 (ks.foldl (fun s k => C.bfadd s (bfAt (sh0.bytes 0) (16 * c + i + k))) a), sh') ∧
        Footprint ctx (isR 0) noT sh sh'
  | [], _, _, _, _, sh₁, he, _, hR => ⟨sh₁, he, hR⟩
  | k :: ks, hks, acc, a, sh, sh₁, he, hF, hR => by
    have hx := eval_xAt (C := C) hr0 hax slot i k (hks k (List.mem_cons_self ..)).1 (hks k (List.mem_cons_self ..)).2 l sh₁
      (hF.trans (hR.mono (fun _ h => h) (fun _ h => h.elim))) htr h11 hs
    have hadd := eval_bin C (op := .add) (s := .bf16) (site := 0) (by simp) he hx (z := .bf16 (C.bfadd a (bfAt (sh0.bytes 0) (16 * c + i + k)))) rfl
    exact eval_bsumE hr0 hax slot i htr l h11 hs ks (fun k' h => hks k' (List.mem_cons_of_mem _ h)) _ _ sh _ hadd
      hF (hR.trans (by rw [rd_eq]; exact Footprint.rdn _ _ _ _ rfl))

/-- An f32 store to element `e` of thread memory `tr` extends what it holds. -/
theorem store_tr (hrt : sh0.regions tr = some ⟨.thread, 64, 4⟩) (e : Nat) (he : e < 16) (y : Float32)
    (v : Nat → Float32) (hv : v e = y) (sh : Shared) (hF : Footprint ctx (isR 0) (isR tr) sh0 sh)
    (ht : ∀ j < e, f32At (sh.bytes tr) j = v j) :
    (storeAt ctx (.scalar .f32) ⟨tr, ((4 * e : Nat) : Int), .scalar .f32⟩ (.f32 y)).run sh = some ((), wrT sh tr (4 * e) y) ∧
      Footprint ctx (isR 0) (isR tr) sh0 (wrT sh tr (4 * e) y) ∧ ∀ j < e + 1, f32At ((wrT sh tr (4 * e) y).bytes tr) j = v j := by
  refine ⟨store_f32_thread ctx sh tr 64 e y (by rw [hF.regions]; exact hrt) (by omega),
    hF.trans (Footprint.wrT _ _ _ _ rfl), fun j hj => ?_⟩
  show f32At (if tr = tr then writeBytes (sh.bytes tr) (4 * e) (wordBytes 4 (Val.f32Bits y)) else sh.bytes tr) j = v j
  rw [ite_eq_left rfl]
  by_cases hje : j = e
  · subst hje; rw [f32At_write_same, hv]
  · rw [f32At_write_other _ _ hje]; exact ht j (by omega)

/-- `x_thread[i] = x[i]`. -/
theorem first_store (hr0 : sh0.regions 0 = some ⟨.device, size, ax⟩) (hax : ax % 2 = 0)
    (hrt : sh0.regions tr = some ⟨.thread, 64, 4⟩) (htr : tr ≠ 0) (slot i : Nat) (hi : i < 16) (hb : 32 * c + 32 ≤ size)
    (v : Nat → Float32) (hv : v i = xf C (sh0.bytes 0) (16 * c + i)) (l : Locals) (sh : Shared)
    (hF : Footprint ctx (isR 0) (isR tr) sh0 sh)
    (h11 : l 11 = some (.ptr ⟨0, ((32 * c : Nat) : Int), .scalar .bf16⟩)) (h12 : l 12 = some (.ptr ⟨tr, 0, .scalar .f32⟩))
    (hs : l slot = some (.int .i32 i)) (ht : ∀ j < i, f32At (sh.bytes tr) j = v j) :
    ∃ sh', Exec C ctx [.store (.scalar .f32) (.offset (.local 12) (.local slot)) (.conv .f32 (x0 slot))] l sh .normal l sh' ∧
      Footprint ctx (isR 0) (isR tr) sh0 sh' ∧ ∀ j < i + 1, f32At (sh'.bytes tr) j = v j := by
  have hp := eval_ptr_i32 C (ctx := ctx) (o := 0) (eval_local' C h12 sh) (eval_local' C hs sh) (by omega)
  rw [show 0 + i * (Ty.scalar .f32).bytes = 4 * i by simp [Ty.bytes, Scalar.bytes]; ring] at hp
  have hx := eval_conv C (t := .f32) (eval_x0 (C := C) hr0 hax slot i (by omega) (by omega) l sh hF htr h11 hs) (convert_f32_bf16 C _)
  have hF₁ : Footprint ctx (isR 0) (isR tr) sh0 (rd ctx sh 0 (2 * (16 * c + i))) :=
    hF.trans (by rw [rd_eq]; exact Footprint.rdn _ _ _ _ rfl)
  obtain ⟨hst, hF₂, ht₂⟩ := store_tr hrt i hi _ v hv _ hF₁ (by intro j hj; exact ht j hj)
  exact ⟨_, .store hp hx hst (.nil _ _), hF₂, ht₂⟩

/-- `x_thread[i + k] = x[i + k] / d` for the stores `ks` at consecutive `k` from `k0`. -/
theorem scale_stores (hr0 : sh0.regions 0 = some ⟨.device, size, ax⟩) (hax : ax % 2 = 0)
    (hrt : sh0.regions tr = some ⟨.thread, 64, 4⟩) (htr : tr ≠ 0) (slot i : Nat) (hb : 32 * c + 32 ≤ size)
    (v : Nat → Float32) (l : Locals)
    (h11 : l 11 = some (.ptr ⟨0, ((32 * c : Nat) : Int), .scalar .bf16⟩)) (h12 : l 12 = some (.ptr ⟨tr, 0, .scalar .f32⟩))
    (hs : l slot = some (.int .i32 i)) :
    ∀ (ks : List (Nat × Nat)) (k0 : Nat), (∀ n p, ks[n]? = some p → p.1 = k0 + n ∧ i + p.1 < 16 ∧
      v (i + p.1) = C.fmul (xf C (sh0.bytes 0) (16 * c + i + p.1)) (Val.ofF32Bits p.2)) →
    ∀ (sh : Shared), Footprint ctx (isR 0) (isR tr) sh0 sh → (∀ j < i + k0, f32At (sh.bytes tr) j = v j) →
    ∃ sh', Exec C ctx (ks.map fun p => scaleStore slot p.1 p.2) l sh .normal l sh' ∧
      Footprint ctx (isR 0) (isR tr) sh0 sh' ∧ ∀ j < i + k0 + ks.length, f32At (sh'.bytes tr) j = v j
  | [], k0, _, sh, hF, ht => ⟨sh, .nil _ _, hF, by simpa using ht⟩
  | ⟨k, s⟩ :: ks, k0, hks, sh, hF, ht => by
    obtain ⟨hk0, hk, hv⟩ := hks 0 ⟨k, s⟩ rfl
    simp only [Nat.add_zero] at hk0 hk hv
    have hp := eval_ptr_i32 C (ctx := ctx) (o := 0) (eval_local' C h12 sh) (eval_addi C (k := k) hs (by omega) sh) (by omega)
    rw [show 0 + (i + k) * (Ty.scalar .f32).bytes = 4 * (i + k) by simp [Ty.bytes, Scalar.bytes]; ring] at hp
    have hx : (eval C ctx l (.conv .f32 (.bin .mul .f32 0 (.conv .f32 (xAt slot k)) (f32l s)))).run sh =
        some (.f32 (C.fmul (C.widen (bfAt (sh0.bytes 0) (16 * c + i + k))) (Val.ofF32Bits s)),
          rd ctx sh 0 (2 * (16 * c + i + k))) :=
      eval_conv C (eval_f32 C (.inl ⟨by decide, by decide⟩)
        (eval_conv C (eval_xAt (C := C) hr0 hax slot i k (by omega) (by omega) l sh hF htr h11 hs) rfl)
        (eval_lit C _ _ _ _) rfl) rfl
    have hF₁ : Footprint ctx (isR 0) (isR tr) sh0 (rd ctx sh 0 (2 * (16 * c + i + k))) :=
      hF.trans (by rw [rd_eq]; exact Footprint.rdn _ _ _ _ rfl)
    obtain ⟨hst, hF₂, ht₂⟩ := store_tr hrt (i + k) hk _ v (by rw [hv]) _ hF₁
      (by intro j hj; exact ht j (by omega))
    obtain ⟨sh', hex, hF', ht'⟩ := scale_stores hr0 hax hrt htr slot i hb v l h11 h12 hs ks (k0 + 1)
      (fun n p hp => by
        have := hks (n + 1) p (by simpa using hp)
        exact ⟨by omega, this.2.1, this.2.2⟩) _ hF₂ (by intro j hj; exact ht₂ j (by omega))
    refine ⟨sh', ?_, hF', by intro j hj; exact ht' j (by simp at hj ⊢; omega)⟩
    exact (Exec.append (.store hp hx hst (.nil _ _)) hex : Exec C ctx ([scaleStore slot k s] ++ ks.map _) _ _ _ _ _)

variable (C)

/-! ### At BITS = 3 -/

/-- `x_thread[j]` of chunk `c` at BITS = 3: `x[i]` at `j % 8 = 0`, else `x[i + k] / d` for `k = j % 8`, the
division folded to the product with `1/d` (`d` = 8, 64, 2, 16, 128, 4, 32 for `k` = 1 … 7). -/
def xt3 (X : ByteMemory.Bytes) (c j : Nat) : Float32 :=
  match j % 8 with
  | 1 => C.fmul (xf C X (16 * c + j)) (Val.ofF32Bits 0x3E000000)
  | 2 => C.fmul (xf C X (16 * c + j)) (Val.ofF32Bits 0x3C800000)
  | 3 => C.fmul (xf C X (16 * c + j)) (Val.ofF32Bits 0x3F000000)
  | 4 => C.fmul (xf C X (16 * c + j)) (Val.ofF32Bits 0x3D800000)
  | 5 => C.fmul (xf C X (16 * c + j)) (Val.ofF32Bits 0x3C000000)
  | 6 => C.fmul (xf C X (16 * c + j)) (Val.ofF32Bits 0x3E800000)
  | 7 => C.fmul (xf C X (16 * c + j)) (Val.ofF32Bits 0x3D000000)
  | _ => xf C X (16 * c + j)

/-- The sum `mlxq_load_vector<T, 3>` returns for chunk `c`: `sum += x[i] + … + x[i + 7]` (the eight added as
bfloats) for `i` = 0, 8, from `sum = 0`. -/
def cs3 (X : ByteMemory.Bytes) (c : Nat) : Float32 :=
  C.fadd (C.fadd zero (C.widen (bsum C X (16 * c) [1, 2, 3, 4, 5, 6, 7]))) (C.widen (bsum C X (16 * c + 8) [1, 2, 3, 4, 5, 6, 7]))

def scales3 : List (Nat × Nat) :=
  [(1, 0x3E000000), (2, 0x3C800000), (3, 0x3F000000), (4, 0x3D800000), (5, 0x3C000000), (6, 0x3E800000), (7, 0x3D000000)]

theorem loadVecBody_eq : loadVecBody =
    [.set 14 (.bin .add .f32 0 (.local 14) chunkSum), .store (.scalar .f32) (.offset (.local 12) (.local 15)) (.conv .f32 (x0 15))] ++
      scales3.map fun p => scaleStore 15 p.1 p.2 := rfl

variable {C}

theorem xt3_scaled (X : ByteMemory.Bytes) (c i : Nat) (hi : i = 0 ∨ i = 8) :
    ∀ n p, scales3[n]? = some p → p.1 = 1 + n ∧ i + p.1 < 16 ∧
      xt3 C X c (i + p.1) = C.fmul (xf C X (16 * c + i + p.1)) (Val.ofF32Bits p.2) := by
  intro n p hp
  rcases n with _ | _ | _ | _ | _ | _ | _ | n <;> simp [scales3] at hp <;> subst hp <;>
    refine ⟨rfl, by omega, ?_⟩ <;> simp only [xt3, Nat.add_assoc] <;> rw [Nat.add_mod, show i % 8 = 0 by omega] <;> rfl

/-- One iteration `i` (0 or 8) of `load_vector`'s bits-3 loop. -/
theorem lv3_body (hr0 : sh0.regions 0 = some ⟨.device, size, ax⟩) (hax : ax % 2 = 0)
    (hrt : sh0.regions tr = some ⟨.thread, 64, 4⟩) (htr : tr ≠ 0) (hb : 32 * c + 32 ≤ size) (i : Nat) (hi : i = 0 ∨ i = 8)
    (l : Locals) (sh : Shared) (sm : Float32) (hF : Footprint ctx (isR 0) (isR tr) sh0 sh)
    (h11 : l 11 = some (.ptr ⟨0, ((32 * c : Nat) : Int), .scalar .bf16⟩)) (h12 : l 12 = some (.ptr ⟨tr, 0, .scalar .f32⟩))
    (h14 : l 14 = some (.f32 sm)) (h15 : l 15 = some (.int .i32 i))
    (ht : ∀ j < i, f32At (sh.bytes tr) j = xt3 C (sh0.bytes 0) c j) :
    ∃ sh', Exec C ctx loadVecBody l sh .normal
      (setLocal l 14 (.f32 (C.fadd sm (C.widen (bsum C (sh0.bytes 0) (16 * c + i) [1, 2, 3, 4, 5, 6, 7]))))) sh' ∧
      Footprint ctx (isR 0) (isR tr) sh0 sh' ∧ ∀ j < i + 8, f32At (sh'.bytes tr) j = xt3 C (sh0.bytes 0) c j := by
  obtain ⟨sh₁, hs, hR₁⟩ := eval_bsumE (C := C) hr0 hax 15 i htr l h11 h15 [1, 2, 3, 4, 5, 6, 7]
    (by intro k hk; simp at hk; omega) (x0 15) _ sh _
    (eval_x0 (C := C) hr0 hax 15 i (by omega) (by omega) l sh hF htr h11 h15) hF
    (by rw [rd_eq]; exact Footprint.rdn _ _ _ _ rfl)
  have hsum : (eval C ctx l (.bin .add .f32 0 (.local 14) chunkSum)).run sh =
      some (.f32 (C.fadd sm (C.widen (bsum C (sh0.bytes 0) (16 * c + i) [1, 2, 3, 4, 5, 6, 7]))), sh₁) := by
    rw [chunkSum_eq]
    exact eval_f32 C (.inr ⟨rfl, rfl⟩) (eval_local' C h14 sh) (eval_conv C hs rfl) rfl
  have hF₁ : Footprint ctx (isR 0) (isR tr) sh0 sh₁ := hF.trans (hR₁.mono (fun _ h => h) (fun _ h => h.elim))
  generalize hl₁ : setLocal l 14 (.f32 (C.fadd sm (C.widen (bsum C (sh0.bytes 0) (16 * c + i) [1, 2, 3, 4, 5, 6, 7])))) = l₁
  have g11 : l₁ 11 = some (.ptr ⟨0, ((32 * c : Nat) : Int), .scalar .bf16⟩) := by rw [← hl₁, setLocal_other _ _ (by omega)]; exact h11
  have g12 : l₁ 12 = some (.ptr ⟨tr, 0, .scalar .f32⟩) := by rw [← hl₁, setLocal_other _ _ (by omega)]; exact h12
  have g15 : l₁ 15 = some (.int .i32 i) := by rw [← hl₁, setLocal_other _ _ (by omega)]; exact h15
  obtain ⟨sh₂, hex₂, hF₂, ht₂⟩ := first_store (C := C) hr0 hax hrt htr 15 i (by omega) hb (xt3 C (sh0.bytes 0) c)
    (by simp only [xt3]; rw [show i % 8 = 0 by omega]; rfl) l₁ sh₁ hF₁ g11 g12 g15
    (by rw [hR₁.bytes_eq]; exact ht)
  obtain ⟨sh₃, hex₃, hF₃, ht₃⟩ := scale_stores (C := C) hr0 hax hrt htr 15 i hb (xt3 C (sh0.bytes 0) c) l₁ g11 g12 g15
    scales3 1 (xt3_scaled _ c i hi) sh₂ hF₂ ht₂
  refine ⟨sh₃, ?_, hF₃, ht₃⟩
  subst hl₁
  rw [loadVecBody_eq]
  exact .set hsum (Exec.append hex₂ hex₃)

end LoadVector

theorem lv3_spec (C : M1Max.Contract) (wa : Nat) (qd : CStmt)
    (qv : (Nat → Bool) → ByteMemory.Bytes → Nat → (Nat → Float32) → Float32 → Float32 → Float32 → Float32) :
    LvSpec C ⟨3, wa, loadVecScope, qd, xt3 C, cs3 C, qv⟩ := by
  intro ctx l sh c tr size ax hr0 hax hb hrt htr h11 h12
  simp only
  have hF0 := Footprint.refl ctx (isR 0) (isR tr) sh
  generalize hl₁ : setLocal (setLocal l 14 (.f32 zero)) 15 (.int .i32 0) = l₁
  have g11 : l₁ 11 = some (.ptr ⟨0, ((32 * c : Nat) : Int), .scalar .bf16⟩) := by
    rw [← hl₁, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact h11
  have g12 : l₁ 12 = some (.ptr ⟨tr, 0, .scalar .f32⟩) := by
    rw [← hl₁, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact h12
  have g14 : l₁ 14 = some (.f32 zero) := by rw [← hl₁, setLocal_other _ _ (by omega)]; exact setLocal_same _ _ _
  have g15 : l₁ 15 = some (.int .i32 0) := by rw [← hl₁]; exact setLocal_same _ _ _
  obtain ⟨sh₁, hex₁, hF₁, ht₁⟩ := lv3_body (C := C) hr0 hax hrt htr hb 0 (.inl rfl) l₁ sh zero hF0 g11 g12 g14 g15
    (fun j hj => absurd hj (Nat.not_lt_zero _))
  generalize hs₀ : C.fadd zero (C.widen (bsum C (sh.bytes 0) (16 * c + 0) [1, 2, 3, 4, 5, 6, 7])) = s₀ at hex₁
  generalize hl₂ : setLocal (setLocal l₁ 14 (.f32 s₀)) 15 (.int .i32 8) = l₂
  have hst₁ : Exec C ctx (stepBy 15 8) (setLocal l₁ 14 (.f32 s₀)) sh₁ .normal l₂ sh₁ := by
    rw [← hl₂]; exact .set (eval_addi C (by rw [setLocal_other _ _ (by omega)]; exact g15) (by omega) _) (.nil _ _)
  have g11₂ : l₂ 11 = some (.ptr ⟨0, ((32 * c : Nat) : Int), .scalar .bf16⟩) := by
    rw [← hl₂, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact g11
  have g12₂ : l₂ 12 = some (.ptr ⟨tr, 0, .scalar .f32⟩) := by
    rw [← hl₂, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact g12
  have g14₂ : l₂ 14 = some (.f32 s₀) := by rw [← hl₂, setLocal_other _ _ (by omega)]; exact setLocal_same _ _ _
  have g15₂ : l₂ 15 = some (.int .i32 8) := by rw [← hl₂]; exact setLocal_same _ _ _
  obtain ⟨sh₂, hex₂, hF₂, ht₂⟩ := lv3_body (C := C) hr0 hax hrt htr hb 8 (.inr rfl) l₂ sh₁ s₀ hF₁ g11₂ g12₂ g14₂ g15₂
    (fun j hj => ht₁ j (by omega))
  generalize hs₁ : C.fadd s₀ (C.widen (bsum C (sh.bytes 0) (16 * c + 8) [1, 2, 3, 4, 5, 6, 7])) = s₁ at hex₂
  generalize hl₃ : setLocal (setLocal l₂ 14 (.f32 s₁)) 15 (.int .i32 16) = l₃
  have hst₂ : Exec C ctx (stepBy 15 8) (setLocal l₂ 14 (.f32 s₁)) sh₂ .normal l₃ sh₂ := by
    rw [← hl₃]; exact .set (eval_addi C (by rw [setLocal_other _ _ (by omega)]; exact g15₂) (by omega) _) (.nil _ _)
  have g14₃ : l₃ 14 = some (.f32 s₁) := by rw [← hl₃, setLocal_other _ _ (by omega)]; exact setLocal_same _ _ _
  have g15₃ : l₃ 15 = some (.int .i32 16) := by rw [← hl₃]; exact setLocal_same _ _ _
  have hbody : Exec C ctx [.set 14 (f32l 0x0), .set 15 (i32l 0), loadVecLoop, .set 13 (.local 14), .leave] l sh .leave
      (setLocal l₃ 13 (.f32 s₁)) sh₂ := by
    refine .set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _) ?_)
    subst hl₁
    exact .loop_next (eval_lt_true (C := C) g15 (by omega) (by omega) _) hex₁ (.inl rfl) hst₁
      (.loop_next (eval_lt_true (C := C) g15₂ (by omega) (by omega) _) hex₂ (.inl rfl) hst₂
        (.loop_exit (eval_lt_false (C := C) g15₃ (by omega) (by omega) (by omega) _)
          (.set (eval_local' C g14₃ _) .leave)))
  refine ⟨_, sh₂, .scope hbody (.inr rfl) (.nil _ _), hF₂, ?_, ?_, ht₂⟩
  · intro j hj
    rw [setLocal_other _ _ (by omega), ← hl₃, ← hl₂, ← hl₁]
    simp only [setLocal]
    simp [show j ≠ 14 by omega, show j ≠ 15 by omega]
  · rw [setLocal_same, ← hs₁, ← hs₀]
    simp only [Nat.add_zero]
    rfl

/-! ### At BITS = 4 -/

section LoadVector4
variable (C : M1Max.Contract)

/-- `x_thread[j]` of chunk `c` at BITS = 4: `x[i]` at `j % 4 = 0`, else `x[i + k] / d` for `k = j % 4`, the
division folded to the product with `1/d` (`d` = 16, 256, 4096 for `k` = 1, 2, 3). -/
def xt4 (X : ByteMemory.Bytes) (c j : Nat) : Float32 :=
  match j % 4 with
  | 1 => C.fmul (xf C X (16 * c + j)) (Val.ofF32Bits 0x3D800000)
  | 2 => C.fmul (xf C X (16 * c + j)) (Val.ofF32Bits 0x3B800000)
  | 3 => C.fmul (xf C X (16 * c + j)) (Val.ofF32Bits 0x39800000)
  | _ => xf C X (16 * c + j)

/-- The sum `mlxq_load_vector<T, 4>` returns for chunk `c`: `sum += x[i] + x[i + 1] + x[i + 2] + x[i + 3]` (added as
bfloats) for `i` = 0, 4, 8, 12, from `sum = 0`. -/
def cs4 (X : ByteMemory.Bytes) (c : Nat) : Float32 :=
  C.fadd (C.fadd (C.fadd (C.fadd zero (C.widen (bsum C X (16 * c) [1, 2, 3]))) (C.widen (bsum C X (16 * c + 4) [1, 2, 3])))
    (C.widen (bsum C X (16 * c + 8) [1, 2, 3]))) (C.widen (bsum C X (16 * c + 12) [1, 2, 3]))

def scales4 : List (Nat × Nat) := [(1, 0x3D800000), (2, 0x3B800000), (3, 0x39800000)]

theorem loadVecBody4_eq : loadVecBody4 =
    [.set 14 (.bin .add .f32 0 (.local 14) chunkSum4), .store (.scalar .f32) (.offset (.local 12) (.local 16)) (.conv .f32 (x0 16))] ++
      scales4.map fun p => scaleStore 16 p.1 p.2 := rfl

variable {C}

theorem xt4_scaled (X : ByteMemory.Bytes) (c i : Nat) (hi : i % 4 = 0) (hi16 : i < 16) :
    ∀ n p, scales4[n]? = some p → p.1 = 1 + n ∧ i + p.1 < 16 ∧
      xt4 C X c (i + p.1) = C.fmul (xf C X (16 * c + i + p.1)) (Val.ofF32Bits p.2) := by
  intro n p hp
  rcases n with _ | _ | _ | n <;> simp [scales4] at hp <;> subst hp <;>
    refine ⟨rfl, by omega, ?_⟩ <;> simp only [xt4, Nat.add_assoc] <;> rw [Nat.add_mod, hi] <;> rfl

variable {ctx : Ctx} {sh0 : Shared} {size ax tr c : Nat}

/-- One iteration `i` (0, 4, 8 or 12) of `load_vector`'s bits-4 loop. -/
theorem lv4_body (hr0 : sh0.regions 0 = some ⟨.device, size, ax⟩) (hax : ax % 2 = 0)
    (hrt : sh0.regions tr = some ⟨.thread, 64, 4⟩) (htr : tr ≠ 0) (hb : 32 * c + 32 ≤ size) (i : Nat) (hi : i % 4 = 0)
    (hi16 : i < 16) (l : Locals) (sh : Shared) (sm : Float32) (hF : Footprint ctx (isR 0) (isR tr) sh0 sh)
    (h11 : l 11 = some (.ptr ⟨0, ((32 * c : Nat) : Int), .scalar .bf16⟩)) (h12 : l 12 = some (.ptr ⟨tr, 0, .scalar .f32⟩))
    (h14 : l 14 = some (.f32 sm)) (h16 : l 16 = some (.int .i32 i))
    (ht : ∀ j < i, f32At (sh.bytes tr) j = xt4 C (sh0.bytes 0) c j) :
    ∃ sh', Exec C ctx loadVecBody4 l sh .normal
      (setLocal l 14 (.f32 (C.fadd sm (C.widen (bsum C (sh0.bytes 0) (16 * c + i) [1, 2, 3]))))) sh' ∧
      Footprint ctx (isR 0) (isR tr) sh0 sh' ∧ ∀ j < i + 4, f32At (sh'.bytes tr) j = xt4 C (sh0.bytes 0) c j := by
  obtain ⟨sh₁, hs, hR₁⟩ := eval_bsumE (C := C) hr0 hax 16 i htr l h11 h16 [1, 2, 3]
    (by intro k hk; simp at hk; omega) (x0 16) _ sh _
    (eval_x0 (C := C) hr0 hax 16 i (by omega) (by omega) l sh hF htr h11 h16) hF
    (by rw [rd_eq]; exact Footprint.rdn _ _ _ _ rfl)
  have hsum : (eval C ctx l (.bin .add .f32 0 (.local 14) chunkSum4)).run sh =
      some (.f32 (C.fadd sm (C.widen (bsum C (sh0.bytes 0) (16 * c + i) [1, 2, 3]))), sh₁) := by
    rw [chunkSum4_eq]
    exact eval_f32 C (.inr ⟨rfl, rfl⟩) (eval_local' C h14 sh) (eval_conv C hs rfl) rfl
  have hF₁ : Footprint ctx (isR 0) (isR tr) sh0 sh₁ := hF.trans (hR₁.mono (fun _ h => h) (fun _ h => h.elim))
  generalize hl₁ : setLocal l 14 (.f32 (C.fadd sm (C.widen (bsum C (sh0.bytes 0) (16 * c + i) [1, 2, 3])))) = l₁
  have g11 : l₁ 11 = some (.ptr ⟨0, ((32 * c : Nat) : Int), .scalar .bf16⟩) := by rw [← hl₁, setLocal_other _ _ (by omega)]; exact h11
  have g12 : l₁ 12 = some (.ptr ⟨tr, 0, .scalar .f32⟩) := by rw [← hl₁, setLocal_other _ _ (by omega)]; exact h12
  have g16 : l₁ 16 = some (.int .i32 i) := by rw [← hl₁, setLocal_other _ _ (by omega)]; exact h16
  obtain ⟨sh₂, hex₂, hF₂, ht₂⟩ := first_store (C := C) hr0 hax hrt htr 16 i hi16 hb (xt4 C (sh0.bytes 0) c)
    (by simp only [xt4]; rw [hi]; rfl) l₁ sh₁ hF₁ g11 g12 g16
    (by rw [hR₁.bytes_eq]; exact ht)
  obtain ⟨sh₃, hex₃, hF₃, ht₃⟩ := scale_stores (C := C) hr0 hax hrt htr 16 i hb (xt4 C (sh0.bytes 0) c) l₁ g11 g12 g16
    scales4 1 (xt4_scaled _ c i hi hi16) sh₂ hF₂ ht₂
  refine ⟨sh₃, ?_, hF₃, ht₃⟩
  subst hl₁
  rw [loadVecBody4_eq]
  exact .set hsum (Exec.append hex₂ hex₃)

end LoadVector4

theorem lv4_spec (C : M1Max.Contract) (wa : Nat) (qd : CStmt)
    (qv : (Nat → Bool) → ByteMemory.Bytes → Nat → (Nat → Float32) → Float32 → Float32 → Float32 → Float32) :
    LvSpec C ⟨4, wa, loadVecScope4, qd, xt4 C, cs4 C, qv⟩ := by
  intro ctx l sh c tr size ax hr0 hax hb hrt htr h11 h12
  simp only
  -- the loop's iteration `n` (counter `4n`), with `sum` so far `a`
  have step : ∀ (n : Nat) (hn : n < 4) (l : Locals) (sh' : Shared) (a : Float32),
      Footprint ctx (isR 0) (isR tr) sh sh' → l 11 = some (.ptr ⟨0, ((32 * c : Nat) : Int), .scalar .bf16⟩) →
      l 12 = some (.ptr ⟨tr, 0, .scalar .f32⟩) → l 14 = some (.f32 a) → l 16 = some (.int .i32 (4 * n)) →
      (∀ j < 4 * n, f32At (sh'.bytes tr) j = xt4 C (sh.bytes 0) c j) →
      ∃ sh'', Exec C ctx loadVecBody4 l sh' .normal
        (setLocal l 14 (.f32 (C.fadd a (C.widen (bsum C (sh.bytes 0) (16 * c + 4 * n) [1, 2, 3]))))) sh'' ∧
        Exec C ctx (stepBy 16 4) (setLocal l 14 (.f32 (C.fadd a (C.widen (bsum C (sh.bytes 0) (16 * c + 4 * n) [1, 2, 3])))))
          sh'' .normal (setLocal (setLocal l 14 (.f32 (C.fadd a (C.widen (bsum C (sh.bytes 0) (16 * c + 4 * n) [1, 2, 3])))))
            16 (.int .i32 (4 * (n + 1)))) sh'' ∧
        Footprint ctx (isR 0) (isR tr) sh sh'' ∧ ∀ j < 4 * (n + 1), f32At (sh''.bytes tr) j = xt4 C (sh.bytes 0) c j := by
    intro n hn l sh' a hF g11 g12 g14 g16 ht
    obtain ⟨sh'', hex, hF', ht'⟩ := lv4_body (C := C) hr0 hax hrt htr hb (4 * n) (by omega) (by omega) l sh' a hF g11 g12
      g14 g16 ht
    refine ⟨sh'', hex, .set (eval_addi C (by rw [setLocal_other _ _ (by omega)]; exact g16) (by omega) _)
      (by rw [show 4 * n + 4 = 4 * (n + 1) by ring]; exact .nil _ _), hF', fun j hj => ht' j (by omega)⟩
  have keep : ∀ (l : Locals) (a : Float32) (k : Nat), (setLocal (setLocal l 14 (.f32 a)) 16 (.int .i32 k)) 11 = l 11 ∧
      (setLocal (setLocal l 14 (.f32 a)) 16 (.int .i32 k)) 12 = l 12 := fun l a k => by simp [setLocal]
  have hF0 := Footprint.refl ctx (isR 0) (isR tr) sh
  generalize hl₁ : setLocal (setLocal l 14 (.f32 zero)) 16 (.int .i32 0) = l₁
  obtain ⟨sh₁, e1, s1, hF₁, ht₁⟩ := step 0 (by omega) l₁ sh zero hF0
    (by rw [← hl₁, (keep l zero 0).1]; exact h11) (by rw [← hl₁, (keep l zero 0).2]; exact h12)
    (by rw [← hl₁]; simp [setLocal]) (by rw [← hl₁]; simp [setLocal]) (fun j hj => absurd hj (by omega))
  generalize ha₁ : C.fadd zero (C.widen (bsum C (sh.bytes 0) (16 * c + 4 * 0) [1, 2, 3])) = a₁ at e1 s1
  generalize hl₂ : setLocal (setLocal l₁ 14 (.f32 a₁)) 16 (.int .i32 (4 * (0 + 1))) = l₂ at s1
  obtain ⟨sh₂, e2, s2, hF₂, ht₂⟩ := step 1 (by omega) l₂ sh₁ a₁ hF₁
    (by rw [← hl₂, (keep l₁ a₁ _).1, ← hl₁, (keep l zero 0).1]; exact h11)
    (by rw [← hl₂, (keep l₁ a₁ _).2, ← hl₁, (keep l zero 0).2]; exact h12)
    (by rw [← hl₂]; simp [setLocal]) (by rw [← hl₂]; simp [setLocal]) ht₁
  generalize ha₂ : C.fadd a₁ (C.widen (bsum C (sh.bytes 0) (16 * c + 4 * 1) [1, 2, 3])) = a₂ at e2 s2
  generalize hl₃ : setLocal (setLocal l₂ 14 (.f32 a₂)) 16 (.int .i32 (4 * (1 + 1))) = l₃ at s2
  obtain ⟨sh₃, e3, s3, hF₃, ht₃⟩ := step 2 (by omega) l₃ sh₂ a₂ hF₂
    (by rw [← hl₃, (keep l₂ a₂ _).1, ← hl₂, (keep l₁ a₁ _).1, ← hl₁, (keep l zero 0).1]; exact h11)
    (by rw [← hl₃, (keep l₂ a₂ _).2, ← hl₂, (keep l₁ a₁ _).2, ← hl₁, (keep l zero 0).2]; exact h12)
    (by rw [← hl₃]; simp [setLocal]) (by rw [← hl₃]; simp [setLocal]) ht₂
  generalize ha₃ : C.fadd a₂ (C.widen (bsum C (sh.bytes 0) (16 * c + 4 * 2) [1, 2, 3])) = a₃ at e3 s3
  generalize hl₄ : setLocal (setLocal l₃ 14 (.f32 a₃)) 16 (.int .i32 (4 * (2 + 1))) = l₄ at s3
  obtain ⟨sh₄, e4, s4, hF₄, ht₄⟩ := step 3 (by omega) l₄ sh₃ a₃ hF₃
    (by rw [← hl₄, (keep l₃ a₃ _).1, ← hl₃, (keep l₂ a₂ _).1, ← hl₂, (keep l₁ a₁ _).1, ← hl₁, (keep l zero 0).1]; exact h11)
    (by rw [← hl₄, (keep l₃ a₃ _).2, ← hl₃, (keep l₂ a₂ _).2, ← hl₂, (keep l₁ a₁ _).2, ← hl₁, (keep l zero 0).2]; exact h12)
    (by rw [← hl₄]; simp [setLocal]) (by rw [← hl₄]; simp [setLocal]) ht₃
  generalize ha₄ : C.fadd a₃ (C.widen (bsum C (sh.bytes 0) (16 * c + 4 * 3) [1, 2, 3])) = a₄ at e4 s4
  generalize hl₅ : setLocal (setLocal l₄ 14 (.f32 a₄)) 16 (.int .i32 (4 * (3 + 1))) = l₅ at s4
  have g14₅ : l₅ 14 = some (.f32 a₄) := by rw [← hl₅]; simp [setLocal]
  have g16₅ : l₅ 16 = some (.int .i32 16) := by rw [← hl₅]; simp [setLocal]
  have hbody : Exec C ctx [.set 14 (f32l 0x0), .set 16 (i32l 0), loadVecLoop4, .set 13 (.local 14), .leave] l sh .leave
      (setLocal l₅ 13 (.f32 a₄)) sh₄ := by
    refine .set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _) ?_)
    subst hl₁
    exact .loop_next (eval_lt_true (C := C) (a := 0) (by simp [setLocal]) (by omega) (by omega) _) e1 (.inl rfl) s1
      (.loop_next (eval_lt_true (C := C) (a := 4) (by rw [← hl₂]; simp [setLocal]) (by omega) (by omega) _) e2 (.inl rfl) s2
        (.loop_next (eval_lt_true (C := C) (a := 8) (by rw [← hl₃]; simp [setLocal]) (by omega) (by omega) _) e3 (.inl rfl) s3
          (.loop_next (eval_lt_true (C := C) (a := 12) (by rw [← hl₄]; simp [setLocal]) (by omega) (by omega) _) e4 (.inl rfl) s4
            (.loop_exit (eval_lt_false (C := C) g16₅ (by omega) (by omega) (by omega) _)
              (.set (eval_local' C g14₅ _) .leave)))))
  refine ⟨_, sh₄, .scope hbody (.inr rfl) (.nil _ _), hF₄, ?_, ?_, ht₄⟩
  · intro j hj
    rw [setLocal_other _ _ (by omega), ← hl₅, ← hl₄, ← hl₃, ← hl₂, ← hl₁]
    simp only [setLocal]
    simp [show j ≠ 14 by omega, show j ≠ 16 by omega]
  · rw [setLocal_same, ← ha₄, ← ha₃, ← ha₂, ← ha₁]
    simp only [Nat.mul_zero, Nat.add_zero, Nat.mul_one]
    rfl

/-! ## Expected outputs

On the inputs' bytes: `x` (bf16 elements `bfAt X`), `w` (bytes, `byteAt W`), `scales` and `biases` (bf16
elements). Lane `L` of the SIMD-group computing row `row` handles, at K step `t`, the 16 values of chunk `32t + L` of
`x` (its `x_thread` and sum from `load_vector`), the lane's weight bytes of the step and the scale and bias of group
`8t + L / 4` of the row. -/

section Expected
variable (C : M1Max.Contract) (V : Variant)

/-- `result[r]` of lane `L` for row `row` after the first `t` K steps: `result[r] += qdot(ws + r * ROWB, x_thread,
s, b, sum)` from `result[r] = 0`. -/
def acc (fuse : Nat → Bool) (steps : Nat) (X W S B : ByteMemory.Bytes) (row L : Nat) : Nat → Float32
  | 0 => zero
  | t + 1 => C.fadd (acc fuse steps X W S B row L t)
      (V.qv fuse W (row * (64 * V.bits * steps) + 2 * V.bits * L + 64 * V.bits * t) (V.xt X (32 * t + L))
        (C.widen (bfAt S (row * (8 * steps) + 8 * t + L / 4))) (C.widen (bfAt B (row * (8 * steps) + 8 * t + L / 4)))
        (V.cs X (32 * t + L)))

/-- `y[row] = static_cast<T>(simd_sum(result[r]))`. -/
def yOf (fuse : Nat → Bool) (steps : Nat) (X W S B : ByteMemory.Bytes) (row : Nat) : BF :=
  C.narrow (C.simdSum fun L => acc C V fuse steps X W S B row L steps)

/-- Byte `b` of `y` [1, 1, N] bf16, N = 64·blocks. -/
def expectedOf (fuse : Nat → Bool) (steps blocks : Nat) (X W S B : ByteMemory.Bytes) (b : Nat) : BitVec 8 :=
  if b < 128 * blocks then (wordBytes 2 (Val.bf16Bits (yOf C V fuse steps X W S B (b / 2)))).getD (b % 2) 0 else 0

end Expected

/-! ## Ownership and memory -/

/-- Writers of device bytes: element `e` of `y` (region 4) by lane 0 of SIMD-group `(e % 64) / 4` of threadgroup
`e / 64`, in device epoch 0 (the barrier does not order device memory). -/
def dev (region byte : Nat) : Option Writer :=
  if region = 4 then some ⟨512 * (byte / 128) + 32 * (byte / 8 % 16), byte / 128, 0⟩ else none

/-- Owners of threadgroup bytes in threadgroup `g`'s first barrier epoch `g`: chunk `c` of `xs` (region 5) and `ss[c]`
(region 6) by thread `c % 512`; read-only after the barrier. -/
def tgo (g ep region byte : Nat) : Option Nat :=
  if ep = g ∧ region = 5 then some (512 * g + byte / 64 % 512)
  else if ep = g ∧ region = 6 then some (512 * g + byte / 4 % 512) else none

/-- The launch's regions: x, w, scales, biases, y, xs, ss and each thread's `t` and `result`. -/
structure Shape (L : Launch) (V : Variant) (steps blocks ax aw as ab : Nat) : Prop where
  r0 : L.regions 0 = some ⟨.device, 1024 * steps, ax⟩
  r1 : L.regions 1 = some ⟨.device, 64 * blocks * (64 * V.bits * steps), aw⟩
  r2 : L.regions 2 = some ⟨.device, 2 * (64 * blocks * (8 * steps)), as⟩
  r3 : L.regions 3 = some ⟨.device, 2 * (64 * blocks * (8 * steps)), ab⟩
  r4 : L.regions 4 = some ⟨.device, 128 * blocks, 16⟩
  r5 : L.regions 5 = some ⟨.threadgroup, 2048 * steps, 4⟩
  r6 : L.regions 6 = some ⟨.threadgroup, 128 * steps, 4⟩
  rt : ∀ T, L.regions (2 * T + 7) = some ⟨.thread, 64, 4⟩
  rr : ∀ T, L.regions (2 * T + 8) = some ⟨.thread, 16, 4⟩
  ax : ax % 2 = 0
  aw : aw % V.wAlign = 0
  as : as % 2 = 0
  ab : ab % 2 = 0

theorem Shape.input {L : Launch} {V : Variant} {steps blocks ax aw as ab : Nat} (h : Shape L V steps blocks ax aw as ab)
    (r : Nat) (hr : r < 4) : ∃ R : Region, L.regions r = some R ∧ R.space = .device := by
  rcases (show r = 0 ∨ r = 1 ∨ r = 2 ∨ r = 3 by omega) with rfl | rfl | rfl | rfl
  · exact ⟨_, h.r0, rfl⟩
  · exact ⟨_, h.r1, rfl⟩
  · exact ⟨_, h.r2, rfl⟩
  · exact ⟨_, h.r3, rfl⟩

/-- The launch and its inputs, and the values `xs`, `ss` and `y` are to hold. -/
structure Env where
  L : Launch
  fuse : Nat → Bool
  X : ByteMemory.Bytes
  W : ByteMemory.Bytes
  S : ByteMemory.Bytes
  B : ByteMemory.Bytes
  xv : Nat → Float32
  sv : Nat → Float32
  yv : Nat → BF

/-- Memory in barrier epoch `ge`, once the `xs` elements `PX`, the `ss` entries `PS` and the `y` elements below `nY`
are written: inputs intact, those values as `E` says, and every access so far owned. -/
structure Mem (E : Env) (ge : Nat) (PX PS : Nat → Prop) (nY : Nat) (sh : Shared) : Prop where
  regions : sh.regions = E.L.regions
  x : sh.bytes 0 = E.X
  w : sh.bytes 1 = E.W
  s : sh.bytes 2 = E.S
  b : sh.bytes 3 = E.B
  dEpoch : sh.deviceEpoch = 0
  gEpoch : sh.groupEpoch = ge
  xs : ∀ e, PX e → f32At (sh.bytes 5) e = E.xv e
  ss : ∀ c, PS c → f32At (sh.bytes 6) c = E.sv c
  y : ∀ e < nY, ∀ j < 2, sh.bytes 4 (2 * e + j) = (wordBytes 2 (Val.bf16Bits (E.yv e))).getD j 0
  log : ∀ a ∈ sh.log, Owned E.L dev tgo a

section MemLemmas
variable {E : Env} {V : Variant} {steps blocks ax aw as ab ge nY : Nat} {PX PS : Nat → Prop} {sh sh' : Shared}

/-- Reads of the inputs, and after the barrier of `xs` and `ss`, and writes of thread memory keep `Mem`. -/
theorem Mem.frame (h : Mem E ge PX PS nY sh) (hS : Shape E.L V steps blocks ax aw as ab) (ctx : Ctx) {R T : Nat → Prop}
    (hf : Footprint ctx R T sh sh') (hR : ∀ r, R r → r < 4 ∨ ((r = 5 ∨ r = 6) ∧ ge ≠ ctx.group))
    (hT : ∀ r, T r → 7 ≤ r) : Mem E ge PX PS nY sh' where
  regions := hf.regions.trans h.regions
  x := (hf.bytes 0 (fun h' => by have := hT 0 h'; omega)).trans h.x
  w := (hf.bytes 1 (fun h' => by have := hT 1 h'; omega)).trans h.w
  s := (hf.bytes 2 (fun h' => by have := hT 2 h'; omega)).trans h.s
  b := (hf.bytes 3 (fun h' => by have := hT 3 h'; omega)).trans h.b
  dEpoch := hf.dEpoch.trans h.dEpoch
  gEpoch := hf.gEpoch.trans h.gEpoch
  xs e he := by rw [hf.bytes 5 (fun h' => by have := hT 5 h'; omega)]; exact h.xs e he
  ss c hc := by rw [hf.bytes 6 (fun h' => by have := hT 6 h'; omega)]; exact h.ss c hc
  y e he j hj := by rw [hf.bytes 4 (fun h' => by have := hT 4 h'; omega)]; exact h.y e he j hj
  log a ha := by
    rcases hf.log a ha with ha | ⟨r, b, hr, rfl⟩
    · exact h.log a ha
    · rcases hR r hr with hr4 | ⟨hr56, hne⟩
      · obtain ⟨R', hR', hsp⟩ := hS.input r hr4
        exact owned_device_read E.L dev tgo ctx sh r b R' hR' (by rw [hsp]; decide) (by simp [dev]; omega)
      · rcases hr56 with rfl | rfl
        · exact owned_group_read E.L dev tgo ctx sh 5 b _ hS.r5 rfl (by simp [tgo, h.gEpoch]; omega)
        · exact owned_group_read E.L dev tgo ctx sh 6 b _ hS.r6 rfl (by simp [tgo, h.gEpoch]; omega)

theorem Mem.mono (h : Mem E ge PX PS nY sh) {PX' PS' : Nat → Prop} {nY' : Nat} (hX : ∀ e, PX' e → PX e)
    (hS : ∀ c, PS' c → PS c) (hY : nY' ≤ nY) : Mem E ge PX' PS' nY' sh where
  regions := h.regions
  x := h.x
  w := h.w
  s := h.s
  b := h.b
  dEpoch := h.dEpoch
  gEpoch := h.gEpoch
  xs e he := h.xs e (hX e he)
  ss c hc := h.ss c (hS c hc)
  y e he := h.y e (by omega)
  log := h.log

/-- The owner of `xs` element `e` writes it in its threadgroup's first epoch. -/
theorem Mem.wxs (h : Mem E ge PX PS nY sh) (hS : Shape E.L V steps blocks ax aw as ab) (ctx : Ctx) (e : Nat)
    (he : e < 512 * steps) (ht : ctx.thread = 512 * ge + e / 16 % 512) (hg : ctx.group = ge) :
    Mem E ge (fun e' => PX e' ∨ e' = e) PS nY (wr4 ctx sh 5 (4 * e) (E.xv e)) where
  regions := h.regions
  x := h.x
  w := h.w
  s := h.s
  b := h.b
  dEpoch := h.dEpoch
  gEpoch := h.gEpoch
  xs e' he' := by
    show f32At (if (5 : Nat) = 5 then writeBytes (sh.bytes 5) (4 * e) (wordBytes 4 (Val.f32Bits (E.xv e))) else sh.bytes 5) e' = _
    rw [ite_eq_left rfl]
    by_cases hee : e' = e
    · subst hee; exact f32At_write_same _ _ _
    · rw [f32At_write_other _ _ hee]; exact h.xs e' (he'.resolve_right hee)
  ss := h.ss
  y := h.y
  log := forall_log _ 4 _ (fun b hb => owned_group E.L dev tgo ctx sh 5 (4 * e + b) _ hS.r5 true rfl
    (by rw [h.gEpoch, hg, ht]; simp [tgo]; omega)) h.log

/-- The owner of `ss[c]` writes it in its threadgroup's first epoch. -/
theorem Mem.wss (h : Mem E ge PX PS nY sh) (hS : Shape E.L V steps blocks ax aw as ab) (ctx : Ctx) (c : Nat)
    (ht : ctx.thread = 512 * ge + c % 512) (hg : ctx.group = ge) :
    Mem E ge PX (fun c' => PS c' ∨ c' = c) nY (wr4 ctx sh 6 (4 * c) (E.sv c)) where
  regions := h.regions
  x := h.x
  w := h.w
  s := h.s
  b := h.b
  dEpoch := h.dEpoch
  gEpoch := h.gEpoch
  xs := h.xs
  ss c' hc' := by
    show f32At (if (6 : Nat) = 6 then writeBytes (sh.bytes 6) (4 * c) (wordBytes 4 (Val.f32Bits (E.sv c))) else sh.bytes 6) c' = _
    rw [ite_eq_left rfl]
    by_cases hcc : c' = c
    · subst hcc; exact f32At_write_same _ _ _
    · rw [f32At_write_other _ _ hcc]; exact h.ss c' (hc'.resolve_right hcc)
  y := h.y
  log := forall_log _ 4 _ (fun b hb => owned_group E.L dev tgo ctx sh 6 (4 * c + b) _ hS.r6 true rfl
    (by rw [h.gEpoch, hg, ht]; simp [tgo]; omega)) h.log

/-- Lane 0 of SIMD-group `(nY % 64) / 4` of threadgroup `nY / 64` writes `y[nY]`. -/
theorem Mem.wy (h : Mem E ge PX PS nY sh) (hS : Shape E.L V steps blocks ax aw as ab) (ctx : Ctx) (hn : nY < 64 * blocks)
    (ht : ctx.thread = 512 * (nY / 64) + 32 * (nY % 64 / 4)) (hg : ctx.group = nY / 64) :
    Mem E ge PX PS (nY + 1) (wr ctx sh 4 (2 * nY) (E.yv nY)) where
  regions := h.regions
  x := h.x
  w := h.w
  s := h.s
  b := h.b
  dEpoch := h.dEpoch
  gEpoch := h.gEpoch
  xs := h.xs
  ss := h.ss
  y e he j hj := by
    show writeBytes (sh.bytes 4) (2 * nY) (wordBytes 2 (Val.bf16Bits (E.yv nY))) (2 * e + j) = _
    by_cases hen : e < nY
    · rw [writeBytes_outside _ _ _ _ (by rw [wordBytes_length]; omega)]; exact h.y e hen j hj
    · obtain rfl : e = nY := by omega
      rw [writeBytes_inside _ _ _ j (by rw [wordBytes_length]; omega)]
  log := forall_log _ 2 _ (fun j hj => owned_device E.L dev tgo ctx sh 4 (2 * nY + j) _ hS.r4 true (by simp)
    ⟨512 * ((2 * nY + j) / 128) + 32 * ((2 * nY + j) / 8 % 16), (2 * nY + j) / 128, 0⟩ (by simp [dev])
    (by rw [ht]; show _ = 512 * ((2 * nY + j) / 128) + 32 * ((2 * nY + j) / 8 % 16); omega)
    (by rw [hg]; show _ = (2 * nY + j) / 128; omega) (by rw [h.dEpoch])) h.log

/-- A barrier ordering threadgroup memory starts the next epoch. -/
theorem Mem.pass (h : Mem E ge PX PS nY sh) : Mem E (ge + 1) PX PS nY (pass false true sh) :=
  { h with
    dEpoch := by show sh.deviceEpoch = 0; exact h.dEpoch
    gEpoch := by show sh.groupEpoch + 1 = ge + 1; rw [h.gEpoch] }

/-- A threadgroup's start: its threadgroup arrays reset. -/
theorem Mem.reset (h : Mem E ge PX PS nY sh) (hb : E.L.buffers.length = 5) (garbage : Garbage) (g : Nat) :
    Mem E ge (fun _ => False) (fun _ => False) nY { sh with bytes := E.L.resetGroup garbage g sh.bytes } where
  regions := h.regions
  x := by show E.L.resetGroup garbage g sh.bytes 0 = _; rw [Launch.resetGroup_buffer _ _ _ _ 0 (by omega)]; exact h.x
  w := by show E.L.resetGroup garbage g sh.bytes 1 = _; rw [Launch.resetGroup_buffer _ _ _ _ 1 (by omega)]; exact h.w
  s := by show E.L.resetGroup garbage g sh.bytes 2 = _; rw [Launch.resetGroup_buffer _ _ _ _ 2 (by omega)]; exact h.s
  b := by show E.L.resetGroup garbage g sh.bytes 3 = _; rw [Launch.resetGroup_buffer _ _ _ _ 3 (by omega)]; exact h.b
  dEpoch := h.dEpoch
  gEpoch := h.gEpoch
  xs := fun _ h => h.elim
  ss := fun _ h => h.elim
  y e he j hj := by
    show E.L.resetGroup garbage g sh.bytes 4 _ = _
    rw [Launch.resetGroup_buffer _ _ _ _ 4 (by omega)]; exact h.y e he j hj
  log := h.log

end MemLemmas

/-- `E`'s values are the variant's: `xs[e]` the `x_thread` value `e % 16` of chunk `e / 16`, `ss[c]` chunk `c`'s sum,
`y[e]` the expected output. -/
structure Good (C : M1Max.Contract) (V : Variant) (steps : Nat) (E : Env) : Prop where
  xv : ∀ e, E.xv e = V.xt E.X (e / 16) (e % 16)
  sv : ∀ c, E.sv c = V.cs E.X c
  yv : ∀ e, E.yv e = yOf C V E.fuse steps E.X E.W E.S E.B e

/-! ## A thread -/

/-- Lane `i` of SIMD-group `s` of threadgroup `g`: thread `512 g + 32 s + i`. -/
structure Lane (ctx : Ctx) (g s i : Nat) : Prop where
  tg : ctx.coord .threadgroupPositionInGrid = u32x3 0 g 0
  lane : ctx.coord .threadIndexInSimdgroup = u32 i
  sg : ctx.coord .simdgroupIndexInThreadgroup = u32 s
  ga0 : ctx.groupArray 0 = 5
  ga1 : ctx.groupArray 1 = 6
  thread : ctx.thread = 512 * g + (32 * s + i)
  group : ctx.group = g
  ta0 : ctx.threadArray 0 = 2 * (512 * g + (32 * s + i)) + 7
  ta1 : ctx.threadArray 1 = 2 * (512 * g + (32 * s + i)) + 8
  hs : s < 16
  hi : i < 32

/-- The locals every phase reads and keeps (slots 0–8). -/
structure Locs (s i : Nat) (l : Locals) : Prop where
  x : l 0 = some (ptr 0)
  w : l 1 = some (.ptr ⟨1, 0, .scalar .u32⟩)
  sc : l 2 = some (ptr 2)
  bi : l 3 = some (ptr 3)
  y : l 4 = some (ptr 4)
  sg : l 5 = some (u32 s)
  lane : l 6 = some (u32 i)
  xs : l 7 = some (fptr 5)
  ss : l 8 = some (fptr 6)

theorem Locs.set {s i : Nat} {l : Locals} (h : Locs s i l) {slot : Nat} (v : Val) (hs : 8 < slot) :
    Locs s i (setLocal l slot v) :=
  ⟨by rw [setLocal_other _ _ (by omega)]; exact h.x, by rw [setLocal_other _ _ (by omega)]; exact h.w,
   by rw [setLocal_other _ _ (by omega)]; exact h.sc, by rw [setLocal_other _ _ (by omega)]; exact h.bi,
   by rw [setLocal_other _ _ (by omega)]; exact h.y, by rw [setLocal_other _ _ (by omega)]; exact h.sg,
   by rw [setLocal_other _ _ (by omega)]; exact h.lane, by rw [setLocal_other _ _ (by omega)]; exact h.xs,
   by rw [setLocal_other _ _ (by omega)]; exact h.ss⟩

theorem Locs.keep {s i : Nat} {l l' : Locals} (h : Locs s i l) (hk : ∀ j, j < 13 → l' j = l j) : Locs s i l' :=
  ⟨by rw [hk 0 (by omega)]; exact h.x, by rw [hk 1 (by omega)]; exact h.w, by rw [hk 2 (by omega)]; exact h.sc,
   by rw [hk 3 (by omega)]; exact h.bi, by rw [hk 4 (by omega)]; exact h.y, by rw [hk 5 (by omega)]; exact h.sg,
   by rw [hk 6 (by omega)]; exact h.lane, by rw [hk 7 (by omega)]; exact h.xs, by rw [hk 8 (by omega)]; exact h.ss⟩

/-! ### Before the barrier: the chunks of `x` -/

/-- `xs` elements written once threads below `n` and thread `n` up to element `m` have run (chunk `c` by thread
`c % 512`). -/
def PXn (steps n m e : Nat) : Prop := e < 512 * steps ∧ (e / 16 % 512 < n ∨ (e / 16 % 512 = n ∧ e < m))
def PSn (steps n m c : Nat) : Prop := c < 32 * steps ∧ (c % 512 < n ∨ (c % 512 = n ∧ c < m))

/-- Iterations of the chunk loop of thread `n`. -/
def nIter (steps n : Nat) : Nat := (32 * steps + 511 - n) / 512

theorem nIter_lt {steps n : Nat} (hn : n < 512) (j : Nat) : n + 512 * j < 32 * steps ↔ j < nIter steps n := by
  have hd : 32 * steps + 511 - n + n = 32 * steps + 511 := Nat.sub_add_cancel (by omega)
  unfold nIter; omega

theorem nIter_ge {steps n : Nat} (hn : n < 512) : 32 * steps ≤ n + 512 * nIter steps n := by
  have hd : 32 * steps + 511 - n + n = 32 * steps + 511 := Nat.sub_add_cancel (by omega)
  unfold nIter; omega

theorem nIter_le {steps n : Nat} (hn : n < 512) : n + 512 * nIter steps n < 32 * steps + 512 := by
  have hd : 32 * steps + 511 - n + n = 32 * steps + 511 := Nat.sub_add_cancel (by omega)
  unfold nIter; omega

def pre1 : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .bf16⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .u32⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .bf16⟩)),
   .set 3 (.lit (.ptr ⟨3, 0, .scalar .bf16⟩)),
   .set 4 (.lit (.ptr ⟨4, 0, .scalar .bf16⟩)),
   .set 5 (.coord .simdgroupIndexInThreadgroup),
   .set 6 (.coord .threadIndexInSimdgroup),
   .array 7 true 0 (.scalar .f32),
   .array 8 true 1 (.scalar .f32),
   .set 9 (.conv .i32 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 5) (u32l 32)) (.local 6)))]

def pre2 (bits steps : Nat) : List CStmt :=
  [.set 18 row0Expr,
   .set 19
     (.offset (.offset (.ptrCast (.scalar .u8) (.local 1)) (.bin .mul .i32 0 (.local 18) (i32l (64 * bits * steps))))
       (.bin .mul .u32 0 (.local 6) (u32l (2 * bits)))),
   .set 20 (.offset (.offset (.local 2) (.bin .mul .i32 0 (.local 18) (i32l (8 * steps)))) (.bin .div .u32 0 (.local 6) (u32l 4))),
   .set 21 (.offset (.offset (.local 3) (.bin .mul .i32 0 (.local 18) (i32l (8 * steps)))) (.bin .div .u32 0 (.local 6) (u32l 4))),
   .array 22 false 1 (.scalar .f32),
   .store (.scalar .f32) (.offset (.local 22) (i32l 0)) (f32l 0x0),
   .store (.scalar .f32) (.offset (.local 22) (i32l 1)) (f32l 0x0),
   .store (.scalar .f32) (.offset (.local 22) (i32l 2)) (f32l 0x0),
   .store (.scalar .f32) (.offset (.local 22) (i32l 3)) (f32l 0x0),
   .set 23 (i32l 0)]

/-- The code after the barrier. -/
def post1 (bits steps : Nat) (qd : CStmt) : List CStmt := pre2 bits steps ++ [stepLoop bits steps qd, .set 39 (i32l 0), outLoop]

theorem body_split (bits steps : Nat) (lv qd : CStmt) :
    body bits steps lv qd = (pre1 ++ [chunkLoop steps lv]) ++ .barrier 1 false true :: post1 bits steps qd := rfl

section Phase1
variable {C : M1Max.Contract} {V : Variant} {E : Env} {steps blocks ax aw as ab : Nat} {ctx : Ctx} {g s i : Nat}

/-- The copy loop's `k`-th test: `xs[16c + k']` written for `k' < k`. -/
def CopyI (E : Env) (V : Variant) (steps g n c tr : Nat) (k : Nat) (l : Locals) (sh : Shared) : Prop :=
  Locs (n / 32) (n % 32) l ∧ l 9 = some (.int .i32 c) ∧ l 10 = some (.ptr ⟨tr, 0, .scalar .f32⟩) ∧ l 17 = some (.int .i32 k) ∧
    Mem E g (PXn steps n (16 * c + k)) (PSn steps n (c + 1)) (64 * g) sh ∧
    ∀ j < 16, f32At (sh.bytes tr) j = V.xt E.X c j

theorem copy_loop (hS : Shape E.L V steps blocks ax aw as ab) (hG : Good C V steps E) (hl : Lane ctx g s i)
    (hK : 512 * steps + 512 < 2 ^ 31) (c : Nat) (hc : c < 32 * steps) (hcn : c % 512 = 32 * s + i)
    (l : Locals) (sh : Shared) (h0 : CopyI E V steps g (32 * s + i) c (2 * (512 * g + (32 * s + i)) + 7) 0 l sh) :
    ∃ l' sh', Exec C ctx [copyLoop] l sh .normal l' sh' ∧
      CopyI E V steps g (32 * s + i) c (2 * (512 * g + (32 * s + i)) + 7) 16 l' sh' := by
  have htr : 7 ≤ 2 * (512 * g + (32 * s + i)) + 7 := by omega
  refine Exec.loop_count 16 (CopyI E V steps g (32 * s + i) c _) (CopyI E V steps g (32 * s + i) c _)
    (fun k hk l sh hI => ⟨sh, eval_lt C hI.2.2.2.1 (by omega) (by omega) sh, hI⟩) (fun k hk l sh hI => ?_) h0
  obtain ⟨hloc, h9, h10, h17, hM, ht⟩ := hI
  have h7 := hloc.xs
  -- `xs[c * 16 + k] = t[k]`
  have hidx : (eval C ctx l (.bin .add .i32 0 (.bin .mul .i32 0 (.local 9) (i32l 16)) (.local 17))).run sh =
      some (.int .i32 (c * 16 + k), sh) :=
    eval_int C (by decide) (eval_int C (by decide) (eval_local' C h9 sh) (eval_lit C _ _ _ _)
      (binary_mul_i32 C c 16 (by omega) (by omega) (by omega))) (eval_local' C h17 sh)
      (binary_add_i32 C (c * 16) k (by omega))
  have hp := eval_ptr_i32 C (o := 0) (eval_local' C (ctx := ctx) h7 sh) hidx (by omega)
  rw [show 0 + (c * 16 + k) * (Ty.scalar .f32).bytes = 4 * (16 * c + k) by simp [Ty.bytes, Scalar.bytes]; ring] at hp
  have hq := eval_ptr_i32 C (o := 0) (eval_local' C (ctx := ctx) h10 sh) (eval_local' C h17 sh) (by omega)
  rw [show 0 + k * (Ty.scalar .f32).bytes = 4 * k by simp [Ty.bytes, Scalar.bytes]; ring] at hq
  have hld := load_f32_thread ctx sh (2 * (512 * g + (32 * s + i)) + 7) 64 k
    (by rw [hM.regions]; exact hS.rt (512 * g + (32 * s + i))) (by omega)
  rw [ht k hk] at hld
  have hv : V.xt E.X c k = E.xv (16 * c + k) := by
    rw [hG.xv, show (16 * c + k) / 16 = c by omega, show (16 * c + k) % 16 = k by omega]
  have hst := store_f32_group ctx sh 5 (2048 * steps) (16 * c + k) (V.xt E.X c k) (by rw [hM.regions]; exact hS.r5)
    (by omega)
  have hM' := hM.wxs hS ctx (16 * c + k) (by omega) (by rw [hl.thread]; omega) hl.group
  rw [← hv] at hM'
  refine ⟨.normal, l, _, _, _, .inl rfl, .store hp ((eval_load C _ _ (.scalar .f32) _ _ _ _ hq).trans hld) hst (.nil _ _),
    .set (eval_addi C h17 (by omega) _) (.nil _ _), ⟨?_, ?_, ?_, setLocal_same _ _ _, ?_, ?_⟩⟩
  · exact hloc.set _ (by omega)
  · rw [setLocal_other _ _ (by omega)]; exact h9
  · rw [setLocal_other _ _ (by omega)]; exact h10
  · exact hM'.mono (fun e he => by
      unfold PXn at he ⊢
      by_cases hee : e = 16 * c + k
      · exact .inr hee
      · exact .inl ⟨he.1, by omega⟩) (fun _ h => h) le_rfl
  · intro j hj
    rw [wr4_bytes_other _ _ _ _ (by omega)]
    exact ht j hj

/-- One chunk `c` of thread `c % 512`: `load_vector` into `t`, `ss[c]`, then `t` into `xs`. -/
theorem chunk_body (hV : LvSpec C V) (hS : Shape E.L V steps blocks ax aw as ab) (hG : Good C V steps E)
    (hl : Lane ctx g s i) (hK : 512 * steps + 512 < 2 ^ 31) (c : Nat) (hc : c < 32 * steps) (hcn : c % 512 = 32 * s + i)
    (l : Locals) (sh : Shared) (hloc : Locs s i l) (h9 : l 9 = some (.int .i32 c))
    (hM : Mem E g (PXn steps (32 * s + i) (16 * c)) (PSn steps (32 * s + i) c) (64 * g) sh) :
    ∃ l' sh', Exec C ctx (chunkBody V.lv) l sh .normal l' sh' ∧ Locs s i l' ∧ l' 9 = some (.int .i32 c) ∧
      Mem E g (PXn steps (32 * s + i) (16 * (c + 1))) (PSn steps (32 * s + i) (c + 1)) (64 * g) sh' := by
  have hsi := hl.hi; have hss := hl.hs
  -- `t`, `x + c * 16`
  generalize hl₁ : setLocal l 10 (.ptr ⟨2 * (512 * g + (32 * s + i)) + 7, 0, .scalar .f32⟩) = l₁
  have hloc₁ : Locs s i l₁ := by rw [← hl₁]; exact hloc.set _ (by omega)
  have g9₁ : l₁ 9 = some (.int .i32 c) := by rw [← hl₁, setLocal_other _ _ (by omega)]; exact h9
  have hmul : (eval C ctx l₁ (.bin .mul .i32 0 (.local 9) (i32l 16))).run sh = some (.int .i32 (c * 16), sh) :=
    eval_int C (by decide) (eval_local' C g9₁ sh) (eval_lit C _ _ _ _) (binary_mul_i32 C c 16 (by omega) (by omega) (by omega))
  have hp11 := eval_ptr_i32 C (o := 0) (eval_local' C hloc₁.x sh) hmul (by omega)
  rw [show 0 + c * 16 * (Ty.scalar .bf16).bytes = 32 * c by simp [Ty.bytes, Scalar.bytes]; ring] at hp11
  generalize hl₃ : setLocal (setLocal l₁ 11 (.ptr ⟨0, ((32 * c : Nat) : Int), .scalar .bf16⟩)) 12
    (.ptr ⟨2 * (512 * g + (32 * s + i)) + 7, 0, .scalar .f32⟩) = l₃
  have hpre : Exec C ctx [.array 10 false 0 (.scalar .f32), .set 11 (.offset (.local 0) (.bin .mul .i32 0 (.local 9) (i32l 16))),
      .set 12 (.local 10)] l sh .normal l₃ sh := by
    rw [← hl₃]
    refine .array ?_
    rw [show (if false = true then ctx.groupArray 0 else ctx.threadArray 0) = 2 * (512 * g + (32 * s + i)) + 7 from hl.ta0,
      hl₁]
    exact .set hp11 (.set (eval_local' C (by rw [setLocal_other _ _ (by omega), ← hl₁]; exact setLocal_same _ _ _) _) (.nil _ _))
  have g11 : l₃ 11 = some (.ptr ⟨0, ((32 * c : Nat) : Int), .scalar .bf16⟩) := by
    rw [← hl₃, setLocal_other _ _ (by omega)]; exact setLocal_same _ _ _
  have g12 : l₃ 12 = some (.ptr ⟨2 * (512 * g + (32 * s + i)) + 7, 0, .scalar .f32⟩) := by rw [← hl₃]; exact setLocal_same _ _ _
  -- `load_vector`
  obtain ⟨l₄, sh₄, hlv, hF, hkeep, h13, ht⟩ := hV ctx l₃ sh c (2 * (512 * g + (32 * s + i)) + 7) (1024 * steps) ax
    (by rw [hM.regions]; exact hS.r0) hS.ax (by omega) (by rw [hM.regions]; exact hS.rt _) (by omega) g11 g12
  have hM₄ := hM.frame hS ctx hF (fun r hr => .inl (by simp only [isR] at hr; omega))
    (fun r hr => by simp only [isR] at hr; omega)
  rw [hM.x] at h13 ht
  rw [← hG.sv] at h13
  have hloc₃ : Locs s i l₃ := by rw [← hl₃]; exact (hloc₁.set _ (by omega)).set _ (by omega)
  have hloc₄ : Locs s i l₄ := hloc₃.keep (fun j hj => hkeep j (by omega))
  have g9₄ : l₄ 9 = some (.int .i32 c) := by
    rw [hkeep 9 (by omega), ← hl₃, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega)]; exact g9₁
  have g10₄ : l₄ 10 = some (.ptr ⟨2 * (512 * g + (32 * s + i)) + 7, 0, .scalar .f32⟩) := by
    rw [hkeep 10 (by omega), ← hl₃, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), ← hl₁]
    exact setLocal_same _ _ _
  -- `ss[c]`
  have hp6 := eval_ptr_i32 C (o := 0) (eval_local' C (ctx := ctx) hloc₄.ss sh₄) (eval_local' C g9₄ sh₄) (by omega)
  rw [show 0 + c * (Ty.scalar .f32).bytes = 4 * c by simp [Ty.bytes, Scalar.bytes]; ring] at hp6
  have hst := store_f32_group ctx sh₄ 6 (128 * steps) c (E.sv c) (by rw [hM₄.regions]; exact hS.r6) (by omega)
  have hM₅ := hM₄.wss hS ctx c (by rw [hl.thread]; omega) hl.group
  -- the copy
  have hc0 : CopyI E V steps g (32 * s + i) c (2 * (512 * g + (32 * s + i)) + 7) 0 (setLocal l₄ 17 (.int .i32 0))
      (wr4 ctx sh₄ 6 (4 * c) (E.sv c)) := by
    refine ⟨by rw [show (32 * s + i) / 32 = s by omega, show (32 * s + i) % 32 = i by omega]; exact hloc₄.set _ (by omega), by rw [setLocal_other _ _ (by omega)]; exact g9₄,
      by rw [setLocal_other _ _ (by omega)]; exact g10₄, setLocal_same _ _ _, ?_, ?_⟩
    · exact hM₅.mono (fun e he => by unfold PXn at he ⊢; omega) (fun c' hc' => by
        unfold PSn at hc' ⊢
        by_cases hcc : c' = c
        · exact .inr hcc
        · exact .inl ⟨hc'.1, by omega⟩) le_rfl
    · intro j hj; rw [wr4_bytes_other _ _ _ _ (by omega)]; exact ht j hj
  obtain ⟨l₇, sh₇, hcopy, hloc₇, h9', _, _, hM₇, _⟩ := copy_loop hS hG hl hK c hc hcn _ _ hc0
  rw [show (32 * s + i) / 32 = s by omega, show (32 * s + i) % 32 = i by omega] at hloc₇
  refine ⟨l₇, sh₇, ?_, hloc₇, h9', by rw [show 16 * (c + 1) = 16 * c + 16 by ring]; exact hM₇⟩
  · exact (Exec.append hpre (Exec.append hlv (.store hp6 (eval_local' C h13 _) hst
      (.set (eval_lit C _ _ _ _) hcopy))) : Exec C ctx ([_, _, _] ++ ([V.lv] ++ [_, _, _])) _ _ _ _ _)

/-- The chunk loop's `j`-th test. -/
def ChunkI (E : Env) (steps g s i : Nat) (j : Nat) (l : Locals) (sh : Shared) : Prop :=
  Locs s i l ∧ l 9 = some (.int .i32 (32 * s + i + 512 * j)) ∧
    Mem E g (PXn steps (32 * s + i) (16 * (32 * s + i + 512 * j))) (PSn steps (32 * s + i) (32 * s + i + 512 * j)) (64 * g) sh

/-- A thread's chunks `32s + i + 512j` below `K / 16`. -/
theorem chunk_loop (hV : LvSpec C V) (hS : Shape E.L V steps blocks ax aw as ab) (hG : Good C V steps E)
    (hl : Lane ctx g s i) (hK : 512 * steps + 512 < 2 ^ 31) (l : Locals) (sh : Shared) (h0 : ChunkI E steps g s i 0 l sh) :
    ∃ l' sh', Exec C ctx [chunkLoop steps V.lv] l sh .normal l' sh' ∧ Locs s i l' ∧
      Mem E g (PXn steps (32 * s + i + 1) (16 * (32 * s + i + 1))) (PSn steps (32 * s + i + 1) (32 * s + i + 1)) (64 * g) sh' := by
  have hsi := hl.hi; have hss := hl.hs
  have hn : 32 * s + i < 512 := by omega
  have hle := nIter_le (steps := steps) hn
  have hge := nIter_ge (steps := steps) hn
  obtain ⟨l', sh', hex, hloc, _, hM⟩ := Exec.loop_count (nIter steps (32 * s + i)) (ChunkI E steps g s i)
    (ChunkI E steps g s i)
    (fun j hj l sh hI => ⟨sh, by
      have hjn : 32 * s + i + 512 * j < 2 ^ 31 := by
        have : 512 * j ≤ 512 * nIter steps (32 * s + i) := Nat.mul_le_mul_left _ hj
        omega
      rw [eval_lt C (ctx := ctx) (n := 32 * steps) hI.2.1 hjn (by omega) sh]
      exact congrArg (fun b => some (Val.bool b, sh)) (decide_eq_decide.mpr (nIter_lt (steps := steps) hn j)), hI⟩)
    (fun j hj l sh hI => by
      obtain ⟨hloc, h9, hM⟩ := hI
      have hc : 32 * s + i + 512 * j < 32 * steps := (nIter_lt (steps := steps) hn j).mpr hj
      have hcn : (32 * s + i + 512 * j) % 512 = 32 * s + i := by omega
      obtain ⟨l₁, sh₁, hb, hloc₁, h9₁, hM₁⟩ := chunk_body hV hS hG hl hK (32 * s + i + 512 * j) hc hcn l sh hloc h9 hM
      refine ⟨.normal, l₁, sh₁, _, _, .inl rfl, hb, .set (eval_addi C (k := 512) h9₁ (by omega) _) (.nil _ _),
        hloc₁.set (slot := 9) _ (by omega), by rw [setLocal_same, show 32 * s + i + 512 * j + 512 = 32 * s + i + 512 * (j + 1) by ring], ?_⟩
      exact hM₁.mono (fun e he => by unfold PXn at he ⊢; omega) (fun c hc => by unfold PSn at hc ⊢; omega) le_rfl) h0
  refine ⟨l', sh', hex, hloc, hM.mono (fun e he => by unfold PXn at he ⊢; omega)
    (fun c hc => by unfold PSn at hc ⊢; omega) le_rfl⟩

/-- A thread's declarations and chunk loop, to the barrier. -/
theorem lane_phase1 (hV : LvSpec C V) (hS : Shape E.L V steps blocks ax aw as ab) (hG : Good C V steps E)
    (hl : Lane ctx g s i) (hK : 512 * steps + 512 < 2 ^ 31) (sh : Shared)
    (hM : Mem E g (PXn steps (32 * s + i) (16 * (32 * s + i))) (PSn steps (32 * s + i) (32 * s + i)) (64 * g) sh) :
    ∃ l sh', (∃ m0, ∀ m, m0 ≤ m → (runThread C m ⟨ctx, fun _ => none, [.block (body V.bits steps V.lv V.qd)], .running⟩).run sh =
      some (⟨ctx, l, [.block (post1 V.bits steps V.qd)], .barrier 1 false true⟩, sh')) ∧ Locs s i l ∧
      Mem E g (PXn steps (32 * s + i + 1) (16 * (32 * s + i + 1))) (PSn steps (32 * s + i + 1) (32 * s + i + 1)) (64 * g) sh' := by
  have hsi := hl.hi; have hss := hl.hs
  generalize hl₀ : setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (setLocal (fun _ => none : Locals) 0 (ptr 0))
    1 (.ptr ⟨1, 0, .scalar .u32⟩)) 2 (ptr 2)) 3 (ptr 3)) 4 (ptr 4)) 5 (u32 s)) 6 (u32 i)) 7 (fptr 5)) 8 (fptr 6) = l₀
  have hloc₀ : Locs s i l₀ := by
    rw [← hl₀]; exact ⟨by simp [setLocal], by simp [setLocal], by simp [setLocal], by simp [setLocal], by simp [setLocal],
      by simp [setLocal], by simp [setLocal], by simp [setLocal], by simp [setLocal]⟩
  have h9 : (eval C ctx l₀ (.conv .i32 (.bin .add .u32 0 (.bin .mul .u32 0 (.local 5) (u32l 32)) (.local 6)))).run sh =
      some (.int .i32 (32 * s + i), sh) := by
    rw [show 32 * s + i = s * 32 + i by ring]
    exact eval_conv C (eval_int C (by decide) (eval_int C (by decide) (eval_local' C hloc₀.sg sh)
      (eval_lit C _ _ _ _) (binary_mul_u32 C s 32)) (eval_local' C hloc₀.lane sh) (binary_add_u32 C (s * 32) i))
      (convert_i32_u32 C (s * 32 + i) (by omega))
  have hpre : Exec C ctx pre1 (fun _ => none) sh .normal (setLocal l₀ 9 (.int .i32 (32 * s + i))) sh := by
    rw [← hl₀] at h9 ⊢
    refine .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <|
      .set (eval_lit C _ _ _ _) <| .set (eval_lit C _ _ _ _) <| .set (eval_coord C _ _ _ _) <|
      .set (eval_coord C _ _ _ _) <| .array <| .array <| ?_
    rw [hl.sg, hl.lane, show (if true = true then ctx.groupArray 0 else ctx.threadArray 0) = 5 from hl.ga0,
      show (if true = true then ctx.groupArray 1 else ctx.threadArray 1) = 6 from hl.ga1]
    exact .set h9 (.nil _ _)
  obtain ⟨l₁, sh₁, hloop, hloc₁, hM₁⟩ := chunk_loop hV hS hG hl hK _ sh
    ⟨hloc₀.set (slot := 9) (.int .i32 (32 * s + i)) (by omega), by simp [setLocal], by simpa using hM⟩
  refine ⟨l₁, sh₁, ?_, hloc₁, hM₁⟩
  rw [body_split]
  exact (Exec.reaches_barrier (K := []) (hpre.append hloop)).run rfl

end Phase1

/-! ### After the barrier: the K loop -/

/-- The first of the SIMD-group's four rows. -/
def row0 (g s : Nat) : Nat := 4 * (16 * g + s)

/-- Bounds of the K loop's offsets: row `row` of the weights (ROWB = 64·bits·steps bytes), the lane's bytes at step
`t`, its scale index, and the `int` products. -/
theorem row_bounds {Bt steps blocks row t L : Nat} (hrow : row < 64 * blocks) (ht : t < steps) (hL : L < 32)
    (hB : 0 < Bt) (hW : 64 * blocks * (64 * Bt * steps) < 2 ^ 31) :
    row * (64 * Bt * steps) + 2 * Bt * L + 64 * Bt * t + 2 * Bt ≤ 64 * blocks * (64 * Bt * steps) ∧
    row * (8 * steps) + 8 * t + L / 4 < 64 * blocks * (8 * steps) ∧
    row * (64 * Bt * steps) < 2 ^ 31 ∧ row * (8 * steps) < 2 ^ 31 := by
  have h1 : 2 * Bt * L + 2 * Bt ≤ 64 * Bt := by nlinarith
  have h2 : 64 * Bt * t + 64 * Bt ≤ 64 * Bt * steps := by nlinarith
  have h3 : (row + 1) * (64 * Bt * steps) ≤ 64 * blocks * (64 * Bt * steps) := Nat.mul_le_mul_right _ (by omega)
  have h4 : (row + 1) * (8 * steps) ≤ 64 * blocks * (8 * steps) := Nat.mul_le_mul_right _ (by omega)
  have h5 : 8 * steps ≤ 64 * Bt * steps := by nlinarith
  have h6 : 64 * blocks * (8 * steps) ≤ 64 * blocks * (64 * Bt * steps) := Nat.mul_le_mul_left _ h5
  have h7 : 8 * t + 8 ≤ 8 * steps := by omega
  have h8 : L / 4 < 8 := by omega
  refine ⟨by nlinarith, by nlinarith, by nlinarith, by nlinarith⟩

/-- Regions read after the barrier: w, scales, biases, xs, ss. -/
def rdR (r : Nat) : Prop := r = 1 ∨ r = 2 ∨ r = 3 ∨ r = 5 ∨ r = 6

/-- Thread `512g + 32s + i`'s `t` and `result` arrays. -/
def tR (g s i : Nat) : Nat := 2 * (512 * g + (32 * s + i)) + 7
def resR (g s i : Nat) : Nat := 2 * (512 * g + (32 * s + i)) + 8

/-- The locals of the K loop at step `t`. -/
structure KLocs (V : Variant) (steps g s i t : Nat) (l : Locals) : Prop where
  locs : Locs s i l
  r0 : l 18 = some (.int .i32 (row0 g s))
  ws : l 19 = some (.ptr ⟨1, ((row0 g s * (64 * V.bits * steps) + 2 * V.bits * i + 64 * V.bits * t : Nat) : Int), .scalar .u8⟩)
  sc : l 20 = some (.ptr ⟨2, ((2 * (row0 g s * (8 * steps) + 8 * t + i / 4) : Nat) : Int), .scalar .bf16⟩)
  bi : l 21 = some (.ptr ⟨3, ((2 * (row0 g s * (8 * steps) + 8 * t + i / 4) : Nat) : Int), .scalar .bf16⟩)
  res : l 22 = some (.ptr ⟨resR g s i, 0, .scalar .f32⟩)
  k : l 23 = some (.int .i32 (512 * t))

theorem KLocs.keep {V : Variant} {steps g s i t : Nat} {l l' : Locals} (h : KLocs V steps g s i t l)
    (hk : ∀ j, j < 24 → l' j = l j) : KLocs V steps g s i t l' :=
  ⟨h.locs.keep (fun j hj => hk j (by omega)), by rw [hk 18 (by omega)]; exact h.r0, by rw [hk 19 (by omega)]; exact h.ws,
   by rw [hk 20 (by omega)]; exact h.sc, by rw [hk 21 (by omega)]; exact h.bi, by rw [hk 22 (by omega)]; exact h.res,
   by rw [hk 23 (by omega)]; exact h.k⟩

section Phase2
variable {C : M1Max.Contract} {V : Variant} {E : Env} {steps blocks ax aw as ab nY : Nat} {ctx : Ctx} {g s i : Nat}

/-- One row `r` of a K step `t`: its scale and bias, `qdot`, and `result[r] += …`. -/
theorem row_body (hQ : QdSpec C V) (hS : Shape E.L V steps blocks ax aw as ab) (hG : Good C V steps E)
    (hl : Lane ctx g s i) (hfz : ctx.fuse = E.fuse) (hg : g < blocks) (hB : 0 < V.bits) (hWa : V.wAlign ∣ 2)
    (hW : 64 * blocks * (64 * V.bits * steps) < 2 ^ 31) (t r : Nat) (ht : t < steps) (hr : r < 4) (sh0 : Shared)
    (hM : Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) nY sh0)
    (l : Locals) (sh : Shared) (hF : Footprint ctx rdR (isR (resR g s i)) sh0 sh) (hkl : KLocs V steps g s i t l)
    (h24 : l 24 = some (.f32 (V.cs E.X (32 * t + i))))
    (h25 : l 25 = some (.ptr ⟨5, ((4 * (16 * (32 * t + i)) : Nat) : Int), .scalar .f32⟩)) (h26 : l 26 = some (.int .i32 r)) :
    ∃ l' sh', Exec C ctx (rowBody V.bits steps V.qd) l sh .normal l' sh' ∧ Footprint ctx rdR (isR (resR g s i)) sh0 sh' ∧
      (∀ j, j < 27 → l' j = l j) ∧
      (∀ r', r' ≠ r → f32At (sh'.bytes (resR g s i)) r' = f32At (sh.bytes (resR g s i)) r') ∧
      f32At (sh'.bytes (resR g s i)) r = C.fadd (f32At (sh.bytes (resR g s i)) r)
        (V.qv E.fuse E.W ((row0 g s + r) * (64 * V.bits * steps) + 2 * V.bits * i + 64 * V.bits * t) (V.xt E.X (32 * t + i))
          (C.widen (bfAt E.S ((row0 g s + r) * (8 * steps) + 8 * t + i / 4)))
          (C.widen (bfAt E.B ((row0 g s + r) * (8 * steps) + 8 * t + i / 4))) (V.cs E.X (32 * t + i))) := by
  have hsi := hl.hi; have hss := hl.hs
  have hrow : row0 g s + r < 64 * blocks := by unfold row0; omega
  obtain ⟨bw, bsc, -, -⟩ := row_bounds hrow ht hsi hB hW
  have hreg : sh.regions = E.L.regions := hF.regions.trans hM.regions
  have hby : ∀ q, q ≠ resR g s i → sh.bytes q = sh0.bytes q := fun q hq => hF.bytes q hq
  have hsteps : 4096 * steps ≤ 64 * blocks * (64 * V.bits * steps) := by
    have h1 : 64 * 1 ≤ 64 * blocks := by omega
    have h2 : 64 * 1 * steps ≤ 64 * V.bits * steps := Nat.mul_le_mul_right _ (by omega)
    calc 4096 * steps = (64 * 1) * (64 * 1 * steps) := by ring
      _ ≤ 64 * blocks * (64 * V.bits * steps) := Nat.mul_le_mul h1 h2
  have hX : 64 * V.bits * steps ≤ 64 * blocks * (64 * V.bits * steps) := Nat.le_mul_of_pos_left _ (by omega)
  have hrG : r * (8 * steps) < 2 ^ 31 := by
    have : r * (8 * steps) ≤ 3 * (8 * steps) := Nat.mul_le_mul_right _ (by omega)
    omega
  have hrR : r * (64 * V.bits * steps) < 2 ^ 31 := by
    have h1 : r * (64 * V.bits * steps) ≤ 3 * (64 * V.bits * steps) := Nat.mul_le_mul_right _ (by omega)
    have h2 : 3 * (64 * V.bits * steps) ≤ 64 * blocks * (64 * V.bits * steps) := Nat.mul_le_mul_right _ (by omega)
    omega
  -- `s` and `b`
  have hmG : (eval C ctx l (.bin .mul .i32 0 (.local 26) (i32l (8 * steps)))).run sh = some (.int .i32 (r * (8 * steps)), sh) :=
    eval_int C (by decide) (eval_local' C h26 sh) (eval_lit C _ _ _ _) (binary_mul_i32 C r _ hrG (by omega) (by omega))
  have hidx : 2 * (row0 g s * (8 * steps) + 8 * t + i / 4) + r * (8 * steps) * (Ty.scalar .bf16).bytes =
      2 * ((row0 g s + r) * (8 * steps) + 8 * t + i / 4) := by simp [Ty.bytes, Scalar.bytes]; ring
  have hp20 := eval_ptr_i32 C (eval_local' C hkl.sc sh) hmG hrG
  rw [hidx] at hp20
  have hls := load_bf16 ctx sh 2 _ as ((row0 g s + r) * (8 * steps) + 8 * t + i / 4) (by rw [hreg]; exact hS.r2) hS.as
    (by omega)
  rw [hby 2 (by unfold resR; omega), hM.s] at hls
  have hS27 : (eval C ctx l (.conv .f32 (.load (.scalar .bf16) (.offset (.local 20)
      (.bin .mul .i32 0 (.local 26) (i32l (8 * steps))))))).run sh =
      some (.f32 (C.widen (bfAt E.S ((row0 g s + r) * (8 * steps) + 8 * t + i / 4))),
        rd ctx sh 2 (2 * ((row0 g s + r) * (8 * steps) + 8 * t + i / 4))) :=
    eval_conv C ((eval_load C _ _ _ _ _ _ _ hp20).trans hls) rfl
  generalize hsh₁ : rd ctx sh 2 (2 * ((row0 g s + r) * (8 * steps) + 8 * t + i / 4)) = sh₁ at hS27
  have hF₁ : Footprint ctx rdR (isR (resR g s i)) sh0 sh₁ := by
    rw [← hsh₁, rd_eq]; exact hF.trans (Footprint.rdn _ _ _ _ (by simp [rdR]))
  have hreg₁ : sh₁.regions = E.L.regions := hF₁.regions.trans hM.regions
  generalize hl₁ : setLocal l 27 (.f32 (C.widen (bfAt E.S ((row0 g s + r) * (8 * steps) + 8 * t + i / 4)))) = l₁
  have k₁ : ∀ j, j < 27 → l₁ j = l j := fun j hj => by rw [← hl₁, setLocal_other _ _ (by omega)]
  have hmG₁ : (eval C ctx l₁ (.bin .mul .i32 0 (.local 26) (i32l (8 * steps)))).run sh₁ =
      some (.int .i32 (r * (8 * steps)), sh₁) :=
    eval_int C (by decide) (eval_local' C (by rw [k₁ 26 (by omega)]; exact h26) sh₁) (eval_lit C _ _ _ _)
      (binary_mul_i32 C r _ hrG (by omega) (by omega))
  have hp21 := eval_ptr_i32 C (eval_local' C (by rw [k₁ 21 (by omega)]; exact hkl.bi) sh₁) hmG₁ hrG
  rw [hidx] at hp21
  have hlb := load_bf16 ctx sh₁ 3 _ ab ((row0 g s + r) * (8 * steps) + 8 * t + i / 4) (by rw [hreg₁]; exact hS.r3) hS.ab
    (by omega)
  rw [hF₁.bytes 3 (by unfold isR resR; omega), hM.b] at hlb
  have hB28 : (eval C ctx l₁ (.conv .f32 (.load (.scalar .bf16) (.offset (.local 21)
      (.bin .mul .i32 0 (.local 26) (i32l (8 * steps))))))).run sh₁ =
      some (.f32 (C.widen (bfAt E.B ((row0 g s + r) * (8 * steps) + 8 * t + i / 4))),
        rd ctx sh₁ 3 (2 * ((row0 g s + r) * (8 * steps) + 8 * t + i / 4))) :=
    eval_conv C ((eval_load C _ _ _ _ _ _ _ hp21).trans hlb) rfl
  generalize hsh₂ : rd ctx sh₁ 3 (2 * ((row0 g s + r) * (8 * steps) + 8 * t + i / 4)) = sh₂ at hB28
  have hF₂ : Footprint ctx rdR (isR (resR g s i)) sh0 sh₂ := by
    rw [← hsh₂, rd_eq]; exact hF₁.trans (Footprint.rdn _ _ _ _ (by simp [rdR]))
  generalize hl₂ : setLocal l₁ 28 (.f32 (C.widen (bfAt E.B ((row0 g s + r) * (8 * steps) + 8 * t + i / 4)))) = l₂
  have k₂ : ∀ j, j < 27 → l₂ j = l j := fun j hj => by rw [← hl₂, setLocal_other _ _ (by omega), k₁ j hj]
  -- `ws + r * ROWB`
  have hmR : (eval C ctx l₂ (.bin .mul .i32 0 (.local 26) (i32l (64 * V.bits * steps)))).run sh₂ =
      some (.int .i32 (r * (64 * V.bits * steps)), sh₂) :=
    eval_int C (by decide) (eval_local' C (by rw [k₂ 26 (by omega)]; exact h26) sh₂) (eval_lit C _ _ _ _)
      (binary_mul_i32 C r _ hrR (by omega) (by omega))
  have hp29 := eval_ptr_i32 C (eval_local' C (by rw [k₂ 19 (by omega)]; exact hkl.ws) sh₂) hmR hrR
  rw [show row0 g s * (64 * V.bits * steps) + 2 * V.bits * i + 64 * V.bits * t + r * (64 * V.bits * steps) *
      (Ty.scalar .u8).bytes = (row0 g s + r) * (64 * V.bits * steps) + 2 * V.bits * i + 64 * V.bits * t by
      simp [Ty.bytes, Scalar.bytes]; ring] at hp29
  generalize hwo : (row0 g s + r) * (64 * V.bits * steps) + 2 * V.bits * i + 64 * V.bits * t = wo at hp29 bw
  generalize hl₃ : setLocal (setLocal (setLocal (setLocal (setLocal l₂ 29 (.ptr ⟨1, ((wo : Nat) : Int), .scalar .u8⟩)) 30
    (.ptr ⟨5, ((4 * (16 * (32 * t + i)) : Nat) : Int), .scalar .f32⟩)) 31
    (.f32 (C.widen (bfAt E.S ((row0 g s + r) * (8 * steps) + 8 * t + i / 4))))) 32
    (.f32 (C.widen (bfAt E.B ((row0 g s + r) * (8 * steps) + 8 * t + i / 4))))) 33 (.f32 (V.cs E.X (32 * t + i))) = l₃
  have hsets : Exec C ctx [.set 27 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 20)
      (.bin .mul .i32 0 (.local 26) (i32l (8 * steps)))))),
      .set 28 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 21) (.bin .mul .i32 0 (.local 26) (i32l (8 * steps)))))),
      .set 29 (.offset (.local 19) (.bin .mul .i32 0 (.local 26) (i32l (64 * V.bits * steps)))),
      .set 30 (.local 25), .set 31 (.local 27), .set 32 (.local 28), .set 33 (.local 24)] l sh .normal l₃ sh₂ := by
    subst hl₃ hl₂ hl₁
    exact .set hS27 (.set hB28 (.set hp29 (.set (eval_local' C (by simp [setLocal, h25]) _)
      (.set (eval_local' C (by simp [setLocal]) _) (.set (eval_local' C (by simp [setLocal]) _)
        (.set (eval_local' C (by simp [setLocal, h24]) _) (.nil _ _)))))))
  have k₃ : ∀ j, j < 27 → l₃ j = l j := fun j hj => by
    rw [← hl₃, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), setLocal_other _ _ (by omega),
      setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), k₂ j hj]
  -- `qdot`
  have hwa : wo % V.wAlign = 0 := by
    apply Nat.mod_eq_zero_of_dvd
    refine Nat.dvd_trans hWa ⟨(row0 g s + r) * (32 * V.bits * steps) + V.bits * i + 32 * V.bits * t, ?_⟩
    rw [← hwo]; ring
  have hreg₂ : sh₂.regions = E.L.regions := hF₂.regions.trans hM.regions
  obtain ⟨l₄, sh₃, hqd, hFq, kq, h34⟩ := hQ ctx l₃ sh₂ wo (16 * (32 * t + i)) _ (2048 * steps) aw (V.xt E.X (32 * t + i))
    (C.widen (bfAt E.S ((row0 g s + r) * (8 * steps) + 8 * t + i / 4)))
    (C.widen (bfAt E.B ((row0 g s + r) * (8 * steps) + 8 * t + i / 4))) (V.cs E.X (32 * t + i)) (by rw [hreg₂]; exact hS.r1) hS.aw hwa (by omega) (by rw [hreg₂]; exact hS.r5) (by omega)
    (fun j hj => by
      rw [hF₂.bytes 5 (by unfold isR resR; omega), hM.xs _ (by omega), hG.xv,
        show (16 * (32 * t + i) + j) / 16 = 32 * t + i by omega, show (16 * (32 * t + i) + j) % 16 = j by omega])
    (by rw [← hl₃]; simp [setLocal]) (by rw [← hl₃]; simp [setLocal]) (by rw [← hl₃]; simp [setLocal])
    (by rw [← hl₃]; simp [setLocal]) (by rw [← hl₃]; simp [setLocal])
  rw [hF₂.bytes 1 (by unfold isR resR; omega), hM.w, hfz] at h34
  have hF₃ : Footprint ctx rdR (isR (resR g s i)) sh0 sh₃ :=
    hF₂.trans (hFq.mono (fun q hq => by rcases hq with rfl | rfl <;> simp [rdR]) (fun _ h => h.elim))
  -- `result[r] += …`
  have k₄ : ∀ j, j < 27 → l₄ j = l j := fun j hj => by rw [kq j (.inl (by omega)), k₃ j hj]
  have g22 : l₄ 22 = some (.ptr ⟨resR g s i, 0, .scalar .f32⟩) := by rw [k₄ 22 (by omega)]; exact hkl.res
  have g26 : l₄ 26 = some (.int .i32 r) := by rw [k₄ 26 (by omega)]; exact h26
  have hp := eval_ptr_i32 C (o := 0) (eval_local' C (ctx := ctx) g22 sh₃) (eval_local' C g26 sh₃) (by omega)
  rw [show 0 + r * (Ty.scalar .f32).bytes = 4 * r by simp [Ty.bytes, Scalar.bytes]; ring] at hp
  have hreg₃ : sh₃.regions = E.L.regions := hF₃.regions.trans hM.regions
  have hrr : sh₃.regions (resR g s i) = some ⟨.thread, 16, 4⟩ := by rw [hreg₃]; exact hS.rr _
  have hld := load_f32_thread ctx sh₃ (resR g s i) 16 r hrr (by omega)
  have hb3 : sh₃.bytes = sh.bytes := by rw [hFq.bytes_eq, ← hsh₂, ← hsh₁]; rfl
  rw [hb3] at hld
  have hv : (eval C ctx l₄ (.bin .add .f32 0 (.load (.scalar .f32) (.offset (.local 22) (.local 26))) (.local 34))).run sh₃ =
      some (.f32 (C.fadd (f32At (sh.bytes (resR g s i)) r) (V.qv E.fuse E.W wo (V.xt E.X (32 * t + i))
        (C.widen (bfAt E.S ((row0 g s + r) * (8 * steps) + 8 * t + i / 4)))
        (C.widen (bfAt E.B ((row0 g s + r) * (8 * steps) + 8 * t + i / 4))) (V.cs E.X (32 * t + i)))), sh₃) :=
    eval_f32 C (.inr ⟨rfl, rfl⟩) ((eval_load C _ _ (.scalar .f32) _ _ _ _ hp).trans hld) (eval_local' C h34 _) rfl
  generalize hyv : C.fadd (f32At (sh.bytes (resR g s i)) r) (V.qv E.fuse E.W wo (V.xt E.X (32 * t + i))
    (C.widen (bfAt E.S ((row0 g s + r) * (8 * steps) + 8 * t + i / 4)))
    (C.widen (bfAt E.B ((row0 g s + r) * (8 * steps) + 8 * t + i / 4))) (V.cs E.X (32 * t + i))) = yv at hv
  have hst := store_f32_thread ctx sh₃ (resR g s i) 16 r yv hrr (by omega)
  refine ⟨l₄, wrT sh₃ (resR g s i) (4 * r) yv, ?_, hF₃.trans (Footprint.wrT _ _ _ _ rfl), k₄, fun r' hr' => ?_, ?_⟩
  · exact (Exec.append hsets (Exec.append hqd (.store hp hv hst (.nil _ _))) :
      Exec C ctx ([_, _, _, _, _, _, _] ++ ([V.qd] ++ [_])) _ _ _ _ _)
  · rw [wrT_bytes_same, f32At_write_other _ _ hr', hb3]
  · rw [wrT_bytes_same, f32At_write_same, ← hyv, ← hwo]

/-- `acc` in `E`'s terms. -/
abbrev accE (C : M1Max.Contract) (V : Variant) (steps : Nat) (E : Env) (row L t : Nat) : Float32 :=
  acc C V E.fuse steps E.X E.W E.S E.B row L t

/-- The row loop's `r`-th test in K step `t`: rows below `r` updated. -/
def RowI (C : M1Max.Contract) (V : Variant) (E : Env) (steps g s i t : Nat) (sh0 : Shared) (ctx : Ctx) (r : Nat)
    (l : Locals) (sh : Shared) : Prop :=
  KLocs V steps g s i t l ∧ l 24 = some (.f32 (V.cs E.X (32 * t + i))) ∧
    l 25 = some (.ptr ⟨5, ((4 * (16 * (32 * t + i)) : Nat) : Int), .scalar .f32⟩) ∧ l 26 = some (.int .i32 r) ∧
    Footprint ctx rdR (isR (resR g s i)) sh0 sh ∧
    ∀ r' < 4, f32At (sh.bytes (resR g s i)) r' = accE C V steps E (row0 g s + r') i (if r' < r then t + 1 else t)

theorem row_loop (hQ : QdSpec C V) (hS : Shape E.L V steps blocks ax aw as ab) (hG : Good C V steps E)
    (hl : Lane ctx g s i) (hfz : ctx.fuse = E.fuse) (hg : g < blocks) (hB : 0 < V.bits) (hWa : V.wAlign ∣ 2)
    (hW : 64 * blocks * (64 * V.bits * steps) < 2 ^ 31) (t : Nat) (ht : t < steps) (sh0 : Shared)
    (hM : Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) nY sh0)
    (l : Locals) (sh : Shared) (h0 : RowI C V E steps g s i t sh0 ctx 0 l sh) :
    ∃ l' sh', Exec C ctx [rowLoop V.bits steps V.qd] l sh .normal l' sh' ∧ RowI C V E steps g s i t sh0 ctx 4 l' sh' := by
  refine Exec.loop_count 4 (RowI C V E steps g s i t sh0 ctx) (RowI C V E steps g s i t sh0 ctx)
    (fun r hr l sh hI => ⟨sh, eval_lt C hI.2.2.2.1 (by omega) (by omega) sh, hI⟩) (fun r hr l sh hI => ?_) h0
  obtain ⟨hkl, h24, h25, h26, hF, hres⟩ := hI
  obtain ⟨l₁, sh₁, hb, hF₁, k₁, hoth, hnew⟩ :=
    row_body hQ hS hG hl hfz hg hB hWa hW t r ht hr sh0 hM l sh hF hkl h24 h25 h26
  refine ⟨.normal, l₁, sh₁, _, _, .inl rfl, hb, .set (eval_addi C (k := 1) (by rw [k₁ 26 (by omega)]; exact h26) (by omega) _)
    (.nil _ _), hkl.keep (fun j hj => by rw [setLocal_other _ _ (by omega)]; exact k₁ j (by omega)),
    by rw [setLocal_other _ _ (by omega), k₁ 24 (by omega)]; exact h24,
    by rw [setLocal_other _ _ (by omega), k₁ 25 (by omega)]; exact h25, setLocal_same _ _ _, hF₁, fun r' hr' => ?_⟩
  by_cases hrr : r' = r
  · subst hrr
    rw [hnew, hres r' hr', ite_eq_right (by omega), ite_eq_left (by omega)]
    rfl
  · rw [hoth r' hrr, hres r' hr']
    congr 1
    by_cases h : r' < r
    · rw [ite_eq_left h, ite_eq_left (by omega)]
    · rw [ite_eq_right h, ite_eq_right (by omega)]

/-- The K loop's `t`-th test: `result` holds the first `t` steps. -/
def StepI (C : M1Max.Contract) (V : Variant) (E : Env) (steps g s i : Nat) (sh0 : Shared) (ctx : Ctx) (t : Nat)
    (l : Locals) (sh : Shared) : Prop :=
  KLocs V steps g s i t l ∧ Footprint ctx rdR (isR (resR g s i)) sh0 sh ∧
    ∀ r < 4, f32At (sh.bytes (resR g s i)) r = accE C V steps E (row0 g s + r) i t

theorem step_loop (hQ : QdSpec C V) (hS : Shape E.L V steps blocks ax aw as ab) (hG : Good C V steps E)
    (hl : Lane ctx g s i) (hfz : ctx.fuse = E.fuse) (hg : g < blocks) (hB : 0 < V.bits) (hB8 : V.bits < 8)
    (hWa : V.wAlign ∣ 2) (hW : 64 * blocks * (64 * V.bits * steps) < 2 ^ 31) (sh0 : Shared)
    (hM : Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) nY sh0)
    (l : Locals) (sh : Shared) (h0 : StepI C V E steps g s i sh0 ctx 0 l sh) :
    ∃ l' sh', Exec C ctx [stepLoop V.bits steps V.qd] l sh .normal l' sh' ∧ StepI C V E steps g s i sh0 ctx steps l' sh' := by
  have hsi := hl.hi; have hss := hl.hs
  have hsteps : 4096 * steps ≤ 64 * blocks * (64 * V.bits * steps) := by
    have h1 : 64 * 1 ≤ 64 * blocks := by omega
    have h2 : 64 * 1 * steps ≤ 64 * V.bits * steps := Nat.mul_le_mul_right _ (by omega)
    calc 4096 * steps = (64 * 1) * (64 * 1 * steps) := by ring
      _ ≤ 64 * blocks * (64 * V.bits * steps) := Nat.mul_le_mul h1 h2
  refine Exec.loop_count steps (StepI C V E steps g s i sh0 ctx) (StepI C V E steps g s i sh0 ctx)
    (fun t ht l sh hI => ⟨sh, by
      rw [eval_lt C (ctx := ctx) (n := 512 * steps) hI.1.k (by omega) (by omega) sh]
      exact congrArg (fun b => some (Val.bool b, sh)) (decide_eq_decide.mpr (by omega)), hI⟩)
    (fun t ht l sh hI => ?_) h0
  obtain ⟨hkl, hF, hres⟩ := hI
  have hreg : sh.regions = E.L.regions := hF.regions.trans hM.regions
  -- `sum = ss[(k + lane * 16) / 16]`
  have hidx : (eval C ctx l (.bin .div .u32 0 (.bin .add .u32 0 (.conv .u32 (.local 23)) (.bin .mul .u32 0 (.local 6) (u32l 16)))
      (u32l 16))).run sh = some (u32 (32 * t + i), sh) := by
    rw [show 32 * t + i = (512 * t + i * 16) / 16 by omega]
    exact eval_int C (by decide) (eval_int C (by decide) (eval_conv C (eval_local' C hkl.k sh)
      (convert_u32_i32 C (512 * t) (by omega))) (eval_int C (by decide) (eval_local' C hkl.locs.lane sh) (eval_lit C _ _ _ _)
        (binary_mul_u32 C i 16)) (binary_add_u32 C (512 * t) (i * 16))) (eval_lit C _ _ _ _)
      (binary_div_u32 C (512 * t + i * 16) 16 (by omega) (by omega) (by omega))
  have hp := eval_offset_u32 C (o := 0) (eval_local' C hkl.locs.ss sh) hidx (by omega)
  rw [show 0 + (32 * t + i) * (Ty.scalar .f32).bytes = 4 * (32 * t + i) by simp [Ty.bytes, Scalar.bytes]; ring] at hp
  have hld := load_f32_group ctx sh 6 (128 * steps) (32 * t + i) (by rw [hreg]; exact hS.r6) (by omega)
  rw [hF.bytes 6 (by unfold isR resR; omega), hM.ss _ (by omega), hG.sv] at hld
  have h24 := (eval_load C _ _ (.scalar .f32) _ _ _ _ hp).trans hld
  have hF₁ : Footprint ctx rdR (isR (resR g s i)) sh0 (rd4 ctx sh 6 (4 * (32 * t + i))) :=
    hF.trans (by rw [rd4_eq]; exact Footprint.rdn _ _ _ _ (by simp [rdR]))
  -- `x_thread = xs + k + lane * 16`
  generalize hl₁ : setLocal l 24 (.f32 (V.cs E.X (32 * t + i))) = l₁
  have k₁ : ∀ j, j < 24 → l₁ j = l j := fun j hj => by rw [← hl₁, setLocal_other _ _ (by omega)]
  have g7 : l₁ 7 = some (fptr 5) := by rw [k₁ 7 (by omega)]; exact hkl.locs.xs
  have g23 : l₁ 23 = some (.int .i32 (512 * t)) := by rw [k₁ 23 (by omega)]; exact hkl.k
  have g6 : l₁ 6 = some (u32 i) := by rw [k₁ 6 (by omega)]; exact hkl.locs.lane
  have hx1 := eval_ptr_i32 C (o := 0) (eval_local' C (ctx := ctx) g7 (rd4 ctx sh 6 (4 * (32 * t + i))))
    (eval_local' C g23 _) (by omega)
  have hx2 := eval_offset_u32 C hx1 (eval_int C (site := 0) (by decide) (eval_local' C g6 _)
    (eval_lit C _ _ _ _) (binary_mul_u32 C i 16)) (by omega)
  rw [show 0 + 512 * t * (Ty.scalar .f32).bytes + i * 16 * (Ty.scalar .f32).bytes = 4 * (16 * (32 * t + i)) by
    simp [Ty.bytes, Scalar.bytes]; ring] at hx2
  generalize hl₃ : setLocal (setLocal l₁ 25 (.ptr ⟨5, ((4 * (16 * (32 * t + i)) : Nat) : Int), .scalar .f32⟩)) 26
    (.int .i32 0) = l₃
  have k₃ : ∀ j, j < 24 → l₃ j = l j := fun j hj => by
    rw [← hl₃, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), k₁ j hj]
  -- the four rows
  obtain ⟨l₄, sh₂, hrows, hkl₄, -, -, -, hF₂, hres₂⟩ := row_loop hQ hS hG hl hfz hg hB hWa hW t ht sh0 hM l₃ _
    ⟨hkl.keep k₃, by rw [← hl₃, setLocal_other _ _ (by omega), setLocal_other _ _ (by omega), ← hl₁]; exact setLocal_same _ _ _,
      by rw [← hl₃, setLocal_other _ _ (by omega)]; exact setLocal_same _ _ _, by rw [← hl₃]; exact setLocal_same _ _ _, hF₁,
      fun r' hr' => by rw [show (rd4 ctx sh 6 (4 * (32 * t + i))).bytes = sh.bytes from rfl, hres r' hr', ite_eq_right (by omega)]⟩
  -- `ws += 32 * BPL`, `sc += 8`, `bi += 8`, `k += 512`
  have hw := eval_ptr_i32 C (eval_local' C (ctx := ctx) hkl₄.ws sh₂) (eval_lit C ctx l₄ (.int .i32 (64 * V.bits)) sh₂) (by omega)
  rw [show row0 g s * (64 * V.bits * steps) + 2 * V.bits * i + 64 * V.bits * t + 64 * V.bits * (Ty.scalar .u8).bytes =
    row0 g s * (64 * V.bits * steps) + 2 * V.bits * i + 64 * V.bits * (t + 1) by simp [Ty.bytes, Scalar.bytes]; ring] at hw
  generalize hl₅ : setLocal l₄ 19 (.ptr ⟨1, ((row0 g s * (64 * V.bits * steps) + 2 * V.bits * i + 64 * V.bits * (t + 1) : Nat) :
    Int), .scalar .u8⟩) = l₅
  have g20 : l₅ 20 = some (.ptr ⟨2, ((2 * (row0 g s * (8 * steps) + 8 * t + i / 4) : Nat) : Int), .scalar .bf16⟩) := by
    rw [← hl₅, setLocal_other _ _ (by omega)]; exact hkl₄.sc
  have hsc := eval_ptr_i32 C (eval_local' C (ctx := ctx) g20 sh₂) (eval_lit C ctx l₅ (.int .i32 8) sh₂) (by omega)
  rw [show 2 * (row0 g s * (8 * steps) + 8 * t + i / 4) + 8 * (Ty.scalar .bf16).bytes =
    2 * (row0 g s * (8 * steps) + 8 * (t + 1) + i / 4) by simp [Ty.bytes, Scalar.bytes]; ring] at hsc
  generalize hl₆ : setLocal l₅ 20 (.ptr ⟨2, ((2 * (row0 g s * (8 * steps) + 8 * (t + 1) + i / 4) : Nat) : Int), .scalar .bf16⟩) = l₆
  have g21 : l₆ 21 = some (.ptr ⟨3, ((2 * (row0 g s * (8 * steps) + 8 * t + i / 4) : Nat) : Int), .scalar .bf16⟩) := by
    rw [← hl₆, setLocal_other _ _ (by omega), ← hl₅, setLocal_other _ _ (by omega)]; exact hkl₄.bi
  have hbi := eval_ptr_i32 C (eval_local' C (ctx := ctx) g21 sh₂) (eval_lit C ctx l₆ (.int .i32 8) sh₂) (by omega)
  rw [show 2 * (row0 g s * (8 * steps) + 8 * t + i / 4) + 8 * (Ty.scalar .bf16).bytes =
    2 * (row0 g s * (8 * steps) + 8 * (t + 1) + i / 4) by simp [Ty.bytes, Scalar.bytes]; ring] at hbi
  generalize hl₇ : setLocal l₆ 21 (.ptr ⟨3, ((2 * (row0 g s * (8 * steps) + 8 * (t + 1) + i / 4) : Nat) : Int), .scalar .bf16⟩) = l₇
  have k₇ : ∀ j, j < 19 ∨ j = 22 ∨ j = 23 → l₇ j = l₄ j := fun j hj => by
    rw [← hl₇, setLocal_other _ _ (by omega), ← hl₆, setLocal_other _ _ (by omega), ← hl₅, setLocal_other _ _ (by omega)]
  have g23 : l₇ 23 = some (.int .i32 (512 * t)) := by rw [k₇ 23 (by omega)]; exact hkl₄.k
  refine ⟨.normal, l₇, sh₂, _, sh₂, .inl rfl, ?_, .set (eval_addi C (k := 512) g23 (by omega) _) (.nil _ _), ⟨?_, hF₂, ?_⟩⟩
  · subst hl₇ hl₆ hl₅ hl₃ hl₁
    exact (Exec.set h24 (Exec.set hx2 (Exec.set (eval_lit C _ _ _ _) (Exec.append hrows
      (.set hw (.set hsc (.set hbi (.nil _ _))))))) :
      Exec C ctx (_ :: _ :: _ :: ([rowLoop V.bits steps V.qd] ++ [_, _, _])) _ _ _ _ _)
  · have q19 : l₇ 19 = some (.ptr ⟨1, ((row0 g s * (64 * V.bits * steps) + 2 * V.bits * i + 64 * V.bits * (t + 1) : Nat) :
        Int), .scalar .u8⟩) := by
      rw [← hl₇, setLocal_other _ _ (by omega), ← hl₆, setLocal_other _ _ (by omega), ← hl₅]; exact setLocal_same _ _ _
    have q20 : l₇ 20 = some (.ptr ⟨2, ((2 * (row0 g s * (8 * steps) + 8 * (t + 1) + i / 4) : Nat) : Int), .scalar .bf16⟩) := by
      rw [← hl₇, setLocal_other _ _ (by omega), ← hl₆]; exact setLocal_same _ _ _
    have q21 : l₇ 21 = some (.ptr ⟨3, ((2 * (row0 g s * (8 * steps) + 8 * (t + 1) + i / 4) : Nat) : Int), .scalar .bf16⟩) := by
      rw [← hl₇]; exact setLocal_same _ _ _
    exact ⟨(hkl₄.locs.keep (fun j hj => k₇ j (by omega))).set _ (by omega),
      by rw [setLocal_other _ _ (by omega), k₇ 18 (by omega)]; exact hkl₄.r0,
      by rw [setLocal_other _ _ (by omega)]; exact q19, by rw [setLocal_other _ _ (by omega)]; exact q20,
      by rw [setLocal_other _ _ (by omega)]; exact q21,
      by rw [setLocal_other _ _ (by omega), k₇ 22 (by omega)]; exact hkl₄.res,
      by rw [setLocal_same, show 512 * t + 512 = 512 * (t + 1) by ring]⟩
  · intro r hr
    rw [hres₂ r hr, ite_eq_left hr]

/-- The output loop's body after its `simd_sum`, and a thread's frames stopped at that `simd_sum`. -/
def outRest : List CStmt :=
  [.set 41 (.local 40),
   .ite (.bin .eq .u32 0 (.local 6) (u32l 0))
     [.store (.scalar .bf16) (.offset (.local 4) (.bin .add .i32 0 (.local 18) (.local 39))) (.conv .bf16 (.local 41))] []]

theorem outBody_eq : outBody = .collective 16 40 .sum .f32 (.load (.scalar .f32) (.offset (.local 22) (.local 39))) (u16l 0) ::
    outRest := rfl

def outFrames : List Metal.Frame := [.block outRest, .loop (lt 39 4) (stepBy 39 1) outBody, .block []]

/-- The locals of the output loop at row `r`. -/
structure OutLocs (g s i r : Nat) (l : Locals) : Prop where
  locs : Locs s i l
  r0 : l 18 = some (.int .i32 (row0 g s))
  res : l 22 = some (.ptr ⟨resR g s i, 0, .scalar .f32⟩)
  r : l 39 = some (.int .i32 r)

/-- The output loop's `simd_sum` of `result[r]`: the thread stops there. -/
theorem out_collective {l : Locals} {sh : Shared} (hS : Shape E.L V steps blocks ax aw as ab) (r : Nat) (hr : r < 4)
    (hol : OutLocs g s i r l) (hreg : sh.regions = E.L.regions) :
    Exec C ctx outBody l sh (.stop (.collective 16 40 .sum .f32 (.f32 (f32At (sh.bytes (resR g s i)) r)) 0) [.block outRest]) l sh := by
  have hp := eval_ptr_i32 C (o := 0) (eval_local' C (ctx := ctx) hol.res sh) (eval_local' C hol.r sh) (by omega)
  rw [show 0 + r * (Ty.scalar .f32).bytes = 4 * r by simp [Ty.bytes, Scalar.bytes]; ring] at hp
  have hld := load_f32_thread ctx sh (resR g s i) 16 r (by rw [hreg]; exact hS.rr _) (by omega)
  rw [outBody_eq]
  exact .collective ((eval_load C _ _ (.scalar .f32) _ _ _ _ hp).trans hld) (eval_lit C _ _ _ _) rfl

/-- `result[r] = 0` for `r` below 4. -/
theorem zero_stores {l : Locals} (hS : Shape E.L V steps blocks ax aw as ab) (hres : l 22 = some (.ptr ⟨resR g s i, 0, .scalar .f32⟩))
    (sh : Shared) (hreg : sh.regions = E.L.regions) :
    ∃ sh', Exec C ctx [.store (.scalar .f32) (.offset (.local 22) (i32l 0)) (f32l 0x0),
      .store (.scalar .f32) (.offset (.local 22) (i32l 1)) (f32l 0x0),
      .store (.scalar .f32) (.offset (.local 22) (i32l 2)) (f32l 0x0),
      .store (.scalar .f32) (.offset (.local 22) (i32l 3)) (f32l 0x0)] l sh .normal l sh' ∧
      Footprint ctx rdR (isR (resR g s i)) sh sh' ∧ ∀ r < 4, f32At (sh'.bytes (resR g s i)) r = zero := by
  have hrr : ∀ sh : Shared, sh.regions = E.L.regions → sh.regions (resR g s i) = some ⟨.thread, 16, 4⟩ :=
    fun sh h => by rw [h]; exact hS.rr _
  have st : ∀ (r : Nat) (sh : Shared), r < 4 → sh.regions = E.L.regions →
      Exec C ctx [.store (.scalar .f32) (.offset (.local 22) (i32l r)) (f32l 0x0)] l sh .normal l (wrT sh (resR g s i) (4 * r) zero) ∧
      Footprint ctx rdR (isR (resR g s i)) sh (wrT sh (resR g s i) (4 * r) zero) := by
    intro r sh hr h
    have hp := eval_ptr_i32 C (o := 0) (eval_local' C (ctx := ctx) hres sh) (eval_lit C ctx l (.int .i32 r) sh) (by omega)
    rw [show 0 + r * (Ty.scalar .f32).bytes = 4 * r by simp [Ty.bytes, Scalar.bytes]; ring] at hp
    exact ⟨.store hp (eval_lit C _ _ _ _) (store_f32_thread ctx sh (resR g s i) 16 r zero (hrr sh h) (by omega)) (.nil _ _),
      Footprint.wrT _ _ _ _ rfl⟩
  obtain ⟨e0, f0⟩ := st 0 sh (by omega) hreg
  obtain ⟨e1, f1⟩ := st 1 _ (by omega) (f0.regions.trans hreg)
  obtain ⟨e2, f2⟩ := st 2 _ (by omega) (f1.regions.trans (f0.regions.trans hreg))
  obtain ⟨e3, f3⟩ := st 3 _ (by omega) (f2.regions.trans (f1.regions.trans (f0.regions.trans hreg)))
  refine ⟨_, Exec.append e0 (Exec.append e1 (Exec.append e2 e3)), f0.trans (f1.trans (f2.trans f3)), fun r hr => ?_⟩
  simp only [wrT_bytes_same]
  rw [f32At_write, f32At_write, f32At_write, f32At_write]
  split_ifs <;> first | rfl | omega

/-- After the barrier: `row0`, the pointers, `result = 0`, the K loop, to the first `simd_sum`. -/
theorem lane_phase2 (hQ : QdSpec C V) (hS : Shape E.L V steps blocks ax aw as ab) (hG : Good C V steps E)
    (hl : Lane ctx g s i) (hfz : ctx.fuse = E.fuse) (hg : g < blocks) (hB : 0 < V.bits) (hB8 : V.bits < 8)
    (hWa : V.wAlign ∣ 2) (hW : 64 * blocks * (64 * V.bits * steps) < 2 ^ 31) (hst : 0 < steps) (l : Locals)
    (hloc : Locs s i l) (sh : Shared) (hM : Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) nY sh) :
    ∃ l' sh', (∃ m0, ∀ m, m0 ≤ m → (runThread C m ⟨ctx, l, [.block (post1 V.bits steps V.qd)], .running⟩).run sh =
      some (⟨ctx, l', outFrames, .collective 16 40 .sum .f32 (.f32 (accE C V steps E (row0 g s + 0) i steps)) 0⟩, sh')) ∧
      OutLocs g s i 0 l' ∧ Footprint ctx rdR (isR (resR g s i)) sh sh' ∧
      ∀ r < 4, f32At (sh'.bytes (resR g s i)) r = accE C V steps E (row0 g s + r) i steps := by
  have hsi := hl.hi; have hss := hl.hs
  have hrow : row0 g s < 64 * blocks := by unfold row0; omega
  have hX : 8 * steps ≤ 64 * V.bits * steps := by nlinarith
  have hrR : row0 g s * (64 * V.bits * steps) < 2 ^ 31 :=
    lt_of_le_of_lt (Nat.mul_le_mul_right _ hrow.le) hW
  have hrG : row0 g s * (8 * steps) < 2 ^ 31 := lt_of_le_of_lt (Nat.mul_le_mul_left _ hX) hrR
  have hXb : 64 * V.bits * steps < 2 ^ 31 := lt_of_le_of_lt (Nat.le_mul_of_pos_left _ (by omega)) hW
  have hbl : 64 * blocks < 2 ^ 31 := lt_of_le_of_lt (Nat.le_mul_of_pos_right _ (by positivity)) hW
  -- `row0`
  have hc1 : (eval C ctx l (.component (.coord .threadgroupPositionInGrid) (u32l 1))).run sh = some (u32 g, sh) := by
    have hv : (eval C ctx l (.coord .threadgroupPositionInGrid)).run sh = some (.vec .u32 [u32 0, u32 g, u32 0], sh) := by
      rw [eval_coord, hl.tg]; rfl
    exact eval_component C hv (eval_lit C _ _ _ _) rfl rfl
  have h18 : (eval C ctx l row0Expr).run sh = some (.int .i32 (row0 g s), sh) := by
    unfold row0Expr
    rw [show row0 g s = (g * 16 + s) * 4 by unfold row0; ring]
    exact eval_conv C (eval_int C (by decide) (eval_int C (by decide) (eval_int C (by decide) hc1 (eval_lit C _ _ _ _)
      (binary_mul_u32 C g 16)) (eval_local' C hloc.sg sh) (binary_add_u32 C (g * 16) s)) (eval_lit C _ _ _ _)
      (binary_mul_u32 C (g * 16 + s) 4)) (convert_i32_u32 C _ (by unfold row0 at hrow; omega))
  generalize hl₁ : setLocal l 18 (.int .i32 (row0 g s)) = l₁
  have k₁ : ∀ j, j ≠ 18 → l₁ j = l j := fun j hj => by rw [← hl₁, setLocal_other _ _ hj]
  have g18 : l₁ 18 = some (.int .i32 (row0 g s)) := by rw [← hl₁]; exact setLocal_same _ _ _
  have g6 : l₁ 6 = some (u32 i) := by rw [k₁ 6 (by omega)]; exact hloc.lane
  -- `ws`
  have g1 : l₁ 1 = some (.ptr ⟨1, 0, .scalar .u32⟩) := by rw [k₁ 1 (by omega)]; exact hloc.w
  have hp1 := eval_ptr_i32 C (o := 0) (eval_ptrCast C (t := .scalar .u8) (eval_local' C (ctx := ctx) g1 sh)) (eval_int C (s := .i32) (b := i32l (64 * V.bits * steps)) (site := 0) (by decide) (eval_local' C g18 sh)
    (eval_lit C _ _ _ _) (binary_mul_i32 C _ _ hrR (by omega) hXb)) hrR
  have hiB : i * (2 * V.bits) ≤ 32 * 16 := Nat.mul_le_mul (by omega) (by omega)
  have hp2 := eval_offset_u32 C (n := i * (2 * V.bits)) hp1 (eval_int C (op := .mul) (s := .u32) (b := u32l (2 * V.bits)) (site := 0) (by decide)
    (eval_local' C g6 sh) (eval_u32l C (by omega) sh) (binary_mul_u32 C i (2 * V.bits))) (by omega)
  rw [show 0 + row0 g s * (64 * V.bits * steps) * (Ty.scalar .u8).bytes + i * (2 * V.bits) * (Ty.scalar .u8).bytes =
    row0 g s * (64 * V.bits * steps) + 2 * V.bits * i + 64 * V.bits * 0 by simp [Ty.bytes, Scalar.bytes]; ring] at hp2
  generalize hl₂ : setLocal l₁ 19 (.ptr ⟨1, ((row0 g s * (64 * V.bits * steps) + 2 * V.bits * i + 64 * V.bits * 0 : Nat) : Int),
    .scalar .u8⟩) = l₂
  have k₂ : ∀ j, j ≠ 18 → j ≠ 19 → l₂ j = l j := fun j h1 h2 => by rw [← hl₂, setLocal_other _ _ h2, k₁ j h1]
  have g18₂ : l₂ 18 = some (.int .i32 (row0 g s)) := by rw [← hl₂, setLocal_other _ _ (by omega)]; exact g18
  -- `sc`, `bi`
  have hptr : ∀ (lc : Locals) (r : Nat), lc r = some (ptr r) → lc 18 = some (.int .i32 (row0 g s)) →
      lc 6 = some (u32 i) →
      (eval C ctx lc (.offset (.offset (.local r) (.bin .mul .i32 0 (.local 18) (i32l (8 * steps))))
        (.bin .div .u32 0 (.local 6) (u32l 4)))).run sh =
      some (.ptr ⟨r, ((2 * (row0 g s * (8 * steps) + 8 * 0 + i / 4) : Nat) : Int), .scalar .bf16⟩, sh) := by
    intro lc r hr h18' h6'
    have h1 := eval_ptr_i32 C (o := 0) (eval_local' C (ctx := ctx) hr sh) (eval_int C (s := .i32) (b := i32l (8 * steps))
      (site := 0) (by decide) (eval_local' C h18' sh) (eval_lit C _ _ _ _) (binary_mul_i32 C _ _ hrG (by omega) (by omega))) hrG
    have h2 := eval_offset_u32 C (n := i / 4) h1 (eval_int C (op := .div) (s := .u32) (b := u32l 4) (site := 0) (by decide)
      (eval_local' C h6' sh) (eval_lit C _ _ _ _) (binary_div_u32 C i 4 (by omega) (by omega) (by omega))) (by omega)
    rw [show 0 + row0 g s * (8 * steps) * (Ty.scalar .bf16).bytes + i / 4 * (Ty.scalar .bf16).bytes =
      2 * (row0 g s * (8 * steps) + 8 * 0 + i / 4) by simp [Ty.bytes, Scalar.bytes]; ring] at h2
    exact h2
  have hp20 := hptr l₂ 2 (by rw [k₂ 2 (by omega) (by omega)]; exact hloc.sc) g18₂ (by rw [k₂ 6 (by omega) (by omega)]; exact hloc.lane)
  generalize hl₃ : setLocal l₂ 20 (.ptr ⟨2, ((2 * (row0 g s * (8 * steps) + 8 * 0 + i / 4) : Nat) : Int), .scalar .bf16⟩) = l₃
  have hp21 := hptr l₃ 3 (by rw [← hl₃, setLocal_other _ _ (by omega), k₂ 3 (by omega) (by omega)]; exact hloc.bi)
    (by rw [← hl₃, setLocal_other _ _ (by omega)]; exact g18₂)
    (by rw [← hl₃, setLocal_other _ _ (by omega), k₂ 6 (by omega) (by omega)]; exact hloc.lane)
  generalize hl₄ : setLocal (setLocal l₃ 21 (.ptr ⟨3, ((2 * (row0 g s * (8 * steps) + 8 * 0 + i / 4) : Nat) : Int), .scalar .bf16⟩))
    22 (.ptr ⟨resR g s i, 0, .scalar .f32⟩) = l₄
  have g22 : l₄ 22 = some (.ptr ⟨resR g s i, 0, .scalar .f32⟩) := by rw [← hl₄]; exact setLocal_same _ _ _
  -- `result = 0`
  obtain ⟨sh₁, hz, hFz, hres0⟩ := zero_stores (C := C) (ctx := ctx) hS g22 sh hM.regions
  generalize hl₅ : setLocal l₄ 23 (.int .i32 0) = l₅
  have hpre : Exec C ctx (pre2 V.bits steps) l sh .normal l₅ sh₁ := by
    have hz' := Exec.append hz (.set (slot := 23) (eval_lit C ctx l₄ (.int .i32 0) sh₁) (.nil _ _))
    rw [hl₅] at hz'
    rw [← hl₄, ← hl₃, ← hl₂, ← hl₁] at hz'
    subst hl₁ hl₂ hl₃
    refine .set h18 (.set hp2 (.set hp20 (.set hp21 (.array ?_))))
    rw [show (if false = true then ctx.groupArray 1 else ctx.threadArray 1) = resR g s i from hl.ta1]
    exact hz'
  -- the K loop
  have hkl : KLocs V steps g s i 0 l₅ := by
    rw [← hl₅, ← hl₄, ← hl₃, ← hl₂, ← hl₁]
    exact ⟨(((((hloc.set _ (by omega)).set _ (by omega)).set _ (by omega)).set _ (by omega)).set _ (by omega)).set _
      (by omega), by simp [setLocal], by simp [setLocal], by simp [setLocal], by simp [setLocal], by simp [setLocal],
      by simp [setLocal]⟩
  obtain ⟨l₆, sh₂, hstep, hkl₆, hF₂, hres₂⟩ := step_loop hQ hS hG hl hfz hg hB hB8 hWa hW sh hM l₅ sh₁
    ⟨hkl, hFz, fun r hr => hres0 r hr⟩
  have hol : OutLocs g s i 0 (setLocal l₆ 39 (.int .i32 0)) :=
    ⟨hkl₆.locs.set _ (by omega), by rw [setLocal_other _ _ (by omega)]; exact hkl₆.r0,
      by rw [setLocal_other _ _ (by omega)]; exact hkl₆.res, setLocal_same _ _ _⟩
  have hout := out_collective (C := C) (ctx := ctx) hS 0 (by omega) hol (hF₂.regions.trans hM.regions)
  rw [hres₂ 0 (by omega)] at hout
  have hex : Exec C ctx (post1 V.bits steps V.qd) l sh
      (.stop (.collective 16 40 .sum .f32 (.f32 (accE C V steps E (row0 g s + 0) i steps)) 0)
        ([.block outRest] ++ [.loop (lt 39 4) (stepBy 39 1) outBody, .block []])) (setLocal l₆ 39 (.int .i32 0)) sh₂ :=
    (Exec.append hpre (Exec.append hstep (.set (eval_lit C _ _ _ _) (.loop_stop (eval_lt_true (C := C) hol.r (by omega)
      (by omega) _) hout))) : Exec C ctx (pre2 V.bits steps ++ ([stepLoop V.bits steps V.qd] ++ [_, _])) _ _ _ _ _)
  exact ⟨_, sh₂, (hex.reaches_stop (K := [])).run rfl, hol, hF₂, hres₂⟩

/-- `simd_sum(result[r])` of the SIMD-group computing row `row`. -/
def vsum (C : M1Max.Contract) (V : Variant) (steps : Nat) (E : Env) (row : Nat) : Float32 :=
  C.simdSum fun L => accE C V steps E row L steps

/-- After the `simd_sum` of row `r`: `v`, lane 0's store of `y[row0 + r]`, and `r += 1`. -/
theorem out_rest (hS : Shape E.L V steps blocks ax aw as ab) (hG : Good C V steps E) (hl : Lane ctx g s i)
    (hg : g < blocks) (hbl : 64 * blocks < 2 ^ 31) (r : Nat) (hr : r < 4) (l : Locals) (hol : OutLocs g s i r l) (sh : Shared)
    (hM : Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) (row0 g s + r + min i 1) sh) :
    ∃ l' sh', Exec C ctx outRest (setLocal l 40 (.f32 (vsum C V steps E (row0 g s + r)))) sh .normal l' sh' ∧
      OutLocs g s i r l' ∧ Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) (row0 g s + r + 1) sh' ∧
      (∀ q, q ≠ 4 → sh'.bytes q = sh.bytes q) ∧ sh'.regions = sh.regions := by
  have hsi := hl.hi; have hss := hl.hs
  generalize hl₁ : setLocal (setLocal l 40 (.f32 (vsum C V steps E (row0 g s + r)))) 41
    (.f32 (vsum C V steps E (row0 g s + r))) = l₁
  have hol₁ : OutLocs g s i r l₁ := by
    rw [← hl₁]
    exact ⟨(hol.locs.set _ (by omega)).set _ (by omega), by simp [setLocal, hol.r0], by simp [setLocal, hol.res],
      by simp [setLocal, hol.r]⟩
  have h41 : l₁ 41 = some (.f32 (vsum C V steps E (row0 g s + r))) := by rw [← hl₁]; exact setLocal_same _ _ _
  have hset : ∀ (ss : List CStmt) (o : Outcome) (l' : Locals) (sh' : Shared), Exec C ctx ss l₁ sh o l' sh' →
      Exec C ctx (.set 41 (.local 40) :: ss) (setLocal l 40 (.f32 (vsum C V steps E (row0 g s + r)))) sh o l' sh' := by
    intro ss o l' sh' h
    rw [← hl₁] at h
    exact .set (eval_local' C (setLocal_same _ _ _) sh) h
  have htest := eval_int C (op := .eq) (s := .u32) (site := 0) (b := u32l 0) (by decide) (eval_local' C (ctx := ctx) hol₁.locs.lane sh)
    (eval_lit C _ _ _ _) (binary_eq_u32 C i 0 (by omega) (by omega))
  by_cases hi0 : i = 0
  · subst hi0
    have hp := eval_ptr_i32 C (o := 0) (eval_local' C (ctx := ctx) hol₁.locs.y sh)
      (eval_int C (s := .i32) (site := 0) (by decide) (eval_local' C hol₁.r0 sh) (eval_local' C hol₁.r sh)
        (binary_add_i32 C (row0 g s) r (by unfold row0; omega))) (by unfold row0; omega)
    rw [show 0 + (row0 g s + r) * (Ty.scalar .bf16).bytes = 2 * (row0 g s + r) by simp [Ty.bytes, Scalar.bytes]; ring] at hp
    have hst := store_bf16 ctx sh 4 (128 * blocks) 16 (row0 g s + r) (C.narrow (vsum C V steps E (row0 g s + r)))
      (by rw [hM.regions]; exact hS.r4) (by decide) (by unfold row0; omega)
    have hy : E.yv (row0 g s + r) = C.narrow (vsum C V steps E (row0 g s + r)) := by rw [hG.yv]; rfl
    have hM' := (show Mem E (g + 1) _ _ (row0 g s + r) sh by simpa using hM).wy hS ctx (by unfold row0; omega)
      (by rw [hl.thread]; unfold row0; omega) (by rw [hl.group]; unfold row0; omega)
    rw [hy] at hM'
    refine ⟨l₁, _, hset _ _ _ _ (.ite htest (.store hp (eval_conv C (eval_local' C h41 _) rfl) hst (.nil _ _)) (.nil _ _)),
      hol₁, hM', fun q hq => wr_bytes_other _ _ _ _ hq, rfl⟩
  · rw [decide_eq_false hi0] at htest
    refine ⟨l₁, sh, hset _ _ _ _ (.ite htest (.nil _ _) (.nil _ _)), hol₁, ?_, fun _ _ => rfl, rfl⟩
    simpa [show min i 1 = 1 by omega] using hM

/-- Resumed after the `simd_sum` of row `r < 3`: to the next `simd_sum`. -/
theorem lane_next (hS : Shape E.L V steps blocks ax aw as ab) (hG : Good C V steps E) (hl : Lane ctx g s i)
    (hg : g < blocks) (hbl : 64 * blocks < 2 ^ 31) (r : Nat) (hr : r + 1 < 4) (l : Locals) (hol : OutLocs g s i r l)
    (sh : Shared) (hM : Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) (row0 g s + r + min i 1) sh) :
    ∃ l' sh', (∃ m0, ∀ m, m0 ≤ m → (runThread C m ⟨ctx, setLocal l 40 (.f32 (vsum C V steps E (row0 g s + r))), outFrames,
      .running⟩).run sh =
        some (⟨ctx, l', outFrames, .collective 16 40 .sum .f32 (.f32 (f32At (sh.bytes (resR g s i)) (r + 1))) 0⟩, sh')) ∧
      OutLocs g s i (r + 1) l' ∧ Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) (row0 g s + r + 1) sh' ∧
      ∀ q, q ≠ 4 → sh'.bytes q = sh.bytes q := by
  obtain ⟨l₁, sh₁, hrest, hol₁, hM₁, hb₁, hreg₁⟩ := out_rest hS hG hl hg hbl r (by omega) l hol sh hM
  have hst : Exec C ctx (stepBy 39 1) l₁ sh₁ .normal (setLocal l₁ 39 (.int .i32 (r + 1))) sh₁ :=
    .set (eval_addi C hol₁.r (by omega) _) (.nil _ _)
  have hol₂ : OutLocs g s i (r + 1) (setLocal l₁ 39 (.int .i32 (r + 1))) :=
    ⟨hol₁.locs.set _ (by omega), by rw [setLocal_other _ _ (by omega)]; exact hol₁.r0,
      by rw [setLocal_other _ _ (by omega)]; exact hol₁.res, setLocal_same _ _ _⟩
  have hb := out_collective (C := C) (ctx := ctx) hS (r + 1) hr hol₂ (hreg₁.trans hM.regions)
  rw [hb₁ _ (by unfold resR; omega)] at hb
  exact ⟨_, sh₁, (Exec.resume_stop (K := []) (ss := []) hrest (.inl rfl) hst
    (eval_lt_true (C := C) hol₂.r hr (by omega) _) hb).run rfl, hol₂, hM₁, hb₁⟩

/-- Resumed after the last `simd_sum`: to the end. -/
theorem lane_last (hS : Shape E.L V steps blocks ax aw as ab) (hG : Good C V steps E) (hl : Lane ctx g s i)
    (hg : g < blocks) (hbl : 64 * blocks < 2 ^ 31) (l : Locals) (hol : OutLocs g s i 3 l)
    (sh : Shared) (hM : Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) (row0 g s + 3 + min i 1) sh) :
    ∃ l' sh', (∃ m0, ∀ m, m0 ≤ m → (runThread C m ⟨ctx, setLocal l 40 (.f32 (vsum C V steps E (row0 g s + 3))), outFrames,
      .running⟩).run sh = some (⟨ctx, l', [], .done⟩, sh')) ∧
      Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) (row0 g s + 3 + 1) sh' := by
  obtain ⟨l₁, sh₁, hrest, hol₁, hM₁, -, -⟩ := out_rest hS hG hl hg hbl 3 (by omega) l hol sh hM
  have hst : Exec C ctx (stepBy 39 1) l₁ sh₁ .normal (setLocal l₁ 39 (.int .i32 (3 + 1))) sh₁ :=
    .set (eval_addi C hol₁.r (by omega) _) (.nil _ _)
  have hc := eval_lt_false (C := C) (ctx := ctx) (n := 4) (setLocal_same l₁ 39 (.int .i32 (3 + 1))) (by omega) (by omega)
    (by omega) sh₁
  exact ⟨_, sh₁, ((Exec.resume_exit (K := []) (ss := []) (b := outBody) hrest (.inl rfl) hst hc).trans
    (Exec.nil _ _).reaches_done).run rfl, hM₁⟩

end Phase2

/-! ## SIMD-groups and threadgroups -/

section Groups
variable {C : M1Max.Contract} {V : Variant} {E : Env} {steps blocks ax aw as ab : Nat}

/-- The launch's structure: 32 × 16 threadgroups tiling the grid along y, five buffers, two threadgroup and two
thread arrays per thread, and the kernel's body. -/
structure Tiled (E : Env) (V : Variant) (steps blocks : Nat) : Prop where
  tiles : E.L.Tiles 32 16 1 1 blocks 1 16
  buffers : E.L.buffers.length = 5
  groupArrays : E.L.groupArrays = 2
  threadArrays : E.L.threadArrays = 2
  body : E.L.kernel.body = body V.bits steps V.lv V.qd

theorem lane_of (hT : Tiled E V steps blocks) (g : Nat) (s : Fin 16) (i : Fin 32) :
    Lane (E.L.ctxAt E.fuse 0 g 0 (32 * s + i)) g s i where
  tg := Launch.ctxAt_threadgroupPositionInGrid _ _ _ _ _ _
  lane := Launch.ctxAt_lane _ _ _ _ _ _ _
  sg := Launch.ctxAt_simd _ _ _ _ _ _ _
  ga0 := by rw [Launch.ctxAt_groupArray, hT.buffers]
  ga1 := by rw [Launch.ctxAt_groupArray, hT.buffers]
  thread := by rw [hT.tiles.thread]; omega
  group := by rw [hT.tiles.group_id]; omega
  ta0 := by rw [hT.tiles.threadArray, hT.buffers, hT.groupArrays, hT.threadArrays]; omega
  ta1 := by rw [hT.tiles.threadArray, hT.buffers, hT.groupArrays, hT.threadArrays]; omega
  hs := s.isLt
  hi := i.isLt

/-- To the barrier: SIMD-group `s`'s lanes run their chunk loops in order. -/
theorem simd_phase1 (hV : LvSpec C V) (hS : Shape E.L V steps blocks ax aw as ab) (hG : Good C V steps E)
    (hT : Tiled E V steps blocks) (hK : 512 * steps + 512 < 2 ^ 31) (g : Nat) (s : Fin 16) (sh : Shared)
    (hM : Mem E g (PXn steps (32 * s) (16 * (32 * s))) (PSn steps (32 * s) (32 * s)) (64 * g) sh) :
    ∃ (f r : Nat) (U : Fin 32 → Thread) (sh' : Shared),
      (runSimd C f r (List.ofFn (E.L.lanes E.fuse 0 g 0 s))).run sh = some (List.ofFn U, sh') ∧
      Mem E g (PXn steps (32 * (s + 1)) (16 * (32 * (s + 1)))) (PSn steps (32 * (s + 1)) (32 * (s + 1))) (64 * g) sh' ∧
      ∀ i, (U i).status = .barrier 1 false true ∧ ((U i).ctx = E.L.ctxAt E.fuse 0 g 0 (32 * s + i) ∧
        (U i).frames = [.block (post1 V.bits steps V.qd)] ∧ Locs s i (U i).locals) := by
  obtain ⟨f, r, U, sh', hr, hI, hU⟩ := simd_blocked_bound C (E.L.lanes E.fuse 0 g 0 s)
    (fun k sh => Mem E g (PXn steps (32 * s + k) (16 * (32 * s + k))) (PSn steps (32 * s + k) (32 * s + k)) (64 * g) sh)
    (fun i t => t.status = .barrier 1 false true ∧ (t.ctx = E.L.ctxAt E.fuse 0 g 0 (32 * s + i) ∧
      t.frames = [.block (post1 V.bits steps V.qd)] ∧ Locs s i t.locals))
    (fun i sh hI => by
      obtain ⟨l, sh', ⟨n, hn⟩, hloc, hM'⟩ := lane_phase1 hV hS hG (lane_of hT g s i) hK sh hI
      refine ⟨n, ⟨E.L.ctxAt E.fuse 0 g 0 (32 * s + i), l, [.block (post1 V.bits steps V.qd)], .barrier 1 false true⟩, sh', ?_,
        by rw [show 32 * (s : Nat) + (i + 1) = 32 * s + i + 1 by ring]; exact hM', rfl, rfl, rfl, rfl, hloc⟩
      show (runThread C n ⟨_, fun _ => none, [.block E.L.kernel.body], .running⟩).run sh = _
      rw [hT.body]
      exact hn n le_rfl) sh (by simpa using hM)
  exact ⟨f, r, U, sh', hr, by rw [show 32 * ((s : Nat) + 1) = 32 * s + 32 by ring]; exact hI, hU⟩

/-- The result arrays of the SIMD-group's lanes below `k`. -/
def ResDone (C : M1Max.Contract) (V : Variant) (steps : Nat) (E : Env) (g s k : Nat) (sh : Shared) : Prop :=
  ∀ i < k, ∀ r < 4, f32At (sh.bytes (resR g s i)) r = accE C V steps E (row0 g s + r) i steps

/-- A lane stopped at the output loop's `simd_sum` of row `r`. -/
def POut (E : Env) (g s r : Nat) (i : Fin 32) (t : Thread) : Prop :=
  t.ctx = E.L.ctxAt E.fuse 0 g 0 (32 * s + i) ∧ t.frames = outFrames ∧ OutLocs g s i r t.locals

/-- From the lanes stopped at the `simd_sum` of row `r`, to the end. -/
def Rounds (C : M1Max.Contract) (V : Variant) (steps : Nat) (E : Env) (g : Nat) (s : Fin 16) (r : Nat) : Prop :=
  ∀ (U : Fin 32 → Thread) (sh : Shared), (∀ i, POut E g s r i (U i)) →
    Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) (row0 g s + r) sh → ResDone C V steps E g s 32 sh →
    ∃ (f rr : Nat) (W : Fin 32 → Thread) (sh' : Shared),
      (runSimd C f rr (List.ofFn fun i => { U i with status := .running }.set 40 (.f32 (vsum C V steps E (row0 g s + r))))).run
        sh = some (List.ofFn W, sh') ∧
      Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) (row0 g s + 4) sh' ∧ ∀ i, (W i).status = .done

theorem rounds_last (hS : Shape E.L V steps blocks ax aw as ab) (hG : Good C V steps E) (hT : Tiled E V steps blocks)
    (hbl : 64 * blocks < 2 ^ 31) (g : Nat) (hg : g < blocks) (s : Fin 16) : Rounds C V steps E g s 3 := by
  intro U sh hU hM _
  obtain ⟨f, rr, W, sh', hr, hI, hW⟩ := simd_blocked_bound C (fun i => { U i with status := .running }.set 40
      (.f32 (vsum C V steps E (row0 g s + 3))))
    (fun k sh => Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) (row0 g s + 3 + min k 1) sh)
    (fun _ t => t.status = .done)
    (fun i sh hI => by
      obtain ⟨hc, hf, hol⟩ := hU i
      rw [resume_eq (U i) _ _ hc hf]
      obtain ⟨l', sh', ⟨n, hn⟩, hM'⟩ := lane_last hS hG (lane_of hT g s i) hg hbl _ hol sh hI
      exact ⟨n, _, sh', hn n le_rfl, by rw [show min ((i : Nat) + 1) 1 = 1 by omega]; exact hM', rfl, rfl⟩) sh
    (by simpa using hM)
  exact ⟨f, rr, W, sh', hr, by simpa using hI, hW⟩

theorem rounds_step (hS : Shape E.L V steps blocks ax aw as ab) (hG : Good C V steps E) (hT : Tiled E V steps blocks)
    (hbl : 64 * blocks < 2 ^ 31) (g : Nat) (hg : g < blocks) (s : Fin 16) (r : Nat) (hr : r + 1 < 4)
    (ih : Rounds C V steps E g s (r + 1)) : Rounds C V steps E g s r := by
  intro U sh hU hM hR
  refine simd_collective_bound C (fun i => { U i with status := .running }.set 40 (.f32 (vsum C V steps E (row0 g s + r))))
    16 40 .sum .f32 0 (fun i => .f32 (accE C V steps E (row0 g s + (r + 1)) i steps))
    (fun _ => .f32 (vsum C V steps E (row0 g s + (r + 1)))) (resolve_sum C 0 _)
    (fun k sh => Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) (row0 g s + r + min k 1) sh ∧
      ResDone C V steps E g s 32 sh)
    (POut E g s (r + 1))
    (fun sh => Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) (row0 g s + 4) sh)
    (fun _ t => t.status = .done) (fun i sh hI => ?_) (fun U' sh' hP hI => ?_) sh ⟨by simpa using hM, hR⟩
  · obtain ⟨hc, hf, hol⟩ := hU i
    rw [resume_eq (U i) _ _ hc hf]
    obtain ⟨hM₁, hR₁⟩ := hI
    obtain ⟨l', sh', ⟨n, hn⟩, hol', hM', hb⟩ := lane_next hS hG (lane_of hT g s i) hg hbl r hr _ hol sh hM₁
    rw [hR₁ i i.isLt (r + 1) hr] at hn
    exact ⟨n, _, sh', hn n le_rfl, ⟨by rw [show min ((i : Nat) + 1) 1 = 1 by omega]; exact hM',
      fun i' hi' r' hr' => by rw [hb _ (by unfold resR; omega)]; exact hR₁ i' hi' r' hr'⟩, rfl, rfl, rfl, hol'⟩
  · obtain ⟨hM₁, hR₁⟩ := hI
    exact ih U' sh' hP (by rw [show row0 g s + (r + 1) = row0 g s + r + min 32 1 by omega]; exact hM₁) hR₁

/-- After the barrier: SIMD-group `s`'s lanes run the K loop to the first `simd_sum`, then the four rows' outputs. -/
theorem simd_phase23 (hQ : QdSpec C V) (hS : Shape E.L V steps blocks ax aw as ab) (hG : Good C V steps E)
    (hT : Tiled E V steps blocks) (hB : 0 < V.bits) (hB8 : V.bits < 8) (hWa : V.wAlign ∣ 2)
    (hW : 64 * blocks * (64 * V.bits * steps) < 2 ^ 31) (hst : 0 < steps) (g : Nat) (hg : g < blocks) (s : Fin 16)
    (U : Fin 32 → Thread) (hU : ∀ i, (U i).ctx = E.L.ctxAt E.fuse 0 g 0 (32 * s + i) ∧
      (U i).frames = [.block (post1 V.bits steps V.qd)] ∧ Locs s i (U i).locals) (sh : Shared)
    (hM : Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) (row0 g s) sh) :
    ∃ (f r : Nat) (W : Fin 32 → Thread) (sh' : Shared),
      (runSimd C f r (List.ofFn fun i => { U i with status := .running })).run sh = some (List.ofFn W, sh') ∧
      Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) (row0 g s + 4) sh' ∧
      ∀ i, (W i).status = .done := by
  have hbl : 64 * blocks < 2 ^ 31 := lt_of_le_of_lt (Nat.le_mul_of_pos_right _ (by positivity)) hW
  have hall : Rounds C V steps E g s 0 :=
    rounds_step hS hG hT hbl g hg s 0 (by omega) (rounds_step hS hG hT hbl g hg s 1 (by omega)
      (rounds_step hS hG hT hbl g hg s 2 (by omega) (rounds_last hS hG hT hbl g hg s)))
  refine simd_collective_bound C (fun i => { U i with status := .running }) 16 40 .sum .f32 0
    (fun i => .f32 (accE C V steps E (row0 g s + 0) i steps)) (fun _ => .f32 (vsum C V steps E (row0 g s + 0)))
    (resolve_sum C 0 _)
    (fun k sh => Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) (row0 g s) sh ∧
      ResDone C V steps E g s k sh)
    (POut E g s 0)
    (fun sh => Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) (row0 g s + 4) sh)
    (fun _ t => t.status = .done) (fun i sh hI => ?_) (fun U' sh' hP hI => ?_) sh
    ⟨hM, fun _ h => absurd h (Nat.not_lt_zero _)⟩
  · obtain ⟨hc, hf, hloc⟩ := hU i
    rw [run_eq (U i) _ _ hc hf]
    obtain ⟨hM₁, hR₁⟩ := hI
    obtain ⟨l', sh', ⟨n, hn⟩, hol, hF, hres⟩ := lane_phase2 hQ hS hG (lane_of hT g s i) rfl hg hB hB8 hWa hW hst _ hloc
      sh hM₁
    refine ⟨n, _, sh', hn n le_rfl, ⟨hM₁.frame hS _ hF (fun q hq => by
        rcases hq with h | h | h | h | h <;> subst h <;> simp <;> rw [(lane_of hT g s i).group] <;> omega)
        (fun q hq => by unfold isR resR at hq; omega), fun i' hi' r' hr' => ?_⟩, rfl, rfl, rfl, hol⟩
    by_cases hii : i' = i
    · subst hii; exact hres r' hr'
    · rw [hF.bytes _ (by unfold isR resR; omega)]; exact hR₁ i' (by omega) r' hr'
  · obtain ⟨hM₁, hR₁⟩ := hI
    exact hall U' sh' hP (by simpa using hM₁) hR₁

/-- Threadgroup `g`: to the barrier, then each SIMD-group's four rows. -/
theorem group_run (hV : LvSpec C V) (hQ : QdSpec C V) (hS : Shape E.L V steps blocks ax aw as ab) (hG : Good C V steps E)
    (hT : Tiled E V steps blocks) (hB : 0 < V.bits) (hB8 : V.bits < 8) (hWa : V.wAlign ∣ 2)
    (hW : 64 * blocks * (64 * V.bits * steps) < 2 ^ 31) (hst : 0 < steps) (g : Nat) (hg : g < blocks) (sh : Shared)
    (hM : Mem E g (fun _ => False) (fun _ => False) (64 * g) sh) :
    ∃ f r b sh', (runGroup C f r b (List.ofFn fun s : Fin 16 => List.ofFn (E.L.lanes E.fuse 0 g 0 s))).run sh =
      some ((), sh') ∧ Mem E (g + 1) (fun _ => False) (fun _ => False) (64 * (g + 1)) sh' := by
  have hK : 512 * steps + 512 < 2 ^ 31 := by
    have h1 : 64 * 1 ≤ 64 * blocks := by omega
    have h2 : 64 * 1 * steps ≤ 64 * V.bits * steps := Nat.mul_le_mul_right _ (by omega)
    have : 4096 * steps ≤ 64 * blocks * (64 * V.bits * steps) := by
      calc 4096 * steps = (64 * 1) * (64 * 1 * steps) := by ring
        _ ≤ 64 * blocks * (64 * V.bits * steps) := Nat.mul_le_mul h1 h2
    omega
  refine group_barrier_bound C (by decide) (fun s => E.L.lanes E.fuse 0 g 0 s) 1 false true
    (fun j sh => Mem E g (PXn steps (32 * j) (16 * (32 * j))) (PSn steps (32 * j) (32 * j)) (64 * g) sh)
    (fun j i t => t.ctx = E.L.ctxAt E.fuse 0 g 0 (32 * j + i) ∧ t.frames = [.block (post1 V.bits steps V.qd)] ∧
      Locs j i t.locals)
    (fun sh => Mem E (g + 1) (fun _ => False) (fun _ => False) (64 * (g + 1)) sh)
    (fun j sh hj => simd_phase1 hV hS hG hT hK g j sh hj) (fun U sh hU hI => ?_) sh
    (hM.mono (fun e he => by unfold PXn at he; omega) (fun c hc => by unfold PSn at hc; omega) le_rfl)
  have hM₁ : Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) (64 * g) (pass false true sh) :=
    hI.pass.mono (fun e he => ⟨he, .inl (by omega)⟩) (fun c hc => ⟨hc, .inl (by omega)⟩) le_rfl
  obtain ⟨f, r, b, sh', hr, hI'⟩ := group_done_bound C (fun s i => { U s i with status := .running })
    (fun j sh => Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) (64 * g + 4 * j) sh)
    (fun j sh hj => by
      obtain ⟨f, r, W, sh', hr, hM', hW'⟩ := simd_phase23 hQ hS hG hT hB hB8 hWa hW hst g hg j (U j) (hU j) sh
        (by unfold row0; rw [show 4 * (16 * g + (j : Nat)) = 64 * g + 4 * j by ring]; exact hj)
      have hM'' : Mem E (g + 1) (fun e => e < 512 * steps) (fun c => c < 32 * steps) (64 * g + 4 * ((j : Nat) + 1)) sh' := by
        unfold row0 at hM'; rw [show 64 * g + 4 * ((j : Nat) + 1) = 4 * (16 * g + j) + 4 by ring]; exact hM'
      exact ⟨f, r, W, sh', hr, hM'', hW'⟩) _ (by simpa using hM₁)
  exact ⟨f, r, b, sh', hr, hI'.mono (fun _ h => h.elim) (fun _ h => h.elim) (by omega)⟩

end Groups

/-! ## The launch -/

/-- The input buffers: x [1, 1, K] bf16, w [N, K·BITS/32] uint32, scales and biases [N, K/64] bf16, for K = 512·steps
and N = 64·blocks. -/
def inputsOf (V : Variant) (steps blocks : Nat) (X W S B : ByteMemory.Bytes) (ax aw as ab : Nat) : List Buffer :=
  [⟨.device, 2 * (512 * steps), ax, X⟩, ⟨.device, 4 * (64 * blocks * (16 * V.bits * steps)), aw, W⟩,
   ⟨.device, 2 * (64 * blocks * (8 * steps)), as, S⟩, ⟨.device, 2 * (64 * blocks * (8 * steps)), ab, B⟩]

/-- MLX's launch at `affineConfig K N BITS`: grid [32, N/4, 1], threadgroup [32, 16, 1], y [1, 1, N] bf16. -/
def launchOf (V : Variant) (steps blocks : Nat) (X W S B : ByteMemory.Bytes) (ax aw as ab : Nat)
    (initial : Nat → ByteMemory.Bytes) : Launch :=
  ⟨coreOf V.bits steps V.lv V.qd, (32, 16 * blocks, 1), (32, 16, 1),
    buffers (inputsOf V steps blocks X W S B ax aw as ab) [2 * (64 * blocks)] 16 initial⟩

def envOf (C : M1Max.Contract) (V : Variant) (fuse : Nat → Bool) (steps blocks : Nat) (X W S B : ByteMemory.Bytes)
    (ax aw as ab : Nat) (initial : Nat → ByteMemory.Bytes) : Env :=
  ⟨launchOf V steps blocks X W S B ax aw as ab initial, fuse, X, W, S, B, fun e => V.xt X (e / 16) (e % 16), V.cs X,
    yOf C V fuse steps X W S B⟩

section Launch
variable {C : M1Max.Contract} {V : Variant} {fuse : Nat → Bool} {steps blocks : Nat} {X W S B : ByteMemory.Bytes}
  {ax aw as ab : Nat} {initial : Nat → ByteMemory.Bytes}

theorem envOf_good : Good C V steps (envOf C V fuse steps blocks X W S B ax aw as ab initial) := ⟨fun _ => rfl, fun _ => rfl, fun _ => rfl⟩

theorem envOf_tiled (hbk : 0 < blocks) : Tiled (envOf C V fuse steps blocks X W S B ax aw as ab initial) V steps blocks where
  tiles := ⟨rfl, by show (32, 16 * blocks, 1) = (1 * 32, blocks * 16, 1 * 1); rw [Nat.mul_comm 16], rfl, by omega⟩
  buffers := by simp [envOf, launchOf, buffers, inputsOf]
  groupArrays := rfl
  threadArrays := rfl
  body := rfl

theorem envOf_shape (hax : ax % 2 = 0) (haw : aw % V.wAlign = 0) (has : as % 2 = 0) (hab : ab % 2 = 0) :
    Shape (envOf C V fuse steps blocks X W S B ax aw as ab initial).L V steps blocks ax aw as ab := by
  have hb : (launchOf V steps blocks X W S B ax aw as ab initial).buffers =
      buffers (inputsOf V steps blocks X W S B ax aw as ab) [2 * (64 * blocks)] 16 initial := rfl
  have hlen : (launchOf V steps blocks X W S B ax aw as ab initial).buffers.length = 5 := by
    simp [launchOf, buffers, inputsOf]
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, fun T => ?_, fun T => ?_, hax, haw, has, hab⟩
  · rw [show 1024 * steps = 2 * (512 * steps) by ring]; exact regions_input hb 0 (by simp [inputsOf])
  · rw [show 64 * blocks * (64 * V.bits * steps) = 4 * (64 * blocks * (16 * V.bits * steps)) by ring]
    exact regions_input hb 1 (by simp [inputsOf])
  · exact regions_input hb 2 (by simp [inputsOf])
  · exact regions_input hb 3 (by simp [inputsOf])
  · rw [show 128 * blocks = 2 * (64 * blocks) by ring]; exact regions_output hb 0 (by simp)
  · have := Launch.regions_groupArray (launchOf V steps blocks X W S B ax aw as ab initial) 0 (.scalar .f32) (512 * steps) rfl
    rw [hlen] at this
    rw [show 2048 * steps = (Ty.scalar .f32).bytes * (512 * steps) by simp [Ty.bytes, Scalar.bytes]; ring]; exact this
  · have := Launch.regions_groupArray (launchOf V steps blocks X W S B ax aw as ab initial) 1 (.scalar .f32) (32 * steps) rfl
    rw [hlen] at this
    rw [show 128 * steps = (Ty.scalar .f32).bytes * (32 * steps) by simp [Ty.bytes, Scalar.bytes]; ring]; exact this
  · have := Launch.regions_threadArray (launchOf V steps blocks X W S B ax aw as ab initial) T 0 (.scalar .f32) 16 rfl
    rw [hlen, show Launch.groupArrays _ = 2 from rfl, show Launch.threadArrays _ = 2 from rfl] at this
    rw [show 2 * T + 7 = 5 + 2 + T * 2 + 0 by ring]; exact this
  · have := Launch.regions_threadArray (launchOf V steps blocks X W S B ax aw as ab initial) T 1 (.scalar .f32) 4 rfl
    rw [hlen, show Launch.groupArrays _ = 2 from rfl, show Launch.threadArrays _ = 2 from rfl] at this
    rw [show 2 * T + 8 = 5 + 2 + T * 2 + 1 by ring]; exact this

/-- The launch: its `blocks` threadgroups in order, each writing its 64 elements of `y`. -/
theorem launch_inv (hV : LvSpec C V) (hQ : QdSpec C V) (hB : 0 < V.bits) (hB8 : V.bits < 8) (hWa : V.wAlign ∣ 2)
    (hW : 64 * blocks * (64 * V.bits * steps) < 2 ^ 31) (hst : 0 < steps) (hbk : 0 < blocks) (hax : ax % 2 = 0)
    (haw : aw % V.wAlign = 0) (has : as % 2 = 0) (hab : ab % 2 = 0) (garbage : Garbage) :
    ∃ n sh, Mem (envOf C V fuse steps blocks X W S B ax aw as ab initial) blocks (fun _ => False) (fun _ => False)
      (64 * blocks) sh ∧ runLaunch C fuse (launchOf V steps blocks X W S B ax aw as ab initial) garbage n n n =
        some ⟨sh.bytes, sh.log⟩ := by
  have hT := envOf_tiled (C := C) (V := V) (fuse := fuse) (steps := steps) (X := X) (W := W) (S := S) (B := B) (ax := ax)
    (aw := aw) (as := as) (ab := ab) (initial := initial) hbk
  have hS := envOf_shape (C := C) (fuse := fuse) (blocks := blocks) (X := X) (W := W) (S := S) (B := B) (initial := initial)
    (steps := steps) hax haw has hab
  have hb : (launchOf V steps blocks X W S B ax aw as ab initial).buffers =
      buffers (inputsOf V steps blocks X W S B ax aw as ab) [2 * (64 * blocks)] 16 initial := rfl
  have h0 : Mem (envOf C V fuse steps blocks X W S B ax aw as ab initial) 0 (fun _ => False) (fun _ => False) (64 * 0)
      ((launchOf V steps blocks X W S B ax aw as ab initial).initial garbage) :=
    { regions := rfl
      x := initial_input hb garbage 0 (by simp [inputsOf])
      w := initial_input hb garbage 1 (by simp [inputsOf])
      s := initial_input hb garbage 2 (by simp [inputsOf])
      b := initial_input hb garbage 3 (by simp [inputsOf])
      dEpoch := rfl
      gEpoch := rfl
      xs := fun _ h => h.elim
      ss := fun _ h => h.elim
      y := fun e he => absurd he (by omega)
      log := fun a ha => by simp [Launch.initial] at ha }
  obtain ⟨n, sh, hI, hr⟩ := launch_bound C hT.tiles fuse garbage
    (fun G sh => Mem (envOf C V fuse steps blocks X W S B ax aw as ab initial) G (fun _ => False) (fun _ => False) (64 * G) sh)
    h0 (fun bx byy bz hx hy hz sh hI => by
      obtain rfl : bx = 0 := by omega
      obtain rfl : bz = 0 := by omega
      have hI' : Mem (envOf C V fuse steps blocks X W S B ax aw as ab initial) byy (fun _ => False) (fun _ => False)
          (64 * byy) sh := by simpa using hI
      obtain ⟨f, r, b, sh', hr, hM'⟩ := group_run hV hQ hS envOf_good hT hB hB8 hWa hW hst byy hy _
        (hI'.reset hT.buffers garbage (0 + byy * 1 + 0 * 1 * blocks))
      exact ⟨f, r, b, sh', hr, by simpa using hM'⟩)
  exact ⟨n, sh, by simpa using hI, hr⟩

/-- **The GPU runs the affine row kernel as specified**, at any bit width whose `load_vector` and `qdot` meet their
specifications, for any text that compiles to its core. -/
theorem gpu_outputOf (hV : LvSpec C V) (hQ : QdSpec C V) (hB : 0 < V.bits) (hB8 : V.bits < 8) (hWa : V.wAlign ∣ 2)
    (G : Gpu C) (text : List Char) (hc : compile text = some (coreOf V.bits steps V.lv V.qd))
    (hmax : 512 ≤ G.maxThreads text) (hst : 0 < steps) (hbk : 0 < blocks)
    (hW : 64 * blocks * (64 * V.bits * steps) < 2 ^ 31) (hax : 2 ∣ ax) (haw : V.wAlign ∣ aw) (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute text (32, 16 * blocks, 1) (32, 16, 1) (inputsOf V steps blocks X W S B ax aw as ab) [2 * (64 * blocks)] =
      some [expectedOf C V (G.fusion text) steps blocks X W S B] := by
  have h := gpu_owned C G (grid := (32, 16 * blocks, 1)) (tg := (32, 16, 1))
    (inputs := inputsOf V steps blocks X W S B ax aw as ab) (sizes := [2 * (64 * blocks)])
    (fun _ => expectedOf C V (G.fusion text) steps blocks X W S B) hc (by simpa using hmax) (fun initial garbage => by
      obtain ⟨n, sh, hM, hr⟩ := launch_inv (C := C) (V := V) (initial := initial) (fuse := G.fusion text) (X := X) (W := W)
        (S := S) (B := B) hV hQ hB hB8 hWa hW hst hbk (Nat.mod_eq_zero_of_dvd hax) (Nat.mod_eq_zero_of_dvd haw)
        (Nat.mod_eq_zero_of_dvd has) (Nat.mod_eq_zero_of_dvd hab) garbage
      refine ⟨n, n, n, sh, dev, tgo, hr, hM.log, ?_⟩
      intro i hi b hb
      obtain rfl : i = 0 := by simp at hi; omega
      have hb' : b < 128 * blocks := by simp at hb; omega
      show sh.bytes 4 b = expectedOf C V _ steps blocks X W S B b
      have := hM.y (b / 2) (by omega) (b % 2) (by omega)
      rw [show 2 * (b / 2) + b % 2 = b by omega] at this
      rw [this]
      unfold expectedOf
      rw [ite_eq_left hb']
      rfl)
  rw [h]
  show some [fun b => if b < 2 * (64 * blocks) then expectedOf C V _ steps blocks X W S B b else 0] = _
  congr 2
  funext b
  unfold expectedOf
  by_cases hb : b < 128 * blocks
  · rw [ite_eq_left (by omega), ite_eq_left hb]
  · rw [ite_eq_right (by omega), ite_eq_right hb]

end Launch

/-! ## BITS = 3 -/

/-- `load_vector` and `qdot` at BITS = 3 (byte accesses of `w`: no alignment needed). -/
def v3 (C : M1Max.Contract) : Variant := ⟨3, 1, loadVecScope, qdotScope, xt3 C, cs3 C, qdot3 C⟩

/-- Byte `b` of `y` [1, 1, 64·blocks] bf16 at BITS = 3: element `b / 2` is `yOf` of its row, through `acc` over the K
steps, `qdot3` (with `half3`'s ten lines and `deq`), `xt3` and `cs3`. -/
def expected3 (C : M1Max.Contract) (fuse : Nat → Bool) (steps blocks : Nat) (X W S B : ByteMemory.Bytes) : Nat → BitVec 8 :=
  expectedOf C (v3 C) fuse steps blocks X W S B

/-- **The GPU runs the 3-bit affine row kernel as specified**, for any K = 512·steps and N = 64·blocks with the weight
bytes N·K·3/8 below 2^31 (the kernel's `int` offsets `row0 * ROWB`), for any text that elaborates to `core3 steps`. -/
theorem gpu_output3 (C : M1Max.Contract) (G : Gpu C) (text : List Char) (steps blocks : Nat)
    (hc : (frontend text).bind elaborate = some (core3 steps)) (hmax : 512 ≤ G.maxThreads text) (hst : 0 < steps)
    (hbk : 0 < blocks) (hW : 64 * blocks * (192 * steps) < 2 ^ 31) (X W S B : ByteMemory.Bytes) (ax aw as ab : Nat)
    (hax : 2 ∣ ax) (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute text (32, 16 * blocks, 1) (32, 16, 1)
        [⟨.device, 2 * (512 * steps), ax, X⟩, ⟨.device, 4 * (64 * blocks * (48 * steps)), aw, W⟩,
         ⟨.device, 2 * (64 * blocks * (8 * steps)), as, S⟩, ⟨.device, 2 * (64 * blocks * (8 * steps)), ab, B⟩]
        [2 * (64 * blocks)] =
      some [expected3 C (G.fusion text) steps blocks X W S B] :=
  gpu_outputOf (lv3_spec C 1 qdotScope (qdot3 C)) (qdot3_spec C loadVecScope (xt3 C) (cs3 C)) (by simp) (by simp)
    (by simp) G text hc hmax hst hbk hW hax (one_dvd _) has hab

/-! ## BITS = 4 -/

/-- `load_vector` and `qdot` at BITS = 4 (halfword accesses of `w`: 2-byte alignment). -/
def v4 (C : M1Max.Contract) : Variant := ⟨4, 2, loadVecScope4, qdotScope4, xt4 C, cs4 C, qdot4 C⟩

/-- Byte `b` of `y` [1, 1, 64·blocks] bf16 at BITS = 4: element `b / 2` is `yOf` of its row, through `acc` over the K
steps, `qdot4` (with `accum4`, `quad4` and `deq`), `xt4` and `cs4`. -/
def expected4 (C : M1Max.Contract) (fuse : Nat → Bool) (steps blocks : Nat) (X W S B : ByteMemory.Bytes) : Nat → BitVec 8 :=
  expectedOf C (v4 C) fuse steps blocks X W S B

/-- **The GPU runs the 4-bit affine row kernel as specified**, for any K = 512·steps and N = 64·blocks with the weight
bytes N·K/2 below 2^31 (the kernel's `int` offsets `row0 * ROWB`), for any text that elaborates to `core4 steps`. `w`
must be 2-aligned: `qdot` reads it as `uint16_t`. -/
theorem gpu_output4 (C : M1Max.Contract) (G : Gpu C) (text : List Char) (steps blocks : Nat)
    (hc : (frontend text).bind elaborate = some (core4 steps)) (hmax : 512 ≤ G.maxThreads text) (hst : 0 < steps)
    (hbk : 0 < blocks) (hW : 64 * blocks * (256 * steps) < 2 ^ 31) (X W S B : ByteMemory.Bytes) (ax aw as ab : Nat)
    (hax : 2 ∣ ax) (haw : 2 ∣ aw) (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute text (32, 16 * blocks, 1) (32, 16, 1)
        [⟨.device, 2 * (512 * steps), ax, X⟩, ⟨.device, 4 * (64 * blocks * (64 * steps)), aw, W⟩,
         ⟨.device, 2 * (64 * blocks * (8 * steps)), as, S⟩, ⟨.device, 2 * (64 * blocks * (8 * steps)), ab, B⟩]
        [2 * (64 * blocks)] =
      some [expected4 C (G.fusion text) steps blocks X W S B] :=
  gpu_outputOf (lv4_spec C 2 qdotScope4 (qdot4 C)) (qdot4_spec C loadVecScope4 (xt4 C) (cs4 C)) (by simp) (by simp)
    (by simp) G text hc hmax hst hbk hW hax haw has hab

/-! ## The route's instantiations -/

/-- in_proj_qkv: K = 5120, N = 10240, 3 bits. -/
theorem gpu_output_3_10_160 (C : M1Max.Contract) (G : Gpu C) (hmax : 512 ≤ G.maxThreads (text 3 10 160))
    (X W S B : ByteMemory.Bytes) (ax aw as ab : Nat) (hax : 2 ∣ ax) (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 3 10 160) (32, 2560, 1) (32, 16, 1)
        [⟨.device, 10240, ax, X⟩, ⟨.device, 19660800, aw, W⟩, ⟨.device, 1638400, as, S⟩, ⟨.device, 1638400, ab, B⟩]
        [20480] =
      some [expected3 C (G.fusion (text 3 10 160)) 10 160 X W S B] :=
  gpu_output3 C G _ 10 160 compile_3_10_160 hmax (by decide) (by decide) (by decide) X W S B ax aw as ab hax has hab

/-- K = 5120, N = 6144, 3 bits. -/
theorem gpu_output_3_10_96 (C : M1Max.Contract) (G : Gpu C) (hmax : 512 ≤ G.maxThreads (text 3 10 96))
    (X W S B : ByteMemory.Bytes) (ax aw as ab : Nat) (hax : 2 ∣ ax) (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 3 10 96) (32, 1536, 1) (32, 16, 1)
        [⟨.device, 10240, ax, X⟩, ⟨.device, 11796480, aw, W⟩, ⟨.device, 983040, as, S⟩, ⟨.device, 983040, ab, B⟩]
        [12288] =
      some [expected3 C (G.fusion (text 3 10 96)) 10 96 X W S B] :=
  gpu_output3 C G _ 10 96 compile_3_10_96 hmax (by decide) (by decide) (by decide) X W S B ax aw as ab hax has hab

/-- K = 6144, N = 5120, 3 bits. -/
theorem gpu_output_3_12_80 (C : M1Max.Contract) (G : Gpu C) (hmax : 512 ≤ G.maxThreads (text 3 12 80))
    (X W S B : ByteMemory.Bytes) (ax aw as ab : Nat) (hax : 2 ∣ ax) (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 3 12 80) (32, 1280, 1) (32, 16, 1)
        [⟨.device, 12288, ax, X⟩, ⟨.device, 11796480, aw, W⟩, ⟨.device, 983040, as, S⟩, ⟨.device, 983040, ab, B⟩]
        [10240] =
      some [expected3 C (G.fusion (text 3 12 80)) 12 80 X W S B] :=
  gpu_output3 C G _ 12 80 compile_3_12_80 hmax (by decide) (by decide) (by decide) X W S B ax aw as ab hax has hab

/-- The head: K = 5120, N = 248320, 4 bits. -/
theorem gpu_output_4_10_3880 (C : M1Max.Contract) (G : Gpu C) (hmax : 512 ≤ G.maxThreads (text 4 10 3880))
    (X W S B : ByteMemory.Bytes) (ax aw as ab : Nat) (hax : 2 ∣ ax) (haw : 2 ∣ aw) (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute (text 4 10 3880) (32, 62080, 1) (32, 16, 1)
        [⟨.device, 10240, ax, X⟩, ⟨.device, 635699200, aw, W⟩, ⟨.device, 39731200, as, S⟩, ⟨.device, 39731200, ab, B⟩]
        [496640] =
      some [expected4 C (G.fusion (text 4 10 3880)) 10 3880 X W S B] :=
  gpu_output4 C G _ 10 3880 compile_4_10_3880 hmax (by decide) (by decide) (by decide) X W S B ax aw as ab hax haw has hab

/-- **The GPU runs MLX's text for `affineConfig 5120 10240 3` as specified** (`text 3 10 160`). -/
theorem gpu_output (C : M1Max.Contract) (G : Gpu C) (hmax : 512 ≤ G.maxThreads Metal.Elab.Tests.affineRowText)
    (X W S B : ByteMemory.Bytes) (ax aw as ab : Nat) (hax : 2 ∣ ax) (has : 2 ∣ as) (hab : 2 ∣ ab) :
    G.execute Metal.Elab.Tests.affineRowText (32, 2560, 1) (32, 16, 1)
        [⟨.device, 10240, ax, X⟩, ⟨.device, 19660800, aw, W⟩, ⟨.device, 1638400, as, S⟩, ⟨.device, 1638400, ab, B⟩]
        [20480] =
      some [expected3 C (G.fusion Metal.Elab.Tests.affineRowText) 10 160 X W S B] :=
  gpu_output3 C G _ 10 160 compile_eq hmax (by decide) (by decide) (by decide) X W S B ax aw as ab hax has hab

end Metal.Kernels.AffineRow
