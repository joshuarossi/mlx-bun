import models.qwen.InitialStorageZeros

namespace Inference.Models.Qwen.InitialCacheMemory
open Contracts.Mlx DecodeStage Kernels.Delta InitialStorageRegions
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

structure DeltaPlan where
  trace : InitialStorage.DeltaTrace
  layout : Layout

def StagePlan : Stage → Type
  | .delta _ => DeltaPlan
  | .attention _ => PUnit
def Plan : List Stage → Type
  | [] => PUnit
  | stage::rest => StagePlan stage × Plan rest

-- Complete legal store schedules exist for any supplied allocation layout.
def Plan.fromLayouts (layouts : Nat → Layout) (prior : Nat → ByteMemory.Bytes) :
    (stages : List Stage) → Nat → Plan stages
  | [], _ => ⟨⟩
  | .delta _::rest, index =>
    ⟨⟨InitialStorage.DeltaTrace.fromBefore (prior (2*index)) (prior (2*index+1)), layouts index⟩,
      Plan.fromLayouts layouts prior rest (index+1)⟩
  | .attention _::rest, index => ⟨⟨⟩, Plan.fromLayouts layouts prior rest (index+1)⟩

def stageMemory : (stage : Stage) → StagePlan stage → ByteMemory.Bytes → ByteMemory.Bytes
  | .delta _, plan, before => memory plan.trace plan.layout before
  | .attention _, _, before => before

def execute : (stages : List Stage) → Plan stages → ByteMemory.Bytes → ByteMemory.Bytes
  | [], _, before => before
  | stage::rest, plan, before => execute rest plan.2 (stageMemory stage plan.1 before)

def DeltaReady (layout : Layout) (memory : ByteMemory.Bytes) : Prop :=
  (∀ offset < 61440, memory (layout.historyBase+offset)=0) ∧
  (∀ offset < 3145728, memory (layout.recurrentBase+offset)=0)

def StageReady : (stage : Stage) → StagePlan stage → ByteMemory.Bytes → Prop
  | .delta _, plan, memory => DeltaReady plan.layout memory
  | .attention _, _, _ => True

def Ready : (stages : List Stage) → Plan stages → ByteMemory.Bytes → Prop
  | [], _, _ => True
  | stage::rest, plan, memory => StageReady stage plan.1 memory ∧ Ready rest plan.2 memory

theorem stage_ready (stage : Stage) (plan : StagePlan stage) (before : ByteMemory.Bytes) :
    StageReady stage plan (stageMemory stage plan before) := by
  cases stage with
  | delta _ => exact ⟨InitialStorageZeros.history_byte plan.trace plan.layout before,
      InitialStorageZeros.recurrent_byte plan.trace plan.layout before⟩
  | attention _ => trivial

theorem stage_preserves (stage : Stage) (plan : StagePlan stage) (before : ByteMemory.Bytes)
    (address : Nat) (zero : before address=0) : stageMemory stage plan before address=0 := by
  cases stage with
  | delta _ => exact InitialStorageZeros.preserves_zero plan.trace plan.layout before address zero
  | attention _ => exact zero

theorem execute_preserves (stages : List Stage) (plan : Plan stages) (before : ByteMemory.Bytes)
    (address : Nat) (zero : before address=0) : execute stages plan before address=0 := by
  induction stages generalizing before with
  | nil => exact zero
  | cons stage rest ih => exact ih plan.2 _ (stage_preserves stage plan.1 before address zero)

theorem stage_preserved (stage : Stage) (plan : StagePlan stage) (before : ByteMemory.Bytes)
    (ready : StageReady stage plan before) (rest : List Stage) (tail : Plan rest) :
    StageReady stage plan (execute rest tail before) := by
  cases stage with
  | delta _ => exact ⟨fun offset bound => execute_preserves rest tail before _ (ready.1 offset bound),
      fun offset bound => execute_preserves rest tail before _ (ready.2 offset bound)⟩
  | attention _ => trivial

theorem execute_ready (stages : List Stage) (plan : Plan stages) (before : ByteMemory.Bytes) :
    Ready stages plan (execute stages plan before) := by
  induction stages generalizing before with
  | nil => trivial
  | cons stage rest ih =>
    exact ⟨stage_preserved stage plan.1 _ (stage_ready stage plan.1 before) rest plan.2,
      ih plan.2 (stageMemory stage plan.1 before)⟩

