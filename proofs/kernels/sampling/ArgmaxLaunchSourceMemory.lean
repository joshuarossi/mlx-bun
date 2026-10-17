import kernels.sampling.ArgmaxLaunchSourceSyntax
import kernels.sampling.ArgmaxScratchSourceMemory
import kernels.sampling.ArgmaxFinalStoreMemory

namespace Inference.Kernels.Sampling.ArgmaxLaunchSourceMemory
open Contracts.Mlx ArgmaxPairs ArgmaxLaunchSourceSyntax
open ArgmaxShuffleSyntax ArgmaxShuffleSemantics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] ArgmaxLaunchSourceSyntax.parse ArgmaxShuffleSyntax.parseBetter ArgmaxShuffleSemantics.parsedRun

def initialCandidate : Option Candidate := do
  match ←parse parseInit initSource with
  | .initialize => some sentinel | _ => none

theorem initialized : initialCandidate=some sentinel := by simp [initialCandidate,parsed_initSource]

def update (text : String) (value best : Candidate) : Option Candidate := do
  match ←parse parseUpdate text with
  | .update id =>
    if id="i" ∨ id="id" then do
      let comparison ←ArgmaxShuffleSyntax.parseBetter betterBody
      pure (selected comparison value best)
    else none
  | _ => none

theorem partial_update (value best : Candidate) : update partialUpdateSource value best=some (choose value best) := by
  simp [update,parsed_partialUpdateSource,parsed_better,selected_eq]
theorem finish_update (value best : Candidate) : update finishUpdateSource value best=some (choose value best) := by
  simp [update,parsed_finishUpdateSource,parsed_better,selected_eq]

def scanSource (text : String) : List Candidate → Candidate → Option Candidate
  | [],best => some best
  | value::rest,best => do scanSource text rest (←update text value best)

theorem scan_eq (text : String) (updateEq : ∀ value best, update text value best=some (choose value best))
    (values : List Candidate) (best : Candidate) : scanSource text values best=some (scan values best) := by
  induction values generalizing best with
  | nil => rfl
  | cons value rest ih =>
    simp only [scanSource,updateEq]
    exact ih _

def partialLane {logits : Fin 248320 → ArrayStorage.BF} {platform : LogSumExpRanges.Platform}
    {source : ArrayStorage.BFBuffer logits} (lse : LogSumExpMemory.Execution platform source) (tile : Fin 243) (thread : Fin 128) : Option Candidate := do
  let first ←initialCandidate
  let values ←NormalizedScoreSourceMemory.laneValues lse tile thread
  scanSource partialUpdateSource values first

theorem partial_lane_eq {logits : Fin 248320 → ArrayStorage.BF} {platform : LogSumExpRanges.Platform}
    {source : ArrayStorage.BFBuffer logits} (lse : LogSumExpMemory.Execution platform source)
    (primitive : LogSumExpRanges.Primitives platform)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)|≤(2:ℝ)^(23:Nat)) (tile : Fin 243) (thread : Fin 128) :
    partialLane lse tile thread=some (NormalizedArgmaxExecution.partialLane (NormalizedArgmaxMemory.candidates lse) tile thread) := by
  unfold partialLane
  rw [initialized,NormalizedScoreSourceMemory.lane_values_eq lse primitive bound tile thread]
  exact scan_eq partialUpdateSource partial_update _ _

-- The source's integer row * P + tile/index executes as uint32 before
-- pointer indexing. The selected B1 row has row=0 and P=243.
def rowIndex (row index : BitVec 32) : Nat := (row*(BitVec.ofNat 32 243)+index).toNat

def storePartial (layout : ArgmaxPairMemory.Layout 243) (lane : Fin 32)
    (row tile : BitVec 32) (value : Candidate) : Option (List ByteMemory.Store) := do
  match ←parse parsePartialStore partialStoreSource with
  | .partialStore owner =>
    if lane.val=owner then
      pure [⟨(layout.scores+4*rowIndex row tile)/4,FloatMemory.bits (ArgmaxStorage.score value)⟩,
        ⟨(layout.ids+4*rowIndex row tile)/4,BitVec.ofNat 32 value.index⟩]
    else pure []
  | _ => none

theorem partial_store (layout : ArgmaxPairMemory.Layout 243) (values : Fin 243 → Candidate) (tile : Fin 243) :
    storePartial layout 0 0 (BitVec.ofNat 32 tile.val) (values tile)=
      some [ArgmaxPairMemory.scoreStore layout values tile,ArgmaxPairMemory.idStore layout values tile] := by
  have small : tile.val<4294967296 := by have := tile.isLt; omega
  have score : (layout.scores+4*tile.val)/4=layout.scores/4+tile.val := by omega
  have id : (layout.ids+4*tile.val)/4=layout.ids/4+tile.val := by omega
  simp [storePartial,parsed_partialStoreSource,rowIndex,BitVec.toNat_ofNat,Nat.mod_eq_of_lt small,
    ArgmaxPairMemory.scoreStore,ArgmaxPairMemory.idStore,score,id]

