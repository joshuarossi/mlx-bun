import kernels.attention.SdpaQueryMemory
import kernels.attention.SdpaOutputMemory

namespace Inference.Kernels.Attention.SdpaOnePassDonation
open Contracts.Mlx State
set_option maxRecDepth 10000
attribute [local irreducible] SdpaOutput.programs ReadBeforeOverwrite.allReaders ReadBeforeOverwrite.captureMany

def owner (base : Nat) (store : HalfMemory.Store) : Fin 24 := ⟨((store.word-base/2)/256)%24, Nat.mod_lt _ (by decide)⟩

theorem store_inside_head {values : SdpaOutput.Values} (trace : SdpaOutput.Trace values) (store : HalfMemory.Store)
    (member : store ∈ trace.schedule) :
    (SdpaQueryMemory.layout trace.base).base (owner trace.base store) ≤ 2*store.word ∧
      2*store.word+2 ≤ (SdpaQueryMemory.layout trace.base).base (owner trace.base store)+512 := by
  have original := (ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp member
  obtain ⟨label, _, offset, rfl⟩ := SdpaOutput.member trace.base values store original
  have headBound := label.1.isLt
  have indexBound := (SdpaLayout.coordinate label.2.1 offset).isLt
  have aligned := trace.aligned
  dsimp only [SdpaQueryMemory.layout, owner, SdpaOutput.entry, SdpaOutput.address]
  omega

def ownedStores {values : SdpaOutput.Values} (trace : SdpaOutput.Trace values) : List (Fin 24 × HalfMemory.Store) :=
  trace.schedule.map (fun store => (owner trace.base store, store))

theorem owned_stores_inside {values : SdpaOutput.Values} (trace : SdpaOutput.Trace values) :
    ∀ entry ∈ ownedStores trace,
      (SdpaQueryMemory.layout trace.base).base entry.1 ≤ 2*entry.2.word ∧
        2*entry.2.word+2 ≤ (SdpaQueryMemory.layout trace.base).base entry.1+512 := by
  intro entry member
  obtain ⟨store, present, rfl⟩ := List.mem_map.mp member
  exact store_inside_head trace store present

-- A witness executes all captures before the output schedule. General
-- execution objects below also admit interleaving independent heads.
def readTrace {values : SdpaOutput.Values} (trace : SdpaOutput.Trace values) : SdpaQueryMemory.Trace trace.base :=
  let readers := (ReadBeforeOverwrite.allReaders 24 1024).map (fun reader => ReadBeforeOverwrite.Event.capture reader.1 reader.2)
  let captured := ReadBeforeOverwrite.captureMany (SdpaQueryMemory.read trace.base)
    (ReadBeforeOverwrite.allReaders 24 1024) (ReadBeforeOverwrite.initial trace.before)
  { before := trace.before
    events := readers++(ownedStores trace).map (fun entry => .write entry.1 entry.2)
    after := ReadBeforeOverwrite.writeMany (ownedStores trace) captured
    execution := ReadBeforeOverwrite.append_execution ReadBeforeOverwrite.canonical
      (ReadBeforeOverwrite.writeMany_valid _ _ ReadBeforeOverwrite.canonical_ready (owned_stores_inside trace))
    ready := ReadBeforeOverwrite.writeMany_ready _ _ ReadBeforeOverwrite.canonical_ready }

theorem readTrace_stores {values : SdpaOutput.Values} (trace : SdpaOutput.Trace values) :
    (readTrace trace).events.filterMap ReadBeforeOverwrite.storeProjection=trace.schedule := by
  change (((ReadBeforeOverwrite.allReaders 24 1024).map (fun reader : Fin 24 × Fin 1024 => ReadBeforeOverwrite.Event.capture reader.1 reader.2))++
    (ownedStores trace).map (fun entry : Fin 24 × HalfMemory.Store => ReadBeforeOverwrite.Event.write entry.1 entry.2)).filterMap ReadBeforeOverwrite.storeProjection=_
  simp only [List.filterMap_append, List.filterMap_map, Function.comp_def, ReadBeforeOverwrite.storeProjection,
    List.filterMap_none, List.filterMap_some, List.nil_append, ownedStores, List.map_map]

variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {arch : Char}

abbrev HeadExecutions (p : SdpaVector.Platform) (query : Fin 24 → Fin 256 → ArrayStorage.BF) (cache : Kv.Cache Kv.BF steps) :=
  ∀ head, SdpaOnePassScratch.Execution p (query head) (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))

