import models.qwen.DecodeExistingStepConstruction

-- Concrete recursive graph execution for a token whose KV capacity is reused.
-- Input cache geometry is a reached-state invariant, not a launch-plan oracle.
-- Loaded storage, dispatch, headroom and native ownership stay explicit.
namespace Inference.Models.Qwen.DecodeExistingHighWaterConstruction
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention
open ResidualDeltaHighWater (Frontier Before before_mono cacheProtected_mono)
open DecodeHighWaterGeometry (After)
open DecodeExistingStepConstruction (stageBytes next next_cursor)
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

def bytes : List Stage → Nat → Nat
  | [], _ => 0
  | kind::rest, tokens => stageBytes kind tokens+bytes rest tokens

section Geometry
variable {kind : Stage} {rest : List Stage} {tokens : Nat}
  (cache : Caches (kind::rest) tokens) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage (kind::rest) cache source.bytes)
  (trace : DecodeMemoryChain.Trace (kind::rest) cache input angle source storage)
  (safe : DecodeMemoryChain.CacheSafe (kind::rest) cache input angle source storage trace)

theorem after_protected (property : Nat → Nat → Prop)
    (head : DecodePreservation.StageProtected property kind (cacheAfter kind cache.1 input angle) trace.1.first.cacheAfter.storage)
    (tail : DecodePreservation.Protected property rest (DecodeChain.run rest cache.2 (forward kind cache.1 input angle) angle).2 _
      (DecodeMemoryChain.after rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2 safe.2)) :
    DecodePreservation.Protected property (kind::rest) (DecodeChain.run (kind::rest) cache input angle).2 _
      (DecodeMemoryChain.after (kind::rest) cache input angle source storage trace safe) := by
  apply (DecodeCacheGeometry.protected_iff _ _ _ _ _).mpr
  rw [DecodeHighWaterGeometry.after_regions]
  intro region member
  rcases List.mem_append.mp member with first|second
  · exact (DecodeCacheGeometry.stage_protected_iff _ _ _ _).mp head region first
  · exact (DecodeCacheGeometry.protected_iff _ _ _ _ _).mp tail region second

theorem after_pairwise
    (apart : DecodePreservation.StageProtected (fun base size => DecodePreservation.Protected (MemoryRegions.Disjoint base size)
      rest (DecodeChain.run rest cache.2 (forward kind cache.1 input angle) angle).2 _
      (DecodeMemoryChain.after rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2 safe.2))
      kind (cacheAfter kind cache.1 input angle) trace.1.first.cacheAfter.storage)
    (tailPairwise : DecodeCacheGeometry.Pairwise rest (DecodeChain.run rest cache.2 (forward kind cache.1 input angle) angle).2 _
      (DecodeMemoryChain.after rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2 safe.2)) :
    DecodeCacheGeometry.Pairwise (kind::rest) (DecodeChain.run (kind::rest) cache input angle).2 _
      (DecodeMemoryChain.after (kind::rest) cache input angle source storage trace safe) := by
  unfold DecodeCacheGeometry.Pairwise
  rw [DecodeHighWaterGeometry.after_regions]
  apply List.pairwise_append.mpr
  refine ⟨DecodeCacheGeometry.stage_pairwise _ _ _,tailPairwise,?_⟩
  intro first firstMember second secondMember
  have separate := (DecodeCacheGeometry.stage_protected_iff _ _ _ _).mp apart first firstMember
  exact (DecodeCacheGeometry.protected_iff _ _ _ _ _).mp separate second secondMember
end Geometry

theorem stage_and (kind : Stage) (cache : Cache kind tokens) (stored : DecodeFrame.StageStorage kind cache)
    {first second : Nat → Nat → Prop}
    (left : DecodePreservation.StageProtected first kind cache stored)
    (right : DecodePreservation.StageProtected second kind cache stored) :
    DecodePreservation.StageProtected (fun base size => first base size ∧ second base size) kind cache stored := by
  cases kind <;> exact ⟨⟨left.1,right.1⟩,⟨left.2,right.2⟩⟩

section Result
variable {all stages : List Stage} {tokens : Nat}
  (position : DecodeParameterConstruction.Cursor all stages)
  (cache : Caches stages tokens) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage stages cache source.bytes)
  (parameters : DecodeParameterMemory.Storage all source.bytes) (frontier : Frontier)

