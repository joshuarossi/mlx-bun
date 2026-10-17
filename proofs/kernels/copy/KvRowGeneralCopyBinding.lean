import kernels.copy.KvRowDispatchGeometry
import kernels.copy.GeneralCopy2DSemantics
import kernels.copy.GeneralCopy2DInterleaving
import state.KvAppendMemory

namespace Inference.Kernels.Copy.KvRowGeneralCopyBinding
open Contracts.Mlx KvRowDispatchGeometry
set_option maxRecDepth 10000
attribute [local irreducible] Copy2DMemory.programs CopyExecution.Trace.memory List.finRange

-- GeneralCopy2DSemantics and Copy2DMemory both use Copy2D.Layout. All fields
-- below come from the ORIGINAL row source and actual destination allocation.
-- No desired values or post-execution attachments are inputs.
theorem bounds (source : State.KvCopy.Source next) (descriptor : SourceDescriptor source)
    (base capacity n : Nat) (aligned : base%2=0) (room : n<capacity)
    (minimum : 2≤capacity) (supported : capacity≤262144)
    (bounded : base+2*(4*capacity*256)≤2^64) :
    GeneralCopy2DSemantics.Bounds (State.KvCopy.layout source base capacity n) where
  sourceAligned := source.aligned
  destinationAligned := by dsimp [State.KvCopy.layout]; omega
  sourceIndex := by
    have := descriptor.span
    have := descriptor.small
    dsimp [State.KvCopy.layout]
    omega
  destinationIndex := by dsimp [State.KvCopy.layout]; omega
  sourceAddress := by
    have := descriptor.span
    have := descriptor.bounded
    dsimp [State.KvCopy.layout]
    omega
  destinationAddress := by
    have limit := Nat.mul_le_mul_right 256 (show n+1≤capacity by omega)
    dsimp [State.KvCopy.layout]
    omega
  rowRoom := by dsimp [State.KvCopy.layout]; omega

-- Restricted CommandEncoder binding model: array.offset() is ALREADY bytes,
-- and copy_gpu_inplace multiplies its additional ELEMENT offset by dtype size.
-- Native buffer identity/offset extraction remains a source-correspondence
-- boundary. This record describes a pointer; it does not manufacture a heap.
structure Pointer where
  bufferBase : Nat
  arrayOffset : Nat
  deriving DecidableEq, Repr

def Pointer.address (pointer : Pointer) (extraByteOffset : Nat) : Nat :=
  pointer.bufferBase+pointer.arrayOffset+extraByteOffset

structure Arguments where
  input : Nat
  output : Nat
  inputStrides : List Nat
  outputStrides : List Nat
  grid : Grid
  group : Option Grid
  deriving DecidableEq, Repr

-- SliceUpdate::None passes i_offset=0/o_offset=prepare_slice(...).first;
-- its GeneralGeneral descriptor binds strides to slots3/4. BF16 is2bytes.
def arguments (source : State.KvCopy.Source next) (sourcePointer destinationPointer : Pointer)
    (sourceBatch sourceTime capacity n : Nat) : Arguments :=
  let slice := prepareSlice (sliceArguments (4*capacity*256) capacity n)
  let collapsed := collapse (axes sourceBatch source.rowStride sourceTime source.columnStride (4*capacity*256) capacity) (2^31-1)
  let dims := KvRowDispatchGeometry.grid collapsed
  ⟨sourcePointer.address (0*2),destinationPointer.address (slice.1*2),
    collapsed.map Axis.inputStride,collapsed.map Axis.outputStride,dims,blockDimensions dims⟩

theorem arguments_layout (source : State.KvCopy.Source next) (descriptor : SourceDescriptor source) (sourcePointer destinationPointer : Pointer)
    (base sourceBatch sourceTime capacity n : Nat)
    (inputBinding : sourcePointer.address 0=source.base)
    (outputBinding : destinationPointer.address 0=base)
    (geometry : Selection source descriptor sourceBatch sourceTime capacity n) :
    arguments source sourcePointer destinationPointer sourceBatch sourceTime capacity n=
      ⟨(State.KvCopy.layout source base capacity n).sourceBase,
        (State.KvCopy.layout source base capacity n).destinationBase,
        [(State.KvCopy.layout source base capacity n).sourceRow,(State.KvCopy.layout source base capacity n).sourceColumn],
        [(State.KvCopy.layout source base capacity n).destinationRow,1],⟨256,4,1⟩,some ⟨256,4,1⟩⟩ := by
  simp only [arguments,geometry.slice,geometry.inputStrides,geometry.outputStrides,geometry.dispatch,block_selected,State.KvCopy.layout]
  have input : sourcePointer.address (0*2)=source.base := by simpa using inputBinding
  have output : destinationPointer.address (256*n*2)=base+2*(n*256) := by
    unfold Pointer.address at outputBinding ⊢
    omega
  rw [input,output]
  simp only [Nat.mul_comm]

