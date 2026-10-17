import models.qwen.TokenReadyStepMemory

namespace Inference.Models.Qwen.TokenReuseStepMemory
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
open TokenReadyMemory TokenReadyStepMemory
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

variable {p : Pipeline} {time parameterCut : Nat} (ready : Ready p time parameterCut) (context : Context p)
  (dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages)
  (room : ready.frontier.cursor+TokenNextPlanConstruction.bytes p time≤2^64)
  (reuse : ¬Inference.State.KvAllocation.capacity time<time+1)

def request : TokenNextPlanConstruction.Request (state:=ready.state) ready.parameters where
  cursor := ready.frontier.cursor
  aligned := ready.frontier.aligned
  room := room
  token := ready.token
  parameterCut := parameterCut
  cacheCut := ready.frontier.cursor
  ordered := ⟨ready.ordered,Nat.le_refl _⟩
  parameters := ready.parametersBound
  cachesBelow := ready.cachesBound
  cachesAbove := ready.cachesAbove
  pairwise := ready.pairwise
  dispatch := dispatch
  reuse := reuse

def plan : TokenParameterConstruction.Plan ready.parameters (context.angles.value time) context.sampling :=
  (request ready dispatch room reuse).plan (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish

theorem request_next_cursor : (request ready dispatch room reuse).nextCursor=ready.frontier.cursor+TokenNextPlanConstruction.bytes p time := by
  simp only [TokenNextPlanConstruction.Request.nextCursor,TokenNextPlanConstruction.Request.finalCursor,
    TokenNextPlanConstruction.Request.frontier,request,TokenNextPlanConstruction.bytes,Nat.add_assoc]

def witness : Witness ready context where
  plan := plan ready context dispatch room reuse
  safe := (request ready dispatch room reuse).parameters_safe (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish
  frontier := ⟨(request ready dispatch room reuse).nextCursor,(request ready dispatch room reuse).next_aligned⟩
  ordered := (congrArg (fun cursor => parameterCut≤cursor) (request_next_cursor ready dispatch room reuse)).mpr
    (ready.ordered.trans (Nat.le_add_right _ _))
  tokenBound := (request ready dispatch room reuse).token_bound (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish
  cachesBound := (request ready dispatch room reuse).caches_bound (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish
  cachesAbove := ((request ready dispatch room reuse).caches_geometry (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish).1
  pairwise := ((request ready dispatch room reuse).caches_geometry (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish).2

noncomputable def next (supported : time+1≤262144) : Ready p (time+1) parameterCut :=
  (witness ready context dispatch room reuse).next supported

theorem next_cursor (supported : time+1≤262144) :
    (next ready context dispatch room reuse supported).frontier.cursor=ready.frontier.cursor+TokenNextPlanConstruction.bytes p time :=
  request_next_cursor ready dispatch room reuse
end Inference.Models.Qwen.TokenReuseStepMemory
