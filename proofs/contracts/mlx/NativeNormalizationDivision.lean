import contracts.mlx.DivisionDirectedBounds
import contracts.mlx.NativeDivisionBounds
import contracts.mlx.FlushOrder
import contracts.mlx.Float32OverflowMargin

namespace Inference.Contracts.Mlx.NativeNormalizationDivision
open Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- IEEE/model logical operations only. This is not a proof of physical M1 Max
-- instruction behavior or a bitwise equality of the two division backends.
-- Signed zeros may share a real value; all bounds below are numerical bounds.
theorem flush_real_congr (x y : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true)
    (same : real x=real y) : real (FlushToZero.flush x)=real (FlushToZero.flush y) :=
  le_antisymm (FlushOrder.monotone x y hx hy same.le) (FlushOrder.monotone y x hy hx same.ge)

theorem raw_real_eq (x y : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true)
    (domain : Division.DivisorDomain y) (finite : (FlushToZero.flush x/y).isFinite=true) :
    real (FlushToZero.flush x/y)=real (DivisionBounds.raw x y) :=
  (Numerics.div_real _ y hy finite).trans (DivisionBounds.raw_real x y hx hy domain).symm

theorem real_eq_reference (x y : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true)
    (domain : Division.DivisorDomain y) (finite : (FlushToZero.flush x/y).isFinite=true) :
    real (FlushToZero.div x y)=real (DivisionBounds.value x y) := by
  unfold FlushToZero.div DivisionBounds.value
  rw [FlushToZero.flush_eq_of_one_le y domain.1]
  exact FlushToZero.real_flushExact_congr _ _ _ (raw_real_eq x y hx hy domain finite)


-- A global native-logical finite-division proof would leave no independent
-- numerical directed-bound premises: all other fields transfer from the
-- established IEEE reference. Actual native selection remains external.
theorem directed_of_finite
    (finite : ∀ x y : Float32, x.isFinite=true → y.isFinite=true → Division.DivisorDomain y →
      (FlushToZero.flush x/y).isFinite=true) : DivisionDirectedBounds.Contract FlushToZero.div := by
  refine ⟨⟨?_,?_⟩,?_,?_⟩
  · intro x y hx hy domain
    unfold FlushToZero.div
    rw [FlushToZero.flush_eq_of_one_le y domain.1]
    exact FlushToZero.finite_flushExact _ _ (finite x y hx hy domain)
  · intro x y cap hx hy domain hc bound
    rw [real_eq_reference x y hx hy domain (finite x y hx hy domain)]
    exact DivisionDirectedBounds.reference.bounded x y cap hx hy domain hc bound
  · intro x y cap hx hy domain hc bound
    rw [real_eq_reference x y hx hy domain (finite x y hx hy domain)]
    exact DivisionDirectedBounds.reference.quotientBounded x y cap hx hy domain hc bound
  · intro x y floor hx hy domain hf normal bound
    rw [real_eq_reference x y hx hy domain (finite x y hx hy domain)]
    exact DivisionDirectedBounds.reference.lower x y floor hx hy domain hf normal bound

-- All selected RMS divisors are >=128. A weaker >=2 domain already gives
-- strict overflow headroom for every finite numerator, including max-finite.
theorem raw_finite (x y : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true)
    (lower : 2≤real y) : (FlushToZero.flush x/y).isFinite=true := by
  apply NativeDivisionBounds.finite _ y (FlushToZero.finite_flush x hx) hy (by linarith)
  have maximum : |real x|≤Float32OverflowMargin.maximum :=
    Model.abs_toReal_le_posMaxFinite_of_isIEEE_of_isFinite (model x) (by decide) (by rw [finite_model]; exact hx)
  have numerator := (FlushToZero.flush_abs_le x).trans maximum
  rw [abs_div,abs_of_pos (by linarith : 0<real y)]
  apply lt_of_le_of_lt (div_le_div_of_nonneg_left (abs_nonneg _) (by norm_num : (0:ℝ)<2) lower)
  apply lt_of_le_of_lt (div_le_div_of_nonneg_right numerator (by norm_num : (0:ℝ)≤2))
  rw [Float32OverflowMargin.maximum_value]
  norm_num

theorem finite (x y : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true)
    (lower : 2≤real y) : (FlushToZero.div x y).isFinite=true := by
  unfold FlushToZero.div
  rw [FlushToZero.flush_eq_of_one_le y (by linarith)]
  exact FlushToZero.finite_flushExact _ _ (raw_finite x y hx hy lower)

theorem quotient_bounded (x y cap : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true)
    (domain : Division.DivisorDomain y) (lower : 2≤real y) (hc : cap.isFinite=true)
    (bound : |real x|/real y≤real cap) : |real (FlushToZero.div x y)|≤real cap := by
  rw [real_eq_reference x y hx hy domain (raw_finite x y hx hy lower)]
  exact DivisionDirectedBounds.reference.quotientBounded x y cap hx hy domain hc bound

