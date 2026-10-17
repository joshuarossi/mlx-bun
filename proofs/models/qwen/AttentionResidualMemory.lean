import models.qwen.AttentionPreservation
import models.qwen.ResidualMlpMemory

namespace Inference.Models.Qwen.AttentionResidualMemory
open Contracts.Mlx Kernels.Attention State DecodeStage DecodeChain
set_option maxRecDepth 10000

variable {steps : Nat} {query gate : OutputGateDevice.Heads} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}
  {attention : SdpaShared.Execution input p contracted arch} {gatePlatform : OutputGate.Platform}
  {projection : Layers.AffineVerifyLinear.Projection 12 5120} {x : Fin 5120 → ArrayStorage.BF}

def residualInput (tail : AttentionTailMemory.Execution attention gate gatePlatform projection)
    (source : ArrayStorage.BFBuffer x) (shared : source.bytes=input.cache.memory)
    (safe : AttentionTailMemory.Safe tail source.base 10240) : BinaryMemory.Input x tail.output :=
  ⟨AttentionPreservation.residual tail source shared safe, tail.buffer, rfl⟩

structure Execution (tail : AttentionTailMemory.Execution attention gate gatePlatform projection)
    (block : ResidualBlocks.Mlp) (x : Fin 5120 → ArrayStorage.BF) where
  source : ArrayStorage.BFBuffer x
  shared : source.bytes=input.cache.memory
  sourceSafe : AttentionTailMemory.Safe tail source.base 10240
  suffix : ResidualMlpMemory.Execution block (residualInput tail source shared sourceSafe)
  keysSafe : ResidualMlpMemory.Safe suffix tail.afterCache.layout.keyBase (KvRegions.bytes steps)
  valuesSafe : ResidualMlpMemory.Safe suffix tail.afterCache.layout.valueBase (KvRegions.bytes steps)

variable {tail : AttentionTailMemory.Execution attention gate gatePlatform projection} {block : ResidualBlocks.Mlp}

def fromSuffix (tail : AttentionTailMemory.Execution attention gate gatePlatform projection) (block : ResidualBlocks.Mlp)
    (source : ArrayStorage.BFBuffer x) (shared : source.bytes=input.cache.memory)
    (sourceSafe : AttentionTailMemory.Safe tail source.base 10240)
    (suffix : ResidualMlpMemory.Execution block (residualInput tail source shared sourceSafe))
    (keysSafe : ResidualMlpMemory.Safe suffix tail.afterCache.layout.keyBase (KvRegions.bytes steps))
    (valuesSafe : ResidualMlpMemory.Safe suffix tail.afterCache.layout.valueBase (KvRegions.bytes steps)) : Execution tail block x :=
  ⟨source, shared, sourceSafe, suffix, keysSafe, valuesSafe⟩

def Execution.output (execution : Execution tail block x) : Fin 5120 → ArrayStorage.BF := execution.suffix.output
def Execution.outputBuffer (execution : Execution tail block x) : ArrayStorage.BFBuffer execution.output := execution.suffix.outputBuffer

def Execution.afterCache (execution : Execution tail block x) : KvRegions.Storage cache :=
  tail.afterCache.reframe execution.outputBuffer.bytes
    (execution.suffix.other_region execution.keysSafe) (execution.suffix.other_region execution.valuesSafe)

theorem Execution.cache_output_shared (execution : Execution tail block x) :
    execution.afterCache.memory=execution.outputBuffer.bytes := rfl

theorem Execution.output_eq (execution : Execution tail block x) :
    execution.output=block.forward x (projection.forward (OutputGateMemory.values gatePlatform
      (fun head => SdpaDispatched.forward p contracted arch (query head)
        (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))) gate)) :=
  execution.suffix.output_eq.trans (congrArg (block.forward x) tail.output_eq)

def Safe (execution : Execution tail block x) (base size : Nat) : Prop :=
  AttentionTailMemory.Safe tail base size ∧ ResidualMlpMemory.Safe execution.suffix base size

theorem Execution.other_region (execution : Execution tail block x) {base size : Nat}
    (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.outputBuffer.bytes (base+offset)=input.cache.memory (base+offset) :=
  (execution.suffix.other_region safe.2 offset bound).trans (tail.other_region safe.1 offset bound)

def Execution.retainedCaches {n : Nat} (execution : Execution tail block x) (stages : List Stage) (retained : Caches stages n)
    (storage : DecodeFrame.Storage stages retained input.cache.memory)
    (safe : DecodePreservation.Protected (Safe execution) stages retained input.cache.memory storage) :
    DecodeFrame.Storage stages retained execution.outputBuffer.bytes :=
  DecodePreservation.reframe (Safe execution) input.cache.memory execution.outputBuffer.bytes
    (fun _ _ region => execution.other_region region) stages retained storage safe

end Inference.Models.Qwen.AttentionResidualMemory
