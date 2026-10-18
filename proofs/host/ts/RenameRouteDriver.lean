import host.ts.RenameKernelRfl
import host.ts.RenameParametricViews
import host.ts.RenameParametricVariables
import host.ts.RenameParametricLiteral
import Lean

namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

private def addData (name : Lean.Name) (value : Lean.Expr) (type? : Option Lean.Expr := none) : TermElabM Unit := do
  addDecl (.defnDecl {
    name := name
    levelParams := []
    type := ← match type? with | some type => pure type | none => inferType value
    value := value
    hints := if name.getString! = "F" then .abbrev else .regular 0
    safety := .safe })

private def field (e : Lean.Expr) (constructor : Lean.Name) (arity index : Nat) : TermElabM Lean.Expr := do
  let e ← whnf e
  unless e.isAppOfArity constructor arity do
    throwError "host_transport_step: unsupported source constructor {e.getAppFn.constName!.toString}"
  pure e.getAppArgs[index]!

private def emit (source : String) : CommandElabM Unit := do
  let stx ← match Parser.runParserCategory (← getEnv) `command source with
    | .ok stx => pure stx
    | .error message => throwError "host_transport_step generated syntax: {message}"
  withScope (fun scope => { scope with opts := scope.opts.setBool `Elab.async false }) (elabCommand stx)

