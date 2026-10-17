import kernels.copy.KvRowGeneralCopyBinding
import kernels.copy.GeneralCopy2DSourceRefinement

namespace Inference.Kernels.Copy.GeneralCopy2DHostDispatch
open Contracts.Mlx GeneralCopy2DSemantics KvRowDispatchGeometry
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange

-- Explicit semantics of a finite dispatch_threads grid. These are uint32
-- coordinates with the selected grid bounds, not arbitrary logical labels.
-- Actual Metal issuance/completion corresponding to this operational protocol
-- remains a hardware/runtime boundary; no device execution is inferred here.
structure GridId where
  x : BitVec 32
  y : BitVec 32
  z : BitVec 32
  xBound : x.toNat<256
  yBound : y.toNat<4
  zZero : z=0
  deriving DecidableEq

def GridId.label (id : GridId) : Label := (⟨id.y.toNat,id.yBound⟩,⟨id.x.toNat,id.xBound⟩)

def GridId.ofLabel (label : Label) : GridId where
  x := BitVec.ofNat 32 label.2.val
  y := BitVec.ofNat 32 label.1.val
  z := 0
  xBound := by rw [BitVec.toNat_ofNat,Nat.mod_eq_of_lt (by have := label.2.isLt; omega)]; exact label.2.isLt
  yBound := by rw [BitVec.toNat_ofNat,Nat.mod_eq_of_lt (by have := label.1.isLt; omega)]; exact label.1.isLt
  zZero := rfl

theorem GridId.label_ofLabel (label : Label) : (ofLabel label).label=label := by
  apply Prod.ext <;> apply Fin.ext
  · change label.1.val%2^32=label.1.val
    exact Nat.mod_eq_of_lt (by have := label.1.isLt; omega)
  · change label.2.val%2^32=label.2.val
    exact Nat.mod_eq_of_lt (by have := label.2.isLt; omega)

theorem GridId.ofLabel_label (id : GridId) : ofLabel id.label=id := by
  cases id with
  | mk x y z xb yb zz =>
    cases zz
    simp [ofLabel,label]

def gridEquivalence : GridId ≃ Label :=
  ⟨GridId.label,GridId.ofLabel,GridId.ofLabel_label,GridId.label_ofLabel⟩

def gridIds : List GridId := (Copy2D.labels 4 256).map GridId.ofLabel

theorem grid_covers (id : GridId) : id∈gridIds := by
  exact List.mem_map.mpr ⟨id.label,List.mem_product.mpr ⟨List.mem_finRange _,List.mem_finRange _⟩,GridId.ofLabel_label id⟩

theorem grid_labels : gridIds.map GridId.label=Copy2D.labels 4 256 := by
  simp only [gridIds,List.map_map,Function.comp_def,GridId.label_ofLabel]
  exact List.map_id _

theorem grid_distinct : gridIds.Nodup :=
  ((List.nodup_finRange 4).product (List.nodup_finRange 256)).map
    (fun _ _ same => by have := congrArg GridId.label same; simpa only [GridId.label_ofLabel] using this)

theorem grid_count : gridIds.length=1024 := by
  simp only [gridIds,List.length_map,Copy2D.labels]
  change ((List.finRange 4) ×ˢ (List.finRange 256)).length=1024
  rw [List.length_product,List.length_finRange,List.length_finRange]

def issuePrograms : List (List GridId) := gridIds.map (fun id => [id])

-- Singleton per-ID programs give a small-step choose-an-unissued-ID protocol.
-- Each completed native invocation ID is issued exactly once; the protocol
-- does not assume an ordering, a final copy heap, or a label permutation.
structure Dispatch where
  order : List GridId
  remaining : List (List GridId)
  execution : ThreadgroupWrites.Executes issuePrograms order remaining
  completed : ThreadgroupWrites.AtBarrier remaining

private theorem singleton_flatten {α : Type} (ids : List α) : (ids.map (fun id => [id])).flatten=ids := by
  induction ids with
  | nil => rfl
  | cons id ids ih => simp only [List.map_cons,List.flatten_cons,List.singleton_append,ih]

