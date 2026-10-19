import host.load.RuntimeOracleSliceOutputPlan
import host.load.RuntimeOracleSliceOutputBPre

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000
namespace Host.Load.Run.Full.Ordinary.RetainedOracleConvolutionBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open RetainedOracleConcatReturnBatch
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles

noncomputable def SliceOutputBRest.rules := (SliceOutput.rules.zip SliceOutput.starts).filterMap (fun entry => if 983 ≤ entry.2 && entry.2 < 1005 then some entry.1 else none)

host_retained_theorem slice_output_b := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer ((P.RestStream.micro0.micro9.S80).substitute LoopVariables.oracleVariables)) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C RankOrigin.InitializedCacheConcat.roles boundary objects H N tail host) R live framed before after old old' P.RestStream.micro0.micro9.s80 s)
    (inventory : RetainedInventory (outputANotes notes caller) ν₀ ν C₀ C R live P.RestStream.micro0.micro9.s80 s)
    (budget : s.next+32 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 21) (typedFixed : R.a 21 = 21)
    (bigTypedLive : live 26) (bigTypedFixed : R.a 26 = 26)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (capture : notes.captures.owners 95 = some RankOrigin.InitializedHandleBuffer.constructorMetadata)
    (signatureFrame : ¬framed SliceOutput.Block980.types) => by
  have earlier := slice_output_b_pre notes caller ν₀ ν C₀ C R boundary objects H N tail host live framed
    before after old old' s inst h inventory budget functionLive functionFixed objectLive objectFixed
    arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed bigTypedLive bigTypedFixed
    globalLive globalFixed capture signatureFrame
  have post := Classical.choose_spec earlier
  have previous := post.1
  have state := post.2.1
  have retained := post.2.2.1
  have sourceInst := post.2.2.2
  have room := chain_next_budget_le h state
    (P.RestStream.micro0.micro9.s83.next-P.RestStream.micro0.micro9.s80.next) 2 32 (2^64)
    (by decide +kernel) (by decide +kernel) budget
  have targetBound : (Classical.choose earlier).next+1 < 2^64 := by omega
  have native := state.native.2
  have codeNote : RankOrigin.InitializedHandleBuffer.constructorMetadata.roles 0 = some (.literal (.lit (F64.ofNat 9))) := rfl
  have protoNote : RankOrigin.InitializedHandleBuffer.constructorMetadata.roles 1 = some (.literal (.lit (F64.ofNat 26))) := rfl
  host_retained_plan_chain_after P.F, SliceOutputBRest using state, retained, sourceInst continuing_run previous initial_relation h

host_assert_retained_schema slice_output_b, 25

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``slice_output_b
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
      for (name,index) in [(`outputBNotes,1),(`outputBLive,7)] do
        let value := retained.getAppArgs[index]!
        let used ← args.filterM fun a => pure (value.find? (· == a)).isSome
        Parametric.Driver.addData ((← getCurrNamespace) ++ name) (← mkLambdaFVars used value)

end Host.Load.Run.Full.Ordinary.RetainedOracleConvolutionBatch
