import models.qwen.DeltaOutputRanges
import kernels.NormalizationEpsilonRanges
namespace Inference.Models.Qwen.DeltaOutputEpsilonRanges
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Delta DeltaNet DeltaOutputRanges
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := DeltaNet.BF
private theorem bf (e : Int) (lo : -133 ≤ e) (hi : e ≤ 119) :
    Model.isFinite (BFloat16DyadicBounds.ceiling 1 e) = true ∧ Model.toReal (BFloat16DyadicBounds.ceiling 1 e) = (2 : ℝ)^e := by
  simpa only [Nat.cast_one, one_mul] using BFloat16DyadicBounds.ceiling_range 1 e (by decide) lo hi
private theorem fp (e : Int) (lo : -149 ≤ e) (hi : e ≤ 100) :
    (DyadicBounds.ceiling 1 e).isFinite = true ∧ real (DyadicBounds.ceiling 1 e) = (2 : ℝ)^e := by
  simpa only [Nat.cast_one, one_mul] using DyadicBounds.ceiling_range 1 e (by decide) lo hi

theorem gated_wide (layer : Layer) (cache : Cache) (input : Nat → Fin 5120 → BF) (time : Nat)
    (parameters : DeltaHeadRanges.Parameters layer)
    (weight : ∀ i, Model.isFinite (layer.normWeight i) = true ∧ |Model.toReal (layer.normWeight i)| ≤ 2)
    (projection : DeltaInputRanges.ProjectionRanges layer input)
    (recurrence : RecurrentFinite layer cache input time)
    (recurrentBound : ∀ h v, |Model.toReal (recurrentOutput layer cache input time h v)| ≤ (2 : ℝ)^(56 : Nat))
    (division : DivisionDirectedBounds.Contract layer.gated.divide) (root : RsqrtEpsilonBounds.Envelope layer.gated.rsqrt Blocks.eps 2)
    (exponential : Kernels.StableSigmoidRanges.ExponentialRange layer.gated.expAbs) :
    GatedFinite layer cache input time ∧ ∀ i, Model.isFinite (merged layer cache input time i) = true ∧
      |Model.toReal (merged layer cache input time i)| ≤ (2 : ℝ)^(30 : Nat) := by
  have h head := Kernels.NormalizationEpsilonRanges.Gated.ranges_wide layer.gated normProfile tailProfile (le_refl _)
    division root exponential (recurrentOutput layer cache input time head) (zHead layer input time head) layer.normWeight
    (fun i => ⟨recurrence.cast head i, recurrentBound head i⟩)
    (fun i => by norm_num only [normProfile, (bf 1 (by decide) (by decide)).2, zpow_ofNat]; exact weight i)
    (fun i => ⟨layer.z.forward_finite _ (projection.finite.z time) _, by
      simpa only [zHead, tailProfile, (fp 23 (by decide) (by decide)).2, zpow_ofNat] using projection.z time (channel head i)⟩)
  have hg : GatedFinite layer cache input time := by
    constructor
    · intro head
      rw [parameters.width, parameters.eps]
      exact (h head).1
    · intro head i
      rw [parameters.width, parameters.eps]
      exact ((h head).2 i).1
  refine ⟨hg, fun i => ⟨merged_finite layer cache input time hg i, ?_⟩⟩
  unfold merged gatedOutput
  rw [parameters.width, parameters.eps]
  simpa only [normProfile, tailProfile, (bf 30 (by decide) (by decide)).2, zpow_ofNat] using
    ((h (headOf i)).2 (valueOf i)).2.2

end Inference.Models.Qwen.DeltaOutputEpsilonRanges
