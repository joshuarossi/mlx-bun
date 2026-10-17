import models.qwen.InitialCopiedParameterConstruction
import models.qwen.TokenEmbeddingParsedConstruction
import models.qwen.NativeCopiedTokenState
import models.qwen.FinalParameterFrameBases

namespace Inference.Models.Qwen.InitialCopiedTokenConstruction
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling TokenAutoregressiveMemoryConstruction
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

variable {p : Pipeline} {before : TokenAutoregressiveMemory.State p 0}
  {original : TokenParameterMemory.Storage p before.index.bytes}

def ChainPlan (embedding : TokenParameterConstruction.EmbeddingPlan original) (angle : RopeAngles.Inputs) :=
  InitialCopiedParameterConstruction.ChainPlan p.graph.stages .root before.logical.cache
    (p.embedding.forward before.logical.token) angle embedding.entry.source embedding.entry.storage
    embedding.afterEmbedding.graph.stages

def buildChain (embedding : TokenParameterConstruction.EmbeddingPlan original) {angle : RopeAngles.Inputs}
    (plan : ChainPlan embedding angle) :=
  InitialCopiedParameterConstruction.chain p.graph.stages .root before.logical.cache
    (p.embedding.forward before.logical.token) angle embedding.entry.source embedding.entry.storage
    embedding.afterEmbedding.graph.stages plan

def ChainSafe (embedding : TokenParameterConstruction.EmbeddingPlan original) {angle : RopeAngles.Inputs}
    (plan : ChainPlan embedding angle) (base size : Nat) : Prop :=
  InitialCopiedDecodeChain.Safe p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle
    embedding.entry.source embedding.entry.storage (buildChain embedding plan) base size

def ChainCaches (embedding : TokenParameterConstruction.EmbeddingPlan original) {angle : RopeAngles.Inputs}
    (plan : ChainPlan embedding angle) :=
  InitialCopiedParameterConstruction.CacheRegions p.graph.stages .root before.logical.cache
    (p.embedding.forward before.logical.token) angle embedding.entry.source embedding.entry.storage
    embedding.afterEmbedding.graph.stages plan

private theorem entry_cache_linked (entry : Entry before)
    (linked : entry.source=entry.embedding.forwardBuffer) :
    entry.storage = TokenAutoregressiveMemory.transportCaches (congrArg ArrayStorage.BFBuffer.bytes linked).symm
      (TokenAutoregressiveMemory.embeddingCaches before entry.embedding rfl entry.caches) := by
  have same : linked=rfl := Subsingleton.elim _ _
  rw [same]
  rfl

attribute [local irreducible] Entry.source Entry.storage TokenParameterConstruction.EmbeddingPlan.afterEmbedding

structure BodyPlan (embedding : TokenParameterConstruction.EmbeddingPlan original) (angle : RopeAngles.Inputs) where
  chain : ChainPlan embedding angle
  caches : ChainCaches embedding chain
  parameters : embedding.afterEmbedding.Protected (ChainSafe embedding chain)

variable {embedding : TokenParameterConstruction.EmbeddingPlan original} {angle : RopeAngles.Inputs}

def BodyPlan.hiddenBuffer (body : BodyPlan embedding angle) :
    ArrayStorage.BFBuffer (p.graph.hidden before.logical.cache (p.embedding.forward before.logical.token) angle) :=
  InitialCopiedDecodeChain.outputBuffer p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle
    embedding.entry.source embedding.entry.storage (buildChain embedding body.chain)

theorem BodyPlan.hidden_eq (body : BodyPlan embedding angle) : body.hiddenBuffer=
    InitialCopiedDecodeChain.outputBuffer p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle
      embedding.entry.source embedding.entry.storage (buildChain embedding body.chain) := rfl

theorem BodyPlan.hidden_bytes (body : BodyPlan embedding angle) : body.hiddenBuffer.bytes=
    (InitialCopiedDecodeChain.outputBuffer p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle
      embedding.entry.source embedding.entry.storage (buildChain embedding body.chain)).bytes := rfl

attribute [local irreducible] BodyPlan.hiddenBuffer

theorem BodyPlan.frame (body : BodyPlan embedding angle) (safe : ChainSafe embedding body.chain base size)
    (offset : Nat) (bound : offset<size) : body.hiddenBuffer.bytes (base+offset)=embedding.entry.source.bytes (base+offset) :=
  (congrFun body.hidden_bytes _).trans
    (InitialCopiedDecodeChain.other_region p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle
      embedding.entry.source embedding.entry.storage (buildChain embedding body.chain) base size safe offset bound)

