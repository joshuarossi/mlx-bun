import kernels.attention.SdpaLoads
import state.KvGrowthPairMemory

namespace Inference.Kernels.Attention.SdpaMemory
open Contracts.Mlx State
set_option maxRecDepth 10000
attribute [local irreducible] Copy2DMemory.programs CopyExecution.Trace.memory

-- All three SDPA operands read the same heap. Cache views translate the
-- physical base; they do not encode a fresh copy of the logical history.
structure Input (query : Fin 24 → Fin 256 → ArrayStorage.BF) (cache : Kv.Cache Kv.BF steps) where
  cache : KvRegions.Storage cache
  query : ∀ head, ArrayStorage.BFBuffer (query head)
  shared : ∀ head, (query head).bytes=cache.memory

variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF steps}

def Input.storage (input : Input query cache) : SdpaLoads.Storage query cache.keys cache.values where
  query := input.query
  keys := {
    bytes := input.cache.local.keys
    capacity := KvAllocation.capacity steps
    room := (KvAllocation.capacity_bounds steps).1
    attached := input.cache.local.keysAttached }
  values := {
    bytes := input.cache.local.values
    capacity := KvAllocation.capacity steps
    room := (KvAllocation.capacity_bounds steps).1
    attached := input.cache.local.valuesAttached }

theorem Input.key_load (input : Input query cache) (head : Fin 4) (time : Fin steps) (i : Fin 256) :
    HalfMemory.load input.storage.keys.bytes (2*SdpaLoads.address input.storage.keys.capacity head time.val i)=
      HalfMemory.load input.cache.memory (input.cache.layout.keyBase+2*Kv.address (KvAllocation.capacity steps) head time.val i) :=
  input.cache.key_load head time i

theorem Input.value_load (input : Input query cache) (head : Fin 4) (time : Fin steps) (i : Fin 256) :
    HalfMemory.load input.storage.values.bytes (2*SdpaLoads.address input.storage.values.capacity head time.val i)=
      HalfMemory.load input.cache.memory (input.cache.layout.valueBase+2*Kv.address (KvAllocation.capacity steps) head time.val i) :=
  input.cache.value_load head time i

theorem Input.query_load (input : Input query cache) (head : Fin 24) (i : Fin 256) :
    HalfMemory.load (input.storage.query head).bytes ((input.storage.query head).base+2*i.val)=
      HalfMemory.load input.cache.memory ((input.query head).base+2*i.val) :=
  congrArg (fun memory => HalfMemory.load memory ((input.query head).base+2*i.val)) (input.shared head)

def Input.execution (input : Input query cache) (p : SdpaVector.Platform) (contracted : Bool) (arch : Char) :
    SdpaLoads.Execution p contracted arch query cache.keys cache.values :=
  SdpaLoads.Execution.fromStorage p contracted arch query cache.keys cache.values input.storage

theorem Input.output_eq (input : Input query cache) (p : SdpaVector.Platform) (contracted : Bool) (arch : Char)
    (head : Fin 24) (i : Fin 256) :
    (input.execution p contracted arch).output head i=
      SdpaDispatched.forward p contracted arch (query head)
        (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head)) i :=
  (input.execution p contracted arch).output_eq head i

variable {n : Nat} {old : Kv.Cache Kv.BF n} {key value : KvBytes.Row}

theorem append_frame (updated : KvCacheMemory.Execution old key value) {base size : Nat}
    (keySeparate : MemoryRegions.Disjoint updated.keys.base (KvRegions.bytes (n+1)) base size)
    (valueSeparate : MemoryRegions.Disjoint updated.values.base (KvRegions.bytes (n+1)) base size)
    (offset : Nat) (bound : offset<size) :
    updated.after.memory (base+offset)=updated.keys.copy.before (base+offset) := by
  have keyFrame := updated.keys.other_region (by rw [updated.keyCapacity]; exact keySeparate) offset bound
  have valueFrame := updated.values.other_region (by rw [updated.valueCapacity]; exact valueSeparate) offset bound
  exact valueFrame.trans ((congrFun updated.linked (base+offset)).trans keyFrame)

