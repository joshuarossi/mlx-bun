import kernels.sampling.LogSumExpSourceMerge
namespace Inference.Kernels.Sampling.LogSumExpSourceScratch
open Contracts.Mlx
variable {logits : Fin 248320→ArrayStorage.BF} {p : LogSumExpRanges.Platform} {source : ArrayStorage.BFBuffer logits}

def maximum (p : LogSumExpRanges.Platform) (memory : ByteMemory.Bytes) (base : Nat) : Float32 :=
  Maximum.tree (fun lane=>FloatMemory.load memory (base+4*lane.val)) p.maximumTree

def sum (p : LogSumExpRanges.Platform) (memory : ByteMemory.Bytes) (base : Nat) : Float32 :=
  FlushedReduction.evaluate (fun lane=>FloatMemory.load memory (base+4*lane.val)) p.sumTree

def maxPrograms (p : LogSumExpRanges.Platform) (source : ArrayStorage.BFBuffer logits) (base : Nat) :=
  FloatArrayWrites.programs base (fun simd=>(LogSumExpSourceMerge.groups p source.bytes source.base simd).maximum)

theorem max_programs (scratch : LogSumExpMemory.Scratch p source) :
    maxPrograms p source scratch.maxBase=
      FloatArrayWrites.programs scratch.maxBase (fun simd=>(LogSumExpDevice.groups p source simd).maximum) := by
  unfold maxPrograms
  rw [LogSumExpSourceMerge.groups_model source p]

theorem max_read (scratch : LogSumExpMemory.Scratch p source) :
    maximum p scratch.maxima.memory scratch.maxBase=LogSumExpMemory.maximum p source scratch.maxima := rfl

theorem max_during (scratch : LogSumExpMemory.Scratch p source) (stores : List ByteMemory.Store)
    (subset : ∀ store∈stores,store∈scratch.normalizers.schedule) :
    maximum p (ByteMemory.execute stores scratch.normalizers.before) scratch.maxBase=
      LogSumExpMemory.maximum p source scratch.maxima := scratch.maximum_during stores subset

def normalizerPrograms (p : LogSumExpRanges.Platform) (source : ArrayStorage.BFBuffer logits)
    (maxBase normBase : Nat) (current : ByteMemory.Bytes) :=
  FloatArrayWrites.programs normBase (fun simd=>
    let state := LogSumExpSourceMerge.groups p source.bytes source.base simd
    FlushToZero.mul state.normalizer
      (LogSumExpSourceArithmetic.exponential p.scalar state.maximum (maximum p current maxBase)))

theorem normalizer_programs (scratch : LogSumExpMemory.Scratch p source) (stores : List ByteMemory.Store)
    (subset : ∀ store∈stores,store∈scratch.normalizers.schedule) :
    normalizerPrograms p source scratch.maxBase scratch.normBase (ByteMemory.execute stores scratch.normalizers.before)=
      FloatArrayWrites.programs scratch.normBase (LogSumExpMemory.adjusted p source scratch.maxima) := by
  unfold normalizerPrograms
  rw [LogSumExpSourceMerge.groups_model source p,max_during scratch stores subset]
  unfold LogSumExpMemory.adjusted
  rfl

theorem maxima_barrier (scratch : LogSumExpMemory.Scratch p source) :
    ThreadgroupWrites.Executes (maxPrograms p source scratch.maxBase) scratch.maxima.schedule scratch.maxima.remaining ∧
      ThreadgroupWrites.AtBarrier scratch.maxima.remaining := by
  rw [max_programs scratch]
  exact ⟨scratch.maxima.execution,scratch.maxima.completed⟩

theorem normalizers_barrier (scratch : LogSumExpMemory.Scratch p source) :
    ThreadgroupWrites.Executes (normalizerPrograms p source scratch.maxBase scratch.normBase scratch.normalizers.before)
      scratch.normalizers.schedule scratch.normalizers.remaining ∧ ThreadgroupWrites.AtBarrier scratch.normalizers.remaining := by
  have programs := normalizer_programs scratch [] (by simp)
  change normalizerPrograms p source scratch.maxBase scratch.normBase scratch.normalizers.before=_ at programs
  rw [programs]
  exact ⟨scratch.normalizers.execution,scratch.normalizers.completed⟩

theorem max_after (scratch : LogSumExpMemory.Scratch p source) :
    maximum p scratch.normalizers.memory scratch.maxBase=LogSumExpMemory.maximum p source scratch.maxima :=
  scratch.maximum_after

def finish (p : LogSumExpRanges.Platform) (memory : ByteMemory.Bytes) (maxBase normBase : Nat) : ArrayStorage.BF :=
  let maxval := maximum p memory maxBase
  let normalizer := sum p memory normBase
  if FloatLib.Floats.Formats.BinaryInterchange.Model.isInf (Numerics.model maxval) then BFloat16.narrow maxval
  else BFloat16.narrow (FlushToZero.add (p.log normalizer) maxval)

theorem finish_model (scratch : LogSumExpMemory.Scratch p source) :
    finish p scratch.normalizers.memory scratch.maxBase scratch.normBase=
      LogSumExpMemory.finish p source scratch.maxima scratch.normalizers := by
  unfold finish
  rw [max_after scratch]
  unfold LogSumExpMemory.finish LogSumExpRanges.finish
  rfl

theorem read_bounds (scratch : LogSumExpMemory.Scratch p source) (lane : Fin 32) :
    scratch.maxBase+4*lane.val+4≤2^64 ∧ scratch.normBase+4*lane.val+4≤2^64 := by
  have := scratch.maxima.bounded
  have := scratch.normalizers.bounded
  have := lane.isLt
  constructor <;> omega

theorem owners (simd : Fin 32) :
    LogSumExpLayout.groupOf (LogSumExpLayout.writer simd)=simd ∧
      (LogSumExpLayout.laneOf (LogSumExpLayout.writer simd)).val=0 := LogSumExpLayout.writer_index simd
end Inference.Kernels.Sampling.LogSumExpSourceScratch
