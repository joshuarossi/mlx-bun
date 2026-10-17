import models.qwen.DecodeStageSequenceRanges

namespace Inference.Models.Qwen.DecodeChainSequenceRanges
open Contracts.Mlx Contracts.Mlx.Numerics DecodeStage Kernels.Attention
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

def Parameters : List Stage → Prop
  | [] => True
  | s::rest => DecodeStageSequenceRanges.Parameters s ∧ Parameters rest
def Primitives : List Stage → Type
  | [] => PUnit
  | s::rest => DecodeStageSequenceRanges.Primitives s × Primitives rest
def CachesBound : (stages : List Stage) → DecodeChain.Caches stages time → Prop
  | [], _ => True
  | s::rest, cache => DecodeStageSequenceRanges.CacheBound s cache.1 ∧ CachesBound rest cache.2

theorem initial (stages : List Stage) : CachesBound stages (InitialState.caches stages) := by
  induction stages with
  | nil => trivial
  | cons s rest ih => exact ⟨DecodeStageSequenceRanges.initial s, ih⟩

theorem caches_finite (stages : List Stage) (cache : DecodeChain.Caches stages time) (hc : CachesBound stages cache) :
    DecodeChain.CachesFinite stages cache := by
  induction stages with
  | nil => trivial
  | cons s rest ih => exact ⟨DecodeStageSequenceRanges.cache_finite s cache.1 hc.1, ih cache.2 hc.2⟩

noncomputable def ranges : (stages : List Stage) → Parameters stages → Primitives stages →
    (index : Nat) → index+stages.length ≤ 64 →
    (cache : DecodeChain.Caches stages time) → CachesBound stages cache →
    (x : Row BF) → ResidualMlpRanges.InputBound index x →
    (angle : RopeAngles.Inputs) → RopeAnglesRanges.InputsBound angle → time+1 ≤ 262144 →
    DecodeChain.Ranges stages cache x angle
  | [], _, _, _, _, _, _, _, _, _, _, _ => ⟨⟩
  | s::rest, parameters, primitive, index, size, cache, hc, x, hx, angle, ha, supported =>
    let hs : index < 64 := by simp only [List.length_cons] at size; omega
    let ht : index+1+rest.length ≤ 64 := by simp only [List.length_cons] at size; omega
    ⟨DecodeStageSequenceRanges.checked s parameters.1 primitive.1 index hs cache.1 hc.1 x hx angle ha supported,
      ranges rest parameters.2 primitive.2 (index+1) ht cache.2 hc.2 (DecodeStage.forward s cache.1 x angle)
        (DecodeStageSequenceRanges.next_input s parameters.1 primitive.1 index hs cache.1 hc.1 x hx angle ha supported)
        angle ha supported⟩

theorem next_input (stages : List Stage) (parameters : Parameters stages) (primitive : Primitives stages)
    (index : Nat) (size : index+stages.length ≤ 64) (cache : DecodeChain.Caches stages time) (hc : CachesBound stages cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144) :
    ResidualMlpRanges.InputBound (index+stages.length) (DecodeChain.run stages cache x angle).1 := by
  induction stages generalizing index x with
  | nil => exact hx
  | cons s rest ih =>
    have hs : index < 64 := by simp only [List.length_cons] at size; omega
    have ht : index+1+rest.length ≤ 64 := by simp only [List.length_cons] at size; omega
    have hn := DecodeStageSequenceRanges.next_input s parameters.1 primitive.1 index hs cache.1 hc.1 x hx angle ha supported
    have h := ih parameters.2 primitive.2 (index+1) ht cache.2 hc.2 (DecodeStage.forward s cache.1 x angle) hn
    simpa only [DecodeChain.run, List.length_cons, show index+1+rest.length = index+(rest.length+1) from by omega] using h

theorem output_bounded (stages : List Stage) (parameters : Parameters stages) (primitive : Primitives stages)
    (index : Nat) (size : index+stages.length ≤ 64) (nonempty : stages ≠ [])
    (cache : DecodeChain.Caches stages time) (hc : CachesBound stages cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144) :
    ∀ i, |Model.toReal ((DecodeChain.run stages cache x angle).1 i)| ≤ (2 : ℝ)^(56 : Nat) := by
  induction stages generalizing index x with
  | nil => exact False.elim (nonempty rfl)
  | cons s rest ih =>
    have hs : index < 64 := by simp only [List.length_cons] at size; omega
    have ht : index+1+rest.length ≤ 64 := by simp only [List.length_cons] at size; omega
    by_cases empty : rest = []
    · subst rest
      exact DecodeStageSequenceRanges.output_bounded s parameters.1 primitive.1 index hs cache.1 hc.1 x hx angle ha supported
    · exact ih parameters.2 primitive.2 (index+1) ht empty cache.2 hc.2 (DecodeStage.forward s cache.1 x angle)
        (DecodeStageSequenceRanges.next_input s parameters.1 primitive.1 index hs cache.1 hc.1 x hx angle ha supported)

