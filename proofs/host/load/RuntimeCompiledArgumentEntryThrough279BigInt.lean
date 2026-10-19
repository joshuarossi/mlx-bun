import host.load.RuntimeCompiledArgumentEntryThrough279Prelude
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``retained_from272_to277
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
        Parametric.Driver.addData ((← getCurrNamespace) ++ `Through277 ++ Name.mkSimple tag) value

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``Through277.notes
  forallTelescopeReducing info.type fun args _ => do
    let control ← whnf (← mkAppM ``RuntimeNotes.control #[← mkAppM ``RetainedNotes.runtime #[mkAppN (mkConst ``Through277.notes) args]])
    let children ← whnf control.getAppArgs[1]!
    let fn ← whnf children.getAppArgs[1]!
    let rest ← whnf children.getAppArgs[2]!
    let home ← whnf rest.getAppArgs[1]!
    let tail ← whnf rest.getAppArgs[2]!
    let values ← whnf tail.getAppArgs[1]!
    let entries ← whnf values.getAppArgs[1]!
    let entry ← whnf entries.getAppArgs[1]!
    let role ← whnf entry.getAppArgs[0]!
    unless role.isAppOfArity ``Value.literal 1 do throwError "final BigInt call argument is not a literal note"
    for (tag,value) in [("fnRole",fn.getAppArgs[0]!),("thisRole",home.getAppArgs[0]!),("meaning",role.getAppArgs[0]!)] do
      let value ← instantiateMVars (← mkLambdaFVars args value)
      if value.hasFVar || value.hasMVar then throwError "BigInt descriptor contains local proof"
      Parametric.Driver.addData ((← getCurrNamespace) ++ `Through277 ++ Name.mkSimple tag) value

theorem through277_control (notes : RetainedNotes) (role cellRole receiverRole : Annotated.Value) :
    (Through277.notes notes role cellRole receiverRole).runtime.control =
      callNote (Through277.fnRole notes role cellRole receiverRole) (Through277.thisRole notes role cellRole receiverRole)
        [.literal (Through277.meaning notes role cellRole receiverRole)] := by host_kernel_rfl

theorem through277_closed (notes : RetainedNotes) (role cellRole receiverRole : Annotated.Value) :
    ∀ valuation, SymE.eval valuation (Through277.meaning notes role cellRole receiverRole) = From64.Span244.Block277.sourceValue := by
  intro valuation
  host_kernel_rfl

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