def afterAppend (updated : KvCacheMemory.Execution old key value)
    (queries : ∀ head, ArrayStorage.BFBuffer (query head))
    (shared : ∀ head, (queries head).bytes=updated.keys.copy.before)
    (keySeparate : ∀ head, MemoryRegions.Disjoint updated.keys.base (KvRegions.bytes (n+1)) (queries head).base 512)
    (valueSeparate : ∀ head, MemoryRegions.Disjoint updated.values.base (KvRegions.bytes (n+1)) (queries head).base 512) :
    Input query (Kv.append old key value) where
  cache := updated.after
  query := fun head => ArrayFrame.bf (queries head) updated.after.memory (by
    intro offset bound
    exact (append_frame updated (keySeparate head) (valueSeparate head) offset bound).trans
      (congrFun (shared head) ((queries head).base+offset)).symm)
  shared := fun _ => rfl

theorem afterAppend_memory (updated : KvCacheMemory.Execution old key value)
    (queries : ∀ head, ArrayStorage.BFBuffer (query head))
    (shared : ∀ head, (queries head).bytes=updated.keys.copy.before)
    (keySeparate : ∀ head, MemoryRegions.Disjoint updated.keys.base (KvRegions.bytes (n+1)) (queries head).base 512)
    (valueSeparate : ∀ head, MemoryRegions.Disjoint updated.values.base (KvRegions.bytes (n+1)) (queries head).base 512) :
    (afterAppend updated queries shared keySeparate valueSeparate).cache.memory=updated.values.copy.memory := rfl

-- Growth also writes zero-fill temporaries and new allocations. Preserving
-- queries across just the final row copies would miss those four dispatches.
structure GrowthInput (query : Fin 24 → Fin 256 → ArrayStorage.BF) (growth : KvGrowthPairMemory.Execution old) where
  query : ∀ head, ArrayStorage.BFBuffer (query head)
  shared : ∀ head, (query head).bytes=growth.keys.zeros.before
  keyZero : ∀ head, MemoryRegions.Disjoint (2*growth.keyLayout.zeroBase) 524288 (query head).base 512
  keyDestination : ∀ head, MemoryRegions.Disjoint (2*growth.keyLayout.destination) (2*(4*(n+256)*256)) (query head).base 512
  valueZero : ∀ head, MemoryRegions.Disjoint (2*growth.valueLayout.zeroBase) 524288 (query head).base 512
  valueDestination : ∀ head, MemoryRegions.Disjoint (2*growth.valueLayout.destination) (2*(4*(n+256)*256)) (query head).base 512

variable {growth : KvGrowthPairMemory.Execution old}

def GrowthInput.queries (input : GrowthInput query growth) (head : Fin 24) : ArrayStorage.BFBuffer (query head) :=
  ArrayFrame.bf (input.query head) growth.prepared.memory (by
    intro offset bound
    exact (growth.other_region (input.keyZero head) (input.keyDestination head)
      (input.valueZero head) (input.valueDestination head) offset bound).trans
        (congrFun (input.shared head) ((input.query head).base+offset)).symm)

def GrowthInput.afterAppend (input : GrowthInput query growth) (updated : KvCacheMemory.Execution old key value)
    (initial : updated.keys.copy.before=growth.prepared.memory)
    (keyBase : updated.keys.base=2*growth.keyLayout.destination)
    (valueBase : updated.values.base=2*growth.valueLayout.destination) : Input query (Kv.append old key value) :=
  SdpaMemory.afterAppend updated input.queries (fun _ => initial.symm)
    (by
      intro head
      change MemoryRegions.Disjoint updated.keys.base (KvRegions.bytes (n+1)) (input.query head).base 512
      rw [keyBase]
      unfold KvRegions.bytes
      rw [growth.capacity_next]
      exact input.keyDestination head)
    (by
      intro head
      change MemoryRegions.Disjoint updated.values.base (KvRegions.bytes (n+1)) (input.query head).base 512
      rw [valueBase]
      unfold KvRegions.bytes
      rw [growth.capacity_next]
      exact input.valueDestination head)

def GrowthInput.append (input : GrowthInput query growth)
    (keySource : KvCopy.Source key) (valueSource : KvCopy.Source value)
    (keyShared : keySource.bytes=growth.keys.zeros.before) (valueShared : valueSource.bytes=growth.keys.zeros.before)
    (keySafe : KvGrowthPairMemory.SourceSafe growth keySource) (valueSafe : KvGrowthPairMemory.SourceSafe growth valueSource) :
    Input query (Kv.append old key value) :=
  input.afterAppend (growth.append keySource valueSource keyShared valueShared keySafe valueSafe) rfl rfl rfl

end Inference.Kernels.Attention.SdpaMemory
