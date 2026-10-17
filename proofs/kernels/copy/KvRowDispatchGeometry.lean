import state.KvCopy

namespace Inference.Kernels.Copy.KvRowDispatchGeometry
open Contracts.Mlx
set_option maxRecDepth 10000

-- A restricted mathematical translation of backend/common/utils.cpp:20-83,
-- for TWO nonnegative stride arrays. This is not a parsed C++ host semantics.
-- Axis records replace retained integer indices; none denotes the -1 marker.
-- The selected arithmetic bounds below justify natural-number multiplication
-- for the corresponding native size_t/int/stride operations.
structure Axis where
  extent : Nat
  inputStride : Nat
  outputStride : Nat
  deriving DecidableEq, Repr

def contiguous (previous current : Axis) (size cap : Nat) : Prop :=
  current.inputStride*current.extent=previous.inputStride ∧
  current.outputStride*current.extent=previous.outputStride ∧ size≤cap

instance (previous current : Axis) (size cap : Nat) : Decidable (contiguous previous current size cap) := by
  unfold contiguous
  infer_instance

def mark (cap : Nat) : List Axis → Axis → Nat → List (Option Axis) → List (Option Axis)
  | [], _, _, markers => markers++[none]
  | current::rest, previous, size, markers =>
      let product := size*current.extent
      let connected := contiguous previous current product cap
      let nextMarkers := if connected then markers else markers++[none]
      let nextSize := if connected then product else current.extent
      let retained := if current.extent=1 then nextMarkers else nextMarkers++[some current]
      mark cap rest current nextSize retained

def markers (axes : List Axis) (cap : Nat) : List (Option Axis) :=
  match axes with
  | [] => []
  | first::rest => mark cap rest first first.extent (if first.extent=1 then [] else [some first])

-- Native second phase multiplies all retained extents between separators and
-- takes both strides from the LAST retained axis in each group. Empty groups
-- (including leading/consecutive separators) are ignored.
def collect : List (Option Axis) → Option Axis → List Axis
  | [], none => []
  | [], some group => [group]
  | none::rest, none => collect rest none
  | none::rest, some group => group::collect rest none
  | some axis::rest, none => collect rest (some axis)
  | some axis::rest, some group =>
      collect rest (some ⟨group.extent*axis.extent,axis.inputStride,axis.outputStride⟩)

def collapse (axes : List Axis) (cap : Nat) : List Axis :=
  let result := collect (markers axes cap) none
  if axes≠[] ∧ result=[] then [⟨1,0,0⟩] else result

-- Actual upd.shape [1,4,1,256] and prepare_slice's unit-slice output strides.
-- Batch and singleton-time source strides are not guessed from a contiguous
-- source: they may be arbitrary nonnegative values.
def axes (sourceBatch sourceHead sourceTime sourceColumn destinationBatch capacity : Nat) : List Axis :=
  [⟨1,sourceBatch,destinationBatch⟩,⟨4,sourceHead,256*capacity⟩,
    ⟨1,sourceTime,256⟩,⟨256,sourceColumn,1⟩]

theorem singleton_time_break (sourceHead sourceTime capacity size : Nat) (room : 2≤capacity) :
    ¬contiguous ⟨4,sourceHead,256*capacity⟩ ⟨1,sourceTime,256⟩ size cap := by
  intro h
  have equal := h.2.1
  simp only [Nat.mul_one] at equal
  omega

-- Closed symbolic evaluation of both phases. The two undecided contiguity
-- tests only add redundant separators, so no source contiguity is assumed.
theorem collapsed (sourceBatch sourceHead sourceTime sourceColumn destinationBatch capacity : Nat)
    (room : 2≤capacity) :
    collapse (axes sourceBatch sourceHead sourceTime sourceColumn destinationBatch capacity) (2^31-1)=
      [⟨4,sourceHead,256*capacity⟩,⟨256,sourceColumn,1⟩] := by
  simp only [collapse,axes,markers,mark]
  simp only [singleton_time_break sourceHead sourceTime capacity _ room,↓reduceIte]
  split_ifs <;> simp_all [collect]

-- copy_gpu_inplace uses the last two collapsed dimensions and computes rest
-- from their product. No shape bytes are bound for ndim≤3.
structure Grid where
  x : Nat
  y : Nat
  z : Nat
  deriving DecidableEq, Repr

