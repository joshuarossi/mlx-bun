import layers.QuantizedEmbedding
import contracts.mlx.RowStorage
import contracts.mlx.WordArrayWrites
import contracts.mlx.HalfArrayWrites
import contracts.mlx.ArrayViews

namespace Inference.Layers.QuantizedEmbeddingDevice
open Contracts.Mlx Kernels.Quantization
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000

structure Storage (layer : QuantizedEmbedding.Layer) where
  packed : ByteMemory.Bytes
  packedBase : Nat
  aligned : packedBase%4=0
  bounded : packedBase+4*(248320*640) ≤ 2^64
  attached : ∀ token i, ByteMemory.load32 packed (packedBase+4*(token.val*640+i.val))=layer.words token i
  scales : ArrayStorage.BFBuffer (RowStorage.flatten layer.scales)
  biases : ArrayStorage.BFBuffer (RowStorage.flatten layer.biases)

def words (layer : QuantizedEmbedding.Layer) (i : Nat) : BitVec 32 :=
  if h : i<248320*640 then layer.words ⟨i/640, by omega⟩ ⟨i%640, by omega⟩ else 0

def Storage.canonical (layer : QuantizedEmbedding.Layer) : Storage layer where
  packed := ByteMemory.encode (words layer)
  packedBase := 0
  aligned := by decide
  bounded := by decide
  attached := by
    intro token i
    rw [Nat.zero_add, ByteMemory.load32_encode _ _ (by omega), show 4*(token.val*640+i.val)/4=token.val*640+i.val by omega]
    have bound := QuantizedEmbedding.takeRow_bounds 640 token i
    simp only [words, bound, ↓reduceDIte]
    congr 2 <;> omega
  scales := ArrayStorage.BFBuffer.canonical _ (by decide)
  biases := ArrayStorage.BFBuffer.canonical _ (by decide)

variable {layer : QuantizedEmbedding.Layer}

def packedLoads (storage : Storage layer) (token : Fin 248320) (i : Fin 640) : BitVec 32 :=
  ByteMemory.load32 storage.packed (storage.packedBase+4*(token.val*640+i.val))
def parameterLoads {values : Fin 248320 → Fin 80 → BF}
    (source : ArrayStorage.BFBuffer (RowStorage.flatten values)) (token : Fin 248320) (i : Fin 80) : BF :=
  source.read (RowStorage.index token i)

theorem packedLoads_eq (storage : Storage layer) (token : Fin 248320) : packedLoads storage token=layer.words token :=
  funext (storage.attached token)

theorem parameterLoads_eq {values : Fin 248320 → Fin 80 → BF}
    (source : ArrayStorage.BFBuffer (RowStorage.flatten values)) (token : Fin 248320) : parameterLoads source token=values token := by
  funext i
  unfold parameterLoads
  rw [ArrayStorage.BFBuffer.read_correct, RowStorage.flatten_index]

-- gather_front<uint32,...,1> copies packed words. The BF16 parameter
-- instantiations copy two adjacent words per thread, with the same row index.
structure Take (storage : Storage layer) (token : Fin 248320) where
  packed : WordArrayWrites.Trace 0 (packedLoads storage token)
  scales : HalfArrayWrites.Trace 0 (fun i => ArrayStorage.bits (parameterLoads storage.scales token i))
  biases : HalfArrayWrites.Trace 0 (fun i => ArrayStorage.bits (parameterLoads storage.biases token i))

def Take.canonical (storage : Storage layer) (token : Fin 248320) : Take storage token :=
  ⟨WordArrayWrites.Trace.canonical _ (by decide), HalfArrayWrites.Trace.canonical _ (by decide),
    HalfArrayWrites.Trace.canonical _ (by decide)⟩

private theorem word_byte (word : BitVec 32) (offset : Fin 4) :
    ByteMemory.byte word offset.val=(word >>> (8*offset.val)).setWidth 8 := by
  apply BitVec.eq_of_getLsbD_eq
  intro i hi
  simp [ByteMemory.byte, BitVec.getLsbD_ushiftRight, hi, Nat.add_comm]

