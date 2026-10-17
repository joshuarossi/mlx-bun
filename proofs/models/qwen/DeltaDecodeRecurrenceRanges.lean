import models.qwen.DeltaSequenceRecurrenceRanges
import kernels.delta.RecurrenceEnvelope

namespace Inference.Models.Qwen.DeltaDecodeRecurrenceRanges
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Delta DeltaNet
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

structure Result (layer : Layer) (cache : Cache) (input : Nat → Fin 5120 → BF) (time : Nat) : Prop where
  finite : RecurrentFinite layer cache input 0
  output : ∀ h v, |Model.toReal (recurrentOutput layer cache input 0 h v)| ≤ (2 : ℝ)^(56 : Nat)
  state : ∀ h v,
    (∀ i, ((DeltaCache.after layer cache input 1).recurrent h v i).isFinite = true) ∧
      RecurrenceStability.magnitude (fun i => real ((DeltaCache.after layer cache input 1).recurrent h v i)) ≤
        RecurrenceEnvelope.bound (time+1)

theorem ranges (layer : Layer) (cache : Cache) (input : Nat → Fin 5120 → BF) (time : Nat)
    (supported : time+1 ≤ 262144)
    (heads : DeltaHeadEnergy.Ranges layer cache input 0) (gates : DeltaGateRanges.Ranges layer input 0)
    (stateFinite : ∀ h v i, (cache.recurrent h v i).isFinite = true)
    (stateBound : ∀ h v, RecurrenceStability.magnitude (fun i => real (cache.recurrent h v i)) ≤ RecurrenceEnvelope.bound time) :
    Result layer cache input time := by
  have data h v := DeltaRecurrentInputs.from_heads layer cache input 0 heads gates h v
  have step h v := RecurrenceEnvelope.step layer.recurrence.reduce layer.recurrence.reduction layer.recurrence.flags
    (cache.recurrent h v) (inputs layer cache input h v 0) time supported (stateFinite h v) (stateBound h v)
    (DeltaSequenceRecurrenceRanges.kernel_inputs _ (data h v))
  have output h v := RecurrenceReadoutRanges.value layer.recurrence.reduce layer.recurrence.reduction layer.recurrence.flags
    (cache.recurrent h v) (inputs layer cache input h v 0) (stateFinite h v)
    ((stateBound h v).trans ((RecurrenceEnvelope.upper time (by omega)).trans (by norm_num)))
    (DeltaSequenceRecurrenceRanges.kernel_inputs _ (data h v))
    ((step h v).2.trans (RecurrenceEnvelope.upper (time+1) supported)) (data h v).queryMagnitude
  refine ⟨?_, fun h v => (output h v).2.2, step⟩
  refine ⟨?_, ?_, ?_, fun h v => (output h v).1, fun h v => (output h v).2.1⟩
  · intro t ht
    have : t = 0 := by omega
    subst t
    exact heads.coarse.finite
  · intro t ht
    have : t = 0 := by omega
    subst t
    exact gates.finite
  · intro _ _ t ht
    omega

theorem from_projections (layer : Layer) (headParameters : DeltaHeadEnergy.Parameters layer)
    (gateParameters : DeltaGateRanges.Parameters layer)
    (headExp : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.recurrence.heads.expAbs)
    (division : DivisionDirectedBounds.Contract layer.recurrence.heads.divide)
    (root : RsqrtRelativeBounds.Envelope layer.recurrence.heads.rsqrt (17/16))
    (native : ∀ x, x.isFinite = true → layer.recurrence.heads.divide x (Float32.ofInt 128) =
      FlushToZero.div x (Float32.ofInt 128))
    (decay : DecayRanges.PrimitiveRanges layer.recurrence.gates.decay DeltaGateRanges.profile)
    (beta : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.recurrence.gates.expAbs)
    (cache : Cache) (input : Nat → Fin 5120 → BF) (projection : DeltaInputRanges.ProjectionRanges layer input)
    (history : ∀ i c, Model.isFinite (cache.history i c) = true ∧ |Model.toReal (cache.history i c)| ≤ (2 : ℝ)^(34 : Nat))
    (weight : ∀ c i, Model.isFinite (layer.convolutionWeight c i) = true ∧ |Model.toReal (layer.convolutionWeight c i)| ≤ 1)
    (stateFinite : ∀ h v i, (cache.recurrent h v i).isFinite = true)
    (stateBound : ∀ h v, RecurrenceStability.magnitude (fun i => real (cache.recurrent h v i)) ≤ RecurrenceEnvelope.bound time)
    (supported : time+1 ≤ 262144) : Result layer cache input time := by
  have conv := DeltaInputRanges.convolution layer cache input projection history weight
  exact ranges layer cache input time supported
    (DeltaHeadEnergy.from_convolution layer headParameters headExp division root native cache input 0
      (fun c => ⟨conv.1.cast 0 c, conv.2 0 c⟩))
    (DeltaGateRanges.ranges layer gateParameters decay beta input projection 0) stateFinite stateBound

end Inference.Models.Qwen.DeltaDecodeRecurrenceRanges
