import kernels.normalization.MlxRmsOutputSemantics

namespace Inference.Kernels.Normalization.MlxRmsOutputMemory
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange

variable {n : Nat}
def origin (threads : Nat) (positive : 0<threads) (col : Fin n) : Nat :=
  (NormalizationSchedule.owner threads positive col.val).thread.val*4
def outer (threads : Nat) (positive : 0<threads) (col : Fin n) : Nat :=
  (NormalizationSchedule.owner threads positive col.val).iteration*(threads*4)
def inner (threads : Nat) (positive : 0<threads) (col : Fin n) : Nat :=
  (NormalizationSchedule.owner threads positive col.val).element.val

theorem column_address (threads : Nat) (positive : 0<threads) (col : Fin n) :
    origin threads positive col+(outer threads positive col+inner threads positive col)=col.val := by
  have address := NormalizationSchedule.address_owner threads positive col.val
  change outer threads positive col+origin threads positive col+inner threads positive col=col.val at address
  omega

theorem local_small (threads : Nat) (positive : 0<threads) (width : n≤2^32) (col : Fin n) :
    outer threads positive col+inner threads positive col<2^32 := by
  have := column_address threads positive col
  have := col.isLt
  omega

-- Pointer adjustment is the existing owner model: row-local x/out and unit
-- weight stride. The parsed assignment below reads the current heap, including
-- donated x storage. Source loop/pointer-update refinement remains separate.
def cell (threads : Nat) (positive : 0<threads) (source weight destination : Nat)
    (inverse : M1Max.WordMemory) (inverseBase : Nat) (col : Fin n) (memory : HalfMemory.Bytes) : HalfMemory.Bytes :=
  MlxRmsOutputSemantics.result (source+2*origin threads positive col)
    (weight+2*origin threads positive col) (destination+2*origin threads positive col)
    inverse inverseBase (outer threads positive col) (inner threads positive col) memory

def sourceCell (text : String) (threads : Nat) (positive : 0<threads) (source weight destination : Nat)
    (inverse : M1Max.WordMemory) (inverseBase : Nat) (col : Fin n) (memory : HalfMemory.Bytes) : Option HalfMemory.Bytes :=
  MlxRmsOutputSemantics.executeSource text (source+2*origin threads positive col)
    (weight+2*origin threads positive col) (destination+2*origin threads positive col)
    inverse inverseBase (outer threads positive col) (inner threads positive col) memory

