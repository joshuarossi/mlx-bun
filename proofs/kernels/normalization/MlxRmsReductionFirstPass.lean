import kernels.normalization.MlxRmsReductionCell

namespace Inference.Kernels.Normalization.MlxRmsReductionFirstPass
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open MlxRmsLoopControl (count)
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange NormalizationSchedule.threadColumns

variable {values weight : Fin count → ArrayStorage.BF} (input : BinaryMemory.Input values weight)

def selectedText (threads : Nat) (positive : 0<threads) (col : Fin count) : String :=
  if MlxRmsOutputMemory.outer threads positive col+MlxRmsOutputMemory.origin threads positive col+4≤count
    then MlxRmsReductionCell.sourceBody else MlxRmsReductionCell.sourceTailBody

def cell (contracted : Bool) (threads : Nat) (positive : 0<threads) (col : Fin count) (acc : Float32) : Option Float32 := do
  let owner := NormalizationSchedule.owner threads positive col.val
  let x ←MlxRmsPointerSource.execute MlxRmsPointerSource.sourceX "x" input.lhs.base 0 count owner.thread.val 1
  MlxRmsReductionCell.executeSource (selectedText threads positive col) contracted x
    (MlxRmsOutputMemory.outer threads positive col) (MlxRmsOutputMemory.inner threads positive col) acc input.lhs.bytes

theorem cell_execution (contracted : Bool) (threads : Nat) (positive : 0<threads) (col : Fin count) (acc : Float32) :
    cell input contracted threads positive col acc=
      some (SquaredSum.arithmeticStep contracted (RmsNormMemory.sourceValues input) acc col) := by
  have width : count≤2^32 := by decide
  have pointers := MlxRmsPointerSource.buffer_pointers input threads positive width col
  have small := MlxRmsOutputMemory.local_small threads positive width col
  have address := MlxRmsOutputMemory.column_address threads positive col
  have shifted : input.lhs.base+2*MlxRmsOutputMemory.origin threads positive col+
      2*(MlxRmsOutputMemory.outer threads positive col+MlxRmsOutputMemory.inner threads positive col)=
      input.lhs.base+2*col.val := by omega
  dsimp only [cell]
  dsimp only at pointers
  rw [pointers.1]
  change MlxRmsReductionCell.executeSource (selectedText threads positive col) contracted
    (input.lhs.base+2*MlxRmsOutputMemory.origin threads positive col)
    (MlxRmsOutputMemory.outer threads positive col) (MlxRmsOutputMemory.inner threads positive col) acc input.lhs.bytes=_
  unfold selectedText
  split
  · rw [MlxRmsReductionCell.source_execution _ _ _ _ small]
    simp only [shifted,MlxRmsReductionCell.step,SquaredSum.arithmeticStep,RmsNormMemory.sourceValues,ArrayStorage.BFBuffer.read]
  · rw [MlxRmsReductionCell.tail_source_execution _ _ _ _ small]
    simp only [shifted,MlxRmsReductionCell.step,SquaredSum.arithmeticStep,RmsNormMemory.sourceValues,ArrayStorage.BFBuffer.read]

def run (contracted : Bool) (threads : Nat) (positive : 0<threads) : List (Fin count) → Float32 → Option Float32
  | [],acc => some acc
  | col::rest,acc => do run contracted threads positive rest (←cell input contracted threads positive col acc)

theorem run_execution (contracted : Bool) (threads : Nat) (positive : 0<threads)
    (columns : List (Fin count)) (acc : Float32) :
    run input contracted threads positive columns acc=
      some (columns.foldl (SquaredSum.arithmeticStep contracted (RmsNormMemory.sourceValues input)) acc) := by
  induction columns generalizing acc with
  | nil => rfl
  | cons col rest ih => rw [run,cell_execution input]; exact ih _

def executeThread (contracted : Bool) (threads : Nat) (positive : 0<threads) (thread : Fin threads) : Option Float32 := do
  let columns ←MlxRmsLoopControl.executeSource MlxRmsLoopSyntax.sourceBody threads thread
  run input contracted threads positive columns 0

theorem thread_execution (contracted : Bool) (threads : Nat) (positive : 0<threads) (thread : Fin threads) :
    executeThread input contracted threads positive thread=
      some (NormalizationReduction.threadSum contracted (RmsNormMemory.sourceValues input) thread) := by
  unfold executeThread
  rw [MlxRmsLoopControl.source_columns threads positive thread]
  exact run_execution input contracted threads positive _ 0

-- These register values are constructed folds of source-read BF16 values.
-- The theorem above establishes each fold by parsing both loop and cell text.
def locals (contracted : Bool) (threads : Nat) : Fin threads → Float32 :=
  NormalizationReduction.threadSum contracted (RmsNormMemory.sourceValues input)

theorem checked_locals (contracted : Bool) (threads : Nat) (positive : 0<threads) :
    ∀ thread, executeThread input contracted threads positive thread=some (locals input contracted threads thread) :=
  thread_execution input contracted threads positive

end Inference.Kernels.Normalization.MlxRmsReductionFirstPass
