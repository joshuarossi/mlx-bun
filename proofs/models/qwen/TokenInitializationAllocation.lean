import models.qwen.TokenInitializationMemory

namespace Inference.Models.Qwen.TokenInitializationAllocation
open Contracts.Mlx DecodeStage
set_option maxRecDepth 100000
set_option maxHeartbeats 800000

def deltaCount : List Stage → Nat
  | [] => 0
  | .delta _::rest => 1+deltaCount rest
  | .attention _::rest => deltaCount rest

def cacheBytes : List Stage → Nat
  | [] => 0
  | .delta _::rest => 3207168+cacheBytes rest
  | .attention _::rest => cacheBytes rest

def bytes (stages : List Stage) : Nat := 4+cacheBytes stages

theorem cacheBytes_count (stages : List Stage) : cacheBytes stages=3207168*deltaCount stages := by
  induction stages with
  | nil => rfl
  | cons stage rest ih => cases stage <;> simp only [cacheBytes,deltaCount,ih,Nat.mul_add,Nat.mul_one]

def cachePlan : (stages : List Stage) → (base : Nat) → base%4=0 → base+cacheBytes stages≤2^64 → InitialCacheMemory.Plan stages
  | [], _, _, _ => ⟨⟩
  | .delta _::rest, base, aligned, bounded =>
    ⟨⟨InitialStorage.DeltaTrace.fromBefore (fun _ => 0) (fun _ => 0),
      InitialStorageRegions.Layout.contiguous base aligned (by change base+(3207168+cacheBytes rest)≤2^64 at bounded; omega)⟩,
      cachePlan rest (base+3207168) (by omega) (by change base+(3207168+cacheBytes rest)≤2^64 at bounded; omega)⟩
  | .attention _::rest, base, aligned, bounded => ⟨⟨⟩,cachePlan rest base aligned bounded⟩

def CacheProtected (property : Nat → Nat → Prop) : (stages : List Stage) → InitialCacheMemory.Plan stages → Prop
  | [], _ => True
  | .delta _::rest, plan =>
    (property plan.1.layout.historyBase 61440 ∧ property plan.1.layout.recurrentBase 3145728) ∧ CacheProtected property rest plan.2
  | .attention _::rest, plan => CacheProtected property rest plan.2

theorem cache_regions (stages : List Stage) (base : Nat) (aligned : base%4=0) (bounded : base+cacheBytes stages≤2^64)
    (property : Nat → Nat → Prop)
    (regions : ∀ offset count, offset+count≤cacheBytes stages → property (base+offset) count) :
    CacheProtected property stages (cachePlan stages base aligned bounded) := by
  induction stages generalizing base with
  | nil => trivial
  | cons stage rest ih =>
    cases stage with
    | delta layer =>
      refine ⟨⟨?_,?_⟩,?_⟩
      · simpa only [cachePlan,InitialStorageRegions.Layout.contiguous,Nat.add_zero] using regions 0 61440 (by change 0+61440≤3207168+cacheBytes rest; omega)
      · exact regions 61440 3145728 (by change 61440+3145728≤3207168+cacheBytes rest; omega)
      · apply ih
        intro offset count inside
        simpa only [Nat.add_assoc] using regions (3207168+offset) count (by change 3207168+offset+count≤3207168+cacheBytes rest; omega)
    | attention layer => exact ih base aligned bounded regions

theorem cache_protected_safe (stages : List Stage) (plan : InitialCacheMemory.Plan stages)
    (safe : CacheProtected (MemoryRegions.Disjoint base size) stages plan) :
    TokenInitializationMemory.CacheSafe stages plan base size := by
  induction stages with
  | nil => trivial
  | cons stage rest ih =>
    cases stage with
    | delta _ => exact ⟨⟨MemoryRegions.disjoint_symm safe.1.1,MemoryRegions.disjoint_symm safe.1.2⟩,ih plan.2 safe.2⟩
    | attention _ => exact ⟨trivial,ih plan.2 safe⟩

