import contracts.mlx.Arithmetic
import contracts.mlx.BFloat16Arithmetic
import contracts.mlx.Negation
import contracts.mlx.Memory
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Bounds

namespace Inference.Kernels.Attention.Rope
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

-- Primitive fast trigonometry is distinct from the software calculation of
-- theta. In particular, the MSL small-error guarantee near ±pi must not be
-- silently extended to all supported token positions.
structure TrigContract (fn : Float32 → Float32) (ideal : ℝ → ℝ)
    (error : Float32 → ℝ) (domain : Float32 → Prop) : Prop where
  accuracy : ∀ theta, theta.isFinite = true → domain theta → (fn theta).isFinite = true →
    |real (fn theta) - ideal (real theta)| ≤ error theta

inductive Contraction where
  | separate | first | second

structure Platform where
  sin : Float32 → Float32
  cos : Float32 → Float32
  sinError : Float32 → ℝ
  cosError : Float32 → ℝ
  domain : Float32 → Prop
  sine : TrigContract sin Real.sin sinError domain
  cosine : TrigContract cos Real.cos cosError domain
  first : Contraction
  second : Contraction

structure Inputs where
  first : BF
  second : BF
  theta : Float32

structure Target where
  first : ℝ
  second : ℝ
  theta : ℝ

structure InputError (x : Inputs) (target error : Target) : Prop where
  first : |Model.toReal x.first - target.first| ≤ error.first
  second : |Model.toReal x.second - target.second| ≤ error.second
  theta : |real x.theta - target.theta| ≤ error.theta

structure InputsFinite (p : Platform) (x : Inputs) : Prop where
  first : Model.isFinite x.first = true
  second : Model.isFinite x.second = true
  theta : x.theta.isFinite = true
  domain : p.domain x.theta
  sine : (p.sin x.theta).isFinite = true
  cosine : (p.cos x.theta).isFinite = true
  product : (FlushToZero.flush (BFloat16.widen x.second) * FlushToZero.flush (p.sin x.theta)).isFinite = true

def baseBind (p : Platform) (x : Inputs) (i : Nat) : Float32 :=
  if i = 0 then BFloat16.widen x.first else if i = 1 then BFloat16.widen x.second
  else if i = 2 then p.cos x.theta else p.sin x.theta

noncomputable def baseTarget (x : Target) (i : Nat) : ℝ :=
  if i = 0 then x.first else if i = 1 then x.second else if i = 2 then Real.cos x.theta else Real.sin x.theta

noncomputable def baseBudget (p : Platform) (x : Inputs) (error : Target) (i : Nat) : ℝ :=
  if i = 0 then error.first else if i = 1 then error.second
  else if i = 2 then p.cosError x.theta + error.theta else p.sinError x.theta + error.theta

theorem base_error (p : Platform) (x : Inputs) (target error : Target)
    (hf : InputsFinite p x) (he : InputError x target error) (i : Nat) :
    |real (baseBind p x i) - baseTarget target i| ≤ baseBudget p x error i := by
  by_cases h0 : i = 0
  · subst i
    simpa [baseBind, baseTarget, baseBudget, BFloat16.widen_real _ hf.first] using he.first
  by_cases h1 : i = 1
  · subst i
    simpa [baseBind, baseTarget, baseBudget, BFloat16.widen_real _ hf.second] using he.second
  by_cases h2 : i = 2
  · simp only [baseBind, baseTarget, baseBudget, ite_eq_right h0, ite_eq_right h1, ite_eq_left h2]
    have hl := p.cosine.accuracy x.theta hf.theta hf.domain hf.cosine
    have ha := (Real.abs_cos_sub_cos_le (real x.theta) target.theta).trans he.theta
    calc
      _ = |(real (p.cos x.theta) - Real.cos (real x.theta)) + (Real.cos (real x.theta) - Real.cos target.theta)| := by congr 1; ring
      _ ≤ _ := (abs_add_le _ _).trans (add_le_add hl ha)
  · simp only [baseBind, baseTarget, baseBudget, ite_eq_right h0, ite_eq_right h1, ite_eq_right h2]
    have hl := p.sine.accuracy x.theta hf.theta hf.domain hf.sine
    have ha := (Real.abs_sin_sub_sin_le (real x.theta) target.theta).trans he.theta
    calc
      _ = |(real (p.sin x.theta) - Real.sin (real x.theta)) + (Real.sin (real x.theta) - Real.sin target.theta)| := by congr 1; ring
      _ ≤ _ := (abs_add_le _ _).trans (add_le_add hl ha)

