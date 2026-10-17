import kernels.RmsHeadsMemory

namespace Inference.Kernels.RmsHeadsFreshMemory
open Contracts.Mlx
set_option maxRecDepth 10000
attribute [local irreducible] RmsHeadsMemory.sourceValues RmsHeadsMemory.produced RmsScratch.Trace.factor
  MultiOutputWrites.programs ReadBeforeOverwrite.allReaders ReadBeforeOverwrite.captureMany

variable {heads base : Nat} {values : Fin heads → Fin 256 → ArrayStorage.BF} {weight : Fin 256 → ArrayStorage.BF}

-- Fresh output reads the original contiguous rows and writes a distinct
-- allocation. Global output schedules cannot overwrite any operand read.
structure Execution (input : RmsHeadsMemory.Input values weight base) (p : RmsNorm.Platform) (width eps : Float32) where
  dispatch : p.groups=2
  destination : Nat
  geometry : RmsHeadStores.Geometry heads destination
  scratch : ∀ head, RmsScratch.Trace p (RmsHeadsMemory.sourceValues input head)
  inverse : ∀ head, FloatArrayWrites.Trace 0 (fun _ : Fin 1 => (scratch head).factor width eps)
  factor : Fin heads → Float32
  factorRead : ∀ head, factor head=(inverse head).buffer.read 0
  reads : RmsHeadReads.Trace heads base
  initial : reads.before=input.source.memory
  stores : RmsHeadStores.Trace geometry (RmsHeadsMemory.produced input factor)
  storeInitial : stores.before=input.source.memory
  sourceSeparate : MemoryRegions.Disjoint destination (512*heads) base (512*heads)
  weightSeparate : MemoryRegions.Disjoint destination (512*heads) input.weight.base 512

variable {input : RmsHeadsMemory.Input values weight base} {p : RmsNorm.Platform} {width eps : Float32}

def fromScratch (input : RmsHeadsMemory.Input values weight base) (p : RmsNorm.Platform) (width eps : Float32)
    (dispatch : p.groups=2) (destination : Nat) (geometry : RmsHeadStores.Geometry heads destination)
    (scratch : ∀ head, RmsScratch.Trace p (RmsHeadsMemory.sourceValues input head))
    (inverse : ∀ head, FloatArrayWrites.Trace 0 (fun _ : Fin 1 => (scratch head).factor width eps))
    (sourceSeparate : MemoryRegions.Disjoint destination (512*heads) base (512*heads))
    (weightSeparate : MemoryRegions.Disjoint destination (512*heads) input.weight.base 512) : Execution input p width eps :=
  let factor := fun head => (inverse head).buffer.read 0
  ⟨dispatch,destination,geometry,scratch,inverse,factor,fun _ => rfl,
    RmsHeadReads.Trace.canonical heads base input.source.memory,rfl,
    MultiOutputWrites.canonical (geometry.layout (RmsHeadsMemory.produced input factor)) input.source.memory,rfl,
    sourceSeparate,weightSeparate⟩

def canonical (input : RmsHeadsMemory.Input values weight base) (p : RmsNorm.Platform) (width eps : Float32)
    (dispatch : p.groups=2) (destination : Nat) (geometry : RmsHeadStores.Geometry heads destination)
    (sourceSeparate : MemoryRegions.Disjoint destination (512*heads) base (512*heads))
    (weightSeparate : MemoryRegions.Disjoint destination (512*heads) input.weight.base 512) : Execution input p width eps :=
  let scratch := fun head => RmsScratch.Trace.canonical p (RmsHeadsMemory.sourceValues input head)
  fromScratch input p width eps dispatch destination geometry scratch
    (fun head => FloatArrayWrites.Trace.canonical (fun _ : Fin 1 => (scratch head).factor width eps) (by decide))
    sourceSeparate weightSeparate

theorem Execution.captured_input (execution : Execution input p width eps) : execution.reads.capturedRows=values :=
  execution.reads.rows_eq input.source execution.initial

theorem Execution.factor_eq (execution : Execution input p width eps) (head : Fin heads) (before : M1Max.WordMemory) (scratchBase : Nat) :
    execution.factor head=RmsNorm.inverse p (fun i => BFloat16.widen (values head i)) width eps before scratchBase := by
  rw [execution.factorRead, ArrayStorage.FloatBuffer.read_correct, (execution.scratch head).factor_eq width eps before scratchBase,
    RmsHeadsMemory.sourceValues_eq]

theorem Execution.produced_eq (execution : Execution input p width eps) (head : Fin heads) (before : M1Max.WordMemory) (scratchBase : Nat) :
    RmsHeadsMemory.produced input execution.factor head=
      RmsNorm.value p (fun i => BFloat16.widen (values head i)) weight width eps before scratchBase := by
  funext i
  unfold RmsHeadsMemory.produced
  rw [ArrayStorage.BFBuffer.read_correct,ArrayStorage.BFBuffer.read_correct,execution.factor_eq head before scratchBase]
  unfold RmsNormMemory.operation
  rfl

