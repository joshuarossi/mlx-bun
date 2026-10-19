import host.load.RuntimePostConcatCleanupPlan
import host.ts.RenameRouteComposition
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.PostConcatCleanup
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/-- Notes after the `#disposed` write. The current cell inventory and the
other five retained families stay on `notes`; only the control and stack change. -/
def storeNotes (notes : RetainedNotes) (role : Annotated.Value) (tail : List Annotated.Tree) :
    RetainedNotes :=
  notes.withRuntime ⟨returnNote role,tail,notes.runtime.cells⟩

/-- The disposed-flag name is not the wrapper's current handle name. -/
theorem handle_not_disposed :
    nameEq AfterB.Block75.sourceName DisposedStore.sourceName = false := by
  host_kernel_rfl

/-- One original step at source 2034 (`DisposedStore.input`, region index 55).
The current return role, stack note, and a private note of another name are the
only annotation premises. The same live set is the end live set. The result
keeps `StateR`, all six retained inventories, and `Inst`. -/
theorem store_tail (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (FR : Ren → P.F.S → P.F.S → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ DisposedStore.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      DisposedStore.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live DisposedStore.input s)
    (role : Annotated.Value) (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
    (controlNote : notes.runtime.control = returnNote role)
    (stackNotes : notes.runtime.stack = headNote::tailNotes)
    (targetBound : s.next ≤ 2^64)
    (tracked : PrivateNote)
    (entry : notes.privates.owners DisposedStore.sourceAddress = some tracked)
    (different : nameEq tracked.name DisposedStore.sourceName = false) :
    ∃ result, interpC (step P.F DisposedStore.input).run C₀ = some (DisposedStore.output,C₀) ∧
      interpC (step P.F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        DisposedStore.output result ∧
      RetainedInventory (storeNotes notes role tailNotes) ν₀ ν C₀ C R live
        DisposedStore.output result ∧
      Inst ν₀ DisposedStore.nextServer C₀ := by
  unfold storeNotes
  exact DisposedStore.retained_transport notes ν₀ ν C₀ C R FR live framed before after old old' s
    inst h inventory role headNote tailNotes controlNote stackNotes targetBound tracked entry different

/-- The same step as a one-step run. `live` is unchanged. -/
theorem store_run (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (FR : Ren → P.F.S → P.F.S → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ DisposedStore.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      DisposedStore.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live DisposedStore.input s)
    (role : Annotated.Value) (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
    (controlNote : notes.runtime.control = returnNote role)
    (stackNotes : notes.runtime.stack = headNote::tailNotes)
    (targetBound : s.next ≤ 2^64)
    (tracked : PrivateNote)
    (entry : notes.privates.owners DisposedStore.sourceAddress = some tracked)
    (different : nameEq tracked.name DisposedStore.sourceName = false) :
    ∃ result, runC P.F 1 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        DisposedStore.output result ∧
      RetainedInventory (storeNotes notes role tailNotes) ν₀ ν C₀ C R live
        DisposedStore.output result ∧
      Inst ν₀ DisposedStore.nextServer C₀ := by
  obtain ⟨result,_sourceRun,targetRun,post,retained,nextInst⟩ :=
    store_tail notes ν₀ ν C₀ C R FR live framed before after old old' s inst h inventory
      role headNote tailNotes controlNote stackNotes targetBound tracked entry different
  have sourceOpen : isHalt DisposedStore.input.ctl = false := by host_kernel_rfl
  have targetOpen : isHalt s.ctl = false := h.control.isHalt_eq.trans sourceOpen
  exact ⟨result,runC_cons P.F 0 s result result C C C targetOpen targetRun rfl,post,retained,nextInst⟩

host_assert_retained_schema store_run, 1

end Host.Load.Run.Full.Ordinary.PostConcatCleanup
