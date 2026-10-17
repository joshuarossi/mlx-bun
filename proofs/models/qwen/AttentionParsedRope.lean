import models.qwen.AttentionRopeDispatchMemory
import kernels.attention.MlxRopeSingleDispatch

namespace Inference.Models.Qwen.AttentionParsedRope
open Contracts.Mlx Kernels Kernels.Attention

variable {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF}
  {phase : AttentionAffineMemory.Execution layer.projections input}
  {copy : AttentionQueryMemory.Execution phase}
  {parameters : AttentionParameterMemory.Storage layer copy.copy.memory}
  {normal : AttentionNormalizationMemory.Execution copy parameters} {angle : RopeAngles.Inputs}

-- Standard-attention query24/key4: each parsed kernel acts on the complete
-- head preparation, then key runs on the CURRENT heap left by query.
theorem query_source (execution : AttentionRopeDispatchMemory.Execution normal angle) :
    MlxRopeSingleMemory.Executes layer.preparation.rotation execution.query.preparation.destination
      (fun _ => RopeAngles.value layer.preparation.angles angle)
      (RopeRowsDynamicMemory.initial execution.query.preparation.output.memory)
      execution.query.rotation.events execution.query.rotation.finish :=
  (MlxRopeSingleDispatch.selected_execution execution.query).1

theorem key_source (execution : AttentionRopeDispatchMemory.Execution normal angle) :
    MlxRopeSingleMemory.Executes layer.preparation.rotation execution.key.preparation.destination
      (fun _ => RopeAngles.value layer.preparation.angles angle)
      (RopeRowsDynamicMemory.initial execution.key.preparation.output.memory)
      execution.key.rotation.events execution.key.rotation.finish :=
  (MlxRopeSingleDispatch.selected_execution execution.key).1

theorem current_heap (execution : AttentionRopeDispatchMemory.Execution normal angle) :
    (AttentionRopeDispatchMemory.keyInput normal angle execution.query execution.keySafe).memory=
      execution.query.rotation.finish.memory ∧
    execution.memory=execution.key.rotation.finish.memory := ⟨rfl,rfl⟩

theorem angle_source (lane : Fin 32) :
    MlxRopeSingleAngles.source layer.preparation.angles angle lane=
      some (RopeAngles.value layer.preparation.angles angle lane) :=
  MlxRopeSingleAngles.selected_theta _ _ _

end Inference.Models.Qwen.AttentionParsedRope
