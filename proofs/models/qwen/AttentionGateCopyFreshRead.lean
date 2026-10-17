import models.qwen.AttentionGateCopyReadConstruction
import state.KvCacheFreshMemory
namespace Inference.Models.Qwen.AttentionGateCopyFreshRead
open Contracts.Mlx State Kernels.Attention
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange CopyContiguous.programs Copy2DMemory.programs CopyExecution.Trace.memory

variable {layer : Attention.Layer} {cache : Kv.Cache Kv.BF n} {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}

-- Growth/reuse prepares the old history first. Each later SliceUpdate has
-- its own ownership choice and full preservation dispatch in this new type.
structure Prepared (s : AttentionGateCopyReadConstruction.Input layer cache values angle) where
  positive : 0<n
  preparation : AttentionBlockMemory.Preparation s.oldAfter
  keySafe : preparation.Safe s.front.keySource.base (KvAppendMemory.sourceBytes s.front.keySource)
  valueSafe : preparation.Safe s.front.valueSource.base (KvAppendMemory.sourceBytes s.front.valueSource)

variable {s : AttentionGateCopyReadConstruction.Input layer cache values angle}

def Prepared.key (p : Prepared s) := p.preparation.source s.front.keySource rfl p.keySafe

def Prepared.value (p : Prepared s) := p.preparation.source s.front.valueSource rfl p.valueSafe

def Prepared.append (p : Prepared s) (allocation : KvCacheFreshMemory.Allocation p.preparation.storage p.key p.value) :
    KvCacheFreshMemory.Execution cache (layer.heads values angle).key (layer.heads values angle).value :=
  ⟨p.preparation.storage,p.key,p.value,rfl,rfl,allocation⟩

structure Read (p : Prepared s) where
  allocation : KvCacheFreshMemory.Allocation p.preparation.storage p.key p.value
  queriesPrepared : ∀ head, p.preparation.Safe (s.front.query head).base 512
  gatesPrepared : ∀ head, p.preparation.Safe (s.front.gate head).base 512
  queries : ∀ head, (p.append allocation).Safe (s.front.query head).base 512
  gates : ∀ head, (p.append allocation).Safe (s.front.gate head).base 512

variable {p : Prepared s} (read : Read p)
def Read.kv := p.append read.allocation

theorem Read.other_region (prepared : p.preparation.Safe base size) (safe : read.kv.Safe base size)
    (offset : Nat) (inside : offset<size) :
    read.kv.after.memory (base+offset)=s.front.memory (base+offset) :=
  (read.kv.other_region safe offset inside).trans (p.preparation.other_region prepared offset inside)

def Read.buffer {x : Fin width → ArrayStorage.BF} (source : ArrayStorage.BFBuffer x)
    (shared : source.bytes=s.front.memory) (prepared : p.preparation.Safe source.base (2*width))
    (safe : read.kv.Safe source.base (2*width)) : ArrayStorage.BFBuffer x :=
  ArrayFrame.bf source read.kv.after.memory (fun offset inside =>
    (read.other_region prepared safe offset inside).trans (congrFun shared _).symm)

def Read.query (head : Fin 24) :=
  read.buffer (s.front.query head) (s.front.shared.1 head) (read.queriesPrepared head) (read.queries head)

def Read.gate (head : Fin 24) :=
  read.buffer (s.front.gate head) (s.front.shared.2.1 head) (read.gatesPrepared head) (read.gates head)

def Read.input : SdpaMemory.Input (layer.heads values angle).query (layer.cacheAfter values angle cache) where
  cache := read.kv.after
  query := read.query
  shared := fun _ => rfl

theorem Read.gates_shared (head : Fin 24) : (read.gate head).bytes=read.input.cache.memory := rfl

theorem Read.query_layout (head : Fin 24) :
    (read.input.query head).base=s.front.rope.query.destination+2*(head.val*256) := s.front.query_base head

theorem Read.query_contiguous :
    ∀ head, (read.input.query head).base=(read.input.query 0).base+2*(head.val*256) := by
  intro head
  rw [read.query_layout head,read.query_layout 0]
  simp

theorem Read.gate_layout (head : Fin 24) :
    (read.gate head).base=2*(s.front.phase.gateCopy.base/2+head.val*256) := by
  change (s.front.gate head).base=_
  rw [s.front.gate_base head]
  have := s.front.phase.gateCopy.aligned
  omega

theorem Read.key_row_starts : read.kv.keys.appended.copy.before=read.kv.keys.preservation.memory := read.kv.keys.appended_before

theorem Read.value_row_starts : read.kv.values.appended.copy.before=read.kv.values.preservation.memory := read.kv.values.appended_before

theorem Read.value_preservation_starts : read.kv.values.source.bytes=read.kv.keys.memory := rfl

-- Both the cache supplied to SDPA and all query/gate views use the final
-- heap after both optional full copies and both ordered row updates.
theorem Read.final_heap : read.input.cache.memory=read.kv.values.appended.copy.memory := rfl
end Inference.Models.Qwen.AttentionGateCopyFreshRead
