import models.qwen.AttentionReadAllocation
import models.qwen.ResidualDeltaHighWater

namespace Inference.Models.Qwen.AttentionReadHighWater
open Contracts.Mlx Kernels Kernels.Attention State Layers ResidualAttentionConstruction
open ResidualDeltaHighWater (Before Frontier before_mono fresh)
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] Copy2DMemory.programs CopyExecution.Trace.memory KvConcatMemory.programs CopyContiguous.programs

-- Growth advances a proof frontier; it makes no allocator ownership claim.
def next (frontier : Frontier) (n : Nat) : Frontier where
  cursor := frontier.cursor+KvGrowthAllocation.bytes n
  aligned := by have := frontier.aligned; dsimp [KvGrowthAllocation.bytes,KvGrowthAllocation.tensorBytes]; omega

theorem le_next (frontier : Frontier) (n : Nat) : frontier.cursor≤(next frontier n).cursor := by dsimp [next]; omega

theorem growth_zero : KvAllocation.capacity 0<0+1 := by decide

variable {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {original : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  (s : Input layer cache original angle) (frontier : Frontier)
  (capacity : (next frontier n).cursor≤2^64)
  (oldBound : Before frontier.cursor s.storage.layout.keyBase (KvRegions.bytes n) ∧
    Before frontier.cursor s.storage.layout.valueBase (KvRegions.bytes n))
  (live : AttentionReadAllocation.Live s (Before frontier.cursor))
  (growing : KvAllocation.capacity n<n+1)

def workspace : KvGrowthAllocation.Workspace s.oldAfter where
  base := frontier.cursor
  aligned := by have := frontier.aligned; omega
  bounded := capacity
  keys := fresh oldBound.1
  values := fresh oldBound.2

include live in
theorem live_fresh : AttentionReadAllocation.Live s
    (MemoryRegions.Disjoint (workspace s frontier capacity oldBound).base (KvGrowthAllocation.bytes n)) :=
  ⟨fresh live.key,fresh live.value,fun head => fresh (live.queries head),fun head => fresh (live.gates head),fresh live.residual⟩

theorem read_cache_bases_generic (r : ReadPlan s) :
    r.input.cache.layout.keyBase=r.allocation.preparation.storage.layout.keyBase ∧
    r.input.cache.layout.valueBase=r.allocation.preparation.storage.layout.valueBase := ⟨rfl,rfl⟩

theorem read_query_base_generic (r : ReadPlan s) (head : Fin 24) : (r.input.query head).base=(s.front.query head).base := rfl

theorem read_gate_base_generic (r : ReadPlan s) (head : Fin 24) : (r.gates head).base=(s.front.gate head).base := rfl

theorem read_residual_base_generic (r : ReadPlan s) : r.residual.base=s.savedResidual.base := rfl

theorem read_sources_generic (r : ReadPlan s) :
    (r.allocation.append.updated.keys.source.base=s.front.keySource.base ∧
      r.allocation.append.updated.keys.source.rowStride=s.front.keySource.rowStride ∧
      r.allocation.append.updated.keys.source.columnStride=s.front.keySource.columnStride) ∧
    (r.allocation.append.updated.values.source.base=s.front.valueSource.base ∧
      r.allocation.append.updated.values.source.rowStride=s.front.valueSource.rowStride ∧
      r.allocation.append.updated.values.source.columnStride=s.front.valueSource.columnStride) := ⟨⟨rfl,rfl,rfl⟩,⟨rfl,rfl,rfl⟩⟩

theorem read_key_bytes_generic (r : ReadPlan s) : KvAppendMemory.sourceBytes r.allocation.append.updated.keys.source=KvAppendMemory.sourceBytes s.front.keySource := rfl

theorem read_value_bytes_generic (r : ReadPlan s) : KvAppendMemory.sourceBytes r.allocation.append.updated.values.source=KvAppendMemory.sourceBytes s.front.valueSource := rfl

attribute [local irreducible] ReadPlan.input ReadPlan.gates ReadPlan.residual AttentionBlockMemory.Append.updated

def read : ReadPlan s := AttentionReadAllocation.growthRead (workspace s frontier capacity oldBound) growing
  (live_fresh s frontier capacity oldBound live)


theorem cache_layout :
    (read s frontier capacity oldBound live growing).input.cache.layout.keyBase=frontier.cursor+524288 ∧
    (read s frontier capacity oldBound live growing).input.cache.layout.valueBase=frontier.cursor+1048576+KvGrowthAllocation.tensorBytes n :=
  ⟨(read_cache_bases_generic s (read s frontier capacity oldBound live growing)).1.trans ((workspace s frontier capacity oldBound).layout growing).1,
    (read_cache_bases_generic s (read s frontier capacity oldBound live growing)).2.trans ((workspace s frontier capacity oldBound).layout growing).2⟩


theorem cache_bound :
    Before (next frontier n).cursor (read s frontier capacity oldBound live growing).input.cache.layout.keyBase (KvRegions.bytes (n+1)) ∧
    Before (next frontier n).cursor (read s frontier capacity oldBound live growing).input.cache.layout.valueBase (KvRegions.bytes (n+1)) := by
  rw [(cache_layout s frontier capacity oldBound live growing).1,(cache_layout s frontier capacity oldBound live growing).2]
  rw [KvRegions.bytes, ((workspace s frontier capacity oldBound).execution growing).capacity_next]
  dsimp [Before,next,KvGrowthAllocation.bytes,KvGrowthAllocation.tensorBytes]
  omega


theorem query_base (head : Fin 24) : ((read s frontier capacity oldBound live growing).input.query head).base=(s.front.query head).base := read_query_base_generic s _ head

theorem gate_base (head : Fin 24) : ((read s frontier capacity oldBound live growing).gates head).base=(s.front.gate head).base := read_gate_base_generic s _ head

theorem residual_base : (read s frontier capacity oldBound live growing).residual.base=s.savedResidual.base := read_residual_base_generic s _


theorem query_bound (head : Fin 24) : Before (next frontier n).cursor
    ((read s frontier capacity oldBound live growing).input.query head).base 512 := by
  rw [query_base]
  exact before_mono (le_next frontier n) (live.queries head)

theorem gate_bound (head : Fin 24) : Before (next frontier n).cursor
    ((read s frontier capacity oldBound live growing).gates head).base 512 := by
  rw [gate_base]
  exact before_mono (le_next frontier n) (live.gates head)

theorem residual_bound : Before (next frontier n).cursor (read s frontier capacity oldBound live growing).residual.base 10240 := by
  rw [residual_base]
  exact before_mono (le_next frontier n) live.residual


theorem safe {base size : Nat} (prefixSafe : s.front.Safe base size) (bound : Before frontier.cursor base size) :
    (read s frontier capacity oldBound live growing).Safe base size :=
  ⟨prefixSafe,AttentionReadAllocation.growth_append_safe (workspace s frontier capacity oldBound) growing
    (live_fresh s frontier capacity oldBound live) (fresh bound)⟩

theorem other_region {base size : Nat} (prefixSafe : s.front.Safe base size) (bound : Before frontier.cursor base size)
    (offset : Nat) (inside : offset<size) :
    (read s frontier capacity oldBound live growing).input.cache.memory (base+offset)=s.front.entry.source.lhs.bytes (base+offset) :=
  (read s frontier capacity oldBound live growing).other_region (safe s frontier capacity oldBound live growing prefixSafe bound) offset inside



theorem key_source_geometry :
    (read s frontier capacity oldBound live growing).allocation.append.updated.keys.source.base=s.front.keySource.base ∧
    (read s frontier capacity oldBound live growing).allocation.append.updated.keys.source.rowStride=s.front.keySource.rowStride ∧
    (read s frontier capacity oldBound live growing).allocation.append.updated.keys.source.columnStride=s.front.keySource.columnStride := (read_sources_generic s (read s frontier capacity oldBound live growing)).1

theorem value_source_geometry :
    (read s frontier capacity oldBound live growing).allocation.append.updated.values.source.base=s.front.valueSource.base ∧
    (read s frontier capacity oldBound live growing).allocation.append.updated.values.source.rowStride=s.front.valueSource.rowStride ∧
    (read s frontier capacity oldBound live growing).allocation.append.updated.values.source.columnStride=s.front.valueSource.columnStride := (read_sources_generic s (read s frontier capacity oldBound live growing)).2

theorem key_source_bound : Before (next frontier n).cursor
    (read s frontier capacity oldBound live growing).allocation.append.updated.keys.source.base
    (KvAppendMemory.sourceBytes (read s frontier capacity oldBound live growing).allocation.append.updated.keys.source) := by
  rw [(key_source_geometry s frontier capacity oldBound live growing).1,read_key_bytes_generic s]
  exact before_mono (le_next frontier n) live.key

theorem value_source_bound : Before (next frontier n).cursor
    (read s frontier capacity oldBound live growing).allocation.append.updated.values.source.base
    (KvAppendMemory.sourceBytes (read s frontier capacity oldBound live growing).allocation.append.updated.values.source) := by
  rw [(value_source_geometry s frontier capacity oldBound live growing).1,read_value_bytes_generic s]
  exact before_mono (le_next frontier n) live.value


theorem storage_reframe_layout (old : KvRegions.Storage cache) (after : ByteMemory.Bytes)
    (keys : ∀ offset < KvRegions.bytes n, after (old.layout.keyBase+offset)=old.memory (old.layout.keyBase+offset))
    (values : ∀ offset < KvRegions.bytes n, after (old.layout.valueBase+offset)=old.memory (old.layout.valueBase+offset)) :
    (old.reframe after keys values).layout=old.layout := rfl

def oldAfterRead : KvRegions.Storage cache :=
  s.storage.reframe (read s frontier capacity oldBound live growing).input.cache.memory
    (fun offset bound => (other_region s frontier capacity oldBound live growing s.keys oldBound.1 offset bound).trans (congrFun s.shared _).symm)
    (fun offset bound => (other_region s frontier capacity oldBound live growing s.values oldBound.2 offset bound).trans (congrFun s.shared _).symm)


theorem oldAfterRead_layout : (oldAfterRead s frontier capacity oldBound live growing).layout=s.storage.layout :=
  storage_reframe_layout s.storage (read s frontier capacity oldBound live growing).input.cache.memory
    (fun offset bound => (other_region s frontier capacity oldBound live growing s.keys oldBound.1 offset bound).trans (congrFun s.shared _).symm)
    (fun offset bound => (other_region s frontier capacity oldBound live growing s.values oldBound.2 offset bound).trans (congrFun s.shared _).symm)

attribute [local irreducible] oldAfterRead

theorem oldAfterRead_bound :
    Before (next frontier n).cursor (oldAfterRead s frontier capacity oldBound live growing).layout.keyBase (KvRegions.bytes n) ∧
    Before (next frontier n).cursor (oldAfterRead s frontier capacity oldBound live growing).layout.valueBase (KvRegions.bytes n) :=
  by
  rw [oldAfterRead_layout]
  exact ⟨before_mono (le_next frontier n) oldBound.1,before_mono (le_next frontier n) oldBound.2⟩


def bufferAfter {count : Nat} {values : Fin count → ArrayStorage.BF} (buffer : ArrayStorage.BFBuffer values)
    (shared : buffer.bytes=s.front.entry.source.lhs.bytes)
    (prefixSafe : s.front.Safe buffer.base (2*count)) (bound : Before frontier.cursor buffer.base (2*count)) : ArrayStorage.BFBuffer values :=
  ArrayFrame.bf buffer (read s frontier capacity oldBound live growing).input.cache.memory
    (fun offset inside => (other_region s frontier capacity oldBound live growing prefixSafe bound offset inside).trans (congrFun shared _).symm)


def parametersAfter (parameters : DecodeParameterMemory.AttentionStorage layer s.front.entry.source.lhs.bytes)
    (retained : parameters.Protected (fun base size => s.front.Safe base size ∧ Before frontier.cursor base size)) :
    DecodeParameterMemory.AttentionStorage layer (read s frontier capacity oldBound live growing).input.cache.memory :=
  parameters.reframe _ (parameters.protected_mono
    (fun _ _ h => other_region s frontier capacity oldBound live growing h.1 h.2) retained)

theorem parametersAfter_regions (parameters : DecodeParameterMemory.AttentionStorage layer s.front.entry.source.lhs.bytes)
    (retained : parameters.Protected (fun base size => s.front.Safe base size ∧ Before frontier.cursor base size))
    (property : Nat → Nat → Prop) :
    (parametersAfter s frontier capacity oldBound live growing parameters retained).Protected property ↔ parameters.Protected property :=
  parameters.reframe_protected _ _ property

theorem parametersAfter_bound (parameters : DecodeParameterMemory.AttentionStorage layer s.front.entry.source.lhs.bytes)
    (retained : parameters.Protected (fun base size => s.front.Safe base size ∧ Before frontier.cursor base size)) :
    (parametersAfter s frontier capacity oldBound live growing parameters retained).Protected (Before (next frontier n).cursor) :=
  (parametersAfter_regions s frontier capacity oldBound live growing parameters retained _).mpr
    (parameters.protected_mono (fun _ _ h => before_mono (le_next frontier n) h.2) retained)


def retainedCaches {count : Nat} (stages : List DecodeStage.Stage) (caches : DecodeChain.Caches stages count)
    (stored : DecodeFrame.Storage stages caches s.front.entry.source.lhs.bytes)
    (retained : DecodePreservation.Protected (fun base size => s.front.Safe base size ∧ Before frontier.cursor base size)
      stages caches s.front.entry.source.lhs.bytes stored) :
    DecodeFrame.Storage stages caches (read s frontier capacity oldBound live growing).input.cache.memory :=
  DecodePreservation.reframe (fun base size => s.front.Safe base size ∧ Before frontier.cursor base size)
    s.front.entry.source.lhs.bytes _ (fun _ _ h => other_region s frontier capacity oldBound live growing h.1 h.2)
    stages caches stored retained

theorem retainedCaches_bound {count : Nat} (stages : List DecodeStage.Stage) (caches : DecodeChain.Caches stages count)
    (stored : DecodeFrame.Storage stages caches s.front.entry.source.lhs.bytes)
    (retained : DecodePreservation.Protected (fun base size => s.front.Safe base size ∧ Before frontier.cursor base size)
      stages caches s.front.entry.source.lhs.bytes stored) :
    DecodePreservation.Protected (Before (next frontier n).cursor) stages caches _
      (retainedCaches s frontier capacity oldBound live growing stages caches stored retained) :=
  DecodePreservation.preserves_geometry _ _ _ _ _ stages caches stored retained
    (ResidualDeltaHighWater.cacheProtected_mono stages caches stored
      (fun _ _ h => before_mono (le_next frontier n) h.2) retained)

end Inference.Models.Qwen.AttentionReadHighWater
