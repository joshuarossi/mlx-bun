import models.qwen.AttentionGateCopyInitialParsedDonation
import models.qwen.AttentionGateCopyInitialParsedFresh

namespace Inference.Models.Qwen.AttentionGateCopyInitialParsedDispatch
open Contracts.Mlx Kernels.Attention State
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2D.labels Copy2DMemory.programs

variable {layer : Attention.Layer} {cache : Kv.Cache Kv.BF 0}
  {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {front : AttentionGateCopyFront.Execution layer values angle}
  (read : AttentionGateCopyInitialRead.Read front cache)

abbrev Attention := SdpaShared.Execution read.input layer.attention layer.mergeContracted layer.architectureSuffix

def source (attention : Attention read) : Option (List (List HalfMemory.Store)) :=
  match attention with
  | .onePassFresh execution selected => MlxSdpaFreshOutputSource.source execution selected
  | .onePassDonated execution => MlxSdpaOutputSource.source execution.stores.base execution.kernels
  | .twoPass _ _ => none

def schedule (attention : Attention read) : List HalfMemory.Store :=
  match attention with
  | .onePassFresh execution _ => execution.kernel.output.schedule
  | .onePassDonated execution => execution.stores.schedule
  | .twoPass _ execution => execution.stores.schedule

def remaining (attention : Attention read) : List (List HalfMemory.Store) :=
  match attention with
  | .onePassFresh execution _ => execution.kernel.output.remaining
  | .onePassDonated execution => execution.stores.remaining
  | .twoPass _ execution => execution.stores.remaining

def PhaseCertificate (attention : Attention read) : Prop :=
  match attention with
  | .onePassFresh execution selected => AttentionGateCopyInitialParsedFresh.SourceCertificate read execution selected
  | .onePassDonated execution => AttentionGateCopyInitialParsedDonation.PartialCertificate read execution
  | .twoPass _ _ => False

theorem phase_certificate (attention : Attention read)
    (finite : ∀ head, SdpaDispatched.Finite layer.attention layer.mergeContracted layer.architectureSuffix
      ((layer.heads values angle).query head)
      ((layer.cacheAfter values angle cache).keys (SdpaScore.kvHead head))
      ((layer.cacheAfter values angle cache).values (SdpaScore.kvHead head))) : PhaseCertificate read attention := by
  cases attention with
  | onePassFresh execution selected =>
    apply AttentionGateCopyInitialParsedFresh.source_certificate read execution selected (by decide)
    intro head
    simpa only [SdpaDispatched.Finite,ite_eq_right selected] using finite head
  | onePassDonated execution =>
    exact AttentionGateCopyInitialParsedDonation.partial_certificate read execution (by decide)
  | twoPass first execution =>
    exact False.elim (AttentionGateCopyInitialParsedDonation.short_selected execution.selected)

-- At N=1 source selection excludes two-pass for every suffix. Native suffix,
-- buffer-donation eligibility and compiler/completion attachment stay explicit.
theorem source_to_projection (attention : Attention read)
    (tail : AttentionTailMemory.Execution attention (layer.heads values angle).gate layer.gate layer.output)
    (gateLink : tail.gates=read.gate)
    (finite : ∀ head, SdpaDispatched.Finite layer.attention layer.mergeContracted layer.architectureSuffix
      ((layer.heads values angle).query head)
      ((layer.cacheAfter values angle cache).keys (SdpaScore.kvHead head))
      ((layer.cacheAfter values angle cache).values (SdpaScore.kvHead head))) :
    ∃ programs intermediate gatedHeap,
      source read attention=some programs ∧
      ThreadgroupWrites.Executes programs (schedule read attention) (remaining read attention) ∧
      ThreadgroupWrites.AtBarrier (remaining read attention) ∧
      MlxOutputGateScheduled.unaryRun layer.gate (front.phase.gateCopy.base/2) tail.gating.activation.base
        tail.gating.activation.trace.schedule
        (HalfMemory.execute (schedule read attention) read.input.cache.memory)=some intermediate ∧
      MlxOutputGateScheduled.binaryRun (attention.base/2) tail.gating.activation.base tail.gating.base
        tail.gating.trace.schedule intermediate=some gatedHeap ∧
      tail.buffer.bytes=HalfMemory.execute tail.projected.affine.stores gatedHeap := by
  cases attention with
  | onePassFresh execution selected =>
    apply AttentionGateCopyInitialParsedFresh.source_to_projection read execution selected tail gateLink
    intro head
    simpa only [SdpaDispatched.Finite,ite_eq_right selected] using finite head
  | onePassDonated execution =>
    apply AttentionGateCopyInitialParsedDonation.source_to_projection read execution tail gateLink
    intro head
    simpa only [SdpaDispatched.Finite,ite_eq_right execution.selected] using finite head
  | twoPass first execution =>
    exact False.elim (AttentionGateCopyInitialParsedDonation.short_selected execution.selected)

end Inference.Models.Qwen.AttentionGateCopyInitialParsedDispatch
