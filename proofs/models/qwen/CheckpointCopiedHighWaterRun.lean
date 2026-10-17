import models.qwen.CheckpointCopiedHighWaterState
import models.qwen.NativeCopiedAllocationBudget

namespace Inference.Models.Qwen.CheckpointCopiedHighWaterRun
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
open CheckpointCopiedHighWaterState (State)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

structure Context (p : Pipeline) where
  sampling : LogSumExpRanges.Platform
  encoded : CheckpointDictionaryBinding.Encoding
  binding : CheckpointDictionaryBinding.Bindings p encoded
  selected : ReachedTokenContext.Primitive.Selections p.graph
  other : ReachedTokenContext.Primitive.Other p.graph
  samplingPrimitive : LogSumExpRanges.Primitives sampling
  dispatches : ∀ n, NativeCopiedHighWater.Dispatches p n
  lseLocal : Nat → ByteMemory.Bytes
  tileLocal : Nat → Fin 243 → ByteMemory.Bytes
  finishLocal : Nat → ByteMemory.Bytes

structure Result {p : Pipeline} (initial : State p 0) (n : Nat) where
  state : State p n
  frontier : state.frontier.cursor=initial.frontier.cursor+NativeCopiedAllocationBudget.cumulative p n

variable {p : Pipeline} (ctx : Context p) (initial : State p 0)
  (room : initial.frontier.cursor+NativeCopiedAllocationBudget.budget≤2^64)

include room in
theorem stepRoom {n : Nat} (previous : Result initial n) (supported : n+1≤262144) :
    previous.state.frontier.cursor+NativeCopiedHighWater.bytes p n≤2^64 := by
  rw [previous.frontier]
  exact NativeCopiedAllocationBudget.prefix_room p supported room

def stepPlan {n : Nat} (previous : Result initial n) (supported : n+1≤262144) :=
  CheckpointCopiedHighWaterState.plan previous.state (stepRoom initial room previous supported) (ctx.dispatches n)
    ctx.sampling (ctx.lseLocal n) (ctx.tileLocal n) (ctx.finishLocal n)

theorem stepSafe {n : Nat} (previous : Result initial n) (supported : n+1≤262144) :
    NativeCopiedTokenConstruction.Safe (stepPlan ctx initial room previous supported) :=
  CheckpointCopiedHighWaterState.safe previous.state (stepRoom initial room previous supported) (ctx.dispatches n)
    ctx.sampling (ctx.lseLocal n) (ctx.tileLocal n) (ctx.finishLocal n)

noncomputable def next {n : Nat} (previous : Result initial n) (supported : n+1≤262144) : Result initial (n+1) where
  state := CheckpointCopiedHighWaterState.advance previous.state (stepRoom initial room previous supported) (ctx.dispatches n)
    ctx.sampling (ctx.lseLocal n) (ctx.tileLocal n) (ctx.finishLocal n)
    ctx.encoded ctx.binding ctx.selected ctx.other ctx.samplingPrimitive supported
  frontier := by
    rw [CheckpointCopiedHighWaterState.advance_frontier,previous.frontier,NativeCopiedAllocationBudget.cumulative_succ,Nat.add_assoc]

-- The recursion supplies no execution-plan oracle. Each next plan is built
-- from the preceding concrete state and one initial address-space budget.
noncomputable def run : (n : Nat) → n≤262144 → Result initial n
  | 0, _ => ⟨initial,by simp only [NativeCopiedAllocationBudget.cumulative_zero,Nat.add_zero]⟩
  | n+1, supported => next ctx initial room (run n (by omega)) supported

theorem run_zero (supported : 0≤262144) : (run ctx initial room 0 supported).state=initial := rfl

theorem run_succ (n : Nat) (supported : n+1≤262144) :
    run ctx initial room (n+1) supported=next ctx initial room (run ctx initial room n (by omega)) supported := rfl

theorem frontier (n : Nat) (supported : n≤262144) :
    (run ctx initial room n supported).state.frontier.cursor=
      initial.frontier.cursor+NativeCopiedAllocationBudget.cumulative p n :=
  (run ctx initial room n supported).frontier

theorem parameters_preserved (n : Nat) (supported : n≤262144) (property : Nat → Nat → Prop) :
    (run ctx initial room n supported).state.parameters.Protected property ↔ initial.parameters.Protected property := by
  induction n with
  | zero => exact Iff.rfl
  | succ n ih =>
    exact (CheckpointCopiedHighWaterState.advance_parameters _ _ _ _ _ _ _ _ _ _ _ _ _ property).trans (ih (by omega))

theorem frame (n : Nat) (supported : n≤262144)
    (region : TokenParameterConstruction.Region initial.parameters base size) (offset : Nat) (inside : offset<size) :
    (run ctx initial room n supported).state.memory.index.bytes (base+offset)=initial.memory.index.bytes (base+offset) := by
  induction n with
  | zero => rfl
  | succ n ih =>
    have currentRegion : TokenParameterConstruction.Region (run ctx initial room n (by omega)).state.parameters base size :=
      fun property kept => region property ((parameters_preserved ctx initial room n (by omega) property).mp kept)
    exact (CheckpointCopiedHighWaterState.advance_frame _ _ _ _ _ _ _ _ _ _ _ _ _ currentRegion offset inside).trans (ih (by omega))

end Inference.Models.Qwen.CheckpointCopiedHighWaterRun
