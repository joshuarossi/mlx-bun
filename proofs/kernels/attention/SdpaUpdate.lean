import kernels.attention.OnlineSoftmax
import kernels.delta.Gates
import contracts.mlx.ArithmeticFold

namespace Inference.Kernels.Attention.SdpaUpdate
open Contracts.Mlx Contracts.Mlx.Numerics

-- fast::exp is a primitive contract. Everything around it, including the
-- rounded score differences and accumulator updates, is proved below.
structure ExpContract (exp : Float32 → Float32) (error : Float32 → ℝ) : Prop where
  accuracy : ∀ x, x.isFinite = true → (exp x).isFinite = true →
    |real (exp x) - Real.exp (real x)| ≤ error x
inductive Contraction where
  | separate | first | second
structure Platform where
  exp : Float32 → Float32
  expError : Float32 → ℝ
  exponential : ExpContract exp expError
  sumContracted : Bool
  numeratorContracted : Contraction
structure State where
  shift : Float32
  denominator : Float32
  numerator : Float32
structure Error where
  denominator : ℝ
  numerator : ℝ
structure StateError (actual : State) (target : OnlineSoftmax.Summary) (error : Error) : Prop where
  shift : real actual.shift = target.shift
  denominator : |real actual.denominator - target.denominator| ≤ error.denominator
  numerator : |real actual.numerator - target.numerator| ≤ error.numerator

def difference (x shift : Float32) : Float32 := Arithmetic.sub x shift
def exponential (p : Platform) (x shift : Float32) : Float32 := p.exp (difference x shift)
structure ExponentFinite (p : Platform) (x shift : Float32) : Prop where
  input : x.isFinite = true
  shiftFinite : shift.isFinite = true
  difference : (FlushToZero.flush x - FlushToZero.flush shift).isFinite = true
  exponential : (exponential p x shift).isFinite = true

noncomputable def exponentialBudget (p : Platform) (x shift : Float32) (target error : ℝ) : ℝ :=
  p.expError (difference x shift) + Real.exp (max (target - real shift) (real (difference x shift))) *
    (Arithmetic.subBudget x shift + error)

theorem exponential_error (p : Platform) (x shift : Float32) (target error : ℝ)
    (hf : ExponentFinite p x shift) (he : |real x - target| ≤ error) :
    |real (exponential p x shift) - Real.exp (target - real shift)| ≤ exponentialBudget p x shift target error := by
  have hd := Arithmetic.sub_error x shift hf.input hf.shiftFinite hf.difference
  have hd' : |real (difference x shift) - (target - real shift)| ≤ Arithmetic.subBudget x shift + error := by
    calc
      _ = |(real (difference x shift) - (real x - real shift)) + (real x - target)| := by congr 1; ring
      _ ≤ _ := (abs_add_le _ _).trans (add_le_add hd he)
  have hl := p.exponential.accuracy (difference x shift) (FlushToZero.finite_flush _ hf.difference) hf.exponential
  have hp := (Delta.Gates.exp_lipschitz (target - real shift) (real (difference x shift))).trans
    (mul_le_mul_of_nonneg_left hd' (Real.exp_pos _).le)
  calc
    _ = |(real (exponential p x shift) - Real.exp (real (difference x shift))) +
      (Real.exp (real (difference x shift)) - Real.exp (target - real shift))| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add hl hp)

def bind (p : Platform) (s : State) (score value shift : Float32) (i : Nat) : Float32 :=
  if i = 0 then s.denominator else if i = 1 then s.numerator
  else if i = 2 then exponential p s.shift shift else if i = 3 then exponential p score shift else value
noncomputable def targetBind (s : OnlineSoftmax.Summary) (score value shift : ℝ) (i : Nat) : ℝ :=
  if i = 0 then s.denominator else if i = 1 then s.numerator
  else if i = 2 then Real.exp (s.shift - shift) else if i = 3 then Real.exp (score - shift) else value
noncomputable def inputBudget (p : Platform) (s : State) (score shift : Float32) (target : OnlineSoftmax.Summary)
    (error : Error) (targetScore scoreError valueError : ℝ) (i : Nat) : ℝ :=
  if i = 0 then error.denominator else if i = 1 then error.numerator
  else if i = 2 then exponentialBudget p s.shift shift target.shift 0
  else if i = 3 then exponentialBudget p score shift targetScore scoreError else valueError

def denominatorExpr (p : Platform) : Arithmetic.Expr :=
  if p.sumContracted then .fma (.input 0) (.input 2) (.input 3)
  else .add (.mul (.input 0) (.input 2)) (.input 3)
def numeratorExpr (p : Platform) : Arithmetic.Expr :=
  match p.numeratorContracted with
  | .separate => .add (.mul (.input 1) (.input 2)) (.mul (.input 3) (.input 4))
  | .first => .fma (.input 1) (.input 2) (.mul (.input 3) (.input 4))
  | .second => .fma (.input 3) (.input 4) (.mul (.input 1) (.input 2))

def step (p : Platform) (s : State) (score value shift : Float32) : State where
  shift := shift
  denominator := if p.sumContracted then FlushToZero.fma s.denominator (exponential p s.shift shift) (exponential p score shift)
    else FlushToZero.add (FlushToZero.mul s.denominator (exponential p s.shift shift)) (exponential p score shift)
  numerator := match p.numeratorContracted with
    | .separate => FlushToZero.add (FlushToZero.mul s.numerator (exponential p s.shift shift)) (FlushToZero.mul (exponential p score shift) value)
    | .first => FlushToZero.fma s.numerator (exponential p s.shift shift) (FlushToZero.mul (exponential p score shift) value)
    | .second => FlushToZero.fma (exponential p score shift) value (FlushToZero.mul s.numerator (exponential p s.shift shift))

