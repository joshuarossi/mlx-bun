import layers.QuantizedEmbeddingDequantizeSource
import kernels.copy.GatherFrontHost
import kernels.quantization.AffineDequantizeHost

namespace Inference.Layers.QuantizedEmbeddingParsedPipeline
open Contracts.Mlx Kernels.Copy Kernels.Quantization QuantizedEmbeddingMemory
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 100000
attribute [local irreducible] List.finRange

variable {layer : QuantizedEmbedding.Layer} {token : Fin 248320}

-- All source operands are read from the existing execution's current heaps.
-- The construction needs no expected copy result or dequantized output.
-- Native descriptor attachment, the chosen contraction profile, source
-- compilation and physical dispatch ordering remain external obligations.
structure Certificate (run : Execution layer token) (unsigned : Bool) : Prop where
  packed : ∀ stores subset,
    (List.finRange 640).mapM (QuantizedEmbeddingGatherSource.packedThread run unsigned (run.duringPacked stores subset))=
      some (WordArrayWrites.programs run.regions.packed run.packedValues)
  scales : ∀ stores subset,
    (List.finRange 40).mapM (QuantizedEmbeddingGatherSource.parameterThread run unsigned (run.duringScales stores subset)
      run.storage.scales.base run.regions.scales)=
      some (parameterPrograms run.regions.scales (fun i => ArrayStorage.bits (run.scaleValues i)))
  biases : ∀ stores subset,
    (List.finRange 40).mapM (QuantizedEmbeddingGatherSource.parameterThread run unsigned (run.duringBiases stores subset)
      run.storage.biases.base run.regions.biases)=
      some (parameterPrograms run.regions.biases (fun i => ArrayStorage.bits (run.biasValues i)))
  dequantize : ∀ stores, MemoryRegions.Inside16 run.regions.output 10240 stores →
    (List.finRange 2560).mapM (QuantizedEmbeddingDequantizeSource.threadSource run (HalfMemory.execute stores run.p3.memory))=
      some (QuantizedEmbeddingDequantizeSource.programs run.regions.output (fun i => ArrayStorage.bits (run.produced i)))
  dequantizeSchedule :
    ThreadgroupWrites.Executes (QuantizedEmbeddingDequantizeSource.programs run.regions.output (fun i => ArrayStorage.bits (run.produced i)))
      run.output.schedule (List.replicate 2560 [])

theorem checked (run : Execution layer token) (unsigned : Bool) : Certificate run unsigned := {
  packed := QuantizedEmbeddingGatherSource.packed_prefix run unsigned
  scales := QuantizedEmbeddingGatherSource.scales_prefix run unsigned
  biases := QuantizedEmbeddingGatherSource.biases_prefix run unsigned
  dequantize := QuantizedEmbeddingDequantizeSource.programs_prefix run
  dequantizeSchedule := QuantizedEmbeddingDequantizeSource.native_schedule run
}

theorem host_selection (maximum : Nat) :
    GatherFrontHost.select GatherFrontHost.packed 248320=some ⟨false,1,640,1,640,248320⟩ ∧
    GatherFrontHost.select GatherFrontHost.parameter 248320=some ⟨false,2,40,1,80,248320⟩ ∧
    AffineDequantizeHost.dims 4 5120 maximum=⟨2560,min maximum 2560,2560,1,false⟩ :=
  ⟨GatherFrontHost.packed_selected,GatherFrontHost.parameter_selected,AffineDequantizeHost.selected maximum⟩

theorem source_and_output (run : Execution layer token) (unsigned : Bool) :
    Certificate run unsigned ∧ run.tokenBuffer.read=token.val ∧
      (∀ i, run.outputBuffer.read i=layer.forward token i) :=
  ⟨checked run unsigned,run.tokenBuffer.read_correct,QuantizedEmbeddingDequantizeSource.output_read run⟩

theorem source_and_error (run : Execution layer token) (unsigned : Bool) (finite : layer.Finite token) :
    Certificate run unsigned ∧ ∀ i,
      Model.isFinite (run.outputBuffer.read i)=true ∧
      |Model.toReal (run.outputBuffer.read i)-layer.target token i|≤layer.budget token i := by
  refine ⟨checked run unsigned,fun i => ?_⟩
  rw [QuantizedEmbeddingDequantizeSource.output_read]
  exact ⟨layer.forward_finite token finite i,layer.forward_error token finite i⟩

end Inference.Layers.QuantizedEmbeddingParsedPipeline
