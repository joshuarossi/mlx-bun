import state.KvGrowthPairMemory

namespace Inference.State.KvGrowthAllocation
open Contracts.Mlx
set_option maxRecDepth 10000

-- Independent zero extensions and repacked key/value arrays. Addresses are
-- byte offsets; the concat kernels receive their corresponding half indices.
def tensorBytes (n : Nat) : Nat := 2048*(n+256)
def bytes (n : Nat) : Nat := 1048576+2*tensorBytes n

variable {n : Nat} {cache : Kv.Cache Kv.BF n}

structure Workspace (old : KvRegions.Storage cache) where
  base : Nat
  aligned : base%2=0
  bounded : base+bytes n≤2^64
  keys : MemoryRegions.Disjoint base (bytes n) old.layout.keyBase (KvRegions.bytes n)
  values : MemoryRegions.Disjoint base (bytes n) old.layout.valueBase (KvRegions.bytes n)

variable {old : KvRegions.Storage cache}

theorem Workspace.separate (w : Workspace old) {offset count other size : Nat}
    (inside : offset+count≤bytes n) (safe : MemoryRegions.Disjoint w.base (bytes n) other size) :
    MemoryRegions.Disjoint (w.base+offset) count other size := by
  unfold MemoryRegions.Disjoint at *
  omega

theorem Workspace.half_bases (w : Workspace old) :
    2*(w.base/2)=w.base ∧
    2*((w.base+524288)/2)=w.base+524288 ∧
    2*((w.base+524288+tensorBytes n)/2)=w.base+524288+tensorBytes n ∧
    2*((w.base+1048576+tensorBytes n)/2)=w.base+1048576+tensorBytes n := by
  have := w.aligned
  dsimp [tensorBytes]
  omega

theorem old_half_bases (old : KvRegions.Storage cache) :
    2*(old.layout.keyBase/2)=old.layout.keyBase ∧
    2*(old.layout.valueBase/2)=old.layout.valueBase := by
  have := old.layout.keyAligned
  have := old.layout.valueAligned
  omega

theorem old_bytes (growing : KvAllocation.capacity n<n+1) : KvRegions.bytes n=2*(4*n*256) := by
  rw [KvRegions.bytes,KvAllocation.growth_full n growing]

def Workspace.keyLayout (w : Workspace old) (growing : KvAllocation.capacity n<n+1) : KvConcatMemory.Layout n where
  oldBase := old.layout.keyBase/2
  zeroBase := w.base/2
  destination := (w.base+524288)/2
  oldSeparate := by
    rw [w.half_bases.2.1,(old_half_bases old).1,← old_bytes growing]
    exact w.separate (by dsimp [bytes,tensorBytes]; omega) w.keys
  zeroSeparate := by
    rw [w.half_bases.2.1,w.half_bases.1]
    exact Or.inr (by omega)

def Workspace.valueLayout (w : Workspace old) (growing : KvAllocation.capacity n<n+1) : KvConcatMemory.Layout n where
  oldBase := old.layout.valueBase/2
  zeroBase := (w.base+524288+tensorBytes n)/2
  destination := (w.base+1048576+tensorBytes n)/2
  oldSeparate := by
    rw [w.half_bases.2.2.2,(old_half_bases old).2,← old_bytes growing]
    simpa only [Nat.add_assoc] using w.separate (offset := 1048576+tensorBytes n) (count := 2*(4*(n+256)*256)) (by dsimp [bytes,tensorBytes]; omega) w.values
  zeroSeparate := by
    rw [w.half_bases.2.2.2,w.half_bases.2.2.1]
    exact Or.inr (by omega)

