import host.ts.RenameParametricState
namespace Host.Ts.Owned.Parametric

/-- The fresh-address map fixes allocation growth even when native resources,
numeric servers and live support change between two related source cuts. -/
theorem HeapR.target_next_add {S : Type} {NR NR' : NumV → NumV → Prop} {R : Ren}
    {live framed live' framed' : Nat → Prop}
    {before after before' after' : List Val} {s₀ s t₀ t : St S}
    (h : HeapR NR R live framed before after s₀ s)
    (ht : HeapR NR' R live' framed' before' after' t₀ t)
    (k : Nat) (source : t₀.next = s₀.next+k) : t.next = s.next+k := by
  have first := h.fresh k
  have last := ht.fresh 0
  simp only [Nat.add_zero,source] at last
  exact last.symm.trans first

end Host.Ts.Owned.Parametric
