import models.qwen.CheckpointCopiedHighWaterState
import models.qwen.InitialCopiedSequenceSeed
namespace Inference.Models.Qwen.CheckpointCopiedHighWaterSeed
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
open ResidualDeltaHighWater (Frontier Before)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes}
  (original : TokenParameterMemory.Storage p initialHeap) (token : Fin 248320) (frontier : Frontier)
  (room : frontier.cursor+InitialCopiedSequenceSeed.bytes p≤2^64)
  (parameters : original.Protected (Before frontier.cursor))

include room in
private theorem initializationRoom : (TokenInitializationHighWater.next frontier).cursor≤2^64 := by
  have total := room
  dsimp only [TokenInitializationHighWater.next,InitialCopiedSequenceSeed.bytes] at *
  omega

-- The seed carries the real initialized heap and its geometric invariants.
-- Its initial cache plan and token write are computed from this arena.
def seed : CheckpointCopiedHighWaterState.State p 0 where
  memory := (InitialCopiedSequenceSeed.initialized original token frontier room parameters).state
  parameters := (InitialCopiedSequenceSeed.initialized original token frontier room parameters).parameters
  frontier := InitialCopiedSequenceSeed.nextFrontier frontier
  tokenBound := TokenInitializationHighWater.token_bound original token frontier (initializationRoom frontier room) parameters
  parametersBound := TokenInitializationHighWater.parameters_bound original token frontier (initializationRoom frontier room) parameters
  cachesBound := TokenInitializationHighWater.cache_bound original token frontier (initializationRoom frontier room) parameters
  canonical := InitialCopiedSequenceSeed.canonical original token frontier room parameters

theorem first_room : (seed original token frontier room parameters).frontier.cursor+NativeCopiedHighWater.bytes p 0≤2^64 := by
  change frontier.cursor+TokenInitializationHighWater.bytes+InitialCopiedTokenHighWater.bytes p≤2^64
  simpa only [InitialCopiedSequenceSeed.bytes,Nat.add_assoc] using room

def initializationPlan : TokenInitializationMemory.Plan p token initialHeap :=
  InitialCopiedSequenceSeed.initializationPlan token frontier room

def cachePlan : InitialCacheMemory.Plan p.graph.stages := (initializationPlan (p:=p) (initialHeap:=initialHeap) token frontier room).caches

def tokenHeap : ByteMemory.Bytes := (initializationPlan (p:=p) (initialHeap:=initialHeap) token frontier room).tokenWrite.memory

def index : Inference.State.TokenStorage.Buffer token := (initializationPlan (p:=p) (initialHeap:=initialHeap) token frontier room).index

theorem shared : (index (p:=p) (initialHeap:=initialHeap) token frontier room).bytes=
    InitialCacheMemory.execute p.graph.stages (cachePlan (p:=p) (initialHeap:=initialHeap) token frontier room)
      (tokenHeap (p:=p) (initialHeap:=initialHeap) token frontier room) := rfl

theorem memory_eq : (seed original token frontier room parameters).memory=
    TokenAutoregressiveMemory.initial p token (cachePlan (p:=p) (initialHeap:=initialHeap) token frontier room)
      (tokenHeap (p:=p) (initialHeap:=initialHeap) token frontier room)
      (index (p:=p) (initialHeap:=initialHeap) token frontier room)
      (shared (p:=p) (initialHeap:=initialHeap) token frontier room) := rfl

theorem parameters_eq : (seed original token frontier room parameters).parameters=
    (InitialCopiedSequenceSeed.initialized original token frontier room parameters).parameters := rfl

theorem frontier_eq : (seed original token frontier room parameters).frontier=TokenInitializationHighWater.next frontier := rfl

-- Exact initial indices for the checkpoint recurrence, with no externally
-- supplied initializer or alternate parameter/cache heap.
theorem trace (sampling : LogSumExpRanges.Platform)
    (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
    (selected : ReachedTokenContext.Primitive.Selections p.graph)
    (other : ReachedTokenContext.Primitive.Other p.graph) (samplingPrimitive : LogSumExpRanges.Primitives sampling) :
    CheckpointNativeCopiedSequence.Trace p sampling encoded binding selected other samplingPrimitive token
      (cachePlan (p:=p) (initialHeap:=initialHeap) token frontier room)
      (tokenHeap (p:=p) (initialHeap:=initialHeap) token frontier room)
      (index (p:=p) (initialHeap:=initialHeap) token frontier room)
      (shared (p:=p) (initialHeap:=initialHeap) token frontier room)
      (seed original token frontier room parameters).parameters
      (seed original token frontier room parameters).memory
      (seed original token frontier room parameters).parameters := .initial

theorem token_read : (seed original token frontier room parameters).memory.index.read=token.val :=
  InitialCopiedSequenceSeed.token_read original token frontier room parameters

theorem original_parameters (property : Nat → Nat → Prop) :
    (seed original token frontier room parameters).parameters.Protected property ↔ original.Protected property :=
  InitialCopiedSequenceSeed.original_parameters original token frontier room parameters property

theorem original_bytes : original.Protected (fun base size => ∀ offset<size,
    (seed original token frontier room parameters).memory.index.bytes (base+offset)=initialHeap (base+offset)) :=
  InitialCopiedSequenceSeed.original_bytes original token frontier room parameters

end Inference.Models.Qwen.CheckpointCopiedHighWaterSeed
