import models.qwen.InitialCopiedTokenHighWater
import models.qwen.InitialCopiedInitializationLineage
import models.qwen.TokenInitializationHighWater
namespace Inference.Models.Qwen.InitialCopiedSequenceSeed
open Contracts.Mlx Layers TokenInference Kernels.Attention
open ResidualDeltaHighWater (Frontier Before)
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

-- Initialization's token/cache stores and the first complete inference call
-- consume one checked arena bound; no completed initializer plan is supplied.
def bytes (p : Pipeline) : Nat := TokenInitializationHighWater.bytes+InitialCopiedTokenHighWater.bytes p

private theorem plan_canonical {p : Pipeline} {token : Fin 248320} {initialHeap : ByteMemory.Bytes}
    (plan : TokenInitializationMemory.Plan p token initialHeap) :
    EmptyKvLineage.Canonical p.graph.stages plan.state.logical.cache plan.state.index.bytes plan.state.caches :=
  InitialCopiedInitializationLineage.state p token plan.caches plan.tokenWrite.memory plan.index rfl

variable {p : Pipeline} {initialHeap : ByteMemory.Bytes}
  (original : TokenParameterMemory.Storage p initialHeap) (token : Fin 248320) (frontier : Frontier)
  (room : frontier.cursor+bytes p≤2^64) (parameters : original.Protected (Before frontier.cursor))

include room in
private theorem initializationRoom : (TokenInitializationHighWater.next frontier).cursor≤2^64 := by
  dsimp only [TokenInitializationHighWater.next]
  have total := room
  unfold bytes at total
  omega

def initializationPlan : TokenInitializationMemory.Plan p token initialHeap :=
  (TokenInitializationHighWater.workspace (p:=p) frontier (initializationRoom frontier room)).plan

def initialized : TokenInitializationMemory.Initialized p :=
  TokenInitializationHighWater.initialized original token frontier (initializationRoom frontier room) parameters

theorem state_eq : (initialized original token frontier room parameters).state=
    (initializationPlan (p:=p) (initialHeap:=initialHeap) token frontier room).state := rfl

def nextFrontier : Frontier := TokenInitializationHighWater.next frontier

include room in
private theorem firstRoom : (nextFrontier frontier).cursor+InitialCopiedTokenHighWater.bytes p≤2^64 := by
  simpa only [nextFrontier,TokenInitializationHighWater.next,bytes,Nat.add_assoc] using room

theorem canonical :
    let ready := initialized original token frontier room parameters
    EmptyKvLineage.Canonical p.graph.stages ready.state.logical.cache ready.state.index.bytes ready.state.caches :=
  plan_canonical (TokenInitializationHighWater.workspace (p:=p) frontier (initializationRoom frontier room)).plan

-- These are precisely the inputs needed by the complete first-token source
-- allocator, attached to the actual initialized parameter/cache heap.
theorem request (dispatches : InitialCopiedHighWaterConstruction.Dispatches p.graph.stages) :
    InitialCopiedTokenHighWater.Request (initialized original token frontier room parameters).parameters (nextFrontier frontier) := {
  room := firstRoom frontier room
  token := TokenInitializationHighWater.token_bound original token frontier (initializationRoom frontier room) parameters
  parameters := TokenInitializationHighWater.parameters_bound original token frontier (initializationRoom frontier room) parameters
  caches := TokenInitializationHighWater.cache_bound original token frontier (initializationRoom frontier room) parameters
  canonical := canonical original token frontier room parameters
  dispatches := dispatches }

theorem token_read : (initialized original token frontier room parameters).state.index.read=token.val :=
  TokenInitializationHighWater.token_read original token frontier (initializationRoom frontier room) parameters

theorem original_parameters (property : Nat → Nat → Prop) :
    (initialized original token frontier room parameters).parameters.Protected property ↔ original.Protected property :=
  TokenInitializationHighWater.parameters_regions original token frontier (initializationRoom frontier room) parameters property

theorem original_bytes : original.Protected (fun base size => ∀ offset<size,
    (initialized original token frontier room parameters).state.index.bytes (base+offset)=initialHeap (base+offset)) :=
  TokenInitializationHighWater.parameter_bytes original token frontier (initializationRoom frontier room) parameters

end Inference.Models.Qwen.InitialCopiedSequenceSeed
