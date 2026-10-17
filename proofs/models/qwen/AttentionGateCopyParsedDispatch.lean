import models.qwen.AttentionGateCopyParsedDonation
import models.qwen.AttentionGateCopyParsedFresh
import models.qwen.AttentionGateCopyParsedTwoPass

namespace Inference.Models.Qwen.AttentionGateCopyParsedDispatch
open Contracts.Mlx Kernels.Attention State
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2D.labels Copy2DMemory.programs

variable {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {s : AttentionGateCopyReadConstruction.Input layer cache values angle}
  (read : AttentionGateCopyReadConstruction.ReadPlan s)

abbrev Attention := SdpaShared.Execution read.input layer.attention layer.mergeContracted layer.architectureSuffix

def source (attention : Attention read) : Option (List (List HalfMemory.Store)) :=
  match attention with
  | .onePassFresh execution selected => MlxSdpaFreshOutputSource.source execution selected
  | .onePassDonated execution => MlxSdpaOutputSource.source execution.stores.base execution.kernels
  | .twoPass first execution => MlxSdpaTwoPassOutputSource.sourcePrograms first
      (SdpaDispatchedDevice.complete_blocks layer.architectureSuffix (n+1)) layer.mergeContracted execution.stores.base

def before (attention : Attention read) : ByteMemory.Bytes :=
  match attention with
  | .onePassFresh _ _ | .onePassDonated _ => read.input.cache.memory
  | .twoPass first _ => first.first.memory

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

structure TwoPhaseCertificate
    (first : SdpaTwoPassShared.Execution read.input layer.attention (SdpaDispatched.blockCount layer.architectureSuffix (n+1)))
    (execution : SdpaTwoPassDonation.Execution first layer.mergeContracted) : Prop where
  firstStores : ∃ programs,
    MlxSdpaTwoPassStores.source (SdpaDispatched.blockCount layer.architectureSuffix (n+1)) layer.attention
      read.input.storage.queryValues read.input.storage.keys.read read.input.storage.values.read
      first.first.trace.sumBase first.first.trace.maxBase first.first.trace.outputBase=some programs ∧
    ThreadgroupWrites.Executes programs first.first.trace.schedule first.first.trace.remaining ∧
    ThreadgroupWrites.AtBarrier first.first.trace.remaining
  nativeQueries : ∀ (head : Fin 24)
    (block : Fin (SdpaDispatched.blockCount layer.architectureSuffix (n+1))) (lane : Fin 32) (item : Fin 8),
    MlxSdpaTwoPassQueryGeometry.registers first.inputAfter.cache.memory s.front.rope.query.destination
      (SdpaDispatched.blockCount layer.architectureSuffix (n+1)) head block lane item=
      ArrayStorage.bits ((layer.heads values angle).query head (SdpaScore.index lane item))
  partials : ∀ head block lane item, ∃ finish,
    MlxSdpaTwoPassFirstSource.Executes layer.attention first.inputAfter head block lane item
      (List.finRange (SdpaTwoPassLayout.count (n+1) (SdpaDispatched.blockCount layer.architectureSuffix (n+1)) block))
      (MlxSdpaTwoPassStores.initial .zero) finish ∧
    (first.first.readState head block (SdpaScore.index lane item)).shift=finish.shift ∧
    (first.first.readState head block (SdpaScore.index lane item)).denominator=finish.denominator ∧
    (first.first.readState head block (SdpaScore.index lane item)).numerator=
      BFloat16.widen
        (BFloat16.narrow finish.numerator)
  currentTemporaries : ∀ head block i,
    MlxSdpaTwoPassMergeFrame.readState execution.stores.memory first.first.trace.sumBase first.first.trace.maxBase
      first.first.trace.outputBase (SdpaDispatched.blockCount layer.architectureSuffix (n+1)) head block i=
      first.first.readState head block i

def PhaseCertificate (attention : Attention read) : Prop :=
  match attention with
  | .onePassFresh execution selected => AttentionGateCopyParsedFresh.SourceCertificate read execution selected
  | .onePassDonated execution => AttentionGateCopyParsedDonation.PartialCertificate read execution
  | .twoPass first execution => TwoPhaseCertificate read first execution

theorem phase_certificate (attention : Attention read) (supported : n+1≤262144)
    (finite : ∀ head, SdpaDispatched.Finite layer.attention layer.mergeContracted layer.architectureSuffix
      ((layer.heads values angle).query head)
      ((layer.cacheAfter values angle cache).keys (SdpaScore.kvHead head))
      ((layer.cacheAfter values angle cache).values (SdpaScore.kvHead head))) : PhaseCertificate read attention := by
  cases attention with
  | onePassFresh execution selected =>
    apply AttentionGateCopyParsedFresh.source_certificate read execution selected supported
    intro head
    simpa only [SdpaDispatched.Finite,ite_eq_right selected] using finite head
  | onePassDonated execution => exact AttentionGateCopyParsedDonation.partial_certificate read execution supported
  | twoPass first execution =>
    exact ⟨MlxSdpaTwoPassStores.checked first,read.two_pass_current_capture first,
      MlxSdpaTwoPassStores.read_provenance first,MlxSdpaTwoPassMergeFrame.completed_state execution⟩

-- All constructors of the shared attention union are covered. Physical
-- dispatch/completion, compiler and descriptor bindings remain explicit.
theorem source_to_projection (attention : Attention read)
    (tail : AttentionTailMemory.Execution attention (layer.heads values angle).gate layer.gate layer.output)
    (gateLink : tail.gates=read.gates)
    (finite : ∀ head, SdpaDispatched.Finite layer.attention layer.mergeContracted layer.architectureSuffix
      ((layer.heads values angle).query head)
      ((layer.cacheAfter values angle cache).keys (SdpaScore.kvHead head))
      ((layer.cacheAfter values angle cache).values (SdpaScore.kvHead head))) :
    ∃ programs intermediate gatedHeap,
      source read attention=some programs ∧
      ThreadgroupWrites.Executes programs (schedule read attention) (remaining read attention) ∧
      ThreadgroupWrites.AtBarrier (remaining read attention) ∧
      MlxOutputGateScheduled.unaryRun layer.gate (s.front.phase.gateCopy.base/2) tail.gating.activation.base
        tail.gating.activation.trace.schedule (HalfMemory.execute (schedule read attention) (before read attention))=some intermediate ∧
      MlxOutputGateScheduled.binaryRun (attention.base/2) tail.gating.activation.base tail.gating.base
        tail.gating.trace.schedule intermediate=some gatedHeap ∧
      tail.buffer.bytes=HalfMemory.execute tail.projected.affine.stores gatedHeap := by
  cases attention with
  | onePassFresh execution selected =>
    apply AttentionGateCopyParsedFresh.source_to_projection read execution selected tail gateLink
    intro head
    simpa only [SdpaDispatched.Finite,ite_eq_right selected] using finite head
  | onePassDonated execution =>
    apply AttentionGateCopyParsedDonation.source_to_projection read execution tail gateLink
    intro head
    simpa only [SdpaDispatched.Finite,ite_eq_right execution.selected] using finite head
  | twoPass first execution =>
    apply AttentionGateCopyParsedTwoPass.source_to_projection read first execution tail gateLink
    intro head
    simpa only [SdpaDispatched.Finite,ite_eq_left execution.selected] using finite head

end Inference.Models.Qwen.AttentionGateCopyParsedDispatch
