import models.qwen.TokenGrowthStepMemory
import models.qwen.TokenReuseStepMemory
import models.qwen.TokenWorkspaceFootprint

-- Token position determines the static cache-growth schedule. Both cases
-- construct the complete next token from the reached heap and original weights.
namespace Inference.Models.Qwen.TokenConstructedStepMemory
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
open TokenReadyMemory TokenReadyStepMemory
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

variable {p : Pipeline} {time parameterCut : Nat} (ready : Ready p time parameterCut)
  (context : Context p) (dispatch : DecodeHighWaterConstruction.Dispatches p.graph.stages)
  (room : ready.frontier.cursor+TokenWorkspaceFootprint.bytes p time≤2^64)

def witness : Witness ready context :=
  if growth : State.KvAllocation.capacity time<time+1 then
    TokenGrowthStepMemory.witness ready dispatch growth
      (by simpa only [TokenWorkspaceFootprint.bytes,ite_eq_left growth] using room) context
  else
    TokenReuseStepMemory.witness ready context dispatch
      (by simpa only [TokenWorkspaceFootprint.bytes,ite_eq_right growth] using room) growth

theorem witness_cursor : (witness ready context dispatch room).frontier.cursor=
    ready.frontier.cursor+TokenWorkspaceFootprint.bytes p time := by
  unfold witness
  split
  · rw [TokenGrowthStepMemory.witness_cursor]
    simp only [TokenWorkspaceFootprint.bytes,ite_eq_left ‹_›]
  · change (TokenReuseStepMemory.request ready dispatch _ _).nextCursor=_
    rw [TokenReuseStepMemory.request_next_cursor]
    simp only [TokenWorkspaceFootprint.bytes,ite_eq_right ‹_›]

noncomputable def next (supported : time+1≤262144) : Ready p (time+1) parameterCut :=
  (witness ready context dispatch room).next supported

theorem next_cursor (supported : time+1≤262144) :
    (next ready context dispatch room supported).frontier.cursor=
      ready.frontier.cursor+TokenWorkspaceFootprint.bytes p time := witness_cursor ready context dispatch room

theorem parameter_regions (supported : time+1≤262144) (property : Nat → Nat → Prop) :
    (next ready context dispatch room supported).parameters.Protected property ↔ ready.parameters.Protected property :=
  (witness ready context dispatch room).parameters_protected supported property

theorem parameter_bytes (supported : time+1≤262144)
    (region : TokenParameterConstruction.Region ready.parameters base size) (offset : Nat) (bound : offset<size) :
    (next ready context dispatch room supported).state.index.bytes (base+offset)=ready.state.index.bytes (base+offset) :=
  (witness ready context dispatch room).other_region supported region offset bound

end Inference.Models.Qwen.TokenConstructedStepMemory
