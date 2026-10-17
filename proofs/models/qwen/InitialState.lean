import models.qwen.TokenInference

namespace Inference.Models.Qwen.InitialState
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open DecodeStage Kernels.Attention

-- SSMCache's absent convolution/recurrent tensors become zero tensors; the
-- plain KV cache has no active rows before the first append. Native allocation
-- is not modeled by these value-level initialization theorems.
def delta : DeltaNet.Cache where
  history _ _ := Model.zero FloatFormat.bfloat16 false
  recurrent _ _ _ := 0
def deltaReference : DeltaNet.ReferenceCache where
  history _ _ := 0
  recurrent _ _ _ := 0

theorem delta_error : DeltaNet.CacheError delta deltaReference deltaReference := by
  constructor
  · intro i c
    simp [delta, deltaReference]
  · intro h v k
    simp [delta, deltaReference, Kernels.StableSigmoid.real_zero]
theorem delta_finite : DeltaCache.Finite delta := by
  constructor
  · intro i c
    dsimp [delta]
    decide +kernel
  · intro h v k
    dsimp [delta]
    decide +kernel

def emptyKv (α : Type) : State.Kv.Cache α 0 where
  keys _ t _ := Fin.elim0 t
  values _ t _ := Fin.elim0 t
theorem empty_error : State.Kv.Error (emptyKv BF) (emptyKv ℝ) (emptyKv ℝ) := by
  constructor <;> intro _ t <;> exact Fin.elim0 t
theorem empty_finite : State.Kv.Finite (emptyKv BF) := by
  constructor <;> intro _ t <;> exact Fin.elim0 t

def stage : (s : Stage) → Cache s 0
  | .delta _ => delta
  | .attention _ => emptyKv BF
def stageReference : (s : Stage) → ReferenceCache s 0
  | .delta _ => deltaReference
  | .attention _ => emptyKv ℝ
theorem stage_error (s : Stage) : CacheError s (stage s) (stageReference s) (stageReference s) := by
  cases s with
  | delta _ => exact delta_error
  | attention _ => exact empty_error
theorem stage_finite (s : Stage) : CacheFinite s (stage s) := by
  cases s with
  | delta _ => exact delta_finite
  | attention _ => exact empty_finite

def caches : (stages : List Stage) → DecodeChain.Caches stages 0
  | [] => ⟨⟩
  | s::rest => (stage s, caches rest)
def references : (stages : List Stage) → DecodeChain.ReferenceCaches stages 0
  | [] => ⟨⟩
  | s::rest => (stageReference s, references rest)

theorem caches_error (stages : List Stage) : DecodeChain.CacheErrors stages (caches stages) (references stages) (references stages) := by
  induction stages with
  | nil => trivial
  | cons s rest ih => exact ⟨stage_error s, ih⟩
theorem caches_finite (stages : List Stage) : DecodeChain.CachesFinite stages (caches stages) := by
  induction stages with
  | nil => trivial
  | cons s rest ih => exact ⟨stage_finite s, ih⟩

theorem first_token_correct (p : TokenInference.Pipeline) (token : Fin 248320) (a : RopeAngles.Inputs) (aim ae : RopeAngles.Target)
    (hf : p.Ranges (caches p.graph.stages) token a) (ha : RopeAngles.InputError a aim ae) (hb : 0 ≤ aim.base)
    (capacity : p.Capacities (caches p.graph.stages) (references p.graph.stages) (references p.graph.stages) token a aim ae hf) :
    (∀ i, |Model.toReal ((p.run (caches p.graph.stages) token a).1 i) - (p.targetRun (references p.graph.stages) token aim).1 i| ≤
      (p.budgetRun (caches p.graph.stages) (references p.graph.stages) (references p.graph.stages) token a aim ae hf).1 i) ∧
    DecodeChain.CacheErrors p.graph.stages (p.run (caches p.graph.stages) token a).2 (p.targetRun (references p.graph.stages) token aim).2
      (p.budgetRun (caches p.graph.stages) (references p.graph.stages) (references p.graph.stages) token a aim ae hf).2 ∧
    (∀ i, Model.isFinite ((p.run (caches p.graph.stages) token a).1 i) = true) ∧
    DecodeChain.CachesFinite p.graph.stages (p.run (caches p.graph.stages) token a).2 :=
  p.run_correct _ _ _ token a aim ae (caches_error p.graph.stages) (caches_finite p.graph.stages) hf ha hb capacity

end Inference.Models.Qwen.InitialState
