import kernels.attention.SdpaTwoPassMemory
import kernels.attention.SdpaMemory
import kernels.attention.SdpaOutputMemory

namespace Inference.Kernels.Attention.SdpaTwoPassShared
open Contracts.Mlx State
set_option maxRecDepth 10000
attribute [local irreducible] SdpaTwoPassBytes.programs
attribute [local irreducible] SdpaTwoPassFirstPass.raw SdpaTwoPassFirstPass.stored

abbrev First (p : SdpaVector.Platform) (blocks : Nat) (query : Fin 24 → Fin 256 → ArrayStorage.BF)
    (keys values : Fin 4 → Fin steps → Fin 256 → ArrayStorage.BF) :=
  SdpaTwoPassMemory.Execution
    (fun (h : Fin 24) (b : Fin blocks) => (SdpaTwoPassFirstPass.raw p (query h) (keys (SdpaScore.kvHead h)) (values (SdpaScore.kvHead h)) 0 b).denominator)
    (fun (h : Fin 24) (b : Fin blocks) => (SdpaTwoPassFirstPass.raw p (query h) (keys (SdpaScore.kvHead h)) (values (SdpaScore.kvHead h)) 0 b).shift)
    (fun h b i => SdpaTwoPassFirstPass.stored p (query h) (keys (SdpaScore.kvHead h)) (values (SdpaScore.kvHead h)) i b)

def Separate {blocks : Nat} {sums maxima : Fin 24 → Fin blocks → Float32}
    {values : Fin 24 → Fin blocks → Fin 256 → ArrayStorage.BF}
    (first : SdpaTwoPassMemory.Execution sums maxima values) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint first.trace.sumBase (4*(24*blocks)) base size ∧
  MemoryRegions.Disjoint first.trace.maxBase (4*(24*blocks)) base size ∧
  MemoryRegions.Disjoint first.trace.outputBase (2*(24*blocks*256)) base size

variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF steps}

structure Execution (input : SdpaMemory.Input query cache) (p : SdpaVector.Platform) (blocks : Nat) where
  first : First p blocks input.storage.queryValues input.storage.keys.read input.storage.values.read
  initial : first.trace.sumBefore=input.cache.memory
  keysSeparate : Separate first input.cache.layout.keyBase (KvRegions.bytes steps)
  valuesSeparate : Separate first input.cache.layout.valueBase (KvRegions.bytes steps)
  queriesSeparate : ∀ head, Separate first (input.query head).base 512

variable {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {blocks : Nat}

def canonical (input : SdpaMemory.Input query cache) (p : SdpaVector.Platform) (layout : SdpaTwoPassMemory.Layout blocks)
    (keysSeparate : MemoryRegions.Disjoint layout.sumBase (4*(24*blocks)) input.cache.layout.keyBase (KvRegions.bytes steps) ∧
      MemoryRegions.Disjoint layout.maxBase (4*(24*blocks)) input.cache.layout.keyBase (KvRegions.bytes steps) ∧
      MemoryRegions.Disjoint layout.outputBase (2*(24*blocks*256)) input.cache.layout.keyBase (KvRegions.bytes steps))
    (valuesSeparate : MemoryRegions.Disjoint layout.sumBase (4*(24*blocks)) input.cache.layout.valueBase (KvRegions.bytes steps) ∧
      MemoryRegions.Disjoint layout.maxBase (4*(24*blocks)) input.cache.layout.valueBase (KvRegions.bytes steps) ∧
      MemoryRegions.Disjoint layout.outputBase (2*(24*blocks*256)) input.cache.layout.valueBase (KvRegions.bytes steps))
    (queriesSeparate : ∀ head, MemoryRegions.Disjoint layout.sumBase (4*(24*blocks)) (input.query head).base 512 ∧
      MemoryRegions.Disjoint layout.maxBase (4*(24*blocks)) (input.query head).base 512 ∧
      MemoryRegions.Disjoint layout.outputBase (2*(24*blocks*256)) (input.query head).base 512) : Execution input p blocks where
  first := SdpaTwoPassMemory.canonical _ _ _ layout input.cache.memory
  initial := rfl
  keysSeparate := keysSeparate
  valuesSeparate := valuesSeparate
  queriesSeparate := queriesSeparate

def Execution.afterCache (execution : Execution input p blocks) : KvRegions.Storage cache :=
  input.cache.reframe execution.first.memory
    (by
      intro offset bound
      exact (execution.first.other_region execution.keysSeparate.1 execution.keysSeparate.2.1 execution.keysSeparate.2.2 offset bound).trans
        (congrFun execution.initial (input.cache.layout.keyBase+offset)))
    (by
      intro offset bound
      exact (execution.first.other_region execution.valuesSeparate.1 execution.valuesSeparate.2.1 execution.valuesSeparate.2.2 offset bound).trans
        (congrFun execution.initial (input.cache.layout.valueBase+offset)))

def Execution.afterQueries (execution : Execution input p blocks) (head : Fin 24) : ArrayStorage.BFBuffer (query head) :=
  ArrayFrame.bf (input.query head) execution.first.memory (by
    intro offset bound
    have safe := execution.queriesSeparate head
    exact (execution.first.other_region safe.1 safe.2.1 safe.2.2 offset bound).trans
      ((congrFun execution.initial ((input.query head).base+offset)).trans
        (congrFun (input.shared head) ((input.query head).base+offset)).symm))

def Execution.inputAfter (execution : Execution input p blocks) : SdpaMemory.Input query cache :=
  ⟨execution.afterCache, execution.afterQueries, fun _ => rfl⟩

theorem Execution.input_after_memory (execution : Execution input p blocks) :
    execution.inputAfter.cache.memory=execution.first.memory := rfl

theorem Execution.first_to_second (execution : Execution input p blocks) (head : Fin 24) (block : Fin blocks) (i : Fin 256) :
    execution.first.readState head block i=SdpaTwoPassVector.partials p (query head)
      (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head)) i block := by
  rw [execution.first.readState_projected, SdpaTwoPassBytes.first_to_second,
    input.storage.query_eq, input.storage.keys.read_eq, input.storage.values.read_eq]

