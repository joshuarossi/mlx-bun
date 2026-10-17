import models.qwen.DecodePreservation

namespace Inference.Models.Qwen.DecodeFrameRead
open Contracts.Mlx DecodeStage DecodeChain
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

-- Read every cache directly from the common heap at its physical addresses.
-- The logical cache parameter is used only to type the attached storage.
def stage : (stage : Stage) → (cache : Cache stage n) → (memory : ByteMemory.Bytes) →
    DecodeFrame.StageBuffer stage cache memory → Cache stage n
  | .delta _, _, memory, buffer => {
      history := fun row channel => Model.ofBits (HalfMemory.load memory
        (buffer.storage.buffers.history.base+2*(State.ConvolutionStorage.index row channel).val))
      recurrent := fun head row key => FloatMemory.load memory
        (buffer.storage.buffers.recurrent.base+4*Kernels.Delta.GatedStores.stateIndex head row key) }
  | .attention _, _, memory, buffer => {
      keys := fun head time i => Model.ofBits (HalfMemory.load memory
        (buffer.storage.layout.keyBase+2*State.Kv.address (State.KvAllocation.capacity n) head time.val i))
      values := fun head time i => Model.ofBits (HalfMemory.load memory
        (buffer.storage.layout.valueBase+2*State.Kv.address (State.KvAllocation.capacity n) head time.val i)) }

theorem stage_eq (s : Stage) (cache : Cache s n) (memory : ByteMemory.Bytes)
    (buffer : DecodeFrame.StageBuffer s cache memory) : stage s cache memory buffer=cache := by
  cases s with
  | delta layer =>
    change DeltaNet.Cache.mk _ _=cache
    cases cache with
    | mk history recurrent =>
      congr 1
      · funext row channel
        have attached := buffer.storage.buffers.history.read_correct (State.ConvolutionStorage.index row channel)
        rw [ArrayStorage.BFBuffer.read, show buffer.storage.buffers.history.bytes=memory from buffer.shared] at attached
        exact attached.trans (State.ConvolutionStorage.flatten_index history row channel)
      · funext head row key
        have attached := buffer.storage.buffers.recurrent.attached head row key
        rw [buffer.storage.shared, show buffer.storage.buffers.history.bytes=memory from buffer.shared] at attached
        exact attached
  | attention layer =>
    change State.Kv.Cache.mk _ _=cache
    cases cache with
    | mk keys values =>
      congr 1
      · funext head time i
        have attached := buffer.storage.keys head time i
        rw [show buffer.storage.memory=memory from buffer.shared] at attached
        exact congrArg (fun bits : BitVec 16 => (Model.ofBits bits : BF)) attached
      · funext head time i
        have attached := buffer.storage.values head time i
        rw [show buffer.storage.memory=memory from buffer.shared] at attached
        exact congrArg (fun bits : BitVec 16 => (Model.ofBits bits : BF)) attached

def caches : (stages : List Stage) → (cache : Caches stages n) → (memory : ByteMemory.Bytes) →
    DecodeFrame.Storage stages cache memory → Caches stages n
  | [], _, _, _ => ⟨⟩
  | s::rest, cache, memory, storage =>
    ⟨stage s cache.1 memory storage.1, caches rest cache.2 memory storage.2⟩

theorem caches_eq (stages : List Stage) (cache : Caches stages n) (memory : ByteMemory.Bytes)
    (storage : DecodeFrame.Storage stages cache memory) : caches stages cache memory storage=cache := by
  induction stages with
  | nil =>
    change (PUnit.unit : PUnit)=cache
    cases cache
    rfl
  | cons s rest ih =>
    exact Prod.ext (stage_eq s cache.1 memory storage.1) (ih cache.2 storage.2)

theorem retained (region : Nat → Nat → Prop) (before after : ByteMemory.Bytes)
    (frame : ∀ base size, region base size → ∀ offset < size, after (base+offset)=before (base+offset))
    (stages : List Stage) (cache : Caches stages n) (storage : DecodeFrame.Storage stages cache before)
    (safe : DecodePreservation.Protected region stages cache before storage) :
    caches stages cache after (DecodePreservation.reframe region before after frame stages cache storage safe)=
      caches stages cache before storage :=
  (caches_eq _ _ _ _).trans (caches_eq _ _ _ _).symm

end Inference.Models.Qwen.DecodeFrameRead
