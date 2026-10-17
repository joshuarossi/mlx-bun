import kernels.attention.SdpaTwoPassShared

namespace Inference.Kernels.Attention.SdpaTwoPassCompletion
open Contracts.Mlx State
set_option maxRecDepth 10000
attribute [local irreducible] SdpaOutput.programs SdpaTwoPassBytes.programs

variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {arch : Char}

structure Execution (first : SdpaTwoPassShared.Execution input p (SdpaDispatched.blockCount arch steps)) (contracted : Bool) where
  selected : SdpaDispatched.twoPass arch steps
  output : SdpaOutputMemory.Execution first.inputAfter p contracted arch
  linked : ∀ selected, output.kernel.second selected=first.secondAfter contracted (SdpaDispatchedDevice.complete_blocks arch steps)
  temporarySeparate : SdpaTwoPassShared.Separate first.first output.kernel.output.base 12288

variable {first : SdpaTwoPassShared.Execution input p (SdpaDispatched.blockCount arch steps)} {contracted : Bool}

def fromSecond (first : SdpaTwoPassShared.Execution input p (SdpaDispatched.blockCount arch steps))
    (contracted : Bool) (selected : SdpaDispatched.twoPass arch steps)
    (second : SdpaDispatchedDevice.TwoPass p contracted arch first.inputAfter.storage.queryValues
      first.inputAfter.storage.keys.read first.inputAfter.storage.values.read)
    (linked : second=first.secondAfter contracted (SdpaDispatchedDevice.complete_blocks arch steps))
    (base : Nat) (aligned : base%2=0) (bounded : base+12288 ≤ 2^64)
    (keysSeparate : MemoryRegions.Disjoint base 12288 first.inputAfter.cache.layout.keyBase (KvRegions.bytes steps))
    (valuesSeparate : MemoryRegions.Disjoint base 12288 first.inputAfter.cache.layout.valueBase (KvRegions.bytes steps))
    (queriesSeparate : ∀ head, MemoryRegions.Disjoint base 12288 (first.inputAfter.query head).base 512)
    (temporarySeparate : SdpaTwoPassShared.Separate first.first base 12288) : Execution first contracted :=
  let one : ¬SdpaDispatched.twoPass arch steps → SdpaDispatchedDevice.OnePass p
      first.inputAfter.storage.queryValues first.inputAfter.storage.keys.read first.inputAfter.storage.values.read :=
    fun impossible => False.elim (impossible selected)
  let two := fun _ : SdpaDispatched.twoPass arch steps => second
  { selected := selected
    output := {
      kernel := {
        first := one
        second := two
        output := SdpaOutput.Trace.canonical (SdpaDispatchedDevice.produced p contracted arch
          first.inputAfter.storage.queryValues first.inputAfter.storage.keys.read first.inputAfter.storage.values.read one two)
          first.inputAfter.cache.memory base aligned bounded }
      initial := rfl
      keysSeparate := keysSeparate
      valuesSeparate := valuesSeparate
      queriesSeparate := queriesSeparate }
    linked := fun _ => linked
    temporarySeparate := temporarySeparate }

def canonical (first : SdpaTwoPassShared.Execution input p (SdpaDispatched.blockCount arch steps))
    (contracted : Bool) (selected : SdpaDispatched.twoPass arch steps)
    (base : Nat) (aligned : base%2=0) (bounded : base+12288 ≤ 2^64)
    (keysSeparate : MemoryRegions.Disjoint base 12288 first.inputAfter.cache.layout.keyBase (KvRegions.bytes steps))
    (valuesSeparate : MemoryRegions.Disjoint base 12288 first.inputAfter.cache.layout.valueBase (KvRegions.bytes steps))
    (queriesSeparate : ∀ head, MemoryRegions.Disjoint base 12288 (first.inputAfter.query head).base 512)
    (temporarySeparate : SdpaTwoPassShared.Separate first.first base 12288) : Execution first contracted :=
  fromSecond first contracted selected (first.secondAfter contracted (SdpaDispatchedDevice.complete_blocks arch steps)) rfl
    base aligned bounded keysSeparate valuesSeparate queriesSeparate temporarySeparate

theorem Execution.second_reads_heap (execution : Execution first contracted) (head : Fin 24)
    (block : Fin (SdpaDispatched.blockCount arch steps)) (i : Fin 256) :
    (execution.output.kernel.second execution.selected).first.readState head block i=first.first.readState head block i := by
  rw [execution.linked]
  exact first.second_after_reads_heap contracted _ head block i

theorem Execution.output_eq (execution : Execution first contracted) (head : Fin 24) (i : Fin 256) :
    execution.output.loaded.output head i=SdpaDispatched.forward p contracted arch (query head)
      (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head)) i :=
  execution.output.output_eq head i

theorem Execution.output_start (execution : Execution first contracted) :
    execution.output.kernel.output.before=first.first.memory := execution.output.initial

theorem Execution.memory (execution : Execution first contracted) :
    execution.output.afterCache.memory=HalfMemory.execute execution.output.kernel.output.schedule
      (MemoryProjection.execute SdpaTwoPassMemory.write first.first.trace.schedule input.cache.memory) := by
  change HalfMemory.execute execution.output.kernel.output.schedule execution.output.kernel.output.before=_
  rw [execution.output_start]
  unfold SdpaTwoPassMemory.Execution.memory
  rw [first.initial]

theorem Execution.other_region (execution : Execution first contracted) {base size : Nat}
    (separate : MemoryRegions.Disjoint execution.output.kernel.output.base 12288 base size)
    (offset : Nat) (bound : offset<size) :
    execution.output.afterCache.memory (base+offset)=first.first.memory (base+offset) :=
  (MemoryRegions.execute16_other execution.output.kernel.output.schedule execution.output.kernel.output.before
    (SdpaOutputMemory.stores_inside execution.output.kernel.output) separate offset bound).trans
      (congrFun execution.output_start (base+offset))

theorem Execution.temporary_bytes (execution : Execution first contracted) :
    (∀ offset < 4*(24*SdpaDispatched.blockCount arch steps),
      execution.output.afterCache.memory (first.first.trace.sumBase+offset)=first.first.memory (first.first.trace.sumBase+offset)) ∧
    (∀ offset < 4*(24*SdpaDispatched.blockCount arch steps),
      execution.output.afterCache.memory (first.first.trace.maxBase+offset)=first.first.memory (first.first.trace.maxBase+offset)) ∧
    (∀ offset < 2*(24*SdpaDispatched.blockCount arch steps*256),
      execution.output.afterCache.memory (first.first.trace.outputBase+offset)=first.first.memory (first.first.trace.outputBase+offset)) :=
  ⟨execution.other_region (MemoryRegions.disjoint_symm execution.temporarySeparate.1),
    execution.other_region (MemoryRegions.disjoint_symm execution.temporarySeparate.2.1),
    execution.other_region (MemoryRegions.disjoint_symm execution.temporarySeparate.2.2)⟩

end Inference.Kernels.Attention.SdpaTwoPassCompletion
