import kernels.trellis.DownPointerSource
namespace Inference.Kernels.Trellis.DownPointerArrays
open Contracts.Mlx PackedArrayMaterialization PackedArrayDownMaterialization
set_option maxRecDepth 10000

def sourceBase (k block row : Nat) : Option (BitVec 32) :=
  (DownPointerSource.prepare k block row 0 0 false).bind (fun value => match value with
    | .pointer offset => some (BitVec.ofNat 32 offset.toNat)
    | _ => none)

theorem source_base (k block row : Nat) (valid : k=2 ∨ k=3 ∨ k=4)
    (blockBound : block<20) (rowBound : row<17408) :
    sourceBase k block row=some (BitVec.ofNat 32 (Models.Qwen.CheckpointTrellisMemory.downIndex row block 0 k)) := by
  rw [sourceBase,DownPointerSource.prepared_tail k block row 0 valid blockBound (by simpa only [Nat.add_zero] using rowBound),Option.bind_some]
  simp only [Nat.add_zero]
  rw [DownPointerSource.base_index k block row valid blockBound rowBound]

theorem paired_source_base (k block r0 r u : Nat) (valid : k=2 ∨ k=3 ∨ k=4)
    (blockBound : block<20) (rowBound : r0+r+u<17408) :
    ((DownPointerSource.prepare k block r0 r u true).bind (fun value => match value with
      | .pointer offset => some (BitVec.ofNat 32 offset.toNat)
      | _ => none))=sourceBase k block (r0+r+u) := by
  rw [DownPointerSource.prepared_pair k block r0 r u valid blockBound rowBound,Option.bind_some,
    source_base k block (r0+r+u) valid blockBound rowBound]
  simp only [DownPointerSource.base_index k block (r0+r+u) valid blockBound rowBound]

def bases (k block row0 row1 : Nat) : String → BitVec 32 := fun name =>
  if name="row0" then (sourceBase k block row0).getD 0
  else if name="row1" then (sourceBase k block row1).getD 0 else 0

theorem bases_eq (input : Input k) (block row0 row1 : Nat)
    (blockBound : block<20) (row0Bound : row0<17408) (row1Bound : row1<17408) :
    bases k block row0 row1=input.bases row0 row1 block := by
  funext name
  unfold bases Input.bases
  rw [source_base k block row0 input.valid blockBound row0Bound,
    source_base k block row1 input.valid blockBound row1Bound]
  rfl

def arrayCell (input : Input k) (row0 row1 block lane u : Nat) (paired virtual : Bool) (index : Nat) : Option (BitVec 32) :=
  (PackedArrayDown.localCell paired k lane u virtual index).bind
    (materialize (bases k block row0 row1) input.globals)

theorem array_cell_eq (input : Input k) (row0 row1 block lane u : Nat) (paired virtual : Bool) (index : Nat)
    (row0Bound : row0<17408) (row1Bound : row1<17408) (blockBound : block<20) :
    arrayCell input row0 row1 block lane u paired virtual index=input.arrayCell row0 row1 block lane u paired virtual index := by
  unfold arrayCell Input.arrayCell
  rw [bases_eq input block row0 row1 blockBound row0Bound row1Bound]

def arrays (input : Input k) (row0 row1 block lane u : Nat) (paired : Bool) : String → Nat → BitVec 32 := fun name index =>
  if name="w" then (arrayCell input row0 row1 block lane u paired false index).getD 0
  else if name="v" then (arrayCell input row0 row1 block lane u paired true index).getD 0 else 0

theorem arrays_eq (input : Input k) (row0 row1 block lane u : Nat) (paired : Bool)
    (row0Bound : row0<17408) (row1Bound : row1<17408) (blockBound : block<20) :
    arrays input row0 row1 block lane u paired=input.arrays row0 row1 block lane u paired := by
  funext name index
  unfold arrays Input.arrays
  rw [array_cell_eq input row0 row1 block lane u paired false index row0Bound row1Bound blockBound,
    array_cell_eq input row0 row1 block lane u paired true index row0Bound row1Bound blockBound]

theorem window (input : Input k) (row0 row1 block lane u i : Nat) (paired : Bool)
    (row0Bound : row0<17408) (row1Bound : row1<17408) (blockBound : block<20) (laneBound : lane<16)
    (rowBound : if paired then u<2 else u=0) (column : i<16) :
    CodebookWindowSemantics.executeArrays (arrays input row0 row1 block lane u paired) (i*k)=some
      (Codebook.CodebookWindow.byteOffset
        (DownCodebook.Lane.alignedWord (input.matrix (selectedRow row0 row1 u) block) k lane) (i*k)) := by
  rw [arrays_eq input row0 row1 block lane u paired row0Bound row1Bound blockBound]
  exact input.window row0 row1 block lane u i paired row0Bound row1Bound blockBound laneBound rowBound column
end Inference.Kernels.Trellis.DownPointerArrays