structure Request (parameterCut cacheCut : Nat) : Prop where
  ordered : parameterCut≤cacheCut ∧ cacheCut≤frontier.cursor
  capacity : frontier.cursor+bytes stages tokens≤2^64
  sourceBound : Before frontier.cursor source.base 10240
  sourceLower : cacheCut≤source.base
  parametersBound : DecodeParameterMemory.Protected all parameters (Before parameterCut)
  cachesBelow : DecodePreservation.Protected (Before cacheCut) stages cache source.bytes storage
  cachesAbove : DecodePreservation.Protected (After parameterCut) stages cache source.bytes storage
  pairwise : DecodeCacheGeometry.Pairwise stages cache source.bytes storage
  dispatch : DecodeHighWaterConstruction.Dispatches stages
  room : ¬State.KvAllocation.capacity tokens<tokens+1

structure Result (parameterCut cacheCut : Nat) where
  plan : DecodeParameterConstruction.ChainPlan stages position cache input angle source storage parameters
  safeBefore : ∀ base size, Before frontier.cursor base size →
    DecodePreservation.Protected (MemoryRegions.Disjoint base size) stages cache source.bytes storage →
    DecodeMemoryChain.Safe stages cache input angle source storage
      (DecodeParameterConstruction.chain stages position cache input angle source storage parameters plan) base size
  cacheSafe : DecodeParameterConstruction.CacheRegions stages position cache input angle source storage parameters plan
  outputBound : Before (frontier.cursor+bytes stages tokens)
    (DecodeParameterConstruction.outputBuffer stages position cache input angle source storage parameters plan).base 10240
  outputLower : cacheCut≤(DecodeParameterConstruction.outputBuffer stages position cache input angle source storage parameters plan).base
  cachesBound : DecodePreservation.Protected (Before (frontier.cursor+bytes stages tokens)) stages
    (DecodeChain.run stages cache input angle).2 _
    (DecodeParameterConstruction.after stages position cache input angle source storage parameters plan cacheSafe)
  cachesAbove : DecodePreservation.Protected (After parameterCut) stages
    (DecodeChain.run stages cache input angle).2 _
    (DecodeParameterConstruction.after stages position cache input angle source storage parameters plan cacheSafe)
  pairwise : DecodeCacheGeometry.Pairwise stages (DecodeChain.run stages cache input angle).2 _
    (DecodeParameterConstruction.after stages position cache input angle source storage parameters plan cacheSafe)
  updatedApart : ∀ base size, Before frontier.cursor base size →
    DecodePreservation.Protected (MemoryRegions.Disjoint base size) stages cache source.bytes storage →
    DecodePreservation.Protected (MemoryRegions.Disjoint base size) stages (DecodeChain.run stages cache input angle).2 _
      (DecodeParameterConstruction.after stages position cache input angle source storage parameters plan cacheSafe)
end Result

section Build
variable {all : List Stage} {tokens parameterCut cacheCut : Nat}

