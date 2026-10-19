import host.ts.RenameRetainedParameterBody
import host.ts.RenameRetainedHeapFrame

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.CachedArrayEntry
open Parametric

/-- Enter the original block when its syntax declares no lexical cells.
The two new continuation notes are structural; all existing owners are framed. -/
theorem retained_empty_block_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {source target : St F.S}
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (body : List Stmt) (env : Env) (empty : blockNames body = [])
    (control : source.ctl = .ex (.block body) env) :
    interpC (step F source).run C₀ = some (enterBlock source body env,C₀) ∧
      interpC (step F target).run C = some (enterBlock target body (R.env env),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (enterBlock source body env) (enterBlock target body (R.env env)) ∧
      RetainedInventory (notes.withRuntime (notes.runtime.bodyEntered body env notes.runtime.stack))
        ν₀ ν C₀ C R live (enterBlock source body env) (enterBlock target body (R.env env)) := by
  have targetControl := (h.control_view control).ex_view
  have envLive := h.controlLive
  rw [control] at envLive
  have frame : Parametric.FrameR (NumberRoles ν₀ ν C₀ C) R (.s (.block body env)) (.s (.block body (R.env env))) :=
    .node _ (.cons (.node _ (.cons (.atom _ _) (.cons (env_roles _ R _) .nil))) .nil)
  have frameLive : treeSupport live (Encode.frame (.s (.block body env))) :=
    ⟨⟨True.intro,envLive.2.1,True.intro⟩,True.intro⟩
  have scope : Parametric.FrameR (NumberRoles ν₀ ν C₀ C) R (.s (.scope [])) (.s (.scope [])) :=
    .node _ (.cons (.node _ (.cons (.node _ .nil) .nil)) .nil)
  have scopeLive : treeSupport live (Encode.frame (.s (.scope []))) :=
    ⟨⟨True.intro,True.intro⟩,True.intro⟩
  have related := (h.restack (.cons frame (.cons scope h.stack)) ⟨frameLive,scopeLive,h.stackLive⟩).go (c := .ret .undef) (c' := .ret .undef)
    (.node _ (.cons (.value .undef) .nil)) ⟨True.intro,True.intro⟩
  have runtime : RuntimeInventory (notes.runtime.bodyEntered body env notes.runtime.stack) ν₀ ν C₀ C R live
      (enterBlock source body env) (enterBlock target body (R.env env)) := by
    refine ⟨inventory.runtime.keyLive,⟨returnNote_holds .undef,?_,?_⟩,⟨returnNote_holds .undef,?_,?_⟩⟩
    · simpa only [RuntimeNotes.bodyEntered,enterBlock,hoist,empty,St.push,St.ret,List.map_cons,identity_environment] using
        ForestHolds.cons (blockFrameNote_holds ν₀ C₀ identity body env)
          (.cons (emptyScopeNote_holds ν₀ C₀ identity) inventory.runtime.source.stack)
    · simpa only [RuntimeNotes.bodyEntered,Notes.Holds,cellValueAt,enterBlock,hoist,empty,St.push,St.ret] using inventory.runtime.source.cells
    · simpa only [RuntimeNotes.bodyEntered,enterBlock,hoist,empty,St.push,St.ret,List.map_cons] using
        ForestHolds.cons (blockFrameNote_holds ν C R body env)
          (.cons (emptyScopeNote_holds ν C R) inventory.runtime.target.stack)
    · simpa only [RuntimeNotes.bodyEntered,Notes.Holds,cellValueAt,enterBlock,hoist,empty,St.push,St.ret] using inventory.runtime.target.cells
  refine ⟨?_,?_,?_,inventory.heap_step runtime ?_ ?_ (.refl C₀) (.refl C)⟩
  · rw [step_block_eq F source body env control]; rfl
  · rw [step_block_eq F target body (R.env env) targetControl]; rfl
  · simpa only [enterBlock,hoist,empty,St.push,St.ret,St.go] using related
  · simp only [enterBlock,hoist,empty,St.push,St.ret]
  · simp only [enterBlock,hoist,empty,St.push,St.ret]

end Host.Ts.Owned.Annotated.CachedArrayEntry
