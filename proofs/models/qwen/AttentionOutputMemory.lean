import models.qwen.AttentionGateMemory
import layers.AffineMemory

namespace Inference.Models.Qwen.AttentionOutputMemory
open Contracts.Mlx Kernels.Attention State
set_option maxRecDepth 10000

variable {x gate : OutputGateDevice.Heads} {input : OutputGateMemory.Input x gate} {p : OutputGate.Platform}
  {steps : Nat} {cache : Kv.Cache Kv.BF steps}

structure CacheSeparation (execution : OutputGateMemory.Execution input p) (storage : KvRegions.Storage cache) : Prop where
  activationKeys : MemoryRegions.Disjoint (2*execution.activation.base) 12288 storage.layout.keyBase (KvRegions.bytes steps)
  activationValues : MemoryRegions.Disjoint (2*execution.activation.base) 12288 storage.layout.valueBase (KvRegions.bytes steps)
  outputKeys : MemoryRegions.Disjoint (2*execution.base) 12288 storage.layout.keyBase (KvRegions.bytes steps)
  outputValues : MemoryRegions.Disjoint (2*execution.base) 12288 storage.layout.valueBase (KvRegions.bytes steps)

def gatedCache (execution : OutputGateMemory.Execution input p) (storage : KvRegions.Storage cache)
    (shared : storage.memory=input.memory) (separate : CacheSeparation execution storage) : KvRegions.Storage cache :=
  AttentionGateMemory.afterGate execution storage shared separate.activationKeys separate.activationValues separate.outputKeys separate.outputValues

structure Execution (gating : OutputGateMemory.Execution input p)
    (projection : Layers.AffineVerifyLinear.Projection 12 5120) where
  affine : Layers.AffineMemory.Execution (groups := 1280) projection (OutputGateMemory.values p x gate)
  linked : affine.source=gating.buffer

variable {gating : OutputGateMemory.Execution input p} {projection : Layers.AffineVerifyLinear.Projection 12 5120}

def fromGate (gating : OutputGateMemory.Execution input p) (projection : Layers.AffineVerifyLinear.Projection 12 5120)
    (weights : Layers.AffineDevice.Storage projection) (shared : Layers.AffineMemory.Shared projection weights gating.buffer.bytes)
    (base : Nat) (aligned : base%2=0) (bounded : base+10240 ≤ 2^64)
    (inputSeparate : MemoryRegions.Disjoint base 10240 gating.buffer.base 12288)
    (weightsSeparate : Layers.AffineMemory.Separate projection weights base 10240) : Execution gating projection :=
  ⟨Layers.AffineMemory.fromStorage (groups := 1280) projection _ weights gating.buffer shared base aligned bounded inputSeparate weightsSeparate,
    Layers.AffineMemory.source_fromStorage (steps := 12) (groups := 1280) (p := projection)
      weights gating.buffer shared base aligned bounded inputSeparate weightsSeparate⟩

def Execution.output (execution : Execution gating projection) : Fin 5120 → ArrayStorage.BF := execution.affine.output

def Execution.buffer (execution : Execution gating projection) : ArrayStorage.BFBuffer execution.output := execution.affine.outputBuffer

theorem Execution.output_eq (execution : Execution gating projection) :
    execution.output=projection.forward (OutputGateMemory.values p x gate) := execution.affine.output_eq

theorem Execution.memory (execution : Execution gating projection) :
    execution.buffer.bytes=HalfMemory.execute execution.affine.stores gating.trace.memory := by
  unfold Execution.buffer
  rw [Layers.AffineMemory.Execution.memory, execution.linked]
  rfl

theorem Execution.other_region (execution : Execution gating projection) {base size : Nat}
    (activationSeparate : MemoryRegions.Disjoint (2*gating.activation.base) 12288 base size)
    (gateSeparate : MemoryRegions.Disjoint (2*gating.base) 12288 base size)
    (projectionSeparate : MemoryRegions.Disjoint execution.affine.base 10240 base size)
    (offset : Nat) (bound : offset<size) :
    execution.buffer.bytes (base+offset)=input.memory (base+offset) := by
  have final := execution.affine.other_region projectionSeparate offset bound
  rw [execution.linked] at final
  exact final.trans (gating.other_region activationSeparate gateSeparate offset bound)

