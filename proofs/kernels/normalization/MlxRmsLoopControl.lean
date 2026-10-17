import kernels.normalization.MlxRmsLoopSyntax
import contracts.mlx.NormalizationReduction

namespace Inference.Kernels.Normalization.MlxRmsLoopControl
open Contracts.Mlx MlxRmsLoopSyntax
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] List.finRange
abbrev count : Nat := 5120

def batch (control : Control) (r thread : Nat) : List Nat :=
  if r+thread*4+4≤count then
    ((List.finRange 4).filter (fun element => control.fullStart≤element.val)).map
      (fun element => r+thread*4+element.val)
  else (List.finRange 4).filterMap (fun element =>
    if control.tailStart≤element.val ∧ r+thread*4+element.val<count then
      some (r+thread*4+element.val) else none)

def enumerate (threads thread : Nat) : Nat → Nat → List Nat
  | 0,_ => []
  | fuel+1,r => batch MlxRmsLoopSyntax.control r thread++enumerate threads thread fuel (r+threads*4)

-- Finite evaluator for the parsed loops. Fuel exhaustion while r is in bounds
-- fails, rather than silently dropping cells. The terminating source program
-- is proved below to fit count iterations for every positive selected lsize.
def outer (control : Control) (threads thread : Nat) : Nat → Nat → Option (List Nat)
  | 0,r => if r<count then none else some []
  | fuel+1,r =>
    if r<count then do
      let rest ←outer control threads thread fuel (r+threads*4)
      pure (batch control r thread++rest)
    else some []

def toColumn (value : Nat) : Option (Fin count) :=
  if h : value<count then some ⟨value,h⟩ else none

def executeSource (source : String) (threads : Nat) (thread : Fin threads) : Option (List (Fin count)) := do
  let control ←parseBody source
  let raw ←outer control threads thread.val count control.outerStart
  pure (raw.filterMap toColumn)

theorem batch_guarded (r thread : Nat) :
    batch MlxRmsLoopSyntax.control r thread=(List.finRange 4).filterMap
      (fun element => if r+thread*4+element.val<count then some (r+thread*4+element.val) else none) := by
  unfold batch
  split
  · rename_i full
    have safe (element : Fin 4) : r+thread*4+element.val<count := by have := element.isLt; omega
    simp only [MlxRmsLoopSyntax.control,Nat.zero_le,decide_true,List.filter_true]
    rw [show (fun element : Fin 4 => if r+thread*4+element.val<count then some (r+thread*4+element.val) else none)=
      (fun element => some (r+thread*4+element.val)) from funext (fun element => ite_eq_left (safe element))]
    simp
  · simp only [MlxRmsLoopSyntax.control,Nat.zero_le,true_and]

theorem batch_empty (r thread : Nat) (late : count≤r) : batch MlxRmsLoopSyntax.control r thread=[] := by
  rw [batch_guarded]
  apply List.filterMap_eq_nil_iff.mpr
  intro element _
  exact ite_eq_right (by omega)

theorem enumerate_empty (threads thread fuel r : Nat) (late : count≤r) : enumerate threads thread fuel r=[] := by
  induction fuel generalizing r with
  | zero => rfl
  | succ fuel ih => rw [enumerate,batch_empty r thread late,ih _ (by omega),List.nil_append]

theorem outer_enumerate (threads thread fuel r : Nat) (termination : count≤r+fuel*(threads*4)) :
    outer MlxRmsLoopSyntax.control threads thread fuel r=some (enumerate threads thread fuel r) := by
  induction fuel generalizing r with
  | zero => simp only [outer,enumerate,show ¬r<count by omega,ite_false]
  | succ fuel ih =>
    by_cases active : r<count
    · rw [outer,ite_eq_left active,ih _ (by rw [Nat.succ_mul] at termination; omega)]
      rfl
    · rw [outer,ite_eq_right active,enumerate_empty threads thread (fuel+1) r (by omega)]

theorem enumerate_finRange (threads thread fuel r : Nat) :
    enumerate threads thread fuel r=(List.finRange fuel).flatMap
      (fun iteration => batch MlxRmsLoopSyntax.control (r+iteration.val*(threads*4)) thread) := by
  induction fuel generalizing r with
  | zero => simp only [enumerate,List.finRange_zero,List.flatMap_nil]
  | succ fuel ih =>
    rw [enumerate,ih,List.finRange_succ,List.flatMap_cons,List.flatMap_map]
    simp only [Fin.val_zero,Fin.val_succ,Nat.zero_mul,Nat.add_zero]
    congr 1
    apply congrArg (fun f : Fin fuel → List Nat => (List.finRange fuel).flatMap f)
    funext iteration
    congr 1
    simp only [Nat.add_mul,Nat.one_mul]
    omega

theorem batch_schedule (threads : Nat) (thread : Fin threads) (iteration : Nat) :
    batch MlxRmsLoopSyntax.control (iteration*(threads*4)) thread.val=
      ((List.finRange 4).filterMap (fun element =>
        NormalizationSchedule.columnIndex count ⟨iteration,thread,element⟩)).map Fin.val := by
  rw [batch_guarded,List.map_filterMap]
  apply List.filterMap_congr
  intro element _
  simp only [NormalizationSchedule.columnIndex,NormalizationSchedule.address]
  by_cases inside : iteration*(threads*4)+thread.val*4+element.val<count
  · simp [inside]
  · simp [inside]

