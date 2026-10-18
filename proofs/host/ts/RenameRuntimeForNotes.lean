import host.ts.RenameRetainedForInit
import host.ts.RenameParametricForControl

set_option Elab.async false

namespace Host.Ts.Owned.Annotated
open Parametric

def forBodyFrameNote (test update : Option Expr) (body : Stmt) (env : Env) (names labels : List Name) : Tree :=
  .node "Frame.lp" [.node "LoopF.forBody" [.atom (Option Expr) test,.atom (Option Expr) update,
    .atom Stmt body,environmentNote env,.atom (List Name) names,.atom (List Name) labels]]
def forUpdateFrameNote (test update : Option Expr) (body : Stmt) (env : Env) (names labels : List Name) : Tree :=
  .node "Frame.lp" [.node "LoopF.forUpd" [.atom (Option Expr) test,.atom (Option Expr) update,
    .atom Stmt body,environmentNote env,.atom (List Name) names,.atom (List Name) labels]]

theorem forBodyFrameNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren)
    (test update : Option Expr) (body : Stmt) (env : Env) (names labels : List Name) :
    (forBodyFrameNote test update body env names labels).Holds ν C R
      (Encode.frame (.lp (.forBody test update body (R.env env) names labels))) := by
  dsimp only [forBodyFrameNote,Encode.frame,Encode.loopF,Encode.atom]
  repeat first | exact environmentNote_holds ν C R env | constructor
theorem forUpdateFrameNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren)
    (test update : Option Expr) (body : Stmt) (env : Env) (names labels : List Name) :
    (forUpdateFrameNote test update body env names labels).Holds ν C R
      (Encode.frame (.lp (.forUpd test update body (R.env env) names labels))) := by
  dsimp only [forUpdateFrameNote,Encode.frame,Encode.loopF,Encode.atom]
  repeat first | exact environmentNote_holds ν C R env | constructor

def RuntimeNotes.forTest (notes : RuntimeNotes) (test update : Option Expr) (body : Stmt)
    (env : Env) (names labels : List Name) (tail : List Tree) : RuntimeNotes :=
  match test with
  | some expression => {notes with control := expressionNote expression env, stack := forBodyFrameNote test update body env names labels::tail}
  | none => {notes with control := statementNote body env, stack := forUpdateFrameNote test update body env names labels::tail}
def RuntimeNotes.forUpdate (notes : RuntimeNotes) (test update : Option Expr) (body : Stmt)
    (env : Env) (names labels : List Name) (tail : List Tree) : RuntimeNotes :=
  match update with
  | some expression => {notes with control := expressionNote expression env, stack := forTestFrameNote false test update body env names labels::tail}
  | none => notes.forTest test update body env names labels tail
def RuntimeNotes.forBody (notes : RuntimeNotes) (guard : Bool) (test update : Option Expr) (body : Stmt)
    (env : Env) (names labels : List Name) (tail : List Tree) : RuntimeNotes :=
  if guard then {notes with control := statementNote body env, stack := forUpdateFrameNote test update body env names labels::tail}
  else {notes with control := returnNote .undef, stack := tail}
def RuntimeNotes.copyIndex (notes : RuntimeNotes) (fresh : Nat) (role : Value) : RuntimeNotes :=
  {notes with cells := notes.cells.write fresh role}

theorem RuntimeNotes.forTest_holds {S : Type} (notes : RuntimeNotes) (ν : Nat → F64) (C : CSrv) (R : Ren)
    (test update : Option Expr) (body : Stmt) (env : Env) (names labels : List Name) (tail : List Tree) (s : St S)
    (frames : ForestHolds ν C R tail (s.stack.map Encode.frame)) (cells : notes.cells.Holds ν C R s) :
    (notes.forTest test update body env names labels tail).Holds ν C R
      (forTestState s test update body (R.env env) names labels) := by
  cases test with
  | none => exact ⟨statementNote_holds ν C R body env,
      .cons (forUpdateFrameNote_holds ν C R none update body env names labels) frames,cells⟩
  | some expression => exact ⟨expressionNote_holds ν C R expression env,
      .cons (forBodyFrameNote_holds ν C R (some expression) update body env names labels) frames,cells⟩
theorem RuntimeNotes.forUpdate_holds {S : Type} (notes : RuntimeNotes) (ν : Nat → F64) (C : CSrv) (R : Ren)
    (test update : Option Expr) (body : Stmt) (env : Env) (names labels : List Name) (tail : List Tree) (s : St S)
    (frames : ForestHolds ν C R tail (s.stack.map Encode.frame)) (cells : notes.cells.Holds ν C R s) :
    (notes.forUpdate test update body env names labels tail).Holds ν C R
      (forUpdateState s test update body (R.env env) names labels) := by
  cases update with
  | none => exact notes.forTest_holds ν C R test none body env names labels tail s frames cells
  | some expression => exact ⟨expressionNote_holds ν C R expression env,
      .cons (forTestFrameNote_holds ν C R false test (some expression) body env names labels) frames,cells⟩
theorem RuntimeNotes.forBody_holds {S : Type} (notes : RuntimeNotes) (ν : Nat → F64) (C : CSrv) (R : Ren)
    (guard : Bool) (test update : Option Expr) (body : Stmt) (env : Env) (names labels : List Name) (tail : List Tree) (s : St S)
    (frames : ForestHolds ν C R tail (s.stack.map Encode.frame)) (cells : notes.cells.Holds ν C R s) :
    (notes.forBody guard test update body env names labels tail).Holds ν C R
      (forBodyState s guard test update body (R.env env) names labels) := by
  cases guard with
  | false => exact ⟨returnNote_holds .undef,frames,cells⟩
  | true => exact ⟨statementNote_holds ν C R body env,
      .cons (forUpdateFrameNote_holds ν C R test update body env names labels) frames,cells⟩

/-- Pointwise effects below the live boundary retain every non-runtime
family across lexical allocation and scheduling. New cell notes are supplied
by the checked allocation/copy rule. -/
theorem RetainedInventory.grow_heap_step {S : Type} {notes : RetainedNotes} {runtimeNotes : RuntimeNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live newLive : Nat → Prop} {s₀ s t₀ t : St S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (runtime : RuntimeInventory runtimeNotes ν₀ ν C₀ C R newLive t₀ t)
    (grow : ∀ a, live a → newLive a)
    (source : ∀ a, live a → t₀.heap.get a = s₀.heap.get a)
    (target : ∀ a, live a → t.heap.get (R.a a) = s.heap.get (R.a a)) :
    RetainedInventory (notes.withRuntime runtimeNotes) ν₀ ν C₀ C R newLive t₀ t :=
  ⟨runtime,
    inventory.privates.frame grow (fun a role entry => source a (inventory.privates.keyLive a role entry).1)
      (fun a role entry => target a (inventory.privates.keyLive a role entry).1),
    inventory.captures.frame grow (fun a role entry => source a (inventory.captures.keyLive a role entry))
      (fun a role entry => target a (inventory.captures.keyLive a role entry)),
    inventory.arrays.frame grow (fun a roles entry => source a (inventory.arrays.keyLive a roles entry))
      (fun a roles entry => target a (inventory.arrays.keyLive a roles entry)),
    inventory.publicFields.frame grow (fun a field role entry => source a (inventory.publicFields.keyLive a field role entry))
      (fun a field role entry => target a (inventory.publicFields.keyLive a field role entry)),
    inventory.buffers.frame grow (fun a roles entry => source a (inventory.buffers.keyLive a roles entry))
      (fun a roles entry => target a (inventory.buffers.keyLive a roles entry))⟩

end Host.Ts.Owned.Annotated