def build : (stages : List Stage) → (position : DecodeParameterConstruction.Cursor all stages) →
    (cache : Caches stages tokens) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    (parameters : DecodeParameterMemory.Storage all source.bytes) → (frontier : Frontier) →
    Request cache input source storage parameters frontier parameterCut cacheCut →
    Result position cache input angle source storage parameters frontier parameterCut cacheCut
  | [], _, _, _, _, _, _, _, _, request => {
      plan := ⟨⟩
      safeBefore := fun _ _ _ _ => trivial
      cacheSafe := trivial
      outputBound := by simpa only [DecodeParameterConstruction.outputBuffer,DecodeMemoryChain.outputBuffer,bytes,Nat.add_zero] using request.sourceBound
      outputLower := request.sourceLower
      cachesBound := trivial
      cachesAbove := trivial
      pairwise := List.Pairwise.nil
      updatedApart := fun _ _ _ _ => trivial }
  | kind::rest, position, cache, input, angle, source, storage, parameters, frontier, request => by
    have headCapacity : (next frontier kind tokens).cursor≤2^64 := by
      rw [next_cursor]
      have capacity := request.capacity
      change frontier.cursor+(stageBytes kind tokens+bytes rest tokens)≤2^64 at capacity
      omega
    let headRequest : DecodeExistingStepConstruction.Request cache input source storage parameters frontier parameterCut cacheCut := {
      ordered := request.ordered
      capacity := headCapacity
      sourceBound := request.sourceBound
      sourceLower := request.sourceLower
      parametersBound := request.parametersBound
      cachesBelow := request.cachesBelow
      cachesAbove := request.cachesAbove
      pairwise := request.pairwise
      dispatch := request.dispatch.1
      room := request.room }
    let first := DecodeExistingStepConstruction.plan position cache input angle source storage parameters frontier headRequest
    have firstBound := DecodeExistingStepConstruction.updated_bound position cache input angle source storage parameters frontier headRequest
    have firstApart := DecodeExistingStepConstruction.updated_apart position cache input angle source storage parameters frontier headRequest
    have monotone : frontier.cursor≤(next frontier kind tokens).cursor := by rw [next_cursor]; exact Nat.le_add_right _ _
    let tailRequest : Request cache.2 (forward kind cache.1 input angle) first.step.first.buffer first.step.nextStorage
        first.nextParameters (next frontier kind tokens) parameterCut cacheCut := {
      ordered := ⟨request.ordered.1,request.ordered.2.trans monotone⟩
      capacity := by rw [next_cursor]; simpa only [bytes,Nat.add_assoc] using request.capacity
      sourceBound := DecodeExistingStepConstruction.output_bound position cache input angle source storage parameters frontier headRequest
      sourceLower := DecodeExistingStepConstruction.output_lower position cache input angle source storage parameters frontier headRequest
      parametersBound := DecodeExistingStepConstruction.parameters_bound position cache input angle source storage parameters frontier headRequest
      cachesBelow := DecodeExistingStepConstruction.retained_below position cache input angle source storage parameters frontier headRequest
      cachesAbove := DecodeExistingStepConstruction.retained_above position cache input angle source storage parameters frontier headRequest
      pairwise := DecodeExistingStepConstruction.retained_pairwise position cache input angle source storage parameters frontier headRequest
      dispatch := request.dispatch.2
      room := request.room }
    let tail := build rest (.next position) cache.2 (forward kind cache.1 input angle) angle
      first.step.first.buffer first.step.nextStorage first.nextParameters (next frontier kind tokens) tailRequest
    have joined := stage_and kind (cacheAfter kind cache.1 input angle) first.step.first.cacheAfter.storage firstBound firstApart
    have headSurvives := DecodeHighWaterConstruction.stage_mono kind _ _
      (fun base size bounds => tail.safeBefore base size bounds.1 bounds.2) joined
    let plan : DecodeParameterConstruction.ChainPlan (kind::rest) position cache input angle source storage parameters := ⟨first,tail.plan⟩
    have cacheSafe : DecodeParameterConstruction.CacheRegions (kind::rest) position cache input angle source storage parameters plan :=
      ⟨headSurvives,tail.cacheSafe⟩
    let trace := DecodeParameterConstruction.chain (kind::rest) position cache input angle source storage parameters plan
    let safe := DecodeParameterConstruction.cacheSafe (kind::rest) position cache input angle source storage parameters plan cacheSafe
    refine {
      plan := plan
      safeBefore := ?_
      cacheSafe := cacheSafe
      outputBound := ?_
      outputLower := tail.outputLower
      cachesBound := ?_
      cachesAbove := ?_
      pairwise := ?_
      updatedApart := ?_ }
    · intro base size bound separate
      exact ⟨DecodeExistingStepConstruction.writes position cache input angle source storage parameters frontier headRequest bound separate,
        tail.safeBefore base size (before_mono monotone bound)
          (DecodeExistingStepConstruction.retained_geometry position cache input angle source storage parameters frontier headRequest _ separate.2)⟩
    · have bound := tail.outputBound
      rw [next_cursor] at bound
      simpa only [DecodeParameterConstruction.outputBuffer,DecodeMemoryChain.outputBuffer,DecodeParameterConstruction.chain,bytes,Nat.add_assoc] using bound
    · apply after_protected cache input angle source storage trace safe (Before (frontier.cursor+bytes (kind::rest) tokens))
      · exact DecodeHighWaterConstruction.stage_mono kind _ _ (fun _ _ bound => before_mono
          (by rw [next_cursor]; dsimp [bytes]; omega) bound) firstBound
      · have bound := tail.cachesBound
        rw [next_cursor] at bound
        simpa only [trace,plan,DecodeParameterConstruction.chain,DecodeParameterConstruction.after,bytes,Nat.add_assoc] using bound
    · exact after_protected cache input angle source storage trace safe (After parameterCut)
        (DecodeExistingStepConstruction.updated_above position cache input angle source storage parameters frontier headRequest) tail.cachesAbove
    · exact after_pairwise cache input angle source storage trace safe
        (DecodeHighWaterConstruction.stage_mono kind _ _ (fun base size bounds => tail.updatedApart base size bounds.1 bounds.2) joined)
        tail.pairwise
    · intro base size bound separate
      exact after_protected cache input angle source storage trace safe (MemoryRegions.Disjoint base size)
        (DecodeExistingStepConstruction.updated_separate position cache input angle source storage parameters frontier headRequest bound separate)
        (tail.updatedApart base size (before_mono monotone bound)
          (DecodeExistingStepConstruction.retained_geometry position cache input angle source storage parameters frontier headRequest _ separate.2))
