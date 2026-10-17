import kernels.attention.SdpaTwoPassVector
import kernels.attention.SdpaSequenceRanges

namespace Inference.Kernels.Attention.SdpaTwoPassRanges
open Contracts.Mlx Contracts.Mlx.Numerics SdpaUpdate SdpaTwoPassVector
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

def outputCap : BF := BFloat16DyadicBounds.ceiling 1 27
theorem outputCap_range : Model.isFinite outputCap = true ∧ Model.toReal outputCap = (2 : ℝ)^(27 : Nat) := by
  simpa only [outputCap, Nat.cast_one, one_mul, zpow_ofNat] using
    BFloat16DyadicBounds.ceiling_range 1 27 (by decide) (by decide) (by decide)

theorem ranges (p : SdpaVector.Platform) (primitive : SdpaSequenceRanges.Primitives p)
    (contracted : Bool) (blocks : Nat) (minimum : 32 ≤ blocks) (supported : blocks ≤ 1024)
    (active : blocks ≤ steps) (bound : steps ≤ 262144)
    (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (hq : ∀ i, Model.isFinite (query i) = true ∧ |Model.toReal (query i)| ≤ 1024)
    (hk : ∀ t i, Model.isFinite (keys t i) = true ∧ |Model.toReal (keys t i)| ≤ 1024)
    (hv : ∀ t i, Model.isFinite (values t i) = true ∧ |Model.toReal (values t i)| ≤ (2 : ℝ)^(23 : Nat)) :
    SdpaTwoPassVector.Finite p contracted blocks query keys values ∧ ∀ i,
      |Model.toReal (forward p contracted blocks query keys values i)| ≤ (2 : ℝ)^(27 : Nat) := by
  have first (i : Fin 256) (block : Fin blocks) := SdpaTwoPassFirstPass.ranges p primitive.maximum primitive.exponential
    minimum active bound query keys values hq hk hv i block
  have finite i block := SdpaTwoPassFirstPass.loaded_finite p query keys values i block (first i block)
  have shiftBound (i : Fin 256) (block : Fin blocks) :
      |real (partials p query keys values i block).shift| ≤ (2 : ℝ)^(24 : Nat) := (first i block).rawBound.shift.2
  let maxima := fun block : Fin blocks => (partials p query keys values 0 block).shift
  obtain ⟨winner, selected, largest⟩ := SdpaTwoPassMaximum.selected p primitive.maximum minimum maxima
    (fun b => (finite 0 b).1) (shiftBound 0)
  have common : (commonShift p blocks query keys values).isFinite = true ∧
      |real (commonShift p blocks query keys values)| ≤ (2 : ℝ)^(24 : Nat) := by
    change (SdpaTwoPassMaximum.common p maxima).isFinite = true ∧
      |real (SdpaTwoPassMaximum.common p maxima)| ≤ (2 : ℝ)^(24 : Nat)
    rw [selected]
    exact ⟨(finite 0 winner).1, shiftBound 0 winner⟩
  have order (i : Fin 256) (block : Fin blocks) :
      real (FlushToZero.flush (partials p query keys values i block).shift) ≤
        real (FlushToZero.flush (commonShift p blocks query keys values)) := by
    rw [(SdpaTwoPassFirstPass.shared p query keys values i 0 block).1]
    change real (FlushToZero.flush (maxima block)) ≤ real (FlushToZero.flush (SdpaTwoPassMaximum.common p maxima))
    rw [selected]
    exact largest block
  have exponent (i : Fin 256) (block : Fin blocks) := SdpaOrderedExponentRanges.ordered p.merge.scalar primitive.exponential
    (partials p query keys values i block).shift (commonShift p blocks query keys values)
    ⟨(finite i block).1, shiftBound i block⟩ common (order i block)
  have witness (i : Fin 256) :
      real (exponential p.merge.scalar (partials p query keys values i winner).shift (commonShift p blocks query keys values)) = 1 := by
    rw [(SdpaTwoPassFirstPass.shared p query keys values i 0 winner).1]
    change real (exponential p.merge.scalar (maxima winner) (SdpaTwoPassMaximum.common p maxima)) = 1
    rw [selected]
    exact (SdpaExponentRanges.diagonal p.merge.scalar primitive.exponential _ (finite 0 winner).1).2
  have merge (i : Fin 256) := SdpaTwoPassMergeRanges.ranges p.merge contracted (partials p query keys values i)
    (commonShift p blocks query keys values) supported
    (fun b => ⟨(finite i b).2.1, le_trans (by norm_num : (0 : ℝ) ≤ 1) (first i b).rawBound.denominator.2.1,
      (first i b).rawBound.denominator.2.2.trans (by exact_mod_cast SdpaTwoPassLayout.count_bound steps blocks bound minimum b)⟩)
    (fun b => ⟨(finite i b).2.2, by
      change |real (BFloat16.widen (SdpaTwoPassFirstPass.stored p query keys values i b))| ≤ _
      rw [BFloat16.widen_real _ (first i b).cast]
      exact (first i b).storedBound⟩)
    (exponent i) winner (first i winner).rawBound.denominator.2.1 (witness i)
  have normalization (i : Fin 256) : SdpaNormalize.Finite p.normalization (merged p contracted blocks query keys values i) ∧
      |Model.toReal (forward p contracted blocks query keys values i)| ≤ (2 : ℝ)^(27 : Nat) := by
    have mf := SdpaTwoPassMerge.forward_finite p.merge contracted _ _ (merge i).1 common.1
    have domain : Division.DivisorDomain (merged p contracted blocks query keys values i).denominator :=
      ⟨(merge i).2.1.1, (merge i).2.1.2.trans (by norm_num)⟩
    have quotient := primitive.division.finite _ _ mf.2.2 mf.2.1 domain
    have cap := DyadicBounds.ceiling_range 1 27 (by decide) (by decide) (by decide)
    have quotientBound := primitive.division.quotientBounded _ _ (DyadicBounds.ceiling 1 27)
      mf.2.2 mf.2.1 domain cap.1 (by
        rw [cap.2, Nat.cast_one, one_mul]
        apply (div_le_iff₀ (by linarith [domain.1] : 0 < real (merged p contracted blocks query keys values i).denominator)).mpr
        simpa only [merged, zpow_ofNat] using (merge i).2.2)
    have cast := BFloat16ConversionBounds.narrow_range _ outputCap quotient outputCap_range.1 (by
      rw [outputCap_range.2]
      simpa only [cap.2, Nat.cast_one, one_mul, zpow_ofNat] using quotientBound)
    exact ⟨⟨mf.2.2, mf.2.1, domain, quotient, cast.1⟩, cast.2.trans_eq outputCap_range.2⟩
  exact ⟨⟨fun i => (hq i).1, fun t i => (hk t i).1, fun t i => (hv t i).1,
    fun t => (SdpaScoreRanges.ranges p.scoreContracted p.merge.reduce p.merge.reduction query (keys t) hq (hk t)).1,
    first, fun i => (merge i).1, fun i => (normalization i).1⟩, fun i => (normalization i).2⟩

end Inference.Kernels.Attention.SdpaTwoPassRanges
