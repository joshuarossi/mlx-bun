import host.sim.compose.NumImage

namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim

theorem eraseNum_agree (cut : Nat) (x : F64) :
    Agree (fun _ => True) cut (eraseNum cut x) Map.id := by
  refine ⟨fun _ _ => rfl, ?_, rfl, rfl, rfl⟩
  intro j hj
  change (if j < cut then NumV.ref j else _) = .ref j
  rw [ite_eq_left hj]

private theorem map_eq_at {α β : Type} {f g : α → β} : ∀ {l : List α},
    l.map f = l.map g → ∀ a ∈ l, f a = g a := by
  intro l
  induction l with
  | nil => intro _ a ha; cases ha
  | cons x l ih =>
    intro he a ha
    have h := List.cons.inj he
    rcases List.mem_cons.mp ha with rfl | ha
    · exact h.1
    · exact ih h.2 a ha

/-- Only the finite changed list must be checked when the common heap's
number references precede the erased entry. -/
theorem heap_eraseNum_of_off {S : Type} {b s s' : St S} {l : List Nat} {cut : Nat} {x : F64}
    (hclosed : ∀ a o, b.heap.get a = some o → Supp.hobj (fun _ => True) cut o)
    (hs : ∀ a, a ∉ l → s.heap.get a = b.heap.get a)
    (hs' : ∀ a, a ∉ l → s'.heap.get a = b.heap.get a)
    (himg : l.map (fun a => s'.heap.get a) =
      l.map (fun a => (s.heap.get a).map (eraseNum cut x).hobj)) :
    ∀ a, s'.heap.get a = (s.heap.get a).map (eraseNum cut x).hobj := by
  intro a
  by_cases ha : a ∈ l
  · exact map_eq_at himg a ha
  · rw [hs a ha, hs' a ha]
    cases ho : b.heap.get a with
    | none => rfl
    | some o =>
      have he := (Map.hobj_agree (eraseNum_agree cut x) (hclosed a o ho)).trans (Map.hobj_id o)
      exact congrArg some he.symm

end Host.Ts.Sim.Compose
