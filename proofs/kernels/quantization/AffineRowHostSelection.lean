import kernels.quantization.AffineOutputSource

namespace Inference.Kernels.Quantization.AffineRowHostSelection
open Contracts.Mlx
set_option maxRecDepth 10000
attribute [local irreducible] AffineOutputSource.rowBase

-- Reviewed translation of affineRowEligible and affineRow's launch, not a
-- TypeScript frontend proof. Array descriptors, row-contiguous preparation,
-- device limits and the model's choice of wrapper remain native boundaries.
structure Metadata where
  rows : Nat
  weightRank : Nat
  scaleRows : Nat
  scaleGroups : Nat
  inputWidth : Nat
  inputSize : Nat
  bits : Nat
  groupSize : Nat
  mode : String
  deriving DecidableEq, Repr

def eligible (m : Metadata) : Bool :=
  m.mode=="affine" && m.groupSize==64 && (m.bits==3 || m.bits==4) &&
    m.rows==1 && (m.scaleGroups*64)%512==0 && m.scaleGroups*64≤7680 &&
    m.scaleRows%(4*16)==0 && m.weightRank==2

structure Launch where
  width : Nat
  outputRows : Nat
  bits : Nat
  gridX : Nat
  gridY : Nat
  gridZ : Nat
  groupX : Nat
  groupY : Nat
  groupZ : Nat
  rowsPerSimd : Nat
  simdsPerGroup : Nat
  deriving DecidableEq, Repr

-- Natural-number division agrees with host Number arithmetic on the exact
-- positive, integral shapes below. Invalid/mismatched descriptors are outside
-- this translation, rather than silently repaired by an integer quotient.
def launch (m : Metadata) : Launch :=
  ⟨m.inputWidth,m.scaleRows,m.bits,32,m.scaleRows/4,1,32,16,1,4,16⟩

def metadata (steps blocks bits : Nat) : Metadata :=
  ⟨1,2,blocks*64,steps*8,steps*512,steps*512,bits,64,"affine"⟩

theorem selected (steps blocks : Nat) (limit : steps≤15) (bits : Nat) (supported : bits=3 ∨ bits=4) :
    eligible (metadata steps blocks bits)=true := by
  have k : steps*8*64=steps*512 := by omega
  have bounded : steps*512≤7680 := by omega
  rcases supported with rfl|rfl <;> simp [eligible,metadata,k,bounded]

theorem selected_launch (steps blocks bits : Nat) :
    launch (metadata steps blocks bits)=⟨steps*512,blocks*64,bits,32,blocks*16,1,32,16,1,4,16⟩ := by
  simp [launch,metadata]
  omega

theorem exact_metadata (steps blocks bits : Nat) (positive : 0<steps) (limit : steps≤15)
    (rowsBound : blocks≤3880) :
    (metadata steps blocks bits).inputSize/(metadata steps blocks bits).inputWidth=1 ∧
    (metadata steps blocks bits).inputWidth=(metadata steps blocks bits).scaleGroups*64 ∧
    (metadata steps blocks bits).inputWidth<2^53 ∧
    (metadata steps blocks bits).scaleRows<2^53 := by
  dsimp [metadata]
  have sizePositive : 0<steps*512 := by omega
  exact ⟨Nat.div_self sizePositive,by omega,by omega,by omega⟩

-- All sixteen SIMD groups are live. This excludes the upstream eight-row
-- launch and small projections (such as Delta's 48-row a/b projections).
def group (block : Fin blocks) (simd : Fin 16) : Fin (blocks*16) :=
  ⟨block.val*16+simd.val,by have := block.isLt; have := simd.isLt; omega⟩

theorem complete_group (value : Fin (blocks*16)) :
    ∃ block : Fin blocks, ∃ simd : Fin 16, group block simd=value := by
  refine ⟨⟨value.val/16,by have := value.isLt; omega⟩,⟨value.val%16,by omega⟩,?_⟩
  apply Fin.ext
  dsimp [group]
  omega

theorem unique_group (a b : Fin blocks) (s t : Fin 16) (same : group a s=group b t) : a=b ∧ s=t := by
  have equal := congrArg Fin.val same
  have := s.isLt; have := t.isLt
  dsimp [group] at equal
  constructor <;> apply Fin.ext <;> omega

theorem native_coordinates (block : Fin blocks) (simd : Fin 16) :
    (group block simd).val/16=block.val ∧ (group block simd).val%16=simd.val := by
  have := simd.isLt
  dsimp [group]
  omega

theorem parsed_row_base (rowsBound : blocks≤3880) (block : Fin blocks) (simd : Fin 16) :
    AffineOutputSource.rowBase (BitVec.ofNat 32 block.val) simd=some ((block.val*16+simd.val)*4:Int) := by
  have derived := AffineOutputSource.row_base (groups:=blocks*16) (by omega) (group block simd)
  have coordinates := native_coordinates block simd
  have sameSimd : AffineOutputSource.simd (group block simd)=simd := Fin.ext coordinates.2
  rw [sameSimd] at derived
  unfold AffineOutputSource.block at derived
  rw [coordinates.1] at derived
  convert derived using 1
  dsimp [group]
  ring

theorem complete_rows (row : Fin (blocks*64)) :
    ∃ block : Fin blocks, ∃ simd : Fin 16, ∃ offset : Fin 4,
      (block.val*16+simd.val)*4+offset.val=row.val := by
  obtain ⟨block,simd,offset,equal⟩ := AffineLayout.output_owner row
  exact ⟨block,simd,offset,congrArg Fin.val equal⟩

theorem small_projection_excluded (bits : Nat) :
    eligible ⟨1,2,48,80,5120,5120,bits,64,"affine"⟩=false := by
  simp [eligible]

theorem head_selected : eligible (metadata 10 3880 4)=true ∧
    launch (metadata 10 3880 4)=⟨5120,248320,4,32,62080,1,32,16,1,4,16⟩ := by
  decide +kernel

end Inference.Kernels.Quantization.AffineRowHostSelection
