import host.load.RuntimeCompiledArgumentEntryThrough279SecondStore
import host.load.RuntimeCompiledArgumentEntryThrough279ClosedCell
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``retained_from170_to214
  forallTelescopeReducing info.type fun args conclusion => do
    let conclusion ← whnf conclusion
    unless conclusion.isAppOfArity ``Exists 2 do throwError "count descriptor: expected reached state"
    withLocalDeclD `result conclusion.getAppArgs[0]! fun result => do
      let rec inventory (type : Lean.Expr) : MetaM Lean.Expr := do
        let type ← whnf type
        if type.getAppFn.isConstOf ``RetainedInventory then return type
        unless type.isAppOfArity ``And 2 do throwError "count descriptor: missing inventory"
        let saved ← saveState
        try inventory type.getAppArgs[0]!
        catch _ => saved.restore; inventory type.getAppArgs[1]!
      let post ← inventory (mkApp conclusion.getAppArgs[1]! result)
      let notesArgs ← args.filterM fun arg => do
        return [`notes,`role,`cellRole,`receiverRole].contains (← getFVarLocalDecl arg).userName
      let liveArgs ← args.filterM fun arg => do return (← getFVarLocalDecl arg).userName == `live
      for (tag,value,parameters) in [("notes",post.getAppArgs[1]!,notesArgs),("live",post.getAppArgs[7]!,liveArgs)] do
        let value ← instantiateMVars (← mkLambdaFVars parameters value)
        if value.hasFVar || value.hasMVar then throwError "count descriptor depends on a reached target/proof: {tag}"
        Parametric.Driver.addData ((← getCurrNamespace) ++ `Through214 ++ Name.mkSimple tag) value

noncomputable def Through214.indexRole (notes : RetainedNotes) (role cellRole receiverRole : Annotated.Value) : Annotated.Value :=
  ((Through214.notes notes role cellRole receiverRole).runtime.cells.cells From64.VariableIndex214.indexCell).getD .undef

theorem through214_index_selected (notes : RetainedNotes) (role cellRole receiverRole : Annotated.Value) :
    (Through214.notes notes role cellRole receiverRole).runtime.cells.cells From64.VariableIndex214.indexCell =
      some (Through214.indexRole notes role cellRole receiverRole) := by host_kernel_rfl

theorem through214_index_closed (notes : RetainedNotes) (role cellRole receiverRole : Annotated.Value) :
    ClosedLiteralNote (Through214.indexRole notes role cellRole receiverRole) := by
  change _ = true
  host_kernel_rfl

theorem through214_index_source : cellValueAt Region.s214 From64.VariableIndex214.indexCell =
    .num (.lit From64.VariableIndex214.literal) := by host_kernel_rfl

noncomputable def Through214.literalNotes (notes : RetainedNotes) (role cellRole receiverRole : Annotated.Value) :=
  literalCellNotes (Through214.notes notes role cellRole receiverRole) From64.VariableIndex214.indexCell From64.VariableIndex214.literal

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
