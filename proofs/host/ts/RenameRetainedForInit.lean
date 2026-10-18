import host.ts.RenameParametricForInit
import host.ts.RenameParameterEffects
import host.ts.RenameRuntimeStatements
import host.ts.RenameRetainedInventory

set_option Elab.async false

namespace Host.Ts.Owned.Annotated
open Parametric

def forTestFrameNote (copy : Bool) (test update : Option Expr) (body : Stmt)
    (env : Env) (names labels : List Name) : Tree :=
  .node "Frame.lp" [.node "LoopF.forTest" [.atom Bool copy,.atom (Option Expr) test,.atom (Option Expr) update,
    .atom Stmt body,environmentNote env,.atom (List Name) names,.atom (List Name) labels]]

theorem forTestFrameNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (copy : Bool)
    (test update : Option Expr) (body : Stmt) (env : Env) (names labels : List Name) :
    (forTestFrameNote copy test update body env names labels).Holds ν C R
      (Encode.frame (.lp (.forTest copy test update body (R.env env) names labels))) := by
  dsimp only [forTestFrameNote,Encode.frame,Encode.loopF,Encode.atom]
  repeat first | exact environmentNote_holds ν C R env | constructor

def RuntimeNotes.forLet (notes : RuntimeNotes) (name : Name) (init : Expr)
    (test update : Option Expr) (body : Stmt) (env : Env) : RuntimeNotes :=
  {notes with control := expressionNote init env, stack := statementFrameNotes env (.declarationInit .let_ (.id name) init []) ++ forTestFrameNote true test update body env [name] []::notes.stack}

/-- The actual lexical for header allocates its uninitialized cell, then
retains the initializer and iteration continuations. Existing cell meanings
remain unchanged; initialization later records the evaluated value's role. -/
theorem RetainedInventory.for_let_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (name : Name) (init : Expr) (test update : Option Expr) (body : Stmt) (env : Env)
    (control : s₀.ctl = .ex (.for_ (some (.decl .let_ [(.id name,some init)])) test update body) env)
    (sourceBound : s₀.next+1 ≤ 2^64) (targetBound : s.next+1 ≤ 2^64) :
    interpC (step F s₀).run C₀ = some (forLetState s₀ name init test update body env,C₀) ∧
      interpC (step F s).run C = some (forLetState s name init test update body (R.env env),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (CellsLive live s₀.next [name]) framed before after old old'
        (forLetState s₀ name init test update body env) (forLetState s name init test update body (R.env env)) ∧
      RetainedInventory (notes.withRuntime (notes.runtime.forLet name init test update body (allocCells s₀ [name] env).1))
        ν₀ ν C₀ C R (CellsLive live s₀.next [name])
        (forLetState s₀ name init test update body env) (forLetState s name init test update body (R.env env)) := by
  obtain ⟨left,right,post⟩ := step_for_let_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h name init test update body env control sourceBound targetBound
  have environmentLive := h.controlLive
  rw [control] at environmentLive
  obtain ⟨_,environmentMap,_⟩ := allocCells_roles h [name] env environmentLive.2.1 sourceBound targetBound
  have grow := CellsLive.grow live s₀.next [name]
  have sourceFrame : ∀ a, live a → (forLetState s₀ name init test update body env).heap.get a = s₀.heap.get a := by
    intro a alive
    exact allocCells_heap_below s₀ [name] env a (h.heap.sourceBound a alive) sourceBound
  have targetFrame : ∀ a, live a → (forLetState s name init test update body (R.env env)).heap.get (R.a a) = s.heap.get (R.a a) := by
    intro a alive
    exact allocCells_heap_below s [name] (R.env env) (R.a a) (h.heap.targetBound a alive) targetBound
  have cells := inventory.runtime.cellInventory.frame grow
    (fun a role entry => sourceFrame a (inventory.runtime.keyLive a role entry))
    (fun a role entry => targetFrame a (inventory.runtime.keyLive a role entry))
  let newEnv := (allocCells s₀ [name] env).1
  have sourceAllocatedStack : (allocCells s₀ [name] env).2.stack = s₀.stack := rfl
  have targetAllocatedStack : (allocCells s [name] (R.env env)).2.stack = s.stack := rfl
  have sourceStack := (statementFrameNotes_holds ν₀ C₀ identity (.declarationInit .let_ (.id name) init []) newEnv).append
    (.cons (forTestFrameNote_holds ν₀ C₀ identity true test update body newEnv [name] []) inventory.runtime.source.stack)
  have targetStack := (statementFrameNotes_holds ν C R (.declarationInit .let_ (.id name) init []) newEnv).append
    (.cons (forTestFrameNote_holds ν C R true test update body newEnv [name] []) inventory.runtime.target.stack)
  have runtime : RuntimeInventory (notes.runtime.forLet name init test update body newEnv) ν₀ ν C₀ C R
      (CellsLive live s₀.next [name]) (forLetState s₀ name init test update body env)
      (forLetState s name init test update body (R.env env)) := by
    refine ⟨cells.keyLive,⟨?_,?_,cells.source⟩,⟨?_,?_,cells.target⟩⟩
    · exact expressionNote_source ν₀ C₀ init newEnv
    · simpa only [RuntimeNotes.forLet,forLetState,StatementAction.advance,St.go,St.push,List.map_append,List.map_cons,identity_environment,sourceAllocatedStack,newEnv] using sourceStack
    · simpa only [RuntimeNotes.forLet,forLetState,StatementAction.advance,StatementAction.control,St.go,environmentMap] using expressionNote_holds ν C R init newEnv
    · simpa only [RuntimeNotes.forLet,forLetState,StatementAction.advance,St.go,St.push,List.map_append,List.map_cons,environmentMap,targetAllocatedStack,newEnv] using targetStack
  exact ⟨left,right,post,runtime,
    inventory.privates.frame grow (fun a role entry => sourceFrame a (inventory.privates.keyLive a role entry).1)
      (fun a role entry => targetFrame a (inventory.privates.keyLive a role entry).1),
    inventory.captures.frame grow (fun a role entry => sourceFrame a (inventory.captures.keyLive a role entry))
      (fun a role entry => targetFrame a (inventory.captures.keyLive a role entry)),
    inventory.arrays.frame grow (fun a roles entry => sourceFrame a (inventory.arrays.keyLive a roles entry))
      (fun a roles entry => targetFrame a (inventory.arrays.keyLive a roles entry)),
    inventory.publicFields.frame grow (fun a field role entry => sourceFrame a (inventory.publicFields.keyLive a field role entry))
      (fun a field role entry => targetFrame a (inventory.publicFields.keyLive a field role entry)),
    inventory.buffers.frame grow (fun a roles entry => sourceFrame a (inventory.buffers.keyLive a roles entry))
      (fun a roles entry => targetFrame a (inventory.buffers.keyLive a roles entry))⟩

end Host.Ts.Owned.Annotated
