import contracts.mlx.Division
import contracts.mlx.Float32Bounds
import contracts.mlx.BFloat16

namespace Inference.Contracts.Mlx.DivisionBounds
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange Numerics

-- A scalar primitive boundary. Range preservation is proved below for the
-- flushed, nearest-even IEEE reference. Binding a compiled Metal operation
-- to this reference is a hardware/compiler obligation.
structure Contract (divide : Float32 → Float32 → Float32) : Prop where
  finite : ∀ x y, x.isFinite = true → y.isFinite = true → Division.DivisorDomain y →
    (divide x y).isFinite = true
  bounded : ∀ x y cap, x.isFinite = true → y.isFinite = true → Division.DivisorDomain y →
    cap.isFinite = true → |real x| ≤ real cap → |real (divide x y)| ≤ real cap

def raw (x y : Float32) : Float32 := Float32.ofModel (Model.toFloat32Model
  (Model.div (model (FlushToZero.flush x)) (model y)))
def value (x y : Float32) : Float32 := FlushToZero.flush (raw x y)
noncomputable def error (x y : Float32) : ℝ :=
  2 * FlushToZero.threshold + epsilon (real (FlushToZero.flush x) / real y)

theorem divisor_not_zero (y : Float32) (_hy : y.isFinite = true) (hd : Division.DivisorDomain y) :
    Model.isZero (model y) = false := by
  cases hz : Model.isZero (model y)
  · rfl
  · have hr := Model.toReal_eq_zero_of_isZero (model y) hz
    change real y = 0 at hr
    have := hd.1
    linarith

theorem quotient_bound (x y : Float32) (hd : Division.DivisorDomain y) :
    |real (FlushToZero.flush x) / real y| ≤ |real x| := by
  rw [abs_div, abs_of_pos (by linarith [hd.1] : 0 < real y)]
  exact (div_le_self (abs_nonneg _) hd.1).trans (FlushToZero.flush_abs_le x)

theorem model_finite (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true)
    (hd : Division.DivisorDomain y) :
    Model.isFinite (Model.div (model (FlushToZero.flush x)) (model y)) = true := by
  apply Model.isFinite_div_of_abs_div_le_posMaxFinite _ _ (by decide)
    (by rw [finite_model]; exact FlushToZero.finite_flush x hx)
    (by rw [finite_model]; exact hy) (divisor_not_zero y hy hd)
  exact (quotient_bound x y hd).trans (Model.abs_toReal_le_posMaxFinite_of_isIEEE_of_isFinite (model x)
    (by decide) (by rw [finite_model]; exact hx))

theorem raw_finite (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true)
    (hd : Division.DivisorDomain y) : (raw x y).isFinite = true := by
  change (Model.toFloat32Model (Model.div (model (FlushToZero.flush x)) (model y))).unpack.isFinite = true
  rw [Model.unpack_toFloat32Model, Model.isFinite_toModel (by decide)]
  exact model_finite x y hx hy hd

theorem raw_real (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true)
    (hd : Division.DivisorDomain y) :
    real (raw x y) = Model.roundAt FloatFormat.binary32 (real (FlushToZero.flush x) / real y) := by
  unfold raw
  rw [BFloat16.bridge]
  exact Model.toReal_div_eq_roundAt _ _ (by decide)
    (by rw [finite_model]; exact FlushToZero.finite_flush x hx)
    (by rw [finite_model]; exact hy) (divisor_not_zero y hy hd) (model_finite x y hx hy hd)

theorem referenceRange : Contract value := by
  constructor
  · intro x y hx hy hd
    exact FlushToZero.finite_flush _ (raw_finite x y hx hy hd)
  · intro x y cap hx hy hd hc hb
    apply (FlushToZero.flush_abs_le _).trans
    rw [raw_real x y hx hy hd]
    exact Float32Bounds.rounded_bound cap hc _ ((quotient_bound x y hd).trans hb)

theorem referenceAccuracy : Division.Contract value error := by
  constructor
  · intro x y hx hy hd _
    have er : |real (raw x y) - real (FlushToZero.flush x) / real y| ≤
        epsilon (real (FlushToZero.flush x) / real y) := by
      rw [raw_real x y hx hy hd]
      exact Model.abs_roundAt_sub_le _ _
    have ei : |real (FlushToZero.flush x) / real y - real x / real y| ≤ FlushToZero.threshold := by
      rw [← sub_div, abs_div, abs_of_pos (by linarith [hd.1] : 0 < real y)]
      exact (div_le_self (abs_nonneg _) hd.1).trans (FlushToZero.flush_error x)
    have eo := FlushToZero.flush_error (raw x y)
    unfold value error
    calc
      _ = |(real (FlushToZero.flush (raw x y)) - real (raw x y)) +
          ((real (raw x y) - real (FlushToZero.flush x) / real y) +
          (real (FlushToZero.flush x) / real y - real x / real y))| := by congr 1; ring
      _ ≤ _ := by
        have h := (abs_add_le _ _).trans (add_le_add eo ((abs_add_le _ _).trans (add_le_add er ei)))
        linarith
  · intro x y hx hy hn hd _
    apply FlushToZero.flush_nonnegative
    rw [raw_real x y hx hy hd]
    exact FlushToZero.round_nonnegative _ (div_nonneg (FlushToZero.flush_nonnegative x hn) (by linarith [hd.1]))

end Inference.Contracts.Mlx.DivisionBounds
