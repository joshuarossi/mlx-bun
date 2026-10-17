import contracts.mlx.ArithmeticFold
import contracts.mlx.FlushedReduction
import contracts.mlx.BFloat16
import Mathlib.Algebra.BigOperators.Fin

namespace Inference.Kernels.Delta.Gated
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators
open Arithmetic (Expr)
set_option maxHeartbeats 2000000
set_option maxRecDepth 10000

-- One value row of gated.ts at Dk=128: 32 SIMD lanes, four contiguous
-- coordinates each. Compiler contraction choices remain explicit and static.
structure Contraction where
  prediction : Bool
  update : Bool
  output : Bool

def laneIndex (lane : Fin 32) (offset : Fin 4) : Fin 128 :=
  ⟨lane.val * 4 + offset.val, by have := lane.isLt; have := offset.isLt; omega⟩

def laneEquiv : (Fin 32 × Fin 4) ≃ Fin 128 where
  toFun p := laneIndex p.1 p.2
  invFun i := (⟨i.val / 4, by have := i.isLt; omega⟩, ⟨i.val % 4, by omega⟩)
  left_inv p := by
    rcases p with ⟨⟨lane, hl⟩, ⟨offset, ho⟩⟩
    apply Prod.ext <;> apply Fin.ext <;> dsimp [laneIndex] <;> omega
  right_inv i := by apply Fin.ext; dsimp [laneIndex]; omega

theorem lanes_complete (f : Fin 128 → ℝ) :
    (∑ lane : Fin 32, ∑ offset : Fin 4, f (laneIndex lane offset)) = ∑ i : Fin 128, f i := by
  simpa only [Fintype.sum_prod_type, laneEquiv, Equiv.coe_fn_mk] using Equiv.sum_comp laneEquiv f

export ArithmeticFold (madd maddFloat evaluate_madd ideal_madd evaluate_fold ideal_fold
  reduceExpr evaluate_reduce ideal_reduce)

def laneExpr (contracted : Bool) (a b : Fin 128 → Expr) (lane : Fin 32) : Expr :=
  (List.finRange 4).foldl (fun acc offset => madd contracted (a (laneIndex lane offset)) (b (laneIndex lane offset)) acc) .zero

def dotExpr (contracted : Bool) (tree : Reduction.Tree 32) (a b : Fin 128 → Expr) : Expr :=
  reduceExpr (laneExpr contracted a b) tree

def sourceDot (reduce : (Fin 32 → Float32) → Float32) (contracted : Bool) (a b : Fin 128 → Float32) : Float32 :=
  reduce (fun lane => (List.finRange 4).foldl
    (fun acc offset => maddFloat contracted (a (laneIndex lane offset)) (b (laneIndex lane offset)) acc) 0)

theorem dot_execution (input : Nat → Float32) (reduce : (Fin 32 → Float32) → Float32)
    (platform : FlushedReduction.SimdContract reduce) (contracted : Bool) (a b : Fin 128 → Expr) :
    Arithmetic.evaluate input (dotExpr contracted platform.tree a b) =
      sourceDot reduce contracted (fun i => Arithmetic.evaluate input (a i)) (fun i => Arithmetic.evaluate input (b i)) := by
  unfold dotExpr sourceDot
  rw [evaluate_reduce, platform.execution]
  apply congrArg (fun f => FlushedReduction.evaluate f platform.tree)
  funext lane
  exact evaluate_fold input contracted _ _ _ .zero

theorem dot_ideal (input : Nat → ℝ) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) (contracted : Bool) (a b : Fin 128 → Expr) :
    Arithmetic.ideal input (dotExpr contracted tree a b) =
      ∑ i : Fin 128, Arithmetic.ideal input (a i) * Arithmetic.ideal input (b i) := by
  unfold dotExpr
  rw [ideal_reduce, Reduction.ideal_complete _ tree coverage, ← Fin.sum_univ_def]
  have hl : ∀ lane, Arithmetic.ideal input (laneExpr contracted a b lane) =
      ∑ offset : Fin 4, Arithmetic.ideal input (a (laneIndex lane offset)) * Arithmetic.ideal input (b (laneIndex lane offset)) := by
    intro lane
    unfold laneExpr
    rw [ideal_fold, Arithmetic.ideal, zero_add, ← Fin.sum_univ_def]
  simp_rw [hl]
  exact lanes_complete (fun i => Arithmetic.ideal input (a i) * Arithmetic.ideal input (b i))