theorem Dispatch.issued_once (dispatch : Dispatch) : dispatch.order.Perm gridIds := by
  have h := ThreadgroupWrites.completed_schedule dispatch.execution dispatch.completed
  simpa only [issuePrograms,singleton_flatten] using h

theorem Dispatch.labels (dispatch : Dispatch) :
    (dispatch.order.map GridId.label).Perm (Copy2D.labels 4 256) := by
  have h := dispatch.issued_once.map GridId.label
  rw [grid_labels] at h
  exact h

theorem Dispatch.complete (dispatch : Dispatch) (id : GridId) : id∈dispatch.order :=
  dispatch.issued_once.mem_iff.mpr (grid_covers id)

theorem Dispatch.distinct (dispatch : Dispatch) : dispatch.order.Nodup :=
  dispatch.issued_once.nodup_iff.mpr grid_distinct

theorem Dispatch.count (dispatch : Dispatch) : dispatch.order.length=1024 :=
  dispatch.issued_once.length_eq.trans grid_count

def Dispatch.canonical : Dispatch where
  order := issuePrograms.flatten
  remaining := List.replicate issuePrograms.length []
  execution := ThreadgroupWrites.canonical _
  completed := ThreadgroupWrites.canonical_barrier _

-- The logical-body schedule and its completeness are DERIVED from the finite
-- grid scheduler, rather than accepted as a caller-supplied label permutation.
def Dispatch.launch (dispatch : Dispatch) (bounds : Bounds layout) (before : ByteMemory.Bytes) :
    GeneralCopy2DSourceRefinement.Launch layout before
      (GeneralCopy2DSourceRefinement.run layout (dispatch.order.map GridId.label) before) :=
  ⟨_,dispatch.labels,GeneralCopy2DSourceRefinement.run_bodies bounds _ before⟩

theorem Dispatch.refines (dispatch : Dispatch) (bounds : Bounds layout)
    (separate : GeneralCopy2DInterleaving.Separate layout) (trace : Copy2DMemory.Trace layout 4 256) :
    GeneralCopy2DSourceRefinement.run layout (dispatch.order.map GridId.label) trace.before=trace.memory :=
  GeneralCopy2DSourceRefinement.launch_eq bounds separate trace (dispatch.launch bounds trace.before)

-- Manual translation of the selected GeneralGeneral/static-offset host
-- branch. Source-byte guards check its reviewed fragments; they do not prove
-- the C++ translation, native metadata extraction or compiler correctness.
def specializationTag (dimensions : Nat) (isLarge : Bool) : String :=
  if dimensions≤3 then toString dimensions else "n"++toString (if isLarge then 4 else 2)

inductive Dtype where
  | bfloat16 | float16 | float32
  deriving DecidableEq, Repr

def dtypeName : Dtype → String
  | .bfloat16 => "bfloat16"
  | .float16 => "float16"
  | .float32 => "float32"

def metalType : Dtype → String
  | .bfloat16 => "bfloat16_t"
  | .float16 => "float16_t"
  | .float32 => "float"

def kernelNameFor (dimensions : Nat) (isLarge dynamic : Bool) (input output : Dtype) : String :=
  "gg"++specializationTag dimensions isLarge++(if isLarge then "large" else "")++
    (if dynamic then "_dynamic" else "")++"_copy"++dtypeName input++dtypeName output

def kernelName (dimensions : Nat) (isLarge dynamic : Bool) : String :=
  kernelNameFor dimensions isLarge dynamic .bfloat16 .bfloat16

instance (sourceDataSize capacity : Nat) : Decidable (KvRowDispatchGeometry.large sourceDataSize capacity) := by
  unfold KvRowDispatchGeometry.large
  infer_instance

def selectedKernel (collapsed : List Axis) (sourceDataSize capacity : Nat) : String :=
  kernelName collapsed.length (decide (KvRowDispatchGeometry.large sourceDataSize capacity)) false

