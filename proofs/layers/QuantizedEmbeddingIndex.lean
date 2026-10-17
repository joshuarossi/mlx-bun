import layers.QuantizedEmbeddingDevice
import state.TokenStorage

namespace Inference.Layers.QuantizedEmbeddingIndex
open Contracts.Mlx QuantizedEmbeddingDevice
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

variable {layer : QuantizedEmbedding.Layer} {token : Fin 248320}

-- gather_front obtains its common row index from the token's uint32
-- buffer. The bounded index contract also excludes the negative-index path.
def packedLoads (storage : Storage layer) (index : State.TokenStorage.Buffer token) (i : Fin 640) : BitVec 32 :=
  ByteMemory.load32 storage.packed (storage.packedBase+4*(index.read*640+i.val))

theorem packedLoads_eq (storage : Storage layer) (index : State.TokenStorage.Buffer token) :
    packedLoads storage index=QuantizedEmbeddingDevice.packedLoads storage token := by
  funext i
  unfold packedLoads
  rw [index.read_correct]
  rfl

def parameterLoads {values : Fin 248320 → Fin 80 → BF} (source : ArrayStorage.BFBuffer (RowStorage.flatten values))
    (index : State.TokenStorage.Buffer token) (i : Fin 80) : BF :=
  Model.ofBits (HalfMemory.load source.bytes (source.base+2*(index.read*80+i.val)))

theorem parameterLoads_eq {values : Fin 248320 → Fin 80 → BF}
    (source : ArrayStorage.BFBuffer (RowStorage.flatten values)) (index : State.TokenStorage.Buffer token) :
    parameterLoads source index=QuantizedEmbeddingDevice.parameterLoads source token := by
  funext i
  unfold parameterLoads QuantizedEmbeddingDevice.parameterLoads ArrayStorage.BFBuffer.read
  rw [index.read_correct, RowStorage.index_value]

structure Execution (layer : QuantizedEmbedding.Layer) (token : Fin 248320) where
  index : State.TokenStorage.Buffer token
  embedding : QuantizedEmbeddingDevice.Execution layer token

def Execution.fromStorage (layer : QuantizedEmbedding.Layer) (token : Fin 248320)
    (index : State.TokenStorage.Buffer token) (weights : Storage layer) : Execution layer token :=
  ⟨index, QuantizedEmbeddingDevice.Execution.fromStorage layer token weights⟩

theorem Execution.packed_trace (execution : Execution layer token) :
    ThreadgroupWrites.Executes (WordArrayWrites.programs 0 (packedLoads execution.embedding.storage execution.index))
      execution.embedding.take.packed.schedule execution.embedding.take.packed.remaining := by
  rw [packedLoads_eq]
  exact execution.embedding.take.packed.execution

theorem Execution.scale_trace (execution : Execution layer token) :
    ThreadgroupWrites.Executes (HalfArrayWrites.programs 0 (fun i => ArrayStorage.bits (parameterLoads execution.embedding.storage.scales execution.index i)))
      execution.embedding.take.scales.schedule execution.embedding.take.scales.remaining := by
  rw [parameterLoads_eq]
  exact execution.embedding.take.scales.execution

theorem Execution.bias_trace (execution : Execution layer token) :
    ThreadgroupWrites.Executes (HalfArrayWrites.programs 0 (fun i => ArrayStorage.bits (parameterLoads execution.embedding.storage.biases execution.index i)))
      execution.embedding.take.biases.schedule execution.embedding.take.biases.remaining := by
  rw [parameterLoads_eq]
  exact execution.embedding.take.biases.execution

end Inference.Layers.QuantizedEmbeddingIndex
