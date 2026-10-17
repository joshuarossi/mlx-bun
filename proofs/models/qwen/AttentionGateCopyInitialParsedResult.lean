import models.qwen.AttentionGateCopyInitialParsedDispatch
import layers.AffineRouteParsedSource

namespace Inference.Models.Qwen.AttentionGateCopyInitialParsedResult
open Contracts.Mlx Kernels.Attention State Layers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

variable {layer : Attention.Layer} {cache : Kv.Cache Kv.BF 0}
  {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {front : AttentionGateCopyFront.Execution layer values angle}
  (read : AttentionGateCopyInitialRead.Read front cache)
  (attention : AttentionGateCopyInitialParsedDispatch.Attention read)
  (tail : AttentionTailMemory.Execution attention (layer.heads values angle).gate layer.gate layer.output)

-- The executed route follows the stored width: three-bit uses the custom
-- complete-row wrapper, four-bit MLX qmv_fast. Allocation and descriptor
-- attachment remain carried execution contracts.
theorem parsed_projection (before : Nat → Float32)
    (finite : layer.output.Finite (OutputGateMemory.values layer.gate attention.output (layer.heads values angle).gate)) :
    AffineRouteParsedSource.Certificate 80 640 tail.projected.affine before rfl rfl :=
  AffineRouteParsedSource.checked tail.projected.affine before (by decide) (by decide) (by decide) finite rfl rfl

theorem current_gate_heap : tail.projected.affine.source.bytes=tail.gating.trace.memory :=
  congrArg ArrayStorage.BFBuffer.bytes tail.projected.linked

theorem output_readback (before : Nat → Float32)
    (finite : layer.output.Finite (OutputGateMemory.values layer.gate attention.output (layer.heads values angle).gate))
    (row : Fin 5120) :
    AffineRouteParsedSource.value tail.projected.affine row=tail.buffer.read row :=
  AffineRouteParsedSource.same_buffer tail.projected.affine before (parsed_projection read attention tail before finite) row

theorem output_error (before : Nat → Float32)
    (finite : layer.output.Finite (OutputGateMemory.values layer.gate attention.output (layer.heads values angle).gate))
    (target error : Fin 6144 → ℝ)
    (inputBound : ∀ i, |Model.toReal (OutputGateMemory.values layer.gate attention.output
      (layer.heads values angle).gate i)-target i|≤error i) (row : Fin 5120) :
    |Model.toReal (AffineRouteParsedSource.value tail.projected.affine row)-layer.output.target target row|≤
      layer.output.budget (OutputGateMemory.values layer.gate attention.output (layer.heads values angle).gate) target error row :=
  AffineRouteParsedSource.readback_error tail.projected.affine before
    (parsed_projection read attention tail before finite) target error inputBound finite row

structure Certificate (before : Nat → Float32) : Prop where
  phases : AttentionGateCopyInitialParsedDispatch.PhaseCertificate read attention
  stores : ∃ programs intermediate gatedHeap,
    AttentionGateCopyInitialParsedDispatch.source read attention=some programs ∧
    ThreadgroupWrites.Executes programs (AttentionGateCopyInitialParsedDispatch.schedule read attention)
      (AttentionGateCopyInitialParsedDispatch.remaining read attention) ∧
    ThreadgroupWrites.AtBarrier (AttentionGateCopyInitialParsedDispatch.remaining read attention) ∧
    MlxOutputGateScheduled.unaryRun layer.gate (front.phase.gateCopy.base/2) tail.gating.activation.base
      tail.gating.activation.trace.schedule
      (HalfMemory.execute (AttentionGateCopyInitialParsedDispatch.schedule read attention)
        read.input.cache.memory)=some intermediate ∧
    MlxOutputGateScheduled.binaryRun (attention.base/2) tail.gating.activation.base tail.gating.base
      tail.gating.trace.schedule intermediate=some gatedHeap ∧
    tail.buffer.bytes=HalfMemory.execute tail.projected.affine.stores gatedHeap
  projectionSource : AffineRouteParsedSource.Certificate 80 640 tail.projected.affine before rfl rfl
  inputHeap : tail.projected.affine.source.bytes=tail.gating.trace.memory
  cacheHeap : tail.afterCache.memory=tail.buffer.bytes

theorem checked (before : Nat → Float32)
    (gateLink : tail.gates=read.gate)
    (finite : ∀ head, SdpaDispatched.Finite layer.attention layer.mergeContracted layer.architectureSuffix
      ((layer.heads values angle).query head)
      ((layer.cacheAfter values angle cache).keys (SdpaScore.kvHead head))
      ((layer.cacheAfter values angle cache).values (SdpaScore.kvHead head)))
    (outputFinite : layer.output.Finite
      (OutputGateMemory.values layer.gate attention.output (layer.heads values angle).gate)) :
    Certificate read attention tail before :=
  ⟨AttentionGateCopyInitialParsedDispatch.phase_certificate read attention finite,
    AttentionGateCopyInitialParsedDispatch.source_to_projection read attention tail gateLink finite,
    parsed_projection read attention tail before outputFinite,
    current_gate_heap read attention tail,tail.cache_output_shared⟩

end Inference.Models.Qwen.AttentionGateCopyInitialParsedResult