variable {storage : Storage layer} {token : Fin 248320}

theorem Take.packed_byte (take : Take storage token) (i : Fin 2560) :
    take.packed.memory i.val=QuantizedEmbedding.bytes (layer.words token) i := by
  have copied := take.packed.byte_correct (QuantizedEmbedding.wordByte i) ⟨i.val%4, by omega⟩
  have loaded : packedLoads storage token (QuantizedEmbedding.wordByte i)=layer.words token (QuantizedEmbedding.wordByte i) :=
    storage.attached token (QuantizedEmbedding.wordByte i)
  rw [loaded, word_byte] at copied
  simpa only [QuantizedEmbedding.wordByte, QuantizedEmbedding.bytes, Nat.zero_add, show 4*(i.val/4)+i.val%4=i.val by omega] using copied

@[irreducible] def produced (take : Take storage token) (i : Fin 5120) : BF :=
  AffineDequantize.value layer.contracted (take.scales.buffer.read (AffineDequantize.groupIndex i))
    (take.biases.buffer.read (AffineDequantize.groupIndex i))
    (AffineDequantize.code (take.packed.memory (AffineDequantize.byteIndex i).val) (AffineDequantize.byteCoordinate i))

theorem produced_eq (take : Take storage token) : produced take=layer.forward token := by
  funext i
  unfold produced
  rw [ArrayStorage.BFBuffer.read_correct, ArrayStorage.BFBuffer.read_correct,
    parameterLoads_eq, parameterLoads_eq, take.packed_byte]
  rfl

structure Execution (layer : QuantizedEmbedding.Layer) (token : Fin 248320) where
  storage : Storage layer
  take : Take storage token
  output : HalfArrayWrites.Trace 0 (fun i => ArrayStorage.bits (produced take i))

def Execution.fromStorage (layer : QuantizedEmbedding.Layer) (token : Fin 248320) (storage : Storage layer) : Execution layer token :=
  let take := Take.canonical storage token
  ⟨storage, take, HalfArrayWrites.Trace.canonical _ (by decide)⟩

def Execution.values (execution : Execution layer token) : Fin 5120 → BF := execution.output.buffer.read
def Execution.outputBuffer (execution : Execution layer token) : ArrayStorage.BFBuffer execution.values :=
  ArrayViews.readback execution.output.buffer

theorem Execution.values_eq (execution : Execution layer token) : execution.values=layer.forward token := by
  funext i
  unfold Execution.values
  rw [ArrayStorage.BFBuffer.read_correct, produced_eq]

def Execution.forwardBuffer (execution : Execution layer token) : ArrayStorage.BFBuffer (layer.forward token) :=
  ArrayViews.reindex execution.values_eq execution.outputBuffer

theorem Execution.forward_bytes (execution : Execution layer token) : execution.forwardBuffer.bytes=execution.output.memory :=
  ArrayViews.reindex_bytes _ _

theorem packed_bounds (storage : Storage layer) (token : Fin 248320) (i : Fin 640) :
    (storage.packedBase+4*(token.val*640+i.val))%4=0 ∧
    storage.packedBase+4*(token.val*640+i.val)+4 ≤ 2^64 := by
  have := storage.aligned
  have := storage.bounded
  have := QuantizedEmbedding.takeRow_bounds 640 token i
  omega

theorem gather_dispatch : 248320*640<2^31 ∧ 248320*80<2^31 ∧ 640>8 ∧ 80>8 ∧ (80+2-1)/2=40 := by decide

theorem parameter_owner (i : Fin 80) : (i.val/2)*2+i.val%2=i.val ∧ i.val/2<40 := by omega

theorem dequantize_owner (i : Fin 5120) :
    (AffineDequantize.byteIndex i).val*2+(AffineDequantize.byteCoordinate i).val=i.val ∧ (AffineDequantize.byteIndex i).val<2560 :=
  ⟨AffineDequantize.pack_coordinate i, (AffineDequantize.byteIndex i).isLt⟩

end Inference.Layers.QuantizedEmbeddingDevice
