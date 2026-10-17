import contracts.mlx.Arithmetic
import kernels.trellis.GateUpTail
import FloatLib.Floats.Formats.BinaryInterchange.Operations.Compare.Proof

namespace Inference.Kernels.StableSigmoid
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Inference.Kernels.Trellis.GateUpTail (sigmoid inverse_difference)

-- Binary32 stable sigmoid used by the fused normalization/gate tail. There
-- is no bf16 intermediate cast between its reciprocal, branch, and products.
-- With denormals disabled the sign test compares the flushed input.
def negative (x : Float32) : Prop :=
  Model.compare (model (FlushToZero.flush x)) (model (0 : Float32)) = some .lt
instance (x : Float32) : Decidable (negative x) :=
  inferInstanceAs (Decidable (Model.compare (model (FlushToZero.flush x)) (model (0 : Float32)) = some .lt))
def denominator (expAbs : Float32 → Float32) (x : Float32) : Float32 := FlushToZero.add 1 (expAbs x)
def quotient (expAbs : Float32 → Float32) (x : Float32) : Float32 := FlushToZero.div 1 (denominator expAbs x)
def value (expAbs : Float32 → Float32) (x : Float32) : Float32 :=
  if negative x then quotient expAbs x else Arithmetic.sub 1 (quotient expAbs x)

theorem real_zero : real (0 : Float32) = 0 := by
  rw [real_unpack]
  exact Model.unpackedToReal_zero .positive

theorem negative_iff (x : Float32) (hx : x.isFinite = true) : negative x ↔ real (FlushToZero.flush x) < 0 := by
  have h := Model.compare_eq_some_lt_iff_toReal_lt_of_isFinite (model (FlushToZero.flush x)) (model (0 : Float32))
    (by rw [finite_model]; exact FlushToZero.finite_flush x hx) (by rw [finite_model]; decide)
  change negative x ↔ real (FlushToZero.flush x) < real (0 : Float32) at h
  rwa [real_zero] at h

theorem negative_real (x : Float32) (hx : x.isFinite = true) (hn : negative x) : real x < 0 := by
  have h := (negative_iff x hx).mp hn
  rcases FlushToZero.flush_cases x with e | e
  · rwa [e] at h
  · rw [e.1] at h; exact absurd h (lt_irrefl 0)

-- A nonnegative flushed input is nonnegative or tiny.
theorem nonnegative_real (x : Float32) (hx : x.isFinite = true) (hn : ¬negative x) :
    0 ≤ real x ∨ (real x < 0 ∧ |real x| < FlushToZero.threshold) := by
  by_cases h : real x < 0
  · rcases FlushToZero.flush_cases x with e | e
    · exact absurd ((negative_iff x hx).mpr (by rwa [e])) hn
    · exact Or.inr ⟨h, e.2.2⟩
  · exact Or.inl (le_of_not_gt h)

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
  exact FlushToZero.finite_flushExact _ _ hf.reciprocal

noncomputable def reciprocalBudget (expAbs : Float32 → Float32) (error : Float32 → ℝ) (x : Float32) : ℝ :=
  FlushToZero.threshold + epsilon (1 / real (denominator expAbs x)) +
    (FlushToZero.addBudget 1 (expAbs x) + error x) /
      (real (denominator expAbs x) * (1 + Real.exp (|real x|)))
