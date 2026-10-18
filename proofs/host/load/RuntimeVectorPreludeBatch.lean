import host.load.RuntimeVectorPreludePlan
import host.ts.renameOrdinary.RankOriginInitializedVector
import host.ts.renameOrdinary.VectorToConcatPreludeSupport
import host.mlx.OrdinaryConcatStates

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RetainedVectorPreludeBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

noncomputable def entryNotes (notes : RetainedNotes) (caller : List Annotated.Tree) : RetainedNotes :=
  let current := RetainedVectorEntryBatch.endNotes notes caller
  current.withRuntime ⟨returnNote (.handle RetainedVectorEntryBatch.Vector249.input.ffi.mlx.next),
    current.runtime.stack,current.runtime.cells⟩

host_retained_theorem vector_to_mid := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (FR : Ren → P.F.S → P.F.S → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer P.RestStream.micro0.micro2.S50) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro2.s50 s)
    (inventory : RetainedInventory (entryNotes notes caller) ν₀ ν C₀ C R live P.RestStream.micro0.micro2.s50 s)
    (budget : s.next+32 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (arrayBufferLive : live aArrayBufferProto) (arrayBufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) => by
  host_retained_plan_chain P.F, First using h, inventory, inst
host_assert_retained_schema vector_to_mid, 32

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``vector_to_mid
  forallTelescope info.type fun args tail => do
    let tail ← whnf tail
    unless tail.isAppOfArity ``Exists 2 do throwError "expected connected vector prelude"
    lambdaTelescope tail.getAppArgs[1]! fun _ body => do
      let rec inventory (p : Lean.Expr) : MetaM Lean.Expr := do
        if p.getAppFn.isConstOf ``RetainedInventory then return p
        if p.isAppOfArity ``And 2 then
          try inventory p.getAppArgs[0]! catch _ => inventory p.getAppArgs[1]!
        else throwError "missing connected vector inventory"
      let retained ← inventory body
      for (name,index) in [(`midNotes,1),(`midLive,7)] do
        let value := retained.getAppArgs[index]!
        let used ← args.filterM fun a => pure (value.find? (· == a)).isSome
        Parametric.Driver.addData ((← getCurrNamespace) ++ name) (← mkLambdaFVars used value)

end Host.Load.Run.Full.Ordinary.RetainedVectorPreludeBatch
