import models.qwen.DeltaHeadRanges
import models.qwen.DeltaGateRanges
import kernels.delta.GatedRanges

namespace Inference.Models.Qwen.DeltaInitialRecurrenceRanges
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Delta DeltaNet
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

theorem bound_inputs (layer : Layer) (cache : Cache) (input : Nat → Fin 5120 → BF)
    (heads : DeltaHeadRanges.Ranges layer cache input 0) (gates : DeltaGateRanges.Ranges layer input 0)
    (state : ∀ h v i, (cache.recurrent h v i).isFinite = true ∧ |real (cache.recurrent h v i)| ≤ 1)
    (head : Fin 48) (value : Fin 128) :
    GatedRanges.InitialInputs (Recurrence.bind (cache.recurrent head value) (inputs layer cache input head value 0)) := by
  have hf := State.Ssm.projected_finite layer.recurrence layer.headParams (convData layer cache input)
    (DeltaNet.gates layer input) 0 heads.finite gates.finite head value
  constructor
  · intro i
    rw [Recurrence.bind_state]
    exact state head value i
  · intro i
    rw [Recurrence.bind_key]
    change (BFloat16.widen _).isFinite = true ∧ |real (BFloat16.widen _)| ≤ 8
    refine ⟨BFloat16.widen_finite _ (hf.key i), ?_⟩
    rw [BFloat16.widen_real _ (hf.key i)]
    exact heads.key _ i
  · intro i
    rw [Recurrence.bind_query]
    change (BFloat16.widen _).isFinite = true ∧ |real (BFloat16.widen _)| ≤ 1/2
    refine ⟨BFloat16.widen_finite _ (hf.query i), ?_⟩
    rw [BFloat16.widen_real _ (hf.query i)]
    exact heads.query _ i
  · rw [Recurrence.bind_value]
    change (BFloat16.widen _).isFinite = true ∧ |real (BFloat16.widen _)| ≤ (2 : ℝ)^(36 : Nat)
    refine ⟨BFloat16.widen_finite _ hf.value, ?_⟩
    rw [BFloat16.widen_real _ hf.value]
    exact heads.value head value
  · rw [Recurrence.bind_decay]
    refine ⟨hf.decay.outputFinite, ?_⟩
    change |real (Decay.value layer.recurrence.gates.decay (BFloat16.widen (layer.aLog head))
      (layer.a.forward (input 0) head) (layer.dtBias head))| ≤ 1
    rw [abs_of_nonneg (gates.decay head).1]
    exact (gates.decay head).2
  · rw [Recurrence.bind_beta]
    have hb := Gates.beta_finite layer.recurrence.gates.expAbs layer.recurrence.gates.expAbsError
      layer.recurrence.gates.exponential _ hf.beta
    change (BFloat16.widen _).isFinite = true ∧ |real (BFloat16.widen _)| ≤ 1
    refine ⟨BFloat16.widen_finite _ hb, ?_⟩
    rw [BFloat16.widen_real _ hb]
    change |Model.toReal (Kernels.Trellis.GateUpSplitTail.sigmoidValue layer.recurrence.gates.expAbs
      (layer.b.forward (input 0) head))| ≤ 1
    rw [abs_of_nonneg (gates.beta head).1]
    exact (gates.beta head).2

theorem ranges (layer : Layer) (cache : Cache) (input : Nat → Fin 5120 → BF)
    (heads : DeltaHeadRanges.Ranges layer cache input 0) (gates : DeltaGateRanges.Ranges layer input 0)
    (state : ∀ h v i, (cache.recurrent h v i).isFinite = true ∧ |real (cache.recurrent h v i)| ≤ 1) :
    RecurrentFinite layer cache input 0 ∧
      (∀ h v, |Model.toReal (recurrentOutput layer cache input 0 h v)| ≤ (2 : ℝ)^(47 : Nat)) ∧
      (∀ h v i, ((DeltaCache.after layer cache input 1).recurrent h v i).isFinite = true ∧
        |real ((DeltaCache.after layer cache input 1).recurrent h v i)| ≤ (2 : ℝ)^(41 : Nat)) := by
  have hi h v := bound_inputs layer cache input heads gates state h v
  have hr h v := GatedRanges.initial_ranges _ layer.recurrence.flags layer.recurrence.reduction.tree
    layer.recurrence.reduction.coverage (hi h v)
  have hv h v := GatedRanges.initial_value _ layer.recurrence.flags layer.recurrence.reduce layer.recurrence.reduction (hi h v)
  refine ⟨?_, fun h v => (hv h v).2, ?_⟩
  · refine ⟨?_, ?_, ?_, fun h v => (hr h v).2.1, fun h v => (hv h v).1⟩
    · intro t ht
      have : t = 0 := by omega
      subst t
      exact heads.finite
    · intro t ht
      have : t = 0 := by omega
      subst t
      exact gates.finite
    · intro _ _ t ht
      omega
  · intro h v i
    have hf := Arithmetic.finite_evaluate _ _ ((hr h v).1 i).1
    have hb := ((hr h v).1 i).2
    rw [Gated.state_execution _ layer.recurrence.reduce layer.recurrence.reduction layer.recurrence.flags i] at hf hb
    exact ⟨hf, hb⟩

theorem from_projections (layer : Layer) (headParameters : DeltaHeadRanges.Parameters layer)
    (gateParameters : DeltaGateRanges.Parameters layer)
    (headExp : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.recurrence.heads.expAbs)
    (division : DivisionDirectedBounds.Contract layer.recurrence.heads.divide)
    (root : RsqrtBounds.Envelope layer.recurrence.heads.rsqrt)
    (decay : DecayRanges.PrimitiveRanges layer.recurrence.gates.decay DeltaGateRanges.profile)
    (beta : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.recurrence.gates.expAbs)
    (cache : Cache) (input : Nat → Fin 5120 → BF) (projection : DeltaInputRanges.ProjectionRanges layer input)
    (history : ∀ i c, Model.isFinite (cache.history i c) = true ∧ |Model.toReal (cache.history i c)| ≤ (2 : ℝ)^(34 : Nat))
    (weight : ∀ c i, Model.isFinite (layer.convolutionWeight c i) = true ∧ |Model.toReal (layer.convolutionWeight c i)| ≤ 1)
    (state : ∀ h v i, (cache.recurrent h v i).isFinite = true ∧ |real (cache.recurrent h v i)| ≤ 1) :
    RecurrentFinite layer cache input 0 ∧
      (∀ h v, |Model.toReal (recurrentOutput layer cache input 0 h v)| ≤ (2 : ℝ)^(47 : Nat)) ∧
      (∀ h v i, ((DeltaCache.after layer cache input 1).recurrent h v i).isFinite = true ∧
        |real ((DeltaCache.after layer cache input 1).recurrent h v i)| ≤ (2 : ℝ)^(41 : Nat)) :=
  ranges layer cache input (DeltaHeadRanges.ranges layer headParameters headExp division root cache input projection history weight 0)
    (DeltaGateRanges.ranges layer gateParameters decay beta input projection 0) state

end Inference.Models.Qwen.DeltaInitialRecurrenceRanges