def product (p : Platform) (x : Inputs) : Float32 := FlushToZero.mul (BFloat16.widen x.second) (p.sin x.theta)
def productExpr : Arithmetic.Expr := .mul (.input 1) (.input 3)

noncomputable def productBudget (p : Platform) (x : Inputs) (target error : Target) : ℝ :=
  Arithmetic.budget (baseBind p x) (baseTarget target) (baseBudget p x error) productExpr

theorem product_error (p : Platform) (x : Inputs) (target error : Target)
    (hf : InputsFinite p x) (he : InputError x target error) :
    |real (product p x) - target.second * Real.sin target.theta| ≤ productBudget p x target error := by
  have hr : Arithmetic.Finite (baseBind p x) productExpr :=
    ⟨BFloat16.widen_finite x.second hf.second, hf.sine, hf.product⟩
  exact Arithmetic.error (baseBind p x) (baseTarget target) (baseBudget p x error) (base_error p x target error hf he) productExpr hr

def bind (p : Platform) (x : Inputs) (i : Nat) : Float32 :=
  if i = 4 then -BFloat16.widen x.second else if i = 5 then -product p x else baseBind p x i
noncomputable def targetBind (x : Target) (i : Nat) : ℝ :=
  if i = 4 then -x.second else if i = 5 then -(x.second * Real.sin x.theta) else baseTarget x i
noncomputable def inputBudget (p : Platform) (x : Inputs) (target error : Target) (i : Nat) : ℝ :=
  if i = 4 then error.second else if i = 5 then productBudget p x target error else baseBudget p x error i

theorem bind_error (p : Platform) (x : Inputs) (target error : Target)
    (hf : InputsFinite p x) (he : InputError x target error) (i : Nat) :
    |real (bind p x i) - targetBind target i| ≤ inputBudget p x target error i := by
  by_cases h4 : i = 4
  · simp only [bind, targetBind, inputBudget, ite_eq_left h4]
    rw [Negation.real_neg _ (BFloat16.widen_finite _ hf.second), BFloat16.widen_real _ hf.second,
      neg_sub_neg, abs_sub_comm]
    exact he.second
  by_cases h5 : i = 5
  · simp only [bind, targetBind, inputBudget, ite_eq_right h4, ite_eq_left h5]
    have hp : (product p x).isFinite = true := FlushToZero.finite_flushExact _ _ hf.product
    rw [Negation.real_neg (product p x) hp, neg_sub_neg, abs_sub_comm]
    exact product_error p x target error hf he
  · simpa only [bind, targetBind, inputBudget, ite_eq_right h4, ite_eq_right h5] using base_error p x target error hf he i

-- The compiler profile chooses among the two legal single-FMA contractions
-- or two separately rounded products. No reassociation across a pair occurs.
def firstExpr : Contraction → Arithmetic.Expr
  | .separate => .sub (.mul (.input 0) (.input 2)) (.mul (.input 1) (.input 3))
  | .first => .fma (.input 0) (.input 2) (.input 5)
  | .second => .fma (.input 4) (.input 3) (.mul (.input 0) (.input 2))
def secondExpr : Contraction → Arithmetic.Expr
  | .separate => .add (.mul (.input 0) (.input 3)) (.mul (.input 1) (.input 2))
  | .first => .fma (.input 0) (.input 3) (.mul (.input 1) (.input 2))
  | .second => .fma (.input 1) (.input 2) (.mul (.input 0) (.input 3))

def expression (p : Platform) (second : Bool) : Arithmetic.Expr := if second then secondExpr p.second else firstExpr p.first

def sourceFirst (flag : Contraction) (x1 x2 c s : Float32) : Float32 :=
  match flag with
  | .separate => Arithmetic.sub (FlushToZero.mul x1 c) (FlushToZero.mul x2 s)
  | .first => FlushToZero.fma x1 c (-FlushToZero.mul x2 s)
  | .second => FlushToZero.fma (-x2) s (FlushToZero.mul x1 c)
def sourceSecond (flag : Contraction) (x1 x2 c s : Float32) : Float32 :=
  match flag with
  | .separate => FlushToZero.add (FlushToZero.mul x1 s) (FlushToZero.mul x2 c)
  | .first => FlushToZero.fma x1 s (FlushToZero.mul x2 c)
  | .second => FlushToZero.fma x2 c (FlushToZero.mul x1 s)
def source (p : Platform) (x : Inputs) (second : Bool) : Float32 :=
  if second then sourceSecond p.second (BFloat16.widen x.first) (BFloat16.widen x.second) (p.cos x.theta) (p.sin x.theta)
  else sourceFirst p.first (BFloat16.widen x.first) (BFloat16.widen x.second) (p.cos x.theta) (p.sin x.theta)

