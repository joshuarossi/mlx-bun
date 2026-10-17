import kernels.sampling.LogSumExpRanges
import contracts.mlx.FloatArrayWrites
import contracts.mlx.HalfArrayWrites
import contracts.mlx.ArrayViews

namespace Inference.Kernels.Sampling.LogSumExpDevice
open Contracts.Mlx
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000
variable {logits : Fin 248320 → BF}

@[irreducible] def groups (p : LogSumExpRanges.Platform) (source : ArrayStorage.BFBuffer logits) : Fin 32 → LogSumExpBlockRanges.State :=
  LogSumExpRanges.groupState p (fun i => BFloat16.widen (source.read i))

theorem groups_eq (p : LogSumExpRanges.Platform) (source : ArrayStorage.BFBuffer logits) :
    groups p source=LogSumExpRanges.groupState p (fun i => BFloat16.widen (logits i)) := by
  have equal : (fun i => BFloat16.widen (source.read i))=(fun i => BFloat16.widen (logits i)) := by
    funext i
    rw [ArrayStorage.BFBuffer.read_correct]
  unfold groups
  rw [equal]

def maximum (p : LogSumExpRanges.Platform) (source : ArrayStorage.BFBuffer logits)
    (maxima : FloatArrayWrites.Trace 0 (fun group => (groups p source group).maximum)) : Float32 :=
  Maximum.tree maxima.buffer.read p.maximumTree

theorem maximum_eq (p : LogSumExpRanges.Platform) (source : ArrayStorage.BFBuffer logits)
    (maxima : FloatArrayWrites.Trace 0 (fun group => (groups p source group).maximum)) :
    maximum p source maxima=LogSumExpMergeRanges.maximum (groups p source) p.maximumTree := by
  have equal : maxima.buffer.read=(fun group => (groups p source group).maximum) := funext maxima.buffer.read_correct
  unfold maximum
  rw [equal]
  rfl

@[irreducible] def adjusted (p : LogSumExpRanges.Platform) (source : ArrayStorage.BFBuffer logits)
    (maxima : FloatArrayWrites.Trace 0 (fun group => (groups p source group).maximum)) (group : Fin 32) : Float32 :=
  FlushToZero.mul (groups p source group).normalizer
    (Attention.SdpaUpdate.exponential p.scalar (groups p source group).maximum (maximum p source maxima))

@[irreducible] def finish (p : LogSumExpRanges.Platform) (source : ArrayStorage.BFBuffer logits)
    (maxima : FloatArrayWrites.Trace 0 (fun group => (groups p source group).maximum))
    (normalizers : FloatArrayWrites.Trace 0 (adjusted p source maxima)) : BF :=
  LogSumExpRanges.finish p ⟨maximum p source maxima, FlushedReduction.evaluate normalizers.buffer.read p.sumTree⟩

-- The first completed scratch phase stores the 32 SIMD maxima. The second
-- stores each SIMD's rescaled normalizer after reading those same maxima.
structure Execution (p : LogSumExpRanges.Platform) (logits : Fin 248320 → BF) where
  source : ArrayStorage.BFBuffer logits
  maxima : FloatArrayWrites.Trace 0 (fun group => (groups p source group).maximum)
  normalizers : FloatArrayWrites.Trace 0 (adjusted p source maxima)
  output : HalfArrayWrites.Trace 0 (fun _ : Fin 1 => ArrayStorage.bits (finish p source maxima normalizers))

def Execution.fromStorage (p : LogSumExpRanges.Platform) (logits : Fin 248320 → BF) (source : ArrayStorage.BFBuffer logits) :
    Execution p logits :=
  let maxima := FloatArrayWrites.Trace.canonical (fun group => (groups p source group).maximum) (by decide)
  let normalizers := FloatArrayWrites.Trace.canonical (adjusted p source maxima) (by decide)
  ⟨source, maxima, normalizers, HalfArrayWrites.Trace.canonical _ (by decide)⟩

variable {p : LogSumExpRanges.Platform}

theorem Execution.finish_eq (execution : Execution p logits) :
    finish p execution.source execution.maxima execution.normalizers=LogSumExpRanges.value p logits := by
  have read : execution.normalizers.buffer.read=adjusted p execution.source execution.maxima :=
    funext execution.normalizers.buffer.read_correct
  have adjustedEq : adjusted p execution.source execution.maxima=(fun group =>
      FlushToZero.mul (groups p execution.source group).normalizer
        (Attention.SdpaUpdate.exponential p.scalar (groups p execution.source group).maximum
          (LogSumExpMergeRanges.maximum (groups p execution.source) p.maximumTree))) := by
    funext group
    unfold adjusted
    rw [maximum_eq]
  unfold finish
  rw [maximum_eq, read, adjustedEq, ← LogSumExpMergeRanges.execution, groups_eq]
  rfl

def Execution.value (execution : Execution p logits) : BF := execution.output.buffer.read 0

theorem Execution.value_eq (execution : Execution p logits) : execution.value=LogSumExpRanges.value p logits := by
  unfold Execution.value
  rw [ArrayStorage.BFBuffer.read_correct, execution.finish_eq]

def Execution.outputBuffer (execution : Execution p logits) : ArrayStorage.BFBuffer (fun _ : Fin 1 => execution.value) where
  bytes := execution.output.memory
  base := 0
  aligned := by decide
  bounded := by decide
  attached := by intro i; have same : i=0 := Fin.ext (by omega); subst i; rfl

theorem Execution.output_bytes (execution : Execution p logits) : execution.outputBuffer.bytes=execution.output.memory := rfl

theorem launch : 248320>4096 ∧ (248320+4096-1)/4096=61 ∧ 1024/32=32 := by decide

end Inference.Kernels.Sampling.LogSumExpDevice
