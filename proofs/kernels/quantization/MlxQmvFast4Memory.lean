import kernels.quantization.MlxQmvFast4Pointers
namespace Inference.Kernels.Quantization.MlxQmvFast4Memory
open Contracts.Mlx
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] MlxQmvFast4LoopSource.sourceLoop AffineRow.tiles4
  AffineOutputSource.originalRegisters

def SourceStep (p : AffineRow.Platform) (input : Fin (steps*512)→ArrayStorage.BF)
    (buffers : AffineLoads.Buffers) (projection : MlxQmvMemory.Execution .four p input buffers groups)
    (stores : List HalfMemory.Store) (before : Nat→Float32) (group : Fin groups) (lane : Fin 32)
    (step : Fin steps) (call : Fin 4→Option Float32) : Prop :=
  ∃ cells sum,
    MlxQmvFast4Syntax.parseLoad MlxQmvFast4Syntax.loadSource=some () ∧
    MlxQmvFast4Pointers.parsePointers MlxQmvFast4Pointers.pointersSource=some () ∧
    MlxQmvFast4Pointers.parseUpdates MlxQmvFast4Pointers.updatesSource=some () ∧
    MlxQmvInput4Source.execute p.tile.divide (HalfMemory.execute stores projection.source.bytes)
      (projection.source.base+2*(MlxQmvFast4Pointers.inputOffset step.val lane.val)) before=some (sum,cells) ∧
    ∀ row,∃ value,call row=some value ∧
      MlxQmvFast4Syntax.parseCall MlxQmvFast4Syntax.callSource=some () ∧
      MlxQmvFast4Pointers.parseReads MlxQmvFast4Pointers.readsSource=some () ∧
      MlxQmvDot4FunctionSource.Execution p.tile.contracted p.tile.tailContracted
        (MlxQmvFast4Pointers.memory (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
          group row step lane cells)
        (BFloat16.widen (MlxQmvFast4Pointers.scale (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes)) group row step lane)) sum
        (BFloat16.widen (MlxQmvFast4Pointers.bias (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes)) group row step lane)) value

theorem source_step (p : AffineRow.Platform) (input : Fin (steps*512)→ArrayStorage.BF)
    (buffers : AffineLoads.Buffers) (projection : MlxQmvMemory.Execution .four p input buffers groups)
    (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 projection.base (2*(4*groups)) stores)
    (before : Nat→Float32) (group : Fin groups) (lane : Fin 32) (step : Fin steps)
    (finite : ∀ row : Fin (4*groups), AffineTile.Finite4 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights4 buffers row).words step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))) :
    SourceStep p input buffers projection stores before group lane step
      (fun row=>some (AffineRow.tiles4 p input (AffineLoads.weights4 buffers (CopyContiguous.index group row)) step lane)) := by
  let source := AffineDot4PreparedMemory.inputSlice (projection.duringInput stores inside) step lane
  obtain ⟨cells,load,prepared⟩ := MlxQmvInput4Source.execution p.tile source before
  refine ⟨cells,AffineInput.summed (AffineRow.slice input step lane) AffineInput.groups4,
    MlxQmvFast4Syntax.parsed_load,MlxQmvFast4Pointers.parsed_pointers,MlxQmvFast4Pointers.parsed_updates,?_,?_⟩
  · rw [MlxQmvFast4Pointers.input_eq]
    exact load
  · intro row
    refine ⟨_,rfl,MlxQmvFast4Syntax.parsed_call,MlxQmvFast4Pointers.parsed_reads,?_⟩
    rw [MlxQmvFast4Pointers.memory_eq,MlxQmvFast4Pointers.scale_eq,MlxQmvFast4Pointers.bias_eq]
    apply MlxQmvDot4TileMemory.during_output p input buffers projection stores inside
      (CopyContiguous.index group row) step lane cells 0 _ (finite _)
    intro i j
    simpa only [MlxQmvDot4Source.input,MlxQmvDot4TileMemory.view,Nat.zero_add] using prepared i j

variable {p : AffineRow.Platform} {input : Fin (steps*512)→ArrayStorage.BF} {buffers : AffineLoads.Buffers}
    (projection : MlxQmvMemory.Execution .four p input buffers groups)
    (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 projection.base (2*(4*groups)) stores)
    (before : Nat→Float32)

include inside in
theorem source_registers
    (finite : ∀ (row : Fin (4*groups)) step lane, AffineTile.Finite4 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights4 buffers row).words step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))) (group : Fin groups) (lane : Fin 32) :
    ∃ call : Fin steps→Fin 4→Option Float32,
      (∀ step,SourceStep p input buffers projection stores before group lane step (call step)) ∧
      MlxQmvFast4LoopSource.sourceLoop call=some (fun row=>AffineOutputSource.originalRegisters
        (p:=p) (input:=input) (buffers:=buffers) (CopyContiguous.index group row) lane) := by
  let call := fun (step : Fin steps) (row : Fin 4)=>some
    (AffineRow.tiles4 p input (AffineLoads.weights4 buffers (CopyContiguous.index group row)) step lane)
  refine ⟨call,fun step=>source_step p input buffers projection stores inside before group lane step
    (fun row=>finite row step lane),?_⟩
  have run := MlxQmvFast4LoopSource.source_loop call
    (fun step row=>AffineRow.tiles4 p input (AffineLoads.weights4 buffers (CopyContiguous.index group row)) step lane)
    (fun _ _=>rfl)
  have target : (fun row=>AffineRow.laneValue
      (fun step (_ : Fin 32)=>AffineRow.tiles4 p input (AffineLoads.weights4 buffers (CopyContiguous.index group row)) step lane) 0)=
      (fun row=>AffineOutputSource.originalRegisters (p:=p) (input:=input) (buffers:=buffers)
        (CopyContiguous.index group row) lane) := by
    funext row
    simp only [AffineOutputSource.originalRegisters,AffineRow.laneValue]
  exact run.trans (congrArg some target)