def grid (collapsed : List Axis) : Grid :=
  let dim0 := (collapsed.reverse[0]?).map Axis.extent |>.getD 1
  let dim1 := (collapsed.reverse[1]?).map Axis.extent |>.getD 1
  let dataSize := (collapsed.map Axis.extent).prod
  ⟨dim0,dim1,dataSize/(dim0*dim1)⟩

theorem grid_selected (sourceHead sourceColumn capacity : Nat) :
    grid [⟨4,sourceHead,256*capacity⟩,⟨256,sourceColumn,1⟩]=⟨256,4,1⟩ := by simp [grid]

-- Default pow2=10 get_block_dims_common loop, with explicit bounded fuel.
-- Exhaustion is failure, not an invented return value; the selected closed
-- evaluation below proves that the actual loop reaches its native exit.
structure Powers where
  x : Nat
  y : Nat
  z : Nat
  deriving DecidableEq

def Powers.sum (p : Powers) : Nat := p.x+p.y+p.z
def Powers.dimensions (p : Powers) : Grid := ⟨2^p.x,2^p.y,2^p.z⟩

def blockLoop : Nat → Grid → Powers → Option Grid
  | 0, _, _ => none
  | fuel+1, dims, p =>
      let first := if dims.x≥2^(p.x+1) then {p with x:=p.x+1} else p
      if first.sum=10 then some first.dimensions else
      let second := if dims.y≥2^(first.y+1) then {first with y:=first.y+1} else first
      if second.sum=10 then some second.dimensions else
      let third := if dims.z≥2^(second.z+1) then {second with z:=second.z+1} else second
      if third.sum=p.sum ∨ third.sum=10 then some third.dimensions
      else blockLoop fuel dims third

def blockDimensions (dims : Grid) : Option Grid := blockLoop 10 dims ⟨0,0,0⟩

theorem block_selected : blockDimensions ⟨256,4,1⟩=some ⟨256,4,1⟩ := by decide

theorem collapsed_dispatch (sourceBatch sourceHead sourceTime sourceColumn destinationBatch capacity : Nat)
    (room : 2≤capacity) :
    grid (collapse (axes sourceBatch sourceHead sourceTime sourceColumn destinationBatch capacity) (2^31-1))=⟨256,4,1⟩ := by
  rw [collapsed _ _ _ _ _ _ room,grid_selected]

-- prepare_slice's loop (common/slicing.cpp:7-18), specialized to
-- nonnegative starts and unit positive slice steps. Each entry is
-- (start, sliceStep, originalArrayStride).
def prepareSlice : List (Nat × Nat × Nat) → Nat × List Nat
  | [] => (0,[])
  | (start,step,stride)::rest =>
      let tail := prepareSlice rest
      (start*stride+tail.1,stride*step::tail.2)

def sliceArguments (batch capacity n : Nat) : List (Nat × Nat × Nat) :=
  [(0,1,batch),(0,1,256*capacity),(n,1,256),(0,1,1)]

theorem slice_prepared (batch capacity n : Nat) :
    prepareSlice (sliceArguments batch capacity n)=(256*n,[batch,256*capacity,256,1]) := by
  simp only [sliceArguments,prepareSlice,Nat.zero_mul,Nat.mul_zero,Nat.mul_one,Nat.one_mul,Nat.zero_add,Nat.add_zero,Nat.mul_comm]

-- KvCopy.Source deliberately does not promise a backing-allocation span or
-- native data_size. Supply those original descriptor facts explicitly; source
-- attachment alone does NOT imply the small-int32 native branch.
structure SourceDescriptor (source : State.KvCopy.Source next) where
  dataSize : Nat
  span : 3*source.rowStride+255*source.columnStride<dataSize
  small : dataSize≤2^31-1
  bounded : source.base+2*dataSize≤2^64

def large (sourceDataSize capacity : Nat) : Prop :=
  sourceDataSize>2^31-1 ∨ 4*capacity*256>2^31-1

theorem small_selection (source : State.KvCopy.Source next) (descriptor : SourceDescriptor source)
    (capacity : Nat) (supported : capacity≤262144) : ¬large descriptor.dataSize capacity := by
  have := descriptor.small
  unfold large
  omega

theorem source_stride_bounds (source : State.KvCopy.Source next) (descriptor : SourceDescriptor source) :
    source.rowStride<2^31 ∧ source.columnStride<2^31 ∧
      4*source.rowStride<2^63 ∧ 256*source.columnStride<2^63 := by
  have := descriptor.span
  have := descriptor.small
  omega

