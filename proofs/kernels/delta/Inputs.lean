import kernels.delta.Decay
import kernels.delta.Recurrence

namespace Inference.Kernels.Delta.Inputs
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Trellis
abbrev BF := BFloat16Arithmetic.Value

structure Projected (α : Type) where
  key : Fin 128 → α
  query : Fin 128 → α
  value : α
  aLog : α
  a : α
  dtBias : α
  b : α

structure Platform where
  decay : Decay.Platform
  expAbs : BF → BF
  expAbsError : BF → ℝ
  exponential : GateUpSplitTail.ExpAbsContract expAbs expAbsError

def actual (p : Platform) (x : Projected BF) : Recurrence.Inputs Float32 where
  key i := BFloat16.widen (x.key i)
  query i := BFloat16.widen (x.query i)
  value := BFloat16.widen x.value
  decay := Decay.value p.decay (BFloat16.widen x.aLog) x.a x.dtBias
  beta := BFloat16.widen (GateUpSplitTail.sigmoidValue p.expAbs x.b)

noncomputable def target (x : Projected ℝ) : Recurrence.Inputs ℝ where
  key := x.key
  query := x.query
  value := x.value
  decay := Gates.decay x.aLog (x.a + x.dtBias)
  beta := GateUpTail.sigmoid x.b

structure Finite (p : Platform) (x : Projected BF) : Prop where
  key : ∀ i, Model.isFinite (x.key i) = true
  query : ∀ i, Model.isFinite (x.query i) = true
  value : Model.isFinite x.value = true
  aLog : Model.isFinite x.aLog = true
  b : Model.isFinite x.b = true
  decay : Decay.Finite p.decay (BFloat16.widen x.aLog) x.a x.dtBias
  beta : Gates.BetaValid p.expAbs x.b

structure ProjectionError (x : Projected BF) (y error : Projected ℝ) : Prop where
  key : ∀ i, |Model.toReal (x.key i) - y.key i| ≤ error.key i
  query : ∀ i, |Model.toReal (x.query i) - y.query i| ≤ error.query i
  value : |Model.toReal x.value - y.value| ≤ error.value
  aLog : |Model.toReal x.aLog - y.aLog| ≤ error.aLog
  a : |Model.toReal x.a - y.a| ≤ error.a
  dtBias : |Model.toReal x.dtBias - y.dtBias| ≤ error.dtBias
  b : |Model.toReal x.b - y.b| ≤ error.b

noncomputable def scaleError (x : Projected BF) (y error : Projected ℝ) : ℝ :=
  Real.exp (max y.aLog (Model.toReal x.aLog)) * error.aLog
noncomputable def bounds (p : Platform) (x : Projected BF) (y error : Projected ℝ) : Recurrence.Inputs ℝ where
  key := error.key
  query := error.query
  value := error.value
  decay := Decay.budget p.decay (BFloat16.widen x.aLog) x.a x.dtBias +
    scaleError x y error * Gates.softplus (Model.toReal x.a + Model.toReal x.dtBias) +
    Real.exp y.aLog * (error.a + error.dtBias)
  beta := Gates.betaBudget p.expAbs p.expAbsError x.b + error.b / 4

