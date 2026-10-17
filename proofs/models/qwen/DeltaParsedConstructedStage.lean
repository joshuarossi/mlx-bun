import models.qwen.DeltaParsedStoragePipeline
import models.qwen.DeltaConstructedPreparationSource

namespace Inference.Models.Qwen.DeltaParsedConstructedStage
open Contracts.Mlx Kernels Kernels.Delta Kernels.Normalization Layers
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 100000
attribute [local irreducible] ResidualDeltaStorageConstruction.block
  ResidualDeltaStorageConstruction.preparation TrellisParsedStageSources.deltaImplementation

variable {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Fin 5120 → ArrayStorage.BF}
  (source : ResidualDeltaStorageConstruction.Source layer cache input)
  (plan : ResidualDeltaStorageConstruction.Plan source)

-- Only native specialization and primitive contracts accompany the existing
-- initial-heap source and allocation plan. Completed registers, parameters,
-- phase outputs and numerical error conclusions are not caller fields.
structure Native where
  a : AffineVerifyLinear.Projection4 10 48
  b : AffineVerifyLinear.Projection4 10 48
  aSelected : layer.mixer.a=.bits4 a
  bSelected : layer.mixer.b=.bits4 b
  kernel : MlxRmsHostSelection.KernelLimit
  nativeThreads : layer.inputNorm.platform.groups*32=kernel.threads
  scratch : M1Max.WordMemory
  inverseBefore : M1Max.WordMemory
  base : Nat
  inverseBase : Nat
  generation : Nat
  size : Char
  before : Nat → Float32
  width : layer.mixer.headParams.width=SiluHeads128Output.width
  trellis : TrellisParsedNative.Input (TrellisParsedStageSources.deltaImplementation source plan)

def Certificate (native : Native source plan) : Prop :=
  DeltaParsedEntry.Certificate source.entry native.a native.b native.aSelected native.bSelected
    native.kernel native.scratch native.inverseBefore native.base native.inverseBase native.generation native.size native.before ∧
  DeltaParsedStoragePipeline.Certificate source plan native.before native.trellis

theorem checked (native : Native source plan) (finite : layer.Finite cache (fun _ => input) 0) :
    Certificate source plan native := by
  have aFinite : native.a.Finite (layer.inputNorm.forward input) := by
    have selected := finite.mixer.projections.a 0
    rw [native.aSelected] at selected
    exact selected
  have bFinite : native.b.Finite (layer.inputNorm.forward input) := by
    have selected := finite.mixer.projections.b 0
    rw [native.bSelected] at selected
    exact selected
  exact ⟨DeltaParsedEntry.checked source.entry native.a native.b native.aSelected native.bSelected native.kernel
      native.nativeThreads native.scratch native.inverseBefore native.base native.inverseBase native.generation
      native.size native.before (finite.mixer.projections.qkv 0) (finite.mixer.projections.z 0) aFinite bFinite,
    DeltaParsedStoragePipeline.checked source plan native.before native.trellis native.width finite⟩

-- Expose the physical producer/consumer edges of the same constructed stage.
-- The source certificate's projection values are read from the surviving
-- original buffers at convolution concatenation and gate preparation.
theorem concat_read (native : Native source plan) (parsed : Certificate source plan native) (row : Fin 10240) :
    (DeltaPreparationConstruction.window source.entry.affine source.cacheAfterEntry source.parametersAfterEntry rfl
      plan.preparation.convolution).joined.source.read row=
      AffineRouteParsedSource.value source.entry.affine.qkv row :=
  DeltaConstructedPreparationSource.concat_parsed source plan.preparation parsed.1.projections row

theorem decay_projection_read (native : Native source plan) (parsed : Certificate source plan native) (head : Fin 48) :
    (ResidualDeltaStorageConstruction.preparation source plan.preparation).prepared.source.storage.projectionA.read head=
      AffineNativeParsedSource4.value (blocks := 6)
        (Delta48NativeParsedAffine4.aExecution source.entry.affine native.a native.aSelected) head :=
  DeltaConstructedPreparationSource.prepared_a_parsed source plan.preparation parsed.1.projections head

theorem beta_projection_read (native : Native source plan) (parsed : Certificate source plan native) (head : Fin 48) :
    (ResidualDeltaStorageConstruction.preparation source plan.preparation).prepared.source.storage.projectionB.read head=
      AffineNativeParsedSource4.value (blocks := 6)
        (Delta48NativeParsedAffine4.bExecution source.entry.affine native.b native.bSelected) head :=
  DeltaConstructedPreparationSource.prepared_b_parsed source plan.preparation parsed.1.projections head

theorem source_and_error (native : Native source plan) (finite : layer.Finite cache (fun _ => input) 0)
    (targetCache errorCache : DeltaNet.ReferenceCache) (cacheBound : DeltaNet.CacheError cache targetCache errorCache)
    (target error : Nat → Fin 5120 → ℝ)
    (inputBound : ∀ t i, |Model.toReal (input i)-target t i| ≤ error t i)
    (capacity : layer.Capacity cache targetCache errorCache (fun _ => input) target error 0 finite) :
    Certificate source plan native ∧
      (∀ row,|Model.toReal ((ResidualDeltaStorageConstruction.fromStorage source plan).outputBuffer.read row)-
        layer.target targetCache target 0 row| ≤ layer.budget cache targetCache errorCache (fun _ => input) target error 0 finite row) ∧
      DeltaNet.CacheError (ResidualDeltaStorageConstruction.fromStorage source plan).readCache
        (layer.targetCacheAfter targetCache target 1)
        (layer.cacheBudget cache targetCache errorCache (fun _ => input) target error 1) :=
  ⟨checked source plan native finite,
    (DeltaParsedStoragePipeline.source_and_error source plan native.before native.trellis native.width finite
      targetCache errorCache cacheBound target error inputBound capacity).2⟩

end Inference.Models.Qwen.DeltaParsedConstructedStage
