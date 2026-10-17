import kernels.trellis.DownLoopSource
namespace Inference.Kernels.Trellis.DownLaneFold
open DownCodebook DownLoopSource
set_option maxRecDepth 10000

-- These are identities of sequential state transitions. They use no
-- floating-point associativity, commutativity, contraction or distributivity.
def update {α : Type} (step : Nat → α → α) (state : Nat → α) (column : Nat) : Nat → α :=
  fun i => if i=column then step column (state column) else state i

theorem columns {α : Type} (step : Nat → α → α) (state : Nat → α) (count column : Nat) :
    ((List.range count).foldl (update step) state) column=
      if column<count then step column (state column) else state column := by
  induction count with
  | zero => rfl
  | succ count ih =>
    rw [List.range_succ,List.foldl_append]
    simp only [List.foldl_cons,List.foldl_nil,update]
    by_cases same : column=count
    · subst column
      rw [ite_eq_left rfl,ih]
      simp
    · rw [ite_eq_right same,ih]
      by_cases bound : column<count
      · simp only [bound,ite_true,show column<count+1 by omega]
      · simp only [bound,ite_false,show ¬column<count+1 by omega]

theorem project_fold {α β γ : Type} (points : List α) (step : β → α → β)
    (project : β → γ) (scalar : γ → α → γ)
    (same : ∀ state point, project (step state point)=scalar (project state) point) (state : β) :
    project (points.foldl step state)=points.foldl scalar (project state) := by
  induction points generalizing state with
  | nil => rfl
  | cons point rest ih =>
    simp only [List.foldl_cons]
    rw [ih,same]

theorem paired_range {α : Type} (step : Nat → α → α) (start count : Nat) (initial : α) :
    (List.range count).foldl
      (fun acc r => step (start+2*r+1) (step (start+2*r) acc)) initial=
      pairedRows step start count initial := by
  induction count generalizing start initial with
  | zero => rfl
  | succ count ih =>
    rw [List.range_succ_eq_map,List.foldl_cons,List.foldl_map]
    have shifted : (fun acc r => step (start+2*(r+1)+1) (step (start+2*(r+1)) acc))=
        (fun acc r => step (start+2+2*r+1) (step (start+2+2*r) acc)) := by
      funext acc r
      have offset : start+2*(r+1)=start+2+2*r := by omega
      rw [offset]
    simp only [Nat.mul_zero,Nat.add_zero]
    rw [shifted,ih]
    rfl

def action {α : Type} (step : Nat → Nat → α → α) (start : Nat) (state : Nat → α) (point : Event) : Nat → α :=
  update (step (start+point.r+point.u)) state point.i

theorem ordered_fold {α : Type} (step : Nat → Nat → α → α) (start column : Nat)
    (columnBound : column<16) (initial : Nat → α) :
    ((orderedEvents).foldl (action step start) initial) column=
      pairedRows (fun row acc => step row column acc) start 68 (initial column) := by
  simp only [orderedEvents,List.foldl_flatMap,List.foldl_map,action]
  have perPair : ∀ (state : Nat → α) (r : Nat),
      ((List.range 2).foldl (fun state u => (List.range 16).foldl
        (update (step (start+2*r+u))) state) state) column=
      step (start+2*r+1) column (step (start+2*r) column (state column)) := by
    intro state r
    have projected := project_fold (List.range 2)
      (fun state u => (List.range 16).foldl (update (step (start+2*r+u))) state)
      (fun state => state column) (fun acc u => step (start+2*r+u) column acc)
      (fun state u => by rw [columns,ite_eq_left columnBound]) state
    simpa only [show List.range 2=[0,1] from rfl,List.foldl_cons,List.foldl_nil,Nat.add_zero] using projected
  have projected := project_fold (List.range 68)
    (fun state r => (List.range 2).foldl (fun state u => (List.range 16).foldl
      (update (step (start+2*r+u))) state) state)
    (fun state => state column)
    (fun acc r => step (start+2*r+1) column (step (start+2*r) column acc)) perPair initial
  exact projected.trans (paired_range (fun row acc => step row column acc) start 68 (initial column))
end Inference.Kernels.Trellis.DownLaneFold
