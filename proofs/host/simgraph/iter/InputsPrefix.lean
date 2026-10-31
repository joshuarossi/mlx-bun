import host.simgraph.iter.InputsAt

namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Run.Full Host.Mlx Host.Mlx.FfiEval Host.Ts

/-- Input correspondence with an explicit fixed prefix for model parameters. -/
def InputsOkAt (bound : Nat) (inputs : List (InKey × Nat))
    (ps : List (Option Nat × Option Nat)) (tok : Nat) : Bool :=
  inputs.all fun (key, j) =>
    decide (inputNode (loadedAt (fun j => j) ps) (tensorAt tok) key = some j) &&
      (movingKey key || decide (j < bound))

theorem inputsOkAt_20000 (inputs : List (InKey × Nat))
    (ps : List (Option Nat × Option Nat)) (tok : Nat) :
    InputsOkAt 20000 inputs ps tok = InputsOk inputs ps tok := rfl

theorem inputsOkAt_of_take_drop (bound n : Nat) (inputs : List (InKey × Nat))
    (ps : List (Option Nat × Option Nat)) (tok : Nat)
    (ht : InputsOkAt bound (inputs.take n) ps tok = true)
    (hd : InputsOkAt bound (inputs.drop n) ps tok = true) :
    InputsOkAt bound inputs ps tok = true := by
  unfold InputsOkAt at ht hd ⊢
  rw [← List.take_append_drop n inputs, List.all_append]
  rw [ht, hd]
  rfl

/-- The moving token and caches use the map; checked parameter carriers use its fixed prefix. -/
theorem inputs_at_bound (bound : Nat) (inputs : List (InKey × Nat))
    (ps : List (Option Nat × Option Nat)) (tok : Nat)
    (hok : InputsOkAt bound inputs ps tok = true) (σ : Nat → Nat)
    (hfix : ∀ j, j < bound → σ j = j) :
    ∀ key j, inputsOf inputs key = some j →
      inputNode (loadedAt σ ps) (tensorAt (σ tok)) key = some (σ j) := by
  intro key j hj
  have hc := List.all_eq_true.mp hok _ (inputsOf_mem hj)
  simp only [Bool.and_eq_true, decide_eq_true_eq, Bool.or_eq_true] at hc
  obtain ⟨hn, hm⟩ := hc
  rw [inputNode_at, hn]
  cases h : movingKey key with
  | true => simp
  | false =>
    simp only [h, Bool.false_eq_true, false_or] at hm
    simp [hfix j hm]

end Host.Mlx.SimGraph.Iter
