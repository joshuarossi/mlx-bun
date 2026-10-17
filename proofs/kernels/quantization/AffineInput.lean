import contracts.mlx.BFloat16Arithmetic
import contracts.mlx.BFloat16
import contracts.mlx.Arithmetic
import contracts.mlx.Division
import kernels.quantization.AffineLift

namespace Inference.Kernels.Quantization.AffineInput
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators
abbrev BF := BFloat16Arithmetic.Value

-- load_vector adds groups of four/eight bf16 operands before promoting the
-- group result into its float accumulator. Preserve those inner roundings.
inductive SumExpr (n : Nat) where
  | input : Fin n → SumExpr n
  | add : SumExpr n → SumExpr n → SumExpr n

def evaluate (x : Fin n → BF) : SumExpr n → BF
  | .input i => x i
  | .add a b => BFloat16Arithmetic.add (evaluate x a) (evaluate x b)

noncomputable def ideal (x : Fin n → ℝ) : SumExpr n → ℝ
  | .input i => x i
  | .add a b => ideal x a + ideal x b

def Finite (x : Fin n → BF) : SumExpr n → Prop
  | .input i => Model.isFinite (x i) = true
  | .add a b => Finite x a ∧ Finite x b ∧
    Model.isFinite (Model.add (BFloat16Arithmetic.flush (evaluate x a)) (BFloat16Arithmetic.flush (evaluate x b))) = true

noncomputable def budget (x : Fin n → BF) (error : Fin n → ℝ) : SumExpr n → ℝ
  | .input i => error i
  | .add a b => BFloat16Arithmetic.addBudget (evaluate x a) (evaluate x b) + budget x error a + budget x error b

theorem evaluate_finite (x : Fin n → BF) (expr : SumExpr n) (hf : Finite x expr) : Model.isFinite (evaluate x expr) = true := by
  cases expr with
  | input i => exact hf
  | add a b => exact BFloat16Arithmetic.finite_flush _ hf.2.2

theorem evaluate_error (x : Fin n → BF) (target error : Fin n → ℝ)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (expr : SumExpr n) (hf : Finite x expr) :
    |Model.toReal (evaluate x expr) - ideal target expr| ≤ budget x error expr := by
  induction expr with
  | input i => exact hi i
  | add a b ia ib =>
    have ha := ia hf.1
    have hb := ib hf.2.1
    have hl := BFloat16Arithmetic.add_error (evaluate x a) (evaluate x b)
      (evaluate_finite x a hf.1) (evaluate_finite x b hf.2.1) hf.2.2
    change |Model.toReal (BFloat16Arithmetic.add (evaluate x a) (evaluate x b)) - (ideal target a + ideal target b)| ≤ _
    calc
      _ = |(Model.toReal (BFloat16Arithmetic.add (evaluate x a) (evaluate x b)) -
        (Model.toReal (evaluate x a) + Model.toReal (evaluate x b))) +
        ((Model.toReal (evaluate x a) - ideal target a) + (Model.toReal (evaluate x b) - ideal target b))| := by congr 1; ring
      _ ≤ _ := by
        have h := (abs_add_le _ _).trans (add_le_add hl ((abs_add_le _ _).trans (add_le_add ha hb)))
        simpa only [budget, add_assoc] using h

def group4 (x : Fin 4 → SumExpr n) : SumExpr n := .add (.add (.add (x 0) (x 1)) (x 2)) (x 3)
def group8 (x : Fin 8 → SumExpr n) : SumExpr n :=
  .add (.add (.add (.add (.add (.add (.add (x 0) (x 1)) (x 2)) (x 3)) (x 4)) (x 5)) (x 6)) (x 7)

theorem ideal_group4 (x : Fin n → ℝ) (expr : Fin 4 → SumExpr n) : ideal x (group4 expr) = ∑ i, ideal x (expr i) := by
  simp [group4, ideal, Fin.sum_univ_succ]
  ring

theorem ideal_group8 (x : Fin n → ℝ) (expr : Fin 8 → SumExpr n) : ideal x (group8 expr) = ∑ i, ideal x (expr i) := by
  simp [group8, ideal, Fin.sum_univ_succ]
  ring

def sumExpression (groups : Nat) : Arithmetic.Expr :=
  (List.finRange groups).foldl (fun acc i => .add acc (.input i.val)) .zero

def sumGroups (values : Fin groups → Float32) : Float32 :=
  (List.finRange groups).foldl (fun acc i => FlushToZero.add acc (values i)) 0

def bind (values : Fin groups → Float32) (i : Nat) : Float32 := if h : i < groups then values ⟨i, h⟩ else 0
noncomputable def bindReal (values : Fin groups → ℝ) (i : Nat) : ℝ := if h : i < groups then values ⟨i, h⟩ else 0

