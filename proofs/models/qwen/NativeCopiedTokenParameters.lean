import models.qwen.NativeCopiedTokenState
import models.qwen.InitialCopiedTokenParameterFrame
import models.qwen.CapacityCopiedTokenParameterFrame

namespace Inference.Models.Qwen.NativeCopiedTokenParameters
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference NativeCopiedTokenRoute NativeCopiedTokenState
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

def RegionSafe {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform}
    {cache : p.graph.Cache n} {token : Fin 248320} {angle : RopeAngles.Inputs}
    (run : Execution p sampling cache token angle) (base size : Nat) : Prop := match run with
  | .initial run => InitialCopiedTokenParameterFrame.Safe run base size
  | .positive run => CapacityCopiedTokenParameterFrame.Safe run base size

theorem route_frame {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform}
    {cache : p.graph.Cache n} {token : Fin 248320} {angle : RopeAngles.Inputs}
    (run : Execution p sampling cache token angle) (safe : RegionSafe run base size)
    (offset : Nat) (bound : offset<size) :
    (final run).sampler.memory (base+offset)=(embedding run).tokenBuffer.bytes (base+offset) := by
  cases run with
  | initial run => exact InitialCopiedTokenParameterFrame.frame run safe offset bound
  | positive run => exact CapacityCopiedTokenParameterFrame.frame run safe offset bound

variable {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform}
  {before : TokenAutoregressiveMemory.State p n} {angle : RopeAngles.Inputs}
  (step : Step p sampling before angle)

theorem step_frame (safe : RegionSafe step.execution base size) (offset : Nat) (bound : offset<size) :
    (final step.execution).sampler.memory (base+offset)=before.index.bytes (base+offset) :=
  (route_frame step.execution safe offset bound).trans (congrFun (entry_heap step) _)

variable (original : TokenParameterMemory.Storage p before.index.bytes)
  (safe : original.Protected (RegionSafe step.execution))

-- Reframing preserves every original parameter address and byte. It does
-- not supply new parameter tensors to either route's kernel descriptors.
def after : TokenParameterMemory.Storage p (final step.execution).sampler.memory :=
  original.reframe _ (original.protected_mono (fun _ _ live => step_frame step live) safe)

theorem parameters_preserved (property : Nat → Nat → Prop) :
    (after step original safe).Protected property ↔ original.Protected property :=
  original.reframe_protected _ _ property

include safe in
theorem original_bytes (region : TokenParameterConstruction.Region original base size)
    (offset : Nat) (bound : offset<size) :
    (final step.execution).sampler.memory (base+offset)=before.index.bytes (base+offset) :=
  step_frame step (region (RegionSafe step.execution) safe) offset bound

theorem embedding_bases :
    (after step original safe).embedding.packedBase=original.embedding.packedBase ∧
    (after step original safe).embedding.scales.base=original.embedding.scales.base ∧
    (after step original safe).embedding.biases.base=original.embedding.biases.base := ⟨rfl,rfl,rfl⟩

variable (parameters : TokenSequenceRanges.Parameters p)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (samplingPrimitive : LogSumExpRanges.Primitives sampling)
  (angleBound : RopeAnglesRanges.InputsBound angle) (supported : n+1≤262144)
  (aim angleError : RopeAngles.Target) (angleAccuracy : RopeAngles.InputError angle aim angleError)
  (baseNonnegative : 0≤aim.base)

def next : TokenParameterMemory.Storage p
    (advance step parameters primitive samplingPrimitive angleBound supported aim angleError angleAccuracy baseNonnegative).index.bytes :=
  after step original safe

theorem next_parameters (property : Nat → Nat → Prop) :
    (next step original safe parameters primitive samplingPrimitive angleBound supported aim angleError angleAccuracy baseNonnegative).Protected property ↔
      original.Protected property := parameters_preserved step original safe property

end Inference.Models.Qwen.NativeCopiedTokenParameters