theorem cache_within (stages : List Stage) (base : Nat) (aligned : base%4=0) (bounded : base+cacheBytes stages≤2^64) :
    CacheProtected (fun address count => base≤address ∧ address+count≤base+cacheBytes stages)
      stages (cachePlan stages base aligned bounded) :=
  cache_regions stages base aligned bounded _ (by intro offset count inside; constructor <;> omega)

-- Internal history/state separation is already a field of each Layout.
-- This additionally separates each Delta slot from every later slot.
def CacheDisjoint : (stages : List Stage) → InitialCacheMemory.Plan stages → Prop
  | [], _ => True
  | .delta _::rest, plan =>
    CacheProtected (MemoryRegions.Disjoint plan.1.layout.historyBase 61440) rest plan.2 ∧
    CacheProtected (MemoryRegions.Disjoint plan.1.layout.recurrentBase 3145728) rest plan.2 ∧ CacheDisjoint rest plan.2
  | .attention _::rest, plan => CacheDisjoint rest plan.2

theorem cache_disjoint (stages : List Stage) (base : Nat) (aligned : base%4=0) (bounded : base+cacheBytes stages≤2^64) :
    CacheDisjoint stages (cachePlan stages base aligned bounded) := by
  induction stages generalizing base with
  | nil => trivial
  | cons stage rest ih =>
    cases stage with
    | delta layer =>
      refine ⟨?_,?_,?_⟩
      · apply cache_regions
        intro offset count inside
        change MemoryRegions.Disjoint base 61440 ((base+3207168)+offset) count
        exact Or.inl (by omega)
      · apply cache_regions
        intro offset count inside
        change MemoryRegions.Disjoint (base+61440) 3145728 ((base+3207168)+offset) count
        exact Or.inl (by omega)
      · apply ih
    | attention layer => exact ih base aligned bounded

theorem delta_slots (stages : List Stage) : bytes stages=4+3207168*deltaCount stages := by rw [bytes,cacheBytes_count]

theorem deltaCount_filter (stages : List Stage) :
    deltaCount stages=(stages.filter (fun stage => !Qwen38TrellisM1Max.isAttention stage)).length := by
  induction stages with
  | nil => rfl
  | cons stage rest ih => cases stage <;> simp [deltaCount,Qwen38TrellisM1Max.isAttention,ih,Nat.add_comm]

theorem graph_delta_count (graph : Qwen38TrellisM1Max.Graph) : deltaCount graph.stages=48 := by
  rw [deltaCount_filter]
  exact graph.delta_count

theorem graph_footprint (graph : Qwen38TrellisM1Max.Graph) : bytes graph.stages=153944068 := by
  rw [delta_slots,graph_delta_count]

attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

structure Workspace (stages : List Stage) where
  base : Nat
  aligned : base%4=0
  bounded : base+bytes stages≤2^64

variable {stages : List Stage}

def Workspace.caches (w : Workspace stages) : InitialCacheMemory.Plan stages :=
  cachePlan stages (w.base+4) (by have := w.aligned; omega) (by have := w.bounded; dsimp [bytes] at this; omega)

theorem Workspace.cache_disjoint (w : Workspace stages) : CacheDisjoint stages w.caches :=
  TokenInitializationAllocation.cache_disjoint stages (w.base+4)
    (by have := w.aligned; omega) (by have := w.bounded; dsimp [bytes] at this; omega)

theorem Workspace.cache_within (w : Workspace stages) :
    CacheProtected (fun address count => w.base+4≤address ∧ address+count≤w.base+bytes stages) stages w.caches := by
  apply cache_regions
  intro offset count inside
  dsimp [bytes]
  constructor <;> omega

theorem Workspace.cache_safe (w : Workspace stages) (safe : MemoryRegions.Disjoint w.base (bytes stages) other size) :
    TokenInitializationMemory.CacheSafe stages w.caches other size := by
  apply cache_protected_safe
  apply cache_regions
  intro offset count inside
  unfold MemoryRegions.Disjoint at *
  dsimp [bytes] at safe
  omega

