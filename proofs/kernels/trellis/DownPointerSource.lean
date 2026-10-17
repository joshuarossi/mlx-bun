import kernels.trellis.DownPointerSemantics
namespace Inference.Kernels.Trellis.DownPointerSource
open DownPointerSyntax DownPointerSemantics Contracts.Mlx Models.Qwen
set_option maxRecDepth 10000

def execute (pointer : Bool) (text : String) (env : Environment) : Option Value :=
  (parse pointer text).bind (fun code => evaluate env code.value)

theorem stride_selected (k : Nat) (valid : k=2 ∨ k=3 ∨ k=4) :
    execute false strideSource (environment k 0 true)=some (.ulong (BitVec.ofNat 64 (stride k))) := by
  rw [execute,parsed_stride,Option.bind_some]
  have selected:=stride_closed (PackedArrayMaterialization.widthIndex k valid)
  simpa only [PackedArrayMaterialization.width_index] using selected

theorem block_selected (k block : Nat) (valid : k=2 ∨ k=3 ∨ k=4) (blockBound : block<20) (active : Bool) :
    execute true blockSource (environment k block active)=some
      (.pointer (BitVec.ofNat 64 (if active then blockOffset k block else 0))) := by
  rw [execute,parsed_block,Option.bind_some]
  have selected:=block_closed (PackedArrayMaterialization.widthIndex k valid) ⟨block,blockBound⟩ active
  simpa only [PackedArrayMaterialization.width_index] using selected

theorem pair_selected (base stride : BitVec 64) (r0 r u : BitVec 32) :
    execute true pairSource (rowEnvironment base stride r0 r u)=
      some (.pointer (base+BitVec.ofNat 64 (r0+r+u).toNat*stride)) := by
  rw [execute,parsed_pair,Option.bind_some]
  exact pair_evaluate base stride r0 r u

theorem tail_selected (base stride : BitVec 64) (r0 r u : BitVec 32) :
    execute true tailSource (rowEnvironment base stride r0 r u)=
      some (.pointer (base+BitVec.ofNat 64 (r0+r).toNat*stride)) := by
  rw [execute,parsed_tail,Option.bind_some]
  exact tail_evaluate base stride r0 r u

theorem uint_row (r0 r u : Nat) (bound : r0+r+u<17408) :
    (BitVec.ofNat 32 r0+BitVec.ofNat 32 r+BitVec.ofNat 32 u).toNat=r0+r+u := by
  have a : r0<2^32 := by omega
  have b : r<2^32 := by omega
  have c : u<2^32 := by omega
  have ab : r0+r<2^32 := by omega
  have abc : r0+r+u<2^32 := by omega
  simp only [BitVec.toNat_add,BitVec.toNat_ofNat,Nat.mod_eq_of_lt a,Nat.mod_eq_of_lt b,
    Nat.mod_eq_of_lt c,Nat.mod_eq_of_lt ab,Nat.mod_eq_of_lt abc]

def base (k block row : Nat) : BitVec 64 :=
  BitVec.ofNat 64 (blockOffset k block)+BitVec.ofNat 64 row*BitVec.ofNat 64 (stride k)

def prepare (k block r0 r u : Nat) (paired : Bool) : Option Value :=
  (execute false strideSource (environment k 0 true)).bind (fun strideValue =>
    match strideValue with
    | .ulong rowStride =>
      (execute true blockSource (environment k block true)).bind (fun blockValue =>
        match blockValue with
        | .pointer blockBase => execute true (if paired then pairSource else tailSource)
            (rowEnvironment blockBase rowStride (BitVec.ofNat 32 r0) (BitVec.ofNat 32 r) (BitVec.ofNat 32 u))
        | _ => none)
    | _ => none)

theorem prepared_pair (k block r0 r u : Nat) (valid : k=2 ∨ k=3 ∨ k=4)
    (blockBound : block<20) (rowBound : r0+r+u<17408) :
    prepare k block r0 r u true=some (.pointer (base k block (r0+r+u))) := by
  simp only [prepare,stride_selected k valid,Option.bind_some,block_selected k block valid blockBound true,ite_true]
  rw [pair_selected,uint_row r0 r u rowBound]
  rfl

