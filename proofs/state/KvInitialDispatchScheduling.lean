import contracts.mlx.CopyDispatchCommutation
import state.KvInitialPairMemory
import models.qwen.InitialKvSourceMemory
import kernels.copy.ScalarCopyQuadSemantics
import kernels.copy.VectorCopySemantics

namespace Inference.State.KvInitialDispatchScheduling
open Contracts.Mlx CopyExecution CopyDispatchCommutation KvSlicePreparationMemory
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2DMemory.programs

def scalarOps (source destination : Nat) (cells : List (Fin words)) : List Operation :=
  cells.map (fun i => ⟨source/2,destination/2+i.val⟩)

def vectorOps (source destination : Nat) (cells : List (Fin words)) : List Operation :=
  cells.map (fun i => ⟨source/2+i.val,destination/2+i.val⟩)

def rowOps (source : KvCopy.Source next) (destination : Nat) : List Operation :=
  (Copy2DMemory.programs (KvCopy.layout source destination 256 0) 4 256).flatten

theorem scalar_footprint (source destination : Nat) (cells : List (Fin words))
    (sourceAligned : source%2=0) (destinationAligned : destination%2=0) :
    Footprint (scalarOps source destination cells) source 2 destination bytes where
  reads := by
    intro op member
    obtain ⟨i,_,rfl⟩ := List.mem_map.mp member
    dsimp
    omega
  writes := by
    intro op member
    obtain ⟨i,_,rfl⟩ := List.mem_map.mp member
    have := i.isLt
    dsimp [words,bytes] at *
    omega

theorem vector_footprint (source destination : Nat) (cells : List (Fin words))
    (sourceAligned : source%2=0) (destinationAligned : destination%2=0) :
    Footprint (vectorOps source destination cells) source bytes destination bytes where
  reads := by
    intro op member
    obtain ⟨i,_,rfl⟩ := List.mem_map.mp member
    have := i.isLt
    dsimp [words,bytes] at *
    omega
  writes := by
    intro op member
    obtain ⟨i,_,rfl⟩ := List.mem_map.mp member
    have := i.isLt
    dsimp [words,bytes] at *
    omega

theorem row_footprint (source : KvCopy.Source next) (destination : Nat) (aligned : destination%2=0) :
    Footprint (rowOps source destination) source.base (KvAppendMemory.sourceBytes source) destination bytes where
  reads := by
    intro op member
    obtain ⟨label,rfl⟩ := Copy2DMemory.member _ op member
    have bound := KvAppendMemory.source_bounds source destination 256 0 label
    have even := Copy2DMemory.source_aligned (KvCopy.layout source destination 256 0) source.aligned label
    dsimp only [Copy2DMemory.operation]
    omega
  writes := by
    intro op member
    obtain ⟨label,rfl⟩ := Copy2DMemory.member _ op member
    have address := KvCopy.destination_word source destination 256 0 label
    have bound := Kv.address_bounds 256 label.1 0 label.2 (by decide)
    dsimp only [Copy2DMemory.operation]
    unfold bytes
    omega

theorem scalar_execute (source destination : Nat) (aligned : source%2=0)
    (cells : List (Fin words)) (memory : ByteMemory.Bytes) :
    execute (scalarOps source destination cells) memory=
      Kernels.Copy.ScalarCopyQuadSemantics.run source destination cells memory := by
  induction cells generalizing memory with
  | nil => rfl
  | cons i rest ih =>
      have address : 2*(source/2)=source := by omega
      simp only [scalarOps,List.map_cons,execute,Kernels.Copy.ScalarCopyQuadSemantics.run,
        Kernels.Copy.ScalarCopyQuadSemantics.event,HalfMemory.execute,address]
      exact ih _

