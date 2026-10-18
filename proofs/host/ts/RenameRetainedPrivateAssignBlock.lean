import host.ts.RenameRetainedPrivateAssign
import host.ts.RenameRuntimeHeapReads
import host.ts.RenameRouteComposition

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def privateAssignmentOutput {S : Type} (source : St S) (owner brand : Nat) (field : Name)
    (value : Val) (enumerable : Bool) (object : Obj) : St S :=
  (source.setObj owner {object with priv := setPrivL brand field (.data value true enumerable) object.priv}).ret value

def RetainedNotes.thisPrivateAssigned (notes : RetainedNotes) (owner brand : Nat)
    (field : Name) (role : Value) : RetainedNotes :=
  notes.privateStored owner brand field role notes.runtime.stack

private theorem assign_one (F : Ffi) (source target : St F.S) (C : CSrv)
    (active : isHalt source.ctl = false) (execution : interpC (step F source).run C = some (target,C)) :
    runC F 1 source C = some (target,C) := runC_cons F 0 source target target C C C active execution rfl

/-- Five original transitions for `this.#field = parameter`. Both meanings
come from the current cell inventory. The owning private-field note is
created by the checked store, on arbitrary heaps/environments/caller stacks.
In particular an owned handle is not inferred from its raw bigint bits. -/
theorem RetainedInventory.this_private_assign_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (env : Env) (field parameter : Name) (brand thisCell parameterCell owner : Nat)
    (object : Obj) (value previous : Val) (enumerable : Bool) (role : Value)
    (control : source.ctl = .ev (.assign .assign (.expr (.priv .this field false)) (.id parameter)) env)
    (brandLookup : lookupEnv (privName field) env = some brand)
    (thisLookup : lookupEnv nThis env = some thisCell)
    (parameterLookup : lookupEnv parameter env = some parameterCell)
    (thisRead : source.heap.get thisCell = some (.cell (some (.obj owner))))
    (parameterRead : source.heap.get parameterCell = some (.cell (some value)))
    (objectRead : source.heap.get owner = some (.obj object)) (ordinary : object.kind = .ordinary)
    (descriptor : findPriv brand field object.priv = some (.data previous true enumerable))
    (thisNote : notes.runtime.cells.cells thisCell = some (.obj owner))
    (parameterNote : notes.runtime.cells.cells parameterCell = some role)
    (sourceBound : source.next ≤ 2^64) (targetBound : target.next ≤ 2^64) :
    ∃ result,
      runC F 5 source C₀ = some (privateAssignmentOutput source owner brand field value enumerable object,C₀) ∧
      runC F 5 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (privateAssignmentOutput source owner brand field value enumerable object) result ∧
      RetainedInventory (notes.thisPrivateAssigned owner brand field role) ν₀ ν C₀ C R live
        (privateAssignmentOutput source owner brand field value enumerable object) result ∧
      result.ffi = target.ffi ∧ result.next = target.next := by
  obtain ⟨left1,right1,h1,inv1⟩ := inventory.private_assignment_step F FR notes ν₀ ν C₀ C R live framed
    before after old old' source target h .this field false (.id parameter) env brand control brandLookup
  obtain ⟨_,left2,right2,h2,runtime2⟩ := inv1.runtime.this_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h1 env thisCell (.obj owner) (.obj owner) rfl thisLookup thisRead thisNote
  have inv2 := inv1.heap_step runtime2 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨_,_,left3,right3,h3,inv3⟩ := inv2.private_receiver_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' _ _ h2 (.obj owner) brand field (.id parameter) env source.stack (.obj owner)
    (privateReceiverNote brand field (.id parameter) env) notes.runtime.stack rfl rfl rfl rfl
  obtain ⟨_,left4,right4,h4,runtime4⟩ := inv3.runtime.variable_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h3 parameter env parameterCell value role rfl parameterLookup parameterRead parameterNote
  have inv4 := inv3.heap_step runtime4 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨_,_,_,left5,right5,h5,inv5⟩ := inv4.private_store_step h4 owner brand field role value .undef previous enumerable object
    source.stack (privatePutNote (.obj owner) brand field) notes.runtime.stack rfl rfl objectRead ordinary descriptor rfl rfl
    sourceBound targetBound
  have l1 := assign_one F _ _ C₀ (by rw [control]; rfl) left1
  have r1 := assign_one F _ _ C (h.control.isHalt_eq.trans (by rw [control]; rfl)) right1
  have l2 := assign_one F _ _ C₀ rfl left2
  have r2 := assign_one F _ _ C (h1.control.isHalt_eq.trans rfl) right2
  have l3 := assign_one F _ _ C₀ rfl left3
  have r3 := assign_one F _ _ C (h2.control.isHalt_eq.trans rfl) right3
  have l4 := assign_one F _ _ C₀ rfl left4
  have r4 := assign_one F _ _ C (h3.control.isHalt_eq.trans rfl) right4
  have l5 := assign_one F _ _ C₀ rfl left5
  have r5 := assign_one F _ _ C (h4.control.isHalt_eq.trans rfl) right5
  exact ⟨_,runC_join F (runC_join F (runC_join F (runC_join F l1 l2) l3) l4) l5,
    runC_join F (runC_join F (runC_join F (runC_join F r1 r2) r3) r4) r5,h5,inv5,rfl,rfl⟩

end Host.Ts.Owned.Annotated
