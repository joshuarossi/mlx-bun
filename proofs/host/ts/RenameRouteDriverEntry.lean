import host.ts.RenameRouteDriver
import host.ts.RenameParametricExpressionEntry
namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

elab "host_transport_entry " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let tag ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      let type? := if tag == "F" then none else some stateTy
      addData (pre ++ Name.mkSimple tag) value type?
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    let expr ← whnf (← field ctl ``Ctl.ev 2 0)
    let env ← field ctl ``Ctl.ev 2 1
    addData (pre ++ `sourceEnv) env
    if expr.isAppOfArity ``Expr.priv 3 then
      let args := expr.getAppArgs
      for (tag,value) in [("sourceObject",args[0]!),("sourceName",args[1]!), ("sourceOptional",args[2]!)] do
        addData (pre ++ Name.mkSimple tag) value
      let lookup ← mkAppM ``lookupEnv #[← mkAppM ``privName #[args[1]!],env]
      let brand ← field lookup ``Option.some 2 1
      addData (pre ++ `sourceBrand) brand
      pure 0
    else if expr.isAppOfArity ``Expr.call 3 then
      let args := expr.getAppArgs
      let callee ← whnf args[0]!
      let name ← field callee ``Expr.id 1 0
      for (tag,value) in [("sourceName",name),("sourceArgs",args[1]!), ("sourceOptional",args[2]!)] do
        addData (pre ++ Name.mkSimple tag) value
      pure 1
    else if expr.isAppOfArity ``Expr.array 1 then
      let elems := expr.getAppArgs[0]!
      let e ← field (← field elems ``List.cons 3 1) ``Elem.spread 1 0
      let rest ← field elems ``List.cons 3 2
      addData (pre ++ `sourceObject) e
      addData (pre ++ `sourceRest) rest
      pure 2
    else throwError "host_transport_entry: unsupported source expression {expr.getAppFn.constName!.toString}"
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let focus := if tag == 0 || tag == 2 then s!"{n}.sourceObject" else s!"(.id {n}.sourceName)"
  let whole := if tag == 0 then s!"(.priv {focus} {n}.sourceName {n}.sourceOptional)"
    else if tag == 2 then s!"(.array (.spread {focus}::{n}.sourceRest))"
    else s!"(.call {focus} {n}.sourceArgs {n}.sourceOptional)"
  let frame := if tag == 0 then s!"(.e (.priv {n}.sourceBrand {n}.sourceName {n}.sourceOptional))"
    else if tag == 2 then s!"(.l (.spread [] {n}.sourceRest {n}.sourceEnv))"
    else s!"(.c (.callee {n}.sourceArgs {n}.sourceEnv {n}.sourceOptional))"
  emit (header ++ s!"theorem {n}.source_control : {n}.input.ctl = .ev {whole} {n}.sourceEnv := by host_kernel_rfl")
  if tag == 0 then
    emit (header ++ s!"theorem {n}.source_brand : lookupEnv (privName {n}.sourceName) {n}.sourceEnv = some {n}.sourceBrand := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_post : ({n}.input.push {frame}).go (.ev {focus} {n}.sourceEnv) = {n}.output := by host_kernel_rfl")
  let call := if tag == 0 then s!"step_private_descent_from_source {n}.F NR FR R C₀ C live framed before after old old' {n}.input s h {n}.sourceObject {n}.sourceName {n}.sourceOptional {n}.sourceEnv {n}.sourceBrand {n}.source_control {n}.source_brand"
    else if tag == 2 then s!"step_array_spread_entry_from_source {n}.F NR FR R C₀ C live framed before after old old' {n}.input s h {n}.sourceObject {n}.sourceRest {n}.sourceEnv {n}.source_control"
    else s!"step_identifier_call_descent_from_source {n}.F NR FR R C₀ C live framed before after old old' {n}.input s h {n}.sourceName {n}.sourceArgs {n}.sourceOptional {n}.sourceEnv {n}.source_control"
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (R : Ren) (C₀ C : CSrv)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R live framed before after old old' {n}.output result := by
    obtain ⟨_,hr,hpost⟩ := {call}
    exact ⟨_,hr,{n}.source_post ▸ hpost⟩")
elab "host_transport_return_expression " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else some stateTy)
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    let st ← field ctl ``Ctl.ex 2 0
    let e ← field (← field st ``Stmt.ret 1 0) ``Option.some 2 1
    addData (pre ++ `sourceExpression) e
    addData (pre ++ `sourceEnv) (← field ctl ``Ctl.ex 2 1)
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  emit (header ++ s!"theorem {n}.source_control : {n}.input.ctl = .ex (.ret (some {n}.sourceExpression)) {n}.sourceEnv := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_post : (StatementAction.returnExpression {n}.sourceExpression).advance {n}.input {n}.sourceEnv = {n}.output := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (R : Ren) (C₀ C : CSrv)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R live framed before after old old' {n}.output result := by
    obtain ⟨_,hr,hpost⟩ := step_statement_from_source {n}.F NR FR R C₀ C live framed before after old old'
      {n}.input s h (.returnExpression {n}.sourceExpression) {n}.sourceEnv {n}.source_control
    exact ⟨_,hr,{n}.source_post ▸ hpost⟩")

elab "host_transport_bare_callee " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else some stateTy)
    let addr ← field (← mkAppM ``St.ctl #[s] >>= fun ctl => field ctl ``Ctl.ret 1 0) ``Val.obj 1 0
    addData (pre ++ `sourceAddress) addr
    let stack ← mkAppM ``St.stack #[s]
    addData (pre ++ `sourceTail) (← field stack ``List.cons 3 2)
    let cf ← whnf (← field (← field stack ``List.cons 3 1) ``Frame.c 1 0)
    for (tag,i) in [("sourceArgs",0),("sourceEnv",1),("sourceOptional",2)] do
      addData (pre ++ Name.mkSimple tag) (← field cf ``CallF.callee 3 i)
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  emit (header ++ s!"theorem {n}.source_control : {n}.input.ctl = .ret (.obj {n}.sourceAddress) := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_frame : {n}.input.stack = .c (.callee {n}.sourceArgs {n}.sourceEnv {n}.sourceOptional)::{n}.sourceTail := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_run (C₀ : CSrv) : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (R : Ren) (C₀ C : CSrv)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R live framed before after old old' {n}.output result := by
    obtain ⟨result,hr₀,hr,hpost⟩ := step_callStart_from_source {n}.F NR FR R C₀ C live framed before after old old'
      {n}.input s h (.callee {n}.sourceOptional) {n}.sourceAddress .undef {n}.sourceArgs {n}.sourceEnv {n}.sourceTail
      {n}.source_control {n}.source_frame
    rw [{n}.source_run] at hr₀
    have hs := congrArg Prod.fst (Option.some.inj hr₀)
    dsimp only at hs
    rw [← hs] at hpost
    exact ⟨result,hr,hpost⟩")
end Host.Ts.Owned.Parametric.Driver
