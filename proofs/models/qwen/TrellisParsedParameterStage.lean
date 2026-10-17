import models.qwen.TrellisParsedStageSources
import models.qwen.TrellisParsedNative
import models.qwen.DecodeParameterConstruction
namespace Inference.Models.Qwen.TrellisParsedParameterStage
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention
set_option maxRecDepth 10000

def Native : (kind : Stage) → (cache : Cache kind n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    DecodeMemoryStage.Execution kind cache input angle → Type
  | .delta _, _, _, _, execution => TrellisParsedNative.Input execution.block.suffix.suffix
  | .attention _, _, _, _, execution => TrellisParsedNative.Input execution.block.suffix.suffix

def Parsed : (kind : Stage) → (cache : Cache kind n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (execution : DecodeMemoryStage.Execution kind cache input angle) → Native kind cache input angle execution → Prop
  | .delta _, _, _, _, execution, native => TrellisParsedNative.Parsed execution.block.suffix.suffix native
  | .attention _, _, _, _, execution, native => TrellisParsedNative.Parsed execution.block.suffix.suffix native

private theorem attach_equal {x update : Fin 5120 → ArrayStorage.BF} {block : ResidualBlocks.Mlp}
    {source : BinaryMemory.Input x update} (before after : ResidualMlpMemory.Execution block source)
    (same : before=after) (native : TrellisParsedNative.Input after)
    (attached : ResidualMlpParsedTrellis.Source before)
    (precise : attached.precise=(TrellisParsedNative.transport same.symm native).precise)
    (absolute : attached.absolute=(TrellisParsedNative.transport same.symm native).absolute)
    (vector : attached.vector=(TrellisParsedNative.transport same.symm native).vector) :
    TrellisParsedNative.Parsed after native := by
  have result := TrellisParsedNative.transport_parsed same (TrellisParsedNative.transport same.symm native)
    (TrellisParsedNative.parsed before (TrellisParsedNative.transport same.symm native) attached precise absolute vector)
  rw [TrellisParsedNative.transport_roundtrip] at result
  exact result

theorem stage (kind : Stage) (cache : Cache kind n) (input : Row BF) (angle : RopeAngles.Inputs)
    (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.StageBuffer kind cache source.bytes)
    (parameters : DecodeParameterMemory.StageStorage kind source.bytes)
    (plan : DecodeParameterConstruction.StagePlan kind cache input angle source storage parameters)
    (native : Native kind cache input angle (DecodeParameterConstruction.stage kind cache input angle source storage parameters plan).execution) :
    Parsed kind cache input angle (DecodeParameterConstruction.stage kind cache input angle source storage parameters plan).execution native := by
  cases kind with
  | delta layer =>
    let original := DecodeParameterConstruction.deltaSource plan.entry storage plan.frames
    let same := (TrellisParsedStageSources.delta_implementation original plan.allocation).trans
      (TrellisParsedStageConstruction.delta_suffix original plan.allocation).symm
    let moved := TrellisParsedNative.transport same.symm native
    exact attach_equal _ _ same native
      (TrellisParsedStageSources.delta original plan.allocation moved.precise moved.absolute moved.exponential moved.inputBounded moved.vector)
      rfl rfl rfl
  | attention layer =>
    let same := (TrellisParsedStageConstruction.attention_suffix plan).symm
    let moved := TrellisParsedNative.transport same.symm native
    exact attach_equal _ _ same native
      (TrellisParsedStageSources.attention plan moved.precise moved.absolute moved.exponential moved.inputBounded moved.vector)
      rfl rfl rfl
end Inference.Models.Qwen.TrellisParsedParameterStage
