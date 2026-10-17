import models.qwen.AttentionAffineMemory
import models.qwen.Attention

namespace Inference.Models.Qwen.AttentionParameterMemory
open Contracts.Mlx Layers
set_option maxRecDepth 10000

structure Storage (layer : Attention.Layer) (memory : ByteMemory.Bytes) where
  queryScale : ArrayStorage.BFBuffer layer.preparation.qNorm.weight
  keyScale : ArrayStorage.BFBuffer layer.preparation.kNorm.weight
  projection : AffineDevice.Storage layer.output
  queryShared : queryScale.bytes=memory
  keyShared : keyScale.bytes=memory
  projectionShared : AffineMemory.Shared layer.output projection memory

variable {layer : Attention.Layer} {memory : ByteMemory.Bytes}

def Protected (storage : Storage layer memory) (property : Nat → Nat → Prop) : Prop :=
  property storage.queryScale.base 512 ∧ property storage.keyScale.base 512 ∧
  AffineMemoryFrames.Protected layer.output storage.projection property

theorem protected_mono (storage : Storage layer memory) {first second : Nat → Nat → Prop}
    (implies : ∀ base size, first base size → second base size) (safe : Protected storage first) : Protected storage second :=
  ⟨implies _ _ safe.1, implies _ _ safe.2.1,
    AffineMemoryFrames.protected_mono layer.output storage.projection implies safe.2.2⟩

def reframe (storage : Storage layer memory) (after : ByteMemory.Bytes)
    (same : Protected storage (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset))) : Storage layer after where
  queryScale := ArrayFrame.bf storage.queryScale after
    (fun offset bound => (same.1 offset bound).trans (congrFun storage.queryShared _).symm)
  keyScale := ArrayFrame.bf storage.keyScale after
    (fun offset bound => (same.2.1 offset bound).trans (congrFun storage.keyShared _).symm)
  projection := AffineMemoryFrames.reframe layer.output storage.projection after
    (AffineMemoryFrames.stable layer.output storage.projection memory after storage.projectionShared same.2.2)
  queryShared := rfl
  keyShared := rfl
  projectionShared := AffineMemoryFrames.reframe_shared layer.output storage.projection after _

def afterAffine {input : Fin 5120 → ArrayStorage.BF}
    (execution : AttentionAffineMemory.Execution layer.projections input)
    (storage : Storage layer execution.source.bytes)
    (safe : Protected storage (AttentionAffineMemory.Safe execution)) : Storage layer execution.memory :=
  reframe storage execution.memory (protected_mono storage (fun _ _ region => execution.other_region region) safe)

theorem reframe_protected (storage : Storage layer memory) (after : ByteMemory.Bytes)
    (same : Protected storage (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset)))
    (property : Nat → Nat → Prop) : Protected (reframe storage after same) property ↔ Protected storage property := by
  unfold Protected
  exact and_congr Iff.rfl (and_congr Iff.rfl
    (AffineMemoryFrames.reframe_protected layer.output storage.projection after _ property))

end Inference.Models.Qwen.AttentionParameterMemory
