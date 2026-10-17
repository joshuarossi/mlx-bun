import kernels.copy.VectorCopySourceRefinement

namespace Inference.Kernels.Copy.VectorCopyHostSelection
open Contracts.Mlx VectorCopySemantics

-- Manual translation of the pinned common/copy.h Vector allocation branch,
-- metal/copy.cpp nonlarge Vector branch, utils.h work threshold, and copy.metal
-- BF16 instantiation. This is not a parser of host C++, an allocator ownership
-- theorem, a Metal compiler theorem, or a hardware dispatch/coherence theorem.
-- dispatch_threads uses an exact grid, rather than a rounded dispatch_threadgroups
-- grid. Hardware issuance of precisely these grid IDs remains an external link.
def wrapperSource : String := r#"void copy_gpu_inplace(
    const array& in,
    array& out,
    CopyType ctype,
    const Stream& s) {
  assert(in.shape() == out.shape());
  return copy_gpu_inplace(
      in, out, in.shape(), in.strides(), out.strides(), 0, 0, ctype, s);
}"#

-- This exact wrapper selects literal zero offsets. The translation below is
-- manual; the companion guard checks wrapper bytes and pinned source hashes.
def wrapperOffsets : Nat × Nat := (0,0)

def workPerThread (itemBytes size : Nat) : Nat :=
  if size < 65536 then 1 else max 1 (8 / itemBytes)

def ceilDiv (n d : Nat) : Nat := (n+d-1)/d

def kernelName (size itemBytes : Nat) : String :=
  if size > 4294967295 then "v2_copybfloat16bfloat16"
  else if workPerThread itemBytes size > 1 then "vn_copybfloat16bfloat16"
  else "v_copybfloat16bfloat16"

structure Pipeline where
  maxThreads : Nat
  positive : 0 < maxThreads

structure Dispatch where
  grid : Nat
  group : Nat
  sizeArgument : Nat
  inputByteOffset : Nat
  outputByteOffset : Nat
  kernel : String

def dispatch (pipeline : Pipeline) (size inputElements outputElements : Nat) : Dispatch where
  grid := ceilDiv size (workPerThread 2 size)
  group := min pipeline.maxThreads (ceilDiv size (workPerThread 2 size))
  sizeArgument := size
  inputByteOffset := inputElements*2
  outputByteOffset := outputElements*2
  kernel := kernelName size 2

-- Metadata is attached to the actual shared-heap source buffer. In the chosen
-- SliceUpdate route contiguous && size==data_size selects Vector; scalar is
-- excluded by size>1. Source zero payload is optional, never substituted for
-- the actual current indexed loads in the semantics.
structure Slab (values : Fin count → ArrayStorage.BF) where
  buffer : ArrayStorage.BFBuffer values
  logicalSize : Nat
  dataSize : Nat
  contiguous : Bool
  logicalSize_eq : logicalSize=count
  dataSize_eq : dataSize=count
  contiguous_eq : contiguous=true

namespace Slab
variable (slab : Slab values)
theorem selectsVector : slab.contiguous=true ∧ slab.logicalSize=slab.dataSize ∧ slab.dataSize≠1 := by
  rw [slab.logicalSize_eq,slab.dataSize_eq]
  exact ⟨slab.contiguous_eq,rfl,by decide +kernel⟩

theorem output_dataSize : slab.dataSize=count := slab.dataSize_eq

theorem allocation_bytes : slab.dataSize*2=524288 := by rw [slab.dataSize_eq]; rfl

theorem nonempty : 0<slab.logicalSize := by rw [slab.logicalSize_eq]; decide +kernel

theorem notLarge : ¬slab.dataSize>4294967295 := by rw [slab.dataSize_eq]; decide +kernel

theorem work : workPerThread 2 slab.dataSize=4 := by rw [slab.dataSize_eq]; rfl

theorem kernel : kernelName slab.dataSize 2="vn_copybfloat16bfloat16" := by
  rw [slab.dataSize_eq]; rfl

-- The byte-bound zero-offset wrapper selects these physical arguments; this
-- binds native byte pointers to the real attached source/destination bases.
theorem dispatch_exact (pipeline : Pipeline) :
    dispatch pipeline slab.dataSize 0 0 =
      ⟨65536,min pipeline.maxThreads 65536,262144,0,0,"vn_copybfloat16bfloat16"⟩ := by
  rw [slab.dataSize_eq]; rfl

end Slab

theorem group_positive (pipeline : Pipeline) : 0 < (dispatch pipeline count 0 0).group := by
  change 0 < min pipeline.maxThreads 65536
  exact Nat.lt_min.mpr ⟨pipeline.positive,by decide +kernel⟩

theorem group_bounded (pipeline : Pipeline) :
    (dispatch pipeline count 0 0).group ≤ pipeline.maxThreads ∧
    (dispatch pipeline count 0 0).group ≤ (dispatch pipeline count 0 0).grid := by
  exact ⟨Nat.min_le_left _ _,Nat.min_le_right _ _⟩