def readPair (layout : ArgmaxPairMemory.Layout 243) (memory : ByteMemory.Bytes) (row index : BitVec 32) : Option Candidate := do
  match ←parse parseFinishRead finishReadSource with
  | .finishRead => pure ⟨ArgmaxStorage.decodedScore (FloatMemory.load memory (layout.scores+4*rowIndex row index)),
    (ByteMemory.load32 memory (layout.ids+4*rowIndex row index)).toNat⟩
  | _ => none

def readAt (layout : ArgmaxPairMemory.Layout 243) (memory : ByteMemory.Bytes) (index : Nat) : Candidate :=
  ⟨ArgmaxStorage.decodedScore (FloatMemory.load memory (layout.scores+4*index)),
    (ByteMemory.load32 memory (layout.ids+4*index)).toNat⟩

theorem pair_read (layout : ArgmaxPairMemory.Layout 243) (memory : ByteMemory.Bytes) (index : Nat) (small : index<2^32) :
    readPair layout memory 0 (BitVec.ofNat 32 index)=some (readAt layout memory index) := by
  change index<4294967296 at small
  simp [readPair,parsed_finishReadSource,rowIndex,readAt,BitVec.toNat_ofNat,Nat.mod_eq_of_lt small]

-- Parse the original simd==0 ownership and both scratch-load ternaries.
def mergeInputs {input : Fin 128 → Candidate} (trace : ArgmaxPairMemory.Reduction input) : Option (Fin 4 → Candidate) := do
  match ←parse parseMergeRead mergeReadSource with
  | .mergeRead group scoreCount idCount =>
    if group=0 then pure (fun (lane : Fin 4) => ⟨
      if lane.val < scoreCount then ArgmaxStorage.decodedScore (FloatMemory.load trace.scratch.memory (4*lane.val)) else none,
      if lane.val < idCount then (ByteMemory.load32 trace.scratch.memory (16+4*lane.val)).toNat else 0xffffffff⟩)
    else none
  | _ => none

theorem merge_inputs {input : Fin 128 → Candidate} (trace : ArgmaxPairMemory.Reduction input) :
    mergeInputs trace=some trace.scratch.read := by
  unfold mergeInputs
  rw [parsed_mergeReadSource]
  change some (fun (lane : Fin 4) => (⟨
    if lane.val<4 then ArgmaxStorage.decodedScore (FloatMemory.load trace.scratch.memory (4*lane.val)) else none,
    if lane.val<4 then (ByteMemory.load32 trace.scratch.memory (16+4*lane.val)).toNat else 0xffffffff⟩ : Candidate))=some trace.scratch.read
  apply congrArg some
  funext lane
  have bound := lane.isLt
  simp [bound,ArgmaxPairMemory.Trace.read,ArgmaxPairMemory.localLayout]

attribute [local irreducible] mergeInputs

def mergeSource {input : Fin 128 → Candidate} (trace : ArgmaxPairMemory.Reduction input) : Option Candidate := do
  let values ←mergeInputs trace
  parsedRun mergeLoop values 0

theorem merge_source (original : Fin 248320 → Candidate) (identified : ArgmaxSourceOrigins.Identified original)
    (input : Fin 128 → Candidate) (valid : ∀ i, ArgmaxStorage.Valid (input i))
    (origin : ∀ i, NormalizedArgmaxExecution.Origin original (input i)) (trace : ArgmaxPairMemory.Reduction input) :
    mergeSource trace=some trace.output := by
  have same := congrArg (fun (values : Option (Fin 4 → Candidate)) =>
    values.bind (fun current => parsedRun mergeLoop current 0)) (merge_inputs trace)
  exact same.trans (ArgmaxSourceOrigins.scratch_exact original identified input valid origin trace)

variable {logits : Fin 248320 → ArrayStorage.BF} {platform : LogSumExpRanges.Platform}
  {source : ArrayStorage.BFBuffer logits} {lse : LogSumExpMemory.Execution platform source}
  (selection : NormalizedArgmaxMemory.Execution lse)

def tileStores (tile : Fin 243) : Option (List ByteMemory.Store) := do
  let value ←mergeSource (selection.tiles tile)
  storePartial selection.layout 0 0 (BitVec.ofNat 32 tile.val) value

def partialPrograms : Option (List (List ByteMemory.Store)) := (List.finRange 243).mapM (tileStores selection)

