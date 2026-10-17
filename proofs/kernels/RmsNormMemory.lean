import contracts.mlx.BinaryMemory
import contracts.mlx.RmsScratch
import contracts.mlx.ArrayFrame

namespace Inference.Kernels.RmsNormMemory
open Contracts.Mlx
set_option maxRecDepth 10000
abbrev BF := ArrayStorage.BF

variable {n : Nat} {x weight : Fin n → BF}

def sourceValues (input : BinaryMemory.Input x weight) (i : Fin n) : Float32 := BFloat16.widen (input.lhs.read i)

theorem sourceValues_eq (input : BinaryMemory.Input x weight) : sourceValues input=fun i => BFloat16.widen (x i) := by
  funext i
  unfold sourceValues
  rw [ArrayStorage.BFBuffer.read_correct]

def operation (factor : Float32) (value weight : BF) : BF :=
  BFloat16Arithmetic.mul weight (BFloat16.narrow (FlushToZero.mul (BFloat16.widen value) factor))

attribute [local irreducible] operation sourceValues RmsScratch.Trace.factor BinaryMemory.kernel

-- The reduction phase reads the source before the barrier. The output
-- phase may reuse that source allocation at the same element addresses.
structure Execution (input : BinaryMemory.Input x weight) (p : RmsNorm.Platform) (width eps : Float32) where
  scratch : RmsScratch.Trace p (sourceValues input)
  inverse : FloatArrayWrites.Trace 0 (fun _ : Fin 1 => scratch.factor width eps)
  factor : Float32
  factorRead : factor=inverse.buffer.read 0
  normalized : BinaryMemory.Execution input (operation factor)
  weightsSeparate : MemoryRegions.Disjoint (2*normalized.base) (2*n) input.rhs.base (2*n)

variable {input : BinaryMemory.Input x weight} {p : RmsNorm.Platform} {width eps : Float32}

def fromScratch (input : BinaryMemory.Input x weight) (p : RmsNorm.Platform) (width eps : Float32)
    (scratch : RmsScratch.Trace p (sourceValues input))
    (inverse : FloatArrayWrites.Trace 0 (fun _ : Fin 1 => scratch.factor width eps))
    (base : Nat) (bounded : 2*base+2*n ≤ 2^64)
    (sourceSafe : input.lhs.base/2=base ∨ MemoryRegions.Disjoint input.lhs.base (2*n) (2*base) (2*n))
    (weightsSeparate : MemoryRegions.Disjoint (2*base) (2*n) input.rhs.base (2*n)) : Execution input p width eps :=
  ⟨scratch, inverse, inverse.buffer.read 0, rfl,
    BinaryMemory.fromBuffers input (operation (inverse.buffer.read 0)) base bounded sourceSafe
      (Or.inr (MemoryRegions.disjoint_symm weightsSeparate)), weightsSeparate⟩

def canonical (input : BinaryMemory.Input x weight) (p : RmsNorm.Platform) (width eps : Float32)
    (base : Nat) (bounded : 2*base+2*n ≤ 2^64)
    (sourceSafe : input.lhs.base/2=base ∨ MemoryRegions.Disjoint input.lhs.base (2*n) (2*base) (2*n))
    (weightsSeparate : MemoryRegions.Disjoint (2*base) (2*n) input.rhs.base (2*n)) : Execution input p width eps :=
  let scratch := RmsScratch.Trace.canonical p (sourceValues input)
  fromScratch input p width eps scratch (FloatArrayWrites.Trace.canonical _ (by decide)) base bounded sourceSafe weightsSeparate

def Execution.output (execution : Execution input p width eps) : Fin n → BF := execution.normalized.buffer.read

def Execution.outputBuffer (execution : Execution input p width eps) : ArrayStorage.BFBuffer execution.output :=
  ArrayViews.readback execution.normalized.buffer

theorem Execution.factor_eq (execution : Execution input p width eps) (before : M1Max.WordMemory) (base : Nat) :
    execution.factor=RmsNorm.inverse p (fun i => BFloat16.widen (x i)) width eps before base := by
  rw [execution.factorRead, ArrayStorage.FloatBuffer.read_correct, execution.scratch.factor_eq width eps before base, sourceValues_eq]

theorem Execution.output_eq (execution : Execution input p width eps) (before : M1Max.WordMemory) (base : Nat) :
    execution.output=RmsNorm.value p (fun i => BFloat16.widen (x i)) weight width eps before base := by
  funext i
  unfold Execution.output
  rw [ArrayStorage.BFBuffer.read_correct, execution.factor_eq before base]
  unfold operation
  rfl

theorem Execution.other_region (execution : Execution input p width eps) {base size : Nat}
    (separate : MemoryRegions.Disjoint (2*execution.normalized.base) (2*n) base size) (offset : Nat) (bound : offset<size) :
    execution.outputBuffer.bytes (base+offset)=input.lhs.bytes (base+offset) :=
  execution.normalized.other_region separate offset bound

def Execution.weightsAfter (execution : Execution input p width eps) : ArrayStorage.BFBuffer weight :=
  ArrayFrame.bf input.rhs execution.outputBuffer.bytes (by
    intro offset bound
    exact (execution.other_region execution.weightsSeparate offset bound).trans
      (congrFun input.shared (input.rhs.base+offset)).symm)

end Inference.Kernels.RmsNormMemory
