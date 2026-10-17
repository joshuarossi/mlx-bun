import models.qwen.DeltaNet
import contracts.mlx.ArithmeticDependencies

namespace Inference.Models.Qwen.DeltaCache
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Delta
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open DeltaNet

-- Every updated state coordinate participates in the output dot product.
-- Its range proof is therefore a consequence of the existing output proof.
theorem dot_operands_finite (input : Nat → Float32) (contracted : Bool) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) (a b : Fin 128 → Arithmetic.Expr)
    (hf : Arithmetic.Finite input (Gated.dotExpr contracted tree a b)) (i : Fin 128) :
    Arithmetic.Finite input (a i) ∧ Arithmetic.Finite input (b i) := by
  let lane := (Gated.laneEquiv.symm i).1
  let offset := (Gated.laneEquiv.symm i).2
  have hl : lane ∈ Reduction.leaves tree := coverage.mem_iff.mpr (List.mem_finRange lane)
  have hLane := ArithmeticDependencies.reduce_finite input (Gated.laneExpr contracted a b) tree hf lane hl
  have hParts := ArithmeticDependencies.fold_finite input contracted
    (fun j => a (Gated.laneIndex lane j)) (fun j => b (Gated.laneIndex lane j)) (List.finRange 4) .zero hLane
  have he : Gated.laneIndex lane offset = i := Gated.laneEquiv.apply_symm_apply i
  simpa only [he] using hParts.2 offset (List.mem_finRange offset)

theorem updated_state_range (layer : Layer) (cache : Cache) (x : Nat → Fin 5120 → BF)
    (time : Nat) (hr : RecurrentFinite layer cache x time) (head : Fin 48) (value i : Fin 128) :
    Arithmetic.Finite
      (Recurrence.bind (Recurrence.run layer.recurrence.reduce layer.recurrence.flags (inputs layer cache x head value)
        (cache.recurrent head value) time) (inputs layer cache x head value time))
      (Gated.stateExpr layer.recurrence.flags layer.recurrence.reduction.tree i) :=
  (dot_operands_finite _ layer.recurrence.flags.output layer.recurrence.reduction.tree layer.recurrence.reduction.coverage
    (Gated.stateExpr layer.recurrence.flags layer.recurrence.reduction.tree) (fun j => .input (256+j.val)) (hr.output head value) i).1

def after (layer : Layer) (cache : Cache) (x : Nat → Fin 5120 → BF) (steps : Nat) : Cache where
  history i c := Convolution.tail (fun j => cache.history j c) (fun t => layer.qkv.forward (x t) c) steps i
  recurrent head value := Recurrence.run layer.recurrence.reduce layer.recurrence.flags (inputs layer cache x head value)
    (cache.recurrent head value) steps

noncomputable def targetAfter (layer : Layer) (eps : ℝ) (cache : ReferenceCache) (x : Nat → Fin 5120 → ℝ) (steps : Nat) : ReferenceCache where
  history i c := Convolution.tail (fun j => cache.history j c) (fun t => layer.qkv.target (x t) c) steps i
  recurrent head value := Recurrence.targetRun (targets layer eps cache x head value) (cache.recurrent head value) steps

noncomputable def budgetAfter (layer : Layer) (eps epsError : ℝ) (cache : Cache) (targetCache errorCache : ReferenceCache)
    (x : Nat → Fin 5120 → BF) (target error : Nat → Fin 5120 → ℝ) (steps : Nat) : ReferenceCache where
  history i c := Convolution.tail (fun j => errorCache.history j c) (fun t => layer.qkv.budget (x t) (target t) (error t) c) steps i
  recurrent head value := Recurrence.errorRun layer.recurrence.reduce layer.recurrence.reduction.tree layer.recurrence.flags
    (inputs layer cache x head value) (cache.recurrent head value) (targets layer eps targetCache target head value)
    (inputBudgets layer eps epsError cache targetCache errorCache x target error head value)
    (targetCache.recurrent head value) (errorCache.recurrent head value) steps

theorem after_zero (layer : Layer) (cache : Cache) (x : Nat → Fin 5120 → BF) : after layer cache x 0 = cache := by
  cases cache with
  | mk history recurrent =>
    simp only [after, Recurrence.run, Convolution.initial_history]

theorem history_streaming (layer : Layer) (cache : Cache) (x : Nat → Fin 5120 → BF) (steps : Nat) (i : Fin 3) (c : Fin 10240) :
    (after layer cache x steps).history i c =
      Convolution.runHistory (fun j => cache.history j c) (fun t => layer.qkv.forward (x t) c) steps i := by
  rw [Convolution.history_correct]
  rfl