theorem bind_read (values : Fin groups → Float32) (i : Fin groups) : bind values i.val = values i := by simp [bind, i.isLt]
theorem bindReal_read (values : Fin groups → ℝ) (i : Fin groups) : bindReal values i.val = values i := by simp [bindReal, i.isLt]

private theorem evaluate_fold (values : Fin groups → Float32) (indices : List (Fin groups)) (acc : Arithmetic.Expr) :
    Arithmetic.evaluate (bind values) (indices.foldl (fun acc i => .add acc (.input i.val)) acc) =
      indices.foldl (fun acc i => FlushToZero.add acc (values i)) (Arithmetic.evaluate (bind values) acc) := by
  induction indices generalizing acc with
  | nil => rfl
  | cons i rest ih => simpa only [List.foldl_cons, Arithmetic.evaluate, bind_read] using ih (.add acc (.input i.val))

theorem sum_execution (values : Fin groups → Float32) : Arithmetic.evaluate (bind values) (sumExpression groups) = sumGroups values :=
  evaluate_fold values (List.finRange groups) .zero

private theorem ideal_fold (values : Fin groups → ℝ) (indices : List (Fin groups)) (acc : Arithmetic.Expr) :
    Arithmetic.ideal (bindReal values) (indices.foldl (fun acc i => .add acc (.input i.val)) acc) =
      Arithmetic.ideal (bindReal values) acc + (indices.map values).sum := by
  induction indices generalizing acc with
  | nil => simp
  | cons i rest ih =>
    simp only [List.foldl_cons, ih, Arithmetic.ideal, bindReal_read, List.map_cons, List.sum_cons]
    ring

theorem sum_ideal (values : Fin groups → ℝ) : Arithmetic.ideal (bindReal values) (sumExpression groups) = ∑ i, values i := by
  rw [sumExpression, ideal_fold]
  simp [Arithmetic.ideal, ← Fin.sum_univ_def]

def summed (x : Fin n → BF) (group : Fin groups → SumExpr n) : Float32 :=
  sumGroups (fun i => BFloat16.widen (evaluate x (group i)))

noncomputable def summedBudget (x : Fin n → BF) (target error : Fin n → ℝ) (group : Fin groups → SumExpr n) : ℝ :=
  Arithmetic.budget (bind (fun i => BFloat16.widen (evaluate x (group i))))
    (bindReal (fun i => ideal target (group i))) (bindReal (fun i => budget x error (group i))) (sumExpression groups)

theorem summed_error (x : Fin n → BF) (target error : Fin n → ℝ)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (group : Fin groups → SumExpr n)
    (hg : ∀ i, Finite x (group i))
    (hf : Arithmetic.Finite (bind (fun i => BFloat16.widen (evaluate x (group i)))) (sumExpression groups)) :
    |real (summed x group) - ∑ i, ideal target (group i)| ≤ summedBudget x target error group := by
  have he : ∀ i, |real (bind (fun i => BFloat16.widen (evaluate x (group i))) i) -
      bindReal (fun i => ideal target (group i)) i| ≤ bindReal (fun i => budget x error (group i)) i := by
    intro i
    unfold bind bindReal
    split
    · rw [BFloat16.widen_real _ (evaluate_finite x _ (hg _))]
      exact evaluate_error x target error hi _ (hg _)
    · have hz : real (0 : Float32) = 0 := by rw [real_unpack]; exact Model.unpackedToReal_zero .positive
      simp only [hz, sub_zero, abs_zero, le_refl]
  have ha := Arithmetic.error _ _ _ he (sumExpression groups) hf
  rw [sum_execution, sum_ideal] at ha
  exact ha

def index4 (group : Fin 4) (column : Fin 4) : Fin 16 :=
  ⟨group.val * 4 + column.val, by have := group.isLt; have := column.isLt; omega⟩
def index8 (group : Fin 2) (column : Fin 8) : Fin 16 :=
  ⟨group.val * 8 + column.val, by have := group.isLt; have := column.isLt; omega⟩
def groups4 (i : Fin 4) : SumExpr 16 := group4 (fun j => .input (index4 i j))
def groups3 (i : Fin 2) : SumExpr 16 := group8 (fun j => .input (index8 i j))

theorem groups4_coverage (x : Fin 16 → ℝ) : (∑ i, ideal x (groups4 i)) = ∑ i, x i := by
  simp [groups4, ideal_group4, ideal, index4, Fin.sum_univ_succ]
  ring

theorem groups3_coverage (x : Fin 16 → ℝ) : (∑ i, ideal x (groups3 i)) = ∑ i, x i := by
  simp [groups3, ideal_group8, ideal, index8, Fin.sum_univ_succ]
  ring

