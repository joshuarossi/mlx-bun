import models.qwen.DeltaParsedModelPipeline
import models.qwen.TrellisParsedStageSources
import models.qwen.TrellisParsedNative

namespace Inference.Models.Qwen.DeltaParsedStoragePipeline
open Contracts.Mlx Kernels Kernels.Delta Layers
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 100000
attribute [local irreducible] ResidualDeltaStorageConstruction.block
  ResidualDeltaStorageConstruction.preparation
  TrellisParsedStageSources.deltaImplementation

variable {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Fin 5120 → ArrayStorage.BF}
  (source : ResidualDeltaStorageConstruction.Source layer cache input)
  (plan : ResidualDeltaStorageConstruction.Plan source)

def Certificate (before : Nat → Float32)
    (native : TrellisParsedNative.Input (TrellisParsedStageSources.deltaImplementation source plan)) : Prop :=
  DeltaParsedPipeline.Certificate (ResidualDeltaStorageConstruction.block source plan) before ∧
    TrellisParsedNative.Parsed (TrellisParsedStageSources.deltaImplementation source plan) native

theorem checked (before : Nat → Float32)
    (native : TrellisParsedNative.Input (TrellisParsedStageSources.deltaImplementation source plan))
    (widthSame : layer.mixer.headParams.width=SiluHeads128Output.width)
    (finite : layer.Finite cache (fun _ => input) 0) : Certificate source plan before native := by
  refine ⟨?_,?_⟩
  · exact DeltaParsedModelPipeline.checked (ResidualDeltaStorageConstruction.block source plan)
      before widthSame layer.epsilon finite.mixer
  · exact TrellisParsedNative.parsed _ native
      (TrellisParsedStageSources.delta source plan native.precise native.absolute native.exponential
        native.inputBounded native.vector) rfl rfl rfl

-- The parsed core and parsed Trellis suffix above are the phases already
-- carried by the original parameter-backed constructor, on its same heap.
theorem core_same :
    (ResidualDeltaStorageConstruction.fromStorage source plan).block=
      ResidualDeltaStorageConstruction.block source plan := by
  unfold ResidualDeltaStorageConstruction.fromStorage
  rfl

theorem input_same : (ResidualDeltaStorageConstruction.fromStorage source plan).entry.source.lhs=source.data.source :=
  ResidualDeltaStorageConstruction.source_linked source plan

theorem parameters_same : (ResidualDeltaStorageConstruction.fromStorage source plan).parameters=source.parameters :=
  ResidualDeltaStorageConstruction.parameters_linked source plan

theorem cache_heap :
    (ResidualDeltaStorageConstruction.fromStorage source plan).afterCache.memory=
      (ResidualDeltaStorageConstruction.fromStorage source plan).outputBuffer.bytes :=
  (ResidualDeltaStorageConstruction.fromStorage source plan).cache_output_shared

theorem source_and_error (before : Nat → Float32)
    (native : TrellisParsedNative.Input (TrellisParsedStageSources.deltaImplementation source plan))
    (widthSame : layer.mixer.headParams.width=SiluHeads128Output.width)
    (finite : layer.Finite cache (fun _ => input) 0)
    (targetCache errorCache : DeltaNet.ReferenceCache) (cacheBound : DeltaNet.CacheError cache targetCache errorCache)
    (target error : Nat → Fin 5120 → ℝ)
    (inputBound : ∀ t i, |Model.toReal (input i)-target t i| ≤ error t i)
    (capacity : layer.Capacity cache targetCache errorCache (fun _ => input) target error 0 finite) :
    Certificate source plan before native ∧
      (∀ row,|Model.toReal ((ResidualDeltaStorageConstruction.fromStorage source plan).outputBuffer.read row)-
        layer.target targetCache target 0 row| ≤ layer.budget cache targetCache errorCache (fun _ => input) target error 0 finite row) ∧
      DeltaNet.CacheError (ResidualDeltaStorageConstruction.fromStorage source plan).readCache
        (layer.targetCacheAfter targetCache target 1)
        (layer.cacheBudget cache targetCache errorCache (fun _ => input) target error 1) :=
  ⟨checked source plan before native widthSame finite,
    (ResidualDeltaStorageConstruction.fromStorage source plan).output_error targetCache errorCache cacheBound
      target error inputBound finite capacity,
    (ResidualDeltaStorageConstruction.fromStorage source plan).cache_error targetCache errorCache cacheBound
      target error inputBound finite⟩

end Inference.Models.Qwen.DeltaParsedStoragePipeline
