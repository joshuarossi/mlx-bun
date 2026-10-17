import models.qwen.DeltaRegions
import models.qwen.DecodeStorage
import state.KvRegions
import models.qwen.InitialCacheMemory

namespace Inference.Models.Qwen.DecodeFrame
open Contracts.Mlx DecodeStage DecodeChain
set_option maxRecDepth 10000

def StageStorage : (stage : Stage) → Cache stage n → Type
  | .delta _, cache => DeltaRegions.Storage cache
  | .attention _, cache => State.KvRegions.Storage cache

def stageMemory : (stage : Stage) → (cache : Cache stage n) → StageStorage stage cache → ByteMemory.Bytes
  | .delta _, _, storage => storage.memory
  | .attention _, _, storage => storage.memory

def stageLocal : (stage : Stage) → (cache : Cache stage n) → StageStorage stage cache → DecodeStorage.StageStorage stage cache
  | .delta _, _, storage => storage.buffers
  | .attention _, _, storage => storage.local

def StageSeparate : (stage : Stage) → (cache : Cache stage n) → StageStorage stage cache → Nat → Nat → Prop
  | .delta _, _, storage, base, size =>
    MemoryRegions.Disjoint base size storage.buffers.history.base 61440 ∧
      MemoryRegions.Disjoint base size storage.buffers.recurrent.base 3145728
  | .attention _, _, storage, base, size =>
    MemoryRegions.Disjoint base size storage.layout.keyBase (State.KvRegions.bytes n) ∧
      MemoryRegions.Disjoint base size storage.layout.valueBase (State.KvRegions.bytes n)

def stageAfter32 (stores : List ByteMemory.Store) (inside : MemoryRegions.Inside32 base size stores) :
    (stage : Stage) → (cache : Cache stage n) → (storage : StageStorage stage cache) →
    StageSeparate stage cache storage base size → StageStorage stage cache
  | .delta _, _, storage, separate => storage.after32 stores inside separate.1 separate.2
  | .attention _, _, storage, separate => storage.after32 stores inside separate.1 separate.2

def stageAfter16 (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 base size stores) :
    (stage : Stage) → (cache : Cache stage n) → (storage : StageStorage stage cache) →
    StageSeparate stage cache storage base size → StageStorage stage cache
  | .delta _, _, storage, separate => storage.after16 stores inside separate.1 separate.2
  | .attention _, _, storage, separate => storage.after16 stores inside separate.1 separate.2

theorem stage_after32_memory (stores : List ByteMemory.Store) (inside : MemoryRegions.Inside32 base size stores)
    (stage : Stage) (cache : Cache stage n) (storage : StageStorage stage cache) (separate : StageSeparate stage cache storage base size) :
    stageMemory stage cache (stageAfter32 stores inside stage cache storage separate)=ByteMemory.execute stores (stageMemory stage cache storage) := by
  cases stage <;> rfl

theorem stage_after16_memory (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 base size stores)
    (stage : Stage) (cache : Cache stage n) (storage : StageStorage stage cache) (separate : StageSeparate stage cache storage base size) :
    stageMemory stage cache (stageAfter16 stores inside stage cache storage separate)=HalfMemory.execute stores (stageMemory stage cache storage) := by
  cases stage <;> rfl

-- Every stage's cache is attached to a projection of the same heap.
structure StageBuffer (stage : Stage) (cache : Cache stage n) (memory : ByteMemory.Bytes) where
  storage : StageStorage stage cache
  shared : stageMemory stage cache storage=memory

def Storage : (stages : List Stage) → Caches stages n → ByteMemory.Bytes → Type
  | [], _, _ => PUnit
  | stage::rest, cache, memory => StageBuffer stage cache.1 memory × Storage rest cache.2 memory

def localStorage : (stages : List Stage) → (cache : Caches stages n) → (memory : ByteMemory.Bytes) →
    Storage stages cache memory → DecodeStorage.Storage stages cache
  | [], _, _, _ => ⟨⟩
  | stage::rest, cache, memory, storage =>
    ⟨stageLocal stage cache.1 storage.1.storage, localStorage rest cache.2 memory storage.2⟩

