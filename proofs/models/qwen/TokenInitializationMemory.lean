import models.qwen.TokenParameterMemory

namespace Inference.Models.Qwen.TokenInitializationMemory
open Contracts.Mlx Layers TokenInference DecodeStage
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

-- Every cache write region is explicit; attention's empty KV has no stores.
def StageSafe : (stage : Stage) → InitialCacheMemory.StagePlan stage → Nat → Nat → Prop
  | .delta _, plan, base, size => MemoryRegions.Disjoint plan.layout.historyBase 61440 base size ∧
      MemoryRegions.Disjoint plan.layout.recurrentBase 3145728 base size
  | .attention _, _, _, _ => True

def CacheSafe : (stages : List Stage) → InitialCacheMemory.Plan stages → Nat → Nat → Prop
  | [], _, _, _ => True
  | stage::rest, plan, base, size => StageSafe stage plan.1 base size ∧ CacheSafe rest plan.2 base size

theorem stage_frame (stage : Stage) (plan : InitialCacheMemory.StagePlan stage) (before : ByteMemory.Bytes)
    (safe : StageSafe stage plan base size) (offset : Nat) (bound : offset<size) :
    InitialCacheMemory.stageMemory stage plan before (base+offset)=before (base+offset) := by
  cases stage with
  | delta _ =>
    exact (MemoryRegions.execute32_other _ _ (InitialStorageRegions.shifted_recurrent_inside plan.trace plan.layout)
      safe.2 offset bound).trans
      (MemoryRegions.execute16_other _ _ (InitialStorageRegions.shifted_history_inside plan.trace plan.layout)
        safe.1 offset bound)
  | attention _ => rfl

theorem cache_frame (stages : List Stage) (plan : InitialCacheMemory.Plan stages) (before : ByteMemory.Bytes)
    (safe : CacheSafe stages plan base size) (offset : Nat) (bound : offset<size) :
    InitialCacheMemory.execute stages plan before (base+offset)=before (base+offset) := by
  induction stages generalizing before with
  | nil => rfl
  | cons stage rest ih => exact (ih plan.2 _ safe.2).trans (stage_frame stage plan.1 before safe.1 offset bound)

structure Plan (p : Pipeline) (token : Fin 248320) (initialHeap : ByteMemory.Bytes) where
  tokenBase : Nat
  tokenAligned : tokenBase%4=0
  tokenBounded : tokenBase+4≤2^64
  caches : InitialCacheMemory.Plan p.graph.stages
  tokenSafe : CacheSafe p.graph.stages caches tokenBase 4

variable {p : Pipeline} {token : Fin 248320} {initialHeap : ByteMemory.Bytes}

def Plan.tokenWrite (plan : Plan p token initialHeap) : WordArrayWrites.Trace plan.tokenBase (fun _ : Fin 1 => BitVec.ofNat 32 token.val) :=
  let programs := WordArrayWrites.programs plan.tokenBase (fun _ : Fin 1 => BitVec.ofNat 32 token.val)
  ⟨initialHeap,plan.tokenAligned,by simpa using plan.tokenBounded,programs.flatten,List.replicate programs.length [],
    ThreadgroupWrites.canonical programs,ThreadgroupWrites.canonical_barrier programs⟩

def Plan.memory (plan : Plan p token initialHeap) : ByteMemory.Bytes :=
  InitialCacheMemory.execute p.graph.stages plan.caches plan.tokenWrite.memory

def Plan.Safe (plan : Plan p token initialHeap) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint plan.tokenBase 4 base size ∧ CacheSafe p.graph.stages plan.caches base size

theorem Plan.other_region (plan : Plan p token initialHeap) (safe : plan.Safe base size) (offset : Nat) (bound : offset<size) :
    plan.memory (base+offset)=initialHeap (base+offset) :=
  (cache_frame p.graph.stages plan.caches plan.tokenWrite.memory safe.2 offset bound).trans
    (MemoryRegions.execute32_other _ _ (ArrayFrame.word_stores_inside plan.tokenWrite) safe.1 offset bound)