noncomputable def finiteBudget (expAbs : Float32 → Float32) (error : Float32 → ℝ) (x : Float32) : ℝ :=
  reciprocalBudget expAbs error x +
    if negative x then 0 else Arithmetic.subBudget 1 (quotient expAbs x) + FlushToZero.threshold

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
  · have hr := negative_real x hf.input hn
    simpa only [value, finiteBudget, hn, ite_true, add_zero, hr, ← ht] using hq
  · have hs := Arithmetic.sub_error (1 : Float32) (quotient expAbs x) (by decide)
      (quotient_finite expAbs error he x hf) (hf.subtraction hn)
    rw [real_one] at hs
    simp only [value, finiteBudget, hn, ite_false]
    have hb : |(1-1/(1+Real.exp |real x|))-sigmoid (real x)| ≤ FlushToZero.threshold := by
      rcases nonnegative_real x hf.input hn with h | h
      · simp only [not_lt.mpr h, ite_false] at ht
        rw [← ht, sub_self, abs_zero]
        exact FlushToZero.threshold_pos.le
      · exact (Inference.Kernels.Trellis.GateUpTail.upper_branch _ h.1
          (h.2.le.trans FlushToZero.threshold_lt_one.le)).trans h.2.le
    calc
      _ = |((real (Arithmetic.sub 1 (quotient expAbs x)) - (1 - real (quotient expAbs x))) -
        (real (quotient expAbs x) - 1 / (1 + Real.exp (|real x|)))) +
        ((1-1/(1+Real.exp |real x|))-sigmoid (real x))| := by congr 1; ring
      _ ≤ _ := by
        have h := (abs_add_le _ _).trans (add_le_add ((abs_sub _ _).trans (add_le_add hs hq)) hb)
        linarith

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
    |real (value expAbs x) - sigmoid (real x)| ≤ 1 / (1 + Real.exp (|real x|)) + FlushToZero.threshold := by
  rw [value_overflow expAbs x he]
  have ht := Inference.Kernels.Trellis.GateUpTail.stable_sigmoid (real x)
  have hp : 0 < 1 / (1 + Real.exp (|real x|)) := by positivity
  have h0 := FlushToZero.threshold_pos
  by_cases hn : negative x
  · have hr := negative_real x hx hn
    simp only [hn, ite_true, real_zero, hr] at ht ⊢
    rw [← ht, zero_sub, abs_neg, abs_of_pos hp]
    linarith
  · simp only [hn, ite_false, real_one]
    rcases nonnegative_real x hx hn with h | h
    · simp only [not_lt.mpr h, ite_false] at ht
      rw [← ht]
      have hh : (1 : ℝ) - (1 - 1 / (1 + Real.exp (|real x|))) = 1 / (1 + Real.exp (|real x|)) := by ring
      rw [hh, abs_of_pos hp]
      linarith
    · have hb := Inference.Kernels.Trellis.GateUpTail.upper_branch _ h.1 (h.2.le.trans FlushToZero.threshold_lt_one.le)
      calc
        _ = |((1-1/(1+Real.exp |real x|))-sigmoid (real x)) + 1/(1+Real.exp |real x|)| := by congr 1; ring
        _ ≤ _ := by
          have := (abs_add_le _ _).trans (add_le_add hb (le_of_eq (abs_of_pos hp)))
          linarith [h.2]

def Valid (expAbs : Float32 → Float32) (x : Float32) : Prop := Finite expAbs x ∨ expAbs x = Float32.inf
noncomputable def budget (expAbs : Float32 → Float32) (error : Float32 → ℝ) (x : Float32) : ℝ :=
  if (expAbs x).isFinite then finiteBudget expAbs error x else 1 / (1 + Real.exp (|real x|)) + FlushToZero.threshold


theorem accuracy (expAbs : Float32 → Float32) (error : Float32 → ℝ) (he : ExpContract expAbs error)
    (x : Float32) (hx : x.isFinite = true) (hv : Valid expAbs x) :
    |real (value expAbs x) - sigmoid (real x)| ≤ budget expAbs error x := by
  rcases hv with hf | hi
  · simpa only [budget, hf.exponential, Bool.true_eq, ite_true] using finite_error expAbs error he x hf
  · have hn : (expAbs x).isFinite = false := by rw [hi]; decide
    simpa only [budget, hn, Bool.false_eq_true, ite_false] using overflow_error expAbs x hx hi

end Inference.Kernels.StableSigmoid
