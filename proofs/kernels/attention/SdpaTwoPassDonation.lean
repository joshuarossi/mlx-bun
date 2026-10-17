import kernels.attention.SdpaTwoPassShared

namespace Inference.Kernels.Attention.SdpaTwoPassDonation
open Contracts.Mlx State
set_option maxRecDepth 10000
attribute [local irreducible] SdpaOutput.programs

variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {arch : Char}

-- After the first dispatch completes, the second pass reads its three
-- temporary allocations. Query bytes may be overwritten by the output;
-- the retained cache and first-pass temporaries must remain intact.
structure Execution (first : SdpaTwoPassShared.Execution input p (SdpaDispatched.blockCount arch steps)) (contracted : Bool) where
  selected : SdpaDispatched.twoPass arch steps
  stores : SdpaOutput.Trace (SdpaTwoPassScratch.forward (first.second contracted (SdpaDispatchedDevice.complete_blocks arch steps)))
  initial : stores.before=first.first.memory
  keysSeparate : MemoryRegions.Disjoint stores.base 12288 first.afterCache.layout.keyBase (KvRegions.bytes steps)
  valuesSeparate : MemoryRegions.Disjoint stores.base 12288 first.afterCache.layout.valueBase (KvRegions.bytes steps)
  temporarySeparate : SdpaTwoPassShared.Separate first.first stores.base 12288

variable {first : SdpaTwoPassShared.Execution input p (SdpaDispatched.blockCount arch steps)} {contracted : Bool}

def canonical (first : SdpaTwoPassShared.Execution input p (SdpaDispatched.blockCount arch steps))
    (contracted : Bool) (selected : SdpaDispatched.twoPass arch steps)
    (base : Nat) (aligned : base%2=0) (bounded : base+12288 ≤ 2^64)
    (keysSeparate : MemoryRegions.Disjoint base 12288 first.afterCache.layout.keyBase (KvRegions.bytes steps))
    (valuesSeparate : MemoryRegions.Disjoint base 12288 first.afterCache.layout.valueBase (KvRegions.bytes steps))
    (temporarySeparate : SdpaTwoPassShared.Separate first.first base 12288) : Execution first contracted :=
  ⟨selected, SdpaOutput.Trace.canonical _ first.first.memory base aligned bounded, rfl, keysSeparate, valuesSeparate, temporarySeparate⟩

def fromQuery (first : SdpaTwoPassShared.Execution input p (SdpaDispatched.blockCount arch steps))
    (contracted : Bool) (selected : SdpaDispatched.twoPass arch steps)
    (layout : ∀ head : Fin 24, (input.query head).base=(input.query 0).base+2*(head.val*256))
    (keysSeparate : MemoryRegions.Disjoint (input.query 0).base 12288 first.afterCache.layout.keyBase (KvRegions.bytes steps))
    (valuesSeparate : MemoryRegions.Disjoint (input.query 0).base 12288 first.afterCache.layout.valueBase (KvRegions.bytes steps))
    (temporarySeparate : SdpaTwoPassShared.Separate first.first (input.query 0).base 12288) : Execution first contracted :=
  canonical first contracted selected (input.query 0).base (input.query 0).aligned
    (by have bound := (input.query 23).bounded; rw [layout 23] at bound; exact bound)
    keysSeparate valuesSeparate temporarySeparate

theorem fromQuery_address (first : SdpaTwoPassShared.Execution input p (SdpaDispatched.blockCount arch steps))
    (contracted : Bool) (selected : SdpaDispatched.twoPass arch steps)
    (layout : ∀ head : Fin 24, (input.query head).base=(input.query 0).base+2*(head.val*256))
    (keysSeparate : MemoryRegions.Disjoint (input.query 0).base 12288 first.afterCache.layout.keyBase (KvRegions.bytes steps))
    (valuesSeparate : MemoryRegions.Disjoint (input.query 0).base 12288 first.afterCache.layout.valueBase (KvRegions.bytes steps))
    (temporarySeparate : SdpaTwoPassShared.Separate first.first (input.query 0).base 12288) :
    (fromQuery first contracted selected layout keysSeparate valuesSeparate temporarySeparate).stores.base=(input.query 0).base := rfl

