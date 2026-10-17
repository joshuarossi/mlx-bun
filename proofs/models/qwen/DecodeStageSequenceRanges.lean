import models.qwen.InitialState
import models.qwen.ResidualDeltaDecodeRanges
import models.qwen.ResidualAttentionSequenceRanges

namespace Inference.Models.Qwen.DecodeStageSequenceRanges
open Contracts.Mlx Contracts.Mlx.Numerics DecodeStage Kernels.Attention Kernels.Delta
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

def Parameters : Stage → Prop
  | .delta b => ResidualDeltaDecodeRanges.Parameters b
  | .attention b => ResidualAttentionSequenceRanges.Parameters b
def Primitives : Stage → Type
  | .delta b => ResidualDeltaDecodeRanges.Primitives b
  | .attention b => ResidualAttentionSequenceRanges.Primitives b

structure DeltaBound (cache : DeltaNet.Cache) (time : Nat) : Prop where
  history : ∀ i c, Model.isFinite (cache.history i c) = true ∧ |Model.toReal (cache.history i c)| ≤ (2 : ℝ)^(34 : Nat)
  finite : ∀ h v i, (cache.recurrent h v i).isFinite = true
  size : ∀ h v, RecurrenceStability.magnitude (fun i => real (cache.recurrent h v i)) ≤ RecurrenceEnvelope.bound time

def CacheBound : (s : Stage) → Cache s time → Prop
  | .delta _, c => DeltaBound c time
  | .attention _, c => ResidualAttentionSequenceRanges.CacheBound c

theorem cache_finite (s : Stage) (cache : Cache s time) (hc : CacheBound s cache) : DecodeStage.CacheFinite s cache := by
  cases s with
  | delta _ => exact ⟨fun i c => (hc.history i c).1, hc.finite⟩
  | attention _ => exact ResidualAttentionSequenceRanges.CacheBound.finite cache hc

theorem initial (s : Stage) : CacheBound s (InitialState.stage s) := by
  cases s with
  | delta _ =>
    change DeltaBound InitialState.delta 0
    refine ⟨?_, InitialState.delta_finite.recurrent, ?_⟩
    · intro i c
      exact ⟨InitialState.delta_finite.history i c, by simp [InitialState.delta]⟩
    · intro h v
      simp [InitialState.delta, RecurrenceStability.magnitude, RecurrenceStability.energy,
        FlushedIdentities.zero_real, RecurrenceEnvelope.zero]
  | attention _ =>
    constructor <;> intro _ t <;> exact Fin.elim0 t

noncomputable def checked (s : Stage) (parameters : Parameters s) (primitive : Primitives s)
    (index : Nat) (hs : index < 64) (cache : Cache s time) (hc : CacheBound s cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144) :
    DecodeStage.Finite s cache x angle := by
  cases s with
  | delta b =>
    exact (ResidualDeltaDecodeRanges.checked b parameters primitive index hs cache (fun _ => x)
      (fun _ => hx) hc.history hc.finite hc.size supported).finite
  | attention b =>
    exact (ResidualAttentionSequenceRanges.checked b parameters primitive index hs x hx angle ha cache hc supported).finite

theorem next_input (s : Stage) (parameters : Parameters s) (primitive : Primitives s)
    (index : Nat) (hs : index < 64) (cache : Cache s time) (hc : CacheBound s cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144) :
    ResidualMlpRanges.InputBound (index+1) (DecodeStage.forward s cache x angle) := by
  cases s with
  | delta b =>
    exact ResidualDeltaDecodeRanges.next_input b parameters primitive index hs cache (fun _ => x)
      (fun _ => hx) hc.history hc.finite hc.size supported
  | attention b =>
    exact ResidualAttentionSequenceRanges.next_input b parameters primitive index hs x hx angle ha cache hc supported

theorem output_bounded (s : Stage) (parameters : Parameters s) (primitive : Primitives s)
    (index : Nat) (hs : index < 64) (cache : Cache s time) (hc : CacheBound s cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144) :
    ∀ i, |Model.toReal (DecodeStage.forward s cache x angle i)| ≤ (2 : ℝ)^(56 : Nat) := by
  have cap : (index+1 : Nat)*(2 : ℝ)^(50 : Nat) ≤ (2 : ℝ)^(56 : Nat) := by
    have h : ((index+1 : Nat) : ℝ) ≤ 64 := by exact_mod_cast (show index+1 ≤ 64 by omega)
    push_cast at h
    norm_num
    linarith
  cases s with
  | delta b =>
    intro i
    exact ((ResidualDeltaDecodeRanges.checked b parameters primitive index hs cache (fun _ => x)
      (fun _ => hx) hc.history hc.finite hc.size supported).output i).trans cap
  | attention b =>
    intro i
    exact ((ResidualAttentionSequenceRanges.checked b parameters primitive index hs x hx angle ha cache hc supported).output i).trans cap

theorem next_cache (s : Stage) (parameters : Parameters s) (primitive : Primitives s)
    (index : Nat) (hs : index < 64) (cache : Cache s time) (hc : CacheBound s cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144) :
    CacheBound s (DecodeStage.cacheAfter s cache x angle) := by
  cases s with
  | delta b =>
    let h := ResidualDeltaDecodeRanges.checked b parameters primitive index hs cache (fun _ => x)
      (fun _ => hx) hc.history hc.finite hc.size supported
    exact ⟨h.history, fun head v => (h.recurrent head v).1, fun head v => (h.recurrent head v).2⟩
  | attention b =>
    exact (ResidualAttentionSequenceRanges.checked b parameters primitive index hs x hx angle ha cache hc supported).cacheBound

theorem accuracy (s : Stage) (parameters : Parameters s) (primitive : Primitives s)
    (index : Nat) (hs : index < 64) (cache : Cache s time) (cacheBound : CacheBound s cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144)
    (ct ce : ReferenceCache s time) (hc : CacheError s cache ct ce)
    (t e : Row ℝ) (hi : ∀ i, |Model.toReal (x i)-t i| ≤ e i)
    (aim ae : RopeAngles.Target) (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) :
    (∀ i, |Model.toReal (DecodeStage.forward s cache x angle i)-DecodeStage.target s ct t aim i| ≤
      DecodeStage.budget s cache ct ce x t e angle aim ae
        (checked s parameters primitive index hs cache cacheBound x hx angle ha supported) i) ∧
    CacheError s (DecodeStage.cacheAfter s cache x angle) (DecodeStage.targetCacheAfter s ct t aim)
      (DecodeStage.cacheBudget s cache ct ce x t e angle aim ae) := by
  cases s with
  | delta b =>
    exact ResidualDeltaDecodeRanges.accuracy b parameters primitive index hs cache (fun _ => x)
      (fun _ => hx) cacheBound.history cacheBound.finite cacheBound.size supported ct ce hc
      (fun _ => t) (fun _ => e) (fun _ => hi)
  | attention b =>
    exact ResidualAttentionSequenceRanges.accuracy b parameters primitive index hs x hx angle ha cache cacheBound supported
      t e hi aim ae he hb ct ce hc

end Inference.Models.Qwen.DecodeStageSequenceRanges
