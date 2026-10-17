import kernels.attention.SdpaShared
import models.qwen.AttentionOutputMemory

namespace Inference.Models.Qwen.AttentionTailMemory
open Contracts.Mlx Kernels.Attention State
set_option maxRecDepth 10000

variable {steps : Nat} {query gate : OutputGateDevice.Heads} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}

def gateInput (attention : SdpaShared.Execution input p contracted arch)
    (gates : ∀ head, ArrayStorage.BFBuffer (gate head)) (shared : ∀ head, (gates head).bytes=input.cache.memory)
    (safe : ∀ head, SdpaShared.Safe attention (gates head).base 512) : OutputGateMemory.Input attention.output gate where
  memory := attention.memory
  storage := {
    source := attention.buffer
    gate := fun head => ArrayFrame.bf (gates head) attention.memory (by
      intro offset bound
      exact (attention.other_region (safe head) offset bound).trans
        (congrFun (shared head) ((gates head).base+offset)).symm) }
  sourceShared := attention.buffer_bytes
  gateShared := fun _ => rfl

theorem gateInput_layout (attention : SdpaShared.Execution input p contracted arch)
    (gates : ∀ head, ArrayStorage.BFBuffer (gate head)) (shared : ∀ head, (gates head).bytes=input.cache.memory)
    (safe : ∀ head, SdpaShared.Safe attention (gates head).base 512) (head : Fin 24) :
    ((gateInput attention gates shared safe).storage.source head).base=2*(attention.base/2+head.val*256) := attention.buffer_base head

structure Execution (attention : SdpaShared.Execution input p contracted arch) (gate : OutputGateDevice.Heads)
    (gatePlatform : OutputGate.Platform) (projection : Layers.AffineVerifyLinear.Projection 12 5120) where
  gates : ∀ head, ArrayStorage.BFBuffer (gate head)
  gatesShared : ∀ head, (gates head).bytes=input.cache.memory
  gatesSafe : ∀ head, SdpaShared.Safe attention (gates head).base 512
  gating : OutputGateMemory.Execution (gateInput attention gates gatesShared gatesSafe) gatePlatform
  projected : AttentionOutputMemory.Execution gating projection
  gateSeparate : AttentionOutputMemory.CacheSeparation gating attention.afterCache
  projectionKeys : MemoryRegions.Disjoint projected.affine.base 10240 attention.afterCache.layout.keyBase (KvRegions.bytes steps)
  projectionValues : MemoryRegions.Disjoint projected.affine.base 10240 attention.afterCache.layout.valueBase (KvRegions.bytes steps)

variable {attention : SdpaShared.Execution input p contracted arch} {gatePlatform : OutputGate.Platform}
  {projection : Layers.AffineVerifyLinear.Projection 12 5120}

-- All byte attachments are produced by the read/gate/projection executions;
-- the remaining premises describe the allocation geometry and input payloads.
def fromGate (attention : SdpaShared.Execution input p contracted arch)
    (gates : ∀ head, ArrayStorage.BFBuffer (gate head)) (shared : ∀ head, (gates head).bytes=input.cache.memory)
    (safe : ∀ head, SdpaShared.Safe attention (gates head).base 512)
    (gating : OutputGateMemory.Execution (gateInput attention gates shared safe) gatePlatform)
    (projected : AttentionOutputMemory.Execution gating projection)
    (gateSeparate : AttentionOutputMemory.CacheSeparation gating attention.afterCache)
    (projectionKeys : MemoryRegions.Disjoint projected.affine.base 10240 attention.afterCache.layout.keyBase (KvRegions.bytes steps))
    (projectionValues : MemoryRegions.Disjoint projected.affine.base 10240 attention.afterCache.layout.valueBase (KvRegions.bytes steps)) :
    Execution attention gate gatePlatform projection :=
  ⟨gates, shared, safe, gating, projected, gateSeparate, projectionKeys, projectionValues⟩

def Execution.output (execution : Execution attention gate gatePlatform projection) : Fin 5120 → ArrayStorage.BF := execution.projected.output

def Execution.buffer (execution : Execution attention gate gatePlatform projection) : ArrayStorage.BFBuffer execution.output := execution.projected.buffer

def Execution.afterCache (execution : Execution attention gate gatePlatform projection) : KvRegions.Storage cache :=
  execution.projected.afterCache attention.afterCache attention.cache_memory execution.gateSeparate execution.projectionKeys execution.projectionValues

theorem Execution.cache_output_shared (execution : Execution attention gate gatePlatform projection) :
    execution.afterCache.memory=execution.buffer.bytes := rfl

theorem Execution.cache_layout (execution : Execution attention gate gatePlatform projection) :
    execution.afterCache.layout=input.cache.layout := attention.cache_layout

def Safe (execution : Execution attention gate gatePlatform projection) (base size : Nat) : Prop :=
  SdpaShared.Safe attention base size ∧
    MemoryRegions.Disjoint (2*execution.gating.activation.base) 12288 base size ∧
    MemoryRegions.Disjoint (2*execution.gating.base) 12288 base size ∧
    MemoryRegions.Disjoint execution.projected.affine.base 10240 base size

theorem Execution.other_region (execution : Execution attention gate gatePlatform projection) {base size : Nat}
    (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.buffer.bytes (base+offset)=input.cache.memory (base+offset) :=
  (execution.projected.other_region safe.2.1 safe.2.2.1 safe.2.2.2 offset bound).trans
    (attention.other_region safe.1 offset bound)

theorem Execution.output_eq (execution : Execution attention gate gatePlatform projection) :
    execution.output=projection.forward (OutputGateMemory.values gatePlatform
      (fun head => SdpaDispatched.forward p contracted arch (query head)
        (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))) gate) := by
  have reads : attention.output=(fun head => SdpaDispatched.forward p contracted arch (query head)
      (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))) :=
    funext (fun head => funext (attention.output_eq head))
  exact execution.projected.output_eq.trans
    (congrArg (fun heads => projection.forward (OutputGateMemory.values gatePlatform heads gate)) reads)

theorem Execution.memory (execution : Execution attention gate gatePlatform projection) :
    execution.buffer.bytes=HalfMemory.execute execution.projected.affine.stores
      (ElementwiseMemory.execute (OutputGateMemory.multiplyKernel execution.gating.activation execution.gating.base)
        execution.gating.trace.schedule
        (ElementwiseMemory.execute (OutputGateMemory.sigmoidKernel
          (gateInput attention execution.gates execution.gatesShared execution.gatesSafe) gatePlatform execution.gating.activation.base)
          execution.gating.activation.trace.schedule attention.memory)) := by
  change execution.projected.buffer.bytes=_
  rw [execution.projected.memory]
  unfold ElementwiseMemory.Trace.memory
  rw [execution.gating.initial]
  unfold ElementwiseMemory.Trace.memory
  rw [execution.gating.activation.initial]
  rfl

end Inference.Models.Qwen.AttentionTailMemory
