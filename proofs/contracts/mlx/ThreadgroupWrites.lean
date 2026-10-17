import contracts.mlx.Memory

namespace Inference.Contracts.Mlx.ThreadgroupWrites

-- A scheduler may advance any thread, but can issue only that thread's next
-- write. Programs stop at the barrier. This is an operational model, with
-- the hardware's write/visibility and barrier behavior a platform boundary.
inductive Step : List (List α) → α → List (List α) → Prop where
  | head (store : α) (rest : List α) (threads : List (List α)) :
      Step ((store::rest)::threads) store (rest::threads)
  | tail (thread : List α) {before after : List (List α)} {store : α} :
      Step before store after → Step (thread::before) store (thread::after)

inductive Executes : List (List α) → List α → List (List α) → Prop where
  | done (threads : List (List α)) : Executes threads [] threads
  | next {before middle after : List (List α)} {store : α} {rest : List α} :
      Step before store middle → Executes middle rest after → Executes before (store::rest) after

def AtBarrier (threads : List (List α)) : Prop := ∀ thread ∈ threads, thread=[]

theorem append_execution {before middle after : List (List α)} {first second : List α}
    (left : Executes before first middle) (right : Executes middle second after) :
    Executes before (first++second) after := by
  induction left with
  | done => exact right
  | next step execution ih => exact .next step (ih right)

theorem lift_execution (thread : List α)
    {before after : List (List α)} {schedule : List α}
    (execution : Executes before schedule after) : Executes (thread::before) schedule (thread::after) := by
  induction execution with
  | done => exact .done _
  | next step execution ih => exact .next (.tail thread step) ih

theorem drain_head (thread : List α) (threads : List (List α)) :
    Executes (thread::threads) thread ([]::threads) := by
  induction thread with
  | nil => exact .done _
  | cons store rest ih => exact .next (.head store rest threads) ih

-- A finite completing schedule is constructed for every collection of thread
-- programs. The barrier premise and execution relation are jointly realizable.
theorem canonical (threads : List (List α)) :
    Executes threads threads.flatten (List.replicate threads.length []) := by
  induction threads with
  | nil => exact .done _
  | cons thread rest ih =>
    exact append_execution (drain_head thread rest) (lift_execution [] ih)

theorem canonical_barrier (threads : List (List α)) : AtBarrier (List.replicate threads.length ([] : List α)) := by
  intro thread member
  exact (List.mem_replicate.mp member).2

theorem step_conservation {before after : List (List α)} {store : α}
    (step : Step before store after) : before.flatten.Perm (store::after.flatten) := by
  induction step with
  | head => simp
  | @tail thread before after store step ih =>
    simp only [List.flatten_cons]
    exact (ih.append_left thread).trans (List.perm_append_comm.trans (by
      simpa using (List.perm_append_comm : (after.flatten++thread).Perm (thread++after.flatten)).cons store))

theorem conservation {before after : List (List α)} {schedule : List α}
    (execution : Executes before schedule after) : before.flatten.Perm (schedule++after.flatten) := by
  induction execution with
  | done => simp
  | @next before middle after store rest step execution ih =>
    exact (step_conservation step).trans (ih.cons store)

theorem barrier_empty (threads : List (List α)) (ready : AtBarrier threads) : threads.flatten=[] := by
  induction threads with
  | nil => rfl
  | cons thread rest ih =>
    have head := ready thread (by simp)
    have tail : AtBarrier rest := fun xs hx => ready xs (by simp [hx])
    simp only [List.flatten_cons, head, List.nil_append, ih tail]

-- Completion plus legal scheduling constructs the permutation consumed by
-- the memory proofs. It is not supplied as an independent kernel premise.
theorem completed_schedule {before after : List (List α)} {schedule : List α}
    (execution : Executes before schedule after) (ready : AtBarrier after) : schedule.Perm before.flatten := by
  have h := conservation execution
  rw [barrier_empty after ready, List.append_nil] at h
  exact h.symm

theorem completed_value {programs after : List (List Memory.Store)} {schedule : List Memory.Store}
    (execution : Executes programs schedule after) (ready : AtBarrier after)
    (memory : M1Max.WordMemory) (word : Nat) (value : Float32)
    (values : ∀ store ∈ programs.flatten, store.word=word → store.value=value)
    (covered : ∃ store ∈ programs.flatten, store.word=word) :
    Memory.execute schedule memory word = value :=
  Memory.written_value_permuted programs.flatten schedule (completed_schedule execution ready) memory word value values covered

end Inference.Contracts.Mlx.ThreadgroupWrites
