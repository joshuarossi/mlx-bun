import models.qwen.InitialCopiedTokenSource
import models.qwen.CapacityCopiedTokenSource

namespace Inference.Models.Qwen.NativeCopiedTokenRoute
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

-- The index selects the actual cache route. At zero, only the direct-zero
-- chain can be supplied; a successor uses the capacity-preserving chain.
inductive Execution (p : Pipeline) (sampling : LogSumExpRanges.Platform) :
    {n : Nat} → p.graph.Cache n → Fin 248320 → RopeAngles.Inputs → Type where
  | initial {cache : p.graph.Cache 0} {token : Fin 248320} {angle : RopeAngles.Inputs}
      (run : InitialCopiedTokenSource.Execution p sampling cache token angle) :
      Execution p sampling cache token angle
  | positive {n : Nat} {cache : p.graph.Cache (n+1)} {token : Fin 248320} {angle : RopeAngles.Inputs}
      (run : CapacityCopiedTokenSource.Execution p sampling cache token angle) :
      Execution p sampling cache token angle

variable {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform}
  {cache : p.graph.Cache n} {token : Fin 248320} {angle : RopeAngles.Inputs}

def embedding : Execution p sampling cache token angle → QuantizedEmbeddingMemory.Execution p.embedding token
  | .initial run => run.embedding
  | .positive run => run.embedding

def source : Execution p sampling cache token angle → ArrayStorage.BFBuffer (p.embedding.forward token)
  | .initial run => run.forward.source
  | .positive run => run.forward.source

def storage (run : Execution p sampling cache token angle) :
    DecodeFrame.Storage p.graph.stages cache (source run).bytes := match run with
  | .initial run => run.forward.storage
  | .positive run => run.forward.storage

theorem linked (run : Execution p sampling cache token angle) : source run=(embedding run).forwardBuffer := by
  cases run with
  | initial run => exact run.linked
  | positive run => exact run.linked

def finalStorage : Execution p sampling cache token angle →
    FinalProjectionConstruction.Storage p.graph.finalNorm p.graph.output
      (p.graph.hidden cache (p.embedding.forward token) angle)
  | .initial run => run.forward.finalParameters
  | .positive run => run.forward.finalParameters

def finalAllocation (run : Execution p sampling cache token angle) :
    FinalProjectionConstruction.Allocation (finalStorage run) := match run with
  | .initial run => run.forward.allocation
  | .positive run => run.forward.allocation

def final (run : Execution p sampling cache token angle) :
    FinalProjectionSamplerSource.Execution (finalStorage run) (finalAllocation run) sampling := match run with
  | .initial run => run.final
  | .positive run => run.final

def Inputs (run : Execution p sampling cache token angle) : Type := match run with
  | .initial run => InitialCopiedDerivedNative.Inputs p.graph.stages cache (p.embedding.forward token) angle
      run.forward.source run.forward.storage run.forward.chain
  | .positive run => CapacityAttentionDerivedNative.Inputs p.graph.stages cache (p.embedding.forward token) angle
      run.forward.source run.forward.storage run.forward.chain

def Certificate (run : Execution p sampling cache token angle) (unsigned : Bool) (inputs : Inputs run)
    (ranges : p.Ranges cache token angle) (supported : n+1≤262144)
    (finalNative : FinalProjectionParsedSource.Native (finalStorage run) (finalAllocation run))
    (lseNative : LogSumExpSourceHost.Attachment) : Prop := match run,inputs with
  | .initial run,inputs => InitialCopiedTokenSource.Certificate run unsigned
      (InitialCopiedDerivedNative.native p.graph.stages cache (p.embedding.forward token) angle
        run.forward.source run.forward.storage run.forward.chain inputs ranges.graph.chain) finalNative lseNative
  | .positive run,inputs => CapacityCopiedTokenSource.Certificate run unsigned
      (CapacityAttentionDerivedNative.native p.graph.stages cache (p.embedding.forward token) angle
        run.forward.source run.forward.storage run.forward.chain inputs ranges.graph.chain supported) finalNative lseNative

theorem checked (run : Execution p sampling cache token angle) (unsigned : Bool) (inputs : Inputs run)
    (ranges : p.Ranges cache token angle) (supported : n+1≤262144)
    (finalNative : FinalProjectionParsedSource.Native (finalStorage run) (finalAllocation run))
    (lseNative : LogSumExpSourceHost.Attachment) (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite ((p.run cache token angle).1 i)=true ∧
      |Model.toReal ((p.run cache token angle).1 i)| ≤ (2:ℝ)^(23:Nat)) :
    Certificate run unsigned inputs ranges supported finalNative lseNative := by
  cases run with
  | initial run => exact (InitialCopiedTokenSource.derived_source_token run unsigned inputs finalNative ranges lseNative primitive bound).1
  | positive run => exact (CapacityCopiedTokenSource.derived_source_token run unsigned inputs finalNative ranges supported lseNative primitive bound).1

-- The shared suffix keeps its concrete final-storage and allocation indices.
-- It therefore exposes the same sampled heap on both indexed routes.
theorem token_read (run : Execution p sampling cache token angle) (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite ((p.run cache token angle).1 i)=true ∧
      |Model.toReal ((p.run cache token angle).1 i)| ≤ (2:ℝ)^(23:Nat)) :
    (ByteMemory.load32 (final run).sampler.memory (final run).sampler.selection.destination).toNat=
      GreedySampling.sample sampling (p.run cache token angle).1 :=
  FinalProjectionSamplerSource.token_read (final run) primitive bound

theorem source_token (run : Execution p sampling cache token angle) (unsigned : Bool) (inputs : Inputs run)
    (ranges : p.Ranges cache token angle) (supported : n+1≤262144)
    (finalNative : FinalProjectionParsedSource.Native (finalStorage run) (finalAllocation run))
    (lseNative : LogSumExpSourceHost.Attachment) (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite ((p.run cache token angle).1 i)=true ∧
      |Model.toReal ((p.run cache token angle).1 i)| ≤ (2:ℝ)^(23:Nat)) :
    Certificate run unsigned inputs ranges supported finalNative lseNative ∧
    (ArgmaxLaunchSourceMemory.tokenMemory (final run).sampler.selection).map
      (fun memory => (ByteMemory.load32 memory (final run).sampler.selection.destination).toNat)=
      some (GreedySampling.sample sampling (p.run cache token angle).1) :=
  ⟨checked run unsigned inputs ranges supported finalNative lseNative primitive bound,
    (FinalProjectionSamplerSource.source_token (final run) finalNative ranges.graph.output lseNative primitive bound).2⟩

end Inference.Models.Qwen.NativeCopiedTokenRoute
