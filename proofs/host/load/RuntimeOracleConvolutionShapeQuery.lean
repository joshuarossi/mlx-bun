import host.load.RuntimeOracleConvolutionShapeEntry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RetainedOracleConvolutionBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles

noncomputable def ShapeQuery.rules := (ConvolutionShape.rules.zip ConvolutionShape.starts).filterMap (fun entry => if entry.2 == 668 then some entry.1 else none)

host_retained_theorem convolution_shape_query := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (roles : Nat → GraphNode) (boundary : Nat → Prop)
    (objects : Nat → Object) (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer (P.RestStream.micro0.micro6.S68.substitute LoopVariables.oracleVariables)) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host) R live framed before after old old'
      P.RestStream.micro0.micro6.s68 s)
    (inventory : RetainedInventory (shapeEntryNotes notes caller) ν₀ ν C₀ C R live P.RestStream.micro0.micro6.s68 s)
    (signatureFrame : ¬ framed ConvolutionShape.Block668.types) (owned : H 29372) (region : R.region (4*29372) = 4*R.handle 29372) => by
  host_retained_plan_chain P.F, ShapeQuery using h, inventory, inst
host_assert_retained_schema convolution_shape_query, 1

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``convolution_shape_query
  forallTelescope info.type fun args tail => do
    let tail ← whnf tail
    unless tail.isAppOfArity ``Exists 2 do throwError "expected weight rank result"
    lambdaTelescope tail.getAppArgs[1]! fun _ body => do
      let rec inventory (p : Lean.Expr) : MetaM Lean.Expr := do
        if p.getAppFn.isConstOf ``RetainedInventory then return p
        if p.isAppOfArity ``And 2 then
          try inventory p.getAppArgs[0]! catch _ => inventory p.getAppArgs[1]!
        else throwError "missing weight rank inventory"
      let retained ← inventory body
      for (name,index) in [(`shapeQueryNotes,1),(`shapeQueryLive,7)] do
        let value := retained.getAppArgs[index]!
        let used ← args.filterM fun a => pure (value.find? (· == a)).isSome
        Parametric.Driver.addData ((← getCurrNamespace) ++ name) (← mkLambdaFVars used value)

end Host.Load.Run.Full.Ordinary.RetainedOracleConvolutionBatch