-- No divisibility assumption on pipeline.maxThreads: dispatch_threads may have
-- a partial final group. Grid IDs remain exactly Fin 65536.
theorem grid_exact (pipeline : Pipeline) : (dispatch pipeline count 0 0).grid=threadCount := rfl

theorem no_tail (thread : Fin threadCount) : thread.val*4+4≤count := by
  have := thread.isLt
  dsimp [threadCount,count] at *
  omega

theorem uint32_and_signed_locals (thread : Fin threadCount) (i : Fin 4) :
    thread.val*4+i.val<count ∧ thread.val*4+i.val<2^32 ∧ i.val+1<2^31 := by
  have := no_tail thread
  have := i.isLt
  dsimp [count] at *
  omega

-- Supplied facts concern only original metadata and fresh physical allocation.
-- There is no output-buffer, completed execution, or final value premise.
structure Allocated (slab : Slab values) where
  destination : Nat
  donatable : Bool
  notDonated : donatable=false
  allocation : Allocation slab.buffer.base destination
  pipeline : Pipeline

variable {values : Fin count → ArrayStorage.BF} {slab : Slab values}

namespace Allocated
variable (plan : Allocated slab)
def launch : Dispatch := dispatch plan.pipeline slab.dataSize wrapperOffsets.1 wrapperOffsets.2

theorem launch_exact : plan.launch=
    ⟨65536,min plan.pipeline.maxThreads 65536,262144,0,0,"vn_copybfloat16bfloat16"⟩ := by
  simp only [launch,wrapperOffsets]
  exact slab.dispatch_exact plan.pipeline

def after : HalfMemory.Bytes :=
  run slab.buffer.base plan.destination (indices (List.finRange threadCount)) slab.buffer.bytes

theorem physical_arguments :
    slab.buffer.base+plan.launch.inputByteOffset=slab.buffer.base ∧
    plan.destination+plan.launch.outputByteOffset=plan.destination := by
  constructor <;> rfl

theorem distinct : slab.buffer.base≠plan.destination := by
  have fresh := plan.allocation.fresh
  dsimp [MemoryRegions.Disjoint,count] at fresh
  omega

theorem parsed_launch : VectorCopyBodySemantics.Launch slab.buffer.base plan.destination
    (List.finRange threadCount) slab.buffer.bytes plan.after :=
  VectorCopyBodySemantics.launch_refines _ _ plan.allocation.destinationAligned _ _

theorem agreement : VectorCopySourceRefinement.Agreement slab.buffer.base plan.destination
    plan.allocation slab.buffer.bytes plan.after
    (VectorCopyInterleaving.canonicalAfter slab.buffer.base plan.destination slab.buffer.bytes) :=
  VectorCopySourceRefinement.canonical_agreement plan.allocation slab.buffer.bytes

theorem read (i : Fin count) :
    HalfMemory.load plan.after (plan.destination+2*i.val)=ArrayStorage.bits (values i) :=
  (VectorCopyBodySemantics.execution_read plan.allocation plan.parsed_launch (List.Perm.refl _) i).trans
    (slab.buffer.attached i)

theorem frame (separate : MemoryRegions.Disjoint plan.destination (2*count) other size)
    (offset : Nat) (bound : offset<size) :
    plan.after (other+offset)=slab.buffer.bytes (other+offset) :=
  VectorCopySemantics.frame plan.allocation _ _ separate offset bound

-- Any completed actual parsed-body launch or ordered separate-event execution
-- has this same heap; execution is never defined by the desired readback.
theorem any_body (execution : VectorCopyBodySemantics.Launch slab.buffer.base plan.destination
    threads slab.buffer.bytes final) (completed : threads.Perm (List.finRange threadCount)) :
    final=plan.after := by
  exact (VectorCopyBodySemantics.execution_refines plan.allocation execution completed).2.trans
    plan.agreement.body_refines.symm

theorem any_events (execution : VectorCopyInterleaving.Executes slab.buffer.base plan.destination
    (VectorCopyInterleaving.initial slab.buffer.bytes) events final)
    (completed : VectorCopyInterleaving.Completed final) : final.memory=plan.after :=
  (VectorCopyInterleaving.copy_refines plan.allocation execution completed).trans
    plan.agreement.body_refines.symm

end Allocated

-- is_donatable(in,out), same BF16 dtype, and the copied shared-buffer identity
-- are explicit host ownership/metadata premises. On that route copy_gpu returns
-- before pipeline lookup or dispatch; there are zero kernel writes.
structure Donated (slab : Slab values) where
  donatable : Bool
  selected : donatable=true

def Donated.output (_plan : Donated slab) : ArrayStorage.BFBuffer values := slab.buffer

theorem Donated.heap_eq (plan : Donated slab) : plan.output.bytes=slab.buffer.bytes := rfl

theorem Donated.base_eq (plan : Donated slab) : plan.output.base=slab.buffer.base := rfl

end Inference.Kernels.Copy.VectorCopyHostSelection
