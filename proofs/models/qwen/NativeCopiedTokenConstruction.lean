import models.qwen.InitialCopiedTokenConstruction
import models.qwen.CapacityCopiedTokenConstruction
import models.qwen.NativeCopiedTokenParameters
import models.qwen.CopiedAttentionOriginalTailChains
import models.qwen.FinalProjectionStorageLineage

namespace Inference.Models.Qwen.NativeCopiedTokenConstruction
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  CopiedAttentionOriginalTailChains.Initial.TokenBuilt CopiedAttentionOriginalTailChains.Capacity.TokenBuilt

-- Each branch starts with one original bundle on the preceding state heap.
-- Complete executions are constructed by the branch factory, not supplied
-- alongside a separate claim that unrelated parameters survived its writes.
-- Every attention tail must additionally be built from that stage's original
-- output weights and its actual copied gate buffer.
inductive Plan (p : Pipeline) (sampling : LogSumExpRanges.Platform) (angle : RopeAngles.Inputs) :
    {n : Nat} → (before : TokenAutoregressiveMemory.State p n) →
      TokenParameterMemory.Storage p before.index.bytes → Type where
  | initial {before : TokenAutoregressiveMemory.State p 0}
      {original : TokenParameterMemory.Storage p before.index.bytes}
      (plan : InitialCopiedTokenConstruction.Plan original angle sampling)
      (tails : CopiedAttentionOriginalTailChains.Initial.TokenBuilt plan) : Plan p sampling angle before original
  | positive {n : Nat} {before : TokenAutoregressiveMemory.State p (n+1)}
      {original : TokenParameterMemory.Storage p before.index.bytes}
      (plan : CapacityCopiedTokenConstruction.Plan original angle sampling)
      (tails : CopiedAttentionOriginalTailChains.Capacity.TokenBuilt plan) : Plan p sampling angle before original

variable {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform}
  {before : TokenAutoregressiveMemory.State p n} {angle : RopeAngles.Inputs}
  {original : TokenParameterMemory.Storage p before.index.bytes}

def step (plan : Plan p sampling angle before original) : NativeCopiedTokenState.Step p sampling before angle := match plan with
  | .initial plan _ => plan.step
  | .positive plan _ => plan.step

theorem embedding_weights (plan : Plan p sampling angle before original) :
    (NativeCopiedTokenRoute.embedding (step plan).execution).storage=original.embedding := by
  cases plan with
  | initial plan _ => exact plan.embedding_weights
  | positive plan _ => exact plan.embedding_weights

theorem original_token (plan : Plan p sampling angle before original) :
    (NativeCopiedTokenRoute.embedding (step plan).execution).tokenBuffer=before.index := (step plan).tokenLinked

theorem final_norm_base (plan : Plan p sampling angle before original) :
    (NativeCopiedTokenRoute.finalStorage (step plan).execution).normWeights.base=original.graph.norm.base := by
  cases plan with
  | initial plan _ => exact plan.final_norm_base
  | positive plan _ => exact plan.final_norm_base

theorem final_weights_addresses (plan : Plan p sampling angle before original) :
    AffineStorageLineage.addresses p.graph.output (NativeCopiedTokenRoute.finalStorage (step plan).execution).outputWeights=
      AffineStorageLineage.addresses p.graph.output original.graph.output := by
  cases plan with
  | initial plan _ => exact FinalProjectionStorageLineage.initial_addresses plan.graph.body
  | positive plan _ => exact FinalProjectionStorageLineage.capacity_addresses plan.graph.body

theorem final_launch_addresses (plan : Plan p sampling angle before original) :
    AffineStorageLineage.addresses p.graph.output (AffineStorageLineage.launchWeights
      (FinalProjectionConstruction.output (NativeCopiedTokenRoute.finalStorage (step plan).execution)
        (NativeCopiedTokenRoute.finalAllocation (step plan).execution)))=
      AffineStorageLineage.addresses p.graph.output original.graph.output :=
  (FinalProjectionStorageLineage.output_addresses _ _).trans (final_weights_addresses plan)

def Safe (plan : Plan p sampling angle before original) : Prop :=
  original.Protected (NativeCopiedTokenParameters.RegionSafe (step plan).execution)

def after (plan : Plan p sampling angle before original) (safe : Safe plan) :
    TokenParameterMemory.Storage p (NativeCopiedTokenRoute.final (step plan).execution).sampler.memory :=
  NativeCopiedTokenParameters.after (step plan) original safe

theorem output_addresses_after (plan : Plan p sampling angle before original) (safe : Safe plan) :
    AffineStorageLineage.addresses p.graph.output (after plan safe).graph.output=
      AffineStorageLineage.addresses p.graph.output original.graph.output :=
  FinalProjectionStorageLineage.token_addresses original _
    (original.protected_mono (fun _ _ live => NativeCopiedTokenParameters.step_frame (step plan) live) safe)

theorem parameters_preserved (plan : Plan p sampling angle before original) (safe : Safe plan) (property : Nat → Nat → Prop) :
    (after plan safe).Protected property ↔ original.Protected property :=
  NativeCopiedTokenParameters.parameters_preserved (step plan) original safe property

theorem frame (plan : Plan p sampling angle before original) (safe : Safe plan)
    (region : TokenParameterConstruction.Region original base size) (offset : Nat) (bound : offset<size) :
    (NativeCopiedTokenRoute.final (step plan).execution).sampler.memory (base+offset)=before.index.bytes (base+offset) :=
  NativeCopiedTokenParameters.original_bytes (step plan) original safe region offset bound

end Inference.Models.Qwen.NativeCopiedTokenConstruction
