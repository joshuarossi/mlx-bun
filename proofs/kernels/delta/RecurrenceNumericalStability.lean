import kernels.delta.RecurrenceStability

namespace Inference.Kernels.Delta.RecurrenceNumericalStability
open Contracts.Mlx Contracts.Mlx.Numerics
open scoped BigOperators

noncomputable def realInputs (input : Recurrence.Inputs Float32) : Recurrence.Inputs ℝ where
  key i := real (input.key i)
  query i := real (input.query i)
  value := real input.value
  decay := real input.decay
  beta := real input.beta

noncomputable def zeroErrors : Recurrence.Inputs ℝ where
  key _ := 0
  query _ := 0
  value := 0
  decay := 0
  beta := 0

theorem exact_inputs (input : Recurrence.Inputs Float32) :
    Recurrence.InputError input (realInputs input) zeroErrors := by
  constructor <;> simp [realInputs, zeroErrors]

-- This budget isolates arithmetic introduced by this step. The real
-- recurrence here consumes the actual rounded inputs; upstream input errors
-- remain a separate obligation of the whole-layer accuracy theorem.
noncomputable def localBudget (tree : Reduction.Tree 32) (flags : Gated.Contraction)
    (state : Fin 128 → Float32) (input : Recurrence.Inputs Float32) : Fin 128 → ℝ :=
  Recurrence.stepBudget tree flags state input (fun i => real (state i)) (fun _ => 0)
    (realInputs input) zeroErrors

