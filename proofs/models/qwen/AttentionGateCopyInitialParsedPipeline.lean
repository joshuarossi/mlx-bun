import models.qwen.AttentionGateCopyInitialSources
import models.qwen.AttentionGateCopyParsedQkv
import models.qwen.AttentionGateCopyParsedHeadNormalization
import models.qwen.AttentionGateCopyParsedRope
import models.qwen.AttentionGateCopyInitialParsedResult

namespace Inference.Models.Qwen.AttentionGateCopyInitialParsedPipeline
open Contracts.Mlx Kernels Kernels.Attention Kernels.Normalization State Layers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2D.labels Copy2DMemory.programs

variable {layer : Attention.Layer} {cache : Kv.Cache Kv.BF 0}
  {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {front : AttentionGateCopyFront.Execution layer values angle}
  (read : AttentionGateCopyInitialRead.Read front cache)
  (attention : AttentionGateCopyInitialParsedDispatch.Attention read)
  (tail : AttentionTailMemory.Execution attention (layer.heads values angle).gate layer.gate layer.output)

structure Certificate (sources : InitialKvSourceMemory.Sources read.kv.zeros) (before : Nat → Float32) : Prop where
  cacheSource : AttentionGateCopyInitialSources.Certificate read sources
  projections : AttentionGateCopyParsedQkv.Certificate front.phase before
  queryCopy : ∃ programs,
    MlxAttentionGateCopyMemory.sourcePrograms front.phase.queryGateBuffer.base
      (2*front.queryCopy.destination)=some programs ∧
    ThreadgroupWrites.Executes programs front.queryCopy.copy.schedule front.queryCopy.copy.remaining ∧
    ThreadgroupWrites.AtBarrier front.queryCopy.copy.remaining ∧
    CopyExecution.execute front.queryCopy.copy.schedule front.phase.memory=front.queryCopy.copy.memory
  normalization : ∃ queryAfter keyAfter,
    MlxRmsHeadMemory.Executes (AttentionGateCopyNormalizationMemory.queryInput front.queryCopy front.parameters)
      front.normal.query (ReadBeforeOverwrite.initial front.queryCopy.copy.memory)
      front.normal.query.reads.events queryAfter ∧
    MlxRmsHeadMemory.Executes
      (AttentionGateCopyNormalizationMemory.keyInput front.queryCopy front.parameters front.normal.query
        front.normal.keySafe front.normal.scaleSafe) front.normal.key
      (ReadBeforeOverwrite.initial queryAfter.memory) front.normal.key.reads.events keyAfter ∧
    keyAfter.memory=front.normal.memory
  queryReduction : ∀ (head : Fin 24) (words inverseWords : M1Max.WordMemory) (scratchBase inverseBase : Nat),
    ∃ after, MlxRmsHeadReduction.executeSource
      (AttentionGateCopyNormalizationMemory.queryInput front.queryCopy front.parameters)
      layer.preparation.qNorm.platform head AttentionHeads.width Blocks.eps
      words inverseWords scratchBase inverseBase=some after ∧ after.phase=7 ∧
      after.inverse inverseBase=MlxRmsHeadMemory.inverseWords
        (AttentionGateCopyNormalizationMemory.queryInput front.queryCopy front.parameters)
        front.normal.query head 0
  keyReduction : ∀ (head : Fin 4) (words inverseWords : M1Max.WordMemory) (scratchBase inverseBase : Nat),
    ∃ after, MlxRmsHeadReduction.executeSource
      (AttentionGateCopyNormalizationMemory.keyInput front.queryCopy front.parameters front.normal.query
        front.normal.keySafe front.normal.scaleSafe)
      layer.preparation.kNorm.platform head AttentionHeads.width Blocks.eps
      words inverseWords scratchBase inverseBase=some after ∧ after.phase=7 ∧
      after.inverse inverseBase=MlxRmsHeadMemory.inverseWords
        (AttentionGateCopyNormalizationMemory.keyInput front.queryCopy front.parameters front.normal.query
          front.normal.keySafe front.normal.scaleSafe) front.normal.key head 0
  queryRotation : MlxRopeSingleMemory.Executes layer.preparation.rotation front.rope.query.preparation.destination
    (fun _ => RopeAngles.value layer.preparation.angles angle)
    (RopeRowsDynamicMemory.initial front.rope.query.preparation.output.memory)
    front.rope.query.rotation.events front.rope.query.rotation.finish
  keyRotation : MlxRopeSingleMemory.Executes layer.preparation.rotation front.rope.key.preparation.destination
    (fun _ => RopeAngles.value layer.preparation.angles angle)
    (RopeRowsDynamicMemory.initial front.rope.key.preparation.output.memory)
    front.rope.key.rotation.events front.rope.key.rotation.finish
  angles : ∀ lane, MlxRopeSingleAngles.source layer.preparation.angles angle lane=
    some (RopeAngles.value layer.preparation.angles angle lane)
  result : AttentionGateCopyInitialParsedResult.Certificate read attention tail before

-- All stages refer to this one staged front end and ReadPlan. No result tensor
-- is supplied to bridge the source phases. Native descriptors, completion and
-- numerical primitive contracts remain fields of the participating executions.
theorem checked (sources : InitialKvSourceMemory.Sources read.kv.zeros) (before : Nat → Float32)
    (queryFinite : layer.projections.q.Finite values)
    (keyFinite : layer.projections.k.Finite values)
    (valueFinite : layer.projections.v.Finite values)
    (gateLink : tail.gates=read.gate)
    (finite : ∀ head, SdpaDispatched.Finite layer.attention layer.mergeContracted layer.architectureSuffix
      ((layer.heads values angle).query head)
      ((layer.cacheAfter values angle cache).keys (SdpaScore.kvHead head))
      ((layer.cacheAfter values angle cache).values (SdpaScore.kvHead head)))
    (outputFinite : layer.output.Finite
      (OutputGateMemory.values layer.gate attention.output (layer.heads values angle).gate)) :
    Certificate read attention tail sources before :=
  ⟨AttentionGateCopyInitialSources.checked read sources,
    AttentionGateCopyParsedQkv.checked front.phase before queryFinite keyFinite valueFinite,
    front.queryCopy.parsed_programs,
    AttentionGateCopyParsedHeadNormalization.source_chain front.normal,
    AttentionGateCopyParsedHeadNormalization.query_inverse front.normal,
    AttentionGateCopyParsedHeadNormalization.key_inverse front.normal,
    AttentionGateCopyParsedRope.query_source front.rope,
    AttentionGateCopyParsedRope.key_source front.rope,
    AttentionGateCopyParsedRope.angle_source,
    AttentionGateCopyInitialParsedResult.checked read attention tail before gateLink finite outputFinite⟩

end Inference.Models.Qwen.AttentionGateCopyInitialParsedPipeline
