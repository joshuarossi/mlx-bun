import kernels.attention.MlxSdpaTwoPassOutputSource

namespace Inference.Kernels.Attention.MlxSdpaTwoPassMergeFrame
open Contracts.Mlx State
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

-- The second-pass native pointer cells read these three typed current-heap
-- regions. BF16 partial numerators widen only after the actual halfword load.
def readState (memory : ByteMemory.Bytes) (sumBase maxBase outputBase blocks : Nat)
    (head : Fin 24) (block : Fin blocks) (i : Fin 256) : SdpaUpdate.State :=
  ⟨FloatMemory.load memory (maxBase+4*SdpaTwoPassLayout.summaryAddress blocks head block),
   FloatMemory.load memory (sumBase+4*SdpaTwoPassLayout.summaryAddress blocks head block),
   BFloat16.widen (Model.ofBits (HalfMemory.load memory
    (outputBase+2*SdpaTwoPassLayout.partialAddress blocks head block i)))⟩

variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF}
  {cache : Kv.Cache Kv.BF steps} {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform}
  {architecture : Char} {contracted : Bool}
  {first : SdpaTwoPassShared.Execution input p (SdpaDispatched.blockCount architecture steps)}

theorem prefix_inside (execution : SdpaTwoPassDonation.Execution first contracted) (stores : List HalfMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ execution.stores.schedule) :
    MemoryRegions.Inside16 execution.stores.base 12288 stores :=
  fun store member => SdpaOutputMemory.stores_inside execution.stores store (subset store member)

theorem protected_state (execution : SdpaTwoPassDonation.Execution first contracted) (stores : List HalfMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ execution.stores.schedule)
    (head : Fin 24) (block : Fin (SdpaDispatched.blockCount architecture steps)) (i : Fin 256) :
    readState (HalfMemory.execute stores first.first.memory) first.first.trace.sumBase first.first.trace.maxBase
      first.first.trace.outputBase (SdpaDispatched.blockCount architecture steps) head block i=
      first.first.readState head block i := by
  have inside := prefix_inside execution stores subset
  have sumSafe := MemoryRegions.disjoint_symm execution.temporarySeparate.1
  have maxSafe := MemoryRegions.disjoint_symm execution.temporarySeparate.2.1
  have outSafe := MemoryRegions.disjoint_symm execution.temporarySeparate.2.2
  have sumFrame : ∀ offset<4*(24*SdpaDispatched.blockCount architecture steps),
      (HalfMemory.execute stores first.first.memory) (first.first.trace.sumBase+offset)=first.first.memory (first.first.trace.sumBase+offset) := by
    intro offset bound
    exact MemoryRegions.execute16_other stores first.first.memory inside sumSafe offset bound
  have maxFrame : ∀ offset<4*(24*SdpaDispatched.blockCount architecture steps),
      (HalfMemory.execute stores first.first.memory) (first.first.trace.maxBase+offset)=first.first.memory (first.first.trace.maxBase+offset) := by
    intro offset bound
    exact MemoryRegions.execute16_other stores first.first.memory inside maxSafe offset bound
  have outFrame : ∀ offset<2*(24*SdpaDispatched.blockCount architecture steps*256),
      (HalfMemory.execute stores first.first.memory) (first.first.trace.outputBase+offset)=first.first.memory (first.first.trace.outputBase+offset) := by
    intro offset bound
    exact MemoryRegions.execute16_other stores first.first.memory inside outSafe offset bound
  have summary := SdpaTwoPassLayout.summary_bounds _ head block
  have partialBound := SdpaTwoPassLayout.partial_bounds _ head block i
  unfold readState SdpaTwoPassMemory.Execution.readState SdpaTwoPassMemory.Execution.maxRead
    SdpaTwoPassMemory.Execution.sumRead SdpaTwoPassMemory.Execution.outputRead FloatMemory.load
  rw [ArrayFrame.word_congr first.first.memory _ _ _ _ maxFrame (by omega),
    ArrayFrame.word_congr first.first.memory _ _ _ _ sumFrame (by omega),
    ArrayFrame.half_congr first.first.memory _ _ _ _ outFrame (by omega)]

-- In particular every prefix admitted by the parsed output store schedule
-- leaves all later cross-head temporary loads unchanged.
theorem completed_state (execution : SdpaTwoPassDonation.Execution first contracted)
    (head : Fin 24) (block : Fin (SdpaDispatched.blockCount architecture steps)) (i : Fin 256) :
    readState execution.stores.memory first.first.trace.sumBase first.first.trace.maxBase
      first.first.trace.outputBase (SdpaDispatched.blockCount architecture steps) head block i=
      first.first.readState head block i := by
  have same := protected_state execution execution.stores.schedule (fun _ member => member) head block i
  rw [←execution.initial] at same
  exact same

end Inference.Kernels.Attention.MlxSdpaTwoPassMergeFrame
