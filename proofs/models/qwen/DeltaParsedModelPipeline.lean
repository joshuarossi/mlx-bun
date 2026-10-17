import models.qwen.DeltaParsedPipeline

namespace Inference.Models.Qwen.DeltaParsedModelPipeline
open Contracts.Mlx Kernels Kernels.Delta Layers
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 2000

variable {layer : DeltaNet.Layer} {cache : DeltaNet.Cache} {input residual : Fin 5120 → ArrayStorage.BF}
  {convInput : ConvolutionMemory.Input cache.history (layer.qkv.forward input) layer.convolutionWeight}
  {convolution : ConvolutionMemory.Execution convInput layer.recurrence.convolutionContracted}
  {preparation : DeltaConvolutionMemory.Execution convolution layer.headParams.qScale layer.headParams.kScale
    layer.recurrence.heads layer.headParams.width layer.headParams.eps layer.aLog (layer.a.forward input) layer.dtBias
    (layer.b.forward input) layer.recurrence.gates}
  {block : ResidualBlocks.Mlp}
  (run : DeltaBlockMemory.Execution preparation cache.recurrent layer.recurrence.reduce layer.recurrence.flags
    (DeltaNet.zHead layer (fun _ => input) 0) layer.normWeight layer.gated layer.out block residual)

theorem normalization_eq : GatedInputs.flatten run.tail.normalization.output=
    DeltaNet.merged layer cache (fun _ => input) 0 := by
  rw [run.tail.normalization.output_eq,run.recurrence.output_eq,DeltaMemoryRefinement.produced_output preparation]
  rfl

theorem projection_finite (finite : layer.Finite cache (fun _ => input) 0) :
    layer.out.Finite (GatedInputs.flatten run.tail.normalization.output) := by
  rw [normalization_eq run]
  exact finite.output

-- The numerical model's existing range certificate supplies the source
-- parser's finite-input requirements. No new bound on a completed source
-- output is requested by this bridge.
theorem checked (before : Nat → Float32)
    (widthSame : layer.headParams.width=SiluHeads128Output.width)
    (epsSame : layer.headParams.eps=SiluHeads128Output.epsilon)
    (finite : layer.Finite cache (fun _ => input) 0) : DeltaParsedPipeline.Certificate run before :=
  DeltaParsedPipeline.checked run before widthSame epsSame
    (finite.recurrence.gates 0 (by decide)).decay (projection_finite run finite)

theorem output_read (row : Fin 5120) : run.tail.buffer.read row=layer.forward cache (fun _ => input) 0 row := by
  calc
    _ = run.tail.output row := ArrayStorage.BFBuffer.read_correct _ row
    _ = _ := congrFun (DeltaMemoryRefinement.tail_forward run.tail) row

theorem state_read (head : Fin 48) (row key : Fin 128) :
    run.tail.afterState.read head row key=(DeltaCache.after layer cache (fun _ => input) 1).recurrent head row key :=
  congrFun (congrFun (congrFun (DeltaMemoryRefinement.tail_state run.tail) head) row) key

theorem source_and_error (before : Nat → Float32)
    (widthSame : layer.headParams.width=SiluHeads128Output.width)
    (epsSame : layer.headParams.eps=SiluHeads128Output.epsilon)
    (finite : layer.Finite cache (fun _ => input) 0)
    (idealEps epsError : ℝ) (positive : 0 < idealEps)
    (epsBound : |Numerics.real layer.headParams.eps-idealEps| ≤ epsError)
    (targetCache errorCache : DeltaNet.ReferenceCache) (cacheBound : DeltaNet.CacheError cache targetCache errorCache)
    (target error : Nat → Fin 5120 → ℝ)
    (inputBound : ∀ t i, |Model.toReal (input i)-target t i| ≤ error t i) :
    DeltaParsedPipeline.Certificate run before ∧
      ∀ row,|Model.toReal (run.tail.buffer.read row)-layer.target idealEps targetCache target 0 row| ≤
        layer.budget idealEps epsError cache targetCache errorCache (fun _ => input) target error 0 row := by
  refine ⟨checked run before widthSame epsSame finite,?_⟩
  intro row
  rw [output_read run row]
  exact layer.forward_error idealEps epsError positive epsBound cache targetCache errorCache cacheBound
    (fun _ => input) target error inputBound 0 finite row

end Inference.Models.Qwen.DeltaParsedModelPipeline