theorem selected_kernel (source : State.KvCopy.Source next) (descriptor : SourceDescriptor source)
    (sourceBatch sourceTime capacity n : Nat) (selection : Selection source descriptor sourceBatch sourceTime capacity n) :
    selectedKernel (collapse (axes sourceBatch source.rowStride sourceTime source.columnStride (4*capacity*256) capacity) (2^31-1))
      descriptor.dataSize capacity="gg2_copybfloat16bfloat16" := by
  have shape := congrArg List.length selection.shape
  simp only [List.length_map,List.length_cons,List.length_nil] at shape
  simp only [selectedKernel,shape,selection.small,decide_false,kernelName]
  rfl

-- JIT source uses the suffix after the first underscore as its library key;
-- it emits gg2_<library> with function copy_gg_nd2 and explicit IdxT=int.
-- No-JIT lookup uses the same selected kernel name directly. Actual library
-- caching/loading and compilation are external, rather than postulated proofs.
def libraryName (name : String) : String :=
  let rest := name.toList.dropWhile (fun c => c≠'_')
  if rest=[] then name else String.ofList rest.tail

def templateDefinition (name function : String) (types : List String) : String :=
  let applied := function++"<"++String.intercalate ", " types++">"
  "\ntemplate [[host_name(\""++name++"\")]] [[kernel]] decltype("++applied++") "++applied++";\n"

structure Lookup where
  kernel : String
  library : String
  entry : String
  templateArguments : List String
  emitted : String
  deriving DecidableEq, Repr

def selectedLookup : Lookup :=
  let name := kernelName 2 false false
  let library := libraryName name
  let entry := "copy_gg_nd2"
  let types := [metalType .bfloat16,metalType .bfloat16,"int"]
  ⟨name,library,entry,types,templateDefinition ("gg2_"++library) entry types⟩

theorem lookup_selected :
    selectedLookup=⟨"gg2_copybfloat16bfloat16","copybfloat16bfloat16","copy_gg_nd2",
      ["bfloat16_t","bfloat16_t","int"],
      "\ntemplate [[host_name(\"gg2_copybfloat16bfloat16\")]] [[kernel]] decltype(copy_gg_nd2<bfloat16_t, bfloat16_t, int>) copy_gg_nd2<bfloat16_t, bfloat16_t, int>;\n"⟩ := by decide +kernel

-- BF16 cast_to<U>(T) is interpreted as same-type raw16 identity by the parsed
-- body. Binding that typed interpretation to Metal bfloat16_t remains explicit.
inductive SlotValue where
  | pointer : Nat → SlotValue
  | strides : List Nat → SlotValue
  deriving DecidableEq, Repr

def slots (arguments : KvRowGeneralCopyBinding.Arguments) : List (Nat × SlotValue) :=
  [(0,.pointer arguments.input),(1,.pointer arguments.output),
    (3,.strides arguments.inputStrides),(4,.strides arguments.outputStrides)]

theorem slots_layout (source : State.KvCopy.Source next) (descriptor : SourceDescriptor source)
    (sourcePointer destinationPointer : KvRowGeneralCopyBinding.Pointer)
    (base sourceBatch sourceTime capacity n : Nat)
    (inputBinding : sourcePointer.address 0=source.base) (outputBinding : destinationPointer.address 0=base)
    (selection : Selection source descriptor sourceBatch sourceTime capacity n) :
    slots (KvRowGeneralCopyBinding.arguments source sourcePointer destinationPointer sourceBatch sourceTime capacity n)=
      [(0,.pointer source.base),(1,.pointer (base+2*(n*256))),
        (3,.strides [source.rowStride,source.columnStride]),(4,.strides [capacity*256,1])] := by
  rw [KvRowGeneralCopyBinding.arguments_layout source descriptor _ _ _ _ _ _ _ inputBinding outputBinding selection]
  rfl

-- Exact selected dispatch dimensions are derived from the host algorithm.
-- The pipeline must report1024 max threads: the native host throws otherwise.
structure Host (source : State.KvCopy.Source next) (descriptor : SourceDescriptor source)
    (sourceBatch sourceTime capacity n : Nat) where
  selection : Selection source descriptor sourceBatch sourceTime capacity n
  sourcePointer : KvRowGeneralCopyBinding.Pointer
  destinationPointer : KvRowGeneralCopyBinding.Pointer
  base : Nat
  inputBinding : sourcePointer.address 0=source.base
  outputBinding : destinationPointer.address 0=base
  sourceOffset : sourcePointer.arrayOffset<2^63
  destinationRange : destinationPointer.arrayOffset+2*(4*capacity*256)≤2^63
  room : n<capacity
  inputDtype : Dtype
  outputDtype : Dtype
  inputBF16 : inputDtype=.bfloat16
  outputBF16 : outputDtype=.bfloat16
  pipelineMax : Nat
  pipelineCompatible : pipelineMax=1024

