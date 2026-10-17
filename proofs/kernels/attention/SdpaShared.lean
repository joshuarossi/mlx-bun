import kernels.attention.SdpaOutputMemory
import kernels.attention.SdpaOnePassDonation
import kernels.attention.SdpaTwoPassDonation

namespace Inference.Kernels.Attention.SdpaShared
open Contracts.Mlx State
set_option maxRecDepth 10000

variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF steps}

-- The dispatch and buffer ownership select a constructor. Each constructor
-- carries completed memory operations, not a postulated output attachment.
inductive Execution (input : SdpaMemory.Input query cache) (p : SdpaVector.Platform) (contracted : Bool) (arch : Char) where
  | onePassFresh (execution : SdpaOutputMemory.Execution input p contracted arch) (selected : ¬SdpaDispatched.twoPass arch steps)
  | onePassDonated (execution : SdpaOnePassDonation.Execution input p arch)
  | twoPass (first : SdpaTwoPassShared.Execution input p (SdpaDispatched.blockCount arch steps))
      (execution : SdpaTwoPassDonation.Execution first contracted)

variable {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}

def Execution.output (execution : Execution input p contracted arch) : Fin 24 → Fin 256 → ArrayStorage.BF :=
  match execution with
  | .onePassFresh e _ => e.loaded.output
  | .onePassDonated e => e.output
  | .twoPass _ e => e.output

def Execution.buffer (execution : Execution input p contracted arch) (head : Fin 24) : ArrayStorage.BFBuffer (execution.output head) :=
  match execution with
  | .onePassFresh e _ => e.loaded.outputBuffer head
  | .onePassDonated e => e.buffer head
  | .twoPass _ e => e.buffer head

def Execution.memory (execution : Execution input p contracted arch) : ByteMemory.Bytes :=
  match execution with
  | .onePassFresh e _ => e.kernel.output.memory
  | .onePassDonated e => e.stores.memory
  | .twoPass _ e => e.stores.memory

def Execution.base (execution : Execution input p contracted arch) : Nat :=
  match execution with
  | .onePassFresh e _ => e.kernel.output.base
  | .onePassDonated e => e.stores.base
  | .twoPass _ e => e.stores.base

def Execution.afterCache (execution : Execution input p contracted arch) : KvRegions.Storage cache :=
  match execution with
  | .onePassFresh e _ => e.afterCache
  | .onePassDonated e => e.afterCache
  | .twoPass _ e => e.afterCache

theorem Execution.output_eq (execution : Execution input p contracted arch) (head : Fin 24) (i : Fin 256) :
    execution.output head i=SdpaDispatched.forward p contracted arch (query head)
      (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head)) i := by
  cases execution with
  | onePassFresh e _ => exact e.output_eq head i
  | onePassDonated e => exact e.output_eq contracted head i
  | twoPass first e => exact e.output_eq head i

theorem Execution.buffer_bytes (execution : Execution input p contracted arch) (head : Fin 24) :
    (execution.buffer head).bytes=execution.memory := by cases execution <;> rfl

theorem Execution.cache_memory (execution : Execution input p contracted arch) :
    execution.afterCache.memory=execution.memory := by cases execution <;> rfl

theorem Execution.cache_layout (execution : Execution input p contracted arch) :
    execution.afterCache.layout=input.cache.layout := by cases execution <;> rfl

theorem Execution.aligned (execution : Execution input p contracted arch) : execution.base%2=0 := by
  cases execution with
  | onePassFresh e _ => exact e.kernel.output.aligned
  | onePassDonated e => exact e.stores.aligned
  | twoPass first e => exact e.stores.aligned

theorem Execution.buffer_base (execution : Execution input p contracted arch) (head : Fin 24) :
    (execution.buffer head).base=2*(execution.base/2+head.val*256) := by
  have aligned := execution.aligned
  have address : (execution.buffer head).base=execution.base+2*(head.val*256) := by cases execution <;> rfl
  rw [address]
  omega

def Safe (execution : Execution input p contracted arch) (base size : Nat) : Prop :=
  match execution with
  | .onePassFresh e _ => MemoryRegions.Disjoint e.kernel.output.base 12288 base size
  | .onePassDonated e => MemoryRegions.Disjoint e.stores.base 12288 base size
  | .twoPass first e => SdpaTwoPassShared.Separate first.first base size ∧ MemoryRegions.Disjoint e.stores.base 12288 base size

theorem Execution.other_region (execution : Execution input p contracted arch) {base size : Nat}
    (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.memory (base+offset)=input.cache.memory (base+offset) := by
  cases execution with
  | onePassFresh e _ =>
    exact (MemoryRegions.execute16_other e.kernel.output.schedule e.kernel.output.before
      (SdpaOutputMemory.stores_inside e.kernel.output) safe offset bound).trans (congrFun e.initial (base+offset))
  | onePassDonated e => exact e.other_region safe offset bound
  | twoPass first e =>
    exact (e.other_region safe.2 offset bound).trans
      ((first.first.other_region safe.1.1 safe.1.2.1 safe.1.2.2 offset bound).trans (congrFun first.initial (base+offset)))

end Inference.Kernels.Attention.SdpaShared
