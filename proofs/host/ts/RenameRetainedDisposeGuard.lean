import host.ts.RenameRetainedDisposeFlag
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated.Dispose
open Parametric

def guardOutput {S : Type} (source : St S) (env : Env) (frames : List Frame) : St S :=
  {source with ctl := .ret .undef,stack := .s (.block [assign,unregisterStmt,freeStmt] env)::frames}
def guardNotes (notes : RetainedNotes) (env : Env) (tail : List Tree) : RetainedNotes :=
  notes.withRuntime ⟨returnNote .undef,blockFrameNote [assign,unregisterStmt,freeStmt] env::tail,notes.runtime.cells⟩

/-- The real disposed-field read and false source branch take four steps.
The retained handle field keeps its existing interpretation. -/
theorem guard_block {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (env : Env) (frames : List Frame) (head : Tree) (tail : List Tree)
    (thisCell owner brand : Nat) (object : Obj) (w e : Bool)
    (control : source.ctl = .ev (.priv .this flag false) env)
    (stack : source.stack = .s (.if_ (.ret none) none env)::.s (.block [assign,unregisterStmt,freeStmt] env)::frames)
    (stackNotes : notes.runtime.stack = head::blockFrameNote [assign,unregisterStmt,freeStmt] env::tail)
    (thisLookup : lookupEnv nThis env = some thisCell)
    (brandLookup : lookupEnv (privName flag) env = some brand)
    (thisRead : source.heap.get thisCell = some (.cell (some (.obj owner))))
    (objectRead : source.heap.get owner = some (.obj object)) (ordinary : object.kind = .ordinary)
    (descriptor : findPriv brand flag object.priv = some (.data (.bool false) w e))
    (thisNote : notes.runtime.cells.cells thisCell = some (.obj owner)) :
    ∃ result, runC F 4 source C₀ = some (guardOutput source env frames,C₀) ∧
      runC F 4 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' (guardOutput source env frames) result ∧
      RetainedInventory (guardNotes notes env tail) ν₀ ν C₀ C R live (guardOutput source env frames) result ∧
      result.heap = target.heap ∧ result.ffi = target.ffi ∧ result.next = target.next := by
  obtain ⟨s3,left3,right3,h3,inv3,heap3,native3,next3⟩ := inventory.this_private_static_block state
    env thisCell owner brand flag (.bool false) object (.bool false) w e control thisLookup brandLookup
    thisRead objectRead ordinary descriptor thisNote (.bool false)
  obtain ⟨_,left4,right4,h4,inv4⟩ := inv3.if_bool_step h3 false (.ret none) none env
    (.s (.block [assign,unregisterStmt,freeStmt] env)::frames) head
    (blockFrameNote [assign,unregisterStmt,freeStmt] env::tail) rfl stack stackNotes
  have l4 := one_step F _ _ C₀ rfl left4
  have r4 := one_step F _ _ C (h3.control.isHalt_eq.trans rfl) right4
  exact ⟨_,runC_join F left3 l4,runC_join F right3 r4,h4,inv4,heap3,native3,next3⟩
end Host.Ts.Owned.Annotated.Dispose