theorem vector_execute (source destination : Nat) (aligned : source%2=0)
    (cells : List (Fin words)) (memory : ByteMemory.Bytes) :
    execute (vectorOps source destination cells) memory=
      Kernels.Copy.VectorCopySemantics.run source destination cells memory := by
  induction cells generalizing memory with
  | nil => rfl
  | cons i rest ih =>
      have address : 2*(source/2+i.val)=source+2*i.val := by omega
      simp only [vectorOps,List.map_cons,execute,Kernels.Copy.VectorCopySemantics.run,
        Kernels.Copy.VectorCopySemantics.event,HalfMemory.execute,address]
      exact ih _

-- Actual current-heap vector preservation followed by the strided key row
-- program; the donated branch has no preservation dispatch.
def preserveOps (choice : Choice slab) (cells : List (Fin words)) : List Operation :=
  match choice with
  | .donated _ _ => []
  | .copied destination _ _ _ => vectorOps slab destination cells

def keyOps (choice : Choice slab) (source : KvCopy.Source key) (cells : List (Fin words)) : List Operation :=
  preserveOps choice cells ++ rowOps source choice.destination

def nativeCells : List (Fin words) :=
  Kernels.Copy.VectorCopySemantics.indices (List.finRange Kernels.Copy.VectorCopySemantics.threadCount)

theorem native_scalar_cells : nativeCells=Kernels.Copy.ScalarCopyQuadSemantics.indices
    (List.finRange Kernels.Copy.ScalarCopyQuadSemantics.threadCount) := rfl

theorem preparation_memory (slab : Nat) (slabAligned : slab%2=0) (slabBounded : slab+bytes≤2^64) (choice : Choice slab)
    (before : ByteMemory.Bytes) :
    (choice.prepare before).memory=execute (preserveOps choice nativeCells) before := by
  cases choice with
  | donated aligned bounded => rfl
  | copied destination aligned bounded fresh =>
      let a : Kernels.Copy.VectorCopySemantics.Allocation slab destination :=
        ⟨slabAligned,slabBounded,aligned,bounded,fresh⟩
      have same := Kernels.Copy.VectorCopySemantics.threads_refine a
        (List.finRange Kernels.Copy.VectorCopySemantics.threadCount) (List.Perm.refl _) before
      simp only [preserveOps]
      rw [vector_execute slab destination slabAligned]
      exact same.symm

theorem preservation_memory (layout : KvRegions.Layout 1) (choice : Choice layout.keyBase)
    (before : ByteMemory.Bytes) :
    (choice.prepare before).memory=execute (preserveOps choice nativeCells) before :=
  preparation_memory layout.keyBase layout.keyAligned layout.keyBound choice before

theorem slice_memory (slice : KvInitialPairMemory.Slice old next before slab) :
    slice.memory=execute (rowOps slice.source slice.choice.destination) slice.preservation.memory := by
  rfl

theorem key_slice_memory (layout : KvRegions.Layout 1)
    (slice : KvInitialPairMemory.Slice old next before layout.keyBase) :
    slice.memory=execute (keyOps slice.choice slice.source nativeCells) before := by
  rw [slice_memory,show slice.preservation.memory=(slice.choice.prepare before).memory from rfl,
    preservation_memory layout slice.choice before]
  exact (execute_append _ _ before).symm

variable {layout : KvRegions.Layout 1} {keySource : KvCopy.Source key} {valueSource : KvCopy.Source value}
    (allocation : KvInitialPairMemory.Allocation layout keySource valueSource)
    (scalar : Nat) (scalarAligned : scalar%2=0)
    (keepsScalar : MemoryRegions.Disjoint allocation.keyChoice.destination bytes scalar 2)

include scalarAligned keepsScalar