theorem raw_source (threads : Nat) (positive : 0<threads) (thread : Fin threads) :
    outer MlxRmsLoopSyntax.control threads thread.val count 0=
      some ((NormalizationSchedule.threadColumns count thread).map Fin.val) := by
  rw [outer_enumerate threads thread.val count 0 (by dsimp [count]; omega),enumerate_finRange]
  simp only [Nat.zero_add]
  simp_rw [batch_schedule threads thread]
  simp only [NormalizationSchedule.threadColumns,List.product,List.map_flatMap,List.map_map,
    List.filterMap_flatMap,Function.comp_def,List.map_filterMap,List.filterMap_map]

theorem source_columns (threads : Nat) (positive : 0<threads) (thread : Fin threads) :
    executeSource sourceBody threads thread=some (NormalizationSchedule.threadColumns count thread) := by
  unfold executeSource
  rw [parsed_body]
  change ((outer MlxRmsLoopSyntax.control threads thread.val count 0).bind
    (fun raw => some (raw.filterMap toColumn)))=_
  rw [raw_source threads positive thread]
  simp only [Option.bind_some,List.filterMap_map,Function.comp_def,toColumn]
  have convert : (fun col : Fin count => if h : col.val<count then some (⟨col.val,h⟩ : Fin count) else none)=
      (fun col => some col) := by
    funext col
    rw [dite_eq_left col.isLt]
  rw [convert]
  simp

-- Arithmetic refinement for every active iteration. The full/tail guard,
-- mixed signed-int i addition and stride update have their uint32 values;
-- none can wrap under the selected positive threadgroup bound.
def uintColumn (r thread i : Nat) : Nat := ((r+(thread*4)%2^32)%2^32+i)%2^32
def uintNext (r threads : Nat) : Nat := (r+(threads*4)%2^32)%2^32

theorem arithmetic (threads : Nat) (bounded : threads≤1024) (thread : Fin threads)
    (r : Nat) (active : r<count) :
    uintNext r threads=r+threads*4 ∧ uintColumn r thread.val 4=r+thread.val*4+4 ∧
      ∀ element : Fin 4, uintColumn r thread.val element.val=r+thread.val*4+element.val := by
  have threadSmall : thread.val*4<4294967296 := by have := thread.isLt; omega
  have sumSmall : r+thread.val*4<4294967296 := by have := thread.isLt; dsimp [count] at active; omega
  have stepSmall : r+threads*4<4294967296 := by dsimp [count] at active; omega
  have strideSmall : threads*4<4294967296 := by omega
  have colSmall (i : Nat) (bound : i≤4) : r+thread.val*4+i<4294967296 := by
    have := thread.isLt; dsimp [count] at active; omega
  simp only [uintNext,uintColumn,show 2^32=4294967296 by rfl,Nat.mod_eq_of_lt strideSmall,
    Nat.mod_eq_of_lt threadSmall,Nat.mod_eq_of_lt sumSmall,Nat.mod_eq_of_lt stepSmall,
    Nat.mod_eq_of_lt (colSmall 4 (by omega)),true_and]
  intro element
  exact Nat.mod_eq_of_lt (colSmall element.val (by have := element.isLt; omega))

inductive Executes (threads : Nat) (thread : Fin threads) : Nat → List Nat → Prop where
  | stop (finished : count≤r) : Executes threads thread r []
  | step (active : r<count) (update : uintNext r threads=r+threads*4)
      (full : uintColumn r thread.val 4=r+thread.val*4+4)
      (elements : ∀ element : Fin 4, uintColumn r thread.val element.val=r+thread.val*4+element.val)
      (rest : Executes threads thread (r+threads*4) columns) :
      Executes threads thread r (batch MlxRmsLoopSyntax.control r thread.val++columns)

theorem operational (threads : Nat) (bounded : threads≤1024) (thread : Fin threads) (fuel r : Nat)
    (termination : count≤r+fuel*(threads*4)) : Executes threads thread r (enumerate threads thread.val fuel r) := by
  induction fuel generalizing r with
  | zero => exact .stop (by simpa only [Nat.zero_mul,Nat.add_zero] using termination)
  | succ fuel ih =>
    by_cases active : r<count
    · obtain ⟨update,full,elements⟩ := arithmetic threads bounded thread r active
      exact .step active update full elements (ih _ (by rw [Nat.succ_mul] at termination; omega))
    · rw [enumerate_empty threads thread.val (fuel+1) r (by omega)]
      exact .stop (by omega)

theorem source_operational (threads : Nat) (positive : 0<threads) (bounded : threads≤1024) (thread : Fin threads) :
    Executes threads thread 0 ((NormalizationSchedule.threadColumns count thread).map Fin.val) := by
  have run := operational threads bounded thread count 0 (by dsimp [count]; omega)
  have result := raw_source threads positive thread
  rw [outer_enumerate threads thread.val count 0 (by dsimp [count]; omega)] at result
  rw [Option.some.inj result] at run
  exact run

end Inference.Kernels.Normalization.MlxRmsLoopControl
