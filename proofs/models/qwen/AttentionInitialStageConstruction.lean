import models.qwen.AttentionInitialWorkspaceConstruction
import models.qwen.DecodeInitialMemoryStage
import models.qwen.ResidualDeltaHighWater

namespace Inference.Models.Qwen.AttentionInitialStageConstruction
open Contracts.Mlx Layers State Kernels.Attention
open AttentionInitialWorkspaceConstruction
open ResidualDeltaHighWater (Frontier Before)
set_option maxRecDepth 10000

variable {layer : ResidualAttention.Layer} {cache : Kv.Cache Kv.BF 0}
  {input : Fin 5120 → ArrayStorage.BF}
  {source : ResidualAttentionStorageConstruction.Source layer cache input}
  (workspace : Workspace source) (angle : RopeAngles.Inputs) (keyCopied valueCopied : Bool)

def execution : DecodeInitialMemoryStage.AttentionExecution layer cache input angle :=
  ⟨workspace.front angle,workspace.read angle keyCopied valueCopied,
    workspace.execution angle keyCopied valueCopied⟩

def trace : DecodeInitialMemoryStage.Trace (.attention layer) cache input angle source.source
    ⟨source.storage,source.shared⟩ where
  execution := execution workspace angle keyCopied valueCopied
  inputLinked := workspace.source_eq angle
  cacheLinked := trivial

theorem safe {base size : Nat} (bound : Before workspace.base base size) :
    (trace workspace angle keyCopied valueCopied).Safe base size := by
  refine ⟨workspace.prefix.safe angle (Or.inr bound),?_,?_⟩
  · exact KvInitialAllocation.safe (workspace.kvWorkspace angle) keyCopied valueCopied
      (bound.trans (Nat.le_add_right _ _))
  · exact (workspace.tailWorkspace angle keyCopied valueCopied).protect (Or.inr
      (bound.trans (show workspace.base≤workspace.tailBase from
        (Nat.le_add_right _ _).trans (Nat.le_add_right _ _))))

theorem buffer_bytes : (trace workspace angle keyCopied valueCopied).buffer.bytes=
    (workspace.execution angle keyCopied valueCopied).outputBuffer.bytes :=
  DecodeInitialMemoryStage.forward_bytes _ _ _ _ _

theorem buffer_base : (trace workspace angle keyCopied valueCopied).buffer.base=
    (workspace.execution angle keyCopied valueCopied).outputBuffer.base :=
  DecodeInitialMemoryStage.forward_base _ _ _ _ _

theorem cache_storage : (trace workspace angle keyCopied valueCopied).cacheAfter.storage=
    (workspace.execution angle keyCopied valueCopied).afterCache := rfl

theorem other_region {base size : Nat} (bound : Before workspace.base base size) (offset : Nat) (inside : offset<size) :
    (trace workspace angle keyCopied valueCopied).buffer.bytes (base+offset)=source.source.bytes (base+offset) :=
  (trace workspace angle keyCopied valueCopied).other_region (safe workspace angle keyCopied valueCopied bound) offset inside

theorem bytes_aligned (layer : ResidualAttention.Layer) : AttentionInitialWorkspaceConstruction.bytes (layer:=layer)%16=0 := by
  dsimp [AttentionInitialWorkspaceConstruction.bytes,AttentionInitialTailConstruction.extent,
    AttentionTailWorkspaceConstruction.bytes,SdpaWorkspace.bytes]
  omega

def next (frontier : Frontier) (layer : ResidualAttention.Layer) : Frontier where
  cursor := frontier.cursor+AttentionInitialWorkspaceConstruction.bytes (layer:=layer)
  aligned := by rw [Nat.add_mod,frontier.aligned,bytes_aligned]

theorem output_bound : Before (workspace.base+AttentionInitialWorkspaceConstruction.bytes (layer:=layer))
    (trace workspace angle keyCopied valueCopied).buffer.base 10240 := by
  rw [buffer_base]
  exact workspace.output_bound angle keyCopied valueCopied

theorem cache_bound : DecodePreservation.StageProtected
    (Before (workspace.base+AttentionInitialWorkspaceConstruction.bytes (layer:=layer)))
    (.attention layer) (layer.cacheAfter input angle cache) (trace workspace angle keyCopied valueCopied).cacheAfter.storage := by
  rw [cache_storage]
  have bound := workspace.cache_bound angle keyCopied valueCopied
  have ordered : workspace.tailBase≤workspace.base+AttentionInitialWorkspaceConstruction.bytes (layer:=layer) := by
    dsimp [Workspace.tailBase,AttentionInitialWorkspaceConstruction.bytes]
    omega
  exact ⟨bound.1.trans ordered,bound.2.trans ordered⟩

end Inference.Models.Qwen.AttentionInitialStageConstruction