theorem Plan.token_bytes (plan : Plan p token initialHeap) (offset : Fin 4) :
    plan.memory (plan.tokenBase+offset.val)=ByteMemory.byte (BitVec.ofNat 32 token.val) offset.val := by
  exact (cache_frame p.graph.stages plan.caches plan.tokenWrite.memory plan.tokenSafe offset.val offset.isLt).trans
    (by simpa only [Fin.val_zero,Nat.mul_zero,Nat.add_zero] using plan.tokenWrite.byte_correct (0 : Fin 1) offset)

theorem Plan.token_read (plan : Plan p token initialHeap) :
    ByteMemory.load32 plan.memory plan.tokenBase=BitVec.ofNat 32 token.val := by
  have same : ByteMemory.load32 plan.memory plan.tokenBase=ByteMemory.load32 plan.tokenWrite.memory plan.tokenBase := by
    unfold ByteMemory.load32 Plan.memory
    rw [cache_frame _ _ _ plan.tokenSafe 0 (by decide),cache_frame _ _ _ plan.tokenSafe 1 (by decide),
      cache_frame _ _ _ plan.tokenSafe 2 (by decide),cache_frame _ _ _ plan.tokenSafe 3 (by decide)]
  exact same.trans (by simpa using plan.tokenWrite.read_correct (0 : Fin 1))

def Plan.index (plan : Plan p token initialHeap) : Inference.State.TokenStorage.Buffer token :=
  ⟨plan.memory,plan.tokenBase,plan.tokenAligned,plan.tokenBounded,plan.token_read⟩

def Plan.state (plan : Plan p token initialHeap) : TokenAutoregressiveMemory.State p 0 :=
  TokenAutoregressiveMemory.initial p token plan.caches plan.tokenWrite.memory plan.index rfl

def Plan.parameters (plan : Plan p token initialHeap) (original : TokenParameterMemory.Storage p initialHeap)
    (safe : original.Protected plan.Safe) : TokenParameterMemory.Storage p plan.state.index.bytes :=
  original.reframe plan.memory (original.protected_mono (fun _ _ region => plan.other_region region) safe)

theorem Plan.parameters_regions (plan : Plan p token initialHeap) (original : TokenParameterMemory.Storage p initialHeap)
    (safe : original.Protected plan.Safe) (property : Nat → Nat → Prop) :
    (plan.parameters original safe).Protected property ↔ original.Protected property := original.reframe_protected _ _ property

theorem Plan.parameters_bytes (plan : Plan p token initialHeap) (original : TokenParameterMemory.Storage p initialHeap)
    (safe : original.Protected plan.Safe) :
    original.Protected (fun base size => ∀ offset < size, plan.state.index.bytes (base+offset)=initialHeap (base+offset)) :=
  original.protected_mono (fun _ _ region => plan.other_region region) safe

theorem Plan.read_token (plan : Plan p token initialHeap) : plan.state.index.read=token.val := plan.state.index.read_correct

theorem Plan.read_caches (plan : Plan p token initialHeap) : plan.state.readCaches=InitialState.caches p.graph.stages :=
  TokenAutoregressiveMemory.State.caches_eq plan.state

structure Initialized (p : Pipeline) where
  state : TokenAutoregressiveMemory.State p 0
  parameters : TokenParameterMemory.Storage p state.index.bytes

def fromStorage (original : TokenParameterMemory.Storage p initialHeap) (plan : Plan p token initialHeap)
    (safe : original.Protected plan.Safe) : Initialized p := ⟨plan.state,plan.parameters original safe⟩

theorem initialize_token (original : TokenParameterMemory.Storage p initialHeap) (plan : Plan p token initialHeap)
    (safe : original.Protected plan.Safe) : (fromStorage original plan safe).state.index.read=token.val := plan.read_token

theorem initialize_caches (original : TokenParameterMemory.Storage p initialHeap) (plan : Plan p token initialHeap)
    (safe : original.Protected plan.Safe) :
    (fromStorage original plan safe).state.readCaches=InitialState.caches p.graph.stages := plan.read_caches

end Inference.Models.Qwen.TokenInitializationMemory
