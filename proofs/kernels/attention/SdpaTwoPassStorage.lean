import kernels.attention.SdpaTwoPassVector

namespace Inference.Kernels.Attention.SdpaTwoPassStorage
open Contracts.Mlx Contracts.Mlx.Numerics SdpaTwoPassLayout
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

-- Separate logical arrays for the two FP32 summaries and BF16 partials.
-- A permutation of the complete write schedule represents completion of
-- the first kernel before the second reads; native synchronization remains
-- an execution premise, not a consequence of these logical-array lemmas.
def summaries (positive : 0 < blocks) (values : Fin 24 → Fin blocks → α)
    (before : Nat → α) (schedule : List Nat) : Nat → α :=
  Memory.writeCells (fun j => values ⟨j/blocks%24, Nat.mod_lt _ (by decide)⟩
    ⟨j%blocks, Nat.mod_lt _ positive⟩) schedule before
def partials (positive : 0 < blocks) (values : Fin 24 → Fin blocks → Fin 256 → α)
    (before : Nat → α) (schedule : List Nat) : Nat → α :=
  Memory.writeCells (fun j => values ⟨j/256/blocks%24, Nat.mod_lt _ (by decide)⟩
    ⟨j/256%blocks, Nat.mod_lt _ positive⟩ ⟨j%256, Nat.mod_lt _ (by decide)⟩) schedule before

theorem summary_read (positive : 0 < blocks) (values : Fin 24 → Fin blocks → α)
    (before : Nat → α) (schedule : List Nat) (complete : schedule.Perm (List.range (24*blocks)))
    (head : Fin 24) (block : Fin blocks) :
    summaries positive values before schedule (summaryAddress blocks head block) = values head block := by
  have member := complete.mem_iff.mpr (List.mem_range.mpr (summary_bounds blocks head block))
  unfold summaries
  rw [Memory.writeCells_read, ite_eq_left member]
  simp only [(summary_inverse blocks head block).1, (summary_inverse blocks head block).2, Nat.mod_eq_of_lt head.isLt]

theorem partial_inverse (blocks : Nat) (head : Fin 24) (block : Fin blocks) (i : Fin 256) :
    partialAddress blocks head block i/256 = summaryAddress blocks head block ∧
      partialAddress blocks head block i%256 = i.val := by
  have hi := i.isLt
  unfold partialAddress
  omega

theorem partial_read (positive : 0 < blocks) (values : Fin 24 → Fin blocks → Fin 256 → α)
    (before : Nat → α) (schedule : List Nat) (complete : schedule.Perm (List.range (24*blocks*256)))
    (head : Fin 24) (block : Fin blocks) (i : Fin 256) :
    partials positive values before schedule (partialAddress blocks head block i) = values head block i := by
  have member := complete.mem_iff.mpr (List.mem_range.mpr (partial_bounds blocks head block i))
  unfold partials
  rw [Memory.writeCells_read, ite_eq_left member]
  simp only [(partial_inverse blocks head block i).1, (partial_inverse blocks head block i).2,
    (summary_inverse blocks head block).1, (summary_inverse blocks head block).2, Nat.mod_eq_of_lt head.isLt]

theorem summary_frame (positive : 0 < blocks) (values : Fin 24 → Fin blocks → α)
    (before : Nat → α) (schedule : List Nat) (complete : schedule.Perm (List.range (24*blocks)))
    (j : Nat) (outside : 24*blocks ≤ j) : summaries positive values before schedule j = before j := by
  unfold summaries
  rw [Memory.writeCells_read, ite_eq_right (fun h => by have := List.mem_range.mp (complete.mem_iff.mp h); omega)]
theorem partial_frame (positive : 0 < blocks) (values : Fin 24 → Fin blocks → Fin 256 → α)
    (before : Nat → α) (schedule : List Nat) (complete : schedule.Perm (List.range (24*blocks*256)))
    (j : Nat) (outside : 24*blocks*256 ≤ j) : partials positive values before schedule j = before j := by
  unfold partials
  rw [Memory.writeCells_read, ite_eq_right (fun h => by have := List.mem_range.mp (complete.mem_iff.mp h); omega)]

