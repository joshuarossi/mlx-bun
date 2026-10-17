import models.qwen.CopiedAttentionParameterConstruction
import models.qwen.AttentionNormalizedConstruction
namespace Inference.Models.Qwen.CopiedAttentionProjectionAllocation
open Contracts.Mlx Layers
set_option maxRecDepth 10000

def bytes : Nat := 53248

theorem contained {base first firstSize other size : Nat}
    (lower : base≤first) (upper : first+firstSize≤base+bytes)
    (separate : MemoryRegions.Disjoint base bytes other size) : MemoryRegions.Disjoint first firstSize other size := by
  unfold MemoryRegions.Disjoint at *
  omega

structure Workspace {p : AttentionHeads.Projections} {input : Fin 5120 → ArrayStorage.BF}
    (source : ArrayStorage.BFBuffer input) (weights : AttentionAffineConstruction.Weights p source.bytes) where
  base : Nat
  aligned : base%2=0
  bounded : base+bytes≤2^64
  inputSeparate : MemoryRegions.Disjoint base bytes source.base 10240
  weightsSeparate : AttentionNormalizedConstruction.Protected weights (MemoryRegions.Disjoint base bytes)

variable {p : AttentionHeads.Projections} {input : Fin 5120 → ArrayStorage.BF}
  {source : ArrayStorage.BFBuffer input} {weights : AttentionAffineConstruction.Weights p source.bytes}
  (w : Workspace source weights)

private def allocation {groups : Nat} (projection : AffineVerifyLinear.Projection 10 (4*groups))
    (original : AffineDevice.Storage projection)
    (safe : AffineMemoryFrames.Protected projection original (MemoryRegions.Disjoint w.base bytes))
    (offset : Nat) (aligned : offset%2=0) (bounded : offset+2*(4*groups)≤bytes) :
    CopiedAttentionProjectionLaunch.Allocation projection original (source:=source) where
  base := w.base+offset
  aligned := by have := w.aligned; omega
  bounded := by have := w.bounded; omega
  input := contained (by omega) (by omega) w.inputSeparate
  weights := AttentionAffineConstruction.separate projection original
    (AffineMemoryFrames.protected_mono projection original (fun _ _ separate => contained (by omega) (by omega) separate) safe)

def plan : CopiedAttentionProjectionConstruction.Plan p source weights (MemoryRegions.Disjoint w.base bytes) where
  inputLive := w.inputSeparate
  qLive := w.weightsSeparate.1
  kLive := w.weightsSeparate.2.1
  vLive := w.weightsSeparate.2.2
  q := allocation w (groups:=3072) p.q weights.q w.weightsSeparate.1 0 (by decide) (by decide +kernel)
  k := allocation w (groups:=256) p.k weights.k w.weightsSeparate.2.1 36864 (by decide) (by decide +kernel)
  v := allocation w (groups:=256) p.v weights.v w.weightsSeparate.2.2 38912 (by decide) (by decide +kernel)
  copyBase := w.base+24576
  copyAligned := by have := w.aligned; omega
  copyBounded := by have := w.bounded; unfold bytes at this; omega
  qSafe := fun _ _ separate => contained (by simp [allocation]) (by simp [allocation,bytes]) separate
  kSafe := fun _ _ separate => contained (by simp [allocation]) (by simp [allocation,bytes]) separate
  vSafe := fun _ _ separate => contained (by simp [allocation]) (by simp [allocation,bytes]) separate
  copySafe := fun _ _ separate => contained (by omega) (by unfold bytes; omega) separate
  copyQ := Or.inr (by simp [allocation])
  kQ := Or.inr (by simp [allocation])
  vQ := Or.inr (by simp [allocation])
  vK := Or.inr (by simp [allocation])
  kCopy := Or.inr (by simp [allocation])
  vCopy := Or.inr (by simp [allocation])

theorem query_base : (CopiedAttentionProjectionConstruction.execution weights (plan w)).queryGateBuffer.base=w.base :=
  (AttentionAffineConstruction.forward_base _).trans (by
    exact CopiedAttentionProjectionConstruction.query_base weights (plan w))

variable {layer : Attention.Layer} {weights : AttentionAffineConstruction.Weights layer.projections source.bytes}
  (w : Workspace source weights)

def queryAllocation : CopiedAttentionParameterConstruction.QueryAllocation weights (plan w) where
  destination := (w.base+40960)/2
  bounded := by have := w.bounded; unfold bytes at this; omega
  query := by rw [query_base]; have := w.aligned; unfold MemoryRegions.Disjoint; omega
  gate := by
    change MemoryRegions.Disjoint (2*((w.base+40960)/2)) 12288 (CopiedAttentionProjectionConstruction.copy weights (plan w)).base 12288
    rw [CopiedAttentionProjectionConstruction.copy_base]
    change MemoryRegions.Disjoint (2*((w.base+40960)/2)) 12288 (w.base+24576) 12288
    have := w.aligned; unfold MemoryRegions.Disjoint; omega
  safe := by
    intro base size separate
    have aligned : 2*((w.base+40960)/2)=w.base+40960 := by have := w.aligned; omega
    rw [aligned]
    exact contained (by omega) (by unfold bytes; omega) separate

theorem other_region {base size : Nat} (separate : MemoryRegions.Disjoint w.base bytes base size)
    (offset : Nat) (bound : offset<size) :
    (CopiedAttentionParameterConstruction.queryCopy weights (plan w) (queryAllocation w)).copy.memory (base+offset)=
      source.bytes (base+offset) :=
  CopiedAttentionParameterConstruction.query_frame weights (plan w) (queryAllocation w) separate offset bound
end Inference.Models.Qwen.CopiedAttentionProjectionAllocation
