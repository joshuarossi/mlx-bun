import host.ts.RenameRetainedInventory
import host.ts.RenameRuntimeStatements
import host.ts.RenameClosureStackEffects
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def emptyScopeNote : Tree := .node "Frame.s" [.node "StmtF.scope" [.node "List" []]]
theorem emptyScopeNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) :
    emptyScopeNote.Holds ν C R (Encode.frame (.s (.scope []))) := by repeat constructor
def RuntimeNotes.bodyEntered (notes : RuntimeNotes) (body : List Stmt) (env : Env) (tail : List Tree) : RuntimeNotes :=
  ⟨returnNote .undef,blockFrameNote body env::emptyScopeNote::tail,notes.cells⟩

/-- Completing the original synchronous parameter scheduler enters its actual
block and allocates its real lexical cells. The source-AST `noInitFunctions`
guard is checked separately; no assumed target body or allocation is supplied. -/
theorem RetainedInventory.parameter_body_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (value : Val) (name : Option Name) (params : List Pat) (body : List Stmt) (args : List Val) (env : Env)
    (frames : List Frame) (head : Tree) (tail : List Tree) (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .k (.params (.mk name params none (.block body) false false []) [] args env)::frames)
    (stackNotes : notes.runtime.stack = head::tail) (inert : noInitFunctions body = true)
    (sourceBound : s₀.next+(blockNames body).length ≤ 2^64) (targetBound : s.next+(blockNames body).length ≤ 2^64) :
    ∃ targetFrames,
      let t₀ := enterBlock {s₀ with stack := frames} body env
      let t := enterBlock {s with stack := targetFrames} body (R.env env)
      let bodyEnv := (hoist {s₀ with stack := frames} body env).1
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (CellsLive live s₀.next (blockNames body))
        framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime (notes.runtime.bodyEntered body bodyEnv tail)) ν₀ ν C₀ C R
        (CellsLive live s₀.next (blockNames body)) t₀ t := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  obtain ⟨targetArgs,frameEq,_⟩ := frameRelation.params_view
  rw [frameEq] at targetStack
  obtain ⟨sourceRun,targetRun,post⟩ := step_parameter_body_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h value targetValue name params body args targetArgs env frames targetFrames
    control targetControl stack targetStack inert sourceBound targetBound
  have sourceNotes := inventory.runtime.source.stack
  have targetNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  have sourceStack := enterBlock_stack_prefix {s₀ with stack := frames} body env inert
  have targetStack' := enterBlock_stack_prefix {s with stack := targetFrames} body (R.env env) inert
  have targetEnvironment : (hoist {s with stack := targetFrames} body (R.env env)).1 =
      R.env (hoist {s₀ with stack := frames} body env).1 := by
    have relation := post.stack
    rw [sourceStack,targetStack'] at relation
    cases relation with
    | cons head _ => exact (StmtF.block.inj (Frame.s.inj head.block_view)).2
  have grow := CellsLive.grow live s₀.next (blockNames body)
  have sourceFrame : ∀ b, live b →
      (enterBlock {s₀ with stack := frames} body env).heap.get b = s₀.heap.get b :=
    fun b alive => enterBlock_heap_below {s₀ with stack := frames} body env b (h.heap.sourceBound b alive) sourceBound inert
  have targetFrame : ∀ b, live b →
      (enterBlock {s with stack := targetFrames} body (R.env env)).heap.get (R.a b) = s.heap.get (R.a b) :=
    fun b alive => enterBlock_heap_below {s with stack := targetFrames} body (R.env env) (R.a b)
      (h.heap.targetBound b alive) targetBound inert
  have cells := inventory.runtime.cellInventory.frame grow
    (fun b role entry => sourceFrame b (inventory.runtime.keyLive b role entry))
    (fun b role entry => targetFrame b (inventory.runtime.keyLive b role entry))
  have runtime : RuntimeInventory
      (notes.runtime.bodyEntered body (hoist {s₀ with stack := frames} body env).1 tail) ν₀ ν C₀ C R
      (CellsLive live s₀.next (blockNames body))
      (enterBlock {s₀ with stack := frames} body env) (enterBlock {s with stack := targetFrames} body (R.env env)) := by
    refine ⟨cells.keyLive,⟨returnNote_holds .undef,?_,cells.source⟩,⟨returnNote_holds .undef,?_,cells.target⟩⟩
    · rw [RuntimeNotes.bodyEntered,sourceStack,List.map_cons,List.map_cons]
      exact .cons (by simpa only [identity_environment] using
        blockFrameNote_holds ν₀ C₀ identity body (hoist {s₀ with stack := frames} body env).1)
        (.cons (emptyScopeNote_holds ν₀ C₀ identity) sourceNotes.tail)
    · rw [RuntimeNotes.bodyEntered,targetStack',List.map_cons,List.map_cons,targetEnvironment]
      exact .cons (blockFrameNote_holds ν C R body (hoist {s₀ with stack := frames} body env).1)
        (.cons (emptyScopeNote_holds ν C R) targetNotes.tail)
  exact ⟨targetFrames,sourceRun,targetRun,post,runtime,
    inventory.privates.frame grow
      (fun b note entry => sourceFrame b (inventory.privates.keyLive b note entry).1)
      (fun b note entry => targetFrame b (inventory.privates.keyLive b note entry).1),
    inventory.captures.frame grow
      (fun b note entry => sourceFrame b (inventory.captures.keyLive b note entry))
      (fun b note entry => targetFrame b (inventory.captures.keyLive b note entry)),
    inventory.arrays.frame grow
      (fun b roles entry => sourceFrame b (inventory.arrays.keyLive b roles entry))
      (fun b roles entry => targetFrame b (inventory.arrays.keyLive b roles entry)),
    inventory.publicFields.frame grow
      (fun b name role entry => sourceFrame b (inventory.publicFields.keyLive b name role entry))
      (fun b name role entry => targetFrame b (inventory.publicFields.keyLive b name role entry)),
    inventory.buffers.frame grow
      (fun b roles entry => sourceFrame b (inventory.buffers.keyLive b roles entry))
      (fun b roles entry => targetFrame b (inventory.buffers.keyLive b roles entry))⟩
end Host.Ts.Owned.Annotated
