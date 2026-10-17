import models.qwen.AttentionSuffixAllocation
import models.qwen.ResidualMlpAllocation

namespace Inference.Models.Qwen.AttentionSuffixHighWater
open Contracts.Mlx Layers Kernels.Attention State
set_option maxRecDepth 10000
attribute [local irreducible] SdpaOutput.programs Copy2DMemory.programs
  ReadBeforeOverwrite.allReaders ReadBeforeOverwrite.captureMany

private theorem trellis_regions {mlp : WrittenLayers.GateDown} {memory : ByteMemory.Bytes}
    (stored : TrellisWeightsMemory.Weights mlp memory) (after : ByteMemory.Bytes)
    (same : stored.Protected (fun base size => ∀ offset < size, after (base+offset)=memory (base+offset)))
    (property : Nat → Nat → Prop) : (stored.reframe after same).Protected property ↔ stored.Protected property := Iff.rfl

def Before (cursor base size : Nat) : Prop := base+size≤cursor

variable {steps : Nat} {query gate : OutputGateDevice.Heads} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}
  {attention : SdpaShared.Execution input p contracted arch} {gatePlatform : OutputGate.Platform}
  {projection : AffineVerifyLinear.Projection 12 5120} {x : Fin 5120 → ArrayStorage.BF} {block : ResidualBlocks.Mlp}
  (tail : AttentionTailMemory.Execution attention gate gatePlatform projection)
  (prepared : AttentionSuffixAllocation.Input tail (x:=x) (block:=block))

structure Request where
  cursor : Nat
  aligned : cursor%16=0
  room : cursor+ResidualMlpAllocation.bytes≤2^64
  source : Before cursor prepared.source.base 10240
  update : Before cursor tail.buffer.base 10240
  norm : Before cursor prepared.norm.base 10240
  parameters : prepared.parameters.Protected (Before cursor)
  keys : Before cursor tail.afterCache.layout.keyBase (KvRegions.bytes steps)
  values : Before cursor tail.afterCache.layout.valueBase (KvRegions.bytes steps)

variable (request : Request tail prepared)

def workspace : ResidualMlpAllocation.Workspace
    (AttentionResidualMemory.residualInput tail prepared.source prepared.shared prepared.safe)
    (AttentionTailConstruction.normAfterTail tail prepared.norm prepared.normShared prepared.normSafe)
    (AttentionTailConstruction.mlpAfterTail tail prepared.parameters prepared.parametersSafe) where
  base := request.cursor
  aligned := request.aligned
  bounded := request.room
  leftSafe := Or.inr request.source
  rightSafe := Or.inr request.update
  normSafe := Or.inr request.norm
  parametersSafe := (trellis_regions prepared.parameters _ _ _).mpr
    (prepared.parameters.protected_mono (fun _ _ below => Or.inr below) request.parameters)

def allocation : AttentionTailConstruction.SuffixAllocation tail prepared.source prepared.shared prepared.safe
    prepared.norm prepared.normShared prepared.normSafe prepared.parameters prepared.parametersSafe :=
  (workspace tail prepared request).allocation rfl

theorem suffix_safe (below : Before request.cursor base size) :
    ResidualMlpMemory.Safe (AttentionSuffixAllocation.existing tail prepared (allocation tail prepared request)) base size :=
  (workspace tail prepared request).protect rfl (Or.inr below)

def plan : AttentionSuffixAllocation.Plan tail prepared where
  allocation := allocation tail prepared request
  keys := suffix_safe tail prepared request request.keys
  values := suffix_safe tail prepared request request.values

def execution : AttentionResidualMemory.Execution tail block x :=
  AttentionSuffixAllocation.execution tail prepared (plan tail prepared request)

theorem execution_suffix : (execution tail prepared request).suffix=(workspace tail prepared request).execution rfl := rfl

attribute [local irreducible] ResidualMlpMemory.Execution.outputBuffer

theorem output_base : (execution tail prepared request).outputBuffer.base=request.cursor+720896 :=
  (workspace tail prepared request).output_base rfl

private theorem end_bound {cursor address : Nat} (same : address=cursor+720896) :
    Before (cursor+ResidualMlpAllocation.bytes) address 10240 := by
  unfold Before ResidualMlpAllocation.bytes
  omega

theorem output_bound : Before (request.cursor+ResidualMlpAllocation.bytes) (execution tail prepared request).outputBuffer.base 10240 :=
  end_bound (output_base tail prepared request)

theorem suffix_frame (below : Before request.cursor base size) (offset : Nat) (bound : offset<size) :
    (execution tail prepared request).outputBuffer.bytes (base+offset)=tail.buffer.bytes (base+offset) :=
  (congrArg (fun e => e.outputBuffer.bytes (base+offset)) (execution_suffix tail prepared request)).trans
    ((workspace tail prepared request).other_region rfl (Or.inr below) offset bound)

private theorem cache_geometry (run : AttentionResidualMemory.Execution tail block x) (cursor : Nat)
    (keys : Before cursor tail.afterCache.layout.keyBase (KvRegions.bytes steps))
    (values : Before cursor tail.afterCache.layout.valueBase (KvRegions.bytes steps)) :
    Before cursor run.afterCache.layout.keyBase (KvRegions.bytes steps) ∧
      Before cursor run.afterCache.layout.valueBase (KvRegions.bytes steps) := ⟨keys,values⟩

theorem cache_bounds :
    Before (request.cursor+ResidualMlpAllocation.bytes) (execution tail prepared request).afterCache.layout.keyBase (KvRegions.bytes steps) ∧
    Before (request.cursor+ResidualMlpAllocation.bytes) (execution tail prepared request).afterCache.layout.valueBase (KvRegions.bytes steps) :=
  cache_geometry tail (execution tail prepared request) (request.cursor+ResidualMlpAllocation.bytes)
    (request.keys.trans (Nat.le_add_right _ _)) (request.values.trans (Nat.le_add_right _ _))

theorem next_aligned : (request.cursor+ResidualMlpAllocation.bytes)%16=0 := by
  have := request.aligned
  unfold ResidualMlpAllocation.bytes
  omega

end Inference.Models.Qwen.AttentionSuffixHighWater
