import models.qwen.DeltaHeadEnergy
import models.qwen.DeltaGateRanges
import kernels.delta.GatedRecurrentRanges
import kernels.delta.RecurrenceNumericalStability

namespace Inference.Models.Qwen.DeltaRecurrentInputs
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Delta DeltaNet
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators

private theorem coordinate_le_magnitude (x : Fin n → ℝ) (i : Fin n) :
    |x i| ≤ RecurrenceStability.magnitude x := by
  apply (sq_le_sq₀ (abs_nonneg _) (RecurrenceStability.magnitude_nonnegative _)).mp
  rw [sq_abs, RecurrenceStability.magnitude_square]
  exact Finset.single_le_sum (fun j _ => sq_nonneg (x j)) (Finset.mem_univ i)

structure Ranges (input : Recurrence.Inputs Float32) : Prop where
  key : ∀ i, (input.key i).isFinite = true ∧ |real (input.key i)| ≤ 2
  query : ∀ i, (input.query i).isFinite = true ∧ |real (input.query i)| ≤ 1/8
  value : input.value.isFinite = true ∧ |real input.value| ≤ (2 : ℝ)^(36 : Nat)
  decay : input.decay.isFinite = true ∧ 0 ≤ real input.decay ∧ real input.decay ≤ 1
  beta : input.beta.isFinite = true ∧ 0 ≤ real input.beta ∧ real input.beta ≤ 1
  keyEnergy : RecurrenceStability.energy (fun i => real (input.key i)) ≤ 2
  queryMagnitude : RecurrenceStability.magnitude (fun i => real (input.query i)) ≤ 1/8

theorem from_heads (layer : Layer) (cache : Cache) (input : Nat → Fin 5120 → BF) (t : Nat)
    (heads : DeltaHeadEnergy.Ranges layer cache input t) (gates : DeltaGateRanges.Ranges layer input t)
    (head : Fin 48) (value : Fin 128) : Ranges (inputs layer cache input head value t) := by
  let current := inputs layer cache input head value t
  have hf := State.Ssm.projected_finite layer.recurrence layer.headParams (convData layer cache input)
    (DeltaNet.gates layer input) t heads.coarse.finite gates.finite head value
  have keyValue (i : Fin 128) : real (current.key i) = Model.toReal
      ((State.Ssm.heads layer.recurrence layer.headParams (convData layer cache input) t).k 0 (Layout.keyHead head) i) :=
    BFloat16.widen_real _ (hf.key i)
  have queryValue (i : Fin 128) : real (current.query i) = Model.toReal
      ((State.Ssm.heads layer.recurrence layer.headParams (convData layer cache input) t).q 0 (Layout.keyHead head) i) :=
    BFloat16.widen_real _ (hf.query i)
  have keyEnergy : RecurrenceStability.energy (fun i => real (current.key i)) ≤ 2 := by
    simpa only [RecurrenceStability.energy, keyValue] using heads.key (Layout.keyHead head)
  have queryMagnitude : RecurrenceStability.magnitude (fun i => real (current.query i)) ≤ 1/8 := by
    simpa only [RecurrenceStability.magnitude, RecurrenceStability.energy, queryValue] using
      DeltaHeadEnergy.query_magnitude layer cache input t heads (Layout.keyHead head)
  refine ⟨?_, ?_, ?_, ?_, ?_, keyEnergy, queryMagnitude⟩
  · intro i
    refine ⟨BFloat16.widen_finite _ (hf.key i), ?_⟩
    have hc := coordinate_le_magnitude (fun j => real (current.key j)) i
    have hs := RecurrenceStability.magnitude_square (fun j => real (current.key j))
    change |real (current.key i)| ≤ 2
    nlinarith only [hc, hs, keyEnergy, abs_nonneg (real (current.key i))]
  · intro i
    exact ⟨BFloat16.widen_finite _ (hf.query i),
      (coordinate_le_magnitude (fun j => real (current.query j)) i).trans queryMagnitude⟩
  · refine ⟨BFloat16.widen_finite _ hf.value, ?_⟩
    change |real (BFloat16.widen _)| ≤ _
    rw [BFloat16.widen_real _ hf.value]
    exact heads.coarse.value head value
  · exact ⟨hf.decay.outputFinite, gates.decay head⟩
  · have hb := Gates.beta_finite layer.recurrence.gates.expAbs layer.recurrence.gates.expAbsError
      layer.recurrence.gates.exponential _ hf.beta
    refine ⟨BFloat16.widen_finite _ hb, ?_⟩
    change 0 ≤ real (BFloat16.widen _) ∧ real (BFloat16.widen _) ≤ 1
    rw [BFloat16.widen_real _ hb]
    exact gates.beta head

theorem stable (input : Recurrence.Inputs Float32) (h : Ranges input) :
    real input.beta*RecurrenceStability.energy (fun i => real (input.key i)) ≤ 2 :=
  (mul_le_mul_of_nonneg_right h.beta.2.2 (RecurrenceStability.energy_nonnegative _)).trans
    (by simpa only [one_mul] using h.keyEnergy)

theorem bound_inputs (state : Fin 128 → Float32) (input : Recurrence.Inputs Float32) (exponent : Int)
    (hs : ∀ i, (state i).isFinite = true ∧ |real (state i)| ≤ (2 : ℝ)^exponent)
    (hi : Ranges input) : GatedRecurrentRanges.Inputs (Recurrence.bind state input) exponent := by
  constructor
  · intro i; simpa only [Recurrence.bind_state] using hs i
  · intro i; simpa only [Recurrence.bind_key] using hi.key i
  · intro i; simpa only [Recurrence.bind_query] using hi.query i
  · simpa only [Recurrence.bind_value] using hi.value
  · simpa only [Recurrence.bind_decay, abs_of_nonneg hi.decay.2.1] using And.intro hi.decay.1 hi.decay.2.2
  · simpa only [Recurrence.bind_beta, abs_of_nonneg hi.beta.2.1] using And.intro hi.beta.1 hi.beta.2.2

theorem step (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (flags : Gated.Contraction) (state : Fin 128 → Float32) (input : Recurrence.Inputs Float32)
    (exponent : Int) (lower : 36 ≤ exponent) (upper : exponent ≤ 70)
    (hs : ∀ i, (state i).isFinite = true ∧ |real (state i)| ≤ (2 : ℝ)^exponent)
    (hi : Ranges input) :
    (∀ i, (Recurrence.step reduce flags state input i).isFinite = true) ∧
      RecurrenceStability.magnitude (fun i => real (Recurrence.step reduce flags state input i)) ≤
        RecurrenceStability.magnitude (fun i => real (state i))+
          |real input.beta*real input.value| * RecurrenceStability.magnitude (fun i => real (input.key i))+
            RecurrenceStability.magnitude (RecurrenceNumericalStability.localBudget platform.tree flags state input) := by
  have hr := GatedRecurrentRanges.ranges (Recurrence.bind state input) flags platform.tree platform.coverage
    exponent lower upper (bound_inputs state input exponent hs hi)
  refine ⟨?_, RecurrenceNumericalStability.step_growth reduce platform flags state input
    (by rw [abs_of_nonneg hi.decay.2.1]; exact hi.decay.2.2) hi.beta.2.1 (stable input hi) (fun i => (hr.1 i).1)⟩
  intro i
  have hf := Arithmetic.finite_evaluate _ _ (hr.1 i).1
  rwa [Gated.state_execution _ reduce platform flags i] at hf

end Inference.Models.Qwen.DeltaRecurrentInputs
