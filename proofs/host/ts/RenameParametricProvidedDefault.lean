import host.ts.RenameParametricParameters

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Ts.Owned.Parametric

/-- The current machine code leaves a provided default-pattern argument under
the original `.dflt` binding control for one transition. -/
theorem step_parameter_provided_default_actual_eq (F : Ffi) (s : St F.S) (value : Val)
    (fn : Func) (name : Name) (default : Expr) (params : List Pat)
    (args : List Val) (env : Env) (frames : List Frame)
    (control : s.ctl = .ret value)
    (stack : s.stack = .k (.params fn (.dflt (.id name) default::params) args env)::frames)
    (provided : nthD .undef args 0 ≠ .undef) :
    step F s = M.pure
      (({s with stack := frames}.push (.k (.params fn params args.tail env))).go
        (.bind (.dflt (.id name) default) (nthD .undef args 0) env .init .let_)) := by
  cases args with
  | nil => simp [nthD] at provided
  | cons first rest =>
    cases first <;> simp_all [step,stepRet,retStep,retK,paramsNext]

/-- For a non-undefined argument, that actual transition has a different
control from the ordinary identifier `parameterArgument` endpoint. -/
theorem step_parameter_provided_default_not_parameterArgument (F : Ffi) (s : St F.S)
    (value : Val) (fn : Func) (name : Name) (default : Expr) (params : List Pat)
    (args : List Val) (env : Env) (frames : List Frame) (server : CSrv)
    (control : s.ctl = .ret value)
    (stack : s.stack = .k (.params fn (.dflt (.id name) default::params) args env)::frames)
    (provided : nthD .undef args 0 ≠ .undef) :
    interpC (step F s).run server ≠ some
      (parameterArgument {s with stack := frames} fn name params args env,server) := by
  let actual :=
    ({s with stack := frames}.push (.k (.params fn params args.tail env))).go
      (.bind (.dflt (.id name) default) (nthD .undef args 0) env .init .let_)
  have actualRun : interpC (step F s).run server = some (actual,server) := by
    rw [step_parameter_provided_default_actual_eq F s value fn name default params args env frames
      control stack provided]
    rfl
  have controlsDiffer : actual ≠ parameterArgument {s with stack := frames} fn name params args env := by
    intro same
    have controlEq := congrArg St.ctl same
    simp [actual,parameterArgument,St.push,St.go] at controlEq
  intro claimed
  have statesEqual := congrArg Prod.fst (Option.some.inj (actualRun.symm.trans claimed))
  exact controlsDiffer statesEqual

end Host.Ts.Owned.Parametric
