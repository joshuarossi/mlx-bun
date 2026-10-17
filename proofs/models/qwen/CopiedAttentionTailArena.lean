import kernels.attention.SdpaWorkspace
import models.qwen.AttentionTailAllocation
import models.qwen.ResidualDeltaHighWater

namespace Inference.Models.Qwen.CopiedAttentionTailArena
open Contracts.Mlx Kernels.Attention State Layers
open ResidualDeltaHighWater (Before Frontier fresh)
set_option maxRecDepth 10000
set_option maxHeartbeats 800000

-- A monotone proof frontier is not an allocator or a peak-memory claim.
def bytes (arch : Char) (steps : Nat) : Nat :=
  SdpaWorkspace.bytes (SdpaDispatched.blockCount arch steps)+AttentionTailAllocation.bytes

def next (frontier : Frontier) (arch : Char) (steps : Nat) : Frontier where
  cursor := frontier.cursor+bytes arch steps
  aligned := by
    have := frontier.aligned
    dsimp [bytes,SdpaWorkspace.bytes,AttentionTailAllocation.bytes]
    omega

variable {steps : Nat} {query gate : OutputGateDevice.Heads} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {arch : Char}
  {projection : AffineVerifyLinear.Projection 12 5120}

structure Live (input : SdpaMemory.Input query cache)
    (gates : ∀ head, ArrayStorage.BFBuffer (gate head))
    (weights : AffineDevice.Storage projection) (frontier : Frontier) : Prop where
  keys : Before frontier.cursor input.cache.layout.keyBase (KvRegions.bytes steps)
  values : Before frontier.cursor input.cache.layout.valueBase (KvRegions.bytes steps)
  queries : ∀ head, Before frontier.cursor (input.query head).base 512
  gates : ∀ head, Before frontier.cursor (gates head).base 512
  weights : AffineMemoryFrames.Protected projection weights (Before frontier.cursor)

variable (frontier : Frontier) (capacity : (next frontier arch steps).cursor≤2^64)
  (gates : ∀ head, ArrayStorage.BFBuffer (gate head))
  (weights : AffineDevice.Storage projection) (live : Live input gates weights frontier)

def workspace : SdpaWorkspace.Workspace input arch where
  base := frontier.cursor
  aligned := by have := frontier.aligned; omega
  bounded := by have := capacity; dsimp [next,bytes] at this; omega
  keysSafe := fresh live.keys
  valuesSafe := fresh live.values
  queriesSafe := fun head => fresh (live.queries head)

def attention (platform : SdpaVector.Platform) (contracted : Bool) :=
  (workspace frontier capacity gates weights live).execution platform contracted

def tailBase : Nat := frontier.cursor+SdpaWorkspace.bytes (SdpaDispatched.blockCount arch steps)

theorem tail_fresh {base size : Nat} (before : Before frontier.cursor base size) :
    MemoryRegions.Disjoint (tailBase (arch:=arch) (steps:=steps) frontier) AttentionTailAllocation.bytes base size := by
  exact Or.inr (by dsimp [Before,tailBase] at *; omega)

variable (platform : SdpaVector.Platform) (contracted : Bool)

theorem attention_safe {base size : Nat} (before : Before frontier.cursor base size) :
    SdpaShared.Safe (attention frontier capacity gates weights live platform contracted) base size :=
  (workspace frontier capacity gates weights live).protect platform contracted (fresh before)

def tailWorkspace : AttentionTailAllocation.Workspace
    (attention frontier capacity gates weights live platform contracted) gates weights where
  base := tailBase (arch:=arch) (steps:=steps) frontier
  aligned := by have := frontier.aligned; dsimp [tailBase,SdpaWorkspace.bytes]; omega
  bounded := by simpa only [next,bytes,tailBase,Nat.add_assoc] using capacity
  attentionSafe := by
    rw [attention,SdpaWorkspace.Workspace.output_base]
    exact Or.inr (by dsimp [tailBase,workspace,SdpaWorkspace.bytes]; omega)
  gatesSafe := fun head => tail_fresh frontier (live.gates head)
  keysSafe := tail_fresh frontier live.keys
  valuesSafe := tail_fresh frontier live.values
  weightsSafe := AffineMemoryFrames.protected_mono projection weights
    (fun _ _ before => ⟨attention_safe frontier capacity gates weights live platform contracted before,
      tail_fresh frontier before⟩) live.weights

variable (gatePlatform : OutputGate.Platform)
  (shared : ∀ head, (gates head).bytes=input.cache.memory)
  (weightShared : AffineMemory.Shared projection weights input.cache.memory)

def execution : AttentionTailMemory.Execution
    (attention frontier capacity gates weights live platform contracted) gate gatePlatform projection :=
  (tailWorkspace frontier capacity gates weights live platform contracted).execution gatePlatform shared
    (fun head => attention_safe frontier capacity gates weights live platform contracted (live.gates head)) weightShared

theorem execution_gates : (execution frontier capacity gates weights live platform contracted gatePlatform shared weightShared).gates=gates := rfl

theorem protect {base size : Nat} (before : Before frontier.cursor base size) :
    AttentionTailMemory.Safe (execution frontier capacity gates weights live platform contracted gatePlatform shared weightShared) base size :=
  (tailWorkspace frontier capacity gates weights live platform contracted).protect gatePlatform shared
    (fun head => attention_safe frontier capacity gates weights live platform contracted (live.gates head)) weightShared
    (attention_safe frontier capacity gates weights live platform contracted before) (tail_fresh frontier before)

theorem other_region {base size : Nat} (before : Before frontier.cursor base size) (offset : Nat) (bound : offset<size) :
    (execution frontier capacity gates weights live platform contracted gatePlatform shared weightShared).buffer.bytes (base+offset)=
      input.cache.memory (base+offset) :=
  (execution frontier capacity gates weights live platform contracted gatePlatform shared weightShared).other_region
    (protect frontier capacity gates weights live platform contracted gatePlatform shared weightShared before) offset bound

end Inference.Models.Qwen.CopiedAttentionTailArena
