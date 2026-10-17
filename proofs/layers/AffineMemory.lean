import layers.AffineDevice
import kernels.quantization.MlxQmvMemory

namespace Inference.Layers.AffineMemory
open Contracts.Mlx Kernels.Quantization AffineVerifyLinear
set_option maxRecDepth 10000

structure Execution3 (p : Projection3 steps (4*groups)) (input : Fin (steps*512) → ArrayStorage.BF) where
  weights : AffineDevice.Storage3 p
  kernel : MlxQmvMemory.Execution .three p.platform input weights.buffers groups

structure Execution4 (p : Projection4 steps (4*groups)) (input : Fin (steps*512) → ArrayStorage.BF) where
  weights : AffineDevice.Storage4 p
  kernel : MlxQmvMemory.Execution .four p.platform input weights.buffers groups

def Execution (p : Projection steps (4*groups)) (input : Fin (steps*512) → ArrayStorage.BF) : Type :=
  match p with | .bits3 p => Execution3 p input | .bits4 p => Execution4 p input

def Shared (p : Projection steps rows) (weights : AffineDevice.Storage p) (memory : ByteMemory.Bytes) : Prop :=
  match p with
  | .bits3 _ => Kernels.Quantization.AffineMemory.Shared weights.buffers memory
  | .bits4 _ => Kernels.Quantization.AffineMemory.Shared weights.buffers memory

def Separate (p : Projection steps rows) (weights : AffineDevice.Storage p) (base size : Nat) : Prop :=
  match p with
  | .bits3 _ => Kernels.Quantization.AffineMemory.Separate .three weights.buffers steps rows base size
  | .bits4 _ => Kernels.Quantization.AffineMemory.Separate .four weights.buffers steps rows base size

def fromStorage (p : Projection steps (4*groups)) (input : Fin (steps*512) → ArrayStorage.BF)
    (weights : AffineDevice.Storage p) (source : ArrayStorage.BFBuffer input) (shared : Shared p weights source.bytes)
    (base : Nat) (aligned : base%2=0) (bounded : base+2*(4*groups) ≤ 2^64)
    (inputSeparate : MemoryRegions.Disjoint base (2*(4*groups)) source.base (2*(steps*512)))
    (weightsSeparate : Separate p weights base (2*(4*groups))) : Execution p input :=
  match p with
  | .bits3 p => ⟨weights, MlxQmvMemory.canonical .three p.platform input weights.buffers groups weights.geometry
      source shared base aligned bounded inputSeparate weightsSeparate⟩
  | .bits4 p => ⟨weights, MlxQmvMemory.canonical .four p.platform input weights.buffers groups weights.geometry
      source shared base aligned bounded inputSeparate weightsSeparate⟩

variable {steps groups : Nat} {p : Projection steps (4*groups)} {input : Fin (steps*512) → ArrayStorage.BF}

def Execution.source (execution : Execution p input) : ArrayStorage.BFBuffer input :=
  match p with | .bits3 _ => execution.kernel.source | .bits4 _ => execution.kernel.source

def Execution.output (execution : Execution p input) : Fin (4*groups) → ArrayStorage.BF :=
  match p with | .bits3 _ => execution.kernel.output | .bits4 _ => execution.kernel.output

def Execution.outputBuffer (execution : Execution p input) : ArrayStorage.BFBuffer execution.output :=
  match p with | .bits3 _ => execution.kernel.outputBuffer | .bits4 _ => execution.kernel.outputBuffer

def Execution.base (execution : Execution p input) : Nat :=
  match p with | .bits3 _ => execution.kernel.base | .bits4 _ => execution.kernel.base

def Execution.stores (execution : Execution p input) : List HalfMemory.Store :=
  match p with | .bits3 _ => execution.kernel.stores.schedule | .bits4 _ => execution.kernel.stores.schedule

theorem Execution.output_eq (execution : Execution p input) : execution.output=p.forward input := by
  cases p with
  | bits3 p =>
    funext row
    change execution.kernel.output row=p.forward input row
    rw [execution.kernel.output3, execution.weights.attached]
    rfl
  | bits4 p =>
    funext row
    change execution.kernel.output row=p.forward input row
    rw [execution.kernel.output4, execution.weights.attached]
    rfl

def Execution.forwardBuffer (execution : Execution p input) : ArrayStorage.BFBuffer (p.forward input) where
  bytes := execution.outputBuffer.bytes
  base := execution.outputBuffer.base
  aligned := execution.outputBuffer.aligned
  bounded := execution.outputBuffer.bounded
  attached := by
    intro row
    rw [← execution.output_eq]
    exact execution.outputBuffer.attached row

theorem Execution.memory (execution : Execution p input) :
    execution.outputBuffer.bytes=HalfMemory.execute execution.stores execution.source.bytes := by
  cases p with
  | bits3 p => exact execution.kernel.memory
  | bits4 p => exact execution.kernel.memory

theorem Execution.other_region (execution : Execution p input) {base size : Nat}
    (separate : MemoryRegions.Disjoint execution.base (2*(4*groups)) base size) (offset : Nat) (bound : offset<size) :
    execution.outputBuffer.bytes (base+offset)=execution.source.bytes (base+offset) := by
  cases p with
  | bits3 p => exact execution.kernel.other_region separate offset bound
  | bits4 p => exact execution.kernel.other_region separate offset bound

theorem source_fromStorage (weights : AffineDevice.Storage p) (source : ArrayStorage.BFBuffer input)
    (shared : Shared p weights source.bytes) (base : Nat) (aligned : base%2=0) (bounded : base+2*(4*groups) ≤ 2^64)
    (inputSeparate : MemoryRegions.Disjoint base (2*(4*groups)) source.base (2*(steps*512)))
    (weightsSeparate : Separate p weights base (2*(4*groups))) :
    (fromStorage p input weights source shared base aligned bounded inputSeparate weightsSeparate).source=source := by
  cases p <;> rfl

end Inference.Layers.AffineMemory