def Execution.afterCache (execution : Execution gating projection) (storage : KvRegions.Storage cache)
    (shared : storage.memory=input.memory) (separate : CacheSeparation gating storage)
    (projectionKeys : MemoryRegions.Disjoint execution.affine.base 10240 storage.layout.keyBase (KvRegions.bytes steps))
    (projectionValues : MemoryRegions.Disjoint execution.affine.base 10240 storage.layout.valueBase (KvRegions.bytes steps)) : KvRegions.Storage cache :=
  storage.reframe execution.buffer.bytes
    (by
      intro offset bound
      exact (execution.other_region separate.activationKeys separate.outputKeys projectionKeys offset bound).trans
        (congrFun shared (storage.layout.keyBase+offset)).symm)
    (by
      intro offset bound
      exact (execution.other_region separate.activationValues separate.outputValues projectionValues offset bound).trans
        (congrFun shared (storage.layout.valueBase+offset)).symm)

theorem Execution.cache_output_shared (execution : Execution gating projection) (storage : KvRegions.Storage cache)
    (shared : storage.memory=input.memory) (separate : CacheSeparation gating storage)
    (projectionKeys : MemoryRegions.Disjoint execution.affine.base 10240 storage.layout.keyBase (KvRegions.bytes steps))
    (projectionValues : MemoryRegions.Disjoint execution.affine.base 10240 storage.layout.valueBase (KvRegions.bytes steps)) :
    (execution.afterCache storage shared separate projectionKeys projectionValues).memory=execution.buffer.bytes := rfl

-- Both attention routes feed the same projection theorem, so the earlier
-- numerical bounds apply to these completed, shared-memory output bytes.
theorem onePass_output {query : OutputGateDevice.Heads} {cache : Kv.Cache Kv.BF steps}
    {attentionInput : SdpaMemory.Input query cache} {attentionPlatform : SdpaVector.Platform} {arch : Char}
    (attention : SdpaOnePassDonation.Execution attentionInput attentionPlatform arch) (contracted : Bool)
    {gateInput : OutputGateMemory.Input attention.output gate} {gatePlatform : OutputGate.Platform}
    {gating : OutputGateMemory.Execution gateInput gatePlatform}
    (execution : Execution gating projection) :
    execution.output=projection.forward (OutputGateMemory.values gatePlatform
      (fun head => SdpaDispatched.forward attentionPlatform contracted arch (query head)
        (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))) gate) := by
  have reads : attention.output=(fun head => SdpaDispatched.forward attentionPlatform contracted arch (query head)
      (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))) :=
    funext (fun head => funext (attention.output_eq contracted head))
  exact execution.output_eq.trans
    (congrArg (fun heads => projection.forward (OutputGateMemory.values gatePlatform heads gate)) reads)

theorem twoPass_output {query : OutputGateDevice.Heads} {cache : Kv.Cache Kv.BF steps}
    {attentionInput : SdpaMemory.Input query cache} {attentionPlatform : SdpaVector.Platform} {arch : Char}
    {first : SdpaTwoPassShared.Execution attentionInput attentionPlatform (SdpaDispatched.blockCount arch steps)} {contracted : Bool}
    (attention : SdpaTwoPassDonation.Execution first contracted)
    {gateInput : OutputGateMemory.Input attention.output gate} {gatePlatform : OutputGate.Platform}
    {gating : OutputGateMemory.Execution gateInput gatePlatform}
    (execution : Execution gating projection) :
    execution.output=projection.forward (OutputGateMemory.values gatePlatform
      (fun head => SdpaDispatched.forward attentionPlatform contracted arch (query head)
        (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))) gate) := by
  have reads : attention.output=(fun head => SdpaDispatched.forward attentionPlatform contracted arch (query head)
      (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))) :=
    funext (fun head => funext (attention.output_eq head))
  exact execution.output_eq.trans
    (congrArg (fun heads => projection.forward (OutputGateMemory.values gatePlatform heads gate)) reads)

end Inference.Models.Qwen.AttentionOutputMemory
