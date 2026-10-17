import kernels.trellis.PackedArrayMaterialization
namespace Inference.Kernels.Trellis.PackedArrayDownMaterialization
open Contracts.Mlx Models.Qwen PackedArraySemantics PackedArrayMaterialization
set_option maxRecDepth 10000

theorem down_cell (k lane row : Nat) (valid : k=2 ∨ k=3 ∨ k=4) (laneBound : lane<16)
    (paired virtual : Bool) (rowBound : if paired then row<2 else row=0)
    (index : Nat) (bound : index<PackedArrayDown.count k) :
    PackedArrayDown.localCell paired k lane row virtual index=
      some (.word (if virtual then PackedArrayDown.virtualWord row k lane index else PackedArrayDown.alignedWord row k lane index)) := by
  cases paired with
  | false =>
    have zero : row=0 := rowBound
    subst row
    have closed := PackedArrayDown.tail_closed (widthIndex k valid) ⟨lane,laneBound⟩ virtual
      ⟨index,by simpa only [width_index] using bound⟩
    simpa only [width_index] using closed
  | true =>
    have closed := PackedArrayDown.pair_closed (widthIndex k valid) ⟨lane,laneBound⟩ ⟨row,rowBound⟩ virtual
      ⟨index,by simpa only [width_index] using bound⟩
    simpa only [width_index] using closed

structure Input (k : Nat) where
  valid : k=2 ∨ k=3 ∨ k=4
  codes : CheckpointTrellis.Codes k
  scales : CheckpointTrellis.Scales
  storage : CheckpointTrellisStorage.Storage codes scales

def selectedRow (row0 row1 u : Nat) : Nat := if u=0 then row0 else row1

def Input.bases (_input : Input k) (row0 row1 block : Nat) : String → BitVec 32 := fun name =>
  if name="row0" then BitVec.ofNat 32 (CheckpointTrellisMemory.downIndex row0 block 0 k)
  else if name="row1" then BitVec.ofNat 32 (CheckpointTrellisMemory.downIndex row1 block 0 k) else 0

def Input.globals (input : Input k) : String → Nat → BitVec 32 := fun name index =>
  if name="rowWords" then ByteMemory.load32 input.storage.code.bytes (input.storage.code.base+4*index) else 0

def Input.matrix (input : Input k) : DownExecution.PackedMatrix := CheckpointTrellis.downWords k input.valid input.codes

theorem native_index (row block word k : Nat) (valid : k=2 ∨ k=3 ∨ k=4)
    (rowBound : row<17408) (blockBound : block<20) (wordBound : word<8*k) :
    (BitVec.ofNat 32 (CheckpointTrellisMemory.downIndex row block 0 k)+BitVec.ofNat 32 word).toNat=
      CheckpointTrellisMemory.downIndex row block word k := by
  have arithmetic : CheckpointTrellisMemory.downIndex row block 0 k+word=CheckpointTrellisMemory.downIndex row block word k := by
    unfold CheckpointTrellisMemory.downIndex
    omega
  have bounds := CheckpointTrellisMemory.down_offset_bound row block word k valid rowBound blockBound wordBound
  have total : CheckpointTrellisMemory.downIndex row block word k<2^32 := by
    rcases valid with rfl|rfl|rfl <;> omega
  have baseBound : CheckpointTrellisMemory.downIndex row block 0 k<2^32 := by omega
  have small : word<2^32 := by omega
  rw [BitVec.toNat_add,BitVec.toNat_ofNat,BitVec.toNat_ofNat,Nat.mod_eq_of_lt baseBound,Nat.mod_eq_of_lt small,
    arithmetic,Nat.mod_eq_of_lt total]