def Host.arguments (host : Host source descriptor sourceBatch sourceTime capacity n) : KvRowGeneralCopyBinding.Arguments :=
  KvRowGeneralCopyBinding.arguments source host.sourcePointer host.destinationPointer sourceBatch sourceTime capacity n

theorem Host.bound_slots (host : Host source descriptor sourceBatch sourceTime capacity n) :
    slots host.arguments=[(0,.pointer source.base),(1,.pointer (host.base+2*(n*256))),
      (3,.strides [source.rowStride,source.columnStride]),(4,.strides [capacity*256,1])] :=
  slots_layout source descriptor _ _ _ _ _ _ _ host.inputBinding host.outputBinding host.selection

theorem Host.kernel_lookup (host : Host source descriptor sourceBatch sourceTime capacity n) :
    selectedKernel (collapse (axes sourceBatch source.rowStride sourceTime source.columnStride (4*capacity*256) capacity) (2^31-1))
      descriptor.dataSize capacity=selectedLookup.kernel := by
  rw [selected_kernel source descriptor _ _ _ _ host.selection]
  rfl

def Host.nativeKernel (host : Host source descriptor sourceBatch sourceTime capacity n) : String :=
  let collapsed := collapse (axes sourceBatch source.rowStride sourceTime source.columnStride (4*capacity*256) capacity) (2^31-1)
  kernelNameFor collapsed.length (decide (KvRowDispatchGeometry.large descriptor.dataSize capacity)) false
    host.inputDtype host.outputDtype

theorem Host.native_kernel_lookup (host : Host source descriptor sourceBatch sourceTime capacity n) :
    host.nativeKernel=selectedLookup.kernel := by
  simpa only [Host.nativeKernel,host.inputBF16,host.outputBF16,selectedKernel,kernelName] using host.kernel_lookup

theorem Host.native_template_types (host : Host source descriptor sourceBatch sourceTime capacity n) :
    [metalType host.inputDtype,metalType host.outputDtype,"int"]=selectedLookup.templateArguments := by
  rw [host.inputBF16,host.outputBF16]
  rfl

theorem Host.offsets (host : Host source descriptor sourceBatch sourceTime capacity n) :
    host.sourcePointer.arrayOffset+0<2^63 ∧ (256*n)*2<2^63 ∧
      host.destinationPointer.arrayOffset+(256*n)*2<2^63 :=
  KvRowGeneralCopyBinding.offset_bounds _ _ _ _ host.sourceOffset host.destinationRange host.room

theorem Host.grid (host : Host source descriptor sourceBatch sourceTime capacity n) :
    KvRowDispatchGeometry.grid
      (collapse (axes sourceBatch source.rowStride sourceTime source.columnStride (4*capacity*256) capacity) (2^31-1))=⟨256,4,1⟩ :=
  host.selection.dispatch

theorem Host.id_bounds (host : Host source descriptor sourceBatch sourceTime capacity n) (id : GridId) :
    let dims := KvRowDispatchGeometry.grid
      (collapse (axes sourceBatch source.rowStride sourceTime source.columnStride (4*capacity*256) capacity) (2^31-1))
    id.x.toNat<dims.x ∧ id.y.toNat<dims.y ∧ id.z.toNat<dims.z := by
  dsimp only
  rw [host.grid]
  exact ⟨id.xBound,id.yBound,by rw [id.zZero]; decide⟩

