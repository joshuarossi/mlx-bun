import kernels.quantization.AffineOutputSource
namespace Inference.Kernels.Quantization.AffineOutput3Source
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open AffineOutputSource (values programs source_programs)
set_option maxRecDepth 10000
attribute [local irreducible] CopyContiguous.programs

variable {p : AffineRow.Platform} {input : Fin (steps*512) → ArrayStorage.BF} {buffers : AffineLoads.Buffers}
  (projection : MlxQmvMemory.Execution .three p input buffers groups)

def originalRegisters (row : Fin (4*groups)) : Fin 32 → Float32 :=
  AffineRow.laneValue (AffineRow.tiles3 p input (AffineLoads.weights3 buffers row))

theorem original_values : values p (originalRegisters (groups:=groups) (p:=p) (input:=input) (buffers:=buffers))=
    fun row => ArrayStorage.bits (MlxQmvDevice.produced .three p projection.source buffers row) := by
  funext row
  apply congrArg ArrayStorage.bits
  change AffineRow.output p (AffineRow.tiles3 p input (AffineLoads.weights3 buffers row))=MlxQmvDevice.produced .three p projection.source buffers row
  unfold MlxQmvDevice.produced
  exact (AffineLoads.forward3_input p input projection.source buffers row).symm

theorem selected_programs (limit : groups≤62080) :
    programs p (originalRegisters (groups:=groups) (p:=p) (input:=input) (buffers:=buffers)) projection.base=
      some (CopyContiguous.programs (blocks:=groups) projection.base
        (fun row => ArrayStorage.bits (MlxQmvDevice.produced .three p projection.source buffers row))) := by
  rw [source_programs p _ _ limit,original_values projection]

structure Certificate : Prop where
  sourcePrograms : programs p (originalRegisters (groups:=groups) (p:=p) (input:=input) (buffers:=buffers)) projection.base=
      some (CopyContiguous.programs (blocks:=groups) projection.base
        (fun row => ArrayStorage.bits (MlxQmvDevice.produced .three p projection.source buffers row)))
  execution : ∃ writes, programs p (originalRegisters (groups:=groups) (p:=p) (input:=input) (buffers:=buffers)) projection.base=some writes ∧
    ThreadgroupWrites.Executes writes projection.stores.schedule projection.stores.remaining
  completed : ThreadgroupWrites.AtBarrier projection.stores.remaining
  storeBounds : ∀ row : Fin (4*groups), (projection.base+2*row.val)%2=0 ∧ projection.base+2*row.val+2≤2^64
  sameHeap : projection.stores.memory=HalfMemory.execute projection.stores.schedule projection.source.bytes
  readback : ∀ row : Fin (4*groups), HalfMemory.load projection.stores.memory (projection.base+2*row.val)=
    ArrayStorage.bits (AffineRow.output p (AffineRow.tiles3 p input (AffineLoads.weights3 buffers row)))

theorem checked_output (limit : groups≤62080) : Certificate projection := by
  refine ⟨selected_programs projection limit,⟨_,selected_programs projection limit,projection.stores.execution⟩,
    projection.stores.completed,projection.stores.read_bounds projection.bounded,projection.memory,?_⟩
  intro row
  rw [projection.stores.read_correct]
  apply congrArg ArrayStorage.bits
  unfold MlxQmvDevice.produced
  exact AffineLoads.forward3_input p input projection.source buffers row

theorem separated_writers (limit : groups≤62080) :
    ∃ writes, programs p (originalRegisters (groups:=groups) (p:=p) (input:=input) (buffers:=buffers)) projection.base=some writes ∧
      WriteOwnership.Separated MemoryCells.Store.word writes := by
  exact ⟨_,selected_programs projection limit,CopyContiguous.separated _ _⟩

theorem outside (separate : MemoryRegions.Disjoint projection.base (2*(4*groups)) base size)
    (offset : Nat) (bound : offset<size) : projection.stores.memory (base+offset)=projection.source.bytes (base+offset) :=
  projection.other_region separate offset bound

end Inference.Kernels.Quantization.AffineOutput3Source
