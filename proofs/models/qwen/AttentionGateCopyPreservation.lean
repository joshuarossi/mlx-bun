import models.qwen.AttentionGateCopyRopeMemory

namespace Inference.Models.Qwen.AttentionGateCopyPreservation
open Contracts.Mlx Kernels.Attention State
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2D.labels Copy2DMemory.programs

variable {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF}
  {phase : AttentionGateCopyKvMemory.Execution layer.projections input}
  {copy : AttentionGateCopyQueryMemory.Execution phase}
  {parameters : AttentionParameterMemory.Storage layer copy.copy.memory}
  {normal : AttentionGateCopyNormalizationMemory.Execution copy parameters} {angle : RopeAngles.Inputs}

-- Every stage's destination footprint is included, including the gate copy
-- which was absent from the original Q/K/V-only phase type.
def PhaseSafe (phase : AttentionGateCopyKvMemory.Execution layer.projections input) (base size : Nat) : Prop :=
  MemoryRegions.Disjoint phase.q.base 24576 base size ∧
  MemoryRegions.Disjoint phase.gateCopy.base 12288 base size ∧
  MemoryRegions.Disjoint phase.k.base 2048 base size ∧
  MemoryRegions.Disjoint phase.v.base 2048 base size

theorem phase_frame {base size : Nat} (safe : PhaseSafe phase base size) (offset : Nat) (bound : offset<size) :
    phase.memory (base+offset)=phase.q.source.bytes (base+offset) := by
  have value := phase.v.other_region safe.2.2.2 offset bound
  rw [phase.value_input_memory] at value
  have key := phase.k.other_region safe.2.2.1 offset bound
  rw [phase.keyInputMemory] at key
  have gateCopy := MlxAttentionGateCopyMemory.other_region phase.gateCopy safe.2.1 offset bound
  have shared := congrArg ArrayStorage.BFBuffer.bytes phase.gateCopySource
  rw [shared] at gateCopy
  exact value.trans (key.trans (gateCopy.trans (phase.q.other_region safe.1 offset bound)))

structure Safe (rope : AttentionGateCopyRopeMemory.Execution normal angle) (base size : Nat) : Prop where
  phase : PhaseSafe phase base size
  queryCopy : MemoryRegions.Disjoint (2*copy.destination) 12288 base size
  normalization : AttentionGateCopyNormalizationMemory.Safe normal base size
  rotation : AttentionGateCopyRopeMemory.Safe rope base size

theorem frame (rope : AttentionGateCopyRopeMemory.Execution normal angle) {base size : Nat}
    (safe : Safe rope base size) (offset : Nat) (bound : offset<size) :
    rope.memory (base+offset)=phase.q.source.bytes (base+offset) :=
  (rope.other_region safe.rotation offset bound).trans
    ((normal.other_region safe.normalization offset bound).trans
      ((copy.other_region safe.queryCopy offset bound).trans (phase_frame safe.phase offset bound)))

-- Construct the old cache on the final current heap from protected bytes.
-- A post-projection/cache attachment or expected phase output is not a premise.
def cacheAfter {n : Nat} {cache : Kv.Cache Kv.BF n}
    (rope : AttentionGateCopyRopeMemory.Execution normal angle) (storage : KvRegions.Storage cache)
    (shared : storage.memory=phase.q.source.bytes)
    (keysSafe : Safe rope storage.layout.keyBase (KvRegions.bytes n))
    (valuesSafe : Safe rope storage.layout.valueBase (KvRegions.bytes n)) : KvRegions.Storage cache :=
  storage.reframe rope.memory
    (fun offset bound => (frame rope keysSafe offset bound).trans (congrFun shared _).symm)
    (fun offset bound => (frame rope valuesSafe offset bound).trans (congrFun shared _).symm)

end Inference.Models.Qwen.AttentionGateCopyPreservation
