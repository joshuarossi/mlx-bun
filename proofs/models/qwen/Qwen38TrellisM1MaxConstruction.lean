import models.qwen.Qwen38TrellisM1MaxMemory
import models.qwen.DecodeMemoryConstruction
import models.qwen.FinalProjectionConstruction

namespace Inference.Models.Qwen.Qwen38TrellisM1MaxConstruction
open Contracts.Mlx Layers Qwen38TrellisM1Max DecodeStage Kernels.Attention
set_option maxRecDepth 10000
attribute [local irreducible] Graph.stages

variable {graph : Graph} {cache : graph.Cache n} {input : Row BF} {angle : RopeAngles.Inputs}
  {source : ArrayStorage.BFBuffer input} {storage : DecodeFrame.Storage graph.stages cache source.bytes}

def fromChain (chain : DecodeMemoryChain.Trace graph.stages cache input angle source storage)
    (chainSafe : DecodeMemoryChain.CacheSafe graph.stages cache input angle source storage chain)
    (parameters : FinalProjectionConstruction.Storage graph.finalNorm graph.output (graph.hidden cache input angle))
    (linked : parameters.source=DecodeMemoryChain.outputBuffer graph.stages cache input angle source storage chain)
    (allocation : FinalProjectionConstruction.Allocation parameters) :
    Qwen38TrellisM1MaxMemory.Execution graph cache input angle where
  source := source
  storage := storage
  chain := chain
  chainSafe := chainSafe
  normInput := FinalProjectionConstruction.normInput parameters
  normLinked := linked
  normalization := FinalProjectionConstruction.normalization parameters allocation
  projection := FinalProjectionConstruction.output parameters allocation
  projectionLinked := FinalProjectionConstruction.output_source parameters allocation

variable (plan : DecodeMemoryConstruction.ChainPlan graph.stages cache input angle source storage)

def chain := DecodeMemoryConstruction.chain graph.stages cache input angle source storage plan

def hiddenBuffer : ArrayStorage.BFBuffer (graph.hidden cache input angle) :=
  DecodeMemoryConstruction.outputBuffer graph.stages cache input angle source storage plan

theorem hidden_bytes : (hiddenBuffer plan).bytes=
    (DecodeMemoryChain.outputBuffer graph.stages cache input angle source storage (chain plan)).bytes := rfl

def Safe (base size : Nat) : Prop :=
  DecodeMemoryChain.Safe graph.stages cache input angle source storage (chain plan) base size

theorem hidden_frame {base size : Nat} (safe : Safe plan base size) (offset : Nat) (bound : offset<size) :
    (hiddenBuffer plan).bytes (base+offset)=source.bytes (base+offset) :=
  (congrFun (hidden_bytes plan) _).trans
    (DecodeMemoryChain.other_region graph.stages cache input angle source storage (chain plan) base size safe offset bound)

-- Original final-norm/output parameters survive all 64 layers. The final
-- projection constructor receives views of those same bytes and addresses.
def finalStorage (normWeights : ArrayStorage.BFBuffer graph.finalNorm.weight) (normShared : normWeights.bytes=source.bytes)
    (outputWeights : AffineDevice.Storage graph.output) (outputShared : AffineMemory.Shared graph.output outputWeights source.bytes)
    (normSafe : Safe plan normWeights.base 10240)
    (outputSafe : AffineMemoryFrames.Protected graph.output outputWeights (Safe plan)) :
    FinalProjectionConstruction.Storage graph.finalNorm graph.output (graph.hidden cache input angle) :=
  FinalProjectionConstruction.fromFrame source.bytes (hiddenBuffer plan) (Safe plan)
    (fun _ _ safe => hidden_frame plan safe) normWeights normShared outputWeights outputShared normSafe outputSafe

def fromStorage (cacheSafe : DecodeMemoryConstruction.CacheRegions graph.stages cache input angle source storage plan)
    (normWeights : ArrayStorage.BFBuffer graph.finalNorm.weight) (normShared : normWeights.bytes=source.bytes)
    (outputWeights : AffineDevice.Storage graph.output) (outputShared : AffineMemory.Shared graph.output outputWeights source.bytes)
    (normSafe : Safe plan normWeights.base 10240)
    (outputSafe : AffineMemoryFrames.Protected graph.output outputWeights (Safe plan))
    (allocation : FinalProjectionConstruction.Allocation
      (finalStorage plan normWeights normShared outputWeights outputShared normSafe outputSafe)) :
    Qwen38TrellisM1MaxMemory.Execution graph cache input angle :=
  fromChain (chain plan) (DecodeMemoryConstruction.cacheSafe graph.stages cache input angle source storage plan cacheSafe)
    (finalStorage plan normWeights normShared outputWeights outputShared normSafe outputSafe) rfl allocation

end Inference.Models.Qwen.Qwen38TrellisM1MaxConstruction