theorem prepared_tail (k block r0 r : Nat) (valid : k=2 ∨ k=3 ∨ k=4)
    (blockBound : block<20) (rowBound : r0+r<17408) :
    prepare k block r0 r 0 false=some (.pointer (base k block (r0+r))) := by
  simp only [prepare,stride_selected k valid,Option.bind_some,block_selected k block valid blockBound true,ite_true,Bool.false_eq_true,ite_false]
  rw [tail_selected]
  have rows := uint_row r0 r 0 (by simpa only [Nat.add_zero] using rowBound)
  simp only [BitVec.add_zero,Nat.add_zero] at rows
  rw [rows]
  rfl

theorem base_index (k block row : Nat) (valid : k=2 ∨ k=3 ∨ k=4)
    (blockBound : block<20) (rowBound : row<17408) :
    (base k block row).toNat=CheckpointTrellisMemory.downIndex row block 0 k := by
  have total:=CheckpointTrellisMemory.down_offset_bound row block 0 k valid rowBound blockBound (by rcases valid with rfl|rfl|rfl <;> decide)
  have small : CheckpointTrellisMemory.downIndex row block 0 k<2^64 := by rcases valid with h|h|h <;> omega
  have formula := original_index row block 0 k
  simp only [Nat.add_zero] at formula
  have offset : blockOffset k block<2^64 := by omega
  have strideBound : stride k<2^64 := by rcases valid with rfl|rfl|rfl <;> decide
  have rowSmall : row<2^64 := by omega
  have product : row*stride k<2^64 := by omega
  simp only [base,BitVec.toNat_add,BitVec.toNat_mul,BitVec.toNat_ofNat,
    Nat.mod_eq_of_lt offset,Nat.mod_eq_of_lt strideBound,Nat.mod_eq_of_lt rowSmall,
    Nat.mod_eq_of_lt product,formula,Nat.mod_eq_of_lt small]

-- Current original code bytes are loaded at the source-derived row pointer;
-- neither the packed words nor the output of the load is an input premise.
theorem current_word (input : PackedArrayDownMaterialization.Input k) (row block word : Nat)
    (rowBound : row<17408) (blockBound : block<20) (wordBound : word<8*k) :
    ByteMemory.load32 input.storage.code.bytes
      (input.storage.code.base+4*((base k block row).toNat+word))=
      input.matrix row block word := by
  rw [base_index k block row input.valid blockBound rowBound]
  have offset : CheckpointTrellisMemory.downIndex row block 0 k+word=
      CheckpointTrellisMemory.downIndex row block word k := by
    unfold CheckpointTrellisMemory.downIndex
    omega
  rw [offset]
  exact input.storage.down_source_word input.valid row block word rowBound blockBound wordBound
def readPrepared (input : PackedArrayDownMaterialization.Input k) (block r0 r u word : Nat) (paired : Bool) : Option (BitVec 32) :=
  (prepare k block r0 r u paired).bind (fun value => match value with
    | .pointer offset => some (ByteMemory.load32 input.storage.code.bytes
        (input.storage.code.base+4*(offset.toNat+word)))
    | _ => none)

theorem pair_current_word (input : PackedArrayDownMaterialization.Input k) (block r0 r u word : Nat)
    (rowBound : r0+r+u<17408) (blockBound : block<20) (wordBound : word<8*k) :
    readPrepared input block r0 r u word true=some (input.matrix (r0+r+u) block word) := by
  rw [readPrepared,prepared_pair k block r0 r u input.valid blockBound rowBound,Option.bind_some]
  exact congrArg some (current_word input (r0+r+u) block word rowBound blockBound wordBound)

theorem tail_current_word (input : PackedArrayDownMaterialization.Input k) (block r0 r word : Nat)
    (rowBound : r0+r<17408) (blockBound : block<20) (wordBound : word<8*k) :
    readPrepared input block r0 r 0 word false=some (input.matrix (r0+r) block word) := by
  rw [readPrepared,prepared_tail k block r0 r input.valid blockBound rowBound,Option.bind_some]
  exact congrArg some (current_word input (r0+r) block word rowBound blockBound wordBound)
end Inference.Kernels.Trellis.DownPointerSource
