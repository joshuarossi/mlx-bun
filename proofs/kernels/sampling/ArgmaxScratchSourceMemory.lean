import kernels.sampling.ArgmaxScratchSourceSyntax
import kernels.sampling.ArgmaxSourceOrigins

namespace Inference.Kernels.Sampling.ArgmaxScratchSourceMemory
open Contracts.Mlx ArgmaxPairs ArgmaxScratchSourceSyntax
open ArgmaxShuffleSyntax ArgmaxShuffleSemantics
set_option maxRecDepth 10000

-- Separate typed scores[4]/ids[4] occupy the already-defined localLayout.
-- Stores precede this thread's barrier event; no hardware completion is inferred.
inductive Event where
  | store : ByteMemory.Store → Event
  | barrier : Event

def stores (events : List Event) : List ByteMemory.Store := events.filterMap (fun event =>
  match event with | .store write => some write | .barrier => none)

def execute (statement : Body) (lane : Fin 32) (group : Fin 4) (value : Candidate) : Option (List Event) :=
  if lane.val=statement.ownerLane then
    if group.val<statement.scoreCount ∧ group.val<statement.idCount then
      some [.store ⟨group.val,FloatMemory.bits (ArgmaxStorage.score value)⟩,
        .store ⟨4+group.val,BitVec.ofNat 32 value.index⟩,.barrier]
    else none
  else some [.barrier]

def executeSource (lane : Fin 32) (group : Fin 4) (value : Candidate) : Option (List Event) := do
  let statement ←parse sourceBody
  execute statement lane group value

theorem owner (group : Fin 4) (value : Candidate) : executeSource 0 group value=
    some [.store (ArgmaxPairMemory.scoreStore ArgmaxPairMemory.localLayout (fun _ : Fin 4 => value) group),
      .store (ArgmaxPairMemory.idStore ArgmaxPairMemory.localLayout (fun _ : Fin 4 => value) group),.barrier] := by
  unfold executeSource
  rw [parsed]
  have bound := group.isLt
  simp [execute,body,ArgmaxPairMemory.scoreStore,ArgmaxPairMemory.idStore,ArgmaxPairMemory.localLayout,bound]

theorem inactive (lane : Fin 32) (nonzero : lane.val≠0) (group : Fin 4) (value : Candidate) :
    executeSource lane group value=some [.barrier] := by
  unfold executeSource
  rw [parsed]
  simp [execute,body,nonzero]

theorem barrier_reached (lane : Fin 32) (group : Fin 4) (value : Candidate) :
    ∃ events, executeSource lane group value=some events ∧ Event.barrier∈events := by
  by_cases zero : lane.val=0
  · have same : lane=0 := Fin.ext zero
    subst lane
    exact ⟨_,owner group value,by simp⟩
  · exact ⟨_,inactive lane zero group value,by simp⟩

theorem owner_stores (group : Fin 4) (values : Fin 4 → Candidate) :
    (executeSource 0 group (values group)).map stores=
      some [ArgmaxPairMemory.scoreStore ArgmaxPairMemory.localLayout values group,
        ArgmaxPairMemory.idStore ArgmaxPairMemory.localLayout values group] := by
  rw [owner]
  rfl

-- Read best/bestId from execution of the parsed first shuffle phase. Exact
-- candidate equality is justified by original-token identity, including ±0.
def groupEvents (input : Fin 128 → Candidate) (group : Fin 4) : Option (List Event) := do
  let value ←parsedRun simdLoop (fun lane => input (ArgmaxReductionDevice.thread group lane)) 0
  executeSource 0 group value

def programs (input : Fin 128 → Candidate) : Option (List (List ByteMemory.Store)) :=
  (List.finRange 4).mapM (fun group => (groupEvents input group).map stores)

