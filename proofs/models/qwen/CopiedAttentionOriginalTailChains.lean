import models.qwen.CopiedAttentionInitialTailFactory
import models.qwen.CopiedAttentionCapacityTailFactory
import models.qwen.InitialCopiedTokenConstruction
import models.qwen.CapacityCopiedTokenConstruction
namespace Inference.Models.Qwen.CopiedAttentionOriginalTailChains
open Contracts.Mlx Layers DecodeStage DecodeChain TokenInference Kernels.Attention
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

namespace Initial
open InitialCopiedParameterConstruction
open DecodeParameterConstruction (remainingParameters)


def StageBuilt : (kind : Stage) → (cache : Cache kind 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.StageBuffer kind cache source.bytes) →
    (parameters : DecodeParameterMemory.StageStorage kind source.bytes) →
    StagePlan kind cache input angle source storage parameters → Prop
  | .delta _,_,_,_,_,_,_,_ => True
  | .attention _,_,_,_,source,_,parameters,plan => CopiedAttentionInitialTailFactory.InitialBuilt source parameters plan.1

def Built : (stages : List Stage) → (cursor : DecodeParameterConstruction.Cursor all stages) →
    (cache : Caches stages 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    (parameters : DecodeParameterMemory.Storage all source.bytes) →
    ChainPlan stages cursor cache input angle source storage parameters → Prop
  | [],_,_,_,_,_,_,_,_ => True
  | kind::rest,cursor,cache,input,angle,source,storage,parameters,plan =>
    StageBuilt kind cache.1 input angle source storage.1 (remainingParameters cursor parameters).1 plan.1.first ∧
      Built rest (.next cursor) cache.2 (forward kind cache.1 input angle) angle plan.1.step.first.buffer
        plan.1.step.nextStorage plan.1.nextParameters plan.2

variable {all : List Stage} {kind : Stage} {rest : List Stage}
  {cursor : DecodeParameterConstruction.Cursor all (kind::rest)}
  {cache : Caches (kind::rest) 0} {input : Row BF} {angle : RopeAngles.Inputs}
  {source : ArrayStorage.BFBuffer input} {storage : DecodeFrame.Storage (kind::rest) cache source.bytes}
  {parameters : DecodeParameterMemory.Storage all source.bytes}
  (plan : ChainPlan (kind::rest) cursor cache input angle source storage parameters)

theorem first (built : Built (kind::rest) cursor cache input angle source storage parameters plan) :
    StageBuilt kind cache.1 input angle source storage.1 (remainingParameters cursor parameters).1 plan.1.first := built.1

theorem remaining (built : Built (kind::rest) cursor cache input angle source storage parameters plan) :
    Built rest (.next cursor) cache.2 (forward kind cache.1 input angle) angle plan.1.step.first.buffer
      plan.1.step.nextStorage plan.1.nextParameters plan.2 := built.2

variable {p : Pipeline}  {before : TokenAutoregressiveMemory.State p 0}
  {original : TokenParameterMemory.Storage p before.index.bytes} {sampling : Kernels.Sampling.LogSumExpRanges.Platform}

def TokenBuilt (plan : InitialCopiedTokenConstruction.Plan original angle sampling) : Prop :=
  Built p.graph.stages .root before.logical.cache (p.embedding.forward before.logical.token) angle
    plan.embedding.entry.source plan.embedding.entry.storage plan.embedding.afterEmbedding.graph.stages plan.graph.body.chain
end Initial

namespace Capacity
open CapacityAttentionParameterConstruction
variable {n : Nat}

def StageBuilt : (kind : Stage) → (cache : Cache kind n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.StageBuffer kind cache source.bytes) →
    (parameters : DecodeParameterMemory.StageStorage kind source.bytes) →
    StagePlan kind cache input angle source storage parameters → Prop
  | .delta _,_,_,_,_,_,_,_ => True
  | .attention _,_,_,_,source,_,parameters,plan => CopiedAttentionCapacityTailFactory.CapacityBuilt source parameters plan

def Built : (stages : List Stage) → (cursor : CapacityAttentionParameterConstruction.Cursor all stages) →
    (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    (parameters : DecodeParameterMemory.Storage all source.bytes) →
    ChainPlan stages cursor cache input angle source storage parameters → Prop
  | [],_,_,_,_,_,_,_,_ => True
  | kind::rest,cursor,cache,input,angle,source,storage,parameters,plan =>
    StageBuilt kind cache.1 input angle source storage.1 (remainingParameters cursor parameters).1 plan.1.first ∧
      Built rest (.next cursor) cache.2 (forward kind cache.1 input angle) angle plan.1.step.first.buffer
        plan.1.step.nextStorage plan.1.nextParameters plan.2

variable {all : List Stage} {kind : Stage} {rest : List Stage}
  {cursor : CapacityAttentionParameterConstruction.Cursor all (kind::rest)}
  {cache : Caches (kind::rest) n} {input : Row BF} {angle : RopeAngles.Inputs}
  {source : ArrayStorage.BFBuffer input} {storage : DecodeFrame.Storage (kind::rest) cache source.bytes}
  {parameters : DecodeParameterMemory.Storage all source.bytes}
  (plan : ChainPlan (kind::rest) cursor cache input angle source storage parameters)

theorem first (built : Built (kind::rest) cursor cache input angle source storage parameters plan) :
    StageBuilt kind cache.1 input angle source storage.1 (remainingParameters cursor parameters).1 plan.1.first := built.1

theorem remaining (built : Built (kind::rest) cursor cache input angle source storage parameters plan) :
    Built rest (.next cursor) cache.2 (forward kind cache.1 input angle) angle plan.1.step.first.buffer
      plan.1.step.nextStorage plan.1.nextParameters plan.2 := built.2

variable {p : Pipeline} {time : Nat} {before : TokenAutoregressiveMemory.State p (time+1)}
  {original : TokenParameterMemory.Storage p before.index.bytes} {sampling : Kernels.Sampling.LogSumExpRanges.Platform}

def TokenBuilt (plan : CapacityCopiedTokenConstruction.Plan original angle sampling) : Prop :=
  Built (n:=time+1) p.graph.stages .root before.logical.cache (p.embedding.forward before.logical.token) angle
    plan.embedding.entry.source plan.embedding.entry.storage plan.embedding.afterEmbedding.graph.stages plan.graph.body.chain
end Capacity

end Inference.Models.Qwen.CopiedAttentionOriginalTailChains
