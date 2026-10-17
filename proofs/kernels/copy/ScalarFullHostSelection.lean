import kernels.copy.VectorCopyHostSelection
import kernels.copy.ScalarCopyQuadSourceRefinement
import models.qwen.InitialCacheSourceConstruction
import models.qwen.InitialRecurrentSource

namespace Inference.Kernels.Copy.ScalarFullHostSelection
open Contracts.Mlx
open Inference.Models.Qwen
open VectorCopyHostSelection (Pipeline workPerThread ceilDiv)
set_option maxRecDepth 10000

-- Manual translation of zeros/full/broadcast/Full::eval_gpu and the nonlarge
-- Scalar copy host route, not a verified C++/array-metadata frontend. Scalar
-- creation, native buffer ownership, extracted metadata/pointers, compiler and
-- coherent hardware execution remain external. Source semantics below execute
-- actual attached buffers and construct their outputs rather than assume them.
def fullEvalSource : String := r#"void Full::eval_gpu(const std::vector<array>& inputs, array& out) {
  MLX_PROFILER_RANGE("Full::eval_gpu");
  auto in = inputs[0];
  CopyType ctype;
  if (in.data_size() == 1) {
    ctype = CopyType::Scalar;
  } else if (in.flags().contiguous) {
    ctype = CopyType::Vector;
  } else {
    ctype = CopyType::General;
  }
  copy_gpu(in, out, ctype);
}"#

def zerosSource : String := r#"array zeros(const Shape& shape, Dtype dtype, StreamOrDevice s /* = {} */) {
  return full(shape, array(0, dtype), to_stream(s));
}"#

def fullShapeSource : String := r#"array full(Shape shape, array vals, Dtype dtype, StreamOrDevice s /* = {} */) {
  if (std::any_of(shape.begin(), shape.end(), [](auto i) { return i < 0; })) {
    throw std::invalid_argument("[full] Negative dimensions not allowed.");
  }
  return full_impl(broadcast_to(vals, std::move(shape), s), dtype, s);
}"#

def fullImplSource : String := r#"array full_impl(array vals, Dtype dtype, StreamOrDevice s /* = {} */) {
  return array(
      vals.shape(),
      dtype,
      std::make_shared<Full>(to_stream(s)),
      {astype(vals, dtype, s)});
}"#

inductive Variant where
  | history | recurrent | kv
  deriving DecidableEq

def shape : Variant → List Nat
  | .history => [1,3,10240]
  | .recurrent => [1,48,128,128]
  | .kv => [1,4,256,256]

-- History/recurrent dimensions match DeltaNet.Cache; KV matches State.Kv.Cache
-- with first growth capacity256. Runtime model/config extraction remains explicit.
def elements (variant : Variant) : Nat := (shape variant).prod

def itemBytes : Variant → Nat
  | .recurrent => 4
  | _ => 2

def dtypeName : Variant → String
  | .recurrent => "float32"
  | _ => "bfloat16"

def work (variant : Variant) : Nat := workPerThread (itemBytes variant) (elements variant)

def kernel (variant : Variant) : String :=
  (if work variant>1 then "sn_copy" else "s_copy") ++ dtypeName variant ++ dtypeName variant

structure BroadcastInput (variant : Variant) where
  memory : HalfMemory.Bytes
  base : Nat

-- Broadcasting a scalar to the selected shape is a view, with no new stores.
-- This is the manually translated view descriptor; connecting it to a runtime
-- MLX array (including shared-buffer offset) is the stated metadata boundary.
def BroadcastInput.dataSize (_input : BroadcastInput variant) : Nat := 1

def BroadcastInput.logicalShape (_input : BroadcastInput variant) : List Nat := shape variant

def BroadcastInput.strides (_input : BroadcastInput variant) : List Nat := List.replicate (shape variant).length 0

def BroadcastInput.read (input : BroadcastInput variant) (_index : Fin (elements variant)) : BitVec (8*itemBytes variant) :=
  if h : itemBytes variant=2 then
    h ▸ (HalfMemory.load input.memory input.base : BitVec (8*2))
  else
    (show itemBytes variant=4 from by cases variant <;> simp_all [itemBytes]) ▸
      (ByteMemory.load32 input.memory input.base : BitVec (8*4))

