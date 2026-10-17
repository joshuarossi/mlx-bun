import kernels.attention.SdpaMemory
import contracts.mlx.ArrayRelocation

namespace Inference.Kernels.Attention.SdpaOutputMemory
open Contracts.Mlx State
set_option maxRecDepth 10000
attribute [local irreducible] SdpaOutput.programs

def rebase (oldBase base : Nat) (store : HalfMemory.Store) : HalfMemory.Store :=
  ⟨base/2+(store.word-oldBase/2), store.value⟩

theorem rebase_programs (oldBase base : Nat) (values : SdpaOutput.Values) :
    (SdpaOutput.programs oldBase values).map (List.map (rebase oldBase base))=SdpaOutput.programs base values := by
  simp only [SdpaOutput.programs, List.map_map, Function.comp_def]
  congr 1
  funext label
  unfold SdpaOutput.thread
  split
  · simp only [List.map_ofFn]
    congr 1
    funext offset
    simp only [Function.comp_def, rebase, SdpaOutput.entry, Nat.add_sub_cancel_left]
  · rfl

def relocate {values : SdpaOutput.Values} (trace : SdpaOutput.Trace values)
    (before : ByteMemory.Bytes) (base : Nat) (aligned : base%2=0) (bounded : base+12288 ≤ 2^64) : SdpaOutput.Trace values where
  before := before
  base := base
  aligned := aligned
  bounded := bounded
  schedule := trace.schedule.map (rebase trace.base base)
  remaining := trace.remaining.map (List.map (rebase trace.base base))
  execution := by rw [← rebase_programs trace.base base]; exact ArrayRelocation.map_execution _ trace.execution
  completed := ArrayRelocation.map_barrier _ _ trace.completed

theorem stores_inside_of_subset (base : Nat) (aligned : base%2=0) (values : SdpaOutput.Values)
    (stores : List HalfMemory.Store) (members : ∀ store ∈ stores, store ∈ (SdpaOutput.programs base values).flatten) :
    MemoryRegions.Inside16 base 12288 stores := by
  intro store present
  obtain ⟨label, _, offset, rfl⟩ := SdpaOutput.member base values store (members store present)
  have headBound := label.1.isLt
  have coordinateBound := (SdpaLayout.coordinate label.2.1 offset).isLt
  dsimp only [SdpaOutput.entry, SdpaOutput.address]
  omega

theorem stores_inside {values : SdpaOutput.Values} (trace : SdpaOutput.Trace values) :
    MemoryRegions.Inside16 trace.base 12288 trace.schedule :=
  stores_inside_of_subset trace.base trace.aligned values trace.schedule
    (fun _ member => (ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp member)

-- This object places the output phase in the operand heap. It does not
-- identify the two-pass temporary allocations with global memory yet.
variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF steps}

structure Execution (input : SdpaMemory.Input query cache) (p : SdpaVector.Platform) (contracted : Bool) (arch : Char) where
  kernel : SdpaDispatchedDevice.Execution p contracted arch input.storage.queryValues input.storage.keys.read input.storage.values.read
  initial : kernel.output.before=input.cache.memory
  keysSeparate : MemoryRegions.Disjoint kernel.output.base 12288 input.cache.layout.keyBase (KvRegions.bytes steps)
  valuesSeparate : MemoryRegions.Disjoint kernel.output.base 12288 input.cache.layout.valueBase (KvRegions.bytes steps)
  queriesSeparate : ∀ head, MemoryRegions.Disjoint kernel.output.base 12288 (input.query head).base 512

variable {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}

def fromKernel (input : SdpaMemory.Input query cache) (p : SdpaVector.Platform) (contracted : Bool) (arch : Char)
    (kernel : SdpaDispatchedDevice.Execution p contracted arch input.storage.queryValues input.storage.keys.read input.storage.values.read)
    (base : Nat) (aligned : base%2=0) (bounded : base+12288 ≤ 2^64)
    (keysSeparate : MemoryRegions.Disjoint base 12288 input.cache.layout.keyBase (KvRegions.bytes steps))
    (valuesSeparate : MemoryRegions.Disjoint base 12288 input.cache.layout.valueBase (KvRegions.bytes steps))
    (queriesSeparate : ∀ head, MemoryRegions.Disjoint base 12288 (input.query head).base 512) : Execution input p contracted arch where
  kernel := { kernel with output := relocate kernel.output input.cache.memory base aligned bounded }
  initial := rfl
  keysSeparate := keysSeparate
  valuesSeparate := valuesSeparate
  queriesSeparate := queriesSeparate

