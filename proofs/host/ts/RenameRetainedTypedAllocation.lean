import host.ts.RenameRetainedInventory
import host.ts.RenameTypedArrayEffects

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Both original typed-array allocations preserve the old retained data.
Freshness supplies the new view's resource meaning. A constructor separately
establishes the new buffer's fixed byte notes and the whole-state relation. -/
theorem RetainedInventory.newTyped_return (F : Ffi) {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    {NR : NumV → NumV → Prop} (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (kind : EltK) (proto count : Nat) (sourceBytes targetBytes : List Host.Ts.Byte)
    (sourceBound : s₀.next+1 < 2^64) (targetBound : s.next+1 < 2^64) :
    RetainedInventory (notes.withRuntime ⟨returnNote (.obj (s₀.next+1)),notes.runtime.stack,notes.runtime.cells⟩)
      ν₀ ν C₀ C R (LiveAfter (LiveAfter live s₀.next) (s₀.next+1))
      ((newTyped F s₀ kind proto sourceBytes count).2.ret (.obj (s₀.next+1)))
      ((newTyped F s kind proto targetBytes count).2.ret (.obj (s.next+1))) := by
  let sourcePost := (newTyped F s₀ kind proto sourceBytes count).2.ret (.obj (s₀.next+1))
  let targetPost := (newTyped F s kind proto targetBytes count).2.ret (.obj (s.next+1))
  have sourceFrame : ∀ a, live a → sourcePost.heap.get a = s₀.heap.get a :=
    fun a alive => newTyped_ret_heap_below F s₀ kind proto sourceBytes count a (heap.sourceBound a alive) sourceBound
  have targetFrame : ∀ a, live a → targetPost.heap.get (R.a a) = s.heap.get (R.a a) :=
    fun a alive => newTyped_ret_heap_below F s kind proto targetBytes count (R.a a) (heap.targetBound a alive) targetBound
  have grow : ∀ a, live a → LiveAfter (LiveAfter live s₀.next) (s₀.next+1) a :=
    fun _ alive => Or.inl (Or.inl alive)
  have heapPost := inventory.heapInventory.frame grow sourceFrame targetFrame
  have fresh : R.a (s₀.next+1) = s.next+1 := heap.fresh 1
  have returnRole : (Value.obj (s₀.next+1)).Holds ν C R (.obj (s.next+1)) := by
    simpa only [fresh] using Value.Holds.obj (ν := ν) (C := C) (R := R) (s₀.next+1)
  refine ⟨⟨heapPost.cells.keyLive,
      ⟨returnNote_holds (.obj (s₀.next+1)),inventory.runtime.source.stack,heapPost.cells.source⟩,
      ⟨returnNote_holds returnRole,inventory.runtime.target.stack,heapPost.cells.target⟩⟩,
    heapPost.privates,heapPost.captures,?_,?_,?_⟩
  · exact inventory.arrays.frame grow
      (fun a roles selected => sourceFrame a (inventory.arrays.keyLive a roles selected))
      (fun a roles selected => targetFrame a (inventory.arrays.keyLive a roles selected))
  · exact inventory.publicFields.frame grow
      (fun a name role selected => sourceFrame a (inventory.publicFields.keyLive a name role selected))
      (fun a name role selected => targetFrame a (inventory.publicFields.keyLive a name role selected))
  · exact inventory.buffers.frame grow
      (fun a roles selected => sourceFrame a (inventory.buffers.keyLive a roles selected))
      (fun a roles selected => targetFrame a (inventory.buffers.keyLive a roles selected))

end Host.Ts.Owned.Annotated
