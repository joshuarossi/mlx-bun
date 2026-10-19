import host.ts.RenamePostConcatCleanup
import host.ts.RenameRuntimeSourceCut
import host.ts.RenameRouteDriver
import host.ts.RenameKernelRfl
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

/-- Source-selected logical not uses the existing retained rules. The selector
does not change the interpreter or introduce a numeric truthiness premise. -/
elab "host_compiled_argument_not_step " f:term ", " s:term " using " initial:term
    " to " t:term " using " next:term " as " name:ident : command => do
  let saved ← get
  try
    let pre := (← getCurrNamespace) ++ name.getId
    let entry ← liftTermElabM do
      let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
      let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
      let s ← Term.elabTermEnsuringType s stateTy
      let t ← Term.elabTermEnsuringType t stateTy
      let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
      let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
      let ctl ← whnf (← mkAppM ``St.ctl #[s])
      let entry ← if ctl.isAppOfArity ``Ctl.ev 2 then do
        let expression ← whnf ctl.getAppArgs[0]!
        unless expression.isAppOfArity ``Expr.unary 2 do throwError "expected logical-not descent"
        unless (← whnf expression.getAppArgs[0]!).isConstOf ``UnOp.not do
          throwError "expected logical-not descent"
        Parametric.Driver.addData (pre ++ `operand) expression.getAppArgs[1]!
        Parametric.Driver.addData (pre ++ `environment) ctl.getAppArgs[1]!
        pure true
      else do
        unless ctl.isAppOfArity ``Ctl.ret 1 do throwError "expected logical-not object return"
        let value ← whnf ctl.getAppArgs[0]!
        unless value.isAppOfArity ``Val.obj 1 do throwError "expected object truthiness"
        let stack ← whnf (← mkAppM ``St.stack #[s])
        unless stack.isAppOfArity ``List.cons 3 do throwError "expected logical-not frame"
        let frame ← whnf stack.getAppArgs[1]!
        unless frame.isAppOfArity ``Frame.e 1 do throwError "expected expression frame"
        let inner ← whnf frame.getAppArgs[0]!
        unless inner.isAppOfArity ``ExprF.unary 1 do throwError "expected logical-not frame"
        unless (← whnf inner.getAppArgs[0]!).isConstOf ``UnOp.not do
          throwError "expected logical-not frame"
        Parametric.Driver.addData (pre ++ `address) value.getAppArgs[0]!
        Parametric.Driver.addData (pre ++ `sourceTail) stack.getAppArgs[2]!
        pure false
      for (tag,value) in [("F",f),("input",s),("output",t)] do
        let type? := if tag == "F" then none else
          some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F))))
        Parametric.Driver.addData (pre ++ Name.mkSimple tag) value type?
      Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
      Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
      pure entry
    let n := "_root_." ++ pre.toString
    let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
    let emit (text : String) : CommandElabM Unit := do
      Parametric.Driver.emit (header ++ text)
      if (← get).messages.hasErrors then
        let mut detail := ""
        for message in (← get).messages.toList.drop saved.messages.toList.length do
          detail := detail ++ (← message.data.toString) ++ "\n"
        throwError "logical-not source proof failed: {detail}"
    let control := if entry then s!".ev (.unary .not {n}.operand) {n}.environment" else s!".ret (.obj {n}.address)"
    let post := if entry then s!"({n}.input.push (.e (.unary .not))).go (.ev {n}.operand {n}.environment)"
      else "({" ++ s!"{n}.input with stack := {n}.sourceTail" ++ "}).ret (.bool false)"
    let resultNotes := if entry then s!"notes.withRuntime (notes.runtime.notDescent {n}.operand {n}.environment)"
      else "notes.withRuntime (notes.runtime.binaryResult (.bool false) notes.runtime.stack.tail)"
    emit s!"theorem {n}.source_control : {n}.input.ctl = {control} := by host_kernel_rfl"
    if !entry then
      emit s!"theorem {n}.source_frame : {n}.input.stack = .e (.unary .not)::{n}.sourceTail := by host_kernel_rfl"
    emit s!"theorem {n}.source_post : ({post}) = {n}.output := by host_kernel_rfl"
    emit s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer) := by host_kernel_rfl"
    let application := if entry then
      s!"obtain ⟨sourceRun,targetRun,post,retained⟩ := inventory.not_entry_step h {n}.operand {n}.environment {n}.source_control"
      else s!"obtain ⟨_,sourceRun,targetRun,post,retained⟩ := inventory.not_object_step h {n}.address {n}.sourceTail {n}.source_control {n}.source_frame"
    emit s!"theorem {n}.retained_transport
        (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
        (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
        (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
        (inst : Inst ν₀ {n}.initialServer C₀)
        (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
        (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s) :
        ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
          interpC (step {n}.F s).run C = some (result,C) ∧
          Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
          RetainedInventory ({resultNotes}) ν₀ ν C₀ C R live {n}.output result ∧
          Inst ν₀ {n}.nextServer C₀ := by
        {application}
        rw [{n}.source_post] at sourceRun post retained
        exact ⟨_,sourceRun,targetRun,post,retained,
          pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step sourceRun⟩"
  catch exception =>
    set saved
    throw exception

end Host.Ts.Owned.Annotated.Driver