theorem broadcast_scalar (input : BroadcastInput variant) : input.dataSize=1 := rfl

theorem broadcast_same_source (input : BroadcastInput variant) (i j : Fin (elements variant)) :
    input.read i=input.read j := rfl

-- Full tests data_size==1 before contiguous flags, so scalar broadcast is never
-- routed through a Vector donation branch. Scalar set_copy_output_data always
-- allocates out.nbytes(), with out data_size the contiguous shape product.
def selectedScalar (input : BroadcastInput variant) : Bool := input.dataSize==1

theorem full_selects_scalar (input : BroadcastInput variant) : selectedScalar input=true := rfl

def allocationBytes (variant : Variant) : Nat := elements variant*itemBytes variant

structure Dispatch where
  grid : Nat
  group : Nat
  sizeArgument : Nat
  templateN : Nat
  kernelName : String
  inputByteOffset : Nat
  outputByteOffset : Nat

def dispatch (variant : Variant) (pipeline : Pipeline) : Dispatch where
  grid := ceilDiv (elements variant) (work variant)
  group := min pipeline.maxThreads (ceilDiv (elements variant) (work variant))
  sizeArgument := elements variant
  templateN := work variant
  kernelName := kernel variant
  inputByteOffset := VectorCopyHostSelection.wrapperOffsets.1*itemBytes variant
  outputByteOffset := VectorCopyHostSelection.wrapperOffsets.2*itemBytes variant

theorem history_shape : elements .history=30720 := rfl
theorem recurrent_shape : elements .recurrent=786432 := rfl
theorem kv_shape : elements .kv=262144 := rfl

theorem history_dispatch (pipeline : Pipeline) : dispatch .history pipeline=
    ⟨30720,min pipeline.maxThreads 30720,30720,1,"s_copybfloat16bfloat16",0,0⟩ := rfl

theorem recurrent_dispatch (pipeline : Pipeline) : dispatch .recurrent pipeline=
    ⟨393216,min pipeline.maxThreads 393216,786432,2,"sn_copyfloat32float32",0,0⟩ := rfl

theorem kv_dispatch (pipeline : Pipeline) : dispatch .kv pipeline=
    ⟨65536,min pipeline.maxThreads 65536,262144,4,"sn_copybfloat16bfloat16",0,0⟩ := rfl

theorem template_default (variant : Variant) :
    (work variant=1 ∨ work variant=8/itemBytes variant) := by
  cases variant <;> decide +kernel

theorem byteCounts : allocationBytes .history=61440 ∧ allocationBytes .recurrent=3145728 ∧
    allocationBytes .kv=524288 := by decide +kernel

theorem nonlarge (variant : Variant) : elements variant≤4294967295 ∧ elements variant<2^31 := by
  cases variant <;> decide +kernel

theorem group_positive (variant : Variant) (pipeline : Pipeline) : 0<(dispatch variant pipeline).group := by
  cases variant <;> apply Nat.lt_min.mpr <;> exact ⟨pipeline.positive,by decide +kernel⟩

theorem group_bounded (variant : Variant) (pipeline : Pipeline) :
    (dispatch variant pipeline).group≤pipeline.maxThreads ∧
    (dispatch variant pipeline).group≤(dispatch variant pipeline).grid :=
  ⟨Nat.min_le_left _ _,Nat.min_le_right _ _⟩

-- Exact dispatch_threads grid IDs; there is no padded extra thread requiring
-- a size guard. Each final thread's full N-element loop is in range.
theorem no_tail (variant : Variant) (pipeline : Pipeline) (thread : Fin (dispatch variant pipeline).grid) :
    thread.val*work variant+work variant≤elements variant := by
  cases variant with
  | history =>
      have bound : thread.val<30720 := thread.isLt
      change thread.val*1+1≤30720
      omega
  | recurrent =>
      have bound : thread.val<393216 := thread.isLt
      change thread.val*2+2≤786432
      omega
  | kv =>
      have bound : thread.val<65536 := thread.isLt
      change thread.val*4+4≤262144
      omega