structure Certificate : Prop where
  constants : MlxQmvFast4Syntax.sourceConfig=some [2,2,4,8,4,16,512,4]
  registers : ∀ group lane,∃ call : Fin steps→Fin 4→Option Float32,
    (∀ step,SourceStep p input buffers projection stores before group lane step (call step)) ∧
    MlxQmvFast4LoopSource.sourceLoop call=some (fun row=>AffineOutputSource.originalRegisters
      (p:=p) (input:=input) (buffers:=buffers) (CopyContiguous.index group row) lane)
  sourcePrograms : MlxQmvFast4Output.programs p
    (AffineOutputSource.originalRegisters (groups:=groups) (p:=p) (input:=input) (buffers:=buffers)) projection.base=
    some (CopyContiguous.programs (blocks:=groups) projection.base
      (fun row=>ArrayStorage.bits (MlxQmvDevice.produced .four p projection.source buffers row)))
  execution : ∃ writes,MlxQmvFast4Output.programs p
    (AffineOutputSource.originalRegisters (groups:=groups) (p:=p) (input:=input) (buffers:=buffers)) projection.base=some writes ∧
    ThreadgroupWrites.Executes writes projection.stores.schedule projection.stores.remaining
  completed : ThreadgroupWrites.AtBarrier projection.stores.remaining
  sameHeap : projection.stores.memory=HalfMemory.execute projection.stores.schedule projection.source.bytes
  readback : ∀ row : Fin (4*groups),HalfMemory.load projection.stores.memory (projection.base+2*row.val)=
    ArrayStorage.bits (AffineRow.output p (AffineRow.tiles4 p input (AffineLoads.weights4 buffers row)))

include inside in
theorem checked (limit : groups≤62080)
    (finite : ∀ (row : Fin (4*groups)) step lane, AffineTile.Finite4 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights4 buffers row).words step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))) : Certificate projection stores before := by
  have sourcePrograms : MlxQmvFast4Output.programs p
      (AffineOutputSource.originalRegisters (groups:=groups) (p:=p) (input:=input) (buffers:=buffers)) projection.base=
      some (CopyContiguous.programs (blocks:=groups) projection.base
        (fun row=>ArrayStorage.bits (MlxQmvDevice.produced .four p projection.source buffers row))) := by
    rw [MlxQmvFast4Output.source_programs p _ _ limit,AffineOutputSource.original_values projection]
  refine ⟨MlxQmvFast4Syntax.source_config,source_registers projection stores inside before finite,sourcePrograms,
    ⟨_,sourcePrograms,projection.stores.execution⟩,projection.stores.completed,projection.memory,?_⟩
  intro row
  rw [projection.stores.read_correct]
  apply congrArg ArrayStorage.bits
  unfold MlxQmvDevice.produced
  exact AffineLoads.forward4_input p input projection.source buffers row

-- The original initial heap serves all later protected store prefixes. Each
-- native invocation has private input cells, not a new global/shared oracle.
theorem all_prefixes (limit : groups≤62080)
    (finite : ∀ (row : Fin (4*groups)) step lane, AffineTile.Finite4 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights4 buffers row).words step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))) :
    ∀ stores,MemoryRegions.Inside16 projection.base (2*(4*groups)) stores→Certificate projection stores before :=
  fun stores inside=>checked projection stores inside before limit finite

theorem outside (separate : MemoryRegions.Disjoint projection.base (2*(4*groups)) base size)
    (offset : Nat) (bound : offset<size) : projection.stores.memory (base+offset)=projection.source.bytes (base+offset) :=
  projection.other_region separate offset bound

theorem selected (generation : Nat) (size : Char)
    (projection : MlxQmvMemory.Execution .four p input buffers (blocks*2))
    (limit : blocks≤31040) (hsteps : steps≤15) (before : Nat→Float32)
    (finite : ∀ (row : Fin (4*(blocks*2))) step lane, AffineTile.Finite4 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights4 buffers row).words step lane)
      (AffineLoads.scale buffers row (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))) :
    MlxQmvHostSource.selected generation size (steps*512) (blocks*8)=true ∧
    MlxQmvHostSource.launch (blocks*8)=⟨1,blocks,1,32,2,1⟩ ∧
    (∀ (group : Fin (blocks*2)) (row : Fin 4) (step : Fin steps) (lane : Fin 32),
      MlxQmvFast4Pointers.packedOffset steps group.val row.val step.val lane.val+8<2^31 ∧
      MlxQmvFast4Pointers.parameterOffset steps group.val row.val step.val lane.val<2^31 ∧
      MlxQmvFast4Pointers.inputOffset step.val lane.val+16<2^31) ∧
    ∀ stores,MemoryRegions.Inside16 projection.base (2*(4*(blocks*2))) stores→Certificate projection stores before := by
  refine ⟨MlxQmvHostSource.selected_blocks generation size steps blocks,MlxQmvHostSource.launch_blocks blocks,?_,?_⟩
  · exact fun group row step lane=>MlxQmvFast4Pointers.signed_offsets (by omega) hsteps group row step lane
  · exact all_prefixes projection before (by omega) finite

end Inference.Kernels.Quantization.MlxQmvFast4Memory