theorem execution (p : Platform) (x : Inputs) (second : Bool) :
    Arithmetic.evaluate (bind p x) (expression p second) = source p x second := by
  cases second <;> simp only [expression, source, Bool.false_eq_true, ite_false, ite_true]
  · cases p.first <;> rfl
  · cases p.second <;> rfl

noncomputable def targetValue (x : Target) (second : Bool) : ℝ :=
  if second then x.first * Real.sin x.theta + x.second * Real.cos x.theta
  else x.first * Real.cos x.theta - x.second * Real.sin x.theta

theorem ideal (p : Platform) (x : Target) (second : Bool) :
    Arithmetic.ideal (targetBind x) (expression p second) = targetValue x second := by
  cases second <;> simp only [expression, targetValue, Bool.false_eq_true, ite_false, ite_true]
  · cases p.first <;> simp [firstExpr, Arithmetic.ideal, targetBind, baseTarget] <;> ring
  · cases p.second <;> simp [secondExpr, Arithmetic.ideal, targetBind, baseTarget, add_comm]

theorem target_norm (x : Target) :
    targetValue x false ^ 2 + targetValue x true ^ 2 = x.first ^ 2 + x.second ^ 2 := by
  unfold targetValue
  simp only [Bool.false_eq_true, ite_false, ite_true]
  calc
    _ = (x.first ^ 2 + x.second ^ 2) * (Real.sin x.theta ^ 2 + Real.cos x.theta ^ 2) := by ring
    _ = _ := by rw [Real.sin_sq_add_cos_sq]; ring

def value (p : Platform) (x : Inputs) (second : Bool) : BF := BFloat16.narrow (source p x second)
structure Finite (p : Platform) (x : Inputs) : Prop where
  inputs : InputsFinite p x
  arithmetic : ∀ second, Arithmetic.Finite (bind p x) (expression p second)
  cast : ∀ second, Model.isFinite (value p x second) = true

noncomputable def budget (p : Platform) (x : Inputs) (target error : Target) (second : Bool) : ℝ :=
  Arithmetic.budget (bind p x) (targetBind target) (inputBudget p x target error) (expression p second) +
    BFloat16.epsilon (real (source p x second))

theorem value_error (p : Platform) (x : Inputs) (target error : Target) (hf : Finite p x)
    (he : InputError x target error) (second : Bool) :
    |Model.toReal (value p x second) - targetValue target second| ≤ budget p x target error second := by
  have ha := Arithmetic.error (bind p x) (targetBind target) (inputBudget p x target error)
    (bind_error p x target error hf.inputs he) (expression p second) (hf.arithmetic second)
  rw [execution, ideal] at ha
  have hfinite := Arithmetic.finite_evaluate _ _ (hf.arithmetic second)
  rw [execution] at hfinite
  have hc := BFloat16.narrow_error (source p x second) hfinite (hf.cast second)
  change |Model.toReal (value p x second) - real (source p x second)| ≤ _ at hc
  unfold budget
  calc
    _ = |(Model.toReal (value p x second) - real (source p x second)) + (real (source p x second) - targetValue target second)| := by congr 1; ring
    _ ≤ _ := by linarith [(abs_add_le _ _).trans (add_le_add hc ha)]

-- The selected Qwen head has 256 coordinates; nontraditional partial RoPE
-- rotates 32 disjoint pairs at offsets i and i+32 and leaves [64,256) intact.
def pairFirst (i : Fin 32) : Fin 256 := ⟨i.val, by have := i.isLt; omega⟩
def pairSecond (i : Fin 32) : Fin 256 := ⟨i.val+32, by have := i.isLt; omega⟩
def headInputs (x : Fin 256 → BF) (theta : Fin 32 → Float32) (i : Fin 32) : Inputs :=
  ⟨x (pairFirst i), x (pairSecond i), theta i⟩
noncomputable def headTargets (x : Fin 256 → ℝ) (theta : Fin 32 → ℝ) (i : Fin 32) : Target :=
  ⟨x (pairFirst i), x (pairSecond i), theta i⟩

def head (p : Platform) (x : Fin 256 → BF) (theta : Fin 32 → Float32) (j : Fin 256) : BF :=
  if h : j.val < 64 then value p (headInputs x theta ⟨j.val % 32, by omega⟩) (decide (32 ≤ j.val)) else x j
noncomputable def headTarget (x : Fin 256 → ℝ) (theta : Fin 32 → ℝ) (j : Fin 256) : ℝ :=
  if h : j.val < 64 then targetValue (headTargets x theta ⟨j.val % 32, by omega⟩) (decide (32 ≤ j.val)) else x j