-- Local operands: state[0..127], k[128..255], q[256..383], v[384],
-- g[385], beta[386]. The dispatcher/load proof binds these to tensor cells.
def decayedExpr (i : Fin 128) : Expr := .mul (.input i.val) (.input 385)

def predictionExpr (flags : Contraction) (tree : Reduction.Tree 32) : Expr :=
  dotExpr flags.prediction tree decayedExpr (fun i => .input (128+i.val))

def deltaExpr (flags : Contraction) (tree : Reduction.Tree 32) : Expr :=
  .mul (.sub (.input 384) (predictionExpr flags tree)) (.input 386)

def stateExpr (flags : Contraction) (tree : Reduction.Tree 32) (i : Fin 128) : Expr :=
  madd flags.update (.input (128+i.val)) (deltaExpr flags tree) (decayedExpr i)

def outputExpr (flags : Contraction) (tree : Reduction.Tree 32) : Expr :=
  dotExpr flags.output tree (stateExpr flags tree) (fun i => .input (256+i.val))

def sourceDecayed (input : Nat → Float32) (i : Fin 128) : Float32 := FlushToZero.mul (input i.val) (input 385)

def sourcePrediction (input : Nat → Float32) (reduce : (Fin 32 → Float32) → Float32) (flags : Contraction) : Float32 :=
  sourceDot reduce flags.prediction (sourceDecayed input) (fun i => input (128+i.val))

def sourceDelta (input : Nat → Float32) (reduce : (Fin 32 → Float32) → Float32) (flags : Contraction) : Float32 :=
  FlushToZero.mul (Arithmetic.sub (input 384) (sourcePrediction input reduce flags)) (input 386)

def sourceState (input : Nat → Float32) (reduce : (Fin 32 → Float32) → Float32) (flags : Contraction) (i : Fin 128) : Float32 :=
  maddFloat flags.update (input (128+i.val)) (sourceDelta input reduce flags) (sourceDecayed input i)

def sourceOutput (input : Nat → Float32) (reduce : (Fin 32 → Float32) → Float32) (flags : Contraction) : Float32 :=
  sourceDot reduce flags.output (sourceState input reduce flags) (fun i => input (256+i.val))

def value (input : Nat → Float32) (reduce : (Fin 32 → Float32) → Float32) (flags : Contraction) : Model FloatFormat.bfloat16 :=
  BFloat16.narrow (sourceOutput input reduce flags)

theorem prediction_execution (input : Nat → Float32) (reduce : (Fin 32 → Float32) → Float32)
    (platform : FlushedReduction.SimdContract reduce) (flags : Contraction) :
    Arithmetic.evaluate input (predictionExpr flags platform.tree) = sourcePrediction input reduce flags :=
  dot_execution input reduce platform flags.prediction decayedExpr (fun i => .input (128+i.val))

theorem delta_execution (input : Nat → Float32) (reduce : (Fin 32 → Float32) → Float32)
    (platform : FlushedReduction.SimdContract reduce) (flags : Contraction) :
    Arithmetic.evaluate input (deltaExpr flags platform.tree) = sourceDelta input reduce flags := by
  simp only [deltaExpr, Arithmetic.evaluate, prediction_execution input reduce platform flags, sourceDelta]

theorem state_execution (input : Nat → Float32) (reduce : (Fin 32 → Float32) → Float32)
    (platform : FlushedReduction.SimdContract reduce) (flags : Contraction) (i : Fin 128) :
    Arithmetic.evaluate input (stateExpr flags platform.tree i) = sourceState input reduce flags i := by
  simp only [stateExpr, evaluate_madd, Arithmetic.evaluate, delta_execution input reduce platform flags]
  rfl

theorem output_execution (input : Nat → Float32) (reduce : (Fin 32 → Float32) → Float32)
    (platform : FlushedReduction.SimdContract reduce) (flags : Contraction) :
    Arithmetic.evaluate input (outputExpr flags platform.tree) = sourceOutput input reduce flags := by
  unfold outputExpr
  rw [dot_execution input reduce platform flags.output]
  simp only [state_execution input reduce platform flags, Arithmetic.evaluate, sourceOutput]

-- Independent real-valued recurrence for one row: decay, predict, correct,
-- then project the updated state onto q. These definitions contain no floats.
noncomputable def prediction (input : Nat → ℝ) : ℝ :=
  ∑ i : Fin 128, (input i.val * input 385) * input (128+i.val)

noncomputable def delta (input : Nat → ℝ) : ℝ := (input 384 - prediction input) * input 386

noncomputable def state (input : Nat → ℝ) (i : Fin 128) : ℝ :=
  input i.val * input 385 + input (128+i.val) * delta input

