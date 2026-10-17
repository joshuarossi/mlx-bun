import models.qwen.NativeCopiedHighWater
namespace Inference.Models.Qwen.NativeCopiedAllocationBudget
open Contracts.Mlx Layers DecodeStage TokenInference Kernels.Attention State
set_option maxRecDepth 10000

-- This bounds cumulative fresh address reservations. It makes no claim about
-- physical RAM, allocator reuse, resident memory, or a physical peak.
def perToken : Nat := 2^39
def budget : Nat := 2^57

theorem capacity_bound {n : Nat} (supported : n≤262144) : KvAllocation.capacity n≤262144 := by
  unfold KvAllocation.capacity
  omega

theorem read_bound {n : Nat} (supported : n+1≤262144) : CapacityCopiedWorkspace.readBytes n≤2149576704 := by
  have cap := capacity_bound supported
  unfold CapacityCopiedWorkspace.readBytes
  split <;> dsimp [KvRegions.bytes,KvGrowthAllocation.bytes,KvGrowthAllocation.tensorBytes] <;> omega

theorem tail_bound (arch : Char) (steps : Nat) : CopiedAttentionTailArena.bytes arch steps≤12826624 := by
  have blocks := SdpaDispatchedDevice.bounded_blocks arch steps
  dsimp [CopiedAttentionTailArena.bytes,SdpaWorkspace.bytes,AttentionTailAllocation.bytes]
  omega

theorem initial_stage_bound (stage : Stage) : InitialCopiedWorkspace.stageBytes stage≤2^32 := by
  cases stage with
  | delta => simp only [InitialCopiedWorkspace.stageBytes,ResidualDeltaAllocation.bytes]; omega
  | attention layer =>
    have tail := tail_bound layer.mixer.architectureSuffix 1
    dsimp [InitialCopiedWorkspace.stageBytes,CopiedAttentionEntryAllocation.bytes,CopiedAttentionInitialReadAllocation.bytes,
      KvRegions.bytes,KvAllocation.capacity,ResidualMlpAllocation.bytes]
    omega

theorem capacity_stage_bound {n : Nat} (supported : n+1≤262144) (stage : Stage) : CapacityCopiedWorkspace.stageBytes n stage≤2^32 := by
  cases stage with
  | delta => simp only [CapacityCopiedWorkspace.stageBytes,ResidualDeltaAllocation.bytes]; omega
  | attention layer =>
    have tail := tail_bound layer.mixer.architectureSuffix (n+1)
    have read := read_bound supported
    dsimp [CapacityCopiedWorkspace.stageBytes,CopiedAttentionEntryAllocation.bytes,ResidualMlpAllocation.bytes]
    omega

theorem initial_chain_bound (stages : List Stage) : InitialCopiedWorkspace.bytes stages≤stages.length*2^32 := by
  induction stages with
  | nil => rfl
  | cons stage rest ih =>
    have first := initial_stage_bound stage
    simp only [InitialCopiedWorkspace.bytes,List.length_cons,Nat.succ_mul]
    omega

theorem capacity_chain_bound {n : Nat} (supported : n+1≤262144) (stages : List Stage) :
    CapacityCopiedWorkspace.bytes n stages≤stages.length*2^32 := by
  induction stages with
  | nil => rfl
  | cons stage rest ih =>
    have first := capacity_stage_bound supported stage
    simp only [CapacityCopiedWorkspace.bytes,List.length_cons,Nat.succ_mul]
    omega

theorem token_bound (p : Pipeline) {time : Nat} (supported : time+1≤262144) : NativeCopiedHighWater.bytes p time≤perToken := by
  cases time with
  | zero =>
    have chain := initial_chain_bound p.graph.stages
    rw [Qwen38TrellisM1Max.Graph.layer_count] at chain
    change 13120+InitialCopiedWorkspace.bytes p.graph.stages+FinalProjectionSamplerAllocation.bytes≤perToken
    dsimp [perToken,FinalProjectionSamplerAllocation.bytes]
    omega
  | succ n =>
    have chain := capacity_chain_bound supported p.graph.stages
    rw [Qwen38TrellisM1Max.Graph.layer_count] at chain
    change 13120+CapacityCopiedWorkspace.bytes (n+1) p.graph.stages+FinalProjectionSamplerAllocation.bytes≤perToken
    dsimp [perToken,FinalProjectionSamplerAllocation.bytes]
    omega

-- Count is the number of actual indexed token-constructor reservations.
def cumulative (p : Pipeline) : Nat → Nat
  | 0 => 0
  | count+1 => cumulative p count+NativeCopiedHighWater.bytes p count

theorem cumulative_zero (p : Pipeline) : cumulative p 0=0 := rfl
theorem cumulative_succ (p : Pipeline) (count : Nat) :
    cumulative p (count+1)=cumulative p count+NativeCopiedHighWater.bytes p count := rfl

theorem cumulative_mono (p : Pipeline) {first second : Nat} (ordered : first≤second) :
    cumulative p first≤cumulative p second := by
  induction ordered with
  | refl => exact Nat.le_refl _
  | step ordered ih => exact ih.trans (Nat.le_add_right _ _)

theorem cumulative_linear (p : Pipeline) {count : Nat} (supported : count≤262144) :
    cumulative p count≤count*perToken := by
  induction count with
  | zero => rfl
  | succ count ih =>
    have previous := ih (by omega)
    have current := token_bound p supported
    simp only [cumulative,Nat.succ_mul]
    omega

theorem cumulative_bound (p : Pipeline) {count : Nat} (supported : count≤262144) : cumulative p count≤budget := by
  have bound := cumulative_linear p supported
  dsimp [perToken,budget] at *
  omega

theorem prefix_room (p : Pipeline) {start count : Nat} (supported : count+1≤262144)
    (room : start+budget≤2^64) : start+cumulative p count+NativeCopiedHighWater.bytes p count≤2^64 := by
  have bound := cumulative_bound p supported
  rw [cumulative_succ] at bound
  omega

end Inference.Models.Qwen.NativeCopiedAllocationBudget
