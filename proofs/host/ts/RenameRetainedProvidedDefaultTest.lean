import host.ts.RenameRetainedProvidedDefault

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Ts.Owned.Annotated
open Parametric

/-- Concrete constructor guards distinguish a supplied value from a missing
argument whose default is undefined. -/
theorem provided_boolean_guard : nthD .undef [Val.bool true] 0 ≠ .undef := by
  simp [nthD]

theorem missing_undefined_guard : nthD .undef [Val.undef] 0 = .undef := by
  simp [nthD]

theorem missing_cannot_satisfy_provided_guard :
    ¬ (nthD .undef [Val.undef] 0 ≠ .undef) := by
  simp [nthD]

/-- The target guard is inherited from the current `ValueR` relation. -/
theorem related_provided_value_stays_provided {NR : NumV → NumV → Prop} {R : Ren}
    {sourceValue targetValue : Val} (related : Parametric.ValueR NR R sourceValue targetValue)
    (provided : sourceValue ≠ .undef) : targetValue ≠ .undef := by
  intro targetUndefined
  exact provided (related.undef_iff.mpr targetUndefined)

/-- Negative endpoint check: for a supplied value the original step cannot
produce the ordinary identifier-pattern endpoint. -/
theorem original_identifier_endpoint_refuted (F : Ffi) (s : St F.S) (value : Val)
    (fn : Func) (name : Name) (default : Expr) (params : List Pat) (args : List Val)
    (env : Env) (frames : List Frame) (server : CSrv)
    (control : s.ctl = .ret value)
    (stack : s.stack = .k (.params fn (.dflt (.id name) default::params) args env)::frames)
    (provided : nthD .undef args 0 ≠ .undef) :
    interpC (step F s).run server ≠ some
      (Parametric.parameterArgument {s with stack := frames} fn name params args env,server) :=
  Parametric.step_parameter_provided_default_not_parameterArgument F s value fn name default params
    args env frames server control stack provided

/-- Positive endpoint check against the unchanged single-step interpreter. -/
theorem original_step_uses_default_pattern_endpoint (F : Ffi) (s : St F.S) (value : Val)
    (fn : Func) (name : Name) (default : Expr) (params : List Pat) (args : List Val)
    (env : Env) (frames : List Frame)
    (control : s.ctl = .ret value)
    (stack : s.stack = .k (.params fn (.dflt (.id name) default::params) args env)::frames)
    (provided : nthD .undef args 0 ≠ .undef) :
    step F s = M.pure
      (({s with stack := frames}.push (.k (.params fn params args.tail env))).go
        (.bind (.dflt (.id name) default) (nthD .undef args 0) env .init .let_)) :=
  Parametric.step_parameter_provided_default_actual_eq F s value fn name default params args env frames
    control stack provided

end Host.Ts.Owned.Annotated
