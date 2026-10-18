import host.ts.RenameRetainedParameterBody
import host.ts.RenameParametricTryEntry
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def tryFrameNote (handler : Option (Option Pat × List Stmt)) (finalizer : Option (List Stmt)) (env : Env) : Tree :=
  .node "Frame.s" [.node "StmtF.try_" [.atom _ handler,.atom _ finalizer,environmentNote env]]

theorem tryFrameNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren)
    (handler : Option (Option Pat × List Stmt)) (finalizer : Option (List Stmt)) (env : Env) :
    (tryFrameNote handler finalizer env).Holds ν C R
      (Encode.frame (.s (.try_ handler finalizer (R.env env)))) := by
  exact .node _ (.cons (.node _ (.cons (.atom _ _) (.cons (.atom _ _)
    (.cons (environmentNote_holds ν C R env) .nil)))) .nil)

/-- Enter the original protected block with its real lexical hoister. All
previous annotation families survive; the actual handler/finalizer is saved
under the new block and scope, with the original captured environment. -/
theorem RetainedInventory.try_entry_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (body : List Stmt) (handler : Option (Option Pat × List Stmt)) (finalizer : Option (List Stmt)) (env : Env)
    (control : s₀.ctl = .ex (.try_ body handler finalizer) env) (inert : noInitFunctions body = true)
    (sourceBound : s₀.next+(blockNames body).length ≤ 2^64) (targetBound : s.next+(blockNames body).length ≤ 2^64) :
    let base₀ := s₀.push (.s (.try_ handler finalizer env))
    let base := s.push (.s (.try_ handler finalizer (R.env env)))
    let bodyEnv := (hoist base₀ body env).1
    interpC (step F s₀).run C₀ = some (enterBlock base₀ body env,C₀) ∧
    interpC (step F s).run C = some (enterBlock base body (R.env env),C) ∧
    Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (CellsLive live s₀.next (blockNames body))
      framed before after old old' (enterBlock base₀ body env) (enterBlock base body (R.env env)) ∧
    RetainedInventory (notes.withRuntime (notes.runtime.bodyEntered body bodyEnv
      (tryFrameNote handler finalizer env::notes.runtime.stack))) ν₀ ν C₀ C R
      (CellsLive live s₀.next (blockNames body)) (enterBlock base₀ body env) (enterBlock base body (R.env env)) := by
  obtain ⟨left,right,post⟩ := step_try_entry_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h body handler finalizer env control inert sourceBound targetBound
  have sourceStack := enterBlock_stack_prefix (s₀.push (.s (.try_ handler finalizer env))) body env inert
  have targetStack := enterBlock_stack_prefix (s.push (.s (.try_ handler finalizer (R.env env)))) body (R.env env) inert
  have targetEnvironment : (hoist (s.push (.s (.try_ handler finalizer (R.env env)))) body (R.env env)).1 =
      R.env (hoist (s₀.push (.s (.try_ handler finalizer env))) body env).1 := by
    have relation := post.stack
    rw [sourceStack,targetStack] at relation
    cases relation with
    | cons head _ => exact (StmtF.block.inj (Frame.s.inj head.block_view)).2
  have grow := CellsLive.grow live s₀.next (blockNames body)
  have sourceFrame : ∀ a, live a →
      (enterBlock (s₀.push (.s (.try_ handler finalizer env))) body env).heap.get a = s₀.heap.get a :=
    fun a alive => enterBlock_heap_below (s₀.push (.s (.try_ handler finalizer env))) body env a
      (h.heap.sourceBound a alive) sourceBound inert
  have targetFrame : ∀ a, live a →
      (enterBlock (s.push (.s (.try_ handler finalizer (R.env env)))) body (R.env env)).heap.get (R.a a) = s.heap.get (R.a a) :=
    fun a alive => enterBlock_heap_below (s.push (.s (.try_ handler finalizer (R.env env)))) body (R.env env) (R.a a)
      (h.heap.targetBound a alive) targetBound inert
  have cells := inventory.runtime.cellInventory.frame grow
    (fun a role entry => sourceFrame a (inventory.runtime.keyLive a role entry))
    (fun a role entry => targetFrame a (inventory.runtime.keyLive a role entry))
  refine ⟨left,right,post,⟨cells.keyLive,⟨returnNote_holds .undef,?_,cells.source⟩,
    ⟨returnNote_holds .undef,?_,cells.target⟩⟩,
    inventory.privates.frame grow
      (fun a note entry => sourceFrame a (inventory.privates.keyLive a note entry).1)
      (fun a note entry => targetFrame a (inventory.privates.keyLive a note entry).1),
    inventory.captures.frame grow
      (fun a note entry => sourceFrame a (inventory.captures.keyLive a note entry))
      (fun a note entry => targetFrame a (inventory.captures.keyLive a note entry)),
    inventory.arrays.frame grow
      (fun a roles entry => sourceFrame a (inventory.arrays.keyLive a roles entry))
      (fun a roles entry => targetFrame a (inventory.arrays.keyLive a roles entry)),
    inventory.publicFields.frame grow
      (fun a name role entry => sourceFrame a (inventory.publicFields.keyLive a name role entry))
      (fun a name role entry => targetFrame a (inventory.publicFields.keyLive a name role entry)),
    inventory.buffers.frame grow
      (fun a roles entry => sourceFrame a (inventory.buffers.keyLive a roles entry))
      (fun a roles entry => targetFrame a (inventory.buffers.keyLive a roles entry))⟩
  · rw [RuntimeNotes.bodyEntered,sourceStack,List.map_cons,List.map_cons]
    exact .cons (by simpa only [identity_environment] using
      blockFrameNote_holds ν₀ C₀ identity body (hoist (s₀.push (.s (.try_ handler finalizer env))) body env).1)
      (.cons (emptyScopeNote_holds ν₀ C₀ identity)
        (.cons (by simpa only [identity_environment] using tryFrameNote_holds ν₀ C₀ identity handler finalizer env)
          inventory.runtime.source.stack))
  · rw [RuntimeNotes.bodyEntered,targetStack,List.map_cons,List.map_cons,targetEnvironment]
    exact .cons (blockFrameNote_holds ν C R body (hoist (s₀.push (.s (.try_ handler finalizer env))) body env).1)
      (.cons (emptyScopeNote_holds ν C R)
        (.cons (tryFrameNote_holds ν C R handler finalizer env) inventory.runtime.target.stack))
end Host.Ts.Owned.Annotated