theorem zero_preservation_independent (zeroCells keyCells : List (Fin words)) :
    Independent (scalarOps scalar layout.valueBase zeroCells) (preserveOps allocation.keyChoice keyCells) := by
  cases choiceEq : allocation.keyChoice with
  | donated aligned bounded =>
      intro a ha b hb
      simp only [preserveOps,List.not_mem_nil] at hb
  | copied destination aligned bounded fresh =>
      have destinationEq : allocation.keyChoice.destination=destination := by rw [choiceEq]; rfl
      have keepsValues := allocation.keyKeepsZeroValues
      rw [destinationEq] at keepsValues keepsScalar
      exact footprints_independent
        (scalar_footprint scalar layout.valueBase zeroCells scalarAligned layout.valueAligned)
        (vector_footprint layout.keyBase destination keyCells layout.keyAligned aligned)
        (MemoryRegions.disjoint_symm keepsValues) (MemoryRegions.disjoint_symm keepsScalar)
        layout.separate

theorem zero_row_independent (zeroCells : List (Fin words)) :
    Independent (scalarOps scalar layout.valueBase zeroCells) (rowOps keySource allocation.keyChoice.destination) :=
  footprints_independent
    (scalar_footprint scalar layout.valueBase zeroCells scalarAligned layout.valueAligned)
    (row_footprint keySource allocation.keyChoice.destination allocation.keyChoice.aligned)
    (MemoryRegions.disjoint_symm allocation.keyKeepsZeroValues)
    (MemoryRegions.disjoint_symm keepsScalar)
    (MemoryRegions.disjoint_symm allocation.keyZerosSafe.values)

theorem zero_key_independent (zeroCells keyCells : List (Fin words)) :
    Independent (scalarOps scalar layout.valueBase zeroCells) (keyOps allocation.keyChoice keySource keyCells) :=
  independent_append _ _ _ (zero_preservation_independent allocation scalar scalarAligned keepsScalar _ _)
    (zero_row_independent allocation scalar scalarAligned keepsScalar _)

omit scalarAligned keepsScalar in
theorem key_writes (keyCells : List (Fin words)) :
    ∀ op∈keyOps allocation.keyChoice keySource keyCells,
      allocation.keyChoice.destination≤2*op.destination ∧
      2*op.destination+2≤allocation.keyChoice.destination+bytes := by
  intro op member
  rcases List.mem_append.mp member with hp|hr
  · cases choiceEq : allocation.keyChoice with
    | donated aligned bounded => simp only [preserveOps,choiceEq,List.not_mem_nil] at hp
    | copied destination aligned bounded fresh =>
        have footprint := vector_footprint layout.keyBase destination keyCells layout.keyAligned aligned
        exact footprint.writes op (by simpa only [preserveOps,choiceEq] using hp)
  · exact (row_footprint keySource _ allocation.keyChoice.aligned).writes op hr

omit scalarAligned in
theorem key_scalar_retained (keyCells : List (Fin words)) (before : ByteMemory.Bytes) :
    HalfMemory.load (execute (keyOps allocation.keyChoice keySource keyCells) before) scalar=
      HalfMemory.load before scalar := by
  exact ArrayFrame.half_congr before _ scalar 2 0
    (execute_frame _ (key_writes allocation keyCells) keepsScalar before) (by decide)

-- V-zero before K-preserve/K-row and V-zero after those completed dispatches
-- yield exactly the same bytes. This applies to ANY cell ordering, hence in
-- particular each native completed dispatch, without a final-heap premise.
theorem zero_key_commute (zeroCells keyCells : List (Fin words)) (before : ByteMemory.Bytes) :
    execute (keyOps allocation.keyChoice keySource keyCells)
      (Kernels.Copy.ScalarCopyQuadSemantics.run scalar layout.valueBase zeroCells before)=
    Kernels.Copy.ScalarCopyQuadSemantics.run scalar layout.valueBase zeroCells
      (execute (keyOps allocation.keyChoice keySource keyCells) before) := by
  rw [← scalar_execute scalar _ scalarAligned,← scalar_execute scalar _ scalarAligned]
  exact execute_commute _ _ (zero_key_independent allocation scalar scalarAligned keepsScalar _ _) before