theorem index_bounds (variant : Variant) (pipeline : Pipeline)
    (thread : Fin (dispatch variant pipeline).grid) (offset : Fin (work variant)) :
    thread.val*work variant+offset.val<elements variant ∧
    thread.val*work variant+offset.val<2^32 ∧ offset.val+1<2^31 := by
  have tail := no_tail variant pipeline thread
  have size := nonlarge variant
  have localBound : work variant≤4 := by cases variant <;> decide +kernel
  have := offset.isLt
  omega

structure History where
  source : ArrayStorage.BFBuffer InitialStorage.historyZero
  plan : InitialCacheMemory.DeltaPlan
  safe : MemoryRegions.Disjoint plan.layout.historyBase 61440 source.base 2 ∧
    MemoryRegions.Disjoint plan.layout.recurrentBase 3145728 source.base 2
  pipeline : Pipeline

def History.input (p : History) : BroadcastInput .history := ⟨p.source.bytes,p.source.base⟩

theorem History.pointer (p : History) : p.input.base+(dispatch .history p.pipeline).inputByteOffset=p.source.base := rfl

theorem History.input_read (p : History) (i : Fin (elements .history)) :
    p.input.read i=ArrayStorage.bits (InitialStorage.historyZero 0) :=
  InitialHistorySource.scalar_read p.source

theorem History.output_pointer (p : History) :
    p.plan.layout.historyBase+(dispatch .history p.pipeline).outputByteOffset=p.plan.layout.historyBase := rfl

theorem History.checked (p : History) : InitialCacheSourceConstruction.HistoryChecked p.source p.plan p.safe :=
  InitialCacheSourceConstruction.history_checked p.source p.plan p.safe

structure Recurrent where
  source : ArrayStorage.FloatBuffer InitialStorage.recurrentZero
  layout : InitialStorageRegions.Layout
  fresh : MemoryRegions.Disjoint layout.recurrentBase 3145728 source.base 4
  rawZero : ByteMemory.load32 source.bytes source.base=0
  pipeline : Pipeline

def Recurrent.input (p : Recurrent) : BroadcastInput .recurrent := ⟨p.source.bytes,p.source.base⟩

theorem Recurrent.pointer (p : Recurrent) : p.input.base+(dispatch .recurrent p.pipeline).inputByteOffset=p.source.base := rfl

theorem Recurrent.input_raw (p : Recurrent) (i : Fin (elements .recurrent)) :
    p.input.read i=0 := p.rawZero

theorem Recurrent.output_pointer (p : Recurrent) :
    p.layout.recurrentBase+(dispatch .recurrent p.pipeline).outputByteOffset=p.layout.recurrentBase := rfl

theorem Recurrent.checked (p : Recurrent) : InitialRecurrentSource.Checked p.source p.layout p.fresh p.rawZero :=
  InitialRecurrentSource.checked p.source p.layout p.fresh p.rawZero

structure Kv where
  source : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues
  destination : Nat
  allocation : ScalarCopyQuadSemantics.Allocation source.base destination
  pipeline : Pipeline

def Kv.input (p : Kv) : BroadcastInput .kv := ⟨p.source.bytes,p.source.base⟩

theorem Kv.pointer (p : Kv) : p.input.base+(dispatch .kv p.pipeline).inputByteOffset=p.source.base := rfl

theorem Kv.input_read (p : Kv) (i : Fin (elements .kv)) :
    p.input.read i=0 := ScalarCopyQuadSourceRefinement.scalar_zero p.source

theorem Kv.output_pointer (p : Kv) :
    p.destination+(dispatch .kv p.pipeline).outputByteOffset=p.destination := rfl

def Kv.checked (p : Kv) : ScalarCopyQuadSourceRefinement.Checked p.source p.destination p.allocation :=
  ScalarCopyQuadSourceRefinement.canonical p.source p.destination p.allocation

end Inference.Kernels.Copy.ScalarFullHostSelection