structure Finite (p : Platform) (s : State) (score value shift : Float32) : Prop where
  factor : ExponentFinite p s.shift shift
  scoreExponent : ExponentFinite p score shift
  denominator : Arithmetic.Finite (bind p s score value shift) (denominatorExpr p)
  numerator : Arithmetic.Finite (bind p s score value shift) (numeratorExpr p)

noncomputable def budget (p : Platform) (s : State) (score value shift : Float32) (target : OnlineSoftmax.Summary)
    (error : Error) (targetScore targetValue scoreError valueError : ℝ) : Error where
  denominator := Arithmetic.budget (bind p s score value shift) (targetBind target targetScore targetValue (real shift))
    (inputBudget p s score shift target error targetScore scoreError valueError) (denominatorExpr p)
  numerator := Arithmetic.budget (bind p s score value shift) (targetBind target targetScore targetValue (real shift))
    (inputBudget p s score shift target error targetScore scoreError valueError) (numeratorExpr p)

theorem bind_error (p : Platform) (s : State) (score value shift : Float32) (target : OnlineSoftmax.Summary)
    (error : Error) (targetScore targetValue scoreError valueError : ℝ)
    (hf : Finite p s score value shift) (hs : StateError s target error)
    (hscore : |real score - targetScore| ≤ scoreError) (hvalue : |real value - targetValue| ≤ valueError) (i : Nat) :
    |real (bind p s score value shift i) - targetBind target targetScore targetValue (real shift) i| ≤
      inputBudget p s score shift target error targetScore scoreError valueError i := by
  unfold bind targetBind inputBudget
  split
  · exact hs.denominator
  · split
    · exact hs.numerator
    · split
      · exact exponential_error p s.shift shift target.shift 0 hf.factor (by rw [hs.shift]; simp)
      · split
        · exact exponential_error p score shift targetScore scoreError hf.scoreExponent hscore
        · exact hvalue

theorem denominator_execution (p : Platform) (s : State) (score value shift : Float32) :
    Arithmetic.evaluate (bind p s score value shift) (denominatorExpr p) = (step p s score value shift).denominator := by
  unfold denominatorExpr step
  cases p.sumContracted <;> rfl

theorem numerator_execution (p : Platform) (s : State) (score value shift : Float32) :
    Arithmetic.evaluate (bind p s score value shift) (numeratorExpr p) = (step p s score value shift).numerator := by
  unfold numeratorExpr step
  cases p.numeratorContracted <;> rfl

theorem denominator_ideal (p : Platform) (s : OnlineSoftmax.Summary) (score value shift : ℝ) :
    Arithmetic.ideal (targetBind s score value shift) (denominatorExpr p) = (OnlineSoftmax.append s score value shift).denominator := by
  unfold denominatorExpr
  cases p.sumContracted <;> simp [Arithmetic.ideal, targetBind, OnlineSoftmax.append]

theorem numerator_ideal (p : Platform) (s : OnlineSoftmax.Summary) (score value shift : ℝ) :
    Arithmetic.ideal (targetBind s score value shift) (numeratorExpr p) = (OnlineSoftmax.append s score value shift).numerator := by
  unfold numeratorExpr
  cases p.numeratorContracted <;> simp [Arithmetic.ideal, targetBind, OnlineSoftmax.append, add_comm]

theorem step_error (p : Platform) (s : State) (score value shift : Float32) (target : OnlineSoftmax.Summary)
    (error : Error) (targetScore targetValue scoreError valueError : ℝ)
    (hf : Finite p s score value shift) (hs : StateError s target error)
    (hscore : |real score - targetScore| ≤ scoreError) (hvalue : |real value - targetValue| ≤ valueError) :
    StateError (step p s score value shift) (OnlineSoftmax.append target targetScore targetValue (real shift))
      (budget p s score value shift target error targetScore targetValue scoreError valueError) where
  shift := rfl
  denominator := by
    have h := Arithmetic.error (bind p s score value shift) (targetBind target targetScore targetValue (real shift))
      (inputBudget p s score shift target error targetScore scoreError valueError)
      (bind_error p s score value shift target error targetScore targetValue scoreError valueError hf hs hscore hvalue)
      (denominatorExpr p) hf.denominator
    rwa [denominator_execution, denominator_ideal] at h
  numerator := by
    have h := Arithmetic.error (bind p s score value shift) (targetBind target targetScore targetValue (real shift))
      (inputBudget p s score shift target error targetScore scoreError valueError)
      (bind_error p s score value shift target error targetScore targetValue scoreError valueError hf hs hscore hvalue)
      (numeratorExpr p) hf.numerator
    rwa [numerator_execution, numerator_ideal] at h

theorem step_finite (p : Platform) (s : State) (score value shift : Float32) (hf : Finite p s score value shift) :
    (step p s score value shift).shift.isFinite = true ∧ (step p s score value shift).denominator.isFinite = true ∧
      (step p s score value shift).numerator.isFinite = true := by
  have hd := Arithmetic.finite_evaluate (bind p s score value shift) (denominatorExpr p) hf.denominator
  have hn := Arithmetic.finite_evaluate (bind p s score value shift) (numeratorExpr p) hf.numerator
  rw [denominator_execution] at hd
  rw [numerator_execution] at hn
  exact ⟨hf.factor.shiftFinite, hd, hn⟩

end Inference.Kernels.Attention.SdpaUpdate
