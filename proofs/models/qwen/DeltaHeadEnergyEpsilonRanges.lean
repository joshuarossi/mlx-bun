import models.qwen.DeltaHeadEnergy
import models.qwen.DeltaHeadEpsilonRanges
namespace Inference.Models.Qwen.DeltaHeadEnergyEpsilonRanges
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Delta DeltaNet DeltaHeadEnergy
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators
theorem from_convolution (layer : Layer) (parameters : Parameters layer)
    (exponential : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.recurrence.heads.expAbs)
    (division : DivisionDirectedBounds.Contract layer.recurrence.heads.divide)
    (root : RsqrtEpsilonBounds.Envelope layer.recurrence.heads.rsqrt Blocks.eps (17/16))
    (native : ∀ x, x.isFinite = true → layer.recurrence.heads.divide x (Float32.ofInt 128) =
      FlushToZero.div x (Float32.ofInt 128))
    (cache : Cache) (input : Nat → Fin 5120 → BF) (t : Nat)
    (conv : ∀ c, Model.isFinite (State.Ssm.convolved layer.recurrence (convData layer cache input) t c) = true ∧
      |Model.toReal (State.Ssm.convolved layer.recurrence (convData layer cache input) t c)| ≤ (2 : ℝ)^(36 : Nat)) :
    Ranges layer cache input t := by
  have coarse := DeltaHeadEpsilonRanges.from_convolution layer parameters.toParameters exponential division
    (⟨root.finite,fun x hx lower => (root.bound x hx lower).trans (by norm_num)⟩) cache input t conv
  have tight : RsqrtEpsilonBounds.Envelope layer.recurrence.heads.rsqrt layer.headParams.eps (17/16) := by
    rw [parameters.eps]
    exact root
  let p := layer.recurrence.heads
  let x : Fin 1 → Fin 10240 → BF := fun _ => State.Ssm.convolved layer.recurrence (convData layer cache input) t
  have activated (head : Fin 80) (i : Fin 128) :
      (SiluRmsHeads.activated p (Layers.DeltaHeads.slice x 0 head) i).isFinite = true ∧
        |real (SiluRmsHeads.activated p (Layers.DeltaHeads.slice x 0 head) i)| ≤ (2 : ℝ)^(50 : Nat) := by
    have ha := SiluRmsHeadsRanges.activation p exponential (Layers.DeltaHeads.slice x 0 head i)
      DeltaInputRanges.convolutionCap (conv _).1 DeltaInputRanges.convolutionProfile.storeFinite
      (by rw [DeltaInputRanges.convolutionCap_real]; exact (conv _).2)
    refine ⟨BFloat16.widen_finite _ ha.2.1, ?_⟩
    rw [SiluRmsHeads.activated, BFloat16.widen_real _ ha.2.1]
    exact ha.2.2.trans (by rw [DeltaInputRanges.convolutionCap_real]; norm_num)
  have epsLower : (2 : ℝ)^(-21 : Int) ≤ real layer.headParams.eps := by
    rw [parameters.eps, Blocks.eps_value]
    norm_num
  refine ⟨coarse, ?_, ?_⟩
  · intro head
    have hf := (coarse.finite.qNorm 0 head).toReductionFinite
    have hn := Kernels.NormalizationEpsilonRanges.Energy.normalized_energy p (Layers.DeltaHeads.slice x 0 (Layers.DeltaHeads.qHead head))
      layer.headParams.qScale layer.headParams.width layer.headParams.eps (1/128) hf
      (activated (Layers.DeltaHeads.qHead head)) parameters.qScale (by norm_num) epsLower (by
        rw [parameters.width]
        apply native
        exact SquaredSum.finite_evaluate _ _ hf.hSum) tight
    exact hn.2.trans (by norm_num)
  · intro head
    have hf := (coarse.finite.kNorm 0 head).toReductionFinite
    have hn := Kernels.NormalizationEpsilonRanges.Energy.normalized_energy p (Layers.DeltaHeads.slice x 0 (Layers.DeltaHeads.kHead head))
      layer.headParams.kScale layer.headParams.width layer.headParams.eps (23/256) hf
      (activated (Layers.DeltaHeads.kHead head))
      (fun i => ⟨(parameters.kScale i).1, parameters.keyScale i⟩) (by norm_num) epsLower (by
        rw [parameters.width]
        apply native
        exact SquaredSum.finite_evaluate _ _ hf.hSum) tight
    exact hn.2.trans (by norm_num)

end Inference.Models.Qwen.DeltaHeadEnergyEpsilonRanges
