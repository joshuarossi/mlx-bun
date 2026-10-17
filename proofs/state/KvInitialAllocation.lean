import state.KvInitialPairMemory

namespace Inference.State.KvInitialAllocation
open Contracts.Mlx KvSlicePreparationMemory
set_option maxRecDepth 10000
attribute [local irreducible] CopyContiguous.programs Copy2DMemory.programs CopyExecution.Trace.memory

-- Two zero slabs and room for either/both preservation copies. These are
-- address-space constructors. Native allocation ownership and actual choice
-- of donation versus allocation remain separate execution obligations.
def reservedBytes : Nat := 2097152

private theorem cache_bytes : KvRegions.bytes 1=bytes := by decide +kernel

structure Workspace (keySource : KvCopy.Source key) (valueSource : KvCopy.Source value) where
  cursor : Nat
  aligned : cursor%16=0
  bounded : cursor+reservedBytes≤2^64
  keyBefore : keySource.base+KvAppendMemory.sourceBytes keySource≤cursor
  valueBefore : valueSource.base+KvAppendMemory.sourceBytes valueSource≤cursor

variable {keySource : KvCopy.Source key} {valueSource : KvCopy.Source value}
  (workspace : Workspace keySource valueSource)

def layout : KvRegions.Layout 1 where
  keyBase := workspace.cursor
  valueBase := workspace.cursor+524288
  keyAligned := by have := workspace.aligned; omega
  valueAligned := by have := workspace.aligned; omega
  keyBound := by
    change workspace.cursor+524288≤2^64
    have := workspace.bounded
    unfold reservedBytes at this
    omega
  valueBound := by
    change workspace.cursor+524288+524288≤2^64
    have := workspace.bounded
    unfold reservedBytes at this
    omega
  separate := Or.inl (by change workspace.cursor+524288≤workspace.cursor+524288; rfl)

def keyChoice (copied : Bool) : Choice (layout workspace).keyBase :=
  match copied with
  | false => .donated (layout workspace).keyAligned
      (by have bound := (layout workspace).keyBound; rw [cache_bytes] at bound; exact bound)
  | true => .copied (workspace.cursor+1048576)
      (by have := workspace.aligned; omega)
      (by have := workspace.bounded; unfold reservedBytes at this; unfold bytes; omega)
      (Or.inr (by change workspace.cursor+bytes≤workspace.cursor+1048576; unfold bytes; omega))

private def selectChoice (source destination : Nat) (sourceAligned : source%2=0)
    (sourceBound : source+bytes≤2^64) (destinationAligned : destination%2=0)
    (destinationBound : destination+bytes≤2^64)
    (separate : MemoryRegions.Disjoint destination bytes source bytes) : Bool → Choice source
  | false => .donated sourceAligned sourceBound
  | true => .copied destination destinationAligned destinationBound separate

private theorem value_source_bound : (layout workspace).valueBase+bytes≤2^64 := by
  change workspace.cursor+524288+bytes≤2^64
  have := workspace.bounded
  unfold reservedBytes at this
  unfold bytes
  omega

private theorem value_destination_aligned : (workspace.cursor+1572864)%2=0 := by
  have := workspace.aligned
  omega

private theorem value_destination_bound : workspace.cursor+1572864+bytes≤2^64 := by
  change workspace.cursor+1572864+524288≤2^64
  rw [Nat.add_assoc]
  exact workspace.bounded

private theorem value_copy_separate : MemoryRegions.Disjoint (workspace.cursor+1572864) bytes
    (layout workspace).valueBase bytes := by
  apply Or.inr
  change workspace.cursor+524288+bytes≤workspace.cursor+1572864
  unfold bytes
  omega

def valueChoice (copied : Bool) : Choice (layout workspace).valueBase :=
  selectChoice (layout workspace).valueBase (workspace.cursor+1572864)
    (layout workspace).valueAligned
    (value_source_bound workspace) (value_destination_aligned workspace)
    (value_destination_bound workspace) (value_copy_separate workspace) copied

theorem key_destination (copied : Bool) :
    (keyChoice workspace copied).destination=workspace.cursor+(if copied then 1048576 else 0) := by
  cases copied <;> simp [keyChoice,Choice.destination,layout]

theorem value_destination (copied : Bool) :
    (valueChoice workspace copied).destination=workspace.cursor+(if copied then 1572864 else 524288) := by
  cases copied <;> simp [valueChoice,selectChoice,Choice.destination,layout]

theorem fresh {destination base size : Nat} (lower : workspace.cursor≤destination) (bound : base+size≤workspace.cursor) :
    MemoryRegions.Disjoint destination bytes base size := Or.inr (bound.trans lower)

