import kernels.delta.Layout

namespace Inference.Kernels.Delta.Recurrence
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators

structure Inputs (α : Type) where
  key : Fin 128 → α
  query : Fin 128 → α
  value : α
  decay : α
  beta : α

-- Bind the distinct source operands to the row proof's local variables.
-- The tail of this total function is unused by the kernel expressions.
def bind (state : Fin 128 → α) (input : Inputs α) (index : Nat) : α :=
  if hs : index < 128 then state ⟨index, hs⟩
  else if hk : index < 256 then input.key ⟨index-128, by omega⟩
  else if hq : index < 384 then input.query ⟨index-256, by omega⟩
  else if index = 384 then input.value
  else if index = 385 then input.decay
  else input.beta

theorem bind_state (state : Fin 128 → α) (input : Inputs α) (i : Fin 128) : bind state input i.val = state i := by
  simp [bind, i.isLt]

theorem bind_key (state : Fin 128 → α) (input : Inputs α) (i : Fin 128) : bind state input (128+i.val) = input.key i := by
  have hi := i.isLt
  simp [bind, show ¬128+i.val < 128 by omega, show 128+i.val < 256 by omega]

theorem bind_query (state : Fin 128 → α) (input : Inputs α) (i : Fin 128) : bind state input (256+i.val) = input.query i := by
  have hi := i.isLt
  simp [bind, show ¬256+i.val < 128 by omega, show ¬256+i.val < 256 by omega, show 256+i.val < 384 by omega]

theorem bind_value (state : Fin 128 → α) (input : Inputs α) : bind state input 384 = input.value := by simp [bind]
theorem bind_decay (state : Fin 128 → α) (input : Inputs α) : bind state input 385 = input.decay := by simp [bind]
theorem bind_beta (state : Fin 128 → α) (input : Inputs α) : bind state input 386 = input.beta := by simp [bind]

structure InputError (actual : Inputs Float32) (target bound : Inputs ℝ) : Prop where
  key : ∀ i, |real (actual.key i) - target.key i| ≤ bound.key i
  query : ∀ i, |real (actual.query i) - target.query i| ≤ bound.query i
  value : |real actual.value - target.value| ≤ bound.value
  decay : |real actual.decay - target.decay| ≤ bound.decay
  beta : |real actual.beta - target.beta| ≤ bound.beta

theorem bind_error (state : Fin 128 → Float32) (targetState stateError : Fin 128 → ℝ)
    (hs : ∀ i, |real (state i) - targetState i| ≤ stateError i)
    (input : Inputs Float32) (target inputError : Inputs ℝ) (he : InputError input target inputError) (i : Nat) :
    |real (bind state input i) - bind targetState target i| ≤ bind stateError inputError i := by
  by_cases hstate : i < 128
  · simpa only [bind, dite_eq_left hstate] using hs ⟨i, hstate⟩
  · by_cases hkey : i < 256
    · simpa only [bind, dite_eq_right hstate, dite_eq_left hkey] using he.key ⟨i-128, by omega⟩
    · by_cases hquery : i < 384
      · simpa only [bind, dite_eq_right hstate, dite_eq_right hkey, dite_eq_left hquery] using he.query ⟨i-256, by omega⟩
      · by_cases hv : i = 384
        · simpa only [bind, dite_eq_right hstate, dite_eq_right hkey, dite_eq_right hquery, ite_eq_left hv] using he.value
        · by_cases hg : i = 385
          · simpa only [bind, dite_eq_right hstate, dite_eq_right hkey, dite_eq_right hquery, ite_eq_right hv, ite_eq_left hg] using he.decay
          · simpa only [bind, dite_eq_right hstate, dite_eq_right hkey, dite_eq_right hquery, ite_eq_right hv, ite_eq_right hg] using he.beta

def step (reduce : (Fin 32 → Float32) → Float32) (flags : Gated.Contraction)
    (state : Fin 128 → Float32) (input : Inputs Float32) : Fin 128 → Float32 :=
  Gated.sourceState (bind state input) reduce flags

noncomputable def targetStep (state : Fin 128 → ℝ) (input : Inputs ℝ) : Fin 128 → ℝ :=
  Gated.state (bind state input)

