import models.qwen.AttentionGateCopyFreshGeometry
import models.qwen.AttentionParsedFresh
import models.qwen.AttentionParsedScheduledGate

namespace Inference.Models.Qwen.AttentionGateCopyCapacityParsedFresh
open Contracts.Mlx Kernels.Attention State
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2D.labels Copy2DMemory.programs

variable {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {s : AttentionGateCopyReadConstruction.Input layer cache values angle}
  {preparation : AttentionGateCopyFreshRead.Prepared s}
  (read : AttentionGateCopyFreshRead.Read preparation)
  (attention : SdpaOutputMemory.Execution read.input layer.attention layer.mergeContracted layer.architectureSuffix)
  (selected : ¬SdpaDispatched.twoPass layer.architectureSuffix (n+1))

def fresh (base : Nat) (aligned : base%2=0) (bounded : base+12288≤2^64)
    (keysSeparate : MemoryRegions.Disjoint base 12288 read.input.cache.layout.keyBase (KvRegions.bytes (n+1)))
    (valuesSeparate : MemoryRegions.Disjoint base 12288 read.input.cache.layout.valueBase (KvRegions.bytes (n+1)))
    (queriesSeparate : ∀ head, MemoryRegions.Disjoint base 12288 (read.input.query head).base 512) :
    SdpaOutputMemory.Execution read.input layer.attention layer.mergeContracted layer.architectureSuffix :=
  SdpaOutputMemory.canonical read.input layer.attention layer.mergeContracted layer.architectureSuffix base
    aligned bounded keysSeparate valuesSeparate queriesSeparate

theorem query_layout (head : Fin 24) :
    (read.input.query head).base=(SdpaQueryMemory.layout s.front.rope.query.destination).base head := by
  rw [read.query_layout head]
  dsimp [SdpaQueryMemory.layout]
  omega

-- Every protected fresh-output prefix derives its registers and complete
-- parsed score/update folds from the same constructed current query/cache heap.
structure SourceCertificate : Prop where
  output : ∃ programs, MlxSdpaFreshOutputSource.source attention selected=some programs ∧
    ThreadgroupWrites.Executes programs attention.kernel.output.schedule attention.kernel.output.remaining ∧
    ThreadgroupWrites.AtBarrier attention.kernel.output.remaining ∧
    HalfMemory.execute attention.kernel.output.schedule read.input.cache.memory=attention.kernel.output.memory
  summaries : ∀ stores : List HalfMemory.Store, MemoryRegions.Inside16 attention.kernel.output.base 12288 stores →
    ∀ head group, ∃ finish,
    MlxSdpaFreshPartialSource.source (input:=read.input) (p:=layer.attention) stores s.front.rope.query.destination head group 0 0=some finish ∧
    (attention.kernel.first selected head).summaries.read true group=finish.shift ∧
    (attention.kernel.first selected head).summaries.read false group=finish.denominator
  transpose : ∀ stores : List HalfMemory.Store, MemoryRegions.Inside16 attention.kernel.output.base 12288 stores →
    ∀ head readerGroup readerLane offset, ∃ finish,
    MlxSdpaFreshPartialSource.source (input:=read.input) (p:=layer.attention) stores s.front.rope.query.destination head readerLane readerGroup offset=some finish ∧
    ((attention.kernel.first selected head).scratch offset).register readerGroup readerLane=finish.numerator
  control : ∀ group : Fin 32,
    MlxSdpaVectorLoop.Runs (n+1) group.val ((SdpaLayout.keys (n+1) group).map Fin.val) ∧
      group.val+32*SdpaLayout.count (n+1) group<2^31

theorem source_certificate (supported : n+1≤262144)
    (finite : ∀ head, SdpaVector.Finite layer.attention ((layer.heads values angle).query head)
      ((layer.cacheAfter values angle cache).keys (SdpaScore.kvHead head))
      ((layer.cacheAfter values angle cache).values (SdpaScore.kvHead head))) : SourceCertificate read attention selected := by
  obtain ⟨output,summaries,transpose,control⟩ := MlxSdpaFreshOutputSource.lifecycle attention selected
    s.front.rope.query.destination (query_layout read) supported finite
  exact ⟨output,summaries,transpose,control⟩

variable (tail : AttentionTailMemory.Execution (SdpaShared.Execution.onePassFresh attention selected)
  (layer.heads values angle).gate layer.gate layer.output)

theorem source_to_projection (gateLink : tail.gates=read.gate)
    (finite : ∀ head, SdpaVector.Finite layer.attention ((layer.heads values angle).query head)
      ((layer.cacheAfter values angle cache).keys (SdpaScore.kvHead head))
      ((layer.cacheAfter values angle cache).values (SdpaScore.kvHead head))) :
    ∃ sdpaPrograms intermediate gatedHeap,
      MlxSdpaFreshOutputSource.source attention selected=some sdpaPrograms ∧
      ThreadgroupWrites.Executes sdpaPrograms attention.kernel.output.schedule attention.kernel.output.remaining ∧
      ThreadgroupWrites.AtBarrier attention.kernel.output.remaining ∧
      MlxOutputGateScheduled.unaryRun layer.gate (s.front.phase.gateCopy.base/2) tail.gating.activation.base
        tail.gating.activation.trace.schedule
        (HalfMemory.execute attention.kernel.output.schedule read.input.cache.memory)=some intermediate ∧
      MlxOutputGateScheduled.binaryRun (attention.kernel.output.base/2) tail.gating.activation.base tail.gating.base
        tail.gating.trace.schedule intermediate=some gatedHeap ∧
      tail.buffer.bytes=HalfMemory.execute tail.projected.affine.stores gatedHeap := by
  have gateLayout : ∀ head, (tail.gates head).base=2*(s.front.phase.gateCopy.base/2+head.val*256) := by
    intro head
    rw [gateLink]
    exact read.gate_layout head
  obtain ⟨programs,parsed,scheduled,completed,heap⟩ := AttentionParsedFresh.source_to_gate attention selected tail finite
  obtain ⟨middle,gatedHeap,unary,binary,projected⟩ :=
    AttentionParsedScheduledGate.source_to_projection tail (s.front.phase.gateCopy.base/2) gateLayout
  refine ⟨programs,middle,gatedHeap,parsed,scheduled,completed,?_,binary,projected⟩
  rw [heap]
  exact unary

end Inference.Models.Qwen.AttentionGateCopyCapacityParsedFresh
