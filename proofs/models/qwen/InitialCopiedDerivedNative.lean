import models.qwen.InitialCopiedChainParsed
namespace Inference.Models.Qwen.InitialCopiedDerivedNative
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention Kernels.Normalization
set_option maxRecDepth 10000
attribute [local irreducible] AttentionGateCopyInitialRead.Read.input
  AttentionGateCopyInitialResidualStage.block AttentionGateCopyInitialResidualStage.original

-- Only source/native inputs are retained here. The first-token original
-- model ranges below supply every stage finite contract at cache index0.
structure AttentionInput (plan : AttentionGateCopyInitialResidualStage.Plan layer cache input angle) where
  trellis : TrellisParsedNative.Input (AttentionGateCopyInitialResidualStage.block plan).suffix
  before : Nat → Float32
  kernel : MlxRmsHostSelection.KernelLimit
  nativeThreads : layer.inputNorm.platform.groups*32=kernel.threads
  scratch : M1Max.WordMemory
  inverseBefore : M1Max.WordMemory
  base : Nat
  inverseBase : Nat
  sources : InitialKvSourceMemory.Sources plan.read.kv.zeros
  gateLink : plan.tail.gates=plan.read.gate

def StageInput : (kind : Stage) → (cache : Cache kind 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    InitialCopiedDecodeStage.Execution kind cache input angle → Type
  | .delta _, _, _, _, execution => DeltaParsedConstructedStage.Native execution.1 execution.2
  | .attention _, _, _, _, execution => AttentionInput execution

def stageNative (kind : Stage) (cache : Cache kind 0) (input : Row BF) (angle : RopeAngles.Inputs)
    (execution : InitialCopiedDecodeStage.Execution kind cache input angle)
    (native : StageInput kind cache input angle execution) (finite : Finite kind cache input angle) :
    InitialCopiedStageParsed.Native kind cache input angle execution := by
  cases kind with
  | delta _ => exact ⟨native,finite⟩
  | attention _ => exact {
      trellis := native.trellis
      before := native.before
      kernel := native.kernel
      nativeThreads := native.nativeThreads
      scratch := native.scratch
      inverseBefore := native.inverseBefore
      base := native.base
      inverseBase := native.inverseBase
      sources := native.sources
      finite := finite
      gateLink := native.gateLink }

def Inputs : (stages : List Stage) → (cache : Caches stages 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    InitialCopiedDecodeChain.Trace stages cache input angle source storage → Type
  | [], _, _, _, _, _, _ => PUnit
  | kind::rest, cache, input, angle, _, _, trace =>
    StageInput kind cache.1 input angle trace.1.first.execution ×
    Inputs rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2

def native : (stages : List Stage) → (cache : Caches stages 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    (trace : InitialCopiedDecodeChain.Trace stages cache input angle source storage) →
    Inputs stages cache input angle source storage trace → Ranges stages cache input angle →
    InitialCopiedChainParsed.Native stages cache input angle source storage trace
  | [], _, _, _, _, _, _, _, _ => ⟨⟩
  | kind::rest, cache, input, angle, _, _, trace, inputs, ranges =>
    ⟨stageNative kind cache.1 input angle trace.1.first.execution inputs.1 ranges.1,
      native rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2 inputs.2 ranges.2⟩

theorem parsed (stages : List Stage) (cache : Caches stages 0) (input : Row BF) (angle : RopeAngles.Inputs)
    (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage stages cache source.bytes)
    (trace : InitialCopiedDecodeChain.Trace stages cache input angle source storage)
    (inputs : Inputs stages cache input angle source storage trace) (ranges : Ranges stages cache input angle) :
    InitialCopiedChainParsed.Parsed stages cache input angle source storage trace
      (native stages cache input angle source storage trace inputs ranges) :=
  InitialCopiedChainParsed.checked _ _ _ _ _ _ _ _
end Inference.Models.Qwen.InitialCopiedDerivedNative
