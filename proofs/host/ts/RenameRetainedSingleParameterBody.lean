import host.ts.RenameRetainedParameterBody
import host.ts.RenameRuntimeParameters
import host.ts.RenameRetainedStores
import host.ts.RenameRuntimePureScheduler
import host.ts.RenameRouteComposition

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def singleParameterFunction (functionName : Option Name) (parameterName : Name) (body : List Stmt) : Func :=
  .mk functionName [.id parameterName] none (.block body) false false []

def singleParameterBodyNotes (notes : RetainedNotes) (functionName : Option Name) (parameterName : Name)
    (body : List Stmt) (env bodyEnv : Env) (address : Nat) (role : Value) (tail : List Tree) : RetainedNotes :=
  let fn := singleParameterFunction functionName parameterName body
  let bound := (notes.runtime.parameterArgument fn parameterName [] [role] env tail).initialized address role
  notes.withRuntime (bound.bodyEntered body bodyEnv tail)

private theorem parameter_one (F : Ffi) (source target : St F.S) (C : CSrv)
    (active : isHalt source.ctl = false) (execution : interpC (step F source).run C = some (target,C)) :
    runC F 1 source C = some (target,C) := runC_cons F 0 source target target C C C active execution rfl

/-- Bind the actual last argument and enter its original function block.
The source heap, body, caller and numeric meaning are arbitrary; the stored
parameter annotation follows from the current saved argument occurrence. -/
theorem RetainedInventory.single_parameter_body {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (functionName : Option Name) (parameterName : Name) (body : List Stmt)
    (env : Env) (frames : List Frame) (address : Nat) (value : Val) (role : Value) (tail : List Tree)
    (control : source.ctl = .ret .undef)
    (stack : source.stack = .k (.params (singleParameterFunction functionName parameterName body)
      [.id parameterName] [value] env)::frames)
    (lookup : lookupEnv parameterName env = some address)
    (read : source.heap.get address = some (.cell none))
    (stackNotes : notes.runtime.stack = parameterFrameNote (singleParameterFunction functionName parameterName body)
      [.id parameterName] [role] env::tail)
    (inert : noInitFunctions body = true)
    (sourceBound : source.next+(blockNames body).length ≤ 2^64)
    (targetBound : target.next+(blockNames body).length ≤ 2^64) :
    let base := {(source.setCell address value).ret .undef with stack := frames}
    let bodyEnv := (hoist base body env).1
    let reachedLive := CellsLive live source.next (blockNames body)
    ∃ result,
      runC F 3 source C₀ = some (enterBlock base body env,C₀) ∧
      runC F 3 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R reachedLive framed before after old old'
        (enterBlock base body env) result ∧
      RetainedInventory (singleParameterBodyNotes notes functionName parameterName body env bodyEnv address role tail)
        ν₀ ν C₀ C R reachedLive (enterBlock base body env) result := by
  dsimp only
  let fn := singleParameterFunction functionName parameterName body
  obtain ⟨target1,left1,right1,h1,runtime1⟩ := inventory.runtime.parameter_id_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' source target h .undef fn parameterName [] [value] env frames [role] tail control stack stackNotes
  have pure1 := PureRuntimeCase.parameterId h .undef fn parameterName [] [value] env frames control stack
  have effects1 := pure1.effects left1 right1
  have inv1 := inventory.pure_step runtime1 pure1 left1 right1 (.refl C₀) (.refl C)
  obtain ⟨_,left2,right2,h2,inv2⟩ := inv1.init_step h1 parameterName env address value none .let_ role
    rfl lookup read rfl (by change source.next ≤ 2^64; omega) (by rw [effects1.2.next]; omega)
  obtain ⟨_,left3,right3,h3,inv3⟩ := inv2.parameter_body_step h2 .undef functionName [.id parameterName]
    body [] env frames (parameterFrameNote fn [] [] env) tail rfl rfl rfl inert
    (by change source.next+(blockNames body).length ≤ 2^64; exact sourceBound)
    (by change target1.next+(blockNames body).length ≤ 2^64; rw [effects1.2.next]; exact targetBound)
  have l1 := parameter_one F _ _ C₀ (by rw [control]; rfl) left1
  have r1 := parameter_one F _ _ C (h.control.isHalt_eq.trans (by rw [control]; rfl)) right1
  have l2 := parameter_one F _ _ C₀ rfl left2
  have r2 := parameter_one F _ _ C (h1.control.isHalt_eq.trans rfl) right2
  have l3 := parameter_one F _ _ C₀ rfl left3
  have r3 := parameter_one F _ _ C (h2.control.isHalt_eq.trans rfl) right3
  exact ⟨_,runC_join F (runC_join F l1 l2) l3,runC_join F (runC_join F r1 r2) r3,h3,inv3⟩

end Host.Ts.Owned.Annotated
