import kernels.sampling.LogSumExpSourceMemory
import kernels.sampling.ArgmaxLaunchSourceMemory
namespace Inference.Kernels.Sampling.LogSumExpSamplerSource
open Contracts.Mlx
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
variable {logits : Fin 248320→ArrayStorage.BF} {p : LogSumExpRanges.Platform} {source : ArrayStorage.BFBuffer logits}

def nativeValue (lse : LogSumExpMemory.Execution p source) : ArrayStorage.BF :=
  LogSumExpSourceScratch.finish p
    (LogSumExpSourceMemory.normHeap p source.bytes source.base lse.scratch.maxBase lse.scratch.normBase
      lse.scratch.maxima.before (LogSumExpSourceMemory.owners lse.scratch.maxBase lse.scratch.maxima.schedule)
      (LogSumExpSourceMemory.owners lse.scratch.normBase lse.scratch.normalizers.schedule)) lse.scratch.maxBase lse.scratch.normBase

def nativeMemory (lse : LogSumExpMemory.Execution p source) : Option ByteMemory.Bytes :=
  LogSumExpSourceMemory.executeSource p source.bytes source.base lse.scratch.maxBase lse.scratch.normBase lse.destination
    lse.scratch.maxima.before (LogSumExpSourceMemory.owners lse.scratch.maxBase lse.scratch.maxima.schedule)
    (LogSumExpSourceMemory.owners lse.scratch.normBase lse.scratch.normalizers.schedule)

structure LogSumExpCertificate (lse : LogSumExpMemory.Execution p source) (native : LogSumExpSourceHost.Attachment) : Prop where
  host : LogSumExpSourceHost.select native.metadata native.pipelineMaximum=some LogSumExpSourceHost.launch
  privateReads : ∀ stores, (∀ store∈stores,store∈lse.output.schedule) → ∀ thread,
    LogSumExpSourceLoop.executeThread p.scalar (HalfMemory.execute stores source.bytes) source.base thread=
      some (LogSumExpLoopRanges.localState p.scalar (fun i=>BFloat16.widen (logits i)) thread)
  maxBarrier : ThreadgroupWrites.Executes (LogSumExpSourceScratch.maxPrograms p source lse.scratch.maxBase)
      lse.scratch.maxima.schedule lse.scratch.maxima.remaining ∧ ThreadgroupWrites.AtBarrier lse.scratch.maxima.remaining
  normalizerBarrier : ThreadgroupWrites.Executes
      (LogSumExpSourceScratch.normalizerPrograms p source lse.scratch.maxBase lse.scratch.normBase lse.scratch.normalizers.before)
      lse.scratch.normalizers.schedule lse.scratch.normalizers.remaining ∧ ThreadgroupWrites.AtBarrier lse.scratch.normalizers.remaining
  currentScratch : ∀ stores, (∀ store∈stores,store∈lse.scratch.normalizers.schedule) →
    LogSumExpSourceScratch.normalizerPrograms p source lse.scratch.maxBase lse.scratch.normBase
      (ByteMemory.execute stores lse.scratch.normalizers.before)=
      FloatArrayWrites.programs lse.scratch.normBase (LogSumExpMemory.adjusted p source lse.scratch.maxima)
  memory : nativeMemory lse=some lse.memory
  readback : nativeValue lse=lse.buffer.read 0

theorem checked_logsumexp (lse : LogSumExpMemory.Execution p source) (native : LogSumExpSourceHost.Attachment) : LogSumExpCertificate lse native :=
  ⟨LogSumExpSourceHost.attached_launch native,LogSumExpSourceLoop.current_thread lse,
    LogSumExpSourceScratch.maxima_barrier lse.scratch,LogSumExpSourceScratch.normalizers_barrier lse.scratch,
    LogSumExpSourceScratch.normalizer_programs lse.scratch,LogSumExpSourceMemory.source_execution lse,
    LogSumExpSourceMemory.readback lse⟩

variable {lse : LogSumExpMemory.Execution p source}

structure Certificate (selection : NormalizedArgmaxMemory.Execution lse) (native : LogSumExpSourceHost.Attachment) : Prop where
  logsumexp : LogSumExpCertificate lse native
  greedy : ArgmaxLaunchSourceMemory.Certificate selection

theorem checked (selection : NormalizedArgmaxMemory.Execution lse) (native : LogSumExpSourceHost.Attachment) (primitive : LogSumExpRanges.Primitives p)
    (bound : ∀ i,Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)|≤(2:ℝ)^(23:Nat)) : Certificate selection native :=
  ⟨checked_logsumexp lse native,ArgmaxLaunchSourceMemory.checked_sampler selection primitive bound⟩

-- The score kernel consumes the BF16 word emitted by the source interpreter
-- above, from its actual evolving global heap during partial-token stores.
theorem consumer_read (selection : NormalizedArgmaxMemory.Execution lse) (native : LogSumExpSourceHost.Attachment) (stores : List ByteMemory.Store)
    (subset : ∀ store∈stores,store∈selection.partials.schedule) :
    nativeValue lse=(selection.lseDuring stores subset).read 0 := by
  rw [(checked_logsumexp lse native).readback,ArrayStorage.BFBuffer.read_correct,ArrayStorage.BFBuffer.read_correct]

theorem consumer_heap (selection : NormalizedArgmaxMemory.Execution lse) (native : LogSumExpSourceHost.Attachment) : nativeMemory lse=some selection.partials.before := by
  rw [(checked_logsumexp lse native).memory,selection.initial]

theorem source_token (selection : NormalizedArgmaxMemory.Execution lse) (native : LogSumExpSourceHost.Attachment) (primitive : LogSumExpRanges.Primitives p)
    (bound : ∀ i,Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)|≤(2:ℝ)^(23:Nat)) :
    Certificate selection native ∧
      (ArgmaxLaunchSourceMemory.tokenMemory selection).map
        (fun memory=>(ByteMemory.load32 memory selection.destination).toNat)=some (GreedySampling.sample p logits) :=
  ⟨checked selection native primitive bound,(ArgmaxLaunchSourceMemory.source_token selection primitive bound).2⟩
end Inference.Kernels.Sampling.LogSumExpSamplerSource
