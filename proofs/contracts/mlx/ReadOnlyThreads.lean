import contracts.mlx.Memory
import Mathlib.Data.List.OfFn
import Mathlib.Data.List.Nodup

namespace Inference.Contracts.Mlx.ReadOnlyThreads

-- A phase computes each thread's result from an immutable input memory,
-- captured by `read`. It cannot mutate that memory. A completed barrier
-- exposes the resulting per-thread programs to the following write phase.
abbrev State (α : Type) := Nat → Option α
def initial : State α := fun _ => none
def run (read : Nat → α) (schedule : List Nat) (before : State α) : State α :=
  Memory.writeCells (fun thread => some (read thread)) schedule before

inductive Executes (threads : Nat) (read : Nat → α) : State α → List Nat → State α → Prop where
  | done (before : State α) : Executes threads read before [] before
  | next {before after : State α} {thread : Nat} {rest : List Nat} :
      thread<threads → before thread=none →
      Executes threads read (Memory.putCell before thread (some (read thread))) rest after →
      Executes threads read before (thread::rest) after

def AtBarrier (threads : Nat) (state : State α) : Prop := ∀ thread, thread<threads → state thread ≠ none

variable {α : Type} {threads : Nat} {read : Nat → α} {before after : State α} {schedule : List Nat}

theorem result (execution : Executes threads read before schedule after) : after=run read schedule before := by
  induction execution with
  | done => rfl
  | next bound pending rest ih => exact ih

theorem completed (execution : Executes threads read initial schedule after) (barrier : AtBarrier threads after)
    (thread : Nat) (bound : thread<threads) : after thread=some (read thread) := by
  have ready := barrier thread bound
  rw [result execution] at ready ⊢
  unfold run at ready ⊢
  rw [Memory.writeCells_read] at ready ⊢
  by_cases issued : thread ∈ schedule
  · simp only [issued, ite_true]
  · simp only [issued, ite_false, initial, ne_eq, not_true_eq_false] at ready

theorem run_valid (read : Nat → α) (schedule : List Nat) (before : State α)
    (unique : schedule.Nodup) (bounded : ∀ thread ∈ schedule, thread<threads)
    (pending : ∀ thread ∈ schedule, before thread=none) :
    Executes threads read before schedule (run read schedule before) := by
  induction schedule generalizing before with
  | nil => exact .done before
  | cons thread rest ih =>
    have distinct := List.nodup_cons.mp unique
    apply Executes.next (bounded thread (by simp)) (pending thread (by simp))
    apply ih _ distinct.2 (fun i hi => bounded i (by simp [hi]))
    intro other ho
    have different : other ≠ thread := by intro equal; subst other; exact distinct.1 ho
    simp only [Memory.putCell, different, ite_false]
    exact pending other (by simp [ho])

theorem canonical (threads : Nat) (read : Nat → α) :
    Executes threads read initial (List.range threads) (run read (List.range threads) initial) :=
  run_valid read _ initial List.nodup_range (fun _ h => List.mem_range.mp h) (fun _ _ => rfl)

theorem canonical_barrier (threads : Nat) (read : Nat → α) :
    AtBarrier threads (run read (List.range threads) initial) := by
  intro thread bound
  simp only [run, Memory.writeCells_read, List.mem_range.mpr bound, ite_true, ne_eq, reduceCtorEq, not_false_eq_true]

def values (threads : Nat) (state : State α) (fallback : α) : List α :=
  List.ofFn (fun thread : Fin threads => (state thread.val).getD fallback)

theorem completed_values (execution : Executes threads read initial schedule after) (barrier : AtBarrier threads after)
    (fallback : α) : values threads after fallback=List.ofFn (fun thread : Fin threads => read thread.val) := by
  unfold values
  apply congrArg List.ofFn
  funext thread
  rw [completed execution barrier thread.val thread.isLt]
  rfl

theorem completed_list (expected : List α) (fallback : α)
    (execution : Executes expected.length (fun thread => (expected[thread]?).getD fallback) initial schedule after)
    (barrier : AtBarrier expected.length after) : values expected.length after fallback=expected := by
  rw [completed_values execution barrier fallback]
  calc
    _ = List.ofFn expected.get := by
      apply congrArg List.ofFn
      funext thread
      rw [List.getElem?_eq_getElem thread.isLt]
      rfl
    _ = expected := List.ofFn_get expected

end Inference.Contracts.Mlx.ReadOnlyThreads
