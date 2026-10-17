import kernels.sampling.ArgmaxStorage
import kernels.sampling.NormalizedArgmaxLayout

namespace Inference.Kernels.Sampling.ArgmaxReductionDevice
open Contracts.Mlx ArgmaxPairs NormalizedArgmaxLayout
set_option maxRecDepth 10000

def thread (group : Fin 4) (lane : Fin 32) : Fin 128 := ⟨group.val*32+lane.val, by omega⟩
def simd (input : Fin 128 → Candidate) (group : Fin 4) : Candidate := tree (fun lane => input (thread group lane)) simdTree

theorem tree_rename (input : Fin m → Candidate) (f : Fin n → Fin m) (t : Reduction.Tree n) :
    tree input (rename f t)=tree (fun i => input (f i)) t := by
  induction t with
  | leaf i => rfl
  | add left right hl hr => simp only [rename, tree, hl, hr]

theorem tree_substitute (input : Fin m → Candidate) (subtrees : Fin n → Reduction.Tree m) (t : Reduction.Tree n) :
    tree input (substitute subtrees t)=tree (fun i => tree input (subtrees i)) t := by
  induction t with
  | leaf i => rfl
  | add left right hl hr => simp only [substitute, tree, hl, hr]

theorem group_eq (input : Fin 128 → Candidate) (group : Fin 4) : simd input group=tree input (groupTree group) :=
  (tree_rename input (thread group) simdTree).symm

theorem group_valid (input : Fin 128 → Candidate) (valid : ∀ i, ArgmaxStorage.Valid (input i)) (group : Fin 4) :
    ArgmaxStorage.Valid (simd input group) := ArgmaxStorage.tree_valid _ simdTree (fun lane => valid (thread group lane))

structure Trace (input : Fin 128 → Candidate) where
  scratch : ArgmaxStorage.Trace (simd input)

def Trace.canonical (input : Fin 128 → Candidate) : Trace input := ⟨ArgmaxStorage.Trace.canonical _ (by decide)⟩

variable {input : Fin 128 → Candidate}

def Trace.output (trace : Trace input) : Candidate := tree trace.scratch.read mergeTree

theorem Trace.output_eq (trace : Trace input) (valid : ∀ i, ArgmaxStorage.Valid (input i)) :
    trace.output=tree input threadgroupTree := by
  have read : trace.scratch.read=simd input := funext (trace.scratch.read_correct (group_valid input valid))
  unfold Trace.output
  rw [read]
  unfold threadgroupTree
  rw [tree_substitute]
  have same : simd input=(fun group => tree input (groupTree group)) := funext (group_eq input)
  rw [same]

theorem Trace.output_valid (trace : Trace input) (valid : ∀ i, ArgmaxStorage.Valid (input i)) : ArgmaxStorage.Valid trace.output := by
  rw [trace.output_eq valid]
  exact ArgmaxStorage.tree_valid _ _ valid

theorem store_owner (group : Fin 4) : (thread group 0).val%32=0 ∧ (thread group 0).val/32=group.val := by
  simp only [thread, Fin.val_zero]
  omega

end Inference.Kernels.Sampling.ArgmaxReductionDevice
