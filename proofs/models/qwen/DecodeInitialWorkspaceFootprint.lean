import models.qwen.DecodeInitialConstruction
import models.qwen.TokenSequenceWorkspaceFootprint

namespace Inference.Models.Qwen.DecodeInitialWorkspaceFootprint
open Contracts.Mlx Layers TokenInference Kernels.Attention
set_option maxRecDepth 10000

-- Equality of reserved byte counts only. The direct zero/slice-update route
-- and the previous empty-concat route have different intermediate heaps.
theorem stage_bytes_eq (stage : DecodeStage.Stage) :
    DecodeInitialConstruction.stageBytes stage=DecodeHighWaterConstruction.stageBytes stage 0 := by
  cases stage with
  | delta layer => rfl
  | attention layer =>
    dsimp [DecodeInitialConstruction.stageBytes,DecodeHighWaterConstruction.stageBytes,
      AttentionInitialWorkspaceConstruction.bytes,AttentionInitialTailConstruction.extent,
      ResidualAttentionHighWater.fixedBytes,ResidualAttentionWorkspaceConstruction.bytes,
      State.KvGrowthAllocation.bytes,State.KvGrowthAllocation.tensorBytes]
    omega

theorem bytes_eq (stages : List DecodeStage.Stage) :
    DecodeInitialConstruction.bytes stages=DecodeHighWaterConstruction.bytes stages 0 := by
  induction stages with
  | nil => rfl
  | cons stage rest ih => simp only [DecodeInitialConstruction.bytes,DecodeHighWaterConstruction.bytes,stage_bytes_eq,ih]

theorem count_bound (stages : List DecodeStage.Stage) :
    DecodeInitialConstruction.bytes stages≤
      (stages.filter (fun stage => !Qwen38TrellisM1Max.isAttention stage)).length*4139488+
      (stages.filter Qwen38TrellisM1Max.isAttention).length*(13637632+2097152) := by
  rw [bytes_eq,DecodeHighWaterConstruction.footprint_eq]
  exact Qwen38TrellisM1MaxWorkspaceFootprint.count_bound stages 0

theorem graph_bound (graph : Qwen38TrellisM1Max.Graph) :
    DecodeInitialConstruction.bytes graph.stages≤48*4139488+16*(13637632+2097152) := by
  simpa only [graph.delta_count,graph.attention_count] using count_bound graph.stages

theorem graph_bound_bytes (graph : Qwen38TrellisM1Max.Graph) :
    DecodeInitialConstruction.bytes graph.stages≤450451968 := graph_bound graph

theorem first_blocks (arch : Char) : SdpaDispatched.blockCount arch 1≤128 := by
  by_cases single : arch='s'
  · simp [SdpaDispatched.blockCount,SdpaTwoPassDispatch.blocks,SdpaDispatch.qwen,SdpaTwoPassDispatch.defaultBlocks,single]
  · by_cases dual : arch='d'
    · simp [SdpaDispatched.blockCount,SdpaTwoPassDispatch.blocks,SdpaDispatch.qwen,SdpaTwoPassDispatch.defaultBlocks,dual]
    · simp [SdpaDispatched.blockCount,SdpaTwoPassDispatch.blocks,SdpaDispatch.qwen,SdpaTwoPassDispatch.defaultBlocks,single,dual]

theorem first_blocks_m1max : SdpaDispatched.blockCount 's' 1=64 := rfl

theorem attention_bound (layer : ResidualAttention.Layer) :
    DecodeInitialConstruction.stageBytes (.attention layer)≤4552704 := by
  have bound := first_blocks layer.mixer.architectureSuffix
  dsimp [DecodeInitialConstruction.stageBytes,AttentionInitialWorkspaceConstruction.bytes,
    AttentionInitialTailConstruction.extent,AttentionTailWorkspaceConstruction.bytes,SdpaWorkspace.bytes]
  omega