def produced (kernels : HeadExecutions p query cache) (head : Fin 24) (i : Fin 256) : ArrayStorage.BF := SdpaOnePassScratch.forward (kernels head) i

structure Execution (input : SdpaMemory.Input query cache) (p : SdpaVector.Platform) (arch : Char) where
  selected : ¬SdpaDispatched.twoPass arch steps
  kernels : HeadExecutions p query cache
  base : Nat
  queries : SdpaQueryMemory.Trace base
  initial : queries.before=input.cache.memory
  heads : ∀ head, (input.query head).base=(SdpaQueryMemory.layout base).base head
  stores : SdpaOutput.Trace (produced kernels)
  outputBase : stores.base=base
  outputInitial : stores.before=queries.before
  storeSchedule : queries.events.filterMap ReadBeforeOverwrite.storeProjection=stores.schedule
  keysSeparate : MemoryRegions.Disjoint stores.base 12288 input.cache.layout.keyBase (KvRegions.bytes steps)
  valuesSeparate : MemoryRegions.Disjoint stores.base 12288 input.cache.layout.valueBase (KvRegions.bytes steps)

def fromStores (input : SdpaMemory.Input query cache) (p : SdpaVector.Platform) (arch : Char)
    (selected : ¬SdpaDispatched.twoPass arch steps) (kernels : HeadExecutions p query cache) (stores : SdpaOutput.Trace (produced kernels))
    (initial : stores.before=input.cache.memory)
    (heads : ∀ head, (input.query head).base=(SdpaQueryMemory.layout stores.base).base head)
    (keysSeparate : MemoryRegions.Disjoint stores.base 12288 input.cache.layout.keyBase (KvRegions.bytes steps))
    (valuesSeparate : MemoryRegions.Disjoint stores.base 12288 input.cache.layout.valueBase (KvRegions.bytes steps)) : Execution input p arch :=
  ⟨selected, kernels, stores.base, readTrace stores, initial, heads, stores, rfl, rfl, readTrace_stores stores, keysSeparate, valuesSeparate⟩

def canonical (input : SdpaMemory.Input query cache) (p : SdpaVector.Platform) (arch : Char)
    (selected : ¬SdpaDispatched.twoPass arch steps) (base : Nat) (aligned : base%2=0) (bounded : base+12288 ≤ 2^64)
    (heads : ∀ head, (input.query head).base=(SdpaQueryMemory.layout base).base head)
    (keysSeparate : MemoryRegions.Disjoint base 12288 input.cache.layout.keyBase (KvRegions.bytes steps))
    (valuesSeparate : MemoryRegions.Disjoint base 12288 input.cache.layout.valueBase (KvRegions.bytes steps)) : Execution input p arch :=
  let kernels : HeadExecutions p query cache := fun head => SdpaOnePassScratch.Execution.canonical p (query head)
    (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))
  fromStores input p arch selected kernels (SdpaOutput.Trace.canonical _ input.cache.memory base aligned bounded) rfl heads keysSeparate valuesSeparate

theorem Execution.captured_query (execution : Execution input p arch) : execution.queries.capturedQuery=query :=
  execution.queries.query_eq input execution.initial execution.heads

