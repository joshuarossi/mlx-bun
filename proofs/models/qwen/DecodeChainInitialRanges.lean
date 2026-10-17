import models.qwen.DecodeStageInitialRanges

namespace Inference.Models.Qwen.DecodeChainInitialRanges
open Contracts.Mlx Contracts.Mlx.Numerics DecodeStage Kernels.Attention
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

def Parameters : List Stage → Prop
  | [] => True
  | s::rest => DecodeStageInitialRanges.Parameters s ∧ Parameters rest
def Primitives : List Stage → Type
  | [] => PUnit
  | s::rest => DecodeStageInitialRanges.Primitives s × Primitives rest

noncomputable def ranges : (stages : List Stage) → Parameters stages → Primitives stages →
    (index : Nat) → index + stages.length ≤ 64 → (x : Row BF) → ResidualMlpRanges.InputBound index x →
    (angle : RopeAngles.Inputs) → RopeAnglesRanges.InputsBound angle → real angle.position = 0 →
    DecodeChain.Ranges stages (InitialState.caches stages) x angle
  | [], _, _, _, _, _, _, _, _, _ => ⟨⟩
  | s::rest, parameters, primitive, index, size, x, hx, angle, ha, position =>
    let hs : index < 64 := by simp only [List.length_cons] at size; omega
    let ht : index+1+rest.length ≤ 64 := by simp only [List.length_cons] at size; omega
    ⟨DecodeStageInitialRanges.checked s parameters.1 primitive.1 index hs x hx angle ha position,
      ranges rest parameters.2 primitive.2 (index+1) ht (DecodeStage.forward s (InitialState.stage s) x angle)
        (DecodeStageInitialRanges.next_input s parameters.1 primitive.1 index hs x hx angle ha position) angle ha position⟩

theorem next_input (stages : List Stage) (parameters : Parameters stages) (primitive : Primitives stages)
    (index : Nat) (size : index + stages.length ≤ 64) (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (position : real angle.position = 0) :
    ResidualMlpRanges.InputBound (index + stages.length) (DecodeChain.run stages (InitialState.caches stages) x angle).1 := by
  induction stages generalizing index x with
  | nil => exact hx
  | cons s rest ih =>
    have hs : index < 64 := by simp only [List.length_cons] at size; omega
    have ht : index+1+rest.length ≤ 64 := by simp only [List.length_cons] at size; omega
    have hn := DecodeStageInitialRanges.next_input s parameters.1 primitive.1 index hs x hx angle ha position
    have h := ih parameters.2 primitive.2 (index+1) ht (DecodeStage.forward s (InitialState.stage s) x angle) hn
    simpa only [DecodeChain.run, InitialState.caches, List.length_cons,
      show index+1+rest.length = index+(rest.length+1) from by omega] using h

theorem output_bounded (stages : List Stage) (parameters : Parameters stages) (primitive : Primitives stages)
    (index : Nat) (size : index + stages.length ≤ 64) (nonempty : stages ≠ [])
    (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (position : real angle.position = 0) :
    ∀ i, |Model.toReal ((DecodeChain.run stages (InitialState.caches stages) x angle).1 i)| ≤ (2 : ℝ)^(56 : Nat) := by
  induction stages generalizing index x with
  | nil => exact False.elim (nonempty rfl)
  | cons s rest ih =>
    have hs : index < 64 := by simp only [List.length_cons] at size; omega
    have ht : index+1+rest.length ≤ 64 := by simp only [List.length_cons] at size; omega
    by_cases empty : rest = []
    · subst rest
      exact DecodeStageInitialRanges.output_bounded s parameters.1 primitive.1 index hs x hx angle ha position
    · exact ih parameters.2 primitive.2 (index+1) ht empty (DecodeStage.forward s (InitialState.stage s) x angle)
        (DecodeStageInitialRanges.next_input s parameters.1 primitive.1 index hs x hx angle ha position)

-- Derive the software range certificates from parameters and the incoming
-- invariant, then compose the numerical and returned-cache proofs. No
-- intermediate finiteness or error-dependent residual capacity is assumed.
theorem run_correct (stages : List Stage) (parameters : Parameters stages) (primitive : Primitives stages)
    (index : Nat) (size : index + stages.length ≤ 64) (x : Row BF) (hx : ResidualMlpRanges.InputBound index x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (position : real angle.position = 0)
    (ct ce : DecodeChain.ReferenceCaches stages 0) (hc : DecodeChain.CacheErrors stages (InitialState.caches stages) ct ce)
    (t e : Row ℝ) (hi : ∀ i, |Model.toReal (x i)-t i| ≤ e i)
    (aim ae : RopeAngles.Target) (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) :
    (∀ i, |Model.toReal ((DecodeChain.run stages (InitialState.caches stages) x angle).1 i)-
        (DecodeChain.targetRun stages ct t aim).1 i| ≤
      (DecodeChain.budgetRun stages (InitialState.caches stages) ct ce x t e angle aim ae
        (ranges stages parameters primitive index size x hx angle ha position)).1 i) ∧
    DecodeChain.CacheErrors stages (DecodeChain.run stages (InitialState.caches stages) x angle).2
      (DecodeChain.targetRun stages ct t aim).2
      (DecodeChain.budgetRun stages (InitialState.caches stages) ct ce x t e angle aim ae
        (ranges stages parameters primitive index size x hx angle ha position)).2 ∧
    (∀ i, Model.isFinite ((DecodeChain.run stages (InitialState.caches stages) x angle).1 i) = true) ∧
    DecodeChain.CachesFinite stages (DecodeChain.run stages (InitialState.caches stages) x angle).2 := by
  induction stages generalizing index x t e with
  | nil => exact ⟨hi, trivial, fun i => (hx i).1, trivial⟩
  | cons s rest ih =>
    have hs : index < 64 := by simp only [List.length_cons] at size; omega
    have ht : index+1+rest.length ≤ 64 := by simp only [List.length_cons] at size; omega
    let hf := DecodeStageInitialRanges.checked s parameters.1 primitive.1 index hs x hx angle ha position
    have hn := DecodeStageInitialRanges.next_input s parameters.1 primitive.1 index hs x hx angle ha position
    have layer := DecodeStageInitialRanges.accuracy s parameters.1 primitive.1 index hs x hx angle ha position
      ct.1 ce.1 hc.1 t e hi aim ae he hb
    have tail := ih parameters.2 primitive.2 (index+1) ht (DecodeStage.forward s (InitialState.stage s) x angle) hn
      ct.2 ce.2 hc.2 (DecodeStage.target s ct.1 t aim)
      (DecodeStage.budget s (InitialState.stage s) ct.1 ce.1 x t e angle aim ae hf) layer.1
    exact ⟨tail.1, ⟨layer.2, tail.2.1⟩, tail.2.2.1,
      ⟨DecodeStage.cache_finite s (InitialState.stage s) x angle (InitialState.stage_finite s) hf, tail.2.2.2⟩⟩

end Inference.Models.Qwen.DecodeChainInitialRanges
