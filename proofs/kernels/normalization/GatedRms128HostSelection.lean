import kernels.normalization.GatedRms128OutputSource

namespace Inference.Kernels.Normalization.GatedRms128HostSelection

-- Reviewed translation of gatedRmsNorm's launch metadata. The caller supplies
-- row-contiguous BF16 input/gate descriptors and the BF16 weight vector.
-- Native descriptor extraction, Float32Array epsilon bitcasting, and Metal
-- compilation/submission remain explicit platform boundaries.
structure Launch where
  inputs : List String
  outputs : List String
  shape : List Nat
  bfloat16 : Bool
  grid : List Nat
  group : List Nat
  templateInts : List (String × Nat)
  deriving DecidableEq,Repr

def threads (width : Nat) : Nat := min 1024 (((width+127)/128)*32)
def launch (shape : List Nat) (size width : Nat) (epsilon : BitVec 32) : Launch :=
  ⟨["x","gate","weight"],["out"],shape,true,
    [size/width*threads width,1,1],[threads width,1,1],
    [("D",width),("THREADS",threads width),("EPS",epsilon.toNat)]⟩

def selected (epsilon : BitVec 32) : Launch := launch [1,1,48,128] 6144 128 epsilon

theorem selected_threads : threads 128=32 := by decide +kernel
theorem selected_launch (epsilon : BitVec 32) :
    selected epsilon=⟨["x","gate","weight"],["out"],[1,1,48,128],true,
      [1536,1,1],[32,1,1],[("D",128),("THREADS",32),("EPS",epsilon.toNat)]⟩ := rfl

theorem selected_geometry (thread : Fin 1536) :
    (GatedRms128OutputSource.head thread).val=thread.val/32 ∧
    (GatedRms128OutputSource.lane thread).val=thread.val%32 ∧
    thread.val/32<48 ∧ thread.val%32<32 ∧
    thread.val/32*32+thread.val%32=thread.val := by
  have := thread.isLt
  dsimp [GatedRms128OutputSource.head,GatedRms128OutputSource.lane]
  omega

theorem selected_index (thread : Fin 1536) (i : Fin 4) :
    GatedRms128OutputSource.offset thread i=thread.val*4+i.val ∧
    GatedRms128OutputSource.offset thread i<6144 := by
  rw [GatedRms128OutputSource.offset_index]
  have := (Contracts.Mlx.CopyContiguous.index thread i).isLt
  exact ⟨rfl,this⟩

end Inference.Kernels.Normalization.GatedRms128HostSelection
