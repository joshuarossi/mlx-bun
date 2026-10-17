import kernels.attention.SdpaSharedConstruction

namespace Inference.Kernels.Attention.SdpaWorkspace
open Contracts.Mlx State
set_option maxRecDepth 100000

-- Each first-pass block stores 24 FP32 sums, 24 FP32 maxima and
-- 24*256 BF16 partials; the final BF16 output follows those arrays.
def bytes (blocks : Nat) : Nat := 12480*blocks+12288

theorem subregion {blocks workspace other size offset count : Nat}
    (safe : MemoryRegions.Disjoint workspace (bytes blocks) other size) (inside : offset+count≤bytes blocks) :
    MemoryRegions.Disjoint (workspace+offset) count other size := by
  unfold MemoryRegions.Disjoint at *
  omega

variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {arch : Char} {other size : Nat}

structure Workspace (input : SdpaMemory.Input query cache) (arch : Char) where
  base : Nat
  aligned : base%4=0
  bounded : base+bytes (SdpaDispatched.blockCount arch steps)≤2^64
  keysSafe : MemoryRegions.Disjoint base (bytes (SdpaDispatched.blockCount arch steps)) input.cache.layout.keyBase (KvRegions.bytes steps)
  valuesSafe : MemoryRegions.Disjoint base (bytes (SdpaDispatched.blockCount arch steps)) input.cache.layout.valueBase (KvRegions.bytes steps)
  queriesSafe : ∀ head, MemoryRegions.Disjoint base (bytes (SdpaDispatched.blockCount arch steps)) (input.query head).base 512

def Workspace.layout (w : Workspace input arch) : SdpaTwoPassMemory.Layout (SdpaDispatched.blockCount arch steps) where
  sumBase := w.base
  maxBase := w.base+96*SdpaDispatched.blockCount arch steps
  outputBase := w.base+192*SdpaDispatched.blockCount arch steps
  sumAligned := w.aligned
  maxAligned := by have := w.aligned; omega
  outputAligned := by have := w.aligned; omega
  sumBounded := by have := w.bounded; dsimp [bytes] at this; omega
  maxBounded := by have := w.bounded; dsimp [bytes] at this; omega
  outputBounded := by have := w.bounded; dsimp [bytes] at this; omega
  sumMax := Or.inl (by omega)
  sumOutput := Or.inl (by omega)
  maxOutput := Or.inl (by omega)

theorem Workspace.temporary_safe (w : Workspace input arch)
    (safe : MemoryRegions.Disjoint w.base (bytes (SdpaDispatched.blockCount arch steps)) other size) :
    SdpaSharedConstruction.TemporarySafe w.layout other size := by
  refine ⟨?_,?_,?_⟩
  · change MemoryRegions.Disjoint w.base (4*(24*SdpaDispatched.blockCount arch steps)) other size
    simpa only [Nat.add_zero] using subregion (offset := 0) (count := 4*(24*SdpaDispatched.blockCount arch steps)) safe (by dsimp [bytes]; omega)
  · exact subregion safe (by dsimp [bytes]; omega)
  · exact subregion safe (by dsimp [bytes]; omega)

theorem Workspace.output_safe (w : Workspace input arch)
    (safe : MemoryRegions.Disjoint w.base (bytes (SdpaDispatched.blockCount arch steps)) other size) :
    MemoryRegions.Disjoint (w.base+12480*SdpaDispatched.blockCount arch steps) 12288 other size :=
  subregion safe (by dsimp [bytes]; omega)

def Workspace.output (w : Workspace input arch) : SdpaSharedConstruction.Output input where
  base := w.base+12480*SdpaDispatched.blockCount arch steps
  aligned := by have := w.aligned; omega
  bounded := by have := w.bounded; dsimp [bytes] at this; omega
  keysSeparate := w.output_safe w.keysSafe
  valuesSeparate := w.output_safe w.valuesSafe

def Workspace.one (w : Workspace input arch) : SdpaSharedConstruction.OneAllocation input :=
  ⟨w.output,.fresh (fun head => w.output_safe (w.queriesSafe head))⟩

def Workspace.two (w : Workspace input arch) : SdpaSharedConstruction.TwoAllocation input arch where
  layout := w.layout
  output := w.output
  mode := .fresh (fun head => w.output_safe (w.queriesSafe head))
  keysSeparate := w.temporary_safe w.keysSafe
  valuesSeparate := w.temporary_safe w.valuesSafe
  queriesSeparate := fun head => w.temporary_safe (w.queriesSafe head)
  outputSeparate := ⟨Or.inl (by dsimp [Workspace.layout,Workspace.output]; omega),
    Or.inl (by dsimp [Workspace.layout,Workspace.output]; omega),
    Or.inl (by dsimp [Workspace.layout,Workspace.output]; omega)⟩

def Workspace.execution (w : Workspace input arch) (p : SdpaVector.Platform) (contracted : Bool) :
    SdpaShared.Execution input p contracted arch :=
  SdpaSharedConstruction.canonical input p contracted arch (fun _ => w.one) (fun _ => w.two)

theorem Workspace.protect (w : Workspace input arch) (p : SdpaVector.Platform) (contracted : Bool)
    (safe : MemoryRegions.Disjoint w.base (bytes (SdpaDispatched.blockCount arch steps)) other size) :
    SdpaShared.Safe (w.execution p contracted) other size := by
  apply (SdpaSharedConstruction.canonical_safe (fun _ => w.one) (fun _ => w.two) other size).mpr
  unfold SdpaSharedConstruction.Safe
  split
  · exact ⟨w.temporary_safe safe,w.output_safe safe⟩
  · exact w.output_safe safe

theorem Workspace.output_base (w : Workspace input arch) (p : SdpaVector.Platform) (contracted : Bool) :
    (w.execution p contracted).base=w.base+12480*SdpaDispatched.blockCount arch steps := by
  rw [Workspace.execution,SdpaSharedConstruction.canonical_base]
  split <;> rfl

theorem Workspace.other_region (w : Workspace input arch) (p : SdpaVector.Platform) (contracted : Bool)
    (safe : MemoryRegions.Disjoint w.base (bytes (SdpaDispatched.blockCount arch steps)) other size)
    (offset : Nat) (bound : offset<size) :
    (w.execution p contracted).memory (other+offset)=input.cache.memory (other+offset) :=
  (w.execution p contracted).other_region (w.protect p contracted safe) offset bound

theorem default_footprint (arch : Char) (steps : Nat) : bytes (SdpaDispatched.blockCount arch steps)≤12791808 := by
  have := SdpaDispatchedDevice.bounded_blocks arch steps
  dsimp [bytes]
  omega

end Inference.Kernels.Attention.SdpaWorkspace
