import host.sim.conv.Frozen
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim

section
variable {S : Type} {M : Map} {s t s1 t1 s2 t2 : St S}

/-- Control, stack and native-state changes that leave both heaps unchanged. -/
theorem HeapStepFoot.sameHeap (hs : s1.heap = s.heap) (hn : s1.next = s.next)
    (ht : t1.heap = t.heap) : HeapStepFoot M s t s1 t1 where
  grows := Nat.le_of_eq hn.symm
  old a ha := .inl (by unfold Present at ha ⊢; rw [hs] at ha; exact ha)
  kept a _ _ := by rw [ht]

/-- A write to a present source entry and its target image preserves caller-only entries. -/
theorem HeapStepFoot.write {a : Nat} {o o' : HObj} (hp : Present s a)
    (ha : a < 2 ^ 64) (hat : M.a a < 2 ^ 64) :
    HeapStepFoot M s t { s with heap := s.heap.set a o } { t with heap := t.heap.set (M.a a) o' } where
  grows := Nat.le_refl _
  old b hb := .inl (by
    rcases Present.of_set ha hb with rfl | hb
    · exact hp
    · exact hb)
  kept b _ hb := by
    show (t.heap.set (M.a a) o').get b = t.heap.get b
    rw [PTrie.get_set_u64 _ _ _ hat, ite_eq_right (Ne.symm (hb a hp))]

/-- Allocation only writes at the old counter, above every caller-only old address. -/
theorem HeapStepFoot.alloc (o o' : HObj) (hs : s.next < 2 ^ 64) (ht : t.next < 2 ^ 64) :
    HeapStepFoot M s t (s.alloc o).2 (t.alloc o').2 where
  grows := Nat.le_succ _
  old a ha := by
    rcases Present.of_alloc hs ha with rfl | ha
    · exact .inr (Nat.le_refl _)
    · exact .inl ha
  kept a ha _ := by
    show (t.heap.set t.next o').get a = t.heap.get a
    rw [PTrie.get_set_u64 _ _ _ ht, ite_eq_right (Nat.ne_of_lt ha)]

/-- Compose footprints while the source's fresh names map above the target's original counter. -/
theorem HeapStepFoot.trans (h1 : HeapStepFoot M s t s1 t1) (h2 : HeapStepFoot M s1 t1 s2 t2)
    (hx : ∀ k, M.a (s.next + k) = t.next + k) (ht : t.next ≤ t1.next) :
    HeapStepFoot M s t s2 t2 where
  grows := Nat.le_trans h1.grows h2.grows
  old a ha := by
    rcases h2.old a ha with ha | ha
    · exact h1.old a ha
    · exact .inr (Nat.le_trans h1.grows ha)
  kept a ha hnot := by
    have hnot1 : ∀ b, Present s1 b → M.a b ≠ a := by
      intro b hb e
      rcases h1.old b hb with hp | hp
      · exact hnot b hp e
      · have hn : M.a b = t.next + (b - s.next) := by
          simpa only [Nat.add_sub_of_le hp] using hx (b - s.next)
        rw [e] at hn
        omega
    exact (h2.kept a (Nat.lt_of_lt_of_le ha ht) hnot1).trans (h1.kept a ha hnot)

end
end Host.Ts.Sim.Conv
