import models.qwen.DeltaHeadRanges
import models.qwen.DeltaInputRanges
import kernels.NormalizationEpsilonRanges

namespace Inference.Models.Qwen.DeltaHeadEpsilonRanges
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Delta DeltaNet
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

private theorem cap (e : Int) (lo : -133 ≤ e) (hi : e ≤ 119) :
    Model.isFinite (BFloat16DyadicBounds.ceiling 1 e) = true ∧
      Model.toReal (BFloat16DyadicBounds.ceiling 1 e) = (2 : ℝ)^e := by
  simpa only [Nat.cast_one, one_mul] using BFloat16DyadicBounds.ceiling_range 1 e (by decide) lo hi

private def profile (e : Int) (lo : -100 ≤ e) (hi : e ≤ 100) : NormalizationUniform.Profile 128 where
  positive := by decide
  widthLog := 7
  widthLogBound := by decide
  widthBound := by decide
  normalizedExponent := 6
  normalizedPositive := by decide
  normalizedBound := by decide
  rootCapacity := by decide
  eps := Blocks.eps
  epsFinite := Blocks.eps_finite
  epsNormal := Blocks.eps_normal
  epsBound := by rw [Blocks.eps_value]; norm_num
  smallCapacity := by rw [Blocks.eps_value]; norm_num
  weightCap := BFloat16DyadicBounds.ceiling 1 e
  outputCap := BFloat16DyadicBounds.ceiling 1 (e+6)
  outputFinite := (cap (e+6) (by omega) (by omega)).1
  outputCapacity := by
    rw [(cap e (by omega) (by omega)).2, (cap (e+6) (by omega) (by omega)).2,
      zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]
    norm_num

-- The written graph folds 1/128 into Q and an approximation of 1/sqrt(128)
-- into K. These parameter bounds are explicit until construction is bound.
abbrev Parameters := DeltaHeadRanges.Parameters
abbrev Ranges := DeltaHeadRanges.Ranges

theorem from_convolution (layer : Layer) (parameters : Parameters layer)
    (exponential : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.recurrence.heads.expAbs)
    (division : DivisionDirectedBounds.Contract layer.recurrence.heads.divide)
    (root : RsqrtEpsilonBounds.Envelope layer.recurrence.heads.rsqrt Blocks.eps 2)
    (cache : Cache) (input : Nat → Fin 5120 → BF) (t : Nat)
    (conv : ∀ c, Model.isFinite (State.Ssm.convolved layer.recurrence (convData layer cache input) t c) = true ∧
      |Model.toReal (State.Ssm.convolved layer.recurrence (convData layer cache input) t c)| ≤ (2 : ℝ)^(36 : Nat)) :
    Ranges layer cache input t := by
  let p := layer.recurrence.heads
  let x : Fin 1 → Fin 10240 → BF := fun _ => State.Ssm.convolved layer.recurrence (convData layer cache input) t
  have hi (row : Fin 1) (head : Fin 80) (i : Fin 128) :
      Model.isFinite (Layers.DeltaHeads.slice x row head i) = true ∧
        |Model.toReal (Layers.DeltaHeads.slice x row head i)| ≤ (2 : ℝ)^(50 : Nat) := by
    exact ⟨(conv _).1, (conv _).2.trans (by norm_num)⟩
  have ha (row : Fin 1) (head : Fin 80) (i : Fin 128) := SiluRmsHeadsRanges.activation p exponential
    (Layers.DeltaHeads.slice x row head i) DeltaInputRanges.convolutionCap (conv _).1
    DeltaInputRanges.convolutionProfile.storeFinite (by rw [DeltaInputRanges.convolutionCap_real]; exact (conv _).2)
  have hq (row : Fin 1) (head : Fin 16) := Kernels.NormalizationEpsilonRanges.Silu.normalized p (profile (-7) (by decide) (by decide))
    exponential division root (Layers.DeltaHeads.slice x row (Layers.DeltaHeads.qHead head)) layer.headParams.qScale
    (hi row _) (fun i => by
      have h := parameters.qScale i
      norm_num only [profile, (cap (-7) (by decide) (by decide)).2, zpow_neg, zpow_ofNat] at ⊢
      exact h)
  have hk (row : Fin 1) (head : Fin 16) := Kernels.NormalizationEpsilonRanges.Silu.normalized p (profile (-3) (by decide) (by decide))
    exponential division root (Layers.DeltaHeads.slice x row (Layers.DeltaHeads.kHead head)) layer.headParams.kScale
    (hi row _) (fun i => by
      have h := parameters.kScale i
      norm_num only [profile, (cap (-3) (by decide) (by decide)).2, zpow_neg, zpow_ofNat] at ⊢
      exact h)
  refine ⟨?_, ?_, ?_, ?_⟩
  · constructor
    · exact fun row head i => (ha row head i).1
    · intro row head
      rw [parameters.width, parameters.eps]
      exact (hq row head).2.1
    · intro row head
      rw [parameters.width, parameters.eps]
      exact (hk row head).2.1
  · intro head i
    have h := ((hq 0 head).2.2 i).2
    change |Model.toReal (SiluRmsHeads.normalized p _ _ layer.headParams.width layer.headParams.eps i)| ≤ _
    rw [parameters.width, parameters.eps]
    norm_num only [profile, show (-7 : Int)+6 = -1 from by decide,
      (cap (-1) (by decide) (by decide)).2, zpow_neg_one] at h
    exact h
  · intro head i
    have h := ((hk 0 head).2.2 i).2
    change |Model.toReal (SiluRmsHeads.normalized p _ _ layer.headParams.width layer.headParams.eps i)| ≤ _
    rw [parameters.width, parameters.eps]
    norm_num only [profile, show (-3 : Int)+6 = 3 from by decide,
      (cap 3 (by decide) (by decide)).2, zpow_ofNat] at h
    exact h
  · intro head i
    change |Model.toReal (SiluRmsHeads.activate p (Layers.DeltaHeads.slice x 0 (Layers.DeltaHeads.vHead head) i))| ≤ _
    simpa only [DeltaInputRanges.convolutionCap_real] using (ha 0 (Layers.DeltaHeads.vHead head) i).2.2

theorem ranges (layer : Layer) (parameters : Parameters layer)
    (exponential : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.recurrence.heads.expAbs)
    (division : DivisionDirectedBounds.Contract layer.recurrence.heads.divide)
    (root : RsqrtEpsilonBounds.Envelope layer.recurrence.heads.rsqrt Blocks.eps 2)
    (cache : Cache) (input : Nat → Fin 5120 → BF) (projection : DeltaInputRanges.ProjectionRanges layer input)
    (history : ∀ i c, Model.isFinite (cache.history i c) = true ∧ |Model.toReal (cache.history i c)| ≤ (2 : ℝ)^(34 : Nat))
    (weight : ∀ c i, Model.isFinite (layer.convolutionWeight c i) = true ∧ |Model.toReal (layer.convolutionWeight c i)| ≤ 1)
    (t : Nat) : Ranges layer cache input t := by
  have hc := DeltaInputRanges.convolution layer cache input projection history weight
  exact from_convolution layer parameters exponential division root cache input t (fun c => ⟨hc.1.cast t c, hc.2 t c⟩)

end Inference.Models.Qwen.DeltaHeadEpsilonRanges
