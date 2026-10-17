import kernels.quantization.AffineOuter4Syntax
import kernels.quantization.AffineDot3PreloadFrame
import kernels.quantization.AffineOutputSource
namespace Inference.Kernels.Quantization.AffineOuter3Call
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open AffineOuter4Syntax
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] parseLayout parseHeader parsePointers parseReads parseUpdates parseInitial parseCall
  AffineOutputSource.rowBase

structure Frame where
  memory : AffineDot3Source.Memory
  scale : Float32
  sum : Float32
  bias : Float32

def rowSpan (shape : Layout) (steps : Nat) : Nat := steps*512*3/shape.rowDivisor
def groupSpan (shape : Layout) (steps : Nat) : Nat := steps*512/shape.groupDivisor
def packedOffset (shape : Layout) (updates : Updates) (steps row0 offset step lane : Nat) : Nat :=
  row0*rowSpan shape steps+lane*(shape.packedFactor*3)+step*(updates.packedLanes*(shape.packedFactor*3))+offset*rowSpan shape steps
def scalarOffset (shape : Layout) (divisor advance steps row0 offset step lane : Nat) : Nat :=
  row0*groupSpan shape steps+lane/divisor+step*advance+offset*groupSpan shape steps

def frameSource (buffers : AffineLoads.Buffers) (scratch : Nat → Float32)
    (group : Fin groups) (offset : Fin 4) (step : Fin steps) (lane : Fin 32) : Option Frame := do
  let shape ←parseLayout layoutSource
  let header ←parseHeader headerSource
  let divisor ←parsePointers pointersSource
  let reads ←parseReads readsSource
  let updates ←parseUpdates updatesSource
  let row0 ←AffineOutputSource.rowBase (AffineOutputSource.block group) (AffineOutputSource.simd group)
  let k := header.start+step.val*header.stride
  pure ⟨⟨buffers.packed,buffers.packedBase+packedOffset shape updates steps row0.toNat offset.val step.val lane.val,
    scratch,k+lane.val*reads.inputLaneWidth⟩,
    BFloat16.widen (Model.ofBits (HalfMemory.load buffers.scales
      (buffers.scaleBase+2*scalarOffset shape divisor updates.scaleStep steps row0.toNat offset.val step.val lane.val))),
    scratch (steps*32*16+(k+lane.val*reads.sumLaneWidth)/reads.sumDivisor),
    BFloat16.widen (Model.ofBits (HalfMemory.load buffers.biases
      (buffers.biasBase+2*scalarOffset shape divisor updates.biasStep steps row0.toNat offset.val step.val lane.val)))⟩

def expectedFrame (buffers : AffineLoads.Buffers) (scratch : Nat → Float32)
    (group : Fin groups) (offset : Fin 4) (step : Fin steps) (lane : Fin 32) : Frame :=
  let row := CopyContiguous.index group offset
  ⟨AffineDot3TileMemory.view buffers row step lane scratch ((AffineLayout.chunkIndex step lane).val*16),
    BFloat16.widen (AffineLoads.scale buffers row (AffineRow.groupIndex step lane)),
    scratch (steps*32*16+(AffineLayout.chunkIndex step lane).val),
    BFloat16.widen (AffineLoads.bias buffers row (AffineRow.groupIndex step lane))⟩

theorem packed_offset (group : Fin groups) (offset : Fin 4) (step : Fin steps) (lane : Fin 32) :
    packedOffset layout updates steps (4*group.val) offset.val step.val lane.val=
      AffineLayout.weightOffset 3 (CopyContiguous.index group offset).val steps step.val lane.val 0 := by
  have span : steps*512*3/8=steps*192 := by omega
  simp only [packedOffset,rowSpan,layout,updates,span,CopyContiguous.index,AffineLayout.weightOffset]
  ring

theorem scalar_offset (group : Fin groups) (offset : Fin 4) (step : Fin steps) (lane : Fin 32) :
    scalarOffset layout 4 8 steps (4*group.val) offset.val step.val lane.val=
      AffineLoads.groupIndex (CopyContiguous.index group offset) (AffineRow.groupIndex step lane) := by
  have span : steps*512/64=steps*8 := by omega
  simp only [scalarOffset,groupSpan,layout,span,AffineLoads.groupIndex,CopyContiguous.index,AffineRow.groupIndex]
  ring