theorem local_error (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (flags : Gated.Contraction) (state : Fin 128 → Float32) (input : Recurrence.Inputs Float32)
    (i : Fin 128) (hf : Arithmetic.Finite (Recurrence.bind state input) (Gated.stateExpr flags platform.tree i)) :
    |real (Recurrence.step reduce flags state input i)-
      Recurrence.targetStep (fun j => real (state j)) (realInputs input) i| ≤
        localBudget platform.tree flags state input i :=
  Recurrence.step_error reduce platform flags state input _ _ _ _ (by intro j; simp)
    (exact_inputs input) i hf

theorem local_magnitude (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (flags : Gated.Contraction) (state : Fin 128 → Float32) (input : Recurrence.Inputs Float32)
    (hf : ∀ i, Arithmetic.Finite (Recurrence.bind state input) (Gated.stateExpr flags platform.tree i)) :
    RecurrenceStability.magnitude (fun i => real (Recurrence.step reduce flags state input i)-
      Recurrence.targetStep (fun j => real (state j)) (realInputs input) i) ≤
        RecurrenceStability.magnitude (localBudget platform.tree flags state input) :=
  RecurrenceStability.pointwise_bound _ _ (fun i => local_error reduce platform flags state input i (hf i))

noncomputable def defect (reduce : (Fin 32 → Float32) → Float32) (tree : Reduction.Tree 32)
    (flags : Gated.Contraction) (inputs : Nat → Recurrence.Inputs Float32) (initial : Fin 128 → Float32) (t : Nat) : ℝ :=
  RecurrenceStability.magnitude (localBudget tree flags (Recurrence.run reduce flags inputs initial t) (inputs t))

theorem run_error (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (flags : Gated.Contraction) (inputs : Nat → Recurrence.Inputs Float32) (initial : Fin 128 → Float32)
    (targetInitial : Fin 128 → ℝ) (steps : Nat)
    (hd : ∀ t, t < steps → |real (inputs t).decay| ≤ 1)
    (hb : ∀ t, t < steps → 0 ≤ real (inputs t).beta)
    (hk : ∀ t, t < steps → real (inputs t).beta*RecurrenceStability.energy (fun i => real ((inputs t).key i)) ≤ 2)
    (hf : ∀ t, t < steps → ∀ i,
      Arithmetic.Finite (Recurrence.bind (Recurrence.run reduce flags inputs initial t) (inputs t))
        (Gated.stateExpr flags platform.tree i)) :
    RecurrenceStability.magnitude (fun i => real (Recurrence.run reduce flags inputs initial steps i)-
      Recurrence.targetRun (fun t => realInputs (inputs t)) targetInitial steps i) ≤
        RecurrenceStability.magnitude (fun i => real (initial i)-targetInitial i)+
          ∑ t ∈ Finset.range steps, defect reduce platform.tree flags inputs initial t := by
  exact RecurrenceStability.error_accumulation (fun t => realInputs (inputs t))
    (fun t i => real (Recurrence.run reduce flags inputs initial t i)) targetInitial _ steps hd hb hk
    (fun t ht => local_magnitude reduce platform flags _ (inputs t) (hf t ht))

theorem step_growth (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (flags : Gated.Contraction) (state : Fin 128 → Float32) (input : Recurrence.Inputs Float32)
    (hd : |real input.decay| ≤ 1) (hb : 0 ≤ real input.beta)
    (hk : real input.beta*RecurrenceStability.energy (fun i => real (input.key i)) ≤ 2)
    (hf : ∀ i, Arithmetic.Finite (Recurrence.bind state input) (Gated.stateExpr flags platform.tree i)) :
    RecurrenceStability.magnitude (fun i => real (Recurrence.step reduce flags state input i)) ≤
      RecurrenceStability.magnitude (fun i => real (state i))+
        |real input.beta*real input.value| * RecurrenceStability.magnitude (fun i => real (input.key i))+
          RecurrenceStability.magnitude (localBudget platform.tree flags state input) := by
  have numerical := local_magnitude reduce platform flags state input hf
  have ideal := RecurrenceStability.target_step_growth (fun i => real (state i)) (realInputs input) hd hb hk
  have triangle := RecurrenceStability.triangle
    (fun i => real (Recurrence.step reduce flags state input i)-
      Recurrence.targetStep (fun j => real (state j)) (realInputs input) i)
    (Recurrence.targetStep (fun j => real (state j)) (realInputs input))
  simp only [sub_add_cancel] at triangle
  have combined := triangle.trans (add_le_add numerical ideal)
  dsimp only [realInputs] at combined
  linarith only [combined]

theorem run_growth (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (flags : Gated.Contraction) (inputs : Nat → Recurrence.Inputs Float32) (initial : Fin 128 → Float32)
    (steps : Nat)
    (hd : ∀ t, t < steps → |real (inputs t).decay| ≤ 1)
    (hb : ∀ t, t < steps → 0 ≤ real (inputs t).beta)
    (hk : ∀ t, t < steps → real (inputs t).beta*RecurrenceStability.energy (fun i => real ((inputs t).key i)) ≤ 2)
    (hf : ∀ t, t < steps → ∀ i,
      Arithmetic.Finite (Recurrence.bind (Recurrence.run reduce flags inputs initial t) (inputs t))
        (Gated.stateExpr flags platform.tree i)) :
    RecurrenceStability.magnitude (fun i => real (Recurrence.run reduce flags inputs initial steps i)) ≤
      RecurrenceStability.magnitude (fun i => real (initial i))+
        ∑ t ∈ Finset.range steps, (|real (inputs t).beta*real (inputs t).value| *
          RecurrenceStability.magnitude (fun i => real ((inputs t).key i))+
            defect reduce platform.tree flags inputs initial t) := by
  induction steps with
  | zero => simp only [Recurrence.run, Finset.range_zero, Finset.sum_empty, add_zero, le_refl]
  | succ t ih =>
    have previous := ih (fun j hj => hd j (by omega)) (fun j hj => hb j (by omega))
      (fun j hj => hk j (by omega)) (fun j hj => hf j (by omega))
    have hs := step_growth reduce platform flags (Recurrence.run reduce flags inputs initial t) (inputs t)
      (hd t (by omega)) (hb t (by omega)) (hk t (by omega)) (hf t (by omega))
    change _ ≤ _ + _ + defect reduce platform.tree flags inputs initial t at hs
    simp only [Recurrence.run, Finset.sum_range_succ]
    linarith only [previous, hs]

end Inference.Kernels.Delta.RecurrenceNumericalStability
