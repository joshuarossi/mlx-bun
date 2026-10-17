import models.qwen.TokenGrowthPlanConstruction
import models.qwen.TokenReadyStepMemory

-- Construct the next complete token, including cache growth, from a reached
-- heap. The graph/token plan and all next-state attachments are derived here.
namespace Inference.Models.Qwen.TokenGrowthStepMemory
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
open TokenReadyMemory
open TokenBoundaryHighWater (Before)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

variable {p : Pipeline} {time parameterCut : Nat}
  (ready : Ready p time parameterCut)
  (dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages)
  (growth : State.KvAllocation.capacity time<time+1)
  (room : ready.frontier.cursor+TokenGrowthPlanConstruction.bytes p time≤2^64)

def request : TokenGrowthPlanConstruction.Request ready.parameters where
  cursor := ready.frontier.cursor
  aligned := ready.frontier.aligned
  room := room
  token := ready.token
  parameters := ready.parameters.protected_mono
    (fun _ _ inside => ResidualDeltaHighWater.before_mono ready.ordered inside) ready.parametersBound
  caches := ready.cachesBound
  dispatch := dispatch
  growth := growth

theorem request_cursor : (request ready dispatch growth room).cursor=ready.frontier.cursor := rfl

theorem request_frontier : (request ready dispatch growth room).frontier.cursor=ready.frontier.cursor+13120 := rfl

theorem next_cursor : (request ready dispatch growth room).nextCursor=
    ready.frontier.cursor+TokenGrowthPlanConstruction.bytes p time := by
  unfold TokenGrowthPlanConstruction.Request.nextCursor TokenGrowthPlanConstruction.Request.finalCursor
    TokenGrowthPlanConstruction.Request.frontier TokenGrowthPlanConstruction.bytes
  simp only [request_cursor,Nat.add_assoc]

def witness (context : Context p) : TokenReadyStepMemory.Witness ready context where
  plan := (request ready dispatch growth room).plan (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish
  safe := (request ready dispatch growth room).parameters_safe (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish
  frontier := ⟨(request ready dispatch growth room).nextCursor,(request ready dispatch growth room).next_aligned⟩
  ordered := (congrArg (fun cursor => parameterCut≤cursor) (next_cursor ready dispatch growth room)).mpr
    (ready.ordered.trans (Nat.le_add_right _ _))
  tokenBound := (request ready dispatch growth room).token_bound (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish
  cachesBound := (request ready dispatch growth room).caches_bound (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish
  cachesAbove := ResidualDeltaHighWater.cacheProtected_mono _ _ _
    (fun _ _ lower => (ready.ordered.trans (Nat.le_add_right _ 13120)).trans lower)
    ((request ready dispatch growth room).caches_geometry (context.angles.value time) context.sampling
      (context.locals time).lse (context.locals time).tile (context.locals time).finish).1
  pairwise := ((request ready dispatch growth room).caches_geometry (context.angles.value time) context.sampling
    (context.locals time).lse (context.locals time).tile (context.locals time).finish).2

theorem witness_cursor (context : Context p) : (witness ready dispatch growth room context).frontier.cursor=
    ready.frontier.cursor+TokenGrowthPlanConstruction.bytes p time := next_cursor ready dispatch growth room

noncomputable def next (context : Context p) (supported : time+1≤262144) : Ready p (time+1) parameterCut :=
  (witness ready dispatch growth room context).next supported

theorem next_frontier (context : Context p) (supported : time+1≤262144) :
    (next ready dispatch growth room context supported).frontier.cursor=
      ready.frontier.cursor+TokenGrowthPlanConstruction.bytes p time := witness_cursor ready dispatch growth room context

theorem parameter_regions (context : Context p) (supported : time+1≤262144) (property : Nat → Nat → Prop) :
    (next ready dispatch growth room context supported).parameters.Protected property ↔ ready.parameters.Protected property :=
  (witness ready dispatch growth room context).parameters_protected supported property

theorem parameter_bytes (context : Context p) (supported : time+1≤262144)
    (region : TokenParameterConstruction.Region ready.parameters base size) (offset : Nat) (bound : offset<size) :
    (next ready dispatch growth room context supported).state.index.bytes (base+offset)=ready.state.index.bytes (base+offset) :=
  (witness ready dispatch growth room context).other_region supported region offset bound

end Inference.Models.Qwen.TokenGrowthStepMemory