def allocation (keyCopied valueCopied : Bool) : KvInitialPairMemory.Allocation (layout workspace) keySource valueSource where
  keySourceBound := workspace.keyBefore.trans (by have := workspace.bounded; omega)
  valueSourceBound := workspace.valueBefore.trans (by have := workspace.bounded; omega)
  keyChoice := keyChoice workspace keyCopied
  valueChoice := valueChoice workspace valueCopied
  keyZerosSafe := ⟨fresh workspace (by dsimp [layout]; omega) workspace.keyBefore,
    fresh workspace (by dsimp [layout]; omega) workspace.keyBefore⟩
  valueZerosSafe := ⟨fresh workspace (by dsimp [layout]; omega) workspace.valueBefore,
    fresh workspace (by dsimp [layout]; omega) workspace.valueBefore⟩
  keySafe := fresh workspace (by rw [key_destination]; omega) workspace.keyBefore
  valueSafe := fresh workspace (by rw [value_destination]; omega) workspace.valueBefore
  keyKeepsValueSource := fresh workspace (by rw [key_destination]; omega) workspace.valueBefore
  keyKeepsZeroValues := by
    rw [key_destination]
    cases keyCopied <;> simp only [Bool.false_eq_true,ite_false,ite_true,Nat.add_zero]
    · exact Or.inl (by change workspace.cursor+bytes≤workspace.cursor+524288; unfold bytes; omega)
    · exact Or.inr (by change workspace.cursor+524288+bytes≤workspace.cursor+1048576; unfold bytes; omega)
  separate := by
    rw [key_destination,value_destination]
    cases keyCopied <;> cases valueCopied <;>
      simp only [Bool.false_eq_true,ite_false,ite_true,Nat.add_zero] <;>
      unfold MemoryRegions.Disjoint bytes <;> omega

theorem safe (keyCopied valueCopied : Bool) {base size : Nat} (bound : base+size≤workspace.cursor) :
    KvInitialPairMemory.Safe (layout workspace) (allocation workspace keyCopied valueCopied) base size where
  keyZero := fresh workspace (by dsimp [layout]; omega) bound
  valueZero := fresh workspace (by dsimp [layout]; omega) bound
  keyOutput := fresh workspace (by change workspace.cursor≤(keyChoice workspace keyCopied).destination; rw [key_destination]; omega) bound
  valueOutput := fresh workspace (by change workspace.cursor≤(valueChoice workspace valueCopied).destination; rw [value_destination]; omega) bound

def execution (keyCopied valueCopied : Bool) (before : ByteMemory.Bytes)
    (keyShared : keySource.bytes=before) (valueShared : valueSource.bytes=before) :
    KvInitialPairMemory.Execution cache key value :=
  KvInitialPairMemory.fromSources before (layout workspace) keySource valueSource keyShared valueShared
    (allocation workspace keyCopied valueCopied)

theorem execution_safe (keyCopied valueCopied : Bool) (before : ByteMemory.Bytes)
    (keyShared : keySource.bytes=before) (valueShared : valueSource.bytes=before)
    {base size : Nat} (bound : base+size≤workspace.cursor) :
    (execution (cache:=cache) workspace keyCopied valueCopied before keyShared valueShared).Safe base size :=
  safe workspace keyCopied valueCopied bound

theorem parameter_frame (keyCopied valueCopied : Bool) (before : ByteMemory.Bytes)
    (keyShared : keySource.bytes=before) (valueShared : valueSource.bytes=before)
    {base size : Nat} (bound : base+size≤workspace.cursor) (offset : Nat) (inside : offset<size) :
    (execution (cache:=cache) workspace keyCopied valueCopied before keyShared valueShared).after.memory (base+offset)=
      before (base+offset) :=
  (execution (cache:=cache) workspace keyCopied valueCopied before keyShared valueShared).other_region
    (execution_safe workspace keyCopied valueCopied before keyShared valueShared bound) offset inside

def allocatedBytes (keyCopied valueCopied : Bool) : Nat :=
  1048576+(if keyCopied then 524288 else 0)+(if valueCopied then 524288 else 0)

theorem allocated_bound (keyCopied valueCopied : Bool) : allocatedBytes keyCopied valueCopied≤reservedBytes := by
  cases keyCopied <;> cases valueCopied <;> decide +kernel

theorem output_bounded (keyCopied valueCopied : Bool) :
    (allocation workspace keyCopied valueCopied).keyChoice.destination+bytes≤workspace.cursor+reservedBytes ∧
    (allocation workspace keyCopied valueCopied).valueChoice.destination+bytes≤workspace.cursor+reservedBytes := by
  change (keyChoice workspace keyCopied).destination+bytes≤workspace.cursor+reservedBytes ∧
    (valueChoice workspace valueCopied).destination+bytes≤workspace.cursor+reservedBytes
  rw [key_destination,value_destination]
  cases keyCopied <;> cases valueCopied <;>
    simp only [Bool.false_eq_true,ite_false,ite_true,Nat.add_zero] <;>
    unfold reservedBytes bytes <;> omega

end Inference.State.KvInitialAllocation
