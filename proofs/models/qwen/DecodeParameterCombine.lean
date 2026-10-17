import models.qwen.DecodeParameterMemory
namespace Inference.Models.Qwen.DecodeParameterCombine
open Contracts.Mlx Layers DecodeStage
set_option maxRecDepth 10000
variable {first second third : Nat → Nat → Prop}
  (join : ∀ base size, first base size → second base size → third base size)
include join
theorem affine (p : AffineVerifyLinear.Projection steps rows) (w : AffineDevice.Storage p)
    (a : AffineMemoryFrames.Protected p w first) (b : AffineMemoryFrames.Protected p w second) :
    AffineMemoryFrames.Protected p w third := by
  cases p <;> exact ⟨join _ _ a.1 b.1,join _ _ a.2.1 b.2.1,join _ _ a.2.2 b.2.2⟩
theorem trellis (w : TrellisWeightsMemory.Weights mlp memory) (a : w.Protected first) (b : w.Protected second) : w.Protected third :=
  ⟨join _ _ a.1 b.1,join _ _ a.2.1 b.2.1,join _ _ a.2.2.1 b.2.2.1,join _ _ a.2.2.2.1 b.2.2.2.1,
    join _ _ a.2.2.2.2.1 b.2.2.2.2.1,join _ _ a.2.2.2.2.2 b.2.2.2.2.2⟩
theorem suffix (w : ResidualDeltaConstruction.MlpWeights block memory) (a : w.Protected first) (b : w.Protected second) : w.Protected third :=
  ⟨join _ _ a.1 b.1,trellis join w.trellis a.2 b.2⟩
theorem deltaMixer (w : DeltaParameterMemory.Storage layer memory)
    (a : DeltaParameterMemory.Protected w first) (b : DeltaParameterMemory.Protected w second) : DeltaParameterMemory.Protected w third :=
  ⟨join _ _ a.1 b.1,join _ _ a.2.1 b.2.1,join _ _ a.2.2.1 b.2.2.1,join _ _ a.2.2.2.1 b.2.2.2.1,
    join _ _ a.2.2.2.2.1 b.2.2.2.2.1,join _ _ a.2.2.2.2.2.1 b.2.2.2.2.2.1,
    affine join layer.out w.projection a.2.2.2.2.2.2 b.2.2.2.2.2.2⟩
theorem attentionMixer (w : AttentionParameterMemory.Storage layer memory)
    (a : AttentionParameterMemory.Protected w first) (b : AttentionParameterMemory.Protected w second) : AttentionParameterMemory.Protected w third :=
  ⟨join _ _ a.1 b.1,join _ _ a.2.1 b.2.1,affine join layer.output w.projection a.2.2 b.2.2⟩
theorem stage (kind : Stage) (w : DecodeParameterMemory.StageStorage kind memory)
    (a : DecodeParameterMemory.StageProtected kind w first) (b : DecodeParameterMemory.StageProtected kind w second) :
    DecodeParameterMemory.StageProtected kind w third := by
  cases kind with
  | delta layer => exact ⟨join _ _ a.1 b.1,
      ⟨affine join _ _ a.2.1.1 b.2.1.1,affine join _ _ a.2.1.2.1 b.2.1.2.1,
        affine join _ _ a.2.1.2.2.1 b.2.1.2.2.1,affine join _ _ a.2.1.2.2.2 b.2.1.2.2.2⟩,
      deltaMixer join _ a.2.2.1 b.2.2.1,suffix join _ a.2.2.2 b.2.2.2⟩
  | attention layer => exact ⟨join _ _ a.1 b.1,
      ⟨affine join _ _ a.2.1.1 b.2.1.1,affine join _ _ a.2.1.2.1 b.2.1.2.1,affine join _ _ a.2.1.2.2 b.2.1.2.2⟩,
      attentionMixer join _ a.2.2.1 b.2.2.1,suffix join _ a.2.2.2 b.2.2.2⟩
theorem all : (stages : List Stage) → (w : DecodeParameterMemory.Storage stages memory) →
    DecodeParameterMemory.Protected stages w first → DecodeParameterMemory.Protected stages w second →
    DecodeParameterMemory.Protected stages w third
  | [], _, _, _ => True.intro
  | kind::rest, w, a, b => ⟨stage join kind w.1 a.1 b.1,all rest w.2 a.2 b.2⟩
end Inference.Models.Qwen.DecodeParameterCombine