theorem collapse_arithmetic (source : State.KvCopy.Source next) (descriptor : SourceDescriptor source)
    (capacity : Nat) (supported : capacity≤262144) :
    4*source.rowStride<2^64 ∧ 256*source.columnStride<2^64 ∧
    4*(256*capacity)<2^64 ∧ (4:Nat)*1*256<2^31 ∧ (1024:Nat)<2^64 := by
  have := source_stride_bounds source descriptor
  omega

theorem collapsed_arrays (source : State.KvCopy.Source next) (sourceBatch sourceTime destinationBatch capacity : Nat)
    (room : 2≤capacity) :
    let result := collapse (axes sourceBatch source.rowStride sourceTime source.columnStride destinationBatch capacity) (2^31-1)
    result.map Axis.extent=[4,256] ∧ result.map Axis.inputStride=[source.rowStride,source.columnStride] ∧
      result.map Axis.outputStride=[256*capacity,1] := by
  dsimp only
  rw [collapsed _ _ _ _ _ _ room]
  exact ⟨rfl,rfl,rfl⟩

-- Native elem_to_loc_2 uses x=coordinate, y=head. Its collapsed stride arrays
-- therefore denote exactly KvCopy's 2-D layout, including the slice offset.
theorem layout_addresses (source : State.KvCopy.Source next) (base capacity n : Nat) (label : State.KvBytes.Label) :
    Copy2D.sourceAddress (State.KvCopy.layout source base capacity n) label=
      source.base+2*(label.2.val*source.columnStride+label.1.val*source.rowStride) ∧
    (State.KvCopy.layout source base capacity n).destinationBase+
      2*Copy2D.destination (State.KvCopy.layout source base capacity n).destinationRow label=
      base+2*(256*n+label.2.val+label.1.val*(256*capacity)) := by
  constructor
  · rfl
  · dsimp [State.KvCopy.layout,Copy2D.destination]
    ring

theorem source_index_bounds (source : State.KvCopy.Source next) (descriptor : SourceDescriptor source)
    (label : State.KvBytes.Label) :
    let x := label.2.val*source.columnStride
    let y := label.1.val*source.rowStride
    x<2^31 ∧ y<2^31 ∧ x+y<2^31 ∧ x+y<descriptor.dataSize ∧
      source.base+2*(x+y)+2≤2^64 := by
  have col : label.2.val≤255 := by have := label.2.isLt; omega
  have row : label.1.val≤3 := by have := label.1.isLt; omega
  have colBound := Nat.mul_le_mul_right source.columnStride col
  have rowBound := Nat.mul_le_mul_right source.rowStride row
  have := descriptor.span
  have := descriptor.small
  have := descriptor.bounded
  dsimp only
  omega

theorem destination_index_bounds (base capacity n : Nat) (room : n<capacity)
    (supported : capacity≤262144) (bounded : base+2*(4*capacity*256)≤2^64)
    (label : State.KvBytes.Label) :
    let x := label.2.val
    let y := label.1.val*(256*capacity)
    x<2^31 ∧ y<2^31 ∧ x+y<2^31 ∧ 256*n+x+y<4*capacity*256 ∧
      base+2*(256*n+x+y)+2≤2^64 ∧ 256*n<2^63 := by
  have actual := State.Kv.address_bounds capacity label.1 n label.2 room
  have col : label.2.val≤255 := by have := label.2.isLt; omega
  have row : label.1.val≤3 := by have := label.1.isLt; omega
  have rowBound := Nat.mul_le_mul_right (256*capacity) row
  dsimp only [State.Kv.address] at actual
  have rearrange : (label.1.val*capacity+n)*256+label.2.val=
      256*n+label.2.val+label.1.val*(256*capacity) := by ring
  rw [rearrange] at actual
  dsimp only
  omega

theorem grid_bounds (label : State.KvBytes.Label) :
    label.2.val<256 ∧ label.1.val<4 ∧ label.2.val<2^32 ∧ label.1.val<2^32 ∧
      (256:Nat)*4*1=1024 ∧ (1024:Nat)<2^32 := by
  have := label.1.isLt
  have := label.2.isLt
  omega

