import host.load.RuntimeOracleWeightShapeTail
import host.ts.RenameRuntimeDriverUndefinedVariable
import host.ts.renameOrdinary.RankOriginInitializedCacheConcat

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RetainedOracleConcatReturnBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles

host_retained_undefined_variable P.F, P.RestStream.micro0.micro5.s67 using (P.RestStream.micro0.micro5.S67.substitute LoopVariables.oracleVariables) to P.RestStream.micro0.micro5.s68 using (P.RestStream.micro0.micro5.S68.substitute LoopVariables.oracleVariables) as WeightRowUndefined

noncomputable def WeightShapeSpreadReturn.rules := (metadataRules 555 570).map (fun n => if n == ``WeightMetadata.Block567.retained_transport then ``WeightRowUndefined.retained_transport else n)

host_retained_theorem weight_spread_to_tail := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer ((P.RestStream.micro0.micro5.S55).substitute LoopVariables.oracleVariables)) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C RankOrigin.InitializedCacheConcat.roles boundary objects H N tail host) R live framed before after old old' P.RestStream.micro0.micro5.s55 s)
    (inventory : RetainedInventory (shapeSpreadEntryNotes notes caller) ν₀ ν C₀ C R live P.RestStream.micro0.micro5.s55 s)
    (budget : s.next+32 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 21) (typedFixed : R.a 21 = 21)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (owned : H 1365) (region : R.region (4*1365) = 4*R.handle 1365)
    (capture : notes.captures.owners 90 = some RankOrigin.InitialRetained.constructorMetadata) => by
  have native := h.native.2
  have codeNote : RankOrigin.InitialRetained.constructorMetadata.roles 0 = some (.literal (.lit (F64.ofNat 4))) := rfl
  have protoNote : RankOrigin.InitialRetained.constructorMetadata.roles 1 = some (.literal (.lit (F64.ofNat 21))) := rfl
  host_normalize_retained h, inventory
  host_retained_plan_chain P.F, WeightShapeSpreadReturn using h, inventory, inst
host_assert_retained_schema weight_spread_to_tail, 15

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``weight_spread_to_tail
  forallTelescope info.type fun args tail => do
    let tail ← whnf tail
    unless tail.isAppOfArity ``Exists 2 do throwError "expected connected cleanup output"
    lambdaTelescope tail.getAppArgs[1]! fun _ body => do
      let rec inventory (p : Lean.Expr) : MetaM Lean.Expr := do
        if p.getAppFn.isConstOf ``RetainedInventory then return p
        if p.isAppOfArity ``And 2 then
          try inventory p.getAppArgs[0]! catch _ => inventory p.getAppArgs[1]!
        else throwError "missing connected cleanup inventory"
      let retained ← inventory body
      for (name,index) in [(`shapeTailNotes,1),(`shapeTailLive,7)] do
        let value := retained.getAppArgs[index]!
        let used ← args.filterM fun a => pure (value.find? (· == a)).isSome
        Parametric.Driver.addData ((← getCurrNamespace) ++ name) (← mkLambdaFVars used value)

end Host.Load.Run.Full.Ordinary.RetainedOracleConcatReturnBatch
