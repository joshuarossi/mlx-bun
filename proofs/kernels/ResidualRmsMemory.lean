import kernels.ResidualRmsNorm
import contracts.mlx.BinaryMemory
import contracts.mlx.RmsScratch
import contracts.mlx.ArrayFrame

namespace Inference.Kernels.ResidualRmsMemory
open Contracts.Mlx
set_option maxRecDepth 10000
abbrev BF := ArrayStorage.BF

variable {n : Nat} {left right weight : Fin n → BF} {input : BinaryMemory.Input left right}

structure Residual (input : BinaryMemory.Input left right) (weight : Fin n → BF) where
  addition : BinaryMemory.Execution input ResidualRmsNorm.residual
  weights : ArrayStorage.BFBuffer weight
  shared : weights.bytes=input.lhs.bytes
  weightsSeparate : MemoryRegions.Disjoint (2*addition.base) (2*n) weights.base (2*n)

def Residual.weightsAfter (residual : Residual input weight) : ArrayStorage.BFBuffer weight :=
  ArrayFrame.bf residual.weights residual.addition.trace.memory (by
    intro offset bound
    exact (residual.addition.other_region residual.weightsSeparate offset bound).trans
      (congrFun residual.shared (residual.weights.base+offset)).symm)

def Residual.normalizationInput (residual : Residual input weight) :
    BinaryMemory.Input (fun i => ResidualRmsNorm.residual (left i) (right i)) weight :=
  ⟨residual.addition.buffer, residual.weightsAfter, rfl⟩

def Residual.sourceValues (residual : Residual input weight) (i : Fin n) : Float32 := BFloat16.widen (residual.addition.buffer.read i)

theorem Residual.sourceValues_eq (residual : Residual input weight) :
    residual.sourceValues=ResidualRmsNorm.residualInput left right := by
  funext i
  unfold Residual.sourceValues
  rw [ArrayStorage.BFBuffer.read_correct]
  rfl

def operation (factor : Float32) (value weight : BF) : BF :=
  BFloat16Arithmetic.mul weight (BFloat16.narrow (FlushToZero.mul (BFloat16.widen value) factor))

attribute [local irreducible] operation Residual.sourceValues
  RmsScratch.Trace.factor BinaryMemory.kernel

-- sums[] and inv[] are threadgroup storage. Their existing scratch traces
-- use a separate address space from the evolving device heap below.
structure Execution (residual : Residual input weight) (p : RmsNorm.Platform) (width eps : Float32) where
  scratch : RmsScratch.Trace p residual.sourceValues
  inverse : FloatArrayWrites.Trace 0 (fun _ : Fin 1 => scratch.factor width eps)
  factor : Float32
  factorRead : factor=inverse.buffer.read 0
  normalized : BinaryMemory.Execution residual.normalizationInput (operation factor)
  residualSeparate : MemoryRegions.Disjoint (2*normalized.base) (2*n) (2*residual.addition.base) (2*n)
  weightsSeparate : MemoryRegions.Disjoint (2*normalized.base) (2*n) residual.weights.base (2*n)

variable {residual : Residual input weight} {p : RmsNorm.Platform} {width eps : Float32}

def fromScratch (residual : Residual input weight) (p : RmsNorm.Platform) (width eps : Float32)
    (scratch : RmsScratch.Trace p residual.sourceValues)
    (inverse : FloatArrayWrites.Trace 0 (fun _ : Fin 1 => scratch.factor width eps))
    (base : Nat) (bounded : 2*base+2*n ≤ 2^64)
    (residualSeparate : MemoryRegions.Disjoint (2*base) (2*n) (2*residual.addition.base) (2*n))
    (weightsSeparate : MemoryRegions.Disjoint (2*base) (2*n) residual.weights.base (2*n)) : Execution residual p width eps :=
  ⟨scratch, inverse, inverse.buffer.read 0, rfl,
    BinaryMemory.fromBuffers residual.normalizationInput (operation (inverse.buffer.read 0)) base bounded
      (Or.inr (MemoryRegions.disjoint_symm residualSeparate)) (Or.inr (MemoryRegions.disjoint_symm weightsSeparate)),
    residualSeparate, weightsSeparate⟩

def canonical (residual : Residual input weight) (p : RmsNorm.Platform) (width eps : Float32)
    (base : Nat) (bounded : 2*base+2*n ≤ 2^64)
    (residualSeparate : MemoryRegions.Disjoint (2*base) (2*n) (2*residual.addition.base) (2*n))
    (weightsSeparate : MemoryRegions.Disjoint (2*base) (2*n) residual.weights.base (2*n)) : Execution residual p width eps :=
  let scratch := RmsScratch.Trace.canonical p residual.sourceValues
  fromScratch residual p width eps scratch (FloatArrayWrites.Trace.canonical _ (by decide)) base bounded residualSeparate weightsSeparate

def Execution.output (execution : Execution residual p width eps) : Fin n → BF := execution.normalized.buffer.read

def Execution.outputBuffer (execution : Execution residual p width eps) : ArrayStorage.BFBuffer execution.output :=
  ArrayViews.readback execution.normalized.buffer

theorem Execution.factor_eq (execution : Execution residual p width eps) (before : M1Max.WordMemory) (base : Nat) :
    execution.factor=RmsNorm.inverse p (ResidualRmsNorm.residualInput left right) width eps before base := by
  rw [execution.factorRead, ArrayStorage.FloatBuffer.read_correct, execution.scratch.factor_eq width eps before base, residual.sourceValues_eq]

theorem Execution.output_eq (execution : Execution residual p width eps) (before : M1Max.WordMemory) (base : Nat) :
    execution.output=ResidualRmsNorm.normalized p left right weight width eps before base := by
  funext i
  unfold Execution.output
  rw [ArrayStorage.BFBuffer.read_correct, execution.factor_eq before base]
  unfold operation
  rfl

def Execution.residualBuffer (execution : Execution residual p width eps) :
    ArrayStorage.BFBuffer (fun i => ResidualRmsNorm.residual (left i) (right i)) :=
  ArrayFrame.bf residual.addition.buffer execution.normalized.trace.memory
    (execution.normalized.other_region execution.residualSeparate)

def Execution.weightsBuffer (execution : Execution residual p width eps) : ArrayStorage.BFBuffer weight :=
  ArrayFrame.bf residual.weightsAfter execution.normalized.trace.memory
    (execution.normalized.other_region execution.weightsSeparate)

theorem Execution.residual_shared (execution : Execution residual p width eps) :
    execution.residualBuffer.bytes=execution.outputBuffer.bytes := rfl

theorem Execution.other_region (execution : Execution residual p width eps) {base size : Nat}
    (residualSeparate : MemoryRegions.Disjoint (2*residual.addition.base) (2*n) base size)
    (normalizedSeparate : MemoryRegions.Disjoint (2*execution.normalized.base) (2*n) base size)
    (offset : Nat) (bound : offset<size) :
    execution.outputBuffer.bytes (base+offset)=input.lhs.bytes (base+offset) :=
  (execution.normalized.other_region normalizedSeparate offset bound).trans
    (residual.addition.other_region residualSeparate offset bound)

theorem accumulation (residual : Residual input weight) (contracted : Bool) (columns : List (Fin n)) (acc : Float32) :
    columns.foldl (SquaredSum.arithmeticStep contracted residual.sourceValues) acc=
      ResidualRmsNorm.accumulate contracted left right columns acc := by
  rw [residual.sourceValues_eq]
  rfl

end Inference.Kernels.ResidualRmsMemory
