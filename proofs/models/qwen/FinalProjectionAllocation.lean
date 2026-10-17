import models.qwen.FinalProjectionConstruction

namespace Inference.Models.Qwen.FinalProjectionAllocation
open Contracts.Mlx Layers
set_option maxRecDepth 100000

variable {norm : Blocks.Norm} {projection : AffineVerifyLinear.Projection 10 248320}
  {input : Fin 5120 → ArrayStorage.BF}

def bytes : Nat := 506880

structure Workspace (storage : FinalProjectionConstruction.Storage norm projection input) where
  base : Nat
  aligned : base%4=0
  bounded : base+bytes≤2^64
  sourceSafe : MemoryRegions.Disjoint base bytes storage.source.base 10240
  normSafe : MemoryRegions.Disjoint base bytes storage.normWeights.base 10240
  outputSafe : AffineMemoryFrames.Protected projection storage.outputWeights (MemoryRegions.Disjoint base bytes)

theorem subregion {workspace other size offset count : Nat}
    (safe : MemoryRegions.Disjoint workspace bytes other size) (inside : offset+count≤bytes) :
    MemoryRegions.Disjoint (workspace+offset) count other size := by
  unfold MemoryRegions.Disjoint at *
  omega

variable {storage : FinalProjectionConstruction.Storage norm projection input}
  {other size : Nat}

theorem Workspace.normalization_safe (w : Workspace storage) (safe : MemoryRegions.Disjoint w.base bytes other size) :
    MemoryRegions.Disjoint (2*(w.base/2)) 10240 other size := by
  have aligned := w.aligned
  rw [show 2*(w.base/2)=w.base by omega]
  simpa only [Nat.add_zero] using subregion (offset := 0) (count := 10240) safe (by decide +kernel)

theorem Workspace.output_safe (w : Workspace storage) (safe : MemoryRegions.Disjoint w.base bytes other size) :
    MemoryRegions.Disjoint (w.base+10240) 496640 other size :=
  subregion safe (by decide +kernel : 10240+496640≤bytes)

theorem separate (p : AffineVerifyLinear.Projection steps rows) (weights : AffineDevice.Storage p)
    (safe : AffineMemoryFrames.Protected p weights (MemoryRegions.Disjoint base count)) :
    AffineMemory.Separate p weights base count := by
  cases p <;> exact ⟨safe.1,safe.2.1,safe.2.2⟩

def Workspace.allocation (w : Workspace storage) : FinalProjectionConstruction.Allocation storage where
  normBase := w.base/2
  normBounded := by have := w.bounded; dsimp [bytes] at this; omega
  normSource := Or.inr (MemoryRegions.disjoint_symm (w.normalization_safe w.sourceSafe))
  normWeights := w.normalization_safe w.normSafe
  normOutputWeights := AffineMemoryFrames.protected_mono projection storage.outputWeights
    (fun _ _ safe => w.normalization_safe safe) w.outputSafe
  outputBase := w.base+10240
  outputAligned := by have := w.aligned; omega
  outputBounded := by have := w.bounded; dsimp [bytes] at this; omega
  outputSource := Or.inr (by omega)
  outputWeights := separate projection storage.outputWeights
    (AffineMemoryFrames.protected_mono projection storage.outputWeights (fun _ _ safe => w.output_safe safe) w.outputSafe)

def Workspace.output (w : Workspace storage) := FinalProjectionConstruction.output storage w.allocation

theorem Workspace.output_base (w : Workspace storage) : w.output.base=w.base+10240 :=
  FinalProjectionConstruction.output_base storage w.allocation

theorem Workspace.output_eq (w : Workspace storage) : w.output.output=projection.forward (norm.forward input) :=
  FinalProjectionConstruction.output_eq storage w.allocation

theorem Workspace.other_region (w : Workspace storage) (safe : MemoryRegions.Disjoint w.base bytes other size)
    (offset : Nat) (bound : offset<size) : w.output.outputBuffer.bytes (other+offset)=storage.source.bytes (other+offset) :=
  FinalProjectionConstruction.other_region storage w.allocation (w.normalization_safe safe) (w.output_safe safe) offset bound

theorem footprint : bytes=10240+496640 := by decide +kernel

end Inference.Models.Qwen.FinalProjectionAllocation
