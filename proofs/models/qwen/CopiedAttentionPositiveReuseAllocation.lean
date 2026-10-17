import models.qwen.AttentionGateCopyFreshRead
namespace Inference.Models.Qwen.CopiedAttentionPositiveReuseAllocation
open Contracts.Mlx Layers State Kernels.Attention
set_option maxRecDepth 10000
variable {n : Nat}
def bytes (n : Nat) : Nat := 2*KvRegions.bytes (n+1)

structure Request {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
    {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
    (s : AttentionGateCopyReadConstruction.Input layer cache input angle) where
  positive : 0<n
  reuse : KvAllocation.capacity n=KvAllocation.capacity (n+1)
  cursor : Nat
  aligned : cursor%16=0
  room : cursor+bytes n≤2^64
  oldKeys : s.oldAfter.layout.keyBase+KvRegions.bytes (n+1)≤cursor
  oldValues : s.oldAfter.layout.valueBase+KvRegions.bytes (n+1)≤cursor
  keys : s.front.keySource.base+KvAppendMemory.sourceBytes s.front.keySource≤cursor
  values : s.front.valueSource.base+KvAppendMemory.sourceBytes s.front.valueSource≤cursor
  queries : ∀ head, (s.front.query head).base+512≤cursor
  gates : ∀ head, (s.front.gate head).base+512≤cursor

variable {layer : Attention.Layer} {cache : Kv.Cache Kv.BF n} {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {s : AttentionGateCopyReadConstruction.Input layer cache input angle} (request : Request s)

def prepared : AttentionGateCopyFreshRead.Prepared s where
  positive := request.positive
  preparation := .existing request.reuse
  keySafe := True.intro
  valueSafe := True.intro

def allocation : KvCacheFreshMemory.Allocation (prepared request).preparation.storage (prepared request).key (prepared request).value where
  keyChoice := .copied request.cursor (by have := request.aligned; omega)
    (by rw [KvSliceCapacityPreparation.region_bytes]; have := request.room; unfold bytes at this; omega)
    (by rw [KvSliceCapacityPreparation.region_bytes]; exact Or.inr request.oldKeys)
  valueChoice := .copied (request.cursor+KvRegions.bytes (n+1))
    (by have := request.aligned; unfold KvRegions.bytes; omega)
    (by rw [KvSliceCapacityPreparation.region_bytes]; have := request.room; unfold bytes at this; omega)
    (by rw [KvSliceCapacityPreparation.region_bytes]; exact Or.inr (request.oldValues.trans (Nat.le_add_right _ _)))
  keySafe := Or.inr request.keys
  valueSafe := Or.inr (request.values.trans (Nat.le_add_right _ _))
  keyKeepsValueSource := Or.inr request.values
  keyKeepsOldValues := Or.inr request.oldValues
  separate := Or.inl (Nat.le_refl _)

theorem safe_below {base size : Nat} (below : base+size≤request.cursor) :
    ((prepared request).append (allocation request)).Safe base size :=
  ⟨Or.inr below,Or.inr (below.trans (Nat.le_add_right _ _))⟩

def read : AttentionGateCopyFreshRead.Read (prepared request) where
  allocation := allocation request
  queriesPrepared := fun _ => True.intro
  gatesPrepared := fun _ => True.intro
  queries := fun head => safe_below request (request.queries head)
  gates := fun head => safe_below request (request.gates head)

theorem frame {base size : Nat} (below : base+size≤request.cursor) (offset : Nat) (bound : offset<size) :
    (read request).input.cache.memory (base+offset)=s.front.memory (base+offset) :=
  (read request).other_region True.intro (safe_below request below) offset bound
end Inference.Models.Qwen.CopiedAttentionPositiveReuseAllocation