theorem Workspace.token_safe (w : Workspace stages) : TokenInitializationMemory.CacheSafe stages w.caches w.base 4 := by
  apply cache_protected_safe
  apply cache_regions
  intro offset count inside
  exact Or.inl (by omega)

variable {p : TokenInference.Pipeline} {token : Fin 248320} {initialHeap : ByteMemory.Bytes}

def Workspace.plan (w : Workspace p.graph.stages) : TokenInitializationMemory.Plan p token initialHeap where
  tokenBase := w.base
  tokenAligned := w.aligned
  tokenBounded := by have := w.bounded; dsimp [bytes] at this; omega
  caches := w.caches
  tokenSafe := w.token_safe

theorem Workspace.protect (w : Workspace p.graph.stages) (safe : MemoryRegions.Disjoint w.base (bytes p.graph.stages) other size) :
    (w.plan (token:=token) (initialHeap:=initialHeap)).Safe other size := by
  refine ⟨?_,w.cache_safe safe⟩
  change MemoryRegions.Disjoint w.base 4 other size
  unfold MemoryRegions.Disjoint at *
  dsimp [bytes] at safe
  omega

def Workspace.initialize (w : Workspace p.graph.stages) (original : TokenParameterMemory.Storage p initialHeap)
    (safe : original.Protected (MemoryRegions.Disjoint w.base (bytes p.graph.stages))) : TokenInitializationMemory.Initialized p :=
  TokenInitializationMemory.fromStorage original (w.plan (token:=token) (initialHeap:=initialHeap))
    (original.protected_mono (fun _ _ region => w.protect region) safe)

theorem Workspace.token_base (w : Workspace p.graph.stages) (original : TokenParameterMemory.Storage p initialHeap)
    (safe : original.Protected (MemoryRegions.Disjoint w.base (bytes p.graph.stages))) :
    (w.initialize original safe (token:=token)).state.index.base=w.base := rfl

theorem Workspace.token_read (w : Workspace p.graph.stages) (original : TokenParameterMemory.Storage p initialHeap)
    (safe : original.Protected (MemoryRegions.Disjoint w.base (bytes p.graph.stages))) :
    (w.initialize original safe (token:=token)).state.index.read=token.val :=
  TokenInitializationMemory.initialize_token _ _ _

theorem Workspace.caches_read (w : Workspace p.graph.stages) (original : TokenParameterMemory.Storage p initialHeap)
    (safe : original.Protected (MemoryRegions.Disjoint w.base (bytes p.graph.stages))) :
    (w.initialize original safe (token:=token)).state.readCaches=InitialState.caches p.graph.stages :=
  TokenInitializationMemory.initialize_caches _ _ _

theorem Workspace.parameter_bytes (w : Workspace p.graph.stages) (original : TokenParameterMemory.Storage p initialHeap)
    (safe : original.Protected (MemoryRegions.Disjoint w.base (bytes p.graph.stages))) :
    original.Protected (fun base size => ∀ offset < size,
      (w.initialize original safe (token:=token)).state.index.bytes (base+offset)=initialHeap (base+offset)) :=
  w.plan.parameters_bytes original (original.protected_mono (fun _ _ region => w.protect region) safe)

theorem Workspace.parameters_regions (w : Workspace p.graph.stages) (original : TokenParameterMemory.Storage p initialHeap)
    (safe : original.Protected (MemoryRegions.Disjoint w.base (bytes p.graph.stages))) (property : Nat → Nat → Prop) :
    (w.initialize original safe (token:=token)).parameters.Protected property ↔ original.Protected property :=
  w.plan.parameters_regions original (original.protected_mono (fun _ _ region => w.protect region) safe) property

theorem Workspace.other_region (w : Workspace p.graph.stages)
    (safe : MemoryRegions.Disjoint w.base (bytes p.graph.stages) other size) (offset : Nat) (bound : offset<size) :
    (w.plan (token:=token) (initialHeap:=initialHeap)).memory (other+offset)=initialHeap (other+offset) :=
  w.plan.other_region (w.protect safe) offset bound

end Inference.Models.Qwen.TokenInitializationAllocation
