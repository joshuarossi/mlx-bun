import models.qwen.AttentionGateCopyParsedQkv
import models.qwen.AttentionGateCopyParsedHeadNormalization
import models.qwen.AttentionGateCopyParsedRope
import models.qwen.AttentionGateCopyCapacityParsedResult

import models.qwen.AttentionGateCopyPositiveSources
import models.qwen.AttentionGateCopyFreshSources

namespace Inference.Models.Qwen.AttentionGateCopyCapacityParsedPipeline
open Contracts.Mlx Kernels Kernels.Attention Kernels.Normalization State Layers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2D.labels Copy2DMemory.programs

variable {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {s : AttentionGateCopyReadConstruction.Input layer cache values angle}
  {preparation : AttentionGateCopyFreshRead.Prepared s}
  (read : AttentionGateCopyFreshRead.Read preparation)
  (attention : AttentionGateCopyCapacityParsedDispatch.Attention read)
  (tail : AttentionTailMemory.Execution attention (layer.heads values angle).gate layer.gate layer.output)

structure Certificate (before : Nat → Float32)
    (inputs : AttentionGateCopyPositiveSources.Inputs preparation.preparation)
    (supported : n+1≤262144) : Prop where
  preparationSource : AttentionGateCopyPositiveSources.PreparationSource preparation.preparation inputs (by omega)
  cacheSource : AttentionGateCopyFreshSources.Certificate read supported
  caller : AttentionKvCallerSelection.select n 1 (AttentionKvCallerSelection.model n)=
    some (AttentionGateCopyPositiveSources.route preparation.preparation)
  projections : AttentionGateCopyParsedQkv.Certificate s.front.phase before
  queryCopy : ∃ programs,
    MlxAttentionGateCopyMemory.sourcePrograms s.front.phase.queryGateBuffer.base
      (2*s.front.queryCopy.destination)=some programs ∧
    ThreadgroupWrites.Executes programs s.front.queryCopy.copy.schedule s.front.queryCopy.copy.remaining ∧
    ThreadgroupWrites.AtBarrier s.front.queryCopy.copy.remaining ∧
    CopyExecution.execute s.front.queryCopy.copy.schedule s.front.phase.memory=s.front.queryCopy.copy.memory
  normalization : ∃ queryAfter keyAfter,
    MlxRmsHeadMemory.Executes (AttentionGateCopyNormalizationMemory.queryInput s.front.queryCopy s.front.parameters)
      s.front.normal.query (ReadBeforeOverwrite.initial s.front.queryCopy.copy.memory)
      s.front.normal.query.reads.events queryAfter ∧
    MlxRmsHeadMemory.Executes
      (AttentionGateCopyNormalizationMemory.keyInput s.front.queryCopy s.front.parameters s.front.normal.query
        s.front.normal.keySafe s.front.normal.scaleSafe) s.front.normal.key
      (ReadBeforeOverwrite.initial queryAfter.memory) s.front.normal.key.reads.events keyAfter ∧
    keyAfter.memory=s.front.normal.memory
  queryReduction : ∀ (head : Fin 24) (words inverseWords : M1Max.WordMemory) (scratchBase inverseBase : Nat),
    ∃ after, MlxRmsHeadReduction.executeSource
      (AttentionGateCopyNormalizationMemory.queryInput s.front.queryCopy s.front.parameters)
      layer.preparation.qNorm.platform head AttentionHeads.width Blocks.eps
      words inverseWords scratchBase inverseBase=some after ∧ after.phase=7 ∧
      after.inverse inverseBase=MlxRmsHeadMemory.inverseWords
        (AttentionGateCopyNormalizationMemory.queryInput s.front.queryCopy s.front.parameters)
        s.front.normal.query head 0
  keyReduction : ∀ (head : Fin 4) (words inverseWords : M1Max.WordMemory) (scratchBase inverseBase : Nat),
    ∃ after, MlxRmsHeadReduction.executeSource
      (AttentionGateCopyNormalizationMemory.keyInput s.front.queryCopy s.front.parameters s.front.normal.query
        s.front.normal.keySafe s.front.normal.scaleSafe)
      layer.preparation.kNorm.platform head AttentionHeads.width Blocks.eps
      words inverseWords scratchBase inverseBase=some after ∧ after.phase=7 ∧
      after.inverse inverseBase=MlxRmsHeadMemory.inverseWords
        (AttentionGateCopyNormalizationMemory.keyInput s.front.queryCopy s.front.parameters s.front.normal.query
          s.front.normal.keySafe s.front.normal.scaleSafe) s.front.normal.key head 0
  queryRotation : MlxRopeSingleMemory.Executes layer.preparation.rotation s.front.rope.query.preparation.destination
    (fun _ => RopeAngles.value layer.preparation.angles angle)
    (RopeRowsDynamicMemory.initial s.front.rope.query.preparation.output.memory)
    s.front.rope.query.rotation.events s.front.rope.query.rotation.finish
  keyRotation : MlxRopeSingleMemory.Executes layer.preparation.rotation s.front.rope.key.preparation.destination
    (fun _ => RopeAngles.value layer.preparation.angles angle)
    (RopeRowsDynamicMemory.initial s.front.rope.key.preparation.output.memory)
    s.front.rope.key.rotation.events s.front.rope.key.rotation.finish
  angles : ∀ lane, MlxRopeSingleAngles.source layer.preparation.angles angle lane=
    some (RopeAngles.value layer.preparation.angles angle lane)
  result : AttentionGateCopyCapacityParsedResult.Certificate read attention tail before

-- All stages refer to this one staged front end and ReadPlan. No result tensor
-- is supplied to bridge the source phases. Native descriptors, completion and
-- numerical primitive contracts remain fields of the participating executions.
theorem checked (before : Nat → Float32)
    (inputs : AttentionGateCopyPositiveSources.Inputs preparation.preparation)
    (queryFinite : layer.projections.q.Finite values)
    (keyFinite : layer.projections.k.Finite values)
    (valueFinite : layer.projections.v.Finite values)
    (gateLink : tail.gates=read.gate) (supported : n+1≤262144)
    (finite : ∀ head, SdpaDispatched.Finite layer.attention layer.mergeContracted layer.architectureSuffix
      ((layer.heads values angle).query head)
      ((layer.cacheAfter values angle cache).keys (SdpaScore.kvHead head))
      ((layer.cacheAfter values angle cache).values (SdpaScore.kvHead head)))
    (outputFinite : layer.output.Finite
      (OutputGateMemory.values layer.gate attention.output (layer.heads values angle).gate)) :
    Certificate read attention tail before inputs supported :=
  ⟨AttentionGateCopyPositiveSources.preparation_checked _ inputs (by omega),
    AttentionGateCopyFreshSources.checked read supported,
    AttentionGateCopyPositiveSources.caller_selected _ preparation.positive,
    AttentionGateCopyParsedQkv.checked s.front.phase before queryFinite keyFinite valueFinite,
    s.front.queryCopy.parsed_programs,
    AttentionGateCopyParsedHeadNormalization.source_chain s.front.normal,
    AttentionGateCopyParsedHeadNormalization.query_inverse s.front.normal,
    AttentionGateCopyParsedHeadNormalization.key_inverse s.front.normal,
    AttentionGateCopyParsedRope.query_source s.front.rope,
    AttentionGateCopyParsedRope.key_source s.front.rope,
    AttentionGateCopyParsedRope.angle_source,
    AttentionGateCopyCapacityParsedResult.checked read attention tail before gateLink supported finite outputFinite⟩

end Inference.Models.Qwen.AttentionGateCopyCapacityParsedPipeline
