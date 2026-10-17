import contracts.mlx.ByteMemory
import FloatLib.Floats.Formats.IEEE754.Native.Model

namespace Inference.Contracts.Mlx.FloatMemory
open M1Max

def bits (value : Float32) : BitVec 32 := value.toBits.toBitVec
def decode (value : BitVec 32) : Float32 := Float32.ofBits ⟨value⟩

-- Only this direction is valid for all represented floating values.
-- Arbitrary raw NaN payloads need not survive decode followed by encode.
theorem decode_bits (value : Float32) : decode (bits value)=value := by
  cases value with
  | ofModel value =>
    change Float32.ofModel (FloatLib.Floats.Formats.BinaryInterchange.Model.toFloat32Model
      (FloatLib.Floats.Formats.BinaryInterchange.Model.ofFloat32Model value))=Float32.ofModel value
    rw [FloatLib.Floats.Formats.BinaryInterchange.Model.toFloat32Model_ofFloat32Model]

def view (memory : ByteMemory.Bytes) : WordMemory := fun word => decode (ByteMemory.view memory word)
def encode (memory : WordMemory) : ByteMemory.Bytes := ByteMemory.encode (fun word => bits (memory word))

theorem view_encode (memory : WordMemory) : view (encode memory)=memory := by
  unfold view encode
  rw [ByteMemory.view_encode]
  funext word
  exact decode_bits _

def encodeStore (store : Memory.Store) : ByteMemory.Store := ⟨store.word, bits store.value⟩
def execute (stores : List Memory.Store) (memory : ByteMemory.Bytes) : ByteMemory.Bytes :=
  ByteMemory.execute (stores.map encodeStore) memory

theorem store_view (memory : ByteMemory.Bytes) (store : Memory.Store) :
    view (ByteMemory.store32 memory (4*store.word) (bits store.value))=Memory.write (view memory) store := by
  have raw : ByteMemory.view (ByteMemory.store32 memory (4*store.word) (bits store.value))=
      MemoryCells.write (ByteMemory.view memory) (encodeStore store) := by
    simpa only [ByteMemory.execute, MemoryCells.execute, encodeStore] using
      ByteMemory.view_execute_bytes [encodeStore store] memory
  funext word
  change decode (ByteMemory.view (ByteMemory.store32 memory (4*store.word) (bits store.value)) word)=_
  rw [raw]
  by_cases hit : word=store.word
  · simp [MemoryCells.write, Memory.write, encodeStore, hit, decode_bits]
  · simp [MemoryCells.write, Memory.write, encodeStore, hit, view]

theorem execute_view (stores : List Memory.Store) (memory : ByteMemory.Bytes) :
    view (execute stores memory)=Memory.execute stores (view memory) := by
  induction stores generalizing memory with
  | nil => rfl
  | cons store rest ih =>
    change view (execute rest (ByteMemory.store32 memory (4*store.word) (bits store.value)))=
      Memory.execute rest (Memory.write (view memory) store)
    rw [ih, store_view]

def load (memory : ByteMemory.Bytes) (address : Nat) : Float32 := decode (ByteMemory.load32 memory address)

theorem load_view (memory : ByteMemory.Bytes) (address : Nat) (aligned : address%4=0) :
    load memory address=view memory (address/4) := by
  exact congrArg (fun a => decode (ByteMemory.load32 memory a)) (show address=4*(address/4) by omega)

theorem execute_load (stores : List Memory.Store) (memory : ByteMemory.Bytes) (address : Nat) (aligned : address%4=0) :
    load (execute stores memory) address=Memory.execute stores (view memory) (address/4) := by
  rw [load_view _ _ aligned, execute_view]

end Inference.Contracts.Mlx.FloatMemory
