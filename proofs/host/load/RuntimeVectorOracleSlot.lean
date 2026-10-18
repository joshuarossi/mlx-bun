import host.load.RuntimeVectorOracleSecond
import host.ts.RenameRetainedNormalize

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RetainedVectorOracleBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_theorem vector_to_array := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (FR : Ren → P.F.S → P.F.S → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer ((P.RestStream.micro0.micro2.S50).substitute LoopVariables.oracleVariables)) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro2.s50 s)
    (inventory : RetainedInventory (entryNotes notes caller) ν₀ ν C₀ C R live P.RestStream.micro0.micro2.s50 s)
    (budget : s.next+32 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (arrayBufferLive : live aArrayBufferProto) (arrayBufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (signatureFrame : ¬ framed Plan.Block295.types)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) => by
  have earlier := vector_to_null notes caller ν₀ ν C₀ C R FR live framed before after old old' s inst h inventory
    budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed arrayBufferLive arrayBufferFixed signatureFrame globalLive globalFixed
  have post := Classical.choose_spec earlier
  have previous := post.1
  have state := post.2.1
  have retained := post.2.2.1
  have sourceInst := post.2.2.2
  host_normalize_retained state, retained
  host_retained_plan_chain_after P.F, Array using state, retained, sourceInst continuing_run previous initial_relation h
host_assert_retained_schema vector_to_array, 48

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``vector_to_array
  forallTelescope info.type fun args tail => do
    let tail ← whnf tail
    unless tail.isAppOfArity ``Exists 2 do throwError "expected connected vector array"
    lambdaTelescope tail.getAppArgs[1]! fun _ body => do
      let rec inventory (p : Lean.Expr) : MetaM Lean.Expr := do
        if p.getAppFn.isConstOf ``RetainedInventory then return p
        if p.isAppOfArity ``And 2 then
          try inventory p.getAppArgs[0]! catch _ => inventory p.getAppArgs[1]!
        else throwError "missing connected vector array inventory"
      let retained ← inventory body
      for (name,index) in [(`arrayNotes,1),(`arrayLive,7)] do
        let value := retained.getAppArgs[index]!
        let used ← args.filterM fun a => pure (value.find? (· == a)).isSome
        Parametric.Driver.addData ((← getCurrNamespace) ++ name) (← mkLambdaFVars used value)

end Host.Load.Run.Full.Ordinary.RetainedVectorOracleBatch
