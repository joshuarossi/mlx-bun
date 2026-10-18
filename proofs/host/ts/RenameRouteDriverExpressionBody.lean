import host.ts.RenameParametricExpressionBody
import host.ts.RenameRouteDriver
namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- Select the real expression-bodied function at a finished parameter list.
The source function shape and exact endpoint are ordinary kernel checks. -/
elab "host_transport_expression_body " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else some stateTy)
    let add (tag : String) (value : Lean.Expr) := addData (pre ++ Name.mkSimple tag) value
    add "sourceValue" (← field (← mkAppM ``St.ctl #[s]) ``Ctl.ret 1 0)
    let stack ← mkAppM ``St.stack #[s]
    add "sourceTail" (← field stack ``List.cons 3 2)
    let fn ← field (← field (← field stack ``List.cons 3 1) ``Frame.k 1 0) ``FnF.params 4 0
    let frame ← field (← field stack ``List.cons 3 1) ``Frame.k 1 0
    add "sourceArgs" (← field frame ``FnF.params 4 2)
    add "sourceEnv" (← field frame ``FnF.params 4 3)
    add "sourceName" (← field fn ``Func.mk 7 0)
    add "sourceParams" (← field fn ``Func.mk 7 1)
    add "sourceExpression" (← field (← field fn ``Func.mk 7 3) ``Body.expr 1 0)
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  emit (header ++ s!"theorem {n}.source_control : {n}.input.ctl = .ret {n}.sourceValue := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_frame : {n}.input.stack = .k (.params
    (.mk {n}.sourceName {n}.sourceParams none (.expr {n}.sourceExpression) false false []) []
    {n}.sourceArgs {n}.sourceEnv)::{n}.sourceTail := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_post : expressionBodyState {n}.input {n}.sourceExpression {n}.sourceEnv {n}.sourceTail =
    {n}.output := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop) (FR : Ren → {n}.F.S → {n}.F.S → Prop)
      (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R live framed before after old old' {n}.output result ∧ result.heap = s.heap := by
    obtain ⟨result,_,hr,hpost,heap⟩ := step_parameter_expression_from_source {n}.F NR FR R C₀ C live framed before after old old'
      {n}.input s h {n}.sourceValue {n}.sourceName {n}.sourceParams {n}.sourceExpression {n}.sourceArgs
      {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame
    exact ⟨result,hr,{n}.source_post ▸ hpost,heap⟩")
end Host.Ts.Owned.Parametric.Driver
