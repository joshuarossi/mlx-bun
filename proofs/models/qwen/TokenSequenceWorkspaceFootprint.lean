import models.qwen.TokenConstructedSequenceMemory

-- Count the static cache-growth positions to bound the finite constructor's
-- cumulative address-space consumption. This allocator retains prior scratch
-- regions; this is deliberately not a claim about peak physical RAM use.
namespace Inference.Models.Qwen.TokenSequenceWorkspaceFootprint
open Contracts.Mlx TokenInference
set_option maxRecDepth 10000

def growthCount (time : Nat) : Nat → Nat
  | 0 => 0
  | steps+1 => growthCount time steps+
      if State.KvAllocation.capacity (time+steps)<time+steps+1 then 1 else 0

theorem growth_count (time steps : Nat) :
    growthCount time steps+(time+255)/256=(time+steps+255)/256 := by
  induction steps with
  | zero => simp only [growthCount,Nat.zero_add,Nat.add_zero]
  | succ steps ih =>
      by_cases growing : State.KvAllocation.capacity (time+steps)<time+steps+1
      · have atBoundary := (State.KvAllocation.growth_iff (time+steps)).mp growing
        simp only [growthCount,ite_eq_left growing]
        omega
      · have away : (time+steps)%256≠0 := by
          intro equal
          exact growing ((State.KvAllocation.growth_iff (time+steps)).mpr equal)
        simp only [growthCount,ite_eq_right growing]
        omega

theorem growth_count_eq (time steps : Nat) :
    growthCount time steps=(time+steps+255)/256-(time+255)/256 := by
  have := growth_count time steps
  omega

theorem step_bound (p : Pipeline) (time : Nat) (supported : time+1≤262144) :
    TokenWorkspaceFootprint.bytes p time≤417419488+
      if State.KvAllocation.capacity time<time+1 then 17196646400 else 0 := by
  by_cases growing : State.KvAllocation.capacity time<time+1
  · simpa only [TokenWorkspaceFootprint.bytes,ite_eq_left growing] using
      TokenWorkspaceFootprint.growth_bound p time growing supported
  · simpa only [TokenWorkspaceFootprint.bytes,ite_eq_right growing,Nat.add_zero] using
      TokenWorkspaceFootprint.reuse_bound p time

theorem cumulative_bound (p : Pipeline) (time steps : Nat) (supported : time+steps≤262144) :
    TokenConstructedSequenceMemory.bytes p time steps≤steps*417419488+growthCount time steps*17196646400 := by
  induction steps with
  | zero => simp only [TokenConstructedSequenceMemory.bytes,growthCount,Nat.zero_mul,Nat.zero_add,Nat.le_refl]
  | succ steps ih =>
      have previous := ih (by omega)
      have next := step_bound p (time+steps) (by omega)
      by_cases growing : State.KvAllocation.capacity (time+steps)<time+steps+1
      · simp only [TokenConstructedSequenceMemory.bytes,growthCount,ite_eq_left growing,
          Nat.succ_mul] at *
        omega
      · simp only [TokenConstructedSequenceMemory.bytes,growthCount,ite_eq_right growing,
          Nat.succ_mul,Nat.add_zero] at *
        omega

theorem boundary_bound (p : Pipeline) (time steps : Nat) (supported : time+steps≤262144) :
    TokenConstructedSequenceMemory.bytes p time steps≤steps*417419488+
      ((time+steps+255)/256-(time+255)/256)*17196646400 := by
  simpa only [growth_count_eq] using cumulative_bound p time steps supported

theorem full_growth_count : growthCount 1 262143=1023 := by
  rw [growth_count_eq]

theorem full_bound (p : Pipeline) :
    TokenConstructedSequenceMemory.bytes p 1 262143≤262143*417419488+1023*17196646400 := by
  simpa only [full_growth_count] using cumulative_bound p 1 262143 (by decide)

end Inference.Models.Qwen.TokenSequenceWorkspaceFootprint
