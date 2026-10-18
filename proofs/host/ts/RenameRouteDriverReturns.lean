import host.ts.RenameRouteDriver
import host.ts.RenameParametricReturnStep

namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- Select a real synchronous return/unwind frame and apply its source-only
transport theorem. Cleanup, asynchronous and unsupported frames are rejected. -/
elab "host_transport_return " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let abrupt ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      let type? := if tag == "F" then none else
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F))))
      addData (pre ++ Name.mkSimple tag) value type?
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    let abrupt := ctl.isAppOfArity ``Ctl.abr 1
    let value ← if abrupt then do
      let a ← field ctl ``Ctl.abr 1 0
      field a ``Abrupt.ret 1 0
    else field ctl ``Ctl.ret 1 0
    let stack ← mkAppM ``St.stack #[s]
    let frame ← whnf (← field stack ``List.cons 3 1)
    let tail ← field stack ``List.cons 3 2
    addData (pre ++ `sourceValue) value
    addData (pre ++ `sourceTail) tail
    let nilEnv := mkApp (mkConst ``List.nil [.zero]) (mkConst ``Host.Ts.Name |> fun nameTy =>
      mkApp2 (mkConst ``Prod [.zero,.zero]) nameTy (mkConst ``Nat))
    let (action,env) ← if frame.isAppOfArity ``Frame.s 1 then do
      let st ← whnf frame.getAppArgs[0]!
      if st.isConstOf ``StmtF.ret && !abrupt then
        pure (mkConst ``ReturnExit.explicitReturn,nilEnv)
      else if st.isAppOfArity ``StmtF.block 2 then
        let ss := st.getAppArgs[0]!
        if abrupt then pure (mkApp (mkConst ``ReturnUnwind.block) ss,st.getAppArgs[1]!)
        else
          unless (← whnf ss).isAppOfArity ``List.nil 1 do
            throwError "host_transport_return: nonempty block is not a return exit"
          pure (mkConst ``ReturnExit.emptyBlock,st.getAppArgs[1]!)
      else if st.isAppOfArity ``StmtF.scope 1 then
        unless (← whnf st.getAppArgs[0]!).isAppOfArity ``List.nil 1 do
          throwError "host_transport_return: nonempty cleanup scope"
        pure (mkConst (if abrupt then ``ReturnUnwind.scope else ``ReturnExit.emptyScope),nilEnv)
      else throwError "host_transport_return: unsupported statement frame {st.getAppFn.constName!.toString}"
    else
      let fn ← field frame ``Frame.k 1 0
      let boundary ← field fn ``FnF.fn 1 0
      unless (← whnf boundary).isConstOf ``Boundary.call do
        throwError "host_transport_return: unsupported function boundary"
      pure (mkConst (if abrupt then ``ReturnUnwind.call else ``ReturnExit.implicitCall),nilEnv)
    addData (pre ++ `sourceAction) action
    addData (pre ++ `sourceEnv) env
    pure abrupt
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let ctl := if abrupt then s!".abr (.ret {n}.sourceValue)" else s!".ret {n}.sourceValue"
  emit (header ++ s!"theorem {n}.source_control : {n}.input.ctl = {ctl} := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_frame : {n}.input.stack = {n}.sourceAction.frame {n}.sourceEnv :: {n}.sourceTail := by host_kernel_rfl")
  let sourcePost := "({" ++ s!"{n}.input with stack := {n}.sourceTail" ++ "}).go" ++ s!" ({n}.sourceAction.control {n}.sourceValue)"
  emit (header ++ s!"theorem {n}.source_post : ({sourcePost}) = {n}.output := by host_kernel_rfl")
  let rule := if abrupt then "step_return_unwind_from_source" else "step_return_exit_from_source"
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (R : Ren) (C₀ C : CSrv)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R live framed before after old old' {n}.output result := by
    obtain ⟨v,fs,_,hr,hpost,_⟩ := {rule} {n}.F NR FR R C₀ C live framed before after
      old old' {n}.input s h {n}.sourceValue {n}.sourceAction {n}.sourceEnv {n}.sourceTail
      {n}.source_control {n}.source_frame
    exact ⟨_,hr,{n}.source_post ▸ hpost⟩")

end Host.Ts.Owned.Parametric.Driver
