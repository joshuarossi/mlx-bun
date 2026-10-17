import models.qwen.AttentionAffine
import kernels.RmsNormDevice
import contracts.mlx.Copy2D
import contracts.mlx.CopyShape
import contracts.mlx.CopyIndices

namespace Inference.Models.Qwen.AttentionNormalization
open Contracts.Mlx
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000

def queryLayout {p : AttentionHeads.Projections} {input : Fin 5120 → BF}
    (projections : AttentionAffine.Execution p input) : Copy2D.Layout :=
  ⟨projections.q.forwardBuffer.base, 512, 1, 0, 256⟩

abbrev QueryCopy {p : AttentionHeads.Projections} {input : Fin 5120 → BF}
    (projections : AttentionAffine.Execution p input) :=
  Copy2D.Trace (queryLayout projections) projections.q.forwardBuffer.bytes 24 256

def queryBuffer {p : AttentionHeads.Projections} {input : Fin 5120 → BF}
    (projections : AttentionAffine.Execution p input) (copy : QueryCopy projections) (head : Fin 24) :
    ArrayStorage.BFBuffer ((p.forward input).query head) where
  bytes := copy.memory
  base := 2*(head.val*256)
  aligned := by omega
  bounded := by have := head.isLt; omega
  attached := by
    intro i
    have read := copy.read_correct (head, i)
    have address : Copy2D.sourceAddress (queryLayout projections) (head, i)=
        projections.q.forwardBuffer.base+2*(AttentionHeads.queryIndex head i).val := by
      dsimp [Copy2D.sourceAddress, queryLayout, AttentionHeads.queryIndex]
      omega
    rw [address, projections.q.forwardBuffer.attached] at read
    simpa only [queryLayout, Copy2D.destination, Nat.zero_add, Nat.mul_add, Nat.add_comm, AttentionHeads.Projections.forward] using read

structure Execution (p : AttentionHeads.Projections) (prep : AttentionHeads.Preparation)
    (input : Fin 5120 → BF) (projections : AttentionAffine.Execution p input) where
  queryCopy : QueryCopy projections
  query : ∀ head, Kernels.RmsNormDevice.Execution prep.qNorm.platform ((p.forward input).query head)
    prep.qNorm.weight AttentionHeads.width Blocks.eps
  key : ∀ head, Kernels.RmsNormDevice.Execution prep.kNorm.platform ((p.forward input).key head)
    prep.kNorm.weight AttentionHeads.width Blocks.eps
  queryInput : ∀ head, (query head).source=queryBuffer projections queryCopy head
  keyInput : ∀ head, (key head).source=projections.key head

def Execution.fromProjections (p : AttentionHeads.Projections) (prep : AttentionHeads.Preparation)
    (input : Fin 5120 → BF) (projections : AttentionAffine.Execution p input) : Execution p prep input projections :=
  let queryCopy := Copy2D.Trace.canonical (queryLayout projections) projections.q.forwardBuffer.bytes (fun _ => 0) 24 256 (by rfl) (by change 256 ≤ 256; decide)
  let query := fun head => Kernels.RmsNormDevice.Execution.fromStorage prep.qNorm.platform ((p.forward input).query head)
    prep.qNorm.weight AttentionHeads.width Blocks.eps (queryBuffer projections queryCopy head)
    (ArrayStorage.BFBuffer.canonical _ (by decide)) (by decide)
  let key := fun head => Kernels.RmsNormDevice.Execution.fromStorage prep.kNorm.platform ((p.forward input).key head)
    prep.kNorm.weight AttentionHeads.width Blocks.eps (projections.key head)
    (ArrayStorage.BFBuffer.canonical _ (by decide)) (by decide)
  ⟨queryCopy, query, key, fun _ => rfl, fun _ => rfl⟩

variable {p : AttentionHeads.Projections} {prep : AttentionHeads.Preparation} {input : Fin 5120 → BF}
  {projections : AttentionAffine.Execution p input}

def Execution.queryBuffer (execution : Execution p prep input projections) (head : Fin 24) :
    ArrayStorage.BFBuffer ((prep.normalized (p.forward input)).query head) :=
  (execution.query head).forwardBuffer prep.qNorm.scratch prep.qNorm.base

def Execution.keyBuffer (execution : Execution p prep input projections) (head : Fin 4) :
    ArrayStorage.BFBuffer ((prep.normalized (p.forward input)).key head) :=
  (execution.key head).forwardBuffer prep.kNorm.scratch prep.kNorm.base

theorem Execution.query_bytes (execution : Execution p prep input projections) (head : Fin 24) :
    (execution.queryBuffer head).bytes=(execution.query head).stores.memory :=
  (execution.query head).forward_bytes prep.qNorm.scratch prep.qNorm.base

theorem Execution.key_bytes (execution : Execution p prep input projections) (head : Fin 4) :
    (execution.keyBuffer head).bytes=(execution.key head).stores.memory :=
  (execution.key head).forward_bytes prep.kNorm.scratch prep.kNorm.base

theorem query_copy_shape : CopyShape.collapse (2^31-1)
    [⟨1, 12288, 6144⟩, ⟨24, 512, 256⟩, ⟨256, 1, 1⟩]=[⟨24, 512, 256⟩, ⟨256, 1, 1⟩] := by decide +kernel

theorem query_copy_signed (head : Fin 24) (i : Fin 256) :
    (CopyIndices.elem2 i.val head.val 1 512).toInt=Int.ofNat (AttentionHeads.queryIndex head i).val := by
  have := head.isLt
  have := i.isLt
  have exactIndex := CopyIndices.elem2_signed i.val head.val 1 512 (by omega) (by omega) (by decide) (by decide) (by omega)
  simpa only [AttentionHeads.queryIndex, Nat.mul_one, Nat.add_comm] using exactIndex

end Inference.Models.Qwen.AttentionNormalization
