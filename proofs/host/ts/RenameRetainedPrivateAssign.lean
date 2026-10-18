import host.ts.RenameRetainedStores
import host.ts.RenameRetainedHeapFrame
import host.ts.RenameParametricPrivateAssign

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def privateReceiverNote (brand : Nat) (name : Name) (rhs : Expr) (env : Env) : Tree :=
  .node "Frame.a" [.node "AsgF.privObj" [.atom AsgOp .assign,.address brand,.atom Name name,
    .atom Expr rhs,environmentNote env]]
def privatePutNote (role : Value) (brand : Nat) (name : Name) : Tree :=
  .node "Frame.a" [.node "AsgF.put" [.atom (Option BinOp) none,
    .node "Target.priv" [.value role,.address brand,.atom Name name],.value .undef]]
def RuntimeNotes.privateAssignment (notes : RuntimeNotes) (receiver : Expr) (brand : Nat)
    (name : Name) (rhs : Expr) (env : Env) : RuntimeNotes :=
  {notes with control := expressionNote receiver env,stack := privateReceiverNote brand name rhs env::notes.stack}
def RuntimeNotes.privateReceiver (notes : RuntimeNotes) (role : Value) (brand : Nat)
    (name : Name) (rhs : Expr) (env : Env) (tail : List Tree) : RuntimeNotes :=
  {notes with control := expressionNote rhs env,stack := privatePutNote role brand name::tail}

theorem privateReceiverNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren)
    (brand : Nat) (name : Name) (rhs : Expr) (env : Env) :
    (privateReceiverNote brand name rhs env).Holds ν C R
      (Encode.frame (.a (.privObj .assign (R.a brand) name rhs (R.env env)))) :=
  .node _ (.cons (.node _ (.cons (.atom _ _) (.cons (.address brand) (.cons (.atom _ _)
    (.cons (.atom _ _) (.cons (environmentNote_holds ν C R env) .nil)))))) .nil)

theorem privatePutNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren} {role : Value} {value : Val}
    (meaning : role.Holds ν C R value) (brand : Nat) (name : Name) :
    (privatePutNote role brand name).Holds ν C R
      (Encode.frame (.a (.put none (.priv value (R.a brand) name) .undef))) :=
  .node _ (.cons (.node _ (.cons (.atom _ _) (.cons
    (.node _ (.cons (.value meaning) (.cons (.address brand) (.cons (.atom _ _) .nil))))
    (.cons (.value .undef) .nil)))) .nil)

/-- Private assignment entry adds only the source brand, syntax and lexical
environment above the retained caller stack. -/
theorem RetainedInventory.private_assignment_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (receiver : Expr) (name : Name) (opt : Bool) (rhs : Expr) (env : Env) (brand : Nat)
    (control : s₀.ctl = .ev (.assign .assign (.expr (.priv receiver name opt)) rhs) env)
    (lookup : lookupEnv (privName name) env = some brand) :
    let t₀ := (s₀.push (.a (.privObj .assign brand name rhs env))).go (.ev receiver env)
    let t := (s.push (.a (.privObj .assign (R.a brand) name rhs (R.env env)))).go (.ev receiver (R.env env))
    interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
    Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
    RetainedInventory (notes.withRuntime (notes.runtime.privateAssignment receiver brand name rhs env))
      ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨left,right,post⟩ := step_private_assignment_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s₀ s h receiver name opt rhs env brand control lookup
  have sourceBrand : identity.a brand = brand := rfl
  have runtime : RuntimeInventory (notes.runtime.privateAssignment receiver brand name rhs env)
      ν₀ ν C₀ C R live
      ((s₀.push (.a (.privObj .assign brand name rhs env))).go (.ev receiver env))
      ((s.push (.a (.privObj .assign (R.a brand) name rhs (R.env env)))).go (.ev receiver (R.env env))) :=
    ⟨inventory.runtime.keyLive,⟨expressionNote_source ν₀ C₀ receiver env,
      .cons (by simpa only [sourceBrand,identity_environment] using
        privateReceiverNote_holds ν₀ C₀ identity brand name rhs env) inventory.runtime.source.stack,
      inventory.runtime.source.cells⟩,
      ⟨expressionNote_holds ν C R receiver env,.cons (privateReceiverNote_holds ν C R brand name rhs env)
        inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
  exact ⟨left,right,post,inventory.heap_step runtime rfl rfl (TableExtends.refl C₀) (TableExtends.refl C)⟩

/-- Receiver scheduling uses the current retained return role in the actual
private put frame. It reads no future stored value or target field. -/
theorem RetainedInventory.private_receiver_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (brand : Nat) (name : Name) (rhs : Expr) (env : Env) (frames₀ : List Frame)
    (role : Value) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret value) (stack : s₀.stack = .a (.privObj .assign brand name rhs env)::frames₀)
    (controlNote : notes.runtime.control = returnNote role) (stackNotes : notes.runtime.stack = head::tail) :
    ∃ (targetValue : Val) (frames : List Frame),
      let t₀ := privateReceiverState {s₀ with stack := frames₀} value brand name rhs env
      let t := privateReceiverState {s with stack := frames} targetValue (R.a brand) name rhs (R.env env)
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime (notes.runtime.privateReceiver role brand name rhs env tail))
        ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨targetValue,frames,targetControl,left,right,post⟩ := step_private_receiver_from_source F
    (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' s₀ s h value brand name rhs env frames₀ control stack
  obtain ⟨frame,otherFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.privateReceiver_view] at targetStack
  have targetEq : otherFrames = frames := by
    have run : interpC (step F s).run C = some
        (privateReceiverState {s with stack := otherFrames} targetValue (R.a brand) name rhs (R.env env),C) := by
      rw [step_private_receiver_eq F s targetValue (R.a brand) name rhs (R.env env) otherFrames targetControl targetStack]; rfl
    have same := congrArg (fun p => p.1.stack) (Option.some.inj (run.symm.trans right))
    exact List.cons.inj same |>.2
  rw [targetEq] at targetStack
  have sourceStack := inventory.runtime.source.stack
  have targetNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  have sourceMeaning := inventory.runtime.source.control
  have targetMeaning := inventory.runtime.target.control
  rw [controlNote,control] at sourceMeaning
  rw [controlNote,targetControl] at targetMeaning
  have sourceBrand : identity.a brand = brand := rfl
  have runtime : RuntimeInventory (notes.runtime.privateReceiver role brand name rhs env tail)
      ν₀ ν C₀ C R live
      (privateReceiverState {s₀ with stack := frames₀} value brand name rhs env)
      (privateReceiverState {s with stack := frames} targetValue (R.a brand) name rhs (R.env env)) :=
    ⟨inventory.runtime.keyLive,⟨expressionNote_source ν₀ C₀ rhs env,
      .cons (by simpa only [sourceBrand] using privatePutNote_holds (returnNote_view sourceMeaning) brand name)
        sourceStack.tail,inventory.runtime.source.cells⟩,
      ⟨expressionNote_holds ν C R rhs env,
        .cons (privatePutNote_holds (returnNote_view targetMeaning) brand name) targetNotes.tail,
        inventory.runtime.target.cells⟩⟩
  exact ⟨targetValue,frames,left,right,post,
    inventory.heap_step runtime rfl rfl (TableExtends.refl C₀) (TableExtends.refl C)⟩

end Host.Ts.Owned.Annotated
