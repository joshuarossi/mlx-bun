import host.ts.RenameParametricLookup
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

/-- A checked ordinary prototype path survives changes outside the live heap.
Heap closure supplies liveness of each successor prototype; no reached lookup
or target prototype-path premise is needed. -/
theorem OrdinaryLookup.frame_live
    {S : Type} {NR : NumV → NumV → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {source target reached : St S}
    (heap : HeapR NR R live framed before after source target)
    (frame : ∀ a, live a → reached.heap.get a = source.heap.get a)
    {name : Name} {fuel a : Nat} {property : Option PropV}
    (path : OrdinaryLookup source name fuel a property) :
    live a → OrdinaryLookup reached name fuel a property := by
  induction path with
  | hit fuel a object property read kind descriptor =>
    intro alive
    exact .hit fuel a object property (by rw [frame a alive]; exact read) kind descriptor
  | next fuel a b object read kind absent prototype path ih =>
    intro alive
    obtain ⟨_,_,_,support⟩ := heap.readOrdinary a object alive read kind
    have nextAlive : live b := by
      have value := support.2.1
      rw [prototype] at value
      exact value
    exact .next fuel a b object (by rw [frame a alive]; exact read) kind absent prototype (ih nextAlive)
  | stop fuel a object read kind absent prototype =>
    intro alive
    exact .stop fuel a object (by rw [frame a alive]; exact read) kind absent prototype

end Host.Ts.Owned.Parametric
