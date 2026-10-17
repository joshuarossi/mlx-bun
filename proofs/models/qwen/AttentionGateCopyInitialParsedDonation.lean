import models.qwen.AttentionGateCopyInitialRead
import models.qwen.AttentionParsedOnePass
import models.qwen.AttentionParsedScheduledGate

namespace Inference.Models.Qwen.AttentionGateCopyInitialParsedDonation
open Contracts.Mlx Kernels.Attention State
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2D.labels Copy2DMemory.programs

variable {layer : Attention.Layer} {cache : Kv.Cache Kv.BF 0}
  {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {front : AttentionGateCopyFront.Execution layer values angle}
  (read : AttentionGateCopyInitialRead.Read front cache)

theorem short_selected : ¬SdpaDispatched.twoPass layer.architectureSuffix 1 := by
  intro selected
  have length := SdpaDispatched.long layer.architectureSuffix 1 (by omega) selected
  omega

theorem query_layout (head : Fin 24) :
    (read.input.query head).base=(SdpaQueryMemory.layout front.rope.query.destination).base head := by
  rw [read.query_layout head]
  dsimp [SdpaQueryMemory.layout]
  omega

-- Donation is constructed on the actual native RoPE query allocation.
-- Cache/output separation remains an allocation-ownership obligation.
def donation (selected : ¬SdpaDispatched.twoPass layer.architectureSuffix 1)
    (keysSeparate : MemoryRegions.Disjoint front.rope.query.destination 12288 read.input.cache.layout.keyBase (KvRegions.bytes 1))
    (valuesSeparate : MemoryRegions.Disjoint front.rope.query.destination 12288 read.input.cache.layout.valueBase (KvRegions.bytes 1)) :
    SdpaOnePassDonation.Execution read.input layer.attention layer.architectureSuffix :=
  SdpaOnePassDonation.canonical read.input layer.attention layer.architectureSuffix selected front.rope.query.destination
    front.rope.query.output.aligned front.rope.query.output.bounded (query_layout read) keysSeparate valuesSeparate

variable (attention : SdpaOnePassDonation.Execution read.input layer.attention layer.architectureSuffix)

theorem query_base : attention.base=front.rope.query.destination := by
  have base := attention.heads 0
  rw [read.query_layout 0] at base
  dsimp [SdpaQueryMemory.layout] at base
  omega

structure PartialCertificate : Prop where
  summaries : ∀ head group, ∃ finish,
    MlxSdpaPartialSource.Executes attention head group 0 0
      (List.finRange (SdpaLayout.count 1 group)) (MlxSdpaPartialSource.initial .empty) finish ∧
    (attention.kernels head).summaries.read true group=finish.shift ∧
    (attention.kernels head).summaries.read false group=finish.denominator
  transpose : ∀ head readerGroup readerLane offset, ∃ finish,
    MlxSdpaPartialSource.Executes attention head readerLane readerGroup offset
      (List.finRange (SdpaLayout.count 1 readerLane)) (MlxSdpaPartialSource.initial .empty) finish ∧
    ((attention.kernels head).scratch offset).register readerGroup readerLane=finish.numerator
  control : ∀ group : Fin 32,
    MlxSdpaVectorLoop.Runs 1 group.val ((SdpaLayout.keys 1 group).map Fin.val) ∧
      group.val+32*SdpaLayout.count 1 group<2^31

theorem partial_certificate (supported : 1≤262144) : PartialCertificate read attention where
  summaries := MlxSdpaOutputSource.summary_provenance attention
  transpose := MlxSdpaOutputSource.transpose_provenance attention
  control := fun group => ⟨MlxSdpaVectorLoop.selected_visits _ group,MlxSdpaVectorLoop.signed_counter _ supported group⟩

variable (tail : AttentionTailMemory.Execution
  (SdpaShared.Execution.onePassDonated (contracted:=layer.mergeContracted) attention)
  (layer.heads values angle).gate layer.gate layer.output)

theorem source_to_projection (gateLink : tail.gates=read.gate)
    (finite : ∀ head, SdpaVector.Finite layer.attention ((layer.heads values angle).query head)
      ((layer.cacheAfter values angle cache).keys (SdpaScore.kvHead head))
      ((layer.cacheAfter values angle cache).values (SdpaScore.kvHead head))) :
    ∃ sdpaPrograms intermediate gatedHeap,
      MlxSdpaOutputSource.source attention.stores.base attention.kernels=some sdpaPrograms ∧
      ThreadgroupWrites.Executes sdpaPrograms attention.stores.schedule attention.stores.remaining ∧
      ThreadgroupWrites.AtBarrier attention.stores.remaining ∧
      MlxOutputGateScheduled.unaryRun layer.gate (front.phase.gateCopy.base/2) tail.gating.activation.base
        tail.gating.activation.trace.schedule
        (HalfMemory.execute attention.stores.schedule read.input.cache.memory)=some intermediate ∧
      MlxOutputGateScheduled.binaryRun (attention.stores.base/2) tail.gating.activation.base tail.gating.base
        tail.gating.trace.schedule intermediate=some gatedHeap ∧
      tail.buffer.bytes=HalfMemory.execute tail.projected.affine.stores gatedHeap := by
  have gateLayout : ∀ head, (tail.gates head).base=2*(front.phase.gateCopy.base/2+head.val*256) := by
    intro head
    rw [gateLink]
    exact read.gate_layout head
  obtain ⟨programs,parsed,scheduled,completed,heap,_⟩ := AttentionParsedOnePass.source_to_gate attention tail finite
  obtain ⟨middle,gatedHeap,unary,binary,projected⟩ :=
    AttentionParsedScheduledGate.source_to_projection tail (front.phase.gateCopy.base/2) gateLayout
  refine ⟨programs,middle,gatedHeap,parsed,scheduled,completed,?_,binary,projected⟩
  rw [heap]
  exact unary

end Inference.Models.Qwen.AttentionGateCopyInitialParsedDonation
