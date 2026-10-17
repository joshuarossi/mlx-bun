import models.qwen.AttentionNormalization
import kernels.attention.RopeDevice
import contracts.mlx.RowStorage
import state.KvCopy

namespace Inference.Models.Qwen.AttentionHeadsDevice
open Contracts.Mlx Kernels.Attention
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000

structure Execution (p : AttentionHeads.Projections) (prep : AttentionHeads.Preparation)
    (input : Fin 5120 → BF) (angle : RopeAngles.Inputs) where
  projections : AttentionAffine.Execution p input
  normalization : AttentionNormalization.Execution p prep input projections
  query : ∀ head, RopeDevice.Execution prep.rotation ((prep.normalized (p.forward input)).query head) (RopeAngles.value prep.angles angle)
  key : ∀ head, RopeDevice.Execution prep.rotation ((prep.normalized (p.forward input)).key head) (RopeAngles.value prep.angles angle)
  queryInput : ∀ head, (query head).source=normalization.queryBuffer head
  keyInput : ∀ head, (key head).source=normalization.keyBuffer head

def Execution.fromNormalization (p : AttentionHeads.Projections) (prep : AttentionHeads.Preparation)
    (input : Fin 5120 → BF) (angle : RopeAngles.Inputs) (projections : AttentionAffine.Execution p input)
    (normalization : AttentionNormalization.Execution p prep input projections) : Execution p prep input angle :=
  let query : ∀ head : Fin 24, RopeDevice.Execution prep.rotation ((prep.normalized (p.forward input)).query head)
      (RopeAngles.value prep.angles angle) := fun head => RopeDevice.Execution.fromStorage prep.rotation ((prep.normalized (p.forward input)).query head)
    (RopeAngles.value prep.angles angle) (normalization.queryBuffer head)
  let key : ∀ head : Fin 4, RopeDevice.Execution prep.rotation ((prep.normalized (p.forward input)).key head)
      (RopeAngles.value prep.angles angle) := fun head => RopeDevice.Execution.fromStorage prep.rotation ((prep.normalized (p.forward input)).key head)
    (RopeAngles.value prep.angles angle) (normalization.keyBuffer head)
  ⟨projections, normalization, query, key, fun _ => RopeDevice.Execution.fromStorage_source _ _ _ _,
    fun _ => RopeDevice.Execution.fromStorage_source _ _ _ _⟩

def Execution.fromStorage (p : AttentionHeads.Projections) (prep : AttentionHeads.Preparation)
    (input : Fin 5120 → BF) (angle : RopeAngles.Inputs) (source : ArrayStorage.BFBuffer input)
    (weights : AttentionAffine.Weights p) : Execution p prep input angle :=
  let projections := AttentionAffine.Execution.fromStorage p input source weights
  Execution.fromNormalization p prep input angle projections (AttentionNormalization.Execution.fromProjections p prep input projections)

variable {p : AttentionHeads.Projections} {prep : AttentionHeads.Preparation}
  {input : Fin 5120 → BF} {angle : RopeAngles.Inputs}

def Execution.queryBuffer (execution : Execution p prep input angle) (head : Fin 24) :
    ArrayStorage.BFBuffer ((prep.forward (p.forward input) angle).query head) := (execution.query head).buffer

def Execution.keyBuffer (execution : Execution p prep input angle) (head : Fin 4) :
    ArrayStorage.BFBuffer ((prep.forward (p.forward input) angle).key head) := (execution.key head).buffer

def Execution.valueBuffer (execution : Execution p prep input angle) (head : Fin 4) :
    ArrayStorage.BFBuffer ((prep.forward (p.forward input) angle).value head) := execution.projections.value head

def Execution.gateBuffer (execution : Execution p prep input angle) (head : Fin 24) :
    ArrayStorage.BFBuffer ((prep.forward (p.forward input) angle).gate head) := execution.projections.gate head

def Execution.keySource (execution : Execution p prep input angle) : State.KvCopy.Source ((prep.forward (p.forward input) angle).key) where
  bytes := RowStorage.bytes execution.keyBuffer
  base := 0
  rowStride := 256
  columnStride := 1
  aligned := by decide
  attached := by
    intro head i
    simp only [Nat.zero_add, Nat.mul_one]
    rw [Nat.add_comm i.val, RowStorage.raw_read]
    exact (execution.keyBuffer head).attached i

def Execution.valueSource (execution : Execution p prep input angle) : State.KvCopy.Source ((prep.forward (p.forward input) angle).value) where
  bytes := execution.projections.v.forwardBuffer.bytes
  base := execution.projections.v.forwardBuffer.base
  rowStride := 256
  columnStride := 1
  aligned := execution.projections.v.forwardBuffer.aligned
  attached := by
    intro head i
    simpa only [AttentionHeads.kvIndex, Nat.mul_one, Nat.add_comm, AttentionHeads.Projections.forward,
      AttentionHeads.Preparation.forward, Layers.AffineDevice.Execution.forwardBuffer, State.KvBytes.bits, ArrayStorage.bits] using
      execution.projections.v.forwardBuffer.attached (AttentionHeads.kvIndex head i)

def Execution.read (execution : Execution p prep input angle) : AttentionHeads.Heads BF where
  query head := (execution.queryBuffer head).read
  key head := (execution.keyBuffer head).read
  value head := (execution.valueBuffer head).read
  gate head := (execution.gateBuffer head).read

theorem Execution.read_eq (execution : Execution p prep input angle) :
    execution.read=prep.forward (p.forward input) angle := by
  unfold Execution.read
  have q : (fun head => (execution.queryBuffer head).read)=(prep.forward (p.forward input) angle).query :=
    funext fun head => funext (ArrayStorage.BFBuffer.read_correct _)
  have k : (fun head => (execution.keyBuffer head).read)=(prep.forward (p.forward input) angle).key :=
    funext fun head => funext (ArrayStorage.BFBuffer.read_correct _)
  have v : (fun head => (execution.valueBuffer head).read)=(prep.forward (p.forward input) angle).value :=
    funext fun head => funext (ArrayStorage.BFBuffer.read_correct _)
  have g : (fun head => (execution.gateBuffer head).read)=(prep.forward (p.forward input) angle).gate :=
    funext fun head => funext (ArrayStorage.BFBuffer.read_correct _)
  rw [q, k, v, g]

theorem Execution.key_source_bytes (execution : Execution p prep input angle) (head : Fin 4) (i : Fin 512) :
    execution.keySource.bytes (2*(head.val*256)+i.val)=(execution.key head).rotation.memory i.val := by
  change RowStorage.bytes execution.keyBuffer (2*(head.val*256)+i.val)=_
  rw [RowStorage.byte_read execution.keyBuffer head i.val i.isLt]
  simp only [Execution.keyBuffer, RopeDevice.Execution.buffer, Nat.zero_add]

theorem Execution.value_source_bytes (execution : Execution p prep input angle) :
    execution.valueSource.bytes=execution.projections.v.outputBuffer.bytes := rfl

theorem Execution.query_input_bytes (execution : Execution p prep input angle) (head : Fin 24) :
    (execution.query head).source.bytes=(execution.normalization.query head).stores.memory := by
  rw [execution.queryInput]
  exact execution.normalization.query_bytes head

theorem Execution.key_input_bytes (execution : Execution p prep input angle) (head : Fin 4) :
    (execution.key head).source.bytes=(execution.normalization.key head).stores.memory := by
  rw [execution.keyInput]
  exact execution.normalization.key_bytes head

end Inference.Models.Qwen.AttentionHeadsDevice