theorem sum4_error (x : Fin 16 → BF) (target error : Fin 16 → ℝ)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hg : ∀ i, Finite x (groups4 i))
    (hf : Arithmetic.Finite (bind (fun i => BFloat16.widen (evaluate x (groups4 i)))) (sumExpression 4)) :
    |real (summed x groups4) - ∑ i, target i| ≤ summedBudget x target error groups4 := by
  have h := summed_error x target error hi groups4 hg hf
  rwa [groups4_coverage] at h

theorem sum3_error (x : Fin 16 → BF) (target error : Fin 16 → ℝ)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hg : ∀ i, Finite x (groups3 i))
    (hf : Arithmetic.Finite (bind (fun i => BFloat16.widen (evaluate x (groups3 i)))) (sumExpression 2)) :
    |real (summed x groups3) - ∑ i, target i| ≤ summedBudget x target error groups3 := by
  have h := summed_error x target error hi groups3 hg hf
  rwa [groups3_coverage] at h

-- The input division is a scalar primitive boundary. Its error is added to
-- upstream error scaled by the exact positive divisor; it is never assumed
-- to be an exact shift for subnormals or near the flushing boundary.
noncomputable def scaledBudget (divError : Float32 → Float32 → ℝ) (x : BF) (divisor : Float32) (error : ℝ) : ℝ :=
  divError (BFloat16.widen x) divisor + error / real divisor

theorem scaled_error (divide : Float32 → Float32 → Float32) (divError : Float32 → Float32 → ℝ)
    (platform : Division.Contract divide divError) (x : BF) (divisor : Float32)
    (hx : Model.isFinite x = true)
    (hd : divisor.isFinite = true) (hdp : 0 < real divisor) (hdom : Division.DivisorDomain divisor)
    (ho : (divide (BFloat16.widen x) divisor).isFinite = true)
    (target error : ℝ) (he : |Model.toReal x - target| ≤ error) :
    |real (divide (BFloat16.widen x) divisor) - target / real divisor| ≤ scaledBudget divError x divisor error := by
  have hp := platform.accuracy (BFloat16.widen x) divisor (BFloat16.widen_finite x hx) hd hdom ho
  rw [BFloat16.widen_real _ hx] at hp
  have ht : |Model.toReal x / real divisor - target / real divisor| ≤ error / real divisor := by
    rw [← sub_div, abs_div, abs_of_pos hdp]
    exact div_le_div_of_nonneg_right he hdp.le
  exact (abs_sub_le _ _ _).trans (add_le_add hp ht)

def divisor (shift : Fin 13) : Float32 := Float32.ofInt (2^shift.val)

set_option maxRecDepth 10000 in
theorem divisors_checked : ∀ shift : Fin 13,
    divisor shift = AffineLift.value (1 * 2^shift.val) ∧ (divisor shift).isFinite = true := by decide +kernel

theorem divisor_value (shift : Fin 13) : real (divisor shift) = (2 : ℝ)^shift.val := by
  rw [(divisors_checked shift).1]
  simpa using AffineLift.field_exact (1 : Fin 16) shift

theorem divisor_domain (shift : Fin 13) : Division.DivisorDomain (divisor shift) := by
  rw [Division.DivisorDomain, divisor_value]
  fin_cases shift <;> norm_num

def prepare (divide : Float32 → Float32 → Float32) (x : BF) (shift : Fin 13) : Float32 :=
  if shift.val = 0 then BFloat16.widen x else divide (BFloat16.widen x) (divisor shift)

noncomputable def prepareBudget (divError : Float32 → Float32 → ℝ) (x : BF) (shift : Fin 13) (error : ℝ) : ℝ :=
  if shift.val = 0 then error else scaledBudget divError x (divisor shift) error

theorem prepare_error (divide : Float32 → Float32 → Float32) (divError : Float32 → Float32 → ℝ)
    (platform : Division.Contract divide divError) (x : BF) (shift : Fin 13)
    (hx : Model.isFinite x = true) (ho : (prepare divide x shift).isFinite = true)
    (target error : ℝ) (he : |Model.toReal x - target| ≤ error) :
    |real (prepare divide x shift) - target / (2 : ℝ)^shift.val| ≤ prepareBudget divError x shift error := by
  unfold prepare prepareBudget
  split
  · rename_i hz
    simpa only [BFloat16.widen_real _ hx, hz, pow_zero, div_one] using he
  · rename_i hn
    have hf : (divide (BFloat16.widen x) (divisor shift)).isFinite = true := by simpa only [prepare, hn, ite_false] using ho
    have h := scaled_error divide divError platform x (divisor shift) hx (divisors_checked shift).2
      (by rw [divisor_value]; positivity) (divisor_domain shift) hf target error he
    rwa [divisor_value] at h

end Inference.Kernels.Quantization.AffineInput