-- The parsed GG2 body now obtains all its arithmetic premises from original
-- descriptor/allocation geometry. Its source reads are the executing heap's.
theorem parsed_body (source : State.KvCopy.Source next) (descriptor : SourceDescriptor source)
    (base capacity n : Nat) (aligned : base%2=0) (room : n<capacity)
    (minimum : 2≤capacity) (supported : capacity≤262144)
    (bounded : base+2*(4*capacity*256)≤2^64)
    (label : GeneralCopy2DSemantics.Label) (before : GeneralCopy2DSemantics.Machine) :
    ((GeneralCopy2DSyntax.parseBody GeneralCopy2DSyntax.sourceBody).bind
      (fun code => GeneralCopy2DSemantics.execute (State.KvCopy.layout source base capacity n) label code before))=
      some (GeneralCopy2DSemantics.afterBody (State.KvCopy.layout source base capacity n) label before) :=
  GeneralCopy2DSemantics.parsed_execution (bounds source descriptor base capacity n aligned room minimum supported bounded) label before

theorem body_operation (source : State.KvCopy.Source next) (descriptor : SourceDescriptor source)
    (base capacity n : Nat) (aligned : base%2=0) (room : n<capacity)
    (minimum : 2≤capacity) (supported : capacity≤262144)
    (bounded : base+2*(4*capacity*256)≤2^64)
    (label : GeneralCopy2DSemantics.Label) (before after : GeneralCopy2DSemantics.Machine)
    (execution : GeneralCopy2DSemantics.execute (State.KvCopy.layout source base capacity n) label GeneralCopy2DSyntax.body before=some after) :
    after.memory=CopyExecution.execute [Copy2DMemory.operation (State.KvCopy.layout source base capacity n) label] before.memory :=
  GeneralCopy2DSemantics.execution_refines (bounds source descriptor base capacity n aligned room minimum supported bounded) label before after execution

-- Whole backing-region separation is sufficient for the actual dynamic-copy
-- NoAlias predicate, even for strided/overlapping source coordinates.
theorem no_alias (source : State.KvCopy.Source next) (descriptor : SourceDescriptor source)
    (base capacity n : Nat) (aligned : base%2=0) (room : n<capacity)
    (minimum : 2≤capacity) (supported : capacity≤262144)
    (bounded : base+2*(4*capacity*256)≤2^64)
    (fresh : MemoryRegions.Disjoint base (2*(4*capacity*256)) source.base (2*descriptor.dataSize)) :
    CopyExecution.NoAlias (Copy2DMemory.programs (State.KvCopy.layout source base capacity n) 4 256).flatten := by
  apply Copy2DMemory.no_alias
  intro reader writer same
  let b := bounds source descriptor base capacity n aligned room minimum supported bounded
  have src := source_index_bounds source descriptor reader
  have dst := destination_index_bounds base capacity n room supported bounded writer
  have equal := congrArg (fun word => 2*word) same
  change 2*(Copy2DMemory.operation (State.KvCopy.layout source base capacity n) reader).source=
    2*(Copy2DMemory.operation (State.KvCopy.layout source base capacity n) writer).destination at equal
  rw [GeneralCopy2DSemantics.source_word_address b,GeneralCopy2DSemantics.destination_word_address b] at equal
  dsimp only [GeneralCopy2DSemantics.sourceIndex,GeneralCopy2DSemantics.destinationIndex,State.KvCopy.layout] at equal
  simp only [Nat.mul_comm capacity 256] at equal
  dsimp only at src dst
  rcases fresh with left|right <;> omega

-- One constructor links symbolic host collapse/dispatch with parsed-body
-- arithmetic. All premises are original pointer/allocation/dispatch geometry.
theorem selected_bounds (source : State.KvCopy.Source next) (descriptor : SourceDescriptor source)
    (base sourceBatch sourceTime capacity n : Nat)
    (aligned : base%2=0) (batchBound : sourceBatch<2^63) (timeBound : sourceTime<2^63)
    (room : n<capacity) (minimum : 2≤capacity) (supported : capacity≤262144)
    (bounded : base+2*(4*capacity*256)≤2^64) :
    Selection source descriptor sourceBatch sourceTime capacity n ∧
      GeneralCopy2DSemantics.Bounds (State.KvCopy.layout source base capacity n) :=
  ⟨KvRowDispatchGeometry.selected source descriptor _ _ _ _ batchBound timeBound minimum supported room,
    bounds source descriptor _ _ _ aligned room minimum supported bounded⟩