theorem Execution.group_separate (execution : Execution input p arch) {base size : Nat}
    (separate : MemoryRegions.Disjoint execution.stores.base 12288 base size) (head : Fin 24) :
    MemoryRegions.Disjoint ((SdpaQueryMemory.layout execution.base).base head) 512 base size := by
  rw [execution.outputBase] at separate
  have := head.isLt
  dsimp only [SdpaQueryMemory.layout]
  rcases separate with left|right <;> unfold MemoryRegions.Disjoint <;> omega

def Execution.intermediateCache (execution : Execution input p arch)
    {after : SdpaQueryMemory.Machine} {events : List (ReadBeforeOverwrite.Event 24 1024)}
    (run : ReadBeforeOverwrite.Executes (SdpaQueryMemory.layout execution.base) (SdpaQueryMemory.read execution.base)
      (ReadBeforeOverwrite.initial input.cache.memory) events after) : KvRegions.Storage cache :=
  input.cache.reframe after.memory
    (ReadBeforeOverwrite.frame run (execution.group_separate execution.keysSeparate))
    (ReadBeforeOverwrite.frame run (execution.group_separate execution.valuesSeparate))

theorem Execution.intermediate_capture (execution : Execution input p arch)
    {after : SdpaQueryMemory.Machine} {events : List (ReadBeforeOverwrite.Event 24 1024)}
    (run : ReadBeforeOverwrite.Executes (SdpaQueryMemory.layout execution.base) (SdpaQueryMemory.read execution.base)
      (ReadBeforeOverwrite.initial input.cache.memory) events after)
    (head : Fin 24) (thread : Fin 1024) (registers : SdpaQueryMemory.Registers)
    (captured : after.registers head thread=some registers) (offset : Fin 8) :
    registers offset=ArrayStorage.bits (query head (SdpaLayout.coordinate (SdpaQueryMemory.lane thread) offset)) := by
  rw [ReadBeforeOverwrite.captured_original (SdpaQueryMemory.read_local execution.base) run head thread registers captured]
  exact SdpaQueryMemory.input_read input execution.base execution.heads head thread offset

def Execution.output (execution : Execution input p arch) (head : Fin 24) (i : Fin 256) : ArrayStorage.BF := execution.stores.read head i

theorem Execution.output_eq (execution : Execution input p arch) (contracted : Bool) (head : Fin 24) (i : Fin 256) :
    execution.output head i=SdpaDispatched.forward p contracted arch (query head)
      (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head)) i := by
  unfold Execution.output
  rw [execution.stores.read_correct]
  unfold produced
  rw [SdpaOnePassScratch.forward_eq]
  unfold SdpaDispatched.forward
  rw [ite_eq_right execution.selected]

theorem Execution.memory (execution : Execution input p arch) : execution.queries.after.memory=execution.stores.memory := by
  rw [execution.queries.memory, execution.storeSchedule]
  unfold SdpaOutput.Trace.memory
  rw [execution.outputInitial]

theorem Execution.other_region (execution : Execution input p arch) {base size : Nat}
    (separate : MemoryRegions.Disjoint execution.stores.base 12288 base size) (offset : Nat) (bound : offset<size) :
    execution.stores.memory (base+offset)=input.cache.memory (base+offset) :=
  (MemoryRegions.execute16_other execution.stores.schedule execution.stores.before
    (SdpaOutputMemory.stores_inside execution.stores) separate offset bound).trans
      (congrFun (execution.outputInitial.trans execution.initial) (base+offset))

def Execution.afterCache (execution : Execution input p arch) : KvRegions.Storage cache :=
  input.cache.reframe execution.stores.memory (execution.other_region execution.keysSeparate) (execution.other_region execution.valuesSeparate)

def Execution.buffer (execution : Execution input p arch) (head : Fin 24) : ArrayStorage.BFBuffer (execution.output head) where
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

theorem Execution.cache_output_shared (execution : Execution input p arch) (head : Fin 24) :
    execution.afterCache.memory=(execution.buffer head).bytes := rfl

end Inference.Kernels.Attention.SdpaOnePassDonation
