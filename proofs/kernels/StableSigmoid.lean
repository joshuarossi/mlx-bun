import contracts.mlx.Arithmetic
import kernels.trellis.GateUpTail
import FloatLib.Floats.Formats.BinaryInterchange.Operations.Compare.Proof

namespace Inference.Kernels.StableSigmoid
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Inference.Kernels.Trellis.GateUpTail (sigmoid inverse_difference)

-- Binary32 stable sigmoid used by the fused normalization/gate tail. There
-- is no bf16 intermediate cast between its reciprocal, branch, and products.
def negative (x : Float32) : Prop := Model.compare (model x) (model (0 : Float32)) = some .lt
instance (x : Float32) : Decidable (negative x) := inferInstanceAs (Decidable (Model.compare (model x) (model (0 : Float32)) = some .lt))
def denominator (expAbs : Float32 → Float32) (x : Float32) : Float32 := FlushToZero.add 1 (expAbs x)
def quotient (expAbs : Float32 → Float32) (x : Float32) : Float32 := FlushToZero.div 1 (denominator expAbs x)
def value (expAbs : Float32 → Float32) (x : Float32) : Float32 :=
  if negative x then quotient expAbs x else Arithmetic.sub 1 (quotient expAbs x)

theorem real_zero : real (0 : Float32) = 0 := by
  rw [real_unpack]
  exact Model.unpackedToReal_zero .positive

theorem negative_iff (x : Float32) (hx : x.isFinite = true) : negative x ↔ real x < 0 := by
  have h := Model.compare_eq_some_lt_iff_toReal_lt_of_isFinite (model x) (model (0 : Float32))
    (by rw [finite_model]; exact hx) (by rw [finite_model]; decide)
  change negative x ↔ real x < real (0 : Float32) at h
  rwa [real_zero] at h

structure ExpContract (expAbs : Float32 → Float32) (error : Float32 → ℝ) : Prop where
  nonnegative : ∀ x, x.isFinite = true → (expAbs x).isFinite = true → 0 ≤ real (expAbs x)
  accuracy : ∀ x, x.isFinite = true → (expAbs x).isFinite = true →
    |real (expAbs x) - Real.exp (|real x|)| ≤ error x

structure Finite (expAbs : Float32 → Float32) (x : Float32) : Prop where
  input : x.isFinite = true
  exponential : (expAbs x).isFinite = true
  addition : ((1 : Float32) + FlushToZero.flush (expAbs x)).isFinite = true
  reciprocal : ((1 : Float32) / denominator expAbs x).isFinite = true
  subtraction : ¬negative x → (FlushToZero.flush (1 : Float32) - FlushToZero.flush (quotient expAbs x)).isFinite = true

theorem denominator_ge_one (expAbs : Float32 → Float32) (error : Float32 → ℝ)
    (he : ExpContract expAbs error) (x : Float32) (hf : Finite expAbs x) : 1 ≤ real (denominator expAbs x) :=
  FlushToZero.add_one_ge_one (expAbs x) hf.exponential (he.nonnegative x hf.input hf.exponential) hf.addition

theorem denominator_finite (expAbs : Float32 → Float32) (x : Float32) (hf : Finite expAbs x) :
    (denominator expAbs x).isFinite = true := by
  unfold denominator FlushToZero.add
  rw [FlushToZero.flush_one]
  exact FlushToZero.finite_flush _ hf.addition

theorem quotient_finite (expAbs : Float32 → Float32) (error : Float32 → ℝ)
    (he : ExpContract expAbs error) (x : Float32) (hf : Finite expAbs x) : (quotient expAbs x).isFinite = true := by
  unfold quotient FlushToZero.div
  rw [FlushToZero.flush_one, FlushToZero.flush_eq_of_one_le _ (denominator_ge_one expAbs error he x hf)]
  exact FlushToZero.finite_flush _ hf.reciprocal

noncomputable def reciprocalBudget (expAbs : Float32 → Float32) (error : Float32 → ℝ) (x : Float32) : ℝ :=
  FlushToZero.threshold + epsilon (1 / real (denominator expAbs x)) +
    (FlushToZero.addBudget 1 (expAbs x) + error x) /
      (real (denominator expAbs x) * (1 + Real.exp (|real x|)))
noncomputable def finiteBudget (expAbs : Float32 → Float32) (error : Float32 → ℝ) (x : Float32) : ℝ :=
  reciprocalBudget expAbs error x + if negative x then 0 else Arithmetic.subBudget 1 (quotient expAbs x)

