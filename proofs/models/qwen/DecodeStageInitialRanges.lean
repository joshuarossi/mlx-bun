import models.qwen.InitialState
import models.qwen.ResidualDeltaInitialRanges
import models.qwen.ResidualAttentionInitialRanges

namespace Inference.Models.Qwen.DecodeStageInitialRanges
open Contracts.Mlx Contracts.Mlx.Numerics DecodeStage Kernels.Attention
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

def Parameters : Stage → Prop
  | .delta b => ResidualDeltaInitialRanges.Parameters b
  | .attention b => ResidualAttentionInitialRanges.Parameters b
def Primitives : Stage → Type
  | .delta b => ResidualDeltaInitialRanges.Primitives b
  | .attention b => ResidualAttentionInitialRanges.Primitives b

theorem zero_history : ∀ i c, Model.isFinite (InitialState.delta.history i c) = true ∧
    |Model.toReal (InitialState.delta.history i c)| ≤ (2 : ℝ)^(34 : Nat) := by
  intro i c
  exact ⟨InitialState.delta_finite.history i c, by simp [InitialState.delta]⟩
theorem zero_recurrent : ∀ h v i, (InitialState.delta.recurrent h v i).isFinite = true ∧
    |real (InitialState.delta.recurrent h v i)| ≤ 1 := by
  intro h v i
  exact ⟨InitialState.delta_finite.recurrent h v i, by simp [InitialState.delta, FlushedIdentities.zero_real]⟩

noncomputable def checked (s : Stage) (parameters : Parameters s) (primitive : Primitives s)
    (index : Nat) (hs : index < 64) (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (position : real angle.position = 0) :
    DecodeStage.Finite s (InitialState.stage s) x angle := by
  cases s with
  | delta b =>
      exact (ResidualDeltaInitialRanges.checked b parameters primitive index hs InitialState.delta
        (fun _ => x) (fun _ => hx) zero_history zero_recurrent).finite
  | attention b =>
      exact (ResidualAttentionInitialRanges.checked b parameters primitive index hs x hx
        angle ha position (InitialState.emptyKv BF)).finite

theorem next_input (s : Stage) (parameters : Parameters s) (primitive : Primitives s)
    (index : Nat) (hs : index < 64) (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (position : real angle.position = 0) :
    ResidualMlpRanges.InputBound (index+1) (DecodeStage.forward s (InitialState.stage s) x angle) := by
  cases s with
  | delta b =>
      exact ResidualDeltaInitialRanges.next_input b parameters primitive index hs InitialState.delta
        (fun _ => x) (fun _ => hx) zero_history zero_recurrent
  | attention b =>
      exact ResidualAttentionInitialRanges.next_input b parameters primitive index hs x hx
        angle ha position (InitialState.emptyKv BF)

theorem output_bounded (s : Stage) (parameters : Parameters s) (primitive : Primitives s)
    (index : Nat) (hs : index < 64) (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (position : real angle.position = 0) :
    ∀ i, |Model.toReal (DecodeStage.forward s (InitialState.stage s) x angle i)| ≤ (2 : ℝ)^(56 : Nat) := by
  have cap : (index+1 : Nat) * (2 : ℝ)^(50 : Nat) ≤ (2 : ℝ)^(56 : Nat) := by
    have h : ((index+1 : Nat) : ℝ) ≤ 64 := by exact_mod_cast (show index+1 ≤ 64 by omega)
    push_cast at h
    norm_num
    linarith
  cases s with
  | delta b =>
    intro i
    exact ((ResidualDeltaInitialRanges.checked b parameters primitive index hs InitialState.delta
      (fun _ => x) (fun _ => hx) zero_history zero_recurrent).output i).trans cap
  | attention b =>
    intro i
    exact ((ResidualAttentionInitialRanges.checked b parameters primitive index hs x hx
      angle ha position (InitialState.emptyKv BF)).output i).trans cap

theorem accuracy (s : Stage) (parameters : Parameters s) (primitive : Primitives s)
    (index : Nat) (hs : index < 64) (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (position : real angle.position = 0)
    (ct ce : ReferenceCache s 0) (hc : CacheError s (InitialState.stage s) ct ce)
    (t e : Row ℝ) (hi : ∀ i, |Model.toReal (x i)-t i| ≤ e i)
    (aim ae : RopeAngles.Target) (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) :
    (∀ i, |Model.toReal (DecodeStage.forward s (InitialState.stage s) x angle i)-DecodeStage.target s ct t aim i| ≤
      DecodeStage.budget s (InitialState.stage s) ct ce x t e angle aim ae (checked s parameters primitive index hs x hx angle ha position) i) ∧
    CacheError s (DecodeStage.cacheAfter s (InitialState.stage s) x angle) (DecodeStage.targetCacheAfter s ct t aim)
      (DecodeStage.cacheBudget s (InitialState.stage s) ct ce x t e angle aim ae) := by
  cases s with
  | delta b =>
      exact ResidualDeltaInitialRanges.accuracy b parameters primitive index hs InitialState.delta
        (fun _ => x) (fun _ => hx) zero_history zero_recurrent ct ce hc (fun _ => t) (fun _ => e) (fun _ => hi)
  | attention b =>
      exact ResidualAttentionInitialRanges.accuracy b parameters primitive index hs x hx
        angle ha position (InitialState.emptyKv BF) t e hi aim ae he hb ct ce hc

end Inference.Models.Qwen.DecodeStageInitialRanges
