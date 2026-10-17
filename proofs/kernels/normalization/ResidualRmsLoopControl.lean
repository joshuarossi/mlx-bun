import kernels.normalization.ResidualRmsLoopSyntax
import contracts.mlx.NormalizationReduction

namespace Inference.Kernels.Normalization.ResidualRmsLoopControl
open Contracts.Mlx ResidualRmsLoopSyntax
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] List.finRange

def count : Nat := 5120
def modulus : Nat := 2^32

-- Uint arithmetic is modeled at each source multiplication/addition. Fuel is
-- evaluator resource, not an assumed successful result: exhaustion is none.
def column (control : Control) (r thread i : Nat) : Nat :=
  ((r+(thread*control.columnMultiplier)%modulus)%modulus+i)%modulus

def emit (value : Nat) : Option (Fin count) :=
  if h : value<count then some ⟨value,h⟩ else none

def inner (control : Control) (thread r : Nat) : Nat → Nat → Option (List (Fin count))
  | 0,_ => none
  | fuel+1,i =>
    if i<control.innerLimit%modulus then do
      let rest ←inner control thread r fuel ((i+1)%modulus)
      pure ((emit (column control r thread i)).toList++rest)
    else some []

def outer (control : Control) (threads thread : Nat) : Nat → Nat → Option (List (Fin count))
  | 0,_ => none
  | fuel+1,r =>
    if r<count then do
      let first ←inner control thread r (control.innerLimit+1) (control.innerStart%modulus)
      let rest ←outer control threads thread fuel ((r+(threads*control.outerMultiplier)%modulus)%modulus)
      pure (first++rest)
    else some []

def executeSource (source : String) (thread : Fin 1024) : Option (List (Fin count)) := do
  let control ←parseBody source
  outer ResidualRmsLoopSyntax.control 1024 thread.val 3 (control.outerStart%modulus)

-- Use the schedule's actual guarded visit expression, retaining element order.
def visits (iteration : Nat) (thread : Fin 1024) : List (Fin count) :=
  (List.finRange 4).filterMap (fun element =>
    NormalizationSchedule.columnIndex count ⟨iteration,thread,element⟩)

theorem late_empty (iteration : Nat) (late : 2 ≤ iteration) (thread : Fin 1024) : visits iteration thread=[] := by
  apply List.filterMap_eq_nil_iff.mpr
  intro element _
  have outside : ¬ NormalizationSchedule.address (NormalizationSchedule.Visit.mk iteration thread element)<count := by
    change ¬(iteration*4096+thread.val*4+element.val<5120)
    omega
  simp only [NormalizationSchedule.columnIndex,dite_eq_right outside]

theorem threadColumns_two (thread : Fin 1024) :
    NormalizationSchedule.threadColumns count thread=visits 0 thread++visits 1 thread := by
  have asFlatMap : NormalizationSchedule.threadColumns count thread=
      (List.finRange count).flatMap (fun iteration => visits iteration.val thread) := by
    simp only [NormalizationSchedule.threadColumns,List.product,List.map_flatMap,List.map_map,
      List.filterMap_flatMap,Function.comp_def,visits,List.filterMap_map]
  rw [asFlatMap]
  change (List.finRange 5120).flatMap (fun iteration => visits iteration.val thread)=_
  rw [@List.finRange_succ 5119,List.flatMap_cons,List.flatMap_map]
  rw [@List.finRange_succ 5118,List.flatMap_cons,List.flatMap_map]
  have tail : (List.finRange 5118).flatMap (fun i => visits (i.succ.succ.val) thread)=[] := by
    apply List.flatMap_eq_nil_iff.mpr
    intro i _
    exact late_empty _ (by simp only [Fin.val_succ]; omega) thread
  simpa only [Function.comp_def,Fin.val_zero,Fin.val_succ,Nat.zero_add,tail,List.append_nil] using
    (show visits 0 thread++(visits 1 thread++(List.finRange 5118).flatMap
      (fun i => visits i.succ.succ.val thread))=visits 0 thread++visits 1 thread by rw [tail,List.append_nil])

theorem inner_execution (thread : Fin 1024) (r : Nat) (smallR : r≤4096) :
    inner ResidualRmsLoopSyntax.control thread.val r 5 0=
      some ((List.finRange 4).filterMap (fun element => emit (r+thread.val*4+element.val))) := by
  have smallCol (i : Nat) (bound : i≤3) : r+thread.val*4+i<4294967296 := by
    have := thread.isLt; omega
  have smallBase : r+thread.val*4<4294967296 := by have := smallCol 0 (by decide); omega
  have four : List.finRange 4=([0,1,2,3] : List (Fin 4)) := by decide +kernel
  simp [inner,ResidualRmsLoopSyntax.control,column,four,modulus,Nat.mod_eq_of_lt smallBase,
    Nat.mod_eq_of_lt (smallCol 1 (by decide)),Nat.mod_eq_of_lt (smallCol 2 (by decide)),
    Nat.mod_eq_of_lt (smallCol 3 (by decide)),List.filterMap_eq_flatMap_toList]

theorem outer_execution (thread : Fin 1024) :
    outer ResidualRmsLoopSyntax.control 1024 thread.val 3 0=some (visits 0 thread++visits 1 thread) := by
  have first := inner_execution thread 0 (by omega)
  have second := inner_execution thread 4096 (by omega)
  change (do
    let a ←inner ResidualRmsLoopSyntax.control thread.val 0 5 0
    let b ←inner ResidualRmsLoopSyntax.control thread.val 4096 5 0
    pure (a++(b++[])))=some (visits 0 thread++visits 1 thread)
  rw [first,second]
  simp [visits,NormalizationSchedule.columnIndex,NormalizationSchedule.address,emit]

-- Exact ordered equivalence, so floating accumulation order is preserved.
theorem source_columns (thread : Fin 1024) :
    executeSource sourceBody thread=some (NormalizationSchedule.threadColumns count thread) := by
  unfold executeSource
  rw [parsed_body]
  change outer ResidualRmsLoopSyntax.control 1024 thread.val 3 0=_
  rw [outer_execution,threadColumns_two]

end Inference.Kernels.Normalization.ResidualRmsLoopControl
