import models.qwen.CapacityAttentionChainParsed

namespace Inference.Models.Qwen.CapacityAttentionDerivedNative
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention Kernels.Normalization
set_option maxRecDepth 10000
variable {n : Nat}
attribute [local irreducible] AttentionGateCopyFreshRead.Read.input
  AttentionGateCopyCapacityResidualStage.block AttentionGateCopyCapacityResidualStage.original

-- Native inputs contain descriptors, local memories and the gate-buffer
-- link. Every stage's finite contract is inserted from one original model
-- range derivation, rather than supplied in a per-stage native record.
structure AttentionInput {n : Nat} {layer : ResidualAttention.Layer} {cache : State.Kv.Cache State.Kv.BF n}
    {input : Row BF} {angle : RopeAngles.Inputs} (plan : AttentionGateCopyCapacityResidualStage.Plan layer cache input angle) where
  trellis : TrellisParsedNative.Input (AttentionGateCopyCapacityResidualStage.block plan).suffix
  before : Nat → Float32
  kernel : MlxRmsHostSelection.KernelLimit
  nativeThreads : layer.inputNorm.platform.groups*32=kernel.threads
  scratch : M1Max.WordMemory
  inverseBefore : M1Max.WordMemory
  base : Nat
  inverseBase : Nat
  gateLink : plan.tail.gates=plan.read.gate
  growth : AttentionGateCopyPositiveSources.Inputs plan.preparation.preparation

def StageInput : (kind : Stage) → (cache : Cache kind n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    CapacityAttentionDecodeStage.Execution kind cache input angle → Type
  | .delta _, _, _, _, execution => DeltaParsedConstructedStage.Native execution.1 execution.2
  | .attention _, _, _, _, execution => AttentionInput execution.val

def stageNative (kind : Stage) (cache : Cache kind n) (input : Row BF) (angle : RopeAngles.Inputs)
    (execution : CapacityAttentionDecodeStage.Execution kind cache input angle)
    (native : StageInput kind cache input angle execution) (finite : Finite kind cache input angle)
    (supported : n+1≤262144) : CapacityAttentionStageParsed.Native kind cache input angle execution := by
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
      finite := finite
      gateLink := native.gateLink
      supported := supported
      growth := native.growth }

def Inputs : (stages : List Stage) → (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    CapacityAttentionDecodeChain.Trace stages cache input angle source storage → Type
  | [], _, _, _, _, _, _ => PUnit
  | kind::rest, cache, input, angle, _, _, trace =>
    StageInput kind cache.1 input angle trace.1.first.execution ×
    Inputs rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2

def native : (stages : List Stage) → (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    (trace : CapacityAttentionDecodeChain.Trace stages cache input angle source storage) →
    Inputs stages cache input angle source storage trace → Ranges stages cache input angle → n+1≤262144 →
    CapacityAttentionChainParsed.Native stages cache input angle source storage trace
  | [], _, _, _, _, _, _, _, _, _ => ⟨⟩
  | kind::rest, cache, input, angle, _, _, trace, inputs, ranges, supported =>
    ⟨stageNative kind cache.1 input angle trace.1.first.execution inputs.1 ranges.1 supported,
      native rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2
        inputs.2 ranges.2 supported⟩

theorem parsed (stages : List Stage) (cache : Caches stages n) (input : Row BF) (angle : RopeAngles.Inputs)
    (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage stages cache source.bytes)
    (trace : CapacityAttentionDecodeChain.Trace stages cache input angle source storage)
    (inputs : Inputs stages cache input angle source storage trace) (ranges : Ranges stages cache input angle)
    (supported : n+1≤262144) :
    CapacityAttentionChainParsed.Parsed stages cache input angle source storage trace
      (native stages cache input angle source storage trace inputs ranges supported) :=
  CapacityAttentionChainParsed.checked _ _ _ _ _ _ _ _

end Inference.Models.Qwen.CapacityAttentionDerivedNative
