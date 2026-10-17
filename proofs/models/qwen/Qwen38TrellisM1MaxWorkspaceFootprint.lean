import models.qwen.ResidualAttentionHighWater
import models.qwen.Qwen38TrellisM1Max

namespace Inference.Models.Qwen.Qwen38TrellisM1MaxWorkspaceFootprint
open Contracts.Mlx Layers Kernels Kernels.Attention State
set_option maxRecDepth 10000

-- Monotone bump allocation retains every modeled stage workspace. This is a
-- workspace geometry bound, excluding loaded parameters and runtime overhead.
def stageBytes (n : Nat) : DecodeStage.Stage → Nat
  | .delta _ => ResidualDeltaAllocation.bytes
  | .attention layer => ResidualAttentionHighWater.fixedBytes layer n+KvGrowthAllocation.bytes n

def bytes (n : Nat) : List DecodeStage.Stage → Nat
  | [] => 0
  | stage::rest => stageBytes n stage+bytes n rest

theorem attention_stage_bound (layer : ResidualAttention.Layer) (n : Nat) :
    stageBytes n (.attention layer)≤13637632+KvGrowthAllocation.bytes n :=
  Nat.add_le_add_right (ResidualAttentionWorkspaceConstruction.footprint layer.mixer.architectureSuffix (n+1)) _

theorem count_bound (stages : List DecodeStage.Stage) (n : Nat) :
    bytes n stages≤
      (stages.filter (fun stage => !Qwen38TrellisM1Max.isAttention stage)).length*4139488+
      (stages.filter Qwen38TrellisM1Max.isAttention).length*(13637632+KvGrowthAllocation.bytes n) := by
  induction stages with
  | nil => simp [bytes]
  | cons stage rest ih =>
    cases stage with
    | delta layer =>
      simp only [bytes,stageBytes,ResidualDeltaAllocation.bytes,List.filter_cons,Qwen38TrellisM1Max.isAttention,
        Bool.not_false,ite_true,Bool.false_eq_true,ite_false,List.length_cons] at *
      omega
    | attention layer =>
      have bound := attention_stage_bound layer n
      simp only [bytes,List.filter_cons,Qwen38TrellisM1Max.isAttention,Bool.not_true,
        ite_true,Bool.false_eq_true,ite_false,List.length_cons] at *
      exact (Nat.add_le_add bound ih).trans (by simp only [Nat.add_mul,Nat.one_mul]; omega)

theorem graph_bound (graph : Qwen38TrellisM1Max.Graph) (n : Nat) :
    bytes n graph.stages≤48*4139488+16*(13637632+KvGrowthAllocation.bytes n) := by
  simpa only [graph.delta_count,graph.attention_count] using count_bound graph.stages n

theorem first_token_bound (graph : Qwen38TrellisM1Max.Graph) :
    bytes 0 graph.stages≤48*4139488+16*(13637632+2097152) := graph_bound graph 0

theorem first_token_bound_bytes (graph : Qwen38TrellisM1Max.Graph) :
    bytes 0 graph.stages≤450451968 := first_token_bound graph

theorem first_token_headroom (graph : Qwen38TrellisM1Max.Graph) (cursor : Nat)
    (capacity : cursor+450451968≤2^64) : cursor+bytes 0 graph.stages≤2^64 :=
  (Nat.add_le_add_left (first_token_bound_bytes graph) cursor).trans capacity

end Inference.Models.Qwen.Qwen38TrellisM1MaxWorkspaceFootprint