theorem next_cache (stages : List Stage) (parameters : Parameters stages) (primitive : Primitives stages)
    (index : Nat) (size : index+stages.length ≤ 64) (cache : DecodeChain.Caches stages time) (hc : CachesBound stages cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144) :
    CachesBound stages (DecodeChain.run stages cache x angle).2 := by
  induction stages generalizing index x with
  | nil => trivial
  | cons s rest ih =>
    have hs : index < 64 := by simp only [List.length_cons] at size; omega
    have ht : index+1+rest.length ≤ 64 := by simp only [List.length_cons] at size; omega
    refine ⟨DecodeStageSequenceRanges.next_cache s parameters.1 primitive.1 index hs cache.1 hc.1 x hx angle ha supported, ?_⟩
    exact ih parameters.2 primitive.2 (index+1) ht cache.2 hc.2 (DecodeStage.forward s cache.1 x angle)
      (DecodeStageSequenceRanges.next_input s parameters.1 primitive.1 index hs cache.1 hc.1 x hx angle ha supported)

theorem run_correct (stages : List Stage) (parameters : Parameters stages) (primitive : Primitives stages)
    (index : Nat) (size : index+stages.length ≤ 64) (cache : DecodeChain.Caches stages time) (cacheBound : CachesBound stages cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144)
    (ct ce : DecodeChain.ReferenceCaches stages time) (hc : DecodeChain.CacheErrors stages cache ct ce)
    (t e : Row ℝ) (hi : ∀ i, |Model.toReal (x i)-t i| ≤ e i)
    (aim ae : RopeAngles.Target) (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) :
    (∀ i, |Model.toReal ((DecodeChain.run stages cache x angle).1 i)-(DecodeChain.targetRun stages ct t aim).1 i| ≤
      (DecodeChain.budgetRun stages cache ct ce x t e angle aim ae
        (ranges stages parameters primitive index size cache cacheBound x hx angle ha supported)).1 i) ∧
    DecodeChain.CacheErrors stages (DecodeChain.run stages cache x angle).2 (DecodeChain.targetRun stages ct t aim).2
      (DecodeChain.budgetRun stages cache ct ce x t e angle aim ae
        (ranges stages parameters primitive index size cache cacheBound x hx angle ha supported)).2 ∧
    (∀ i, Model.isFinite ((DecodeChain.run stages cache x angle).1 i) = true) ∧
    DecodeChain.CachesFinite stages (DecodeChain.run stages cache x angle).2 := by
  induction stages generalizing index x t e with
  | nil => exact ⟨hi, trivial, fun i => (hx i).1, trivial⟩
  | cons s rest ih =>
    have hs : index < 64 := by simp only [List.length_cons] at size; omega
    have ht : index+1+rest.length ≤ 64 := by simp only [List.length_cons] at size; omega
    let hf := DecodeStageSequenceRanges.checked s parameters.1 primitive.1 index hs cache.1 cacheBound.1 x hx angle ha supported
    have hn := DecodeStageSequenceRanges.next_input s parameters.1 primitive.1 index hs cache.1 cacheBound.1 x hx angle ha supported
    have layer := DecodeStageSequenceRanges.accuracy s parameters.1 primitive.1 index hs cache.1 cacheBound.1 x hx angle ha supported
      ct.1 ce.1 hc.1 t e hi aim ae he hb
    have tail := ih parameters.2 primitive.2 (index+1) ht cache.2 cacheBound.2 (DecodeStage.forward s cache.1 x angle) hn
      ct.2 ce.2 hc.2 (DecodeStage.target s ct.1 t aim) (DecodeStage.budget s cache.1 ct.1 ce.1 x t e angle aim ae hf) layer.1
    exact ⟨tail.1, ⟨layer.2, tail.2.1⟩, tail.2.2.1,
      ⟨DecodeStage.cache_finite s cache.1 x angle (DecodeStageSequenceRanges.cache_finite s cache.1 cacheBound.1) hf, tail.2.2.2⟩⟩

end Inference.Models.Qwen.DecodeChainSequenceRanges