-- Identical subsequent V preservation/update dispatches preserve this exact
-- equality by function congruence. This does not identify the native scheduler.
theorem followed_by (zeroCells keyCells : List (Fin words)) (suffix : List Operation) (before : ByteMemory.Bytes) :
    execute suffix (execute (keyOps allocation.keyChoice keySource keyCells)
      (Kernels.Copy.ScalarCopyQuadSemantics.run scalar layout.valueBase zeroCells before))=
    execute suffix (Kernels.Copy.ScalarCopyQuadSemantics.run scalar layout.valueBase zeroCells
      (execute (keyOps allocation.keyChoice keySource keyCells) before)) :=
  congrArg (execute suffix) (zero_key_commute allocation scalar scalarAligned keepsScalar _ _ before)

-- Generic pair order comparison, with K-zero as the common prefix and the
-- same actual V preservation/row dispatches after the swap. Scalar payloads
-- are read dynamically; existing source attachments prove they are zero.
theorem two_orders (keyScalar : Nat) (before : ByteMemory.Bytes) :
    let start := Kernels.Copy.ScalarCopyQuadSemantics.run keyScalar layout.keyBase nativeCells before
    let k := keyOps allocation.keyChoice keySource nativeCells
    let v := keyOps allocation.valueChoice valueSource nativeCells
    execute v (execute k (Kernels.Copy.ScalarCopyQuadSemantics.run scalar layout.valueBase nativeCells start))=
      execute v (Kernels.Copy.ScalarCopyQuadSemantics.run scalar layout.valueBase nativeCells (execute k start)) :=
  followed_by allocation scalar scalarAligned keepsScalar nativeCells nativeCells _ _

-- Exact existing shared-heap Pair execution in the same current-read operation
-- language. Parameter/source attachments are transported by the old constructor.
omit scalarAligned keepsScalar in
theorem pair_memory_ops (zeros : KvInitialPairMemory.ZeroPair layout before)
    (keyShared : keySource.bytes=before) (valueShared : valueSource.bytes=before)
    (cache : Kv.Cache KvBytes.BF 0) :
    KvInitialPairMemory.memory (cache:=cache) zeros allocation keyShared valueShared=
      execute (keyOps allocation.valueChoice valueSource nativeCells)
        (execute (keyOps allocation.keyChoice keySource nativeCells) zeros.memory) := by
  have valuesEq := slice_memory (KvInitialPairMemory.values (cache:=cache) zeros allocation keyShared valueShared)
  have prepareEq := preparation_memory layout.valueBase layout.valueAligned layout.valueBound
    allocation.valueChoice (KvInitialPairMemory.keys (cache:=cache) zeros allocation keyShared).memory
  change _=execute (keyOps allocation.valueChoice valueSource nativeCells) _
  rw [show KvInitialPairMemory.memory (cache:=cache) zeros allocation keyShared valueShared=
    (KvInitialPairMemory.values (cache:=cache) zeros allocation keyShared valueShared).memory from rfl,valuesEq]
  change execute (rowOps valueSource allocation.valueChoice.destination)
    (allocation.valueChoice.prepare _).memory=_
  rw [prepareEq,← execute_append]
  change execute (keyOps allocation.valueChoice valueSource nativeCells) _=_
  exact congrArg (execute (keyOps allocation.valueChoice valueSource nativeCells))
    (key_slice_memory layout (KvInitialPairMemory.keys (cache:=cache) zeros allocation keyShared))

omit scalarAligned keepsScalar in
def delayedScalar (zeros : KvInitialPairMemory.ZeroPair layout before)
    (sources : Models.Qwen.InitialKvSourceMemory.Sources zeros)
    (keepsValueScalar : MemoryRegions.Disjoint allocation.keyChoice.destination bytes sources.valueScalar.base 2) :
    ArrayStorage.BFBuffer Kernels.Copy.ScalarCopyQuadSourceRefinement.zeroValues :=
  ArrayFrame.bf sources.valueAfter
    (execute (keyOps allocation.keyChoice keySource nativeCells) zeros.keys.memory)
    (execute_frame _ (key_writes allocation nativeCells) keepsValueScalar zeros.keys.memory)

