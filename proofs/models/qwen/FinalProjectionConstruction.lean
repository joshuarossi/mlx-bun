import models.qwen.NormalizationMemory
import layers.AffineMemoryFrames

namespace Inference.Models.Qwen.FinalProjectionConstruction
open Contracts.Mlx Layers
set_option maxRecDepth 10000

variable {norm : Blocks.Norm} {projection : AffineVerifyLinear.Projection 10 248320}
  {input : Fin 5120 → ArrayStorage.BF}

structure Storage (norm : Blocks.Norm) (projection : AffineVerifyLinear.Projection 10 248320)
    (input : Fin 5120 → ArrayStorage.BF) where
  source : ArrayStorage.BFBuffer input
  normWeights : ArrayStorage.BFBuffer norm.weight
  normShared : normWeights.bytes=source.bytes
  outputWeights : AffineDevice.Storage projection
  outputShared : AffineMemory.Shared projection outputWeights source.bytes

def fromFrame (before : ByteMemory.Bytes) (source : ArrayStorage.BFBuffer input)
    (region : Nat → Nat → Prop)
    (frame : ∀ base size, region base size → ∀ offset < size, source.bytes (base+offset)=before (base+offset))
    (normWeights : ArrayStorage.BFBuffer norm.weight) (normShared : normWeights.bytes=before)
    (outputWeights : AffineDevice.Storage projection) (outputShared : AffineMemory.Shared projection outputWeights before)
    (normSafe : region normWeights.base 10240)
    (outputSafe : AffineMemoryFrames.Protected projection outputWeights region) : Storage norm projection input where
  source := source
  normWeights := ArrayFrame.bf normWeights source.bytes
    (fun offset bound => (frame _ _ normSafe offset bound).trans (congrFun normShared _).symm)
  normShared := rfl
  outputWeights := AffineMemoryFrames.reframe projection outputWeights source.bytes
    (AffineMemoryFrames.stable projection outputWeights before source.bytes outputShared
      (AffineMemoryFrames.protected_mono projection outputWeights (fun _ _ safe => frame _ _ safe) outputSafe))
  outputShared := AffineMemoryFrames.reframe_shared _ _ _ _

structure Allocation (storage : Storage norm projection input) where
  normBase : Nat
  normBounded : 2*normBase+10240≤2^64
  normSource : storage.source.base/2=normBase ∨ MemoryRegions.Disjoint storage.source.base 10240 (2*normBase) 10240
  normWeights : MemoryRegions.Disjoint (2*normBase) 10240 storage.normWeights.base 10240
  normOutputWeights : AffineMemoryFrames.Protected projection storage.outputWeights (MemoryRegions.Disjoint (2*normBase) 10240)
  outputBase : Nat
  outputAligned : outputBase%2=0
  outputBounded : outputBase+496640≤2^64
  outputSource : MemoryRegions.Disjoint outputBase 496640 (2*normBase) 10240
  outputWeights : AffineMemory.Separate projection storage.outputWeights outputBase 496640

variable (storage : Storage norm projection input) (allocation : Allocation storage)

def normInput : BinaryMemory.Input input norm.weight := ⟨storage.source,storage.normWeights,storage.normShared⟩

def normalization : NormalizationMemory.Execution norm (normInput storage) :=
  NormalizationMemory.fromStorage norm storage.source storage.normWeights storage.normShared allocation.normBase
    allocation.normBounded allocation.normSource allocation.normWeights

def normalized : ArrayStorage.BFBuffer (norm.forward input) := NormalizationMemory.forwardBuffer (normalization storage allocation)

theorem normalized_base : (normalized storage allocation).base=2*allocation.normBase :=
  NormalizationMemory.forward_base _

theorem normalized_frame {base size : Nat} (safe : MemoryRegions.Disjoint (2*allocation.normBase) 10240 base size)
    (offset : Nat) (bound : offset<size) :
    (normalized storage allocation).bytes (base+offset)=storage.source.bytes (base+offset) := by
  rw [normalized, NormalizationMemory.forward_bytes]
  exact (normalization storage allocation).other_region safe offset bound

def weightsAfter : AffineDevice.Storage projection :=
  AffineMemoryFrames.reframe projection storage.outputWeights (normalized storage allocation).bytes
    (AffineMemoryFrames.stable projection storage.outputWeights storage.source.bytes (normalized storage allocation).bytes
      storage.outputShared (AffineMemoryFrames.protected_mono projection storage.outputWeights
        (fun _ _ region => normalized_frame storage allocation region) allocation.normOutputWeights))

theorem weights_shared : AffineMemory.Shared projection (weightsAfter storage allocation) (normalized storage allocation).bytes :=
  AffineMemoryFrames.reframe_shared _ _ _ _

theorem weights_separate : AffineMemory.Separate projection (weightsAfter storage allocation) allocation.outputBase 496640 := by
  cases projection <;> exact ⟨allocation.outputWeights.packed,allocation.outputWeights.scales,allocation.outputWeights.biases⟩

def output : AffineMemory.Execution (groups := 62080) projection (norm.forward input) :=
  AffineMemory.fromStorage (steps := 10) (groups := 62080) projection (norm.forward input) (weightsAfter storage allocation) (normalized storage allocation)
    (weights_shared storage allocation) allocation.outputBase allocation.outputAligned allocation.outputBounded
    (by
      change MemoryRegions.Disjoint allocation.outputBase 496640 (normalized storage allocation).base 10240
      rw [normalized_base]
      exact allocation.outputSource) (weights_separate storage allocation)

theorem output_source : (output storage allocation).source=normalized storage allocation :=
  AffineMemory.source_fromStorage _ _ _ _ _ _ _ _

theorem output_eq : (output storage allocation).output=projection.forward (norm.forward input) :=
  (output storage allocation).output_eq

theorem output_base : (output storage allocation).base=allocation.outputBase := by
  cases projection <;> rfl

theorem other_region {base size : Nat}
    (normSafe : MemoryRegions.Disjoint (2*allocation.normBase) 10240 base size)
    (outputSafe : MemoryRegions.Disjoint allocation.outputBase 496640 base size)
    (offset : Nat) (bound : offset<size) :
    (output storage allocation).outputBuffer.bytes (base+offset)=storage.source.bytes (base+offset) := by
  have same := (output storage allocation).other_region (by rw [output_base]; exact outputSafe) offset bound
  exact same.trans ((congrArg (fun buffer => buffer.bytes (base+offset)) (output_source storage allocation)).trans
    (normalized_frame storage allocation normSafe offset bound))

end Inference.Models.Qwen.FinalProjectionConstruction