-- Concrete first-token capacity, with arbitrary original strided sources.
theorem first_capacity (sourceBatch sourceHead sourceTime sourceColumn destinationBatch : Nat) :
    collapse (axes sourceBatch sourceHead sourceTime sourceColumn destinationBatch 256) (2^31-1)=
      [⟨4,sourceHead,65536⟩,⟨256,sourceColumn,1⟩] ∧
    grid (collapse (axes sourceBatch sourceHead sourceTime sourceColumn destinationBatch 256) (2^31-1))=⟨256,4,1⟩ :=
  ⟨collapsed _ _ _ _ _ _ (by decide),collapsed_dispatch _ _ _ _ _ _ (by decide)⟩

-- All native intermediate multiplications used in the two host loops fit
-- their selected signed/unsigned types. Batch/time strides here are ORIGINAL
-- descriptor values; their representability cannot follow from row attachment.
theorem host_integer_bounds (source : State.KvCopy.Source next) (descriptor : SourceDescriptor source)
    (sourceBatch sourceTime capacity n : Nat) (batchBound : sourceBatch<2^63) (timeBound : sourceTime<2^63)
    (supported : capacity≤262144) (room : n<capacity) :
    sourceBatch<2^63 ∧ sourceTime*1<2^63 ∧ source.rowStride*4<2^63 ∧
    source.columnStride*256<2^63 ∧ 4*capacity*256<2^31 ∧ 256*n*2<2^63 ∧
    (1024:Nat)<2^31 ∧ (1024:Nat)<2^64 := by
  have := source_stride_bounds source descriptor
  have row := Nat.mul_le_mul_right 256 (show n≤262144 by omega)
  omega

-- Exact geometry returned to the selected, non-reducing SliceUpdate route.
-- No GPU execution, output values or parameter attachment is an input here.
-- Actual C++ translation, descriptor extraction, BF16 dtype, unit slice steps,
-- and runtime pipeline capability still bind this model to a native dispatch.
structure Selection (source : State.KvCopy.Source next) (descriptor : SourceDescriptor source)
    (sourceBatch sourceTime capacity n : Nat) : Prop where
  slice : prepareSlice (sliceArguments (4*capacity*256) capacity n)=
    (256*n,[4*capacity*256,256*capacity,256,1])
  shape : (collapse (axes sourceBatch source.rowStride sourceTime source.columnStride (4*capacity*256) capacity) (2^31-1)).map Axis.extent=[4,256]
  inputStrides : (collapse (axes sourceBatch source.rowStride sourceTime source.columnStride (4*capacity*256) capacity) (2^31-1)).map Axis.inputStride=
    [source.rowStride,source.columnStride]
  outputStrides : (collapse (axes sourceBatch source.rowStride sourceTime source.columnStride (4*capacity*256) capacity) (2^31-1)).map Axis.outputStride=
    [256*capacity,1]
  small : ¬large descriptor.dataSize capacity
  dispatch : grid (collapse (axes sourceBatch source.rowStride sourceTime source.columnStride (4*capacity*256) capacity) (2^31-1))=⟨256,4,1⟩
  group : blockDimensions ⟨256,4,1⟩=some ⟨256,4,1⟩
  arithmetic : sourceBatch<2^63 ∧ sourceTime*1<2^63 ∧ source.rowStride*4<2^63 ∧
    source.columnStride*256<2^63 ∧ 4*capacity*256<2^31 ∧ 256*n*2<2^63 ∧
    (1024:Nat)<2^31 ∧ (1024:Nat)<2^64

theorem selected (source : State.KvCopy.Source next) (descriptor : SourceDescriptor source)
    (sourceBatch sourceTime capacity n : Nat) (batchBound : sourceBatch<2^63) (timeBound : sourceTime<2^63)
    (minimum : 2≤capacity) (supported : capacity≤262144) (room : n<capacity) :
    Selection source descriptor sourceBatch sourceTime capacity n where
  slice := slice_prepared _ _ _
  shape := (collapsed_arrays source sourceBatch sourceTime _ capacity minimum).1
  inputStrides := (collapsed_arrays source sourceBatch sourceTime _ capacity minimum).2.1
  outputStrides := (collapsed_arrays source sourceBatch sourceTime _ capacity minimum).2.2
  small := small_selection source descriptor capacity supported
  dispatch := collapsed_dispatch _ _ _ _ _ _ minimum
  group := block_selected
  arithmetic := host_integer_bounds source descriptor _ _ _ _ batchBound timeBound supported room

end Inference.Kernels.Copy.KvRowDispatchGeometry