theorem lower (x y floor : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true)
    (domain : Division.DivisorDomain y) (lower : 2≤real y) (hf : floor.isFinite=true)
    (normal : FlushToZero.threshold<real floor)
    (bound : real floor≤real (FlushToZero.flush x)/real y) : real floor≤real (FlushToZero.div x y) := by
  rw [real_eq_reference x y hx hy domain (raw_finite x y hx hy lower)]
  exact DivisionDirectedBounds.reference.lower x y floor hx hy domain hf normal bound

inductive Width where
  | deltaHead | attentionHead | hidden
  deriving DecidableEq

def width : Width → Nat
  | .deltaHead => 128
  | .attentionHead => 256
  | .hidden => 5120

def divisor (w : Width) : Float32 := Float32.ofInt (width w)

theorem divisor_finite (w : Width) : (divisor w).isFinite=true := by cases w <;> decide +kernel

theorem divisor_real (w : Width) : real (divisor w)=width w := by
  cases w with
  | deltaHead =>
      change Model.unpackedToReal (.finite .positive 8388608 (-16) (by decide))=128
      norm_num [Model.unpackedToReal_finite,Model.modelSignBit,Formats.Flocq.bpow,
        FloatLib.Numerics.binaryRadix,FloatLib.Numerics.Radix.toReal]
  | attentionHead =>
      change Model.unpackedToReal (.finite .positive 8388608 (-15) (by decide))=256
      norm_num [Model.unpackedToReal_finite,Model.modelSignBit,Formats.Flocq.bpow,
        FloatLib.Numerics.binaryRadix,FloatLib.Numerics.Radix.toReal]
  | hidden =>
      change Model.unpackedToReal (.finite .positive 10485760 (-11) (by decide))=5120
      norm_num [Model.unpackedToReal_finite,Model.modelSignBit,Formats.Flocq.bpow,
        FloatLib.Numerics.binaryRadix,FloatLib.Numerics.Radix.toReal]

theorem divisor_domain (w : Width) : Division.DivisorDomain (divisor w) := by
  rw [Division.DivisorDomain,divisor_real]
  cases w <;> norm_num [width]

theorem divisor_lower (w : Width) : 2≤real (divisor w) := by rw [divisor_real]; cases w <;> norm_num [width]

theorem selected_finite (w : Width) (x : Float32) (hx : x.isFinite=true) :
    (FlushToZero.div x (divisor w)).isFinite=true := finite x _ hx (divisor_finite w) (divisor_lower w)

theorem selected_reference (w : Width) (x : Float32) (hx : x.isFinite=true) :
    real (FlushToZero.div x (divisor w))=real (DivisionBounds.value x (divisor w)) :=
  real_eq_reference x _ hx (divisor_finite w) (divisor_domain w)
    (raw_finite x _ hx (divisor_finite w) (divisor_lower w))

theorem selected_bounded (w : Width) (x cap : Float32) (hx : x.isFinite=true)
    (hc : cap.isFinite=true) (bound : |real x|≤real cap) :
    |real (FlushToZero.div x (divisor w))|≤real cap := by
  rw [selected_reference w x hx]
  exact DivisionDirectedBounds.reference.bounded x _ cap hx (divisor_finite w) (divisor_domain w) hc bound

theorem selected_quotient_bounded (w : Width) (x cap : Float32) (hx : x.isFinite=true)
    (hc : cap.isFinite=true) (bound : |real x|/real (divisor w)≤real cap) :
    |real (FlushToZero.div x (divisor w))|≤real cap :=
  quotient_bounded x _ cap hx (divisor_finite w) (divisor_domain w) (divisor_lower w) hc bound

theorem selected_lower (w : Width) (x floor : Float32) (hx : x.isFinite=true)
    (hf : floor.isFinite=true) (normal : FlushToZero.threshold<real floor)
    (bound : real floor≤real (FlushToZero.flush x)/real (divisor w)) :
    real floor≤real (FlushToZero.div x (divisor w)) :=
  lower x _ floor hx (divisor_finite w) (divisor_domain w) (divisor_lower w) hf normal bound

theorem selected_accuracy (w : Width) (x : Float32) (hx : x.isFinite=true) :
    |real (FlushToZero.div x (divisor w))-real x/real (divisor w)|≤FlushToZero.divBudget x (divisor w) :=
  Division.flushedRneContract.accuracy x _ hx (divisor_finite w) (divisor_domain w) (selected_finite w x hx)

end Inference.Contracts.Mlx.NativeNormalizationDivision
