import host.load.RuntimeVectorNullSlot

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RetainedVectorPreludeBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles

host_retained_theorem vector_to_concat := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (roles : Nat → GraphNode) (boundary : Nat → Prop)
    (objects : Nat → Object) (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer P.RestStream.micro0.micro2.S50) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host) R live framed before after old old'
      P.RestStream.micro0.micro2.s50 s)
    (inventory : RetainedInventory (entryNotes notes caller) ν₀ ν C₀ C R live P.RestStream.micro0.micro2.s50 s)
    (budget : s.next+32 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (arrayBufferLive : live aArrayBufferProto) (arrayBufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (signatureFrame : ¬ framed Plan.Block295.types)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (constructorSelected : notes.captures.owners 95 = some RankOrigin.InitializedHandleBuffer.constructorMetadata)
    (typedLive : live 26) (typedFixed : R.a 26 = 26) => by
  have earlier := vector_to_slot notes caller ν₀ ν C₀ C R roles boundary objects H N tail host
    live framed before after old old' s inst h inventory budget functionLive functionFixed objectLive objectFixed
    arrayLive arrayFixed arrayBufferLive arrayBufferFixed signatureFrame globalLive globalFixed constructorSelected typedLive typedFixed
  have post := Classical.choose_spec earlier
  have previous := post.1
  have state := post.2.1
  have retained := post.2.2.1
  have sourceInst := post.2.2.2
  host_normalize_retained state, retained
  host_retained_plan_chain_after P.F, Ready using state, retained, sourceInst continuing_run previous initial_relation h
host_assert_retained_schema vector_to_concat, 86

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``vector_to_concat
  forallTelescope info.type fun args tail => do
    let tail ← whnf tail
    unless tail.isAppOfArity ``Exists 2 do throwError "expected connected concat entry"
    lambdaTelescope tail.getAppArgs[1]! fun _ body => do
      let rec inventory (p : Lean.Expr) : MetaM Lean.Expr := do
        if p.getAppFn.isConstOf ``RetainedInventory then return p
        if p.isAppOfArity ``And 2 then
          try inventory p.getAppArgs[0]! catch _ => inventory p.getAppArgs[1]!
        else throwError "missing connected concat inventory"
      let retained ← inventory body
      for (name,index) in [(`readyNotes,1),(`readyLive,7)] do
        let value := retained.getAppArgs[index]!
        let used ← args.filterM fun a => pure (value.find? (· == a)).isSome
        Parametric.Driver.addData ((← getCurrNamespace) ++ name) (← mkLambdaFVars used value)

theorem ready_captures (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (readyNotes notes caller).captures = notes.captures := rfl

end Host.Load.Run.Full.Ordinary.RetainedVectorPreludeBatch
