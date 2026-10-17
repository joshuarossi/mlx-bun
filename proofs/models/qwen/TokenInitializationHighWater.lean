import models.qwen.DecodeCacheGeometry
import models.qwen.ResidualDeltaHighWater

namespace Inference.Models.Qwen.TokenInitializationHighWater
open Contracts.Mlx DecodeStage
open ResidualDeltaHighWater (Before Frontier before_mono fresh)
set_option maxRecDepth 100000
set_option maxHeartbeats 800000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

-- Twelve padding bytes round the actual initialization footprint to sixteen.
def bytes : Nat := 153944080

def next (frontier : Frontier) : Frontier where
  cursor := frontier.cursor+bytes
  aligned := by have := frontier.aligned; dsimp [bytes]; omega

theorem le_next (frontier : Frontier) : frontier.cursor≤(next frontier).cursor := by dsimp [next]; omega

variable {p : TokenInference.Pipeline} {initialHeap : ByteMemory.Bytes}
  (original : TokenParameterMemory.Storage p initialHeap) (token : Fin 248320) (frontier : Frontier)
  (capacity : (next frontier).cursor≤2^64) (originalBound : original.Protected (Before frontier.cursor))

def workspace : TokenInitializationAllocation.Workspace p.graph.stages where
  base := frontier.cursor
  aligned := by have := frontier.aligned; omega
  bounded := by
    rw [TokenInitializationAllocation.graph_footprint]
    have := capacity
    dsimp [next,bytes] at this
    omega

def initialized : TokenInitializationMemory.Initialized p :=
  (workspace (p:=p) frontier capacity).initialize original
    (original.protected_mono (fun _ _ bound => fresh bound) originalBound) (token:=token)

theorem token_base : (initialized original token frontier capacity originalBound).state.index.base=frontier.cursor :=
  (workspace (p:=p) frontier capacity).token_base original _

theorem token_bound : Before (next frontier).cursor (initialized original token frontier capacity originalBound).state.index.base 4 := by
  rw [token_base]
  dsimp [Before,next,bytes]
  omega

theorem token_read : (initialized original token frontier capacity originalBound).state.index.read=token.val :=
  (workspace (p:=p) frontier capacity).token_read original _

theorem caches_read : (initialized original token frontier capacity originalBound).state.readCaches=InitialState.caches p.graph.stages :=
  (workspace (p:=p) frontier capacity).caches_read original _

theorem initializationCache_mono : (stages : List Stage) → (plan : InitialCacheMemory.Plan stages) →
    {first second : Nat → Nat → Prop} → (∀ base size, first base size → second base size) →
    TokenInitializationAllocation.CacheProtected first stages plan → TokenInitializationAllocation.CacheProtected second stages plan
  | [], _, _, _, _, _ => True.intro
  | .delta _::rest, plan, _, _, implies, safe =>
    ⟨⟨implies _ _ safe.1.1,implies _ _ safe.1.2⟩,initializationCache_mono rest plan.2 implies safe.2⟩
  | .attention _::rest, plan, _, _, implies, safe => initializationCache_mono rest plan.2 implies safe

theorem initialized_protected (w : TokenInitializationAllocation.Workspace p.graph.stages)
    (safe : original.Protected (MemoryRegions.Disjoint w.base (TokenInitializationAllocation.bytes p.graph.stages)))
    (property : Nat → Nat → Prop) (empty : property 0 0)
    (regions : TokenInitializationAllocation.CacheProtected property p.graph.stages w.caches) :
    let ready := w.initialize original safe (token:=token)
    DecodePreservation.Protected property p.graph.stages ready.state.logical.cache ready.state.index.bytes ready.state.caches :=
  DecodeCacheGeometry.initial_protected property empty p.graph.stages w.caches _
    (InitialCacheMemory.execute_ready p.graph.stages w.caches (w.plan (token:=token) (initialHeap:=initialHeap)).tokenWrite.memory) regions

theorem cache_bound :
    let ready := initialized original token frontier capacity originalBound
    DecodePreservation.Protected (Before (next frontier).cursor) p.graph.stages
      ready.state.logical.cache ready.state.index.bytes ready.state.caches := by
  apply initialized_protected original token (workspace (p:=p) frontier capacity)
  · exact Nat.zero_le _
  · apply initializationCache_mono p.graph.stages (workspace (p:=p) frontier capacity).caches
      (first := fun address count => frontier.cursor+4≤address ∧ address+count≤frontier.cursor+TokenInitializationAllocation.bytes p.graph.stages)
    · intro base size bound
      have footprint := TokenInitializationAllocation.graph_footprint p.graph
      dsimp [Before,next,bytes]
      omega
    · exact (workspace (p:=p) frontier capacity).cache_within

theorem parameters_regions (property : Nat → Nat → Prop) :
    (initialized original token frontier capacity originalBound).parameters.Protected property ↔ original.Protected property :=
  (workspace (p:=p) frontier capacity).parameters_regions original _ property

theorem parameters_bound :
    (initialized original token frontier capacity originalBound).parameters.Protected (Before (next frontier).cursor) :=
  (parameters_regions original token frontier capacity originalBound _).mpr
    (original.protected_mono (fun _ _ bound => before_mono (le_next frontier) bound) originalBound)

theorem parameter_bytes : original.Protected (fun base size => ∀ offset < size,
    (initialized original token frontier capacity originalBound).state.index.bytes (base+offset)=initialHeap (base+offset)) :=
  (workspace (p:=p) frontier capacity).parameter_bytes original _

theorem pairwise :
    let ready := initialized original token frontier capacity originalBound
    DecodeCacheGeometry.Pairwise p.graph.stages ready.state.logical.cache ready.state.index.bytes ready.state.caches :=
  DecodeCacheGeometry.initialized_pairwise (workspace (p:=p) frontier capacity) original _

theorem padding : bytes=153944068+12 := by decide

end Inference.Models.Qwen.TokenInitializationHighWater
