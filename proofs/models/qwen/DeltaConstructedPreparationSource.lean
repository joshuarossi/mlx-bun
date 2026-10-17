import models.qwen.DeltaParsedEntry
import models.qwen.DeltaProjectionParameterSource
import models.qwen.DeltaConvolutionParsedSource
namespace Inference.Models.Qwen.DeltaConstructedPreparationSource
open Contracts.Mlx Layers Kernels Kernels.Delta
set_option maxRecDepth 100000
variable {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Fin 5120→ArrayStorage.BF}
  (source : ResidualDeltaStorageConstruction.Source layer cache input)
  (plan : ResidualDeltaStorageConstruction.PreparationPlan source)

-- These identities expose the actual constructor arguments. In particular,
-- neither normalized input nor completed preparation is supplied as an oracle.
theorem original_input : source.entry.source.lhs=source.data.source :=
  ResidualDeltaConstruction.normalized_source source.data

theorem original_norm_weights : source.entry.source.rhs=source.data.normWeights := rfl

theorem normalization_base : source.entry.normalization.normalized.base=source.data.normalizationBase := rfl

theorem physical_projection_outputs :
    source.entry.affine.qkv.base=source.data.affineRegions.qkv ∧
    source.entry.affine.z.base=source.data.affineRegions.z ∧
    source.entry.affine.a.base=source.data.affineRegions.a ∧
    source.entry.affine.b.base=source.data.affineRegions.b := by
  exact DeltaAffineConstruction.fromStorage_bases _ _ _ _ _ source.data.affineAllocation

theorem preparation_attachment : ResidualDeltaStorageConstruction.preparation source plan=
    DeltaPreparationConstruction.fromStorage source.entry.affine source.cacheAfterEntry source.parametersAfterEntry rfl
      plan.convolution plan.prepared := rfl

theorem parameter_bases :
    source.parametersAfterEntry.convolution.base=source.parameters.convolution.base ∧
    source.parametersAfterEntry.queryScale.base=source.parameters.queryScale.base ∧
    source.parametersAfterEntry.keyScale.base=source.parameters.keyScale.base ∧
    source.parametersAfterEntry.logarithm.base=source.parameters.logarithm.base ∧
    source.parametersAfterEntry.bias.base=source.parameters.bias.base ∧
    source.parametersAfterEntry.normalization.base=source.parameters.normalization.base :=
  ⟨rfl,rfl,rfl,rfl,rfl,rfl⟩

theorem parameter_bytes_preserved : DeltaParameterMemory.Protected source.parameters
    (fun base size=>∀ offset<size,source.entry.affine.memory (base+offset)=source.data.source.bytes (base+offset)) := by
  apply DeltaParameterMemory.protected_mono source.parameters _ source.entryFrames.parameterSafe
  intro base size safe offset bound
  exact source.entry.other_region safe offset bound

theorem initial_heap : source.entry.source.lhs.bytes=source.data.source.bytes :=
  congrArg ArrayStorage.BFBuffer.bytes (original_input source)

theorem current_parameters :
    source.parametersAfterEntry.convolution.bytes=source.entry.affine.memory ∧
    source.parametersAfterEntry.queryScale.bytes=source.entry.affine.memory ∧
    source.parametersAfterEntry.keyScale.bytes=source.entry.affine.memory ∧
    source.parametersAfterEntry.logarithm.bytes=source.entry.affine.memory ∧
    source.parametersAfterEntry.bias.bytes=source.entry.affine.memory :=
  ⟨rfl,rfl,rfl,rfl,rfl⟩

theorem concat_projection :
    (DeltaPreparationConstruction.window source.entry.affine source.cacheAfterEntry source.parametersAfterEntry rfl
      plan.convolution).joined.source=source.entry.affine.qkvBuffer := rfl

theorem concat_read (row : Fin 10240) :
    (DeltaPreparationConstruction.window source.entry.affine source.cacheAfterEntry source.parametersAfterEntry rfl
      plan.convolution).joined.source.read row=layer.mixer.qkv.forward (layer.inputNorm.forward input) row :=
  source.entry.affine.qkvBuffer.read_correct row

theorem gate_projection_bases :
    (ResidualDeltaStorageConstruction.preparation source plan).gateSource.storage.projectionA.base=source.entry.affine.aBuffer.base ∧
    (ResidualDeltaStorageConstruction.preparation source plan).gateSource.storage.projectionB.base=source.entry.affine.bBuffer.base ∧
    (ResidualDeltaStorageConstruction.preparation source plan).gateSource.storage.logarithm.base=source.parameters.logarithm.base ∧
    (ResidualDeltaStorageConstruction.preparation source plan).gateSource.storage.bias.base=source.parameters.bias.base :=
  ⟨rfl,rfl,rfl,rfl⟩

private theorem convolution_gate_bases
    {history : State.ConvolutionStorage.History} {next : Fin 10240→ArrayStorage.BF}
    {weights : Fin 10240→Fin 4→ArrayStorage.BF} {convInput : ConvolutionMemory.Input history next weights}
    {contracted : Bool} (conv : ConvolutionMemory.Execution convInput contracted)
    {aLog a dtBias b : GateDevice.Heads} (original : GateMemory.Input aLog a dtBias b)
    (shared : original.storage.logarithm.bytes=convInput.window.joined.old.bytes)
    (safe : original.Protected (fun base=>ConvolutionMemory.Safe conv base 96)) :
    (DeltaConvolutionMemory.gatesAfterConvolution conv original shared safe).storage.projectionA.base=original.storage.projectionA.base ∧
    (DeltaConvolutionMemory.gatesAfterConvolution conv original shared safe).storage.projectionB.base=original.storage.projectionB.base ∧
    (DeltaConvolutionMemory.gatesAfterConvolution conv original shared safe).storage.logarithm.base=original.storage.logarithm.base ∧
    (DeltaConvolutionMemory.gatesAfterConvolution conv original shared safe).storage.bias.base=original.storage.bias.base := ⟨rfl,rfl,rfl,rfl⟩