-- Construct the recurrence's contract from the gate proofs. In particular,
-- accuracy of the composed beta/decay gates is not a caller assumption.
theorem input_error (p : Platform) (x : Projected BF) (y error : Projected ℝ)
    (hf : Finite p x) (he : ProjectionError x y error) :
    Recurrence.InputError (actual p x) (target y) (bounds p x y error) := by
  constructor
  · intro i
    simpa only [actual, target, bounds, BFloat16.widen_real _ (hf.key i)] using he.key i
  · intro i
    simpa only [actual, target, bounds, BFloat16.widen_real _ (hf.query i)] using he.query i
  · simpa only [actual, target, bounds, BFloat16.widen_real _ hf.value] using he.value
  · apply Decay.propagated_error p.decay (BFloat16.widen x.aLog) x.a x.dtBias hf.decay
      y.aLog (y.a + y.dtBias) (scaleError x y error) (error.a + error.dtBias)
    · rw [BFloat16.widen_real _ hf.aLog]
      exact (Gates.exp_lipschitz y.aLog (Model.toReal x.aLog)).trans
        (mul_le_mul_of_nonneg_left he.aLog (Real.exp_pos _).le)
    · calc
        _ = |(Model.toReal x.a - y.a) + (Model.toReal x.dtBias - y.dtBias)| := by congr 1; ring
        _ ≤ _ := (abs_add_le _ _).trans (add_le_add he.a he.dtBias)
  · change |real (BFloat16.widen (GateUpSplitTail.sigmoidValue p.expAbs x.b)) - GateUpTail.sigmoid y.b| ≤ _
    rw [BFloat16.widen_real _ (Gates.beta_finite p.expAbs p.expAbsError p.exponential x.b hf.beta)]
    exact Gates.beta_total_error p.expAbs p.expAbsError p.exponential x.b hf.b hf.beta y.b error.b he.b

-- A complete recurrent step now consumes projection contracts and the
-- primitive gate contracts, with its incoming state error carried through.
theorem step_error (p : Platform) (x : Projected BF) (y error : Projected ℝ)
    (hf : Finite p x) (he : ProjectionError x y error)
    (reduce : (Fin 32 → Float32) → Float32) (reduction : FlushedReduction.SimdContract reduce)
    (flags : Gated.Contraction) (state : Fin 128 → Float32) (ideal stateError : Fin 128 → ℝ)
    (hs : ∀ i, |real (state i) - ideal i| ≤ stateError i) (i : Fin 128)
    (hr : Arithmetic.Finite (Recurrence.bind state (actual p x)) (Gated.stateExpr flags reduction.tree i)) :
    |real (Recurrence.step reduce flags state (actual p x) i) - Recurrence.targetStep ideal (target y) i| ≤
      Recurrence.stepBudget reduction.tree flags state (actual p x) ideal stateError (target y) (bounds p x y error) i :=
  Recurrence.step_error reduce reduction flags state (actual p x) ideal stateError (target y) (bounds p x y error)
    hs (input_error p x y error hf he) i hr

theorem run_error (p : Platform) (xs : Nat → Projected BF) (ys errors : Nat → Projected ℝ)
    (reduce : (Fin 32 → Float32) → Float32) (reduction : FlushedReduction.SimdContract reduce)
    (flags : Gated.Contraction) (initial : Fin 128 → Float32) (ideal initialError : Fin 128 → ℝ)
    (hi : ∀ i, |real (initial i) - ideal i| ≤ initialError i) (steps : Nat)
    (hf : ∀ t, t < steps → Finite p (xs t))
    (he : ∀ t, t < steps → ProjectionError (xs t) (ys t) (errors t))
    (hr : ∀ t, t < steps → ∀ i : Fin 128,
      Arithmetic.Finite (Recurrence.bind (Recurrence.run reduce flags (fun s => actual p (xs s)) initial t) (actual p (xs t)))
        (Gated.stateExpr flags reduction.tree i)) :
    ∀ i, |real (Recurrence.run reduce flags (fun t => actual p (xs t)) initial steps i) -
      Recurrence.targetRun (fun t => target (ys t)) ideal steps i| ≤
      Recurrence.errorRun reduce reduction.tree flags (fun t => actual p (xs t)) initial
        (fun t => target (ys t)) (fun t => bounds p (xs t) (ys t) (errors t)) ideal initialError steps i :=
  Recurrence.run_error reduce reduction flags (fun t => actual p (xs t)) initial
    (fun t => target (ys t)) (fun t => bounds p (xs t) (ys t) (errors t)) ideal initialError hi steps hr
    (fun t ht => input_error p (xs t) (ys t) (errors t) (hf t ht) (he t ht))

end Inference.Kernels.Delta.Inputs
