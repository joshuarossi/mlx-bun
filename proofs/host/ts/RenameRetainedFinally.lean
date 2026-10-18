import host.ts.RenameRetainedParameterBody
import host.ts.RenameRetainedHeapFrame
import host.ts.RenameParametricFinally
import host.ts.RenameRuntimeReturns
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def finallyObjectNote (a : Nat) : Tree :=
  .node "Frame.s" [.node "StmtF.finally_" [.node "Comp.abrupt" [.node "Abrupt.ret" [.value (.obj a)]]]]
theorem finallyObjectNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (a : Nat) :
    (finallyObjectNote a).Holds ν C R (Encode.frame (.s (.finally_ (.abrupt (.ret (.obj (R.a a))))))) := by
  repeat constructor

theorem enterBlock_no_cells {S : Type} (s : St S) (body : List Stmt) (env : Env)
    (inert : noInitFunctions body = true) (names : blockNames body = []) :
    enterBlock s body env = ((s.push (.s (.scope []))).push (.s (.block body env))).ret .undef := by
  unfold enterBlock
  rw [hoist_inert_eq _ _ _ inert,names]
  rfl

/-- The array-returning route saves its actual returned object while entering
the original cleanup block. Its checked syntax allocates no lexical cells;
the saved object, all retained fields and native state survive unchanged. -/
theorem RetainedInventory.return_finally_object_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (a : Nat) (handler : Option (Option Pat × List Stmt)) (fin : List Stmt) (env : Env)
    (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .abr (.ret (.obj a))) (stack : s₀.stack = .s (.try_ handler (some fin) env)::frames)
    (stackNotes : notes.runtime.stack = head::tail) (inert : noInitFunctions fin = true) (names : blockNames fin = [])
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ targetFrames,
      let t₀ := enterBlock ({s₀ with stack := frames}.push (.s (.finally_ (.abrupt (.ret (.obj a)))))) fin env
      let t := enterBlock ({s with stack := targetFrames}.push (.s (.finally_ (.abrupt (.ret (.obj (R.a a))))))) fin (R.env env)
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (CellsLive live s₀.next (blockNames fin)) framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime (notes.runtime.bodyEntered fin env (finallyObjectNote a::tail)))
        ν₀ ν C₀ C R (CellsLive live s₀.next (blockNames fin)) t₀ t := by
  obtain ⟨value,targetControl,valueRelation⟩ := (h.control_view control).returnAbrupt_view
  cases valueRelation
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.try_view] at targetStack
  obtain ⟨other,otherFrames,left,right,post⟩ := step_return_finally_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s₀ s h (.obj a) handler fin env frames control stack inert
    (by simpa only [names,List.length_nil,Nat.add_zero] using sourceBound)
    (by simpa only [names,List.length_nil,Nat.add_zero] using targetBound)
  have actual : interpC (step F s).run C = some
      (enterBlock ({s with stack := targetFrames}.push (.s (.finally_ (.abrupt (.ret (.obj (R.a a))))))) fin (R.env env),C) := by
    rw [step_return_finally_eq F s (.obj (R.a a)) handler fin (R.env env) targetFrames targetControl targetStack]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (right.symm.trans actual))
  dsimp only at same
  rw [same] at post
  have sourceHeap : (enterBlock ({s₀ with stack := frames}.push (.s (.finally_ (.abrupt (.ret (.obj a)))))) fin env).heap = s₀.heap := by
    rw [enterBlock_no_cells _ fin env inert names]; rfl
  have targetHeap : (enterBlock ({s with stack := targetFrames}.push (.s (.finally_ (.abrupt (.ret (.obj (R.a a))))))) fin (R.env env)).heap = s.heap := by
    rw [enterBlock_no_cells _ fin (R.env env) inert names]; rfl
  have sourceNotes := inventory.runtime.source.stack
  have targetNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  have grow := CellsLive.grow live s₀.next (blockNames fin)
  have cells := inventory.runtime.cellInventory.frame grow
    (fun _ _ _ => by rw [sourceHeap]) (fun _ _ _ => by rw [targetHeap])
  refine ⟨targetFrames,left,actual,post,⟨cells.keyLive,⟨returnNote_holds .undef,?_,cells.source⟩,
    ⟨returnNote_holds .undef,?_,cells.target⟩⟩,
    inventory.privates.frame grow (fun _ _ _ => by rw [sourceHeap]) (fun _ _ _ => by rw [targetHeap]),
    inventory.captures.frame grow (fun _ _ _ => by rw [sourceHeap]) (fun _ _ _ => by rw [targetHeap]),
    inventory.arrays.frame grow (fun _ _ _ => by rw [sourceHeap]) (fun _ _ _ => by rw [targetHeap]),
    inventory.publicFields.frame grow (fun _ _ _ _ => by rw [sourceHeap]) (fun _ _ _ _ => by rw [targetHeap]),
    inventory.buffers.frame grow (fun _ _ _ => by rw [sourceHeap]) (fun _ _ _ => by rw [targetHeap])⟩
  · rw [RuntimeNotes.bodyEntered,enterBlock_no_cells _ fin env inert names]
    exact .cons (by simpa only [identity_environment] using blockFrameNote_holds ν₀ C₀ identity fin env)
      (.cons (emptyScopeNote_holds ν₀ C₀ identity) (.cons (finallyObjectNote_holds ν₀ C₀ identity a) sourceNotes.tail))
  · rw [RuntimeNotes.bodyEntered,enterBlock_no_cells _ fin (R.env env) inert names]
    exact .cons (blockFrameNote_holds ν C R fin env)
      (.cons (emptyScopeNote_holds ν C R) (.cons (finallyObjectNote_holds ν C R a) targetNotes.tail))