-- The vocabulary head and final normalization are also taken from the one
-- original bundle, on the actual output heap of its constructed 64 stages.
def BodyPlan.finalStorage (body : BodyPlan embedding angle) :
    FinalProjectionConstruction.Storage p.graph.finalNorm p.graph.output
      (p.graph.hidden before.logical.cache (p.embedding.forward before.logical.token) angle) :=
  FinalProjectionConstruction.fromFrame embedding.entry.source.bytes body.hiddenBuffer (ChainSafe embedding body.chain)
    (fun _ _ safe => body.frame safe) embedding.afterEmbedding.graph.norm embedding.afterEmbedding.graph.normShared
    embedding.afterEmbedding.graph.output embedding.afterEmbedding.graph.outputShared
    body.parameters.2.2.2.2.1 body.parameters.2.2.2.2.2

theorem BodyPlan.final_source (body : BodyPlan embedding angle) : body.finalStorage.source=body.hiddenBuffer := rfl

theorem BodyPlan.final_norm_base (body : BodyPlan embedding angle) :
    body.finalStorage.normWeights.base=original.graph.norm.base :=
  (FinalParameterFrameBases.fromFrame_norm_base embedding.entry.source.bytes body.hiddenBuffer (ChainSafe embedding body.chain)
    (fun _ _ safe => body.frame safe) embedding.afterEmbedding.graph.norm embedding.afterEmbedding.graph.normShared
    embedding.afterEmbedding.graph.output embedding.afterEmbedding.graph.outputShared
    body.parameters.2.2.2.2.1 body.parameters.2.2.2.2.2).trans
      (FinalParameterFrameBases.afterEmbedding_norm_base embedding)

structure GraphPlan (embedding : TokenParameterConstruction.EmbeddingPlan original) (angle : RopeAngles.Inputs) where
  body : BodyPlan embedding angle
  allocation : FinalProjectionConstruction.Allocation body.finalStorage

def GraphPlan.forward (plan : GraphPlan embedding angle) :
    Qwen38InitialCopiedExecution.Execution p.graph before.logical.cache (p.embedding.forward before.logical.token) angle where
  source := embedding.entry.source
  storage := embedding.entry.storage
  chain := buildChain embedding plan.body.chain
  safe := InitialCopiedParameterConstruction.cacheSafe p.graph.stages .root before.logical.cache
    (p.embedding.forward before.logical.token) angle embedding.entry.source embedding.entry.storage
    embedding.afterEmbedding.graph.stages plan.body.chain plan.body.caches
  finalParameters := plan.body.finalStorage
  linked := plan.body.final_source.trans plan.body.hidden_eq
  allocation := plan.allocation

theorem GraphPlan.source (plan : GraphPlan embedding angle) : plan.forward.source=embedding.entry.source := rfl
theorem GraphPlan.storage (plan : GraphPlan embedding angle) : plan.forward.storage=embedding.entry.storage := rfl

variable {sampling : LogSumExpRanges.Platform}

def GraphPlan.execution (plan : GraphPlan embedding angle)
    (sampler : FinalProjectionSamplerSource.Execution plan.forward.finalParameters plan.forward.allocation sampling) :
    InitialCopiedTokenSource.Execution p sampling before.logical.cache before.logical.token angle where
  embedding := embedding.entry.embedding
  forward := plan.forward
  linked := by rw [plan.source]; unfold Entry.source; rfl
  final := sampler

structure Plan (original : TokenParameterMemory.Storage p before.index.bytes) (angle : RopeAngles.Inputs)
    (sampling : LogSumExpRanges.Platform) where
  embedding : TokenParameterConstruction.EmbeddingPlan original
  graph : GraphPlan embedding angle
  headSafe : Qwen38InitialCopiedCache.Safe graph.forward
  sampler : FinalProjectionSamplerSource.Execution graph.forward.finalParameters graph.forward.allocation sampling
  samplerSafe : InitialCopiedTokenCache.Safe (graph.execution sampler) headSafe

def Plan.execution (plan : Plan original angle sampling) := plan.graph.execution plan.sampler

def Plan.step (plan : Plan original angle sampling) : NativeCopiedTokenState.Step p sampling before angle where
  execution := .initial plan.execution
  tokenLinked := rfl
  embeddingSafe := plan.embedding.caches
  cacheLinked := by
    change plan.graph.forward.storage = _
    rw [plan.graph.storage]
    exact entry_cache_linked plan.embedding.entry (by unfold Entry.source; rfl)
  safe := ⟨plan.headSafe,plan.samplerSafe⟩

theorem Plan.embedding_weights (plan : Plan original angle sampling) :
    (NativeCopiedTokenRoute.embedding plan.step.execution).storage=original.embedding := rfl

theorem Plan.original_token (plan : Plan original angle sampling) :
    (NativeCopiedTokenRoute.embedding plan.step.execution).tokenBuffer=before.index := rfl

theorem Plan.final_norm_base (plan : Plan original angle sampling) :
    (NativeCopiedTokenRoute.finalStorage plan.step.execution).normWeights.base=original.graph.norm.base :=
  plan.graph.body.final_norm_base

end Inference.Models.Qwen.InitialCopiedTokenConstruction
