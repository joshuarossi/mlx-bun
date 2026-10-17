import models.qwen.AttentionAffine
import layers.AffineMemoryFrames

namespace Inference.Models.Qwen.AttentionAffineMemory
open Contracts.Mlx Layers
set_option maxRecDepth 10000

structure Execution (p : AttentionHeads.Projections) (input : Fin 5120 → ArrayStorage.BF) where
  q : AffineMemory.Execution (groups := 3072) p.q input
  k : AffineMemory.Execution (groups := 256) p.k input
  v : AffineMemory.Execution (groups := 256) p.v input
  keyInput : k.source=AffineMemoryFrames.sourceAfter q
  valueInput : v.source=AffineMemoryFrames.sourceAfter k
  keyQuery : MemoryRegions.Disjoint k.base 2048 q.forwardBuffer.base 24576
  valueQuery : MemoryRegions.Disjoint v.base 2048 q.forwardBuffer.base 24576
  valueKey : MemoryRegions.Disjoint v.base 2048 k.forwardBuffer.base 2048

variable {p : AttentionHeads.Projections} {input : Fin 5120 → ArrayStorage.BF}

def Execution.source (execution : Execution p input) : ArrayStorage.BFBuffer input := execution.q.source
def Execution.memory (execution : Execution p input) : ByteMemory.Bytes := execution.v.outputBuffer.bytes

theorem Execution.key_memory (execution : Execution p input) : execution.k.source.bytes=execution.q.outputBuffer.bytes :=
  congrArg ArrayStorage.BFBuffer.bytes execution.keyInput

theorem Execution.value_memory (execution : Execution p input) : execution.v.source.bytes=execution.k.outputBuffer.bytes :=
  congrArg ArrayStorage.BFBuffer.bytes execution.valueInput

def Execution.queryGateBuffer (execution : Execution p input) : ArrayStorage.BFBuffer (p.q.forward input) :=
  ArrayFrame.bf execution.q.forwardBuffer execution.memory (by
    intro offset bound
    have key := execution.k.other_region execution.keyQuery offset bound
    have value := execution.v.other_region execution.valueQuery offset bound
    rw [execution.key_memory] at key
    rw [execution.value_memory] at value
    exact value.trans key)

def Execution.keyBuffer (execution : Execution p input) : ArrayStorage.BFBuffer (p.k.forward input) :=
  ArrayFrame.bf execution.k.forwardBuffer execution.memory (by
    intro offset bound
    exact (execution.v.other_region execution.valueKey offset bound).trans (congrFun execution.value_memory _))

def Execution.valueBuffer (execution : Execution p input) : ArrayStorage.BFBuffer (p.v.forward input) := execution.v.forwardBuffer

-- Q and gate are views of alternating 256-coordinate halves. They retain
-- their original addresses while K and V are computed on the same heap.
def Execution.query (execution : Execution p input) (head : Fin 24) :
    ArrayStorage.BFBuffer ((p.forward input).query head) :=
  ArrayViews.slice execution.queryGateBuffer (head.val*512) 256 (by have := head.isLt; omega)

def Execution.gate (execution : Execution p input) (head : Fin 24) :
    ArrayStorage.BFBuffer ((p.forward input).gate head) :=
  ArrayViews.slice execution.queryGateBuffer (head.val*512+256) 256 (by have := head.isLt; omega)

def Execution.key (execution : Execution p input) (head : Fin 4) :
    ArrayStorage.BFBuffer ((p.forward input).key head) :=
  ArrayViews.slice execution.keyBuffer (head.val*256) 256 (by have := head.isLt; omega)

def Execution.value (execution : Execution p input) (head : Fin 4) :
    ArrayStorage.BFBuffer ((p.forward input).value head) :=
  ArrayViews.slice execution.valueBuffer (head.val*256) 256 (by have := head.isLt; omega)

theorem Execution.buffers_shared (execution : Execution p input) :
    (∀ head, (execution.query head).bytes=execution.memory) ∧
    (∀ head, (execution.gate head).bytes=execution.memory) ∧
    (∀ head, (execution.key head).bytes=execution.memory) ∧
    (∀ head, (execution.value head).bytes=execution.memory) := ⟨fun _ => rfl, fun _ => rfl, fun _ => rfl, fun _ => rfl⟩

def Execution.read (execution : Execution p input) : AttentionHeads.Heads ArrayStorage.BF :=
  ⟨fun head => (execution.query head).read, fun head => (execution.key head).read,
    fun head => (execution.value head).read, fun head => (execution.gate head).read⟩

theorem Execution.read_eq (execution : Execution p input) : execution.read=p.forward input := by
  unfold Execution.read
  have query : (fun head => (execution.query head).read)=(p.forward input).query :=
    funext fun _ => funext (ArrayStorage.BFBuffer.read_correct _)
  have key : (fun head => (execution.key head).read)=(p.forward input).key :=
    funext fun _ => funext (ArrayStorage.BFBuffer.read_correct _)
  have value : (fun head => (execution.value head).read)=(p.forward input).value :=
    funext fun _ => funext (ArrayStorage.BFBuffer.read_correct _)
  have gate : (fun head => (execution.gate head).read)=(p.forward input).gate :=
    funext fun _ => funext (ArrayStorage.BFBuffer.read_correct _)
  rw [query, key, value, gate]

def Safe (execution : Execution p input) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint execution.q.base 24576 base size ∧
  MemoryRegions.Disjoint execution.k.base 2048 base size ∧ MemoryRegions.Disjoint execution.v.base 2048 base size

theorem Execution.other_region (execution : Execution p input) {base size : Nat}
    (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.memory (base+offset)=execution.source.bytes (base+offset) := by
  have query := execution.q.other_region safe.1 offset bound
  have key := execution.k.other_region safe.2.1 offset bound
  have value := execution.v.other_region safe.2.2 offset bound
  rw [execution.key_memory] at key
  rw [execution.value_memory] at value
  exact value.trans (key.trans query)

end Inference.Models.Qwen.AttentionAffineMemory