theorem quotient_error (expAbs : Float32 → Float32) (error : Float32 → ℝ)
    (he : ExpContract expAbs error) (x : Float32) (hf : Finite expAbs x) :
    |real (quotient expAbs x) - 1 / (1 + Real.exp (|real x|))| ≤ reciprocalBudget expAbs error x := by
  have hfadd : (FlushToZero.flush (1 : Float32) + FlushToZero.flush (expAbs x)).isFinite = true := by
    simpa only [FlushToZero.flush_one] using hf.addition
  have hd := FlushToZero.add_error (1 : Float32) (expAbs x) (by decide) hf.exponential hfadd
  rw [real_one] at hd
  have hex := he.accuracy x hf.input hf.exponential
  have hden : |real (denominator expAbs x) - (1 + Real.exp (|real x|))| ≤ FlushToZero.addBudget 1 (expAbs x) + error x := by
    calc
      _ = |(real (denominator expAbs x) - (1 + real (expAbs x))) + (real (expAbs x) - Real.exp (|real x|))| := by congr 1; ring
      _ ≤ _ := (abs_add_le _ _).trans (add_le_add hd hex)
  have hp := denominator_ge_one expAbs error he x hf
  have hi : |1 / real (denominator expAbs x) - 1 / (1 + Real.exp (|real x|))| ≤
      (FlushToZero.addBudget 1 (expAbs x) + error x) / (real (denominator expAbs x) * (1 + Real.exp (|real x|))) := by
    rw [inverse_difference _ _ (by linarith) (by positivity)]
    exact div_le_div_of_nonneg_right hden (by positivity)
  have hq := FlushToZero.reciprocal_error (denominator expAbs x) (denominator_finite expAbs x hf) hp hf.reciprocal
  calc
    _ = |(real (quotient expAbs x) - 1 / real (denominator expAbs x)) +
      (1 / real (denominator expAbs x) - 1 / (1 + Real.exp (|real x|)))| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add hq hi)

theorem finite_error (expAbs : Float32 → Float32) (error : Float32 → ℝ)
    (he : ExpContract expAbs error) (x : Float32) (hf : Finite expAbs x) :
    |real (value expAbs x) - sigmoid (real x)| ≤ finiteBudget expAbs error x := by
  have hq := quotient_error expAbs error he x hf
  have ht := Inference.Kernels.Trellis.GateUpTail.stable_sigmoid (real x)
  by_cases hn : negative x
  · have hr := (negative_iff x hf.input).mp hn
    simpa only [value, finiteBudget, hn, ite_true, add_zero, hr, ← ht] using hq
  · have hr : ¬real x < 0 := fun h => hn ((negative_iff x hf.input).mpr h)
    simp only [hr, ite_false] at ht
    have hs := Arithmetic.sub_error (1 : Float32) (quotient expAbs x) (by decide)
      (quotient_finite expAbs error he x hf) (hf.subtraction hn)
    rw [real_one] at hs
    simp only [value, finiteBudget, hn, ite_false]
    rw [← ht]
    calc
      _ = |(real (Arithmetic.sub 1 (quotient expAbs x)) - (1 - real (quotient expAbs x))) -
        (real (quotient expAbs x) - 1 / (1 + Real.exp (|real x|)))| := by congr 1; ring
      _ ≤ _ := by have h := (abs_sub _ _).trans (add_le_add hs hq); linarith

theorem quotient_overflow (expAbs : Float32 → Float32) (x : Float32) (he : expAbs x = Float32.inf) : quotient expAbs x = 0 := by
  unfold quotient denominator
  rw [he]
  decide +kernel

theorem value_overflow (expAbs : Float32 → Float32) (x : Float32) (he : expAbs x = Float32.inf) :
    value expAbs x = if negative x then 0 else 1 := by
  unfold value
  rw [quotient_overflow expAbs x he]
  split
  · rfl
  · decide +kernel

theorem overflow_error (expAbs : Float32 → Float32) (x : Float32) (hx : x.isFinite = true) (he : expAbs x = Float32.inf) :
    |real (value expAbs x) - sigmoid (real x)| = 1 / (1 + Real.exp (|real x|)) := by
  rw [value_overflow expAbs x he]
  have ht := Inference.Kernels.Trellis.GateUpTail.stable_sigmoid (real x)
  have hp : 0 < 1 / (1 + Real.exp (|real x|)) := by positivity
  by_cases hn : negative x
  · have hr := (negative_iff x hx).mp hn
    simp only [hn, ite_true, real_zero, hr] at ht ⊢
    rw [← ht, zero_sub, abs_neg, abs_of_pos hp]
  · have hr : ¬real x < 0 := fun h => hn ((negative_iff x hx).mpr h)
    simp only [hn, ite_false, real_one, hr] at ht ⊢
    rw [← ht]
    have hh : (1 : ℝ) - (1 - 1 / (1 + Real.exp (|real x|))) = 1 / (1 + Real.exp (|real x|)) := by ring
    rw [hh, abs_of_pos hp]

def Valid (expAbs : Float32 → Float32) (x : Float32) : Prop := Finite expAbs x ∨ expAbs x = Float32.inf
noncomputable def budget (expAbs : Float32 → Float32) (error : Float32 → ℝ) (x : Float32) : ℝ :=
  if (expAbs x).isFinite then finiteBudget expAbs error x else 1 / (1 + Real.exp (|real x|))

theorem accuracy (expAbs : Float32 → Float32) (error : Float32 → ℝ) (he : ExpContract expAbs error)
    (x : Float32) (hx : x.isFinite = true) (hv : Valid expAbs x) :
    |real (value expAbs x) - sigmoid (real x)| ≤ budget expAbs error x := by
  rcases hv with hf | hi
  · simpa only [budget, hf.exponential, Bool.true_eq, ite_true] using finite_error expAbs error he x hf
  · have hn : (expAbs x).isFinite = false := by rw [hi]; decide
    simpa only [budget, hn, Bool.false_eq_true, ite_false] using (overflow_error expAbs x hx hi).le

end Inference.Kernels.StableSigmoid
