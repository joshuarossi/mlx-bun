import host.ts.RenameRouteDriver
import host.ts.RenameParametricExpressionReturns
import host.ts.RenameParametricDescent

namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- Select and apply proved structural continuation rules at actual source
states. No target constructor, branch, value or execution is supplied. -/
elab "host_transport_structural " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let tag ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      let type? := if tag == "F" then none else
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F))))
      addData (pre ++ Name.mkSimple tag) value type?
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    if ctl.isAppOfArity ``Ctl.ev 2 then
      let e ← whnf ctl.getAppArgs[0]!
      unless e.isAppOfArity ``Expr.bin 3 do
        throwError "host_transport_structural: unsupported expression {e.getAppFn.constName!.toString}"
      let d := mkAppN (mkConst ``Descent.binary) e.getAppArgs
      addData (pre ++ `descent) d
      addData (pre ++ `sourceEnv) ctl.getAppArgs[1]!
      pure 0
    else
      let v ← field ctl ``Ctl.ret 1 0
      let stack ← mkAppM ``St.stack #[s]
      let frame ← field stack ``List.cons 3 1
      let tail ← field stack ``List.cons 3 2
      addData (pre ++ `sourceValue) v
      addData (pre ++ `sourceTail) tail
      let frame ← whnf frame
      if frame.isAppOfArity ``Frame.c 1 then
        let args ← whnf frame.getAppArgs[0]!
        unless args.isAppOfArity ``CallF.args 6 do
          throwError "host_transport_structural: unsupported call frame {args.getAppFn.constName!.toString}"
        for (tag,value) in [("sourceKind",args.getAppArgs[0]!),("sourceFunction",args.getAppArgs[1]!),
          ("sourceThis",args.getAppArgs[2]!),("sourceAcc",args.getAppArgs[3]!),
          ("sourceRest",args.getAppArgs[4]!),("sourceEnv",args.getAppArgs[5]!)] do
          addData (pre ++ Name.mkSimple tag) value
        pure 1
      else
        let e ← field frame ``Frame.e 1 0
        let e ← whnf e
        unless e.isAppOfArity ``ExprF.binL 3 do
          throwError "host_transport_structural: unsupported expression frame {e.getAppFn.constName!.toString}"
        for (tag,value) in [("sourceOp",e.getAppArgs[0]!),("sourceRight",e.getAppArgs[1]!),
          ("sourceEnv",e.getAppArgs[2]!)] do
          addData (pre ++ Name.mkSimple tag) value
        pure 2
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let sourcePost ← if tag == 0 then do
    emit (header ++ s!"theorem {n}.source_control : {n}.input.ctl = .ev {n}.descent.whole {n}.sourceEnv := by host_kernel_rfl")
    pure s!"({n}.input.push ({n}.descent.frame {n}.sourceEnv)).go (.ev {n}.descent.focus {n}.sourceEnv)"
  else do
    emit (header ++ s!"theorem {n}.source_control : {n}.input.ctl = .ret {n}.sourceValue := by host_kernel_rfl")
    if tag == 1 then
      emit (header ++ s!"theorem {n}.source_frame : {n}.input.stack = .c (.args {n}.sourceKind {n}.sourceFunction {n}.sourceThis {n}.sourceAcc {n}.sourceRest {n}.sourceEnv) :: {n}.sourceTail := by host_kernel_rfl")
      pure ("argumentState ({" ++ s!"{n}.input with stack := {n}.sourceTail" ++ "})" ++ s!" {n}.sourceKind {n}.sourceFunction {n}.sourceThis ({n}.sourceValue::{n}.sourceAcc) {n}.sourceRest {n}.sourceEnv")
    else
      emit (header ++ s!"theorem {n}.source_frame : {n}.input.stack = .e (.binL {n}.sourceOp {n}.sourceRight {n}.sourceEnv) :: {n}.sourceTail := by host_kernel_rfl")
      pure ("binaryLeftState ({" ++ s!"{n}.input with stack := {n}.sourceTail" ++ "})" ++ s!" {n}.sourceOp {n}.sourceRight {n}.sourceEnv {n}.sourceValue")
  emit (header ++ s!"theorem {n}.source_post : ({sourcePost}) = {n}.output := by host_kernel_rfl")
  let common := s!"{n}.F NR FR R C₀ C live framed before after old old' {n}.input s h"
  let body := if tag == 0 then s!"
      have hc := (h.control_view {n}.source_control).ev_view
      obtain ⟨_,hr,hpost⟩ := step_descent_roles {common} {n}.descent {n}.sourceEnv (R.env {n}.sourceEnv) {n}.source_control hc
      refine ⟨_,hr,?_⟩
      exact {n}.source_post ▸ hpost"
    else if tag == 1 then s!"
      obtain ⟨result,_,hr,hpost⟩ := step_argument_from_source {common} {n}.sourceValue {n}.sourceKind
        {n}.sourceFunction {n}.sourceThis {n}.sourceAcc {n}.sourceRest {n}.sourceEnv {n}.sourceTail
        {n}.source_control {n}.source_frame (by decide)
      exact ⟨result,hr,{n}.source_post ▸ hpost⟩"
    else s!"
      obtain ⟨result,_,hr,hpost⟩ := step_binary_left_from_source {common} {n}.sourceValue
        {n}.sourceOp {n}.sourceRight {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame
      exact ⟨result,hr,{n}.source_post ▸ hpost⟩"
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (R : Ren) (C₀ C : CSrv)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R live framed before after old old' {n}.output result := by {body}")

end Host.Ts.Owned.Parametric.Driver
