import host.ts.RenameCompiledArgumentEntryChain
import host.ts.RenameRouteDriver
import host.ts.RenameKernelRfl
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

private def printed (stx : Syntax) : CommandElabM String :=
  match stx.reprint with
  | some text => pure text
  | none => throwError "host_compiled_argument_chain_step: source syntax cannot be printed"

/-- Select the actual `Ctl.ret` / `Frame.e` `ExprF.chain` continuation.
A wrong frame or a wrong declared endpoint restores the command state and
rejects the cut before any partial declaration remains. -/
elab "host_compiled_argument_chain_step " f:term ", " s:term " using " initial:term
    " to " t:term " using " next:term " as " name:ident : command => do
  let saved ← get
  try
    let pre := (← getCurrNamespace) ++ name.getId
    let _ ← liftTermElabM do
      let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
      let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
      let s ← Term.elabTermEnsuringType s stateTy
      let t ← Term.elabTermEnsuringType t stateTy
      let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
      let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
      let ctl ← whnf (← mkAppM ``St.ctl #[s])
      unless ctl.isAppOfArity ``Ctl.ret 1 do
        throwError "host_compiled_argument_chain_step: expected Ctl.ret into ExprF.chain"
      let stack ← whnf (← mkAppM ``St.stack #[s])
      unless stack.isAppOfArity ``List.cons 3 do
        throwError "host_compiled_argument_chain_step: expected Ctl.ret into ExprF.chain"
      let frame ← whnf stack.getAppArgs[1]!
      unless frame.isAppOfArity ``Frame.e 1 do
        throwError "host_compiled_argument_chain_step: expected Ctl.ret into ExprF.chain"
      let inner ← whnf frame.getAppArgs[0]!
      unless inner.isConstOf ``ExprF.chain do
        throwError "host_compiled_argument_chain_step: expected Ctl.ret into ExprF.chain"
      let value := ctl.getAppArgs[0]!
      let tail := stack.getAppArgs[2]!
      for (tag,value) in [("F",f),("input",s),("output",t)] do
        let type? := if tag == "F" then none else
          some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F))))
        Parametric.Driver.addData (pre ++ Name.mkSimple tag) value type?
      Parametric.Driver.addData (pre ++ `sourceValue) value
      Parametric.Driver.addData (pre ++ `sourceTail) tail
      Parametric.Driver.addData (pre ++ `initialServer) initial
      Parametric.Driver.addData (pre ++ `nextServer) next
      pure ()
    let n := "_root_." ++ pre.toString
    let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
    let post := "({" ++ s!"{n}.input with stack := {n}.sourceTail" ++ s!"}).ret {n}.sourceValue"
    let reject (label : String) : CommandElabM Unit := do
      unless (← get).messages.hasErrors do return
      let mut detail := ""
      for message in (← get).messages.toList do
        detail := detail ++ (← message.data.toString) ++ "\n"
      throwError "host_compiled_argument_chain_step: {label}\n{detail}"
    Parametric.Driver.emit (header ++ s!"theorem {n}.source_control : {n}.input.ctl = .ret {n}.sourceValue := by host_kernel_rfl")
    reject "source return was not checked"
    Parametric.Driver.emit (header ++ s!"theorem {n}.source_frame : {n}.input.stack = .e .chain :: {n}.sourceTail := by host_kernel_rfl")
    reject "source frame was not checked"
    Parametric.Driver.emit (header ++ s!"theorem {n}.source_post : ({post}) = {n}.output := by host_kernel_rfl")
    reject "endpoint is not the chain return"
    Parametric.Driver.emit (header ++ s!"theorem {n}.source_step : interpS (step {n}.F {n}.input).run {n}.initialServer = some ({post},{n}.nextServer) := by host_kernel_rfl")
    reject "source step was not checked"
    Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
        (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
        (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
        (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
        (inst : Inst ν₀ {n}.initialServer C₀)
        (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
        (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
        (role : Value) (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
        (controlNote : notes.runtime.control = returnNote role)
        (stackNotes : notes.runtime.stack = headNote :: tailNotes) :
        ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
        RetainedInventory (notes.withRuntime (notes.runtime.chainReturn tailNotes)) ν₀ ν C₀ C R live {n}.output result ∧
        Inst ν₀ {n}.nextServer C₀ := by
        obtain ⟨result,sourceRun,targetRun,related,retained,nextInst⟩ := RetainedInventory.chain_return {n}.F notes ν₀ ν C₀ C R FR
          live framed before after old old' {n}.input s {n}.initialServer {n}.nextServer inst h inventory
          {n}.sourceValue role {n}.sourceTail headNote tailNotes {n}.source_control {n}.source_frame
          controlNote stackNotes {n}.source_step
        exact ⟨result,{n}.source_post ▸ sourceRun,targetRun,{n}.source_post ▸ related,{n}.source_post ▸ retained,nextInst⟩")
    reject "retained transport was not checked"
  catch exception =>
    let text ← exception.toMessageData.toString
    set saved
    if (text.splitOn "host_compiled_argument_chain_step:").length > 1 then
      throwError text
    else if (text.splitOn "kernel").length > 1 || (text.splitOn "type mismatch").length > 1 then
      throwError "host_compiled_argument_chain_step: endpoint is not the chain return\n{text}"
    else
      throwError text

end Host.Ts.Owned.Annotated.Driver