/-- Name an object selected from an actual source heap. Subsequent facts about
that object are checked using its ordinary Lean definition. -/
elab "host_transport_object " p:ident i:num a:num " as " name:ident : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let s := mkConst (pre ++ Name.mkSimple s!"s{i.getNat}")
  let object ← field (← mkAppM ``St.obj? #[s,mkRawNatLit a.getNat]) ``Option.some 2 1
  addData ((← getCurrNamespace) ++ name.getId) (← whnf object)

/-- Inspect an actual source state and emit a checked transport application.
Every source observation and the exact selected endpoint are checked by the
kernel. Unsupported dispatch cases stop with an error; a target run, target
callee shape, and target argument roles are never accepted as premises.

The closure case is selected from the actual `Machine.step` control and live
heap object; variable and literal cases are selected from source syntax. -/
elab "host_transport_closure " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.call 3 do
      throwError "host_transport_step: unsupported source control {ctl.getAppFn.constName!.toString}"
    let callee := ctl.getAppArgs[0]!
    let a ← field callee ``Val.obj 1 0
    let object ← field (← mkAppM ``St.obj? #[s,a]) ``Option.some 2 1
    let code ← field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0
    let code ← whnf code
    unless code.isAppOfArity ``Code.closure 4 do
      throwError "host_transport_step: unsupported source callee {code.getAppFn.constName!.toString}"
    for (tag,value) in [("F",f),("input",s),("output",t),("address",a),("object",object),
      ("sourceFunction",code.getAppArgs[0]!),("sourceEnv",code.getAppArgs[1]!),
      ("sourceArrow",code.getAppArgs[2]!),("sourceHome",code.getAppArgs[3]!),
      ("sourceThis",ctl.getAppArgs[1]!),("sourceArgs",ctl.getAppArgs[2]!)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  emit (header ++ s!"theorem {n}.source_control : {n}.input.ctl = .call (.obj {n}.address) {n}.sourceThis {n}.sourceArgs := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_heap : {n}.input.heap.get {n}.address = some (.obj {n}.object) := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_kind : {n}.object.kind = .fn (.closure {n}.sourceFunction {n}.sourceEnv {n}.sourceArrow {n}.sourceHome) := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (R : Ren) (C₀ C : CSrv)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S)
      (h : StateR NR FR R live framed before after old old' {n}.input s)
      (ht : s.next + 2 + (paramNames {n}.sourceFunction).length ≤ 2^64) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R (ClosureLive live {n}.input.next {n}.sourceArrow {n}.sourceHome {n}.sourceFunction)
          framed before after old old' {n}.output result := by
    obtain ⟨callee,this,args,hc,hcallee,_,_⟩ := (h.control_view {n}.source_control).call_view
    have heq : callee = .obj (R.a {n}.address) := by cases hcallee; rfl
    rw [heq] at hc
    obtain ⟨result₀,result,hr₀,hr,hpost⟩ := step_closure_from_state {n}.F NR FR R C₀ C live framed
      before after old old' {n}.input s h {n}.address {n}.object {n}.sourceFunction {n}.sourceEnv
      {n}.sourceArrow {n}.sourceHome {n}.sourceThis this {n}.sourceArgs args
      {n}.source_control hc {n}.source_heap {n}.source_kind (by decide) ht
    rw [{n}.source_run] at hr₀
    have heq : {n}.output = result₀ := congrArg Prod.fst (Option.some.inj hr₀)
    exact ⟨result,hr,heq.symm ▸ hpost⟩")

/-- An initialized variable read derives its target cell and numeric/handle
role from the selected live source cell. -/
elab "host_transport_variable " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    let e ← field ctl ``Ctl.ev 2 0
    let identifier ← field e ``Expr.id 1 0
    let env := ctl.getAppArgs[1]!
    let a ← field (← mkAppM ``lookupEnv #[identifier,env]) ``Option.some 2 1
    let initialized ← field (← mkAppM ``St.cell? #[s,a]) ``Option.some 2 1
    let value ← field initialized ``Option.some 2 1
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceName",identifier),
      ("sourceEnv",env),("address",a),("sourceValue",value)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  emit (header ++ s!"theorem {n}.source_control : {n}.input.ctl = .ev (.id {n}.sourceName) {n}.sourceEnv := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_lookup : lookupEnv {n}.sourceName {n}.sourceEnv = some {n}.address := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_cell : {n}.input.heap.get {n}.address = some (.cell (some {n}.sourceValue)) := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_post : {n}.input.ret {n}.sourceValue = {n}.output := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (R : Ren) (C₀ C : CSrv)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S)
      (h : StateR NR FR R live framed before after old old' {n}.input s) :
      ∃ value, interpC (step {n}.F s).run C = some (s.ret value,C) ∧
        StateR NR FR R live framed before after old old' {n}.output (s.ret value) ∧
        ValueR NR R {n}.sourceValue value := by
    have hc := (h.control_view {n}.source_control).ev_view
    have henv : treeSupport live (Encode.env {n}.sourceEnv) := by
      have hl := h.controlLive
      rw [{n}.source_control] at hl
      exact hl.2.1
    have ha := env_lookup_live {n}.sourceName {n}.sourceEnv {n}.address henv {n}.source_lookup
    obtain ⟨value,_,hr,hpost,hvalue⟩ := step_variable_roles {n}.F NR FR R C₀ C live framed
      before after old old' {n}.input s h {n}.sourceName {n}.sourceEnv {n}.address {n}.sourceValue
      {n}.source_control hc {n}.source_lookup ha {n}.source_cell
    rw [{n}.source_post] at hpost
    exact ⟨value,hr,hpost,hvalue⟩")

/-- The real literal parser fixes the output's occurrence annotation. -/
elab "host_transport_literal " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    let e ← field ctl ``Ctl.ev 2 0
    let literal ← field e ``Expr.lit 1 0
    let value ← field (← mkAppM ``St.ctl #[t]) ``Ctl.ret 1 0
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceLiteral",literal),
      ("sourceEnv",ctl.getAppArgs[1]!),("sourceValue",value)] do
      let type? := if tag == "input" || tag == "output" then
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))) else none
      addData (pre ++ Name.mkSimple tag) value type?
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  emit (header ++ s!"theorem {n}.source_control : {n}.input.ctl = .ev (.lit {n}.sourceLiteral) {n}.sourceEnv := by host_kernel_rfl")
  emit (header ++ s!"noncomputable def {n}.parsed : LiteralValue {n}.sourceLiteral {n}.sourceValue := by constructor <;> host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_post : {n}.input.ret {n}.sourceValue = {n}.output := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.transport (FR : Ren → {n}.F.S → {n}.F.S → Prop)
      (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s) :
      interpC (step {n}.F s).run C = some (s.ret {n}.sourceValue,C) ∧
        StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output (s.ret {n}.sourceValue) ∧
        {n}.parsed.role.Holds ν₀ C₀ Annotated.identity {n}.sourceValue ∧
        {n}.parsed.role.Holds ν C R {n}.sourceValue := by
    obtain ⟨_,hr,hpost,hleft,hright⟩ := step_literal_from_source {n}.F FR R ν₀ ν C₀ C live framed
      before after old old' {n}.input s h {n}.sourceLiteral {n}.sourceValue {n}.sourceEnv {n}.parsed {n}.source_control
    rw [{n}.source_post] at hpost
    exact ⟨hr,hpost,hleft,hright⟩")

/-- Dispatch only through proved interpreter cases, rejecting every currently
unsupported constructor instead of introducing a simulation premise. -/
elab "host_transport_step " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let tag ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    if ctl.isAppOfArity ``Ctl.call 3 then pure 0
    else if ctl.isAppOfArity ``Ctl.ev 2 then
      let e ← whnf ctl.getAppArgs[0]!
      if e.isAppOfArity ``Expr.id 1 then pure 1
      else if e.isAppOfArity ``Expr.lit 1 then pure 2
      else throwError "host_transport_step: unsupported source expression {e.getAppFn.constName!.toString}"
    else throwError "host_transport_step: unsupported source control {ctl.getAppFn.constName!.toString}"
  match tag with
  | 0 => elabCommand (← `(host_transport_closure $f, $s to $t as $name))
  | 1 => elabCommand (← `(host_transport_variable $f, $s to $t as $name))
  | _ => elabCommand (← `(host_transport_literal $f, $s to $t as $name))

end Host.Ts.Owned.Parametric.Driver
