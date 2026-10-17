import models.qwen.DeltaAffine
import layers.AffineMemoryFrames

namespace Inference.Models.Qwen.DeltaAffineMemory
open Contracts.Mlx Layers Kernels.Delta
set_option maxRecDepth 10000

-- Four affine dispatches consume the preserved normalized input. Their
-- packed weights, scales and biases are attached on each actual input heap.
structure Execution (layer : DeltaNet.Layer) (input : Fin 5120 → ArrayStorage.BF) where
  qkv : AffineMemory.Execution (groups := 2560) layer.qkv input
  z : AffineMemory.Execution (groups := 1536) layer.z input
  a : AffineMemory.Execution (groups := 12) layer.a input
  b : AffineMemory.Execution (groups := 12) layer.b input
  zInput : z.source=AffineMemoryFrames.sourceAfter qkv
  aInput : a.source=AffineMemoryFrames.sourceAfter z
  bInput : b.source=AffineMemoryFrames.sourceAfter a
  zQkv : MemoryRegions.Disjoint z.base 12288 qkv.forwardBuffer.base 20480
  aQkv : MemoryRegions.Disjoint a.base 96 qkv.forwardBuffer.base 20480
  bQkv : MemoryRegions.Disjoint b.base 96 qkv.forwardBuffer.base 20480
  aZ : MemoryRegions.Disjoint a.base 96 z.forwardBuffer.base 12288
  bZ : MemoryRegions.Disjoint b.base 96 z.forwardBuffer.base 12288
  bA : MemoryRegions.Disjoint b.base 96 a.forwardBuffer.base 96

variable {layer : DeltaNet.Layer} {input : Fin 5120 → ArrayStorage.BF}

def Execution.memory (execution : Execution layer input) : ByteMemory.Bytes := execution.b.outputBuffer.bytes
def Execution.source (execution : Execution layer input) : ArrayStorage.BFBuffer input := execution.qkv.source

theorem Execution.z_memory (execution : Execution layer input) : execution.z.source.bytes=execution.qkv.outputBuffer.bytes :=
  congrArg ArrayStorage.BFBuffer.bytes execution.zInput

theorem Execution.a_memory (execution : Execution layer input) : execution.a.source.bytes=execution.z.outputBuffer.bytes :=
  congrArg ArrayStorage.BFBuffer.bytes execution.aInput

theorem Execution.b_memory (execution : Execution layer input) : execution.b.source.bytes=execution.a.outputBuffer.bytes :=
  congrArg ArrayStorage.BFBuffer.bytes execution.bInput

def Execution.qkvBuffer (execution : Execution layer input) : ArrayStorage.BFBuffer (layer.qkv.forward input) :=
  ArrayFrame.bf execution.qkv.forwardBuffer execution.memory (by
    intro offset bound
    have z := execution.z.other_region execution.zQkv offset bound
    have a := execution.a.other_region execution.aQkv offset bound
    have b := execution.b.other_region execution.bQkv offset bound
    rw [execution.z_memory] at z
    rw [execution.a_memory] at a
    rw [execution.b_memory] at b
    exact b.trans (a.trans z))

def Execution.zBuffer (execution : Execution layer input) : ArrayStorage.BFBuffer (layer.z.forward input) :=
  ArrayFrame.bf execution.z.forwardBuffer execution.memory (by
    intro offset bound
    have a := execution.a.other_region execution.aZ offset bound
    have b := execution.b.other_region execution.bZ offset bound
    rw [execution.a_memory] at a
    rw [execution.b_memory] at b
    exact b.trans a)

def Execution.aBuffer (execution : Execution layer input) : ArrayStorage.BFBuffer (layer.a.forward input) :=
  ArrayFrame.bf execution.a.forwardBuffer execution.memory (by
    intro offset bound
    exact (execution.b.other_region execution.bA offset bound).trans (congrFun execution.b_memory _))

def Execution.bBuffer (execution : Execution layer input) : ArrayStorage.BFBuffer (layer.b.forward input) := execution.b.forwardBuffer

def Execution.inputAfter (execution : Execution layer input) : ArrayStorage.BFBuffer input := AffineMemoryFrames.sourceAfter execution.b

theorem Execution.buffers_shared (execution : Execution layer input) :
    execution.qkvBuffer.bytes=execution.memory ∧ execution.zBuffer.bytes=execution.memory ∧
      execution.aBuffer.bytes=execution.memory ∧ execution.bBuffer.bytes=execution.memory ∧ execution.inputAfter.bytes=execution.memory :=
  ⟨rfl,rfl,rfl,rfl,rfl⟩

def Execution.gateBuffer (execution : Execution layer input) :
    ArrayStorage.BFBuffer (GatedInputs.flatten (DeltaNet.zHead layer (fun _ => input) 0)) where
  bytes := execution.memory
  base := execution.zBuffer.base
  aligned := execution.zBuffer.aligned
  bounded := execution.zBuffer.bounded
  attached := by
    intro i
    have same : GatedInputs.flatten (DeltaNet.zHead layer (fun _ => input) 0) i=layer.z.forward input i := by
      change layer.z.forward input (DeltaNet.channel (DeltaNet.headOf i) (DeltaNet.valueOf i))=_
      rw [DeltaNet.reshape_roundtrip]
    rw [same]
    exact execution.zBuffer.attached i

def Safe (execution : Execution layer input) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint execution.qkv.base 20480 base size ∧
  MemoryRegions.Disjoint execution.z.base 12288 base size ∧
  MemoryRegions.Disjoint execution.a.base 96 base size ∧
  MemoryRegions.Disjoint execution.b.base 96 base size

theorem Execution.other_region (execution : Execution layer input) {base size : Nat}
    (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.memory (base+offset)=execution.source.bytes (base+offset) := by
  have qkv := execution.qkv.other_region safe.1 offset bound
  have z := execution.z.other_region safe.2.1 offset bound
  have a := execution.a.other_region safe.2.2.1 offset bound
  have b := execution.b.other_region safe.2.2.2 offset bound
  rw [execution.z_memory] at z
  rw [execution.a_memory] at a
  rw [execution.b_memory] at b
  exact b.trans (a.trans (z.trans qkv))

-- Other projection weights may be carried through this entire phase using
-- the same packed/scales/bias frame proof, retaining their physical bases.
def Execution.weightsAfter (execution : Execution layer input) (next : AffineVerifyLinear.Projection steps rows)
    (weights : AffineDevice.Storage next) (shared : AffineMemory.Shared next weights execution.source.bytes)
    (safe : AffineMemoryFrames.Protected next weights (Safe execution)) : AffineDevice.Storage next :=
  AffineMemoryFrames.reframe next weights execution.memory
    (AffineMemoryFrames.stable next weights execution.source.bytes execution.memory shared
      (AffineMemoryFrames.protected_mono next weights (fun _ _ region => execution.other_region region) safe))

theorem Execution.weights_shared (execution : Execution layer input) (next : AffineVerifyLinear.Projection steps rows)
    (weights : AffineDevice.Storage next) (shared : AffineMemory.Shared next weights execution.source.bytes)
    (safe : AffineMemoryFrames.Protected next weights (Safe execution)) :
    AffineMemory.Shared next (execution.weightsAfter next weights shared safe) execution.memory :=
  AffineMemoryFrames.reframe_shared next weights execution.memory _

end Inference.Models.Qwen.DeltaAffineMemory
