import models.qwen.InitialCopiedTokenHighWater
import models.qwen.CapacityCopiedTokenHighWater

namespace Inference.Models.Qwen.NativeCopiedHighWater
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
open ResidualDeltaHighWater (Frontier Before)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  NativeCopiedTokenConstruction.step NativeCopiedTokenConstruction.after
  NativeCopiedTokenRoute.final FinalProjectionSamplerSource.Execution.sampler

def bytes (p : Pipeline) : Nat → Nat
  | 0 => InitialCopiedTokenHighWater.bytes p
  | n+1 => CapacityCopiedTokenHighWater.bytes p n

def Request {p : Pipeline} : {n : Nat} → {before : TokenAutoregressiveMemory.State p n} →
    TokenParameterMemory.Storage p before.index.bytes → Frontier → Prop
  | 0, _, original, frontier => InitialCopiedTokenHighWater.Request original frontier
  | _+1, _, original, frontier => CapacityCopiedTokenHighWater.Request original frontier

def Dispatches (p : Pipeline) : Nat → Prop
  | 0 => InitialCopiedHighWaterConstruction.Dispatches p.graph.stages
  | _+1 => CapacityCopiedHighWaterConstruction.Dispatches p.graph.stages

-- Empty-cache lineage is needed only at the first step. Every later step
-- consumes the exact indexed cache produced by its predecessor.
def Canonical {p : Pipeline} : {n : Nat} → TokenAutoregressiveMemory.State p n → Prop
  | 0, before => EmptyKvLineage.Canonical p.graph.stages before.logical.cache before.index.bytes before.caches
  | _+1, _ => True

variable {p : Pipeline} {n : Nat} {before : TokenAutoregressiveMemory.State p n}
  {original : TokenParameterMemory.Storage p before.index.bytes} {frontier : Frontier}

def request (room : frontier.cursor+bytes p n≤2^64)
    (token : Before frontier.cursor before.index.base 4)
    (parameters : original.Protected (Before frontier.cursor))
    (caches : DecodePreservation.Protected (Before frontier.cursor) p.graph.stages before.logical.cache before.index.bytes before.caches)
    (canonical : Canonical before) (dispatches : Dispatches p n) : Request original frontier := by
  cases n with
  | zero => exact ⟨room,token,parameters,caches,canonical,dispatches⟩
  | succ n => exact ⟨room,token,parameters,caches,dispatches⟩

variable (r : Request original frontier) (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform)
  (lseLocal : ByteMemory.Bytes) (tileLocal : Fin 243 → ByteMemory.Bytes) (finishLocal : ByteMemory.Bytes)

def plan : NativeCopiedTokenConstruction.Plan p sampling angle before original := by
  cases n with
  | zero => exact InitialCopiedTokenHighWater.nativePlan r angle sampling lseLocal tileLocal finishLocal
  | succ n => exact CapacityCopiedTokenHighWater.nativePlan r angle sampling lseLocal tileLocal finishLocal

theorem safe : NativeCopiedTokenConstruction.Safe (plan r angle sampling lseLocal tileLocal finishLocal) := by
  cases n with
  | zero => exact InitialCopiedTokenHighWater.safe r angle sampling lseLocal tileLocal finishLocal
  | succ n => exact CapacityCopiedTokenHighWater.safe r angle sampling lseLocal tileLocal finishLocal

def next : Frontier := by
  cases n with
  | zero => exact InitialCopiedTokenHighWater.next r
  | succ n => exact CapacityCopiedTokenHighWater.next r

theorem next_eq : (next r).cursor=frontier.cursor+bytes p n := by
  cases n with
  | zero => exact InitialCopiedTokenHighWater.next_eq r
  | succ n => exact CapacityCopiedTokenHighWater.next_eq r

theorem next_bounded : (next r).cursor≤2^64 := by
  cases n with
  | zero => exact InitialCopiedTokenHighWater.next_bounded r
  | succ n => exact CapacityCopiedTokenHighWater.next_bounded r

theorem token_bound : Before (next r).cursor
    (NativeCopiedTokenRoute.final (NativeCopiedTokenConstruction.step
      (plan r angle sampling lseLocal tileLocal finishLocal)).execution).sampler.selection.destination 4 := by
  cases n with
  | zero => exact InitialCopiedTokenHighWater.token_bound r angle sampling lseLocal tileLocal finishLocal
  | succ n => exact CapacityCopiedTokenHighWater.token_bound r angle sampling lseLocal tileLocal finishLocal

theorem caches_bound :
    let step := NativeCopiedTokenConstruction.step (plan r angle sampling lseLocal tileLocal finishLocal)
    DecodePreservation.Protected (Before (next r).cursor) p.graph.stages
      (p.run before.logical.cache before.logical.token angle).2
      (NativeCopiedTokenRoute.final step.execution).sampler.memory
      (NativeCopiedTokenMemory.after step.execution step.safe) := by
  cases n with
  | zero => exact InitialCopiedTokenHighWater.caches_bound r angle sampling lseLocal tileLocal finishLocal
  | succ n => exact CapacityCopiedTokenHighWater.caches_bound r angle sampling lseLocal tileLocal finishLocal

theorem parameters_bound :
    (NativeCopiedTokenConstruction.after (plan r angle sampling lseLocal tileLocal finishLocal)
      (safe r angle sampling lseLocal tileLocal finishLocal)).Protected (Before (next r).cursor) := by
  cases n with
  | zero => exact InitialCopiedTokenHighWater.parameters_bound r angle sampling lseLocal tileLocal finishLocal
  | succ n => exact CapacityCopiedTokenHighWater.parameters_bound r angle sampling lseLocal tileLocal finishLocal

end Inference.Models.Qwen.NativeCopiedHighWater
