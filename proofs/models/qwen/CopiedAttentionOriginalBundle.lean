import models.qwen.CopiedAttentionFrontConstruction
import models.qwen.DecodeParameterMemory
namespace Inference.Models.Qwen.CopiedAttentionOriginalBundle
open Contracts.Mlx Layers Kernels Kernels.Attention State
set_option maxRecDepth 10000
variable {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF}
  (source : ArrayStorage.BFBuffer input)
  (original : DecodeParameterMemory.AttentionStorage layer source.bytes)
  (normal : NormalizationMemory.Execution layer.inputNorm ⟨source,original.norm,original.normShared⟩)
  (safe : original.Protected (MemoryRegions.Disjoint (2*normal.normalized.base) 10240))

theorem normalization_frame {base size : Nat}
    (region : MemoryRegions.Disjoint (2*normal.normalized.base) 10240 base size)
    (offset : Nat) (bound : offset<size) :
    (NormalizationMemory.forwardBuffer normal).bytes (base+offset)=source.bytes (base+offset) := by
  rw [NormalizationMemory.forward_bytes]
  exact normal.other_region region offset bound

def normalized : DecodeParameterMemory.AttentionStorage layer (NormalizationMemory.forwardBuffer normal).bytes :=
  original.reframe _ (original.protected_mono (fun _ _ region => normalization_frame source original normal region) safe)

theorem normalized_protected (property : Nat → Nat → Prop) :
    (normalized source original normal safe).Protected property ↔ original.Protected property :=
  original.reframe_protected _ _ property

variable {live : Nat → Nat → Prop}
  (regions : original.Protected live)

include regions in
theorem current_regions : (normalized source original normal safe).Protected live :=
  (normalized_protected source original normal safe live).mpr regions

variable (plan : CopiedAttentionProjectionConstruction.Plan layer.mixer.projections
    (NormalizationMemory.forwardBuffer normal) (normalized source original normal safe).projections live)
  (allocation : CopiedAttentionParameterConstruction.QueryAllocation (normalized source original normal safe).projections plan)
  (angle : RopeAngles.Inputs)
  (native : CopiedAttentionFrontConstruction.Native (normalized source original normal safe).projections plan allocation
    (normalized source original normal safe).mixer (current_regions source original normal safe regions).2.2.1 angle)

def front : AttentionGateCopyFront.Execution layer.mixer (layer.inputNorm.forward input) angle :=
  CopiedAttentionFrontConstruction.execution (normalized source original normal safe).projections plan allocation
    (normalized source original normal safe).mixer (current_regions source original normal safe regions).2.2.1 native

theorem front_input : (front source original normal safe regions plan allocation angle native).phase.q.source=
    NormalizationMemory.forwardBuffer normal :=
  CopiedAttentionFrontConstruction.original_source _ _ _ _ _ _

theorem front_memory : (front source original normal safe regions plan allocation angle native).memory=native.rope.memory :=
  CopiedAttentionFrontConstruction.memory _ _ _ _ _ _
end Inference.Models.Qwen.CopiedAttentionOriginalBundle
