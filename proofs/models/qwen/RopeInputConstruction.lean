import models.qwen.TokenAutoregressive
import contracts.mlx.IntegerBounds
import Mathlib.Analysis.Complex.ExponentialBounds

namespace Inference.Models.Qwen.RopeInputConstruction
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Attention
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- rope.cpp passes float std::log2(base_) to rope_single. This is the
-- observed CPU result for base_=10000000. Native libm correspondence to
-- this word remains explicit; no CPU observation is used as a Lean axiom.
def base : Float32 := Float32.ofBits 0x41ba0729
theorem base_finite : base.isFinite = true := by decide +kernel
theorem base_real : real base = (12191529 : ℝ)/524288 := by
  have decoded : Model.toDyadic? (model base) = some ⟨false, 12191529, -19⟩ := by decide +kernel
  change Model.toReal (model base) = _
  rw [Model.toReal_eq, decoded]
  norm_num [FloatLib.Numerics.Dyadic.toReal, FloatLib.Numerics.Dyadic.signedSignificand]

theorem logarithm_expansion : Real.log 10000000 = 7*(Real.log 2 + Real.log 5) := by
  rw [show (10000000 : ℝ) = 10^7 from by norm_num, Real.log_pow, Real.log_ten_eq]
  norm_num

theorem base_accuracy : |real base - Real.log 10000000 / Real.log 2| ≤ (1 : ℝ)/1048576 := by
  rw [base_real, logarithm_expansion]
  have positive : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have low : ((12191529 : ℝ)/524288 - 1/1048576)*Real.log 2 ≤ 7*(Real.log 2 + Real.log 5) := by
    linarith [Real.log_two_lt_d9, Real.log_five_gt_d9]
  have high : 7*(Real.log 2 + Real.log 5) ≤ ((12191529 : ℝ)/524288 + 1/1048576)*Real.log 2 := by
    linarith [Real.log_two_gt_d9, Real.log_five_lt_d9]
  have lower := (le_div_iff₀ positive).mpr low
  have upper := (div_le_iff₀ positive).mpr high
  exact abs_le.mpr ⟨by linarith, by linarith⟩

def inputs (time : Nat) : RopeAngles.Inputs := ⟨base, Float32.ofInt time, 1⟩
noncomputable def target (time : Nat) : RopeAngles.Target :=
  ⟨Real.log 10000000 / Real.log 2, time, 1⟩
noncomputable def error : RopeAngles.Target := ⟨1/1048576, 0, 0⟩

theorem position_exact (time : Nat) (supported : time < 262144) :
    (inputs time).position.isFinite = true ∧ real (inputs time).position = (time : ℝ) :=
  IntegerBounds.natural time (by omega)

theorem inputs_bound (time : Nat) (supported : time < 262144) : RopeAnglesRanges.InputsBound (inputs time) := by
  refine ⟨base_finite, ?_, ?_, (position_exact time supported).1, ?_, by change (1 : Float32).isFinite = true; decide +kernel, ?_⟩
  · change 0 ≤ real base
    rw [base_real]
    norm_num
  · change |real base| ≤ 32
    rw [base_real]
    norm_num
  · rw [(position_exact time supported).2, abs_of_nonneg (Nat.cast_nonneg _)]
    norm_num
    exact_mod_cast supported.le
  · change |real (1 : Float32)| ≤ 1
    rw [real_one]
    norm_num

theorem input_error (time : Nat) (supported : time < 262144) :
    RopeAngles.InputError (inputs time) (target time) error := by
  constructor
  · exact base_accuracy
  · change |real (inputs time).position - (time : ℝ)| ≤ 0
    rw [(position_exact time supported).2, sub_self, abs_zero]
  · change |real (1 : Float32) - 1| ≤ 0
    rw [real_one, sub_self, abs_zero]

theorem target_base_nonnegative (time : Nat) : 0 ≤ (target time).base :=
  div_nonneg (Real.log_nonneg (by norm_num)) (Real.log_nonneg (by norm_num))

-- The complete sequence now derives its input contracts from the position
-- constructor. Only the fixed host log2 discrepancy appears in its error.
noncomputable def angles : TokenAutoregressive.Angles where
  value := inputs
  target := target
  error := fun _ => error
  ranges := inputs_bound
  accuracy := input_error
  base := fun time _ => target_base_nonnegative time

theorem source_inputs (hostLog2 : Float32) (host : hostLog2 = base) (time : Nat) :
    (⟨hostLog2, Float32.ofInt time, 1⟩ : RopeAngles.Inputs) = inputs time := by
  subst hostLog2
  rfl

theorem signed_offset_bound (time : Nat) (supported : time < 262144) : time < 2147483648 := by omega

theorem power_law (time : Nat) (i : Fin 32) :
    RopeAngles.targetValue (target time) i =
      (time : ℝ) * Real.exp (-((i.val : ℝ)/32) * Real.log 10000000) := by
  simpa only [target, one_mul] using RopeAngles.base_frequency 10000000 time 1 i

end Inference.Models.Qwen.RopeInputConstruction