omit scalarAligned keepsScalar in
theorem delayedScalar_heap (zeros : KvInitialPairMemory.ZeroPair layout before)
    (sources : Models.Qwen.InitialKvSourceMemory.Sources zeros)
    (keepsValueScalar : MemoryRegions.Disjoint allocation.keyChoice.destination bytes sources.valueScalar.base 2) :
    (delayedScalar allocation zeros sources keepsValueScalar).bytes=
      execute (keyOps allocation.keyChoice keySource nativeCells) zeros.keys.memory := rfl

omit scalarAligned keepsScalar in
theorem delayedScalar_base (zeros : KvInitialPairMemory.ZeroPair layout before)
    (sources : Models.Qwen.InitialKvSourceMemory.Sources zeros)
    (keepsValueScalar : MemoryRegions.Disjoint allocation.keyChoice.destination bytes sources.valueScalar.base 2) :
    (delayedScalar allocation zeros sources keepsValueScalar).base=sources.valueScalar.base := rfl

omit scalarAligned keepsScalar in
def delayedChecked (zeros : KvInitialPairMemory.ZeroPair layout before)
    (sources : Models.Qwen.InitialKvSourceMemory.Sources zeros)
    (keepsValueScalar : MemoryRegions.Disjoint allocation.keyChoice.destination bytes sources.valueScalar.base 2) :
    Kernels.Copy.ScalarCopyQuadSourceRefinement.Checked
      (delayedScalar allocation zeros sources keepsValueScalar) layout.valueBase sources.valueAllocation :=
  Kernels.Copy.ScalarCopyQuadSourceRefinement.canonical _ _ _

omit scalarAligned keepsScalar in
theorem pair_reordered (zeros : KvInitialPairMemory.ZeroPair layout before)
    (sources : Models.Qwen.InitialKvSourceMemory.Sources zeros)
    (keepsValueScalar : MemoryRegions.Disjoint allocation.keyChoice.destination bytes sources.valueScalar.base 2)
    (keyShared : keySource.bytes=before) (valueShared : valueSource.bytes=before)
    (cache : Kv.Cache KvBytes.BF 0) :
    KvInitialPairMemory.memory (cache:=cache) zeros allocation keyShared valueShared=
      execute (keyOps allocation.valueChoice valueSource nativeCells)
        (Kernels.Copy.ScalarCopyQuadSemantics.run sources.valueScalar.base layout.valueBase nativeCells
          (execute (keyOps allocation.keyChoice keySource nativeCells) zeros.keys.memory)) := by
  rw [pair_memory_ops allocation zeros keyShared valueShared cache]
  have valuesEq : Kernels.Copy.ScalarCopyQuadSemantics.run sources.valueScalar.base layout.valueBase nativeCells
      zeros.keys.memory=zeros.memory := sources.value_body_heap
  rw [← valuesEq]
  exact followed_by allocation sources.valueScalar.base sources.valueScalar.aligned keepsValueScalar
    nativeCells nativeCells _ zeros.keys.memory

omit scalarAligned keepsScalar in
theorem pair_reordered_checked (zeros : KvInitialPairMemory.ZeroPair layout before)
    (sources : Models.Qwen.InitialKvSourceMemory.Sources zeros)
    (keepsValueScalar : MemoryRegions.Disjoint allocation.keyChoice.destination bytes sources.valueScalar.base 2)
    (keyShared : keySource.bytes=before) (valueShared : valueSource.bytes=before)
    (cache : Kv.Cache KvBytes.BF 0) :
    KvInitialPairMemory.memory (cache:=cache) zeros allocation keyShared valueShared=
      execute (keyOps allocation.valueChoice valueSource nativeCells)
        (delayedChecked allocation zeros sources keepsValueScalar).bodyAfter :=
  pair_reordered allocation zeros sources keepsValueScalar keyShared valueShared cache

end Inference.State.KvInitialDispatchScheduling
