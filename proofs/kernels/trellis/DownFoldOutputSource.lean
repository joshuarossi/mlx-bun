import kernels.trellis.DownFoldSource
namespace Inference.Kernels.Trellis.DownFoldOutputSource
open Contracts.Mlx DownFoldVectorMemory
set_option maxRecDepth 10000

def component (abi : VectorLoad)
    (trace : DownDevice.Trace load before base words k scale input)
    (reduce : DownExecution.SimdReduction) (base group thread index : Nat) : Option (List HalfMemory.Store) :=
  if bound : index<4 then DownFoldSource.operation abi trace reduce base group thread ⟨index,bound⟩ else none

theorem component_selected (abi : VectorLoad)
    (trace : DownDevice.Trace load before base words k scale input)
    (reduce : DownExecution.SimdReduction) (base group thread index : Nat)
    (hg : group<160) (ht : thread<256) (hi : index<4) :
    component abi trace reduce base group thread index=some
      (if thread%32=0 then [DownOutput.entry base (DownOutput.foldValues trace reduce) group thread index] else []) := by
  rw [component,dite_eq_left hi]
  exact DownFoldSource.operation_current abi trace reduce base group thread hg ht ⟨index,hi⟩

def threadStores (abi : VectorLoad)
    (trace : DownDevice.Trace load before base words k scale input)
    (reduce : DownExecution.SimdReduction) (base group thread : Nat) : Option (List HalfMemory.Store) :=
  DownFoldSource.components.bind (fun indices =>
    (indices.mapM (component abi trace reduce base group thread)).map List.flatten)

theorem thread_stores (abi : VectorLoad)
    (trace : DownDevice.Trace load before base words k scale input)
    (reduce : DownExecution.SimdReduction) (base group thread : Nat)
    (hg : group<160) (ht : thread<256) :
    threadStores abi trace reduce base group thread=some
      (DownOutput.threadStores base (DownOutput.foldValues trace reduce) group thread) := by
  rw [threadStores,DownFoldSource.components_selected,Option.bind_some]
  change (([0,1,2,3].mapM (component abi trace reduce base group thread)).map List.flatten)=_
  simp only [List.mapM_cons,List.mapM_nil,
    component_selected abi trace reduce base group thread 0 hg ht (by decide),
    component_selected abi trace reduce base group thread 1 hg ht (by decide),
    component_selected abi trace reduce base group thread 2 hg ht (by decide),
    component_selected abi trace reduce base group thread 3 hg ht (by decide)]
  by_cases active : thread%32=0
  · simp only [active,ite_true,DownOutput.threadStores]
    rfl
  · simp only [active,ite_false,DownOutput.threadStores]
    rfl

def programs (abi : VectorLoad)
    (trace : DownDevice.Trace load before base words k scale input)
    (reduce : DownExecution.SimdReduction) (base : Nat) : List (List HalfMemory.Store) :=
  ((List.range 160).product (List.range 256)).map (fun pair =>
    (threadStores abi trace reduce base pair.1 pair.2).getD [])

theorem programs_eq (abi : VectorLoad)
    (trace : DownDevice.Trace load before base words k scale input)
    (reduce : DownExecution.SimdReduction) (base : Nat) :
    programs abi trace reduce base=DownOutput.programs base (DownOutput.foldValues trace reduce) := by
  unfold programs DownOutput.programs
  apply List.map_congr_left
  intro pair member
  obtain ⟨hg,ht⟩:=List.mem_product.mp member
  rw [thread_stores abi trace reduce base pair.1 pair.2 (List.mem_range.mp hg) (List.mem_range.mp ht)]
  rfl

theorem source_execution (abi : VectorLoad)
    (trace : DownDevice.Trace load before base words k scale input)
    (reduce : DownExecution.SimdReduction)
    (destination : DownOutput.Trace (DownOutput.foldValues trace reduce)) :
    ThreadgroupWrites.Executes (programs abi trace reduce destination.base)
      destination.schedule destination.remaining := by
  rw [programs_eq]
  exact destination.execution

/-- Raw BF16 output bits in the same destination heap, without converting
    an arbitrary NaN bit pattern through a scalar floating representation. -/
theorem current_bits (abi : VectorLoad)
    (trace : DownDevice.Trace load before base words k scale input)
    (reduce : DownExecution.SimdReduction)
    (destination : DownOutput.Trace (DownOutput.foldValues trace reduce))
    (index : Nat) (bound : index<5120) :
    HalfMemory.load destination.memory (destination.base+2*index)=
      (DownOutput.foldValues trace reduce index).bits := by
  have execution:=source_execution abi trace reduce destination
  rw [programs_eq] at execution
  unfold DownOutput.Trace.memory
  rw [HalfMemory.execute_load _ _ _ (by have := destination.aligned; omega),
    show (destination.base+2*index)/2=destination.base/2+index by have := destination.aligned; omega]
  exact DownOutput.stored (HalfMemory.view destination.before) destination.base _ destination.schedule destination.remaining
    execution destination.completed index bound

theorem current_bytes (abi : VectorLoad)
    (trace : DownDevice.Trace load before base words k scale input)
    (reduce : DownExecution.SimdReduction)
    (destination : DownOutput.Trace (DownOutput.foldValues trace reduce))
    (index offset : Nat) (bound : index<5120) (offsetBound : offset<2) :
    destination.memory (destination.base+2*index+offset)=
      HalfMemory.byte (DownOutput.foldValues trace reduce index).bits offset := by
  have bits:=congrArg (fun value => HalfMemory.byte value offset) (current_bits abi trace reduce destination index bound)
  rw [HalfMemory.byte_load _ _ _ offsetBound] at bits
  exact bits

end Inference.Kernels.Trellis.DownFoldOutputSource
