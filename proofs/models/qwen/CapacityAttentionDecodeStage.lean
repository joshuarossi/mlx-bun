import models.qwen.AttentionGateCopyCapacityStageCache
import models.qwen.DecodeMemoryStage
import models.qwen.ResidualDeltaStorageConstruction
namespace Inference.Models.Qwen.CapacityAttentionDecodeStage
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention
set_option maxRecDepth 10000
variable {n : Nat}

abbrev Delta (layer : ResidualDelta.Layer) (cache : DeltaNet.Cache) (input : Row BF) :=
  (source : ResidualDeltaStorageConstruction.Source layer cache input) × ResidualDeltaStorageConstruction.Plan source

def deltaExecution (execution : Delta layer cache input) : ResidualDeltaMemory.Execution layer cache input :=
  ResidualDeltaStorageConstruction.fromStorage execution.1 execution.2

attribute [local irreducible] deltaExecution DecodeMemoryStage.source DecodeMemoryStage.forwardBuffer
  DecodeMemoryStage.before DecodeMemoryStage.after DecodeMemoryStage.Safe
  AttentionGateCopyCapacityResidualStage.forwardBuffer AttentionGateCopyCapacityResidualStage.afterCache AttentionGateCopyCapacityStageCache.before

-- The attention alternative retains the new copied source events. It cannot
-- be coerced to the old attention Prefix, which omitted the gate-copy writes.
def Execution : (kind : Stage) → Cache kind n → Row BF → RopeAngles.Inputs → Type
  | .delta layer, cache, input, _ => Delta layer cache input
  | .attention layer, cache, input, angle =>
    {plan : AttentionGateCopyCapacityResidualStage.Plan layer cache input angle // AttentionGateCopyCapacityStageCache.Safe plan}

structure View (kind : Stage) (cache : Cache kind n) (input : Row BF) (angle : RopeAngles.Inputs) where
  source : ArrayStorage.BFBuffer input
  buffer : ArrayStorage.BFBuffer (forward kind cache input angle)
  before : DecodeFrame.StageBuffer kind cache source.bytes
  after : DecodeFrame.StageBuffer kind (cacheAfter kind cache input angle) buffer.bytes
  Safe : Nat → Nat → Prop
  otherRegion : ∀ base size, Safe base size → ∀ offset<size, buffer.bytes (base+offset)=source.bytes (base+offset)

def view : (kind : Stage) → (cache : Cache kind n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    Execution kind cache input angle → View kind cache input angle
  | .delta layer, cache, input, angle, execution => {
    source := DecodeMemoryStage.source (n:=n) (.delta layer) cache input angle (deltaExecution execution)
    buffer := DecodeMemoryStage.forwardBuffer (n:=n) (.delta layer) cache input angle (deltaExecution execution)
    before := DecodeMemoryStage.before (n:=n) (.delta layer) cache input angle (deltaExecution execution)
    after := DecodeMemoryStage.after (n:=n) (.delta layer) cache input angle (deltaExecution execution)
    Safe := DecodeMemoryStage.Safe (n:=n) (.delta layer) cache input angle (deltaExecution execution)
    otherRegion := fun _ _ safe offset bound => DecodeMemoryStage.other_region (n:=n) (.delta layer) cache input angle (deltaExecution execution) safe offset bound }
  | .attention _, _, _, _, execution => {
    source := execution.val.input.lhs
    buffer := AttentionGateCopyCapacityResidualStage.forwardBuffer execution.val
    before := ⟨AttentionGateCopyCapacityStageCache.before execution.val execution.property,AttentionGateCopyCapacityStageCache.before_memory execution.val execution.property⟩
    after := ⟨AttentionGateCopyCapacityResidualStage.afterCache execution.val,AttentionGateCopyCapacityResidualStage.after_shared execution.val⟩
    Safe := AttentionGateCopyCapacityResidualStage.Safe execution.val
    otherRegion := fun _ _ safe offset bound => AttentionGateCopyCapacityStageCache.forward_frame execution.val safe offset bound }

attribute [local irreducible] view
variable (kind : Stage) (cache : Cache kind n) (input : Row BF) (angle : RopeAngles.Inputs)
  (execution : Execution kind cache input angle)
def source := (view kind cache input angle execution).source
def buffer := (view kind cache input angle execution).buffer
def before := (view kind cache input angle execution).before
def after := (view kind cache input angle execution).after
def Safe := (view kind cache input angle execution).Safe
theorem frame {base size : Nat} (safe : Safe kind cache input angle execution base size) (offset : Nat) (bound : offset<size) :
    (buffer kind cache input angle execution).bytes (base+offset)=(source kind cache input angle execution).bytes (base+offset) :=
  (view kind cache input angle execution).otherRegion base size safe offset bound
variable {kind cache input angle execution}

structure Trace (stage : Stage) (cache : Cache stage n) (input : Row BF) (angle : RopeAngles.Inputs)
    (inputBuffer : ArrayStorage.BFBuffer input) (storage : DecodeFrame.StageBuffer stage cache inputBuffer.bytes) where
  execution : Execution stage cache input angle
  inputLinked : source stage cache input angle execution=inputBuffer
  cacheLinked : (before stage cache input angle execution).storage=storage.storage

variable {stage : Stage} {cache : Cache stage n} {input : Row BF} {angle : RopeAngles.Inputs}
  {inputBuffer : ArrayStorage.BFBuffer input} {storage : DecodeFrame.StageBuffer stage cache inputBuffer.bytes}

def Trace.buffer (trace : Trace stage cache input angle inputBuffer storage) :
    ArrayStorage.BFBuffer (forward stage cache input angle) := CapacityAttentionDecodeStage.buffer stage cache input angle trace.execution

def Trace.Safe (trace : Trace stage cache input angle inputBuffer storage) : Nat → Nat → Prop :=
  CapacityAttentionDecodeStage.Safe stage cache input angle trace.execution

theorem Trace.other_region (trace : Trace stage cache input angle inputBuffer storage) {base size : Nat}
    (safe : trace.Safe base size) (offset : Nat) (bound : offset<size) :
    trace.buffer.bytes (base+offset)=inputBuffer.bytes (base+offset) :=
  (CapacityAttentionDecodeStage.frame stage cache input angle trace.execution safe offset bound).trans
    (congrArg (fun buffer => buffer.bytes (base+offset)) trace.inputLinked)

def Trace.cacheAfter (trace : Trace stage cache input angle inputBuffer storage) :
    DecodeFrame.StageBuffer stage (DecodeStage.cacheAfter stage cache input angle) trace.buffer.bytes :=
  after stage cache input angle trace.execution

def Trace.retained {tokens : Nat} (trace : Trace stage cache input angle inputBuffer storage)
    (stages : List Stage) (cache : Caches stages tokens) (retained : DecodeFrame.Storage stages cache inputBuffer.bytes)
    (safe : DecodePreservation.Protected trace.Safe stages cache inputBuffer.bytes retained) :
    DecodeFrame.Storage stages cache trace.buffer.bytes :=
  DecodePreservation.reframe trace.Safe inputBuffer.bytes trace.buffer.bytes
    (fun _ _ region => trace.other_region region) stages cache retained safe

end Inference.Models.Qwen.CapacityAttentionDecodeStage