/-- Normal completion of cleanup resumes the object saved by the real
finally frame. The cleanup expression's result is discarded by the original
interpreter, and the current native relation and retained data are preserved. -/
theorem RetainedInventory.finally_object_resume_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (initial : Val) (a : Nat) (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret initial) (stack : s₀.stack = .s (.finally_ (.abrupt (.ret (.obj a))))::frames)
    (stackNotes : notes.runtime.stack = head::tail) :
    ∃ targetFrames,
      interpC (step F s₀).run C₀ = some ({s₀ with stack := frames}.go (.abr (.ret (.obj a))),C₀) ∧
      interpC (step F s).run C = some ({s with stack := targetFrames}.go (.abr (.ret (.obj (R.a a)))),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := frames}.go (.abr (.ret (.obj a))))
        ({s with stack := targetFrames}.go (.abr (.ret (.obj (R.a a))))) ∧
      RetainedInventory (notes.withRuntime ⟨abruptReturnNote (.obj a),tail,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live ({s₀ with stack := frames}.go (.abr (.ret (.obj a))))
        ({s with stack := targetFrames}.go (.abr (.ret (.obj (R.a a))))) := by
  obtain ⟨value,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  obtain ⟨pending,frameEquation,pendingRelation⟩ := frameRelation.finally_return_view
  cases pendingRelation
  rw [frameEquation] at targetStack
  obtain ⟨other,otherFrames,left,right,post⟩ := step_finally_return_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s₀ s h initial (.obj a) frames control stack
  have actual : interpC (step F s).run C =
      some ({s with stack := targetFrames}.go (.abr (.ret (.obj (R.a a)))),C) := by
    rw [step_finally_return_eq F s value (.obj (R.a a)) targetFrames targetControl targetStack]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (right.symm.trans actual))
  dsimp only at same
  rw [same] at post
  have sourceNotes := inventory.runtime.source.stack
  have targetNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  have runtime : RuntimeInventory ⟨abruptReturnNote (.obj a),tail,notes.runtime.cells⟩ ν₀ ν C₀ C R live
      ({s₀ with stack := frames}.go (.abr (.ret (.obj a))))
      ({s with stack := targetFrames}.go (.abr (.ret (.obj (R.a a))))) :=
    ⟨inventory.runtime.keyLive,⟨abruptReturnNote_holds (.obj a),sourceNotes.tail,inventory.runtime.source.cells⟩,
      ⟨abruptReturnNote_holds (.obj a),targetNotes.tail,inventory.runtime.target.cells⟩⟩
  exact ⟨targetFrames,left,actual,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩
end Host.Ts.Owned.Annotated
