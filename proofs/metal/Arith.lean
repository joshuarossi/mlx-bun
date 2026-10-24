import metal.Steps
import metal.Bytes

namespace Metal
open Core Inference.Contracts.Mlx

/-! # Values and expressions

The scalar operations on values of the types the kernels use (`binary`, `convert`, `bitcast` at `uint`,
`int`, `ulong`, `long`, `float`, `bfloat`), `int` values as two's-complement words (`i32`), pointers to
buffers, and evaluation lemmas for the expressions built from them: literals, coordinates, pointer offsets
and the contraction sites' products and sums. -/


/-! ## `int` values -/

/-- An `int` value: its two's-complement word. -/
def i32 (v : Int) : Val := .int .i32 (v % 2 ^ 32).toNat

theorem i32_nat (n : Nat) (h : n < 2 ^ 32) : i32 n = .int .i32 n := by
  unfold i32; congr 1; omega

theorem signed_i32v {v : Int} (h1 : -2 ^ 31 ≤ v) (h2 : v < 2 ^ 31) : Val.signed .i32 (v % 2 ^ 32).toNat = v := by
  simp only [Val.signed, Scalar.isSigned, Scalar.width, Scalar.bytes, true_and]
  split <;> omega

theorem wrap_i32v {v : Int} (h1 : -2 ^ 31 ≤ v) (h2 : v < 2 ^ 31) : Val.wrap .i32 v = some (v % 2 ^ 32).toNat := by
  have e : Val.wrap .i32 v = if -(2 : Int) ^ 31 ≤ v ∧ v < 2 ^ 31 then some (v % 2 ^ 32).toNat else none := rfl
  rw [e, ite_eq_left_iff.mpr (fun h => absurd ⟨h1, h2⟩ h)]

theorem signed_i64v {v : Int} (h1 : -2 ^ 63 ≤ v) (h2 : v < 2 ^ 63) : Val.signed .i64 (v % 2 ^ 64).toNat = v := by
  simp only [Val.signed, Scalar.isSigned, Scalar.width, Scalar.bytes, true_and]
  split <;> omega

theorem u32_mod (n : Nat) : u32 (n % 2 ^ 32) = u32 n := by simp [u32]

theorem u64_mod (n : Nat) : u64 (n % 2 ^ 64) = u64 n := by simp [u64]

/-! ## Operations -/

section Ops
variable (C : M1Max.Contract)

theorem binary_sub_i32v {a b : Int} (ha1 : -2 ^ 31 ≤ a) (ha2 : a < 2 ^ 31) (hb1 : -2 ^ 31 ≤ b) (hb2 : b < 2 ^ 31)
    (h1 : -2 ^ 31 ≤ a - b) (h2 : a - b < 2 ^ 31) : binary C .sub .i32 (i32 a) (i32 b) = some (i32 (a - b)) := by
  simp only [binary, i32, Scalar.isInt, and_self, ite_true, signed_i32v ha1 ha2, signed_i32v hb1 hb2,
    wrap_i32v h1 h2, Option.map_some]

theorem binary_add_i32v {a b : Int} (ha1 : -2 ^ 31 ≤ a) (ha2 : a < 2 ^ 31) (hb1 : -2 ^ 31 ≤ b) (hb2 : b < 2 ^ 31)
    (h1 : -2 ^ 31 ≤ a + b) (h2 : a + b < 2 ^ 31) : binary C .add .i32 (i32 a) (i32 b) = some (i32 (a + b)) := by
  simp only [binary, i32, Scalar.isInt, and_self, ite_true, signed_i32v ha1 ha2, signed_i32v hb1 hb2,
    wrap_i32v h1 h2, Option.map_some]

theorem binary_ge_i32v {a b : Int} (ha1 : -2 ^ 31 ≤ a) (ha2 : a < 2 ^ 31) (hb1 : -2 ^ 31 ≤ b) (hb2 : b < 2 ^ 31) :
    binary C .ge .i32 (i32 a) (i32 b) = some (.bool (decide (b ≤ a))) := by
  simp only [binary, i32, Scalar.isInt, and_self, ite_true, signed_i32v ha1 ha2, signed_i32v hb1 hb2, intCompare,
    ordered_ge_compare, Option.map_some]

/-- `(a - b) + b` of `int`s, `a` and `b` naturals. -/
theorem binary_add_i32_sub {a b : Nat} (ha : a < 2 ^ 31) (hb : b < 2 ^ 31) :
    binary C .add .i32 (i32 ((a : Int) - b)) (.int .i32 b) = some (.int .i32 a) := by
  have h := binary_add_i32v C (a := (a : Int) - b) (b := (b : Int)) (by omega) (by omega) (by omega) (by omega)
    (by omega) (by omega)
  rwa [i32_nat b (by omega), show (a : Int) - b + b = (a : Int) by omega, i32_nat a (by omega)] at h

theorem binary_bitAnd_i32 (x y : Nat) : binary C .bitAnd .i32 (.int .i32 x) (.int .i32 y) = some (.int .i32 (x &&& y)) := by
  simp [binary, Scalar.isInt]

theorem binary_shr_i32 {a b : Nat} (ha : a < 2 ^ 31) (hb : b < 32) :
    binary C .shr .i32 (.int .i32 a) (.int .i32 b) = some (.int .i32 (a / 2 ^ b)) := by
  have hw : Val.wrap .i32 ((a : Int) / 2 ^ b) = some (a / 2 ^ b) := by
    rw [show (a : Int) / 2 ^ b = ((a / 2 ^ b : Nat) : Int) by push_cast; rfl]
    exact wrap_i32 (lt_of_le_of_lt (Nat.div_le_self _ _) ha)
  simp [binary, Scalar.isInt, signed_i32 ha, signed_i32 (show b < 2 ^ 31 by omega), Scalar.width, Scalar.bytes,
    show b < 32 from hb, hw]

