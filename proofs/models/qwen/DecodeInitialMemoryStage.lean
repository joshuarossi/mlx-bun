import models.qwen.DecodeMemoryStage
import models.qwen.AttentionInitialResultMemory

namespace Inference.Models.Qwen.DecodeInitialMemoryStage
open Contracts.Mlx DecodeStage DecodeChain Kernels.Attention
set_option maxRecDepth 10000

-- This adapter covers the generic KVCache null-cache branch. Selection of a
-- concrete host cache composition and execution owner is a separate boundary.
-- The first attention invocation installs its zero slabs directly. This sum
-- consumes that concrete execution, rather than an empty-cache concatenation
-- or an assumed equality between their different physical heaps.
structure AttentionExecution (layer : ResidualAttention.Layer) (cache : State.Kv.Cache State.Kv.BF 0)
    (input : Row BF) (angle : RopeAngles.Inputs) where
  front : ResidualAttentionMemory.Prefix layer input angle
  read : AttentionInitialKvMemory.Read front cache
  result : AttentionInitialResultMemory.Execution read

def Execution : (stage : Stage) → Cache stage 0 → Row BF → RopeAngles.Inputs → Type
  | .delta layer, cache, input, _ => ResidualDeltaMemory.Execution layer cache input
  | .attention layer, cache, input, angle => AttentionExecution layer cache input angle

