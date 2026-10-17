import models.qwen.AttentionInitialKvMemory

namespace Inference.Models.Qwen.AttentionInitialResultMemory
open Contracts.Mlx State Kernels.Attention
set_option maxRecDepth 10000
attribute [local irreducible] CopyContiguous.programs Copy2DMemory.programs CopyExecution.Trace.memory

variable {layer : ResidualAttention.Layer} {original : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
    {cache : Kv.Cache Kv.BF 0} {front : ResidualAttentionMemory.Prefix layer original angle}
    (read : AttentionInitialKvMemory.Read front cache)

-- Existing downstream SDPA/gating/projection/MLP executions consume the direct
-- first-KV heap. Physical gate and original-residual links are explicit.
structure Execution where
  residualPrefix : front.Safe front.entry.source.lhs.base 10240
  residualKv : read.kv.Safe front.entry.source.lhs.base 10240
  attention : SdpaShared.Execution read.input layer.mixer.attention layer.mixer.mergeContracted layer.mixer.architectureSuffix
  tail : AttentionTailMemory.Execution attention (layer.mixer.heads (layer.inputNorm.forward original) angle).gate
    layer.mixer.gate layer.mixer.output
  gatesLinked : tail.gates=read.gate
  suffix : AttentionResidualMemory.Execution tail layer.suffix original
  sourceLinked : suffix.source=read.buffer (front.residual residualPrefix) rfl residualKv

variable (execution : Execution read)

def Execution.output := execution.suffix.output

def Execution.outputBuffer : ArrayStorage.BFBuffer execution.output := execution.suffix.outputBuffer

def Execution.afterCache : KvRegions.Storage (layer.cacheAfter original angle cache) := execution.suffix.afterCache

theorem Execution.output_eq : execution.output=layer.forward original angle cache := execution.suffix.output_eq

theorem Execution.cache_shared : execution.afterCache.memory=execution.outputBuffer.bytes := rfl

def Execution.forwardBuffer : ArrayStorage.BFBuffer (layer.forward original angle cache) :=
  ArrayViews.reindex execution.output_eq execution.outputBuffer

def Safe (base size : Nat) : Prop :=
  front.Safe base size ∧ read.kv.Safe base size ∧ AttentionResidualMemory.Safe execution.suffix base size

theorem Execution.other_region (safe : Safe read execution base size) (offset : Nat) (bound : offset<size) :
    execution.outputBuffer.bytes (base+offset)=front.entry.source.lhs.bytes (base+offset) :=
  (execution.suffix.other_region safe.2.2 offset bound).trans
    ((read.other_region safe.2.1 offset bound).trans (front.other_region safe.1 offset bound))

def Execution.parametersAfter (parameters : AttentionParameterMemory.Storage layer.mixer front.entry.source.lhs.bytes)
    (safe : AttentionParameterMemory.Protected parameters (Safe read execution)) :
    AttentionParameterMemory.Storage layer.mixer execution.outputBuffer.bytes :=
  AttentionParameterMemory.reframe parameters execution.outputBuffer.bytes
    (AttentionParameterMemory.protected_mono parameters (fun _ _ region => Execution.other_region read execution region) safe)

end Inference.Models.Qwen.AttentionInitialResultMemory
