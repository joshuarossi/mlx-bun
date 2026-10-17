import kernels.quantization.AffineMemory

namespace Inference.Kernels.Quantization.MlxQmvMemory
open Contracts.Mlx
set_option maxRecDepth 10000
attribute [local irreducible] CopyContiguous.programs

theorem stores_inside {base groups : Nat} {values : Fin (4*groups) → BitVec 16}
    (aligned : base%2=0) (stores : List HalfMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ (CopyContiguous.programs base values).flatten) :
    MemoryRegions.Inside16 base (2*(4*groups)) stores := by
  intro store member
  obtain ⟨thread, offset, rfl⟩ := CopyContiguous.member base values store (subset store member)
  have := (CopyContiguous.index thread offset).isLt
  dsimp only [CopyContiguous.entry]
  omega

theorem trace_inside {base groups : Nat} {values : Fin (4*groups) → BitVec 16}
    (trace : CopyContiguous.Trace base values) : MemoryRegions.Inside16 base (2*(4*groups)) trace.schedule :=
  stores_inside trace.aligned trace.schedule (fun _ member =>
    (ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp member)

structure Execution (bits : MlxQmvDevice.Bits) (p : AffineRow.Platform) {steps : Nat}
    (input : Fin (steps*512) → ArrayStorage.BF) (buffers : AffineLoads.Buffers) (groups : Nat) where
  geometry : MlxQmvDevice.Geometry bits buffers steps (4*groups)
  source : ArrayStorage.BFBuffer input
  shared : AffineMemory.Shared buffers source.bytes
  base : Nat
  bounded : base+2*(4*groups) ≤ 2^64
  stores : CopyContiguous.Trace base (blocks := groups) (fun row => ArrayStorage.bits (MlxQmvDevice.produced bits p source buffers row))
  initial : stores.before=source.bytes
  inputSeparate : MemoryRegions.Disjoint base (2*(4*groups)) source.base (2*(steps*512))
  weightsSeparate : AffineMemory.Separate bits buffers steps (4*groups) base (2*(4*groups))

variable {bits : MlxQmvDevice.Bits} {p : AffineRow.Platform} {steps groups : Nat}
  {input : Fin (steps*512) → ArrayStorage.BF} {buffers : AffineLoads.Buffers}

def canonical (bits : MlxQmvDevice.Bits) (p : AffineRow.Platform) (input : Fin (steps*512) → ArrayStorage.BF)
    (buffers : AffineLoads.Buffers) (groups : Nat) (geometry : MlxQmvDevice.Geometry bits buffers steps (4*groups))
    (source : ArrayStorage.BFBuffer input) (shared : AffineMemory.Shared buffers source.bytes)
    (base : Nat) (aligned : base%2=0) (bounded : base+2*(4*groups) ≤ 2^64)
    (inputSeparate : MemoryRegions.Disjoint base (2*(4*groups)) source.base (2*(steps*512)))
    (weightsSeparate : AffineMemory.Separate bits buffers steps (4*groups) base (2*(4*groups))) :
    Execution bits p input buffers groups :=
  ⟨geometry, source, shared, base, bounded,
    CopyContiguous.Trace.canonical base _ source.bytes aligned, rfl, inputSeparate, weightsSeparate⟩

theorem Execution.input_stable (execution : Execution bits p input buffers groups)
    (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 execution.base (2*(4*groups)) stores)
    (offset : Nat) (bound : offset < 2*(steps*512)) :
    HalfMemory.execute stores execution.source.bytes (execution.source.base+offset)=execution.source.bytes (execution.source.base+offset) :=
  MemoryRegions.execute16_other stores execution.source.bytes inside execution.inputSeparate offset bound

def Execution.duringInput (execution : Execution bits p input buffers groups)
    (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 execution.base (2*(4*groups)) stores) : ArrayStorage.BFBuffer input :=
  ArrayFrame.bf execution.source (HalfMemory.execute stores execution.source.bytes) (execution.input_stable stores inside)

theorem Execution.duringWeights (execution : Execution bits p input buffers groups)
    (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 execution.base (2*(4*groups)) stores) :
    AffineMemory.Stable bits buffers steps (4*groups) (HalfMemory.execute stores execution.source.bytes) :=
  AffineMemory.stable_after execution.shared stores inside execution.weightsSeparate

-- Any subset of completed output stores leaves every remaining arithmetic
-- input unchanged. Loads may occur between stores from independent groups.
theorem Execution.partial_produced (execution : Execution bits p input buffers groups)
    (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 execution.base (2*(4*groups)) stores) (row : Fin (4*groups)) :
    MlxQmvDevice.produced bits p (execution.duringInput stores inside)
      (AffineMemory.reframe buffers (HalfMemory.execute stores execution.source.bytes)) row=
      MlxQmvDevice.produced bits p execution.source buffers row :=
  AffineMemory.produced_eq p execution.source (execution.input_stable stores inside) (execution.duringWeights stores inside) row

def Execution.buffer (execution : Execution bits p input buffers groups) :
    ArrayStorage.BFBuffer (MlxQmvDevice.produced bits p execution.source buffers (rows := 4*groups)) where
  bytes := execution.stores.memory
  base := execution.base
  aligned := execution.stores.aligned
  bounded := execution.bounded
  attached := execution.stores.read_correct

def Execution.output (execution : Execution bits p input buffers groups) : Fin (4*groups) → ArrayStorage.BF := execution.buffer.read

def Execution.outputBuffer (execution : Execution bits p input buffers groups) : ArrayStorage.BFBuffer execution.output :=
  ArrayViews.readback execution.buffer

theorem Execution.output3 (execution : Execution .three p input buffers groups) (row : Fin (4*groups)) :
    execution.output row=AffineRow.output p (AffineRow.tiles3 p input (AffineLoads.weights3 buffers row)) := by
  unfold Execution.output
  rw [ArrayStorage.BFBuffer.read_correct]
  unfold MlxQmvDevice.produced
  exact AffineLoads.forward3_input p input execution.source buffers row

theorem Execution.output4 (execution : Execution .four p input buffers groups) (row : Fin (4*groups)) :
    execution.output row=AffineRow.output p (AffineRow.tiles4 p input (AffineLoads.weights4 buffers row)) := by
  unfold Execution.output
  rw [ArrayStorage.BFBuffer.read_correct]
  unfold MlxQmvDevice.produced
  exact AffineLoads.forward4_input p input execution.source buffers row

theorem Execution.other_region (execution : Execution bits p input buffers groups) {base size : Nat}
    (separate : MemoryRegions.Disjoint execution.base (2*(4*groups)) base size) (offset : Nat) (bound : offset<size) :
    execution.stores.memory (base+offset)=execution.source.bytes (base+offset) :=
  (MemoryRegions.execute16_other execution.stores.schedule execution.stores.before (trace_inside execution.stores) separate offset bound).trans
    (congrFun execution.initial (base+offset))

theorem Execution.memory (execution : Execution bits p input buffers groups) :
    execution.stores.memory=HalfMemory.execute execution.stores.schedule execution.source.bytes := by
  unfold CopyContiguous.Trace.memory
  rw [execution.initial]

end Inference.Kernels.Quantization.MlxQmvMemory