theorem history_error (layer : Layer) (cache : Cache) (targetCache errorCache : ReferenceCache) (hc : CacheError cache targetCache errorCache)
    (x : Nat → Fin 5120 → BF) (target error : Nat → Fin 5120 → ℝ)
    (hi : ∀ t i, |Model.toReal (x t i) - target t i| ≤ error t i) (hf : ProjectionFinite layer x)
    (eps epsError : ℝ) (steps : Nat) (i : Fin 3) (c : Fin 10240) :
    |Model.toReal ((after layer cache x steps).history i c) - (targetAfter layer eps targetCache target steps).history i c| ≤
      (budgetAfter layer eps epsError cache targetCache errorCache x target error steps).history i c := by
  simp only [after, targetAfter, budgetAfter, Convolution.tail]
  unfold Convolution.joined
  split
  · exact hc.history _ c
  · exact layer.qkv.forward_error _ _ _ (hi _) (hf.qkv _) c

theorem after_error (layer : Layer) (eps epsError : ℝ) (hp : 0 < eps) (hee : |real layer.headParams.eps - eps| ≤ epsError)
    (cache : Cache) (targetCache errorCache : ReferenceCache) (hc : CacheError cache targetCache errorCache)
    (x : Nat → Fin 5120 → BF) (target error : Nat → Fin 5120 → ℝ)
    (hi : ∀ t i, |Model.toReal (x t i) - target t i| ≤ error t i) (hf : ProjectionFinite layer x)
    (hv : ConvolutionFinite layer cache x) (time : Nat) (hr : RecurrentFinite layer cache x time) :
    CacheError (after layer cache x (time+1)) (targetAfter layer eps targetCache target (time+1))
      (budgetAfter layer eps epsError cache targetCache errorCache x target error (time+1)) where
  history := history_error layer cache targetCache errorCache hc x target error hi hf eps epsError (time+1)
  recurrent head value i := by
    apply State.Ssm.state_error layer.recurrence layer.headParams eps epsError hp hee
      (convData layer cache x) (targetConvData layer targetCache target) (convErrors layer errorCache x target error)
      (gates layer x) (targetGates layer target) (gateErrors layer x target error)
      (convolution_finite layer cache x hf hv) (convolution_input_error layer cache targetCache errorCache hc x target error hi hf)
      (gate_input_error layer x target error hi hf) head value (cache.recurrent head value)
      (targetCache.recurrent head value) (errorCache.recurrent head value) (hc.recurrent head value) (time+1)
      (fun t ht => hr.heads t (by omega)) (fun t ht => hr.gates t (by omega)) _ i
    intro t ht j
    by_cases h : t < time
    · exact hr.state head value t h j
    · have he : t = time := by omega
      subst t
      exact updated_state_range layer cache x time hr head value j

structure Finite (cache : Cache) : Prop where
  history : ∀ i c, Model.isFinite (cache.history i c) = true
  recurrent : ∀ head value i, (cache.recurrent head value i).isFinite = true

theorem after_finite (layer : Layer) (cache : Cache) (x : Nat → Fin 5120 → BF)
    (hf : ProjectionFinite layer x) (hv : ConvolutionFinite layer cache x) (time : Nat) (hr : RecurrentFinite layer cache x time) :
    Finite (after layer cache x (time+1)) where
  history i c := by
    simp only [after, Convolution.tail]
    unfold Convolution.joined
    split
    · exact hv.history _ c
    · exact layer.qkv.forward_finite _ (hf.qkv _) c
  recurrent head value i := by
    change (Gated.sourceState _ layer.recurrence.reduce layer.recurrence.flags i).isFinite = true
    rw [← Gated.state_execution _ _ layer.recurrence.reduction]
    exact Arithmetic.finite_evaluate _ _ (updated_state_range layer cache x time hr head value i)

-- One contract now covers both outputs consumed by the next stage: the row
-- sent to the residual block and the state/history retained for the next call.
theorem forward_and_cache_error (layer : Layer) (eps epsError : ℝ) (hp : 0 < eps) (hee : |real layer.headParams.eps - eps| ≤ epsError)
    (cache : Cache) (targetCache errorCache : ReferenceCache) (hc : CacheError cache targetCache errorCache)
    (x : Nat → Fin 5120 → BF) (target error : Nat → Fin 5120 → ℝ)
    (hi : ∀ t i, |Model.toReal (x t i) - target t i| ≤ error t i) (time : Nat) (hf : layer.Finite cache x time) :
    (∀ i, |Model.toReal (layer.forward cache x time i) - layer.target eps targetCache target time i| ≤
      layer.budget eps epsError cache targetCache errorCache x target error time i) ∧
    CacheError (after layer cache x (time+1)) (targetAfter layer eps targetCache target (time+1))
      (budgetAfter layer eps epsError cache targetCache errorCache x target error (time+1)) :=
  ⟨layer.forward_error eps epsError hp hee cache targetCache errorCache hc x target error hi time hf,
    after_error layer eps epsError hp hee cache targetCache errorCache hc x target error hi hf.projections hf.convolution time hf.recurrence⟩

end Inference.Models.Qwen.DeltaCache
