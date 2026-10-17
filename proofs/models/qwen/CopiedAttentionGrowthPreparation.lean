import models.qwen.CopiedAttentionFreshAppendAllocation
import state.KvGrowthAllocation
namespace Inference.Models.Qwen.CopiedAttentionGrowthPreparation
open Contracts.Mlx Layers State Kernels.Attention
set_option maxRecDepth 10000
variable {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {s : AttentionGateCopyReadConstruction.Input layer cache input angle}

def preparation (w : KvGrowthAllocation.Workspace s.oldAfter) (growing : KvAllocation.capacity n<n+1) :
    AttentionBlockMemory.Preparation s.oldAfter := .growth (w.allocation growing)

theorem safe (w : KvGrowthAllocation.Workspace s.oldAfter) (growing : KvAllocation.capacity n<n+1)
    {base size : Nat} (separate : MemoryRegions.Disjoint w.base (KvGrowthAllocation.bytes n) base size) :
    (preparation w growing).Safe base size := by
  change MemoryRegions.Disjoint (2*(w.base/2)) 524288 base size ∧
    MemoryRegions.Disjoint (2*((w.base+524288)/2)) (2*(4*(n+256)*256)) base size ∧
    MemoryRegions.Disjoint (2*((w.base+524288+KvGrowthAllocation.tensorBytes n)/2)) 524288 base size ∧
    MemoryRegions.Disjoint (2*((w.base+1048576+KvGrowthAllocation.tensorBytes n)/2)) (2*(4*(n+256)*256)) base size
  rw [w.half_bases.1,w.half_bases.2.1,w.half_bases.2.2.1,w.half_bases.2.2.2]
  refine ⟨?_,?_,?_,?_⟩
  · simpa using w.separate (offset:=0) (count:=524288) (by dsimp [KvGrowthAllocation.bytes]; omega) separate
  · exact w.separate (by dsimp [KvGrowthAllocation.bytes,KvGrowthAllocation.tensorBytes]; omega) separate
  · simpa only [Nat.add_assoc] using w.separate (offset:=524288+KvGrowthAllocation.tensorBytes n) (count:=524288)
      (by dsimp [KvGrowthAllocation.bytes]; omega) separate
  · simpa only [Nat.add_assoc] using w.separate (offset:=1048576+KvGrowthAllocation.tensorBytes n) (count:=2*(4*(n+256)*256))
      (by dsimp [KvGrowthAllocation.bytes,KvGrowthAllocation.tensorBytes]; omega) separate

structure Request {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
    {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs} (s : AttentionGateCopyReadConstruction.Input layer cache input angle) where
  positive : 0<n
  growing : KvAllocation.capacity n<n+1
  cursor : Nat
  aligned : cursor%16=0
  room : cursor+(KvGrowthAllocation.bytes n+CopiedAttentionFreshAppendAllocation.bytes n)≤2^64
  oldKeys : s.oldAfter.layout.keyBase+KvRegions.bytes n≤cursor
  oldValues : s.oldAfter.layout.valueBase+KvRegions.bytes n≤cursor
  keys : s.front.keySource.base+KvAppendMemory.sourceBytes s.front.keySource≤cursor
  values : s.front.valueSource.base+KvAppendMemory.sourceBytes s.front.valueSource≤cursor
  queries : ∀ head, (s.front.query head).base+512≤cursor
  gates : ∀ head, (s.front.gate head).base+512≤cursor

variable (request : Request s)
def workspace : KvGrowthAllocation.Workspace s.oldAfter where
  base := request.cursor
  aligned := by have := request.aligned; omega
  bounded := by have := request.room; omega
  keys := Or.inr request.oldKeys
  values := Or.inr request.oldValues

def prepared : AttentionGateCopyFreshRead.Prepared s where
  positive := request.positive
  preparation := preparation (workspace request) request.growing
  keySafe := safe _ _ (Or.inr request.keys)
  valueSafe := safe _ _ (Or.inr request.values)

def appendRequest : CopiedAttentionFreshAppendAllocation.Request (prepared request) where
  cursor := request.cursor+KvGrowthAllocation.bytes n
  aligned := by have := request.aligned; dsimp [KvGrowthAllocation.bytes,KvGrowthAllocation.tensorBytes]; omega
  room := by have := request.room; omega
  oldKeys := by
    change ((workspace request).execution request.growing).prepared.layout.keyBase+KvRegions.bytes (n+1)≤_
    rw [((workspace request).layout request.growing).1,KvRegions.bytes,((workspace request).execution request.growing).capacity_next]
    change request.cursor+524288+2*(4*(n+256)*256)≤request.cursor+KvGrowthAllocation.bytes n
    dsimp [KvGrowthAllocation.bytes,KvGrowthAllocation.tensorBytes]
    omega
  oldValues := by
    change ((workspace request).execution request.growing).prepared.layout.valueBase+KvRegions.bytes (n+1)≤_
    rw [((workspace request).layout request.growing).2,KvRegions.bytes,((workspace request).execution request.growing).capacity_next]
    change request.cursor+1048576+KvGrowthAllocation.tensorBytes n+2*(4*(n+256)*256)≤request.cursor+KvGrowthAllocation.bytes n
    dsimp [KvGrowthAllocation.bytes,KvGrowthAllocation.tensorBytes]
    omega
  keys := by change s.front.keySource.base+KvAppendMemory.sourceBytes s.front.keySource≤_; have := request.keys; omega
  values := by change s.front.valueSource.base+KvAppendMemory.sourceBytes s.front.valueSource≤_; have := request.values; omega
  queriesPrepared := fun head => safe _ _ (Or.inr (request.queries head))
  gatesPrepared := fun head => safe _ _ (Or.inr (request.gates head))
  queries := fun head => (request.queries head).trans (Nat.le_add_right _ _)
  gates := fun head => (request.gates head).trans (Nat.le_add_right _ _)

def read := CopiedAttentionFreshAppendAllocation.read (appendRequest request)

theorem frame {base size : Nat} (below : base+size≤request.cursor) (offset : Nat) (bound : offset<size) :
    (read request).input.cache.memory (base+offset)=s.front.memory (base+offset) :=
  CopiedAttentionFreshAppendAllocation.frame _ (safe _ _ (Or.inr below))
    (below.trans (Nat.le_add_right _ _)) offset bound
end Inference.Models.Qwen.CopiedAttentionGrowthPreparation
