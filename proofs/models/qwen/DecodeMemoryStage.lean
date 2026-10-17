import models.qwen.DeltaMemoryStage
import models.qwen.ResidualAttentionMemory

namespace Inference.Models.Qwen.DecodeMemoryStage
open Contracts.Mlx DecodeStage DecodeChain Kernels.Attention
set_option maxRecDepth 10000

-- The stage sum contains the concrete shared-heap layer executions. Its
-- numerical equations are consequences of those proofs, not interface fields.
def Execution : (stage : Stage) → Cache stage n → Row BF → RopeAngles.Inputs → Type
  | .delta layer, cache, input, _ => ResidualDeltaMemory.Execution layer cache input
  | .attention layer, cache, input, angle => ResidualAttentionMemory.Execution layer cache input angle

def source : (stage : Stage) → (cache : Cache stage n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    Execution stage cache input angle → ArrayStorage.BFBuffer input
  | .delta _, _, _, _, execution => execution.entry.source.lhs
  | .attention _, _, _, _, execution => execution.source

def output : (stage : Stage) → (cache : Cache stage n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    Execution stage cache input angle → Row BF
  | .delta _, _, _, _, execution => execution.output
  | .attention _, _, _, _, execution => execution.output

def outputBuffer : (stage : Stage) → (cache : Cache stage n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (execution : Execution stage cache input angle) → ArrayStorage.BFBuffer (output stage cache input angle execution)
  | .delta _, _, _, _, execution => execution.outputBuffer
  | .attention _, _, _, _, execution => execution.outputBuffer

theorem output_eq (stage : Stage) (cache : Cache stage n) (input : Row BF) (angle : RopeAngles.Inputs)
    (execution : Execution stage cache input angle) : output stage cache input angle execution=forward stage cache input angle := by
  cases stage with
  | delta layer => exact execution.output_eq
  | attention layer => exact execution.output_eq

def forwardBuffer (stage : Stage) (cache : Cache stage n) (input : Row BF) (angle : RopeAngles.Inputs)
    (execution : Execution stage cache input angle) : ArrayStorage.BFBuffer (forward stage cache input angle) :=
  ArrayViews.reindex (output_eq stage cache input angle execution) (outputBuffer stage cache input angle execution)

theorem forward_bytes (stage : Stage) (cache : Cache stage n) (input : Row BF) (angle : RopeAngles.Inputs)
    (execution : Execution stage cache input angle) :
    (forwardBuffer stage cache input angle execution).bytes=(outputBuffer stage cache input angle execution).bytes :=
  ArrayViews.reindex_bytes _ _

attribute [local irreducible] forwardBuffer
  ResidualDeltaMemory.Execution.outputBuffer ResidualAttentionMemory.Execution.outputBuffer

def before : (stage : Stage) → (cache : Cache stage n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (execution : Execution stage cache input angle) →
    DecodeFrame.StageBuffer stage cache (source stage cache input angle execution).bytes
  | .delta _, _, _, _, execution => DeltaMemoryStage.before execution n
  | .attention _, _, _, _, execution => ⟨execution.storage, execution.shared⟩

def after : (stage : Stage) → (cache : Cache stage n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (execution : Execution stage cache input angle) →
    DecodeFrame.StageBuffer stage (cacheAfter stage cache input angle) (forwardBuffer stage cache input angle execution).bytes
  | .delta layer, cache, input, angle, execution =>
    ⟨DeltaMemoryStage.afterStorage execution, (DeltaMemoryStage.after_memory execution).trans
      (forward_bytes (.delta layer) cache input angle execution).symm⟩
  | .attention layer, cache, input, angle, execution =>
    ⟨execution.afterCache, execution.cache_output_shared.trans
      (forward_bytes (.attention layer) cache input angle execution).symm⟩

def Safe : (stage : Stage) → (cache : Cache stage n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    Execution stage cache input angle → Nat → Nat → Prop
  | .delta _, _, _, _, execution => ResidualDeltaMemory.Safe execution
  | .attention _, _, _, _, execution => ResidualAttentionMemory.Safe execution

theorem other_region (stage : Stage) (cache : Cache stage n) (input : Row BF) (angle : RopeAngles.Inputs)
    (execution : Execution stage cache input angle) {base size : Nat}
    (safe : Safe stage cache input angle execution base size) (offset : Nat) (bound : offset<size) :
    (forwardBuffer stage cache input angle execution).bytes (base+offset)=
      (source stage cache input angle execution).bytes (base+offset) := by
  rw [forward_bytes]
  cases stage with
  | delta layer => exact execution.other_region safe offset bound
  | attention layer => exact execution.other_region safe offset bound

structure Trace (stage : Stage) (cache : Cache stage n) (input : Row BF) (angle : RopeAngles.Inputs)
    (inputBuffer : ArrayStorage.BFBuffer input) (storage : DecodeFrame.StageBuffer stage cache inputBuffer.bytes) where
  execution : Execution stage cache input angle
  inputLinked : source stage cache input angle execution=inputBuffer
  cacheLinked : (before stage cache input angle execution).storage=storage.storage

variable {stage : Stage} {cache : Cache stage n} {input : Row BF} {angle : RopeAngles.Inputs}
  {inputBuffer : ArrayStorage.BFBuffer input} {storage : DecodeFrame.StageBuffer stage cache inputBuffer.bytes}

def Trace.buffer (trace : Trace stage cache input angle inputBuffer storage) :
    ArrayStorage.BFBuffer (forward stage cache input angle) := forwardBuffer stage cache input angle trace.execution

def Trace.Safe (trace : Trace stage cache input angle inputBuffer storage) : Nat → Nat → Prop :=
  DecodeMemoryStage.Safe stage cache input angle trace.execution

theorem Trace.other_region (trace : Trace stage cache input angle inputBuffer storage) {base size : Nat}
    (safe : trace.Safe base size) (offset : Nat) (bound : offset<size) :
    trace.buffer.bytes (base+offset)=inputBuffer.bytes (base+offset) :=
  (DecodeMemoryStage.other_region stage cache input angle trace.execution safe offset bound).trans
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

end Inference.Models.Qwen.DecodeMemoryStage