-- GridId exactly describes that selected dispatch, so completed issuance
-- derives the launch/readback proof without a caller label-permutation premise.
theorem Host.dispatch_refines (host : Host source descriptor sourceBatch sourceTime capacity n)
    (bounds : Bounds (State.KvCopy.layout source host.base capacity n))
    (separate : GeneralCopy2DInterleaving.Separate (State.KvCopy.layout source host.base capacity n))
    (dispatch : Dispatch) (trace : Copy2DMemory.Trace (State.KvCopy.layout source host.base capacity n) 4 256) :
    GeneralCopy2DSourceRefinement.run (State.KvCopy.layout source host.base capacity n)
      (dispatch.order.map GridId.label) trace.before=trace.memory :=
  dispatch.refines bounds separate trace


-- Exact reviewed host fragments. The external byte guard checks these plus
-- full-file SHA256 pins; none is asserted to be a parsed C++ semantics.
def kernelBranchSource : String := r#"  if (ctype == CopyType::General || ctype == CopyType::GeneralGeneral) {
    if (shape.size() <= MAX_COPY_SPECIALIZED_DIMS) {
      kernel_name += std::to_string(shape.size());
    } else {
      work_per_thread = large ? 4 : 2;
      concatenate(kernel_name, "n", std::to_string(work_per_thread));
    }
    if (large) {
      kernel_name += "large";
    }
    if (dynamic) {
      kernel_name += "_dynamic";
      if (ctype != CopyType::GeneralGeneral) {
        throw std::runtime_error(
            "[Copy::eval_gpu] Dynamic output offset requires GeneralGeneral copy");
      }
    }
  } else {
    work_per_thread = get_work_per_thread(out.dtype(), out.data_size());
    if (!large && work_per_thread > 1) {
      kernel_name += "n";
    }
  }
  concatenate(kernel_name, "_copy", type_to_name(in), type_to_name(out));
"#

def pointerBindingSource : String := r#"  inp_offset *= size_of(in.dtype());
  out_offset *= size_of(out.dtype());

  compute_encoder.set_input_array(in, 0, inp_offset);
  compute_encoder.set_output_array(out, 1, out_offset);

"#

def strideBindingSource : String := r#"    compute_encoder.set_vector_bytes(strides_in, ndim, 3);
    if (ctype == CopyType::GeneralGeneral) {
      compute_encoder.set_vector_bytes(strides_out, ndim, 4);
    }"#

def encoderBindingSource : String := r#"  get_command_encoder()->setBuffer(a_buf, a.offset() + offset, idx);"#

def jitLibrarySource : String := r#"MTL::ComputePipelineState* get_copy_kernel(
    metal::Device& d,
    const std::string& kernel_name,
    const array& in,
    const array& out) {
  std::string lib_name = kernel_name.substr(kernel_name.find("_") + 1);
  auto lib = d.get_library(lib_name, [&]() {
    std::string kernel_source = metal::utils();
    kernel_source += metal::copy();
    auto in_type = get_type_string(in.dtype());
    auto out_type = get_type_string(out.dtype());"#

def jitEntrySource : String := r#"    kernel_source += get_template_definition(
        "gg2_" + lib_name, "copy_gg_nd2", in_type, out_type, "int");"#

def noJitLookupSource : String := r#"MTL::ComputePipelineState* get_copy_kernel(
    metal::Device& d,
    const std::string& kernel_name,
    const array&,
    const array&) {
  return d.get_kernel(kernel_name);
}"#

def bfloatTypeSource : String := r#"    case bfloat16:
      return "bfloat16_t";"#

def bfloatNameSource : String := r#"    case bfloat16:
      tname = "bfloat16";"#

def templateFormatSource : String := r#"  return fmt::format(
      "\ntemplate [[host_name(\"{0}\")]] [[kernel]] decltype({1}) {1};\n",
      name,
      s.str());"#

def precompiledEntrySource : String := r#"  instantiate_kernel("gg2_copy" #tname, copy_gg_nd2, type, type, int)                 \"#

def precompiledTypeSource : String := r#"instantiate_copy_itype(bfloat16, bfloat16_t)"#

def prepareSliceSource : String := r#"  for (int i = 0; i < in.ndim(); ++i) {
    data_offset += start_indices[i] * in.strides()[i];
    inp_strides[i] = in.strides()[i] * strides[i];
  }"#

end Inference.Kernels.Copy.GeneralCopy2DHostDispatch