end Build


section Derived
variable {all stages : List Stage} {tokens parameterCut cacheCut : Nat}
  {position : DecodeParameterConstruction.Cursor all stages}
  {cache : Caches stages tokens} {input : Row BF} {angle : RopeAngles.Inputs}
  {source : ArrayStorage.BFBuffer input} {storage : DecodeFrame.Storage stages cache source.bytes}
  {parameters : DecodeParameterMemory.Storage all source.bytes} {frontier : Frontier}
  (result : Result position cache input angle source storage parameters frontier parameterCut cacheCut)

theorem stage_bytes_aligned (kind : Stage) (tokens : Nat) : stageBytes kind tokens%16=0 := by
  have aligned := (next ⟨0,by decide⟩ kind tokens).aligned
  simpa only [next_cursor,Nat.zero_add] using aligned

theorem bytes_aligned (stages : List Stage) (tokens : Nat) : bytes stages tokens%16=0 := by
  induction stages with
  | nil => rfl
  | cons kind rest ih => simp only [bytes,Nat.add_mod,stage_bytes_aligned,ih,Nat.zero_add,Nat.zero_mod]

def Result.endFrontier (_result : Result position cache input angle source storage parameters frontier parameterCut cacheCut) : Frontier where
  cursor := frontier.cursor+bytes stages tokens
  aligned := by rw [Nat.add_mod,frontier.aligned,bytes_aligned]

theorem Result.other_region {base size : Nat} (bound : Before frontier.cursor base size)
    (separate : DecodePreservation.Protected (MemoryRegions.Disjoint base size) stages cache source.bytes storage)
    (offset : Nat) (inside : offset<size) :
    (DecodeParameterConstruction.outputBuffer stages position cache input angle source storage parameters result.plan).bytes (base+offset)=source.bytes (base+offset) :=
  DecodeMemoryChain.other_region stages cache input angle source storage
    (DecodeParameterConstruction.chain stages position cache input angle source storage parameters result.plan)
    base size (result.safeBefore base size bound separate) offset inside

theorem Result.read_result : DecodeParameterConstruction.readResult stages position cache input angle source storage parameters
    result.plan result.cacheSafe=DecodeChain.run stages cache input angle :=
  DecodeParameterConstruction.read_result_eq stages position cache input angle source storage parameters result.plan result.cacheSafe

theorem Result.parameters_bound (bound : DecodeParameterMemory.Protected all parameters (Before parameterCut)) :
    DecodeParameterMemory.Protected all
      (DecodeParameterConstruction.finalParameters stages position cache input angle source storage parameters result.plan)
      (Before parameterCut) :=
  (DecodeParameterConstruction.finalParameters_regions stages position cache input angle source storage parameters result.plan _).mpr bound

theorem Result.safe_below {base size : Nat} (ordered : parameterCut≤frontier.cursor)
    (above : DecodePreservation.Protected (After parameterCut) stages cache source.bytes storage)
    (bound : Before parameterCut base size) :
    DecodeMemoryChain.Safe stages cache input angle source storage
      (DecodeParameterConstruction.chain stages position cache input angle source storage parameters result.plan) base size :=
  result.safeBefore base size (before_mono ordered bound)
    (cacheProtected_mono stages cache storage (fun _ _ lower => Or.inl (bound.trans lower)) above)

theorem Result.updated_separate_below {base size : Nat} (bound : Before parameterCut base size) :
    DecodePreservation.Protected (MemoryRegions.Disjoint base size) stages (DecodeChain.run stages cache input angle).2 _
      (DecodeParameterConstruction.after stages position cache input angle source storage parameters result.plan result.cacheSafe) :=
  cacheProtected_mono stages _ _ (fun _ _ lower => Or.inl (bound.trans lower)) result.cachesAbove

end Derived

end Inference.Models.Qwen.DecodeExistingHighWaterConstruction
