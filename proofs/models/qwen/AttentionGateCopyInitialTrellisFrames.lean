import models.qwen.AttentionGateCopyInitialRead
import models.qwen.TrellisWeightsMemory
namespace Inference.Models.Qwen.AttentionGateCopyInitialTrellisFrames
open Contracts.Mlx Kernels.Attention State Layers
set_option maxRecDepth 10000
attribute [local irreducible] AttentionGateCopyInitialRead.Read.input AttentionGateCopyInitialRead.Read.kv
variable {layer : Attention.Layer} {cache : Kv.Cache Kv.BF 0}
  {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {front : AttentionGateCopyFront.Execution layer values angle}
  (read : AttentionGateCopyInitialRead.Read front cache)

-- Includes every copy write in the new prefix and every cache growth/append.
def Safe (base size : Nat) : Prop :=
  AttentionGateCopyFront.Safe front base size ∧ read.kv.Safe base size

theorem frame {base size : Nat} (safe : Safe read base size) (offset : Nat) (bound : offset<size) :
    read.input.cache.memory (base+offset)=front.phase.q.source.bytes (base+offset) :=
  (read.other_region safe.2 offset bound).trans
    (AttentionGateCopyPreservation.frame front.rope safe.1 offset bound)

def buffer {width : Nat} {value : Fin width → ArrayStorage.BF}
    (original : ArrayStorage.BFBuffer value) (shared : original.bytes=front.phase.q.source.bytes)
    (safe : Safe read original.base (2*width)) : ArrayStorage.BFBuffer value :=
  ArrayFrame.bf original read.input.cache.memory
    (fun offset bound => (frame read safe offset bound).trans (congrFun shared _).symm)

theorem buffer_base {width : Nat} {value : Fin width → ArrayStorage.BF}
    (original : ArrayStorage.BFBuffer value) (shared : original.bytes=front.phase.q.source.bytes)
    (safe : Safe read original.base (2*width)) : (buffer read original shared safe).base=original.base := by simp only [buffer,ArrayFrame.bf]


theorem buffer_bytes {width : Nat} {value : Fin width → ArrayStorage.BF}
    (original : ArrayStorage.BFBuffer value) (shared : original.bytes=front.phase.q.source.bytes)
    (safe : Safe read original.base (2*width)) : (buffer read original shared safe).bytes=read.input.cache.memory := by simp only [buffer,ArrayFrame.bf]

def weights (parameters : TrellisWeightsMemory.Weights mlp front.phase.q.source.bytes)
    (safe : parameters.Protected (Safe read)) : TrellisWeightsMemory.Weights mlp read.input.cache.memory :=
  parameters.reframe read.input.cache.memory
    (parameters.protected_mono (fun _ _ region => frame read region) safe)
end Inference.Models.Qwen.AttentionGateCopyInitialTrellisFrames
