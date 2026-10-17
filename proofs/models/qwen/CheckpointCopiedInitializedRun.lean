import models.qwen.CheckpointCopiedHighWaterSeed
import models.qwen.CheckpointCopiedHighWaterRun
namespace Inference.Models.Qwen.CheckpointCopiedInitializedRun
open Contracts.Mlx Layers TokenInference Kernels.Attention
open ResidualDeltaHighWater (Frontier Before)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

-- This is a cumulative fresh-address budget, not a physical memory promise.
def bytes : Nat := TokenInitializationHighWater.bytes+NativeCopiedAllocationBudget.budget

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes}
  (original : TokenParameterMemory.Storage p initialHeap) (token : Fin 248320) (frontier : Frontier)
  (room : frontier.cursor+bytes≤2^64) (parameters : original.Protected (Before frontier.cursor))

include room in
private theorem seedRoom : frontier.cursor+InitialCopiedSequenceSeed.bytes p≤2^64 := by
  have first := NativeCopiedAllocationBudget.token_bound p (time:=0) (by decide)
  have budgets : NativeCopiedAllocationBudget.perToken≤NativeCopiedAllocationBudget.budget := by decide +kernel
  change InitialCopiedTokenHighWater.bytes p≤NativeCopiedAllocationBudget.perToken at first
  have total := room
  dsimp only [InitialCopiedSequenceSeed.bytes,bytes] at *
  omega

def initial : CheckpointCopiedHighWaterState.State p 0 :=
  CheckpointCopiedHighWaterSeed.seed original token frontier (seedRoom frontier room) parameters

include room in
theorem runRoom : (initial original token frontier room parameters).frontier.cursor+NativeCopiedAllocationBudget.budget≤2^64 := by
  change frontier.cursor+TokenInitializationHighWater.bytes+NativeCopiedAllocationBudget.budget≤2^64
  simpa only [bytes,Nat.add_assoc] using room

variable (ctx : CheckpointCopiedHighWaterRun.Context p)

noncomputable def run (n : Nat) (supported : n≤262144) :
    CheckpointCopiedHighWaterRun.Result (initial original token frontier room parameters) n :=
  CheckpointCopiedHighWaterRun.run ctx (initial original token frontier room parameters)
    (runRoom original token frontier room parameters) n supported

noncomputable def state (n : Nat) (supported : n≤262144) : CheckpointCopiedHighWaterState.State p n :=
  (run original token frontier room parameters ctx n supported).state

theorem run_zero (supported : 0≤262144) :
    state original token frontier room parameters ctx 0 supported=initial original token frontier room parameters := rfl

theorem frontier_eq (n : Nat) (supported : n≤262144) :
    (state original token frontier room parameters ctx n supported).frontier.cursor=
      frontier.cursor+TokenInitializationHighWater.bytes+NativeCopiedAllocationBudget.cumulative p n :=
  CheckpointCopiedHighWaterRun.frontier ctx (initial original token frontier room parameters)
    (runRoom original token frontier room parameters) n supported

theorem parameters_preserved (n : Nat) (supported : n≤262144) (property : Nat → Nat → Prop) :
    (state original token frontier room parameters ctx n supported).parameters.Protected property ↔ original.Protected property :=
  (CheckpointCopiedHighWaterRun.parameters_preserved ctx (initial original token frontier room parameters)
    (runRoom original token frontier room parameters) n supported property).trans
      (CheckpointCopiedHighWaterSeed.original_parameters original token frontier (seedRoom frontier room) parameters property)

-- Each original parameter span keeps its original bytes across both actual
-- initialization and every subsequent constructed source execution.
theorem frame (n : Nat) (supported : n≤262144)
    (region : TokenParameterConstruction.Region original base size) (offset : Nat) (inside : offset<size) :
    (state original token frontier room parameters ctx n supported).memory.index.bytes (base+offset)=initialHeap (base+offset) := by
  have initialRegion : TokenParameterConstruction.Region (initial original token frontier room parameters).parameters base size :=
    fun property kept => region property
      ((CheckpointCopiedHighWaterSeed.original_parameters original token frontier (seedRoom frontier room) parameters property).mp kept)
  exact (CheckpointCopiedHighWaterRun.frame ctx (initial original token frontier room parameters)
    (runRoom original token frontier room parameters) n supported initialRegion offset inside).trans
      (region _ (CheckpointCopiedHighWaterSeed.original_bytes original token frontier (seedRoom frontier room) parameters) offset inside)

theorem initial_token : (initial original token frontier room parameters).memory.index.read=token.val :=
  CheckpointCopiedHighWaterSeed.token_read original token frontier (seedRoom frontier room) parameters

end Inference.Models.Qwen.CheckpointCopiedInitializedRun
