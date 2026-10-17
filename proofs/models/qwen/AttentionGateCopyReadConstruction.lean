import models.qwen.AttentionGateCopyFront
import models.qwen.AttentionBlockMemory
import kernels.attention.MlxSdpaTwoPassQueryGeometry

namespace Inference.Models.Qwen.AttentionGateCopyReadConstruction
open Contracts.Mlx Kernels.Attention State
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2D.labels Copy2DMemory.programs

structure Input (layer : Attention.Layer) {n : Nat} (cache : Kv.Cache Kv.BF n)
    (values : Fin 5120 → ArrayStorage.BF) (angle : RopeAngles.Inputs) where
  front : AttentionGateCopyFront.Execution layer values angle
  storage : KvRegions.Storage cache
  shared : storage.memory=front.phase.q.source.bytes
  keysSafe : AttentionGateCopyFront.Safe front storage.layout.keyBase (KvRegions.bytes n)
  valuesSafe : AttentionGateCopyFront.Safe front storage.layout.valueBase (KvRegions.bytes n)

variable {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}

def Input.oldAfter (s : Input layer cache values angle) : KvRegions.Storage cache :=
  s.front.cacheAfter s.storage s.shared s.keysSafe s.valuesSafe

structure AppendPlan (s : Input layer cache values angle) where
  preparation : AttentionBlockMemory.Preparation s.oldAfter
  keyPrepared : preparation.Safe s.front.keySource.base (KvAppendMemory.sourceBytes s.front.keySource)
  valuePrepared : preparation.Safe s.front.valueSource.base (KvAppendMemory.sourceBytes s.front.valueSource)
  keySeparate : MemoryRegions.Disjoint preparation.storage.layout.keyBase (KvRegions.bytes (n+1)) s.front.keySource.base (KvAppendMemory.sourceBytes s.front.keySource)
  valueSeparate : MemoryRegions.Disjoint preparation.storage.layout.valueBase (KvRegions.bytes (n+1)) s.front.valueSource.base (KvAppendMemory.sourceBytes s.front.valueSource)
  valueKeySeparate : MemoryRegions.Disjoint preparation.storage.layout.keyBase (KvRegions.bytes (n+1)) s.front.valueSource.base (KvAppendMemory.sourceBytes s.front.valueSource)

def AppendPlan.append {s : Input layer cache values angle} (a : AppendPlan s) :
    AttentionBlockMemory.Append (layer.heads values angle) s.oldAfter :=
  ⟨a.preparation,s.front.keySource,s.front.valueSource,rfl,rfl,a.keyPrepared,a.valuePrepared,
    a.keySeparate,a.valueSeparate,a.valueKeySeparate⟩

structure ReadPlan (s : Input layer cache values angle) where
  allocation : AppendPlan s
  queriesSafe : ∀ head, allocation.append.Safe (s.front.query head).base 512
  gatesSafe : ∀ head, allocation.append.Safe (s.front.gate head).base 512

variable {s : Input layer cache values angle}

def ReadPlan.input (read : ReadPlan s) : SdpaMemory.Input (layer.heads values angle).query
    (layer.cacheAfter values angle cache) :=
  read.allocation.append.input s.front.query s.front.shared.1 read.queriesSafe

def ReadPlan.gates (read : ReadPlan s) (head : Fin 24) : ArrayStorage.BFBuffer ((layer.heads values angle).gate head) :=
  read.allocation.append.buffer (s.front.gate head) (s.front.shared.2.1 head) (read.gatesSafe head)

theorem ReadPlan.gates_shared (read : ReadPlan s) (head : Fin 24) :
    (read.gates head).bytes=read.input.cache.memory := rfl

-- The native pointer/capture geometry is now derived from actual RoPE output
-- stores and protected append frames, rather than supplied as an independent
-- expected query layout premise to one-pass or two-pass SDPA source proofs.
theorem ReadPlan.query_layout (read : ReadPlan s) (head : Fin 24) :
    (read.input.query head).base=s.front.rope.query.destination+2*(head.val*256) :=
  s.front.query_base head

theorem ReadPlan.query_contiguous (read : ReadPlan s) :
    ∀ head, (read.input.query head).base=(read.input.query 0).base+2*(head.val*256) := by
  intro head
  rw [read.query_layout head,read.query_layout 0]
  simp

theorem ReadPlan.gate_layout (read : ReadPlan s) (head : Fin 24) :
    (read.gates head).base=2*(s.front.phase.gateCopy.base/2+head.val*256) := by
  change (s.front.gate head).base=_
  rw [s.front.gate_base head]
  have aligned := s.front.phase.gateCopy.aligned
  omega

theorem ReadPlan.two_pass_capture (read : ReadPlan s) (blocks : Nat) (head : Fin 24)
    (block : Fin blocks) (lane : Fin 32) (item : Fin 8) :
    MlxSdpaTwoPassQueryGeometry.registers read.input.cache.memory s.front.rope.query.destination blocks head block lane item=
      ArrayStorage.bits ((layer.heads values angle).query head (SdpaScore.index lane item)) :=
  MlxSdpaTwoPassQueryGeometry.captured read.input s.front.rope.query.destination blocks read.query_layout head block lane item

theorem ReadPlan.two_pass_current_capture (read : ReadPlan s) {blocks : Nat} {p : SdpaVector.Platform}
    (first : SdpaTwoPassShared.Execution read.input p blocks) (head : Fin 24)
    (block : Fin blocks) (lane : Fin 32) (item : Fin 8) :
    MlxSdpaTwoPassQueryGeometry.registers first.inputAfter.cache.memory s.front.rope.query.destination blocks head block lane item=
      ArrayStorage.bits ((layer.heads values angle).query head (SdpaScore.index lane item)) := by
  have layout : ∀ head, (first.inputAfter.query head).base=s.front.rope.query.destination+2*(head.val*256) := by
    intro head
    exact read.query_layout head
  exact MlxSdpaTwoPassQueryGeometry.captured first.inputAfter s.front.rope.query.destination blocks layout head block lane item

end Inference.Models.Qwen.AttentionGateCopyReadConstruction