theorem qkv_original_parameters : DeltaProjectionParameterSource.Framed layer.mixer.qkv
    source.data.affineWeights.qkv (DeltaProjectionParameterSource.weights source.entry.affine.qkv) := by
  have current := DeltaProjectionParameterSource.qkv_origin _ _ _ _ _ source.data.affineAllocation
  exact DeltaProjectionParameterSource.trans _ _ _ _ ⟨_,_,rfl⟩ current

theorem z_original_parameters : DeltaProjectionParameterSource.Framed layer.mixer.z
    source.data.affineWeights.z (DeltaProjectionParameterSource.weights source.entry.affine.z) := by
  have current := DeltaProjectionParameterSource.z_origin _ _ _ _ _ source.data.affineAllocation
  exact DeltaProjectionParameterSource.trans _ _ _ _ ⟨_,_,rfl⟩ current

theorem a_original_parameters : DeltaProjectionParameterSource.Framed layer.mixer.a
    source.data.affineWeights.a (DeltaProjectionParameterSource.weights source.entry.affine.a) := by
  have current := DeltaProjectionParameterSource.a_origin _ _ _ _ _ source.data.affineAllocation
  exact DeltaProjectionParameterSource.trans _ _ _ _ ⟨_,_,rfl⟩ current

theorem b_original_parameters : DeltaProjectionParameterSource.Framed layer.mixer.b
    source.data.affineWeights.b (DeltaProjectionParameterSource.weights source.entry.affine.b) := by
  have current := DeltaProjectionParameterSource.b_origin _ _ _ _ _ source.data.affineAllocation
  exact DeltaProjectionParameterSource.trans _ _ _ _ ⟨_,_,rfl⟩ current

attribute [local irreducible] ResidualDeltaStorageConstruction.preparation

theorem prepared_gate_bases :
    (ResidualDeltaStorageConstruction.preparation source plan).prepared.source.storage.projectionA.base=source.entry.affine.aBuffer.base ∧
    (ResidualDeltaStorageConstruction.preparation source plan).prepared.source.storage.projectionB.base=source.entry.affine.bBuffer.base ∧
    (ResidualDeltaStorageConstruction.preparation source plan).prepared.source.storage.logarithm.base=source.parameters.logarithm.base ∧
    (ResidualDeltaStorageConstruction.preparation source plan).prepared.source.storage.bias.base=source.parameters.bias.base := by
  have framed := convolution_gate_bases _
    (ResidualDeltaStorageConstruction.preparation source plan).gateSource
    (ResidualDeltaStorageConstruction.preparation source plan).gateShared
    (ResidualDeltaStorageConstruction.preparation source plan).gateSafe
  have linked := (ResidualDeltaStorageConstruction.preparation source plan).linked
  rw [←linked] at framed
  have bases := gate_projection_bases source plan
  exact ⟨framed.1.trans bases.1,framed.2.1.trans bases.2.1,
    framed.2.2.1.trans bases.2.2.1,framed.2.2.2.trans bases.2.2.2⟩
variable {a b : AffineVerifyLinear.Projection4 10 48}
  {ha : layer.mixer.a=.bits4 a} {hb : layer.mixer.b=.bits4 b}
  {generation : Nat} {size : Char} {before : Nat→Float32}
  (parsed : DeltaParsedProjections.Certificate source.entry.affine a b ha hb generation size before)

include parsed in
theorem concat_parsed (row : Fin 10240) :
    (DeltaPreparationConstruction.window source.entry.affine source.cacheAfterEntry source.parametersAfterEntry rfl
      plan.convolution).joined.source.read row=
      AffineParsedSource.value (steps:=10) (blocks:=160) source.entry.affine.qkv row :=
  DeltaParsedProjections.qkv_readback source.entry.affine parsed row

include parsed in
theorem prepared_a_parsed (head : Fin 48) :
    (ResidualDeltaStorageConstruction.preparation source plan).prepared.source.storage.projectionA.read head=
      AffineNativeParsedSource4.value (blocks:=6)
        (Delta48NativeParsedAffine4.aExecution source.entry.affine a ha) head := by
  rw [ArrayStorage.BFBuffer.read_correct]
  have projected := DeltaParsedProjections.a_readback source.entry.affine parsed head
  rw [ArrayStorage.BFBuffer.read_correct] at projected
  exact projected

include parsed in
theorem prepared_b_parsed (head : Fin 48) :
    (ResidualDeltaStorageConstruction.preparation source plan).prepared.source.storage.projectionB.read head=
      AffineNativeParsedSource4.value (blocks:=6)
        (Delta48NativeParsedAffine4.bExecution source.entry.affine b hb) head := by
  rw [ArrayStorage.BFBuffer.read_correct]
  have projected := DeltaParsedProjections.b_readback source.entry.affine parsed head
  rw [ArrayStorage.BFBuffer.read_correct] at projected
  exact projected
end Inference.Models.Qwen.DeltaConstructedPreparationSource