private theorem mapM_some {α β : Type} (items : List α) (f : α → Option β) (g : α → β)
    (same : ∀ item∈items, f item=some (g item)) : items.mapM f=some (items.map g) := by
  induction items with
  | nil => rfl
  | cons item rest ih =>
    simp only [List.mapM_cons,same item (by simp),List.map_cons]
    rw [ih (fun value member => same value (by simp [member]))]
    rfl

theorem partial_programs (valid : ∀ i, ArgmaxStorage.Valid (NormalizedArgmaxMemory.candidates lse i)) :
    partialPrograms selection=some (ArgmaxPairMemory.programs selection.layout (fun tile => (selection.tiles tile).output)) := by
  unfold partialPrograms ArgmaxPairMemory.programs
  apply mapM_some
  intro tile _
  unfold tileStores
  rw [merge_source _ ArgmaxSourceOrigins.candidates_identified _
    (NormalizedArgmaxDevice.partial_lane_valid _ valid tile) (ArgmaxSourceOrigins.partial_lane_origin _ tile)]
  exact partial_store selection.layout (fun tile => (selection.tiles tile).output) tile

def finishWhile : Nat → BitVec 32 → BitVec 32 → Option (List Nat)
  | fuel,current,stride =>
    if current.toNat<243 then
      match fuel with
      | 0 => none
      | left+1 => do pure (current.toNat::(←finishWhile left (current+stride) stride))
    else some []

def finishTraversal (thread : Fin 128) : Option (List Nat) := do
  match ←parse parseFinishLoop finishLoopSource with
  | .finishLoop stride => finishWhile 2 (BitVec.ofNat 32 thread.val) (BitVec.ofNat 32 stride)
  | _ => none

theorem finish_traversal (thread : Fin 128) : finishTraversal thread=some (NormalizedArgmaxLayout.finishOffsets thread) := by
  have first : thread.val<243 := by have := thread.isLt; omega
  have a : thread.val<4294967296 := by have := thread.isLt; omega
  have b : thread.val+128<4294967296 := by have := thread.isLt; omega
  have c : thread.val+128+128<4294967296 := by have := thread.isLt; omega
  have last : ¬thread.val+128+128<243 := by omega
  by_cases second : thread.val+128<243
  all_goals simp [finishTraversal,parsed_finishLoopSource,finishWhile,BitVec.toNat_add,BitVec.toNat_ofNat,
    Nat.mod_eq_of_lt a,Nat.mod_eq_of_lt b,Nat.mod_eq_of_lt c,first,second,last,
    NormalizedArgmaxLayout.finishOffsets,NormalizedArgmaxLayout.finishOffset,List.finRange_succ]

def finishValues (thread : Fin 128) : Option (List Candidate) := do
  let indices ←finishTraversal thread
  indices.mapM (fun index => readPair selection.layout selection.partials.memory 0 (BitVec.ofNat 32 index))

theorem finish_values (thread : Fin 128) : finishValues selection thread=some
    ((NormalizedArgmaxLayout.finishOffsets thread).attach.map (fun index => selection.partials.read
      ⟨index.val,NormalizedArgmaxLayout.finish_in_bounds thread index.val index.property⟩)) := by
  unfold finishValues
  rw [finish_traversal]
  have read : (NormalizedArgmaxLayout.finishOffsets thread).mapM
      (fun index => readPair selection.layout selection.partials.memory 0 (BitVec.ofNat 32 index))=
      some ((NormalizedArgmaxLayout.finishOffsets thread).map (readAt selection.layout selection.partials.memory)) := by
    apply mapM_some
    intro index member
    exact pair_read selection.layout selection.partials.memory index
      (by have := NormalizedArgmaxLayout.finish_in_bounds thread index member; omega)
  change (NormalizedArgmaxLayout.finishOffsets thread).mapM _=_
  rw [read]
  congr 1
  rw [←List.attach_map_val]
  rfl

def finishLane (thread : Fin 128) : Option Candidate := do
  let first ←initialCandidate
  let values ←finishValues selection thread
  scanSource finishUpdateSource values first

theorem finish_lane (thread : Fin 128) : finishLane selection thread=
    some (NormalizedArgmaxDevice.finishInput selection.partials.read thread) := by
  unfold finishLane
  rw [initialized,finish_values]
  exact scan_eq finishUpdateSource finish_update _ _

def tokenMemory : Option ByteMemory.Bytes := do
  let value ←mergeSource selection.finish
  ArgmaxFinalStoreMemory.executeSource 0 0 (BitVec.ofNat 32 value.index) selection.destination selection.partials.memory