def canonical (input : SdpaMemory.Input query cache) (p : SdpaVector.Platform) (contracted : Bool) (arch : Char)
    (base : Nat) (aligned : base%2=0) (bounded : base+12288 ≤ 2^64)
    (keysSeparate : MemoryRegions.Disjoint base 12288 input.cache.layout.keyBase (KvRegions.bytes steps))
    (valuesSeparate : MemoryRegions.Disjoint base 12288 input.cache.layout.valueBase (KvRegions.bytes steps))
    (queriesSeparate : ∀ head, MemoryRegions.Disjoint base 12288 (input.query head).base 512) : Execution input p contracted arch :=
  fromKernel input p contracted arch (input.execution p contracted arch).kernel base aligned bounded keysSeparate valuesSeparate queriesSeparate

def Execution.loaded (execution : Execution input p contracted arch) : SdpaLoads.Execution p contracted arch query cache.keys cache.values :=
  ⟨input.storage, execution.kernel⟩

theorem Execution.output_eq (execution : Execution input p contracted arch) (head : Fin 24) (i : Fin 256) :
    execution.loaded.output head i=SdpaDispatched.forward p contracted arch (query head)
      (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head)) i :=
  execution.loaded.output_eq head i

def Execution.afterCache (execution : Execution input p contracted arch) : KvRegions.Storage cache :=
  input.cache.reframe execution.kernel.output.memory
    (by
      intro offset bound
      have same := MemoryRegions.execute16_other execution.kernel.output.schedule execution.kernel.output.before
        (stores_inside execution.kernel.output) execution.keysSeparate offset bound
      exact same.trans (congrFun execution.initial (input.cache.layout.keyBase+offset)))
    (by
      intro offset bound
      have same := MemoryRegions.execute16_other execution.kernel.output.schedule execution.kernel.output.before
        (stores_inside execution.kernel.output) execution.valuesSeparate offset bound
      exact same.trans (congrFun execution.initial (input.cache.layout.valueBase+offset)))

def Execution.afterQueries (execution : Execution input p contracted arch) (head : Fin 24) : ArrayStorage.BFBuffer (query head) :=
  ArrayFrame.bf (input.query head) execution.kernel.output.memory (by
    intro offset bound
    have same := MemoryRegions.execute16_other execution.kernel.output.schedule execution.kernel.output.before
      (stores_inside execution.kernel.output) (execution.queriesSeparate head) offset bound
    exact same.trans ((congrFun execution.initial ((input.query head).base+offset)).trans
      (congrFun (input.shared head) ((input.query head).base+offset)).symm))

theorem Execution.cache_output_shared (execution : Execution input p contracted arch) (head : Fin 24) :
    execution.afterCache.memory=(execution.loaded.outputBuffer head).bytes := rfl

theorem Execution.queries_output_shared (execution : Execution input p contracted arch) (head : Fin 24) :
    (execution.afterQueries head).bytes=(execution.loaded.outputBuffer head).bytes := rfl

-- Any partial output-store list has the same frame. Thus interleaving
-- output stores with later input reads cannot change the protected inputs.
def Execution.duringCache (execution : Execution input p contracted arch) (stores : List HalfMemory.Store)
    (members : ∀ store ∈ stores, store ∈ (SdpaOutput.programs execution.kernel.output.base
      (SdpaDispatchedDevice.produced p contracted arch input.storage.queryValues input.storage.keys.read input.storage.values.read
        execution.kernel.first execution.kernel.second)).flatten) : KvRegions.Storage cache :=
  input.cache.after16 stores (stores_inside_of_subset _ execution.kernel.output.aligned _ stores members)
    execution.keysSeparate execution.valuesSeparate

def Execution.duringQueries (execution : Execution input p contracted arch) (stores : List HalfMemory.Store)
    (members : ∀ store ∈ stores, store ∈ (SdpaOutput.programs execution.kernel.output.base
      (SdpaDispatchedDevice.produced p contracted arch input.storage.queryValues input.storage.keys.read input.storage.values.read
        execution.kernel.first execution.kernel.second)).flatten) (head : Fin 24) : ArrayStorage.BFBuffer (query head) :=
  ArrayFrame.bf (input.query head) (HalfMemory.execute stores input.cache.memory) (by
    intro offset bound
    exact (MemoryRegions.execute16_other stores input.cache.memory
      (stores_inside_of_subset _ execution.kernel.output.aligned _ stores members) (execution.queriesSeparate head) offset bound).trans
        (congrFun (input.shared head) ((input.query head).base+offset)).symm)

end Inference.Kernels.Attention.SdpaOutputMemory
