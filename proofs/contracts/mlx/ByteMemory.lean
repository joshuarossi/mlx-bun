import contracts.mlx.MemoryCells

namespace Inference.Contracts.Mlx.ByteMemory

abbrev Bytes := Nat → BitVec 8
abbrev Words := Nat → BitVec 32
abbrev Store := MemoryCells.Store (BitVec 32)

-- Explicit little-endian storage. The representation proof does not assume
-- a native typed load or turn arbitrary bit patterns into floating values.
def byte (value : BitVec 32) (index : Nat) : BitVec 8 := value.extractLsb' (8*index) 8
def join (a b c d : BitVec 8) : BitVec 32 := ((d ++ c) ++ b) ++ a

theorem join_bytes (value : BitVec 32) :
    join (byte value 0) (byte value 1) (byte value 2) (byte value 3)=value := by
  unfold join byte
  rw [BitVec.extractLsb'_append_extractLsb'_eq_extractLsb' (by decide),
    BitVec.extractLsb'_append_extractLsb'_eq_extractLsb' (by decide),
    BitVec.extractLsb'_append_extractLsb'_eq_extractLsb' (by decide)]
  simp

def encode (memory : Words) : Bytes := fun address => byte (memory (address/4)) (address%4)
def load32 (memory : Bytes) (address : Nat) : BitVec 32 :=
  join (memory (address+0)) (memory (address+1)) (memory (address+2)) (memory (address+3))

theorem byte_load32 (memory : Bytes) (address offset : Nat) (bound : offset<4) :
    byte (load32 memory address) offset=memory (address+offset) := by
  rcases (show offset=0 ∨ offset=1 ∨ offset=2 ∨ offset=3 by omega) with rfl | rfl | rfl | rfl
  all_goals
    apply BitVec.eq_of_getLsbD_eq
    intro bit hb
    simp only [byte, load32, join, BitVec.getLsbD_extractLsb', BitVec.getLsbD_append]
  · simp [hb]
  · simp [hb, show ¬8+bit<8 by omega]
  · simp [hb, show ¬16+bit<8 by omega, show 16+bit-8=8+bit by omega, show ¬8+bit<8 by omega]
  · simp [hb, show ¬24+bit<8 by omega, show 24+bit-8=16+bit by omega,
      show ¬16+bit<8 by omega, show 16+bit-8=8+bit by omega, show ¬8+bit<8 by omega]

theorem encode_byte (memory : Words) (word offset : Nat) (bound : offset<4) :
    encode memory (4*word+offset)=byte (memory word) offset := by
  unfold encode
  rw [show (4*word+offset)/4=word by omega, show (4*word+offset)%4=offset by omega]

theorem load32_encode (memory : Words) (address : Nat) (aligned : address%4=0) :
    load32 (encode memory) address=memory (address/4) := by
  have same : address=4*(address/4) := by omega
  apply (congrArg (load32 (encode memory)) same).trans
  unfold load32
  rw [encode_byte memory _ 0 (by decide), encode_byte memory _ 1 (by decide),
    encode_byte memory _ 2 (by decide), encode_byte memory _ 3 (by decide)]
  exact join_bytes _

def store32 (memory : Bytes) (address : Nat) (value : BitVec 32) : Bytes :=
  fun atByte => if address ≤ atByte ∧ atByte<address+4 then byte value (atByte-address) else memory atByte

theorem store32_encode (memory : Words) (store : Store) :
    store32 (encode memory) (4*store.word) store.value=encode (MemoryCells.write memory store) := by
  funext address
  by_cases hit : address/4=store.word
  · have inside : 4*store.word ≤ address ∧ address<4*store.word+4 := by omega
    have offset : address-4*store.word=address%4 := by omega
    simp only [store32, inside, ite_true, offset, encode, MemoryCells.write, hit]
    simp
  · have outside : ¬(4*store.word ≤ address ∧ address<4*store.word+4) := by omega
    simp only [store32, outside, ite_false, encode, MemoryCells.write, hit]

def execute : List Store → Bytes → Bytes
  | [], memory => memory
  | store::rest, memory => execute rest (store32 memory (4*store.word) store.value)

theorem execute_encode (stores : List Store) (memory : Words) :
    execute stores (encode memory)=encode (MemoryCells.execute stores memory) := by
  induction stores generalizing memory with
  | nil => rfl
  | cons store rest ih =>
    rw [execute, store32_encode, ih]
    rfl

theorem execute_load32 (stores : List Store) (memory : Words) (address : Nat) (aligned : address%4=0) :
    load32 (execute stores (encode memory)) address=MemoryCells.execute stores memory (address/4) := by
  rw [execute_encode, load32_encode _ address aligned]

def view (memory : Bytes) : Words := fun word => load32 memory (4*word)

theorem view_encode (memory : Words) : view (encode memory)=memory := by
  funext word
  unfold view
  rw [load32_encode _ _ (by omega), show 4*word/4=word by omega]

theorem encode_view (memory : Bytes) : encode (view memory)=memory := by
  funext address
  unfold encode view
  rw [byte_load32 _ _ _ (by omega), show 4*(address/4)+address%4=address by omega]

theorem view_execute (stores : List Store) (memory : Words) :
    view (execute stores (encode memory))=MemoryCells.execute stores memory := by
  rw [execute_encode, view_encode]

theorem view_execute_bytes (stores : List Store) (memory : Bytes) :
    view (execute stores memory)=MemoryCells.execute stores (view memory) := by
  calc
    _ = view (execute stores (encode (view memory))) := congrArg (fun m => view (execute stores m)) (encode_view memory).symm
    _ = _ := view_execute stores (view memory)

theorem execute_bytes_load32 (stores : List Store) (memory : Bytes) (address : Nat) (aligned : address%4=0) :
    load32 (execute stores memory) address=MemoryCells.execute stores (view memory) (address/4) := by
  have same := congrFun (view_execute_bytes stores memory) (address/4)
  change load32 (execute stores memory) (4*(address/4))=_ at same
  rwa [show 4*(address/4)=address by omega] at same

theorem store32_frame (memory : Bytes) (address other : Nat) (value : BitVec 32)
    (outside : other<address ∨ address+4 ≤ other) : store32 memory address value other=memory other := by
  apply ite_eq_right
  omega

end Inference.Contracts.Mlx.ByteMemory
