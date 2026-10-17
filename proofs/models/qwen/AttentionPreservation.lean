import models.qwen.AttentionTailMemory
import models.qwen.DecodePreservation

namespace Inference.Models.Qwen.AttentionPreservation
open Contracts.Mlx Kernels.Attention State DecodeStage DecodeChain
set_option maxRecDepth 10000

variable {steps : Nat} {query gate : OutputGateDevice.Heads} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}
  {attention : SdpaShared.Execution input p contracted arch} {gatePlatform : OutputGate.Platform}
  {projection : Layers.AffineVerifyLinear.Projection 12 5120}

-- This may be applied separately to the already-updated graph prefix and
-- the not-yet-updated suffix: their logical token counts need not agree.
def caches {n : Nat} (execution : AttentionTailMemory.Execution attention gate gatePlatform projection)
    (stages : List Stage) (retained : Caches stages n) (storage : DecodeFrame.Storage stages retained input.cache.memory)
    (safe : DecodePreservation.Protected (AttentionTailMemory.Safe execution) stages retained input.cache.memory storage) :
    DecodeFrame.Storage stages retained execution.buffer.bytes :=
  DecodePreservation.reframe (AttentionTailMemory.Safe execution) input.cache.memory execution.buffer.bytes
    (fun _ _ region => execution.other_region region) stages retained storage safe

theorem ownership {n : Nat} (execution : AttentionTailMemory.Execution attention gate gatePlatform projection)
    (stages : List Stage) (retained : Caches stages n) (storage : DecodeFrame.Storage stages retained input.cache.memory)
    (safe : DecodePreservation.Protected (AttentionTailMemory.Safe execution) stages retained input.cache.memory storage)
    (allocator : AllocatorOwnership.State) (owned : CacheOwnership.OwnedCaches allocator stages retained input.cache.memory storage) :
    CacheOwnership.OwnedCaches allocator stages retained execution.buffer.bytes (caches execution stages retained storage safe) :=
  DecodePreservation.preserves_ownership allocator (AttentionTailMemory.Safe execution) input.cache.memory execution.buffer.bytes
    (fun _ _ region => execution.other_region region) stages retained storage safe owned

theorem geometry {n : Nat} (execution : AttentionTailMemory.Execution attention gate gatePlatform projection)
    (stages : List Stage) (retained : Caches stages n) (storage : DecodeFrame.Storage stages retained input.cache.memory)
    (safe : DecodePreservation.Protected (AttentionTailMemory.Safe execution) stages retained input.cache.memory storage)
    (region : Nat → Nat → Prop) (prepared : DecodePreservation.Protected region stages retained input.cache.memory storage) :
    DecodePreservation.Protected region stages retained execution.buffer.bytes (caches execution stages retained storage safe) :=
  DecodePreservation.preserves_geometry (AttentionTailMemory.Safe execution) region input.cache.memory execution.buffer.bytes
    (fun _ _ valid => execution.other_region valid) stages retained storage safe prepared

def residual {n : Nat} {values : Fin n → ArrayStorage.BF}
    (execution : AttentionTailMemory.Execution attention gate gatePlatform projection) (source : ArrayStorage.BFBuffer values)
    (shared : source.bytes=input.cache.memory) (safe : AttentionTailMemory.Safe execution source.base (2*n)) : ArrayStorage.BFBuffer values :=
  ArrayFrame.bf source execution.buffer.bytes (by
    intro offset bound
    exact (execution.other_region safe offset bound).trans (congrFun shared (source.base+offset)).symm)

theorem residual_shared {n : Nat} {values : Fin n → ArrayStorage.BF}
    (execution : AttentionTailMemory.Execution attention gate gatePlatform projection) (source : ArrayStorage.BFBuffer values)
    (shared : source.bytes=input.cache.memory) (safe : AttentionTailMemory.Safe execution source.base (2*n)) :
    (residual execution source shared safe).bytes=execution.buffer.bytes := rfl

end Inference.Models.Qwen.AttentionPreservation
