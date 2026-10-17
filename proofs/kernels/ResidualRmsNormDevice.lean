import kernels.ResidualRmsNorm
import kernels.RmsNormDevice

namespace Inference.Kernels.ResidualRmsNormDevice
open Contracts.Mlx
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000

@[irreducible] def produced {x update : Fin n → BF} (source : ArrayStorage.BFBuffer x)
    (change : ArrayStorage.BFBuffer update) (i : Fin n) : BF := ResidualRmsNorm.residual (source.read i) (change.read i)

theorem produced_eq {x update : Fin n → BF} (source : ArrayStorage.BFBuffer x) (change : ArrayStorage.BFBuffer update) :
    produced source change=fun i => ResidualRmsNorm.residual (x i) (update i) := by
  funext i
  unfold produced
  rw [ArrayStorage.BFBuffer.read_correct, ArrayStorage.BFBuffer.read_correct]

structure Execution (p : RmsNorm.Platform) (x update weight : Fin n → BF) (width eps : Float32) where
  source : ArrayStorage.BFBuffer x
  update : ArrayStorage.BFBuffer update
  residualStores : HalfArrayWrites.Trace 0 (fun i => ArrayStorage.bits (produced source update i))
  normalization : RmsNormDevice.Execution p (produced source update) weight width eps
  normalizationInput : normalization.source=residualStores.buffer

def Execution.fromStorage (p : RmsNorm.Platform) (x update weight : Fin n → BF) (width eps : Float32)
    (source : ArrayStorage.BFBuffer x) (change : ArrayStorage.BFBuffer update) (weights : ArrayStorage.BFBuffer weight)
    (bounded : 2*n ≤ 2^64) : Execution p x update weight width eps :=
  let residualStores := HalfArrayWrites.Trace.canonical (fun i => ArrayStorage.bits (produced source change i)) bounded
  ⟨source, change, residualStores, RmsNormDevice.Execution.fromStorage p _ weight width eps residualStores.buffer weights bounded, rfl⟩

variable {n : Nat} {p : RmsNorm.Platform} {x update weight : Fin n → BF} {width eps : Float32}

def Execution.residual (execution : Execution p x update weight width eps) : Fin n → BF := execution.residualStores.buffer.read
def Execution.residualBuffer (execution : Execution p x update weight width eps) : ArrayStorage.BFBuffer execution.residual :=
  ArrayViews.readback execution.residualStores.buffer

theorem Execution.residual_eq (execution : Execution p x update weight width eps) :
    execution.residual=fun i => ResidualRmsNorm.residual (x i) (update i) := by
  funext i
  unfold Execution.residual
  rw [ArrayStorage.BFBuffer.read_correct, produced_eq]

def Execution.output (execution : Execution p x update weight width eps) : Fin n → BF := execution.normalization.output
def Execution.outputBuffer (execution : Execution p x update weight width eps) : ArrayStorage.BFBuffer execution.output := execution.normalization.outputBuffer

theorem Execution.output_eq (execution : Execution p x update weight width eps) (scratch : M1Max.WordMemory) (base : Nat) :
    execution.output=ResidualRmsNorm.normalized p x update weight width eps scratch base := by
  unfold Execution.output
  rw [execution.normalization.output_eq scratch base, produced_eq]
  rfl

theorem Execution.normalization_input_bytes (execution : Execution p x update weight width eps) :
    execution.normalization.source.bytes=execution.residualStores.memory :=
  congrArg ArrayStorage.BFBuffer.bytes execution.normalizationInput

theorem Execution.accumulation (execution : Execution p x update weight width eps) (columns : List (Fin n)) (acc : Float32) :
    columns.foldl (SquaredSum.arithmeticStep p.contracted (fun i => BFloat16.widen (execution.normalization.source.read i))) acc=
      ResidualRmsNorm.accumulate p.contracted x update columns acc := by
  have read : (fun i => BFloat16.widen (execution.normalization.source.read i))=ResidualRmsNorm.residualInput x update := by
    funext i
    rw [ArrayStorage.BFBuffer.read_correct, produced_eq]
    rfl
  rw [read, ResidualRmsNorm.accumulate_execution]

theorem launch : min 1024 (((5120+127)/128)*32)=1024 ∧ 1024/32=32 := by decide

end Inference.Kernels.ResidualRmsNormDevice