theorem token_memory (valid : ∀ i, ArgmaxStorage.Valid (NormalizedArgmaxMemory.candidates lse i)) :
    tokenMemory selection=some selection.memory := by
  unfold tokenMemory
  rw [merge_source _ ArgmaxSourceOrigins.candidates_identified _ (selection.finish_valid valid)
    (ArgmaxSourceOrigins.finish_lane_origin selection valid)]
  change ArgmaxFinalStoreMemory.executeSource 0 0 (BitVec.ofNat 32 selection.finish.output.index)
    selection.destination selection.partials.memory=some selection.memory
  rw [ArgmaxFinalStoreMemory.lane_zero]
  change some (ByteMemory.store32 selection.partials.memory selection.destination
    (BitVec.ofNat 32 selection.finish.output.index))=some selection.memory
  apply congrArg some
  exact ((ArgmaxFinalStoreMemory.trace_store selection.output).trans
    (congrArg (fun memory => ByteMemory.store32 memory selection.destination (BitVec.ofNat 32 selection.finish.output.index)) selection.afterPartials)).symm

-- All phases share the existing sampler's actual byte images and completed
-- interleavings. These equalities are conclusions derived from parsed code;
-- none is supplied as a desired per-phase output premise.
structure Certificate : Prop where
  traversal : ∀ tile thread, ArgmaxTraversalSource.ParsedRuns ArgmaxTraversalSource.sourceHeader tile thread
    (NormalizedArgmaxLayout.partialOffsets tile thread)
  partialLanes : ∀ tile thread, partialLane lse tile thread=
    some (NormalizedArgmaxExecution.partialLane (NormalizedArgmaxMemory.candidates lse) tile thread)
  currentScores : ∀ stores, (∀ store∈stores,store∈selection.partials.schedule) → ∀ index : Fin 248320,
    (NormalizedScoreSourceMemory.run source.base lse.destination index.val (ByteMemory.execute stores selection.partials.before)).map
      (fun value => (⟨some value,index.val⟩ : Candidate))=some (NormalizedArgmaxMemory.candidates lse index)
  partialScratch : ∀ tile, ∃ writes,
    ArgmaxScratchSourceMemory.programs (NormalizedArgmaxExecution.partialLane (NormalizedArgmaxMemory.candidates lse) tile)=some writes ∧
    ThreadgroupWrites.Executes writes (selection.tiles tile).scratch.schedule (selection.tiles tile).scratch.remaining ∧
    ThreadgroupWrites.AtBarrier (selection.tiles tile).scratch.remaining
  globalPartials : ∃ writes, partialPrograms selection=some writes ∧
    ThreadgroupWrites.Executes writes selection.partials.schedule selection.partials.remaining ∧
    ThreadgroupWrites.AtBarrier selection.partials.remaining
  finishTraversal : ∀ thread, finishTraversal thread=some (NormalizedArgmaxLayout.finishOffsets thread)
  finishLanes : ∀ thread, finishLane selection thread=some (NormalizedArgmaxDevice.finishInput selection.partials.read thread)
  finishScratch : ∃ writes, ArgmaxScratchSourceMemory.programs (NormalizedArgmaxDevice.finishInput selection.partials.read)=some writes ∧
    ThreadgroupWrites.Executes writes selection.finish.scratch.schedule selection.finish.scratch.remaining ∧
    ThreadgroupWrites.AtBarrier selection.finish.scratch.remaining
  output : tokenMemory selection=some selection.memory

theorem checked_sampler (primitive : LogSumExpRanges.Primitives platform)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)|≤(2:ℝ)^(23:Nat)) : Certificate selection := by
  have valid := NormalizedArgmaxMemory.candidates_valid lse primitive bound
  exact ⟨ArgmaxTraversalSource.source_visits,partial_lane_eq lse primitive bound,
    fun stores subset index => NormalizedScoreSourceMemory.during_candidate lse selection stores subset primitive bound index,
    ArgmaxScratchSourceMemory.selected_partial selection valid,
    ⟨_,partial_programs selection valid,selection.partials.execution,selection.partials.completed⟩,
    finish_traversal,finish_lane selection,ArgmaxScratchSourceMemory.selected_finish selection valid,
    token_memory selection valid⟩

theorem source_token (primitive : LogSumExpRanges.Primitives platform)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)|≤(2:ℝ)^(23:Nat)) :
    Certificate selection ∧
      (tokenMemory selection).map (fun memory => (ByteMemory.load32 memory selection.destination).toNat)=
        some (GreedySampling.sample platform logits) := by
  have source := checked_sampler selection primitive bound
  refine ⟨source,?_⟩
  rw [source.output]
  exact congrArg some (selection.token_eq primitive bound)

end Inference.Kernels.Sampling.ArgmaxLaunchSourceMemory