def Workspace.allocation (w : Workspace old) (growing : KvAllocation.capacity n<n+1) : KvGrowthPairMemory.Allocation old where
  growing := growing
  keyLayout := w.keyLayout growing
  valueLayout := w.valueLayout growing
  keyBase := (old_half_bases old).1
  valueBase := (old_half_bases old).2
  keyZeroSeparate := by
    change MemoryRegions.Disjoint (2*(w.base/2)) 524288 (2*(old.layout.keyBase/2)) (2*(4*n*256))
    rw [w.half_bases.1,(old_half_bases old).1,← old_bytes growing]
    simpa using w.separate (offset := 0) (count := 524288) (by dsimp [bytes]; omega) w.keys
  valueZeroSeparate := by
    change MemoryRegions.Disjoint (2*((w.base+524288+tensorBytes n)/2)) 524288 (2*(old.layout.valueBase/2)) (2*(4*n*256))
    rw [w.half_bases.2.2.1,(old_half_bases old).2,← old_bytes growing]
    simpa only [Nat.add_assoc] using w.separate (offset := 524288+tensorBytes n) (count := 524288) (by dsimp [bytes]; omega) w.values
  zeroKeepsOldValues := by
    change MemoryRegions.Disjoint (2*(w.base/2)) 524288 (2*(old.layout.valueBase/2)) (2*(4*n*256))
    rw [w.half_bases.1,(old_half_bases old).2,← old_bytes growing]
    simpa using w.separate (offset := 0) (count := 524288) (by dsimp [bytes]; omega) w.values
  copyKeepsOldValues := by
    change MemoryRegions.Disjoint (2*((w.base+524288)/2)) (2*(4*(n+256)*256)) (2*(old.layout.valueBase/2)) (2*(4*n*256))
    rw [w.half_bases.2.1,(old_half_bases old).2,← old_bytes growing]
    exact w.separate (by dsimp [bytes,tensorBytes]; omega) w.values
  zeroKeepsKeys := by
    change MemoryRegions.Disjoint (2*((w.base+524288+tensorBytes n)/2)) 524288 (2*((w.base+524288)/2)) (2*(4*(n+256)*256))
    rw [w.half_bases.2.2.1,w.half_bases.2.1]
    exact Or.inr (by dsimp [tensorBytes]; omega)
  separate := by
    change MemoryRegions.Disjoint (2*((w.base+524288)/2)) (2*(4*(n+256)*256)) (2*((w.base+1048576+tensorBytes n)/2)) (2*(4*(n+256)*256))
    rw [w.half_bases.2.1,w.half_bases.2.2.2]
    exact Or.inl (by dsimp [tensorBytes]; omega)
  keyBound := by
    change 2*((w.base+524288)/2)+2*(4*(n+256)*256)≤2^64
    rw [w.half_bases.2.1]
    have := w.bounded
    dsimp [bytes,tensorBytes] at this
    omega
  valueBound := by
    change 2*((w.base+1048576+tensorBytes n)/2)+2*(4*(n+256)*256)≤2^64
    rw [w.half_bases.2.2.2]
    have := w.bounded
    dsimp [bytes,tensorBytes] at *
    omega

def Workspace.execution (w : Workspace old) (growing : KvAllocation.capacity n<n+1) :=
  KvGrowthPairMemory.fromStorage old (w.allocation growing)

theorem Workspace.layout (w : Workspace old) (growing : KvAllocation.capacity n<n+1) :
    (w.execution growing).prepared.layout.keyBase=w.base+524288 ∧
    (w.execution growing).prepared.layout.valueBase=w.base+1048576+tensorBytes n :=
  ⟨w.half_bases.2.1,w.half_bases.2.2.2⟩

theorem Workspace.frame (w : Workspace old) (growing : KvAllocation.capacity n<n+1) {other size : Nat}
    (safe : MemoryRegions.Disjoint w.base (bytes n) other size) (offset : Nat) (bound : offset<size) :
    (w.execution growing).prepared.memory (other+offset)=old.memory (other+offset) := by
  apply (w.execution growing).other_region
  · change MemoryRegions.Disjoint (2*(w.base/2)) 524288 other size
    rw [w.half_bases.1]
    simpa using w.separate (offset := 0) (count := 524288) (by dsimp [bytes]; omega) safe
  · change MemoryRegions.Disjoint (2*((w.base+524288)/2)) (2*(4*(n+256)*256)) other size
    rw [w.half_bases.2.1]
    exact w.separate (by dsimp [bytes,tensorBytes]; omega) safe
  · change MemoryRegions.Disjoint (2*((w.base+524288+tensorBytes n)/2)) 524288 other size
    rw [w.half_bases.2.2.1]
    simpa only [Nat.add_assoc] using w.separate (offset := 524288+tensorBytes n) (count := 524288) (by dsimp [bytes]; omega) safe
  · change MemoryRegions.Disjoint (2*((w.base+1048576+tensorBytes n)/2)) (2*(4*(n+256)*256)) other size
    rw [w.half_bases.2.2.2]
    simpa only [Nat.add_assoc] using w.separate (offset := 1048576+tensorBytes n) (count := 2*(4*(n+256)*256)) (by dsimp [bytes,tensorBytes]; omega) safe
  · exact bound

theorem supported_footprint (growing : KvAllocation.capacity n<n+1) (supported : n+1≤262144) : bytes n≤1074790400 := by
  have := (KvAllocation.growth_iff n).mp growing
  dsimp [bytes,tensorBytes]
  omega

end Inference.State.KvGrowthAllocation
