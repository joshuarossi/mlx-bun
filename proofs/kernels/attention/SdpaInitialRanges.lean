import kernels.attention.SdpaInitialLoopRanges
import kernels.attention.SdpaMergeRanges
import contracts.mlx.DivisionBounds
import contracts.mlx.BFloat16DyadicBounds
import contracts.mlx.BFloat16ConversionBounds

namespace Inference.Kernels.Attention.SdpaInitialRanges
open Contracts.Mlx Contracts.Mlx.Numerics SdpaUpdate SdpaVector
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

structure Primitives (p : SdpaVector.Platform) : Prop where
  maximum : SdpaInitialLoopRanges.Maximum p
  exponential : SdpaExponentRanges.Primitive p.merge.scalar
  division : DivisionBounds.Contract p.normalization.divide

def outputCap : BF := BFloat16DyadicBounds.ceiling 1 28
theorem outputCap_range : Model.isFinite outputCap = true ∧ Model.toReal outputCap = (2 : ℝ)^(28 : Nat) := by
  simpa [outputCap] using BFloat16DyadicBounds.ceiling_range 1 28 (by decide) (by decide) (by decide)

theorem ranges (p : SdpaVector.Platform) (primitive : Primitives p)
    (query : Fin 256 → BF) (keys values : Fin 1 → Fin 256 → BF)
    (hq : ∀ i, Model.isFinite (query i) = true ∧ |Model.toReal (query i)| ≤ 1024)
    (hk : ∀ t i, Model.isFinite (keys t i) = true ∧ |Model.toReal (keys t i)| ≤ 1024)
    (hv : ∀ t i, Model.isFinite (values t i) = true ∧ |Model.toReal (values t i)| ≤ (2 : ℝ)^(23 : Nat)) :
    SdpaVector.Finite p query keys values ∧ ∀ i,
      |Model.toReal (SdpaVector.forward p query keys values i)| ≤ (2 : ℝ)^(28 : Nat) := by
  have loops := SdpaInitialLoopRanges.ranges p primitive.maximum primitive.exponential query keys values hq hk hv
  have exponent i g : ExponentFinite p.merge.scalar (partials p query keys values i g).shift (commonShift p query keys values) ∧
      0 ≤ real (exponential p.merge.scalar (partials p query keys values i g).shift (commonShift p query keys values)) ∧
      real (exponential p.merge.scalar (partials p query keys values i g).shift (commonShift p query keys values)) ≤ 1 := by
    rw [loops.shift, loops.common]
    split
    · have h := SdpaExponentRanges.diagonal p.merge.scalar primitive.exponential _ loops.scoreFinite
      exact ⟨h.1, by rw [h.2]; norm_num⟩
    · exact SdpaExponentRanges.initial p.merge.scalar primitive.exponential _ loops.scoreFinite loops.scoreRange
  have eabs i g : (exponential p.merge.scalar (partials p query keys values i g).shift (commonShift p query keys values)).isFinite = true ∧
      |real (exponential p.merge.scalar (partials p query keys values i g).shift (commonShift p query keys values))| ≤ 1 :=
    ⟨(exponent i g).1.exponential, by rw [abs_of_nonneg (exponent i g).2.1]; exact (exponent i g).2.2⟩
  have denominator i : Arithmetic.Finite (SdpaMerge.bind p.merge (partials p query keys values i) (commonShift p query keys values) false)
      (SdpaMerge.expression p.merge.reduction.tree) ∧
      |real (SdpaMerge.source p.merge (partials p query keys values i) (commonShift p query keys values) false)| ≤ 32 := by
    have h := SdpaMergeRanges.component_ranges p.merge (partials p query keys values i) (commonShift p query keys values)
      false 0 (by decide) (by decide) (fun g => ⟨(loops.partials i g).denominator, by
        change |real (partials p query keys values i g).denominator| ≤ (2 : ℝ)^(0 : Int)
        rw [abs_of_nonneg (loops.partials i g).denominatorRange.1, zpow_zero]
        exact (loops.partials i g).denominatorRange.2⟩) (eabs i)
    simpa only [zpow_zero, mul_one] using h
  have numerator i : Arithmetic.Finite (SdpaMerge.bind p.merge (partials p query keys values i) (commonShift p query keys values) true)
      (SdpaMerge.expression p.merge.reduction.tree) ∧
      |real (SdpaMerge.source p.merge (partials p query keys values i) (commonShift p query keys values) true)| ≤ (2 : ℝ)^(28 : Nat) := by
    have h := SdpaMergeRanges.component_ranges p.merge (partials p query keys values i) (commonShift p query keys values)
      true 23 (by decide) (by decide) (fun g => ⟨(loops.partials i g).numerator, by
        simpa only [SdpaMerge.component, ite_true, zpow_ofNat] using (loops.partials i g).numeratorRange⟩) (eabs i)
    norm_num at h ⊢
    exact h
  have merge i : SdpaMerge.Finite p.merge (partials p query keys values i) (commonShift p query keys values) :=
    ⟨fun g => (exponent i g).1, fun n => by cases n; exact (denominator i).1; exact (numerator i).1⟩
  have lower i : 1 ≤ real (merged p query keys values i).denominator := by
    apply SdpaMergeRanges.denominator_lower p.merge (partials p query keys values i) (commonShift p query keys values)
      (merge i) (fun g => (loops.partials i g).denominatorRange.1) (fun g => (exponent i g).2.1) 0 (loops.denominatorZero i)
    rw [loops.shift, loops.common, ite_eq_left rfl]
    exact (SdpaExponentRanges.diagonal p.merge.scalar primitive.exponential _ loops.scoreFinite).2
  have norm i : SdpaNormalize.Finite p.normalization (merged p query keys values i) ∧
      |Model.toReal (SdpaVector.forward p query keys values i)| ≤ (2 : ℝ)^(28 : Nat) := by
    have hm := SdpaMerge.forward_finite p.merge _ _ (merge i)
    have domain : Division.DivisorDomain (merged p query keys values i).denominator :=
      ⟨lower i, ((le_abs_self _).trans (denominator i).2).trans (by norm_num)⟩
    have quotient := primitive.division.finite _ _ hm.2.2 hm.2.1 domain
    have fp := DyadicBounds.ceiling_range 1 28 (by decide) (by decide) (by decide)
    have bound := primitive.division.bounded _ _ (DyadicBounds.ceiling 1 28) hm.2.2 hm.2.1 domain fp.1 (by
      simpa only [fp.2, Nat.cast_one, one_mul, zpow_ofNat, SdpaMerge.forward] using (numerator i).2)
    have cast := BFloat16ConversionBounds.narrow_range _ outputCap quotient outputCap_range.1 (by
      rw [outputCap_range.2]
      simpa only [fp.2, Nat.cast_one, one_mul, zpow_ofNat] using bound)
    exact ⟨⟨hm.2.2, hm.2.1, domain, quotient, cast.1⟩, cast.2.trans_eq outputCap_range.2⟩
  exact ⟨⟨fun i => (hq i).1, fun t i => (hk t i).1, fun t i => (hv t i).1,
    loops.scores, loops.loops, merge, fun i => (norm i).1⟩, fun i => (norm i).2⟩

end Inference.Kernels.Attention.SdpaInitialRanges
