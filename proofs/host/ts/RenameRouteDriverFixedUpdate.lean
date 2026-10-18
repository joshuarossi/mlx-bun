import host.ts.RenameRouteDriver
import host.ts.RenameFixedUpdate

namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- Select literal-index postfix operations from actual source syntax and
continuations. The incoming index occurrence is established by earlier code. -/
elab "host_transport_fixed_update " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let branch ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else some stateTy)
    let add (tag : String) (value : Lean.Expr) := addData (pre ++ Name.mkSimple tag) value
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    let mut hasVariable := false
    let mut branch := "read"
    if ctl.isAppOfArity ``Ctl.ev 2 then
      let e ← whnf ctl.getAppArgs[0]!
      unless e.isAppOfArity ``Expr.update 3 && e.getAppArgs[0]!.isConstOf ``Bool.true && e.getAppArgs[1]!.isConstOf ``Bool.false do
        throwError "host_transport_fixed_update: expected postfix increment"
      add "sourceName" (← field e.getAppArgs[2]! ``Expr.id 1 0)
      add "sourceEnv" ctl.getAppArgs[1]!
      hasVariable := true
    else
      add "sourceValue" (← field ctl ``Ctl.ret 1 0)
      let stack ← mkAppM ``St.stack #[s]
      add "sourceTail" (← field stack ``List.cons 3 2)
      let frame ← whnf (← field stack ``List.cons 3 1)
      if frame.isAppOfArity ``Frame.a 1 then
        let af ← whnf frame.getAppArgs[0]!
        unless af.isAppOfArity ``AsgF.updOld 3 && af.getAppArgs[0]!.isConstOf ``Bool.true && af.getAppArgs[1]!.isConstOf ``Bool.false do
          throwError "host_transport_fixed_update: expected postfix assignment"
        let target ← whnf af.getAppArgs[2]!
        add "sourceName" (← field target ``Target.var 2 0)
        add "sourceEnv" (← field target ``Target.var 2 1)
        add "sourceNumber" (← field (← field ctl ``Ctl.ret 1 0) ``Val.num 1 0 >>= fun n => field n ``NumV.lit 1 0)
        add "sourceNextNumber" (← field (← field (← mkAppM ``St.ctl #[t]) ``Ctl.ret 1 0) ``Val.num 1 0 >>= fun n => field n ``NumV.lit 1 0)
        hasVariable := true
        branch := "increment"
      else
        let ef ← field frame ``Frame.e 1 0
        add "sourceSaved" (← field ef ``ExprF.const 1 0)
        branch := "constant"
    if hasVariable then
      let env := mkConst (pre ++ `sourceEnv)
      let a ← field (← mkAppM ``lookupEnv #[mkConst (pre ++ `sourceName),env]) ``Option.some 2 1
      add "sourceAddress" a
      if branch == "read" then
        add "sourceValue" (← field (← mkAppM ``St.cell? #[s,a]) ``Option.some 2 1 >>= fun v => field v ``Option.some 2 1)
    pure branch
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let fact (tag proposition : String) := emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  let common := s!"{n}.F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' {n}.input s h"
  let (extra,post,body) ← if branch == "read" then do
      fact "source_control" s!"{n}.input.ctl = .ev (.update true false (.id {n}.sourceName)) {n}.sourceEnv"
      fact "source_lookup" s!"lookupEnv {n}.sourceName {n}.sourceEnv = some {n}.sourceAddress"
      fact "source_cell" s!"{n}.input.heap.get {n}.sourceAddress = some (.cell (some {n}.sourceValue))"
      fact "source_post" s!"({n}.input.push (.a (.updOld true false (.var {n}.sourceName {n}.sourceEnv)))).ret {n}.sourceValue = {n}.output"
      pure (s!"(cell : s.heap.get (R.a {n}.sourceAddress) = some (.cell (some {n}.sourceValue)))",
        s!"result.ctl = .ret {n}.sourceValue ∧ result.heap = s.heap",
        s!"obtain ⟨_,hr,hpost⟩ := step_update_var_from_source_fixed {common} {n}.sourceName {n}.sourceEnv {n}.sourceAddress {n}.sourceValue {n}.sourceValue {n}.source_control {n}.source_lookup {n}.source_cell cell\n    exact ⟨_,hr,{n}.source_post ▸ hpost,rfl,rfl⟩")
    else if branch == "constant" then do
      fact "source_control" s!"{n}.input.ctl = .ret {n}.sourceValue"
      fact "source_frame" s!"{n}.input.stack = .e (.const {n}.sourceSaved)::{n}.sourceTail"
      fact "source_post" ("({" ++ s!"{n}.input with stack := {n}.sourceTail" ++ "}).ret " ++ s!"{n}.sourceSaved = {n}.output")
      pure ("","result.heap = s.heap",s!"obtain ⟨result,_,hr,hpost,heap⟩ := step_constant_from_source {common} {n}.sourceValue {n}.sourceSaved {n}.sourceTail {n}.source_control {n}.source_frame\n    exact ⟨result,hr,{n}.source_post ▸ hpost,heap⟩")
    else do
      fact "source_control" s!"{n}.input.ctl = .ret (.num (.lit {n}.sourceNumber))"
      fact "source_frame" s!"{n}.input.stack = .a (.updOld true false (.var {n}.sourceName {n}.sourceEnv))::{n}.sourceTail"
      fact "source_lookup" s!"lookupEnv {n}.sourceName {n}.sourceEnv = some {n}.sourceAddress"
      fact "source_cell" s!"{n}.input.heap.get {n}.sourceAddress = some (.cell (some (.num (.lit {n}.sourceNumber))))"
      fact "source_sum" s!"F64.bin .add {n}.sourceNumber (.fin false 1 0) = {n}.sourceNextNumber"
      fact "source_post" s!"fixedPostincrement {n}.input {n}.sourceAddress {n}.sourceNumber {n}.sourceNextNumber {n}.sourceTail = {n}.output"
      emit (header ++ s!"theorem {n}.source_bound : {n}.input.next ≤ 2^64 := by decide +kernel")
      pure (s!"(control : s.ctl = .ret (.num (.lit {n}.sourceNumber))) (cell : s.heap.get (R.a {n}.sourceAddress) = some (.cell (some (.num (.lit {n}.sourceNumber))))) (notFramed : ¬ framed {n}.sourceAddress) (bound : s.next ≤ 2^64)",
        s!"result.ctl = .ret (.num (.lit {n}.sourceNextNumber)) ∧ result.heap = (s.setCell (R.a {n}.sourceAddress) (.num (.lit {n}.sourceNextNumber))).heap",
        s!"obtain ⟨fs,_,hr,hpost⟩ := step_postinc_fixed_from_source {n}.F FR R ν₀ ν C₀ C live framed before after old old' {n}.input s h {n}.sourceName {n}.sourceEnv {n}.sourceAddress {n}.sourceNumber {n}.sourceNextNumber {n}.sourceTail {n}.source_control control {n}.source_frame {n}.source_lookup {n}.source_cell cell notFramed {n}.source_bound bound {n}.source_sum\n    exact ⟨_,hr,{n}.source_post ▸ hpost,rfl,rfl⟩")
  emit (header ++ s!"theorem {n}.transport (FR : Ren → {n}.F.S → {n}.F.S → Prop) (R : Ren)
      (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s) {extra} :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧ {post} := by\n    {body}")

end Host.Ts.Owned.Parametric.Driver
