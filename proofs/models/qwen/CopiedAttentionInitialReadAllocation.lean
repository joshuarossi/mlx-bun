import models.qwen.AttentionGateCopyInitialRead
namespace Inference.Models.Qwen.CopiedAttentionInitialReadAllocation
open Contracts.Mlx Layers State Kernels.Attention
set_option maxRecDepth 10000

def bytes : Nat := 2*KvRegions.bytes 1

private theorem bytes_one : KvRegions.bytes 1=524288 := by norm_num [KvRegions.bytes,KvAllocation.capacity]

structure Request {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
    (front : AttentionGateCopyFront.Execution layer input angle) where
  cursor : Nat
  aligned : cursor%16=0
  room : cursor+bytes≤2^64
  keys : front.keySource.base+KvAppendMemory.sourceBytes front.keySource≤cursor
  values : front.valueSource.base+KvAppendMemory.sourceBytes front.valueSource≤cursor
  queries : ∀ head, (front.query head).base+512≤cursor
  gates : ∀ head, (front.gate head).base+512≤cursor

variable {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {front : AttentionGateCopyFront.Execution layer input angle} (request : Request front)

def layout : KvRegions.Layout 1 where
  keyBase := request.cursor
  valueBase := request.cursor+KvRegions.bytes 1
  keyAligned := by have := request.aligned; omega
  valueAligned := by rw [bytes_one]; have := request.aligned; omega
  keyBound := by have := request.room; unfold bytes at this; omega
  valueBound := by have := request.room; unfold bytes at this; omega
  separate := Or.inl (Nat.le_refl _)

-- This allocator selects the donated SliceUpdate ownership branch explicitly.
-- Native donation eligibility is a separate caller/source attachment.
def allocation : KvInitialPairMemory.Allocation (layout request) front.keySource front.valueSource where
  keySourceBound := by have := request.keys; have := request.room; omega
  valueSourceBound := by have := request.values; have := request.room; omega
  keyChoice := .donated (layout request).keyAligned (by simpa only [bytes_one,KvSlicePreparationMemory.bytes,KvSlicePreparationMemory.Choice.destination] using (layout request).keyBound)
  valueChoice := .donated (layout request).valueAligned (by simpa only [bytes_one,KvSlicePreparationMemory.bytes,KvSlicePreparationMemory.Choice.destination] using (layout request).valueBound)
  keyZerosSafe := ⟨Or.inr request.keys,Or.inr (by have := request.keys; change _≤request.cursor+KvRegions.bytes 1; omega)⟩
  valueZerosSafe := ⟨Or.inr request.values,Or.inr (by have := request.values; change _≤request.cursor+KvRegions.bytes 1; omega)⟩
  keySafe := Or.inr request.keys
  valueSafe := Or.inr (by have := request.values; change _≤request.cursor+KvRegions.bytes 1; omega)
  keyKeepsValueSource := Or.inr request.values
  keyKeepsZeroValues := by simpa only [bytes_one,KvSlicePreparationMemory.bytes,KvSlicePreparationMemory.Choice.destination] using (layout request).separate
  separate := by simpa only [bytes_one,KvSlicePreparationMemory.bytes,KvSlicePreparationMemory.Choice.destination] using (layout request).separate

theorem safe_below {cache : Kv.Cache Kv.BF 0} {base size : Nat} (below : base+size≤request.cursor) :
    (AttentionGateCopyInitialRead.fromFront (cache:=cache) front (layout request) (allocation request)).Safe base size := by
  change KvInitialPairMemory.Safe (layout request) (allocation request) base size
  exact ⟨Or.inr below,Or.inr (by change base+size≤request.cursor+KvRegions.bytes 1; omega),
    Or.inr below,Or.inr (by change base+size≤request.cursor+KvRegions.bytes 1; omega)⟩

def read (cache : Kv.Cache Kv.BF 0) : AttentionGateCopyInitialRead.Read front cache where
  layout := layout request
  allocation := allocation request
  queries := fun head => safe_below request (request.queries head)
  gates := fun head => safe_below request (request.gates head)

theorem frame (cache : Kv.Cache Kv.BF 0) {base size : Nat} (below : base+size≤request.cursor)
    (offset : Nat) (bound : offset<size) :
    (read request cache).input.cache.memory (base+offset)=front.memory (base+offset) :=
  (read request cache).other_region (safe_below request below) offset bound

theorem next_aligned : (request.cursor+bytes)%16=0 := by have := request.aligned; unfold bytes; rw [bytes_one]; omega
end Inference.Models.Qwen.CopiedAttentionInitialReadAllocation