theorem Input.source_word (input : Input k) (row0 row1 block u lane index : Nat)
    (row0Bound : row0<17408) (row1Bound : row1<17408) (blockBound : block<20) :
    (PackedArrayDown.sourceWord u k lane index).evaluate (input.bases row0 row1 block) input.globals=
      input.matrix (selectedRow row0 row1 u) block ((lane*(16*k)/32+index)%(8*k)) := by
  have positive : 0<8*k := by rcases input.valid with h|h|h <;> omega
  have wordBound := Nat.mod_lt (lane*(16*k)/32+index) positive
  by_cases zero : u=0
  · rw [PackedArrayDown.sourceWord,ite_eq_left zero]
    change ByteMemory.load32 input.storage.code.bytes (input.storage.code.base+4*
      (BitVec.ofNat 32 (CheckpointTrellisMemory.downIndex row0 block 0 k)+
        BitVec.ofNat 32 ((lane*(16*k)/32+index)%(8*k))).toNat)=_ at ⊢
    rw [native_index row0 block _ k input.valid row0Bound blockBound wordBound]
    simpa only [Input.matrix,selectedRow,zero,ite_true] using
      input.storage.down_source_word input.valid row0 block _ row0Bound blockBound wordBound
  · rw [PackedArrayDown.sourceWord,ite_eq_right zero]
    change ByteMemory.load32 input.storage.code.bytes (input.storage.code.base+4*
      (BitVec.ofNat 32 (CheckpointTrellisMemory.downIndex row1 block 0 k)+
        BitVec.ofNat 32 ((lane*(16*k)/32+index)%(8*k))).toNat)=_ at ⊢
    rw [native_index row1 block _ k input.valid row1Bound blockBound wordBound]
    simpa only [Input.matrix,selectedRow,zero,ite_false] using
      input.storage.down_source_word input.valid row1 block _ row1Bound blockBound wordBound

theorem Input.aligned_word (input : Input k) (row0 row1 block u lane index : Nat)
    (row0Bound : row0<17408) (row1Bound : row1<17408) (blockBound : block<20) :
    (PackedArrayDown.alignedWord u k lane index).evaluate (input.bases row0 row1 block) input.globals=
      DownCodebook.Lane.alignedWord (input.matrix (selectedRow row0 row1 u) block) k lane index := by
  by_cases shifted : k=3 ∧ lane%2=1
  · rw [PackedArrayDown.alignedWord,ite_eq_left shifted,DownCodebook.Lane.alignedWord,ite_eq_left shifted]
    simp only [Word.evaluate]
    rw [input.source_word row0 row1 block u lane index row0Bound row1Bound blockBound,
      input.source_word row0 row1 block u lane (index+1) row0Bound row1Bound blockBound]
    simp only [Nat.add_assoc]
  · rw [PackedArrayDown.alignedWord,ite_eq_right shifted,DownCodebook.Lane.alignedWord,ite_eq_right shifted]
    exact input.source_word row0 row1 block u lane index row0Bound row1Bound blockBound

theorem Input.virtual_word (input : Input k) (row0 row1 block u lane index : Nat)
    (row0Bound : row0<17408) (row1Bound : row1<17408) (blockBound : block<20) :
    (PackedArrayDown.virtualWord u k lane index).evaluate (input.bases row0 row1 block) input.globals=
      Codebook.CodebookWindow.virtualWord
        (DownCodebook.Lane.alignedWord (input.matrix (selectedRow row0 row1 u) block) k lane) index := by
  unfold PackedArrayDown.virtualWord Codebook.CodebookWindow.virtualWord
  split
  · simp only [Word.evaluate]
    rw [input.aligned_word row0 row1 block u lane 0 row0Bound row1Bound blockBound]
  · simp only [Word.evaluate]
    rw [input.aligned_word row0 row1 block u lane (index-1) row0Bound row1Bound blockBound,
      input.aligned_word row0 row1 block u lane index row0Bound row1Bound blockBound]

def Input.arrayCell (input : Input k) (row0 row1 block lane u : Nat) (paired virtual : Bool) (index : Nat) : Option (BitVec 32) :=
  (PackedArrayDown.localCell paired k lane u virtual index).bind (materialize (input.bases row0 row1 block) input.globals)

