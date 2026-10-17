import models.qwen.CopiedScalarInitialization
import models.qwen.CheckpointCopiedHighWaterRunFrame

namespace Inference.Models.Qwen.CopiedScalarRunSources
open Contracts.Mlx Layers TokenInference Kernels.Attention
open ResidualDeltaHighWater (Frontier Before)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes}
  (original : TokenParameterMemory.Storage p initialHeap) (token : Fin 248320) (frontier : Frontier)
  (room : frontier.cursor+CopiedScalarInitialization.bytes≤2^64)
  (parameters : original.Protected (Before frontier.cursor))
  (ctx : CheckpointCopiedHighWaterRun.Context p)

private theorem initial_before {base size : Nat} (below : base+size≤frontier.cursor+16) :
    Before (CopiedScalarInitialization.initial original token frontier room parameters).frontier.cursor base size := by
  change base+size≤frontier.cursor+16+TokenInitializationHighWater.bytes
  omega

theorem frame {base size : Nat} (below : base+size≤frontier.cursor+16)
    (n : Nat) (supported : n≤262144) (offset : Nat) (inside : offset<size) :
    (CopiedScalarInitialization.run original token frontier room parameters ctx n supported).state.memory.index.bytes (base+offset)=
      (CopiedScalarInitialization.sources (p:=p) (initialHeap:=initialHeap) token frontier room).history.bytes (base+offset) := by
  exact (CheckpointCopiedHighWaterRunFrame.frame_for_arbitrary_initial_span ctx
    (CopiedScalarInitialization.initial original token frontier room parameters)
    (CheckpointCopiedInitializedRun.runRoom
      (CopiedScalarInitialization.originalAfter original frontier room parameters) token
      (CopiedScalarInitialization.nextFrontier frontier)
      (CopiedScalarInitialization.remainingRoom frontier room)
      (CopiedScalarInitialization.parametersBefore original frontier room parameters)) n supported
    (initial_before original token frontier room parameters below) offset inside).trans
      (congrFun (CopiedScalarInitialization.source_heap original token frontier room parameters).symm _)

noncomputable def zero (n : Nat) (supported : n≤262144) : InitialCacheParsedSourceConstruction.Sources :=
  (CopiedScalarInitialization.sources (p:=p) (initialHeap:=initialHeap) token frontier room).reframe
    (CopiedScalarInitialization.run original token frontier room parameters ctx n supported).state.memory.index.bytes
    (by
      intro offset inside
      apply frame original token frontier room parameters ctx _ n supported offset inside
      rw [CopiedScalarInitialization.history_base]
      omega)
    (by
      intro offset inside
      apply frame original token frontier room parameters ctx _ n supported offset inside
      rw [CopiedScalarInitialization.recurrent_base]
      omega)

theorem history_base (n : Nat) (supported : n≤262144) :
    (zero original token frontier room parameters ctx n supported).history.base=frontier.cursor :=
  (InitialCacheParsedSourceConstruction.Sources.reframe_history_base _ _ _ _).trans
    (CopiedScalarInitialization.history_base token frontier room)

theorem recurrent_base (n : Nat) (supported : n≤262144) :
    (zero original token frontier room parameters ctx n supported).recurrent.base=frontier.cursor+4 :=
  (InitialCacheParsedSourceConstruction.Sources.reframe_recurrent_base _ _ _ _).trans
    (CopiedScalarInitialization.recurrent_base token frontier room)

theorem history_heap (n : Nat) (supported : n≤262144) :
    (zero original token frontier room parameters ctx n supported).history.bytes=
      (CopiedScalarInitialization.run original token frontier room parameters ctx n supported).state.memory.index.bytes := rfl

theorem recurrent_heap (n : Nat) (supported : n≤262144) :
    (zero original token frontier room parameters ctx n supported).recurrent.bytes=
      (CopiedScalarInitialization.run original token frontier room parameters ctx n supported).state.memory.index.bytes := rfl

theorem raw_zero (n : Nat) (supported : n≤262144) :
    ByteMemory.load32 (CopiedScalarInitialization.run original token frontier room parameters ctx n supported).state.memory.index.bytes
      (frontier.cursor+4)=0 := by
  have raw := (zero original token frontier room parameters ctx n supported).raw
  rw [history_heap,recurrent_base] at raw
  exact raw

theorem scalar_before (n : Nat) (supported : n≤262144) :
    Before (CopiedScalarInitialization.run original token frontier room parameters ctx n supported).state.frontier.cursor frontier.cursor 2 ∧
    Before (CopiedScalarInitialization.run original token frontier room parameters ctx n supported).state.frontier.cursor (frontier.cursor+4) 4 := by
  have location := CheckpointCopiedInitializedRun.frontier_eq
    (CopiedScalarInitialization.originalAfter original frontier room parameters) token
    (CopiedScalarInitialization.nextFrontier frontier) (CopiedScalarInitialization.remainingRoom frontier room)
    (CopiedScalarInitialization.parametersBefore original frontier room parameters) ctx n supported
  change (CopiedScalarInitialization.run original token frontier room parameters ctx n supported).state.frontier.cursor=frontier.cursor+16+TokenInitializationHighWater.bytes+NativeCopiedAllocationBudget.cumulative p n at location
  constructor <;> change _≤_ <;> rw [location] <;> omega

end Inference.Models.Qwen.CopiedScalarRunSources