-- A Bounds-only adapter for existing actual append executions. These raw
-- span facts do not assert a native data_size or native small-branch choice;
-- those are separately supplied by SourceDescriptor/Selection above.
theorem bounds_of_span (source : State.KvCopy.Source next)
    (sourceSmall : 3*source.rowStride+255*source.columnStride<2^31)
    (sourceBound : source.base+State.KvAppendMemory.sourceBytes source≤2^64)
    (base capacity n : Nat) (aligned : base%2=0) (room : n<capacity)
    (supported : capacity≤262144) (bounded : base+2*(4*capacity*256)≤2^64) :
    GeneralCopy2DSemantics.Bounds (State.KvCopy.layout source base capacity n) where
  sourceAligned := source.aligned
  destinationAligned := by dsimp [State.KvCopy.layout]; omega
  sourceIndex := sourceSmall
  destinationIndex := by dsimp [State.KvCopy.layout]; omega
  sourceAddress := sourceBound
  destinationAddress := by
    have limit := Nat.mul_le_mul_right 256 (show n+1≤capacity by omega)
    dsimp [State.KvCopy.layout]
    omega
  rowRoom := by dsimp [State.KvCopy.layout]; omega

theorem append_bounds_of_span {n : Nat} {old : State.KvBytes.History n} {next : State.KvBytes.Row} (execution : State.KvAppendMemory.Execution old next)
    (sourceSmall : 3*execution.source.rowStride+255*execution.source.columnStride<2^31)
    (sourceBound : execution.source.base+State.KvAppendMemory.sourceBytes execution.source≤2^64)
    (supported : execution.capacity≤262144)
    (bounded : execution.base+2*(4*execution.capacity*256)≤2^64) :
    GeneralCopy2DSemantics.Bounds (State.KvCopy.layout execution.source execution.base execution.capacity n) :=
  bounds_of_span execution.source sourceSmall sourceBound execution.base execution.capacity n execution.aligned execution.room supported bounded

theorem append_no_alias {n : Nat} {old : State.KvBytes.History n} {next : State.KvBytes.Row} (execution : State.KvAppendMemory.Execution old next) :
    CopyExecution.NoAlias (Copy2DMemory.programs (State.KvCopy.layout execution.source execution.base execution.capacity n) 4 256).flatten :=
  State.KvAppendMemory.no_alias execution.source execution.base execution.capacity n execution.aligned execution.room execution.separate

-- CommandEncoder adds TWO signed int64 BYTE offsets before passing them
-- to Metal. Absolute64-bit pointer bounds alone do not justify that addition.
-- These original buffer-relative bounds explicitly cover the separate issue.
theorem offset_bounds (sourcePointer destinationPointer : Pointer) (capacity n : Nat)
    (sourceOffset : sourcePointer.arrayOffset<2^63)
    (destinationRange : destinationPointer.arrayOffset+2*(4*capacity*256)≤2^63)
    (room : n<capacity) :
    sourcePointer.arrayOffset+0<2^63 ∧ (256*n)*2<2^63 ∧
      destinationPointer.arrayOffset+(256*n)*2<2^63 := by
  have beforeEnd := Nat.mul_le_mul_right 256 (show n+1≤capacity by omega)
  omega

theorem separate_of_no_alias (layout : Copy2D.Layout)
    (separate : CopyExecution.NoAlias (Copy2DMemory.programs layout 4 256).flatten) :
    GeneralCopy2DInterleaving.Separate layout := by
  have member (label : Copy2D.Label 4 256) :
      Copy2DMemory.operation layout label∈(Copy2DMemory.programs layout 4 256).flatten := by
    unfold Copy2DMemory.programs Copy2D.labels
    exact List.mem_flatten.mpr ⟨[Copy2DMemory.operation layout label],
      List.mem_map.mpr ⟨label,List.mem_product.mpr ⟨List.mem_finRange _,List.mem_finRange _⟩,rfl⟩,
      List.mem_singleton_self _⟩
  intro reader writer
  exact separate _ (member reader) _ (member writer)

theorem append_separate {n : Nat} {old : State.KvBytes.History n} {next : State.KvBytes.Row}
    (execution : State.KvAppendMemory.Execution old next) :
    GeneralCopy2DInterleaving.Separate (State.KvCopy.layout execution.source execution.base execution.capacity n) :=
  separate_of_no_alias _ (append_no_alias execution)

end Inference.Kernels.Copy.KvRowGeneralCopyBinding
