import host.ts.RenameRouteDriver
import host.ts.RenameParametricMapControl

namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- Check the actual prelude's receiver and guard operations from source
syntax and source state. Unsupported controls are rejected. -/
elab "host_transport_map_control " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let branch ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      let type? := if tag == "F" then none else
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F))))
      addData (pre ++ Name.mkSimple tag) value type?
    let add (tag : String) (value : Lean.Expr) := addData (pre ++ Name.mkSimple tag) value
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    if ctl.isAppOfArity ``Ctl.ex 2 then
      let st ← whnf ctl.getAppArgs[0]!
      unless st.isAppOfArity ``Stmt.if_ 3 do throwError "host_transport_map_control: expected if statement"
      add "sourceAction" (mkAppN (mkConst ``StatementAction.ifTest) st.getAppArgs)
      add "sourceEnv" ctl.getAppArgs[1]!
      pure "statement"
    else if ctl.isAppOfArity ``Ctl.ev 2 then
      unless (← whnf ctl.getAppArgs[0]!).isConstOf ``Expr.this do throwError "host_transport_map_control: expected this expression"
      let env := ctl.getAppArgs[1]!
      let a ← field (← mkAppM ``lookupEnv #[mkConst ``nThis,env]) ``Option.some 2 1
      let value ← field (← field (← mkAppM ``St.cell? #[s,a]) ``Option.some 2 1) ``Option.some 2 1
      for (tag,v) in [("sourceEnv",env),("sourceAddress",a),("sourceValue",value)] do add tag v
      pure "this"
    else
      let value ← field ctl ``Ctl.ret 1 0
      let stack ← mkAppM ``St.stack #[s]
      add "sourceTail" (← field stack ``List.cons 3 2)
      let frame ← whnf (← field stack ``List.cons 3 1)
      if frame.isAppOfArity ``Frame.s 1 then
        let st ← whnf frame.getAppArgs[0]!
        unless st.isAppOfArity ``StmtF.if_ 3 do throwError "host_transport_map_control: expected if continuation"
        add "sourceGuard" (← field value ``Val.bool 1 0)
        for (tag,i) in [("sourceYes",0),("sourceNo",1),("sourceEnv",2)] do add tag st.getAppArgs[i]!
        pure "if"
      else
        let e ← whnf (← field frame ``Frame.e 1 0)
        unless e.isAppOfArity ``ExprF.binR 2 do throwError "host_transport_map_control: expected binary continuation"
        pure "undefined"
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let fact (tag proposition : String) := emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  let common := s!"{n}.F NR FR R C₀ C live framed before after old old' {n}.input s h"
  let rule ← if branch == "statement" then do
      fact "source_control" s!"{n}.input.ctl = .ex {n}.sourceAction.statement {n}.sourceEnv"
      pure s!"step_statement_from_source {common} {n}.sourceAction {n}.sourceEnv {n}.source_control"
    else if branch == "this" then do
      fact "source_control" s!"{n}.input.ctl = .ev .this {n}.sourceEnv"
      fact "source_lookup" s!"lookupEnv nThis {n}.sourceEnv = some {n}.sourceAddress"
      fact "source_cell" s!"{n}.input.heap.get {n}.sourceAddress = some (.cell (some {n}.sourceValue))"
      pure s!"step_this_from_source {common} {n}.sourceEnv {n}.sourceAddress {n}.sourceValue
        {n}.source_control {n}.source_lookup {n}.source_cell"
    else if branch == "if" then do
      fact "source_control" s!"{n}.input.ctl = .ret (.bool {n}.sourceGuard)"
      fact "source_frame" s!"{n}.input.stack = .s (.if_ {n}.sourceYes {n}.sourceNo {n}.sourceEnv)::{n}.sourceTail"
      pure s!"step_if_from_source {common} {n}.sourceGuard {n}.sourceYes {n}.sourceNo {n}.sourceEnv
        {n}.sourceTail {n}.source_control {n}.source_frame"
    else do
      fact "source_control" s!"{n}.input.ctl = .ret .undef"
      fact "source_frame" s!"{n}.input.stack = .e (.binR .sne .undef)::{n}.sourceTail"
      pure s!"step_undefined_sne_from_source {common} {n}.sourceTail {n}.source_control {n}.source_frame"
  emit (header ++ s!"theorem {n}.source_run (C₀ : CSrv) : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by host_kernel_rfl")
  let args := if branch == "this" then "value,hr₀,hr,hpost,_"
    else if branch == "statement" then "hr₀,hr,hpost" else "result,hr₀,hr,hpost"
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop) (FR : Ren → {n}.F.S → {n}.F.S → Prop)
      (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R live framed before after old old' {n}.output result := by
    obtain ⟨{args}⟩ := {rule}
    rw [{n}.source_run] at hr₀
    have hs := congrArg Prod.fst (Option.some.inj hr₀)
    dsimp only at hs
    rw [← hs] at hpost
    exact ⟨_,hr,hpost⟩")

end Host.Ts.Owned.Parametric.Driver