def Separate : (stages : List Stage) → (cache : Caches stages n) → (memory : ByteMemory.Bytes) →
    Storage stages cache memory → Nat → Nat → Prop
  | [], _, _, _, _, _ => True
  | stage::rest, cache, memory, storage, base, size =>
    StageSeparate stage cache.1 storage.1.storage base size ∧ Separate rest cache.2 memory storage.2 base size

def after32 (stores : List ByteMemory.Store) (inside : MemoryRegions.Inside32 base size stores) :
    (stages : List Stage) → (cache : Caches stages n) → (memory : ByteMemory.Bytes) → (storage : Storage stages cache memory) →
    Separate stages cache memory storage base size → Storage stages cache (ByteMemory.execute stores memory)
  | [], _, _, _, _ => ⟨⟩
  | stage::rest, cache, memory, storage, separate =>
    ⟨⟨stageAfter32 stores inside stage cache.1 storage.1.storage separate.1,
      by rw [stage_after32_memory, storage.1.shared]⟩,
      after32 stores inside rest cache.2 memory storage.2 separate.2⟩

def after16 (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 base size stores) :
    (stages : List Stage) → (cache : Caches stages n) → (memory : ByteMemory.Bytes) → (storage : Storage stages cache memory) →
    Separate stages cache memory storage base size → Storage stages cache (HalfMemory.execute stores memory)
  | [], _, _, _, _ => ⟨⟩
  | stage::rest, cache, memory, storage, separate =>
    ⟨⟨stageAfter16 stores inside stage cache.1 storage.1.storage separate.1,
      by rw [stage_after16_memory, storage.1.shared]⟩,
      after16 stores inside rest cache.2 memory storage.2 separate.2⟩

-- The next inference call receives the same logical caches attached to
-- the changed heap; its established numerical bounds are therefore retained.
def afterWords {output : Fin m → BitVec 32} (trace : WordArrayWrites.Trace base output)
    (stages : List Stage) (cache : Caches stages n) (storage : Storage stages cache trace.before)
    (separate : Separate stages cache trace.before storage base (4*m)) :
    DecodeStorage.Storage stages cache :=
  localStorage stages cache trace.memory (after32 trace.schedule (ArrayFrame.word_stores_inside trace) stages cache trace.before storage separate)

def afterHalves {output : Fin m → BitVec 16} (trace : HalfArrayWrites.Trace base output)
    (stages : List Stage) (cache : Caches stages n) (storage : Storage stages cache trace.before)
    (separate : Separate stages cache trace.before storage base (2*m)) :
    DecodeStorage.Storage stages cache :=
  localStorage stages cache trace.memory (after16 trace.schedule (ArrayFrame.half_stores_inside trace) stages cache trace.before storage separate)

def initialStage : (stage : Stage) → (plan : InitialCacheMemory.StagePlan stage) → (memory : ByteMemory.Bytes) →
    InitialCacheMemory.StageReady stage plan memory → StageBuffer stage (InitialState.stage stage) memory
  | .delta _, plan, memory, ready =>
    ⟨⟨InitialCacheMemory.deltaStorage plan.layout memory ready, rfl, plan.layout.separate⟩, rfl⟩
  | .attention _, _, memory, _ =>
    ⟨{ layout := {
         keyBase := 0
         valueBase := 0
         keyAligned := by decide
         valueAligned := by decide
         keyBound := by decide
         valueBound := by decide
         separate := Or.inl (by decide) }
       memory := memory
       keys := by intro _ time; exact Fin.elim0 time
       values := by intro _ time; exact Fin.elim0 time }, rfl⟩

def fromInitial : (stages : List Stage) → (plan : InitialCacheMemory.Plan stages) → (memory : ByteMemory.Bytes) →
    InitialCacheMemory.Ready stages plan memory → Storage stages (InitialState.caches stages) memory
  | [], _, _, _ => ⟨⟩
  | stage::rest, plan, memory, ready =>
    ⟨initialStage stage plan.1 memory ready.1, fromInitial rest plan.2 memory ready.2⟩

def initial (stages : List Stage) (plan : InitialCacheMemory.Plan stages) (before : ByteMemory.Bytes) :
    Storage stages (InitialState.caches stages) (InitialCacheMemory.execute stages plan before) :=
  fromInitial stages plan _ (InitialCacheMemory.execute_ready stages plan before)

end Inference.Models.Qwen.DecodeFrame
