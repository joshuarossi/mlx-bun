import host.load.RuntimeNamespacedMapNotes
import host.mlx.NativeInventoryFrontends
import host.mlx.NativeVectorInventoryFrontend
import host.load.RuntimePrefix
import host.ts.RenameRetainedChain
import host.ts.RenameRuntimeBatch
import host.load.RuntimeBlockPlan

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.NamespacedVectorEntryBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

noncomputable def entryNotes (notes : RetainedNotes) (caller : List Annotated.Tree) : RetainedNotes :=
  (NamespacedMap.arrayNotes notes caller).typedBytes P.RestStream.micro0.micro2.s23.next
    (handleArrayBytes [25732,29363])

host_source_plan_subst P.F, P.RestStream.micro0 from 224 plan_steps 25 substitute LoopVariables.oracleVariables as Plan224

host_retained_theorem typed_to_vector_entry := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (FR : Ren → P.F.S → P.F.S → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan224.Block224.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro2.s24 s)
    (inventory : RetainedInventory (entryNotes notes caller) ν₀ ν C₀ C R live P.RestStream.micro0.micro2.s24 s)
    (budget : s.next+16 ≤ 2^64)
    (namespaceEntry : notes.runtime.cells.cells Plan224.Block230.address = some (.obj 4817))
    (pointerEntry : notes.runtime.cells.cells Plan224.Block234.address = some (.obj 2638))
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) => by
  have countClosed (valuation : Nat → F64) : (SymE.lit (F64.ofNat 2)).eval valuation = Plan224.Block247.sourceValue := rfl
  host_retained_plan_chain P.F, Plan224 using h, inventory, inst
host_assert_retained_schema typed_to_vector_entry, 25

host_retained_vectorData P.F, P.RestStream.micro0.micro2.s49 using (P.RestStream.micro0.micro2.S49.substitute LoopVariables.oracleVariables)
  to P.RestStream.micro0.micro2.s50 using (P.RestStream.micro0.micro2.S50.substitute LoopVariables.oracleVariables) as Vector249

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``typed_to_vector_entry
  forallTelescope info.type fun args tail => do
    let tail ← whnf tail
    unless tail.isAppOfArity ``Exists 2 do throwError "expected retained vector entry"
    lambdaTelescope tail.getAppArgs[1]! fun _ body => do
      let rec inventory (p : Lean.Expr) : MetaM Lean.Expr := do
        if p.getAppFn.isConstOf ``RetainedInventory then return p
        if p.isAppOfArity ``And 2 then
          try inventory p.getAppArgs[0]! catch _ => inventory p.getAppArgs[1]!
        else throwError "missing retained vector inventory"
      let retained ← inventory body
      for (name,index) in [(`endNotes,1),(`endLive,7)] do
        let value := retained.getAppArgs[index]!
        let used ← args.filterM fun a => pure (value.find? (· == a)).isSome
        Parametric.Driver.addData ((← getCurrNamespace) ++ name) (← mkLambdaFVars used value)

theorem vector_control (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (endNotes notes caller).runtime.control = callNote (.obj 4709) (.obj 4817)
      [.ptr (.js 3126688) 0,.exactInteger (.lit (F64.ofNat 2))] := by rfl
theorem vector_buffer (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (endNotes notes caller).buffers.owners 3126688 = some (handleArrayBytes [25732,29363]) := by rfl

noncomputable def finalNotes (notes : RetainedNotes) (caller : List Annotated.Tree) : RetainedNotes :=
  let current := endNotes notes caller
  current.withRuntime ⟨returnNote (.handle Vector249.input.ffi.mlx.next),
    current.runtime.stack,current.runtime.cells⟩

theorem final_publics (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (finalNotes notes caller).publicFields = notes.publicFields := rfl

end Host.Load.Run.Full.Ordinary.NamespacedVectorEntryBatch
