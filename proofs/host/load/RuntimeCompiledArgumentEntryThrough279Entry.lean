import host.load.RuntimeCompiledArgumentEntryWrapper
import host.load.RuntimeCompiledArgumentEntryPlanFrom64
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

-- Extract only deterministic entry annotations from the already-checked
-- wrapper contract. Neither definition can contain its reached target/proof.
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``retained_wrapper
  forallTelescopeReducing info.type fun args conclusion => do
    let conclusion ← whnf conclusion
    unless conclusion.isAppOfArity ``Exists 2 do throwError "wrapper descriptor: expected reached state"
    withLocalDeclD `result conclusion.getAppArgs[0]! fun result => do
      let rec inventory (type : Lean.Expr) : MetaM Lean.Expr := do
        let type ← whnf type
        if type.getAppFn.isConstOf ``RetainedInventory then return type
        unless type.isAppOfArity ``And 2 do throwError "wrapper descriptor: missing inventory"
        let saved ← saveState
        try inventory type.getAppArgs[0]!
        catch _ => saved.restore; inventory type.getAppArgs[1]!
      let post ← inventory (mkApp conclusion.getAppArgs[1]! result)
      let notesArgs ← args.filterM fun arg => do
        return [`notes,`role,`cellRole,`receiverRole].contains (← getFVarLocalDecl arg).userName
      let liveArgs ← args.filterM fun arg => do return (← getFVarLocalDecl arg).userName == `live
      for (tag,value,parameters) in [("notes",post.getAppArgs[1]!,notesArgs),("live",post.getAppArgs[7]!,liveArgs)] do
        let value ← instantiateMVars (← mkLambdaFVars parameters value)
        if value.hasFVar || value.hasMVar then throwError "wrapper descriptor depends on a reached target/proof: {tag}"
        Parametric.Driver.addData ((← getCurrNamespace) ++ `Through64 ++ Name.mkSimple tag) value

theorem through64_control (notes : RetainedNotes) (role cellRole receiverRole : Annotated.Value) :
    (Through64.notes notes role cellRole receiverRole).runtime.control = returnNote .undef := by host_kernel_rfl

theorem source_heap_growth64 : Region.s64.next = Region.s0.next+12 := by host_kernel_rfl
theorem source_heap_growth106 : Region.s106.next = Region.s0.next+26 := by host_kernel_rfl
theorem source_heap_growth279 : Region.s279.next = Region.s0.next+39 := by host_kernel_rfl
theorem current_typed_constructor : From64.TypedCount106.address = 95 ∧
    From64.TypedCount106.codeIndex = 9 ∧ From64.TypedCount106.protoIndex = 26 ∧
    From64.TypedCount106.count = 3 := by
  refine ⟨?_,?_,?_,?_⟩ <;> host_kernel_rfl

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