theorem targetStep_formula (state : Fin 128 → ℝ) (input : Inputs ℝ) (i : Fin 128) :
    targetStep state input i = input.decay * state i + input.beta *
      (input.value - input.decay * ∑ j : Fin 128, state j * input.key j) * input.key i := by
  unfold targetStep
  rw [Gated.state_rank_one]
  simp only [bind_state, bind_key, bind_value, bind_decay, bind_beta]

noncomputable def stepBudget (tree : Reduction.Tree 32) (flags : Gated.Contraction)
    (state : Fin 128 → Float32) (input : Inputs Float32)
    (targetState stateError : Fin 128 → ℝ) (target inputError : Inputs ℝ) (i : Fin 128) : ℝ :=
  Arithmetic.budget (bind state input) (bind targetState target) (bind stateError inputError) (Gated.stateExpr flags tree i)

theorem step_error (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (flags : Gated.Contraction) (state : Fin 128 → Float32) (input : Inputs Float32)
    (targetState stateError : Fin 128 → ℝ) (target inputError : Inputs ℝ)
    (hs : ∀ i, |real (state i) - targetState i| ≤ stateError i) (he : InputError input target inputError)
    (i : Fin 128) (hf : Arithmetic.Finite (bind state input) (Gated.stateExpr flags platform.tree i)) :
    |real (step reduce flags state input i) - targetStep targetState target i| ≤
      stepBudget platform.tree flags state input targetState stateError target inputError i :=
  Gated.state_error (bind state input) (bind targetState target) (bind stateError inputError)
    (bind_error state targetState stateError hs input target inputError he) reduce platform flags i hf

-- Every iteration consumes the previous register state. No step is assumed
-- exact: the preceding step's error becomes the next step's input error.
def run (reduce : (Fin 32 → Float32) → Float32) (flags : Gated.Contraction)
    (inputs : Nat → Inputs Float32) (initial : Fin 128 → Float32) : Nat → Fin 128 → Float32
  | 0 => initial
  | t+1 => step reduce flags (run reduce flags inputs initial t) (inputs t)

noncomputable def targetRun (inputs : Nat → Inputs ℝ) (initial : Fin 128 → ℝ) : Nat → Fin 128 → ℝ
  | 0 => initial
  | t+1 => targetStep (targetRun inputs initial t) (inputs t)

noncomputable def errorRun (reduce : (Fin 32 → Float32) → Float32) (tree : Reduction.Tree 32) (flags : Gated.Contraction)
    (inputs : Nat → Inputs Float32) (initial : Fin 128 → Float32)
    (targets errors : Nat → Inputs ℝ) (targetInitial initialError : Fin 128 → ℝ) : Nat → Fin 128 → ℝ
  | 0 => initialError
  | t+1 => stepBudget tree flags (run reduce flags inputs initial t) (inputs t)
      (targetRun targets targetInitial t) (errorRun reduce tree flags inputs initial targets errors targetInitial initialError t)
      (targets t) (errors t)

theorem run_error (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce) (flags : Gated.Contraction)
    (inputs : Nat → Inputs Float32) (initial : Fin 128 → Float32)
    (targets errors : Nat → Inputs ℝ) (targetInitial initialError : Fin 128 → ℝ)
    (hi : ∀ i, |real (initial i) - targetInitial i| ≤ initialError i) (steps : Nat) :
    (∀ t, t < steps → ∀ i : Fin 128, Arithmetic.Finite (bind (run reduce flags inputs initial t) (inputs t)) (Gated.stateExpr flags platform.tree i)) →
    (∀ t, t < steps → InputError (inputs t) (targets t) (errors t)) →
    ∀ i, |real (run reduce flags inputs initial steps i) - targetRun targets targetInitial steps i| ≤
      errorRun reduce platform.tree flags inputs initial targets errors targetInitial initialError steps i := by
  induction steps with
  | zero => intro _ _ i; exact hi i
  | succ t ih =>
    intro hf he i
    have previous := ih (fun j hj => hf j (by omega)) (fun j hj => he j (by omega))
    exact step_error reduce platform flags _ _ _ _ _ _ previous (he t (by omega)) i (hf t (by omega) i)

def outputAt (reduce : (Fin 32 → Float32) → Float32) (flags : Gated.Contraction)
    (inputs : Nat → Inputs Float32) (initial : Fin 128 → Float32) (time : Nat) : Model FloatFormat.bfloat16 :=
  Gated.value (bind (run reduce flags inputs initial time) (inputs time)) reduce flags

noncomputable def targetOutputAt (inputs : Nat → Inputs ℝ) (initial : Fin 128 → ℝ) (time : Nat) : ℝ :=
  Gated.output (bind (targetRun inputs initial time) (inputs time))

noncomputable def outputBudget (reduce : (Fin 32 → Float32) → Float32) (tree : Reduction.Tree 32) (flags : Gated.Contraction)
    (inputs : Nat → Inputs Float32) (initial : Fin 128 → Float32)
    (targets errors : Nat → Inputs ℝ) (targetInitial initialError : Fin 128 → ℝ) (time : Nat) : ℝ :=
  Arithmetic.budget (bind (run reduce flags inputs initial time) (inputs time))
    (bind (targetRun targets targetInitial time) (targets time))
    (bind (errorRun reduce tree flags inputs initial targets errors targetInitial initialError time) (errors time))
    (Gated.outputExpr flags tree) +
    BFloat16.epsilon (real (Gated.sourceOutput (bind (run reduce flags inputs initial time) (inputs time)) reduce flags))

theorem output_error (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce) (flags : Gated.Contraction)
    (inputs : Nat → Inputs Float32) (initial : Fin 128 → Float32)
    (targets errors : Nat → Inputs ℝ) (targetInitial initialError : Fin 128 → ℝ)
    (hi : ∀ i, |real (initial i) - targetInitial i| ≤ initialError i) (time : Nat)
    (hf : ∀ t, t < time → ∀ i : Fin 128, Arithmetic.Finite (bind (run reduce flags inputs initial t) (inputs t)) (Gated.stateExpr flags platform.tree i))
    (he : ∀ t, t ≤ time → InputError (inputs t) (targets t) (errors t))
    (ho : Arithmetic.Finite (bind (run reduce flags inputs initial time) (inputs time)) (Gated.outputExpr flags platform.tree))
    (hb : Model.isFinite (outputAt reduce flags inputs initial time) = true) :
    |Model.toReal (outputAt reduce flags inputs initial time) - targetOutputAt targets targetInitial time| ≤
      outputBudget reduce platform.tree flags inputs initial targets errors targetInitial initialError time := by
  have hs := run_error reduce platform flags inputs initial targets errors targetInitial initialError hi time hf
    (fun t ht => he t (by omega))
  exact Gated.value_error _ _ _ (bind_error _ _ _ hs _ _ _ (he time (by omega))) reduce platform flags ho hb

theorem stored_run_error (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce) (flags : Gated.Contraction)
    (inputs : Nat → Inputs Float32) (initial : Fin 128 → Float32)
    (targets errors : Nat → Inputs ℝ) (targetInitial initialError : Fin 128 → ℝ)
    (hi : ∀ i, |real (initial i) - targetInitial i| ≤ initialError i) (steps : Nat)
    (hf : ∀ t, t < steps → ∀ i : Fin 128, Arithmetic.Finite (bind (run reduce flags inputs initial t) (inputs t)) (Gated.stateExpr flags platform.tree i))
    (he : ∀ t, t < steps → InputError (inputs t) (targets t) (errors t))
    (base : Nat) (row : Layout.Row batchSize) (before : M1Max.WordMemory) (scheduled : List Memory.Store)
    (order : scheduled.Perm (Layout.stores base row (run reduce flags inputs initial steps))) (i : Fin 128) :
    |real (Memory.execute scheduled before (Layout.stateAddress base row i)) - targetRun targets targetInitial steps i| ≤
      errorRun reduce platform.tree flags inputs initial targets errors targetInitial initialError steps i := by
  rw [Layout.state_written base row _ before scheduled order i]
  exact run_error reduce platform flags inputs initial targets errors targetInitial initialError hi steps hf he i

end Inference.Kernels.Delta.Recurrence
