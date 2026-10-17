import models.qwen.AttentionNormalizationMemory
import kernels.normalization.MlxRmsHeadReduction

namespace Inference.Models.Qwen.AttentionParsedHeadNormalization
open Contracts.Mlx Kernels Kernels.Normalization
set_option maxRecDepth 10000

variable {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF}
  {phase : AttentionAffineMemory.Execution layer.projections input}
  {copy : AttentionQueryMemory.Execution phase}
  {parameters : AttentionParameterMemory.Storage layer copy.copy.memory}

-- Dispatch uses the real selected 256-wide heads: 24 query rows and four
-- key rows, each one 64 threads. Native metadata attachment stays explicit.
theorem selected_dispatch (kernel : MlxRmsHostSelection.KernelLimit) (capacity : 64≤kernel.threads) :
    MlxRmsHostSelection.select (MlxRmsHeadHostSelection.metadata 24 256 true) kernel=
      some ⟨256,24,false,1,64,1536,.donated⟩ ∧
    MlxRmsHostSelection.select (MlxRmsHeadHostSelection.metadata 4 256 true) kernel=
      some ⟨256,4,false,1,64,256,.donated⟩ :=
  ⟨MlxRmsHeadHostSelection.selected_query kernel capacity,MlxRmsHeadHostSelection.selected_key kernel capacity⟩

-- Query normalization starts on the copied query heap; key normalization
-- starts on the resulting query heap and preserves that already-written row
-- set. Every source event uses parsed caches and current-heap weight reads.
theorem source_chain (execution : AttentionNormalizationMemory.Execution copy parameters) :
    ∃ queryAfter keyAfter,
      MlxRmsHeadMemory.Executes (AttentionNormalizationMemory.queryInput copy parameters) execution.query
        (ReadBeforeOverwrite.initial copy.copy.memory) execution.query.reads.events queryAfter ∧
      MlxRmsHeadMemory.Executes
        (AttentionNormalizationMemory.keyInput copy parameters execution.query execution.keySafe execution.scaleSafe) execution.key
        (ReadBeforeOverwrite.initial queryAfter.memory) execution.key.reads.events keyAfter ∧
      keyAfter.memory=execution.memory := by
  have query := MlxRmsHeadMemory.checked (AttentionNormalizationMemory.queryInput copy parameters) execution.query (by decide)
  have key := MlxRmsHeadMemory.checked
    (AttentionNormalizationMemory.keyInput copy parameters execution.query execution.keySafe execution.scaleSafe) execution.key (by decide)
  refine ⟨execution.query.reads.after,execution.key.reads.after,query.1,?_,key.2⟩
  rw [query.2]
  exact key.1

theorem query_inverse (execution : AttentionNormalizationMemory.Execution copy parameters) (head : Fin 24)
    (before inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat) :
    ∃ after, MlxRmsHeadReduction.executeSource (AttentionNormalizationMemory.queryInput copy parameters)
      layer.preparation.qNorm.platform head AttentionHeads.width Blocks.eps
      before inverseBefore scratchBase inverseBase=some after ∧ after.phase=7 ∧
      after.inverse inverseBase=MlxRmsHeadMemory.inverseWords
        (AttentionNormalizationMemory.queryInput copy parameters) execution.query head 0 := by
  exact ⟨_,MlxRmsHeadReduction.source_execution _ _ _ _ _ _ _ _ _,rfl,
    MlxRmsHeadReduction.factor_read _ execution.query head before inverseBefore scratchBase inverseBase⟩

theorem key_inverse (execution : AttentionNormalizationMemory.Execution copy parameters) (head : Fin 4)
    (before inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat) :
    ∃ after, MlxRmsHeadReduction.executeSource
      (AttentionNormalizationMemory.keyInput copy parameters execution.query execution.keySafe execution.scaleSafe)
      layer.preparation.kNorm.platform head AttentionHeads.width Blocks.eps
      before inverseBefore scratchBase inverseBase=some after ∧ after.phase=7 ∧
      after.inverse inverseBase=MlxRmsHeadMemory.inverseWords
        (AttentionNormalizationMemory.keyInput copy parameters execution.query execution.keySafe execution.scaleSafe) execution.key head 0 := by
  exact ⟨_,MlxRmsHeadReduction.source_execution _ _ _ _ _ _ _ _ _,rfl,
    MlxRmsHeadReduction.factor_read _ execution.key head before inverseBefore scratchBase inverseBase⟩

end Inference.Models.Qwen.AttentionParsedHeadNormalization