def readState (maxima sums : Nat → Float32) (values : Nat → BF)
    (head : Fin 24) (block : Fin blocks) (i : Fin 256) : SdpaUpdate.State :=
  ⟨maxima (summaryAddress blocks head block), sums (summaryAddress blocks head block),
    BFloat16.widen (values (partialAddress blocks head block i))⟩

theorem first_to_second (p : SdpaVector.Platform) (positive : 0 < blocks)
    (query : Fin 24 → Fin 256 → BF) (keys values : Fin 4 → Fin steps → Fin 256 → BF)
    (maxBefore sumBefore : Nat → Float32) (partialBefore : Nat → BF)
    (maxSchedule sumSchedule partialSchedule : List Nat)
    (maxComplete : maxSchedule.Perm (List.range (24*blocks)))
    (sumComplete : sumSchedule.Perm (List.range (24*blocks)))
    (partialComplete : partialSchedule.Perm (List.range (24*blocks*256)))
    (head : Fin 24) (block : Fin blocks) (i : Fin 256) :
    readState
      (summaries positive (fun h b => (SdpaTwoPassFirstPass.raw p (query h) (keys (SdpaScore.kvHead h))
        (values (SdpaScore.kvHead h)) 0 b).shift) maxBefore maxSchedule)
      (summaries positive (fun h b => (SdpaTwoPassFirstPass.raw p (query h) (keys (SdpaScore.kvHead h))
        (values (SdpaScore.kvHead h)) 0 b).denominator) sumBefore sumSchedule)
      (partials positive (fun h b c => SdpaTwoPassFirstPass.stored p (query h) (keys (SdpaScore.kvHead h))
        (values (SdpaScore.kvHead h)) c b) partialBefore partialSchedule) head block i =
      SdpaTwoPassVector.partials p (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head)) i block := by
  unfold readState
  rw [summary_read positive _ maxBefore maxSchedule maxComplete, summary_read positive _ sumBefore sumSchedule sumComplete,
    partial_read positive _ partialBefore partialSchedule partialComplete]
  have shared := SdpaTwoPassFirstPass.shared p (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head)) 0 i block
  change (SdpaTwoPassFirstPass.raw _ _ _ _ 0 block).shift = (SdpaTwoPassFirstPass.raw _ _ _ _ i block).shift ∧
    (SdpaTwoPassFirstPass.raw _ _ _ _ 0 block).denominator = (SdpaTwoPassFirstPass.raw _ _ _ _ i block).denominator at shared
  rw [shared.1, shared.2]
  rfl

-- The second kernel also transposes the 32 by 32 numerator scratch array.
-- This is the same proved cell mapping as the one-pass transpose, now fed
-- by each group's ordered block accumulation instead of an online partial.
def secondScratch (lanes : Fin 32 → Fin 32 → Float32) (before : Nat → Float32)
    (schedule : List Nat) (group : Fin 32) (reduce : (Fin 32 → Float32) → Float32) : Float32 :=
  reduce (fun lane => SdpaLayout.stored lanes before schedule (group.val*32+lane.val))
theorem second_scratch_read (lanes : Fin 32 → Fin 32 → Float32) (before : Nat → Float32)
    (schedule : List Nat) (complete : schedule.Perm (List.range 1024))
    (group : Fin 32) (reduce : (Fin 32 → Float32) → Float32) :
    secondScratch lanes before schedule group reduce = reduce (fun lane => lanes lane group) := by
  unfold secondScratch
  apply congrArg reduce
  funext lane
  exact SdpaLayout.scratch_read lanes before schedule complete group lane

end Inference.Kernels.Attention.SdpaTwoPassStorage
