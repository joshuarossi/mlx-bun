import host.ts.RenameRetainedInventory

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Real fresh allocations retain every prior occurrence family and establish
the fixed return-address note. The allocating primitive separately proves the
new objects' whole-state relation. -/
theorem RetainedInventory.allocate_return {S : Type} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {s₀ s : St S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    {NR : NumV → NumV → Prop} (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (object₀ object : HObj) (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    RetainedInventory (notes.withRuntime {notes.runtime with control := returnNote (.obj s₀.next)})
      ν₀ ν C₀ C R (LiveAfter live s₀.next)
      ((s₀.alloc object₀).2.ret (.obj s₀.next)) ((s.alloc object).2.ret (.obj s.next)) := by
  have cells := inventory.runtime.cellInventory.alloc heap object₀ object (.obj s₀.next) (.obj s.next) sourceBound targetBound
  have fresh : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using heap.fresh 0
  have targetRole : (Value.obj s₀.next).Holds ν C R (.obj s.next) := by
    simpa only [fresh] using Value.Holds.obj (ν := ν) (C := C) (R := R) s₀.next
  have runtime : RuntimeInventory {notes.runtime with control := returnNote (.obj s₀.next)} ν₀ ν C₀ C R
      (LiveAfter live s₀.next) ((s₀.alloc object₀).2.ret (.obj s₀.next)) ((s.alloc object).2.ret (.obj s.next)) :=
    ⟨cells.keyLive,⟨returnNote_holds (.obj s₀.next),inventory.runtime.source.stack,cells.source⟩,
      ⟨returnNote_holds targetRole,inventory.runtime.target.stack,cells.target⟩⟩
  have prior := inventory.heapInventory.alloc heap object₀ object (.obj s₀.next) (.obj s.next) sourceBound targetBound
  exact ⟨runtime,prior.privates,prior.captures,
    inventory.arrays.alloc heap object₀ object (.obj s₀.next) (.obj s.next) sourceBound targetBound,
    inventory.publicFields.alloc heap object₀ object (.obj s₀.next) (.obj s.next) sourceBound targetBound,
    inventory.buffers.alloc heap object₀ object (.obj s₀.next) (.obj s.next) sourceBound targetBound⟩

end Host.Ts.Owned.Annotated
