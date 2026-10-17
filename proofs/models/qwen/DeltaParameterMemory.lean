import models.qwen.DeltaAffineMemory
import kernels.delta.ConvolutionMemory
import kernels.delta.GateMemory

namespace Inference.Models.Qwen.DeltaParameterMemory
open Contracts.Mlx Layers Kernels.Delta
set_option maxRecDepth 10000

structure Storage (layer : DeltaNet.Layer) (memory : ByteMemory.Bytes) where
  convolution : ArrayStorage.BFBuffer (ConvolutionDevice.weightWords layer.convolutionWeight)
  queryScale : ArrayStorage.BFBuffer layer.headParams.qScale
  keyScale : ArrayStorage.BFBuffer layer.headParams.kScale
  logarithm : ArrayStorage.BFBuffer layer.aLog
  bias : ArrayStorage.BFBuffer layer.dtBias
  normalization : ArrayStorage.BFBuffer layer.normWeight
  projection : AffineDevice.Storage layer.out
  convolutionShared : convolution.bytes=memory
  queryShared : queryScale.bytes=memory
  keyShared : keyScale.bytes=memory
  logarithmShared : logarithm.bytes=memory
  biasShared : bias.bytes=memory
  normalizationShared : normalization.bytes=memory
  projectionShared : AffineMemory.Shared layer.out projection memory

variable {layer : DeltaNet.Layer} {memory : ByteMemory.Bytes}

def Protected (storage : Storage layer memory) (property : Nat → Nat → Prop) : Prop :=
  property storage.convolution.base 81920 ∧ property storage.queryScale.base 256 ∧
  property storage.keyScale.base 256 ∧ property storage.logarithm.base 96 ∧
  property storage.bias.base 96 ∧ property storage.normalization.base 256 ∧
  AffineMemoryFrames.Protected layer.out storage.projection property

theorem protected_mono (storage : Storage layer memory) {first second : Nat → Nat → Prop}
    (implies : ∀ base size, first base size → second base size) (safe : Protected storage first) : Protected storage second :=
  ⟨implies _ _ safe.1, implies _ _ safe.2.1, implies _ _ safe.2.2.1,
    implies _ _ safe.2.2.2.1, implies _ _ safe.2.2.2.2.1, implies _ _ safe.2.2.2.2.2.1,
    AffineMemoryFrames.protected_mono layer.out storage.projection implies safe.2.2.2.2.2.2⟩

def reframe (storage : Storage layer memory) (after : ByteMemory.Bytes)
    (same : Protected storage (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset))) : Storage layer after where
  convolution := ArrayFrame.bf storage.convolution after
    (fun offset bound => (same.1 offset bound).trans (congrFun storage.convolutionShared _).symm)
  queryScale := ArrayFrame.bf storage.queryScale after
    (fun offset bound => (same.2.1 offset bound).trans (congrFun storage.queryShared _).symm)
  keyScale := ArrayFrame.bf storage.keyScale after
    (fun offset bound => (same.2.2.1 offset bound).trans (congrFun storage.keyShared _).symm)
  logarithm := ArrayFrame.bf storage.logarithm after
    (fun offset bound => (same.2.2.2.1 offset bound).trans (congrFun storage.logarithmShared _).symm)
  bias := ArrayFrame.bf storage.bias after
    (fun offset bound => (same.2.2.2.2.1 offset bound).trans (congrFun storage.biasShared _).symm)
  normalization := ArrayFrame.bf storage.normalization after
    (fun offset bound => (same.2.2.2.2.2.1 offset bound).trans (congrFun storage.normalizationShared _).symm)
  projection := AffineMemoryFrames.reframe layer.out storage.projection after
    (AffineMemoryFrames.stable layer.out storage.projection memory after storage.projectionShared same.2.2.2.2.2.2)
  convolutionShared := rfl
  queryShared := rfl
  keyShared := rfl
  logarithmShared := rfl
  biasShared := rfl
  normalizationShared := rfl
  projectionShared := AffineMemoryFrames.reframe_shared layer.out storage.projection after _

def afterAffine {input : Fin 5120 → ArrayStorage.BF} (execution : DeltaAffineMemory.Execution layer input)
    (storage : Storage layer execution.source.bytes) (safe : Protected storage (DeltaAffineMemory.Safe execution)) :
    Storage layer execution.memory :=
  reframe storage execution.memory (protected_mono storage (fun _ _ region => execution.other_region region) safe)

-- The gate expression now consumes the actual A/B projection outputs and
-- the retained checkpoint constants from that same completed heap.
def gateInput {input : Fin 5120 → ArrayStorage.BF} (execution : DeltaAffineMemory.Execution layer input)
    (storage : Storage layer execution.memory) : GateMemory.Input layer.aLog (layer.a.forward input) layer.dtBias (layer.b.forward input) where
  storage := ⟨storage.logarithm, execution.aBuffer, storage.bias, execution.bBuffer⟩
  aShared := storage.logarithmShared.symm
  biasShared := storage.biasShared.trans storage.logarithmShared.symm
  bShared := storage.logarithmShared.symm

theorem gate_input_memory {input : Fin 5120 → ArrayStorage.BF} (execution : DeltaAffineMemory.Execution layer input)
    (storage : Storage layer execution.memory) : (gateInput execution storage).storage.logarithm.bytes=execution.memory :=
  storage.logarithmShared

end Inference.Models.Qwen.DeltaParameterMemory