def source : (stage : Stage) → (cache : Cache stage 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    Execution stage cache input angle → ArrayStorage.BFBuffer input
  | .delta _, _, _, _, execution => execution.entry.source.lhs
  | .attention _, _, _, _, execution => execution.front.entry.source.lhs

def output : (stage : Stage) → (cache : Cache stage 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    Execution stage cache input angle → Row BF
  | .delta _, _, _, _, execution => execution.output
  | .attention _, _, _, _, execution => execution.result.output

def outputBuffer : (stage : Stage) → (cache : Cache stage 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (execution : Execution stage cache input angle) → ArrayStorage.BFBuffer (output stage cache input angle execution)
  | .delta _, _, _, _, execution => execution.outputBuffer
  | .attention _, _, _, _, execution => execution.result.outputBuffer

theorem output_eq (stage : Stage) (cache : Cache stage 0) (input : Row BF) (angle : RopeAngles.Inputs)
    (execution : Execution stage cache input angle) : output stage cache input angle execution=forward stage cache input angle := by
  cases stage with
  | delta layer => exact execution.output_eq
  | attention layer => exact execution.result.output_eq

def forwardBuffer (stage : Stage) (cache : Cache stage 0) (input : Row BF) (angle : RopeAngles.Inputs)
    (execution : Execution stage cache input angle) : ArrayStorage.BFBuffer (forward stage cache input angle) :=
  ArrayViews.reindex (output_eq stage cache input angle execution) (outputBuffer stage cache input angle execution)

theorem forward_bytes (stage : Stage) (cache : Cache stage 0) (input : Row BF) (angle : RopeAngles.Inputs)
    (execution : Execution stage cache input angle) :
    (forwardBuffer stage cache input angle execution).bytes=(outputBuffer stage cache input angle execution).bytes :=
  ArrayViews.reindex_bytes _ _

theorem forward_base (stage : Stage) (cache : Cache stage 0) (input : Row BF) (angle : RopeAngles.Inputs)
    (execution : Execution stage cache input angle) :
    (forwardBuffer stage cache input angle execution).base=(outputBuffer stage cache input angle execution).base :=
  ArrayViews.reindex_base _ _

attribute [local irreducible] forwardBuffer ResidualDeltaMemory.Execution.outputBuffer

def after : (stage : Stage) → (cache : Cache stage 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (execution : Execution stage cache input angle) →
    DecodeFrame.StageBuffer stage (cacheAfter stage cache input angle) (forwardBuffer stage cache input angle execution).bytes
  | .delta layer, cache, input, angle, execution =>
    ⟨DeltaMemoryStage.afterStorage execution,(DeltaMemoryStage.after_memory execution).trans
      (forward_bytes (.delta layer) cache input angle execution).symm⟩
  | .attention layer, cache, input, angle, execution =>
    ⟨execution.result.afterCache,execution.result.cache_shared.trans
      (forward_bytes (.attention layer) cache input angle execution).symm⟩

def Safe : (stage : Stage) → (cache : Cache stage 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    Execution stage cache input angle → Nat → Nat → Prop
  | .delta _, _, _, _, execution => ResidualDeltaMemory.Safe execution
  | .attention _, _, _, _, execution => AttentionInitialResultMemory.Safe execution.read execution.result

theorem other_region (stage : Stage) (cache : Cache stage 0) (input : Row BF) (angle : RopeAngles.Inputs)
    (execution : Execution stage cache input angle) {base size : Nat}
    (safe : Safe stage cache input angle execution base size) (offset : Nat) (bound : offset<size) :
    (forwardBuffer stage cache input angle execution).bytes (base+offset)=
      (source stage cache input angle execution).bytes (base+offset) := by
  rw [forward_bytes]
  cases stage with
  | delta layer => exact execution.other_region safe offset bound
  | attention layer => exact AttentionInitialResultMemory.Execution.other_region execution.read execution.result safe offset bound

-- Delta must consume the same physical recurrent/history storage. Attention
-- at position zero has no live prior KV elements and reads no old KV slab.
def CacheLinked : (stage : Stage) → (cache : Cache stage 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (execution : Execution stage cache input angle) → DecodeFrame.StageStorage stage cache → Prop
  | .delta _, _, _, _, execution, storage => (DeltaMemoryStage.before execution 0).storage=storage
  | .attention _, _, _, _, _, _ => True

structure Trace (stage : Stage) (cache : Cache stage 0) (input : Row BF) (angle : RopeAngles.Inputs)
    (inputBuffer : ArrayStorage.BFBuffer input) (storage : DecodeFrame.StageBuffer stage cache inputBuffer.bytes) where
  execution : Execution stage cache input angle
  inputLinked : source stage cache input angle execution=inputBuffer
  cacheLinked : CacheLinked stage cache input angle execution storage.storage

variable {stage : Stage} {cache : Cache stage 0} {input : Row BF} {angle : RopeAngles.Inputs}
  {inputBuffer : ArrayStorage.BFBuffer input} {storage : DecodeFrame.StageBuffer stage cache inputBuffer.bytes}

def Trace.buffer (trace : Trace stage cache input angle inputBuffer storage) :
    ArrayStorage.BFBuffer (forward stage cache input angle) := forwardBuffer stage cache input angle trace.execution

def Trace.Safe (trace : Trace stage cache input angle inputBuffer storage) : Nat → Nat → Prop :=
  DecodeInitialMemoryStage.Safe stage cache input angle trace.execution

theorem Trace.other_region (trace : Trace stage cache input angle inputBuffer storage) {base size : Nat}
    (safe : trace.Safe base size) (offset : Nat) (bound : offset<size) :
    trace.buffer.bytes (base+offset)=inputBuffer.bytes (base+offset) :=
  (DecodeInitialMemoryStage.other_region stage cache input angle trace.execution safe offset bound).trans
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

def delta {layer : ResidualDelta.Layer} {deltaCache : DeltaNet.Cache}
    {deltaStorage : DecodeFrame.StageBuffer (n:=0) (.delta layer) deltaCache inputBuffer.bytes}
    (trace : DecodeMemoryStage.Trace (.delta layer) deltaCache input angle inputBuffer deltaStorage) :
    Trace (.delta layer) deltaCache input angle inputBuffer deltaStorage :=
  ⟨trace.execution,trace.inputLinked,trace.cacheLinked⟩

theorem delta_buffer {layer : ResidualDelta.Layer} {deltaCache : DeltaNet.Cache}
    {deltaStorage : DecodeFrame.StageBuffer (n:=0) (.delta layer) deltaCache inputBuffer.bytes}
    (trace : DecodeMemoryStage.Trace (.delta layer) deltaCache input angle inputBuffer deltaStorage) :
    (delta trace).buffer=trace.buffer := by
  unfold Trace.buffer forwardBuffer DecodeMemoryStage.Trace.buffer DecodeMemoryStage.forwardBuffer
  rfl

theorem delta_cache {layer : ResidualDelta.Layer} {deltaCache : DeltaNet.Cache}
    {deltaStorage : DecodeFrame.StageBuffer (n:=0) (.delta layer) deltaCache inputBuffer.bytes}
    (trace : DecodeMemoryStage.Trace (.delta layer) deltaCache input angle inputBuffer deltaStorage) :
    (delta trace).cacheAfter.storage=trace.cacheAfter.storage := rfl

end Inference.Models.Qwen.DecodeInitialMemoryStage