private theorem half_zero (memory : ByteMemory.Bytes) (base size address : Nat)
    (zero : ∀ offset < size, memory (base+offset)=0) (bound : address+2 ≤ size) :
    HalfMemory.load memory (base+address)=0 := by
  unfold HalfMemory.load
  rw [Nat.add_assoc, zero _ (by omega), Nat.add_assoc, zero _ (by omega)]
  rfl

private theorem word_zero (memory : ByteMemory.Bytes) (base size address : Nat)
    (zero : ∀ offset < size, memory (base+offset)=0) (bound : address+4 ≤ size) :
    ByteMemory.load32 memory (base+address)=0 := by
  unfold ByteMemory.load32
  rw [Nat.add_assoc, zero _ (by omega), Nat.add_assoc, zero _ (by omega),
    Nat.add_assoc, zero _ (by omega), Nat.add_assoc, zero _ (by omega)]
  rfl

private theorem zero_half : ArrayStorage.bits (InitialStorage.historyZero 0)=0 := by decide +kernel
private theorem zero_word : FloatMemory.decode 0=(0 : Float32) := by decide +kernel

def deltaStorage (layout : Layout) (memory : ByteMemory.Bytes) (ready : DeltaReady layout memory) :
    DeltaDevice.Storage InitialState.delta where
  history := {
    bytes := memory
    base := layout.historyBase
    aligned := layout.historyAligned
    bounded := layout.historyBound
    attached := by
      intro i
      have read := half_zero memory layout.historyBase 61440 (2*i.val) ready.1 (by have := i.isLt; omega)
      rw [← zero_half] at read
      simpa only [InitialStorage.historyZero, InitialState.delta, State.ConvolutionStorage.flatten] using read }
  recurrent := {
    bytes := memory
    base := layout.recurrentBase
    aligned := layout.recurrentAligned
    bounded := layout.recurrentBound
    attached := by
      intro head row key
      change FloatMemory.decode (ByteMemory.load32 memory (layout.recurrentBase+4*GatedStores.stateIndex head row key))=0
      rw [word_zero memory layout.recurrentBase 3145728 _ ready.2 (by
        have := head.isLt; have := row.isLt; have := key.isLt
        dsimp [GatedStores.stateIndex]
        omega), zero_word] }

def stageStorage : (stage : Stage) → (plan : StagePlan stage) → (memory : ByteMemory.Bytes) →
    StageReady stage plan memory → DecodeStorage.StageStorage stage (InitialState.stage stage)
  | .delta _, plan, memory, ready => deltaStorage plan.layout memory ready
  | .attention _, _, memory, _ => InitialStorage.emptyKv memory memory

def storage : (stages : List Stage) → (plan : Plan stages) → (memory : ByteMemory.Bytes) →
    Ready stages plan memory → DecodeStorage.Storage stages (InitialState.caches stages)
  | [], _, _, _ => ⟨⟩
  | stage::rest, plan, memory, ready => ⟨stageStorage stage plan.1 memory ready.1, storage rest plan.2 memory ready.2⟩

def initialized (stages : List Stage) (plan : Plan stages) (before : ByteMemory.Bytes) :
    DecodeStorage.Storage stages (InitialState.caches stages) :=
  storage stages plan (execute stages plan before) (execute_ready stages plan before)

-- Every tensor below points into the same post-initialization memory.
-- This proves initialization contents, not the native allocator's lifetimes
-- or non-aliasing across layers during later inference launches.
theorem delta_history_bytes (layer : ResidualDelta.Layer) (rest : List Stage)
    (plan : Plan (.delta layer::rest)) (before : ByteMemory.Bytes) :
    (initialized (.delta layer::rest) plan before).1.history.bytes=execute (.delta layer::rest) plan before := rfl

theorem delta_recurrent_bytes (layer : ResidualDelta.Layer) (rest : List Stage)
    (plan : Plan (.delta layer::rest)) (before : ByteMemory.Bytes) :
    (initialized (.delta layer::rest) plan before).1.recurrent.bytes=execute (.delta layer::rest) plan before := rfl

theorem next_storage (stage : Stage) (rest : List Stage) (plan : Plan (stage::rest)) (before : ByteMemory.Bytes) :
    (initialized (stage::rest) plan before).2=
      initialized rest plan.2 (stageMemory stage plan.1 before) := rfl

end Inference.Models.Qwen.InitialCacheMemory