def Execution.output (execution : Execution first contracted) (head : Fin 24) (i : Fin 256) : ArrayStorage.BF := execution.stores.read head i

theorem Execution.output_eq (execution : Execution first contracted) (head : Fin 24) (i : Fin 256) :
    execution.output head i=SdpaDispatched.forward p contracted arch (query head)
      (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head)) i := by
  unfold Execution.output
  rw [execution.stores.read_correct, first.output_eq]
  unfold SdpaDispatched.forward
  rw [ite_eq_left execution.selected]

def Execution.buffer (execution : Execution first contracted) (head : Fin 24) : ArrayStorage.BFBuffer (execution.output head) where
  bytes := execution.stores.memory
  base := execution.stores.base+2*(head.val*256)
  aligned := by have := execution.stores.aligned; omega
  bounded := by have := execution.stores.bounded; have := head.isLt; omega
  attached := by
    intro i
    change HalfMemory.load execution.stores.memory ((execution.stores.base+2*(head.val*256))+2*i.val)=
      HalfMemory.load execution.stores.memory (execution.stores.base+2*SdpaOutput.address head i)
    congr 1
    dsimp only [SdpaOutput.address]
    omega

theorem Execution.other_region (execution : Execution first contracted) {base size : Nat}
    (separate : MemoryRegions.Disjoint execution.stores.base 12288 base size) (offset : Nat) (bound : offset<size) :
    execution.stores.memory (base+offset)=first.first.memory (base+offset) :=
  (MemoryRegions.execute16_other execution.stores.schedule execution.stores.before
    (SdpaOutputMemory.stores_inside execution.stores) separate offset bound).trans
      (congrFun execution.initial (base+offset))

def Execution.afterCache (execution : Execution first contracted) : KvRegions.Storage cache :=
  first.afterCache.reframe execution.stores.memory
    (execution.other_region execution.keysSeparate) (execution.other_region execution.valuesSeparate)

theorem Execution.cache_output_shared (execution : Execution first contracted) (head : Fin 24) :
    execution.afterCache.memory=(execution.buffer head).bytes := rfl

theorem Execution.temporary_bytes (execution : Execution first contracted) :
    (∀ offset < 4*(24*SdpaDispatched.blockCount arch steps),
      execution.stores.memory (first.first.trace.sumBase+offset)=first.first.memory (first.first.trace.sumBase+offset)) ∧
    (∀ offset < 4*(24*SdpaDispatched.blockCount arch steps),
      execution.stores.memory (first.first.trace.maxBase+offset)=first.first.memory (first.first.trace.maxBase+offset)) ∧
    (∀ offset < 2*(24*SdpaDispatched.blockCount arch steps*256),
      execution.stores.memory (first.first.trace.outputBase+offset)=first.first.memory (first.first.trace.outputBase+offset)) :=
  ⟨execution.other_region (MemoryRegions.disjoint_symm execution.temporarySeparate.1),
    execution.other_region (MemoryRegions.disjoint_symm execution.temporarySeparate.2.1),
    execution.other_region (MemoryRegions.disjoint_symm execution.temporarySeparate.2.2)⟩

theorem Execution.memory (execution : Execution first contracted) :
    execution.stores.memory=HalfMemory.execute execution.stores.schedule
      (MemoryProjection.execute SdpaTwoPassMemory.write first.first.trace.schedule input.cache.memory) := by
  unfold SdpaOutput.Trace.memory
  rw [execution.initial]
  unfold SdpaTwoPassMemory.Execution.memory
  rw [first.initial]

end Inference.Kernels.Attention.SdpaTwoPassDonation
