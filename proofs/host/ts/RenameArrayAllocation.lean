import host.ts.RenameArrayInventory
import host.ts.RenameParametricArrayLiteral
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- An actual array allocation records the meanings already carried by its
operand list, while framing every older selected array. -/
theorem ArrayInventory.allocate {S : Type} {notes : ArrayNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {s₀ s : St S} {NR : NumV → NumV → Prop}
    (inventory : ArrayInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (roles : List Value) (values targetValues : List Val)
    (sourceRoles : ListR (fun role value => role.Holds ν₀ C₀ identity value) roles values)
    (targetRoles : ListR (fun role value => role.Holds ν C R value) roles targetValues)
    (sourceSupport : listSupport (valueSupport live) values)
    (sourceBound : s₀.next < 2^64) (targetBound : s.next < 2^64) :
    ArrayInventory (notes.write s₀.next roles) ν₀ ν C₀ C R (LiveAfter live s₀.next)
      ((s₀.alloc (valueArray values)).2.ret (.obj s₀.next))
      ((s.alloc (valueArray targetValues)).2.ret (.obj s.next)) := by
  have fresh : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using heap.fresh 0
  have old := inventory.alloc heap (valueArray values) (valueArray targetValues) (.obj s₀.next) (.obj s.next) sourceBound targetBound
  have sourceObject : ((s₀.alloc (valueArray values)).2.ret (.obj s₀.next)).heap.get s₀.next =
      some (.obj ⟨.array values,.obj aArrayProto,[],[],true⟩) := by
    simp only [St.alloc,St.ret,valueArray,PTrie.get_set_u64 _ _ _ sourceBound,ite_true]
  have targetObject : ((s.alloc (valueArray targetValues)).2.ret (.obj s.next)).heap.get (R.a s₀.next) =
      some (.obj ⟨.array targetValues,.obj aArrayProto,[],[],true⟩) := by
    simp only [fresh,St.alloc,St.ret,valueArray,PTrie.get_set_u64 _ _ _ targetBound,ite_true]
  refine old.annotate s₀.next roles (Or.inr rfl)
    ⟨_,values,sourceObject,rfl,sourceRoles⟩ ⟨_,targetValues,targetObject,rfl,targetRoles⟩ ?_
  intro o vs object kind
  have same := HObj.obj.inj (Option.some.inj (sourceObject.symm.trans object))
  subst o
  have eq : values = vs := Kind.array.inj kind
  subst vs
  exact listSupport_mono (valueSupport_mono (fun _ alive => Or.inl alive)) values sourceSupport
end Host.Ts.Owned.Annotated
