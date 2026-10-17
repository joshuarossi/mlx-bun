import contracts.mlx.ElementwiseAdd
import contracts.mlx.HalfArrayWrites
import contracts.mlx.ArrayViews

namespace Inference.Contracts.Mlx.ElementwiseAddDevice
abbrev BF := ArrayStorage.BF

@[irreducible] def produced {left right : Fin n → BF}
    (lhs : ArrayStorage.BFBuffer left) (rhs : ArrayStorage.BFBuffer right) (i : Fin n) : BF :=
  BFloat16Arithmetic.add (lhs.read i) (rhs.read i)

theorem produced_eq {left right : Fin n → BF} (lhs : ArrayStorage.BFBuffer left) (rhs : ArrayStorage.BFBuffer right) :
    produced lhs rhs=ElementwiseAdd.forward left right := by
  funext i
  unfold produced ElementwiseAdd.forward
  rw [ArrayStorage.BFBuffer.read_correct, ArrayStorage.BFBuffer.read_correct]

-- Inputs denote the completed producer buffers, held fixed for this phase.
-- Distinct output cells can be scheduled in any order permitted by the trace.
structure Execution (left right : Fin n → BF) where
  lhs : ArrayStorage.BFBuffer left
  rhs : ArrayStorage.BFBuffer right
  stores : HalfArrayWrites.Trace 0 (fun i => ArrayStorage.bits (produced lhs rhs i))

def Execution.fromStorage (left right : Fin n → BF) (lhs : ArrayStorage.BFBuffer left)
    (rhs : ArrayStorage.BFBuffer right) (bounded : 2*n ≤ 2^64) : Execution left right :=
  ⟨lhs, rhs, HalfArrayWrites.Trace.canonical _ bounded⟩

variable {n : Nat} {left right : Fin n → BF}

def Execution.output (execution : Execution left right) : Fin n → BF := execution.stores.buffer.read
def Execution.outputBuffer (execution : Execution left right) : ArrayStorage.BFBuffer execution.output :=
  ArrayViews.readback execution.stores.buffer

theorem Execution.output_eq (execution : Execution left right) : execution.output=ElementwiseAdd.forward left right := by
  funext i
  unfold Execution.output
  rw [ArrayStorage.BFBuffer.read_correct, produced_eq]

theorem Execution.output_bytes (execution : Execution left right) :
    execution.outputBuffer.bytes=execution.stores.memory := rfl

def Execution.forwardBuffer (execution : Execution left right) : ArrayStorage.BFBuffer (ElementwiseAdd.forward left right) :=
  ArrayViews.reindex execution.output_eq execution.outputBuffer

theorem Execution.forward_bytes (execution : Execution left right) :
    execution.forwardBuffer.bytes=execution.stores.memory := ArrayViews.reindex_bytes _ _

end Inference.Contracts.Mlx.ElementwiseAddDevice
