import models.qwen.TokenGrowthPlanConstruction
import models.qwen.TokenNextPlanConstruction

-- Bounds for the constructed bump-allocation workspaces. These exclude weights,
-- local threadgroup memory and native allocator overhead. Summing these sizes
-- establishes address-space headroom, not a physical-memory fit or reclamation.
namespace Inference.Models.Qwen.TokenWorkspaceFootprint
open Contracts.Mlx Layers TokenInference Kernels.Attention
set_option maxRecDepth 10000

theorem reuse_stage_bound (layer : ResidualAttention.Layer) (time : Nat) :
    DecodeExistingStepConstruction.stageBytes (.attention layer) time≤13637632 :=
  ResidualAttentionWorkspaceConstruction.footprint layer.mixer.architectureSuffix (time+1)

theorem reuse_count_bound (stages : List DecodeStage.Stage) (time : Nat) :
    DecodeExistingHighWaterConstruction.bytes stages time≤
      (stages.filter (fun stage => !Qwen38TrellisM1Max.isAttention stage)).length*4139488+
      (stages.filter Qwen38TrellisM1Max.isAttention).length*13637632 := by
  induction stages with
  | nil => simp [DecodeExistingHighWaterConstruction.bytes]
  | cons stage rest ih =>
      cases stage with
      | delta layer =>
          simp only [DecodeExistingHighWaterConstruction.bytes,DecodeExistingStepConstruction.stageBytes,
            ResidualDeltaAllocation.bytes,List.filter_cons,Qwen38TrellisM1Max.isAttention,
            Bool.not_false,ite_true,Bool.false_eq_true,ite_false,List.length_cons] at *
          omega
      | attention layer =>
          have bound := reuse_stage_bound layer time
          simp only [DecodeExistingHighWaterConstruction.bytes,List.filter_cons,
            Qwen38TrellisM1Max.isAttention,Bool.not_true,ite_true,Bool.false_eq_true,
            ite_false,List.length_cons] at *
          exact (Nat.add_le_add bound ih).trans (by simp only [Nat.add_mul,Nat.one_mul]; omega)

theorem reuse_bound (p : Pipeline) (time : Nat) :
    TokenNextPlanConstruction.bytes p time≤417419488 := by
  have bound := reuse_count_bound p.graph.stages time
  rw [p.graph.delta_count,p.graph.attention_count] at bound
  unfold TokenNextPlanConstruction.bytes
  omega

theorem growth_bound (p : Pipeline) (time : Nat)
    (growing : State.KvAllocation.capacity time<time+1) (supported : time+1≤262144) :
    TokenGrowthPlanConstruction.bytes p time≤17614065888 := by
  have bound := Qwen38TrellisM1MaxWorkspaceFootprint.graph_bound p.graph time
  have capacity := State.KvGrowthAllocation.supported_footprint growing supported
  unfold TokenGrowthPlanConstruction.bytes
  rw [DecodeHighWaterConstruction.footprint_eq]
  omega

-- The choice is fixed by the token position. It does not test a numerical
-- contract or accept a caller-supplied execution plan.
def bytes (p : Pipeline) (time : Nat) : Nat :=
  if State.KvAllocation.capacity time<time+1 then TokenGrowthPlanConstruction.bytes p time
  else TokenNextPlanConstruction.bytes p time

theorem supported_bound (p : Pipeline) (time : Nat) (supported : time+1≤262144) :
    bytes p time≤17614065888 := by
  unfold bytes
  split
  · exact growth_bound p time ‹_› supported
  · exact (reuse_bound p time).trans (by decide)

theorem aligned (p : Pipeline) (time : Nat) : bytes p time%16=0 := by
  have grow := DecodeHighWaterConstruction.bytes_aligned p.graph.stages time
  have reuse := DecodeExistingHighWaterConstruction.bytes_aligned p.graph.stages time
  unfold bytes TokenGrowthPlanConstruction.bytes TokenNextPlanConstruction.bytes
  split <;> omega

theorem positive (p : Pipeline) (time : Nat) : 0<bytes p time := by
  unfold bytes TokenGrowthPlanConstruction.bytes TokenNextPlanConstruction.bytes
  split <;> omega

end Inference.Models.Qwen.TokenWorkspaceFootprint
