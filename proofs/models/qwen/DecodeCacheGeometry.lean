import models.qwen.TokenInitializationAllocation

namespace Inference.Models.Qwen.DecodeCacheGeometry
open Contracts.Mlx DecodeStage DecodeChain
set_option maxRecDepth 10000

abbrev Region := Nat × Nat
def Separate (first second : Region) : Prop := MemoryRegions.Disjoint first.1 first.2 second.1 second.2

def stageRegions : (stage : Stage) → (cache : Cache stage n) → DecodeFrame.StageStorage stage cache → List Region
  | .delta _, _, storage => [(storage.buffers.history.base,61440),(storage.buffers.recurrent.base,3145728)]
  | .attention _, _, storage => [(storage.layout.keyBase,State.KvRegions.bytes n),(storage.layout.valueBase,State.KvRegions.bytes n)]

def regions : (stages : List Stage) → (cache : Caches stages n) → (memory : ByteMemory.Bytes) →
    DecodeFrame.Storage stages cache memory → List Region
  | [], _, _, _ => []
  | stage::rest, cache, memory, storage => stageRegions stage cache.1 storage.1.storage ++ regions rest cache.2 memory storage.2

theorem stage_protected_iff (property : Nat → Nat → Prop) (stage : Stage) (cache : Cache stage n)
    (storage : DecodeFrame.StageStorage stage cache) :
    DecodePreservation.StageProtected property stage cache storage ↔
      ∀ region ∈ stageRegions stage cache storage, property region.1 region.2 := by
  cases stage <;> simp [DecodePreservation.StageProtected,stageRegions]

theorem protected_iff (property : Nat → Nat → Prop) (stages : List Stage) (cache : Caches stages n)
    (memory : ByteMemory.Bytes) (storage : DecodeFrame.Storage stages cache memory) :
    DecodePreservation.Protected property stages cache memory storage ↔
      ∀ region ∈ regions stages cache memory storage, property region.1 region.2 := by
  induction stages with
  | nil => simp [DecodePreservation.Protected,regions]
  | cons stage rest ih =>
    simp only [DecodePreservation.Protected,regions,stage_protected_iff,ih,List.mem_append]
    constructor
    · intro h region member
      rcases member with head|tail
      · exact h.1 region head
      · exact h.2 region tail
    · intro h
      exact ⟨fun region member => h region (Or.inl member),fun region member => h region (Or.inr member)⟩

theorem stage_reframe_regions (property : Nat → Nat → Prop) (before after : ByteMemory.Bytes)
    (frame : ∀ base size, property base size → ∀ offset < size, after (base+offset)=before (base+offset))
    (stage : Stage) (cache : Cache stage n) (buffer : DecodeFrame.StageBuffer stage cache before)
    (safe : DecodePreservation.StageProtected property stage cache buffer.storage) :
    stageRegions stage cache (DecodePreservation.stageReframe property before after frame stage cache buffer safe).storage=
      stageRegions stage cache buffer.storage := by
  cases stage <;> rfl

theorem reframe_regions (property : Nat → Nat → Prop) (before after : ByteMemory.Bytes)
    (frame : ∀ base size, property base size → ∀ offset < size, after (base+offset)=before (base+offset))
    (stages : List Stage) (cache : Caches stages n) (storage : DecodeFrame.Storage stages cache before)
    (safe : DecodePreservation.Protected property stages cache before storage) :
    regions stages cache after (DecodePreservation.reframe property before after frame stages cache storage safe)=
      regions stages cache before storage := by
  induction stages with
  | nil => rfl
  | cons stage rest ih =>
    change stageRegions stage cache.1 (DecodePreservation.stageReframe property before after frame stage cache.1 storage.1 safe.1).storage ++
      regions rest cache.2 after (DecodePreservation.reframe property before after frame rest cache.2 storage.2 safe.2)=_
    rw [stage_reframe_regions,ih]
    rfl

theorem stage_pairwise (stage : Stage) (cache : Cache stage n) (storage : DecodeFrame.StageStorage stage cache) :
    (stageRegions stage cache storage).Pairwise Separate := by
  cases stage with
  | delta _ => simpa [stageRegions,Separate] using storage.separate
  | attention _ => simpa [stageRegions,Separate] using storage.layout.separate

def Pairwise (stages : List Stage) (cache : Caches stages n) (memory : ByteMemory.Bytes)
    (storage : DecodeFrame.Storage stages cache memory) : Prop :=
  (regions stages cache memory storage).Pairwise Separate

theorem reframe_pairwise (property : Nat → Nat → Prop) (before after : ByteMemory.Bytes)
    (frame : ∀ base size, property base size → ∀ offset < size, after (base+offset)=before (base+offset))
    (stages : List Stage) (cache : Caches stages n) (storage : DecodeFrame.Storage stages cache before)
    (safe : DecodePreservation.Protected property stages cache before storage)
    (pairwise : Pairwise stages cache before storage) :
    Pairwise stages cache after (DecodePreservation.reframe property before after frame stages cache storage safe) := by
  unfold Pairwise
  rw [reframe_regions]
  exact pairwise

theorem initial_protected (property : Nat → Nat → Prop) (empty : property 0 0)
    (stages : List Stage) (plan : InitialCacheMemory.Plan stages) (memory : ByteMemory.Bytes)
    (ready : InitialCacheMemory.Ready stages plan memory)
    (safe : TokenInitializationAllocation.CacheProtected property stages plan) :
    DecodePreservation.Protected property stages (InitialState.caches stages) memory
      (DecodeFrame.fromInitial stages plan memory ready) := by
  induction stages with
  | nil => trivial
  | cons stage rest ih =>
    cases stage with
    | delta _ => exact ⟨safe.1,ih plan.2 ready.2 safe.2⟩
    | attention _ => exact ⟨⟨empty,empty⟩,ih plan.2 ready.2 safe⟩