noncomputable def headBudget (p : Platform) (x : Fin 256 → BF) (theta : Fin 32 → Float32)
    (target error : Fin 256 → ℝ) (targetTheta errorTheta : Fin 32 → ℝ) (j : Fin 256) : ℝ :=
  if h : j.val < 64 then budget p (headInputs x theta ⟨j.val % 32, by omega⟩)
    (headTargets target targetTheta ⟨j.val % 32, by omega⟩) (headTargets error errorTheta ⟨j.val % 32, by omega⟩) (decide (32 ≤ j.val)) else error j

theorem head_error (p : Platform) (x : Fin 256 → BF) (theta : Fin 32 → Float32)
    (target error : Fin 256 → ℝ) (targetTheta errorTheta : Fin 32 → ℝ)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i)
    (ht : ∀ i, |real (theta i) - targetTheta i| ≤ errorTheta i)
    (hf : ∀ i, Finite p (headInputs x theta i)) (j : Fin 256) :
    |Model.toReal (head p x theta j) - headTarget target targetTheta j| ≤ headBudget p x theta target error targetTheta errorTheta j := by
  unfold head headTarget headBudget
  split
  · let i : Fin 32 := ⟨j.val % 32, by omega⟩
    exact value_error p (headInputs x theta i) (headTargets target targetTheta i)
      (headTargets error errorTheta i) (hf i) ⟨hi (pairFirst i), hi (pairSecond i), ht i⟩ _
  · exact hi j

theorem head_finite (p : Platform) (x : Fin 256 → BF) (theta : Fin 32 → Float32)
    (hx : ∀ j, Model.isFinite (x j) = true) (hf : ∀ i, Finite p (headInputs x theta i)) (j : Fin 256) :
    Model.isFinite (head p x theta j) = true := by
  unfold head
  split
  · exact (hf _).cast _
  · exact hx j

theorem unchanged (p : Platform) (x : Fin 256 → BF) (theta : Fin 32 → Float32) (j : Fin 256) (hj : 64 ≤ j.val) :
    head p x theta j = x j := by simp [head, show ¬j.val < 64 by omega]

theorem pair_disjoint (i j : Fin 32) : pairFirst i ≠ pairSecond j := by
  intro h
  have h := congrArg Fin.val h
  dsimp [pairFirst, pairSecond] at h
  have := i.isLt
  omega

theorem head_first (p : Platform) (x : Fin 256 → BF) (theta : Fin 32 → Float32) (i : Fin 32) :
    head p x theta (pairFirst i) = value p (headInputs x theta i) false := by
  have hi := i.isLt
  simp [head, pairFirst, show i.val < 64 by omega, Nat.mod_eq_of_lt hi, Nat.not_le.mpr hi]

theorem head_second (p : Platform) (x : Fin 256 → BF) (theta : Fin 32 → Float32) (i : Fin 32) :
    head p x theta (pairSecond i) = value p (headInputs x theta i) true := by
  have hi := i.isLt
  simp [head, pairSecond, show i.val + 32 < 64 by omega, Nat.mod_eq_of_lt hi]

-- The host first copies the partial-RoPE input. Every pair then owns two
-- distinct cells. Any permutation of those 64 stores preserves the rest.
def stored (p : Platform) (x : Nat → BF) (theta : Fin 32 → Float32) (schedule : List Nat) : Nat → BF :=
  Memory.writeCells (fun i => if h : i < 256 then head p (fun j => x j.val) theta ⟨i, h⟩ else x i) schedule x

theorem stored_read (p : Platform) (x : Nat → BF) (theta : Fin 32 → Float32)
    (schedule : List Nat) (hs : schedule.Perm (List.range 64)) (i : Fin 256) :
    stored p x theta schedule i.val = head p (fun j => x j.val) theta i := by
  unfold stored
  rw [Memory.writeCells_read]
  by_cases hi : i.val < 64
  · rw [ite_eq_left (hs.mem_iff.mpr (List.mem_range.mpr hi)), dite_eq_left i.isLt]
  · rw [ite_eq_right (fun h => hi (List.mem_range.mp (hs.mem_iff.mp h)))]
    exact (unchanged p (fun j => x j.val) theta i (by omega)).symm

theorem stored_frame (p : Platform) (x : Nat → BF) (theta : Fin 32 → Float32)
    (schedule : List Nat) (hs : schedule.Perm (List.range 64)) (i : Nat) (hi : 64 ≤ i) :
    stored p x theta schedule i = x i := by
  unfold stored
  rw [Memory.writeCells_read, ite_eq_right (fun h => by have := List.mem_range.mp (hs.mem_iff.mp h); omega)]

end Inference.Kernels.Attention.Rope
