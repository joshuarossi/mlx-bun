import host.ts.RenameRetainedInventory
import host.ts.RenameRuntimeParameters
import host.ts.RenameParametricProvidedDefault

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Ts.Owned.Annotated
open Parametric

def RuntimeNotes.parameterProvidedDefault (notes : RuntimeNotes) (fn : Func) (name : Name)
    (default : Expr) (params : List Pat) (roles : List Value) (env : Env) (tail : List Tree) : RuntimeNotes :=
  {notes with
    control := bindingNote (.dflt (.id name) default) (parameterRole roles) env .init .let_,
    stack := parameterFrameNote fn params roles.tail env::tail}

/-- With a provided value for an identifier default pattern, the current
parameter step enters the interpreter's original `.dflt` binding control.
The target argument role and all six retained inventories come from the
current related parameter frame. -/
theorem RetainedInventory.provided_default_parameter_step
    (F : Ffi) (FR : Ren → F.S → F.S → Prop) (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (source target : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (value : Val) (fn : Func) (name : Name) (default : Expr) (params : List Pat)
    (args : List Val) (env : Env) (frames : List Frame) (roles : List Value) (tailNotes : List Tree)
    (control : source.ctl = .ret value)
    (stack : source.stack = .k (.params fn (.dflt (.id name) default::params) args env)::frames)
    (provided : nthD .undef args 0 ≠ .undef)
    (stackNotes : notes.runtime.stack =
      parameterFrameNote fn (.dflt (.id name) default::params) roles env::tailNotes) :
    ∃ result,
      interpC (step F source).run C₀ = some
        (Parametric.parameterProvidedDefault {source with stack := frames} fn name default params args env,C₀) ∧
      interpC (step F target).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (Parametric.parameterProvidedDefault {source with stack := frames} fn name default params args env) result ∧
      RetainedInventory (notes.withRuntime
        (notes.runtime.parameterProvidedDefault fn name default params roles env tailNotes))
        ν₀ ν C₀ C R live
        (Parametric.parameterProvidedDefault {source with stack := frames} fn name default params args env) result ∧
      result.ffi = target.ffi ∧ result.next = target.next ∧ result.heap = target.heap := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨targetArgs,targetFrames,targetStack,sourceRoles,targetRoles,sourceTail,targetTail⟩ :=
    inventory.runtime.parameter_stack_roles h fn (.dflt (.id name) default::params)
      args env frames roles tailNotes stack stackNotes
  obtain ⟨sourceRun,targetRun,targetProvided,related⟩ := step_parameter_provided_default_roles F
    (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' source target h
    value targetValue fn name default params args targetArgs env frames targetFrames
    control targetControl stack targetStack provided
  let sourcePost := Parametric.parameterProvidedDefault
    {source with stack := frames} fn name default params args env
  let targetPost := Parametric.parameterProvidedDefault
    {target with stack := targetFrames} fn name default params targetArgs (R.env env)
  have sourceControlRole : (parameterRole roles).Holds ν₀ C₀ identity (nthD .undef args 0) :=
    parameterRole_holds sourceRoles
  have targetControlRole : (parameterRole roles).Holds ν C R (nthD .undef targetArgs 0) :=
    parameterRole_holds targetRoles
  have sourceControlNote :
      (bindingNote (.dflt (.id name) default) (parameterRole roles) env .init .let_).Holds
        ν₀ C₀ identity (Encode.ctl sourcePost.ctl) := by
    simpa [sourcePost,Parametric.parameterProvidedDefault,St.push,St.go,identity_environment]
      using bindingNote_holds (.dflt (.id name) default) env .init .let_ sourceControlRole
  have targetControlNote :
      (bindingNote (.dflt (.id name) default) (parameterRole roles) env .init .let_).Holds
        ν C R (Encode.ctl targetPost.ctl) := by
    simpa [targetPost,Parametric.parameterProvidedDefault,St.push,St.go]
      using bindingNote_holds (.dflt (.id name) default) env .init .let_ targetControlRole
  have sourceStackNote :
      ForestHolds ν₀ C₀ identity
        (parameterFrameNote fn params roles.tail env::tailNotes) (sourcePost.stack.map Encode.frame) := by
    simpa [sourcePost,Parametric.parameterProvidedDefault,St.push,St.go,identity_environment]
      using ForestHolds.cons
        (parameterFrameNote_holds fn params roles.tail env args.tail
          (parameterRoles_tail sourceRoles)) sourceTail
  have targetStackNote :
      ForestHolds ν C R
        (parameterFrameNote fn params roles.tail env::tailNotes) (targetPost.stack.map Encode.frame) := by
    simpa [targetPost,Parametric.parameterProvidedDefault,St.push,St.go]
      using ForestHolds.cons
        (parameterFrameNote_holds fn params roles.tail env targetArgs.tail
          (parameterRoles_tail targetRoles)) targetTail
  have runtime : RuntimeInventory
      (notes.runtime.parameterProvidedDefault fn name default params roles env tailNotes)
      ν₀ ν C₀ C R live sourcePost targetPost := by
    refine ⟨inventory.runtime.keyLive,?_,?_⟩
    · exact ⟨sourceControlNote,sourceStackNote,inventory.runtime.source.cells⟩
    · exact ⟨targetControlNote,targetStackNote,inventory.runtime.target.cells⟩
  have sourcePure : step F source = M.pure sourcePost := by
    rw [step_parameter_provided_default_actual_eq F source value fn name default params args env frames
      control stack provided]
    rfl
  have targetPure : step F target = M.pure targetPost := by
    rw [step_parameter_provided_default_actual_eq F target targetValue fn name default params targetArgs
      (R.env env) targetFrames targetControl targetStack targetProvided]
    rfl
  have effects : PureRuntimeCase F source target :=
    ⟨.of_pure F source sourcePost sourcePure ⟨rfl,rfl,rfl⟩,
     .of_pure F target targetPost targetPure ⟨rfl,rfl,rfl⟩⟩
  have retained := inventory.pure_step runtime effects sourceRun targetRun
    (TableExtends.refl C₀) (TableExtends.refl C)
  refine ⟨targetPost,sourceRun,targetRun,related,retained,?_,?_,?_⟩
  · rfl
  · rfl
  · rfl

end Host.Ts.Owned.Annotated
