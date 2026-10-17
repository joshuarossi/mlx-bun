import models.qwen.AttentionGateCopyFront
import models.qwen.KvInitialKernelMemory

namespace Inference.Models.Qwen.AttentionGateCopyInitialRead
open Contracts.Mlx State Kernels.Attention
set_option maxRecDepth 10000
set_option maxHeartbeats 50000
attribute [local irreducible] List.finRange Copy2D.labels CopyContiguous.programs Copy2DMemory.programs
  CopyExecution.Trace.memory KvInitialPairMemory.fromSources

variable {layer : Attention.Layer} {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {cache : Kv.Cache Kv.BF 0}

def fromFront (front : AttentionGateCopyFront.Execution layer values angle) (layout : KvRegions.Layout 1)
    (allocation : KvInitialPairMemory.Allocation layout front.keySource front.valueSource) :
    KvInitialPairMemory.Execution cache (layer.heads values angle).key (layer.heads values angle).value :=
  KvInitialPairMemory.fromSources front.memory layout front.keySource front.valueSource rfl rfl allocation

theorem fromFront_before (front : AttentionGateCopyFront.Execution layer values angle) (layout : KvRegions.Layout 1)
    (allocation : KvInitialPairMemory.Allocation layout front.keySource front.valueSource) :
    (fromFront (cache:=cache) front layout allocation).before=front.memory := by
  unfold fromFront KvInitialPairMemory.fromSources
  rfl

attribute [local irreducible] fromFront

-- Native first-token initialization installs the zero slabs directly. This
-- route has no zero-length old-cache concatenation or growth-copy dispatch.
structure Read (front : AttentionGateCopyFront.Execution layer values angle) (cache : Kv.Cache Kv.BF 0) where
  layout : KvRegions.Layout 1
  allocation : KvInitialPairMemory.Allocation layout front.keySource front.valueSource
  queries : ∀ head, (fromFront (cache:=cache) front layout allocation).Safe (front.query head).base 512
  gates : ∀ head, (fromFront (cache:=cache) front layout allocation).Safe (front.gate head).base 512

variable {front : AttentionGateCopyFront.Execution layer values angle} (read : Read front cache)

def Read.kv := fromFront (cache:=cache) front read.layout read.allocation

theorem Read.before : read.kv.before=front.memory := fromFront_before front read.layout read.allocation

def Read.query (head : Fin 24) : ArrayStorage.BFBuffer ((layer.heads values angle).query head) :=
  read.kv.bufferAfter (front.query head) ((front.shared.1 head).trans read.before.symm) (read.queries head)

def Read.gate (head : Fin 24) : ArrayStorage.BFBuffer ((layer.heads values angle).gate head) :=
  read.kv.bufferAfter (front.gate head) ((front.shared.2.1 head).trans read.before.symm) (read.gates head)

def Read.input : SdpaMemory.Input (layer.heads values angle).query (layer.cacheAfter values angle cache) where
  cache := read.kv.after
  query := read.query
  shared := fun _ => rfl

theorem Read.gates_shared (head : Fin 24) : (read.gate head).bytes=read.input.cache.memory := rfl

theorem Read.query_layout (head : Fin 24) :
    (read.input.query head).base=front.rope.query.destination+2*(head.val*256) := front.query_base head

theorem Read.query_contiguous :
    ∀ head, (read.input.query head).base=(read.input.query 0).base+2*(head.val*256) := by
  intro head
  rw [read.query_layout head,read.query_layout 0]
  simp

theorem Read.gate_layout (head : Fin 24) :
    (read.gate head).base=2*(front.phase.gateCopy.base/2+head.val*256) := by
  change (front.gate head).base=_
  rw [front.gate_base head]
  have := front.phase.gateCopy.aligned
  omega

theorem Read.other_region (safe : read.kv.Safe base size) (offset : Nat) (bound : offset<size) :
    read.input.cache.memory (base+offset)=front.memory (base+offset) :=
  (read.kv.other_region safe offset bound).trans (congrFun read.before _)

def Read.buffer {x : Fin width → ArrayStorage.BF} (source : ArrayStorage.BFBuffer x)
    (shared : source.bytes=front.memory) (safe : read.kv.Safe source.base (2*width)) : ArrayStorage.BFBuffer x :=
  read.kv.bufferAfter source (shared.trans read.before.symm) safe

end Inference.Models.Qwen.AttentionGateCopyInitialRead
