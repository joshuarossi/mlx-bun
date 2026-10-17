import models.qwen.NativeCopiedHighWaterFrame
import models.qwen.CheckpointCopiedHighWaterRun
namespace Inference.Models.Qwen.CheckpointCopiedHighWaterRunFrame
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
open ResidualDeltaHighWater (Before)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  NativeCopiedTokenConstruction.step NativeCopiedTokenRoute.final
  FinalProjectionSamplerSource.Execution.sampler

section Step
variable {p : Pipeline} {n : Nat} (before : CheckpointCopiedHighWaterState.State p n)
  (room : before.frontier.cursor+NativeCopiedHighWater.bytes p n≤2^64)
  (dispatches : NativeCopiedHighWater.Dispatches p n)
  (sampling : LogSumExpRanges.Platform)
  (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)
  (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (selected : ReachedTokenContext.Primitive.Selections p.graph) (other : ReachedTokenContext.Primitive.Other p.graph)
  (samplingPrimitive : LogSumExpRanges.Primitives sampling) (supported : n+1≤262144)

theorem advance_frame {base size : Nat} (below : Before before.frontier.cursor base size)
    (offset : Nat) (bound : offset<size) :
    (CheckpointCopiedHighWaterState.advance before room dispatches sampling lseLocal tileLocal finishLocal
      encoded binding selected other samplingPrimitive supported).memory.index.bytes (base+offset)=
      before.memory.index.bytes (base+offset) :=
  (congrFun (CheckpointNativeCopiedTokenState.advance_heap
    (NativeCopiedTokenConstruction.step (CheckpointCopiedHighWaterState.plan before room dispatches sampling lseLocal tileLocal finishLocal))
    encoded binding selected other samplingPrimitive supported) (base+offset)).trans
    (NativeCopiedHighWaterFrame.frame (CheckpointCopiedHighWaterState.request before room dispatches)
      (RopeInputConstruction.inputs n) sampling lseLocal tileLocal finishLocal below offset bound)
end Step

variable {p : Pipeline} (ctx : CheckpointCopiedHighWaterRun.Context p)
  (initial : CheckpointCopiedHighWaterState.State p 0)
  (room : initial.frontier.cursor+NativeCopiedAllocationBudget.budget≤2^64)

theorem frame_for_arbitrary_initial_span (n : Nat) (supported : n≤262144)
    {base size : Nat} (below : Before initial.frontier.cursor base size) (offset : Nat) (bound : offset<size) :
    (CheckpointCopiedHighWaterRun.run ctx initial room n supported).state.memory.index.bytes (base+offset)=
      initial.memory.index.bytes (base+offset) := by
  induction n with
  | zero => rfl
  | succ n ih =>
    let previous := CheckpointCopiedHighWaterRun.run ctx initial room n (by omega)
    have belowCurrent : Before previous.state.frontier.cursor base size := below.trans (by
      rw [previous.frontier]
      exact Nat.le_add_right _ _)
    exact (advance_frame previous.state
      (CheckpointCopiedHighWaterRun.stepRoom initial room previous supported) (ctx.dispatches n)
      ctx.sampling (ctx.lseLocal n) (ctx.tileLocal n) (ctx.finishLocal n)
      ctx.encoded ctx.binding ctx.selected ctx.other ctx.samplingPrimitive supported belowCurrent offset bound).trans (ih (by omega))

end Inference.Models.Qwen.CheckpointCopiedHighWaterRunFrame
