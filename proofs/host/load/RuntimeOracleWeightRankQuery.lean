import host.load.RuntimeOracleWeightMetadataPlan

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RetainedOracleConcatReturnBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles

noncomputable def metadataRules (lo hi : Nat) : List Lean.Name :=
  ((WeightMetadata.rules.zip WeightMetadata.starts).filter (fun entry => decide (lo ≤ entry.2 ∧ entry.2 < hi))).map Prod.fst
noncomputable def WeightRankQuery.rules := metadataRules 484 485
noncomputable def WeightShapeEntry.rules := metadataRules 485 529
noncomputable def WeightShapeQuery.rules := metadataRules 529 530
noncomputable def WeightShapeReturn.rules := metadataRules 530 570

host_retained_theorem weight_rank_query := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (roles : Nat → GraphNode) (boundary : Nat → Prop)
    (objects : Nat → Object) (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer (P.RestStream.micro0.micro4.S84.substitute LoopVariables.oracleVariables)) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host) R live framed before after old old'
      P.RestStream.micro0.micro4.s84 s)
    (inventory : RetainedInventory (weightRankNotes notes caller) ν₀ ν C₀ C R live P.RestStream.micro0.micro4.s84 s)
    (signatureFrame : ¬ framed WeightMetadata.Block484.types) (owned : H 1365) => by
  host_retained_plan_chain P.F, WeightRankQuery using h, inventory, inst
host_assert_retained_schema weight_rank_query, 1

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``weight_rank_query
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
      for (name,index) in [(`rankQueryNotes,1),(`rankQueryLive,7)] do
        let value := retained.getAppArgs[index]!
        let used ← args.filterM fun a => pure (value.find? (· == a)).isSome
        Parametric.Driver.addData ((← getCurrNamespace) ++ name) (← mkLambdaFVars used value)

end Host.Load.Run.Full.Ordinary.RetainedOracleConcatReturnBatch
