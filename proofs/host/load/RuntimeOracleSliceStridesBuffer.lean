import host.load.RuntimeOracleSliceStridesE

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000
namespace Host.Load.Run.Full.Ordinary.RetainedOracleConvolutionBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open RetainedOracleConcatReturnBatch

noncomputable def SliceStridesBuffer.rules : List Lean.Name := [``StridesI32.retained_transport]

host_retained_theorem slice_strides_buffer := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (FR : Ren → P.F.S → P.F.S → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer ((P.RestStream.micro0.micro9.S36).substitute LoopVariables.oracleVariables)) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro9.s36 s)
    (inventory : RetainedInventory (stridesENotes notes caller) ν₀ ν C₀ C R live P.RestStream.micro0.micro9.s36 s)
    (budget : s.next+32 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 21) (typedFixed : R.a 21 = 21)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (capture : notes.captures.owners 90 = some RankOrigin.InitialRetained.constructorMetadata) => by
  have codeNote : RankOrigin.InitialRetained.constructorMetadata.roles 0 = some (.literal (.lit (F64.ofNat 4))) := rfl
  have protoNote : RankOrigin.InitialRetained.constructorMetadata.roles 1 = some (.literal (.lit (F64.ofNat 21))) := rfl
  host_normalize_retained h, inventory
  host_retained_plan_chain P.F, SliceStridesBuffer using h, inventory, inst
host_assert_retained_schema slice_strides_buffer, 1

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``slice_strides_buffer
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
      for (name,index) in [(`stridesBufferNotes,1),(`stridesBufferLive,7)] do
        let value := retained.getAppArgs[index]!
        let used ← args.filterM fun a => pure (value.find? (· == a)).isSome
        Parametric.Driver.addData ((← getCurrNamespace) ++ name) (← mkLambdaFVars used value)

end Host.Load.Run.Full.Ordinary.RetainedOracleConvolutionBatch