/-- `/` on `ulong`. -/
theorem binary_div_u64 {a b : Nat} (ha : a < 2 ^ 64) (hb : b < 2 ^ 64) (h : 0 < b) :
    binary C .div .u64 (u64 a) (u64 b) = some (u64 (a / b)) := by
  rw [← u64_lit ha, ← u64_lit hb]
  simp [binary, u64, Val.signed, Val.wrap, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  refine ⟨by omega, ?_⟩
  rw [show (a : Int) / b = ((a / b : Nat) : Int) by push_cast; rfl]
  generalize a / b = m
  omega

/-- f32 `<`: true exactly when the hardware comparison orders the operands. -/
theorem binary_lt_f32 (x y : Float32) :
    binary C .lt .f32 (.f32 x) (.f32 y) = some (.bool (decide (f32Compare x y = some .lt))) := by
  simp only [binary]
  generalize f32Compare x y = o
  rcases o with _ | (_ | _ | _) <;> rfl

theorem binary_lt_bf16 (a b : BF) :
    binary C .lt .bf16 (.bf16 a) (.bf16 b) = some (.bool (decide (f32Compare (C.widen a) (C.widen b) = some .lt))) := by
  show (ordered .lt (f32Compare (C.widen a) (C.widen b))).map Val.bool = _
  cases f32Compare (C.widen a) (C.widen b) with
  | none => rfl
  | some o => cases o <;> rfl

theorem convert_i32_u8 {w : Nat} (h : w < 256) : convert C .i32 (.int .u8 w) = some (.int .i32 w) := by
  simp [convert, Val.signed, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  omega

theorem convert_i32_u16 {w : Nat} (h : w < 65536) : convert C .i32 (.int .u16 w) = some (.int .i32 w) := by
  simp [convert, Val.signed, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  omega

theorem convert_u32_u8 {w : Nat} (_h : w < 256) : convert C .u32 (.int .u8 w) = some (u32 w) := by
  simp [convert, u32, Val.signed, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  omega

theorem convert_f32_bf16 (x : BF) : convert C .f32 (.bf16 x) = some (.f32 (C.widen x)) := rfl

theorem convert_bf16_f32 (x : Float32) : convert C .bf16 (.f32 x) = some (.bf16 (C.narrow x)) := rfl

theorem convert_f32_f32 (x : Float32) : convert C .f32 (.f32 x) = some (.f32 x) := rfl

theorem bitcast_f32_u32 (w : Nat) (h : w < 2 ^ 32) : bitcast .f32 (u32 w) = some (.f32 (Val.ofF32Bits w)) := by
  rw [← u32_lit h]; rfl

section U64
variable (a b : Nat)

theorem binary_shl_u64 (hb : b < 64) : binary C .shl .u64 (u64 a) (u64 b) = some (u64 (a * 2 ^ b)) := by
  rw [← u64_lit (show b < 2 ^ 64 by omega)]
  simp [binary, u64, Val.signed, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  omega

theorem binary_shr_u64 (ha : a < 2 ^ 64) (hb : b < 64) :
    binary C .shr .u64 (u64 a) (u64 b) = some (u64 (a / 2 ^ b)) := by
  rw [← u64_lit ha, ← u64_lit (show b < 2 ^ 64 by omega)]
  simp [binary, u64, Val.signed, Val.wrap, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  refine ⟨hb, ?_⟩
  rw [show (a : Int) / 2 ^ b = ((a / 2 ^ b : Nat) : Int) by push_cast; rfl]
  generalize a / 2 ^ b = m
  omega

theorem binary_bitOr_u64 (ha : a < 2 ^ 64) (hb : b < 2 ^ 64) :
    binary C .bitOr .u64 (u64 a) (u64 b) = some (u64 (a ||| b)) := by
  rw [← u64_lit ha, ← u64_lit hb, ← u64_lit (Nat.or_lt_two_pow ha hb)]
  simp [binary, Scalar.isInt]

theorem convert_u32_u64 : convert C .u32 (u64 a) = some (u32 a) := by
  simp [convert, u64, u32, Val.signed, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]
  omega

/-- `a - b` of two non-negative `int`s, as an `int` value. -/
theorem binary_sub_i32_nat (ha : a < 2 ^ 31) (hb : b < 2 ^ 31) :
    binary C .sub .i32 (.int .i32 a) (.int .i32 b) = some (i32 ((a : Int) - b)) := by
  have h := binary_sub_i32v C (a := a) (b := b) (by omega) (by omega) (by omega) (by omega) (by omega) (by omega)
  rwa [i32_nat a (by omega), i32_nat b (by omega)] at h

/-- `(float)y` of an `int` of magnitude at most 2^24: its exact binary32. -/
theorem convert_f32_i32v {v : Int} (h1 : -2 ^ 24 ≤ v) (h2 : v ≤ 2 ^ 24) :
    convert C .f32 (i32 v) = some (.f32 (Val.ofF32Bits (exactF32 v))) := by
  have hs := signed_i32v (v := v) (by omega) (by omega)
  have hna : v.natAbs ≤ 2 ^ 24 := by rcases Int.natAbs_eq v with h | h <;> omega
  simp only [convert, i32, hs]
  simp [Scalar.isInt]
  exact hna

end U64

end Ops

theorem ordered_gt_some (o : Option Ordering) : ordered .gt o = some (decide (o = some .gt)) := by
  rcases o with _ | (_ | _ | _) <;> rfl

theorem ordered_eq_some (o : Option Ordering) : ordered .eq o = some (decide (o = some .eq)) := by
  rcases o with _ | (_ | _ | _) <;> rfl

theorem nf_bf16 (b : Bool) : ¬(b = true ∧ Scalar.bf16 = .f32) := fun h => Scalar.noConfusion h.2

theorem mix_succ {α : Type} (x y : Nat → α) (k j : Nat) :
    (if j = k then x k else if j < k then x j else y j) = if j < k + 1 then x j else y j := by
  by_cases h : j = k
  · subst h; simp
  · by_cases h' : j < k
    · simp [h, h', show j < k + 1 by omega]
    · simp [h, h', show ¬ j < k + 1 by omega]

/-! ## Locals and resumed threads -/

theorem setLocal_lt {l : Locals} {j slot : Nat} (v : Val) (h : j < slot) : setLocal l slot v j = l j :=
  setLocal_other l v (by omega)

theorem setLocal_setLocal (l : Locals) (s : Nat) (v w : Val) : setLocal (setLocal l s v) s w = setLocal l s w := by
  funext i; simp only [setLocal]; split <;> rfl

theorem setLocal_self {l : Locals} {s : Nat} {v : Val} (h : l s = some v) : setLocal l s v = l := by
  funext i; simp only [setLocal]; split
  · subst_vars; exact h.symm
  · rfl

/-- A stopped thread resumed by its SIMD-group (`runSimd`), as a literal. -/
theorem resume_eq (t : Thread) (ctx : Ctx) (F : List Frame) (hc : t.ctx = ctx) (hf : t.frames = F) (slot : Nat)
    (v : Val) : { t with status := .running }.set slot v = ⟨ctx, setLocal t.locals slot v, F, .running⟩ := by
  obtain ⟨c, l, f, s⟩ := t
  simp only at hc hf
  subst hc hf
  rfl

/-- A thread resumed after a barrier (`runGroup`), as a literal. -/
theorem run_eq (t : Thread) (ctx : Ctx) (F : List Frame) (hc : t.ctx = ctx) (hf : t.frames = F) :
    { t with status := .running } = ⟨ctx, t.locals, F, .running⟩ := by
  obtain ⟨c, l, f, s⟩ := t
  simp only at hc hf
  subst hc hf
  rfl

/-! ## Expressions -/

/-- A bf16 pointer to the start of buffer `r`. -/
def ptr (r : Nat) : Val := .ptr ⟨r, 0, .scalar .bf16⟩

/-- An f32 pointer to the start of region `r`. -/
def fptr (r : Nat) : Val := .ptr ⟨r, 0, .scalar .f32⟩

section Eval
variable (C : M1Max.Contract)

/-- Component `x` of a `uint3` coordinate. -/
theorem eval_coord_x {ctx : Ctx} {l : Locals} {c : Coord} {a b d : Nat} (h : ctx.coord c = u32x3 a b d) (sh : Shared) :
    (eval C ctx l (.component (.coord c) (.lit (.int .u32 0)))).run sh = some (u32 a, sh) := by
  have hv : (eval C ctx l (.coord c)).run sh = some (.vec .u32 [u32 a, u32 b, u32 d], sh) := by
    rw [eval_coord, h]; rfl
  exact eval_component C hv (eval_lit C _ _ _ _) rfl rfl

/-- A bf16 pointer moved by a `u32` index. -/
theorem eval_index {ctx : Ctx} {l : Locals} {r slot n : Nat} (hr : l r = some (ptr r)) (hs : l slot = some (u32 n))
    (hn : n < 2 ^ 32) (sh : Shared) :
    (eval C ctx l (.offset (.local r) (.local slot))).run sh =
      some (.ptr ⟨r, ((2 * n : Nat) : Int), .scalar .bf16⟩, sh) := by
  have := eval_offset_u32 C (o := 0) (eval_local' C (ctx := ctx) hr sh) (eval_local' C (ctx := ctx) hs sh) hn
  rwa [show 0 + n * (Ty.scalar .bf16).bytes = 2 * n by simp only [Ty.bytes, Scalar.bytes]; omega] at this

/-- An f32 pointer moved by a `u32` index. -/
theorem eval_index4 {ctx : Ctx} {l : Locals} {a r slot n : Nat} (hr : l a = some (fptr r)) (hs : l slot = some (u32 n))
    (hn : n < 2 ^ 32) (sh : Shared) :
    (eval C ctx l (.offset (.local a) (.local slot))).run sh =
      some (.ptr ⟨r, ((4 * n : Nat) : Int), .scalar .f32⟩, sh) := by
  have := eval_offset_u32 C (o := 0) (eval_local' C (ctx := ctx) hr sh) (eval_local' C (ctx := ctx) hs sh) hn
  rwa [show 0 + n * (Ty.scalar .f32).bytes = 4 * n by simp only [Ty.bytes, Scalar.bytes]; omega] at this

/-- A bf16 pointer moved by a `u32` index. -/
theorem eval_bf16_base {ctx : Ctx} {l : Locals} {sh sh₁ sh₂ : Shared} {p i : CExpr} {r n : Nat}
    (hp : (eval C ctx l p).run sh = some (.ptr ⟨r, 0, .scalar .bf16⟩, sh₁))
    (hi : (eval C ctx l i).run sh₁ = some (u32 n, sh₂)) (hn : n < 2 ^ 32) :
    (eval C ctx l (.offset p i)).run sh = some (.ptr ⟨r, ((2 * n : Nat) : Int), .scalar .bf16⟩, sh₂) := by
  have := eval_offset_u32 C (o := 0) hp hi hn
  rw [show 0 + n * (Ty.scalar .bf16).bytes = 2 * n by simp [Ty.bytes, Scalar.bytes, Nat.mul_comm]] at this
  exact this

/-- A bf16 pointer at element `a` moved by a `u32` index. -/
theorem eval_bf16 {ctx : Ctx} {l : Locals} {sh sh₁ sh₂ : Shared} {p i : CExpr} {r a n : Nat}
    (hp : (eval C ctx l p).run sh = some (.ptr ⟨r, ((2 * a : Nat) : Int), .scalar .bf16⟩, sh₁))
    (hi : (eval C ctx l i).run sh₁ = some (u32 n, sh₂)) (hn : n < 2 ^ 32) :
    (eval C ctx l (.offset p i)).run sh = some (.ptr ⟨r, ((2 * (a + n) : Nat) : Int), .scalar .bf16⟩, sh₂) := by
  have := eval_offset_u32 C hp hi hn
  rw [show 2 * a + n * (Ty.scalar .bf16).bytes = 2 * (a + n) by simp [Ty.bytes, Scalar.bytes]; ring] at this
  exact this

/-- A binary32 pointer at element `a` moved by a `u32` index. -/
theorem eval_f32p {ctx : Ctx} {l : Locals} {sh sh₁ sh₂ : Shared} {p i : CExpr} {r a n : Nat}
    (hp : (eval C ctx l p).run sh = some (.ptr ⟨r, ((4 * a : Nat) : Int), .scalar .f32⟩, sh₁))
    (hi : (eval C ctx l i).run sh₁ = some (u32 n, sh₂)) (hn : n < 2 ^ 32) :
    (eval C ctx l (.offset p i)).run sh = some (.ptr ⟨r, ((4 * (a + n) : Nat) : Int), .scalar .f32⟩, sh₂) := by
  have := eval_offset_u32 C hp hi hn
  rw [show 4 * a + n * (Ty.scalar .f32).bytes = 4 * (a + n) by simp [Ty.bytes, Scalar.bytes]; ring] at this
  exact this

/-- A binary32 pointer at element `a` moved by a non-negative `int` index. -/
theorem eval_f32i {ctx : Ctx} {l : Locals} {sh sh₁ sh₂ : Shared} {p i : CExpr} {r a n : Nat}
    (hp : (eval C ctx l p).run sh = some (.ptr ⟨r, ((4 * a : Nat) : Int), .scalar .f32⟩, sh₁))
    (hi : (eval C ctx l i).run sh₁ = some (.int .i32 n, sh₂)) (hn : n < 2 ^ 31) :
    (eval C ctx l (.offset p i)).run sh = some (.ptr ⟨r, ((4 * (a + n) : Nat) : Int), .scalar .f32⟩, sh₂) := by
  have := eval_offset_i32 C hp hi hn
  rw [show 4 * a + n * (Ty.scalar .f32).bytes = 4 * (a + n) by simp [Ty.bytes, Scalar.bytes]; ring] at this
  exact this

theorem eval_cond_same {ctx : Ctx} {l : Locals} {sh sh₁ sh₂ : Shared} {c a : CExpr} {v : Bool}
    {w : Val} (hc : (eval C ctx l c).run sh = some (.bool v, sh₁)) (ha : (eval C ctx l a).run sh₁ = some (w, sh₂)) :
    (eval C ctx l (.cond c a a)).run sh = some (w, sh₂) :=
  eval_cond C hc (by rw [ite_self]; exact ha)

/-- `z + x * y` (`z` not a product) under either choice of the compiler at `site`, the operands' memory
effects in either evaluation order: `z` reads nothing that changes, `x` and `y` may log. -/
theorem eval_add_mul_mem {ctx : Ctx} {l : Locals} {sh sh₁ sh₂ : Shared} {site m : Nat} {x y z : CExpr}
    {p q r : Float32} (hm : isMulF32 z = false)
    (hx : (eval C ctx l x).run sh = some (.f32 p, sh₁)) (hy : (eval C ctx l y).run sh₁ = some (.f32 q, sh₂))
    (hz : (eval C ctx l z).run sh = some (.f32 r, sh)) (hz' : (eval C ctx l z).run sh₂ = some (.f32 r, sh₂)) :
    (eval C ctx l (.bin .add .f32 site z (.bin .mul .f32 m x y))).run sh =
      some (.f32 (if ctx.fuse site then C.fma p q r else C.fadd r (C.fmul p q)), sh₂) := by
  cases hf : ctx.fuse site
  · exact eval_bin C (by simp [hf]) hz (eval_bin_plain C (.inl ⟨by decide, by decide⟩) hx hy rfl) rfl
  · exact eval_fma_add_mul C hf hm hx hy hz'

end Eval

section Eval
variable (C : M1Max.Contract) {ctx : Ctx}

/-- A `uint` operation on `uint` operands. -/
theorem eval_bin_u32 {op : Core.BinOp} {site : Nat} {a b : CExpr} {l : Locals} {sh : Shared} {x y : Nat} {z : Val}
    (ha : (eval C ctx l a).run sh = some (u32 x, sh)) (hb : (eval C ctx l b).run sh = some (u32 y, sh))
    (hz : binary C op .u32 (u32 x) (u32 y) = some z) : (eval C ctx l (.bin op .u32 site a b)).run sh = some (z, sh) :=
  eval_int C (by decide) ha hb hz

theorem eval_u32lit (l : Locals) (sh : Shared) (n : Nat) (h : n < 2 ^ 32) :
    (eval C ctx l (.lit (.int .u32 n))).run sh = some (u32 n, sh) := by
  rw [← u32_lit h]; rfl

theorem eval_u64lit (l : Locals) (sh : Shared) (n : Nat) (h : n < 2 ^ 64) :
    (eval C ctx l (.lit (.int .u64 n))).run sh = some (u64 n, sh) := by
  rw [← u64_lit h]; rfl

/-- `lane == 0`-style tests. -/
theorem eval_eq_u32 {l : Locals} {sh : Shared} {i a b : Nat} (h : l i = some (u32 a)) (ha : a < 2 ^ 32) (hb : b < 2 ^ 32) :
    (eval C ctx l (.bin .eq .u32 0 (.local i) (.lit (.int .u32 b)))).run sh = some (.bool (decide (a = b)), sh) :=
  eval_bin_u32 C (eval_local' C h sh) (eval_u32lit C l sh b hb) (binary_eq_u32 C a b ha hb)

theorem eval_lt_u32 {l : Locals} {sh : Shared} {i a b : Nat} (h : l i = some (u32 a)) (ha : a < 2 ^ 32) (hb : b < 2 ^ 32) :
    (eval C ctx l (.bin .lt .u32 0 (.local i) (.lit (.int .u32 b)))).run sh = some (.bool (decide (a < b)), sh) :=
  eval_bin_u32 C (eval_local' C h sh) (eval_u32lit C l sh b hb) (binary_lt_u32 C a b ha hb)

/-- A pointer at byte 0 of region `r` moved by a `uint` index `n`. -/
theorem eval_ptr_u32 {l : Locals} {sh : Shared} {p i : CExpr} {r n : Nat} {e : Ty}
    (hp : (eval C ctx l p).run sh = some (.ptr ⟨r, 0, e⟩, sh)) (hi : (eval C ctx l i).run sh = some (u32 n, sh))
    (hn : n < 2 ^ 32) : (eval C ctx l (.offset p i)).run sh = some (.ptr ⟨r, ((n * e.bytes : Nat) : Int), e⟩, sh) := by
  have h := eval_offset_u32 C (o := 0) hp hi hn
  rwa [Nat.zero_add] at h

/-- `-(long)x` for a `uint` `x`. -/
theorem eval_neg_i64 {l : Locals} {sh : Shared} {e : CExpr} {a : Nat}
    (he : (eval C ctx l e).run sh = some (u32 a, sh)) (ha : a < 2 ^ 31) :
    (eval C ctx l (.un .neg .i64 (.conv .i64 e))).run sh = some (.int .i64 ((-(a : Int)) % 2 ^ 64).toNat, sh) := by
  have hconv : lift1 (convert C .i64) (u32 a) = some (.int .i64 a) := by
    simp [lift1, convert, u32, Val.signed, Scalar.isSigned, Scalar.isInt, Scalar.width, Scalar.bytes]; omega
  refine eval_un C (eval_conv C he hconv) ?_
  have hs : Val.signed .i64 a = a := by
    simp only [Val.signed, Scalar.isSigned, Scalar.width, Scalar.bytes, true_and]; rw [ite_eq_right (by omega)]
  have hw : Val.wrap .i64 (-(a : Int)) = some ((-(a : Int)) % 2 ^ 64).toNat := by
    have e : Val.wrap .i64 (-(a : Int)) = if -(2 : Int) ^ 63 ≤ -(a : Int) ∧ -(a : Int) < 2 ^ 63 then
        some ((-(a : Int)) % 2 ^ 64).toNat else none := rfl
    rw [e, ite_eq_left ⟨by omega, by omega⟩]
  simp only [lift1, unary, Scalar.isInt, and_self, ite_true, hs, hw, Option.map_some]

/-- `-(int)x` for a `uint` `x`. -/
theorem eval_neg_i32 {l : Locals} {sh : Shared} {e : CExpr} {a : Nat}
    (he : (eval C ctx l e).run sh = some (u32 a, sh)) (ha : a < 2 ^ 31) :
    (eval C ctx l (.un .neg .i32 (.conv .i32 e))).run sh = some (.int .i32 ((-(a : Int)) % 2 ^ 32).toNat, sh) := by
  have hconv : lift1 (convert C .i32) (u32 a) = some (.int .i32 a) := convert_i32_u32 C a ha
  refine eval_un C (eval_conv C he hconv) ?_
  have hw : Val.wrap .i32 (-(a : Int)) = some ((-(a : Int)) % 2 ^ 32).toNat :=
    wrap_i32v (by omega) (by omega)
  simp only [lift1, unary, Scalar.isInt, and_self, ite_true, signed_i32 ha, hw, Option.map_some]

/-- A pointer at byte offset `o` moved back by `n` elements (a negated `uint` index). -/
theorem eval_offset_back {l : Locals} {sh : Shared} {p i : CExpr} {r o n : Nat} {e : Ty} {sc : Scalar} {w : Nat}
    (hp : (eval C ctx l p).run sh = some (.ptr ⟨r, (o : Int), e⟩, sh))
    (hi : (eval C ctx l i).run sh = some (.int sc w, sh)) (hw : Val.signed sc w = -(n : Int)) (hn : n * e.bytes ≤ o) :
    (eval C ctx l (.offset p i)).run sh = some (.ptr ⟨r, ((o - n * e.bytes : Nat) : Int), e⟩, sh) := by
  rw [eval_offset C hp hi, hw]
  congr 3
  push_cast [hn]
  ring_nf

end Eval

section Eval
variable (C : M1Max.Contract) {ctx : Ctx} {l : Locals} {sh : Shared}

theorem eval_i32lit (n : Nat) (h : n < 2 ^ 32) : (eval C ctx l (.lit (.int .i32 n))).run sh = some (i32 n, sh) := by
  rw [i32_nat n h]; rfl

theorem eval_i32lit_raw (n : Nat) : (eval C ctx l (.lit (.int .i32 n))).run sh = some (.int .i32 n, sh) :=
  rfl

/-- Component `x` of a `uint3` coordinate. -/
theorem eval_coord0 {c : Coord} {a b d : Nat} (h : ctx.coord c = u32x3 a b d) :
    (eval C ctx l (.component (.coord c) (.lit (.int .u32 0)))).run sh = some (u32 a, sh) := by
  have hv : (eval C ctx l (.coord c)).run sh = some (.vec .u32 [u32 a, u32 b, u32 d], sh) := by rw [eval_coord, h]; rfl
  exact eval_component C hv (eval_lit C _ _ _ _) (natOf_unsigned 0 rfl) rfl

/-- Component `y` of a `uint3` coordinate. -/
theorem eval_coord1 {c : Coord} {a b d : Nat} (h : ctx.coord c = u32x3 a b d) :
    (eval C ctx l (.component (.coord c) (.lit (.int .u32 1)))).run sh = some (u32 b, sh) := by
  have hv : (eval C ctx l (.coord c)).run sh = some (.vec .u32 [u32 a, u32 b, u32 d], sh) := by rw [eval_coord, h]; rfl
  exact eval_component C hv (eval_lit C _ _ _ _) (natOf_unsigned 1 rfl) rfl

theorem eval_coord2 {c : Coord} {a b d : Nat} (h : ctx.coord c = u32x3 a b d) :
    (eval C ctx l (.component (.coord c) (.lit (.int .u32 2)))).run sh = some (u32 d, sh) := by
  have hv : (eval C ctx l (.coord c)).run sh = some (.vec .u32 [u32 a, u32 b, u32 d], sh) := by rw [eval_coord, h]; rfl
  exact eval_component C hv (eval_lit C _ _ _ _) (natOf_unsigned 2 rfl) rfl

theorem eval_toU64 {e : CExpr} {a : Nat} (he : (eval C ctx l e).run sh = some (u32 a, sh)) (ha : a < 2 ^ 32) :
    (eval C ctx l (.conv .u64 e)).run sh = some (u64 a, sh) :=
  eval_conv C he (convert_u64_u32 C a ha)

theorem eval_mul_u64 {a b : CExpr} {site x y : Nat} (ha : (eval C ctx l a).run sh = some (u64 x, sh))
    (hb : (eval C ctx l b).run sh = some (u64 y, sh)) :
    (eval C ctx l (.bin .mul .u64 site a b)).run sh = some (u64 (x * y), sh) :=
  eval_int C (by decide) ha hb (binary_mul_u64 C x y)

theorem eval_add_u64 {a b : CExpr} {site x y : Nat} (ha : (eval C ctx l a).run sh = some (u64 x, sh))
    (hb : (eval C ctx l b).run sh = some (u64 y, sh)) :
    (eval C ctx l (.bin .add .u64 site a b)).run sh = some (u64 (x + y), sh) :=
  eval_int C (by decide) ha hb (binary_add_u64 C x y)

end Eval

section Eval
variable (C : M1Max.Contract) {ctx : Ctx} {l : Locals} {sh sh₁ sh₂ : Shared}

/-- `r + x * y` with `r` a local, under either choice of the compiler at `site`; `x` and `y` may read memory. -/
theorem eval_local_add_mul {site m slot : Nat} {x y : CExpr} {p q r : Float32} (hl : l slot = some (.f32 r))
    (hx : (eval C ctx l x).run sh = some (.f32 p, sh₁)) (hy : (eval C ctx l y).run sh₁ = some (.f32 q, sh₂)) :
    (eval C ctx l (.bin .add .f32 site (.local slot) (.bin .mul .f32 m x y))).run sh =
      some (.f32 (if ctx.fuse site then C.fma p q r else C.fadd r (C.fmul p q)), sh₂) := by
  cases hf : ctx.fuse site
  · exact eval_bin C (by simp [hf]) (eval_local' C hl sh) (eval_bin_plain C (.inl ⟨by decide, by decide⟩) hx hy rfl) rfl
  · exact eval_fma_add_mul C hf rfl hx hy (eval_local' C hl _)

/-- A pointer moved by an `int` index. -/
theorem eval_ptr_i32 {p i : CExpr} {r o n : Nat} {t : Ty} (hp : (eval C ctx l p).run sh = some (.ptr ⟨r, (o : Int), t⟩, sh₁))
    (hi : (eval C ctx l i).run sh₁ = some (.int .i32 n, sh₂)) (hn : n < 2 ^ 31) :
    (eval C ctx l (.offset p i)).run sh = some (.ptr ⟨r, ((o + n * t.bytes : Nat) : Int), t⟩, sh₂) :=
  eval_offset_i32 C hp hi hn

end Eval

section EvalP
variable {C : M1Max.Contract} {ctx : Ctx} {l : Locals}

/-- `x * y + z` under either choice at `site`, the operands reading memory within an invariant `P`. -/
theorem eval_mul_add_P {site m : Nat} {x y z : CExpr} {p q r : Float32} (P : Shared → Prop)
    (hx : ∀ sh, P sh → ∃ sh', (eval C ctx l x).run sh = some (.f32 p, sh') ∧ P sh')
    (hy : ∀ sh, P sh → ∃ sh', (eval C ctx l y).run sh = some (.f32 q, sh') ∧ P sh')
    (hz : ∀ sh, P sh → ∃ sh', (eval C ctx l z).run sh = some (.f32 r, sh') ∧ P sh') (sh : Shared) (h : P sh) :
    ∃ sh', (eval C ctx l (.bin .add .f32 site (.bin .mul .f32 m x y) z)).run sh =
      some (.f32 (if ctx.fuse site then C.fma p q r else C.fadd (C.fmul p q) r), sh') ∧ P sh' := by
  obtain ⟨sh₁, h₁, p₁⟩ := hx sh h
  obtain ⟨sh₂, h₂, p₂⟩ := hy sh₁ p₁
  obtain ⟨sh₃, h₃, p₃⟩ := hz sh₂ p₂
  refine ⟨sh₃, ?_, p₃⟩
  cases hf : ctx.fuse site
  · exact eval_bin C (by simp [hf]) (eval_bin_plain C (.inl ⟨by decide, by decide⟩) h₁ h₂ rfl) h₃ rfl
  · exact eval_fma_mul_add C hf h₁ h₂ h₃

/-- `z + x * y` (`z` not a product) under either choice at `site`, the operands reading memory within `P`. -/
theorem eval_add_mul_P {site m : Nat} {x y z : CExpr} {p q r : Float32} (hm : isMulF32 z = false) (P : Shared → Prop)
    (hx : ∀ sh, P sh → ∃ sh', (eval C ctx l x).run sh = some (.f32 p, sh') ∧ P sh')
    (hy : ∀ sh, P sh → ∃ sh', (eval C ctx l y).run sh = some (.f32 q, sh') ∧ P sh')
    (hz : ∀ sh, P sh → ∃ sh', (eval C ctx l z).run sh = some (.f32 r, sh') ∧ P sh') (sh : Shared) (h : P sh) :
    ∃ sh', (eval C ctx l (.bin .add .f32 site z (.bin .mul .f32 m x y))).run sh =
      some (.f32 (if ctx.fuse site then C.fma p q r else C.fadd r (C.fmul p q)), sh') ∧ P sh' := by
  cases hf : ctx.fuse site
  · obtain ⟨sh₁, h₁, p₁⟩ := hz sh h
    obtain ⟨sh₂, h₂, p₂⟩ := hx sh₁ p₁
    obtain ⟨sh₃, h₃, p₃⟩ := hy sh₂ p₂
    exact ⟨sh₃, eval_bin C (by simp [hf]) h₁ (eval_bin_plain C (.inl ⟨by decide, by decide⟩) h₂ h₃ rfl) rfl, p₃⟩
  · obtain ⟨sh₁, h₁, p₁⟩ := hx sh h
    obtain ⟨sh₂, h₂, p₂⟩ := hy sh₁ p₁
    obtain ⟨sh₃, h₃, p₃⟩ := hz sh₂ p₂
    exact ⟨sh₃, eval_fma_add_mul C hf hm h₁ h₂ h₃, p₃⟩

/-- A plain f32 product, the operands reading memory within `P`. -/
theorem eval_mul_P {x y : CExpr} {p q : Float32} (P : Shared → Prop)
    (hx : ∀ sh, P sh → ∃ sh', (eval C ctx l x).run sh = some (.f32 p, sh') ∧ P sh')
    (hy : ∀ sh, P sh → ∃ sh', (eval C ctx l y).run sh = some (.f32 q, sh') ∧ P sh') (sh : Shared) (h : P sh) :
    ∃ sh', (eval C ctx l (.bin .mul .f32 0 x y)).run sh = some (.f32 (C.fmul p q), sh') ∧ P sh' := by
  obtain ⟨sh₁, h₁, p₁⟩ := hx sh h
  obtain ⟨sh₂, h₂, p₂⟩ := hy sh₁ p₁
  exact ⟨sh₂, eval_bin_plain C (.inl ⟨by decide, by decide⟩) h₁ h₂ rfl, p₂⟩

end EvalP

/-! ## Statements and counted loops -/

section Exec
variable (C : M1Max.Contract) {ctx : Ctx}

/-- `.set` with the resulting locals named. -/
theorem Exec.set_eq {slot : Nat} {e : CExpr} {ss : List CStmt} {l : Locals} {sh : Shared} {v : Val} {sh₁ : Shared}
    {o : Outcome} {l' l₁ : Locals} {sh' : Shared} (he : (eval C ctx l e).run sh = some (v, sh₁))
    (hl : setLocal l slot v = l₁) (h : Exec C ctx ss l₁ sh₁ o l' sh') : Exec C ctx (.set slot e :: ss) l sh o l' sh' := by
  subst hl; exact .set he h

/-- A thread array's pointer, its region named. -/
theorem exec_tarray {ss : List CStmt} {l : Locals} {sh : Shared} {o : Outcome} {l' : Locals} {sh' : Shared}
    {slot index r : Nat} {elem : Ty} (hr : ctx.threadArray index = r)
    (h : Exec C ctx ss (setLocal l slot (.ptr ⟨r, 0, elem⟩)) sh o l' sh') :
    Exec C ctx (.array slot false index elem :: ss) l sh o l' sh' := by
  subst hr; exact .array h

end Exec

/-- `for (; i < bound; i += d) body`. -/
def loopOf (i : Nat) (bound : CExpr) (d : Nat) (body : List CStmt) : CStmt :=
  .loop (.bin .lt .u32 0 (.local i) bound) [.set i (.bin .add .u32 0 (.local i) (.lit (.int .u32 d)))] body

/-- Its frame while the body runs. -/
def frameOf (i : Nat) (bound : CExpr) (d : Nat) (body : List CStmt) : Frame :=
  .loop (.bin .lt .u32 0 (.local i) bound) [.set i (.bin .add .u32 0 (.local i) (.lit (.int .u32 d)))] body

section Loops
variable (C : M1Max.Contract) {ctx : Ctx}

theorem exec_step {i d x : Nat} {l : Locals} {sh : Shared} (hi : l i = some (u32 x)) (hd : d < 2 ^ 32) :
    Exec C ctx [.set i (.bin .add .u32 0 (.local i) (.lit (.int .u32 d)))] l sh .normal
      (setLocal l i (u32 (x + d))) sh :=
  .set (eval_bin_u32 C (eval_local' C hi sh) (eval_u32lit C l sh d hd) (binary_add_u32 C x d)) (.nil _ _)

theorem eval_test {i x n : Nat} {bound : CExpr} {l : Locals} {sh : Shared} (hi : l i = some (u32 x)) (hx : x < 2 ^ 32)
    (hn : n < 2 ^ 32) (hb : (eval C ctx l bound).run sh = some (u32 n, sh)) :
    (eval C ctx l (.bin .lt .u32 0 (.local i) bound)).run sh = some (.bool (decide (x < n)), sh) :=
  eval_bin_u32 C (eval_local' C hi sh) hb (binary_lt_u32 C x n hx hn)

/-- A counted loop `for (; i < n; i += d)` from `i = x0`, of `N` iterations, by an invariant. -/
theorem exec_count (i d n N x0 : Nat) (bound : CExpr) (body : List CStmt) (I : Nat → Locals → Shared → Prop)
    (hn : n < 2 ^ 32) (hd : d < 2 ^ 32) (hN : ∀ k, k ≤ N → (x0 + d * k < n ↔ k < N)) (hxs : x0 + d * N < 2 ^ 32)
    (hctr : ∀ k ≤ N, ∀ l sh, I k l sh → l i = some (u32 (x0 + d * k)) ∧ (eval C ctx l bound).run sh = some (u32 n, sh))
    (hbody : ∀ k < N, ∀ l sh, I k l sh → ∃ o l₁ sh₁, (o = .normal ∨ o = .continue_) ∧ Exec C ctx body l sh o l₁ sh₁ ∧
       l₁ i = some (u32 (x0 + d * k)) ∧ I (k + 1) (setLocal l₁ i (u32 (x0 + d * (k + 1)))) sh₁)
    {l : Locals} {sh : Shared} (h0 : I 0 l sh) :
    ∃ l' sh', Exec C ctx [loopOf i bound d body] l sh .normal l' sh' ∧ I N l' sh' := by
  refine Exec.loop_count N I I (fun k hk l sh hI => ⟨sh, ?_, hI⟩) (fun k hk l sh hI => ?_) h0
  · obtain ⟨h1, h2⟩ := hctr k hk l sh hI
    have hk' : x0 + d * k < 2 ^ 32 := lt_of_le_of_lt (by have := Nat.mul_le_mul_left d hk; omega) hxs
    rw [eval_test C h1 hk' hn h2, decide_eq_decide.mpr (hN k hk)]
  · obtain ⟨o, l₁, sh₁, ho, hb, h1, hI'⟩ := hbody k hk l sh hI
    refine ⟨o, l₁, sh₁, _, sh₁, ho, hb, ?_, hI'⟩
    have := exec_step C (ctx := ctx) (sh := sh₁) h1 hd
    rwa [show x0 + d * k + d = x0 + d * (k + 1) by ring] at this

/-- Entering a loop whose first iteration stops. -/
theorem exec_loop_stop {i x n d : Nat} {bound : CExpr} {body ss : List CStmt} {l l' : Locals} {sh sh' : Shared}
    {s : Status} {inner : List Frame} (hi : l i = some (u32 x)) (hx : x < 2 ^ 32) (hn : n < 2 ^ 32)
    (hb : (eval C ctx l bound).run sh = some (u32 n, sh)) (hlt : x < n)
    (hbody : Exec C ctx body l sh (.stop s inner) l' sh') :
    Exec C ctx (loopOf i bound d body :: ss) l sh (.stop s (inner ++ [frameOf i bound d body, .block ss])) l' sh' :=
  .loop_stop (by rw [eval_test C hi hx hn hb, decide_eq_true hlt]) hbody

/-- Resumed in a loop's body: the rest of it, the step, and the next iteration up to its stop. -/
theorem resume_loop_stop {i x n d : Nat} {bound : CExpr} {body rest ss : List CStmt} {K inner : List Frame}
    {l l₁ l' : Locals} {sh sh₁ sh' : Shared} {o₁ : Outcome} {s : Status}
    (hrest : Exec C ctx rest l sh o₁ l₁ sh₁) (ho : o₁ = .normal ∨ o₁ = .continue_) (hi : l₁ i = some (u32 x))
    (hd : d < 2 ^ 32) (hxd : x + d < 2 ^ 32) (hn : n < 2 ^ 32)
    (hb : (eval C ctx (setLocal l₁ i (u32 (x + d))) bound).run sh₁ = some (u32 n, sh₁)) (hlt : x + d < n)
    (hbody : Exec C ctx body (setLocal l₁ i (u32 (x + d))) sh₁ (.stop s inner) l' sh') :
    Reaches C ⟨ctx, l, .block rest :: frameOf i bound d body :: .block ss :: K, .running⟩ sh
      ⟨ctx, l', inner ++ frameOf i bound d body :: .block ss :: K, s⟩ sh' :=
  Exec.resume_stop hrest ho (exec_step C hi hd)
    (by rw [eval_test C (setLocal_same _ _ _) hxd hn hb, decide_eq_true hlt]) hbody

/-- Resumed in a loop's last iteration: the rest of it, the step, and the exit. -/
theorem resume_loop_exit {i x n d : Nat} {bound : CExpr} {body rest ss : List CStmt} {K : List Frame}
    {l l₁ : Locals} {sh sh₁ : Shared} {o₁ : Outcome}
    (hrest : Exec C ctx rest l sh o₁ l₁ sh₁) (ho : o₁ = .normal ∨ o₁ = .continue_) (hi : l₁ i = some (u32 x))
    (hd : d < 2 ^ 32) (hxd : x + d < 2 ^ 32) (hn : n < 2 ^ 32)
    (hb : (eval C ctx (setLocal l₁ i (u32 (x + d))) bound).run sh₁ = some (u32 n, sh₁)) (hge : n ≤ x + d) :
    Reaches C ⟨ctx, l, .block rest :: frameOf i bound d body :: .block ss :: K, .running⟩ sh
      ⟨ctx, setLocal l₁ i (u32 (x + d)), .block ss :: K, .running⟩ sh₁ :=
  Exec.resume_exit hrest ho (exec_step C hi hd)
    (by rw [eval_test C (setLocal_same _ _ _) hxd hn hb, decide_eq_false (by omega)])

end Loops

end Metal
