import kernels.attention.SdpaSequenceLoopRanges
import kernels.attention.SdpaMergeRelative
import contracts.mlx.DivisionDirectedBounds
import contracts.mlx.BFloat16DyadicBounds
import contracts.mlx.BFloat16ConversionBounds

namespace Inference.Kernels.Attention.SdpaSequenceRanges
open Contracts.Mlx Contracts.Mlx.Numerics SdpaUpdate SdpaVector
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

structure Primitives (p : SdpaVector.Platform) : Prop where
  maximum : SdpaInitialLoopRanges.Maximum p
  exponential : SdpaExponentRanges.Primitive p.merge.scalar
  division : DivisionDirectedBounds.Contract p.normalization.divide

def outputCap : BF := BFloat16DyadicBounds.ceiling 1 26
theorem outputCap_range : Model.isFinite outputCap = true ∧ Model.toReal outputCap = (2 : ℝ)^(26 : Nat) := by
  simpa only [outputCap, Nat.cast_one, one_mul, zpow_ofNat] using
    BFloat16DyadicBounds.ceiling_range 1 26 (by decide) (by decide) (by decide)

theorem ranges (p : SdpaVector.Platform) (primitive : Primitives p) (steps : Nat) (positive : 0 < steps) (bound : steps ≤ 262144)
    (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (hq : ∀ i, Model.isFinite (query i) = true ∧ |Model.toReal (query i)| ≤ 1024)
    (hk : ∀ t i, Model.isFinite (keys t i) = true ∧ |Model.toReal (keys t i)| ≤ 1024)
    (hv : ∀ t i, Model.isFinite (values t i) = true ∧ |Model.toReal (values t i)| ≤ (2 : ℝ)^(23 : Nat)) :
    SdpaVector.Finite p query keys values ∧ ∀ i,
      |Model.toReal (SdpaVector.forward p query keys values i)| ≤ (2 : ℝ)^(26 : Nat) := by
  have loops := SdpaSequenceLoopRanges.ranges p primitive.maximum primitive.exponential steps positive bound query keys values hq hk hv
  obtain ⟨witness, witnessBound⟩ := loops.witness
  have merge (i : Fin 256) := SdpaMergeRelative.ranges p.merge (partials p query keys values i)
    (commonShift p query keys values)
    (fun g => ⟨(loops.partials i g).denominator, (loops.partials i g).denominatorRange.1,
      (loops.partials i g).denominatorRange.2.trans (by exact_mod_cast SdpaSequenceLoopRanges.group_bound steps bound g)⟩)
    (fun g => ⟨(loops.partials i g).numerator, (loops.partials i g).numeratorRange⟩)
    (loops.exponent i) witness (witnessBound i).1 (witnessBound i).2
  have normalization (i : Fin 256) : SdpaNormalize.Finite p.normalization (merged p query keys values i) ∧
      |Model.toReal (SdpaVector.forward p query keys values i)| ≤ (2 : ℝ)^(26 : Nat) := by
    have finite := SdpaMerge.forward_finite p.merge _ _ (merge i).1
    have domain : Division.DivisorDomain (merged p query keys values i).denominator :=
      ⟨(merge i).2.1.1, (merge i).2.1.2.trans (by norm_num)⟩
    have quotient := primitive.division.finite _ _ finite.2.2 finite.2.1 domain
    have cap := DyadicBounds.ceiling_range 1 26 (by decide) (by decide) (by decide)
    have quotientBound := primitive.division.quotientBounded _ _ (DyadicBounds.ceiling 1 26)
      finite.2.2 finite.2.1 domain cap.1 (by
        rw [cap.2, Nat.cast_one, one_mul]
        apply (div_le_iff₀ (by linarith [domain.1] : 0 < real (merged p query keys values i).denominator)).mpr
        simpa only [merged, zpow_ofNat] using (merge i).2.2)
    have cast := BFloat16ConversionBounds.narrow_range _ outputCap quotient outputCap_range.1 (by
      rw [outputCap_range.2]
      simpa only [cap.2, Nat.cast_one, one_mul, zpow_ofNat] using quotientBound)
    exact ⟨⟨finite.2.2, finite.2.1, domain, quotient, cast.1⟩, cast.2.trans_eq outputCap_range.2⟩
  exact ⟨⟨fun i => (hq i).1, fun t i => (hk t i).1, fun t i => (hv t i).1,
    loops.scores, loops.loops, fun i => (merge i).1, fun i => (normalization i).1⟩,
    fun i => (normalization i).2⟩

end Inference.Kernels.Attention.SdpaSequenceRanges