theorem tight_count_bound (stages : List DecodeStage.Stage) :
    DecodeInitialConstruction.bytes stages≤
      (stages.filter (fun stage => !Qwen38TrellisM1Max.isAttention stage)).length*4139488+
      (stages.filter Qwen38TrellisM1Max.isAttention).length*4552704 := by
  induction stages with
  | nil => simp [DecodeInitialConstruction.bytes]
  | cons stage rest ih =>
    cases stage with
    | delta layer =>
      simp only [DecodeInitialConstruction.bytes,DecodeInitialConstruction.stageBytes,ResidualDeltaAllocation.bytes,
        List.filter_cons,Qwen38TrellisM1Max.isAttention,Bool.not_false,ite_true,Bool.false_eq_true,ite_false,List.length_cons] at *
      omega
    | attention layer =>
      have bound := attention_bound layer
      simp only [DecodeInitialConstruction.bytes,List.filter_cons,Qwen38TrellisM1Max.isAttention,
        Bool.not_true,ite_true,Bool.false_eq_true,ite_false,List.length_cons] at *
      exact (Nat.add_le_add bound ih).trans (by simp only [Nat.add_mul,Nat.one_mul]; omega)

theorem tight_graph_bound (graph : Qwen38TrellisM1Max.Graph) :
    DecodeInitialConstruction.bytes graph.stages≤271538688 := by
  have bound := tight_count_bound graph.stages
  rw [graph.delta_count,graph.attention_count] at bound
  exact bound

-- This expression is definitionally TokenDirectInitialConstruction.bytes p;
-- stating the formula here keeps this arithmetic independent of that large
-- execution constructor. Initialization reserves 153944080 bytes separately.
theorem token_bound (p : Pipeline) :
    13120+DecodeInitialConstruction.bytes p.graph.stages+506880+1952≤272060640 := by
  have bound := tight_graph_bound p.graph
  omega

theorem initialized_bound (p : Pipeline) :
    153944080+(13120+DecodeInitialConstruction.bytes p.graph.stages+506880+1952)≤426004720 := Nat.add_le_add_left (token_bound p) 153944080

-- 262144 modeled token steps: the direct first step plus 262143 constructed
-- growth/reuse steps. These sums deliberately retain old bump allocations;
-- they are not physical peak-memory estimates or reclamation guarantees.
theorem full_bound (p : Pipeline) :
    (13120+DecodeInitialConstruction.bytes p.graph.stages+506880+1952)+
      TokenConstructedSequenceMemory.bytes p 1 262143≤127016038170624 := by
  have first := token_bound p
  have rest := TokenSequenceWorkspaceFootprint.full_bound p
  omega

theorem initialized_full_bound (p : Pipeline) :
    153944080+(13120+DecodeInitialConstruction.bytes p.graph.stages+506880+1952)+
      TokenConstructedSequenceMemory.bytes p 1 262143≤127016192114704 := by
  simpa only [Nat.add_assoc] using Nat.add_le_add_left (full_bound p) 153944080

theorem token_headroom (p : Pipeline) (cursor : Nat) (capacity : cursor+272060640≤2^64) :
    cursor+(13120+DecodeInitialConstruction.bytes p.graph.stages+506880+1952)≤2^64 :=
  (Nat.add_le_add_left (token_bound p) cursor).trans capacity

theorem initialized_headroom (p : Pipeline) (cursor : Nat) (capacity : cursor+426004720≤2^64) :
    cursor+153944080+(13120+DecodeInitialConstruction.bytes p.graph.stages+506880+1952)≤2^64 := by
  simpa only [Nat.add_assoc] using (Nat.add_le_add_left (initialized_bound p) cursor).trans capacity

theorem full_headroom (p : Pipeline) (cursor : Nat) (capacity : cursor+127016192114704≤2^64) :
    cursor+153944080+(13120+DecodeInitialConstruction.bytes p.graph.stages+506880+1952)+
      TokenConstructedSequenceMemory.bytes p 1 262143≤2^64 := by
  simpa only [Nat.add_assoc] using (Nat.add_le_add_left (initialized_full_bound p) cursor).trans capacity

end Inference.Models.Qwen.DecodeInitialWorkspaceFootprint