theorem Input.primary_cell (input : Input k) (row0 row1 block lane u index : Nat) (paired : Bool)
    (row0Bound : row0<17408) (row1Bound : row1<17408) (blockBound : block<20) (laneBound : lane<16)
    (rowBound : if paired then u<2 else u=0) (bound : index<PackedArrayDown.count k) :
    input.arrayCell row0 row1 block lane u paired false index=some
      (DownCodebook.Lane.alignedWord (input.matrix (selectedRow row0 row1 u) block) k lane index) := by
  unfold Input.arrayCell
  rw [down_cell k lane u input.valid laneBound paired false rowBound index bound]
  exact congrArg some (input.aligned_word row0 row1 block u lane index row0Bound row1Bound blockBound)

theorem Input.virtual_cell (input : Input k) (row0 row1 block lane u index : Nat) (paired : Bool)
    (row0Bound : row0<17408) (row1Bound : row1<17408) (blockBound : block<20) (laneBound : lane<16)
    (rowBound : if paired then u<2 else u=0) (bound : index<PackedArrayDown.count k) :
    input.arrayCell row0 row1 block lane u paired true index=some
      (Codebook.CodebookWindow.virtualWord
        (DownCodebook.Lane.alignedWord (input.matrix (selectedRow row0 row1 u) block) k lane) index) := by
  unfold Input.arrayCell
  rw [down_cell k lane u input.valid laneBound paired true rowBound index bound]
  exact congrArg some (input.virtual_word row0 row1 block u lane index row0Bound row1Bound blockBound)

def Input.arrays (input : Input k) (row0 row1 block lane u : Nat) (paired : Bool) : String → Nat → BitVec 32 := fun name index =>
  if name="w" then (input.arrayCell row0 row1 block lane u paired false index).getD 0
  else if name="v" then (input.arrayCell row0 row1 block lane u paired true index).getD 0 else 0

theorem Input.window (input : Input k) (row0 row1 block lane u i : Nat) (paired : Bool)
    (row0Bound : row0<17408) (row1Bound : row1<17408) (blockBound : block<20) (laneBound : lane<16)
    (rowBound : if paired then u<2 else u=0) (column : i<16) :
    CodebookWindowSemantics.executeArrays (input.arrays row0 row1 block lane u paired) (i*k)=some
      (Codebook.CodebookWindow.byteOffset
        (DownCodebook.Lane.alignedWord (input.matrix (selectedRow row0 row1 u) block) k lane) (i*k)) := by
  have bounds := Codebook.CodebookWindow.lane_geometry k i input.valid column
  rw [CodebookWindowSemantics.actual_arrays _ _ (Nat.le_trans bounds.1 (by decide))]
  by_cases test : 2 ≤ (i*k) ∧ (i*k-2)%32+14 ≤ 32
  · rw [CodebookWindowSemantics.expected,ite_eq_left test,Codebook.CodebookWindow.byteOffset,ite_eq_left test]
    change some (((input.arrayCell row0 row1 block lane u paired false ((i*k-2)/32)).getD 0 >>> ((i*k-2)%32)) &&& 16383)=_
    rw [input.primary_cell row0 row1 block lane u _ paired row0Bound row1Bound blockBound laneBound rowBound bounds.2.1]
    rfl
  · rw [CodebookWindowSemantics.expected,ite_eq_right test,Codebook.CodebookWindow.byteOffset,ite_eq_right test]
    change some (((input.arrayCell row0 row1 block lane u paired true ((i*k+14)/32)).getD 0 >>> ((i*k+14)%32)) &&& 16383)=_
    rw [input.virtual_cell row0 row1 block lane u _ paired row0Bound row1Bound blockBound laneBound rowBound bounds.2.2.1]
    rfl
end Inference.Kernels.Trellis.PackedArrayDownMaterialization