-- The second-pass scratch is threadgroup memory, a separate address space.
-- Its first-pass global loads are justified by readState_projected above.
def Execution.second (execution : Execution input p blocks) (contracted : Bool) (complete : blocks%32=0) :
    SdpaTwoPassScratch.Execution p contracted complete input.storage.queryValues input.storage.keys.read input.storage.values.read := by
  let first := execution.first.trace
  refine ⟨first, fun head => SdpaTwoPassScratch.canonicalScratch
    (SdpaTwoPassScratch.numeratorLanes p contracted complete _ _ _ first head) (fun _ => 0) 0 (by decide) (by decide), ?_, ?_⟩
  · intro head offset
    rw [SdpaTwoPassScratch.canonical_base, SdpaTwoPassScratch.canonical_base]
  · intro head offset
    exact SdpaTwoPassScratch.canonical_reuse _ _ _ _ _ offset

theorem Execution.second_reads_heap (execution : Execution input p blocks) (contracted : Bool) (complete : blocks%32=0)
    (head : Fin 24) (block : Fin blocks) (i : Fin 256) :
    (execution.second contracted complete).first.readState head block i=execution.first.readState head block i :=
  (execution.first.readState_projected head block i).symm

-- Reattach the very same first-pass schedule after its operand frame.
-- Only the proof of which mathematical inputs it represents changes.
def rebindTrace {sums maxima sums' maxima' : Fin 24 → Fin blocks → Float32}
    {values values' : Fin 24 → Fin blocks → Fin 256 → ArrayStorage.BF}
    (trace : SdpaTwoPassBytes.Trace sums maxima values)
    (hs : sums=sums') (hm : maxima=maxima') (hv : values=values') : SdpaTwoPassBytes.Trace sums' maxima' values' :=
  hs ▸ hm ▸ hv ▸ trace

theorem rebind_trace_memory {sums maxima sums' maxima' : Fin 24 → Fin blocks → Float32}
    {values values' : Fin 24 → Fin blocks → Fin 256 → ArrayStorage.BF}
    (trace : SdpaTwoPassBytes.Trace sums maxima values) (hs : sums=sums') (hm : maxima=maxima') (hv : values=values') :
    (rebindTrace trace hs hm hv).schedule=trace.schedule ∧ (rebindTrace trace hs hm hv).sumBefore=trace.sumBefore := by
  cases hs
  cases hm
  cases hv
  exact ⟨rfl, rfl⟩

theorem rebind_trace_read {sums maxima sums' maxima' : Fin 24 → Fin blocks → Float32}
    {values values' : Fin 24 → Fin blocks → Fin 256 → ArrayStorage.BF}
    (trace : SdpaTwoPassBytes.Trace sums maxima values) (hs : sums=sums') (hm : maxima=maxima') (hv : values=values')
    (head : Fin 24) (block : Fin blocks) (i : Fin 256) :
    (rebindTrace trace hs hm hv).readState head block i=trace.readState head block i := by
  cases hs
  cases hm
  cases hv
  rfl

def rebindFirst {keys values : SdpaLoads.History steps}
    (before after : SdpaLoads.Storage query keys values)
    (first : SdpaTwoPassBytes.FirstTrace p blocks before.queryValues before.keys.read before.values.read) :
    SdpaTwoPassBytes.FirstTrace p blocks after.queryValues after.keys.read after.values.read :=
  rebindTrace first
    (by rw [before.query_eq, after.query_eq, before.keys.read_eq, after.keys.read_eq, before.values.read_eq, after.values.read_eq])
    (by rw [before.query_eq, after.query_eq, before.keys.read_eq, after.keys.read_eq, before.values.read_eq, after.values.read_eq])
    (by rw [before.query_eq, after.query_eq, before.keys.read_eq, after.keys.read_eq, before.values.read_eq, after.values.read_eq])

theorem rebind_memory {keys values : SdpaLoads.History steps}
    (before after : SdpaLoads.Storage query keys values)
    (first : SdpaTwoPassBytes.FirstTrace p blocks before.queryValues before.keys.read before.values.read) :
    (rebindFirst before after first).schedule=first.schedule ∧
      (rebindFirst before after first).sumBefore=first.sumBefore := rebind_trace_memory first _ _ _

theorem rebind_read {keys values : SdpaLoads.History steps}
    (before after : SdpaLoads.Storage query keys values)
    (first : SdpaTwoPassBytes.FirstTrace p blocks before.queryValues before.keys.read before.values.read)
    (head : Fin 24) (block : Fin blocks) (i : Fin 256) :
    (rebindFirst before after first).readState head block i=first.readState head block i := rebind_trace_read first _ _ _ head block i

def Execution.firstAfter (execution : Execution input p blocks) :
    SdpaTwoPassBytes.FirstTrace p blocks execution.inputAfter.storage.queryValues
      execution.inputAfter.storage.keys.read execution.inputAfter.storage.values.read :=
  rebindFirst input.storage execution.inputAfter.storage execution.first.trace

theorem Execution.first_after_memory (execution : Execution input p blocks) :
    execution.firstAfter.schedule=execution.first.trace.schedule ∧
      execution.firstAfter.sumBefore=execution.first.trace.sumBefore :=
  rebind_memory input.storage execution.inputAfter.storage execution.first.trace

def secondFromFirst {keys values : SdpaLoads.History steps}
    (first : SdpaTwoPassBytes.FirstTrace p blocks query keys values) (contracted : Bool) (complete : blocks%32=0) :
    SdpaTwoPassScratch.Execution p contracted complete query keys values := by
  refine ⟨first, fun head => SdpaTwoPassScratch.canonicalScratch
    (SdpaTwoPassScratch.numeratorLanes p contracted complete _ _ _ first head) (fun _ => 0) 0 (by decide) (by decide), ?_, ?_⟩
  · intro head offset
    rw [SdpaTwoPassScratch.canonical_base, SdpaTwoPassScratch.canonical_base]
  · intro head offset
    exact SdpaTwoPassScratch.canonical_reuse _ _ _ _ _ offset

theorem second_from_first_read {keys values : SdpaLoads.History steps}
    (first : SdpaTwoPassBytes.FirstTrace p blocks query keys values) (contracted : Bool) (complete : blocks%32=0)
    (head : Fin 24) (block : Fin blocks) (i : Fin 256) :
    (secondFromFirst first contracted complete).first.readState head block i=first.readState head block i := rfl

def Execution.secondAfter (execution : Execution input p blocks) (contracted : Bool) (complete : blocks%32=0) :
    SdpaTwoPassScratch.Execution p contracted complete execution.inputAfter.storage.queryValues
      execution.inputAfter.storage.keys.read execution.inputAfter.storage.values.read :=
  secondFromFirst execution.firstAfter contracted complete

theorem Execution.second_after_reads_heap (execution : Execution input p blocks) (contracted : Bool) (complete : blocks%32=0)
    (head : Fin 24) (block : Fin blocks) (i : Fin 256) :
    (execution.secondAfter contracted complete).first.readState head block i=execution.first.readState head block i :=
  (second_from_first_read execution.firstAfter contracted complete head block i).trans
    ((rebind_read input.storage execution.inputAfter.storage execution.first.trace head block i).trans
      (execution.first.readState_projected head block i).symm)

theorem Execution.output_eq (execution : Execution input p blocks) (contracted : Bool) (complete : blocks%32=0)
    (head : Fin 24) (i : Fin 256) :
    SdpaTwoPassScratch.forward (execution.second contracted complete) head i=
      SdpaTwoPassVector.forward p contracted blocks (query head)
        (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head)) i := by
  rw [SdpaTwoPassScratch.forward_eq, input.storage.query_eq, input.storage.keys.read_eq, input.storage.values.read_eq]

end Inference.Kernels.Attention.SdpaTwoPassShared
