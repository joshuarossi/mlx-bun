import host.load.RuntimeOracleReturnPlan

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RetainedOracleConcatReturnBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open RetainedVectorOracleBatch

noncomputable def entryNotes (notes : RetainedNotes) (caller : List Annotated.Tree) : RetainedNotes :=
  (readyNotes notes caller).nativeHandleResult OracleConcatCases.Source336.out
    OracleConcatCases.Source336.input.ffi.mlx.next

/- The current output slot supplies the native handle to Bun.read.u64. The
ordinary return path then passes that same retained handle to MLXArray's
constructor; no future private-field role is an entry premise. -/
host_retained_theorem concat_to_constructor := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (FR : Ren → P.F.S → P.F.S → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer ((P.RestStream.micro0.micro3.S37).substitute LoopVariables.oracleVariables)) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      P.RestStream.micro0.micro3.s37 s)
    (inventory : RetainedInventory (entryNotes notes caller) ν₀ ν C₀ C R live
      P.RestStream.micro0.micro3.s37 s)
    (budget : s.next+16 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) => by
  host_normalize_retained h, inventory
  host_retained_plan_chain P.F, Plan using h, inventory, inst
host_assert_retained_schema concat_to_constructor, 35

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``concat_to_constructor
  forallTelescope info.type fun args tail => do
    let tail ← whnf tail
    unless tail.isAppOfArity ``Exists 2 do throwError "expected connected constructor entry"
    lambdaTelescope tail.getAppArgs[1]! fun _ body => do
      let rec inventory (p : Lean.Expr) : MetaM Lean.Expr := do
        if p.getAppFn.isConstOf ``RetainedInventory then return p
        if p.isAppOfArity ``And 2 then
          try inventory p.getAppArgs[0]! catch _ => inventory p.getAppArgs[1]!
        else throwError "missing connected constructor inventory"
      let retained ← inventory body
      for (name,index) in [(`constructorNotes,1),(`constructorLive,7)] do
        let value := retained.getAppArgs[index]!
        let used ← args.filterM fun a => pure (value.find? (· == a)).isSome
        Parametric.Driver.addData ((← getCurrNamespace) ++ name) (← mkLambdaFVars used value)

end Host.Load.Run.Full.Ordinary.RetainedOracleConcatReturnBatch
