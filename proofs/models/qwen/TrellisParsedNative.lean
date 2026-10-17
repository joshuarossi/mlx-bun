import models.qwen.TrellisParsedHostBinding
import models.qwen.ResidualMlpParsedTrellis
namespace Inference.Models.Qwen.TrellisParsedNative
open Contracts.Mlx Kernels.Trellis WrittenLayers
set_option maxRecDepth 10000
abbrev BF := ArrayStorage.BF

-- Exactly the remaining native/primitive interface. Packed checkpoint data,
-- model equalities and output/error agreement are absent from this record.
structure Input (existing : ResidualMlpMemory.Execution block source) where
  precise : Float32 → Float32
  absolute : BF → BF
  exponential : TrellisMlpParsedGateTail.Exponential block.mlp.activation precise absolute
  inputBounded : ∀ group, (existing.mlp.device.staging group).inputBase+10240≤2^64
  vector : DownFoldVectorMemory.VectorLoad
  leading : List Nat
  supported : TrellisParsedHostBinding.Supported block.mlp

variable {x update : Fin 5120 → BF} {block : ResidualBlocks.Mlp} {source : BinaryMemory.Input x update}

def transport {before after : ResidualMlpMemory.Execution block source}
    (same : before=after) (native : Input before) : Input after := same ▸ native

-- Equality transport changes no native operation or metadata choice.
theorem transport_precise {before after : ResidualMlpMemory.Execution block source}
    (same : before=after) (native : Input before) : (transport same native).precise=native.precise := by
  cases same
  rfl

def Parsed (existing : ResidualMlpMemory.Execution block source) (native : Input existing) : Prop :=
  (∃ attached : ResidualMlpParsedTrellis.Source existing,
    attached.precise=native.precise ∧ attached.absolute=native.absolute ∧ attached.vector=native.vector ∧
    TrellisMlpParsedPipeline.Ready (ResidualMlpParsedTrellis.branch existing attached)
      (ResidualMlpParsedTrellis.gate existing attached) native.vector) ∧
    TrellisParsedHostBinding.actualCode block.mlp native.leading=some (TrellisMlpParsedGateTail.code block.mlp.activation)

theorem parsed (existing : ResidualMlpMemory.Execution block source) (native : Input existing)
    (attached : ResidualMlpParsedTrellis.Source existing) (precise : attached.precise=native.precise)
    (absolute : attached.absolute=native.absolute) (vector : attached.vector=native.vector) : Parsed existing native := by
  refine ⟨⟨attached,precise,absolute,vector,?_⟩,TrellisParsedHostBinding.actual_code block.mlp native.leading native.supported⟩
  rw [←vector]
  exact ResidualMlpParsedTrellis.ready existing attached

theorem transport_parsed {before after : ResidualMlpMemory.Execution block source}
    (same : before=after) (native : Input before) (parsed : Parsed before native) :
    Parsed after (transport same native) := by
  cases same
  exact parsed


theorem transport_roundtrip {before after : ResidualMlpMemory.Execution block source}
    (same : before=after) (native : Input after) :
    transport same (transport same.symm native)=native := by
  cases same
  rfl

end Inference.Models.Qwen.TrellisParsedNative
