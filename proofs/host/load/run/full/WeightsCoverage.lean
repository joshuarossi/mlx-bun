import host.load.run.full.Parameters
set_option Elab.async false
namespace Host.Load.Run.Full
open Lean Elab Command Meta

/-- Reuse the already checked load coverage certificate for each exact
parameter named by the weight extractor. Only proof terms are selected here;
each selected term is checked against the actual named tensor in the kernel. -/
elab "reuse_parameter_coverage" : command => liftTermElabM do
  let mut proofs : Std.HashMap Lean.Expr Lean.Name := {}
  let mut i : Nat := 0
  repeat
    let n := `Host.Load.Run.Full.code ++ Name.mkSimple s!"tensor{i}"
    let some ci := (← getEnv).find? n | break
    let .defnInfo d := ci | throwError "expected tensor definition {n}"
    proofs := proofs.insert d.value (`Host.Load.Run.Full.code.coverChecks ++ Name.mkSimple s!"head{i}")
    i := i + 1
  let mut j : Nat := 0
  repeat
    let n := `Host.Load.Run.Full.weights ++ Name.mkSimple s!"tensor{j}"
    let some ci := (← getEnv).find? n | break
    let .defnInfo d := ci | throwError "expected tensor definition {n}"
    let some proof := proofs[d.value]? | throwError "no existing coverage certificate for {n}"
    let lhs := mkApp3 (mkConst ``Host.Load.Program.covered)
      (mkConst ``code) (mkConst ``code.cert) (mkConst n)
    let type ← mkEq lhs (mkConst ``Bool.true)
    let name := `Host.Load.Run.Full.weights ++ Name.mkSimple s!"covered{j}"
    addDecl (.thmDecl { name, levelParams := [], type, value := mkConst proof })
    j := j + 1
  logInfo m!"reused {j} weight parameter coverage proofs from {i} checked load references"

reuse_parameter_coverage

elab "parameter_coverage" : tactic => do
  let goal ← Lean.Elab.Tactic.getMainGoal
  let target ← instantiateMVars (← goal.getType)
  let lhs := target.getAppArgs[1]!
  let tensor := lhs.getAppArgs[2]!
  let .const n _ := tensor | throwError "expected named parameter, got {tensor}"
  let .str pre last := n | throwError "expected tensor name"
  let some j := (last.drop 6).toString.toNat? | throwError "expected tensor index"
  goal.assign (mkConst (pre ++ Name.mkSimple s!"covered{j}"))
  Lean.Elab.Tactic.replaceMainGoal []

end Host.Load.Run.Full
