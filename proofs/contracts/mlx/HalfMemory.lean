import contracts.mlx.ByteMemory

namespace Inference.Contracts.Mlx.HalfMemory

abbrev Bytes := ByteMemory.Bytes
abbrev Words := Nat → BitVec 16
abbrev Store := MemoryCells.Store (BitVec 16)

def byte (value : BitVec 16) (index : Nat) : BitVec 8 := value.extractLsb' (8*index) 8
def load (memory : Bytes) (address : Nat) : BitVec 16 := memory (address+1) ++ memory (address+0)
def encode (memory : Words) : Bytes := fun address => byte (memory (address/2)) (address%2)
def view (memory : Bytes) : Words := fun word => load memory (2*word)

theorem join_bytes (value : BitVec 16) : byte value 1 ++ byte value 0=value := by
  unfold byte
  rw [BitVec.extractLsb'_append_extractLsb'_eq_extractLsb' (by decide)]
  exact BitVec.extractLsb'_eq_self

theorem byte_load (memory : Bytes) (address offset : Nat) (bound : offset<2) :
    byte (load memory address) offset=memory (address+offset) := by
  rcases (show offset=0 ∨ offset=1 by omega) with rfl | rfl
  all_goals
    apply BitVec.eq_of_getLsbD_eq
    intro bit hb
    simp only [byte, load, BitVec.getLsbD_extractLsb', BitVec.getLsbD_append]
  · simp [hb]
  · simp [hb, show ¬8+bit<8 by omega]

theorem encode_byte (memory : Words) (word offset : Nat) (bound : offset<2) :
    encode memory (2*word+offset)=byte (memory word) offset := by
  unfold encode
  rw [show (2*word+offset)/2=word by omega, show (2*word+offset)%2=offset by omega]

theorem load_encode (memory : Words) (address : Nat) (aligned : address%2=0) :
    load (encode memory) address=memory (address/2) := by
  apply (congrArg (load (encode memory)) (show address=2*(address/2) by omega)).trans
  unfold load
  rw [encode_byte memory _ 0 (by decide), encode_byte memory _ 1 (by decide)]
  exact join_bytes _

theorem view_encode (memory : Words) : view (encode memory)=memory := by
  funext word
  unfold view
  rw [load_encode _ _ (by omega), show 2*word/2=word by omega]

theorem encode_view (memory : Bytes) : encode (view memory)=memory := by
  funext address
  unfold encode view
  rw [byte_load _ _ _ (by omega), show 2*(address/2)+address%2=address by omega]

def store (memory : Bytes) (address : Nat) (value : BitVec 16) : Bytes :=
  fun atByte => if address ≤ atByte ∧ atByte<address+2 then byte value (atByte-address) else memory atByte

theorem store_encode (memory : Words) (write : Store) :
    store (encode memory) (2*write.word) write.value=encode (MemoryCells.write memory write) := by
  funext address
  by_cases hit : address/2=write.word
  · have inside : 2*write.word ≤ address ∧ address<2*write.word+2 := by omega
    have offset : address-2*write.word=address%2 := by omega
    simp [store, inside, offset, encode, MemoryCells.write, hit]
  · have outside : ¬(2*write.word ≤ address ∧ address<2*write.word+2) := by omega
    simp only [store, outside, ite_false, encode, MemoryCells.write, hit]

def execute : List Store → Bytes → Bytes
  | [], memory => memory
  | write::rest, memory => execute rest (store memory (2*write.word) write.value)

theorem execute_encode (writes : List Store) (memory : Words) :
    execute writes (encode memory)=encode (MemoryCells.execute writes memory) := by
  induction writes generalizing memory with
  | nil => rfl
  | cons write rest ih =>
    rw [execute, store_encode, ih]
    rfl

theorem execute_view (writes : List Store) (memory : Bytes) :
    view (execute writes memory)=MemoryCells.execute writes (view memory) := by
  calc
    _ = view (execute writes (encode (view memory))) := congrArg (fun m => view (execute writes m)) (encode_view memory).symm
    _ = _ := by rw [execute_encode, view_encode]

theorem execute_load (writes : List Store) (memory : Bytes) (address : Nat) (aligned : address%2=0) :
    load (execute writes memory) address=MemoryCells.execute writes (view memory) (address/2) := by
  have same := congrFun (execute_view writes memory) (address/2)
  change load (execute writes memory) (2*(address/2))=_ at same
  rwa [show 2*(address/2)=address by omega] at same

end Inference.Contracts.Mlx.HalfMemory
