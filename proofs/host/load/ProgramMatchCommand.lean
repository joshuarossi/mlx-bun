import host.load.ProgramCommand
namespace Host.Load.Program
open Lean Elab Command Meta Host.Mlx Host.Mlx.FfiEval

private def addProof (name : Lean.Name) (params : Array Lean.Expr) (ty value : Lean.Expr) : TermElabM Unit := do
  addDecl (.thmDecl { name, levelParams := [], type := ← mkForallFVars params ty, value := ← mkLambdaFVars params value })

private def trueType (value : Lean.Expr) : TermElabM Lean.Expr := mkEq value (mkConst ``Bool.true)

private def checkTrue (name : Lean.Name) (params : Array Lean.Expr) (value : Lean.Expr) : TermElabM Unit := do
  addProof name params (← trueType value) (← mkEqRefl value)

private def checkAll (pre : Lean.Name) (params : Array Lean.Expr) (f : Lean.Expr)
    (values : List Lean.Expr) (tails : Array Lean.Expr) : TermElabM Lean.Expr := do
  let values := values.toArray
  let mut next := mkConst ``Bool.true
  for j in [0:values.size + 1] do
    let i := values.size - j
    let name := pre ++ Name.mkSimple s!"all{i}"
    let value ← mkAppM ``allAt #[f, mkRawNatLit i, tails[i]!]
    if i == values.size then
      checkTrue name params value
    else
      let headName := pre ++ Name.mkSimple s!"head{i}"
      checkTrue headName params (mkApp2 f (mkRawNatLit i) values[i]!)
      let proof ← mkAppM ``allAt_cons #[f, mkRawNatLit i, values[i]!, tails[i+1]!, mkAppN (mkConst headName) params, next]
      addProof name params (← trueType value) proof
    next := mkAppN (mkConst name) params
  pure next

/-- Recheck an existing load program in a later actual graph. The program and
its carrier list are reused; only the finite per-node matching obligations are
new. No native evaluator is involved in this command. -/
elab "load_program_matches " name:ident " : " program:term ", " certificate:term ", " state:term : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  let pre := (← getCurrNamespace) ++ name.getId
  let nodeTy := mkConst ``Node
  let codeTy := mkApp (mkConst ``List [.zero]) nodeTy
  let natList := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)
  let pE ← instantiateMVars (← Term.elabTermAndSynthesize program (some codeTy))
  let cE ← instantiateMVars (← Term.elabTermAndSynthesize certificate (some natList))
  let sE ← instantiateMVars (← Term.elabTermAndSynthesize state (some (mkConst ``Ffi.St)))
  let mut nodes := #[]
  let mut tails := #[pE]
  let mut tail := pE
  repeat
    let value ← whnf tail
    if value.isAppOfArity ``List.nil 1 then break
    unless value.isAppOfArity ``List.cons 3 do
      throwError "load_program_matches: program does not reduce to a finite node list"
    let args := value.getAppArgs
    nodes := nodes.push args[1]!
    tail := args[2]!
    tails := tails.push tail
  let kernelTy := mkConst ``KernelSources
  let tableTy := mkApp (mkConst ``List [.zero]) (mkConst ``Host.Ts.F64)
  withLocalDeclD `table tableTy fun table => withLocalDeclD `sources kernelTy fun sources => do
    let allNu := mkApp (mkConst ``Host.Ts.CSrv.val) (mkApp (mkConst ``Host.Ts.CSrv.mk) table)
    let gE := mkAppN (mkConst ``ffiGraph) #[mkConst ``Int, mkConst ``InKey, mkApp (mkConst ``concrete) allNu, sources, sE]
    let matchF ← withLocalDeclD `i (mkConst ``Nat) fun i => withLocalDeclD `node nodeTy fun n => do
      let body ← mkAppM ``nodeOk #[gE, cE, i, mkApp (mkConst ``Node.erase) n]
      mkLambdaFVars #[i,n] body
    let matchedAll ← checkAll (pre ++ `checks) #[table,sources] matchF nodes.toList tails
    let proof ← mkAppM ``matches_of_allAt #[pE, gE, cE, matchedAll]
    addProof pre #[table,sources] (← inferType proof) proof
  logInfo m!"load_program_matches {pre}: {nodes.size} kernel-checked node obligations"

end Host.Load.Program
