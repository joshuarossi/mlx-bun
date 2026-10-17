import kernels.normalization.ResidualRmsOutputSemantics

namespace Inference.Kernels.Normalization.ResidualRmsOutputMemory
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open ResidualRmsCellSemantics (count BF)
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange

def cell (residual weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (col : Fin count) (memory : HalfMemory.Bytes) : HalfMemory.Bytes :=
  (ResidualRmsOutputSemantics.finalState residual weight destination inverse inverseBase col memory).memory

def run (residual weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat) :
    List (Fin count) → HalfMemory.Bytes → HalfMemory.Bytes
  | [],before => before
  | col::rest,before => run residual weight destination inverse inverseBase rest
      (cell residual weight destination inverse inverseBase col before)

-- The schedule records logical cell order. Its physical realization and the
-- source's outer column loops remain distinct obligations. Every memory write
-- below is nevertheless derived from execution of the parsed output body.
inductive Runs (residual weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat) :
    List (Fin count) → HalfMemory.Bytes → HalfMemory.Bytes → Prop where
  | nil (before) : Runs residual weight destination inverse inverseBase [] before before
  | next (source : ResidualRmsOutputSemantics.executeSource ResidualRmsOutputSyntax.sourceBody
        residual weight destination inverse inverseBase col before=some after)
      (rest : Runs residual weight destination inverse inverseBase columns after.memory final) :
      Runs residual weight destination inverse inverseBase (col::columns) before final

theorem canonical (residual weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (columns : List (Fin count)) (before : HalfMemory.Bytes) :
    Runs residual weight destination inverse inverseBase columns before
      (run residual weight destination inverse inverseBase columns before) := by
  induction columns generalizing before with
  | nil => exact .nil _
  | cons col rest ih => exact .next (ResidualRmsOutputSemantics.source_execution _ _ _ _ _ _ _) (ih _)

variable {values weight : Fin count → BF} (input : BinaryMemory.Input values weight)

theorem cell_eq (destination : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (col : Fin count) (before : HalfMemory.Bytes) :
    cell input.lhs.base input.rhs.base (2*destination) inverse inverseBase col before=
      HalfMemory.store before (2*(BinaryMemory.kernel input (ResidualRmsMemory.operation (inverse inverseBase)) destination).destination col)
        (ElementwiseMemory.result (BinaryMemory.kernel input (ResidualRmsMemory.operation (inverse inverseBase)) destination) before col) := by
  have left : 2*(input.lhs.base/2+col.val)=input.lhs.base+2*col.val := by have := input.lhs.aligned; omega
  have right : 2*(input.rhs.base/2+col.val)=input.rhs.base+2*col.val := by have := input.rhs.aligned; omega
  change HalfMemory.store before (2*destination+2*col.val)
    (ArrayStorage.bits (ResidualRmsMemory.operation (inverse inverseBase)
      (Model.ofBits (HalfMemory.load before (input.lhs.base+2*col.val)))
      (Model.ofBits (HalfMemory.load before (input.rhs.base+2*col.val)))))=_
  simp only [BinaryMemory.kernel,ElementwiseMemory.contiguous,ElementwiseMemory.result,BinaryMemory.bases,
    Fin.val_zero,ite_true,Fin.val_one,Nat.one_ne_zero,ite_false,left,right]
  congr 1
  omega

theorem run_eq (destination : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (columns : List (Fin count)) (before : HalfMemory.Bytes) :
    run input.lhs.base input.rhs.base (2*destination) inverse inverseBase columns before=
      ElementwiseMemory.execute (BinaryMemory.kernel input (ResidualRmsMemory.operation (inverse inverseBase)) destination) columns before := by
  induction columns generalizing before with
  | nil => rfl
  | cons col rest ih => rw [run,ElementwiseMemory.execute,←cell_eq input destination inverse inverseBase col before]; exact ih _

-- This compares complete heaps, not just returned elements. It uses the
-- existing layer's constructed owner schedule and starting heap; no caller
-- supplies a parsed result or assumed equality of completed output memories.
theorem refines_existing {factor : Float32}
    (existing : BinaryMemory.Execution input (ResidualRmsMemory.operation factor))
    (inverse : M1Max.WordMemory) (inverseBase : Nat) (factorRead : inverse inverseBase=factor) :
    run input.lhs.base input.rhs.base (2*existing.base) inverse inverseBase existing.trace.schedule input.lhs.bytes=
      existing.trace.memory := by
  rw [run_eq input,factorRead]
  rw [ElementwiseMemory.Trace.memory,existing.initial]

-- All parsed source stores are constructed along that same schedule.
theorem checked_existing {factor : Float32}
    (existing : BinaryMemory.Execution input (ResidualRmsMemory.operation factor))
    (inverse : M1Max.WordMemory) (inverseBase : Nat) (factorRead : inverse inverseBase=factor) :
    Runs input.lhs.base input.rhs.base (2*existing.base) inverse inverseBase existing.trace.schedule
      input.lhs.bytes existing.trace.memory := by
  rw [←refines_existing input existing inverse inverseBase factorRead]
  exact canonical _ _ _ _ _ _ _

end Inference.Kernels.Normalization.ResidualRmsOutputMemory