def Execution.buffer (execution : Execution input p width eps) (head : Fin heads) :
    ArrayStorage.BFBuffer (RmsHeadsMemory.produced input execution.factor head) := RmsHeadStores.buffer execution.stores head

def Execution.output (execution : Execution input p width eps) (head : Fin heads) : Fin 256 → ArrayStorage.BF :=
  (execution.buffer head).read

theorem Execution.output_eq (execution : Execution input p width eps) (head : Fin heads) (before : M1Max.WordMemory) (scratchBase : Nat) :
    execution.output head=RmsNorm.value p (fun i => BFloat16.widen (values head i)) weight width eps before scratchBase :=
  (funext (execution.buffer head).read_correct).trans (execution.produced_eq head before scratchBase)

def Execution.forwardBuffer (execution : Execution input p width eps) (head : Fin heads) (before : M1Max.WordMemory) (scratchBase : Nat) :
    ArrayStorage.BFBuffer (RmsNorm.value p (fun i => BFloat16.widen (values head i)) weight width eps before scratchBase) :=
  ArrayViews.reindex (execution.produced_eq head before scratchBase) (execution.buffer head)

theorem Execution.other_region (execution : Execution input p width eps) {region size : Nat}
    (separate : MemoryRegions.Disjoint execution.destination (512*heads) region size) (offset : Nat) (bound : offset<size) :
    execution.stores.memory (region+offset)=input.source.memory (region+offset) :=
  (RmsHeadStores.other_region execution.stores separate offset bound).trans (congrFun execution.storeInitial _)

-- These bounds apply to arbitrary partial or interleaved output schedules.
theorem Execution.stores_inside (execution : Execution input p width eps) (stores : List HalfMemory.Store)
    (members : ∀ store ∈ stores, store ∈ execution.stores.schedule) :
    MemoryRegions.Inside16 execution.destination (512*heads) stores := by
  intro store member
  obtain ⟨head,i,address⟩ := RmsHeadStores.store_coordinate execution.stores store (members store member)
  have aligned := execution.geometry.aligned
  have h := head.isLt
  have coordinate := i.isLt
  rw [address]
  omega

theorem Execution.partial_frame (execution : Execution input p width eps) (stores : List HalfMemory.Store)
    (members : ∀ store ∈ stores, store ∈ execution.stores.schedule) {region size : Nat}
    (separate : MemoryRegions.Disjoint execution.destination (512*heads) region size) (offset : Nat) (bound : offset<size) :
    HalfMemory.execute stores input.source.memory (region+offset)=input.source.memory (region+offset) :=
  MemoryRegions.execute16_other stores input.source.memory (execution.stores_inside stores members) separate offset bound

def Execution.duringRows (execution : Execution input p width eps) (stores : List HalfMemory.Store)
    (members : ∀ store ∈ stores, store ∈ execution.stores.schedule) : RmsHeadReads.Input values base where
  memory := HalfMemory.execute stores input.source.memory
  rows := fun head => ArrayFrame.bf (input.source.rows head) _ (by
    intro offset bound
    have region : MemoryRegions.Disjoint execution.destination (512*heads) (input.source.rows head).base 512 := by
      rw [input.source.addresses head]
      have safe := execution.sourceSeparate
      have h := head.isLt
      dsimp only [RmsHeadReads.layout]
      unfold MemoryRegions.Disjoint at safe ⊢
      omega
    exact (execution.partial_frame stores members region offset bound).trans (congrFun (input.source.shared head) _).symm)
  shared := fun _ => rfl
  addresses := input.source.addresses

def Execution.duringWeight (execution : Execution input p width eps) (stores : List HalfMemory.Store)
    (members : ∀ store ∈ stores, store ∈ execution.stores.schedule) : ArrayStorage.BFBuffer weight :=
  ArrayFrame.bf input.weight (HalfMemory.execute stores input.source.memory)
    (fun offset bound => (execution.partial_frame stores members execution.weightSeparate offset bound).trans (congrFun input.shared _).symm)

theorem Execution.read_during (execution : Execution input p width eps) (stores : List HalfMemory.Store)
    (members : ∀ store ∈ stores, store ∈ execution.stores.schedule) (head : Fin heads) (thread : Fin 64) (offset : Fin 4) :
    RmsHeadReads.read base (HalfMemory.execute stores input.source.memory) head thread offset=
      ArrayStorage.bits (values head (RmsHeadReads.coordinate thread offset)) :=
  (execution.duringRows stores members).read_correct head thread offset

def Execution.weightsAfter (execution : Execution input p width eps) : ArrayStorage.BFBuffer weight :=
  ArrayFrame.bf input.weight execution.stores.memory
    (fun offset bound => (execution.other_region execution.weightSeparate offset bound).trans (congrFun input.shared _).symm)

end Inference.Kernels.RmsHeadsFreshMemory
