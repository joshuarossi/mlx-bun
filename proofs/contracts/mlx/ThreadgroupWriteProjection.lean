import contracts.mlx.ThreadgroupWrites

namespace Inference.Contracts.Mlx.ThreadgroupWriteProjection
open ThreadgroupWrites

-- Project a single source program onto one of its output buffers. Events
-- for other buffers disappear, while this buffer retains each thread's
-- source order. This is a consequence of the shared execution trace.
def programs (project : α → Option β) (threads : List (List α)) : List (List β) :=
  threads.map (List.filterMap project)

theorem step_some (project : α → Option β) {before after : List (List α)} {event : α} {value : β}
    (step : Step before event after) (kept : project event=some value) :
    Step (programs project before) value (programs project after) := by
  induction step with
  | head event rest threads =>
    simpa only [programs, List.map_cons, List.filterMap_cons, kept] using
      Step.head value (rest.filterMap project) (programs project threads)
  | tail thread step ih => exact Step.tail (thread.filterMap project) (ih kept)

theorem step_none (project : α → Option β) {before after : List (List α)} {event : α}
    (step : Step before event after) (dropped : project event=none) :
    programs project before=programs project after := by
  induction step with
  | head event rest threads => simp only [programs, List.map_cons, List.filterMap_cons, dropped]
  | tail thread step ih => exact congrArg (List.cons (thread.filterMap project)) (ih dropped)

theorem execution (project : α → Option β) {before after : List (List α)} {schedule : List α}
    (run : Executes before schedule after) :
    Executes (programs project before) (schedule.filterMap project) (programs project after) := by
  induction run with
  | done threads => exact .done _
  | @next before middle after event rest step run ih =>
    cases kept : project event with
    | none =>
      rw [List.filterMap_cons, kept, step_none project step kept]
      exact ih
    | some value =>
      rw [List.filterMap_cons, kept]
      exact .next (step_some project step kept) ih

theorem completed (project : α → Option β) (threads : List (List α)) (ready : AtBarrier threads) :
    AtBarrier (programs project threads) := by
  intro thread member
  obtain ⟨original, inside, rfl⟩ := List.mem_map.mp member
  rw [ready original inside]
  rfl

theorem member (project : α → Option β) (threads : List (List α)) (value : β) :
    value ∈ (programs project threads).flatten ↔ ∃ event ∈ threads.flatten, project event=some value := by
  constructor
  · intro inside
    obtain ⟨thread, ht, hv⟩ := List.mem_flatten.mp inside
    obtain ⟨original, ho, rfl⟩ := List.mem_map.mp ht
    obtain ⟨event, he, equal⟩ := List.mem_filterMap.mp hv
    exact ⟨event, List.mem_flatten.mpr ⟨original, ho, he⟩, equal⟩
  · rintro ⟨event, he, equal⟩
    obtain ⟨original, ho, hi⟩ := List.mem_flatten.mp he
    exact List.mem_flatten.mpr ⟨original.filterMap project, List.mem_map.mpr ⟨original, ho, rfl⟩,
      List.mem_filterMap.mpr ⟨event, hi, equal⟩⟩

end Inference.Contracts.Mlx.ThreadgroupWriteProjection
