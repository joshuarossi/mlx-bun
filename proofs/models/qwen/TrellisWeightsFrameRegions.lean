import models.qwen.TrellisWeightsMemory
namespace Inference.Models.Qwen.TrellisWeightsFrameRegions
open Contracts.Mlx WrittenLayers
variable (weights : TrellisWeightsMemory.Weights mlp memory) (after : ByteMemory.Bytes)
  (same : weights.Protected (fun base size => ∀ offset<size, after (base+offset)=memory (base+offset)))
  (property : Nat → Nat → Prop)
theorem regions : (weights.reframe after same).Protected property ↔ weights.Protected property := Iff.rfl
end Inference.Models.Qwen.TrellisWeightsFrameRegions
