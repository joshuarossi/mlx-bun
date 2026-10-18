import host.ts.RenameArrayInventory
import host.ts.RenameParametricArrayPush
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- A real array mutation replaces its own retained element list and frames
all other selected arrays by injectivity of the live address map. -/
theorem ArrayInventory.write_owner {S : Type} {notes : ArrayNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {s₀ s t₀ t : St S} {NR : NumV → NumV → Prop}
    (inventory : ArrayInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (a : Nat) (roles : List Value) (alive : live a)
    (source : ArrayContents roles ν₀ C₀ identity a t₀) (target : ArrayContents roles ν C R a t)
    (closed : ∀ o values, t₀.heap.get a = some (.obj o) → o.kind = .array values → listSupport (valueSupport live) values)
    (sourceFrame : ∀ b, b ≠ a → t₀.heap.get b = s₀.heap.get b)
    (targetFrame : ∀ b, b ≠ R.a a → t.heap.get b = s.heap.get b) :
    ArrayInventory (notes.write a roles) ν₀ ν C₀ C R live t₀ t := by
  constructor
  · intro b other entry
    by_cases eq : b = a
    · exact eq ▸ alive
    · exact inventory.keyLive b other (by simpa only [ArrayNotes.write,ite_eq_right eq] using entry)
  · intro b other entry
    by_cases eq : b = a
    · subst b
      have same : roles = other := Option.some.inj (by simpa [ArrayNotes.write] using entry)
      exact same ▸ source
    · have oldEntry : notes.owners b = some other := by simpa only [ArrayNotes.write,ite_eq_right eq] using entry
      exact (inventory.source b other oldEntry).frame (sourceFrame b eq)
  · intro b other entry
    by_cases eq : b = a
    · subst b
      have same : roles = other := Option.some.inj (by simpa [ArrayNotes.write] using entry)
      exact same ▸ target
    · have oldEntry : notes.owners b = some other := by simpa only [ArrayNotes.write,ite_eq_right eq] using entry
      have distinct : R.a b ≠ R.a a := fun same => eq (heap.inj b a (inventory.keyLive b other oldEntry) alive same)
      exact (inventory.target b other oldEntry).frame (targetFrame (R.a b) distinct)
  · intro b other entry o values object kind
    by_cases eq : b = a
    · subst b; exact closed o values object kind
    · have oldEntry : notes.owners b = some other := by simpa only [ArrayNotes.write,ite_eq_right eq] using entry
      exact inventory.sourceClosed b other oldEntry o values ((sourceFrame b eq).symm.trans object) kind

/-- The stored array values are exactly the already annotated append operands.
No new role is selected after inspecting the resulting element bits. -/
theorem ArrayInventory.set_array {S : Type} {notes : ArrayNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {s₀ s : St S} {NR : NumV → NumV → Prop}
    (inventory : ArrayInventory notes ν₀ ν C₀ C R live s₀ s)
    (heap : Parametric.HeapR NR R live framed before after s₀ s)
    (a : Nat) (roles : List Value) (values targetValues : List Val) (o₀ o : Obj) (v₀ v : Val) (alive : live a)
    (sourceRoles : ListR (fun role value => role.Holds ν₀ C₀ identity value) roles values)
    (targetRoles : ListR (fun role value => role.Holds ν C R value) roles targetValues)
    (support : listSupport (valueSupport live) values)
    (sourceBound : a < 2^64) (targetBound : R.a a < 2^64) :
    ArrayInventory (notes.write a roles) ν₀ ν C₀ C R live
      ((s₀.setObj a {o₀ with kind := .array values}).ret v₀)
      ((s.setObj (R.a a) {o with kind := .array targetValues}).ret v) := by
  have sourceObject : ((s₀.setObj a {o₀ with kind := .array values}).ret v₀).heap.get a =
      some (.obj {o₀ with kind := .array values}) := by
    simp only [St.setObj,St.ret,PTrie.get_set_u64 _ _ _ sourceBound,ite_true]
  have targetObject : ((s.setObj (R.a a) {o with kind := .array targetValues}).ret v).heap.get (R.a a) =
      some (.obj {o with kind := .array targetValues}) := by
    simp only [St.setObj,St.ret,PTrie.get_set_u64 _ _ _ targetBound,ite_true]
  refine inventory.write_owner heap a roles alive ⟨_,values,sourceObject,rfl,sourceRoles⟩
    ⟨_,targetValues,targetObject,rfl,targetRoles⟩ ?_ ?_ ?_
  · intro other vs object kind
    have same := HObj.obj.inj (Option.some.inj (sourceObject.symm.trans object))
    subst other
    have eq : values = vs := Kind.array.inj kind
    subst vs
    exact support
  · intro b other
    simp only [St.setObj,St.ret,PTrie.get_set_u64 _ _ _ sourceBound,ite_eq_right other]
  · intro b other
    simp only [St.setObj,St.ret,PTrie.get_set_u64 _ _ _ targetBound,ite_eq_right other]
end Host.Ts.Owned.Annotated
