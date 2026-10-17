import models.qwen.DeltaHeadRanges
import kernels.delta.SiluRmsHeadsEnergy
import kernels.delta.RecurrenceStability

namespace Inference.Models.Qwen.DeltaHeadEnergy
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Delta DeltaNet
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators

-- The sharper key scale is an input parameter obligation, to be bound to
-- the graph's constructed BF16 vector. Hardware premises stay scalar.
structure Parameters (layer : Layer) : Prop extends DeltaHeadRanges.Parameters layer where
  keyScale : ∀ i, |Model.toReal (layer.headParams.kScale i)| ≤ (23/256 : ℝ)

structure Ranges (layer : Layer) (cache : Cache) (input : Nat → Fin 5120 → BF) (t : Nat) : Prop where
  coarse : DeltaHeadRanges.Ranges layer cache input t
  query : ∀ h, RecurrenceStability.energy (fun i => Model.toReal
    ((State.Ssm.heads layer.recurrence layer.headParams (convData layer cache input) t).q 0 h i)) ≤ 1/64
  key : ∀ h, RecurrenceStability.energy (fun i => Model.toReal
    ((State.Ssm.heads layer.recurrence layer.headParams (convData layer cache input) t).k 0 h i)) ≤ 2

theorem from_convolution (layer : Layer) (parameters : Parameters layer)
    (exponential : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.recurrence.heads.expAbs)
    (division : DivisionDirectedBounds.Contract layer.recurrence.heads.divide)
    (root : RsqrtRelativeBounds.Envelope layer.recurrence.heads.rsqrt (17/16))
    (native : ∀ x, x.isFinite = true → layer.recurrence.heads.divide x (Float32.ofInt 128) =
      FlushToZero.div x (Float32.ofInt 128))
    (cache : Cache) (input : Nat → Fin 5120 → BF) (t : Nat)
    (conv : ∀ c, Model.isFinite (State.Ssm.convolved layer.recurrence (convData layer cache input) t c) = true ∧
      |Model.toReal (State.Ssm.convolved layer.recurrence (convData layer cache input) t c)| ≤ (2 : ℝ)^(36 : Nat)) :
    Ranges layer cache input t := by
  have coarse := DeltaHeadRanges.from_convolution layer parameters.toParameters exponential division
    (RsqrtRelativeBounds.weaken _ _ root (by norm_num)) cache input t conv
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
    have hn := SiluRmsHeadsEnergy.normalized_energy p (Layers.DeltaHeads.slice x 0 (Layers.DeltaHeads.qHead head))
      layer.headParams.qScale layer.headParams.width layer.headParams.eps (1/128) hf
      (activated (Layers.DeltaHeads.qHead head)) parameters.qScale (by norm_num) epsLower (by
        rw [parameters.width]
        apply native
        exact SquaredSum.finite_evaluate _ _ hf.hSum) root
    exact hn.2.trans (by norm_num)
  · intro head
    have hf := (coarse.finite.kNorm 0 head).toReductionFinite
    have hn := SiluRmsHeadsEnergy.normalized_energy p (Layers.DeltaHeads.slice x 0 (Layers.DeltaHeads.kHead head))
      layer.headParams.kScale layer.headParams.width layer.headParams.eps (23/256) hf
      (activated (Layers.DeltaHeads.kHead head))
      (fun i => ⟨(parameters.kScale i).1, parameters.keyScale i⟩) (by norm_num) epsLower (by
        rw [parameters.width]
        apply native
        exact SquaredSum.finite_evaluate _ _ hf.hSum) root
    exact hn.2.trans (by norm_num)

theorem query_magnitude (layer : Layer) (cache : Cache) (input : Nat → Fin 5120 → BF) (t : Nat)
    (h : Ranges layer cache input t) (head : Fin 16) :
    RecurrenceStability.magnitude (fun i => Model.toReal
      ((State.Ssm.heads layer.recurrence layer.headParams (convData layer cache input) t).q 0 head i)) ≤ 1/8 := by
  have bound := h.query head
  have squared := RecurrenceStability.magnitude_square (fun i => Model.toReal
    ((State.Ssm.heads layer.recurrence layer.headParams (convData layer cache input) t).q 0 head i))
  nlinarith only [bound, squared]

theorem key_stable (layer : Layer) (cache : Cache) (input : Nat → Fin 5120 → BF) (t : Nat)
    (h : Ranges layer cache input t) (head : Fin 16) (beta : ℝ) (upper : beta ≤ 1) :
    beta*RecurrenceStability.energy (fun i => Model.toReal
      ((State.Ssm.heads layer.recurrence layer.headParams (convData layer cache input) t).k 0 head i)) ≤ 2 := by
  exact (mul_le_mul_of_nonneg_right upper (RecurrenceStability.energy_nonnegative _)).trans
    (by simpa only [one_mul] using h.key head)

end Inference.Models.Qwen.DeltaHeadEnergy
