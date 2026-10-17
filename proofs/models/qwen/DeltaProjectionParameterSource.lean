import models.qwen.DeltaNormalizedConstruction
namespace Inference.Models.Qwen.DeltaProjectionParameterSource
open Contracts.Mlx Layers
set_option maxRecDepth 10000

def weights {steps groups : Nat} {p : AffineVerifyLinear.Projection steps (4*groups)}
    {input : Fin (steps*512)→ArrayStorage.BF} (execution : AffineMemory.Execution p input) : AffineDevice.Storage p :=
  match p with | .bits3 _ => execution.weights | .bits4 _ => execution.weights

def Framed (p : AffineVerifyLinear.Projection steps rows) (original current : AffineDevice.Storage p) : Prop :=
  ∃ memory, ∃ same : AffineMemoryFrames.Stable p original memory,
    current=AffineMemoryFrames.reframe p original memory same

private theorem fromStorage_weights {steps groups : Nat} (p : AffineVerifyLinear.Projection steps (4*groups))
    (input : Fin (steps*512)→ArrayStorage.BF) (original : AffineDevice.Storage p)
    (source : ArrayStorage.BFBuffer input) (shared : AffineMemory.Shared p original source.bytes)
    (base : Nat) (aligned : base%2=0) (bounded : base+2*(4*groups)≤2^64)
    (inputSafe : MemoryRegions.Disjoint base (2*(4*groups)) source.base (2*(steps*512)))
    (safe : AffineMemory.Separate p original base (2*(4*groups))) :
    weights (AffineMemory.fromStorage p input original source shared base aligned bounded inputSafe safe)=original := by
  cases p <;> rfl

-- Each physical parameter bundle is a frame of the caller's original bytes.
-- Stable includes every packed byte and every BF16 scale/bias byte, not just
-- equality of a decoded numerical result.
theorem qkv_origin (layer : DeltaNet.Layer) (input : Fin 5120→ArrayStorage.BF)
    (source : ArrayStorage.BFBuffer input) (w : DeltaAffineConstruction.Weights layer source.bytes)
    (regions : DeltaAffineConstruction.Regions) (allocation : DeltaAffineConstruction.Allocation regions source w) :
    Framed layer.qkv w.qkv (weights (DeltaAffineConstruction.fromStorage layer input source w regions allocation).qkv) := by
  unfold DeltaAffineConstruction.fromStorage
  rw [fromStorage_weights]
  exact ⟨_,_,rfl⟩

theorem z_origin (layer : DeltaNet.Layer) (input : Fin 5120→ArrayStorage.BF)
    (source : ArrayStorage.BFBuffer input) (w : DeltaAffineConstruction.Weights layer source.bytes)
    (regions : DeltaAffineConstruction.Regions) (allocation : DeltaAffineConstruction.Allocation regions source w) :
    Framed layer.z w.z (weights (DeltaAffineConstruction.fromStorage layer input source w regions allocation).z) := by
  unfold DeltaAffineConstruction.fromStorage
  rw [fromStorage_weights]
  exact ⟨_,_,rfl⟩

theorem a_origin (layer : DeltaNet.Layer) (input : Fin 5120→ArrayStorage.BF)
    (source : ArrayStorage.BFBuffer input) (w : DeltaAffineConstruction.Weights layer source.bytes)
    (regions : DeltaAffineConstruction.Regions) (allocation : DeltaAffineConstruction.Allocation regions source w) :
    Framed layer.a w.a (weights (DeltaAffineConstruction.fromStorage layer input source w regions allocation).a) := by
  unfold DeltaAffineConstruction.fromStorage
  rw [fromStorage_weights]
  exact ⟨_,_,rfl⟩

theorem b_origin (layer : DeltaNet.Layer) (input : Fin 5120→ArrayStorage.BF)
    (source : ArrayStorage.BFBuffer input) (w : DeltaAffineConstruction.Weights layer source.bytes)
    (regions : DeltaAffineConstruction.Regions) (allocation : DeltaAffineConstruction.Allocation regions source w) :
    Framed layer.b w.b (weights (DeltaAffineConstruction.fromStorage layer input source w regions allocation).b) := by
  unfold DeltaAffineConstruction.fromStorage
  rw [fromStorage_weights]
  exact ⟨_,_,rfl⟩

private theorem stable_trans (p : AffineVerifyLinear.Projection steps rows) (original : AffineDevice.Storage p)
    (first second : ByteMemory.Bytes) (one : AffineMemoryFrames.Stable p original first)
    (two : AffineMemoryFrames.Stable p (AffineMemoryFrames.reframe p original first one) second) :
    AffineMemoryFrames.Stable p original second := by
  cases p <;> exact ⟨fun i h=>(two.packed i h).trans (one.packed i h),
    fun i h=>(two.scales i h).trans (one.scales i h),fun i h=>(two.biases i h).trans (one.biases i h)⟩

theorem trans (p : AffineVerifyLinear.Projection steps rows) (a b c : AffineDevice.Storage p)
    (first : Framed p a b) (second : Framed p b c) : Framed p a c := by
  obtain ⟨memory1,same1,rfl⟩ := first
  obtain ⟨memory2,same2,rfl⟩ := second
  refine ⟨memory2,stable_trans p a memory1 memory2 same1 same2,?_⟩
  cases p <;> rfl

theorem bases {p : AffineVerifyLinear.Projection steps rows} {original current : AffineDevice.Storage p}
    (frame : Framed p original current) :
    (DeltaAffineConstruction.buffers p current).packedBase=(DeltaAffineConstruction.buffers p original).packedBase ∧
    (DeltaAffineConstruction.buffers p current).scaleBase=(DeltaAffineConstruction.buffers p original).scaleBase ∧
    (DeltaAffineConstruction.buffers p current).biasBase=(DeltaAffineConstruction.buffers p original).biasBase := by
  obtain ⟨memory,same,rfl⟩ := frame
  cases p <;> exact ⟨rfl,rfl,rfl⟩
end Inference.Models.Qwen.DeltaProjectionParameterSource
