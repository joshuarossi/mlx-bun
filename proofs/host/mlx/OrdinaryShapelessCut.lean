import host.mlx.OrdinaryShapelessStates
import host.ts.RenameKernelRfl

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.ShapelessCut
open Host.Ts
open Lean Elab Command Meta

/- Check each original step separately, then compose the original runs. This
keeps the kernel working set bounded while proving the candidate cut's exact
position inside the authoritative outer boundary. -/
run_cmd liftTermElabM do
  let scopeName ← getCurrNamespace
  let micro := (``P.RestStream.micro0.micro36.F).getPrefix
  let F := mkConst ``P.F
  let state (i : Nat) := mkConst (micro ++ Name.mkSimple s!"s{i}")
  let server (i : Nat) := mkConst (micro ++ Name.mkSimple s!"S{i}")
  let run (first count : Nat) := mkAppN (mkConst ``runS) #[F,mkRawNatLit count,state first,server first]
  let result (i : Nat) := mkAppM ``Prod.mk #[state i,server i] >>= fun pair => mkAppM ``Option.some #[pair]
  let add (name : Lean.Name) (type value : Lean.Expr) := addDecl (.thmDecl {name := scopeName ++ name,levelParams := [],type := type,value := value})
  let join (first count : Nat) (previous step : Lean.Expr) := mkAppN (mkConst ``runS_trans)
    #[F,mkRawNatLit count,mkRawNatLit 1,state first,state (first+count),state (first+count+1),
      server first,server (first+count),server (first+count+1),previous,step]
  for i in [:100] do
    let stepName := Name.mkSimple s!"step{i}"
    add stepName (← mkEq (run i 1) (← result (i+1))) (← mkEqRefl (run i 1))
    let current := mkConst (scopeName ++ stepName)
    let value := if i == 0 then current else join 0 i (mkConst (scopeName ++ Name.mkSimple s!"up{i}")) current
    add (Name.mkSimple s!"up{i+1}") (← mkEq (run 0 (i+1)) (← result (i+1))) value
    if i ≥ 86 then
      let count := i-86
      let value := if count == 0 then current else
        join 86 count (mkConst (scopeName ++ Name.mkSimple s!"suffix{count}")) current
      add (Name.mkSimple s!"suffix{count+1}") (← mkEq (run 86 (count+1)) (← result (i+1))) value

/-- The selected native call is reached from the original outer boundary. -/
theorem source_prefix : runS P.F 86 P.RestStream.micro0.s36 P.RestStream.micro0.S36 =
    some (P.RestStream.micro0.micro36.s86,P.RestStream.micro0.micro36.S86) := up86

theorem source_suffix : runS P.F 14 P.RestStream.micro0.micro36.s86 P.RestStream.micro0.micro36.S86 =
    some (P.RestStream.micro0.s37,P.RestStream.micro0.S37) := suffix14

theorem source_outer : runS P.F 100 P.RestStream.micro0.s36 P.RestStream.micro0.S36 =
    some (P.RestStream.micro0.s37,P.RestStream.micro0.S37) := up100

end Host.Load.Run.Full.Ordinary.ShapelessCut
