import host.ts.RenameRetainedInventory
set_option Elab.async false
namespace Host.Ts.Owned.Annotated

theorem RuntimeInventory.stack_cons {S : Type} {notes : RuntimeNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (frame : Frame) (tail : List Frame) (source : s₀.stack = frame::tail) :
    notes.stack = notes.stack.headD (.node "" [])::notes.stack.tail := by
  have holds := inventory.source.stack
  rw [source,List.map_cons] at holds
  cases hs : notes.stack with
  | nil => rw [hs] at holds; cases holds
  | cons head tail => rfl

theorem chain_next_offset {S : Type} {NR₀ NR : NumV → NumV → Prop}
    {FR₀ FR : Ren → S → S → Prop} {R : Ren} {live₀ live framed₀ framed : Nat → Prop}
    {before₀ after₀ before after : List Val} {old₀ old₀' old old' : List Event}
    {s₀ s t₀ t : St S}
    (initial : Parametric.StateR NR₀ FR₀ R live₀ framed₀ before₀ after₀ old₀ old₀' s₀ s)
    (current : Parametric.StateR NR FR R live framed before after old old' t₀ t)
    (offset : Nat) (source : t₀.next = s₀.next+offset) : t.next = s.next+offset := by
  have first := initial.heap.fresh offset
  have reached := current.heap.fresh 0
  simp only [Nat.add_zero,source] at reached
  exact reached.symm.trans first

theorem chain_next_budget {S : Type} {NR₀ NR : NumV → NumV → Prop}
    {FR₀ FR : Ren → S → S → Prop} {R : Ren} {live₀ live framed₀ framed : Nat → Prop}
    {before₀ after₀ before after : List Val} {old₀ old₀' old old' : List Event}
    {s₀ s t₀ t : St S}
    (initial : Parametric.StateR NR₀ FR₀ R live₀ framed₀ before₀ after₀ old₀ old₀' s₀ s)
    (current : Parametric.StateR NR FR R live framed before after old old' t₀ t)
    (offset allowance limit : Nat) (source : t₀.next = s₀.next+offset)
    (room : offset < allowance) (budget : s.next+allowance ≤ limit) : t.next < limit := by
  rw [chain_next_offset initial current offset source]
  omega

theorem chain_next_budget_le {S : Type} {NR₀ NR : NumV → NumV → Prop}
    {FR₀ FR : Ren → S → S → Prop} {R : Ren} {live₀ live framed₀ framed : Nat → Prop}
    {before₀ after₀ before after : List Val} {old₀ old₀' old old' : List Event}
    {s₀ s t₀ t : St S}
    (initial : Parametric.StateR NR₀ FR₀ R live₀ framed₀ before₀ after₀ old₀ old₀' s₀ s)
    (current : Parametric.StateR NR FR R live framed before after old old' t₀ t)
    (offset required allowance limit : Nat) (source : t₀.next = s₀.next+offset)
    (room : offset+required ≤ allowance) (budget : s.next+allowance ≤ limit) : t.next+required ≤ limit := by
  rw [chain_next_offset initial current offset source]
  omega

theorem chain_not_framed_fresh {S : Type} {NR : NumV → NumV → Prop}
    {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (initial : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (address : Nat) (fresh : s₀.next ≤ address) : ¬ framed address := by
  intro framedAddress
  have below := initial.heap.sourceBound address (initial.heap.prefixLive address framedAddress)
  omega

end Host.Ts.Owned.Annotated