private theorem mapM_some {α β : Type} (items : List α) (f : α → Option β) (g : α → β)
    (same : ∀ item∈items, f item=some (g item)) : items.mapM f=some (items.map g) := by
  induction items with
  | nil => rfl
  | cons item rest ih =>
    simp only [List.mapM_cons,same item (by simp),List.map_cons]
    rw [ih (fun value member => same value (by simp [member]))]
    rfl

variable (original : Fin 248320 → Candidate) (identified : ArgmaxSourceOrigins.Identified original)
  (input : Fin 128 → Candidate) (valid : ∀ i, ArgmaxStorage.Valid (input i))
  (origin : ∀ i, NormalizedArgmaxExecution.Origin original (input i))

include original identified valid origin in
theorem group_events (group : Fin 4) :
    groupEvents input group=executeSource 0 group (ArgmaxReductionDevice.simd input group) := by
  unfold groupEvents
  rw [ArgmaxSourceOrigins.group_exact original identified input valid origin group]
  rfl

include original identified valid origin in
theorem programs_eq : programs input=some (ArgmaxPairMemory.programs ArgmaxPairMemory.localLayout (ArgmaxReductionDevice.simd input)) := by
  unfold programs ArgmaxPairMemory.programs
  apply mapM_some
  intro group _
  rw [group_events original identified input valid origin group]
  exact owner_stores group (ArgmaxReductionDevice.simd input)

-- This is the existing real local byte trace and its actual interleaving.
-- Completion is the explicit established trace barrier, never a result premise.
include original identified valid origin in
theorem checked_existing (trace : ArgmaxPairMemory.Reduction input) :
    ∃ writes, programs input=some writes ∧
      ThreadgroupWrites.Executes writes trace.scratch.schedule trace.scratch.remaining ∧
      ThreadgroupWrites.AtBarrier trace.scratch.remaining :=
  ⟨_,programs_eq original identified input valid origin,trace.scratch.execution,trace.scratch.completed⟩

open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
variable {logits : Fin 248320 → ArrayStorage.BF} {platform : LogSumExpRanges.Platform}
  {source : ArrayStorage.BFBuffer logits} {lse : LogSumExpMemory.Execution platform source}
  (selection : NormalizedArgmaxMemory.Execution lse)

-- Both actual launch stages are instantiated, so the generic store adapter is
-- consumed on the selected sampler path rather than left as unused machinery.
theorem selected_partial (candidateValid : ∀ i, ArgmaxStorage.Valid (NormalizedArgmaxMemory.candidates lse i)) (tile : Fin 243) :
    ∃ writes, programs (NormalizedArgmaxExecution.partialLane (NormalizedArgmaxMemory.candidates lse) tile)=some writes ∧
      ThreadgroupWrites.Executes writes (selection.tiles tile).scratch.schedule (selection.tiles tile).scratch.remaining ∧
      ThreadgroupWrites.AtBarrier (selection.tiles tile).scratch.remaining :=
  checked_existing (NormalizedArgmaxMemory.candidates lse) ArgmaxSourceOrigins.candidates_identified _
    (NormalizedArgmaxDevice.partial_lane_valid _ candidateValid tile)
    (ArgmaxSourceOrigins.partial_lane_origin _ tile) (selection.tiles tile)

theorem selected_finish (candidateValid : ∀ i, ArgmaxStorage.Valid (NormalizedArgmaxMemory.candidates lse i)) :
    ∃ writes, programs (NormalizedArgmaxDevice.finishInput selection.partials.read)=some writes ∧
      ThreadgroupWrites.Executes writes selection.finish.scratch.schedule selection.finish.scratch.remaining ∧
      ThreadgroupWrites.AtBarrier selection.finish.scratch.remaining :=
  checked_existing (NormalizedArgmaxMemory.candidates lse) ArgmaxSourceOrigins.candidates_identified _
    (selection.finish_valid candidateValid) (ArgmaxSourceOrigins.finish_lane_origin selection candidateValid) selection.finish

end Inference.Kernels.Sampling.ArgmaxScratchSourceMemory