noncomputable def output (input : Nat → ℝ) : ℝ := ∑ i : Fin 128, state input i * input (256+i.val)

theorem prediction_factor (input : Nat → ℝ) :
    prediction input = input 385 * ∑ i : Fin 128, input i.val * input (128+i.val) := by
  unfold prediction
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  ring

theorem state_rank_one (input : Nat → ℝ) (i : Fin 128) :
    state input i = input 385 * input i.val + input 386 *
      (input 384 - input 385 * ∑ j : Fin 128, input j.val * input (128+j.val)) * input (128+i.val) := by
  unfold state delta
  rw [prediction_factor]
  ring

theorem output_rank_one (input : Nat → ℝ) :
    output input = input 385 * (∑ i : Fin 128, input i.val * input (256+i.val)) +
      delta input * (∑ i : Fin 128, input (128+i.val) * input (256+i.val)) := by
  unfold output state
  calc
    _ = ∑ i : Fin 128, (input 385 * (input i.val * input (256+i.val)) +
      delta input * (input (128+i.val) * input (256+i.val))) := by
      apply Finset.sum_congr rfl
      intro i _
      ring
    _ = _ := by rw [Finset.sum_add_distrib, Finset.mul_sum, Finset.mul_sum]

theorem prediction_ideal (input : Nat → ℝ) (flags : Contraction) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) :
    Arithmetic.ideal input (predictionExpr flags tree) = prediction input := by
  unfold predictionExpr
  rw [dot_ideal input tree coverage]
  rfl

theorem delta_ideal (input : Nat → ℝ) (flags : Contraction) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) :
    Arithmetic.ideal input (deltaExpr flags tree) = delta input := by
  simp only [deltaExpr, Arithmetic.ideal, prediction_ideal input flags tree coverage, delta]

theorem state_ideal (input : Nat → ℝ) (flags : Contraction) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) (i : Fin 128) :
    Arithmetic.ideal input (stateExpr flags tree i) = state input i := by
  simp only [stateExpr, ideal_madd, Arithmetic.ideal, delta_ideal input flags tree coverage]
  rfl

theorem output_ideal (input : Nat → ℝ) (flags : Contraction) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) :
    Arithmetic.ideal input (outputExpr flags tree) = output input := by
  unfold outputExpr
  rw [dot_ideal input tree coverage]
  simp only [state_ideal input flags tree coverage, Arithmetic.ideal, output]

theorem state_error (input : Nat → Float32) (target inputError : Nat → ℝ)
    (hi : ∀ i, |real (input i) - target i| ≤ inputError i)
    (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (flags : Contraction) (i : Fin 128) (hf : Arithmetic.Finite input (stateExpr flags platform.tree i)) :
    |real (sourceState input reduce flags i) - state target i| ≤
      Arithmetic.budget input target inputError (stateExpr flags platform.tree i) := by
  have h := Arithmetic.error input target inputError hi (stateExpr flags platform.tree i) hf
  rw [state_execution input reduce platform flags i, state_ideal target flags platform.tree platform.coverage i] at h
  exact h

theorem value_error (input : Nat → Float32) (target inputError : Nat → ℝ)
    (hi : ∀ i, |real (input i) - target i| ≤ inputError i)
    (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (flags : Contraction) (hf : Arithmetic.Finite input (outputExpr flags platform.tree))
    (hb : Model.isFinite (value input reduce flags) = true) :
    |Model.toReal (value input reduce flags) - output target| ≤
      Arithmetic.budget input target inputError (outputExpr flags platform.tree) + BFloat16.epsilon (real (sourceOutput input reduce flags)) := by
  have h := Arithmetic.error input target inputError hi (outputExpr flags platform.tree) hf
  rw [output_execution input reduce platform flags, output_ideal target flags platform.tree platform.coverage] at h
  have hfinite := Arithmetic.finite_evaluate input (outputExpr flags platform.tree) hf
  rw [output_execution input reduce platform flags] at hfinite
  have hcast := BFloat16.narrow_error (sourceOutput input reduce flags) hfinite hb
  change |Model.toReal (value input reduce flags) - real (sourceOutput input reduce flags)| ≤ _ at hcast
  calc
    _ = |(Model.toReal (value input reduce flags) - real (sourceOutput input reduce flags)) +
      (real (sourceOutput input reduce flags) - output target)| := by congr 1; ring
    _ ≤ _ := by have h' := (abs_add_le _ _).trans (add_le_add hcast h); linarith

end Inference.Kernels.Delta.Gated