theorem initial_pairwise (stages : List Stage) (plan : InitialCacheMemory.Plan stages) (memory : ByteMemory.Bytes)
    (ready : InitialCacheMemory.Ready stages plan memory)
    (disjoint : TokenInitializationAllocation.CacheDisjoint stages plan) :
    Pairwise stages (InitialState.caches stages) memory (DecodeFrame.fromInitial stages plan memory ready) := by
  induction stages with
  | nil => exact .nil
  | cons stage rest ih =>
    change (stageRegions stage (InitialState.stage stage) (DecodeFrame.initialStage stage plan.1 memory ready.1).storage ++
      regions rest (InitialState.caches rest) memory (DecodeFrame.fromInitial rest plan.2 memory ready.2)).Pairwise Separate
    apply List.pairwise_append.mpr
    refine ⟨stage_pairwise _ _ _,?_,?_⟩
    · cases stage with
      | delta _ => exact ih plan.2 ready.2 disjoint.2.2
      | attention _ => exact ih plan.2 ready.2 disjoint
    · intro first firstMember second secondMember
      cases stage with
      | delta _ =>
        simp only [stageRegions,DecodeFrame.initialStage,InitialCacheMemory.deltaStorage,List.mem_cons,List.not_mem_nil,or_false] at firstMember
        rcases firstMember with rfl|rfl
        · exact (protected_iff _ _ _ _ _).mp
            (initial_protected (MemoryRegions.Disjoint plan.1.layout.historyBase 61440) (Or.inr (Nat.zero_le _))
              rest plan.2 memory ready.2 disjoint.1) second secondMember
        · exact (protected_iff _ _ _ _ _).mp
            (initial_protected (MemoryRegions.Disjoint plan.1.layout.recurrentBase 3145728) (Or.inr (Nat.zero_le _))
              rest plan.2 memory ready.2 disjoint.2.1) second secondMember
      | attention _ =>
        simp only [stageRegions,DecodeFrame.initialStage,State.KvRegions.bytes,State.KvAllocation.capacity_zero,
          Nat.mul_zero,Nat.zero_mul,List.mem_cons,List.not_mem_nil,or_false,or_self] at firstMember
        subst first
        exact Or.inl (Nat.zero_le _)

theorem workspace_initial_pairwise (workspace : TokenInitializationAllocation.Workspace stages) (before : ByteMemory.Bytes) :
    Pairwise stages (InitialState.caches stages) (InitialCacheMemory.execute stages workspace.caches before)
      (DecodeFrame.initial stages workspace.caches before) :=
  initial_pairwise stages workspace.caches _ (InitialCacheMemory.execute_ready stages workspace.caches before) workspace.cache_disjoint

theorem head_separate_tail (stage : Stage) (rest : List Stage) (cache : Caches (stage::rest) n)
    (memory : ByteMemory.Bytes) (storage : DecodeFrame.Storage (stage::rest) cache memory)
    (pairwise : Pairwise (stage::rest) cache memory storage)
    (region : Region) (member : region ∈ stageRegions stage cache.1 storage.1.storage) :
    DecodePreservation.Protected (MemoryRegions.Disjoint region.1 region.2) rest cache.2 memory storage.2 := by
  apply (protected_iff _ _ _ _ _).mpr
  intro other otherMember
  exact (List.pairwise_append.mp pairwise).2.2 region member other otherMember

-- A newly allocated cache can be prepended without a per-cache separation
-- oracle when its regions start beyond all retained region ends.
theorem fresh_head_pairwise (stage : Stage) (rest : List Stage) (cache : Caches (stage::rest) n)
    (memory : ByteMemory.Bytes) (storage : DecodeFrame.Storage (stage::rest) cache memory) (cursor : Nat)
    (head : DecodePreservation.StageProtected (fun base _ => cursor≤base) stage cache.1 storage.1.storage)
    (tail : DecodePreservation.Protected (fun base size => base+size≤cursor) rest cache.2 memory storage.2)
    (pairwise : Pairwise rest cache.2 memory storage.2) : Pairwise (stage::rest) cache memory storage := by
  apply List.pairwise_append.mpr
  refine ⟨stage_pairwise _ _ _,pairwise,?_⟩
  intro first firstMember second secondMember
  have lower := (stage_protected_iff _ _ _ _).mp head first firstMember
  have upper := (protected_iff _ _ _ _ _).mp tail second secondMember
  exact Or.inr (upper.trans lower)

attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

theorem initialized_pairwise {p : TokenInference.Pipeline} {token : Fin 248320} {initialHeap : ByteMemory.Bytes}
    (workspace : TokenInitializationAllocation.Workspace p.graph.stages)
    (original : TokenParameterMemory.Storage p initialHeap)
    (safe : original.Protected (MemoryRegions.Disjoint workspace.base (TokenInitializationAllocation.bytes p.graph.stages))) :
    let initialized := workspace.initialize original safe (token := token)
    Pairwise p.graph.stages initialized.state.logical.cache initialized.state.index.bytes initialized.state.caches :=
  workspace_initial_pairwise workspace (workspace.plan (token := token) (initialHeap := initialHeap)).tokenWrite.memory

end Inference.Models.Qwen.DecodeCacheGeometry