theorem source_cell (threads : Nat) (positive : 0<threads) (width : n≤2^32)
    (source weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (col : Fin n) (memory : HalfMemory.Bytes) :
    sourceCell MlxRmsOutputSyntax.sourceBody threads positive source weight destination inverse inverseBase col memory=
      some (cell threads positive source weight destination inverse inverseBase col memory) :=
  MlxRmsOutputSemantics.source_execution _ _ _ _ _ _ _ (local_small threads positive width col) _

theorem tail_source_cell (threads : Nat) (positive : 0<threads) (width : n≤2^32)
    (source weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (col : Fin n) (memory : HalfMemory.Bytes) :
    sourceCell MlxRmsOutputSyntax.sourceTailBody threads positive source weight destination inverse inverseBase col memory=
      some (cell threads positive source weight destination inverse inverseBase col memory) :=
  MlxRmsOutputSemantics.tail_source_execution _ _ _ _ _ _ _ (local_small threads positive width col) _

theorem cell_value (threads : Nat) (positive : 0<threads) (source weight destination : Nat)
    (inverse : M1Max.WordMemory) (inverseBase : Nat) (col : Fin n) (memory : HalfMemory.Bytes) :
    cell threads positive source weight destination inverse inverseBase col memory=
      HalfMemory.store memory (destination+2*col.val)
        (ArrayStorage.bits (RmsNormMemory.operation (inverse inverseBase)
          (Model.ofBits (HalfMemory.load memory (source+2*col.val)))
          (Model.ofBits (HalfMemory.load memory (weight+2*col.val))))) := by
  have address := column_address threads positive col
  have shifted (base : Nat) : base+2*origin threads positive col+
      2*(outer threads positive col+inner threads positive col)=base+2*col.val := by omega
  simp only [cell,MlxRmsOutputSemantics.result,shifted]

def run (threads : Nat) (positive : 0<threads) (source weight destination : Nat)
    (inverse : M1Max.WordMemory) (inverseBase : Nat) : List (Fin n) → HalfMemory.Bytes → HalfMemory.Bytes
  | [],before => before
  | col::rest,before => run threads positive source weight destination inverse inverseBase rest
      (cell threads positive source weight destination inverse inverseBase col before)

inductive Runs (threads : Nat) (positive : 0<threads) (source weight destination : Nat)
    (inverse : M1Max.WordMemory) (inverseBase : Nat) : List (Fin n) → HalfMemory.Bytes → HalfMemory.Bytes → Prop where
  | nil (before) : Runs threads positive source weight destination inverse inverseBase [] before before
  | next (sourceStep : sourceCell MlxRmsOutputSyntax.sourceBody threads positive source weight destination inverse inverseBase col before=some after)
      (rest : Runs threads positive source weight destination inverse inverseBase columns after final) :
      Runs threads positive source weight destination inverse inverseBase (col::columns) before final

theorem canonical (threads : Nat) (positive : 0<threads) (width : n≤2^32)
    (source weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (columns : List (Fin n)) (before : HalfMemory.Bytes) :
    Runs threads positive source weight destination inverse inverseBase columns before
      (run threads positive source weight destination inverse inverseBase columns before) := by
  induction columns generalizing before with
  | nil => exact .nil _
  | cons col rest ih => exact .next (source_cell _ _ width _ _ _ _ _ _ _) (ih _)

variable {values weights : Fin n → ArrayStorage.BF} (input : BinaryMemory.Input values weights)

theorem cell_eq (threads : Nat) (positive : 0<threads) (destination : Nat)
    (inverse : M1Max.WordMemory) (inverseBase : Nat) (col : Fin n) (before : HalfMemory.Bytes) :
    cell threads positive input.lhs.base input.rhs.base (2*destination) inverse inverseBase col before=
      HalfMemory.store before (2*(BinaryMemory.kernel input (RmsNormMemory.operation (inverse inverseBase)) destination).destination col)
        (ElementwiseMemory.result (BinaryMemory.kernel input (RmsNormMemory.operation (inverse inverseBase)) destination) before col) := by
  have left : 2*(input.lhs.base/2+col.val)=input.lhs.base+2*col.val := by have := input.lhs.aligned; omega
  have right : 2*(input.rhs.base/2+col.val)=input.rhs.base+2*col.val := by have := input.rhs.aligned; omega
  rw [cell_value]
  simp only [BinaryMemory.kernel,ElementwiseMemory.contiguous,ElementwiseMemory.result,BinaryMemory.bases,
    Fin.val_zero,ite_true,Fin.val_one,Nat.one_ne_zero,ite_false,left,right]
  congr 1
  omega

theorem run_eq (threads : Nat) (positive : 0<threads) (destination : Nat)
    (inverse : M1Max.WordMemory) (inverseBase : Nat) (columns : List (Fin n)) (before : HalfMemory.Bytes) :
    run threads positive input.lhs.base input.rhs.base (2*destination) inverse inverseBase columns before=
      ElementwiseMemory.execute (BinaryMemory.kernel input (RmsNormMemory.operation (inverse inverseBase)) destination) columns before := by
  induction columns generalizing before with
  | nil => rfl
  | cons col rest ih =>
    rw [run,ElementwiseMemory.execute,←cell_eq input threads positive destination inverse inverseBase col before]
    exact ih _

theorem refines_existing (threads : Nat) (positive : 0<threads) {factor : Float32}
    (existing : BinaryMemory.Execution input (RmsNormMemory.operation factor))
    (inverse : M1Max.WordMemory) (inverseBase : Nat) (factorRead : inverse inverseBase=factor) :
    run threads positive input.lhs.base input.rhs.base (2*existing.base) inverse inverseBase
      existing.trace.schedule input.lhs.bytes=existing.trace.memory := by
  rw [run_eq input,factorRead]
  rw [ElementwiseMemory.Trace.memory,existing.initial]

theorem checked_existing (threads : Nat) (positive : 0<threads) (width : n≤2^32) {factor : Float32}
    (existing : BinaryMemory.Execution input (RmsNormMemory.operation factor))
    (inverse : M1Max.WordMemory) (inverseBase : Nat) (factorRead : inverse inverseBase=factor) :
    Runs threads positive input.lhs.base input.rhs.base (2*existing.base) inverse inverseBase
      existing.trace.schedule input.lhs.bytes existing.trace.memory := by
  rw [←refines_existing input threads positive existing inverse inverseBase factorRead]
  exact canonical threads positive width _ _ _ _ _ _ _

-- Read the inverse from the existing RMS execution's completed byte buffer;
-- the caller does not supply a factor value or output-memory equality.
def inverseWords {platform : RmsNorm.Platform} {size eps : Float32}
    (existing : RmsNormMemory.Execution input platform size eps) : M1Max.WordMemory :=
  fun word => FloatMemory.load existing.inverse.memory (4*word)

theorem checked_rms (threads : Nat) (positive : 0<threads) (width : n≤2^32)
    {platform : RmsNorm.Platform} {size eps : Float32}
    (existing : RmsNormMemory.Execution input platform size eps) :
    Runs threads positive input.lhs.base input.rhs.base (2*existing.normalized.base)
      (inverseWords input existing) 0 existing.normalized.trace.schedule
      input.lhs.bytes existing.normalized.trace.memory := by
  apply checked_existing input threads positive width existing.normalized
  exact existing.factorRead.symm

end Inference.Kernels.Normalization.MlxRmsOutputMemory
