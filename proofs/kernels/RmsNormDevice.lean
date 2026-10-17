import contracts.mlx.RmsScratch
import contracts.mlx.HalfArrayWrites
import contracts.mlx.ArrayViews

namespace Inference.Kernels.RmsNormDevice
open Contracts.Mlx
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000

@[irreducible] def produced {x weight : Fin n → BF} {factor : Float32}
    (source : ArrayStorage.BFBuffer x) (weights : ArrayStorage.BFBuffer weight)
    (inverse : ArrayStorage.FloatBuffer (fun _ : Fin 1 => factor)) (i : Fin n) : BF :=
  BFloat16Arithmetic.mul (weights.read i)
    (BFloat16.narrow (FlushToZero.mul (BFloat16.widen (source.read i)) (inverse.read 0)))

structure Execution (p : RmsNorm.Platform) (x weight : Fin n → BF) (width eps : Float32) where
  source : ArrayStorage.BFBuffer x
  weights : ArrayStorage.BFBuffer weight
  scratch : RmsScratch.Trace p (fun i => BFloat16.widen (source.read i))
  inverse : FloatArrayWrites.Trace 0 (fun _ : Fin 1 => scratch.factor width eps)
  stores : HalfArrayWrites.Trace 0 (fun i => ArrayStorage.bits (produced source weights inverse.buffer i))

def Execution.fromStorage (p : RmsNorm.Platform) (x weight : Fin n → BF) (width eps : Float32)
    (source : ArrayStorage.BFBuffer x) (weights : ArrayStorage.BFBuffer weight) (bounded : 2*n ≤ 2^64) :
    Execution p x weight width eps :=
  let scratch := RmsScratch.Trace.canonical p (fun i => BFloat16.widen (source.read i))
  let inverse := FloatArrayWrites.Trace.canonical (fun _ : Fin 1 => scratch.factor width eps) (by decide)
  ⟨source, weights, scratch, inverse, HalfArrayWrites.Trace.canonical _ bounded⟩

variable {n : Nat} {p : RmsNorm.Platform} {x weight : Fin n → BF} {width eps : Float32}

theorem Execution.produced_eq (execution : Execution p x weight width eps) (before : M1Max.WordMemory) (base : Nat) :
    produced execution.source execution.weights execution.inverse.buffer=
      RmsNorm.value p (fun i => BFloat16.widen (x i)) weight width eps before base := by
  have inputRead : (fun i => BFloat16.widen (execution.source.read i))=(fun i => BFloat16.widen (x i)) := by
    funext i
    rw [ArrayStorage.BFBuffer.read_correct]
  funext i
  unfold produced
  rw [ArrayStorage.BFBuffer.read_correct, ArrayStorage.BFBuffer.read_correct, ArrayStorage.FloatBuffer.read_correct,
    execution.scratch.factor_eq width eps before base, inputRead]
  rfl

def Execution.output (execution : Execution p x weight width eps) : Fin n → BF := execution.stores.buffer.read
def Execution.outputBuffer (execution : Execution p x weight width eps) : ArrayStorage.BFBuffer execution.output :=
  ArrayViews.readback execution.stores.buffer

theorem Execution.output_eq (execution : Execution p x weight width eps) (before : M1Max.WordMemory) (base : Nat) :
    execution.output=RmsNorm.value p (fun i => BFloat16.widen (x i)) weight width eps before base := by
  funext i
  unfold Execution.output
  rw [ArrayStorage.BFBuffer.read_correct, execution.produced_eq before base]

def Execution.forwardBuffer (execution : Execution p x weight width eps) (before : M1Max.WordMemory) (base : Nat) :
    ArrayStorage.BFBuffer (RmsNorm.value p (fun i => BFloat16.widen (x i)) weight width eps before base) :=
  ArrayViews.reindex (execution.output_eq before base) execution.outputBuffer

theorem Execution.forward_bytes (execution : Execution p x weight width eps) (before : M1Max.WordMemory) (base : Nat) :
    (execution.forwardBuffer before base).bytes=execution.stores.memory :=
  ArrayViews.reindex_bytes _ _

theorem Execution.factor_read (execution : Execution p x weight width eps) :
    FloatMemory.load execution.inverse.memory 0=execution.scratch.factor width eps :=
  execution.inverse.read_correct 0

-- Every valid source output visit has one owner, including looped tails.
theorem output_owner (p : RmsNorm.Platform) (i : Fin n) :
    ∃! visit : NormalizationSchedule.ValidVisit (p.groups*32) n,
      NormalizationSchedule.address visit.val=i.val :=
  NormalizationSchedule.unique_owner (p.groups*32) n (by have := p.groupsPositive; omega) i

end Inference.Kernels.RmsNormDevice
