import models.qwen.ReachedTokenStepMemory

namespace Inference.Models.Qwen.ReachedTokenConstructedMemory
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
open TokenReadyMemory (Ready)
open ReachedTokenStepMemory
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

variable {p : Pipeline} {time parameterCut : Nat} (ready : Ready p time parameterCut)
  (context : ReachedTokenContext.Context p) (dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages)

def reuseWitness (room : ready.frontier.cursor+TokenNextPlanConstruction.bytes p time≤2^64)
    (reuse : ¬Inference.State.KvAllocation.capacity time<time+1) : Witness ready context where
  plan := (TokenReuseStepMemory.request ready dispatch room reuse).plan (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish
  safe := (TokenReuseStepMemory.request ready dispatch room reuse).parameters_safe (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish
  frontier := ⟨(TokenReuseStepMemory.request ready dispatch room reuse).nextCursor,
    (TokenReuseStepMemory.request ready dispatch room reuse).next_aligned⟩
  ordered := (congrArg (fun cursor => parameterCut≤cursor)
    (TokenReuseStepMemory.request_next_cursor ready dispatch room reuse)).mpr
    (ready.ordered.trans (Nat.le_add_right _ _))
  tokenBound := (TokenReuseStepMemory.request ready dispatch room reuse).token_bound (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish
  cachesBound := (TokenReuseStepMemory.request ready dispatch room reuse).caches_bound (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish
  cachesAbove := ((TokenReuseStepMemory.request ready dispatch room reuse).caches_geometry (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish).1
  pairwise := ((TokenReuseStepMemory.request ready dispatch room reuse).caches_geometry (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish).2

def growthWitness (growth : Inference.State.KvAllocation.capacity time<time+1)
    (room : ready.frontier.cursor+TokenGrowthPlanConstruction.bytes p time≤2^64) : Witness ready context where
  plan := (TokenGrowthStepMemory.request ready dispatch growth room).plan (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish
  safe := (TokenGrowthStepMemory.request ready dispatch growth room).parameters_safe (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish
  frontier := ⟨(TokenGrowthStepMemory.request ready dispatch growth room).nextCursor,
    (TokenGrowthStepMemory.request ready dispatch growth room).next_aligned⟩
  ordered := (congrArg (fun cursor => parameterCut≤cursor)
    (TokenGrowthStepMemory.next_cursor ready dispatch growth room)).mpr
    (ready.ordered.trans (Nat.le_add_right _ _))
  tokenBound := (TokenGrowthStepMemory.request ready dispatch growth room).token_bound (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish
  cachesBound := (TokenGrowthStepMemory.request ready dispatch growth room).caches_bound (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish
  cachesAbove := ResidualDeltaHighWater.cacheProtected_mono _ _ _
    (fun _ _ lower => (ready.ordered.trans (Nat.le_add_right _ 13120)).trans lower)
    ((TokenGrowthStepMemory.request ready dispatch growth room).caches_geometry (context.angles.value time) context.sampling
      (context.locals time).lse (context.locals time).tile (context.locals time).finish).1
  pairwise := ((TokenGrowthStepMemory.request ready dispatch growth room).caches_geometry (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish).2

variable (room : ready.frontier.cursor+TokenWorkspaceFootprint.bytes p time≤2^64)

def witness : Witness ready context :=
  if growth : Inference.State.KvAllocation.capacity time<time+1 then
    growthWitness ready context dispatch growth
      (by simpa only [TokenWorkspaceFootprint.bytes,ite_eq_left growth] using room)
  else
    reuseWitness ready context dispatch
      (by simpa only [TokenWorkspaceFootprint.bytes,ite_eq_right growth] using room) growth

theorem witness_cursor : (witness ready context dispatch room).frontier.cursor=
    ready.frontier.cursor+TokenWorkspaceFootprint.bytes p time := by
  unfold witness
  split
  · change (TokenGrowthStepMemory.request ready dispatch _ _).nextCursor=_
    rw [TokenGrowthStepMemory.next_cursor]
    simp only [TokenWorkspaceFootprint.bytes,ite_eq_left ‹_›]
  · change (TokenReuseStepMemory.request ready dispatch _ _).nextCursor=_
    rw [TokenReuseStepMemory.request_next_cursor]
    simp only [TokenWorkspaceFootprint.bytes,ite_eq_right ‹_›]

noncomputable def next (supported : time+1≤262144) : Ready p (time+1) parameterCut :=
  (witness ready context dispatch room).next supported

theorem next_cursor (supported : time+1≤262144) :
    (next ready context dispatch room supported).frontier.cursor=
      ready.frontier.cursor+TokenWorkspaceFootprint.bytes p time := witness_cursor ready context dispatch room

theorem next_logical (supported : time+1≤262144) :
    (next ready context dispatch room supported).state.logical=
      ReachedTokenContext.Logical.advance p context.parameters context.primitive context.sampling context.samplingPrimitive
        ready.state.logical (context.angles.value time) (context.angles.ranges time (by omega)) supported
        (context.angles.target time) (context.angles.error time)
        (context.angles.accuracy time (by omega)) (context.angles.base time (by omega)) := rfl

end Inference.Models.Qwen.ReachedTokenConstructedMemory