theorem frame_source (limit : groups≤62080) (buffers : AffineLoads.Buffers) (scratch : Nat → Float32)
    (group : Fin groups) (offset : Fin 4) (step : Fin steps) (lane : Fin 32) :
    frameSource buffers scratch group offset step lane=some (expectedFrame buffers scratch group offset step lane) := by
  simp only [frameSource,parsed_layout,parsed_header,parsed_pointers,parsed_reads,parsed_updates,AffineOutputSource.row_base limit]
  have positive : ((4:Int)*(group.val:Int)).toNat=4*group.val := by omega
  simp only [bind,Option.bind,positive,header,reads,updates,Nat.zero_add]
  change some (⟨⟨buffers.packed,buffers.packedBase+packedOffset layout updates steps (4*group.val) offset.val step.val lane.val,
      scratch,step.val*512+lane.val*16⟩,
    BFloat16.widen (Model.ofBits (HalfMemory.load buffers.scales
      (buffers.scaleBase+2*scalarOffset layout 4 8 steps (4*group.val) offset.val step.val lane.val))),
    scratch (steps*32*16+(step.val*512+lane.val*16)/16),
    BFloat16.widen (Model.ofBits (HalfMemory.load buffers.biases
      (buffers.biasBase+2*scalarOffset layout 4 8 steps (4*group.val) offset.val step.val lane.val)))⟩ : Frame)=_
  rw [packed_offset,scalar_offset,AffineLayout.sum_pointer]
  have input : step.val*512+lane.val*16=(AffineLayout.chunkIndex step lane).val*16 := by
    dsimp [AffineLayout.chunkIndex]; omega
  rw [input]
  rfl

-- Finite selected dimensions make the actual signed offset intermediates
-- representable; geometry separately supplies native pointer allocation bounds.
theorem offset_bounds (limit : groups≤62080) (hsteps : steps≤15)
    (group : Fin groups) (offset : Fin 4) (step : Fin steps) (lane : Fin 32) :
    packedOffset layout updates steps (4*group.val) offset.val step.val lane.val<2^31 ∧
    scalarOffset layout 4 8 steps (4*group.val) offset.val step.val lane.val<2^31 ∧
    step.val*512+lane.val*16<steps*512 ∧ step.val*512+512≤2^31 := by
  rw [packed_offset,scalar_offset]
  have row := (CopyContiguous.index group offset).isLt
  have groupBound := (AffineRow.groupIndex step lane).isLt
  have packed := AffineLayout.weight_bound 3 (Or.inl rfl) (CopyContiguous.index group offset) step lane 0 (by decide)
  have scalar := AffineLoads.group_bound (CopyContiguous.index group offset) (AffineRow.groupIndex step lane)
  have totalPacked : 4*groups*(steps*64*3)≤715161600 := by nlinarith
  have totalScalar : 4*groups*(steps*8)≤29798400 := by nlinarith
  have := step.isLt; have := lane.isLt
  omega

-- A call retains its actual parsed function execution. Keeping the result
-- relational avoids duplicating the byte-loop interpreter and all its rounds.
def SourceCall (p : AffineTile.Platform) (buffers : AffineLoads.Buffers) (scratch : Nat → Float32)
    (group : Fin groups) (offset : Fin 4) (step : Fin steps) (lane : Fin 32) (result : Float32) : Prop :=
  ∃ frame : Frame, parseCall callSource=some () ∧ frameSource buffers scratch group offset step lane=some frame ∧
    AffineDot3FunctionSource.Execution p.contracted p.tailContracted frame.memory frame.scale frame.sum frame.bias result

variable (p : AffineRow.Platform) (input : Fin (steps*512) → ArrayStorage.BF) (buffers : AffineLoads.Buffers)
  (projection : MlxQmvMemory.Execution .three p input buffers groups)
  (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 projection.base (2*(4*groups)) stores)
  {schedule after}
  (trace : AffinePreload3Source.SourceTrace p.tile (AffineDot4PreloadedMemory.chunkBuffer projection.source) schedule after)
  (before : Nat → Float32)

include inside trace in
theorem source_call (limit : groups≤62080) (hsteps : steps≤15)
    (group : Fin groups) (offset : Fin 4) (step : Fin steps) (lane : Fin 32)
    (finite : AffineTile.Finite3 p.tile (AffineRow.slice input step lane)
      ((AffineLoads.weights3 buffers (CopyContiguous.index group offset)).bytes step lane)
      (AffineLoads.scale buffers (CopyContiguous.index group offset) (AffineRow.groupIndex step lane))
      (AffineLoads.bias buffers (CopyContiguous.index group offset) (AffineRow.groupIndex step lane))) :
    SourceCall p.tile (AffineMemory.reframe buffers (HalfMemory.execute stores projection.source.bytes))
      (MemoryCells.execute schedule before) group offset step lane
      (AffineRow.tiles3 p input (AffineLoads.weights3 buffers (CopyContiguous.index group offset)) step lane) := by
  refine ⟨expectedFrame _ _ group offset step lane,parsed_call,frame_source limit _ _ group offset step lane,?_⟩
  exact AffineDot3PreloadFrame.completed p input buffers projection hsteps trace before stores inside
    (CopyContiguous.index group offset) step lane finite
end Inference.Kernels.Quantization.AffineOuter3Call
