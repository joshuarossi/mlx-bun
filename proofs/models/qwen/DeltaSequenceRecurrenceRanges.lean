import models.qwen.DeltaRecurrentInputs
import kernels.delta.RecurrenceReadoutRanges
import kernels.delta.RecurrenceSupportedError

namespace Inference.Models.Qwen.DeltaSequenceRecurrenceRanges
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Delta DeltaNet
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

theorem kernel_inputs (input : Recurrence.Inputs Float32) (h : DeltaRecurrentInputs.Ranges input) :
    RecurrenceSupportedRanges.Inputs input where
  key := h.key
  query := h.query
  value := h.value
  decay := ⟨h.decay.1, by rw [abs_of_nonneg h.decay.2.1]; exact h.decay.2.2⟩
  beta := h.beta
  keyEnergy := h.keyEnergy

structure Result (layer : Layer) (cache : Cache) (input : Nat → Fin 5120 → BF) (time : Nat) : Prop where
  finite : RecurrentFinite layer cache input time
  output : ∀ h v, |Model.toReal (recurrentOutput layer cache input time h v)| ≤ (2 : ℝ)^(56 : Nat)
  state : ∀ t, t ≤ time+1 → ∀ h v,
    (∀ i, ((DeltaCache.after layer cache input t).recurrent h v i).isFinite = true) ∧
      RecurrenceStability.magnitude (fun i => real ((DeltaCache.after layer cache input t).recurrent h v i)) ≤
        9*(2 : ℝ)^(55 : Nat)

theorem ranges (layer : Layer) (cache : Cache) (input : Nat → Fin 5120 → BF) (time : Nat)
    (bound : time+1 ≤ 262144)
    (heads : ∀ t, t ≤ time → DeltaHeadEnergy.Ranges layer cache input t)
    (gates : ∀ t, t ≤ time → DeltaGateRanges.Ranges layer input t)
    (stateFinite : ∀ h v i, (cache.recurrent h v i).isFinite = true)
    (stateZero : ∀ h v, RecurrenceStability.magnitude (fun i => real (cache.recurrent h v i)) = 0) :
    Result layer cache input time := by
  have data (h : Fin 48) (v : Fin 128) (t : Nat) (ht : t ≤ time) :=
    DeltaRecurrentInputs.from_heads layer cache input t (heads t ht) (gates t ht) h v
  have run (h : Fin 48) (v : Fin 128) := RecurrenceSupportedRanges.run_uniform
    layer.recurrence.reduce layer.recurrence.reduction layer.recurrence.flags
    (inputs layer cache input h v) (cache.recurrent h v) (stateFinite h v) (stateZero h v)
    (time+1) bound (fun t ht => kernel_inputs _ (data h v t (by omega)))
  have instructions (h : Fin 48) (v : Fin 128) (t : Nat) (ht : t ≤ time) :=
    GatedRecurrentRanges.ranges
      (Recurrence.bind (Recurrence.run layer.recurrence.reduce layer.recurrence.flags
        (inputs layer cache input h v) (cache.recurrent h v) t) (inputs layer cache input h v t))
      layer.recurrence.flags layer.recurrence.reduction.tree layer.recurrence.reduction.coverage 59
      (by decide) (by decide) (RecurrenceSupportedRanges.bound_inputs _ _
        (run h v t (by omega)).1 ((run h v t (by omega)).2.trans (by norm_num)) (kernel_inputs _ (data h v t ht)))
  have output (h : Fin 48) (v : Fin 128) := RecurrenceReadoutRanges.value
    layer.recurrence.reduce layer.recurrence.reduction layer.recurrence.flags
    (Recurrence.run layer.recurrence.reduce layer.recurrence.flags
      (inputs layer cache input h v) (cache.recurrent h v) time) (inputs layer cache input h v time)
    (run h v time (by omega)).1 ((run h v time (by omega)).2.trans (by norm_num))
    (kernel_inputs _ (data h v time (le_refl _))) (run h v (time+1) (le_refl _)).2
    (data h v time (le_refl _)).queryMagnitude
  refine ⟨?_, fun h v => (output h v).2.2, fun t ht h v => run h v t ht⟩
  refine ⟨fun t ht => (heads t ht).coarse.finite, fun t ht => (gates t ht).finite,
    ?_, fun h v => (output h v).1, fun h v => (output h v).2.1⟩
  intro h v t ht i
  exact ((instructions h v t (by omega)).1 i).1

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
    (stateZero : ∀ h v, RecurrenceStability.magnitude (fun i => real (cache.recurrent h v i)) = 0)
    (time : Nat) (bound : time+1 ≤ 262144) : Result layer cache input time := by
  have conv := DeltaInputRanges.convolution layer cache input projection history weight
  exact ranges layer cache input time bound
    (fun t _ => DeltaHeadEnergy.from_convolution layer headParameters headExp division root native cache input t
      (fun c => ⟨conv.1.cast t c, conv.2 t c⟩))
    (fun t _ => DeltaGateRanges.ranges layer gateParameters decay beta input projection t) stateFinite stateZero

end Inference.Models.Qwen.DeltaSequenceRecurrenceRanges
